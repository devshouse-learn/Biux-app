import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/user_repository.dart';
import '../datasources/user_remote_datasource.dart';

// Data Repository Implementation
class UserRepositoryImpl implements UserRepository {
  final UserRemoteDataSource remoteDataSource;

  UserRepositoryImpl({required this.remoteDataSource});

  @override
  Future<UserEntity> getUserById(String id) async {
    final userModel = await remoteDataSource.getUserById(id);

    if (userModel == null) {
      throw Exception('Usuario no encontrado');
    }

    return UserEntity(
      id: userModel.uid,
      fullName: userModel.name ?? 'Usuario',
      userName: userModel.username ?? userModel.name ?? 'usuario',
      email: userModel.email ?? '',
      photo: userModel.photoUrl ?? '',
    );
  }

  @override
  Future<List<UserEntity>> getAllUsers() async {
    final userModels = await remoteDataSource.getAllUsers();
    return userModels
        .map(
          (model) => UserEntity(
            id: model.uid,
            fullName: model.name ?? 'Usuario',
            userName: model.username ?? model.name ?? 'usuario',
            email: model.email ?? '',
            photo: model.photoUrl ?? '',
          ),
        )
        .toList();
  }

  @override
  Future<UserEntity> createUser(UserEntity user) async {
    // Implementation here
    throw UnimplementedError();
  }

  @override
  Future<UserEntity> updateUser(UserEntity user) async {
    // Implementation here
    throw UnimplementedError();
  }

  @override
  Future<void> deleteUser(String id) async {
    // Implementation here
    throw UnimplementedError();
  }

  @override
  Future<void> updateUserRole(String userId, UserRole newRole) async {
    await remoteDataSource.updateUserRole(userId, newRole);
  }

  @override
  Future<void> toggleAutorizacionAdmin(String userId, bool autorizado) async {
    await remoteDataSource.toggleAutorizacionAdmin(userId, autorizado);
  }
}
