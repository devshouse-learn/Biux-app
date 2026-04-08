import 'package:biux/features/groups/domain/repositories/group_repository_interface.dart';

class RejectJoinRequestUseCase {
  final GroupRepositoryInterface repository;

  RejectJoinRequestUseCase(this.repository);

  Future<bool> call(String groupId, String userId) async {
    return await repository.rejectJoinRequest(groupId, userId);
  }
}
