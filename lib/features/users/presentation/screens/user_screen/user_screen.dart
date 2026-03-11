import 'package:biux/core/design_system/color_tokens.dart';
import 'package:biux/core/config/images.dart';
import 'package:biux/core/config/styles.dart';
import 'package:biux/core/design_system/locale_notifier.dart';
import 'package:biux/features/roads/data/models/competitor_road.dart';
import 'package:biux/features/stories/data/models/story.dart';
import 'package:biux/features/users/data/models/user.dart';
import 'package:biux/features/users/presentation/screens/user_screen/user_screen_bloc.dart';
import 'package:biux/shared/widgets/optimized_image_picker.dart';
import 'package:biux/shared/services/optimized_cache_manager.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_image_viewer/easy_image_viewer.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class UserScreen extends StatelessWidget {
  const UserScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bloc = context.watch<UserScreenBloc>();
    return Scaffold(
      backgroundColor: ColorTokens.neutral100,
      appBar: AppBar(
        backgroundColor: ColorTokens.primary30,
        title: Selector<UserScreenBloc, BiuxUser>(
          selector: (_, bloc) => bloc.user,
          builder: (context, value, child) {
            return _AppBar(user: bloc.user);
          },
        ),
      ),
      body: Stack(
        children: <Widget>[
          Selector<UserScreenBloc, BiuxUser>(
            selector: (_, bloc) => bloc.user,
            builder: (context, value, child) {
              return _SuperiorUserScreen(user: bloc.user);
            },
          ),
          Selector<UserScreenBloc, BiuxUser>(
            selector: (_, bloc) => bloc.user,
            builder: (context, value, child) {
              return _TabBarViewUser(user: bloc.user);
            },
          ),
          Selector<UserScreenBloc, BiuxUser>(
            selector: (_, bloc) => bloc.user,
            builder: (context, value, child) {
              return _button(user: bloc.user, context: context);
            },
          ),
          Selector<UserScreenBloc, BiuxUser>(
            selector: (_, bloc) => bloc.user,
            builder: (context, value, child) {
              return _TextDescripcion(user: bloc.user);
            },
          ),
        ],
      ),
    );
  }
}

class _AppBar extends StatelessWidget {
  final BiuxUser user;
  _AppBar({Key? key, required this.user}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Container(
          alignment: Alignment.topCenter,
          child: Text(user.fullName, style: Styles.containerNameUser),
        ),
        GestureDetector(
          child: Container(
            height: 35,
            width: 35,
            decoration: BoxDecoration(
              image: DecorationImage(image: new AssetImage(Images.kImageShare)),
            ),
          ),
          onTap: () {},
        ),
      ],
    );
  }
}

class _SuperiorUserScreen extends StatelessWidget {
  final BiuxUser user;
  _SuperiorUserScreen({Key? key, required this.user}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        Container(
          alignment: Alignment.topLeft,
          margin: new EdgeInsets.only(top: 15, left: 10),
          child: GestureDetector(
            onTap: () {
              final imageProvider = CachedNetworkImageProvider(
                user.photo,
                cacheManager: OptimizedCacheManager.avatarInstance,
              );
              showImageViewer(
                context,
                imageProvider,
                backgroundColor: ColorTokens.neutral40,
                useSafeArea: true,
                immersive: false,
              );
            },
            child: Container(
              height: 130,
              width: 130,
              decoration: new BoxDecoration(
                border: Border.all(color: ColorTokens.neutral100, width: 4),
                borderRadius: BorderRadius.circular(100.0),
              ),
              child: ClipOval(
                child: OptimizedNetworkImage(
                  imageUrl: user.photo,
                  width: 130,
                  height: 130,
                  imageType: 'avatar',
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
        ),
        GestureDetector(
          child: Container(
            margin: new EdgeInsets.only(top: 115, left: 45),
            height: 60,
            width: 60,
            decoration: BoxDecoration(
              image: DecorationImage(
                image: new AssetImage(Images.kImageChange),
              ),
            ),
          ),
          onTap: () {},
        ),
      ],
    );
  }
}

class _TextDescripcion extends StatelessWidget {
  final BiuxUser user;
  _TextDescripcion({Key? key, required this.user}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(15.0),
      margin: EdgeInsets.only(top: 150),
      child: Text(user.description, style: Styles.containerFollowing),
    );
  }
}

class _button extends StatelessWidget {
  final BiuxUser user;
  final BuildContext context;
  _button({Key? key, required this.user, required this.context})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bloc = context.watch<UserScreenBloc>();
    final l = Provider.of<LocaleNotifier>(context);
    Size size = MediaQuery.of(context).size;
    return Stack(
      children: <Widget>[
        Container(
          margin: EdgeInsets.only(left: size.width * 0.55),
          height: 40,
          color: ColorTokens.neutral100,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Container(
                height: 20,
                width: 20,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: new AssetImage(Images.kImageHelmetRight),
                  ),
                ),
              ),
              Container(
                margin: EdgeInsets.only(right: 10, left: 5),
                child: Row(
                  children: [
                    Text(
                      user.following.length.toString(),
                      style: Styles.containerBlack,
                    ),
                    SizedBox(width: 5),
                    Text(l.t('following'), style: Styles.containerFollowing),
                  ],
                ),
              ),
            ],
          ),
        ),
        Container(
          margin: EdgeInsets.only(top: 60, right: 10),
          alignment: Alignment.topRight,
          child: ButtonTheme(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(20)),
            ),
            minWidth: 160,
            height: 50,
            child: ElevatedButton(
              //color: ColorTokens.neutral100,
              child: Text(
                l.t('edit_profile'),
                style: Styles.containerFollowing,
              ),
              onPressed: () {
                bloc.onTapEdit(context);
              },
            ),
          ),
        ),
      ],
    );
  }
}

