import 'package:biux/core/design_system/color_tokens.dart';
import 'package:biux/core/design_system/locale_notifier.dart';
import 'package:biux/core/config/images.dart';
import 'package:biux/core/config/strings.dart';
import 'package:biux/core/config/styles.dart';
import 'package:biux/features/stories/data/models/story.dart';
import 'package:biux/features/authentication/data/repositories/authentication_repository.dart';
import 'package:biux/core/utils/share_utils.dart';
import 'package:biux/core/utils/strings_utils.dart';
import 'package:biux/features/stories/presentation/screens/story_view/story_view_bloc.dart';
import 'package:biux/features/stories/presentation/screens/story_view/story_comments_bottom_sheet.dart';
import 'package:biux/shared/services/optimized_cache_manager.dart';
import 'package:biux/shared/widgets/optimized_image_picker.dart';
import 'package:carousel_slider/carousel_slider.dart';
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
    final sizeScreen = MediaQuery.of(context).size;
    return Stack(
      children: [
        Align(
          alignment: Alignment.centerRight,
          child: Container(
            margin: const EdgeInsets.only(top: 30),
            width: sizeScreen.width * 0.8,
            child: _CarouselImages(
              story: story,
              isAdvertisement: isAdvertisement,
            ),
          ),
        ),
        _PhotoUserStory(story: story, isAdvertisement: isAdvertisement),
        if (isAdvertisement)
          Positioned(top: 50, right: 20, child: _AdvertisementBadge()),
      ],
    );
  }
}

class _PhotoUserStory extends StatelessWidget {
  final Story story;
  final bool isAdvertisement;
  const _PhotoUserStory({
    Key? key,
    required this.story,
    this.isAdvertisement = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final sizeScreen = MediaQuery.of(context).size;
    return Stack(
      children: [
        GestureDetector(
          child: Container(
            width: 80,
            height: 80,
            margin: EdgeInsets.only(left: sizeScreen.width * 0.1, top: 10),
            decoration: BoxDecoration(
              border: Border.all(
                color: isAdvertisement
                    ? Color(0xFFFFD700)
                    : Theme.of(context).scaffoldBackgroundColor,
                width: isAdvertisement ? 5 : 4,
              ),
              image: DecorationImage(
                image: CachedNetworkImageProvider(
                  story.user.photo,
                  cacheManager: OptimizedCacheManager.avatarInstance,
                ),
                fit: BoxFit.cover,
              ),
              borderRadius: BorderRadius.circular(100.0),
            ),
          ),
        ),
        if (isAdvertisement)
          Positioned(
            bottom: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Color(0xFFFFD700),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
              ),
              child: Icon(Icons.flash_on, size: 16, color: Color(0xFF1A1A1A)),
            ),
          ),
      ],
    );
  }
}

class _ButtonLikesStory extends StatelessWidget {
  final Story story;
  final VoidCallback? onTap;
  _ButtonLikesStory({Key? key, required this.story, required this.onTap})
    : super(key: key);
  final idUser = AuthenticationRepository().getUserId;

  @override
  Widget build(BuildContext context) {
    final sizeScreen = MediaQuery.of(context).size;
    bool exists = false;
    for (var element in story.listReactions) {
      if (element.id == idUser) {
        exists = true;
      }
    }
    return Align(
      alignment: Alignment.bottomRight,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(10),
          width: sizeScreen.width * 0.25,
          margin: EdgeInsets.only(top: sizeScreen.height * 0.35),
          decoration: BoxDecoration(
            color: exists ? ColorTokens.primary30 : ColorTokens.secondary50,
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(30),
              topLeft: Radius.circular(30),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Text(
                    story.listReactions.length.toString(),
                    style: Styles.accentTextThemeWhite,
                  ),
                  Image.asset(Images.kBikeLikesImage, height: 25, width: 25),
                ],
              ),
              Text(AppStrings.likes, style: Styles.accentTextThemeWhite),
            ],
          ),
        ),
      ),
    );
  }
}

class _CarouselImages extends StatefulWidget {
  final Story story;
  final bool isAdvertisement;
  _CarouselImages({Key? key, required this.story, this.isAdvertisement = false})
    : super(key: key);

  @override
  State<_CarouselImages> createState() => _CarouselImagesState();
}

