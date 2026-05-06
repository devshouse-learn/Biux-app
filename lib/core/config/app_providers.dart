import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';

// Core
import 'package:biux/core/config/api_config.dart';
import 'package:biux/core/design_system/theme_notifier.dart';
import 'package:biux/core/design_system/locale_notifier.dart';

// Auth
import 'package:biux/features/authentication/data/repositories/auth_repository.dart';
import 'package:biux/features/authentication/presentation/providers/auth_provider.dart'
    as app_auth;

// Users
import 'package:biux/features/users/presentation/providers/user_provider.dart';
import 'package:biux/features/users/presentation/providers/user_profile_provider.dart';
import 'package:biux/features/users/presentation/providers/edit_username_provider.dart';
import 'package:biux/features/users/domain/repositories/user_repository.dart';
import 'package:biux/features/users/data/repositories/user_repository_impl.dart';
import 'package:biux/features/users/data/datasources/user_remote_datasource.dart';

// Maps
import 'package:biux/features/maps/data/repositories/meeting_point_repository.dart';
import 'package:biux/features/maps/presentation/providers/location_provider.dart';
import 'package:biux/features/maps/presentation/providers/map_provider.dart';
import 'package:biux/features/maps/presentation/providers/meeting_point_provider.dart';

// Groups & Rides
import 'package:biux/features/groups/presentation/providers/group_provider.dart';
import 'package:biux/features/cities/presentation/providers/city_provider.dart';
import 'package:biux/features/rides/presentation/providers/ride_provider.dart';

// Bikes
import 'package:biux/features/bikes/presentation/providers/bike_provider.dart';
import 'package:biux/features/bikes/data/repositories/bike_repository_impl.dart';
import 'package:biux/features/bikes/domain/usecases/register_bike_usecase.dart';
import 'package:biux/features/bikes/domain/usecases/get_user_bikes_usecase.dart';
import 'package:biux/features/bikes/domain/usecases/report_bike_theft_usecase.dart';
import 'package:biux/features/bikes/domain/usecases/transfer_bike_ownership_usecase.dart';
import 'package:biux/features/bikes/domain/usecases/get_public_bike_info_usecase.dart';
import 'package:biux/features/bikes/domain/usecases/delete_bike_usecase.dart';
import 'package:biux/features/bikes/domain/usecases/mark_as_recovered_usecase.dart';

// Shop
import 'package:biux/features/shop/presentation/providers/shop_provider.dart';
import 'package:biux/features/shop/presentation/providers/seller_request_provider.dart';
import 'package:biux/features/shop/data/repositories/product_repository_impl.dart';
import 'package:biux/features/shop/data/repositories/order_repository_impl.dart';
import 'package:biux/features/shop/data/datasources/product_remote_datasource.dart';
import 'package:biux/features/shop/data/datasources/order_remote_datasource.dart';

// Store
import 'package:biux/features/store/data/repositories/product_repository_impl.dart'
    as store_repo;
import 'package:biux/features/store/domain/usecases/create_product_usecase.dart';
import 'package:biux/features/store/domain/usecases/get_products_usecase.dart';
import 'package:biux/features/store/domain/usecases/update_product_usecase.dart';
import 'package:biux/features/store/domain/usecases/delete_product_usecase.dart';
import 'package:biux/features/store/presentation/providers/product_provider.dart';
import 'package:biux/features/store/presentation/providers/cart_provider.dart';

// Promotions
import 'package:biux/features/promotions/presentation/providers/promotions_provider.dart';

// Experiences
import 'package:biux/features/experiences/presentation/providers/experience_classic_provider.dart';
import 'package:biux/features/experiences/presentation/providers/experience_creator_classic_provider.dart';
import 'package:biux/features/experiences/presentation/providers/story_groups_provider.dart';
import 'package:biux/features/experiences/data/repositories/experience_repository_impl.dart';
import 'package:biux/features/experiences/domain/usecases/group_stories_by_user_usecase.dart';
import 'package:biux/features/experiences/data/datasources/story_views_local_datasource.dart';

// Social
import 'package:biux/features/social/presentation/providers/social_providers_config.dart';
import 'package:biux/features/social/presentation/providers/notifications_provider.dart';
import 'package:biux/features/social/data/repositories/notifications_repository_impl.dart';
import 'package:biux/features/social/presentation/providers/follow_provider.dart';

// New features
import 'package:biux/features/cycling_stats/presentation/providers/cycling_stats_provider.dart';
import 'package:biux/features/emergency/presentation/providers/emergency_provider.dart';
import 'package:biux/features/achievements/presentation/providers/achievements_provider.dart';
import 'package:biux/features/chat/presentation/providers/chat_provider.dart';
import 'package:biux/features/road_reports/presentation/providers/road_reports_provider.dart';
import 'package:biux/features/ride_tracker/presentation/providers/ride_tracker_provider.dart';
import 'package:biux/features/ride_recommendations/presentation/providers/ride_recommendation_provider.dart';
import 'package:biux/features/accidents/presentation/providers/accident_provider.dart';
import 'package:biux/features/weather/presentation/providers/weather_provider.dart';

