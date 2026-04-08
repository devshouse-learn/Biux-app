import 'package:biux/features/groups/data/models/group_model.dart';
import 'package:biux/features/groups/domain/repositories/group_repository_interface.dart';

class GetGroupByIdUseCase {
  final GroupRepositoryInterface repository;

  GetGroupByIdUseCase(this.repository);

  Future<GroupModel?> call(String groupId) async {
    return await repository.getGroup(groupId);
  }
}
