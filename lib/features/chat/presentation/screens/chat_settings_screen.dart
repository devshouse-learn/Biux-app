import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:biux/core/config/router/app_routes.dart';
import 'package:biux/core/design_system/color_tokens.dart';
import 'package:biux/features/settings/presentation/widgets/settings_shared_widgets.dart';
import 'package:biux/core/design_system/locale_notifier.dart';
import 'package:provider/provider.dart';
import 'package:biux/core/design_system/locale_notifier.dart';

class ChatSettingsScreen extends StatefulWidget {
  const ChatSettingsScreen({super.key});

  @override
  State<ChatSettingsScreen> createState() => _ChatSettingsScreenState();
}

class _ChatSettingsScreenState extends State<ChatSettingsScreen> {
  LocaleNotifier get l => Provider.of<LocaleNotifier>(context);

  double _fontSize = 14.0;

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    final stored = prefs.getDouble('chat_font_size');
    if (stored != null && mounted) {
      setState(() => _fontSize = stored);
    }
  }

  Future<void> _saveFontSize(double size) async {
    setState(() => _fontSize = size);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('chat_font_size', size);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: SettingsWidgets.scaffoldBackground(isDark),
      appBar: AppBar(
        title: Text('Ajustes de chats'),
        backgroundColor: ColorTokens.primary30,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // --- Tamaño de fuente ---
          SettingsWidgets.buildSectionTitle(l.t('customization'), isDark),
          SizedBox(height: 12),
          _buildFontSizeCard(isDark),

          SizedBox(height: 24),

          // --- Copia de seguridad ---
          SettingsWidgets.buildSectionTitle(l.t('backup'), isDark),
          SizedBox(height: 12),
          SettingsWidgets.buildOptionCard(
            context: context,
            icon: Icons.cloud_upload_outlined,
            title: l.t('backup'),
            subtitle: 'Respalda tus chats en la nube',
            isDark: isDark,
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(l.t('feature_in_development')),
                  backgroundColor: Colors.orange.shade600,
                ),
              );
            },
          ),

          SizedBox(height: 24),

          // --- Usuarios bloqueados ---
          SettingsWidgets.buildSectionTitle(l.t('privacy'), isDark),
          SizedBox(height: 12),
          SettingsWidgets.buildOptionCard(
            context: context,
            icon: Icons.block,
            title: l.t('blocked_users'),
            subtitle: 'Administra tu lista de usuarios bloqueados',
            isDark: isDark,
            onTap: () => context.push(AppRoutes.blockedUsers),
          ),

          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildFontSizeCard(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A2B3C) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          if (!isDark)
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.text_fields,
                color: isDark ? Colors.white70 : ColorTokens.primary30,
              ),
              const SizedBox(width: 12),
              Text(
                'Tamaño de fuente',
                style: TextStyle(
                  color: isDark ? Colors.white : Colors.black87,
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              const Text('A', style: TextStyle(fontSize: 12)),
              Expanded(
                child: Slider(
                  value: _fontSize,
                  min: 12,
                  max: 22,
                  divisions: 5,
                  activeColor: ColorTokens.primary30,
                  label: '${_fontSize.toInt()}',
                  onChanged: _saveFontSize,
                ),
              ),
              Text('A', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            ],
          ),
          Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF243B53) : Colors.grey.shade100,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                l.t('text_preview'),
                style: TextStyle(
                  fontSize: _fontSize,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
