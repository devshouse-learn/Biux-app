import 'package:flutter_test/flutter_test.dart';
import '../../helpers/user_test_factory.dart';
import 'package:biux/features/users/domain/entities/user_entity.dart';

void main() {
  group('Group-related UserEntity tests', () {
    test('debe crear usuario regular', () {
      final user = UserTestFactory.createUser();
      expect(user.role, UserRole.user);
      expect(user.isAdmin, false);
    });

    test('debe crear admin', () {
      final admin = UserTestFactory.createAdmin();
      expect(admin.role, UserRole.admin);
      expect(admin.isAdmin, true);
    });

    test('debe crear vendedor autorizado', () {
      final seller = UserTestFactory.createSeller();
      expect(seller.role, UserRole.seller);
      expect(seller.canSellProducts, true);
      expect(seller.autorizadoPorAdmin, true);
    });

    test('debe generar listas de usuarios para grupos', () {
      final members = UserTestFactory.createUsers(10);
      expect(members.length, 10);
      // IDs únicos
      final ids = members.map((u) => u.id).toSet();
      expect(ids.length, 10);
    });

    test('isAdministrador debe funcionar con role admin', () {
      final admin = UserTestFactory.createAdmin();
      expect(admin.isAdministrador, true);
    });

    test('isAdministrador debe funcionar con isAdmin legacy', () {
      final legacyAdmin = UserTestFactory.createUser(isAdmin: true);
      expect(legacyAdmin.isAdministrador, true);
    });
  });
}
