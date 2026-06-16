import 'package:flutter/material.dart';

/// Icono de avión de papel 3D con punta dirigida hacia la diagonal derecha
class PaperPlaneIcon extends StatelessWidget {
  final double size;
  final Color? color;
  final bool animated;

  const PaperPlaneIcon({
    Key? key,
    this.size = 24.0,
    this.color,
    this.animated = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final iconColor = color ?? Theme.of(context).colorScheme.primary;

    if (animated) {
      return TweenAnimationBuilder<double>(
        tween: Tween<double>(begin: 0, end: 1),
        duration: const Duration(milliseconds: 800),
        curve: Curves.easeInOut,
        builder: (context, value, child) {
          return Transform.translate(
            offset: Offset(value * 4, -value * 4),
            child: Opacity(
              opacity: 1 - (value * 0.3),
              child: CustomPaint(
                size: Size(size, size),
                painter: _PaperPlanePainter(
                  color: iconColor,
                  rotation: value * 0.3,
                ),
              ),
            ),
          );
        },
      );
    }

    return CustomPaint(
      size: Size(size, size),
      painter: _PaperPlanePainter(color: iconColor),
    );
  }
}

class _PaperPlanePainter extends CustomPainter {
  final Color color;
  final double rotation;

  _PaperPlanePainter({required this.color, this.rotation = 0});

  @override
  void paint(Canvas canvas, Size size) {
    canvas.translate(size.width / 2, size.height / 2);
    canvas.rotate(rotation * 3.14159265359 / 180);
    canvas.translate(-size.width / 2, -size.height / 2);

    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final shadowPaint = Paint()
      ..color = color.withOpacity(0.2)
      ..style = PaintingStyle.fill;

    final darkPaint = Paint()
      ..color = color.withOpacity(0.7)
      ..style = PaintingStyle.fill;

    final accentPaint = Paint()
      ..color = color.withOpacity(0.5)
      ..style = PaintingStyle.fill;

    final w = size.width;
    final h = size.height;

    // Sombra trasera (debajo de todo)
    final shadowPath = Path();
    shadowPath.moveTo(w * 0.5, h * 0.2);
    shadowPath.lineTo(w * 0.35, h * 0.5);
    shadowPath.lineTo(w * 0.4, h * 0.75);
    shadowPath.close();
    canvas.drawPath(shadowPath, shadowPaint);

    // Panel frontal principal (lado izquierdo)
    // Representa la cara superior del avión
    final mainPath = Path();
    mainPath.moveTo(w * 0.5, h * 0.15); // Punta del avión ↗️
    mainPath.lineTo(w * 0.15, h * 0.35); // Ala trasera izquierda
    mainPath.lineTo(w * 0.2, h * 0.75); // Cola izquierda
    mainPath.lineTo(w * 0.5, h * 0.6); // Centro trasero
    mainPath.close();
    canvas.drawPath(mainPath, paint);

    // Panel derecho (lado derecho con sombra)
    final rightPath = Path();
    rightPath.moveTo(w * 0.5, h * 0.15); // Punta del avión
    rightPath.lineTo(w * 0.85, h * 0.35); // Ala trasera derecha
    rightPath.lineTo(w * 0.8, h * 0.75); // Cola derecha
    rightPath.lineTo(w * 0.5, h * 0.6); // Centro trasero
    rightPath.close();
    canvas.drawPath(rightPath, darkPaint);

    // Pliegue central vertical (profundidad)
    final foldPaint = Paint()
      ..color = color.withOpacity(0.4)
      ..strokeWidth = w * 0.04
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawLine(
      Offset(w * 0.5, h * 0.15),
      Offset(w * 0.5, h * 0.6),
      foldPaint,
    );

    // Pliegue horizontal (para separar alas)
    canvas.drawLine(
      Offset(w * 0.15, h * 0.35),
      Offset(w * 0.85, h * 0.35),
      foldPaint,
    );

    // Ala inferior izquierda (triángulo con curvatura)
    final bottomLeftWing = Path();
    bottomLeftWing.moveTo(w * 0.2, h * 0.75);
    bottomLeftWing.lineTo(w * 0.05, h * 0.55);
    bottomLeftWing.quadraticBezierTo(w * 0.1, h * 0.7, w * 0.2, h * 0.75);
    canvas.drawPath(bottomLeftWing, accentPaint);

    // Ala inferior derecha (triángulo con curvatura)
    final bottomRightWing = Path();
    bottomRightWing.moveTo(w * 0.8, h * 0.75);
    bottomRightWing.lineTo(w * 0.95, h * 0.55);
    bottomRightWing.quadraticBezierTo(w * 0.9, h * 0.7, w * 0.8, h * 0.75);
    canvas.drawPath(bottomRightWing, accentPaint);

    // Punto de luz/brillo en la punta
    final highlightPaint = Paint()
      ..color = Colors.white.withOpacity(0.5)
      ..style = PaintingStyle.fill;

    canvas.drawCircle(Offset(w * 0.5, h * 0.18), w * 0.04, highlightPaint);

    // Pequeño triángulo de profundidad en la punta
    final tipDepth = Path();
    tipDepth.moveTo(w * 0.5, h * 0.15);
    tipDepth.lineTo(w * 0.48, h * 0.2);
    tipDepth.lineTo(w * 0.52, h * 0.2);
    tipDepth.close();
    canvas.drawPath(tipDepth, darkPaint);
  }

  @override
  bool shouldRepaint(_PaperPlanePainter oldDelegate) {
    return oldDelegate.color != color || oldDelegate.rotation != rotation;
  }
}
