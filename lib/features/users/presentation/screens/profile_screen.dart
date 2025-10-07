import 'package:biux/features/maps/presentation/providers/meeting_point_provider.dart';
import 'package:biux/features/users/presentation/providers/user_provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import 'package:biux/core/design_system/color_tokens.dart';
import 'package:biux/shared/widgets/optimized_image_picker.dart';

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
          content: Text(
            success
                ? 'Perfil actualizado correctamente'
                : widget.userProvider.error ?? 'Error al actualizar perfil',
          ),
          backgroundColor: success
              ? ColorTokens.success40
              : ColorTokens.error50,
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

                try {
                  print('🔄 Iniciando logout desde perfil...');

                  // Detener la escucha del MeetingPointProvider si existe
                  try {
                    final meetingPointProvider =
                        Provider.of<MeetingPointProvider>(
                          widgetContext,
                          listen: false,
                        );
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
                    '✅ Logout completado, esperando redirección automática del router',
                  );
                } catch (e) {
                  print('❌ Error en logout desde perfil: $e');

                  // Cerrar loading
                  if (widgetContext.mounted) {
                    Navigator.of(widgetContext).pop();

                    // Mostrar error
                    ScaffoldMessenger.of(widgetContext).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Error al cerrar sesión: ${e.toString()}',
                        ),
                        backgroundColor: ColorTokens.error50,
                      ),
                    );
                  }
                }
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

  void _showDeleteAccountDialog() {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text('Eliminar Cuenta'),
          content: Text(
            'Esta acción marcará tu cuenta para eliminación. El proceso será revisado por nuestro equipo. ¿Continuar?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: Text('Cancelar'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(dialogContext).pop();
                bool success = await widget.userProvider
                    .requestAccountDeletion();

                if (mounted && success) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Solicitud de eliminación enviada'),
                      backgroundColor: ColorTokens.warning50,
                    ),
                  );
                }
              },
              child: Text(
                'Eliminar',
                style: TextStyle(color: ColorTokens.error50),
              ),
            ),
          ],
        );
      },
    );
  }

  // Función temporal para actualizar ciudades con departamentos

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Mi Perfil'),
        backgroundColor: ColorTokens.primary30,
        foregroundColor: ColorTokens.neutral100,
        actions: [
          IconButton(icon: Icon(Icons.logout), onPressed: _showLogoutDialog),
        ],
      ),
      body: widget.userProvider.isLoading
          ? Center(child: CircularProgressIndicator())
          : widget.userProvider.user == null
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error, size: 64, color: ColorTokens.neutral60),
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
                  // Foto de perfil optimizada
                  OptimizedImagePicker(
                    currentImageUrl: widget.userProvider.user?.photoUrl,
                    onImageSelected: (url) async {
                      if (url != null) {
                        // Actualizar la URL en Firestore directamente
                        try {
                          final currentUser = FirebaseAuth.instance.currentUser;
                          if (currentUser != null) {
                            // Actualizar en Firestore
                            await FirebaseFirestore.instance
                                .collection('users')
                                .doc(currentUser.uid)
                                .update({'photoUrl': url});

                            // Recargar los datos del usuario en el provider
                            await widget.userProvider.loadUserData();

                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Imagen de perfil actualizada'),
                                  backgroundColor: ColorTokens.success40,
                                ),
                              );
                            }
                          }
                        } catch (e) {
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Error actualizando imagen: $e'),
                                backgroundColor: ColorTokens.error50,
                              ),
                            );
                          }
                        }
                      }
                    },
                    imageType: 'avatar',
                    entityId:
                        FirebaseAuth.instance.currentUser?.uid ?? 'temp_user',
                    width: 120,
                    height: 120,
                    borderRadius: BorderRadius.circular(60),
                    placeholder: Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: ColorTokens.neutral20,
                        boxShadow: [
                          BoxShadow(
                            color: ColorTokens.neutral60.withValues(alpha: 0.3),
                            spreadRadius: 2,
                            blurRadius: 8,
                            offset: Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.camera_alt,
                        size: 40,
                        color: ColorTokens.neutral60,
                      ),
                    ),
                  ),

                  SizedBox(height: 8),
                  Text(
                    'Toca para cambiar foto',
                    style: TextStyle(
                      color: ColorTokens.neutral60,
                      fontSize: 14,
                    ),
                  ),

                  SizedBox(height: 24),

                  // Username section
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: ColorTokens.neutral10,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: ColorTokens.neutral30,
                        width: 1,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.alternate_email,
                              color: ColorTokens.primary50,
                              size: 20,
                            ),
                            SizedBox(width: 8),
                            Text(
                              'Username',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                                color: ColorTokens.neutral90,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                widget.userProvider.user?.username != null &&
                                        widget
                                            .userProvider
                                            .user!
                                            .username!
                                            .isNotEmpty
                                    ? '@${widget.userProvider.user!.username}'
                                    : 'No tienes username',
                                style: TextStyle(
                                  fontSize: 16,
                                  color:
                                      widget.userProvider.user?.username !=
                                              null &&
                                          widget
                                              .userProvider
                                              .user!
                                              .username!
                                              .isNotEmpty
                                      ? ColorTokens.neutral80
                                      : ColorTokens.neutral60,
                                  fontStyle:
                                      widget.userProvider.user?.username ==
                                              null ||
                                          widget
                                              .userProvider
                                              .user!
                                              .username!
                                              .isEmpty
                                      ? FontStyle.italic
                                      : FontStyle.normal,
                                ),
                              ),
                            ),
                            IconButton(
                              onPressed: () async {
                                await context.push('/edit-username');
                                // Refrescar datos después de editar el username
                                await widget.userProvider.loadUserData();
                              },
                              icon: Icon(
                                Icons.edit,
                                color: ColorTokens.primary50,
                                size: 20,
                              ),
                              tooltip: 'Editar username',
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 24),

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
                      text:
                          widget.userProvider.user?.phoneNumber.isNotEmpty ==
                              true
                          ? widget.userProvider.user!.phoneNumber
                          : widget.formatPhoneFunction(
                              FirebaseAuth.instance.currentUser?.uid ?? '',
                            ),
                    ),
                  ),

                  SizedBox(height: 32),

                  // Botón actualizar
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _updateProfile,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: ColorTokens.primary50,
                        foregroundColor: ColorTokens.neutral100,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: Text(
                        'Actualizar Perfil',
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  ),

                  SizedBox(height: 24),

                  // Estado de eliminación
                  if (widget.userProvider.user?.isDeleting == true)
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: ColorTokens.warning50.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.warning, color: ColorTokens.warning50),
                          SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Cuenta en proceso de eliminación',
                                  style: TextStyle(
                                    color: ColorTokens.warning50,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                if (widget
                                        .userProvider
                                        .user
                                        ?.deletionRequestDate !=
                                    null)
                                  Text(
                                    'Solicitado: ${widget.userProvider.user!.deletionRequestDate!.day}/${widget.userProvider.user!.deletionRequestDate!.month}/${widget.userProvider.user!.deletionRequestDate!.year}',
                                    style: TextStyle(
                                      color: ColorTokens.warning50,
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
                          Icon(
                            Icons.delete_forever,
                            color: ColorTokens.error50,
                          ),
                          SizedBox(width: 8),
                          Text(
                            'Eliminar Cuenta',
                            style: TextStyle(
                              color: ColorTokens.error50,
                              fontSize: 16,
                            ),
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
