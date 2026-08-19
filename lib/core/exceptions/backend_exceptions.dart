/// Excepciones específicas para backend y capas de datos
import 'package:biux/core/exceptions/authorization_exceptions.dart';

/// Error de red/conectividad
class NetworkException extends BiuxException {
  final int? statusCode;
  NetworkException(String message, {this.statusCode})
    : super(
        'Error de red: $message${statusCode != null ? ' (Código: $statusCode)' : ''}',
      );
}

/// Timeout de operación
class TimeoutException extends BiuxException {
  final Duration duration;
  TimeoutException(this.duration)
    : super(
        'La operación excedió el tiempo límite de ${duration.inSeconds} segundos',
      );
}

/// Error al obtener recurso del servidor
class ServerException extends BiuxException {
  final int statusCode;
  final String? details;
  ServerException(String message, this.statusCode, {this.details})
    : super(
        'Error del servidor ($statusCode): $message${details != null ? '\nDetalles: $details' : ''}',
      );
}

/// OTP o autenticación fallida
class OTPException extends BiuxException {
  OTPException(String message) : super('Error de OTP: $message');
}

/// Error al procesar datos (Firebase, JSON, etc)
class DataProcessingException extends BiuxException {
  DataProcessingException(String resource, String reason)
    : super('Error al procesar $resource: $reason');
}

/// Error de sincronización de datos
class SyncException extends BiuxException {
  SyncException(String resource, String reason)
    : super('Error sincronizando $resource: $reason');
}

/// Recurso no encontrado en el servidor
class ResourceNotFoundOnServerException extends BiuxException {
  ResourceNotFoundOnServerException(String resource)
    : super('$resource no encontrado en el servidor');
}

/// Error al subir archivo
class FileUploadException extends BiuxException {
  FileUploadException(String fileName, String reason)
    : super('Error al subir archivo $fileName: $reason');
}

/// Cuota o límite excedido
class QuotaExceededException extends BiuxException {
  QuotaExceededException(String resource)
    : super('Se ha excedido el límite de $resource. Intenta más tarde.');
}

/// Operación rechazada por reglas de negocio
class BusinessRuleException extends BiuxException {
  BusinessRuleException(String message) : super('Regla de negocio: $message');
}

/// Error genérico de repositorio
class RepositoryException extends BiuxException {
  RepositoryException(String repository, String operation, String reason)
    : super('Error en $repository.$operation(): $reason');
}
