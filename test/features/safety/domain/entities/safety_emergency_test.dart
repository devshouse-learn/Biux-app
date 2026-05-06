import 'package:flutter_test/flutter_test.dart';
import 'package:biux/features/safety/domain/entities/block_report_entity.dart';
import 'package:biux/features/emergency/domain/entities/emergency_contact_entity.dart';
import 'package:biux/features/accidents/domain/entities/accident_entity.dart';

void main() {
  group('BlockEntity', () {
    test('debe crear bloqueo con campos requeridos', () {
      final block = BlockEntity(
        id: 'b1',
        blockerId: 'user1',
        blockedId: 'user2',
        createdAt: DateTime(2025, 6, 1),
      );
      expect(block.blockerId, 'user1');
      expect(block.blockedId, 'user2');
    });
  });

  group('ReportEntity (Safety)', () {
    test('debe crear reporte con estado pendiente por defecto', () {
      final report = ReportEntity(
        id: 'r1',
        reporterId: 'user1',
        reportedId: 'user2',
        reason: ReportReason.harassment,
        createdAt: DateTime(2025, 6, 1),
      );
      expect(report.status, 'pending');
      expect(report.reason, ReportReason.harassment);
      expect(report.description, isNull);
    });

    test('ReportReason debe tener todas las razones', () {
      expect(ReportReason.values.length, 6);
    });

    test('ReportReason labels deben ser strings no vacíos', () {
      for (final reason in ReportReason.values) {
        expect(reason.label, isNotEmpty);
      }
    });
  });

  group('EmergencyContactEntity', () {
    test('debe crear contacto con toMap/fromMap', () {
      final contact = EmergencyContactEntity(
        id: 'ec1',
        name: 'María',
        phone: '+521234567890',
        relationship: 'Esposa',
      );

      final map = contact.toMap();
      expect(map['name'], 'María');
      expect(map['phone'], '+521234567890');

      final restored = EmergencyContactEntity.fromMap(map);
      expect(restored.name, contact.name);
      expect(restored.phone, contact.phone);
      expect(restored.relationship, 'Esposa');
    });

    test('fromMap debe manejar relationship nulo', () {
      final contact = EmergencyContactEntity.fromMap({
        'id': 'ec2',
        'name': 'Pedro',
        'phone': '+521111111111',
      });
      expect(contact.relationship, isNull);
    });
  });

  group('AccidentEntity', () {
    test('debe crear accidente con campos requeridos', () {
      final accident = AccidentEntity(
        id: 'a1',
        userId: 'user1',
        userName: 'Juan',
        latitude: 20.6736,
        longitude: -103.3445,
        description: 'Caída en curva',
        severity: 'moderate',
        createdAt: DateTime(2025, 6, 1),
      );
      expect(accident.severity, 'moderate');
      expect(accident.resolved, false);
      expect(accident.imageUrls, isEmpty);
    });

    test('toMap debe serializar correctamente', () {
      final accident = AccidentEntity(
        id: 'a2',
        userId: 'u1',
        userName: 'Test',
        latitude: 20.0,
        longitude: -103.0,
        description: 'Test accidente',
        severity: 'minor',
        createdAt: DateTime(2025, 1, 1),
        resolved: true,
        imageUrls: ['img1.jpg'],
      );

      final map = accident.toMap();
      expect(map['severity'], 'minor');
      expect(map['resolved'], true);
      expect((map['imageUrls'] as List).length, 1);
    });

    test('fromMap debe manejar campos faltantes', () {
      final accident = AccidentEntity.fromMap('a3', {});
      expect(accident.userId, '');
      expect(accident.severity, 'minor');
      expect(accident.resolved, false);
      expect(accident.latitude, 0);
    });

    test('fromMap debe parsear String como fecha', () {
      final accident = AccidentEntity.fromMap('a4', {
        'createdAt': '2025-06-01T00:00:00.000',
        'userId': 'u1',
      });
      expect(accident.createdAt.year, 2025);
    });
  });
}
