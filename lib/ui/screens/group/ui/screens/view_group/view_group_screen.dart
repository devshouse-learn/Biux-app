import 'package:biux/config/colors.dart';
import 'package:biux/config/images.dart';
import 'package:biux/config/strings.dart';
import 'package:biux/config/styles.dart';
import 'package:biux/data/models/road.dart';
import 'package:biux/data/models/story.dart';
import 'package:biux/ui/screens/group/ui/screens/view_group/view_group_bloc.dart';
import 'package:biux/ui/screens/group/ui/screens/view_group/view_members_group.dart';
import 'package:biux/ui/screens/zoom_screen/zoom_page.dart';
import 'package:biux/ui/widgets/button_facebook_widget.dart';
import 'package:biux/ui/widgets/button_instagram_widget.dart';
import 'package:biux/ui/widgets/button_whatsapp_widget.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:readmore/readmore.dart';
import '../../../../../../data/models/group.dart';

class ViewGroupScreen extends StatelessWidget {
  ViewGroupScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<ViewGroupBloc>();
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: AppColors.darkBlue,
        title: Selector<ViewGroupBloc, Group>(
            selector: (_, bloc) => bloc.group,
            builder: (context, value, child) {
              return _AppBar(group: bloc.group);
            }),
      ),
      body: Stack(
        alignment: Alignment.bottomRight,
        children: <Widget>[
          Selector<ViewGroupBloc, Group?>(
              selector: (_, bloc) => bloc.group,
              builder: (context, group, child) {
                return _HigherViewGroup(group: bloc.group);
              }),
          Selector<ViewGroupBloc, Group?>(
              selector: (_, bloc) => bloc.group,
              builder: (context, group, child) {
                return _SocialNetworks(
                  group: bloc.group,
                );
              }),
          Selector<ViewGroupBloc, Group?>(
              selector: (_, bloc) => bloc.group,
              builder: (context, group, child) {
                return _TabBarSeeGroup(
                  group: bloc.group,
                );
              }),
        ],
      ),
    );
  }
}

class _AppBar extends StatelessWidget {
  Group group;
  _AppBar({Key? key, required this.group}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Row(
            children: [
              Container(
                child: IconButton(
                  iconSize: 40,
                  icon: Icon(Icons.arrow_back_rounded),
                  color: AppColors.white,
                  onPressed: () {},
                ),
              ),
              Container(
                  alignment: Alignment.topCenter,
                  child: Text(
                    group.name,
                    style: Styles.containerNameUser,
                  )),
            ],
          ),
          GestureDetector(
            child: Container(
              height: 35,
              width: 35,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage(Images.kImageShare),
                ),
              ),
            ),
            onTap: () {},
          ),
        ]);
  }
}

class _HigherViewGroup extends StatelessWidget {
  Group group;
  _HigherViewGroup({Key? key, required this.group}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(children: <Widget>[
      Container(
        alignment: Alignment.topCenter,
        margin: EdgeInsets.only(top: 20),
        child: GestureDetector(
          onTap: () {
            showDialog(
                context: context,
                builder: (BuildContext context) {
                  return ZoomPage(group.logo, group.name);
                });
          },
          child: Container(
            height: 130,
            width: 130,
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.white, width: 4),
              image: DecorationImage(
                image: NetworkImage(group.logo),
                fit: BoxFit.cover,
              ),
              borderRadius: BorderRadius.circular(100.0),
            ),
          ),
        ),
      ),
      Container(
        alignment: Alignment.topCenter,
        margin: EdgeInsets.only(top: 115),
        child: GestureDetector(
          child: Container(
            height: 60,
            width: 60,
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage(Images.kImageChange),
              ),
            ),
          ),
          onTap: () {},
        ),
      ),
      Container(
        height: 40,
        margin: EdgeInsets.only(top: 160, left: 10),
        alignment: Alignment.topCenter,
        child: ButtonTheme(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(20)),
          ),
          minWidth: 140,
          height: 50,
          child: RaisedButton(
              color: AppColors.white,
              child:
                  Text(AppStrings.editGroup, style: Styles.containerTextGroup),
              onPressed: () {}),
        ),
      )
    ]);
  }
}

