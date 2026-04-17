import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:biux/core/services/remote_config_service.dart';
import 'package:biux/core/services/app_logger.dart';

/// Servicio para verificar actualizaciones de la app.
///
/// Lee desde Firestore (via RemoteConfigService):
/// - `min_version`: versión mínima requerida (force update)
/// - `latest_version`: última versión disponible (update sugerido)
/// - `update_url_ios`: URL de App Store
/// - `update_url_android`: URL de Play Store
/// - `maintenance_mode`: si la app está en mantenimiento
/// - `maintenance_message`: mensaje de mantenimiento
class AppUpdateService {
  AppUpdateService._();

  static PackageInfo? _packageInfo;

  static Future<void> initialize() async {
    _packageInfo = await PackageInfo.fromPlatform();
    AppLogger.info(
      'App version: ${_packageInfo!.version}+${_packageInfo!.buildNumber}',
      tag: 'AppUpdate',
    );
  }

  static String get currentVersion => _packageInfo?.version ?? '0.0.0';
  static String get currentBuildNumber => _packageInfo?.buildNumber ?? '0';
  static String get packageName => _packageInfo?.packageName ?? '';

  static bool isForceUpdateRequired() {
    final config = RemoteConfigService();
    final minVersion = config.getString('min_version', defaultValue: '1.0.0');
    final result = _isVersionLower(currentVersion, minVersion);
    if (result) {
      AppLogger.warning(
        'Force update requerido: $currentVersion < $minVersion',
        tag: 'AppUpdate',
      );
    }
    return result;
  }

  static bool isOptionalUpdateAvailable() {
    final config = RemoteConfigService();
    final latestVersion = config.getString(
      'latest_version',
      defaultValue: '1.0.0',
    );
    return _isVersionLower(currentVersion, latestVersion);
  }

  static bool isMaintenanceMode() {
    final config = RemoteConfigService();
    return config.getBool('maintenance_mode', defaultValue: false);
  }

  static String get maintenanceMessage {
    final config = RemoteConfigService();
    return config.getString(
      'maintenance_message',
      defaultValue: 'La app está en mantenimiento. Vuelve pronto.',
    );
  }

  static String getUpdateUrl(TargetPlatform platform) {
    final config = RemoteConfigService();
    if (platform == TargetPlatform.iOS) {
      return config.getString('update_url_ios', defaultValue: '');
    }
    return config.getString('update_url_android', defaultValue: '');
  }

  static bool _isVersionLower(String v1, String v2) {
    try {
      final parts1 = v1.split('.').map(int.parse).toList();
      final parts2 = v2.split('.').map(int.parse).toList();
      while (parts1.length < 3) {
        parts1.add(0);
      }
      while (parts2.length < 3) {
        parts2.add(0);
      }
      for (var i = 0; i < 3; i++) {
        if (parts1[i] < parts2[i]) return true;
        if (parts1[i] > parts2[i]) return false;
      }
      return false;
    } catch (e) {
      AppLogger.error(
        'Error comparando versiones: $v1 vs $v2',
        error: e,
        tag: 'AppUpdate',
      );
      return false;
    }
  }

  static Future<void> showForceUpdateDialog(BuildContext context) async {
    final platform = Theme.of(context).platform;
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => PopScope(
        canPop: false,
        child: AlertDialog(
          title: const Text('Actualización requerida'),
          content: const Text(
            'Hay una nueva versión disponible que es obligatoria para seguir usando Biux. '
            'Por favor actualiza la app.',
          ),
          actions: [
            FilledButton(
              onPressed: () => _openStore(platform),
              child: const Text('Actualizar'),
            ),
          ],
        ),
      ),
    );
  }

  static Future<void> showOptionalUpdateDialog(BuildContext context) async {
    final platform = Theme.of(context).platform;
    await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Nueva versión disponible'),
        content: const Text(
          'Hay una nueva versión de Biux disponible con mejoras y correcciones.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Más tarde'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              _openStore(platform);
            },
            child: const Text('Actualizar'),
          ),
        ],
      ),
    );
  }

  static Future<void> showMaintenanceDialog(BuildContext context) async {
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => PopScope(
        canPop: false,
        child: AlertDialog(
          icon: const Icon(Icons.construction_rounded, size: 48),
          title: const Text('Mantenimiento'),
          content: Text(maintenanceMessage),
          actions: [
            FilledButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Reintentar'),
            ),
          ],
        ),
      ),
    );
  }

  static Future<void> checkOnStartup(BuildContext context) async {
    if (isMaintenanceMode()) {
      if (context.mounted) await showMaintenanceDialog(context);
      return;
    }
    if (isForceUpdateRequired()) {
      if (context.mounted) await showForceUpdateDialog(context);
      return;
    }
    if (isOptionalUpdateAvailable()) {
      if (context.mounted) await showOptionalUpdateDialog(context);
    }
  }

  static void _openStore(TargetPlatform platform) {
    final url = getUpdateUrl(platform);
    if (url.isNotEmpty) {
      AppLogger.info('Abriendo store: $url', tag: 'AppUpdate');
    }
  }
}
