import 'package:biux/features/groups/domain/repositories/group_repository_interface.dart';

class LeaveGroupUseCase {
  final GroupRepositoryInterface repository;

  LeaveGroupUseCase(this.repository);

  Future<bool> call(String groupId, String userId) async {
    return await repository.leaveGroup(groupId, userId);
  }
}
