class UserModel {
  final String? id;
  final String fullName;
  final String email;
  final String password;

  const UserModel({
    this.id,
    required this.fullName,
    required this.email,
    required this.password,
  });

  toJson() {
    return {
      'fullName': fullName,
      'email': email,
      'password': password,
    };
  }

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
        fullName: json['fullName'] ?? '',
        email: json['email'] ?? '',
        password: json['password'] ?? '',
      ); // yha issue aa skta h
}
