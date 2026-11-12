import 'package:flutter/material.dart';
import 'app_colors.dart';

/// Modelo de una semana curricular (Secuencia Didáctica Oficial)
class CurriculumWeek {
  final int weekNumber;
  final String title;
  final List<String> contents;
  final String description;
  final String? planetName;
  final Color? planetColor;
  final String suggestedDuration;
  final List<String> learningObjectives;
  final String inclusionTips;
  final String? slidesUrl;

  const CurriculumWeek({
    required this.weekNumber,
    required this.title,
    required this.contents,
    required this.description,
    this.planetName,
    this.planetColor,
    this.suggestedDuration = '4 a 5 horas pedagógicas',
    this.learningObjectives = const [],
    this.inclusionTips = 'Adaptaciones DUA: Textos en lectura fácil, apoyos visuales y actividades multisensoriales.',
    this.slidesUrl,
  });
}

/// Modelo de una Competencia Curricular
class CurriculumCompetence {
  final int id;
  final String title;
  final String officialDescription;
  final Color themeColor;
  final IconData icon;
  final String planetAssociation;
  final List<CurriculumWeek> weeks;

  const CurriculumCompetence({
    required this.id,
    required this.title,
    required this.officialDescription,
    required this.themeColor,
    required this.icon,
    required this.planetAssociation,
    required this.weeks,
  });

  int get totalWeeks => weeks.length;
}

/// Base de datos centralizada de la Malla Curricular Docente (31 Semanas Oficiales organizadas por Planeta).
class TeacherCurriculumDatabase {
  TeacherCurriculumDatabase._();

