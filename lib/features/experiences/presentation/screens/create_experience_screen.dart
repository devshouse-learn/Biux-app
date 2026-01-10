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
  final bool
  isStoryMode; // true = solo historias (requiere imagen/video), false/null = modo completo
  final bool isPostMode; // true = solo posts, false/null = modo completo
  final bool
  textOnly; // true = post solo texto (sin multimedia), false = permite multimedia

  const CreateExperienceScreen({
    super.key,
    required this.experienceType,
    this.rideId,
    this.isStoryMode = false,
    this.isPostMode = false,
    this.textOnly = false,
  });

  @override
  State<CreateExperienceScreen> createState() => _CreateExperienceScreenState();
}

class _CreateExperienceScreenState extends State<CreateExperienceScreen> {
  final _descriptionController = TextEditingController();
  // final _tagsController = TextEditingController(); // Ya no se usa
  final _formKey = GlobalKey<FormState>();

  // Tipo de contenido (Story o Post)
  late String _contentType;

  @override
  void initState() {
    super.initState();

    // Establecer el tipo según el modo
    if (widget.isStoryMode) {
      _contentType = 'story';
    } else if (widget.isPostMode) {
      _contentType = 'post';
    } else {
      _contentType = 'story'; // Default
    }

    // Inicializar el tipo de experiencia
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ExperienceCreatorProvider>().setExperienceType(
        widget.experienceType,
        rideId: widget.rideId,
        isTextOnly: widget.textOnly,
      );
    });
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    // _tagsController.dispose(); // Ya no se usa
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ExperienceCreatorProvider>(
      builder: (context, provider, child) {
        // 🔥 LÓGICA AUTOMÁTICA: Si se añaden medios y no estamos en modo fijo, cambiar a historia
        if (!widget.isStoryMode &&
            !widget.isPostMode &&
            provider.mediaItems.isNotEmpty &&
            _contentType != 'story') {
          // Usar Future.microtask para evitar setState durante build
          Future.microtask(() {
            if (mounted) {
              setState(() {
                _contentType = 'story';
              });
            }
          });
        }

        return Scaffold(
          backgroundColor: ColorTokens.neutral10,
          appBar: AppBar(
            title: Text(
              widget.isStoryMode
                  ? 'Nueva Historia'
                  : widget.isPostMode
                  ? 'Nueva Publicación'
                  : widget.experienceType == ExperienceType.ride
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
                        // Selector de tipo de contenido (solo si no está en modo fijo)
                        if (!widget.isStoryMode && !widget.isPostMode) ...[
                          _buildContentTypeSelector(),
                          const SizedBox(height: 24),
                        ],

                        // Selector de multimedia (oculto para posts de solo texto)
                        if (!widget.textOnly) ...[
                          _buildMediaSection(provider),
                          const SizedBox(height: 24),
                        ],

                        // Descripción
                        _buildDescriptionSection(provider),

                        const SizedBox(height: 24),

                        // Tags - REMOVIDO (no se necesita)
                        // _buildTagsSection(provider),
                        // const SizedBox(height: 24),

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
                      _contentType == 'story'
                          ? Icons.image
                          : Icons.photo_library,
                      color: isDark
                          ? ColorTokens.primary30
                          : ColorTokens.primary50,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _contentType == 'story'
                          ? 'Multimedia (Requerida)'
                          : 'Multimedia (Opcional)',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: isDark ? Colors.white : Colors.black,
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
                Container(
                  margin: const EdgeInsets.only(top: 12),
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: isDark
                        ? (_contentType == 'story'
                                  ? ColorTokens.primary50
                                  : ColorTokens.secondary50)
                              .withValues(alpha: 0.15)
                        : (_contentType == 'story'
                                  ? ColorTokens.primary50
                                  : ColorTokens.secondary50)
                              .withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      width: 1.5,
                      color: isDark
                          ? (_contentType == 'story'
                                    ? ColorTokens.primary30
                                    : ColorTokens.secondary30)
                                .withValues(alpha: 0.6)
                          : (_contentType == 'story'
                                    ? ColorTokens.primary50
                                    : ColorTokens.secondary50)
                                .withValues(alpha: 0.5),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        _contentType == 'story'
                            ? Icons.timer_outlined
                            : Icons.info_outline,
                        size: 15,
                        color: isDark
                            ? (_contentType == 'story'
                                  ? ColorTokens.primary30
                                  : ColorTokens.secondary30)
                            : (_contentType == 'story'
                                  ? ColorTokens.primary60
                                  : ColorTokens.secondary60),
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          _contentType == 'story'
                              ? 'Historia requiere imagen o video (máximo 30 segundos)'
                              : 'Publicación: Si agregas multimedia, se publicará como HISTORIA',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            color: isDark
                                ? (_contentType == 'story'
                                      ? ColorTokens.primary30
                                      : ColorTokens.secondary30)
                                : (_contentType == 'story'
                                      ? ColorTokens.primary60
                                      : ColorTokens.secondary60),
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
                // Stories permiten videos (máximo 30s)
                // Posts SOLO permiten fotos (sin videos)
                allowVideo:
                    widget.isStoryMode, // Solo stories pueden tener video
                onImageFromGallery: provider.addImageFromGallery,
                onTakePhoto: provider.takePhoto,
                onVideoFromGallery: widget.isStoryMode
                    ? provider.addVideoFromGallery
                    : null,
                onRecordVideo: widget.isStoryMode ? provider.recordVideo : null,
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
                _contentType == 'story' ? Icons.short_text : Icons.description,
                color: isDark ? ColorTokens.primary30 : ColorTokens.primary50,
              ),
              const SizedBox(width: 8),
              Text(
                _contentType == 'story'
                    ? 'Texto de Historia'
                    : 'Descripción de Publicación',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: isDark ? Colors.white : Colors.black,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          // Ayuda contextual según el tipo
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isDark
                  ? (_contentType == 'story'
                            ? ColorTokens.primary50
                            : ColorTokens.secondary50)
                        .withValues(alpha: 0.15)
                  : (_contentType == 'story'
                            ? ColorTokens.primary50
                            : ColorTokens.secondary50)
                        .withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                width: 1.5,
                color: isDark
                    ? (_contentType == 'story'
                              ? ColorTokens.primary30
                              : ColorTokens.secondary30)
                          .withValues(alpha: 0.6)
                    : (_contentType == 'story'
                              ? ColorTokens.primary50
                              : ColorTokens.secondary50)
                          .withValues(alpha: 0.5),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  _contentType == 'story'
                      ? Icons.lightbulb_outline
                      : Icons.info_outline,
                  size: 17,
                  color: isDark
                      ? (_contentType == 'story'
                            ? ColorTokens.primary30
                            : ColorTokens.secondary30)
                      : (_contentType == 'story'
                            ? ColorTokens.primary60
                            : ColorTokens.secondary60),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _contentType == 'story'
                        ? 'Historia: Texto corto (máximo 100 caracteres)'
                        : 'Publicación: Escribe lo que quieras compartir',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: isDark
                          ? (_contentType == 'story'
                                ? ColorTokens.primary30
                                : ColorTokens.secondary30)
                          : (_contentType == 'story'
                                ? ColorTokens.primary60
                                : ColorTokens.secondary60),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _descriptionController,
            maxLines: _contentType == 'story' ? 3 : 5,
            maxLength: _contentType == 'story' ? 100 : 500,
            style: TextStyle(
              color: isDark ? Colors.white : Colors.black87,
              fontSize: 14,
            ),
            decoration: InputDecoration(
              hintText: _contentType == 'story'
                  ? 'Escribe un texto corto para tu historia...'
                  : 'Describe tu publicación en detalle...',
              hintStyle: TextStyle(
                color: isDark ? Colors.grey[300] : Colors.grey[600],
                fontSize: 14,
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

  // Widget _buildTagsSection removido - ya no se usa
  /*
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
  */

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
          // Información según el tipo de contenido
          if (widget.textOnly) ...[
            _buildInfoItem(
              '📝 Post de solo texto',
              'No se requiere ni permite multimedia. Solo escribe tu publicación.',
            ),
          ] else if (_contentType == 'story') ...[
            _buildInfoItem(
              '⏱️ Historia efímera',
              'Tu historia desaparecerá en 24 horas.',
            ),
            _buildInfoItem(
              '📸 Multimedia requerida',
              'Las historias requieren al menos una imagen o video (<30s).',
            ),
          ] else if (widget.experienceType == ExperienceType.ride) ...[
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
              '📸 Multimedia opcional',
              'Puedes agregar fotos/videos o publicar solo con texto.',
            ),
            _buildInfoItem(
              '� Máximo 5 elementos',
              'Puedes agregar hasta 5 imágenes o videos en total.',
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
    final hasDescription = provider.description.trim().isNotEmpty;
    final hasMedia = provider.mediaItems.isNotEmpty;
    final isProcessing = provider.mediaItems.any((item) => item.isProcessing);

    // Posts de solo texto: NO requieren ni permiten multimedia
    if (widget.textOnly) {
      return hasDescription && !provider.isUploading && !isProcessing;
    }

    // Historias REQUIEREN multimedia (imagen o video)
    if (_contentType == 'story' && !hasMedia) {
      return false;
    }

    // Posts con multimedia: multimedia opcional
    return hasDescription && !provider.isUploading && !isProcessing;
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
            color: Colors.black.withValues(alpha: 0.05),
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
                          ? ColorTokens.primary50.withValues(alpha: 0.1)
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
                          ? ColorTokens.secondary50.withValues(alpha: 0.1)
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
