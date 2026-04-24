import 'package:flutter/material.dart';

/// Badge de verificación para perfiles de usuario
class VerifiedBadge extends StatelessWidget {
  final double size;
  final bool isVerified;

  const VerifiedBadge({super.key, this.size = 18, this.isVerified = true});

  @override
  Widget build(BuildContext context) {
    if (!isVerified) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.only(left: 4),
      child: Icon(
        Icons.verified_rounded,
        size: size,
        color: const Color(0xFF1DA1F2),
      ),
    );
  }
}
