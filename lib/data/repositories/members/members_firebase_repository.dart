import 'package:biux/data/models/member.dart';
import 'package:biux/data/repositories/members/members_repository_abstract.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:biux/core/config/strings.dart';

class MembersFirebaseRepository extends MembersRepositoryAbstract {
  static final subcollection = 'members';
  static final collection = 'groups';
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  @override
  Future<Member> deleteMember(String memberId, String groupId) async {
    try {
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
      return Member.fromJson(
        response.docs.first.data(),
      );
    } catch (e) {
      return Member();
    }
  }

  @override
  Future<Member> getApproved(String userId, String groupId) async {
    try {
      final response = await firestore
          .collection(collection)
          .doc(groupId)
          .collection(subcollection)
          .where('userId', isEqualTo: userId)
          .get();
      return Member.fromJson(
        response.docs.first.data(),
      );
    } catch (e) {
      return Member();
    }
  }

  @override
  Future<List<Member>> getMembers() async {
    try {
      final result = await firestore.collectionGroup(subcollection).get();
      return result.docs
          .map(
            (e) => Member.fromJson(
              e.data(),
            ),
          )
          .toList();
    } catch (e) {
      return List.empty();
    }
  }

  Future<List<Member>> getMyMembersGroup(String groupId) async {
    try {
      final result = await firestore
          .collection(collection)
          .doc(groupId)
          .collection(subcollection)
          .get();
      return result.docs
          .map(
            (e) => Member.fromJson(
              e.data(),
            ),
          )
          .toList();
    } catch (e) {
      return List.empty();
    }
  }

  @override
  Future<List<Member>> getMyGroups(String groupId) async {
    try {
      final result = await firestore
          .collection(collection)
          .where('id', isEqualTo: groupId)
          .get();
      return result.docs
          .map(
            (e) => Member.fromJson(
              e.data(),
            ),
          )
          .toList();
    } catch (e) {
      return List.empty();
    }
  }

  @override
  Future<String> joinGroups(
      String groupId, int numberMember, Member member) async {
    String docId = '';
    try {
      await firestore
          .collection(collection)
          .doc(groupId)
          .collection(subcollection)
          .add(member.toJson())
          .then(
        (DocumentReference doc) {
          docId = doc.id;
          firestore
              .collection(collection)
              .doc(groupId)
              .collection(subcollection)
              .doc(docId)
              .update(
            {
              AppStrings.idText: docId,
            },
          );
        },
      );
      await firestore
          .collection(collection)
          .doc(groupId)
          .update({'numberMembers': numberMember + 1});
      return docId;
    } catch (e) {
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
      await firestore
          .collection(collection)
          .doc(groupId)
          .update({'numberMembers': numberMember - 1});
      return true;
    } catch (e) {
      return false;
    }
  }
}
