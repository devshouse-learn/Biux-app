import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:biux/features/help/presentation/screens/help_screen.dart';

void main() {
  testWidgets('HelpScreen back icon exists and is tappable', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: HelpScreen()));
    await tester.pumpAndSettle();

    final back = find.byIcon(Icons.arrow_back);
    expect(back, findsWidgets);
    await tester.tap(back.first);
    await tester.pumpAndSettle();
  });
}
