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
          l.t('privacy_and_data'),
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
          _SectionTitle(l.t('your_data')),
          _PrivacyTile(
            icon: Icons.download,
            title: l.t('export_my_data'),
            subtitle: l.t('download_copy_info'),
            onTap: () => _exportData(context),
          ),
          _PrivacyTile(
            icon: Icons.visibility_off,
            title: l.t('activity_history'),
            subtitle: l.t('manage_activity_log'),
            onTap: () {},
          ),
          SizedBox(height: 16),
          _SectionTitle(l.t('account_label')),
          _PrivacyTile(
            icon: Icons.lock_reset,
            title: l.t('active_sessions'),
            subtitle: l.t('view_close_sessions'),
            onTap: () => context.push('/settings/sessions'),
          ),
          _PrivacyTile(
            icon: Icons.delete_forever,
            title: l.t('request_account_deletion'),
            subtitle: l.t('account_deleted_permanently'),
            color: Colors.red,
            onTap: () => _confirmDeleteAccount(context),
          ),
        ],
      ),
    );
  }

  void _exportData(BuildContext context) {
    final l = Provider.of<LocaleNotifier>(context, listen: false);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(l.t('data_export_sent')),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _confirmDeleteAccount(BuildContext context) {
    final l = Provider.of<LocaleNotifier>(context, listen: false);
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(l.t('delete_account_question')),
        content: Text(l.t('delete_account_irreversible')),
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
