import 'package:biux/config/colors.dart';
import 'package:biux/config/styles.dart';
import 'package:biux/config/strings.dart';
import 'package:biux/data/models/user.dart';
import 'package:biux/data/repositories/users/user_repository.dart';
import 'package:biux/data/local_storage/localstorage.dart';
import 'package:biux/ui/screens/user/profile_screen.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import "dart:async";
// import "main.dart"; //for current user

class CommentScreen extends StatefulWidget {
  final String postId;
  final String postOwner;
  final String postMediaUrl;
  final BiuxUser user;

  const CommentScreen({
    required this.postId,
    required this.postOwner,
    required this.postMediaUrl,
    required this.user,
  });
  @override
  _CommentScreenState createState() => _CommentScreenState(
        postId: this.postId,
        postOwner: this.postOwner,
        postMediaUrl: this.postMediaUrl,
      );
}

class _CommentScreenState extends State<CommentScreen> {
  final String postId;
  final String postOwner;
  final String postMediaUrl;

  bool didFetchComments = false;
  List<Comment> fetchedComments = [];

  final TextEditingController _commentController = TextEditingController();

  _CommentScreenState({
    required this.postId,
    required this.postOwner,
    required this.postMediaUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // backgroundColor: AppColors.greyishNavyBlue,
      appBar: AppBar(
        backgroundColor: AppColors.strongCyan,
        title: Text(
          AppStrings.biuxComments,
          style: Styles.accentTextThemeWhite,
        ),
      ),
      body: buildPage(),
    );
  }

  Widget buildPage() {
    return Column(
      children: [
        Expanded(
          child: buildComments(),
        ),
        Divider(),
        ListTile(
          title: TextFormField(
            controller: _commentController,
            decoration: InputDecoration(labelText: AppStrings.writeComment),
            onFieldSubmitted: addComment,
          ),
          trailing: OutlinedButton(
            onPressed: () {
              addComment(_commentController.text);
            },
            //borderSide: BorderSide.none,
            child: Text(
              AppStrings.postText,
              style: Styles.accentTextThemeBlack,
            ),
          ),
        ),
      ],
    );
  }

  Widget buildComments() {
    if (this.didFetchComments == false) {
      return FutureBuilder<List<Comment>>(
        future: getComments(),
        builder: (context, AsyncSnapshot<dynamic> snapshot) {
          if (!snapshot.hasData)
            return Container(
              alignment: FractionalOffset.center,
              child: CircularProgressIndicator(),
            );
          this.didFetchComments = true;
          this.fetchedComments = snapshot.data!;
          return snapshot.data.isEmpty
              ? Center(
                  child: Text(AppStrings.noComments),
                )
              : ListView(
                  children: snapshot.data,
                );
        },
      );
    } else {
      // for optimistic updating
      return ListView(children: this.fetchedComments);
    }
  }

  Future<List<Comment>> getComments() async {
    List<Comment> comments = [];
    var result = await FirebaseFirestore.instance
        .collection(AppStrings.instaComments)
        .doc(postId)
        .collection(AppStrings.comments)
        .get();
    comments = result.docs
        .map((doc) => Comment.fromMap(
              doc.data(),
            ))
        .toList();
    // data.docs.forEach((DocumentSnapshot doc) {
    //   comments.add(Comment.fromMap(doc));
    // });

    return comments;
  }

  addComment(String comment) {
    _commentController.clear();
    FirebaseFirestore.instance
        .collection(AppStrings.instaComments)
        .doc(postId)
        .collection(AppStrings.comments)
        .add({
      AppStrings.userNameText: widget.user.userName,
      AppStrings.comment: comment,
      AppStrings.timestamp: Timestamp.now(),
      AppStrings.avatarUrlText: widget.user.photo,
      AppStrings.userIdText: widget.user.id.toString()
    });

    //adds to postOwner's activity feed
    FirebaseFirestore.instance
        .collection(AppStrings.instaFeed)
        .doc(postOwner)
        .collection(AppStrings.items)
        .add(
      {
        AppStrings.userNameText: widget.user.userName,
        AppStrings.userIdText: widget.user.id.toString(),
        AppStrings.typeText: AppStrings.comment,
        AppStrings.userProfileImgText: widget.user.photo,
        AppStrings.commentData: comment,
        AppStrings.timestamp: Timestamp.now(),
        AppStrings.postId: postId,
        AppStrings.foto: postMediaUrl,
      },
    );

    // add comment to the current listview for an optimistic update
    setState(
      () {
        fetchedComments = List.from(fetchedComments)
          ..add(
            Comment(
              username: widget.user.userName,
              comment: comment,
              timestamp: Timestamp.now(),
              avatarUrl: widget.user.photo,
              userId: widget.user.id.toString(),
            ),
          );
      },
    );
  }
}

class Comment extends StatelessWidget {
  final String username;
  final String userId;
  final String avatarUrl;
  final String comment;
  final Timestamp timestamp;
  BiuxUser? user;

  Comment({
    required this.username,
    required this.userId,
    required this.avatarUrl,
    required this.comment,
    required this.timestamp,
  });

  factory Comment.fromMap(
    Map map,
  ) {
    return Comment(
      username: map[AppStrings.userNameText],
      userId: map[AppStrings.userIdText],
      comment: map[AppStrings.comment],
      timestamp: map[AppStrings.timestamp],
      avatarUrl: map[AppStrings.avatarUrlText],
    );
  }
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(15.0),
      child: Card(
        elevation: 10,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(20),
            topRight: Radius.circular(20),
            topLeft: Radius.circular(20),
            bottomRight: Radius.circular(0),
          ),
        ),
        child: Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(left: 28.0, bottom: 0, top: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    child: Text(
                      username,
                      style: Styles.sizedBox,
                    ),
                    onTap: () async {
                      var username = (await LocalStorage().getUser())!;
                      user = await UserRepository().getPerson(username);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (BuildContext context) => ProfileScreen(
                            currentUserId: userId,
                            photo: user!.photo,
                            user: user,
                            username: user!.userName,
                            profileCover: user!.profileCover,
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
            GestureDetector(
              onTap: () {},
              child: ListTile(
                title: Text(
                  comment,
                  style: Styles.accentTextThemeBlack,
                ),
                leading: GestureDetector(
                  child: CircleAvatar(
                    maxRadius: 35,
                    backgroundImage: NetworkImage(avatarUrl),
                  ),
                  onTap: () async {
                    var username = (await LocalStorage().getUser())!;
                    user = await UserRepository().getPerson(username);
                    Navigator.push(
                      context,
                       MaterialPageRoute(
                        builder: (BuildContext context) => ProfileScreen(
                          currentUserId: userId,
                          photo: user!.photo,
                          user: user,
                          username: user!.userName,
                          profileCover: user!.profileCover,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
            Container(
              height: 10,
            ),
          ],
        ),
      ),
    );
  }
}
