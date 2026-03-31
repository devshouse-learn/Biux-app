/// Roles de usuario en la tienda
enum UserRole {
  user, // Usuario normal - solo puede ver y comprar
  seller, // Vendedor autorizado - puede subir sus propios productos
  admin; // Administrador - control total del sistema

  String get displayName {
    switch (this) {
      case UserRole.user:
        return 'user_role_user';
      case UserRole.seller:
        return 'user_role_seller';
      case UserRole.admin:
        return 'user_role_admin';
    }
  }
}

// Domain Entity for User
class UserEntity {
  final String id;
  final String fullName;
  final String userName;
  final String email;
  final String photo;
  final UserRole role; // Rol del usuario en el sistema
  final bool autorizadoPorAdmin; // Si fue autorizado por un administrador
  final bool isAdmin; // Campo legacy - para compatibilidad
  final bool canSellProducts; // Campo legacy - para compatibilidad

  const UserEntity({
    required this.id,
    required this.fullName,
    required this.userName,
    required this.email,
    required this.photo,
    this.role = UserRole.user, // Por defecto es usuario normal
    this.autorizadoPorAdmin = false,
    this.isAdmin = false, // Legacy
    this.canSellProducts = false, // Legacy
  });

  // Getters basados en el nuevo sistema de roles
  bool get isAdministrador => role == UserRole.admin || isAdmin;
  bool get isVendedor => role == UserRole.seller || canSellProducts;
  bool get isUsuarioNormal =>
      role == UserRole.user && !isAdmin && !canSellProducts;

  // Getter para verificar si puede crear productos
  bool get canCreateProducts => isAdministrador || isVendedor;

  // Getter para verificar si puede gestionar vendedores
  bool get canManageSellers => isAdministrador;

  // Getter para verificar si puede eliminar cualquier producto
  bool get canDeleteAnyProduct => isAdministrador;
}
