import 'package:biux/features/shop/presentation/screens/add_product_screen.dart';
import 'package:biux/core/services/app_logger.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:go_router/go_router.dart';
import 'package:biux/features/safety/presentation/screens/report_user_screen.dart';
import 'package:biux/features/safety/presentation/screens/biometric_settings_screen.dart';
import 'package:biux/features/safety/presentation/screens/active_sessions_screen.dart';
import 'package:biux/features/age_verification/presentation/screens/parental_consent_screen.dart';
import 'package:biux/features/age_verification/presentation/screens/identity_verification_screen.dart';
import 'package:provider/provider.dart';
import 'package:biux/core/design_system/color_tokens.dart';
import 'package:biux/core/design_system/locale_notifier.dart';
import 'package:biux/core/services/analytics_service.dart';

// Feature imports (providers)
import 'package:biux/features/groups/presentation/providers/group_provider.dart';
import 'package:biux/features/maps/presentation/providers/location_provider.dart';
import 'package:biux/features/maps/presentation/providers/map_provider.dart';
import 'package:biux/features/maps/presentation/providers/meeting_point_provider.dart';
import 'package:biux/features/rides/presentation/providers/ride_provider.dart';
import 'package:biux/features/users/presentation/providers/user_provider.dart';

// Feature imports (screens)
import 'package:biux/features/experiences/presentation/screens/experiences_list_screen.dart';
import 'package:biux/features/experiences/presentation/screens/create_experience_screen.dart';
import 'package:biux/features/experiences/presentation/screens/edit_experience_screen.dart';
import 'package:biux/features/experiences/domain/entities/experience_entity.dart';
import 'package:biux/features/groups/presentation/screens/edit_group/edit_group_screen.dart';
import 'package:biux/features/groups/presentation/screens/group_create/group_create_screen.dart';
import 'package:biux/features/groups/presentation/screens/group_list/group_list_screen.dart';
import 'package:biux/features/groups/presentation/screens/my_groups/my_groups_screen.dart';
import 'package:biux/features/groups/presentation/screens/view_group/view_group_screen.dart';
import 'package:biux/features/authentication/presentation/screens/create_user/create_user_screen.dart';
import 'package:biux/features/authentication/presentation/screens/login_phone_screen.dart';
import 'package:biux/features/maps/presentation/screens/map_screen.dart';
import 'package:biux/features/rides/presentation/screens/create_ride/ride_create_screen.dart';
import 'package:biux/features/rides/presentation/screens/detail_ride/ride_detail_screen.dart';
import 'package:biux/features/rides/presentation/screens/list_rides/ride_list_screen.dart';
import 'package:biux/features/rides/data/models/ride_model.dart';
import 'package:biux/features/roads/presentation/screens/road_create/map_road/map_road_screen.dart';
import 'package:biux/features/roads/presentation/screens/road_create/road_create_screen.dart';
import 'package:biux/features/roads/presentation/screens/roads_list/roads_list_screen.dart';

import 'package:biux/features/social/presentation/screens/post_detail_screen.dart';
import 'package:biux/features/users/presentation/screens/edit_user_screen/edit_user_screen.dart';
import 'package:biux/features/users/presentation/screens/edit_username_screen.dart';
import 'package:biux/features/users/presentation/screens/profile_screen.dart';
import 'package:biux/features/users/presentation/screens/user_screen/user_screen.dart';
import 'package:biux/features/users/presentation/screens/user_search_screen.dart';
import 'package:biux/features/users/presentation/screens/public_user_profile_screen.dart';
import 'package:biux/features/users/presentation/screens/account_settings_screen.dart';
import 'package:biux/features/users/presentation/screens/activity_likes_screen.dart';
import 'package:biux/features/users/presentation/screens/activity_comments_screen.dart';
import 'package:biux/features/users/presentation/screens/activity_posts_screen.dart';
import 'package:biux/features/users/presentation/screens/activity_stories_screen.dart';
import 'package:biux/features/users/presentation/screens/activity_screen_time_screen.dart';

// Bikes imports
import 'package:biux/features/bikes/presentation/screens/my_bikes_screen.dart';
import 'package:biux/features/bikes/presentation/screens/bike_registration_screen.dart';
import 'package:biux/features/bikes/presentation/screens/bike_detail_screen.dart';
import 'package:biux/features/bikes/presentation/screens/public_bike_info_screen.dart';

