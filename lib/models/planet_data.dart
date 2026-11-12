import 'package:flutter/material.dart';
import 'app_colors.dart';

/// Colección de más de 100 insignias (un mapa de strings con las rutas de las imágenes).
/// Las claves son los IDs de las insignias y los valores son las rutas de los assets.
final Map<String, String> globalInsigniaDatabase = {
  'insignia_luz': 'assets/insignias/luz.png',
  'insignia_colores': 'assets/insignias/colores.png',
  'insignia_espejos': 'assets/insignias/espejos.png',
  'insignia_lupas': 'assets/insignias/lupas.png',
  'insignia_robots': 'assets/insignias/robots.png',
  'insignia_algoritmos': 'assets/insignias/algoritmos.png',
  'insignia_programacion': 'assets/insignias/programacion.png',
  'insignia_reciclaje': 'assets/insignias/reciclaje.png',
  'insignia_ecosistemas': 'assets/insignias/ecosistemas.png',
  'insignia_agua': 'assets/insignias/agua.png',
  'insignia_plantas': 'assets/insignias/plantas.png',
  'insignia_animales': 'assets/insignias/animales.png',
  'insignia_cuerpo': 'assets/insignias/cuerpo.png',
  'insignia_atomos': 'assets/insignias/atomos.png',
  'insignia_quimica': 'assets/insignias/quimica.png',
  'insignia_gravedad': 'assets/insignias/gravedad.png',
  'insignia_sonido': 'assets/insignias/sonido.png',
  'insignia_energia': 'assets/insignias/energia.png',
  'insignia_sabiduria': 'assets/insignias/sabiduria.png',
  // Generamos dinámicamente más de 100 insignias adicionales para completar la colección
  for (int i = 1; i <= 100; i++)
    'insignia_adicional_$i': 'assets/insignias/adicionales/insignia_$i.png',
};

/// Modelo de datos para un Tema dentro de un Planeta.
class PlanetTheme {
  final String id;
  final String name;
  
  // Soporta presentaciones, actividades y pruebas parciales
  final List<dynamic> presentations;
  final List<dynamic> activities;
  final List<dynamic> partialTests;

  // Lógica de evaluación e insignia
  final double score; // Punteo (0.0 a 100.0)
  final bool isCompleted;
  final bool hasEarnedInsignia;
  final String? insigniaId;

  const PlanetTheme({
    required this.id,
    required this.name,
    this.presentations = const [],
    this.activities = const [],
    this.partialTests = const [],
    this.score = 0.0,
    this.isCompleted = false,
    this.hasEarnedInsignia = false,
    this.insigniaId,
  });

  /// Lógica de evaluación: si el estudiante completa un tema con un punteo
  /// mayor o igual a 90 (>= 90 y <= 100), se debe activar una variable
  /// 'hasEarnedInsignia = true' y registrar un ID de insignia.
  PlanetTheme copyWithScore(double newScore, {String? customInsigniaId}) {
    final bool earned = newScore >= 90.0 && newScore <= 100.0;
    return PlanetTheme(
      id: id,
      name: name,
      presentations: presentations,
      activities: activities,
      partialTests: partialTests,
      score: newScore,
      isCompleted: true,
      hasEarnedInsignia: earned,
      insigniaId: earned ? (customInsigniaId ?? 'insignia_$id') : insigniaId,
    );
  }

  PlanetTheme copyWith({
    String? id,
    String? name,
    List<dynamic>? presentations,
    List<dynamic>? activities,
    List<dynamic>? partialTests,
    double? score,
    bool? isCompleted,
    bool? hasEarnedInsignia,
    String? insigniaId,
  }) {
    return PlanetTheme(
      id: id ?? this.id,
      name: name ?? this.name,
      presentations: presentations ?? this.presentations,
      activities: activities ?? this.activities,
      partialTests: partialTests ?? this.partialTests,
      score: score ?? this.score,
      isCompleted: isCompleted ?? this.isCompleted,
      hasEarnedInsignia: hasEarnedInsignia ?? this.hasEarnedInsignia,
      insigniaId: insigniaId ?? this.insigniaId,
    );
  }
}

/// Modelo de datos para cada planeta de la constelación.
///
/// Diseñado bajo principios de accesibilidad cognitiva (lectura fácil):
/// - Textos claros y directos.
/// - Estructura dividida en oraciones breves y viñetas (puntos).
/// - Diálogos personalizados de los personajes guía.
class PlanetData {
  final int id;
  final String name;
  final String description;
  final Color color;
  final IconData icon;
  final String assetPath; // Ruta centralizada del asset de imagen del planeta
  
