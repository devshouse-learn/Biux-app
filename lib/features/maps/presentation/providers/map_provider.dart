import 'dart:ui' as ui;

import 'package:biux/core/config/images.dart';
import 'package:biux/features/maps/data/models/meeting_point.dart';
import 'package:biux/features/maps/presentation/providers/location_provider.dart';
import 'package:biux/features/roads/data/models/route.dart';
import 'package:biux/shared/services/directions_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';


class MapState {
  final Set<Marker> markers;
  final Set<Polyline> polylines;
  final List<MeetingPoint> meetingPoints;
  final MeetingPoint? selectedPoint;
  final BiuxRoute? selectedRoute;
  final bool isLoading;
  final LatLng defaultLocation;
  final LatLng? userLocation;

  MapState({
    required this.markers,
    this.polylines = const {},
    required this.meetingPoints,
    this.selectedPoint,
    this.selectedRoute,
    this.isLoading = false,
    // Coordenadas de Ibagué por defecto
    this.defaultLocation = const LatLng(4.4389, -75.2322),
    this.userLocation,
  });

  MapState copyWith({
    Set<Marker>? markers,
    Set<Polyline>? polylines,
    List<MeetingPoint>? meetingPoints,
    MeetingPoint? selectedPoint,
    BiuxRoute? selectedRoute,
    bool clearSelectedPoint = false,
    bool clearSelectedRoute = false,
    bool? isLoading,
    LatLng? defaultLocation,
    LatLng? userLocation,
    bool clearUserLocation = false,
  }) {
    return MapState(
      markers: markers ?? this.markers,
      polylines: polylines ?? this.polylines,
      meetingPoints: meetingPoints ?? this.meetingPoints,
      selectedPoint:
          clearSelectedPoint ? null : (selectedPoint ?? this.selectedPoint),
      selectedRoute:
          clearSelectedRoute ? null : (selectedRoute ?? this.selectedRoute),
      isLoading: isLoading ?? this.isLoading,
      defaultLocation: defaultLocation ?? this.defaultLocation,
      userLocation:
          clearUserLocation ? null : (userLocation ?? this.userLocation),
    );
  }
}

class MapProvider extends ChangeNotifier {
  GoogleMapController? _mapController;
  MapState _state = MapState(
    markers: {},
    meetingPoints: [],
    isLoading: false,
  );
  BitmapDescriptor? _meetingPointIcon;
  LocationProvider? _locationProvider;
  bool _locationRequested = false;

  MapState get state => _state;
  Set<Marker> get markers => _state.markers;
  Set<Polyline> get polylines => _state.polylines;
  MeetingPoint? get selectedPoint => _state.selectedPoint;
  BiuxRoute? get selectedRoute => _state.selectedRoute;
  bool get isLoading => _state.isLoading;
  LatLng? get userLocation => _state.userLocation;

  void setLocationProvider(LocationProvider locationProvider) {
    _locationProvider = locationProvider;
  }

