import 'package:biux/core/config/colors.dart';
import 'package:biux/features/maps/presentation/providers/location_provider.dart';
import 'package:biux/features/maps/presentation/providers/map_provider.dart';
import 'package:biux/features/maps/presentation/providers/meeting_point_provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:biux/features/roads/data/models/route.dart';

class MapScreen extends StatefulWidget {
  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  static const CameraPosition _defaultLocation = CameraPosition(
    target: LatLng(4.4389, -75.2322),
    zoom: 13,
  );

  @override
  void initState() {
    super.initState();
    // Iniciar la escucha de puntos de encuentro cuando el usuario está autenticado
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser != null) {
        final meetingPointProvider =
            Provider.of<MeetingPointProvider>(context, listen: false);
        meetingPointProvider.startListening();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer3<MapProvider, MeetingPointProvider, LocationProvider>(
      builder:
          (context, mapProvider, meetingPointProvider, locationProvider, _) {
        // Conectar LocationProvider con MapProvider una vez
        WidgetsBinding.instance.addPostFrameCallback((_) {
          mapProvider.setLocationProvider(locationProvider);
        });

        // Cargar puntos de encuentro
        if (meetingPointProvider.meetingPoints.isNotEmpty) {
          mapProvider.updateMeetingPoints(meetingPointProvider.meetingPoints);
        }

        return Stack(
          children: [
            MapView(
              initialPosition: _defaultLocation,
              mapProvider: mapProvider,
            ),

            // Botón flotante para solicitar ubicación
            Positioned(
              top: 16,
              right: 16,
              child: FloatingActionButton(
                heroTag: "location_btn",
                mini: true,
                backgroundColor: AppColors.strongCyan,
                foregroundColor: AppColors.white,
                onPressed: () async {
                  await mapProvider.requestUserLocation();

                  if (locationProvider.error != null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(locationProvider.error!),
                        backgroundColor: AppColors.red,
                      ),
                    );
                  }
                },
                child: locationProvider.isLoading
                    ? SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(AppColors.white),
                        ),
                      )
                    : Icon(Icons.my_location),
              ),
            ),

            if (mapProvider.isLoading || meetingPointProvider.isLoading)
              const LoadingIndicator(),

            // Card de detalles del punto de encuentro
            if (mapProvider.selectedPoint != null)
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: MeetingPointDetailsCard(
                  mapProvider: mapProvider,
                ),
              ),
          ],
        );
      },
    );
  }
}

class MapView extends StatelessWidget {
  final CameraPosition initialPosition;
  final MapProvider mapProvider;

  const MapView({
    Key? key,
    required this.initialPosition,
    required this.mapProvider,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GoogleMap(
      initialCameraPosition: initialPosition,
      markers: mapProvider.markers,
      polylines: mapProvider.polylines,
      myLocationEnabled: true,
      myLocationButtonEnabled: true,
      zoomControlsEnabled: false,
      onMapCreated: mapProvider.onMapCreated,
      onTap: (_) => mapProvider.selectMeetingPoint(null),
    );
  }
}

class LoadingIndicator extends StatelessWidget {
  const LoadingIndicator({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: CircularProgressIndicator(
        valueColor: AlwaysStoppedAnimation<Color>(AppColors.strongCyan),
      ),
    );
  }
}

class MeetingPointDetailsCard extends StatelessWidget {
  final MapProvider mapProvider;

  const MeetingPointDetailsCard({
    Key? key,
    required this.mapProvider,
  }) : super(key: key);

  Future<void> _openGoogleMaps() async {
    final point = mapProvider.selectedPoint!;
    final url =
        'https://www.google.com/maps/dir/?api=1&destination=${point.latitude},${point.longitude}&travelmode=driving';

    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.transparent,
      child: InkWell(
        onTap: () {}, // Previene que los toques pasen al mapa
        child: Container(
          margin: EdgeInsets.all(16),
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: AppColors.black.withOpacity(0.2),
                blurRadius: 8,
                offset: Offset(0, -2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              DetailsHeader(mapProvider: mapProvider),
              SizedBox(height: 8),
              Text(
                mapProvider.selectedPoint!.description,
                style: TextStyle(color: AppColors.grey),
              ),
              SizedBox(height: 16),
              // Botón de navegación
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _openGoogleMaps,
                  icon: Icon(Icons.navigation, color: AppColors.white),
                  label: Text(
                    'Ir al punto de encuentro',
                    style: TextStyle(
                      color: AppColors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.strongCyan,
                    padding: EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
              if (mapProvider.selectedPoint!.routes.isNotEmpty) ...[
                SizedBox(height: 16),
                Text(
                  'Rutas disponibles:',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8),
                RoutesList(routes: mapProvider.selectedPoint!.routes),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class DetailsHeader extends StatelessWidget {
  final MapProvider mapProvider;

  const DetailsHeader({
    Key? key,
    required this.mapProvider,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            mapProvider.selectedPoint!.name,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        IconButton(
          icon: Icon(Icons.close),
          onPressed: () => mapProvider.selectMeetingPoint(null),
        ),
      ],
    );
  }
}

class RoutesList extends StatelessWidget {
  final List<BiuxRoute> routes;

  const RoutesList({
    Key? key,
    required this.routes,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 120,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: routes.length,
        itemBuilder: (context, index) => RouteCard(route: routes[index]),
      ),
    );
  }
}

class RouteCard extends StatelessWidget {
  final BiuxRoute route;

  const RouteCard({
    Key? key,
    required this.route,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final mapProvider = Provider.of<MapProvider>(context);
    final isSelected = mapProvider.selectedRoute?.id == route.id;

    return Card(
      margin: EdgeInsets.only(right: 8),
      color:
          isSelected ? AppColors.strongCyan.withOpacity(0.1) : AppColors.white,
      child: InkWell(
        onTap: () {
          if (isSelected) {
            mapProvider
                .selectRoute(null); // Deseleccionar si ya está seleccionada
          } else {
            mapProvider.selectRoute(route); // Seleccionar esta ruta
          }
        },
        borderRadius: BorderRadius.circular(4),
        child: Container(
          width: 200,
          padding: EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      route.name,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppColors.strongCyan,
                      ),
                    ),
                  ),
                  if (isSelected)
                    Icon(
                      Icons.route,
                      color: AppColors.strongCyan,
                      size: 20,
                    ),
                ],
              ),
              SizedBox(height: 4),
              Text(
                route.description,
                style: TextStyle(fontSize: 12),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              Spacer(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  RouteLevelBadge(level: route.level),
                  if (!isSelected)
                    Text(
                      'Toca para ver ruta',
                      style: TextStyle(
                        fontSize: 10,
                        color: AppColors.grey,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  if (isSelected)
                    Text(
                      'Ruta mostrada',
                      style: TextStyle(
                        fontSize: 10,
                        color: AppColors.strongCyan,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class RouteLevelBadge extends StatelessWidget {
  final String level;

  const RouteLevelBadge({
    Key? key,
    required this.level,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Flexible(
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: 6,
          vertical: 4,
        ),
        decoration: BoxDecoration(
          color: AppColors.strongCyan.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          'Nivel: $level',
          style: TextStyle(
            color: AppColors.strongCyan,
            fontSize: 10,
            fontWeight: FontWeight.bold,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }
}
