import 'package:flutter/material.dart';

/// RefreshIndicator estilizado con los colores de Biux
class BiuxRefreshIndicator extends StatelessWidget {
  final Widget child;
  final Future<void> Function() onRefresh;
  final Color? color;
  final Color? backgroundColor;

  const BiuxRefreshIndicator({
    super.key,
    required this.child,
    required this.onRefresh,
    this.color,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return RefreshIndicator(
      onRefresh: onRefresh,
      color: color ?? const Color(0xFF16242D),
      backgroundColor:
          backgroundColor ?? (isDark ? const Color(0xFF1E2A32) : Colors.white),
      strokeWidth: 2.5,
      displacement: 40,
      child: child,
    );
  }
}
