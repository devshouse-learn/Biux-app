import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:biux/core/design_system/color_tokens.dart';
import 'package:biux/features/settings/presentation/widgets/settings_shared_widgets.dart';

class ActivityHubScreen extends StatelessWidget {
  const ActivityHubScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: SettingsWidgets.scaffoldBackground(isDark),
      appBar: AppBar(
        title: const Text('Tu actividad'),
        backgroundColor: ColorTokens.primary30,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          SettingsWidgets.buildSectionTitle('Interacciones', isDark),
          const SizedBox(height: 12),
          SettingsWidgets.buildMenuCard(
            context,
            icon: Icons.favorite_outline,
            title: 'Likes',
            subtitle: 'Publicaciones que te gustaron',
            isDark: isDark,
            onTap: () => context.push('/activity/likes'),
          ),
          const SizedBox(height: 8),
          SettingsWidgets.buildMenuCard(
            context,
            icon: Icons.chat_bubble_outline,
            title: 'Comentarios',
            subtitle: 'Tus comentarios en publicaciones',
            isDark: isDark,
            onTap: () => context.push('/activity/comments'),
          ),
          const SizedBox(height: 24),
          SettingsWidgets.buildSectionTitle('Tu contenido', isDark),
          const SizedBox(height: 12),
          SettingsWidgets.buildMenuCard(
            context,
            icon: Icons.grid_on_outlined,
            title: 'Publicaciones',
            subtitle: 'Tus posts compartidos',
            isDark: isDark,
            onTap: () => context.push('/activity/posts'),
          ),
          const SizedBox(height: 8),
          SettingsWidgets.buildMenuCard(
            context,
            icon: Icons.auto_stories_outlined,
            title: 'Historias',
            subtitle: 'Tus historias recientes',
            isDark: isDark,
            onTap: () => context.push('/activity/stories'),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}
