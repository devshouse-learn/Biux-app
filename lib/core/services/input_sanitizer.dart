/// Servicio de sanitización y validación de inputs.
/// Previene inyección de datos y asegura formatos correctos.
class InputSanitizer {
  InputSanitizer._();

  /// Límites de longitud por tipo de campo
  static const int maxNameLength = 100;
  static const int maxDescriptionLength = 2000;
  static const int maxCommentLength = 1000;
  static const int maxTagLength = 50;
  static const int maxUrlLength = 2048;
  static const int maxSearchQueryLength = 200;
  static const int maxUsernameLength = 30;
  static const int maxEmailLength = 254;

  /// Sanitiza texto general: trim + limita longitud + remueve caracteres de control
  static String sanitizeText(String input, {int? maxLength}) {
    final max = maxLength ?? maxDescriptionLength;
    var sanitized = input.trim();

    // Remover caracteres de control (excepto newlines y tabs)
    sanitized = sanitized.replaceAll(RegExp(r'[\x00-\x08\x0B\x0C\x0E-\x1F]'), '');

    // Limitar longitud
    if (sanitized.length > max) {
      sanitized = sanitized.substring(0, max);
    }

    return sanitized;
  }

  /// Sanitiza nombre de usuario
  static String sanitizeName(String input) {
    return sanitizeText(input, maxLength: maxNameLength);
  }

  /// Sanitiza username (solo alfanuméricos, underscores, puntos)
  static String sanitizeUsername(String input) {
    var sanitized = input.trim().toLowerCase();
    sanitized = sanitized.replaceAll(RegExp(r'[^a-z0-9._]'), '');
    if (sanitized.length > maxUsernameLength) {
      sanitized = sanitized.substring(0, maxUsernameLength);
    }
    return sanitized;
  }

  /// Sanitiza descripción/comentario
  static String sanitizeDescription(String input) {
    return sanitizeText(input, maxLength: maxDescriptionLength);
  }

  /// Sanitiza comentario
  static String sanitizeComment(String input) {
    return sanitizeText(input, maxLength: maxCommentLength);
  }

  /// Sanitiza query de búsqueda
  static String sanitizeSearchQuery(String input) {
    var sanitized = sanitizeText(input, maxLength: maxSearchQueryLength);
    // Remover caracteres especiales de regex
    sanitized = sanitized.replaceAll(RegExp(r'[\\^$.|?*+(){}[\]]'), '');
    return sanitized;
  }

  /// Sanitiza tag/etiqueta
  static String sanitizeTag(String input) {
    var sanitized = input.trim().toLowerCase();
    sanitized = sanitized.replaceAll(RegExp(r'[^a-záéíóúüñ0-9_\- ]'), '');
    if (sanitized.length > maxTagLength) {
      sanitized = sanitized.substring(0, maxTagLength);
    }
    return sanitized;
  }

  /// Valida formato de email
  static bool isValidEmail(String email) {
    if (email.length > maxEmailLength) return false;
    return RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$')
        .hasMatch(email);
  }

  /// Valida formato de teléfono colombiano
  static bool isValidPhoneNumber(String phone) {
    final cleaned = phone.replaceAll(RegExp(r'[\s\-+]'), '');
    // Acepta: 3XXXXXXXXX, 573XXXXXXXXX
    return RegExp(r'^(57)?3\d{9}$').hasMatch(cleaned);
  }

  /// Valida que una URL sea segura (https)
  static bool isValidUrl(String url) {
    if (url.length > maxUrlLength) return false;
    try {
      final uri = Uri.parse(url);
      return uri.scheme == 'https' && uri.host.isNotEmpty;
    } catch (_) {
      return false;
    }
  }

  /// Valida Firebase Storage URL
  static bool isValidFirebaseStorageUrl(String url) {
    return url.startsWith('https://firebasestorage.googleapis.com/') ||
        url.startsWith('https://storage.googleapis.com/');
  }

  /// Sanitiza un mapa de datos antes de guardar en Firestore
  static Map<String, dynamic> sanitizeMap(Map<String, dynamic> data) {
    return data.map((key, value) {
      if (value is String) {
        return MapEntry(key, sanitizeText(value));
      }
      if (value is Map<String, dynamic>) {
        return MapEntry(key, sanitizeMap(value));
      }
      return MapEntry(key, value);
    });
  }
}
