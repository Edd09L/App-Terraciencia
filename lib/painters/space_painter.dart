import 'dart:math';
import 'dart:ui' as ui;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// Modelo interno para una estrella.
class SpaceStar {
  final double xRatio; // Posición X relativa (0.0 a 1.0)
  final double yRatio; // Posición Y relativa (0.0 a 1.0)
  final double size;   // Tamaño en píxeles (1, 2 o 3)
  final double phase;  // Desfase de fase para el brillo

  const SpaceStar(this.xRatio, this.yRatio, this.size, this.phase);
}

/// Pintor encargado de renderizar las estrellas del espacio profundo.
///
/// Implementa:
/// - 700 estrellas deterministas generadas con semilla fija.
/// - 3 niveles de Parallax (pequeñas, medianas y grandes) según el movimiento del mouse.
/// - Animación lenta de opacidad ("respiración").
/// - Atenuación del brillo (dimming) cuando se interactúa con algún planeta.
class SpacePainter extends CustomPainter {
  final double breathValue; // Valor de la animación (0.0 a 1.0)
  final Offset mouseOffset; // Desplazamiento del cursor para el parallax
  final double dimFactor;   // Factor de atenuación de luz (1.0 normal, 0.5 atenuado)

  static List<SpaceStar>? _cachedStars;
  static const int _starCount = 700;

  SpacePainter({
    required this.breathValue,
    required this.mouseOffset,
    this.dimFactor = 1.0,
  });

  /// Genera las estrellas una sola vez de forma estática para ahorrar procesamiento.
  static List<SpaceStar> _getStars() {
    if (_cachedStars != null) return _cachedStars!;

    final random = Random(42768); // Semilla fija — nueva distribución más densa
    _cachedStars = List<SpaceStar>.generate(_starCount, (_) {
      final double rand = random.nextDouble();
      double size = 1.0;
      if (rand > 0.90) {
        size = 3.0; // 10% estrellas grandes (3px)
      } else if (rand > 0.62) {
        size = 2.0; // 28% estrellas medianas (2px)
      } // 62% estrellas pequeñas (1px) — máxima densidad de fondo

      return SpaceStar(
        random.nextDouble(),
        random.nextDouble(),
        size,
        random.nextDouble() * 2 * pi,
      );
    });
    return _cachedStars!;
  }

  @override
  void paint(Canvas canvas, Size size) {
    // 1. Fondo negro absoluto obligatorio
    canvas.drawRect(
      Offset.zero & size,
      Paint()..color = const Color(0xFF000000),
    );

    final stars = _getStars();

    // Dibujamos las estrellas agrupándolas por su tamaño/capa
    // Esto es muy óptimo porque reduce los cambios de estado en el Canvas.
    for (int starSize = 1; starSize <= 3; starSize++) {
      final layerStars = stars.where((s) => s.size == starSize).toList();
      if (layerStars.isEmpty) continue;

      // Definir la velocidad del Parallax para esta capa
      double parallaxFactor = 0.05; // Capa lejana (estrellas de 1px)
      if (starSize == 2) {
        parallaxFactor = 0.12; // Capa media (estrellas de 2px)
      } else if (starSize == 3) {
        parallaxFactor = 0.22; // Capa cercana (estrellas de 3px)
      }

      final points = Float32List(layerStars.length * 2);

      for (int i = 0; i < layerStars.length; i++) {
        final star = layerStars[i];

        // Calcular posición base
        double x = star.xRatio * size.width;
        double y = star.yRatio * size.height;

        // Aplicar desplazamiento parallax
        x += mouseOffset.dx * parallaxFactor;
        y += mouseOffset.dy * parallaxFactor;

        // Envoltura alrededor del lienzo para no perder estrellas en los bordes
        x = x % size.width;
        y = y % size.height;
        if (x < 0) x += size.width;
        if (y < 0) y += size.height;

        points[i * 2] = x;
        points[i * 2 + 1] = y;
      }

      // Animación de respiración lenta de la opacidad:
      // La opacidad base oscila entre 0.3 y 1.0.
      // Se le aplica el desfase de fase de cada capa para que luzca natural.
      final double layerPhase = starSize * 0.4;
      final double breathCycle = sin(breathValue * 2 * pi + layerPhase);
      
      // Mapear ciclo sinusoide [-1, 1] a opacidad [0.3, 1.0]
      double opacity = 0.3 + 0.7 * ((breathCycle + 1.0) / 2.0);
      
      // Aplicar atenuación si el usuario está enfocado en un planeta
      opacity = opacity * dimFactor;

      final paint = Paint()
        ..color = Colors.white.withOpacity(opacity.clamp(0.15, 1.0))
        ..strokeWidth = starSize.toDouble()
        ..strokeCap = StrokeCap.round;

      canvas.drawRawPoints(ui.PointMode.points, points, paint);
    }

    // 2. Pintar nebulosas decorativas muy suaves detrás de todo
    _paintNebulae(canvas, size);
  }

  void _paintNebulae(Canvas canvas, Size size) {
    final nebulaPaint = Paint()..blendMode = BlendMode.screen;

    // Nebulosa Cósmica Verde/Azul en la esquina
    final blueCenter = Offset(size.width * 0.75, size.height * 0.3);
    final blueRadius = size.width * 0.4;
    nebulaPaint.shader = RadialGradient(
      colors: [
        const Color(0xFF1E3C72).withOpacity(0.06 * dimFactor),
        Colors.transparent,
      ],
    ).createShader(Rect.fromCircle(center: blueCenter, radius: blueRadius));
    canvas.drawCircle(blueCenter, blueRadius, nebulaPaint);

    // Nebulosa Cósmica Púrpura
    final purpleCenter = Offset(size.width * 0.25, size.height * 0.7);
    final purpleRadius = size.width * 0.35;
    nebulaPaint.shader = RadialGradient(
      colors: [
        const Color(0xFF7B1FA2).withOpacity(0.04 * dimFactor),
        Colors.transparent,
      ],
    ).createShader(Rect.fromCircle(center: purpleCenter, radius: purpleRadius));
    canvas.drawCircle(purpleCenter, purpleRadius, nebulaPaint);
  }

  @override
  bool shouldRepaint(covariant SpacePainter oldDelegate) {
    return oldDelegate.breathValue != breathValue ||
        oldDelegate.mouseOffset != mouseOffset ||
        oldDelegate.dimFactor != dimFactor;
  }
}
