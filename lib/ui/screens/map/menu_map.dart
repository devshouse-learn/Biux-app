import 'dart:async';
import 'package:biux/config/colors.dart';
import 'package:biux/config/images.dart';
import 'package:biux/config/styles.dart';
import 'package:biux/config/strings.dart';
import 'package:biux/data/models/sites.dart';
import 'package:biux/data/models/types_sites.dart';
import 'package:biux/data/repositories/sites/sites_repository.dart';
import 'package:biux/ui/screens/temp/detail_business.dart';
import 'package:biux/ui/widgets/button_center_widget.dart';
import 'package:biux/ui/widgets/map_helper_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';

class MenuMap extends StatefulWidget {
  final latitude;
  final longitude;

  MenuMap(this.latitude, this.longitude);

  @override
  _MenuMapState createState() => _MenuMapState(latitude, longitude);
}

class _MenuMapState extends State<MenuMap> {
  final latitude;
  final longitude;
  _MenuMapState(this.latitude, this.longitude);
  // final CameraPosition _kGooglePlex = CameraPosition(
  //   target: LatLng(4.433771, -75.204678),
  //   zoom: 14.4746,
  // );
  String gifm = Images.kGifMaps;

  Completer<GoogleMapController> _controller = Completer();
  final Map<String, Marker> _markers = {};
  Map<MarkerId, Marker> markers = <MarkerId, Marker>{};
  late Marker marker;
  late Position position;
  late BitmapDescriptor iconTest;
  Map<PolylineId, Polyline> polylines = {};
  List<LatLng> polylineCoordinates = [];
  PolylinePoints polylinePoints = PolylinePoints();
  late LatLng currentLocatioN;
  var serviceEnabled;
  late List<Sites> listSites = [];
  late List<Sites> listBusiness = [];
  final Location location = Location();
  var icon24;
  late TypesSites typesSites;
  final markerS = <Marker>{};
  CameraPosition? _kGooglePlex;

  void initState() {
    super.initState();
    setState(() {
      // adding a new marker to map
      markerS.forEach((marker) => markers[marker.markerId] = marker);
    });
    listSites = [];
    listBusiness = [];
    typesSites = TypesSites();
    _loadMarkers();
    setState(() {});
    Future.delayed(Duration.zero, loadPosition);
    setState(() {});
    Future.delayed(Duration.zero, _loadMarkers);
    setState(() {});
    markerS.forEach((marker) => markers[marker.markerId] = marker);
  }

  cargarTiposSitios() async {}

  void _loadMarkers() async {
    //_marcadores =
    typesSites = await SitesRepository().getTypesSites();
    listSites = await SitesRepository().getSites();
    listBusiness = await SitesRepository().getSitesFilter();
    final total = listSites.length;
    // final Response response = await get(negocio.icono);
    //  _marcadores.clear();
    for (var i = 0; i < total; i++) {
      var business = listSites[i];
      var markerIdVal = business.typesSites?.type ?? "";
      final BitmapDescriptor markerImage =
          await MapHelper.getMarkerImageFromUrl(
        business.icon!,
        targetWidth: 100,
      );
      markerS.add(
        Marker(
          markerId: MarkerId('m${business.id}'),
          position: LatLng(business.latitude!, business.longitude!),
          infoWindow: InfoWindow(
            title: markerIdVal,
            snippet: business.name,
          ),
          onTap: () => goDetail(business),
          icon: markerImage,
        ),
      );
    }
    setState(() {});
  }

