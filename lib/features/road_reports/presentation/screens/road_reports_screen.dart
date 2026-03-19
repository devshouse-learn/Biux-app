import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:geolocator/geolocator.dart';
import 'package:biux/core/design_system/color_tokens.dart';
import 'package:biux/core/design_system/locale_notifier.dart';
import 'package:biux/features/road_reports/presentation/providers/road_reports_provider.dart';
import 'package:biux/features/users/presentation/providers/user_provider.dart';

class RoadReportsScreen extends StatefulWidget {
  const RoadReportsScreen({Key? key}) : super(key: key);
  @override
  State<RoadReportsScreen> createState() => _RoadReportsScreenState();
}

class _RoadReportsScreenState extends State<RoadReportsScreen> {
  String get _currentUid => FirebaseAuth.instance.currentUser?.uid ?? '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<RoadReportsProvider>().loadReports();
    });
  }

  Future<Position?> _getCurrentPosition() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Activa el servicio de ubicación'),
              backgroundColor: Colors.orange,
            ),
          );
        }
        return null;
      }
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Se necesitan permisos de ubicación'),
                backgroundColor: Colors.orange,
              ),
            );
          }
          return null;
        }
      }
      if (permission == LocationPermission.deniedForever) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Permisos denegados. Ve a Configuración.'),
              backgroundColor: Colors.red,
            ),
          );
        }
        return null;
      }
      return await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 10),
        ),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error ubicación: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return null;
    }
  }

  Future<void> _onConfirm(RoadReportsProvider provider, String reportId) async {
    final l = Provider.of<LocaleNotifier>(context, listen: false);
    try {
      final success = await provider.confirmReport(reportId, _currentUid);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              success ? '¡Reporte confirmado!' : 'Ya confirmaste este reporte',
            ),
            backgroundColor: success ? Colors.green[700] : Colors.orange,
            duration: const Duration(seconds: 2),
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
      }
    }
  }

  void _confirmDelete(RoadReportsProvider provider, String reportId) {
    showDialog(
      context: context,
      builder: (dc) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.delete_outline, color: Colors.red),
            SizedBox(width: 8),
            Text('Eliminar reporte'),
          ],
        ),
        content: const Text(
          '¿Estás seguro de que quieres eliminar este reporte?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dc).pop(),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(dc).pop();
              await provider.dismissReport(reportId);
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Row(
                      children: [
                        Icon(Icons.check_circle, color: Colors.white, size: 20),
                        SizedBox(width: 8),
                        Text('Reporte eliminado'),
                      ],
                    ),
                    backgroundColor: Colors.green[700],
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorTokens.neutral99,
      appBar: AppBar(
        title: const Text('Reportes de Vía'),
        backgroundColor: ColorTokens.primary30,
        foregroundColor: Colors.white,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showCreate(context),
        backgroundColor: ColorTokens.primary30,
        icon: const Icon(Icons.add_location_alt, color: Colors.white),
        label: const Text('Reportar', style: TextStyle(color: Colors.white)),
      ),
      body: Consumer<RoadReportsProvider>(
        builder: (ctx, provider, _) {
          if (provider.isLoading)
            return const Center(child: CircularProgressIndicator());
          if (provider.reports.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.check_circle_outline,
                    size: 64,
                    color: Colors.green[300],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No hay reportes activos',
                    style: TextStyle(color: Colors.grey[600], fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '¡Las vías están despejadas!',
                    style: TextStyle(color: Colors.grey[400], fontSize: 13),
                  ),
                ],
              ),
            );
          }
          return RefreshIndicator(
            onRefresh: () => provider.loadReports(),
            child: ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: provider.reports.length,
              itemBuilder: (ctx, i) => _buildReportCard(provider, i),
            ),
          );
        },
      ),
    );
  }

  Widget _buildReportCard(RoadReportsProvider provider, int index) {
    final r = provider.reports[index];
    final isOwner = r.userId == _currentUid;
    final alreadyConfirmed = r.hasConfirmed(_currentUid);

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: Colors.orange.withValues(alpha: 0.1),
                  child: Text(r.typeIcon, style: const TextStyle(fontSize: 22)),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        r.typeName,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                        ),
                      ),
                      Text(
                        'Por ${r.userName}',
                        style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                      ),
                    ],
                  ),
                ),
                if (isOwner)
                  PopupMenuButton<String>(
                    icon: Icon(
                      Icons.more_vert,
                      color: Colors.grey[400],
                      size: 20,
                    ),
                    onSelected: (v) {
                      if (v == 'delete') _confirmDelete(provider, r.id);
                    },
                    itemBuilder: (_) => [
                      const PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(
                              Icons.delete_outline,
                              color: Colors.red,
                              size: 20,
                            ),
                            SizedBox(width: 8),
                            Text(
                              'Eliminar reporte',
                              style: TextStyle(color: Colors.red),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              r.description,
              style: TextStyle(fontSize: 14, color: Colors.grey[700]),
            ),
            const SizedBox(height: 12),

            // Footer: confirmaciones + botón
            Row(
              children: [
                Icon(Icons.thumb_up, size: 14, color: Colors.grey[400]),
                const SizedBox(width: 4),
                Text(
                  '${r.confirmations}',
                  style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                ),
                const Spacer(),

                // Siempre mostrar botón de confirmar (incluso en tu propio reporte)
                // pero también mostrar indicador si es tuyo
                if (isOwner) ...[
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    margin: const EdgeInsets.only(right: 8),
                    decoration: BoxDecoration(
                      color: ColorTokens.primary30.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Text(
                      'Tuyo',
                      style: TextStyle(
                        fontSize: 10,
                        color: ColorTokens.primary30,
                      ),
                    ),
                  ),
                ],

                // Botón de confirmar siempre visible para todos
                ElevatedButton.icon(
                  onPressed: alreadyConfirmed
                      ? null
                      : () => _onConfirm(provider, r.id),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: alreadyConfirmed
                        ? Colors.grey[200]
                        : ColorTokens.primary30,
                    foregroundColor: alreadyConfirmed
                        ? Colors.grey[500]
                        : Colors.white,
                    disabledBackgroundColor: Colors.grey[200],
                    disabledForegroundColor: ColorTokens.primary30,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 8,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  icon: Icon(
                    alreadyConfirmed ? Icons.thumb_up : Icons.thumb_up_outlined,
                    size: 16,
                  ),
                  label: Text(
                    alreadyConfirmed ? 'Confirmado' : 'Confirmar',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showCreate(BuildContext context) {
    final l = Provider.of<LocaleNotifier>(context, listen: false);
    String type = 'pothole';
    final descCtrl = TextEditingController();
    bool isSending = false;
    final types = {
      'pothole': '🕳️ Hueco',
      'obstacle': '⚠️ Obstáculo',
      'danger': '🚨 Peligro',
      'construction': '🚧 Construcción',
      'flooding': '🌊 Inundación',
    };

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setBS) => Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 20,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Nuevo Reporte',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Text(
                'Selecciona el tipo y describe el problema',
                style: TextStyle(color: Colors.grey[600], fontSize: 13),
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: types.entries
                    .map(
                      (e) => ChoiceChip(
                        label: Text(e.value),
                        selected: type == e.key,
                        selectedColor: ColorTokens.primary30.withValues(
                          alpha: 0.2,
                        ),
                        onSelected: (_) => setBS(() => type = e.key),
                      ),
                    )
                    .toList(),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: descCtrl,
                decoration: InputDecoration(
                  labelText: 'Descripción',
                  hintText: 'Ej: Hueco grande en el carril...',
                  border: const OutlineInputBorder(),
                  hintStyle: TextStyle(color: Colors.grey[400]),
                ),
                maxLines: 2,
                textCapitalization: TextCapitalization.sentences,
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.gps_fixed, size: 14, color: Colors.grey[500]),
                  const SizedBox(width: 4),
                  Text(
                    'Se usará tu ubicación actual',
                    style: TextStyle(fontSize: 11, color: Colors.grey[500]),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: ColorTokens.primary30,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.all(14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  icon: isSending
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.send),
                  label: Text(isSending ? 'Enviando...' : 'Enviar Reporte'),
                  onPressed: isSending
                      ? null
                      : () async {
                          if (descCtrl.text.trim().isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Escribe una descripción'),
                                backgroundColor: Colors.orange,
                              ),
                            );
                            return;
                          }
                          setBS(() => isSending = true);
                          try {
                            final pos = await _getCurrentPosition();
                            if (pos == null) {
                              setBS(() => isSending = false);
                              return;
                            }
                            final uid = _currentUid;
                            if (uid.isEmpty) {
                              if (mounted)
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Debes iniciar sesión'),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                              setBS(() => isSending = false);
                              return;
                            }
                            final name =
                                context.read<UserProvider>().user?.name ??
                                'Ciclista';
                            await context
                                .read<RoadReportsProvider>()
                                .createReport(
                                  userId: uid,
                                  userName: name,
                                  type: type,
                                  description: descCtrl.text.trim(),
                                  lat: pos.latitude,
                                  lng: pos.longitude,
                                );
                            if (ctx.mounted) Navigator.pop(ctx);
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: const Row(
                                    children: [
                                      Icon(
                                        Icons.check_circle,
                                        color: Colors.white,
                                        size: 20,
                                      ),
                                      SizedBox(width: 8),
                                      Text('¡Reporte enviado!'),
                                    ],
                                  ),
                                  backgroundColor: Colors.green[700],
                                ),
                              );
                            }
                          } catch (e) {
                            setBS(() => isSending = false);
                            if (mounted)
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('${l.t('error_generic')}: $e'),
                                  backgroundColor: Colors.red,
                                ),
                              );
                          }
                        },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
