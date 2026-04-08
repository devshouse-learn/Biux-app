import 'package:biux/features/groups/domain/repositories/group_repository_interface.dart';

class DeleteGroupUseCase {
  final GroupRepositoryInterface repository;

  DeleteGroupUseCase(this.repository);

  Future<bool> call(String groupId) async {
    return await repository.deleteGroup(groupId);
  }
}
