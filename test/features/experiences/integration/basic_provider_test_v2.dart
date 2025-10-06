import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:biux/features/experiences/presentation/providers/experience_classic_provider.dart';
import '../../../helpers/firebase_test_setup.dart';

void main() {
  group('Pruebas Básicas de ExperienceProvider', () {
    // Configuración global de Firebase para todas las pruebas
    setUpAll(() async {
      print('🔧 Configurando Firebase para todas las pruebas...');
      await FirebaseTestSetup.initializeFirebase();
      print('✅ Firebase configurado para todas las pruebas');
    });

    setUp(() {
      FirebaseTestSetup.reset();
    });

    testWidgets('Verificar que ExperienceProvider se puede instanciar', (
      tester,
    ) async {
      print('🧪 Iniciando prueba de instanciación de ExperienceProvider');

      bool providerCreated = false;
      ExperienceProvider? provider;

      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider(
            create: (context) {
              print('🏗️ Creando ExperienceProvider');
              provider = ExperienceProvider();
              providerCreated = true;
              return provider!;
            },
            child: Consumer<ExperienceProvider>(
              builder: (context, experienceProvider, child) {
                return Scaffold(
                  body: Center(
                    child: const Text(
                      'Provider inicializado: true',
                      key: Key('provider_status'),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verificar que el provider se creó correctamente
      expect(
        providerCreated,
        isTrue,
        reason: 'ExperienceProvider debería haberse creado',
      );
      expect(
        provider,
        isNotNull,
        reason: 'ExperienceProvider no debería ser null',
      );
      expect(find.text('Provider inicializado: true'), findsOneWidget);

      print('✅ ExperienceProvider se creó exitosamente');
    });

    testWidgets('Verificar propiedades iniciales del ExperienceProvider', (
      tester,
    ) async {
      print('🧪 Verificando propiedades iniciales');

      ExperienceProvider? provider;

      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider(
            create: (context) {
              provider = ExperienceProvider();
              return provider!;
            },
            child: Builder(
              builder: (context) {
                final experienceProvider = Provider.of<ExperienceProvider>(
                  context,
                );
                return Scaffold(
                  body: Column(
                    children: [
                      Text(
                        'Experiences: ${experienceProvider.experiences.length}',
                      ),
                      Text('Loading: ${experienceProvider.isLoading}'),
                      Text('Error: ${experienceProvider.error ?? "null"}'),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verificar propiedades iniciales
      expect(provider, isNotNull);
      expect(
        provider!.experiences,
        isEmpty,
        reason: 'Lista de experiencias debería estar vacía inicialmente',
      );
      expect(
        provider!.isLoading,
        isFalse,
        reason: 'isLoading debería ser false inicialmente',
      );
      expect(
        provider!.error,
        isNull,
        reason: 'error debería ser null inicialmente',
      );

      print('✅ Propiedades iniciales verificadas correctamente');
    });

    test('Crear ExperienceProvider directamente', () async {
      print('🧪 Creando ExperienceProvider directamente');

      // Verificar que Firebase esté disponible
      expect(
        FirebaseTestSetup.isInitialized,
        isTrue,
        reason: 'Firebase debería estar inicializado',
      );

      // Crear el provider directamente
      final provider = ExperienceProvider();

      expect(provider, isNotNull);
      expect(provider.experiences, isEmpty);
      expect(provider.isLoading, isFalse);
      expect(provider.error, isNull);

      print('✅ ExperienceProvider creado directamente exitosamente');
    });
  });
}
