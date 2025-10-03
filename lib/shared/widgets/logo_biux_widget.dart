import 'package:biux/core/config/colors.dart';
import 'package:biux/core/config/images.dart';
import 'package:flutter/material.dart';

class LogoBiuxWidget extends StatelessWidget {
  LogoBiuxWidget(
      {Key? key,
      required this.imageLogo,
      required this.getImage,
      this.left = 10,
      this.top = 90})
      : super(key: key);
  final imageLogo;
  Function getImage;
  double top;
  double left;

  @override
  Widget build(BuildContext context) {
    return Stack(children: <Widget>[
      Container(
        margin: EdgeInsets.only(top: top, left: left),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(60.0),
          boxShadow: [
            BoxShadow(
              color: AppColors.white,
              spreadRadius: 3,
            )
          ],
        ),
        child: GestureDetector(
          onTap: getImage(),
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.strongCyan,
            ),
            height: 120,
            width: 120,
            child: imageLogo == null
                ? new Center(
                    child: new Image.asset(Images.kBiuxLogoLettersWhite,
                        scale: 20, color: AppColors.white),
                  )
                : Container(
                    alignment: (Alignment(-1.0, 2.5)),
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        fit: BoxFit.cover,
                        image: FileImage(
                          imageLogo.path != null ? imageLogo : getImage,
                        ),
                      ),
                      borderRadius: BorderRadius.all(
                        const Radius.circular(80.0),
                      ),
                    ),
                  ),
          ),
        ),
      ),
      Container(
        margin: EdgeInsets.only(top: 110, left: 210),
        child: GestureDetector(
            child: Container(
              height: 30,
              width: 30,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(60.0),
                  color: AppColors.darkBlue,
                  boxShadow: [
                    BoxShadow(
                      blurRadius: 1.0,
                      color: AppColors.black,
                    )
                  ]),
              child: Icon(
                Icons.add,
                color: AppColors.white,
                size: 25,
              ),
            ),
            onTap: getImage()),
      ),
    ]);
  }
}
