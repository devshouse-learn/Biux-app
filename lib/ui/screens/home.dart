import 'package:biux/config/colors.dart';
import 'package:biux/config/images.dart';
import 'package:biux/config/strings.dart';
import 'package:biux/config/styles.dart';
import 'package:biux/config/themes/theme.dart';
import 'package:biux/config/themes/theme_notifier.dart';
import 'package:biux/data/models/advertising.dart';
import 'package:biux/data/models/city.dart';
import 'package:biux/data/models/group.dart';
import 'package:biux/data/models/member.dart';
import 'package:biux/data/models/user.dart';
import 'package:biux/data/models/user_membership.dart';
import 'package:biux/data/repositories/authentication_repository.dart';
import 'package:biux/data/repositories/members/members_repository.dart';
import 'package:biux/data/repositories/users/user_repository.dart';
import 'package:biux/data/shared_preferences/localstorage.dart';
import 'package:biux/data/shared_preferences/shared_preferences.dart';
import 'package:biux/ui/screens/group/my_groups.dart';
import 'package:biux/ui/screens/group/ui/screens/group_create.dart';
import 'package:biux/ui/screens/group/ui/screens/group_slider/group_slider.dart';
import 'package:biux/ui/screens/group/ui/screens/groups_list.dart';
import 'package:biux/ui/screens/login/login.dart';
import 'package:biux/ui/screens/map/menu_map.dart';
import 'package:biux/ui/screens/roads/ui/screens/create_road.dart';
import 'package:biux/ui/screens/roads/ui/screens/menu_roads.dart';
import 'package:biux/ui/screens/story/ui/screens/stories_screen.dart';
import 'package:biux/ui/screens/story/ui/screens/upload_page.dart';
import 'package:biux/ui/screens/user/ui/view_profile_biux.dart';
import 'package:biux/ui/widgets/circle_image_widget.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:palette_generator/palette_generator.dart';
import 'package:proste_dialog/proste_dialog.dart';
import 'package:provider/provider.dart';
import 'package:stylish_bottom_bar/stylish_bottom_bar.dart';

class MyHome extends StatefulWidget {
  @override
  _MyHomeState createState() => _MyHomeState();
}

class _MyHomeState extends State<MyHome> {
  int _pageIndex = 0;
  late BiuxUser user;
  late UserMembership userMembership;
  var heart = false;
  GlobalKey _bottomNavigationKey = GlobalKey();
  int gifCurrent = 0;
  String urlGif1 = Images.kGifSports;
  String urlGif2 = Images.kGifBike;
  int textCurrent = 0;
  String text1 = AppStrings.messageUpdate;
  int currentTitle = 0;
  String title1 = AppStrings.messageUpdate2;
  String title2 = AppStrings.messageWelcome;
  String noFoud = AppStrings.urlDetailGroup;
  var profile;
  String asl = Images.kBiuxLogoBackgroundWhite;
  String logod = Images.kBiuxLogoLettersGray;
  String exit = Images.kExit;
  late ThemeData theme;
  late bool isLoggedIn;
  String text3 = AppStrings.publicidad;
  bool active = false;
  late Group group;
  late String username;
  late List<City> city;
  late Member member;
  late bool vip = false;
  late String idUser;
  final googleSignIn = GoogleSignIn();
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  var userRecord;
  var userRecord2;
  late User currentUserModel;
  late Advertising advertising;
  late PaletteGenerator paletteGenerator;
  var bgColor;
  late int joinMe;
  late bool valRef = false;
  // datos del admin del grupo
  late BiuxUser admin;

  void initState() {
    super.initState();
    joinMe = 0;
    user = BiuxUser();
    getUserProfile();
    getData();
  }

