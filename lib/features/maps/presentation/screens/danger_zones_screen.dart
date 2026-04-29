// ignore_for_file: deprecated_member_use
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:biux/features/maps/data/datasources/danger_zones_datasource.dart';
import 'package:biux/core/design_system/locale_notifier.dart';
import 'package:provider/provider.dart';

class DangerZonesScreen extends StatefulWidget {
  const DangerZonesScreen({super.key});

  @override
  State<DangerZonesScreen> createState() => _DangerZonesScreenState();
}

// ignore_for_file: unused_field
class _DangerZonesScreenState extends State<DangerZonesScreen> {
  LocaleNotifier get l => Provider.of<LocaleNotifier>(context);

  Position? _position;
  bool _reportMode = false;

  @override
  void initState() {
    super.initState();
    _getLocation();
  }

  Future<void> _getLocation() async {
    try {
      final pos = await Geolocator.getCurrentPosition();
      setState(() => _position = pos);
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(l.t('danger_zones')),
        backgroundColor: Color(0xFF16242D),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: Icon(
              _reportMode ? Icons.close_rounded : Icons.add_location_rounded,
            ),
            onPressed: () => setState(() => _reportMode = !_reportMode),
            tooltip: _reportMode ? l.t('cancel') : 'Reportar zona',
          ),
        ],
      ),
      body: Stack(
        children: [
          StreamBuilder<List<DangerZoneEntity>>(
            stream: DangerZonesDatasource.zonesStream(),
            builder: (context, snap) {
              final zones = snap.data ?? [];
              final markers = zones.map((z) {
                return Marker(
                  markerId: MarkerId(z.id),
                  position: LatLng(z.lat, z.lng),
                  icon: BitmapDescriptor.defaultMarkerWithHue(
                    z.type == DangerType.accident
                        ? BitmapDescriptor.hueRed
                        : z.type == DangerType.theft
                        ? BitmapDescriptor.hueOrange
                        : BitmapDescriptor.hueYellow,
                  ),
                  infoWindow: InfoWindow(
                    title: z.typeLabel,
                    snippet: '\${z.description} • \${z.reportCount} reportes',
                  ),
                  onTap: () => _showZoneDetail(context, z),
                );
              }).toSet();

              return GoogleMap(
                initialCameraPosition: CameraPosition(
                  target: _position != null
                      ? LatLng(_position!.latitude, _position!.longitude)
                      : const LatLng(19.4326, -99.1332),
                  zoom: 14,
                ),
                markers: markers,
                myLocationEnabled: true,
                myLocationButtonEnabled: true,
                onTap: _reportMode ? _onMapTap : null,
              );
            },
          ),
          // Leyenda
          Positioned(
            bottom: 16,
            left: 16,
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 8,
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Leyenda',
                    style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12),
                  ),
                  SizedBox(height: 6),
                  _LegendItem(color: Colors.red, label: l.t('accident_label')),
                  _LegendItem(color: Colors.orange, label: l.t('robbery')),
                  _LegendItem(
                    color: Colors.yellow.shade700,
                    label: l.t('others'),
                  ),
                ],
              ),
            ),
          ),
          if (_reportMode)
            Positioned(
              top: 12,
              left: 16,
              right: 16,
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.red.shade200),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.touch_app_rounded,
                      color: Colors.red,
                      size: 20,
                    ),
                    SizedBox(width: 8),
                    Text(
                      l.t('tap_map_report'),
                      style: TextStyle(
                        color: Colors.red,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  void _onMapTap(LatLng position) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) =>
          _ReportSheet(lat: position.latitude, lng: position.longitude),
    ).then((_) => setState(() => _reportMode = false));
  }

  void _showZoneDetail(BuildContext context, DangerZoneEntity zone) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              zone.typeLabel,
              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 18),
            ),
            const SizedBox(height: 8),
            Text(
              zone.description,
              style: const TextStyle(color: Colors.black54),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(
                  Icons.person_outline_rounded,
                  size: 16,
                  color: Colors.grey,
                ),
                const SizedBox(width: 4),
                Text(
                  'Reportado por \${zone.reportedByName}',
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
                const Spacer(),
                Icon(
                  Icons.warning_amber_rounded,
                  size: 16,
                  color: Colors.orange,
                ),
                const SizedBox(width: 4),
                Text(
                  '\${zone.reportCount} reportes',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () async {
                  await DangerZonesDatasource.confirmZone(zone.id);
                  if (context.mounted) Navigator.pop(context);
                },
                icon: Icon(Icons.thumb_up_rounded),
                label: Text(l.t('confirm_danger_zone')),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ReportSheet extends StatefulWidget {
  final double lat;
  final double lng;
  const _ReportSheet({required this.lat, required this.lng});

  @override
  State<_ReportSheet> createState() => _ReportSheetState();
}

class _ReportSheetState extends State<_ReportSheet> {
  LocaleNotifier get l => Provider.of<LocaleNotifier>(context);

  DangerType _type = DangerType.accident;
  final _desc = TextEditingController();
  bool _loading = false;

  @override
  void dispose() {
    _desc.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l.t('report_danger_zone'),
            style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
          ),
          SizedBox(height: 16),
          DropdownButtonFormField<DangerType>(
            value: _type,
            decoration: InputDecoration(
              labelText: l.t('danger_type'),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            items: DangerType.values
                .map(
                  (t) => DropdownMenuItem(
                    value: t,
                    child: Text(
                      DangerZoneEntity(
                        id: '',
                        reportedBy: '',
                        reportedByName: '',
                        type: t,
                        description: '',
                        lat: 0,
                        lng: 0,
                        reportCount: 0,
                        createdAt: DateTime.now(),
                      ).typeLabel,
                    ),
                  ),
                )
                .toList(),
            onChanged: (v) => setState(() => _type = v ?? DangerType.accident),
          ),
          SizedBox(height: 12),
          TextField(
            controller: _desc,
            decoration: InputDecoration(
              labelText: l.t('description_optional'),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            maxLines: 2,
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _loading ? null : _submit,
              icon: Icon(Icons.send_rounded),
              label: Text(l.t('send_report_user')),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _submit() async {
    setState(() => _loading = true);
    try {
      await DangerZonesDatasource.reportZone(
        type: _type,
        description: _desc.text.trim(),
        lat: widget.lat,
        lng: widget.lng,
      );
      if (mounted) Navigator.pop(context);
    } finally {
      setState(() => _loading = false);
    }
  }
}

class _LegendItem extends StatelessWidget {
  final Color color;
  final String label;
  const _LegendItem({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          margin: const EdgeInsets.only(right: 6, top: 4),
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        Text(label, style: const TextStyle(fontSize: 11)),
      ],
    );
  }
}
