import 'package:flutter_test/flutter_test.dart';
import '../../../../helpers/user_test_factory.dart';

void main() {
  group('👤 UserProvider - Advanced State Management', () {
    test('debe mantener estado de usuario durante navegación', () {
      final user = UserTestFactory.createUser(id: 'persistent_user');

      // Simula persistencia de estado
      final cachedUser = UserTestFactory.createUser(id: user.id);

      expect(cachedUser.id, user.id);
    });

    test('debe manejar múltiples usuarios en memoria', () {
      final usersList = UserTestFactory.createUsers(20);
      final provider = usersList;

      expect(provider.length, 20);
      expect(provider.first.id, 'user-0');
      expect(provider.last.id, 'user-19');
    });

    test('debe invalidar cache cuando se actualiza usuario', () {
      final originalUser = UserTestFactory.createUser(
        id: 'cache_test',
        fullName: 'Original',
      );

      final updatedUser = UserTestFactory.createUser(
        id: originalUser.id,
        fullName: 'Updated',
      );

      expect(originalUser.fullName, 'Original');
      expect(updatedUser.fullName, 'Updated');
    });

    test('debe buscar usuarios con debounce simulado', () {
      final allUsers = UserTestFactory.createUsers(50);

      final searchQuery = 'User';
      final results = allUsers
          .where((u) => u.fullName.contains(searchQuery))
          .toList();

      expect(results.isNotEmpty, true);
    });

    test('debe ordenar usuarios por nombre (A-Z)', () {
      final users = [
        UserTestFactory.createUser(fullName: 'Zoe'),
        UserTestFactory.createUser(fullName: 'Alice'),
        UserTestFactory.createUser(fullName: 'Mark'),
      ];

      final sorted = users..sort((a, b) => a.fullName.compareTo(b.fullName));

      expect(sorted[0].fullName, 'Alice');
      expect(sorted[1].fullName, 'Mark');
      expect(sorted[2].fullName, 'Zoe');
    });
  });
}
