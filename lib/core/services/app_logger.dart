import 'package:flutter/foundation.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';

/// Niveles de logging
enum LogLevel { debug, info, warning, error }

/// Servicio de logging estructurado para toda la app.
///
/// - En debug: imprime en consola con formato
/// - En release: solo warning/error, y envía errores a Crashlytics
class AppLogger {
  AppLogger._();

  static LogLevel _minLevel = kDebugMode ? LogLevel.debug : LogLevel.warning;

  /// Configura el nivel mínimo de log
  static void setMinLevel(LogLevel level) => _minLevel = level;

  /// Log de depuración (solo en debug mode)
  static void debug(String message, {String? tag}) {
    _log(LogLevel.debug, message, tag: tag);
  }

  /// Log informativo
  static void info(String message, {String? tag}) {
    _log(LogLevel.info, message, tag: tag);
  }

  /// Log de advertencia
  static void warning(String message, {String? tag, Object? error}) {
    _log(LogLevel.warning, message, tag: tag, error: error);
  }

  /// Log de error — también envía a Crashlytics en release
  static void error(
    String message, {
    String? tag,
    Object? error,
    StackTrace? stackTrace,
  }) {
    _log(LogLevel.error, message, tag: tag, error: error);

    // Enviar a Crashlytics en release
    if (!kDebugMode && error != null) {
      FirebaseCrashlytics.instance.recordError(
        error,
        stackTrace,
        reason: '[$tag] $message',
      );
    }
  }

  static void _log(
    LogLevel level,
    String message, {
    String? tag,
    Object? error,
  }) {
    if (level.index < _minLevel.index) return;

    final prefix = _prefix(level);
    final tagStr = tag != null ? '[$tag] ' : '';
    final errorStr = error != null ? ' | Error: $error' : '';
    final line = '$prefix $tagStr$message$errorStr';

    // Solo imprimir en debug
    if (kDebugMode) {
      debugPrint(line);
    }
  }

  static String _prefix(LogLevel level) {
    switch (level) {
      case LogLevel.debug:
        return '[DEBUG]';
      case LogLevel.info:
        return '[INFO]';
      case LogLevel.warning:
        return '[WARN]';
      case LogLevel.error:
        return '[ERROR]';
    }
  }
}
