import 'package:biux/config/colors.dart';
import 'package:biux/config/router/router_path.dart';
import 'package:biux/config/strings.dart';
import 'package:biux/data/models/group.dart';
import 'package:biux/ui/screens/group/group_create/group_create_bloc.dart';
import 'package:biux/ui/screens/group/group_create/group_create_screen.dart';
import 'package:biux/ui/screens/group/group_list/group_list_screen.dart';
import 'package:biux/ui/screens/group/group_list/group_list_screen_bloc.dart';
import 'package:biux/ui/screens/group/my_groups/my_groups_bloc.dart';
import 'package:biux/ui/screens/group/my_groups/my_groups_screen.dart';
import 'package:biux/ui/screens/group/view_group/view_group_bloc.dart';
import 'package:biux/ui/screens/group/view_group/view_group_screen.dart';
import 'package:biux/ui/screens/login/create_user/create_user_bloc.dart';
import 'package:biux/ui/screens/login/create_user/create_user_screen.dart';
import 'package:biux/ui/screens/login/login_bloc.dart';
import 'package:biux/ui/screens/main_menu/main_menu.dart';
import 'package:biux/ui/screens/main_menu/main_menu_bloc.dart';
import 'package:biux/ui/screens/map/map_screen.dart';
import 'package:biux/ui/screens/map/map_screen_bloc.dart';
import 'package:biux/ui/screens/roads/road_create/map_road/map_road_bloc.dart';
import 'package:biux/ui/screens/roads/road_create/map_road/map_road_screen.dart';
import 'package:biux/ui/screens/roads/road_create/road_create_bloc.dart';
import 'package:biux/ui/screens/roads/road_create/road_create_screen.dart';
import 'package:biux/ui/screens/roads/roads_list/roads_list_screen.dart';
import 'package:biux/ui/screens/roads/roads_list/roads_list_screen_bloc.dart';
import 'package:biux/ui/screens/splash_screen.dart';
import 'package:biux/ui/screens/story/story_create/story_create_bloc.dart';
import 'package:biux/ui/screens/story/story_create/story_create_screen.dart';
import 'package:biux/ui/screens/story/story_view/story_view_bloc.dart';
import 'package:biux/ui/screens/story/story_view/story_view_screen.dart';
import 'package:biux/ui/screens/user/edit_user_screen/edit_user_screen.dart';
import 'package:biux/ui/screens/user/edit_user_screen/edit_user_screen_bloc.dart';
import 'package:biux/ui/screens/user/user_screen/user_screen.dart';
import 'package:biux/ui/screens/user/user_screen/user_screen_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../ui/screens/login/login_phone.dart';

Route<dynamic> generateRoute(RouteSettings settings) {
  final args = settings.arguments;
  switch (settings.name) {
    case AppRoutes.loginRoute:
      return _buildRoute(
        settings: settings,
        builder: ChangeNotifierProvider(
          create: (_) => LoginBloc(),
          child: LoginPhonePage(),
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
      final map = args as Map;
      return _buildRoute(
        settings: settings,
        builder: ChangeNotifierProvider(
          create: (_) => ViewGroupBloc(
            adminId: map['adminId'],
            groupId: map['groupId'],
          ),
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
            ChangeNotifierProvider(
              create: (_) => MapScreenBloc(),
            )
          ],
          child: MainMenu(),
        ),
      );
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
    case AppRoutes.roadCreateRoute:
      final group = args as Group;
      return _buildRoute(
        settings: settings,
        builder: ChangeNotifierProvider(
          create: (_) => RoadCreateBloc(
            group: group,
          ),
          child: RoadCreateScreen(),
        ),
      );
    case AppRoutes.roadMapRoute:
      return _buildRoute(
        settings: settings,
        builder: ChangeNotifierProvider(
          create: (_) => MapRoadBloc(),
          child: MapRoadsLocation(),
        ),
      );
    case AppRoutes.editUserScreenRoute:
      return _buildRoute(
        settings: settings,
        builder: ChangeNotifierProvider(
          create: (_) => EditUserScreenBloc(),
          child: UserEditScreen(),
        ),
      );
    case AppRoutes.createUserRoute:
      return _buildRoute(
        settings: settings,
        builder: ChangeNotifierProvider(
          create: (_) => CreateUserBloc(),
          child: CreateUserScreen(),
        ),
      );
    case AppRoutes.mapScreenRoute:
      return _buildRoute(
        settings: settings,
        builder: ChangeNotifierProvider(
          create: (_) => MapScreenBloc(),
          child: MapScreen(),
        ),
      );
    case AppRoutes.myGroupsRoute:
      return _buildRoute(
        settings: settings,
        builder: ChangeNotifierProvider(
          create: (_) => MyGroupsBloc(),
          child: MyGroupsScreen(),
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
