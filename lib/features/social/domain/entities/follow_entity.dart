class FollowEntity {
  final String id;
  final String followerId;
  final String followingId;
  final DateTime createdAt;

  const FollowEntity({
    required this.id,
    required this.followerId,
    required this.followingId,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() => {
    'followerId': followerId,
    'followingId': followingId,
    'createdAt': createdAt.toIso8601String(),
  };
}
