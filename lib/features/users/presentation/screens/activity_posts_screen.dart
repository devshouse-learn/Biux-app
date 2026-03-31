import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:go_router/go_router.dart';
import 'package:biux/core/design_system/color_tokens.dart';
import 'package:biux/features/experiences/data/models/experience_model.dart';
import 'package:biux/features/experiences/domain/entities/experience_entity.dart';
import 'package:biux/shared/widgets/post_card.dart';
import 'package:biux/features/social/presentation/widgets/post_social_actions.dart';

/// Pantalla que muestra todas las publicaciones (posts) del usuario.
/// Usa la misma estructura visual que el feed.
class ActivityPostsScreen extends StatefulWidget {
  const ActivityPostsScreen({Key? key}) : super(key: key);

  @override
  State<ActivityPostsScreen> createState() => _ActivityPostsScreenState();
}

class _ActivityPostsScreenState extends State<ActivityPostsScreen> {
  final _firestore = FirebaseFirestore.instance;
  final String? _currentUserId = FirebaseAuth.instance.currentUser?.uid;

  List<ExperienceModel> _posts = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserPosts();
  }

  Future<void> _loadUserPosts() async {
    if (_currentUserId == null) return;
    setState(() => _isLoading = true);

    try {
      final snapshot = await _firestore
          .collection('experiences')
          .where('user.id', isEqualTo: _currentUserId)
          .orderBy('createdAt', descending: true)
          .get();

      final posts = snapshot.docs
          .map((doc) {
            try {
              final data = doc.data();
              data['id'] = doc.id;
              return ExperienceModel.fromJson(data);
            } catch (_) {
              return null;
            }
          })
          .whereType<ExperienceModel>()
          .where((e) => e.format == ExperienceFormat.post)
          .toList();

      if (mounted) {
        setState(() {
          _posts = posts;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorTokens.primary30,
      appBar: AppBar(
        backgroundColor: ColorTokens.primary30,
        foregroundColor: ColorTokens.neutral100,
        title: Text(
          'Mis Publicaciones',
          style: TextStyle(
            color: ColorTokens.neutral100,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: ColorTokens.neutral100),
          onPressed: () => context.pop(),
        ),
        elevation: 0,
      ),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(
                  ColorTokens.secondary50,
                ),
              ),
            )
          : _posts.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.grid_on, color: ColorTokens.neutral60, size: 64),
                  SizedBox(height: 16),
                  Text(
                    'No has compartido publicaciones aún',
                    style: TextStyle(
                      color: ColorTokens.neutral80,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            )
          : RefreshIndicator(
              onRefresh: _loadUserPosts,
              color: ColorTokens.secondary50,
              child: GridView.builder(
                padding: EdgeInsets.all(4),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4,
                  crossAxisSpacing: 4,
                  mainAxisSpacing: 4,
                ),
                itemCount: _posts.length,
                itemBuilder: (context, index) =>
                    _buildPostThumbnail(_posts[index]),
              ),
            ),
    );
  }

  Widget _buildPostThumbnail(ExperienceModel post) {
    final entity = post.toEntity();
    final imageUrls = entity.media.map((m) => m.url).toList();
    final firstImage = imageUrls.isNotEmpty ? imageUrls.first : null;

    return GestureDetector(
      onTap: () => _showPostDetail(post),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(4),
        child: firstImage != null
            ? Image.network(
                firstImage,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  color: ColorTokens.primary40,
                  child: Icon(Icons.image, color: ColorTokens.neutral60),
                ),
              )
            : Container(
                color: ColorTokens.primary40,
                child: Icon(Icons.image, color: ColorTokens.neutral60),
              ),
      ),
    );
  }

  void _showPostDetail(ExperienceModel post) {
    final entity = post.toEntity();
    final imageUrls = entity.media.map((m) => m.url).toList();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: ColorTokens.primary30,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.85,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (_, scrollController) => SingleChildScrollView(
          controller: scrollController,
          child: Column(
            children: [
              SizedBox(height: 8),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: ColorTokens.neutral60,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              SizedBox(height: 8),
              PostCard(
                user: PostCardUser(
                  id: entity.user.id,
                  fullName: entity.user.fullName,
                  userName: entity.user.userName,
                  photo: entity.user.photo,
                ),
                imageUrls: imageUrls,
                description: entity.description,
                timestamp: _formatDate(entity.createdAt),
                isEdited: entity.isEdited,
                onUserTap: () {},
                actionsWidget: PostSocialActions(
                  postId: entity.id,
                  postOwnerId: entity.user.id,
                  postPreview: entity.description.length > 50
                      ? entity.description.substring(0, 50)
                      : entity.description,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final diff = DateTime.now().difference(date);
    if (diff.inDays > 0) return 'Hace ${diff.inDays}d';
    if (diff.inHours > 0) return 'Hace ${diff.inHours}h';
    if (diff.inMinutes > 0) return 'Hace ${diff.inMinutes}m';
    return 'Ahora';
  }
}
