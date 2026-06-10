import 'dart:async';
import 'package:biux/core/services/local_storage.dart';
import 'package:biux/core/models/common/response.dart';
import 'package:biux/features/authentication/domain/entities/auth_entity.dart';
import 'package:biux/features/authentication/domain/repositories/auth_repository_interface.dart';
import 'package:biux/features/users/data/models/user.dart';
import 'package:biux/features/users/data/repositories/user_firebase_repository.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:biux/core/config/api_config.dart';
import 'package:biux/core/exceptions/authorization_exceptions.dart';
import 'package:biux/core/services/app_logger.dart';

class AuthenticationRepository implements AuthRepositoryInterface {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  String? _verificationId;

  bool get isLoggedIn {
    if (_auth.currentUser != null) {
      return true;
    } else {
      return false;
    }
  }

  String get getUserId => _auth.currentUser!.uid;

  Future<void> signOut() => _auth.signOut();

  Future<ResponseRepo> login(String email, String password) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      final user = userCredential.user;
      return ResponseRepo(message: user!.uid, status: true, statusCode: 200);
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        return ResponseRepo(
          message: 'err_user_not_found',
          status: false,
          statusCode: 500,
        );
      } else if (e.code == 'wrong-password') {
        return ResponseRepo(
          message: 'err_wrong_password',
          status: false,
          statusCode: 500,
        );
      } else if (e.code == 'invalid-email') {
        return ResponseRepo(
          message: 'err_invalid_email',
          status: false,
          statusCode: 500,
        );
      } else {
        return ResponseRepo(
          message: 'err_login',
          status: false,
          statusCode: 500,
        );
      }
    }
  }

  Future sendEmail(String user) async {
    try {
      await _auth.sendPasswordResetEmail(email: user);
    } on FirebaseAuthException catch (e) {
      if (e.code == 'invalid-email') {
        return ResponseRepo(
          message: 'err_invalid_email',
          status: false,
          statusCode: 500,
        );
      } else if (e.code == 'user-not-found') {
        return ResponseRepo(
          message: 'err_user_not_found',
          status: false,
          statusCode: 500,
        );
      } else {}
    }
  }

  Future<ResponseRepo> registerUser({required BiuxUser user}) async {
    try {
      UserCredential userCredential = await _auth
          .createUserWithEmailAndPassword(
            email: user.email,
            password: user.password,
          );
      final String uid = userCredential.user!.uid;
      // CRÍTICO #11: NUNCA guardar passwords en Firestore
      // Firebase Auth ya gestiona la autenticación de manera segura
      final BiuxUser biuxUser = BiuxUser(
        id: uid,
        fullName: user.fullName,
        cityId: user.cityId,
        dateBirth: user.dateBirth,
        email: user.email,
        facebook: user.facebook,
        followerS: user.followerS,
        followers: user.followers,
        following: user.following,
        gender: user.gender,
        groupId: user.groupId,
        instagram: user.instagram,
        modality: user.modality,
        // REMOVER: password: user.password,  <- Nunca guardar en Firestore
        photo: user.photo,
        premium: user.premium,
        profileCover: user.profileCover,
        situationAccident: user.situationAccident,
        token: user.token,
        userName: user.userName,
        whatsapp: user.whatsapp,
      );
      await UserFirebaseRepository().registerUser(user: biuxUser);
      LocalStorage().setUserName(user.userName);
      return ResponseRepo(message: biuxUser.id, status: true, statusCode: 200);
    } on FirebaseAuthException catch (e) {
      if (e.code == 'email-already-in-use') {
        return ResponseRepo(
          message: 'err_email_already_use',
          statusCode: 500,
          status: false,
        );
      } else {
        return ResponseRepo(
          message: 'err_register_user',
          status: false,
          statusCode: 500,
        );
      }
    }
  }

  // Implementaciones de AuthRepositoryInterface
  @override
  String? get currentUserId => _auth.currentUser?.uid;

  /// ALTO: Validar entrada y no loguear respuestas sensibles
  @override
  Future<bool> sendOTP(String phoneNumber) async {
    try {
      // Validar que el teléfono no esté vacío
      if (phoneNumber.isEmpty) {
        throw ValidationException('phoneNumber', 'Número de teléfono no puede estar vacío');
      }

      final response = await http.post(
        Uri.parse(ApiConfig.sendOtp),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'phoneNumber': phoneNumber,
        }),
      ).timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          AppLogger.warning('Timeout enviando OTP', tag: 'AuthenticationRepository');
          return throw Exception('OTP request timeout');
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        _verificationId = data['verificationId'] ?? data['id'] ?? phoneNumber;
        AppLogger.info('OTP enviado exitosamente', tag: 'AuthenticationRepository');
        return true;
      } else {
        // ALTO: No loguear respuesta completa que puede contener datos sensibles
        AppLogger.warning('Error enviando OTP: código ${response.statusCode}',
            tag: 'AuthenticationRepository');
        throw Exception('Error sending OTP');
      }
    } on ValidationException catch (e) {
      AppLogger.warning('Validación fallida: ${e.message}',
          tag: 'AuthenticationRepository');
      rethrow;
    } on FirebaseException catch (e) {
      AppLogger.error('Error de Firebase enviando OTP: $e',
          tag: 'AuthenticationRepository', error: e);
      throw Exception('Firebase error sending OTP');
    } catch (e) {
      AppLogger.error('Error inesperado enviando OTP: $e',
          tag: 'AuthenticationRepository', error: e);
      throw Exception('Error sending OTP');
    }
  }

  /// ALTO: Validar entrada y no loguear datos sensibles en respuesta
  @override
  Future<AuthEntity> validateOTP(String phoneNumber, String code) async {
    try {
      // Validar entrada
      if (phoneNumber.isEmpty || code.isEmpty) {
        throw ValidationException('input',
            'Número de teléfono y código no pueden estar vacíos');
      }

      if (_verificationId == null || _verificationId!.isEmpty) {
        throw ValidationException('verificationId', 'ID de verificación no encontrado');
      }

      final response = await http.post(
        Uri.parse(ApiConfig.validateOtp),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'phoneNumber': phoneNumber,
          'code': code,
          'verificationId': _verificationId,
        }),
      ).timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          AppLogger.warning('Timeout validando OTP', tag: 'AuthenticationRepository');
          return throw Exception('OTP validation timeout');
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        final token = data['token'] ?? data['customToken'];
        final uid = data['uid'] ?? data['userId'];

        if (token == null || uid == null) {
          AppLogger.warning('Respuesta inválida: falta token o uid',
              tag: 'AuthenticationRepository');
          throw ValidationException('response', 'Respuesta inválida del servidor');
        }

        AppLogger.info('OTP validado exitosamente',
            tag: 'AuthenticationRepository');

        return AuthEntity(
          uid: uid,
          token: token,
          phoneNumber: phoneNumber,
        );
      } else {
        // ALTO: No loguear respuesta que contiene tokens/datos sensibles
        AppLogger.warning('Error validando OTP: código ${response.statusCode}',
            tag: 'AuthenticationRepository');
        throw Exception('OTP validation failed');
      }
    } on ValidationException catch (e) {
      AppLogger.warning('Validación fallida: ${e.message}',
          tag: 'AuthenticationRepository');
      rethrow;
    } on FirebaseException catch (e) {
      AppLogger.error('Error de Firebase validando OTP: $e',
          tag: 'AuthenticationRepository', error: e);
      throw Exception('Firebase error validating OTP');
    } catch (e) {
      AppLogger.error('Error inesperado validando OTP: $e',
          tag: 'AuthenticationRepository', error: e);
      throw Exception('OTP validation failed');
    }
  }
}

