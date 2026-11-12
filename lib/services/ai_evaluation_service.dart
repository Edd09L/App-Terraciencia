/// Servicio de Evaluación IA para Terraciencia.
///
/// Implementación stub (offline, basada en reglas locales).
/// Cuando se tenga el endpoint real del AI Evaluation Service,
/// solo se necesita cambiar la lógica interna de [evaluate] sin
/// modificar la interfaz pública ni la capa de UI.
///
/// Ponderación:
///   - Fase 2 (Quiz):       50% del puntaje total
///   - Fase 3 (Mapa Mental): 50% del puntaje total
///
/// Umbral de aprobación: >= 90 puntos sobre 100.
library;

/// Resultado de la evaluación consolidada de una lección.
class EvaluationResult {
  /// Puntaje total consolidado (0.0 a 100.0).
  final double totalScore;

  /// Puntaje individual del quiz (Fase 2), ya ponderado.
  final double quizWeightedScore;

  /// Puntaje individual del mapa mental (Fase 3), ya ponderado.
  final double mindMapWeightedScore;

  /// Si el estudiante aprobó (>= 90).
  final bool passed;

  /// Mensaje de retroalimentación principal.
  final String feedbackMessage;

  /// Retroalimentación detallada por cada rama del mapa mental.
  final List<String> detailedFeedback;

  const EvaluationResult({
    required this.totalScore,
    required this.quizWeightedScore,
    required this.mindMapWeightedScore,
    required this.passed,
    required this.feedbackMessage,
    this.detailedFeedback = const [],
  });
}

/// Servicio singleton de evaluación IA.
class AIEvaluationService {
  AIEvaluationService._();
  static final AIEvaluationService instance = AIEvaluationService._();

  /// Evalúa el desempeño consolidado de una lección.
  ///
  /// Regla pedagógica (DUA / 2do básico):
  /// - Valora la respuesta para un estudiante de 2do básico.
  /// - Ignora errores ortográficos y de acentuación.
  /// - Si responde con coherencia sobre los conceptos solicitados (ej: curiosidad, sentidos, comunidad),
  ///   asigna el puntaje completo (40 pts) y felicita con un mensaje motivador.
  /// - Si la nota total suma >= 90 pts, libera la estampita / insignia.
  Future<EvaluationResult> evaluate({
    required double quizScore,
    required Map<String, String> mindMapAnswers,
    required Map<String, String> expectedAnswers,
  }) async {
    // ── Simular latencia de red (reemplazable por llamada a endpoint IA real) ──
    await Future.delayed(const Duration(milliseconds: 800));

    // ── Evaluar Mapa Mental (Fase 3: hasta 40 pts o 50% según escala) ────────
    double mindMapRawScore = 0.0;
    int totalBranches = expectedAnswers.length;
    final List<String> feedback = [];

    if (totalBranches == 0) {
      mindMapRawScore = 100.0;
    } else {
      int correctBranches = 0;
      for (final entry in expectedAnswers.entries) {
        final String label = entry.key;
        final String expected = entry.value.toLowerCase().trim();
        final String answer =
            (mindMapAnswers[label] ?? '').toLowerCase().trim();

        if (answer.isEmpty) {
          feedback.add(
            '❌ "$label": Dejaste este espacio en blanco. ¡Anímate a escribir tu respuesta!',
          );
        } else if (_isCoherentForSecondGrade(answer, expected)) {
          // Acepta respuestas coherentes ignorando errores ortográficos
          correctBranches++;
          feedback.add('✅ "$label": ¡Excelente reflexión!');
        } else {
          // Coincidencia parcial o respuesta breve
          final double similarity = _calculateSimilarity(answer, expected);
          if (similarity >= 0.3 || answer.split(' ').length >= 2) {
            correctBranches++;
            feedback.add(
              '🔶 "$label": ¡Buena idea! Tu respuesta: "$answer".',
            );
          } else {
            feedback.add(
              '❌ "$label": Tu respuesta es muy corta o no se relaciona con lo pedido. Intenta explicar un poco más.',
            );
          }
        }
      }
      mindMapRawScore = (correctBranches / totalBranches) * 100.0;
    }

    // ── Consolidar Puntaje Total (0 a 100) ────────────────────────────────
    // Si el quiz fue sobre 30 pts y el mapa sobre 40, o en base 100 normalizada:
    // Normalizamos: Quiz representa 50% y Mapa Mental representa 50%
    final double quizWeighted = quizScore > 50 ? quizScore * 0.50 : quizScore * (50.0 / 30.0);
    final double mindMapWeighted = mindMapRawScore * 0.50;
    final double total = (quizWeighted + mindMapWeighted).clamp(0.0, 100.0);

    // ── Generar mensaje motivador ─────────────────────────────────────────
    final bool passed = total >= 90.0;
    String message;

    if (passed) {
      message =
          '🌟 ¡Maravilloso trabajo, explorador! Demostraste gran curiosidad científica '
          'y comprensión del mundo que te rodea. ¡Tu insignia ha sido desbloqueada!';
    } else if (total >= 70.0) {
      message =
          '💪 ¡Muy buen esfuerzo! Tienes excelentes ideas sobre la ciencia. '
          'Revisa las observaciones y completa el reto para ganar tu insignia.';
    } else {
      message =
          '🌱 ¡Sigue explorando! Recuerda usar tus sentidos y hacerte muchas preguntas. '
          'Vuelve a la Fase 1 para repasar las diapositivas y volver a intentarlo.';
    }

    return EvaluationResult(
      totalScore: total,
      quizWeightedScore: quizWeighted.clamp(0.0, 50.0),
      mindMapWeightedScore: mindMapWeighted.clamp(0.0, 50.0),
      passed: passed,
      feedbackMessage: message,
      detailedFeedback: feedback,
    );
  }

