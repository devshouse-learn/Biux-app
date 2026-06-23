import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:biux/core/design_system/color_tokens.dart';
import 'package:biux/core/design_system/locale_notifier.dart';
import 'package:biux/features/settings/presentation/widgets/settings_shared_widgets.dart';

class ActivityHubScreen extends StatelessWidget {
  const ActivityHubScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: SettingsWidgets.scaffoldBackground(isDark),
      appBar: AppBar(
        title: Text(
          Provider.of<LocaleNotifier>(
            context,
            listen: false,
          ).t('your_activity'),
        ),
        backgroundColor: ColorTokens.primary30,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          SettingsWidgets.buildSectionTitle(Provider.of<LocaleNotifier>(context, listen: false).t('interactions'), isDark),
          const SizedBox(height: 12),
          SettingsWidgets.buildMenuCard(
            context,
            icon: Icons.favorite_outline,
            title: Provider.of<LocaleNotifier>(context, listen: false).t('likes'),
            subtitle: Provider.of<LocaleNotifier>(context, listen: false).t('posts_you_liked'),
            isDark: isDark,
            onTap: () => context.push('/activity/likes'),
          ),
          const SizedBox(height: 8),
          SettingsWidgets.buildMenuCard(
            context,
            icon: Icons.chat_bubble_outline,
            title: Provider.of<LocaleNotifier>(context, listen: false).t('comments'),
            subtitle: Provider.of<LocaleNotifier>(context, listen: false).t('your_comments_on_posts'),
            isDark: isDark,
            onTap: () => context.push('/activity/comments'),
          ),
          const SizedBox(height: 24),
          SettingsWidgets.buildSectionTitle(Provider.of<LocaleNotifier>(context, listen: false).t('your_content'), isDark),
          const SizedBox(height: 12),
          SettingsWidgets.buildMenuCard(
            context,
            icon: Icons.grid_on_outlined,
            title: Provider.of<LocaleNotifier>(context, listen: false).t('posts'),
            subtitle: Provider.of<LocaleNotifier>(context, listen: false).t('your_shared_posts'),
            isDark: isDark,
            onTap: () => context.push('/activity/posts'),
          ),
          const SizedBox(height: 8),
          SettingsWidgets.buildMenuCard(
            context,
            icon: Icons.auto_stories_outlined,
            title: Provider.of<LocaleNotifier>(context, listen: false).t('stories'),
            subtitle: Provider.of<LocaleNotifier>(context, listen: false).t('your_recent_stories'),
            isDark: isDark,
            onTap: () => context.push('/activity/stories'),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}
