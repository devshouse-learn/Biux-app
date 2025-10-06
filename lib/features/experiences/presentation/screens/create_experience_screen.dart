import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:biux/features/experiences/domain/entities/experience_entity.dart';
import 'package:biux/features/experiences/presentation/providers/experience_creator_classic_provider.dart';
import 'package:biux/features/experiences/presentation/widgets/media_item_widget.dart';
import 'package:biux/features/experiences/presentation/widgets/media_selector_widget.dart';
import 'package:biux/core/design_system/color_tokens.dart';

/// Pantalla para crear nuevas experiencias
/// Soporta imágenes y videos con compresión automática
class CreateExperienceScreen extends StatefulWidget {
  final ExperienceType experienceType;
  final String? rideId;

  const CreateExperienceScreen({
    super.key,
    required this.experienceType,
    this.rideId,
  });

  @override
  State<CreateExperienceScreen> createState() => _CreateExperienceScreenState();
}

class _CreateExperienceScreenState extends State<CreateExperienceScreen> {
  final _descriptionController = TextEditingController();
  final _tagsController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  // Nuevo: Tipo de contenido (Story o Post)
  String _contentType = 'story'; // 'story' o 'post'

  @override
  void initState() {
    super.initState();

    // Inicializar el tipo de experiencia
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ExperienceCreatorProvider>().setExperienceType(
        widget.experienceType,
        rideId: widget.rideId,
      );
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
    return Consumer<ExperienceCreatorProvider>(
      builder: (context, provider, child) {
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
              if (provider.isUploading)
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
                  onPressed: _canPublish(provider) ? _publishExperience : null,
                  child: Text(
                    'Publicar',
                    style: TextStyle(
                      color: _canPublish(provider)
                          ? Colors.white
                          : Colors.white54,
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
                if (provider.isUploading)
                  LinearProgressIndicator(
                    value: provider.uploadProgress > 0
                        ? provider.uploadProgress
                        : null,
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
                        // Selector de tipo de contenido
                        _buildContentTypeSelector(),

                        const SizedBox(height: 24),

                        // Selector de multimedia
                        _buildMediaSection(provider),

                        const SizedBox(height: 24),

                        // Descripción
                        _buildDescriptionSection(provider),

                        const SizedBox(height: 24),

                        // Tags
                        _buildTagsSection(provider),

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
      },
    );
  }

  Widget _buildMediaSection(ExperienceCreatorProvider provider) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[800] : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? Colors.grey[600]! : Colors.grey[300]!,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  children: [
                    Icon(
                      widget.experienceType == ExperienceType.ride
                          ? Icons.videocam
                          : Icons.photo_library,
                      color: isDark
                          ? ColorTokens.primary30
                          : ColorTokens.primary50,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Multimedia',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      '${provider.mediaItems.length}/5',
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark ? Colors.grey[400] : Colors.grey[600],
                      ),
                    ),
                  ],
                ),
                // Ayuda contextual para medios
                if (_contentType == 'story')
                  Container(
                    margin: const EdgeInsets.only(top: 12),
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: ColorTokens.primary50.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                        color: ColorTokens.primary50.withOpacity(0.3),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.tips_and_updates,
                          size: 14,
                          color: ColorTokens.primary50,
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            'Stories necesitan al menos un video (preferido) o imagen',
                            style: TextStyle(
                              fontSize: 11,
                              color: ColorTokens.primary50,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),

          // Lista de media items
          if (provider.mediaItems.isNotEmpty)
            SizedBox(
              height: 120,
              child: ReorderableListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: provider.mediaItems.length,
                onReorder: provider.reorderMediaItems,
                itemBuilder: (context, index) {
                  final item = provider.mediaItems[index];
                  return MediaItemWidget(
                    key: ValueKey(item.filePath),
                    mediaItem: item,
                    onRemove: () => provider.removeMediaItem(index),
                  );
                },
              ),
            ),

          // Selector de multimedia
          if (provider.mediaItems.length < 5)
            Padding(
              padding: const EdgeInsets.all(16),
              child: MediaSelectorWidget(
                allowVideo:
                    widget.experienceType == ExperienceType.ride ||
                    _contentType == 'story',
                onImageFromGallery: provider.addImageFromGallery,
                onTakePhoto: provider.takePhoto,
                onVideoFromGallery:
                    widget.experienceType == ExperienceType.ride ||
                        _contentType == 'story'
                    ? provider.addVideoFromGallery
                    : null,
                onRecordVideo:
                    widget.experienceType == ExperienceType.ride ||
                        _contentType == 'story'
                    ? provider.recordVideo
                    : null,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildDescriptionSection(ExperienceCreatorProvider provider) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[800] : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? Colors.grey[600]! : Colors.grey[300]!,
        ),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.description,
                color: isDark ? ColorTokens.primary30 : ColorTokens.primary50,
              ),
              const SizedBox(width: 8),
              Text(
                _contentType == 'story'
                    ? 'Descripción (Story)'
                    : 'Descripción (Post)',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          // Ayuda contextual según el tipo
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: _contentType == 'story'
                  ? ColorTokens.primary50.withOpacity(0.1)
                  : ColorTokens.secondary50.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: _contentType == 'story'
                    ? ColorTokens.primary50.withOpacity(0.3)
                    : ColorTokens.secondary50.withOpacity(0.3),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  _contentType == 'story'
                      ? Icons.lightbulb_outline
                      : Icons.info_outline,
                  size: 16,
                  color: _contentType == 'story'
                      ? ColorTokens.primary50
                      : ColorTokens.secondary50,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _contentType == 'story'
                        ? 'Para stories (videos): Mantén el texto corto (máximo 50 caracteres)'
                        : 'Para posts (fotos): Puedes escribir tanto como quieras',
                    style: TextStyle(
                      fontSize: 12,
                      color: _contentType == 'story'
                          ? ColorTokens.primary50
                          : ColorTokens.secondary50,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _descriptionController,
            maxLines: _contentType == 'story' ? 2 : 4,
            maxLength: _contentType == 'story' ? 50 : 300,
            style: TextStyle(color: isDark ? Colors.white : Colors.black87),
            decoration: InputDecoration(
              hintText: _contentType == 'story'
                  ? 'Descripción corta para tu video story...'
                  : 'Describe tu experiencia con fotos en detalle...',
              hintStyle: TextStyle(
                color: isDark ? Colors.grey[400] : Colors.grey[500],
              ),
              filled: true,
              fillColor: isDark ? Colors.grey[700] : Colors.grey[50],
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(
                  color: isDark ? Colors.grey[600]! : Colors.grey[300]!,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(
                  color: isDark ? Colors.grey[600]! : Colors.grey[300]!,
                ),
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
            onChanged: provider.updateDescription,
          ),
        ],
      ),
    );
  }

