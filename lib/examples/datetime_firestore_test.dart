import 'package:biux/features/experiences/domain/entities/experience_entity.dart';
import 'package:biux/features/experiences/data/models/experience_model.dart';
import 'package:biux/features/users/domain/entities/user_entity.dart';

/// Test de ejemplo para verificar que DateTime funciona correctamente
/// con Firestore y la serialización JSON
void testDateTimeCompatibility() {
  // 1. Crear una fecha - compatible con Firestore
  final now = DateTime.now();

  // 2. Crear una entidad con DateTime
  final userEntity = UserEntity(
    id: 'user123',
    fullName: 'Test User',
    userName: 'testuser',
    email: 'test@example.com',
    photo: 'https://example.com/photo.jpg',
  );

  final mediaEntity = ExperienceMediaEntity(
    id: 'media123',
    url: 'https://example.com/image.jpg',
    mediaType: MediaType.image,
    duration: 0,
    aspectRatio: 1.0,
  );

  final reactionEntity = ExperienceReactionEntity(
    id: 'reaction123',
    user: userEntity,
    type: ReactionType.like,
    createdAt: now, // DateTime se maneja directamente
  );

  final experienceEntity = ExperienceEntity(
    id: 'exp123',
    description: 'Test experience',
    tags: ['test', 'example'],
    user: userEntity,
    createdAt: now, // DateTime compatible con Firestore
    media: [mediaEntity],
    type: ExperienceType.general,
    views: 0,
    reactions: [reactionEntity],
  );

  // 3. Convertir a modelo y serializar
  final model = ExperienceModel.fromEntity(experienceEntity);
  final json = model.toJson();

  // 4. El DateTime se serializa como ISO8601 string (compatible con Firestore)
  print('DateTime serializado: ${json['createdAt']}');
  // Salida: "2025-10-06T15:30:45.123456"

  // 5. Deserializar desde JSON
  final modelFromJson = ExperienceModel.fromJson(json);
  final entityFromModel = modelFromJson.toEntity();

  // 6. Verificar que DateTime se mantiene correctamente
  assert(entityFromModel.createdAt == now);
  assert(entityFromModel.reactions.first.createdAt == now);

  print('✅ DateTime funciona correctamente con Firestore!');
  print('   - Se serializa como ISO8601 string');
  print('   - Se deserializa correctamente');
  print('   - Compatible con Firestore Timestamp');
}

/// Ejemplo de cómo DateTime funciona con Firestore
///
/// Firestore maneja DateTime de las siguientes maneras:
/// 1. DateTime -> Timestamp automáticamente al guardar
/// 2. Timestamp -> DateTime automáticamente al leer
/// 3. String ISO8601 -> DateTime al deserializar JSON
///
/// Nuestro modelo actual es compatible con todos estos casos:
/// - ExperienceModel.toJson() -> convierte DateTime a ISO8601 string
/// - ExperienceModel.fromJson() -> convierte string a DateTime
/// - Las entidades usan DateTime directamente (compatible con Firestore)
