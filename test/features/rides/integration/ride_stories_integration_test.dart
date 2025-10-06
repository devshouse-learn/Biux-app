import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

// Importaciones de biux
import 'package:biux/features/experiences/domain/entities/experience_entity.dart';
import 'package:biux/features/users/domain/entities/user_entity.dart';
import 'package:biux/features/experiences/presentation/providers/experience_classic_provider.dart';
import 'package:biux/features/experiences/domain/repositories/experience_repository.dart';

// Mock Repository para experiencias de rodadas
class MockRideExperienceRepository implements ExperienceRepository {
  final Map<String, List<ExperienceEntity>> _rideExperiences = {};
  bool _shouldThrowError = false;

  void addExperienceToRide(String rideId, ExperienceEntity experience) {
    _rideExperiences[rideId] = _rideExperiences[rideId] ?? [];
    _rideExperiences[rideId]!.add(experience);
    print(
      '🎯 Experiencia agregada a rodada $rideId: ${experience.description}',
    );
  }

  void setShouldThrowError(bool value) {
    _shouldThrowError = value;
  }

  void clearAllRideExperiences() {
    _rideExperiences.clear();
    print('🧹 Todas las experiencias de rodadas limpiadas');
  }

  List<ExperienceEntity> getRideExperiencesSync(String rideId) {
    return _rideExperiences[rideId] ?? [];
  }

  @override
  Future<List<ExperienceEntity>> getUserExperiences(String userId) async {
    if (_shouldThrowError) throw Exception('Error simulado');
    await Future.delayed(const Duration(milliseconds: 50));
    return [];
  }

  @override
  Future<List<ExperienceEntity>> getRideExperiences(String rideId) async {
    if (_shouldThrowError) throw Exception('Error cargando stories de rodada');
    await Future.delayed(const Duration(milliseconds: 50));
    return _rideExperiences[rideId] ?? [];
  }

  @override
  Future<List<ExperienceEntity>> getFollowingExperiences(String userId) async {
    if (_shouldThrowError) throw Exception('Error simulado');
    await Future.delayed(const Duration(milliseconds: 50));
    return [];
  }

  @override
  Future<ExperienceEntity> createExperience(
    CreateExperienceRequest request,
  ) async {
    if (_shouldThrowError) throw Exception('Error creando story de rodada');
    await Future.delayed(const Duration(milliseconds: 50));

    final newExperience = ExperienceEntity(
      id: 'story_${DateTime.now().millisecondsSinceEpoch}',
      description: request.description,
      tags: request.tags,
      user: _createMockUser(),
      createdAt: DateTime.now(),
      media: [],
      type: request.type,
      rideId: request.rideId,
      views: 0,
      reactions: [],
    );

    if (request.rideId != null) {
      addExperienceToRide(request.rideId!, newExperience);
    }

    return newExperience;
  }

  @override
  Future<void> deleteExperience(String experienceId) async {
    if (_shouldThrowError) throw Exception('Error eliminando story');
    await Future.delayed(const Duration(milliseconds: 50));
  }

  @override
  Future<void> addReaction(String experienceId, ReactionType reaction) async {
    if (_shouldThrowError) throw Exception('Error agregando reacción');
    await Future.delayed(const Duration(milliseconds: 50));
  }

  @override
  Future<void> removeReaction(String experienceId) async {
    if (_shouldThrowError) throw Exception('Error eliminando reacción');
    await Future.delayed(const Duration(milliseconds: 50));
  }

  @override
  Future<void> markAsViewed(String experienceId) async {
    if (_shouldThrowError) throw Exception('Error marcando como vista');
    await Future.delayed(const Duration(milliseconds: 50));
  }

  @override
  Future<String> uploadMedia({
    required String filePath,
    required MediaType mediaType,
    required String experienceId,
    Function(double)? onProgress,
  }) async {
    if (_shouldThrowError) throw Exception('Error subiendo media');
    await Future.delayed(const Duration(milliseconds: 100));
    return 'https://mock-url.com/media/$experienceId';
  }

  UserEntity _createMockUser() {
    return const UserEntity(
      id: 'user_123',
      fullName: 'Ciclista Aventurero',
      userName: 'ciclista123',
      email: 'ciclista@biux.com',
      photo: 'https://example.com/photo.jpg',
    );
  }
}

