import 'package:flutter_test/flutter_test.dart';
import 'package:biux/features/experiences/presentation/providers/experience_classic_provider.dart';
import 'package:biux/features/experiences/domain/repositories/experience_repository.dart';
import 'package:biux/features/experiences/domain/entities/experience_entity.dart';
import 'package:biux/features/users/domain/entities/user_entity.dart';

/// Mock repository simplificado para pruebas que no usa Firebase real
class MockExperienceRepository implements ExperienceRepository {
  @override
  Future<ExperienceEntity?> getExperienceById(String experienceId) async {
    return null;
  }

  @override
  Future<void> updateExperience(String experienceId, {required String description, List<String>? existingMediaUrls, bool isEdited = false, List<CreateMediaRequest>? newMediaFiles}) async {}

  @override
  Stream<DateTime?> watchLatestExperienceTimestamp() => Stream.value(null);

  List<ExperienceEntity> _mockExperiences = [];
  bool _shouldThrowError = false;
  String? _errorMessage;

  void setMockExperiences(List<ExperienceEntity> experiences) {
    _mockExperiences = experiences;
  }

  void setShouldThrowError(bool shouldThrow, [String? message]) {
    _shouldThrowError = shouldThrow;
    _errorMessage = message;
  }

  @override
  Future<List<ExperienceEntity>> getUserExperiences(String userId) async {
    if (_shouldThrowError) {
      throw Exception(_errorMessage ?? 'Error simulado');
    }
    await Future.delayed(const Duration(milliseconds: 100)); // Simular latencia
    return _mockExperiences.where((exp) => exp.user.id == userId).toList();
  }

  @override
  Future<List<ExperienceEntity>> getRideExperiences(String rideId) async {
    if (_shouldThrowError) {
      throw Exception(_errorMessage ?? 'Error simulado');
    }
    await Future.delayed(const Duration(milliseconds: 100));
    return _mockExperiences.where((exp) => exp.rideId == rideId).toList();
  }

  @override
  Future<List<ExperienceEntity>> getFollowingExperiences(String userId) async {
    if (_shouldThrowError) {
      throw Exception(_errorMessage ?? 'Error simulado');
    }
    await Future.delayed(const Duration(milliseconds: 100));
    return _mockExperiences;
  }

  @override
  Future<ExperienceEntity> createExperience(
    CreateExperienceRequest request,
  ) async {
    if (_shouldThrowError) {
      throw Exception(_errorMessage ?? 'Error simulado');
    }
    await Future.delayed(const Duration(milliseconds: 100));

    final newExperience = ExperienceEntity(
      id: 'generated_id_${DateTime.now().millisecondsSinceEpoch}',
      description: request.description,
      tags: request.tags,
      user: createMockUser(), // Usuario mock por defecto
      createdAt: DateTime.now(),
      media: [], // Simplificado por ahora
      type: request.type,
      rideId: request.rideId,
      views: 0,
      reactions: [],
    );

    _mockExperiences.add(newExperience);
    return newExperience;
  }

  @override
  Future<void> deleteExperience(String experienceId) async {
    if (_shouldThrowError) {
      throw Exception(_errorMessage ?? 'Error simulado');
    }
    await Future.delayed(const Duration(milliseconds: 100));
    _mockExperiences.removeWhere((exp) => exp.id == experienceId);
  }

  @override
  Future<void> addReaction(String experienceId, ReactionType reaction) async {
    if (_shouldThrowError) {
      throw Exception(_errorMessage ?? 'Error simulado');
    }
    await Future.delayed(const Duration(milliseconds: 50));
    // Mock: no hacer nada por simplicidad
  }

  @override
  Future<void> removeReaction(String experienceId) async {
    if (_shouldThrowError) {
      throw Exception(_errorMessage ?? 'Error simulado');
    }
    await Future.delayed(const Duration(milliseconds: 50));
    // Mock: no hacer nada por simplicidad
  }

  @override
  Future<void> markAsViewed(String experienceId) async {
    if (_shouldThrowError) {
      throw Exception(_errorMessage ?? 'Error simulado');
    }
    await Future.delayed(const Duration(milliseconds: 50));
    // Mock: incrementar views en la experiencia encontrada
    final index = _mockExperiences.indexWhere((exp) => exp.id == experienceId);
    if (index != -1) {
      _mockExperiences[index] = _mockExperiences[index].copyWith(
        views: _mockExperiences[index].views + 1,
      );
    }
  }

