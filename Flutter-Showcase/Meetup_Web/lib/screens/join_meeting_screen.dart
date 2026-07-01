import 'package:flutter/material.dart';

import '../controllers/join_meeting_controller.dart';

class JoinMeetingDialog extends StatefulWidget {
  final String? initialRoomId;

  const JoinMeetingDialog({super.key, this.initialRoomId});

  @override
  State<JoinMeetingDialog> createState() => _JoinMeetingDialogState();
}

class _JoinMeetingDialogState extends State<JoinMeetingDialog> {
  final _roomController = TextEditingController();
  late final JoinMeetingController controller;

  @override
  void initState() {
    super.initState();
    controller = JoinMeetingController();
    if (widget.initialRoomId != null) {
      _roomController.text = widget.initialRoomId!;
    }
  }

  @override
  void dispose() {
    controller.dispose();
    _roomController.dispose();
    super.dispose();
  }

  Future<void> _join() async {
    FocusScope.of(context).unfocus();
    await controller.join(context, _roomController.text);
  }

  void _handleRoomIdChanged(String value) {
    String parsed = controller.sanitize(value);

    if (parsed != value) {
      int newOffset = _roomController.selection.baseOffset;
      if (newOffset > parsed.length) {
        newOffset = parsed.length;
      }
      _roomController.value = _roomController.value.copyWith(
        text: parsed,
        selection: TextSelection.collapsed(offset: newOffset < 0 ? parsed.length : newOffset),
      );
    }
    controller.clearValidation();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        return Dialog(
          insetPadding: EdgeInsets.symmetric(horizontal: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
          backgroundColor: Colors.transparent,
          clipBehavior: Clip.antiAlias,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 760),
            child: LayoutBuilder(
              builder: (context, constraints) {
                return AnimatedSize(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                  alignment: Alignment.center,
                  child: constraints.maxWidth > 720
                      ? KeyedSubtree(key: const ValueKey('desktop'), child: buildDesktopView(context))
                      : KeyedSubtree(key: const ValueKey('mobile'), child: buildMobileView(context)),
                );
              },
            ),
          ),
        );
      },
    );
  }

  // =========================================================================
  // DESKTOP DIALOG VIEW
  // =========================================================================
  Widget buildDesktopView(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return SizedBox(
      height: 270,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Graphic Info Banner Pane (Left Side)
          Expanded(
            flex: 4,
            child: Container(
              color: colorScheme.surfaceContainerHighest,
              child: Stack(
                children: [
                  Padding(padding: const EdgeInsets.fromLTRB(8, 8, 0, 0), child: Image.asset('assets/image/appbar_logo.png', width: 70)),
                  Positioned.fill(
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Spacer(flex: 1),
                          Text(
                            'Enter meeting room.',
                            style: textTheme.headlineSmall?.copyWith(color: colorScheme.onSurface, fontWeight: FontWeight.bold, height: 1.2),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Paste the room ID shared by your host and join the 1-to-1 video call instantly.',
                            style: textTheme.bodyMedium?.copyWith(color: colorScheme.onSurfaceVariant),
                          ),
                          // Spacer(flex: 2),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Form Detail & Action Pane (Right Side)
          Expanded(
            flex: 5,
            child: Container(
              padding: const EdgeInsets.all(32),
              color: colorScheme.surfaceContainer,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Join via ID', style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                      const CloseButton(),
                    ],
                  ),
                  const SizedBox(height: 32),

                  _buildLabelText('Room ID', textTheme, colorScheme),
                  TextField(
                    controller: _roomController,
                    textCapitalization: TextCapitalization.characters,
                    onChanged: _handleRoomIdChanged,
                    style: textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w500),
                    decoration: InputDecoration(
                      hintText: 'AB12CD34',
                      errorText: controller.validationMessage,
                      prefixIcon: const Icon(Icons.vpn_key_outlined, size: 20),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
                    ),
                  ),

                  // const Spacer(),
                  const SizedBox(height: 24),

                  // Action Layout
                  FilledButton.icon(
                    icon: controller.isCheckingRoom ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)) : const Icon(Icons.login, size: 20),
                    label: Text(controller.isCheckingRoom ? 'Checking...' : 'Join Call'),
                    onPressed: controller.isCheckingRoom ? null : _join,
                    style: FilledButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // =========================================================================
  // MOBILE DIALOG VIEW
  // =========================================================================
  Widget buildMobileView(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Container(
      color: colorScheme.surfaceContainer,
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Enter meeting room', style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
              const CloseButton(),
            ],
          ),

          Text('Paste the room ID shared by your host and join the video call instantly.', style: textTheme.bodyMedium?.copyWith(color: colorScheme.onSurfaceVariant)),
          SizedBox(height: 12),

          _buildLabelText('Room ID', textTheme, colorScheme),
          TextField(
            controller: _roomController,
            textCapitalization: TextCapitalization.characters,
            onChanged: _handleRoomIdChanged,
            style: textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w500),
            decoration: InputDecoration(
              hintText: 'AB12CD34',
              errorText: controller.validationMessage,
              prefixIcon: const Icon(Icons.vpn_key_outlined, size: 20),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
            ),
          ),
          SizedBox(height: 12),

          FilledButton.icon(
            icon: controller.isCheckingRoom ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2)) : const Icon(Icons.login),
            label: Text(controller.isCheckingRoom ? 'Checking...' : 'Join Call'),
            onPressed: controller.isCheckingRoom ? null : _join,
            style: FilledButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14)),
          ),
        ],
      ),
    );
  }

  Widget _buildLabelText(String label, TextTheme textTheme, ColorScheme colorScheme) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        label,
        style: textTheme.labelSmall?.copyWith(color: colorScheme.primary, fontWeight: FontWeight.bold, letterSpacing: 0.5),
      ),
    );
  }
}
