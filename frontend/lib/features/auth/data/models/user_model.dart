/// User Model for authentication
/// Location: lib/features/auth/data/models/user_model.dart
class UserModel {
  final dynamic id; // Can be int (local) or String (backend)
  final String username;
  final String? companyName; // Optional for backwards compatibility
  final String? email;
  final String? phone;
  final String? joinDate;

  UserModel({
    required this.id,
    required this.username,
    this.companyName,
    this.email,
    this.phone,
    this.joinDate,
  });

  /// Create from backend JSON response
  /// Backend returns: {id, name, email, phone, join_date}
  factory UserModel.fromBackendJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'], // String from backend
      username: json['name'] ?? json['username'] ?? '', // Backend uses 'name'
      companyName: json['name'],
      email: json['email'],
      phone: json['phone'],
      joinDate: json['join_date'],
    );
  }

  /// Create from local JSON (SharedPreferences)
  factory UserModel.fromLocalJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'], // int from local
      username: json['username'] ?? '',
      companyName: json['companyName'],
      email: json['email'],
      phone: json['phone'],
      joinDate: json['joinDate'],
    );
  }

  /// Convert to JSON for SharedPreferences
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'companyName': companyName,
      'email': email,
      'phone': phone,
      'joinDate': joinDate,
    };
  }

  /// Convert to JSON for backend requests
  Map<String, dynamic> toBackendJson() {
    return {
      'name': username, // Backend uses 'name' not 'username'
      'email': email,
      'phone': phone,
    };
  }

  @override
  String toString() {
    return 'UserModel(id: $id, username: $username, email: $email)';
  }
}