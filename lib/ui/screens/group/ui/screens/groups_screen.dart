import 'package:biux/config/colors.dart';
import 'package:biux/config/styles.dart';
import 'package:biux/config/strings.dart';
import 'package:biux/config/themes/theme.dart';
import 'package:biux/data/models/group.dart';
import 'package:biux/ui/screens/group/ui/screens/group_slider/group_slider.dart';
import 'package:flutter/material.dart';

class GroupsScreen extends StatelessWidget {
  final Group _group;
  final int? id;
  final Function? byEnd;

  GroupsScreen(
    this._group, {
    this.byEnd,
    this.id,
  });
  final ThemeData theme = darkTheme;

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.centerLeft,
      children: <Widget>[
        GestureDetector(
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20.0),
              boxShadow: [
                BoxShadow(
                  color: AppColors.gray.withOpacity(0.8),
                  spreadRadius: 5,
                  blurRadius: 7,
                  offset: Offset(0, 3), // changes position of shadow
                ),
              ],
            ),
            child: SizedBox(
              height: 120,
              child: Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20.0),
                ),
                margin: EdgeInsets.only(left: 46),
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  //  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Container(
                      margin: EdgeInsets.only(left: 70, top: 20),
                      child: Text(
                        _group.name!.toUpperCase(),
                        style: Styles.cardGroupName,
                      ),
                    ),
                    Container(
                      height: 10,
                    ),
                    Container(
                      margin: EdgeInsets.only(left: 70, bottom: 30),
                      child: Row(
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          Column(
                            children: <Widget>[
                              Row(
                                children: <Widget>[
                                  Icon(Icons.supervised_user_circle,
                                      size: 20,
                                      color: AppColors.greyishNavyBlue),
                                  Container(
                                    width: 8,
                                  ),
                                  Text(
                                    _group.numberMembers.toString(),
                                    style: Styles.rowGroupNumberMembers,
                                  ),
                                ],
                              ),
                              Container(
                                child: Text(
                                  AppStrings.followers,
                                  textAlign: TextAlign.start,
                                  style: Styles.columnContainer,
                                ),
                              ),
                            ],
                          ),
                          Container(
                            width: 30,
                          ),
                          Column(
                            children: <Widget>[
                              Row(
                                children: <Widget>[
                                  Icon(Icons.directions_bike,
                                      size: 20,
                                      color: AppColors.greyishNavyBlue),
                                  Container(
                                    width: 8,
                                  ),
                                  Text(
                                    _group.numberRoads.toString(),
                                    style: Styles.rowGroupNumberMembers,
                                  )
                                ],
                              ),
                              Text(
                                AppStrings.rolled,
                                textAlign: TextAlign.start,
                                style: Styles.columnContainer,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          onTap: () async {
            await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => GroupSlider(
                  _group,
                ),
              ),
            );
            if (byEnd != null) {
              byEnd!();
            }
          },
        ),
        Container(
          padding: new EdgeInsets.only(
            top: 10.0,
            bottom: 10,
          ),
          child: Container(
            height: 110,
            width: 110,
            decoration: BoxDecoration(
              color: AppColors.white,
              boxShadow: [
                BoxShadow(
                  color: AppColors.gray.withOpacity(0.8),
                  spreadRadius: 5,
                  blurRadius: 7,
                  offset: Offset(0, 3), // changes position of shadow
                ),
              ],
              image: DecorationImage(
                  image: NetworkImage(
                    _group.logo == null
                        ? AppStrings.urlBiuxApp
                        : _group.logo!,
                  ),
                  fit: BoxFit.cover),
              borderRadius: BorderRadius.circular(12.0),
            ),
          ),
        ),
      ],
    );
  }
}

_onloading() {
  return CircularProgressIndicator();
}
