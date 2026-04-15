import 'package:flutter_test/flutter_test.dart';

import 'package:biux/features/experiences/domain/entities/experience_entity.dart';
import 'package:biux/features/users/domain/entities/user_entity.dart';
import 'package:biux/features/experiences/presentation/providers/experience_classic_provider.dart';
import 'package:biux/features/experiences/domain/repositories/experience_repository.dart';

class MockExperienceRepository implements ExperienceRepository {
  @override
  Future<ExperienceEntity?> getExperienceById(String experienceId) async => null;

  @override
  Future<void> updateExperience(
    String experienceId, {
    required String description,
    bool isEdited = true,
    List<CreateMediaRequest>? newMediaFiles,
    List<String>? existingMediaUrls,
  }) async {}

  @override
  Future<bool> removeMediaFromExperience(String experienceId, int mediaIndex) async => false;

  @override
  Stream<DateTime?> watchLatestExperienceTimestamp() => Stream.value(null);

  final Map<String, List<ExperienceEntity>> _userExperiences = {};
  final List<ExperienceEntity> _generalExperiences = [];
  bool _shouldThrowError = false;

  void setShouldThrowError(bool value) => _shouldThrowError = value;

  void addUserExperience(String userId, ExperienceEntity experience) {
    _userExperiences[userId] = _userExperiences[userId] ?? [];
    _userExperiences[userId]!.add(experience);
  }

  void addGeneralExperience(ExperienceEntity experience) {
    _generalExperiences.add(experience);
  }

  @override
  Future<List<ExperienceEntity>> getUserExperiences(String userId) async {
    if (_shouldThrowError) throw Exception('Error simulado');
    await Future.delayed(const Duration(milliseconds: 100));
    return _userExperiences[userId] ?? [];
  }

  @override
  Future<List<ExperienceEntity>> getRideExperiences(String rideId) async => [];

  @override
  Future<List<ExperienceEntity>> getFollowingExperiences(String userId) async {
    await Future.delayed(const Duration(milliseconds: 100));
    return _generalExperiences;
  }

  @override
  Future<ExperienceEntity> createExperience(CreateExperienceRequest request) async {
    if (_shouldThrowError) throw Exception('Error creando experiencia');
    return ExperienceEntity(
      id: 'exp_${DateTime.now().millisecondsSinceEpoch}',
      description: request.description,
      tags: request.tags,
      user: const UserEntity(id: 'current_user', fullName: 'Usuario Test', userName: 'test_user', email: 'test@biux.com', photo: ''),
      createdAt: DateTime.now(),
      media: [],
      type: request.type,
      rideId: request.rideId,
      views: 0,
      reactions: [],
    );
  }

  @override
  Future<void> deleteExperience(String experienceId) async {}
  @override
  Future<void> addReaction(String experienceId, ReactionType reaction) async {}
  @override
  Future<void> removeReaction(String experienceId) async {}
  @override
  Future<void> markAsViewed(String experienceId) async {}
  @override
  Future<String> uploadMedia({required String filePath, required MediaType mediaType, required String experienceId, Function(double)? onProgress}) async => 'mock_url';
  @override
  Future<void> addViewer(String experienceId, UserEntity viewer) async {}
  @override
  Stream<List<UserEntity>> watchViewers(String experienceId) => Stream.value([]);
  @override
  Future<void> repostExperience(ExperienceEntity original, {String caption = ''}) async {}
  @override
  Future<Map<String, String>> getUserReposts(String userId) async => {};
}

