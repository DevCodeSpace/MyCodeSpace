import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mouse_demo/controllers/settings_controller.dart';

import '../components/pushable_button.dart';
import '../controllers/trackpad_controller.dart';
import '../theme/app_colors.dart';

class TrackpadScreen extends GetView<TrackpadController> {
  const TrackpadScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = Get.find<SettingsController>();
    // Local UI State for gestures
    final RxInt pointerCount = 0.obs;
    final RxMap<int, List<Offset>> activeTrails = <int, List<Offset>>{}.obs;
    Offset? lastDragPosition;

    const double outerRadius = 24.0;
    const int maxTrailLength = 20;

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(controller.desktopName.value.toUpperCase()),
        actions: [IconButton(onPressed: controller.openMoreSheet, icon: Icon(Icons.more_vert))],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(outerRadius),
                  gradient: LinearGradient(
                    colors: [AppColors.primary.withValues(alpha: 0.1), AppColors.primary.withValues(alpha: 0.01)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  border: Border.all(color: AppColors.primary.withValues(alpha: 0.15)),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(outerRadius),
                  child: Column(
                    children: [
                      Expanded(
                        child: Listener(
                          onPointerDown: (event) {
                            pointerCount.value++;
                            activeTrails[event.pointer] = [event.localPosition];
                          },
                          onPointerMove: (event) {
                            if (activeTrails.containsKey(event.pointer)) {
                              final trail = List<Offset>.from(activeTrails[event.pointer]!);
                              trail.add(event.localPosition);
                              if (trail.length > maxTrailLength) {
                                trail.removeAt(0);
                              }
                              activeTrails[event.pointer] = trail;
                            }
                          },
                          onPointerUp: (event) {
                            pointerCount.value--;
                            activeTrails.remove(event.pointer);
                          },
                          child: GestureDetector(
                            behavior: HitTestBehavior.opaque,
                            onPanUpdate: (details) {
                              if (pointerCount.value == 2 && (settings.isVerticalScrollEnabled.value || settings.isHorizontalScrollEnabled.value)) {
                                controller.setAction("Scrolling");
                                controller.scroll(
                                  settings.isHorizontalScrollEnabled.value ? details.delta.dx * settings.scrollSensitivity.value : 0,
                                  settings.isVerticalScrollEnabled.value ? details.delta.dy * settings.scrollSensitivity.value : 0,
                                );
                              } else if (settings.isMoveEnabled.value) {
                                controller.setAction("Moving");
                                controller.move(details.delta.dx * settings.moveSensitivity.value, details.delta.dy * settings.moveSensitivity.value);
                              }
                            },

                            /// CLICK
                            onTap: () {
                              controller.setAction("Left Click");
                              controller.click();
                            },

                            /// DOUBLE CLICK
                            onDoubleTap: () {
                              controller.setAction("Double Click");
                              controller.doubleClick();
                            },

                            /// DRAG START
                            onLongPressStart: (details) {
                              if (!settings.isDragEnabled.value) return;
                              controller.setAction("Dragging");
                              controller.mouseDown();
                              lastDragPosition = details.localPosition;
                            },

                            /// DRAG MOVE
                            onLongPressMoveUpdate: (details) {
                              if (!settings.isDragEnabled.value) return;
                              if (lastDragPosition != null) {
                                final current = details.localPosition;
                                controller.move(
                                  (current.dx - lastDragPosition!.dx) * settings.dragSensitivity.value,
                                  (current.dy - lastDragPosition!.dy) * settings.dragSensitivity.value,
                                );
                                lastDragPosition = current;
                              }
                            },

                            /// DRAG END
                            onLongPressEnd: (_) {
                              if (!settings.isDragEnabled.value) return;
                              controller.mouseUp();
                              controller.setAction("");
                              lastDragPosition = null;
                            },
                            // onScaleStart: (details) {
                            //   lastScale = 1.0;
                            //   lastFocalPoint = details.focalPoint;
                            //   currentGestureMode = "none"; // Reset lock on new touch
                            // },

                            // onScaleUpdate: (details) {
                            //   final current = details.focalPoint;
                            //   final dx = (current.dx - (lastFocalPoint?.dx ?? current.dx));
                            //   final dy = (current.dy - (lastFocalPoint?.dy ?? current.dy));
                            //   lastFocalPoint = current;

                            //   // 🖱️ 1 Finger: Standard Move
                            //   if (details.pointerCount == 1) {
                            //     controller.move(dx * PreferenceHelper.moveSensitivity, dy * PreferenceHelper.moveSensitivity);
                            //     return;
                            //   }

                            //   // 🖱️ 2 Fingers: Scroll or Zoom
                            //   if (details.pointerCount == 2) {
                            //     final double scaleDifference = (details.scale - 1.0).abs();
                            //     final double moveDistance = (dx.abs() + dy.abs());

                            //     // --- STEP 1: LOCK THE MODE ---
                            //     if (currentGestureMode == "none") {
                            //       if (scaleDifference > 0.08) {
                            //         currentGestureMode = "zooming";
                            //       } else if (moveDistance > 2.0) {
                            //         currentGestureMode = "scrolling";
                            //       }
                            //     }

                            //     // --- STEP 2: EXECUTE ONLY THE LOCKED MODE ---
                            //     if (currentGestureMode == "zooming") {
                            //       final scaleChange = details.scale - lastScale;
                            //       if (scaleChange.abs() > 0.03) {
                            //         if (scaleChange > 0) {
                            //           controller.zoomIn();
                            //         } else {
                            //           controller.zoomOut();
                            //         }
                            //         lastScale = details.scale;
                            //       }
                            //     } else if (currentGestureMode == "scrolling") {
                            //       controller.scroll(dx * PreferenceHelper.scrollSensitivity, dy * PreferenceHelper.scrollSensitivity);
                            //     }
                            //   }
                            // },

                            // onScaleEnd: (_) {
                            //   controller.setAction("");
                            //   lastFocalPoint = null;
                            //   currentGestureMode = "none"; // Release the lock
                            // },

                            // ✅ SAFE gestures
                            // onTap: () {
                            //   controller.setAction("Left Click");
                            //   controller.click();
                            // },

                            // onDoubleTap: () {
                            //   controller.setAction("Double Click");
                            //   controller.doubleClick();
                            // },

                            // // ✅ DRAG (without pan conflict)
                            // onLongPressStart: (_) {
                            //   controller.setAction("Dragging");
                            //   controller.mouseDown();
                            // },

                            // onLongPressEnd: (_) {
                            //   controller.mouseUp();
                            //   controller.setAction("");
                            // },
                            child: Stack(
                              children: [
                                // 1. BACKGROUND GRID
                                Opacity(
                                  opacity: 0.2,
                                  child: CustomPaint(
                                    painter: GridPainter(gridColor: AppColors.primary),
                                    size: Size.infinite,
                                  ),
                                ),

                                // 2. MULTI-GESTURE TRAIL (Updated to pass all active trails)
                                Obx(
                                  () => CustomPaint(
                                    painter: MultiTrailPainter(trails: activeTrails.values.toList()),
                                    size: Size.infinite,
                                  ),
                                ),
                                _buildActionOverlay(),
                              ],
                            ),
                          ),
                        ),
                      ),
                      _buildClickButtons(outerRadius),
                    ],
                  ),
                ),
              ),
            ),

            Text('Connected at ${controller.ipAddress}', style: TextStyle(fontSize: 12)),
          ],
        ),
      ),
    );
  }

  Widget _buildActionOverlay() {
    return Positioned(
      top: 20,
      left: 0,
      right: 0,
      child: Obx(() {
        if (controller.currentAction.value.isEmpty) return const SizedBox.shrink();
        return Center(
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(20)),
            child: Text(
              controller.currentAction.value,
              style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildClickButtons(double radius) {
    return SizedBox(
      height: 60,
      child: Row(
        spacing: 4,
        children: [
          Expanded(
            child: PushableButton(
              onPressed: controller.click,
              color: AppColors.primary,
              height: 60,
              borderRadius: BorderRadiusGeometry.only(bottomLeft: Radius.circular(radius)),
              child: SizedBox(),
            ),
          ),
          // const VerticalDivider(width: 1, color: Colors.white24),
          Expanded(
            child: PushableButton(
              onPressed: controller.rightClick,
              color: AppColors.primary,
              height: 60,
              borderRadius: BorderRadiusGeometry.only(bottomRight: Radius.circular(radius)),
              child: SizedBox(),
            ),
          ),
        ],
      ),
    );
  }
}

class GridPainter extends CustomPainter {
  final Color gridColor;

  GridPainter({required this.gridColor});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = gridColor
      ..strokeWidth = 1.0;

    for (double i = 0; i < size.width; i += 40) {
      for (double j = 0; j < size.height; j += 40) {
        canvas.drawCircle(Offset(i, j), 1, paint);
      }
    }
  }

  @override
  // Return true so it repaints when the theme changes
  bool shouldRepaint(covariant GridPainter oldDelegate) {
    return oldDelegate.gridColor != gridColor;
  }
}

class MultiTrailPainter extends CustomPainter {
  final List<List<Offset>> trails;
  // final Color color;

  MultiTrailPainter({required this.trails});

  @override
  void paint(Canvas canvas, Size size) {
    // Loop through every finger currently tracking on the screen
    for (final points in trails) {
      if (points.length < 2) continue;

      // Draw the trail for this specific finger
      for (int i = 0; i < points.length - 1; i++) {
        final double fraction = i / (points.length - 1);

        final paint = Paint()
          ..color = AppColors.primary.withValues(alpha: fraction * 0.8)
          ..strokeWidth = 2.0 + (fraction * 4.0)
          ..strokeCap = StrokeCap.round;

        canvas.drawLine(points[i], points[i + 1], paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant MultiTrailPainter oldDelegate) {
    // Return true so it repaints smoothly while dragging
    return true;
  }
}
