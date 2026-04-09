import 'package:biux/features/groups/domain/repositories/group_repository_interface.dart';

class CancelJoinRequestUseCase {
  final GroupRepositoryInterface repository;

  CancelJoinRequestUseCase(this.repository);

  Future<bool> call(String groupId, String userId) async {
    return await repository.cancelJoinRequest(groupId, userId);
  }
}
