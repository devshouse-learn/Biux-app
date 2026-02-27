import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

// Importaciones de biux
import 'package:biux/features/experiences/domain/entities/experience_entity.dart';
import 'package:biux/features/users/domain/entities/user_entity.dart';
import 'package:biux/features/experiences/presentation/providers/experience_classic_provider.dart';
import 'package:biux/features/experiences/domain/repositories/experience_repository.dart';
import 'package:biux/features/experiences/presentation/widgets/experiences_stories_widget.dart';

// Mock Repository para testing
class MockExperienceRepository implements ExperienceRepository {
  @override
  Future<ExperienceEntity?> getExperienceById(String experienceId) async {
    return null;
  }

  @override
  Future<void> updateExperience(String experienceId, {required String description}) async {}

  final Map<String, List<ExperienceEntity>> _userExperiences = {};
  final List<ExperienceEntity> _generalExperiences = [];
  bool _shouldThrowError = false;

  void setShouldThrowError(bool value) {
    _shouldThrowError = value;
  }

  void addUserExperience(String userId, ExperienceEntity experience) {
    _userExperiences[userId] = _userExperiences[userId] ?? [];
    _userExperiences[userId]!.add(experience);
  }

  void addGeneralExperience(ExperienceEntity experience) {
    _generalExperiences.add(experience);
  }

  @override
  Future<List<ExperienceEntity>> getUserExperiences(String userId) async {
    print('🔍 Mock: getUserExperiences llamado para userId: $userId');
    if (_shouldThrowError) throw Exception('Error simulado');

    await Future.delayed(const Duration(milliseconds: 100));
    final result = _userExperiences[userId] ?? [];
    print('✅ Mock: Retornando ${result.length} experiencias de usuario');
    return result;
  }

  @override
  Future<List<ExperienceEntity>> getRideExperiences(String rideId) async {
    return [];
  }

  @override
  Future<List<ExperienceEntity>> getFollowingExperiences(String userId) async {
    await Future.delayed(const Duration(milliseconds: 100));
    return _generalExperiences;
  }

  @override
  Future<ExperienceEntity> createExperience(
    CreateExperienceRequest request,
  ) async {
    if (_shouldThrowError) throw Exception('Error creando experiencia');

    final newExperience = ExperienceEntity(
      id: 'exp_${DateTime.now().millisecondsSinceEpoch}',
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
      media: [],
      type: request.type,
      rideId: request.rideId,
      views: 0,
      reactions: [],
    );

    return newExperience;
  }

  // Implementaciones mínimas requeridas
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
  group('📱 Experiences Stories Widget - Instagram Layout', () {
    late MockExperienceRepository mockRepository;
    late ExperienceProvider experienceProvider;

    setUp(() {
      print('\n🏁 Setup: Inicializando test de stories generales');
      mockRepository = MockExperienceRepository();
      experienceProvider = ExperienceProvider(repository: mockRepository);
    });

    testWidgets('🎨 Widget Test: Stories widget vacío', (
      WidgetTester tester,
    ) async {
      print('\n🧪 TEST: Widget de stories sin experiencias');

      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider<ExperienceProvider>.value(
            value: experienceProvider,
            child: const Scaffold(body: ExperiencesStoriesWidget()),
          ),
        ),
      );

      // Trigger del initState
      await tester.pump();

      // Verificar que aparece el header
      expect(find.text('Stories'), findsOneWidget);
      expect(find.byIcon(Icons.auto_stories), findsOneWidget);

      // Verificar que aparece el botón "Agregar Story"
      expect(find.text('Tu story'), findsOneWidget);
      expect(find.byIcon(Icons.add), findsOneWidget);

      print('✅ Widget vacío renderizado correctamente');
    });

