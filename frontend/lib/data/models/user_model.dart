/// User model to represent authenticated user data
/// Location: lib/data/models/user_model.dart
class UserModel {
  final int id;
  final String username;
  final String? companyName;
  final String? email;
  final String? phone;

  UserModel({
    required this.id,
    required this.username,
    this.companyName,
    this.email,
    this.phone,
  });

  /// Convert database map to UserModel
  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'] as int,
      username: map['username'] as String,
      companyName: map['company_name'] as String?,
      email: map['email'] as String?,
      phone: map['phone'] as String?,
    );
  }

  /// Convert UserModel to map for database
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'username': username,
      'company_name': companyName,
      'email': email,
      'phone': phone,
    };
  }

  /// Create a copy with modified fields
  UserModel copyWith({
    int? id,
    String? username,
    String? companyName,
    String? email,
    String? phone,
  }) {
    return UserModel(
      id: id ?? this.id,
      username: username ?? this.username,
      companyName: companyName ?? this.companyName,
      email: email ?? this.email,
      phone: phone ?? this.phone,
    );
  }
}