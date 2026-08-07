class UserModel {
  final int? id;
  final String name;
  final String email;
  final String passwordHash;
  final String? avatarPath;
  final DateTime createdAt;

  const UserModel({
    this.id,
    required this.name,
    required this.email,
    required this.passwordHash,
    this.avatarPath,
    required this.createdAt,
  });

  // Copy with
  UserModel copyWith({
    int? id,
    String? name,
    String? email,
    String? passwordHash,
    String? avatarPath,
    DateTime? createdAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      passwordHash: passwordHash ?? this.passwordHash,
      avatarPath: avatarPath ?? this.avatarPath,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  // To Map (for SQLite)
  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'name': name,
      'email': email,
      'password_hash': passwordHash,
      'avatar_path': avatarPath,
      'created_at': createdAt.toIso8601String(),
    };
  }

  // From Map (from SQLite)
  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'] as int?,
      name: map['name'] as String,
      email: map['email'] as String,
      passwordHash: map['password_hash'] as String,
      avatarPath: map['avatar_path'] as String?,
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }

  @override
  String toString() {
    return 'UserModel(id: $id, name: $name, email: $email)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UserModel && other.id == id && other.email == email;
  }

  @override
  int get hashCode => id.hashCode ^ email.hashCode;
}
