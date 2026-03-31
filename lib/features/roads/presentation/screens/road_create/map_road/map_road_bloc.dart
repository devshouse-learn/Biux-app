import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';

class MapRoadBloc extends ChangeNotifier {
  Location location = Location();
  final Completer<GoogleMapController> controller = Completer();
  LocationData locationData = LocationData.fromMap({
    'latitude': 4.4410096,
    'longitude': -75.2135319,
  });
  CameraPosition locationPosition = CameraPosition(
    target: LatLng(4.4410096, -75.2135319),
    zoom: 14.4746,
  );

  MapRoadBloc() {
    currentLocation();
  }

  Future<void> currentLocation() async {
    locationData = await Location().getLocation();
    locationPosition = CameraPosition(
      target: LatLng(locationData.latitude!, locationData.longitude!),
      zoom: 14.4746,
    );
    changeCameraPosition(locationPosition);
    notifyListeners();
  }

  Future<void> changeLocation(LatLng latLng) async {
    locationData = LocationData.fromMap({
      'latitude': latLng.latitude,
      'longitude': latLng.longitude,
    });
    locationPosition = CameraPosition(
      target: LatLng(latLng.latitude, latLng.longitude),
      zoom: 14.4746,
    );
    changeCameraPosition(locationPosition);
    notifyListeners();
  }

  Future<void> changeCameraPosition(CameraPosition cameraPosition) async {
    final GoogleMapController controllerMap = await controller.future;
    controllerMap.animateCamera(CameraUpdate.newCameraPosition(cameraPosition));
  }
}
