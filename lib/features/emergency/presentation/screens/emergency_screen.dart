import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:biux/core/design_system/color_tokens.dart';
import 'package:biux/features/emergency/presentation/providers/emergency_provider.dart';
import 'package:biux/features/emergency/domain/entities/emergency_contact_entity.dart';
import 'package:biux/features/users/presentation/providers/user_provider.dart';
import 'package:biux/features/accidents/domain/entities/accident_entity.dart';
import 'package:biux/features/accidents/presentation/screens/accidents_list_screen.dart';
import 'package:biux/features/accidents/presentation/screens/accident_report_screen.dart';
import 'package:biux/features/accidents/presentation/screens/accident_detail_screen.dart';

class EmergencyScreen extends StatefulWidget {
  const EmergencyScreen({Key? key}) : super(key: key);
  @override
  State<EmergencyScreen> createState() => _EmergencyScreenState();
}

class _EmergencyScreenState extends State<EmergencyScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid != null) context.read<EmergencyProvider>().loadContacts(uid);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorTokens.neutral99,
      appBar: AppBar(
        title: const Text('Emergencia SOS'),
        backgroundColor: Colors.red[700],
        foregroundColor: Colors.white,
      ),
      body: Consumer<EmergencyProvider>(
        builder: (context, p, _) {
          return RefreshIndicator(
            onRefresh: () async {
              final uid = FirebaseAuth.instance.currentUser?.uid;
              if (uid != null) p.loadContacts(uid);
              setState(() {});
            },
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _buildSOS(context, p),
                  const SizedBox(height: 24),
                  _buildRecentAccidents(context),
                  const SizedBox(height: 24),
                  _buildQuickEmergency(),
                  const SizedBox(height: 24),
                  _buildContacts(context, p),
                  const SizedBox(height: 16),
                  _buildTips(),
                  const SizedBox(height: 80),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // ── SOS Button ─────────────────────────────────────────
  Widget _buildSOS(BuildContext context, EmergencyProvider p) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: p.sosActive
              ? [Colors.orange, Colors.amber]
              : [Colors.red[700]!, Colors.red[900]!],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: (p.sosActive ? Colors.orange : Colors.red).withValues(
              alpha: 0.4,
            ),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          const Icon(Icons.sos, size: 60, color: Colors.white),
          const SizedBox(height: 12),
          Text(
            p.sosActive ? 'ALERTA ACTIVA' : 'BOTÓN DE EMERGENCIA',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            p.sosActive
                ? 'Tus contactos han sido notificados'
                : 'Mantén presionado para enviar alerta SOS',
            style: const TextStyle(color: Colors.white70, fontSize: 13),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          GestureDetector(
            onLongPress: p.sosActive ? null : () => _triggerSOS(context, p),
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.2),
                border: Border.all(color: Colors.white, width: 3),
              ),
              child: Center(
                child: Text(
                  p.sosActive ? '✓' : 'SOS',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
          if (p.sosActive) ...[
            const SizedBox(height: 12),
            TextButton(
              onPressed: () => p.cancelSOS(),
              child: const Text(
                'Cancelar alerta',
                style: TextStyle(
                  color: Colors.white,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _triggerSOS(BuildContext context, EmergencyProvider p) async {
    try {
      final pos = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );
      final uid = FirebaseAuth.instance.currentUser?.uid ?? '';
      final name = context.read<UserProvider>().user?.name ?? 'Ciclista';
      await p.sendSOS(
        userId: uid,
        userName: name,
        latitude: pos.latitude,
        longitude: pos.longitude,
        message: 'Emergencia ciclista',
      );
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('¡Alerta SOS enviada!'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  // ══════════════════════════════════════════════════════════
  // ── Accidentes Recientes (NUEVO) ─────────────────────────
  // ══════════════════════════════════════════════════════════
  Widget _buildRecentAccidents(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 8),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Icon(Icons.car_crash, color: Colors.red, size: 22),
                  SizedBox(width: 8),
                  Text(
                    'Accidentes Recientes',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              Row(
                children: [
                  TextButton.icon(
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const AccidentReportScreen(),
                      ),
                    ),
                    icon: const Icon(Icons.add, size: 16),
                    label: const Text('Reportar'),
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.red[700],
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('accidents')
                .where('resolved', isEqualTo: false)
                .orderBy('createdAt', descending: true)
                .limit(5)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Padding(
                  padding: EdgeInsets.all(16),
                  child: Center(
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                );
              }

              if (snapshot.hasError) {
                return Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      const Icon(Icons.error_outline, color: Colors.red),
                      const SizedBox(height: 4),
                      Text(
                        'Error al cargar accidentes',
                        style: TextStyle(color: Colors.grey[600], fontSize: 13),
                      ),
                    ],
                  ),
                );
              }

              final docs = snapshot.data?.docs ?? [];

              if (docs.isEmpty) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  child: Center(
                    child: Column(
                      children: [
                        Icon(
                          Icons.check_circle_outline,
                          size: 40,
                          color: Colors.green[300],
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          '¡Sin accidentes reportados!',
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Las vías están despejadas',
                          style: TextStyle(
                            color: Colors.grey[500],
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }

              final accidents = docs.map((d) {
                final data = d.data() as Map<String, dynamic>;
                return AccidentEntity.fromMap(d.id, data);
              }).toList();

              return Column(
                children: [
                  ...accidents.map((a) => _accidentTile(context, a)),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const AccidentsListScreen(),
                        ),
                      ),
                      icon: const Icon(Icons.map, size: 18),
                      label: const Text('Ver todos en mapa'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.red[700],
                        side: BorderSide(color: Colors.red[200]!),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _accidentTile(BuildContext context, AccidentEntity a) {
    final color = _severityColor(a.severity);
    final timeAgo = _timeAgo(a.createdAt);

    return InkWell(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => AccidentDetailScreen(accident: a)),
      ),
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(_severityIcon(a.severity), color: color, size: 22),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 1,
                        ),
                        decoration: BoxDecoration(
                          color: color.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          _severityLabel(a.severity),
                          style: TextStyle(
                            color: color,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          a.description,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Icon(
                        Icons.person_outline,
                        size: 12,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(width: 3),
                      Text(
                        a.userName.isNotEmpty ? a.userName : 'Anónimo',
                        style: TextStyle(color: Colors.grey[500], fontSize: 11),
                      ),
                      const SizedBox(width: 8),
                      Icon(
                        Icons.access_time,
                        size: 12,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(width: 3),
                      Text(
                        timeAgo,
                        style: TextStyle(color: Colors.grey[500], fontSize: 11),
                      ),
                      if (a.imageUrls.isNotEmpty) ...[
                        const SizedBox(width: 8),
                        Icon(
                          Icons.photo_camera,
                          size: 12,
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
    );
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

  String _severityLabel(String severity) {
    switch (severity) {
      case 'severe':
        return 'Grave';
      case 'moderate':
        return 'Moderado';
      default:
        return 'Leve';
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

  String _timeAgo(DateTime date) {
    final diff = DateTime.now().difference(date);
    if (diff.inMinutes < 1) return 'Ahora';
    if (diff.inMinutes < 60) return 'Hace ${diff.inMinutes} min';
    if (diff.inHours < 24) return 'Hace ${diff.inHours} h';
    if (diff.inDays < 7) return 'Hace ${diff.inDays} d';
    return DateFormat('dd/MM/yy').format(date);
  }

  // ── Números de Emergencia ──────────────────────────────
  Widget _buildQuickEmergency() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 8),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Números de Emergencia',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          _eTile('🚑 Emergencias', '123', Colors.red),
          _eTile('�� Policía', '112', Colors.blue),
          _eTile('🚒 Bomberos', '119', Colors.orange),
          _eTile('🏥 Cruz Roja', '132', Colors.red[800]!),
        ],
      ),
    );
  }

  Widget _eTile(String t, String n, Color c) {
    return ListTile(
      dense: true,
      contentPadding: EdgeInsets.zero,
      title: Text(t, style: const TextStyle(fontWeight: FontWeight.w500)),
      trailing: ElevatedButton.icon(
        onPressed: () => _makeCall(n, t),
        icon: const Icon(Icons.phone, size: 16),
        label: Text(n),
        style: ElevatedButton.styleFrom(
          backgroundColor: c,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        ),
      ),
    );
  }

  // ── Contactos de Emergencia ────────────────────────────
  Widget _buildContacts(BuildContext context, EmergencyProvider p) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 8),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Mis Contactos de Emergencia',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              IconButton(
                icon: const Icon(
                  Icons.add_circle,
                  color: ColorTokens.primary30,
                ),
                onPressed: () => _showAdd(context),
              ),
            ],
          ),
          if (p.contacts.isEmpty)
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                'Agrega contactos de emergencia para que sean notificados en caso de alerta',
                style: TextStyle(color: Colors.grey),
                textAlign: TextAlign.center,
              ),
            )
          else
            ...p.contacts.map(
              (c) => ListTile(
                dense: true,
                contentPadding: EdgeInsets.zero,
                leading: CircleAvatar(
                  backgroundColor: ColorTokens.primary30.withValues(alpha: 0.1),
                  child: Text(
                    _relIcon(c.relationship),
                    style: const TextStyle(fontSize: 18),
                  ),
                ),
                title: Text(
                  c.name,
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
                subtitle: Text(
                  '${c.phone}${c.relationship != null && c.relationship!.isNotEmpty ? " • ${c.relationship}" : ""}',
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(
                        Icons.phone,
                        color: Colors.green,
                        size: 20,
                      ),
                      onPressed: () => _makeCall(c.phone, c.name),
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.delete,
                        color: Colors.red,
                        size: 20,
                      ),
                      onPressed: () {
                        final uid =
                            FirebaseAuth.instance.currentUser?.uid ?? '';
                        p.removeContact(uid, c.id);
                      },
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _makeCall(String number, String name) async {
    final uri = Uri.parse('tel://$number');
    final canCall = await canLaunchUrl(uri);
    if (canCall) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      if (!mounted) return;
      var dialogOpen = true;
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (ctx) {
          Future.delayed(const Duration(seconds: 4), () {
            if (dialogOpen && ctx.mounted) {
              dialogOpen = false;
              Navigator.of(ctx).pop();
            }
          });
          return Dialog(
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.green.withValues(alpha: 0.1),
                    ),
                    child: const Icon(
                      Icons.phone_in_talk,
                      size: 50,
                      color: Colors.green,
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Llamando...',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    name,
                    style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    number,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 20),
                  const SizedBox(
                    width: 200,
                    child: LinearProgressIndicator(
                      color: Colors.green,
                      backgroundColor: Color(0xFFE0E0E0),
                    ),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        if (dialogOpen) {
                          dialogOpen = false;
                          Navigator.of(ctx).pop();
                        }
                      },
                      icon: const Icon(Icons.call_end, size: 20),
                      label: const Text(
                        'Colgar',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      );
    }
  }

  String _relIcon(String? r) => switch (r) {
    'Mamá' => '👩',
    'Papá' => '👨',
    'Hermano/a' => '🧑‍🤝‍🧑',
    'Esposo/a' => '💑',
    'Novio/a' => '❤️',
    'Hijo/a' => '👶',
    'Tío/a' => '👤',
    'Abuelo/a' => '👴',
    'Primo/a' => '🤝',
    'Amigo/a' => '🤗',
    'Compañero/a' => '🚴',
    'Vecino/a' => '🏠',
    _ => '👤',
  };

  void _showAdd(BuildContext context) {
    final nameC = TextEditingController();
    final phoneC = TextEditingController();
    String? selRel;
    const rels = [
      'Mamá',
      'Papá',
      'Hermano/a',
      'Esposo/a',
      'Novio/a',
      'Hijo/a',
      'Tío/a',
      'Abuelo/a',
      'Primo/a',
      'Amigo/a',
      'Compañero/a',
      'Vecino/a',
      'Otro',
    ];

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setD) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Row(
            children: [
              Icon(Icons.person_add, color: ColorTokens.primary30),
              SizedBox(width: 8),
              Text('Agregar Contacto'),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameC,
                  decoration: InputDecoration(
                    labelText: 'Nombre',
                    prefixIcon: const Icon(Icons.person),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  textCapitalization: TextCapitalization.words,
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: phoneC,
                  decoration: InputDecoration(
                    labelText: 'Teléfono',
                    prefixIcon: const Icon(Icons.phone),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    hintText: 'Ej: 3001234567',
                  ),
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  initialValue: selRel,
                  decoration: InputDecoration(
                    labelText: 'Relación',
                    prefixIcon: const Icon(Icons.family_restroom),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  isExpanded: true,
                  items: rels
                      .map((r) => DropdownMenuItem(value: r, child: Text(r)))
                      .toList(),
                  onChanged: (v) => setD(() => selRel = v),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancelar'),
            ),
            ElevatedButton.icon(
              onPressed: () {
                if (nameC.text.trim().isEmpty || phoneC.text.trim().isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Nombre y teléfono son requeridos'),
                      backgroundColor: Colors.orange,
                    ),
                  );
                  return;
                }
                final uid = FirebaseAuth.instance.currentUser?.uid ?? '';
                context.read<EmergencyProvider>().addContact(
                  uid,
                  EmergencyContactEntity(
                    id: DateTime.now().millisecondsSinceEpoch.toString(),
                    name: nameC.text.trim(),
                    phone: phoneC.text.trim(),
                    relationship: selRel,
                  ),
                );
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('${nameC.text.trim()} agregado'),
                    backgroundColor: Colors.green[700],
                  ),
                );
              },
              icon: const Icon(Icons.save),
              label: const Text('Guardar'),
              style: ElevatedButton.styleFrom(
                backgroundColor: ColorTokens.primary30,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Tips de Seguridad ──────────────────────────────────
  Widget _buildTips() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.amber.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.amber.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.tips_and_updates, color: Colors.amber),
              SizedBox(width: 8),
              Text(
                'Tips de Seguridad',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _tip('Usa siempre casco y luces'),
          _tip('Comparte tu ubicación con alguien de confianza'),
          _tip('Lleva identificación y datos médicos'),
          _tip('Revisa tu bicicleta antes de salir'),
          _tip('Respeta las señales de tránsito'),
          _tip('Usa ropa reflectiva de noche'),
        ],
      ),
    );
  }

  Widget _tip(String t) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          const Icon(Icons.check_circle, size: 16, color: Colors.green),
          const SizedBox(width: 8),
          Expanded(child: Text(t, style: const TextStyle(fontSize: 13))),
        ],
      ),
    );
  }
}
