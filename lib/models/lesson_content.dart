/// Modelos de datos para el contenido inyectable de cada lección.
///
/// Diseñado para alimentar la plantilla [LessonTemplateScreen] con datos
/// específicos de cada uno de los 40 temas de Terraciencia.
///
/// Estructura DUA (Diseño Universal para el Aprendizaje):
///   Fase 1 — Aprender: diapositivas + modelo 3D + glosario
///   Fase 2 — Practicar: quiz interactivo de opción múltiple
///   Fase 3 — Evaluar: mapa mental con campos de texto en blanco
library;

// ─────────────────────────────────────────────────────────────────────────────
// Fase 1: Aprender
// ─────────────────────────────────────────────────────────────────────────────

/// Una diapositiva individual dentro de la fase "Aprender".
class LessonSlide {
  /// Título breve de la diapositiva (lectura fácil).
  final String title;

  /// Descripción o contenido textual de la diapositiva.
  final String description;

  /// Ruta al asset de imagen (PNG/JPG). Puede ser null si se usa SVG.
  final String? imagePath;

  /// Ruta al asset SVG. Puede ser null si se usa imagen raster.
  final String? svgPath;

  const LessonSlide({
    required this.title,
    required this.description,
    this.imagePath,
    this.svgPath,
  });
}

/// Entrada del glosario emergente (accesibilidad cognitiva).
class GlossaryEntry {
  /// Palabra o término a definir.
  final String term;

  /// Definición en lectura fácil.
  final String definition;

  /// Imagen de ejemplo opcional para reforzar comprensión visual.
  final String? exampleImagePath;

  const GlossaryEntry({
    required this.term,
    required this.definition,
    this.exampleImagePath,
  });
}

/// Par para actividades de relacionar / emparejar conceptos (Fase 2).
class MatchingPair {
  /// Concepto o término de la izquierda (ej: "Curiosidad").
  final String left;

  /// Definición o descripción de la derecha (ej: "Hacerse preguntas del mundo").
  final String right;

  const MatchingPair({
    required this.left,
    required this.right,
  });
}

// ─────────────────────────────────────────────────────────────────────────────
// Fase 2: Practicar
// ─────────────────────────────────────────────────────────────────────────────

/// Pregunta individual del micro-quiz interactivo.
class QuizQuestion {
  /// Texto de la pregunta (lectura fácil, máximo 2 líneas).
  final String question;

  /// Lista de opciones de respuesta (recomendado: 3-4 opciones).
  final List<String> options;

  /// Índice (0-based) de la respuesta correcta dentro de [options].
  final int correctIndex;

  /// Puntos que vale esta pregunta (suma total del quiz = 100 idealmente).
  final int points;

  /// Retroalimentación que se muestra al responder correctamente.
  final String? feedbackCorrect;

  /// Retroalimentación que se muestra al responder incorrectamente.
  final String? feedbackIncorrect;

  const QuizQuestion({
    required this.question,
    required this.options,
    required this.correctIndex,
    this.points = 25,
    this.feedbackCorrect,
    this.feedbackIncorrect,
  });
}

// ─────────────────────────────────────────────────────────────────────────────
// Fase 3: Evaluar
// ─────────────────────────────────────────────────────────────────────────────

/// Una rama individual del mapa mental interactivo.
class MindMapBranch {
  /// Etiqueta visible de la rama (ej: "Función", "Estructura").
  final String label;

  /// Texto de ayuda (hint) dentro del TextField vacío.
  final String hintText;

  /// Respuesta esperada para la evaluación (no visible al alumno).
  final String expectedAnswer;

  const MindMapBranch({
    required this.label,
    required this.hintText,
    required this.expectedAnswer,
  });
}

/// Plantilla de mapa mental para la fase de evaluación.
class MindMapTemplate {
  /// Nodo central (tema principal, no editable por el alumno).
  final String centralNode;

  /// Lista de ramas que el alumno debe completar con texto.
  final List<MindMapBranch> branches;

  const MindMapTemplate({
    required this.centralNode,
    required this.branches,
  });
}

// ─────────────────────────────────────────────────────────────────────────────
// Modelo Principal: Contenido de Lección
// ─────────────────────────────────────────────────────────────────────────────

/// Contenido completo inyectable para una lección dentro de [LessonTemplateScreen].
///
/// Cada instancia de [LessonContent] alimenta las 3 fases DUA de un tema específico.
/// Se vincula al [Topic] existente a través de [topicId].
class LessonContent {
  /// Identificador del tema asociado (debe coincidir con [Topic.id]).
  final String topicId;

  /// Fase 1: Lista de diapositivas para el PageView.
  final List<LessonSlide> slides;

  /// Fase 1: Ruta opcional al modelo 3D (.glb) para ModelViewer.
  final String? model3dPath;

  /// Fase 1: Entradas del glosario emergente.
  final List<GlossaryEntry> glossary;

  /// Fase 2: Preguntas del micro-quiz interactivo (opcional si se usa matchingPairs).
  final List<QuizQuestion> quizQuestions;

  /// Fase 2: Pares para la actividad interactiva de emparejar/relacionar (opcional).
  final List<MatchingPair>? matchingPairs;

  /// Fase 2: Puntos totales de la actividad de relacionar (por defecto 30).
  final int matchingPoints;

  /// Fase 3: Plantilla del mapa mental interactivo.
  final MindMapTemplate mindMap;

  const LessonContent({
    required this.topicId,
    required this.slides,
    this.model3dPath,
    this.glossary = const [],
    this.quizQuestions = const [],
    this.matchingPairs,
    this.matchingPoints = 30,
    required this.mindMap,
  });
}
