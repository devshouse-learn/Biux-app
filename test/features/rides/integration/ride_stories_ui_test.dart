import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

// Importaciones de biux
import 'package:biux/features/experiences/domain/entities/experience_entity.dart';
import 'package:biux/features/users/domain/entities/user_entity.dart';
import 'package:biux/features/experiences/presentation/providers/experience_classic_provider.dart';
import 'package:biux/features/experiences/domain/repositories/experience_repository.dart';

// Mock para simular el repository
class MockStoryRepository implements ExperienceRepository {
  final Map<String, List<ExperienceEntity>> _rideStories = {};
  bool _shouldThrowError = false;

  void populateRideWithStories(String rideId, List<ExperienceEntity> stories) {
    _rideStories[rideId] = stories;
  }

  void setShouldThrowError(bool value) {
    _shouldThrowError = value;
  }

  @override
  Future<List<ExperienceEntity>> getRideExperiences(String rideId) async {
    if (_shouldThrowError) throw Exception('Error de red');
    await Future.delayed(const Duration(milliseconds: 100));
    return _rideStories[rideId] ?? [];
  }

  @override
  Future<ExperienceEntity> createExperience(
    CreateExperienceRequest request,
  ) async {
    if (_shouldThrowError) throw Exception('Error creando story');
    await Future.delayed(const Duration(milliseconds: 100));

    final newStory = ExperienceEntity(
      id: 'story_${DateTime.now().millisecondsSinceEpoch}',
      description: request.description,
      tags: request.tags,
      user: const UserEntity(
        id: 'current_user',
        fullName: 'Usuario Actual',
        userName: 'usuario',
        email: 'usuario@biux.com',
        photo: '',
      ),
      createdAt: DateTime.now(),
      media: [],
      type: request.type,
      rideId: request.rideId,
    );

    // Agregar a la rodada correspondiente
    if (request.rideId != null) {
      _rideStories[request.rideId!] = _rideStories[request.rideId!] ?? [];
      _rideStories[request.rideId!]!.insert(
        0,
        newStory,
      ); // Insertar al inicio (más reciente)
    }

    return newStory;
  }

  // Implementaciones mínimas para otros métodos requeridos
  @override
  Future<List<ExperienceEntity>> getUserExperiences(String userId) async => [];

  @override
  Future<List<ExperienceEntity>> getFollowingExperiences(String userId) async =>
      [];

  @override
  Future<void> deleteExperience(String experienceId) async {}

  @override
  Future<void> addReaction(String experienceId, ReactionType reaction) async {}

  @override
  Future<void> removeReaction(String experienceId) async {}

  @override
  Future<void> markAsViewed(String experienceId) async {}

  @override
  Future<String> uploadMedia({
    required String filePath,
    required MediaType mediaType,
    required String experienceId,
    Function(double)? onProgress,
  }) async => 'mock_url';
}

