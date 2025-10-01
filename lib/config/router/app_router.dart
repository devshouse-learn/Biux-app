import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../providers/location_provider.dart';
import '../../providers/map_provider.dart';
import '../../providers/meeting_point_provider.dart';
import '../../providers/user_provider.dart';
import '../../ui/screens/group/group_create/group_create_screen.dart';
import '../../ui/screens/group/group_list/group_list_screen.dart';
import '../../ui/screens/group/my_groups/my_groups_screen.dart';
import '../../ui/screens/group/view_group/view_group_screen.dart';
import '../../ui/screens/login/create_user/create_user_screen.dart';
import '../../ui/screens/login/login_phone.dart';
import '../../ui/screens/main_shell.dart';
import '../../ui/screens/map/map_screen.dart';
import '../../ui/screens/roads/road_create/map_road/map_road_screen.dart';
import '../../ui/screens/roads/road_create/road_create_screen.dart';
import '../../ui/screens/roads/roads_list/roads_list_screen.dart';
import '../../ui/screens/splash_screen.dart';
import '../../ui/screens/story/story_create/story_create_screen.dart';
import '../../ui/screens/story/story_view/story_view_screen.dart';
import '../../ui/screens/user/edit_user_screen/edit_user_screen.dart';
import '../../ui/screens/user/profile_screen.dart';
import '../../ui/screens/user/user_screen/user_screen.dart';
import 'app_routes.dart';
import 'auth_notifier.dart';

class AppRouter {
  static final GlobalKey<NavigatorState> _rootNavigatorKey =
      GlobalKey<NavigatorState>();
  static final AuthNotifier _authNotifier = AuthNotifier();

