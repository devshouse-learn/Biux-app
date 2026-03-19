import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:video_player/video_player.dart';
import 'package:biux/features/experiences/domain/entities/experience_entity.dart';
import 'package:biux/features/experiences/domain/repositories/experience_repository.dart';
import 'package:biux/features/experiences/presentation/providers/experience_provider.dart';
// import 'package:biux/shared/services/video_experience_service.dart'; // IMPLEMENTADO (STUB): Implementar

/// Estado para la creación de experiencias
class ExperienceCreatorState {
  final List<MediaItem> mediaItems;
  final String description;
  final List<String> tags;
  final ExperienceType? experienceType;
  final String? rideId;
  final bool isUploading;
  final double uploadProgress;
  final String? error;
  final bool isRecording;
  final VideoPlayerController? videoController;
  final bool isTextOnly; // Post de solo texto (sin multimedia)

  const ExperienceCreatorState({
    this.mediaItems = const [],
    this.description = '',
    this.tags = const [],
    this.experienceType,
    this.rideId,
    this.isUploading = false,
    this.uploadProgress = 0.0,
    this.error,
    this.isRecording = false,
    this.videoController,
    this.isTextOnly = false,
  });

  /// Crear copia con campos modificados
  ExperienceCreatorState copyWith({
    List<MediaItem>? mediaItems,
    String? description,
    List<String>? tags,
    ExperienceType? experienceType,
    String? rideId,
    bool? isUploading,
    double? uploadProgress,
    String? error,
    bool? isRecording,
    VideoPlayerController? videoController,
    bool? isTextOnly,
  }) {
    return ExperienceCreatorState(
      mediaItems: mediaItems ?? this.mediaItems,
      description: description ?? this.description,
      tags: tags ?? this.tags,
      experienceType: experienceType ?? this.experienceType,
      rideId: rideId ?? this.rideId,
      isUploading: isUploading ?? this.isUploading,
      uploadProgress: uploadProgress ?? this.uploadProgress,
      error: error ?? this.error,
      isRecording: isRecording ?? this.isRecording,
      videoController: videoController ?? this.videoController,
      isTextOnly: isTextOnly ?? this.isTextOnly,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ExperienceCreatorState &&
        other.mediaItems.toString() == mediaItems.toString() &&
        other.description == description &&
        other.tags.toString() == tags.toString() &&
        other.experienceType == experienceType &&
        other.rideId == rideId &&
        other.isUploading == isUploading &&
        other.uploadProgress == uploadProgress &&
        other.error == error &&
        other.isRecording == isRecording &&
        other.videoController == videoController;
  }

  @override
  int get hashCode {
    return mediaItems.hashCode ^
        description.hashCode ^
        tags.hashCode ^
        experienceType.hashCode ^
        rideId.hashCode ^
        isUploading.hashCode ^
        uploadProgress.hashCode ^
        error.hashCode ^
        isRecording.hashCode ^
        videoController.hashCode;
  }

  @override
  String toString() {
    return 'ExperienceCreatorState(mediaItems: $mediaItems, description: $description, tags: $tags, experienceType: $experienceType, rideId: $rideId, isUploading: $isUploading, uploadProgress: $uploadProgress, error: $error, isRecording: $isRecording, videoController: $videoController)';
  }
}

/// Item multimedia para la experiencia
class MediaItem {
  final String filePath;
  final MediaType mediaType;
  final int duration;
  final double? aspectRatio;
  final String? thumbnailPath;
  final bool isProcessing;

  const MediaItem({
    required this.filePath,
    required this.mediaType,
    required this.duration,
    this.aspectRatio,
    this.thumbnailPath,
    this.isProcessing = false,
  });

  /// Crear copia con campos modificados
  MediaItem copyWith({
    String? filePath,
    MediaType? mediaType,
    int? duration,
    double? aspectRatio,
    String? thumbnailPath,
    bool? isProcessing,
  }) {
    return MediaItem(
      filePath: filePath ?? this.filePath,
      mediaType: mediaType ?? this.mediaType,
      duration: duration ?? this.duration,
      aspectRatio: aspectRatio ?? this.aspectRatio,
      thumbnailPath: thumbnailPath ?? this.thumbnailPath,
      isProcessing: isProcessing ?? this.isProcessing,
    );
  }

