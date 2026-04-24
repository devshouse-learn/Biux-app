import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:biux/core/design_system/locale_notifier.dart';

class LanguageSelectionScreen {
  LanguageSelectionScreen._();

  static const Map<String, Map<String, String>> _languageInfo = {
    'Español': {'flag': '🇪🇸', 'native': 'Español'},
    'English': {'flag': '🇺🇸', 'native': 'English'},
    'Français': {'flag': '🇫🇷', 'native': 'Français'},
    'Italiano': {'flag': '🇮🇹', 'native': 'Italiano'},
    'Português': {'flag': '🇧🇷', 'native': 'Português'},
  };

  /// Muestra el selector de idioma como bottom sheet.
  /// Esto evita problemas de navegación cuando MaterialApp se reconstruye al cambiar locale.
  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) {
        return const _LanguageSheet();
      },
    );
  }
}

class _LanguageSheet extends StatelessWidget {
  const _LanguageSheet();

  @override
  Widget build(BuildContext context) {
    final l = Provider.of<LocaleNotifier>(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[400],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            SizedBox(height: 16),
            Text(
              l.t('select_language'),
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
            const SizedBox(height: 16),
            ...LanguageSelectionScreen._languageInfo.entries.map((entry) {
              final langName = entry.key;
              final info = entry.value;
              final isSelected = l.languageName == langName;

              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: () async {
                    final localeNotifier = Provider.of<LocaleNotifier>(
                      context,
                      listen: false,
                    );
                    Navigator.pop(context);
                    await localeNotifier.setLanguage(langName);
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? (isDark
                                ? const Color(0xFF16242D)
                                : const Color(
                                    0xFF16242D,
                                  ).withValues(alpha: 0.1))
                          : (isDark ? Colors.grey[900] : Colors.grey[100]),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected
                            ? const Color(0xFF16242D)
                            : Colors.transparent,
                        width: isSelected ? 2 : 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Text(
                          info['flag']!,
                          style: const TextStyle(fontSize: 28),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Text(
                            info['native']!,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: isSelected
                                  ? FontWeight.bold
                                  : FontWeight.w500,
                              color: isSelected
                                  ? (isDark
                                        ? Colors.white
                                        : const Color(0xFF16242D))
                                  : (isDark ? Colors.white70 : Colors.black87),
                            ),
                          ),
                        ),
                        if (isSelected)
                          const Icon(
                            Icons.check_circle,
                            color: Color(0xFF16242D),
                            size: 24,
                          ),
                      ],
                    ),
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}
