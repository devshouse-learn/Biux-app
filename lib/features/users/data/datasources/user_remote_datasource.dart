// Remote Data Source Interface for Users
abstract class UserRemoteDataSource {
  Future<dynamic> getUserById(String id);
  Future<List<dynamic>> getAllUsers();
  Future<dynamic> createUser(Map<String, dynamic> userData);
  Future<dynamic> updateUser(String id, Map<String, dynamic> userData);
  Future<void> deleteUser(String id);
}

// Implementation of Remote Data Source
class UserRemoteDataSourceImpl implements UserRemoteDataSource {
  // Here you would inject your HTTP client or API service
  
  @override
  Future<dynamic> getUserById(String id) async {
    // Implementation would call your API
    throw UnimplementedError('API call to get user by id');
  }
  
  @override
  Future<List<dynamic>> getAllUsers() async {
    // Implementation would call your API
    throw UnimplementedError('API call to get all users');
  }
  
  @override
  Future<dynamic> createUser(Map<String, dynamic> userData) async {
    // Implementation would call your API
    throw UnimplementedError('API call to create user');
  }
  
  @override
  Future<dynamic> updateUser(String id, Map<String, dynamic> userData) async {
    // Implementation would call your API  
    throw UnimplementedError('API call to update user');
  }
  
  @override
  Future<void> deleteUser(String id) async {
    // Implementation would call your API
    throw UnimplementedError('API call to delete user');
  }
}