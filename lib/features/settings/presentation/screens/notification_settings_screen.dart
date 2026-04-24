import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:biux/core/config/router/app_routes.dart';
import 'package:biux/core/design_system/color_tokens.dart';
import 'package:biux/core/design_system/locale_notifier.dart';
import 'package:biux/features/users/presentation/providers/user_provider.dart';
import 'package:biux/features/settings/presentation/widgets/settings_shared_widgets.dart';
import 'notifications_details_screen.dart';
import 'appearance_details_screen.dart';
import 'privacy_details_screen.dart';
import 'permissions_screen.dart';
import 'information_details_screen.dart';

class NotificationSettingsScreen extends StatefulWidget {
  const NotificationSettingsScreen({super.key});

  @override
  State<NotificationSettingsScreen> createState() =>
      _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState
    extends State<NotificationSettingsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<UserProvider>().loadUserData();
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l = Provider.of<LocaleNotifier>(context);

    return Scaffold(
      backgroundColor: SettingsWidgets.scaffoldBackground(isDark),
      appBar: SettingsWidgets.buildAppBar(context, 'Configuración y actividad'),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // ── Tu cuenta ──────────────────────────────────────────
          SettingsWidgets.buildMenuCard(
            context,
            icon: Icons.person_outline,
            title: 'Tu cuenta',
            subtitle: 'Datos personales, sesiones y seguridad',
            isDark: isDark,
            onTap: () => context.push(AppRoutes.accountSettings),
          ),

          const SizedBox(height: 24),

          // ── Cómo usas BIUX ─────────────────────────────────────
          SettingsWidgets.buildSectionTitle('Cómo usas BIUX', isDark),
          const SizedBox(height: 12),
          SettingsWidgets.buildMenuCard(
            context,
            icon: Icons.history,
            title: 'Tu actividad',
            subtitle: 'Likes, comentarios, posts e historias',
            isDark: isDark,
            onTap: () => context.push('/activity'),
          ),
          const SizedBox(height: 8),
          SettingsWidgets.buildMenuCard(
            context,
            icon: Icons.timer_outlined,
            title: 'Administración de tiempo',
            subtitle: 'Tu uso diario de la app',
            isDark: isDark,
            onTap: () => context.push('/activity/screen-time'),
          ),
          const SizedBox(height: 8),
          SettingsWidgets.buildMenuCard(
            context,
            icon: Icons.notifications_outlined,
            title: l.t('notifications'),
            subtitle: l.t('notifications_subtitle'),
            isDark: isDark,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const NotificationsDetailsScreen(),
                ),
              );
            },
          ),

          const SizedBox(height: 24),

          // ── Quién puede ver tu contenido ───────────────────────
          SettingsWidgets.buildSectionTitle(
            'Quién puede ver tu contenido',
            isDark,
          ),
          const SizedBox(height: 12),
          SettingsWidgets.buildMenuCard(
            context,
            icon: Icons.lock_outline,
            title: 'Privacidad de la cuenta',
            subtitle: 'Controla quién puede ver tu perfil',
            isDark: isDark,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const PrivacyDetailsScreen(),
                ),
              );
            },
          ),
          const SizedBox(height: 8),
          SettingsWidgets.buildMenuCard(
            context,
            icon: Icons.block,
            title: 'Bloqueados',
            subtitle: 'Administra usuarios bloqueados',
            isDark: isDark,
            onTap: () => context.push(AppRoutes.blockedUsers),
          ),

          const SizedBox(height: 24),

          // ── Tu app y contenido multimedia ──────────────────────
          SettingsWidgets.buildSectionTitle(
            'Tu app y contenido multimedia',
            isDark,
          ),
          const SizedBox(height: 12),
          SettingsWidgets.buildMenuCard(
            context,
            icon: Icons.security,
            title: 'Permisos',
            subtitle: 'Cámara, ubicación, micrófono y más',
            isDark: isDark,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const PermissionsScreen(),
                ),
              );
            },
          ),
          const SizedBox(height: 8),
          SettingsWidgets.buildMenuCard(
            context,
            icon: Icons.folder_outlined,
            title: 'Archivo y descarga',
            subtitle: 'Gestiona almacenamiento multimedia',
            isDark: isDark,
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('Función en desarrollo'),
                  backgroundColor: Colors.orange.shade600,
                ),
              );
            },
          ),
          const SizedBox(height: 8),
          SettingsWidgets.buildMenuCard(
            context,
            icon: Icons.language,
            title: 'Idioma',
            subtitle: 'Español',
            isDark: isDark,
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('Función en desarrollo'),
                  backgroundColor: Colors.orange.shade600,
                ),
              );
            },
          ),
          const SizedBox(height: 8),
          SettingsWidgets.buildMenuCard(
            context,
            icon: Icons.palette_outlined,
            title: l.t('appearance'),
            subtitle: l.t('appearance_subtitle'),
            isDark: isDark,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const AppearanceDetailsScreen(),
                ),
              );
            },
          ),

          const SizedBox(height: 24),

          // ── Soporte ────────────────────────────────────────────
          SettingsWidgets.buildSectionTitle('Soporte', isDark),
          const SizedBox(height: 12),
          SettingsWidgets.buildMenuCard(
            context,
            icon: Icons.help_outline,
            title: 'Centro de ayuda',
            subtitle: 'Soporte y preguntas frecuentes',
            isDark: isDark,
            onTap: () => context.push(AppRoutes.help),
          ),
          const SizedBox(height: 8),
          SettingsWidgets.buildMenuCard(
            context,
            icon: Icons.info_outline,
            title: l.t('information'),
            subtitle: l.t('information_subtitle'),
            isDark: isDark,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const InformationDetailsScreen(),
                ),
              );
            },
          ),

          const SizedBox(height: 24),

          // ── Acciones de cuenta ─────────────────────────────────
          SettingsWidgets.buildMenuCard(
            context,
            icon: Icons.logout,
            title: 'Cerrar sesión',
            subtitle: 'Salir de tu cuenta actual',
            isDark: isDark,
            onTap: () => _showLogoutDialog(),
          ),
          const SizedBox(height: 8),
          SettingsWidgets.buildMenuCard(
            context,
            icon: Icons.delete_forever,
            title: 'Eliminar cuenta',
            subtitle: 'Eliminar permanentemente tu cuenta',
            isDark: isDark,
            onTap: () => _showDeleteAccountDialog(),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  void _showLogoutDialog() {
    final l = Provider.of<LocaleNotifier>(context, listen: false);
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l.t('logout')),
        content: Text(l.t('sign_out_confirm')),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: Text(l.t('cancel')),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(dialogContext).pop();
              final userProvider = context.read<UserProvider>();
              await userProvider.signOut();
              if (mounted) context.go('/login');
            },
            child: Text(l.t('confirm'), style: const TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _showDeleteAccountDialog() {
    final l = Provider.of<LocaleNotifier>(context, listen: false);
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l.t('delete_account')),
        content: Text(l.t('delete_account_confirm')),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: Text(l.t('cancel')),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(dialogContext).pop();
              final userProvider = context.read<UserProvider>();
              await userProvider.requestAccountDeletion();
              if (mounted) context.go('/login');
            },
            child: Text(l.t('confirm'), style: const TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
