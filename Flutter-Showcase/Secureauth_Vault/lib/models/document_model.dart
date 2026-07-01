enum DocumentType { pdf, image, video, other }

class DocumentModel {
  final String id;
  final String name;
  final String fileName;
  final String filePath; // encrypted local path
  final DocumentType type;
  final String? folderId;
  final int size;
  final DateTime createdAt;
  final DateTime updatedAt;

  const DocumentModel({
    required this.id,
    required this.name,
    required this.fileName,
    required this.filePath,
    required this.type,
    this.folderId,
    this.size = 0,
    required this.createdAt,
    required this.updatedAt,
  });

  static DocumentType typeFromExtension(String ext) {
    switch (ext.toLowerCase()) {
      case 'pdf':
        return DocumentType.pdf;
      case 'jpg':
      case 'jpeg':
      case 'png':
      case 'gif':
      case 'webp':
        return DocumentType.image;
      case 'mp4':
      case 'mov':
      case 'avi':
        return DocumentType.video;
      default:
        return DocumentType.other;
    }
  }

  String get typeString => type.name;

  String get sizeFormatted {
    if (size < 1024) return '${size}B';
    if (size < 1024 * 1024) return '${(size / 1024).toStringAsFixed(1)}KB';
    return '${(size / (1024 * 1024)).toStringAsFixed(1)}MB';
  }

  Map<String, dynamic> toMap() => {
    'id': id,
    'name': name,
    'file_name': fileName,
    'file_path': filePath,
    'type': typeString,
    'folder_id': folderId,
    'size': size,
    'created_at': createdAt.toIso8601String(),
    'updated_at': updatedAt.toIso8601String(),
  };

  factory DocumentModel.fromMap(Map<String, dynamic> map) => DocumentModel(
    id: map['id'] as String,
    name: map['name'] as String,
    fileName: map['file_name'] as String,
    filePath: map['file_path'] as String,
    type: DocumentType.values.firstWhere((t) => t.name == (map['type'] as String), orElse: () => DocumentType.other),
    folderId: map['folder_id'] as String?,
    size: map['size'] as int? ?? 0,
    createdAt: DateTime.parse(map['created_at'] as String),
    updatedAt: DateTime.parse(map['updated_at'] as String),
  );

  DocumentModel copyWith({String? name, String? folderId}) => DocumentModel(
    id: id,
    name: name ?? this.name,
    fileName: fileName,
    filePath: filePath,
    type: type,
    folderId: folderId ?? this.folderId,
    size: size,
    createdAt: createdAt,
    updatedAt: DateTime.now(),
  );
}
