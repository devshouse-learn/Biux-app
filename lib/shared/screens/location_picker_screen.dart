import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';
import 'package:biux/core/design_system/locale_notifier.dart';

class LocationPickerScreen extends StatefulWidget {
  final LatLng? initialLocation;
  final String? title;

  const LocationPickerScreen({Key? key, this.initialLocation, this.title})
    : super(key: key);

  @override
  State<LocationPickerScreen> createState() => _LocationPickerScreenState();
}

class _LocationPickerScreenState extends State<LocationPickerScreen> {
  GoogleMapController?
  _mapController; // ignore: unused_field // ignore: unused_field
  LatLng? _selectedLocation;
  bool _loading = true;
  String? _address;

  @override
  void initState() {
    super.initState();
    _initLocation();
  }

  Future<void> _initLocation() async {
    if (widget.initialLocation != null) {
      setState(() {
        _selectedLocation = widget.initialLocation;
        _loading = false;
      });
      return;
    }

    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.whileInUse ||
          permission == LocationPermission.always) {
        final position = await Geolocator.getCurrentPosition(
          locationSettings: const LocationSettings(
            accuracy: LocationAccuracy.high,
          ),
        );
        setState(() {
          _selectedLocation = LatLng(position.latitude, position.longitude);
          _loading = false;
        });
      } else {
        // Default CDMX
        setState(() {
          _selectedLocation = const LatLng(19.4326, -99.1332);
          _loading = false;
        });
      }
    } catch (e) {
      setState(() {
        _selectedLocation = const LatLng(19.4326, -99.1332);
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = Provider.of<LocaleNotifier>(context, listen: false);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.red[700],
        foregroundColor: Colors.white,
        title: Text(widget.title ?? l.t('select_location_title')),
        actions: [
          TextButton.icon(
            onPressed: _selectedLocation != null
                ? () => Navigator.pop(context, _selectedLocation)
                : null,
            icon: const Icon(Icons.check, color: Colors.white),
            label: Text(
              l.t('location_confirm'),
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Stack(
              children: [
                GoogleMap(
                  initialCameraPosition: CameraPosition(
                    target: _selectedLocation!,
                    zoom: 16,
                  ),
                  onMapCreated: (controller) => _mapController = controller,
                  onCameraMove: (position) {
                    _selectedLocation = position.target;
                  },
                  onCameraIdle: () {
                    if (_selectedLocation != null) {
                      setState(() {
                        _address =
                            '${_selectedLocation!.latitude.toStringAsFixed(5)}, '
                            '${_selectedLocation!.longitude.toStringAsFixed(5)}';
                      });
                    }
                  },
                  myLocationEnabled: true,
                  myLocationButtonEnabled: true,
                  zoomControlsEnabled: false,
                  mapToolbarEnabled: false,
                ),
                // Center pin
                const Center(
                  child: Padding(
                    padding: EdgeInsets.only(bottom: 36),
                    child: Icon(Icons.location_on, size: 48, color: Colors.red),
                  ),
                ),
                // Bottom info card
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(20),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 10,
                          offset: const Offset(0, -2),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 40,
                          height: 4,
                          decoration: BoxDecoration(
                            color: Colors.grey[300],
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            const Icon(Icons.pin_drop, color: Colors.red),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    l.t('location_selected'),
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                  ),
                                  Text(
                                    _address ?? l.t('location_move_map'),
                                    style: TextStyle(
                                      color: Colors.grey[600],
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          l.t('location_move_pin'),
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 12,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}
