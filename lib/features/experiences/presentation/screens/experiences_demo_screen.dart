import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:biux/core/design_system/locale_notifier.dart';
import 'package:biux/features/experiences/domain/entities/experience_entity.dart';
import 'package:biux/features/experiences/presentation/widgets/experience_story_viewer.dart';
import 'package:biux/features/users/domain/entities/user_entity.dart';

/// Pantalla de ejemplo para mostrar las experiencias funcionando
/// Esta será la base para integrar con las rodadas programadas
class ExperiencesDemoScreen extends StatefulWidget {
  const ExperiencesDemoScreen({super.key});

  @override
  State<ExperiencesDemoScreen> createState() => _ExperiencesDemoScreenState();
}

class _ExperiencesDemoScreenState extends State<ExperiencesDemoScreen> {
  int? _selectedExperienceIndex;
  late List<ExperienceEntity> _experiences;

  @override
  void initState() {
    super.initState();
    _loadDemoExperiences();
  }

  void _loadDemoExperiences() {
    // Crear datos de ejemplo para las experiencias
    final demoUser = UserEntity(
      id: 'demo_user_1',
      fullName: 'Juan Pérez',
      userName: 'juan_perez',
      email: 'juan@example.com',
      photo: 'https://picsum.photos/200',
    );

    _experiences = [
      ExperienceEntity(
        id: 'exp_1',
        user: demoUser,
        media: [
          ExperienceMediaEntity(
            id: 'media_1',
            url: 'https://picsum.photos/400/600?random=1',
            mediaType: MediaType.image,
            duration: 15, // 15 segundos para imágenes
          ),
          ExperienceMediaEntity(
            id: 'media_2',
            url: 'https://picsum.photos/400/600?random=2',
            mediaType: MediaType.image,
            duration: 15,
          ),
        ],
        description: '¡Increíble ruta por la montaña! 🚴‍♂️',
        createdAt: DateTime.now().subtract(const Duration(hours: 2)),
        tags: ['ciclismo', 'montaña'],
        views: 15,
        type: ExperienceType.ride,
      ),
      ExperienceEntity(
        id: 'exp_2',
        user: UserEntity(
          id: 'demo_user_2',
          fullName: 'María González',
          userName: 'maria_gonzalez',
          email: 'maria@example.com',
          photo: 'https://picsum.photos/200?random=3',
        ),
        media: [
          ExperienceMediaEntity(
            id: 'media_3',
            url: 'https://picsum.photos/400/600?random=4',
            mediaType: MediaType.image,
            duration: 15,
          ),
        ],
        description: 'Descanso en el mirador 🌄',
        createdAt: DateTime.now().subtract(const Duration(minutes: 30)),
        tags: ['descanso', 'mirador'],
        views: 23,
        type: ExperienceType.general,
      ),
      ExperienceEntity(
        id: 'exp_3',
        user: UserEntity(
          id: 'demo_user_3',
          fullName: 'Carlos Rodríguez',
          userName: 'carlos_rodriguez',
          email: 'carlos@example.com',
          photo: 'https://picsum.photos/200?random=5',
        ),
        media: [
          ExperienceMediaEntity(
            id: 'media_4',
            url:
                'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4',
            mediaType: MediaType.video,
            duration: 15, // 15 segundos de video
            thumbnailUrl: 'https://picsum.photos/400/600?random=6',
          ),
        ],
        description: '¡Video de la llegada! 🎥',
        createdAt: DateTime.now().subtract(const Duration(minutes: 10)),
        tags: ['llegada', 'video'],
        views: 35,
        type: ExperienceType.ride,
      ),
    ];
  }

  void _openExperience(int index) {
    setState(() {
      _selectedExperienceIndex = index;
    });
  }

  void _closeExperience() {
    setState(() {
      _selectedExperienceIndex = null;
    });
  }

  void _nextExperience() {
    if (_selectedExperienceIndex != null &&
        _selectedExperienceIndex! < _experiences.length - 1) {
      setState(() {
        _selectedExperienceIndex = _selectedExperienceIndex! + 1;
      });
    }
  }

  void _previousExperience() {
    if (_selectedExperienceIndex != null && _selectedExperienceIndex! > 0) {
      setState(() {
        _selectedExperienceIndex = _selectedExperienceIndex! - 1;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = Provider.of<LocaleNotifier>(context, listen: false);
    return Scaffold(
      backgroundColor: Colors.grey[900],
      appBar: AppBar(
        title: Text(
          l.t('exp_demo_title'),
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.grey[900],
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Stack(
        children: [
          // Lista de experiencias
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l.t('exp_demo_recent'),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),

                // Lista de círculos simples (sin widget complejo)
                Container(
                  height: 80,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: _experiences.length,
                    itemBuilder: (context, index) {
                      final experience = _experiences[index];
                      return Padding(
                        padding: const EdgeInsets.only(right: 12),
                        child: GestureDetector(
                          onTap: () => _openExperience(index),
                          child: Column(
                            children: [
                              Container(
                                width: 64,
                                height: 64,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color:
                                        experience.type == ExperienceType.ride
                                        ? Colors.orange
                                        : Colors.cyan,
                                    width: 2,
                                  ),
                                ),
                                child: CircleAvatar(
                                  radius: 30,
                                  backgroundImage: NetworkImage(
                                    experience.user.photo,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                experience.user.fullName.split(' ').first,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),

                const SizedBox(height: 40),

                // Lista detallada de experiencias
                Expanded(
                  child: ListView.builder(
                    itemCount: _experiences.length,
                    itemBuilder: (context, index) {
                      final experience = _experiences[index];
                      return Card(
                        color: Colors.grey[800],
                        margin: const EdgeInsets.only(bottom: 16),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundImage: NetworkImage(
                              experience.user.photo,
                            ),
                          ),
                          title: Text(
                            experience.user.fullName,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          subtitle: Text(
                            experience.description,
                            style: const TextStyle(color: Colors.white70),
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.visibility,
                                color: Colors.white70,
                                size: 16,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '${experience.views}',
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 12,
                                ),
                              ),
                              const SizedBox(width: 12),
                              const Icon(
                                Icons.favorite,
                                color: Colors.red,
                                size: 16,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '${experience.reactions.length}',
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                          onTap: () => _openExperience(index),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),

          // Visor de experiencias en pantalla completa
          if (_selectedExperienceIndex != null)
            ExperienceStoryViewer(
              experience: _experiences[_selectedExperienceIndex!],
              onNext: _nextExperience,
              onPrevious: _previousExperience,
              onClose: _closeExperience,
              onTap: () {
                // Aquí podrías agregar lógica adicional como pausar/reanudar
                debugPrint('Experience tapped');
              },
            ),
        ],
      ),
    );
  }
}
