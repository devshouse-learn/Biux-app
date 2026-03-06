import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import "package:flutter/foundation.dart";

/// Servicio para gestionar el estado de visualización de historias en almacenamiento local
/// Similar a Instagram, marca qué historias ya fueron vistas por el usuario actual
class StoryViewsLocalService {
  static const String _viewedStoriesKey = 'viewed_stories';
  static const String _lastCleanupKey = 'last_cleanup_date';

  // Las vistas expiran después de 24 horas (como Instagram)
  static const Duration _viewExpirationDuration = Duration(hours: 24);

  /// Obtiene todas las historias vistas (con sus timestamps)
  Future<Map<String, DateTime>> getViewedStories() async {
    final prefs = await SharedPreferences.getInstance();
    final String? viewedStoriesJson = prefs.getString(_viewedStoriesKey);

    if (viewedStoriesJson == null) {
      return {};
    }

    try {
      final Map<String, dynamic> decoded = json.decode(viewedStoriesJson);
      final Map<String, DateTime> viewedStories = {};

      decoded.forEach((key, value) {
        viewedStories[key] = DateTime.parse(value as String);
      });

      return viewedStories;
    } catch (e) {
      debugPrint('Error al decodificar historias vistas: $e');
      return {};
    }
  }

  /// Marca una historia como vista
  Future<void> markStoryAsViewed(String storyId) async {
    final viewedStories = await getViewedStories();
    viewedStories[storyId] = DateTime.now();
    await _saveViewedStories(viewedStories);
  }

  /// Marca múltiples historias como vistas
  Future<void> markStoriesAsViewed(List<String> storyIds) async {
    final viewedStories = await getViewedStories();
    final now = DateTime.now();

    for (final storyId in storyIds) {
      viewedStories[storyId] = now;
    }

    await _saveViewedStories(viewedStories);
  }

  /// Verifica si una historia fue vista
  Future<bool> isStoryViewed(String storyId) async {
    final viewedStories = await getViewedStories();

    if (!viewedStories.containsKey(storyId)) {
      return false;
    }

    final viewedAt = viewedStories[storyId]!;
    final now = DateTime.now();

    // Si la vista expiró (más de 24 horas), considerarla como no vista
    if (now.difference(viewedAt) > _viewExpirationDuration) {
      await _removeExpiredView(storyId);
      return false;
    }

    return true;
  }

  /// Verifica qué historias de una lista fueron vistas
  Future<Map<String, bool>> areStoriesViewed(List<String> storyIds) async {
    final viewedStories = await getViewedStories();
    final now = DateTime.now();
    final Map<String, bool> result = {};

    for (final storyId in storyIds) {
      if (!viewedStories.containsKey(storyId)) {
        result[storyId] = false;
        continue;
      }

      final viewedAt = viewedStories[storyId]!;

      // Verificar si la vista expiró
      if (now.difference(viewedAt) > _viewExpirationDuration) {
        result[storyId] = false;
        await _removeExpiredView(storyId);
      } else {
        result[storyId] = true;
      }
    }

    return result;
  }

  /// Limpia las vistas expiradas (más de 24 horas)
  Future<void> cleanupExpiredViews() async {
    final viewedStories = await getViewedStories();
    final now = DateTime.now();
    final Map<String, DateTime> cleanedStories = {};

    viewedStories.forEach((storyId, viewedAt) {
      if (now.difference(viewedAt) <= _viewExpirationDuration) {
        cleanedStories[storyId] = viewedAt;
      }
    });

    await _saveViewedStories(cleanedStories);
    await _updateLastCleanup();
  }

  /// Limpia todas las vistas (útil para debugging o logout)
  Future<void> clearAllViews() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_viewedStoriesKey);
  }

  /// Verifica si es necesario hacer limpieza automática
  Future<bool> needsCleanup() async {
    final prefs = await SharedPreferences.getInstance();
    final String? lastCleanupStr = prefs.getString(_lastCleanupKey);

    if (lastCleanupStr == null) {
      return true;
    }

    final lastCleanup = DateTime.parse(lastCleanupStr);
    final now = DateTime.now();

    // Hacer limpieza cada 6 horas
    return now.difference(lastCleanup) > const Duration(hours: 6);
  }

  /// Ejecuta limpieza si es necesario
  Future<void> cleanupIfNeeded() async {
    if (await needsCleanup()) {
      await cleanupExpiredViews();
    }
  }

  // --- Métodos privados ---

  /// Guarda el mapa de historias vistas en SharedPreferences
  Future<void> _saveViewedStories(Map<String, DateTime> viewedStories) async {
    final prefs = await SharedPreferences.getInstance();

    final Map<String, String> toSave = {};
    viewedStories.forEach((key, value) {
      toSave[key] = value.toIso8601String();
    });

    final String encoded = json.encode(toSave);
    await prefs.setString(_viewedStoriesKey, encoded);
  }

  /// Elimina una vista expirada
  Future<void> _removeExpiredView(String storyId) async {
    final viewedStories = await getViewedStories();
    viewedStories.remove(storyId);
    await _saveViewedStories(viewedStories);
  }

  /// Actualiza la fecha del último cleanup
  Future<void> _updateLastCleanup() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_lastCleanupKey, DateTime.now().toIso8601String());
  }
}
