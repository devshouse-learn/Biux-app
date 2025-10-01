import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../config/colors.dart';
import '../../../data/models/user_model.dart';
import '../../../providers/user_provider.dart';

class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();

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

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final currentUser = FirebaseAuth.instance.currentUser;

      if (currentUser != null) {
        // Intentar cargar datos del usuario
        await userProvider.loadUserData();

        // Si no existe, crear el usuario con el teléfono formateado desde UID
        if (userProvider.user == null) {
          String formattedPhone = _getFormattedPhoneFromUID(currentUser.uid);
          await userProvider.createUserIfNotExists(
            currentUser.uid,
            formattedPhone,
          );
        }

        // Actualizar los campos de texto con los datos cargados
        if (userProvider.user != null) {
          _nameController.text = userProvider.user?.name ?? '';
          _emailController.text = userProvider.user?.email ?? '';
        }
      }
    });
  }

  Future<void> _updateProfile() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);

    bool success = await userProvider.updateProfile(
      name: _nameController.text.trim(),
      email: _emailController.text.trim(),
    );

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Perfil actualizado correctamente'),
          backgroundColor: AppColors.green,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(userProvider.error ?? 'Error al actualizar perfil'),
          backgroundColor: AppColors.red,
        ),
      );
    }
  }

  Future<void> _uploadImage() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);

    bool success = await userProvider.uploadProfileImage();

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Imagen subida correctamente'),
          backgroundColor: AppColors.green,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al subir la imagen'),
          backgroundColor: AppColors.red,
        ),
      );
    }
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Cerrar Sesión'),
          content: Text('¿Estás seguro que deseas cerrar sesión?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Cancelar'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
                final userProvider =
                    Provider.of<UserProvider>(context, listen: false);
                await userProvider.signOut();
                Navigator.of(context)
                    .pushNamedAndRemoveUntil('/login', (route) => false);
              },
              child:
                  Text('Cerrar Sesión', style: TextStyle(color: AppColors.red)),
            ),
          ],
        );
      },
    );
  }

  void _showDeleteAccountDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Eliminar Cuenta'),
          content: Text(
              'Esta acción marcará tu cuenta para eliminación. El proceso será revisado por nuestro equipo. ¿Continuar?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Cancelar'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
                final userProvider =
                    Provider.of<UserProvider>(context, listen: false);
                bool success = await userProvider.requestAccountDeletion();

                if (success) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Solicitud de eliminación enviada'),
                      backgroundColor: AppColors.vividOrange,
                    ),
                  );
                }
              },
              child: Text('Eliminar', style: TextStyle(color: AppColors.red)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Mi Perfil'),
        backgroundColor: AppColors.blackPearl,
        foregroundColor: AppColors.white,
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: _showLogoutDialog,
          ),
        ],
      ),
      body: Consumer<UserProvider>(
        builder: (context, userProvider, child) {
          if (userProvider.isLoading) {
            return Center(child: CircularProgressIndicator());
          }

          UserModel? user = userProvider.user;

          if (user == null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error, size: 64, color: AppColors.grey),
                  SizedBox(height: 16),
                  Text('Error cargando datos del perfil'),
                  SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => userProvider.loadUserData(),
                    child: Text('Reintentar'),
                  ),
                ],
              ),
            );
          }

          return SingleChildScrollView(
            padding: EdgeInsets.all(16),
            child: Column(
              children: [
                // Foto de perfil
                GestureDetector(
                  onTap: _uploadImage,
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.grey.withOpacity(0.3),
                          spreadRadius: 2,
                          blurRadius: 8,
                          offset: Offset(0, 3),
                        ),
                      ],
                    ),
                    child: CircleAvatar(
                      radius: 60,
                      backgroundColor: AppColors.grey200,
                      backgroundImage:
                          user.photoUrl != null && user.photoUrl!.isNotEmpty
                              ? NetworkImage(user.photoUrl!)
                              : null,
                      child: user.photoUrl == null || user.photoUrl!.isEmpty
                          ? Icon(Icons.camera_alt,
                              size: 40, color: AppColors.grey600)
                          : null,
                    ),
                  ),
                ),

                SizedBox(height: 8),
                Text(
                  'Toca para cambiar foto',
                  style: TextStyle(color: AppColors.grey600, fontSize: 14),
                ),

                SizedBox(height: 32),

                // Campo nombre
                TextField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    labelText: 'Nombre',
                    prefixIcon: Icon(Icons.person),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),

                SizedBox(height: 16),

                // Campo email
                TextField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    labelText: 'Correo Electrónico',
                    prefixIcon: Icon(Icons.email),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  keyboardType: TextInputType.emailAddress,
                ),

                SizedBox(height: 16),

                // Teléfono (solo lectura)
                TextField(
                  decoration: InputDecoration(
                    labelText: 'Teléfono',
                    prefixIcon: Icon(Icons.phone),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  enabled: false,
                  controller: TextEditingController(
                      text: user.phoneNumber.isNotEmpty
                          ? user.phoneNumber
                          : _getFormattedPhoneFromUID(
                              FirebaseAuth.instance.currentUser?.uid ?? '')),
                ),

                SizedBox(height: 32),

                // Botón actualizar
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _updateProfile,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.blue,
                      foregroundColor: AppColors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: Text('Actualizar Perfil',
                        style: TextStyle(fontSize: 16)),
                  ),
                ),

                SizedBox(height: 24),

                // Estado de eliminación
                if (user.isDeleting)
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.vividOrange.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.warning, color: AppColors.vividOrange),
                        SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Cuenta en proceso de eliminación',
                                style: TextStyle(
                                  color: AppColors.vividOrange,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              if (user.deletionRequestDate != null)
                                Text(
                                  'Solicitado: ${user.deletionRequestDate!.day}/${user.deletionRequestDate!.month}/${user.deletionRequestDate!.year}',
                                  style: TextStyle(
                                    color: AppColors.vividOrange,
                                    fontSize: 12,
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                SizedBox(height: 32),

                // Botón eliminar cuenta
                if (!user.isDeleting)
                  TextButton(
                    onPressed: _showDeleteAccountDialog,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.delete_forever, color: AppColors.red),
                        SizedBox(width: 8),
                        Text(
                          'Eliminar Cuenta',
                          style: TextStyle(color: AppColors.red, fontSize: 16),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }
}
