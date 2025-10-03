import 'package:biux/features/maps/data/models/meeting_point.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapScreenBloc extends ChangeNotifier {
  Set<Marker> _markers = {};
  List<MeetingPoint> _meetingPoints = [];
  MeetingPoint? _selectedPoint;
  GoogleMapController? _mapController;

  Set<Marker> get markers => _markers;
  List<MeetingPoint> get meetingPoints => _meetingPoints;
  MeetingPoint? get selectedPoint => _selectedPoint;

  void onMapCreated(GoogleMapController controller) {
    _mapController = controller;
    notifyListeners();
  }

  void updateMeetingPoints(List<MeetingPoint> points) {
    _meetingPoints = points;
    _updateMarkers();
    notifyListeners();
  }

  void selectMeetingPoint(MeetingPoint? point) {
    _selectedPoint = point;
    if (point != null && _mapController != null) {
      _mapController!.animateCamera(
        CameraUpdate.newLatLng(
          LatLng(point.latitude, point.longitude),
        ),
      );
    }
    notifyListeners();
  }

  void _updateMarkers() {
    _markers = _meetingPoints.map((point) {
      return Marker(
        markerId: MarkerId(point.id),
        position: LatLng(point.latitude, point.longitude),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
        infoWindow: InfoWindow(
          title: point.name,
          snippet: point.description,
        ),
        onTap: () => selectMeetingPoint(point),
      );
    }).toSet();
    notifyListeners();
  }

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }
}
