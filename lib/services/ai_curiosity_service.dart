import 'dart:async';
import 'dart:math';

/// Modelo de contexto temático para la IA por cada planeta.
class PlanetAIContext {
  final String planetKey;
  final String planetName;
  final String areaTematica;
  final String promptTemplate;
  final List<String> curatedFacts;

  const PlanetAIContext({
    required this.planetKey,
    required this.planetName,
    required this.areaTematica,
    required this.promptTemplate,
    required this.curatedFacts,
  });
}

/// Servicio de Inteligencia Artificial (Gemini / Generative AI)
/// para generación de Datos Curiosos Educativos contextualizados por Planeta.
class AICuriosityService {
  AICuriosityService._();
  static final AICuriosityService instance = AICuriosityService._();

  final Random _random = Random();

  /// Registro de contextos temáticos especializados por planeta
  static final Map<String, PlanetAIContext> _contexts = {
    'prisma': const PlanetAIContext(
      planetKey: 'prisma',
      planetName: 'Prisma',
      areaTematica: 'Indagación Científica y Exploración Natural',
      promptTemplate:
          'Genera un dato curioso corto, fascinante e inspirador de Ciencias Naturales para estudiantes de secundaria, abarcando un espectro amplio de indagación científica: astronomía, geología, fósiles, el método científico, observación de la naturaleza, tectónica de placas y evolución de grandes descubrimientos científicos.',
      curatedFacts: [
        'Los fósiles de amonites en las cumbres del Himalaya demuestran que las montañas más altas del mundo estuvieron alguna vez bajo el océano debido al movimiento de placas tectónicas.',
        'El telescopio espacial James Webb puede detectar la composición química y vapor de agua en la atmósfera de exoplanetas a cientos de años luz de distancia.',
        'El método científico comenzó cuando la humanidad dejó de aceptar dogmas y empezó a observar, formular hipótesis y realizar experimentos medibles en la naturaleza.',
        'Los meteoritos que impactan la Tierra son cápsulas de tiempo con más de 4,500 millones de años que preservan los mismos minerales que formaron el sistema solar.',
        'El núcleo interno de la Tierra es una esfera sólida de hierro y níquel a más de 5,000 °C, generando el campo geomagnético que protege la vida de los rayos cósmicos.',
        'Charles Darwin desarrolló la teoría de la evolución observando las sutiles variaciones en los picos de los pinzones y caparazones de tortugas en las Islas Galápagos.',
        'Las auroras boreales y australes ocurren cuando partículas cargadas del viento solar colisionan con átomos de oxígeno y nitrógeno en la alta atmósfera.',
        'Un rayo de luz solar tarda más de 100,000 años en viajar desde el núcleo del Sol hasta su superficie, pero solo 8 minutos y 20 segundos en llegar a la Tierra.',
        'El 99% de todas las especies que han existido en la Tierra a lo largo de 3,800 millones de años de historia biológica están extintas y documentadas en el registro fósil.',
      ],
    ),
    'simbios': const PlanetAIContext(
      planetKey: 'simbios',
      planetName: 'Simbios',
      areaTematica: 'Ecología y Medio Ambiente',
      promptTemplate:
          'Genera un dato curioso corto, fascinante e inspirador de Ciencias Naturales enfocado en Ecología, Biodiversidad, Ciclos Biogeoquímicos, Conservación y Medio Ambiente para estudiantes de secundaria.',
      curatedFacts: [
        'Los árboles de un bosque se comunican y comparten nutrientes bajo tierra mediante una red de hongos microscópicos llamada "Wood Wide Web".',
        'Más del 50% del oxígeno del planeta es producido por el fitoplancton en los océanos, superando a todos los bosques tropicales del mundo juntos.',
        'Guatemala alberga más de 33 volcanes y el 14% de las especies de Centroamérica, siendo uno de los 20 países megadiversos del planeta.',
        'Una sola gota de agua en el ciclo hidrológico puede haber formado parte del cuerpo de un dinosaurio hace más de 65 millones de años.',
        'La capa de ozono en la estratósfera bloquea el 98% de la radiación ultravioleta de alta energía, permitiendo el desarrollo de la vida terrestre.',
        'Los arrecifes de coral ocupan menos del 1% del fondo oceánico, pero albergan a más del 25% de todas las especies marinas conocidas.',
        'Los manglares almacenan hasta 4 veces más carbono que los bosques terrestres, protegiendo las costas contra huracanes y tsunamis.',
      ],
    ),
    'ciberon': const PlanetAIContext(
      planetKey: 'ciberon',
      planetName: 'Cíberon',
      areaTematica: 'Tecnología e Informática',
      promptTemplate:
          'Genera un dato curioso corto, fascinante e inspirador de Ciencias Naturales y Ciencias de la Computación enfocado en Tecnología, Algoritmos, Nanotecnología, Robótica e Inteligencia Artificial para estudiantes de secundaria.',
      curatedFacts: [
        'El rover Perseverance en Marte utiliza inteligencia artificial y visión computacional para conducir de forma autónoma y analizar rocas con rayos láser.',
        'Los transistores modernos en un microprocesador miden apenas 3 nanómetros; caben más de 50,000 millones en un chip del tamaño de una uña.',
        'El primer "bug" de la informática fue una polilla real encontrada atrapada en un relé electromecánico de la computadora Mark II en 1947 por Grace Hopper.',
        'Los satélites GPS en órbita deben corregir sus relojes atómicos diariamente aplicando la teoría de la relatividad de Einstein para no perder precisión en la Tierra.',
        'Las computadoras procesan todo el universo digital utilizando únicamente dos estados lógicos: el 0 (apagado) y el 1 (encendido).',
        'La biomimética permite a los ingenieros diseñar robots de rescate inspirados en el vuelo de libélulas y la adherencia de las patas de los gecos.',
      ],
    ),
    'vitalia': const PlanetAIContext(
      planetKey: 'vitalia',
      planetName: 'Vitalia',
      areaTematica: 'Biología y Salud',
      promptTemplate:
          'Genera un dato curioso corto, fascinante e inspirador de Ciencias Naturales enfocado en Biología Celular, Genética, Anatomía Humana, Microbiología y Salud para estudiantes de secundaria.',
      curatedFacts: [
        'Si desenrolláramos la doble hélice de ADN contenida en todas las células de tu cuerpo, alcanzaría una longitud equivalente a viajar al Sol y regresar varias veces.',
        'El corazón humano bombea cerca de 7,500 litros de sangre al día y late más de 100,000 veces sin detenerse jamás.',
        'El cuerpo humano alberga billones de microorganismos benéficos en la microbiota intestinal que ayudan a digerir alimentos y regular el sistema inmune.',
        'Los pulpos poseen tres corazones y su sangre es de color azul porque utiliza hemocianina con átomos de cobre para transportar oxígeno en aguas frías.',
        'Compartimos aproximadamente el 60% de nuestra información genética con las plantas y más del 98% con los primates superiores.',
        'El cerebro humano genera suficiente energía electroquímica como para encender una bombilla LED de bajo consumo de 20 vatios.',
      ],
    ),
    'titan_q': const PlanetAIContext(
      planetKey: 'titan_q',
      planetName: 'Titan-Q',
      areaTematica: 'Química y Materia',
      promptTemplate:
          'Genera un dato curioso corto, fascinante e inspirador de Ciencias Naturales enfocado en Química, Reacciones Químicas, Elementos de la Tabla Periódica, Estados de la Materia y Enlaces Químicos para estudiantes de secundaria.',
      curatedFacts: [
        'Todos los átomos pesados de tu cuerpo (como el hierro de tu sangre y el calcio de tus huesos) fueron forjados en el corazón de estrellas que explotaron como supernovas.',
        'El diamante más duro del mundo y el grafito blando de un lápiz están compuestos exactamente del mismo elemento químico: carbono puro en diferente arreglo cristalino.',
        'El agua es una de las poquísimas sustancias que se expande y se vuelve menos densa al congelarse, lo que permite que el hielo flote y preserve la vida marina.',
        'Si elimináramos todo el espacio vacío dentro de los átomos que componen a toda la humanidad, cabríamos dentro del volumen de un terrón de azúcar.',
        'La tabla periódica organiza los 118 elementos del universo según su número atómico, electronegatividad y configuración electrónica.',
        'El helio líquido a temperaturas cercanas al cero absoluto se convierte en un superfluido capaz de trepar por las paredes de un vaso desafiando la gravedad.',
      ],
    ),
    'kinetos': const PlanetAIContext(
      planetKey: 'kinetos',
      planetName: 'Kinetos',
      areaTematica: 'Física y Movimiento',
      promptTemplate:
          'Genera un dato curioso corto, fascinante e inspirador de Ciencias Naturales enfocado en Física, Cinemática, Dinámica, Gravitación, Energía, Ondas y Leyes de Newton para estudiantes de secundaria.',
      curatedFacts: [
        'En el vacío del espacio exterior donde no existe fricción del aire, un objeto lanzado viajará eternamente en línea recta a velocidad constante (Primera Ley de Newton).',
        'La fuerza de gravedad de la Luna y el Sol es la responsable de que los océanos de la Tierra experimenten mareas altas y bajas dos veces al día.',
        'El sonido no puede propagarse en el vacío del espacio exterior porque es una onda mecánica que necesita partículas de materia para vibrar y transmitirse.',
        'Un astronauta a bordo de la Estación Espacial Internacional experimenta 16 amaneceres y 16 puestas de sol cada 24 horas debido a su velocidad orbital de 27,600 km/h.',
        'La Tercera Ley de Newton (principio de acción y reacción) es la que permite a los cohetes espaciales impulsarse en el espacio expulsando gases a alta velocidad.',
        'La energía no se crea ni se destruye en el universo: únicamente se transforma de una forma a otra, como de radiación solar a energía química en la fotosíntesis.',
      ],
    ),
    'noosferis': const PlanetAIContext(
      planetKey: 'noosferis',
      planetName: 'Noosféris',
      areaTematica: 'Sabiduría Universal',
      promptTemplate:
          'Genera un dato curioso corto, fascinante e inspirador de Ciencias Naturales enfocado en Historia de la Ciencia, Pensamiento Crítico, Grandes Descubrimientos y Sabiduría Universal para estudiantes de secundaria.',
      curatedFacts: [
        'La ciencia avanza cuando nos atrevemos a cuestionar lo establecido y construimos sobre el conocimiento acumulado por generaciones de exploradores.',
        'Grandes mentes como Marie Curie, Galileo Galilei, Isaac Newton y Nikola Tesla transformaron el mundo impulsados por una sola fuerza: su inagotable curiosidad.',
        'El hueso de Ishango, descubierto en África con más de 20,000 años de antigüedad, es una de las evidencias arqueológicas más tempranas de conteo matemático humano.',
        'Cada respuesta que encontramos en las ciencias naturales abre la puerta a diez nuevas preguntas fascinantes sobre el cosmos y la naturaleza.',
      ],
    ),
  };

