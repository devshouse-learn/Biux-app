import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:biux/features/authentication/presentation/providers/auth_provider.dart'
    as app_auth;
import 'package:biux/features/authentication/data/repositories/auth_repository.dart';
import 'package:biux/features/experiences/presentation/providers/experience_classic_provider.dart';
import 'package:biux/features/experiences/presentation/providers/experience_creator_classic_provider.dart';
import 'package:biux/features/users/presentation/providers/user_provider.dart';
import 'package:biux/features/groups/presentation/providers/group_provider.dart';
import 'package:biux/features/rides/presentation/providers/ride_provider.dart';
import 'package:biux/features/cities/presentation/providers/city_provider.dart';

/// Helper para pruebas de integración con Firebase
class IntegrationTestHelper {
  /// Crea un widget con providers reales para pruebas de integración
  static Widget createIntegrationTestWidget({required Widget child}) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) =>
              app_auth.AuthProvider(authRepository: AuthRepository()),
        ),
        ChangeNotifierProvider(create: (_) => UserProvider()),
        ChangeNotifierProvider(create: (_) => GroupProvider()),
        ChangeNotifierProvider(create: (_) => CityProvider()),
        ChangeNotifierProvider(create: (_) => RideProvider()),
        ChangeNotifierProvider(create: (_) => ExperienceProvider()),
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
      ],
      child: MaterialApp(
        home: child,
        theme: ThemeData(primarySwatch: Colors.blue),
      ),
    );
  }

  /// Pump widget con tiempo de espera para operaciones asíncronas
  static Future<void> pumpAndSettle(
    WidgetTester tester, {
    Duration? duration,
  }) async {
    await tester.pumpAndSettle(duration ?? const Duration(milliseconds: 500));
  }

  /// Esperar por un widget específico con timeout
  static Future<void> waitForWidget(
    WidgetTester tester,
    Finder finder, {
    Duration timeout = const Duration(seconds: 10),
  }) async {
    final stopwatch = Stopwatch()..start();

    while (finder.evaluate().isEmpty && stopwatch.elapsed < timeout) {
      await tester.pump(const Duration(milliseconds: 100));
    }

    stopwatch.stop();

    if (finder.evaluate().isEmpty) {
      throw Exception('Widget not found after ${timeout.inSeconds} seconds');
    }
  }

  /// Tap en widget con verificación y espera
  static Future<void> tapWidget(WidgetTester tester, Finder finder) async {
    await waitForWidget(tester, finder);
    await tester.tap(finder);
    await pumpAndSettle(tester);
  }

  /// Enter text con verificación
  static Future<void> enterText(
    WidgetTester tester,
    Finder finder,
    String text,
  ) async {
    await waitForWidget(tester, finder);
    await tester.enterText(finder, text);
    await pumpAndSettle(tester);
  }

  /// Scroll hasta que un widget sea visible
  static Future<void> scrollUntilVisible(
    WidgetTester tester,
    Finder finder,
    Finder scrollable, {
    double delta = 100.0,
  }) async {
    int maxScrolls = 20; // Evitar loops infinitos
    int scrollCount = 0;

    while (finder.evaluate().isEmpty && scrollCount < maxScrolls) {
      await tester.drag(scrollable, Offset(0, -delta));
      await pumpAndSettle(tester);
      scrollCount++;
    }

    if (finder.evaluate().isEmpty) {
      throw Exception('Widget not found after $maxScrolls scrolls');
    }
  }

  /// Debug: Imprimir todos los widgets Text en pantalla
  static void debugPrintAllText(WidgetTester tester) {
    print('=== TEXTOS EN PANTALLA ===');
    final textWidgets = find.byType(Text).evaluate();
    for (final element in textWidgets) {
      final text = element.widget as Text;
      print('Texto encontrado: "${text.data}"');
    }
    print('=== TOTAL: ${textWidgets.length} textos ===');
  }

  /// Debug: Imprimir información sobre ListView
  static void debugPrintListViewInfo(WidgetTester tester) {
    print('=== INFORMACIÓN DE LISTVIEW ===');
    final listViews = find.byType(ListView).evaluate();
    print('ListViews encontrados: ${listViews.length}');

    for (int i = 0; i < listViews.length; i++) {
      final listView = listViews.elementAt(i).widget as ListView;
      print('ListView $i: ${listView.toString()}');
    }

    // Buscar widgets comunes de listas
    final containers = find.byType(Container).evaluate().length;
    final cards = find.byType(Card).evaluate().length;
    final listTiles = find.byType(ListTile).evaluate().length;

    print('Containers: $containers');
    print('Cards: $cards');
    print('ListTiles: $listTiles');
    print('=== FIN INFORMACIÓN ===');
  }

  /// Debug: Verificar estado de providers
  static void debugPrintProviderState(BuildContext context) {
    print('=== ESTADO DE PROVIDERS ===');

    try {
      final experienceProvider = Provider.of<ExperienceProvider>(
        context,
        listen: false,
      );
      print(
        'ExperienceProvider - Experiencias: ${experienceProvider.experiences.length}',
      );
      print('ExperienceProvider - Loading: ${experienceProvider.isLoading}');
      print('ExperienceProvider - Error: ${experienceProvider.error}');
    } catch (e) {
      print('Error accediendo ExperienceProvider: $e');
    }

    try {
      final authProvider = Provider.of<app_auth.AuthProvider>(
        context,
        listen: false,
      );
      print('AuthProvider - Estado: ${authProvider.state}');
      print('AuthProvider - Error: ${authProvider.errorMessage ?? "null"}');
    } catch (e) {
      print('Error accediendo AuthProvider: $e');
    }

    print('=== FIN ESTADO ===');
  }
}
