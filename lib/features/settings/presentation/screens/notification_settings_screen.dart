import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:biux/core/config/router/app_routes.dart';
import 'package:biux/core/design_system/locale_notifier.dart';
import 'package:biux/features/users/presentation/providers/user_provider.dart';
import 'package:biux/features/settings/presentation/widgets/settings_shared_widgets.dart';
import 'notifications_details_screen.dart';
import 'appearance_details_screen.dart';
import 'privacy_details_screen.dart';
import 'permissions_screen.dart';
import 'information_details_screen.dart';
import 'language_selection_screen.dart';
import 'archive_download_screen.dart';

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
      appBar: SettingsWidgets.buildAppBar(
        context,
        l.t('settings_and_activity'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // ── Tu cuenta ──────────────────────────────────────────
          SettingsWidgets.buildMenuCard(
            context,
            icon: Icons.person_outline,
            title: l.t('your_account'),
            subtitle: l.t('personal_data_sessions'),
            isDark: isDark,
            onTap: () => context.push(AppRoutes.accountSettings),
          ),

          SizedBox(height: 24),

          // ── Cómo usas BIUX ─────────────────────────────────────
          SettingsWidgets.buildSectionTitle(l.t('how_you_use_biux'), isDark),
          SizedBox(height: 12),
          SettingsWidgets.buildMenuCard(
            context,
            icon: Icons.history,
            title: l.t('your_activity'),
            subtitle: l.t('likes_comments_posts_stories'),
            isDark: isDark,
            onTap: () => context.push('/activity'),
          ),
          SizedBox(height: 8),
          SettingsWidgets.buildMenuCard(
            context,
            icon: Icons.timer_outlined,
            title: l.t('time_management'),
            subtitle: l.t('daily_app_usage'),
            isDark: isDark,
            onTap: () => context.push('/activity/screen-time'),
          ),
          SizedBox(height: 8),
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

          SizedBox(height: 24),

          // ── Quién puede ver tu contenido ───────────────────────
          SettingsWidgets.buildSectionTitle(l.t('who_can_see_content'), isDark),
          SizedBox(height: 12),
          SettingsWidgets.buildMenuCard(
            context,
            icon: Icons.lock_outline,
            title: l.t('account_privacy'),
            subtitle: l.t('control_who_sees_profile'),
            isDark: isDark,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const PrivacyDetailsScreen()),
              );
            },
          ),
          SizedBox(height: 8),
          SettingsWidgets.buildMenuCard(
            context,
            icon: Icons.block,
            title: l.t('blocked'),
            subtitle: l.t('manage_blocked_users'),
            isDark: isDark,
            onTap: () => context.push(AppRoutes.blockedUsers),
          ),

          SizedBox(height: 24),

          // ── Tu app y contenido multimedia ──────────────────────
          SettingsWidgets.buildSectionTitle(l.t('your_app_and_media'), isDark),
          SizedBox(height: 12),
          SettingsWidgets.buildMenuCard(
            context,
            icon: Icons.security,
            title: l.t('permissions_label'),
            subtitle: l.t('camera_location_mic'),
            isDark: isDark,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const PermissionsScreen()),
              );
            },
          ),
          SizedBox(height: 8),
          SettingsWidgets.buildMenuCard(
            context,
            icon: Icons.save_alt_rounded,
            title: l.t('archive_download'),
            subtitle: l.t('archive_download_subtitle'),
            isDark: isDark,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const ArchiveDownloadScreen(),
                ),
              );
            },
          ),
          SizedBox(height: 8),
          SettingsWidgets.buildMenuCard(
            context,
            icon: Icons.language,
            title: l.t('language'),
            subtitle: l.languageName,
            isDark: isDark,
            onTap: () {
              LanguageSelectionScreen.show(context);
            },
          ),
          SizedBox(height: 8),
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

          SizedBox(height: 24),

          // ── Soporte ────────────────────────────────────────────
          SettingsWidgets.buildSectionTitle(l.t('support'), isDark),
          SizedBox(height: 12),
          SettingsWidgets.buildMenuCard(
            context,
            icon: Icons.help_outline,
            title: l.t('help_center'),
            subtitle: l.t('support_faq'),
            isDark: isDark,
            onTap: () => context.push(AppRoutes.help),
          ),
          SizedBox(height: 8),
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

          SizedBox(height: 24),

          // ── Acciones de cuenta ─────────────────────────────────
          SettingsWidgets.buildMenuCard(
            context,
            icon: Icons.logout,
            title: l.t('close_session'),
            subtitle: l.t('exit_current_account'),
            isDark: isDark,
            onTap: () => _showLogoutDialog(),
          ),
          SizedBox(height: 8),
          SettingsWidgets.buildMenuCard(
            context,
            icon: Icons.delete_forever,
            title: l.t('delete_account_option'),
            subtitle: l.t('delete_account_permanently_option'),
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
            child: Text(
              l.t('confirm'),
              style: const TextStyle(color: Colors.red),
            ),
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
            child: Text(
              l.t('confirm'),
              style: const TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }
}
