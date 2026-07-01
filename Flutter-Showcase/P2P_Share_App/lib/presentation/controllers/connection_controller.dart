import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../app/routes/app_routes.dart';
import '../../app/theme/app_theme.dart';
import '../../domain/entities/device.dart';
import '../../domain/entities/pairing_request.dart';
import '../../domain/entities/share_manifest.dart';
import '../../domain/entities/transfer_request.dart';
import '../../domain/repositories/connection_repository.dart';
import 'transfer_controller.dart';

class ConnectionController extends GetxController {
  ConnectionController({
    required this.connectionRepository,
    required this.transferController,
  });

  final ConnectionRepository connectionRepository;
  final TransferController transferController;

  final RxBool isConnected = false.obs;
  final RxList<Device> discoveredDevices = <Device>[].obs;
  final Rxn<Device> connectedDevice = Rxn<Device>();
  final RxBool isScanning = false.obs;
  final RxString statusText = 'Looking for nearby devices.'.obs;

  StreamSubscription<PairingRequest>? _pairingSubscription;
  StreamSubscription<TransferRequest>? _transferSubscription;
  StreamSubscription<Device>? _disconnectSubscription;
  Timer? _discoveryTimer;

  @override
  void onInit() {
    super.onInit();
    _boot();
  }

  @override
  void onClose() {
    _discoveryTimer?.cancel();
    _pairingSubscription?.cancel();
    _transferSubscription?.cancel();
    _disconnectSubscription?.cancel();
    super.onClose();
  }

  Future<void> _boot() async {
    await connectionRepository.ensureRunning();
    _pairingSubscription = connectionRepository.watchPairingRequests().listen(
      _handlePairingRequest,
    );
    _transferSubscription = connectionRepository.watchTransferRequests().listen(
      _handleTransferRequest,
    );
    _disconnectSubscription = connectionRepository.watchDisconnections().listen(
      _handleRemoteDisconnect,
    );
  }

  Future<void> startContinuousDiscovery() async {
    await scanNow();
    _discoveryTimer?.cancel();
    _discoveryTimer = Timer.periodic(const Duration(seconds: 4), (_) {
      scanNow();
    });
  }

  void stopContinuousDiscovery() {
    _discoveryTimer?.cancel();
    _discoveryTimer = null;
  }

  Future<void> scanNow() async {
    if (isScanning.value) return;
    isScanning.value = true;
    statusText.value = 'Sweeping your local network for nearby devices.';
    try {
      final devices = await connectionRepository.discoverPeers();
      final visibleDevices = devices
          .where(
            (device) => device.ipAddress != connectedDevice.value?.ipAddress,
          )
          .toList();
      discoveredDevices.assignAll(visibleDevices);
      statusText.value = visibleDevices.isEmpty
          ? 'No devices surfaced yet. Keep this radar open.'
          : 'Tap a device to send a secure pairing request.';
    } finally {
      isScanning.value = false;
    }
  }

  Future<bool> sendPairingRequest(Device device) async {
    statusText.value = 'Sending pairing request to ${device.name}...';
    final remote = await connectionRepository.sendPairingRequest(device);
    if (remote == null) {
      statusText.value = '${device.name} declined the request.';
      return false;
    }

    connectedDevice.value = remote;
    isConnected.value = true;
    statusText.value = 'Connected to ${remote.name}.';
    Get.offAllNamed(AppRoutes.home);
    return true;
  }

  Future<bool> requestTransfer() async {
    final device = connectedDevice.value;
    if (device == null) return false;

    statusText.value = 'Waiting for ${device.name} to accept the transfer.';
    final accepted = await connectionRepository.sendTransferRequest(device);
    if (!accepted) {
      statusText.value = '${device.name} rejected the incoming transfer.';
      return false;
    }
    return true;
  }

  Future<void> confirmDisconnect() async {
    if (!isConnected.value) return;

    final confirmed = await Get.dialog<bool>(
      _DisconnectConfirmationDialog(
        deviceName: connectedDevice.value?.name ?? 'Device',
      ),
    );

    if (confirmed == true) {
      await disconnect();
    }
  }

  Future<void> disconnect() async {
    final device = connectedDevice.value;
    if (device != null) {
      await connectionRepository.disconnect(device);
    }
    isConnected.value = false;
    connectedDevice.value = null;
    statusText.value = 'Device disconnected.';
    if (Get.currentRoute != AppRoutes.home) {
      Get.offAllNamed(AppRoutes.home);
    }
  }

