import '../models/topic.dart';

/// Temas del Planeta Cíberon — Tecnología e Informática.
const List<Topic> temasCiberon = [
  Topic(
    id: 'CIBE-01',
    title: 'Inventos Tecnológicos Históricos',
    description: 'Cómo la rueda, el microscopio y el internet cambiaron nuestras vidas.',
    planetId: 'ciberon',
    type: TopicType.presentation,
    contentUrl: 'placeholder_canva_cibe01',
  ),
  Topic(
    id: 'CIBE-02',
    title: 'Ciencias de la Computación',
    description: 'Aprende cómo las máquinas siguen instrucciones lógicas paso a paso.',
    planetId: 'ciberon',
    type: TopicType.simulation,
    contentUrl: 'widget_simulador_algoritmos',
  ),
  Topic(
    id: 'CIBE-03',
    title: 'Ética y Salud Digital',
    description: 'Usa las pantallas y redes sociales de forma segura, balanceada y responsable.',
    planetId: 'ciberon',
    type: TopicType.exercise,
    contentUrl: 'placeholder_canva_cibe03',
  ),
];
