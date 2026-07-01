import 'dart:io';
import 'dart:math' as math;

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';

import '../../services/face_recognition_service.dart';
import 'attendance_controller.dart';

enum _LivenessAction { blink, turnHeadLeft, turnHeadRight }

class FaceScanView extends StatefulWidget {
  const FaceScanView({super.key});

  @override
  State<FaceScanView> createState() => _FaceScanViewState();
}

class _FaceScanViewState extends State<FaceScanView> {
  CameraController? _camCtrl;
  final _frs = FaceRecognitionService();
  bool _processing = false;
  bool _cameraReady = false;
  bool _done = false;
  String _instruction = 'Position your face in the oval';
  bool _faceDetected = false;
  int _noFaceFrames = 0;
  int _scanGeneration = 0;
  int? _activeTrackingId;
  Rect? _lastFaceBounds;
  static const _kNoFaceThreshold = 2;
  late CameraDescription _camera;

  late List<_LivenessAction> _actions;
  int _actionIdx = 0;
  bool _eyeWasClosed = false;
  int _holdFrames = 0;
  static const _kHoldRequired = 2;

  @override
  void initState() {
    super.initState();
    _actions = [_LivenessAction.blink, _LivenessAction.turnHeadLeft, _LivenessAction.turnHeadRight];
    _initCamera();
  }

  // ---------------------------------------------------------------------------
  // Camera
  // ---------------------------------------------------------------------------

  Future<void> _initCamera() async {
    await _frs.init();
    final cameras = await availableCameras();
    _camera = cameras.firstWhere((c) => c.lensDirection == CameraLensDirection.front, orElse: () => cameras.first);
    _camCtrl = CameraController(
      _camera,
      ResolutionPreset.medium,
      enableAudio: false,
      imageFormatGroup: Platform.isAndroid ? ImageFormatGroup.nv21 : ImageFormatGroup.bgra8888,
    );
    await _camCtrl!.initialize();
    if (!mounted) return;
    setState(() => _cameraReady = true);
    _camCtrl!.startImageStream(_onFrame);
  }

  // ---------------------------------------------------------------------------
  // Frame processing
  // ---------------------------------------------------------------------------

  Future<void> _onFrame(CameraImage image) async {
    if (_processing || _done) return;
    _processing = true;
    try {
      final faces = await _frs.detectFacesFromStream(image, _camera);
      if (!mounted) return;

      if (faces.isEmpty) {
        _noFaceFrames++;
        if ((_faceDetected || _actionIdx > 0) && _noFaceFrames >= _kNoFaceThreshold) {
          _resetLivenessProgress('Keep the same face in the oval');
        }
        return;
      }

      if (faces.length > 1) {
        _resetLivenessProgress('Only one face should be visible');
        return;
      }

      final face = _largestFace(faces);
      if (!_isSameContinuousFace(face)) return;

      _noFaceFrames = 0;
      if (!_faceDetected) setState(() => _faceDetected = true);
      _checkLiveness(face);
    } finally {
      _processing = false;
    }
  }

  Face _largestFace(List<Face> faces) {
    return faces.reduce((a, b) {
      final aArea = a.boundingBox.width * a.boundingBox.height;
      final bArea = b.boundingBox.width * b.boundingBox.height;
      return aArea >= bArea ? a : b;
    });
  }

  bool _isSameContinuousFace(Face face) {
    final trackingId = face.trackingId;
    if (_activeTrackingId == null && trackingId != null) {
      _activeTrackingId = trackingId;
    } else if (_activeTrackingId != null && trackingId != null && _activeTrackingId != trackingId) {
      _resetLivenessProgress('Face changed. Start again');
      return false;
    }

    final previousBounds = _lastFaceBounds;
    if (previousBounds != null) {
      final movement = (face.boundingBox.center - previousBounds.center).distance;
      final maxExpectedMovement = math.max(previousBounds.width, previousBounds.height) * 0.35;
      final previousArea = previousBounds.width * previousBounds.height;
      final currentArea = face.boundingBox.width * face.boundingBox.height;
      final areaRatio = previousArea <= 0 ? 1.0 : currentArea / previousArea;

      if (movement > maxExpectedMovement || areaRatio < 0.65 || areaRatio > 1.55) {
        _resetLivenessProgress('Keep the same face in view');
        return false;
      }
    }

    _lastFaceBounds = face.boundingBox;
    return true;
  }

