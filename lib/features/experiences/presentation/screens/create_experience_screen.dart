import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:biux/features/experiences/domain/entities/experience_entity.dart';
import 'package:biux/features/experiences/domain/repositories/experience_repository.dart';
import 'package:biux/features/experiences/presentation/providers/experience_classic_provider.dart';
import 'package:biux/features/experiences/presentation/providers/experience_creator_classic_provider.dart';
import 'package:biux/features/experiences/presentation/widgets/media_item_widget.dart';
import 'package:biux/features/experiences/presentation/widgets/media_selector_widget.dart';
import 'package:biux/core/design_system/color_tokens.dart';
import 'package:biux/features/experiences/presentation/screens/image_crop_editor_screen.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;

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
  final ExperienceEntity? experienceToEdit; // Para modo edición

  const CreateExperienceScreen({
    super.key,
    required this.experienceType,
    this.rideId,
    this.isStoryMode = false,
    this.isPostMode = false,
    this.textOnly = false,
    this.experienceToEdit,
  });

  @override
  State<CreateExperienceScreen> createState() => _CreateExperienceScreenState();
}

class _CreateExperienceScreenState extends State<CreateExperienceScreen> {
  final _descriptionController = TextEditingController();
  // final _tagsController = TextEditingController(); // Ya no se usa
  final _formKey = GlobalKey<FormState>();
  final _descriptionFocusNode = FocusNode();

  // Tipo de contenido (Story o Post)
  late String _contentType;

  // Índice de la imagen cuya descripción se está editando (null = descripción general)
  int? _editingMediaIndex;

  // Modo edición
  bool get _isEditMode => widget.experienceToEdit != null;

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

    // Pre-llenar datos si estamos en modo edición
    if (_isEditMode) {
      _descriptionController.text = widget.experienceToEdit!.description;
    }

    // Inicializar el tipo de experiencia con el formato correcto
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final creatorProvider = context.read<ExperienceCreatorProvider>();
      creatorProvider.setExperienceType(
        widget.experienceType,
        rideId: widget.rideId,
        isTextOnly: widget.textOnly,
        format: widget.isStoryMode
            ? ExperienceFormat.story
            : ExperienceFormat.post,
      );

