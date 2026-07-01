import 'dart:io';
import 'dart:ui' as ui;
import 'package:animated_emoji/animated_emoji.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pretty_qr_code/pretty_qr_code.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:web_rtc/components/call_controls_bar.dart';
import 'package:web_rtc/components/floating_emoji.dart';
import 'package:web_rtc/components/participants_panel.dart';
import '../controllers/call_controller.dart';

import '../services/webrtc_service.dart';
import '../utils/meeting_link.dart';
import 'chat_screen.dart';

class CallScreen extends StatefulWidget {
  final String roomId;
  final bool createRoom;

  const CallScreen({super.key, required this.roomId, required this.createRoom});

  @override
  State<CallScreen> createState() => _CallScreenState();
}

class _CallScreenState extends State<CallScreen> {
  late final CallController controller;
  final GlobalKey _qrKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    controller = CallController(roomId: widget.roomId, createRoom: widget.createRoom);

    controller.onNewMessageCallback = (msg) {
      if (ModalRoute.of(context)?.isCurrent == true && mounted) {
        final width = MediaQuery.of(context).size.width;
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.chat_bubble_outline, color: Theme.of(context).colorScheme.onInverseSurface, size: 20),
                const SizedBox(width: 12),
                Expanded(child: Text(msg.text, maxLines: 2, overflow: TextOverflow.ellipsis)),
              ],
            ),
            behavior: SnackBarBehavior.floating,
            margin: EdgeInsets.only(bottom: 100, left: width > 720 ? width / 2 - 200 : 16, right: width > 720 ? width / 2 - 200 : 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            duration: const Duration(seconds: 4),
            action: SnackBarAction(
              label: 'OPEN',
              onPressed: () {
                controller.webRTCService?.markChatAsRead();
                if (width > 720) {
                  controller.toggleChat(); // This needs to exist, wait, I can just use controller.isChatOpen = true; let's use the toggle or setter.
                  // I'll call controller.toggleChat() but since toggle flips it, if it's false, it becomes true. But wait! The old code explicitly sets it to true. Let's just call toggleChat if it's closed.
                  if (!controller.isChatOpen) controller.toggleChat();
                } else {
                  Navigator.of(context).push(MaterialPageRoute(builder: (_) => const ChatScreen()));
                }
              },
            ),
          ),
        );
      }
    };

    controller.onPeerLeftCallback = () {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('${controller.webRTCService?.remoteUserName ?? 'Peer'} has left the call'), behavior: SnackBarBehavior.floating));
      }
    };

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      controller.attach(context);
    });
  }

  Future<void> _shareQrCodeImage() async {
    try {
      final boundary = _qrKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
      if (boundary == null) return;

      final image = await boundary.toImage(pixelRatio: 6.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      if (byteData != null) {
        final pngBytes = byteData.buffer.asUint8List();
        final tempDir = await getTemporaryDirectory();
        final filePath = '${tempDir.path}/meeting_qr_${widget.roomId}.png';
        final file = File(filePath);
        await file.writeAsBytes(pngBytes);

        await SharePlus.instance.share(
          ShareParams(
            text: 'Join my CodeX Meet meeting!\n\nMeeting ID: ${widget.roomId}\nMeeting Link: ${buildCallMeetingLink(widget.roomId)}',
            subject: 'Join CodeX Meet',
            files: [XFile(filePath)],
          ),
        );
      }
    } catch (e) {
      debugPrint('Error sharing QR code: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error sharing QR Code: $e')));
      }
    }
  }



  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        final theme = Theme.of(context);
        final colorScheme = theme.colorScheme;
        final textTheme = theme.textTheme;
        final isMobile = MediaQuery.of(context).size.width < 720;

        return Scaffold(
      backgroundColor: colorScheme.scrim,
      appBar: AppBar(
        leadingWidth: isMobile ? 140 : 240,
        leading: Row(
          children: [
            const SizedBox(width: 16),
            if (!isMobile) ...[
              StreamBuilder(
                stream: Stream.periodic(const Duration(seconds: 1)),
                builder: (context, snapshot) {
                  return Text(TimeOfDay.now().format(context), style: textTheme.bodyLarge?.copyWith(color: colorScheme.onInverseSurface));
                },
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Text('|', style: textTheme.bodyLarge?.copyWith(color: colorScheme.onInverseSurface)),
              ),
            ],
            Expanded(
              child: SelectableText(widget.roomId, style: textTheme.bodyLarge?.copyWith(color: colorScheme.onInverseSurface), maxLines: 1),
            ),
          ],
        ),
        title: Consumer<WebRTCService>(
          builder: (context, service, _) {
            if (service.hasRemoteStream) {
              return Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(color: colorScheme.error, shape: BoxShape.circle),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    service.callDurationString,
                    style: textTheme.bodySmall?.copyWith(color: colorScheme.onInverseSurface, fontWeight: FontWeight.bold),
                  ),
                ],
              );
            } else {
              return Text(
                service.statusMessage,
                style: textTheme.bodyMedium?.copyWith(color: colorScheme.onInverseSurface.withValues(alpha: 0.8), fontWeight: FontWeight.w500),
              );
            }
          },
        ),
        iconTheme: IconThemeData(color: colorScheme.onInverseSurface),
        centerTitle: true,
        backgroundColor: colorScheme.scrim,
        elevation: 0,
        foregroundColor: colorScheme.onInverseSurface,
        actions: [
          ParticipantsAvatarButton(
            onTap: controller.toggleParticipants,
          ),
          const SizedBox(width: 12),
        ],
      ),
      body: Consumer<WebRTCService>(
        builder: (context, service, _) {
          return LayoutBuilder(
            builder: (context, constraints) {
              final isWeb = constraints.maxWidth > 720;
              return isWeb ? buildDesktopView(context, service) : buildMobileView(context, service);
            },
          );
        },
      ),
        );
      },
    );
  }

  Widget buildDesktopView(BuildContext context, WebRTCService service) {
    if (controller.isLeaving) {
      return const Center(child: CircularProgressIndicator());
    }

    return Stack(
      children: [
        Positioned(left: 0, right: 0, top: 0, bottom: 0, child: _buildRemoteStream(context, service)),

        // show popup to copy and share the meeting link
        Positioned(
          left: 24,
          top: 24,
          width: 360,
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            transitionBuilder: (child, animation) {
              return FadeTransition(
                opacity: animation,
                child: ScaleTransition(
                  scale: Tween<double>(begin: 0.9, end: 1.0).animate(CurvedAnimation(parent: animation, curve: Curves.easeOutBack)),
                  child: child,
                ),
              );
            },
            child: (!service.hasRemoteStream && service.isHost) ? _buildShareMeetingLinkPopup(context, service) : const SizedBox.shrink(),
          ),
        ),

        // PIP Desktop
        if (service.hasRemoteStream) Positioned(left: 24, bottom: 24, width: 180, height: 260, child: _buildLocalPIP(context, service)),

        // Participants Desktop
        if (controller.isParticipantsOpen)
          Positioned(
            top: MediaQuery.of(context).padding.top + 16,
            bottom: 120,
            right: 16,
            width: 360,
            child: ParticipantsPanel(onClose: controller.closeParticipants),
          ),

        // Chat Desktop
        if (controller.isChatOpen)
          Positioned(
            top: MediaQuery.of(context).padding.top + 16,
            bottom: 120,
            right: 16,
            width: 360,
            child: Card(
              elevation: 12,
              margin: EdgeInsets.zero,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
              clipBehavior: Clip.antiAlias,
              child: ChatScreen(onClose: controller.closeChat),
            ),
          ),

        // Overlay emoji picker bar
        Positioned(
          bottom: 95,
          left: 0,
          right: 0,
          child: IgnorePointer(
            ignoring: !controller.isEmojiMenuOpen,
            child: AnimatedOpacity(
              opacity: controller.isEmojiMenuOpen ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              child: AnimatedSlide(
                offset: controller.isEmojiMenuOpen ? const Offset(0, 0) : const Offset(0, 1),
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                child: Center(child: _buildEmojiPickerBar(isMobile: false)),
              ),
            ),
          ),
        ),

        // Bottom Controls Desktop
        Positioned(
          bottom: 12,
          left: 24,
          right: 24,
          child: Center(
            child: CallControlsBar(
              service: service,
              isMobile: false,
              isEmojiMenuOpen: controller.isEmojiMenuOpen,
              onToggleEmojiMenu: controller.toggleEmojiMenu,
              onToggleChat: controller.toggleChat,
              onLeaveRoom: () => controller.leaveRoom(context),
            ),
          ),
        ),

        // Put this as the LAST item inside your view Stacks
        Positioned(
          bottom: 100,
          left: 0,
          right: 0,
          child: Center(
            child: SizedBox(
              height: 500,
              width: 200,
              child: Stack(
                alignment: Alignment.bottomCenter,
                children: controller.activeEmojis.map((ae) {
                  return FloatingEmoji(
                    key: ValueKey(ae.id),
                    emoji: ae.emoji,
                    senderName: ae.senderName == controller.authService?.user?.displayName ? "Me" : ae.senderName,
                    onAnimationComplete: () {
                      controller.removeEmoji(ae.id);
                    },
                    isMobile: false,
                  );
                }).toList(),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget buildMobileView(BuildContext context, WebRTCService service) {
    final colorScheme = Theme.of(context).colorScheme;

    if (controller.isLeaving) {
      return const Center(child: CircularProgressIndicator());
    }

    return Stack(
      children: [
        _buildRemoteStream(context, service),

        if (service.hasRemoteStream) Positioned(left: 16, top: 4, width: 100, height: 150, child: _buildLocalPIP(context, service)),

        // show popup to copy and share the meeting link
        Positioned(
          left: 16,
          top: 0,
          right: 16,
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            transitionBuilder: (child, animation) {
              return FadeTransition(
                opacity: animation,
                child: ScaleTransition(
                  scale: Tween<double>(begin: 0.9, end: 1.0).animate(CurvedAnimation(parent: animation, curve: Curves.easeOutBack)),
                  child: child,
                ),
              );
            },
            child: (!service.hasRemoteStream && service.isHost) ? _buildShareMeetingLinkPopup(context, service) : const SizedBox.shrink(),
          ),
        ),

        // Overlay emoji picker bar
        Positioned(
          bottom: 90,
          left: 0,
          right: 0,
          child: IgnorePointer(
            ignoring: !controller.isEmojiMenuOpen,
            child: AnimatedOpacity(
              opacity: controller.isEmojiMenuOpen ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeInOut,
              child: AnimatedSlide(
                offset: controller.isEmojiMenuOpen ? const Offset(0, 0) : const Offset(0, 0.4),
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOutCubic,
                child: Center(child: _buildEmojiPickerBar(isMobile: true)),
              ),
            ),
          ),
        ),
        // Bottom Controls Mobile
        Positioned(
          bottom: 16,
          left: 0,
          right: 0,
          child: Center(
            child: CallControlsBar(
              service: service,
              isMobile: true,
              isEmojiMenuOpen: controller.isEmojiMenuOpen,
              onToggleEmojiMenu: controller.toggleEmojiMenu,
              onToggleChat: () {
                service.markChatAsRead();
                Navigator.of(context).push(MaterialPageRoute(builder: (_) => const ChatScreen()));
              },
              onLeaveRoom: () => controller.leaveRoom(context),
            ),
          ),
        ),

        // Put this as the LAST item inside your view Stacks
        Positioned(
          bottom: 90,
          left: 0,
          right: 0,
          child: Center(
            child: SizedBox(
              height: 500,
              width: 200,
              child: Stack(
                alignment: Alignment.bottomCenter,
                children: controller.activeEmojis.map((ae) {
                  return FloatingEmoji(
                    key: ValueKey(ae.id),
                    emoji: ae.emoji,
                    senderName: ae.senderName == controller.authService?.user?.displayName ? "Me" : ae.senderName,
                    onAnimationComplete: () {
                      controller.removeEmoji(ae.id);
                    },
                    isMobile: true,
                  );
                }).toList(),
              ),
            ),
          ),
        ),

        // Participants Mobile
        if (controller.isParticipantsOpen)
          Positioned.fill(
            child: Container(
              color: colorScheme.scrim.withValues(alpha: 0.5),
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
              child: ParticipantsPanel(onClose: controller.closeParticipants),
            ),
          ),
      ],
    );
  }

  Widget _buildRemoteStream(BuildContext context, WebRTCService service) {
    final bool isRemote = service.hasRemoteStream;
    final String displayName = isRemote ? service.remoteUserName : service.localUserName;
    final String initial = displayName.isNotEmpty ? displayName[0].toUpperCase() : 'A';
    final bool isCamOff = isRemote ? service.isRemoteCameraOff : service.isCameraOff;
    final Color bgColor = isRemote ? const Color(0xFF7A2E1A) : const Color(0xFF0F4C75);
    final Color avatarColor = isRemote ? const Color(0xFFF15A24) : const Color(0xFF005A9E);

    final isMobile = MediaQuery.of(context).size.width < 720;
    final double bottomPadding = isMobile ? (controller.isEmojiMenuOpen ? 145 : 90) : (controller.isEmojiMenuOpen ? 150 : 100);

    final renderer = isRemote ? service.remoteRenderer : service.localRenderer;
    final bool isVerticalVideo = renderer.videoWidth > 0 && renderer.videoHeight > 0 && renderer.videoHeight > renderer.videoWidth;

    final double? videoAspectRatio = (renderer.videoWidth > 0 && renderer.videoHeight > 0) ? renderer.videoWidth / renderer.videoHeight : null;

    Widget videoBox = Container(
      constraints: const BoxConstraints(maxWidth: 1300),
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(24), color: bgColor),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          if (!isCamOff)
            Positioned.fill(
              child: RTCVideoView(
                renderer,
                key: ValueKey(isRemote ? 'remote_video' : 'local_video'),
                mirror: !isRemote && service.isFrontCamera && !service.isScreenSharing,
                objectFit: isMobile
                    ? (isVerticalVideo ? RTCVideoViewObjectFit.RTCVideoViewObjectFitContain : RTCVideoViewObjectFit.RTCVideoViewObjectFitCover)
                    : RTCVideoViewObjectFit.RTCVideoViewObjectFitCover,
              ),
            ),
          if (isCamOff)
            Positioned.fill(
              child: Center(
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white.withValues(alpha: 0.8), width: 1.5),
                    color: avatarColor,
                  ),
                  width: 100,
                  height: 100,
                  alignment: Alignment.center,
                  child: Text(
                    initial,
                    style: const TextStyle(fontSize: 48, color: Colors.white, fontWeight: FontWeight.w400),
                  ),
                ),
              ),
            ),
          Positioned(
            bottom: 16,
            left: 20,
            child: Text(
              displayName,
              style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w500),
            ),
          ),
          if (!isRemote && service.isScreenSharing)
            Positioned(
              left: 20,
              top: 20,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(color: Theme.of(context).colorScheme.error.withValues(alpha: 0.92), borderRadius: BorderRadius.circular(999)),
                child: Text(
                  'Sharing',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(color: Theme.of(context).colorScheme.onError, fontWeight: FontWeight.w700),
                ),
              ),
            ),
          if (!isCamOff && service.isMobile && !isRemote)
            Positioned(
              bottom: 0,
              right: 0,
              child: IconButton(
                onPressed: service.switchCamera,
                icon: Icon(Icons.cameraswitch, color: Colors.white, size: 20),
              ),
            ),
        ],
      ),
    );

    if (isMobile) {
      return Center(
        child: AnimatedContainer(duration: const Duration(milliseconds: 300), curve: Curves.easeOut, padding: EdgeInsets.fromLTRB(16, 0, 16, bottomPadding), child: videoBox),
      );
    }

    // On Web, wrap it in AspectRatio so that the container adapts to the width of the incoming stream
    final double aspect = (videoAspectRatio != null && videoAspectRatio > 0) ? videoAspectRatio : 16 / 9;

    videoBox = AspectRatio(aspectRatio: aspect, child: videoBox);

    videoBox = ConstrainedBox(constraints: const BoxConstraints(maxWidth: 1300), child: videoBox);

    return Center(
      child: AnimatedContainer(duration: const Duration(milliseconds: 300), curve: Curves.easeOut, padding: EdgeInsets.fromLTRB(16, 0, 16, bottomPadding), child: videoBox),
    );
  }

  Widget _buildShareMeetingLinkPopup(BuildContext context, WebRTCService service) {
    final colorScheme = Theme.of(context).colorScheme;
    return Card(
      clipBehavior: Clip.antiAlias,
      color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.9),
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              children: [
                Text(
                  "You're the only one here",
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, color: colorScheme.onSurfaceVariant),
                ),
                Text(
                  "Share this meeting link/ID with others to join.",
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant.withValues(alpha: 0.8)),
                ),
              ],
            ),
          ),

          Container(
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainer,
              border: Border.all(color: colorScheme.outlineVariant),
            ),
            padding: const EdgeInsets.fromLTRB(12, 8, 0, 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          RichText(
                            text: TextSpan(
                              children: [
                                TextSpan(
                                  text: "Meeting ID: ",
                                  style: GoogleFonts.googleSansFlex(fontSize: 16, fontWeight: FontWeight.w600, color: colorScheme.onSurfaceVariant),
                                ),
                                TextSpan(
                                  text: widget.roomId,
                                  style: GoogleFonts.googleSansCode(fontSize: 16, fontWeight: FontWeight.w600, color: colorScheme.onSurfaceVariant),
                                ),
                              ],
                            ),
                          ),
                          Text(buildCallMeetingLink(widget.roomId), style: Theme.of(context).textTheme.bodySmall, overflow: TextOverflow.ellipsis),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.copy, color: colorScheme.primary, size: 20),
                      onPressed: () async {
                        await Clipboard.setData(ClipboardData(text: buildCallMeetingLink(widget.roomId)));
                        if (!context.mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: const Text('Meeting URL copied to clipboard'), behavior: SnackBarBehavior.floating));
                      },
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.only(right: 12, top: 4),
                  child: Row(
                    spacing: 8,
                    children: [
                      Expanded(
                        child: FilledButton.tonalIcon(
                          icon: const Icon(Icons.share, size: 16),
                          label: Text("Share Meeting Link", style: GoogleFonts.googleSansFlex(fontSize: 12)),
                          onPressed: () async {
                            final String link = buildCallMeetingLink(widget.roomId);
                            final String invitationText =
                                'Join my CodeX Meet meeting!\n\n'
                                'Meeting ID: ${widget.roomId}\n'
                                'Meeting Link: $link\n\n'
                                'Tap the link to join directly.';
                            await SharePlus.instance.share(ShareParams(text: invitationText, subject: 'Join CodeX Meet'));
                          },
                        ),
                      ),
                      FilledButton.icon(
                        icon: Icon(Icons.qr_code, size: 16),
                        label: Text("QR Code", style: GoogleFonts.googleSansFlex(fontSize: 12)),
                        style: FilledButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 12)),
                        onPressed: controller.toggleQrCode,
                      ),
                    ],
                  ),
                ),
                AnimatedCrossFade(
                  duration: const Duration(milliseconds: 300),
                  firstChild: const SizedBox.shrink(),
                  secondChild: Column(
                    children: [
                      const SizedBox(height: 12),
                      Center(
                        child: RepaintBoundary(
                          key: _qrKey,
                          child: Container(
                            width: 180,
                            height: 180,
                            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
                            padding: const EdgeInsets.all(12),
                            child: PrettyQrView.data(
                              data: buildCallMeetingLink(widget.roomId),
                              decoration: const PrettyQrDecoration(
                                shape: PrettyQrSmoothSymbol(color: Colors.black),
                                image: PrettyQrDecorationImage(image: AssetImage('assets/image/logo.png'), position: PrettyQrDecorationImagePosition.embedded, scale: 0.25),
                              ),
                            ),
                          ),
                        ),
                      ),
                      Center(
                        child: TextButton.icon(
                          icon: const Icon(Icons.share, size: 16),
                          label: Text("Share QR Code", style: GoogleFonts.googleSansFlex(fontSize: 12)),
                          onPressed: _shareQrCodeImage,
                        ),
                      ),
                    ],
                  ),
                  crossFadeState: controller.showQrCode ? CrossFadeState.showSecond : CrossFadeState.showFirst,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLocalPIP(BuildContext context, WebRTCService service) {
    final colorScheme = Theme.of(context).colorScheme;
    final String initial = service.localUserName.isNotEmpty ? service.localUserName[0].toUpperCase() : 'A';
    final Color bgColor = const Color(0xFF0F4C75);
    final Color avatarColor = const Color(0xFF005A9E);

    return Card(
      // elevation: 8,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      clipBehavior: Clip.antiAlias,
      color: bgColor,
      child: Stack(
        children: [
          if (!service.isCameraOff)
            Positioned.fill(
              child: RTCVideoView(service.localRenderer, mirror: service.isFrontCamera && !service.isScreenSharing, objectFit: RTCVideoViewObjectFit.RTCVideoViewObjectFitCover),
            )
          else
            Positioned.fill(
              child: Center(
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white.withValues(alpha: 0.8), width: 1.0),
                    color: avatarColor,
                  ),
                  width: 50,
                  height: 50,
                  alignment: Alignment.center,
                  child: Text(
                    initial,
                    style: const TextStyle(fontSize: 24, color: Colors.white, fontWeight: FontWeight.w400),
                  ),
                ),
              ),
            ),
          if (service.isScreenSharing)
            Positioned(
              left: 10,
              top: 10,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(color: colorScheme.error.withValues(alpha: 0.92), borderRadius: BorderRadius.circular(999)),
                child: Text(
                  'Sharing',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(color: colorScheme.onError, fontWeight: FontWeight.w700),
                ),
              ),
            ),
          // if (service.isCameraOff)
          //   Positioned.fill(
          //     child: Center(
          //       child: Container(
          //         decoration: BoxDecoration(
          //           shape: BoxShape.circle,
          //           border: Border.all(color: Colors.white.withValues(alpha: 0.8), width: 1.0),
          //           color: avatarColor,
          //         ),
          //         width: 50,
          //         height: 50,
          //         alignment: Alignment.center,
          //         child: Text(
          //           initial,
          //           style: const TextStyle(fontSize: 24, color: Colors.white, fontWeight: FontWeight.w400),
          //         ),
          //       ),
          //     ),
          //   ),
          Positioned(
            bottom: 8,
            left: 12,
            child: Text(
              "Me",
              style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w500),
            ),
          ),

          if (!service.isCameraOff && service.isMobile)
            Positioned(
              bottom: 0,
              right: 0,
              child: IconButton(
                onPressed: service.switchCamera,
                icon: Icon(Icons.cameraswitch, color: Colors.white, size: 20),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildEmojiPickerBar({required bool isMobile}) {
    final colorScheme = Theme.of(context).colorScheme;
    final size = isMobile ? 24 : 28;

    // Map the network string key to the matching AnimatedEmoji target
    final popularEmojis = [
      {'id': 'clap', 'data': AnimatedEmojis.clap},
      {'id': 'heart', 'data': AnimatedEmojis.redHeart},
      {'id': 'thumbsUp', 'data': AnimatedEmojis.thumbsUp},
      {'id': 'party', 'data': AnimatedEmojis.partyPopper},
      {'id': 'laugh', 'data': AnimatedEmojis.laughing},
      {'id': 'astonished', 'data': AnimatedEmojis.astonished},
      {'id': 'thinking', 'data': AnimatedEmojis.thinkingFace},
    ];

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.scrim,
        border: Border.all(color: colorScheme.inverseSurface),
        borderRadius: BorderRadius.circular(200),
      ),
      padding: EdgeInsets.symmetric(horizontal: isMobile ? 8 : 12, vertical: 4),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        spacing: 4,
        children: popularEmojis.map((emojiItem) {
          final String id = emojiItem['id'] as String;
          final AnimatedEmojiData emojiData = emojiItem['data'] as AnimatedEmojiData;
          return InkWell(
            borderRadius: BorderRadius.circular(100),
            onTap: () {
              controller.sendReaction(id);
              if (isMobile) {
                controller.toggleEmojiMenu();
              }
            },
            child: Padding(
              padding: const EdgeInsets.all(6.0),
              child: SizedBox(width: size.toDouble(), height: size.toDouble(), child: AnimatedEmoji(emojiData, animate: true)),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class ActiveEmoji {
  final String id;
  final String emoji;
  final String senderName;

  ActiveEmoji(this.id, this.emoji, this.senderName);
}
