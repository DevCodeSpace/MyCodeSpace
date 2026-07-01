class DocumentFolder {
  final String id;
  final String name;
  final DateTime createdAt;
  final DateTime updatedAt;

  const DocumentFolder({
    required this.id,
    required this.name,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'name': name,
    'created_at': createdAt.toIso8601String(),
    'updated_at': updatedAt.toIso8601String(),
  };

  factory DocumentFolder.fromMap(Map<String, dynamic> map) => DocumentFolder(
    id: map['id'] as String,
    name: map['name'] as String,
    createdAt: DateTime.parse(map['created_at'] as String),
    updatedAt: DateTime.parse(map['updated_at'] as String),
  );
}
