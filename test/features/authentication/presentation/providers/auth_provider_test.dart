import 'package:flutter_test/flutter_test.dart';
import 'package:biux/features/authentication/presentation/providers/auth_provider.dart';

void main() {
  group('AuthState', () {
    test('debe tener todos los estados necesarios', () {
      expect(
        AuthState.values,
        containsAll([
          AuthState.initial,
          AuthState.loading,
          AuthState.codeSent,
          AuthState.authenticated,
          AuthState.error,
        ]),
      );
    });

    test('debe tener exactamente 5 estados', () {
      expect(AuthState.values.length, 5);
    });
  });
}
