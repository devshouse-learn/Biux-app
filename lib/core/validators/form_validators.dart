/// Sistema de validadores para formularios en Biux
///
/// Proporciona métodos estáticos para validar:
/// - Números de teléfono (Colombia)
/// - Emails
/// - Contraseñas
/// - Nombres
/// - Campos genéricos
///
/// Todos los validadores retornan null si es válido, o un mensaje de error si no lo es.
class FormValidators {
  /// Validar número de teléfono colombiano
  ///
  /// Acepta:
  /// - Números locales: 3112345678 (10 dígitos)
  /// - Con código país: +573112345678 o +57 3112345678
  /// - Con espacios: 311 2345678 o +57 311 234 5678
  /// - Con guiones: 311-234-5678
  ///
  /// Retorna null si es válido, mensaje de error si no
  static String? validatePhoneNumber(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'El número de teléfono es requerido';
    }

    // Limpiar: remover espacios, guiones, paréntesis
    final cleanPhone = value
        .trim()
        .replaceAll(' ', '')
        .replaceAll('-', '')
        .replaceAll('(', '')
        .replaceAll(')', '');

    // Validar que solo contenga dígitos y opcionalmente un + al inicio
    if (!RegExp(r'^\+?[0-9]+$').hasMatch(cleanPhone)) {
      return 'El número debe contener solo dígitos';
    }

    // Validar longitud
    late final String numericOnly;
    if (cleanPhone.startsWith('+')) {
      numericOnly = cleanPhone.substring(1);
    } else {
      numericOnly = cleanPhone;
    }

    // Colombia: +57 (código país) + 10 dígitos
    // O sin código: solo 10 dígitos
    if (cleanPhone.startsWith('+57')) {
      // Formato internacional
      final phoneBody = numericOnly.substring(2); // Remover 57
      if (phoneBody.length != 10) {
        return 'El número debe tener 10 dígitos después del código de país +57';
      }
      // Primer dígito debe ser 3 (teléfono móvil en Colombia)
      if (!phoneBody.startsWith('3')) {
        return 'El número debe comenzar con 3 (móvil Colombia)';
      }
    } else if (numericOnly.length == 10) {
      // Formato local
      if (!numericOnly.startsWith('3')) {
        return 'El número debe comenzar con 3 (móvil Colombia)';
      }
    } else if (numericOnly.length == 12 && numericOnly.startsWith('57')) {
      // Formato sin + pero con código de país
      final phoneBody = numericOnly.substring(2);
      if (!phoneBody.startsWith('3')) {
        return 'El número debe comenzar con 3 (móvil Colombia)';
      }
    } else {
      return 'Formato no válido. Usa: 3112345678 o +573112345678';
    }

