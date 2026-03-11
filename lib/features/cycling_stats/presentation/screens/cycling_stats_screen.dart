import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:share_plus/share_plus.dart';
import 'package:biux/core/design_system/color_tokens.dart';
import 'package:biux/core/design_system/locale_notifier.dart';
import 'package:biux/features/cycling_stats/presentation/providers/cycling_stats_provider.dart';
import 'package:biux/features/cycling_stats/domain/entities/cycling_stats_entity.dart';

class CyclingStatsScreen extends StatefulWidget {
  const CyclingStatsScreen({Key? key}) : super(key: key);

  @override
  State<CyclingStatsScreen> createState() => _CyclingStatsScreenState();
}

class _CyclingStatsScreenState extends State<CyclingStatsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _selectedPeriod = 'total';

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
    }
  }

  void _syncAndNotify() {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;
    final provider = context.read<CyclingStatsProvider>();
    if (provider.isSyncing) return;

    provider.refreshAll(uid).then((_) {
      if (mounted) {
        final l = Provider.of<LocaleNotifier>(context, listen: false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white, size: 18),
                const SizedBox(width: 10),
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
    final l = Provider.of<LocaleNotifier>(context, listen: false);
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
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
                    l.t('loading_stats'),
                    style: const TextStyle(color: Colors.grey),
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
                    icon: const Icon(Icons.refresh),
                    label: Text(l.t('retry')),
                  ),
                ],
              ),
            );
          }

          return NestedScrollView(
            headerSliverBuilder: (context, innerBoxIsScrolled) => [
              _buildSliverAppBar(provider, l),
            ],
            body: TabBarView(
              controller: _tabController,
              children: [
                _buildStatsTab(provider, l),
                _buildLeaderboardTab(provider, l),
              ],
            ),
          );
        },
      ),
    );
  }

  // ─── APPBAR ──────────────────────────────────────────────
  SliverAppBar _buildSliverAppBar(
    CyclingStatsProvider provider,
    LocaleNotifier l,
  ) {
    final stats = provider.stats;
    return SliverAppBar(
      expandedHeight: 200,
      pinned: true,
      backgroundColor: ColorTokens.primary30,
      foregroundColor: Colors.white,
      title: Text(
        l.t('my_stats'),
        style: const TextStyle(fontWeight: FontWeight.bold),
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
          tooltip: l.t('update_stats'),
          onPressed: provider.isSyncing ? null : _syncAndNotify,
        ),
        IconButton(
          icon: const Icon(Icons.share),
          tooltip: l.t('share'),
          onPressed: () => _shareStats(stats, l),
        ),
      ],
      bottom: TabBar(
        controller: _tabController,
        indicatorColor: Colors.white,
        indicatorWeight: 3,
        labelColor: Colors.white,
        unselectedLabelColor: Colors.white60,
        labelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
        tabs: [
          Tab(
            icon: const Icon(Icons.bar_chart_rounded, size: 22),
            text: l.t('statistics'),
          ),
          Tab(
            icon: const Icon(Icons.emoji_events_rounded, size: 22),
            text: l.t('ranking'),
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
                top: 50,
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
                                '${stats.totalKm.toStringAsFixed(1)} ${l.t('km_total_suffix')}',
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
                                    ? l.t('max_level_reached')
                                    : '${stats.kmToNextLevel.toStringAsFixed(0)} ${l.t('km_to_next_level')} ${l.t(stats.nextLevelName)}',
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
  Widget _buildStatsTab(CyclingStatsProvider provider, LocaleNotifier l) {
    final stats = provider.stats;
    if (stats == null) {
      return _buildEmptyState(
        l: l,
        icon: Icons.pedal_bike,
        title: l.t('no_stats_yet'),
        subtitle: l.t('complete_first_ride_subtitle'),
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
          if (provider.lastUpdated != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                children: [
                  Icon(Icons.access_time, size: 14, color: Colors.grey[400]),
                  const SizedBox(width: 6),
                  Text(
                    '${l.t('updated')}: ${provider.lastUpdatedLabel}',
                    style: TextStyle(fontSize: 11, color: Colors.grey[500]),
                  ),
                  const Spacer(),
                  GestureDetector(
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
                              ? SizedBox(
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
                          const SizedBox(width: 4),
                          Text(
                            provider.isSyncing
                                ? l.t('updating')
                                : l.t('update'),
                            style: TextStyle(
                              fontSize: 11,
                              color: ColorTokens.primary30,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          _buildPeriodFilter(l),
          const SizedBox(height: 16),

          // Stats principales en grid
          _buildMainStatsGrid(stats, l),
          const SizedBox(height: 16),

          // Récords personales
          _buildRecordsSection(stats, l),
          const SizedBox(height: 16),

          // Gráfico mensual
          _buildMonthlyChart(stats, l),
          const SizedBox(height: 16),

          // Resumen rápido
          _buildQuickSummary(stats, l),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  // ─── FILTRO DE PERÍODO ───────────────────────────────────
  Widget _buildPeriodFilter(LocaleNotifier l) {
    final periods = [
      {'id': 'total', 'label': l.t('total')},
      {'id': 'month', 'label': l.t('this_month')},
      {'id': 'week', 'label': l.t('week')},
    ];

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8),
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
                    color: isSelected ? Colors.white : Colors.grey[600],
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
  Widget _buildMainStatsGrid(CyclingStatsEntity stats, LocaleNotifier l) {
    final items = [
      _StatItem(
        icon: Icons.straighten_rounded,
        label: l.t('distance'),
        value: '${stats.totalKm.toStringAsFixed(1)}',
        unit: 'km',
        color: ColorTokens.primary30,
      ),
      _StatItem(
        icon: Icons.flag_rounded,
        label: l.t('rides'),
        value: '${stats.totalRides}',
        unit: '',
        color: const Color(0xFF2196F3),
      ),
      _StatItem(
        icon: Icons.speed_rounded,
        label: l.t('avg_speed'),
        value: stats.avgSpeed.toStringAsFixed(1),
        unit: 'km/h',
        color: const Color(0xFFFF9800),
      ),
      _StatItem(
        icon: Icons.rocket_launch_rounded,
        label: l.t('max_speed'),
        value: stats.maxSpeed.toStringAsFixed(1),
        unit: 'km/h',
        color: const Color(0xFFF44336),
      ),
      _StatItem(
        icon: Icons.terrain_rounded,
        label: l.t('elevation'),
        value: '${stats.totalElevation}',
        unit: 'm',
        color: const Color(0xFF4CAF50),
      ),
      _StatItem(
        icon: Icons.local_fire_department_rounded,
        label: l.t('calories'),
        value: '${stats.totalCalories}',
        unit: 'kcal',
        color: const Color(0xFFFF5722),
      ),
      _StatItem(
        icon: Icons.timer_rounded,
        label: l.t('time'),
        value: stats.formattedTime,
        unit: '',
        color: const Color(0xFF3F51B5),
      ),
      _StatItem(
        icon: Icons.bolt_rounded,
        label: l.t('streak'),
        value: '${stats.streak}',
        unit: l.t('days'),
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
        childAspectRatio: 1.6,
      ),
      itemCount: items.length,
      itemBuilder: (context, index) => _buildStatTile(items[index]),
    );
  }

  Widget _buildStatTile(_StatItem item) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8),
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
                  color: item.color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(item.icon, size: 18, color: item.color),
              ),
              const Spacer(),
              Icon(
                Icons.arrow_forward_ios_rounded,
                size: 12,
                color: Colors.grey[300],
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
                        color: Colors.grey[800],
                      ),
                    ),
                    if (item.unit.isNotEmpty)
                      TextSpan(
                        text: ' ${item.unit}',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey[500],
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 2),
              Text(
                item.label,
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.grey[500],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ─── RECORDS PERSONALES ──────────────────────────────────
  Widget _buildRecordsSection(CyclingStatsEntity stats, LocaleNotifier l) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFFFFF8E1),
            Colors.amber.withValues(alpha: 0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.amber.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.emoji_events_rounded,
                color: Colors.amber,
                size: 22,
              ),
              const SizedBox(width: 8),
              Text(
                l.t('personal_records'),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _buildRecordItem(
                  '🏎️',
                  l.t('max_speed'),
                  '${stats.maxSpeed.toStringAsFixed(1)} km/h',
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
                  l.t('total_distance'),
                  '${stats.totalKm.toStringAsFixed(1)} km',
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildRecordItem(
                  '🔥',
                  l.t('best_streak'),
                  '${stats.streak} ${l.t('days')}',
                ),
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
                  '${stats.totalRides}',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRecordItem(String emoji, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Column(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 20)),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
          ),
          Text(label, style: TextStyle(fontSize: 10, color: Colors.grey[600])),
        ],
      ),
    );
  }

  // ─── GRÁFICO MENSUAL ─────────────────────────────────────
  Widget _buildMonthlyChart(CyclingStatsEntity stats, LocaleNotifier l) {
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
      l.t('month_jan'),
      l.t('month_feb'),
      l.t('month_mar'),
      l.t('month_apr'),
      l.t('month_may'),
      l.t('month_jun'),
      l.t('month_jul'),
      l.t('month_aug'),
      l.t('month_sep'),
      l.t('month_oct'),
      l.t('month_nov'),
      l.t('month_dec'),
    ];

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8),
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
              Text(
                l.t('km_per_month'),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
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
                    '${l.t('last_n_months_prefix')} ${last6.length} ${l.t('months')}',
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
                  l.t('no_data_yet'),
                  style: const TextStyle(color: Colors.grey),
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
                                : Colors.grey[600],
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
                                : Colors.grey[500],
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
  Widget _buildQuickSummary(CyclingStatsEntity stats, LocaleNotifier l) {
    final avgPerRide = stats.totalRides > 0
        ? stats.totalKm / stats.totalRides
        : 0.0;
    final avgMinPerRide = stats.totalRides > 0
        ? stats.totalMinutes / stats.totalRides
        : 0.0;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8),
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
              Text(
                l.t('activity_summary'),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          _buildSummaryRow(
            Icons.route_rounded,
            l.t('avg_per_ride'),
            '${avgPerRide.toStringAsFixed(1)} km',
          ),
          _buildSummaryRow(
            Icons.timer_outlined,
            l.t('avg_time'),
            '${avgMinPerRide.toStringAsFixed(0)} min',
          ),
          _buildSummaryRow(
            Icons.calendar_today_rounded,
            l.t('last_ride'),
            _formatLastRide(stats.lastRideDate, l),
          ),
          _buildSummaryRow(
            Icons.trending_up_rounded,
            l.t('current_level'),
            '${stats.levelEmoji} ${stats.level.toUpperCase()}',
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, size: 18, color: Colors.grey[400]),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: TextStyle(fontSize: 13, color: Colors.grey[600]),
            ),
          ),
          Text(
            value,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }

  String _formatLastRide(DateTime date, LocaleNotifier l) {
    final now = DateTime.now();
    final diff = now.difference(date).inDays;
    if (diff == 0) return l.t('today');
    if (diff == 1) return l.t('yesterday');
    if (diff < 7) return '${l.t('ago_prefix')} $diff ${l.t('days')}';
    return '${date.day}/${date.month}/${date.year}';
  }

  // ─── TAB RANKING ─────────────────────────────────────────
  Widget _buildLeaderboardTab(CyclingStatsProvider provider, LocaleNotifier l) {
    final leaderboard = provider.leaderboard;

    if (leaderboard.isEmpty) {
      return _buildEmptyState(
        l: l,
        icon: Icons.leaderboard_rounded,
        title: l.t('empty_ranking'),
        subtitle: l.t('empty_ranking_subtitle'),
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        await context.read<CyclingStatsProvider>().loadLeaderboard();
      },
      color: ColorTokens.primary30,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: leaderboard.length + 1, // +1 para el header
        itemBuilder: (context, index) {
          if (index == 0) return _buildLeaderboardHeader(leaderboard, l);
          return _buildLeaderboardItem(leaderboard[index - 1], index - 1, l);
        },
      ),
    );
  }

  Widget _buildLeaderboardHeader(
    List<Map<String, dynamic>> leaderboard,
    LocaleNotifier l,
  ) {
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
          Text(
            '🏆 ${l.t('top_3_cyclists')}',
            style: const TextStyle(
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

  Widget _buildLeaderboardItem(
    Map<String, dynamic> entry,
    int index,
    LocaleNotifier l,
  ) {
    final km = (entry['totalKm'] as num?)?.toDouble() ?? 0;
    final level = entry['level'] ?? 'novato';
    final totalRides = (entry['totalRides'] as num?)?.toInt() ?? 0;
    final isTop3 = index < 3;
    final medals = ['🥇', '🥈', '🥉'];

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isTop3 ? Colors.amber.withValues(alpha: 0.06) : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: isTop3
            ? Border.all(color: Colors.amber.withValues(alpha: 0.2))
            : null,
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 6),
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
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: Text(
                        '#${index + 1}',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: Colors.grey[600],
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
                  '${l.t('cyclist')} #${index + 1}',
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${km.toStringAsFixed(1)} km · $totalRides ${l.t('rides')}',
                  style: TextStyle(fontSize: 12, color: Colors.grey[500]),
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
    required LocaleNotifier l,
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
              style: TextStyle(color: Colors.grey[500], fontSize: 14),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _loadData,
              icon: const Icon(Icons.refresh, size: 18),
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
    if (km >= 5000) return '💎';
    if (km >= 1000) return '🔥';
    if (km >= 200) return '⚡';
    return '🌱';
  }

  Color _getLevelColor(String level) {
    switch (level) {
      case 'leyenda':
        return Colors.amber[800]!;
      case 'experto':
        return Colors.deepPurple;
      case 'avanzado':
        return Colors.red[700]!;
      case 'intermedio':
        return Colors.blue[700]!;
      default:
        return Colors.green[700]!;
    }
  }

  void _shareStats(CyclingStatsEntity? stats, LocaleNotifier l) {
    if (stats == null) return;
    final text =
        '🚴 ${l.t('my_stats_in_biux')}:\n\n'
        '📏 ${stats.totalKm.toStringAsFixed(1)} ${l.t('km_traveled')}\n'
        '🏁 ${stats.totalRides} ${l.t('rides_completed')}\n'
        '⚡ ${stats.avgSpeed.toStringAsFixed(1)} ${l.t('kmh_avg')}\n'
        '🚀 ${stats.maxSpeed.toStringAsFixed(1)} ${l.t('kmh_max_speed')}\n'
        '🔥 ${l.t('streak_of')} ${stats.streak} ${l.t('days')}\n'
        '${stats.levelEmoji} ${l.t('level')}: ${stats.level.toUpperCase()}\n\n'
        '${l.t('download_biux_cta')}';
    SharePlus.instance.share(ShareParams(text: text));
  }
}

class _StatItem {
  final IconData icon;
  final String label;
  final String value;
  final String unit;
  final Color color;

  const _StatItem({
    required this.icon,
    required this.label,
    required this.value,
    required this.unit,
    required this.color,
  });
}
