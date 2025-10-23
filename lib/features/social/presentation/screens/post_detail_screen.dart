import 'package:flutter/material.dart';
import 'package:biux/features/experiences/presentation/screens/experiences_list_screen.dart';

/// Pantalla de detalle de un post/experiencia
/// Simplemente redirige a la lista de experiencias
class PostDetailScreen extends StatelessWidget {
  final String postId;

  const PostDetailScreen({super.key, required this.postId});

  @override
  Widget build(BuildContext context) {
    // Por ahora simplemente muestra la lista completa
    // La funcionalidad de filtrar un solo post se puede agregar después
    return const ExperiencesListScreen();
  }
}
