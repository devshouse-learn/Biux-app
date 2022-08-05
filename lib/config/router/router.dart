import 'package:biux/config/colors.dart';
import 'package:biux/config/router/router_path.dart';
import 'package:biux/config/strings.dart';
import 'package:biux/ui/screens/group/ui/screens/group_create/group_create_BLOC.dart';
import 'package:biux/ui/screens/group/ui/screens/group_create/group_create_screen.dart';
import 'package:biux/ui/screens/login/login.dart';
import 'package:biux/ui/screens/login/login_bloc.dart';
import 'package:biux/ui/screens/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

Route<dynamic> generateRoute(RouteSettings settings) {
  final args = settings.arguments;
  switch (settings.name) {
    case AppRoutes.loginRoute:
      return _buildRoute(
        settings: settings,
        builder: ChangeNotifierProvider(
          create: (_) => LoginBloc(),
          child: LoginPage(),
        ),
      );
    case AppRoutes.splashRoute:
      return _buildRoute(
        settings: settings,
        builder: SplashScreen(),
      );
    case AppRoutes.groupCreateRoute:
      return _buildRoute(
        settings: settings,
        builder: ChangeNotifierProvider(
          create: (_) => GroupCreateBloc(),
          child: GroupCreateScreen(),
        ),
      );
    default:
      return _errorRoute();
  }
}

MaterialPageRoute _buildRoute({
  required RouteSettings settings,
  required Widget builder,
}) {
  return MaterialPageRoute(
    settings: settings,
    maintainState: true,
    builder: (_) => AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarIconBrightness: Brightness.dark,
        statusBarColor: ColorsMaster.MAIN_COLOR,
      ),
      child: builder,
    ),
  );
}

Route<dynamic> _errorRoute() {
  return MaterialPageRoute(builder: (_) {
    return Scaffold(
      backgroundColor: ColorsMaster.MAIN_COLOR,
      appBar: AppBar(
        title: Text(AppStrings.pathError),
      ),
      body: Center(
        child: Text(AppStrings.pathError),
      ),
    );
  });
}
