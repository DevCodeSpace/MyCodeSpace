import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../widgets/pin_pad.dart';
import 'auth_controller.dart';

class AuthView extends GetView<AuthController> {
  const AuthView({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: SafeArea(
        child: Obx(
          () => Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Column(
              children: [
                const SizedBox(height: 48),
                // Glowing Icon Header (Adapts to lock/fingerprint)
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(
                      color: Theme.of(context).colorScheme.primary.withOpacity(0.2),
                      width: 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Theme.of(context).colorScheme.primary.withOpacity(0.05),
                        blurRadius: 16,
                        offset: const Offset(0, 8),
                      )
                    ],
                  ),
                  child: Icon(
                    controller.biometricPending.value ? Icons.fingerprint : Icons.lock_outline_rounded,
                    size: 40,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 28),
                // Title
                Text(
                  'Welcome Back',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.5,
                        color: isDark ? Colors.white : const Color(0xFF0F172A),
                      ),
                ),
                const SizedBox(height: 10),
                // Subtitle / Info State
                Text(
                  controller.biometricPending.value
                      ? 'Authenticating with biometric...'
                      : 'Enter your PIN to unlock',
                  style: TextStyle(
                    color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 40),
                // Pin Dots
                SizedBox(
                  height: 20, // fixed height to prevent structural shifts
                  child: _PinDots(length: controller.pin.value.length),
                ),
                if (controller.biometricFailed.value && controller.error.value.isEmpty) ...[
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.info_outline_rounded, size: 16, color: Theme.of(context).colorScheme.error),
                      const SizedBox(width: 6),
                      Text(
                        'Biometric failed — use your PIN',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.error,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ],
                if (controller.error.value.isNotEmpty) ...[
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.error.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      controller.error.value,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.error,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
                if (controller.isLoading.value) ...[
                  const SizedBox(height: 20),
                  SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).colorScheme.primary),
                    ),
                  )
                ],
                const Spacer(),
                // PinPad Keyboard
                PinPad(
                  onDigit: controller.addDigit,
                  onDelete: controller.deleteDigit,
                  onBiometric: controller.biometricAvailable ? controller.authenticateWithBiometric : null,
                ),
                const SizedBox(height: 28),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _PinDots extends StatelessWidget {
  final int length;
  const _PinDots({required this.length});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(6, (i) {
        final filled = i < length;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          margin: const EdgeInsets.symmetric(horizontal: 8),
          width: filled ? 16 : 12,
          height: filled ? 16 : 12,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: filled ? Theme.of(context).colorScheme.primary : Colors.transparent,
            border: Border.all(
              color: filled ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.outline.withOpacity(0.4),
              width: 2,
            ),
            boxShadow: filled
                ? [
                    BoxShadow(
                      color: Theme.of(context).colorScheme.primary.withOpacity(0.4),
                      blurRadius: 8,
                      spreadRadius: 1,
                    )
                  ]
                : [],
          ),
        );
      }),
    );
  }
}
