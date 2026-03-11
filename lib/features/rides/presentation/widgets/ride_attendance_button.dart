import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:biux/core/design_system/locale_notifier.dart';
import '../providers/ride_provider.dart';
import '../../data/models/ride_model.dart';

/// Botón único e inteligente para manejar asistencia a rodadas
/// Muestra el estado actual y permite cambiar entre:
/// - No voy (sin confirmar)
/// - Tal vez voy
/// - Voy confirmado
class RideAttendanceButton extends StatelessWidget {
  final RideModel ride;

  const RideAttendanceButton({Key? key, required this.ride}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final l = Provider.of<LocaleNotifier>(context);
    final rideProvider = Provider.of<RideProvider>(context);
    final currentUserId = rideProvider.currentUserId;

    if (currentUserId == null) {
      return const SizedBox.shrink();
    }

    // ✅ VERIFICAR SI LA RODADA YA PASÓ LA FECHA DE CONVOCATORIA
    final now = DateTime.now();
    final rideHasPassed = ride.dateTime.isBefore(now);

    if (rideHasPassed) {
      // Mostrar botón deshabilitado si ya pasó
      return SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
          onPressed: null, // Deshabilitado
          icon: const Icon(Icons.block, size: 24),
          label: Text(
            l.t('ride_finished_no_participants'),
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF9E9E9E), // Gris
            disabledBackgroundColor: const Color(0xFF9E9E9E),
            foregroundColor: Colors.white,
            disabledForegroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 18),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      );
    }

    // Determinar estado actual
    final isConfirmed = ride.participants.contains(currentUserId);
    final isMaybe = ride.maybeParticipants.contains(currentUserId);

    // SOLO UN BOTÓN PRINCIPAL - sin opciones adicionales confusas
    return _buildMainButton(context, rideProvider, isConfirmed, isMaybe, l);
  }

  Widget _buildMainButton(
    BuildContext context,
    RideProvider provider,
    bool isConfirmed,
    bool isMaybe,
    LocaleNotifier l,
  ) {
    // Estado: NO participa - Mostrar popup para elegir
    if (!isConfirmed && !isMaybe) {
      return SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
          onPressed: provider.isLoading
              ? null
              : () => _showOptionsForJoin(context, provider),
          icon: const Icon(Icons.directions_bike, size: 24),
          label: Text(
            l.t('are_you_going'),
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF2196F3), // Material Blue
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 18),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 2,
          ),
        ),
      );
    }

    // Estado: CONFIRMADO
    if (isConfirmed) {
      return SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
          onPressed: provider.isLoading
              ? null
              : () => _showOptions(context, provider),
          icon: const Icon(Icons.check_circle, size: 24),
          label: Text(
            l.t('confirmed_tap_to_change'),
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF4CAF50), // Material Green
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 18),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 2,
          ),
        ),
      );
    }

    // Estado: TAL VEZ
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: provider.isLoading
            ? null
            : () => _showOptions(context, provider),
        icon: const Icon(Icons.help_outline, size: 24),
        label: Text(
          l.t('maybe_tap_to_change'),
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFFF9800), // Material Orange
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 18),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 2,
        ),
      ),
    );
  }

  // Popup para cuando NO está participando
  void _showOptionsForJoin(BuildContext context, RideProvider provider) {
    final l = Provider.of<LocaleNotifier>(context, listen: false);
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                l.t('going_to_this_ride'),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              ListTile(
                leading: const Icon(
                  Icons.check_circle,
                  color: Colors.green,
                  size: 32,
                ),
                title: Text(l.t('confirmed_going')),
                subtitle: Text(l.t('definitely_attending')),
                onTap: () {
                  Navigator.pop(context);
                  _confirmAttendance(context, provider);
                },
              ),
              ListTile(
                leading: const Icon(
                  Icons.help_outline,
                  color: Colors.orange,
                  size: 32,
                ),
                title: Text(l.t('maybe_going')),
                subtitle: Text(l.t('not_sure_yet')),
                onTap: () {
                  Navigator.pop(context);
                  _changeToMaybe(context, provider);
                },
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  // Popup para cuando YA está participando
  void _showOptions(BuildContext context, RideProvider provider) {
    final l = Provider.of<LocaleNotifier>(context, listen: false);
    final currentUserId = provider.currentUserId;
    if (currentUserId == null) return;

    // Determinar estado actual
    final isConfirmed = ride.participants.contains(currentUserId);
    final isMaybe = ride.maybeParticipants.contains(currentUserId);

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                l.t('change_attendance_status'),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),

              // Solo mostrar "Confirmar" si NO está confirmado
              if (!isConfirmed)
                ListTile(
                  leading: const Icon(
                    Icons.check_circle,
                    color: Colors.green,
                    size: 32,
                  ),
                  title: Text(l.t('confirm_attendance')),
                  subtitle: Text(l.t('definitely_going')),
                  onTap: () {
                    Navigator.pop(context);
                    _confirmAttendance(context, provider);
                  },
                ),

              // Solo mostrar "Tal vez" si NO está en maybe
              if (!isMaybe)
                ListTile(
                  leading: const Icon(
                    Icons.help_outline,
                    color: Colors.orange,
                    size: 32,
                  ),
                  title: Text(l.t('maybe_going')),
                  subtitle: Text(l.t('not_sure_yet')),
                  onTap: () {
                    Navigator.pop(context);
                    _changeToMaybe(context, provider);
                  },
                ),

              const Divider(),

              // Siempre mostrar cancelar
              ListTile(
                leading: const Icon(Icons.cancel, color: Colors.red, size: 32),
                title: Text(l.t('cancel_attendance')),
                subtitle: Text(l.t('not_going_anymore')),
                onTap: () {
                  Navigator.pop(context);
                  _cancelAttendance(context, provider);
                },
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _confirmAttendance(
    BuildContext context,
    RideProvider provider,
  ) async {
    final l = Provider.of<LocaleNotifier>(context, listen: false);
    final success = await provider.joinRide(ride.id, maybe: false);

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            success
                ? '✅ ${l.t('attendance_confirmed')}'
                : '❌ ${provider.error ?? l.t('error')}',
          ),
          backgroundColor: success ? Colors.green : Colors.red,
        ),
      );
    }
  }

  Future<void> _changeToMaybe(
    BuildContext context,
    RideProvider provider,
  ) async {
    final l = Provider.of<LocaleNotifier>(context, listen: false);
    final success = await provider.joinRide(ride.id, maybe: true);

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            success
                ? '🤔 ${l.t('marked_maybe')}'
                : '❌ ${provider.error ?? l.t('error')}',
          ),
          backgroundColor: success ? Colors.orange : Colors.red,
        ),
      );
    }
  }

  Future<void> _cancelAttendance(
    BuildContext context,
    RideProvider provider,
  ) async {
    final l = Provider.of<LocaleNotifier>(context, listen: false);
    // Confirmar cancelación
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l.t('cancel_attendance')),
        content: Text(l.t('cancel_attendance_confirm')),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l.t('no_label')),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: Text(l.t('yes_cancel')),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    final success = await provider.leaveRide(ride.id);

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            success
                ? '👋 ${l.t('attendance_cancelled')}'
                : '❌ ${provider.error ?? l.t('error')}',
          ),
          backgroundColor: success ? Colors.grey : Colors.red,
        ),
      );
    }
  }
}