  getUserProfile() {
    Future.delayed(
      Duration.zero,
      () async {
        username = (await LocalStorage().getUser())!;
        city = await UserRepository().getCities();
        final useR = await UserRepository().getPerson(username);
        final ref =
            FirebaseFirestore.instance.collection(AppStrings.instaUsers);
        final nMember = await MembersRepository().getMyGroupsUser(user.id!);

        LocalStorage().saveUserId(
          user.id.toString(),
        );

        if (useR != null) {
          setState(
            () {
              user = useR;
              member = nMember;
              vip = user.premium!;
              final nombreAdmin = admin.id ?? '';
              if (nombreAdmin == user.id) {
                joinMe = 1;
              }
            },
          );
        }
        userRecord = await ref
            .where(AppStrings.idText,
                isEqualTo: AppStrings.idUFirebase(id: user.id.toString()))
            .get();
        if (userRecord.docs.isEmpty) {
          ref.doc(AppStrings.idUFirebase(id: user.id.toString())).set(
            {
              AppStrings.idText: AppStrings.idUFirebase(id: user.id.toString()),
              AppStrings.user: user.userName,
              AppStrings.nameVal: user.userName,
              AppStrings.photoText: user.photo,
              AppStrings.profileCoverText: user.profileCover,
              AppStrings.emailText: user.email,
              AppStrings.name: user.names,
              AppStrings.surname: user.surnames,
              AppStrings.bio: "",
              AppStrings.followersText: {},
              AppStrings.followingText: {},
            },
          );
        }

        userRecord = await ref
            .where(AppStrings.idText,
                isEqualTo:
                    AppStrings.idGFirebase(id: member.group!.id.toString()))
            .get();
        if (userRecord2 == null) {
          ref.doc(AppStrings.idGFirebase(id: member.group!.id.toString())).set(
            {
              AppStrings.idText:
                  AppStrings.idGFirebase(id: member.group!.id.toString()),
              AppStrings.user: member.group!.name,
              AppStrings.nameVal: user.userName,
              AppStrings.photoText: member.group!.logo,
              AppStrings.facebookText2: member.group!.facebook,
              AppStrings.emailText: member.group!.name,
              AppStrings.bio: "",
              AppStrings.followersText: {},
              AppStrings.followingText: {},
            },
          );
        }
      },
    );
  }

  List<Widget> _children = [];
//
  final MenuRoads _first = MenuRoads();
  // final MenuHistorias _secound = MenuHistorias();
  final GroupsList _third = new GroupsList();
  final MenuMap _four = new MenuMap("", "");
  Widget _showPage = new MenuRoads();

  void onLoginStatusChanged(
    bool isLoggedIn,
  ) {
    setState(() {
      this.isLoggedIn = isLoggedIn;
    });
  }

  int postCount = 0;
  var _darkTheme = true;

  getData() {
    _children = [
      MenuRoads(),
      StoriesScreen(
        photo: '',
        user: '',
        location: '',
        description: '',
        postId: '',
        ownerId: '',
        timestamp: Timestamp.now(),
      ),
      GroupsList(),
      MenuMap("", ""),
    ];
  }

