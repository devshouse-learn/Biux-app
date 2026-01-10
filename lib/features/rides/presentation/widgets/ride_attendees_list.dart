import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../users/domain/repositories/user_repository.dart';
import '../../../users/domain/entities/user_entity.dart';
import 'package:go_router/go_router.dart';

/// Widget que muestra la lista de asistentes a una rodada
/// Obtiene los datos completos de cada usuario desde Firestore
class RideAttendeesList extends StatelessWidget {
  final List<String> confirmedIds;
  final List<String> maybeIds;
  final String rideId;

  const RideAttendeesList({
    Key? key,
    required this.confirmedIds,
    required this.maybeIds,
    required this.rideId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (confirmedIds.isEmpty && maybeIds.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32.0),
          child: Text(
            'Aún no hay asistentes confirmados',
            style: TextStyle(color: Colors.grey, fontSize: 16),
          ),
        ),
      );
    }

    return ListView(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: [
        if (confirmedIds.isNotEmpty) ...[
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              'Confirmados',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          ...confirmedIds.map(
            (userId) => _AttendeeCard(
              userId: userId,
              status: 'confirmed',
              rideId: rideId,
            ),
          ),
        ],
        if (maybeIds.isNotEmpty) ...[
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              'Tal vez',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          ...maybeIds.map(
            (userId) =>
                _AttendeeCard(userId: userId, status: 'maybe', rideId: rideId),
          ),
        ],
      ],
    );
  }
}

/// Tarjeta individual de asistente
class _AttendeeCard extends StatelessWidget {
  final String userId;
  final String status;
  final String rideId;

  const _AttendeeCard({
    required this.userId,
    required this.status,
    required this.rideId,
  });

  @override
  Widget build(BuildContext context) {
    final userRepository = Provider.of<UserRepository>(context, listen: false);

    return FutureBuilder<UserEntity>(
      future: userRepository.getUserById(userId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const ListTile(
            leading: CircleAvatar(
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
            title: Text('Cargando...'),
          );
        }

        if (snapshot.hasError || !snapshot.hasData) {
          return ListTile(
            leading: CircleAvatar(child: Text(_getInitials(userId))),
            title: Text(userId),
            subtitle: const Text('Error al cargar datos'),
            trailing: _getStatusIcon(),
          );
        }

        final user = snapshot.data!;

        return ListTile(
          leading: CircleAvatar(
            backgroundImage: user.photo.isNotEmpty
                ? NetworkImage(user.photo)
                : null,
            child: user.photo.isEmpty
                ? Text(_getInitials(user.userName))
                : null,
          ),
          title: Text(
            user.fullName.isNotEmpty ? user.fullName : user.userName,
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
          subtitle: user.fullName.isNotEmpty && user.userName.isNotEmpty
              ? Text('@${user.userName}')
              : null,
          trailing: _getStatusIcon(),
          onTap: () {
            // Navegar al perfil del usuario usando el ID correcto
            context.push('/users/${user.id}');
          },
        );
      },
    );
  }

  Widget _getStatusIcon() {
    if (status == 'confirmed') {
      return const Icon(Icons.check_circle, color: Colors.green, size: 20);
    } else {
      return const Icon(Icons.help_outline, color: Colors.orange, size: 20);
    }
  }

  String _getInitials(String name) {
    if (name.isEmpty) return '?';
    final parts = name.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name[0].toUpperCase();
  }
}
