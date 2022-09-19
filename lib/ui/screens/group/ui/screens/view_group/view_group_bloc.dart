import 'package:biux/data/models/group.dart';
import 'package:biux/data/models/member.dart';
import 'package:biux/data/models/road.dart';
import 'package:biux/data/models/story.dart';
import 'package:biux/data/models/user.dart';
import 'package:biux/data/repositories/groups/groups_firebase_repository.dart';
import 'package:biux/data/repositories/members/members_firebase_repository.dart';
import 'package:biux/data/repositories/roads/roads_firebase_repository.dart';
import 'package:biux/data/repositories/stories/stories_firebase_repository.dart';
import 'package:biux/data/repositories/users/user_firebase_repository.dart';
import 'package:flutter/material.dart';
import 'package:biux/data/local_storage/localstorage.dart';

class ViewGroupBloc extends ChangeNotifier {
  List<Road> roads = [];
  List<Story> stories = [];
  List<Member> member = [];
  List<BiuxUser> listMember = [];
  BiuxUser dataMember = BiuxUser();
  Group group = Group();
  BiuxUser admin = BiuxUser();
  final groupId;
  final adminId;
  ViewGroupBloc({required this.groupId, required this.adminId}) {
    loadData(adminId: adminId, groupId: groupId);
  }

  Future<void> loadData(
      {required String groupId, required String adminId}) async {
    Future.delayed(Duration.zero, () async {
      await getGroup(groupId);
      await getRoads(groupId);
      await getAdmin(adminId);
      await getStorie(groupId);
      await getDataMembers();
    });
  }

  Future<void> getGroup(String groupId) async {
    final dataGroup =
        await GroupsFirebaseRepository().getSpecificGroup(groupId);
    final dataMembers = await MembersFirebaseRepository().getMembers(groupId);
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
}
