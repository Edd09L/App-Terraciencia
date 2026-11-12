import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../models/app_colors.dart';
import '../models/teacher_curriculum_model.dart';
import '../providers/user_role_provider.dart';
import 'class_topic_detail_screen.dart';

/// Alias para soportar el nombre MallaCurricularScreen en toda la aplicaciÃ³n
typedef MallaCurricularScreen = TeacherMaterialScreen;

/// Pantalla "Malla Curricular & Recursos Docentes" rediseÃ±ada en fondo Blanco Hueso (#F8F9FA),
/// pestaÃ±as centradas con degradados fluidos, tarjetas de semana en colores pastel y cuadrÃ­cula responsiva limpia.
///
/// Principios de diseÃ±o aplicados:
/// 1. FONDO GLOBAL BLANCO HUESO:
///    - Fondo de toda la pantalla en tono limpio Blanco Hueso (#F8F9FA).
///    - EliminaciÃ³n del banner grande superior de competencia para una vista directa y despejada.
/// 2. BARRAS / PESTAÃ‘AS CENTRADAS (TAB BAR):
///    - PestaÃ±as centradas horizontalmente (MainAxisAlignment.center) con degradados fluidos para 2 planetas
///      y color sÃ³lido para 1 planeta.
/// 3. TARJETAS DE SEMANA EN COLORES PASTEL:
///    - EliminaciÃ³n total del texto e Ã­cono de horas pedagÃ³gicas.
///    - Fondo pÃ¡lido suave relativo al planeta activo (ej. #F4FBF7 para Simbios) con borde izquierdo de 4px.
///    - Cuadro interno de contenidos en blanco puro (#FFFFFF) con borde sutil para mÃ¡xima nitidez.
/// 4. ALINEACIÃ“N Y CUADRÃCULA RESPONSIVA:
///    - Grid de 2 columnas en pantallas amplias y 1 columna en mÃ³viles, perfectamente balanceado.
class TeacherMaterialScreen extends StatefulWidget {
  final String initialGrade;

  const TeacherMaterialScreen({
    super.key,
    this.initialGrade = '2do Básico',
  });

  @override
  State<TeacherMaterialScreen> createState() => _TeacherMaterialScreenState();
}

class _TeacherMaterialScreenState extends State<TeacherMaterialScreen> {
  static const List<String> gradeOptions = [
    '1ro Básico',
    '2do Básico',
    '3ro Básico',
    '4to Bachillerato',
    '5to Bachillerato',
  ];

  late String selectedGrade;
  late List<CurriculumCompetence> _allCompetencias;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  // ID de la competencia activa seleccionada en las pestañas (1, 2, 3 o 4)
  int _selectedCompetenceId = 1;

