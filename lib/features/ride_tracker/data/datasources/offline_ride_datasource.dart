
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class OfflineRideEntity {
  final String id;
  final String name;
  final double distanceKm;
  final int durationSeconds;
  final List<Map<String, double>> points;
  final DateTime startedAt;
  final bool synced;

  const OfflineRideEntity({
    required this.id,
    required this.name,
    required this.distanceKm,
    required this.durationSeconds,
    required this.points,
    required this.startedAt,
    this.synced = false,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'distanceKm': distanceKm,
        'durationSeconds': durationSeconds,
        'points': points,
        'startedAt': startedAt.toIso8601String(),
        'synced': synced,
      };

  factory OfflineRideEntity.fromJson(Map<String, dynamic> json) =>
      OfflineRideEntity(
        id: json['id'],
        name: json['name'],
        distanceKm: (json['distanceKm'] as num).toDouble(),
        durationSeconds: json['durationSeconds'],
        points: (json['points'] as List)
            .map((p) => Map<String, double>.from(p))
            .toList(),
        startedAt: DateTime.parse(json['startedAt']),
        synced: json['synced'] ?? false,
      );
}

class OfflineRideDatasource {
  static const _key = 'offline_rides';

  static Future<List<OfflineRideEntity>> getAll() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw == null) return [];
    final list = jsonDecode(raw) as List;
    return list
        .map((e) => OfflineRideEntity.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  static Future<void> save(OfflineRideEntity ride) async {
    final prefs = await SharedPreferences.getInstance();
    final list = await getAll();
    final idx = list.indexWhere((r) => r.id == ride.id);
    if (idx >= 0) {
      list[idx] = ride;
    } else {
      list.add(ride);
    }
    await prefs.setString(
        _key, jsonEncode(list.map((r) => r.toJson()).toList()));
  }

  static Future<void> markSynced(String id) async {
    final list = await getAll();
    final idx = list.indexWhere((r) => r.id == id);
    if (idx < 0) return;
    final updated = OfflineRideEntity(
      id: list[idx].id,
      name: list[idx].name,
      distanceKm: list[idx].distanceKm,
      durationSeconds: list[idx].durationSeconds,
      points: list[idx].points,
      startedAt: list[idx].startedAt,
      synced: true,
    );
    list[idx] = updated;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
        _key, jsonEncode(list.map((r) => r.toJson()).toList()));
  }

  static Future<List<OfflineRideEntity>> getPending() async {
    final all = await getAll();
    return all.where((r) => !r.synced).toList();
  }

  static Future<void> delete(String id) async {
    final list = await getAll();
    list.removeWhere((r) => r.id == id);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
        _key, jsonEncode(list.map((r) => r.toJson()).toList()));
  }
}
