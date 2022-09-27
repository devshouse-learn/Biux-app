import 'dart:async';
import 'package:biux/data/models/response.dart';
import 'package:biux/data/models/user_membership.dart';
import 'package:biux/data/models/user.dart';
import 'dart:io';
import 'package:biux/data/repositories/users/user_repository_abstract.dart';
import 'package:biux/data/local_storage/localstorage.dart';
import 'package:biux/utils/firebase_utils.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserFirebaseRepository extends UserRepositoryAbstract {
  static final collection = 'users';
  static final collectionMembership = 'usersMembership';
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  FirebaseUtils firebaseUtils = FirebaseUtils();

  @override
  Future<UserMembership> getMembership(UserMembership userMembership) async {
    try {
      final response = await firestore
          .collection(collection)
          .where('id', isEqualTo: userMembership.id)
          .get();
      return UserMembership.fromJsonMap(
        response.docs.first.data(),
      );
    } catch (e) {
      return UserMembership();
    }
  }

  @override
  Future<List<UserMembership>> getMembershipList() async {
    try {
      final result = await firestore
          .collection(collectionMembership)
          .where('stateMembership', isEqualTo: true)
          .get();
      return result.docs
          .map(
            (e) => UserMembership.fromJsonMap(
              e.data(),
            ),
          )
          .toList();
    } catch (e) {
      return List.empty();
    }
  }

  @override
  Future<UserMembership> getMembershipPerson(String id) async {
    try {
      final result = await firestore
          .collection(collectionMembership)
          .where('stateMembership', isEqualTo: true)
          .where('userId', isEqualTo: id)
          .get();
      return UserMembership.fromJsonMap(
        result.docs.first.data(),
      );
    } catch (e) {
      return UserMembership();
    }
  }

  @override
  Future<BiuxUser> getPerson(String nUsername) async {
    try {
      final result = await firestore
          .collection(collection)
          .where('user', isEqualTo: nUsername)
          .get();
      return BiuxUser.fromJsonMap(
        result.docs.first.data(),
      );
    } catch (e) {
      return BiuxUser();
    }
  }

  @override
  Future<BiuxUser> getUser(String username) async {
    try {
      final result = await firestore
          .collection(collection)
          .where('userName', isEqualTo: username)
          .get();
      return BiuxUser.fromJsonMap(
        result.docs.first.data(),
      );
    } catch (e) {
      return BiuxUser();
    }
  }

  Future<BiuxUser> getUserById(String id) async {
    try {
      final result = await firestore
          .collection(collection)
          .where('id', isEqualTo: id)
          .get();
      return BiuxUser.fromJsonMap(
        result.docs.first.data(),
      );
    } catch (e) {
      return BiuxUser();
    }
  }

  @override
  Future<List<BiuxUser>> getUsernames() async {
    try {
      final result = await firestore
          .collection(collection)
          .where('stateMembership', isEqualTo: true)
          .get();
      return result.docs
          .map(
            (e) => BiuxUser.fromJsonMap(
              e.data(),
            ),
          )
          .toList();
    } catch (e) {
      return List.empty();
    }
  }

  @override
  Future<List<BiuxUser>> getUsers(int limit, int offset) async {
    try {
      final result = await firestore.collection(collection).get();
      return result.docs
          .map(
            (e) => BiuxUser.fromJsonMap(
              e.data(),
            ),
          )
          .toList();
    } catch (e) {
      return List.empty();
    }
  }

  @override
  Future<BiuxUser> getValidationEmails(String email) async {
    try {
      final result = await firestore
          .collection(collection)
          .where('email', isEqualTo: email)
          .get();
      return BiuxUser.fromJsonMap(
        result.docs.first.data(),
      );
    } catch (e) {
      return BiuxUser();
    }
  }

  @override
  Future<BiuxUser> getValidationFacebook(String facebook) async {
    try {
      final result = await firestore
          .collection(collection)
          .where('facebook', isEqualTo: facebook)
          .get();
      return BiuxUser.fromJsonMap(
        result.docs.first.data(),
      );
    } catch (e) {
      return BiuxUser();
    }
  }

  @override
  Future<BiuxUser> getValidationUser(String userName) async {
    try {
      final result = await firestore
          .collection(collection)
          .where('userName', isEqualTo: userName)
          .get();
      return BiuxUser.fromJsonMap(
        result.docs.first.data(),
      );
    } catch (e) {
      return BiuxUser();
    }
  }

  @override
  Future<bool> login(String biuxUser, String password) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: biuxUser,
        password: password,
      );
      final user = userCredential.user;
      return true;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        return false;
      } else if (e.code == 'wrong-password') {
        return false;
      } else if (e.code == 'invalid-email') {
        return false;
      } else {
        return false;
      }
    }
  }

  @override
  Future sendEmail(String user) async {
    try {
      await _auth.sendPasswordResetEmail(email: user);
    } on FirebaseAuthException catch (e) {
      print(e);
      if (e.code == 'invalid-email') {
      } else if (e.code == 'user-not-found') {
      } else {}
    }
  }

  @override
  Future<BiuxUser> updateUser(BiuxUser user) async {
    try {
      await firestore.collection(collection).doc(user.id).update(
            user.toJson(),
          );
      final response = await this.getUserId(user.id);
      return response;
    } catch (e) {
      return BiuxUser();
    }
  }

  Future<BiuxUser> getUserId(String id) async {
    try {
      final response = await firestore
          .collection(collection)
          .where(
            'id',
            isEqualTo: id,
          )
          .get();
      return BiuxUser.fromJsonMap(
        response.docs.first.data(),
      );
    } catch (e) {
      return BiuxUser();
    }
  }

  @override
  Future uploadPhoto(
    String id,
    File filePhoto,
    BiuxUser user,
  ) async {
    try {
      final url = await firebaseUtils.uploadImage(
        image: filePhoto,
        nameImage: 'PhotoUser',
        imageFolder: id,
      );
      final BiuxUser biuxUser = BiuxUser(
        cellphone: user.cellphone,
        cityId: user.cityId,
        dateBirth: user.dateBirth,
        email: user.email,
        facebook: user.facebook,
        followerS: user.followerS,
        followers: user.followers,
        following: user.following,
        gender: user.gender,
        groupId: user.groupId,
        id: user.id,
        instagram: user.instagram,
        modality: user.modality,
        names: user.names,
        password: user.password,
        photo: url,
        premium: user.premium,
        profileCover: user.profileCover,
        situationAccident: user.situationAccident,
        surnames: user.surnames,
        token: user.token,
        userName: user.userName,
        whatsapp: user.whatsapp,
      );
      await this.updateUser(biuxUser);
    } catch (e) {}
  }

  @override
  Future uploadProfileCover(String id, File fileProfileCover) async {
    try {
      FirebaseUtils firebaseUtils = FirebaseUtils();
      final url = firebaseUtils.uploadImage(
        image: fileProfileCover,
        nameImage: 'ProfileCover',
        imageFolder: 'ProfileCover',
      );
    } catch (e) {}
  }

  Future<ResponseRepo> registerUser({required BiuxUser user}) async {
    try {
      await firestore.collection(collection).doc(user.id).set(
            user.toJson(),
          );
      LocalStorage().saveUserEmail(user.email);
      LocalStorage().saveUserId(user.id);
      return ResponseRepo(
        status: true,
        message: '',
        statusCode: 200,
      );
    } catch (e) {
      return ResponseRepo(
        status: false,
        message: '',
        statusCode: 500,
      );
    }
  }
}
