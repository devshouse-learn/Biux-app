import 'dart:io';
import 'package:biux/features/roads/data/models/competitor_road.dart';
import 'package:biux/features/roads/data/models/road.dart';

abstract class RoadsRepositoryAbstract {
  Future<List<Road>> getRoadsByCity({
    int limit = 0,
    int offset = 0,
    required String cityId,
  });
  Future<bool> uploadProfileCoverRoad(String id, File filePhoto);
  Future<bool> updateRoad(Road road);
  Future<List<CompetitorRoad>> getListParticipantRoad(String id);
  Future<List<Road>> getRoadsGroups({
    required String groupId,
    int limit = 0,
    int offset = 0,
  });
  Future<bool> joinRoad({
    required CompetitorRoad competitorRoad,
    required String roadId,
  });
  Future<bool> deleteRoad(Road road);
  Future<CompetitorRoad> getParticipantRoad(
      {required String id, required String userId});
  Future<bool> deleteCompetitorRoad({
    required CompetitorRoad competitorRoad,
    required String roadId,
  });
  Future<bool> createRoad(Road road);
}
