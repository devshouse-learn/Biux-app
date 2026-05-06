import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:biux/features/experiences/presentation/providers/experience_classic_provider.dart';
import 'package:biux/features/experiences/domain/entities/experience_entity.dart';
import 'package:biux/features/social/presentation/widgets/post_social_actions.dart';
import 'package:biux/core/design_system/locale_notifier.dart';
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
  LocaleNotifier get l => Provider.of<LocaleNotifier>(context);

  ExperienceEntity? _experience;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadExperience();
    // Cargar reposts del usuario para que isReposted sea correcto
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          context.read<ExperienceProvider>().loadMyReposts(uid);
        }
      });
    }
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
            _error = l.t('post_not_found');
          }
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _error = 'Error cargando la publicación: $e';
        });
      }
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  /// Formatea el tiempo relativo al formato solicitado
  String _formatRelativeTime(DateTime? createdAt) {
    if (createdAt == null) return '';

    final now = DateTime.now();
    final difference = now.difference(createdAt);

    // Menos de un minuto
    if (difference.inSeconds < 60) {
      return 'hace ${difference.inSeconds} segundo${difference.inSeconds != 1 ? 's' : ''}';
    }

    // Menos de una hora
    if (difference.inMinutes < 60) {
      return 'hace ${difference.inMinutes} minuto${difference.inMinutes != 1 ? 's' : ''}';
    }

    // Menos de un día
    if (difference.inHours < 24) {
      return 'hace ${difference.inHours} hora${difference.inHours != 1 ? 's' : ''}';
    }

    // Menos de 7 días
    if (difference.inDays < 7) {
      return 'hace ${difference.inDays} día${difference.inDays != 1 ? 's' : ''}';
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
    final isRepost = _experience?.isRepost == true;
    return Scaffold(
      appBar: AppBar(
        title: Text(isRepost ? 'Reposteo' : l.t('publication')),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null || _experience == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.image_not_supported, size: 64),
            SizedBox(height: 16),
            Text(
              _error ?? l.t('post_not_found'),
              style: const TextStyle(fontSize: 16),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => context.pop(),
              child: Text(l.t('back')),
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
        timestamp: _formatRelativeTime(experience.createdAt),
        isEdited: experience.isEdited,
        headerSubtitle: experience.isRepost
            ? _RepostBannerDetail(
                userName:
                    (experience.originalAuthorUserName?.isNotEmpty == true)
                    ? experience.originalAuthorUserName!
                    : 'usuario',
                authorId: experience.originalAuthorId,
                currentUserId: currentUserId,
              )
            : null,
        onUserTap: () => context.push('/user-profile/${experience.user.id}'),
        onImageLongPress: (index) {
          _showMediaOptions(context, imageUrls[index]);
        },
        galleryOverlays: [
          if (isOwner)
            Positioned(
              top: 8,
              right: 8,
              child: _buildPostOptions(context, experience),
            ),
        ],
        actionsWidget: Padding(
          padding: const EdgeInsets.fromLTRB(16, 24, 16, 0),
          child: Builder(
            builder: (ctx) {
              final provider = ctx.watch<ExperienceProvider>();
              final uid = FirebaseAuth.instance.currentUser?.uid;
              final isOwner = uid == experience.user.id;
              final isMyOwnRepost = experience.isRepost && isOwner;
              final hasRepostedOriginal = provider.hasRepostedPost(
                experience.id,
              );
              final isReposted = isMyOwnRepost || hasRepostedOriginal;
              final showRepostButton = !(isOwner && !experience.isRepost);
              return PostSocialActions(
                postId: experience.id,
                postOwnerId: experience.user.id,
                postPreview: experience.description.length > 50
                    ? experience.description.substring(0, 50)
                    : experience.description,
                isReposted: isReposted,
                onRepost: showRepostButton && !isReposted
                    ? () async {
                        final confirmed = await showDialog<bool>(
                          context: ctx,
                          builder: (dialogCtx) => AlertDialog(
                            title: Text(l.t('repost_publication')),
                            content: Text(
                              'De @${experience.user.userName.isNotEmpty ? experience.user.userName : experience.user.fullName}',
                            ),
                            actions: [
                              TextButton(
                                onPressed: () =>
                                    Navigator.pop(dialogCtx, false),
                                child: Text(l.t('cancel')),
                              ),
                              ElevatedButton(
                                onPressed: () => Navigator.pop(dialogCtx, true),
                                child: const Text('Repostear'),
                              ),
                            ],
                          ),
                        );
                        if (confirmed != true || !ctx.mounted) return;
                        await provider.repostStory(experience);
                        if (uid != null && ctx.mounted) {
                          provider.loadMyReposts(uid);
                        }
                      }
                    : null,
                onUnrepost: showRepostButton && isReposted
                    ? () async {
                        if (isMyOwnRepost) {
                          await provider.deleteExperience(experience.id);
                        } else {
                          await provider.removeRepost(experience.id);
                        }
                        if (uid != null && ctx.mounted) {
                          provider.loadMyReposts(uid);
                        }
                      }
                    : null,
              );
            },
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

  void _showMediaOptions(BuildContext context, String mediaUrl) {
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
                leading: Icon(Icons.save_alt, color: Colors.blue),
                title: Text(l.t('download_image')),
                onTap: () {
                  Navigator.pop(context);
                  // Implementar descarga
                },
              ),
              ListTile(
                leading: Icon(Icons.share, color: Colors.green),
                title: Text(l.t('share')),
                onTap: () {
                  Navigator.pop(context);
                  // Implementar compartir
                },
              ),
              ListTile(
                leading: Icon(Icons.report, color: Colors.red),
                title: Text(l.t('report_action')),
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
  Widget _buildPostOptions(BuildContext context, ExperienceEntity experience) {
    return PopupMenuButton<String>(
      color: Colors.grey[800],
      onSelected: (value) {
        if (value == 'edit') {
          context.push('/edit-post/${experience.id}', extra: experience);
        } else if (value == 'delete') {
          _showDeletePostConfirmation(context, experience);
        }
      },
      itemBuilder: (BuildContext context) => [
        PopupMenuItem<String>(
          value: 'edit',
          child: Row(
            children: [
              Icon(Icons.edit, size: 18),
              SizedBox(width: 8),
              Text(l.t('edit')),
            ],
          ),
        ),
        PopupMenuItem<String>(
          value: 'delete',
          child: Row(
            children: [
              Icon(Icons.delete, color: Colors.red, size: 18),
              SizedBox(width: 8),
              Text(l.t('delete'), style: TextStyle(color: Colors.red)),
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
  ) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l.t('delete_post')),
        content: Text(l.t('confirm_delete_post')),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(l.t('cancel')),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(dialogContext);
              _deletePostFromFirebase(context, experience);
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
  ) async {
    final l = Provider.of<LocaleNotifier>(context, listen: false);
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

/// Banner de repost para PostDetailScreen
class _RepostBannerDetail extends StatelessWidget {
  final String userName;
  final String? authorId;
  final String? currentUserId;

  const _RepostBannerDetail({
    required this.userName,
    required this.authorId,
    required this.currentUserId,
  });

  void _navigate(BuildContext context) {
    if (authorId != null && authorId!.isNotEmpty) {
      if (currentUserId == authorId) {
        context.push('/profile');
      } else {
        context.push('/user-profile/$authorId');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).colorScheme.primary;
    return GestureDetector(
      onTap: () => _navigate(context),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: primaryColor,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.repeat_rounded, size: 14, color: Colors.white),
            const SizedBox(width: 5),
            Text(
              'Reposteado de @$userName',
              style: const TextStyle(
                fontSize: 12,
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