  static List<CurriculumCompetence> getCompetencias() {
    return [
      // ═════════════════════════════════════════════════════════════════════════
      // COMPETENCIA 1 — PLANETA PRISMA (Ciencias e Indagación) — Semanas 1 a 4
      // ═════════════════════════════════════════════════════════════════════════
      const CurriculumCompetence(
        id: 1,
        title: 'COMPETENCIA 1',
        officialDescription:
            'Expresa los resultados obtenidos, a partir de la indagación de fenómenos y situaciones de la vida cotidiana, utilizando diferentes medios de comunicación y el método científico.',
        themeColor: AppColors.prisma,
        icon: Icons.biotech_rounded,
        planetAssociation: 'Prisma (Ciencias e Indagación)',
        weeks: [
          CurriculumWeek(
            weekNumber: 1,
            title: 'La Ciencia en Acción: Evolución, Tecnología y Sociedad',
            contents: [
              '1.1.1 Historia de la ciencia y su evolución en el tiempo.',
              '1.1.2 Relación entre avances tecnológicos y progreso social.',
              '1.1.3 La ciencia como actividad humana colaborativa y ética.',
            ],
            description:
                'Introducción a la ciencia moderna, su desarrollo a través de las eras y el impacto transformador de las tecnologías en la calidad de vida de las comunidades.',
            planetName: 'Prisma',
            planetColor: AppColors.prisma,
            slidesUrl: 'https://www.canva.com/design/DAHWl7lM8js/mOhgvI64u01ucTvazBWM9Q/watch?embed',
            learningObjectives: [
              'Reconocer el valor de los descubrimientos científicos cotidianos.',
              'Identificar el impacto social de la tecnología con visión ética.',
            ],
            inclusionTips: 'Utilizar líneas de tiempo ilustradas con pictogramas y contrastes altos.'
          ),
          CurriculumWeek(
            weekNumber: 2,
            title: 'El Camino del Descubrimiento: Método Científico y Reportes',
            contents: [
              '1.2.1 Etapas del método científico: Observación y planteamiento de preguntas.',
              '1.2.2 Formulación de hipótesis y diseño experimental controlado.',
              '1.2.3 Registro sistemático de datos y elaboración de reportes de indagación.',
            ],
            description:
                'Fundamentos del método científico aplicados a la resolución de problemas cotidianos y la comunicación rigurosa de hallazgos experimentales.',
            planetName: 'Prisma',
            planetColor: AppColors.prisma,
            slidesUrl: 'https://www.canva.com/design/DAHWlz1UWoo/jpddo6_AIOd7gN6YPLSDyg/watch?embed',
            learningObjectives: [
              'Estructurar preguntas de indagación basadas en la observación.',
              'Diseñar experimentos seguros registrando variables en tablas visuales.',
            ]
          ),
          CurriculumWeek(
            weekNumber: 3,
            title: 'El Laboratorio del Entorno y las Medidas del Universo',
            contents: [
              '1.2.4 Normas de bioseguridad y uso responsable del material de laboratorio.',
              '1.3.1 Magnitudes fundamentales del Sistema Internacional (SI).',
              '1.3.2 Instrumentos de medición: balanza, probeta, regla y cronómetro.',
              '1.3.3 Conversión de unidades y aplicaciones prácticas en el aula.',
            ],
            description:
                'Manejo de instrumentos de medición directa, factores de conversión y buenas prácticas de seguridad e higiene científica.',
            planetName: 'Prisma',
            planetColor: AppColors.prisma,
            slidesUrl: 'https://www.canva.com/design/DAHWlwKTQ98/N3JRV46lVEtMiN4rn_8hyw/watch?embed',
            learningObjectives: [
              'Operar instrumentos de medida con precisión y cuidado.',
              'Convertir unidades de longitud, masa y tiempo a escalas cotidianas.',
            ]
          ),
          CurriculumWeek(
            weekNumber: 4,
            title: 'Precisión Científica: Notación y Margen de Error',
            contents: [
              '1.3.4 Notación científica: números grandes y microscópicos.',
              '1.3.5 Fuentes de error experimental, incertidumbre y cifras significativas.',
            ],
            description:
                'Comprensión del orden de magnitud en el cosmos y el micromundo, junto con la estimación reflexiva del error en mediciones.',
            planetName: 'Prisma',
            planetColor: AppColors.prisma,
            slidesUrl: 'https://www.canva.com/design/DAHWgUBGbPg/JKIksrv6ZQeNiQpzpCrSQQ/watch?embed',
            learningObjectives: [
              'Expresar cantidades astronómicas y moleculares en notación científica.',
              'Analizar el margen de error y su relevancia en la ciencia.',
            ]
          ),
        ]
          ),

      // ═════════════════════════════════════════════════════════════════════════
      // COMPETENCIA 2 — PLANETA SIMBIOS (Educación Ambiental y Ecología) — Semanas 5 a 14
      // ═════════════════════════════════════════════════════════════════════════
      const CurriculumCompetence(
        id: 2,
        title: 'COMPETENCIA 2',
        officialDescription:
            'Comunica resultados de lo observado e indagado sobre la estructura del planeta Tierra, los ecosistemas, la biodiversidad y las acciones de mitigación y preservación ambiental.',
        themeColor: AppColors.simbios,
        icon: Icons.public_rounded,
        planetAssociation: 'Simbios (Educación Ambiental y Ecología)',
        weeks: [
          CurriculumWeek(
            weekNumber: 5,
            title: 'Dynamic Earth: Atmósfera, Clima y Gravedad',
            contents: [
              '2.1.1 Capas de la atmósfera y su papel protector para la vida.',
              '2.1.2 Factores meteorológicos: temperatura, presión y vientos.',
              '2.1.3 La gravedad terrestre y la órbita de nuestro planeta.',
            ],
            description:
                'Exploración de la envoltura gaseosa de la Tierra, las fuerzas gravitacionales y la dinámica de las capas atmosféricas.',
            planetName: 'Simbios',
            planetColor: AppColors.simbios,
            slidesUrl: 'https://www.canva.com/design/DAHYp5ZC3KE/HDS_ywTlND_bFRewc9wg6w/watch?embed',
            learningObjectives: [
              'Diferenciar las capas atmosféricas y su función protectora.',
              'Comprender cómo la atmósfera y la gravedad posibilitan la vida.',
            ]
          ),
          CurriculumWeek(
            weekNumber: 6,
            title: 'El Ciclo del Agua: Hidrósfera y Manejo Sustentable',
            contents: [
              '2.1.4 Distribución y propiedades del agua dulce y salada.',
              '2.1.5 Fases del ciclo hidrológico y balance hídrico.',
              '2.1.6 Cuencas hidrográficas y uso sustentable del agua.',
            ],
            description:
                'Análisis del ciclo hidrológico y la imperiosa necesidad del cuidado comunitario del agua potable y las cuencas.',
            planetName: 'Simbios',
            planetColor: AppColors.simbios,
            slidesUrl: 'https://www.canva.com/design/DAHYp1BI0Wc/MvfFSweJ_pZgMI7lPUQ2pQ/watch?embed',
            learningObjectives: [
              'Reconocer las fases del ciclo del agua mediante modelos visuales.',
              'Proponer acciones concretas de ahorro y saneamiento hídrico.',
            ]
          ),
          CurriculumWeek(
            weekNumber: 7,
            title: 'La Tierra Vibrante: Litósfera, Geotermia y Minería',
            contents: [
              '2.1.7 Estructura de la litósfera: corteza, manto y núcleo.',
              '2.1.8 Energía geotérmica y dinámica volcánica en Guatemala.',
              '2.1.9 Minerales, rocas e impacto ambiental de la minería.',
            ],
            description:
                'Fuerzas internas del planeta, la dinámica de placas tectónicas, vulcanismo y el aprovechamiento responsable de recursos geológicos.',
            planetName: 'Simbios',
            planetColor: AppColors.simbios,
            slidesUrl: 'https://www.canva.com/design/DAHYp0uAVL8/oW4eLABLwvjTZynqHOv6AQ/watch?embed',
            learningObjectives: [
              'Identificar las capas internas terrestres y sus propiedades térmicas.',
              'Explicar el origen de los terremotos y la formación volcánica.',
            ]
          ),
          CurriculumWeek(
            weekNumber: 8,
            title: 'Los Reinos de la Vida: Bosques, Animales y Plantas',
            contents: [
              '2.1.10 El suelo como recurso vivo: tipos, capas y conservación.',
              '2.2.1-Parte A Reino Plantae y Animalia: adaptaciones morfológicas y fisiológicas.',
            ],
            description:
                'Clasificación sistemática de la vida en la Tierra, centrándose en flora, fauna, conservación del suelo y sus extraordinarias adaptaciones.',
            planetName: 'Simbios',
            planetColor: AppColors.simbios,
            slidesUrl: 'https://www.canva.com/design/DAHYqLypi_g/b5HFiViuJ8ST2r6N99Onmg/watch?embed',
            learningObjectives: [
              'Clasificar organismos vivos según sus reinos biológicos.',
              'Reconocer adaptaciones de animales y plantas a sus hábitats.',
            ]
          ),
          CurriculumWeek(
            weekNumber: 9,
            title: 'Microcosmos y Redes de Vida: De Hongos a Ecosistemas',
            contents: [
              '2.2.1-Parte B Reino Fungi, Protista y Monera: descomponedores y microorganismos.',
              '2.2.2 Cadenas y redes tróficas: productores, consumidores y descomponedores.',
              '2.2.3 Flujo de energía y pirámides ecológicas en ecosistemas.',
              '2.2.4 Relaciones interespecíficas: simbiosis, mutualismo y competencia.',
            ],
            description:
                'El papel esencial de los microorganismos y descomponedores en el reciclaje de materia y las complejas redes tróficas.',
            planetName: 'Simbios',
            planetColor: AppColors.simbios,
            slidesUrl: 'https://www.canva.com/design/DAHYqCECcJM/Q1mjepk96RFfF0XrsinKWw/watch?embed',
            learningObjectives: [
              'Trazar redes tróficas y pirámides de biomasa de ecosistemas cercanos.',
              'Diferenciar relaciones ecológicas simbióticas.',
            ]
          ),
          CurriculumWeek(
            weekNumber: 10,
            title: 'Tesoros Biológicos: Biomas, Ciclos y Áreas Protegidas',
            contents: [
              '2.2.5 Principales biomas terrestres y acuáticos del mundo.',
              '2.2.6 Ciclos biogeoquímicos: carbono, nitrógeno y fósforo.',
              '2.2.7 Megabiodiversidad de Guatemala y especies endémicas.',
              '2.2.8 Áreas protegidas y reservas de biósfera (SIGAP).',
              '2.2.9 Especies en peligro de extinción y estrategias de conservación.',
            ],
            description:
                'Estudio de los grandes biomas de la biosfera, la circulación de nutrientes químicos y el valor de las reservas naturales de Guatemala.',
            planetName: 'Simbios',
            planetColor: AppColors.simbios,
            slidesUrl: 'https://www.canva.com/design/DAHYrJVe388/vWqY8dvFSzXpV4hjjgVxeA/watch?embed',
            learningObjectives: [
              'Mapear los principales biomas y su fauna característica.',
              'Comprender la importancia vital de las áreas protegidas.',
            ]
          ),
          CurriculumWeek(
            weekNumber: 11,
            title: 'Planeta Sustentable: Reforestación y Diagnóstico Ambiental',
            contents: [
              '2.3.1 Diagnóstico ambiental comunitario: identificación de problemáticas.',
              '2.3.2 Deforestación, pérdida de cobertura forestal y erosión.',
              '2.3.3 Proyectos de reforestación escolar y comunitaria.',
            ],
            description:
                'Metodologías de evaluación del entorno escolar y estrategias activas de reforestación con especies nativas.',
            planetName: 'Simbios',
            planetColor: AppColors.simbios,
            slidesUrl: 'https://www.canva.com/design/DAHYrAXbYms/mjlEh43gDE3pOrep5fTnog/watch?embed',
            learningObjectives: [
              'Realizar un diagnóstico ambiental del entorno escolar.',
              'Diseñar una propuesta participativa de reforestación.',
            ]
          ),
          CurriculumWeek(
            weekNumber: 12,
            title: 'Acción Ambiental: Equilibrio Ecológico y las 4R',
            contents: [
              '2.3.4 Gestión integral de residuos sólidos: Reducir, Reutilizar, Reciclar y Rechazar (4R).',
              '2.3.5 Contaminación del aire, agua y suelo: causas y efectos.',
              '2.3.6 Huella ecológica individual y huella de carbono.',
              '2.3.7 Energías renovables: solar, eólica, biomasa e hidroeléctrica.',
            ],
            description:
                'Hábitos sustentables para la gestión responsable de residuos y fomento de la economía circular y energías limpias.',
            planetName: 'Simbios',
            planetColor: AppColors.simbios,
            slidesUrl: 'https://www.canva.com/design/DAHYrA9CXKw/2WEzbyEPHFYYC2WzY6cW1w/watch?embed',
            learningObjectives: [
              'Aplicar la regla de las 4R en el hogar y en la escuela.',
              'Iniciar un proyecto de compostaje y reciclaje de plásticos.',
            ]
          ),
          CurriculumWeek(
            weekNumber: 13,
            title: 'Planeta en Alerta: Fenómenos Globales y Resiliencia',
            contents: [
              '2.4.1 Efecto invernadero natural y calentamiento global antropogénico.',
              '2.4.2 Cambio climático: evidencias, impactos y proyecciones.',
              '2.4.3 Fenómenos de El Niño y La Niña (ENSO) y su impacto en la región.',
            ],
            description:
                'Fundamentos científicos del calentamiento global, los gases de efecto invernadero y estrategias de resiliencia comunitaria.',
            planetName: 'Simbios',
            planetColor: AppColors.simbios,
            slidesUrl: 'https://www.canva.com/design/DAHYrH5eAQ8/Ox9V28l2w9-4kA8kituJfg/watch?embed',
            learningObjectives: [
              'Explicar el mecanismo físico-químico del efecto invernadero.',
              'Identificar medidas de adaptación ante eventos climáticos extremos.',
            ]
          ),
          CurriculumWeek(
            weekNumber: 14,
            title: 'Protegiendo Nuestro Entorno: Mitigación y Gestión de Riesgo',
            contents: [
              '2.4.4 Medidas de adaptación y mitigación frente al cambio climático.',
              '2.4.5 Gestión de riesgo de desastres: planes de evacuación y resiliencia comunitaria.',
            ],
            description:
                'Cultura de prevención de desastres, diseño de mapas de riesgo comunitario y rutas de evacuación seguras.',
            planetName: 'Simbios',
            planetColor: AppColors.simbios,
            slidesUrl: 'https://www.canva.com/design/DAHYrChpcZc/4JnKXpTOhSGBELC6EYuBGg/watch?embed',
            learningObjectives: [
              'Elaborar un mapa de riesgo y evacuación del centro educativo.',
              'Participar proactivamente en simulacros y brigadas de emergencia.',
            ]
          ),
        ]
          ),

      // ═════════════════════════════════════════════════════════════════════════
      // COMPETENCIA 3 — PLANETA VITALIA (Biología y Vida) — Semanas 15 a 23
      // ═════════════════════════════════════════════════════════════════════════
      const CurriculumCompetence(
        id: 3,
        title: 'COMPETENCIA 3',
        officialDescription:
            'Aplica conocimientos científicos sobre la célula, los sistemas del cuerpo humano, la nutrición integral, la salud sexual y la farmacología consciente para el bienestar individual y colectivo.',
        themeColor: AppColors.vitalia,
        icon: Icons.favorite_rounded,
        planetAssociation: 'Vitalia (Biología y Vida)',
        weeks: [
          CurriculumWeek(
            weekNumber: 15,
            title: 'Arquitectura Celular: Células, Tejidos y División',
            contents: [
              '3.1.1 Teoría celular y tipos de células: procariotas y eucariotas.',
              '3.1.2 Organelos celulares y sus funciones metabólicas.',
              '3.1.3 Ciclo celular: mitosis, meiosis y diferenciación en tejidos.',
            ],
            description:
                'La célula como unidad fundamental de la vida, su estructura ultra-microscópica y la diferenciación en tejidos biológicos.',
            planetName: 'Vitalia',
            planetColor: AppColors.vitalia,
            slidesUrl: 'https://www.canva.com/design/DAHYrFe2MMw/aQQiQLMdDkOALJGItbBfrQ/watch?embed',
            learningObjectives: [
              'Distinguir células vegetales y animales con sus organelos clave.',
              'Explicar el proceso de división celular y formación de tejidos.',
            ]
          ),
          CurriculumWeek(
            weekNumber: 16,
            title: 'Nutrición Integral: De las Plantas al Cuerpo Humano',
            contents: [
              '3.1.4 Fotosíntesis y respiración celular: balance energético.',
              '3.1.5 Nutrición autótrofa vs. heterótrofa.',
              '3.1.6 Sistema digestivo humano: órganos y procesos de absorción.',
              '3.1.7 Grupos alimenticios, dieta balanceada y valor nutricional.',
              '3.1.8 Trastornos nutricionales: desnutrición, anemia y obesidad.',
            ],
            description:
                'Principios de la nutrición biológica, diseño de dietas balanceadas según requerimientos etarios y fomento de hábitos saludables.',
            planetName: 'Vitalia',
            planetColor: AppColors.vitalia,
            slidesUrl: 'https://www.canva.com/design/DAHYrH24TTM/cCZx3Q_sTMANZmmIK5mEIg/watch?embed',
            learningObjectives: [
              'Clasificar alimentos según su aporte de nutrientes.',
              'Diseñar un menú saludable y balanceado con alimentos locales.',
            ]
          ),
          CurriculumWeek(
            weekNumber: 17,
            title: 'Estructura en Movimiento: Sistema Musculoesquelético',
            contents: [
              '3.2.1 Sistema locomotor: esqueleto, articulaciones y músculos esqueléticos.',
            ],
            description:
                'Funcionamiento coordinado de huesos, ligamentos y fibras musculares para el soporte, locomoción e higiene postural.',
            planetName: 'Vitalia',
            planetColor: AppColors.vitalia,
            slidesUrl: 'https://www.canva.com/design/DAHYrEkhheM/erNArIIO4UXoELex4pQQdw/watch?embed',
            learningObjectives: [
              'Identificar los principales huesos y grupos musculares.',
              'Reconocer pautas de ergonomía e higiene postural escolar.',
            ]
          ),
          CurriculumWeek(
            weekNumber: 18,
            title: 'El Motor de la Vida: Circulación y Reproducción',
            contents: [
              '3.2.2 Sistema cardiovascular: corazón, vasos sanguíneos y circulación mayor y menor.',
            ],
            description:
                'El flujo sanguíneo y el transporte de oxígeno celular, junto con las bases anatómicas del sistema cardiovascular.',
            planetName: 'Vitalia',
            planetColor: AppColors.vitalia,
            slidesUrl: 'https://www.canva.com/design/DAHYrJDzT-U/TG-eLAN9Led0rD7HPphxJw/watch?embed',
            learningObjectives: [
              'Explicar el recorrido circulatorio pulmonar y sistémico.',
              'Comprender las funciones biológicas del corazón.',
            ]
          ),
          CurriculumWeek(
            weekNumber: 19,
            title: 'Centro de Control y Defensa: Inmunidad y Sistema Nervioso',
            contents: [
              '3.2.3 Sistema inmunológico: defensas innatas, adaptativas y vacunación.',
              '3.2.4 Sistema nervioso central y periférico: neuronas, sinapsis y arcos reflejos.',
            ],
            description:
                'Mecanismos de defensa del organismo contra patógenos, el valor científico de la inmunización y el procesamiento neurológico de estímulos.',
            planetName: 'Vitalia',
            planetColor: AppColors.vitalia,
            slidesUrl: 'https://www.canva.com/design/DAHYrGL1fo0/6HSl9mk19W8eX1GeLhFkPg/watch?embed',
            learningObjectives: [
              'Describir cómo las vacunas fortalecen la respuesta inmune.',
              'Esquematizar la transmisión del impulso nervioso en la sinapsis.',
            ]
          ),
          CurriculumWeek(
            weekNumber: 20,
            title: 'Equidad y Responsabilidad: Sexo, Género y Salud Sexual',
            contents: [
              '3.3.1 Anatomía y fisiología de los aparatos reproductores femenino y masculino.',
              '3.3.2 Dimensiones de la sexualidad: afectividad, género, rol social y respeto.',
            ],
            description:
                'Desarrollo integral de la sexualidad humana con énfasis en la autoestima, equidad de género, respeto y toma de decisiones autónomas.',
            planetName: 'Vitalia',
            planetColor: AppColors.vitalia,
            slidesUrl: 'https://www.canva.com/design/DAHYrLOTomA/4q39iY07SF2-v8ohI9j1uA/watch?embed',
            learningObjectives: [
              'Fomentar relaciones afectivas basadas en el respeto mutuo.',
              'Identificar los derechos fundamentales en salud sexual.',
            ]
          ),
          CurriculumWeek(
            weekNumber: 21,
            title: 'Decisiones Conscientes: Sexualidad, Prevención y VIH/SIDA',
            contents: [
              '3.3.3 Salud sexual y reproductiva: derechos, planificación familiar y métodos anticonceptivos.',
              '3.3.4 Infecciones de Transmisión Sexual (ITS): causas, síntomas y prevención.',
              '3.3.5 VIH/SIDA: mitos, realidades, vías de transmisión y no discriminación.',
            ],
            description:
                'Información científica sobre prevención de ITS y embarazos no planificados, combatiendo estigmas con base biológica y empática.',
            planetName: 'Vitalia',
            planetColor: AppColors.vitalia,
            slidesUrl: 'https://www.canva.com/design/DAHYrPWXFcQ/4NAGgUDGTXE6Tu4329-DAA/watch?embed',
            learningObjectives: [
              'Diferenciar la efectividad de los métodos de prevención.',
              'Desmitificar el contagio del VIH promoviendo la empatía.',
            ]
          ),
          CurriculumWeek(
            weekNumber: 22,
            title: 'Sabiduría y Alerta: Medicina, Sustancias y Adicciones',
            contents: [
              '3.4.1 Medicina tradicional, plantas medicinales y saberes ancestrales de Guatemala.',
              '3.4.2 Sustancias psicoactivas: tabaco, alcohol y drogas ilícitas (efectos neurológicos y sociales).',
            ],
            description:
                'El valor del conocimiento botánico tradicional y la comprensión neurobiológica de los riesgos asociados al consumo de sustancias.',
            planetName: 'Vitalia',
            planetColor: AppColors.vitalia,
            slidesUrl: 'https://www.canva.com/design/DAHYrGlxZbg/HYV875spBLsyDHV-HkQBjQ/watch?embed',
            learningObjectives: [
              'Valorar el aporte de la medicina natural validada.',
              'Explicar los mecanismos neuronales de la adicción a sustancias.',
            ]
          ),
          CurriculumWeek(
            weekNumber: 23,
            title: 'Farmacología Consciente: Medicamentos y Autocuidado',
            contents: [
              '3.4.3 Medicamentos: uso racional, prescripción, dosis y riesgos de la automedicación.',
              '3.4.4 Salud mental, manejo del estrés y estilos de vida saludables en la adolescencia.',
            ],
            description:
                'Cultura del consumo informado de fármacos y alerta sobre la resistencia microbiana global por abuso de antibióticos.',
            planetName: 'Vitalia',
            planetColor: AppColors.vitalia,
            slidesUrl: 'https://www.canva.com/design/DAHYwDy3OJc/o-ZtiqJkTn-dFRfsYLTpDg/watch?embed',
            learningObjectives: [
              'Identificar la importancia de seguir prescripciones médicas exactas.',
              'Comprender el peligro de la superbacterias resistentes.',
            ]
          ),
        ]
          ),

      // ═════════════════════════════════════════════════════════════════════════
      // COMPETENCIA 4 — PLANETAS TITAN-Q (Química) Y KINETOS (Física) — Semanas 24 a 31
      // ═════════════════════════════════════════════════════════════════════════
      const CurriculumCompetence(
        id: 4,
        title: 'COMPETENCIA 4',
        officialDescription:
            'Explica fenómenos físicos y químicos que ocurren en la materia, los átomos, los enlaces y las leyes del movimiento y las fuerzas en el entorno.',
        themeColor: AppColors.kinetos,
        icon: Icons.flash_on_rounded,
        planetAssociation: 'Titan-Q y Kinetos (Química y Física)',
        weeks: [
          // ── TITAN-Q (Química y Materia) — Semanas 24 a 26 ─────────────────
          CurriculumWeek(
            weekNumber: 24,
            title: 'La Ciencia de la Materia: Mezclas, Propiedades y Cambios',
            contents: [
              '4.1.1 Propiedades generales y específicas de la materia: masa, volumen y densidad.',
              '4.1.2 Estados de agregación de la materia y cambios de fase.',
              '4.1.3 Sustancias puras, elementos, compuestos y mezclas (homogéneas y heterogéneas).',
            ],
            description:
                'Clasificación de sustancias puras y mezclas, cambios físicos y químicos, y técnicas de laboratorio para separar componentes.',
            planetName: 'Titan-Q',
            planetColor: AppColors.titanQ,
            slidesUrl: 'https://www.canva.com/design/DAHYwCSrVCg/wMgZMIQ4SWalYYZLL82Jwg/watch?embed',
            learningObjectives: [
              'Diferenciar mezclas de sustancias puras con ejemplos visuales.',
              'Seleccionar métodos de separación según propiedades físicas.',
            ]
          ),
          CurriculumWeek(
            weekNumber: 25,
            title: 'Viaje al Corazón del Átomo: Modelos y Tabla Periódica',
            contents: [
              '4.1.4 Modelos atómicos históricos: Dalton, Thomson, Rutherford y Bohr.',
              '4.1.5 Estructura atómica moderna: protones, neutrones, electrones y número atómico (Z).',
              '4.1.6 Organización de la Tabla Periódica: grupos, periodos y familias químicas.',
            ],
            description:
                'El átomo como bloque constructor del universo y la lógica organizativa de los elementos en la Tabla Periódica.',
            planetName: 'Titan-Q',
            planetColor: AppColors.titanQ,
            slidesUrl: 'https://www.canva.com/design/DAHYwHiKWS0/1wFpH8z10JQ9epjiieRLEQ/watch?embed',
            learningObjectives: [
              'Esquematizar la estructura atómica con sus partículas subatómicas.',
              'Ubicar elementos en la Tabla Periódica interpretando su número atómico.',
            ]
          ),
          CurriculumWeek(
            weekNumber: 26,
            title: 'De Elementos a Compuestos: Metales y Química Binaria',
            contents: [
              '4.1.7 Metales, no metales y metaloides: propiedades físicas y químicas.',
              '4.1.8 Enlaces químicos fundamentales: iónico y covalente.',
              '4.1.9 Nomenclatura química básica de compuestos binarios (óxidos e hidruros).',
            ],
            description:
                'La unión de átomos para formar nuevas sustancias, la regla del octeto y formulación química elemental.',
            planetName: 'Titan-Q',
            planetColor: AppColors.titanQ,
            slidesUrl: 'https://www.canva.com/design/DAHYwHiKWS0/1wFpH8z10JQ9epjiieRLEQ/watch?embed',
            learningObjectives: [
              'Distinguir enlaces iónicos de covalentes mediante transferencia de electrones.',
              'Nombrar y formular compuestos binarios sencillos.',
            ]
          ),

          // ── KINETOS (Física y Movimiento) — Semanas 27 a 31 ────────────────
          CurriculumWeek(
            weekNumber: 27,
            title: 'Vectores en el Espacio: Magnitudes Escalares y Métodos Gráficos',
            contents: [
              '4.2.1 Magnitudes escalares y vectoriales: diferencias y ejemplos cotidianos.',
              '4.2.2 Componentes de un vector: magnitud, dirección y sentido.',
              '4.2.3 Métodos gráficos para la suma de vectores (paralelogramo y polígono).',
            ],
            description:
                'Fundamentos geométricos del análisis vectorial, diferenciando magnitudes físicas como rapidez y velocidad.',
            planetName: 'Kinetos',
            planetColor: AppColors.kinetos,
            slidesUrl: 'https://www.canva.com/design/DAHYwBeFfJ4/viQuUqhgw3JpOqeQYhyhvg/watch?embed',
            learningObjectives: [
              'Diferenciar cantidades escalares de vectoriales en situaciones reales.',
              'Sumar vectores gráficamente con precisión de regla y transportador.',
            ]
          ),
          CurriculumWeek(
            weekNumber: 28,
            title: 'La Dinámica del Movimiento: MCU y MRUA Básico',
            contents: [
              '4.3.1 Conceptos de cinemática: posición, trayectoria, distancia y desplazamiento.',
              '4.3.2 Movimiento Rectilíneo Uniforme (MRU): velocidad constante y ecuación d = v · t.',
            ],
            description:
                'Descripción matemática y física del movimiento de objetos con aceleración constante y trayectorias circulares orbitales.',
            planetName: 'Kinetos',
            planetColor: AppColors.kinetos,
            slidesUrl: 'https://www.canva.com/design/DAHYwKDFT_M/rfAT06CBVoIMKfTgXEHILA/watch?embed',
            learningObjectives: [
              'Diferenciar trayectoria de desplazamiento.',
              'Explicar el concepto de velocidad y rapidez en MRU.',
            ]
          ),
          CurriculumWeek(
            weekNumber: 29,
            title: 'Física Matemática: Análisis de Gráficas y Ecuaciones del MRUA',
            contents: [
              '4.3.3 Movimiento Rectilíneo Uniformemente Acelerado (MRUA): aceleración y gráficas v-t y d-t.',
              '4.3.4 Caída libre y aceleración de la gravedad (g = 9.8 m/s²).',
            ],
            description:
                'Resolución de problemas de cinemática, cálculo de distancias de frenado, caída libre e interpretación de gráficas.',
            planetName: 'Kinetos',
            planetColor: AppColors.kinetos,
            slidesUrl: 'https://www.canva.com/design/DAHYwFtE7UI/jfryP_psZ25BuTw7NoLnAw/watch?embed',
            learningObjectives: [
              'Resolver problemas numéricos de cinemática paso a paso.',
              'Interpretar el significado físico del área bajo la curva v-t y la caída libre.',
            ]
          ),
          CurriculumWeek(
            weekNumber: 30,
            title: 'Universo en Acción: Las Leyes de Newton y la Fuerza',
            contents: [
              '4.4.1 Concepto de fuerza: tipos de fuerzas (contacto y a distancia).',
              '4.4.2 Primera Ley de Newton: Ley de la Inercia y aplicaciones.',
              '4.4.3 Segunda Ley de Newton: Fuerza, masa y aceleración (F = m · a).',
            ],
            description:
                'Las leyes que rigen el movimiento en todo el cosmos, ilustradas mediante cohetes espaciales y fenómenos cotidianos.',
            planetName: 'Kinetos',
            planetColor: AppColors.kinetos,
            slidesUrl: 'https://www.canva.com/design/DAHYwCIWkCc/cuulqZ8hB91zCfKX7XgkNg/watch?embed',
            learningObjectives: [
              'Demostrar experimentalmente la inercia y la aceleración.',
              'Calcular la fuerza necesaria para acelerar diversas masas.',
            ]
          ),
          CurriculumWeek(
            weekNumber: 31,
            title: 'Equilibrio y Análisis de Fuerzas: Diagramas de Cuerpo Libre',
            contents: [
              '4.4.4 Tercera Ley de Newton: Principio de acción y reacción.',
              '4.4.5 Diagramas de cuerpo libre (DCL) y condiciones de equilibrio estático.',
            ],
            description:
                'Integración final de la mecánica clásica mediante el trazado de fuerzas concurrentes y condiciones de equilibrio estático.',
            planetName: 'Kinetos',
            planetColor: AppColors.kinetos,
            slidesUrl: 'https://www.canva.com/design/DAHYwOgDCcw/6Fq68-_-P2TS5XHtDlw1Fw/watch?embed',
            learningObjectives: [
              'Construir diagramas de cuerpo libre precisos para diversas estructuras.',
              'Aplicar el principio de acción y reacción en sistemas físicos.',
            ]
          ),
        ]
          ),
    ];
  }