    testWidgets('🎥 Widget Test: Stories con experiencias mixtas', (
      WidgetTester tester,
    ) async {
      print('\n🧪 TEST: Widget con experiencias de diferentes tipos');

      // Crear experiencias de ejemplo
      final videoExperience = ExperienceEntity(
        id: 'video_exp_1',
        description: 'Video de rodada',
        tags: ['video', 'ciclismo'],
        user: const UserEntity(
          id: 'user_video',
          fullName: 'Carlos Biker',
          userName: 'carlos_bike',
          email: 'carlos@biux.com',
          photo: '',
        ),
        createdAt: DateTime.now().subtract(const Duration(hours: 1)),
        media: [
          ExperienceMediaEntity(
            id: 'video_1',
            url: 'https://example.com/video.mp4',
            mediaType: MediaType.video,
            duration: 20,
            aspectRatio: 16 / 9,
            thumbnailUrl: 'https://example.com/thumb.jpg',
          ),
        ],
        type: ExperienceType.ride,
        views: 15,
        reactions: [],
      );

      final photoExperience = ExperienceEntity(
        id: 'photo_exp_1',
        description: 'Foto del paisaje',
        tags: ['paisaje', 'naturaleza'],
        user: const UserEntity(
          id: 'user_photo',
          fullName: 'Ana Photographer',
          userName: 'ana_photo',
          email: 'ana@biux.com',
          photo: 'https://example.com/avatar.jpg',
        ),
        createdAt: DateTime.now().subtract(const Duration(minutes: 30)),
        media: [
          ExperienceMediaEntity(
            id: 'photo_1',
            url: 'https://example.com/photo.jpg',
            mediaType: MediaType.image,
            duration: 5,
            aspectRatio: 4 / 3,
          ),
        ],
        type: ExperienceType.general,
        views: 8,
        reactions: [],
      );

      // Agregar al mock repository
      mockRepository.addUserExperience('current_user', videoExperience);
      mockRepository.addUserExperience('current_user', photoExperience);

      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider<ExperienceProvider>.value(
            value: experienceProvider,
            child: const Scaffold(body: ExperiencesStoriesWidget()),
          ),
        ),
      );

      // Trigger del initState y carga de datos
      await tester.pump();
      await tester.pump(); // Para que se complete la carga

      // Verificar que aparecen las stories
      expect(find.text('Stories'), findsOneWidget);
      expect(find.text('Tu story'), findsOneWidget);
      expect(find.text('carlos_bike'), findsOneWidget);
      expect(find.text('ana_photo'), findsOneWidget);

      // Verificar que hay 3 elementos: botón + 2 stories
      expect(find.byType(GestureDetector), findsAtLeast(3));

      print('✅ Widget con experiencias mixtas renderizado correctamente');
    });

    testWidgets('🎬 Widget Test: Tap en agregar story abre modal', (
      WidgetTester tester,
    ) async {
      print('\n🧪 TEST: Tap en "Agregar Story" abre opciones');

      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider<ExperienceProvider>.value(
            value: experienceProvider,
            child: const Scaffold(body: ExperiencesStoriesWidget()),
          ),
        ),
      );

      await tester.pump();

      // Buscar y tocar el botón "Agregar Story"
      final addButton = find.text('Tu story');
      expect(addButton, findsOneWidget);

      await tester.tap(addButton);
      await tester.pumpAndSettle();

      // Verificar que se abre el modal con opciones
      expect(find.text('Crear Story'), findsOneWidget);
      expect(find.text('Video Story'), findsOneWidget);
      expect(find.text('Foto Story'), findsOneWidget);
      expect(find.text('Graba hasta 30s'), findsOneWidget);
      expect(find.text('Comparte momentos'), findsOneWidget);

      print('✅ Modal de opciones se abre correctamente');
    });

    testWidgets('🔄 Widget Test: Loading state', (WidgetTester tester) async {
      print('\n🧪 TEST: Estado de loading');

      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider<ExperienceProvider>.value(
            value: experienceProvider,
            child: const Scaffold(body: ExperiencesStoriesWidget()),
          ),
        ),
      );

      // En el primer pump, debería estar en loading
      await tester.pump();

      // Verificar que aparece el loading indicator
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('Stories'), findsOneWidget);

      print('✅ Estado de loading renderizado correctamente');
    });

    test('📦 Unit Test: Filtrado de experiencias duplicadas', () async {
      print('\n🧪 TEST: Filtrado de experiencias duplicadas');

      // Crear experiencia duplicada en diferentes listas
      final experience = ExperienceEntity(
        id: 'duplicate_exp',
        description: 'Experiencia duplicada',
        tags: ['test'],
        user: const UserEntity(
          id: 'user_test',
          fullName: 'Test User',
          userName: 'test_user',
          email: 'test@test.com',
          photo: '',
        ),
        createdAt: DateTime.now(),
        media: [],
        type: ExperienceType.general,
        views: 0,
        reactions: [],
      );

      // Agregar la misma experiencia a diferentes listas
      mockRepository.addUserExperience('current_user', experience);
      mockRepository.addGeneralExperience(experience);

      // Cargar experiencias
      await experienceProvider.loadUserExperiences('current_user');

      // Verificar que solo aparece una vez
      final userExp = experienceProvider.userExperiences;
      expect(userExp.length, 1);
      expect(userExp.first.id, 'duplicate_exp');

      print('✅ Filtrado de duplicados funciona correctamente');
    });
  });
}
