import 'package:get/get.dart';
import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';
import 'package:uuid/uuid.dart';

import '../../models/category.dart';
import '../../models/credential.dart';
import '../../models/document_folder.dart';
import '../../models/document_model.dart';
import '../utils/app_constants.dart';
import 'encryption_service.dart';

class DatabaseService extends GetxService {
  late Database _db;
  late EncryptionService _enc;
  static const _uuid = Uuid();

  Future<DatabaseService> init() async {
    _enc = Get.find<EncryptionService>();
    final dbPath = await getDatabasesPath();
    final path = p.join(dbPath, AppConstants.dbName);

    _db = await openDatabase(path, version: AppConstants.dbVersion, onCreate: _onCreate, onUpgrade: _onUpgrade);

    await _seedDefaultCategories();
    return this;
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE ${AppConstants.tableCredentials} (
        id TEXT PRIMARY KEY,
        title TEXT NOT NULL,
        username TEXT,
        password TEXT,
        url TEXT,
        notes TEXT,
        tags TEXT,
        category_id TEXT,
        is_favorite INTEGER DEFAULT 0,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        account_number TEXT,
        ifsc_code TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE ${AppConstants.tableDocuments} (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        file_name TEXT NOT NULL,
        file_path TEXT NOT NULL,
        type TEXT NOT NULL,
        folder_id TEXT,
        size INTEGER DEFAULT 0,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE ${AppConstants.tableDocumentFolders} (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL UNIQUE,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE ${AppConstants.tableCategories} (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        icon TEXT NOT NULL,
        color INTEGER NOT NULL,
        type TEXT NOT NULL
      )
    ''');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('''
        CREATE TABLE IF NOT EXISTS ${AppConstants.tableDocumentFolders} (
          id TEXT PRIMARY KEY,
          name TEXT NOT NULL UNIQUE,
          created_at TEXT NOT NULL,
          updated_at TEXT NOT NULL
        )
      ''');
    }

    // Progressive execution matrix targeting current schema deployment versioning changes
    // Checks if the database table needs the new Indian banking structural blocks
    // NOTE: Ensure AppConstants.dbVersion has been incremented to trigger this logic.
    if (oldVersion < 3) {
      try {
        await db.execute('ALTER TABLE ${AppConstants.tableCredentials} ADD COLUMN account_number TEXT');
        await db.execute('ALTER TABLE ${AppConstants.tableCredentials} ADD COLUMN ifsc_code TEXT');
      } catch (e) {
        // Safe-catch structural exceptions in case the column already exists in raw testing environments
      }
    }
  }

  Future<void> _seedDefaultCategories() async {
    final existing = await _db.query(AppConstants.tableCategories, limit: 1);
    if (existing.isNotEmpty) return;

    final batch = _db.batch();
    for (final cat in AppConstants.defaultCredentialCategories) {
      batch.insert(AppConstants.tableCategories, {
        'id': _uuid.v4(),
        'name': cat['name'],
        'icon': cat['icon'],
        'color': cat['color'],
        'type': AppConstants.categoryTypeCredential,
      });
    }
    for (final cat in AppConstants.defaultDocumentCategories) {
      batch.insert(AppConstants.tableCategories, {
        'id': _uuid.v4(),
        'name': cat['name'],
        'icon': cat['icon'],
        'color': cat['color'],
        'type': AppConstants.categoryTypeDocument,
      });
    }
    await batch.commit(noResult: true);
  }

  // ─── Credentials ────────────────────────────────────────────────────────────

  Future<String> insertCredential(Credential cred) async {
    final id = _uuid.v4();
    final map = _encryptCredential(cred.copyWith()).toMap();
    map['id'] = id;
    await _db.insert(AppConstants.tableCredentials, map);
    return id;
  }

  Future<void> updateCredential(Credential cred) async {
    final map = _encryptCredential(cred).toMap();
    await _db.update(AppConstants.tableCredentials, map, where: 'id = ?', whereArgs: [cred.id]);
  }

  Future<void> deleteCredential(String id) async {
    await _db.delete(AppConstants.tableCredentials, where: 'id = ?', whereArgs: [id]);
  }

  Future<List<Credential>> getAllCredentials() async {
    final rows = await _db.query(AppConstants.tableCredentials, orderBy: 'updated_at DESC');
    return rows.map((r) => _decryptCredential(Credential.fromMap(r))).toList();
  }

  Future<List<Credential>> searchCredentials(String query) async {
    final lower = query.toLowerCase();
    final all = await getAllCredentials();
    return all.where((c) {
      return c.title.toLowerCase().contains(lower) ||
          c.url.toLowerCase().contains(lower) ||
          (c.accountNumber != null && c.accountNumber!.toLowerCase().contains(lower)) || // Added to local lookup matrix filters
          (c.ifscCode != null && c.ifscCode!.toLowerCase().contains(lower)) || // Added to local lookup matrix filters
          c.tags.any((t) => t.toLowerCase().contains(lower));
    }).toList();
  }

  Future<List<Credential>> getCredentialsByCategory(String categoryId) async {
    final rows = await _db.query(AppConstants.tableCredentials, where: 'category_id = ?', whereArgs: [categoryId], orderBy: 'updated_at DESC');
    return rows.map((r) => _decryptCredential(Credential.fromMap(r))).toList();
  }

  // Symmetrically secures banking fields using your standard configuration block pipelines
  Credential _encryptCredential(Credential c) => Credential(
    id: c.id,
    title: c.title,
    username: c.username.isNotEmpty ? _enc.encrypt(c.username) : '',
    password: c.password.isNotEmpty ? _enc.encrypt(c.password) : '',
    url: c.url,
    notes: c.notes.isNotEmpty ? _enc.encrypt(c.notes) : '',
    tags: c.tags,
    categoryId: c.categoryId,
    isFavorite: c.isFavorite,
    createdAt: c.createdAt,
    updatedAt: c.updatedAt,
    accountNumber: (c.accountNumber != null && c.accountNumber!.isNotEmpty) ? _enc.encrypt(c.accountNumber!) : null,
    ifscCode: (c.ifscCode != null && c.ifscCode!.isNotEmpty) ? _enc.encrypt(c.ifscCode!) : null,
  );

  // Symmetrically decrypts banking data elements down into original formats
  Credential _decryptCredential(Credential c) => Credential(
    id: c.id,
    title: c.title,
    username: c.username.isNotEmpty ? _enc.decrypt(c.username) : '',
    password: c.password.isNotEmpty ? _enc.decrypt(c.password) : '',
    url: c.url,
    notes: c.notes.isNotEmpty ? _enc.decrypt(c.notes) : '',
    tags: c.tags,
    categoryId: c.categoryId,
    isFavorite: c.isFavorite,
    createdAt: c.createdAt,
    updatedAt: c.updatedAt,
    accountNumber: (c.accountNumber != null && c.accountNumber!.isNotEmpty) ? _enc.decrypt(c.accountNumber!) : null,
    ifscCode: (c.ifscCode != null && c.ifscCode!.isNotEmpty) ? _enc.decrypt(c.ifscCode!) : null,
  );

  // ─── Documents ──────────────────────────────────────────────────────────────

  Future<String> insertDocument(DocumentModel doc) async {
    final id = _uuid.v4();
    final map = doc.toMap();
    map['id'] = id;
    await _db.insert(AppConstants.tableDocuments, map);
    return id;
  }

  Future<void> updateDocument(DocumentModel doc) async {
    await _db.update(AppConstants.tableDocuments, doc.toMap(), where: 'id = ?', whereArgs: [doc.id]);
  }

  Future<void> deleteDocument(String id) async {
    await _db.delete(AppConstants.tableDocuments, where: 'id = ?', whereArgs: [id]);
  }

  Future<List<DocumentModel>> getAllDocuments() async {
    final rows = await _db.query(AppConstants.tableDocuments, orderBy: 'updated_at DESC');
    return rows.map(DocumentModel.fromMap).toList();
  }

  Future<List<DocumentModel>> searchDocuments(String query) async {
    final lower = query.toLowerCase();
    final all = await getAllDocuments();
    return all.where((d) => d.name.toLowerCase().contains(lower)).toList();
  }

  Future<List<DocumentFolder>> getAllDocumentFolders() async {
    final rows = await _db.query(AppConstants.tableDocumentFolders, orderBy: 'name COLLATE NOCASE ASC');
    return rows.map(DocumentFolder.fromMap).toList();
  }

  Future<void> insertDocumentFolder(DocumentFolder folder) async {
    await _db.insert(AppConstants.tableDocumentFolders, folder.toMap(), conflictAlgorithm: ConflictAlgorithm.abort);
  }

  Future<void> deleteDocumentFolder(String id) async {
    await _db.transaction((txn) async {
      await txn.update(AppConstants.tableDocuments, {'folder_id': null}, where: 'folder_id = ?', whereArgs: [id]);
      await txn.delete(AppConstants.tableDocumentFolders, where: 'id = ?', whereArgs: [id]);
    });
  }

  // ─── Categories ─────────────────────────────────────────────────────────────

  Future<List<Category>> getCategories(String type) async {
    final rows = await _db.query(AppConstants.tableCategories, where: 'type = ?', whereArgs: [type]);
    return rows.map(Category.fromMap).toList();
  }

  Future<void> insertCategory(Category cat) async {
    await _db.insert(AppConstants.tableCategories, cat.toMap());
  }

  Future<void> deleteCategory(String id) async {
    await _db.delete(AppConstants.tableCategories, where: 'id = ?', whereArgs: [id]);
  }

  // ─── Backup / Restore ───────────────────────────────────────────────────────

  Future<Map<String, dynamic>> exportAll() async {
    final credentials = (await getAllCredentials()).map((c) => c.toMap()).toList();
    final documents = await _db.query(AppConstants.tableDocuments);
    final documentFolders = await _db.query(AppConstants.tableDocumentFolders);
    final categories = await _db.query(AppConstants.tableCategories);
    return {
      'backup_version': AppConstants.kBackupDataVersion,
      'credentials': credentials,
      'documents': documents,
      'document_folders': documentFolders,
      'categories': categories,
      'exported_at': DateTime.now().toIso8601String(),
    };
  }

  Future<void> importAll(Map<String, dynamic> data) async {
    final backupVersion = data['backup_version'];
    final isPortableBackup = backupVersion is int && backupVersion >= AppConstants.kBackupDataVersion;

    await _db.transaction((txn) async {
      await txn.delete(AppConstants.tableCredentials);
      await txn.delete(AppConstants.tableDocuments);
      await txn.delete(AppConstants.tableDocumentFolders);
      await txn.delete(AppConstants.tableCategories);

      for (final row in (data['credentials'] as List? ?? [])) {
        final rowMap = Map<String, dynamic>.from(row as Map);
        if (isPortableBackup) {
          final cred = Credential.fromMap(rowMap);
          final encrypted = _encryptCredential(cred).toMap();
          await txn.insert(AppConstants.tableCredentials, encrypted);
          continue;
        }

        await txn.insert(AppConstants.tableCredentials, rowMap);
      }
      for (final row in (data['documents'] as List? ?? [])) {
        await txn.insert(AppConstants.tableDocuments, Map<String, dynamic>.from(row as Map));
      }
      for (final row in (data['document_folders'] as List? ?? [])) {
        await txn.insert(AppConstants.tableDocumentFolders, Map<String, dynamic>.from(row as Map));
      }
      for (final row in (data['categories'] as List? ?? [])) {
        await txn.insert(AppConstants.tableCategories, Map<String, dynamic>.from(row as Map));
      }
    });
  }

  Future<Map<String, int>> getStats() async {
    final credCount = Sqflite.firstIntValue(await _db.rawQuery('SELECT COUNT(*) FROM ${AppConstants.tableCredentials}')) ?? 0;
    final docCount = Sqflite.firstIntValue(await _db.rawQuery('SELECT COUNT(*) FROM ${AppConstants.tableDocuments}')) ?? 0;
    return {'credentials': credCount, 'documents': docCount};
  }
}
