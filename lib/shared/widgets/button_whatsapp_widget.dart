import 'package:biux/core/config/colors.dart';
import 'package:biux/core/config/images.dart';
import 'package:biux/core/utils/launch_social_networks_utils.dart';
import 'package:flutter/material.dart';

class ButtonWhatsappWidget extends StatelessWidget {
  ButtonWhatsappWidget({
    Key? key,
    required this.whatsapp,
    required this.name,
    this.height = 50,
    this.width = 50,
    this.radiusCircular = 15,
  }) : super(key: key);
  final String whatsappLogo = Images.kWhatsapp;
  final String whatsapp;
  final String name;
  final double height;
  final double width;
  final double radiusCircular;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => LaunchSocialNetworks().launchwhatsapp(whatsapp, name),
      child: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: new AssetImage(whatsappLogo),
          ),
          color: AppColors.white,
          borderRadius: BorderRadius.circular(radiusCircular),
        ),
        height: height,
        width: width,
      ),
    );
  }
}
