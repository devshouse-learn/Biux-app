import 'package:biux/config/colors.dart';
import 'package:flutter/material.dart';

class ButtonContinueBiuxWidget extends StatelessWidget {
  ButtonContinueBiuxWidget({
    Key? key,
    required this.onPressed,
  }) : super(key: key);
  final Function onPressed;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: Container(
        margin: EdgeInsets.only(top: 670),
        child: Align(
          alignment: Alignment.bottomCenter,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(60.0),
              boxShadow: [
                BoxShadow(
                  color: AppColors.white,
                  spreadRadius: 10,
                ),
              ],
            ),
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.strongCyan,
              ),
              height: 70,
              width: 70,
              child: Stack(
                children: <Widget>[
                  new Center(
                    child: new Icon(
                      Icons.arrow_forward_rounded,
                      color: AppColors.white,
                      size: 40,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      onTap: onPressed(),
    );
  }
}
