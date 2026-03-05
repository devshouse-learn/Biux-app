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

  const MediaItem({
    required this.filePath,
    required this.mediaType,
    required this.duration,
    this.aspectRatio,
    this.thumbnailPath,
    this.isProcessing = false,
    this.url,
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
  }) {
    return MediaItem(
      filePath: filePath ?? this.filePath,
      mediaType: mediaType ?? this.mediaType,
      duration: duration ?? this.duration,
      aspectRatio: aspectRatio ?? this.aspectRatio,
      thumbnailPath: thumbnailPath ?? this.thumbnailPath,
      isProcessing: isProcessing ?? this.isProcessing,
      url: url ?? this.url,
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
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1080, // ✅ Cambio: 1080px de ancho máximo
        maxHeight: 1350, // ✅ Cambio: 1350px de alto máximo
        imageQuality: 85,
      );

      if (image != null) {
        // Verificar que el archivo existe
        final file = File(image.path);
        if (!file.existsSync()) {
          _error = 'El archivo seleccionado no está disponible';
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
      _error = 'Error seleccionando imagen: $e';
      notifyListeners();
    }
  }

  /// Tomar foto
  Future<void> takePhoto() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1080, // ✅ Cambio: 1080px de ancho máximo
        maxHeight: 1350, // ✅ Cambio: 1350px de alto máximo
        imageQuality: 85,
      );

      if (image != null) {
        // Verificar que el archivo existe
        final file = File(image.path);
        if (!file.existsSync()) {
          _error = 'La foto tomada no está disponible';
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
      _error = 'Error tomando foto: $e';
      notifyListeners();
    }
  }

  /// Agregar imagen que ya ha sido recortada
  void addCroppedImage(File croppedImageFile) {
    try {
      if (!croppedImageFile.existsSync()) {
        _error = 'El archivo recortado no está disponible';
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
      _error = 'Error agregando imagen recortada: $e';
      notifyListeners();
    }
  }

  /// Agregar video desde galería
  Future<void> addVideoFromGallery() async {
    try {
      final XFile? video = await _imagePicker.pickVideo(
        source: ImageSource.gallery,
        maxDuration: const Duration(seconds: 30),
      );

      if (video != null) {
        // Verificar que el archivo existe
        final file = File(video.path);
        if (!file.existsSync()) {
          _error = 'El video seleccionado no está disponible';
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
          _error =
              'El video debe durar máximo 30 segundos. Duración actual: ${duration}s';
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
      _error = 'Error seleccionando video: $e';
      notifyListeners();
    }
  }

  /// Grabar video
  Future<void> recordVideo() async {
    try {
      final XFile? video = await _imagePicker.pickVideo(
        source: ImageSource.camera,
        maxDuration: const Duration(seconds: 30),
      );

      if (video != null) {
        // Verificar que el archivo existe
        final file = File(video.path);
        if (!file.existsSync()) {
          _error = 'El video grabado no está disponible';
          notifyListeners();
          return;
        }

        final controller = VideoPlayerController.file(file);

        await controller.initialize();
        final duration = controller.value.duration.inSeconds;
        controller.dispose();

        // Validar duración máxima de 30 segundos
        if (duration > 30) {
          _error =
              'El video debe durar máximo 30 segundos. Duración actual: ${duration}s';
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
      _error = 'Error grabando video: $e';
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
    // Validar multimedia solo si NO es post de solo texto
    if (!_isTextOnly && _mediaItems.isEmpty) {
      _error = 'Debes agregar al menos una imagen o video';
      notifyListeners();
      return false;
    }

    // Validar descripción solo para posts de solo texto
    if (_isTextOnly && _description.trim().isEmpty) {
      _error = 'La descripción es requerida para este post';
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
      _error = 'Error creando experiencia: $e';
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
          ),
        )
        .toList();
    notifyListeners();
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
