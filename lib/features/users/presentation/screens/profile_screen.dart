import 'package:biux/features/maps/presentation/providers/meeting_point_provider.dart';
import 'package:biux/features/users/presentation/providers/user_provider.dart';
import 'package:biux/features/users/data/models/user.dart';
import 'package:biux/features/experiences/presentation/providers/experience_classic_provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import 'package:biux/core/design_system/color_tokens.dart';
import 'package:biux/core/config/styles.dart';
import 'package:biux/shared/widgets/optimized_image_picker.dart';
import 'package:biux/shared/services/optimized_cache_manager.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:biux/features/experiences/data/repositories/experience_repository_impl.dart';
import 'package:biux/features/experiences/domain/entities/experience_entity.dart';
import 'package:biux/features/experiences/presentation/screens/create_experience_screen.dart';

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
  final Set<String> _failedImageIds = {};
  late Future<dynamic> _experiencesFuture;
  int _postCount = 0;
  int _lastKnownFeedLength = -1;
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _experiencesFuture = _loadExperiences();
    _initializeUserData();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Detectar si el feed cambió (nuevo post creado) para refrescar experiencias
    final feedLength = context.watch<ExperienceProvider>().experiences.length;
    if (_lastKnownFeedLength >= 0 && feedLength != _lastKnownFeedLength) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _refreshExperiences();
      });
    }
    _lastKnownFeedLength = feedLength;
  }

  Future<dynamic> _loadExperiences() {
    return ExperienceRepositoryImpl().getUserExperiences(
      FirebaseAuth.instance.currentUser?.uid ?? '',
    );
  }

  void _refreshExperiences() {
    setState(() {
      _experiencesFuture = _loadExperiences();
    });
  }

  void _showExperienceMenu(BuildContext context, dynamic experience) {
    showModalBottomSheet(
      context: context,
      backgroundColor: ColorTokens.neutral20,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: ColorTokens.neutral60,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            ListTile(
              leading: Icon(Icons.edit_outlined, color: ColorTokens.primary50),
              title: Text(
                'Editar publicación',
                style: TextStyle(color: ColorTokens.neutral100),
              ),
              onTap: () {
                Navigator.pop(ctx);
                context.push('/edit-post/${experience.id}', extra: experience);
              },
            ),
            ListTile(
              leading: Icon(Icons.delete_outline, color: ColorTokens.error50),
              title: Text(
                'Eliminar publicación',
                style: TextStyle(color: ColorTokens.error50),
              ),
              onTap: () {
                Navigator.pop(ctx);
                showDialog(
                  context: context,
                  builder: (dialogCtx) => AlertDialog(
                    backgroundColor: ColorTokens.neutral20,
                    title: Text(
                      '¿Eliminar publicación?',
                      style: TextStyle(color: ColorTokens.neutral100),
                    ),
                    content: Text(
                      'Esta acción no se puede deshacer',
                      style: TextStyle(color: ColorTokens.neutral80),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(dialogCtx),
                        child: Text(
                          'Cancelar',
                          style: TextStyle(color: ColorTokens.primary50),
                        ),
                      ),
                      TextButton(
                        onPressed: () async {
                          Navigator.pop(dialogCtx);
                          try {
                            final provider = context.read<ExperienceProvider>();
                            await provider.deleteExperience(experience.id);
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Publicación eliminada'),
                                  duration: Duration(seconds: 2),
                                ),
                              );
                            }
                          } catch (e) {
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Error eliminando: $e'),
                                  backgroundColor: ColorTokens.error50,
                                ),
                              );
                            }
                          }
                        },
                        child: Text(
                          'Eliminar',
                          style: TextStyle(color: ColorTokens.error50),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _initializeUserData() async {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final currentUser = FirebaseAuth.instance.currentUser;

      if (currentUser != null) {
        debugPrint('🔄 Cargando datos del usuario...');
        await widget.userProvider.loadUserData();

        if (widget.userProvider.user == null) {
          debugPrint('⚠️ Usuario no existe, creando...');
          String formattedPhone = widget.formatPhoneFunction(currentUser.uid);
          await widget.userProvider.createUserIfNotExists(
            currentUser.uid,
            formattedPhone,
          );
          // Recargar datos después de crear el usuario
          await widget.userProvider.loadUserData();
        }

        if (widget.userProvider.user != null && mounted) {
          debugPrint('✅ Inicializando campos con datos del usuario:');
          debugPrint('   Nombre: "${widget.userProvider.user?.name ?? ''}"');
          debugPrint('   Email: "${widget.userProvider.user?.email ?? ''}"');
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
              style: Styles.cancelButtonStyle,
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () async {
                // Capturar el contexto del widget antes de cualquier operación asíncrona
                final widgetContext = context;

                // Cerrar diálogo de confirmación
                Navigator.of(dialogContext).pop();

                // Verificar que el contexto sigue siendo válido antes de mostrar el loading
                if (!widgetContext.mounted) {
                  debugPrint('❌ Contexto inválido, abortando logout');
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
                  debugPrint('🔄 Iniciando logout desde perfil...');

                  // Detener la escucha del MeetingPointProvider si existe
                  try {
                    final meetingPointProvider =
                        Provider.of<MeetingPointProvider>(
                          widgetContext,
                          listen: false,
                        );
                    meetingPointProvider.stopListening();
                    debugPrint('✅ MeetingPointProvider detenido');
                  } catch (e) {
                    debugPrint('⚠️ Error deteniendo MeetingPointProvider: $e');
                  }

                  // Limpiar UserProvider primero
                  await widget.userProvider.signOut();
                  debugPrint('✅ UserProvider limpiado');

                  // Limpiar Firebase Auth (esto activa el refreshListenable del router)
                  await FirebaseAuth.instance.signOut();
                  debugPrint('✅ Firebase Auth limpiado');

                  // Esperar un momento para que el router detecte el cambio
                  await Future.delayed(Duration(milliseconds: 300));
                  debugPrint('✅ Logout completado');

                  // Cerrar loading
                  if (widgetContext.mounted) {
                    Navigator.of(widgetContext).pop();
                  }

                  // NO navegamos manualmente - el router detectará el cambio de auth automáticamente
                  // gracias al refreshListenable configurado en el router
                  debugPrint(
                    '✅ Logout completado, esperando redirección automática del router',
                  );
                } catch (e) {
                  debugPrint('❌ Error en logout desde perfil: $e');

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
              style: Styles.cancelButtonStyle,
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
                          debugPrint('🔍 DEBUG: Intentando navegar a usuario');
                          debugPrint('  User ID: "${user.id}"');
                          debugPrint('  User ID isEmpty: ${user.id.isEmpty}');
                          debugPrint('  User ID length: ${user.id.length}');

                          if (user.id.isNotEmpty) {
                            final route = '/user-profile/${user.id.trim()}';
                            debugPrint('🔍 DEBUG: Ruta a navegar: $route');
                            Navigator.of(context).pop();
                            WidgetsBinding.instance.addPostFrameCallback((_) {
                              if (context.mounted) {
                                debugPrint(
                                  '🔍 DEBUG: Ejecutando navegación: $route',
                                );
                                context.push(route);
                              }
                            });
                          } else {
                            debugPrint(
                              '❌ ERROR: User ID está vacío, no se puede navegar',
                            );
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Error: Usuario inválido'),
                              ),
                            );
                          }
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
                          debugPrint('🔍 DEBUG: Intentando navegar a usuario');
                          debugPrint('  User ID: "${user.id}"');
                          debugPrint('  User ID isEmpty: ${user.id.isEmpty}');
                          debugPrint('  User ID length: ${user.id.length}');

                          if (user.id.isNotEmpty) {
                            final route = '/user-profile/${user.id.trim()}';
                            debugPrint('🔍 DEBUG: Ruta a navegar: $route');
                            Navigator.of(context).pop();
                            WidgetsBinding.instance.addPostFrameCallback((_) {
                              if (context.mounted) {
                                debugPrint(
                                  '🔍 DEBUG: Ejecutando navegación: $route',
                                );
                                context.push(route);
                              }
                            });
                          } else {
                            debugPrint(
                              '❌ ERROR: User ID está vacío, no se puede navegar',
                            );
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Error: Usuario inválido'),
                              ),
                            );
                          }
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
        final data = userDoc.data() as Map<String, dynamic>;
        // Asegurar que el ID está incluido en los datos
        data['id'] = userDoc.id;
        debugPrint('✅ Usuario cargado con ID: ${userDoc.id}');
        return BiuxUser.fromJsonMap(data);
      } else {
        debugPrint('❌ Usuario no encontrado: $userId');
      }
    } catch (e) {
      debugPrint('❌ Error cargando usuario $userId: $e');
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
                    Navigator.of(dialogContext).pop();
                  },
                  style: Styles.cancelButtonStyle,
                  child: Text('Cancelar'),
                ),
                ElevatedButton.icon(
                  onPressed: () async {
                    // Guardar referencias antes de cerrar el diálogo
                    final name = nameController.text.trim();
                    final username = usernameController.text.trim();
                    final description = descriptionController.text.trim();
                    final profileUrl = selectedProfileImageUrl;
                    final email = widget.userProvider.user?.email ?? '';

                    // Actualizar todos los campos de perfil
                    bool success = await widget.userProvider.updateProfile(
                      name: name,
                      username: username,
                      description: description,
                      photoUrl: profileUrl,
                      email: email,
                    );

                    // Cerrar el diálogo
                    if (mounted) {
                      Navigator.of(dialogContext).pop();
                    }

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
        title: const Text('Mi Perfil'),
        backgroundColor: ColorTokens.primary30,
        foregroundColor: ColorTokens.neutral100,
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
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          ColorTokens.primary30,
                          ColorTokens.primary30.withValues(alpha: 0.8),
                        ],
                      ),
                    ),
                    child: SafeArea(
                      child: Padding(
                        padding: EdgeInsets.fromLTRB(16, 16, 16, 20),
                        child: Column(
                          children: [
                            // Primera fila: Botón (+) izquierda y controles derecha
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                // Menú izquierdo: Story + Post
                                PopupMenuButton<String>(
                                  icon: Icon(
                                    Icons.add_circle_outline,
                                    color: ColorTokens.neutral100,
                                    size: 24,
                                  ),
                                  onSelected: (value) {
                                    if (value == 'story') {
                                      Navigator.of(context).push(
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              const CreateExperienceScreen(
                                                experienceType:
                                                    ExperienceType.general,
                                                isStoryMode: true,
                                              ),
                                        ),
                                      );
                                    } else if (value == 'post') {
                                      Navigator.of(context).push(
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              const CreateExperienceScreen(
                                                experienceType:
                                                    ExperienceType.general,
                                                isPostMode: true,
                                                textOnly: false,
                                              ),
                                        ),
                                      );
                                    }
                                  },
                                  itemBuilder: (BuildContext context) => [
                                    PopupMenuItem<String>(
                                      value: 'story',
                                      child: Row(
                                        children: [
                                          Icon(
                                            Icons.add_photo_alternate,
                                            size: 20,
                                          ),
                                          SizedBox(width: 10),
                                          Text('Agregar Historia'),
                                        ],
                                      ),
                                    ),
                                    PopupMenuItem<String>(
                                      value: 'post',
                                      child: Row(
                                        children: [
                                          Icon(Icons.image_search, size: 20),
                                          SizedBox(width: 10),
                                          Text('Nueva Publicación'),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),

                                // Botones derechos: Editar + Configuración
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Tooltip(
                                      message: 'Editar perfil',
                                      child: IconButton(
                                        icon: Icon(
                                          Icons.edit_outlined,
                                          color: ColorTokens.neutral100,
                                          size: 20,
                                        ),
                                        onPressed: () {
                                          _showEditProfileDialog();
                                        },
                                        constraints: BoxConstraints(
                                          minWidth: 32,
                                          minHeight: 32,
                                        ),
                                        padding: EdgeInsets.zero,
                                      ),
                                    ),
                                    Tooltip(
                                      message: 'Configuración',
                                      child: IconButton(
                                        icon: Icon(
                                          Icons.settings_outlined,
                                          color: ColorTokens.neutral100,
                                          size: 20,
                                        ),
                                        onPressed: () {
                                          context.go('/account-settings');
                                        },
                                        constraints: BoxConstraints(
                                          minWidth: 32,
                                          minHeight: 32,
                                        ),
                                        padding: EdgeInsets.zero,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),

                            SizedBox(height: 16),

                            // Segunda fila: Foto + Nombre/Usuario
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Foto de perfil
                                Container(
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: ColorTokens.neutral100,
                                      width: 2,
                                    ),
                                  ),
                                  child: CircleAvatar(
                                    radius: 40,
                                    backgroundColor: ColorTokens.neutral20,
                                    backgroundImage:
                                        widget.userProvider.user?.photoUrl !=
                                                null &&
                                            widget
                                                .userProvider
                                                .user!
                                                .photoUrl!
                                                .isNotEmpty
                                        ? NetworkImage(
                                            widget.userProvider.user!.photoUrl!,
                                          )
                                        : null,
                                    child:
                                        widget.userProvider.user?.photoUrl ==
                                                null ||
                                            widget
                                                .userProvider
                                                .user!
                                                .photoUrl!
                                                .isEmpty
                                        ? Icon(
                                            Icons.person,
                                            size: 40,
                                            color: ColorTokens.neutral60,
                                          )
                                        : null,
                                  ),
                                ),
                                SizedBox(width: 16),

                                // Nombre y usuario - Columna al lado de la foto
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        widget.userProvider.user?.name !=
                                                    null &&
                                                widget
                                                    .userProvider
                                                    .user!
                                                    .name!
                                                    .isNotEmpty
                                            ? widget.userProvider.user!.name!
                                            : 'Sin nombre',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: ColorTokens.neutral100,
                                        ),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      SizedBox(height: 4),
                                      if (widget.userProvider.user?.username !=
                                              null &&
                                          widget
                                              .userProvider
                                              .user!
                                              .username!
                                              .isNotEmpty)
                                        Text(
                                          '@${widget.userProvider.user!.username}',
                                          style: TextStyle(
                                            fontSize: 13,
                                            color: ColorTokens.neutral100
                                                .withValues(alpha: 0.7),
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                    ],
                                  ),
                                ),
                              ],
                            ),

                            SizedBox(height: 16),

                            // Tercera fila: Estadísticas
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                Column(
                                  children: [
                                    Text(
                                      _postCount.toString(),
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: ColorTokens.neutral100,
                                      ),
                                    ),
                                    Text(
                                      'Posts',
                                      style: TextStyle(
                                        fontSize: 10,
                                        color: ColorTokens.neutral100
                                            .withValues(alpha: 0.8),
                                      ),
                                    ),
                                  ],
                                ),
                                GestureDetector(
                                  onTap: () {
                                    _showFollowersModal(context);
                                  },
                                  child: Column(
                                    children: [
                                      Text(
                                        (widget
                                                    .userProvider
                                                    .user
                                                    ?.followers
                                                    ?.length ??
                                                0)
                                            .toString(),
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                          color: ColorTokens.neutral100,
                                        ),
                                      ),
                                      Text(
                                        'Seguidores',
                                        style: TextStyle(
                                          fontSize: 10,
                                          color: ColorTokens.neutral100
                                              .withValues(alpha: 0.8),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () {
                                    _showFollowingModal(context);
                                  },
                                  child: Column(
                                    children: [
                                      Text(
                                        (widget
                                                    .userProvider
                                                    .user
                                                    ?.following
                                                    ?.length ??
                                                0)
                                            .toString(),
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                          color: ColorTokens.neutral100,
                                        ),
                                      ),
                                      Text(
                                        'Siguiendo',
                                        style: TextStyle(
                                          fontSize: 10,
                                          color: ColorTokens.neutral100
                                              .withValues(alpha: 0.8),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),

                            SizedBox(height: 12),

                            // Descripción - Debajo de la foto, alineada a izquierda
                            if (widget.userProvider.user?.description != null &&
                                widget
                                    .userProvider
                                    .user!
                                    .description!
                                    .isNotEmpty)
                              Align(
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  widget.userProvider.user!.description!,
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: ColorTokens.neutral100.withValues(
                                      alpha: 0.9,
                                    ),
                                    height: 1.4,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      children: [
                        SizedBox(height: 20),
                        // ========== SECCIÓN DE PUBLICACIONES ==========
                        Text(
                          'Publicaciones',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color:
                                Theme.of(context).brightness == Brightness.dark
                                ? ColorTokens.neutral100
                                : ColorTokens.primary30,
                          ),
                        ),

                        SizedBox(height: 16),

                        // Cargar y mostrar experiencias del usuario
                        FutureBuilder(
                          future: _experiencesFuture,
                          builder: (context, snapshot) {
                            // Estado de carga
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return Container(
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
                                child: Center(
                                  child: CircularProgressIndicator(
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      ColorTokens.primary30,
                                    ),
                                  ),
                                ),
                              );
                            }

                            // Error
                            if (snapshot.hasError) {
                              return Container(
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
                                      Icons.error_outline,
                                      size: 48,
                                      color: ColorTokens.error50,
                                    ),
                                    SizedBox(height: 12),
                                    Text(
                                      'Error cargando publicaciones',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: ColorTokens.error50,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }

                            // Sin datos o lista vacía
                            if (!snapshot.hasData ||
                                snapshot.data == null ||
                                (snapshot.data as dynamic).isEmpty) {
                              return Container(
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
                              );
                            }

                            // Filtrar: solo PUBLICACIONES (no historias) con media válido
                            final allExperiences = snapshot.data as dynamic;
                            final experiences = allExperiences.where((exp) {
                              // Excluir historias — solo publicaciones en el perfil
                              if (exp.isStoryFormat == true) return false;
                              try {
                                if (exp.media == null || exp.media.isEmpty)
                                  return false;
                                if (exp.media.first == null) return false;
                                final media = exp.media.first;
                                final url = media.url ?? '';
                                if (url.isEmpty) return false;
                                if (!url.startsWith('http://') &&
                                    !url.startsWith('https://'))
                                  return false;
                                // Para videos: validar que tenga thumbnail o URL válida
                                if (media.mediaType == MediaType.video) {
                                  final thumb = media.thumbnailUrl ?? '';
                                  return thumb.isNotEmpty &&
                                          thumb.startsWith('http') ||
                                      url.isNotEmpty;
                                }
                                return true;
                              } catch (e) {
                                return false;
                              }
                            }).toList();

                            // Eliminar publicaciones con imágenes que fallaron al cargar
                            experiences.removeWhere(
                              (exp) =>
                                  _failedImageIds.contains(exp.id.toString()),
                            );

                            // Actualizar contador de posts
                            if (_postCount != experiences.length) {
                              WidgetsBinding.instance.addPostFrameCallback((_) {
                                if (mounted)
                                  setState(
                                    () => _postCount = experiences.length,
                                  );
                              });
                            }

                            // Si después de filtrar no hay experiencias, mostrar el mensaje
                            if (experiences.isEmpty) {
                              return Container(
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
                                      'Sin publicaciones válidas',
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
                              );
                            }

                            // Mostrar grid de publicaciones
                            return GridView.builder(
                              shrinkWrap: true,
                              physics: NeverScrollableScrollPhysics(),
                              gridDelegate:
                                  SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 3,
                                    crossAxisSpacing: 8,
                                    mainAxisSpacing: 8,
                                    childAspectRatio: 1,
                                  ),
                              itemCount: experiences.length,
                              itemBuilder: (context, index) {
                                final experience = experiences[index];
                                return GestureDetector(
                                  onTap: () {
                                    context.push(
                                      '/stories/post/${experience.id}',
                                    );
                                  },
                                  onLongPress: () {
                                    _showExperienceMenu(context, experience);
                                  },
                                  child: Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(
                                        color: ColorTokens.primary30,
                                        width: 1,
                                      ),
                                    ),
                                    child: Stack(
                                      fit: StackFit.expand,
                                      children: [
                                        // Imagen/thumbnail de la experiencia optimizada
                                        experience.media.isNotEmpty
                                            ? Builder(
                                                builder: (context) {
                                                  final media =
                                                      experience.media.first;
                                                  final isVideo =
                                                      media.mediaType ==
                                                      MediaType.video;
                                                  final displayUrl = isVideo
                                                      ? (media
                                                                    .thumbnailUrl
                                                                    ?.isNotEmpty ==
                                                                true
                                                            ? media
                                                                  .thumbnailUrl!
                                                            : media.url)
                                                      : media.url;
                                                  return Stack(
                                                    fit: StackFit.expand,
                                                    children: [
                                                      CachedNetworkImage(
                                                        imageUrl: displayUrl,
                                                        fit: BoxFit.cover,
                                                        cacheManager:
                                                            OptimizedCacheManager
                                                                .instance,
                                                        memCacheWidth: 400,
                                                        memCacheHeight: 400,
                                                        fadeInDuration:
                                                            const Duration(
                                                              milliseconds: 100,
                                                            ),
                                                        fadeOutDuration:
                                                            const Duration(
                                                              milliseconds: 50,
                                                            ),
                                                        placeholder:
                                                            (
                                                              context,
                                                              url,
                                                            ) => Container(
                                                              color: ColorTokens
                                                                  .neutral20,
                                                              child: Center(
                                                                child: Icon(
                                                                  isVideo
                                                                      ? Icons
                                                                            .videocam
                                                                      : Icons
                                                                            .image,
                                                                  color: ColorTokens
                                                                      .neutral60,
                                                                  size: 32,
                                                                ),
                                                              ),
                                                            ),
                                                        errorWidget: (context, url, error) {
                                                          final expId =
                                                              experience.id
                                                                  .toString();
                                                          if (!_failedImageIds
                                                              .contains(
                                                                expId,
                                                              )) {
                                                            WidgetsBinding
                                                                .instance
                                                                .addPostFrameCallback((
                                                                  _,
                                                                ) {
                                                                  if (mounted) {
                                                                    setState(() {
                                                                      _failedImageIds
                                                                          .add(
                                                                            expId,
                                                                          );
                                                                    });
                                                                  }
                                                                });
                                                          }
                                                          return SizedBox.shrink();
                                                        },
                                                      ),
                                                      if (isVideo)
                                                        Center(
                                                          child: Container(
                                                            padding:
                                                                const EdgeInsets.all(
                                                                  8,
                                                                ),
                                                            decoration:
                                                                BoxDecoration(
                                                                  color: Colors
                                                                      .black
                                                                      .withValues(
                                                                        alpha:
                                                                            0.5,
                                                                      ),
                                                                  shape: BoxShape
                                                                      .circle,
                                                                ),
                                                            child: const Icon(
                                                              Icons.play_arrow,
                                                              color:
                                                                  Colors.white,
                                                              size: 24,
                                                            ),
                                                          ),
                                                        ),
                                                    ],
                                                  );
                                                },
                                              )
                                            : Container(
                                                color: ColorTokens.neutral20,
                                                child: Icon(
                                                  Icons.image,
                                                  color: ColorTokens.neutral60,
                                                ),
                                              ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            );
                          },
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
                              backgroundColor:
                                  Theme.of(context).brightness ==
                                      Brightness.dark
                                  ? ColorTokens.neutral30
                                  : ColorTokens.neutral90,
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
