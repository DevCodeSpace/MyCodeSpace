import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart' hide Response;
import 'package:path_provider/path_provider.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as shelf_io;
import 'package:shelf_router/shelf_router.dart';

import '../../core/constants/app_constants.dart';
import '../../domain/entities/share_manifest.dart';
import '../../domain/entities/shared_file.dart';
import '../../domain/entities/transfer_history_entry.dart';
import '../../domain/entities/transfer_session.dart';
import '../models/share_manifest_model.dart';
import 'connection_service.dart';
import 'device_catalog_service.dart';

class TransferService {
  TransferService({required ConnectionService connectionService, required DeviceCatalogService deviceCatalogService})
    : _connectionService = connectionService,
      _deviceCatalogService = deviceCatalogService,
      _sessionController = StreamController<TransferSession>.broadcast(),
      _dio = Dio() {
    _currentSession = const TransferSession(
      role: TransferRole.sender,
      status: TransferStatus.idle,
      peerName: 'No active transfer',
      files: [],
      totalBytes: 0,
      transferredBytes: 0,
      speedBytesPerSecond: 0,
      etaSeconds: 0,
      ipAddress: '',
      activeFileName: null,
    );

    // Listen for peer cancellations
    _connectionService.watchTransferCancellations().listen((peerIp) {
      if (_peerIpAddress == peerIp &&
          _currentSession.status != TransferStatus.completed &&
          _currentSession.status != TransferStatus.failed &&
          _currentSession.status != TransferStatus.cancelled) {
        cancel(notifyPeer: false);
      }
    });
  }

  final ConnectionService _connectionService;
  final DeviceCatalogService _deviceCatalogService;
  final StreamController<TransferSession> _sessionController;
  final Dio _dio;

  HttpServer? _server;
  TransferSession _currentSession = const TransferSession(
    role: TransferRole.sender,
    status: TransferStatus.idle,
    peerName: 'No active transfer',
    files: [],
    totalBytes: 0,
    transferredBytes: 0,
    speedBytesPerSecond: 0,
    etaSeconds: 0,
    ipAddress: '',
    activeFileName: null,
  );
  ShareManifest? _activeManifest;
  final Stopwatch _speedWatch = Stopwatch();
  DateTime _lastTick = DateTime.now();
  int _bytesAtLastTick = 0;
  int _currentFileIndex = 0;
  String? _receiverIpAddress;
  String? _receiverDirectory;
  final Map<String, String> _receivedFileLocations = <String, String>{};
  CancelToken? _cancelToken;
  bool _isPaused = false;
  int _lastEmitTime = 0;
  String? _peerIpAddress;

  TransferSession get currentSession => _currentSession;
  Stream<TransferSession> watchSession() => _sessionController.stream;

