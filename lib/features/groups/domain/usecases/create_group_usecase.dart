import 'package:image_picker/image_picker.dart';
import 'package:biux/features/groups/domain/repositories/group_repository_interface.dart';

class CreateGroupUseCase {
  final GroupRepositoryInterface repository;

  CreateGroupUseCase(this.repository);

  Future<String?> call({
    required String name,
    required String description,
    required String adminId,
    required String cityId,
    XFile? logoFile,
    XFile? coverFile,
  }) async {
    return await repository.createGroup(
      name: name,
      description: description,
      adminId: adminId,
      cityId: cityId,
      logoFile: logoFile,
      coverFile: coverFile,
    );
  }
}
