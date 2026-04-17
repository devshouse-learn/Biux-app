import 'package:biux/core/design_system/locale_notifier.dart';
import 'dart:core';
import 'package:flutter/foundation.dart' show kIsWeb;

// Core imports
import 'package:biux/core/config/router/app_router.dart';
import 'package:biux/core/config/strings.dart';
import 'package:biux/core/config/api_config.dart';
import 'package:biux/core/design_system/theme_notifier.dart';
import 'package:biux/core/design_system/app_theme.dart';

// Features imports
import 'package:biux/features/authentication/data/repositories/auth_repository.dart';
import 'package:biux/features/authentication/presentation/providers/auth_provider.dart'
    as app_auth;
import 'package:biux/features/cities/presentation/providers/city_provider.dart';
import 'package:biux/features/groups/presentation/providers/group_provider.dart';
import 'package:biux/features/maps/data/repositories/meeting_point_repository.dart';
import 'package:biux/features/maps/presentation/providers/location_provider.dart';
import 'package:biux/features/maps/presentation/providers/map_provider.dart';
import 'package:biux/features/maps/presentation/providers/meeting_point_provider.dart';
import 'package:biux/features/rides/presentation/providers/ride_provider.dart';
import 'package:biux/features/users/presentation/providers/user_provider.dart';
import 'package:biux/features/users/presentation/providers/user_profile_provider.dart';
import 'package:biux/features/users/presentation/providers/edit_username_provider.dart';
import 'package:biux/features/users/domain/repositories/user_repository.dart';
import 'package:biux/features/users/data/repositories/user_repository_impl.dart';
import 'package:biux/features/users/data/datasources/user_remote_datasource.dart';
import 'package:biux/features/experiences/presentation/providers/experience_classic_provider.dart';
import 'package:biux/features/experiences/presentation/providers/experience_creator_classic_provider.dart';
import 'package:biux/features/experiences/presentation/providers/story_groups_provider.dart';
import 'package:biux/features/experiences/data/repositories/experience_repository_impl.dart';
import 'package:biux/features/experiences/domain/usecases/group_stories_by_user_usecase.dart';
import 'package:biux/features/experiences/data/datasources/story_views_local_datasource.dart';
import 'package:biux/features/bikes/presentation/providers/bike_provider.dart';
import 'package:biux/features/bikes/data/repositories/bike_repository_impl.dart';
import 'package:biux/features/bikes/domain/usecases/register_bike_usecase.dart';
import 'package:biux/features/bikes/domain/usecases/get_user_bikes_usecase.dart';
import 'package:biux/features/bikes/domain/usecases/report_bike_theft_usecase.dart';
import 'package:biux/features/bikes/domain/usecases/transfer_bike_ownership_usecase.dart';
import 'package:biux/features/bikes/domain/usecases/get_public_bike_info_usecase.dart';
import 'package:biux/features/bikes/domain/usecases/delete_bike_usecase.dart';
import 'package:biux/features/bikes/domain/usecases/mark_as_recovered_usecase.dart';
import 'package:biux/features/shop/presentation/providers/shop_provider.dart';
import 'package:biux/features/shop/presentation/providers/seller_request_provider.dart';
import 'package:biux/features/shop/data/repositories/product_repository_impl.dart';
import 'package:biux/features/shop/data/repositories/order_repository_impl.dart';
import 'package:biux/features/shop/data/datasources/product_remote_datasource.dart';
import 'package:biux/features/shop/data/datasources/order_remote_datasource.dart';

// Promotions
import 'package:biux/features/promotions/presentation/providers/promotions_provider.dart';

// Store (Tienda) imports
import 'package:biux/features/store/data/repositories/product_repository_impl.dart'
    as store_repo;
import 'package:biux/features/store/domain/usecases/create_product_usecase.dart';
import 'package:biux/features/store/domain/usecases/get_products_usecase.dart';
import 'package:biux/features/store/domain/usecases/update_product_usecase.dart';
import 'package:biux/features/store/domain/usecases/delete_product_usecase.dart';
import 'package:biux/features/store/presentation/providers/product_provider.dart';
import 'package:biux/features/store/presentation/providers/cart_provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:biux/features/social/presentation/providers/social_providers_config.dart';
import 'package:biux/features/settings/presentation/providers/notification_settings_provider.dart';
import 'package:biux/features/settings/data/repositories/notification_settings_repository_impl.dart';
import 'package:biux/features/social/presentation/providers/notifications_provider.dart';
import 'package:biux/features/social/data/repositories/notifications_repository_impl.dart';
import 'package:firebase_auth/firebase_auth.dart';

// New feature providers
import 'package:biux/features/cycling_stats/presentation/providers/cycling_stats_provider.dart';
import 'package:biux/features/emergency/presentation/providers/emergency_provider.dart';
import 'package:biux/features/achievements/presentation/providers/achievements_provider.dart';
import 'package:biux/features/chat/presentation/providers/chat_provider.dart';
import 'package:biux/features/road_reports/presentation/providers/road_reports_provider.dart';
import 'package:biux/features/ride_tracker/presentation/providers/ride_tracker_provider.dart';
import 'package:biux/features/ride_recommendations/presentation/providers/ride_recommendation_provider.dart';
import 'package:biux/features/accidents/presentation/providers/accident_provider.dart';
import 'package:biux/features/weather/presentation/providers/weather_provider.dart';
import 'package:biux/features/social/presentation/providers/follow_provider.dart';

