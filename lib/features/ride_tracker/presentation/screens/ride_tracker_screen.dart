import 'dart:async';
import 'dart:math' show sin, cos, sqrt, atan2, pi;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:biux/core/design_system/color_tokens.dart';
import 'package:biux/features/ride_tracker/presentation/providers/ride_tracker_provider.dart';
import 'package:biux/features/ride_tracker/domain/entities/ride_track_entity.dart';
import 'package:biux/features/road_reports/presentation/providers/road_reports_provider.dart';
import 'package:biux/features/road_reports/domain/entities/road_report_entity.dart';

class RideTrackerScreen extends StatefulWidget {
  final bool showHistory;
  const RideTrackerScreen({Key? key, this.showHistory = false})
    : super(key: key);

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
    _showHistory = widget.showHistory;
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
      context.read<RoadReportsProvider>().loadReports();
    });
  }

  @override
  void dispose() {
    _pulseController.dispose();
    try {
      _mapController?.dispose();
    } catch (_) {}
    _mapController = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: isDark ? ColorTokens.primary10 : const Color(0xFFF5F5F5),
      body: Consumer<RideTrackerProvider>(
        builder: (ctx, p, _) {
          if (p.points.isNotEmpty && _mapController != null) {
            try {
              final last = p.points.last;
              _mapController!.animateCamera(
                CameraUpdate.newLatLng(LatLng(last.lat, last.lng)),
              );
            } catch (_) {
              _mapController = null;
            }
          } else if (p.points.isEmpty) {
            _mapController = null;
          }

          // Si está mostrando historial
          if (_showHistory && !p.isTracking) {
            return _buildHistoryView(p);
          }

          return Stack(
            children: [
              _buildMapArea(p),
              _buildTopBar(p),
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: _buildBottomPanel(p),
              ),
            ],
          );
        },
      ),
    );
  }

  // ─── MAPA ────────────────────────────────────────────────
  Widget _buildMapArea(RideTrackerProvider p) {
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
                  infoWindow: const InfoWindow(title: 'Inicio'),
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

    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            ColorTokens.primary30.withValues(alpha: 0.05),
            Theme.of(context).brightness == Brightness.dark
                ? ColorTokens.primary10
                : const Color(0xFFF5F5F5),
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
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.7)
                        : ColorTokens.primary30.withValues(alpha: 0.4),
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 24),
          Text(
            p.isTracking ? 'Obteniendo señal GPS...' : '¿Listo para pedalear?',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: isDark ? Colors.white : Colors.grey[800],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            p.isTracking
                ? 'Espera mientras encontramos tu ubicación'
                : 'Presiona iniciar para grabar tu rodada',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: isDark ? Colors.white70 : Colors.grey[500],
            ),
          ),
          const SizedBox(height: 120),
        ],
      ),
    );
  }

  // ─── BARRA SUPERIOR ──────────────────────────────────────
  Widget _buildTopBar(RideTrackerProvider p) {
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
                  _showExitConfirmation(p);
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
                      p.isPaused ? 'EN PAUSA' : 'GRABANDO',
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
                    try {
                      _mapController!.animateCamera(
                        CameraUpdate.newCameraPosition(
                          CameraPosition(
                            target: LatLng(
                              p.points.last.lat,
                              p.points.last.lng,
                            ),
                            zoom: 16.5,
                          ),
                        ),
                      );
                    } catch (_) {
                      _mapController = null;
                    }
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
          color: Theme.of(context).brightness == Brightness.dark
              ? ColorTokens.primary30
              : Colors.white.withValues(alpha: 0.95),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 8,
            ),
          ],
        ),
        child: Icon(icon, size: 22, color: Colors.white),
      ),
    );
  }

  // ─── PANEL INFERIOR ──────────────────────────────────────
  Widget _buildBottomPanel(RideTrackerProvider p) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      decoration: BoxDecoration(
        color: isDark ? ColorTokens.primary20 : Colors.white,
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
          child: SingleChildScrollView(
            physics: const ClampingScrollPhysics(),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Handle
                Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 14),
                  decoration: BoxDecoration(
                    color: isDark ? Colors.white24 : Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),

                // Timer principal
                Text(
                  p.durationFormatted,
                  style: TextStyle(
                    fontSize: 44,
                    fontWeight: FontWeight.w800,
                    color: isDark ? ColorTokens.neutral100 : Colors.grey[800],
                    letterSpacing: 2,
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                ),
                Text(
                  'TIEMPO',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: isDark ? ColorTokens.neutral80 : Colors.grey[400],
                    letterSpacing: 1.5,
                  ),
                ),
                const SizedBox(height: 10),

                // Indicador de detección de movimiento en bicicleta
                if (p.isTracking && !p.isPaused)
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 400),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: p.isMoving
                          ? const Color(0xFF1B5E20).withValues(alpha: 0.1)
                          : Colors.orange.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: p.isMoving
                            ? const Color(0xFF4CAF50).withValues(alpha: 0.5)
                            : Colors.orange.withValues(alpha: 0.5),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          p.isMoving
                              ? Icons.directions_bike_rounded
                              : Icons.pause_circle_outline_rounded,
                          size: 15,
                          color: p.isMoving
                              ? const Color(0xFF388E3C)
                              : Colors.orange[700],
                        ),
                        const SizedBox(width: 6),
                        Text(
                          p.isMoving
                              ? 'En movimiento'
                              : 'Detenido — esperando...',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: p.isMoving
                                ? const Color(0xFF388E3C)
                                : Colors.orange[700],
                          ),
                        ),
                      ],
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
                      label: 'Distancia',
                      color: isDark ? Colors.white : ColorTokens.primary30,
                    ),
                    _buildDivider(),
                    _buildStatItem(
                      icon: Icons.speed_rounded,
                      value: p.currentSpeed.toStringAsFixed(1),
                      unit: 'km/h',
                      label: 'Velocidad',
                      color: const Color(0xFFFF9800),
                    ),
                    _buildDivider(),
                    _buildStatItem(
                      icon: Icons.local_fire_department_rounded,
                      value: '${p.calories}',
                      unit: 'kcal',
                      label: 'Calorías',
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
                      color: Theme.of(context).colorScheme.surface,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildMiniStat(
                          'Máx',
                          '${p.maxSpeed.toStringAsFixed(1)} km/h',
                        ),
                        Container(
                          width: 1,
                          height: 20,
                          color: Colors.grey[200],
                        ),
                        _buildMiniStat(
                          'Prom',
                          '${p.avgSpeed.toStringAsFixed(1)} km/h',
                        ),
                        Container(
                          width: 1,
                          height: 20,
                          color: Colors.grey[200],
                        ),
                        _buildMiniStat('GPS', '${p.points.length} pts'),
                      ],
                    ),
                  ),
                ],

                const SizedBox(height: 16),

                // Alertas viales cercanas
                _buildRoadAlertsSection(p),

                const SizedBox(height: 16),

                // Botones
                _buildActionButtons(p),
              ],
            ),
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
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
                      color: isDark ? ColorTokens.neutral100 : Colors.grey[800],
                      fontFeatures: const [FontFeature.tabularFigures()],
                    ),
                  ),
                  const TextSpan(text: ' '),
                  TextSpan(
                    text: unit,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: isDark ? ColorTokens.neutral80 : Colors.grey[400],
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
              color: isDark ? ColorTokens.neutral90 : Colors.grey[500],
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: isDark ? ColorTokens.neutral80 : Colors.grey[700],
            fontFeatures: const [FontFeature.tabularFigures()],
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            color: isDark ? ColorTokens.neutral80 : Colors.grey[400],
          ),
        ),
      ],
    );
  }

  // ─── BOTONES ─────────────────────────────────────────────
  Widget _buildActionButtons(RideTrackerProvider p) {
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
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.play_arrow_rounded, size: 28),
              SizedBox(width: 8),
              Text(
                'INICIAR RODADA',
                style: TextStyle(
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
                    p.isPaused ? 'Reanudar' : 'Pausar',
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
              onPressed: () => _showFinishConfirmation(p),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.stop_rounded, size: 22),
                  SizedBox(width: 6),
                  Text(
                    'Finalizar',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
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
  Widget _buildHistoryView(RideTrackerProvider p) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: isDark ? ColorTokens.primary10 : const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: ColorTokens.primary30,
        foregroundColor: Colors.white,
        title: const Text(
          'Mis Rodadas',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () {
            if (widget.showHistory) {
              Navigator.of(context).pop();
            } else {
              setState(() => _showHistory = false);
            }
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Actualizar',
            onPressed: () {
              final uid = FirebaseAuth.instance.currentUser?.uid;
              if (uid != null) {
                p.loadHistory(uid);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Row(
                      children: [
                        Icon(Icons.check_circle, color: Colors.white, size: 18),
                        SizedBox(width: 8),
                        Text('Historial actualizado'),
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
                    'Sin rodadas aún',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Tus rodadas grabadas aparecerán aquí',
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
                  if (index == 0) return _buildHistorySummary(p);
                  return _buildHistoryCard(p.history[index - 1], p);
                },
              ),
            ),
    );
  }

  Widget _buildHistorySummary(RideTrackerProvider p) {
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
            '${p.history.length} rodadas registradas',
            style: const TextStyle(color: Colors.white70, fontSize: 13),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildSummaryChip(
                '📏',
                '${totalKm.toStringAsFixed(1)} km',
                'Total',
              ),
              _buildSummaryChip(
                '⏱️',
                '${(totalMin / 60).toStringAsFixed(1)} h',
                'Tiempo',
              ),
              _buildSummaryChip('🔥', '$totalCal', 'Calorías'),
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

  Widget _buildHistoryCard(RideTrackEntity ride, RideTrackerProvider p) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final date = ride.startTime;
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
    final dateStr = '${date.day} ${months[date.month]} ${date.year}';
    final timeStr =
        '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';

    final durationStr = ride.durationFormatted;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: isDark ? ColorTokens.primary20 : Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.15 : 0.04),
            blurRadius: 8,
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: () => _showRideDetail(ride),
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
                        color: ColorTokens.primary30.withValues(
                          alpha: isDark ? 0.25 : 0.08,
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.directions_bike_rounded,
                        color: Colors.white,
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            ride.name.isNotEmpty ? ride.name : dateStr,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            ride.name.isNotEmpty
                                ? '$dateStr · $timeStr · $durationStr'
                                : '$timeStr · $durationStr',
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
                        color: isDark ? Colors.white70 : Colors.grey[400],
                        size: 20,
                      ),
                      onSelected: (value) {
                        if (value == 'rename') _showRenameDialog(ride, p);
                        if (value == 'delete') _confirmDeleteRide(ride, p);
                      },
                      itemBuilder: (_) => [
                        PopupMenuItem(
                          value: 'rename',
                          child: Row(
                            children: [
                              Icon(
                                Icons.edit_rounded,
                                color: ColorTokens.primary30,
                                size: 18,
                              ),
                              const SizedBox(width: 8),
                              const Text('Editar nombre'),
                            ],
                          ),
                        ),
                        const PopupMenuItem(
                          value: 'delete',
                          child: Row(
                            children: [
                              Icon(
                                Icons.delete_outline,
                                color: Colors.red,
                                size: 18,
                              ),
                              SizedBox(width: 8),
                              Text(
                                'Eliminar',
                                style: TextStyle(color: Colors.red),
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
                      isDark ? Colors.white : ColorTokens.primary30,
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
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
                color: isDark ? ColorTokens.neutral80 : Colors.grey[700],
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  void _showRideDetail(RideTrackEntity ride) {
    final date = ride.startTime;
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
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.7,
        ),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Theme.of(context).brightness == Brightness.dark
              ? ColorTokens.primary20
              : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: SingleChildScrollView(
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
                ride.name.isNotEmpty
                    ? ride.name
                    : '${date.day} ${months[date.month]} ${date.year}',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              if (ride.name.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 2),
                  child: Text(
                    '${date.day} ${months[date.month]} ${date.year}',
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                  ),
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
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        _buildDetailItem(
                          '📏',
                          'Distancia',
                          '${ride.totalKm.toStringAsFixed(2)} km',
                        ),
                        _buildDetailItem(
                          '⏱️',
                          'Duración',
                          ride.durationFormatted,
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        _buildDetailItem(
                          '⚡',
                          'Vel. Promedio',
                          '${ride.avgSpeed.toStringAsFixed(1)} km/h',
                        ),
                        _buildDetailItem(
                          '🚀',
                          'Vel. Máxima',
                          '${ride.maxSpeed.toStringAsFixed(1)} km/h',
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        _buildDetailItem(
                          '🔥',
                          'Calorías',
                          '${ride.calories} kcal',
                        ),
                        _buildDetailItem(
                          '📍',
                          'Puntos GPS',
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
                  child: const Text(
                    'Cerrar',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ],
          ),
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

  void _showRenameDialog(RideTrackEntity ride, RideTrackerProvider p) {
    final ctrl = TextEditingController(text: ride.name);
    ctrl.selection = TextSelection(
      baseOffset: 0,
      extentOffset: ctrl.text.length,
    );

    final isDark = Theme.of(context).brightness == Brightness.dark;
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: isDark ? ColorTokens.primary20 : null,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        insetPadding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.edit_rounded,
                color: ColorTokens.primary30,
                size: 34,
              ),
              const SizedBox(height: 10),
              Text(
                'Editar nombre',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 14),
              TextField(
                controller: ctrl,
                autofocus: true,
                maxLength: 40,
                textCapitalization: TextCapitalization.sentences,
                style: TextStyle(color: isDark ? Colors.white : Colors.black87),
                decoration: InputDecoration(
                  hintText: 'Ej: Ruta del domingo',
                  hintStyle: TextStyle(
                    color: isDark ? Colors.white38 : Colors.grey[400],
                  ),
                  counterText: '',
                  filled: true,
                  fillColor: isDark ? ColorTokens.primary30 : Colors.grey[100],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 12,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: isDark
                        ? ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: ColorTokens.primary30,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            onPressed: () => Navigator.pop(ctx),
                            child: const Text('Cancelar'),
                          )
                        : TextButton(
                            style: TextButton.styleFrom(
                              foregroundColor: Colors.grey[700],
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            onPressed: () => Navigator.pop(ctx),
                            child: const Text('Cancelar'),
                          ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: ColorTokens.primary30,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () async {
                        final name = ctrl.text.trim().isEmpty
                            ? ride.name
                            : ctrl.text.trim();
                        Navigator.pop(ctx);
                        await p.renameRide(ride.id, name);
                      },
                      child: const Text(
                        'Guardar',
                        style: TextStyle(fontWeight: FontWeight.w700),
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

  void _confirmDeleteRide(RideTrackEntity ride, RideTrackerProvider p) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.delete_outline, color: Colors.red, size: 22),
            SizedBox(width: 8),
            Text('Eliminar rodada', style: TextStyle(fontSize: 17)),
          ],
        ),
        content: Text(
          '¿Eliminar la rodada de ${ride.totalKm.toStringAsFixed(1)} km del ${ride.startTime.day}/${ride.startTime.month}/${ride.startTime.year}?',
          style: const TextStyle(fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Cancelar'),
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
                  content: const Text('Rodada eliminada'),
                  backgroundColor: Colors.red,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              );
            },
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }

  // ─── DIÁLOGOS DE GRABACIÓN ───────────────────────────────

  void _showTooShortDialog(RideTrackerProvider p) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => Dialog(
        backgroundColor: isDark ? ColorTokens.primary20 : null,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        insetPadding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.timer_off_rounded,
                color: Colors.orange,
                size: 44,
              ),
              const SizedBox(height: 12),
              const Text(
                'Rodada muy corta',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                'La rodada debe durar al menos 30 segundos para poder guardarla. Llevas ${p.durationSec} segundos.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: isDark ? Colors.white70 : Colors.grey[600],
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 44,
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.red,
                          side: const BorderSide(color: Colors.red),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: () {
                          Navigator.pop(ctx);
                          p.cancelTracking();
                        },
                        child: const Text(
                          'Cancelar',
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: SizedBox(
                      height: 44,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: ColorTokens.primary30,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: () {
                          Navigator.pop(ctx);
                          p.resumeTracking();
                        },
                        child: const Text(
                          'Reanudar',
                          style: TextStyle(fontWeight: FontWeight.w700),
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

  void _showFinishConfirmation(RideTrackerProvider p) {
    // Pausar inmediatamente al tocar "Finalizar"
    p.pauseTracking();

    // Si la rodada es muy corta, no permitir guardar
    if (p.durationSec < 30) {
      _showTooShortDialog(p);
      return;
    }

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Theme.of(context).brightness == Brightness.dark
              ? ColorTokens.primary20
              : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
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
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Colors.white24
                      : Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const Icon(
                Icons.flag_rounded,
                size: 44,
                color: Color(0xFFF44336),
              ),
              const SizedBox(height: 10),
              const Text(
                '¿Finalizar rodada?',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
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
                  color: Theme.of(context).colorScheme.surface,
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
                        child: const Text(
                          'Continuar',
                          style: TextStyle(fontWeight: FontWeight.w600),
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
                        onPressed: () {
                          Navigator.pop(ctx);
                          _showNameDialog(p);
                        },
                        child: const Text(
                          'Guardar',
                          style: TextStyle(fontWeight: FontWeight.w700),
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

  /// Muestra el diálogo para que el usuario nombre su rodada antes de guardarla.
  void _showNameDialog(RideTrackerProvider p, {bool exitAfter = false}) {
    final now = DateTime.now();
    const months = [
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
    final ctrl = TextEditingController(
      text: 'Rodada ${now.day} ${months[now.month]}',
    );
    // Seleccionar todo el texto por defecto para fácil reemplazo
    ctrl.selection = TextSelection(
      baseOffset: 0,
      extentOffset: ctrl.text.length,
    );

    final isDark = Theme.of(context).brightness == Brightness.dark;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => Dialog(
        backgroundColor: isDark ? ColorTokens.primary20 : null,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        insetPadding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.edit_rounded,
                color: ColorTokens.primary30,
                size: 38,
              ),
              const SizedBox(height: 10),
              Text(
                '¿Cómo se llama esta rodada?',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 14),
              TextField(
                controller: ctrl,
                autofocus: true,
                maxLength: 40,
                textCapitalization: TextCapitalization.sentences,
                style: TextStyle(color: isDark ? Colors.white : Colors.black87),
                decoration: InputDecoration(
                  hintText: 'Ej: Ruta del domingo',
                  hintStyle: TextStyle(
                    color: isDark ? Colors.white38 : Colors.grey[400],
                  ),
                  counterText: '',
                  filled: true,
                  fillColor: isDark ? ColorTokens.primary30 : Colors.grey[100],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 12,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: isDark
                        ? ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: ColorTokens.primary30,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            onPressed: () => Navigator.pop(ctx),
                            child: const Text('Cancelar'),
                          )
                        : TextButton(
                            style: TextButton.styleFrom(
                              foregroundColor: Colors.grey[700],
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            onPressed: () => Navigator.pop(ctx),
                            child: const Text('Cancelar'),
                          ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: ColorTokens.primary30,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () async {
                        final name = ctrl.text.trim().isEmpty
                            ? 'Mi rodada'
                            : ctrl.text.trim();
                        Navigator.pop(ctx);
                        await _doSave(p, name, exitAfter);
                      },
                      child: const Text(
                        'Guardar',
                        style: TextStyle(fontWeight: FontWeight.w700),
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

  Future<void> _doSave(
    RideTrackerProvider p,
    String name,
    bool exitAfter,
  ) async {
    final uid = FirebaseAuth.instance.currentUser?.uid ?? '';
    if (uid.isEmpty) return;

    final success = await p.stopAndSave(uid, name);
    if (!mounted) return;
    HapticFeedback.heavyImpact();

    if (success) {
      // Llevar directamente a Mis Rodadas
      setState(() => _showHistory = true);
      if (exitAfter) Navigator.of(context).pop();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.warning_rounded, color: Colors.white, size: 20),
              SizedBox(width: 10),
              Text('Rodada muy corta, no se guardó'),
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

  void _showExitConfirmation(RideTrackerProvider p) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.orange, size: 22),
            SizedBox(width: 8),
            Text('¿Salir?', style: TextStyle(fontSize: 17)),
          ],
        ),
        content: const Text(
          'Tienes una rodada en curso. Si sales perderás los datos.',
          style: TextStyle(fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              p.cancelTracking();
              Navigator.of(context).pop();
            },
            child: const Text(
              'Descartar',
              style: TextStyle(fontWeight: FontWeight.w600),
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
            onPressed: () {
              Navigator.pop(ctx);
              _showNameDialog(p, exitAfter: true);
            },
            child: const Text('Guardar y Salir'),
          ),
        ],
      ),
    );
  }

  // ─── ALERTAS VIALES ──────────────────────────────────────
  Widget _buildRoadAlertsSection(RideTrackerProvider p) {
    return Consumer<RoadReportsProvider>(
      builder: (context, rrp, _) {
        if (rrp.isLoading) {
          return const SizedBox(
            height: 30,
            child: Center(
              child: SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
          );
        }

        final pos =
            p.points.isNotEmpty
                ? LatLng(p.points.last.lat, p.points.last.lng)
                : null;

        final active = rrp.reports.where((r) => r.isActive).toList();
        List<RoadReportEntity> nearby;
        if (pos != null) {
          nearby =
              active
                  .where(
                    (r) =>
                        _distKm(
                          pos.latitude,
                          pos.longitude,
                          r.latitude,
                          r.longitude,
                        ) <=
                        20.0,
                  )
                  .toList()
                ..sort(
                  (a, b) =>
                      _distKm(
                        pos.latitude,
                        pos.longitude,
                        a.latitude,
                        a.longitude,
                      ).compareTo(
                        _distKm(
                          pos.latitude,
                          pos.longitude,
                          b.latitude,
                          b.longitude,
                        ),
                      ),
                );
        } else {
          nearby = active;
        }

        if (nearby.isEmpty) return const SizedBox.shrink();

        final isDark = Theme.of(context).brightness == Brightness.dark;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.warning_amber_rounded,
                  size: 14,
                  color: Colors.orange,
                ),
                const SizedBox(width: 6),
                Text(
                  'Alertas viales${pos != null ? ' cercanas' : ''}',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: isDark ? Colors.white54 : Colors.grey[600],
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(width: 6),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.orange.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    '${nearby.length}',
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: Colors.orange,
                    ),
                  ),
                ),
                const Spacer(),
                GestureDetector(
                  onTap: () => rrp.loadReports(),
                  child: Icon(
                    Icons.refresh,
                    size: 14,
                    color: isDark ? Colors.white38 : Colors.grey[400],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 76,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: nearby.length > 5 ? 5 : nearby.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (context, i) {
                  final r = nearby[i];
                  final distStr = pos != null
                      ? _formatDist(
                          _distKm(
                            pos.latitude,
                            pos.longitude,
                            r.latitude,
                            r.longitude,
                          ),
                        )
                      : null;
                  return _buildAlertChip(r, distStr, isDark);
                },
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildAlertChip(RoadReportEntity r, String? dist, bool isDark) {
    final Color chipColor;
    switch (r.type) {
      case 'danger':
        chipColor = Colors.red;
        break;
      case 'construction':
        chipColor = Colors.orange;
        break;
      case 'flooding':
        chipColor = Colors.blue;
        break;
      case 'pothole':
        chipColor = Colors.brown;
        break;
      default:
        chipColor = Colors.orange;
    }

    return Container(
      width: 130,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: chipColor.withValues(alpha: isDark ? 0.12 : 0.07),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: chipColor.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            children: [
              Text(r.typeIcon, style: const TextStyle(fontSize: 14)),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  r.typeName,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: chipColor,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            r.description.isEmpty ? r.typeName : r.description,
            style: TextStyle(
              fontSize: 10,
              color: isDark ? Colors.white54 : Colors.grey[600],
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          if (dist != null) ...[
            const SizedBox(height: 3),
            Row(
              children: [
                Icon(
                  Icons.near_me,
                  size: 9,
                  color: isDark ? Colors.white38 : Colors.grey[400],
                ),
                const SizedBox(width: 3),
                Text(
                  dist,
                  style: TextStyle(
                    fontSize: 9,
                    color: isDark ? Colors.white38 : Colors.grey[400],
                  ),
                ),
                if (r.confirmations > 0) ...[
                  const SizedBox(width: 6),
                  Icon(
                    Icons.thumb_up_alt,
                    size: 9,
                    color: chipColor.withValues(alpha: 0.7),
                  ),
                  const SizedBox(width: 2),
                  Text(
                    '${r.confirmations}',
                    style: TextStyle(
                      fontSize: 9,
                      color: chipColor.withValues(alpha: 0.7),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ],
      ),
    );
  }

  double _distKm(double lat1, double lon1, double lat2, double lon2) {
    const r = 6371.0;
    final dLat = (lat2 - lat1) * pi / 180;
    final dLon = (lon2 - lon1) * pi / 180;
    final a =
        sin(dLat / 2) * sin(dLat / 2) +
        cos(lat1 * pi / 180) *
            cos(lat2 * pi / 180) *
            sin(dLon / 2) *
            sin(dLon / 2);
    return r * 2 * atan2(sqrt(a), sqrt(1 - a));
  }

  String _formatDist(double km) {
    if (km < 1) return '${(km * 1000).round()} m';
    return '${km.toStringAsFixed(1)} km';
  }
  Future<bool> _onWillPop(RideTrackerProvider provider) async {
    if (!provider.isTracking) return true;
    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('¿Salir de la rodada?'),
        content: const Text('Tienes una rodada activa. Si sales, se perderá el progreso.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Salir', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
    return result ?? false;
  }

}