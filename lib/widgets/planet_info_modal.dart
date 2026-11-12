import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
// ignore: avoid_web_libraries_in_flutter, deprecated_member_use
import 'dart:js' as js; // Utilizado para interactuar con la Web Speech API
import '../models/planet_data.dart';
import '../models/topic.dart';
import '../models/teacher_curriculum_model.dart';
import '../data/topics_database.dart';
import '../services/ai_curiosity_service.dart';
import '../screens/class_topic_detail_screen.dart';

/// Alias para soportar ambas denominaciones del modal en el sistema
typedef PlanetDetailModal = PlanetInfoModal;

/// Modal de Planeta con Reestructuración Espacial y Lógica de IA Contextualizada:
/// 1. Parte Superior Izquierda: Barra de búsqueda estilo píldora ("Buscar en [Planeta]").
/// 2. Parte Superior Derecha: Botón flotante de audio para lectura TTS del dato curioso y botón cerrar.
/// 3. Parte Central: Opciones y portal de ingreso al planeta.
/// 4. Parte Inferior (Centro): Contenedor para el Dato Curioso generado por IA según la temática del planeta.
class PlanetInfoModal extends StatefulWidget {
  final PlanetData planet;

  const PlanetInfoModal({super.key, required this.planet});

  @override
  State<PlanetInfoModal> createState() => _PlanetInfoModalState();
}

class _PlanetInfoModalState extends State<PlanetInfoModal> {
  bool _isSpeaking = false;

  // ── Buscador interno filtrado por planeta ──────────────────────────
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  bool _showSearchDropdown = false;
  Topic? _selectedTopic;

  // ── Estado del Dato Curioso por IA ─────────────────────────────────
  String _currentCuriosityFact = '';
  bool _isLoadingAICuriosity = false;
  late final PlanetAIContext _aiContext;

  @override
  void initState() {
    super.initState();
    _aiContext = AICuriosityService.instance.getContextForPlanet(widget.planet.name);
    _currentCuriosityFact = widget.planet.funFact;
    _fetchCuriosityFromAI();
  }

  @override
  void dispose() {
    _stopReading();
    _searchController.dispose();
    super.dispose();
  }

  // ── Petición contextual a la API de IA (Gemini) ────────────────────
  Future<void> _fetchCuriosityFromAI() async {
    if (_isLoadingAICuriosity) return;
    setState(() => _isLoadingAICuriosity = true);

    try {
      final fact = await AICuriosityService.instance
          .fetchCuriosity(planetName: widget.planet.name);
      if (mounted) {
        setState(() {
          _currentCuriosityFact = fact;
          _isLoadingAICuriosity = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _currentCuriosityFact = widget.planet.funFact;
          _isLoadingAICuriosity = false;
        });
      }
    }
  }

  // ── Mapeo nombre de planeta → planetId ─────────────────────────────
  String get _planetId {
    final name = widget.planet.name
        .toLowerCase()
        .replaceAll('é', 'e')
        .replaceAll('í', 'i')
        .replaceAll('ó', 'o')
        .replaceAll('-', '_');
    const map = {
      'prisma': 'prisma',
      'ciberon': 'ciberon',
      'kinetos': 'kinetos',
      'titan_q': 'titan_q',
      'vitalia': 'vitalia',
      'simbios': 'simbios',
      'noosferis': 'noosferis',
    };
    return map[name] ?? 'prisma';
  }

  List<Topic> get _planetTopics {
    final pid = _planetId;
    if (pid.isEmpty) return [];

    final baseTopics = allTopics.where((t) => t.planetId == pid).toList();

    // Semanas oficiales del currículo nacional para este planeta
    final competencias = TeacherCurriculumDatabase.getCompetencias();
    final curriculumTopics = <Topic>[];
    for (final comp in competencias) {
      for (final w in comp.weeks) {
        final pName = (w.planetName ?? '').toLowerCase();
        final normalizedPid = pid.replaceAll('_', '').replaceAll('-', '');
        if (pName.contains(normalizedPid) || normalizedPid.contains(pName)) {
          final titleWithSemana = w.title.toLowerCase().startsWith('semana ')
              ? w.title
              : 'Semana ${w.weekNumber}: ${w.title}';
          final exists = baseTopics.any((bt) =>
              bt.title.toLowerCase().contains('semana ${w.weekNumber}') ||
              bt.id == '${pid}_tema_${w.weekNumber}');
          if (!exists) {
            curriculumTopics.add(
              Topic(
                id: '${pid}_semana_${w.weekNumber}',
                title: titleWithSemana,
                description: w.description,
                planetId: pid,
                contentUrl: w.slidesUrl,
              ),
            );
          }
        }
      }
    }

    return [...baseTopics, ...curriculumTopics];
  }

