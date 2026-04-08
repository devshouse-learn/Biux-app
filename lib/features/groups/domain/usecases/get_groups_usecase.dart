import 'package:biux/features/groups/data/models/group_model.dart';
import 'package:biux/features/groups/domain/repositories/group_repository_interface.dart';

class GetGroupsUseCase {
  final GroupRepositoryInterface repository;

  GetGroupsUseCase(this.repository);

  /// Obtener todos los grupos
  Stream<List<GroupModel>> call() {
    return repository.getGroups();
  }

  /// Obtener grupos del usuario
  Stream<List<GroupModel>> byUser(String userId) {
    return repository.getUserGroups(userId);
  }

  /// Obtener grupos administrados
  Stream<List<GroupModel>> adminGroups(String userId) {
    return repository.getAdminGroups(userId);
  }

  /// Obtener grupos por ciudad
  Stream<List<GroupModel>> byCity(String cityId) {
    return repository.getGroupsByCity(cityId);
  }
}
