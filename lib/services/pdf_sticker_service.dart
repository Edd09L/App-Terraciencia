import 'dart:math' show min;
import 'dart:typed_data';
import 'package:flutter/services.dart' show rootBundle;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../models/topic.dart';

/// Servicio estático que genera y abre el diálogo nativo de impresión/descarga
/// para una planilla de stickers de insignias de Terraciencia.
///
/// Usa los paquetes [pdf] y [printing] ya declarados en pubspec.yaml.
///
/// Diseño del documento:
/// - Formato A4 vertical, márgenes de 14 px.
/// - Encabezado minimalista: logo monocromático + subtítulo descriptivo gris.
/// - Cuadrícula 6 × 7 (42 celdas por página, ≈ 28 mm c/u → cabe con 40 stickers).
/// - Paginación automática si hay más de 42 insignias.
class PdfStickerService {
  // ─── Paleta de colores corporativa ──────────────────────────────────────────
  static const PdfColor _blue  = PdfColor(0.0627, 0.2275, 0.3608); // #103A5C
  static const PdfColor _grey  = PdfColor(0.42, 0.42, 0.42);       // #6B6B6B texto sutil

  // ─── Colores por planeta (espejo de AppColors en la UI) ───────────────
  static PdfColor _planetColor(String planetId) {
    switch (planetId.toLowerCase().replaceAll('-', '_')) {
      case 'prisma':  return const PdfColor.fromInt(0xFF4B0082); // #4B0082 Índigo Profundo
      case 'ciberon': return const PdfColor.fromInt(0xFF8B6508); // #8B6508 Dorado / Ámbar
      case 'kinetos': return const PdfColor.fromInt(0xFF9E2A2B); // #9E2A2B Rojo Rubí
      case 'titan_q': return const PdfColor.fromInt(0xFF004F77); // #004F77 Azul Océano
      case 'vitalia': return const PdfColor.fromInt(0xFFA1005B); // #A1005B Magenta Vértice
      case 'simbios': return const PdfColor.fromInt(0xFF1B5E20); // #1B5E20 Verde Esmeralda
      default:        return const PdfColor.fromInt(0xFF8B6508); // #8B6508
    }
  }

  static String _planetName(String planetId) {
    const names = <String, String>{
      'prisma':  'Prisma',
      'ciberon': 'Cíberon',
      'kinetos': 'Kinetos',
      'titan_q': 'Titan-Q',
      'vitalia': 'Vitalia',
      'simbios': 'Simbios',
    };
    return names[planetId] ?? planetId;
  }

  // ─── Método principal ────────────────────────────────────────────────────────