// Settings
import 'package:biux/features/settings/presentation/providers/notification_settings_provider.dart';
import 'package:biux/features/settings/data/repositories/notification_settings_repository_impl.dart';

// Safety
import 'package:biux/features/safety/presentation/providers/safety_provider.dart';

/// Configuración centralizada de todos los providers de la app.
class AppProviders {
  AppProviders._();

  static List<SingleChildWidget> get all => [
    ..._coreProviders,
    ..._authProviders,
    ..._userProviders,
    ..._mapProviders,
    ..._groupAndRideProviders,
    ..._bikeProviders,
    ..._shopProviders,
    ..._storeProviders,
    ..._experienceProviders,
    ..._socialProviders,
    ..._featureProviders,
    ..._settingsProviders,
  ];

  static List<SingleChildWidget> get _coreProviders => [
    ChangeNotifierProvider<ThemeNotifier>(create: (_) => ThemeNotifier()),
    ChangeNotifierProvider<LocaleNotifier>(create: (_) => LocaleNotifier()),
  ];

  static List<SingleChildWidget> get _authProviders => [
    ChangeNotifierProvider(
      create: (_) => app_auth.AuthProvider(
        authRepository: AuthRepository(baseUrl: ApiConfig.authBaseUrl),
      ),
    ),
    ChangeNotifierProxyProvider<app_auth.AuthProvider, NotificationsProvider?>(
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
  ];

  static List<SingleChildWidget> get _userProviders => [
    ChangeNotifierProvider(create: (_) => UserProvider()),
    ChangeNotifierProvider(create: (_) => UserProfileProvider()),
    ChangeNotifierProvider(create: (_) => EditUsernameProvider()),
    Provider<UserRepository>(
      create: (_) =>
          UserRepositoryImpl(remoteDataSource: UserRemoteDataSourceImpl()),
    ),
  ];

  static List<SingleChildWidget> get _mapProviders => [
    ChangeNotifierProvider(
      create: (_) => MeetingPointProvider(repository: MeetingPointRepository()),
    ),
    ChangeNotifierProvider(create: (_) => MapProvider()),
    ChangeNotifierProvider(create: (_) => LocationProvider()),
  ];

  static List<SingleChildWidget> get _groupAndRideProviders => [
    ChangeNotifierProvider(create: (_) => GroupProvider()),
    ChangeNotifierProvider(create: (_) => CityProvider()),
    ChangeNotifierProvider(create: (_) => RideProvider()),
  ];

  static List<SingleChildWidget> get _bikeProviders => [
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
  ];

  static List<SingleChildWidget> get _shopProviders => [
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
    ChangeNotifierProvider(create: (_) => PromotionsProvider()),
    ChangeNotifierProvider(create: (_) => SellerRequestProvider()),
  ];

  static List<SingleChildWidget> get _storeProviders => [
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
  ];

  static List<SingleChildWidget> get _experienceProviders => [
    ChangeNotifierProvider(create: (_) => ExperienceProvider()),
    ChangeNotifierProvider(
      create: (_) => StoryGroupsProvider(
        ExperienceRepositoryImpl(),
        GroupStoriesByUserUseCase(StoryViewsLocalService()),
        StoryViewsLocalService(),
      ),
    ),
    ChangeNotifierProxyProvider<ExperienceProvider, ExperienceCreatorProvider>(
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
  ];

  static List<SingleChildWidget> get _socialProviders => [
    ...SocialProvidersConfig.getProviders(),
    ChangeNotifierProvider(create: (_) => FollowProvider()),
  ];

  static List<SingleChildWidget> get _featureProviders => [
    ChangeNotifierProvider(create: (_) => CyclingStatsProvider()),
    ChangeNotifierProvider(create: (_) => EmergencyProvider()),
    ChangeNotifierProvider(create: (_) => AchievementsProvider()),
    ChangeNotifierProvider(create: (_) => ChatProvider()),
    ChangeNotifierProvider(create: (_) => RoadReportsProvider()),
    ChangeNotifierProvider(create: (_) => RideTrackerProvider()),
    ChangeNotifierProvider(create: (_) => RideRecommendationProvider()),
    ChangeNotifierProvider(create: (_) => WeatherProvider()),
    ChangeNotifierProvider(create: (_) => AccidentProvider()),
    ChangeNotifierProvider(create: (_) => SafetyProvider()),
  ];

  static List<SingleChildWidget> get _settingsProviders => [
    ChangeNotifierProvider(
      create: (_) =>
          NotificationSettingsProvider(NotificationSettingsRepositoryImpl()),
    ),
  ];
}
