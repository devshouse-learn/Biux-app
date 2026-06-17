import 'package:flutter/material.dart';
import 'package:biux/core/design_system/color_tokens.dart';

/// Widget personalizado que dibuja un icono minimalista de 3 ciclistas en transporte público
class GroupsIcon extends StatelessWidget {
  final double size;
  final Color color;

  const GroupsIcon({
    Key? key,
    this.size = 24,
    this.color = ColorTokens.primary30,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(size, size),
      painter: GroupsIconPainter(color),
    );
  }
}

class GroupsIconPainter extends CustomPainter {
  final Color color;

  GroupsIconPainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final scale = size.width / 24;

    // Pintura para las personas de atrás (más transparentes)
    final backPaint = Paint()
      ..color = color.withOpacity(0.5)
      ..style = PaintingStyle.fill;

    // Pintura para la persona adelante (opaca)
    final frontPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    // PERSONA IZQUIERDA ATRÁS
    _drawPerson(canvas, backPaint, 5 * scale, 12 * scale, 1.2);

    // PERSONA DERECHA ATRÁS
    _drawPerson(canvas, backPaint, 19 * scale, 12 * scale, 1.2);

    // PERSONA ADELANTE (centro, más grande)
    _drawPerson(canvas, frontPaint, 12 * scale, 7 * scale, 1.6);
  }

  void _drawPerson(
    Canvas canvas,
    Paint paint,
    double centerX,
    double centerY,
    double scale,
  ) {
    // CABEZA (círculo AÚN MÁS GRANDE)
    canvas.drawCircle(
      Offset(centerX, centerY - 3.8 * scale),
      2.2 * scale,
      paint,
    );

    // CUERPO (forma de trapecio/hombros redondeados - AÚN MÁS GRANDE)
    final path = Path();

    // Punto inicial: izquierda arriba (hombros)
    path.moveTo(centerX - 2.6 * scale, centerY - 0.8 * scale);

    // Línea diagonal izquierda hacia abajo-afuera
    path.lineTo(centerX - 4.0 * scale, centerY + 3.5 * scale);

    // Línea inferior (base ancha)
    path.lineTo(centerX + 4.0 * scale, centerY + 3.5 * scale);

    // Línea diagonal derecha hacia arriba-adentro
    path.lineTo(centerX + 2.6 * scale, centerY - 0.8 * scale);

    // Curva redondeada en la parte superior (hombros)
    path.quadraticBezierTo(
      centerX,
      centerY - 2.0 * scale,
      centerX - 2.6 * scale,
      centerY - 0.8 * scale,
    );

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(GroupsIconPainter oldDelegate) {
    return oldDelegate.color != color;
  }
}
