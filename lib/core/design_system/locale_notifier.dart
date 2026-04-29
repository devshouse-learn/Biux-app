import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:biux/core/config/app_translations.dart';

/// Notifier para cambiar el idioma de la app de forma reactiva.
/// Similar a ThemeNotifier pero para Locale.
class LocaleNotifier extends ChangeNotifier {
  static const String _key = 'language';

  Locale _locale = const Locale('es', 'CO');

  Locale get locale => _locale;

  /// Código de idioma actual (es, en, pt, fr).
  String get langCode => _locale.languageCode;

  /// Nombre legible del idioma actual.
  String get languageName => _localeToName(_locale);

  /// Traduce una clave al idioma actual.
  String t(String key) => AppTranslations.translate(key, langCode);

  /// Helper estático para traducir desde cualquier widget con context.
  static String tr(BuildContext context, String key) {
    return context.read<LocaleNotifier>().t(key);
  }

  LocaleNotifier() {
    _loadFromPrefs();
  }

  /// Mapa de idiomas disponibles.
  static const Map<String, Locale> supportedLanguages = {
    'Español': Locale('es', 'CO'),
    'English': Locale('en', 'US'),
    'Français': Locale('fr', 'FR'),
    'Italiano': Locale('it', 'IT'),
    'Português': Locale('pt', 'BR'),
  };

  /// Lista de Locale soportados (para MaterialApp.supportedLocales).
  static List<Locale> get supportedLocales =>
      supportedLanguages.values.toList();

  /// Cambia el idioma y persiste la preferencia.
  Future<void> setLanguage(String languageName) async {
    final newLocale = supportedLanguages[languageName];
    if (newLocale == null) return;

    _locale = newLocale;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, languageName);
  }

  Future<void> _loadFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString(_key);
    if (saved != null && supportedLanguages.containsKey(saved)) {
      _locale = supportedLanguages[saved]!;
      notifyListeners();
    }
  }

  String _localeToName(Locale locale) {
    for (final entry in supportedLanguages.entries) {
      if (entry.value.languageCode == locale.languageCode) {
        return entry.key;
      }
    }
    return 'Español';
  }
}
