import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:go_router/go_router.dart';
import 'package:biux/core/design_system/color_tokens.dart';
import 'dart:developer' as developer;
import 'package:biux/core/design_system/locale_notifier.dart';
import 'package:provider/provider.dart';

/// Pantalla que muestra todos los comentarios realizados por el usuario.
/// Al seleccionar uno lleva al post/contenido donde se hizo el comentario.
class ActivityCommentsScreen extends StatefulWidget {
  const ActivityCommentsScreen({Key? key}) : super(key: key);

  @override
  State<ActivityCommentsScreen> createState() => _ActivityCommentsScreenState();
}

class _ActivityCommentsScreenState extends State<ActivityCommentsScreen> {
  LocaleNotifier get l => Provider.of<LocaleNotifier>(context);

  final _database = FirebaseDatabase.instance;
  final _firestore = FirebaseFirestore.instance;
  final String? _currentUserId = FirebaseAuth.instance.currentUser?.uid;

  List<_CommentItem> _comments = [];
  bool _isLoading = true;
  bool _isNavigating = false;

  @override
  void initState() {
    super.initState();
    _loadUserComments();
  }

  int _parseTimestamp(dynamic value) {
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }

  Future<void> _loadUserComments() async {
    if (_currentUserId == null) return;
    setState(() => _isLoading = true);

    try {
      final expSnapshot = await _firestore
          .collection('experiences')
          .orderBy('createdAt', descending: true)
          .limit(200)
          .get();

      // Consultar comentarios de todos los posts en paralelo por lotes
      final List<_CommentItem> items = [];
      const batchSize = 30;

      for (int i = 0; i < expSnapshot.docs.length; i += batchSize) {
        final batch = expSnapshot.docs.skip(i).take(batchSize);
        final futures = batch.map((doc) async {
          final List<_CommentItem> docItems = [];
          try {
            // Descargar todos los comentarios del post y filtrar por userId localmente
            final commentsSnap = await _database
                .ref('comments/posts/${doc.id}')
                .get();

            if (commentsSnap.exists && commentsSnap.value != null) {
              final commentsData = commentsSnap.value;
              if (commentsData is! Map) return docItems;
              final commentsMap = commentsData;
              final expData = doc.data();
              final media = expData['media'] as List<dynamic>?;
              String? postImage;
              if (media != null && media.isNotEmpty) {
                final first = media.first;
                if (first is Map) {
                  postImage = first['url']?.toString();
                }
              }
              final user = expData['user'] as Map<String, dynamic>?;

              for (final commentEntry in commentsMap.entries) {
                final commentData = commentEntry.value;
                if (commentData is! Map) continue;
                // Filtrar: solo comentarios del usuario actual
                final commentUserId = commentData['userId']?.toString();
                if (commentUserId != _currentUserId) continue;
                if (commentData['isDeleted'] == true) continue;

                final createdAt = _parseTimestamp(commentData['createdAt']);
                docItems.add(
                  _CommentItem(
                    commentId: commentEntry.key.toString(),
                    postId: doc.id,
                    text: commentData['text']?.toString() ?? '',
                    timestamp: DateTime.fromMillisecondsSinceEpoch(
                      createdAt > 0
                          ? createdAt
                          : DateTime.now().millisecondsSinceEpoch,
                    ),
                    parentCommentId: commentData['parentCommentId']?.toString(),
                    postDescription:
                        expData['description']?.toString() ?? l.t('publication'),
                    postImageUrl: postImage,
                    postAuthorName:
                        user?['fullName']?.toString() ??
                        user?['userName']?.toString() ??
                        '',
                    postAuthorId: user?['id']?.toString(),
                  ),
                );
              }
            }
          } catch (_) {}
          return docItems;
        });
        final batchResults = await Future.wait(futures);
        for (final docItems in batchResults) {
          items.addAll(docItems);
        }
      }

      items.sort((a, b) => b.timestamp.compareTo(a.timestamp));

      if (mounted) {
        setState(() {
          _comments = items;
          _isLoading = false;
        });
      }
    } catch (e) {
      developer.log(
        'Error general en comentarios: $e',
        name: 'ActivityComments',
      );
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
          l.t('comments_label'),
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
          : _comments.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.chat_bubble_outline,
                    color: ColorTokens.neutral60,
                    size: 64,
                  ),
                  SizedBox(height: 16),
                  Text(
                    l.t('no_comments_yet'),
                    style: TextStyle(
                      color: ColorTokens.neutral80,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            )
          : RefreshIndicator(
              onRefresh: _loadUserComments,
              color: ColorTokens.secondary50,
              child: ListView.builder(
                padding: EdgeInsets.all(12),
                itemCount: _comments.length,
                itemBuilder: (context, index) =>
                    _buildCommentCard(_comments[index]),
              ),
            ),
    );
  }

  Widget _buildCommentCard(_CommentItem item) {
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () {
            if (_isNavigating) return;
            _isNavigating = true;
            context
                .push('/post-detail/${item.postId}')
                .then((_) {
                  _isNavigating = false;
                })
                .catchError((_) {
                  _isNavigating = false;
                });
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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Thumbnail del post
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: item.postImageUrl != null
                      ? Image.network(
                          item.postImageUrl!,
                          width: 50,
                          height: 50,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => _buildPlaceholder(),
                        )
                      : _buildPlaceholder(),
                ),
                SizedBox(width: 12),
                // Comment content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (item.postAuthorName != null &&
                          item.postAuthorName!.isNotEmpty)
                        Text(
                          'En post de ${item.postAuthorName}',
                          style: TextStyle(
                            color: ColorTokens.neutral80,
                            fontSize: 12,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      SizedBox(height: 4),
                      // El comentario del usuario
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: ColorTokens.secondary50.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          item.text,
                          style: TextStyle(
                            color: ColorTokens.neutral100,
                            fontSize: 14,
                          ),
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      SizedBox(height: 4),
                      Row(
                        children: [
                          if (item.parentCommentId != null)
                            Container(
                              margin: EdgeInsets.only(right: 8),
                              padding: EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: ColorTokens.neutral60.withValues(
                                  alpha: 0.2,
                                ),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                'Respuesta',
                                style: TextStyle(
                                  color: ColorTokens.neutral60,
                                  fontSize: 10,
                                ),
                              ),
                            ),
                          Text(
                            _formatTimeAgo(item.timestamp),
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
                Icon(
                  Icons.arrow_forward_ios,
                  color: ColorTokens.neutral60,
                  size: 16,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        color: ColorTokens.primary50,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(Icons.image, color: ColorTokens.neutral60, size: 20),
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

class _CommentItem {
  final String commentId;
  final String postId;
  final String text;
  final DateTime timestamp;
  final String? parentCommentId;
  String? postDescription;
  String? postImageUrl;
  String? postAuthorName;
  String? postAuthorId;

  _CommentItem({
    required this.commentId,
    required this.postId,
    required this.text,
    required this.timestamp,
    this.parentCommentId,
    this.postDescription,
    this.postImageUrl,
    this.postAuthorName,
    this.postAuthorId,
  });
}
