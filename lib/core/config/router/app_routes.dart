class AppRoutes {
  // Rutas principales
  static const String splash = '/splash';
  static const String login = '/login';
  static const String map = '/map';

  // Rutas de usuario
  static const String profile = '/profile';
  static const String editUser = '/edit-user';
  static const String createUser = '/create-user';
  static const String userSearch = '/users/search';
  static const String userProfile = '/user-profile/:userId';

  // Rutas de grupos
  static const String groupList = '/groups';
  static const String groupCreate = '/groups/create';
  static const String viewGroup = '/groups/:groupId';
  static const String myGroups = '/my-groups';

  // Rutas de historias
  static const String storyCreate = '/stories/create';
  static const String viewStory = '/stories/:storyId';

  // Rutas de caminos/rutas
  static const String roadsList = '/roads';
  static const String roadCreate = '/roads/create/:groupId';
  static const String roadMap = '/roads/map';

  // Rutas de bicicletas
  static const String myBikes = '/my-bikes';
  static const String bikeRegistration = '/bikes/register';
  static const String bikeDetail = '/bikes/:bikeId';
  static const String publicBikeInfo = '/bikes/public/:qrCode';

  // Rutas de configuración
  static const String notificationSettings = '/settings/notifications';
  static const String accountSettings = '/account-settings';

  // Rutas de nuevas funcionalidades
  static const String chatList = '/chat';
  static const String chatDetail = '/chat/:chatId';
  static const String roadReports = '/road-reports';
  static const String rideTracker = '/ride-tracker';
  static const String cyclingStats = '/cycling-stats';
  static const String emergency = '/emergency';
  static const String achievements = '/achievements';
  static const String education = '/education';

  // Rutas de ayuda
  static const String help = '/help';

  // Nombres de rutas para navegación
  static const String splashName = 'splash';
  static const String loginName = 'login';
  static const String mapName = 'map';
  static const String profileName = 'profile';
  static const String editUserName = 'editUser';
  static const String createUserName = 'createUser';
  static const String userSearchName = 'userSearch';
  static const String userProfileName = 'userProfile';
  static const String groupListName = 'groupList';
  static const String groupCreateName = 'groupCreate';
  static const String viewGroupName = 'viewGroup';
  static const String myGroupsName = 'myGroups';
  static const String storyCreateName = 'storyCreate';
  static const String viewStoryName = 'viewStory';
  static const String roadsListName = 'roadsList';
  static const String roadCreateName = 'roadCreate';
  static const String roadMapName = 'roadMap';
  static const String myBikesName = 'myBikes';
  static const String bikeRegistrationName = 'bikeRegistration';
  static const String bikeDetailName = 'bikeDetail';
  static const String publicBikeInfoName = 'publicBikeInfo';
  static const String notificationSettingsName = 'notificationSettings';
  static const String accountSettingsName = 'accountSettings';
  static const String helpName = 'help';

  // Nombres de nuevas funcionalidades
  static const String chatListName = 'chatList';
  static const String chatDetailName = 'chatDetail';
  static const String roadReportsName = 'roadReports';
  static const String rideTrackerName = 'rideTracker';
  static const String cyclingStatsName = 'cyclingStats';
  static const String emergencyName = 'emergency';
  static const String achievementsName = 'achievements';
  static const String educationName = 'education';

  // Onboarding
  static const String onboarding = '/onboarding';
  static const String onboardingName = 'onboarding';

  // Búsqueda global
  static const String globalSearch = '/search';
  static const String globalSearchName = 'globalSearch';

  // Followers
  static const String followers = '/users/:userId/followers';
  static const String followersName = 'followers';

  // Weather
  static const String weather = '/weather';
  static const String weatherName = 'weather';

  // Ride Recommendations
  static const String rideRecommendations = '/ride-recommendations';
  static const String rideRecommendationsName = 'rideRecommendations';

  // Accidents
  static const String accidentReport = '/accidents/report';
  static const String accidentReportName = 'accidentReport';

  // Age Verification
  static const String parentalConsent = '/parental-consent';
  static const String parentalConsentName = 'parentalConsent';
  static const String identityVerification = '/identity-verification';
  static const String identityVerificationName = 'identityVerification';

  // Safety
  static const String reportUser = '/report-user/:userId';
  static const String reportUserName = 'reportUser';
  static const String biometricSettings = '/settings/biometric';
  static const String biometricSettingsName = 'biometricSettings';
  static const String activeSessions = '/settings/sessions';
  static const String activeSessionsName = 'activeSessions';
  static const twoFactor = '/two-factor';
  static const dangerZones = '/danger-zones';
  static const accessibilitySettings = '/accessibility-settings';

  // Welcome post-registro
  static const String welcome = '/welcome';
  static const String welcomeName = 'welcome';
  // Completitud de perfil
  static const String profileCompletion = '/profile/completion';
  static const String profileCompletionName = 'profileCompletion';
}
