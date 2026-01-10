import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:biux/features/users/presentation/providers/user_provider.dart';
import 'package:biux/core/design_system/color_tokens.dart';

/// Widget de debug para diagnosticar problemas con la imagen de perfil
class ProfileImageDebugWidget extends StatefulWidget {
  @override
  _ProfileImageDebugWidgetState createState() =>
      _ProfileImageDebugWidgetState();
}

class _ProfileImageDebugWidgetState extends State<ProfileImageDebugWidget> {
  @override
  void initState() {
    super.initState();
    _loadDebugInfo();
  }

  void _loadDebugInfo() {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final currentUser = FirebaseAuth.instance.currentUser;

      print('🔍 DEBUG PROFILE IMAGE:');
      print('Current User UID: ${currentUser?.uid}');
      print('Current User Phone: ${currentUser?.phoneNumber}');
      print('UserProvider User: ${userProvider.user?.name}');
      print('UserProvider PhotoUrl: ${userProvider.user?.photoUrl}');
      print('UserProvider IsLoading: ${userProvider.isLoading}');
      print('UserProvider Error: ${userProvider.error}');

      if (userProvider.user == null && currentUser != null) {
        print('⚠️ Usuario no cargado, intentando cargar...');
        await userProvider.loadUserData();

        if (mounted) {
          setState(() {});
        }

        print('Después de cargar:');
        print('UserProvider User: ${userProvider.user?.name}');
        print('UserProvider PhotoUrl: ${userProvider.user?.photoUrl}');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<UserProvider>(
      builder: (context, userProvider, child) {
        final currentUser = FirebaseAuth.instance.currentUser;

        return Scaffold(
          appBar: AppBar(
            title: Text('Debug: Imagen de Perfil'),
            backgroundColor: ColorTokens.primary30,
            foregroundColor: Colors.white,
          ),
          body: Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Estado de autenticación
                Card(
                  child: ListTile(
                    title: Text('Firebase Auth'),
                    subtitle: Text(
                      currentUser != null
                          ? 'Autenticado: ${currentUser.uid}\nTeléfono: ${currentUser.phoneNumber ?? "N/A"}'
                          : 'No autenticado',
                    ),
                    leading: Icon(
                      currentUser != null ? Icons.check_circle : Icons.error,
                      color: currentUser != null ? Colors.green : Colors.red,
                    ),
                  ),
                ),

                SizedBox(height: 16),

                // Estado del UserProvider
                Card(
                  child: ListTile(
                    title: Text('UserProvider'),
                    subtitle: Text(
                      'Usuario: ${userProvider.user?.name ?? "null"}\n'
                      'Email: ${userProvider.user?.email ?? "null"}\n'
                      'Teléfono: ${userProvider.user?.phoneNumber ?? "null"}\n'
                      'PhotoUrl: ${userProvider.user?.photoUrl ?? "null"}\n'
                      'Cargando: ${userProvider.isLoading}\n'
                      'Error: ${userProvider.error ?? "ninguno"}',
                    ),
                    leading: Icon(
                      userProvider.user != null
                          ? Icons.person
                          : Icons.person_outline,
                      color: userProvider.user != null
                          ? Colors.green
                          : Colors.orange,
                    ),
                  ),
                ),

                SizedBox(height: 16),

                // Preview de la imagen
                if (userProvider.user?.photoUrl != null)
                  Card(
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Column(
                        children: [
                          Text('Preview de Imagen:'),
                          SizedBox(height: 8),
                          CircleAvatar(
                            radius: 50,
                            backgroundColor: ColorTokens.neutral20,
                            backgroundImage:
                                userProvider.user!.photoUrl!.isNotEmpty
                                ? NetworkImage(userProvider.user!.photoUrl!)
                                : null,
                            child: userProvider.user!.photoUrl!.isEmpty
                                ? Icon(Icons.person, size: 50)
                                : null,
                          ),
                          SizedBox(height: 8),
                          Text(
                            'URL: ${userProvider.user!.photoUrl}',
                            style: TextStyle(fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                  ),

                SizedBox(height: 16),

                // Botones de acción
                Row(
                  children: [
                    ElevatedButton(
                      onPressed: () async {
                        await userProvider.loadUserData();
                        setState(() {});
                      },
                      child: Text('Recargar Datos'),
                    ),
                    SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: () async {
                        if (currentUser != null) {
                          await userProvider.createUserIfNotExists(
                            currentUser.uid,
                            currentUser.phoneNumber ?? currentUser.uid,
                          );
                          setState(() {});
                        }
                      },
                      child: Text('Crear Usuario'),
                    ),
                  ],
                ),

                SizedBox(height: 16),

                // Botón para subir imagen
                ElevatedButton.icon(
                  onPressed: () async {
                    final result = await userProvider.uploadProfileImage();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          result
                              ? 'Imagen subida correctamente'
                              : 'Error subiendo imagen',
                        ),
                        backgroundColor: result ? Colors.green : Colors.red,
                      ),
                    );
                    setState(() {});
                  },
                  icon: Icon(Icons.camera_alt),
                  label: Text('Subir Nueva Imagen'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: ColorTokens.secondary50,
                    foregroundColor: Colors.white,
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
