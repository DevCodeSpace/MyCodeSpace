import 'package:flutter/material.dart';
import '../services/webrtc_service.dart';

class CallControlsBar extends StatelessWidget {
  final WebRTCService service;
  final bool isMobile;
  final bool isEmojiMenuOpen;
  final VoidCallback onToggleEmojiMenu;
  // final bool isChatOpen;
  final VoidCallback onToggleChat;
  final VoidCallback onLeaveRoom;

  const CallControlsBar({
    super.key,
    required this.service,
    this.isMobile = true,
    required this.isEmojiMenuOpen,
    required this.onToggleEmojiMenu,
    // required this.isChatOpen,
    required this.onToggleChat,
    required this.onLeaveRoom,
  });

  @override
  Widget build(BuildContext context) {
    if (isMobile) {
      return _buildMobileControls(context);
    } else {
      return _buildDesktopControls(context);
    }
  }

  Widget _buildDesktopControls(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: colorScheme.inverseSurface, borderRadius: BorderRadius.circular(320)),
      child: Row(mainAxisSize: MainAxisSize.min, spacing: 8, children: _buildDesktopControlButtons(context)),
    );
  }

  List<Widget> _buildDesktopControlButtons(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    const double buttonSize = 52;
    const double iconSize = 24;

    return [
      _buildM3Control(
        icon: service.isMuted ? Icons.mic_off : Icons.mic,
        label: 'Mic',
        isSelected: !service.isMuted,
        colorScheme: colorScheme,
        isDestructive: false,
        size: buttonSize,
        iconSize: iconSize,
        onPressed: service.toggleMute,
      ),
      CameraControlWithTooltip(service: service, buttonSize: buttonSize, iconSize: iconSize, colorScheme: colorScheme),
      // _buildM3Control(
      //   icon: service.isCameraOff && service.hasCamera ? Icons.videocam_off : Icons.videocam,
      //   label: 'Camera',
      //   isSelected: !service.isCameraOff && service.hasCamera,
      //   colorScheme: colorScheme,
      //   isDestructive: false,
      //   size: buttonSize,
      //   iconSize: iconSize,
      //   onPressed: service.toggleCamera,
      //   showBadge: !service.hasCamera,
      // ),
      if (service.canScreenShare)
        _buildM3Control(
          icon: service.isScreenSharing ? Icons.stop_screen_share : Icons.screen_share,
          label: service.isScreenSharing ? 'Stop Sharing' : 'Share Screen',
          isSelected: service.isScreenSharing,
          colorScheme: colorScheme,
          isDestructive: false,
          size: buttonSize,
          iconSize: iconSize,
          onPressed: service.toggleScreenShare,
        ),
      _buildM3Control(
        icon: Icons.emoji_emotions,
        label: 'Reactions',
        isSelected: isEmojiMenuOpen,
        colorScheme: colorScheme,
        isDestructive: false,
        size: buttonSize,
        iconSize: iconSize,
        onPressed: onToggleEmojiMenu,
      ),
      _buildM3Control(
        icon: Icons.chat,
        label: 'Chat',
        isSelected: false, //isChatOpen,
        colorScheme: colorScheme,
        isDestructive: false,
        size: buttonSize,
        iconSize: iconSize,
        onPressed: onToggleChat,
        showBadge: service.hasUnreadMessages,
      ),
      // _buildM3Control(
      //   icon: Icons.cameraswitch,
      //   label: 'Flip Camera',
      //   isSelected: false,
      //   colorScheme: colorScheme,
      //   isDestructive: false,
      //   size: buttonSize,
      //   iconSize: iconSize,
      //   onPressed: service.switchCamera,
      // ),
      _buildM3Control(
        icon: Icons.call_end,
        label: 'Leave Room',
        isSelected: true,
        colorScheme: colorScheme,
        isDestructive: true,
        size: buttonSize,
        iconSize: iconSize,
        onPressed: onLeaveRoom,
      ),
    ];
  }

  Widget _buildM3Control({
    required IconData icon,
    required String label,
    required bool isSelected,
    required ColorScheme colorScheme,
    required bool isDestructive,
    required VoidCallback onPressed,
    required double size,
    required double iconSize,
    bool showBadge = false,
  }) {
    final Color buttonColor;
    final Color iconColor;

    if (isDestructive) {
      buttonColor = colorScheme.errorContainer;
      iconColor = colorScheme.onErrorContainer;
    } else if (isSelected) {
      buttonColor = colorScheme.primaryContainer;
      iconColor = colorScheme.onPrimaryContainer;
    } else {
      buttonColor = colorScheme.surfaceContainerHighest;
      iconColor = colorScheme.onSurfaceVariant;
    }

    return Badge(
      isLabelVisible: showBadge,
      backgroundColor: Colors.amber.shade500,
      largeSize: 12,
      smallSize: 12,
      alignment: Alignment.topRight,
      child: IconButton(
        onPressed: onPressed,
        tooltip: label,
        style: IconButton.styleFrom(
          backgroundColor: buttonColor,
          foregroundColor: iconColor,
          minimumSize: Size(size, size),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(160)),
        ),
        icon: Icon(icon, size: iconSize),
      ),
    );
  }

  Widget _buildMobileControls(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    const double buttonSize = 48;
    const double iconSize = 20;

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(color: colorScheme.inverseSurface, borderRadius: BorderRadius.circular(32)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        spacing: 8,
        children: [
          CameraControlWithTooltip(service: service, buttonSize: buttonSize, iconSize: iconSize, colorScheme: colorScheme),
          _buildM3Control(
            icon: service.isMuted ? Icons.mic_off : Icons.mic,
            label: 'Mic',
            isSelected: !service.isMuted,
            colorScheme: colorScheme,
            isDestructive: false,
            size: buttonSize,
            iconSize: iconSize,
            onPressed: service.toggleMute,
          ),
          _buildM3Control(
            icon: Icons.emoji_emotions,
            label: 'Reactions',
            isSelected: isEmojiMenuOpen,
            colorScheme: colorScheme,
            isDestructive: false,
            size: buttonSize,
            iconSize: iconSize,
            onPressed: onToggleEmojiMenu,
          ),
          _buildM3Control(
            icon: Icons.more_vert,
            label: 'More',
            isSelected: false,
            colorScheme: colorScheme,
            isDestructive: false,
            size: buttonSize,
            iconSize: iconSize,
            onPressed: () => _showMoreBottomSheet(context),
            showBadge: service.hasUnreadMessages, // && !isChatOpen,
          ),
          Container(width: 1, height: 24, color: colorScheme.onInverseSurface.withValues(alpha: 0.2)),
          _buildM3Control(
            icon: Icons.call_end,
            label: 'Leave Room',
            isSelected: true,
            colorScheme: colorScheme,
            isDestructive: true,
            size: buttonSize,
            iconSize: iconSize,
            onPressed: onLeaveRoom,
          ),
        ],
      ),
    );
  }

  void _showMoreBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (service.canScreenShare)
                  ListTile(
                    leading: Icon(service.isScreenSharing ? Icons.stop_screen_share : Icons.screen_share),
                    title: Text(service.isScreenSharing ? 'Stop Sharing' : 'Share Screen'),
                    onTap: () {
                      Navigator.pop(context);
                      service.toggleScreenShare();
                    },
                  ),
                ListTile(
                  leading: Badge(isLabelVisible: service.hasUnreadMessages, child: const Icon(Icons.chat)),
                  title: const Text('In-call messages'),
                  onTap: () {
                    Navigator.pop(context);
                    onToggleChat();
                  },
                ),
                // ListTile(
                //   leading: const Icon(Icons.cameraswitch),
                //   title: const Text('Flip camera'),
                //   onTap: () {
                //     Navigator.pop(context);
                //     service.switchCamera();
                //   },
                // ),
                ListTile(
                  leading: const Icon(Icons.warning),
                  title: const Text('Report Meeting'),
                  onTap: () {
                    Navigator.pop(context);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class CameraControlWithTooltip extends StatefulWidget {
  final WebRTCService service;
  final double buttonSize;
  final double iconSize;
  final ColorScheme colorScheme;

  const CameraControlWithTooltip({super.key, required this.service, required this.buttonSize, required this.iconSize, required this.colorScheme});

  @override
  State<CameraControlWithTooltip> createState() => _CameraControlWithTooltipState();
}

class _CameraControlWithTooltipState extends State<CameraControlWithTooltip> {
  bool _dismissed = false;
  final LayerLink _layerLink = LayerLink();
  OverlayEntry? _overlayEntry;

  @override
  void didUpdateWidget(covariant CameraControlWithTooltip oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.service.hasCamera != oldWidget.service.hasCamera) {
      if (widget.service.hasCamera) {
        _dismissed = false;
      }
    }
  }

  @override
  void dispose() {
    _hideOverlay();
    super.dispose();
  }

  void _showOverlay() {
    if (_overlayEntry != null) return;
    _overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        width: 250,
        child: CompositedTransformFollower(
          link: _layerLink,
          showWhenUnlinked: false,
          targetAnchor: Alignment.topCenter,
          followerAnchor: Alignment.bottomCenter,
          offset: const Offset(0, -12),
          child: Material(color: Colors.transparent, child: _buildWarningPopup()),
        ),
      ),
    );
    Overlay.of(context).insert(_overlayEntry!);
  }

  void _hideOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  void _updateOverlayState() {
    if (!mounted) return;
    final showTooltip = !widget.service.hasCamera && !_dismissed;
    if (showTooltip) {
      _showOverlay();
    } else {
      _hideOverlay();
    }
  }

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) => _updateOverlayState());

    return CompositedTransformTarget(link: _layerLink, child: _buildCameraButton());
  }

  Widget _buildCameraButton() {
    final bool hasNoCamera = !widget.service.hasCamera;
    final bool isSelected = widget.service.isInitialized && !widget.service.isCameraOff && widget.service.hasCamera;
    final Color buttonColor = isSelected ? widget.colorScheme.primaryContainer : widget.colorScheme.surfaceContainerHighest;
    final Color iconColor = isSelected ? widget.colorScheme.onPrimaryContainer : widget.colorScheme.onSurfaceVariant;

    return Badge(
      isLabelVisible: hasNoCamera,
      backgroundColor: Colors.amber.shade600,
      label: const Text(
        '!',
        style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 10),
      ),
      largeSize: 16,
      alignment: Alignment.topRight,
      child: IconButton(
        onPressed: () {
          if (hasNoCamera) {
            setState(() {
              _dismissed = true;
            });
            _updateOverlayState();
          } else {
            widget.service.toggleCamera();
          }
        },
        tooltip: 'Camera',
        style: IconButton.styleFrom(
          backgroundColor: buttonColor,
          foregroundColor: iconColor,
          minimumSize: Size(widget.buttonSize, widget.buttonSize),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(160)),
        ),
        icon: Icon(widget.service.isCameraOff ? Icons.videocam_off : Icons.videocam, size: widget.iconSize),
      ),
    );
  }

  Widget _buildWarningPopup() {
    const popupColor = Color(0xFF2E3135);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 250,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: popupColor,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.3), blurRadius: 10, offset: const Offset(0, 4))],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Icon(Icons.error, color: Colors.amber.shade600, size: 20),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text(
                      "Camera not found",
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                    ),
                  ),
                  GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () {
                      setState(() {
                        _dismissed = true;
                      });
                      _updateOverlayState();
                    },
                    child: const Padding(
                      padding: EdgeInsets.all(4.0),
                      child: Icon(Icons.close, color: Colors.white70, size: 18),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              const Text("Make sure your camera is plugged in", style: TextStyle(color: Colors.white70, fontSize: 13)),
            ],
          ),
        ),
        CustomPaint(
          size: const Size(16, 8),
          painter: TrianglePainter(color: popupColor),
        ),
      ],
    );
  }
}

class TrianglePainter extends CustomPainter {
  final Color color;
  TrianglePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    final path = Path()
      ..moveTo(0, 0)
      ..lineTo(size.width, 0)
      ..lineTo(size.width / 2, size.height)
      ..close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
