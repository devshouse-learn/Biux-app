import 'package:biux/config/styles.dart';
import 'package:biux/config/strings.dart';
import 'package:biux/config/themes/theme.dart';
import 'package:biux/data/models/user.dart';
import 'package:flutter/material.dart';

class ButtonUsers extends StatelessWidget {
  final BiuxUser _user;
  final BiuxUser user;
  final Function alTerminar;

  ButtonUsers(this._user, this.user, {required this.alTerminar});
  final ThemeData theme = darkTheme;

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.centerLeft,
      children: <Widget>[
        GestureDetector(
          child: SizedBox(
            height: 50,
            child: Card(
              elevation: 15,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20.0),
              ),
              margin: EdgeInsets.only(left: 40),
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
                          _user.names,
                          style: theme == darkTheme
                              ? Styles.rowItemColordark
                              : Styles.rowItemColorligth,
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
                          _user.surnames,
                          style: theme == darkTheme
                              ? Styles.rowItemColordark
                              : Styles.rowItemColorligth,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    height: 10,
                  ),
                  Container(
                    //   margin: EdgeInsets.only(left: 120),
                    child: Row(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        Container(
                          width: 30,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        Container(
          padding: EdgeInsets.only(
            top: 10.0,
            bottom: 10,
          ),
          child: Container(
            height: 60,
            width: 60,
            decoration: BoxDecoration(
              image: DecorationImage(
                image: NetworkImage(
                  _user.photo == null
                      ? AppStrings.urlDetailGroup
                      : _user.photo,
                ),
                fit: BoxFit.fill,
              ),
              borderRadius: BorderRadius.circular(40.0),
            ),
          ),
        ),
      ],
    );
  }
}
