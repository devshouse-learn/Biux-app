import 'package:biux/data/models/group.dart';
import 'package:biux/data/models/member.dart';
import 'package:biux/data/models/user.dart';
import 'package:biux/data/repositories/groups/groups_firebase_repository.dart';
import 'package:biux/data/repositories/members/members_firebase_repository.dart';
import 'package:biux/data/repositories/users/user_firebase_repository.dart';
import 'package:flutter/material.dart';
import 'package:biux/data/local_storage/localstorage.dart';

class ViewGroupBloc extends ChangeNotifier {
  final GroupsFirebaseRepository groupsFirebaseRepository =
      GroupsFirebaseRepository();
  final MembersFirebaseRepository membersFirebaseRepository =
      MembersFirebaseRepository();
  final UserFirebaseRepository userFirebaseRepository =
      UserFirebaseRepository();
  Group group = Group();
  BiuxUser admin = BiuxUser();
  BiuxUser user = BiuxUser();
  final groupId;
  final adminId;
  bool validation = false;
  Member member = Member();
  ViewGroupBloc({required this.groupId, required this.adminId}) {
    getGroup(groupId);
    getAdmin(adminId);
    getUsers();
  }

  Future<void> getGroup(String groupId) async {
    String? userId = await LocalStorage().getUserId();
    final dataGroup = await groupsFirebaseRepository.getSpecificGroup(groupId);
    final dataMembers = await membersFirebaseRepository.getApproved(
        userId!, groupId);
    member = dataMembers;
    if (user.id == member.userId) {
      validation = true;
    } else {
      validation = false;
    }
    group = dataGroup;
    notifyListeners();
  }

  Future<void> getAdmin(String id) async {
    final dataAdmin =
        await userFirebaseRepository.getUserId(id);
    admin = dataAdmin;
    notifyListeners();
  }

  Future<void> getUsers() async {
    String? userId = await LocalStorage().getUserId();
    final dataUser =
        await userFirebaseRepository.getUserId(userId!);
    user = dataUser;
    notifyListeners();
  }

  Future<bool> joinGroup() async {
    final result = await membersFirebaseRepository.joinGroups(group.id,
        group.numberMembers, Member(approved: true, userId: user.id!));
    validation = true;
    notifyListeners();
    return result;
  }

  Future<bool> leaveGroup() async {
    final dataMembers = await membersFirebaseRepository.getApproved(
        user.id!, group.id);
    final result = await membersFirebaseRepository.leaveGroups(
        dataMembers.id, group.numberMembers, group.id);
    validation = false;
    notifyListeners();
    return result;
  }
}
