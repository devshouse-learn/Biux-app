import 'package:flutter_test/flutter_test.dart';
import 'package:biux/features/users/presentation/providers/user_provider.dart';
import 'package:biux/features/users/data/models/user_model.dart';

void main() {
  group('UserProvider', () {
    late UserProvider provider;

    setUp(() {
      provider = UserProvider.forTest(
        initialUser: UserModel(
          uid: 'test-uid',
          name: 'Test User',
          username: 'testuser',
          email: 'test@biux.app',
          phoneNumber: '+521234567890',
          photoUrl: 'https://example.com/photo.jpg',
        ),
      );
    });

    test('profileCompletionPercent debe ser 100 con todos los campos', () {
      expect(provider.profileCompletionPercent, 100);
    });

    test('missingProfileFields debe estar vacío con perfil completo', () {
      expect(provider.missingProfileFields, isEmpty);
    });

    test('isProfileComplete debe ser true', () {
      expect(provider.isProfileComplete, true);
    });

    test('publicProfileUrl debe incluir el username', () {
      expect(provider.publicProfileUrl, contains('testuser'));
    });

    test('shareProfileText debe incluir el nombre', () {
      expect(provider.shareProfileText, contains('Test User'));
    });

    test('perfil incompleto sin foto ni bio', () {
      final p = UserProvider.forTest(
        initialUser: UserModel(
          uid: 'test-uid',
          name: 'Test User',
          username: 'testuser',
          email: 'test@biux.app',
          phoneNumber: '+521234567890',
        ),
      );
      expect(p.profileCompletionPercent, lessThan(100));
      expect(p.missingProfileFields, isNotEmpty);
    });
  });
}
