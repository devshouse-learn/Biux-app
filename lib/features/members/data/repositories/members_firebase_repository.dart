import 'package:biux/features/members/data/models/member.dart';
import 'package:biux/features/members/domain/repositories/members_repository_abstract.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:biux/core/config/strings.dart';
import 'package:biux/core/services/app_logger.dart';
import 'package:biux/core/exceptions/authorization_exceptions.dart';

class MembersFirebaseRepository extends MembersRepositoryAbstract {
  static final subcollection = 'members';
  static final collection = 'groups';
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  /// ALTO: Validar entrada y agregar logging
  @override
  Future<Member> deleteMember(String memberId, String groupId) async {
    try {
      if (memberId.isEmpty || groupId.isEmpty) {
        throw ValidationException('ids', 'Member ID y Group ID son requeridos');
      }

      await firestore
          .collection(collection)
          .doc(groupId)
          .collection(subcollection)
          .doc(memberId)
          .delete();

      final response = await firestore
          .collection(collection)
          .where('id', isEqualTo: memberId)
          .get();

      if (response.docs.isEmpty) {
        return Member();
      }

      AppLogger.info('Miembro eliminado: $memberId', tag: 'MembersRepository');
      return Member.fromJson(response.docs.first.data());
    } on ValidationException catch (e) {
      AppLogger.warning('Validación fallida: ${e.message}',
          tag: 'MembersRepository');
      return Member();
    } on FirebaseException catch (e) {
      AppLogger.error('Error eliminando miembro: $e',
          tag: 'MembersRepository', error: e);
      return Member();
    }
  }

  /// ALTO: Validar entrada y agregar logging
  @override
  Future<Member> getApproved(String userId, String groupId) async {
    try {
      if (userId.isEmpty || groupId.isEmpty) {
        throw ValidationException('ids', 'User ID y Group ID son requeridos');
      }

      final response = await firestore
          .collection(collection)
          .doc(groupId)
          .collection(subcollection)
          .where('userId', isEqualTo: userId)
          .get();

      if (response.docs.isEmpty) {
        return Member();
      }

      return Member.fromJson(response.docs.first.data());
    } on ValidationException catch (e) {
      AppLogger.warning('Validación fallida: ${e.message}',
          tag: 'MembersRepository');
      return Member();
    } on FirebaseException catch (e) {
      AppLogger.error('Error obteniendo miembro aprobado: $e',
          tag: 'MembersRepository', error: e);
      return Member();
    }
  }

  /// ALTO: Agregar logging
  @override
  Future<List<Member>> getMembers() async {
    try {
      final result = await firestore.collectionGroup(subcollection).get();
      AppLogger.debug('Miembros encontrados: ${result.docs.length}',
          tag: 'MembersRepository');
      return result.docs.map((e) => Member.fromJson(e.data())).toList();
    } on FirebaseException catch (e) {
      AppLogger.error('Error obteniendo miembros: $e',
          tag: 'MembersRepository', error: e);
      return List.empty();
    }
  }

  /// ALTO: Validar entrada y agregar logging
  Future<List<Member>> getMyMembersGroup(String groupId) async {
    try {
      if (groupId.isEmpty) {
        throw ValidationException('groupId', 'Group ID no puede estar vacío');
      }

      final result = await firestore
          .collection(collection)
          .doc(groupId)
          .collection(subcollection)
          .get();

      AppLogger.debug('Miembros del grupo: ${result.docs.length}',
          tag: 'MembersRepository');

      return result.docs.map((e) => Member.fromJson(e.data())).toList();
    } on ValidationException catch (e) {
      AppLogger.warning('Validación fallida: ${e.message}',
          tag: 'MembersRepository');
      return List.empty();
    } on FirebaseException catch (e) {
      AppLogger.error('Error obteniendo miembros del grupo: $e',
          tag: 'MembersRepository', error: e);
      return List.empty();
    }
  }

  /// ALTO: Validar entrada y agregar logging
  @override
  Future<List<Member>> getMyGroups(String groupId) async {
    try {
      if (groupId.isEmpty) {
        throw ValidationException('groupId', 'Group ID no puede estar vacío');
      }

      final result = await firestore
          .collection(collection)
          .where('id', isEqualTo: groupId)
          .get();

      AppLogger.debug('Grupos encontrados: ${result.docs.length}',
          tag: 'MembersRepository');

      return result.docs.map((e) => Member.fromJson(e.data())).toList();
    } on ValidationException catch (e) {
      AppLogger.warning('Validación fallida: ${e.message}',
          tag: 'MembersRepository');
      return List.empty();
    } on FirebaseException catch (e) {
      AppLogger.error('Error obteniendo mis grupos: $e',
          tag: 'MembersRepository', error: e);
      return List.empty();
    }
  }

  @override
  Future<String> joinGroups(
    String groupId,
    int numberMember,
    Member member,
  ) async {
    String docId = '';
    try {
      await firestore
          .collection(collection)
          .doc(groupId)
          .collection(subcollection)
          .add(member.toJson())
          .then((DocumentReference doc) {
            docId = doc.id;
            firestore
                .collection(collection)
                .doc(groupId)
                .collection(subcollection)
                .doc(docId)
                .update({AppStrings.idText: docId});
          });
      await firestore.collection(collection).doc(groupId).update({
        'numberMembers': numberMember + 1,
      });
      return docId;
    } on FirebaseException catch (e) {
      return '';
    }
  }

  Future<bool> leaveGroups(String id, int numberMember, String groupId) async {
    try {
      await firestore
          .collection(collection)
          .doc(groupId)
          .collection(subcollection)
          .doc(id)
          .delete();
      await firestore.collection(collection).doc(groupId).update({
        'numberMembers': numberMember - 1,
      });
      return true;
    } on FirebaseException catch (e) {
      return false;
    }
  }
}

