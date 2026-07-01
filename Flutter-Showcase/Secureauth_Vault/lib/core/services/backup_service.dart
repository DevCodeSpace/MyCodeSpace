import 'dart:convert';
import 'dart:io';

import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/drive/v3.dart' as drive;
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

import 'database_service.dart';
import 'encryption_service.dart';

class _AuthClient extends http.BaseClient {
  final Map<String, String> _headers;
  final http.Client _inner = http.Client();
  _AuthClient(this._headers);

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) {
    request.headers.addAll(_headers);
    return _inner.send(request);
  }
}

class BackupService extends GetxService {
  final _googleSignIn = GoogleSignIn(scopes: [drive.DriveApi.driveAppdataScope]);

  final isSignedIn = false.obs;
  final isSyncing = false.obs;
  final lastBackupTime = Rx<DateTime?>(null);

  Future<BackupService> init() async {
    isSignedIn.value = await _googleSignIn.isSignedIn();
    return this;
  }

  Future<bool> signIn() async {
    try {
      final account = await _googleSignIn.signIn();
      isSignedIn.value = account != null;
      return isSignedIn.value;
    } catch (e) {
      Get.snackbar('Sign In Failed', e.toString());
      return false;
    }
  }

  Future<void> signOut() async {
    await _googleSignIn.signOut();
    isSignedIn.value = false;
  }

  Future<drive.DriveApi?> _getDriveApi() async {
    final account = _googleSignIn.currentUser ?? await _googleSignIn.signInSilently();
    if (account == null) return null;

    final authHeaders = await account.authHeaders;
    return drive.DriveApi(_AuthClient(authHeaders));
  }

  Future<String?> _getOrCreateFolder(drive.DriveApi api) async {
    const folderName = 'VaultBackups';
    final result = await api.files.list(
      q: "name='$folderName' and mimeType='application/vnd.google-apps.folder' and trashed=false",
      spaces: 'appDataFolder',
    );

    if (result.files != null && result.files!.isNotEmpty) {
      return result.files!.first.id;
    }

    final folder = await api.files.create(
      drive.File()
        ..name = folderName
        ..mimeType = 'application/vnd.google-apps.folder'
        ..parents = ['appDataFolder'],
    );
    return folder.id;
  }

  Future<bool> backup() async {
    if (!isSignedIn.value) {
      final signed = await signIn();
      if (!signed) return false;
    }

    isSyncing.value = true;
    try {
      final api = await _getDriveApi();
      if (api == null) return false;

      final db = Get.find<DatabaseService>();
      final enc = Get.find<EncryptionService>();
      final hasBackupKey = await enc.hasBackupKey();
      if (!hasBackupKey) {
        Get.snackbar('Backup Setup Needed', 'Please unlock with PIN once, then try backup again');
        return false;
      }

      final rawData = await db.exportAll();
      final encrypted = await enc.encryptBackupPayload(jsonEncode(rawData));

      final folderId = await _getOrCreateFolder(api);
      final timestamp = DateTime.now().toIso8601String().replaceAll(':', '-');
      final fileName = 'vault_backup_$timestamp.enc';

      final bytes = utf8.encode(encrypted);
      final media = drive.Media(Stream.fromIterable([bytes]), bytes.length, contentType: 'application/octet-stream');

      await api.files.create(
        drive.File()
          ..name = fileName
          ..parents = folderId != null ? [folderId] : null,
        uploadMedia: media,
      );

      lastBackupTime.value = DateTime.now();
      Get.snackbar('Backup Successful', 'Your SecureAuth Vault has been backed up to Google Drive');
      return true;
    } catch (e) {
      Get.snackbar('Backup Failed', e.toString());
      return false;
    } finally {
      isSyncing.value = false;
    }
  }

  Future<List<drive.File>> listBackups() async {
    final api = await _getDriveApi();
    if (api == null) return [];

    try {
      final folderId = await _getOrCreateFolder(api);
      final result = await api.files.list(
        q: "'$folderId' in parents and name contains 'vault_backup' and trashed=false",
        orderBy: 'createdTime desc',
        spaces: 'appDataFolder',
        $fields: 'files(id, name, createdTime, size)',
      );
      return result.files ?? [];
    } catch (_) {
      return [];
    }
  }

  Future<bool> restoreLatestBackup({bool showIfMissing = true}) async {
    if (!isSignedIn.value) {
      final signed = await signIn();
      if (!signed) return false;
    }

    final backups = await listBackups();
    drive.File? latest;
    for (final file in backups) {
      if (file.id != null && file.id!.isNotEmpty) {
        latest = file;
        break;
      }
    }

    if (latest == null) {
      if (showIfMissing) {
        Get.snackbar('No Backup Found', 'No Google Drive backup found for this account');
      }
      return false;
    }

    return restore(latest.id!);
  }

