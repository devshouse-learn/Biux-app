import 'dart:io';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:biux/core/design_system/locale_notifier.dart';
import 'package:biux/features/accidents/domain/entities/accident_entity.dart';
import 'package:biux/features/accidents/presentation/screens/accident_detail_screen.dart';
import 'package:biux/features/users/presentation/providers/user_provider.dart';
import 'package:biux/shared/screens/location_picker_screen.dart';

class AccidentReportScreen extends StatefulWidget {
  const AccidentReportScreen({Key? key}) : super(key: key);
  @override
  State<AccidentReportScreen> createState() => _AccidentReportScreenState();
}

class _AccidentReportScreenState extends State<AccidentReportScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // ── Form state ──────────────────────────────────────
  final _descCtrl = TextEditingController();
  String _severity = 'minor';
  bool _submitting = false;
  LatLng? _selectedLocation;
  bool _loadingLocation = true;
  final List<File> _photos = [];
  final ImagePicker _picker = ImagePicker();

  // ── List/Map state ──────────────────────────────────
  Position? _myPosition;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _getAutoLocation();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  // ═══════════════════════════════════════════════════════
  // ── Location helpers ────────────────────────────────
  // ═══════════════════════════════════════════════════════
  Future<void> _getAutoLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        setState(() => _loadingLocation = false);
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.deniedForever) {
        setState(() => _loadingLocation = false);
        return;
      }
      if (permission == LocationPermission.whileInUse ||
          permission == LocationPermission.always) {
        final pos = await Geolocator.getCurrentPosition(
          locationSettings: const LocationSettings(
            accuracy: LocationAccuracy.high,
          ),
        );
        setState(() {
          _selectedLocation = LatLng(pos.latitude, pos.longitude);
          _myPosition = pos;
          _loadingLocation = false;
        });
      } else {
        setState(() => _loadingLocation = false);
      }
    } catch (e) {
      debugPrint('Error getting location: $e');
      setState(() => _loadingLocation = false);
    }
  }

  String _distanceText(double lat, double lng) {
    if (_myPosition == null) return '';
    final meters = Geolocator.distanceBetween(
      _myPosition!.latitude,
      _myPosition!.longitude,
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

  // ═══════════════════════════════════════════════════════
  // ── Photo helpers ───────────────────────────────────
  // ═══════════════════════════════════════════════════════
  Future<void> _addPhoto(ImageSource source) async {
    final l = Provider.of<LocaleNotifier>(context, listen: false);
    try {
      PermissionStatus status;
      if (source == ImageSource.camera) {
        status = await Permission.camera.request();
      } else {
        status = await Permission.photos.request();
      }

      if (status.isGranted || status.isLimited) {
        final XFile? xfile = await _picker.pickImage(
          source: source,
          maxWidth: 1200,
          maxHeight: 1200,
          imageQuality: 75,
        );
        if (xfile != null) {
          setState(() => _photos.add(File(xfile.path)));
        }
      } else if (status.isPermanentlyDenied) {
        if (mounted) {
          showDialog(
            context: context,
            builder: (ctx) => AlertDialog(
              title: Text(l.t('permission_required')),
              content: Text(
                source == ImageSource.camera
                    ? l.t('camera_permission_message')
                    : l.t('gallery_permission_message'),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: Text(l.t('cancel')),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.pop(ctx);
                    openAppSettings();
                  },
                  child: Text(l.t('open_settings')),
                ),
              ],
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                source == ImageSource.camera
                    ? l.t('camera_permission_needed')
                    : l.t('gallery_permission_needed'),
              ),
            ),
          );
        }
      }
    } catch (e) {
      debugPrint('Error picking image: $e');
    }
  }

  void _showPhotoOptions() {
    final l = Provider.of<LocaleNotifier>(context, listen: false);
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt, color: Colors.red),
                title: Text(l.t('take_photo')),
                onTap: () {
                  Navigator.pop(ctx);
                  _addPhoto(ImageSource.camera);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library, color: Colors.blue),
                title: Text(l.t('select_from_gallery')),
                onTap: () {
                  Navigator.pop(ctx);
                  _addPhoto(ImageSource.gallery);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════
  // ── Upload & Submit ─────────────────────────────────
  // ═══════════════════════════════════════════════════════
  Future<List<String>> _uploadPhotos(String accidentId) async {
    final List<String> urls = [];
    for (int i = 0; i < _photos.length; i++) {
      final ref = FirebaseStorage.instance.ref().child(
        'accidents/$accidentId/photo_$i.jpg',
      );
      await ref.putFile(_photos[i]);
      final url = await ref.getDownloadURL();
      urls.add(url);
    }
    return urls;
  }

  Future<void> _submit() async {
    final l = Provider.of<LocaleNotifier>(context, listen: false);
    if (_descCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l.t('accident_description_required'))),
      );
      return;
    }
    if (_selectedLocation == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l.t('accident_location_required'))),
      );
      return;
    }

    setState(() => _submitting = true);

    try {
      final user = FirebaseAuth.instance.currentUser;
      final uid = user?.uid ?? '';

      String userName = l.t('anonymous');
      try {
        final userProvider = context.read<UserProvider>();
        userName =
            userProvider.user?.name ?? user?.displayName ?? l.t('anonymous');
      } catch (_) {
        userName = user?.displayName ?? l.t('anonymous');
      }

      final docRef = await FirebaseFirestore.instance
          .collection('accidents')
          .add({
            'userId': uid,
            'userName': userName,
            'latitude': _selectedLocation!.latitude,
            'longitude': _selectedLocation!.longitude,
            'description': _descCtrl.text.trim(),
            'severity': _severity,
            'imageUrls': [],
            'createdAt': DateTime.now().toIso8601String(),
            'resolved': false,
          });

      if (_photos.isNotEmpty) {
        final urls = await _uploadPhotos(docRef.id);
        await docRef.update({'imageUrls': urls});
      }

      if (mounted) {
        // Limpiar formulario y cambiar a tab de reportes
        _descCtrl.clear();
        setState(() {
          _photos.clear();
          _severity = 'minor';
          _submitting = false;
        });
        _tabController.animateTo(0);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l.t('accident_reported_success')),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${l.t('error_generic')}: $e'),
            backgroundColor: Colors.red,
          ),
        );
        setState(() => _submitting = false);
      }
    }
  }

  Future<void> _openMapPicker() async {
    final l = Provider.of<LocaleNotifier>(context, listen: false);
    final LatLng? result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => LocationPickerScreen(
          initialLocation: _selectedLocation,
          title: l.t('accident_location'),
        ),
      ),
    );
    if (result != null) {
      setState(() => _selectedLocation = result);
    }
  }

  // ═══════════════════════════════════════════════════════
  // ── BUILD ───────────────────────────────────────────
  // ═══════════════════════════════════════════════════════
  @override
  Widget build(BuildContext context) {
    final l = Provider.of<LocaleNotifier>(context);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.red[700],
        foregroundColor: Colors.white,
        title: Text(l.t('accidents_title')),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: [
            Tab(
              icon: const Icon(Icons.list_alt, size: 20),
              text: l.t('reports_tab'),
            ),
            Tab(icon: const Icon(Icons.map, size: 20), text: l.t('map_tab')),
            Tab(
              icon: const Icon(Icons.add_circle_outline, size: 20),
              text: l.t('report_tab'),
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [_buildReportsTab(l), _buildMapTab(l), _buildReportForm(l)],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════
  // ── TAB 1: REPORTES (todos los usuarios) ────────────
  // ═══════════════════════════════════════════════════════
  Widget _buildReportsTab(LocaleNotifier l) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('accidents')
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
                  l.t('error_loading_reports'),
                  style: TextStyle(color: Colors.grey[600]),
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: () => setState(() {}),
                  icon: const Icon(Icons.refresh),
                  label: Text(l.t('retry')),
                ),
              ],
            ),
          );
        }

        final docs = snapshot.data?.docs ?? [];

        if (docs.isEmpty) {
          return RefreshIndicator(
            onRefresh: () async {
              await _getAutoLocation();
              setState(() {});
            },
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              children: [
                SizedBox(height: MediaQuery.of(context).size.height * 0.2),
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
                      l.t('no_active_accidents'),
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: () => _tabController.animateTo(2),
                      icon: const Icon(Icons.add),
                      label: Text(l.t('report_accident')),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red[700],
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
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

        final active = accidents.where((a) => !a.resolved).toList();
        final resolved = accidents.where((a) => a.resolved).toList();

        return RefreshIndicator(
          onRefresh: () async {
            await _getAutoLocation();
            setState(() {});
          },
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.only(top: 8, bottom: 80),
            children: [
              // ── Header con contador ────────────────
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.red[50],
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.warning, size: 16, color: Colors.red[700]),
                          const SizedBox(width: 4),
                          Text(
                            l
                                .t('active_count')
                                .replaceAll('{n}', '${active.length}'),
                            style: TextStyle(
                              color: Colors.red[700],
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (resolved.isNotEmpty) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.green[50],
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.check_circle,
                              size: 16,
                              color: Colors.green[700],
                            ),
                            const SizedBox(width: 4),
                            Text(
                              l
                                  .t('resolved_count')
                                  .replaceAll('{n}', '${resolved.length}'),
                              style: TextStyle(
                                color: Colors.green[700],
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                    const Spacer(),
                    Text(
                      l.t('visible_for_all'),
                      style: TextStyle(color: Colors.grey[400], fontSize: 11),
                    ),
                    const SizedBox(width: 4),
                    Icon(Icons.public, size: 14, color: Colors.grey[400]),
                  ],
                ),
              ),

              // ── Accidentes activos ─────────────────
              if (active.isNotEmpty) ...[
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 4,
                  ),
                  child: Text(
                    l.t('active_label'),
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: Colors.red,
                      letterSpacing: 1,
                    ),
                  ),
                ),
                ...active.map((a) => _accidentCard(a, l: l)),
              ],

              // ── Accidentes resueltos ───────────────
              if (resolved.isNotEmpty) ...[
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
                  child: Text(
                    l.t('resolved_label'),
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                      letterSpacing: 1,
                    ),
                  ),
                ),
                ...resolved.map(
                  (a) => _accidentCard(a, isResolved: true, l: l),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _accidentCard(
    AccidentEntity a, {
    bool isResolved = false,
    required LocaleNotifier l,
  }) {
    final color = isResolved ? Colors.green : _severityColor(a.severity);
    final dist = _distanceText(a.latitude, a.longitude);
    final currentUid = FirebaseAuth.instance.currentUser?.uid;
    final isMine = currentUid == a.userId;

    return Opacity(
      opacity: isResolved ? 0.6 : 1.0,
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: isResolved ? 0 : 2,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => AccidentDetailScreen(accident: a),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                // Icono severidad
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    isResolved ? Icons.check_circle : _severityIcon(a.severity),
                    color: color,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 10),
                // Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: color.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              isResolved
                                  ? l.t('resolved')
                                  : _severityLabel(a.severity, l),
                              style: TextStyle(
                                color: color,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          if (isMine) ...[
                            const SizedBox(width: 4),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.blue.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                l.t('mine'),
                                style: const TextStyle(
                                  color: Colors.blue,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                          const Spacer(),
                          Text(
                            _timeAgo(a.createdAt, l),
                            style: TextStyle(
                              color: Colors.grey[400],
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
                        style: const TextStyle(fontSize: 13),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Icons.person_outline,
                            size: 13,
                            color: Colors.grey[400],
                          ),
                          const SizedBox(width: 3),
                          Text(
                            a.userName.isNotEmpty
                                ? a.userName
                                : l.t('anonymous'),
                            style: TextStyle(
                              color: Colors.grey[500],
                              fontSize: 11,
                            ),
                          ),
                          if (dist.isNotEmpty) ...[
                            const SizedBox(width: 10),
                            Icon(
                              Icons.near_me,
                              size: 13,
                              color: Colors.grey[400],
                            ),
                            const SizedBox(width: 3),
                            Text(
                              dist,
                              style: TextStyle(
                                color: Colors.grey[500],
                                fontSize: 11,
                              ),
                            ),
                          ],
                          if (a.imageUrls.isNotEmpty) ...[
                            const SizedBox(width: 10),
                            Icon(
                              Icons.photo_camera,
                              size: 13,
                              color: Colors.grey[400],
                            ),
                            const SizedBox(width: 3),
                            Text(
                              '${a.imageUrls.length}',
                              style: TextStyle(
                                color: Colors.grey[500],
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right, size: 18, color: Colors.grey),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════
  // ── TAB 2: MAPA ─────────────────────────────────────
  // ═══════════════════════════════════════════════════════
  Widget _buildMapTab(LocaleNotifier l) {
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
              snippet: a.description.length > 60
                  ? '${a.description.substring(0, 60)}...'
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
            ? LatLng(_myPosition!.latitude, _myPosition!.longitude)
            : accidents.isNotEmpty
            ? LatLng(accidents.first.latitude, accidents.first.longitude)
            : const LatLng(19.4326, -99.1332);

        return Stack(
          children: [
            GoogleMap(
              initialCameraPosition: CameraPosition(
                target: initialPos,
                zoom: 13,
              ),
              markers: markers,
              myLocationEnabled: true,
              myLocationButtonEnabled: true,
              zoomControlsEnabled: true,
            ),
            // Leyenda
            Positioned(
              top: 12,
              left: 12,
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.15),
                      blurRadius: 8,
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      l
                          .t('active_count')
                          .replaceAll('{n}', '${accidents.length}'),
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 6),
                    _legendItem(Colors.red, l.t('severity_severe')),
                    _legendItem(Colors.orange, l.t('severity_moderate')),
                    _legendItem(Colors.yellow[700]!, l.t('severity_minor')),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _legendItem(Color color, String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 2),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 6),
          Text(label, style: const TextStyle(fontSize: 11)),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════
  // ── TAB 3: FORMULARIO DE REPORTE ────────────────────
  // ═══════════════════════════════════════════════════════
  Widget _buildReportForm(LocaleNotifier l) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Banner info ─────────────────────────────
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.red[50],
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.red[200]!),
            ),
            child: Row(
              children: [
                Icon(Icons.public, color: Colors.red[700], size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    l.t('report_visible_disclaimer'),
                    style: TextStyle(
                      color: Colors.red[800],
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // ── Ubicación ─────────────────────────────
          Text(
            l.t('accident_location_section'),
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          GestureDetector(
            onTap: _openMapPicker,
            child: Container(
              height: 160,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey[300]!),
                color: Theme.of(context).colorScheme.surface,
              ),
              child: _loadingLocation
                  ? const Center(child: CircularProgressIndicator())
                  : _selectedLocation != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Stack(
                        children: [
                          GoogleMap(
                            initialCameraPosition: CameraPosition(
                              target: _selectedLocation!,
                              zoom: 15,
                            ),
                            markers: {
                              Marker(
                                markerId: const MarkerId('accident'),
                                position: _selectedLocation!,
                                icon: BitmapDescriptor.defaultMarkerWithHue(
                                  BitmapDescriptor.hueRed,
                                ),
                              ),
                            },
                            liteModeEnabled: true,
                            zoomControlsEnabled: false,
                            scrollGesturesEnabled: false,
                            myLocationButtonEnabled: false,
                          ),
                          Positioned.fill(
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(onTap: _openMapPicker),
                            ),
                          ),
                          Positioned(
                            bottom: 8,
                            right: 8,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.red[700],
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    Icons.edit_location_alt,
                                    color: Colors.white,
                                    size: 16,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    l.t('change_location'),
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    )
                  : Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.map, size: 48, color: Colors.grey),
                        const SizedBox(height: 8),
                        Text(
                          l.t('tap_to_select_location'),
                          style: const TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
            ),
          ),
          if (_selectedLocation != null)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                '${_selectedLocation!.latitude.toStringAsFixed(5)}, ${_selectedLocation!.longitude.toStringAsFixed(5)}',
                style: TextStyle(color: Colors.grey[500], fontSize: 11),
              ),
            ),

          const SizedBox(height: 20),

          // ── Gravedad ──────────────────────────────
          Text(
            l.t('severity_section'),
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              _severityChip(
                'minor',
                l.t('severity_minor'),
                Colors.yellow[700]!,
                Icons.warning_amber,
              ),
              const SizedBox(width: 8),
              _severityChip(
                'moderate',
                l.t('severity_moderate'),
                Colors.orange,
                Icons.warning,
              ),
              const SizedBox(width: 8),
              _severityChip(
                'severe',
                l.t('severity_severe'),
                Colors.red,
                Icons.dangerous,
              ),
            ],
          ),

          const SizedBox(height: 20),

          // ── Descripción ───────────────────────────
          Text(
            l.t('description_section'),
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _descCtrl,
            maxLines: 4,
            decoration: InputDecoration(
              hintText: l.t('accident_description_hint'),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              filled: true,
              fillColor: Colors.grey[50],
            ),
          ),

          const SizedBox(height: 20),

          // ── Fotos ─────────────────────────────────
          Text(
            l.t('photos_optional_section'),
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 100,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                GestureDetector(
                  onTap: _photos.length < 5 ? _showPhotoOptions : null,
                  child: Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey[300]!),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.add_a_photo,
                          color: _photos.length < 5
                              ? Colors.red[700]
                              : Colors.grey,
                          size: 28,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${_photos.length}/5',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                ..._photos.asMap().entries.map(
                  (entry) => Padding(
                    padding: const EdgeInsets.only(left: 8),
                    child: Stack(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.file(
                            entry.value,
                            width: 100,
                            height: 100,
                            fit: BoxFit.cover,
                          ),
                        ),
                        Positioned(
                          top: 4,
                          right: 4,
                          child: GestureDetector(
                            onTap: () =>
                                setState(() => _photos.removeAt(entry.key)),
                            child: Container(
                              padding: const EdgeInsets.all(2),
                              decoration: const BoxDecoration(
                                color: Colors.red,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.close,
                                color: Colors.white,
                                size: 14,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // ── Botón enviar ──────────────────────────
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton.icon(
              onPressed: !_submitting ? _submit : null,
              icon: _submitting
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.send),
              label: Text(_submitting ? l.t('sending') : l.t('send_report')),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red[700],
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),

          const SizedBox(height: 12),

          // Disclaimer
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.blue[50],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.info_outline, size: 18, color: Colors.blue[700]),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    l.t('call_911_disclaimer'),
                    style: TextStyle(color: Colors.blue[800], fontSize: 12),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _severityChip(String value, String label, Color color, IconData icon) {
    final selected = _severity == value;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _severity = value),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: selected ? color.withValues(alpha: 0.2) : Colors.grey[100],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: selected ? color : Colors.transparent,
              width: 2,
            ),
          ),
          child: Column(
            children: [
              Icon(icon, color: selected ? color : Colors.grey, size: 24),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: selected ? color : Colors.grey,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