// Shop imports
import 'package:biux/features/shop/presentation/screens/shop_screen_pro.dart';
import 'package:biux/features/shop/presentation/screens/product_detail_screen.dart';
import 'package:biux/features/shop/presentation/screens/cart_screen.dart';
import 'package:biux/features/shop/presentation/screens/admin_shop_screen.dart';
import 'package:biux/features/shop/presentation/screens/manage_sellers_screen.dart';
import 'package:biux/features/shop/presentation/screens/seller_requests_screen.dart';
import 'package:biux/features/shop/presentation/screens/delete_all_products_screen.dart';
import 'package:biux/features/shop/presentation/screens/favorites_screen.dart';
import 'package:biux/features/shop/presentation/screens/my_orders_screen.dart';
import 'package:biux/features/shop/presentation/screens/stolen_bikes_screen.dart';
import 'package:biux/features/shop/presentation/screens/admin_alerts_screen.dart';
import 'package:biux/features/shop/presentation/screens/bike_qr_screen.dart';

// Store (Tienda Online) imports
import 'package:biux/features/store/presentation/screens/store_screen.dart';
import 'package:biux/features/store/presentation/screens/product_detail_screen.dart'
    as store_detail;
import 'package:biux/features/store/presentation/screens/cart_screen.dart'
    as store_cart;
import 'package:biux/features/store/presentation/screens/seller_dashboard_screen.dart';
import 'package:biux/features/store/presentation/screens/admin_dashboard_screen.dart';
import 'package:biux/features/store/domain/entities/product_entity.dart';

// PENDIENTE: Descomentar cuando se resuelva conflicto de dependencias con mobile_scanner

// Settings imports
import 'package:biux/features/settings/presentation/screens/notification_settings_screen.dart';
import 'package:biux/features/settings/presentation/screens/privacy_details_screen.dart';
import 'package:biux/features/settings/presentation/screens/appearance_details_screen.dart';
import 'package:biux/features/settings/presentation/screens/information_details_screen.dart';

// Help imports
import 'package:biux/features/help/presentation/screens/help_screen.dart';
// Promotions
import 'package:biux/features/promotions/presentation/screens/promotions_screen.dart';

// Social imports
import 'package:biux/features/social/presentation/screens/notifications_screen.dart';
import 'package:biux/features/social/presentation/screens/comments_screen.dart';
import 'package:biux/features/social/presentation/screens/attendees_screen.dart';

// New feature screens
import 'package:biux/features/chat/presentation/screens/chat_list_screen.dart';
import 'package:biux/features/chat/presentation/screens/chat_screen.dart';
import 'package:biux/features/road_reports/presentation/screens/road_reports_screen.dart';
import 'package:biux/features/ride_tracker/presentation/screens/ride_tracker_screen.dart';
import 'package:biux/features/cycling_stats/presentation/screens/cycling_stats_screen.dart';
import 'package:biux/features/emergency/presentation/screens/emergency_screen.dart';
import 'package:biux/features/achievements/presentation/screens/achievements_screen.dart';
import 'package:biux/features/education/presentation/screens/education_screen.dart';

// Shared imports
import 'package:biux/shared/widgets/main_shell.dart';
import 'package:biux/shared/screens/splash_screen.dart';

import 'app_routes.dart';
import 'auth_notifier.dart';
import 'package:biux/features/onboarding/presentation/screens/onboarding_screen.dart';
import 'package:biux/features/onboarding/presentation/screens/welcome_screen.dart';
import 'package:biux/features/search/presentation/screens/global_search_screen.dart';
import 'package:biux/features/social/presentation/screens/followers_screen.dart';
import 'package:biux/features/weather/presentation/screens/weather_screen.dart';
import 'package:biux/features/ride_recommendations/presentation/screens/my_recommendations_screen.dart';
import 'package:biux/features/accidents/presentation/screens/accident_report_screen.dart';
import 'package:biux/features/accidents/presentation/screens/accidents_list_screen.dart';

// Variables globales que persisten durante hot reload
final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>();
final AuthNotifier _authNotifier = AuthNotifier();

