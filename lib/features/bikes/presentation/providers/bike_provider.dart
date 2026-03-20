import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:biux/features/bikes/domain/entities/bike_entity.dart';
import 'package:biux/features/bikes/domain/entities/bike_enums.dart';
import 'package:biux/features/bikes/domain/usecases/register_bike_usecase.dart';
import 'package:biux/features/bikes/domain/usecases/get_user_bikes_usecase.dart';
import 'package:biux/features/bikes/domain/usecases/report_bike_theft_usecase.dart';
import 'package:biux/features/bikes/domain/usecases/transfer_bike_ownership_usecase.dart';
import 'package:biux/features/bikes/domain/usecases/get_public_bike_info_usecase.dart';
import 'package:biux/features/bikes/domain/usecases/delete_bike_usecase.dart';
import 'package:biux/features/bikes/domain/usecases/mark_as_recovered_usecase.dart';
import 'package:biux/features/bikes/data/repositories/bike_repository_impl.dart';
import 'package:biux/shared/services/optimized_storage_service.dart';

/// Estados del provider de bicicletas
enum BikeProviderState { initial, loading, loaded, error }

/// Provider para la gestión de bicicletas
class BikeProvider extends ChangeNotifier {
  final RegisterBikeUseCase _registerBikeUseCase;
  final GetUserBikesUseCase _getUserBikesUseCase;
  final ReportBikeTheftUseCase _reportBikeTheftUseCase;
  final TransferBikeOwnershipUseCase _transferBikeOwnershipUseCase;
  final GetPublicBikeInfoUseCase _getPublicBikeInfoUseCase;
  final DeleteBikeUseCase _deleteBikeUseCase;
  final MarkAsRecoveredUseCase _markAsRecoveredUseCase;

