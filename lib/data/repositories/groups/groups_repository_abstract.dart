import 'dart:io';

import 'package:biux/data/models/group.dart';
import 'package:biux/data/models/member.dart';

abstract class GroupsRepositoryAbstract {
  Future<List<Group>> getGroups(String cityId);
  Future uploadLogoGroup(int id, File filePhoto);
  Future uploadGroupProfileCover(int id, File fileProfileCover);
  Future<Group> getSpecificGroup(int id);
  Future<Group> getMembers(id);
  Future<List<Group>> getNamesGroups();
  Future<Group> updateGroup(Group group);
  Future<Member> deleteGroup(Group group);
}
