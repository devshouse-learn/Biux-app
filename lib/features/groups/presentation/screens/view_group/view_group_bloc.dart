import 'package:biux/features/groups/data/models/group.dart';
import 'package:biux/features/members/data/models/member.dart';
import 'package:biux/features/roads/data/models/road.dart';
import 'package:biux/features/roads/data/repositories/roads_firebase_repository.dart';
import 'package:biux/features/stories/data/models/story.dart';
import 'package:biux/features/stories/data/repositories/stories_firebase_repository.dart';
import 'package:biux/features/users/data/models/user.dart';
import 'package:biux/features/authentication/data/repositories/authentication_repository.dart';
import 'package:biux/features/groups/data/repositories/groups_firebase_repository.dart';
import 'package:biux/features/members/data/repositories/members_firebase_repository.dart';

import 'package:biux/features/users/data/repositories/user_firebase_repository.dart';
import 'package:flutter/material.dart';

class ViewGroupBloc extends ChangeNotifier {
  List<Road> roads = [];
  List<Story> stories = [];
  List<Member> member = [];
  List<BiuxUser> listMember = [];
  BiuxUser user = BiuxUser();
  BiuxUser dataMember = BiuxUser();
  Group group = Group();
  BiuxUser admin = BiuxUser();
  final String groupId;
  final String adminId;
  ViewGroupBloc({required this.groupId, required this.adminId}) {
    loadData(adminId: adminId, groupId: groupId);
  }

  Future<void> loadData(
      {required String groupId, required String adminId}) async {
    Future.delayed(Duration.zero, () async {
      await getUser();
      await getGroup(groupId);
      await getRoads(groupId);
      await getAdmin(adminId);
      await getStorie(groupId);
      await getDataMembers();
    });
  }

  Future<void> getUser() async {
    String? userId = AuthenticationRepository().getUserId;
    final dataUser = await UserFirebaseRepository().getUserId(userId);
    user = dataUser;
    notifyListeners();
  }

  Future<void> getGroup(String groupId) async {
    final dataGroup =
        await GroupsFirebaseRepository().getSpecificGroup(groupId);
    final dataMembers =
        await MembersFirebaseRepository().getMyMembersGroup(groupId);
    member = dataMembers;
    group = dataGroup;
    notifyListeners();
  }

  Future<void> getRoads(String groupId) async {
    final dataRoads =
        await RoadsFirebaseRepository().getRoadsGroups(groupId: groupId);
    roads = dataRoads;
    notifyListeners();
  }

  Future<void> getAdmin(String id) async {
    final dataAdmin = await UserFirebaseRepository().getUserId(id);
    admin = dataAdmin;
    notifyListeners();
  }

  Future<void> getStorie(String groupId) async {
    final dataStory = await StoriesFirebaseRepository().getStoriesId(groupId);
    stories = dataStory;
    notifyListeners();
  }

  Future<void> getDataMembers() async {
    member.map((e) async {
      dataMember = await UserFirebaseRepository().getUserId(e.userId);
      listMember.add(dataMember);
    }).toList();
  }

  Future<void> onTapOutRoads(Road road) async {
    road.numberParticipants = road.numberParticipants - 1;
    road.competitorRoad = road.competitorRoad
        .where((competitor) => competitor.id != user.id)
        .toList();
    await RoadsFirebaseRepository().onTapRoad(road);
    notifyListeners();
  }

  Future<void> onTapJoinRoads(Road road) async {
    road.numberParticipants = road.numberParticipants + 1;
    road.competitorRoad.add(BiuxUser(id: user.id, fullName: user.fullName));
    await RoadsFirebaseRepository().onTapRoad(road);
    notifyListeners();
  }
}
