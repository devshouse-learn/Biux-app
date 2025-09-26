import 'dart:async';

import 'package:biux/config/colors.dart';
import 'package:biux/config/strings.dart';
import 'package:biux/data/models/city.dart';
import 'package:biux/data/models/sites.dart';
import 'package:biux/data/models/user.dart';
import 'package:biux/data/repositories/authentication_repository.dart';
import 'package:biux/data/repositories/cities/cities_firebase_repository.dart';
import 'package:biux/data/repositories/sites/sites_firebase_repository.dart';
import 'package:biux/data/repositories/users/user_firebase_repository.dart';
import 'package:biux/ui/widgets/map_helper_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:permission_handler/permission_handler.dart';

class MapScreenBloc extends ChangeNotifier {
  Completer<GoogleMapController> controller = Completer();
  final cityController = TextEditingController();
  final Location location = Location();
  List<Widget> imageSliders = [];
  List<Sites> sites = [];
  List<City> listCities = [];
  List<Marker> markerSites = [];
  Map<PolylineId, Polyline> polylines = {};
  PolylinePoints polylinePoints =
      PolylinePoints(apiKey: AppStrings.googleAPiKey);
  final FocusNode focusNodeCity = FocusNode();
  bool serviceEnabled = false;
  CameraPosition currentLocation = CameraPosition(
    target: LatLng(
      4.4410096,
      -75.2135319,
    ),
    zoom: 14.4746,
  );
  var result;
  String validate = '';
  String cityId = '';
  City cityUser = City();
  BiuxUser user = BiuxUser();

  MapScreenBloc() {
    loadData();
  }

  Future<void> loadData() async {
    Future.delayed(Duration.zero, () async {
      await getUser();
      await hasPermision();
      await getLocation();
      await getCities();
      await getSites();
    });
  }

  Future<void> getUser() async {
    String? userId = AuthenticationRepository().getUserId;
    user = await UserFirebaseRepository().getUserId(
      userId,
    );
    cityUser = await CitiesFirebaseRepository().getCityId(
      user.cityId.name,
    );
    notifyListeners();
  }

  Future<void> getSites() async {
    final dataSites = await SitesFirebaseRepository().getSites();
    for (final site in dataSites) {
      final BitmapDescriptor markerImage =
          await MapHelper.getMarkerImageFromUrl(
        site.icon,
        targetWidth: 100,
      );
      site.iconBytes = markerImage;
      sites.add(
        site,
      );
      notifyListeners();
    }
  }

  Future<void> hasPermision() async {
    final service = await location.hasPermission();
    if (service.name == AppStrings.grantedText) serviceEnabled = true;
  }

  Future<void> onTapService() async {
    final permissionStatus = await location.requestPermission();
    if (permissionStatus.name != AppStrings.grantedText) {
      serviceEnabled = false;
      validate = permissionStatus.name;
    } else {
      serviceEnabled = true;
      getLocation();
      notifyListeners();
    }
  }

  Future<void> onTapPermissions() async {
    openAppSettings();
    notifyListeners();
  }

  Future<void> getLocation() async {
    result = await location.getLocation();
    currentLocation = CameraPosition(
      target: LatLng(
        result.latitude!,
        result.longitude!,
      ),
      zoom: 16.0,
    );
    changeCameraPosition(currentLocation);
    notifyListeners();
  }

  Future<void> changeCameraPosition(CameraPosition cameraPosition) async {
    final GoogleMapController controllerMap = await controller.future;
    controllerMap.animateCamera(
      CameraUpdate.newCameraPosition(cameraPosition),
    );
  }

  Future<void> getRoute(LatLng origen, LatLng destino) async {
    List<LatLng> polylineCoordinates = [];
    PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
        request: PolylineRequest(
            origin: PointLatLng(
              origen.latitude,
              origen.longitude,
            ),
            destination: PointLatLng(
              destino.latitude,
              destino.longitude,
            ),
            mode: TravelMode.bicycling));

    if (result.points.isNotEmpty) {
      result.points.forEach(
        (
          PointLatLng point,
        ) {
          polylineCoordinates.add(
            LatLng(
              point.latitude,
              point.longitude,
            ),
          );
        },
      );
    }
    markRoute(
      polylineCoordinates,
    );
    notifyListeners();
  }

  Future<void> markRoute(List<LatLng> polylineCoordinates) async {
    PolylineId id = PolylineId(AppStrings.polyline);
    Polyline polylinePoints = Polyline(
      polylineId: id,
      color: AppColors.blue,
      points: polylineCoordinates,
      width: 3,
    );
    polylines[id] = polylinePoints;
    notifyListeners();
  }

  Future<void> getCities() async {
    final dataCities = await CitiesFirebaseRepository().getCities();
    listCities = dataCities;
    cityController.text = cityUser.name;
    notifyListeners();
  }

  Future<void> filterCities() async {
    final dataFilterCities = await CitiesFirebaseRepository().getCities();
    listCities = dataFilterCities
        .where(
          (city) => city.name.toLowerCase().contains(
                cityController.text.toLowerCase(),
              ),
        )
        .toList();
    notifyListeners();
  }

  Future<void> onTapCities(
      String nameCity, double latitude, double longitude) async {
    cityController.text = nameCity;
    currentLocation = CameraPosition(
      target: LatLng(
        latitude,
        longitude,
      ),
      zoom: 16.0,
    );
    focusNodeCity.unfocus();
    notifyListeners();
  }

  Future<void> setState() async {
    cityController.clear();
    notifyListeners();
  }

  Future<void> onTapMyLocation() async {
    cityController.text = cityUser.name;
    currentLocation = CameraPosition(
      target: LatLng(
        result.latitude!,
        result.longitude!,
      ),
      zoom: 16.0,
    );
    focusNodeCity.unfocus();
    notifyListeners();
  }
}