      // En modo edición, pre-cargar la descripción y media en el provider
      if (_isEditMode) {
        creatorProvider.updateDescription(widget.experienceToEdit!.description);
        creatorProvider.loadExistingMedia(widget.experienceToEdit!.media);
      }
    });
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _descriptionFocusNode.dispose();
    // _tagsController.dispose(); // Ya no se usa
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ExperienceCreatorProvider>(
      builder: (context, provider, child) {
        return PopScope(
          canPop: false,
          onPopInvokedWithResult: (didPop, result) {
            if (didPop) return;
            _showDeleteDialog(context);
          },
          child: Scaffold(
            backgroundColor: ColorTokens.neutral10,
            appBar: AppBar(
              title: Text(
                _isEditMode
                    ? 'Editar Publicación'
                    : widget.isStoryMode
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
              leading: PopupMenuButton<String>(
                icon: Icon(Icons.more_vert, color: Colors.white),
                onSelected: (value) {
                  if (value == 'delete') {
                    _showDeleteDialog(context);
                  }
                },
                itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                  PopupMenuItem<String>(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(Icons.delete_outline, color: Colors.red),
                        SizedBox(width: 8),
                        Text(
                          widget.isPostMode
                              ? 'Descartar Publicación'
                              : 'Descartar Historia',
                          style: TextStyle(color: Colors.red),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
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
                    onPressed: _canPublish(provider)
                        ? _publishExperience
                        : null,
                    child: Text(
                      _isEditMode ? 'Guardar y publicar cambios' : 'Publicar',
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
                      'Multimedia (Requerida)',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: isDark ? Colors.white : Colors.black,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      '${provider.mediaItems.length}/10',
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
                              : 'Agrega fotos o videos a tu publicación',
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
                    key: ValueKey(
                      item.isRemote ? 'remote_$index' : item.filePath,
                    ),
                    mediaItem: item,
                    onRemove: () {
                      if (_editingMediaIndex == index) {
                        _stopEditingMediaDescription(provider);
                      } else if (_editingMediaIndex != null &&
                          _editingMediaIndex! > index) {
                        setState(
                          () => _editingMediaIndex = _editingMediaIndex! - 1,
                        );
                      }
                      provider.removeMediaItem(index);
                    },
                    onTap: item.isImage && !item.isProcessing
                        ? () => _onMediaItemTap(context, provider, index, item)
                        : null,
                    onEditDescription:
                        _contentType == 'story' &&
                            item.isImage &&
                            !item.isProcessing
                        ? () => _startEditingMediaDescription(
                            provider,
                            index,
                            item,
                          )
                        : null,
                  );
                },
              ),
            ),

          // Selector de multimedia
          if (provider.mediaItems.length < 10)
            Padding(
              padding: const EdgeInsets.all(16),
              child: MediaSelectorWidget(
                allowVideo: true,
                onImageFromGallery: () =>
                    provider.addMultipleImagesFromGallery(),
                onTakePhoto: () =>
                    _openImagePickerWithCrop(context, provider, isCamera: true),
                onVideoFromGallery: provider.addVideoFromGallery,
                onRecordVideo: provider.recordVideo,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildDescriptionSection(ExperienceCreatorProvider provider) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isEditingMedia =
        _contentType == 'story' && _editingMediaIndex != null;

    // Título dinámico
    String headerText;
    if (isEditingMedia) {
      headerText = 'Texto de imagen ${_editingMediaIndex! + 1}';
    } else if (_contentType == 'story') {
      headerText = 'Texto de Historia';
    } else {
      headerText = 'Descripción de Publicación';
    }

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
                isEditingMedia
                    ? Icons.image
                    : (_contentType == 'story'
                          ? Icons.short_text
                          : Icons.description),
                color: isEditingMedia
                    ? Colors.blue
                    : (isDark ? ColorTokens.primary30 : ColorTokens.primary50),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  headerText,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: isEditingMedia
                        ? Colors.blue
                        : (isDark ? Colors.white : Colors.black),
                  ),
                ),
              ),
              if (isEditingMedia)
                GestureDetector(
                  onTap: () => _stopEditingMediaDescription(provider),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.blue.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.close, size: 16, color: Colors.blue),
                        SizedBox(width: 4),
                        Text(
                          'Volver a historia',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.blue,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
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
            focusNode: _descriptionFocusNode,
            maxLines: _contentType == 'story' ? 3 : 5,
            maxLength: isEditingMedia
                ? 200
                : (_contentType == 'story' ? 100 : 500),
            style: TextStyle(
              color: isDark ? Colors.white : Colors.black87,
              fontSize: 14,
            ),
            decoration: InputDecoration(
              hintText: isEditingMedia
                  ? 'Escribe una descripción para esta imagen...'
                  : (_contentType == 'story'
                        ? 'Escribe un texto corto para tu historia...'
                        : 'Describe tu publicación en detalle...'),
              hintStyle: TextStyle(
                color: isDark ? Colors.grey[300] : Colors.grey[600],
                fontSize: 14,
              ),
              filled: true,
              fillColor: isDark ? Colors.grey[700] : Colors.grey[50],
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(
                  color: isEditingMedia
                      ? Colors.blue
                      : (isDark ? Colors.grey[600]! : Colors.grey[300]!),
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(
                  color: isEditingMedia
                      ? Colors.blue
                      : (isDark ? Colors.grey[600]! : Colors.grey[300]!),
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(
                  color: isEditingMedia ? Colors.blue : ColorTokens.primary50,
                ),
              ),
            ),
            validator: (value) {
              // La descripción es opcional
              return null;
            },
            onChanged: (text) {
              if (isEditingMedia) {
                provider.updateMediaDescription(_editingMediaIndex!, text);
              } else {
                provider.updateDescription(text);
              }
            },
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
              '📸 Multimedia requerida',
              'Debes agregar al menos una foto o video para publicar.',
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

    // Modo edición: solo requiere que no esté subiendo
    if (_isEditMode) {
      return !provider.isUploading && !isProcessing;
    }

    // Posts de solo texto: NO requieren ni permiten multimedia
    if (widget.textOnly) {
      return hasDescription && !provider.isUploading && !isProcessing;
    }

    // Historias REQUIEREN multimedia (imagen o video)
    if (_contentType == 'story' && !hasMedia) {
      return false;
    }

    // Posts con multimedia: REQUIEREN multimedia, descripción es opcional
    return hasMedia && !provider.isUploading && !isProcessing;
  }

  Future<void> _publishExperience() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_isEditMode) {
      // Modo edición: actualizar experiencia existente
      final experienceProvider = context.read<ExperienceProvider>();
      final creatorProvider = context.read<ExperienceCreatorProvider>();
      final newDescription = _descriptionController.text.trim();

      // Separar media existente (remota) de media nueva (local)
      final existingMediaUrls = <String>[];
      final newMediaFiles = <CreateMediaRequest>[];

      for (final item in creatorProvider.mediaItems) {
        if (item.isRemote) {
          existingMediaUrls.add(item.url!);
        } else {
          newMediaFiles.add(
            CreateMediaRequest(
              filePath: item.filePath,
              mediaType: item.mediaType,
              duration: item.duration,
              aspectRatio: item.aspectRatio,
            ),
          );
        }
      }

      final success = await experienceProvider.updateExperience(
        widget.experienceToEdit!.id,
        description: newDescription,
        existingMediaUrls: existingMediaUrls,
        newMediaFiles: newMediaFiles.isNotEmpty ? newMediaFiles : null,
      );

      if (success && mounted) {
        final provider = context.read<ExperienceCreatorProvider>();
        provider.reset();
        Navigator.of(context).pop(true);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('¡Publicación actualizada exitosamente!'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(experienceProvider.error ?? 'Error al actualizar'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } else {
      // Modo creación: crear nueva experiencia
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
            SnackBar(
              content: Text(provider.error!),
              backgroundColor: Colors.red,
            ),
          );
          provider.clearError();
        }
      }
    }
  }

  void _showDeleteDialog(BuildContext context) {
    final title = widget.isPostMode
        ? 'Descartar Publicación'
        : 'Descartar Historia';
    final content = widget.isPostMode
        ? '¿Estás seguro de que deseas descartar esta publicación? Se perderán todos los cambios.'
        : '¿Estás seguro de que deseas descartar esta historia? Se perderán todos los cambios.';
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              // Limpiar el estado del provider antes de salir
              final provider = context.read<ExperienceCreatorProvider>();
              provider.reset();
              Navigator.of(context).pop(false);
            },
            child: const Text('Descartar'),
          ),
        ],
      ),
    );
  }

  /// Activa edición inline de la descripción de una imagen en el campo "Texto de Historia"
  void _startEditingMediaDescription(
    ExperienceCreatorProvider provider,
    int index,
    MediaItem item,
  ) {
    setState(() {
      _editingMediaIndex = index;
      _descriptionController.text = item.description ?? '';
    });
    _descriptionFocusNode.requestFocus();
  }

  /// Vuelve a la descripción general de la historia
  void _stopEditingMediaDescription(ExperienceCreatorProvider provider) {
    setState(() {
      _editingMediaIndex = null;
      _descriptionController.text = provider.description;
    });
  }

  /// Manejar tap en un media item para ajustar encuadre
  Future<void> _onMediaItemTap(
    BuildContext context,
    ExperienceCreatorProvider provider,
    int index,
    MediaItem item,
  ) async {
    try {
      File imageFile;

      if (item.isRemote) {
        // Descargar imagen remota a archivo temporal
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Descargando imagen...'),
            duration: Duration(seconds: 1),
          ),
        );

        final response = await http.get(Uri.parse(item.url!));
        if (response.statusCode != 200) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Error al descargar la imagen'),
                backgroundColor: Colors.red,
              ),
            );
          }
          return;
        }

        final tempDir = await getTemporaryDirectory();
        final tempFile = File(
          '${tempDir.path}/edit_${DateTime.now().millisecondsSinceEpoch}.jpg',
        );
        await tempFile.writeAsBytes(response.bodyBytes);
        imageFile = tempFile;
      } else {
        // Imagen local
        imageFile = File(item.filePath);
        if (!imageFile.existsSync()) return;
      }

      if (!mounted) return;

      // Abrir editor de crop
      final croppedFile = await Navigator.of(context).push<File>(
        MaterialPageRoute(
          builder: (_) => ImageCropEditorScreen(
            imageFile: imageFile,
            title: 'Ajustar encuadre',
          ),
        ),
      );

      if (croppedFile != null) {
        // Reemplazar el item con la versión recortada
        provider.replaceMediaItem(
          index,
          MediaItem(
            filePath: croppedFile.path,
            mediaType: MediaType.image,
            duration: 0,
            aspectRatio: 1.0,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  /// Abre el selector de imágenes y después el editor de crop
  Future<void> _openImagePickerWithCrop(
    BuildContext context,
    ExperienceCreatorProvider provider, {
    required bool isCamera,
  }) async {
    try {
      // Usar el método del provider para obtener la imagen
      if (isCamera) {
        // Tomar foto
        final navigator = Navigator.of(context);

        // Primero obtener la imagen usando el picker del provider
        final imagePicker = provider.imagePicker;
        final XFile? pickedFile = await imagePicker.pickImage(
          source: ImageSource.camera,
          maxWidth: 1080,
          maxHeight: 1350,
          imageQuality: 85,
        );

        if (pickedFile != null && mounted) {
          final file = File(pickedFile.path);
          if (file.existsSync()) {
            // Abrir el editor de crop
            final croppedFile = await navigator.push<File>(
              MaterialPageRoute(
                builder: (_) => ImageCropEditorScreen(
                  imageFile: file,
                  title: 'Ajustar foto - Formato cuadrado',
                ),
              ),
            );

            if (croppedFile != null) {
              // Añadir la imagen recortada al provider
              provider.addCroppedImage(croppedFile);
            }
          }
        }
      } else {
        // Seleccionar desde galería
        final navigator = Navigator.of(context);

        final imagePicker = provider.imagePicker;
        final XFile? pickedFile = await imagePicker.pickImage(
          source: ImageSource.gallery,
          maxWidth: 1080,
          maxHeight: 1350,
          imageQuality: 85,
        );

        if (pickedFile != null && mounted) {
          final file = File(pickedFile.path);
          if (file.existsSync()) {
            // Abrir el editor de crop
            final croppedFile = await navigator.push<File>(
              MaterialPageRoute(
                builder: (_) => ImageCropEditorScreen(
                  imageFile: file,
                  title: 'Ajustar imagen - Formato cuadrado',
                ),
              ),
            );

            if (croppedFile != null) {
              // Añadir la imagen recortada al provider
              provider.addCroppedImage(croppedFile);
            }
          }
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
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
