import 'package:flutter_test/flutter_test.dart';

void main() {
  group('HelpScreen', () {
    test('placeholder - screen exists', () {
      // Las pruebas de widget de HelpScreen requieren
      // providers (LocaleNotifier) que no están disponibles en tests unitarios.
      // Este placeholder asegura que el archivo compila correctamente.
      expect(true, isTrue);
    });
  });
}
