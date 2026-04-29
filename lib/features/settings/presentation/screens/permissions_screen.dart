import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:biux/core/design_system/locale_notifier.dart';
import 'package:biux/shared/services/permission_service.dart';
import 'package:biux/features/settings/presentation/widgets/settings_shared_widgets.dart';

class PermissionsScreen extends StatefulWidget {
  const PermissionsScreen({super.key});

  @override
  State<PermissionsScreen> createState() => _PermissionsScreenState();
}

class _PermissionsScreenState extends State<PermissionsScreen>
    with WidgetsBindingObserver {
  LocaleNotifier get l => Provider.of<LocaleNotifier>(context);

  bool _cameraGranted = false;
  bool _locationGranted = false;
  bool _microphoneGranted = false;
  bool _photosGranted = false;
  bool _notificationsGranted = false;
  bool _contactsGranted = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadPermissions();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _loadPermissions();
    }
  }

  Future<void> _loadPermissions() async {
    final permissions = await PermissionService().loadAllPermissions();
    if (!mounted) return;
    setState(() {
      _cameraGranted = permissions['camera'] ?? false;
      _locationGranted = permissions['location'] ?? false;
      _microphoneGranted = permissions['microphone'] ?? false;
      _photosGranted = permissions['photos'] ?? false;
      _notificationsGranted = permissions['notifications'] ?? false;
      _contactsGranted = permissions['contacts'] ?? false;
    });
  }

  Future<void> _togglePermission(
    Permission permission,
    bool currentValue,
  ) async {
    if (currentValue) {
      await openAppSettings();
    } else {
      final granted = await PermissionService().ensurePermission(
        permission,
        context: context,
      );
      if (granted) _loadPermissions();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: SettingsWidgets.scaffoldBackground(isDark),
      appBar: SettingsWidgets.buildAppBar(context, l.t('permissions')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          SettingsWidgets.buildSectionTitle(l.t('permissions'), isDark),
          SizedBox(height: 12),
          SettingsWidgets.buildToggleCard(
            context: context,
            icon: Icons.camera_alt,
            title: l.t('camera'),
            subtitle: 'Fotos, cámara en chat y reportes',
            isDark: isDark,
            value: _cameraGranted,
            onChanged: (_) =>
                _togglePermission(Permission.camera, _cameraGranted),
          ),
          SizedBox(height: 8),
          SettingsWidgets.buildToggleCard(
            context: context,
            icon: Icons.photo_library,
            title: l.t('gallery_label'),
            subtitle: 'Enviar fotos y videos desde galería',
            isDark: isDark,
            value: _photosGranted,
            onChanged: (_) =>
                _togglePermission(Permission.photos, _photosGranted),
          ),
          SizedBox(height: 8),
          SettingsWidgets.buildToggleCard(
            context: context,
            icon: Icons.location_on,
            title: l.t('location'),
            subtitle: 'GPS, mapa, rodadas y ubicación en chat',
            isDark: isDark,
            value: _locationGranted,
            onChanged: (_) =>
                _togglePermission(Permission.location, _locationGranted),
          ),
          SizedBox(height: 8),
          SettingsWidgets.buildToggleCard(
            context: context,
            icon: Icons.mic,
            title: l.t('microphone'),
            subtitle: 'Notas de voz en chat',
            isDark: isDark,
            value: _microphoneGranted,
            onChanged: (_) =>
                _togglePermission(Permission.microphone, _microphoneGranted),
          ),
          SizedBox(height: 8),
          SettingsWidgets.buildToggleCard(
            context: context,
            icon: Icons.notifications,
            title: l.t('notifications_label'),
            subtitle: 'Mensajes, rodadas y alertas',
            isDark: isDark,
            value: _notificationsGranted,
            onChanged: (_) => _togglePermission(
              Permission.notification,
              _notificationsGranted,
            ),
          ),
          SizedBox(height: 8),
          SettingsWidgets.buildToggleCard(
            context: context,
            icon: Icons.contacts,
            title: l.t('contacts'),
            subtitle: 'Encontrar amigos e invitar ciclistas',
            isDark: isDark,
            value: _contactsGranted,
            onChanged: (_) =>
                _togglePermission(Permission.contacts, _contactsGranted),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}
