import 'dart:convert';
import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Servicio global singleton que rastrea el tiempo de uso de la app.
/// Debe inicializarse en main.dart antes de runApp().
class ScreenTimeService with WidgetsBindingObserver {
  ScreenTimeService._();
  static final ScreenTimeService _instance = ScreenTimeService._();
  static ScreenTimeService get instance => _instance;

  static const _storageKey = 'biux_screen_time';

  Map<String, int> _dailyMinutes = {};
  DateTime? _sessionStart;
  bool _initialized = false;

  /// Inicializa el servicio y comienza a rastrear.
  Future<void> initialize() async {
    if (_initialized) return;
    _initialized = true;

    await _loadData();
    _sessionStart = DateTime.now();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive) {
      saveCurrentSession();
    } else if (state == AppLifecycleState.resumed) {
      _sessionStart = DateTime.now();
    }
  }

  String _todayKey() {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  }

  Future<void> _loadData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_storageKey);
      if (raw != null) {
        final decoded = json.decode(raw) as Map<String, dynamic>;
        _dailyMinutes = decoded.map((k, v) => MapEntry(k, (v as num).toInt()));
      }
    } catch (_) {}
  }

  /// Guarda la sesión actual y resetea el contador.
  Future<void> saveCurrentSession() async {
    if (_sessionStart == null) return;
    final minutes = DateTime.now().difference(_sessionStart!).inMinutes;
    if (minutes < 1) return;

    final key = _todayKey();
    _dailyMinutes[key] = (_dailyMinutes[key] ?? 0) + minutes;
    _sessionStart = DateTime.now();

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_storageKey, json.encode(_dailyMinutes));
    } catch (_) {}
  }

  /// Minutos del día actual incluyendo la sesión en curso.
  int get todayMinutes {
    final key = _todayKey();
    int mins = _dailyMinutes[key] ?? 0;
    if (_sessionStart != null) {
      mins += DateTime.now().difference(_sessionStart!).inMinutes;
    }
    return mins;
  }

  /// Datos de los últimos [count] días.
  List<DayData> getLastDays(int count) {
    final now = DateTime.now();
    final days = <DayData>[];
    for (int i = count - 1; i >= 0; i--) {
      final date = now.subtract(Duration(days: i));
      final key =
          '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
      int mins = _dailyMinutes[key] ?? 0;
      if (i == 0 && _sessionStart != null) {
        mins += DateTime.now().difference(_sessionStart!).inMinutes;
      }
      days.add(DayData(date: date, minutes: mins));
    }
    return days;
  }

  /// Promedio diario de los últimos [days] días.
  double averageDaily(int days) {
    final data = getLastDays(days);
    final total = data.fold<int>(0, (sum, d) => sum + d.minutes);
    return total / days;
  }
}

class DayData {
  final DateTime date;
  final int minutes;

  DayData({required this.date, required this.minutes});
}
