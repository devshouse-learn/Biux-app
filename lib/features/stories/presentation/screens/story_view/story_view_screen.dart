import 'package:biux/core/config/colors.dart';
import 'package:biux/core/config/images.dart';
import 'package:biux/core/config/strings.dart';
import 'package:biux/core/config/styles.dart';
import 'package:biux/features/stories/data/models/story.dart';
import 'package:biux/features/authentication/data/repositories/authentication_repository.dart';
import 'package:biux/core/utils/share_utils.dart';
import 'package:biux/core/utils/strings_utils.dart';
import 'package:biux/features/stories/presentation/screens/story_view/story_view_bloc.dart';
import 'package:biux/shared/widgets/search_bar_widget.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:easy_image_viewer/easy_image_viewer.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:readmore/readmore.dart';

class StoryViewScreen extends StatelessWidget {
  const StoryViewScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bloc = context.watch<StoryViewBloc>();
    return Scaffold(
      backgroundColor: AppColors.white,
      body: ListView(
        children: [
          SearchBarWidget(),
          ...bloc.listStory
              .map((e) => _StoryWidget(
                    story: e,
                  ))
              .toList()
        ],
      ),
    );
  }
}

class _StoryWidget extends StatelessWidget {
  final Story story;
  const _StoryWidget({
    Key? key,
    required this.story,
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
            ),
          ),
        ),
        _PhotoUserStory(
          story: story,
        ),
      ],
    );
  }
}

class _PhotoUserStory extends StatelessWidget {
  final Story story;
  const _PhotoUserStory({
    Key? key,
    required this.story,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final sizeScreen = MediaQuery.of(context).size;
    return GestureDetector(
      child: Container(
        width: 80,
        height: 80,
        margin: EdgeInsets.only(
          left: sizeScreen.width * 0.1,
          top: 10,
        ),
        decoration: BoxDecoration(
          border: Border.all(
            color: AppColors.white,
            width: 4,
          ),
          image: DecorationImage(
            image: NetworkImage(story.user.photo),
            fit: BoxFit.cover,
          ),
          borderRadius: BorderRadius.circular(100.0),
        ),
      ),
    );
  }
}

class _ButtonLikesStory extends StatelessWidget {
  final Story story;
  final VoidCallback? onTap;
  _ButtonLikesStory({
    Key? key,
    required this.story,
    required this.onTap,
  }) : super(key: key);
  final idUser = AuthenticationRepository().getUserId;
  bool exists = false;
  @override
  Widget build(BuildContext context) {
    final sizeScreen = MediaQuery.of(context).size;
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
          margin: EdgeInsets.only(
            top: sizeScreen.height * 0.35,
          ),
          decoration: BoxDecoration(
            color: exists ? AppColors.darkNavy : AppColors.strongCyan,
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
                  Image.asset(
                    Images.kBikeLikesImage,
                    height: 25,
                    width: 25,
                  ),
                ],
              ),
              Text(
                AppStrings.likes,
                style: Styles.accentTextThemeWhite,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CarouselImages extends StatefulWidget {
  final Story story;
  _CarouselImages({Key? key, required this.story}) : super(key: key);

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
    final List<Widget> imageSliders = widget.story.files
        .map(
          (item) => Container(
            child: Stack(
              children: <Widget>[
                Image.network(
                  item,
                  width: sizeScreen.width * 0.8,
                  fit: BoxFit.cover,
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
                top: 8,
                bottom: 8,
                left: 50,
                right: 10,
              ),
              color: AppColors.strongCyan,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      '${widget.story.user.fullName}',
                      style: Styles.advertisingTitleBlack,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: Text(
                      widget.story.creationDate.timeHaveCreated,
                      style: Styles.accentTextThemeWhite,
                    ),
                  ),
                  GestureDetector(
                    onTap: () => ShareUtils().shareFile(
                      filePath: widget.story.fileUrl1,
                      text:
                          '${widget.story.user.userName}${AppStrings.textShareStory}',
                      title: AppStrings.titleShareStory,
                    ),
                    child: Image.asset(
                      Images.kImageShare,
                      height: 20,
                    ),
                  ),
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
                            child: Image.network(
                              e,
                              fit: BoxFit.cover,
                            ),
                          ),
                          onTap: () {
                            final imageProvider = Image.network(e).image;
                            showImageViewer(
                              context,
                              imageProvider,
                              backgroundColor: AppColors.black45,
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
                      color: AppColors.darkNavy.withOpacity(0.7),
                      child: Center(
                        child: Image.asset(
                          Images.kBikeLikesImage,
                          height: 25,
                        ),
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
                color: AppColors.white,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(35),
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.grey.withOpacity(0.5),
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
                    children: widget.story.files.asMap().entries.map(
                      (entry) {
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
                                color: AppColors.black,
                              ),
                              color: (current == entry.key
                                  ? AppColors.strongCyan
                                  : AppColors.darkBlue),
                            ),
                          ),
                        );
                      },
                    ).toList(),
                  ),
                  ReadMoreText(
                    widget.story.description +
                        '\n' +
                        widget.story.tags
                            .map((e) => '#$e')
                            .toString()
                            .replaceAll(
                              ')',
                              '',
                            )
                            .replaceAll(
                              '(',
                              '',
                            ),
                    textAlign: TextAlign.left,
                    preDataText: widget.story.user.userName,
                    preDataTextStyle: Styles.numberBlack,
                    trimLines: 2,
                    trimMode: TrimMode.Line,
                    trimCollapsedText: AppStrings.seeMore,
                    trimExpandedText: AppStrings.seeLess,
                    moreStyle: Styles.moreStyle,
                    lessStyle: Styles.moreStyle,
                    style: Styles.joinMeTextBlack,
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
            setState(
              () {
                _visible = true;
                Future.delayed(Duration(seconds: 1), () {
                  setState(() {
                    _visible = false;
                  });
                });
              },
            );
          },
        ),
      ],
    );
  }
}
