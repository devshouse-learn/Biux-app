import 'package:biux/config/colors.dart';
import 'package:biux/config/images.dart';
import 'package:biux/config/strings.dart';
import 'package:biux/config/styles.dart';
import 'package:biux/data/models/competitor_road.dart';
import 'package:biux/data/models/story.dart';
import 'package:biux/data/models/user.dart';
import 'package:biux/ui/screens/user/ui/user_screen/user_screen_bloc.dart';
import 'package:biux/ui/screens/zoom_screen/zoom_page.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class UserScreen extends StatelessWidget {
  const UserScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bloc = context.watch<UserScreenBloc>();
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: AppColors.darkBlue,
        title: Selector<UserScreenBloc, BiuxUser>(
            selector: (_, bloc) => bloc.user,
            builder: (context, value, child) {
              return _AppBar(user: bloc.user);
            }),
      ),
      body: Stack(
        children: <Widget>[
          Selector<UserScreenBloc, BiuxUser>(
              selector: (_, bloc) => bloc.user,
              builder: (context, value, child) {
                return _SuperiorUserScreen(
                  user: bloc.user,
                );
              }),
          Selector<UserScreenBloc, BiuxUser>(
              selector: (_, bloc) => bloc.user,
              builder: (context, value, child) {
                return _TabBarViewUser(
                  user: bloc.user,
                );
              }),
          Selector<UserScreenBloc, BiuxUser>(
              selector: (_, bloc) => bloc.user,
              builder: (context, value, child) {
                return _button(
                  user: bloc.user,
                  context: context,
                );
              }),
          Selector<UserScreenBloc, BiuxUser>(
              selector: (_, bloc) => bloc.user,
              builder: (context, value, child) {
                return _TextDescripcion(
                  user: bloc.user,
                );
              }),
        ],
      ),
    );
  }
}

class _AppBar extends StatelessWidget {
  BiuxUser user;
  _AppBar({Key? key, required this.user}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Container(
              alignment: Alignment.topCenter,
              child: Text(
                user.fullName,
                style: Styles.containerNameUser,
              )),
          GestureDetector(
            child: Container(
              height: 35,
              width: 35,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: new AssetImage(Images.kImageShare),
                ),
              ),
            ),
            onTap: () {},
          ),
        ]);
  }
}

class _SuperiorUserScreen extends StatelessWidget {
  BiuxUser user;
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
              showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return ZoomPage(user.photo, user.fullName);
                  });
            },
            child: Container(
              height: 130,
              width: 130,
              decoration: new BoxDecoration(
                border: Border.all(color: AppColors.white, width: 4),
                image: DecorationImage(
                  image: new NetworkImage(user.photo),
                  fit: BoxFit.cover,
                ),
                borderRadius: BorderRadius.circular(100.0),
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
  BiuxUser user;
  _TextDescripcion({Key? key, required this.user}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(15.0),
      margin: EdgeInsets.only(top: 150),
      child: Text(
        user.description,
        style: Styles.containerFollowing,
      ),
    );
  }
}

class _button extends StatelessWidget {
  BiuxUser user;
  BuildContext context;
  _button({Key? key, required this.user, required this.context})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bloc = context.watch<UserScreenBloc>();
    Size size = MediaQuery.of(context).size;
    return Stack(
      children: <Widget>[
        Container(
          margin: EdgeInsets.only(left: size.width * 0.55),
          height: 40,
          color: AppColors.white2,
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
                      SizedBox(
                        width: 5,
                      ),
                      Text(
                        AppStrings.following,
                        style: Styles.containerFollowing,
                      ),
                    ],
                  )),
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
            child: RaisedButton(
                color: AppColors.white,
                child: Text(AppStrings.editProfile,
                    style: Styles.containerFollowing),
                onPressed: () {
                  bloc.onTapEdit(context);
                }),
          ),
        )
      ],
    );
  }
}

class _TabBarViewUser extends StatefulWidget {
  BiuxUser user;
  _TabBarViewUser({
    Key? key,
    required this.user,
  }) : super(key: key);

  @override
  State<_TabBarViewUser> createState() => _TabBarViewUserState();
}

class _TabBarViewUserState extends State<_TabBarViewUser>
    with TickerProviderStateMixin {
  late TabController tabController;
  int _selectedIndex = 0;

  void initState() {
    super.initState();
    tabController = TabController(
      length: 3,
      vsync: this,
    );
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
              unselectedLabelColor: AppColors.black,
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
              )),
          Expanded(
            child: TabBarView(
              physics: NeverScrollableScrollPhysics(),
              controller: tabController,
              children: <Widget>[
                Selector<UserScreenBloc, List<Story>>(
                    selector: (_, bloc) => bloc.stories,
                    builder: (context, value, child) {
                      return _ViewUserImage(stories: bloc.stories);
                    }),
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
                      ? Icon(
                          Icons.directions_bike,
                          color: AppColors.black,
                        )
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
                        return Text(bloc.stories.length.toString(),
                            style: Styles.rowItemColorligth);
                      })
                  : index == 1
                      ? Selector<UserScreenBloc, List<CompetitorRoad>>(
                          selector: (_, bloc) => bloc.competitorRoad,
                          builder: (context, value, child) {
                            return Text(bloc.competitorRoad.length.toString(),
                                style: Styles.rowItemColorligth);
                          })
                      : index == 2
                          ? Selector<UserScreenBloc, List<Story>>(
                              selector: (_, bloc) => bloc.stories,
                              builder: (context, value, child) {
                                return Text(bloc.user.followerS.toString(),
                                    style: Styles.rowItemColorligth);
                              })
                          : SizedBox(),
            ],
          ),
          decoration: BoxDecoration(
              border: Border.all(color: AppColors.gray, width: 0.1),
              borderRadius: borderRadius,
              color:
                  index == selectedIndex ? AppColors.white2 : AppColors.white)),
    );
  }
}

class _ViewUserImage extends StatelessWidget {
  List<Story> stories;
  _ViewUserImage({Key? key, required this.stories}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: SingleChildScrollView(
        child: Wrap(
          children: stories
              .map((story) => Stack(
                    children: <Widget>[
                      Container(
                          height: 125,
                          width: 130.8,
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: AppColors.gray,
                              width: 1,
                            ),
                          ),
                          child: Image.network(
                            story.fileUrl1,
                            fit: BoxFit.fill,
                          )),
                      if (story.fileUrl2.isNotEmpty ||
                          story.fileUrl3.isNotEmpty)
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
                  ))
              .toList(),
        ),
      ),
    );
  }
}
