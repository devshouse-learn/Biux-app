import 'package:flutter/material.dart';

/// Widget de avatar de usuario con manejo seguro de userName vacío
class UserAvatar extends StatelessWidget {
  final String? photoUrl;
  final String userName;
  final double radius;
  final Color? backgroundColor;
  final Color? textColor;

  const UserAvatar({
    super.key,
    this.photoUrl,
    required this.userName,
    this.radius = 20,
    this.backgroundColor,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: radius,
      backgroundColor: backgroundColor,
      backgroundImage: photoUrl != null ? NetworkImage(photoUrl!) : null,
      child: photoUrl == null
          ? Text(
              _getInitials(userName),
              style: TextStyle(
                color: textColor ?? Colors.white,
                fontSize: radius * 0.6,
                fontWeight: FontWeight.bold,
              ),
            )
          : null,
    );
  }

  /// Obtiene las iniciales del nombre de usuario de forma segura
  String _getInitials(String name) {
    if (name.isEmpty) return '?';

    final parts = name.trim().split(' ');

    if (parts.length >= 2) {
      // Si tiene nombre y apellido, tomar primera letra de cada uno
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    } else {
      // Si solo tiene un nombre, tomar primera letra
      return name[0].toUpperCase();
    }
  }
}

/// Extension para usar UserAvatar fácilmente
extension UserAvatarExtension on String {
  /// Crea un UserAvatar con este string como userName
  Widget toAvatar({
    String? photoUrl,
    double radius = 20,
    Color? backgroundColor,
    Color? textColor,
  }) {
    return UserAvatar(
      userName: this,
      photoUrl: photoUrl,
      radius: radius,
      backgroundColor: backgroundColor,
      textColor: textColor,
    );
  }
}
