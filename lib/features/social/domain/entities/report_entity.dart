class UserReportEntity {
  final String id;
  final String reporterId;
  final String reportedUserId;
  final String reportedContentId;
  final String reportType; // 'user', 'post', 'comment', 'ride'
  final String reason;
  final String? details;
  final DateTime createdAt;
  final String status; // 'pending', 'reviewed', 'resolved'

  const UserReportEntity({
    required this.id,
    required this.reporterId,
    required this.reportedUserId,
    required this.reportedContentId,
    required this.reportType,
    required this.reason,
    this.details,
    required this.createdAt,
    this.status = 'pending',
  });

  Map<String, dynamic> toMap() => {
    'reporterId': reporterId,
    'reportedUserId': reportedUserId,
    'reportedContentId': reportedContentId,
    'reportType': reportType,
    'reason': reason,
    'details': details,
    'createdAt': createdAt.toIso8601String(),
    'status': status,
  };
}
