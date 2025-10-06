import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:biux/features/experiences/domain/entities/experience_entity.dart';
import 'package:biux/features/experiences/presentation/providers/experience_creator_provider.dart';
import 'package:biux/features/experiences/presentation/widgets/media_item_widget.dart';
import 'package:biux/features/experiences/presentation/widgets/media_selector_widget.dart';
import 'package:biux/core/design_system/color_tokens.dart';

/// Pantalla para crear nuevas experiencias
/// Soporta imágenes y videos con compresión automática
class CreateExperienceScreen extends ConsumerStatefulWidget {
  final ExperienceType experienceType;
  final String? rideId;

  const CreateExperienceScreen({
    super.key,
    required this.experienceType,
    this.rideId,
  });

  @override
  ConsumerState<CreateExperienceScreen> createState() =>
      _CreateExperienceScreenState();
}

class _CreateExperienceScreenState
    extends ConsumerState<CreateExperienceScreen> {
  final _descriptionController = TextEditingController();
  final _tagsController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();

    // Inicializar el tipo de experiencia
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref
          .read(experienceCreatorProvider.notifier)
          .setExperienceType(widget.experienceType, rideId: widget.rideId);
    });
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _tagsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(experienceCreatorProvider);
    final notifier = ref.read(experienceCreatorProvider.notifier);

    return Scaffold(
      backgroundColor: ColorTokens.neutral10,
      appBar: AppBar(
        title: Text(
          widget.experienceType == ExperienceType.ride
              ? 'Nueva Experiencia de Rodada'
              : 'Nueva Experiencia',
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor: ColorTokens.primary30,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          if (state.isUploading)
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
            )
          else
            TextButton(
              onPressed: _canPublish(state) ? _publishExperience : null,
              child: Text(
                'Publicar',
                style: TextStyle(
                  color: _canPublish(state) ? Colors.white : Colors.white54,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: Column(
          children: [
            // Indicador de progreso
            if (state.isUploading)
              LinearProgressIndicator(
                value: state.uploadProgress > 0 ? state.uploadProgress : null,
                backgroundColor: Colors.grey[300],
                valueColor: AlwaysStoppedAnimation<Color>(
                  ColorTokens.primary50,
                ),
              ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Selector de multimedia
                    _buildMediaSection(state, notifier),

                    const SizedBox(height: 24),

                    // Descripción
                    _buildDescriptionSection(notifier),

                    const SizedBox(height: 24),

                    // Tags
                    _buildTagsSection(notifier),

                    const SizedBox(height: 24),

                    // Información adicional
                    _buildInfoSection(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMediaSection(
    ExperienceCreatorState state,
    ExperienceCreatorNotifier notifier,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(
                  widget.experienceType == ExperienceType.ride
                      ? Icons.videocam
                      : Icons.photo_library,
                  color: ColorTokens.primary50,
                ),
                const SizedBox(width: 8),
                Text(
                  'Multimedia',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: ColorTokens.neutral90,
                  ),
                ),
                const Spacer(),
                Text(
                  '${state.mediaItems.length}/5',
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ],
            ),
          ),

          // Lista de media items
          if (state.mediaItems.isNotEmpty)
            SizedBox(
              height: 120,
              child: ReorderableListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: state.mediaItems.length,
                onReorder: notifier.reorderMediaItems,
                itemBuilder: (context, index) {
                  final item = state.mediaItems[index];
                  return MediaItemWidget(
                    key: ValueKey(item.filePath),
                    mediaItem: item,
                    onRemove: () => notifier.removeMediaItem(index),
                  );
                },
              ),
            ),

          // Selector de multimedia
          if (state.mediaItems.length < 5)
            Padding(
              padding: const EdgeInsets.all(16),
              child: MediaSelectorWidget(
                allowVideo: widget.experienceType == ExperienceType.ride,
                onImageFromGallery: notifier.addImageFromGallery,
                onTakePhoto: notifier.takePhoto,
                onVideoFromGallery:
                    widget.experienceType == ExperienceType.ride
                        ? notifier.addVideoFromGallery
                        : null,
                onRecordVideo:
                    widget.experienceType == ExperienceType.ride
                        ? notifier.recordVideo
                        : null,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildDescriptionSection(ExperienceCreatorNotifier notifier) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.description, color: ColorTokens.primary50),
              const SizedBox(width: 8),
              Text(
                'Descripción',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: ColorTokens.neutral90,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _descriptionController,
            maxLines: 4,
            maxLength: 300,
            decoration: InputDecoration(
              hintText: 'Describe tu experiencia...',
              hintStyle: TextStyle(color: Colors.grey[400]),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.grey[300]!),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: ColorTokens.primary50),
              ),
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'La descripción es requerida';
              }
              return null;
            },
            onChanged: notifier.updateDescription,
          ),
        ],
      ),
    );
  }

  Widget _buildTagsSection(ExperienceCreatorNotifier notifier) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.tag, color: ColorTokens.primary50),
              const SizedBox(width: 8),
              Text(
                'Tags (opcional)',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: ColorTokens.neutral90,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _tagsController,
            decoration: InputDecoration(
              hintText: 'ej: ciclismo, montaña, aventura (separados por comas)',
              hintStyle: TextStyle(color: Colors.grey[400]),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.grey[300]!),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: ColorTokens.primary50),
              ),
            ),
            onChanged: (value) {
              final tags =
                  value
                      .split(',')
                      .map((tag) => tag.trim())
                      .where((tag) => tag.isNotEmpty)
                      .toList();
              notifier.updateTags(tags);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildInfoSection() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue[200]!),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            children: [
              Icon(Icons.info_outline, color: Colors.blue[600]),
              const SizedBox(width: 8),
              Text(
                'Información',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.blue[800],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (widget.experienceType == ExperienceType.ride) ...[
            _buildInfoItem(
              '📹 Videos de hasta 30 segundos',
              'Los videos se comprimirán automáticamente para optimizar la calidad y el tamaño.',
            ),
            _buildInfoItem(
              '📱 Máximo 5 elementos',
              'Puedes agregar hasta 5 imágenes o videos en total.',
            ),
          ] else ...[
            _buildInfoItem(
              '📸 Solo imágenes',
              'Las experiencias generales no admiten videos.',
            ),
            _buildInfoItem(
              '🖼️ Máximo 5 imágenes',
              'Cada imagen se mostrará por 15 segundos en el visor.',
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoItem(String title, String description) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Colors.blue[700],
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              description,
              style: TextStyle(fontSize: 12, color: Colors.blue[600]),
            ),
          ),
        ],
      ),
    );
  }

  bool _canPublish(ExperienceCreatorState state) {
    return state.mediaItems.isNotEmpty &&
        state.description.trim().isNotEmpty &&
        !state.isUploading &&
        !state.mediaItems.any((item) => item.isProcessing);
  }

  Future<void> _publishExperience() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final notifier = ref.read(experienceCreatorProvider.notifier);
    final success = await notifier.createExperience();

    if (success && mounted) {
      Navigator.of(context).pop(true);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('¡Experiencia publicada exitosamente!'),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      final state = ref.read(experienceCreatorProvider);
      if (state.error != null && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(state.error!), backgroundColor: Colors.red),
        );
        notifier.clearError();
      }
    }
  }
}
