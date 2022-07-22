import 'package:biux/config/colors.dart';
import 'package:biux/config/styles.dart';
import 'package:biux/config/strings.dart';
import 'package:biux/data/models/sites.dart';
import 'package:biux/ui/screens/temp/detail_business.dart';
import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';

class ButtonCenter extends StatefulWidget {
  final Sites _sites;
  // Function alTerminar;
  final Function viewMoreOnClick;

  ButtonCenter(
    this._sites,
    this.viewMoreOnClick,
  );

  @override
  _ButtonCenterState createState() => _ButtonCenterState();
}

class _ButtonCenterState extends State<ButtonCenter> {
  // ThemeData theme = darkTheme;
  List<LatLng> polylineCoordinates = [];
  PolylinePoints polylinePoints = PolylinePoints();
  Map<PolylineId, Polyline> polylines = {};
  late LatLng currentLocatioN;
  late Marker marker;
  final Map<String, Marker> _markers = {};
  Map<MarkerId, Marker> markers = <MarkerId, Marker>{};
  final Location location = Location();

  _addPolyLine() {
    PolylineId id = PolylineId(AppStrings.polyline);
    Polyline polyline = Polyline(
      polylineId: id,
      color: AppColors.red,
      points: polylineCoordinates,
    );
    polylines[id] = polyline;
    setState(() {});
  }

  _getPolyline(LatLng source, LatLng destiny) async {
    //dibuja la ruta
    PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
      AppStrings.googleAPiKey,
      PointLatLng(source.latitude, source.longitude),
      PointLatLng(
        destiny.latitude,
        destiny.longitude,
      ),
    );
    if (result.points.isNotEmpty) {
      result.points.forEach((PointLatLng point) {
        polylineCoordinates.add(
          LatLng(
            point.latitude,
            point.longitude,
          ),
        );
      });
    }
    _addPolyLine();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        Container(
          height: 140,
          //width: 120,
          child: Card(
            margin: EdgeInsets.only(
              left: 59,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15.0),
            ),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Container(
                    height: 10,
                  ),
                  Row(
                    children: <Widget>[
                      Container(
                        padding: EdgeInsets.only(
                          left: 60,
                        ),
                      ),
                      Flexible(
                        child: Container(
                          child: Text(
                            widget._sites.name ?? "",
                            overflow: TextOverflow.fade,
                            style: Styles.flexibleSites,
                          ),
                        ),
                      ),
                    ],
                  ),
                  Container(
                    height: 2,
                  ),
                  Row(
                    children: <Widget>[
                      Container(
                        padding: EdgeInsets.only(
                          left: 60,
                        ),
                      ),
                      Flexible(
                        child: Container(
                          child: Text(
                            widget._sites.category ?? "",
                            overflow: TextOverflow.fade,
                            style: Styles.flexibleSitesCategory,
                          ),
                        ),
                      ),
                    ],
                  ),
                  Container(
                    height: 5,
                  ),
                  Row(
                    children: <Widget>[
                      Container(
                        padding: EdgeInsets.only(
                          left: 60,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    height: 10,
                  ),
                ],
              ),
            ),
          ),
        ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Container(
              padding: EdgeInsets.only(
                top: 18.0,
                bottom: 1,
                right: 100,
              ),
              child: Row(
                children: <Widget>[
                  GestureDetector(
                    child: Container(
                      height: 110,
                      width: 110,
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          image: NetworkImage(widget._sites.profileCover ?? ""),
                          fit: BoxFit.cover,
                        ),
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                    ),
                    onTap: widget.viewMoreOnClick(),
                  ),
                ],
              ),
            ),
            Container(
              margin: EdgeInsets.only(top: 94, left: 40),
              child: ButtonTheme(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                  side: BorderSide(
                    width: 3,
                    color: AppColors.lightNavyBlue,
                  ),
                ),
                minWidth: 32.0,
                height: 32.0,
                child: RaisedButton(
                  onPressed: widget.viewMoreOnClick(),
                  child: Text(
                    AppStrings.seeMore,
                    style: Styles.conteinerSeeMore,
                  ),
                ),
              ),
            ),
          ],
        ),
        Row(
          children: <Widget>[
            GestureDetector(
              child: SizedBox(
                width: 120,
                child: Container(
                  margin: EdgeInsets.only(top: 130, left: 8),
                  child: Text(
                    widget._sites.name!.toUpperCase(),
                    overflow: TextOverflow.fade,
                    style: Styles.rowSizedBox,
                  ),
                ),
              ),
              onTap: () async {
                var result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (BuildContext context) => DetailBusiness(
                      widget._sites,
                    ),
                  ),
                );
                if (result ?? false) {
                  setState(
                    () {
                      _getPolyline(
                        LatLng(4.43371775, -75.20472854),
                        LatLng(
                          widget._sites.latitude!,
                          widget._sites.longitude!,
                        ),
                      );
                    },
                  );
                }
              },
            ),
          ],
        ),
      ],
    );
  }

  loadPosition(GoogleMapController controller) async {
    // position = await Geolocator()
    //     .getCurrentPosition(desiredAccuracy: LocationAccuracy.best);
    var lat;
    var long;
    location.onLocationChanged.listen(
      (LocationData currentLocation) {
        setState(
          () {
            if (lat != currentLocation.latitude &&
                long != currentLocation.longitude) {
              lat = currentLocation.latitude;
              long = currentLocation.longitude;
              // controller.animateCamera(CameraUpdateCameraPosition(
              //     CameraPosition(
              //         target: LatLng(
              //             currentLocation.latitude, currentLocation.longitude),
              //         zoom: 16.0)));
              this.setState(
                () {
                  marker = Marker(
                    markerId: MarkerId(AppStrings.markerId),
                    position: LatLng(
                      currentLocation.latitude!,
                      currentLocation.longitude!,
                    ),
                    icon: icon24,
                  );
                  markers[marker.markerId] = marker;
                  currentLocatioN = LatLng(
                    currentLocation.latitude!,
                    currentLocation.longitude!,
                  );
                },
              );
            }
          },
        );
      },
    );
  }

  late BitmapDescriptor icon24;
}
