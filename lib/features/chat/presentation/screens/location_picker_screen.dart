import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:biux/core/design_system/locale_notifier.dart';
import 'package:provider/provider.dart';

/// Pantalla de selección de ubicación en mapa.
/// Retorna un LatLng al hacer pop, o null si se cancela.
class LocationPickerScreen extends StatefulWidget {
  const LocationPickerScreen({super.key});

  @override
  State<LocationPickerScreen> createState() => _LocationPickerScreenState();
}

class _LocationPickerScreenState extends State<LocationPickerScreen> {
  LocaleNotifier get l => Provider.of<LocaleNotifier>(context);

  GoogleMapController? _mapController;
  LatLng _selectedPosition = const LatLng(19.4326, -99.1332); // Default CDMX
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _goToCurrentLocation();
  }

  Future<void> _goToCurrentLocation() async {
    try {
      final pos = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.medium,
          timeLimit: Duration(seconds: 8),
        ),
      );
      final latLng = LatLng(pos.latitude, pos.longitude);
      setState(() {
        _selectedPosition = latLng;
        _loading = false;
      });
      _mapController?.animateCamera(CameraUpdate.newLatLngZoom(latLng, 15));
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(l.t('select_location')),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, _selectedPosition),
            child: const Text(
              'Enviar',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 15,
              ),
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: _selectedPosition,
              zoom: 15,
            ),
            onMapCreated: (controller) => _mapController = controller,
            onTap: (latLng) {
              setState(() => _selectedPosition = latLng);
            },
            markers: {
              Marker(
                markerId: const MarkerId('selected'),
                position: _selectedPosition,
                draggable: true,
                onDragEnd: (latLng) {
                  setState(() => _selectedPosition = latLng);
                },
              ),
            },
            myLocationEnabled: true,
            myLocationButtonEnabled: true,
            zoomControlsEnabled: true,
          ),
          // Pin central como indicador visual
          if (_loading) const Center(child: CircularProgressIndicator()),
          // Instrucción
          Positioned(
            top: 12,
            left: 16,
            right: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.black87,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                l.t('tap_map_location'),
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white, fontSize: 13),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