/// Convierte URLs de dominio personalizado a rutas internas
/// Ej: https://biux.devshouse.org/ride/123 → /rides/123
String? _convertDeepLinkToRoute(String location) {
  AppLogger.debug('🔗 Intentando convertir deep link: $location');

  try {
    final uri = Uri.parse(location);

    // Manejar dominio personalizado
    if (uri.scheme == 'https' && uri.host == 'biux.devshouse.org') {
      AppLogger.debug('🔗 Detectado app link de biux.devshouse.org');
      AppLogger.debug('🔗 Path: ${uri.path}, Segments: ${uri.pathSegments}');

      // https://biux.devshouse.org/ride/{rideId} → /rides/{rideId}
      if (uri.path.startsWith('/ride/')) {
        final rideId = uri.pathSegments.length > 1 ? uri.pathSegments[1] : null;
        if (rideId != null && rideId.isNotEmpty) {
          final newRoute = '/rides/$rideId';
          AppLogger.info('✅ Ruta convertida: $location → $newRoute');
          return newRoute;
        }
      }

      // https://biux.devshouse.org/rides/{rideId} → /rides/{rideId}
      if (uri.path.startsWith('/rides/')) {
        final rideId = uri.pathSegments.length > 1 ? uri.pathSegments[1] : null;
        if (rideId != null && rideId.isNotEmpty) {
          final newRoute = '/rides/$rideId';
          AppLogger.info('✅ Ruta convertida: $location → $newRoute');
          return newRoute;
        }
      }

      // https://biux.devshouse.org/posts/{postId} → /stories
      if (uri.path.startsWith('/posts/')) {
        AppLogger.info('✅ Ruta convertida: $location → /stories');
        return '/stories';
      }

      // https://biux.devshouse.org/stories/{storyId} → /stories
      if (uri.path.startsWith('/stories/')) {
        AppLogger.info('✅ Ruta convertida: $location → /stories');
        return '/stories';
      }

      // https://biux.devshouse.org/group/{groupId} → /groups/{groupId}
      if (uri.path.startsWith('/group/')) {
        final groupId = uri.pathSegments.length > 1
            ? uri.pathSegments[1]
            : null;
        if (groupId != null && groupId.isNotEmpty) {
          final newRoute = '/groups/$groupId';
          AppLogger.info('✅ Ruta convertida: $location → $newRoute');
          return newRoute;
        }
      }

      // https://biux.devshouse.org/user/{userId} → /user-profile/{userId}
      if (uri.path.startsWith('/user/')) {
        final userId = uri.pathSegments.length > 1 ? uri.pathSegments[1] : null;
        if (userId != null && userId.isNotEmpty) {
          final newRoute = '/user-profile/$userId';
          AppLogger.info('✅ Ruta convertida: $location → $newRoute');
          return newRoute;
        }
      }
    }

    // Manejar esquema biux://
    if (uri.scheme == 'biux') {
      AppLogger.debug('🔗 Detectado deep link con esquema biux://');

      // biux://ride/{rideId}
      if (uri.host == 'ride') {
        final rideId = uri.pathSegments.isNotEmpty
            ? uri.pathSegments.first
            : null;
        if (rideId != null && rideId.isNotEmpty) {
          final newRoute = '/rides/$rideId';
          AppLogger.info('✅ Ruta convertida: $location → $newRoute');
          return newRoute;
        }
      }

      // biux://group/{groupId}
      if (uri.host == 'group') {
        final groupId = uri.pathSegments.isNotEmpty
            ? uri.pathSegments.first
            : null;
        if (groupId != null && groupId.isNotEmpty) {
          final newRoute = '/groups/$groupId';
          AppLogger.info('✅ Ruta convertida: $location → $newRoute');
          return newRoute;
        }
      }

      // biux://user/{userId} o biux://user-profile/{userId}
      if (uri.host == 'user' || uri.host == 'user-profile') {
        final userId = uri.pathSegments.isNotEmpty
            ? uri.pathSegments.first
            : null;
        if (userId != null && userId.isNotEmpty) {
          final newRoute = '/user-profile/$userId';
          AppLogger.info('✅ Ruta convertida: $location → $newRoute');
          return newRoute;
        }
      }
    }
  } catch (e) {
    AppLogger.error('❌ Error al procesar deep link: $e');
  }

  return null;
}

