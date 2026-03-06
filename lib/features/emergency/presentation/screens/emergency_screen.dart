import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:biux/core/design_system/color_tokens.dart';
import 'package:biux/core/design_system/locale_notifier.dart';
import 'package:biux/features/emergency/presentation/providers/emergency_provider.dart';
import 'package:biux/features/emergency/domain/entities/emergency_contact_entity.dart';
import 'package:biux/features/users/presentation/providers/user_provider.dart';

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
    final l = Provider.of<LocaleNotifier>(context, listen: false);
    return Scaffold(
      backgroundColor: ColorTokens.neutral99,
      appBar: AppBar(
        title: Text(l.t('emergency_sos')),
        backgroundColor: Colors.red[700],
        foregroundColor: Colors.white,
      ),
      body: Consumer<EmergencyProvider>(
        builder: (context, p, _) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _buildSOS(context, p),
                const SizedBox(height: 24),
                _buildQuickEmergency(),
                const SizedBox(height: 24),
                _buildContacts(context, p),
                const SizedBox(height: 16),
                _buildTips(),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSOS(BuildContext context, EmergencyProvider p) {
    final l = Provider.of<LocaleNotifier>(context, listen: false);
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
            p.sosActive ? l.t('alert_active') : l.t('emergency_button'),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            p.sosActive ? l.t('contacts_notified') : l.t('hold_to_send_sos'),
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
              child: Text(
                l.t('cancel_alert'),
                style: const TextStyle(
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
      final name = context.read<UserProvider>().user?.name ?? l.t('cyclist');
      await p.sendSOS(
        userId: uid,
        userName: name,
        latitude: pos.latitude,
        longitude: pos.longitude,
        message: l.t('cyclist_emergency'),
      );
      if (context.mounted)
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l.t('sos_alert_sent')),
            backgroundColor: Colors.red,
          ),
        );
    } catch (e) {
      if (context.mounted)
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
    }
  }

  Widget _buildQuickEmergency() {
    final l = Provider.of<LocaleNotifier>(context, listen: false);
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
          Text(
            l.t('emergency_numbers'),
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          _eTile('🚑 ${l.t('emergencies')}', '123', Colors.red),
          _eTile('🚔 ${l.t('police')}', '112', Colors.blue),
          _eTile('🚒 ${l.t('fire_department')}', '119', Colors.orange),
          _eTile('🏥 ${l.t('red_cross')}', '132', Colors.red[800]!),
        ],
      ),
    );
  }

  Widget _eTile(String t, String n, Color c) => ListTile(
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

  Widget _buildContacts(BuildContext context, EmergencyProvider p) {
    final l = Provider.of<LocaleNotifier>(context, listen: false);
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
              Text(
                l.t('my_emergency_contacts'),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
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
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                l.t('add_emergency_contacts_hint'),
                style: const TextStyle(color: Colors.grey),
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
    final l = Provider.of<LocaleNotifier>(context, listen: false);
    final uri = Uri.parse('tel://\$number');
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
                  Text(
                    l.t('calling'),
                    style: const TextStyle(
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
                      label: Text(
                        l.t('hang_up'),
                        style: const TextStyle(
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
    'Hermano/a' => '🧑‍��‍🧑',
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
    final l = Provider.of<LocaleNotifier>(context, listen: false);
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
              const Icon(Icons.person_add, color: ColorTokens.primary30),
              const SizedBox(width: 8),
              Text(l.t('add_contact')),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameC,
                  decoration: InputDecoration(
                    labelText: l.t('name'),
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
                    labelText: l.t('phone'),
                    prefixIcon: const Icon(Icons.phone),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    hintText: l.t('phone_hint'),
                  ),
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  initialValue: selRel,
                  decoration: InputDecoration(
                    labelText: l.t('relationship'),
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
                    content: Text('${nameC.text.trim()} ${l.t('added')}'),
                    backgroundColor: Colors.green[700],
                  ),
                );
              },
              icon: const Icon(Icons.save),
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

  Widget _buildTips() {
    final l = Provider.of<LocaleNotifier>(context, listen: false);
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
          Row(
            children: [
              const Icon(Icons.tips_and_updates, color: Colors.amber),
              const SizedBox(width: 8),
              Text(
                l.t('safety_tips'),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _tip(l.t('tip_helmet_lights')),
          _tip(l.t('tip_share_location')),
          _tip(l.t('tip_carry_id')),
          _tip(l.t('tip_check_bike')),
          _tip(l.t('tip_traffic_signs')),
          _tip(l.t('tip_reflective_clothing')),
        ],
      ),
    );
  }

  Widget _tip(String t) => Padding(
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