  bool get isVideo => mediaType == MediaType.video;
  bool get isImage => mediaType == MediaType.image;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is MediaItem &&
        other.filePath == filePath &&
        other.mediaType == mediaType &&
        other.duration == duration &&
        other.aspectRatio == aspectRatio &&
        other.thumbnailPath == thumbnailPath &&
        other.isProcessing == isProcessing;
  }

  @override
  int get hashCode {
    return filePath.hashCode ^
        mediaType.hashCode ^
        duration.hashCode ^
        aspectRatio.hashCode ^
        thumbnailPath.hashCode ^
        isProcessing.hashCode;
  }

  @override
  String toString() {
    return 'MediaItem(filePath: $filePath, mediaType: $mediaType, duration: $duration, aspectRatio: $aspectRatio, thumbnailPath: $thumbnailPath, isProcessing: $isProcessing)';
  }
}

/// Provider para la creación de experiencias
final experienceCreatorProvider =
    StateNotifierProvider<ExperienceCreatorNotifier, ExperienceCreatorState>((
      ref,
    ) {
      final repository = ref.read(experienceRepositoryProvider);
      final experienceNotifier = ref.read(experienceProvider.notifier);
      return ExperienceCreatorNotifier(repository, experienceNotifier);
    });

/// Notifier para la creación de experiencias
class ExperienceCreatorNotifier extends StateNotifier<ExperienceCreatorState> {
  // final ExperienceRepository _repository; // PENDIENTE: Usar si se necesita acceso directo al repository
  final ExperienceNotifier _experienceNotifier;
  final ImagePicker _imagePicker = ImagePicker();
  // final VideoExperienceService _videoService = VideoExperienceService(); // PENDIENTE: Implementar

  ExperienceCreatorNotifier(
    ExperienceRepository repository,
    this._experienceNotifier,
  ) : super(const ExperienceCreatorState());

  /// Actualizar descripción
  void updateDescription(String description) {
    state = state.copyWith(description: description);
  }

  /// Actualizar tags
  void updateTags(List<String> tags) {
    state = state.copyWith(tags: tags);
  }

  /// Establecer tipo de experiencia
  void setExperienceType(
    ExperienceType type, {
    String? rideId,
    bool isTextOnly = false,
  }) {
    state = state.copyWith(
      experienceType: type,
      rideId: rideId,
      isTextOnly: isTextOnly,
    );
  }

