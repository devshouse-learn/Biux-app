import 'package:biux/features/authentication/domain/entities/auth_entity.dart';

/// Interfaz del repositorio de autenticación (contrato para la capa de datos)
abstract class AuthRepositoryInterface {
  Future<bool> sendOTP(String phoneNumber);
  Future<AuthEntity> validateOTP(String phoneNumber, String code);
  Future<void> signOut();
  bool get isLoggedIn;
  String? get currentUserId;
}
