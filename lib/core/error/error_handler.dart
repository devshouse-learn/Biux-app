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
        message: 'Sin conexión a internet. Verifica tu red.',
        originalError: error,
        stackTrace: stack,
      );
    }

    // Timeout
    if (error is TimeoutException) {
      return NetworkException(
        message: 'La operación tardó demasiado. Intenta de nuevo.',
        code: 'TIMEOUT',
        originalError: error,
        stackTrace: stack,
      );
    }

    // FormatException
    if (error is FormatException) {
      return ValidationException(
        message: 'Datos con formato inválido.',
        originalError: error,
        stackTrace: stack,
      );
    }

    // Genérico
    final msg = error.toString();

    if (msg.contains('network') || msg.contains('connection')) {
      return NetworkException(
        message: 'Error de conexión. Verifica tu red.',
        originalError: error,
        stackTrace: stack,
      );
    }

    if (msg.contains('permission') || msg.contains('PERMISSION_DENIED')) {
      return PermissionException(
        message: 'No tienes permisos para esta acción.',
        originalError: error,
        stackTrace: stack,
      );
    }

    return AppException(
      message: 'Ocurrió un error inesperado. Intenta de nuevo.',
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
        message = 'Número de teléfono inválido. Verifica el formato.';
        break;
      case 'too-many-requests':
        message = 'Demasiados intentos. Espera unos minutos.';
        break;
      case 'session-expired':
        message = 'La sesión expiró. Solicita un nuevo código.';
        break;
      case 'invalid-verification-code':
        message = 'Código de verificación inválido.';
        break;
      case 'user-disabled':
        message = 'Tu cuenta ha sido deshabilitada.';
        break;
      case 'credential-already-in-use':
        message = 'Este número ya está asociado a otra cuenta.';
        break;
      case 'network-request-failed':
        message = 'Sin conexión a internet.';
        break;
      default:
        message = error.message ?? 'Error de autenticación.';
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
          message: 'No tienes permisos para esta acción.',
          originalError: error,
          stackTrace: stack,
        );
      case 'not-found':
        return NotFoundException(
          message: 'El recurso solicitado no existe.',
          originalError: error,
          stackTrace: stack,
        );
      case 'unavailable':
        return NetworkException(
          message: 'Servicio no disponible. Intenta más tarde.',
          originalError: error,
          stackTrace: stack,
        );
      case 'cancelled':
        return AppException(
          message: 'Operación cancelada.',
          code: 'CANCELLED',
          originalError: error,
          stackTrace: stack,
        );
      case 'resource-exhausted':
        return RateLimitException(
          message: 'Límite de solicitudes alcanzado. Espera un momento.',
          originalError: error,
          stackTrace: stack,
        );
      default:
        return ServerException(
          message: error.message ?? 'Error del servidor.',
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
