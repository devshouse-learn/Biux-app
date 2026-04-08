import 'package:biux/core/design_system/locale_notifier.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:biux/features/social/presentation/widgets/attendees_list.dart';

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
    final l = Provider.of<LocaleNotifier>(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(l.t('attendees_title')),
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
