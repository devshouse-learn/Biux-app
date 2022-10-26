import 'package:biux/config/colors.dart';
import 'package:biux/config/images.dart';
import 'package:biux/utils/launch_social_networks_utils.dart';
import 'package:flutter/material.dart';
class ButtonFacebookWidget extends StatelessWidget {
   ButtonFacebookWidget(
      {Key? key,
      required this.linkFacebook,
      this.height = 50,
      this.width = 50,
      this.radiusCircular = 15})
      : super(key: key);
  final String facebookLogo = Images.kFacebook;
  final String linkFacebook;
  final double height;
  final double width;
  final double radiusCircular;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => LaunchSocialNetworks().launchFacebook(linkFacebook),
      child: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: new AssetImage(facebookLogo),
            scale: 3,
          ),
          color: AppColors.white,
          borderRadius: BorderRadius.circular(15),
        ),
        height: height,
        width: width,
      ),
    );
  }
}
