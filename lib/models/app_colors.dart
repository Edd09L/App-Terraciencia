import 'package:flutter/material.dart';

/// Paleta oficial e institucional de Terraciencia.
///
/// Definición centralizada y fija de todos los colores oficiales del sistema:
/// - Prisma: #4B0082 (Índigo Profundo)
/// - Ciberon: #8B6508 (Dorado / Ámbar)
/// - Kinetos: #9E2A2B (Rojo Rubí)
/// - Vitalia: #A1005B (Magenta Vértice)
/// - Simbios: #1B5E20 (Verde Esmeralda)
/// - Titan-Q: #004F77 (Azul Océano)
class AppColors {
  AppColors._();

  // --- Paleta Oficial de Planetas (Códigos HEX Exactos) ---
  static const Color prisma = Color(0xFF4B0082);   // #4B0082 (Índigo Profundo)
  static const Color ciberon = Color(0xFF8B6508);  // #8B6508 (Dorado / Ámbar)
  static const Color kinetos = Color(0xFF9E2A2B);  // #9E2A2B (Rojo Rubí)
  static const Color vitalia = Color(0xFFA1005B);  // #A1005B (Magenta Vértice)
  static const Color simbios = Color(0xFF1B5E20);  // #1B5E20 (Verde Esmeralda)
  static const Color titanQ = Color(0xFF004F77);   // #004F77 (Azul Océano)
  static const Color noosferis = Color(0xFF8B6508); // #8B6508 (Dorado / Sabiduría)

  // --- Nombres Descriptivos ---
  static const Color indigoProfundo = prisma;
  static const Color doradoAmbar = ciberon;
  static const Color rojoRubi = kinetos;
  static const Color magentaVertice = vitalia;
  static const Color verdeEsmeralda = simbios;
  static const Color azulOceano = titanQ;

  // --- Alias para compatibilidad con código existente ---
  static const Color violetaOscuro = prisma;
  static const Color mostazaDorado = ciberon;
  static const Color rojoOxido = kinetos;
  static const Color magentaOscuro = vitalia;
  static const Color verdeBosque = simbios;
  static const Color azulPetroleo = titanQ;
  static const Color cafeMarron = simbios;

  // --- Colores Base y de Fondo ---
  static const Color background = Color(0xFF000000);
  static const Color surface = Color(0xFF0F0F0F);
  static const Color surfaceElevated = Color(0xFF161616);
  static const Color cardBorder = Color(0x33FFFFFF);

  /// Obtiene el color oficial asociado al ID de un planeta.
  static Color forPlanet(String planetId) {
    final cleanId = planetId
        .toLowerCase()
        .replaceAll('-', '_')
        .replaceAll('í', 'i')
        .replaceAll('é', 'e');
    switch (cleanId) {
      case 'prisma':
        return prisma;
      case 'ciberon':
        return ciberon;
      case 'kinetos':
        return kinetos;
      case 'vitalia':
        return vitalia;
      case 'simbios':
        return simbios;
      case 'titan_q':
      case 'titanq':
        return titanQ;
      case 'noosferis':
        return noosferis;
      default:
        return doradoAmbar;
    }
  }
}

