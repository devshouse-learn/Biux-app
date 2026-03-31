import 'package:biux/features/users/data/models/user.dart';

class UserProfileEntity {
  final BiuxUser user;
  final bool isFollowing;
  final bool isFollowedBy;
  final int postsCount;
  final int storiesCount;
  final List<String> recentStoryIds;

  const UserProfileEntity({
    required this.user,
    this.isFollowing = false,
    this.isFollowedBy = false,
    this.postsCount = 0,
    this.storiesCount = 0,
    this.recentStoryIds = const [],
  });

  UserProfileEntity copyWith({
    BiuxUser? user,
    bool? isFollowing,
    bool? isFollowedBy,
    int? postsCount,
    int? storiesCount,
    List<String>? recentStoryIds,
  }) {
    return UserProfileEntity(
      user: user ?? this.user,
      isFollowing: isFollowing ?? this.isFollowing,
      isFollowedBy: isFollowedBy ?? this.isFollowedBy,
      postsCount: postsCount ?? this.postsCount,
      storiesCount: storiesCount ?? this.storiesCount,
      recentStoryIds: recentStoryIds ?? this.recentStoryIds,
    );
  }
}