  /// Retorna la malla curricular de 31 semanas adaptada dinámicamente al grado académico seleccionado.
  static List<CurriculumCompetence> getCompetenciasForGrade(String grade) {
    final cleanGrade = grade.trim();
    if (cleanGrade == '1ro Básico') {
      return _getCompetencias1roBasico();
    } else if (cleanGrade == '3ro Básico') {
      return _getCompetencias3roBasico();
    } else if (cleanGrade == '4to Bachillerato') {
      return _getCompetencias4toBachillerato();
    } else if (cleanGrade == '5to Bachillerato') {
      return _getCompetencias5toBachillerato();
    }
    return getCompetencias(); // 2do Básico predeterminado
  }

  // ─────────────────────────────────────────────────────────────────────────
  // 1RO BÁSICO — CIENCIAS NATURALES 1
  // ─────────────────────────────────────────────────────────────────────────
  static List<CurriculumCompetence> _getCompetencias1roBasico() {
    final base = getCompetencias();
    return [
      CurriculumCompetence(
        id: 1,
        title: 'COMPETENCIA 1 (1ro Básico)',
        officialDescription:
            'Aplica conceptos, principios y propiedades de la materia y la energía, describiendo los fenómenos naturales y los pasos iniciales del método científico.',
        themeColor: AppColors.prisma,
        icon: Icons.biotech_rounded,
        planetAssociation: 'Prisma (Materia e Indagación Inicial)',
        weeks: base[0].weeks.map((w) {
          return CurriculumWeek(
            weekNumber: w.weekNumber,
            title: '${w.title} [1ro Básico]',
            contents: w.contents,
            description: 'Fundamentos iniciales de indagación y exploración científica adaptados para 1ro Básico: ${w.description}',
            planetName: w.planetName,
            planetColor: w.planetColor,
            slidesUrl: w.slidesUrl
          );
        }).toList()
          ),
      CurriculumCompetence(
        id: 2,
        title: 'COMPETENCIA 2 (1ro Básico)',
        officialDescription:
            'Describe la organización de la biósfera, las relaciones ecológicas y la importancia de la conservación de los recursos naturales en Guatemala.',
        themeColor: AppColors.simbios,
        icon: Icons.park_rounded,
        planetAssociation: 'Simbios (Ecosistemas y Recursos)',
        weeks: base[1].weeks.map((w) {
          return CurriculumWeek(
            weekNumber: w.weekNumber,
            title: '${w.title} [1ro Básico]',
            contents: w.contents,
            description: 'Conceptos fundamentales de ecología y biodiversidad para 1ro Básico: ${w.description}',
            planetName: w.planetName,
            planetColor: w.planetColor,
            slidesUrl: w.slidesUrl
          );
        }).toList()
          ),
      CurriculumCompetence(
        id: 3,
        title: 'COMPETENCIA 3 (1ro Básico)',
        officialDescription:
            'Explica la estructura de la célula como unidad fundamental de la vida, los niveles de organización biológica y la salud preventiva.',
        themeColor: AppColors.vitalia,
        icon: Icons.favorite_rounded,
        planetAssociation: 'Vitalia (La Célula y la Vida)',
        weeks: base[2].weeks.map((w) {
          return CurriculumWeek(
            weekNumber: w.weekNumber,
            title: '${w.title} [1ro Básico]',
            contents: w.contents,
            description: 'Biología celular y hábitos saludables para 1ro Básico: ${w.description}',
            planetName: w.planetName,
            planetColor: w.planetColor,
            slidesUrl: w.slidesUrl
          );
        }).toList()
          ),
      CurriculumCompetence(
        id: 4,
        title: 'COMPETENCIA 4 (1ro Básico)',
        officialDescription:
            'Identifica las propiedades físicas y químicas elementales de la materia y las formas básicas de manifestación de la energía.',
        themeColor: AppColors.titanQ,
        icon: Icons.science_rounded,
        planetAssociation: 'Titan-Q y Kinetos (Materia y Energía)',
        weeks: base[3].weeks.map((w) {
          return CurriculumWeek(
            weekNumber: w.weekNumber,
            title: '${w.title} [1ro Básico]',
            contents: w.contents,
            description: 'Propiedades de la materia y movimiento para 1ro Básico: ${w.description}',
            planetName: w.planetName,
            planetColor: w.planetColor,
            slidesUrl: w.slidesUrl
          );
        }).toList()
          ),
    ];
  }

