import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:biux/core/design_system/color_tokens.dart';
import 'package:biux/core/design_system/locale_notifier.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:biux/core/design_system/design_system.dart';
import 'package:biux/core/config/router/app_routes.dart';
import 'package:biux/features/users/presentation/providers/user_provider.dart';
import 'package:biux/features/emergency/presentation/providers/emergency_provider.dart';

class AppDrawer extends StatefulWidget {
  @override
  _AppDrawerState createState() => _AppDrawerState();
}

class _AppDrawerState extends State<AppDrawer> {
  LocaleNotifier get l => Provider.of<LocaleNotifier>(context);

  bool _hasLoadedData = false;
  bool _sosHolding = false;
  double _sosProgress = 0;
  Timer? _sosTimer;
  static const int _sosHoldMs = 3000; // 3 segundos
  static const int _sosTickMs = 50;

  @override
  void initState() {
    super.initState();
    _loadUserDataOnce();
  }

  void _startSosHold() {
    setState(() {
      _sosHolding = true;
      _sosProgress = 0;
    });
    _sosTimer = Timer.periodic(Duration(milliseconds: _sosTickMs), (timer) {
      setState(() {
        _sosProgress += _sosTickMs / _sosHoldMs;
      });
      if (_sosProgress >= 1.0) {
        timer.cancel();
        _activateSOS();
      }
    });
  }

  void _cancelSosHold() {
    _sosTimer?.cancel();
    setState(() {
      _sosHolding = false;
      _sosProgress = 0;
    });
  }

  void _activateSOS() async {
    _sosTimer?.cancel();
    setState(() {
      _sosHolding = false;
      _sosProgress = 0;
    });
    final user = context.read<UserProvider>().user;
    final uid = FirebaseAuth.instance.currentUser?.uid ?? '';
    final emergencyProvider = context.read<EmergencyProvider>();

    // Navegar primero para que el usuario vea la pantalla
    Navigator.pop(context);
    context.push(AppRoutes.emergency);

    // Disparar SOS inmediatamente (sin countdown adicional)
    emergencyProvider.triggerSosImmediate(
      userId: uid,
      userName: user?.name ?? l.t('cyclist_label'),
    );
  }

  String _formatPhone(String phoneNumber) {
    String clean = phoneNumber.replaceAll(RegExp(r'[^\d]'), '');
    if (clean.startsWith('57')) clean = clean.substring(2);
    if (clean.length == 10) {
      return '${clean.substring(0, 3)} ${clean.substring(3, 6)} ${clean.substring(6)}';
    }
    return phoneNumber;
  }

