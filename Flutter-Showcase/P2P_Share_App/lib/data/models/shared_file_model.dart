import '../../domain/entities/shared_file.dart';

class SharedFileModel extends SharedFile {
  const SharedFileModel({
    required super.id,
    required super.name,
    required super.path,
    required super.size,
    required super.category,
  });

  factory SharedFileModel.fromEntity(SharedFile file) {
    return SharedFileModel(
      id: file.id,
      name: file.name,
      path: file.path,
      size: file.size,
      category: file.category,
    );
  }

  factory SharedFileModel.fromJson(Map<String, dynamic> json) {
    return SharedFileModel(
      id: json['id'] as String,
      name: json['name'] as String,
      path: json['path'] as String? ?? '',
      size: json['size'] as int,
      category: FileCategory.values.firstWhere(
        (value) => value.name == json['category'],
        orElse: () => FileCategory.document,
      ),
    );
  }

  Map<String, dynamic> toJson({bool includePath = true}) {
    return {
      'id': id,
      'name': name,
      'path': includePath ? path : '',
      'size': size,
      'category': category.name,
    };
  }
}
