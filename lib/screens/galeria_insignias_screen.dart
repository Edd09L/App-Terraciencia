import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../models/topic.dart';
import '../models/app_colors.dart';
import '../data/topics_database.dart';
import '../providers/progress_provider.dart';
import '../services/pdf_sticker_service.dart';

/// Pantalla unificada de la Galería de Insignias de Terraciencia.
///
/// Integra el esqueleto visual del álbum de estampitas:
/// - Cuadrícula adaptativa con capacidad para 40 espacios de insignias (4-5 columnas).
/// - Sistema interactivo de selección múltiple (checkbox / resaltado) para elegir estampitas a imprimir.
/// - Botón inferior flotante "PREPARAR STICKERS PARA MI ÁLBUM (PDF)" conectado a Printing.layoutPdf.
/// - Siluetas grises para stickers bloqueados y colores institucionales para desbloqueados.
/// - Simulador de Calificaciones integrado para pruebas de maestros y evaluadores.
class GaleriaInsigniasScreen extends StatefulWidget {
  final String studentName;

  const GaleriaInsigniasScreen({super.key, required this.studentName});

  @override
  State<GaleriaInsigniasScreen> createState() => _GaleriaInsigniasScreenState();
}

class _GaleriaInsigniasScreenState extends State<GaleriaInsigniasScreen> {
  String _filterPlanet = 'todos'; // Filtro por planeta
  bool _showCheatPanel = false;   // Controla la visibilidad del simulador de notas

  // Mapa de selección de insignias por ID para impresión
  final Map<String, bool> _selectedStickers = {};

  @override
  void initState() {
    super.initState();
    // Inicializar la selección de los 40 temas
    for (var topic in allTopics) {
      _selectedStickers[topic.id] = false;
    }
  }

  Color _getPlanetColor(String planetId) {
    return AppColors.forPlanet(planetId);
  }

  IconData _getPlanetIcon(String planetId) {
    switch (planetId) {
      case 'prisma':
        return Icons.wb_sunny_rounded;
      case 'ciberon':
        return Icons.memory_rounded;
      case 'kinetos':
        return Icons.speed_rounded;
      case 'titan_q':
        return Icons.science_rounded;
      case 'vitalia':
        return Icons.favorite_rounded;
      case 'simbios':
        return Icons.recycling_rounded;
      default:
        return Icons.star_rounded;
    }
  }

  String _getPlanetDisplayName(String planetId) {
    switch (planetId) {
      case 'prisma':
        return 'Prisma';
      case 'ciberon':
        return 'Cíberon';
      case 'kinetos':
        return 'Kinetos';
      case 'titan_q':
        return 'Titan-Q';
      case 'vitalia':
        return 'Vitalia';
      case 'simbios':
        return 'Simbios';
      default:
        return planetId;
    }
  }

  void _toggleSelectAll(bool selectAll, ProgressProvider provider) {
    setState(() {
      for (var topic in allTopics) {
        if (provider.isUnlocked(topic.id) || !selectAll) {
          _selectedStickers[topic.id] = selectAll;
        }
      }
    });
  }

