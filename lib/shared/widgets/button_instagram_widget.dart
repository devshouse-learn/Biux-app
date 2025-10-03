import 'package:biux/core/config/images.dart';
import 'package:biux/core/utils/launch_social_networks_utils.dart';
import 'package:flutter/material.dart';

class ButtonInstagramWidget extends StatelessWidget {
  ButtonInstagramWidget(
      {Key? key,
      required this.linkinstagram,
      this.height = 50,
      this.width = 50,
      this.radiusCircular = 15})
      : super(key: key);
  String instagramLogo = Images.kInstagram;
  final String linkinstagram;
  final double height;
  final double width;
  final double radiusCircular;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => LaunchSocialNetworks().launchInstagram(linkinstagram),
      child: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: new AssetImage(instagramLogo),
          ),
        ),
        height: height,
        width: width,
      ),
    );
  }
}
