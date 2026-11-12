import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/ai_evaluation_service.dart';

/// BottomSheet de feedback formativo que se muestra cuando el puntaje es < 90.
///
/// Contiene:
/// - Resumen del puntaje total con desglose (quiz + mapa mental).
/// - Feedback formativo generado por el servicio de IA.
/// - Retroalimentación detallada por rama del mapa mental.
/// - Botón para reintentar las Fases 2 y 3.
///
/// Diseño DUA: retroalimentación formativa y motivacional.
class FeedbackBottomSheet extends StatelessWidget {
  /// Resultado de la evaluación del servicio de IA.
  final EvaluationResult result;

  /// Color temático del planeta.
  final Color themeColor;

  /// Callback al presionar "Intentar de Nuevo".
  final VoidCallback onRetry;

  const FeedbackBottomSheet({
    super.key,
    required this.result,
    required this.themeColor,
    required this.onRetry,
  });

  /// Muestra el BottomSheet como modal.
  static void show({
    required BuildContext context,
    required EvaluationResult result,
    required Color themeColor,
    required VoidCallback onRetry,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withOpacity(0.85),
      builder: (context) => FeedbackBottomSheet(
        result: result,
        themeColor: themeColor,
        onRetry: onRetry,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.75,
      minChildSize: 0.5,
      maxChildSize: 0.92,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: const Color(0xFF0F0F0F),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
            border: Border(
              top: BorderSide(color: themeColor.withOpacity(0.4), width: 3),
              left: BorderSide(color: themeColor.withOpacity(0.2), width: 1),
              right: BorderSide(color: themeColor.withOpacity(0.2), width: 1),
            ),
          ),
          child: ListView(
            controller: scrollController,
            padding: const EdgeInsets.all(24),
            children: [
              // ── Handle de arrastre ──────────────────────────────────────
              Center(
                child: Container(
                  width: 48,
                  height: 5,
                  decoration: BoxDecoration(
                    color: Colors.white24,
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // ── Encabezado ──────────────────────────────────────────────
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.orangeAccent.withOpacity(0.15),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.lightbulb_rounded,
                      color: Colors.orangeAccent,
                      size: 32,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Retroalimentación Formativa',
                          style: GoogleFonts.fredoka(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '¡Sigue intentándolo, vas por buen camino!',
                          style: GoogleFonts.fredoka(
                            color: Colors.white54,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // ── Resumen de Puntaje ──────────────────────────────────────
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.03),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.white10),
                ),
                child: Column(
                  children: [
                    // Puntaje total
                    Text(
                      '${result.totalScore.toInt()} / 100',
                      style: GoogleFonts.fredoka(
                        fontSize: 48,
                        fontWeight: FontWeight.w900,
                        color: _getScoreColor(result.totalScore),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Puntos totales',
                      style: GoogleFonts.fredoka(
                        color: Colors.white38,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Barra de progreso
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: LinearProgressIndicator(
                        value: result.totalScore / 100.0,
                        minHeight: 12,
                        backgroundColor: Colors.white10,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          _getScoreColor(result.totalScore),
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Align(
                      alignment: Alignment.centerRight,
                      child: Text(
                        'Necesitas 90 pts para desbloquear la insignia',
                        style: GoogleFonts.fredoka(
                          color: Colors.white30,
                          fontSize: 11,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Desglose
                    Row(
                      children: [
                        Expanded(
                          child: _buildScoreDetail(
                            'Quiz (50%)',
                            result.quizWeightedScore,
                            Icons.quiz_rounded,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildScoreDetail(
                            'Mapa Mental (50%)',
                            result.mindMapWeightedScore,
                            Icons.hub_rounded,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // ── Feedback Principal del Servicio IA ──────────────────────
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: themeColor.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: themeColor.withOpacity(0.25),
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.smart_toy_rounded,
                        color: themeColor, size: 24),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        result.feedbackMessage,
                        style: GoogleFonts.fredoka(
                          color: Colors.white70,
                          fontSize: 15,
                          height: 1.5,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // ── Feedback Detallado por Rama ─────────────────────────────
              if (result.detailedFeedback.isNotEmpty) ...[
                Text(
                  'Detalle por Rama',
                  style: GoogleFonts.fredoka(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 12),
                ...result.detailedFeedback.map((feedback) {
                  final bool isCorrect = feedback.startsWith('✅');
                  final bool isPartial = feedback.startsWith('🔶');
                  final Color feedbackColor = isCorrect
                      ? Colors.greenAccent
                      : isPartial
                          ? Colors.orangeAccent
                          : Colors.redAccent;

                  return Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: feedbackColor.withOpacity(0.06),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: feedbackColor.withOpacity(0.2),
                      ),
                    ),
                    child: Text(
                      feedback,
                      style: GoogleFonts.fredoka(
                        color: feedbackColor.withOpacity(0.9),
                        fontSize: 14,
                        height: 1.4,
                      ),
                    ),
                  );
                }),
                const SizedBox(height: 8),
              ],

              // ── Botón Intentar de Nuevo ─────────────────────────────────
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.of(context).pop();
                    onRetry();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: themeColor,
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                    elevation: 4,
                  ),
                  icon: const Icon(Icons.refresh_rounded, size: 24),
                  label: Text(
                    'INTENTAR DE NUEVO',
                    style: GoogleFonts.fredoka(
                      fontWeight: FontWeight.w900,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  Widget _buildScoreDetail(String label, double score, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.03),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        children: [
          Icon(icon, color: themeColor, size: 20),
          const SizedBox(height: 6),
          Text(
            '${score.toInt()} pts',
            style: GoogleFonts.fredoka(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            textAlign: TextAlign.center,
            style: GoogleFonts.fredoka(
              color: Colors.white38,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }

  Color _getScoreColor(double score) {
    if (score >= 90) return Colors.greenAccent;
    if (score >= 70) return Colors.amber;
    if (score >= 50) return Colors.orangeAccent;
    return Colors.redAccent;
  }
}