void main() {
  group('Experiences Stories Widget - Unit Tests', () {
    late MockExperienceRepository mockRepository;
    late ExperienceProvider experienceProvider;

    setUp(() {
      mockRepository = MockExperienceRepository();
      experienceProvider = ExperienceProvider(repository: mockRepository);
    });

    test('ExperienceProvider se inicializa correctamente', () {
      expect(experienceProvider, isNotNull);
      expect(experienceProvider.userExperiences, isEmpty);
    });

    test('Cargar experiencias de usuario', () async {
      final experience = ExperienceEntity(
        id: 'test_exp_1', description: 'Test experience', tags: ['test'],
        user: const UserEntity(id: 'current_user', fullName: 'Test User', userName: 'test_user', email: 'test@test.com', photo: ''),
        createdAt: DateTime.now(), media: [], type: ExperienceType.general, views: 0, reactions: [],
      );
      mockRepository.addUserExperience('current_user', experience);
      await experienceProvider.loadUserExperiences('current_user');
      expect(experienceProvider.userExperiences.length, 1);
      expect(experienceProvider.userExperiences.first.id, 'test_exp_1');
    });

    test('Filtrado de experiencias duplicadas', () async {
      final experience = ExperienceEntity(
        id: 'duplicate_exp', description: 'Experiencia duplicada', tags: ['test'],
        user: const UserEntity(id: 'user_test', fullName: 'Test User', userName: 'test_user', email: 'test@test.com', photo: ''),
        createdAt: DateTime.now(), media: [], type: ExperienceType.general, views: 0, reactions: [],
      );
      mockRepository.addUserExperience('current_user', experience);
      mockRepository.addGeneralExperience(experience);
      await experienceProvider.loadUserExperiences('current_user');
      final userExp = experienceProvider.userExperiences;
      expect(userExp.length, 1);
      expect(userExp.first.id, 'duplicate_exp');
    });

    test('Crear experiencia via repository', () async {
      final request = CreateExperienceRequest(description: 'Nueva experiencia', tags: ['ciclismo', 'test'], type: ExperienceType.general, mediaFiles: []);
      final created = await mockRepository.createExperience(request);
      expect(created, isNotNull);
      expect(created.description, 'Nueva experiencia');
      expect(created.tags, contains('ciclismo'));
    });

    test('Error handling en repository', () async {
      mockRepository.setShouldThrowError(true);
      expect(() => mockRepository.getUserExperiences('current_user'), throwsException);
    });

    test('Media types diferentes', () {
      final videoMedia = ExperienceMediaEntity(id: 'v1', url: 'https://example.com/video.mp4', mediaType: MediaType.video, duration: 30, aspectRatio: 16 / 9, thumbnailUrl: 'https://example.com/thumb.jpg');
      final imageMedia = ExperienceMediaEntity(id: 'i1', url: 'https://example.com/photo.jpg', mediaType: MediaType.image, duration: 5, aspectRatio: 4 / 3);
      expect(videoMedia.mediaType, MediaType.video);
      expect(imageMedia.mediaType, MediaType.image);
    });

    test('ExperienceEntity propiedades', () {
      final exp = ExperienceEntity(
        id: 'prop_test', description: 'Test props', tags: ['tag1', 'tag2'],
        user: const UserEntity(id: 'u1', fullName: 'User', userName: 'user', email: 'u@b.com', photo: ''),
        createdAt: DateTime(2025, 1, 15), media: [], type: ExperienceType.ride, rideId: 'ride_123', views: 42, reactions: [],
      );
      expect(exp.id, 'prop_test');
      expect(exp.tags.length, 2);
      expect(exp.type, ExperienceType.ride);
      expect(exp.rideId, 'ride_123');
      expect(exp.views, 42);
    });

    test('UserEntity en experiencia', () {
      const user = UserEntity(id: 'u1', fullName: 'Ana', userName: 'ana', email: 'ana@b.com', photo: 'https://example.com/ana.jpg');
      expect(user.id, 'u1');
      expect(user.fullName, 'Ana');
      expect(user.photo, isNotEmpty);
    });

    test('Repository retorna lista vacia', () async {
      final exps = await mockRepository.getUserExperiences('unknown');
      expect(exps, isEmpty);
    });

    test('Multiples experiencias por usuario', () async {
      for (int i = 0; i < 5; i++) {
        mockRepository.addUserExperience('multi', ExperienceEntity(
          id: 'exp_$i', description: 'Exp $i', tags: ['t$i'],
          user: const UserEntity(id: 'multi', fullName: 'Multi', userName: 'multi', email: 'm@t.com', photo: ''),
          createdAt: DateTime.now().subtract(Duration(hours: i)), media: [], type: ExperienceType.general, views: i * 10, reactions: [],
        ));
      }
      final exps = await mockRepository.getUserExperiences('multi');
      expect(exps.length, 5);
    });
  });
}