void main() {
  group('🚴‍♂️ Ride Stories Integration Tests - Stories como Instagram', () {
    late MockRideExperienceRepository mockRepository;
    late ExperienceProvider experienceProvider;

    setUp(() {
      mockRepository = MockRideExperienceRepository();
      experienceProvider = ExperienceProvider(repository: mockRepository);
    });

    tearDown(() {
      mockRepository.clearAllRideExperiences();
    });

    testWidgets('✅ Rodada sin stories muestra estado vacío correctamente', (
      WidgetTester tester,
    ) async {
      print('\n🎬 TEST: Rodada sin stories - estado inicial');
      const rideId = 'ride_empty_123';

      // Widget de prueba que simula una rodada sin stories
      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider<ExperienceProvider>(
            create: (_) => experienceProvider,
            child: Consumer<ExperienceProvider>(
              builder: (context, provider, child) {
                return Scaffold(
                  body: Column(
                    children: [
                      const Text('Rodada: Ruta del Sol'),
                      const SizedBox(height: 16),

                      // Simulación del área de stories (como Instagram)
                      Container(
                        height: 100,
                        child: Row(
                          children: [
                            // Círculo de "Agregar Story"
                            const _AddStoryCircle(),
                            const SizedBox(width: 8),

                            // Stories existentes de la rodada
                            Expanded(
                              child: provider.isLoading
                                  ? const Center(
                                      child: CircularProgressIndicator(),
                                    )
                                  : provider.rideExperiences.isEmpty
                                  ? const Center(
                                      child: Text(
                                        'No hay stories aún',
                                        style: TextStyle(color: Colors.grey),
                                      ),
                                    )
                                  : ListView.builder(
                                      scrollDirection: Axis.horizontal,
                                      itemCount:
                                          provider.rideExperiences.length,
                                      itemBuilder: (context, index) {
                                        final story =
                                            provider.rideExperiences[index];
                                        return _StoryCircle(
                                          story: story,
                                          onTap: () =>
                                              print('Tap story ${story.id}'),
                                        );
                                      },
                                    ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      );

      // Cargar stories de la rodada vacía
      print('📱 Cargando stories para rodada vacía...');
      await experienceProvider.loadRideExperiences(rideId);
      await tester.pump();

      // Verificaciones
      expect(find.text('Rodada: Ruta del Sol'), findsOneWidget);
      expect(find.text('No hay stories aún'), findsOneWidget);
      expect(find.byType(_AddStoryCircle), findsOneWidget);
      expect(find.byType(_StoryCircle), findsNothing);

      print('✅ Rodada vacía muestra estado correcto');
    });

    testWidgets('✅ Crear story en rodada - aparece inmediatamente como círculo', (
      WidgetTester tester,
    ) async {
      print('\n🎬 TEST: Crear story en rodada');
      const rideId = 'ride_with_stories_456';

      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider<ExperienceProvider>(
            create: (_) => experienceProvider,
            child: Consumer<ExperienceProvider>(
              builder: (context, provider, child) {
                return Scaffold(
                  body: Column(
                    children: [
                      const Text('Rodada: Aventura Ciclística'),
                      const SizedBox(height: 16),

                      // Área de stories
                      Container(
                        height: 100,
                        child: Row(
                          children: [
                            // Botón para agregar story
                            GestureDetector(
                              onTap: () async {
                                print('🎥 Usuario toca "Agregar Story"');
                                await provider.createExperience(
                                  const CreateExperienceRequest(
                                    description:
                                        'Vista increíble desde la montaña! 🏔️',
                                    tags: ['montaña', 'paisaje'],
                                    mediaFiles: [],
                                    type: ExperienceType.ride,
                                    rideId: rideId,
                                  ),
                                );
                              },
                              child: const _AddStoryCircle(),
                            ),
                            const SizedBox(width: 8),

                            // Stories de la rodada
                            Expanded(
                              child: provider.isLoading
                                  ? const Center(
                                      child: CircularProgressIndicator(),
                                    )
                                  : provider.rideExperiences.isEmpty
                                  ? const Center(
                                      child: Text(
                                        'No hay stories aún',
                                        style: TextStyle(color: Colors.grey),
                                      ),
                                    )
                                  : ListView.builder(
                                      scrollDirection: Axis.horizontal,
                                      itemCount:
                                          provider.rideExperiences.length,
                                      itemBuilder: (context, index) {
                                        final story =
                                            provider.rideExperiences[index];
                                        return _StoryCircle(
                                          story: story,
                                          onTap: () => print(
                                            '📖 Abriendo story: ${story.description}',
                                          ),
                                        );
                                      },
                                    ),
                            ),
                          ],
                        ),
                      ),

                      // Información de estado para testing
                      Text('Stories: ${provider.rideExperiences.length}'),
                      if (provider.error != null)
                        Text(
                          'Error: ${provider.error}',
                          style: const TextStyle(color: Colors.red),
                        ),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      );

      // Estado inicial - sin stories
      print('📱 PASO 1: Cargando rodada sin stories...');
      await experienceProvider.loadRideExperiences(rideId);
      await tester.pump();

      expect(find.text('No hay stories aún'), findsOneWidget);
      expect(find.text('Stories: 0'), findsOneWidget);
      expect(find.byType(_StoryCircle), findsNothing);

      // Crear story
      print('📱 PASO 2: Usuario crea una story...');
      await tester.tap(find.byType(_AddStoryCircle));
      await tester.pump(); // Trigger del tap
      await tester.pump(); // Resultado de la creación

      // Verificar que aparece el story circle
      expect(find.text('No hay stories aún'), findsNothing);
      expect(find.text('Stories: 1'), findsOneWidget);
      expect(find.byType(_StoryCircle), findsOneWidget);

      // Verificar datos del story
      final stories = mockRepository.getRideExperiencesSync(rideId);
      expect(stories.length, 1);
      expect(
        stories.first.description,
        'Vista increíble desde la montaña! 🏔️',
      );
      expect(stories.first.type, ExperienceType.ride);
      expect(stories.first.rideId, rideId);

      print('✅ Story creado correctamente y aparece como círculo');
    });

    testWidgets(
      '✅ Múltiples stories en rodada - se muestran como fila horizontal de círculos',
      (WidgetTester tester) async {
        print('\n🎬 TEST: Múltiples stories en rodada');
        const rideId = 'ride_multiple_stories_789';

        // Pre-poblar con algunas stories
        print('🗂️ Pre-poblando rodada con 3 stories...');
        mockRepository.addExperienceToRide(
          rideId,
          ExperienceEntity(
            id: 'story_1',
            description: 'Salida matutina 🌅',
            tags: ['mañana'],
            user: const UserEntity(
              id: 'user1',
              fullName: 'Ana García',
              userName: 'ana_biker',
              email: 'ana@biux.com',
              photo: '',
            ),
            createdAt: DateTime.now().subtract(const Duration(hours: 2)),
            media: [],
            type: ExperienceType.ride,
            rideId: rideId,
          ),
        );

        mockRepository.addExperienceToRide(
          rideId,
          ExperienceEntity(
            id: 'story_2',
            description: 'Parada para hidratarse 💧',
            tags: ['descanso'],
            user: const UserEntity(
              id: 'user2',
              fullName: 'Carlos López',
              userName: 'carlos_cyclist',
              email: 'carlos@biux.com',
              photo: '',
            ),
            createdAt: DateTime.now().subtract(const Duration(hours: 1)),
            media: [],
            type: ExperienceType.ride,
            rideId: rideId,
          ),
        );

        mockRepository.addExperienceToRide(
          rideId,
          ExperienceEntity(
            id: 'story_3',
            description: 'Meta alcanzada! 🏁',
            tags: ['meta', 'logro'],
            user: const UserEntity(
              id: 'user3',
              fullName: 'María Torres',
              userName: 'maria_mountain',
              email: 'maria@biux.com',
              photo: '',
            ),
            createdAt: DateTime.now(),
            media: [],
            type: ExperienceType.ride,
            rideId: rideId,
          ),
        );

        await tester.pumpWidget(
          MaterialApp(
            home: ChangeNotifierProvider<ExperienceProvider>(
              create: (_) => experienceProvider,
              child: Consumer<ExperienceProvider>(
                builder: (context, provider, child) {
                  return Scaffold(
                    body: Column(
                      children: [
                        const Text('Rodada: Gran Travesía'),
                        const SizedBox(height: 16),

                        // Stories horizontales (como Instagram)
                        Container(
                          height: 100,
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Row(
                            children: [
                              const _AddStoryCircle(),
                              const SizedBox(width: 8),
                              Expanded(
                                child: provider.isLoading
                                    ? const Center(
                                        child: CircularProgressIndicator(),
                                      )
                                    : ListView.builder(
                                        scrollDirection: Axis.horizontal,
                                        itemCount:
                                            provider.rideExperiences.length,
                                        itemBuilder: (context, index) {
                                          final story =
                                              provider.rideExperiences[index];
                                          return Padding(
                                            padding: const EdgeInsets.only(
                                              right: 8,
                                            ),
                                            child: _StoryCircle(
                                              story: story,
                                              onTap: () => print(
                                                '📖 Story ${index + 1}: ${story.description}',
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                              ),
                            ],
                          ),
                        ),

                        // Debug info
                        Text(
                          'Total stories: ${provider.rideExperiences.length}',
                        ),
                        Text('Loading: ${provider.isLoading}'),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
        );

        // Cargar stories
        print('📱 Cargando stories de la rodada...');
        await experienceProvider.loadRideExperiences(rideId);
        await tester.pump();

        // Verificaciones
        expect(find.text('Total stories: 3'), findsOneWidget);
        expect(find.byType(_StoryCircle), findsNWidgets(3));
        expect(find.byType(_AddStoryCircle), findsOneWidget);

        // Verificar orden cronológico (más recientes primero)
        final stories = experienceProvider.rideExperiences;
        expect(stories.length, 3);
        expect(stories[0].description, 'Meta alcanzada! 🏁'); // Más reciente
        expect(stories[1].description, 'Parada para hidratarse 💧');
        expect(stories[2].description, 'Salida matutina 🌅'); // Más antigua

        print(
          '✅ Múltiples stories se muestran correctamente en fila horizontal',
        );
      },
    );

    testWidgets(
      '✅ Error cargando stories de rodada - muestra mensaje de error',
      (WidgetTester tester) async {
        print('\n🎬 TEST: Error cargando stories');
        const rideId = 'ride_error_999';

        mockRepository.setShouldThrowError(true);

        await tester.pumpWidget(
          MaterialApp(
            home: ChangeNotifierProvider<ExperienceProvider>(
              create: (_) => experienceProvider,
              child: Consumer<ExperienceProvider>(
                builder: (context, provider, child) {
                  return Scaffold(
                    body: Column(
                      children: [
                        const Text('Rodada: Error Test'),
                        const SizedBox(height: 16),

                        Container(
                          height: 100,
                          child: provider.error != null
                              ? Center(
                                  child: Text(
                                    'Error: ${provider.error}',
                                    style: const TextStyle(color: Colors.red),
                                  ),
                                )
                              : const Center(child: Text('Cargando...')),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
        );

        // Intentar cargar stories con error
        print('📱 Intentando cargar stories con error simulado...');
        await experienceProvider.loadRideExperiences(rideId);
        await tester.pump();

        // Verificar manejo de error
        expect(
          find.textContaining('Error cargando experiencias de rodada'),
          findsOneWidget,
        );
        expect(experienceProvider.error, isNotNull);
        expect(experienceProvider.rideExperiences, isEmpty);

        print('✅ Error manejado correctamente');
      },
    );
  });
}

// Widget helper para el círculo de "Agregar Story" (como Instagram)
class _AddStoryCircle extends StatelessWidget {
  const _AddStoryCircle();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 66,
      height: 66,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: Colors.grey, width: 2),
        color: Colors.grey.withOpacity(0.1),
      ),
      child: const Icon(Icons.add, color: Colors.grey, size: 32),
    );
  }
}

// Widget helper para círculo de story individual
class _StoryCircle extends StatelessWidget {
  final ExperienceEntity story;
  final VoidCallback onTap;

  const _StoryCircle({required this.story, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 66,
        height: 66,
        margin: const EdgeInsets.only(right: 8),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: Colors
                .deepPurple, // Color tipo Instagram para stories no vistas
            width: 3,
          ),
          image: story.user.photo.isNotEmpty
              ? DecorationImage(
                  image: NetworkImage(story.user.photo),
                  fit: BoxFit.cover,
                )
              : null,
        ),
        child: story.user.photo.isEmpty
            ? Center(
                child: Text(
                  story.user.userName[0].toUpperCase(),
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.deepPurple,
                  ),
                ),
              )
            : null,
      ),
    );
  }
}
