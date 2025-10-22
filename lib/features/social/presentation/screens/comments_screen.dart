import 'package:flutter/material.dart';
import '../../domain/repositories/comments_repository.dart';
import '../widgets/comments_list.dart';

/// Pantalla de comentarios de un post
class PostCommentsScreen extends StatelessWidget {
  final String postId;
  final String postOwnerId;

  const PostCommentsScreen({
    super.key,
    required this.postId,
    required this.postOwnerId,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Comentarios')),
      body: SafeArea(
        child: CommentsList(
          type: CommentableType.post,
          targetId: postId,
          targetOwnerId: postOwnerId,
          showTextField: true,
          placeholder: 'Escribe un comentario...',
        ),
      ),
    );
  }
}

/// Pantalla de comentarios de una rodada
class RideCommentsScreen extends StatelessWidget {
  final String rideId;
  final String rideOwnerId;

  const RideCommentsScreen({
    super.key,
    required this.rideId,
    required this.rideOwnerId,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Comentarios')),
      body: SafeArea(
        child: CommentsList(
          type: CommentableType.ride,
          targetId: rideId,
          targetOwnerId: rideOwnerId,
          showTextField: true,
          placeholder: 'Comenta sobre esta rodada...',
        ),
      ),
    );
  }
}
