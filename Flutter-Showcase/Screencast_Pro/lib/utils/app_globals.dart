import 'package:flutter/widgets.dart';

// Attached to RepaintBoundary wrapping the whole app.
// CastStreamService uses this to capture screen frames.
final GlobalKey appCaptureKey = GlobalKey();
