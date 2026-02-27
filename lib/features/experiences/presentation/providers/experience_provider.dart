import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:biux/features/experiences/domain/entities/experience_entity.dart';
import 'package:biux/features/experiences/domain/repositories/experience_repository.dart';
import 'package:biux/features/experiences/data/repositories/experience_repository_impl.dart';

/// Provider del repository
final experienceRepositoryProvider = Provider<ExperienceRepository>((ref) {
  return ExperienceRepositoryImpl();
});

/// Estado para las experiencias
class ExperienceState {
  final List<ExperienceEntity> experiences;
  final List<ExperienceEntity> userExperiences;
  final List<ExperienceEntity> rideExperiences;
  final bool isLoading;
  final String? error;

  const ExperienceState({
    this.experiences = const [],
    this.userExperiences = const [],
    this.rideExperiences = const [],
    this.isLoading = false,
    this.error,
  });

  /// Crear copia con campos modificados
  ExperienceState copyWith({
    List<ExperienceEntity>? experiences,
    List<ExperienceEntity>? userExperiences,
    List<ExperienceEntity>? rideExperiences,
    bool? isLoading,
    String? error,
  }) {
    return ExperienceState(
      experiences: experiences ?? this.experiences,
      userExperiences: userExperiences ?? this.userExperiences,
      rideExperiences: rideExperiences ?? this.rideExperiences,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ExperienceState &&
        other.experiences.toString() == experiences.toString() &&
        other.userExperiences.toString() == userExperiences.toString() &&
        other.rideExperiences.toString() == rideExperiences.toString() &&
        other.isLoading == isLoading &&
        other.error == error;
  }

  @override
  int get hashCode {
    return experiences.hashCode ^
        userExperiences.hashCode ^
        rideExperiences.hashCode ^
        isLoading.hashCode ^
        error.hashCode;
  }

  @override
  String toString() {
    return 'ExperienceState(experiences: $experiences, userExperiences: $userExperiences, rideExperiences: $rideExperiences, isLoading: $isLoading, error: $error)';
  }
}

/// Provider para gestionar las experiencias
final experienceProvider =
    StateNotifierProvider<ExperienceNotifier, ExperienceState>((ref) {
      final repository = ref.read(experienceRepositoryProvider);
      return ExperienceNotifier(repository);
    });

/// Notifier para las experiencias
class ExperienceNotifier extends StateNotifier<ExperienceState> {
  final ExperienceRepository _repository;

  ExperienceNotifier(this._repository) : super(const ExperienceState());

  /// Cargar experiencias del usuario actual
  Future<void> loadUserExperiences(String userId) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final experiences = await _repository.getUserExperiences(userId);
      state = state.copyWith(userExperiences: experiences, isLoading: false);
    } catch (e) {
      state = state.copyWith(error: e.toString(), isLoading: false);
    }
  }

  /// Cargar experiencias de una rodada
  Future<void> loadRideExperiences(String rideId) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final experiences = await _repository.getRideExperiences(rideId);
      state = state.copyWith(rideExperiences: experiences, isLoading: false);
    } catch (e) {
      state = state.copyWith(error: e.toString(), isLoading: false);
    }
  }

  /// Cargar experiencias de usuarios seguidos
  Future<void> loadFollowingExperiences(String userId) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final experiences = await _repository.getFollowingExperiences(userId);
      state = state.copyWith(experiences: experiences, isLoading: false);
    } catch (e) {
      state = state.copyWith(error: e.toString(), isLoading: false);
    }
  }

  /// Crear una nueva experiencia
  Future<void> createExperience(CreateExperienceRequest request) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final newExperience = await _repository.createExperience(request);

      // Agregar la nueva experiencia a la lista correspondiente
      if (request.type == ExperienceType.ride && request.rideId != null) {
        state = state.copyWith(
          rideExperiences: [newExperience, ...state.rideExperiences],
          isLoading: false,
        );
      } else {
        state = state.copyWith(
          userExperiences: [newExperience, ...state.userExperiences],
          experiences: [newExperience, ...state.experiences],
          isLoading: false,
        );
      }
    } catch (e) {
      state = state.copyWith(error: e.toString(), isLoading: false);
    }
  }

  /// Eliminar una experiencia
  Future<void> deleteExperience(String experienceId) async {
    try {
      await _repository.deleteExperience(experienceId);

      // Remover de todas las listas
      state = state.copyWith(
        experiences: state.experiences
            .where((e) => e.id != experienceId)
            .toList(),
        userExperiences: state.userExperiences
            .where((e) => e.id != experienceId)
            .toList(),
        rideExperiences: state.rideExperiences
            .where((e) => e.id != experienceId)
            .toList(),
      );
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  /// Agregar reacción
  Future<void> addReaction(String experienceId, ReactionType reaction) async {
    try {
      await _repository.addReaction(experienceId, reaction);
      // PENDIENTE: Actualizar la experiencia en el estado local
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  /// Remover reacción
  Future<void> removeReaction(String experienceId) async {
    try {
      await _repository.removeReaction(experienceId);
      // PENDIENTE: Actualizar la experiencia en el estado local
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  /// Marcar como vista
  Future<void> markAsViewed(String experienceId) async {
    try {
      await _repository.markAsViewed(experienceId);
      // PENDIENTE: Actualizar las vistas en el estado local
    } catch (e) {
      // Error silencioso para marcar vistas
      print('Error marcando como vista: $e');
    }
  }

  /// Limpiar errores
  void clearError() {
    state = state.copyWith(error: null);
  }
}
