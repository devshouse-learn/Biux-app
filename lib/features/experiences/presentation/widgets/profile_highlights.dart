import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:biux/core/design_system/color_tokens.dart';
import 'package:biux/core/services/optimized_cache_manager.dart';
import 'package:biux/features/experiences/data/datasources/highlights_datasource.dart';
import 'package:biux/features/experiences/data/repositories/experience_repository_impl.dart';

/// Widget que muestra los highlights (historias destacadas) en el perfil
class ProfileHighlights extends StatefulWidget {
  final String userId;
  final bool isOwnProfile;

  const ProfileHighlights({
    super.key,
    required this.userId,
    this.isOwnProfile = true,
  });

  @override
  State<ProfileHighlights> createState() => _ProfileHighlightsState();
}

class _ProfileHighlightsState extends State<ProfileHighlights> {
  final _ds = HighlightsDatasource();
  List<Map<String, dynamic>> _highlights = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadHighlights();
  }

  Future<void> _loadHighlights() async {
    try {
      final highlights = await _ds.getHighlights(widget.userId);
      if (mounted) {
        setState(() {
          _highlights = highlights;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return SizedBox.shrink();
    if (_highlights.isEmpty && !widget.isOwnProfile) return SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 16),
        SizedBox(
          height: 90,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.symmetric(horizontal: 12),
            children: [
              // Botón "+" para agregar nuevo highlight (solo perfil propio)
              if (widget.isOwnProfile)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: GestureDetector(
                    onTap: () => _showCreateHighlightDialog(context),
                    child: Column(
                      children: [
                        Container(
                          width: 64,
                          height: 64,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: ColorTokens.neutral60,
                              width: 1.5,
                            ),
                          ),
                          child: Icon(
                            Icons.add,
                            color: ColorTokens.neutral60,
                            size: 28,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Nuevo',
                          style: TextStyle(
                            fontSize: 11,
                            color: ColorTokens.neutral80,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ),

              // Highlights existentes
              ..._highlights.map(
                (h) => Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: GestureDetector(
                    onTap: () => _openHighlight(h),
                    onLongPress: widget.isOwnProfile
                        ? () => _showHighlightOptions(context, h)
                        : null,
                    child: Column(
                      children: [
                        Container(
                          width: 64,
                          height: 64,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: ColorTokens.primary30,
                              width: 2,
                            ),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(2),
                            child: ClipOval(
                              child:
                                  (h['coverUrl'] as String?)?.isNotEmpty == true
                                  ? CachedNetworkImage(
                                      imageUrl: h['coverUrl'],
                                      fit: BoxFit.cover,
                                      cacheManager:
                                          OptimizedCacheManager.instance,
                                      placeholder: (_, __) => Container(
                                        color: ColorTokens.neutral20,
                                      ),
                                      errorWidget: (_, __, ___) => Container(
                                        color: ColorTokens.neutral20,
                                        child: Icon(
                                          Icons.auto_stories,
                                          color: ColorTokens.neutral60,
                                        ),
                                      ),
                                    )
                                  : Container(
                                      color: ColorTokens.neutral20,
                                      child: Icon(
                                        Icons.auto_stories,
                                        color: ColorTokens.neutral60,
                                      ),
                                    ),
                            ),
                          ),
                        ),
                        SizedBox(height: 4),
                        SizedBox(
                          width: 64,
                          child: Text(
                            h['title'] ?? 'Destacado',
                            style: TextStyle(
                              fontSize: 11,
                              color: ColorTokens.neutral80,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _openHighlight(Map<String, dynamic> highlight) {
    final storyIds = (highlight['storyIds'] as List<dynamic>?)?.cast<String>();
    if (storyIds != null && storyIds.isNotEmpty) {
      // Navigate to first story in the highlight
      context.push('/stories/${storyIds.first}');
    }
  }

  void _showHighlightOptions(
    BuildContext context,
    Map<String, dynamic> highlight,
  ) {
    showModalBottomSheet(
      context: context,
      backgroundColor: ColorTokens.neutral20,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: ColorTokens.neutral60,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          ListTile(
            leading: Icon(Icons.edit_outlined, color: ColorTokens.primary50),
            title: Text(
              'Editar nombre',
              style: TextStyle(color: ColorTokens.neutral100),
            ),
            onTap: () {
              Navigator.pop(ctx);
              _showRenameDialog(context, highlight);
            },
          ),
          ListTile(
            leading: Icon(Icons.delete_outline, color: ColorTokens.error50),
            title: Text(
              'Eliminar destacado',
              style: TextStyle(color: ColorTokens.error50),
            ),
            onTap: () async {
              Navigator.pop(ctx);
              await _ds.deleteHighlight(
                userId: widget.userId,
                highlightId: highlight['id'],
              );
              _loadHighlights();
            },
          ),
          SizedBox(height: 8),
        ],
      ),
    );
  }

  void _showRenameDialog(BuildContext context, Map<String, dynamic> highlight) {
    final controller = TextEditingController(text: highlight['title'] ?? '');
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Renombrar destacado'),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(
            hintText: 'Nombre del destacado',
            border: OutlineInputBorder(),
          ),
          maxLength: 20,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              final newTitle = controller.text.trim();
              if (newTitle.isNotEmpty) {
                await _ds.updateHighlight(
                  userId: widget.userId,
                  highlightId: highlight['id'],
                  title: newTitle,
                );
                Navigator.pop(ctx);
                _loadHighlights();
              }
            },
            child: Text('Guardar'),
          ),
        ],
      ),
    );
  }

  void _showCreateHighlightDialog(BuildContext context) async {
    // Load user stories first
    try {
      final experiences = await ExperienceRepositoryImpl().getUserExperiences(
        widget.userId,
      );

      final stories = (experiences as List<dynamic>)
          .where((e) => e.isStoryFormat == true)
          .toList();

      if (stories.isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('No tienes historias para destacar'),
              backgroundColor: ColorTokens.warning50,
            ),
          );
        }
        return;
      }

      if (!mounted) return;

      final titleController = TextEditingController();
      final selectedIds = <String>{};

      showDialog(
        context: context,
        builder: (ctx) => StatefulBuilder(
          builder: (context, setDialogState) => AlertDialog(
            title: Text('Crear Destacado'),
            content: SizedBox(
              width: double.maxFinite,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: titleController,
                    decoration: InputDecoration(
                      hintText: 'Nombre del destacado',
                      border: OutlineInputBorder(),
                    ),
                    maxLength: 20,
                  ),
                  SizedBox(height: 12),
                  Text(
                    'Selecciona historias:',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  SizedBox(height: 8),
                  SizedBox(
                    height: 200,
                    child: GridView.builder(
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        crossAxisSpacing: 4,
                        mainAxisSpacing: 4,
                      ),
                      itemCount: stories.length,
                      itemBuilder: (context, index) {
                        final story = stories[index];
                        final isSelected = selectedIds.contains(story.id);
                        final mediaUrl = story.media.isNotEmpty
                            ? (story.media.first.thumbnailUrl ??
                                  story.media.first.url)
                            : '';
                        return GestureDetector(
                          onTap: () {
                            setDialogState(() {
                              if (isSelected) {
                                selectedIds.remove(story.id);
                              } else {
                                selectedIds.add(story.id);
                              }
                            });
                          },
                          child: Stack(
                            fit: StackFit.expand,
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(4),
                                child: mediaUrl.isNotEmpty
                                    ? CachedNetworkImage(
                                        imageUrl: mediaUrl,
                                        fit: BoxFit.cover,
                                        cacheManager:
                                            OptimizedCacheManager.instance,
                                      )
                                    : Container(color: ColorTokens.neutral20),
                              ),
                              if (isSelected)
                                Container(
                                  decoration: BoxDecoration(
                                    color: ColorTokens.primary30.withValues(
                                      alpha: 0.5,
                                    ),
                                    borderRadius: BorderRadius.circular(4),
                                    border: Border.all(
                                      color: ColorTokens.primary30,
                                      width: 2,
                                    ),
                                  ),
                                  child: Center(
                                    child: Icon(
                                      Icons.check_circle,
                                      color: Colors.white,
                                      size: 28,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: Text('Cancelar'),
              ),
              ElevatedButton(
                onPressed: selectedIds.isEmpty
                    ? null
                    : () async {
                        final title = titleController.text.trim().isNotEmpty
                            ? titleController.text.trim()
                            : 'Destacado';

                        // Use first selected story's media as cover
                        String coverUrl = '';
                        final firstStory = stories.firstWhere(
                          (s) => selectedIds.contains(s.id),
                          orElse: () => stories.first,
                        );
                        if (firstStory.media.isNotEmpty) {
                          coverUrl =
                              firstStory.media.first.thumbnailUrl ??
                              firstStory.media.first.url;
                        }

                        await _ds.createHighlight(
                          userId: widget.userId,
                          title: title,
                          coverUrl: coverUrl,
                          storyIds: selectedIds.toList(),
                        );

                        Navigator.pop(ctx);
                        _loadHighlights();
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: ColorTokens.primary30,
                  foregroundColor: ColorTokens.neutral100,
                ),
                child: Text('Crear'),
              ),
            ],
          ),
        ),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error cargando historias'),
            backgroundColor: ColorTokens.error50,
          ),
        );
      }
    }
  }
}
