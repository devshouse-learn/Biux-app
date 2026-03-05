import 'package:flutter/material.dart';
import 'package:biux/core/design_system/theme_notifier.dart';
import 'package:biux/core/design_system/locale_notifier.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/design_system/color_tokens.dart';
import '../widgets/settings_shared_widgets.dart';

class AppearanceScreenDetails extends StatefulWidget {
  const AppearanceScreenDetails({super.key});

  @override
  State<AppearanceScreenDetails> createState() =>
      _AppearanceScreenDetailsState();
}

class _AppearanceScreenDetailsState extends State<AppearanceScreenDetails> {
  String _textSizeKey = 'medium';

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _textSizeKey = prefs.getString('text_size_key') ?? 'medium';
    });
  }

  Future<void> _saveTextSize(String sizeKey) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('text_size_key', sizeKey);
    setState(() => _textSizeKey = sizeKey);
  }

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
          SettingsWidgets.buildSectionTitle(l.t('text'), isDark),
          const SizedBox(height: 12),
          SettingsWidgets.buildOptionCard(
            context: context,
            icon: Icons.text_fields,
            title: l.t('font_size'),
            subtitle: '${l.t('current')}: ${l.t(_textSizeKey)}',
            isDark: isDark,
            onTap: () => _showTextSizeDialog(context),
          ),
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

  Widget _buildThemeToggleCard(
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
      iconColor: isLightMode
          ? const Color(0xFFFF9800)
          : const Color(0xFF1A237E),
    );
  }

  void _showTextSizeDialog(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l = context.read<LocaleNotifier>();
    final sizeKeys = ['small', 'medium', 'large', 'very_large'];

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? ColorTokens.primary30 : Colors.white,
        title: Text(
          l.t('font_size'),
          style: TextStyle(color: isDark ? Colors.white : Colors.black87),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: sizeKeys.map((sizeKey) {
            final isSelected = _textSizeKey == sizeKey;
            return ListTile(
              title: Text(
                l.t(sizeKey),
                style: TextStyle(
                  color: isDark ? Colors.white : Colors.black87,
                  fontSize: _getFontSize(sizeKey),
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
                _saveTextSize(sizeKey);
                Navigator.pop(context);
              },
            );
          }).toList(),
        ),
      ),
    );
  }

  void _showLanguageDialog(BuildContext context) {
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

  double _getFontSize(String sizeKey) {
    switch (sizeKey) {
      case 'small':
        return 12;
      case 'medium':
        return 14;
      case 'large':
        return 16;
      case 'very_large':
        return 18;
      default:
        return 14;
    }
  }
}
