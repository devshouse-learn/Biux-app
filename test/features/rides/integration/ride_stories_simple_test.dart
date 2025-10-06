import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

// Importaciones de biux
import 'package:biux/features/experiences/domain/entities/experience_entity.dart';
import 'package:biux/features/users/domain/entities/user_entity.dart';
import 'package:biux/features/experiences/presentation/providers/experience_classic_provider.dart';
import 'package:biux/features/experiences/domain/repositories/experience_repository.dart';

// Mock Repository simplificado
class SimpleMockRepository implements ExperienceRepository {
  final Map<String, List<ExperienceEntity>> _rideExperiences = {};
  bool _shouldThrowError = false;

  void setShouldThrowError(bool value) {
    _shouldThrowError = value;
  }

  void addExperienceToRide(String rideId, ExperienceEntity experience) {
    _rideExperiences[rideId] = _rideExperiences[rideId] ?? [];
    _rideExperiences[rideId]!.add(experience);
  }

  @override
  Future<List<ExperienceEntity>> getRideExperiences(String rideId) async {
    print('🔍 Mock: getRideExperiences llamado para rideId: $rideId');

    if (_shouldThrowError) {
      print('❌ Mock: Simulando error');
      throw Exception('Error simulado');
    }

    // Simular delay de red
    await Future.delayed(const Duration(milliseconds: 100));

    final result = _rideExperiences[rideId] ?? [];
    print('✅ Mock: Retornando ${result.length} experiencias');
    return result;
  }

  @override
  Future<ExperienceEntity> createExperience(
    CreateExperienceRequest request,
  ) async {
    print('🚀 Mock: createExperience llamado');
    if (_shouldThrowError) throw Exception('Error creando story');

    await Future.delayed(const Duration(milliseconds: 50));

    final newExperience = ExperienceEntity(
      id: 'story_${DateTime.now().millisecondsSinceEpoch}',
      description: request.description,
      tags: request.tags,
      user: const UserEntity(
        id: 'current_user',
        fullName: 'Usuario Test',
        userName: 'test_user',
        email: 'test@biux.com',
        photo: '',
      ),
      createdAt: DateTime.now(),
      media: [
        // Agregar un video de ejemplo para testing
        ExperienceMediaEntity(
          id: 'video_1',
          url: 'https://example.com/video.mp4',
          mediaType: MediaType.video,
          duration: 15,
          aspectRatio: 16 / 9,
          thumbnailUrl: 'https://example.com/thumb.jpg',
        ),
      ],
      type: request.type,
      rideId: request.rideId,
      views: 0,
      reactions: [],
    );

    if (request.rideId != null) {
      addExperienceToRide(request.rideId!, newExperience);
    }

    print('✅ Mock: Experiencia creada: ${newExperience.id}');
    return newExperience;
  }

  // Implementaciones mínimas requeridas
  @override
  Future<List<ExperienceEntity>> getUserExperiences(String userId) async => [];

  @override
  Future<List<ExperienceEntity>> getFollowingExperiences(String userId) async =>
      [];

  @override
  Future<void> deleteExperience(String experienceId) async {}

  @override
  Future<void> addReaction(String experienceId, ReactionType reaction) async {}

  @override
  Future<void> removeReaction(String experienceId) async {}

  @override
  Future<void> markAsViewed(String experienceId) async {}

  @override
  Future<String> uploadMedia({
    required String filePath,
    required MediaType mediaType,
    required String experienceId,
    Function(double)? onProgress,
  }) async => 'mock_url';
}

