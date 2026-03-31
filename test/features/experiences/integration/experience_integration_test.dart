import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:biux/features/experiences/presentation/providers/experience_classic_provider.dart';
import '../../../helpers/experience_test_helper.dart';

void main() {
  group('Pruebas de Integración - Experiencias', () {
    testWidgets('Crear experiencia y verificar que aparece en la lista', (
      WidgetTester tester,
    ) async {
      print('🧪 Iniciando prueba de integración - Crear experiencia');

      // Configurar el widget de prueba
      final testWidget = ExperienceTestHelper.createExperienceTestWidget(
        child: Builder(
          builder: (context) {
            return Column(
              children: [
                // Botón para crear experiencia
                ElevatedButton(
                  onPressed: () async {
                    print('📝 Creando experiencia de prueba...');
                    final provider = Provider.of<ExperienceProvider>(
                      context,
                      listen: false,
                    );
                    await ExperienceTestHelper.createTestExperience(provider);
                    print('✅ Experiencia creada');
                  },
                  child: const Text('Crear Experiencia'),
                ),
                // Lista de experiencias
                Expanded(
                  child: Consumer<ExperienceProvider>(
                    builder: (context, provider, child) {
                      print(
                        '🔄 Rebuilding lista - ${provider.experiences.length} experiencias',
                      );

                      if (provider.isLoading) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      if (provider.error != null) {
                        return Center(child: Text('Error: ${provider.error}'));
                      }

                      if (provider.experiences.isEmpty) {
                        return const Center(child: Text('No hay experiencias'));
                      }

                      return ListView.builder(
                        itemCount: provider.experiences.length,
                        itemBuilder: (context, index) {
                          final experience = provider.experiences[index];
                          return ListTile(
                            title: Text(experience.description),
                            subtitle: Text(
                              'Tags: ${experience.tags.join(', ')}',
                            ),
                            trailing: Text('ID: ${experience.id}'),
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            );
          },
        ),
      );

      // Montar el widget
      await tester.pumpWidget(testWidget);
      print('🏗️ Widget montado');

      // Verificar estado inicial
      expect(find.text('Crear Experiencia'), findsOneWidget);
      expect(find.text('No hay experiencias'), findsOneWidget);
      print('✅ Estado inicial verificado');

      // Crear experiencia
      await tester.tap(find.text('Crear Experiencia'));
      print('👆 Botón presionado');

      // Esperar que se complete la operación
      await tester.pump(); // Dispara el rebuild inmediato
      await tester.pump(
        const Duration(seconds: 1),
      ); // Espera para operaciones async
      await tester.pumpAndSettle(); // Espera todas las animaciones
      print('⏳ Esperando completar operación...');

      // Debug: Verificar estado del provider
      final BuildContext context = tester.element(find.byType(Column));
      ExperienceTestHelper.debugProviderState(context);

      // Debug: Imprimir todos los textos en pantalla
      print('=== TEXTOS EN PANTALLA ===');
      final textWidgets = find.byType(Text).evaluate();
      for (final element in textWidgets) {
        final text = element.widget as Text;
        print('Texto: "${text.data}"');
      }
      print('=== TOTAL: ${textWidgets.length} textos ===');

      // Verificar que ya no aparece "No hay experiencias"
      expect(
        find.text('No hay experiencias'),
        findsNothing,
        reason:
            'Después de crear una experiencia, no debería mostrar "No hay experiencias"',
      );

      // Verificar que aparece al menos una experiencia
      expect(
        find.byType(ListTile),
        findsAtLeastNWidgets(1),
        reason: 'Debería haber al menos un ListTile con la experiencia creada',
      );

      print('🎉 Prueba completada exitosamente');
    });

    testWidgets('Cargar experiencias existentes', (WidgetTester tester) async {
      print('🧪 Iniciando prueba de carga de experiencias existentes');

      final testWidget = ExperienceTestHelper.createExperienceTestWidget(
        child: Builder(
          builder: (context) {
            return Column(
              children: [
                ElevatedButton(
                  onPressed: () async {
                    print('🔄 Cargando experiencias...');
                    final provider = Provider.of<ExperienceProvider>(
                      context,
                      listen: false,
                    );
                    await provider.loadUserExperiences('test_user_id');
                    print('✅ Experiencias cargadas');
                  },
                  child: const Text('Cargar Experiencias'),
                ),
                Expanded(
                  child: Consumer<ExperienceProvider>(
                    builder: (context, provider, child) {
                      if (provider.isLoading) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      if (provider.error != null) {
                        return Center(child: Text('Error: ${provider.error}'));
                      }

                      return Column(
                        children: [
                          Text(
                            'Total experiencias: ${provider.experiences.length}',
                          ),
                          Expanded(
                            child: ListView.builder(
                              itemCount: provider.experiences.length,
                              itemBuilder: (context, index) {
                                final experience = provider.experiences[index];
                                return Card(
                                  child: ListTile(
                                    title: Text(experience.description),
                                    subtitle: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Usuario: ${experience.user.fullName}',
                                        ),
                                        Text('Fecha: ${experience.createdAt}'),
                                        Text('Tipo: ${experience.type}'),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ],
            );
          },
        ),
      );

      await tester.pumpWidget(testWidget);

      // Cargar experiencias
      await tester.tap(find.text('Cargar Experiencias'));
      await tester.pump();
      await tester.pump(const Duration(seconds: 2));
      await tester.pumpAndSettle();

      // Debug del estado
      final BuildContext context = tester.element(find.byType(Column));
      ExperienceTestHelper.debugProviderState(context);

      print('🎉 Prueba de carga completada');
    });
  });
}