  void _handleRemoteDisconnect(Device device) {
    if (isConnected.value &&
        connectedDevice.value?.ipAddress == device.ipAddress) {
      isConnected.value = false;
      connectedDevice.value = null;
      statusText.value = '${device.name} disconnected.';

      Get.dialog<void>(
        _DisconnectionNotificationDialog(deviceName: device.name),
      );

      if (Get.currentRoute != AppRoutes.home) {
        Get.offAllNamed(AppRoutes.home);
      }
    }
  }

  Future<void> _handlePairingRequest(PairingRequest request) async {
    await Get.dialog<void>(
      _PairingRequestDialog(
        senderName: request.sender.name,
        onReject: () async {
          await connectionRepository.rejectPairingRequest(request.requestId);
          if (Get.isDialogOpen ?? false) Get.back<void>();
        },
        onAccept: () async {
          await connectionRepository.acceptPairingRequest(request.requestId);
          connectedDevice.value = request.sender.copyWith(isConnected: true);
          isConnected.value = true;
          if (Get.isDialogOpen ?? false) Get.back<void>();
          Get.offAllNamed(AppRoutes.home);
        },
      ),
      barrierDismissible: false,
    );
  }

  Future<void> _handleTransferRequest(TransferRequest request) async {
    final manifestFuture = connectionRepository.fetchManifest(
      request.sender.ipAddress,
    );

    await Get.dialog<void>(
      _TransferRequestDialog(
        senderName: request.sender.name,
        manifestFuture: manifestFuture,
        onReject: () async {
          await connectionRepository.rejectTransferRequest(request.requestId);
          if (Get.isDialogOpen ?? false) Get.back<void>();
        },
        onAccept: (manifest) async {
          unawaited(
            connectionRepository.acceptTransferRequest(request.requestId),
          );
          if (Get.isDialogOpen ?? false) Get.back<void>();
          Get.toNamed(AppRoutes.transfer);
          await transferController.startReceiving(
            ipAddress: request.sender.ipAddress,
            manifest: manifest,
          );
        },
      ),
      barrierDismissible: false,
    );
  }
}

class _PairingRequestDialog extends StatelessWidget {
  const _PairingRequestDialog({
    required this.senderName,
    required this.onAccept,
    required this.onReject,
  });

