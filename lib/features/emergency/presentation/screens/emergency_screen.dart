import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:biux/core/design_system/color_tokens.dart';
import 'package:biux/core/design_system/locale_notifier.dart';
import 'package:biux/features/emergency/presentation/providers/emergency_provider.dart';
import 'package:biux/features/emergency/domain/entities/emergency_contact_entity.dart';
import 'package:biux/features/users/presentation/providers/user_provider.dart';
import 'package:biux/features/accidents/domain/entities/accident_entity.dart';
import 'package:biux/features/accidents/presentation/screens/accidents_list_screen.dart';
import 'package:biux/features/accidents/presentation/screens/accident_report_screen.dart';
import 'package:biux/features/accidents/presentation/screens/accident_detail_screen.dart';
import 'package:biux/core/design_system/locale_notifier.dart';

class EmergencyScreen extends StatefulWidget {
  const EmergencyScreen({Key? key}) : super(key: key);
  @override
  State<EmergencyScreen> createState() => _EmergencyScreenState();
}

class _EmergencyScreenState extends State<EmergencyScreen> {
  LocaleNotifier get l => Provider.of<LocaleNotifier>(context);

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
            SizedBox(height: 12),
            TextButton(
              onPressed: () => p.cancelSOS(),
              child: Text(
                l.t('cancel_alert'),
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
    final l = Provider.of<LocaleNotifier>(context, listen: false);
    try {
      final pos = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );
      final uid = FirebaseAuth.instance.currentUser?.uid ?? '';
      final name = context.read<UserProvider>().user?.name ?? l.t('cyclist_label');
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
          SnackBar(
            content: Text('${l.t('error_generic')}: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // ══════════════════════════════════════════════════════════
  // ── Accidentes Recientes (NUEVO) ─────────────────────────
  // ══════════════════════════════════════════════════════════
  Widget _buildRecentAccidents(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDark ? const Color(0xFF1E2A32) : Colors.white;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.08), blurRadius: 8),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Row(
                  children: [
                    const Icon(Icons.car_crash, color: Colors.red, size: 22),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        'Accidentes Recientes',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              TextButton.icon(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const AccidentReportScreen(),
                  ),
                ),
                icon: Icon(Icons.add, size: 16),
                label: Text(l.t('report_action')),
                style: TextButton.styleFrom(
                  foregroundColor: Colors.red[700],
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('accidents')
                .orderBy('createdAt', descending: true)
                .limit(20)
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
              final accidents = docs
                  .map(
                    (d) => AccidentEntity.fromMap(
                      d.id,
                      d.data() as Map<String, dynamic>,
                    ),
                  )
                  .where((a) => !a.resolved)
                  .take(5)
                  .toList();

              if (accidents.isEmpty) {
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDark ? const Color(0xFF1E2A32) : Colors.white;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.08), blurRadius: 8),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Números de Emergencia',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
          const SizedBox(height: 12),
          _eTile(
            emoji: '🚑',
            service: 'Ambulancia / SAMU',
            description: 'Emergencias médicas y accidentes',
            number: '123',
            color: Colors.red,
          ),
          _eTile(
            emoji: '🚔',
            service: 'Policía Nacional',
            description: 'Seguridad, delitos y orden público',
            number: '112',
            color: Colors.blue,
          ),
          _eTile(
            emoji: '🚒',
            service: 'Bomberos',
            description: 'Incendios, rescates y materiales peligrosos',
            number: '119',
            color: Colors.orange,
          ),
          _eTile(
            emoji: '🏥',
            service: 'Cruz Roja',
            description: 'Primeros auxilios y asistencia humanitaria',
            number: '132',
            color: Colors.red[800]!,
          ),
          _eTile(
            emoji: '🛡️',
            service: 'Defensa Civil',
            description: 'Desastres naturales y emergencias civiles',
            number: '144',
            color: Colors.green[700]!,
          ),
          const SizedBox(height: 12),
          // Advertencia
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.amber.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.amber.withValues(alpha: 0.4)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('⚠️', style: TextStyle(fontSize: 18)),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Llama solo en caso de emergencia real',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                          color: isDark ? Colors.amber[200] : Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Realizar llamadas falsas a servicios de emergencia es una infracción legal que puede acarrear multas o sanciones penales, y desvía recursos que podrían salvar vidas reales.',
                        style: TextStyle(
                          fontSize: 11,
                          color: isDark ? Colors.white60 : Colors.black54,
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
    );
  }

  Widget _eTile({
    required String emoji,
    required String service,
    required String description,
    required String number,
    required Color color,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: Text(emoji, style: const TextStyle(fontSize: 20)),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  service,
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 11,
                    color: isDark ? Colors.white54 : Colors.grey[500],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          ElevatedButton.icon(
            onPressed: () => _makeCall(number, service),
            icon: const Icon(Icons.phone, size: 15),
            label: Text(
              number,
              style: const TextStyle(
                fontWeight: FontWeight.w800,
                letterSpacing: 0.5,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: color,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
          ),
        ],
      ),
    );
  }

  // ── Contactos de Emergencia ────────────────────────────
  Widget _buildContacts(BuildContext context, EmergencyProvider p) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDark ? const Color(0xFF1E2A32) : Colors.white;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.08), blurRadius: 8),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  l.t('my_emergency_contacts'),
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 12),
              GestureDetector(
                onTap: () => _showAdd(context),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black87,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.add, color: Colors.white, size: 16),
                      SizedBox(width: 4),
                      Text(
                        l.t('add_label'),
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          if (p.contacts.isEmpty)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'Agrega contactos de emergencia para que sean notificados en caso de alerta',
                style: TextStyle(color: isDark ? Colors.white54 : Colors.grey),
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
    final uri = Uri(scheme: 'tel', path: number);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
      return;
    }
    // Fallback: intentar de todas formas con launchUrl
    try {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
      return;
    } catch (_) {}
    // Solo si definitivamente no se puede, mostrar dialog
    if (true) {
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
            backgroundColor: Theme.of(context).dialogTheme.backgroundColor,
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
          title: Row(
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
                    labelText: l.t('name_label'),
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
                    prefixIcon: Icon(Icons.phone),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    hintText: l.t('phone_example'),
                  ),
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  initialValue: selRel,
                  decoration: InputDecoration(
                    labelText: 'Relación',
                    prefixIcon: Icon(Icons.family_restroom),
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
              child: Text(l.t('cancel')),
            ),
            ElevatedButton.icon(
              onPressed: () {
                if (nameC.text.trim().isEmpty || phoneC.text.trim().isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(l.t('name_phone_required')),
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
              icon: Icon(Icons.save),
              label: Text(l.t('save')),
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
