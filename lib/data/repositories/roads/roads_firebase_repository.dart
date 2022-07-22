import 'package:biux/data/models/road.dart';
import 'package:biux/data/models/group.dart';
import 'package:biux/data/models/competitor_road.dart';
import 'dart:io';

import 'package:biux/data/repositories/roads/roads_repository_abstract.dart';
import 'package:biux/utils/firebase_utils.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RoadsFirebaseRepository extends RoadsRepositoryAbstract {
  static final collection = 'roads';
  static final collectionCompetitor = 'CompetitorRoad';
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  @override
  Future<CompetitorRoad> deleteCompetitorRoad(
      CompetitorRoad competitorRoad) async {
    try {
      await firestore
          .collection(collectionCompetitor)
          .doc(competitorRoad.id.toString())
          .delete();
      final response = await firestore
          .collection(collection)
          .where('id', isEqualTo: competitorRoad.id.toString())
          .get();
      return CompetitorRoad.fromJson(
        response.docs.first.data(),
      );
    } catch (e) {
      return CompetitorRoad();
    }
  }

  @override
  Future deleteRoad(Road road, Group group) async {
    try {
      await firestore.collection(collection).doc(road.id.toString()).delete();
    } catch (e) {}
  }

  @override
  Future<List<CompetitorRoad>> getListParticipantRoad(int id) async {
    try {
      final result = await firestore
          .collection(collectionCompetitor)
          .where('roadId', isEqualTo: id)
          .get();
      return result.docs
          .map(
            (e) => CompetitorRoad.fromJson(
              e.data(),
            ),
          )
          .toList();
    } catch (e) {
      return List.empty();
    }
  }

  @override
  Future<CompetitorRoad> getParticipantRoad(int id, int userId) async {
    try {
      final response = await firestore
          .collection(collectionCompetitor)
          .where('roadId', isEqualTo: id.toString())
          .where('userId', isEqualTo: userId.toString())
          .get();
      return CompetitorRoad.fromJson(
        response.docs.first.data(),
      );
    } catch (e) {
      return CompetitorRoad();
    }
  }

  @override
  Future<List<Road>> getRoads(int limit, int offset, int cityId) async {
    try {
      final result = await firestore
          .collection(collection)
          .where('cityId', isEqualTo: cityId)
          .get();
      return result.docs
          .map(
            (e) => Road.fromJson(
              e.data(),
            ),
          )
          .toList();
    } catch (e) {
      return List.empty();
    }
  }

  @override
  Future<List<Road>> getRoadsGroups(int id, int limit, int offset) async {
    try {
      final result = await firestore
          .collection(collection)
          .where('groupId', isEqualTo: id)
          .get();
      return result.docs
          .map(
            (e) => Road.fromJson(
              e.data(),
            ),
          )
          .toList();
    } catch (e) {
      return List.empty();
    }
  }

  @override
  Future joinMeRoad(int userId, int roadId) {
    // TODO: implement joinMeRoad
    throw UnimplementedError();
  }

  @override
  Future<Road> updateRoad(Road road) async {
    try {
      await firestore
          .collection(collection)
          .doc(road.id.toString())
          .update(road.toJson());
      final response = await firestore
          .collection(collection)
          .where('id', isEqualTo: road.id.toString())
          .get();
      return Road.fromJson(
        response.docs.first.data(),
      );
    } catch (e) {
      return Road();
    }
  }

  @override
  Future uploadProfileCoverRoad(int id, File filePhoto) async {
    try {
      FirebaseUtils firebaseUtils = FirebaseUtils();
      final url = firebaseUtils.uploadImage(
        image: filePhoto,
        nameImage: 'ProfileCoverRoad',
        imageFolder: 'ProfileCoverRoad',
      );
    } catch (e) {}
  }
}
