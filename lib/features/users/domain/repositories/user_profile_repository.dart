import 'package:biux/features/users/data/models/user.dart';

abstract class UserProfileRepository {
  Future<List<BiuxUser>> searchUsers(String query);
  Future<BiuxUser?> getUserProfile(String userId);
  Future<bool> followUser(String userId);
  Future<bool> unfollowUser(String userId);
  Future<List<BiuxUser>> getFollowers(String userId);
  Future<List<BiuxUser>> getFollowing(String userId);
  Future<List<BiuxUser>> getUserExperiences(String userId);
  Future<bool> isFollowing(String userId);

  // Follow request methods for private accounts
  Future<bool> sendFollowRequest(String userId);
  Future<bool> cancelFollowRequest(String userId);
  Future<bool> acceptFollowRequest(String requesterId);
  Future<bool> rejectFollowRequest(String requesterId);
  Future<bool> hasPendingFollowRequest(String userId);
  Future<List<BiuxUser>> getFollowRequests();

  // Profile visibility
  Future<bool> updateProfileVisibility(String visibility);
}
