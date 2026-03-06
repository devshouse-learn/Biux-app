import 'dart:core';
import 'package:flutter/foundation.dart' show kIsWeb;

// Core imports
import 'package:biux/core/config/router/app_router.dart';
import 'package:biux/core/config/strings.dart';
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
import 'package:biux/features/experiences/data/datasources/story_views_local_service.dart';
import 'package:biux/features/bikes/presentation/providers/bike_provider.dart';
import 'package:biux/features/bikes/data/repositories/bike_repository_impl.dart';
import 'package:biux/features/bikes/domain/usecases/register_bike_usecase.dart';
import 'package:biux/features/bikes/domain/usecases/get_user_bikes_usecase.dart';
import 'package:biux/features/bikes/domain/usecases/report_bike_theft_usecase.dart';
import 'package:biux/features/bikes/domain/usecases/transfer_bike_ownership_usecase.dart';
import 'package:biux/features/bikes/domain/usecases/get_public_bike_info_usecase.dart';
import 'package:biux/features/bikes/domain/usecases/delete_bike_usecase.dart';
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


// New feature providers
import 'package:biux/features/cycling_stats/presentation/providers/cycling_stats_provider.dart';
import 'package:biux/features/emergency/presentation/providers/emergency_provider.dart';
import 'package:biux/features/achievements/presentation/providers/achievements_provider.dart';
import 'package:biux/features/chat/presentation/providers/chat_provider.dart';
import 'package:biux/features/road_reports/presentation/providers/road_reports_provider.dart';
import 'package:biux/features/ride_tracker/presentation/providers/ride_tracker_provider.dart';
import 'package:biux/features/accidents/presentation/providers/accident_provider.dart';
import 'package:biux/features/weather/presentation/providers/weather_provider.dart';
import 'package:biux/features/social/presentation/providers/follow_provider.dart';

// Shared imports
import 'package:biux/shared/services/local_storage.dart';
import 'package:biux/shared/services/notification_service.dart';
import 'package:biux/shared/widgets/notification_listener_widget.dart';

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

import 'firebase_options.dart';

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

  // Inicializar servicio de notificaciones
  await NotificationService().initialize();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => app_auth.AuthProvider(
            authRepository: AuthRepository(
              baseUrl: 'https://n8n.oktavia.me/webhook',
            ),
          ),
        ),
        ChangeNotifierProvider<ThemeNotifier>(create: (_) => ThemeNotifier()),
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
        ChangeNotifierProvider(
          create: (_) => SellerRequestProvider()..initialize(),
        ),

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
        ChangeNotifierProvider(create: (_) => WeatherProvider()),

        // Settings Providers
        ChangeNotifierProvider(
          create: (_) => NotificationSettingsProvider(
            NotificationSettingsRepositoryImpl(),
          ),
        ),
        ChangeNotifierProvider(create: (_) => AccidentProvider()),
        ChangeNotifierProvider(create: (_) => FollowProvider()),
      ],
      child: MyApp(),
    ),
  );
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

    return BiuxNotificationListener(
      child: MaterialApp.router(
        debugShowCheckedModeBanner: false,
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [Locale(AppStrings.en, AppStrings.us)],
        title: AppStrings.APP_NAME,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: themeNotifier.themeMode,
        routerConfig: AppRouter.router,
      ),
    );
  }
}

// Test miércoles, 26 de noviembre de 2025, 18:59:20 -05
