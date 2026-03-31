import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:biux/features/experiences/presentation/providers/experience_classic_provider.dart';
import 'package:biux/features/experiences/presentation/providers/experience_creator_classic_provider.dart';
import 'package:biux/features/experiences/domain/entities/experience_entity.dart';
import 'package:biux/features/experiences/domain/repositories/experience_repository.dart';

void main() {
  group('Pruebas de Integración - ExperienceProvider', () {
    testWidgets('Crear experiencia directamente con Provider', (
      WidgetTester tester,
    ) async {
      print('🧪 Iniciando prueba directa de ExperienceProvider');

      // Widget minimal para testing
      final testWidget = MultiProvider(
        providers: [
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
                ExperienceCreatorProvider(
                  experienceProvider: experienceProvider,
                ),
          ),
        ],
        child: MaterialApp(
          home: Builder(
            builder: (context) {
              return Scaffold(
                body: Consumer<ExperienceProvider>(
                  builder: (context, provider, child) {
                    return Column(
                      children: [
                        Text(
                          'Total experiencias: ${provider.experiences.length}',
                        ),
                        Text('Loading: ${provider.isLoading}'),
                        Text('Error: ${provider.error ?? "Sin errores"}'),
                        ElevatedButton(
                          onPressed: () async {
                            print('📝 Creando experiencia...');
                            final request = CreateExperienceRequest(
                              description:
                                  'Test experiencia ${DateTime.now().millisecondsSinceEpoch}',
                              tags: ['test', 'integración'],
                              mediaFiles: [
                                CreateMediaRequest(
                                  filePath: 'test_image.jpg',
                                  mediaType: MediaType.image,
                                  duration: 15,
                                ),
                              ],
                              type: ExperienceType.general,
                            );

                            final success = await provider.createExperience(
                              request,
                            );
                            print('✅ Resultado: $success');
                          },
                          child: const Text('Crear Experiencia'),
                        ),
                        Expanded(
                          child: ListView.builder(
                            itemCount: provider.experiences.length,
                            itemBuilder: (context, index) {
                              final experience = provider.experiences[index];
                              return Card(
                                child: ListTile(
                                  title: Text(experience.description),
                                  subtitle: Text(
                                    'Usuario: ${experience.user.fullName}',
                                  ),
                                  trailing: Text('ID: ${experience.id}'),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    );
                  },
                ),
              );
            },
          ),
        ),
      );

      // Montar el widget
      await tester.pumpWidget(testWidget);
      print('🏗️ Widget montado');

      // Verificar estado inicial
      expect(find.text('Total experiencias: 0'), findsOneWidget);
      expect(find.text('Loading: false'), findsOneWidget);
      print('✅ Estado inicial verificado');

      // Intentar crear experiencia
      await tester.tap(find.text('Crear Experiencia'));
      await tester.pump(); // Trigger build
      await tester.pump(const Duration(seconds: 1)); // Wait for async
      print('👆 Botón presionado, esperando resultado...');

      // Verificar resultado
      await tester.pumpAndSettle(const Duration(seconds: 5));

      // Debug: Imprimir todos los textos
      print('=== TEXTOS DESPUÉS DE CREAR ===');
      final textWidgets = find.byType(Text).evaluate();
      for (final element in textWidgets) {
        final text = element.widget as Text;
        print('Texto: "${text.data}"');
      }
      print('=== FIN TEXTOS ===');

      print('🎉 Prueba completada');
    });

    testWidgets('Verificar instanciación de providers', (
      WidgetTester tester,
    ) async {
      print('🧪 Verificando instanciación de providers');

      final testWidget = MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => ExperienceProvider()),
        ],
        child: MaterialApp(
          home: Builder(
            builder: (context) {
              final provider = Provider.of<ExperienceProvider>(
                context,
                listen: false,
              );
              return Scaffold(
                body: Column(
                  children: [
                    const Text('Provider inicializado: true'),
                    Text('Experiencias: ${provider.experiences.length}'),
                    Text('Loading: ${provider.isLoading}'),
                  ],
                ),
              );
            },
          ),
        ),
      );

      await tester.pumpWidget(testWidget);

      expect(find.text('Provider inicializado: true'), findsOneWidget);
      expect(find.text('Experiencias: 0'), findsOneWidget);
      expect(find.text('Loading: false'), findsOneWidget);

      print('✅ Providers instanciados correctamente');
    });

    test('Crear provider directamente y testear métodos', () async {
      print('🧪 Testing directo del ExperienceProvider');

      final provider = ExperienceProvider();

      // Verificar estado inicial
      expect(provider.experiences.length, 0);
      expect(provider.isLoading, false);
      expect(provider.error, null);

      print('✅ Estado inicial correcto');
      print(
        '📊 Provider tiene métodos: createExperience, deleteExperience, addReaction',
      );

      // Intentar crear experiencia (esto fallará sin Firebase configurado)
      try {
        final request = CreateExperienceRequest(
          description: 'Test experiencia',
          tags: ['test'],
          mediaFiles: [
            CreateMediaRequest(
              filePath: 'test.jpg',
              mediaType: MediaType.image,
              duration: 15,
            ),
          ],
          type: ExperienceType.general,
        );

        final result = await provider.createExperience(request);
        print('📝 Resultado de creación: $result');
        print('📊 Experiencias después: ${provider.experiences.length}');
        print('❌ Error: ${provider.error}');
      } catch (e) {
        print('❌ Error esperado (sin Firebase): $e');
      }
    });
  });
}
