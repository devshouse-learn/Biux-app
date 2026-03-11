import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:biux/core/design_system/color_tokens.dart';
import 'package:biux/core/design_system/locale_notifier.dart';
import 'package:biux/features/ride_tracker/presentation/providers/ride_tracker_provider.dart';
import 'package:biux/features/ride_tracker/domain/entities/ride_track_entity.dart';

class RideTrackerScreen extends StatefulWidget {
  const RideTrackerScreen({Key? key}) : super(key: key);

  @override
  State<RideTrackerScreen> createState() => _RideTrackerScreenState();
}

class _RideTrackerScreenState extends State<RideTrackerScreen>
    with SingleTickerProviderStateMixin {
  GoogleMapController? _mapController;
  late AnimationController _pulseController;
  bool _showHistory = false;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
    // Cargar historial al iniciar
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid != null) {
        context.read<RideTrackerProvider>().loadHistory(uid);
      }
    });
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _mapController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = Provider.of<LocaleNotifier>(context, listen: false);
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: Consumer<RideTrackerProvider>(
        builder: (ctx, p, _) {
          if (p.points.isNotEmpty && _mapController != null) {
            final last = p.points.last;
            _mapController!.animateCamera(
              CameraUpdate.newLatLng(LatLng(last.lat, last.lng)),
            );
          }

          // Si está mostrando historial
          if (_showHistory && !p.isTracking) {
            return _buildHistoryView(p, l);
          }

          return Stack(
            children: [
              _buildMapArea(p, l),
              _buildTopBar(p, l),
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: _buildBottomPanel(p, l),
              ),
            ],
          );
        },
      ),
    );
  }

  // ─── MAPA ────────────────────────────────────────────────
  Widget _buildMapArea(RideTrackerProvider p, LocaleNotifier l) {
    if (p.points.isNotEmpty) {
      return GoogleMap(
        initialCameraPosition: CameraPosition(
          target: LatLng(p.points.last.lat, p.points.last.lng),
          zoom: 16.5,
        ),
        onMapCreated: (controller) => _mapController = controller,
        polylines: {
          Polyline(
            polylineId: const PolylineId('track'),
            points: p.points.map((pt) => LatLng(pt.lat, pt.lng)).toList(),
            color: ColorTokens.primary30,
            width: 5,
          ),
        },
        markers: p.points.length > 1
            ? {
                Marker(
                  markerId: const MarkerId('start'),
                  position: LatLng(p.points.first.lat, p.points.first.lng),
                  icon: BitmapDescriptor.defaultMarkerWithHue(
                    BitmapDescriptor.hueGreen,
                  ),
                  infoWindow: InfoWindow(
                    title: l.t('ride_tracker_start_point'),
                  ),
                ),
              }
            : {},
        myLocationEnabled: true,
        myLocationButtonEnabled: false,
        zoomControlsEnabled: false,
        compassEnabled: false,
        mapToolbarEnabled: false,
        padding: const EdgeInsets.only(bottom: 300),
      );
    }

    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            ColorTokens.primary30.withValues(alpha: 0.05),
            const Color(0xFFF5F5F5),
          ],
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AnimatedBuilder(
            animation: _pulseController,
            builder: (context, child) {
              return Transform.scale(
                scale: 1.0 + (_pulseController.value * 0.08),
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: ColorTokens.primary30.withValues(alpha: 0.08),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.directions_bike_rounded,
                    size: 60,
                    color: ColorTokens.primary30.withValues(alpha: 0.4),
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 24),
          Text(
            p.isTracking
                ? l.t('ride_tracker_getting_gps_signal')
                : l.t('ride_tracker_ready_to_ride'),
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: Colors.grey[800],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            p.isTracking
                ? l.t('ride_tracker_waiting_for_location')
                : l.t('ride_tracker_press_start_to_record'),
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, color: Colors.grey[500]),
          ),
          const SizedBox(height: 120),
        ],
      ),
    );
  }

  // ─── BARRA SUPERIOR ──────────────────────────────────────
  Widget _buildTopBar(RideTrackerProvider p, LocaleNotifier l) {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: EdgeInsets.only(
          top: MediaQuery.of(context).padding.top + 8,
          left: 8,
          right: 8,
          bottom: 12,
        ),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.black.withValues(alpha: p.points.isNotEmpty ? 0.3 : 0.0),
              Colors.transparent,
            ],
          ),
        ),
        child: Row(
          children: [
            _buildCircleButton(
              icon: Icons.arrow_back_rounded,
              onTap: () {
                if (p.isTracking) {
                  _showExitConfirmation(p, l);
                } else {
                  Navigator.of(context).pop();
                }
              },
            ),
            const Spacer(),
            if (p.isTracking)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 7,
                ),
                decoration: BoxDecoration(
                  color: p.isPaused
                      ? Colors.orange.withValues(alpha: 0.9)
                      : Colors.green.withValues(alpha: 0.9),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.15),
                      blurRadius: 8,
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.white.withValues(alpha: 0.5),
                            blurRadius: 4,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      p.isPaused
                          ? l.t('ride_tracker_paused_status')
                          : l.t('ride_tracker_recording_status'),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1,
                      ),
                    ),
                  ],
                ),
              ),
            const Spacer(),
            if (p.points.isNotEmpty)
              _buildCircleButton(
                icon: Icons.my_location_rounded,
                onTap: () {
                  if (p.points.isNotEmpty && _mapController != null) {
                    _mapController!.animateCamera(
                      CameraUpdate.newCameraPosition(
                        CameraPosition(
                          target: LatLng(p.points.last.lat, p.points.last.lng),
                          zoom: 16.5,
                        ),
                      ),
                    );
                  }
                },
              )
            else if (!p.isTracking)
              _buildCircleButton(
                icon: Icons.history_rounded,
                onTap: () => setState(() => _showHistory = true),
              )
            else
              const SizedBox(width: 44),
          ],
        ),
      ),
    );
  }

  Widget _buildCircleButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.95),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 8,
            ),
          ],
        ),
        child: Icon(icon, size: 22, color: Colors.grey[800]),
      ),
    );
  }

  // ─── PANEL INFERIOR ──────────────────────────────────────
  Widget _buildBottomPanel(RideTrackerProvider p, LocaleNotifier l) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 14),
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              // Timer principal
              Text(
                p.durationFormatted,
                style: TextStyle(
                  fontSize: 44,
                  fontWeight: FontWeight.w800,
                  color: Colors.grey[800],
                  letterSpacing: 2,
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
              Text(
                l.t('ride_tracker_time'),
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[400],
                  letterSpacing: 1.5,
                ),
              ),
              const SizedBox(height: 16),

              // Stats grid
              Row(
                children: [
                  _buildStatItem(
                    icon: Icons.straighten_rounded,
                    value: p.totalKm.toStringAsFixed(2),
                    unit: 'km',
                    label: l.t('ride_tracker_distance'),
                    color: ColorTokens.primary30,
                  ),
                  _buildDivider(),
                  _buildStatItem(
                    icon: Icons.speed_rounded,
                    value: p.currentSpeed.toStringAsFixed(1),
                    unit: 'km/h',
                    label: l.t('ride_tracker_speed'),
                    color: const Color(0xFFFF9800),
                  ),
                  _buildDivider(),
                  _buildStatItem(
                    icon: Icons.local_fire_department_rounded,
                    value: '${p.calories}',
                    unit: 'kcal',
                    label: l.t('ride_tracker_calories'),
                    color: const Color(0xFFFF5722),
                  ),
                ],
              ),

              // Stats secundarias
              if (p.isTracking) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(
                    vertical: 8,
                    horizontal: 12,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildMiniStat(
                        l.t('ride_tracker_max'),
                        '${p.maxSpeed.toStringAsFixed(1)} km/h',
                      ),
                      Container(width: 1, height: 20, color: Colors.grey[200]),
                      _buildMiniStat(
                        l.t('ride_tracker_avg'),
                        '${p.avgSpeed.toStringAsFixed(1)} km/h',
                      ),
                      Container(width: 1, height: 20, color: Colors.grey[200]),
                      _buildMiniStat('GPS', '${p.points.length} pts'),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: 16),

              // Botones
              _buildActionButtons(p, l),

              // Link al historial (solo si no está grabando)
              if (!p.isTracking && p.history.isNotEmpty) ...[
                const SizedBox(height: 12),
                GestureDetector(
                  onTap: () => setState(() => _showHistory = true),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.history_rounded,
                          size: 18,
                          color: ColorTokens.primary30,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          '${l.t('ride_tracker_view_history')} (${p.history.length} ${l.t('ride_tracker_rides')})',
                          style: TextStyle(
                            fontSize: 13,
                            color: ColorTokens.primary30,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Icon(
                          Icons.arrow_forward_ios_rounded,
                          size: 12,
                          color: ColorTokens.primary30,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String value,
    required String unit,
    required String label,
    required Color color,
  }) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(height: 4),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                children: [
                  TextSpan(
                    text: value,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: Colors.grey[800],
                      fontFeatures: const [FontFeature.tabularFigures()],
                    ),
                  ),
                  const TextSpan(text: ' '),
                  TextSpan(
                    text: unit,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey[400],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              color: Colors.grey[500],
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() =>
      Container(width: 1, height: 36, color: Colors.grey[200]);

  Widget _buildMiniStat(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: Colors.grey[700],
            fontFeatures: const [FontFeature.tabularFigures()],
          ),
        ),
        Text(label, style: TextStyle(fontSize: 10, color: Colors.grey[400])),
      ],
    );
  }

  // ─── BOTONES ─────────────────────────────────────────────
  Widget _buildActionButtons(RideTrackerProvider p, LocaleNotifier l) {
    if (!p.isTracking) {
      return SizedBox(
        width: double.infinity,
        height: 56,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF4CAF50),
            foregroundColor: Colors.white,
            elevation: 3,
            shadowColor: const Color(0xFF4CAF50).withValues(alpha: 0.4),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          onPressed: () async {
            HapticFeedback.mediumImpact();
            final error = await p.startTracking();
            if (error != null && mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Row(
                    children: [
                      const Icon(
                        Icons.location_off_rounded,
                        color: Colors.white,
                        size: 20,
                      ),
                      const SizedBox(width: 10),
                      Expanded(child: Text(error)),
                    ],
                  ),
                  backgroundColor: Colors.red,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  duration: const Duration(seconds: 4),
                ),
              );
            }
          },
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.play_arrow_rounded, size: 28),
              const SizedBox(width: 8),
              Text(
                l.t('ride_tracker_start_ride'),
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Row(
      children: [
        Expanded(
          child: SizedBox(
            height: 52,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: p.isPaused
                    ? const Color(0xFF4CAF50)
                    : const Color(0xFFFF9800),
                foregroundColor: Colors.white,
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              onPressed: () {
                HapticFeedback.lightImpact();
                p.isPaused ? p.resumeTracking() : p.pauseTracking();
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    p.isPaused ? Icons.play_arrow_rounded : Icons.pause_rounded,
                    size: 22,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    p.isPaused
                        ? l.t('ride_tracker_resume')
                        : l.t('ride_tracker_pause'),
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: SizedBox(
            height: 52,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFF44336),
                foregroundColor: Colors.white,
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              onPressed: () => _showFinishConfirmation(p, l),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.stop_rounded, size: 22),
                  const SizedBox(width: 6),
                  Text(
                    l.t('ride_tracker_finish'),
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ─── HISTORIAL ───────────────────────────────────────────
  Widget _buildHistoryView(RideTrackerProvider p, LocaleNotifier l) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: ColorTokens.primary30,
        foregroundColor: Colors.white,
        title: Text(
          l.t('ride_tracker_my_rides'),
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => setState(() => _showHistory = false),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            tooltip: l.t('ride_tracker_refresh'),
            onPressed: () {
              final uid = FirebaseAuth.instance.currentUser?.uid;
              if (uid != null) {
                p.loadHistory(uid);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Row(
                      children: [
                        const Icon(
                          Icons.check_circle,
                          color: Colors.white,
                          size: 18,
                        ),
                        const SizedBox(width: 8),
                        Text(l.t('ride_tracker_history_updated')),
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
            },
          ),
        ],
      ),
      body: p.isLoading
          ? const Center(child: CircularProgressIndicator())
          : p.history.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.directions_bike_rounded,
                    size: 64,
                    color: Colors.grey[300],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    l.t('ride_tracker_no_rides_yet'),
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    l.t('ride_tracker_rides_will_appear_here'),
                    style: TextStyle(fontSize: 14, color: Colors.grey[400]),
                  ),
                ],
              ),
            )
          : RefreshIndicator(
              onRefresh: () async {
                final uid = FirebaseAuth.instance.currentUser?.uid;
                if (uid != null) await p.loadHistory(uid);
              },
              color: ColorTokens.primary30,
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: p.history.length + 1,
                itemBuilder: (context, index) {
                  if (index == 0) return _buildHistorySummary(p, l);
                  return _buildHistoryCard(p.history[index - 1], p, l);
                },
              ),
            ),
    );
  }

  Widget _buildHistorySummary(RideTrackerProvider p, LocaleNotifier l) {
    double totalKm = 0;
    int totalMin = 0;
    int totalCal = 0;
    for (final r in p.history) {
      totalKm += r.totalKm;
      totalMin += r.durationMinutes;
      totalCal += r.calories;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            ColorTokens.primary30,
            ColorTokens.primary30.withValues(alpha: 0.85),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Text(
            '${p.history.length} ${l.t('ride_tracker_rides_registered')}',
            style: const TextStyle(color: Colors.white70, fontSize: 13),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildSummaryChip(
                '📏',
                '${totalKm.toStringAsFixed(1)} km',
                l.t('ride_tracker_total'),
              ),
              _buildSummaryChip(
                '⏱️',
                '${(totalMin / 60).toStringAsFixed(1)} h',
                l.t('ride_tracker_time_label'),
              ),
              _buildSummaryChip(
                '🔥',
                '$totalCal',
                l.t('ride_tracker_calories'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryChip(String emoji, String value, String label) {
    return Column(
      children: [
        Text(emoji, style: const TextStyle(fontSize: 20)),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
        Text(
          label,
          style: const TextStyle(color: Colors.white60, fontSize: 11),
        ),
      ],
    );
  }

  Widget _buildHistoryCard(
    RideTrackEntity ride,
    RideTrackerProvider p,
    LocaleNotifier l,
  ) {
    final date = ride.startTime;
    final months = [
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
    final dateStr = '${date.day} ${months[date.month]} ${date.year}';
    final timeStr =
        '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';

    final durationStr = ride.durationFormatted;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: () => _showRideDetail(ride, l),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              children: [
                // Header: fecha + opciones
                Row(
                  children: [
                    Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: ColorTokens.primary30.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.directions_bike_rounded,
                        color: ColorTokens.primary30,
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            dateStr,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            '$timeStr · $durationStr',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[500],
                            ),
                          ),
                        ],
                      ),
                    ),
                    PopupMenuButton<String>(
                      icon: Icon(
                        Icons.more_vert_rounded,
                        color: Colors.grey[400],
                        size: 20,
                      ),
                      onSelected: (value) {
                        if (value == 'delete') _confirmDeleteRide(ride, p, l);
                      },
                      itemBuilder: (_) => [
                        PopupMenuItem(
                          value: 'delete',
                          child: Row(
                            children: [
                              const Icon(
                                Icons.delete_outline,
                                color: Colors.red,
                                size: 18,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                l.t('ride_tracker_delete'),
                                style: const TextStyle(color: Colors.red),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                // Stats
                Row(
                  children: [
                    _buildHistoryStat(
                      Icons.straighten_rounded,
                      '${ride.totalKm.toStringAsFixed(1)} km',
                      ColorTokens.primary30,
                    ),
                    _buildHistoryStat(
                      Icons.speed_rounded,
                      '${ride.avgSpeed.toStringAsFixed(1)} km/h',
                      const Color(0xFFFF9800),
                    ),
                    _buildHistoryStat(
                      Icons.rocket_launch_rounded,
                      '${ride.maxSpeed.toStringAsFixed(1)} km/h',
                      const Color(0xFFF44336),
                    ),
                    _buildHistoryStat(
                      Icons.local_fire_department_rounded,
                      '${ride.calories} kcal',
                      const Color(0xFFFF5722),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHistoryStat(IconData icon, String value, Color color) {
    return Expanded(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Flexible(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: Colors.grey[700],
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  void _showRideDetail(RideTrackEntity ride, LocaleNotifier l) {
    final date = ride.startTime;
    final months = [
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

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.7,
        ),
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const Icon(
              Icons.directions_bike_rounded,
              size: 40,
              color: ColorTokens.primary30,
            ),
            const SizedBox(height: 8),
            Text(
              '${date.day} ${months[date.month]} ${date.year}',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            Text(
              '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')} - ${ride.endTime.hour.toString().padLeft(2, '0')}:${ride.endTime.minute.toString().padLeft(2, '0')}',
              style: TextStyle(fontSize: 14, color: Colors.grey[500]),
            ),
            const SizedBox(height: 20),
            // Detalles en grid
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(14),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      _buildDetailItem(
                        '📏',
                        l.t('ride_tracker_distance'),
                        '${ride.totalKm.toStringAsFixed(2)} km',
                      ),
                      _buildDetailItem(
                        '⏱️',
                        l.t('ride_tracker_duration'),
                        ride.durationFormatted,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      _buildDetailItem(
                        '⚡',
                        l.t('ride_tracker_avg_speed'),
                        '${ride.avgSpeed.toStringAsFixed(1)} km/h',
                      ),
                      _buildDetailItem(
                        '🚀',
                        l.t('ride_tracker_max_speed'),
                        '${ride.maxSpeed.toStringAsFixed(1)} km/h',
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      _buildDetailItem(
                        '🔥',
                        l.t('ride_tracker_calories'),
                        '${ride.calories} kcal',
                      ),
                      _buildDetailItem(
                        '📍',
                        l.t('ride_tracker_gps_points'),
                        '${ride.pointCount}',
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: ColorTokens.primary30,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () => Navigator.pop(ctx),
                child: Text(
                  l.t('ride_tracker_close'),
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailItem(String emoji, String label, String value) {
    return Expanded(
      child: Column(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 22)),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
          ),
          Text(label, style: TextStyle(fontSize: 11, color: Colors.grey[500])),
        ],
      ),
    );
  }

  void _confirmDeleteRide(
    RideTrackEntity ride,
    RideTrackerProvider p,
    LocaleNotifier l,
  ) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            const Icon(Icons.delete_outline, color: Colors.red, size: 22),
            const SizedBox(width: 8),
            Text(
              l.t('ride_tracker_delete_ride'),
              style: const TextStyle(fontSize: 17),
            ),
          ],
        ),
        content: Text(
          '${l.t('ride_tracker_delete_ride_confirm')} ${ride.totalKm.toStringAsFixed(1)} km ${l.t('ride_tracker_of_date')} ${ride.startTime.day}/${ride.startTime.month}/${ride.startTime.year}?',
          style: const TextStyle(fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              l.t('ride_tracker_cancel'),
              style: TextStyle(color: Colors.grey[600]),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onPressed: () {
              Navigator.pop(ctx);
              final uid = FirebaseAuth.instance.currentUser?.uid ?? '';
              p.deleteRide(ride.id, uid);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(l.t('ride_tracker_ride_deleted')),
                  backgroundColor: Colors.red,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              );
            },
            child: Text(l.t('ride_tracker_delete')),
          ),
        ],
      ),
    );
  }

  // ─── DIÁLOGOS DE GRABACIÓN ───────────────────────────────
  void _showFinishConfirmation(RideTrackerProvider p, LocaleNotifier l) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const Icon(
                Icons.flag_rounded,
                size: 44,
                color: Color(0xFFF44336),
              ),
              const SizedBox(height: 10),
              Text(
                l.t('ride_tracker_finish_ride_question'),
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                '${p.totalKm.toStringAsFixed(2)} km en ${p.durationFormatted}',
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildSummaryItem2(
                      '📏',
                      '${p.totalKm.toStringAsFixed(2)} km',
                    ),
                    _buildSummaryItem2('⏱️', p.durationFormatted),
                    _buildSummaryItem2(
                      '⚡',
                      '${p.avgSpeed.toStringAsFixed(1)} km/h',
                    ),
                    _buildSummaryItem2('🔥', '${p.calories} kcal'),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 48,
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.grey[700],
                          side: BorderSide(color: Colors.grey[300]!),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: () => Navigator.pop(ctx),
                        child: Text(
                          l.t('ride_tracker_continue'),
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: SizedBox(
                      height: 48,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF4CAF50),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: () async {
                          Navigator.pop(ctx);
                          await _finishRide(p, lParam: l);
                        },
                        child: Text(
                          l.t('ride_tracker_save'),
                          style: const TextStyle(fontWeight: FontWeight.w700),
                        ),
                      ),
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

  Widget _buildSummaryItem2(String emoji, String value) {
    return Column(
      children: [
        Text(emoji, style: const TextStyle(fontSize: 18)),
        const SizedBox(height: 3),
        Text(
          value,
          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700),
        ),
      ],
    );
  }

  Future<void> _finishRide(
    RideTrackerProvider p, {
    LocaleNotifier? lParam,
  }) async {
    final l = lParam ?? Provider.of<LocaleNotifier>(context, listen: false);
    final uid = FirebaseAuth.instance.currentUser?.uid ?? '';
    if (uid.isEmpty) return;

    final success = await p.stopAndSave(uid);

    if (mounted) {
      HapticFeedback.heavyImpact();
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(
                  Icons.check_circle_rounded,
                  color: Colors.white,
                  size: 20,
                ),
                const SizedBox(width: 10),
                Text(
                  l.t('ride_tracker_ride_saved'),
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ],
            ),
            backgroundColor: const Color(0xFF4CAF50),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            duration: const Duration(seconds: 2),
            action: SnackBarAction(
              label: l.t('ride_tracker_view_history'),
              textColor: Colors.white,
              onPressed: () => setState(() => _showHistory = true),
            ),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(
                  Icons.warning_rounded,
                  color: Colors.white,
                  size: 20,
                ),
                const SizedBox(width: 10),
                Text(l.t('ride_tracker_ride_too_short')),
              ],
            ),
            backgroundColor: Colors.orange,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }
    }
  }

  void _showExitConfirmation(RideTrackerProvider p, LocaleNotifier l) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            const Icon(
              Icons.warning_amber_rounded,
              color: Colors.orange,
              size: 22,
            ),
            const SizedBox(width: 8),
            Text(
              l.t('ride_tracker_exit_question'),
              style: const TextStyle(fontSize: 17),
            ),
          ],
        ),
        content: Text(
          l.t('ride_tracker_exit_warning'),
          style: const TextStyle(fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              l.t('ride_tracker_cancel'),
              style: TextStyle(color: Colors.grey[600]),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              p.cancelTracking();
              Navigator.of(context).pop();
            },
            child: Text(
              l.t('ride_tracker_discard'),
              style: const TextStyle(
                color: Colors.red,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: ColorTokens.primary30,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onPressed: () async {
              Navigator.pop(ctx);
              await _finishRide(p, lParam: l);
              if (mounted) Navigator.of(context).pop();
            },
            child: Text(l.t('ride_tracker_save_and_exit')),
          ),
        ],
      ),
    );
  }
}
