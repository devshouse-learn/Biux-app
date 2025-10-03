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
    return UserEntity(
      id: userModel.id,
      fullName: userModel.fullName,
      userName: userModel.userName,
      email: userModel.email,
      photo: userModel.photo,
    );
  }
  
  @override
  Future<List<UserEntity>> getAllUsers() async {
    final userModels = await remoteDataSource.getAllUsers();
    return userModels.map((model) => UserEntity(
      id: model.id,
      fullName: model.fullName,
      userName: model.userName,
      email: model.email,
      photo: model.photo,
    )).toList();
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
}