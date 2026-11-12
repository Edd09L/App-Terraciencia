import 'dart:math';
import 'package:flutter/material.dart';
import '../models/app_colors.dart';

/// Pintor que dibuja los anillos orbitales concéntricos alrededor de Noosféris.
///
/// Características:
/// - 3 o 4 elipses/círculos concéntricos sutiles, centrados en la posición de Noosféris.
/// - Cada anillo tiene un trazado de puntos o línea muy tenue para simular órbitas reales.
/// - Efecto de brillo (glow) suave en cada anillo con color cósmico.
/// - `breathValue` (0.0–1.0) permite una ligera pulsación de opacidad.
class OrbitalRingsPainter extends CustomPainter {
  final Offset center;        // Posición central de Noosféris en el lienzo
  final double breathValue;   // Pulsación de animación (0.0 → 1.0)
  final double dimFactor;     // Atenuación de opacidad global

  /// Radios de las 4 órbitas (en píxeles)
  final List<double> orbitalRadii;

  OrbitalRingsPainter({
    required this.center,
    required this.orbitalRadii,
    this.breathValue = 0.5,
    this.dimFactor = 1.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Pulsación sutil: ±3% de opacidad
    final double pulseOpacity = 0.5 + 0.5 * sin(breathValue * 2 * pi);

    // Colores de cada órbita con la paleta oficial
    final List<Color> ringColors = [
      AppColors.azulPetroleo,
      AppColors.violetaOscuro,
      AppColors.mostazaDorado,
      AppColors.magentaOscuro,
    ];

    for (int i = 0; i < orbitalRadii.length; i++) {
      final double r = orbitalRadii[i];
      final Color baseColor = ringColors[i % ringColors.length];

      // ── 1. Capa GLOW (halo difuminado) ─────────────────────────────
      final glowPaint = Paint()
        ..color = baseColor.withValues(alpha: 0.10 * pulseOpacity * dimFactor)
        ..strokeWidth = 14.0
        ..style = PaintingStyle.stroke
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8.0);

      canvas.drawCircle(center, r, glowPaint);

      // ── 2. Línea de órbita (fina y semitransparente) ────────────────
      final orbitPaint = Paint()
        ..color = baseColor.withValues(alpha: 0.28 * pulseOpacity * dimFactor)
        ..strokeWidth = 1.2
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round;

      // Dibujamos como segmentos cortos (punteado muy fino) para efecto orbital
      _drawDottedCircle(canvas, center, r, orbitPaint);
    }
  }

  /// Dibuja un círculo como serie de arcos cortos (efecto de línea orbital punteada).
  void _drawDottedCircle(
      Canvas canvas, Offset center, double radius, Paint paint) {
    const int segments = 120;       // Número de puntos en el círculo
    const double dashFraction = 0.55; // Fracción de cada segmento pintada

    const double segmentAngle = (2 * pi) / segments;

    for (int j = 0; j < segments; j++) {
      final double startAngle = j * segmentAngle;
      const double sweepAngle = segmentAngle * dashFraction;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle,
        false,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant OrbitalRingsPainter oldDelegate) {
    return oldDelegate.breathValue != breathValue ||
        oldDelegate.center != center ||
        oldDelegate.dimFactor != dimFactor;
  }
}
