import 'package:biux/config/colors.dart';
import 'package:biux/config/images.dart';
import 'package:biux/config/strings.dart';
import 'package:biux/config/styles.dart';
import 'package:biux/ui/screens/main_menu/main_menu_bloc.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class MainMenu extends StatelessWidget {
  MainMenu({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<MainMenuBloc>();
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.greyishNavyBlue,
        title: Selector<MainMenuBloc, int>(
            selector: (_, bloc) => bloc.pageIndex,
            builder: (context, value, child) {
              return _AppBar();
            }),
        actions: [
          Selector<MainMenuBloc, int>(
              selector: (_, bloc) => bloc.pageIndex,
              builder: (context, value, child) {
                return _ActionButton();
              }),
        ],
      ),
      drawer: Selector<MainMenuBloc, int>(
          selector: (_, bloc) => bloc.pageIndex,
          builder: (context, value, child) {
            return _MainMenuDrawer();
          }),
      bottomNavigationBar: Selector<MainMenuBloc, int>(
          selector: (_, bloc) => bloc.pageIndex,
          builder: (context, value, child) {
            return _BottomNavigationBar();
          }),
          body: SafeArea(
        child: IndexedStack(
          index: bloc.pageIndex,
          children: bloc.children,
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
        Text(AppStrings.APP_NAME.toUpperCase(), style: Styles.mainMenuTextBiux),
      ],
    );
  }
}

class _ActionButton extends StatelessWidget {
  _ActionButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<MainMenuBloc>();
    return Row(children: <Widget>[
      if (bloc.pageIndex == 0 || bloc.pageIndex == 1)
      Container(
        height: 32,
        width: 32,
        margin: EdgeInsets.only(right: 30),
        child: GestureDetector(
          onTap: () {},
          child: Image.asset(Images.kImageAdd),
        ),
      ),
    ]);
  }
}

class _MainMenuDrawer extends StatelessWidget {
   _MainMenuDrawer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<MainMenuBloc>();
    return Container(
      color: AppColors.greyishNavyBlue,
      width: 300,
      child: Drawer(
        backgroundColor: AppColors.darkBlue,
        child: ListView(children: <Widget>[
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
                    image: NetworkImage(bloc.user.photo!),
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
              bloc.user.names == '' ? AppStrings.loadingName : bloc.user.names!,
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
                AppStrings.editProfile,
                style: Styles.containerTextGroup,
              ),
              onPressed: () {},
            ),
          ),
          Container(
            margin: EdgeInsets.only(left: 20, top: 10),
            height: 500,
            child: Column(children: <Widget>[
              ListTile(
                horizontalTitleGap: 10,
                leading: Image.asset(
                  Images.kImageHome,
                  color: AppColors.white,
                  height: 30,
                ),
                title: Text(
                  AppStrings.beginning,
                  style: Styles.containerTextName,
                ),
                onTap: () {},
              ),
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
                onTap: () {},
              ),
            ]),
          )
        ]),
      ),
    );
  }
}

class _BottomNavigationBar extends StatelessWidget {
  _BottomNavigationBar({Key? key}) : super(key: key);
  GlobalKey _bottomNavigationKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<MainMenuBloc>();
    return CurvedNavigationBar(
      height: 65,
      backgroundColor: AppColors.transparent,
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
