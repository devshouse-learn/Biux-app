import 'dart:async';
import 'package:biux/config/colors.dart';
import 'package:biux/config/styles.dart';
import 'package:biux/config/strings.dart';
import 'package:biux/data/models/sites.dart';
import 'package:biux/ui/screens/map/menu_map.dart';
import 'package:biux/ui/screens/zoom_screen/zoom_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

class DetailBusiness extends StatefulWidget {
  final Sites _sites;

  DetailBusiness(this._sites);
  static final CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(4.444, -75.242438),
    zoom: 14.4746,
  );
  @override
  _DetailBusinessState createState() => _DetailBusinessState();
}

class _DetailBusinessState extends State<DetailBusiness> {
  Completer<GoogleMapController> _controller = Completer();
  Map<PolylineId, Polyline> polylines = {};
  List<LatLng> polylineCoordinates = [];
  PolylinePoints polylinePoints = PolylinePoints();

  void _onMapCreated(GoogleMapController controller) {
    _controller.complete(controller);
  }

  final Map<String, Marker> _markers = {};
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: new AppBar(
        backgroundColor: AppColors.greyishNavyBlue,
        title: Row(
          children: <Widget>[
            Text(
              widget._sites.name!,
              style: Styles.paddingHintText,
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: Center(
          child: Stack(
            children: <Widget>[
              ListView(
                children: <Widget>[
                  Container(
                    height: 20,
                  ),
                  GestureDetector(
                    child: Center(
                      child: Stack(
                        children: <Widget>[
                          Container(
                            height: 160.0,
                            width: 160.0,
                            decoration: BoxDecoration(
                              image: DecorationImage(
                                image:
                                    NetworkImage(widget._sites.profileCover!),
                                fit: BoxFit.cover,
                              ),
                              borderRadius: BorderRadius.all(
                                const Radius.circular(
                                  80.0,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) {
                            return ZoomPage3(widget._sites);
                          },
                        ),
                      );
                    },
                  ),
                  Container(
                    height: 20,
                  ),
                  Center(
                    child: Container(
                      child: Text(
                        widget._sites.name!,
                        overflow: TextOverflow.fade,
                        style: Styles.alertDialogTitle,
                      ),
                    ),
                  ),
                  Stack(
                    alignment: Alignment.bottomRight,
                    children: <Widget>[
                      GestureDetector(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[],
                        ),
                      ),
                    ],
                  ),
                  Container(
                    alignment: Alignment.center,
                    child: Text(
                      widget._sites.category ?? "",
                      style: Styles.roadDescriptionText,
                    ),
                  ),
                  widget._sites.description == ""
                      ? SizedBox(
                          height: 20,
                        )
                      : Container(
                          padding: EdgeInsets.all(20),
                          child: Wrap(
                            children: <Widget>[
                              Container(
                                alignment: Alignment.center,
                                child: Text(
                                  widget._sites.description!,
                                  style: Styles.roadDescriptionText,
                                ),
                              ),
                            ],
                          ),
                        ),
                  Row(
                    children: <Widget>[
                      Padding(
                        padding: EdgeInsets.fromLTRB(
                          15,
                          0,
                          0,
                          0,
                        ),
                      ),
                      Container(
                        child: Icon(
                          Icons.access_time,
                        ),
                      ),
                      Container(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          widget._sites.schedule! == AppStrings.missingOpening
                              ? " "
                              : widget._sites.schedule!,
                          style: Styles.roadDescriptionText,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    height: 10,
                  ),
                  widget._sites.telephone == ""
                      ? SizedBox()
                      : Row(
                          children: <Widget>[
                            Padding(
                              padding: EdgeInsets.fromLTRB(
                                15,
                                0,
                                0,
                                0,
                              ),
                            ),
                            Container(
                              child: Icon(Icons.phone),
                            ),
                            GestureDetector(
                              child: Container(
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  widget._sites.telephone!,
                                  style: Styles.roadDescriptionText,
                                ),
                              ),
                              onTap: () {
                                launch(AppStrings.launchTel(whatsapp: widget._sites.whatsapp!));
                              },
                            ),
                          ],
                        ),
                  Container(
                    height: 10,
                  ),
                  Row(
                    children: <Widget>[
                      Padding(
                        padding: EdgeInsets.fromLTRB(
                          15,
                          0,
                          0,
                          0,
                        ),
                      ),
                      Container(
                        child: Icon(Icons.directions),
                      ),
                      Container(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          widget._sites.direction!,
                          overflow: TextOverflow.ellipsis,
                          style: Styles.containerDirection,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    height: 20,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      ButtonTheme(
                        padding: EdgeInsets.only(
                          right: 20,
                          left: 20,
                        ),
                        minWidth: 300,
                        height: 50.0,
                        child: RaisedButton(
                          shape: RoundedRectangleBorder(
                            borderRadius: new BorderRadius.circular(10.0),
                            side: BorderSide(
                              width: 3,
                              color: AppColors.greyishNavyBlue,
                            ),
                          ),
                          color: AppColors.greyishNavyBlue,
                          textColor: AppColors.white,
                          child: Text(
                            AppStrings.HowGet,
                            style: Styles.accentTextThemeWhite,
                          ),
                          onPressed: () {
                            Navigator.pop(context, true);
                            MenuMap(
                              widget._sites.latitude,
                              widget._sites.longitude,
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                  Container(
                    height: 10,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: <Widget>[
                      widget._sites.telephone == ""
                          ? Container(
                              alignment: Alignment.center,
                            )
                          : IconButton(
                              iconSize: 10,
                              alignment: Alignment.centerRight,
                              icon: Icon(
                                FontAwesomeIcons.whatsapp,
                                size: 35.0,
                              ),
                              onPressed: () {
                                launch(
                                  AppStrings.launchWhatsapp(whatsapp: widget._sites.whatsapp!)
                                );
                              },
                            ),
                      widget._sites.instagram == ""
                          ? Row(
                              children: [
                                Container(),
                              ],
                            )
                          : IconButton(
                              iconSize: 10,
                              alignment: Alignment.centerRight,
                              icon: new Icon(FontAwesomeIcons.instagram,
                                  size: 35.0),
                              onPressed: () {
                                launch(
                                  "${widget._sites.instagram}",
                                );
                              },
                            ),
                      widget._sites.facebook == ""
                          ? Container()
                          : IconButton(
                              alignment: Alignment.centerRight,
                              iconSize: 10,
                              icon: new Icon(
                                FontAwesomeIcons.facebook,
                                size: 35.0,
                              ),
                              onPressed: () {
                                launch(
                                  "${widget._sites.facebook}",
                                );
                              },
                            )
                    ],
                  ),
                  Container(
                    height: 0,
                  ),
                  /*Container(
                  width: 200,
                  height: 200,
                  child: GoogleMap(
                    mapType: MapType.normal,
                    onMapCreated: _onMapCreated,
                    initialCameraPosition: DetallesNegocio._kGooglePlex,
                    markers: _markers.values.toSet(),
                  ),
                ),*/
                  Container(
                    height: 80,
                  ),
                ],
              ),
              /* Row(
                children: <Widget>[
                  Flexible(
                      flex: 15,
                      child: Container(
                        child: Buttomn(),
                      )),
                  Container(
                    width: 2,
                  ),
                  /* Flexible(
                      flex: 25,
                      child: Container(
                        child: Buttomn2(),
                      ))*/
                ],
              ),*/
            ],
          ),
        ),
      ),
    );
  }

  _addPolyLine() {
    PolylineId id = PolylineId(AppStrings.polyline);
    Polyline polyline = Polyline(
      polylineId: id,
      color: AppColors.red,
      points: polylineCoordinates,
    );
    polylines[id] = polyline;
  }

  _getPolyline(LatLng origen, LatLng destino) async {
    //dibuja la ruta
    PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
      AppStrings.googleAPiKey,
      PointLatLng(origen.latitude, origen.longitude),
      PointLatLng(destino.latitude, destino.longitude),
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
}

class Buttomn extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        height: 50,
        child: RaisedButton(
          padding: EdgeInsets.symmetric(horizontal: 20),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(0.0),
          ),
          color: Theme.of(context).primaryColor,
          child: Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Container(
                width: 40,
              ),
              Expanded(
                child: Text(
                  AppStrings.cancelText,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headline4,
                ),
              ),
              Container(
                width: 40,
              ),
            ],
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
    );
  }
}

/*class Buttomn2 extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Align(
        alignment: Alignment.bottomCenter,
        child: Container(
          height: 50,
          child: RaisedButton(
            padding: EdgeInsets.symmetric(horizontal: 20),
            shape: RoundedRectangleBorder(
              borderRadius: new BorderRadius.circular(0.0),
            ),
            color: Theme.of(context).primaryColor,
            child: Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  Container(
                    width: 40,
                  ),
                  Expanded(
                    child: Text("call",
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.display4),
                  ),
                  Container(
                    width: 40,
                  )
                ]),
            onPressed: () {

             /*  Navigator.push(
                  context,
                  new MaterialPageRoute(
                    builder: (BuildContext context) =>
                        new Codeconduct(),
                  ));*/
            },
          ),
        ));
  }
}
*/
