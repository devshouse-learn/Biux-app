import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:biux/features/ride_recommendations/domain/entities/ride_recommendation_entity.dart';
import 'package:biux/features/ride_recommendations/data/repositories/ride_recommendation_repository_impl.dart';
import 'package:biux/features/ride_tracker/domain/entities/ride_track_entity.dart';
import 'package:biux/features/users/domain/entities/user_entity.dart';

class RideRecommendationProvider extends ChangeNotifier {
  final _repo = RideRecommendationRepositoryImpl();

  List<RideRecommendationEntity> _received = [];
  List<RideRecommendationEntity> _sent = [];
  List<UserEntity> _friends = [];
  bool _loading = false;
  String? _error;

  List<RideRecommendationEntity> get received => _received;
  List<RideRecommendationEntity> get sent => _sent;
  List<UserEntity> get friends => _friends;
  bool get loading => _loading;
  String? get error => _error;
  int get unreadCount => _received.where((r) => !r.isRead).length;

  Future<void> loadRecommendations() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;
    _loading = true;
    notifyListeners();
    try {
      _received = await _repo.getMyRecommendations(uid);
      _sent = await _repo.getSentRecommendations(uid);
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> loadFriends() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;
    try {
      final snap = await FirebaseFirestore.instance
          .collection('follows')
          .where('followerId', isEqualTo: uid)
          .get();

      final ids = snap.docs.map((d) => d['followingId'] as String).toList();
      if (ids.isEmpty) {
        _friends = [];
        notifyListeners();
        return;
      }

      final users = await Future.wait(
        ids.map(
          (id) => FirebaseFirestore.instance.collection('users').doc(id).get(),
        ),
      );

      _friends = users.where((d) => d.exists).map((d) {
        final data = d.data()!;
        return UserEntity(
          id: d.id,
          fullName: data['fullName'] ?? '',
          userName: data['userName'] ?? '',
          email: data['email'] ?? '',
          photo: data['photo'] ?? '',
        );
      }).toList();
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<bool> sendRecommendation({
    required RideTrackEntity track,
    required UserEntity toUser,
    required String routeName,
    required String description,
    required RecommendationType type,
    required List<String> highlights,
    dynamic coverImageFile,
  }) async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return false;
    _loading = true;
    notifyListeners();
    try {
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser.uid)
          .get();
      final userData = userDoc.data() ?? {};

      final rec = RideRecommendationEntity(
        id: '',
        fromUserId: currentUser.uid,
        fromUserName:
            userData['fullName'] ?? userData['userName'] ?? 'Ciclista',
        fromUserPhoto: userData['photo'],
        toUserId: toUser.id,
        trackId: track.id,
        routeName: routeName,
        description: description,
        type: type,
        totalKm: track.totalKm,
        estimatedMinutes: track.durationMinutes > 0
            ? track.durationMinutes
            : (track.durationSeconds ~/ 60),
        avgSpeed: track.avgSpeed,
        calories: track.calories,
        highlights: highlights,
        startLat: track.points.isNotEmpty ? track.points.first.lat : 0,
        startLng: track.points.isNotEmpty ? track.points.first.lng : 0,
        createdAt: DateTime.now(),
      );

      await _repo.sendRecommendation(rec);
      _sent.insert(0, rec);
      _error = null;
      _loading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _loading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> markAsRead(String id) async {
    await _repo.markAsRead(id);
    _received = _received
        .map((r) => r.id == id ? r.copyWith(isRead: true) : r)
        .toList();
    notifyListeners();
  }

  Future<void> deleteRecommendation(String id) async {
    await _repo.deleteRecommendation(id);
    _received.removeWhere((r) => r.id == id);
    _sent.removeWhere((r) => r.id == id);
    notifyListeners();
  }
}