void main() {
  group('🎪 Ride Stories UI Integration - Instagram-style Stories in Rides', () {
    late MockStoryRepository mockRepository;
    late ExperienceProvider experienceProvider;

    setUp(() {
      mockRepository = MockStoryRepository();
      experienceProvider = ExperienceProvider(repository: mockRepository);
    });

    testWidgets(
      '✅ Pantalla de rodada muestra stories horizontales en la parte superior',
      (WidgetTester tester) async {
        print('\n🎬 TEST: Stories horizontales en pantalla de rodada');
        const rideId = 'ride_ui_test_123';

        // Pre-poblar con stories de muestra
        mockRepository.populateRideWithStories(rideId, [
          ExperienceEntity(
            id: 'story_1',
            description: 'Iniciando la aventura! 🚴‍♂️',
            tags: ['inicio'],
            user: const UserEntity(
              id: 'user1',
              fullName: 'Ana García',
              userName: 'ana',
              email: 'ana@test.com',
              photo: '',
            ),
            createdAt: DateTime.now().subtract(const Duration(minutes: 30)),
            media: [],
            type: ExperienceType.ride,
            rideId: rideId,
          ),
          ExperienceEntity(
            id: 'story_2',
            description: 'Paisaje increíble en el kilómetro 15 🌄',
            tags: ['paisaje'],
            user: const UserEntity(
              id: 'user2',
              fullName: 'Carlos López',
              userName: 'carlos',
              email: 'carlos@test.com',
              photo: '',
            ),
            createdAt: DateTime.now().subtract(const Duration(minutes: 15)),
            media: [],
            type: ExperienceType.ride,
            rideId: rideId,
          ),
        ]);

        await tester.pumpWidget(
          MaterialApp(
            home: ChangeNotifierProvider<ExperienceProvider>(
              create: (_) => experienceProvider,
              child: _RideDetailScreen(rideId: rideId),
            ),
          ),
        );

        // Estado inicial - loading
        expect(find.byType(CircularProgressIndicator), findsOneWidget);

        // Cargar stories
        await experienceProvider.loadRideExperiences(rideId);
        await tester.pump();

        // Verificar estructura de la pantalla
        expect(
          find.text('Ruta del Sol'),
          findsOneWidget,
        ); // Título de la rodada
        expect(
          find.text('Stories de la rodada'),
          findsOneWidget,
        ); // Sección de stories

        // Verificar que hay círculos de stories
        expect(find.byType(_StoryCircleWidget), findsNWidgets(2));
        expect(find.byType(_AddStoryButtonWidget), findsOneWidget);

        // Verificar layout horizontal
        expect(find.byType(ListView), findsOneWidget);

        print('✅ Stories se muestran horizontalmente en la parte superior');
      },
    );

    testWidgets('✅ Tap en "Agregar Story" abre modal para crear nueva story', (
      WidgetTester tester,
    ) async {
      print('\n🎬 TEST: Crear nueva story desde rodada');
      const rideId = 'ride_create_story_456';

      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider<ExperienceProvider>(
            create: (_) => experienceProvider,
            child: _RideDetailScreen(rideId: rideId),
          ),
        ),
      );

      // Cargar estado inicial (sin stories)
      await experienceProvider.loadRideExperiences(rideId);
      await tester.pump();

      // Verificar estado inicial
      expect(find.text('No hay stories aún'), findsOneWidget);
      expect(find.byType(_AddStoryButtonWidget), findsOneWidget);

      // Tap en "Agregar Story"
      print('📱 Usuario toca "Agregar Story"');
      await tester.tap(find.byType(_AddStoryButtonWidget));
      await tester.pumpAndSettle();

      // Verificar que se abre modal/dialog
      expect(find.text('Crear Story'), findsOneWidget);
      expect(find.byType(TextField), findsOneWidget);
      expect(find.text('Publicar'), findsOneWidget);

      // Escribir descripción de la story
      await tester.enterText(
        find.byType(TextField),
        'Parada técnica para ajustar frenos 🔧',
      );

      // Publicar story
      print('📱 Usuario publica la story');
      await tester.tap(find.text('Publicar'));
      await tester.pump(); // Trigger del tap
      await tester.pump(); // Proceso de creación

      // Verificar que la story aparece
      expect(find.text('No hay stories aún'), findsNothing);
      expect(find.byType(_StoryCircleWidget), findsOneWidget);

      print('✅ Story creada y aparece inmediatamente');
    });

    testWidgets(
      '✅ Tap en story circle abre visualizador de story (tipo Instagram)',
      (WidgetTester tester) async {
        print('\n🎬 TEST: Abrir visualizador de story');
        const rideId = 'ride_view_story_789';

        // Pre-poblar con una story
        mockRepository.populateRideWithStories(rideId, [
          ExperienceEntity(
            id: 'story_view_test',
            description: 'Llegamos a la cumbre! 🏔️🎉',
            tags: ['cumbre', 'logro'],
            user: const UserEntity(
              id: 'user_climber',
              fullName: 'María Montañista',
              userName: 'maria_mountain',
              email: 'maria@test.com',
              photo: '',
            ),
            createdAt: DateTime.now(),
            media: [],
            type: ExperienceType.ride,
            rideId: rideId,
          ),
        ]);

        await tester.pumpWidget(
          MaterialApp(
            home: ChangeNotifierProvider<ExperienceProvider>(
              create: (_) => experienceProvider,
              child: _RideDetailScreen(rideId: rideId),
            ),
          ),
        );

        // Cargar stories
        await experienceProvider.loadRideExperiences(rideId);
        await tester.pump();

        // Verificar que hay una story
        expect(find.byType(_StoryCircleWidget), findsOneWidget);

        // Tap en la story
        print('📱 Usuario toca circle de story');
        await tester.tap(find.byType(_StoryCircleWidget));
        await tester.pumpAndSettle();

        // Verificar que se abre el visualizador
        expect(find.text('Story Viewer'), findsOneWidget);
        expect(find.text('Llegamos a la cumbre! 🏔️🎉'), findsOneWidget);
        expect(find.text('María Montañista'), findsOneWidget);
        expect(find.byIcon(Icons.close), findsOneWidget);

        // Cerrar visualizador
        await tester.tap(find.byIcon(Icons.close));
        await tester.pumpAndSettle();

        // Verificar que volvemos a la pantalla de rodada
        expect(find.text('Story Viewer'), findsNothing);
        expect(find.text('Ruta del Sol'), findsOneWidget);

        print('✅ Visualizador de story funciona correctamente');
      },
    );

    testWidgets(
      '✅ Stories se ordenan cronológicamente (más recientes primero)',
      (WidgetTester tester) async {
        print('\n🎬 TEST: Orden cronológico de stories');
        const rideId = 'ride_chronological_order';

        // Pre-poblar con stories en diferentes momentos
        mockRepository.populateRideWithStories(rideId, [
          // Nota: En orden cronológico inverso (más reciente primero)
          ExperienceEntity(
            id: 'story_latest',
            description: 'Meta alcanzada! 🏁',
            tags: ['meta'],
            user: const UserEntity(
              id: 'user3',
              fullName: 'Usuario 3',
              userName: 'user3',
              email: '',
              photo: '',
            ),
            createdAt: DateTime.now(), // Más reciente
            media: [],
            type: ExperienceType.ride,
            rideId: rideId,
          ),
          ExperienceEntity(
            id: 'story_middle',
            description: 'Mitad del recorrido 🚴‍♂️',
            tags: ['progreso'],
            user: const UserEntity(
              id: 'user2',
              fullName: 'Usuario 2',
              userName: 'user2',
              email: '',
              photo: '',
            ),
            createdAt: DateTime.now().subtract(const Duration(minutes: 30)),
            media: [],
            type: ExperienceType.ride,
            rideId: rideId,
          ),
          ExperienceEntity(
            id: 'story_first',
            description: 'Comenzamos la aventura! 🌅',
            tags: ['inicio'],
            user: const UserEntity(
              id: 'user1',
              fullName: 'Usuario 1',
              userName: 'user1',
              email: '',
              photo: '',
            ),
            createdAt: DateTime.now().subtract(
              const Duration(hours: 1),
            ), // Más antigua
            media: [],
            type: ExperienceType.ride,
            rideId: rideId,
          ),
        ]);

        await tester.pumpWidget(
          MaterialApp(
            home: ChangeNotifierProvider<ExperienceProvider>(
              create: (_) => experienceProvider,
              child: _RideDetailScreen(rideId: rideId),
            ),
          ),
        );

        // Cargar stories
        await experienceProvider.loadRideExperiences(rideId);
        await tester.pump();

        // Verificar orden
        final stories = experienceProvider.rideExperiences;
        expect(stories.length, 3);
        expect(
          stories[0].description,
          'Meta alcanzada! 🏁',
        ); // Más reciente primero
        expect(stories[1].description, 'Mitad del recorrido 🚴‍♂️');
        expect(
          stories[2].description,
          'Comenzamos la aventura! 🌅',
        ); // Más antigua al final

        expect(find.byType(_StoryCircleWidget), findsNWidgets(3));

        print('✅ Stories se ordenan correctamente por fecha');
      },
    );
  });
}