  final String senderName;
  final VoidCallback onAccept;
  final VoidCallback onReject;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(32),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.15),
              blurRadius: 30,
              offset: const Offset(0, 15),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppTheme.panelBlue,
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.link_rounded, color: AppTheme.gold, size: 40),
            ),
            const SizedBox(height: 24),
            const Text(
              'Pairing Request',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                style: const TextStyle(
                  color: AppTheme.textMuted,
                  fontSize: 16,
                  height: 1.5,
                  fontFamily: 'Prompt',
                ),
                children: [
                  const TextSpan(text: 'Device '),
                  TextSpan(
                    text: senderName,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      color: AppTheme.gold,
                    ),
                  ),
                  const TextSpan(
                    text: ' wants to establish a secure link with you.',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            Row(
              children: [
                Expanded(
                  child: _DialogSecondaryButton(
                    label: 'DECLINE',
                    onTap: onReject,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _DialogPrimaryButton(label: 'ACCEPT', onTap: onAccept),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: AppTheme.surfaceRaised,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.security_rounded,
                    color: AppTheme.goldSoft,
                    size: 16,
                  ),
                  const SizedBox(width: 10),
                  const Text(
                    'END-TO-END ENCRYPTED',
                    style: TextStyle(
                      color: AppTheme.textSoft,
                      letterSpacing: 1.5,
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TransferRequestDialog extends StatelessWidget {
  const _TransferRequestDialog({
    required this.senderName,
    required this.manifestFuture,
    required this.onAccept,
    required this.onReject,
  });

  final String senderName;
  final Future<ShareManifest> manifestFuture;
  final Function(ShareManifest) onAccept;
  final VoidCallback onReject;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(32),
        ),
        child: FutureBuilder<ShareManifest>(
          future: manifestFuture,
          builder: (context, snapshot) {
            final manifest = snapshot.data;
            final isLoading =
                snapshot.connectionState == ConnectionState.waiting;

            return Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppTheme.panelBlue,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Icon(
                        Icons.file_download_outlined,
                        color: AppTheme.gold,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'INCOMING TRANSFER',
                            style: TextStyle(
                              color: AppTheme.textSoft,
                              letterSpacing: 1.2,
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          Text(
                            senderName,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                              color: AppTheme.textPrimary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppTheme.surfaceRaised,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: isLoading
                      ? const Column(
                          children: [
                            SizedBox(height: 10),
                            SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation(
                                  AppTheme.gold,
                                ),
                              ),
                            ),
                            SizedBox(height: 16),
                            Text(
                              'Analyzing manifest...',
                              style: TextStyle(
                                fontSize: 14,
                                color: AppTheme.textMuted,
                              ),
                            ),
                            SizedBox(height: 10),
                          ],
                        )
                      : Column(
                          children: [
                            Row(
                              children: [
                                Text(
                                  '${manifest!.files.length} Files',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const Spacer(),
                                Text(
                                  _sizeLabel(manifest.totalBytes),
                                  style: const TextStyle(
                                    color: AppTheme.gold,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                            const Divider(height: 24),
                            ...manifest.files
                                .take(3)
                                .map(
                                  (file) => Padding(
                                    padding: const EdgeInsets.only(bottom: 8),
                                    child: Row(
                                      children: [
                                        const Icon(
                                          Icons.insert_drive_file_rounded,
                                          size: 16,
                                          color: AppTheme.textMuted,
                                        ),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Text(
                                            file.name,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: const TextStyle(
                                              fontSize: 14,
                                              color: AppTheme.textPrimary,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                            if (manifest.files.length > 3)
                              Padding(
                                padding: const EdgeInsets.only(top: 4),
                                child: Text(
                                  '+ ${manifest.files.length - 3} more items',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: AppTheme.textMuted,
                                    fontStyle: FontStyle.italic,
                                  ),
                                ),
                              ),
                          ],
                        ),
                ),
                const SizedBox(height: 28),
                Row(
                  children: [
                    Expanded(
                      child: _DialogSecondaryButton(
                        label: 'DECLINE',
                        onTap: onReject,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _DialogPrimaryButton(
                        label: 'ACCEPT',
                        onTap: isLoading ? () {} : () => onAccept(manifest!),
                      ),
                    ),
                  ],
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _DisconnectConfirmationDialog extends StatelessWidget {
  const _DisconnectConfirmationDialog({required this.deviceName});

  final String deviceName;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(32),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.warning_amber_rounded,
              color: Colors.orange,
              size: 64,
            ),
            const SizedBox(height: 20),
            const Text(
              'Disconnect Device?',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 12),
            Text(
              'Are you sure you want to terminate the secure link with $deviceName?',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppTheme.textMuted,
                fontSize: 15,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 32),
            Row(
              children: [
                Expanded(
                  child: _DialogSecondaryButton(
                    label: 'CANCEL',
                    onTap: () => Get.back(result: false),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _DialogPrimaryButton(
                    label: 'DISCONNECT',
                    onTap: () => Get.back(result: true),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _DisconnectionNotificationDialog extends StatelessWidget {
  const _DisconnectionNotificationDialog({required this.deviceName});

  final String deviceName;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(32),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.cloud_off_rounded,
              color: AppTheme.textMuted,
              size: 64,
            ),
            const SizedBox(height: 20),
            const Text(
              'Session Terminated',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 12),
            Text(
              '$deviceName has disconnected from the session.',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppTheme.textMuted,
                fontSize: 15,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 32),
            _DialogPrimaryButton(label: 'OKAY', onTap: () => Get.back()),
          ],
        ),
      ),
    );
  }
}

class _DialogPrimaryButton extends StatelessWidget {
  const _DialogPrimaryButton({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 18),
        decoration: BoxDecoration(
          color: AppTheme.gold,
          borderRadius: BorderRadius.circular(22),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

class _DialogSecondaryButton extends StatelessWidget {
  const _DialogSecondaryButton({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 18),
        decoration: BoxDecoration(
          color: AppTheme.panelBlue,
          borderRadius: BorderRadius.circular(22),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: AppTheme.textPrimary,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

String _sizeLabel(int bytes) {
  final gb = bytes / (1024 * 1024 * 1024);
  if (gb >= 1) return '${gb.toStringAsFixed(1)} GB Total';
  final mb = bytes / (1024 * 1024);
  return '${mb.toStringAsFixed(0)} MB Total';
}
