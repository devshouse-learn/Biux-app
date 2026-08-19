import 'dart:async';
import 'package:biux/core/config/strings.dart';
import 'package:biux/core/models/common/response.dart';
import 'package:biux/features/members/data/models/user_membership.dart';
import 'package:biux/features/users/data/models/user.dart';
import 'dart:io';
import 'package:biux/core/utils/firebase_utils.dart';
import 'package:biux/features/users/domain/repositories/user_repository_abstract.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import "package:flutter/foundation.dart";
import 'package:biux/core/exceptions/authorization_exceptions.dart';
import 'package:biux/core/services/authorization_service.dart';
import 'package:biux/core/services/app_logger.dart';

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
      return UserMembership.fromJsonMap(response.docs.first.data());
    } on FirebaseException catch (e) {
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
          .map((e) => UserMembership.fromJsonMap(e.data()))
          .toList();
    } on FirebaseException catch (e) {
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
      return UserMembership.fromJsonMap(result.docs.first.data());
    } on FirebaseException catch (e) {
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
      return BiuxUser.fromJsonMap(result.docs.first.data());
    } on FirebaseException catch (e) {
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
      return BiuxUser.fromJsonMap(result.docs.first.data());
    } on FirebaseException catch (e) {
      return BiuxUser();
    }
  }

  Future<BiuxUser> getUserById(String id) async {
    try {
      final result = await firestore
          .collection(collection)
          .where('id', isEqualTo: id)
          .get();
      return BiuxUser.fromJsonMap(result.docs.first.data());
    } on FirebaseException catch (e) {
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
      return result.docs.map((e) => BiuxUser.fromJsonMap(e.data())).toList();
    } on FirebaseException catch (e) {
      return List.empty();
    }
  }

  @override
  Future<List<BiuxUser>> getUsers(int limit, int offset) async {
    try {
      // CRÍTICO #1: Verificar que solo admins puedan listar todos los usuarios
      final authService = AuthorizationService();
      await authService.requireCanListUsers();

      AppLogger.info('Listado de usuarios iniciado por admin', tag: 'getUsers');

      // Implementar paginación correctamente en Firestore
      // Obtener con límite mayor para hacer skip en cliente
      final result = await firestore
          .collection(collection)
          .limit(limit + offset)
          .get();

      // Hacer skip en cliente (offset)
      final paginatedDocs = result.docs.skip(offset).take(limit).toList();

      AppLogger.info(
        'Se obtuvieron ${paginatedDocs.length} usuarios (limit: $limit, offset: $offset)',
      );
      return paginatedDocs.map((e) => BiuxUser.fromJsonMap(e.data())).toList();
    } on UnauthorizedException catch (e) {
      AppLogger.warning(
        'Intento de acceso no autorizado a getUsers: ${e.message}',
      );
      rethrow;
    } on NotAuthenticatedException catch (e) {
      AppLogger.warning('Usuario no autenticado en getUsers: ${e.message}');
      rethrow;
    } on FirebaseException catch (e) {
      AppLogger.error('Error de Firebase en getUsers: ${e.message}');
      return List.empty();
    } catch (e) {
      AppLogger.error('Error inesperado en getUsers: $e');
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
      return BiuxUser.fromJsonMap(result.docs.first.data());
    } on FirebaseException catch (e) {
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
      return BiuxUser.fromJsonMap(result.docs.first.data());
    } on FirebaseException catch (e) {
      return BiuxUser();
    }
  }

  @override
  Future<bool> getValidationUserName(String userName) async {
    try {
      final result = await firestore
          .collection(collection)
          .where('userName', isEqualTo: userName)
          .get();
      if (result.docs.isEmpty) {
        return false;
      } else {
        return true;
      }
    } on FirebaseException catch (e) {
      return false;
    }
  }

  @override
  Future<bool> login(String biuxUser, String password) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: biuxUser,
        password: password,
      );
      userCredential.user;
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
      AppLogger.error('Error al enviar reset email', error: e, tag: 'UserRepo');
      if (e.code == 'invalid-email') {
      } else if (e.code == 'user-not-found') {
      } else {}
    }
  }

  @override
  Future<BiuxUser> updateUser(BiuxUser user) async {
    try {
      AppLogger.debug('Actualizando usuario ${user.id}', tag: 'UserRepo');

      await firestore.collection(collection).doc(user.id).update({
        AppStrings.fullName: user.fullName,
        AppStrings.whatsappLowercase: user.whatsapp,
        AppStrings.cityId: user.cityId.toJson(), // Serializar cityId como JSON
        AppStrings.description: user.description,
      });

      final response = await this.getUserId(user.id);
      return response;
    } on FirebaseException catch (e) {
      AppLogger.error(
        'Error al actualizar usuario en Firestore',
        error: e,
        tag: 'UserRepo',
      );
      rethrow; // Propagar el error para que se capture en la pantalla
    }
  }

  Future<BiuxUser> getUserId(String id) async {
    try {
      final response = await firestore
          .collection(collection)
          .where('id', isEqualTo: id)
          .get();
      return BiuxUser.fromJsonMap(response.docs.first.data());
    } on FirebaseException catch (e) {
      return BiuxUser();
    }
  }

  @override
  Future uploadPhoto(String id, File filePhoto) async {
    try {
      final url = await firebaseUtils.uploadImage(
        image: filePhoto,
        nameImage: 'PhotoUser',
        imageFolder: id,
      );
      await firestore.collection(collection).doc(id).update({
        AppStrings.photoText: url,
      });
      final response = await this.getUserId(id);
      return response;
    } on FirebaseException catch (e) {
      AppLogger.error(
        'Error al obtener usuario por ID',
        error: e,
        tag: 'UserRepo',
      );
    }
  }

  @override
  Future uploadProfileCover(String id, File fileProfileCover) async {
    try {
      FirebaseUtils firebaseUtils = FirebaseUtils();
      final downloadUrl = await firebaseUtils.uploadImage(
        image: fileProfileCover,
        nameImage: 'ProfileCover',
        imageFolder: 'ProfileCover',
      );

      // Actualizar el campo profileCover en Firestore con la URL descargada
      if (downloadUrl.isNotEmpty) {
        await firestore.collection(collection).doc(id).update({
          'profileCover': downloadUrl,
        });
      }
    } on FirebaseException catch (e) {
      AppLogger.error(
        'Error al subir foto de portada',
        error: e,
        tag: 'UserRepo',
      );
    }
  }

  Future<ResponseRepo> registerUser({required BiuxUser user}) async {
    try {
      await firestore.collection(collection).doc(user.id).set(user.toJson());
      // LocalStorage().saveUserEmail(user.email);
      // LocalStorage().saveUserId(user.id);
      return ResponseRepo(status: true, message: '', statusCode: 200);
    } on FirebaseException catch (e) {
      return ResponseRepo(status: false, message: '', statusCode: 500);
    }
  }
}
