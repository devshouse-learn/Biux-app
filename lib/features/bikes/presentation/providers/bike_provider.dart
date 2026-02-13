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
      print('🚴 BikeProvider: Cargando bicicletas para userId: "$userId"');
      _setState(BikeProviderState.loading);
      _userBikes = await _getUserBikesUseCase(userId);
      print('🚴 BikeProvider: Se encontraron ${_userBikes.length} bicicletas');
      if (_userBikes.isNotEmpty) {
        print('🚴 Primera bici - ownerId: "${_userBikes.first.ownerId}"');
      }
      _setState(BikeProviderState.loaded);
    } catch (e) {
      print('❌ BikeProvider: Error cargando bicicletas: $e');
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
          return 'Falta ingresar la marca de la bicicleta';
        }
        if (brand.length < 2) {
          return 'La marca debe tener al menos 2 caracteres';
        }
        if (!RegExp(r'^[a-zA-ZáéíóúÁÉÍÓÚñÑ0-9\s\-]+$').hasMatch(brand)) {
          return 'La marca solo puede contener letras, números y guiones';
        }

        // Modelo
        final model = _registrationData['model']?.toString().trim() ?? '';
        if (model.isEmpty) {
          return 'Falta ingresar el modelo de la bicicleta';
        }
        if (model.length < 2) {
          return 'El modelo debe tener al menos 2 caracteres';
        }

        // Año
        final year = _registrationData['year'];
        final currentYear = DateTime.now().year;
        if (year == null || year is! int) {
          return 'Falta seleccionar el año de la bicicleta';
        }
        if (year < 1900 || year > currentYear + 1) {
          return 'El año debe estar entre 1900 y ${currentYear + 1}';
        }

        // Color
        final color = _registrationData['color']?.toString().trim() ?? '';
        if (color.isEmpty) {
          return 'Falta ingresar el color de la bicicleta';
        }
        if (color.length < 3) {
          return 'Ingresa un color válido (ej: Rojo, Azul, Negro)';
        }
        if (!RegExp(r'^[a-zA-ZáéíóúÁÉÍÓÚñÑ\s\/\-]+$').hasMatch(color)) {
          return 'El color solo puede contener letras';
        }

        // Talla
        final size = _registrationData['size']?.toString().trim() ?? '';
        if (size.isEmpty) {
          return 'Falta ingresar la talla de la bicicleta';
        }
        if (!RegExp(
          r'^(XXS|XS|S|M|L|XL|XXL|XXXL|\d{1,2}(\.\d)?|\d{1,2}"?)$',
          caseSensitive: false,
        ).hasMatch(size)) {
          return 'Ingresa una talla válida (ej: S, M, L, XL, 16, 18")';
        }

        // Tipo
        if (_registrationData['type'] == null) {
          return 'Falta seleccionar el tipo de bicicleta';
        }

        // Número de serie
        final frameSerial =
            _registrationData['frameSerial']?.toString().trim() ?? '';
        if (frameSerial.isEmpty) {
          return 'Falta ingresar el número de serie del cuadro';
        }
        if (frameSerial.length < 4) {
          return 'El número de serie debe tener al menos 4 caracteres';
        }
        if (!RegExp(r'^[A-Za-z0-9\-]+$').hasMatch(frameSerial)) {
          return 'El número de serie solo puede contener letras, números y guiones';
        }

        // Ciudad
        final city = _registrationData['city']?.toString().trim() ?? '';
        if (city.isEmpty) {
          return 'Falta ingresar la ciudad';
        }
        if (city.length < 2) {
          return 'Ingresa un nombre de ciudad válido';
        }

        return null; // Todos los campos están completos

      case 1: // Fotos
        if (_registrationData['mainPhoto']?.toString().trim().isEmpty ?? true) {
          return 'Falta agregar la foto principal de la bicicleta';
        }
        return null;

      case 2: // Propiedad/Compra (opcional)
        return null; // Los campos de este paso son opcionales

      case 3: // Revisión y confirmación
        return null;

      default:
        return 'Paso inválido';
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
          throw Exception('Error al subir la foto principal de la bicicleta');
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
