import 'dart:io';

import 'package:biux/data/models/competitor_road.dart';
import 'package:biux/data/models/group.dart';
import 'package:biux/data/models/road.dart';

abstract class RoadsRepositoryAbstract {
  Future<List<Road>> getRoads(
    int limit,
    int offset,
    int cityId,
  );
  Future uploadProfileCoverRoad(
    int id,
    File filePhoto,
  );
  Future<Road> updateRoad(Road road);
  Future<List<CompetitorRoad>> getListParticipantRoad(int id);
  Future<List<Road>> getRoadsGroups(
    int id,
    int limit,
    int offset,
  );
  Future joinMeRoad(int userId, int roadId);
  Future deleteRoad(Road road, Group group);
  Future<CompetitorRoad> getParticipantRoad(int id, int userId);
  Future<CompetitorRoad> deleteCompetitorRoad(CompetitorRoad competitorRoad);
}
