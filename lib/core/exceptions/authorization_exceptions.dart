/// Excepciones de autorización y autenticación
abstract class BiuxException implements Exception {
  final String message;
  BiuxException(this.message);

  @override
  String toString() => message;
}

/// Usuario no autenticado
class NotAuthenticatedException extends BiuxException {
  NotAuthenticatedException()
      : super('Usuario no autenticado. Por favor inicia sesión.');
}

/// Usuario no tiene permisos
class UnauthorizedException extends BiuxException {
  UnauthorizedException(String action)
      : super('No tienes permiso para: $action');
}

/// Usuario no es admin
class NotAdminException extends BiuxException {
  NotAdminException()
      : super('Solo administradores pueden realizar esta acción.');
}

/// Recurso no encontrado
class ResourceNotFoundException extends BiuxException {
  ResourceNotFoundException(String resource)
      : super('$resource no encontrado.');
}

/// Operación no válida
class InvalidOperationException extends BiuxException {
  InvalidOperationException(String reason)
      : super('Operación inválida: $reason');
}

/// Error en transacción
class TransactionFailedException extends BiuxException {
  TransactionFailedException(String reason)
      : super('Error en transacción: $reason');
}

/// Límite excedido
class RateLimitException extends BiuxException {
  RateLimitException(String reason)
      : super('Límite excedido: $reason. Intenta más tarde.');
}

/// Validación falló
class ValidationException extends BiuxException {
  ValidationException(String field, String reason)
      : super('Error en validación de $field: $reason');
}
