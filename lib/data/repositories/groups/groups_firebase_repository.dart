import 'package:biux/config/strings.dart';
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
  Future<bool> deleteGroup(Group group) async {
    try {
      await firestore.collection(collection).doc(group.id).delete();
      return true;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<List<Group>> getGroups() async {
    try {
      final result = await firestore
          .collection(collection)
          .get();
      return result.docs
          .map(
            (e) => Group.fromJson(
              json: e.data(),
            ),
          )
          .toList();
    } catch (e) {
      return List.empty();
    }
  }

  @override
  Future<List<Group>> getFilterGroups(String cityAdmin) async {
    try {
      final result = await firestore
          .collection(collection)
          .where('cityAdmin', isEqualTo: cityAdmin)
          .get();
      return result.docs
          .map(
            (e) => Group.fromJson(
              json: e.data(),
            ),
          )
          .toList();
    } catch (e) {
      return List.empty();
    }
  }

  @override
  Future<List<Member>> getMembers(String id) async {
    try {
      final result = await firestore
          .collection(collection)
          .doc(id)
          .collection(subCollection)
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
  Future<List<String>> getNamesGroups() async {
    try {
      final result = await firestore.collection(collection).get();
      return result.docs
          .map(
            (e) => e.data()['name'] as String,
          )
          .toList();
    } catch (e) {
      return List.empty();
    }
  }

  @override
  Future<Group> getSpecificGroup(String id) async {
    try {
      final result = await firestore
          .collection(collection)
          .where('id', isEqualTo: id)
          .get();
      return Group.fromJson(
        json: result.docs.first.data(),
      );
    } catch (e) {
      return Group(id: '');
    }
  }

  @override
  Future<bool> updateGroup(Group group) async {
    try {
      await firestore
          .collection(collection)
          .doc(group.id)
          .update(group.toJson());
      return true;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<bool> uploadGroupProfileCover({
    required String id,
    required File fileProfileCover,
  }) async {
    try {
      FirebaseUtils firebaseUtils = FirebaseUtils();
      final url = await firebaseUtils.uploadImage(
        image: fileProfileCover,
        nameImage: 'fileProfileCover',
        imageFolder: 'fileProfileCover',
      );
      Group group = await this.getSpecificGroup(id);
      final groupUpdate = Group(
        id: group.id,
        cityId: group.cityId,
        description: group.description,
        profileCover: url,
        name: group.name,
        type: group.type,
        active: group.type,
        adminId: group.adminId,
        cityAdmin: group.cityAdmin,
        facebook: group.facebook,
        instagram: group.instagram,
        logo: group.logo,
        logoADM: group.logoADM,
        modality: group.modality,
        numberMembers: group.numberMembers,
        numberRoads: group.numberRoads,
        profileCoverADM: group.profileCoverADM,
        whatsapp: group.whatsapp,
      );
      await this.updateGroup(groupUpdate);
      return true;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<bool> uploadLogoGroup({
    required String id,
    required File filePhoto,
  }) async {
    try {
      FirebaseUtils firebaseUtils = FirebaseUtils();
      final url = await firebaseUtils.uploadImage(
        image: filePhoto,
        nameImage: 'filePhoto',
        imageFolder: 'filePhoto',
      );
      Group group = await this.getSpecificGroup(id);
      final groupUpdate = Group(
        id: group.id,
        cityId: group.cityId,
        description: group.description,
        profileCover: group.profileCover,
        name: group.name,
        type: group.type,
        active: group.type,
        adminId: group.adminId,
        cityAdmin: group.cityAdmin,
        facebook: group.facebook,
        instagram: group.instagram,
        logo: url,
        logoADM: group.logoADM,
        modality: group.modality,
        numberMembers: group.numberMembers,
        numberRoads: group.numberRoads,
        profileCoverADM: group.profileCoverADM,
        whatsapp: group.whatsapp,
      );
      await this.updateGroup(groupUpdate);
      return true;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<bool> createGroup(Group group, File logo, File profileCover) async {
    try {
      await firestore.collection(collection).add(group.toJson()).then(
        (DocumentReference doc) async {
          String docId = doc.id;
          final logoUrl = await updateImageLogo(logo, docId);
          final profileCoverUrl = await updateImageProfileCover(profileCover, docId);
          firestore.collection(collection).doc(docId).update(
            {
              AppStrings.logoText: logoUrl,
              AppStrings.profileCoverText: profileCoverUrl,
              AppStrings.idText: docId,
            },
          );
        },
      );
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<String> updateImageLogo(File filePhoto, String id) async {
    FirebaseUtils firebaseUtils = FirebaseUtils();
    final url = await firebaseUtils.uploadImage(
      image: filePhoto,
      nameImage: 'filePhoto',
      imageFolder: 'filePhoto',
    );

    return url;
  }

  Future<String> updateImageProfileCover(File fileProfileCover, String id) async {
    FirebaseUtils firebaseUtils = FirebaseUtils();
    final url = await firebaseUtils.uploadImage(
      image: fileProfileCover,
      nameImage: 'fileProfileCover',
      imageFolder: 'fileProfileCover',
    );

    return url;
  }
}
