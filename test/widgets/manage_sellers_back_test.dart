import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:biux/features/shop/presentation/screens/manage_sellers_screen.dart';
import 'package:biux/features/users/presentation/providers/user_provider.dart';
import 'package:biux/features/users/data/models/user_model.dart';

void main() {
  testWidgets('ManageSellers back icon exists and is tappable', (tester) async {
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