  BikeProvider({
    required RegisterBikeUseCase registerBikeUseCase,
    required GetUserBikesUseCase getUserBikesUseCase,
    required ReportBikeTheftUseCase reportBikeTheftUseCase,
    required TransferBikeOwnershipUseCase transferBikeOwnershipUseCase,
    required GetPublicBikeInfoUseCase getPublicBikeInfoUseCase,
    required DeleteBikeUseCase deleteBikeUseCase,
    required MarkAsRecoveredUseCase markAsRecoveredUseCase,
  }) : _registerBikeUseCase = registerBikeUseCase,
       _getUserBikesUseCase = getUserBikesUseCase,
       _reportBikeTheftUseCase = reportBikeTheftUseCase,
       _transferBikeOwnershipUseCase = transferBikeOwnershipUseCase,
       _getPublicBikeInfoUseCase = getPublicBikeInfoUseCase,
       _deleteBikeUseCase = deleteBikeUseCase,
       _markAsRecoveredUseCase = markAsRecoveredUseCase;

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
    // Diferir la notificación para evitar llamadas durante el build
    scheduleMicrotask(() {
      notifyListeners();
    });
  }

  void clearError() {
    _errorMessage = null;
    if (_state == BikeProviderState.error) {
      _state = BikeProviderState.loaded;
    }
    scheduleMicrotask(() {
      notifyListeners();
    });
  }

  // ========== Gestión de bicicletas ==========

  /// Obtiene todas las bicicletas del usuario
  Future<void> loadUserBikes(String userId) async {
    try {
      debugPrint('🚴 BikeProvider: Cargando bicicletas para userId: "$userId"');
      _setState(BikeProviderState.loading);
      _userBikes = await _getUserBikesUseCase(userId);
      debugPrint(
        '🚴 BikeProvider: Se encontraron ${_userBikes.length} bicicletas',
      );
      if (_userBikes.isNotEmpty) {
        debugPrint('🚴 Primera bici - ownerId: "${_userBikes.first.ownerId}"');
      }
      _setState(BikeProviderState.loaded);
    } catch (e) {
      debugPrint('❌ BikeProvider: Error cargando bicicletas: $e');
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
    // Diferir la notificación para evitar llamadas durante el build
    scheduleMicrotask(() {
      notifyListeners();
    });
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

  /// Valida el paso actual del formulario y devuelve el mensaje de error si falla
  String? validateCurrentStepWithMessage() {
    switch (_currentStep) {
      case 0: // Datos básicos
        // Marca
        final brand = _registrationData['brand']?.toString().trim() ?? '';
        if (brand.isEmpty) {
          return 'bike_brand_required';
        }
        if (brand.length < 2) {
          return 'bike_brand_min_chars';
        }
        if (!RegExp(r'^[a-zA-ZáéíóúÁÉÍÓÚñÑ0-9\s\-]+$').hasMatch(brand)) {
          return 'bike_brand_invalid_chars';
        }

        // Modelo
        final model = _registrationData['model']?.toString().trim() ?? '';
        if (model.isEmpty) {
          return 'bike_model_required';
        }
        if (model.length < 2) {
          return 'bike_model_min_chars';
        }

        // Año
        final year = _registrationData['year'];
        final currentYear = DateTime.now().year;
        if (year == null || year is! int) {
          return 'bike_year_required';
        }
        if (year < 1900 || year > currentYear + 1) {
          return 'bike_year_range';
        }

        // Color
        final color = _registrationData['color']?.toString().trim() ?? '';
        if (color.isEmpty) {
          return 'bike_color_required';
        }
        if (color.length < 3) {
          return 'bike_color_hint';
        }
        if (!RegExp(r'^[a-zA-ZáéíóúÁÉÍÓÚñÑ\s\/\-]+$').hasMatch(color)) {
          return 'bike_color_invalid';
        }

        // Talla
        final size = _registrationData['size']?.toString().trim() ?? '';
        if (size.isEmpty) {
          return 'bike_size_required';
        }
        if (!RegExp(
          r'^(XXS|XS|S|M|L|XL|XXL|XXXL|\d{1,2}(\.\d)?|\d{1,2}"?)$',
          caseSensitive: false,
        ).hasMatch(size)) {
          return 'bike_size_hint';
        }

        // Tipo
        if (_registrationData['type'] == null) {
          return 'bike_type_required';
        }

        // Número de serie
        final frameSerial =
            _registrationData['frameSerial']?.toString().trim() ?? '';
        if (frameSerial.isEmpty) {
          return 'bike_serial_required';
        }
        if (frameSerial.length < 4) {
          return 'bike_serial_min_chars';
        }
        if (!RegExp(r'^[A-Za-z0-9\-]+$').hasMatch(frameSerial)) {
          return 'bike_serial_invalid_chars';
        }

        // Ciudad
        final city = _registrationData['city']?.toString().trim() ?? '';
        if (city.isEmpty) {
          return 'bike_city_required';
        }
        if (city.length < 2) {
          return 'bike_city_hint';
        }

        return null; // Todos los campos están completos

      case 1: // Fotos
        if (_registrationData['mainPhoto']?.toString().trim().isEmpty ?? true) {
          return 'bike_photo_required';
        }
        return null;

      case 2: // Propiedad/Compra (opcional)
        return null; // Los campos de este paso son opcionales

      case 3: // Revisión y confirmación
        return null;

      default:
        return 'bike_invalid_step';
    }
  }

  /// Valida el paso actual del formulario (versión booleana)
  bool validateCurrentStep() {
    return validateCurrentStepWithMessage() == null;
  }

  /// Registra la bicicleta con los datos del formulario
  Future<BikeEntity?> registerBike(String ownerId) async {
    try {
      _setState(BikeProviderState.loading);

      // Generar un ID temporal para la bici (necesario para las rutas de Storage)
      final tempBikeId = 'bike_${DateTime.now().millisecondsSinceEpoch}';

      // Subir foto principal (obligatoria)
      String? mainPhotoUrl;
      final mainPhotoPath = _registrationData['mainPhoto']?.toString();
      if (mainPhotoPath != null && mainPhotoPath.isNotEmpty) {
        mainPhotoUrl = await OptimizedStorageService.uploadBikeImage(
          userId: ownerId,
          bikeId: tempBikeId,
          imageFile: File(mainPhotoPath),
          imageType: 'main',
        );

        if (mainPhotoUrl == null) {
          throw Exception('bike_upload_main_photo_error');
        }
      }

      // Subir foto del número de serie (opcional)
      String? serialPhotoUrl;
      final serialPhotoPath = _registrationData['serialPhoto']?.toString();
      if (serialPhotoPath != null && serialPhotoPath.isNotEmpty) {
        serialPhotoUrl = await OptimizedStorageService.uploadBikeImage(
          userId: ownerId,
          bikeId: tempBikeId,
          imageFile: File(serialPhotoPath),
          imageType: 'serial',
        );
      }

      // Subir fotos adicionales (opcional)
      List<String>? additionalPhotoUrls;
      final additionalPhotos =
          _registrationData['additionalPhotos'] as List<String>?;
      if (additionalPhotos != null && additionalPhotos.isNotEmpty) {
        additionalPhotoUrls = [];
        for (int i = 0; i < additionalPhotos.length; i++) {
          final photoPath = additionalPhotos[i];
          if (photoPath.isNotEmpty) {
            final photoUrl = await OptimizedStorageService.uploadBikeImage(
              userId: ownerId,
              bikeId: tempBikeId,
              imageFile: File(photoPath),
              imageType: 'additional',
            );
            if (photoUrl != null) {
              additionalPhotoUrls.add(photoUrl);
            }
          }
        }
      }

      // Subir factura (opcional)
      String? invoiceUrl;
      final invoicePath = _registrationData['invoice']?.toString();
      if (invoicePath != null && invoicePath.isNotEmpty) {
        invoiceUrl = await OptimizedStorageService.uploadBikeImage(
          userId: ownerId,
          bikeId: tempBikeId,
          imageFile: File(invoicePath),
          imageType: 'invoice',
        );
      }

      // Ahora registrar la bici con las URLs de las fotos
      final bike = await _registerBikeUseCase(
        ownerId: ownerId,
        brand: _registrationData['brand'],
        model: _registrationData['model'],
        year: _registrationData['year'],
        color: _registrationData['color'],
        size: _registrationData['size'],
        type: _registrationData['type'],
        frameSerial: _registrationData['frameSerial'],
        mainPhoto: mainPhotoUrl!, // Ya está subida
        city: _registrationData['city'],
        serialPhoto: serialPhotoUrl, // URL o null
        neighborhood: _registrationData['neighborhood'],
        additionalPhotos: additionalPhotoUrls, // URLs o null
        invoice: invoiceUrl, // URL o null
        purchaseDate: _registrationData['purchaseDate'],
        purchasePlace: _registrationData['purchasePlace'],
        featuredComponents: _registrationData['featuredComponents'],
      );

      // Añadir a la lista de bicicletas del usuario
      _userBikes.add(bike);
      _currentBike = bike;

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

  /// Marca una bicicleta robada como recuperada
  Future<bool> markAsRecovered({
    required String bikeId,
    required String userId,
  }) async {
    try {
      _setState(BikeProviderState.loading);

      final updatedBike = await _markAsRecoveredUseCase(
        bikeId: bikeId,
        userId: userId,
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

  // ========== Eliminación de bicicletas ==========

  /// Elimina una bicicleta del usuario
  Future<bool> deleteBike(String bikeId) async {
    try {
      _setState(BikeProviderState.loading);

      await _deleteBikeUseCase(bikeId);

      // Remover de la lista local
      _userBikes.removeWhere((bike) => bike.id == bikeId);

      // Si la bicicleta eliminada era la actual, limpiar la selección
      if (_currentBike?.id == bikeId) {
        _currentBike = null;
      }

      _setState(BikeProviderState.loaded);
      return true;
    } catch (e) {
      debugPrint('❌ BikeProvider: Error eliminando bicicleta: $e');
      _setState(BikeProviderState.error, error: e.toString());
      return false;
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

  /// MÉTODO TEMPORAL: Corrige bicicletas con ownerId placeholder
  Future<int> fixPlaceholderBikes(String correctUserId) async {
    try {
      _setState(BikeProviderState.loading);

      // Acceder directamente al repositorio
      final repository = _getUserBikesUseCase.repository as BikeRepositoryImpl;
      final updatedCount = await repository.fixPlaceholderOwnerIds(
        correctUserId,
      );

      // Recargar las bicicletas después de la corrección
      await loadUserBikes(correctUserId);

      _setState(BikeProviderState.loaded);
      return updatedCount;
    } catch (e) {
      _setState(BikeProviderState.error, error: e.toString());
      return 0;
    }
  }
}
