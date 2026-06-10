import 'package:flutter/foundation.dart';

/// Servicio centralizado de logging
/// Reemplaza debugPrint para mejor control de logs en producción
class AppLogger {
  static const String _prefix = '[BIUX]';
  static bool _isDevelopment = kDebugMode;

  /// Configura si se deben mostrar logs
  static void setDevelopmentMode(bool isDev) {
    _isDevelopment = isDev;
  }

  /// Log de info (no sensible)
  static void info(String message) {
    if (_isDevelopment) {
      debugPrint('$_prefix [INFO] $message');
    }
  }

  /// Log de warning
  static void warning(String message) {
    if (_isDevelopment) {
      debugPrint('$_prefix [WARN] $message');
    }
  }

  /// Log de error (sensible - nunca loguear datos de usuario)
  static void error(String message, [dynamic stackTrace]) {
    if (_isDevelopment) {
      debugPrint('$_prefix [ERROR] $message');
      if (stackTrace != null) {
        debugPrintStack(stackTrace: stackTrace as StackTrace?);
      }
    }
    // En producción, aquí se enviaría a un servicio de analytics/crashlytics
  }

  /// Log de debug (solo desarrollo)
  static void debug(String message) {
    if (_isDevelopment) {
      debugPrint('$_prefix [DEBUG] $message');
    }
  }

  /// Log de seguimiento de transacción (NUNCA incluya datos sensibles)
  static void transaction(String action, String status) {
    if (_isDevelopment) {
      debugPrint('$_prefix [TXN] $action -> $status');
    }
  }
}