  void _resetLivenessProgress(String instruction) {
    _scanGeneration++;
    _activeTrackingId = null;
    _lastFaceBounds = null;
    _noFaceFrames = 0;
    _actionIdx = 0;
    _eyeWasClosed = false;
    _holdFrames = 0;
    if (!mounted || _done) return;
    setState(() {
      _faceDetected = false;
      _instruction = instruction;
    });
  }

  // ---------------------------------------------------------------------------
  // Liveness checks
  // ---------------------------------------------------------------------------

  void _checkLiveness(Face face) {
    if (_actionIdx >= _actions.length) return;

    switch (_actions[_actionIdx]) {
      case _LivenessAction.blink:
        if (_instruction != 'Please BLINK your eyes') {
          setState(() => _instruction = 'Please BLINK your eyes');
        }
        final leftOpen = face.leftEyeOpenProbability ?? 1.0;
        final rightOpen = face.rightEyeOpenProbability ?? 1.0;
        if (!_eyeWasClosed && leftOpen < 0.3 && rightOpen < 0.3) {
          _eyeWasClosed = true;
        } else if (_eyeWasClosed && leftOpen > 0.7 && rightOpen > 0.7) {
          _eyeWasClosed = false;
          _holdFrames = 0;
          _completeAction();
        }
        return;

      case _LivenessAction.turnHeadLeft:
        if (_instruction != 'Turn your head Right') {
          setState(() => _instruction = 'Turn your head RIGHT');
        }
        final angle = face.headEulerAngleY ?? 0;
        _applyHoldFrames(angle < -25);
        return;

      case _LivenessAction.turnHeadRight:
        if (_instruction != 'Turn your head Left') {
          setState(() => _instruction = 'Turn your head LEFT');
        }
        final angle = face.headEulerAngleY ?? 0;
        _applyHoldFrames(angle > 25);
        return;
    }
  }

  void _applyHoldFrames(bool conditionMet) {
    if (conditionMet) {
      _holdFrames++;
      if (_holdFrames >= _kHoldRequired) {
        _holdFrames = 0;
        _completeAction();
      }
    } else {
      _holdFrames = 0;
    }
  }

  void _completeAction() {
    _actionIdx++;

    if (_actionIdx >= _actions.length) {
      _onLivenessDone();
    } else {
      setState(() {});
    }
  }

  Future<void> _onLivenessDone() async {
    if (!mounted) return;
    final captureGeneration = _scanGeneration;
    setState(() => _instruction = 'Capturing...');

    if (!mounted || captureGeneration != _scanGeneration) return;

    _done = true;
    await _stopImageStreamIfNeeded();

    try {
      final photo = await _camCtrl!.takePicture();
      final faces = await _frs.detectFacesFromFile(photo.path);

      if (faces.isEmpty) {
        _fail('Face not found in captured photo. Please try again.');
        return;
      }

      final embedding = await _frs.extractEmbeddingFromFile(photo.path, _largestFace(faces).boundingBox);

      if (embedding == null) {
        _fail('Could not extract face features. Please try again.');
        return;
      }

      if (mounted) {
        await Get.find<AttendanceController>().onFaceScanSuccess(embedding: embedding);
      }
      await _deleteTempPhoto(photo.path);
    } catch (e) {
      debugPrint('[FaceScan] processing error: $e');
      _fail('Processing error. Please try again.');
    }
  }

  Future<void> _deleteTempPhoto(String photoPath) async {
    try {
      final file = File(photoPath);
      if (await file.exists()) await file.delete();
    } catch (e) {
      debugPrint('[FaceScan] temp photo delete ignored: $e');
    }
  }

