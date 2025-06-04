class User {
  final int pk;
  final String username;
  final String email;
  final String firstName;
  final String lastName;
  final String? agenceId;

  User({
    required this.pk,
    required this.username,
    required this.email,
    required this.firstName,
    required this.lastName,
    this.agenceId,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      pk: json['pk'] ?? 0, // Valeur par défaut si pk est null
      username: json['username'] ?? '',
      email: json['email'] ?? '',
      firstName: json['first_name'] ?? '',
      lastName: json['last_name'] ?? '',
      agenceId: json['agence_id']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'pk': pk,
      'username': username,
      'email': email,
      'first_name': firstName,
      'last_name': lastName,
      'agence_id': agenceId,
    };
  }
}

class AuthResponse {
  final String accessToken;
  final String refreshToken;
  final User? user;

  AuthResponse({
    required this.accessToken,
    required this.refreshToken,
    this.user,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      accessToken: json['access'] ?? '',
      refreshToken: json['refresh'] ?? '',
      user: json['user'] != null ? User.fromJson(json['user']) : null,
    );
  }
}
