import 'dart:io';
import 'package:biux/config/colors.dart';
import 'package:biux/config/styles.dart';
import 'package:biux/config/strings.dart';
import 'package:biux/data/models/user.dart';
import 'package:biux/data/shared_preferences/localstorage.dart';
import 'package:biux/ui/screens/story/ui/screens/stories_screen.dart';
import 'package:biux/ui/screens/zoom_screen/zoom_screen.dart';
import 'package:biux/ui/widgets/view_image_widget.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async';
import 'package:flutter/scheduler.dart';
import 'package:share/share.dart';
import 'edit_profile.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({
    this.user,
    this.currentUserId,
    this.photo,
    this.username,
    this.profileCover,
  });

  final BiuxUser? user;
  final String? currentUserId;
  final String? photo;
  final String? username;
  final String? profileCover;

  _ProfileScreen createState() => _ProfileScreen(
        this.user,
        this.currentUserId,
        this.username,
        this.photo,
        this.profileCover,
      );
}

class _ProfileScreen extends State<ProfileScreen>
    with AutomaticKeepAliveClientMixin<ProfileScreen> {
  final BiuxUser? user;
  final String? currentUserId;
  final String? photo;
  final String? username;
  final String? profileCover;
  String view = AppStrings.grid;
  bool isFollowing = false;
  bool followButtonClicked = false;
  int postCount = 0;
  int followerCount = 0;
  int followingCount = 0;
  _ProfileScreen(
    this.user,
    this.currentUserId,
    this.username,
    this.photo,
    this.profileCover,
  );

  @override
  void initState() {
    super.initState();
    getUserProfile();
  }

  getUserProfile() {
    Future.delayed(Duration.zero, () async {
      var username = (await LocalStorage().getUser())!;
      // final ref = FirebaseFirestore.instance.collection('insta_users');
    });
  }

  followUser() {
    setState(() {
      this.isFollowing = true;
      followButtonClicked = true;
    });

    FirebaseFirestore.instance
        .doc(AppStrings.instaUserFirebase(id: currentUserId.toString()))
        .update(
      {AppStrings.followersFirebase(id: widget.user!.id.toString()): true},
    );

    FirebaseFirestore.instance
        .doc(AppStrings.instaUserFirebase(id: widget.user!.id.toString()))
        .update(
      {AppStrings.followingFirebase(id: currentUserId.toString()): true},
    );

    FirebaseFirestore.instance
        .collection(AppStrings.instaFeed)
        .doc(currentUserId.toString())
        .collection(AppStrings.items)
        .doc(currentUserId.toString())
        .set(
      {
        AppStrings.ownerIdText: currentUserId.toString(),
        AppStrings.userNameText: username,
        AppStrings.userIdText: currentUserId.toString(),
        AppStrings.typeText: AppStrings.followText,
        AppStrings.userProfileImgText: photo,
        AppStrings.timestamp: DateTime.now()
      },
    );
  }

  unfollowUser() {
    setState(() {
      isFollowing = false;
      followButtonClicked = true;
    });

    FirebaseFirestore.instance
        .doc(AppStrings.instaUserFirebase(id: currentUserId.toString()))
        .update(
      {
       AppStrings.followersFirebase(id: widget.user!.id.toString()): false,
      },
    );

    FirebaseFirestore.instance
        .doc(AppStrings.instaUserFirebase(id: widget.user!.id.toString()))
        .update(
      {
       AppStrings.followingFirebase(id: currentUserId.toString()): false,
      },
    );

    FirebaseFirestore.instance
        .collection(AppStrings.instaFeed)
        .doc(currentUserId.toString())
        .collection(AppStrings.items)
        .doc(currentUserId.toString())
        .delete();
  }

  @override
  Widget build(BuildContext context) {
    Column buildStatColumn(String label, int number) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Icon(
            Icons.image_outlined,
            color: AppColors.white,
          ),
          Container(
            margin: const EdgeInsets.only(top: 4.0),
            child: Text(
              label,
              style: Styles.containerLabel,
            ),
          ),
          Text(
            number.toString(),
            style: Styles.sendText,
          ),
        ],
      );
    }

    Column buildFollowersColumn(String label, int number) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Icon(
            Icons.pedal_bike_sharp,
            color: AppColors.white,
          ),
          Container(
            margin: const EdgeInsets.only(top: 4.0),
            child: Text(
              label,
              style: Styles.containerLabel,
            ),
          ),
          Text(
            number.toString(),
            style: Styles.containerLabel,
          ),
        ],
      );
    }

    Column buildFollowingColumn(String label, int number) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Icon(
            Icons.electric_bike_outlined,
            color: AppColors.white,
          ),
          Container(
            margin: const EdgeInsets.only(top: 4.0),
            child: Text(
              label,
              style: Styles.containerLabel,
            ),
          ),
          Text(
            number.toString(),
            style: Styles.containerLabel,
          ),
        ],
      );
    }

    Container buildFollowButton({
      String? text,
      Color? backgroundcolor,
      Color? textColor,
      Color? borderColor,
      Function()? function,
    }) {
      return Container(
        padding: EdgeInsets.only(top: 2.0),
        child: FlatButton(
          onPressed: function!,
          child: Container(
            decoration: BoxDecoration(
              color: backgroundcolor,
              border: Border.all(
                color: borderColor!,
              ),
              borderRadius: BorderRadius.circular(5.0),
            ),
            alignment: Alignment.center,
            child: Text(
              text!,
              style: Styles.fontWeightBold.copyWith(
                color: textColor,
              ),
            ),
            width: 200.0,
            height: 27.0,
          ),
        ),
      );
    }

    Container buildProfileFollowButton(BiuxUser user, Map followers) {
      bool isFollow = false; //Para verificar si se sigue o no al usuario
      if (currentUserId == user.id) {
        return buildFollowButton(
          text: AppStrings.editProfile,
          backgroundcolor: AppColors.white,
          textColor: AppColors.black,
          borderColor: AppColors.gray,
          function: () {
            Navigator.push(
              context,
              new MaterialPageRoute(
                builder: (BuildContext context) => ViewEditProfile(),
              ),
            );
          },
        );
      }
      followers.forEach(
        (key, value) {
          if (key == user.id.toString() && value == true) {
            isFollow = true;
          } else if (key == user.id.toString() && value == false) {
            isFollow = false;
          }
        },
      );

      if (isFollow) {
        return buildFollowButton(
          text: AppStrings.stopFollowing,
          backgroundcolor: AppColors.white,
          textColor: AppColors.black,
          borderColor: AppColors.gray,
          function: unfollowUser,
        );
      } else {
        return buildFollowButton(
          text: AppStrings.follow,
          backgroundcolor: AppColors.strongCyan,
          textColor: AppColors.white,
          borderColor: AppColors.strongCyan,
          function: followUser,
        );
      }
    }

    Container buildUserPosts() {
      Future<List<StoriesScreen>> getPosts() async {
        List<StoriesScreen> posts = [];
        var snap = await FirebaseFirestore.instance
            .collection(AppStrings.instaPosts)
            .where(AppStrings.ownerIdText, isEqualTo: AppStrings.idUFirebase(id: currentUserId.toString()))
            //.orderBy("timestamp")
            .get();
        for (var doc in snap.docs) {
          posts.add(StoriesScreen.fromDocument(doc));
          setState(
            () {
              postCount = snap.docs.length;
              var time = Timestamp.now();
              posts.sort((a, b) => time.compareTo(b.timestamp));
            },
          );
        }
        return posts.toList();
      }

      Future<List<ViewImage>> getPostsImage() async {
        List<ViewImage> dataimage = [];
        var snap = await FirebaseFirestore.instance
            .collection(AppStrings.instaPosts)
            // .orderBy("timestamp")
            .where(AppStrings.ownerIdText, isEqualTo: AppStrings.idUFirebase(id: currentUserId.toString()))
            .get();
        for (var doc in snap.docs) {
          dataimage.add(ViewImage.fromDocument(doc));
          setState(
            () {
              postCount = snap.docs.length;
              var time = Timestamp.now();
              dataimage.sort((a, b) => time.compareTo(b.timestamp));
            },
          );
        }
        return dataimage.toList();
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
                    children: snapshot.data!.map(
                      (ViewImage imagePost) {
                        return imagePost;
                      },
                    ).toList(),
                  );
                },
              ),
            );
            return dataView;
          },
        ),
      );
    }

    return StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection(AppStrings.instaUsers)
          .doc(AppStrings.idUFirebase(id: currentUserId.toString()))
          .snapshots(),
      builder: (context, AsyncSnapshot<dynamic> snapshot) {
        if (!snapshot.hasData)
          return Container(
            alignment: FractionalOffset.center,
            child: CircularProgressIndicator(),
          );
        if (snapshot.data.data()[AppStrings.followersText]!.containsKey(currentUserId) &&
            snapshot.data.data()[AppStrings.followersText]![currentUserId] &&
            followButtonClicked == false) {
          isFollowing = true;
        }
        return Scaffold(
          backgroundColor: AppColors.white,
          body: SafeArea(
            child: ListView(
              children: <Widget>[
                Stack(
                  alignment: Alignment.center,
                  children: <Widget>[
                    Container(
                      height: 350,
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          colorFilter: ColorFilter.mode(
                            AppColors.black.withOpacity(0.6),
                            BlendMode.colorBurn,
                          ),
                          image: NetworkImage(
                            snapshot.data.data()[AppStrings.profileCoverText] == null
                                ? AppStrings.urlBiuxApp
                                : snapshot.data.data()[AppStrings.profileCoverText],
                          ),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(left: 20),
                              child: GestureDetector(
                                child: Icon(
                                  Icons.arrow_back,
                                  color: AppColors.white,
                                ),
                                onTap: () {
                                  SchedulerBinding.instance
                                      .addPostFrameCallback(
                                    (_) {
                                      Navigator.of(context).pop();
                                    },
                                  );
                                },
                              ),
                            ),
                            widget.user!.names == snapshot.data.data()[AppStrings.emailText]
                                ? IconButton(
                                    icon: Icon(Icons.share,
                                        color: AppColors.white),
                                    onPressed: () async {
                                      final RenderObject? box =
                                          context.findRenderObject();
                                      if (Platform.isAndroid) {
                                        await Share.share(
                                          AppStrings.messageWhatsapp(usuario: snapshot.data.data()[AppStrings.user])
                                        );
                                      }
                                    },
                                  )
                                : Container()
                          ],
                        ),
                        Align(
                          alignment: Alignment(0.0, 3.0),
                          child: GestureDetector(
                            child: Material(
                              elevation: 20,
                              borderRadius: BorderRadius.circular(55.0),
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(60.0),
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppColors.white,
                                      spreadRadius: 5,
                                    )
                                  ],
                                ),
                                child: GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) {
                                          return ZoomPage3(
                                            snapshot.data.data()[AppStrings.photoText] ==
                                                    null
                                                ? AppStrings.urlBiuxApp
                                                : snapshot.data.data()[AppStrings.photoText],
                                          );
                                        },
                                      ),
                                    );
                                  },
                                  child: Container(
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: AppColors.strongCyan,
                                    ),
                                    height: 110,
                                    width: 110,
                                    child: InkWell(
                                      child: new Container(
                                        alignment: (Alignment(-1.0, 2.5)),
                                        decoration: new BoxDecoration(
                                          image: DecorationImage(
                                            fit: BoxFit.cover,
                                            image: NetworkImage(
                                              snapshot.data.data()[AppStrings.photoText],
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
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              alignment: Alignment.center,
                              padding: const EdgeInsets.only(top: 15.0),
                              child: Text(
                                snapshot.data.data()[AppStrings.emailText],
                                style: Styles.containerWhite,
                              ),
                            ),
                            Container(
                              width: 5,
                            ),
                            Container(
                              alignment: Alignment.center,
                              padding: const EdgeInsets.only(top: 15.0),
                              child: Text(
                                snapshot.data.data()[AppStrings.surname] == null
                                    ? ''
                                    : snapshot.data.data()[AppStrings.surname],
                                style: Styles.containerWhite,
                              ),
                            ),
                          ],
                        ),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              alignment: Alignment.center,
                              child: Text(
                                AppStrings.view(user: snapshot.data.data()[AppStrings.user]),
                                style: Styles.containerDescription,
                              ),
                            ),
                            currentUserId == user!.id
                                ? Container(
                                    alignment: Alignment.center,
                                    padding: const EdgeInsets.only(top: 4.0),
                                    child: Text(
                                      AppStrings.view(user: snapshot.data.data()[AppStrings.emailText]),
                                      style: Styles.containerDescription,
                                    ),
                                  )
                                : Container()
                          ],
                        ),
                        Row(
                          children: <Widget>[
                            Expanded(
                              flex: 1,
                              child: Column(
                                children: <Widget>[
                                  Row(
                                    mainAxisSize: MainAxisSize.max,
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: <Widget>[
                                      buildStatColumn(AppStrings.stories, postCount),
                                      buildFollowingColumn(
                                       AppStrings.followersText2,
                                        _countFollowings(
                                          snapshot.data.data()[AppStrings.followersText],
                                        ),
                                      ),
                                      buildFollowersColumn(
                                        AppStrings.followingText2,
                                        _countFollowings(
                                          snapshot.data.data()[AppStrings.followingText]!,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: <Widget>[
                                      buildProfileFollowButton(
                                        widget.user!,
                                        snapshot.data.data()[AppStrings.followersText],
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    // Container(
                    //   alignment: Alignment.centerLeft,
                    //   padding: const EdgeInsets.only(top: 10.0),
                    //   child: Text(""),
                    // ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.only(top: 3.0),
                ),
                // buildImageViewButtonBar(),
                buildUserPosts(),
              ],
            ),
          ),
        );
      },
    );
  }

  changeView(String viewName) {
    setState(() {
      view = viewName;
    });
  }

  int _countFollowings(Map followings) {
    int count = 0;
    void countValues(key, value) {
      if (value) {
        count += 1;
      }
    }

    followings.forEach(countValues);
    return count;
  }

  @override
  bool get wantKeepAlive => true;
}

class ImageTile extends StatelessWidget {
  final StoriesScreen imagePost;

  ImageTile(this.imagePost);

  clickedImage(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute<bool>(
        builder: (BuildContext context) {
          return Center(
            child: Scaffold(
              appBar: AppBar(
                title: Text(
                  AppStrings.postsProfile,
                  style: Styles.appBarProfile,
                ),
                backgroundColor: AppColors.white,
              ),
              body: GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) {
                        return ZoomPage2(imagePost.photo);
                      },
                    ),
                  );
                },
                child: ListView(
                  children: <Widget>[
                    Container(
                      child: imagePost,
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        GestureDetector(
          onTap: () => clickedImage(context),
          child: Image.network(
            imagePost.photo,
            fit: BoxFit.cover,
          ),
        ),
      ],
    );
  }
}

void openProfile(
  BuildContext context,
  String username,
  String photo,
  BiuxUser user,
) {
  Navigator.of(context).push(
    MaterialPageRoute<bool>(
      builder: (BuildContext context) {
        return ProfileScreen(
          username: username,
          photo: photo,
          currentUserId: user.id,
          user: user,
        );
      },
    ),
  );
}
