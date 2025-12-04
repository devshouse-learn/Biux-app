// Domain Entity for User
class UserEntity {
  final String id;
  final String fullName;
  final String userName;
  final String email;
  final String photo;
  final bool isAdmin; // Campo para identificar administradores
  
  const UserEntity({
    required this.id,
    required this.fullName,
    required this.userName,
    required this.email,
    required this.photo,
    this.isAdmin = false, // Por defecto los usuarios NO son admin
  });
}