class _CarouselImagesState extends State<_CarouselImages> {
  final CarouselSliderController _controller = CarouselSliderController();
  int current = 0;
  bool _visible = false;
  Story storyUpdate = Story();
  @override
  void initState() {
    super.initState();
    storyUpdate = widget.story;
  }

  @override
  Widget build(BuildContext context) {
    final sizeScreen = MediaQuery.of(context).size;
    final bloc = context.watch<StoryViewBloc>();
    widget.story.files
        .map(
          (item) => Container(
            child: Stack(
              children: <Widget>[
                OptimizedNetworkImage(
                  imageUrl: item,
                  imageType: 'general',
                  width: sizeScreen.width * 0.8,
                  fit: BoxFit
                      .contain, // Cambiado de cover a contain para mostrar fotos verticales completas
                ),
              ],
            ),
          ),
        )
        .toList();
    return Stack(
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.only(
                top: 6,
                bottom: 6,
                left: 50,
                right: 10,
              ),
              color: Theme.of(context).brightness == Brightness.dark
                  ? Theme.of(context).colorScheme.surface
                  : ColorTokens.secondary50,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      '${widget.story.user.fullName}',
                      style: Styles.advertisingTitleBlack.copyWith(
                        color: Theme.of(context).brightness == Brightness.dark
                            ? Colors.white
                            : Colors.black87,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: Text(
                      widget.story.creationDate.timeHaveCreated,
                      style: Styles.accentTextThemeWhite.copyWith(
                        color: Theme.of(context).brightness == Brightness.dark
                            ? Colors.grey[400]
                            : Colors.grey[700],
                      ),
                    ),
                  ),
                  // Botón de eliminar solo si es el dueño
                  if (widget.story.user.id ==
                      AuthenticationRepository().getUserId)
                    GestureDetector(
                      onTap: () => _showDeleteConfirmationDialog(context),
                      child: Icon(
                        Icons.delete_outline,
                        color: Colors.red,
                        size: 20,
                      ),
                    ),
                  SizedBox(width: 8),
                  GestureDetector(
                    onTap: () => ShareUtils().shareFile(
                      filePath: widget.story.fileUrl1,
                      text:
                          '${widget.story.user.userName}${AppStrings.textShareStory}',
                      title: AppStrings.titleShareStory,
                    ),
                    child: Image.asset(Images.kImageShare, height: 20),
                  ),
                  if (widget.isAdvertisement) ...[
                    SizedBox(width: 12),
                    GestureDetector(
                      onTap: () => _showAdvertisementInfoDialog(context),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Color(0xFFFFD700), Color(0xFFFFA500)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Color(0xFFFFD700).withValues(alpha: 0.4),
                              blurRadius: 8,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.flash_on, color: Colors.white, size: 14),
                            SizedBox(width: 4),
                            Text(
                              Provider.of<LocaleNotifier>(
                                context,
                              ).t('advertising_label'),
                              style: Styles.accentTextThemeWhite.copyWith(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            Stack(
              alignment: Alignment.topRight,
              children: [
                CarouselSlider(
                  items: widget.story.files
                      .map(
                        (e) => GestureDetector(
                          child: Container(
                            width: 315,
                            child: OptimizedNetworkImage(
                              imageUrl: e,
                              imageType: 'general',
                              fit: BoxFit
                                  .contain, // Cambiado de cover a contain para mostrar fotos verticales completas
                            ),
                          ),
                          onTap: () {
                            final imageProvider = CachedNetworkImageProvider(
                              e,
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
                        ),
                      )
                      .toList(),
                  carouselController: _controller,
                  options: CarouselOptions(
                    enableInfiniteScroll: false,
                    viewportFraction: 1.0,
                    initialPage: 0,
                    enlargeCenterPage: false,
                    height: sizeScreen.height * 0.35,
                    onPageChanged: (index, reason) {
                      setState(() {
                        current = index;
                      });
                    },
                  ),
                ),
                if (_visible)
                  AnimatedOpacity(
                    opacity: _visible ? 1.0 : 0.0,
                    duration: const Duration(milliseconds: 500),
                    child: Container(
                      height: sizeScreen.height * 0.35,
                      width: sizeScreen.width * 0.8,
                      color: ColorTokens.primary30.withValues(alpha: 0.7),
                      child: Center(
                        child: Image.asset(Images.kBikeLikesImage, height: 25),
                      ),
                    ),
                  ),
              ],
            ),
            Container(
              padding: const EdgeInsets.only(
                top: 10,
                left: 15,
                bottom: 20,
                right: 10,
              ),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(35),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Theme.of(context).shadowColor.withValues(alpha: 0.3),
                    spreadRadius: 5,
                    blurRadius: 7,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: widget.story.files.asMap().entries.map((entry) {
                      return GestureDetector(
                        onTap: () => _controller.animateToPage(entry.key),
                        child: Container(
                          width: 10.0,
                          height: 10.0,
                          margin: EdgeInsets.symmetric(
                            vertical: 5.0,
                            horizontal: 4.0,
                          ),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Theme.of(context).dividerColor,
                            ),
                            color: (current == entry.key
                                ? ColorTokens.secondary50
                                : ColorTokens.primary30),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  ReadMoreText(
                    widget.story.description +
                        '\n' +
                        widget.story.tags
                            .map((e) => '#$e')
                            .toString()
                            .replaceAll(')', '')
                            .replaceAll('(', ''),
                    textAlign: TextAlign.left,
                    preDataText: widget.story.user.userName,
                    preDataTextStyle: Styles.numberBlack.copyWith(
                      color: Theme.of(context).textTheme.bodyLarge?.color,
                      fontWeight: FontWeight.bold,
                      shadows: [
                        Shadow(
                          offset: Offset(0, 1),
                          blurRadius: 3.0,
                          color: Colors.black.withValues(alpha: 0.7),
                        ),
                      ],
                    ),
                    style: TextStyle(
                      color: Theme.of(context).textTheme.bodyMedium?.color,
                    ),
                    trimLines: 2,
                    trimMode: TrimMode.Line,
                    trimCollapsedText: AppStrings.seeMore,
                    trimExpandedText: AppStrings.seeLess,
                    moreStyle: Styles.moreStyle.copyWith(
                      color: Theme.of(context).primaryColor,
                    ),
                    lessStyle: Styles.moreStyle.copyWith(
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        _ButtonLikesStory(
          story: widget.story,
          onTap: () {
            bloc.updateStoryLike(
              idUser: AuthenticationRepository().getUserId,
              story: widget.story,
            );
            setState(() {
              _visible = true;
              Future.delayed(Duration(seconds: 1), () {
                setState(() {
                  _visible = false;
                });
              });
            });
          },
        ),
        // Contenedor con descripción, likes y comentarios estilo Instagram
        _StoryActionsBar(story: widget.story),
      ],
    );
  }

  void _showDeleteConfirmationDialog(BuildContext context) {
    final l = Provider.of<LocaleNotifier>(context, listen: false);
    final bloc = context.read<StoryViewBloc>();
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(l.t('delete_story')),
          content: Text(l.t('delete_story_confirm')),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(l.t('cancel')),
            ),
            TextButton(
              onPressed: () {
                bloc.deleteStory(story: widget.story);
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

  void _showAdvertisementInfoDialog(BuildContext context) {
    final l = Provider.of<LocaleNotifier>(context, listen: false);
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: ColorTokens.neutral100,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Container(
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFFFFD700), Color(0xFFFFA500)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(Icons.flash_on, color: Colors.white, size: 28),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l.t('promoted_story').toUpperCase(),
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1,
                        ),
                      ),
                      Text(
                        l.t('boosted_content'),
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.8),
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 8),
                // Información del usuario
                Row(
                  children: [
                    CircleAvatar(
                      radius: 28,
                      backgroundImage: CachedNetworkImageProvider(
                        widget.story.user.photo,
                      ),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.story.user.fullName,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: ColorTokens.neutral90,
                            ),
                          ),
                          Text(
                            '@${widget.story.user.userName}',
                            style: TextStyle(
                              fontSize: 12,
                              color: ColorTokens.neutral60,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 16),
                Divider(height: 1),
                SizedBox(height: 16),

                // Descripción
                Text(
                  l.t('about_this_ad'),
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: ColorTokens.neutral80,
                    letterSpacing: 0.5,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  widget.story.description.isNotEmpty
                      ? widget.story.description
                      : l.t('ad_default_desc'),
                  style: TextStyle(
                    fontSize: 13,
                    color: ColorTokens.neutral80,
                    height: 1.5,
                  ),
                ),

                SizedBox(height: 16),
                Divider(height: 1),
                SizedBox(height: 16),

                // Beneficios
                Text(
                  '✨ ${l.t('ad_benefits_title')}',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFFFD700),
                  ),
                ),
                SizedBox(height: 12),
                ...[
                  '🎯 ${l.t('ad_benefit_reach')}',
                  '⭐ ${l.t('ad_benefit_featured')}',
                  '📊 ${l.t('ad_benefit_engagement')}',
                  '💎 ${l.t('ad_benefit_badge')}',
                ].map((benefit) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      children: [
                        SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            benefit,
                            style: TextStyle(
                              fontSize: 12,
                              color: ColorTokens.neutral80,
                              height: 1.3,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              style: TextButton.styleFrom(foregroundColor: Color(0xFFFFD700)),
              child: Text(
                l.t('understood'),
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _AdvertisementBadge extends StatefulWidget {
  const _AdvertisementBadge({Key? key}) : super(key: key);

  @override
  State<_AdvertisementBadge> createState() => _AdvertisementBadgeState();
}

class _AdvertisementBadgeState extends State<_AdvertisementBadge>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.1,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    _opacityAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scaleAnimation,
      child: FadeTransition(
        opacity: _opacityAnimation,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFFFFD700), Color(0xFFFFA500)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Color(0xFFFFD700).withValues(alpha: 0.6),
                blurRadius: 12,
                spreadRadius: 3,
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.flash_on, color: Colors.white, size: 16),
              SizedBox(width: 6),
              Text(
                Provider.of<LocaleNotifier>(context).t('advertising_label'),
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Barra de acciones estilo Instagram (likes, comentarios y opciones)
class _StoryActionsBar extends StatelessWidget {
  final Story story;

  const _StoryActionsBar({Key? key, required this.story}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final l = Provider.of<LocaleNotifier>(context);
    final idUser = AuthenticationRepository().getUserId;
    bool userLiked = story.listReactions.any(
      (reaction) => reaction.id == idUser,
    );

    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          border: Border(
            top: BorderSide(color: Theme.of(context).dividerColor, width: 0.5),
          ),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Fila de botones de interacción (Like, Comment, Share)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    // Botón Like
                    GestureDetector(
                      onTap: () {
                        context.read<StoryViewBloc>().updateStoryLike(
                          idUser: idUser,
                          story: story,
                        );
                      },
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            userLiked ? Icons.favorite : Icons.favorite_border,
                            color: userLiked ? Colors.red : Colors.grey,
                            size: 28,
                          ),
                          SizedBox(height: 4),
                          Text(
                            story.listReactions.length.toString(),
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Theme.of(
                                context,
                              ).textTheme.bodyMedium?.color,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Botón Comentarios
                    GestureDetector(
                      onTap: () {
                        showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(20),
                              topRight: Radius.circular(20),
                            ),
                          ),
                          builder: (context) =>
                              StoryCommentsBottomSheet(story: story),
                        );
                      },
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.comment_outlined,
                            color: Colors.grey,
                            size: 28,
                          ),
                          SizedBox(height: 4),
                          Text(
                            story.listComments.length.toString(),
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Theme.of(
                                context,
                              ).textTheme.bodyMedium?.color,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Botón Compartir
                    GestureDetector(
                      onTap: () {
                        ShareUtils().shareFile(
                          filePath: story.fileUrl1,
                          text:
                              '${story.user.userName}${AppStrings.textShareStory}',
                          title: AppStrings.titleShareStory,
                        );
                      },
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.share_outlined,
                            color: Colors.grey,
                            size: 28,
                          ),
                          SizedBox(height: 4),
                          Text(
                            l.t('share'),
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Theme.of(
                                context,
                              ).textTheme.bodyMedium?.color,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              // Separador
              Divider(height: 1, thickness: 0.5),
              SizedBox(height: 12),
              // Descripción principal
              if (story.description.isNotEmpty)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          story.user.userName,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).textTheme.bodyLarge?.color,
                          ),
                        ),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            story.description,
                            style: TextStyle(
                              fontSize: 13,
                              color: Theme.of(
                                context,
                              ).textTheme.bodyMedium?.color,
                            ),
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 8),
                    Text(
                      story.creationDate.timeHaveCreated,
                      style: TextStyle(fontSize: 11, color: Colors.grey),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}
