import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/lesson_content.dart';

/// Widget de la Fase 1 — Aprender.
///
/// Contiene:
/// - [PageView] con diapositivas (imágenes + texto en lectura fácil).
/// - Botón de glosario emergente ([AlertDialog]).
/// - Contenedor condicional para modelo 3D (.glb) usando model_viewer_plus.
///
/// Diseño DUA: múltiples formas de representación (visual, textual, 3D).
class LessonPhaseLearn extends StatefulWidget {
  /// Lista de diapositivas para el PageView.
  final List<LessonSlide> slides;

  /// Entradas del glosario emergente.
  final List<GlossaryEntry> glossary;

  /// Ruta al modelo 3D (.glb), si existe.
  final String? model3dPath;

  /// Color temático del planeta para la consistencia visual.
  final Color themeColor;

  /// Factor de escala de texto (modo proyección).
  final double textScaleFactor;

  const LessonPhaseLearn({
    super.key,
    required this.slides,
    this.glossary = const [],
    this.model3dPath,
    required this.themeColor,
    this.textScaleFactor = 1.0,
  });

  @override
  State<LessonPhaseLearn> createState() => _LessonPhaseLearnState();
}

class _LessonPhaseLearnState extends State<LessonPhaseLearn> {
  late PageController _pageController;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // ── Barra de acciones: Glosario ──────────────────────────────────
        if (widget.glossary.isNotEmpty)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                onPressed: () => _showGlossaryDialog(context),
                icon: Icon(Icons.menu_book_rounded,
                    color: widget.themeColor, size: 22),
                label: Text(
                  'Glosario',
                  style: GoogleFonts.fredoka(
                    color: widget.themeColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 14 * widget.textScaleFactor,
                  ),
                ),
                style: TextButton.styleFrom(
                  backgroundColor: widget.themeColor.withOpacity(0.1),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                ),
              ),
            ),
          ),

        // ── PageView de Diapositivas ─────────────────────────────────────
        Expanded(
          flex: 3,
          child: widget.slides.isEmpty
              ? Center(
                  child: Text(
                    'No hay diapositivas disponibles.',
                    style: GoogleFonts.fredoka(
                        color: Colors.white38,
                        fontSize: 16 * widget.textScaleFactor),
                  ),
                )
              : Column(
                  children: [
                    Expanded(
                      child: PageView.builder(
                        controller: _pageController,
                        itemCount: widget.slides.length,
                        onPageChanged: (index) {
                          setState(() => _currentPage = index);
                        },
                        itemBuilder: (context, index) {
                          return _buildSlide(widget.slides[index]);
                        },
                      ),
                    ),
                    // Indicador de página (dots)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(
                          widget.slides.length,
                          (index) => AnimatedContainer(
                            duration: const Duration(milliseconds: 250),
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            width: _currentPage == index ? 24 : 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: _currentPage == index
                                  ? widget.themeColor
                                  : widget.themeColor.withOpacity(0.25),
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
        ),

        // ── Contenedor de Modelo 3D (.glb) ──────────────────────────────
        if (widget.model3dPath != null) ...[
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Icon(Icons.view_in_ar_rounded,
                    color: widget.themeColor, size: 20),
                const SizedBox(width: 8),
                Text(
                  'Modelo 3D Interactivo',
                  style: GoogleFonts.fredoka(
                    color: widget.themeColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 14 * widget.textScaleFactor,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            flex: 2,
            child: Container(
              margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              decoration: BoxDecoration(
                color: const Color(0xFF0A0A0A),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: widget.themeColor.withOpacity(0.3),
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: widget.themeColor.withOpacity(0.1),
                    blurRadius: 20,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(18),
                child: _build3DViewer(),
              ),
            ),
          ),
        ],
      ],
    );
  }

  /// Construye una diapositiva individual.
  Widget _buildSlide(LessonSlide slide) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF0F0F0F),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: widget.themeColor.withOpacity(0.2),
          width: 1.5,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Título de la diapositiva
            Text(
              slide.title,
              style: GoogleFonts.fredoka(
                fontSize: 22 * widget.textScaleFactor,
                fontWeight: FontWeight.w800,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 16),

            // Imagen o placeholder (soporta SVG y PNG/JPG)
            if (slide.svgPath != null)
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: SvgPicture.asset(
                    slide.svgPath!,
                    fit: BoxFit.contain,
                    width: double.infinity,
                    placeholderBuilder: (context) => _buildImagePlaceholder(),
                  ),
                ),
              )
            else if (slide.imagePath != null)
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Image.asset(
                    slide.imagePath!,
                    fit: BoxFit.contain,
                    width: double.infinity,
                    errorBuilder: (context, error, stackTrace) {
                      return _buildImagePlaceholder();
                    },
                  ),
                ),
              )
            else
              Expanded(child: _buildImagePlaceholder()),

            const SizedBox(height: 16),

            // Descripción en lectura fácil
            Text(
              slide.description,
              style: GoogleFonts.fredoka(
                fontSize: 16 * widget.textScaleFactor,
                color: Colors.white70,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Placeholder visual cuando no hay imagen disponible.
  Widget _buildImagePlaceholder() {
    return Container(
      decoration: BoxDecoration(
        color: widget.themeColor.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: widget.themeColor.withOpacity(0.15),
          width: 1,
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.image_rounded,
              size: 48,
              color: widget.themeColor.withOpacity(0.3),
            ),
            const SizedBox(height: 8),
            Text(
              'Imagen próximamente',
              style: GoogleFonts.fredoka(
                color: widget.themeColor.withOpacity(0.4),
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Construye el visor de modelo 3D.
  /// Usa un placeholder hasta que se integre model_viewer_plus.
  Widget _build3DViewer() {
    // TODO: Reemplazar con ModelViewer de model_viewer_plus cuando esté configurado.
    // Ejemplo de integración:
    // return ModelViewer(
    //   src: widget.model3dPath!,
    //   alt: 'Modelo 3D interactivo',
    //   autoRotate: true,
    //   cameraControls: true,
    //   backgroundColor: const Color(0xFF0A0A0A),
    // );
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.0, end: 1.0),
            duration: const Duration(seconds: 2),
            curve: Curves.easeInOut,
            builder: (context, value, child) {
              return Transform.rotate(
                angle: value * 6.28,
                child: child,
              );
            },
            child: Icon(
              Icons.view_in_ar_rounded,
              size: 64,
              color: widget.themeColor.withOpacity(0.5),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Modelo 3D: ${widget.model3dPath}',
            textAlign: TextAlign.center,
            style: GoogleFonts.fredoka(
              color: widget.themeColor.withOpacity(0.6),
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Toca y arrastra para rotar',
            style: GoogleFonts.fredoka(
              color: Colors.white30,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  /// Muestra el diálogo de glosario emergente (accesibilidad cognitiva).
  void _showGlossaryDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.85),
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF0F0F0F),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
            side: BorderSide(color: widget.themeColor.withOpacity(0.4), width: 2),
          ),
          title: Row(
            children: [
              Icon(Icons.menu_book_rounded, color: widget.themeColor, size: 28),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Glosario de Términos',
                  style: GoogleFonts.fredoka(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 20 * widget.textScaleFactor,
                  ),
                ),
              ),
            ],
          ),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.separated(
              shrinkWrap: true,
              itemCount: widget.glossary.length,
              separatorBuilder: (_, __) => Divider(
                color: widget.themeColor.withOpacity(0.15),
                height: 24,
              ),
              itemBuilder: (context, index) {
                final entry = widget.glossary[index];
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: widget.themeColor.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        entry.term,
                        style: GoogleFonts.fredoka(
                          color: widget.themeColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 16 * widget.textScaleFactor,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      entry.definition,
                      style: GoogleFonts.fredoka(
                        color: Colors.white70,
                        fontSize: 14 * widget.textScaleFactor,
                        height: 1.4,
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                '¡ENTENDIDO!',
                style: GoogleFonts.fredoka(
                  color: widget.themeColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
