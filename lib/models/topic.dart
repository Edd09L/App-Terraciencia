/// Clasificación del tipo de contenido de un tema.
enum TopicType {
  presentation, // Presentación o contenido expositivo (Canva, video, lectura)
  exercise,     // Actividad práctica o ejercicio guiado
  simulation,   // Widget o simulación interactiva embebida
  mixed,        // Combinación de presentación y actividad
}

/// Modelo de datos para un tema o micro-módulo (estampita del álbum).
class Topic {
  final String id;           // Identificador único (ej: 'PRIS-01')
  final String title;        // Título del tema (ej: 'Conocimiento Científico')
  final String description;  // Breve descripción o descripción en lectura fácil
  final String planetId;     // Identificador del planeta al que pertenece
  final TopicType type;      // Clasificación del tipo de contenido
  final String? contentUrl;  // Ruta al widget o recurso de contenido (opcional)
  final String? badgeAssetPath; // Ruta al asset SVG/PNG de la insignia (opcional)

  const Topic({
    required this.id,
    required this.title,
    required this.description,
    required this.planetId,
    this.type = TopicType.presentation, // Por defecto es una presentación
    this.contentUrl,
    this.badgeAssetPath,
  });
}
