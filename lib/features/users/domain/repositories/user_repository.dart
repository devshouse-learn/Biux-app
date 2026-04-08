import 'package:biux/features/users/domain/entities/user_entity.dart';

// Domain Repository Interface (Abstract)
abstract class UserRepository {
  Future<UserEntity> getUserById(String id);
  Future<List<UserEntity>> getAllUsers();
  Future<UserEntity> createUser(UserEntity user);
  Future<UserEntity> updateUser(UserEntity user);
  Future<void> deleteUser(String id);

  // Métodos para gestión de roles (tienda)
  Future<void> updateUserRole(String userId, UserRole newRole);
  Future<void> toggleAutorizacionAdmin(String userId, bool autorizado);
}
