import 'package:biux/features/groups/data/models/group_model.dart';
import 'package:biux/features/groups/domain/repositories/group_repository_interface.dart';

class SearchGroupsUseCase {
  final GroupRepositoryInterface repository;

  SearchGroupsUseCase(this.repository);

  Future<List<GroupModel>> call(String query) async {
    return await repository.searchGroups(query);
  }
}
