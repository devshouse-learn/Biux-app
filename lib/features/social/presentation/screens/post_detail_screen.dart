import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:biux/features/experiences/presentation/providers/experience_classic_provider.dart';
import 'package:biux/features/experiences/domain/entities/experience_entity.dart';
import 'package:biux/features/social/presentation/widgets/post_social_actions.dart';
import 'package:biux/core/design_system/color_tokens.dart';
import 'package:biux/shared/widgets/post_card.dart';

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
            _error = 'Publicación no encontrada';
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
        title: const Text(
          'Publicación',
          style: TextStyle(color: Colors.white, fontSize: 16),
        ),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            CircularProgressIndicator(color: Colors.white30),
            SizedBox(height: 16),
            Text(
              'Cargando publicación...',
              style: TextStyle(color: Colors.white54, fontSize: 14),
            ),
          ],
        ),
      );
    }

    if (_error != null || _experience == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.image_not_supported, color: Colors.grey[600], size: 64),
            const SizedBox(height: 16),
            Text(
              _error ?? 'Publicación no encontrada',
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
              child: const Text('Volver'),
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
                leading: const Icon(Icons.save_alt, color: Colors.blue),
                title: const Text('Descargar imagen'),
                onTap: () {
                  Navigator.pop(context);
                  // Implementar descarga
                },
              ),
              ListTile(
                leading: const Icon(Icons.share, color: Colors.green),
                title: const Text('Compartir'),
                onTap: () {
                  Navigator.pop(context);
                  // Implementar compartir
                },
              ),
              ListTile(
                leading: const Icon(Icons.report, color: Colors.red),
                title: const Text('Reportar'),
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
        const PopupMenuItem<String>(
          value: 'edit',
          child: Row(
            children: [
              Icon(Icons.edit, size: 18),
              SizedBox(width: 8),
              Text('Editar'),
            ],
          ),
        ),
        const PopupMenuItem<String>(
          value: 'delete',
          child: Row(
            children: [
              Icon(Icons.delete, color: Colors.red, size: 18),
              SizedBox(width: 8),
              Text('Eliminar', style: TextStyle(color: Colors.red)),
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
        title: const Text('Eliminar publicación'),
        content: const Text(
          '¿Estás seguro de que deseas eliminar esta publicación? Esta acción no se puede deshacer.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancelar'),
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
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }

  /// Elimina el post de Firebase usando el provider (Firestore)
  Future<void> _deletePostFromFirebase(
    BuildContext context,
    ExperienceEntity experience,
  ) async {
    final provider = context.read<ExperienceProvider>();

    // Navegar de vuelta inmediatamente para UX instantánea
    if (context.mounted) {
      Navigator.pop(context);
    }

    // Eliminar en segundo plano
    provider.deleteExperience(experience.id);
  }
}
