import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:biux/core/design_system/locale_notifier.dart';
import 'package:provider/provider.dart';

/// Servicio centralizado de permisos.
/// Verifica si el permiso ya fue concedido en configuración de la app
/// antes de solicitarlo al sistema operativo.
class PermissionService {
  static final PermissionService _instance = PermissionService._();
  factory PermissionService() => _instance;
  PermissionService._();

  // Keys en SharedPreferences
  static const _kCamera = 'camera_permission';
  static const _kLocation = 'location_permission';
  static const _kMicrophone = 'microphone_permission';
  static const _kPhotos = 'photos_permission';
  static const _kNotifications = 'notifications_permission';
  static const _kContacts = 'contacts_permission';
  static const _kStorage = 'storage_permission';

  /// Verifica y solicita un permiso. Si ya está concedido (sistema), retorna true.
  /// Si el usuario lo tiene activado en la config de la app, solicita silenciosamente.
  /// Si no está activado en la config, solicita al sistema y guarda el resultado.
  Future<bool> ensurePermission(
    Permission permission, {
    BuildContext? context,
  }) async {
    // Primero verificar si ya está concedido en el sistema
    final currentStatus = await permission.status;
    if (currentStatus.isGranted || currentStatus.isLimited) {
      // Sincronizar con SharedPreferences
      await _syncPermission(permission, true);
      return true;
    }

    // Verificar si fue permanentemente denegado
    if (currentStatus.isPermanentlyDenied) {
      if (context != null && context.mounted) {
        _showSettingsDialog(context, _permissionName(permission));
      }
      return false;
    }

    // Solicitar permiso al sistema
    final result = await permission.request();
    final granted = result.isGranted || result.isLimited;
    await _syncPermission(permission, granted);

    if (!granted && context != null && context.mounted) {
      if (result.isPermanentlyDenied) {
        _showSettingsDialog(context, _permissionName(permission));
      } else {
        final l = Provider.of<LocaleNotifier>(context, listen: false);
        final name = _permissionName(permission, l: l);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l.t('permission_need_msg').replaceAll('@name', name)),
          ),
        );
      }
    }
    return granted;
  }

  /// Verifica si un permiso está concedido sin solicitarlo.
  Future<bool> isGranted(Permission permission) async {
    final status = await permission.status;
    return status.isGranted || status.isLimited;
  }

  /// Carga el estado de todos los permisos desde el sistema.
  Future<Map<String, bool>> loadAllPermissions() async {
    return {
      'camera': await isGranted(Permission.camera),
      'location': await isGranted(Permission.location),
      'microphone': await isGranted(Permission.microphone),
      'photos': await isGranted(Permission.photos),
      'notifications': await isGranted(Permission.notification),
      'contacts': await isGranted(Permission.contacts),
      'storage': await isGranted(Permission.storage),
    };
  }

  /// Solicita un permiso específico y guarda el resultado.
  Future<bool> requestAndSave(Permission permission) async {
    final status = await permission.request();
    final granted = status.isGranted || status.isLimited;
    await _syncPermission(permission, granted);
    return granted;
  }

  Future<void> _syncPermission(Permission permission, bool granted) async {
    final prefs = await SharedPreferences.getInstance();
    final key = _keyForPermission(permission);
    if (key != null) {
      await prefs.setBool(key, granted);
    }
  }

  String? _keyForPermission(Permission permission) {
    if (permission == Permission.camera) return _kCamera;
    if (permission == Permission.location) return _kLocation;
    if (permission == Permission.locationWhenInUse) return _kLocation;
    if (permission == Permission.microphone) return _kMicrophone;
    if (permission == Permission.photos) return _kPhotos;
    if (permission == Permission.notification) return _kNotifications;
    if (permission == Permission.contacts) return _kContacts;
    if (permission == Permission.storage) return _kStorage;
    return null;
  }

  String _permissionName(Permission permission, {LocaleNotifier? l}) {
    if (l == null) {
      // Fallback sin context
      if (permission == Permission.camera) return 'camera';
      if (permission == Permission.location) return 'location';
      if (permission == Permission.locationWhenInUse) return 'location';
      if (permission == Permission.microphone) return 'microphone';
      if (permission == Permission.photos) return 'gallery';
      if (permission == Permission.notification) return 'notifications';
      if (permission == Permission.contacts) return 'contacts';
      if (permission == Permission.storage) return 'storage';
      return 'access';
    }
    if (permission == Permission.camera) return l.t('perm_camera');
    if (permission == Permission.location) return l.t('perm_location');
    if (permission == Permission.locationWhenInUse) return l.t('perm_location');
    if (permission == Permission.microphone) return l.t('perm_microphone');
    if (permission == Permission.photos) return l.t('perm_gallery');
    if (permission == Permission.notification) return l.t('perm_notifications');
    if (permission == Permission.contacts) return l.t('perm_contacts');
    if (permission == Permission.storage) return l.t('perm_storage');
    return l.t('perm_access');
  }

  void _showSettingsDialog(BuildContext context, String permissionName) {
    final l = Provider.of<LocaleNotifier>(context, listen: false);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: isDark ? const Color(0xFF1A2B3C) : Colors.white,
        title: Text(
          l.t('permission_required'),
          style: TextStyle(color: isDark ? Colors.white : Colors.black87),
        ),
        content: Text(
          l.t('permission_denied_msg').replaceAll('@name', permissionName),
          style: TextStyle(color: isDark ? Colors.white70 : Colors.black54),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(l.t('cancel')),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              openAppSettings();
            },
            child: Text(l.t('open_settings')),
          ),
        ],
      ),
    );
  }
}