  // Contenido detallado en lectura fácil
  final String titleEasyRead;
  final List<String> detailsPoints;
  final String funFact;
  
  // Diálogos de los personajes para guiar al estudiante
  final String bioQuote;
  final String jadeQuote;

  // Estado del viaje del estudiante
  final bool isUnlocked;
  final double progress;

  // Listado dinámico para que cada mundo contenga diferentes temas
  final List<PlanetTheme> themes;

  const PlanetData({
    required this.id,
    required this.name,
    required this.description,
    required this.color,
    required this.icon,
    required this.assetPath,
    required this.titleEasyRead,
    required this.detailsPoints,
    required this.funFact,
    required this.bioQuote,
    required this.jadeQuote,
    this.isUnlocked = false,
    this.progress = 0.0,
    this.themes = const [],
  });

  PlanetData copyWith({
    bool? isUnlocked,
    double? progress,
    List<PlanetTheme>? themes,
  }) {
    return PlanetData(
      id: id,
      name: name,
      description: description,
      color: color,
      icon: icon,
      assetPath: assetPath,
      titleEasyRead: titleEasyRead,
      detailsPoints: detailsPoints,
      funFact: funFact,
      bioQuote: bioQuote,
      jadeQuote: jadeQuote,
      isUnlocked: isUnlocked ?? this.isUnlocked,
      progress: progress ?? this.progress,
      themes: themes ?? this.themes,
    );
  }

  /// Retorna todo el contenido textual formateado para el lector de voz (TTS).
  String toSpeechString() {
    final buffer = StringBuffer();
    buffer.write('Planeta $name. ');
    buffer.write('$description. ');
    buffer.write('Información importante: ');
    for (final point in detailsPoints) {
      buffer.write('$point. ');
    }
    buffer.write('Dato curioso: $funFact');
    return buffer.toString();
  }

  /// Ruta del paisaje de fondo del planeta en assets/images/planets/
  String get landscapeAssetPath {
    final lower = name
        .toLowerCase()
        .replaceAll('é', 'e')
        .replaceAll('í', 'i')
        .replaceAll('ó', 'o')
        .replaceAll(' ', '')
        .replaceAll('-', '');
    if (lower.contains('prisma')) return 'assets/images/planets/Prisma paisaje.jpg';
    if (lower.contains('ciberon')) return 'assets/images/planets/Ciberon paisaje.jpg';
    if (lower.contains('kineto')) return 'assets/images/planets/Kinetos paisaje.jpg';
    if (lower.contains('vitalia')) return 'assets/images/planets/Vitalia paisaje.jpg';
    if (lower.contains('simbios')) return 'assets/images/planets/Simbios paisaje.jpg';
    if (lower.contains('titan')) return 'assets/images/planets/Titan-Q paisaje.jpg';
    if (lower.contains('noosferis') || lower.contains('noo')) return 'assets/images/planets/Noosféris paisaje.jpg';
    return 'assets/images/planets/Prisma paisaje.jpg';
  }

  /// Ruta del ícono temático oficial de la disciplina asignada
  String get disciplineIconAssetPath {
    final lower = name
        .toLowerCase()
        .replaceAll('é', 'e')
        .replaceAll('í', 'i')
        .replaceAll('ó', 'o')
        .replaceAll(' ', '')
        .replaceAll('-', '');
    if (lower.contains('prisma')) return 'assets/images/planets/Ciencias.png';
    if (lower.contains('ciberon')) return 'assets/images/planets/Tecnología.png';
    if (lower.contains('kineto')) return 'assets/images/planets/Física.png';
    if (lower.contains('vitalia')) return 'assets/images/planets/Biología.png';
    if (lower.contains('simbios')) return 'assets/images/planets/Ea.png';
    if (lower.contains('titan')) return 'assets/images/planets/Química.png';
    return 'assets/images/planets/Ciencias.png';
  }

  /// Nombre de la disciplina pedagógica asignada
  String get disciplineName {
    final lower = name
        .toLowerCase()
        .replaceAll('é', 'e')
        .replaceAll('í', 'i')
        .replaceAll('ó', 'o')
        .replaceAll(' ', '')
        .replaceAll('-', '');
    if (lower.contains('prisma')) return 'Ciencias e Indagación';
    if (lower.contains('ciberon')) return 'Tecnología e Informática';
    if (lower.contains('kineto')) return 'Física y Movimiento';
    if (lower.contains('vitalia')) return 'Biología y Vida';
    if (lower.contains('simbios')) return 'Educación Ambiental y Ecología';
    if (lower.contains('titan')) return 'Química y Salud Humana';
    return 'Ciencias Generales';
  }
}

