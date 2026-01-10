class AuthResponse {
  final String token;
  final String uid;

  AuthResponse({required this.token, required this.uid});

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(token: json['token'] ?? '', uid: json['uid'] ?? '');
  }
}