  /// Genera e imprime las insignias seleccionadas en PDF usando el paquete Printing.
  Future<void> _imprimirStickersSeleccionados(ProgressProvider provider) async {
    // Obtener los temas seleccionados
    final selectedTopics = allTopics.where((t) => _selectedStickers[t.id] == true).toList();

    if (selectedTopics.isEmpty) {
      // Si no seleccionó ninguno específico, ofrecer los que estén desbloqueados
      final unlockedTopics = allTopics.where((t) => provider.isUnlocked(t.id)).toList();
      if (unlockedTopics.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '¡Aún no has seleccionado ni desbloqueado insignias para imprimir!',
              style: GoogleFonts.fredoka(fontWeight: FontWeight.bold, color: Colors.white),
            ),
            backgroundColor: AppColors.rojoOxido,
          ),
        );
        return;
      }
      // Usar servicio de planilla completa
      await PdfStickerService.generateAndPrint(unlockedTopics);
      return;
    }

    // Generar documento con los seleccionados
    final pdf = pw.Document(
      title: 'Terraciencia – Insignias Seleccionadas',
      author: 'Terraciencia',
    );

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(24),
        build: (pw.Context context) {
          return [
            pw.Center(
              child: pw.Column(
                children: [
                  pw.Text(
                    'ÁLBUM DE LOGROS - TERRACIENCIA',
                    style: pw.TextStyle(
                      fontSize: 20,
                      fontWeight: pw.FontWeight.bold,
                      color: PdfColor.fromInt(AppColors.mostazaDorado.value),
                    ),
                  ),
                  pw.SizedBox(height: 6),
                  pw.Text(
                    'Astronauta: ${widget.studentName.toUpperCase()}',
                    style: pw.TextStyle(
                      fontSize: 14,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                  pw.SizedBox(height: 4),
                  pw.Text(
                    'Planilla de ${selectedTopics.length} insignias seleccionadas para recortar y pegar en tu mural.',
                    style: const pw.TextStyle(fontSize: 11, color: PdfColors.grey700),
                  ),
                  pw.SizedBox(height: 16),
                  pw.Divider(thickness: 1.5),
                  pw.SizedBox(height: 16),
                ],
              ),
            ),
            pw.Wrap(
              spacing: 12,
              runSpacing: 12,
              alignment: pw.WrapAlignment.center,
              children: selectedTopics.map((topic) {
                final planetColor = _getPlanetColor(topic.planetId);
                return pw.Container(
                  width: 105,
                  height: 115,
                  decoration: pw.BoxDecoration(
                    color: PdfColors.white,
                    borderRadius: const pw.BorderRadius.all(pw.Radius.circular(12)),
                    border: pw.Border.all(
                      color: PdfColor.fromInt(planetColor.value),
                      width: 2.5,
                    ),
                  ),
                  padding: const pw.EdgeInsets.all(8),
                  child: pw.Column(
                    mainAxisAlignment: pw.MainAxisAlignment.center,
                    children: [
                      pw.Container(
                        width: 44,
                        height: 44,
                        decoration: pw.BoxDecoration(
                          shape: pw.BoxShape.circle,
                          color: PdfColor.fromInt(planetColor.value),
                        ),
                        alignment: pw.Alignment.center,
                        child: pw.Text(
                          '★',
                          style: const pw.TextStyle(
                            fontSize: 22,
                            color: PdfColors.white,
                          ),
                        ),
                      ),
                      pw.SizedBox(height: 6),
                      pw.Text(
                        topic.id,
                        style: pw.TextStyle(
                          fontSize: 10,
                          fontWeight: pw.FontWeight.bold,
                          color: PdfColors.black,
                        ),
                      ),
                      pw.SizedBox(height: 2),
                      pw.Text(
                        topic.title,
                        style: const pw.TextStyle(
                          fontSize: 7.5,
                          color: PdfColors.grey800,
                        ),
                        textAlign: pw.TextAlign.center,
                        maxLines: 2,
                        overflow: pw.TextOverflow.clip,
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ];
        },
      ),
    );

    // Lanzar la ventana nativa de impresión / guardado PDF
    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
      name: 'stickers_album_${widget.studentName.replaceAll(' ', '_')}.pdf',
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ProgressProvider>();

    // Filtrar los 40 temas según el planeta seleccionado
    final List<Topic> filteredTopics = allTopics.where((topic) {
      if (_filterPlanet == 'todos') return true;
      return topic.planetId == _filterPlanet;
    }).toList();

    // Contar completados y seleccionados
    final int totalStamps = allTopics.length; // 40 insignias
    final int unlockedStamps = allTopics.where((t) => provider.isUnlocked(t.id)).length;
    final int selectedCount = _selectedStickers.values.where((v) => v).length;
    final double progressPercent = totalStamps > 0 ? unlockedStamps / totalStamps : 0.0;

    return Scaffold(
      backgroundColor: const Color(0xFF000000),
      appBar: AppBar(
        title: Text(
          'Galería de Insignias (40 Espacios)',
          style: GoogleFonts.fredoka(fontWeight: FontWeight.bold, fontSize: 22),
        ),
        backgroundColor: AppColors.surface,
        elevation: 0,
        actions: [
          // ── Botón Seleccionar / Deseleccionar Todo ────────────────────────
          TextButton.icon(
            onPressed: () {
              final bool anySelected = selectedCount > 0;
              _toggleSelectAll(!anySelected, provider);
            },
            icon: Icon(
              selectedCount > 0 ? Icons.deselect_rounded : Icons.select_all_rounded,
              color: AppColors.mostazaDorado,
              size: 20,
            ),
            label: Text(
              selectedCount > 0 ? 'Deseleccionar' : 'Seleccionar Todo',
              style: GoogleFonts.fredoka(
                color: AppColors.mostazaDorado,
                fontSize: 13,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          // ── Simulador de Calificaciones (modo maestro) ───────────────────
          IconButton(
            icon: Icon(
              _showCheatPanel ? Icons.bug_report_rounded : Icons.bug_report_outlined,
              color: _showCheatPanel ? Colors.redAccent : Colors.white60,
            ),
            tooltip: 'Simulador de Calificaciones',
            onPressed: () {
              setState(() {
                _showCheatPanel = !_showCheatPanel;
              });
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // 1. Cabecera con Progreso del Estudiante y Filtros
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            color: const Color(0xFF0F0F0F),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Astronauta: ${widget.studentName}',
                      style: GoogleFonts.fredoka(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      '$unlockedStamps / $totalStamps Insignias Desbloqueadas',
                      style: GoogleFonts.fredoka(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: AppColors.mostazaDorado,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: LinearProgressIndicator(
                    value: progressPercent,
                    minHeight: 12,
                    backgroundColor: Colors.white10,
                    valueColor: AlwaysStoppedAnimation<Color>(AppColors.mostazaDorado),
                  ),
                ),
                const SizedBox(height: 12),

                // Filtro Horizontal de Planetas
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildFilterChip('todos', 'Ver Todas (40)', AppColors.mostazaDorado),
                      const SizedBox(width: 8),
                      _buildFilterChip('prisma', 'Prisma (3)', _getPlanetColor('prisma')),
                      const SizedBox(width: 8),
                      _buildFilterChip('ciberon', 'Cíberon (3)', _getPlanetColor('ciberon')),
                      const SizedBox(width: 8),
                      _buildFilterChip('kinetos', 'Kinetos (6)', _getPlanetColor('kinetos')),
                      const SizedBox(width: 8),
                      _buildFilterChip('titan_q', 'Titan-Q (6)', _getPlanetColor('titan_q')),
                      const SizedBox(width: 8),
                      _buildFilterChip('vitalia', 'Vitalia (12)', _getPlanetColor('vitalia')),
                      const SizedBox(width: 8),
                      _buildFilterChip('simbios', 'Simbios (10)', _getPlanetColor('simbios')),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // 2. Grilla de los 40 Espacios de Insignias (4-5 columnas adaptativas)
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 160, // 4-5 columnas dinámicas según resolución
                mainAxisSpacing: 14,
                crossAxisSpacing: 14,
                childAspectRatio: 0.82,
              ),
              itemCount: filteredTopics.length,
              itemBuilder: (context, index) {
                final topic = filteredTopics[index];
                final bool isUnlocked = provider.isUnlocked(topic.id);
                final double score = provider.getScore(topic.id);
                final Color pColor = _getPlanetColor(topic.planetId);
                final bool isSelected = _selectedStickers[topic.id] ?? false;

                return _buildStampCard(topic, isUnlocked, score, pColor, isSelected);
              },
            ),
          ),

          // 3. Botón Inferior Anclado para Preparar Stickers / Imprimir PDF
          Container(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
            decoration: BoxDecoration(
              color: AppColors.surface,
              border: const Border(top: BorderSide(color: Colors.white12, width: 1)),
            ),
            child: Row(
              children: [
                if (selectedCount > 0)
                  Container(
                    margin: const EdgeInsets.only(right: 14),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    decoration: BoxDecoration(
                      color: AppColors.mostazaDorado.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.mostazaDorado, width: 1.5),
                    ),
                    child: Text(
                      '$selectedCount Seleccionadas',
                      style: GoogleFonts.fredoka(
                        fontWeight: FontWeight.bold,
                        color: AppColors.mostazaDorado,
                        fontSize: 14,
                      ),
                    ),
                  ),
                Expanded(
                  child: SizedBox(
                    height: 52,
                    child: ElevatedButton.icon(
                      onPressed: () => _imprimirStickersSeleccionados(provider),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.mostazaDorado,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 4,
                      ),
                      icon: const Icon(Icons.print_rounded, size: 22),
                      label: Text(
                        selectedCount > 0
                            ? 'IMPRIMIR $selectedCount STICKERS SELECCIONADOS'
                            : 'PREPARAR STICKERS PARA MI ÁLBUM (PDF)',
                        style: GoogleFonts.fredoka(
                          fontWeight: FontWeight.w900,
                          fontSize: 14,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // 4. Panel Simulador de Calificaciones (Cheat Panel)
          if (_showCheatPanel) _buildCheatControls(provider),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String filterId, String label, Color color) {
    final bool isSelected = _filterPlanet == filterId;
    return GestureDetector(
      onTap: () {
        setState(() {
          _filterPlanet = filterId;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.25) : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? color : Colors.white24,
            width: 1.5,
          ),
        ),
        child: Text(
          label,
          style: GoogleFonts.fredoka(
            color: isSelected ? Colors.white : Colors.white70,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildStampCard(Topic topic, bool isUnlocked, double score, Color planetColor, bool isSelected) {
    return InkWell(
      onTap: () {
        // Toggle de selección al tocar la tarjeta
        setState(() {
          _selectedStickers[topic.id] = !isSelected;
        });
      },
      onLongPress: () => _showStampDetailsModal(topic, isUnlocked, score, planetColor),
      borderRadius: BorderRadius.circular(20),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: isSelected
              ? planetColor.withOpacity(0.2)
              : const Color(0xFF0F0F0F),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? AppColors.mostazaDorado
                : (isUnlocked ? planetColor.withOpacity(0.7) : Colors.white10),
            width: isSelected ? 3.0 : (isUnlocked ? 2.0 : 1.5),
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.mostazaDorado.withOpacity(0.4),
                    blurRadius: 14,
                    spreadRadius: 2,
                  )
                ]
              : (isUnlocked
                  ? [
                      BoxShadow(
                        color: planetColor.withOpacity(0.25),
                        blurRadius: 10,
                        spreadRadius: 1,
                      )
                    ]
                  : []),
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Checkbox visual de selección en la esquina superior derecha
            Positioned(
              top: 8,
              right: 8,
              child: Container(
                width: 22,
                height: 22,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isSelected
                      ? AppColors.mostazaDorado
                      : Colors.black45,
                  border: Border.all(
                    color: isSelected ? AppColors.mostazaDorado : Colors.white38,
                    width: 1.5,
                  ),
                ),
                child: isSelected
                    ? const Icon(Icons.check, size: 14, color: Colors.white)
                    : null,
              ),
            ),

            // Fondo con icono difuso
            Opacity(
              opacity: isUnlocked ? 0.08 : 0.03,
              child: Icon(
                _getPlanetIcon(topic.planetId),
                size: 70,
                color: isUnlocked ? planetColor : Colors.white,
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Align(
                    alignment: Alignment.topLeft,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: isUnlocked ? planetColor.withOpacity(0.2) : Colors.white.withOpacity(0.04),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        topic.id,
                        style: GoogleFonts.fredoka(
                          fontSize: 10,
                          fontWeight: FontWeight.w900,
                          color: isUnlocked ? planetColor : Colors.white38,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ),
                  Icon(
                    isUnlocked ? _getPlanetIcon(topic.planetId) : Icons.lock_outline_rounded,
                    size: 36,
                    color: isUnlocked ? planetColor : Colors.white24,
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        topic.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                        style: GoogleFonts.fredoka(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: isUnlocked ? Colors.white : Colors.white38,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        isUnlocked ? '${score.toInt()} pts' : 'Bloqueado',
                        style: GoogleFonts.fredoka(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: isUnlocked ? Colors.greenAccent : Colors.white30,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showStampDetailsModal(Topic topic, bool isUnlocked, double score, Color planetColor) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.8),
      builder: (context) {
        return Center(
          child: Container(
            width: 420,
            margin: const EdgeInsets.all(24),
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: const Color(0xFF0F0F0F),
              borderRadius: BorderRadius.circular(28),
              border: Border.all(
                color: isUnlocked ? planetColor : Colors.white24,
                width: 3.0,
              ),
              boxShadow: [
                BoxShadow(
                  color: isUnlocked ? planetColor.withOpacity(0.25) : Colors.black26,
                  blurRadius: 30,
                  spreadRadius: 2,
                )
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: isUnlocked ? planetColor.withOpacity(0.15) : Colors.white.withOpacity(0.04),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    isUnlocked ? _getPlanetIcon(topic.planetId) : Icons.lock_rounded,
                    size: 64,
                    color: isUnlocked ? planetColor : Colors.white24,
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: isUnlocked ? planetColor.withOpacity(0.2) : Colors.white.withOpacity(0.04),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        topic.id,
                        style: GoogleFonts.fredoka(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: isUnlocked ? planetColor : Colors.white30,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Mundo ${_getPlanetDisplayName(topic.planetId)}',
                      style: GoogleFonts.fredoka(
                        fontSize: 14,
                        color: Colors.white54,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  isUnlocked ? topic.title : 'Insignia Bloqueada',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.fredoka(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  isUnlocked
                      ? topic.description
                      : '¡Consigue una nota de 90 puntos o más en las actividades de este tema para desbloquear la insignia de tu galería!',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.fredoka(
                    fontSize: 14,
                    color: Colors.white70,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 24),
                if (isUnlocked)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      color: Colors.greenAccent.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.greenAccent.withOpacity(0.5)),
                    ),
                    child: Text(
                      'Calificación: ${score.toInt()} / 100 puntos',
                      style: GoogleFonts.fredoka(
                        color: Colors.greenAccent,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isUnlocked ? planetColor : Colors.white24,
                      foregroundColor: isUnlocked ? Colors.black : Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: Text(
                      '¡ENTENDIDO!',
                      style: GoogleFonts.fredoka(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildCheatControls(ProgressProvider provider) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: Color(0xFF161616),
        border: Border(top: BorderSide(color: Colors.redAccent, width: 2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              const Icon(Icons.bug_report, color: Colors.redAccent, size: 20),
              const SizedBox(width: 8),
              Text(
                'SIMULADOR DE NOTAS (MAESTRO / PRUEBAS DUA)',
                style: GoogleFonts.fredoka(
                  color: Colors.redAccent,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                  letterSpacing: 0.5,
                ),
              ),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.close, color: Colors.white60, size: 18),
                onPressed: () => setState(() => _showCheatPanel = false),
              )
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => provider.unlockAll(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  icon: const Icon(Icons.lock_open),
                  label: const Text('DESBLOQUEAR TODO'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => provider.resetProgress(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red.shade800,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  icon: const Icon(Icons.lock_reset),
                  label: const Text('BLOQUEAR TODO'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Simular nota de un tema específico:',
            style: GoogleFonts.fredoka(color: Colors.white70, fontSize: 12),
          ),
          const SizedBox(height: 6),
          SizedBox(
            height: 140,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                _buildQuickScoreAdjuster(provider, 'Prisma', ['PRIS-01', 'PRIS-02', 'PRIS-03']),
                _buildQuickScoreAdjuster(provider, 'Cíberon', ['CIBE-01', 'CIBE-02', 'CIBE-03']),
                _buildQuickScoreAdjuster(provider, 'Kinetos', ['KINE-01', 'KINE-02', 'KINE-03', 'KINE-04', 'KINE-05', 'KINE-06']),
                _buildQuickScoreAdjuster(provider, 'Titan-Q', ['TITA-01', 'TITA-02', 'TITA-03', 'TITA-04', 'TITA-05', 'TITA-06']),
                _buildQuickScoreAdjuster(provider, 'Vitalia', ['VITAL-01', 'VITAL-02', 'VITAL-03', 'VITAL-04', 'VITAL-05', 'VITAL-06', 'VITAL-07', 'VITAL-08', 'VITAL-09', 'VITAL-10', 'VITAL-11', 'VITAL-12']),
                _buildQuickScoreAdjuster(provider, 'Simbios', ['SIMB-01', 'SIMB-02', 'SIMB-03', 'SIMB-04', 'SIMB-05', 'SIMB-06', 'SIMB-07', 'SIMB-08', 'SIMB-09', 'SIMB-10']),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickScoreAdjuster(ProgressProvider provider, String planetName, List<String> codes) {
    return Container(
      width: 200,
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.03),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            planetName,
            style: GoogleFonts.fredoka(fontWeight: FontWeight.bold, color: Colors.yellow, fontSize: 13),
          ),
          const SizedBox(height: 6),
          Expanded(
            child: ListView.builder(
              itemCount: codes.length,
              itemBuilder: (context, idx) {
                final String code = codes[idx];
                final double currentScore = provider.getScore(code);
                final bool isUnlocked = provider.isUnlocked(code);

                return Padding(
                  padding: const EdgeInsets.only(bottom: 4.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(code, style: GoogleFonts.fredoka(fontSize: 11, color: Colors.white70)),
                      Row(
                        children: [
                          GesturefulButton(
                            label: '-10',
                            onTap: () => provider.setScore(code, currentScore - 10),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${currentScore.toInt()}',
                            style: GoogleFonts.fredoka(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: isUnlocked ? Colors.greenAccent : Colors.redAccent,
                            ),
                          ),
                          const SizedBox(width: 4),
                          GesturefulButton(
                            label: '+10',
                            onTap: () => provider.setScore(code, currentScore + 10),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class GesturefulButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const GesturefulButton({super.key, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        decoration: BoxDecoration(
          color: Colors.white12,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(
          label,
          style: GoogleFonts.fredoka(fontSize: 10, color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