  List<Topic> get _searchResults {
    if (_searchQuery.trim().isEmpty) return [];
    final q = _searchQuery.trim().toLowerCase();
    return _planetTopics.where((t) {
      // ÚNICAMENTE se muestran los temas/semanas oficiales cuyo título empiece con "Semana "
      if (!t.title.trim().toLowerCase().startsWith('semana ')) {
        return false;
      }
      return t.title.toLowerCase().contains(q) ||
          t.id.toLowerCase().contains(q) ||
          t.description.toLowerCase().contains(q);
    }).toList();
  }

  // ── Extracción dinámica del número de semana ────────────────────────
  int _extractWeekNumber(Topic topic) {
    final titleMatch = RegExp(r'[Ss]emana\s*(\d+)').firstMatch(topic.title);
    if (titleMatch != null) {
      final parsed = int.tryParse(titleMatch.group(1)!);
      if (parsed != null) return parsed;
    }
    final idMatch = RegExp(r'(\d+)').firstMatch(topic.id);
    if (idMatch != null) {
      final parsed = int.tryParse(idMatch.group(1)!);
      if (parsed != null) return parsed;
    }
    return 1;
  }

  // ── Lector de Voz TTS del Dato Curioso ─────────────────────────────
  void _toggleAudioReading() {
    if (_isSpeaking) {
      _stopReading();
    } else {
      _startReading();
    }
  }

  void _startReading() {
    if (kIsWeb) {
      try {
        final headerTitle = AICuriosityService.instance.getAreaHeaderTitle(widget.planet.name);
        final textToRead = '$headerTitle. $_currentCuriosityFact';
        js.context.callMethod('speakText', [textToRead]);
        setState(() => _isSpeaking = true);
      } catch (e) {
        debugPrint('Error llamando al sintetizador web: $e');
      }
    }
  }

  void _stopReading() {
    if (kIsWeb) {
      try {
        js.context.callMethod('stopSpeaking');
        setState(() => _isSpeaking = false);
      } catch (e) {
        debugPrint('Error deteniendo el sintetizador web: $e');
      }
    }
  }

  // ── Procesamiento de búsqueda / códigos de profesor ────────────────
  void _onTopicSelected(Topic topic) {
    final weekNum = _extractWeekNumber(topic);
    _clearTopicSelection();
    ClassTopicDetailScreen.openFromTopic(context, topic, weekNumber: weekNum);
  }

  void _clearTopicSelection() {
    setState(() {
      _selectedTopic = null;
      _searchQuery = '';
      _searchController.clear();
      _showSearchDropdown = false;
    });
  }

  void _processTeacherCode(String value) {
    final cleanVal = value.trim().toUpperCase();
    final RegExp teacherCodeRegExp =
        RegExp(r'^(PRI|CIB|SIM|VIT|TIT|KIN)[1-2]$');

    if (cleanVal == 'NOO') {
      Navigator.of(context).pop('JUMP:NOO');
      return;
    }

    if (teacherCodeRegExp.hasMatch(cleanVal)) {
      Navigator.of(context).pop('JUMP:$cleanVal');
    }
  }

  IconData _iconForTopicType(TopicType type) {
    switch (type) {
      case TopicType.simulation:
        return Icons.play_circle_outline_rounded;
      case TopicType.exercise:
        return Icons.edit_note_rounded;
      case TopicType.mixed:
        return Icons.auto_awesome_rounded;
      case TopicType.presentation:
        return Icons.slideshow_rounded;
    }
  }

