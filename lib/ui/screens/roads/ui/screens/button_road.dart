import 'package:biux/config/colors.dart';
import 'package:biux/config/styles.dart';
import 'package:biux/config/strings.dart';
import 'package:biux/data/models/member.dart';
import 'package:biux/data/models/road.dart';
import 'package:biux/data/models/user.dart';
import 'package:biux/data/models/analitics.dart';
import 'package:biux/ui/screens/group/ui/screens/group_slider/group_slider.dart';
import 'package:biux/ui/screens/roads/ui/screens/detail_road.dart';
import 'package:biux/ui/widgets/list_participants_roads_widget.dart';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:simple_star_rating/simple_star_rating.dart';

class ButtonRoad extends StatefulWidget {
  final Road road;
  final BiuxUser user;

  ButtonRoad(
    this.road,
    this.user,
  );

  @override
  _ButtonRoadState createState() => _ButtonRoadState();
}

class _ButtonRoadState extends State<ButtonRoad> {
  late String dateTime2;
  late String filter1;
  late String filter2;
  late String filter11;
  late String filter22;
  var dates;
  DateTime now = DateTime.now();
  late DateTime dt;

  void initState() {
    super.initState();
    // todayDate();
  }

  // todayDate() {
  //   DateFormat dateFormat = DateFormat('dd-MM-yyyy KK:mm');
  //   // String year = widget.rodada.fechaHora.toString().substring(6, 10);
  //   // String mes = widget.rodada.fechaHora.toString().substring(3, 5);
  //   // String dias = widget.rodada.fechaHora.toString().substring(0, 2);
  //   // String horas = widget.rodada.fechaHora.toString().substring(11, 19);

  //   // dateTime2 = '${year + '-' + mes + '-' + dias + ' ' + horas}';
  //   // dt = DateTime.parse(dateTime2);

  //   DateTime dateTime = dateFormat.parse(widget.rodada.fechaHora!);

  //   var formatter = new DateFormat('dd-MM-yyyy');
  //   widget.rodada.fechaHora = DateFormat('dd-MM-yyyy KK:mm:a').format(dateTime);
  //   var formattedDate = formatter.format(dateTime);
  // }

