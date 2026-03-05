import 'package:flutter/material.dart';
import 'package:biux/features/experiences/domain/entities/experience_entity.dart';
import 'package:biux/features/experiences/presentation/screens/create_experience_screen.dart';

/// Pantalla de edición que reutiliza CreateExperienceScreen en modo edición
class EditExperienceScreen extends StatelessWidget {
  final ExperienceEntity experience;

  const EditExperienceScreen({super.key, required this.experience});

  @override
  Widget build(BuildContext context) {
    return CreateExperienceScreen(
      experienceType: experience.type,
      rideId: experience.rideId,
      isPostMode: experience.isPostFormat,
      isStoryMode: experience.isStoryFormat,
      experienceToEdit: experience,
    );
  }
}