  // ── Build Principal con Maquetación Desglosada y Anti-Overflow ──────
  @override
  Widget build(BuildContext context) {
    final planet = widget.planet;

    return Material(
      color: Colors.transparent,
      child: Stack(
        children: [
          // 1. Fondo Paisajístico Estelar Panorámico
          Positioned.fill(
            child: Image.asset(
              planet.landscapeAssetPath,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                final lower = planet.name.toLowerCase();
                String alt = 'Imágenes utilizadas/Prisma paisaje.png';
                if (lower.contains('cib')) alt = 'Imágenes utilizadas/Ciberon paisaje.png';
                if (lower.contains('kin')) alt = 'Imágenes utilizadas/Kinetos paisaje.png';
                if (lower.contains('sim')) alt = 'Imágenes utilizadas/Simbios paisaje.png';
                if (lower.contains('vit')) alt = 'Imágenes utilizadas/Vitalia paisaje.png';
                if (lower.contains('tit')) alt = 'Imágenes utilizadas/Titan-Q paisaje.png';
                if (lower.contains('noo')) alt = 'Imágenes utilizadas/Noosféris paisaje.jpg';
                return Image.asset(
                  alt,
                  fit: BoxFit.cover,
                  errorBuilder: (c, e, s) => Container(color: const Color(0xFF0F172A)),
                );
              },
            ),
          ),

          // Velo oscuro translúcido para contraste estético
          Positioned.fill(
            child: Container(
              color: Colors.black.withValues(alpha: 0.48),
            ),
          ),

          // Tap en fondo para cerrar
          Positioned.fill(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => Navigator.of(context).pop(),
              child: const SizedBox.expand(),
            ),
          ),

          // 2. CONTENEDOR DE MAQUETACIÓN ESPACIAL RESPONSIVA (ANTI-OVERFLOW)
          SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final isMobile = constraints.maxWidth < 740;

                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  child: Column(
                    children: [
                      // ══════════════════════════════════════════════════════
                      // FILA SUPERIOR: Buscador (Izq) + Botón Audio y Cerrar (Der)
                      // ══════════════════════════════════════════════════════
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // SUPERIOR IZQUIERDA: Barra de Búsqueda Estilo Píldora
                          Expanded(
                            child: Align(
                              alignment: Alignment.topLeft,
                              child: _buildPillSearchBar(planet),
                            ),
                          ),
                          const SizedBox(width: 14),

                          // SUPERIOR DERECHA: Botón Circular Flotante de Audio + Botón Cerrar
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              _buildFloatingAudioButton(planet),
                              const SizedBox(width: 10),
                              _buildFloatingCloseButton(),
                            ],
                          ),
                        ],
                      ),

                      const SizedBox(height: 14),

                      // ══════════════════════════════════════════════════════
                      // CUERPO SCROLLABLE CON BOTONES ALINEADOS A LA DERECHA
                      // ══════════════════════════════════════════════════════
                      Expanded(
                        child: SingleChildScrollView(
                          physics: const BouncingScrollPhysics(),
                          child: ConstrainedBox(
                            constraints: BoxConstraints(
                              minHeight: (constraints.maxHeight - 92).clamp(0, double.infinity),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                const SizedBox(height: 16),

                                // PARTE DERECHA: Opciones del Portal y Acciones del Planeta
                                Align(
                                  alignment: isMobile ? Alignment.center : Alignment.centerRight,
                                  child: _buildRightActionsColumn(planet, isMobile: isMobile),
                                ),

                                const SizedBox(height: 24),

                                // PARTE INFERIOR: Dato Curioso Contextualizado por IA
                                Center(
                                  child: _buildBottomAICuriosityContainer(planet),
                                ),

                                const SizedBox(height: 8),
                              ],
                            ),
                          ),
                        ),
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

