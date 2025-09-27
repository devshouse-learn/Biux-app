import 'dart:core';

import 'package:biux/config/router/router_path.dart';
import 'package:biux/config/strings.dart';
import 'package:biux/config/themes/theme.dart';
import 'package:biux/config/themes/theme_notifier.dart';
import 'package:biux/data/local_storage/local_storage.dart';
import 'package:biux/data/repositories/auth/auth_repository.dart';
import 'package:biux/providers/auth_provider.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import "package:flutter/services.dart";
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';

import 'config/router/router.dart' as router;
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
  final map = <String, int>{};
  WidgetsFlutterBinding.ensureInitialized();
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await LocalStorage().init();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => AuthProvider(
            authRepository: AuthRepository(
              baseUrl: 'https://n8n.oktavia.me/webhook',
            ),
          ),
        ),
        ChangeNotifierProvider<ThemeNotifier>(
          create: (_) =>
              ThemeNotifier(lightTheme //darkModeOn ? darkTheme : lightTheme,
                  ),
        ),
        // Otros providers que puedas tener
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
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      localizationsDelegates: [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: [
        const Locale(AppStrings.en, AppStrings.us),
      ],
      navigatorObservers: [
        FirebaseAnalyticsObserver(analytics: analytics),
      ],
      title: AppStrings.APP_NAME,
      theme: themeNotifier.getTheme(),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
      ),
      initialRoute: AppRoutes.splashRoute,
      onGenerateRoute: router.generateRoute,
    );
  }
}
