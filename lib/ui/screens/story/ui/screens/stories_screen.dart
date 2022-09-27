import 'package:biux/config/colors.dart';
import 'package:biux/config/images.dart';
import 'package:biux/config/styles.dart';
import 'package:biux/config/strings.dart';
import 'package:biux/data/models/member.dart';
import 'package:biux/data/models/user.dart';
import 'package:biux/data/models/analitics.dart';
import 'package:biux/data/repositories/groups/groups_repository.dart';
import 'package:biux/data/repositories/members/members_repository.dart';
import 'package:biux/data/repositories/users/user_repository.dart';
import 'package:biux/data/local_storage/localstorage.dart';
import 'package:biux/ui/screens/group/ui/screens/group_slider/group_slider.dart';
import 'package:biux/ui/screens/user/profile_screen.dart';
import 'package:biux/ui/screens/zoom_screen/zoom_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:pinch_zoom/pinch_zoom.dart';
import 'package:readmore/readmore.dart';
import 'dart:async';
import 'comment_screen.dart';

class StoriesScreen extends StatefulWidget {
  const StoriesScreen({
    required this.photo,
    required this.user,
    required this.location,
    required this.description,
    this.likes,
    required this.postId,
    required this.ownerId,
    required this.timestamp,
    this.name,
  });

  factory StoriesScreen.fromDocument(DocumentSnapshot document) {
    return StoriesScreen(
      user: document[AppStrings.user],
      timestamp: document[AppStrings.timestamp],
      location: document[AppStrings.locationText],
      photo: document[AppStrings.photoText],
      likes: document[AppStrings.likes],
      description: document[AppStrings.description2],
      postId: document.id,
      ownerId: document[AppStrings.ownerIdText],
      name: document[AppStrings.name],
    );
  }

  factory StoriesScreen.fromJSON(Map data) {
    return StoriesScreen(
      user: data[AppStrings.user],
      location: data[AppStrings.locationText],
      timestamp: data[AppStrings.timestamp],
      photo: data[AppStrings.photoText],
      likes: data[AppStrings.likes],
      description: data[AppStrings.description2],
      ownerId: data[AppStrings.ownerIdText],
      postId: data[AppStrings.postId],
      name: data[AppStrings.name],
    );
  }
  int getLikeCount(var likes) {
    if (likes == null) {
      return 0;
    }
// issue is below
    var vals = likes.values;
    int count = 0;
    for (var val in vals) {
      if (val == true) {
        count = count + 1;
      }
    }

    return count;
  }

  final String photo;
  final String user;
  final String location;
  final String description;
  final likes;
  final Timestamp timestamp;
  final String postId;
  final String ownerId;
  final String? name;

  _StoriesScreen createState() => _StoriesScreen(
        photo: this.photo,
        user: this.user,
        location: this.location,
        description: this.description,
        likes: this.likes,
        likeCount: getLikeCount(this.likes),
        ownerId: this.ownerId,
        postId: this.postId,
        timestamp: this.timestamp,
        name: this.name,
      );
}

class _StoriesScreen extends State<StoriesScreen> {
  final String? photo;
  final String? user;
  final String? location;
  final Timestamp? timestamp;
  final String? description;
  late bool refresh;
  Map? likes;
  int? likeCount;
  final String? postId;
  bool liked = false;
  final String? ownerId;
  final String? name;
  bool showHeart = false;
  TextStyle boldStyle = Styles.sizedBox;
  var reference = FirebaseFirestore.instance.collection(AppStrings.instaPosts);
  _StoriesScreen({
    required this.photo,
    required this.timestamp,
    required this.user,
    required this.location,
    required this.description,
    required this.likes,
    required this.postId,
    required this.likeCount,
    required this.ownerId,
    required this.name,
  });
  BiuxUser? user1;
  BiuxUser? user2;
  String formattedDate2 = "";
  String formattedDate = "";
  late int formatted = 0;
  late int formatted2 = 0;
  var date2 = DateTime.now();
  int postCount = 0;
  late Member member;
  String idValidate = '';
  late String analiticImage;

  @override
  void initState() {
    super.initState();

    getUserProfile();
    member = Member();
    setState(() {});
  }

