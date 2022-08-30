import 'package:biux/config/colors.dart';
import 'package:biux/config/strings.dart';
import 'package:biux/config/themes/theme.dart';
import 'package:biux/ui/screens/login/create_user/user_dates.dart';
import 'package:flutter/material.dart';

class CreateUserNormalOrPremium extends StatefulWidget {
  final ThemeData theme = darkTheme;
  @override
  CreateUserNormalOrPremiumState createState() =>
      CreateUserNormalOrPremiumState();
}

class CreateUserNormalOrPremiumState extends State<CreateUserNormalOrPremium>
    with SingleTickerProviderStateMixin {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.darkDeepNavyBlue,
        title: Text(AppStrings.profileText),
      ),
      /*bottom: new TabBar(
          
          indicatorColor: AppColors.blueAccent,
          controller: controller,
          tabs: <Tab>[
            new Tab(child: Text("Usuario"),),
            new Tab(child: Text("Premium"),),
           
          ]
        )*/

      body: UserNormal(
          //   controller: controller,
          // children: <Widget>[
          //   new UsuarioNormal(),
          //
          //   new UsuarioPremiun(),

          // ]
          ),
    );
  }
}
