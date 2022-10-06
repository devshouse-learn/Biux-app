import 'package:biux/config/strings.dart';
import 'package:biux/data/models/response.dart';
import 'package:biux/data/models/user.dart';
import 'package:biux/data/repositories/users/user_firebase_repository.dart';
import 'package:biux/data/local_storage/localstorage.dart';
import 'package:biux/utils/snackbar_utils.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:http/http.dart' as http;
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:http/http.dart';

class AuthenticationRepository {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  static Future<User?> signInWithGoogle({required BuildContext context}) async {
    FirebaseAuth auth = FirebaseAuth.instance;
    User? user;
    if (kIsWeb) {
      GoogleAuthProvider authProvider = GoogleAuthProvider();
      try {
        final UserCredential userCredential =
            await auth.signInWithPopup(authProvider);
        user = userCredential.user;
      } catch (e) {}
    } else {
      final GoogleSignIn googleSignIn = GoogleSignIn();
      final GoogleSignInAccount? googleSignInAccount =
          await googleSignIn.signIn();
      if (googleSignInAccount != null) {
        final GoogleSignInAuthentication googleSignInAuthentication =
            await googleSignInAccount.authentication;
        final AuthCredential credential = GoogleAuthProvider.credential(
          accessToken: googleSignInAuthentication.accessToken,
          idToken: googleSignInAuthentication.idToken,
        );
        try {
          final UserCredential userCredential =
              await auth.signInWithCredential(credential);
          return user = userCredential.user;
        } on FirebaseAuthException catch (e) {
          if (e.code == 'account-exists-with-different-credential') {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBarUtils.customSnackBar(
                content:
                    'The account already exists with a different credential',
              ),
            );
          } else if (e.code == 'invalid-credential') {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBarUtils.customSnackBar(
                content:
                    'Error occurred while accessing credentials. Try again.',
              ),
            );
          }
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBarUtils.customSnackBar(
              content: 'Error occurred using Google Sign In. Try again.',
            ),
          );
        }
      }
    }
    return user;
  }

  static Future<void> signOut({required BuildContext context}) async {
    final GoogleSignIn googleSignIn = GoogleSignIn();
    try {
      if (!kIsWeb) {
        await googleSignIn.signOut();
      }
      await FirebaseAuth.instance.signOut();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBarUtils.customSnackBar(
          content: 'Error signing out. Try again.',
        ),
      );
    }
  }

  Future<ResponseRepo> login(String email, String password) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      final user = userCredential.user;
      return ResponseRepo(
        message: '',
        status: true,
        statusCode: 200,
      );
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        return ResponseRepo(
          message: AppStrings.userNotFound,
          status: false,
          statusCode: 500,
        );
      } else if (e.code == 'wrong-password') {
        return ResponseRepo(
          message: AppStrings.wrongPassword,
          status: false,
          statusCode: 500,
        );
      } else if (e.code == 'invalid-email') {
        return ResponseRepo(
          message: AppStrings.invalidEmail,
          status: false,
          statusCode: 500,
        );
      } else {
        return ResponseRepo(
          message: AppStrings.msgErrorLogin,
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
          message: AppStrings.invalidEmail,
          status: false,
          statusCode: 500,
        );
      } else if (e.code == 'user-not-found') {
        return ResponseRepo(
          message: AppStrings.userNotFound,
          status: false,
          statusCode: 500,
        );
      } else {}
    }
  }

  static Future<LoginResult> signInWithFacebook() async {
    try {
      LoginResult result = await FacebookAuth.instance.login();
      return result;
    } catch (e) {
      return LoginResult(status: LoginStatus.failed);
    }
  }

  static Future<UserCredential?> signInWithCredential({
    required LoginResult result,
  }) async {
    try {
      final OAuthCredential credential =
          FacebookAuthProvider.credential(result.accessToken!.token);
      final user = await FirebaseAuth.instance.signInWithCredential(credential);
      return user;
    } catch (e) {
      return null;
    }
  }

  static Future<Response> getDataFacebook(
      {required AccessToken accessToken}) async {
    try {
      final graphResponse = await http.get(
        Uri.parse(
          AppStrings.urlFacebookLogin(
            token: accessToken.token,
          ),
        ),
      );
      return graphResponse;
    } catch (e) {
      return http.Response(
        'body',
        500,
      );
    }
  }

  Future<ResponseRepo> registerUser({required BiuxUser user}) async {
    try {
      UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: user.email,
        password: user.password,
      );
      final String uid = userCredential.user!.uid;
      final BiuxUser biuxUser = BiuxUser(
        id: uid,
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
        names: user.names,
        password: user.password,
        photo: user.photo,
        premium: user.premium,
        profileCover: user.profileCover,
        situationAccident: user.situationAccident,
        surnames: user.surnames,
        token: user.token,
        userName: user.userName,
        whatsapp: user.whatsapp,
      );
      await UserFirebaseRepository().registerUser(user: biuxUser);
      LocalStorage().saveKey(user.password);
      LocalStorage().saveUserEmail(user.email);
      LocalStorage().saveUserId(uid);
      return ResponseRepo(
        message: biuxUser.id,
        status: true,
        statusCode: 200,
      );
    } on FirebaseAuthException catch (e) {
      if (e.code == 'email-already-in-use') {
        return ResponseRepo(
          message: AppStrings.emailAlreadyUse,
          statusCode: 500,
          status: false,
        );
      } else {
        return ResponseRepo(
          message: AppStrings.errorRegisterUser,
          status: false,
          statusCode: 500,
        );
      }
    }
  }
}
