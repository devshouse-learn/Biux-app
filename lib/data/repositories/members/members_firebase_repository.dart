import 'package:biux/data/models/member.dart';
import 'package:biux/data/repositories/members/members_repository_abstract.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MembersFirebaseRepository extends MembersRepositoryAbstract {
  static final collection = 'members';
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  @override
  Future<Member> deleteMember(Member member) async {
    try {
      await firestore.collection(collection).doc(member.id.toString()).delete();
      final response = await firestore
          .collection(collection)
          .where('id', isEqualTo: member.id.toString())
          .get();
      return Member.fromJson(
        response.docs.first.data(),
      );
    } catch (e) {
      return Member();
    }
  }

  @override
  Future<Member> getApproved(int id, int userId) async {
    try {
      final response = await firestore
          .collection(collection)
          .where('id', isEqualTo: id.toString())
          .where('userId', isEqualTo: userId.toString())
          .get();
      return Member.fromJson(
        response.docs.first.data(),
      );
    } catch (e) {
      return Member();
    }
  }

  @override
  Future<List<Member>> getMembers(int offset) async {
    try {
      final result = await firestore.collection(collection).get();
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
  Future<List<Member>> getMembersGroup(int id, int offset) async {
    try {
      final result = await firestore
          .collection(collection)
          .where('groupId', isEqualTo: id)
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
  Future<List<Member>> getMyGroups(int id) async {
    try {
      final result = await firestore
          .collection(collection)
          .where('userId', isEqualTo: id)
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
  Future<Member> getMyGroupsUser(int id) async {
    try {
      final response = await firestore
          .collection(collection)
          .where('adminId', isEqualTo: id.toString())
          .get();
      return Member.fromJson(
        response.docs.first.data(),
      );
    } catch (e) {
      return Member();
    }
  }

  @override
  Future<bool> joinGroups(int userId, int groupId) {
    // TODO: implement joinGroups
    throw UnimplementedError();
  }
}
