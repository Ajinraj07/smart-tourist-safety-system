class UserModel {
  final String username;
  final String email;
  final bool isSuperuser;

  UserModel({
    required this.username, 
    required this.email, 
    this.isSuperuser = false,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      username: json['username'] ?? '',
      email: json['email'] ?? '',
      isSuperuser: json['is_superuser'] ?? false,
    );
  }
}
