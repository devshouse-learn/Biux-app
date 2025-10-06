import 'dart:core';

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

// Shared imports
import 'package:biux/shared/services/local_storage.dart';

// External packages
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import "package:flutter/services.dart";
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';

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
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await LocalStorage().init();
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
        ChangeNotifierProvider<ThemeNotifier>(
          create: (_) => ThemeNotifier(),
        ),
        ChangeNotifierProvider(
          create: (_) => MeetingPointProvider(
            repository: MeetingPointRepository(),
          ),
        ),
        ChangeNotifierProvider(
          create: (_) => MapProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => LocationProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => UserProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => GroupProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => CityProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => RideProvider(),
        ),
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

    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale(AppStrings.en, AppStrings.us),
      ],
      title: AppStrings.APP_NAME,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeNotifier.themeMode,
      routerConfig: AppRouter.router,
    );
  }
}