  Future<List<StoriesScreen>> getPosts() async {
    List<StoriesScreen> posts = [];
    var snap = await FirebaseFirestore.instance
        .collection(AppStrings.instaPosts)
        // .where('ownerId', isEqualTo: profileId)
        .orderBy(AppStrings.timestamp, descending: true)
        .get();
    for (var doc in snap.docs) {
      posts.add(StoriesScreen.fromDocument(doc));
    }
    setState(() {
      postCount = snap.docs.length;
    });
    return posts.toList();
  }

  getUserProfile() {
    Future.delayed(
      Duration.zero,
      () async {
        var username = (await LocalStorage().getUser())!;
        user1 = await UserRepository().getPerson(username);
        final nMember = await MembersRepository().getMyGroupsUser(
          user1!.id,
        );
        setState(
          () {
            member = nMember;
          },
        );
      },
    );
  }

  GestureDetector buildLikeIcon({
    String? postId,
    Map? likes,
    String? ownerId,
    String? photoStory,
    String? name,
  }) {
    Color color;
    IconData icon;
    if (likes![user1!.id.toString()] == true) {
      color = AppColors.greyishNavyBlue2;
      icon = FontAwesomeIcons.bicycle;
    } else {
      icon = FontAwesomeIcons.bicycle;
      color = AppColors.white;
    }
    return GestureDetector(
      child: Icon(
        icon,
        size: 25.0,
        color: color,
      ),
      onTap: () {
        _likePost(
          postId!,
          user1!.id.toString(),
          likes,
          ownerId!,
          photoStory!,
          name!,
        );
      },
    );
  }

