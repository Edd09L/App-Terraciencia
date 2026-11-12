import '../models/lesson_content.dart';
import 'tema_prisma_1_data.dart';

/// Contenido de ejemplo para demostrar el LessonTemplateScreen.
///
/// Provee datos completos para el tema VITAL-01 (Teoría Celular)
/// incluyendo diapositivas, glosario, quiz de 4 preguntas, y mapa mental
/// de 4 ramas. Usar como referencia para crear el contenido de los demás temas.

/// Contenido de ejemplo: VITAL-01 — Teoría Celular.
const LessonContent sampleLessonVital01 = LessonContent(
  topicId: 'VITAL-01',
  slides: [
    LessonSlide(
      title: '¿Qué es una Célula?',
      description:
          'La célula es la unidad más pequeña de la vida. '
          'Todos los seres vivos estamos hechos de células: '
          'las personas, los animales, las plantas y hasta las bacterias.',
    ),
    LessonSlide(
      title: 'El Ladrillo de la Vida',
      description:
          'Piensa en tu cuerpo como un edificio enorme. '
          'Cada ladrillo de ese edificio es una célula. '
          'Un adulto tiene aproximadamente 37 billones de células trabajando juntas.',
    ),
    LessonSlide(
      title: 'Partes de la Célula',
      description:
          'Toda célula tiene tres partes principales:\n'
          '• Membrana: la pared que la protege.\n'
          '• Citoplasma: el líquido interior donde flotan las piezas.\n'
          '• Núcleo: el "cerebro" que controla todo.',
    ),
    LessonSlide(
      title: 'La Teoría Celular',
      description:
          'Los científicos descubrieron tres ideas importantes:\n'
          '1. Todos los seres vivos están hechos de células.\n'
          '2. La célula es la unidad básica de la vida.\n'
          '3. Toda célula nace de otra célula que ya existía.',
    ),
  ],
  glossary: [
    GlossaryEntry(
      term: 'Célula',
      definition:
          'La parte más pequeña de un ser vivo que puede funcionar por sí sola. '
          'Es como un ladrillo diminuto que forma todo tu cuerpo.',
    ),
    GlossaryEntry(
      term: 'Membrana Celular',
      definition:
          'La capa exterior de la célula que la protege y decide qué entra y qué sale. '
          'Funciona como la puerta de tu casa.',
    ),
    GlossaryEntry(
      term: 'Núcleo',
      definition:
          'El centro de control de la célula. Contiene el ADN con todas las instrucciones '
          'para que la célula funcione correctamente.',
    ),
    GlossaryEntry(
      term: 'Citoplasma',
      definition:
          'El líquido gelatinoso dentro de la célula donde flotan todas las piezas pequeñas '
          '(organelos) que hacen diferentes trabajos.',
    ),
    GlossaryEntry(
      term: 'Organelo',
      definition:
          'Cada una de las piezas pequeñas dentro de la célula que tienen un trabajo especial, '
          'como las mitocondrias que producen energía.',
    ),
  ],
  quizQuestions: [
    QuizQuestion(
      question: '¿Cuál es la unidad básica de todos los seres vivos?',
      options: [
        'El átomo',
        'La célula',
        'La molécula',
        'El tejido',
      ],
      correctIndex: 1,
      points: 25,
      feedbackCorrect: '¡Exacto! La célula es el ladrillo fundamental de la vida.',
      feedbackIncorrect:
          'Recuerda: la célula es la unidad básica de la vida. '
          'Los átomos son de la química, no de la biología.',
    ),
    QuizQuestion(
      question: '¿Cuál es la función principal del núcleo celular?',
      options: [
        'Producir energía',
        'Proteger la célula',
        'Controlar las funciones de la célula',
        'Almacenar agua',
      ],
      correctIndex: 2,
      points: 25,
      feedbackCorrect:
          '¡Correcto! El núcleo es el "cerebro" que controla todo en la célula.',
      feedbackIncorrect:
          'El núcleo es el centro de control. Las mitocondrias producen energía '
          'y la membrana protege la célula.',
    ),
    QuizQuestion(
      question:
          '¿Cuántas ideas principales tiene la Teoría Celular?',
      options: [
        'Una',
        'Dos',
        'Tres',
        'Cuatro',
      ],
      correctIndex: 2,
      points: 25,
      feedbackCorrect:
          '¡Bien! Son tres: todos los seres vivos tienen células, la célula es la unidad básica, '
          'y toda célula viene de otra célula.',
      feedbackIncorrect:
          'Revisa la diapositiva de la Teoría Celular. Son tres ideas fundamentales.',
    ),
    QuizQuestion(
      question: '¿Qué parte de la célula funciona como una puerta protectora?',
      options: [
        'El núcleo',
        'El citoplasma',
        'La membrana celular',
        'La mitocondria',
      ],
      correctIndex: 2,
      points: 25,
      feedbackCorrect:
          '¡Perfecto! La membrana celular decide qué entra y qué sale de la célula.',
      feedbackIncorrect:
          'Piensa en la parte que "protege" la célula como una puerta. '
          'Esa es la membrana celular.',
    ),
  ],
  mindMap: MindMapTemplate(
    centralNode: 'Teoría Celular',
    branches: [
      MindMapBranch(
        label: 'Definición',
        hintText: '¿Qué es una célula?',
        expectedAnswer: 'unidad básica de la vida',
      ),
      MindMapBranch(
        label: 'Partes Principales',
        hintText: 'Nombra las 3 partes de la célula',
        expectedAnswer: 'membrana citoplasma núcleo',
      ),
      MindMapBranch(
        label: 'Principio 1',
        hintText: '¿Qué dice el primer principio?',
        expectedAnswer: 'todos los seres vivos están hechos de células',
      ),
      MindMapBranch(
        label: 'Principio 3',
        hintText: '¿De dónde vienen las células nuevas?',
        expectedAnswer: 'toda célula nace de otra célula',
      ),
    ],
  ),
);

/// Mapa global de contenido de lecciones indexado por topicId.
///
/// Agrega aquí el contenido de cada tema conforme se vaya desarrollando.
/// El [LessonTemplateScreen] busca el contenido por topicId en este mapa.
final Map<String, LessonContent> lessonContentDatabase = {
  'prisma_tema_1': lessonPrismaTema1,
  'PRIS-01': lessonPrismaTema1,
  'VITAL-01': sampleLessonVital01,
};
