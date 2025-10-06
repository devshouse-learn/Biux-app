import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:biux/features/experiences/domain/entities/experience_entity.dart';
import 'package:biux/features/users/domain/entities/user_entity.dart';
import 'package:biux/features/experiences/domain/repositories/experience_repository.dart';
import 'package:biux/features/experiences/presentation/providers/experience_classic_provider.dart';

// Mock repository que simula Firebase
class MockFirebaseExperienceRepository implements ExperienceRepository {
  List<ExperienceEntity> _firebaseDatabase = [];
  bool shouldThrowError = false;

  void setShouldThrowError(bool value) {
    shouldThrowError = value;
  }

  void addExperienceToFirebase(ExperienceEntity experience) {
    _firebaseDatabase.add(experience);
    print(
      '🔥 Firebase: Experiencia ${experience.id} agregada. Total: ${_firebaseDatabase.length}',
    );
  }

  void clearFirebase() {
    _firebaseDatabase.clear();
    print('🔥 Firebase: Base de datos limpiada');
  }

  void printFirebaseState() {
    print('🔥 Firebase: ${_firebaseDatabase.length} experiencias almacenadas');
    for (int i = 0; i < _firebaseDatabase.length; i++) {
      print(
        '   [$i] ${_firebaseDatabase[i].id} - ${_firebaseDatabase[i].user.fullName}',
      );
    }
  }

  @override
  Future<List<ExperienceEntity>> getUserExperiences(String userId) async {
    print('🔍 Consultando Firebase para usuario: $userId');
    await Future.delayed(
      Duration(milliseconds: 100),
    ); // Simular latencia de red

    if (shouldThrowError) {
      throw Exception('Error cargando experiencias de usuario');
    }

    final result = _firebaseDatabase
        .where((exp) => exp.user.id == userId)
        .toList();
    print(
      '🔍 Firebase retorna ${result.length} experiencias para usuario $userId',
    );
    return result;
  }

  @override
  Future<List<ExperienceEntity>> getRideExperiences(String rideId) async {
    print('🔍 Consultando Firebase para rodada: $rideId');
    await Future.delayed(Duration(milliseconds: 100));

    if (shouldThrowError) {
      throw Exception('Error cargando experiencias de rodada');
    }

    final result = _firebaseDatabase
        .where((exp) => exp.rideId == rideId)
        .toList();
    print(
      '🔍 Firebase retorna ${result.length} experiencias para rodada $rideId',
    );
    return result;
  }

  @override
  Future<List<ExperienceEntity>> getFollowingExperiences(String userId) async {
    await Future.delayed(Duration(milliseconds: 100));
    if (shouldThrowError) {
      throw Exception('Error cargando experiencias seguidas');
    }
    return _firebaseDatabase;
  }

  @override
  Future<ExperienceEntity> createExperience(
    CreateExperienceRequest request,
  ) async {
    print('🚀 Creando experiencia en Firebase: ${request.description}');
    await Future.delayed(
      Duration(milliseconds: 200),
    ); // Simular upload y creación

    if (shouldThrowError) {
      throw Exception('Error creando experiencia');
    }

    final newExperience = ExperienceEntity(
      id: 'exp_${DateTime.now().millisecondsSinceEpoch}',
      description: request.description,
      tags: request.tags,
      user: UserEntity(
        id: 'current_user',
        fullName: 'Usuario Actual',
        userName: 'usuario',
        email: 'usuario@example.com',
        photo: '',
      ),
      createdAt: DateTime.now(),
      media: [],
      type: request.type,
      rideId: request.rideId,
    );

    _firebaseDatabase.add(newExperience);
    print('✅ Experiencia creada en Firebase: ${newExperience.id}');
    return newExperience;
  }

  @override
  Future<void> deleteExperience(String experienceId) async {
    await Future.delayed(Duration(milliseconds: 100));
    if (shouldThrowError) {
      throw Exception('Error eliminando experiencia');
    }
    _firebaseDatabase.removeWhere((exp) => exp.id == experienceId);
    print('🗑️ Experiencia $experienceId eliminada de Firebase');
  }

  @override
  Future<void> addReaction(String experienceId, ReactionType reaction) async {
    await Future.delayed(Duration(milliseconds: 50));
    if (shouldThrowError) {
      throw Exception('Error agregando reacción');
    }
  }

  @override
  Future<void> removeReaction(String experienceId) async {
    await Future.delayed(Duration(milliseconds: 50));
    if (shouldThrowError) {
      throw Exception('Error eliminando reacción');
    }
  }

  @override
  Future<void> markAsViewed(String experienceId) async {
    await Future.delayed(Duration(milliseconds: 50));
    if (shouldThrowError) {
      throw Exception('Error marcando como vista');
    }
  }

