import 'package:biux/data/models/group.dart';
import 'package:biux/data/models/member.dart';

abstract class MembersRepositoryAbstract {
  Future<List<Member>> getMembers(String groupId);
  Future joinGroups(String groupId, Member member);
  Future<Member> getApproved(String id, String userId, String groupId);
  Future<List<Member>> getMyGroups(String id);
  Future<Member> deleteMember(Member member, String groupId);
}
