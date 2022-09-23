import 'package:biux/data/models/group.dart';
import 'package:biux/data/models/road.dart';
import 'package:biux/data/models/competitor_road.dart';
import 'package:biux/data/models/user.dart';
import 'dart:io';
import 'package:biux/data/repositories/roads/roads_repository_abstract.dart';
import 'package:biux/utils/firebase_utils.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RoadsFirebaseRepository extends RoadsRepositoryAbstract {
  static final collection = 'roads';
  static final collectionCompetitor = 'competitorRoad';
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  @override
  Future<bool> deleteCompetitorRoad({
    required CompetitorRoad competitorRoad,
    required String roadId,
  }) async {
    try {
      await firestore
          .collection(collection)
          .doc(roadId)
          .collection(collectionCompetitor)
          .doc(competitorRoad.userId)
          .delete();

      return true;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<bool> deleteRoad(Road road) async {
    try {
      await firestore.collection(collection).doc(road.id).delete();
      return true;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<List<CompetitorRoad>> getListParticipantRoad(String id) async {
    try {
      final result = await firestore
          .collection(collection)
          .doc(id)
          .collection(collectionCompetitor)
          .get();
      return result.docs
          .map(
            (e) => CompetitorRoad.fromJsonMap(
              json: e.data(),
            ),
          )
          .toList();
    } catch (e) {
      return List.empty();
    }
  }

  @override
  Future<CompetitorRoad> getParticipantRoad(
      {required String id, required String userId}) async {
    try {
      final response = await firestore
          .collection(collection)
          .doc(id)
          .collection(collectionCompetitor)
          .where('userId', isEqualTo: userId)
          .get();
      return CompetitorRoad.fromJsonMap(
        json: response.docs.first.data(),
      );
    } catch (e) {
      return CompetitorRoad();
    }
  }

  @override
  Future<List<Road>> getRoadsByCity({
    int limit = 0,
    int offset = 0,
    required String cityId,
  }) async {
    try {
      final result = await firestore
          .collection(collection)
          .where('cityId', isEqualTo: cityId)
          .get();
      return result.docs
          .map(
            (e) => Road.fromJson(
              json: e.data(),
            ),
          )
          .toList();
    } catch (e) {
      return List.empty();
    }
  }

  @override
  Future<List<Road>> getRoadsGroups({
    required String groupId,
    int limit = 0,
    int offset = 0,
  }) async {
    try {
      final result = await firestore
          .collection(collection)
          .where('groupId', isEqualTo: groupId)
          .get();
      return result.docs
          .map(
            (e) => Road.fromJson(
              json: e.data(),
            ),
          )
          .toList();
    } catch (e) {
      return List.empty();
    }
  }

  @override
  Future<bool> joinRoad({
    required CompetitorRoad competitorRoad,
    required String roadId,
  }) async {
    try {
      await firestore
          .collection(collection)
          .doc(roadId)
          .collection(collectionCompetitor)
          .doc(competitorRoad.userId)
          .set(
            competitorRoad.toJson(),
          );
      return true;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<bool> updateRoad(Road road) async {
    try {
      await firestore.collection(collection).doc(road.id).update(
            road.toJson(),
          );
      return true;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<bool> uploadProfileCoverRoad(
    String id,
    File filePhoto,
  ) async {
    try {
      FirebaseUtils firebaseUtils = FirebaseUtils();
      final url = await firebaseUtils.uploadImage(
        image: filePhoto,
        nameImage: 'ProfileCoverRoad',
        imageFolder: 'ProfileCoverRoad',
      );
      Road road = await this.getRoad(id);
      final roadUpdate = Road(
          id: road.id,
          cityId: road.cityId,
          dateTime: road.dateTime,
          description: road.description,
          distance: road.distance,
          groupId: road.groupId,
          image: url,
          modality: road.modality,
          name: road.name,
          numberLikes: road.numberLikes,
          numberParticipants: road.numberParticipants,
          pointmeeting: road.pointmeeting,
          route: road.route,
          routeLevel: road.routeLevel,
          status: road.status,
          type: road.type,
          group: road.group);
      await this.updateRoad(roadUpdate);
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<Road> getRoad(String id) async {
    try {
      final response = await firestore
          .collection(collection)
          .where('id', isEqualTo: id)
          .get();
      return Road.fromJson(
        json: response.docs.first.data(),
      );
    } catch (e) {
      return Road(id: '', group: Group());
    }
  }

  @override
  Future<bool> createRoad(Road road) async {
    try {
      await firestore.collection(collection).doc(road.id).set(
            road.toJson(),
          );
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<List<CompetitorRoad>> getListassistedRoads() async {
    try {
      final response =
          await firestore.collectionGroup(collectionCompetitor).get();
      print(response.docs.first);
      return response.docs
          .map(
            (e) => CompetitorRoad.fromJsonMap(
              json: e.data(),
            ),
          )
          .toList();
    } catch (e) {
      return List.empty();
    }
  }

  Future<bool> onTapRoad(Road road,) async {
    try {
      await firestore
          .collection(collection)
          .doc(road.id)
          .update(road.toJson());
      return true;
    } catch (e) {
      return false;
    }
  }
}
