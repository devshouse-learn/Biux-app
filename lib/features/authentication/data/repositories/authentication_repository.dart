import 'dart:async';
import 'package:biux/core/services/local_storage.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:biux/core/models/common/response.dart';
import 'package:biux/features/authentication/domain/entities/auth_entity.dart';
import 'package:biux/features/authentication/domain/repositories/auth_repository_interface.dart';
import 'package:biux/features/users/data/models/user.dart';
import 'package:biux/features/users/data/repositories/user_firebase_repository.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:biux/core/config/api_config.dart';

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

  @override
  Future<bool> sendOTP(String phoneNumber) async {
    try {
      final response = await http.post(
        Uri.parse(ApiConfig.sendOtp),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'phoneNumber': phoneNumber,
        }),
      ).timeout(
        const Duration(seconds: 30),
        onTimeout: () => throw Exception('Timeout sending OTP'),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        _verificationId = data['verificationId'] ?? data['id'] ?? phoneNumber;
        return true;
      } else {
        throw Exception(
          'Error sending OTP: ${response.statusCode} - ${response.body}',
        );
      }
    } on FirebaseException catch (e) {
      throw Exception('Error sending OTP: $e');
    }
  }

  @override
  Future<AuthEntity> validateOTP(String phoneNumber, String code) async {
    try {
      if (_verificationId == null || _verificationId!.isEmpty) {
        throw Exception('Verification ID not found');
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
        onTimeout: () => throw Exception('Timeout validating OTP'),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        final token = data['token'] ?? data['customToken'];
        final uid = data['uid'] ?? data['userId'];

        if (token == null || uid == null) {
          throw Exception('Invalid response: missing token or uid');
        }

        return AuthEntity(
          uid: uid,
          token: token,
          phoneNumber: phoneNumber,
        );
      } else {
        throw Exception(
          'Error validating OTP: ${response.statusCode} - ${response.body}',
        );
      }
    } on FirebaseException catch (e) {
      throw Exception('OTP validation failed: $e');
    }
  }
}

