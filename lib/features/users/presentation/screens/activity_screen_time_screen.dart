import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:biux/core/design_system/color_tokens.dart';
import 'package:biux/shared/services/screen_time_service.dart';

/// Pantalla de estadísticas de tiempo de uso, estilo Instagram.
/// Lee datos del servicio global ScreenTimeService.
class ActivityScreenTimeScreen extends StatefulWidget {
  const ActivityScreenTimeScreen({Key? key}) : super(key: key);

  @override
  State<ActivityScreenTimeScreen> createState() =>
      _ActivityScreenTimeScreenState();
}

class _ActivityScreenTimeScreenState extends State<ActivityScreenTimeScreen> {
  final _service = ScreenTimeService.instance;

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
    final last7 = _service.getLastDays(7);
    final avg7 = _service.averageDaily(7);
    final avg30 = _service.averageDaily(30);
    final today = _service.todayMinutes;
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
      body: SingleChildScrollView(
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
                                        : ColorTokens.secondary50.withValues(
                                            alpha: 0.4,
                                          ),
                                    borderRadius: BorderRadius.circular(4),
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
                      final dayNames = ['L', 'M', 'X', 'J', 'V', 'S', 'D'];
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
