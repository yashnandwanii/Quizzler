class UserModel {
  final String? id;
  final String fullName;
  final String email;
  final String password;
  final int coins;
  final int rank;
  final String photoUrl;

  const UserModel({
    this.id,
    required this.fullName,
    required this.email,
    required this.password,
    this.coins = 0,
    this.rank = 0,
    this.photoUrl = '',
  });

  toJson() {
    return {
      'fullName': fullName,
      'email': email,
      'password': password,
      'coins': coins,
      'rank': rank,
      'photoUrl': photoUrl,
    };
  }

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
        id: json['id'],
        fullName: json['fullName'] ?? '',
        email: json['email'] ?? '',
        password: json['password'] ?? '',
        coins: json['coins'] ?? 0,
        rank: json['rank'] ?? 0,
        photoUrl: json['photoUrl'] ?? '',
      );
}
