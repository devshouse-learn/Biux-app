import 'package:biux/core/config/router/router_path.dart';
import 'package:biux/features/groups/data/models/group.dart';
import 'package:biux/features/members/data/models/member.dart';
import 'package:biux/features/users/data/models/user.dart';
import 'package:biux/features/authentication/data/repositories/authentication_repository.dart';
import 'package:biux/features/groups/data/repositories/groups_firebase_repository.dart';
import 'package:biux/features/members/data/repositories/members_firebase_repository.dart';
import 'package:biux/features/users/data/repositories/user_firebase_repository.dart';
import 'package:flutter/material.dart';

class MyGroupsBloc extends ChangeNotifier {
  List<Group> listGroup = [];
  BiuxUser user = BiuxUser();
  List<Member> listMembers = [];

  MyGroupsBloc() {
    loadData();
  }

  Future<void> loadData() async {
    Future.delayed(Duration.zero, () async {
      await getUser();
      await getGroups();
    });
  }

  Future<void> getUser() async {
    String? userId = AuthenticationRepository().getUserId;
    final dataUser = await UserFirebaseRepository().getUserId(userId);
    user = dataUser;
    notifyListeners();
  }

  Future<List<Group>> getGroups() async {
    final dataMembers = await MembersFirebaseRepository().getMembers();
    listMembers = dataMembers
        .where(
          (member) => member.userId == user.id,
        )
        .toList();
    listGroup.clear();
    final myGroup =
        await GroupsFirebaseRepository().getSpecificGroup(user.groupId);
    if (myGroup.adminId.isNotEmpty) listGroup.add(myGroup);
    listMembers.map((e) async {
      final group =
          await GroupsFirebaseRepository().getSpecificGroup(e.groupId);
      listGroup.add(group);
      notifyListeners();
    }).toList();
    notifyListeners();
    return listGroup;
  }

  Future<void> onTapViewGroup(BuildContext context) async {
    await Navigator.pushNamed(context, AppRoutes.groupCreateRoute);
    notifyListeners();
    getUser();
  }

  Future<void> onTapJoin(
      Member member, List<Member> members, Group group) async {
    final valueJoin = await MembersFirebaseRepository()
        .joinGroups(group.id, group.numberMembers, member);
    group.numberMembers = group.numberMembers + 1;
    listMembers.add(
      Member(
        approved: true,
        groupId: group.id,
        id: valueJoin,
        userId: user.id,
      ),
    );
    notifyListeners();
  }

  Future<void> onTapLeave(String idMember, List<Member> members, Group group,
      int numberMembers) async {
    group.numberMembers = group.numberMembers - 1;
    listMembers =
        listMembers.where((memebr) => memebr.groupId != group.id).toList();
    await MembersFirebaseRepository()
        .leaveGroups(idMember, numberMembers, group.id);
    getGroups();
    notifyListeners();
  }
}
