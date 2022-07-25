import 'package:biux/config/colors.dart';
import 'package:biux/config/strings.dart';
import 'package:biux/config/styles.dart';
import 'package:biux/data/models/advertising.dart';
import 'package:flutter/material.dart';

class AdvertisingTypeAlert extends StatefulWidget {
  final Advertising advertising;
  AdvertisingTypeAlert(this.advertising);
  @override
  _AdvertisingTypeAlertState createState() => _AdvertisingTypeAlertState();
}

class _AdvertisingTypeAlertState extends State<AdvertisingTypeAlert> {
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(
          Radius.circular(50.0),
        ),
      ),
      content: Column(
        children: [
          Container(
            child: Text(widget.advertising.title),
          ),
          Container(
            height: 200,
            width: 200,
            margin: const EdgeInsets.only(left: 20.0, right: 20.0, top: 100),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10.0),
              image: DecorationImage(
                image: NetworkImage(
                  widget.advertising.photoAd,
                  scale: 0.4,
                ),
                fit: BoxFit.fill,
              ),
            ),
          ),
          SizedBox(
            width: 300.0,
            child: Container(
              width: 180,
              margin: EdgeInsets.only(top: 460, left: 70),
              child: RaisedButton(
                elevation: 20,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
                color: AppColors.green,
                child: Text(
                  widget.advertising.textButton,
                  style: Styles.fontSize,
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ),
          ),
        ],
      ),
      actions: <Widget>[
        // usually buttons at the bottom of the dialog
        FlatButton(
          child: new Text(AppStrings.ok),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ],
    );
  }
}
