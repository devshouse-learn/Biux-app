import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../config/colors.dart';
import '../../config/router/app_routes.dart';
import '../../providers/meeting_point_provider.dart';
import '../../providers/user_provider.dart';

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
        final userProvider = Provider.of<UserProvider>(context, listen: false);
        final currentUser = FirebaseAuth.instance.currentUser;

        if (currentUser != null) {
          if (userProvider.user == null) {
            // Intentar cargar datos del usuario
            await userProvider.loadUserData();

            // Si después de cargar aún no existe, crear el usuario con teléfono formateado
            if (userProvider.user == null) {
              String formattedPhone =
                  _getFormattedPhoneFromUID(currentUser.uid);
              await userProvider.createUserIfNotExists(
                currentUser.uid,
                formattedPhone,
              );
            }
          }
        }
        _hasLoadedData = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: AppColors.white, // Drawer con fondo blanco
      child: Column(
        children: [
          // Header del drawer con información del usuario
          Consumer<UserProvider>(
            builder: (context, userProvider, child) {
              final user = userProvider.user;
              final currentUser = FirebaseAuth.instance.currentUser;

              return UserAccountsDrawerHeader(
                accountName: Text(
                  user?.name ?? 'Usuario',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppColors.white, // Texto blanco
                  ),
                ),
                accountEmail: Text(
                  user?.email ?? currentUser?.phoneNumber ?? 'Sin email',
                  style: TextStyle(color: AppColors.white), // Texto blanco
                ),
                currentAccountPicture: CircleAvatar(
                  backgroundColor: AppColors.white,
                  backgroundImage:
                      user?.photoUrl != null && user!.photoUrl!.isNotEmpty
                          ? NetworkImage(user.photoUrl!)
                          : null,
                  child: user?.photoUrl == null ||
                          user?.photoUrl?.isEmpty == true
                      ? Icon(Icons.person, size: 40, color: AppColors.grey600)
                      : null,
                ),
                decoration: BoxDecoration(
                  color: AppColors.blackPearl,
                ),
              );
            },
          ),

          // Lista de opciones del menú
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                ListTile(
                  leading: Icon(Icons.map, color: AppColors.blackPearl),
                  title: Text('Mapa'),
                  onTap: () {
                    Navigator.pop(context);
                    context.go(AppRoutes.map);
                  },
                ),
                ListTile(
                  leading: Icon(Icons.person, color: AppColors.blackPearl),
                  title: Text('Mi Perfil'),
                  onTap: () {
                    Navigator.pop(context);
                    context.go(AppRoutes.profile);
                  },
                ),
                ListTile(
                  leading:
                      Icon(Icons.directions_bike, color: AppColors.blackPearl),
                  title: Text('Mis Rutas'),
                  onTap: () {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Funcionalidad próximamente')),
                    );
                  },
                ),
                ListTile(
                  leading: Icon(Icons.group, color: AppColors.blackPearl),
                  title: Text('Mis Grupos'),
                  onTap: () {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Funcionalidad próximamente')),
                    );
                  },
                ),
                Divider(),
                ListTile(
                  leading: Icon(Icons.settings, color: AppColors.grey600),
                  title: Text('Configuración'),
                  onTap: () {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Funcionalidad próximamente')),
                    );
                  },
                ),
                ListTile(
                  leading: Icon(Icons.help_outline, color: AppColors.grey600),
                  title: Text('Ayuda'),
                  onTap: () {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Funcionalidad próximamente')),
                    );
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
                      leading: Icon(Icons.logout, color: AppColors.red),
                      title: Text('Cerrar Sesión',
                          style: TextStyle(color: AppColors.red)),
                      onTap: () {
                        // NO cerrar el drawer aquí - se cierra después del logout
                        _showLogoutDialog(context, userProvider);
                      },
                    );
                  },
                ),
                SizedBox(height: 8),
                Text(
                  'BiUX v1.0.0',
                  style: TextStyle(
                    color: AppColors.grey600,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Método de logout más directo y robusto
  Future<void> _performLogout(BuildContext context) async {
    try {
      print('🔄 Iniciando logout...');

      // 1. Detener listeners de Firestore inmediatamente
      try {
        final meetingPointProvider =
            Provider.of<MeetingPointProvider>(context, listen: false);
        meetingPointProvider.stopListening();
        print('✅ MeetingPointProvider detenido');
      } catch (e) {
        print('⚠️ Error deteniendo MeetingPointProvider: $e');
      }

      // 2. Limpiar UserProvider primero
      try {
        final userProvider = Provider.of<UserProvider>(context, listen: false);
        await userProvider.signOut();
        print('✅ UserProvider limpiado');
      } catch (e) {
        print('⚠️ Error en UserProvider signOut: $e');
      }

      // 3. Limpiar Firebase Auth (esto triggers el refreshListenable del router)
      await FirebaseAuth.instance.signOut();
      print('✅ Firebase Auth limpiado');

      // 4. Esperar un momento para que el router detecte el cambio
      await Future.delayed(Duration(milliseconds: 300));
      print('✅ Logout completado');

      return; // Éxito
    } catch (e) {
      print('❌ Error durante logout: $e');
      throw e; // Re-lanzar para manejo en UI
    }
  }

  void _showLogoutDialog(BuildContext context, UserProvider userProvider) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Row(
            children: [
              Icon(Icons.logout, color: AppColors.red),
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
                // Capturar el contexto del widget antes de cualquier operación asíncrona
                final widgetContext = context;

                // Cerrar diálogo de confirmación
                Navigator.of(dialogContext).pop();

                // Verificar que el contexto sigue siendo válido antes de mostrar el loading
                if (!widgetContext.mounted) {
                  print('❌ Contexto inválido, abortando logout');
                  return;
                }

                // Mostrar diálogo de loading usando el contexto capturado
                showDialog(
                  context: widgetContext,
                  barrierDismissible: false,
                  builder: (BuildContext loadingContext) {
                    return WillPopScope(
                      onWillPop: () async => false,
                      child: AlertDialog(
                        content: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(
                                  AppColors.strongCyan),
                            ),
                            SizedBox(width: 16),
                            Text('Cerrando sesión...'),
                          ],
                        ),
                      ),
                    );
                  },
                );

                try {
                  print('🔄 Iniciando logout desde drawer...');

                  // Detener la escucha del MeetingPointProvider si existe
                  try {
                    final meetingPointProvider =
                        Provider.of<MeetingPointProvider>(widgetContext,
                            listen: false);
                    meetingPointProvider.stopListening();
                    print('✅ MeetingPointProvider detenido');
                  } catch (e) {
                    print('⚠️ Error deteniendo MeetingPointProvider: $e');
                  }

                  // Limpiar UserProvider primero
                  await userProvider.signOut();
                  print('✅ UserProvider limpiado');

                  // Limpiar Firebase Auth (esto activa el refreshListenable del router)
                  await FirebaseAuth.instance.signOut();
                  print('✅ Firebase Auth limpiado');

                  // Esperar un momento para que el router detecte el cambio
                  await Future.delayed(Duration(milliseconds: 300));
                  print('✅ Logout completado');

                  // NO hacer pop del loading dialog - el router redirigirá automáticamente
                  // y eso cerrará todos los diálogos abiertos
                  print(
                      '✅ Logout completado, esperando redirección automática del router');
                } catch (e) {
                  print('❌ Error en logout desde drawer: $e');

                  // Solo en caso de error, cerrar loading dialog y mostrar error
                  if (widgetContext.mounted) {
                    Navigator.of(widgetContext).pop();

                    // Mostrar error
                    ScaffoldMessenger.of(widgetContext).showSnackBar(
                      SnackBar(
                        content:
                            Text('Error al cerrar sesión: ${e.toString()}'),
                        backgroundColor: AppColors.red,
                      ),
                    );
                  }
                }
              },
              child:
                  Text('Cerrar Sesión', style: TextStyle(color: AppColors.red)),
            ),
          ],
        );
      },
    );
  }
}