void main() {
  group('🚴‍♂️ Ride Stories - Tests Simplificados', () {
    late SimpleMockRepository mockRepository;
    late ExperienceProvider experienceProvider;

    setUp(() {
      print('\n🏁 Setup: Inicializando test');
      mockRepository = SimpleMockRepository();
      experienceProvider = ExperienceProvider(repository: mockRepository);
    });

    test('📦 Unit Test: Cargar stories de rodada vacía', () async {
      print('\n🧪 TEST: Provider carga rodada vacía correctamente');
      const rideId = 'ride_empty_123';

      // Estado inicial
      expect(experienceProvider.rideExperiences, isEmpty);
      expect(experienceProvider.isLoading, false);

      // Cargar stories
      print('📱 Iniciando loadRideExperiences...');
      final loadingFuture = experienceProvider.loadRideExperiences(rideId);

      // Verificar estado de loading
      expect(experienceProvider.isLoading, true);

      // Esperar resultado
      await loadingFuture;

      // Verificar resultado final
      expect(experienceProvider.isLoading, false);
      expect(experienceProvider.rideExperiences, isEmpty);
      expect(experienceProvider.error, isNull);

      print('✅ Test unitario completado correctamente');
    });

    test('📦 Unit Test: Crear story en rodada', () async {
      print('\n🧪 TEST: Crear story en rodada');
      const rideId = 'ride_create_story_456';

      // Estado inicial
      expect(experienceProvider.rideExperiences, isEmpty);

      // Crear story
      print('📝 Creando nueva story...');
      await experienceProvider.createExperience(
        const CreateExperienceRequest(
          description: 'Nueva story de test! 🚴‍♂️',
          tags: ['test', 'aventura'],
          mediaFiles: [],
          type: ExperienceType.ride,
          rideId: rideId,
        ),
      );

      // Cargar stories para verificar
      await experienceProvider.loadRideExperiences(rideId);

      // Verificar que la story aparece
      expect(experienceProvider.rideExperiences.length, 1);
      expect(
        experienceProvider.rideExperiences.first.description,
        'Nueva story de test! 🚴‍♂️',
      );
      expect(experienceProvider.rideExperiences.first.rideId, rideId);
      expect(
        experienceProvider.rideExperiences.first.type,
        ExperienceType.ride,
      );

      print('✅ Story creada y cargada correctamente');
    });

    test('📦 Unit Test: Múltiples stories en rodada', () async {
      print('\n🧪 TEST: Múltiples stories en rodada');
      const rideId = 'ride_multiple_stories_789';

      // Pre-poblar con algunas stories
      mockRepository.addExperienceToRide(
        rideId,
        ExperienceEntity(
          id: 'story_1',
          description: 'Primera story 🌅',
          tags: ['inicio'],
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
          description: 'Segunda story 💧',
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
          description: 'Tercera story 🏁',
          tags: ['meta'],
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

      // Cargar stories
      await experienceProvider.loadRideExperiences(rideId);

      // Verificar
      expect(experienceProvider.rideExperiences.length, 3);
      expect(experienceProvider.error, isNull);
      expect(experienceProvider.isLoading, false);

      // Verificar contenido de las stories
      final stories = experienceProvider.rideExperiences;
      expect(stories.any((s) => s.description.contains('Primera story')), true);
      expect(stories.any((s) => s.description.contains('Segunda story')), true);
      expect(stories.any((s) => s.description.contains('Tercera story')), true);

      print('✅ Múltiples stories cargadas correctamente');
    });

    test('📦 Unit Test: Error al cargar stories', () async {
      print('\n🧪 TEST: Manejo de errores');
      const rideId = 'ride_error_999';

      // Configurar error
      mockRepository.setShouldThrowError(true);

      // Intentar cargar
      await experienceProvider.loadRideExperiences(rideId);

      // Verificar manejo de error
      expect(experienceProvider.error, isNotNull);
      expect(
        experienceProvider.error!.contains(
          'Error cargando experiencias de rodada',
        ),
        true,
      );
      expect(experienceProvider.rideExperiences, isEmpty);
      expect(experienceProvider.isLoading, false);

      print('✅ Error manejado correctamente');
    });

    test('🎥 Unit Test: Story con video muestra indicador', () async {
      print('\n🧪 TEST: Story con video tiene indicador visual');
      const rideId = 'ride_video_story_789';

      // Crear story con video directamente en el mock
      final videoStory = ExperienceEntity(
        id: 'video_story_123',
        description: 'Video de la rodada épica',
        tags: ['video', 'aventura'],
        user: const UserEntity(
          id: 'video_user',
          fullName: 'Video Creator',
          userName: 'videocreator',
          email: 'video@biux.com',
          photo: '',
        ),
        createdAt: DateTime.now(),
        media: [
          ExperienceMediaEntity(
            id: 'video_media_1',
            url: 'https://example.com/epic_ride.mp4',
            mediaType: MediaType.video,
            duration: 25,
            aspectRatio: 16 / 9,
            thumbnailUrl: 'https://example.com/epic_thumb.jpg',
          ),
        ],
        type: ExperienceType.ride,
        rideId: rideId,
        views: 0,
        reactions: [],
      );

      mockRepository.addExperienceToRide(rideId, videoStory);

      // Cargar stories
      await experienceProvider.loadRideExperiences(rideId);

      // Verificar que la story tiene video
      expect(experienceProvider.rideExperiences.length, 1);
      final loadedStory = experienceProvider.rideExperiences.first;
      expect(loadedStory.hasVideo, true);
      expect(loadedStory.media.length, 1);
      expect(loadedStory.media.first.mediaType, MediaType.video);
      expect(loadedStory.media.first.duration, 25);

      print('✅ Story con video verificada correctamente');
    });

    testWidgets('🎨 Widget Test: Stories widget básico con videos', (
      WidgetTester tester,
    ) async {
      print('\n🧪 TEST: Widget test básico');
      const rideId = 'ride_widget_test';

      // Pre-poblar con una story
      mockRepository.addExperienceToRide(
        rideId,
        ExperienceEntity(
          id: 'story_widget',
          description: 'Story para widget test',
          tags: ['test'],
          user: const UserEntity(
            id: 'user_widget',
            fullName: 'Usuario Widget',
            userName: 'widget_user',
            email: 'widget@test.com',
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
                      Text('Stories: ${provider.rideExperiences.length}'),
                      Text('Loading: ${provider.isLoading}'),
                      Text('Error: ${provider.error ?? "ninguno"}'),
                      ElevatedButton(
                        onPressed: () {
                          provider.loadRideExperiences(rideId);
                        },
                        child: const Text('Cargar Stories'),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      );

      // Estado inicial
      expect(find.text('Stories: 0'), findsOneWidget);
      expect(find.text('Loading: false'), findsOneWidget);

      // Trigger carga
      await tester.tap(find.text('Cargar Stories'));
      await tester.pump(); // Trigger loading state

      expect(find.text('Loading: true'), findsOneWidget);

      // Esperar resultado (pump con duración para simular async)
      await tester.pump(const Duration(milliseconds: 200));

      expect(find.text('Stories: 1'), findsOneWidget);
      expect(find.text('Loading: false'), findsOneWidget);

      print('✅ Widget test completado');
    });
  });
}
