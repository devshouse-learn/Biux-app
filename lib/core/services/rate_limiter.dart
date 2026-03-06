/// Rate limiter del lado del cliente.
/// Previene que el usuario envíe demasiadas solicitudes en poco tiempo.
class RateLimiter {
  RateLimiter._();

  static final Map<String, DateTime> _lastActions = {};
  static final Map<String, int> _actionCounts = {};
  static final Map<String, DateTime> _windowStarts = {};

  /// Verifica si una acción está permitida.
  ///
  /// - [actionKey]: Identificador único de la acción (ej: 'create_story_user123')
  /// - [cooldown]: Tiempo mínimo entre acciones consecutivas
  /// - [maxActions]: Máximo de acciones permitidas en [window]
  /// - [window]: Ventana de tiempo para contar acciones
  ///
  /// Retorna `true` si la acción está permitida, `false` si debe esperar.
  static bool isAllowed(
    String actionKey, {
    Duration cooldown = const Duration(seconds: 2),
    int maxActions = 10,
    Duration window = const Duration(minutes: 1),
  }) {
    final now = DateTime.now();

    // Verificar cooldown individual
    final lastAction = _lastActions[actionKey];
    if (lastAction != null && now.difference(lastAction) < cooldown) {
      return false;
    }

    // Verificar límite por ventana de tiempo
    final windowStart = _windowStarts[actionKey];
    if (windowStart != null && now.difference(windowStart) > window) {
      // Resetear ventana
      _actionCounts[actionKey] = 0;
      _windowStarts[actionKey] = now;
    }

    final count = _actionCounts[actionKey] ?? 0;
    if (count >= maxActions) {
      return false;
    }

    return true;
  }

  /// Registra que una acción fue ejecutada
  static void record(String actionKey) {
    final now = DateTime.now();
    _lastActions[actionKey] = now;
    _windowStarts[actionKey] ??= now;
    _actionCounts[actionKey] = (_actionCounts[actionKey] ?? 0) + 1;
  }

  /// Ejecuta una acción si está permitida, o retorna null si fue bloqueada
  static Future<T?> execute<T>(
    String actionKey,
    Future<T> Function() action, {
    Duration cooldown = const Duration(seconds: 2),
    int maxActions = 10,
    Duration window = const Duration(minutes: 1),
  }) async {
    if (!isAllowed(
      actionKey,
      cooldown: cooldown,
      maxActions: maxActions,
      window: window,
    )) {
      return null;
    }

    record(actionKey);
    return await action();
  }

  /// Tiempo restante hasta que la acción sea permitida de nuevo
  static Duration? timeUntilAllowed(
    String actionKey, {
    Duration cooldown = const Duration(seconds: 2),
  }) {
    final lastAction = _lastActions[actionKey];
    if (lastAction == null) return null;

    final elapsed = DateTime.now().difference(lastAction);
    if (elapsed >= cooldown) return null;

    return cooldown - elapsed;
  }

  /// Limpia todos los registros (útil al cerrar sesión)
  static void reset() {
    _lastActions.clear();
    _actionCounts.clear();
    _windowStarts.clear();
  }
}
