import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';
import 'package:encrypt/encrypt.dart' as enc;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';

import '../utils/app_constants.dart';

class EncryptionService extends GetxService {
  late enc.Encrypter _encrypter;
  late enc.Key _key;

  static const _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
    iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock),
  );

  Future<EncryptionService> init() async {
    String? keyBase64 = await _storage.read(key: AppConstants.kEncryptionKey);

    if (keyBase64 == null) {
      final key = enc.Key.fromSecureRandom(32);
      keyBase64 = base64.encode(key.bytes);
      await _storage.write(key: AppConstants.kEncryptionKey, value: keyBase64);
    }

    _key = enc.Key(base64.decode(keyBase64));
    _encrypter = enc.Encrypter(enc.AES(_key, mode: enc.AESMode.cbc));
    return this;
  }

  String encrypt(String plainText) {
    if (plainText.isEmpty) return '';
    final iv = enc.IV.fromSecureRandom(16);
    final encrypted = _encrypter.encrypt(plainText, iv: iv);
    return '${iv.base64}:${encrypted.base64}';
  }

  String decrypt(String cipherText) {
    if (cipherText.isEmpty) return '';
    try {
      final parts = cipherText.split(':');
      if (parts.length != 2) return cipherText;
      final iv = enc.IV.fromBase64(parts[0]);
      return _encrypter.decrypt64(parts[1], iv: iv);
    } catch (_) {
      return '';
    }
  }

  Future<String> encryptBackupPayload(String plainText) async {
    if (plainText.isEmpty) return '';

    final backupKey = await _readBackupKey();
    if (backupKey == null) {
      return encrypt(plainText);
    }

    final iv = enc.IV.fromSecureRandom(16);
    final encrypted = enc.Encrypter(enc.AES(backupKey, mode: enc.AESMode.cbc)).encrypt(plainText, iv: iv);
    return 'v2:${iv.base64}:${encrypted.base64}';
  }

  Future<String> decryptBackupPayload(String cipherText) async {
    if (cipherText.isEmpty) return '';

    if (cipherText.startsWith('v2:')) {
      try {
        final backupKey = await _readBackupKey();
        if (backupKey == null) return '';

        final parts = cipherText.split(':');
        if (parts.length != 3) return '';

        final iv = enc.IV.fromBase64(parts[1]);
        return enc.Encrypter(enc.AES(backupKey, mode: enc.AESMode.cbc)).decrypt64(parts[2], iv: iv);
      } catch (_) {
        return '';
      }
    }

    // Legacy backup format encrypted with device-specific key.
    return decrypt(cipherText);
  }

  // PIN hashing using PBKDF2
  String hashPin(String pin, String salt) {
    final saltBytes = utf8.encode(salt);
    final pinBytes = utf8.encode(pin);

    // Simple PBKDF2-like derivation using HMAC-SHA256 with 10000 iterations
    List<int> result = pinBytes;
    for (int i = 0; i < 10000; i++) {
      final hmac = Hmac(sha256, saltBytes);
      result = hmac.convert(result).bytes;
    }
    return base64.encode(result);
  }

  String generateSalt() {
    final rng = Random.secure();
    final bytes = List<int>.generate(32, (_) => rng.nextInt(256));
    return base64.encode(bytes);
  }

  Future<void> storePinHash(String pin) async {
    final salt = generateSalt();
    final hash = hashPin(pin, salt);
    await _storage.write(key: AppConstants.kPinSalt, value: salt);
    await _storage.write(key: AppConstants.kPinHash, value: hash);
    await setBackupKeyFromPin(pin);
  }

  Future<void> setBackupKeyFromPin(String pin) async {
    final keyBytes = _deriveBackupKeyBytes(pin);
    await _storage.write(key: AppConstants.kBackupKey, value: base64.encode(keyBytes));
  }

  Future<bool> hasBackupKey() async {
    final keyBase64 = await _storage.read(key: AppConstants.kBackupKey);
    return keyBase64 != null && keyBase64.isNotEmpty;
  }

  Future<bool> verifyPin(String pin) async {
    final salt = await _storage.read(key: AppConstants.kPinSalt);
    final storedHash = await _storage.read(key: AppConstants.kPinHash);
    if (salt == null || storedHash == null) return false;
    final hash = hashPin(pin, salt);
    return hash == storedHash;
  }

  Future<bool> isPinSet() async {
    final hash = await _storage.read(key: AppConstants.kPinHash);
    return hash != null;
  }

  Future<void> resetAll() async {
    await _storage.deleteAll();
  }

  // Encrypts a map to JSON string
  String encryptMap(Map<String, dynamic> data) {
    return encrypt(jsonEncode(data));
  }

  Map<String, dynamic> decryptMap(String cipherText) {
    final json = decrypt(cipherText);
    if (json.isEmpty) return {};
    return jsonDecode(json);
  }

  // Encrypt raw bytes (for files)
  Uint8List encryptBytes(Uint8List data) {
    final iv = enc.IV.fromSecureRandom(16);
    final encrypted = _encrypter.encryptBytes(data, iv: iv);
    final ivBytes = iv.bytes;
    final result = Uint8List(16 + encrypted.bytes.length);
    result.setRange(0, 16, ivBytes);
    result.setRange(16, result.length, encrypted.bytes);
    return result;
  }

  Uint8List decryptBytes(Uint8List data) {
    if (data.length < 16) return data;
    final iv = enc.IV(data.sublist(0, 16));
    final cipherBytes = data.sublist(16);
    final encrypted = enc.Encrypted(cipherBytes);
    return Uint8List.fromList(_encrypter.decryptBytes(encrypted, iv: iv));
  }

  Future<enc.Key?> _readBackupKey() async {
    final keyBase64 = await _storage.read(key: AppConstants.kBackupKey);
    if (keyBase64 == null || keyBase64.isEmpty) return null;

    try {
      return enc.Key(base64.decode(keyBase64));
    } catch (_) {
      return null;
    }
  }

  List<int> _deriveBackupKeyBytes(String pin) {
    final stretched = hashPin(pin, 'secureauth_backup_salt_v1');
    return sha256.convert(utf8.encode(stretched)).bytes;
  }
}
