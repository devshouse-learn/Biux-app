import 'package:biux/config/colors.dart';
import 'package:biux/config/styles.dart';
import 'package:biux/config/strings.dart';
import 'package:biux/config/themes/theme.dart';
import 'package:biux/config/themes/theme_notifier.dart';
import 'package:biux/data/shared_preferences/localstorage.dart';
import 'package:biux/data/models/group.dart';
import 'package:biux/data/models/member.dart';
import 'package:biux/data/models/user.dart';
import 'package:biux/data/models/city.dart';
import 'package:biux/data/repositories/members/members_repository.dart';
import 'package:biux/data/repositories/users/user_repository.dart';
import 'package:biux/ui/screens/group/ui/screens/group_slider/edit_group.dart';
import 'package:biux/ui/screens/home.dart';
import 'package:biux/ui/screens/story/ui/screens/stories_screen.dart';
import 'package:biux/ui/screens/user/ui/screens/detail_users.dart';
import 'package:biux/ui/widgets/loading_widget.dart';
import 'package:biux/ui/widgets/view_image_widget.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';
import 'package:photo_view/photo_view.dart';
import 'package:vector_math/vector_math_64.dart' show Vector3;

class DetailGroup extends StatefulWidget {
  DetailGroup({
    this.group,
    this.onReassemble,
    this.user,
    this.currentUserId,
    this.photo,
    this.userName,
    this.admin,
  });

  final BiuxUser? user;
  final BiuxUser? admin;
  final int? currentUserId;
  final String? photo;
  final String? userName;
  final Group? group;
  final VoidCallback? onReassemble;

  _DetailGroupState createState() => _DetailGroupState(
        this.user,
        this.currentUserId,
        this.userName,
        this.photo,
      );
}

class _DetailGroupState extends State<DetailGroup> {
  final BiuxUser? user;
  final int? currentUserId;
  final String? photo;
  final String? username;
  int postCount = 0;
  int followerCount = 0;
  int followingCount = 0;
  late Function byEnd;
  bool isFollowing = false;
  bool followButtonClicked = false;
  late Member member;
  late BiuxUser useR;
  late City city;
  bool pressGeoON = false;
  late String nameADM;
  bool cmbscritta = false;
  bool loading = false;
  ThemeData theme = darkTheme;
  late String userId;
  int joinMe = 0;
  var adminName;
  var userName;

  _DetailGroupState(
    this.user,
    this.currentUserId,
    this.photo,
    this.username,
  );

  followUser() {
    setState(() {
      this.isFollowing = true;
      followButtonClicked = true;
    });
    FirebaseFirestore.instance
        .doc(AppStrings.instaUserFirebase2(id: currentUserId.toString()))
        .update(
      {AppStrings.followersFirebase(id: currentUserId.toString()): true},
    );
    FirebaseFirestore.instance
        .doc(AppStrings.instaUserFirebase2(id: currentUserId.toString()))
        .update(
      {AppStrings.followingFirebase(id: currentUserId.toString()): true},
    );
    FirebaseFirestore.instance
        .collection(AppStrings.instaFeed)
        .doc(AppStrings.idGFirebase(id: currentUserId.toString()))
        .collection(AppStrings.items)
        .doc(AppStrings.idGFirebase(id: currentUserId.toString()))
        .set(
      {
        AppStrings.ownerIdText: currentUserId.toString(),
        AppStrings.userNameText: username,
        AppStrings.userIdText: currentUserId.toString(),
        AppStrings.typeText: AppStrings.followText,
        AppStrings.userProfileImgText: photo,
        AppStrings.timestamp: DateTime.now(),
      },
    );
  }

  void initState() {
    super.initState();
    member = Member();
    useR = BiuxUser();
    city = City();
    getUserProfile();
    LocalStorage()
        .saveGroupId(AppStrings.idGFirebase(id: widget.group!.id.toString()));
  }

  unfollowUser() {
    setState(() {
      isFollowing = false;
      followButtonClicked = true;
    });

    FirebaseFirestore.instance
        .doc(AppStrings.instaUserFirebase2(id: currentUserId.toString()))
        .update({
      AppStrings.followersFirebase(id: currentUserId.toString()): false
    });

    FirebaseFirestore.instance
        .doc(AppStrings.instaUserFirebase2(id: currentUserId.toString()))
        .update({
      AppStrings.followingFirebase(id: currentUserId.toString()): false
    });

    FirebaseFirestore.instance
        .collection(AppStrings.instaFeed)
        .doc(currentUserId.toString())
        .collection(AppStrings.items)
        .doc(currentUserId.toString())
        .delete();
  }