class _TabBarViewUser extends StatefulWidget {
  final BiuxUser user;
  _TabBarViewUser({Key? key, required this.user}) : super(key: key);

  @override
  State<_TabBarViewUser> createState() => _TabBarViewUserState();
}

class _TabBarViewUserState extends State<_TabBarViewUser>
    with TickerProviderStateMixin {
  late TabController tabController;
  int _selectedIndex = 0;

  void initState() {
    super.initState();
    tabController = TabController(length: 3, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    final bloc = context.watch<UserScreenBloc>();
    Size size = MediaQuery.of(context).size;
    return Container(
      margin: EdgeInsets.only(top: size.height * 0.30),
      child: Column(
        children: <Widget>[
          TabBar(
            onTap: (index) => setState(() => _selectedIndex = index),
            labelPadding: EdgeInsets.zero,
            controller: tabController,
            indicatorWeight: 0.01,
            splashBorderRadius: BorderRadius.circular(20),
            unselectedLabelColor: ColorTokens.neutral0,
            tabs: List<Widget>.generate(
              tabController.length,
              (index) => _TabDecoration(
                borderRadius: index == 0
                    ? BorderRadius.only(topLeft: Radius.circular(10))
                    : index == 2
                    ? BorderRadius.only(topRight: Radius.circular(10))
                    : BorderRadius.only(),
                index: index,
                selectedIndex: _selectedIndex,
                numberRoads: widget.user.followerS.toString(),
              ),
            ),
          ),
          Expanded(
            child: TabBarView(
              physics: NeverScrollableScrollPhysics(),
              controller: tabController,
              children: <Widget>[
                Selector<UserScreenBloc, List<Story>>(
                  selector: (_, bloc) => bloc.stories,
                  builder: (context, value, child) {
                    return _ViewUserImage(stories: bloc.stories);
                  },
                ),
                _ViewUserImage(stories: bloc.stories),
                _ViewUserImage(stories: bloc.stories),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TabDecoration extends StatelessWidget {
  const _TabDecoration({
    Key? key,
    required this.borderRadius,
    required this.index,
    required this.selectedIndex,
    required this.numberRoads,
  }) : super(key: key);
  final int index;
  final int selectedIndex;
  final String numberRoads;
  final BorderRadius borderRadius;

  @override
  Widget build(BuildContext context) {
    final bloc = context.watch<UserScreenBloc>();
    Size size = MediaQuery.of(context).size;
    return Tab(
      height: 70,
      child: Container(
        alignment: Alignment.center,
        width: size.width,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            index == 0
                ? Container(
                    height: 25,
                    width: 25,
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: new AssetImage(Images.kImageGallery),
                      ),
                    ),
                  )
                : index == 1
                ? Icon(Icons.directions_bike, color: ColorTokens.neutral0)
                : index == 2
                ? Container(
                    height: 25,
                    width: 25,
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: new AssetImage(Images.kImageSocial),
                      ),
                    ),
                  )
                : SizedBox(),
            SizedBox(width: 10),
            index == 0
                ? Selector<UserScreenBloc, List<Story>>(
                    selector: (_, bloc) => bloc.stories,
                    builder: (context, value, child) {
                      return Text(
                        bloc.stories.length.toString(),
                        style: Styles.rowItemColorligth,
                      );
                    },
                  )
                : index == 1
                ? Selector<UserScreenBloc, List<CompetitorRoad>>(
                    selector: (_, bloc) => bloc.competitorRoad,
                    builder: (context, value, child) {
                      return Text(
                        bloc.competitorRoad.length.toString(),
                        style: Styles.rowItemColorligth,
                      );
                    },
                  )
                : index == 2
                ? Selector<UserScreenBloc, List<Story>>(
                    selector: (_, bloc) => bloc.stories,
                    builder: (context, value, child) {
                      return Text(
                        bloc.user.followerS.toString(),
                        style: Styles.rowItemColorligth,
                      );
                    },
                  )
                : SizedBox(),
          ],
        ),
        decoration: BoxDecoration(
          border: Border.all(color: ColorTokens.neutral60, width: 0.1),
          borderRadius: borderRadius,
          color: index == selectedIndex
              ? ColorTokens.neutral100
              : ColorTokens.neutral100,
        ),
      ),
    );
  }
}

class _ViewUserImage extends StatelessWidget {
  final List<Story> stories;
  _ViewUserImage({Key? key, required this.stories}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorTokens.neutral100,
      body: SingleChildScrollView(
        child: Wrap(
          children: stories
              .map(
                (story) => Stack(
                  children: <Widget>[
                    Container(
                      height: 125,
                      width: 130.8,
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: ColorTokens.neutral60,
                          width: 1,
                        ),
                      ),
                      child: OptimizedNetworkImage(
                        imageUrl: story.files.first,
                        width: 130.8,
                        height: 130.8,
                        imageType: 'thumbnail',
                        fit: BoxFit.fill,
                      ),
                    ),
                    if (story.files.length > 1)
                      Container(
                        height: 20,
                        width: 20,
                        margin: EdgeInsets.only(left: 105, top: 5),
                        decoration: BoxDecoration(
                          image: DecorationImage(
                            image: new AssetImage(Images.kImageSnakeCase),
                          ),
                        ),
                      ),
                  ],
                ),
              )
              .toList(),
        ),
      ),
    );
  }
}