  Future<void> startSharing(List<SharedFile> files) async {
    await stopServer();
    final sessionFiles = List<SharedFile>.from(files);

    final ipAddress = await _connectionService.getLocalIpAddress() ?? '0.0.0.0';
    final deviceName = await _connectionService.getDisplayName();
    final totalBytes = files.fold<int>(0, (sum, file) => sum + file.size);
    final manifest = ShareManifest(deviceName: deviceName, ipAddress: ipAddress, port: AppConstants.defaultPort, files: sessionFiles, totalBytes: totalBytes);

    _activeManifest = manifest;
    _currentFileIndex = 0;
    _speedWatch
      ..reset()
      ..start();
    _lastTick = DateTime.now();
    _bytesAtLastTick = 0;

    final router = Router()
      ..get('/ping', (Request request) {
        return Response.ok(jsonEncode({'deviceName': deviceName, 'port': AppConstants.defaultPort}), headers: {'content-type': 'application/json'});
      })
      ..get('/manifest', (Request request) {
        // Capture receiver IP
        _peerIpAddress = request.context['shelf.io.connection_info'] != null ? (request.context['shelf.io.connection_info'] as HttpConnectionInfo).remoteAddress.address : null;

        return Response.ok(jsonEncode(ShareManifestModel.fromEntity(manifest).toJson()), headers: {'content-type': 'application/json'});
      })
      ..post('/acknowledge', (Request request) async {
        _emitSession(
          _currentSession.copyWith(
            status: TransferStatus.completed,
            transferredBytes: _activeManifest?.totalBytes ?? _currentSession.totalBytes,
            speedBytesPerSecond: 0,
            etaSeconds: 0,
            message: 'Transfer finished. The receiver has all selected files.',
          ),
        );
        return Response.ok('OK');
      })
      ..post('/progress', (Request request) async {
        final data = jsonDecode(await request.readAsString()) as Map<String, dynamic>;
        _emitSession(
          _currentSession.copyWith(
            transferredBytes: data['transferred'] as int,
            speedBytesPerSecond: (data['speed'] as num).toDouble(),
            etaSeconds: data['eta'] as int,
            activeFileName: data['activeFile'] as String?,
          ),
          force: true,
        );
        return Response.ok('OK');
      })
      ..post('/cancel', (Request request) async {
        _emitSession(_currentSession.copyWith(status: TransferStatus.cancelled, speedBytesPerSecond: 0, message: 'The receiver has cancelled the transfer.'), force: true);
        return Response.ok('OK');
      })
      ..get('/files/<fileId>', (Request request, String fileId) async {
        final sharedFile = sessionFiles.cast<SharedFile?>().firstWhere(
          (file) => file?.id == fileId,
          orElse: () => null,
        );

        if (sharedFile == null) {
          return Response.notFound('File not found in manifest');
        }

        final ioFile = File(sharedFile.path);
        if (!await ioFile.exists()) {
          return Response.notFound('Missing file');
        }

        return Response.ok(
          ioFile.openRead(),
          headers: {'content-type': 'application/octet-stream', 'content-length': '${sharedFile.size}', 'content-disposition': 'attachment; filename="${sharedFile.name}"'},
        );
      });

    final handler = const Pipeline().addMiddleware(logRequests()).addHandler(router.call);
    _server = await shelf_io.serve(handler, InternetAddress.anyIPv4, AppConstants.defaultPort, shared: true);

    _emitSession(
      TransferSession(
        role: TransferRole.sender,
        status: TransferStatus.waiting,
        peerName: 'Waiting for receiver',
        files: sessionFiles,
        totalBytes: totalBytes,
        transferredBytes: 0,
        speedBytesPerSecond: 0,
        etaSeconds: 0,
        ipAddress: ipAddress,
        activeFileName: files.isEmpty ? null : files.first.name,
        message: 'Share this local address or QR code with the receiver.',
        shareCode: '$ipAddress:${AppConstants.defaultPort}',
      ),
    );
  }

