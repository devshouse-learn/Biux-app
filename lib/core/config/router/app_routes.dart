class AppRoutes {
  // Rutas principales
  static const String splash = '/';
  static const String login = '/login';
  static const String mainMenu = '/main';
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

  // Rutas de ayuda
  static const String help = '/help';

  // Nombres de rutas para navegación
  static const String splashName = 'splash';
  static const String loginName = 'login';
  static const String mainMenuName = 'main';
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
  static const String helpName = 'help';
}
