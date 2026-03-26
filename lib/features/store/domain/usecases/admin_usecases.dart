import 'package:biux/features/users/domain/entities/user_entity.dart';
import 'package:biux/features/users/domain/repositories/user_repository.dart';

/// Caso de uso para autorizar a un usuario como vendedor
/// Solo administradores pueden ejecutar esta acción
class AuthorizeSellerUseCase {
  final UserRepository repository;

  AuthorizeSellerUseCase(this.repository);

  Future<void> call(String userId) async {
    if (userId.isEmpty) {
      throw Exception('error_invalid_user_id');
    }

    // Actualizar rol a vendedor y marcar como autorizado
    await repository.updateUserRole(userId, UserRole.seller);
    await repository.toggleAutorizacionAdmin(userId, true);
  }
}

/// Caso de uso para revocar permisos de vendedor
/// Solo administradores pueden ejecutar esta acción
class RevokeSellerUseCase {
  final UserRepository repository;

  RevokeSellerUseCase(this.repository);

  Future<void> call(String userId) async {
    if (userId.isEmpty) {
      throw Exception('error_invalid_user_id');
    }

    // Obtener el usuario actual para validar que no sea admin
    final user = await repository.getUserById(userId);

    if (user.role == UserRole.admin) {
      throw Exception('error_cannot_revoke_admin');
    }

    // Regresar a usuario normal
    await repository.updateUserRole(userId, UserRole.user);
    await repository.toggleAutorizacionAdmin(userId, false);
  }
}

/// Caso de uso para obtener lista de vendedores
class GetAllSellersUseCase {
  final UserRepository repository;

  GetAllSellersUseCase(this.repository);

  Future<List<UserEntity>> call() async {
    final allUsers = await repository.getAllUsers();
    return allUsers.where((user) => user.isVendedor).toList();
  }
}

/// Caso de uso para obtener lista de usuarios normales
class GetNormalUsersUseCase {
  final UserRepository repository;

  GetNormalUsersUseCase(this.repository);

  Future<List<UserEntity>> call() async {
    final allUsers = await repository.getAllUsers();
    return allUsers.where((user) => user.isUsuarioNormal).toList();
  }
}
