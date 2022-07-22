import 'package:biux/config/colors.dart';
import 'package:biux/config/images.dart';
import 'package:biux/config/styles.dart';
import 'package:biux/data/models/city.dart';
import 'package:biux/ui/screens/home.dart';
import 'package:biux/ui/screens/login/login.dart';
import 'package:flutter/material.dart';
import 'package:splash_screen_view/SplashScreenView.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  bool loggedIn = false;
  late List<City> city;
  // final PushNotificationsManager pushNotificationsManager =
  //     new PushNotificationsManager();
  void initState() {
    super.initState();
    // pushNotificationsManager.init();
    // pushNotificationsManager.getMessage();
    /*getLoginToken().then(
      (token) => this.setState(
        () => token!.isEmpty ? loggedIn = false : loggedIn = true,
      ),
    );
    */

  }

  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: <Widget>[
          SplashScreenView(
            navigateRoute: loggedIn == true ? MyHome() : LoginPage(),
            duration: 3000,
            imageSize: 130,
            imageSrc: Images.kBiuxLogoLettersWhite,
            text: "",
            textType: TextType.ColorizeAnimationText,
            textStyle: Styles.splashScreenViewText,
            colors: [
              AppColors.purple,
              AppColors.blue,
              AppColors.yellow,
              AppColors.red,
            ],
            backgroundColor: AppColors.greyishNavyBlue2
          ),
        ],
      ),
    );
  }
}