  /// Genera el documento PDF y abre el diálogo nativo de impresión / descarga.
  ///
  /// [unlockedTopics] – lista de temas ya desbloqueados por el estudiante.
  /// Solo incluye los temas que el usuario ha ganado (calificación ≥ 90).
  static Future<void> generateAndPrint(List<Topic> unlockedTopics) async {
    if (unlockedTopics.isEmpty) return;

    // ── Fuentes (Roboto via PdfGoogleFonts – requiere conexión en primera carga)
    final pw.Font fontBold    = await PdfGoogleFonts.robotoBold();
    final pw.Font fontRegular = await PdfGoogleFonts.robotoRegular();
    final pw.Font fontLight   = await PdfGoogleFonts.robotoLight();

    // ── Cargar logo corporativo monocromático desde assets ───────────────────
    pw.ImageProvider? logoImage;
    try {
      final ByteData logoBytes =
          await rootBundle.load('assets/images/Versión monocromatica.png');
      logoImage = pw.MemoryImage(logoBytes.buffer.asUint8List());
    } catch (_) {
      // Si el asset no está disponible, el encabezado se renderiza sin logo
      logoImage = null;
    }

    // ── Dimensiones de página y cuadrícula ──────────────────────────────────
    // A4: 595.28 × 841.89 pt
    // Margen reducido a 14 pt para aprovechar espacio
    const double pageMargin   = 14.0;
    const double headerHeight = 50.0;   // Encabezado minimalista compacto
    const double afterHeader  = 8.0;
    const int    cols         = 6;      // 6 columnas → 6 × 7 = 42 celdas/pág
    const double cellSpacing  = 5.0;

    // Ancho útil: 595.28 − 2 × 14 = 567.28 pt
    // Celda: (567.28 − 5 × 5) / 6 ≈ 90.5 pt (≈ 31.9 mm, sticker ~28 mm)
    const double cellW = 90.0;
    const double cellH = 90.0;

    // Alto útil: 841.89 − 2 × 14 − 50 − 8 = 755.89 pt
    // Filas: (755.89 + 5) / (90 + 5) ≈ 8 filas → 48 por hoja (usamos 7 = 42)
    const int rowsPerPage = 7;
    const int perPage     = cols * rowsPerPage; // 42

    final double headerWidth = PdfPageFormat.a4.width - pageMargin * 2;

    final doc = pw.Document(
      title:    'Terraciencia – Planilla de Stickers de Logros',
      author:   'Terraciencia',
      subject:  'Planilla de Stickers – Segundo Básico',
    );

    // ── Paginación automática ───────────────────────────────────────────────
    int start = 0;
    while (start < unlockedTopics.length) {
      final int end        = min(start + perPage, unlockedTopics.length);
      final List<Topic> pageItems = unlockedTopics.sublist(start, end);
      start = end;

      doc.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          margin:     const pw.EdgeInsets.all(pageMargin),
          build: (pw.Context ctx) {
            return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.stretch,
              children: [
                // 1. Encabezado minimalista con logo
                _buildHeader(
                  fontBold:    fontBold,
                  fontLight:   fontLight,
                  width:       headerWidth,
                  height:      headerHeight,
                  logoImage:   logoImage,
                ),
                pw.SizedBox(height: afterHeader),

                // 2. Cuadrícula de stickers
                ..._buildGrid(
                  pageItems, cols, cellW, cellH, cellSpacing,
                  fontBold, fontRegular,
                ),
              ],
            );
          },
        ),
      );
    }

    // ── Abrir diálogo nativo de impresión / descarga ────────────────────────
    await Printing.layoutPdf(
      onLayout: (_) async => doc.save(),
      name:     'Terraciencia_Stickers_Logros.pdf',
    );
  }

  // ─── Encabezado minimalista ──────────────────────────────────────────────────

  /// Encabezado limpio y profesional:
  /// Logo monocromático (izquierda) + divisor vertical sutil + texto descriptivo.
  static pw.Widget _buildHeader({
    required pw.Font           fontBold,
    required pw.Font           fontLight,
    required double            width,
    required double            height,
    required pw.ImageProvider? logoImage,
  }) {
    return pw.Container(
      width:  width,
      height: height,
      decoration: const pw.BoxDecoration(
        color: PdfColors.white,
        border: pw.Border(
          bottom: pw.BorderSide(color: PdfColor(0.88, 0.88, 0.88), width: 0.8),
        ),
      ),
      child: pw.Padding(
        padding: const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 6),
        child: pw.Row(
          crossAxisAlignment: pw.CrossAxisAlignment.center,
          children: [
            // ── Logo monocromático ──────────────────────────────────────────
            if (logoImage != null) ...[
              pw.Image(
                logoImage,
                width:  170,
                height: height - 14,
                fit:    pw.BoxFit.contain,
              ),
              // Divisor vertical sutil
              pw.Container(
                width:  0.8,
                height: height - 18,
                margin: const pw.EdgeInsets.symmetric(horizontal: 12),
                color:  const PdfColor(0.80, 0.80, 0.80),
              ),
            ] else ...[
              // Fallback vectorial si el asset no carga
              _buildPlanetIcon(size: 36),
              pw.SizedBox(width: 10),
              pw.Text(
                'Terraciencia',
                style: pw.TextStyle(
                  font:      fontBold,
                  fontSize:  16,
                  color:     _blue,
                ),
              ),
              pw.Container(
                width:  0.8,
                height: height - 18,
                margin: const pw.EdgeInsets.symmetric(horizontal: 12),
                color:  const PdfColor(0.80, 0.80, 0.80),
              ),
            ],

            // ── Texto descriptivo ───────────────────────────────────────────
            pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              mainAxisAlignment:  pw.MainAxisAlignment.center,
              children: [
                pw.Text(
                  'Planilla de Stickers de Logros',
                  style: pw.TextStyle(
                    font:      fontBold,
                    fontSize:  12,
                    color:     _blue,
                  ),
                ),
                pw.SizedBox(height: 3),
                pw.Text(
                  'Segundo Básico  ·  Ciencias Naturales y Tecnología',
                  style: pw.TextStyle(
                    font:      fontLight,
                    fontSize:  8.5,
                    color:     _grey,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Fallback vectorial del imagotipo: globo terráqueo + anillo orbital.
  static pw.Widget _buildPlanetIcon({required double size}) {
    return pw.CustomPaint(
      size: PdfPoint(size, size),
      painter: (PdfGraphics canvas, PdfPoint s) {
        final double cx = s.x / 2;
        final double cy = s.y / 2;
        const double globeR = 11.0;
        const double ringRx = 18.0;
        const double ringRy =  6.5;
        const double nodeR  =  2.5;

        canvas.setFillColor(_blue);
        canvas.drawEllipse(cx - globeR, cy - globeR, globeR * 2, globeR * 2);
        canvas.fillPath();

        canvas.setStrokeColor(_blue);
        canvas.setLineWidth(1.8);
        canvas.drawEllipse(cx - ringRx, cy - ringRy, ringRx * 2, ringRy * 2);
        canvas.strokePath();

        canvas.setFillColor(_blue);
        canvas.drawEllipse(cx + ringRx - nodeR, cy - nodeR, nodeR * 2, nodeR * 2);
        canvas.fillPath();
      },
    );
  }

  // ─── Constructor de la cuadrícula ───────────────────────────────────────────

  /// Genera las filas de la cuadrícula de stickers para una página.
  static List<pw.Widget> _buildGrid(
    List<Topic> items,
    int    cols,
    double cellW,
    double cellH,
    double spacing,
    pw.Font fontBold,
    pw.Font fontRegular,
  ) {
    final int totalRows = (items.length / cols).ceil();
    final List<pw.Widget> rows = [];

    for (int r = 0; r < totalRows; r++) {
      final int rowStart = r * cols;
      final int rowEnd   = min(rowStart + cols, items.length);
      final List<Topic> rowItems = items.sublist(rowStart, rowEnd);

      rows.add(
        pw.Padding(
          padding: pw.EdgeInsets.only(bottom: r < totalRows - 1 ? spacing : 0),
          child: pw.Row(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Celdas de stickers reales
              ...rowItems.map((topic) => pw.Padding(
                padding: pw.EdgeInsets.only(right: spacing),
                child:   _buildStickerCell(topic, cellW, cellH, fontBold, fontRegular),
              )),
              // Relleno invisible para completar filas parciales
              ...List.generate(
                cols - rowItems.length,
                (_) => pw.SizedBox(width: cellW + spacing, height: cellH),
              ),
            ],
          ),
        ),
      );
    }
    return rows;
  }

  // ─── Celda individual de sticker ────────────────────────────────────────────

  /// Construye la celda imprimible de una insignia:
  /// bordes redondeados coloreados por planeta, ícono circular central,
  /// código ID, título (2 líneas máx.) y nombre del planeta.
  static pw.Widget _buildStickerCell(
    Topic   topic,
    double  width,
    double  height,
    pw.Font fontBold,
    pw.Font fontRegular,
  ) {
    final PdfColor col = _planetColor(topic.planetId);

    final PdfColor lightCol = PdfColor(
      col.red   * 0.20 + 0.80,
      col.green * 0.20 + 0.80,
      col.blue  * 0.20 + 0.80,
    );

    return pw.Container(
      width:  width,
      height: height,
      decoration: pw.BoxDecoration(
        color:        PdfColors.white,
        borderRadius: pw.BorderRadius.circular(8),
        border:       pw.Border.all(color: col, width: 2.0),
      ),
      child: pw.Padding(
        padding: const pw.EdgeInsets.all(4.5),
        child: pw.Column(
          mainAxisAlignment:  pw.MainAxisAlignment.spaceAround,
          crossAxisAlignment: pw.CrossAxisAlignment.center,
          children: [
            // ① Código del tema (badge de color)
            pw.Container(
              padding: const pw.EdgeInsets.symmetric(horizontal: 4, vertical: 1.5),
              decoration: pw.BoxDecoration(
                color:        col,
                borderRadius: pw.BorderRadius.circular(4),
              ),
              child: pw.Text(
                topic.id,
                style: pw.TextStyle(
                  font:     fontBold,
                  fontSize: 6,
                  color:    PdfColors.white,
                ),
              ),
            ),

            // ② Ícono circular del planeta (vectorial)
            _buildPlanetCircle(col: col, lightCol: lightCol, size: 32),

            // ③ Título del tema (máx. 2 líneas)
            pw.Text(
              topic.title,
              textAlign: pw.TextAlign.center,
              maxLines:  2,
              style: pw.TextStyle(
                font:     fontRegular,
                fontSize: 6.5,
                color:    PdfColors.black,
              ),
            ),

            // ④ Nombre del planeta (etiqueta de color)
            pw.Text(
              _planetName(topic.planetId),
              style: pw.TextStyle(
                font:     fontBold,
                fontSize: 5.5,
                color:    col,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Círculo decorativo que representa visualmente el planeta:
  /// anillo exterior claro + núcleo coloreado centrado.
  static pw.Widget _buildPlanetCircle({
    required PdfColor col,
    required PdfColor lightCol,
    required double   size,
  }) {
    return pw.CustomPaint(
      size: PdfPoint(size, size),
      painter: (PdfGraphics canvas, PdfPoint s) {
        canvas.setFillColor(lightCol);
        canvas.drawEllipse(0, 0, s.x, s.y);
        canvas.fillPath();

        final double innerR = s.x * 0.35;
        final double cx     = s.x / 2;
        final double cy     = s.y / 2;
        canvas.setFillColor(col);
        canvas.drawEllipse(cx - innerR, cy - innerR, innerR * 2, innerR * 2);
        canvas.fillPath();

        canvas.setStrokeColor(col);
        canvas.setLineWidth(1.2);
        canvas.drawEllipse(0.6, 0.6, s.x - 1.2, s.y - 1.2);
        canvas.strokePath();
      },
    );
  }
}
