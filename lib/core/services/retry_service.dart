import 'dart:async';
import 'dart:math';
import 'package:biux/core/error/error_handler.dart';
import 'package:biux/core/services/app_logger.dart';

/// Servicio de reintentos con backoff exponencial.
/// Úsalo para operaciones de red que pueden fallar temporalmente.
class RetryService {
  RetryService._();

  /// Ejecuta [operation] con reintentos automáticos.
  ///
  /// - [maxAttempts]: Número máximo de intentos (default: 3)
  /// - [initialDelay]: Delay inicial entre reintentos (default: 500ms)
  /// - [maxDelay]: Delay máximo entre reintentos (default: 8s)
  /// - [shouldRetry]: Función que determina si reintentar basado en el error.
  ///   Por defecto usa [ErrorHandler.isRetryable].
  /// - [onRetry]: Callback opcional llamado antes de cada reintento
  static Future<T> run<T>(
    Future<T> Function() operation, {
    int maxAttempts = 3,
    Duration initialDelay = const Duration(milliseconds: 500),
    Duration maxDelay = const Duration(seconds: 8),
    bool Function(Object error)? shouldRetry,
    void Function(int attempt, Object error)? onRetry,
  }) async {
    final retryCheck = shouldRetry ?? ErrorHandler.isRetryable;

    Object? lastError;

    for (int attempt = 1; attempt <= maxAttempts; attempt++) {
      try {
        return await operation();
      } catch (e, stack) {
        lastError = e;

        if (attempt >= maxAttempts || !retryCheck(e)) {
          Error.throwWithStackTrace(lastError, stack);
        }

        // Backoff exponencial con jitter
        final delay = _calculateDelay(attempt, initialDelay, maxDelay);
        AppLogger.warning(
          'RetryService: intento $attempt/$maxAttempts falló, '
          'reintentando en ${delay.inMilliseconds}ms',
        );

        onRetry?.call(attempt, e);
        await Future.delayed(delay);
      }
    }

    throw lastError ?? Exception('RetryService: todos los intentos fallaron');
  }

  /// Calcula el delay con backoff exponencial + jitter aleatorio
  static Duration _calculateDelay(
    int attempt,
    Duration initialDelay,
    Duration maxDelay,
  ) {
    final exponentialMs = initialDelay.inMilliseconds * pow(2, attempt - 1);
    final jitter = Random().nextInt(initialDelay.inMilliseconds);
    final delayMs = (exponentialMs + jitter).toInt();
    return Duration(milliseconds: min(delayMs, maxDelay.inMilliseconds));
  }
}