  // ─────────────────────────────────────────────────────────────────────────
  // 3RO BÁSICO — CIENCIAS NATURALES 3
  // ─────────────────────────────────────────────────────────────────────────
  static List<CurriculumCompetence> _getCompetencias3roBasico() {
    final base = getCompetencias();
    return [
      CurriculumCompetence(
        id: 1,
        title: 'COMPETENCIA 1 (3ro Básico)',
        officialDescription:
            'Formula proyectos de investigación científica escolar rigurosos, analizando datos cuantitativos y evaluando el impacto de los avances científicos.',
        themeColor: AppColors.prisma,
        icon: Icons.biotech_rounded,
        planetAssociation: 'Prisma (Proyectos de Investigación)',
        weeks: base[0].weeks.map((w) {
          return CurriculumWeek(
            weekNumber: w.weekNumber,
            title: '${w.title} [3ro Básico]',
            contents: w.contents,
            description: 'Diseño avanzado de proyectos de indagación científica para 3ro Básico: ${w.description}',
            planetName: w.planetName,
            planetColor: w.planetColor,
            slidesUrl: w.slidesUrl
          );
        }).toList()
          ),
      CurriculumCompetence(
        id: 2,
        title: 'COMPETENCIA 2 (3ro Básico)',
        officialDescription:
            'Evalúa el impacto de las actividades humanas en el cambio climático global, proponiendo modelos de desarrollo sostenible y gestión de riesgos.',
        themeColor: AppColors.simbios,
        icon: Icons.park_rounded,
        planetAssociation: 'Simbios (Sostenibilidad Global)',
        weeks: base[1].weeks.map((w) {
          return CurriculumWeek(
            weekNumber: w.weekNumber,
            title: '${w.title} [3ro Básico]',
            contents: w.contents,
            description: 'Ecología avanzada y cambio climático para 3ro Básico: ${w.description}',
            planetName: w.planetName,
            planetColor: w.planetColor,
            slidesUrl: w.slidesUrl
          );
        }).toList()
          ),
      CurriculumCompetence(
        id: 3,
        title: 'COMPETENCIA 3 (3ro Básico)',
        officialDescription:
            'Explica los mecanismos de la herencia genética, el ADN, la biotecnología moderna y la teoría de la evolución biológica.',
        themeColor: AppColors.vitalia,
        icon: Icons.favorite_rounded,
        planetAssociation: 'Vitalia (Genética y Evolución)',
        weeks: base[2].weeks.map((w) {
          return CurriculumWeek(
            weekNumber: w.weekNumber,
            title: '${w.title} [3ro Básico]',
            contents: w.contents,
            description: 'Genética mendeliana, molecular y evolución para 3ro Básico: ${w.description}',
            planetName: w.planetName,
            planetColor: w.planetColor,
            slidesUrl: w.slidesUrl
          );
        }).toList()
          ),
      CurriculumCompetence(
        id: 4,
        title: 'COMPETENCIA 4 (3ro Básico)',
        officialDescription:
            'Aplica las leyes de la termodinámica, las reacciones químicas complejas, las ondas electromagnéticas y la astronomía moderna.',
        themeColor: AppColors.titanQ,
        icon: Icons.science_rounded,
        planetAssociation: 'Titan-Q y Kinetos (Reacciones y Ondas)',
        weeks: base[3].weeks.map((w) {
          return CurriculumWeek(
            weekNumber: w.weekNumber,
            title: '${w.title} [3ro Básico]',
            contents: w.contents,
            description: 'Física ondulatoria y transformaciones químicas para 3ro Básico: ${w.description}',
            planetName: w.planetName,
            planetColor: w.planetColor,
            slidesUrl: w.slidesUrl
          );
        }).toList()
          ),
    ];
  }