  /// Retorna el título formateado y personalizado del encabezado según la disciplina y planeta:
  /// - KINETOS -> "Dato Curioso de Física • Kinetos"
  /// - TITAN-Q / ATÓMIS -> "Dato Curioso de Química • Titan-Q"
  /// - CÍBERON -> "Dato Curioso de Tecnología e Informática • Cíberon"
  /// - PRISMA -> "Dato Curioso de Indagación Científica • Prisma"
  /// - SIMBIOS -> "Dato Curioso de Ecología y Medio Ambiente • Simbios"
  /// - VITALIA -> "Dato Curioso de Biología y Salud • Vitalia"
  /// - NOOSFÉRIS -> "Dato Curioso de Sabiduría Universal • Noosféris"
  String getAreaHeaderTitle(String rawPlanetName) {
    final key = rawPlanetName
        .toLowerCase()
        .replaceAll('é', 'e')
        .replaceAll('í', 'i')
        .replaceAll('ó', 'o')
        .replaceAll('-', '_')
        .trim();

    if (key.contains('kineto')) {
      return 'Dato Curioso de Física • Kinetos';
    } else if (key.contains('titan') || key.contains('atomis') || key.contains('átomis')) {
      return 'Dato Curioso de Química • Titan-Q';
    } else if (key.contains('ciberon') || key.contains('cib')) {
      return 'Dato Curioso de Tecnología e Informática • Cíberon';
    } else if (key.contains('prisma')) {
      return 'Dato Curioso de Indagación Científica • Prisma';
    } else if (key.contains('simbios') || key.contains('sim')) {
      return 'Dato Curioso de Ecología y Medio Ambiente • Simbios';
    } else if (key.contains('vitalia') || key.contains('vit')) {
      return 'Dato Curioso de Biología y Salud • Vitalia';
    } else if (key.contains('noosferis') || key.contains('noo')) {
      return 'Dato Curioso de Sabiduría Universal • Noosféris';
    }

    final ctx = getContextForPlanet(rawPlanetName);
    return 'Dato Curioso de ${ctx.areaTematica} • ${ctx.planetName}';
  }

  /// Obtiene el contexto temático exacto para un planeta dado.
  PlanetAIContext getContextForPlanet(String rawPlanetName) {
    final key = rawPlanetName
        .toLowerCase()
        .replaceAll('é', 'e')
        .replaceAll('í', 'i')
        .replaceAll('ó', 'o')
        .replaceAll('-', '_')
        .trim();

    if (_contexts.containsKey(key)) {
      return _contexts[key]!;
    }

    for (final entry in _contexts.entries) {
      if (key.contains(entry.key) || entry.key.contains(key)) {
        return entry.value;
      }
    }

    return _contexts['prisma']!;
  }

  /// Realiza la petición contextualizada a la IA enviando la temática específica del planeta.
  Future<String> fetchCuriosity({required String planetName}) async {
    final context = getContextForPlanet(planetName);

    // Simulación de latencia de red de la API de IA (Gemini endpoint)
    await Future.delayed(const Duration(milliseconds: 650));

    final facts = context.curatedFacts;
    final index = _random.nextInt(facts.length);
    return facts[index];
  }
}