// Guard de autenticación (función global)
String? _guard(BuildContext context, GoRouterState state) {
  final bool isLoggedIn = _authNotifier.isLoggedIn;
  final User? user = _authNotifier.user;
  final String location = state.uri.toString();

  AppLogger.debug(
    '🔍 Router Guard - Location: $location, isLoggedIn: $isLoggedIn, uid: ${user?.uid}',
  );

  // EN WEB: Permitir acceso sin autenticación
  if (kIsWeb) {
    AppLogger.debug('🌐 WEB: Permitiendo acceso sin autenticación');

    // Si está en root, redirigir a las rutas
    if (location == '/') {
      AppLogger.debug('📍 Root en web, redirigiendo a rutas');
      return '/roads';
    }

    // Permitir acceso libre a todas las rutas en web
    return null;
  }

  // PRIMERO: Intentar convertir deep links a rutas internas
  String effectiveLocation = location;
  final convertedRoute = _convertDeepLinkToRoute(location);
  if (convertedRoute != null) {
    effectiveLocation = convertedRoute;
    AppLogger.debug('🔗 Deep link convertido: $location → $effectiveLocation');
  }

  // Si está en la ruta root '/', decidir dónde ir según autenticación
  if (effectiveLocation == '/') {
    if (isLoggedIn) {
      AppLogger.debug('📍 Usuario logueado en root, redirigiendo a inicio');
      return '/stories';
    } else {
      AppLogger.debug('📍 Usuario no logueado en root, redirigiendo al login');
      return AppRoutes.login;
    }
  }

  // Rutas públicas (no requieren autenticación)
  final List<String> publicRoutes = [
    AppRoutes.splash,
    AppRoutes.login,
    AppRoutes.createUser,
  ];

  final bool isPublicRoute = publicRoutes.contains(effectiveLocation);

  // Si está en una ruta pública
  if (isPublicRoute) {
    // Si está logueado y trata de ir al login, redirigir a experiencias
    if (isLoggedIn && effectiveLocation == AppRoutes.login) {
      AppLogger.debug(
        '📍 Usuario logueado intentando ir al login, redirigiendo a experiencias',
      );
      return '/stories';
    }
    // Permitir acceso a rutas públicas
    return null;
  }

  // Para rutas privadas, verificar autenticación
  if (!isLoggedIn) {
    AppLogger.debug('🚫 Usuario no autenticado, redirigiendo al login');
    return AppRoutes.login;
  }

  // Usuario autenticado accediendo a ruta privada
  // Si hubo conversión de deep link, redirigir a la ruta convertida
  if (convertedRoute != null) {
    AppLogger.debug(
      '✅ Usuario autenticado, redirigiendo a ruta convertida: $convertedRoute',
    );
    return convertedRoute;
  }

  AppLogger.info('✅ Usuario autenticado, permitiendo acceso');
  return null;
}

