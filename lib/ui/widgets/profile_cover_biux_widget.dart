import 'package:biux/config/colors.dart';
import 'package:biux/config/strings.dart';
import 'package:biux/config/styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';

class ProfileCoverBiuxWidget extends StatelessWidget {
  ProfileCoverBiuxWidget({
    Key? key, required this.imageProfileCover, required this.getProfileCover
  }) : super(key: key);
  final imageProfileCover;
  Function getProfileCover;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(top: 0, left: 0),
      height: 170,
      width: 400,
      child: Stack(
        children: <Widget>[
          imageProfileCover == null
              ? Container()
              : Container(
                  decoration: new BoxDecoration(
                    image: new DecorationImage(
                      image: new FileImage(
                        imageProfileCover.path != null
                            ? imageProfileCover
                            : imageProfileCover,
                      ),
                      fit: BoxFit.cover,
                    ),
                  ),
                  height: 170,
                  width: 400,
                ),
          Padding(
            padding: const EdgeInsets.only(top: 18.0, right: 20),
            child: Align(
              alignment: Alignment.topRight,
              child: SizedBox(
                height: 35,
                width: 135,
                child: RaisedButton(
                  color: AppColors.strongCyan,
                  shape: RoundedRectangleBorder(
                    borderRadius: new BorderRadius.circular(14.0),
                    side: BorderSide(
                      width: 3,
                      color: AppColors.strongCyan,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Icon(
                        Icons.file_upload_outlined,
                        color: AppColors.white,
                        size: 25,
                      ),
                      Text(
                        AppStrings.uploadCover,
                        style: Styles.uploadProfileCoverText,
                      ),
                    ],
                  ),
                  onPressed: getProfileCover(),
                ),
              ),
            ),
          ),
          Container(
            margin: EdgeInsets.only(
              top: 20,
              left: 10,
            ),
            child: Text(
              AppStrings.createGroupText,
              textAlign: TextAlign.center,
              style: Styles.createGroupText,
            ),
          ),
        ],
      ),
    );
  }
}
