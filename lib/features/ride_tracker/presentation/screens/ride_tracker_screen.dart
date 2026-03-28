import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:biux/core/design_system/color_tokens.dart';
import 'package:biux/features/ride_tracker/presentation/providers/ride_tracker_provider.dart';
import 'package:biux/features/ride_recommendations/presentation/widgets/send_recommendation_sheet.dart';
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
  bool _showDetails = false;

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
            return _buildHistoryView(p);
          }

          return Stack(
            children: [
              _buildMapArea(p),
              _buildTopBar(p),
              DraggableScrollableSheet(
                initialChildSize: p.isTracking ? 0.35 : 0.15,
                minChildSize: p.isTracking ? 0.35 : 0.15,
                maxChildSize: p.isTracking ? 0.52 : 0.15,
                snap: true,
                snapSizes: p.isTracking ? const [0.35, 0.52] : const [0.15],
                builder: (context, scrollController) {
                  return Container(
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                      boxShadow: [
                        BoxShadow(color: Color(0x14000000), blurRadius: 20, offset: Offset(0, -4)),
                      ],
                    ),
                    child: ListView(
                      controller: scrollController,
                      shrinkWrap: true,
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
                      children: [
                        // Handle solo al grabar
                        if (p.isTracking)
                          Center(
                            child: Container(
                              width: 36, height: 4,
                              margin: const EdgeInsets.only(top: 8, bottom: 4),
                              decoration: BoxDecoration(
                                color: Colors.grey[300],
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                          )
                        else
                          const SizedBox(height: 10),

                        // Sin grabar: solo boton iniciar
                        if (!p.isTracking) ...[
                          SizedBox(
                            width: double.infinity,
                            height: 52,
                            child: ElevatedButton.icon(
                              onPressed: () => p.startTracking(),
                              icon: const Icon(Icons.play_arrow_rounded, size: 24),
                              label: const Text('Iniciar Rodada',
                                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: ColorTokens.primary30,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                elevation: 0,
                              ),
                            ),
                          ),
                          if (p.history.isNotEmpty) ...[
                            const SizedBox(height: 8),
                            GestureDetector(
                              onTap: () => setState(() => _showHistory = true),
                              child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                                Icon(Icons.history_rounded, size: 16, color: Colors.grey[500]),
                                const SizedBox(width: 6),
                                Text('Ver historial (${p.history.length} rodadas)',
                                  style: TextStyle(fontSize: 13, color: Colors.grey[500],
                                    fontWeight: FontWeight.w500)),
                              ]),
                            ),
                          ],
                        ],

                        // Grabando
                        if (p.isTracking) ...[
                          Center(child: Text(p.durationFormatted,
                            style: TextStyle(fontSize: 38, fontWeight: FontWeight.w900,
                              color: Colors.grey[800], letterSpacing: 2,
                              fontFeatures: const [FontFeature.tabularFigures()]))),
                          Center(child: Text('TIEMPO DE RODADA',
                            style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600,
                              color: Colors.grey[400], letterSpacing: 2))),
                          const SizedBox(height: 8),

                          // Stats principales
                          Container(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            decoration: BoxDecoration(
                              color: Colors.grey[50],
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Row(children: [
                              _buildStatItem(icon: Icons.straighten_rounded,
                                value: p.totalKm.toStringAsFixed(2), unit: 'km',
                                label: 'Distancia', color: ColorTokens.primary30),
                              _buildDivider(),
                              _buildStatItem(icon: Icons.speed_rounded,
                                value: p.currentSpeed.toStringAsFixed(1), unit: 'km/h',
                                label: 'Velocidad', color: const Color(0xFFFF9800)),
                              _buildDivider(),
                              _buildStatItem(icon: Icons.local_fire_department_rounded,
                                value: '${p.calories}', unit: 'kcal',
                                label: 'Calorías', color: const Color(0xFFFF5722)),
                            ]),
                          ),
                          const SizedBox(height: 8),

                          // Botones pausar / finalizar
                          Row(children: [
                            Expanded(
                              child: SizedBox(
                                height: 46,
                                child: OutlinedButton.icon(
                                  onPressed: () => p.isPaused ? p.resumeTracking() : p.pauseTracking(),
                                  icon: Icon(p.isPaused ? Icons.play_arrow_rounded : Icons.pause_rounded, size: 20),
                                  label: Text(p.isPaused ? 'Reanudar' : 'Pausar',
                                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: const Color(0xFFFF9800),
                                    side: const BorderSide(color: Color(0xFFFF9800), width: 1.5),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: SizedBox(
                                height: 46,
                                child: ElevatedButton.icon(
                                  onPressed: () => _showExitConfirmation(p),
                                  icon: const Icon(Icons.stop_rounded, size: 20),
                                  label: const Text('Finalizar',
                                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFFF44336),
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                                    elevation: 0,
                                  ),
                                ),
                              ),
                            ),
                          ]),
                          const SizedBox(height: 8),

                          // Separador mas detalles
                          GestureDetector(
                            onTap: () => setState(() => _showDetails = !_showDetails),
                            child: Row(children: [
                              Expanded(child: Divider(color: Colors.grey[200])),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 8),
                                child: Row(mainAxisSize: MainAxisSize.min, children: [
                                  Icon(
                                    _showDetails
                                      ? Icons.keyboard_arrow_down_rounded
                                      : Icons.keyboard_arrow_up_rounded,
                                    size: 14, color: Colors.grey[400]),
                                  Text(_showDetails ? ' ocultar' : ' más detalles',
                                    style: TextStyle(fontSize: 11, color: Colors.grey[400])),
                                ]),
                              ),
                              Expanded(child: Divider(color: Colors.grey[200])),
                            ]),
                          ),

                          // Stats secundarias
                          if (_showDetails) ...[
                            const SizedBox(height: 8),
                            Row(children: [
                              Expanded(child: _buildDetailCard(
                                icon: Icons.rocket_launch_rounded,
                                label: 'Vel. Máxima',
                                value: '${p.maxSpeed.toStringAsFixed(1)} km/h',
                                color: const Color(0xFFF44336),
                              )),
                              const SizedBox(width: 10),
                              Expanded(child: _buildDetailCard(
                                icon: Icons.analytics_rounded,
                                label: 'Vel. Promedio',
                                value: '${p.avgSpeed.toStringAsFixed(1)} km/h',
                                color: const Color(0xFFFF9800),
                              )),
                            ]),
                            const SizedBox(height: 6),
                            Row(children: [
                              Expanded(child: _buildDetailCard(
                                icon: Icons.my_location_rounded,
                                label: 'Puntos GPS',
                                value: '${p.points.length}',
                                color: ColorTokens.primary30,
                              )),
                              const SizedBox(width: 10),
                              Expanded(child: _buildDetailCard(
                                icon: Icons.timer_outlined,
                                label: 'Tiempo activo',
                                value: p.durationFormatted,
                                color: Colors.purple,
                              )),
                            ]),
                          ],
                        ],
                      ],
                    ),
                  );
                },
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
            p.isTracking ? 'Obteniendo señal GPS...' : '¿Listo para pedalear?',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: Colors.grey[800],
            ),
          ),
          const SizedBox(height: 5),
          Text(
            p.isTracking
                ? 'Espera mientras encontramos tu ubicación'
                : 'Presiona iniciar para grabar tu rodada',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, color: Colors.grey[500]),
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
  Widget _buildBottomPanel(RideTrackerProvider p) {
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
                'TIEMPO',
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
                    label: 'Distancia',
                    color: ColorTokens.primary30,
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
                const SizedBox(height: 6),
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
                      Container(width: 1, height: 20, color: Colors.grey[200]),
                      _buildMiniStat(
                        'Prom',
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
              _buildActionButtons(p),

              // Link al historial (solo si no está grabando)
              if (!p.isTracking && p.history.isNotEmpty) ...[
                const SizedBox(height: 6),
                Row(
                  children: [
                    // Ver historial
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _showHistory = true),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 8),
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
                                'Ver historial (${p.history.length})',
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
                    ),

                  ],
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
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: ColorTokens.primary30,
        foregroundColor: Colors.white,
        title: const Text(
          'Mis Rodadas',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => setState(() => _showHistory = false),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.share_location_rounded),
            tooltip: 'Recomendaciones',
            onPressed: () => context.push('/ride-recommendations'),
          ),
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
                  const SizedBox(height: 5),
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
          const SizedBox(height: 6),
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
                        if (value == 'delete') _confirmDeleteRide(ride, p);
                        if (value == 'recommend') {
                          showModalBottomSheet(
                            context: context,
                            isScrollControlled: true,
                            backgroundColor: Colors.transparent,
                            builder: (_) => SendRecommendationSheet(track: ride),
                          );
                        }
                      },
                      itemBuilder: (_) => [
                        const PopupMenuItem(
                          value: 'recommend',
                          child: Row(
                            children: [
                              Icon(
                                Icons.share_location_rounded,
                                color: Color(0xFF519192),
                                size: 18,
                              ),
                              SizedBox(width: 8),
                              Text('Recomendar ruta'),
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
                const SizedBox(height: 6),
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
            const SizedBox(height: 5),
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
  void _showFinishConfirmation(RideTrackerProvider p) {
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
              const SizedBox(height: 6),
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
                        onPressed: () async {
                          Navigator.pop(ctx);
                          await _finishRide(p);
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

  Future<void> _finishRide(RideTrackerProvider p) async {
    final uid = FirebaseAuth.instance.currentUser?.uid ?? '';
    if (uid.isEmpty) return;

    final success = await p.stopAndSave(uid);

    if (mounted) {
      HapticFeedback.heavyImpact();
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(
              children: [
                Icon(Icons.check_circle_rounded, color: Colors.white, size: 20),
                SizedBox(width: 10),
                Text(
                  '¡Rodada guardada!',
                  style: TextStyle(fontWeight: FontWeight.w600),
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
              label: 'Ver historial',
              textColor: Colors.white,
              onPressed: () => setState(() => _showHistory = true),
            ),
          ),
        );
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
            onPressed: () async {
              Navigator.pop(ctx);
              await _finishRide(p);
              if (mounted) Navigator.of(context).pop();
            },
            child: const Text('Guardar y Salir'),
          ),
        ],
      ),
    );
  }
  Widget _buildDetailCard({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withValues(alpha: 0.15)),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Colors.grey[800],
                  ),
                ),
                Text(
                  label,
                  style: TextStyle(fontSize: 10, color: Colors.grey[500]),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

}
