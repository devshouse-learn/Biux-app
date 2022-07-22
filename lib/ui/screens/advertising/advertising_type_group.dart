import 'package:biux/config/colors.dart';
import 'package:biux/config/strings.dart';
import 'package:biux/config/styles.dart';
import 'package:biux/config/themes/theme.dart';
import 'package:biux/config/themes/theme_notifier.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AdvertisingTypeGroup extends StatelessWidget {
  // PublicidadTipoGrupo(this._grupo, {this.alTerminar, this.id});
  final ThemeData theme = darkTheme;
  var _darkTheme = true;
  @override
  Widget build(BuildContext context) {
    final themeNotifier = Provider.of<ThemeNotifier>(context);
    _darkTheme = (themeNotifier.getTheme() == darkTheme);
    return Stack(children: <Widget>[
      Container(
        margin: EdgeInsets.all(0),
        alignment: Alignment.center,
        height: 150,
        child: Card(
          color:
              _darkTheme == true ? AppColors.greyishNavyBlue3 : AppColors.white,
          margin: EdgeInsets.only(
            left: 59,
          ),
          elevation: 5,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15.0),
          ),
          child: Container(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  ClipRRect(
                    borderRadius: BorderRadius.circular(15.0),
                    child: Container(
                      height: 25,
                      padding: EdgeInsets.only(
                        left: 60,
                      ),
                      child: Row(
                        children: <Widget>[
                          Container(
                            child: Text(
                              AppStrings.advertising,
                              style: Styles.clipRRectRowWhite,
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Container(
                        alignment: Alignment.center,
                      ),
                      Flexible(
                        child: Container(
                          padding: EdgeInsets.only(
                            right: 13.0,
                            left: 22,
                          ),
                          child: Text(
                            AppStrings.description,
                            overflow: TextOverflow.fade,
                            style: Styles.flexible,
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
                      Container(
                        width: 5,
                      ),
                    ],
                  ),
                  Container(
                    height: 10,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      Row(
        children: <Widget>[
          Container(
            padding: new EdgeInsets.only(
              top: 10.0,
              bottom: 10,
            ),
            child: Container(
              height: 110,
              width: 110,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: NetworkImage(
                    AppStrings.urlAdvertising,
                  ),
                  fit: BoxFit.cover,
                ),
                borderRadius: BorderRadius.circular(12.0),
              ),
            ),
          ),
        ],
      ),
      Container(
        margin: EdgeInsets.only(
          top: 135,
        ),
        child: ButtonTheme(
          // padding: EdgeInsets.only(top: 30),
          shape: RoundedRectangleBorder(
            borderRadius: new BorderRadius.circular(10.0),
            side: BorderSide(width: 3, color: AppColors.lightNavyBlue),
          ),
          minWidth: 35.0,
          height: 35.0,
          child: RaisedButton(
            elevation: 20,
            shape: RoundedRectangleBorder(
              borderRadius: new BorderRadius.circular(10.0),
            ),
            color: AppColors.green,
            child: Text(
              AppStrings.contact,
              style: Styles.fontSize,
            ),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ),
      ),
    ]);
  }
}

_onloanding() {
  return CircularProgressIndicator();
}
