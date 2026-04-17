import 'package:biux/features/users/domain/entities/user_entity.dart';

/// Factory para crear entidades de usuario en tests
class UserTestFactory {
  static UserEntity createUser({
    String? id,
    String fullName = 'Test User',
    String userName = 'testuser',
    String email = 'test@example.com',
    String photo = '',
    UserRole role = UserRole.user,
    bool autorizadoPorAdmin = false,
    bool isAdmin = false,
    bool canSellProducts = false,
  }) {
    return UserEntity(
      id: id ?? 'test-user-${DateTime.now().microsecondsSinceEpoch}',
      fullName: fullName,
      userName: userName,
      email: email,
      photo: photo,
      role: role,
      autorizadoPorAdmin: autorizadoPorAdmin,
      isAdmin: isAdmin,
      canSellProducts: canSellProducts,
    );
  }

  /// Crea una lista de usuarios de prueba
  static List<UserEntity> createUsers(int count) {
    return List.generate(
      count,
      (i) => createUser(
        id: 'user-$i',
        fullName: 'User $i',
        userName: 'user_$i',
        email: 'user$i@example.com',
      ),
    );
  }

  /// Crea un usuario admin
  static UserEntity createAdmin({String? id}) {
    return createUser(
      id: id ?? 'admin-user',
      fullName: 'Admin User',
      userName: 'admin',
      email: 'admin@example.com',
      role: UserRole.admin,
      isAdmin: true,
    );
  }

  /// Crea un usuario vendedor
  static UserEntity createSeller({String? id}) {
    return createUser(
      id: id ?? 'seller-user',
      fullName: 'Seller User',
      userName: 'seller',
      email: 'seller@example.com',
      role: UserRole.seller,
      canSellProducts: true,
      autorizadoPorAdmin: true,
    );
  }
}