  // ─────────────────────────────────────────────────────────────────────────
  // 4TO BACHILLERATO — FÍSICA, QUÍMICA Y BIOLOGÍA GENERAL
  // ─────────────────────────────────────────────────────────────────────────
  static List<CurriculumCompetence> _getCompetencias4toBachillerato() {
    final base = getCompetencias();
    return [
      CurriculumCompetence(
        id: 1,
        title: 'COMPETENCIA 1 (4to Bachillerato)',
        officialDescription:
            'Aplica la epistemología de la ciencia y el análisis vectorial en la formulación de modelos predictivos y experimentales.',
        themeColor: AppColors.prisma,
        icon: Icons.biotech_rounded,
        planetAssociation: 'Prisma (Epistemología y Modelado)',
        weeks: base[0].weeks.map((w) {
          return CurriculumWeek(
            weekNumber: w.weekNumber,
            title: '${w.title} [4to Bachillerato]',
            contents: w.contents,
            description: 'Investigación científica y vectores para 4to Bachillerato: ${w.description}',
            planetName: w.planetName,
            planetColor: w.planetColor,
            slidesUrl: w.slidesUrl
          );
        }).toList()
          ),
      CurriculumCompetence(
        id: 2,
        title: 'COMPETENCIA 2 (4to Bachillerato)',
        officialDescription:
            'Analiza los ciclos biogeoquímicos planetarios y la termodinámica de los sistemas ecológicos abiertos.',
        themeColor: AppColors.simbios,
        icon: Icons.park_rounded,
        planetAssociation: 'Simbios (Termodinámica Ecológica)',
        weeks: base[1].weeks.map((w) {
          return CurriculumWeek(
            weekNumber: w.weekNumber,
            title: '${w.title} [4to Bachillerato]',
            contents: w.contents,
            description: 'Biología ambiental y sistemas biogeoquímicos para 4to Bachillerato: ${w.description}',
            planetName: w.planetName,
            planetColor: w.planetColor,
            slidesUrl: w.slidesUrl
          );
        }).toList()
          ),
      CurriculumCompetence(
        id: 3,
        title: 'COMPETENCIA 3 (4to Bachillerato)',
        officialDescription:
            'Explica la bioquímica celular, el metabolismo energético (fotosíntesis y respiración) y la fisiología de organismos complejos.',
        themeColor: AppColors.vitalia,
        icon: Icons.favorite_rounded,
        planetAssociation: 'Vitalia (Bioquímica y Fisiología)',
        weeks: base[2].weeks.map((w) {
          return CurriculumWeek(
            weekNumber: w.weekNumber,
            title: '${w.title} [4to Bachillerato]',
            contents: w.contents,
            description: 'Bioquímica celular y fisiología humana para 4to Bachillerato: ${w.description}',
            planetName: w.planetName,
            planetColor: w.planetColor,
            slidesUrl: w.slidesUrl
          );
        }).toList()
          ),
      CurriculumCompetence(
        id: 4,
        title: 'COMPETENCIA 4 (4to Bachillerato)',
        officialDescription:
            'Resuelve problemas de cinemática vectorial en dos dimensiones, estequiometría y enlaces químicos intermoleculares.',
        themeColor: AppColors.titanQ,
        icon: Icons.science_rounded,
        planetAssociation: 'Titan-Q y Kinetos (Física y Química General)',
        weeks: base[3].weeks.map((w) {
          return CurriculumWeek(
            weekNumber: w.weekNumber,
            title: '${w.title} [4to Bachillerato]',
            contents: w.contents,
            description: 'Cinemática 2D y estequiometría química para 4to Bachillerato: ${w.description}',
            planetName: w.planetName,
            planetColor: w.planetColor,
            slidesUrl: w.slidesUrl
          );
        }).toList()
          ),
    ];
  }

