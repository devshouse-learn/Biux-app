import 'package:biux/config/colors.dart';
import 'package:biux/config/styles.dart';
import 'package:biux/config/strings.dart';
import 'package:biux/data/models/user.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
//needed for currentuser id

class ActivityFeedPage extends StatefulWidget {
  final BiuxUser? user;
  ActivityFeedPage(this.user);
  @override
  _ActivityFeedPageState createState() => _ActivityFeedPageState();
}

class _ActivityFeedPageState extends State<ActivityFeedPage>
    with AutomaticKeepAliveClientMixin<ActivityFeedPage> {
  @override
  Widget build(BuildContext context) {
    super.build(context); // reloads state when opened again
    return Scaffold(
      appBar: AppBar(
        leading: new IconButton(
          icon: new Icon(
            Icons.arrow_back,
            color: AppColors.black,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text(
          AppStrings.notifications,
          style: Styles.accentTextThemeBlack,
        ),
        backgroundColor: AppColors.white,
      ),
      body: buildActivityFeed(),
    );
  }

  buildActivityFeed() {
    return Container(
      color: AppColors.white,
      child: FutureBuilder(
        future: getFeed(),
        builder: (context, AsyncSnapshot<dynamic> snapshot) {
          if (!snapshot.hasData)
            return Container(
              alignment: FractionalOffset.center,
              padding: const EdgeInsets.only(top: 10.0),
              child: CircularProgressIndicator(),
            );
          else {
            return ListView(children: snapshot.data);
          }
        },
      ),
    );
  }

  getFeed() async {
    List<ActivityFeedItem> items = [];
    var snap = await FirebaseFirestore.instance
        .collection(AppStrings.instaFeed)
        .doc(widget.user!.id.toString())
        .collection(AppStrings.items)
        .orderBy(AppStrings.timestamp)
        .get();
    // items.add(ActivityFeedItem.fromMap(map)(doc));
    items = snap.docs
        .map((doc) => ActivityFeedItem.fromMap(
              doc.data(),
            ))
        .toList();
    return items;
  }

  // ensures state is kept when switching pages
  @override
  bool get wantKeepAlive => true;
}

class ActivityFeedItem extends StatelessWidget {
  final String username;
  final String userId;
  final String type; // types include liked photo, follow user, comment on photo
  final String photo;
  final String averageId;
  final String userProfileImg;
  final String commentData;

  ActivityFeedItem({
    required this.username,
    required this.userId,
    required this.type,
    required this.photo,
    required this.averageId,
    required this.userProfileImg,
    required this.commentData,
  });

  // factory ActivityFeedItem.fromDocument(DocumentSnapshot document) {
  //   var data = document.data();
  //   return ActivityFeedItem(
  //     username: data['username'],
  //     userId: data['userId'],
  //     type: data['type'],
  //     foto: data['foto'],
  //     mediaId: data['postId'],
  //     userProfileImg: data['userProfileImg'],
  //     commentData: data["commentData"],
  //   );
  // }
  factory ActivityFeedItem.fromMap(
    Map map,
  ) {
    return ActivityFeedItem(
      username: map[AppStrings.userNameText],
      userId: map[AppStrings.userIdText],
      type: map[AppStrings.typeText],
      photo: map[AppStrings.photoText],
      averageId: map[AppStrings.averageId],
      userProfileImg: map[AppStrings.userProfileImgText],
      commentData: map[AppStrings.commentData],
    );
  }

  Widget mediaPreview = Container();
  var actionText;

  void configureItem(BuildContext context) {
    if (type == AppStrings.like || type == AppStrings.comment) {
      mediaPreview = GestureDetector(
        onTap: () {
          openImage(context, averageId);
        },
        child: Container(
          height: 45.0,
          width: 45.0,
          child: AspectRatio(
            aspectRatio: 487 / 451,
            child: Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                  fit: BoxFit.fill,
                  alignment: FractionalOffset.topCenter,
                  image: NetworkImage(photo),
                ),
              ),
            ),
          ),
        ),
      );
    }
    if (type == AppStrings.like) {
      actionText = AppStrings.biuxPost;
    } else if (type == AppStrings.followText) {
      actionText = AppStrings.startFollow;
    } else if (type == AppStrings.comment) {
      actionText = AppStrings.messagecomment(commentData: commentData);
    } else {
      actionText = AppStrings.errorInvalid(type: type);
    }
  }

  @override
  Widget build(BuildContext context) {
    configureItem(context);
    return Row(
      mainAxisSize: MainAxisSize.max,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.only(
            left: 20.0,
            right: 15.0,
          ),
          child: CircleAvatar(
            radius: 23.0,
            backgroundImage: NetworkImage(userProfileImg),
          ),
        ),
        Expanded(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              GestureDetector(
                child: Text(
                  username,
                  style: Styles.advertisingTitleBlack,
                ),
                onTap: () {
                  //  openProfile(context, userId);
                },
              ),
              Flexible(
                child: Container(
                  child: Text(
                    actionText,
                    style: Styles.accentTextThemeBlack,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              )
            ],
          ),
        ),
        Container(
          child: Align(
            child: Padding(
              child: mediaPreview,
              padding: EdgeInsets.all(15.0),
            ),
            alignment: AlignmentDirectional.bottomEnd,
          ),
        )
      ],
    );
  }
}

openImage(
  BuildContext context,
  String imageId,
) {
  Navigator.of(context).push(
    MaterialPageRoute<bool>(
      builder: (BuildContext context) {
        return Center(
          child: Scaffold(
            backgroundColor: AppColors.white,
            appBar: AppBar(
              title: Text(
                AppStrings.photoText,
                style: Styles.advertisingTitleBlack,
              ),
              backgroundColor: AppColors.white,
            ),
            body: ListView(
              children: <Widget>[
                Container(),
              ],
            ),
          ),
        );
      },
    ),
  );
}
