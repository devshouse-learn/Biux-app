import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:go_router/go_router.dart';
import 'package:biux/core/design_system/color_tokens.dart';
import 'package:biux/core/config/router/app_routes.dart';

class ActiveSessionsScreen extends StatelessWidget {
  const ActiveSessionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid ?? '';
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sesiones activas'),
        backgroundColor: ColorTokens.primary30,
        foregroundColor: Colors.white,
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance.collection('users').doc(uid).snapshots(),
        builder: (context, snapshot) {
          final data = snapshot.data?.data() as Map<String, dynamic>?;
          final sessions = List<Map<String, dynamic>>.from(data?['sessions'] ?? []);
          return Column(children: [
            Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: ColorTokens.primary30.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(children: [
                const Icon(Icons.devices_rounded, color: ColorTokens.primary30),
                const SizedBox(width: 12),
                Text('\${sessions.length + 1} sesion(es) activa(s)',
                    style: const TextStyle(fontWeight: FontWeight.w700)),
              ]),
            ),
            const _SessionTile(
              deviceName: 'Este dispositivo', platform: 'ios',
              isCurrentDevice: true, lastActive: 'Ahora', onRevoke: null,
            ),
            ...sessions.map((s) => _SessionTile(
              deviceName: s['deviceName'] ?? 'Dispositivo desconocido',
              platform: s['platform'] ?? 'android',
              isCurrentDevice: false,
              lastActive: s['lastActive'] ?? '',
              onRevoke: () async {
                await FirebaseFirestore.instance.collection('users').doc(uid).update({
                  'sessions': FieldValue.arrayRemove([s]),
                });
              },
            )),
            const Spacer(),
            Padding(
              padding: const EdgeInsets.all(16),
              child: SizedBox(
                width: double.infinity, height: 52,
                child: OutlinedButton.icon(
                  onPressed: () async {
                    await FirebaseAuth.instance.signOut();
                    if (context.mounted) context.go(AppRoutes.login);
                  },
                  icon: const Icon(Icons.logout_rounded, color: Colors.red),
                  label: const Text('Cerrar todas las sesiones',
                      style: TextStyle(color: Colors.red)),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.red),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                ),
              ),
            ),
          ]);
        },
      ),
    );
  }
}

class _SessionTile extends StatelessWidget {
  final String deviceName;
  final String platform;
  final bool isCurrentDevice;
  final String lastActive;
  final VoidCallback? onRevoke;
  const _SessionTile({
    required this.deviceName, required this.platform,
    required this.isCurrentDevice, required this.lastActive,
    required this.onRevoke,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: isCurrentDevice
            ? Colors.green.withValues(alpha: 0.1)
            : Colors.grey.withValues(alpha: 0.1),
        child: Icon(
          platform.toLowerCase().contains('ios')
              ? Icons.phone_iphone_rounded : Icons.phone_android_rounded,
          color: isCurrentDevice ? Colors.green : Colors.grey,
        ),
      ),
      title: Text(deviceName, style: const TextStyle(fontWeight: FontWeight.w600)),
      subtitle: Text(
        isCurrentDevice ? 'Dispositivo actual' : 'Ultimo acceso: \$lastActive',
        style: TextStyle(fontSize: 12, color: isCurrentDevice ? Colors.green : Colors.grey),
      ),
      trailing: isCurrentDevice ? null : IconButton(
        icon: const Icon(Icons.close_rounded, color: Colors.red),
        onPressed: onRevoke, tooltip: 'Cerrar sesion',
      ),
    );
  }
}
