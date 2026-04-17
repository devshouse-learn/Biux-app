import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AccessibilityService extends ChangeNotifier {
  static const _fontSizeKey = 'font_scale';
  static const _highContrastKey = 'high_contrast';
  static const _reduceMotionKey = 'reduce_motion';
  static const _boldTextKey = 'bold_text';

  double _fontScale = 1.0;
  bool _highContrast = false;
  bool _reduceMotion = false;
  bool _boldText = false;

  double get fontScale => _fontScale;
  bool get highContrast => _highContrast;
  bool get reduceMotion => _reduceMotion;
  bool get boldText => _boldText;

  AccessibilityService() {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    _fontScale = prefs.getDouble(_fontSizeKey) ?? 1.0;
    _highContrast = prefs.getBool(_highContrastKey) ?? false;
    _reduceMotion = prefs.getBool(_reduceMotionKey) ?? false;
    _boldText = prefs.getBool(_boldTextKey) ?? false;
    notifyListeners();
  }

  Future<void> setFontScale(double scale) async {
    _fontScale = scale.clamp(0.8, 1.5);
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_fontSizeKey, _fontScale);
  }

  Future<void> setHighContrast(bool value) async {
    _highContrast = value;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_highContrastKey, value);
  }

  Future<void> setReduceMotion(bool value) async {
    _reduceMotion = value;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_reduceMotionKey, value);
  }

  Future<void> setBoldText(bool value) async {
    _boldText = value;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_boldTextKey, value);
  }
}
