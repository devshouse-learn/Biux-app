import 'package:biux/data/models/member.dart';

abstract class MembersRepositoryAbstract {
  Future<List<Member>> getMembers();
  Future<String> joinGroups(String groupId, int memberNumer, Member member);
  Future<Member> getApproved(String userId, String groupId);
  Future<List<Member>> getMyGroups(String id);
  Future<Member> deleteMember(String memberId, String groupId);
  Future<List<Member>> getMyMembersGroup(String groupId);
}
