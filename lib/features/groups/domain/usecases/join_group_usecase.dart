import 'package:biux/features/groups/domain/repositories/group_repository_interface.dart';

class JoinGroupUseCase {
  final GroupRepositoryInterface repository;

  JoinGroupUseCase(this.repository);

  Future<bool> call(String groupId, String userId) async {
    return await repository.requestJoinGroup(groupId, userId);
  }
}