  void _loadUserDataOnce() {
    if (!_hasLoadedData) {
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        if (!mounted) return;
        final up = Provider.of<UserProvider>(context, listen: false);
        final cu = FirebaseAuth.instance.currentUser;
        if (cu != null && up.user == null) {
          await up.loadUserData();
          if (up.user == null && mounted) {
            await up.createUserIfNotExists(cu.uid, _formatPhone(cu.uid));
          }
        }
        if (mounted) _hasLoadedData = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = Provider.of<LocaleNotifier>(context);
    return Drawer(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      child: Column(
        children: [
          // === HEADER ===
          Consumer<UserProvider>(
            builder: (context, up, _) {
              final user = up.user;
              final cu = FirebaseAuth.instance.currentUser;
              return Container(
                width: double.infinity,
                padding: EdgeInsets.only(
                  top: MediaQuery.of(context).padding.top + 20,
                  bottom: 20,
                  left: 20,
                  right: 20,
                ),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      ColorTokens.primary30,
                      ColorTokens.primary30.withValues(alpha: 0.85),
                    ],
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.3),
                              width: 2,
                            ),
                          ),
                          child:
                              user?.photoUrl != null &&
                                  user!.photoUrl!.isNotEmpty
                              ? CachedNetworkImage(
                                  imageUrl: user.photoUrl!,
                                  imageBuilder: (c, ip) => CircleAvatar(
                                    radius: 32,
                                    backgroundColor: Colors.white24,
                                    backgroundImage: ip,
                                  ),
                                  placeholder: (c, u) => const CircleAvatar(
                                    radius: 32,
                                    backgroundColor: Colors.white24,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  ),
                                  errorWidget: (c, u, e) => const CircleAvatar(
                                    radius: 32,
                                    backgroundColor: Colors.white24,
                                    child: Icon(
                                      Icons.person,
                                      size: 32,
                                      color: Colors.white70,
                                    ),
                                  ),
                                )
                              : const CircleAvatar(
                                  radius: 32,
                                  backgroundColor: Colors.white24,
                                  child: Icon(
                                    Icons.person,
                                    size: 32,
                                    color: Colors.white70,
                                  ),
                                ),
                        ),
                        const SizedBox(width: 10),
                        GestureDetector(
                          onTap: () {
                            Navigator.pop(context);
                            context.push(AppRoutes.notificationSettings);
                          },
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.15),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.settings_outlined,
                              color: Colors.white70,
                              size: 20,
                            ),
                          ),
                        ),
                        const Spacer(),
                        GestureDetector(
                          onTap: () {
                                Navigator.pop(context);
                                context.push(AppRoutes.emergency);
                              },
                              child: SizedBox(
                                width: 90,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 7,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.red,
                                    borderRadius: BorderRadius.circular(12),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.red.withValues(
                                          alpha: 0.4,
                                        ),
                                        blurRadius: 6,
                                        spreadRadius: 1,
                                      ),
                                    ],
                                  ),
                                  child: const Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.sos_rounded,
                                        color: Colors.white,
                                        size: 14,
                                      ),
                                      SizedBox(width: 5),
                                      Text(
                                        'SOS',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 12,
                                          fontWeight: FontWeight.w900,
                                          letterSpacing: 1,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                      ],
                    ),

                    SizedBox(height: 14),
                    // Nombre del usuario
                    Text(
                      user?.name ?? l.t('cyclist_label'),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    // Email/Teléfono
                    Text(
                      user?.email ?? cu?.phoneNumber ?? '',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.7),
                        fontSize: 13,
                      ),
                    ),

                    const SizedBox(height: 14),

                    // ── Botón SOS compacto ──
                    GestureDetector(
                      onLongPressStart: (_) => _startSosHold(),
                      onLongPressEnd: (_) => _cancelSosHold(),
                      onLongPressCancel: () => _cancelSosHold(),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          color: _sosHolding
                              ? Colors.red.withValues(alpha: 0.25)
                              : Colors.white.withValues(alpha: 0.1),
                          border: Border.all(
                            color: _sosHolding
                                ? Colors.red
                                : Colors.white.withValues(alpha: 0.25),
                            width: _sosHolding ? 2 : 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            // Icono SOS con progreso
                            Stack(
                              alignment: Alignment.center,
                              children: [
                                SizedBox(
                                  width: 36,
                                  height: 36,
                                  child: CircularProgressIndicator(
                                    value: _sosProgress,
                                    strokeWidth: 2.5,
                                    backgroundColor: Colors.red.withValues(
                                      alpha: 0.15,
                                    ),
                                    valueColor:
                                        const AlwaysStoppedAnimation<Color>(
                                          Colors.red,
                                        ),
                                  ),
                                ),
                                AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  width: 28,
                                  height: 28,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: _sosHolding
                                        ? Colors.red
                                        : Colors.red.withValues(alpha: 0.8),
                                    boxShadow: _sosHolding
                                        ? [
                                            BoxShadow(
                                              color: Colors.red.withValues(
                                                alpha: 0.5,
                                              ),
                                              blurRadius: 8,
                                              spreadRadius: 1,
                                            ),
                                          ]
                                        : [],
                                  ),
                                  child: Icon(
                                    Icons.sos_rounded,
                                    color: Colors.white,
                                    size: 16,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(width: 12),
                            // Texto informativo
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _sosHolding
                                        ? l.t('activating_sos')
                                        : l.t('emergency_sos'),
                                    style: TextStyle(
                                      color: _sosHolding
                                          ? Colors.red
                                          : Colors.white,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  SizedBox(height: 2),
                                  Text(
                                    _sosHolding
                                        ? l.t('release_to_cancel')
                                        : l.t('hold_3s'),
                                    style: TextStyle(
                                      color: _sosHolding
                                          ? Colors.red.withValues(alpha: 0.8)
                                          : Colors.white.withValues(
                                              alpha: 0.55,
                                            ),
                                      fontSize: 11,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            // Flecha indicadora
                            Icon(
                              _sosHolding
                                  ? Icons.radio_button_on
                                  : Icons.touch_app_rounded,
                              color: _sosHolding
                                  ? Colors.red
                                  : Colors.white.withValues(alpha: 0.4),
                              size: 18,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),

          // === MENU ===
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 8),
              children: [
                // ===== CICLISMO =====
                _sec(l.t('cycling').toUpperCase()),
                _item(
                  Icons.gps_fixed,
                  Colors.green,
                  l.t('record_ride'),
                  l.t('gps_realtime_tracking'),
                  () {
                    Navigator.pop(context);
                    context.push(AppRoutes.rideTracker);
                  },
                ),
                _item(
                  Icons.directions_bike_rounded,
                  Colors.green,
                  l.t('my_rides'),
                  l.t('ride_history'),
                  () {
                    Navigator.pop(context);
                    context.push(AppRoutes.rideTracker, extra: true);
                  },
                ),
                _item(
                  Icons.bar_chart_rounded,
                  Colors.blue,
                  l.t('my_stats'),
                  l.t('stats_subtitle'),
                  () {
                    Navigator.pop(context);
                    context.push(AppRoutes.cyclingStats);
                  },
                ),
                _item(
                  Icons.emoji_events,
                  Colors.amber,
                  l.t('achievements_title'),
                  l.t('achievements_subtitle'),
                  () {
                    Navigator.pop(context);
                    context.push(AppRoutes.achievements);
                  },
                ),

                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: Divider(height: 24),
                ),

                // ===== COMUNIDAD =====
                _sec(l.t('community').toUpperCase()),
                _item(
                  Icons.storefront,
                  Colors.deepPurple,
                  l.t('business_events'),
                  l.t('business_events_subtitle'),
                  () {
                    Navigator.pop(context);
                    context.push('/promotions');
                  },
                ),

                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: Divider(height: 24),
                ),

                // ===== SEGURIDAD =====
                _sec(l.t('safety_section').toUpperCase()),
                _item(
                  Icons.sos,
                  Colors.red,
                  l.t('emergency_sos'),
                  l.t('panic_button_contacts'),
                  () {
                    Navigator.pop(context);
                    context.push(AppRoutes.emergency);
                  },
                ),
                _item(
                  Icons.report_problem_outlined,
                  Colors.orange,
                  l.t('road_reports'),
                  l.t('road_reports_subtitle'),
                  () {
                    Navigator.pop(context);
                    context.push(AppRoutes.roadReports);
                  },
                ),
                _item(
                  Icons.car_crash,
                  Colors.deepOrange,
                  l.t('report_accident'),
                  l.t('report_incident'),
                  () {
                    Navigator.pop(context);
                    context.push('/accidents/report');
                  },
                ),
                _item(
                  Icons.warning_amber_rounded,
                  ColorTokens.error50,
                  l.t('stolen_bikes'),
                  l.t('public_database'),
                  () {
                    Navigator.pop(context);
                    context.push('/shop/stolen-bikes');
                  },
                ),
                Consumer<UserProvider>(
                  builder: (context, up, _) {
                    if (!(up.user?.isAdmin ?? false)) {
                      return const SizedBox.shrink();
                    }
                    return _item(
                      Icons.admin_panel_settings,
                      ColorTokens.secondary50,
                      l.t('alerts_dashboard'),
                      l.t('alerts_dashboard_subtitle'),
                      () {
                        Navigator.pop(context);
                        context.push('/shop/admin-alerts');
                      },
                    );
                  },
                ),

                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: Divider(height: 24),
                ),

                // ===== APRENDIZAJE =====
                _sec(l.t('learning').toUpperCase()),
                _item(
                  Icons.menu_book_rounded,
                  Colors.teal,
                  l.t('road_education'),
                  l.t('education_subtitle'),
                  () {
                    Navigator.pop(context);
                    context.push(AppRoutes.education);
                  },
                ),
                _item(
                  Icons.cloud_rounded,
                  Colors.lightBlue,
                  l.t('weather_title'),
                  l.t('weather_subtitle'),
                  () {
                    Navigator.pop(context);
                    context.push('/weather');
                  },
                ),
              ],
            ),
          ),

          // === FOOTER ===
          Container(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Colors.white12
                      : Colors.grey.shade200,
                ),
              ),
            ),
            child: Column(
              children: [
                ListTile(
                  dense: true,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: ColorTokens.error50.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      Icons.logout,
                      color: ColorTokens.error50,
                      size: 20,
                    ),
                  ),
                  title: Text(
                    l.t('close_session_drawer'),
                    style: TextStyle(
                      color: ColorTokens.error50,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                  onTap: () => _logoutDialog(context),
                ),
                const SizedBox(height: 8),
                Text(
                  'BiUX v1.0.0',
                  style: TextStyle(
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.white38
                        : ColorTokens.neutral60,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _sec(String t) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 4),
      child: Text(
        t,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: isDark ? Colors.white70 : ColorTokens.neutral50,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _item(
    IconData icon,
    Color color,
    String title,
    String sub,
    VoidCallback onTap,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return ListTile(
      dense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 2),
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: color.withValues(alpha: isDark ? 0.2 : 0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: isDark ? Colors.white : color, size: 20),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: isDark ? Colors.white : const Color(0xFF16242D),
        ),
      ),
      subtitle: Text(
        sub,
        style: TextStyle(
          fontSize: 11,
          color: isDark ? Colors.white54 : Colors.grey[500],
        ),
      ),
      trailing: Icon(
        Icons.chevron_right,
        size: 18,
        color: isDark ? Colors.white38 : Colors.grey[400],
      ),
      onTap: onTap,
    );
  }

  void _logoutDialog(BuildContext context) {
    final l = Provider.of<LocaleNotifier>(context, listen: false);
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dc) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.logout, color: ColorTokens.error50),
            SizedBox(width: 8),
            Text(l.t('close_session_drawer')),
          ],
        ),
        content: Text(l.t('confirm_close_session')),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dc).pop(),
            child: Text(l.t('cancel')),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(dc).pop();
              await _doLogout(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: ColorTokens.error50,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: Text(l.t('close_session_drawer')),
          ),
        ],
      ),
    );
  }

  Future<void> _doLogout(BuildContext context) async {
    final l = Provider.of<LocaleNotifier>(context, listen: false);
    try {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => PopScope(
          canPop: false,
          child: AlertDialog(
            content: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(
                    ColorTokens.secondary50,
                  ),
                ),
                const SizedBox(width: 16),
                const Text('Cerrando sesion...'),
              ],
            ),
          ),
        ),
      );
      try {
        final up = Provider.of<UserProvider>(context, listen: false);
        await up.signOut();
      } catch (_) {}
      await FirebaseAuth.instance.signOut();
      await Future.delayed(const Duration(milliseconds: 100));
    } catch (e) {
      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${l.t('error_generic')}: $e'),
            backgroundColor: ColorTokens.error50,
          ),
        );
      }
    }
  }
}
