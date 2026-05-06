import 'package:flutter_test/flutter_test.dart';
import 'package:biux/features/rides/domain/entities/ride_entity.dart';
import 'package:biux/features/maps/domain/entities/meeting_point_entity.dart';
import 'package:biux/features/search/domain/entities/search_result_entity.dart';

void main() {
  group('RideEntity', () {
    late RideEntity ride;

    setUp(() {
      ride = RideEntity(
        id: 'ride-1',
        name: 'Rodada Dominical',
        groupId: 'group-1',
        meetingPointId: 'mp-1',
        dateTime: DateTime(2030, 12, 31, 8, 0),
        difficulty: 'intermediate',
        kilometers: 45.5,
        instructions: 'Llevar casco',
        recommendations: 'Hidratarse bien',
        createdBy: 'user-1',
        createdAt: DateTime(2025, 1, 1),
        status: 'upcoming',
        participants: ['user-1', 'user-2', 'user-3'],
        maybeParticipants: ['user-4'],
        imageUrl: 'https://example.com/ride.jpg',
      );
    });

    test('participantCount debe contar participantes', () {
      expect(ride.participantCount, 3);
    });

    test('isUpcoming debe ser true para rodada futura', () {
      expect(ride.isUpcoming, true);
    });

    test('isPastEvent debe ser false para rodada futura', () {
      expect(ride.isPastEvent, false);
    });

    test('isCancelled debe ser false para rodada activa', () {
      expect(ride.isCancelled, false);
    });

    test('isCancelled debe ser true para rodada cancelada', () {
      final cancelled = RideEntity(
        id: 'ride-2',
        name: 'Cancelada',
        groupId: 'g',
        meetingPointId: 'mp',
        dateTime: DateTime(2030, 12, 31),
        difficulty: 'easy',
        kilometers: 10,
        instructions: '',
        recommendations: '',
        createdBy: 'u',
        createdAt: DateTime(2025, 1, 1),
        status: 'cancelled',
        participants: [],
        maybeParticipants: [],
      );
      expect(cancelled.isCancelled, true);
    });

    test('isPastEvent debe ser true para rodada pasada', () {
      final past = RideEntity(
        id: 'ride-3',
        name: 'Pasada',
        groupId: 'g',
        meetingPointId: 'mp',
        dateTime: DateTime(2020, 1, 1),
        difficulty: 'easy',
        kilometers: 10,
        instructions: '',
        recommendations: '',
        createdBy: 'u',
        createdAt: DateTime(2019, 12, 1),
        status: 'upcoming',
        participants: [],
        maybeParticipants: [],
      );
      expect(past.isPastEvent, true);
      expect(past.isUpcoming, false);
    });
  });

  group('MeetingPointEntity', () {
    test('debe almacenar coordenadas correctamente', () {
      final mp = MeetingPointEntity(
        id: 'mp-1',
        name: 'Parque Central',
        description: 'Entrada principal',
        latitude: 20.6736,
        longitude: -103.3445,
      );
      expect(mp.latitude, 20.6736);
      expect(mp.longitude, -103.3445);
      expect(mp.name, 'Parque Central');
    });
  });

  group('SearchResult', () {
    test('debe crear resultado de tipo usuario', () {
      final r = SearchResult(
        id: 'u1',
        name: 'Juan',
        type: SearchResultType.user,
        subtitle: '@juan',
      );
      expect(r.type, SearchResultType.user);
    });

    test('debe crear resultado sin foto', () {
      final r = SearchResult(
        id: 'g1',
        name: 'Ciclistas GDL',
        type: SearchResultType.group,
      );
      expect(r.photoUrl, isNull);
    });

    test('SearchResultType debe tener 3 valores', () {
      expect(SearchResultType.values.length, 3);
    });
  });
}
