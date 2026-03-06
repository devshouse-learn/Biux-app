import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:biux/features/experiences/presentation/providers/story_groups_provider.dart';
import 'package:biux/features/experiences/domain/entities/user_story_group_entity.dart';
import 'package:biux/shared/widgets/optimized_network_image.dart';
import 'package:biux/core/design_system/color_tokens.dart';

/// Widget de lista horizontal de historias agrupadas por usuario
/// Similar a Instagram Stories en la parte superior
class StoryGroupsList extends StatelessWidget {
  final String currentUserId;
  final VoidCallback? onAddStory;

  const StoryGroupsList({
    super.key,
    required this.currentUserId,
    this.onAddStory,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<StoryGroupsProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) {
          return const _LoadingStoryGroups();
        }

        if (provider.error != null) {
          return const SizedBox.shrink();
        }

        if (provider.storyGroups.isEmpty) {
          return const SizedBox.shrink();
        }

        return SizedBox(
          height: 110,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            itemCount: provider.storyGroups.length + 1, // +1 para "Tu historia"
            itemBuilder: (context, index) {
              // Primer ítem: "Agregar tu historia"
              if (index == 0) {
                return _AddStoryItem(onTap: onAddStory);
              }

              // Grupos de historias de otros usuarios
              final group = provider.storyGroups[index - 1];
              return _StoryGroupItem(
                group: group,
                onTap: () => _openStoryViewer(context, group, provider),
              );
            },
          ),
        );
      },
    );
  }

  void _openStoryViewer(
    BuildContext context,
    UserStoryGroupEntity group,
    StoryGroupsProvider provider,
  ) {
    // Navegar al visor de historias
    // IMPLEMENTADO (STUB): Implementar navegación al StoryViewer
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => StoryViewerScreen(
          storyGroup: group,
          onStoryViewed: (storyId) {
            provider.markStoryAsViewed(storyId);
          },
          onGroupCompleted: () {
            provider.markUserStoriesAsViewed(group.userId);
          },
        ),
      ),
    );
  }
}

/// Item individual de grupo de historias
class _StoryGroupItem extends StatelessWidget {
  final UserStoryGroupEntity group;
  final VoidCallback onTap;

  const _StoryGroupItem({required this.group, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6),
      child: GestureDetector(
        onTap: onTap,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Avatar con borde
            Container(
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: group.hasUnseenStories
                    ? const LinearGradient(
                        colors: [
                          Color(0xFFFF6B6B), // Rojo
                          Color(0xFFFFB84D), // Naranja
                          Color(0xFFFFD93D), // Amarillo
                        ],
                        begin: Alignment.topRight,
                        end: Alignment.bottomLeft,
                      )
                    : null,
                border: !group.hasUnseenStories
                    ? Border.all(color: Colors.grey.shade300, width: 2)
                    : null,
              ),
              padding: const EdgeInsets.all(3),
              child: Container(
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                ),
                padding: const EdgeInsets.all(2),
                child: ClipOval(
                  child: OptimizedNetworkImage(
                    imageUrl: group.userProfilePhoto,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 4),
            // Nombre del usuario
            SizedBox(
              width: 70,
              child: Text(
                group.userName,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Item para agregar nueva historia
class _AddStoryItem extends StatelessWidget {
  final VoidCallback? onTap;

  const _AddStoryItem({this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6),
      child: GestureDetector(
        onTap: onTap,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Avatar con ícono +
            Container(
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.grey.shade300, width: 2),
              ),
              child: Stack(
                children: [
                  // Foto de perfil del usuario actual
                  Positioned.fill(
                    child: ClipOval(
                      child: Container(
                        color: Colors.grey.shade200,
                        child: Icon(
                          Icons.person,
                          size: 35,
                          color: Colors.grey.shade400,
                        ),
                      ),
                    ),
                  ),
                  // Botón + en la esquina
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: ColorTokens.primary30,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                      child: const Icon(
                        Icons.add,
                        size: 16,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 4),
            const SizedBox(
              width: 70,
              child: Text(
                'Tu historia',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Widget de carga mientras se obtienen las historias
class _LoadingStoryGroups extends StatelessWidget {
  const _LoadingStoryGroups();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 110,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        itemCount: 5,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 70,
                  height: 70,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.grey.shade300,
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  width: 50,
                  height: 12,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

/// Pantalla placeholder para el visor de historias
/// IMPLEMENTADO (STUB): Implementar visor completo de historias
class StoryViewerScreen extends StatelessWidget {
  final UserStoryGroupEntity storyGroup;
  final Function(String storyId) onStoryViewed;
  final VoidCallback onGroupCompleted;

  const StoryViewerScreen({
    super.key,
    required this.storyGroup,
    required this.onStoryViewed,
    required this.onGroupCompleted,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Visor de historias de ${storyGroup.userName}',
              style: const TextStyle(color: Colors.white, fontSize: 18),
            ),
            const SizedBox(height: 20),
            Text(
              '${storyGroup.totalStories} historias',
              style: const TextStyle(color: Colors.white70),
            ),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: () {
                // Marcar todas como vistas al cerrar
                onGroupCompleted();
                Navigator.pop(context);
              },
              child: const Text('Cerrar'),
            ),
          ],
        ),
      ),
    );
  }
}
