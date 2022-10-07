import 'package:biux/config/colors.dart';
import 'package:biux/config/images.dart';
import 'package:biux/config/router/router_path.dart';
import 'package:biux/data/repositories/authentication_repository.dart';
import 'package:easy_splash_screen/easy_splash_screen.dart';
import 'package:flutter/material.dart';

class SplashScreen extends StatelessWidget {
  final bool isLoggedIn = AuthenticationRepository().isLoggedIn;
  Widget build(BuildContext context) {
    return EasySplashScreen(
      logo: Image.asset(
        Images.kBiuxLogoLettersWhite,
      ),
      logoWidth: 130,
      backgroundColor: AppColors.greyishNavyBlue2,
      showLoader: false,
      navigator: isLoggedIn ? AppRoutes.mainMenuRoute : AppRoutes.loginRoute,
      durationInSeconds: 3,
    );
  }
}
