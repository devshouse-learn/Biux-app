import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:biux/core/design_system/locale_notifier.dart';
import 'package:biux/features/accidents/domain/entities/accident_entity.dart';
import 'package:biux/features/accidents/presentation/screens/accident_detail_screen.dart';
import 'package:biux/features/accidents/presentation/screens/accident_report_screen.dart';

class AccidentsListScreen extends StatefulWidget {
  const AccidentsListScreen({Key? key}) : super(key: key);

  @override
  State<AccidentsListScreen> createState() => _AccidentsListScreenState();
}

class _AccidentsListScreenState extends State<AccidentsListScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  Position? _myPosition;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _getMyLocation();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _getMyLocation() async {
    try {
      final pos = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.medium,
        ),
      );
      if (mounted) setState(() => _myPosition = pos);
    } catch (e) {
      debugPrint('Error: ' + e.toString());
    }
  }

  String _distanceText(double lat, double lng) {
    if (_myPosition == null) return '';
    final meters = Geolocator.distanceBetween(
      _myPosition?.latitude ?? 0.0,
      _myPosition?.longitude ?? 0.0,
      lat,
      lng,
    );
    if (meters < 1000) return '${meters.toInt()} m';
    return '${(meters / 1000).toStringAsFixed(1)} km';
  }

  String _timeAgo(DateTime date, LocaleNotifier l) {
    final diff = DateTime.now().difference(date);
    if (diff.inMinutes < 1) return l.t('time_ago_now');
    if (diff.inMinutes < 60)
      return l.t('time_ago_minutes').replaceAll('{n}', '${diff.inMinutes}');
    if (diff.inHours < 24)
      return l.t('time_ago_hours').replaceAll('{n}', '${diff.inHours}');
    if (diff.inDays < 7)
      return l.t('time_ago_days').replaceAll('{n}', '${diff.inDays}');
    return DateFormat('dd/MM/yyyy').format(date);
  }

  Color _severityColor(String severity) {
    switch (severity) {
      case 'severe':
        return Colors.red;
      case 'moderate':
        return Colors.orange;
      default:
        return Colors.yellow[700]!;
    }
  }

  String _severityLabel(String severity, LocaleNotifier l) {
    switch (severity) {
      case 'severe':
        return l.t('severity_severe');
      case 'moderate':
        return l.t('severity_moderate');
      default:
        return l.t('severity_minor');
    }
  }

  IconData _severityIcon(String severity) {
    switch (severity) {
      case 'severe':
        return Icons.dangerous;
      case 'moderate':
        return Icons.warning;
      default:
        return Icons.warning_amber;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = Provider.of<LocaleNotifier>(context);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.red[700],
        foregroundColor: Colors.white,
        title: Text(l.t('reported_accidents_title')),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: [
            Tab(icon: const Icon(Icons.list), text: l.t('list_tab')),
            Tab(icon: const Icon(Icons.map), text: l.t('map_tab')),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [_buildListView(l), _buildMapView(l)],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const AccidentReportScreen()),
        ),
        backgroundColor: Colors.red[700],
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: Text(l.t('report_button')),
      ),
    );
  }

  // ── Lista de accidentes con pull-to-refresh ─────────
  Widget _buildListView(LocaleNotifier l) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('accidents')
          .where('resolved', isEqualTo: false)
          .orderBy('createdAt', descending: true)
          .limit(50)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 48, color: Colors.red),
                const SizedBox(height: 8),
                Text(
                  '${l.t('error_generic')}: ${snapshot.error}',
                  style: const TextStyle(color: Colors.red),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => setState(() {}),
                  child: Text(l.t('retry')),
                ),
              ],
            ),
          );
        }

        final docs = snapshot.data?.docs ?? [];

        if (docs.isEmpty) {
          return RefreshIndicator(
            onRefresh: () async => setState(() {}),
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              children: [
                SizedBox(height: MediaQuery.of(context).size.height * 0.25),
                Column(
                  children: [
                    Icon(
                      Icons.check_circle_outline,
                      size: 64,
                      color: Colors.green[300],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      l.t('no_accidents_reported'),
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      l.t('no_active_accidents_zone'),
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  ],
                ),
              ],
            ),
          );
        }

        final accidents = docs.map((d) {
          final data = d.data() as Map<String, dynamic>;
          return AccidentEntity.fromMap(d.id, data);
        }).toList();

        return RefreshIndicator(
          onRefresh: () async {
            await _getMyLocation();
            setState(() {});
          },
          child: ListView.builder(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.only(top: 8, bottom: 80),
            itemCount: accidents.length,
            itemBuilder: (context, index) {
              final a = accidents[index];
              return _accidentCard(a, l);
            },
          ),
        );
      },
    );
  }

  Widget _accidentCard(AccidentEntity a, LocaleNotifier l) {
    final color = _severityColor(a.severity);
    final dist = _distanceText(a.latitude, a.longitude);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => AccidentDetailScreen(accident: a)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // Severity icon
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(_severityIcon(a.severity), color: color, size: 28),
              ),
              const SizedBox(width: 12),
              // Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: color.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            _severityLabel(a.severity, l),
                            style: TextStyle(
                              color: color,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const Spacer(),
                        Text(
                          _timeAgo(a.createdAt, l),
                          style: TextStyle(
                            color: Colors.grey[500],
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      a.description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 14),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.person_outline,
                          size: 14,
                          color: Colors.grey[500],
                        ),
                        const SizedBox(width: 4),
                        Flexible(
                          child: Text(
                            a.userName.isNotEmpty
                                ? a.userName
                                : l.t('anonymous'),
                            style: TextStyle(
                              color: Colors.grey[500],
                              fontSize: 12,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (dist.isNotEmpty) ...[
                          const SizedBox(width: 12),
                          Icon(
                            Icons.near_me,
                            size: 14,
                            color: Colors.grey[500],
                          ),
                          const SizedBox(width: 4),
                          Text(
                            dist,
                            style: TextStyle(
                              color: Colors.grey[500],
                              fontSize: 12,
                            ),
                          ),
                        ],
                        if (a.imageUrls.isNotEmpty) ...[
                          const SizedBox(width: 12),
                          Icon(Icons.photo, size: 14, color: Colors.grey[500]),
                          const SizedBox(width: 4),
                          Text(
                            '${a.imageUrls.length}',
                            style: TextStyle(
                              color: Colors.grey[500],
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }

  // ── Mapa de accidentes ──────────────────────────────
  Widget _buildMapView(LocaleNotifier l) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('accidents')
          .where('resolved', isEqualTo: false)
          .orderBy('createdAt', descending: true)
          .limit(50)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final docs = snapshot.data?.docs ?? [];
        final accidents = docs.map((d) {
          final data = d.data() as Map<String, dynamic>;
          return AccidentEntity.fromMap(d.id, data);
        }).toList();

        final markers = accidents.map((a) {
          return Marker(
            markerId: MarkerId(a.id),
            position: LatLng(a.latitude, a.longitude),
            icon: BitmapDescriptor.defaultMarkerWithHue(
              a.severity == 'severe'
                  ? BitmapDescriptor.hueRed
                  : a.severity == 'moderate'
                  ? BitmapDescriptor.hueOrange
                  : BitmapDescriptor.hueYellow,
            ),
            infoWindow: InfoWindow(
              title:
                  '${_severityLabel(a.severity, l)} - ${_timeAgo(a.createdAt, l)}',
              snippet: a.description.length > 50
                  ? '${a.description.substring(0, 50)}...'
                  : a.description,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => AccidentDetailScreen(accident: a),
                ),
              ),
            ),
          );
        }).toSet();

        final initialPos = _myPosition != null
            ? LatLng(
                _myPosition?.latitude ?? 0.0,
                _myPosition?.longitude ?? 0.0,
              )
            : accidents.isNotEmpty
            ? LatLng(accidents.first.latitude, accidents.first.longitude)
            : const LatLng(19.4326, -99.1332);

        return GoogleMap(
          initialCameraPosition: CameraPosition(target: initialPos, zoom: 13),
          markers: markers,
          myLocationEnabled: true,
          myLocationButtonEnabled: true,
          zoomControlsEnabled: true,
        );
      },
    );
  }
}
