import 'package:biux/features/maps/presentation/providers/meeting_point_provider.dart';
import 'package:biux/features/users/presentation/providers/user_provider.dart';
import 'package:biux/features/users/data/models/user.dart';
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
        print('🔄 Cargando datos del usuario...');
        await widget.userProvider.loadUserData();

        if (widget.userProvider.user == null) {
          print('⚠️ Usuario no existe, creando...');
          String formattedPhone = widget.formatPhoneFunction(currentUser.uid);
          await widget.userProvider.createUserIfNotExists(
            currentUser.uid,
            formattedPhone,
          );
          // Recargar datos después de crear el usuario
          await widget.userProvider.loadUserData();
        }

        if (widget.userProvider.user != null && mounted) {
          print('✅ Inicializando campos con datos del usuario:');
          print('   Nombre: "${widget.userProvider.user?.name ?? ''}"');
          print('   Email: "${widget.userProvider.user?.email ?? ''}"');
          setState(() {
            _nameController.text = widget.userProvider.user?.name ?? '';
            _emailController.text = widget.userProvider.user?.email ?? '';
          });
        }
      }
    });
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

  Widget _buildStatCard({required String value, required String label}) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: ColorTokens.primary30,
          ),
        ),
        SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: ColorTokens.neutral70,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCardButton({
    required String value,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: ColorTokens.primary30,
            ),
          ),
          SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: ColorTokens.neutral70,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  void _showFollowersModal(BuildContext context) {
    final followers = widget.userProvider.user?.followers ?? {};

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        if (followers.isEmpty) {
          return Padding(
            padding: const EdgeInsets.all(20),
            child: SizedBox(
              height: 200,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.people_outline,
                    size: 48,
                    color: ColorTokens.neutral60,
                  ),
                  const SizedBox(height: 12),
                  const Text('Sin seguidores aún'),
                ],
              ),
            ),
          );
        }

        return DraggableScrollableSheet(
          expand: false,
          builder: (context, scrollController) {
            return ListView(
              controller: scrollController,
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    'Seguidores (${followers.length})',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                ...followers.entries.map((entry) {
                  final userId = entry.key;
                  return FutureBuilder<BiuxUser?>(
                    future: _getUserById(userId),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const ListTile(title: Text('Cargando...'));
                      }

                      if (!snapshot.hasData || snapshot.data == null) {
                        return const SizedBox.shrink();
                      }

                      final user = snapshot.data!;
                      return ListTile(
                        leading: CircleAvatar(
                          backgroundImage: user.photo.isNotEmpty
                              ? NetworkImage(user.photo)
                              : null,
                          child: user.photo.isEmpty
                              ? const Icon(Icons.person)
                              : null,
                        ),
                        title: Text(
                          user.fullName.isNotEmpty
                              ? user.fullName
                              : user.userName,
                        ),
                        subtitle: Text('@${user.userName}'),
                        onTap: () {
                          context.pop();
                          context.push('/public-profile/${user.id}');
                        },
                      );
                    },
                  );
                }),
              ],
            );
          },
        );
      },
    );
  }

  void _showFollowingModal(BuildContext context) {
    final following = widget.userProvider.user?.following ?? {};

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        if (following.isEmpty) {
          return Padding(
            padding: const EdgeInsets.all(20),
            child: SizedBox(
              height: 200,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.people_outline,
                    size: 48,
                    color: ColorTokens.neutral60,
                  ),
                  const SizedBox(height: 12),
                  const Text('No sigue a nadie aún'),
                ],
              ),
            ),
          );
        }

        return DraggableScrollableSheet(
          expand: false,
          builder: (context, scrollController) {
            return ListView(
              controller: scrollController,
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    'Siguiendo (${following.length})',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                ...following.entries.map((entry) {
                  final userId = entry.key;
                  return FutureBuilder<BiuxUser?>(
                    future: _getUserById(userId),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const ListTile(title: Text('Cargando...'));
                      }

                      if (!snapshot.hasData || snapshot.data == null) {
                        return const SizedBox.shrink();
                      }

                      final user = snapshot.data!;
                      return ListTile(
                        leading: CircleAvatar(
                          backgroundImage: user.photo.isNotEmpty
                              ? NetworkImage(user.photo)
                              : null,
                          child: user.photo.isEmpty
                              ? const Icon(Icons.person)
                              : null,
                        ),
                        title: Text(
                          user.fullName.isNotEmpty
                              ? user.fullName
                              : user.userName,
                        ),
                        subtitle: Text('@${user.userName}'),
                        onTap: () {
                          context.pop();
                          context.push('/public-profile/${user.id}');
                        },
                      );
                    },
                  );
                }),
              ],
            );
          },
        );
      },
    );
  }

  Future<BiuxUser?> _getUserById(String userId) async {
    try {
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();

      if (userDoc.exists) {
        return BiuxUser.fromJsonMap(userDoc.data() as Map<String, dynamic>);
      }
    } catch (e) {
      print('Error cargando usuario $userId: $e');
    }
    return null;
  }

  void _showEditProfileDialog() {
    final nameController = TextEditingController(
      text: widget.userProvider.user?.name ?? '',
    );
    final usernameController = TextEditingController(
      text: widget.userProvider.user?.username ?? '',
    );
    final descriptionController = TextEditingController(
      text: widget.userProvider.user?.description ?? '',
    );

    String? selectedProfileImageUrl;
    String? selectedCoverImageUrl;

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Row(
                children: [
                  Icon(Icons.edit, color: ColorTokens.primary30),
                  SizedBox(width: 8),
                  Text('Editar Perfil'),
                ],
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ========== FOTO DE PERFIL ==========
                    Text(
                      'Foto de Perfil',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                    SizedBox(height: 12),
                    Center(
                      child: OptimizedImagePicker(
                        currentImageUrl: selectedProfileImageUrl != null
                            ? (selectedProfileImageUrl?.isEmpty ?? false)
                                  ? null // Cadena vacía = sin foto
                                  : selectedProfileImageUrl // Tiene URL
                            : widget
                                  .userProvider
                                  .user
                                  ?.photoUrl, // Sin cambios = usa actual
                        onImageSelected: (url) {
                          setState(() {
                            selectedProfileImageUrl = url;
                          });
                        },
                        imageType: 'avatar',
                        entityId:
                            FirebaseAuth.instance.currentUser?.uid ??
                            'temp_user',
                        width: 100,
                        height: 100,
                        borderRadius: BorderRadius.circular(50),
                        placeholder: Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: ColorTokens.neutral20,
                            border: Border.all(
                              color: ColorTokens.neutral100,
                              width: 2,
                            ),
                          ),
                          child: Icon(
                            Icons.camera_alt,
                            size: 40,
                            color: ColorTokens.neutral60,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 20),

                    // ========== FOTO DE PORTADA ==========
                    Text(
                      'Foto de Portada',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                    SizedBox(height: 12),
                    Center(
                      child: OptimizedImagePicker(
                        currentImageUrl: selectedCoverImageUrl != null
                            ? (selectedCoverImageUrl?.isEmpty ?? false)
                                  ? null // Cadena vacía = sin foto
                                  : selectedCoverImageUrl // Tiene URL
                            : widget
                                  .userProvider
                                  .user
                                  ?.coverPhotoUrl, // Sin cambios = usa actual
                        onImageSelected: (url) {
                          setState(() {
                            selectedCoverImageUrl = url;
                          });
                        },
                        imageType: 'cover',
                        entityId:
                            FirebaseAuth.instance.currentUser?.uid ??
                            'temp_user',
                        width: 200,
                        height: 100,
                        borderRadius: BorderRadius.circular(8),
                        placeholder: Container(
                          width: 200,
                          height: 100,
                          decoration: BoxDecoration(
                            color: ColorTokens.neutral20,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: ColorTokens.neutral100,
                              width: 2,
                            ),
                          ),
                          child: Icon(
                            Icons.image,
                            size: 40,
                            color: ColorTokens.neutral60,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 20),

                    // ========== NOMBRE ==========
                    Text(
                      'Nombre',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                    SizedBox(height: 8),
                    TextField(
                      controller: nameController,
                      decoration: InputDecoration(
                        hintText: 'Tu nombre completo',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 10,
                        ),
                      ),
                    ),
                    SizedBox(height: 16),

                    // ========== USERNAME ==========
                    Text(
                      'Nombre de Usuario',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                    SizedBox(height: 8),
                    TextField(
                      controller: usernameController,
                      decoration: InputDecoration(
                        hintText: 'tu_nombre_usuario',
                        prefixText: '@',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 10,
                        ),
                      ),
                    ),
                    SizedBox(height: 16),

                    // ========== DESCRIPCIÓN ==========
                    Text(
                      'Descripción / Bio',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                    SizedBox(height: 8),
                    TextField(
                      controller: descriptionController,
                      decoration: InputDecoration(
                        hintText: 'Cuéntales sobre ti',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 10,
                        ),
                      ),
                      maxLines: 4,
                      maxLength: 150,
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    nameController.dispose();
                    usernameController.dispose();
                    descriptionController.dispose();
                    Navigator.of(dialogContext).pop();
                  },
                  child: Text('Cancelar'),
                ),
                ElevatedButton.icon(
                  onPressed: () async {
                    // Guardar referencias antes de disposer
                    final name = nameController.text.trim();
                    final username = usernameController.text.trim();
                    final description = descriptionController.text.trim();
                    final profileUrl = selectedProfileImageUrl;
                    final coverUrl = selectedCoverImageUrl;
                    final email = widget.userProvider.user?.email ?? '';

                    // Actualizar todos los campos de perfil
                    bool success = await widget.userProvider.updateProfile(
                      name: name,
                      username: username,
                      description: description,
                      photoUrl: profileUrl,
                      coverPhotoUrl: coverUrl,
                      email: email,
                    );

                    // Cerrar el diálogo primero
                    if (mounted) {
                      Navigator.of(dialogContext).pop();
                    }

                    // Disposer los controladores DESPUÉS de cerrar el diálogo
                    Future.delayed(Duration(milliseconds: 100), () {
                      nameController.dispose();
                      usernameController.dispose();
                      descriptionController.dispose();
                    });

                    // Mostrar resultado usando context principal
                    if (mounted) {
                      if (success) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Perfil actualizado correctamente'),
                            backgroundColor: ColorTokens.success40,
                          ),
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Error: ${widget.userProvider.error ?? "Intenta nuevamente"}',
                            ),
                            backgroundColor: ColorTokens.error50,
                          ),
                        );
                      }
                    }
                  },
                  icon: Icon(Icons.check),
                  label: Text('Guardar'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: ColorTokens.primary30,
                    foregroundColor: ColorTokens.neutral100,
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // Función temporal para actualizar ciudades con departamentos

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            if (Navigator.of(context).canPop()) {
              Navigator.of(context).pop();
            } else {
              context.go('/');
            }
          },
          tooltip: 'Volver',
        ),
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
              child: Column(
                children: [
                  // ========== SECCIÓN DE PERFIL TIPO INSTAGRAM ==========
                  // Foto de portada (cover photo)
                  Container(
                    width: double.infinity,
                    height: 150,
                    decoration: BoxDecoration(
                      color: ColorTokens.primary30,
                      gradient: LinearGradient(
                        colors: [ColorTokens.primary30, ColorTokens.primary50],
                      ),
                    ),
                    child: Stack(
                      children: [
                        // Imagen de portada del usuario o gradiente por defecto
                        Positioned.fill(
                          child:
                              widget.userProvider.user?.coverPhotoUrl != null &&
                                  widget
                                      .userProvider
                                      .user!
                                      .coverPhotoUrl!
                                      .isNotEmpty
                              ? Image.network(
                                  widget.userProvider.user!.coverPhotoUrl!,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) =>
                                      Opacity(
                                        opacity: 0.1,
                                        child: Image.network(
                                          'https://images.unsplash.com/photo-1506794778202-cad84cf45f1d?w=600',
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                )
                              : Opacity(
                                  opacity: 0.1,
                                  child: Image.network(
                                    'https://images.unsplash.com/photo-1506794778202-cad84cf45f1d?w=600',
                                    fit: BoxFit.cover,
                                    errorBuilder:
                                        (context, error, stackTrace) =>
                                            SizedBox.shrink(),
                                  ),
                                ),
                        ),
                        // Botón configuración en esquina superior derecha
                        Positioned(
                          top: 12,
                          right: 12,
                          child: IconButton(
                            icon: Icon(
                              Icons.settings,
                              color: ColorTokens.neutral100,
                              size: 24,
                            ),
                            onPressed: () {
                              context.push('/account-settings');
                            },
                            tooltip: 'Configuración de cuenta',
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Foto de perfil con overlap
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Transform.translate(
                      offset: const Offset(0, -50),
                      child: Column(
                        children: [
                          // Foto de perfil
                          Container(
                            width: 110,
                            height: 110,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: ColorTokens.neutral20,
                              border: Border.all(
                                color: ColorTokens.neutral100,
                                width: 3,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: ColorTokens.neutral60.withValues(
                                    alpha: 0.3,
                                  ),
                                  spreadRadius: 2,
                                  blurRadius: 8,
                                  offset: Offset(0, 3),
                                ),
                              ],
                            ),
                            child:
                                widget.userProvider.user?.photoUrl != null &&
                                    widget
                                        .userProvider
                                        .user!
                                        .photoUrl!
                                        .isNotEmpty
                                ? ClipOval(
                                    child: Image.network(
                                      widget.userProvider.user!.photoUrl!,
                                      fit: BoxFit.cover,
                                      errorBuilder:
                                          (context, error, stackTrace) => Icon(
                                            Icons.person,
                                            size: 50,
                                            color: ColorTokens.neutral60,
                                          ),
                                    ),
                                  )
                                : Icon(
                                    Icons.person,
                                    size: 50,
                                    color: ColorTokens.neutral60,
                                  ),
                          ),

                          SizedBox(height: 12),

                          // Username y nombre
                          Text(
                            widget.userProvider.user?.username != null &&
                                    widget
                                        .userProvider
                                        .user!
                                        .username!
                                        .isNotEmpty
                                ? '@${widget.userProvider.user!.username}'
                                : 'usuario',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: ColorTokens.neutral90,
                            ),
                          ),

                          SizedBox(height: 4),

                          Text(
                            widget.userProvider.user?.name ?? 'Usuario',
                            style: TextStyle(
                              fontSize: 14,
                              color: ColorTokens.neutral70,
                              fontWeight: FontWeight.w500,
                            ),
                          ),

                          SizedBox(height: 16),

                          // Estadísticas (Seguidores, Seguidos)
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              _buildStatCardButton(
                                value:
                                    (widget
                                                .userProvider
                                                .user
                                                ?.followers
                                                ?.length ??
                                            0)
                                        .toString(),
                                label: 'Seguidores',
                                onTap: () => _showFollowersModal(context),
                              ),
                              _buildStatCardButton(
                                value:
                                    (widget
                                                .userProvider
                                                .user
                                                ?.following
                                                ?.length ??
                                            0)
                                        .toString(),
                                label: 'Siguiendo',
                                onTap: () => _showFollowingModal(context),
                              ),
                            ],
                          ),

                          SizedBox(height: 16),

                          // Botón Editar Perfil
                          SizedBox(
                            width: double.infinity,
                            child: OutlinedButton.icon(
                              onPressed: () {
                                _showEditProfileDialog();
                              },
                              icon: Icon(Icons.edit, size: 18),
                              label: Text('Editar Perfil'),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: ColorTokens.primary30,
                                side: BorderSide(
                                  color: ColorTokens.primary30,
                                  width: 1.5,
                                ),
                                padding: EdgeInsets.symmetric(vertical: 10),
                              ),
                            ),
                          ),

                          SizedBox(height: 16),
                        ],
                      ),
                    ),
                  ),

                  // ========== SECCIÓN DE DESCRIPCIÓN BIO ==========
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Descripción/Bio
                        Container(
                          width: double.infinity,
                          padding: EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: ColorTokens.neutral10,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: ColorTokens.neutral30,
                              width: 1,
                            ),
                          ),
                          child: Text(
                            widget.userProvider.user?.description != null &&
                                    widget
                                        .userProvider
                                        .user!
                                        .description!
                                        .isNotEmpty
                                ? widget.userProvider.user!.description!
                                : 'Toca el botón "Editar Perfil" para agregar una descripción',
                            style: TextStyle(
                              fontSize: 14,
                              color:
                                  widget.userProvider.user?.description !=
                                          null &&
                                      widget
                                          .userProvider
                                          .user!
                                          .description!
                                          .isNotEmpty
                                  ? ColorTokens.neutral80
                                  : ColorTokens.neutral60,
                              fontStyle:
                                  widget.userProvider.user?.description ==
                                          null ||
                                      widget
                                          .userProvider
                                          .user!
                                          .description!
                                          .isEmpty
                                  ? FontStyle.italic
                                  : FontStyle.normal,
                            ),
                          ),
                        ),

                        SizedBox(height: 24),

                        // ========== SECCIÓN DE PUBLICACIONES ==========
                        Text(
                          'Publicaciones',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: ColorTokens.neutral90,
                          ),
                        ),

                        SizedBox(height: 16),

                        // Grid de publicaciones (placeholder)
                        Container(
                          width: double.infinity,
                          padding: EdgeInsets.symmetric(vertical: 40),
                          decoration: BoxDecoration(
                            color: ColorTokens.neutral10,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: ColorTokens.neutral30,
                              width: 1,
                            ),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.image_not_supported,
                                size: 48,
                                color: ColorTokens.neutral60,
                              ),
                              SizedBox(height: 12),
                              Text(
                                'Sin publicaciones aún',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: ColorTokens.neutral70,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              SizedBox(height: 8),
                              Text(
                                'Comienza a compartir tus historias',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: ColorTokens.neutral60,
                                ),
                              ),
                            ],
                          ),
                        ),

                        SizedBox(height: 32),

                        // Botón Cerrar Sesión
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: _showLogoutDialog,
                            icon: Icon(Icons.logout),
                            label: Text('Cerrar Sesión'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: ColorTokens.neutral90,
                              foregroundColor: ColorTokens.neutral100,
                              padding: EdgeInsets.symmetric(vertical: 12),
                            ),
                          ),
                        ),

                        SizedBox(height: 16),

                        // Botón Eliminar Cuenta
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton.icon(
                            onPressed: _showDeleteAccountDialog,
                            icon: Icon(Icons.delete_forever),
                            label: Text('Eliminar Cuenta'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: ColorTokens.error50,
                              side: BorderSide(
                                color: ColorTokens.error50,
                                width: 1.5,
                              ),
                              padding: EdgeInsets.symmetric(vertical: 12),
                            ),
                          ),
                        ),

                        SizedBox(height: 24),
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
