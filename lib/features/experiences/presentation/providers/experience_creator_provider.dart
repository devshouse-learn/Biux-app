import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:video_player/video_player.dart';
import 'package:biux/features/experiences/domain/entities/experience_entity.dart';
import 'package:biux/features/experiences/domain/repositories/experience_repository.dart';
import 'package:biux/features/experiences/presentation/providers/experience_provider.dart';
// import 'package:biux/shared/services/video_experience_service.dart'; // TODO: Implementar

part 'experience_creator_provider.freezed.dart';

/// Estado para la creación de experiencias
@freezed
class ExperienceCreatorState with _$ExperienceCreatorState {
  const factory ExperienceCreatorState({
    @Default([]) List<MediaItem> mediaItems,
    @Default('') String description,
    @Default([]) List<String> tags,
    ExperienceType? experienceType,
    String? rideId,
    @Default(false) bool isUploading,
    @Default(0.0) double uploadProgress,
    String? error,
    @Default(false) bool isRecording,
    VideoPlayerController? videoController,
  }) = _ExperienceCreatorState;
}

/// Item multimedia para la experiencia
@freezed
class MediaItem with _$MediaItem {
  const factory MediaItem({
    required String filePath,
    required MediaType mediaType,
    required int duration,
    double? aspectRatio,
    String? thumbnailPath,
    @Default(false) bool isProcessing,
  }) = _MediaItem;

  const MediaItem._();

  bool get isVideo => mediaType == MediaType.video;
  bool get isImage => mediaType == MediaType.image;
}

/// Provider para la creación de experiencias
final experienceCreatorProvider =
    StateNotifierProvider<ExperienceCreatorNotifier, ExperienceCreatorState>((
      ref,
    ) {
      final repository = ref.read(experienceRepositoryProvider);
      return ExperienceCreatorNotifier(repository);
    });

/// Notifier para la creación de experiencias
class ExperienceCreatorNotifier extends StateNotifier<ExperienceCreatorState> {
  final ExperienceRepository _repository;
  final ImagePicker _imagePicker = ImagePicker();
  // final VideoExperienceService _videoService = VideoExperienceService(); // TODO: Implementar

  ExperienceCreatorNotifier(this._repository)
    : super(const ExperienceCreatorState());

  /// Actualizar descripción
  void updateDescription(String description) {
    state = state.copyWith(description: description);
  }

  /// Actualizar tags
  void updateTags(List<String> tags) {
    state = state.copyWith(tags: tags);
  }

  /// Establecer tipo de experiencia
  void setExperienceType(ExperienceType type, {String? rideId}) {
    state = state.copyWith(experienceType: type, rideId: rideId);
  }

  /// Agregar imagen desde galería
  Future<void> addImageFromGallery() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1920,
        imageQuality: 85,
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
        maxHeight: 1920,
        imageQuality: 85,
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
      //   userId: 'temp_user', // TODO: Obtener del auth
      //   experienceId: 'temp_exp', // TODO: Generar ID temporal
      // );

      // TODO: Implementar lógica de video correcta
      state = state.copyWith(error: 'Funcionalidad de video en desarrollo');
    } catch (e) {
      // Remover item en caso de error
      state = state.copyWith(
        mediaItems:
            state.mediaItems
                .where(
                  (item) => !(item.filePath == videoPath && item.isProcessing),
                )
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
    if (state.mediaItems.isEmpty) {
      state = state.copyWith(
        error: 'Debes agregar al menos una imagen o video',
      );
      return false;
    }

    if (state.description.trim().isEmpty) {
      state = state.copyWith(error: 'Debes agregar una descripción');
      return false;
    }

    if (state.experienceType == null) {
      state = state.copyWith(error: 'Debes seleccionar un tipo de experiencia');
      return false;
    }

    state = state.copyWith(isUploading: true, error: null, uploadProgress: 0.0);

    try {
      // Convertir media items a CreateMediaRequest
      final mediaRequests =
          state.mediaItems
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

      // Crear experiencia
      await _repository.createExperience(request);

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
