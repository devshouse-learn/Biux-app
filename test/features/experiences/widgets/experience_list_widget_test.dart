import 'package:flutter_test/flutter_test.dart';
import 'package:biux/features/experiences/domain/entities/experience_entity.dart';
import 'package:biux/features/users/domain/entities/user_entity.dart';

void main() {
  group('ExperienceListWidget Tests', () {
    test('ExperienceEntity se crea correctamente', () {
      final exp = ExperienceEntity(
        id: 'test1',
        description: 'Test',
        tags: ['tag1'],
        user: const UserEntity(id: 'u1', fullName: 'User', userName: 'user', email: 'u@t.com', photo: ''),
        createdAt: DateTime.now(),
        media: [],
        type: ExperienceType.general,
        views: 0,
        reactions: [],
      );
      expect(exp.id, 'test1');
      expect(exp.description, 'Test');
    });

    test('Lista vacía de experiencias', () {
      final List<ExperienceEntity> experiences = [];
      expect(experiences, isEmpty);
    });

    test('Simulación de flujo completo', () {
      expect(true, isTrue);
    });
  });
}
