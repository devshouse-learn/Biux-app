import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:biux/core/design_system/color_tokens.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:biux/core/design_system/design_system.dart';
import '../../core/config/router/app_routes.dart';
import '../../features/users/presentation/providers/user_provider.dart';

class AppDrawer extends StatefulWidget {
  @override
  _AppDrawerState createState() => _AppDrawerState();
}

class _AppDrawerState extends State<AppDrawer> {
  bool _hasLoadedData = false;

  @override
  void initState() {
    super.initState();
    _loadUserDataOnce();
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
    return Drawer(
      backgroundColor: Colors.white,
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
                        const Spacer(),
                        Material(
                          color: Colors.white.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(12),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(12),
                            onTap: () {
                              Navigator.pop(context);
                              context.push('/profile');
                            },
                            child: const Padding(
                              padding: EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.edit,
                                    size: 14,
                                    color: Colors.white70,
                                  ),
                                  SizedBox(width: 6),
                                  Text(
                                    'Editar',
                                    style: TextStyle(
                                      color: Colors.white70,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Text(
                      user?.name ?? 'Ciclista',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      user?.email ?? cu?.phoneNumber ?? '',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.7),
                        fontSize: 13,
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
                _sec('CICLISMO'),
                _item(
                  Icons.gps_fixed,
                  Colors.green,
                  'Grabar Rodada',
                  'GPS tracking en tiempo real',
                  () {
                    Navigator.pop(context);
                    context.push(AppRoutes.rideTracker);
                  },
                ),
                _item(
                  Icons.bar_chart_rounded,
                  Colors.blue,
                  'Mis Estadisticas',
                  'Km, velocidad, nivel y ranking',
                  () {
                    Navigator.pop(context);
                    context.push(AppRoutes.cyclingStats);
                  },
                ),
                _item(
                  Icons.emoji_events,
                  Colors.amber,
                  'Logros',
                  'Medallas y desafios desbloqueados',
                  () {
                    Navigator.pop(context);
                    context.push(AppRoutes.achievements);
                  },
                ),

                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: Divider(height: 24),
                ),

                // ===== COMUNIDAD =====
                _sec('COMUNIDAD'),
                _item(
                  Icons.chat_bubble_outline,
                  ColorTokens.primary30,
                  'Mensajes',
                  'Chats con otros ciclistas',
                  () {
                    Navigator.pop(context);
                    context.push(AppRoutes.chatList);
                  },
                ),
                _item(
                  Icons.storefront,
                  Colors.deepPurple,
                  'Negocios y Eventos',
                  'Publicidad y eventos con registro',
                  () {
                    Navigator.pop(context);
                    context.push('/promotions');
                  },
                ),

                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: Divider(height: 24),
                ),

                // ===== SEGURIDAD =====
                _sec('SEGURIDAD'),
                _item(
                  Icons.sos,
                  Colors.red,
                  'Emergencia SOS',
                  'Boton de panico y contactos',
                  () {
                    Navigator.pop(context);
                    context.push(AppRoutes.emergency);
                  },
                ),
                _item(
                  Icons.report_problem_outlined,
                  Colors.orange,
                  'Reportes Viales',
                  'Baches, obras y peligros en ruta',
                  () {
                    Navigator.pop(context);
                    context.push(AppRoutes.roadReports);
                  },
                ),
                _item(
                  Icons.car_crash,
                  Colors.deepOrange,
                  'Reportar Accidente',
                  'Reporta un incidente vial',
                  () {
                    Navigator.pop(context);
                    context.push('/accidents/report');
                  },
                ),
                _item(
                  Icons.warning_amber_rounded,
                  ColorTokens.error50,
                  'Bicicletas Robadas',
                  'Base de datos publica',
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
                      'Dashboard Alertas',
                      'Intentos venta bicis robadas',
                      () {
                        Navigator.pop(context);
                        context.push('/shop/admin-alerts');
                      },
                    );
                  },
                ),

                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: Divider(height: 24),
                ),

                // ===== APRENDIZAJE =====
                _sec('APRENDIZAJE'),
                _item(
                  Icons.menu_book_rounded,
                  Colors.teal,
                  'Educacion Vial',
                  'Seguridad, mecanica y consejos',
                  () {
                    Navigator.pop(context);
                    context.push(AppRoutes.education);
                  },
                ),
                _item(
                  Icons.cloud_rounded,
                  Colors.lightBlue,
                  'Clima',
                  'Condiciones para rodar hoy',
                  () {
                    Navigator.pop(context);
                    context.push('/weather');
                  },
                ),

                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: Divider(height: 24),
                ),

                // ===== AJUSTES =====
                _sec('AJUSTES'),
                _item(
                  Icons.settings_outlined,
                  ColorTokens.neutral50,
                  'Configuracion',
                  'Notificaciones y preferencias',
                  () {
                    Navigator.pop(context);
                    context.push(AppRoutes.notificationSettings);
                  },
                ),
                _item(
                  Icons.help_outline,
                  ColorTokens.neutral50,
                  'Centro de Ayuda',
                  'Soporte y preguntas frecuentes',
                  () {
                    Navigator.pop(context);
                    context.push(AppRoutes.help);
                  },
                ),
              ],
            ),
          ),

          // === FOOTER ===
          Container(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            decoration: BoxDecoration(
              border: Border(top: BorderSide(color: Colors.grey.shade200)),
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
                    'Cerrar Sesion',
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
                  style: TextStyle(color: ColorTokens.neutral60, fontSize: 11),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _sec(String t) => Padding(
    padding: const EdgeInsets.fromLTRB(20, 8, 20, 4),
    child: Text(
      t,
      style: TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w700,
        color: ColorTokens.neutral50,
        letterSpacing: 1.2,
      ),
    ),
  );

  Widget _item(
    IconData icon,
    Color color,
    String title,
    String sub,
    VoidCallback onTap,
  ) {
    return ListTile(
      dense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 2),
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: color, size: 20),
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: Color(0xFF16242D),
        ),
      ),
      subtitle: Text(
        sub,
        style: TextStyle(fontSize: 11, color: Colors.grey[500]),
      ),
      trailing: Icon(Icons.chevron_right, size: 18, color: Colors.grey[400]),
      onTap: onTap,
    );
  }

  void _logoutDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dc) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.logout, color: ColorTokens.error50),
            const SizedBox(width: 8),
            const Text('Cerrar Sesion'),
          ],
        ),
        content: const Text('Estas seguro que deseas cerrar sesion?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dc).pop(),
            child: const Text('Cancelar'),
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
            child: const Text('Cerrar Sesion'),
          ),
        ],
      ),
    );
  }

  Future<void> _doLogout(BuildContext context) async {
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
