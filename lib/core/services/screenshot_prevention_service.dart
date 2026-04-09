import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:biux/core/services/app_logger.dart';

/// Servicio para prevenir capturas de pantalla en secciones sensibles.
///
/// Uso:
/// ```dart
/// // Activar al entrar a pantalla sensible
/// ScreenshotPreventionService.enable();
///
/// // Desactivar al salir
/// ScreenshotPreventionService.disable();
/// ```
///
/// Requiere código nativo en Android (ScreenshotPlugin.kt)
/// y configuración en iOS (info.plist no aplica, se usa UIScreen).
class ScreenshotPreventionService {
  ScreenshotPreventionService._();

  static const _channel = MethodChannel('com.biux.app/screenshot');
  static bool _isEnabled = false;

  static bool get isEnabled => _isEnabled;

  /// Activa la prevención de capturas de pantalla
  static Future<void> enable() async {
    if (_isEnabled) return;
    if (kIsWeb) return;

    try {
      final result = await _channel.invokeMethod<bool>('enableScreenshotPrevention');
      _isEnabled = result ?? false;
      AppLogger.info('Screenshot prevention enabled: $_isEnabled', tag: 'Screenshot');
    } catch (e) {
      AppLogger.error('Error enabling screenshot prevention', error: e, tag: 'Screenshot');
    }
  }

  /// Desactiva la prevención de capturas de pantalla
  static Future<void> disable() async {
    if (!_isEnabled) return;
    if (kIsWeb) return;

    try {
      final result = await _channel.invokeMethod<bool>('disableScreenshotPrevention');
      _isEnabled = !(result ?? false);
      AppLogger.info('Screenshot prevention disabled', tag: 'Screenshot');
    } catch (e) {
      AppLogger.error('Error disabling screenshot prevention', error: e, tag: 'Screenshot');
    }
  }
}
