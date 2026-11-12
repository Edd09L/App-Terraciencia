import 'dart:math';
import 'package:flutter/material.dart';

/// Pintor encargado de dibujar las líneas de constelación animadas entre planetas.
///
/// Características:
/// - Conexiones lineales secuenciales (1-2, 2-3, 3-4, 4-5, 5-6).
/// - Línea discontinua (punteada/segmentada).
/// - Efecto de "flujo de energía" (desplazamiento de los guiones) utilizando un `dashPhase`.
/// - Doble trazado: una línea base difuminada (glow) y una línea frontal de alto contraste.
class ConstellationPainter extends CustomPainter {
  final List<Offset> points;    // Posiciones de los planetas en el lienzo
  final double dashPhase;        // Fase de la animación de flujo (0.0 a 1.0)
  final double dimFactor;        // Atenuación de opacidad (0.5 si hay zoom)

  ConstellationPainter({
    required this.points,
    required this.dashPhase,
    this.dimFactor = 1.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (points.length < 2) return;

    // Pintar cada segmento de la ruta
    for (int i = 0; i < points.length - 1; i++) {
      final p1 = points[i];
      final p2 = points[i + 1];

      // Definir los colores para el gradiente del segmento (del color del planeta i al i+1)
      // Usaremos un color neutro brillante si las posiciones no están completamente listas.
      _drawDashedLine(canvas, p1, p2);
    }
  }

  /// Dibuja una línea discontinua con animación de flujo y efecto de brillo (glow).
  void _drawDashedLine(Canvas canvas, Offset start, Offset end) {
    final double dx = end.dx - start.dx;
    final double dy = end.dy - start.dy;
    final double distance = sqrt(dx * dx + dy * dy);

    // Si la distancia es insignificante, no dibujamos nada
    if (distance < 1.0) return;

    final Offset direction = Offset(dx / distance, dy / distance);

    const double dashLength = 12.0;
    const double gapLength = 8.0;
    const double patternPeriod = dashLength + gapLength; // 20.0

    // Desplazamiento inicial basado en la fase de la animación (flujo cósmico)
    final double startOffset = (dashPhase * patternPeriod) % patternPeriod;

    // 1. Pintar el brillo de fondo (Glow)
    final glowPaint = Paint()
      ..color = const Color(0xFF64B5F6).withOpacity(0.18 * dimFactor)
      ..strokeWidth = 6.0
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    _paintSegmented(canvas, start, end, direction, distance, patternPeriod, dashLength, startOffset, glowPaint);

    // 2. Pintar la línea frontal de alto contraste (Blanco/Celeste brillante)
    final linePaint = Paint()
      ..color = const Color(0xFFE3F2FD).withOpacity(0.85 * dimFactor)
      ..strokeWidth = 3.0
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    _paintSegmented(canvas, start, end, direction, distance, patternPeriod, dashLength, startOffset, linePaint);
  }

  /// Método auxiliar que calcula y dibuja los trazos individuales de la línea segmentada.
  void _paintSegmented(
    Canvas canvas,
    Offset start,
    Offset end,
    Offset direction,
    double distance,
    double patternPeriod,
    double dashLength,
    double startOffset,
    Paint paint,
  ) {
    double currentDistance = -startOffset;

    while (currentDistance < distance) {
      if (currentDistance + dashLength > 0) {
        final double segmentStartDist = max(0.0, currentDistance);
        final double segmentEndDist = min(distance, currentDistance + dashLength);

        final Offset pStart = start + direction * segmentStartDist;
        final Offset pEnd = start + direction * segmentEndDist;

        canvas.drawLine(pStart, pEnd, paint);
      }
      currentDistance += patternPeriod;
    }
  }

  @override
  bool shouldRepaint(covariant ConstellationPainter oldDelegate) {
    return oldDelegate.dashPhase != dashPhase ||
        oldDelegate.points != points ||
        oldDelegate.dimFactor != dimFactor;
  }
}