  bool showDot = false;
  buildLikeableImage(
    String image,
    String postId,
    String ownerId,
    Map likes,
    String name,
  ) =>
      Stack(
        children: <Widget>[
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) {
                    return ZoomPage2(image);
                  },
                ),
              );
            },
            onDoubleTap: () => _likePost(
              postId,
              user1!.id.toString(),
              likes,
              ownerId,
              image,
              name,
            ),
            child: Container(
              height: 350,
              width: double.infinity,
              child: PinchZoom(
                zoomEnabled: true,
                child: Image.network(image, fit: BoxFit.cover),
                resetDuration: const Duration(milliseconds: 100),
                maxScale: 350,
                onZoomStart: () {},
                onZoomEnd: () {},
              ),
            ),
          ),
          showHeart == true && idValidate == postId
              ? Container(
                  width: double.infinity,
                  height: 350,
                  color: AppColors.black.withOpacity(0.4),
                  child: Opacity(
                    opacity: 0.85,
                    child: Image.asset(
                      Images.kGifLikes,
                      width: 350,
                      height: double.infinity,
                    ),
                  ),
                )
              : Container()
        ],
      );
  bool? heightBounds = false;
  buildPostHeader({
    String? ownerId,
    String? location,
    String? docId,
    String? user,
  }) {
    if (ownerId == null) {
      return Text(AppStrings.ownerError);
    }
    return FutureBuilder(
      future: FirebaseFirestore.instance
          .collection(AppStrings.instaUsers)
          .doc(ownerId)
          .get(),
      builder: (context, AsyncSnapshot<dynamic> snapshot) {
        Size size = MediaQuery.of(context).size;
        if (snapshot.data != null) {
          final data = snapshot.requireData;
          return Stack(
            children: [
              Container(
                decoration: BoxDecoration(
                  color: AppColors.strongCyan,
                  borderRadius: new BorderRadius.only(
                    topRight: Radius.circular(40.0),
                  ),
                ),
                padding: EdgeInsets.only(
                  left: 0,
                  bottom: 3,
                  top: 3,
                ),
                child: Column(
                  children: [
                    GestureDetector(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Container(
                            child: Text(
                              snapshot.data.data()[AppStrings.email],
                              style: Styles.snapshotEmail,
                            ),
                          ),
                          Container(
                            width: 5,
                          ),
                          Container(
                            child: Text(
                              snapshot.data.data()[AppStrings.lastName] == null
                                  ? ''
                                  : '${snapshot.data.data()[AppStrings.lastName]}'
                                              .length <
                                          8
                                      ? '${snapshot.data.data()[AppStrings.lastName]}'
                                      : '${snapshot.data.data()[AppStrings.lastName]}'
                                          .replaceRange(
                                          8,
                                          snapshot.data
                                              .data()[AppStrings.lastName]
                                              .toString()
                                              .length,
                                          '...',
                                        ),
                              style: Styles.snapshotEmail,
                            ),
                          ),
                        ],
                      ),
                      onTap: () async {
                        user2 = await UserRepository().getPerson(
                            snapshot.data.data()[AppStrings.nameVal]);
                        if (user2!.userName ==
                            snapshot.data.data()[AppStrings.user]) {
                          Navigator.push(
                            context,
                            new MaterialPageRoute(
                              builder: (BuildContext context) => ProfileScreen(
                                currentUserId: ownerId.replaceAll(
                                  'U',
                                  '',
                                ),
                                photo: user1!.photo,
                                user: user1,
                                username: user1!.userName,
                                profileCover: user1!.profileCover,
                              ),
                            ),
                          );
                        } else {
                          String groupId = ownerId.replaceAll('G', '');
                          var _group = await GroupsRepository()
                              .getSpecificGroup(groupId);
                          Navigator.push(
                            context,
                            new MaterialPageRoute(
                              builder: (BuildContext context) =>
                                  GroupSlider(_group),
                            ),
                          );
                        }
                      },
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Container(
                          child: Text(
                            location!,
                            style: Styles.accentTextThemeWhite,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Positioned(
                bottom: 2,
                left: -76,
                right: 0,
                top: -25,
                child: GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (BuildContext context) => ProfileScreen(
                          currentUserId: ownerId,
                          photo: user1!.photo,
                          user: user1,
                          username: user1!.userName,
                        ),
                      ),
                    );
                  },
                  child: Container(
                    child: Align(
                      alignment: Alignment.bottomLeft,
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(60.0),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.white,
                              spreadRadius: 2,
                            )
                          ],
                        ),
                        child: Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.strongCyan,
                          ),
                          height: 65,
                          width: 65,
                          child: new Container(
                            alignment: (Alignment(
                              -0.2,
                              2.2,
                            )),
                            decoration: BoxDecoration(
                              image: DecorationImage(
                                fit: BoxFit.cover,
                                image: NetworkImage(
                                  snapshot.data.data()[AppStrings.photoText] ==
                                          null
                                      ? AppStrings.urlBiuxApp
                                      : snapshot.data
                                          .data()[AppStrings.photoText],
                                ),
                              ),
                              borderRadius: new BorderRadius.all(
                                const Radius.circular(
                                  80.0,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              ownerId.replaceAll('U', '') == user1!.id.toString() ||
                      ownerId.replaceAll('G', '') == user1!.groupId
                  ? GestureDetector(
                      onTap: () async {
                        complete(
                          context,
                          docId,
                          snapshot.data.data()[AppStrings.userText],
                        );
                        // FirebaseFirestore.instance
                        //     .collection('insta_posts')
                        //     .doc(docId)
                        //     .delete();
                      },
                      child: Container(
                        margin: EdgeInsets.only(
                          left: size.width * 0.55,
                          top: 10,
                        ),
                        child: Icon(
                          Icons.delete,
                          color: AppColors.white,
                        ),
                      ),
                    )
                  : Container()
            ],
          );
        }
        return Container();
      },
    );
  }

  Container loadingPlaceHolder = Container(
    height: 400.0,
    child: Center(child: CircularProgressIndicator()),
  );
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    // liked = (likes!["104382669430049736924"] == true);
    return RefreshIndicator(
      onRefresh: _pullRefresh,
      child: SafeArea(
        child: Container(
          color: AppColors.greyishNavyBlue,
          child: Container(
            child: FutureBuilder<List<StoriesScreen>>(
              future: getPosts(),
              // ignore: missing_return
              builder: (context, snapshot) {
                if (!snapshot.hasData)
                  return Container(
                    alignment: FractionalOffset.center,
                    padding: const EdgeInsets.only(
                      top: 10.0,
                    ),
                    child: CircularProgressIndicator(),
                  );
                return ListView.builder(
                  itemCount: snapshot.data!.length,
                  itemBuilder: (context, index) {
                    var storie = snapshot.data![index];
                    // Hours
                    DateTime dt = (storie.timestamp).toDate();
                    formatted = date2.difference(dt).inHours;
                    formatted2 = date2.difference(dt).inDays;
                    var vals = storie.likes.values;
                    analiticImage = storie.photo;
                    int count = 0;
                    for (var val in vals) {
                      if (val == true) {
                        count = count + 1;
                      }
                    }
                    return Column(
                      children: [
                        Stack(
                          children: <Widget>[
                            Column(
                              children: <Widget>[
                                Container(
                                  margin: EdgeInsets.only(left: 0),
                                  // height: heightBounds == true
                                  //     ? MediaQuery.of(context).size.height / 1.3
                                  //     : MediaQuery.of(context).size.height / 1.5,
                                  width:
                                      MediaQuery.of(context).size.width / 1.15,
                                  child: Stack(
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.only(
                                          top: 30,
                                          bottom: 10,
                                        ),
                                        child: Card(
                                          elevation: 2,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              40.0,
                                            ),
                                          ),
                                          child: Stack(
                                            children: [
                                              Column(
                                                children: [
                                                  Container(
                                                    // height: 60,
                                                    decoration: BoxDecoration(
                                                      color:
                                                          AppColors.strongCyan,
                                                      borderRadius:
                                                          BorderRadius.only(
                                                        topLeft:
                                                            Radius.circular(
                                                          40.0,
                                                        ),
                                                        topRight:
                                                            Radius.circular(
                                                          40.0,
                                                        ),
                                                      ),
                                                    ),
                                                    padding: EdgeInsets.only(
                                                      left: 60,
                                                    ),
                                                    //  color: AppColors.strongCyan,
                                                    child: buildPostHeader(
                                                      ownerId: storie.ownerId,
                                                      location: storie.location,
                                                      docId: storie.postId,
                                                      user: storie.user,
                                                    ),
                                                  ),
                                                  buildLikeableImage(
                                                    storie.photo,
                                                    storie.postId,
                                                    storie.ownerId,
                                                    storie.likes,
                                                    storie.name!,
                                                  ),
                                                  Container(
                                                    height: 5,
                                                  ),
                                                  Row(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: <Widget>[
                                                      GestureDetector(
                                                        onTap: () async {
                                                          // user2 = await UsuariosRepositorio()
                                                          //     .obtenerPersona(s);
                                                          // if (user2!
                                                          //         .usuario ==
                                                          //     storie
                                                          //         .usuario) {
                                                          //   Navigator.push(
                                                          //     context,
                                                          //     new MaterialPageRoute(
                                                          //       builder: (BuildContext context) => ProfilePage(
                                                          //           currentUserId:
                                                          //               int.parse(storie
                                                          //                   .ownerId),
                                                          //           foto: user!
                                                          //               .foto,
                                                          //           user:
                                                          //               user,
                                                          //           username:
                                                          //               user!
                                                          //                   .usuario!,
                                                          //           portada: user!
                                                          //               .portada),
                                                          //     ),
                                                          //   );
                                                          // } else {
                                                          //   int idgrupo = int
                                                          //       .parse(storie
                                                          //           .ownerId);
                                                          //   var _grupo =
                                                          //       await GruposRepositorio()
                                                          //           .obtenerGrupoEspecifico(
                                                          //               idgrupo);
                                                          //   Navigator.push(
                                                          //     context,
                                                          //     new MaterialPageRoute(
                                                          //         builder: (BuildContext
                                                          //                 context) =>
                                                          //             GrupoSlider(
                                                          //                 _grupo)),
                                                          //   );
                                                          // }
                                                        },
                                                        child: Container(
                                                          margin:
                                                              const EdgeInsets
                                                                  .only(
                                                            left: 20.0,
                                                          ),
                                                          child: Text(
                                                            storie.name!,
                                                            style: boldStyle,
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  Column(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment.start,
                                                    children: [
                                                      GestureDetector(
                                                        child: Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .only(
                                                            left: 18.0,
                                                            right: 18.0,
                                                          ),
                                                          child: Container(
                                                            alignment: Alignment
                                                                .centerLeft,
                                                            child: ReadMoreText(
                                                              storie
                                                                  .description,
                                                              trimLines: 2,
                                                              trimMode:
                                                                  TrimMode.Line,
                                                              trimCollapsedText:
                                                                  AppStrings
                                                                      .seeMore,
                                                              trimExpandedText:
                                                                  AppStrings
                                                                      .seeLess,
                                                              trimLength: 20,
                                                              moreStyle: Styles
                                                                  .moreStyle,
                                                              lessStyle: Styles
                                                                  .moreStyle,
                                                              style: Styles
                                                                  .accentTextThemeBlack,
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                      Container(
                                                        height: 5,
                                                      ),
                                                      Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .only(
                                                          left: 16.0,
                                                        ),
                                                        child: Container(
                                                          alignment: Alignment
                                                              .centerLeft,
                                                          child: Text(
                                                            " Hace ${formatted >= 24 ? formatted2 : formatted} ${formatted2 >= 2 ? "dias" : formatted2 >= 1 ? "dia" : "horas"}",
                                                            style: Styles
                                                                .paddingGray,
                                                          ),
                                                        ),
                                                      ),
                                                      Container(
                                                        height: 15,
                                                      ),
                                                    ],
                                                  ),
                                                  Container(
                                                    //  alignment: Alignment.centerLeft,
                                                    height:
                                                        MediaQuery.of(context)
                                                                .size
                                                                .height /
                                                            120,
                                                    // width: MediaQuery.of(context).size.width * 0.0002,
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  width: 10,
                                ),
                              ],
                            ),
                            Positioned(
                              bottom: 0,
                              left: size.width * 0.50,
                              right: 0,
                              top: 380,
                              child: Align(
                                alignment: Alignment.topLeft,
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
                                      width: 230,
                                      child: InkWell(
                                        child: Container(
                                          width: 205,
                                          alignment: (Alignment(
                                            -0.2,
                                            2.2,
                                          )),
                                          decoration: BoxDecoration(
                                            color: AppColors.strongCyan,
                                            borderRadius: new BorderRadius.only(
                                              bottomLeft: Radius.circular(
                                                40.0,
                                              ),
                                              topLeft: Radius.circular(
                                                40.0,
                                              ),
                                            ),
                                          ),
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  buildLikeIcon(
                                                    postId: storie.postId,
                                                    likes: storie.likes,
                                                    ownerId: storie.ownerId,
                                                    photoStory: storie.photo,
                                                    name: storie.name,
                                                  ),
                                                  Container(
                                                    width: 22,
                                                  ),
                                                  GestureDetector(
                                                    child: Stack(
                                                      children: [
                                                        const Icon(
                                                          FontAwesomeIcons
                                                              .comment,
                                                          color:
                                                              AppColors.white,
                                                          size: 25.0,
                                                        ),
                                                        showDot == false
                                                            ? Positioned(
                                                                right: -1.5,
                                                                top: 0,
                                                                child:
                                                                    Container(
                                                                  width: 12,
                                                                  height: 12,
                                                                  decoration:
                                                                      BoxDecoration(
                                                                    color:
                                                                        AppColors
                                                                            .red,
                                                                    borderRadius:
                                                                        BorderRadius
                                                                            .circular(8),
                                                                  ),
                                                                  child: Icon(
                                                                    FontAwesomeIcons
                                                                        .bell,
                                                                    color: AppColors
                                                                        .white,
                                                                    size: 8.0,
                                                                  ),
                                                                ),
                                                              )
                                                            : SizedBox()
                                                      ],
                                                    ),
                                                    onTap: () {
                                                      setState(
                                                        () {
                                                          showDot == true;
                                                        },
                                                      );
                                                      goToComments(
                                                        context: context,
                                                        postId: storie.postId,
                                                        ownerId: storie.ownerId,
                                                        mediaUrl: storie.photo,
                                                        user: user1,
                                                      );
                                                    },
                                                  ),
                                                ],
                                              ),
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  Container(
                                                    child: Text(
                                                      '${count}',
                                                      style: Styles.sendText,
                                                    ),
                                                  ),
                                                  Container(
                                                    child: Text(
                                                      AppStrings.APP_NAME,
                                                      style: Styles
                                                          .advertisingTitle,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                        onTap: () {
                                          setState(() {});
                                        },
                                      ),
                                    ),
                                  ),
                                  onTap: () {
                                    setState(() {});
                                  },
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    );
                  },
                );
                // (
                //     children: snapshot.data!.map((StoriesScreen imagePost) {
                //   return imagePost;
                // }).toList());
              },
            ),
          ),
        ),
      ),
    );
  }

  void complete(
    BuildContext context,
    String? docId,
    String? name,
  ) {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog
        return WillPopScope(
          onWillPop: () async => false,
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: Container(
              child: AlertDialog(
                backgroundColor: AppColors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20.0),
                  side: BorderSide(
                    width: 3,
                    color: AppColors.greyishNavyBlue,
                  ),
                ),
                content: Text(
                  AppStrings
                      .deleteStorie, //tituloactual == 0 ? titulo1 : titulo2,
                  textAlign: TextAlign.center,
                  style: Styles.showDialogTitleBlack,
                ),
                actions: <Widget>[
                  // usually buttons at the bottom of the dialog
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      new FlatButton(
                        minWidth: 100,
                        shape: RoundedRectangleBorder(
                          borderRadius: new BorderRadius.circular(20.0),
                          side: BorderSide(
                            width: 3,
                            color: AppColors.greyishNavyBlue,
                          ),
                        ),
                        child: Text(
                          AppStrings.no,
                          style: Styles.flatButton,
                        ),
                        onPressed: () {
                          Navigator.pop(context);
                        },
                      ),
                      Container(
                        width: 20,
                      ),
                      FlatButton(
                        minWidth: 100,
                        shape: RoundedRectangleBorder(
                          borderRadius: new BorderRadius.circular(20.0),
                          side: BorderSide(
                            width: 3,
                            color: AppColors.greyishNavyBlue,
                          ),
                        ),
                        child: Text(
                          AppStrings.si,
                          style: Styles.flatButton,
                        ),
                        onPressed: () {
                          Analitycs.deleteStory(
                            user1!.userName,
                            user1!.id,
                            analiticImage,
                            name!,
                          );
                          FirebaseFirestore.instance
                              .collection(AppStrings.instaPosts)
                              .doc(docId)
                              .delete();
                          Navigator.pop(context);
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _likePost(
    String postId,
    String id,
    Map likes,
    String ownerId,
    String photo,
    String name,
  ) {
    var userId = id;
    idValidate = postId;
    bool _liked = likes[userId] == true;

    if (_liked) {
      Analitycs.likeStory(
        user1!.userName,
        user1!.id,
        photo,
        name,
      );
      reference.doc(postId).update(
        {
          AppStrings.likeUser(userId: userId): false
          //firestore plugin doesnt support deleting, so it must be nulled / falsed
        },
      );
      setState(
        () {
          liked = false;
          likes[userId] = false;
        },
      );
      removeActivityFeedItem();
    }
    if (!_liked) {
      reference.doc(postId).update(
        {
          AppStrings.likeUser(userId: userId): true,
        },
      );
      FirebaseFirestore.instance
          .collection(AppStrings.instaFeed)
          .doc(ownerId)
          .collection(AppStrings.items)
          .doc(postId)
          .set(
        {
          AppStrings.userNameText: user1!.userName,
          AppStrings.userIdText: user1!.id.toString(),
          AppStrings.typeText: AppStrings.like,
          AppStrings.userProfileImgText: user1!.photo,
          AppStrings.photoText: photo,
          AppStrings.timestamp: DateTime.now(),
          AppStrings.postId: postId,
        },
      );
      setState(
        () {
          liked = true;
          likes[userId] = true;
          showHeart = true;
        },
      );
      Timer(
        Duration(milliseconds: 2000),
        () {
          showHeart = false;
        },
      );
    }
  }

  void removeActivityFeedItem() {
    FirebaseFirestore.instance
        .collection(AppStrings.instaFeed)
        .doc(AppStrings.idDoc)
        .collection(AppStrings.items)
        .doc(postId)
        .delete();
  }

  Future<void> _pullRefresh() async {
    await Future.delayed(Duration(seconds: 1));
    reference = FirebaseFirestore.instance.collection(AppStrings.instaPosts);
    getPosts();
    setState(() {});
  }
}

void goToComments({
  context,
  required String postId,
  String? ownerId,
  String? mediaUrl,
  BiuxUser? user,
}) {
  Navigator.of(context).push(
    MaterialPageRoute<bool>(
      builder: (BuildContext context) {
        return CommentScreen(
          postId: postId,
          postOwner: ownerId!,
          postMediaUrl: mediaUrl!,
          user: user!,
        );
      },
    ),
  );
}