  Widget build(BuildContext context) {
    bool keyboardIsOpen = MediaQuery.of(context).viewInsets.bottom != 0;
    userMembership = UserMembership();
    final themeNotifier = Provider.of<ThemeNotifier>(context);
    _darkTheme = (themeNotifier.getTheme() == darkTheme);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: WillPopScope(
        onWillPop: () {
          showAlert(context);
          return Future.value(false);
        },
        child: Scaffold(
          resizeToAvoidBottomInset: true,
          extendBody: true,
          appBar: new AppBar(
            backgroundColor: AppColors.greyishNavyBlue,
            title: Stack(
              children: <Widget>[
                Image.asset(
                  asl,
                  color: Theme.of(context).colorScheme.onBackground,
                  fit: BoxFit.contain,
                  height: 32,
                ),
              ],
            ),
            actions: <Widget>[
            ],
          ),
          drawer: Container(
            color: AppColors.greyishNavyBlue,
            width: 250,
            // height: double.infinity,
            child: Theme(
              data: ThemeData(
                accentColor: AppColors.white,
                accentTextTheme: TextTheme(
                  bodyText1: _darkTheme == true
                      ? Styles.accentTextThemeWhite
                      : Styles.accentTextThemeBlack,
                ),
                canvasColor: AppColors.greyishNavyBlue,
              ),
              child: Drawer(
                child: ListView(
                  children: <Widget>[
                    Container(
                      margin: EdgeInsets.only(top: 30),
                      padding: EdgeInsets.only(right: 50, left: 50),
                      width: 50,
                      height: 180,
                      child: CircleImage(user, userMembership),
                      // minRadius: 90,
                      // maxRadius: 150,
                    ),
                    Container(
                      height: 10,
                    ),
                    Wrap(
                      children: <Widget>[
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (BuildContext context) =>
                                    ViewProfileBiux(
                                  user: user,
                                ),
                              ),
                            );
                          },
                          child: Container(
                            padding: EdgeInsets.only(
                              left: 20,
                              bottom: 5,
                            ),
                            child: Text(
                              user.names ?? AppStrings.loadingName,
                              style: _darkTheme == true
                                  ? Styles.wrapDrawerWhite
                                  : Styles.wrapDrawerBlack,
                            ),
                          ),
                        ),
                      ],
                    ),
                    Container(
                      height: 20,
                    ),
                    Container(
                      height: 500,
                      child: Column(
                        children: [
                          Container(
                            width: 50,
                            height: 50,
                            child: Image.asset(
                              logo,
                              width: 120,
                              height: 120,
                            ),
                          ),
                          Container(
                            height: 20,
                          ),
                          ListTile(
                            leading: Icon(
                              Icons.person_outline,
                              color: _darkTheme == true
                                  ? AppColors.white
                                  : AppColors.black,
                            ),
                            title: Text(
                              AppStrings.viewProfile,
                              style: _darkTheme == true
                                  ? Styles.wrapDrawerListTileWhite
                                  : Styles.wrapDrawerListTileBlack,
                            ),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (BuildContext context) =>
                                      ViewProfileBiux(
                                    user: user,
                                  ),
                                ),
                              );
                            },
                          ),
                          ListTile(
                            leading: Icon(
                              Icons.group_outlined,
                              color: _darkTheme == true
                                  ? AppColors.white
                                  : AppColors.black,
                            ),
                            title: Text(
                              AppStrings.MyGroupText,
                              style: _darkTheme == true
                                  ? Styles.wrapDrawerListTileWhite
                                  : Styles.wrapDrawerListTileBlack,
                            ),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (BuildContext context) => MyGroups(
                                    user.id!,
                                  ),
                                ),
                              );
                            },
                          ),
                          joinMe == 0
                              ? ListTile(
                                  leading: Icon(
                                    Icons.supervised_user_circle_outlined,
                                    color: _darkTheme == true
                                        ? AppColors.white
                                        : AppColors.black,
                                  ),
                                  title: Text(
                                    AppStrings.createGroupText,
                                    style: _darkTheme == true
                                        ? Styles.wrapDrawerListTileWhite
                                        : Styles.wrapDrawerListTileBlack,
                                  ),
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (BuildContext context) =>
                                            GroupScreen(),
                                      ),
                                    );
                                  },
                                )
                              : ListTile(
                                  leading: Icon(
                                    Icons.supervised_user_circle,
                                    color: _darkTheme == true
                                        ? AppColors.white
                                        : AppColors.black,
                                  ),
                                  title: Text(
                                    AppStrings.myGrupoText2,
                                    style: _darkTheme == true
                                        ? Styles.wrapDrawerListTileWhite
                                        : Styles.wrapDrawerListTileBlack,
                                  ),
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (BuildContext context) =>
                                            GroupSlider(
                                          member.group,
                                        ),
                                      ),
                                    );
                                  },
                                ),
                          // miembro.usuario.id == null
                          // ? 0
                          // :
                          joinMe == 0
                              ? Container()
                              : joinMe == 1
                                  ? ListTile(
                                      leading: Icon(
                                        Icons.directions_bike,
                                        color: _darkTheme == true
                                            ? AppColors.white
                                            : AppColors.black,
                                      ),
                                      title: Text(
                                        AppStrings.createRoll,
                                        style: _darkTheme == true
                                            ? Styles.wrapDrawerListTileWhite
                                            : Styles.wrapDrawerListTileBlack,
                                      ),
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (BuildContext context) =>
                                                CreateRoad(),
                                          ),
                                        );
                                      },
                                    )
                                  : joinMe == 2
                                      ? ListTile(
                                          leading: Icon(
                                            Icons.directions_bike,
                                            color: _darkTheme == true
                                                ? AppColors.white
                                                : AppColors.black,
                                          ),
                                          title: Text(
                                            AppStrings.noFound,
                                            style: _darkTheme == true
                                                ? Styles.wrapDrawerListTileWhite
                                                : Styles
                                                    .wrapDrawerListTileBlack,
                                          ),
                                          onTap: () {},
                                        )
                                      : Container(),
                          ListTile(
                            leading: Icon(
                              Icons.exit_to_app,
                              color: _darkTheme == true
                                  ? AppColors.white
                                  : AppColors.black,
                            ),
                            title: Text(
                              AppStrings.signOff,
                              style: _darkTheme == true
                                  ? Styles.wrapDrawerListTileWhite
                                  : Styles.wrapDrawerListTileBlack,
                            ),
                            onTap: () {
                              showDialog(
                                barrierDismissible: true,
                                context: context,
                                builder: (BuildContext context) {
                                  // return object of type Dialog
                                  return MaterialApp(
                                    home: AlertDialog(
                                      backgroundColor:
                                          AppColors.greyishNavyBlue2,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.all(
                                          Radius.circular(
                                            15.0,
                                          ),
                                        ),
                                      ),
                                      title: Text(
                                        AppStrings.wantSignOff,
                                        style: Styles.accentTextThemeWhite,
                                      ),
                                      content: Text(
                                        AppStrings.signOff2,
                                        style: Styles.accentTextThemeWhite,
                                      ),
                                      actions: <Widget>[
                                        // usually buttons at the bottom of the dialog
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            FlatButton(
                                              color: AppColors.strongCyan,
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(10.0),
                                                side: BorderSide(
                                                  width: 3,
                                                  color: AppColors.strongCyan,
                                                ),
                                              ),
                                              child: Text(
                                                AppStrings.signOff,
                                                style:
                                                    Styles.accentTextThemeWhite,
                                              ),
                                              onPressed: () async {
                                                await FacebookAuth.instance
                                                    .logOut();
                                                await AuthenticationRepository.signOut(
                                                  context: context,
                                                );
                                                deleteLoginToken();
                                                // pushNotificationsManager
                                                //     .unSubscribeToTopic("biux-all");
                                                LocalStorage().deleteGroupsId();
                                                Navigator.pushAndRemoveUntil(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (context) =>
                                                        LoginPage(),
                                                  ),
                                                  ModalRoute.withName(""),
                                                );
                                                // Navigator.pop(context);
                                              },
                                            ),
                                          ],
                                        ),
                                        Container(
                                          width: 80,
                                        )
                                      ],
                                    ),
                                  );
                                },
                              );
                            },
                          ),
                          Container(
                            height: 30,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          bottomNavigationBar: StylishBottomBar(
            padding: EdgeInsets.all(12),
            inkColor: AppColors.transparent,
            backgroundColor: AppColors.greyishNavyBlue,
            inkEffect: true,
            elevation: 7,
            // borderRadius: new BorderRadius.circular(30.0),
            hasNotch: true,
            items: [
              AnimatedBarItems(
                icon: Icon(
                  Icons.directions_bike,
                ),
                backgroundColor: AppColors.white,
                selectedColor: AppColors.white,
                title: Text(AppStrings.rolled),
              ),
              AnimatedBarItems(
                icon: Icon(
                  Icons.import_contacts,
                  size: 25,
                ),
                backgroundColor: AppColors.white,
                selectedColor: AppColors.white,
                title: Text(AppStrings.storyText),
              ),
              AnimatedBarItems(
                icon: Icon(
                  Icons.group,
                ),
                backgroundColor: AppColors.white,
                selectedColor: AppColors.white,
                title: Text(AppStrings.gruposText),
              ),
              AnimatedBarItems(
                icon: Icon(
                  Icons.room_preferences_outlined,
                ),
                backgroundColor: AppColors.white,
                selectedColor: AppColors.white,
                title: Text(AppStrings.map),
              ),
            ],
            iconSize: 25,
            barAnimation: BarAnimation.blink,
            currentIndex: _pageIndex,
            onTap: onTabTapped,
          ),
          floatingActionButton: _pageIndex == 0 && joinMe == 0
              ? Container(
                  height: 0,
                  width: 0,
                )
              : _pageIndex == 2 && joinMe != 0
                  ? Container(
                      height: 0,
                      width: 0,
                    )
                  : _pageIndex == 3
                      ? Container(
                          height: 0,
                          width: 0,
                        )
                      : Visibility(
                          visible: !keyboardIsOpen,
                          child: FloatingActionButton(
                            onPressed: () {
                              _pageIndex == 0
                                  ? Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (BuildContext context) =>
                                            CreateRoad(),
                                      ),
                                    )
                                  : _pageIndex == 1
                                      ? Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (BuildContext context) =>
                                                Uploader(user),
                                          ),
                                        )
                                      : _pageIndex == 2
                                          ? Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder:
                                                    (BuildContext context) =>
                                                        GroupScreen(),
                                              ),
                                            )
                                          : Container();
                            },
                            backgroundColor: AppColors.strongCyan,
                            child: Icon(
                              CupertinoIcons.add,
                              color: AppColors.white,
                            ),
                          ),
                        ),
          floatingActionButtonLocation:
              FloatingActionButtonLocation.miniCenterDocked,
          backgroundColor:
              bgColor != null ? bgColor.withOpacity(1.0) : AppColors.white,
          body: AnimatedContainer(
            duration: Duration(milliseconds: 2000),
            child: SafeArea(
              child: IndexedStack(
                index: _pageIndex,
                children: _children,
              ),
            ),
          ),
        ),
      ),
    );
  }

  void onTabTapped(int? index) {
    setState(() {
      _pageIndex = index!;
    });
  }

  void showAlert(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => ProsteCustomDialog(
        header: Image.asset(
          exit,
          fit: BoxFit.cover,
        ),
        // type: _tipType,
        content: Text(
          '',
          style: Styles.showDialogContentBlack,
          textAlign: TextAlign.center,
        ),
        insetPadding: EdgeInsets.all(15),
        title: Text(
          AppStrings
              .messageConfirmExit, //tituloactual == 0 ? titulo1 : titulo2,
          textAlign: TextAlign.center,
          style: Styles.showDialogTitleBlack,
        ),
        titlePadding: EdgeInsets.only(top: 20),
        contentPadding: EdgeInsets.all(15),
        confirmButtonColor: AppColors.deepNavyBlue,
        confirmButtonText: Text(
          AppStrings.confirm,
          style: Styles.accentTextThemeWhite,
        ),
        cancelButtonText: Text(
          AppStrings.close,
          style: Styles.cancelButtonText,
        ),
        showConfirmButton: true,
        showCancelButton: true,
        btnsInARow: false,
        btnPadding: EdgeInsets.symmetric(
          vertical: 10,
        ),
        confirmButtonMargin: EdgeInsets.symmetric(
          horizontal: 50,
        ),
        buttonRadius: 20,
        onConfirm: () {
          SystemNavigator.pop();
        },
      ),
    );
  }
}