  @override
  void initState() {
    super.initState();
    selectedGrade = widget.initialGrade;
    if (!gradeOptions.contains(selectedGrade)) {
      selectedGrade = gradeOptions.first;
    }
    _allCompetencias =
        TeacherCurriculumDatabase.getCompetenciasForGrade(selectedGrade);
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.trim().toLowerCase();
      });
    });
  }

  // Imagen dinámica oficial por grado académico seleccionado
  String _getGradeBannerImage(String grade) {
    final clean = grade.trim();
    if (clean.contains('1ro')) {
      return 'Imágenes utilizadas/1ro.png';
    } else if (clean.contains('2do')) {
      return 'Imágenes utilizadas/2do.png';
    } else if (clean.contains('3ro')) {
      return 'Imágenes utilizadas/3ro.png';
    } else if (clean.contains('4to')) {
      return 'Imágenes utilizadas/4to.png';
    } else if (clean.contains('5to')) {
      return 'Imágenes utilizadas/5to.png';
    }
    return 'Imágenes utilizadas/2do.png';
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // Paleta cromÃ¡tica oficial por competencia
  Color _getCompetencePrimaryColor(int id) {
    switch (id) {
      case 1:
        return AppColors.prisma; // #4B0082 Ãndigo Profundo (Prisma)
      case 2:
        return AppColors.simbios; // #1B5E20 Verde Esmeralda (Simbios exclusivo)
      case 3:
        return AppColors.vitalia; // #A1005B Magenta VÃ©rtice (Vitalia)
      case 4:
        return AppColors.titanQ; // #004F77 Azul OcÃ©ano (Titan-Q) / Kinetos (#9E2A2B)
      default:
        return AppColors.ciberon; // #8B6508 Dorado / Ãmbar
    }
  }

  // Degradado bi-color para competencias que abarcan 2 planetas
  Gradient? _getCompetenceGradient(int id) {
    switch (id) {
      case 1:
        return null; // Prisma sÃ³lido (#4B0082)
      case 2:
        return null; // Simbios sÃ³lido exclusivo (#1B5E20)
      case 3:
        return null; // Vitalia sÃ³lido (#A1005B)
      case 4:
        return const LinearGradient(
          colors: [AppColors.titanQ, AppColors.kinetos], // Titan-Q + Kinetos
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        );
      default:
        return null;
    }
  }

  String _getCompetenceWeekRange(int id) {
    switch (id) {
      case 1:
        return 'Sem. 1 - 4';
      case 2:
        return 'Sem. 5 - 14';
      case 3:
        return 'Sem. 15 - 23';
      case 4:
        return 'Sem. 24 - 31';
      default:
        return '';
    }
  }

  String _getCompetenceShortName(int id) {
    switch (id) {
      case 1:
        return 'Indagación Científica';
      case 2:
        return 'Ed. Ambiental y Ecología';
      case 3:
        return 'Biología y Vida';
      case 4:
        return 'Química y Física';
      default:
        return 'Competencia $id';
    }
  }

  Color _getPlanetColor(CurriculumWeek week) {
    return week.planetColor ??
        AppColors.forPlanet(week.planetName ?? '');
  }

  Color _getPlanetPaleBackground(CurriculumWeek week) {
    final planetColor = _getPlanetColor(week);
    return Color.alphaBlend(planetColor.withValues(alpha: 0.06), Colors.white);
  }

  @override
  Widget build(BuildContext context) {
    // Manejo seguro de estado (fallback) antes del renderizado
    if (!gradeOptions.contains(selectedGrade)) {
      selectedGrade = gradeOptions.first;
    }

    final roleProvider = context.watch<UserRoleProvider>();
    final double textScale = roleProvider.textScaleFactor;

    // Obtener la competencia seleccionada
    final selectedComp = _allCompetencias.firstWhere(
      (c) => c.id == _selectedCompetenceId,
      orElse: () => _allCompetencias.first,
    );

    // Filtrar semanas segÃºn bÃºsqueda si hay consulta activa
    final filteredWeeks = _getFilteredWeeksForCompetence(selectedComp);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA), // Fondo Blanco Hueso elegante #F8F9FA
      body: SafeArea(
        child: Column(
          children: [
            // 1. Encabezado Tipográfico Principal con Buscador Integrado
            _buildTopHeader(context, textScale),

            // Banner dinámico de imagen por grado académico (compacto y proporcional)
            _buildGradeBanner(),

            // 2. BARRA DE PESTAÑAS HORIZONTAL CENTRADA (TAB BAR)
            _buildHorizontalTabBar(textScale),

            const SizedBox(height: 12),

            // 4. LISTADO DIRECTO DE SEMANAS (CUADRÃCULA RESPONSIVA LIMPIA)
            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 280),
                switchInCurve: Curves.easeOutCubic,
                switchOutCurve: Curves.easeInCubic,
                child: KeyedSubtree(
                  key: ValueKey<String>('comp_${selectedComp.id}_search_$_searchQuery'),
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(20, 4, 20, 40),
                    physics: const BouncingScrollPhysics(),
                    children: [
                      if (filteredWeeks.isEmpty)
                        _buildEmptySearchInTab(textScale, selectedComp)
                      else
                        _buildWeeksGridOrList(
                          context: context,
                          weeks: filteredWeeks,
                          competenceColor: _getCompetencePrimaryColor(selectedComp.id),
                          textScale: textScale,
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getGradeBannerColor(String grade) {
    final clean = grade.trim();
    if (clean.contains('1ro')) {
      return const Color(0xFF5C00AD);
    } else if (clean.contains('2do')) {
      return const Color(0xFF004AAD);
    } else if (clean.contains('3ro')) {
      return const Color(0xFFAD000A);
    } else if (clean.contains('4to')) {
      return const Color(0xFF00AD07);
    } else if (clean.contains('5to')) {
      return const Color(0xFFAD4300);
    }
    return const Color(0xFF004AAD);
  }

  // ─── Banner Dinámico de Imagen por Grado (Compacto y Proporcional) ─────────
  Widget _buildGradeBanner() {
    final assetPath = _getGradeBannerImage(selectedGrade);
    final fallbackAssetPath = 'assets/images/${assetPath.split('/').last}';
    final bannerBgColor = _getGradeBannerColor(selectedGrade);

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 2, 20, 8),
      child: Container(
        width: double.infinity,
        constraints: const BoxConstraints(
          maxHeight: 140, // Altura máxima compacta para priorizar el contenido
        ),
        decoration: BoxDecoration(
          color: bannerBgColor,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: bannerBgColor.withValues(alpha: 0.22),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Image.asset(
            assetPath,
            key: ValueKey<String>('banner_$selectedGrade'),
            fit: BoxFit.contain, // Imagen completa al 100% sin recortar texto ni isotipos
            width: double.infinity,
            alignment: Alignment.center,
            errorBuilder: (context, error, stackTrace) {
              return Image.asset(
                fallbackAssetPath,
                key: ValueKey<String>('banner_fallback_$selectedGrade'),
                fit: BoxFit.contain,
                width: double.infinity,
                alignment: Alignment.center,
                errorBuilder: (context, error2, stackTrace2) {
                  return Container(
                    height: 120,
                    color: bannerBgColor,
                    alignment: Alignment.center,
                    child: Text(
                      selectedGrade,
                      style: GoogleFonts.plusJakartaSans(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }

  // ─── 1. Encabezado Tipográfico Principal con Buscador Integrado ────────────
  Widget _buildTopHeader(
    BuildContext context,
    double textScale,
  ) {
    // Validación de seguridad de estado previo al renderizado del Dropdown
    if (!gradeOptions.contains(selectedGrade)) {
      selectedGrade = gradeOptions.first;
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // 1. [Botón Volver + Título]
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Botón Regresar independiente estilizado
              Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () => Navigator.of(context).pop(),
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFE2E8F0), width: 1.0),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x06000000),
                          blurRadius: 6,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.arrow_back_ios_new_rounded,
                      color: Color(0xFF0F172A),
                      size: 18,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),

              // Título Tipográfico Delgado y Compacto
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Malla Curricular',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 20 * textScale,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF0F172A),
                      letterSpacing: -0.5,
                      height: 1.1,
                    ),
                  ),
                  const SizedBox(height: 1),
                  Text(
                    'Recursos Docentes • $selectedGrade',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 11.5 * textScale,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF64748B),
                      letterSpacing: -0.2,
                    ),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(width: 12),

          // 2. [Buscador Compacto] (SizedBox width: 280, height: 40, circular(20))
          Flexible(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 280),
              child: SizedBox(
                width: 280,
                height: 40,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: _searchQuery.isNotEmpty
                          ? _getCompetencePrimaryColor(_selectedCompetenceId)
                          : const Color(0xFFE2E8F0),
                      width: 1.0,
                    ),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x06000000),
                        blurRadius: 6,
                        offset: Offset(0, 1),
                      ),
                    ],
                  ),
                  child: TextField(
                    controller: _searchController,
                    style: GoogleFonts.plusJakartaSans(
                      color: const Color(0xFF0F172A),
                      fontSize: 13 * textScale,
                      fontWeight: FontWeight.w500,
                    ),
                    decoration: InputDecoration(
                      isDense: true,
                      hintText: 'Buscar tema...',
                      hintStyle: GoogleFonts.plusJakartaSans(
                        color: const Color(0xFF94A3B8),
                        fontSize: 12.5 * textScale,
                      ),
                      prefixIcon: const Icon(
                        Icons.search_rounded,
                        color: Color(0xFF64748B),
                        size: 18,
                      ),
                      prefixIconConstraints: const BoxConstraints(
                        minWidth: 34,
                        minHeight: 40,
                      ),
                      suffixIcon: _searchQuery.isNotEmpty
                          ? IconButton(
                              padding: EdgeInsets.zero,
                              icon: const Icon(
                                Icons.cancel_rounded,
                                color: Color(0xFF64748B),
                                size: 16,
                              ),
                              onPressed: () => _searchController.clear(),
                            )
                          : null,
                      suffixIconConstraints: const BoxConstraints(
                        minWidth: 32,
                        minHeight: 40,
                      ),
                      border: InputBorder.none,
                      contentPadding:
                          const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                    ),
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(width: 12),

          // 3. [Selector de Grado Académico]
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 1),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: _getCompetencePrimaryColor(_selectedCompetenceId).withValues(alpha: 0.6),
                width: 1.5,
              ),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x06000000),
                  blurRadius: 6,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: selectedGrade,
                dropdownColor: Colors.white,
                icon: Icon(
                  Icons.arrow_drop_down_rounded,
                  color: _getCompetencePrimaryColor(_selectedCompetenceId),
                ),
                style: GoogleFonts.plusJakartaSans(
                  color: const Color(0xFF0F172A),
                  fontSize: 13 * textScale,
                  fontWeight: FontWeight.w800,
                ),
                onChanged: (newGrade) {
                  if (newGrade != null && newGrade != selectedGrade) {
                    setState(() {
                      selectedGrade = newGrade;
                      _allCompetencias =
                          TeacherCurriculumDatabase.getCompetenciasForGrade(newGrade);
                      _selectedCompetenceId = 1;
                    });
                  }
                },
                items: gradeOptions.map((grade) {
                  return DropdownMenuItem<String>(
                    value: grade,
                    child: Text(grade),
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // â”€â”€â”€ 3. BARRA DE PESTAÃ‘AS HORIZONTAL CENTRADA (TAB BAR) â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
  Widget _buildHorizontalTabBar(double textScale) {
    return Container(
      height: 64,
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              for (int index = 0; index < _allCompetencias.length; index++) ...[
                if (index > 0) const SizedBox(width: 12),
                _buildTabItem(_allCompetencias[index], textScale),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTabItem(CurriculumCompetence comp, double textScale) {
    final isSelected = comp.id == _selectedCompetenceId;
    final primaryColor = _getCompetencePrimaryColor(comp.id);
    final gradient = _getCompetenceGradient(comp.id);
    final weekRange = _getCompetenceWeekRange(comp.id);
    final shortName = _getCompetenceShortName(comp.id);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          setState(() {
            _selectedCompetenceId = comp.id;
          });
        },
        borderRadius: BorderRadius.circular(14),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeInOutCubic,
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 9),
          decoration: BoxDecoration(
            gradient: isSelected ? gradient : null,
            color: isSelected
                ? (gradient == null ? primaryColor : null)
                : Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isSelected ? primaryColor.withValues(alpha: 0.8) : const Color(0xFFE2E8F0),
              width: isSelected ? 1.5 : 1.0,
            ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: primaryColor.withValues(alpha: 0.32),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ]
                : const [
                    BoxShadow(
                      color: Color(0x04000000),
                      blurRadius: 4,
                      offset: Offset(0, 1),
                    ),
                  ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Ãcono de la competencia
              Container(
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(
                  color: isSelected
                      ? Colors.white.withValues(alpha: 0.22)
                      : const Color(0xFFF1F5F9),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isSelected
                        ? Colors.white.withValues(alpha: 0.4)
                        : const Color(0xFFE2E8F0),
                    width: 1.0,
                  ),
                ),
                child: Icon(
                  comp.icon,
                  color: isSelected ? Colors.white : const Color(0xFF64748B),
                  size: 18,
                ),
              ),
              const SizedBox(width: 10),

              // Etiqueta y TÃ­tulo de la Competencia
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        'Competencia ${comp.id}',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 13.5 * textScale,
                          fontWeight: FontWeight.w800,
                          color: isSelected
                              ? Colors.white
                              : const Color(0xFF1E293B),
                          letterSpacing: 0.1,
                        ),
                      ),
                      const SizedBox(width: 6),
                      // Badge con rango de semanas
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 7, vertical: 2),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? Colors.white.withValues(alpha: 0.20)
                              : const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          weekRange,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 11 * textScale,
                            fontWeight: FontWeight.w700,
                            color: isSelected
                                ? Colors.white
                                : const Color(0xFF475569),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    shortName,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12 * textScale,
                      fontWeight: FontWeight.w500,
                      color: isSelected
                          ? Colors.white.withValues(alpha: 0.92)
                          : const Color(0xFF64748B),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // â”€â”€â”€ 4. Grid o Lista de Semanas de la PestaÃ±a Activa (2 Columnas) â”€â”€â”€â”€â”€â”€â”€â”€
  Widget _buildWeeksGridOrList({
    required BuildContext context,
    required List<CurriculumWeek> weeks,
    required Color competenceColor,
    required double textScale,
  }) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth >= 768;

        if (isWide) {
          final double cardWidth = (constraints.maxWidth - 18) / 2;
          return Wrap(
            spacing: 18,
            runSpacing: 18,
            children: weeks.map((week) {
              return SizedBox(
                width: cardWidth,
                child: _buildWeekCard(
                  context: context,
                  week: week,
                  competencePrimaryColor: competenceColor,
                  textScale: textScale,
                ),
              );
            }).toList(),
          );
        } else {
          return Column(
            children: weeks.map((week) {
              return _buildWeekCard(
                context: context,
                week: week,
                competencePrimaryColor: competenceColor,
                textScale: textScale,
              );
            }).toList(),
          );
        }
      },
    );
  }

  // â”€â”€â”€ 5. Tarjeta Individual de Semana (Fondo Pastel y Cuadro Interno Blanco)
  Widget _buildWeekCard({
    required BuildContext context,
    required CurriculumWeek week,
    required Color competencePrimaryColor,
    required double textScale,
  }) {
    final planetColor = _getPlanetColor(week);
    final paleBackground = _getPlanetPaleBackground(week);

    return Container(
      margin: const EdgeInsets.only(bottom: 18),
      decoration: BoxDecoration(
        color: paleBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFE2E8F0),
          width: 1.0,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x06000000),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            ClassTopicDetailScreen.openFromWeek(
              context,
              week: week,
              competenceColor: competencePrimaryColor,
            );
          },
          borderRadius: BorderRadius.circular(15),
          hoverColor: planetColor.withValues(alpha: 0.04),
          splashColor: planetColor.withValues(alpha: 0.08),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(15),
            child: IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Borde Lateral Izquierdo SÃ³lido con strokeWidth 4px
                  Container(
                    width: 4.0,
                    color: planetColor,
                  ),

                  // Contenido con Padding Holgado de 20px
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Cabecera: Chip de Semana + Badge de Planeta
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 5),
                                decoration: BoxDecoration(
                                  color: competencePrimaryColor,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              child: Text(
                                'Semana ${week.weekNumber}',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 13 * textScale,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white,
                                  letterSpacing: 0.2,
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),

                            if (week.planetName != null) ...[
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: planetColor.withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: planetColor.withValues(alpha: 0.35),
                                    width: 1.0,
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Container(
                                      width: 8,
                                      height: 8,
                                      decoration: BoxDecoration(
                                        color: planetColor,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      week.planetName!,
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 13 * textScale,
                                        fontWeight: FontWeight.w700,
                                        color: planetColor,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ],
                        ),

                        const SizedBox(height: 16),

                        // TÃ­tulo de la Semana (18.5pt bold, #0F172A)
                        Text(
                          week.title,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 18 * textScale,
                            fontWeight: FontWeight.w800,
                            color: const Color(0xFF0F172A),
                            letterSpacing: -0.2,
                            height: 1.3,
                          ),
                        ),

                        const SizedBox(height: 8),

                        // DescripciÃ³n de introducciÃ³n (14pt, #334155, height 1.45)
                        Text(
                          week.description,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 14 * textScale,
                            color: const Color(0xFF334155),
                            height: 1.45,
                            fontWeight: FontWeight.w500,
                          ),
                        ),

                        const SizedBox(height: 18),

                        // Cuadro Interno de Contenidos Curriculares (Fondo Blanco Puro #FFFFFF)
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(18),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: const Color(0xFFE2E8F0),
                              width: 1.0,
                            ),
                            boxShadow: const [
                              BoxShadow(
                                color: Color(0x04000000),
                                blurRadius: 4,
                                offset: Offset(0, 1),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons.bookmark_border_rounded,
                                    size: 17,
                                    color: planetColor,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Contenidos Curriculares Oficiales:',
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 13.5 * textScale,
                                      fontWeight: FontWeight.w800,
                                      color: const Color(0xFF1E293B),
                                      letterSpacing: -0.1,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              ...week.contents.map((content) {
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 9),
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        margin: const EdgeInsets.only(top: 6),
                                        width: 7,
                                        height: 7,
                                        decoration: BoxDecoration(
                                          color: planetColor,
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Text(
                                          content,
                                          style: GoogleFonts.plusJakartaSans(
                                            fontSize: 13.5 * textScale,
                                            fontWeight: FontWeight.w500,
                                            color: const Color(0xFF1E293B),
                                            height: 1.45,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}

  // ─── 6. Estado Vacío de Búsqueda Dentro de la Pestaña ───────────────────
  Widget _buildEmptySearchInTab(double textScale, CurriculumCompetence comp) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                border: Border.all(
                  color: const Color(0xFFE2E8F0),
                  width: 1.0,
                ),
              ),
              child: const Icon(
                Icons.search_off_rounded,
                color: Color(0xFF64748B),
                size: 42,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Sin coincidencias en Competencia ${comp.id}',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 18 * textScale,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF0F172A),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Prueba buscando con otro término o limpiando el filtro.',
              textAlign: TextAlign.center,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 14 * textScale,
                color: const Color(0xFF334155),
              ),
            ),
            const SizedBox(height: 14),
            TextButton.icon(
              onPressed: () => _searchController.clear(),
              icon: const Icon(Icons.refresh_rounded, color: Color(0xFF004F77)),
              label: Text(
                'Limpiar filtro',
                style: GoogleFonts.plusJakartaSans(
                  fontWeight: FontWeight.bold,
                  fontSize: 13.5 * textScale,
                  color: const Color(0xFF004F77),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // â”€â”€â”€ LÃ³gica de Filtrado por Competencia â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
  List<CurriculumWeek> _getFilteredWeeksForCompetence(CurriculumCompetence comp) {
    if (_searchQuery.isEmpty) {
      return comp.weeks;
    }

    return comp.weeks.where((w) {
      final matchesWeekNum =
          'semana ${w.weekNumber}'.contains(_searchQuery) ||
              'w${w.weekNumber}'.contains(_searchQuery);
      final matchesTitle = w.title.toLowerCase().contains(_searchQuery);
      final matchesDesc = w.description.toLowerCase().contains(_searchQuery);
      final matchesContents = w.contents
          .any((c) => c.toLowerCase().contains(_searchQuery));
      final matchesPlanet =
          w.planetName?.toLowerCase().contains(_searchQuery) ?? false;

      return matchesWeekNum ||
          matchesTitle ||
          matchesDesc ||
          matchesContents ||
          matchesPlanet;
    }).toList();
  }
}