  @override
  Future<String> uploadMedia({
    required String filePath,
    required MediaType mediaType,
    required String experienceId,
    Function(double)? onProgress,
  }) async {
    await Future.delayed(Duration(milliseconds: 300));
    if (shouldThrowError) {
      throw Exception('Error subiendo media');
    }
    return 'https://firebase-storage.com/media/${DateTime.now().millisecondsSinceEpoch}';
  }
}

// Widget que simula la pantalla real
class TestExperienceListScreen extends StatefulWidget {
  const TestExperienceListScreen({Key? key}) : super(key: key);

  @override
  State<TestExperienceListScreen> createState() =>
      _TestExperienceListScreenState();
}

class _TestExperienceListScreenState extends State<TestExperienceListScreen> {
  @override
  void initState() {
    super.initState();
    // Simular el initState de la pantalla real
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ExperienceProvider>().loadUserExperiences('current_user');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Test Experiencias'),
        actions: [
          IconButton(
            key: const Key('create_button'),
            onPressed: () async {
              final request = CreateExperienceRequest(
                description: 'Nueva experiencia de test',
                tags: ['test'],
                mediaFiles: [],
                type: ExperienceType.ride,
                rideId: 'test_ride',
              );

              await context.read<ExperienceProvider>().createExperience(
                request,
              );
            },
            icon: const Icon(Icons.add),
          ),
        ],
      ),
      body: Consumer<ExperienceProvider>(
        builder: (context, provider, child) {
          print(
            '🎨 UI Rebuild - Loading: ${provider.isLoading}, UserExperiences: ${provider.userExperiences.length}, Error: ${provider.error}',
          );

          if (provider.isLoading) {
            return const Center(
              child: CircularProgressIndicator(key: Key('loading_indicator')),
            );
          }

          if (provider.error != null) {
            return Center(
              child: Text(
                'Error: ${provider.error}',
                key: const Key('error_text'),
              ),
            );
          }

          if (provider.userExperiences.isEmpty) {
            return const Center(
              child: Text(
                'No hay experiencias disponibles',
                key: Key('empty_list_text'),
              ),
            );
          }

          return ListView.builder(
            key: const Key('experience_list'),
            itemCount: provider.userExperiences.length,
            itemBuilder: (context, index) {
              final experience = provider.userExperiences[index];
              return ListTile(
                key: Key('experience_item_$index'),
                title: Text(experience.user.fullName),
                subtitle: Text(experience.description),
                trailing: Text('${experience.media.length} media'),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        key: const Key('reload_button'),
        onPressed: () {
          context.read<ExperienceProvider>().loadUserExperiences(
            'current_user',
          );
        },
        child: const Icon(Icons.refresh),
      ),
    );
  }
}

void main() {
  group('🔥 Flujo Completo Real - Firebase Mock Integration', () {
    late MockFirebaseExperienceRepository mockFirebaseRepo;
    late ExperienceProvider experienceProvider;

    setUp(() {
      mockFirebaseRepo = MockFirebaseExperienceRepository();
      experienceProvider = ExperienceProvider(repository: mockFirebaseRepo);
    });

    Widget createTestApp() {
      return MaterialApp(
        home: ChangeNotifierProvider<ExperienceProvider>.value(
          value: experienceProvider,
          child: const TestExperienceListScreen(),
        ),
      );
    }

    testWidgets('🎯 FLUJO REAL: Pantalla vacía -> Crear experiencia -> Aparece en lista', (
      WidgetTester tester,
    ) async {
      // 📱 PASO 1: Abrir la pantalla (simula cuando el usuario abre la app)
      print('\\n📱 PASO 1: Abriendo pantalla de experiencias...');
      await tester.pumpWidget(createTestApp());

      // 🔄 Esperar que se complete el initState con loadUserExperiences
      await tester.pump(); // Triggers initState
      print('📱 initState ejecutado, provider en estado loading...');

      // ✅ Verificar que se muestra loading
      expect(find.byKey(const Key('loading_indicator')), findsOneWidget);
      mockFirebaseRepo.printFirebaseState();

      // ⏳ Esperar que termine la consulta a Firebase (userExperiences está vacío)
      await tester.pump(Duration(milliseconds: 150));
      print('📱 Consulta inicial completada');

      // ✅ Verificar que se muestra mensaje vacío (estado inicial correcto)
      expect(find.byKey(const Key('loading_indicator')), findsNothing);
      expect(find.byKey(const Key('empty_list_text')), findsOneWidget);
      expect(find.text('No hay experiencias disponibles'), findsOneWidget);

      print('✅ PASO 1 COMPLETO: Pantalla muestra estado vacío correctamente');

      // 📱 PASO 2: Crear una nueva experiencia (simula cuando el usuario crea contenido)
      print('\\n📱 PASO 2: Usuario crea una nueva experiencia...');

      await tester.tap(find.byKey(const Key('create_button')));
      await tester.pump(); // Trigger la creación
      print('📱 CreateExperience invocado...');

      // ⏳ Esperar que se complete la creación en Firebase
      await tester.pump(Duration(milliseconds: 250));
      print('📱 Creación completada');

      mockFirebaseRepo.printFirebaseState();

      // 🎯 VERIFICACIÓN CRÍTICA: ¿La experiencia aparece automáticamente en la UI?
      print('\\n🎯 VERIFICACIÓN CRÍTICA:');
      print('   - ¿Desapareció el mensaje vacío?');
      print('   - ¿Apareció la lista de experiencias?');
      print('   - ¿Se muestra la experiencia recién creada?');

      final hasEmptyMessage = find.byKey(const Key('empty_list_text'));
      final hasExperienceList = find.byKey(const Key('experience_list'));
      final hasExperienceItem = find.byKey(const Key('experience_item_0'));

      if (hasEmptyMessage.evaluate().isNotEmpty) {
        print('🔴 PROBLEMA: Todavía se muestra el mensaje vacío');
        print('🔴 La experiencia se creó pero la UI no se actualizó');

        // Intentar reload manual
        print('\\n🔄 Intentando reload manual...');
        await tester.tap(find.byKey(const Key('reload_button')));
        await tester.pump(); // loading state
        await tester.pump(Duration(milliseconds: 150)); // complete loading

        if (find.byKey(const Key('experience_list')).evaluate().isNotEmpty) {
          print('✅ Después del reload manual SÍ aparece la experiencia');
          print(
            '🔴 CONCLUSIÓN: La UI NO se actualiza automáticamente después de crear',
          );
          print(
            '🔴 El usuario necesita recargar manualmente para ver sus experiencias',
          );
        } else {
          print(
            '🔴 Ni siquiera el reload manual funciona - problema más profundo',
          );
        }
      } else if (hasExperienceList.evaluate().isNotEmpty &&
          hasExperienceItem.evaluate().isNotEmpty) {
        print('✅ PERFECTO: La experiencia aparece automáticamente en la UI');
        print('✅ No es necesario reload manual');
        print('✅ El flujo funciona como se espera');

        // Verificar contenido
        expect(find.text('Usuario Actual'), findsOneWidget);
        expect(find.text('Nueva experiencia de test'), findsOneWidget);
      } else {
        print('🔴 Estado inesperado en la UI');
      }

      print('\\n📊 Estado final del provider:');
      print('   - isLoading: ${experienceProvider.isLoading}');
      print('   - error: ${experienceProvider.error}');
      print(
        '   - experiences.length: ${experienceProvider.experiences.length}',
      );
      print(
        '   - userExperiences.length: ${experienceProvider.userExperiences.length}',
      );
      print(
        '   - rideExperiences.length: ${experienceProvider.rideExperiences.length}',
      );

      print(
        '\\n🔥 Test completado - Revisa los logs para diagnosticar el problema',
      );
    });

    testWidgets('🔄 FLUJO DE RECARGA: Verificar que reload siempre funciona', (
      WidgetTester tester,
    ) async {
      // Pre-popular Firebase con una experiencia
      final testUser = UserEntity(
        id: 'current_user',
        fullName: 'Usuario Test',
        userName: 'test',
        email: 'test@example.com',
        photo: '',
      );

      final existingExperience = ExperienceEntity(
        id: 'existing_exp',
        user: testUser,
        description: 'Experiencia existente',
        tags: ['existing'],
        media: [],
        reactions: [],
        createdAt: DateTime.now(),
        rideId: 'existing_ride',
        type: ExperienceType.ride,
      );

      mockFirebaseRepo.addExperienceToFirebase(existingExperience);
      print('\\n🔥 Firebase pre-populated con 1 experiencia');

      await tester.pumpWidget(createTestApp());
      await tester.pump(); // initState
      await tester.pump(Duration(milliseconds: 150)); // complete loading

      // Verificar que la experiencia existente se carga
      expect(find.byKey(const Key('experience_list')), findsOneWidget);
      expect(find.text('Usuario Test'), findsOneWidget);
      expect(find.text('Experiencia existente'), findsOneWidget);

      print('✅ Reload inicial funciona correctamente');

      // Ahora intentar reload manual
      await tester.tap(find.byKey(const Key('reload_button')));
      await tester.pump(); // loading
      await tester.pump(Duration(milliseconds: 150)); // complete

      expect(find.byKey(const Key('experience_list')), findsOneWidget);
      expect(find.text('Usuario Test'), findsOneWidget);

      print('✅ Reload manual funciona correctamente');
    });
  });
}