  getUserProfile() async {
    String? username = await LocalStorage().getUser();
    String? id = await LocalStorage().getUserId();
    userId = id!;

    Future.delayed(
      Duration.zero,
      () async {
        useR = await UserRepository().getPerson(username!);
        member = await MembersRepository().getApproved(
          widget.group!.id,
          userId,
        );
        // Se debe llamar los datos del admin
        final BiuxUser admin = BiuxUser();
        city = await UserRepository().getSpecifiCities(widget.admin!.cityId!);
        this.setState(
          () {
            if (member.approved != null) {
              joinMe = 1;
            } else {}
            if (admin.id! == useR.id) {
              joinMe = 2;
            } else {
              if (member.approved == null) {
                joinMe = 0;
              } else {}
            }
          },
        );
      },
    );
  }

  Container buildUserPosts() {
    Future<List<StoriesScreen>> getPosts() async {
      List<StoriesScreen> posts = [];
      var snap = await FirebaseFirestore.instance
          .collection(AppStrings.instaPosts)
          .where(
            AppStrings.groupIdText,
            isEqualTo: widget.group!.id.toString(),
          )
          // .orderBy("timestamp")
          .get();
      for (var doc in snap.docs) {
        posts.add(StoriesScreen.fromDocument(doc));
        setState(
          () {
            postCount = snap.docs.length;
            var time = Timestamp.now();
            posts.sort(
              (a, b) => time.compareTo(b.timestamp),
            );
          },
        );
      }

      return posts.toList();
    }

    Future<List<ViewImage>> getPostsImage() async {
      List<ViewImage> dataImage = [];
      var snap = await FirebaseFirestore.instance
          .collection(AppStrings.instaPosts)
          .where(
            AppStrings.groupIdText,
            isEqualTo: widget.group!.id.toString(),
          )
          // .orderBy("timestamp")
          .get();
      for (var doc in snap.docs) {
        dataImage.add(ViewImage.fromDocument(doc));

        setState(() {
          postCount = snap.docs.length;
          var time = Timestamp.now();
          dataImage.sort((a, b) => time.compareTo(b.timestamp));
        });
      }

      return dataImage.toList();
    }

    return Container(
        child: FutureBuilder<List<StoriesScreen>>(
      future: getPosts(),
      builder: (context, AsyncSnapshot<dynamic> snapshot) {
        var dataView;
        dataView = Container(
          child: FutureBuilder<List<ViewImage>>(
            future: getPostsImage(),
            builder: (context, snapshot) {
              if (!snapshot.hasData)
                return Container(
                  alignment: FractionalOffset.center,
                  padding: const EdgeInsets.only(top: 10.0),
                  child: CircularProgressIndicator(),
                );
              return Wrap(
                  children: snapshot.data!.map((ViewImage imagePost) {
                return imagePost;
              }).toList());
            },
          ),
        );

        return dataView;
      },
    ));
  }

  void reassemble() {
    super.reassemble();
    if (joinMe == 1) {
      setState(() {
        widget.onReassemble!();
      });
    }
  }

