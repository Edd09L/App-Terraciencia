import 'dart:math';
import 'package:flutter/material.dart';
import '../models/app_colors.dart';

/// Pintor que dibuja 3 elipses horizontales concéntricas muy sutiles
/// centradas en Noosféris, usadas como guías estéticas de profundidad
/// en el layout de zigzag horizontal del Mapa Estelar.
///
/// Características:
/// - 3 elipses con semiejes horizontales progresivamente más anchos.
/// - Efecto de halo difuminado (glow) suave por elipse.
/// - Pulsación lenta sincronizada con `breathValue`.
class ZigzagOrbitsPainter extends CustomPainter {
  /// Centro de Noosféris en el lienzo (canvas completo del scroll)
  final Offset center;

  /// Factor de animación de pulsación (0.0 → 1.0)
  final double breathValue;

  /// Atenuación de opacidad global (1.0 = normal, < 1.0 = atenuado)
  final double dimFactor;

  ZigzagOrbitsPainter({
    required this.center,
    this.breathValue = 0.5,
    this.dimFactor = 1.0,
  });

  /// Semiejes de las 3 elipses [horizontal, vertical] en píxeles
  static const List<List<double>> _ellipses = [
    [540.0, 110.0],  // Elipse interior  — abarca Kinetos y Vitalia (órbita interna)
    [980.0, 175.0],  // Elipse media     — abarca Cíberon y Simbios (órbita intermedia)
    [1420.0, 230.0], // Elipse exterior  — enmarca Prisma y Titan-Q (extremos)
  ];

  /// Colores de cada elipse (interior → exterior) según la paleta institucional
  static const List<Color> _colors = [
    AppColors.azulPetroleo,  // Azul Petróleo
    AppColors.violetaOscuro, // Violeta Oscuro
    AppColors.mostazaDorado, // Mostaza / Dorado
  ];

  @override
  void paint(Canvas canvas, Size size) {
    // Modulación de opacidad con pulsación suave ±15%
    final double pulse = 0.85 + 0.15 * sin(breathValue * 2 * pi);

    for (int i = 0; i < _ellipses.length; i++) {
      final double rx = _ellipses[i][0]; // Semieje horizontal
      final double ry = _ellipses[i][1]; // Semieje vertical
      final Color color = _colors[i % _colors.length];
      final Rect rect = Rect.fromCenter(
        center: center,
        width: rx * 2,
        height: ry * 2,
      );

      // ── 1. Capa Glow muy sutil y difuminada (halo ambiental) ───────
      final glowPaint = Paint()
        ..color = color.withValues(alpha: 0.08 * pulse * dimFactor)
        ..strokeWidth = 20.0
        ..style = PaintingStyle.stroke
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12.0);
      canvas.drawOval(rect, glowPaint);

      // ── 2. Línea orbital curva punteada (Dashed Curved Lines) ───────
      _drawDottedEllipse(canvas, rect, color, pulse);
    }
  }

  /// Dibuja la elipse como arcos cortos (efecto orbital punteado sutil).
  void _drawDottedEllipse(
      Canvas canvas, Rect rect, Color color, double pulse) {
    const int segments = 90;
    const double dashFraction = 0.50; // 50% pintado, 50% hueco

    const double segAngle = (2 * pi) / segments;

    final orbitPaint = Paint()
      ..color = color.withValues(alpha: 0.22 * pulse * dimFactor)
      ..strokeWidth = 1.1
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    for (int j = 0; j < segments; j++) {
      final double startAngle = j * segAngle;
      const double sweepAngle = segAngle * dashFraction;
      canvas.drawArc(rect, startAngle, sweepAngle, false, orbitPaint);
    }
  }

  @override
  bool shouldRepaint(covariant ZigzagOrbitsPainter oldDelegate) {
    return oldDelegate.breathValue != breathValue ||
        oldDelegate.center != center ||
        oldDelegate.dimFactor != dimFactor;
  }
}
