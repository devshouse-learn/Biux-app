import 'package:flutter/foundation.dart';
import 'package:biux/features/safety/data/datasources/safety_datasource.dart';
import 'package:biux/features/safety/domain/entities/block_report_entity.dart';

class SafetyProvider with ChangeNotifier {
  final SafetyDatasource _datasource = SafetyDatasource();
  List<String> _blockedUsers = [];
  bool _isLoading = false;

  List<String> get blockedUsers => _blockedUsers;
  bool get isLoading => _isLoading;
  bool isUserBlocked(String userId) => _blockedUsers.contains(userId);

  Future<void> loadBlockedUsers(String userId) async {
    _isLoading = true;
    notifyListeners();
    try {
      _blockedUsers = await _datasource.getBlockedUsers(userId);
    } catch (_) {}
    _isLoading = false;
    notifyListeners();
  }

  Future<void> blockUser(String blockerId, String blockedId) async {
    try {
      await _datasource.blockUser(blockerId, blockedId);
      if (!_blockedUsers.contains(blockedId)) {
        _blockedUsers.add(blockedId);
        notifyListeners();
      }
    } catch (_) {}
  }

  Future<void> unblockUser(String blockerId, String blockedId) async {
    try {
      await _datasource.unblockUser(blockerId, blockedId);
      _blockedUsers.remove(blockedId);
      notifyListeners();
    } catch (_) {}
  }

  Future<bool> reportUser({
    required String reporterId,
    required String reportedId,
    required ReportReason reason,
    String? description,
  }) async {
    try {
      await _datasource.reportUser(
        reporterId: reporterId,
        reportedId: reportedId,
        reason: reason,
        description: description,
      );
      return true;
    } catch (_) {
      return false;
    }
  }
}