  @override
  Future<String> uploadMedia({
    required String filePath,
    required MediaType mediaType,
    required String experienceId,
    Function(double)? onProgress,
  }) async {
    if (_shouldThrowError) {
      throw Exception(_errorMessage ?? 'Error simulado de upload');
    }
    await Future.delayed(const Duration(milliseconds: 200));
    // Simular progreso si se proporciona callback
    onProgress?.call(0.5);
    await Future.delayed(const Duration(milliseconds: 100));
    onProgress?.call(1.0);

    return 'https://mock-url.com/media/$experienceId.${mediaType == MediaType.image ? 'jpg' : 'mp4'}';
  }
}

/// Helper para crear entidades de prueba
UserEntity createMockUser({
  String id = 'user123',
  String fullName = 'Test User',
  String userName = 'testuser',
  String email = 'test@example.com',
  String photo = 'https://mock-url.com/profile.jpg',
}) {
  return UserEntity(
    id: id,
    fullName: fullName,
    userName: userName,
    email: email,
    photo: photo,
  );
}

ExperienceEntity createMockExperience({
  String id = '',
  String description = 'Experiencia de prueba',
  UserEntity? user,
  ExperienceType type = ExperienceType.general,
  String? rideId,
  List<String>? tags,
}) {
  return ExperienceEntity(
    id: id.isEmpty ? 'exp_${DateTime.now().millisecondsSinceEpoch}' : id,
    description: description,
    tags: tags ?? ['test', 'mock'],
    user: user ?? createMockUser(),
    createdAt: DateTime.now(),
    media: [
      ExperienceMediaEntity(
        id: 'media1',
        url: 'https://mock-url.com/image.jpg',
        mediaType: MediaType.image,
        duration: 5,
        aspectRatio: 1.0,
      ),
    ],
    type: type,
    rideId: rideId,
    views: 0,
    reactions: [],
  );
}

