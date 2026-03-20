import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:go_router/go_router.dart';
import 'package:biux/core/design_system/color_tokens.dart';
import 'dart:developer' as developer;

/// Pantalla que muestra todo el contenido al que el usuario le ha dado like.
/// Al quitar el like, desaparece de esta lista.
class ActivityLikesScreen extends StatefulWidget {
  const ActivityLikesScreen({Key? key}) : super(key: key);

  @override
  State<ActivityLikesScreen> createState() => _ActivityLikesScreenState();
}

class _ActivityLikesScreenState extends State<ActivityLikesScreen> {
  final _database = FirebaseDatabase.instance;
  final _firestore = FirebaseFirestore.instance;
  final String? _currentUserId = FirebaseAuth.instance.currentUser?.uid;

  List<_LikedItem> _likedItems = [];
  bool _isLoading = true;
  // ignore: unused_field
  String? _errorMsg;

  @override
  void initState() {
    super.initState();
    _loadLikedContent();
  }

  int _parseTimestamp(dynamic value) {
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }

  Future<void> _loadLikedContent() async {
    if (_currentUserId == null) return;
    setState(() {
      _isLoading = true;
      _errorMsg = null;
    });

    try {
      final List<_LikedItem> items = [];

      // Estrategia: obtener experiences de Firestore, luego verificar likes
      // individuales en RTDB (evita leer el nodo completo que puede estar
      // bloqueado por reglas de seguridad).

      // 1. Obtener posts recientes de Firestore
      try {
        final expSnapshot = await _firestore
            .collection('experiences')
            .orderBy('createdAt', descending: true)
            .limit(500)
            .get();

        developer.log(
          'Experiences a verificar likes: ${expSnapshot.docs.length}',
          name: 'ActivityLikes',
        );

        for (final doc in expSnapshot.docs) {
          try {
            final likeSnap = await _database
                .ref('likes/posts/${doc.id}/$_currentUserId')
                .get();
            if (likeSnap.exists && likeSnap.value != null) {
              int ts = 0;
              if (likeSnap.value is Map) {
                ts = _parseTimestamp((likeSnap.value as Map)['timestamp']);
              }
              final data = doc.data();
              final format = data['format']?.toString() ?? '';
              final user = data['user'] as Map<String, dynamic>?;
              items.add(
                _LikedItem(
                  targetId: doc.id,
                  type: format == 'story' ? 'story' : 'post',
                  timestamp: DateTime.fromMillisecondsSinceEpoch(
                    ts > 0 ? ts : DateTime.now().millisecondsSinceEpoch,
                  ),
                  title: data['description']?.toString() ?? 'Publicación',
                  imageUrl: _extractFirstImage(data),
                  authorName: _extractAuthorName(data),
                  authorId: user?['id']?.toString(),
                ),
              );
            }
          } catch (e) {
            developer.log(
              'Error verificando like para ${doc.id}: $e',
              name: 'ActivityLikes',
            );
          }
        }
      } catch (e) {
        developer.log(
          'Error obteniendo experiences: $e',
          name: 'ActivityLikes',
        );
      }

      // 2. También verificar likes en stories legacy
      try {
        final storiesSnap = await _firestore
            .collection('stories')
            .limit(200)
            .get();

        for (final doc in storiesSnap.docs) {
          try {
            final likeSnap = await _database
                .ref('likes/stories/${doc.id}/$_currentUserId')
                .get();
            if (likeSnap.exists && likeSnap.value != null) {
              int ts = 0;
              int? expiresAt;
              if (likeSnap.value is Map) {
                final likeData = likeSnap.value as Map;
                ts = _parseTimestamp(likeData['timestamp']);
                expiresAt = likeData['expiresAt'] is int
                    ? likeData['expiresAt']
                    : null;
              }
              if (expiresAt != null &&
                  DateTime.now().millisecondsSinceEpoch > expiresAt) {
                continue;
              }
              final data = doc.data();
              final files = data['files'] as List<dynamic>?;
              final user = data['user'] as Map<String, dynamic>?;
              items.add(
                _LikedItem(
                  targetId: doc.id,
                  type: 'story',
                  timestamp: DateTime.fromMillisecondsSinceEpoch(
                    ts > 0 ? ts : DateTime.now().millisecondsSinceEpoch,
                  ),
                  title: data['description']?.toString() ?? 'Historia',
                  imageUrl: files?.isNotEmpty == true
                      ? files!.first.toString()
                      : null,
                  authorName: user?['name']?.toString() ?? '',
                  authorId: user?['id']?.toString(),
                ),
              );
            }
          } catch (_) {}
        }
      } catch (e) {
        developer.log(
          'Error verificando likes stories legacy: $e',
          name: 'ActivityLikes',
        );
      }

      // Ordenar por más reciente
      items.sort((a, b) => b.timestamp.compareTo(a.timestamp));

      developer.log(
        'Total likes encontrados: ${items.length}',
        name: 'ActivityLikes',
      );

      if (mounted) {
        setState(() {
          _likedItems = items;
          _isLoading = false;
        });
      }
    } catch (e) {
      developer.log('Error general en likes: $e', name: 'ActivityLikes');
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMsg = 'Error cargando likes';
        });
      }
    }
  }

  String? _extractFirstImage(Map<String, dynamic> data) {
    final media = data['media'] as List<dynamic>?;
    if (media != null && media.isNotEmpty) {
      final first = media.first as Map<String, dynamic>;
      return first['url'] as String?;
    }
    return null;
  }

  String _extractAuthorName(Map<String, dynamic> data) {
    final user = data['user'] as Map<String, dynamic>?;
    return user?['fullName'] as String? ?? user?['userName'] as String? ?? '';
  }

  Future<void> _unlikeItem(_LikedItem item) async {
    if (_currentUserId == null) return;
    final basePath = item.type == 'post' ? 'likes/posts' : 'likes/stories';
    await _database.ref('$basePath/${item.targetId}/$_currentUserId').remove();
    setState(() {
      _likedItems.remove(item);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorTokens.primary30,
      appBar: AppBar(
        backgroundColor: ColorTokens.primary30,
        foregroundColor: ColorTokens.neutral100,
        title: Text(
          'Me gusta',
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
          : _likedItems.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.favorite_border,
                    color: ColorTokens.neutral60,
                    size: 64,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'No has dado like a nada aún',
                    style: TextStyle(
                      color: ColorTokens.neutral80,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            )
          : RefreshIndicator(
              onRefresh: _loadLikedContent,
              color: ColorTokens.secondary50,
              child: ListView.builder(
                padding: EdgeInsets.all(12),
                itemCount: _likedItems.length,
                itemBuilder: (context, index) {
                  final item = _likedItems[index];
                  return _buildLikedItemCard(item);
                },
              ),
            ),
    );
  }

  Widget _buildLikedItemCard(_LikedItem item) {
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () {
            if (item.type == 'post') {
              context.push('/post-detail/${item.targetId}');
            }
          },
          child: Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: ColorTokens.primary40,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: ColorTokens.neutral60.withValues(alpha: 0.2),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                // Thumbnail
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: item.imageUrl != null
                      ? Image.network(
                          item.imageUrl!,
                          width: 60,
                          height: 60,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => _buildPlaceholder(item),
                        )
                      : _buildPlaceholder(item),
                ),
                SizedBox(width: 12),
                // Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: item.type == 'post'
                                  ? ColorTokens.secondary50.withValues(
                                      alpha: 0.2,
                                    )
                                  : Colors.purple.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              item.type == 'post' ? 'Post' : 'Historia',
                              style: TextStyle(
                                color: item.type == 'post'
                                    ? ColorTokens.secondary50
                                    : Colors.purpleAccent,
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          SizedBox(width: 8),
                          if (item.authorName != null &&
                              item.authorName!.isNotEmpty)
                            Expanded(
                              child: Text(
                                item.authorName!,
                                style: TextStyle(
                                  color: ColorTokens.neutral80,
                                  fontSize: 12,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                        ],
                      ),
                      SizedBox(height: 4),
                      Text(
                        item.title ?? '',
                        style: TextStyle(
                          color: ColorTokens.neutral100,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 4),
                      Text(
                        _formatTimeAgo(item.timestamp),
                        style: TextStyle(
                          color: ColorTokens.neutral60,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                // Unlike button
                IconButton(
                  icon: Icon(Icons.favorite, color: Colors.red, size: 24),
                  onPressed: () => _showUnlikeDialog(item),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPlaceholder(_LikedItem item) {
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        color: ColorTokens.primary50,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(
        item.type == 'post' ? Icons.image : Icons.auto_stories,
        color: ColorTokens.neutral60,
        size: 24,
      ),
    );
  }

  void _showUnlikeDialog(_LikedItem item) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: ColorTokens.primary40,
        title: Text(
          'Quitar Me gusta',
          style: TextStyle(color: ColorTokens.neutral100),
        ),
        content: Text(
          '¿Quieres quitar tu like? Desaparecerá de esta lista.',
          style: TextStyle(color: ColorTokens.neutral80),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(
              'Cancelar',
              style: TextStyle(color: ColorTokens.neutral80),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              _unlikeItem(item);
            },
            child: Text('Quitar', style: TextStyle(color: ColorTokens.error50)),
          ),
        ],
      ),
    );
  }

  String _formatTimeAgo(DateTime date) {
    final diff = DateTime.now().difference(date);
    if (diff.inDays > 365) return 'Hace ${diff.inDays ~/ 365} año(s)';
    if (diff.inDays > 30) return 'Hace ${diff.inDays ~/ 30} mes(es)';
    if (diff.inDays > 0) return 'Hace ${diff.inDays}d';
    if (diff.inHours > 0) return 'Hace ${diff.inHours}h';
    if (diff.inMinutes > 0) return 'Hace ${diff.inMinutes}m';
    return 'Ahora';
  }
}

class _LikedItem {
  final String targetId;
  final String type; // 'post' or 'story'
  final DateTime timestamp;
  String? title;
  String? imageUrl;
  String? authorName;
  String? authorId;

  _LikedItem({
    required this.targetId,
    required this.type,
    required this.timestamp,
    this.title,
    this.imageUrl,
    this.authorName,
    this.authorId,
  });
}
