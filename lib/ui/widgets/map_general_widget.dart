import 'dart:async';
import 'package:biux/config/colors.dart';
import 'package:biux/config/styles.dart';
import 'package:biux/config/strings.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapGeneral extends StatefulWidget {
  @override
  MapGeneral({required this.message});
  final String message;
  _MapGeneralState createState() => _MapGeneralState();
}

String _message = "";
void getDataAndPop(context) {
  MapGeneral mapgeneral = MapGeneral(
    message: "$_message",
  );
  Navigator.pop(
    context,
    mapgeneral,
  ); //pop happens here
}

class _MapGeneralState extends State<MapGeneral> {
  late int _showing;
  late Marker marker;
  late Position position;

  double size = 450;
  double size2 = 350;

  @override
  void initState() {
    super.initState();

    this.setState(() {
      _showing = 0;
      marker = Marker(
        markerId: MarkerId(AppStrings.markerId2),
        position: LatLng(4.20475, -74.64075),
      );
    });

    Future.delayed(Duration.zero, () => uploadMessage());
  }

  uploadMessage() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            AppStrings.warning,
            style: Styles.fontWeightBold,
          ),
          content: Text(
            AppStrings.messageGoogleMap,
          ),
          actions: <Widget>[
            RaisedButton(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15.0),
                side: BorderSide(
                  width: 3,
                  color: AppColors.lightNavyBlue,
                ),
              ),
              child: Text(
                AppStrings.understood,
                style: Styles.containerDescription,
              ),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }

  loadPosition(GoogleMapController controller) async {
    position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    controller.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          target: LatLng(
            position.latitude,
            position.longitude,
          ),
          zoom: 18.0,
        ),
      ),
    );
    this.setState(
      () {
        marker = Marker(
          markerId: MarkerId(AppStrings.markerId2),
          position: LatLng(
            position.latitude,
            position.longitude,
          ),
        );
      },
    );
  }

  void _confirmLocation(String directionCrontroller) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            AppStrings.confirmLocation,
            style: Styles.fontWeightBold,
          ),
          content: Text(
            AppStrings.messageConfirmLocation(message: directionCrontroller),
            style: Styles.textStyle,
          ),
          actions: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                RaisedButton(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15.0),
                    side: BorderSide(
                      width: 3,
                      color: AppColors.lightNavyBlue,
                    ),
                  ),
                  child: Text(
                    AppStrings.si,
                    style: Styles.containerDescription,
                  ),
                  onPressed: () {
                    _send(context, directionCrontroller);
                  },
                ),
                Container(width: 10),
                RaisedButton(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.0),
                    side: BorderSide(
                      width: 3,
                      color: AppColors.lightNavyBlue,
                    ),
                  ),
                  color: AppColors.white,
                  child: Text(
                    AppStrings.no,
                    style: Styles.containerLightNavyBlue,
                  ),
                  onPressed: () {
                    Navigator.pop(
                      context,
                      widget.message,
                    );
                  },
                )
              ],
            ),
          ],
        );
      },
    );
  }

  Completer<GoogleMapController> _controller = Completer();

  @override
  Widget build(BuildContext context) {
    final TextEditingController directionCrontroller = TextEditingController();
    final _formRegisterAddressKey = GlobalKey<FormState>();
    return Scaffold(
      // resizeToAvoidBottomPadding: false,
      appBar: AppBar(
        title: Text(
          AppStrings.confirmAddress,
          style: Styles.rowContainer,
        ),
      ),
      body: Container(
        child: Stack(
          children: <Widget>[
            Container(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height - size,
              child: GoogleMap(
                myLocationButtonEnabled: true,
                myLocationEnabled: true,
                onTap: (posicion) {
                  this.setState(
                    () {
                      marker = Marker(
                        markerId: MarkerId(AppStrings.markerId2),
                        position: posicion,
                      );
                    },
                  );
                },
                mapType: MapType.normal,
                initialCameraPosition: _iniPosicion,
                onMapCreated: (GoogleMapController controller) {
                  _controller.complete(controller);
                  loadPosition(controller);
                },
                markers: {marker},
              ),
            ),
            Align(
              alignment: Alignment.topLeft,
              child: Text(
                AppStrings.selectLocation,
                style: Styles.alignBlue,
              ),
            ),
            Container(
              margin: EdgeInsets.only(top: size2),
              child: ListView(
                children: [
                  Container(
                    margin: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        AppStrings.mapGeneralAddress,
                        style: Styles.containerDescription,
                      ),
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.symmetric(
                      vertical: 5,
                      horizontal: 10,
                    ),
                    padding: EdgeInsets.only(
                      right: 15,
                      left: 5,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    child: TextFormField(
                      onTap: () {
                        setState(() {
                          size = 650;
                          size2 = 200;
                        });
                      },
                      onEditingComplete: () {
                        FocusScope.of(context).requestFocus(
                          FocusNode(),
                        );
                        setState(() {
                          size = 450;
                          size2 = 350;
                        });
                      },
                      maxLines: 2,
                      controller: directionCrontroller,
                      textInputAction: TextInputAction.done,
                      decoration: InputDecoration(
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        contentPadding: EdgeInsets.fromLTRB(
                          10.0,
                          15.0,
                          20.0,
                          15.0,
                        ),
                        border: InputBorder.none,
                        labelText: AppStrings.departureAddress,
                        labelStyle: Styles.advertisingTitle,
                      ),
                      validator: (value) {
                        if (value == '' || value!.isEmpty || value == null) {
                          return AppStrings.fieldCannotEmpty;
                        } else if (value.length < 5) {
                          return AppStrings.fieldCannotcharacters;
                        }
                        return null;
                      },
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.symmetric(
                      vertical: 20,
                      horizontal: 100,
                    ),
                    child: RaisedButton(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                        side: BorderSide(
                          width: 3,
                          color: AppColors.lightNavyBlue,
                        ),
                      ),
                      child: Container(
                        padding: EdgeInsets.all(10),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Text(
                              AppStrings.confirm,
                              style: Styles.rowContainer,
                            ),
                          ],
                        ),
                      ),
                      onPressed: () {
                        FocusScope.of(context).requestFocus(FocusNode());
                        if (directionCrontroller.text == '') {
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: Text(AppStrings.warning),
                                content: Text(
                                  AppStrings.messageErrorcheck,
                                ),
                                actions: <Widget>[
                                  RaisedButton(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12.0),
                                      side: BorderSide(
                                        color: AppColors.lightNavyBlue,
                                      ),
                                    ),
                                    child: Text(
                                      AppStrings.correctData,
                                      style: Styles.accentTextThemeWhite,
                                    ),
                                    onPressed: () =>
                                        Navigator.of(context).pop(),
                                  ),
                                ],
                              );
                            },
                          );
                        } else {
                          _confirmLocation(directionCrontroller.text);
                        }
                      },
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  void _send(context1, directionCrontroller) {
    var position = {
      AppStrings.latitude: marker.position.latitude,
      AppStrings.longitude: marker.position.longitude,
      AppStrings.addressText: directionCrontroller,
    };
    Navigator.pop(context);
    Navigator.pop(context1, position);
  }

  static final CameraPosition _iniPosicion = CameraPosition(
    target: LatLng(
      4.433,
      -75.217,
    ),
  );
}
