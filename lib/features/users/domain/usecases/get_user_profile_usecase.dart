import 'package:biux/features/users/domain/entities/user_entity.dart';
import 'package:biux/features/users/domain/repositories/user_repository.dart';

// Use Case for getting user profile
class GetUserProfileUseCase {
  final UserRepository repository;

  GetUserProfileUseCase(this.repository);

  Future<UserEntity> call(String userId) async {
    return await repository.getUserById(userId);
  }
}
