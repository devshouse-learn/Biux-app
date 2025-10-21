import 'package:flutter/material.dart';
import 'package:biux/features/bikes/domain/entities/bike_entity.dart';
import 'package:biux/features/bikes/domain/entities/bike_enums.dart';
import 'package:biux/features/bikes/domain/usecases/register_bike_usecase.dart';
import 'package:biux/features/bikes/domain/usecases/get_user_bikes_usecase.dart';
import 'package:biux/features/bikes/domain/usecases/report_bike_theft_usecase.dart';
import 'package:biux/features/bikes/domain/usecases/transfer_bike_ownership_usecase.dart';
import 'package:biux/features/bikes/domain/usecases/get_public_bike_info_usecase.dart';

/// Estados del provider de bicicletas
enum BikeProviderState { initial, loading, loaded, error }

/// Provider para la gestión de bicicletas
class BikeProvider extends ChangeNotifier {
  final RegisterBikeUseCase _registerBikeUseCase;
  final GetUserBikesUseCase _getUserBikesUseCase;
  final ReportBikeTheftUseCase _reportBikeTheftUseCase;
  final TransferBikeOwnershipUseCase _transferBikeOwnershipUseCase;
  final GetPublicBikeInfoUseCase _getPublicBikeInfoUseCase;

  BikeProvider({
    required RegisterBikeUseCase registerBikeUseCase,
    required GetUserBikesUseCase getUserBikesUseCase,
    required ReportBikeTheftUseCase reportBikeTheftUseCase,
    required TransferBikeOwnershipUseCase transferBikeOwnershipUseCase,
    required GetPublicBikeInfoUseCase getPublicBikeInfoUseCase,
  }) : _registerBikeUseCase = registerBikeUseCase,
       _getUserBikesUseCase = getUserBikesUseCase,
       _reportBikeTheftUseCase = reportBikeTheftUseCase,
       _transferBikeOwnershipUseCase = transferBikeOwnershipUseCase,
       _getPublicBikeInfoUseCase = getPublicBikeInfoUseCase;

  // ========== Estado general ==========
  BikeProviderState _state = BikeProviderState.initial;
  String? _errorMessage;
  List<BikeEntity> _userBikes = [];
  BikeEntity? _currentBike;
  BikeEntity? _publicBike; // Para ficha pública

  // Getters
  BikeProviderState get state => _state;
  String? get errorMessage => _errorMessage;
  List<BikeEntity> get userBikes => _userBikes;
  BikeEntity? get currentBike => _currentBike;
  BikeEntity? get publicBike => _publicBike;
  bool get isLoading => _state == BikeProviderState.loading;
  bool get hasError => _state == BikeProviderState.error;

  // ========== Estado del formulario de registro ==========
  int _currentStep = 0;
  final Map<String, dynamic> _registrationData = {};

  int get currentStep => _currentStep;
  Map<String, dynamic> get registrationData => Map.from(_registrationData);

  // ========== Manejo de estado ==========
  void _setState(BikeProviderState newState, {String? error}) {
    _state = newState;
    _errorMessage = error;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    if (_state == BikeProviderState.error) {
      _state = BikeProviderState.loaded;
    }
    notifyListeners();
  }

  // ========== Gestión de bicicletas ==========

  /// Obtiene todas las bicicletas del usuario
  Future<void> loadUserBikes(String userId) async {
    try {
      _setState(BikeProviderState.loading);
      _userBikes = await _getUserBikesUseCase(userId);
      _setState(BikeProviderState.loaded);
    } catch (e) {
      _setState(BikeProviderState.error, error: e.toString());
    }
  }

  /// Obtiene ficha pública de bicicleta por QR
  Future<void> loadPublicBike(String qrCode) async {
    try {
      _setState(BikeProviderState.loading);
      _publicBike = await _getPublicBikeInfoUseCase(qrCode);
      _setState(BikeProviderState.loaded);
    } catch (e) {
      _setState(BikeProviderState.error, error: e.toString());
    }
  }

  /// Selecciona una bicicleta como actual
  void selectBike(BikeEntity bike) {
    _currentBike = bike;
    notifyListeners();
  }

  // ========== Formulario de registro (4 pasos) ==========

  /// Avanza al siguiente paso del formulario
  void nextStep() {
    if (_currentStep < 3) {
      _currentStep++;
      notifyListeners();
    }
  }

  /// Retrocede al paso anterior del formulario
  void previousStep() {
    if (_currentStep > 0) {
      _currentStep--;
      notifyListeners();
    }
  }

  /// Actualiza datos del formulario
  void updateRegistrationData(String key, dynamic value) {
    _registrationData[key] = value;
    notifyListeners();
  }

  /// Reinicia el formulario de registro
  void resetRegistrationForm() {
    _currentStep = 0;
    _registrationData.clear();
    notifyListeners();
  }

  /// Valida el paso actual del formulario
  bool validateCurrentStep() {
    switch (_currentStep) {
      case 0: // Datos básicos
        return _registrationData['brand']?.toString().trim().isNotEmpty ==
                true &&
            _registrationData['model']?.toString().trim().isNotEmpty == true &&
            _registrationData['year'] != null &&
            _registrationData['color']?.toString().trim().isNotEmpty == true &&
            _registrationData['size']?.toString().trim().isNotEmpty == true &&
            _registrationData['type'] != null &&
            _registrationData['frameSerial']?.toString().trim().isNotEmpty ==
                true &&
            _registrationData['city']?.toString().trim().isNotEmpty == true;
      case 1: // Fotos
        return _registrationData['mainPhoto']?.toString().trim().isNotEmpty ==
            true;
      case 2: // Propiedad/Compra (opcional)
        return true; // Los campos de este paso son opcionales
      case 3: // Revisión y confirmación
        return true;
      default:
        return false;
    }
  }