  Future<bool> restore(String fileId) async {
    isSyncing.value = true;
    try {
      final api = await _getDriveApi();
      if (api == null) return false;

      final enc = Get.find<EncryptionService>();
      final db = Get.find<DatabaseService>();

      final media = await api.files.get(fileId, downloadOptions: drive.DownloadOptions.fullMedia) as drive.Media;

      final bytes = await media.stream.expand((b) => b).toList();
      final encrypted = utf8.decode(bytes);
      final isV2Backup = encrypted.startsWith('v2:');

      if (isV2Backup && !(await enc.hasBackupKey())) {
        Get.snackbar('Restore Needs PIN', 'Please unlock with PIN once on this device, then retry restore');
        return false;
      }

      final decrypted = await enc.decryptBackupPayload(encrypted);

      if (decrypted.isEmpty) {
        if (isV2Backup) {
          Get.snackbar('Restore Failed', 'Could not decrypt backup. Make sure the same PIN is used on both devices');
        } else {
          Get.snackbar('Restore Failed', 'This is an old device-bound backup. Create a new backup on old device and restore again');
        }
        return false;
      }

      final data = jsonDecode(decrypted) as Map<String, dynamic>;
      await db.importAll(data);

      Get.snackbar('Restore Successful', 'Your SecureAuth Vault has been restored');
      return true;
    } catch (e) {
      Get.snackbar('Restore Failed', e.toString());
      return false;
    } finally {
      isSyncing.value = false;
    }
  }

  // Future<bool> exportLocalBackup() async {
  //   try {
  //     final db = Get.find<DatabaseService>();
  //     final enc = Get.find<EncryptionService>();

  //     final rawData = await db.exportAll();
  //     final encrypted = await enc.encryptBackupPayload(jsonEncode(rawData));

  //     final dir = await getApplicationDocumentsDirectory();
  //     final timestamp = DateTime.now().toIso8601String().replaceAll(':', '-');
  //     final file = File('${dir.path}/vault_backup_$timestamp.enc');
  //     await file.writeAsString(encrypted);

  //     Get.snackbar('Export Successful', 'Backup saved to ${file.path}');
  //     return true;
  //   } catch (e) {
  //     Get.snackbar('Export Failed', e.toString());
  //     return false;
  //   }
  // }
  Future<bool> exportLocalBackup() async {
    try {
      final db = Get.find<DatabaseService>();
      final enc = Get.find<EncryptionService>();

      final rawData = await db.exportAll();
      final encrypted = await enc.encryptBackupPayload(jsonEncode(rawData));

      String downloadsPath;

      const androidDownloadsDir = '/storage/emulated/0/Download';

      if (await Directory(androidDownloadsDir).exists()) {
        downloadsPath = androidDownloadsDir;
      } else {
        downloadsPath = (await getApplicationDocumentsDirectory()).path;
      }

      final targetFolder = Directory('$downloadsPath/SecureAuth vault');
      if (!await targetFolder.exists()) {
        await targetFolder.create(recursive: true);
      }

      final timestamp = DateTime.now().toIso8601String().replaceAll(':', '-').split('.').first;
      final file = File('${targetFolder.path}/vault_backup_$timestamp.enc');
      await file.writeAsString(encrypted);

      Get.snackbar('Export Successful', 'Backup saved to: Downloads/SecureAuth vault/', snackPosition: SnackPosition.BOTTOM);
      return true;
    } catch (e) {
      Get.snackbar('Export Failed', e.toString(), snackPosition: SnackPosition.BOTTOM);
      return false;
    }
  }

  Future<bool> importLocalBackup(String filePath) async {
    try {
      final enc = Get.find<EncryptionService>();
      final db = Get.find<DatabaseService>();

      final encrypted = await File(filePath).readAsString();
      final decrypted = await enc.decryptBackupPayload(encrypted);

      if (decrypted.isEmpty) {
        Get.snackbar('Import Failed', 'Invalid or corrupted backup file');
        return false;
      }

      final data = jsonDecode(decrypted) as Map<String, dynamic>;
      await db.importAll(data);

      Get.snackbar('Import Successful', 'SecureAuth Vault restored from backup');
      return true;
    } catch (e) {
      Get.snackbar('Import Failed', e.toString());
      return false;
    }
  }
}
