import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../config/colors.dart';
import '../../providers/user_provider.dart';
import '../screens/user/profile_screen.dart';

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
                    // Ya estamos en el mapa, no hacer nada más
                  },
                ),
                ListTile(
                  leading: Icon(Icons.person, color: AppColors.blackPearl),
                  title: Text('Mi Perfil'),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => ProfileScreen()),
                    );
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
                        Navigator.pop(context);
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

  void _showLogoutDialog(BuildContext context, UserProvider userProvider) {
    showDialog(
      context: context,
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
            ElevatedButton(
              onPressed: () async {
                Navigator.of(dialogContext).pop();
                await userProvider.signOut();
                Navigator.of(context)
                    .pushNamedAndRemoveUntil('/login', (route) => false);
              },
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.red),
              child: Text('Cerrar Sesión',
                  style: TextStyle(color: AppColors.white)),
            ),
          ],
        );
      },
    );
  }
}
