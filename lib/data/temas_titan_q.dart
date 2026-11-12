import '../models/topic.dart';

/// Temas del Planeta Titan-Q — Química y Materia.
const List<Topic> temasTitanQ = [
  Topic(
    id: 'TITA-01',
    title: 'Propiedades de la Materia',
    description: 'Diferencia masa y volumen de propiedades específicas como la densidad.',
    planetId: 'titan_q',
    type: TopicType.presentation,
    contentUrl: 'https://www.canva.com/design/DAHYwCSrVCg/wMgZMIQ4SWalYYZLL82Jwg/watch?embed',
  ),
  Topic(
    id: 'TITA-02',
    title: 'El Átomo y sus Modelos',
    description: 'Viaja en el tiempo para ver cómo los científicos imaginaban los átomos.',
    planetId: 'titan_q',
    type: TopicType.presentation,
    contentUrl: 'https://www.canva.com/design/DAHYwHiKWS0/1wFpH8z10JQ9epjiieRLEQ/watch?embed',
  ),
  Topic(
    id: 'TITA-03',
    title: 'Elementos y Tabla Periódica',
    description: 'El catálogo de ingredientes del universo y sus símbolos químicos.',
    planetId: 'titan_q',
    type: TopicType.simulation,
    contentUrl: 'widget_tabla_interactiva',
  ),
  Topic(
    id: 'TITA-04',
    title: 'Sustancias Puras y Compuestos',
    description: 'Aprende cómo se unen las moléculas de agua y otras recetas fijas.',
    planetId: 'titan_q',
    type: TopicType.presentation,
    contentUrl: 'https://www.canva.com/design/DAHYwHiKWS0/1wFpH8z10JQ9epjiieRLEQ/watch?embed',
  ),
  Topic(
    id: 'TITA-05',
    title: 'Mezclas Homogéneas',
    description: 'Soluciones cotidianas donde los ingredientes no se ven a simple vista.',
    planetId: 'titan_q',
    type: TopicType.exercise,
    contentUrl: 'https://www.canva.com/design/DAHYwCSrVCg/wMgZMIQ4SWalYYZLL82Jwg/watch?embed',
  ),
  Topic(
    id: 'TITA-06',
    title: 'Mezclas Heterogéneas',
    description: 'Aprende métodos físicos para separar agua, aceite, arena y piedras.',
    planetId: 'titan_q',
    type: TopicType.simulation,
    contentUrl: 'widget_simulador_separacion',
  ),
];
