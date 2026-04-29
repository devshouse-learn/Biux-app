import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:go_router/go_router.dart';
import 'package:biux/core/design_system/color_tokens.dart';
import 'package:biux/core/config/router/app_routes.dart';
import 'package:intl/intl.dart';
import 'package:biux/core/design_system/locale_notifier.dart';
import 'package:provider/provider.dart';

class ActiveSessionsScreen extends StatefulWidget {
  const ActiveSessionsScreen({super.key});

  @override
  State<ActiveSessionsScreen> createState() => _ActiveSessionsScreenState();
}

class _ActiveSessionsScreenState extends State<ActiveSessionsScreen> {
  LocaleNotifier get l => Provider.of<LocaleNotifier>(context);

  @override
  void initState() {
    super.initState();
    _registerCurrentSession();
  }

  /// Registra la sesión del dispositivo actual al abrir la pantalla
  Future<void> _registerCurrentSession() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    try {
      final platform = Platform.isIOS ? 'ios' : 'android';
      final now = DateTime.now();
      final phoneNumber =
          user.phoneNumber ??
          (await FirebaseFirestore.instance
                  .collection('users')
                  .doc(user.uid)
                  .get())
              .data()?['phoneNumber'] ??
          '';
      final sessionEntry = {
        'deviceName': Platform.isIOS ? 'iPhone' : 'Android',
        'platform': platform,
        'phoneNumber': phoneNumber,
        'lastActive': now.toIso8601String(),
        'timestamp': now.millisecondsSinceEpoch,
      };
      await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
        'sessions': FieldValue.arrayUnion([sessionEntry]),
      }, SetOptions(merge: true));
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid ?? '';
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF1A2530) : const Color(0xFFF5F7FA);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        title: Text(l.t('access_history')),
        backgroundColor: ColorTokens.primary30,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(uid)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: ColorTokens.primary30),
            );
          }

          final data = snapshot.data?.data() as Map<String, dynamic>?;
          final rawSessions = List<Map<String, dynamic>>.from(
            data?['sessions'] ?? [],
          );

          // Ordenar por timestamp descendente (más reciente primero)
          rawSessions.sort((a, b) {
            final ta = (a['timestamp'] as int?) ?? 0;
            final tb = (b['timestamp'] as int?) ?? 0;
            return tb.compareTo(ta);
          });

          return Column(
            children: [
              // Banner resumen
              Container(
                margin: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: ColorTokens.primary30.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: ColorTokens.primary30.withValues(alpha: 0.25),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.lock_person_rounded,
                      color: ColorTokens.primary30,
                      size: 28,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${rawSessions.length + 1} inicio(s) de sesión registrado(s)',
                            style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Dispositivos donde iniciaste sesión con tu número en Biux',
                            style: TextStyle(
                              fontSize: 12,
                              color: isDark
                                  ? Colors.grey[400]
                                  : Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              Expanded(
                child: ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  children: [
                    // Sesión actual (siempre arriba)
                    _SessionTile(
                      deviceName: 'Este dispositivo',
                      platform: 'android',
                      phoneNumber: data?['phoneNumber'] ?? '',
                      isCurrentDevice: true,
                      lastActive: 'Ahora',
                      isDark: isDark,
                      onRevoke: null,
                    ),
                    const SizedBox(height: 8),

                    // Sesiones registradas
                    ...rawSessions.map((s) {
                      final ts = (s['timestamp'] as int?) ?? 0;
                      final date = ts > 0
                          ? DateFormat(
                              'dd MMM yyyy · HH:mm',
                              'es',
                            ).format(DateTime.fromMillisecondsSinceEpoch(ts))
                          : (s['lastActive'] ?? '');
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: _SessionTile(
                          deviceName:
                              s['deviceName'] ?? 'Dispositivo desconocido',
                          platform: s['platform'] ?? 'android',
                          phoneNumber: s['phoneNumber'] ?? '',
                          isCurrentDevice: false,
                          lastActive: date,
                          isDark: isDark,
                          onRevoke: () async {
                            await FirebaseFirestore.instance
                                .collection('users')
                                .doc(uid)
                                .update({
                                  'sessions': FieldValue.arrayRemove([s]),
                                });
                          },
                        ),
                      );
                    }),

                    const SizedBox(height: 16),

                    // Info de Firebase Auth (metadatos del usuario)
                    _FirebaseAuthInfo(isDark: isDark),

                    SizedBox(height: 16),
                  ],
                ),
              ),

              // Botón cerrar todas las sesiones
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                child: SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: OutlinedButton.icon(
                    onPressed: () async {
                      final confirmed = await showDialog<bool>(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          title: Text(l.t('close_all_sessions')),
                          content: Text(
                            '¿Seguro que quieres cerrar sesión en todos los dispositivos?',
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(ctx, false),
                              child: Text(l.t('cancel')),
                            ),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red,
                              ),
                              onPressed: () => Navigator.pop(ctx, true),
                              child: Text(
                                l.t('close_sessions_btn'),
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                          ],
                        ),
                      );
                      if (confirmed == true && context.mounted) {
                        await FirebaseFirestore.instance
                            .collection('users')
                            .doc(uid)
                            .update({'sessions': []});
                        await FirebaseAuth.instance.signOut();
                        if (context.mounted) context.go(AppRoutes.login);
                      }
                    },
                    icon: const Icon(Icons.logout_rounded, color: Colors.red),
                    label: Text(
                      l.t('close_all_sessions'),
                      style: TextStyle(color: Colors.red),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.red),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _FirebaseAuthInfo extends StatelessWidget {
  final bool isDark;
  const _FirebaseAuthInfo({required this.isDark});

  @override
  Widget build(BuildContext context) {
    final l = Provider.of<LocaleNotifier>(context);
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return const SizedBox.shrink();
    final meta = user.metadata;
    final fmt = DateFormat('dd MMM yyyy · hh:mm a', 'es');
    final creation = meta.creationTime != null
        ? fmt.format(meta.creationTime!)
        : '—';
    final lastSign = meta.lastSignInTime != null
        ? fmt.format(meta.lastSignInTime!)
        : '—';
    final cardColor = isDark ? const Color(0xFF243040) : Colors.white;

    return Container(
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.07)
              : Colors.grey.withValues(alpha: 0.15),
        ),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.info_outline_rounded,
                size: 16,
                color: isDark ? Colors.grey[400] : Colors.grey[600],
              ),
              SizedBox(width: 6),
              Text(
                'Datos de tu cuenta Firebase',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.grey[400] : Colors.grey[600],
                ),
              ),
            ],
          ),
          SizedBox(height: 10),
          _InfoRow(
            isDark: isDark,
            label: l.t('account_created'),
            value: creation,
          ),
          SizedBox(height: 6),
          _InfoRow(isDark: isDark, label: l.t('last_access'), value: lastSign),
          if (user.phoneNumber?.isNotEmpty == true) ...[
            SizedBox(height: 6),
            _InfoRow(
              isDark: isDark,
              label: l.t('verified_number'),
              value: user.phoneNumber!,
            ),
          ],
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isDark;
  const _InfoRow({
    required this.label,
    required this.value,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$label: ',
          style: TextStyle(
            fontSize: 12,
            color: isDark ? Colors.grey[500] : Colors.grey[600],
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.grey[300] : Colors.grey[800],
            ),
          ),
        ),
      ],
    );
  }
}

