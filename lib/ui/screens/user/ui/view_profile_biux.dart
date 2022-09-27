import 'dart:io';
import 'package:biux/config/colors.dart';
import 'package:biux/config/styles.dart';
import 'package:biux/config/strings.dart';
import 'package:biux/data/models/user.dart';
import 'package:biux/ui/screens/story/ui/screens/stories_screen.dart';
import 'package:biux/ui/screens/user/edit_profile.dart';
import 'package:biux/ui/screens/zoom_screen/zoom_screen.dart';
import 'package:biux/ui/widgets/view_image_widget.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async';
import 'package:flutter/scheduler.dart';
import 'package:share/share.dart';

class ViewProfileBiux extends StatefulWidget {
  const ViewProfileBiux({
    this.user,
  });
  final BiuxUser? user;
  _ViewProfileBiux createState() => _ViewProfileBiux(this.user);
}

class _ViewProfileBiux extends State<ViewProfileBiux>
    with AutomaticKeepAliveClientMixin<ViewProfileBiux> {
  final BiuxUser? user;

  String view = AppStrings.grid;
  bool isFollowing = false;
  bool followButtonClicked = false;
  int postCount = 0;
  int followerCount = 0;
  int followingCount = 0;
  List<StoriesScreen> posts = [];
  _ViewProfileBiux(
    this.user,
  );

  followUser() {
    setState(() {
      this.isFollowing = true;
      followButtonClicked = true;
    });

    FirebaseFirestore.instance
        .doc(AppStrings.instaUserFirebase(id: user!.id.toString()))
        .update(
      { AppStrings.followersFirebase(id: user!.id.toString()): true},
    );

    FirebaseFirestore.instance
        .doc(AppStrings.instaUserFirebase(id: user!.id.toString()))
        .update(
      {AppStrings.followingFirebase(id: user!.id.toString()): true},
    );

    // FirebaseFirestore.instance
    //     .collection("insta_a_feed")
    //     .doc(user!.id.toString())
    //     .collection("items")
    //     .doc(user!.id.toString())
    //     .set({
    //   "ownerId": user!.id.toString(),
    //   "username": user!.usuario,
    //   "userId": user!.id.toString(),
    //   "type": "follow",
    //   "userProfileImg": foto,
    //   "timestamp": DateTime.now()
    // });
  }

  @override
  void initState() {
    super.initState();
  }

  unfollowUser() {
    setState(() {
      isFollowing = false;
      followButtonClicked = true;
    });

    FirebaseFirestore.instance
        .doc(AppStrings.instaUserFirebase(id: user!.id.toString()))
        .update({
      AppStrings.followersFirebase(id: user!.id.toString()): false
      //firestore plugin doesnt support deleting, so it must be nulled / falsed
    });

    FirebaseFirestore.instance
        .doc(AppStrings.instaUserFirebase(id: user!.id.toString()))
        .update({
      AppStrings.followingFirebase(id: user!.id.toString()): false
      //firestore plugin doesnt support deleting, so it must be nulled / falsed
    });

    FirebaseFirestore.instance
        .collection(AppStrings.instaFeed)
        .doc(user!.id.toString())
        .collection(AppStrings.items)
        .doc(user!.id.toString())
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
            style: Styles.sendText,
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
            style: Styles.sendText,
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
              border: Border.all(color: borderColor!),
              borderRadius: BorderRadius.circular(
                5.0,
              ),
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

    Container buildProfileFollowButton(BiuxUser user) {
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

    Container buildUserPosts() {
      Future<List<StoriesScreen>> getPosts() async {
        var snap = await FirebaseFirestore.instance
            .collection(AppStrings.instaPosts)
            .where(AppStrings.ownerIdText, isEqualTo: '${user!.id.toString()}U')
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
        List<ViewImage> dataimage = [];
        var snap = await FirebaseFirestore.instance
            .collection(AppStrings.instaPosts)
            .where(AppStrings.ownerIdText, isEqualTo: '${user!.id.toString()}U')
            // .orderBy('timestamp')
            .get();
        for (var doc in snap.docs) {
          dataimage.add(ViewImage.fromDocument(doc));
          setState(
            () {
              postCount = snap.docs.length;
              var time = Timestamp.now();
              dataimage.sort(
                (a, b) => time.compareTo(b.timestamp),
              );
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
                      padding: const EdgeInsets.only(
                        top: 10.0,
                      ),
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
          .doc('${user!.id.toString()}U')
          .snapshots(),
      builder: (context, AsyncSnapshot<dynamic> snapshot) {
        if (!snapshot.hasData)
          return Container(
            alignment: FractionalOffset.center,
            child: CircularProgressIndicator(),
          );
        // Usuario user = Usuario.fromJsonMap(
        //   snapshot.data(),
        // );
        if (snapshot.data.data()[AppStrings.followersText]!.containsKey(user!.id) &&
            snapshot.data.data()[AppStrings.followersText]![user!.id] &&
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
                          colorFilter: new ColorFilter.mode(
                              AppColors.black.withOpacity(0.6),
                              BlendMode.colorBurn),
                          image: NetworkImage(
                            widget.user!.profileCover,
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
                            IconButton(
                              icon: Icon(
                                Icons.share,
                                color: AppColors.white,
                              ),
                              onPressed: () async {
                                final RenderObject? box =
                                    context.findRenderObject();
                                if (Platform.isAndroid) {
                                  await Share.share(
                                    AppStrings.messageshare,
                                  );
                                }
                              },
                            ),
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
                                            widget.user!.photo,
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
                                      child: Container(
                                        alignment: (Alignment(
                                          -1.0,
                                          2.5,
                                        )),
                                        decoration: BoxDecoration(
                                          image: DecorationImage(
                                            fit: BoxFit.cover,
                                            image: NetworkImage(
                                              widget.user!.photo,
                                            ),
                                          ),
                                          borderRadius: BorderRadius.all(
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
                                snapshot.data.data()[AppStrings.email],
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
                                snapshot.data.data()[AppStrings.lastName] == null
                                    ? ''
                                    : snapshot.data.data()[AppStrings.lastName],
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
                                AppStrings.view(user: snapshot.data.data()[AppStrings.userText]),
                                style: Styles.containerDescription,
                              ),
                            ),
                            Container(
                              alignment: Alignment.center,
                              padding: const EdgeInsets.only(top: 4.0),
                              child: Text(
                                AppStrings.view(user: snapshot.data.data()[AppStrings.emailText]),
                                style: Styles.containerDescription,
                              ),
                            ),
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
                                      buildStatColumn(AppStrings.storyText, postCount),
                                      buildFollowingColumn(
                                        AppStrings.followers,
                                        _countFollowings(
                                          snapshot.data.data()[AppStrings.followersText],
                                        ),
                                      ),
                                      buildFollowersColumn(
                                        AppStrings.following,
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
                                      )
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
                posts.isEmpty
                    ? Container(
                        alignment: Alignment.center,
                        padding: const EdgeInsets.only(top: 15.0),
                        child: Text(
                          AppStrings.firstStory,
                          style: Styles.containerBlack,
                        ),
                      )
                    : Container()
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
              body: ListView(
                children: <Widget>[
                  Container(
                    child: imagePost,
                  ),
                ],
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
