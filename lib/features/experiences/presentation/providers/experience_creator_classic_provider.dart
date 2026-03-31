import 'package:flutter/foundation.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:video_player/video_player.dart';
import 'package:biux/features/experiences/domain/entities/experience_entity.dart';
import 'package:biux/features/experiences/domain/repositories/experience_repository.dart';
import 'package:biux/features/experiences/data/repositories/experience_repository_impl.dart';
import 'package:biux/features/experiences/presentation/providers/experience_classic_provider.dart';

/// Item multimedia para la experiencia
class MediaItem {
  final String filePath;
  final MediaType mediaType;
  final int duration;
  final double? aspectRatio;
  final String? thumbnailPath;
  final bool isProcessing;
  final String? url; // URL remota para media ya subida (modo edición)
  final String? description; // Descripción individual por imagen (stories)

  const MediaItem({
    required this.filePath,
    required this.mediaType,
    required this.duration,
    this.aspectRatio,
    this.thumbnailPath,
    this.isProcessing = false,
    this.url,
    this.description,
  });

  bool get isVideo => mediaType == MediaType.video;
  bool get isImage => mediaType == MediaType.image;
  bool get isRemote => url != null && url!.isNotEmpty;

  MediaItem copyWith({
    String? filePath,
    MediaType? mediaType,
    int? duration,
    double? aspectRatio,
    String? thumbnailPath,
    bool? isProcessing,
    String? url,
    String? description,
  }) {
    return MediaItem(
      filePath: filePath ?? this.filePath,
      mediaType: mediaType ?? this.mediaType,
      duration: duration ?? this.duration,
      aspectRatio: aspectRatio ?? this.aspectRatio,
      thumbnailPath: thumbnailPath ?? this.thumbnailPath,
      isProcessing: isProcessing ?? this.isProcessing,
      url: url ?? this.url,
      description: description ?? this.description,
    );
  }
}

/// Provider clásico para la creación de experiencias
class ExperienceCreatorProvider extends ChangeNotifier {
  final ExperienceRepository _repository;
  final ExperienceProvider? _experienceProvider;
  final ImagePicker _imagePicker = ImagePicker();

  ExperienceCreatorProvider({
    ExperienceRepository? repository,
    ExperienceProvider? experienceProvider,
  }) : _repository = repository ?? ExperienceRepositoryImpl(),
       _experienceProvider = experienceProvider;

  // Estado
  List<MediaItem> _mediaItems = [];
  String _description = '';
  List<String> _tags = [];
  ExperienceType? _experienceType;
  String? _rideId;
  bool _isUploading = false;
  double _uploadProgress = 0.0;
  String? _error;
  bool _isRecording = false;
  VideoPlayerController? _videoController;
  bool _isTextOnly = false; // Post de solo texto (sin multimedia)
  ExperienceFormat _format = ExperienceFormat.post;

  // Getters
  List<MediaItem> get mediaItems => _mediaItems;
  String get description => _description;
  List<String> get tags => _tags;
  ExperienceType? get experienceType => _experienceType;
  String? get rideId => _rideId;
  ImagePicker get imagePicker => _imagePicker;
  bool get isUploading => _isUploading;
  double get uploadProgress => _uploadProgress;
  String? get error => _error;
  bool get isRecording => _isRecording;
  VideoPlayerController? get videoController => _videoController;
  bool get isTextOnly => _isTextOnly;
  ExperienceFormat get format => _format;

  /// Actualizar descripción
  void updateDescription(String description) {
    _description = description;
    notifyListeners();
  }

  /// Actualizar tags
  void updateTags(List<String> tags) {
    _tags = tags;
    notifyListeners();
  }

  /// Establecer tipo de experiencia
  void setExperienceType(
    ExperienceType type, {
    String? rideId,
    bool isTextOnly = false,
    ExperienceFormat format = ExperienceFormat.post,
  }) {
    _experienceType = type;
    _rideId = rideId;
    _isTextOnly = isTextOnly;
    _format = format;
    notifyListeners();
  }

