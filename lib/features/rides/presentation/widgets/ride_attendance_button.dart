import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
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
    final rideProvider = Provider.of<RideProvider>(context);
    final currentUserId = rideProvider.currentUserId;

    if (currentUserId == null) {
      return const SizedBox.shrink();
    }

    // Determinar estado actual
    final isConfirmed = ride.participants.contains(currentUserId);
    final isMaybe = ride.maybeParticipants.contains(currentUserId);

    // SOLO UN BOTÓN PRINCIPAL - sin opciones adicionales confusas
    return _buildMainButton(context, rideProvider, isConfirmed, isMaybe);
  }

  Widget _buildMainButton(
    BuildContext context,
    RideProvider provider,
    bool isConfirmed,
    bool isMaybe,
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
          label: const Text(
            '¿Vas a esta rodada?',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
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
          label: const Text(
            '¡Confirmado! - Toca para cambiar',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
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
        label: const Text(
          'Tal vez - Toca para cambiar',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
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
              const Text(
                '¿Vas a ir a esta rodada?',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              ListTile(
                leading: const Icon(
                  Icons.check_circle,
                  color: Colors.green,
                  size: 32,
                ),
                title: const Text('Sí, voy confirmado'),
                subtitle: const Text('Definitivamente asistiré'),
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
                title: const Text('Tal vez voy'),
                subtitle: const Text('No estoy seguro/a todavía'),
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
              const Text(
                'Cambiar estado de asistencia',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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
                  title: const Text('Confirmar asistencia'),
                  subtitle: const Text('Definitivamente voy'),
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
                  title: const Text('Tal vez voy'),
                  subtitle: const Text('No estoy seguro/a'),
                  onTap: () {
                    Navigator.pop(context);
                    _changeToMaybe(context, provider);
                  },
                ),

              const Divider(),

              // Siempre mostrar cancelar
              ListTile(
                leading: const Icon(Icons.cancel, color: Colors.red, size: 32),
                title: const Text('Cancelar asistencia'),
                subtitle: const Text('Ya no voy a ir'),
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
    final success = await provider.joinRide(ride.id, maybe: false);

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            success
                ? '✅ Asistencia confirmada'
                : '❌ ${provider.error ?? "Error al confirmar"}',
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
    final success = await provider.joinRide(ride.id, maybe: true);

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            success
                ? '🤔 Marcado como "Tal vez"'
                : '❌ ${provider.error ?? "Error al actualizar"}',
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
    // Confirmar cancelación
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancelar asistencia'),
        content: const Text(
          '¿Estás seguro de que ya no vas a asistir a esta rodada?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('No'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Sí, cancelar'),
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
                ? '👋 Asistencia cancelada'
                : '❌ ${provider.error ?? "Error al cancelar"}',
          ),
          backgroundColor: success ? Colors.grey : Colors.red,
        ),
      );
    }
  }
}
