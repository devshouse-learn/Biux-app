import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/user_repository.dart';
import '../datasources/user_remote_datasource.dart';

class UserRepositoryImpl implements UserRepository {
  final UserRemoteDataSource remoteDataSource;

  UserRepositoryImpl({required this.remoteDataSource});

  UserEntity _toEntity(dynamic model) => UserEntity(
        id: model.uid,
        fullName: model.name ?? 'Usuario',
        userName: model.username ?? model.name ?? 'usuario',
        email: model.email ?? '',
        photo: model.photoUrl ?? '',
      );

  @override
  Future<UserEntity> getUserById(String id) async {
    final userModel = await remoteDataSource.getUserById(id);
    if (userModel == null) throw Exception('Usuario no encontrado');
    return _toEntity(userModel);
  }

  @override
  Future<List<UserEntity>> getAllUsers() async {
    final userModels = await remoteDataSource.getAllUsers();
    return userModels.map(_toEntity).toList();
  }

  @override
  Future<UserEntity> createUser(UserEntity user) async {
    final model = await remoteDataSource.createUser({
      'fullName': user.fullName,
      'userName': user.userName,
      'email': user.email,
      'photoUrl': user.photo,
      'userRole': user.role.name,
      'isAdmin': user.isAdmin,
      'autorizadoPorAdmin': user.autorizadoPorAdmin,
    });
    return _toEntity(model);
  }

  @override
  Future<UserEntity> updateUser(UserEntity user) async {
    final model = await remoteDataSource.updateUser(user.id, {
      'fullName': user.fullName,
      'userName': user.userName,
      'email': user.email,
      'photoUrl': user.photo,
      'userRole': user.role.name,
      'isAdmin': user.isAdmin,
      'autorizadoPorAdmin': user.autorizadoPorAdmin,
    });
    return _toEntity(model);
  }

  @override
  Future<void> deleteUser(String id) async {
    await remoteDataSource.deleteUser(id);
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
