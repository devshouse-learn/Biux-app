import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../config/colors.dart';
import '../../../providers/meeting_point_provider.dart';
import '../../../providers/user_provider.dart';

class ProfileScreen extends StatelessWidget {
  // Función para formatear número de teléfono colombiano
  String _formatColombianPhoneNumber(String phoneNumber) {
    String cleanNumber = phoneNumber.replaceAll(RegExp(r'[^\d]'), '');

    if (cleanNumber.startsWith('57')) {
      cleanNumber = cleanNumber.substring(2);
    }

    if (cleanNumber.length == 10) {
      return '${cleanNumber.substring(0, 3)} ${cleanNumber.substring(3, 6)} ${cleanNumber.substring(6)}';
    }

    return phoneNumber;
  }

  String _getFormattedPhoneFromUID(String uid) {
    return _formatColombianPhoneNumber(uid);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<UserProvider>(
      builder: (context, userProvider, child) {
        return ProfileScreenContent(
          userProvider: userProvider,
          formatPhoneFunction: _getFormattedPhoneFromUID,
        );
      },
    );
  }
}

class ProfileScreenContent extends StatefulWidget {
  final UserProvider userProvider;
  final String Function(String) formatPhoneFunction;

  const ProfileScreenContent({
    Key? key,
    required this.userProvider,
    required this.formatPhoneFunction,
  }) : super(key: key);

  @override
  _ProfileScreenContentState createState() => _ProfileScreenContentState();
}

class _ProfileScreenContentState extends State<ProfileScreenContent> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _initializeUserData();
  }

  Future<void> _initializeUserData() async {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final currentUser = FirebaseAuth.instance.currentUser;

      if (currentUser != null) {
        await widget.userProvider.loadUserData();

        if (widget.userProvider.user == null) {
          String formattedPhone = widget.formatPhoneFunction(currentUser.uid);
          await widget.userProvider.createUserIfNotExists(
            currentUser.uid,
            formattedPhone,
          );
        }

        if (widget.userProvider.user != null && mounted) {
          setState(() {
            _nameController.text = widget.userProvider.user?.name ?? '';
            _emailController.text = widget.userProvider.user?.email ?? '';
          });
        }
      }
    });
  }

  Future<void> _updateProfile() async {
    bool success = await widget.userProvider.updateProfile(
      name: _nameController.text.trim(),
      email: _emailController.text.trim(),
    );

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(success
              ? 'Perfil actualizado correctamente'
              : widget.userProvider.error ?? 'Error al actualizar perfil'),
          backgroundColor: success ? AppColors.green : AppColors.red,
        ),
      );
    }
  }

  Future<void> _uploadImage() async {
    bool success = await widget.userProvider.uploadProfileImage();

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(success
              ? 'Imagen subida correctamente'
              : 'Error al subir la imagen'),
          backgroundColor: success ? AppColors.green : AppColors.red,
        ),
      );
    }
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text('Cerrar Sesión'),
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
                  print('🔄 Iniciando logout desde perfil...');

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
                  await widget.userProvider.signOut();
                  print('✅ UserProvider limpiado');

                  // Limpiar Firebase Auth (esto activa el refreshListenable del router)
                  await FirebaseAuth.instance.signOut();
                  print('✅ Firebase Auth limpiado');

                  // Esperar un momento para que el router detecte el cambio
                  await Future.delayed(Duration(milliseconds: 300));
                  print('✅ Logout completado');

                  // Cerrar loading
                  if (widgetContext.mounted) {
                    Navigator.of(widgetContext).pop();
                  }

                  // NO navegamos manualmente - el router detectará el cambio de auth automáticamente
                  // gracias al refreshListenable configurado en el router
                  print(
                      '✅ Logout completado, esperando redirección automática del router');
                } catch (e) {
                  print('❌ Error en logout desde perfil: $e');

                  // Cerrar loading
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

  void _showDeleteAccountDialog() {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text('Eliminar Cuenta'),
          content: Text(
              'Esta acción marcará tu cuenta para eliminación. El proceso será revisado por nuestro equipo. ¿Continuar?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: Text('Cancelar'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(dialogContext).pop();
                bool success =
                    await widget.userProvider.requestAccountDeletion();

                if (mounted && success) {
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
      body: widget.userProvider.isLoading
          ? Center(child: CircularProgressIndicator())
          : widget.userProvider.user == null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error, size: 64, color: AppColors.grey),
                      SizedBox(height: 16),
                      Text('Error cargando datos del perfil'),
                      SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () => widget.userProvider.loadUserData(),
                        child: Text('Reintentar'),
                      ),
                    ],
                  ),
                )
              : SingleChildScrollView(
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
                                widget.userProvider.user?.photoUrl != null &&
                                        widget.userProvider.user!.photoUrl!
                                            .isNotEmpty
                                    ? NetworkImage(
                                        widget.userProvider.user!.photoUrl!)
                                    : null,
                            child: widget.userProvider.user?.photoUrl == null ||
                                    widget.userProvider.user?.photoUrl
                                            ?.isEmpty ==
                                        true
                                ? Icon(Icons.camera_alt,
                                    size: 40, color: AppColors.grey600)
                                : null,
                          ),
                        ),
                      ),

                      SizedBox(height: 8),
                      Text(
                        'Toca para cambiar foto',
                        style:
                            TextStyle(color: AppColors.grey600, fontSize: 14),
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
                            text: widget.userProvider.user?.phoneNumber
                                        ?.isNotEmpty ==
                                    true
                                ? widget.userProvider.user!.phoneNumber
                                : widget.formatPhoneFunction(
                                    FirebaseAuth.instance.currentUser?.uid ??
                                        '')),
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
                      if (widget.userProvider.user?.isDeleting == true)
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
                                    if (widget.userProvider.user
                                            ?.deletionRequestDate !=
                                        null)
                                      Text(
                                        'Solicitado: ${widget.userProvider.user!.deletionRequestDate!.day}/${widget.userProvider.user!.deletionRequestDate!.month}/${widget.userProvider.user!.deletionRequestDate!.year}',
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
                      if (widget.userProvider.user?.isDeleting != true)
                        TextButton(
                          onPressed: _showDeleteAccountDialog,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.delete_forever, color: AppColors.red),
                              SizedBox(width: 8),
                              Text(
                                'Eliminar Cuenta',
                                style: TextStyle(
                                    color: AppColors.red, fontSize: 16),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
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