// Shared imports
import 'package:biux/core/services/local_storage.dart';
import 'package:biux/core/services/notification_service.dart';
import 'package:biux/core/services/push_notification_service.dart';
import 'package:biux/core/services/screen_time_service.dart';
import 'package:biux/shared/widgets/notification_listener_widget.dart';
import 'package:biux/shared/widgets/offline_banner.dart';

// Core services
import 'package:biux/core/services/connectivity_service.dart';
import 'package:biux/core/services/remote_config_service.dart';
import 'package:biux/core/services/snackbar_service.dart';
import 'package:biux/core/services/performance_service.dart';
import 'package:biux/core/services/app_update_service.dart';

// External packages
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import "package:flutter/services.dart";
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'dart:ui' show PlatformDispatcher;

import 'package:biux/core/config/firebase_options.dart';
import 'package:biux/features/safety/presentation/providers/safety_provider.dart';

void main() async {
  if (kIsWeb) {
    // initialiaze the facebook javascript SDK
    // FacebookAuth.instance.webInitialize(
    //   appId: AppStrings.appId,
    //   cookie: true,
    //   xfbml: false,
    //   version: AppStrings.version,
    // );
  }
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Configurar manejador de mensajes en background
  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

  // Deshabilitar Crashlytics en web (no es compatible)
  if (!kIsWeb) {
    FlutterError.onError = (errorDetails) {
      FirebaseCrashlytics.instance.recordFlutterFatalError(errorDetails);
    };
    // Pass all uncaught asynchronous errors that aren't handled by the Flutter framework to Crashlytics
    PlatformDispatcher.instance.onError = (error, stack) {
      FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
      return true;
    };
  }

  await LocalStorage().init();

  // Inicializar servicios core de forma diferida para evitar ANR
  // Se inicializan después del primer frame para que el splash aparezca inmediatamente
  _initServicesAsync();

  // Inicializar tracking de tiempo de uso
  await ScreenTimeService.instance.initialize();

  // ErrorWidget global para producción - muestra UI amigable en vez de pantalla roja
  ErrorWidget.builder = (FlutterErrorDetails details) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: const Color(0xFF16242D),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.error_outline,
                  color: Colors.white70,
                  size: 64,
                ),
                const SizedBox(height: 16),
                const Text(
                  'Algo salió mal',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Por favor reinicia la aplicación',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.7),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  };

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => app_auth.AuthProvider(
            authRepository: AuthRepository(baseUrl: ApiConfig.authBaseUrl),
          ),
        ),
        ChangeNotifierProvider<ThemeNotifier>(create: (_) => ThemeNotifier()),
        ChangeNotifierProvider<LocaleNotifier>(create: (_) => LocaleNotifier()),
        ChangeNotifierProxyProvider<
          app_auth.AuthProvider,
          NotificationsProvider?
        >(
          create: (_) => null,
          update: (context, authProvider, previous) {
            final currentUser = FirebaseAuth.instance.currentUser;
            if (currentUser == null) return null;
            if (previous != null) return previous;
            return NotificationsProvider(
              repository: NotificationsRepositoryImpl(),
              userId: currentUser.uid,
            );
          },
        ),
        ChangeNotifierProvider(
          create: (_) =>
              MeetingPointProvider(repository: MeetingPointRepository()),
        ),
        ChangeNotifierProvider(create: (_) => MapProvider()),
        ChangeNotifierProvider(create: (_) => LocationProvider()),
        ChangeNotifierProvider(create: (_) => UserProvider()),
        ChangeNotifierProvider(create: (_) => UserProfileProvider()),
        ChangeNotifierProvider(create: (_) => EditUsernameProvider()),

        // UserRepository - Necesario para obtener datos completos de usuarios
        Provider<UserRepository>(
          create: (_) =>
              UserRepositoryImpl(remoteDataSource: UserRemoteDataSourceImpl()),
        ),

        ChangeNotifierProvider(create: (_) => GroupProvider()),
        ChangeNotifierProvider(create: (_) => CityProvider()),
        ChangeNotifierProvider(create: (_) => RideProvider()),
        ChangeNotifierProvider(
          create: (_) {
            final repository = BikeRepositoryImpl();
            return BikeProvider(
              registerBikeUseCase: RegisterBikeUseCase(repository),
              getUserBikesUseCase: GetUserBikesUseCase(repository),
              reportBikeTheftUseCase: ReportBikeTheftUseCase(repository),
              transferBikeOwnershipUseCase: TransferBikeOwnershipUseCase(
                repository,
              ),
              getPublicBikeInfoUseCase: GetPublicBikeInfoUseCase(repository),
              deleteBikeUseCase: DeleteBikeUseCase(repository),
              markAsRecoveredUseCase: MarkAsRecoveredUseCase(repository),
            );
          },
        ),

        // Shop Provider
        ChangeNotifierProvider(
          create: (_) => ShopProvider(
            productRepository: ProductRepositoryImpl(
              remoteDataSource: ProductRemoteDataSource(),
            ),
            orderRepository: OrderRepositoryImpl(
              remoteDataSource: OrderRemoteDataSource(),
            ),
          ),
        ),

        // Promotions provider
        ChangeNotifierProvider(create: (_) => PromotionsProvider()),

        // Seller Request Provider (para gestionar solicitudes de vendedores)
        // No llamar initialize() aquí - se inicializa cuando se accede a la pantalla
        ChangeNotifierProvider(create: (_) => SellerRequestProvider()),

        // Store (Tienda Online) Providers
        ChangeNotifierProvider(
          create: (_) {
            final productRepository = store_repo.ProductRepositoryImpl(
              FirebaseFirestore.instance,
            );
            return ProductProvider(
              getAllProductsUseCase: GetAllProductsUseCase(productRepository),
              getProductsByCategoryUseCase: GetProductsByCategoryUseCase(
                productRepository,
              ),
              getProductsBySellerUseCase: GetProductsBySellerUseCase(
                productRepository,
              ),
              getFeaturedProductsUseCase: GetFeaturedProductsUseCase(
                productRepository,
              ),
              searchProductsUseCase: SearchProductsUseCase(productRepository),
              createProductUseCase: CreateProductUseCase(productRepository),
              updateProductUseCase: UpdateProductUseCase(productRepository),
              deleteProductUseCase: DeleteProductUseCase(productRepository),
            );
          },
        ),
        ChangeNotifierProvider(create: (_) => CartProvider()),

        ChangeNotifierProvider(create: (_) => ExperienceProvider()),
        ChangeNotifierProvider(
          create: (_) => StoryGroupsProvider(
            ExperienceRepositoryImpl(),
            GroupStoriesByUserUseCase(StoryViewsLocalService()),
            StoryViewsLocalService(),
          ),
        ),
        ChangeNotifierProxyProvider<
          ExperienceProvider,
          ExperienceCreatorProvider
        >(
          create: (context) => ExperienceCreatorProvider(
            experienceProvider: Provider.of<ExperienceProvider>(
              context,
              listen: false,
            ),
          ),
          update: (context, experienceProvider, previous) =>
              previous ??
              ExperienceCreatorProvider(experienceProvider: experienceProvider),
        ),

        // Social Providers (Notificaciones, Likes, Comentarios, Asistentes)
        ...SocialProvidersConfig.getProviders(),

        // New feature providers
        ChangeNotifierProvider(create: (_) => CyclingStatsProvider()),
        ChangeNotifierProvider(create: (_) => EmergencyProvider()),
        ChangeNotifierProvider(create: (_) => AchievementsProvider()),
        ChangeNotifierProvider(create: (_) => ChatProvider()),
        ChangeNotifierProvider(create: (_) => RoadReportsProvider()),
        ChangeNotifierProvider(create: (_) => RideTrackerProvider()),
        ChangeNotifierProvider(create: (_) => RideRecommendationProvider()),
        ChangeNotifierProvider(create: (_) => WeatherProvider()),

        // Settings Providers
        ChangeNotifierProvider(
          create: (_) => NotificationSettingsProvider(
            NotificationSettingsRepositoryImpl(),
          ),
        ),
        ChangeNotifierProvider(create: (_) => AccidentProvider()),
        ChangeNotifierProvider(create: (_) => FollowProvider()),
        ChangeNotifierProvider(create: (_) => SafetyProvider()),
      ],
      child: MyApp(),
    ),
  );
}

