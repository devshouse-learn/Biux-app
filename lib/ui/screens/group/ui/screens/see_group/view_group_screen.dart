import 'package:biux/config/colors.dart';
import 'package:biux/config/strings.dart';
import 'package:biux/config/styles.dart';
import 'package:biux/data/models/user.dart';
import 'package:biux/ui/screens/group/ui/screens/see_group/view_group_bloc.dart';
import 'package:biux/ui/screens/zoom_screen/zoom_page.dart';
import 'package:biux/ui/widgets/button_facebook_widget.dart';
import 'package:biux/ui/widgets/button_instagram_widget.dart';
import 'package:biux/ui/widgets/button_border_widget.dart';
import 'package:biux/ui/widgets/button_whatsapp_widget.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../../../data/models/group.dart';

class ViewGroupScreen extends StatelessWidget {
  ViewGroupScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<ViewGroupBloc>();
    return Scaffold(
      backgroundColor: AppColors.darkBlue,
      body: Stack(
        alignment: Alignment.bottomRight,
        children: <Widget>[
          Selector<ViewGroupBloc, Group?>(
              selector: (_, bloc) => bloc.group,
              builder: (context, group, child) {
                return _SuperiorSeeGroup(group: bloc.group);
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
                  admin: bloc.admin,
                );
              }),
        ],
      ),
    );
  }
}

class _SuperiorSeeGroup extends StatelessWidget {
  Group group;
  _SuperiorSeeGroup({Key? key, required this.group}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return Stack(children: <Widget>[
      GestureDetector(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Container(
              height: 250,
              width: size.width,
              decoration: BoxDecoration(
                image: new DecorationImage(
                  image: new NetworkImage(
                    group.profileCover,
                  ),
                  opacity: 150.0,
                  fit: BoxFit.cover,
                ),
                borderRadius: BorderRadius.circular(2.0),
              ),
            ),
          ],
        ),
        onTap: () {
          showDialog(
              context: context,
              builder: (BuildContext context) {
                return ZoomPage(group.profileCover, group.name);
              });
        },
      ),
      Container(
        alignment: Alignment.topCenter,
        margin: new EdgeInsets.only(top: 100),
        child: Text(
          group.name,
          style: Styles.containerWhite,
        ),
      ),
      GestureDetector(
        child: Container(
          margin: EdgeInsets.only(top: 45, left: 10),
          height: 50,
          width: 50,
          child: GestureDetector(
            child: Icon(
              Icons.arrow_back_rounded,
              color: AppColors.white,
              size: 45,
            ),
          ),
        ),
        onTap: () {},
      ),
      Container(
        alignment: Alignment.topCenter,
        margin: new EdgeInsets.only(top: 180.0, right: 230),
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
            decoration: new BoxDecoration(
              image: DecorationImage(
                image: new NetworkImage(group.logo),
                fit: BoxFit.cover,
              ),
              borderRadius: BorderRadius.circular(100.0),
            ),
          ),
        ),
      ),
    ]);
  }
}