  var _darkTheme = true;
  @override
  final GlobalKey<ScaffoldState> _scaffolState = GlobalKey<ScaffoldState>();
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    final themeNotifier = Provider.of<ThemeNotifier>(context);
    _darkTheme = (themeNotifier.getTheme() == darkTheme);
    return Scaffold(
      key: _scaffolState,
      backgroundColor: AppColors.transparent,
      body: Stack(
        children: [
          Container(
            margin: EdgeInsets.only(
              top: 10,
            ),
            child: ListView(
              children: <Widget>[
                Container(
                  child: Align(
                    alignment: Alignment.topCenter,
                    child: GestureDetector(
                      child: Material(
                        elevation: 10,
                        borderRadius: BorderRadius.circular(55.0),
                        child: Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.strongCyan,
                          ),
                          height: 55,
                          width: 130,
                          child: joinMe == 2
                              ? ButtonTheme(
                                  minWidth: 50.0,
                                  height: 30.0,
                                  child: RaisedButton(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: new BorderRadius.all(
                                        Radius.circular(40),
                                      ),
                                      side: BorderSide(
                                        width: 3,
                                        color: AppColors.white,
                                      ),
                                    ),
                                    color: AppColors.white,
                                    textColor: AppColors.black,
                                    child: cmbscritta
                                        ? Text(
                                            AppStrings.editGroup,
                                            style: Styles.accentTextThemeBlack,
                                          )
                                        : Text(
                                            AppStrings.editGroup,
                                            style: Styles.accentTextThemeBlack,
                                          ),
                                    onPressed: () async {
                                      Navigator.push(
                                        context,
                                        new MaterialPageRoute(
                                          builder: (BuildContext context) =>
                                              EditGroups(
                                            widget.group!,
                                            widget.admin!,
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                )
                              : joinMe == 1
                                  ? ButtonTheme(
                                      minWidth: 50.0,
                                      height: 30.0,
                                      child: RaisedButton(
                                        shape: RoundedRectangleBorder(
                                          borderRadius: new BorderRadius.all(
                                              Radius.circular(40)),
                                          side: BorderSide(
                                            width: 3,
                                            color: AppColors.strongCyan,
                                          ),
                                        ),
                                        color: AppColors.strongCyan,
                                        textColor: AppColors.white,
                                        child: cmbscritta
                                            ? Text(
                                                AppStrings.outText,
                                                style:
                                                    Styles.accentTextThemeWhite,
                                              )
                                            : Text(AppStrings.outText),
                                        onPressed: () async {
                                          showDialog(
                                            useRootNavigator: true,
                                            useSafeArea: true,
                                            context: context,
                                            builder: (BuildContext context) {
                                              return AlertDialog(
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      new BorderRadius.circular(
                                                          20.0),
                                                  side: BorderSide(
                                                      width: 3,
                                                      color: AppColors
                                                          .greyishNavyBlue),
                                                ),
                                                content: Text(
                                                    AppStrings.wantOutGroup),
                                                actions: <Widget>[
                                                  Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                    children: [
                                                      FlatButton(
                                                        shape:
                                                            RoundedRectangleBorder(
                                                          borderRadius:
                                                              new BorderRadius
                                                                      .circular(
                                                                  20.0),
                                                          side: BorderSide(
                                                              width: 3,
                                                              color: AppColors
                                                                  .greyishNavyBlue),
                                                        ),
                                                        onPressed: () async {
                                                          Navigator.pop(
                                                              context);
                                                        },
                                                        child: Text(
                                                          AppStrings.cancelText,
                                                          style: Styles
                                                              .accentTextThemeBlack,
                                                        ),
                                                      ),
                                                      Container(
                                                        width: 20,
                                                      ),
                                                      FlatButton(
                                                        shape:
                                                            RoundedRectangleBorder(
                                                          borderRadius:
                                                              new BorderRadius
                                                                      .circular(
                                                                  20.0),
                                                          side: BorderSide(
                                                              width: 3,
                                                              color: AppColors
                                                                  .greyishNavyBlue),
                                                        ),
                                                        onPressed: () async {
                                                          Navigator.of(context)
                                                              .pushAndRemoveUntil(
                                                                  MaterialPageRoute(
                                                                    builder:
                                                                        (context) =>
                                                                            MyHome(),
                                                                  ),
                                                                  (Route<dynamic>
                                                                          route) =>
                                                                      false)
                                                              .then(
                                                                (value) =>
                                                                    setState(
                                                                  () => {},
                                                                ),
                                                              );
                                                          // Navigator.pop(context);
                                                          // Navigator.pop(context);
                                                          setState(
                                                            () {
                                                              widget.group!
                                                                      .numberMembers -
                                                                  1;
                                                              joinMe = 0;
                                                            },
                                                          );
                                                          await MembersRepository()
                                                              .deleteMember(
                                                            member,
                                                          );
                                                        },
                                                        child: Text(
                                                            AppStrings.outText),
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              );
                                            },
                                          );
                                        },
                                      ),
                                    )
                                  : joinMe == 0
                                      ? ButtonTheme(
                                          minWidth: 50.0,
                                          height: 30.0,
                                          child: RaisedButton(
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  new BorderRadius.all(
                                                Radius.circular(40),
                                              ),
                                              side: BorderSide(
                                                width: 1,
                                                color: AppColors.strongCyan,
                                              ),
                                            ),
                                            color: AppColors.strongCyan,
                                            textColor: AppColors.white,
                                            child: cmbscritta
                                                ? Text(
                                                    AppStrings.joined,
                                                    style: Styles
                                                        .accentTextThemeWhite,
                                                  )
                                                : Text(
                                                    AppStrings.joinMe,
                                                    style: Styles
                                                        .accentTextThemeWhite,
                                                  ),
                                            onPressed: () async {
                                              showDialog(
                                                useRootNavigator: true,
                                                useSafeArea: true,
                                                context: context,
                                                builder:
                                                    (BuildContext context) {
                                                  return AlertDialog(
                                                    shape:
                                                        RoundedRectangleBorder(
                                                      borderRadius:
                                                          new BorderRadius
                                                              .circular(20.0),
                                                      side: BorderSide(
                                                          width: 3,
                                                          color: AppColors
                                                              .greyishNavyBlue),
                                                    ),
                                                    content: Text(AppStrings
                                                        .wantJoinGroup),
                                                    actions: <Widget>[
                                                      Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .center,
                                                        children: [
                                                          FlatButton(
                                                            shape:
                                                                RoundedRectangleBorder(
                                                              borderRadius:
                                                                  new BorderRadius
                                                                      .circular(
                                                                20.0,
                                                              ),
                                                              side: BorderSide(
                                                                  width: 3,
                                                                  color: AppColors
                                                                      .greyishNavyBlue),
                                                            ),
                                                            onPressed:
                                                                () async {
                                                              Navigator.pop(
                                                                  context);
                                                            },
                                                            child: Text(
                                                              AppStrings
                                                                  .cancelText,
                                                              style: Styles
                                                                  .accentTextThemeBlack,
                                                            ),
                                                          ),
                                                          Container(
                                                            width: 20,
                                                          ),
                                                          FlatButton(
                                                            shape:
                                                                RoundedRectangleBorder(
                                                              borderRadius:
                                                                  new BorderRadius
                                                                      .circular(
                                                                20.0,
                                                              ),
                                                              side: BorderSide(
                                                                  width: 3,
                                                                  color: AppColors
                                                                      .greyishNavyBlue),
                                                            ),
                                                            onPressed:
                                                                () async {
                                                              await MembersRepository()
                                                                  .joinGroups(
                                                                userId,
                                                                widget
                                                                    .group!.id,
                                                              );
                                                              Navigator.of(
                                                                      context)
                                                                  .pushAndRemoveUntil(
                                                                      MaterialPageRoute(
                                                                        builder:
                                                                            (context) =>
                                                                                MyHome(),
                                                                      ),
                                                                      (Route<dynamic>
                                                                              route) =>
                                                                          false)
                                                                  .then(
                                                                    (value) =>
                                                                        setState(() =>
                                                                            {}),
                                                                  );
                                                              setState(
                                                                () {
                                                                  joinMe = 1;
                                                                  widget.group!
                                                                          .numberMembers +
                                                                      1;
                                                                },
                                                              );
                                                            },
                                                            child: Text(
                                                              AppStrings.joinMe,
                                                              style: Styles
                                                                  .accentTextThemeBlack,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ],
                                                  );
                                                },
                                              );
                                            },
                                          ),
                                        )
                                      : Container(),
                        ),
                      ),
                      onTap: () {
                        setState(() {});
                      },
                    ),
                  ),
                ),
                Container(
                  height: 10,
                ),
                Container(
                  padding: new EdgeInsets.only(
                    left: 10,
                    right: 10,
                  ),
                  child: Text(
                    widget.group!.description,
                    style: Styles.containerDescription,
                  ),
                ),
                Container(
                  height: 10,
                ),
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.only(left: 10),
                      child: Text(
                        AppStrings.leader,
                        style: Styles.containerGray,
                      ),
                    ),
                    GestureDetector(
                      child: Container(
                        padding: EdgeInsets.only(left: 0),
                        child: Text(
                          widget.admin!.names! == null
                              ? AppStrings.loandingText
                              : widget.admin!.names! +
                                  " " +
                                  widget.admin!.surnames!,
                          style: Styles.advertisingTitle.copyWith(
                            fontSize: size.height * 0.025,
                          ),
                        ),
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          new MaterialPageRoute(
                            builder: (BuildContext context) => DetailUsers(
                              widget.admin!,
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
                Container(
                  height: 30,
                ),
                buildUserPosts(),
                Container(
                  height: 10,
                )
              ],
            ),
          ),
          loading == true ? Loading() : Container(),
        ],
      ),
    );
  }

  void _showDialog2(String response) {
    // flutter defined function
    Future.delayed(
      Duration.zero,
      () {
        _scaffolState.currentState!.showSnackBar(
          SnackBar(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(40),
                topRight: Radius.circular(40),
              ),
            ),
            backgroundColor: AppColors.strongCyan,
            content: Text(
              response,
              style: Styles.advertisingTitle,
            ),
          ),
        );
      },
    );
  }
}

class DetailScreen4 extends StatefulWidget {
  final Group group;
  DetailScreen4(this.group);

  @override
  _DetailScreen4State createState() => _DetailScreen4State();
}

class _DetailScreen4State extends State<DetailScreen4> {
  initState() {
    SystemChrome.setEnabledSystemUIOverlays([]);
    super.initState();
  }

  @override
  void dispose() {
    //SystemChrome.restoreSystemUIOverlays();
    SystemChrome.setEnabledSystemUIOverlays(SystemUiOverlay.values);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double _scale = 1.0;
    double _previousScale = 1.0;
    int x = 2;
    int y = 0;
    Group _group;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.greyishNavyBlue,
        title: Text(AppStrings.coverGroup),
      ),
      body: ListView(
        children: [
          Center(
            child: GestureDetector(
              onScaleStart: (ScaleStartDetails details) {
                _previousScale = _scale;
                setState(() {});
              },
              onScaleUpdate: (ScaleUpdateDetails details) {
                _scale = _previousScale * details.scale;
                setState(() {});
              },
              onScaleEnd: (ScaleEndDetails details) {
                _previousScale = 1.0;
                setState(() {});
              },
              child: RotatedBox(
                quarterTurns: 0,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Transform(
                    alignment: FractionalOffset.center,
                    transform: Matrix4.diagonal3(
                      Vector3(_scale, _scale, _scale),
                    ),
                    child: Image(
                      image: NetworkImage(
                        widget.group.profileCover == null
                            ? AppStrings.urlDetailGroup
                            : widget.group.profileCover,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class DetailScreen3 extends StatefulWidget {
  final Group _group;
  DetailScreen3(this._group);

  @override
  _DetailScreen3State createState() => _DetailScreen3State();
}

class _DetailScreen3State extends State<DetailScreen3> {
  initState() {
    SystemChrome.setEnabledSystemUIOverlays([]);
    super.initState();
  }

  @override
  void dispose() {
    //SystemChrome.restoreSystemUIOverlays();
    SystemChrome.setEnabledSystemUIOverlays(SystemUiOverlay.values);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double _scale = 1.0;
    double _previousScale = 1.0;
    int x = 2;
    int y = 0;
    Group _group;
    return Scaffold(
      appBar: AppBar(
        title: Text(AppStrings.coverGroup),
      ),
      body: Center(
        child: GestureDetector(
          onScaleStart: (ScaleStartDetails details) {
            _previousScale = _scale;
            setState(() {});
          },
          onScaleUpdate: (ScaleUpdateDetails details) {
            _scale = _previousScale * details.scale;
            setState(() {});
          },
          onScaleEnd: (ScaleEndDetails details) {
            _previousScale = 1.0;
            setState(() {});
          },
          child: RotatedBox(
            quarterTurns: 0,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Transform(
                alignment: FractionalOffset.center,
                transform: Matrix4.diagonal3(Vector3(_scale, _scale, _scale)),
                child: Hero(
                  tag: AppStrings.coverImage,
                  child: PhotoView(
                    imageProvider: NetworkImage(
                      widget._group.logo == null
                          ? AppStrings.urlDetailGroup
                          : widget._group.profileCover,
                    ),
                    minScale: PhotoViewComputedScale.contained * 1.0,
                    maxScale: PhotoViewComputedScale.covered * 10,
                    backgroundDecoration: BoxDecoration(
                      color: AppColors.greyishNavyBlue2,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class DetailScreen5 extends StatefulWidget {
  final Group _group;
  DetailScreen5(this._group);

  @override
  _DetailScreen5State createState() => _DetailScreen5State();
}

class _DetailScreen5State extends State<DetailScreen5> {
  initState() {
    SystemChrome.setEnabledSystemUIOverlays([]);
    super.initState();
  }

  @override
  void dispose() {
    //SystemChrome.restoreSystemUIOverlays();
    SystemChrome.setEnabledSystemUIOverlays(SystemUiOverlay.values);
    super.dispose();
  }

  Widget build(BuildContext context) {
    return Scaffold(
      body: GestureDetector(
        child: Center(
          child: Hero(
            tag: AppStrings.zoomImagen,
            child: Container(
              child: Image(
                image: NetworkImage(
                  widget._group.logo == null
                      ? AppStrings.urlBiuxApp
                      : widget._group.logo,
                ),
              ),
            ),
          ),
        ),
        onTap: () {
          Navigator.pop(context);
        },
      ),
    );
  }
}
