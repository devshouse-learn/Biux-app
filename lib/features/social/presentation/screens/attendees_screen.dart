import 'package:flutter/material.dart';
import '../widgets/attendees_list.dart';

/// Pantalla de asistentes a una rodada
class RideAttendeesScreen extends StatelessWidget {
  final String rideId;
  final String rideOwnerId;

  const RideAttendeesScreen({
    super.key,
    required this.rideId,
    required this.rideOwnerId,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Asistentes'),
        backgroundColor: const Color(0xFF16242D), // AppColors.blackPearl
      ),
      body: SafeArea(
        child: AttendeesList(
          rideId: rideId,
          showJoinButton: true,
          rideOwnerId: rideOwnerId,
        ),
      ),
    );
  }
}
