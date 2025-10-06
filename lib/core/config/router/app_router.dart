import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:biux/core/design_system/color_tokens.dart';

// Feature imports (providers)
import '../../../features/groups/presentation/providers/group_provider.dart';
import '../../../features/maps/presentation/providers/location_provider.dart';
import '../../../features/maps/presentation/providers/map_provider.dart';
import '../../../features/maps/presentation/providers/meeting_point_provider.dart';
import '../../../features/rides/presentation/providers/ride_provider.dart';
import '../../../features/users/presentation/providers/user_provider.dart';

// Feature imports (screens)
import '../../../features/experiences/presentation/screens/experiences_list_screen.dart';
import '../../../features/experiences/presentation/screens/create_experience_screen.dart';
import '../../../features/experiences/domain/entities/experience_entity.dart';
import '../../../features/groups/presentation/screens/edit_group/edit_group_screen.dart';
import '../../../features/groups/presentation/screens/group_create/group_create_screen.dart';
import '../../../features/groups/presentation/screens/group_list/group_list_screen.dart';
import '../../../features/groups/presentation/screens/my_groups/my_groups_screen.dart';
import '../../../features/groups/presentation/screens/view_group/view_group_screen.dart';
import '../../../features/authentication/presentation/screens/create_user/create_user_screen.dart';
import '../../../features/authentication/presentation/screens/login_phone.dart';
import '../../../features/maps/presentation/screens/map_screen.dart';
import '../../../features/rides/presentation/screens/create_ride/ride_create_screen.dart';
import '../../../features/rides/presentation/screens/detail_ride/ride_detail_screen.dart';
import '../../../features/rides/presentation/screens/list_rides/ride_list_screen.dart';
import '../../../features/roads/presentation/screens/road_create/map_road/map_road_screen.dart';
import '../../../features/roads/presentation/screens/road_create/road_create_screen.dart';
import '../../../features/roads/presentation/screens/roads_list/roads_list_screen.dart';

import '../../../features/stories/presentation/screens/story_view/story_view_screen.dart';
import '../../../features/users/presentation/screens/edit_user_screen/edit_user_screen.dart';
import '../../../features/users/presentation/screens/profile_screen.dart';
import '../../../features/users/presentation/screens/user_screen/user_screen.dart';

// Shared imports
import '../../../shared/widgets/main_shell.dart';
import '../../../shared/widgets/splash_screen.dart';

import 'app_routes.dart';
import 'auth_notifier.dart';

// Variables globales que persisten durante hot reload
final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>();
final AuthNotifier _authNotifier = AuthNotifier();

// Guard de autenticación (función global)
String? _guard(BuildContext context, GoRouterState state) {
  final bool isLoggedIn = _authNotifier.isLoggedIn;
  final User? user = _authNotifier.user;
  final String location = state.uri.toString();

  print(
    '🔍 Router Guard - Location: $location, isLoggedIn: $isLoggedIn, uid: ${user?.uid}',
  );

  // Si está en la ruta root '/', decidir dónde ir según autenticación
  if (location == '/') {
    if (isLoggedIn) {
      print('📍 Usuario logueado en root, redirigiendo a experiencias');
      return '/stories';
    } else {
      print('📍 Usuario no logueado en root, redirigiendo al login');
      return AppRoutes.login;
    }
  }

  // Rutas públicas (no requieren autenticación)
  final List<String> publicRoutes = [
    AppRoutes.splash,
    AppRoutes.login,
    AppRoutes.createUser,
  ];

  final bool isPublicRoute = publicRoutes.contains(location);

  // Si está en una ruta pública
  if (isPublicRoute) {
    // Si está logueado y trata de ir al login, redirigir a experiencias
    if (isLoggedIn && location == AppRoutes.login) {
      print(
        '📍 Usuario logueado intentando ir al login, redirigiendo a experiencias',
      );
      return '/stories';
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

// GoRouter global que persiste durante hot reload
final GoRouter _router = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: AppRoutes.splash,
  debugLogDiagnostics: false,
  redirect: _guard,
  refreshListenable: _authNotifier,
  routes: [
    // Ruta de splash
    GoRoute(
      path: AppRoutes.splash,
      name: AppRoutes.splashName,
      builder: (context, state) => const SplashScreen(),
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
            ChangeNotifierProvider.value(value: context.read<MapProvider>()),
            ChangeNotifierProvider.value(
              value: context.read<LocationProvider>(),
            ),
            ChangeNotifierProvider.value(
              value: context.read<MeetingPointProvider>(),
            ),
            ChangeNotifierProvider.value(value: context.read<UserProvider>()),
            ChangeNotifierProvider.value(value: context.read<GroupProvider>()),
            ChangeNotifierProvider.value(value: context.read<RideProvider>()),
          ],
          child: MainShell(child: child),
        );
      },
      routes: [
        // Menu principal - redirigir a experiencias
        GoRoute(
          path: AppRoutes.mainMenu,
          name: AppRoutes.mainMenuName,
          redirect: (context, state) => '/stories',
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
              routes: [
                // NUEVA RUTA: Editar grupo
                GoRoute(
                  path: 'edit',
                  name: 'editGroup',
                  builder: (context, state) {
                    final groupId = state.pathParameters['groupId']!;
                    return EditGroupScreen(groupId: groupId);
                  },
                ),
              ],
            ),
          ],
        ),

        // Mis grupos
        GoRoute(
          path: AppRoutes.myGroups,
          name: AppRoutes.myGroupsName,
          builder: (context, state) => MyGroupsScreen(),
        ),

        // Experiencias (antes Historias)
        GoRoute(
          path: '/stories',
          name: 'stories',
          builder: (context, state) => const ExperiencesListScreen(),
          routes: [
            // Crear experiencia
            GoRoute(
              path: 'create',
              name: AppRoutes.storyCreateName,
              builder: (context, state) {
                // Determinar tipo de experiencia desde parámetros
                final typeParam = state.uri.queryParameters['type'];
                final rideId = state.uri.queryParameters['rideId'];
                final experienceType = typeParam == 'ride'
                    ? ExperienceType.ride
                    : ExperienceType.general;

                return CreateExperienceScreen(
                  experienceType: experienceType,
                  rideId: rideId,
                );
              },
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

        // Rutas/Caminos (esta ruta permanece para rutas reales)
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

        // Rodadas (Rides) - esta es la ruta correcta para la pestaña de rodadas
        GoRoute(
          path: '/rides',
          name: 'ridesList',
          builder: (context, state) => RideListScreen(),
          routes: [
            // Crear rodada
            GoRoute(
              path: 'create/:groupId',
              name: 'rideCreate',
              builder: (context, state) {
                final groupId = state.pathParameters['groupId']!;
                return RideCreateScreen(groupId: groupId);
              },
            ),
            // Ver detalles de rodada
            GoRoute(
              path: ':rideId',
              name: 'rideDetail',
              builder: (context, state) {
                final rideId = state.pathParameters['rideId']!;
                return RideDetailScreen(rideId: rideId);
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
          const Icon(Icons.error, size: 64, color: ColorTokens.error50),
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

class AppRouter {
  static GoRouter get router => _router;

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
