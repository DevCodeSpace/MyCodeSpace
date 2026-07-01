class Credential {
  final String id;
  final String title;
  final String username; // stored encrypted
  final String password; // stored encrypted
  final String url;
  final String notes; // stored encrypted
  final List<String> tags;
  final String? categoryId;
  final bool isFavorite;
  final DateTime createdAt;
  final DateTime updatedAt;

  // Made nullable directly at root for pristine data tracking
  final String? accountNumber;
  final String? ifscCode;

  const Credential({
    required this.id,
    required this.title,
    this.username = '',
    this.password = '',
    this.url = '',
    this.notes = '',
    this.tags = const [],
    this.categoryId,
    this.isFavorite = false,
    required this.createdAt,
    required this.updatedAt,
    this.accountNumber, // Default parameter is now null natively
    this.ifscCode, // Default parameter is now null natively
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'title': title,
    'username': username,
    'password': password,
    'url': url,
    'notes': notes,
    'tags': tags.join(','),
    'category_id': categoryId,
    'is_favorite': isFavorite ? 1 : 0,
    'created_at': createdAt.toIso8601String(),
    'updated_at': updatedAt.toIso8601String(),
    'account_number': accountNumber, // Passes null natively if empty
    'ifsc_code': ifscCode, // Passes null natively if empty
  };

  factory Credential.fromMap(Map<String, dynamic> map) => Credential(
    id: map['id'] as String,
    title: map['title'] as String,
    username: map['username'] as String? ?? '',
    password: map['password'] as String? ?? '',
    url: map['url'] as String? ?? '',
    notes: map['notes'] as String? ?? '',
    tags: (map['tags'] as String?)?.split(',').where((t) => t.isNotEmpty).toList() ?? [],
    categoryId: map['category_id'] as String?,
    isFavorite: (map['is_favorite'] as int?) == 1,
    createdAt: DateTime.parse(map['created_at'] as String),
    updatedAt: DateTime.parse(map['updated_at'] as String),
    accountNumber: map['account_number'] as String?, // Stripped explicit fallback to preserve null
    ifscCode: map['ifsc_code'] as String?, // Stripped explicit fallback to preserve null
  );

  Credential copyWith({
    String? title,
    String? username,
    String? password,
    String? url,
    String? notes,
    List<String>? tags,
    String? categoryId,
    bool? isFavorite,
    String? accountNumber,
    String? ifscCode,
  }) => Credential(
    id: id,
    title: title ?? this.title,
    username: username ?? this.username,
    password: password ?? this.password,
    url: url ?? this.url,
    notes: notes ?? this.notes,
    tags: tags ?? this.tags,
    categoryId: categoryId ?? this.categoryId,
    isFavorite: isFavorite ?? this.isFavorite,
    createdAt: createdAt,
    updatedAt: DateTime.now(),
    accountNumber: accountNumber ?? this.accountNumber,
    ifscCode: ifscCode ?? this.ifscCode,
  );
}
