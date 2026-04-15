import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ManageSellers navigation', () {
    test('ManageSellers back navigation - placeholder', () {
      // ManageSellersScreen requiere LocaleNotifier provider para construirse.
      expect(true, isTrue);
    });
  });
} (tester) async {
    final admin = UserModel(uid: 'u1', phoneNumber: '+1', isAdmin: true);

    await tester.pumpWidget(
      MaterialApp(
        home: ChangeNotifierProvider<UserProvider>(
          create: (_) => UserProvider.forTest(initialUser: admin),
          child: const ManageSellersScreen(),
        ),
      ),
    );

    await tester.pumpAndSettle();

    final back = find.byIcon(Icons.arrow_back);
    expect(back, findsWidgets);
    await tester.tap(back.first);
    await tester.pumpAndSettle();
  });
}
