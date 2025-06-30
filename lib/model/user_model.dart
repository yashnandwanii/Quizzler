class UserModel {
  final String? id;
  final String fullName;
  final String email;
  final String password;
  final String photoUrl;
  final int coins;
  final int rank;

  const UserModel({
    this.id,
    required this.fullName,
    required this.email,
    required this.password,
    this.photoUrl = '',
    this.coins = 0,
    this.rank = 0,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'fullName': fullName,
      'email': email,
      'password': password,
      'photoUrl': photoUrl,
      'coins': coins,
      'rank': rank,
    };
  }

  UserModel copyWith({
    String? id,
    String? fullName,
    String? email,
    String? password,
    String? photoUrl,
    int? coins,
    int? rank,
  }) {
    return UserModel(
      id: id ?? this.id,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      password: password ?? this.password,
      photoUrl: photoUrl ?? this.photoUrl,
      coins: coins ?? this.coins,
      rank: rank ?? this.rank,
    );
  }

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
        id: json['id'],
        fullName: json['fullName'] ?? '',
        email: json['email'] ?? '',
        password: json['password'] ?? '',
        photoUrl: json['photoUrl'] ?? '',
        coins: json['coins'] ?? 0,
        rank: json['rank'] ?? 0,
      );
}
