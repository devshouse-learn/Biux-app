// ignore_for_file: deprecated_member_use
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:biux/core/design_system/theme_notifier.dart';
import 'package:biux/core/design_system/color_tokens.dart';

class AppearanceDetailsScreen extends StatelessWidget {
  const AppearanceDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Apariencia'),
        backgroundColor: const Color(0xFF16242D),
        foregroundColor: Colors.white,
      ),
      body: Consumer<ThemeNotifier>(
        builder: (context, theme, _) {
          final isDark = theme.isDark;
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _SectionTitle(title: 'Tema de la aplicación'),
              const SizedBox(height: 12),
              _ThemeOptionTile(
                icon: Icons.light_mode_rounded,
                title: 'Modo claro',
                subtitle: 'Fondo blanco, colores brillantes',
                selected: theme.mode == ThemeMode.light,
                onTap: () => theme.setMode(ThemeMode.light),
                isDark: isDark,
              ),
              const SizedBox(height: 8),
              _ThemeOptionTile(
                icon: Icons.dark_mode_rounded,
                title: 'Modo oscuro',
                subtitle: 'Fondo oscuro, menor fatiga visual',
                selected: theme.mode == ThemeMode.dark,
                onTap: () => theme.setMode(ThemeMode.dark),
                isDark: isDark,
              ),
              const SizedBox(height: 8),
              _ThemeOptionTile(
                icon: Icons.phone_android_rounded,
                title: 'Seguir al sistema',
                subtitle: 'Usa la preferencia del dispositivo',
                selected: theme.mode == ThemeMode.system,
                onTap: () => theme.setMode(ThemeMode.system),
                isDark: isDark,
              ),
              const SizedBox(height: 24),
              _SectionTitle(title: 'Cambio rápido'),
              const SizedBox(height: 12),
              _QuickToggleCard(theme: theme, isDark: isDark),
            ],
          );
        },
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(
          fontWeight: FontWeight.w700,
          fontSize: 14,
          color: Colors.grey),
    );
  }
}

class _ThemeOptionTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool selected;
  final VoidCallback onTap;
  final bool isDark;

  const _ThemeOptionTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.selected,
    required this.onTap,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: selected
              ? ColorTokens.primary30.withValues(alpha: 0.08)
              : (isDark ? const Color(0xFF1A2B3C) : Colors.white),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
              color: selected
                  ? ColorTokens.primary30
                  : Colors.grey.shade300,
              width: selected ? 2 : 1),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: selected
                    ? ColorTokens.primary30.withValues(alpha: 0.15)
                    : Colors.grey.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon,
                  color: selected ? ColorTokens.primary30 : Colors.grey,
                  size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                          color: selected
                              ? ColorTokens.primary30
                              : (isDark ? Colors.white : Colors.black87))),
                  const SizedBox(height: 2),
                  Text(subtitle,
                      style: const TextStyle(
                          fontSize: 12, color: Colors.grey)),
                ],
              ),
            ),
            if (selected)
              Icon(Icons.check_circle_rounded,
                  color: ColorTokens.primary30, size: 22),
          ],
        ),
      ),
    );
  }
}

class _QuickToggleCard extends StatelessWidget {
  final ThemeNotifier theme;
  final bool isDark;

  const _QuickToggleCard({required this.theme, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A2B3C) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        children: [
          Icon(
            isDark ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
            color: ColorTokens.primary30,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              isDark ? 'Modo oscuro activo' : 'Modo claro activo',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          Switch(
            value: isDark,
            activeColor: ColorTokens.primary30,
            onChanged: (_) => theme.toggle(),
          ),
        ],
      ),
    );
  }
}
