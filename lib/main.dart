import 'package:biux/core/design_system/locale_notifier.dart';
import 'dart:core';
import 'package:flutter/foundation.dart' show kIsWeb;

// Core imports
import 'package:biux/core/config/router/app_router.dart';
import 'package:biux/core/config/strings.dart';
import 'package:biux/core/config/app_providers.dart';
import 'package:biux/core/design_system/theme_notifier.dart';
import 'package:biux/core/design_system/app_theme.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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
import 'package:biux/features/ride_tracker/data/datasources/offline_ride_datasource.dart';

Future<void> _syncOfflineRides() async {
  try {
    final pending = await OfflineRideDatasource.getPending();
    if (pending.isNotEmpty) {
      debugPrint('📡 \${pending.length} rodadas pendientes de sincronizar');
    }
  } catch (_) {}
}

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

  // Habilitar persistencia offline de Firestore
  FirebaseFirestore.instance.settings = const Settings(
    persistenceEnabled: true,
    cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
  );

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

  runApp(MultiProvider(providers: AppProviders.all, child: MyApp()));
}

/// Inicializa servicios pesados de forma asíncrona sin bloquear el arranque
Future<void> _initServicesAsync() async {
  try {
    ConnectivityService().initialize();

    // Auto-sync rodadas offline cuando se restaure la conexión
    ConnectivityService().statusStream.listen((status) {
      if (status == ConnectivityStatus.online) {
        _syncOfflineRides();
      }
    });
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