  loadPosition() async {
    var lat;
    var long;
    serviceEnabled = await location.requestService();
    setState(() {});
    // serviceEnabled = await location.serviceEnabled();

    if (!serviceEnabled) {
      Scaffold.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AppStrings.activateLocation,
          ),
        ),
      );
      return;
    }

    if (serviceEnabled) {
      final result = await location.getLocation();
      currentLocatioN = LatLng(result.latitude!, result.longitude!);
      location.onLocationChanged.listen((LocationData currentLocation) {
        if (lat != currentLocation.latitude &&
            long != currentLocation.longitude) {
          lat = currentLocation.latitude;
          long = currentLocation.longitude;
          currentLocatioN =
              LatLng(currentLocation.latitude!, currentLocation.longitude!);
          // controller.animateCamera(CameraUpdate.newCameraPosition(
          _kGooglePlex = CameraPosition(
            target:
                LatLng(currentLocation.latitude!, currentLocation.longitude!),
            zoom: 16.0,
          );
          CameraPosition(
            target:
                LatLng(currentLocation.latitude!, currentLocation.longitude!),
            zoom: 16.0,
          );
          setState(() {
            marker = Marker(
              markerId: MarkerId(AppStrings.markerId),
              position:
                  LatLng(currentLocation.latitude!, currentLocation.longitude!),
              icon: icon24,
            );
            markers[marker.markerId] = marker;

            if (latitude != '' && longitude != '') {
              _getPolyline(
                currentLocatioN,
                LatLng(
                  latitude,
                  longitude,
                ),
              );
            }
          });
          setState(
            () {},
          );
        }
      });
      setState(
        () {},
      );
    }
  }

  static final CameraPosition _iniPosicion = CameraPosition(
    target: LatLng(4.436199, -75.202804),
    zoom: 18,
  );

  static final CameraPosition _iniPosicion2 = CameraPosition(
    target: LatLng(4.20475, -74.64075),
    zoom: 18,
  );

  @override
  Widget build(BuildContext context) {
    return  Scaffold(
      body: Stack(
        children: <Widget>[
          serviceEnabled
              ? GoogleMap(
                  zoomControlsEnabled: false,
                  myLocationEnabled: true,
                  myLocationButtonEnabled: true,
                  mapType: MapType.normal,
                  initialCameraPosition: _kGooglePlex!,
                  onMapCreated: (GoogleMapController controller) {
                    _controller.complete(controller);
                    _loadMarkers();
                  },
                  markers: markerS,
                  polylines: Set<Polyline>.of(polylines.values),
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        FlatButton(
                          color: AppColors.strongCyan,
                          shape: RoundedRectangleBorder(
                            borderRadius: new BorderRadius.circular(10.0),
                            side: BorderSide(
                              width: 3,
                              color: AppColors.strongCyan,
                            ),
                          ),
                          child: new Text(
                            AppStrings.activateLocation2,
                            style: Styles.accentTextThemeWhite,
                          ),
                          onPressed: () async {
                            loadPosition();
                            setState(() {});
                          },
                        ),
                      ],
                    ),
                  ],
                )
        ],
      ),
    );
  }

  _addPolyLine() {
    PolylineId id = PolylineId(AppStrings.polyline);
    Polyline polylinePoints = Polyline(
      polylineId: id,
      color: AppColors.blue,
      points: polylineCoordinates,
      width: 3,
    );
    polylines[id] = polylinePoints;
    setState(() {});
  }

  _getPolyline(LatLng origen, LatLng destino) async {
    //dibuja la ruta
    polylineCoordinates = [];
    PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
      AppStrings.googleAPiKey,
      PointLatLng(
        origen.latitude,
        origen.longitude,
      ),
      PointLatLng(
        destino.latitude,
        destino.longitude,
      ),
    );
    if (result.points.isNotEmpty) {
      result.points.forEach(
        (PointLatLng point) {
          polylineCoordinates.add(
            LatLng(
              point.latitude,
              point.longitude,
            ),
          );
        },
      );
    }
    _addPolyLine();
  }

  List<Widget> _listSearch(List<Sites> sites, BuildContext ctx) {
    final _listBusiness = <Widget>[];
    for (Sites sites in sites) {
      final viewMoreOnCLick = () => goDetail(sites);
      _listBusiness.add(
        Container(
          margin: EdgeInsets.only(bottom: 20),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.all(
              Radius.circular(20.0),
            ), // set rounded corner radius
          ),
          child: ButtonCenter(
            sites,
            viewMoreOnCLick,
          ),
        ),
      );
    }
    return _listBusiness;
  }

  void goDetail(Sites sites) async {
    var result = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (BuildContext context) => DetailBusiness(sites),
        ));
    if (result ?? false) {
      if (currentLocatioN == null) {
        await loadPosition();
      }

      _getPolyline(currentLocatioN, LatLng(sites.latitude!, sites.longitude!));
    }
  }
}
