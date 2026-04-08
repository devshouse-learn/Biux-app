import 'package:image_picker/image_picker.dart';
import 'package:biux/features/groups/domain/repositories/group_repository_interface.dart';

class EditGroupUseCase {
  final GroupRepositoryInterface repository;

  EditGroupUseCase(this.repository);

  Future<bool> call({
    required String groupId,
    String? name,
    String? description,
    XFile? logoFile,
    XFile? coverFile,
  }) async {
    return await repository.updateGroup(
      groupId: groupId,
      name: name,
      description: description,
      logoFile: logoFile,
      coverFile: coverFile,
    );
  }
}
