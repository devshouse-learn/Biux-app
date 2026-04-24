import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:biux/core/design_system/color_tokens.dart';
import 'package:biux/features/users/presentation/providers/user_provider.dart';
import 'package:biux/core/design_system/locale_notifier.dart';

/// Pantalla de privacidad con opciones GDPR
class PrivacySettingsScreen extends StatelessWidget {
  const PrivacySettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l = Provider.of<LocaleNotifier>(context);

    return Scaffold(
      backgroundColor: ColorTokens.neutral99,
      appBar: AppBar(
        backgroundColor: ColorTokens.primary10,
        title: Text(
          'Privacidad y datos',
          style: TextStyle(color: Colors.white),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => context.pop(),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _SectionTitle('Tus datos'),
          _PrivacyTile(
            icon: Icons.download,
            title: 'Exportar mis datos',
            subtitle: 'Descarga una copia de toda tu información',
            onTap: () => _exportData(context),
          ),
          _PrivacyTile(
            icon: Icons.visibility_off,
            title: l.t('activity_history'),
            subtitle: 'Gestiona qué actividades quedan registradas',
            onTap: () {},
          ),
          SizedBox(height: 16),
          _SectionTitle(l.t('account_label')),
          _PrivacyTile(
            icon: Icons.lock_reset,
            title: l.t('active_sessions'),
            subtitle: 'Ver y cerrar sesiones en otros dispositivos',
            onTap: () => context.push('/settings/sessions'),
          ),
          _PrivacyTile(
            icon: Icons.delete_forever,
            title: 'Solicitar eliminación de cuenta',
            subtitle: 'Tu cuenta y datos serán eliminados permanentemente',
            color: Colors.red,
            onTap: () => _confirmDeleteAccount(context),
          ),
        ],
      ),
    );
  }

  void _exportData(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Solicitud enviada. Recibirás un email con tus datos en 48h.',
        ),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _confirmDeleteAccount(BuildContext context) {
    final l = Provider.of<LocaleNotifier>(context, listen: false);
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('¿Eliminar cuenta?'),
        content: Text(
          'Esta acción es irreversible. Todos tus datos, grupos y rodadas serán eliminados permanentemente.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l.t('cancel')),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              Navigator.pop(context);
              context.read<UserProvider>().requestAccountDeletion();
            },
            child: Text(l.t('delete'), style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle(this.title);
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 8, top: 8),
    child: Text(
      title,
      style: TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.bold,
        color: Colors.grey.shade500,
        letterSpacing: 0.5,
      ),
    ),
  );
}

class _PrivacyTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final Color? color;
  const _PrivacyTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.color,
  });
  @override
  Widget build(BuildContext context) {
    final c = color ?? ColorTokens.primary10;
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: c.withValues(alpha: 0.1),
          child: Icon(icon, color: c, size: 20),
        ),
        title: Text(
          title,
          style: TextStyle(fontWeight: FontWeight.w600, color: c),
        ),
        subtitle: Text(subtitle, style: TextStyle(color: Colors.grey.shade600)),
        trailing: const Icon(Icons.chevron_right, size: 18),
        onTap: onTap,
      ),
    );
  }
}
