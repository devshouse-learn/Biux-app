import 'package:biux/config/colors.dart';
import 'package:biux/config/styles.dart';
import 'package:biux/config/strings.dart';
import 'package:biux/data/models/group.dart';
import 'package:biux/data/models/road.dart';
import 'package:biux/ui/screens/group/ui/screens/group_slider/group_slider.dart';
import 'package:biux/ui/screens/roads/ui/screens/detail_road.dart';
import 'package:biux/ui/widgets/list_participants_roads_widget.dart';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:simple_star_rating/simple_star_rating.dart';
import '../../../../../../config/themes/theme.dart';

class ButtonRoadsGroup extends StatefulWidget {
  final Road road;
  final Group group;
  final Function? byEnd;
  ButtonRoadsGroup(this.road, this.group, {this.byEnd});

  @override
  _ButtonRoadsGroupState createState() => _ButtonRoadsGroupState();
}

class _ButtonRoadsGroupState extends State<ButtonRoadsGroup> {
  ThemeData theme = darkTheme;
  var dates;
  void initState() {
    super.initState();
    todayDate();
    setState(() {});
  }

  todayDate() {
    DateFormat dateFormat = DateFormat(AppStrings.dateFormat);
    DateTime dateTime = dateFormat.parse(widget.road.dateTime);
    var formatter = new DateFormat(AppStrings.dateFormat2);
    dates = DateFormat(AppStrings.dateFormat3).format(dateTime);
    String formattedDate = formatter.format(dateTime);
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    bool is12HoursFormat = MediaQuery.of(context).alwaysUse24HourFormat;
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
                              dates == null ? AppStrings.dateNotFound : dates,
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
                      new Flexible(
                        child: Container(
                          padding: EdgeInsets.only(right: 13.0),
                          child: Text(
                            widget.road.pointmeeting,
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
                            rating: widget.road.routeLevel.toDouble(),
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
                            style: Styles.flexibleDistance,
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
                      _showDialog(
                        widget.road,
                      );
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
              padding: EdgeInsets.only(
                top: 40.0,
                bottom: 1,
                right: 80,
              ),
              child: Row(
                children: <Widget>[
                  GestureDetector(
                    child: Container(
                      height: 90,
                      width: 95,
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          image: NetworkImage(
                            widget.group.logo == null
                                ? AppStrings.urlBiuxApp
                                : widget.group.logo,
                          ),
                          fit: BoxFit.cover,
                        ),
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (BuildContext context) => GroupSlider(
                            widget.group,
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
                left: size.width * 0.10,
              ),
              child: ButtonTheme(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
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
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => DetailRoad(
                          widget.road,
                          dates,
                          widget.group,
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
            ),
          ],
        ),
        Row(
          children: <Widget>[
            GestureDetector(
              child: SizedBox(
                width: 95,
                child: Container(
                  margin: EdgeInsets.only(top: 140, left: 8),
                  child: Text(
                    widget.group.name.toUpperCase(),
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
                      widget.group,
                      member: null,
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

  void _showDialog(Road road) {
    // flutter defined function
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(
              Radius.circular(50.0),
            ),
          ),
          backgroundColor: AppColors.black54,
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
                  widget.road.id,
                ),
              ],
            ),
          ),
          actions: <Widget>[
            // usually buttons at the bottom of the dialog
            new FlatButton(
              child: new Text(
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
