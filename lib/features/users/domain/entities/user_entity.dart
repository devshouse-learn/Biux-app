// Domain Entity for User
class UserEntity {
  final String id;
  final String fullName;
  final String userName;
  final String email;
  final String photo;
  
  const UserEntity({
    required this.id,
    required this.fullName,
    required this.userName,
    required this.email,
    required this.photo,
  });
}