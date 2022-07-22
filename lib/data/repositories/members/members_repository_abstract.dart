import 'package:biux/data/models/member.dart';

abstract class MembersRepositoryAbstract {
  Future<List<Member>> getMembers(int offset);
  Future<List<Member>> getMembersGroup(int id, int offset);
  Future<bool> joinGroups(int userId, int groupId);
  Future<Member> getApproved(int id, int userId);
  Future<List<Member>> getMyGroups(int id);
  Future<Member> getMyGroupsUser(int id);
  Future<Member> deleteMember(Member member);
}
