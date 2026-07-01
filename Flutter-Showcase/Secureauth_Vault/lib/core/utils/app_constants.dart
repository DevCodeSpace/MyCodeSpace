class AppConstants {
  AppConstants._();

  // Secure storage keys
  static const String kEncryptionKey = 'vault_enc_key';
  static const String kBackupKey = 'vault_backup_key';
  static const String kPinHash = 'vault_pin_hash';
  static const String kPinSalt = 'vault_pin_salt';
  static const String kIsSetupDone = 'vault_setup_done';
  static const int kBackupDataVersion = 2;

  // Shared prefs keys
  static const String kThemeMode = 'theme_mode';
  static const String kBiometricEnabled = 'biometric_enabled';
  static const String kAutoLockTimeout = 'auto_lock_timeout';
  static const String kGoogleAccount = 'google_account';
  static const String kSelectedAppIcon = 'selected_app_icon_key';

  // Auto-lock timeouts (seconds)
  static const List<int> lockTimeouts = [
    30, 60, 120, 300, 600,
    // -1
  ];
  static const List<String> lockTimeoutLabels = [
    '30 seconds',
    '1 minute',
    '2 minutes',
    '5 minutes',
    '10 minutes',
    // 'Never',
  ];

  // Database
  static const String dbName = 'SecureAuth Vault.db';
  static const int dbVersion = 3;

  // Tables
  static const String tableCredentials = 'credentials';
  static const String tableDocuments = 'documents';
  static const String tableDocumentFolders = 'document_folders';
  static const String tableCategories = 'categories';

  // Category types
  static const String categoryTypeCredential = 'credential';
  static const String categoryTypeDocument = 'document';

  // Default categories
  static const List<Map<String, dynamic>> defaultCredentialCategories = [
    {'name': 'Login', 'icon': 'lock', 'color': 0xFF6C63FF},
    {'name': 'Email', 'icon': 'email', 'color': 0xFF03A9F4},
    {'name': 'Banking', 'icon': 'account_balance', 'color': 0xFF4CAF50},
    {'name': 'WiFi', 'icon': 'wifi', 'color': 0xFFFF9800},
    {'name': 'API Keys', 'icon': 'vpn_key', 'color': 0xFFE91E63},
    {'name': 'Notes', 'icon': 'note', 'color': 0xFF9C27B0},
  ];

  static const List<Map<String, dynamic>> defaultDocumentCategories = [
    {'name': 'Identity', 'icon': 'badge', 'color': 0xFF2196F3},
    {'name': 'Financial', 'icon': 'receipt_long', 'color': 0xFF4CAF50},
    {'name': 'Medical', 'icon': 'medical_services', 'color': 0xFFF44336},
    {'name': 'Certificates', 'icon': 'workspace_premium', 'color': 0xFFFF9800},
    {'name': 'Other', 'icon': 'folder', 'color': 0xFF607D8B},
  ];
}
