import 'package:flutter/material.dart';
import '../controllers/create_meeting_controller.dart';

class CreateMeetingDialog extends StatefulWidget {
  const CreateMeetingDialog({super.key});

  @override
  State<CreateMeetingDialog> createState() => _CreateMeetingDialogState();
}

class _CreateMeetingDialogState extends State<CreateMeetingDialog> {
  late final CreateMeetingController controller;

  @override
  void initState() {
    super.initState();
    controller = CreateMeetingController();
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
        return Dialog(
          insetPadding: EdgeInsets.symmetric(horizontal: 16),
          backgroundColor: Colors.transparent,
          constraints: const BoxConstraints(maxWidth: 760),
          clipBehavior: Clip.antiAlias,
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
      height: 300,
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
                            'Your room is ready.',
                            style: textTheme.headlineSmall?.copyWith(color: colorScheme.onSurface, fontWeight: FontWeight.bold, height: 1.2),
                          ),
                          const SizedBox(height: 16),
                          Text('Share this meeting configuration with your participants to begin.', style: textTheme.bodyMedium?.copyWith(color: colorScheme.onSurfaceVariant)),
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
                      Text('Room Specifications', style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                      const CloseButton(),
                    ],
                  ),
                  const SizedBox(height: 24),
                  _buildLabelText('Room ID', textTheme, colorScheme),
                  SelectableText(controller.roomId, style: textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildLabelText('Meeting URL', textTheme, colorScheme),
                          SelectableText(controller.meetingLink, style: textTheme.bodyMedium?.copyWith(color: colorScheme.onSurfaceVariant)),
                        ],
                      ),
                      IconButton(icon: const Icon(Icons.copy, size: 20), onPressed: () => controller.copyLink(context)),
                    ],
                  ),

                  const Spacer(),

                  // Action Layout
                  FilledButton.icon(
                    icon: const Icon(Icons.play_arrow, size: 20),
                    label: const Text('Start Call'),
                    onPressed: () => controller.startCall(context),
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
              Text('Your room is ready', style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
              const CloseButton(),
            ],
          ),

          // Containerized data points to look distinct on tiny panels
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildLabelText('Room ID', textTheme, colorScheme),
              SelectableText(controller.roomId, style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildLabelText('Meeting URL', textTheme, colorScheme),
                        SelectableText(controller.meetingLink, style: textTheme.bodyMedium?.copyWith(color: colorScheme.onSurfaceVariant)),
                      ],
                    ),
                  ),
                  IconButton(icon: const Icon(Icons.copy, size: 16), onPressed: () => controller.copyLink(context)),
                ],
              ),
              // _buildLabelText('Meeting URL', textTheme, colorScheme),
              // SelectableText(controller.meetingLink, style: textTheme.bodyMedium?.copyWith(color: colorScheme.onSurfaceVariant)),
            ],
          ),

          const SizedBox(height: 12),
          FilledButton.icon(
            icon: const Icon(Icons.play_arrow, size: 18),
            label: const Text('Start Call'),
            onPressed: () => controller.startCall(context),
            style: FilledButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14)),
          ),
        ],
      ),
    );
  }

  Widget _buildLabelText(String label, TextTheme textTheme, ColorScheme colorScheme) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Text(
        label,
        style: textTheme.labelSmall?.copyWith(color: colorScheme.primary, fontWeight: FontWeight.bold, letterSpacing: 0.5),
      ),
    );
  }
}
