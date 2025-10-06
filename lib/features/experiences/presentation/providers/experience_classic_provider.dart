import 'package:flutter/foundation.dart';
import 'package:biux/features/experiences/domain/entities/experience_entity.dart';
import 'package:biux/features/experiences/domain/repositories/experience_repository.dart';
import 'package:biux/features/experiences/data/repositories/experience_repository_impl.dart';

/// Provider de experiencias usando ChangeNotifier para compatibilidad con Provider clásico
class ExperienceProvider extends ChangeNotifier {
  final ExperienceRepository _repository;

  ExperienceProvider({ExperienceRepository? repository})
    : _repository = repository ?? ExperienceRepositoryImpl();

  // Estado
  List<ExperienceEntity> _experiences = [];
  List<ExperienceEntity> _userExperiences = [];
  List<ExperienceEntity> _rideExperiences = [];
  bool _isLoading = false;
  String? _error;

  // Getters
  List<ExperienceEntity> get experiences => _experiences;
  List<ExperienceEntity> get userExperiences => _userExperiences;
  List<ExperienceEntity> get rideExperiences => _rideExperiences;
  bool get isLoading => _isLoading;
  String? get error => _error;

  /// Carga experiencias de un usuario específico
  Future<void> loadUserExperiences(String userId) async {
    try {
      _setLoading(true);
      _error = null;

      final experiences = await _repository.getUserExperiences(userId);
      _setUserExperiences(experiences);
    } catch (e) {
      _setError('Error cargando experiencias: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }

  /// Carga experiencias de una rodada específica
  Future<void> loadRideExperiences(String rideId) async {
    try {
      _setLoading(true);
      _error = null;

      final experiences = await _repository.getRideExperiences(rideId);
      _setRideExperiences(experiences);
    } catch (e) {
      _setError('Error cargando experiencias de rodada: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }

  /// Carga experiencias de usuarios seguidos
  Future<void> loadFollowingExperiences(String userId) async {
    try {
      _setLoading(true);
      _error = null;

      final experiences = await _repository.getFollowingExperiences(userId);
      _setExperiences(experiences);
    } catch (e) {
      _setError('Error cargando experiencias: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }

  /// Crea una nueva experiencia
  Future<bool> createExperience(CreateExperienceRequest request) async {
    try {
      _setLoading(true);
      _error = null;

      final newExperience = await _repository.createExperience(request);

      // Recargar experiencias después de crear una nueva
      _refreshAfterCreate(newExperience);
      return true;
    } catch (e) {
      _setError('Error creando experiencia: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Elimina una experiencia
  Future<bool> deleteExperience(String experienceId) async {
    try {
      _setLoading(true);
      _error = null;

      await _repository.deleteExperience(experienceId);

      // Remover de las listas locales
      _removeExperienceFromLists(experienceId);
      return true;
    } catch (e) {
      _setError('Error eliminando experiencia: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Agrega una reacción a una experiencia
  Future<bool> addReaction(String experienceId, ReactionType reaction) async {
    try {
      await _repository.addReaction(experienceId, reaction);
      return true;
    } catch (e) {
      _setError('Error agregando reacción: ${e.toString()}');
      return false;
    }
  }

  /// Elimina una reacción de una experiencia
  Future<bool> removeReaction(String experienceId) async {
    try {
      await _repository.removeReaction(experienceId);
      return true;
    } catch (e) {
      _setError('Error eliminando reacción: ${e.toString()}');
      return false;
    }
  }

  /// Marca una experiencia como vista
  Future<void> markAsViewed(String experienceId) async {
    try {
      await _repository.markAsViewed(experienceId);
    } catch (e) {
      // Error silencioso para las visualizaciones
      debugPrint('Error marcando como vista: ${e.toString()}');
    }
  }

  /// Limpia el error
  void clearError() {
    _error = null;
    notifyListeners();
  }

  /// Reinicia el estado
  void reset() {
    _experiences = [];
    _userExperiences = [];
    _rideExperiences = [];
    _isLoading = false;
    _error = null;
    notifyListeners();
  }

  // Métodos privados
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _error = error;
    notifyListeners();
  }

  void _setExperiences(List<ExperienceEntity> experiences) {
    _experiences = experiences;
    notifyListeners();
  }

  void _setUserExperiences(List<ExperienceEntity> experiences) {
    _userExperiences = experiences;
    notifyListeners();
  }

  void _setRideExperiences(List<ExperienceEntity> experiences) {
    _rideExperiences = experiences;
    notifyListeners();
  }

  void _refreshAfterCreate(ExperienceEntity newExperience) {
    // Agregar a la lista general
    _experiences = [newExperience, ..._experiences];

    // Agregar a experiencias de usuario si corresponde
    _userExperiences = [newExperience, ..._userExperiences];

    // Agregar a experiencias de rodada si corresponde
    if (newExperience.rideId != null) {
      _rideExperiences = [newExperience, ..._rideExperiences];
    }

    notifyListeners();
  }

  void _removeExperienceFromLists(String experienceId) {
    _experiences.removeWhere((exp) => exp.id == experienceId);
    _userExperiences.removeWhere((exp) => exp.id == experienceId);
    _rideExperiences.removeWhere((exp) => exp.id == experienceId);
    notifyListeners();
  }
}