  // ── COMPONENTE 1: Barra de Búsqueda Estilo Píldora (Superior Izquierda) ──
  Widget _buildPillSearchBar(PlanetData planet) {
    final results = _searchResults;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          constraints: const BoxConstraints(maxWidth: 360),
          height: 48,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.95),
            borderRadius: BorderRadius.circular(30), // Estilo píldora
            border: Border.all(
              color: _showSearchDropdown ? planet.color : const Color(0xFFE2E8F0),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.18),
                blurRadius: 14,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Icon(
                  Icons.search_rounded,
                  color: planet.color,
                  size: 22,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    style: GoogleFonts.poppins(
                      color: const Color(0xFF0F172A),
                      fontSize: 13.5,
                      fontWeight: FontWeight.w600,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Buscar en ${planet.name}',
                      hintStyle: GoogleFonts.poppins(
                        color: const Color(0xFF94A3B8),
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                      border: InputBorder.none,
                      isDense: true,
                    ),
                    onChanged: (val) {
                      setState(() {
                        _searchQuery = val;
                        _showSearchDropdown = val.trim().isNotEmpty;
                      });
                    },
                    onSubmitted: _processTeacherCode,
                  ),
                ),
                if (_searchController.text.isNotEmpty)
                  GestureDetector(
                    onTap: _clearTopicSelection,
                    child: const Icon(
                      Icons.cancel_rounded,
                      color: Color(0xFF94A3B8),
                      size: 18,
                    ),
                  ),
              ],
            ),
          ),
        ),

        // Menú desplegable de temas coincidentes
        if (_showSearchDropdown)
          Container(
            margin: const EdgeInsets.only(top: 6),
            constraints: const BoxConstraints(maxWidth: 360, maxHeight: 180),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.98),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE2E8F0), width: 1.0),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.20),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: results.isEmpty
                ? Padding(
                    padding: const EdgeInsets.all(14),
                    child: Text(
                      'No hay temas en ${widget.planet.name} coincidentes.',
                      style: GoogleFonts.inter(
                        color: const Color(0xFF64748B),
                        fontSize: 12.5,
                      ),
                    ),
                  )
                : ListView.builder(
                    shrinkWrap: true,
                    itemCount: results.length,
                    itemBuilder: (context, i) {
                      final topic = results[i];
                      return InkWell(
                        onTap: () => _onTopicSelected(topic),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 10),
                          decoration: const BoxDecoration(
                            border: Border(
                              bottom: BorderSide(
                                  color: Color(0xFFF1F5F9), width: 1.0),
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                _iconForTopicType(topic.type),
                                color: planet.color,
                                size: 18,
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  topic.title,
                                  style: GoogleFonts.poppins(
                                    fontSize: 12.5,
                                    fontWeight: FontWeight.w600,
                                    color: const Color(0xFF0F172A),
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
      ],
    );
  }

  // ── COMPONENTE 2: Botón Circular Flotante de Audio (Superior Derecha) ───
  Widget _buildFloatingAudioButton(PlanetData planet) {
    return Tooltip(
      message: _isSpeaking
          ? 'Detener lectura del dato curioso'
          : 'Escuchar el dato curioso por voz (TTS)',
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: _toggleAudioReading,
          borderRadius: BorderRadius.circular(30),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _isSpeaking
                  ? const Color(0xFFDC2626)
                  : Colors.white.withValues(alpha: 0.95),
              border: Border.all(
                color: _isSpeaking ? Colors.white : planet.color.withValues(alpha: 0.5),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: _isSpeaking
                      ? const Color(0xFFDC2626).withValues(alpha: 0.50)
                      : Colors.black.withValues(alpha: 0.20),
                  blurRadius: 14,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Center(
              child: Icon(
                _isSpeaking ? Icons.stop_rounded : Icons.volume_up_rounded,
                color: _isSpeaking ? Colors.white : const Color(0xFF0F172A),
                size: 24,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFloatingCloseButton() {
    return Tooltip(
      message: 'Cerrar ventana',
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => Navigator.of(context).pop(),
          borderRadius: BorderRadius.circular(30),
          child: Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withValues(alpha: 0.95),
              border: Border.all(
                color: const Color(0xFFE2E8F0),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.20),
                  blurRadius: 14,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Center(
              child: Icon(
                Icons.close_rounded,
                color: Color(0xFF64748B),
                size: 22,
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ── COMPONENTE 3: Opciones y Botones de Acción Alineados a la Derecha ───────
  Widget _buildRightActionsColumn(PlanetData planet, {required bool isMobile}) {
    final topic = _selectedTopic;
    final String mainButtonLabel = topic != null
        ? 'Iniciar: ${topic.title}'
        : (planet.id == 7 ? 'Entrar a Noosféris' : 'Ingresar al planeta');

    return Container(
      constraints: const BoxConstraints(maxWidth: 340),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Si el usuario seleccionó un tema del buscador, mostrar chip indicador
          if (topic != null) ...[
            Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: planet.color, width: 1.5),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.14),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Icon(_iconForTopicType(topic.type), color: planet.color, size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      topic.title,
                      style: GoogleFonts.poppins(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF0F172A),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  GestureDetector(
                    onTap: _clearTopicSelection,
                    child: const Icon(Icons.close_rounded, size: 18, color: Color(0xFF64748B)),
                  ),
                ],
              ),
            ),
          ],

          // 1. BOTÓN PRINCIPAL: "Ingresar al planeta" (Alto Contraste y Nitidez)
          SizedBox(
            height: 52,
            child: ElevatedButton.icon(
              onPressed: () {
                if (topic != null) {
                  final weekNum = _extractWeekNumber(topic);
                  ClassTopicDetailScreen.openFromTopic(context, topic, weekNumber: weekNum);
                } else {
                  Navigator.of(context).pop('ENTER_WORLD');
                }
              },
              icon: const Icon(Icons.rocket_launch_rounded, size: 20, color: Colors.white),
              label: Text(
                mainButtonLabel,
                style: GoogleFonts.poppins(
                  fontSize: 15.5,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.2,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: planet.color,
                foregroundColor: Colors.white,
                elevation: 6,
                shadowColor: planet.color.withValues(alpha: 0.60),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: const BorderSide(color: Colors.white38, width: 1.5),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
              ),
            ),
          ),
          const SizedBox(height: 12),

          // 2. BOTÓN SECUNDARIO: "Volver al mapa estelar" (Blanco Sólido con Letra Oscura)
          SizedBox(
            height: 48,
            child: ElevatedButton.icon(
              onPressed: () => Navigator.of(context).pop(),
              icon: const Icon(Icons.public_rounded, size: 19, color: Color(0xFF0F172A)),
              label: Text(
                'Volver al mapa estelar',
                style: GoogleFonts.poppins(
                  fontSize: 14.5,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF0F172A),
                  letterSpacing: 0.2,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: const Color(0xFF0F172A),
                elevation: 4,
                shadowColor: Colors.black.withValues(alpha: 0.22),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: const BorderSide(color: Color(0xFFCBD5E1), width: 1.5),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── COMPONENTE 5: Contenedor para Dato Curioso IA (Parte Inferior Centro) ─
  Widget _buildBottomAICuriosityContainer(PlanetData planet) {
    final headerTitle = AICuriosityService.instance.getAreaHeaderTitle(planet.name);

    return Container(
      constraints: const BoxConstraints(maxWidth: 780),
      margin: const EdgeInsets.only(top: 10),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0xFAFFFFFF), // Fondo blanco semitraslúcido limpio
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFFE2E8F0),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.24),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
          BoxShadow(
            color: planet.color.withValues(alpha: 0.12),
            blurRadius: 16,
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Cabecera con Icono de IA + Área Temática Dinámica + Botón Rotar
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(5),
                decoration: BoxDecoration(
                  color: const Color(0xFFEFF6FF),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: const Color(0xFFBFDBFE),
                    width: 1.0,
                  ),
                ),
                child: const Icon(
                  Icons.auto_awesome_rounded,
                  color: Color(0xFF004F77),
                  size: 16,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  headerTitle,
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF0F172A),
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              // Botón interactivo para refrescar dato con IA
              Tooltip(
                message: 'Consultar nuevo dato con IA para ${planet.name}',
                child: InkWell(
                  onTap: _fetchCuriosityFromAI,
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    padding: const EdgeInsets.all(5),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: const Color(0xFFE2E8F0),
                        width: 1.0,
                      ),
                    ),
                    child: _isLoadingAICuriosity
                        ? const SizedBox(
                            width: 14,
                            height: 14,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.0,
                              color: Color(0xFF004F77),
                            ),
                          )
                        : const Icon(
                            Icons.refresh_rounded,
                            color: Color(0xFF475569),
                            size: 16,
                          ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),

          // Texto del Dato Curioso generado por IA
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 250),
            child: _isLoadingAICuriosity
                ? Padding(
                    key: const ValueKey('loading_fact_indicator'),
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: Row(
                      children: [
                        const SizedBox(
                          width: 14,
                          height: 14,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.0,
                            color: Color(0xFF004F77),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          'Consultando IA de ${_aiContext.areaTematica}...',
                          style: GoogleFonts.inter(
                            fontSize: 12.5,
                            fontStyle: FontStyle.italic,
                            color: const Color(0xFF64748B),
                          ),
                        ),
                      ],
                    ),
                  )
                : Text(
                    _currentCuriosityFact,
                    key: ValueKey(_currentCuriosityFact),
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      height: 1.42,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF1E293B),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
