import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:share_plus/share_plus.dart';
import 'package:biux/core/design_system/color_tokens.dart';
import 'package:biux/features/cycling_stats/presentation/providers/cycling_stats_provider.dart';
import 'package:biux/features/cycling_stats/domain/entities/cycling_stats_entity.dart';
import 'package:biux/features/ride_tracker/presentation/providers/ride_tracker_provider.dart';
import 'package:biux/features/ride_tracker/domain/entities/ride_track_entity.dart';
import 'package:biux/features/users/presentation/providers/user_provider.dart';
import 'package:biux/features/weather/presentation/providers/weather_provider.dart';
import 'package:biux/core/design_system/locale_notifier.dart';

class CyclingStatsScreen extends StatefulWidget {
  const CyclingStatsScreen({Key? key}) : super(key: key);

  @override
  State<CyclingStatsScreen> createState() => _CyclingStatsScreenState();
}

class _CyclingStatsScreenState extends State<CyclingStatsScreen>
    with SingleTickerProviderStateMixin {
  LocaleNotifier get l => Provider.of<LocaleNotifier>(context);

  late TabController _tabController;
  String _selectedPeriod = 'total';
  String _rankingMode = 'amigos'; // 'amigos' | 'regional'

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  void _loadData() {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid != null) {
      context.read<CyclingStatsProvider>().refreshAll(uid);
      context.read<RideTrackerProvider>().loadHistory(uid);
    }
    final wp = context.read<WeatherProvider>();
    if (wp.weatherData == null && !wp.loading) {
      wp.loadWeather();
    }
  }

  void _syncAndNotify() {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;
    final provider = context.read<CyclingStatsProvider>();
    if (provider.isSyncing) return;

    provider.refreshAll(uid).then((_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white, size: 18),
                SizedBox(width: 10),
                Text(l.t('stats_updated')),
              ],
            ),
            backgroundColor: ColorTokens.primary30,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Consumer<CyclingStatsProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircularProgressIndicator(),
                  const SizedBox(height: 16),
                  Text(
                    'Cargando estadísticas...',
                    style: TextStyle(
                      color: Theme.of(context).brightness == Brightness.dark
                          ? Colors.white70
                          : Colors.grey,
                    ),
                  ),
                ],
              ),
            );
          }

          if (provider.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 48, color: Colors.red),
                  const SizedBox(height: 12),
                  Text(
                    provider.error!,
                    style: const TextStyle(color: Colors.red),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: _loadData,
                    icon: Icon(Icons.refresh),
                    label: Text(l.t('retry')),
                  ),
                ],
              ),
            );
          }

          return NestedScrollView(
            headerSliverBuilder: (context, innerBoxIsScrolled) => [
              _buildSliverAppBar(provider),
            ],
            body: TabBarView(
              controller: _tabController,
              children: [
                _buildStatsTab(provider),
                _buildLeaderboardTab(provider),
              ],
            ),
          );
        },
      ),
    );
  }

  // ─── APPBAR ──────────────────────────────────────────────
  SliverAppBar _buildSliverAppBar(CyclingStatsProvider provider) {
    final stats = provider.stats;
    return SliverAppBar(
      expandedHeight: 200,
      pinned: true,
      backgroundColor: ColorTokens.primary30,
      foregroundColor: Colors.white,
      title: Text(
        l.t('my_stats'),
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      actions: [
        IconButton(
          icon: provider.isSyncing
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              : const Icon(Icons.sync),
          tooltip: 'Actualizar estadísticas',
          onPressed: provider.isSyncing ? null : _syncAndNotify,
        ),
        IconButton(
          icon: Icon(Icons.share),
          tooltip: l.t('share'),
          onPressed: () => _shareStats(stats),
        ),
      ],
      bottom: TabBar(
        controller: _tabController,
        indicatorColor: Colors.white,
        indicatorWeight: 3,
        labelColor: Colors.white,
        unselectedLabelColor: Colors.white60,
        labelStyle: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
        tabs: [
          Tab(
            icon: Icon(Icons.bar_chart_rounded, size: 22),
            text: l.t('statistics'),
          ),
          Tab(
            icon: Icon(Icons.emoji_events_rounded, size: 22),
            text: 'Ranking',
          ),
        ],
      ),
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                ColorTokens.primary30,
                ColorTokens.primary30.withValues(alpha: 0.85),
                const Color(0xFF1A3A4A),
              ],
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.only(
                top: 44,
                left: 20,
                right: 20,
                bottom: 60,
              ),
              child: stats != null
                  ? Row(
                      children: [
                        // Nivel emoji
                        Container(
                          width: 64,
                          height: 64,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Center(
                            child: Text(
                              stats.levelEmoji,
                              style: const TextStyle(fontSize: 36),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                stats.level.toUpperCase(),
                                style: const TextStyle(
                                  color: Colors.amber,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 1.5,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${stats.totalKm.toStringAsFixed(1)} km totales',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              // Barra de progreso
                              ClipRRect(
                                borderRadius: BorderRadius.circular(6),
                                child: LinearProgressIndicator(
                                  value: stats.progressToNextLevel,
                                  minHeight: 6,
                                  backgroundColor: Colors.white.withValues(
                                    alpha: 0.15,
                                  ),
                                  valueColor:
                                      const AlwaysStoppedAnimation<Color>(
                                        Colors.amber,
                                      ),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                stats.level == 'leyenda'
                                    ? '¡Nivel máximo alcanzado!'
                                    : '${stats.kmToNextLevel.toStringAsFixed(0)} km para ${stats.nextLevelName}',
                                style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.6),
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    )
                  : Center(
                      child: Text(
                        l.t('complete_first_ride'),
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 16,
                        ),
                      ),
                    ),
            ),
          ),
        ),
      ),
    );
  }

  // ─── TAB ESTADÍSTICAS ────────────────────────────────────
  Widget _buildStatsTab(CyclingStatsProvider provider) {
    final stats = provider.stats;
    if (stats == null) {
      return _buildEmptyState(
        icon: Icons.pedal_bike,
        title: l.t('no_stats_yet'),
        subtitle: l.t('complete_first_ride_stats'),
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        final uid = FirebaseAuth.instance.currentUser?.uid;
        if (uid != null) {
          await context.read<CyclingStatsProvider>().refreshAll(uid);
        }
      },
      color: ColorTokens.primary30,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Última actualización + Filtro
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Align(
              alignment: Alignment.centerRight,
              child: GestureDetector(
                onTap: provider.isSyncing ? null : _syncAndNotify,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: ColorTokens.primary30.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      provider.isSyncing
                          ? const SizedBox(
                              width: 12,
                              height: 12,
                              child: CircularProgressIndicator(
                                strokeWidth: 1.5,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  ColorTokens.primary30,
                                ),
                              ),
                            )
                          : Icon(
                              Icons.refresh,
                              size: 14,
                              color: ColorTokens.primary30,
                            ),
                      SizedBox(width: 4),
                      Text(
                        provider.isSyncing ? 'Actualizando...' : l.t('update'),
                        style: const TextStyle(
                          fontSize: 11,
                          color: ColorTokens.primary30,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          _buildPeriodFilter(),
          const SizedBox(height: 16),

          // Clima actual para ciclismo
          _buildWeatherCard(),
          const SizedBox(height: 16),

          // Stats principales en grid
          _buildMainStatsGrid(stats),
          const SizedBox(height: 16),

          // Récords personales
          _buildRecordsSection(stats),
          const SizedBox(height: 16),

          // Gráfico mensual
          _buildMonthlyChart(stats),
          const SizedBox(height: 16),

          // Resumen rápido
          _buildQuickSummary(stats),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  // ─── RACHA CALCULADA DESDE HISTORIAL REAL ──────────────
  /// Días consecutivos (hasta hoy) con al menos una rodada.
  int _computeStreak(List<RideTrackEntity> rides) {
    if (rides.isEmpty) return 0;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final rideDays =
        rides
            .map((r) {
              final d = r.startTime;
              return DateTime(d.year, d.month, d.day);
            })
            .toSet()
            .toList()
          ..sort((a, b) => b.compareTo(a)); // más reciente primero
    int streak = 0;
    DateTime checkDay = today;
    for (final day in rideDays) {
      if (day == checkDay) {
        streak++;
        checkDay = checkDay.subtract(const Duration(days: 1));
      } else if (day.isBefore(checkDay)) {
        break;
      }
    }
    return streak;
  }

  // ─── FILTRO DE RIDES POR PERÍODO ─────────────────────────
  List<RideTrackEntity> _filteredRides() {
    final rides = context.read<RideTrackerProvider>().history;
    final now = DateTime.now();
    switch (_selectedPeriod) {
      case 'week':
        // Lunes de la semana actual
        final weekStart = now.subtract(Duration(days: now.weekday - 1));
        final weekStartDay = DateTime(
          weekStart.year,
          weekStart.month,
          weekStart.day,
        );
        return rides.where((r) => !r.startTime.isBefore(weekStartDay)).toList();
      case 'month':
        return rides
            .where(
              (r) =>
                  r.startTime.year == now.year &&
                  r.startTime.month == now.month,
            )
            .toList();
      default: // total
        return rides;
    }
  }

  // ─── TARJETA DE CLIMA ────────────────────────────────────
  Widget _buildWeatherCard() {
    return Consumer<WeatherProvider>(
      builder: (context, wp, _) {
        if (wp.loading) {
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.blue.withValues(alpha: 0.06),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.blue.withValues(alpha: 0.15)),
            ),
            child: Row(
              children: [
                SizedBox(
                  width: 14,
                  height: 14,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.blue,
                  ),
                ),
                SizedBox(width: 10),
                Text(
                  l.t('loading_weather'),
                  style: TextStyle(fontSize: 12, color: Colors.blue),
                ),
              ],
            ),
          );
        }
        if (wp.weatherData == null) return const SizedBox.shrink();

        final safe = wp.isSafeToRide;
        final safeColor = safe ? Colors.green : Colors.orange;
        final isDark = Theme.of(context).brightness == Brightness.dark;

        return Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: isDark
                ? safeColor.withValues(alpha: 0.08)
                : safeColor.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: safeColor.withValues(alpha: 0.25)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Título de sección
              Row(
                children: [
                  Icon(Icons.wb_sunny_outlined, size: 14, color: Colors.amber),
                  SizedBox(width: 6),
                  Text(
                    l.t('current_weather_cycling'),
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: isDark ? Colors.white54 : Colors.grey[600],
                      letterSpacing: 0.5,
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: safeColor.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      safe ? '✅ Apto para rodar' : '⚠️ Precaución',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: safeColor,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              // Fila principal: emoji + temp + datos
              Row(
                children: [
                  Text(wp.weatherEmoji, style: const TextStyle(fontSize: 32)),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        wp.temperature,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        wp.description,
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark ? Colors.white54 : Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  // Grid de datos
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      _statsWeatherRow(
                        '💨',
                        '${wp.windSpeed.round()} km/h ${wp.windDirectionLabel}',
                      ),
                      const SizedBox(height: 4),
                      _statsWeatherRow('💧', 'Humedad ${wp.humidity}%'),
                      const SizedBox(height: 4),
                      _statsWeatherRow('🌡️', 'ST ${wp.feelsLike.round()}°C'),
                    ],
                  ),
                ],
              ),
              if (wp.uvIndex > 0 || wp.precipitationProbability > 0) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    if (wp.uvIndex > 0)
                      _statsWeatherChip(
                        '☀️ UV ${wp.uvIndex.toStringAsFixed(1)} · ${wp.uvAdvice}',
                      ),
                    if (wp.uvIndex > 0 && wp.precipitationProbability > 0)
                      const SizedBox(width: 8),
                    if (wp.precipitationProbability > 0)
                      _statsWeatherChip(
                        '🌧️ Prec. ${wp.precipitationProbability}%',
                      ),
                  ],
                ),
              ],
              if (wp.rideAdvice.isNotEmpty) ...[
                const SizedBox(height: 8),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: safeColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    wp.rideAdvice,
                    style: TextStyle(
                      fontSize: 12,
                      color: safeColor.withValues(alpha: 0.9),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _statsWeatherRow(String emoji, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(emoji, style: const TextStyle(fontSize: 12)),
        const SizedBox(width: 4),
        Text(
          label,
          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500),
        ),
      ],
    );
  }

  Widget _statsWeatherChip(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.grey.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500),
      ),
    );
  }

  // ─── FILTRO DE PERÍODO ───────────────────────────────────
  Widget _buildPeriodFilter() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final periods = [
      {'id': 'total', 'label': 'Total'},
      {'id': 'week', 'label': 'Semana'},
      {'id': 'month', 'label': 'Mes'},
    ];

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: isDark ? ColorTokens.primary20 : Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.15 : 0.04),
            blurRadius: 8,
          ),
        ],
      ),
      child: Row(
        children: periods.map((p) {
          final isSelected = _selectedPeriod == p['id'];
          return Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _selectedPeriod = p['id']!),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: isSelected
                      ? ColorTokens.primary30
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  p['label']!,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: isSelected
                        ? Colors.white
                        : (isDark ? Colors.white70 : Colors.grey[600]),
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  // ─── GRID DE STATS PRINCIPALES ───────────────────────────
  Widget _buildMainStatsGrid(CyclingStatsEntity stats) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final filtered = _filteredRides();
    final hasRides = filtered.isNotEmpty;

    // Calcular valores del período seleccionado
    final km = hasRides ? filtered.fold(0.0, (s, r) => s + r.totalKm) : 0.0;
    final rideCount = filtered.length;
    final avgSpd = hasRides
        ? filtered.fold(0.0, (s, r) => s + r.avgSpeed) / filtered.length
        : 0.0;
    final maxSpd = hasRides
        ? filtered.map((r) => r.maxSpeed).reduce((a, b) => a > b ? a : b)
        : 0.0;
    final elev = hasRides ? filtered.fold(0, (s, r) => s + r.elevationGain) : 0;
    final cal = hasRides ? filtered.fold(0, (s, r) => s + r.calories) : 0;
    final totalMin = hasRides
        ? filtered.fold(0, (s, r) => s + r.durationMinutes)
        : 0;
    final h = totalMin ~/ 60;
    final m = totalMin % 60;
    final timeStr = hasRides ? (h > 0 ? '${h}h ${m}m' : '${m}m') : '0m';
    // Racha calculada desde historial completo (no filtrado por período)
    final allHistory = context.read<RideTrackerProvider>().history;
    final currentStreak = _computeStreak(allHistory);

    final items = [
      _StatItem(
        icon: Icons.straighten_rounded,
        label: l.t('distance'),
        value: km.toStringAsFixed(1),
        unit: 'km',
        color: isDark ? Colors.white : ColorTokens.primary30,
        statKey: 'km',
      ),
      _StatItem(
        icon: Icons.flag_rounded,
        label: l.t('rides_label'),
        value: '$rideCount',
        unit: '',
        color: Color(0xFF2196F3),
        statKey: 'rides',
      ),
      _StatItem(
        icon: Icons.speed_rounded,
        label: l.t('avg_speed'),
        value: avgSpd.toStringAsFixed(1),
        unit: 'km/h',
        color: Color(0xFFFF9800),
        statKey: 'avgSpeed',
      ),
      _StatItem(
        icon: Icons.rocket_launch_rounded,
        label: l.t('max_speed'),
        value: maxSpd.toStringAsFixed(1),
        unit: 'km/h',
        color: Color(0xFFF44336),
        statKey: 'maxSpeed',
      ),
      _StatItem(
        icon: Icons.terrain_rounded,
        label: l.t('elevation'),
        value: '$elev',
        unit: 'm',
        color: Color(0xFF4CAF50),
        statKey: 'elevation',
      ),
      _StatItem(
        icon: Icons.local_fire_department_rounded,
        label: l.t('calories'),
        value: '$cal',
        unit: 'kcal',
        color: Color(0xFFFF5722),
        statKey: 'calories',
      ),
      _StatItem(
        icon: Icons.timer_rounded,
        label: l.t('time_label'),
        value: timeStr,
        unit: '',
        color: Color(0xFF3F51B5),
      ),
      _StatItem(
        icon: Icons.bolt_rounded,
        label: l.t('streak'),
        value: '$currentStreak',
        unit: 'días',
        color: const Color(0xFFFFC107),
      ),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.45,
      ),
      itemCount: items.length,
      itemBuilder: (context, index) => _buildStatTile(items[index]),
    );
  }

  Widget _buildStatTile(_StatItem item) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Material(
      color: isDark ? ColorTokens.primary20 : Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: item.statKey.isNotEmpty ? () => _showRideBreakdown(item) : null,
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.12 : 0.04),
                blurRadius: 8,
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: item.color.withValues(alpha: isDark ? 0.2 : 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(item.icon, size: 18, color: item.color),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      item.label,
                      style: TextStyle(
                        fontSize: 11,
                        color: isDark ? Colors.white : Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 12,
                    color: isDark ? Colors.white30 : Colors.grey[300],
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: item.value,
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                            color: isDark ? Colors.white : Colors.grey[800],
                          ),
                        ),
                        if (item.unit.isNotEmpty)
                          TextSpan(
                            text: ' ${item.unit}',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: isDark ? Colors.white70 : Colors.grey[500],
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ─── DESGLOSE POR RODADA ─────────────────────────────────
  void _showRideBreakdown(_StatItem item) {
    final rides = _filteredRides();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    String _rideValue(RideTrackEntity r) {
      switch (item.statKey) {
        case 'km':
          return '${r.totalKm.toStringAsFixed(2)} km';
        case 'rides':
          return r.durationFormatted;
        case 'avgSpeed':
          return '${r.avgSpeed.toStringAsFixed(1)} km/h';
        case 'maxSpeed':
          return '${r.maxSpeed.toStringAsFixed(1)} km/h';
        case 'elevation':
          return '${r.elevationGain} m';
        case 'calories':
          return '${r.calories} kcal';
        default:
          return '';
      }
    }

    // Ordenar: mayor valor primero
    final sorted = List<RideTrackEntity>.from(rides);
    sorted.sort((a, b) {
      double val(RideTrackEntity r) {
        switch (item.statKey) {
          case 'km':
            return r.totalKm;
          case 'rides':
            return r.durationMinutes.toDouble();
          case 'avgSpeed':
            return r.avgSpeed;
          case 'maxSpeed':
            return r.maxSpeed;
          case 'elevation':
            return r.elevationGain.toDouble();
          case 'calories':
            return r.calories.toDouble();
          default:
            return 0;
        }
      }

      return val(b).compareTo(val(a));
    });

    final months = [
      '',
      'Ene',
      'Feb',
      'Mar',
      'Abr',
      'May',
      'Jun',
      'Jul',
      'Ago',
      'Sep',
      'Oct',
      'Nov',
      'Dic',
    ];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize: 0.4,
        maxChildSize: 0.92,
        expand: false,
        builder: (ctx, scrollCtrl) => Container(
          decoration: BoxDecoration(
            color: isDark ? ColorTokens.primary20 : Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              // Handle
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: isDark ? Colors.white24 : Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              // Header
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: item.color.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(item.icon, color: item.color, size: 22),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.label,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: isDark
                                ? Colors.white
                                : ColorTokens.primary30,
                          ),
                        ),
                        Text(
                          '${sorted.length} rodadas',
                          style: TextStyle(
                            fontSize: 12,
                            color: isDark ? Colors.white54 : Colors.grey[500],
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: item.color.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        '${item.value} ${item.unit}'.trim(),
                        style: TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 14,
                          color: item.color,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Divider(height: 1),
              // Lista
              Expanded(
                child: sorted.isEmpty
                    ? Center(
                        child: Text(
                          l.t('no_rides_yet'),
                          style: TextStyle(
                            color: isDark ? Colors.white54 : Colors.grey[400],
                          ),
                        ),
                      )
                    : ListView.builder(
                        controller: scrollCtrl,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        itemCount: sorted.length,
                        itemBuilder: (_, i) {
                          final ride = sorted[i];
                          final date = ride.startTime;
                          final dateStr =
                              '${date.day} ${months[date.month]} ${date.year}';
                          final name = ride.name.isNotEmpty
                              ? ride.name
                              : dateStr;
                          return Container(
                            margin: const EdgeInsets.only(bottom: 8),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 12,
                            ),
                            decoration: BoxDecoration(
                              color: isDark
                                  ? ColorTokens.primary30.withValues(
                                      alpha: 0.25,
                                    )
                                  : Colors.grey[50],
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              children: [
                                // Posición
                                Container(
                                  width: 28,
                                  height: 28,
                                  decoration: BoxDecoration(
                                    color: i == 0
                                        ? item.color.withValues(alpha: 0.2)
                                        : (isDark
                                              ? Colors.white10
                                              : Colors.grey[200]),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Center(
                                    child: Text(
                                      '${i + 1}',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w700,
                                        color: i == 0
                                            ? item.color
                                            : (isDark
                                                  ? Colors.white60
                                                  : Colors.grey[600]),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                // Ícono
                                Icon(item.icon, size: 18, color: item.color),
                                const SizedBox(width: 10),
                                // Nombre
                                Expanded(
                                  child: Text(
                                    name,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 13,
                                      color: Colors.white,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                // Valor
                                Text(
                                  _rideValue(ride),
                                  style: TextStyle(
                                    fontWeight: FontWeight.w800,
                                    fontSize: 14,
                                    color: item.color,
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ─── RECORDS PERSONALES ──────────────────────────────────
  Widget _buildRecordsSection(CyclingStatsEntity stats) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    // Calcular récords desde historial real (no desde caché Firestore)
    final allRides = context.read<RideTrackerProvider>().history;
    final hasAll = allRides.isNotEmpty;
    final totalKmAll = allRides.fold(0.0, (s, r) => s + r.totalKm);
    final maxSpdAll = hasAll
        ? allRides.map((r) => r.maxSpeed).reduce((a, b) => a > b ? a : b)
        : 0.0;
    final streakAll = _computeStreak(allRides);
    final totalRidesAll = allRides.length;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [
                  Colors.amber.withValues(alpha: 0.15),
                  Colors.amber.withValues(alpha: 0.05),
                ]
              : [const Color(0xFFFFF8E1), Colors.amber.withValues(alpha: 0.1)],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.amber.withValues(alpha: isDark ? 0.4 : 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.emoji_events_rounded, color: Colors.amber, size: 22),
              SizedBox(width: 8),
              Text(
                'Récords Personales',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _buildRecordItem(
                  '🏎️',
                  l.t('max_speed'),
                  '${maxSpdAll.toStringAsFixed(1)} km/h',
                ),
              ),
              Container(
                width: 1,
                height: 40,
                color: Colors.amber.withValues(alpha: 0.3),
              ),
              Expanded(
                child: _buildRecordItem(
                  '🗺️',
                  'Distancia Total',
                  '${totalKmAll.toStringAsFixed(1)} km',
                ),
              ),
            ],
          ),
          SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildRecordItem('🔥', 'Mejor Racha', '$streakAll días'),
              ),
              Container(
                width: 1,
                height: 40,
                color: Colors.amber.withValues(alpha: 0.3),
              ),
              Expanded(
                child: _buildRecordItem(
                  '🏁',
                  l.t('total_rides'),
                  '$totalRidesAll',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRecordItem(String emoji, String label, String value) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Column(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 20)),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: isDark ? ColorTokens.neutral100 : null,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              color: isDark ? Colors.white70 : Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  // ─── GRÁFICO MENSUAL ─────────────────────────────────────
  Widget _buildMonthlyChart(CyclingStatsEntity stats) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final months = stats.monthlyKm.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key));
    final last6 = months.length > 6
        ? months.sublist(months.length - 6)
        : months;
    final maxKm = last6.isEmpty
        ? 1.0
        : last6.map((e) => e.value).reduce((a, b) => a > b ? a : b);
    final monthNames = [
      '',
      'Ene',
      'Feb',
      'Mar',
      'Abr',
      'May',
      'Jun',
      'Jul',
      'Ago',
      'Sep',
      'Oct',
      'Nov',
      'Dic',
    ];
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? ColorTokens.primary20 : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.12 : 0.04),
            blurRadius: 8,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.show_chart_rounded,
                size: 20,
                color: ColorTokens.primary30,
              ),
              const SizedBox(width: 8),
              const Text(
                'Kilómetros por Mes',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const Spacer(),
              if (last6.isNotEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: ColorTokens.primary30.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'Últimos ${last6.length} meses',
                    style: TextStyle(
                      fontSize: 10,
                      color: ColorTokens.primary30,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 20),
          if (last6.isEmpty)
            SizedBox(
              height: 120,
              child: Center(
                child: Text(
                  'Sin datos aún',
                  style: TextStyle(
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.white54
                        : Colors.grey,
                  ),
                ),
              ),
            )
          else
            SizedBox(
              height: 140,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: last6.map((entry) {
                  final height = maxKm > 0 ? (entry.value / maxKm) * 110 : 0.0;
                  final parts = entry.key.split('-');
                  final monthIdx =
                      int.tryParse(parts.length > 1 ? parts[1] : '0') ?? 0;
                  final monthLabel = monthIdx > 0 && monthIdx <= 12
                      ? monthNames[monthIdx]
                      : parts.last;
                  final isMax = entry.value == maxKm;

                  return Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          '${entry.value.toInt()}',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: isMax
                                ? ColorTokens.primary30
                                : (isDark ? Colors.white : Colors.grey[600]),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          height: height.clamp(4.0, 110.0),
                          margin: const EdgeInsets.symmetric(horizontal: 6),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.bottomCenter,
                              end: Alignment.topCenter,
                              colors: isMax
                                  ? [
                                      ColorTokens.primary30,
                                      ColorTokens.primary30.withValues(
                                        alpha: 0.6,
                                      ),
                                    ]
                                  : [
                                      ColorTokens.primary30.withValues(
                                        alpha: 0.4,
                                      ),
                                      ColorTokens.primary30.withValues(
                                        alpha: 0.15,
                                      ),
                                    ],
                            ),
                            borderRadius: BorderRadius.circular(6),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          monthLabel,
                          style: TextStyle(
                            fontSize: 11,
                            color: isMax
                                ? ColorTokens.primary30
                                : (isDark ? Colors.white70 : Colors.grey[500]),
                            fontWeight: isMax
                                ? FontWeight.w700
                                : FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
        ],
      ),
    );
  }

  // ─── RESUMEN RÁPIDO ──────────────────────────────────────
  Widget _buildQuickSummary(CyclingStatsEntity stats) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    // Calcular promedios desde historial real para reflejar borrados
    final allRides = context.read<RideTrackerProvider>().history;
    final totalRidesCount = allRides.length;
    final totalKmAll = allRides.fold(0.0, (s, r) => s + r.totalKm);
    final totalMinAll = allRides.fold(0, (s, r) => s + r.durationMinutes);
    final avgPerRide = totalRidesCount > 0 ? totalKmAll / totalRidesCount : 0.0;
    final avgMinPerRide = totalRidesCount > 0
        ? totalMinAll.toDouble() / totalRidesCount
        : 0.0;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? ColorTokens.primary20 : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.12 : 0.04),
            blurRadius: 8,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.insights_rounded,
                size: 20,
                color: Colors.deepPurple[400],
              ),
              const SizedBox(width: 8),
              const Text(
                'Resumen de Actividad',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 14),
          _buildSummaryRow(
            Icons.route_rounded,
            'Promedio por rodada',
            '${avgPerRide.toStringAsFixed(1)} km',
          ),
          _buildSummaryRow(
            Icons.timer_outlined,
            'Tiempo promedio',
            '${avgMinPerRide.toStringAsFixed(0)} min',
          ),
          _buildSummaryRow(
            Icons.calendar_today_rounded,
            'Última rodada',
            _formatLastRide(stats.lastRideDate),
          ),
          _buildSummaryRow(
            Icons.trending_up_rounded,
            'Nivel actual',
            '${stats.levelEmoji} ${stats.level.toUpperCase()}',
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(IconData icon, String label, String value) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(
            icon,
            size: 18,
            color: isDark ? Colors.white60 : Colors.grey[400],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 13,
                color: isDark ? Colors.white70 : Colors.grey[600],
              ),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: isDark ? Colors.white : null,
            ),
          ),
        ],
      ),
    );
  }

  String _formatLastRide(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date).inDays;
    if (diff == 0) return 'Hoy';
    if (diff == 1) return 'Ayer';
    if (diff < 7) return 'Hace $diff días';
    return '${date.day}/${date.month}/${date.year}';
  }

  // ─── TAB RANKING ─────────────────────────────────────────
  Widget _buildLeaderboardTab(CyclingStatsProvider provider) {
    final userProvider = context.watch<UserProvider>();
    final currentUser = userProvider.user;
    final followingIds = (currentUser?.following?.keys.toList() ?? []);
    // Incluir al usuario actual en amigos
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid != null && !followingIds.contains(uid)) followingIds.add(uid);

    final leaderboard = _rankingMode == 'amigos'
        ? provider.friendsLeaderboard
        : provider.leaderboard;

    return Column(
      children: [
        // ── SELECTOR DE MODO ──
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
          child: Row(
            children: [
              _rankingChip(
                label: l.t('friends_tab'),
                selected: _rankingMode == 'amigos',
                onTap: () {
                  setState(() => _rankingMode = 'amigos');
                  provider.loadFriendsLeaderboard(followingIds);
                },
              ),
              SizedBox(width: 8),
              _rankingChip(
                label: l.t('regional_tab'),
                selected: _rankingMode == 'regional',
                onTap: () {
                  setState(() => _rankingMode = 'regional');
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(l.t('regional_ranking_soon')),
                      backgroundColor: ColorTokens.primary30,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
        Divider(height: 1),
        // ── LISTA ──
        Expanded(
          child: leaderboard.isEmpty
              ? _buildEmptyState(
                  icon: Icons.leaderboard_rounded,
                  title: _rankingMode == 'amigos'
                      ? l.t('no_friends_ranking')
                      : 'Ranking vacío',
                  subtitle: _rankingMode == 'amigos'
                      ? 'Sigue a otros ciclistas\npara verlos aquí'
                      : 'Aún no hay ciclistas en el ranking.\n¡Sé el primero!',
                )
              : RefreshIndicator(
                  onRefresh: () async {
                    if (_rankingMode == 'amigos') {
                      await provider.loadFriendsLeaderboard(followingIds);
                    } else {
                      await provider.loadLeaderboard();
                    }
                  },
                  color: ColorTokens.primary30,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: leaderboard.length + 1,
                    itemBuilder: (context, index) {
                      if (index == 0)
                        return _buildLeaderboardHeader(leaderboard);
                      return _buildLeaderboardItem(
                        leaderboard[index - 1],
                        index - 1,
                      );
                    },
                  ),
                ),
        ),
      ],
    );
  }

  Widget _rankingChip({
    required String label,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? ColorTokens.primary30 : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected
                ? ColorTokens.primary30
                : Colors.grey.withValues(alpha: 0.4),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: selected ? FontWeight.bold : FontWeight.normal,
            color: selected ? Colors.white : null,
          ),
        ),
      ),
    );
  }

  Widget _buildLeaderboardHeader(List<Map<String, dynamic>> leaderboard) {
    if (leaderboard.length < 3) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            ColorTokens.primary30,
            ColorTokens.primary30.withValues(alpha: 0.85),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          const Text(
            '🏆 Top 3 Ciclistas',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              if (leaderboard.length > 1)
                _buildPodiumItem(leaderboard[1], 2, 60),
              _buildPodiumItem(leaderboard[0], 1, 80),
              if (leaderboard.length > 2)
                _buildPodiumItem(leaderboard[2], 3, 50),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPodiumItem(
    Map<String, dynamic> entry,
    int position,
    double height,
  ) {
    final km = (entry['totalKm'] as num?)?.toDouble() ?? 0;
    final medals = ['', '🥇', '🥈', '🥉'];
    final levelEmoji = _getLevelEmoji(km);

    return Column(
      children: [
        Text(medals[position], style: const TextStyle(fontSize: 28)),
        const SizedBox(height: 4),
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.2),
            shape: BoxShape.circle,
            border: Border.all(
              color: position == 1
                  ? Colors.amber
                  : Colors.white.withValues(alpha: 0.4),
              width: position == 1 ? 2.5 : 1.5,
            ),
          ),
          child: Center(
            child: Text(levelEmoji, style: const TextStyle(fontSize: 22)),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          ((entry['userName'] as String?) ?? '').isEmpty
              ? '#$position'
              : (entry['userName'] as String),
          style: const TextStyle(
            color: Colors.white,
            fontSize: 10,
            fontWeight: FontWeight.w600,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 2),
        Text(
          '${km.toStringAsFixed(0)} km',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: 50,
          height: height,
          decoration: BoxDecoration(
            color: position == 1
                ? Colors.amber.withValues(alpha: 0.4)
                : Colors.white.withValues(alpha: 0.15),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
          ),
          child: Center(
            child: Text(
              '#$position',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.8),
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLeaderboardItem(Map<String, dynamic> entry, int index) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final km = (entry['totalKm'] as num?)?.toDouble() ?? 0;
    final level = entry['level'] ?? 'novato';
    final totalRides = (entry['totalRides'] as num?)?.toInt() ?? 0;
    final isTop3 = index < 3;
    final medals = ['🥇', '🥈', '🥉'];

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isTop3
            ? Colors.amber.withValues(alpha: isDark ? 0.12 : 0.06)
            : (isDark ? ColorTokens.primary20 : Colors.white),
        borderRadius: BorderRadius.circular(14),
        border: isTop3
            ? Border.all(
                color: Colors.amber.withValues(alpha: isDark ? 0.4 : 0.2),
              )
            : null,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.1 : 0.03),
            blurRadius: 6,
          ),
        ],
      ),
      child: Row(
        children: [
          // Posición
          SizedBox(
            width: 36,
            child: isTop3
                ? Text(medals[index], style: const TextStyle(fontSize: 22))
                : Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: isDark ? ColorTokens.primary40 : Colors.grey[100],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: Text(
                        '#${index + 1}',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: isDark ? Colors.white : Colors.grey[600],
                        ),
                      ),
                    ),
                  ),
          ),
          const SizedBox(width: 12),
          // Avatar nivel
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: ColorTokens.primary30.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                _getLevelEmoji(km),
                style: const TextStyle(fontSize: 22),
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  ((entry['userName'] as String?) ?? '').isEmpty
                      ? 'Ciclista #${index + 1}'
                      : entry['userName'] as String,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    color: isDark ? ColorTokens.neutral100 : null,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  '${km.toStringAsFixed(1)} km · $totalRides rodadas',
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? Colors.white70 : Colors.grey[500],
                  ),
                ),
              ],
            ),
          ),
          // Badge de nivel
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: _getLevelColor(level).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              level.toUpperCase(),
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: _getLevelColor(level),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─── ESTADO VACÍO ────────────────────────────────────────
  Widget _buildEmptyState({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: ColorTokens.primary30.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 40,
                color: ColorTokens.primary30.withValues(alpha: 0.4),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.white54
                    : Colors.grey[500],
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _loadData,
              icon: Icon(Icons.refresh, size: 18),
              label: Text(l.t('update')),
              style: ElevatedButton.styleFrom(
                backgroundColor: ColorTokens.primary30,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── HELPERS ─────────────────────────────────────────────
  String _getLevelEmoji(double km) {
    if (km >= 10000) return '👑';
    if (km >= 5000) return '⭐';
    if (km >= 2500) return '🏆';
    if (km >= 1000) return '💎';
    if (km >= 500) return '🔥';
    if (km >= 150) return '⚡';
    if (km >= 50) return '🚲';
    return '🌱';
  }

  Color _getLevelColor(String level) {
    switch (level) {
      case 'leyenda':
        return Colors.amber[800]!;
      case 'maestro':
        return Colors.amber;
      case 'elite':
        return Colors.deepPurple;
      case 'experto':
        return Colors.indigo;
      case 'avanzado':
        return Colors.red[700]!;
      case 'intermedio':
        return Colors.blue[700]!;
      case 'aprendiz':
        return Colors.teal;
      default:
        return Colors.green[700]!;
    }
  }

  void _shareStats(CyclingStatsEntity? stats) {
    if (stats == null) return;
    // Usar historial real para que refleje rodadas borradas
    final allRides = context.read<RideTrackerProvider>().history;
    final totalKmH = allRides.fold(0.0, (s, r) => s + r.totalKm);
    final avgSpdH = allRides.isNotEmpty
        ? allRides.fold(0.0, (s, r) => s + r.avgSpeed) / allRides.length
        : 0.0;
    final maxSpdH = allRides.isNotEmpty
        ? allRides.map((r) => r.maxSpeed).reduce((a, b) => a > b ? a : b)
        : 0.0;
    final streakH = _computeStreak(allRides);
    final text =
        '🚴 Mis estadísticas en Biux:\n\n'
        '📏 ${totalKmH.toStringAsFixed(1)} km recorridos\n'
        '🏁 ${allRides.length} rodadas completadas\n'
        '⚡ ${avgSpdH.toStringAsFixed(1)} km/h promedio\n'
        '🚀 ${maxSpdH.toStringAsFixed(1)} km/h velocidad máxima\n'
        '🔥 Racha de $streakH días\n'
        '${stats.levelEmoji} Nivel: ${stats.level.toUpperCase()}\n\n'
        '¡Descarga Biux y pedalea conmigo!';
    SharePlus.instance.share(ShareParams(text: text));
  }
}

class _StatItem {
  final IconData icon;
  final String label;
  final String value;
  final String unit;
  final Color color;
  final String statKey;

  const _StatItem({
    required this.icon,
    required this.label,
    required this.value,
    required this.unit,
    required this.color,
    this.statKey = '',
  });
}
