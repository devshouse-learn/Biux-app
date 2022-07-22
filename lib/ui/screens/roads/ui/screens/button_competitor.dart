import 'package:biux/config/colors.dart';
import 'package:biux/config/styles.dart';
import 'package:biux/config/strings.dart';
import 'package:biux/config/themes/theme.dart';
import 'package:biux/data/models/competitor_road.dart';
import 'package:flutter/material.dart';

class ButtonCompetitorRoad extends StatelessWidget {
  final CompetitorRoad _road;
  final Function? byEnd;

  ButtonCompetitorRoad(this._road, {this.byEnd});
  final ThemeData theme = darkTheme;

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.centerLeft,
      children: <Widget>[
        GestureDetector(
          child: SizedBox(
            height: 40,
            child: Card(
              elevation: 15,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20.0),
              ),
              margin: EdgeInsets.only(left: 6),
              child: Column(
                mainAxisSize: MainAxisSize.max,
                //  crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Container(
                        margin: EdgeInsets.only(
                          top: 15,
                        ),
                        child: Text(
                          _road.user!.names!,
                          overflow: TextOverflow.ellipsis,
                          style: Styles.containerNames,
                        ),
                      ),
                      Container(
                        width: 5,
                      ),
                      Container(
                        margin: EdgeInsets.only(
                          top: 15,
                        ),
                        child: Text(
                          _road.user!.surnames!,
                          style: Styles.containerNames,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
        Container(
          padding: new EdgeInsets.only(
            top: 5.0,
          ),
          child: Container(
            height: 40,
            width: 40,
            decoration: BoxDecoration(
              image: DecorationImage(
                image: new NetworkImage(
                  _road.user!.photo == null
                      ? AppStrings.urlBiuxApp
                      : _road.user!.photo!,
                ),
                fit: BoxFit.cover,
              ),
              borderRadius: BorderRadius.circular(40.0),
            ),
          ),
        ),
      ],
    );
  }
}
