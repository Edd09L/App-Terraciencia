import '../models/topic.dart';

/// Temas del Planeta Kinetos — Física y Medición.
const List<Topic> temasKinetos = [
  Topic(
    id: 'KINE-01',
    title: 'El Sistema Internacional',
    description: 'Aprende las unidades fundamentales: metro, kilogramo y segundo.',
    planetId: 'kinetos',
    type: TopicType.presentation,
    contentUrl: 'https://www.canva.com/design/DAHYwBeFfJ4/viQuUqhgw3JpOqeQYhyhvg/watch?embed',
  ),
  Topic(
    id: 'KINE-02',
    title: 'Conversión de Unidades',
    description: 'Aprende trucos visuales para pasar de unidades grandes a pequeñas.',
    planetId: 'kinetos',
    type: TopicType.exercise,
    contentUrl: 'https://www.canva.com/design/DAHYwKDFT_M/rfAT06CBVoIMKfTgXEHILA/watch?embed',
  ),
  Topic(
    id: 'KINE-03',
    title: 'Notación Científica',
    description: 'El superpoder matemático para escribir números gigantes o microscópicos.',
    planetId: 'kinetos',
    type: TopicType.presentation,
    contentUrl: 'https://www.canva.com/design/DAHYwFtE7UI/jfryP_psZ25BuTw7NoLnAw/watch?embed',
  ),
  Topic(
    id: 'KINE-04',
    title: '¿Qué es el Movimiento?',
    description: 'Explora conceptos de posición, trayectoria, distancia y tiempo.',
    planetId: 'kinetos',
    type: TopicType.presentation,
    contentUrl: 'https://www.canva.com/design/DAHYwCIWkCc/cuulqZ8hB91zCfKX7XgkNg/watch?embed',
  ),
  Topic(
    id: 'KINE-05',
    title: 'Movimiento Rectilíneo Uniforme',
    description: 'Viaja en línea recta y a velocidad constante con la fórmula v=d/t.',
    planetId: 'kinetos',
    type: TopicType.simulation,
    contentUrl: 'widget_simulador_mru',
  ),
  Topic(
    id: 'KINE-06',
    title: 'Fuerzas y Equilibrio Estático',
    description: 'Descubre qué pasa cuando fuerzas opuestas se empujan y se cancelan.',
    planetId: 'kinetos',
    type: TopicType.exercise,
    contentUrl: 'https://www.canva.com/design/DAHYwOgDCcw/6Fq68-_-P2TS5XHtDlw1Fw/watch?embed',
  ),
];
