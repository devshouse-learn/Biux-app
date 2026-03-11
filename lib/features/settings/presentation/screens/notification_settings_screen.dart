import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/design_system/locale_notifier.dart';
import '../widgets/settings_shared_widgets.dart';
import 'notifications_details_screen.dart';
import 'appearance_details_screen.dart';
import 'privacy_details_screen.dart';
import 'information_details_screen.dart';

class NotificationSettingsScreen extends StatelessWidget {
  const NotificationSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l = Provider.of<LocaleNotifier>(context);

    return Scaffold(
      backgroundColor: SettingsWidgets.scaffoldBackground(isDark),
      appBar: SettingsWidgets.buildAppBar(context, l.t('settings')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const SizedBox(height: 8),
          SettingsWidgets.buildSectionTitle(l.t('preferences'), isDark),
          const SizedBox(height: 16),
          SettingsWidgets.buildMenuCard(
            context,
            icon: Icons.notifications,
            title: l.t('notifications'),
            subtitle: l.t('notifications_subtitle'),
            isDark: isDark,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const NotificationsDetailsScreen(),
                ),
              );
            },
          ),
          const SizedBox(height: 12),
          SettingsWidgets.buildMenuCard(
            context,
            icon: Icons.palette,
            title: l.t('appearance'),
            subtitle: l.t('appearance_subtitle'),
            isDark: isDark,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AppearanceScreenDetails(),
                ),
              );
            },
          ),
          const SizedBox(height: 12),
          SettingsWidgets.buildMenuCard(
            context,
            icon: Icons.security,
            title: l.t('privacy'),
            subtitle: l.t('privacy_subtitle'),
            isDark: isDark,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const PrivacyDetailsScreen(),
                ),
              );
            },
          ),
          const SizedBox(height: 12),
          SettingsWidgets.buildMenuCard(
            context,
            icon: Icons.info,
            title: l.t('information'),
            subtitle: l.t('information_subtitle'),
            isDark: isDark,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const InformationDetailsScreen(),
                ),
              );
            },
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}
