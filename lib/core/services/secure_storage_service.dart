import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:biux/core/services/app_logger.dart';

/// Servicio de almacenamiento seguro usando Keychain (iOS) y EncryptedSharedPreferences (Android).
class SecureStorageService {
  SecureStorageService._();

  static const _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
    iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock_this_device),
  );

  // Keys
  static const _keyAuthToken = 'auth_token';
  static const _keyRefreshToken = 'refresh_token';
  static const _keyUserId = 'user_id';
  static const _keyBiometricEnabled = 'biometric_enabled';
  static const _keyPinCode = 'pin_code';

  // ══════════════════════════════════════════
  // Tokens de autenticación
  // ══════════════════════════════════════════

  static Future<void> saveAuthToken(String token) async {
    await _write(_keyAuthToken, token);
  }

  static Future<String?> getAuthToken() async {
    return _read(_keyAuthToken);
  }

  static Future<void> saveRefreshToken(String token) async {
    await _write(_keyRefreshToken, token);
  }

  static Future<String?> getRefreshToken() async {
    return _read(_keyRefreshToken);
  }

  // ══════════════════════════════════════════
  // Datos de usuario
  // ══════════════════════════════════════════

  static Future<void> saveUserId(String userId) async {
    await _write(_keyUserId, userId);
  }

  static Future<String?> getUserId() async {
    return _read(_keyUserId);
  }

  // ══════════════════════════════════════════
  // Seguridad biométrica
  // ══════════════════════════════════════════

  static Future<void> setBiometricEnabled(bool enabled) async {
    await _write(_keyBiometricEnabled, enabled.toString());
  }

  static Future<bool> isBiometricEnabled() async {
    final value = await _read(_keyBiometricEnabled);
    return value == 'true';
  }

  static Future<void> savePinCode(String pin) async {
    await _write(_keyPinCode, pin);
  }

  static Future<String?> getPinCode() async {
    return _read(_keyPinCode);
  }

  // ══════════════════════════════════════════
  // Genéricos
  // ══════════════════════════════════════════

  static Future<void> saveValue(String key, String value) async {
    await _write(key, value);
  }

  static Future<String?> getValue(String key) async {
    return _read(key);
  }

  static Future<void> deleteValue(String key) async {
    try {
      await _storage.delete(key: key);
    } catch (e) {
      AppLogger.error('Error eliminando valor seguro', error: e, tag: 'SecureStorage');
    }
  }

  /// Elimina todos los datos seguros (logout completo)
  static Future<void> clearAll() async {
    try {
      await _storage.deleteAll();
      AppLogger.info('Secure storage limpiado', tag: 'SecureStorage');
    } catch (e) {
      AppLogger.error('Error limpiando secure storage', error: e, tag: 'SecureStorage');
    }
  }

  // ══════════════════════════════════════════
  // Helpers privados
  // ══════════════════════════════════════════

  static Future<void> _write(String key, String value) async {
    try {
      await _storage.write(key: key, value: value);
    } catch (e) {
      AppLogger.error('Error escribiendo valor seguro: $key', error: e, tag: 'SecureStorage');
    }
  }

  static Future<String?> _read(String key) async {
    try {
      return await _storage.read(key: key);
    } catch (e) {
      AppLogger.error('Error leyendo valor seguro: $key', error: e, tag: 'SecureStorage');
      return null;
    }
  }
}