class _TabBarSeeGroup extends StatefulWidget {
  Group group;
  _TabBarSeeGroup({Key? key, required this.group}) : super(key: key);

  @override
  State<_TabBarSeeGroup> createState() => _TabBarSeeGroupState();
}

class _TabBarSeeGroupState extends State<_TabBarSeeGroup>
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
    final bloc = context.read<ViewGroupBloc>();
    return Column(
      children: <Widget>[
        Container(
          margin: EdgeInsets.only(top: 210, bottom: 10),
          alignment: Alignment.topCenter,
          padding: EdgeInsets.symmetric(horizontal: 35.0),
          child: ReadMoreText(
            bloc.group.description,
            textAlign: TextAlign.center,
            trimLines: 2,
            trimMode: TrimMode.Line,
            trimCollapsedText: AppStrings.seeMore,
            trimExpandedText: AppStrings.seeLess,
            moreStyle: Styles.moreStyle,
            lessStyle: Styles.moreStyle,
            style: Styles.containerFollowing,
          ),
        ),
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
              ),
            )),
        Expanded(
          child: TabBarView(
            physics: NeverScrollableScrollPhysics(),
            controller: tabController,
            children: <Widget>[
              Selector<ViewGroupBloc, List<Story>>(
                  selector: (_, bloc) => bloc.stories,
                  builder: (context, value, child) {
                    return _ViewUserImage(stories: bloc.stories);
                  }),
              _ViewUserImage(stories: bloc.stories),
              ViewMembersGroup(),
            ],
          ),
        ),
      ],
    );
  }
}

class _SocialNetworks extends StatelessWidget {
  Group group;
  _SocialNetworks({
    Key? key,
    required this.group,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Container(
      margin: EdgeInsets.only(left: size.width * 0.80, top: 5),
      child: Column(
        children: <Widget>[
          if (group.instagram.isNotEmpty)
            ButtonInstagramWidget(
              linkinstagram: group.instagram,
            ),
          Container(
            height: 5,
          ),
          if (group.whatsapp.isNotEmpty)
            ButtonWhatsappWidget(
              whatsapp: group.whatsapp,
              name: group.name,
            ),
          Container(
            height: 5,
          ),
          if (group.facebook.isNotEmpty)
            ButtonFacebookWidget(
              linkFacebook: group.facebook,
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
  }) : super(key: key);
  final int index;
  final int selectedIndex;
  final BorderRadius borderRadius;

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<ViewGroupBloc>();
    Size size = MediaQuery.of(context).size;
    return Tab(
      height: 70,
      child: Container(
          alignment: Alignment.center,
          width: size.width,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (index == 0)
                Container(
                  height: 30,
                  width: 30,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage(Images.kImageGallery),
                    ),
                  ),
                )
              else if (index == 1)
                Icon(
                  Icons.directions_bike,
                  color: AppColors.black,
                )
              else if (index == 2)
                Container(
                  height: 30,
                  width: 30,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage(Images.kImageSocial),
                    ),
                  ),
                ),
              SizedBox(width: 10),
              if (index == 0)
                Selector<ViewGroupBloc, List<Story>>(
                    selector: (_, bloc) => bloc.stories,
                    builder: (context, value, child) {
                      return Text(bloc.stories.length.toString(),
                          style: Styles.rowItemColorligth);
                    })
              else if (index == 1)
                Selector<ViewGroupBloc, List<Road>>(
                    selector: (_, bloc) => bloc.roads,
                    builder: (context, value, child) {
                      return Text(bloc.roads.length.toString(),
                          style: Styles.rowItemColorligth);
                    })
              else if (index == 2)
                Selector<ViewGroupBloc, List<Story>>(
                    selector: (_, bloc) => bloc.stories,
                    builder: (context, value, child) {
                      return Text(bloc.member.length.toString(),
                          style: Styles.rowItemColorligth);
                    }),
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
                              border:
                                  Border.all(color: AppColors.gray, width: 1)),
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
                              image: AssetImage(Images.kImageSnakeCase),
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