  void _fail(String reason) {
    if (mounted) Get.find<AttendanceController>().onLivenessFailed(reason);
  }

  Future<void> _stopImageStreamIfNeeded() async {
    final camCtrl = _camCtrl;
    if (camCtrl == null || !camCtrl.value.isInitialized || !camCtrl.value.isStreamingImages) return;

    try {
      await camCtrl.stopImageStream();
    } on CameraException catch (e) {
      debugPrint('[FaceScan] stopImageStream ignored: ${e.code}');
    }
  }

  @override
  void dispose() {
    _camCtrl?.dispose();
    _frs.dispose();
    super.dispose();
  }

  // ---------------------------------------------------------------------------
  // UI
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final ctrl = Get.find<AttendanceController>();
      final emp = ctrl.pendingEmployee.value;
      final purpose = ctrl.pendingPurpose.value;
      final title = switch (purpose) {
        ScanPurpose.enroll => 'Enroll Face',
        ScanPurpose.checkIn => 'Check In',
        ScanPurpose.checkOut => 'Check Out',
        ScanPurpose.unified => 'Smart Scan',
      };

      return Scaffold(
        backgroundColor: Colors.black,
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          foregroundColor: Colors.white,
          leading: IconButton(icon: const Icon(Icons.close), onPressed: () => _fail('Cancelled by user')),
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 21)),
              if (emp != null) Text(emp.name, style: const TextStyle(color: Colors.white70, fontSize: 16)),
            ],
          ),
        ),
        body: _cameraReady && _camCtrl != null
            ? Stack(
                fit: StackFit.expand,
                children: [
                  CameraPreview(_camCtrl!),
                  _OvalOverlay(faceDetected: _faceDetected),
                  Positioned(
                    left: 16,
                    right: 16,
                    bottom: 60,
                    child: Column(
                      children: [
                        // Progress dots per liveness action
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(_actions.length, (i) {
                            return Container(
                              margin: const EdgeInsets.symmetric(horizontal: 4),
                              width: 12,
                              height: 12,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: i < _actionIdx
                                    ? Colors.green
                                    : i == _actionIdx
                                    ? Colors.white
                                    : Colors.white30,
                              ),
                            );
                          }),
                        ),
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                          decoration: BoxDecoration(color: Colors.black.withValues(alpha: 0.65), borderRadius: BorderRadius.circular(12)),
                          child: Text(
                            _instruction,
                            style: const TextStyle(color: Colors.white, fontSize: 20),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              )
            : const Center(child: CircularProgressIndicator(color: Colors.white)),
      );
    });
  }
}

// ---------------------------------------------------------------------------
// Oval overlay
// ---------------------------------------------------------------------------

class _OvalOverlay extends StatelessWidget {
  final bool faceDetected;
  const _OvalOverlay({required this.faceDetected});

  @override
  Widget build(BuildContext context) => CustomPaint(painter: _OvalPainter(faceDetected: faceDetected));
}

class _OvalPainter extends CustomPainter {
  final bool faceDetected;
  const _OvalPainter({required this.faceDetected});

  @override
  void paint(Canvas canvas, Size size) {
    final oval = Rect.fromCenter(center: Offset(size.width / 2, size.height * 0.43), width: size.width * 0.72, height: size.height * 0.46);

    // Darken area outside the oval.
    canvas.drawPath(
      Path()
        ..addRect(Rect.fromLTWH(0, 0, size.width, size.height))
        ..addOval(oval)
        ..fillType = PathFillType.evenOdd,
      Paint()..color = Colors.black.withValues(alpha: 0.5),
    );

    // Oval border: green when face detected, white otherwise.
    canvas.drawOval(
      oval,
      Paint()
        ..color = faceDetected ? Colors.green : Colors.white
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3,
    );
  }

  @override
  bool shouldRepaint(_OvalPainter old) => old.faceDetected != faceDetected;
}