  // ─────────────────────────────────────────────────────────────────────────
  // 5TO BACHILLERATO — QUÍMICA ORGÁNICA, BIOQUÍMICA Y FÍSICA MODERNA
  // ─────────────────────────────────────────────────────────────────────────
  static List<CurriculumCompetence> _getCompetencias5toBachillerato() {
    final base = getCompetencias();
    return [
      CurriculumCompetence(
        id: 1,
        title: 'COMPETENCIA 1 (5to Bachillerato)',
        officialDescription:
            'Diseña investigaciones científicas avanzadas integrando sensores digitales, análisis estadístico y simulación computacional.',
        themeColor: AppColors.prisma,
        icon: Icons.biotech_rounded,
        planetAssociation: 'Prisma y Cíberon (Computación y Ciencia)',
        weeks: base[0].weeks.map((w) {
          return CurriculumWeek(
            weekNumber: w.weekNumber,
            title: '${w.title} [5to Bachillerato]',
            contents: w.contents,
            description: 'Modelado computacional y estadística científica para 5to Bachillerato: ${w.description}',
            planetName: w.planetName,
            planetColor: w.planetColor,
            slidesUrl: w.slidesUrl
          );
        }).toList()
          ),
      CurriculumCompetence(
        id: 2,
        title: 'COMPETENCIA 2 (5to Bachillerato)',
        officialDescription:
            'Evalúa la biotecnología vegetal, la ingeniería genética y la bioética en la conservación de la biodiversidad mesoamericana.',
        themeColor: AppColors.simbios,
        icon: Icons.park_rounded,
        planetAssociation: 'Simbios (Biotecnología y Bioética)',
        weeks: base[1].weeks.map((w) {
          return CurriculumWeek(
            weekNumber: w.weekNumber,
            title: '${w.title} [5to Bachillerato]',
            contents: w.contents,
            description: 'Biotecnología y bioética ambiental para 5to Bachillerato: ${w.description}',
            planetName: w.planetName,
            planetColor: w.planetColor,
            slidesUrl: w.slidesUrl
          );
        }).toList()
          ),
      CurriculumCompetence(
        id: 3,
        title: 'COMPETENCIA 3 (5to Bachillerato)',
        officialDescription:
            'Describe la síntesis de macromoléculas, los mecanismos de replicación del ADN y las rutas metabólicas celulares.',
        themeColor: AppColors.vitalia,
        icon: Icons.favorite_rounded,
        planetAssociation: 'Vitalia (Biología Molecular Avanzada)',
        weeks: base[2].weeks.map((w) {
          return CurriculumWeek(
            weekNumber: w.weekNumber,
            title: '${w.title} [5to Bachillerato]',
            contents: w.contents,
            description: 'Genómica y rutas metabólicas para 5to Bachillerato: ${w.description}',
            planetName: w.planetName,
            planetColor: w.planetColor,
            slidesUrl: w.slidesUrl
          );
        }).toList()
          ),
      CurriculumCompetence(
        id: 4,
        title: 'COMPETENCIA 4 (5to Bachillerato)',
        officialDescription:
            'Aplica conceptos de química orgánica, polímeros, electromagnetismo de Maxwell y física cuántica introductoria.',
        themeColor: AppColors.titanQ,
        icon: Icons.science_rounded,
        planetAssociation: 'Titan-Q y Kinetos (Química Orgánica y Física Moderna)',
        weeks: base[3].weeks.map((w) {
          return CurriculumWeek(
            weekNumber: w.weekNumber,
            title: '${w.title} [5to Bachillerato]',
            contents: w.contents,
            description: 'Química del carbono y física moderna para 5to Bachillerato: ${w.description}',
            planetName: w.planetName,
            planetColor: w.planetColor,
            slidesUrl: w.slidesUrl
          );
        }).toList()
          ),
    ];
  }
}
