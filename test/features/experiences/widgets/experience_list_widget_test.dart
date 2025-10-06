import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:biux/features/experiences/domain/entities/experience_entity.dart';
import 'package:biux/features/users/domain/entities/user_entity.dart';
import 'package:biux/features/experiences/domain/repositories/experience_repository.dart';
import 'package:biux/features/experiences/presentation/providers/experience_classic_provider.dart';

// Mock repository para tests
class MockExperienceRepository implements ExperienceRepository {
  List<ExperienceEntity> _experiences = [];
  bool shouldThrowError = false;

  void setExperiences(List<ExperienceEntity> experiences) {
    _experiences = experiences;
  }

  void setShouldThrowError(bool value) {
    shouldThrowError = value;
  }

  @override
  Future<List<ExperienceEntity>> getUserExperiences(String userId) async {
    if (shouldThrowError) {
      throw Exception('Error cargando experiencias de usuario');
    }
    return _experiences.where((exp) => exp.user.id == userId).toList();
  }

  @override
  Future<List<ExperienceEntity>> getRideExperiences(String rideId) async {
    if (shouldThrowError) {
      throw Exception('Error cargando experiencias de rodada');
    }
    return _experiences.where((exp) => exp.rideId == rideId).toList();
  }

  @override
  Future<List<ExperienceEntity>> getFollowingExperiences(String userId) async {
    if (shouldThrowError) {
      throw Exception('Error cargando experiencias seguidas');
    }
    return _experiences;
  }

  @override
  Future<ExperienceEntity> createExperience(
    CreateExperienceRequest request,
  ) async {
    if (shouldThrowError) {
      throw Exception('Error creando experiencia');
    }
    final newExperience = ExperienceEntity(
      id: 'new_exp_${DateTime.now().millisecondsSinceEpoch}',
      description: request.description,
      tags: request.tags,
      user: UserEntity(
        id: 'current_user',
        fullName: 'Usuario Actual',
        userName: 'usuario',
        email: 'usuario@example.com',
        photo: '',
      ),
      createdAt: DateTime.now(),
      media: [],
      type: request.type,
      rideId: request.rideId,
    );
    _experiences.add(newExperience);
    return newExperience;
  }

  @override
  Future<void> deleteExperience(String experienceId) async {
    if (shouldThrowError) {
      throw Exception('Error eliminando experiencia');
    }
    _experiences.removeWhere((exp) => exp.id == experienceId);
  }

  @override
  Future<void> addReaction(String experienceId, ReactionType reaction) async {
    if (shouldThrowError) {
      throw Exception('Error agregando reacción');
    }
  }

  @override
  Future<void> removeReaction(String experienceId) async {
    if (shouldThrowError) {
      throw Exception('Error eliminando reacción');
    }
  }

  @override
  Future<void> markAsViewed(String experienceId) async {
    if (shouldThrowError) {
      throw Exception('Error marcando como vista');
    }
  }

  @override
  Future<String> uploadMedia({
    required String filePath,
    required MediaType mediaType,
    required String experienceId,
    Function(double)? onProgress,
  }) async {
    if (shouldThrowError) {
      throw Exception('Error subiendo media');
    }
    return 'https://example.com/media/${DateTime.now().millisecondsSinceEpoch}';
  }
}

// Widget simple para mostrar una lista de experiencias
class ExperienceListWidget extends StatelessWidget {
  final String? userId;
  final String? rideId;

