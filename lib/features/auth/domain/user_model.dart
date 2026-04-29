class UserModel {
  final int id;
  final String name;
  final String email;
  final String role;
  final int? createdBy;
  final String createdAt;

  const UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    this.createdBy,
    required this.createdAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as int,
      name: json['name'] as String,
      email: json['email'] as String,
      role: json['role'] as String? ?? 'operator',
      createdBy: json['created_by'] as int?,
      createdAt: json['created_at'] as String? ?? '',
    );
  }
}
