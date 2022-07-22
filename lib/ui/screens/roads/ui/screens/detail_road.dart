import 'dart:io';
import 'package:biux/config/colors.dart';
import 'package:biux/config/styles.dart';
import 'package:biux/config/strings.dart';
import 'package:biux/config/themes/theme.dart';
import 'package:biux/config/themes/theme_notifier.dart';
import 'package:biux/data/shared_preferences/localstorage.dart';
import 'package:biux/data/models/competitor_road.dart';
import 'package:biux/data/models/user.dart';
import 'package:biux/data/models/analitics.dart';
import 'package:biux/data/models/road.dart';
import 'package:biux/data/repositories/members/members_repository.dart';
import 'package:biux/data/repositories/roads/roads_repository.dart';
import 'package:biux/data/repositories/users/user_repository.dart';
import 'package:biux/ui/screens/home.dart';
import 'package:biux/ui/widgets/list_participants_roads_widget.dart';
import 'package:http/http.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:photo_view/photo_view.dart';
import 'package:provider/provider.dart';
import 'package:share/share.dart';
import 'package:simple_star_rating/simple_star_rating.dart';
// import 'package:share/share.dart';

class DetailRoad extends StatefulWidget {
  final Road road;
  var dates;
  final VoidCallback? onReassemble;
  DetailRoad(this.road, this.dates, {this.onReassemble});

  @override
  _DetailRoadState createState() => _DetailRoadState();
}

class _DetailRoadState extends State<DetailRoad> {
  bool pressGeoON = false;
  late String roadDate;
  bool cmbscritta = false;
  late CompetitorRoad competitorRoad;
  late String? userId = AppStrings.idInitialized;
  ThemeData theme = darkTheme;
  int joinMe = 0;
  late List<String> imagePaths = [];
  BiuxUser? user;
  int validated = 0;

  @override
  void initState() {
    super.initState();

    todayDate();
    getUserProfile();
  }

  var response;
  void reassemble() {
    super.reassemble();
    if (joinMe == 1) {
      setState(
        () {
          widget.onReassemble!();
        },
      );
    }
  }

  getUserProfile() {
    Future.delayed(
      Duration.zero,
      () async {
        var id = await LocalStorage().getUserId();
        var username = (await LocalStorage().getUser())!;
        user = await UserRepository().getPerson(username);
        setState(() {
          userId = id!;
        });

        final competitor = await RoadsRepository().getParticipantRoad(
          widget.road.id!,
          userId!,
        );

        if (competitor.id != null) {
          setState(() {
            competitorRoad = competitor;
          });
          joinMe = 1;
        } else {
          joinMe = 0;
        }
      },
    );
  }

  todayDate() {}

