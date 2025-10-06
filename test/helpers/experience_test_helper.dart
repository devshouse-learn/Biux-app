import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:biux/features/experiences/presentation/providers/experience_classic_provider.dart';
import 'package:biux/features/experiences/presentation/providers/experience_creator_classic_provider.dart';
import 'package:biux/features/experiences/domain/entities/experience_entity.dart';
import 'package:biux/features/experiences/domain/repositories/experience_repository.dart';

/// Helper simplificado para testing de experiencias
class ExperienceTestHelper {
  /// Crea un widget minimal para testing de experiencias
  static Widget createExperienceTestWidget({required Widget child}) {
    return MultiProvider(
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
              ExperienceCreatorProvider(experienceProvider: experienceProvider),
        ),
      ],
      child: MaterialApp(home: Scaffold(body: child)),
    );
  }

  /// Crear experiencia de prueba en Firebase
  static Future<void> createTestExperience(ExperienceProvider provider) async {
    final request = CreateExperienceRequest(
      description:
          'Experiencia de prueba ${DateTime.now().millisecondsSinceEpoch}',
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

    await provider.createExperience(request);
  }

  /// Verificar que la experiencia aparece en la lista
  static Future<void> verifyExperienceInList(
    WidgetTester tester,
    String description,
  ) async {
    // Esperar un poco para que se carguen las experiencias
    await tester.pump(const Duration(seconds: 2));
    await tester.pumpAndSettle();

    // Debug: Imprimir todos los textos
    print('=== VERIFICANDO EXPERIENCIA: $description ===');
    final textWidgets = find.byType(Text).evaluate();
    bool encontrada = false;

    for (final element in textWidgets) {
      final text = element.widget as Text;
      print('Texto: "${text.data}"');
      if (text.data?.contains(description) == true) {
        encontrada = true;
      }
    }

    print('Experiencia encontrada: $encontrada');
    print('=== FIN VERIFICACIÓN ===');

    // Verificar que el texto aparece
    expect(
      find.textContaining(description),
      findsAtLeastNWidgets(1),
      reason: 'La experiencia "$description" debería aparecer en la lista',
    );
  }

  /// Debug: Imprimir estado del provider
  static void debugProviderState(BuildContext context) {
    try {
      final provider = Provider.of<ExperienceProvider>(context, listen: false);
      print('=== ESTADO PROVIDER ===');
      print('Experiencias: ${provider.experiences.length}');
      print('Loading: ${provider.isLoading}');
      print('Error: ${provider.error}');

      for (int i = 0; i < provider.experiences.length; i++) {
        final exp = provider.experiences[i];
        print('Experiencia $i: ${exp.description}');
      }
      print('=== FIN ESTADO ===');
    } catch (e) {
      print('Error obteniendo estado del provider: $e');
    }
  }
}
