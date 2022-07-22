import 'package:biux/data/models/member.dart';
import 'package:biux/data/models/group.dart';
import 'dart:io';

import 'package:biux/data/repositories/groups/groups_repository_abstract.dart';
import 'package:biux/utils/firebase_utils.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class GroupsFirebaseRepository extends GroupsRepositoryAbstract {
  static final collection = 'groups';
  static final subCollection = 'members';
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  @override
  Future<Member> deleteGroup(Group group) async {
    try {
      await firestore.collection(collection).doc(group.id.toString()).delete();
      final response = await firestore
          .collection(collection)
          .where('id', isEqualTo: group.id.toString())
          .get();
      return Member.fromJson(
        response.docs.first.data(),
      );
    } catch (e) {
      return Member();
    }
  }

  @override
  Future<List<Group>> getGroups(String cityId) async {
    try {
      final result = await firestore.collection(collection).get();
      return result.docs
          .map(
            (e) => Group.fromJson(
              e.data(),
            ),
          )
          .toList();
    } catch (e) {
      return List.empty();
    }
  }

  @override
  Future<Group> getMembers(id) async {
    try {
      final result = await firestore
          .collection(collection)
          .doc(id)
          .collection(subCollection)
          .get();
      return Group.fromJson(
        result.docs.first.data(),
      );
    } catch (e) {
      return Group();
    }
  }

  @override
  Future<List<Group>> getNamesGroups() async {
    try {
      final result = await firestore.collection(collection).get();
      return result.docs
          .map(
            (e) => Group.fromJson(
              e.data(),
            ),
          )
          .toList();
    } catch (e) {
      return List.empty();
    }
  }

  @override
  Future<Group> getSpecificGroup(int id) async {
    try {
      final result = await firestore
          .collection(collection)
          .where('id', isEqualTo: id)
          .get();
      return Group.fromJson(
        result.docs.first.data(),
      );
    } catch (e) {
      return Group();
    }
  }

  @override
  Future<Group> updateGroup(Group group) async {
    try {
      await firestore
          .collection(collection)
          .doc(group.id.toString())
          .update(group.toJson());
      final response = await firestore
          .collection(collection)
          .where('id', isEqualTo: group.id.toString())
          .get();
      return Group.fromJson(
        response.docs.first.data(),
      );
    } catch (e) {
      return Group();
    }
  }

  @override
  Future uploadGroupProfileCover(int id, File fileProfileCover) async {
    FirebaseUtils firebaseUtils = FirebaseUtils();
    final url = await firebaseUtils.uploadImage(
      image: fileProfileCover,
      nameImage: 'fileProfileCover',
      imageFolder: 'fileProfileCover',
    );
  }

  @override
  Future uploadLogoGroup(int id, File filePhoto) async {
    FirebaseUtils firebaseUtils = FirebaseUtils();
    final url = await firebaseUtils.uploadImage(
      image: filePhoto,
      nameImage: 'filePhoto',
      imageFolder: 'filePhoto',
    );
  }
}