/// Lista de los 7 planetas de la Vía Láctea del Saber con la paleta oficial AppColors.
final List<PlanetData> spacePlanets = [
  const PlanetData(
    id: 1,
    name: 'Prisma',
    description: 'El mundo donde nace la curiosidad. Aquí aprenderás a pensar como un científico observando los misterios que nos rodean.',
    color: AppColors.prisma, // #4B0082 - Índigo Profundo
    icon: Icons.wb_sunny_rounded,
    assetPath: 'assets/images/Prisma.png',
    titleEasyRead: '¿Qué es el mundo de Prisma?',
    detailsPoints: [
      'Aprenderás qué es la ciencia y cuál es su objetivo dentro de nuestra sociedad.',
      'Dominarás los pasos del método científico: observar, preguntar, hipótesis, experimentar y concluir.',
      'Diseñarás una pequeña investigación sobre un problema real de tu comunidad.'
    ],
    funFact: '¿Sabías que la primera herramienta científica de la historia se descubrió en África? El \'Hueso de Ishango\' tiene más de 20,000 años y se usaba para entender la naturaleza.',
    bioQuote: '¡Hola! Soy Bio. ¡Comencemos el viaje en Prisma! Aprenderemos de dónde vienen los colores de la luz.',
    jadeQuote: '¡Hola, explorador! Soy Jade. Haz clic en el planeta violeta Prisma para jugar con espejos y luces.',
    progress: 0.0,
    isUnlocked: true, // El primer planeta siempre está desbloqueado
  ),
  const PlanetData(
    id: 2,
    name: 'Cíberon',
    description: 'El núcleo de la era digital. Descubre cómo las máquinas, los algoritmos y la robótica transforman nuestro día a día.',
    color: AppColors.ciberon, // #8B6508 - Dorado / Ámbar
    icon: Icons.memory_rounded,
    assetPath: 'assets/images/Ciberon.png',
    titleEasyRead: '¿Qué es el mundo de Cíberon?',
    detailsPoints: [
      'Descubrirás la diferencia entre ciencia y tecnología, y cómo se complementan.',
      'Explorarás las bases de la robótica y cómo los robots siguen instrucciones (algoritmos).',
      'Aprenderás a usar las pantallas y las redes sociales de forma responsable y balanceada.'
    ],
    funFact: '¿Sabías que el primer \'bug\' o error de computadora fue un insecto real? En 1947, se encontró una polilla atrapada en un circuito de la máquina.',
    bioQuote: '¡Alucinante! Llegamos a Cíberon. Aquí le daremos órdenes a pequeños robots espaciales.',
    jadeQuote: '¡Mira el planeta Cíberon! Entra y descubre cómo piensa una computadora.',
    progress: 0.0,
    isUnlocked: false,
  ),
  const PlanetData(
    id: 6,
    name: 'Kinetos',
    description: 'El planeta de las fuerzas invisibles. Explora las leyes que gobiernan el movimiento, el tiempo y las grandes distancias del universo.',
    color: AppColors.kinetos, // #9E2A2B - Rojo Rubí
    icon: Icons.speed_rounded,
    assetPath: 'assets/images/Kinetos.png',
    titleEasyRead: '¿Qué es el mundo de Kinetos?',
    detailsPoints: [
      'Aprenderás las unidades de medida del Sistema Internacional y el Movimiento Rectilíneo Uniforme (MRU).',
      'Descubrirás cómo funcionan las fuerzas y qué efectos producen sobre los objetos.',
      'Explorarás el concepto de equilibrio estático y por qué los objetos flotan o se detienen en el espacio.'
    ],
    funFact: '¿Sabías que si viajaras en línea recta a la velocidad de un auto de carreras (MRU), tardarías unos 157 años en llegar a la Luna?',
    bioQuote: '¡Siente la fuerza! En Kinetos lanzaremos cohetes y veremos cómo giran las ruedas.',
    jadeQuote: '¡Ya casi completamos la constelación! Entra a Kinetos, el planeta rojo rubí.',
    progress: 0.0,
    isUnlocked: false,
  ),
  const PlanetData(
    id: 5,
    name: 'Titan-Q',
    description: 'El laboratorio del universo. Aquí descubrirás los secretos de los átomos, las mezclas y los ingredientes de todo lo que tocas.',
    color: AppColors.titanQ, // #004F77 - Azul Océano
    icon: Icons.science_rounded,
    assetPath: 'assets/images/Titan-Q.png',
    titleEasyRead: '¿Qué es el mundo de Titan-Q?',
    detailsPoints: [
      'Estudiarás las propiedades de la materia: masa, volumen, densidad y estados.',
      'Conocerás los átomos, los elementos químicos y la Tabla Periódica básica.',
      'Aprenderás técnicas para separar mezclas como la filtración, destilación y evaporación.'
    ],
    funFact: '¿Sabías que el cuerpo humano está hecho del mismo material que las estrellas? Elementos como el hierro de tu sangre se formaron en el espacio.',
    bioQuote: '¡Hora de ponerse las gafas de ciencia en Titan-Q! Jugaremos a hacer mezclas burbujeantes y seguras.',
    jadeQuote: '¡Avanzamos hacia Titan-Q! Haz clic para entender las fórmulas mágicas.',
    progress: 0.0,
    isUnlocked: false,
  ),
  const PlanetData(
    id: 4,
    name: 'Vitalia',
    description: 'El santuario de la vida. Adéntrate en el asombroso mapa de las células, el manual secreto del ADN y los sistemas que te mantienen vivo.',
    color: AppColors.vitalia, // #A1005B - Magenta Vértice
    icon: Icons.favorite_rounded,
    assetPath: 'assets/images/Vitalia.png',
    titleEasyRead: '¿Qué es el mundo de Vitalia?',
    detailsPoints: [
      'Explorarás el origen de la vida y la teoría de la evolución desde sus bases.',
      'Estudiarás la célula: sus partes, tipos (animal y vegetal) y funciones esenciales.',
      'Descifrarás el manual del ADN, los cromosomas y las Leyes de Mendel sobre herencia genética.',
      'Conocerás los sistemas del cuerpo humano: circulatorio, respiratorio, digestivo y nervioso.'
    ],
    funFact: '¿Sabías que si estiráramos por completo el ADN de una sola de tus células, mediría casi 2 metros de largo?',
    bioQuote: '¡Mi planeta preferido! En Vitalia estudiaremos las células, las hojas y a los animales salvajes.',
    jadeQuote: '¡Mira el planeta magenta Vitalia! Haz clic en Vitalia para conocer el cuerpo por dentro.',
    progress: 0.0,
    isUnlocked: false,
  ),
  const PlanetData(
    id: 3,
    name: 'Simbios',
    description: 'El ecosistema vivo. Viaja por las capas de la Tierra, descubre los reinos de la naturaleza y protege la mega-biodiversidad de Guatemala.',
    color: AppColors.simbios, // #1B5E20 - Verde Esmeralda
    icon: Icons.recycling_rounded,
    assetPath: 'assets/images/Simbios.png',
    titleEasyRead: '¿Qué es el mundo de Simbios?',
    detailsPoints: [
      'Aprenderás el ciclo del agua y cómo fluye entre la atmósfera, la tierra y los océanos.',
      'Explorarás las capas internas de la Tierra: corteza, manto y núcleo.',
      'Estudiarás los principales biomas del planeta y sus ecosistemas característicos.',
      'Celebrarás la megabiodiversidad de Guatemala y aprenderás por qué es un tesoro que debemos proteger.'
    ],
    funFact: '¿Sabías que Guatemala es un país \'Megadiverso\'? Albergamos el 14% de todas las especies de animales de Centroamérica.',
    bioQuote: '¡En Simbios somos guardianes ecológicos! Aprendamos a reciclar la basura y cuidar el agua.',
    jadeQuote: 'Sigue el camino a Simbios. ¡Haz clic y cuidemos el bosque juntos!',
    progress: 0.0,
    isUnlocked: false,
  ),
  const PlanetData(
    id: 7,
    name: 'Noosféris',
    description: 'El mundo de la sabiduría. Consigue tus logros y prepara tu álbum impreso.',
    color: AppColors.noosferis, // #8B6508 - Dorado / Sabiduría
    icon: Icons.emoji_events_rounded,
    assetPath: 'assets/images/Noosferis.png',
    titleEasyRead: '¿Qué es el planeta Noosféris?',
    detailsPoints: [
      'Noosféris reúne todos tus aprendizajes espaciales en insignias.',
      'Aquí verás los stickers de logros que has ganado en tu exploración.',
      'Puedes seleccionar múltiples insignias para crear una planilla especial.',
      'El botón de PDF creará una hoja lista para imprimir, con tu nombre escrito.'
    ],
    funFact: '¡Noosféris es la suma de todo lo que has aprendido. Eres un verdadero sabio cósmico!',
    bioQuote: '¡Espectacular! En Noosféris organizaremos tus medallas de estudio. ¡Te felicito mucho!',
    jadeQuote: '¡El gran planeta dorado brilla con tu esfuerzo! Haz clic para armar tu hoja de stickers.',
    progress: 0.0,
    isUnlocked: false,
  ),
];
