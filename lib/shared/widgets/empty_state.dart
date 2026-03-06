
import 'package:flutter/material.dart';
import 'package:biux/core/design_system/color_tokens.dart';

class EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final String? actionText;
  final VoidCallback? onAction;
  final String? emoji;

  const EmptyState({
    Key? key,
    required this.icon,
    required this.title,
    required this.description,
    this.actionText,
    this.onAction,
    this.emoji,
  }) : super(key: key);

  // Factorías para empty states comunes
  factory EmptyState.noRides({VoidCallback? onAction}) => EmptyState(
    icon: Icons.directions_bike_rounded,
    emoji: '🚴',
    title: 'Sin rodadas aún',
    description: 'No hay rodadas programadas. ¡Crea la primera!',
    actionText: 'Crear rodada',
    onAction: onAction,
  );

  factory EmptyState.noGroups({VoidCallback? onAction}) => EmptyState(
    icon: Icons.group_rounded,
    emoji: '👥',
    title: 'Sin grupos',
    description: 'Únete a un grupo o crea el tuyo propio.',
    actionText: 'Explorar grupos',
    onAction: onAction,
  );

  factory EmptyState.noPosts() => const EmptyState(
    icon: Icons.photo_camera_rounded,
    emoji: '📸',
    title: 'Sin publicaciones',
    description: 'Aquí aparecerán las publicaciones. ¡Comparte tu primera experiencia!',
  );

  factory EmptyState.noMessages({VoidCallback? onAction}) => EmptyState(
    icon: Icons.chat_bubble_outline_rounded,
    emoji: '💬',
    title: 'Sin mensajes',
    description: 'Inicia una conversación con otro ciclista.',
    actionText: 'Nuevo mensaje',
    onAction: onAction,
  );

  factory EmptyState.noNotifications() => const EmptyState(
    icon: Icons.notifications_none_rounded,
    emoji: '🔔',
    title: 'Sin notificaciones',
    description: 'Las notificaciones de actividad aparecerán aquí.',
  );

  factory EmptyState.noResults() => const EmptyState(
    icon: Icons.search_off_rounded,
    emoji: '🔍',
    title: 'Sin resultados',
    description: 'Intenta buscar con otros términos.',
  );

  factory EmptyState.noBikes({VoidCallback? onAction}) => EmptyState(
    icon: Icons.pedal_bike_rounded,
    emoji: '🚲',
    title: 'Sin bicicletas',
    description: 'Registra tu bicicleta para protegerla.',
    actionText: 'Registrar bicicleta',
    onAction: onAction,
  );

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (emoji != null) ...[
              Text(emoji!, style: const TextStyle(fontSize: 56)),
              const SizedBox(height: 8),
            ],
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: ColorTokens.primary30.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 48, color: ColorTokens.primary30.withValues(alpha: 0.5)),
            ),
            const SizedBox(height: 24),
            Text(title, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.grey[700]), textAlign: TextAlign.center),
            const SizedBox(height: 8),
            Text(description, style: TextStyle(fontSize: 14, color: Colors.grey[500], height: 1.5), textAlign: TextAlign.center),
            if (actionText != null && onAction != null) ...[
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: onAction,
                icon: const Icon(Icons.add_rounded, size: 20),
                label: Text(actionText!),
                style: ElevatedButton.styleFrom(
                  backgroundColor: ColorTokens.primary30,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