class _TabBarSeeGroup extends StatefulWidget {
  Group group;
  BiuxUser admin;
  _TabBarSeeGroup({Key? key, required this.group, required this.admin})
      : super(key: key);

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
    Size size = MediaQuery.of(context).size;
    return Container(
      margin: EdgeInsets.only(top: size.height * 0.40),
      child: Column(
        children: <Widget>[
          TabBar(
              onTap: (index) => setState(() => _selectedIndex = index),
              labelPadding: EdgeInsets.zero,
              padding: EdgeInsets.symmetric(horizontal: 20),
              controller: tabController,
              indicatorWeight: 0.01,
              splashBorderRadius: BorderRadius.circular(20),
              unselectedLabelColor: AppColors.black,
              tabs: List<Widget>.generate(
                tabController.length,
                (index) => _TabDecoration(
                  borderRadius: index == 0
                      ? BorderRadius.only(
                          bottomLeft: Radius.circular(20),
                          topLeft: Radius.circular(20))
                      : index == 2
                          ? BorderRadius.only(
                              bottomRight: Radius.circular(20),
                              topRight: Radius.circular(20))
                          : BorderRadius.only(),
                  index: index,
                  selectedIndex: _selectedIndex,
                  numberMembers: widget.group.numberMembers.toString(),
                  numberRoads: widget.group.numberRoads.toString(),
                ),
              )),
          Expanded(
            child: TabBarView(
              physics: NeverScrollableScrollPhysics(),
              controller: tabController,
              children: <Widget>[
                _DescriptionGroup(group: widget.group, userAdmin: widget.admin),
                _DescriptionGroup(group: widget.group, userAdmin: widget.admin),
                _DescriptionGroup(group: widget.group, userAdmin: widget.admin),
              ],
            ),
          ),
        ],
      ),
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
    final bloc = context.read<ViewGroupBloc>();
    return Container(
      margin: EdgeInsets.only(bottom: 325, left: 180),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          if (group.whatsapp.isNotEmpty)
            ButtonWhatsappWidget(
              whatsapp: group.whatsapp,
              name: group.name,
            ),
          Container(
            width: 15,
          ),
          if (group.facebook.isNotEmpty)
            ButtonFacebookWidget(
              linkFacebook: group.facebook,
            ),
          Container(
            width: 15,
          ),
          if (group.instagram.isNotEmpty)
            ButtonInstagramWidget(
              linkinstagram: group.instagram,
            ),
        ],
      ),
    );
  }
}

class _DescriptionGroup extends StatelessWidget {
  Group group;
  BiuxUser userAdmin;
  _DescriptionGroup({Key? key, required this.group, required this.userAdmin})
      : super(key: key);
  @override
  Widget build(BuildContext context) {
    final bloc = context.read<ViewGroupBloc>();

    return Scaffold(
      backgroundColor: AppColors.transparent,
      body: ListView(
        children: <Widget>[
          Stack(
            children: <Widget>[
              Container(
                child: Column(
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: EdgeInsets.only(left: 30, right: 30),
                          child: SizedBox(
                            width: 330,
                            child: Text(
                              group.description,
                              style: Styles.containerDescription,
                            ),
                          ),
                        ),
                      ],
                    ),
                    Container(
                      margin: EdgeInsets.only(top: 20, left: 30, right: 30),
                      child: Row(
                        children: [
                          Text(
                            AppStrings.leader,
                            style: Styles.containerLead,
                          ),
                          Text(
                            ' ${userAdmin.names} ${userAdmin.surnames}',
                            style: Styles.containerDescription,
                          ),
                        ],
                      ),
                    ),
                    Selector<ViewGroupBloc, bool?>(
                        selector: (_, bloc) => bloc.validation,
                        builder: (context, validation, child) {
                          return ButtonBorderWidget(
                            onPressed: () => bloc.validation
                                ? bloc.leaveGroup
                                : bloc.joinGroup,
                            text: bloc.validation
                                ? AppStrings.outText
                                : AppStrings.joinMe,
                          );
                        })
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _TabDecoration extends StatelessWidget {
  const _TabDecoration({
    Key? key,
    this.numberMembers = '0',
    this.numberRoads = '0',
    required this.borderRadius,
    required this.index,
    required this.selectedIndex,
  }) : super(key: key);
  final int index;
  final int selectedIndex;
  final String numberRoads;
  final String numberMembers;
  final BorderRadius borderRadius;

  @override
  Widget build(BuildContext context) {
    return Tab(
      iconMargin: EdgeInsets.zero,
      child: Container(
          alignment: Alignment.center,
          height: 50,
          width: 300,
          child: Text(
              index == 0
                  ? AppStrings.description2
                  : index == 1
                      ? AppStrings.rodadas(numberRodadas: numberRoads)
                      : index == 2
                          ? AppStrings.seguidores(members: numberMembers)
                          : '',
              textAlign: TextAlign.center),
          decoration: BoxDecoration(
              borderRadius: borderRadius,
              color: index == selectedIndex
                  ? AppColors.strongCyan
                  : AppColors.white)),
    );
  }
}
