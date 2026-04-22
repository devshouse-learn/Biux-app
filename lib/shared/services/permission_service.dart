import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Se necesita permiso de ${_permissionName(permission)}',
            ),
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

  String _permissionName(Permission permission) {
    if (permission == Permission.camera) return 'cámara';
    if (permission == Permission.location) return 'ubicación';
    if (permission == Permission.locationWhenInUse) return 'ubicación';
    if (permission == Permission.microphone) return 'micrófono';
    if (permission == Permission.photos) return 'galería';
    if (permission == Permission.notification) return 'notificaciones';
    if (permission == Permission.contacts) return 'contactos';
    if (permission == Permission.storage) return 'almacenamiento';
    return 'acceso';
  }

  void _showSettingsDialog(BuildContext context, String permissionName) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: isDark ? const Color(0xFF1A2B3C) : Colors.white,
        title: Text(
          'Permiso requerido',
          style: TextStyle(color: isDark ? Colors.white : Colors.black87),
        ),
        content: Text(
          'El permiso de $permissionName fue denegado. '
          'Actívalo desde la configuración de tu dispositivo.',
          style: TextStyle(color: isDark ? Colors.white70 : Colors.black54),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              openAppSettings();
            },
            child: const Text('Abrir configuración'),
          ),
        ],
      ),
    );
  }
}
