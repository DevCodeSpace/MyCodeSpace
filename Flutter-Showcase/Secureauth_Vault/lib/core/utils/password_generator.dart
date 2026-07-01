import 'dart:math';

class PasswordGenerator {
  PasswordGenerator._();

  static const String _lower = 'abcdefghijklmnopqrstuvwxyz';
  static const String _upper = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
  static const String _digits = '0123456789';
  static const String _symbols = '!@#\$%^&*()-_=+[]{}|;:,.<>?';

  static String generate({
    int length = 16,
    bool useLower = true,
    bool useUpper = true,
    bool useDigits = true,
    bool useSymbols = true,
  }) {
    final rng = Random.secure();
    final pool = StringBuffer();
    final guaranteed = <String>[];

    if (useLower) {
      pool.write(_lower);
      guaranteed.add(_lower[rng.nextInt(_lower.length)]);
    }
    if (useUpper) {
      pool.write(_upper);
      guaranteed.add(_upper[rng.nextInt(_upper.length)]);
    }
    if (useDigits) {
      pool.write(_digits);
      guaranteed.add(_digits[rng.nextInt(_digits.length)]);
    }
    if (useSymbols) {
      pool.write(_symbols);
      guaranteed.add(_symbols[rng.nextInt(_symbols.length)]);
    }

    if (pool.isEmpty) return '';

    final chars = pool.toString();
    final remaining = List.generate(
      length - guaranteed.length,
      (_) => chars[rng.nextInt(chars.length)],
    );

    final all = [...guaranteed, ...remaining]..shuffle(rng);
    return all.join();
  }

  static double strength(String password) {
    if (password.isEmpty) return 0;
    double score = 0;
    if (password.length >= 8) score += 0.2;
    if (password.length >= 12) score += 0.1;
    if (password.length >= 16) score += 0.1;
    if (password.contains(RegExp(r'[a-z]'))) score += 0.15;
    if (password.contains(RegExp(r'[A-Z]'))) score += 0.15;
    if (password.contains(RegExp(r'[0-9]'))) score += 0.15;
    if (password.contains(RegExp(r'[!@#\$%^&*()\-_=+\[\]{}|;:,.<>?]'))) {
      score += 0.15;
    }
    return score.clamp(0.0, 1.0);
  }
}
