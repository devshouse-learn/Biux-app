import 'package:biux/core/services/local_storage.dart';
import 'package:biux/core/models/common/response.dart';
import 'package:biux/features/users/data/models/user.dart';
import 'package:biux/features/users/data/repositories/user_firebase_repository.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthenticationRepository {
  final FirebaseAuth _auth = FirebaseAuth.instance;

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
        password: user.password,
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
}
