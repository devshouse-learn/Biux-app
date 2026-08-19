import 'package:flutter/material.dart';
import 'package:biux/core/design_system/color_tokens.dart';

/// Widget de carga estandarizado para toda la app.
/// Proporciona consistencia visual en loading states.
class BiuxLoadingIndicator extends StatelessWidget {
  /// Tamaño del indicador. Por defecto: medium (50px)
  final LoadingSize size;

  /// Color del indicador. Por defecto: primary
  final Color? color;

  /// Grosor de la línea del indicador
  final double strokeWidth;

  /// Mensaje de texto debajo del indicador (opcional)
  final String? message;

  /// Centrar en pantalla completa
  final bool fullScreen;

  const BiuxLoadingIndicator({
    Key? key,
    this.size = LoadingSize.medium,
    this.color,
    this.strokeWidth = 4.0,
    this.message,
    this.fullScreen = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final indicator = Column(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: size.size,
          height: size.size,
          child: CircularProgressIndicator(
            color: color ?? ColorTokens.primary30,
            strokeWidth: strokeWidth,
          ),
        ),
        if (message != null) ...[
          const SizedBox(height: 12),
          Text(
            message!,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
            textAlign: TextAlign.center,
          ),
        ],
      ],
    );

    if (fullScreen) {
      return Center(child: indicator);
    }

    return indicator;
  }
}

/// Tamaños predefinidos para el indicador de carga
enum LoadingSize {
  small(20),
  medium(50),
  large(80);

  final double size;
  const LoadingSize(this.size);
}

/// Widget para mostrar un indicador de carga en un Centro con altura flexible
class CenterLoadingIndicator extends StatelessWidget {
  final LoadingSize size;
  final Color? color;
  final double strokeWidth;
  final String? message;

  const CenterLoadingIndicator({
    Key? key,
    this.size = LoadingSize.medium,
    this.color,
    this.strokeWidth = 4.0,
    this.message,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: BiuxLoadingIndicator(
        size: size,
        color: color,
        strokeWidth: strokeWidth,
        message: message,
      ),
    );
  }
}
