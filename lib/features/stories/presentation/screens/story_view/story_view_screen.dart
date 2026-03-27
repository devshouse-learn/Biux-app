import 'package:biux/core/config/styles.dart';
import 'package:biux/core/design_system/locale_notifier.dart';
import 'package:biux/core/utils/strings_utils.dart';
import 'package:biux/features/stories/data/models/story.dart';
import 'package:biux/features/authentication/data/repositories/authentication_repository.dart';
import 'package:biux/core/utils/share_utils.dart';
import 'package:biux/features/stories/presentation/screens/story_view/story_view_bloc.dart';
import 'package:biux/shared/services/optimized_cache_manager.dart';
import 'package:biux/shared/widgets/post_card.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_image_viewer/easy_image_viewer.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:readmore/readmore.dart';

class StoryViewScreen extends StatelessWidget {
  const StoryViewScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bloc = context.watch<StoryViewBloc>();

    // Separar historias publicidad de historias normales
    final advertisementStories = <Story>[];
    final regularStories = <Story>[];

    for (final story in bloc.listStory) {
      if (story.isAdvertisement) {
        advertisementStories.add(story);
      } else {
        regularStories.add(story);
      }
    }

    // Combinar: primero publicidades, luego historias normales
    final displayStories = [...advertisementStories, ...regularStories];

    return Scaffold(
      body: ListView.builder(
        itemCount: displayStories.length,
        itemBuilder: (context, index) {
          final story = displayStories[index];
          return _StoryWidget(
            story: story,
            isAdvertisement: story.isAdvertisement,
          );
        },
      ),
    );
  }

  // --- Clases privadas movidas a top-level ---
}

class _StoryWidget extends StatelessWidget {
  final Story story;
  final bool isAdvertisement;
  const _StoryWidget({
    Key? key,
    required this.story,
    this.isAdvertisement = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final l = Provider.of<LocaleNotifier>(context, listen: false);
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: PostCard(
        user: PostCardUser(
          id: story.user.id,
          fullName: story.user.fullName,
          userName: story.user.userName,
          photo: story.user.photo,
        ),
        imageUrls: story.files,
        description: '',
        timestamp: story.creationDate.timeHaveCreated,
        onImageTap: (index) {
          final imageProvider = CachedNetworkImageProvider(
            story.files[index],
            cacheManager: OptimizedCacheManager.instance,
          );
          showImageViewer(
            context,
            imageProvider,
            backgroundColor: Theme.of(
              context,
            ).scaffoldBackgroundColor.withValues(alpha: 0.9),
            useSafeArea: true,
            immersive: false,
          );
        },
        headerTrailing: [
          if (isAdvertisement)
            Container(
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFFFD700), Color(0xFFFFA500)],
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.flash_on, color: Colors.white, size: 12),
                  const SizedBox(width: 2),
                  Text(
                    l.t('advertising_label'),
                    style: Styles.accentTextThemeWhite.copyWith(
                      color: Colors.white,
                      fontSize: 9,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
            ),
          if (story.user.id == AuthenticationRepository().getUserId)
            GestureDetector(
              onTap: () => _showDeleteConfirmation(context),
              child: const Icon(
                Icons.delete_outline,
                color: Colors.red,
                size: 20,
              ),
            ),
          const SizedBox(width: 4),
          GestureDetector(
            onTap: () => ShareUtils().shareFile(
              filePath: story.fileUrl1,
              text: '${story.user.userName}${l.t('text_share_story')}',
              title: l.t('title_share_story'),
            ),
            child: const Icon(Icons.share, color: Colors.white70, size: 20),
          ),
        ],
        descriptionWidget:
            (story.description.isNotEmpty || story.tags.isNotEmpty)
            ? Padding(
                padding: const EdgeInsets.fromLTRB(0, 12, 0, 4),
                child: ReadMoreText(
                  story.description +
                      (story.tags.isNotEmpty
                          ? '\n' +
                                story.tags
                                    .map((e) => '#$e')
                                    .toString()
                                    .replaceAll(')', '')
                                    .replaceAll('(', '')
                          : ''),
                  textAlign: TextAlign.left,
                  preDataText: story.user.userName,
                  preDataTextStyle: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                  style: const TextStyle(color: Colors.white70, fontSize: 14),
                  trimLines: 2,
                  trimMode: TrimMode.Line,
                  trimCollapsedText: l.t('see_more'),
                  trimExpandedText: l.t('see_less'),
                  moreStyle: Styles.moreStyle.copyWith(
                    color: Theme.of(context).primaryColor,
                  ),
                  lessStyle: Styles.moreStyle.copyWith(
                    color: Theme.of(context).primaryColor,
                  ),
                ),
              )
            : null,
        galleryOverlays: [_StoryLikeOverlay(story: story)],
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context) {
    final bloc = context.read<StoryViewBloc>();
    final l = Provider.of<LocaleNotifier>(context, listen: false);
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(l.t('delete_story')),
          content: Text(l.t('delete_story_confirm_no_undo')),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(l.t('cancel')),
            ),
            TextButton(
              onPressed: () {
                bloc.deleteStory(story: story);
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(l.t('story_deleted')),
                    duration: Duration(seconds: 2),
                  ),
                );
              },
              child: Text(l.t('delete'), style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }
}

/// Overlay de like posicionado en la esquina inferior derecha de la imagen.
/// El contador de likes solo es visible para el dueño de la historia.
class _StoryLikeOverlay extends StatelessWidget {
  final Story story;

  const _StoryLikeOverlay({Key? key, required this.story}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final idUser = AuthenticationRepository().getUserId;
    final isOwner = story.user.id == idUser;
    final userLiked = story.listReactions.any(
      (reaction) => reaction.id == idUser,
    );

    return Positioned(
      bottom: 12,
      right: 12,
      child: GestureDetector(
        onTap: () {
          context.read<StoryViewBloc>().updateStoryLike(
            idUser: idUser,
            story: story,
          );
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                userLiked ? Icons.favorite : Icons.favorite_border,
                color: userLiked ? Colors.red : Colors.white,
                size: 28,
              ),
              if (isOwner) ...[
                const SizedBox(width: 6),
                Text(
                  story.listReactions.length.toString(),
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
