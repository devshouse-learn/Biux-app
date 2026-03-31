import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

// Importaciones de biux
import 'package:biux/features/experiences/presentation/providers/experience_classic_provider.dart';

// Helper para setup de Firebase
import '../../../helpers/firebase_test_setup.dart';

void main() {
  group('Pruebas Básicas de ExperienceProvider', () {
    setUpAll(() async {
      // Inicializar Firebase antes de todas las pruebas
      await FirebaseTestSetup.initializeFirebase();
    });

    setUp(() {
      // Setup para cada prueba individual
      FirebaseTestSetup.reset();
    });

    testWidgets('Verificar que ExperienceProvider se puede instanciar', (
      WidgetTester tester,
    ) async {
      print('🧪 Iniciando prueba de instanciación de ExperienceProvider');

      // Crear widget de prueba con Provider
      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider<ExperienceProvider>(
            create: (context) {
              print('🏗️ Creando ExperienceProvider');
              return ExperienceProvider();
            },
            child: Scaffold(
              body: Consumer<ExperienceProvider>(
                builder: (context, provider, child) {
                  print('🎯 Consumer construyendo con provider: true');
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('Provider inicializado: true'),
                        Text('Loading: ${provider.isLoading}'),
                        Text(
                          'Total experiencias: ${provider.userExperiences.length}',
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      );

      // Esperar a que se construya el widget
      await tester.pumpAndSettle();

      // Verificar que el provider se inicializó
      expect(find.text('Provider inicializado: true'), findsOneWidget);
      expect(find.text('Loading: false'), findsOneWidget);
      expect(find.text('Total experiencias: 0'), findsOneWidget);

      print('✅ Prueba de instanciación completada exitosamente');
    });

    testWidgets('Verificar propiedades iniciales del ExperienceProvider', (
      WidgetTester tester,
    ) async {
      print('🧪 Verificando propiedades iniciales');

      ExperienceProvider? capturedProvider;

      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider<ExperienceProvider>(
            create: (context) => ExperienceProvider(),
            child: Builder(
              builder: (context) {
                capturedProvider = Provider.of<ExperienceProvider>(
                  context,
                  listen: false,
                );
                return Scaffold(
                  body: Consumer<ExperienceProvider>(
                    builder: (context, provider, child) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text('isLoading: ${provider.isLoading}'),
                            Text(
                              'userExperiences: ${provider.userExperiences.length}',
                            ),
                            Text(
                              'rideExperiences: ${provider.rideExperiences.length}',
                            ),
                            Text('error: ${provider.error ?? "null"}'),
                          ],
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verificar estado inicial
      expect(capturedProvider, isNotNull);
      expect(capturedProvider!.isLoading, false);
      expect(capturedProvider!.userExperiences, isEmpty);
      expect(capturedProvider!.rideExperiences, isEmpty);
      expect(capturedProvider!.error, isNull);

      // Verificar UI
      expect(find.text('isLoading: false'), findsOneWidget);
      expect(find.text('userExperiences: 0'), findsOneWidget);
      expect(find.text('rideExperiences: 0'), findsOneWidget);
      expect(find.text('error: null'), findsOneWidget);

      print('✅ Propiedades iniciales verificadas correctamente');
    });

    test('Crear ExperienceProvider directamente', () {
      print('🧪 Creando ExperienceProvider directamente');

      // Crear provider sin widget
      final provider = ExperienceProvider();

      // Verificar estado inicial
      expect(provider.isLoading, false);
      expect(provider.userExperiences, isEmpty);
      expect(provider.rideExperiences, isEmpty);
      expect(provider.error, isNull);

      print('✅ ExperienceProvider creado directamente con éxito');
    });
  });
}
