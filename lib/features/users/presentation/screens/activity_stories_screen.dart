import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:go_router/go_router.dart';
import 'package:biux/core/design_system/color_tokens.dart';
import 'package:biux/features/experiences/data/models/experience_model.dart';
import 'package:biux/features/experiences/domain/entities/experience_entity.dart';
import 'dart:developer' as developer;

/// Pantalla que muestra todas las historias (stories) subidas por el usuario.
/// Grid estilo Instagram de thumbnails.
class ActivityStoriesScreen extends StatefulWidget {
  const ActivityStoriesScreen({Key? key}) : super(key: key);

  @override
  State<ActivityStoriesScreen> createState() => _ActivityStoriesScreenState();
}

class _ActivityStoriesScreenState extends State<ActivityStoriesScreen> {
  final _firestore = FirebaseFirestore.instance;
  final String? _currentUserId = FirebaseAuth.instance.currentUser?.uid;

  List<_StoryItem> _stories = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserStories();
  }

  Future<void> _loadUserStories() async {
    if (_currentUserId == null) return;
    setState(() => _isLoading = true);

    try {
      final List<_StoryItem> items = [];

      // 1. Stories del sistema nuevo (experiences con format=story)
      // No usar orderBy para evitar requerir índice compuesto
      try {
        final expSnapshot = await _firestore
            .collection('experiences')
            .where('user.id', isEqualTo: _currentUserId)
            .get();

        developer.log(
          'Experiences encontradas: ${expSnapshot.docs.length}',
          name: 'ActivityStories',
        );

        for (final doc in expSnapshot.docs) {
          try {
            final data = doc.data();
            data['id'] = doc.id;
            final model = ExperienceModel.fromJson(data);
            if (model.format == ExperienceFormat.story) {
              final firstMedia = model.media.isNotEmpty
                  ? model.media.first.url
                  : null;
              items.add(
                _StoryItem(
                  id: doc.id,
                  imageUrl: firstMedia,
                  description: model.description,
                  createdAt: model.createdAt,
                  source: 'experience',
                  viewCount: model.views,
                ),
              );
            }
          } catch (e) {
            developer.log(
              'Error parseando experience story: $e',
              name: 'ActivityStories',
            );
          }
        }
      } catch (e) {
        developer.log(
          'Error consultando experiences: $e',
          name: 'ActivityStories',
        );
      }

      // 2. Stories del sistema legacy (colección stories)
      // No usar orderBy para evitar requerir índice compuesto
      try {
        final storiesSnapshot = await _firestore
            .collection('stories')
            .where('user.id', isEqualTo: _currentUserId)
            .get();

        developer.log(
          'Legacy stories encontradas: ${storiesSnapshot.docs.length}',
          name: 'ActivityStories',
        );

        for (final doc in storiesSnapshot.docs) {
          try {
            final data = doc.data();
            final files = data['files'] as List<dynamic>? ?? [];
            final desc = data['description']?.toString() ?? '';
            final creationDate = data['creationDate']?.toString() ?? '';
            DateTime? created;
            try {
              created = DateTime.tryParse(creationDate);
            } catch (_) {}

            items.add(
              _StoryItem(
                id: doc.id,
                imageUrl: files.isNotEmpty ? files.first.toString() : null,
                description: desc,
                createdAt: created ?? DateTime.now(),
                source: 'legacy',
                viewCount: 0,
              ),
            );
          } catch (e) {
            developer.log(
              'Error parseando legacy story: $e',
              name: 'ActivityStories',
            );
          }
        }
      } catch (e) {
        developer.log(
          'Error consultando legacy stories: $e',
          name: 'ActivityStories',
        );
      }

      // Filtrar stories expiradas (>24h) que ya no son visibles
      final now = DateTime.now();
      final activeItems = items.where((s) {
        return now.difference(s.createdAt).inHours < 24;
      }).toList();

      // Ordenar por fecha (client-side)
      activeItems.sort((a, b) => b.createdAt.compareTo(a.createdAt));

      if (mounted) {
        setState(() {
          _stories = activeItems;
          _isLoading = false;
        });
      }
    } catch (e) {
      developer.log('Error general en stories: $e', name: 'ActivityStories');
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
          'Mis Historias',
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
          : _stories.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.auto_stories_outlined,
                    color: ColorTokens.neutral60,
                    size: 64,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'No has compartido historias aún',
                    style: TextStyle(
                      color: ColorTokens.neutral80,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            )
          : RefreshIndicator(
              onRefresh: _loadUserStories,
              color: ColorTokens.secondary50,
              child: GridView.builder(
                padding: EdgeInsets.all(4),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 4,
                  mainAxisSpacing: 4,
                  childAspectRatio: 9 / 16,
                ),
                itemCount: _stories.length,
                itemBuilder: (context, index) =>
                    _buildStoryTile(_stories[index]),
              ),
            ),
    );
  }

  Widget _buildStoryTile(_StoryItem story) {
    return GestureDetector(
      onTap: () {
        // Mostrar detalle de la historia
        _showStoryDetail(story);
      },
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Imagen
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: story.imageUrl != null
                ? Image.network(
                    story.imageUrl!,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      color: ColorTokens.primary40,
                      child: Icon(
                        Icons.auto_stories,
                        color: ColorTokens.neutral60,
                        size: 32,
                      ),
                    ),
                  )
                : Container(
                    color: ColorTokens.primary40,
                    child: Icon(
                      Icons.auto_stories,
                      color: ColorTokens.neutral60,
                      size: 32,
                    ),
                  ),
          ),
          // Gradient overlay
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(4),
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.7),
                  ],
                  stops: [0.5, 1.0],
                ),
              ),
            ),
          ),
          // Info overlay
          Positioned(
            bottom: 8,
            left: 8,
            right: 8,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (story.description.isNotEmpty)
                  Text(
                    story.description,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                SizedBox(height: 2),
                Text(
                  _formatDate(story.createdAt),
                  style: TextStyle(color: Colors.white70, fontSize: 10),
                ),
              ],
            ),
          ),
          // View count
          if (story.viewCount > 0)
            Positioned(
              top: 8,
              left: 8,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.visibility, color: Colors.white, size: 12),
                    SizedBox(width: 4),
                    Text(
                      '${story.viewCount}',
                      style: TextStyle(color: Colors.white, fontSize: 11),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  void _showStoryDetail(_StoryItem story) {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: EdgeInsets.all(16),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Container(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.8,
            ),
            color: ColorTokens.primary30,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Story image
                Flexible(
                  child: story.imageUrl != null
                      ? Image.network(
                          story.imageUrl!,
                          fit: BoxFit.contain,
                          width: double.infinity,
                          errorBuilder: (_, __, ___) => Container(
                            height: 300,
                            color: ColorTokens.primary40,
                            child: Icon(
                              Icons.broken_image,
                              color: ColorTokens.neutral60,
                              size: 48,
                            ),
                          ),
                        )
                      : Container(
                          height: 300,
                          color: ColorTokens.primary40,
                          child: Icon(
                            Icons.auto_stories,
                            color: ColorTokens.neutral60,
                            size: 48,
                          ),
                        ),
                ),
                // Description
                if (story.description.isNotEmpty)
                  Padding(
                    padding: EdgeInsets.all(16),
                    child: Text(
                      story.description,
                      style: TextStyle(
                        color: ColorTokens.neutral100,
                        fontSize: 14,
                      ),
                    ),
                  ),
                // Footer
                Padding(
                  padding: EdgeInsets.fromLTRB(16, 0, 16, 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _formatDate(story.createdAt),
                        style: TextStyle(
                          color: ColorTokens.neutral60,
                          fontSize: 12,
                        ),
                      ),
                      if (story.viewCount > 0)
                        Row(
                          children: [
                            Icon(
                              Icons.visibility,
                              color: ColorTokens.neutral60,
                              size: 16,
                            ),
                            SizedBox(width: 4),
                            Text(
                              '${story.viewCount} vistas',
                              style: TextStyle(
                                color: ColorTokens.neutral60,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final diff = DateTime.now().difference(date);
    if (diff.inDays > 365) return 'Hace ${diff.inDays ~/ 365} año(s)';
    if (diff.inDays > 30) return 'Hace ${diff.inDays ~/ 30} mes(es)';
    if (diff.inDays > 0) return 'Hace ${diff.inDays}d';
    if (diff.inHours > 0) return 'Hace ${diff.inHours}h';
    if (diff.inMinutes > 0) return 'Hace ${diff.inMinutes}m';
    return 'Ahora';
  }
}

class _StoryItem {
  final String id;
  final String? imageUrl;
  final String description;
  final DateTime createdAt;
  final String source; // 'experience' or 'legacy'
  final int viewCount;

  _StoryItem({
    required this.id,
    this.imageUrl,
    required this.description,
    required this.createdAt,
    required this.source,
    this.viewCount = 0,
  });
}