  /// Valora si la respuesta es coherente para un estudiante de 2do básico
  /// ignorando tildes, mayúsculas y errores ortográficos menores.
  bool _isCoherentForSecondGrade(String answer, String expected) {
    final cleanAnswer = _normalizeText(answer);
    final cleanExpected = _normalizeText(expected);

    // Si tiene al menos 3 caracteres y no está vacía
    if (cleanAnswer.length < 3) return false;

    // Si las palabras esperadas son comodines o temas abiertos
    if (cleanExpected.contains('abierta') ||
        cleanExpected.contains('cualquiera') ||
        cleanExpected.contains('curiosidad') ||
        cleanExpected.contains('sentido') ||
        cleanExpected.contains('comunidad')) {
      // Cualquier respuesta coherente de más de 3 letras cuenta
      return cleanAnswer.length >= 3;
    }

    // Coincidencia de términos clave
    final expectedWords = cleanExpected.split(RegExp(r'\s+'));
    for (final word in expectedWords) {
      if (word.length > 3 && cleanAnswer.contains(word)) {
        return true;
      }
    }

    // Similitud fonética/textual suficiente
    return _calculateSimilarity(cleanAnswer, cleanExpected) >= 0.35;
  }

  /// Normaliza texto quitando tildes, signos de puntuación y espacios extras.
  String _normalizeText(String text) {
    return text
        .toLowerCase()
        .replaceAll('á', 'a')
        .replaceAll('é', 'e')
        .replaceAll('í', 'i')
        .replaceAll('ó', 'o')
        .replaceAll('ú', 'u')
        .replaceAll('ñ', 'n')
        .replaceAll(RegExp(r'[^\w\s]'), '')
        .trim();
  }

  /// Calcula una similitud simple entre dos strings (0.0 a 1.0).
  /// Usa intersección de palabras como proxy de similitud semántica.
  double _calculateSimilarity(String a, String b) {
    final setA = a.split(RegExp(r'\s+')).toSet();
    final setB = b.split(RegExp(r'\s+')).toSet();

    if (setA.isEmpty || setB.isEmpty) return 0.0;

    final intersection = setA.intersection(setB).length;
    final union = setA.union(setB).length;

    return union > 0 ? intersection / union : 0.0;
  }
}
