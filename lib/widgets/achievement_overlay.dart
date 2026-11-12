import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:math' as math;

/// Overlay de animación de logro para cuando el alumno obtiene >= 90 puntos.
///
/// Muestra:
/// - Partículas animadas de celebración.
/// - Ícono de trofeo con escala animada.
/// - Mensaje de felicitación con el puntaje.
/// - Botón para cerrar y volver.
class AchievementOverlay extends StatefulWidget {
  /// Puntaje total obtenido.
  final double score;

  /// Color temático del planeta.
  final Color themeColor;

  /// Nombre del tema completado.
  final String topicTitle;

  /// Callback al cerrar el overlay.
  final VoidCallback onDismiss;

  const AchievementOverlay({
    super.key,
    required this.score,
    required this.themeColor,
    required this.topicTitle,
    required this.onDismiss,
  });

  @override
  State<AchievementOverlay> createState() => _AchievementOverlayState();
}

class _AchievementOverlayState extends State<AchievementOverlay>
    with TickerProviderStateMixin {
  late AnimationController _scaleController;
  late AnimationController _particleController;
  late Animation<double> _scaleAnim;
  late Animation<double> _opacityAnim;

  @override
  void initState() {
    super.initState();

    _scaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _scaleAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.elasticOut),
    );
    _opacityAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _scaleController,
        curve: const Interval(0.0, 0.4, curve: Curves.easeIn),
      ),
    );

    _particleController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();

    _scaleController.forward();
  }

  @override
  void dispose() {
    _scaleController.dispose();
    _particleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _scaleController,
      builder: (context, _) {
        return Opacity(
          opacity: _opacityAnim.value.clamp(0.0, 1.0),
          child: Container(
            color: Colors.black.withOpacity(0.9),
            child: Stack(
              children: [
                // ── Partículas de celebración ──────────────────────────────
                ...List.generate(20, (index) {
                  return AnimatedBuilder(
                    animation: _particleController,
                    builder: (context, _) {
                      final random = math.Random(index);
                      final x = random.nextDouble() *
                          MediaQuery.of(context).size.width;
                      final startY =
                          -50.0 + (random.nextDouble() * -100);
                      final endY =
                          MediaQuery.of(context).size.height + 50;
                      final progress = (_particleController.value +
                              random.nextDouble()) %
                          1.0;
                      final currentY =
                          startY + (endY - startY) * progress;
                      final wobble =
                          math.sin(progress * math.pi * 4) * 30;

                      final colors = [
                        widget.themeColor,
                        Colors.amber,
                        Colors.greenAccent,
                        Colors.cyanAccent,
                        Colors.pinkAccent,
                        Colors.purpleAccent,
                      ];
                      final color = colors[index % colors.length];

                      return Positioned(
                        left: x + wobble,
                        top: currentY,
                        child: Container(
                          width: 6 + random.nextDouble() * 8,
                          height: 6 + random.nextDouble() * 8,
                          decoration: BoxDecoration(
                            color: color.withOpacity(0.7),
                            shape: index % 3 == 0
                                ? BoxShape.circle
                                : BoxShape.rectangle,
                            borderRadius: index % 3 != 0
                                ? BorderRadius.circular(2)
                                : null,
                          ),
                        ),
                      );
                    },
                  );
                }),

                // ── Contenido central ──────────────────────────────────────
                Center(
                  child: Transform.scale(
                    scale: _scaleAnim.value,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Trofeo con resplandor
                        Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: RadialGradient(
                              colors: [
                                widget.themeColor.withOpacity(0.3),
                                widget.themeColor.withOpacity(0.05),
                                Colors.transparent,
                              ],
                            ),
                          ),
                          child: Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: widget.themeColor.withOpacity(0.15),
                              border: Border.all(
                                color: widget.themeColor,
                                width: 3,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: widget.themeColor.withOpacity(0.4),
                                  blurRadius: 40,
                                  spreadRadius: 8,
                                ),
                              ],
                            ),
                            child: Icon(
                              Icons.emoji_events_rounded,
                              size: 80,
                              color: Colors.amber.shade300,
                            ),
                          ),
                        ),
                        const SizedBox(height: 32),

                        // Mensaje de felicitación
                        Text(
                          '🎉 ¡INSIGNIA DESBLOQUEADA!',
                          style: GoogleFonts.fredoka(
                            fontSize: 28,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                            letterSpacing: 1,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          widget.topicTitle,
                          textAlign: TextAlign.center,
                          style: GoogleFonts.fredoka(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: widget.themeColor,
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Puntaje
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 24, vertical: 12),
                          decoration: BoxDecoration(
                            color: Colors.greenAccent.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: Colors.greenAccent.withOpacity(0.5),
                            ),
                          ),
                          child: Text(
                            'Puntaje: ${widget.score.toInt()} / 100',
                            style: GoogleFonts.fredoka(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Colors.greenAccent,
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 40),
                          child: Text(
                            '¡Felicidades! Has demostrado un dominio excepcional '
                            'de este tema. Tu insignia ha sido agregada al álbum.',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.fredoka(
                              fontSize: 15,
                              color: Colors.white70,
                              height: 1.4,
                            ),
                          ),
                        ),
                        const SizedBox(height: 32),

                        // Botón de cierre
                        SizedBox(
                          width: 220,
                          height: 52,
                          child: ElevatedButton.icon(
                            onPressed: widget.onDismiss,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: widget.themeColor,
                              foregroundColor: Colors.black,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(18),
                              ),
                              elevation: 6,
                            ),
                            icon: const Icon(Icons.auto_awesome_rounded),
                            label: Text(
                              '¡GENIAL!',
                              style: GoogleFonts.fredoka(
                                fontWeight: FontWeight.w900,
                                fontSize: 18,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// Helper: AnimatedBuilder compatible con AnimationController.
class AnimatedBuilder extends AnimatedWidget {
  final Widget Function(BuildContext, Widget?) builder;

  const AnimatedBuilder({
    super.key,
    required Animation<double> animation,
    required this.builder,
  }) : super(listenable: animation);

  @override
  Widget build(BuildContext context) {
    return builder(context, null);
  }
}
