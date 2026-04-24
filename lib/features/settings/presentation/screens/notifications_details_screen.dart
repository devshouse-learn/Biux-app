import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:biux/core/design_system/color_tokens.dart';
import 'package:biux/core/design_system/locale_notifier.dart';
import 'package:biux/features/settings/presentation/providers/notification_settings_provider.dart';
import 'package:biux/features/settings/presentation/widgets/settings_shared_widgets.dart';

class NotificationsDetailsScreen extends StatefulWidget {
  const NotificationsDetailsScreen({super.key});

  @override
  State<NotificationsDetailsScreen> createState() =>
      _NotificationsDetailsScreenState();
}

class _NotificationsDetailsScreenState
    extends State<NotificationsDetailsScreen> {
  @override
  void initState() {
    super.initState();
    // Cargar configuración al abrir la pantalla
    Future.microtask(() {
      if (mounted) {
        context.read<NotificationSettingsProvider>().loadSettings();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l = Provider.of<LocaleNotifier>(context);

    return Scaffold(
      backgroundColor: SettingsWidgets.scaffoldBackground(isDark),
      appBar: SettingsWidgets.buildAppBar(context, l.t('notifications')),
      body:
          Selector<NotificationSettingsProvider, NotificationSettingsProvider>(
            selector: (_, provider) => provider,
            builder: (context, provider, _) {
              final settings = provider.settings;

              if (settings == null && provider.isLoading) {
                return const Center(
                  child: CircularProgressIndicator(
                    color: ColorTokens.primary30,
                  ),
                );
              }

              final enablePushNotifications =
                  settings?.enablePushNotifications ?? true;
              final enableLikes = settings?.enableLikes ?? true;
              final enableComments = settings?.enableComments ?? true;
              final enableFollows = settings?.enableFollows ?? true;
              final enableStories = settings?.enableStories ?? true;
              final enableRideInvitations =
                  settings?.enableRideInvitations ?? true;
              final enableGroupInvitations =
                  settings?.enableGroupInvitations ?? true;
              final enableRideReminders = settings?.enableRideReminders ?? true;
              final enableGroupUpdates = settings?.enableGroupUpdates ?? true;
              final enableSystemNotifications =
                  settings?.enableSystemNotifications ?? true;

              return ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  SettingsWidgets.buildToggleCard(
                    context: context,
                    icon: enablePushNotifications
                        ? Icons.notifications_active
                        : Icons.notifications_off,
                    title: l.t('push_notifications'),
                    subtitle: enablePushNotifications
                        ? l.t('enabled')
                        : l.t('disabled'),
                    isDark: isDark,
                    value: enablePushNotifications,
                    onChanged: provider.togglePushNotifications,
                  ),

                  const SizedBox(height: 12),

                  FutureBuilder<bool>(
                    future: _getSoundEnabled(),
                    initialData: true,
                    builder: (context, snapshot) {
                      return SettingsWidgets.buildToggleCard(
                        context: context,
                        icon: Icons.volume_up,
                        title: l.t('sound'),
                        subtitle: l.t('sound_subtitle'),
                        isDark: isDark,
                        value: snapshot.data ?? true,
                        onChanged: (value) => _setSoundEnabled(value),
                        enabled: enablePushNotifications,
                      );
                    },
                  ),

                  const SizedBox(height: 8),

                  FutureBuilder<bool>(
                    future: _getVibrationEnabled(),
                    initialData: true,
                    builder: (context, snapshot) {
                      return SettingsWidgets.buildToggleCard(
                        context: context,
                        icon: Icons.vibration,
                        title: l.t('vibration'),
                        subtitle: l.t('vibration_subtitle'),
                        isDark: isDark,
                        value: snapshot.data ?? true,
                        onChanged: (value) => _setVibrationEnabled(value),
                        enabled: enablePushNotifications,
                      );
                    },
                  ),

                  SizedBox(height: 24),

                  SettingsWidgets.buildSectionTitle(
                    l.t('social_interactions'),
                    isDark,
                  ),
                  SizedBox(height: 12),
                  SettingsWidgets.buildToggleCard(
                    context: context,
                    icon: Icons.favorite,
                    title: l.t('likes'),
                    subtitle: l.t('likes_subtitle'),
                    isDark: isDark,
                    value: enableLikes,
                    onChanged: provider.toggleLikes,
                    enabled: enablePushNotifications,
                  ),
                  SizedBox(height: 8),
                  SettingsWidgets.buildToggleCard(
                    context: context,
                    icon: Icons.comment,
                    title: l.t('comments'),
                    subtitle: l.t('comments_subtitle'),
                    isDark: isDark,
                    value: enableComments,
                    onChanged: provider.toggleComments,
                    enabled: enablePushNotifications,
                  ),
                  SizedBox(height: 8),
                  SettingsWidgets.buildToggleCard(
                    context: context,
                    icon: Icons.person_add,
                    title: l.t('new_followers'),
                    subtitle: l.t('new_followers_subtitle'),
                    isDark: isDark,
                    value: enableFollows,
                    onChanged: provider.toggleFollows,
                    enabled: enablePushNotifications,
                  ),
                  SizedBox(height: 8),
                  SettingsWidgets.buildToggleCard(
                    context: context,
                    icon: Icons.auto_stories,
                    title: l.t('stories'),
                    subtitle: l.t('stories_subtitle'),
                    isDark: isDark,
                    value: enableStories,
                    onChanged: provider.toggleStories,
                    enabled: enablePushNotifications,
                  ),

                  SizedBox(height: 24),

                  SettingsWidgets.buildSectionTitle(
                    l.t('rides_and_groups'),
                    isDark,
                  ),
                  SizedBox(height: 12),
                  SettingsWidgets.buildToggleCard(
                    context: context,
                    icon: Icons.pedal_bike,
                    title: l.t('ride_invitations'),
                    subtitle: l.t('ride_invitations_subtitle'),
                    isDark: isDark,
                    value: enableRideInvitations,
                    onChanged: provider.toggleRideInvitations,
                    enabled: enablePushNotifications,
                  ),
                  SizedBox(height: 8),
                  SettingsWidgets.buildToggleCard(
                    context: context,
                    icon: Icons.group,
                    title: l.t('group_invitations'),
                    subtitle: l.t('group_invitations_subtitle'),
                    isDark: isDark,
                    value: enableGroupInvitations,
                    onChanged: provider.toggleGroupInvitations,
                    enabled: enablePushNotifications,
                  ),
                  SizedBox(height: 8),
                  SettingsWidgets.buildToggleCard(
                    context: context,
                    icon: Icons.notifications_active,
                    title: l.t('ride_reminders'),
                    subtitle: l.t('ride_reminders_subtitle'),
                    isDark: isDark,
                    value: enableRideReminders,
                    onChanged: provider.toggleRideReminders,
                    enabled: enablePushNotifications,
                  ),
                  SizedBox(height: 8),
                  SettingsWidgets.buildToggleCard(
                    context: context,
                    icon: Icons.update,
                    title: l.t('group_updates'),
                    subtitle: l.t('group_updates_subtitle'),
                    isDark: isDark,
                    value: enableGroupUpdates,
                    onChanged: provider.toggleGroupUpdates,
                    enabled: enablePushNotifications,
                  ),

                  SizedBox(height: 24),

                  SettingsWidgets.buildSectionTitle(l.t('system'), isDark),
                  SizedBox(height: 12),
                  SettingsWidgets.buildToggleCard(
                    context: context,
                    icon: Icons.info_outline,
                    title: l.t('system_notifications'),
                    subtitle: l.t('system_notifications_subtitle'),
                    isDark: isDark,
                    value: enableSystemNotifications,
                    onChanged: provider.toggleSystemNotifications,
                    enabled: enablePushNotifications,
                  ),

                  const SizedBox(height: 32),
                ],
              );
            },
          ),
    );
  }

  Future<bool> _getSoundEnabled() async {
    final prefs = await _getPrefs();
    return prefs.getBool('notification_sound') ?? true;
  }

  Future<bool> _getVibrationEnabled() async {
    final prefs = await _getPrefs();
    return prefs.getBool('notification_vibration') ?? true;
  }

  Future<void> _setSoundEnabled(bool value) async {
    final prefs = await _getPrefs();
    await prefs.setBool('notification_sound', value);
    setState(() {});
  }

  Future<void> _setVibrationEnabled(bool value) async {
    final prefs = await _getPrefs();
    await prefs.setBool('notification_vibration', value);
    setState(() {});
  }

  Future<SharedPreferences> _getPrefs() async {
    return SharedPreferences.getInstance();
  }
}