  Future<void> _loadMeetingPointIcon() async {
    if (_meetingPointIcon != null) return;

    final int targetSize = 110; // Tamaño total del ícono
    final double padding = 15.0; // Padding para el círculo blanco

    // Cargar la imagen original
    final ByteData data = await rootBundle.load(Images.kMeetingPoint);
    final ui.Codec codec = await ui.instantiateImageCodec(
      data.buffer.asUint8List(),
      targetWidth: targetSize - (padding * 2).toInt(),
      targetHeight: targetSize - (padding * 2).toInt(),
    );
    final ui.FrameInfo fi = await codec.getNextFrame();

    // Crear un canvas con fondo circular blanco
    final pictureRecorder = ui.PictureRecorder();
    final canvas = Canvas(pictureRecorder);

    // Dibujar círculo blanco
    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    canvas.drawCircle(
      Offset(targetSize / 2, targetSize / 2),
      targetSize / 2,
      paint,
    );

    // Agregar sombra
    final shadowPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.3)
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, 3);
    canvas.drawCircle(
      Offset(targetSize / 2, targetSize / 2),
      targetSize / 2,
      shadowPaint,
    );

    // Dibujar la imagen en el centro
    canvas.drawImage(
      fi.image,
      Offset(padding, padding),
      Paint(),
    );

    // Convertir a imagen
    final picture = pictureRecorder.endRecording();
    final img = await picture.toImage(targetSize, targetSize);
    final ByteData? byteData =
        await img.toByteData(format: ui.ImageByteFormat.png);

    if (byteData != null) {
      _meetingPointIcon =
          BitmapDescriptor.fromBytes(byteData.buffer.asUint8List());
      notifyListeners();
    }
  }

  void onMapCreated(GoogleMapController controller) async {
    _mapController = controller;
    await _loadMeetingPointIcon();

    // Intentar obtener ubicación del usuario si ya tiene permisos
    if (_locationProvider != null && !_locationRequested) {
      _locationRequested = true;
      await _tryGetUserLocation();
    }

    // Centrar en la ubicación del usuario si está disponible, sino en Ibagué
    LatLng initialLocation = _state.userLocation ?? _state.defaultLocation;
    _mapController?.animateCamera(
      CameraUpdate.newLatLngZoom(initialLocation, 13),
    );

    notifyListeners();
  }

  /// Solicita permisos de ubicación cuando el usuario explícitamente lo requiere
  Future<void> requestUserLocation() async {
    if (_locationProvider == null) return;

    _state = _state.copyWith(isLoading: true);
    notifyListeners();

    Position? position = await _locationProvider!.getCurrentLocation();

    if (position != null) {
      LatLng userLatLng = LatLng(position.latitude, position.longitude);
      _state = _state.copyWith(
        userLocation: userLatLng,
        isLoading: false,
      );

      // Centrar mapa en la ubicación del usuario
      _mapController?.animateCamera(
        CameraUpdate.newLatLngZoom(userLatLng, 15),
      );
    } else {
      _state = _state.copyWith(isLoading: false);
    }

    notifyListeners();
  }

  /// Intenta obtener ubicación sin solicitar permisos si no los tiene
  Future<void> _tryGetUserLocation() async {
    if (_locationProvider == null) return;

    Position? position = await _locationProvider!.getLocationForMap();

    if (position != null) {
      _state = _state.copyWith(
        userLocation: LatLng(position.latitude, position.longitude),
      );
      notifyListeners();
    }
  }

  void updateMeetingPoints(List<MeetingPoint> points) async {
    await _loadMeetingPointIcon();
    _state = _state.copyWith(
      meetingPoints: points,
      markers: _createMarkers(points),
    );
    notifyListeners();
  }

  void selectMeetingPoint(MeetingPoint? point) {
    if (point == null) {
      _state = _state.copyWith(clearSelectedPoint: true);
    } else {
      _state = _state.copyWith(selectedPoint: point);
      if (_mapController != null) {
        _mapController!.animateCamera(
          CameraUpdate.newLatLng(
            LatLng(point.latitude, point.longitude),
          ),
        );
      }
    }
    notifyListeners();
  }

  void selectRoute(BiuxRoute? route) async {
    if (route == null) {
      _state = _state.copyWith(
        clearSelectedRoute: true,
        polylines: {},
      );
      notifyListeners();
      return;
    }

    // Mostrar loading mientras obtenemos la ruta
    _state = _state.copyWith(isLoading: true);
    notifyListeners();

    try {
      final origin = LatLng(
          _state.selectedPoint!.latitude, _state.selectedPoint!.longitude);
      final destination =
          LatLng(route.destinationLatitude, route.destinationLongitude);

      print(
          '🗺️ Obteniendo ruta de ciclismo desde ${origin} hasta ${destination}');

      // Obtener la ruta real usando Google Directions API para ciclismo
      final directionResult = await DirectionsService.getDirectionsWithDetails(
        origin: origin,
        destination: destination,
        travelMode: 'bicycling',
      );

      if (directionResult != null && directionResult.points.isNotEmpty) {
        print(
            '✅ Ruta obtenida exitosamente con ${directionResult.points.length} puntos');

        final polylines = {
          Polyline(
            polylineId: PolylineId(route.id),
            points: directionResult.points,
            color: Colors.green, // Verde para rutas de ciclismo
            width: 6,
            patterns: [], // Línea sólida
          ),
        };

        _state = _state.copyWith(
          selectedRoute: route,
          polylines: polylines,
          isLoading: false,
        );

        // Centrar el mapa en la ruta
        if (_mapController != null) {
          _fitRouteInViewFromPoints(directionResult.points);
        }
      } else {
        print('⚠️ No se pudo obtener la ruta desde la API, usando línea recta');

        // Si falla la API, crear una línea recta punteada
        final simplePolylines = {
          Polyline(
            polylineId: PolylineId(route.id),
            points: [origin, destination],
            color: Colors.orange, // Naranja para indicar que es una estimación
            width: 4,
            patterns: [
              PatternItem.dash(20),
              PatternItem.gap(10)
            ], // Línea punteada
          ),
        };

        _state = _state.copyWith(
          selectedRoute: route,
          polylines: simplePolylines,
          isLoading: false,
        );

        if (_mapController != null) {
          _fitRouteInViewFromPoints([origin, destination]);
        }
      }
    } catch (e) {
      print('💥 Error seleccionando ruta: $e');
      _state = _state.copyWith(isLoading: false);
    }

    notifyListeners();
  }

  void _fitRouteInViewFromPoints(List<LatLng> points) {
    if (_mapController == null || points.isEmpty) return;

    if (points.length == 1) {
      _mapController!.animateCamera(
        CameraUpdate.newLatLng(points.first),
      );
      return;
    }

    double minLat =
        points.map((p) => p.latitude).reduce((a, b) => a < b ? a : b);
    double maxLat =
        points.map((p) => p.latitude).reduce((a, b) => a > b ? a : b);
    double minLng =
        points.map((p) => p.longitude).reduce((a, b) => a < b ? a : b);
    double maxLng =
        points.map((p) => p.longitude).reduce((a, b) => a > b ? a : b);

    _mapController!.animateCamera(
      CameraUpdate.newLatLngBounds(
        LatLngBounds(
          southwest: LatLng(minLat, minLng),
          northeast: LatLng(maxLat, maxLng),
        ),
        100.0, // padding
      ),
    );
  }

  Set<Marker> _createMarkers(List<MeetingPoint> points) {
    return points.map((point) {
      return Marker(
        markerId: MarkerId(point.id),
        position: LatLng(point.latitude, point.longitude),
        icon: _meetingPointIcon ?? BitmapDescriptor.defaultMarker,
        infoWindow: InfoWindow(
          title: point.name,
          snippet: point.description,
        ),
        onTap: () => selectMeetingPoint(point),
      );
    }).toSet();
  }

  // Set<Polyline> _createPolylines(List<BiuxRoute> routes) {
  //   return routes.map((route) {
  //     return Polyline(
  //       polylineId: PolylineId(route.id),
  //       points: route.points
  //           .map((point) => LatLng(point.latitude, point.longitude))
  //           .toList(),
  //       color: Colors.blue,
  //       width: 5,
  //     );
  //   }).toSet();
  // }
  //
  // Set<Polyline> _createRoutePolyline(BiuxRoute route) {
  //   if (_state.selectedPoint == null) return {};
  //
  //   // Crear lista de puntos: punto de encuentro + puntos intermedios (si los hay) + destino
  //   List<LatLng> routePoints = [
  //     LatLng(_state.selectedPoint!.latitude,
  //         _state.selectedPoint!.longitude), // Punto de inicio
  //   ];
  //
  //   // Agregar puntos intermedios si existen
  //   if (route.points.isNotEmpty) {
  //     routePoints.addAll(
  //         route.points.map((point) => LatLng(point.latitude, point.longitude)));
  //   }
  //
  //   // Agregar destino final
  //   routePoints
  //       .add(LatLng(route.destinationLatitude, route.destinationLongitude));
  //
  //   return {
  //     Polyline(
  //       polylineId: PolylineId(route.id),
  //       points: routePoints,
  //       color: Colors.blue,
  //       width: 5,
  //       patterns: [],
  //     ),
  //   };
  // }
  //
  // void _fitRouteInView(BiuxRoute route) {
  //   if (_mapController == null || _state.selectedPoint == null) return;
  //
  //   // Calcular bounds para incluir punto de encuentro, ruta y destino
  //   List<LatLng> allPoints = [
  //     LatLng(_state.selectedPoint!.latitude, _state.selectedPoint!.longitude),
  //     ...route.points.map((point) => LatLng(point.latitude, point.longitude)),
  //     LatLng(route.destinationLatitude, route.destinationLongitude),
  //   ];
  //
  //   if (allPoints.length < 2) return;
  //
  //   double minLat =
  //       allPoints.map((p) => p.latitude).reduce((a, b) => a < b ? a : b);
  //   double maxLat =
  //       allPoints.map((p) => p.latitude).reduce((a, b) => a > b ? a : b);
  //   double minLng =
  //       allPoints.map((p) => p.longitude).reduce((a, b) => a < b ? a : b);
  //   double maxLng =
  //       allPoints.map((p) => p.longitude).reduce((a, b) => a > b ? a : b);
  //
  //   _mapController!.animateCamera(
  //     CameraUpdate.newLatLngBounds(
  //       LatLngBounds(
  //         southwest: LatLng(minLat, minLng),
  //         northeast: LatLng(maxLat, maxLng),
  //       ),
  //       100.0, // padding
  //     ),
  //   );
  // }

  void setLoading(bool loading) {
    _state = _state.copyWith(isLoading: loading);
    notifyListeners();
  }

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }
}