  /// Agregar imagen desde galería
  Future<void> addImageFromGallery() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 2400,
        imageQuality: 95,
      );

      if (image != null) {
        final mediaItem = MediaItem(
          filePath: image.path,
          mediaType: MediaType.image,
          duration: 15, // 15 segundos por defecto para imágenes
        );

        state = state.copyWith(mediaItems: [...state.mediaItems, mediaItem]);
      }
    } catch (e) {
      state = state.copyWith(error: 'Error seleccionando imagen: $e');
    }
  }

  /// Tomar foto con cámara
  Future<void> takePhoto() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1920,
        maxHeight: 2400,
        imageQuality: 95,
      );

      if (image != null) {
        final mediaItem = MediaItem(
          filePath: image.path,
          mediaType: MediaType.image,
          duration: 15,
        );

        state = state.copyWith(mediaItems: [...state.mediaItems, mediaItem]);
      }
    } catch (e) {
      state = state.copyWith(error: 'Error tomando foto: $e');
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
        await _processVideo(video.path);
      }
    } catch (e) {
      state = state.copyWith(error: 'Error seleccionando video: $e');
    }
  }

  /// Grabar video con cámara
  Future<void> recordVideo() async {
    try {
      final XFile? video = await _imagePicker.pickVideo(
        source: ImageSource.camera,
        maxDuration: const Duration(seconds: 30),
      );

      if (video != null) {
        await _processVideo(video.path);
      }
    } catch (e) {
      state = state.copyWith(error: 'Error grabando video: $e');
    }
  }

  /// Procesar video (validar duración, comprimir, generar thumbnail)
  Future<void> _processVideo(String videoPath) async {
    try {
      // Marcar como procesando
      final processingItem = MediaItem(
        filePath: videoPath,
        mediaType: MediaType.video,
        duration: 0,
        isProcessing: true,
      );

      state = state.copyWith(mediaItems: [...state.mediaItems, processingItem]);

      // Validar y subir video
      // final uploadResult = await _videoService.uploadVideo(
      //   videoFile: XFile(videoPath),
      //   userId: 'temp_user', // PENDIENTE: Obtener del auth
      //   experienceId: 'temp_exp', // PENDIENTE: Generar ID temporal
      // );

      // PENDIENTE: Implementar lógica de video correcta
      // Por ahora, procesamos el video de forma básica
      final basicVideoItem = MediaItem(
        filePath: videoPath,
        mediaType: MediaType.video,
        duration: 30, // Duración por defecto
        isProcessing: false,
      );

      // Reemplazar el item procesando con el item final
      final updatedItems = state.mediaItems
          .where((item) => !(item.filePath == videoPath && item.isProcessing))
          .toList();
      updatedItems.add(basicVideoItem);

      state = state.copyWith(mediaItems: updatedItems);
    } catch (e) {
      // Remover item en caso de error
      state = state.copyWith(
        mediaItems: state.mediaItems
            .where((item) => !(item.filePath == videoPath && item.isProcessing))
            .toList(),
        error: 'Error procesando video: $e',
      );
    }
  }

  /// Eliminar media item
  void removeMediaItem(int index) {
    final updatedItems = List<MediaItem>.from(state.mediaItems);
    updatedItems.removeAt(index);
    state = state.copyWith(mediaItems: updatedItems);
  }

  /// Reordenar media items
  void reorderMediaItems(int oldIndex, int newIndex) {
    final updatedItems = List<MediaItem>.from(state.mediaItems);
    final item = updatedItems.removeAt(oldIndex);
    updatedItems.insert(newIndex, item);
    state = state.copyWith(mediaItems: updatedItems);
  }

  /// Crear experiencia
  Future<bool> createExperience() async {
    // Solo validar multimedia si NO es post de solo texto
    if (!state.isTextOnly && state.mediaItems.isEmpty) {
      state = state.copyWith(
        error:
            'error_add_media_required', // Translation key – UI should call l.t(error) to display
      );
      return false;
    }

    if (state.description.trim().isEmpty) {
      state = state.copyWith(
        error: 'error_description_required',
      ); // Translation key – UI should call l.t(error) to display
      return false;
    }

    if (state.experienceType == null) {
      state = state.copyWith(
        error: 'error_select_experience_type',
      ); // Translation key – UI should call l.t(error) to display
      return false;
    }

    state = state.copyWith(isUploading: true, error: null, uploadProgress: 0.0);

    try {
      // Convertir media items a CreateMediaRequest
      final mediaRequests = state.mediaItems
          .map(
            (item) => CreateMediaRequest(
              filePath: item.filePath,
              mediaType: item.mediaType,
              duration: item.duration,
              aspectRatio: item.aspectRatio,
            ),
          )
          .toList();

      // Crear request
      final request = CreateExperienceRequest(
        description: state.description.trim(),
        tags: state.tags,
        mediaFiles: mediaRequests,
        type: state.experienceType!,
        rideId: state.rideId,
      );

      // Crear experiencia usando el ExperienceNotifier para actualizar las listas
      await _experienceNotifier.createExperience(request);

      // Limpiar estado después de éxito
      state = const ExperienceCreatorState();
      return true;
    } catch (e) {
      state = state.copyWith(
        isUploading: false,
        error: 'Error creando experiencia: $e',
      );
      return false;
    }
  }

  /// Limpiar error
  void clearError() {
    state = state.copyWith(error: null);
  }

  /// Reiniciar formulario
  void reset() {
    // Limpiar controlador de video si existe
    state.videoController?.dispose();
    state = const ExperienceCreatorState();
  }

  @override
  void dispose() {
    state.videoController?.dispose();
    super.dispose();
  }
}
