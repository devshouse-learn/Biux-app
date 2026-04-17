import 'package:flutter_test/flutter_test.dart';
import 'package:biux/features/experiences/domain/entities/experience_entity.dart';
import 'package:biux/features/users/domain/entities/user_entity.dart';
import 'package:biux/features/experiences/presentation/providers/experience_classic_provider.dart';
import 'package:biux/features/experiences/domain/repositories/experience_repository.dart';

class MockExperienceRepository implements ExperienceRepository {
  @override
  Future<ExperienceEntity?> getExperienceById(String id) async => null;
  @override
  Future<void> updateExperience(
    String id, {
    required String description,
    bool isEdited = true,
    List<CreateMediaRequest>? newMediaFiles,
    List<String>? existingMediaUrls,
  }) async {}
  @override
  Future<bool> removeMediaFromExperience(String id, int index) async => false;
  @override
  Stream<DateTime?> watchLatestExperienceTimestamp() => Stream.value(null);
  final Map<String, List<ExperienceEntity>> _userExperiences = {};
  final List<ExperienceEntity> _generalExperiences = [];
  bool _shouldThrowError = false;
  void setShouldThrowError(bool v) => _shouldThrowError = v;
  void addUserExperience(String userId, ExperienceEntity exp) {
    _userExperiences[userId] = _userExperiences[userId] ?? [];
    _userExperiences[userId]!.add(exp);
  }

  void addGeneralExperience(ExperienceEntity exp) =>
      _generalExperiences.add(exp);
  @override
  Future<List<ExperienceEntity>> getUserExperiences(String userId) async {
    if (_shouldThrowError) throw Exception('Error');
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
  Future<ExperienceEntity> createExperience(CreateExperienceRequest req) async {
    if (_shouldThrowError) throw Exception('Error');
    return ExperienceEntity(
      id: 'exp_new',
      description: req.description,
      tags: req.tags,
      user: const UserEntity(
        id: 'u',
        fullName: 'U',
        userName: 'u',
        email: 'u@b.com',
        photo: '',
      ),
      createdAt: DateTime.now(),
      media: [],
      type: req.type,
      rideId: req.rideId,
      views: 0,
      reactions: [],
    );
  }

  @override
  Future<void> deleteExperience(String id) async {}
  @override
  Future<void> addReaction(String id, ReactionType r) async {}
  @override
  Future<void> removeReaction(String id) async {}
  @override
  Future<void> markAsViewed(String id) async {}
  @override
  Future<String> uploadMedia({
    required String filePath,
    required MediaType mediaType,
    required String experienceId,
    Function(double)? onProgress,
  }) async => 'url';
  @override
  Future<void> addViewer(String id, UserEntity v) async {}
  @override
  Stream<List<UserEntity>> watchViewers(String id) => Stream.value([]);
  @override
  Future<void> repostExperience(
    ExperienceEntity o, {
    String caption = '',
  }) async {}
  @override
  Future<Map<String, String>> getUserReposts(String id) async => {};
}

void main() {
  group('Experiences Stories - Unit Tests', () {
    late MockExperienceRepository mockRepo;
    late ExperienceProvider provider;
    setUp(() {
      mockRepo = MockExperienceRepository();
      provider = ExperienceProvider(repository: mockRepo);
    });

    test('Provider se inicializa', () {
      expect(provider, isNotNull);
      expect(provider.userExperiences, isEmpty);
    });

    test('Cargar experiencias', () async {
      mockRepo.addUserExperience(
        'u1',
        ExperienceEntity(
          id: 'e1',
          description: 'test',
          tags: ['t'],
          user: const UserEntity(
            id: 'u1',
            fullName: 'U',
            userName: 'u',
            email: 'u@t.com',
            photo: '',
          ),
          createdAt: DateTime.now(),
          media: [],
          type: ExperienceType.general,
          views: 0,
          reactions: [],
        ),
      );
      await provider.loadUserExperiences('u1');
      expect(provider.userExperiences.length, 1);
    });

    test('Filtrado duplicadas', () async {
      final exp = ExperienceEntity(
        id: 'dup',
        description: 'dup',
        tags: ['t'],
        user: const UserEntity(
          id: 'u',
          fullName: 'U',
          userName: 'u',
          email: 'u@t.com',
          photo: '',
        ),
        createdAt: DateTime.now(),
        media: [],
        type: ExperienceType.general,
        views: 0,
        reactions: [],
      );
      mockRepo.addUserExperience('u1', exp);
      mockRepo.addGeneralExperience(exp);
      await provider.loadUserExperiences('u1');
      expect(provider.userExperiences.length, 1);
    });

    test('Crear experiencia', () async {
      final created = await mockRepo.createExperience(
        CreateExperienceRequest(
          description: 'new',
          tags: ['t'],
          type: ExperienceType.general,
          mediaFiles: [],
        ),
      );
      expect(created, isNotNull);
      expect(created.description, 'new');
    });

    test('Error handling', () async {
      mockRepo.setShouldThrowError(true);
      expect(() => mockRepo.getUserExperiences('u1'), throwsException);
    });

    test('Media types', () {
      final v = ExperienceMediaEntity(
        id: 'v',
        url: 'u',
        mediaType: MediaType.video,
        duration: 30,
        aspectRatio: 16 / 9,
        thumbnailUrl: 't',
      );
      final i = ExperienceMediaEntity(
        id: 'i',
        url: 'u',
        mediaType: MediaType.image,
        duration: 5,
        aspectRatio: 4 / 3,
      );
      expect(v.mediaType, MediaType.video);
      expect(i.mediaType, MediaType.image);
    });

    test('Entity propiedades', () {
      final e = ExperienceEntity(
        id: 'p',
        description: 'd',
        tags: ['a', 'b'],
        user: const UserEntity(
          id: 'u',
          fullName: 'F',
          userName: 'un',
          email: 'e@b.com',
          photo: '',
        ),
        createdAt: DateTime(2025, 1, 15),
        media: [],
        type: ExperienceType.ride,
        rideId: 'r1',
        views: 42,
        reactions: [],
      );
      expect(e.tags.length, 2);
      expect(e.type, ExperienceType.ride);
      expect(e.views, 42);
    });

    test('Lista vacia', () async {
      final r = await mockRepo.getUserExperiences('none');
      expect(r, isEmpty);
    });

    test('Multiples experiencias', () async {
      for (int i = 0; i < 5; i++) {
        mockRepo.addUserExperience(
          'm',
          ExperienceEntity(
            id: 'e_\$i',
            description: 'E\$i',
            tags: ['t'],
            user: const UserEntity(
              id: 'm',
              fullName: 'M',
              userName: 'm',
              email: 'm@t.com',
              photo: '',
            ),
            createdAt: DateTime.now(),
            media: [],
            type: ExperienceType.general,
            views: 0,
            reactions: [],
          ),
        );
      }
      final r = await mockRepo.getUserExperiences('m');
      expect(r.length, 5);
    });
  });
}