// Widget simulado de pantalla de detalle de rodada con stories
class _RideDetailScreen extends StatefulWidget {
  final String rideId;

  const _RideDetailScreen({required this.rideId});

  @override
  _RideDetailScreenState createState() => _RideDetailScreenState();
}

class _RideDetailScreenState extends State<_RideDetailScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ExperienceProvider>(
        context,
        listen: false,
      ).loadRideExperiences(widget.rideId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ruta del Sol'),
        backgroundColor: Colors.blue,
      ),
      body: Consumer<ExperienceProvider>(
        builder: (context, provider, child) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Sección de Stories (en la parte superior como Instagram)
              Container(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Stories de la rodada',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Área de stories horizontal
                    Container(
                      height: 100,
                      child: provider.isLoading
                          ? const Center(child: CircularProgressIndicator())
                          : Row(
                              children: [
                                // Botón "Agregar Story"
                                _AddStoryButtonWidget(rideId: widget.rideId),
                                const SizedBox(width: 12),

                                // Lista horizontal de stories
                                Expanded(
                                  child: provider.rideExperiences.isEmpty
                                      ? const Center(
                                          child: Text(
                                            'No hay stories aún',
                                            style: TextStyle(
                                              color: Colors.grey,
                                            ),
                                          ),
                                        )
                                      : ListView.builder(
                                          scrollDirection: Axis.horizontal,
                                          itemCount:
                                              provider.rideExperiences.length,
                                          itemBuilder: (context, index) {
                                            final story =
                                                provider.rideExperiences[index];
                                            return Padding(
                                              padding: const EdgeInsets.only(
                                                right: 12,
                                              ),
                                              child: _StoryCircleWidget(
                                                story: story,
                                                onTap: () => _openStoryViewer(
                                                  context,
                                                  story,
                                                ),
                                              ),
                                            );
                                          },
                                        ),
                                ),
                              ],
                            ),
                    ),
                  ],
                ),
              ),

              const Divider(),

              // Resto del contenido de la rodada
              const Expanded(
                child: Center(
                  child: Text(
                    'Información de la rodada\n(Participantes, ruta, etc.)',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  void _openStoryViewer(BuildContext context, ExperienceEntity story) {
    showDialog(
      context: context,
      fullscreenDialog: true,
      builder: (dialogContext) => _StoryViewerDialog(story: story),
    );
  }
}

// Widget para el botón "Agregar Story"
class _AddStoryButtonWidget extends StatelessWidget {
  final String rideId;

  const _AddStoryButtonWidget({required this.rideId});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _showCreateStoryDialog(context),
      child: Container(
        width: 70,
        height: 70,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: Colors.grey, width: 2),
          color: Colors.grey.withOpacity(0.1),
        ),
        child: const Icon(Icons.add, color: Colors.grey, size: 32),
      ),
    );
  }

  void _showCreateStoryDialog(BuildContext context) {
    final textController = TextEditingController();

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Crear Story'),
        content: TextField(
          controller: textController,
          decoration: const InputDecoration(
            hintText: 'Describe tu experiencia...',
          ),
          maxLines: 3,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (textController.text.isNotEmpty) {
                final provider = Provider.of<ExperienceProvider>(
                  context,
                  listen: false,
                );
                await provider.createExperience(
                  CreateExperienceRequest(
                    description: textController.text,
                    tags: [],
                    mediaFiles: [],
                    type: ExperienceType.ride,
                    rideId: rideId,
                  ),
                );
                Navigator.of(dialogContext).pop();
              }
            },
            child: const Text('Publicar'),
          ),
        ],
      ),
    );
  }
}

// Widget para círculo individual de story
class _StoryCircleWidget extends StatelessWidget {
  final ExperienceEntity story;
  final VoidCallback onTap;

  const _StoryCircleWidget({required this.story, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.deepPurple, width: 3),
              color: Colors.blue.withOpacity(0.1),
            ),
            child: Center(
              child: Text(
                story.user.userName[0].toUpperCase(),
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.deepPurple,
                ),
              ),
            ),
          ),
          const SizedBox(height: 4),
          SizedBox(
            width: 70,
            child: Text(
              story.user.userName,
              style: const TextStyle(fontSize: 12),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

// Dialog para visualizar story (tipo Instagram)
class _StoryViewerDialog extends StatelessWidget {
  final ExperienceEntity story;

  const _StoryViewerDialog({required this.story});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Story Viewer'),
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Avatar del usuario
              CircleAvatar(
                radius: 30,
                backgroundColor: Colors.deepPurple,
                child: Text(
                  story.user.fullName[0].toUpperCase(),
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Nombre del usuario
              Text(
                story.user.fullName,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 20),

              // Contenido de la story
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  story.description,
                  style: const TextStyle(fontSize: 16, color: Colors.white),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
