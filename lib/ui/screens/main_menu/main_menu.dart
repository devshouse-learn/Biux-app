import 'package:biux/config/colors.dart';
import 'package:biux/config/images.dart';
import 'package:biux/config/router/router_path.dart';
import 'package:biux/config/strings.dart';
import 'package:biux/config/styles.dart';
import 'package:biux/ui/screens/group/ui/screens/group_list/group_list_screen.dart';
import 'package:biux/ui/screens/main_menu/main_menu_bloc.dart';
import 'package:biux/ui/screens/story/story_view/story_view_bloc.dart';
import 'package:biux/ui/screens/story/story_view/story_view_screen.dart';
import 'package:biux/ui/screens/roads/roads_list/roads_list_screen.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class MainMenu extends StatelessWidget {
  MainMenu({Key? key}) : super(key: key);

  final List<Widget> children = [
    StoryViewScreen(),
    RoadsListScreen(),
    GroupListScreen(),
    GroupListScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final bloc = context.watch<MainMenuBloc>();
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.blackPearl,
        title: Selector<MainMenuBloc, int>(
          selector: (_, bloc) => bloc.pageIndex,
          builder: (context, value, child) {
            return _AppBar();
          },
        ),
        actions: [
          Selector<MainMenuBloc, int>(
            selector: (_, bloc) => bloc.pageIndex,
            builder: (context, value, child) {
              return _ActionButton();
            },
          ),
        ],
      ),
      drawer: Selector<MainMenuBloc, int>(
        selector: (_, bloc) => bloc.pageIndex,
        builder: (context, value, child) {
          return _MainMenuDrawer();
        },
      ),
      bottomNavigationBar: Selector<MainMenuBloc, int>(
          selector: (_, bloc) => bloc.pageIndex,
          builder: (context, value, child) {
            return _BottomNavigationBar();
          }),
      body: Container(
        height: 1500,
        child: IndexedStack(
          alignment: AlignmentDirectional.center,
          index: bloc.pageIndex,
          children: children,
        ),
      ),
    );
  }
}

class _AppBar extends StatelessWidget {
  _AppBar({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<MainMenuBloc>();
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: <Widget>[
        if (bloc.pageIndex == 0)
          Text(
            '${AppStrings.storyText} ',
          )
        else if (bloc.pageIndex == 1)
          Text(
            '${AppStrings.rolled} ',
          )
        else if (bloc.pageIndex == 2)
          Text(
            '${AppStrings.gruposText} ',
          )
        else if (bloc.pageIndex == 3)
          Text(
            '${AppStrings.map} ',
          ),
        Text(
          AppStrings.APP_NAME.toUpperCase(),
          style: Styles.mainMenuTextBiux,
        ),
      ],
    );
  }
}

class _ActionButton extends StatelessWidget {
  _ActionButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<MainMenuBloc>();
    return Row(
      children: <Widget>[
        if (bloc.pageIndex == 0)
          Container(
            height: 32,
            width: 32,
            margin: EdgeInsets.only(right: 30),
            child: GestureDetector(
              onTap: () async {
                final bloc = context.read<StoryViewBloc>();
                final result = await Navigator.pushNamed(
                  context,
                  AppRoutes.storyCreateRoute,
                );
                if (result as bool) {
                  bloc.getIntitalStories();
                }
              },
              child: Image.asset(Images.kImageAdd),
            ),
          ),
      ],
    );
  }
}