    return null; // Válido
  }

  /// Normalizar número de teléfono al formato estándar
  ///
  /// Convierte a: +573112345678 (formato internacional sin espacios)
  static String normalizePhoneNumber(String phoneNumber) {
    final clean = phoneNumber
        .trim()
        .replaceAll(' ', '')
        .replaceAll('-', '')
        .replaceAll('(', '')
        .replaceAll(')', '');

    // Si empieza con +57, está bien
    if (clean.startsWith('+57')) {
      return clean;
    }

    // Si empieza con 57 (sin +), agregamos +
    if (clean.startsWith('57')) {
      return '+$clean';
    }

    // Si tiene 10 dígitos, agregamos +57
    if (clean.length == 10 && RegExp(r'^[0-9]+$').hasMatch(clean)) {
      return '+57$clean';
    }

    // Por defecto, retornar como está
    return clean;
  }

  /// Validar email
  static String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'El email es requerido';
    }

    // Regex simple pero efectivo para emails
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );

    if (!emailRegex.hasMatch(value.trim())) {
      return 'Ingresa un email válido';
    }

    return null;
  }

  /// Validar contraseña fuerte
  ///
  /// Requisitos:
  /// - Mínimo 8 caracteres
  /// - Al menos una mayúscula
  /// - Al menos una minúscula
  /// - Al menos un número
  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'La contraseña es requerida';
    }

    if (value.length < 8) {
      return 'La contraseña debe tener al menos 8 caracteres';
    }

    if (!RegExp(r'[A-Z]').hasMatch(value)) {
      return 'Debe contener al menos una mayúscula';
    }

    if (!RegExp(r'[a-z]').hasMatch(value)) {
      return 'Debe contener al menos una minúscula';
    }

    if (!RegExp(r'[0-9]').hasMatch(value)) {
      return 'Debe contener al menos un número';
    }

    return null;
  }

  /// Validar que dos contraseñas coinciden
  static String? validatePasswordMatch(String? value, String? reference) {
    if (value == null || value.isEmpty) {
      return 'Confirma tu contraseña';
    }

    if (value != reference) {
      return 'Las contraseñas no coinciden';
    }

    return null;
  }

  /// Validar nombre (usuario o nombre completo)
  ///
  /// Acepta: letras, espacios, acentos, guiones
  /// Rechaza: números, caracteres especiales
  static String? validateName(String? value, {String fieldName = 'El nombre'}) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName es requerido';
    }

    if (value.trim().length < 2) {
      return '$fieldName debe tener al menos 2 caracteres';
    }

    if (value.trim().length > 100) {
      return '$fieldName no puede tener más de 100 caracteres';
    }

    // Solo letras, espacios, acentos y guiones
    if (!RegExp(r"^[a-zA-ZáéíóúÁÉÍÓÚñÑ\s\-']+$").hasMatch(value.trim())) {
      return '$fieldName solo puede contener letras y espacios';
    }

    return null;
  }

  /// Validar username (nombre de usuario)
  ///
  /// Acepta: letras minúsculas, números, guiones bajos
  /// Formato: @username o username
  static String? validateUsername(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'El nombre de usuario es requerido';
    }

    String clean = value.trim();
    // Remover @ si está al inicio
    if (clean.startsWith('@')) {
      clean = clean.substring(1);
    }

    if (clean.length < 3) {
      return 'El nombre de usuario debe tener al menos 3 caracteres';
    }

    if (clean.length > 30) {
      return 'El nombre de usuario no puede tener más de 30 caracteres';
    }

    // Solo letras minúsculas, números y guiones bajos
    if (!RegExp(r'^[a-z0-9_]+$').hasMatch(clean)) {
      return 'Solo letras minúsculas, números y guiones bajos (_)';
    }

    return null;
  }

  /// Validar campo genérico (no vacío)
  static String? validateRequired(
    String? value, {
    String fieldName = 'Este campo',
  }) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName es requerido';
    }
    return null;
  }

  /// Validar campo genérico con longitud mínima
  static String? validateMinLength(
    String? value,
    int minLength, {
    String fieldName = 'Este campo',
  }) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName es requerido';
    }

    if (value.trim().length < minLength) {
      return '$fieldName debe tener al menos $minLength caracteres';
    }

    return null;
  }

  /// Validar campo genérico con longitud máxima
  static String? validateMaxLength(
    String? value,
    int maxLength, {
    String fieldName = 'Este campo',
  }) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName es requerido';
    }

    if (value.trim().length > maxLength) {
      return '$fieldName no puede tener más de $maxLength caracteres';
    }

    return null;
  }

  /// Validar campo genérico con rango de longitud
  static String? validateLength(
    String? value,
    int minLength,
    int maxLength, {
    String fieldName = 'Este campo',
  }) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName es requerido';
    }

    final cleanValue = value.trim();
    if (cleanValue.length < minLength || cleanValue.length > maxLength) {
      return '$fieldName debe tener entre $minLength y $maxLength caracteres';
    }

    return null;
  }

  /// Validar que contiene solo caracteres permitidos
  static String? validatePattern(
    String? value,
    RegExp pattern, {
    String fieldName = 'Este campo',
    String errorMessage = 'contiene caracteres no permitidos',
  }) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName es requerido';
    }

    if (!pattern.hasMatch(value.trim())) {
      return '$fieldName $errorMessage';
    }

    return null;
  }

  /// Validar que no contiene caracteres especiales peligrosos
  /// (SQL injection, XSS, etc)
  static String? validateNoSpecialChars(
    String? value, {
    String fieldName = 'Este campo',
  }) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName es requerido';
    }

    // Caracteres peligrosos: comillas, punto y coma, paréntesis, etc
    // Usar List.contains() en lugar de regex complicado
    const dangerousChars = [';', "'", '"', '(', ')', '%', '<', '>', '\\'];
    for (var char in dangerousChars) {
      if (value.contains(char)) {
        return '$fieldName contiene caracteres no permitidos';
      }
    }

    return null;
  }
}
