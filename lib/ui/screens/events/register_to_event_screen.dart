import 'package:biux/config/colors.dart';
import 'package:biux/config/strings.dart';
import 'package:biux/config/styles.dart';
import 'package:flutter/material.dart';

class RegisterToEventScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(AppStrings.titleRegistrationForm),
        ),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(AppStrings.nameText),
            TextField(),
            Text(AppStrings.cedulaText),
            TextField(),
            Row(
              children: <Widget>[
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(AppStrings.ageText),
                    Container(
                      width: 100,
                      child: TextField(),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(AppStrings.epsText),
                    Container(
                      width: 100,
                      child: TextField(),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(AppStrings.rhText),
                    Container(
                      width: 100,
                      child: TextField(),
                    ),
                  ],
                ),
              ],
            ),
            Text(AppStrings.cellPhoneText),
            TextField(),
            Text(
              AppStrings.accidentText,
              style: Styles.accidentText,
            ),
            Row(
              children: <Widget>[
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(AppStrings.nameText),
                    Container(
                      width: 150,
                      child: TextField(),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(AppStrings.phoneText),
                    Container(
                      width: 150,
                      child: TextField(),
                    ),
                  ],
                ),
              ],
            ),
            Text(
              AppStrings.jerseyCaseText,
              style: Styles.accidentText,
            ),
            Row(
              children: <Widget>[
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(AppStrings.sizeText),
                    Container(
                      width: 150,
                      child: TextField(),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(AppStrings.sexText),
                    Container(
                      width: 150,
                      child: TextField(),
                    ),
                  ],
                ),
              ],
            ),
            Align(
              child: ButtonTheme(
                minWidth: 125.0,
                height: 50.0,
                child: RaisedButton(
                  shape: RoundedRectangleBorder(
                    borderRadius: new BorderRadius.circular(25.0),
                    side: BorderSide(width: 3, color: AppColors.lightNavyBlue),
                  ),
                  onPressed: () {},
                  child: Text(
                    AppStrings.payText,
                    style: Styles.sendText,
                  ),
                ),
              ),
            ),
          ],
        ));
  }
}
