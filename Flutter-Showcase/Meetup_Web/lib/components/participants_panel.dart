import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/participant.dart';
import '../services/webrtc_service.dart';

class ParticipantsPanel extends StatelessWidget {
  final VoidCallback onClose;

  const ParticipantsPanel({super.key, required this.onClose});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Consumer<WebRTCService>(
      builder: (context, service, _) {
        final participants = <Participant>[];
        // Add local user
        participants.add(
          Participant(name: '${service.localUserName} (Me)', isMuted: service.isMuted, isCameraOff: service.isCameraOff, bgColor: const Color(0xFF005A9E), isRemote: false),
        );

        // Add remote user if connected
        if (service.hasRemoteStream) {
          participants.add(
            Participant(name: service.remoteUserName, isMuted: service.isRemoteMuted, isCameraOff: service.isRemoteCameraOff, bgColor: const Color(0xFFF15A24), isRemote: true),
          );
        }

        return Card(
          elevation: 12,
          margin: EdgeInsets.zero,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          clipBehavior: Clip.antiAlias,
          color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.95),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                color: colorScheme.surfaceContainer,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Participants (${participants.length})', style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                    CloseButton(onPressed: onClose),
                  ],
                ),
              ),
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: participants.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final p = participants[index];
                    return Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(color: colorScheme.surfaceContainerHigh, borderRadius: BorderRadius.circular(16)),
                      child: Row(
                        children: [
                          CircleAvatar(
                            backgroundColor: p.bgColor,
                            foregroundColor: Colors.white,
                            radius: 20,
                            child: Text(p.initial, style: const TextStyle(fontWeight: FontWeight.bold)),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              p.name,
                              style: textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Icon(p.isMuted ? Icons.mic_off : Icons.mic, size: 20, color: p.isMuted ? colorScheme.error : Colors.green),
                          const SizedBox(width: 8),
                          Icon(p.isCameraOff ? Icons.videocam_off : Icons.videocam, size: 20, color: p.isCameraOff ? colorScheme.error : Colors.green.shade600),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class ParticipantsAvatarButton extends StatelessWidget {
  final VoidCallback onTap;

  const ParticipantsAvatarButton({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Consumer<WebRTCService>(
      builder: (context, service, _) {
        final count = service.hasRemoteStream ? 2 : 1;

        return Center(
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(20),
            child: Container(
              height: 32,
              padding: const EdgeInsets.fromLTRB(6, 0, 12, 0),
              decoration: BoxDecoration(color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.5), borderRadius: BorderRadius.circular(20)),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (service.hasRemoteStream) ...[
                        Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: Theme.of(context).colorScheme.surfaceContainerHighest),
                          ),
                          child: CircleAvatar(
                            radius: 10,
                            backgroundColor: const Color(0xFFF15A24),
                            child: Text(
                              service.remoteUserName.isNotEmpty ? service.remoteUserName[0].toUpperCase() : 'P',
                              style: const TextStyle(fontSize: 10, color: Colors.white, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                        Align(
                          widthFactor: 0.5,
                          alignment: Alignment.centerRight,
                          child: Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: Theme.of(context).colorScheme.surfaceContainerHighest),
                            ),
                            child: CircleAvatar(
                              radius: 10,
                              backgroundColor: const Color(0xFF005A9E),
                              child: Text(
                                service.localUserName.isNotEmpty ? service.localUserName[0].toUpperCase() : 'Y',
                                style: const TextStyle(fontSize: 10, color: Colors.white, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                        ),
                      ] else
                        // Only Local User Avatar
                        Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: Theme.of(context).colorScheme.surfaceContainerHighest),
                          ),
                          child: CircleAvatar(
                            radius: 10,
                            backgroundColor: const Color(0xFF005A9E),
                            child: Text(
                              service.localUserName.isNotEmpty ? service.localUserName[0].toUpperCase() : 'Y',
                              style: const TextStyle(fontSize: 10, color: Colors.white, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '$count',
                    style: TextStyle(fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onInverseSurface),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
