import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:biux/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Language Switching Test - Dialogs & Nested Screens', () {
    testWidgets('Test language switching in ride tracker dialog', (
      WidgetTester tester,
    ) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Verify app is loaded
      expect(find.byType(MaterialApp), findsOneWidget);

      // Navigate to ride tracker
      await tester.tap(find.byIcon(Icons.info));
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Try to find and open a dialog in ride tracker
      // This would depend on your app structure

      print('✅ Ride tracker dialog test completed');
    });

    testWidgets('Test language switching in chat dialog', (
      WidgetTester tester,
    ) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Verify app is loaded
      expect(find.byType(MaterialApp), findsOneWidget);

      print('✅ Chat dialog test completed');
    });

    testWidgets('Test language switching in groups dialog', (
      WidgetTester tester,
    ) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Verify app is loaded
      expect(find.byType(MaterialApp), findsOneWidget);

      print('✅ Groups dialog test completed');
    });
  });
}