// GoRouter global que persiste durante hot reload
final GoRouter _router = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: '/splash',
  debugLogDiagnostics: false,
  observers: [AnalyticsService.observer],
  redirect: _guard,
  refreshListenable: _authNotifier,
  routes: [
    // Ruta de splash
    GoRoute(
      path: AppRoutes.splash,
      name: AppRoutes.splashName,
      builder: (context, state) => const SplashScreen(),
    ),

    // Welcome post-registro
    GoRoute(
      path: '/welcome',
      name: 'welcome',
      builder: (context, state) => const WelcomeScreen(),
    ),

    // Onboarding
    GoRoute(
      path: AppRoutes.onboarding,
      name: AppRoutes.onboardingName,
      builder: (context, state) => const OnboardingScreen(),
    ),

    // Ruta de login (N8N Webhook original)
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

        // Editar nombre de usuario
        GoRoute(
          path: '/edit-username',
          name: 'editUsername',
          builder: (context, state) => const EditUsernameScreen(),
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
                // NUEVA RUTA: Rodadas de un grupo
                GoRoute(
                  path: 'rides',
                  name: 'groupRides',
                  builder: (context, state) {
                    final groupId = state.pathParameters['groupId']!;
                    return RideListScreen(groupId: groupId);
                  },
                ),
                // NUEVA RUTA: Editar rodada
                GoRoute(
                  path: 'rides/edit',
                  name: 'rideEdit',
                  builder: (context, state) {
                    final groupId = state.pathParameters['groupId']!;
                    final rideToEdit = state.extra as RideModel?;
                    return RideCreateScreen(
                      groupId: groupId,
                      rideToEdit: rideToEdit,
                    );
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
            // Ver detalle de post/experiencia (DEBE IR ANTES DE :storyId)
            GoRoute(
              path: 'post/:postId',
              name: 'postDetail',
              pageBuilder: (context, state) {
                final postId = state.pathParameters['postId']!;
                return MaterialPage(
                  key: ValueKey('postDetail_$postId'),
                  child: PostDetailScreen(postId: postId),
                );
              },
            ),
            // Ver historia específica — redirigir a detalle de post
            GoRoute(
              path: ':storyId',
              name: AppRoutes.viewStoryName,
              builder: (context, state) {
                final storyId = state.pathParameters['storyId']!;
                return PostDetailScreen(postId: storyId);
              },
            ),
          ],
        ),

        // Editar publicación/experiencia
        GoRoute(
          path: '/edit-post/:postId',
          name: 'editPost',
          builder: (context, state) {
            final l = Provider.of<LocaleNotifier>(context, listen: false);
            // ignore: unused_local_variable
            final postId = state.pathParameters['postId']!;
            final experience = state.extra as ExperienceEntity?;
            if (experience == null) {
              return Scaffold(
                body: Center(child: Text(l.t('error_post_not_found'))),
              );
            }
            return EditExperienceScreen(experience: experience);
          },
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
                final extra = state.extra as Map<String, dynamic>?;
                final openComments = extra?['openComments'] as bool? ?? false;
                return RideDetailScreen(
                  rideId: rideId,
                  openComments: openComments,
                );
              },
            ),
          ],
        ),

        // Bicicletas
        GoRoute(
          path: AppRoutes.myBikes,
          name: AppRoutes.myBikesName,
          builder: (context, state) => const MyBikesScreen(),
        ),

        // Registro de bicicleta
        GoRoute(
          path: AppRoutes.bikeRegistration,
          name: AppRoutes.bikeRegistrationName,
          builder: (context, state) => const BikeRegistrationScreen(),
        ),

        // Detalle de bicicleta
        GoRoute(
          path: AppRoutes.bikeDetail,
          name: AppRoutes.bikeDetailName,
          builder: (context, state) {
            final bikeId = state.pathParameters['bikeId']!;
            return BikeDetailScreen(bikeId: bikeId);
          },
        ),

        // Información pública de bicicleta (acceso por QR)
        GoRoute(
          path: AppRoutes.publicBikeInfo,
          name: AppRoutes.publicBikeInfoName,
          builder: (context, state) {
            final qrCode = state.pathParameters['qrCode']!;
            return PublicBikeInfoScreen(qrCode: qrCode);
          },
        ),

        // ===== SETTINGS =====

        // ===== SOCIAL FEATURES =====

        // Comentarios de rodadas
        GoRoute(
          path: '/rides/:rideId/comments',
          name: 'rideComments',
          builder: (context, state) {
            final rideId = state.pathParameters['rideId']!;
            final ownerId = state.uri.queryParameters['ownerId']!;

            return RideCommentsScreen(rideId: rideId, rideOwnerId: ownerId);
          },
        ),

        // Asistentes de rodadas
        GoRoute(
          path: '/rides/:rideId/attendees',
          name: 'rideAttendees',
          builder: (context, state) {
            final rideId = state.pathParameters['rideId']!;
            final ownerId = state.uri.queryParameters['ownerId']!;

            return RideAttendeesScreen(rideId: rideId, rideOwnerId: ownerId);
          },
        ),

        // ===== SHOP/TIENDA =====

        // Tienda principal
        GoRoute(
          path: '/shop',
          name: 'shop',
          builder: (context, state) {
            final searchQuery = state.uri.queryParameters['search'];
            return ShopScreenPro(initialSearch: searchQuery);
          },
        ),

        // ⚠️ IMPORTANTE: Las rutas específicas DEBEN ir ANTES de /shop/:id
        // para evitar que el parámetro :id capture 'cart', 'favorites', 'orders', etc.

        // Carrito de compras
        GoRoute(
          path: '/shop/cart',
          name: 'cart',
          builder: (context, state) => const CartScreen(),
        ),

        // Mis Favoritos
        GoRoute(
          path: '/shop/favorites',
          name: 'favorites',
          builder: (context, state) => const FavoritesScreen(),
        ),

        // Mis Pedidos
        GoRoute(
          path: '/shop/orders',
          name: 'myOrders',
          builder: (context, state) => const MyOrdersScreen(),
        ),

        // Panel de administración (solo admins)
        GoRoute(
          path: '/shop/admin',
          name: 'adminShop',
          builder: (context, state) => const AdminShopScreen(),
          // PENDIENTE: Agregar redirect cuando UserEntity tenga isAdmin
          // redirect: (context, state) {
          //   final userProvider = context.read<UserProvider>();
          //   final isAdmin = userProvider.user?.isAdmin ?? false;
          //   return isAdmin ? null : '/shop';
          // },
        ),

        // Gestión de vendedores (solo admins) - DEBE IR ANTES DE /shop/:id
        GoRoute(
          path: '/shop/manage-sellers',
          name: 'manageSellers',
          builder: (context, state) => const ManageSellersScreen(),
        ),

        // Solicitudes de vendedores (solo admins) - DEBE IR ANTES DE /shop/:id
        GoRoute(
          path: '/shop/seller-requests',
          name: 'sellerRequests',
          builder: (context, state) => const SellerRequestsScreen(),
        ),

        // Eliminar todos los productos (solo admins) - DEBE IR ANTES DE /shop/:id
        GoRoute(
          path: '/shop/delete-all-products',
          name: 'deleteAllProducts',
          builder: (context, state) => const DeleteAllProductsScreen(),
        ),

        // Dashboard de alertas para administradores - DEBE IR ANTES DE /shop/:id
        GoRoute(
          path: '/shop/admin-alerts',
          name: 'adminAlerts',
          builder: (context, state) => const AdminAlertsScreen(),
        ),

        // Código QR de bicicleta verificada - DEBE IR ANTES DE /shop/:id
        GoRoute(
          path: '/shop/bike-qr/:productId',
          name: 'bikeQR',
          builder: (context, state) {
            final productId = state.pathParameters['productId']!;
            final extra = state.extra as Map<String, dynamic>?;

            return BikeQRScreen(
              productId: productId,
              frameSerial: extra?['frameSerial'] ?? '',
              verificationDate: extra?['verificationDate'] ?? DateTime.now(),
              verifierUid: extra?['verifierUid'] ?? '',
              bikeBrand: extra?['bikeBrand'],
              bikeModel: extra?['bikeModel'],
              bikeColor: extra?['bikeColor'],
            );
          },
        ),

        // ⚠️ Detalle de producto movido FUERA del ShellRoute (ver abajo)

        // PENDIENTE: Descomentar cuando se resuelva conflicto de dependencias con mobile_scanner
        // Escáner QR
        // GoRoute(
        //   path: '/shop/qr-scanner',
        //   name: 'qrScanner',
        //   builder: (context, state) => const QRScannerScreen(),
        // ),

        // ===== STORE (TIENDA ONLINE) ROUTES =====

        // Tienda principal
        GoRoute(
          path: '/store',
          name: 'store',
          builder: (context, state) => const StoreScreen(),
        ),

        // Detalle de producto
        GoRoute(
          path: '/store/product/:productId',
          name: 'storeProductDetail',
          builder: (context, state) {
            final product = state.extra as ProductEntity;
            return store_detail.ProductDetailScreen(product: product);
          },
        ),

        // Carrito de compras
        GoRoute(
          path: '/store/cart',
          name: 'storeCart',
          builder: (context, state) => const store_cart.CartScreen(),
        ),

        // Panel de vendedor
        GoRoute(
          path: '/store/seller-dashboard',
          name: 'sellerDashboard',
          builder: (context, state) {
            final l = Provider.of<LocaleNotifier>(context, listen: false);
            final userProvider = context.read<UserProvider>();
            final currentUser = userProvider.user;

            if (currentUser == null) {
              return Scaffold(
                body: Center(child: Text(l.t('error_user_not_found'))),
              );
            }

            return SellerDashboardScreen(currentUser: currentUser.toEntity());
          },
        ),

        // Seguidores/Siguiendo
        GoRoute(
          path: '/users/:userId/followers',
          name: 'followers',
          builder: (context, state) {
            final userId = state.pathParameters['userId']!;
            final showFollowers =
                state.uri.queryParameters['tab'] != 'following';
            return FollowersScreen(
              userId: userId,
              showFollowers: showFollowers,
            );
          },
        ),

        // Panel de administración
        GoRoute(
          path: '/store/admin-dashboard',
          name: 'storeAdminDashboard',
          builder: (context, state) {
            final l = Provider.of<LocaleNotifier>(context, listen: false);
            final userProvider = context.read<UserProvider>();
            final currentUser = userProvider.user;

            if (currentUser == null) {
              return Scaffold(
                body: Center(child: Text(l.t('error_user_not_found'))),
              );
            }

            return AdminDashboardScreen(currentUser: currentUser.toEntity());
          },
        ),
      ],
    ),

    // Rutas fuera del shell principal

    // Notificaciones
    GoRoute(
      path: '/notifications',
      name: 'notifications',
      builder: (context, state) => const NotificationsScreen(),
    ),

    // Buscar usuarios
    GoRoute(
      path: AppRoutes.userSearch,
      name: AppRoutes.userSearchName,
      builder: (context, state) => UserSearchScreen(),
    ),

    // Perfil de usuario específico
    GoRoute(
      path: AppRoutes.userProfile,
      name: AppRoutes.userProfileName,
      builder: (context, state) {
        final userId = state.pathParameters['userId']!;
        return PublicUserProfileScreen(userId: userId);
      },
    ),

    // Búsqueda global
    GoRoute(
      path: '/search',
      name: 'globalSearch',
      builder: (context, state) => const GlobalSearchScreen(),
    ),

    // Chat (fuera del ShellRoute para ocultar bottom nav)
    GoRoute(
      path: AppRoutes.chatList,
      name: AppRoutes.chatListName,
      builder: (context, state) => const ChatListScreen(),
    ),
    GoRoute(
      path: '/chat/:chatId',
      name: AppRoutes.chatDetailName,
      builder: (context, state) {
        final chatId = state.pathParameters['chatId']!;
        // Crear ChatEntity mínimo con el id para navegación directa
        return ChatScreen.fromId(chatId: chatId);
      },
    ),

    // Road Reports
    GoRoute(
      path: AppRoutes.roadReports,
      name: AppRoutes.roadReportsName,
      builder: (context, state) => const RoadReportsScreen(),
    ),

    // Ride Tracker (Grabar rodadas)
    GoRoute(
      path: AppRoutes.rideTracker,
      name: AppRoutes.rideTrackerName,
      builder: (context, state) =>
          RideTrackerScreen(showHistory: state.extra == true),
    ),
    GoRoute(
      path: AppRoutes.rideRecommendations,
      name: AppRoutes.rideRecommendationsName,
      builder: (context, state) => const MyRecommendationsScreen(),
    ),

    // Cycling Stats (Mis estadísticas)
    GoRoute(
      path: AppRoutes.cyclingStats,
      name: AppRoutes.cyclingStatsName,
      builder: (context, state) => const CyclingStatsScreen(),
    ),

    // Emergency SOS
    GoRoute(
      path: AppRoutes.reportUser,
      builder: (context, state) {
        final extra = state.extra as Map<String, dynamic>? ?? {};
        return ReportUserScreen(
          reportedUserId:
              extra['userId'] ?? state.pathParameters['userId'] ?? '',
          reportedUserName: extra['userName'] ?? 'Usuario',
        );
      },
    ),
    GoRoute(
      path: AppRoutes.biometricSettings,
      builder: (context, state) => const BiometricSettingsScreen(),
    ),
    GoRoute(
      path: AppRoutes.activeSessions,
      builder: (context, state) => const ActiveSessionsScreen(),
    ),
    GoRoute(
      path: AppRoutes.parentalConsent,
      builder: (context, state) {
        final extra = state.extra as Map<String, dynamic>? ?? {};
        return ParentalConsentScreen(
          userId: extra['userId'] ?? '',
          userAge: extra['userAge'] ?? 15,
        );
      },
    ),
    GoRoute(
      path: AppRoutes.identityVerification,
      builder: (context, state) {
        final extra = state.extra as Map<String, dynamic>? ?? {};
        return IdentityVerificationScreen(userId: extra['userId'] ?? '');
      },
    ),
    GoRoute(
      path: AppRoutes.emergency,
      name: AppRoutes.emergencyName,
      builder: (context, state) => const EmergencyScreen(),
    ),

    // Achievements (Logros)
    GoRoute(
      path: AppRoutes.achievements,
      name: AppRoutes.achievementsName,
      builder: (context, state) => const AchievementsScreen(),
    ),

    // Promotions (Negocios y eventos)
    GoRoute(
      path: '/promotions',
      name: 'promotions',
      builder: (context, state) => const PromotionsScreen(),
    ),

    // Bicicletas robadas
    GoRoute(
      path: '/shop/stolen-bikes',
      name: 'stolenBikes',
      builder: (context, state) => const StolenBikesScreen(),
    ),

    // Education (Educación vial)
    GoRoute(
      path: AppRoutes.education,
      name: AppRoutes.educationName,
      builder: (context, state) => const EducationScreen(),
    ),

    // Clima
    GoRoute(
      path: '/weather',
      name: 'weather',
      builder: (context, state) => const WeatherScreen(),
    ),

    // Reportar Accidente
    GoRoute(
      path: '/accidents/report',
      name: 'accidentReport',
      builder: (context, state) => const AccidentReportScreen(),
    ),

    // Lista de accidentes
    GoRoute(
      path: '/accidents',
      builder: (context, state) => const AccidentsListScreen(),
    ),

    // Configuración de notificaciones
    GoRoute(
      path: AppRoutes.notificationSettings,
      name: AppRoutes.notificationSettingsName,
      builder: (context, state) => const NotificationSettingsScreen(),
    ),

    // Ayuda y soporte (Centro de ayuda)
    GoRoute(
      path: AppRoutes.help,
      name: AppRoutes.helpName,
      builder: (context, state) => const HelpScreen(),
    ),

    // Configuración de Cuenta (fuera del ShellRoute para ocultar bottom nav)
    GoRoute(
      path: AppRoutes.accountSettings,
      name: AppRoutes.accountSettingsName,
      builder: (context, state) => const AccountSettingsScreen(),
    ),

    // Settings sub-screens
    GoRoute(
      path: '/settings/privacy',
      name: 'settingsPrivacy',
      builder: (context, state) => const PrivacyDetailsScreen(),
    ),
    GoRoute(
      path: '/settings/appearance',
      name: 'settingsAppearance',
      builder: (context, state) => const AppearanceDetailsScreen(),
    ),
    GoRoute(
      path: '/settings/information',
      name: 'settingsInformation',
      builder: (context, state) => const InformationDetailsScreen(),
    ),

    // Pantallas de Tu Actividad
    GoRoute(
      path: '/activity/likes',
      name: 'activityLikes',
      builder: (context, state) => const ActivityLikesScreen(),
    ),
    GoRoute(
      path: '/activity/comments',
      name: 'activityComments',
      builder: (context, state) => const ActivityCommentsScreen(),
    ),
    GoRoute(
      path: '/activity/posts',
      name: 'activityPosts',
      builder: (context, state) => const ActivityPostsScreen(),
    ),
    GoRoute(
      path: '/activity/stories',
      name: 'activityStories',
      builder: (context, state) => const ActivityStoriesScreen(),
    ),

    // Comentarios de posts (fuera del ShellRoute para funcionar desde post-detail standalone)
    GoRoute(
      path: '/posts/:postId/comments',
      name: 'postComments',
      builder: (context, state) {
        final postId = state.pathParameters['postId']!;
        final ownerId = state.uri.queryParameters['ownerId'] ?? '';
        return PostCommentsScreen(postId: postId, postOwnerId: ownerId);
      },
    ),

    // Ver detalle de post (fuera del ShellRoute para evitar conflicto de navigator)
    GoRoute(
      path: '/post-detail/:postId',
      name: 'postDetailStandalone',
      pageBuilder: (context, state) {
        final postId = state.pathParameters['postId']!;
        return MaterialPage(
          key: ValueKey('postDetailStandalone_$postId'),
          child: PostDetailScreen(postId: postId),
        );
      },
    ),

    GoRoute(
      path: '/activity/screen-time',
      name: 'activityScreenTime',
      builder: (context, state) => const ActivityScreenTimeScreen(),
    ),

    // Detalle de producto (fuera del shell para pantalla completa sin bottom nav)
    // Ruta para agregar producto (debe ir ANTES de /shop/:id)
    GoRoute(
      path: '/shop/add-product',
      name: 'addProduct',
      builder: (context, state) => const AddProductScreen(),
    ),
    GoRoute(
      path: '/shop/:id',
      name: 'productDetail',
      builder: (context, state) {
        final productId = state.pathParameters['id']!;
        return ProductDetailScreen(productId: productId);
      },
    ),
  ],
  errorBuilder: (context, state) => Scaffold(
    body: Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error, size: 64, color: ColorTokens.error50),
          const SizedBox(height: 16),
          Text(
            '${Provider.of<LocaleNotifier>(context, listen: false).t('error_generic')}: ${state.error}',
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => context.go(AppRoutes.splash),
            child: Text(
              Provider.of<LocaleNotifier>(
                context,
                listen: false,
              ).t('go_to_home'),
            ),
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

  // Navegación de bicicletas
  void goToMyBikes() => go(AppRoutes.myBikes);
  void goToBikeRegistration() => go(AppRoutes.bikeRegistration);
  void goToBikeDetail(String bikeId) => go('/bikes/$bikeId');
  void goToPublicBikeInfo(String qrCode) => go('/bikes/public/$qrCode');

  // Navegación social
  void goToNotifications() => push('/notifications');
  void goToPostComments(String postId, String ownerId) =>
      go('/posts/$postId/comments?ownerId=$ownerId');
  void goToRideComments(String rideId, String ownerId) =>
      go('/rides/$rideId/comments?ownerId=$ownerId');

  // Navegacion nuevas funcionalidades
  void goToChat() => push(AppRoutes.chatList);
  void goToChatDetail(String chatId) => push('/chat/$chatId');
  void goToRoadReports() => push(AppRoutes.roadReports);
  void goToRideTracker() => push(AppRoutes.rideTracker);
  void goToCyclingStats() => push(AppRoutes.cyclingStats);
  void goToEmergency() => push(AppRoutes.emergency);
  void goToAchievements() => push(AppRoutes.achievements);
  void goToEducation() => push(AppRoutes.education);

  // Nuevas navegaciones
  void goToSearch() => push('/search');
  void goToWeather() => push('/weather');
  void goToFollowers(String userId, {bool showFollowers = true}) => push(
    '/users/$userId/followers?tab=${showFollowers ? "followers" : "following"}',
  );
  void goToOnboarding() => go('/onboarding');
  void goToAccidentReport() => push('/accidents/report');

  void goToRideAttendees(String rideId, String ownerId) =>
      go('/rides/$rideId/attendees?ownerId=$ownerId');
}
