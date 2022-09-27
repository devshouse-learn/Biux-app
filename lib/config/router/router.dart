import 'package:biux/config/colors.dart';
import 'package:biux/config/router/router_path.dart';
import 'package:biux/config/strings.dart';
import 'package:biux/ui/screens/group/ui/screens/group_create/group_create_BLOC.dart';
import 'package:biux/ui/screens/group/ui/screens/group_create/group_create_screen.dart';
import 'package:biux/ui/screens/group/ui/screens/group_list/group_list_screen.dart';
import 'package:biux/ui/screens/group/ui/screens/group_list/group_list_screen_bloc.dart';
import 'package:biux/ui/screens/group/ui/screens/view_group/view_group_bloc.dart';
import 'package:biux/ui/screens/group/ui/screens/view_group/view_group_screen.dart';
import 'package:biux/ui/screens/login/login.dart';
import 'package:biux/ui/screens/login/login_bloc.dart';
import 'package:biux/ui/screens/main_menu/main_menu.dart';
import 'package:biux/ui/screens/main_menu/main_menu_bloc.dart';
import 'package:biux/ui/screens/roads/ui/screens/roads_list/roads_list_screen.dart';
import 'package:biux/ui/screens/roads/ui/screens/roads_list/roads_list_screen_bloc.dart';
import 'package:biux/ui/screens/splash_screen.dart';
import 'package:biux/ui/screens/story/story_create/story_create_bloc.dart';
import 'package:biux/ui/screens/story/story_create/story_create_screen.dart';
import 'package:biux/ui/screens/story/story_view/story_view_bloc.dart';
import 'package:biux/ui/screens/story/story_view/story_view_screen.dart';
import 'package:biux/ui/screens/user/ui/user_screen/user_screen.dart';
import 'package:biux/ui/screens/user/ui/user_screen/user_screen_bloc.dart';
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
    case AppRoutes.storyCreateRoute:
      return _buildRoute(
          settings: settings,
          builder: ChangeNotifierProvider(
            create: (_) => StoryCreateBloc(),
            child: StoryCreateScreen(),
          ));
    case AppRoutes.viewGroupRoute:
      return _buildRoute(
        settings: settings,
        builder: ChangeNotifierProvider(
          create: (_) => ViewGroupBloc(adminId: args, groupId: args),
          child: ViewGroupScreen(),
        ),
      );
    case AppRoutes.userScreenRoute:
      return _buildRoute(
        settings: settings,
        builder: ChangeNotifierProvider(
          create: (_) => UserScreenBloc(),
          child: UserScreen(),
        ),
      );
    case AppRoutes.mainMenuRoute:
      return _buildRoute(
          settings: settings,
          builder: MultiProvider(
            providers: [
              ChangeNotifierProvider(
                create: (_) => MainMenuBloc(),
              ),
              ChangeNotifierProvider(
                create: (_) => StoryViewBloc(),
              ),
              ChangeNotifierProvider(
                create: (_) => RoadsListScreenBloc(),
              ),
              ChangeNotifierProvider(
                create: (_) => GroupListScreenBloc(),
              ),
            ],
            child: MainMenu(),
          ));
    case AppRoutes.groupListRoute:
      return _buildRoute(
        settings: settings,
        builder: ChangeNotifierProvider(
          create: (_) => GroupListScreenBloc(),
          child: GroupListScreen(),
        ),
      );
    case AppRoutes.viewStoryRoute:
      return _buildRoute(
        settings: settings,
        builder: ChangeNotifierProvider(
          create: (_) => StoryViewBloc(),
          child: StoryViewScreen(),
        ),
      );
    case AppRoutes.roadsListRoute:
      return _buildRoute(
        settings: settings,
        builder: ChangeNotifierProvider(
          create: (_) => RoadsListScreenBloc(),
          child: RoadsListScreen(),
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
