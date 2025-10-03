
import 'package:biux/core/config/colors.dart';
import 'package:biux/core/config/strings.dart';
import 'package:biux/core/config/styles.dart';
import 'package:biux/features/roads/presentation/screens/road_create/map_road/map_road_bloc.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';

class MapRoadsLocation extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final bloc = context.watch<MapRoadBloc>();
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: AppColors.blackPearl,
        title: Text(
          AppStrings.meetingPointText,
          style: Styles.mainMenuTextBiux,
        ),
      ),
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: bloc.locationPosition,
            zoomControlsEnabled: false,
            myLocationEnabled: true,
            myLocationButtonEnabled: true,
            onMapCreated: (GoogleMapController controller) {
              bloc.controller.complete(controller);
            },
            onTap: (argument) => bloc.changeLocation(argument),
            markers: <Marker>{
              Marker(
                consumeTapEvents: true,
                markerId: MarkerId('locationData'),
                position: LatLng(
                  bloc.locationData.latitude!,
                  bloc.locationData.longitude!,
                ),
              )
            },
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              margin: const EdgeInsets.only(bottom: 20),
              width: 200,
              child: TextButton(
                style: Styles().textButtonStyle,
                onPressed: () => Navigator.pop(
                  context,
                  bloc.locationData,
                ),
                child: Text(
                  AppStrings.savePointText,
                  style: Styles.containerNameUser,
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
