/// Entidad de dominio para autenticación
class AuthEntity {
  final String uid;
  final String? token;
  final String? phoneNumber;
  final bool isAdmin;
  final bool needsProfileSetup;

  const AuthEntity({
    required this.uid,
    this.token,
    this.phoneNumber,
    this.isAdmin = false,
    this.needsProfileSetup = false,
  });
}

/// Estados posibles de autenticación
enum AuthStatus { initial, loading, codeSent, authenticated, error }