  Future<ShareManifest> fetchManifest(String ipAddress) async {
    final response = await _dio.get<Map<String, dynamic>>(
      'http://$ipAddress:${AppConstants.defaultPort}/manifest',
      options: Options(
        sendTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 15),
      ),
    );
    return ShareManifestModel.fromJson(response.data ?? <String, dynamic>{});
  }

  Future<void> downloadFiles({required String ipAddress, required ShareManifest manifest}) async {
    _receiverIpAddress = ipAddress;
    _peerIpAddress = ipAddress;
    _activeManifest = manifest;
    _cancelToken = CancelToken();
    _isPaused = false;

    final directory = await _resolveReceiveDirectory();
    _receiverDirectory = directory.path;
    _currentFileIndex = 0;
    _receivedFileLocations.clear();
    _speedWatch
      ..reset()
      ..start();
    _lastTick = DateTime.now();
    _bytesAtLastTick = 0;

    int lastNotifyTime = 0;

    _emitSession(
      TransferSession(
        role: TransferRole.receiver,
        status: TransferStatus.requesting,
        peerName: manifest.deviceName,
        files: manifest.files,
        totalBytes: manifest.totalBytes,
        transferredBytes: 0,
        speedBytesPerSecond: 0,
        etaSeconds: 0,
        ipAddress: ipAddress,
        activeFileName: manifest.files.isEmpty ? null : manifest.files.first.name,
        message: 'Preparing private receive folder.',
        shareCode: '$ipAddress:${manifest.port}',
      ),
    );

    await _downloadRemainingFiles(manifest);
  }

  Future<void> pauseOrResume() async {
    if (_currentSession.role == TransferRole.sender) return;

    if (_currentSession.status == TransferStatus.transferring) {
      _isPaused = true;
      _cancelToken?.cancel('paused');
      _emitSession(_currentSession.copyWith(status: TransferStatus.paused, speedBytesPerSecond: 0, message: 'Transfer paused. Resume when ready.'));
      return;
    }

    if (_currentSession.status == TransferStatus.paused && _activeManifest != null) {
      _cancelToken = CancelToken();
      _isPaused = false;
      await _downloadRemainingFiles(_activeManifest!);
    }
  }

  Future<void> cancel({bool notifyPeer = true}) async {
    if (notifyPeer &&
        _peerIpAddress != null &&
        (_currentSession.status == TransferStatus.transferring || _currentSession.status == TransferStatus.paused || _currentSession.status == TransferStatus.waiting)) {
      // Notify peer via control server
      unawaited(_connectionService.notifyTransferCancel(_peerIpAddress!));
    }

    _cancelToken?.cancel('cancelled');
    await stopServer();

    _emitSession(_currentSession.copyWith(status: TransferStatus.cancelled, speedBytesPerSecond: 0, message: 'Transfer cancelled.'), force: true);
  }

  Future<void> stopServer() async {
    await _server?.close(force: true);
    _server = null;
  }

  Future<List<TransferHistoryEntry>> buildHistoryEntries({required TransferDirection direction, required TransferRecordStatus status}) async {
    final manifest = _activeManifest;
    if (manifest == null) return [];

    return manifest.files
        .map(
          (file) => TransferHistoryEntry(
            id: '${DateTime.now().microsecondsSinceEpoch}-${file.id}',
            fileName: file.name,
            filePath: direction == TransferDirection.received ? (_receivedFileLocations[file.id] ?? '${_receiverDirectory ?? ''}/${file.name}') : file.path,
            fileSize: file.size,
            fileCategory: file.category,
            direction: direction,
            status: status,
            peerName: manifest.deviceName,
            timestamp: DateTime.now(),
          ),
        )
        .toList();
  }

  Future<void> _downloadRemainingFiles(ShareManifest manifest) async {
    final directoryPath = _receiverDirectory;
    final receiverIpAddress = _receiverIpAddress;
    if (directoryPath == null || receiverIpAddress == null) return;

    final completedBytes = manifest.files.take(_currentFileIndex).fold<int>(0, (sum, file) => sum + file.size);

    int lastNotifyTime = 0;

    _emitSession(
      _currentSession.copyWith(
        status: TransferStatus.transferring,
        transferredBytes: completedBytes,
        activeFileName: manifest.files[_currentFileIndex].name,
        message: 'Receiving files securely over your local network.',
      ),
    );

    try {
      for (int index = _currentFileIndex; index < manifest.files.length; index++) {
        if (_currentSession.status == TransferStatus.cancelled) break;

        final file = manifest.files[index];
        final targetPath = '$directoryPath/${file.name}';
        final targetFile = File(targetPath);
        if (await targetFile.exists()) {
          await targetFile.delete();
        }

        await _dio.download(
          'http://$receiverIpAddress:${manifest.port}/files/${file.id}',
          targetPath,
          cancelToken: _cancelToken,
          onReceiveProgress: (received, total) {
            final transferredBytes = completedBytes + manifest.files.sublist(_currentFileIndex, index).fold<int>(0, (sum, item) => sum + item.size) + received;

            _updateProgress(file, received, TransferRole.receiver, transferredOverride: transferredBytes);

            // Notify sender of actual progress (throttle to every 100ms for strictly equal progress)
            final now = DateTime.now().millisecondsSinceEpoch;
            if (now - lastNotifyTime > 100) {
              lastNotifyTime = now;
              _dio
                  .post(
                    'http://$receiverIpAddress:${manifest.port}/progress',
                    data: {
                      'transferred': transferredBytes,
                      'speed': _currentSession.speedBytesPerSecond,
                      'eta': _currentSession.etaSeconds,
                      'activeFile': _currentSession.activeFileName,
                    },
                  )
                  .catchError((_) => null); // Silent fail
            }
          },
          options: Options(
            sendTimeout: const Duration(seconds: 15),
            receiveTimeout: const Duration(minutes: 60),
          ),
        );

        final publishedPath = await _publishReceivedFile(file: file, tempPath: targetPath);
        _receivedFileLocations[file.id] = publishedPath ?? targetPath;

        _currentFileIndex = index + 1;
      }

      // Sync completion with sender
      try {
        await _dio.post('http://$receiverIpAddress:${manifest.port}/acknowledge');
      } catch (e) {
        // Fallback or log if sync fails
      }

      _emitSession(
        _currentSession.copyWith(
          status: TransferStatus.completed,
          transferredBytes: manifest.totalBytes,
          speedBytesPerSecond: 0,
          etaSeconds: 0,
          message: Platform.isAndroid ? 'All files saved to your Gallery, Downloads, or Files app.' : 'All files saved to $_receiverDirectory.',
        ),
      );
    } on DioException catch (error) {
      if (_isPaused) return;
      if (_currentSession.status == TransferStatus.cancelled) return;

      _emitSession(
        _currentSession.copyWith(
          status: error.type == DioExceptionType.cancel
              ? TransferStatus.cancelled
              : TransferStatus.failed,
          speedBytesPerSecond: 0,
          message: error.message ?? 'Unable to complete download.',
        ),
      );
    } catch (error) {
      if (_isPaused) return;
      if (_currentSession.status == TransferStatus.cancelled) return;

      _emitSession(
        _currentSession.copyWith(
          status: TransferStatus.failed,
          speedBytesPerSecond: 0,
          message: 'System error: ${error.toString()}',
        ),
      );
    }
  }

  Future<Directory> _resolveReceiveDirectory() async {
    Directory baseDirectory;
    if (Platform.isAndroid) {
      baseDirectory = await getExternalStorageDirectory() ?? await getApplicationDocumentsDirectory();
    } else {
      baseDirectory = await getApplicationDocumentsDirectory();
    }

    final receiveDirectory = Directory('${baseDirectory.path}/${AppConstants.receiveFolderName}');
    if (!await receiveDirectory.exists()) {
      await receiveDirectory.create(recursive: true);
    }
    return receiveDirectory;
  }

  Future<String?> _publishReceivedFile({required SharedFile file, required String tempPath}) async {
    if (!Platform.isAndroid) {
      return tempPath;
    }

    try {
      return await _deviceCatalogService.publishReceivedFile(sourcePath: tempPath, fileName: file.name, category: file.category);
    } catch (_) {
      return tempPath;
    }
  }

  void _updateProgress(SharedFile file, int deltaBytes, TransferRole role, {int? transferredOverride}) {
    final manifest = _activeManifest;
    if (manifest == null) return;

    final nextTransferred = transferredOverride ?? (_currentSession.transferredBytes + deltaBytes).clamp(0, manifest.totalBytes);
    final now = DateTime.now();
    final elapsedMs = now.difference(_lastTick).inMilliseconds;

    double speed = _currentSession.speedBytesPerSecond;
    if (elapsedMs >= 400) {
      final diff = nextTransferred - _bytesAtLastTick;
      speed = diff <= 0 ? 0 : diff / (elapsedMs / 1000);
      _lastTick = now;
      _bytesAtLastTick = nextTransferred;
    }

    final remainingBytes = manifest.totalBytes - nextTransferred;
    final eta = speed <= 0 ? 0 : (remainingBytes / speed).round();

    _emitSession(
      _currentSession.copyWith(
        role: role,
        status: TransferStatus.transferring,
        peerName: manifest.deviceName,
        files: manifest.files,
        totalBytes: manifest.totalBytes,
        transferredBytes: nextTransferred,
        speedBytesPerSecond: speed,
        etaSeconds: eta,
        ipAddress: manifest.ipAddress,
        activeFileName: file.name,
        message: '${role == TransferRole.sender ? 'Sending' : 'Receiving'} ${file.name}',
        shareCode: '${manifest.ipAddress}:${manifest.port}',
      ),
    );

    // Removed: Automatic completion based on local write stream.
    // Completion is now triggered via /acknowledge endpoint from receiver.
  }

  void _emitSession(TransferSession session, {bool force = false}) {
    final now = DateTime.now().millisecondsSinceEpoch;
    // Throttle progress updates to ~10fps (every 100ms) to prevent UI lag
    if (!force && session.status == TransferStatus.transferring && now - _lastEmitTime < 100) {
      return;
    }

    _lastEmitTime = now;
    _currentSession = session;
    if (!_sessionController.isClosed) {
      _sessionController.add(session);
    }
  }
}
