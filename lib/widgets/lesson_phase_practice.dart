import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/lesson_content.dart';

/// Widget de la Fase 2 — Practicar.
///
/// Micro-quiz interactivo con:
/// - Preguntas de opción múltiple con radio buttons.
/// - Feedback visual inmediato (✅/❌) al seleccionar una opción.
/// - Cálculo de puntuación en tiempo real visible en la parte superior.
/// - Animaciones suaves para transiciones.
///
/// Diseño DUA: múltiples formas de acción y expresión.
class LessonPhasePractice extends StatefulWidget {
  /// Lista de preguntas del quiz.
  final List<QuizQuestion> questions;

  /// Color temático del planeta.
  final Color themeColor;

  /// Factor de escala de texto (modo proyección).
  final double textScaleFactor;

  /// Callback que se ejecuta cuando el quiz se completa.
  /// Devuelve el puntaje total obtenido (0-100).
  final ValueChanged<double> onQuizCompleted;

  const LessonPhasePractice({
    super.key,
    required this.questions,
    required this.themeColor,
    this.textScaleFactor = 1.0,
    required this.onQuizCompleted,
  });

  @override
  State<LessonPhasePractice> createState() => _LessonPhasePracticeState();
}

class _LessonPhasePracticeState extends State<LessonPhasePractice>
    with SingleTickerProviderStateMixin {
  /// Respuesta seleccionada por pregunta (null = sin responder).
  late List<int?> _selectedAnswers;

  /// Si cada pregunta ya fue confirmada/respondida.
  late List<bool> _answeredQuestions;

  /// Puntaje acumulado del quiz.
  double _currentScore = 0.0;

  /// Puntaje máximo posible del quiz.
  late double _maxScore;

  /// Controlador del scroll para animar hacia la siguiente pregunta.
  final ScrollController _scrollController = ScrollController();

  /// Animación del puntaje.
  late AnimationController _scoreAnimController;
  late Animation<double> _scoreAnim;
  double _displayScore = 0.0;

  @override
  void initState() {
    super.initState();
    _selectedAnswers = List.filled(widget.questions.length, null);
    _answeredQuestions = List.filled(widget.questions.length, false);
    _maxScore = widget.questions.fold(0.0, (sum, q) => sum + q.points);

    _scoreAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _scoreAnim = Tween<double>(begin: 0, end: 0).animate(
      CurvedAnimation(parent: _scoreAnimController, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _scoreAnimController.dispose();
    super.dispose();
  }

  void _animateScoreTo(double newScore) {
    _scoreAnim = Tween<double>(begin: _displayScore, end: newScore).animate(
      CurvedAnimation(parent: _scoreAnimController, curve: Curves.easeOut),
    );
    _scoreAnimController.forward(from: 0).then((_) {
      _displayScore = newScore;
    });
  }

  void _submitAnswer(int questionIndex, int selectedOption) {
    if (_answeredQuestions[questionIndex]) return;

    setState(() {
      _selectedAnswers[questionIndex] = selectedOption;
      _answeredQuestions[questionIndex] = true;

      final question = widget.questions[questionIndex];
      if (selectedOption == question.correctIndex) {
        _currentScore += question.points;
      }

      _animateScoreTo(_currentScore);

      // Si todas están respondidas, notificar completado
      if (_answeredQuestions.every((a) => a)) {
        // Normalizar a escala 0-100
        final normalized =
            _maxScore > 0 ? (_currentScore / _maxScore) * 100.0 : 0.0;
        Future.delayed(const Duration(milliseconds: 600), () {
          widget.onQuizCompleted(normalized);
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final int answeredCount = _answeredQuestions.where((a) => a).length;
    final int totalQuestions = widget.questions.length;
    final double progress =
        totalQuestions > 0 ? answeredCount / totalQuestions : 0.0;

    return Column(
      children: [
        // ── Cabecera con puntaje en tiempo real ──────────────────────────
        Container(
          margin: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF0F0F0F),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: widget.themeColor.withOpacity(0.3),
              width: 1.5,
            ),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(Icons.quiz_rounded,
                          color: widget.themeColor, size: 22),
                      const SizedBox(width: 8),
                      Text(
                        'Micro-Quiz',
                        style: GoogleFonts.fredoka(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16 * widget.textScaleFactor,
                        ),
                      ),
                    ],
                  ),
                  AnimatedBuilder(
                    animation: _scoreAnimController,
                    builder: (context, child) {
                      return Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: widget.themeColor.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: widget.themeColor.withOpacity(0.4),
                          ),
                        ),
                        child: Text(
                          '${_scoreAnim.value.toInt()} / ${_maxScore.toInt()} pts',
                          style: GoogleFonts.fredoka(
                            color: widget.themeColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 14 * widget.textScaleFactor,
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
              const SizedBox(height: 10),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: progress,
                  minHeight: 8,
                  backgroundColor: Colors.white10,
                  valueColor:
                      AlwaysStoppedAnimation<Color>(widget.themeColor),
                ),
              ),
              const SizedBox(height: 6),
              Align(
                alignment: Alignment.centerRight,
                child: Text(
                  '$answeredCount de $totalQuestions respondidas',
                  style: GoogleFonts.fredoka(
                    color: Colors.white38,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
        ),

        // ── Lista de preguntas ───────────────────────────────────────────
        Expanded(
          child: ListView.builder(
            controller: _scrollController,
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
            itemCount: widget.questions.length,
            itemBuilder: (context, index) {
              return _buildQuestionCard(index);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildQuestionCard(int index) {
    final question = widget.questions[index];
    final bool isAnswered = _answeredQuestions[index];
    final int? selected = _selectedAnswers[index];
    final bool isCorrect = selected == question.correctIndex;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF0F0F0F),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isAnswered
              ? (isCorrect
                  ? Colors.greenAccent.withOpacity(0.6)
                  : Colors.redAccent.withOpacity(0.6))
              : widget.themeColor.withOpacity(0.15),
          width: isAnswered ? 2.5 : 1.5,
        ),
        boxShadow: isAnswered
            ? [
                BoxShadow(
                  color: (isCorrect ? Colors.greenAccent : Colors.redAccent)
                      .withOpacity(0.1),
                  blurRadius: 12,
                  spreadRadius: 1,
                ),
              ]
            : [],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Número de pregunta
            Row(
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: widget.themeColor.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'Pregunta ${index + 1}',
                    style: GoogleFonts.fredoka(
                      color: widget.themeColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 12 * widget.textScaleFactor,
                    ),
                  ),
                ),
                const Spacer(),
                Text(
                  '${question.points} pts',
                  style: GoogleFonts.fredoka(
                    color: Colors.white38,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),

            // Texto de la pregunta
            Text(
              question.question,
              style: GoogleFonts.fredoka(
                fontSize: 17 * widget.textScaleFactor,
                fontWeight: FontWeight.w600,
                color: Colors.white,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 16),

            // Opciones de respuesta
            ...List.generate(question.options.length, (optIndex) {
              final bool isSelected = selected == optIndex;
              final bool isThisCorrect = optIndex == question.correctIndex;

              Color optionColor = Colors.white10;
              Color textColor = Colors.white70;
              IconData? trailingIcon;

              if (isAnswered) {
                if (isThisCorrect) {
                  optionColor = Colors.greenAccent.withOpacity(0.15);
                  textColor = Colors.greenAccent;
                  trailingIcon = Icons.check_circle_rounded;
                } else if (isSelected && !isThisCorrect) {
                  optionColor = Colors.redAccent.withOpacity(0.15);
                  textColor = Colors.redAccent;
                  trailingIcon = Icons.cancel_rounded;
                }
              } else if (isSelected) {
                optionColor = widget.themeColor.withOpacity(0.15);
                textColor = widget.themeColor;
              }

              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: InkWell(
                  onTap: isAnswered
                      ? null
                      : () => _submitAnswer(index, optIndex),
                  borderRadius: BorderRadius.circular(14),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 14),
                    decoration: BoxDecoration(
                      color: optionColor,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: isSelected
                            ? textColor.withOpacity(0.5)
                            : Colors.white12,
                        width: 1.5,
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 28,
                          height: 28,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: isSelected
                                ? textColor.withOpacity(0.2)
                                : Colors.white.withOpacity(0.05),
                            border: Border.all(
                              color: isSelected ? textColor : Colors.white24,
                              width: 2,
                            ),
                          ),
                          child: Center(
                            child: Text(
                              String.fromCharCode(65 + optIndex), // A, B, C, D
                              style: GoogleFonts.fredoka(
                                color: isSelected ? textColor : Colors.white54,
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Text(
                            question.options[optIndex],
                            style: GoogleFonts.fredoka(
                              color: textColor,
                              fontSize: 15 * widget.textScaleFactor,
                              height: 1.3,
                            ),
                          ),
                        ),
                        if (trailingIcon != null)
                          Icon(trailingIcon, color: textColor, size: 24),
                      ],
                    ),
                  ),
                ),
              );
            }),

            // Feedback tras responder
            if (isAnswered) ...[
              const SizedBox(height: 8),
              AnimatedOpacity(
                opacity: isAnswered ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 400),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: (isCorrect ? Colors.greenAccent : Colors.orangeAccent)
                        .withOpacity(0.08),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: (isCorrect
                              ? Colors.greenAccent
                              : Colors.orangeAccent)
                          .withOpacity(0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        isCorrect
                            ? Icons.celebration_rounded
                            : Icons.lightbulb_rounded,
                        color: isCorrect
                            ? Colors.greenAccent
                            : Colors.orangeAccent,
                        size: 20,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          isCorrect
                              ? (question.feedbackCorrect ??
                                  '¡Correcto! ¡Excelente trabajo!')
                              : (question.feedbackIncorrect ??
                                  'No es la respuesta correcta. ¡Sigue intentándolo!'),
                          style: GoogleFonts.fredoka(
                            color: isCorrect
                                ? Colors.greenAccent
                                : Colors.orangeAccent,
                            fontSize: 13 * widget.textScaleFactor,
                            height: 1.3,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
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
