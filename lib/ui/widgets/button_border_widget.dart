import 'package:biux/config/colors.dart';
import 'package:biux/config/strings.dart';
import 'package:biux/config/styles.dart';
import 'package:flutter/material.dart';

class ButtonBorderWidget extends StatelessWidget {
  const ButtonBorderWidget({
    Key? key,
    required this.onPressed,
    required this.text,
    this.bottomLeft = 15,
    this.topLeft = 15,
    this.top = 20,
    this.left = 300,
    this.height = 50,
    this.width = 100,
  }) : super(key: key);
  final Function onPressed;
  final String text;
  final double top;
  final double left;
  final double width;
  final double height;
  final double bottomLeft;
  final double topLeft;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(top: top, left: left, bottom: 20),
      width: width,
      height: height,
      child: RaisedButton(
        shape: RoundedRectangleBorder(
          borderRadius: new BorderRadius.only(
            bottomLeft: Radius.circular(bottomLeft),
            topLeft: Radius.circular(topLeft),
          ),
          side: BorderSide(
            width: 3,
            color: AppColors.strongCyan,
          ),
        ),
        color: AppColors.strongCyan,
        child: Text(text,
          style: Styles.accentTextThemeWhite,
        ),
        onPressed: onPressed(),
      ),
    );
  }
}