/// Inicializa servicios pesados de forma asíncrona sin bloquear el arranque
Future<void> _initServicesAsync() async {
  try {
    ConnectivityService().initialize();
    RemoteConfigService().initialize();
    NotificationService().initialize();
    // Inicializar Push Notifications
    await PushNotificationService.initialize();
    // Inicializar info del paquete para update checker
    AppUpdateService.initialize();
    // Performance monitoring
    PerformanceService.startAppLoadTrace();
  } catch (e) {
    debugPrint('⚠️ Error en inicialización async de servicios: $e');
  }
}

class MyApp extends StatelessWidget {
  final FirebaseAnalytics analytics = FirebaseAnalytics.instance;

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    final themeNotifier = Provider.of<ThemeNotifier>(context);
    final localeNotifier = Provider.of<LocaleNotifier>(context);

    return BiuxNotificationListener(
      child: MaterialApp.router(
        scaffoldMessengerKey: SnackBarService.messengerKey,
        debugShowCheckedModeBanner: false,
        locale: localeNotifier.locale,
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: LocaleNotifier.supportedLocales,
        title: AppStrings.APP_NAME,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: themeNotifier.themeMode,
        routerConfig: AppRouter.router,
        builder: (context, child) {
          return Column(
            children: [
              const OfflineBanner(),
              Expanded(child: child ?? const SizedBox.shrink()),
            ],
          );
        },
      ),
    );
  }
}

// Test miércoles, 26 de noviembre de 2025, 18:59:20 -05
