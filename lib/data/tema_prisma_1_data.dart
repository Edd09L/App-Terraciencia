import '../models/lesson_content.dart';

/// Contenido DUA para el Tema 1 del Planeta Prisma: "1. La curiosidad humana y la ciencia".
///
/// Estructura:
/// - FASE 1 (Aprender): 3 diapositivas en Lectura Fácil + Glosario + Modelo 3D de lupa.
/// - FASE 2 (Practicar): Micro-actividad de relacionar 3 tarjetas (30 puntos).
/// - FASE 3 (Evaluar / El Reto): Mapa mental interactivo con 3 campos de texto (40 puntos).
const LessonContent lessonPrismaTema1 = LessonContent(
  topicId: 'prisma_tema_1',
  slides: [
    LessonSlide(
      title: '¡La Chispa de la Ciencia!',
      description:
          'Todos nacemos siendo exploradores. La ciencia empieza cuando te haces preguntas sobre lo que te rodea, como Jade cuando mira las estrellas.',
      svgPath: 'assets/images/jade_curiosa.svg',
    ),
    LessonSlide(
      title: '¿Qué es la Ciencia y la Observación?',
      description:
          'La Ciencia es el camino para buscar respuestas. Usamos nuestros sentidos (vista, oído, tacto) para observar detenidamente.',
    ),
    LessonSlide(
      title: 'Saberes de Nuestra Comunidad',
      description:
          'Nuestros abuelos y comunidades ya hacían ciencia al observar la luna para cultivar y conocer las plantas medicinales.',
    ),
  ],
  glossary: [
    GlossaryEntry(
      term: 'Sentidos',
      definition: 'Herramientas de nuestro cuerpo para percibir el mundo.',
    ),
    GlossaryEntry(
      term: 'Curiosidad',
      definition: 'El deseo natural de aprender, descubrir y hacernos preguntas sobre todo lo que nos rodea.',
    ),
    GlossaryEntry(
      term: 'Observación',
      definition: 'Mirar y examinar con mucha atención usando nuestros sentidos para comprender algo.',
    ),
  ],
  model3dPath: 'assets/modelos/lupa_3d.glb',
  matchingPairs: [
    MatchingPair(
      left: 'Curiosidad',
      right: 'Hacerse preguntas del mundo',
    ),
    MatchingPair(
      left: 'Observación',
      right: 'Usar los sentidos con atención',
    ),
    MatchingPair(
      left: 'Saber Ancestral',
      right: 'Conocimiento de la comunidad',
    ),
  ],
  matchingPoints: 30,
  mindMap: MindMapTemplate(
    centralNode: 'Mi Mapa de la Curiosidad',
    branches: [
      MindMapBranch(
        label: 'Escribe algo que te cause mucha curiosidad:',
        hintText: 'Ejemplo: ¿Por qué brillan las estrellas?, los animales...',
        expectedAnswer: 'curiosidad pregunta abierta sobre la naturaleza o el mundo',
      ),
      MindMapBranch(
        label: '¿Qué sentido usas más para explorar? (Vista, Oído, etc.):',
        hintText: 'Ejemplo: Vista, tacto, oído, olfato, gusto...',
        expectedAnswer: 'vista oido tacto olfato gusto sentidos',
      ),
      MindMapBranch(
        label: 'Escribe un consejo o saber que te haya enseñado tu familia:',
        hintText: 'Ejemplo: Cuidar las plantas, observar la lluvia, recetas...',
        expectedAnswer: 'comunidad familia saber tradicional plantas naturaleza',
      ),
    ],
  ),
);
