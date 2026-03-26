import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:biux/core/error/app_exceptions.dart';

/// Manejador centralizado de errores.
/// Convierte excepciones genéricas en [AppException] tipadas
/// y genera mensajes amigables para el usuario.
class ErrorHandler {
  ErrorHandler._();

  /// Convierte cualquier excepción en un mensaje legible para el usuario
  static String getUserMessage(Object error) {
    if (error is AppException) return error.message;
    final appException = fromException(error);
    return appException.message;
  }

  /// Convierte excepciones externas en [AppException] tipadas
  static AppException fromException(Object error, [StackTrace? stack]) {
    // Ya es AppException
    if (error is AppException) return error;

    // Firebase Auth
    if (error is FirebaseAuthException) {
      return _handleFirebaseAuth(error, stack);
    }

    // Firestore
    if (error is FirebaseException) {
      return _handleFirebase(error, stack);
    }

    // Red / Socket
    if (error is SocketException) {
      return NetworkException(
        message: 'err_no_connection',
        originalError: error,
        stackTrace: stack,
      );
    }

    // Timeout
    if (error is TimeoutException) {
      return NetworkException(
        message: 'err_timeout',
        code: 'TIMEOUT',
        originalError: error,
        stackTrace: stack,
      );
    }

    // FormatException
    if (error is FormatException) {
      return ValidationException(
        message: 'err_invalid_format',
        originalError: error,
        stackTrace: stack,
      );
    }

    // Genérico
    final msg = error.toString();

    if (msg.contains('network') || msg.contains('connection')) {
      return NetworkException(
        message: 'err_connection',
        originalError: error,
        stackTrace: stack,
      );
    }

    if (msg.contains('permission') || msg.contains('PERMISSION_DENIED')) {
      return PermissionException(
        message: 'err_no_permission',
        originalError: error,
        stackTrace: stack,
      );
    }

    return AppException(
      message: 'err_unexpected',
      code: 'UNKNOWN',
      originalError: error,
      stackTrace: stack,
    );
  }

  static AuthException _handleFirebaseAuth(
    FirebaseAuthException error,
    StackTrace? stack,
  ) {
    final String message;
    switch (error.code) {
      case 'invalid-phone-number':
        message = 'err_invalid_phone';
        break;
      case 'too-many-requests':
        message = 'err_too_many_requests';
        break;
      case 'session-expired':
        message = 'err_session_expired';
        break;
      case 'invalid-verification-code':
        message = 'err_invalid_verification_code';
        break;
      case 'user-disabled':
        message = 'err_user_disabled';
        break;
      case 'credential-already-in-use':
        message = 'err_credential_in_use';
        break;
      case 'network-request-failed':
        message = 'err_no_internet';
        break;
      default:
        message = error.message ?? 'err_auth_generic';
    }
    return AuthException(
      message: message,
      code: error.code,
      originalError: error,
      stackTrace: stack,
    );
  }

  static AppException _handleFirebase(
    FirebaseException error,
    StackTrace? stack,
  ) {
    switch (error.code) {
      case 'permission-denied':
        return PermissionException(
          message: 'err_no_permission',
          originalError: error,
          stackTrace: stack,
        );
      case 'not-found':
        return NotFoundException(
          message: 'err_resource_not_found',
          originalError: error,
          stackTrace: stack,
        );
      case 'unavailable':
        return NetworkException(
          message: 'err_service_unavailable',
          originalError: error,
          stackTrace: stack,
        );
      case 'cancelled':
        return AppException(
          message: 'err_operation_cancelled',
          code: 'CANCELLED',
          originalError: error,
          stackTrace: stack,
        );
      case 'resource-exhausted':
        return RateLimitException(
          message: 'err_rate_limit',
          originalError: error,
          stackTrace: stack,
        );
      default:
        return ServerException(
          message: error.message ?? 'err_server',
          originalError: error,
          stackTrace: stack,
        );
    }
  }

  /// Determina si un error es recuperable (vale la pena reintentar)
  static bool isRetryable(Object error) {
    if (error is NetworkException) return true;
    if (error is RateLimitException) return true;
    if (error is SocketException) return true;
    if (error is TimeoutException) return true;

    if (error is FirebaseException) {
      return const [
        'unavailable',
        'deadline-exceeded',
        'resource-exhausted',
      ].contains(error.code);
    }

    final msg = error.toString().toLowerCase();
    return msg.contains('timeout') ||
        msg.contains('network') ||
        msg.contains('connection') ||
        msg.contains('unavailable');
  }
}

class TimeoutException implements Exception {
  final String? message;
  const TimeoutException([this.message]);
}
