// represents a user/agency in the system

class UserModel {
  // id can be int from local db or string from backend
  final dynamic id;
  final String username;
  final String? companyName;
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

  // parses backend response where 'name' is used instead of 'username'
  factory UserModel.fromBackendJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      username: json['name'] ?? json['username'] ?? '',
      companyName: json['name'],
      email: json['email'],
      phone: json['phone'],
      joinDate: json['join_date'],
    );
  }

  // parses local storage json format
  factory UserModel.fromLocalJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      username: json['username'] ?? '',
      companyName: json['companyName'],
      email: json['email'],
      phone: json['phone'],
      joinDate: json['joinDate'],
    );
  }

  // converts to json for local storage
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

  // converts to json format expected by backend
  Map<String, dynamic> toBackendJson() {
    return {'name': username, 'email': email, 'phone': phone};
  }

  @override
  String toString() {
    return 'UserModel(id: $id, username: $username, email: $email)';
  }
}