  var _darkTheme = true;
  @override
  Widget build(BuildContext context) {
    final themeNotifier = Provider.of<ThemeNotifier>(context);
    _darkTheme = (themeNotifier.getTheme() == darkTheme);
    final RenderObject? box = context.findRenderObject();
    bool is12HoursFormat = MediaQuery.of(context).alwaysUse24HourFormat;
    Future.delayed(
      Duration(seconds: 1),
      () {
        validated == 1
            ? showDialog4(context, widget.road.group!.name!)
            : Container();
      },
    );
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.greyishNavyBlue,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        actions: [
          int.parse(userId!) == widget.road.group!.adminId
              ? Row(
                  children: [
                    IconButton(
                      icon: Icon(Icons.delete),
                      onPressed: () async {
                        showDialog(
                          context: this.context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20.0),
                                side: BorderSide(
                                  width: 3,
                                  color: AppColors.greyishNavyBlue,
                                ),
                              ),
                              content: Text(AppStrings.deletedRodada),
                              actions: <Widget>[
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceAround,
                                  children: [
                                    FlatButton(
                                      shape: RoundedRectangleBorder(
                                        borderRadius:
                                            new BorderRadius.circular(20.0),
                                        side: BorderSide(
                                          width: 3,
                                          color: AppColors.greyishNavyBlue,
                                        ),
                                      ),
                                      onPressed: () async {
                                        Navigator.pop(context);
                                      },
                                      child: Text(AppStrings.cancelText),
                                    ),
                                    FlatButton(
                                      shape: RoundedRectangleBorder(
                                        borderRadius:
                                            new BorderRadius.circular(20.0),
                                        side: BorderSide(
                                          width: 3,
                                          color: AppColors.greyishNavyBlue,
                                        ),
                                      ),
                                      onPressed: () async {
                                        Analitycs.deleteRoad(
                                          user!.names!,
                                          user!.id!,
                                          widget.road.name!,
                                          widget.road.distance!,
                                          widget.road.routeLevel!,
                                          widget.road.group!.name!,
                                          widget.road.group!.city!.name!,
                                          widget.road.pointmeeting!,
                                          widget.road.numberParticipants!,
                                        );
                                        Navigator.of(context)
                                            .pushAndRemoveUntil(
                                                MaterialPageRoute(
                                                    builder: (context) =>
                                                        MyHome()),
                                                (Route<dynamic> route) => false)
                                            .then(
                                              (value) => setState(
                                                () => {},
                                              ),
                                            );
                                        await RoadsRepository().deleteRoad(
                                          widget.road,
                                          widget.road.group!,
                                        );
                                      },
                                      child: Text(AppStrings.deletedText),
                                    ),
                                  ],
                                )
                              ],
                            );
                          },
                        );
                      },
                    ),
                  ],
                )
              : Container(),
          IconButton(
            icon: Icon(Icons.share),
            onPressed: () async {
              Analitycs.shareRoad(
                user!.names!,
                user!.id!,
                widget.road.name!,
                widget.road.distance!,
                widget.road.routeLevel!,
                widget.road.group!.name!,
                widget.road.group!.city!.name!,
                widget.road.pointmeeting!,
                widget.road.numberParticipants!,
              );
              final RenderObject? box = context.findRenderObject();
              if (Platform.isAndroid) {
                var response = await get(
                  Uri.parse(
                    widget.road.image == null
                        ? widget.road.group!.logo!
                        : widget.road.image!,
                  ),
                );
                final documentDirectory =
                    (await getExternalStorageDirectory())!.path;
                File imgFile =
                    new File(AppStrings.file(png: documentDirectory));
                imgFile.writeAsBytesSync(response.bodyBytes);
                await Share.shareFiles(
                    [File(AppStrings.file(png: documentDirectory)).path],
                    text: AppStrings.messageFile(
                        description: widget.road.description!,
                        date: widget.dates!,
                        roadName: widget.road.name!,
                        distance: widget.road.distance!.toString(),
                        groupName: widget.road.group!.name!,
                        cellphone: widget.road.group!.admin!.cellphone!,
                        pointmeeting: widget.road.pointmeeting!));
              }
            },
          ),
        ],
        title: Row(
          children: <Widget>[
            Expanded(
              child: Container(
                child: Text(
                  widget.road.group!.name == null
                      ? AppStrings.notFound
                      : widget.road.group!.name!.toUpperCase(),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          ],
        ),
      ),
      body: ListView(
        children: <Widget>[
          Stack(
            children: <Widget>[
              GestureDetector(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Container(
                      height: 160,
                      width: 600,
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          image: NetworkImage(
                            widget.road.image == null
                                ? widget.road.group!.logo!
                                : widget.road.image!,
                          ),
                          fit: BoxFit.cover,
                        ),
                        borderRadius: BorderRadius.circular(2.0),
                      ),
                    ),
                  ],
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) {
                        return DetailScreen6(widget.road);
                      },
                    ),
                  );
                },
              ),
              Container(
                padding: new EdgeInsets.only(
                  top: 50.0,
                  bottom: 2,
                ),
              ),
            ],
          ),
          Container(
            height: 38,
            child: Card(
              elevation: 15,
              child: Text(
                widget.dates! == null ? AppStrings.dateNotFound : widget.dates!,
                textAlign: TextAlign.center,
                style: Styles.noDateText,
              ),
            ),
          ),
          Container(
            height: 10,
          ),
          Container(
            height: 20,
          ),
          Column(
            children: <Widget>[
              Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  Container(
                    width: 8,
                  ),
                  Container(
                    margin: EdgeInsets.only(left: 20),
                    child: Text(
                      AppStrings.route,
                      style: Styles.routeText,
                    ),
                  ),
                  Flexible(
                    child: Container(
                      child: Text(
                        widget.road.name == null ? "" : widget.road.name!,
                        overflow: TextOverflow.fade,
                        style: Styles.textStyle,
                      ),
                    ),
                  ),
                ],
              ),
              Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  Container(
                    width: 8,
                  ),
                  Container(
                    margin: EdgeInsets.only(left: 20),
                    child: Text(
                      AppStrings.organize,
                      style: Styles.routeText,
                    ),
                  ),
                  Expanded(
                    child: Container(
                      child: Text(
                        widget.road.group!.name!,
                        overflow: TextOverflow.fade,
                      ),
                    ),
                  ),
                ],
              ),
              Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  Container(
                    width: 8,
                  ),
                  Container(
                    margin: EdgeInsets.only(left: 20),
                    child: Text(
                      AppStrings.kmText,
                      style: Styles.routeText,
                    ),
                  ),
                  Expanded(
                    child: Container(
                      child: Text(
                        widget.road.distance.toString(),
                        overflow: TextOverflow.fade,
                      ),
                    ),
                  ),
                ],
              ),
              Row(
                children: <Widget>[
                  Container(
                    width: 8,
                  ),
                  Container(
                    margin: EdgeInsets.only(left: 20),
                    child: Text(
                      AppStrings.meetingPoint2,
                      style: Styles.pointMeetingText,
                    ),
                  ),
                  Expanded(
                    child: Container(
                      padding: EdgeInsets.only(left: 5, right: 8),
                      child: Text(
                        widget.road.pointmeeting!,
                        overflow: TextOverflow.fade,
                      ),
                    ),
                  ),
                ],
              ),
              Row(
                children: <Widget>[
                  Container(
                    width: 8,
                  ),
                  Container(
                    margin: EdgeInsets.only(left: 20),
                    child: Text(
                      AppStrings.level,
                      style: Styles.routeText,
                    ),
                  ),
                  Flexible(
                    child: Container(
                      child: SimpleStarRating(
                        allowHalfRating: true,
                        starCount: 5,
                        rating: widget.road.routeLevel!.toDouble(),
                        size: 15,
                        onRated: (rate) {},
                        spacing: 2,
                      ),
                    ),
                  ),
                ],
              ),
              Row(
                children: <Widget>[
                  Container(
                    width: 8,
                  ),
                ],
              ),
              Container(
                height: 6,
              ),
              Row(
                children: <Widget>[
                  Container(
                    padding: EdgeInsets.only(
                      left: 30,
                    ),
                  ),
                  Icon(
                    Icons.directions_bike,
                    size: 20,
                  ),
                  Container(
                    width: 5,
                  ),
                  Text(
                    widget.road.numberParticipants.toString(),
                    textAlign: TextAlign.start,
                    style: Styles.rowGroupNumberMembers,
                  ),
                  Container(
                    width: 10,
                  ),
                ],
              ),
            ],
          ),
          Container(
            height: 10,
          ),
          Container(
            padding: new EdgeInsets.only(left: 27),
            child: Text(
              AppStrings.descriptionsRecommendations,
              style: Styles.routeText,
            ),
          ),
          Container(
            padding: new EdgeInsets.only(
              left: 27,
              right: 20,
            ),
            child: Text(
              widget.road.description!,
              style: Styles.roadDescriptionText,
            ),
          ),
          Container(
            height: 10,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              joinMe == 1
                  ? ButtonTheme(
                      padding: EdgeInsets.only(right: 20, left: 20),
                      minWidth: 200,
                      height: 50.0,
                      child: RaisedButton(
                        shape: RoundedRectangleBorder(
                          borderRadius: new BorderRadius.circular(10.0),
                          side: BorderSide(
                            width: 3,
                            color: AppColors.red,
                          ),
                        ),
                        color: AppColors.red,
                        textColor: AppColors.white,
                        child: Text(
                          AppStrings.stopParticipating,
                          style: Styles.accentTextThemeWhite,
                        ),
                        onPressed: () async {
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return MaterialApp(
                                home: AlertDialog(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20.0),
                                    side: BorderSide(
                                      width: 3,
                                      color: AppColors.greyishNavyBlue,
                                    ),
                                  ),
                                  content: Text(
                                    AppStrings.stopParticipating2,
                                  ),
                                  actions: <Widget>[
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        FlatButton(
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                new BorderRadius.circular(20.0),
                                            side: BorderSide(
                                              width: 3,
                                              color: AppColors.greyishNavyBlue,
                                            ),
                                          ),
                                          onPressed: () async {
                                            Navigator.pop(context);
                                          },
                                          child: Text(AppStrings.cancelText),
                                        ),
                                        Container(
                                          width: 10,
                                        ),
                                        FlatButton(
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                new BorderRadius.circular(20.0),
                                            side: BorderSide(
                                              width: 3,
                                              color: AppColors.greyishNavyBlue,
                                            ),
                                          ),
                                          onPressed: () async {
                                            Future.delayed(
                                              Duration(seconds: 1),
                                              () async {
                                                await RoadsRepository()
                                                    .deleteCompetitorRoad(
                                                  competitorRoad,
                                                );
                                              },
                                            );
                                            Navigator.of(context)
                                                .pushAndRemoveUntil(
                                                    MaterialPageRoute(
                                                        builder: (context) =>
                                                            MyHome()),
                                                    (Route<dynamic> route) =>
                                                        false)
                                                .then(
                                                  (value) => setState(
                                                    () => {},
                                                  ),
                                                );
                                          },
                                          child: Text(
                                              AppStrings.stopParticipating),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              );
                            },
                          );
                        },
                      ),
                    )
                  : ButtonTheme(
                      padding: EdgeInsets.only(
                        right: 20,
                        left: 20,
                      ),
                      minWidth: 200,
                      height: 50.0,
                      child: RaisedButton(
                        shape: RoundedRectangleBorder(
                          borderRadius: new BorderRadius.circular(10.0),
                          side: BorderSide(
                            width: 3,
                            color: AppColors.greyishNavyBlue,
                          ),
                        ),
                        color: _darkTheme == true
                            ? AppColors.greyishNavyBlue
                            : AppColors.white,
                        textColor: AppColors.white,
                        child: Text(
                          AppStrings.joinMe,
                          style: _darkTheme == true
                              ? Styles.joinMeText
                              : Styles.joinMeTextBlack,
                        ),
                        onPressed: () async {
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20.0),
                                  side: BorderSide(
                                    width: 3,
                                    color: AppColors.greyishNavyBlue,
                                  ),
                                ),
                                content: Text(AppStrings.participatingRodada),
                                actions: <Widget>[
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      FlatButton(
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(20.0),
                                          side: BorderSide(
                                            width: 3,
                                            color: AppColors.greyishNavyBlue,
                                          ),
                                        ),
                                        onPressed: () async {
                                          setState(
                                            () {
                                              Navigator.pop(context);
                                            },
                                          );
                                        },
                                        child: Text(AppStrings.cancelText),
                                      ),
                                      Container(
                                        width: 30,
                                      ),
                                      FlatButton(
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              new BorderRadius.circular(20.0),
                                          side: BorderSide(
                                            width: 3,
                                            color: AppColors.greyishNavyBlue,
                                          ),
                                        ),
                                        onPressed: () async {
                                          response = await RoadsRepository()
                                              .joinMeRoad(
                                            userId!,
                                            widget.road.id!,
                                          );
                                          if (response ==
                                              AppStrings.validateGrupo) {
                                            Navigator.pop(
                                              context,
                                            );
                                          } else {
                                            Navigator.of(context)
                                                .pushAndRemoveUntil(
                                                    MaterialPageRoute(
                                                      builder: (context) =>
                                                          MyHome(),
                                                    ),
                                                    (Route<dynamic> route) =>
                                                        false)
                                                .then(
                                                  (value) => setState(
                                                    () => {},
                                                  ),
                                                );
                                          }
                                          setState(
                                            () {
                                              response != null
                                                  ? showDialog(
                                                      context: this.context,
                                                      builder: (BuildContext
                                                          context) {
                                                        return AlertDialog(
                                                          shape:
                                                              RoundedRectangleBorder(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        20.0),
                                                            side: BorderSide(
                                                                width: 3,
                                                                color: AppColors
                                                                    .greyishNavyBlue),
                                                          ),
                                                          content: Text(
                                                            response ??
                                                                AppStrings
                                                                    .errorText,
                                                          ),
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
                                                                        BorderRadius
                                                                            .circular(
                                                                      20.0,
                                                                    ),
                                                                    side:
                                                                        BorderSide(
                                                                      width: 3,
                                                                      color: AppColors
                                                                          .greyishNavyBlue,
                                                                    ),
                                                                  ),
                                                                  onPressed:
                                                                      () async {
                                                                    setState(
                                                                      () {
                                                                        Navigator.pop(
                                                                            context);
                                                                      },
                                                                    );
                                                                  },
                                                                  child: Text(
                                                                    AppStrings
                                                                        .cancelText,
                                                                  ),
                                                                ),
                                                                Container(
                                                                  width: 10,
                                                                ),
                                                                FlatButton(
                                                                  shape:
                                                                      RoundedRectangleBorder(
                                                                    borderRadius:
                                                                        BorderRadius
                                                                            .circular(
                                                                      20.0,
                                                                    ),
                                                                    side:
                                                                        BorderSide(
                                                                      width: 3,
                                                                      color: AppColors
                                                                          .greyishNavyBlue,
                                                                    ),
                                                                  ),
                                                                  onPressed:
                                                                      () async {
                                                                    Navigator.pop(
                                                                        context);
                                                                    await MembersRepository()
                                                                        .joinGroups(
                                                                      userId!,
                                                                      widget
                                                                          .road
                                                                          .group!
                                                                          .id!,
                                                                    );
                                                                    setState(
                                                                      () {
                                                                        validated =
                                                                            1;
                                                                      },
                                                                    );
                                                                  },
                                                                  child: Text(
                                                                    AppStrings
                                                                        .joinGroup,
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                          ],
                                                        );
                                                      },
                                                    )
                                                  : joinMe = 1;
                                            },
                                          );
                                        },
                                        child: Text(AppStrings.joinMe),
                                      )
                                    ],
                                  ),
                                ],
                              );
                            },
                          );
                        },
                      ),
                    ),
            ],
          ),
          Container(
            alignment: Alignment.center,
            padding: EdgeInsets.all(10),
            child: Text(
              AppStrings.participantRodada,
              style: Styles.alertDialogTitle,
            ),
          ),
          joinMe == 1 ? ListParticipantsRoads(widget.road.id!) : Container(),
        ],
      ),
    );
  }

  void _showDialog(Road road) {
    // flutter defined function
    showDialog(
      context: this.context,
      builder: (BuildContext context) {
        // return object of type Dialog
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(
              Radius.circular(
                50.0,
              ),
            ),
          ),
          backgroundColor: AppColors.black54,
          title: new Text(
            AppStrings.ListParticipants,
            style: Styles.alertDialogTitle,
          ),
          content: Container(
            width: 300,
            height: 300,
            child: ListView(
              children: [
                ListParticipantsRoads(
                  widget.road.id!,
                ),
              ],
            ),
          ),
          actions: <Widget>[
            // usually buttons at the bottom of the dialog
            FlatButton(
              child: Text(
                AppStrings.ok,
                style: Styles.alertDialogTitle,
              ),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }

  void showDialog4(BuildContext context, String grupo) {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(
              Radius.circular(50.0),
            ),
          ),
          title: Text(AppStrings.success),
          content: Text(AppStrings.joinGroup2(grupo: grupo)),
          actions: <Widget>[
            FlatButton(
              child: Text(AppStrings.ok),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }
}

class DetailScreen6 extends StatefulWidget {
  final Road road;
  DetailScreen6(this.road);

  @override
  _DetailScreen6State createState() => _DetailScreen6State();
}

class _DetailScreen6State extends State<DetailScreen6> {
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
      appBar: AppBar(
        backgroundColor: AppColors.strongCyan,
        title: Text(AppStrings.coverRodada),
      ),
      body: GestureDetector(
        child: Center(
          child: Hero(
            tag: AppStrings.zoomImagen,
            child: Container(
              child: PhotoView(
                imageProvider: NetworkImage(
                  widget.road.image ?? AppStrings.urlBiuxApp,
                ),
                minScale: PhotoViewComputedScale.contained * 1.0,
                maxScale: PhotoViewComputedScale.covered * 10,
                backgroundDecoration: BoxDecoration(
                  color: AppColors.white,
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
  // void share(BuildContext context, Rodada rodada) {
  //   Share.share(
  //     rodada.portada,
  //   );
  // }
}
