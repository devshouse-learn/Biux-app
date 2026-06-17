import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:biux/core/services/app_logger.dart';
import 'package:biux/core/exceptions/authorization_exceptions.dart';

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

  /// ALTO: Agregar error handling y logging
  static Future<List<OfflineRideEntity>> getAll() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_key);
      if (raw == null) {
        AppLogger.debug(
          'No hay rodadas offline guardadas',
          tag: 'OfflineRideDatasource',
        );
        return [];
      }

      final list = jsonDecode(raw) as List;
      final rides = list
          .map((e) => OfflineRideEntity.fromJson(e as Map<String, dynamic>))
          .toList();

      AppLogger.debug(
        'Rodadas offline cargadas: ${rides.length}',
        tag: 'OfflineRideDatasource',
      );
      return rides;
    } catch (e) {
      AppLogger.error(
        'Error cargando rodadas offline: $e',
        tag: 'OfflineRideDatasource',
        error: e,
      );
      return [];
    }
  }

  /// ALTO: Validar entrada y agregar logging
  static Future<void> save(OfflineRideEntity ride) async {
    try {
      if (ride.id.isEmpty || ride.name.isEmpty) {
        throw ValidationException(
          'ride',
          'ID y nombre de rodada son requeridos',
        );
      }

      final prefs = await SharedPreferences.getInstance();
      final list = await getAll();
      final idx = list.indexWhere((r) => r.id == ride.id);

      if (idx >= 0) {
        list[idx] = ride;
        AppLogger.debug(
          'Rodada offline actualizada: ${ride.id}',
          tag: 'OfflineRideDatasource',
        );
      } else {
        list.add(ride);
        AppLogger.info(
          'Rodada offline guardada: ${ride.id}',
          tag: 'OfflineRideDatasource',
        );
      }

      await prefs.setString(
        _key,
        jsonEncode(list.map((r) => r.toJson()).toList()),
      );
    } on ValidationException catch (e) {
      AppLogger.warning(
        'Validación fallida: ${e.message}',
        tag: 'OfflineRideDatasource',
      );
      rethrow;
    } catch (e) {
      AppLogger.error(
        'Error guardando rodada offline: $e',
        tag: 'OfflineRideDatasource',
        error: e,
      );
      rethrow;
    }
  }

  /// ALTO: Validar entrada, logging y error handling
  static Future<void> markSynced(String id) async {
    try {
      if (id.isEmpty) {
        throw ValidationException('id', 'Ride ID no puede estar vacío');
      }

      final list = await getAll();
      final idx = list.indexWhere((r) => r.id == id);

      if (idx < 0) {
        AppLogger.warning(
          'Rodada offline no encontrada: $id',
          tag: 'OfflineRideDatasource',
        );
        return;
      }

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
        _key,
        jsonEncode(list.map((r) => r.toJson()).toList()),
      );

      AppLogger.info(
        'Rodada marcada como sincronizada: $id',
        tag: 'OfflineRideDatasource',
      );
    } on ValidationException catch (e) {
      AppLogger.warning(
        'Validación fallida: ${e.message}',
        tag: 'OfflineRideDatasource',
      );
      rethrow;
    } catch (e) {
      AppLogger.error(
        'Error marcando rodada como sincronizada: $e',
        tag: 'OfflineRideDatasource',
        error: e,
      );
      rethrow;
    }
  }

  /// ALTO: Agregar logging
  static Future<List<OfflineRideEntity>> getPending() async {
    try {
      final all = await getAll();
      final pending = all.where((r) => !r.synced).toList();

      AppLogger.debug(
        'Rodadas pendientes: ${pending.length}',
        tag: 'OfflineRideDatasource',
      );

      return pending;
    } catch (e) {
      AppLogger.error(
        'Error obteniendo rodadas pendientes: $e',
        tag: 'OfflineRideDatasource',
        error: e,
      );
      return [];
    }
  }

  /// ALTO: Validar entrada, logging y error handling
  static Future<void> delete(String id) async {
    try {
      if (id.isEmpty) {
        throw ValidationException('id', 'Ride ID no puede estar vacío');
      }

      final list = await getAll();
      final initialLength = list.length;
      list.removeWhere((r) => r.id == id);

      if (list.length == initialLength) {
        AppLogger.warning(
          'Rodada offline no encontrada para eliminar: $id',
          tag: 'OfflineRideDatasource',
        );
        return;
      }

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
        _key,
        jsonEncode(list.map((r) => r.toJson()).toList()),
      );

      AppLogger.info(
        'Rodada offline eliminada: $id',
        tag: 'OfflineRideDatasource',
      );
    } on ValidationException catch (e) {
      AppLogger.warning(
        'Validación fallida: ${e.message}',
        tag: 'OfflineRideDatasource',
      );
      rethrow;
    } catch (e) {
      AppLogger.error(
        'Error eliminando rodada offline: $e',
        tag: 'OfflineRideDatasource',
        error: e,
      );
      rethrow;
    }
  }
}
