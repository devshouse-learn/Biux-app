import 'dart:io';

import 'package:biux/features/groups/data/models/group.dart';
import 'package:biux/features/members/data/models/member.dart';

abstract class GroupsRepositoryAbstract {
  Future<List<Group>> getGroups();
  Future<List<Group>> getFilterGroups(String cityAdmin);
  Future<bool> uploadLogoGroup({required String id, required File filePhoto});
  Future<bool> uploadGroupProfileCover({
    required String id,
    required File fileProfileCover,
  });
  Future<Group> getSpecificGroup(String id);
  Future<List<Member>> getMembers(String id);
  Future<List<String>> getNamesGroups();
  Future<bool> updateGroup(Group group);
  Future<bool> deleteGroup(Group group);
  Future<String> createGroup(Group group, File logo);
}
