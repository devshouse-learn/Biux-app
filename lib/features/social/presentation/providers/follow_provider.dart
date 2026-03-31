
import 'package:flutter/foundation.dart';
import 'package:biux/features/social/data/datasources/follow_datasource.dart';

class FollowProvider extends ChangeNotifier {
  final FollowDatasource _ds = FollowDatasource();

  final Map<String, bool> _followingCache = {};
  int _followersCount = 0;
  int _followingCount = 0;
  List<String> _followersList = [];
  List<String> _followingList = [];
  bool _loading = false;

  int get followersCount => _followersCount;
  int get followingCount => _followingCount;
  List<String> get followersList => _followersList;
  List<String> get followingList => _followingList;
  bool get loading => _loading;

  bool isFollowing(String targetUid) => _followingCache[targetUid] ?? false;

  Future<void> checkFollowing(String currentUid, String targetUid) async {
    final result = await _ds.isFollowing(currentUid, targetUid);
    _followingCache[targetUid] = result;
    notifyListeners();
  }

  Future<void> toggleFollow(String currentUid, String targetUid) async {
    final wasFollowing = _followingCache[targetUid] ?? false;
    // Optimistic update
    _followingCache[targetUid] = !wasFollowing;
    if (wasFollowing) {
      _followersCount--;
    } else {
      _followersCount++;
    }
    notifyListeners();

    try {
      if (wasFollowing) {
        await _ds.unfollowUser(currentUid, targetUid);
      } else {
        await _ds.followUser(currentUid, targetUid);
      }
    } catch (e) {
      // Revert on error
      _followingCache[targetUid] = wasFollowing;
      if (wasFollowing) {
        _followersCount++;
      } else {
        _followersCount--;
      }
      notifyListeners();
      debugPrint('Error toggling follow: $e');
    }
  }

  Future<void> loadFollowers(String uid) async {
    _loading = true;
    notifyListeners();
    try {
      _followersList = await _ds.getFollowers(uid);
      _followersCount = _followersList.length;
    } catch (e) {
      debugPrint('Error loading followers: $e');
    }
    _loading = false;
    notifyListeners();
  }

  Future<void> loadFollowing(String uid) async {
    _loading = true;
    notifyListeners();
    try {
      _followingList = await _ds.getFollowing(uid);
      _followingCount = _followingList.length;
    } catch (e) {
      debugPrint('Error loading following: $e');
    }
    _loading = false;
    notifyListeners();
  }
}
