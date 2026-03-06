/// Excepciones centralizadas de la aplicación Biux
/// Todas las capas del proyecto deben usar estas excepciones tipadas

/// Excepción base de la aplicación
class AppException implements Exception {
  final String message;
  final String? code;
  final dynamic originalError;
  final StackTrace? stackTrace;

  const AppException({
    required this.message,
    this.code,
    this.originalError,
    this.stackTrace,
  });

  @override
  String toString() => 'AppException($code): $message';
}

/// Error de red (sin conexión, timeout, etc.)
class NetworkException extends AppException {
  const NetworkException({
    required super.message,
    super.code = 'NETWORK_ERROR',
    super.originalError,
    super.stackTrace,
  });
}

/// Error de autenticación (sesión expirada, credenciales inválidas)
class AuthException extends AppException {
  const AuthException({
    required super.message,
    super.code = 'AUTH_ERROR',
    super.originalError,
    super.stackTrace,
  });
}

/// Error de permisos (acceso denegado)
class PermissionException extends AppException {
  const PermissionException({
    required super.message,
    super.code = 'PERMISSION_ERROR',
    super.originalError,
    super.stackTrace,
  });
}

/// Error de validación de datos
class ValidationException extends AppException {
  final Map<String, String>? fieldErrors;

  const ValidationException({
    required super.message,
    this.fieldErrors,
    super.code = 'VALIDATION_ERROR',
    super.originalError,
    super.stackTrace,
  });
}

/// Error de recurso no encontrado
class NotFoundException extends AppException {
  const NotFoundException({
    required super.message,
    super.code = 'NOT_FOUND',
    super.originalError,
    super.stackTrace,
  });
}

/// Error de almacenamiento (Firebase Storage, cache, etc.)
class StorageException extends AppException {
  const StorageException({
    required super.message,
    super.code = 'STORAGE_ERROR',
    super.originalError,
    super.stackTrace,
  });
}

/// Error de límite de tasa (rate limit)
class RateLimitException extends AppException {
  final Duration? retryAfter;

  const RateLimitException({
    required super.message,
    this.retryAfter,
    super.code = 'RATE_LIMIT',
    super.originalError,
    super.stackTrace,
  });
}

/// Error de servidor/backend
class ServerException extends AppException {
  final int? statusCode;

  const ServerException({
    required super.message,
    this.statusCode,
    super.code = 'SERVER_ERROR',
    super.originalError,
    super.stackTrace,
  });
}

/// Error de caché
class CacheException extends AppException {
  const CacheException({
    required super.message,
    super.code = 'CACHE_ERROR',
    super.originalError,
    super.stackTrace,
  });
}
