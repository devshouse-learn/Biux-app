import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_image_viewer/easy_image_viewer.dart';
import 'package:provider/provider.dart';
import 'package:biux/core/design_system/locale_notifier.dart';
import 'package:biux/features/accidents/domain/entities/accident_entity.dart';

class AccidentDetailScreen extends StatelessWidget {
  final AccidentEntity accident;

  const AccidentDetailScreen({Key? key, required this.accident})
    : super(key: key);

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
    final color = _severityColor(accident.severity);
    final currentUid = FirebaseAuth.instance.currentUser?.uid;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.red[700],
        foregroundColor: Colors.white,
        title: Text(l.t('accident_detail_title')),
        actions: [
          if (currentUid == accident.userId)
            PopupMenuButton<String>(
              onSelected: (value) async {
                if (value == 'resolve') {
                  final confirm = await showDialog<bool>(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      title: Text(l.t('mark_as_resolved')),
                      content: Text(l.t('accident_resolved_question')),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(ctx, false),
                          child: Text(l.t('cancel')),
                        ),
                        TextButton(
                          onPressed: () => Navigator.pop(ctx, true),
                          child: Text(
                            l.t('yes_resolved'),
                            style: const TextStyle(color: Colors.green),
                          ),
                        ),
                      ],
                    ),
                  );
                  if (confirm == true) {
                    await FirebaseFirestore.instance
                        .collection('accidents')
                        .doc(accident.id)
                        .update({'resolved': true});
                    if (context.mounted) {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(l.t('accident_marked_resolved')),
                          backgroundColor: Colors.green,
                        ),
                      );
                    }
                  }
                }
              },
              itemBuilder: (ctx) => [
                PopupMenuItem(
                  value: 'resolve',
                  child: Row(
                    children: [
                      const Icon(Icons.check_circle, color: Colors.green),
                      const SizedBox(width: 8),
                      Text(l.t('mark_resolved')),
                    ],
                  ),
                ),
              ],
            ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Mapa ──────────────────────────────────
            SizedBox(
              height: 200,
              child: GoogleMap(
                initialCameraPosition: CameraPosition(
                  target: LatLng(accident.latitude, accident.longitude),
                  zoom: 16,
                ),
                markers: {
                  Marker(
                    markerId: const MarkerId('accident'),
                    position: LatLng(accident.latitude, accident.longitude),
                    icon: BitmapDescriptor.defaultMarkerWithHue(
                      accident.severity == 'severe'
                          ? BitmapDescriptor.hueRed
                          : accident.severity == 'moderate'
                          ? BitmapDescriptor.hueOrange
                          : BitmapDescriptor.hueYellow,
                    ),
                  ),
                },
                liteModeEnabled: true,
                zoomControlsEnabled: false,
                myLocationButtonEnabled: false,
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Severidad y tiempo ────────────────
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: color.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              _severityIcon(accident.severity),
                              color: color,
                              size: 18,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              _severityLabel(accident.severity, l),
                              style: TextStyle(
                                color: color,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Spacer(),
                      Icon(
                        Icons.access_time,
                        size: 16,
                        color: Colors.grey[500],
                      ),
                      const SizedBox(width: 4),
                      Text(
                        DateFormat(
                          'dd/MM/yyyy HH:mm',
                        ).format(accident.createdAt),
                        style: TextStyle(color: Colors.grey[500], fontSize: 13),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // ── Reportado por ─────────────────────
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 18,
                        backgroundColor: Colors.grey[200],
                        child: const Icon(
                          Icons.person,
                          color: Colors.grey,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l.t('reported_by'),
                            style: const TextStyle(
                              color: Colors.grey,
                              fontSize: 11,
                            ),
                          ),
                          Text(
                            accident.userName.isNotEmpty
                                ? accident.userName
                                : l.t('anonymous'),
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),
                  const Divider(),
                  const SizedBox(height: 8),

                  // ── Descripción ───────────────────────
                  Text(
                    l.t('description_field'),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    accident.description,
                    style: const TextStyle(fontSize: 15, height: 1.5),
                  ),

                  const SizedBox(height: 16),

                  // ── Coordenadas ───────────────────────
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.pin_drop,
                          size: 18,
                          color: Colors.grey,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '${accident.latitude.toStringAsFixed(5)}, ${accident.longitude.toStringAsFixed(5)}',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 13,
                            fontFamily: 'monospace',
                          ),
                        ),
                      ],
                    ),
                  ),

                  // ── Fotos ─────────────────────────────
                  if (accident.imageUrls.isNotEmpty) ...[
                    const SizedBox(height: 20),
                    Text(
                      'Fotos (${accident.imageUrls.length})',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      height: 200,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: accident.imageUrls.length,
                        itemBuilder: (context, index) {
                          return Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: GestureDetector(
                              onTap: () {
                                final imageProvider =
                                    CachedNetworkImageProvider(
                                      accident.imageUrls[index],
                                    );
                                showImageViewer(
                                  context,
                                  imageProvider,
                                  swipeDismissible: true,
                                  doubleTapZoomable: true,
                                );
                              },
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: CachedNetworkImage(
                                  imageUrl: accident.imageUrls[index],
                                  width: 200,
                                  height: 200,
                                  fit: BoxFit.cover,
                                  placeholder: (_, __) => Container(
                                    width: 200,
                                    height: 200,
                                    color: Colors.grey[200],
                                    child: const Center(
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                      ),
                                    ),
                                  ),
                                  errorWidget: (_, __, ___) => Container(
                                    width: 200,
                                    height: 200,
                                    color: Colors.grey[200],
                                    child: const Icon(
                                      Icons.broken_image,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],

                  const SizedBox(height: 24),

                  // ── Botón de emergencia ────────────────
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.red[50],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.red[200]!),
                    ),
                    child: Column(
                      children: [
                        const Icon(
                          Icons.emergency,
                          color: Colors.red,
                          size: 32,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          l.t('call_911'),
                          style: const TextStyle(
                            color: Colors.red,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