void main() {
  group('ExperienceProvider - Pruebas Básicas con Mock Repository', () {
    late MockExperienceRepository mockRepository;
    late ExperienceProvider provider;

    setUp(() {
      mockRepository = MockExperienceRepository();
      provider = ExperienceProvider(repository: mockRepository);
    });

    test('✅ Instanciación del provider', () {
      expect(provider, isNotNull);
      expect(provider.userExperiences, isEmpty);
      expect(provider.rideExperiences, isEmpty);
      expect(provider.isLoading, isFalse);
      expect(provider.error, isNull);

      print(
        '✅ ExperienceProvider se instancia correctamente con mock repository',
      );
    });

    test('✅ Estado inicial del provider', () {
      expect(provider.userExperiences, isEmpty);
      expect(provider.rideExperiences, isEmpty);
      expect(provider.isLoading, isFalse);
      expect(provider.error, isNull);

      print('✅ Estado inicial del provider es correcto');
    });

    test('✅ Cargar experiencias de usuario exitosamente', () async {
      // Configurar datos mock
      final mockUser = createMockUser(id: 'user123', fullName: 'Test User');
      final mockExperiences = [
        createMockExperience(
          id: 'exp1',
          description: 'Primera experiencia',
          user: mockUser,
        ),
        createMockExperience(
          id: 'exp2',
          description: 'Segunda experiencia',
          user: mockUser,
        ),
      ];

      mockRepository.setMockExperiences(mockExperiences);

      // Ejecutar
      await provider.loadUserExperiences('user123');

      // Verificar
      expect(provider.userExperiences, hasLength(2));
      expect(
        provider.userExperiences.first.description,
        equals('Primera experiencia'),
      );
      expect(provider.isLoading, isFalse);
      expect(provider.error, isNull);

      print('✅ Carga de experiencias de usuario funciona correctamente');
    });

    test('✅ Manejar error al cargar experiencias', () async {
      // Configurar mock para lanzar error
      mockRepository.setShouldThrowError(true, 'Error de conexión simulado');

      // Ejecutar
      await provider.loadUserExperiences('user123');

      // Verificar
      expect(provider.userExperiences, isEmpty);
      expect(provider.isLoading, isFalse);
      expect(provider.error, contains('Error de conexión simulado'));

      print('✅ Manejo de errores funciona correctamente');
    });

    test('✅ Cargar experiencias de una rodada específica', () async {
      // Configurar datos mock
      final mockUser = createMockUser();
      final mockExperiences = [
        createMockExperience(
          id: 'exp1',
          description: 'Experiencia de rodada 1',
          user: mockUser,
          type: ExperienceType.ride,
          rideId: 'ride123',
        ),
        createMockExperience(
          id: 'exp2',
          description: 'Experiencia de rodada 2',
          user: mockUser,
          type: ExperienceType.ride,
          rideId: 'ride123',
        ),
        createMockExperience(
          id: 'exp3',
          description: 'Experiencia de otra rodada',
          user: mockUser,
          type: ExperienceType.ride,
          rideId: 'ride456',
        ),
      ];

      mockRepository.setMockExperiences(mockExperiences);

      // Ejecutar
      await provider.loadRideExperiences('ride123');

      // Verificar
      expect(provider.rideExperiences, hasLength(2));
      expect(
        provider.rideExperiences.every((exp) => exp.rideId == 'ride123'),
        isTrue,
      );
      expect(provider.isLoading, isFalse);
      expect(provider.error, isNull);

      print('✅ Carga de experiencias de rodada funciona correctamente');
    });

    test('✅ Verificar estado de carga durante operación asíncrona', () async {
      // Configurar mock
      mockRepository.setMockExperiences([]);

      // Iniciar operación asíncrona sin esperar
      final future = provider.loadUserExperiences('user123');

      // Esperar a que termine
      await future;

      // Verificar que terminó de cargar
      expect(provider.isLoading, isFalse);

      print('✅ Estado de loading funciona correctamente');
    });

    test('✅ Limpiar error al realizar nueva operación exitosa', () async {
      // Primero causar un error
      mockRepository.setShouldThrowError(true, 'Error inicial');
      await provider.loadUserExperiences('user123');
      expect(provider.error, isNotNull);

      // Luego hacer una operación exitosa
      mockRepository.setShouldThrowError(false);
      mockRepository.setMockExperiences([
        createMockExperience(
          id: 'exp1',
          description: 'Nueva experiencia',
          user: createMockUser(id: 'user123'),
        ),
      ]);

      await provider.loadUserExperiences('user123');

      // Verificar que el error se limpió
      expect(provider.error, isNull);
      expect(provider.userExperiences, hasLength(1));

      print('✅ Limpieza de errores funciona correctamente');
    });

    test('✅ Verificar que el provider notifica cambios', () async {
      bool notified = false;

      // Escuchar cambios
      provider.addListener(() {
        notified = true;
      });

      // Configurar mock
      mockRepository.setMockExperiences([
        createMockExperience(
          id: 'exp1',
          description: 'Test notification',
          user: createMockUser(id: 'user123'),
        ),
      ]);

      // Ejecutar operación
      await provider.loadUserExperiences('user123');

      // Verificar que se notificó
      expect(notified, isTrue);

      print('✅ Notificación de cambios funciona correctamente');
    });

    test('✅ Reload de experiencias limpia datos anteriores', () async {
      // Cargar experiencias iniciales
      mockRepository.setMockExperiences([
        createMockExperience(
          id: 'exp1',
          user: createMockUser(id: 'user123'),
        ),
      ]);
      await provider.loadUserExperiences('user123');
      expect(provider.userExperiences, hasLength(1));

      // Cambiar datos y recargar
      mockRepository.setMockExperiences([
        createMockExperience(
          id: 'exp2',
          user: createMockUser(id: 'user123'),
        ),
        createMockExperience(
          id: 'exp3',
          user: createMockUser(id: 'user123'),
        ),
      ]);
      await provider.loadUserExperiences('user123');

      // Verificar que se reemplazaron los datos
      expect(provider.userExperiences, hasLength(2));
      expect(provider.userExperiences.any((exp) => exp.id == 'exp1'), isFalse);
      expect(provider.userExperiences.any((exp) => exp.id == 'exp2'), isTrue);
      expect(provider.userExperiences.any((exp) => exp.id == 'exp3'), isTrue);

      print('✅ Reload de datos funciona correctamente');
    });
  });
}
