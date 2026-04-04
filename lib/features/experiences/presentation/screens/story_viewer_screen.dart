import 'package:flutter/material.dart';
import 'package:biux/features/experiences/domain/entities/experience_entity.dart';
import 'package:biux/features/experiences/presentation/widgets/experience_story_viewer.dart';

/// Pantalla que maneja la navegación entre múltiples stories con swipe
/// Similar a Instagram Stories con navegación automática y manual
class StoryViewerScreen extends StatefulWidget {
  final List<ExperienceEntity> stories;
  final int initialIndex;
  final List<({String experienceId, int mediaIndex})>? mediaOrigins;

  const StoryViewerScreen({
    super.key,
    required this.stories,
    this.initialIndex = 0,
    this.mediaOrigins,
  });

  @override
  State<StoryViewerScreen> createState() => _StoryViewerScreenState();
}

class _StoryViewerScreenState extends State<StoryViewerScreen> {
  late PageController _pageController;
  int currentIndex = 0;

  @override
  void initState() {
    super.initState();
    currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: currentIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _goToNextStory() {
    if (currentIndex < widget.stories.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      // Última story, cerrar
      Navigator.of(context).pop();
    }
  }

  void _goToPreviousStory() {
    if (currentIndex > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      // Primera story, cerrar
      Navigator.of(context).pop();
    }
  }

  void _onPageChanged(int index) {
    setState(() {
      currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: PageView.builder(
        controller: _pageController,
        onPageChanged: _onPageChanged,
        itemCount: widget.stories.length,
        itemBuilder: (context, index) {
          final story = widget.stories[index];

          return ExperienceStoryViewer(
            experience: story,
            allStories: widget.stories,
            storyIndex: index,
            onNext: _goToNextStory,
            onPrevious: _goToPreviousStory,
            onClose: () => Navigator.of(context).pop(),
          );
        },
      ),
    );
  }
}