class _SessionTile extends StatelessWidget {
  final String deviceName;
  final String platform;
  final String phoneNumber;
  final bool isCurrentDevice;
  final String lastActive;
  final bool isDark;
  final VoidCallback? onRevoke;

  const _SessionTile({
    required this.deviceName,
    required this.platform,
    required this.phoneNumber,
    required this.isCurrentDevice,
    required this.lastActive,
    required this.isDark,
    required this.onRevoke,
  });

  @override
  Widget build(BuildContext context) {
    final l = Provider.of<LocaleNotifier>(context);
    final cardColor = isDark ? const Color(0xFF243040) : Colors.white;
    final isIos = platform.toLowerCase().contains('ios');

    return Container(
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(14),
        border: isCurrentDevice
            ? Border.all(color: Colors.green.withValues(alpha: 0.5), width: 1.5)
            : Border.all(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.07)
                    : Colors.grey.withValues(alpha: 0.15),
              ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        leading: CircleAvatar(
          backgroundColor: isCurrentDevice
              ? Colors.green.withValues(alpha: 0.12)
              : ColorTokens.primary30.withValues(alpha: 0.10),
          child: Icon(
            isIos ? Icons.phone_iphone_rounded : Icons.phone_android_rounded,
            color: isCurrentDevice ? Colors.green : ColorTokens.primary30,
          ),
        ),
        title: Text(
          deviceName,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (phoneNumber.isNotEmpty)
              Text(
                phoneNumber,
                style: TextStyle(
                  fontSize: 12,
                  color: isDark ? Colors.grey[400] : Colors.grey[600],
                ),
              ),
            Text(
              isCurrentDevice
                  ? '✓ Sesión actual'
                  : 'Último acceso: $lastActive',
              style: TextStyle(
                fontSize: 12,
                color: isCurrentDevice
                    ? Colors.green
                    : (isDark ? Colors.grey[500] : Colors.grey[500]),
              ),
            ),
          ],
        ),
        trailing: isCurrentDevice
            ? const Icon(
                Icons.check_circle_rounded,
                color: Colors.green,
                size: 20,
              )
            : IconButton(
                icon: Icon(
                  Icons.delete_outline_rounded,
                  color: Colors.red,
                  size: 20,
                ),
                onPressed: onRevoke,
                tooltip: l.t('delete_record'),
              ),
      ),
    );
  }
}
