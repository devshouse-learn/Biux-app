import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:biux/core/design_system/locale_notifier.dart';
import 'package:biux/features/experiences/presentation/providers/experience_classic_provider.dart';
import 'package:biux/features/experiences/domain/entities/experience_entity.dart';
import 'package:biux/features/social/presentation/widgets/post_social_actions.dart';
import 'package:biux/core/design_system/color_tokens.dart';
import 'package:biux/shared/widgets/post_card.dart';
import 'package:firebase_database/firebase_database.dart';

/// Pantalla estilo Instagram para ver publicaciones con galería
/// Permite: ver imágenes en grande, darle like, y comentar
class PostDetailScreen extends StatefulWidget {
  final String postId;

  const PostDetailScreen({super.key, required this.postId});

  @override
  State<PostDetailScreen> createState() => _PostDetailScreenState();
}

class _PostDetailScreenState extends State<PostDetailScreen> {
  ExperienceEntity? _experience;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadExperience();
  }

  Future<void> _loadExperience() async {
    try {
      final provider = context.read<ExperienceProvider>();
      final experience = await provider.getExperienceById(widget.postId);

      if (mounted) {
        setState(() {
          _experience = experience;
          _isLoading = false;
          if (experience == null) {
            _error = 'post_not_found';
          }
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _error = 'post_loading_error_detail:$e';
        });
      }
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  /// Formatea el tiempo relativo al formato solicitado
  String _formatRelativeTime(DateTime? createdAt, LocaleNotifier l) {
    if (createdAt == null) return '';

    final now = DateTime.now();
    final difference = now.difference(createdAt);

    // Menos de un minuto
    if (difference.inSeconds < 60) {
      return l
          .t(
            difference.inSeconds != 1
                ? 'time_full_seconds'
                : 'time_full_second',
          )
          .replaceAll('{n}', '${difference.inSeconds}');
    }

    // Menos de una hora
    if (difference.inMinutes < 60) {
      return l
          .t(
            difference.inMinutes != 1
                ? 'time_full_minutes'
                : 'time_full_minute',
          )
          .replaceAll('{n}', '${difference.inMinutes}');
    }

    // Menos de un día
    if (difference.inHours < 24) {
      return l
          .t(difference.inHours != 1 ? 'time_full_hours' : 'time_full_hour')
          .replaceAll('{n}', '${difference.inHours}');
    }

    // Menos de 7 días
    if (difference.inDays < 7) {
      return l
          .t(difference.inDays != 1 ? 'time_full_days' : 'time_full_day')
          .replaceAll('{n}', '${difference.inDays}');
    }

    // Más de 7 días - mostrar formato DD-MM
    if (createdAt.year == now.year) {
      return '${createdAt.day.toString().padLeft(2, '0')}-${createdAt.month.toString().padLeft(2, '0')}';
    }

    // Diferente año - mostrar DD-MM-YYYY
    return '${createdAt.day.toString().padLeft(2, '0')}-${createdAt.month.toString().padLeft(2, '0')}-${createdAt.year}';
  }

  @override
  Widget build(BuildContext context) {
    final l = Provider.of<LocaleNotifier>(context, listen: false);
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black87,
        foregroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        title: Text(
          l.t('post_title'),
          style: const TextStyle(color: Colors.white, fontSize: 16),
        ),
      ),
      body: _buildBody(l),
    );
  }

  Widget _buildBody(LocaleNotifier l) {
    if (_isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(color: Colors.white30),
            const SizedBox(height: 16),
            Text(
              l.t('post_loading'),
              style: const TextStyle(color: Colors.white54, fontSize: 14),
            ),
          ],
        ),
      );
    }

    if (_error != null || _experience == null) {
      String errorText;
      if (_error != null && _error!.startsWith('post_loading_error_detail:')) {
        errorText =
            '${l.t('post_loading_error')}: ${_error!.split(':').skip(1).join(':')}';
      } else {
        errorText = l.t('post_not_found');
      }
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.image_not_supported, color: Colors.grey[600], size: 64),
            const SizedBox(height: 16),
            Text(
              errorText,
              style: TextStyle(color: Colors.grey[400], fontSize: 16),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => context.pop(),
              style: ElevatedButton.styleFrom(
                backgroundColor: ColorTokens.primary50,
                foregroundColor: Colors.white,
              ),
              child: Text(l.t('go_back')),
            ),
          ],
        ),
      );
    }

    final experience = _experience!;
    final currentUserId = FirebaseAuth.instance.currentUser?.uid;
    final isOwner = currentUserId == experience.user.id;
    final imageUrls = experience.media.map((m) => m.url).toList();

    return SingleChildScrollView(
      child: PostCard(
        user: PostCardUser(
          id: experience.user.id,
          fullName: experience.user.fullName,
          userName: experience.user.userName,
          photo: experience.user.photo,
        ),
        imageUrls: imageUrls,
        description: experience.description,
        timestamp: _formatRelativeTime(experience.createdAt, l),
        isEdited: experience.isEdited,
        onUserTap: () => context.push('/user-profile/${experience.user.id}'),
        onImageLongPress: (index) {
          _showMediaOptions(context, imageUrls[index], l);
        },
        galleryOverlays: [
          if (isOwner)
            Positioned(
              top: 8,
              right: 8,
              child: _buildPostOptions(context, experience, l),
            ),
        ],
        actionsWidget: Padding(
          padding: const EdgeInsets.fromLTRB(16, 24, 16, 0),
          child: PostSocialActions(
            postId: experience.id,
            postOwnerId: experience.user.id,
            postPreview: experience.description.length > 50
                ? experience.description.substring(0, 50)
                : experience.description,
          ),
        ),
        bottomWidget: Column(
          children: [
            Container(
              margin: const EdgeInsets.only(top: 16),
              child: PostCommentsPreview(
                postId: experience.id,
                postOwnerId: experience.user.id,
                maxComments: 5,
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  void _showMediaOptions(
    BuildContext context,
    String mediaUrl,
    LocaleNotifier l,
  ) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                margin: const EdgeInsets.only(top: 12, bottom: 16),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              ListTile(
                leading: const Icon(Icons.save_alt, color: Colors.blue),
                title: Text(l.t('download_image')),
                onTap: () {
                  Navigator.pop(context);
                  // Implementar descarga
                },
              ),
              ListTile(
                leading: const Icon(Icons.share, color: Colors.green),
                title: Text(l.t('share')),
                onTap: () {
                  Navigator.pop(context);
                  // Implementar compartir
                },
              ),
              ListTile(
                leading: const Icon(Icons.report, color: Colors.red),
                title: Text(l.t('report')),
                onTap: () {
                  Navigator.pop(context);
                  // Implementar reporte
                },
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  /// Construye el botón de opciones (menú de tres puntos)
  Widget _buildPostOptions(
    BuildContext context,
    ExperienceEntity experience,
    LocaleNotifier l,
  ) {
    return PopupMenuButton<String>(
      color: Colors.grey[800],
      onSelected: (value) {
        if (value == 'edit') {
          // PENDIENTE: Implementar editar post
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(l.t('edit_post_coming_soon')),
              duration: const Duration(seconds: 2),
            ),
          );
        } else if (value == 'delete') {
          _showDeletePostConfirmation(context, experience, l);
        }
      },
      itemBuilder: (BuildContext context) => [
        PopupMenuItem<String>(
          value: 'edit',
          child: Row(
            children: [
              const Icon(Icons.edit, color: Colors.white, size: 18),
              const SizedBox(width: 8),
              Text(l.t('edit'), style: const TextStyle(color: Colors.white)),
            ],
          ),
        ),
        PopupMenuItem<String>(
          value: 'delete',
          child: Row(
            children: [
              const Icon(Icons.delete, color: Colors.red, size: 18),
              const SizedBox(width: 8),
              Text(l.t('delete'), style: const TextStyle(color: Colors.red)),
            ],
          ),
        ),
      ],
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.7),
          shape: BoxShape.circle,
        ),
        child: const Icon(Icons.more_vert, color: Colors.white, size: 20),
      ),
    );
  }

  /// Muestra diálogo de confirmación para eliminar el post
  void _showDeletePostConfirmation(
    BuildContext context,
    ExperienceEntity experience,
    LocaleNotifier l,
  ) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: Text(
          l.t('delete_post_title'),
          style: const TextStyle(color: Colors.white),
        ),
        content: Text(
          l.t('delete_post_confirm_body'),
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(l.t('cancel')),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(dialogContext);
              _deletePostFromFirebase(context, experience, l);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: Text(l.t('delete')),
          ),
        ],
      ),
    );
  }

  /// Elimina el post de Firebase
  Future<void> _deletePostFromFirebase(
    BuildContext context,
    ExperienceEntity experience,
    LocaleNotifier l,
  ) async {
    try {
      final database = FirebaseDatabase.instance;

      // Intentar primero marcar como eliminado (actualización)
      try {
        await database.ref('experiences/${experience.id}').update({
          'isDeleted': true,
          'deletedAt': DateTime.now().millisecondsSinceEpoch,
        });
      } catch (updateError) {
        // Si falla la actualización, intentar eliminación directa
        if (updateError.toString().contains('Permission denied')) {
          await database.ref('experiences/${experience.id}').remove();
        } else {
          rethrow;
        }
      }

      // Mostrar éxito
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l.t('post_deleted_success')),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );

        // Navegar de vuelta después de 1 segundo
        await Future.delayed(const Duration(seconds: 1));
        if (context.mounted) {
          Navigator.pop(context);
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${l.t('post_delete_error')}: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }
}