class _MainMenuDrawer extends StatelessWidget {
  _MainMenuDrawer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bloc = context.watch<MainMenuBloc>();
    return Container(
      color: AppColors.greyishNavyBlue,
      width: 300,
      child: Drawer(
        backgroundColor: AppColors.darkBlue,
        child: ListView(
          children: <Widget>[
            Container(
              padding: EdgeInsets.only(top: 15, left: 5),
              child: Image.asset(
                Images.kBiuxLogoBackgroundWhite,
                color: AppColors.white,
                height: 30,
              ),
            ),
            Container(
              alignment: Alignment.center,
              margin: EdgeInsets.only(top: 20),
              child: GestureDetector(
                onTap: () {},
                child: Container(
                  height: 130,
                  width: 130,
                  decoration: BoxDecoration(
                    border: Border.all(color: AppColors.white, width: 4),
                    image: DecorationImage(
                      image: NetworkImage(bloc.user.photo),
                      fit: BoxFit.cover,
                    ),
                    borderRadius: BorderRadius.circular(100.0),
                  ),
                ),
              ),
            ),
            Container(
              margin: EdgeInsets.symmetric(vertical: 10),
              alignment: Alignment.center,
              child: Text(
                bloc.user.fullName,
                style: Styles.containerTextName,
              ),
            ),
            Container(
              margin: EdgeInsets.only(left: 30, right: 30),
              child: RaisedButton(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
                color: AppColors.white,
                child: Text(
                  AppStrings.viewProfile,
                  style: Styles.containerTextGroup,
                ),
                onPressed: () {
                  bloc.onTapViewProfile(context);
                },
              ),
            ),
            Container(
              margin: EdgeInsets.only(left: 20, top: 10),
              height: 500,
              child: Column(
                children: <Widget>[
                  ListTile(
                    horizontalTitleGap: 10,
                    leading: Image.asset(
                      Images.kImageNotification,
                      color: AppColors.white,
                      height: 30,
                    ),
                    title: Text(
                      AppStrings.notifications,
                      style: Styles.containerTextName,
                    ),
                    onTap: () {},
                  ),
                  ListTile(
                    horizontalTitleGap: 10,
                    leading: Image.asset(
                      Images.kImageRoads,
                      color: AppColors.white,
                      height: 30,
                    ),
                    title: Text(
                      AppStrings.myRoads,
                      style: Styles.containerTextName,
                    ),
                    onTap: () {},
                  ),
                  ListTile(
                    horizontalTitleGap: 10,
                    leading: Image.asset(
                      Images.kImageGroups,
                      color: AppColors.white,
                      height: 30,
                    ),
                    title: Text(
                      AppStrings.MyGroupText,
                      style: Styles.containerTextName,
                    ),
                    onTap: () {},
                  ),
                  ListTile(
                    horizontalTitleGap: 10,
                    leading: Image.asset(
                      Images.kImageDisconnect,
                      color: AppColors.white,
                      height: 30,
                    ),
                    title: Text(
                      AppStrings.signOff,
                      style: Styles.containerTextName,
                    ),
                    onTap: () async {
                      showDialogSignOut(
                        context: context,
                        onTap: () async {
                          await bloc.signOut();
                          Navigator.pushNamedAndRemoveUntil(
                            context,
                            AppRoutes.loginRoute,
                            (route) => false,
                          );
                        },
                      );
                    },
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}

void showDialogSignOut({
  required BuildContext context,
  required VoidCallback onTap,
}) async {
  return await showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) {
      return AlertDialog(
        backgroundColor: AppColors.transparent,
        alignment: Alignment.center,
        contentPadding: EdgeInsets.zero,
        content: DecoratedBox(
          decoration: ShapeDecoration(
            color: AppColors.transparent,
            shape: RoundedRectangleBorder(
                  side: BorderSide(
                    color: AppColors.white,
                    width: double.infinity,
                  ),
                  borderRadius: BorderRadius.all(
                    Radius.circular(20),
                  ),
                ) +
                Border(
                  bottom: BorderSide(
                    width: 20,
                    color: AppColors.transparent,
                  ),
                ) +
                Border.symmetric(
                  vertical: BorderSide(
                    width: 5,
                    color: AppColors.transparent,
                  ),
                ) +
                Border.symmetric(
                  vertical: BorderSide(
                    width: 5,
                    color: AppColors.transparent,
                  ),
                ) +
                Border(
                  top: BorderSide(
                    width: 20,
                    color: AppColors.transparent,
                  ),
                ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Expanded(
                    child: const SizedBox(),
                  ),
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: AppColors.transparent,
                        width: 4,
                      ),
                      image: DecorationImage(
                        image: AssetImage(Images.kBiuxLogoBackgroundBlue),
                        fit: BoxFit.cover,
                      ),
                      borderRadius: BorderRadius.circular(100.0),
                    ),
                  ),
                  Expanded(
                    child: Align(
                      alignment: Alignment.topRight,
                      child: ClipOval(
                        child: Material(
                          color: AppColors.strongCyan,
                          child: InkWell(
                            splashColor: AppColors.strongCyan,
                            onTap: () => Navigator.of(context).pop(),
                            child: SizedBox(
                              width: 25,
                              height: 25,
                              child: Icon(
                                Icons.close,
                                color: AppColors.white,
                                size: 20,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(
                height: 25,
              ),
              RichText(
                text: TextSpan(
                  style: Styles.accentTextThemeBlack,
                  children: [
                    TextSpan(text: AppStrings.wantText),
                    TextSpan(text: AppStrings.wantSignOff),
                    TextSpan(text: AppStrings.symbolText)
                  ],
                ),
              ),
              const SizedBox(
                height: 25,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  SizedBox(
                    width: 110,
                    child: TextButton(
                      style: Styles().textButtonWhiteStyle,
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: Text(
                        AppStrings.cancelText,
                        style: Styles.containerImage.copyWith(
                          color: AppColors.black,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 110,
                    child: TextButton(
                      style: Styles().textButtonStyle,
                      onPressed: () {
                        onTap();
                        Navigator.pop(context);
                      },
                      child: Text(
                        AppStrings.confirm,
                        style: Styles.containerImage,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    },
  );
}

class _BottomNavigationBar extends StatelessWidget {
  _BottomNavigationBar({Key? key}) : super(key: key);
  final GlobalKey _bottomNavigationKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<MainMenuBloc>();
    return CurvedNavigationBar(
      height: 65,
      backgroundColor: AppColors.white2,
      key: _bottomNavigationKey,
      color: AppColors.darkBlue,
      buttonBackgroundColor: AppColors.white,
      index: bloc.pageIndex,
      items: <Widget>[
        Image.asset(
          Images.kImageGallery,
          color: bloc.pageIndex == 0 ? AppColors.darkBlue : AppColors.white,
          height: 30,
        ),
        Container(
          child: Icon(
            Icons.directions_bike,
            color: bloc.pageIndex == 1 ? AppColors.darkBlue : AppColors.white,
            size: 30,
          ),
        ),
        Image.asset(
          Images.kImageSocial,
          color: bloc.pageIndex == 2 ? AppColors.darkBlue : AppColors.white,
          height: 30,
        ),
        Image.asset(
          Images.kImageLocation,
          color: bloc.pageIndex == 3 ? AppColors.darkBlue : AppColors.white,
          height: 30,
        ),
      ],
      onTap: bloc.onTabTapped,
    );
  }
}
