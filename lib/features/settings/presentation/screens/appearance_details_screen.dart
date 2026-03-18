import 'package:flutter/material.dart';
import 'package:biux/core/design_system/theme_notifier.dart';
import 'package:biux/core/design_system/locale_notifier.dart';
import 'package:provider/provider.dart';
import '../../../../core/design_system/color_tokens.dart';
import '../widgets/settings_shared_widgets.dart';

class AppearanceScreenDetails extends StatelessWidget {
  const AppearanceScreenDetails({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l = Provider.of<LocaleNotifier>(context);

    return Scaffold(
      backgroundColor: SettingsWidgets.scaffoldBackground(isDark),
      appBar: SettingsWidgets.buildAppBar(context, l.t('appearance')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          SettingsWidgets.buildSectionTitle(l.t('theme'), isDark),
          const SizedBox(height: 12),
          _buildThemeToggleCard(context, isDark, l),
          const SizedBox(height: 24),
          SettingsWidgets.buildSectionTitle(l.t('language'), isDark),
          const SizedBox(height: 12),
          SettingsWidgets.buildOptionCard(
            context: context,
            icon: Icons.language,
            title: l.t('language'),
            subtitle: '${l.t('currently')}: ${l.languageName}',
            isDark: isDark,
            onTap: () => _showLanguageDialog(context),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  static Widget _buildThemeToggleCard(
    BuildContext context,
    bool isDark,
    LocaleNotifier l,
  ) {
    final themeNotifier = Provider.of<ThemeNotifier>(context);
    final isLightMode =
        themeNotifier.themeMode == ThemeMode.light ||
        (themeNotifier.themeMode == ThemeMode.system &&
            MediaQuery.of(context).platformBrightness == Brightness.light);

    return SettingsWidgets.buildToggleCard(
      context: context,
      icon: isLightMode ? Icons.wb_sunny_rounded : Icons.nightlight_round,
      title: l.t('app_theme'),
      subtitle: isLightMode ? l.t('light_mode') : l.t('dark_mode'),
      isDark: isDark,
      value: !isLightMode,
      onChanged: (_) => themeNotifier.toggleTheme(),
    );
  }

  static void _showLanguageDialog(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final localeNotifier = context.read<LocaleNotifier>();
    final languages = LocaleNotifier.supportedLanguages.keys.toList();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? ColorTokens.primary30 : Colors.white,
        title: Text(
          localeNotifier.t('select_language'),
          style: TextStyle(color: isDark ? Colors.white : Colors.black87),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: languages.map((lang) {
            final isSelected = localeNotifier.languageName == lang;
            return ListTile(
              title: Text(
                lang,
                style: TextStyle(
                  color: isDark ? Colors.white : Colors.black87,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
              leading: isSelected
                  ? const Icon(Icons.check_circle, color: ColorTokens.primary30)
                  : Icon(
                      Icons.circle_outlined,
                      color: isDark ? Colors.white30 : Colors.black26,
                    ),
              onTap: () {
                localeNotifier.setLanguage(lang);
                Navigator.pop(context);
              },
            );
          }).toList(),
        ),
      ),
    );
  }
}