  /// Agregar imagen desde galería
  Future<void> addImageFromGallery() async {
    if (_mediaItems.length >= 10) {
      _error = 'exp_max_files_allowed';
      notifyListeners();
      return;
    }
    try {
      final isStory = _format == ExperienceFormat.story;
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: isStory ? 1920 : 1080,
        maxHeight: isStory ? 2400 : 1350,
        imageQuality: isStory ? 95 : 85,
      );

      if (image != null) {
        // Verificar que el archivo existe
        final file = File(image.path);
        if (!file.existsSync()) {
          _error = 'exp_file_not_available';
          notifyListeners();
          return;
        }

        final mediaItem = MediaItem(
          filePath: image.path,
          mediaType: MediaType.image,
          duration: 15, // 15 segundos estándar para todas las historias
        );

        _mediaItems = [..._mediaItems, mediaItem];
        notifyListeners();
      }
    } catch (e) {
      _error = 'exp_error_selecting_image';
      notifyListeners();
    }
  }

  /// Agregar múltiples imágenes desde galería
  Future<void> addMultipleImagesFromGallery() async {
    try {
      final remaining = 10 - _mediaItems.length;
      if (remaining <= 0) {
        _error = 'exp_max_images_reached';
        notifyListeners();
        return;
      }

      final List<XFile> images = await _imagePicker.pickMultiImage(
        maxWidth: _format == ExperienceFormat.story ? 1920 : 1080,
        maxHeight: _format == ExperienceFormat.story ? 2400 : 1350,
        imageQuality: _format == ExperienceFormat.story ? 95 : 85,
        limit: remaining,
      );

      if (images.isNotEmpty) {
        final allowed = 10 - _mediaItems.length;
        final selected = images.take(allowed);
        final newItems = <MediaItem>[];
        for (final image in selected) {
          final file = File(image.path);
          if (file.existsSync()) {
            newItems.add(
              MediaItem(
                filePath: image.path,
                mediaType: MediaType.image,
                duration: 15,
              ),
            );
          }
        }
        if (newItems.isNotEmpty) {
          _mediaItems = [..._mediaItems, ...newItems];
          notifyListeners();
        }
      }
    } catch (e) {
      _error = 'exp_error_selecting_images';
      notifyListeners();
    }
  }

  /// Tomar foto
  Future<void> takePhoto() async {
    if (_mediaItems.length >= 10) {
      _error = 'exp_max_files_allowed';
      notifyListeners();
      return;
    }
    try {
      final isStory = _format == ExperienceFormat.story;
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.camera,
        maxWidth: isStory ? 1920 : 1080,
        maxHeight: isStory ? 2400 : 1350,
        imageQuality: isStory ? 95 : 85,
      );

      if (image != null) {
        // Verificar que el archivo existe
        final file = File(image.path);
        if (!file.existsSync()) {
          _error = 'exp_photo_not_available';
          notifyListeners();
          return;
        }

        final mediaItem = MediaItem(
          filePath: image.path,
          mediaType: MediaType.image,
          duration: 15, // 15 segundos estándar para todas las historias
        );

        _mediaItems = [..._mediaItems, mediaItem];
        notifyListeners();
      }
    } catch (e) {
      _error = 'exp_error_taking_photo';
      notifyListeners();
    }
  }

  /// Agregar imagen que ya ha sido recortada
  void addCroppedImage(File croppedImageFile) {
    if (_mediaItems.length >= 10) {
      _error = 'exp_max_files_allowed';
      notifyListeners();
      return;
    }
    try {
      if (!croppedImageFile.existsSync()) {
        _error = 'exp_cropped_not_available';
        notifyListeners();
        return;
      }

      final mediaItem = MediaItem(
        filePath: croppedImageFile.path,
        mediaType: MediaType.image,
        duration: 15, // 15 segundos estándar para todas las historias
      );

      _mediaItems = [..._mediaItems, mediaItem];
      _error = null;
      notifyListeners();
    } catch (e) {
      _error = 'exp_error_adding_cropped';
      notifyListeners();
    }
  }

  /// Agregar video desde galería
  Future<void> addVideoFromGallery() async {
    if (_mediaItems.length >= 10) {
      _error = 'exp_max_files_allowed';
      notifyListeners();
      return;
    }
    try {
      final XFile? video = await _imagePicker.pickVideo(
        source: ImageSource.gallery,
        maxDuration: const Duration(seconds: 30),
      );

      if (video != null) {
        // Verificar que el archivo existe
        final file = File(video.path);
        if (!file.existsSync()) {
          _error = 'exp_video_not_available';
          notifyListeners();
          return;
        }

        // Crear controlador de video para obtener duración
        final controller = VideoPlayerController.file(file);

        await controller.initialize();
        final duration = controller.value.duration.inSeconds;
        controller.dispose();

        // Validar duración máxima de 30 segundos
        if (duration > 30) {
          _error = 'exp_video_too_long';
          notifyListeners();
          return;
        }

        // Limitar duración de videos a máximo 15 segundos (estándar de historias)
        final actualDuration = duration > 15 ? 15 : duration;

        final mediaItem = MediaItem(
          filePath: video.path,
          mediaType: MediaType.video,
          duration: actualDuration, // Máximo 15 segundos
        );

        _mediaItems = [..._mediaItems, mediaItem];
        notifyListeners();
      }
    } catch (e) {
      _error = 'exp_error_selecting_video';
      notifyListeners();
    }
  }

  /// Grabar video
  Future<void> recordVideo() async {
    if (_mediaItems.length >= 10) {
      _error = 'exp_max_files_allowed';
      notifyListeners();
      return;
    }
    try {
      final XFile? video = await _imagePicker.pickVideo(
        source: ImageSource.camera,
        maxDuration: const Duration(seconds: 30),
      );

      if (video != null) {
        // Verificar que el archivo existe
        final file = File(video.path);
        if (!file.existsSync()) {
          _error = 'exp_recorded_not_available';
          notifyListeners();
          return;
        }

        final controller = VideoPlayerController.file(file);

        await controller.initialize();
        final duration = controller.value.duration.inSeconds;
        controller.dispose();

        // Validar duración máxima de 30 segundos
        if (duration > 30) {
          _error = 'exp_video_too_long';
          notifyListeners();
          return;
        }

        // Limitar duración de videos a máximo 15 segundos (estándar de historias)
        final actualDuration = duration > 15 ? 15 : duration;

        final mediaItem = MediaItem(
          filePath: video.path,
          mediaType: MediaType.video,
          duration: actualDuration, // Máximo 15 segundos
        );

        _mediaItems = [..._mediaItems, mediaItem];
        notifyListeners();
      }
    } catch (e) {
      _error = 'exp_error_recording_video';
      notifyListeners();
    }
  }

  /// Remover item multimedia
  void removeMediaItem(int index) {
    if (index >= 0 && index < _mediaItems.length) {
      _mediaItems = List.from(_mediaItems)..removeAt(index);
      notifyListeners();
    }
  }

  /// Reordenar items multimedia
  void reorderMediaItems(int oldIndex, int newIndex) {
    if (oldIndex < newIndex) {
      newIndex -= 1;
    }

    final List<MediaItem> newMediaItems = List.from(_mediaItems);
    final MediaItem item = newMediaItems.removeAt(oldIndex);
    newMediaItems.insert(newIndex, item);

    _mediaItems = newMediaItems;
    notifyListeners();
  }

  /// Crear experiencia
  Future<bool> createExperience() async {
    // Validar límite máximo de archivos
    if (_mediaItems.length > 10) {
      _error = 'exp_max_files_allowed';
      notifyListeners();
      return false;
    }

    // Validar multimedia solo si NO es post de solo texto
    if (!_isTextOnly && _mediaItems.isEmpty) {
      _error = 'exp_media_required';
      notifyListeners();
      return false;
    }

    // Validar descripción solo para posts de solo texto
    if (_isTextOnly && _description.trim().isEmpty) {
      _error = 'exp_description_required';
      notifyListeners();
      return false;
    }

    try {
      _isUploading = true;
      _uploadProgress = 0.0;
      _error = null;
      notifyListeners();

      // Crear lista de media requests
      final mediaRequests = _mediaItems
          .map(
            (item) => CreateMediaRequest(
              filePath: item.filePath,
              mediaType: item.mediaType,
              duration: item.duration,
              aspectRatio: item.aspectRatio,
              description: item.description,
            ),
          )
          .toList();

      // Crear request de experiencia con el formato explícito
      final request = CreateExperienceRequest(
        description: _description,
        tags: _tags,
        mediaFiles: mediaRequests,
        type: _experienceType ?? ExperienceType.general,
        format: _format,
        rideId: _rideId,
      );

      // Simular progreso
      for (int i = 1; i <= 10; i++) {
        await Future.delayed(const Duration(milliseconds: 200));
        _uploadProgress = i / 10;
        notifyListeners();
      }

      // Crear experiencia usando el ExperienceProvider para actualizar las listas
      if (_experienceProvider != null) {
        await _experienceProvider.createExperience(request);
      } else {
        await _repository.createExperience(request);
      }

      _isUploading = false;
      notifyListeners();

      // Limpiar estado después de crear
      reset();

      return true;
    } catch (e) {
      _error = 'exp_error_creating';
      _isUploading = false;
      notifyListeners();
      return false;
    }
  }

  /// Limpiar error
  void clearError() {
    _error = null;
    notifyListeners();
  }

  /// Cargar media existente de una experiencia (para modo edición)
  void loadExistingMedia(List<ExperienceMediaEntity> existingMedia) {
    _mediaItems = existingMedia
        .map(
          (m) => MediaItem(
            filePath: '', // No hay archivo local
            mediaType: m.mediaType,
            duration: m.duration,
            aspectRatio: m.aspectRatio,
            thumbnailPath: null,
            url: m.url,
            description: m.description,
          ),
        )
        .toList();
    notifyListeners();
  }

  /// Reemplazar un media item en una posición específica (para re-crop en edición)
  void replaceMediaItem(int index, MediaItem newItem) {
    if (index >= 0 && index < _mediaItems.length) {
      _mediaItems[index] = newItem;
      notifyListeners();
    }
  }

  /// Actualizar la descripción de un media item (para stories)
  void updateMediaDescription(int index, String description) {
    if (index >= 0 && index < _mediaItems.length) {
      _mediaItems[index] = _mediaItems[index].copyWith(
        description: description,
      );
      notifyListeners();
    }
  }

  /// Resetear estado
  void reset() {
    _mediaItems = [];
    _description = '';
    _tags = [];
    _experienceType = null;
    _rideId = null;
    _isUploading = false;
    _uploadProgress = 0.0;
    _error = null;
    _isRecording = false;
    _videoController?.dispose();
    _videoController = null;
    _format = ExperienceFormat.post;
    notifyListeners();
  }

  @override
  void dispose() {
    _videoController?.dispose();
    super.dispose();
  }
}
