import 'dart:core';

import 'package:biux/config/router/app_router.dart';
import 'package:biux/config/strings.dart';
import 'package:biux/config/themes/theme.dart';
import 'package:biux/config/themes/theme_notifier.dart';
import 'package:biux/data/local_storage/local_storage.dart';
import 'package:biux/data/repositories/auth/auth_repository.dart';
import 'package:biux/providers/auth_provider.dart' as app_auth;
import 'package:biux/providers/city_provider.dart';
import 'package:biux/providers/group_provider.dart';
import 'package:biux/providers/location_provider.dart';
import 'package:biux/providers/map_provider.dart';
import 'package:biux/providers/meeting_point_provider.dart';
import 'package:biux/providers/user_provider.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import "package:flutter/services.dart";
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';

import 'data/repositories/meeting_point_repository.dart';
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
          create: (_) => ThemeNotifier(lightTheme),
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
      theme: themeNotifier.getTheme(),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
      ),
      routerConfig: AppRouter.router,
    );
  }
}
