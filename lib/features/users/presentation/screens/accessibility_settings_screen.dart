
// ignore_for_file: deprecated_member_use
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:biux/core/services/accessibility_service.dart';
import 'package:biux/core/design_system/theme_notifier.dart';
import 'package:biux/core/design_system/color_tokens.dart';

class AccessibilitySettingsScreen extends StatelessWidget {
  const AccessibilitySettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Accesibilidad y apariencia'),
        backgroundColor: const Color(0xFF16242D),
        foregroundColor: Colors.white,
      ),
      body: Consumer2<AccessibilityService, ThemeNotifier>(
        builder: (context, acc, theme, _) {
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _SectionHeader(title: 'Apariencia'),
              _SettingCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Tema',
                        style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: _ThemeOption(
                            icon: Icons.light_mode_rounded,
                            label: 'Claro',
                            selected: theme.mode == ThemeMode.light,
                            onTap: () => theme.setMode(ThemeMode.light),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _ThemeOption(
                            icon: Icons.dark_mode_rounded,
                            label: 'Oscuro',
                            selected: theme.mode == ThemeMode.dark,
                            onTap: () => theme.setMode(ThemeMode.dark),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _ThemeOption(
                            icon: Icons.phone_android_rounded,
                            label: 'Sistema',
                            selected: theme.mode == ThemeMode.system,
                            onTap: () => theme.setMode(ThemeMode.system),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              _SectionHeader(title: 'Tamano de texto'),
              _SettingCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('A', style: TextStyle(fontSize: 12)),
                        Expanded(
                          child: Slider(
                            value: acc.fontScale,
                            min: 0.8,
                            max: 1.5,
                            divisions: 7,
                            activeColor: ColorTokens.primary30,
                            onChanged: acc.setFontScale,
                          ),
                        ),
                        const Text('A',
                            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
                      ],
                    ),
                    Center(
                      child: Text(
                        'Texto de ejemplo',
                        style: TextStyle(fontSize: 14 * acc.fontScale),
                      ),
                    ),
                    const SizedBox(height: 8),
                    SwitchListTile(
                      title: const Text('Texto en negrita'),
                      value: acc.boldText,
                      activeColor: ColorTokens.primary30,
                      onChanged: acc.setBoldText,
                      contentPadding: EdgeInsets.zero,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              _SectionHeader(title: 'Accesibilidad'),
              _SettingCard(
                child: Column(
                  children: [
                    SwitchListTile(
                      title: const Text('Alto contraste'),
                      subtitle: const Text('Aumenta el contraste de colores',
                          style: TextStyle(fontSize: 12)),
                      value: acc.highContrast,
                      activeColor: ColorTokens.primary30,
                      onChanged: acc.setHighContrast,
                      contentPadding: EdgeInsets.zero,
                    ),
                    const Divider(height: 1),
                    SwitchListTile(
                      title: const Text('Reducir animaciones'),
                      subtitle: const Text('Minimiza efectos de movimiento',
                          style: TextStyle(fontSize: 12)),
                      value: acc.reduceMotion,
                      activeColor: ColorTokens.primary30,
                      onChanged: acc.setReduceMotion,
                      contentPadding: EdgeInsets.zero,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
            ],
          );
        },
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(title,
          style: const TextStyle(
              fontWeight: FontWeight.w700, fontSize: 14, color: Colors.grey)),
    );
  }
}

class _SettingCard extends StatelessWidget {
  final Widget child;
  const _SettingCard({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.05), blurRadius: 8)
        ],
      ),
      child: child,
    );
  }
}

class _ThemeOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _ThemeOption(
      {required this.icon,
      required this.label,
      required this.selected,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          border: Border.all(
              color: selected ? ColorTokens.primary30 : Colors.grey.shade300,
              width: selected ? 2 : 1),
          borderRadius: BorderRadius.circular(10),
          color: selected
              ? ColorTokens.primary30.withValues(alpha: 0.08)
              : Colors.transparent,
        ),
        child: Column(
          children: [
            Icon(icon,
                color: selected ? ColorTokens.primary30 : Colors.grey,
                size: 20),
            const SizedBox(height: 4),
            Text(label,
                style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: selected ? ColorTokens.primary30 : Colors.grey)),
          ],
        ),
      ),
    );
  }
}