  Widget _buildTagsSection(ExperienceCreatorProvider provider) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[800] : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? Colors.grey[600]! : Colors.grey[300]!,
        ),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.tag,
                color: isDark ? ColorTokens.primary30 : ColorTokens.primary50,
              ),
              const SizedBox(width: 8),
              Text(
                'Tags (opcional)',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _tagsController,
            style: TextStyle(color: isDark ? Colors.white : Colors.black87),
            decoration: InputDecoration(
              hintText: 'ej: ciclismo, montaña, aventura (separados por comas)',
              hintStyle: TextStyle(
                color: isDark ? Colors.grey[400] : Colors.grey[500],
              ),
              filled: true,
              fillColor: isDark ? Colors.grey[700] : Colors.grey[50],
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(
                  color: isDark ? Colors.grey[600]! : Colors.grey[300]!,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(
                  color: isDark ? Colors.grey[600]! : Colors.grey[300]!,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: ColorTokens.primary50),
              ),
            ),
            onChanged: (value) {
              final tags = value
                  .split(',')
                  .map((tag) => tag.trim())
                  .where((tag) => tag.isNotEmpty)
                  .toList();
              provider.updateTags(tags);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildInfoSection() {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark
            ? Colors.blue[900]?.withValues(alpha: 0.3)
            : Colors.blue[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? Colors.blue[400]! : Colors.blue[200]!,
        ),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            children: [
              Icon(
                Icons.info_outline,
                color: isDark ? Colors.blue[300] : Colors.blue[600],
              ),
              const SizedBox(width: 8),
              Text(
                'Información',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.blue[200] : Colors.blue[800],
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
    final isDark = Theme.of(context).brightness == Brightness.dark;

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
              color: isDark ? Colors.blue[300] : Colors.blue[700],
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              description,
              style: TextStyle(
                fontSize: 12,
                color: isDark ? Colors.blue[200] : Colors.blue[600],
              ),
            ),
          ),
        ],
      ),
    );
  }

  bool _canPublish(ExperienceCreatorProvider provider) {
    return provider.mediaItems.isNotEmpty &&
        provider.description.trim().isNotEmpty &&
        !provider.isUploading &&
        !provider.mediaItems.any((item) => item.isProcessing);
  }

  Future<void> _publishExperience() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final provider = context.read<ExperienceCreatorProvider>();
    final success = await provider.createExperience();

    if (success && mounted) {
      Navigator.of(context).pop(true);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('¡Experiencia publicada exitosamente!'),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      if (provider.error != null && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(provider.error!), backgroundColor: Colors.red),
        );
        provider.clearError();
      }
    }
  }

  /// Construye el selector de tipo de contenido (Story vs Post)
  Widget _buildContentTypeSelector() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '¿Qué quieres crear?',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: ColorTokens.neutral80,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              // Opción Story
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      _contentType = 'story';
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: _contentType == 'story'
                          ? ColorTokens.primary50.withOpacity(0.1)
                          : ColorTokens.neutral10,
                      border: Border.all(
                        color: _contentType == 'story'
                            ? ColorTokens.primary50
                            : ColorTokens.neutral30,
                        width: 2,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        Icon(
                          Icons.play_circle_outline,
                          color: _contentType == 'story'
                              ? ColorTokens.primary50
                              : ColorTokens.neutral60,
                          size: 32,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Story',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: _contentType == 'story'
                                ? ColorTokens.primary50
                                : ColorTokens.neutral70,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Videos + texto corto',
                          style: TextStyle(
                            fontSize: 11,
                            color: ColorTokens.neutral60,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              // Opción Post
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      _contentType = 'post';
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: _contentType == 'post'
                          ? ColorTokens.secondary50.withOpacity(0.1)
                          : ColorTokens.neutral10,
                      border: Border.all(
                        color: _contentType == 'post'
                            ? ColorTokens.secondary50
                            : ColorTokens.neutral30,
                        width: 2,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        Icon(
                          Icons.article_outlined,
                          color: _contentType == 'post'
                              ? ColorTokens.secondary50
                              : ColorTokens.neutral60,
                          size: 32,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Post',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: _contentType == 'post'
                                ? ColorTokens.secondary50
                                : ColorTokens.neutral70,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Fotos + texto largo',
                          style: TextStyle(
                            fontSize: 11,
                            color: ColorTokens.neutral60,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
