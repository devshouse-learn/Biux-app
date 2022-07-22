/* File to get location of user
* used dependencies - location => to get location coordinates of user,
*   - geoLocation => To get Address from the location coordinates
 */
import 'package:flutter/services.dart';
import 'package:flutter_geocoder/geocoder.dart';
import 'package:location/location.dart';

getUserLocation() async {
  LocationData currentLocation;
  LocationData? currentData2;
  String? error = "Error";
  Location location = Location();
  try {
    currentLocation = await location.getLocation();
  } on PlatformException catch (e) {
    if (e.code == 'PERMISSION_DENIED') {
      error = 'please grant permission';
    }
    if (e.code == 'PERMISSION_DENIED_NEVER_ASK') {
      error = 'permission denied- please enable it from app settings';
    
    }
    currentLocation = currentData2!;
  }
  final coordinates =
      Coordinates(currentLocation.latitude!, currentLocation.longitude!);
  var addresses =
      await Geocoder.local.findAddressesFromCoordinates(coordinates);
  var first = addresses.first;
  return first;
}
