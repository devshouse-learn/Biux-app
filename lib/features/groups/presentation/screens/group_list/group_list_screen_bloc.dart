import 'package:biux/features/cities/data/models/city.dart';
import 'package:biux/features/groups/data/models/group.dart';
import 'package:biux/features/members/data/models/member.dart';
import 'package:biux/features/users/data/models/user.dart';
import 'package:biux/features/authentication/data/repositories/authentication_repository.dart';
import 'package:biux/features/cities/data/repositories/cities_firebase_repository.dart';
import 'package:biux/features/groups/data/repositories/groups_firebase_repository.dart';
import 'package:biux/features/members/data/repositories/members_firebase_repository.dart';
import 'package:biux/features/users/data/repositories/user_firebase_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class GroupListScreenBloc extends ChangeNotifier {
  List<Group> listGroup = [];
  List<Group> listFilterGroup = [];
  BiuxUser user = BiuxUser();
  List<City> listCities = [];
  List<Member> listMembers = [];
  final FocusNode focusNodeCity = FocusNode();
  final FocusNode focusNodeGrupo = FocusNode();
  final searchCityController = TextEditingController();
  final searchGroupController = TextEditingController();

  GroupListScreenBloc() {
    loadData();
  }

  Future<void> loadData() async {
    await getUser();
    await getGroupList();
    await getCities();
  }

  Future<List<Group>> getGroupList() async {
    if (searchCityController.text.isEmpty) {
      listGroup = await GroupsFirebaseRepository().getGroups();
      final dataMembers = await MembersFirebaseRepository().getMembers();
      listMembers = dataMembers
          .where((member) => member.userId == user.id)
          .toList();
      notifyListeners();
    } else {
      listGroup = await GroupsFirebaseRepository().getFilterGroups(
        searchCityController.text,
      );
      final dataMembers = await MembersFirebaseRepository().getMembers();
      listMembers = dataMembers
          .where((member) => member.userId == user.id)
          .toList();
      notifyListeners();
    }
    return listGroup;
  }

  Future<void> filterCroup() async {
    if (searchCityController.text.isEmpty)
      listFilterGroup = await GroupsFirebaseRepository().getGroups();
    else
      listFilterGroup = await GroupsFirebaseRepository().getFilterGroups(
        searchCityController.text,
      );
    listGroup = listFilterGroup
        .where(
          (groups) => groups.name.toLowerCase().contains(
            searchGroupController.text.toLowerCase(),
          ),
        )
        .toList();
    notifyListeners();
  }

  Future<void> getUser() async {
    String? userId = AuthenticationRepository().getUserId;
    final dataUser = await UserFirebaseRepository().getUserId(userId);
    user = dataUser;
    notifyListeners();
  }

  Future<void> getCities() async {
    final dataCities = await CitiesFirebaseRepository().getCities();
    listCities = dataCities;
    notifyListeners();
  }

  Future<void> filterCities() async {
    final dataFilterCities = await CitiesFirebaseRepository().getCities();
    listCities = dataFilterCities
        .where(
          (cities) => cities.name.toLowerCase().contains(
            searchCityController.text.toLowerCase(),
          ),
        )
        .toList();
    notifyListeners();
  }

  Future<void> onTapCities(String nameCity) async {
    searchCityController.text = nameCity;
    getGroupList();
    focusNodeCity.unfocus();
    notifyListeners();
  }

  Future<bool> setState() async {
    searchGroupController.clear();
    notifyListeners();
    return Future.value(false);
  }

  Future<bool> willPopScope() async {
    if (focusNodeCity.hasFocus) {
      focusNodeCity.unfocus();
      notifyListeners();
    } else
      SystemNavigator.pop();
    notifyListeners();
    return Future.value(false);
  }

  Future<void> onTapJoin(
    Member member,
    List<Member> members,
    Group group,
  ) async {
    final valueJoin = await MembersFirebaseRepository().joinGroups(
      group.id,
      group.numberMembers,
      member,
    );
    group.numberMembers = group.numberMembers + 1;
    listMembers.add(
      Member(approved: true, groupId: group.id, id: valueJoin, userId: user.id),
    );
    notifyListeners();
  }

  Future<void> onTapLeave(
    String idMember,
    List<Member> members,
    Group group,
    int numberMembers,
  ) async {
    group.numberMembers = group.numberMembers - 1;
    listMembers = listMembers
        .where((memebr) => memebr.groupId != group.id)
        .toList();
    await MembersFirebaseRepository().leaveGroups(
      idMember,
      numberMembers,
      group.id,
    );
    notifyListeners();
  }
}
