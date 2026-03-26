import 'package:biux/features/users/data/models/user_model.dart';
import 'package:biux/features/users/data/datasources/user_service.dart' as real;

/// Proxy que delega al UserService real en features/users.
/// Mantiene la misma API para compatibilidad con código que importe esta ruta.
class UserService {
  final real.UserService _delegate = real.UserService();

  UserService();

  Future<UserModel?> getUserData(String uid) async {
    return _delegate.getUserData(uid);
  }

  void listenToUser(String uid, void Function(UserModel?) callback) {
    _delegate.listenToUser(uid, callback);
  }

  Future<bool> updateUserProfile({
    required String uid,
    String? name,
    String? email,
    String? description,
    String? username,
    String? photoUrl,
    String? coverPhotoUrl,
  }) async {
    return _delegate.updateUserProfile(
      uid: uid,
      name: name,
      email: email,
      description: description,
      username: username,
      photoUrl: photoUrl,
      coverPhotoUrl: coverPhotoUrl,
    );
  }

  Future<String?> uploadProfileImage(String uid) async {
    return _delegate.uploadProfileImage(uid);
  }

  Future<bool> requestAccountDeletion(String uid) async {
    return _delegate.requestAccountDeletion(uid);
  }

  Future<void> signOut() async {
    return _delegate.signOut();
  }

  Future<void> createUserIfNotExists(String uid, String phoneNumber) async {
    await _delegate.createUserIfNotExists(uid, phoneNumber);
  }

  Future<bool> updateSellerPermission(String userId, bool canSell) async {
    return _delegate.updateSellerPermission(userId, canSell);
  }

  Future<List<UserModel>> getAllUsers() async {
    return _delegate.getAllUsers();
  }

  Future<bool> followUser({
    required String currentUserId,
    required String userIdToFollow,
  }) async {
    return _delegate.followUser(
      currentUserId: currentUserId,
      userIdToFollow: userIdToFollow,
    );
  }

  Future<bool> unfollowUser({
    required String currentUserId,
    required String userIdToUnfollow,
  }) async {
    return _delegate.unfollowUser(
      currentUserId: currentUserId,
      userIdToUnfollow: userIdToUnfollow,
    );
  }
}
