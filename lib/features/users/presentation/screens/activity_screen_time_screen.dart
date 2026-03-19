import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:biux/core/design_system/color_tokens.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

/// Pantalla de estadísticas de tiempo de uso, estilo Instagram.
/// Registra el tiempo de sesión y calcula promedios diarios.
class ActivityScreenTimeScreen extends StatefulWidget {
  const ActivityScreenTimeScreen({Key? key}) : super(key: key);

  @override
  State<ActivityScreenTimeScreen> createState() =>
      _ActivityScreenTimeScreenState();
}

class _ActivityScreenTimeScreenState extends State<ActivityScreenTimeScreen>
    with WidgetsBindingObserver {
  static const _storageKey = 'biux_screen_time';
  Map<String, int> _dailyMinutes = {}; // 'yyyy-MM-dd' -> minutes
  DateTime? _sessionStart;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _sessionStart = DateTime.now();
    _loadData();
  }

  @override
  void dispose() {
    _saveCurrentSession();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive) {
      _saveCurrentSession();
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
    if (mounted) setState(() => _isLoading = false);
  }

  Future<void> _saveCurrentSession() async {
    if (_sessionStart == null) return;
    final minutes = DateTime.now().difference(_sessionStart!).inMinutes;
    if (minutes < 1) return;

    final key = _todayKey();
    _dailyMinutes[key] = (_dailyMinutes[key] ?? 0) + minutes;
    _sessionStart = DateTime.now(); // Reset session

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_storageKey, json.encode(_dailyMinutes));
    } catch (_) {}
  }

  // Obtener datos de los últimos N días
  List<_DayData> _getLastDays(int count) {
    final now = DateTime.now();
    final days = <_DayData>[];
    for (int i = count - 1; i >= 0; i--) {
      final date = now.subtract(Duration(days: i));
      final key =
          '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
      int mins = _dailyMinutes[key] ?? 0;
      // Si es hoy, sumar sesión actual
      if (i == 0 && _sessionStart != null) {
        mins += DateTime.now().difference(_sessionStart!).inMinutes;
      }
      days.add(_DayData(date: date, minutes: mins));
    }
    return days;
  }

  double _averageDaily(int days) {
    final data = _getLastDays(days);
    final total = data.fold<int>(0, (sum, d) => sum + d.minutes);
    return total / days;
  }

  String _formatMinutes(int minutes) {
    if (minutes < 60) return '${minutes}m';
    final h = minutes ~/ 60;
    final m = minutes % 60;
    return m > 0 ? '${h}h ${m}m' : '${h}h';
  }

  String _formatMinutesDouble(double minutes) {
    return _formatMinutes(minutes.round());
  }

  @override
  Widget build(BuildContext context) {
    final last7 = _getLastDays(7);
    final avg7 = _averageDaily(7);
    final avg30 = _averageDaily(30);
    final today = last7.isNotEmpty ? last7.last.minutes : 0;
    final maxMinutes = last7.fold<int>(
      1,
      (max, d) => d.minutes > max ? d.minutes : max,
    );

    return Scaffold(
      backgroundColor: ColorTokens.primary30,
      appBar: AppBar(
        backgroundColor: ColorTokens.primary30,
        foregroundColor: ColorTokens.neutral100,
        title: Text(
          'Tiempo en la App',
          style: TextStyle(
            color: ColorTokens.neutral100,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: ColorTokens.neutral100),
          onPressed: () => context.pop(),
        ),
        elevation: 0,
      ),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(
                  ColorTokens.secondary50,
                ),
              ),
            )
          : SingleChildScrollView(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Resumen principal
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: ColorTokens.primary40,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: ColorTokens.secondary50.withValues(alpha: 0.3),
                        width: 1,
                      ),
                    ),
                    child: Column(
                      children: [
                        Text(
                          'Promedio Diario',
                          style: TextStyle(
                            color: ColorTokens.neutral80,
                            fontSize: 14,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          _formatMinutesDouble(avg7),
                          style: TextStyle(
                            color: ColorTokens.neutral100,
                            fontSize: 42,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Últimos 7 días',
                          style: TextStyle(
                            color: ColorTokens.secondary50,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 24),

                  // Gráfico de barras - últimos 7 días
                  Text(
                    'Últimos 7 días',
                    style: TextStyle(
                      color: ColorTokens.neutral100,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 16),

                  Container(
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: ColorTokens.primary40,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        SizedBox(
                          height: 160,
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: last7.map((day) {
                              final ratio = maxMinutes > 0
                                  ? day.minutes / maxMinutes
                                  : 0.0;
                              final isToday =
                                  day.date.day == DateTime.now().day &&
                                  day.date.month == DateTime.now().month;
                              return Expanded(
                                child: Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 4),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      Text(
                                        day.minutes > 0
                                            ? _formatMinutes(day.minutes)
                                            : '-',
                                        style: TextStyle(
                                          color: ColorTokens.neutral80,
                                          fontSize: 10,
                                        ),
                                      ),
                                      SizedBox(height: 4),
                                      Container(
                                        height: (130 * ratio).clamp(4.0, 130.0),
                                        decoration: BoxDecoration(
                                          color: isToday
                                              ? ColorTokens.secondary50
                                              : ColorTokens.secondary50
                                                    .withValues(alpha: 0.4),
                                          borderRadius: BorderRadius.circular(
                                            4,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                        SizedBox(height: 8),
                        Row(
                          children: last7.map((day) {
                            final dayNames = [
                              'L',
                              'M',
                              'X',
                              'J',
                              'V',
                              'S',
                              'D',
                            ];
                            return Expanded(
                              child: Text(
                                dayNames[day.date.weekday - 1],
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: ColorTokens.neutral60,
                                  fontSize: 12,
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 24),

                  // Stats cards
                  Text(
                    'Estadísticas',
                    style: TextStyle(
                      color: ColorTokens.neutral100,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 16),

                  Row(
                    children: [
                      Expanded(
                        child: _buildStatCard(
                          icon: Icons.today,
                          label: 'Hoy',
                          value: _formatMinutes(today),
                        ),
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: _buildStatCard(
                          icon: Icons.calendar_view_week,
                          label: 'Prom. 7 días',
                          value: _formatMinutesDouble(avg7),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _buildStatCard(
                          icon: Icons.calendar_month,
                          label: 'Prom. 30 días',
                          value: _formatMinutesDouble(avg30),
                        ),
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: _buildStatCard(
                          icon: Icons.access_time,
                          label: 'Total semana',
                          value: _formatMinutes(
                            last7.fold<int>(0, (sum, d) => sum + d.minutes),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 32),
                ],
              ),
            ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: ColorTokens.primary40,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: ColorTokens.neutral60.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Icon(icon, color: ColorTokens.secondary50, size: 28),
          SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              color: ColorTokens.neutral100,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(color: ColorTokens.neutral80, fontSize: 12),
          ),
        ],
      ),
    );
  }
}

class _DayData {
  final DateTime date;
  final int minutes;

  _DayData({required this.date, required this.minutes});
}
