import 'package:flutter/material.dart';

class PinPad extends StatelessWidget {
  final void Function(String) onDigit;
  final VoidCallback onDelete;
  final VoidCallback? onBack;
  final VoidCallback? onBiometric;

  const PinPad({
    super.key,
    required this.onDigit,
    required this.onDelete,
    this.onBack,
    this.onBiometric,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildRow(context, ['1', '2', '3']),
        const SizedBox(height: 18),
        _buildRow(context, ['4', '5', '6']),
        const SizedBox(height: 18),
        _buildRow(context, ['7', '8', '9']),
        const SizedBox(height: 18),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Bottom-left: biometric or back
            SizedBox(
              width: 76,
              height: 76,
              child: onBiometric != null
                  ? _IconKey(
                      icon: Icons.fingerprint,
                      onTap: onBiometric!,
                    )
                  : onBack != null
                      ? _IconKey(
                          icon: Icons.arrow_back_rounded,
                          onTap: onBack!,
                        )
                      : const SizedBox.shrink(),
            ),
            const SizedBox(width: 18),
            _DigitKey(digit: '0', onTap: onDigit),
            const SizedBox(width: 18),
            SizedBox(
              width: 76,
              height: 76,
              child: _IconKey(
                icon: Icons.backspace_outlined,
                onTap: onDelete,
                color: Colors.transparent,
                iconColor: Theme.of(context).colorScheme.error.withOpacity(0.8),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildRow(BuildContext context, List<String> digits) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: digits.map((d) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 9),
          child: _DigitKey(digit: d, onTap: onDigit),
        );
      }).toList(),
    );
  }
}

class _DigitKey extends StatelessWidget {
  final String digit;
  final void Function(String) onTap;

  const _DigitKey({required this.digit, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Material(
      color: Theme.of(context).cardColor,
      shape: CircleBorder(
        side: BorderSide(
          color: isDark ? const Color(0xFF1F293D) : const Color(0xFFE2E8F0),
          width: 1,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => onTap(digit),
        splashColor: Theme.of(context).colorScheme.primary.withOpacity(0.12),
        highlightColor: Theme.of(context).colorScheme.primary.withOpacity(0.06),
        child: SizedBox(
          width: 76,
          height: 76,
          child: Center(
            child: Text(
              digit,
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.white : const Color(0xFF0F172A),
                letterSpacing: -0.5,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _IconKey extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final Color? color;
  final Color? iconColor;

  const _IconKey({
    required this.icon,
    required this.onTap,
    this.color,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color ?? Colors.transparent,
      shape: const CircleBorder(),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        splashColor: Theme.of(context).colorScheme.primary.withOpacity(0.12),
        highlightColor: Theme.of(context).colorScheme.primary.withOpacity(0.06),
        child: SizedBox(
          width: 76,
          height: 76,
          child: Center(
            child: Icon(
              icon,
              size: 28,
              color: iconColor ?? Theme.of(context).colorScheme.primary,
            ),
          ),
        ),
      ),
    );
  }
}
