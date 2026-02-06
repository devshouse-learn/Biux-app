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

  // Función para formatear número de teléfono colombiano
  String _formatColombianPhoneNumber(String phoneNumber) {
    // Remover cualquier formato previo y espacios
    String cleanNumber = phoneNumber.replaceAll(RegExp(r'[^\d]'), '');

    // Si empieza con 57, removerlo (código de Colombia)
    if (cleanNumber.startsWith('57')) {
      cleanNumber = cleanNumber.substring(2);
    }

    // Asegurar que tenga 10 dígitos
    if (cleanNumber.length == 10) {
      // Formatear como xxx xxx xxxx
      return '${cleanNumber.substring(0, 3)} ${cleanNumber.substring(3, 6)} ${cleanNumber.substring(6)}';
    }

    // Si no tiene 10 dígitos, devolver tal como está
    return phoneNumber;
  }

  // Función para extraer y formatear teléfono desde UID
  String _getFormattedPhoneFromUID(String uid) {
    // En Firebase Auth con teléfono, el UID suele ser el número de teléfono
    // Formatear el UID como número de teléfono colombiano
    return _formatColombianPhoneNumber(uid);
  }

  void _loadUserDataOnce() {
    if (!_hasLoadedData) {
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        if (!mounted) return;

        final userProvider = Provider.of<UserProvider>(context, listen: false);
        final currentUser = FirebaseAuth.instance.currentUser;

        if (currentUser != null) {
          if (userProvider.user == null) {
            // Intentar cargar datos del usuario
            await userProvider.loadUserData();

            // Si después de cargar aún no existe, crear el usuario con teléfono formateado
            if (userProvider.user == null && mounted) {
              String formattedPhone = _getFormattedPhoneFromUID(
                currentUser.uid,
              );
              await userProvider.createUserIfNotExists(
                currentUser.uid,
                formattedPhone,
              );
            }
          }
        }
        if (mounted) {
          _hasLoadedData = true;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Theme.of(
        context,
      ).scaffoldBackgroundColor, // Respeta el tema
      child: Column(
        children: [
          // Header del drawer con información del usuario
          Consumer<UserProvider>(
            builder: (context, userProvider, child) {
              final user = userProvider.user;
              final currentUser = FirebaseAuth.instance.currentUser;

              // Debug: Imprimir información del usuario
              print('🐛 DEBUG - Usuario en drawer:');
              print('   - user: ${user?.name ?? 'null'}');
              print('   - photoUrl: ${user?.photoUrl ?? 'null'}');
              print('   - currentUser: ${currentUser?.uid ?? 'null'}');

              return UserAccountsDrawerHeader(
                accountName: Text(
                  user?.name ?? 'Usuario',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: ColorTokens.neutral100, // Texto blanco
                  ),
                ),
                accountEmail: Text(
                  (user?.email ?? currentUser?.phoneNumber ?? 'Sin email') +
                      ' ${user?.photoUrl != null ? '📸' : '🚫'}',
                  style: TextStyle(
                    color: ColorTokens.neutral100,
                  ), // Texto blanco
                ),
                currentAccountPicture:
                    user?.photoUrl != null && user!.photoUrl!.isNotEmpty
                    ? CachedNetworkImage(
                        imageUrl: user.photoUrl!,
                        imageBuilder: (context, imageProvider) => CircleAvatar(
                          backgroundColor: ColorTokens.neutral100,
                          backgroundImage: imageProvider,
                        ),
                        placeholder: (context, url) => CircleAvatar(
                          backgroundColor: ColorTokens.neutral100,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              ColorTokens.primary50,
                            ),
                          ),
                        ),
                        errorWidget: (context, url, error) {
                          print('🐛 Error cargando imagen de perfil: $error');
                          return CircleAvatar(
                            backgroundColor: ColorTokens.neutral100,
                            child: Icon(
                              Icons.person,
                              size: 40,
                              color: ColorTokens.neutral60,
                            ),
                          );
                        },
                      )
                    : CircleAvatar(
                        backgroundColor: ColorTokens.neutral100,
                        child: Icon(
                          Icons.person,
                          size: 40,
                          color: ColorTokens.neutral60,
                        ),
                      ),
                decoration: BoxDecoration(color: ColorTokens.primary30),
              );
            },
          ),

          // Lista de opciones del menú
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                ListTile(
                  leading: Icon(
                    Icons.person,
                    color: Theme.of(context).iconTheme.color,
                  ),
                  title: Text('Mi Perfil'),
                  onTap: () {
                    Navigator.pop(context);
                    context.go(AppRoutes.profile);
                  },
                ),
                Divider(),
                ListTile(
                  leading: Icon(Icons.settings, color: ColorTokens.neutral60),
                  title: Text('Configuración'),
                  onTap: () {
                    Navigator.pop(context);
                    context.go(AppRoutes.notificationSettings);
                  },
                ),
                ListTile(
                  leading: Icon(Icons.campaign, color: ColorTokens.neutral60),
                  title: Text('Promociones'),
                  onTap: () {
                    Navigator.pop(context);
                    context.push('/promotions');
                  },
                ),

                ListTile(
                  leading: Icon(
                    Icons.help_outline,
                    color: ColorTokens.neutral60,
                  ),
                  title: Text('Ayuda'),
                  onTap: () {
                    Navigator.pop(context);
                    context.go(AppRoutes.help);
                  },
                ),
              ],
            ),
          ),

          // Footer con versión y logout
          Container(
            padding: EdgeInsets.all(16),
            child: Column(
              children: [
                Divider(),
                Consumer<UserProvider>(
                  builder: (context, userProvider, child) {
                    return ListTile(
                      leading: Icon(Icons.logout, color: ColorTokens.error50),
                      title: Text(
                        'Cerrar Sesión',
                        style: TextStyle(color: ColorTokens.error50),
                      ),
                      onTap: () => _showLogoutDialog(context),
                    );
                  },
                ),
                SizedBox(height: 8),
                Text(
                  'BiUX v1.0.0',
                  style: TextStyle(color: ColorTokens.neutral60, fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Row(
            children: [
              Icon(Icons.logout, color: ColorTokens.error50),
              SizedBox(width: 8),
              Text('Cerrar Sesión'),
            ],
          ),
          content: Text('¿Estás seguro que deseas cerrar sesión?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: Text('Cancelar'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(dialogContext).pop();
                await _performLogout(context);
              },
              child: Text(
                'Cerrar Sesión',
                style: TextStyle(color: ColorTokens.error50),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _performLogout(BuildContext context) async {
    try {
      print('🔄 Iniciando logout desde drawer...');

      // Mostrar loading
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext loadingContext) {
          return PopScope(
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
                  SizedBox(width: 16),
                  Text('Cerrando sesión...'),
                ],
              ),
            ),
          );
        },
      );

      // Limpiar UserProvider
      try {
        final userProvider = Provider.of<UserProvider>(context, listen: false);
        await userProvider.signOut();
        print('✅ UserProvider limpiado');
      } catch (e) {
        print('⚠️ Error en UserProvider signOut: $e');
      }

      // Cerrar sesión en Firebase Auth (esto activará el guard del router)
      await FirebaseAuth.instance.signOut();
      print('✅ Firebase Auth limpiado');

      // Esperar un momento para que el router detecte el cambio
      await Future.delayed(Duration(milliseconds: 100));

      print('✅ Logout completado, el router redirigirá automáticamente');
    } catch (e) {
      print('❌ Error en logout desde drawer: $e');

      // En caso de error, cerrar loading y mostrar error
      if (mounted) {
        Navigator.of(context).pop(); // Cerrar loading dialog

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al cerrar sesión: ${e.toString()}'),
            backgroundColor: ColorTokens.error50,
          ),
        );
      }
    }
  }
}
