import 'package:biux/features/groups/domain/repositories/group_repository_interface.dart';

class ApproveJoinRequestUseCase {
  final GroupRepositoryInterface repository;

  ApproveJoinRequestUseCase(this.repository);

  Future<bool> call(String groupId, String userId) async {
    return await repository.approveJoinRequest(groupId, userId);
  }
}
