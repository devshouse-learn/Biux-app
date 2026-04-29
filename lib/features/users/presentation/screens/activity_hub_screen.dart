import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:biux/core/design_system/color_tokens.dart';
import 'package:biux/features/settings/presentation/widgets/settings_shared_widgets.dart';
import 'package:biux/core/design_system/locale_notifier.dart';
import 'package:provider/provider.dart';

class ActivityHubScreen extends StatelessWidget {
  const ActivityHubScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l = Provider.of<LocaleNotifier>(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: SettingsWidgets.scaffoldBackground(isDark),
      appBar: AppBar(
        title: Text(l.t('your_activity')),
        backgroundColor: ColorTokens.primary30,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          SettingsWidgets.buildSectionTitle(
            l.t('interactions_section'),
            isDark,
          ),
          SizedBox(height: 12),
          SettingsWidgets.buildMenuCard(
            context,
            icon: Icons.favorite_outline,
            title: l.t('likes'),
            subtitle: l.t('posts_you_liked'),
            isDark: isDark,
            onTap: () => context.push('/activity/likes'),
          ),
          SizedBox(height: 8),
          SettingsWidgets.buildMenuCard(
            context,
            icon: Icons.chat_bubble_outline,
            title: l.t('comments_label'),
            subtitle: l.t('your_comments'),
            isDark: isDark,
            onTap: () => context.push('/activity/comments'),
          ),
          SizedBox(height: 24),
          SettingsWidgets.buildSectionTitle(l.t('your_content'), isDark),
          SizedBox(height: 12),
          SettingsWidgets.buildMenuCard(
            context,
            icon: Icons.grid_on_outlined,
            title: l.t('posts'),
            subtitle: l.t('your_shared_posts'),
            isDark: isDark,
            onTap: () => context.push('/activity/posts'),
          ),
          SizedBox(height: 8),
          SettingsWidgets.buildMenuCard(
            context,
            icon: Icons.auto_stories_outlined,
            title: l.t('stories'),
            subtitle: l.t('your_recent_stories'),
            isDark: isDark,
            onTap: () => context.push('/activity/stories'),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}
