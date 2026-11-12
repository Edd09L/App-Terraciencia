import '../models/topic.dart';
import 'temas_prisma.dart';
import 'temas_ciberon.dart';
import 'temas_kinetos.dart';
import 'temas_titan_q.dart';
import 'temas_vitalia.dart';
import 'temas_simbios.dart';

/// Lista global de todos los temas de la Vía Láctea del Saber.
///
/// Agrega las listas individuales de cada planeta en orden de aparición
/// en el mapa estelar. Úsala en la Galería de Insignias y en el
/// ProgressProvider para inicializar el estado de progreso.
final List<Topic> allTopics = [
  ...temasPrisma,   // 3  temas  — Ciencias Naturales
  ...temasCiberon,  // 3  temas  — Tecnología
  ...temasKinetos,  // 6  temas  — Física
  ...temasTitanQ,   // 6  temas  — Química
  ...temasVitalia,  // 12 temas  — Biología
  ...temasSimbios,  // 10 temas  — Ed. Ambiental
]; // Total: 40 temas