  var _darkTheme = true;
  @override
  Widget build(BuildContext context) {
    bool is12HoursFormat = MediaQuery.of(context).alwaysUse24HourFormat;
    var size = MediaQuery.of(context).size;
    DateFormat dateFormat = DateFormat(AppStrings.dateFormat);
    // String year = widget.rodada.fechaHora.toString().substring(6, 10);
    // String mes = widget.rodada.fechaHora.toString().substring(3, 5);
    // String dias = widget.rodada.fechaHora.toString().substring(0, 2);
    // String horas = widget.rodada.fechaHora.toString().substring(11, 19);

    // dateTime2 = '${year + '-' + mes + '-' + dias + ' ' + horas}';
    // dt = DateTime.parse(dateTime2);

    DateTime dateTime = dateFormat.parse(widget.road.dateTime!);
    var formatter = new DateFormat(AppStrings.dateFormat2);
    dates = DateFormat(AppStrings.dateFormat3).format(dateTime);
    var formattedDate = formatter.format(dateTime);
    return Stack(
      children: <Widget>[
        Container(
          height: 180,
          child: Card(
            margin: EdgeInsets.only(
              left: 59,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15.0),
            ),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4.0),
                    child: Container(
                      height: 20,
                      padding: EdgeInsets.only(
                        left: 60,
                      ),
                      color: AppColors.greyishNavyBlue,
                      child: Row(
                        children: <Widget>[
                          Container(
                            child: Text(
                              dates,
                              style: Styles.advertisingTitle,
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                  Container(
                    height: 2,
                  ),
                  Row(
                    children: <Widget>[
                      Container(
                        padding: EdgeInsets.only(
                          left: 40,
                        ),
                      ),
                      Text(
                        AppStrings.route,
                        style: Styles.rowGreyishNavyBlue,
                      ),
                      Flexible(
                        child: Container(
                          child: Text(
                            widget.road.name.toString(),
                            overflow: TextOverflow.fade,
                            style: Styles.flexibleBold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  Container(
                    height: 5,
                  ),
                  Row(
                    children: <Widget>[
                      Container(
                        padding: EdgeInsets.only(
                          left: 40,
                        ),
                      ),
                      Text(
                        AppStrings.meeting,
                        style: Styles.rowGreyishNavyBlue,
                      ),
                      Flexible(
                        child: Container(
                          padding: EdgeInsets.only(right: 13.0),
                          child: Text(
                            widget.road.pointmeeting!,
                            overflow: TextOverflow.fade,
                            style: Styles.flexibleBold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  Container(
                    height: 5,
                  ),
                  Row(
                    children: <Widget>[
                      Container(
                        padding: EdgeInsets.only(
                          left: 40,
                        ),
                      ),
                      Text(
                        AppStrings.level,
                        style: Styles.rowGreyishNavyBlue,
                      ),
                      Flexible(
                        child: Container(
                          child: SimpleStarRating(
                            allowHalfRating: true,
                            starCount: 5,
                            rating: widget.road.routeLevel!.toDouble(),
                            size: 10,
                            onRated: (rate) {},
                            spacing: 2,
                          ),
                        ),
                      ),
                      Container(
                        width: 5,
                      ),
                      Text(
                        AppStrings.kmText,
                        style: Styles.rowGreyishNavyBlue,
                      ),
                      Flexible(
                        child: Container(
                          child: Text(
                            widget.road.distance.toString(),
                            overflow: TextOverflow.fade,
                            style: Styles.flexibleBold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  Container(
                    height: 10,
                  ),
                  GestureDetector(
                    child: Row(
                      children: <Widget>[
                        Container(
                          padding: EdgeInsets.only(
                            left: 35,
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
                          style: Styles.gestureDetectorNumberParticipants,
                        ),
                        Container(
                          width: 10,
                        ),
                      ],
                    ),
                    onTap: () {
                      _showDialog(widget.road);
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Container(
              padding: new EdgeInsets.only(
                top: 40.0,
                bottom: 1,
                right: 80,
              ),
              child: Row(
                children: <Widget>[
                  GestureDetector(
                    child: Container(
                      height: 95,
                      width: 95,
                      decoration: BoxDecoration(
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.gray.withOpacity(0.5),
                            spreadRadius: 5,
                            blurRadius: 7,
                            offset: Offset(0, 3), // changes position of shadow
                          ),
                        ],
                        image: DecorationImage(
                          image: new NetworkImage(
                            widget.road.group!.logo == null
                                ? AppStrings.urlBiuxApp
                                : widget.road.group!.logo!,
                          ),
                          fit: BoxFit.cover,
                        ),
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        new MaterialPageRoute(
                          builder: (BuildContext context) => GroupSlider(
                            widget.road.group,
                            member: null,
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
            Container(
              margin: EdgeInsets.only(
                top: 129,
                left: size.width * 0.05,
              ),
              child: ButtonTheme(
                shape: RoundedRectangleBorder(
                  borderRadius: new BorderRadius.circular(8.0),
                  side: BorderSide(
                    width: 0,
                    color: AppColors.greyishNavyBlue,
                  ),
                ),
                minWidth: 35.0,
                height: 35.0,
                child: RaisedButton(
                  color: AppColors.greyishNavyBlue,
                  onPressed: () async {
                    Analitycs.viewRoad(
                      widget.user.userName!,
                      widget.road.name!,
                      widget.user.id!,
                      widget.road.id!,
                      widget.road.pointmeeting!,
                    );
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => DetailRoad(
                          widget.road,
                          dates,
                        ),
                      ),
                    );
                  },
                  child: Text(
                    AppStrings.seeMore,
                    style: Styles.raisedButtonSeeMore,
                  ),
                ),
              ),
            )
          ],
        ),
        Row(
          children: <Widget>[
            GestureDetector(
              child: SizedBox(
                width: 95,
                child: Container(
                  margin: EdgeInsets.only(
                    top: 140,
                    left: 8,
                  ),
                  child: Text(
                    widget.road.group!.name!.toUpperCase(),
                    overflow: TextOverflow.fade,
                    style: Styles.gestureDetectorGroupName,
                  ),
                ),
              ),
              onTap: () {
                Navigator.push(
                  context,
                  new MaterialPageRoute(
                    builder: (BuildContext context) => GroupSlider(
                      widget.road.group,
                      member: Member(),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ],
    );
  }

  void complete(BuildContext context) {
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
                  borderRadius: BorderRadius.all(
                    Radius.circular(
                      10.0,
                    ),
                  ),
                ),
                content: Text(
                  AppStrings.completedProfileBiux, //tituloactual == 0 ? titulo1 : titulo2,
                  textAlign: TextAlign.center,
                  style: Styles.showDialogTitleBlack,
                ),
                actions: <Widget>[
                  // usually buttons at the bottom of the dialog
                  FlatButton(
                    minWidth: 150,
                    color: AppColors.deepNavyBlue,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    child: Text(
                      AppStrings.ok,
                      style: Styles.alignText,
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                  Container(
                    width: 55,
                  )
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _showDialog(Road road) {
    // flutter defined function
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(
              Radius.circular(
                12.0,
              ),
            ),
          ),
          backgroundColor: AppColors.white,
          title: Text(
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
}
