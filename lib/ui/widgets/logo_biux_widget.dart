import 'package:biux/config/colors.dart';
import 'package:biux/config/styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';

class LogoBiuxWidget extends StatelessWidget {
  LogoBiuxWidget({Key? key, required this.imageLogo, required this.getImage})
      : super(key: key);
  final imageLogo;
  Function getImage;

  @override
  Widget build(BuildContext context) {
    return Stack(children: <Widget>[
      Container(
        margin: EdgeInsets.only(top: 100, left: 20),
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
            height: 110,
            width: 110,
            child: imageLogo == null
                ? new Center(
                  child: new Text('Logo', style: Styles.containerImage),
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
        margin: EdgeInsets.only(top: 180, left: 100),
        child: GestureDetector(
            child: Container(
              height: 30,
              width: 30,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(60.0),
                  color: AppColors.white,
                  boxShadow: [
                    BoxShadow(
                      blurRadius: 1.0,
                      color: AppColors.black,
                    )
                  ]),
              child: Icon(
                Icons.camera_alt_outlined,
                color: AppColors.strongCyan,
                size: 19,
              ),
            ),
            onTap: getImage()),
      ),
    ]);
  }
}