  const ExperienceListWidget({Key? key, this.userId, this.rideId})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<ExperienceProvider>(
        builder: (context, experienceProvider, child) {
          if (experienceProvider.isLoading) {
            return const Center(
              child: CircularProgressIndicator(key: Key('loading_indicator')),
            );
          }

          if (experienceProvider.error != null) {
            return Center(
              child: Text(
                'Error: ${experienceProvider.error}',
                key: const Key('error_text'),
              ),
            );
          }

          final experiences = experienceProvider.experiences;

          if (experiences.isEmpty) {
            return const Center(
              child: Text(
                'No hay experiencias disponibles',
                key: Key('empty_list_text'),
              ),
            );
          }

          return ListView.builder(
            key: const Key('experience_list'),
            itemCount: experiences.length,
            itemBuilder: (context, index) {
              final experience = experiences[index];
              return ListTile(
                key: Key('experience_item_$index'),
                title: Text(experience.user.fullName),
                subtitle: Text(experience.description),
                trailing: Text('${experience.media.length} media'),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        key: const Key('reload_button'),
        onPressed: () {
          if (userId != null) {
            context.read<ExperienceProvider>().loadUserExperiences(userId!);
          } else if (rideId != null) {
            context.read<ExperienceProvider>().loadRideExperiences(rideId!);
          }
        },
        child: const Icon(Icons.refresh),
      ),
    );
  }
}

void main() {
  group('ExperienceListWidget Tests', () {
    late MockExperienceRepository mockRepository;
    late ExperienceProvider experienceProvider;

    // Datos de prueba
    final testUser = UserEntity(
      id: 'user123',
      fullName: 'Juan Pérez',
      userName: 'juanp',
      email: 'juan@example.com',
      photo: 'https://example.com/photo.jpg',
    );

    final testExperience = ExperienceEntity(
      id: 'exp123',
      user: testUser,
      description: 'Una experiencia increíble',
      tags: ['ciclismo', 'aventura'],
      media: [
        ExperienceMediaEntity(
          id: 'media1',
          url: 'https://example.com/image1.jpg',
          mediaType: MediaType.image,
          duration: 0,
          thumbnailUrl: '',
        ),
      ],
      reactions: [],
      createdAt: DateTime.now(),
      rideId: 'ride123',
      type: ExperienceType.ride,
    );

    setUp(() {
      mockRepository = MockExperienceRepository();
      experienceProvider = ExperienceProvider(repository: mockRepository);
    });

    Widget createWidgetUnderTest({String? userId, String? rideId}) {
      return MaterialApp(
        home: ChangeNotifierProvider<ExperienceProvider>.value(
          value: experienceProvider,
          child: ExperienceListWidget(userId: userId, rideId: rideId),
        ),
      );
    }

    testWidgets('✅ Muestra loading al inicio', (WidgetTester tester) async {
      // Configurar experiencias de prueba
      mockRepository.setExperiences([testExperience]);

      await tester.pumpWidget(createWidgetUnderTest(userId: 'user123'));

      // Verificar que se muestra el loading inicialmente
      expect(find.byKey(const Key('loading_indicator')), findsOneWidget);
      expect(find.byKey(const Key('experience_list')), findsNothing);

      print('✅ Loading state mostrado correctamente');
    });

    testWidgets('✅ Carga y muestra experiencias correctamente', (
      WidgetTester tester,
    ) async {
      // Configurar experiencias de prueba
      mockRepository.setExperiences([testExperience]);

      await tester.pumpWidget(createWidgetUnderTest(userId: 'user123'));

      // Simular la carga de experiencias
      await tester.pump(); // Triggear la primera construcción
      await tester.pump(); // Dar tiempo para que se complete la carga

      // Verificar que no hay loading
      expect(find.byKey(const Key('loading_indicator')), findsNothing);

      // Verificar que se muestra la lista
      expect(find.byKey(const Key('experience_list')), findsOneWidget);
      expect(find.byKey(const Key('experience_item_0')), findsOneWidget);

      // Verificar contenido de la experiencia
      expect(find.text('Juan Pérez'), findsOneWidget);
      expect(find.text('Una experiencia increíble'), findsOneWidget);
      expect(find.text('1 media'), findsOneWidget);

      print('✅ Experiencias mostradas correctamente en la lista');
    });

    testWidgets('✅ Muestra mensaje cuando no hay experiencias', (
      WidgetTester tester,
    ) async {
      // Sin experiencias
      mockRepository.setExperiences([]);

      await tester.pumpWidget(createWidgetUnderTest(userId: 'user123'));

      await tester.pump(); // Triggear la primera construcción
      await tester.pump(); // Dar tiempo para que se complete la carga

      // Verificar mensaje de lista vacía
      expect(find.byKey(const Key('empty_list_text')), findsOneWidget);
      expect(find.text('No hay experiencias disponibles'), findsOneWidget);
      expect(find.byKey(const Key('experience_list')), findsNothing);

      print('✅ Estado vacío mostrado correctamente');
    });

    testWidgets('✅ Muestra error cuando falla la carga', (
      WidgetTester tester,
    ) async {
      // Configurar error
      mockRepository.setShouldThrowError(true);

      await tester.pumpWidget(createWidgetUnderTest(userId: 'user123'));

      await tester.pump(); // Triggear la primera construcción
      await tester.pump(); // Dar tiempo para que se complete la carga

      // Verificar mensaje de error
      expect(find.byKey(const Key('error_text')), findsOneWidget);
      expect(find.textContaining('Error:'), findsOneWidget);
      expect(find.byKey(const Key('experience_list')), findsNothing);

      print('✅ Estado de error mostrado correctamente');
    });

    testWidgets('✅ Reload button actualiza la lista', (
      WidgetTester tester,
    ) async {
      // Inicialmente sin experiencias
      mockRepository.setExperiences([]);

      await tester.pumpWidget(createWidgetUnderTest(userId: 'user123'));
      await tester.pump();
      await tester.pump();

      // Verificar estado inicial vacío
      expect(find.byKey(const Key('empty_list_text')), findsOneWidget);

      // Agregar experiencias al mock
      mockRepository.setExperiences([testExperience]);

      // Tocar el botón de reload
      await tester.tap(find.byKey(const Key('reload_button')));
      await tester.pump(); // loading state
      await tester.pump(); // complete loading

      // Verificar que ahora se muestran las experiencias
      expect(find.byKey(const Key('experience_list')), findsOneWidget);
      expect(find.text('Juan Pérez'), findsOneWidget);

      print('✅ Reload funciona correctamente');
    });

    testWidgets('✅ Simulación de flujo completo: crear -> actualizar UI', (
      WidgetTester tester,
    ) async {
      // Empezar sin experiencias
      mockRepository.setExperiences([]);

      await tester.pumpWidget(createWidgetUnderTest(userId: 'user123'));
      await tester.pump();
      await tester.pump();

      // Estado inicial vacío
      expect(find.byKey(const Key('empty_list_text')), findsOneWidget);
      expect(find.byKey(const Key('experience_list')), findsNothing);

      // Simular creación de nueva experiencia
      final createRequest = CreateExperienceRequest(
        description: 'Nueva experiencia',
        tags: ['nuevo'],
        mediaFiles: [],
        type: ExperienceType.ride,
        rideId: 'ride123',
      );

      final createSuccess = await experienceProvider.createExperience(
        createRequest,
      );
      await tester.pump(); // Actualizar UI después de crear

      // ⚠️ AQUÍ ES DONDE PUEDE ESTAR EL PROBLEMA REAL:
      // Después de crear una experiencia, ¿se actualiza automáticamente la UI?

      print('🔍 Resultado de crear experiencia: $createSuccess');
      print(
        '🔍 Experiencias actuales en provider: ${experienceProvider.experiences.length}',
      );
      print('🔍 Error en provider: ${experienceProvider.error}');

      // Si la lista sigue vacía después de crear, entonces el problema está aquí
      final hasExperienceList = find.byKey(const Key('experience_list'));
      final hasEmptyMessage = find.byKey(const Key('empty_list_text'));

      if (hasExperienceList.evaluate().isEmpty &&
          hasEmptyMessage.evaluate().isNotEmpty) {
        print(
          '🔴 PROBLEMA ENCONTRADO: Experiencia creada pero UI no se actualiza automáticamente',
        );
        print('   - La experiencia se guardó en el repositorio');
        print('   - Pero la UI sigue mostrando el mensaje vacío');
        print('   - Se necesita recargar manualmente');

        // Intentar reload manual
        await tester.tap(find.byKey(const Key('reload_button')));
        await tester.pump();
        await tester.pump();

        if (find.byKey(const Key('experience_list')).evaluate().isNotEmpty) {
          print('   - ✅ Después del reload manual SÍ aparece la experiencia');
          print(
            '   - 🔴 Conclusión: La UI no se actualiza automáticamente después de crear',
          );
        }
      } else {
        print('✅ UI se actualiza automáticamente después de crear experiencia');
      }

      print('✅ Flujo completo simulado');
    });
  });
}
