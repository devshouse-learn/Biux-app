import 'dart:io';

import 'package:biux/data/models/group.dart';
import 'package:biux/data/models/member.dart';

abstract class GroupsRepositoryAbstract {
  Future<List<Group>> getGroups(String cityAdmin);
  Future<bool> uploadLogoGroup({
    required String id,
    required File filePhoto,
  });
  Future<bool> uploadGroupProfileCover({
    required String id,
    required File fileProfileCover,
  });
  Future<Group> getSpecificGroup(String id);
  Future<List<Member>> getMembers(String id);
  Future<List<String>> getNamesGroups();
  Future<bool> updateGroup(Group group);
  Future<bool> deleteGroup(Group group);
  Future<bool> createGroup(Group group, File logo, File profileCover);
}