  /// Registra la bicicleta con los datos del formulario
  Future<BikeEntity?> registerBike(String ownerId) async {
    try {
      _setState(BikeProviderState.loading);

      final bike = await _registerBikeUseCase(
        ownerId: ownerId,
        brand: _registrationData['brand'],
        model: _registrationData['model'],
        year: _registrationData['year'],
        color: _registrationData['color'],
        size: _registrationData['size'],
        type: _registrationData['type'],
        frameSerial: _registrationData['frameSerial'],
        mainPhoto: _registrationData['mainPhoto'],
        city: _registrationData['city'],
        serialPhoto: _registrationData['serialPhoto'],
        neighborhood: _registrationData['neighborhood'],
        additionalPhotos: _registrationData['additionalPhotos'],
        invoice: _registrationData['invoice'],
        purchaseDate: _registrationData['purchaseDate'],
        purchasePlace: _registrationData['purchasePlace'],
        featuredComponents: _registrationData['featuredComponents'],
      );

      // Añadir a la lista de bicicletas del usuario
      _userBikes.add(bike);
      _currentBike = bike;

      // Reiniciar formulario
      resetRegistrationForm();

      _setState(BikeProviderState.loaded);
      return bike;
    } catch (e) {
      _setState(BikeProviderState.error, error: e.toString());
      return null;
    }
  }

  // ========== Gestión de robos ==========

  /// Reporta el robo de una bicicleta
  Future<bool> reportTheft({
    required String bikeId,
    required String reporterId,
    required DateTime theftDate,
    required String location,
    required String description,
    String? policeReportNumber,
  }) async {
    try {
      _setState(BikeProviderState.loading);

      final updatedBike = await _reportBikeTheftUseCase(
        bikeId: bikeId,
        reporterId: reporterId,
        theftDate: theftDate,
        location: location,
        description: description,
        policeReportNumber: policeReportNumber,
      );

      // Actualizar en la lista de bicicletas
      final index = _userBikes.indexWhere((bike) => bike.id == bikeId);
      if (index != -1) {
        _userBikes[index] = updatedBike;
      }

      // Actualizar bicicleta actual si corresponde
      if (_currentBike?.id == bikeId) {
        _currentBike = updatedBike;
      }

      _setState(BikeProviderState.loaded);
      return true;
    } catch (e) {
      _setState(BikeProviderState.error, error: e.toString());
      return false;
    }
  }

  // ========== Gestión de transferencias ==========

  /// Solicita transferencia de propiedad
  Future<bool> requestTransfer({
    required String bikeId,
    required String fromUserId,
    required String toUserId,
    String? toUserEmail,
    String? message,
  }) async {
    try {
      _setState(BikeProviderState.loading);

      await _transferBikeOwnershipUseCase(
        bikeId: bikeId,
        fromUserId: fromUserId,
        toUserId: toUserId,
        toUserEmail: toUserEmail,
        message: message,
      );

      _setState(BikeProviderState.loaded);
      return true;
    } catch (e) {
      _setState(BikeProviderState.error, error: e.toString());
      return false;
    }
  }

  /// Obtiene información pública de una bicicleta por código QR
  Future<void> getBikeByQRCode(String qrCode) async {
    try {
      _setState(BikeProviderState.loading);

      final bike = await _getPublicBikeInfoUseCase(qrCode);
      _publicBike = bike;

      _setState(BikeProviderState.loaded);
    } catch (e) {
      _setState(BikeProviderState.error, error: e.toString());
      rethrow;
    }
  }

  /// Limpia la selección actual
  void clearSelection() {
    _currentBike = null;
    _publicBike = null;
    notifyListeners();
  }

  // ========== Utilidades ==========

  /// Obtiene estadísticas rápidas de las bicicletas del usuario
  Map<String, int> getUserBikeStats() {
    if (_userBikes.isEmpty) {
      return {'total': 0, 'active': 0, 'stolen': 0, 'verified': 0};
    }

    return {
      'total': _userBikes.length,
      'active': _userBikes.where((b) => b.status == BikeStatus.active).length,
      'stolen': _userBikes.where((b) => b.status == BikeStatus.stolen).length,
      'verified': _userBikes
          .where((b) => b.status == BikeStatus.verified)
          .length,
    };
  }

  /// Filtra bicicletas por estado
  List<BikeEntity> filterBikesByStatus(BikeStatus status) {
    return _userBikes.where((bike) => bike.status == status).toList();
  }

  /// Busca bicicletas por texto
  List<BikeEntity> searchBikes(String query) {
    if (query.trim().isEmpty) return _userBikes;

    final lowercaseQuery = query.toLowerCase();
    return _userBikes.where((bike) {
      return bike.brand.toLowerCase().contains(lowercaseQuery) ||
          bike.model.toLowerCase().contains(lowercaseQuery) ||
          bike.color.toLowerCase().contains(lowercaseQuery) ||
          bike.frameSerial.toLowerCase().contains(lowercaseQuery);
    }).toList();
  }
}