  static GoRouter createRouter() {
    return GoRouter(
      navigatorKey: _rootNavigatorKey,
      initialLocation: AppRoutes.splash,
      debugLogDiagnostics: true,
      redirect: _guard,
      refreshListenable: _authNotifier,
      routes: [
        // Ruta de splash
        GoRoute(
          path: AppRoutes.splash,
          name: AppRoutes.splashName,
          builder: (context, state) => SplashScreen(),
        ),

        // Ruta de login
        GoRoute(
          path: AppRoutes.login,
          name: AppRoutes.loginName,
          builder: (context, state) => LoginPhonePage(),
        ),

        // Ruta de crear usuario
        GoRoute(
          path: AppRoutes.createUser,
          name: AppRoutes.createUserName,
          builder: (context, state) => CreateUserScreen(),
        ),

        // Shell principal que envuelve todas las pantallas con AppBar y BottomNavigationBar
        ShellRoute(
          builder: (context, state, child) {
            return MultiProvider(
              providers: [
                ChangeNotifierProvider.value(
                    value: context.read<MapProvider>()),
                ChangeNotifierProvider.value(
                    value: context.read<LocationProvider>()),
                ChangeNotifierProvider.value(
                    value: context.read<MeetingPointProvider>()),
                ChangeNotifierProvider.value(
                    value: context.read<UserProvider>()),
              ],
              child: MainShell(child: child),
            );
          },
          routes: [
            // Menu principal - redirigir al mapa
            GoRoute(
              path: AppRoutes.mainMenu,
              name: AppRoutes.mainMenuName,
              redirect: (context, state) => AppRoutes.map,
            ),

            // Mapa
            GoRoute(
              path: AppRoutes.map,
              name: AppRoutes.mapName,
              builder: (context, state) => MapScreen(),
            ),

            // Perfil
            GoRoute(
              path: AppRoutes.profile,
              name: AppRoutes.profileName,
              builder: (context, state) => ProfileScreen(),
            ),

            // Editar usuario
            GoRoute(
              path: AppRoutes.editUser,
              name: AppRoutes.editUserName,
              builder: (context, state) => UserEditScreen(),
            ),

            // Pantalla de usuario
            GoRoute(
              path: '/user',
              name: 'userScreen',
              builder: (context, state) => UserScreen(),
            ),

            // Grupos
            GoRoute(
              path: AppRoutes.groupList,
              name: AppRoutes.groupListName,
              builder: (context, state) => GroupListScreen(),
              routes: [
                // Crear grupo
                GoRoute(
                  path: 'create',
                  name: AppRoutes.groupCreateName,
                  builder: (context, state) => GroupCreateScreen(),
                ),
                // Ver grupo específico
                GoRoute(
                  path: ':groupId',
                  name: AppRoutes.viewGroupName,
                  builder: (context, state) {
                    return ViewGroupScreen();
                  },
                ),
              ],
            ),

            // Mis grupos
            GoRoute(
              path: AppRoutes.myGroups,
              name: AppRoutes.myGroupsName,
              builder: (context, state) => MyGroupsScreen(),
            ),

            // Historias
            GoRoute(
              path: '/stories',
              name: 'stories',
              builder: (context, state) => const Scaffold(
                body: Center(child: Text('Historias - Próximamente')),
              ),
              routes: [
                // Crear historia
                GoRoute(
                  path: 'create',
                  name: AppRoutes.storyCreateName,
                  builder: (context, state) => StoryCreateScreen(),
                ),
                // Ver historia específica
                GoRoute(
                  path: ':storyId',
                  name: AppRoutes.viewStoryName,
                  builder: (context, state) {
                    return StoryViewScreen();
                  },
                ),
              ],
            ),

            // Rutas/Caminos
            GoRoute(
              path: AppRoutes.roadsList,
              name: AppRoutes.roadsListName,
              builder: (context, state) => RoadsListScreen(),
              routes: [
                // Crear ruta
                GoRoute(
                  path: 'create/:groupId',
                  name: AppRoutes.roadCreateName,
                  builder: (context, state) {
                    return RoadCreateScreen();
                  },
                ),
                // Mapa de ruta
                GoRoute(
                  path: 'map',
                  name: AppRoutes.roadMapName,
                  builder: (context, state) {
                    return MapRoadsLocation();
                  },
                ),
              ],
            ),
          ],
        ),
      ],
      errorBuilder: (context, state) => Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text('Error: ${state.error}'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => context.go(AppRoutes.splash),
                child: const Text('Ir al inicio'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Guard de autenticación
  static String? _guard(BuildContext context, GoRouterState state) {
    // Usar el AuthNotifier para obtener el estado de autenticación
    final bool isLoggedIn = _authNotifier.isLoggedIn;
    final User? user = _authNotifier.user;

    final String location = state.uri.toString();
    print(
        '🔍 Router Guard - Location: $location, isLoggedIn: $isLoggedIn, uid: ${user?.uid}');

    // Rutas públicas (no requieren autenticación)
    final List<String> publicRoutes = [
      AppRoutes.splash,
      AppRoutes.login,
      AppRoutes.createUser,
    ];

    final bool isPublicRoute = publicRoutes.contains(location);

    // Si está en una ruta pública
    if (isPublicRoute) {
      // Si está logueado y trata de ir al login, redirigir al mapa
      if (isLoggedIn && location == AppRoutes.login) {
        print(
            '📍 Usuario logueado intentando ir al login, redirigiendo al mapa');
        return AppRoutes.map;
      }
      // Permitir acceso a rutas públicas
      return null;
    }

    // Para rutas privadas, verificar autenticación
    if (!isLoggedIn) {
      print('🚫 Usuario no autenticado, redirigiendo al login');
      return AppRoutes.login;
    }

    // Usuario autenticado accediendo a ruta privada
    print('✅ Usuario autenticado, permitiendo acceso');
    return null;
  }

  // Método para limpiar el notificador cuando la app se cierre
  static void dispose() {
    _authNotifier.dispose();
  }
}

// Extensiones para facilitar la navegación
extension AppRouterExtension on BuildContext {
  void goToLogin() => go(AppRoutes.login);
  void goToMap() => go(AppRoutes.map);
  void goToProfile() => go(AppRoutes.profile);
  void goToMainMenu() => go(AppRoutes.mainMenu);
  void goToGroupList() => go(AppRoutes.groupList);
  void goToCreateGroup() => go('${AppRoutes.groupList}/create');
  void goToViewGroup(String groupId, {String? adminId}) {
    final uri = Uri(
      path: '${AppRoutes.groupList}/$groupId',
      queryParameters: adminId != null ? {'adminId': adminId} : null,
    );
    go(uri.toString());
  }

  void goToCreateStory() => go('/stories/create');
  void goToViewStory(String storyId) => go('/stories/$storyId');
  void goToRoadsList() => go(AppRoutes.roadsList);
  void goToCreateRoad(String groupId) =>
      go('${AppRoutes.roadsList}/create/$groupId');
}
