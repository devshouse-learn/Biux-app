import 'package:biux/config/colors.dart';
import 'package:biux/config/styles.dart';
import 'package:biux/config/strings.dart';
import 'package:biux/data/models/user.dart';
import 'package:biux/data/repositories/users/user_repository.dart';
import 'package:biux/data/local_storage/localstorage.dart';
import 'package:biux/ui/screens/zoom_screen/zoom_screen.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'dart:async';
// import 'profile_page.dart';

// import 'package:flutter_image_slideshow/flutter_image_slideshow.dart';

class ViewImage extends StatefulWidget {
  const ViewImage({
    required this.photo,
    required this.user,
    required this.location,
    required this.description,
    this.likes,
    required this.postId,
    required this.ownerId,
    required this.timestamp,
  });

  factory ViewImage.fromDocument(DocumentSnapshot document) {
    return ViewImage(
      user: document[AppStrings.user],
      timestamp: document[AppStrings.timestamp],
      location: document[AppStrings.locationText],
      photo: document[AppStrings.photoText],
      likes: document[AppStrings.likes],
      description: document[AppStrings.description2],
      postId: document.id,
      ownerId: document[AppStrings.ownerIdText],
    );
  }

  factory ViewImage.fromJSON(Map data) {
    return ViewImage(
      user: data[AppStrings.user],
      location: data[AppStrings.locationText],
      timestamp: data[AppStrings.timestamp],
      photo: data[AppStrings.photoText],
      likes: data[AppStrings.likes],
      description: data[AppStrings.description2],
      ownerId: data[AppStrings.ownerIdText],
      postId: data[AppStrings.postId],
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

  _ViewImage createState() => _ViewImage(
        photo: this.photo,
        user: this.user,
        location: this.location,
        description: this.description,
        likes: this.likes,
        likeCount: getLikeCount(this.likes),
        ownerId: this.ownerId,
        postId: this.postId,
        timestamp: this.timestamp,
      );
}

class _ViewImage extends State<ViewImage> {
  final String? photo;
  final String? user;
  final String? location;
  final Timestamp? timestamp;
  final String? description;
  Map? likes;
  int? likeCount;
  final String? postId;
  bool liked = false;
  final String? ownerId;

  bool showHeart = false;

  TextStyle boldStyle = Styles.appBarProfile;

  var reference = FirebaseFirestore.instance.collection(AppStrings.instaPosts);

  _ViewImage({
    required this.photo,
    required this.timestamp,
    required this.user,
    required this.location,
    required this.description,
    required this.likes,
    required this.postId,
    required this.likeCount,
    required this.ownerId,
  });
  BiuxUser? _user;
  String formattedDate2 = "";
  String formattedDate = "";
  String formatted = "";

  @override
  void initState() {
    super.initState();
    getUserProfile();
  }

  getUserProfile() {
    Future.delayed(
      Duration.zero,
      () async {
        var username = (await LocalStorage().getUser())!;
        _user = await UserRepository().getPerson(username);
        var date = DateTime.fromMicrosecondsSinceEpoch(
          timestamp!.microsecondsSinceEpoch,
        );
        formattedDate2 = DateFormat(AppStrings.dateFormat6).format(date);
        formattedDate = formattedDate2.replaceAll(':', '');
        formatted = formattedDate.replaceAll('/', '-');
        //  usuarioMembresia =
        //  await UsuariosRepositorio().obtenerPersonaMembrecia(usuario.id);
      },
    );
  }

  GestureDetector buildLikeIcon() {
    Color color;
    IconData icon;
    if (liked) {
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
      onTap: () {},
    );
  }

  GestureDetector buildLikeableImage() {
    return GestureDetector(
      child: Column(
        children: <Widget>[
          CachedNetworkImage(
            imageUrl: photo!,
            fit: BoxFit.fitHeight,
            placeholder: (context, url) => loadingPlaceHolder,
            errorWidget: (context, url, error) => Icon(Icons.error),
          ),
        ],
      ),
    );
  }

  buildPostHeader({String? ownerId}) {
    if (ownerId == null) {
      return Text(AppStrings.ownerError);
    }
    return FutureBuilder(
      future: FirebaseFirestore.instance
          .collection(AppStrings.instaUsers)
          .doc(ownerId)
          .get(),
      builder: (context, AsyncSnapshot<dynamic> snapshot) {
        if (snapshot.data != null) {
          final data = snapshot.requireData;
          return Stack(
            children: [],
          );
        }
        return Container();
      },
    );
  }

  Container loadingPlaceHolder = Container(
    height: 70.0,
    child: Center(child: CircularProgressIndicator()),
  );

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    // liked = (likes![AppStrings.idDoc] == true);

    Widget imageCarousel = Card(
      elevation: 5,
      child: Column(
        children: [
          buildLikeableImage(),
        ],
      ),
    );
    return Padding(
      padding: EdgeInsets.only(
        left: 4.0,
        bottom: 2.0,
        top: 2.0,
      ),
      child: Column(
        children: <Widget>[
          Column(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(2.5),
                child: GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) {
                          return ZoomPage2(
                            photo!,
                          );
                        },
                      ),
                    );
                  },
                  child: Container(
                    height: 116,
                    width: size.width * 0.307,
                    child: CachedNetworkImage(
                      imageUrl: photo!,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => loadingPlaceHolder,
                      errorWidget: (context, url, error) => Icon(Icons.error),
                    ),
                  ),
                ),
              )
            ],
          ),
        ],
      ),
    );
  }
}
