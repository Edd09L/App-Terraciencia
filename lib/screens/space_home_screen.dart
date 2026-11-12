import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/app_colors.dart';
import '../models/planet_data.dart';
import '../painters/space_painter.dart';
import '../painters/zigzag_orbits_painter.dart';
import '../widgets/planet_sphere.dart';
import '../widgets/planet_info_modal.dart';
import 'planetas/prisma.dart';
import 'planetas/ciberon.dart';
import 'planetas/simbios.dart';
import 'planetas/vitalia.dart';
import 'planetas/titan_q.dart';
import 'planetas/kinetos.dart';
import 'planetas/noosferis.dart';
import 'galeria_insignias_screen.dart';

/// Pantalla principal del viaje por "La Vía Láctea del Saber".
///
/// Implementa:
/// - Captura inicial de nombre del estudiante como pantalla de bienvenida.
/// - Scroll horizontal adaptativo con botones de navegación asistida (flechas).
/// - Fondo espacial Parallax animado (reacciona al mouse y al scroll).
/// - Layout zigzag horizontal: Noosféris en el centro del canvas (30% mayor),
///   y los 6 planetas orbitales distribuidos alternando arriba/abajo con
///   separación X e Y perfectamente simétrica.
/// - 3 elipses horizontales concentric sutiles como guías estéticas de fondo.
/// - Modal informativo por planeta que se abre al hacer CLIC.
class SpaceHomeScreen extends StatefulWidget {
  const SpaceHomeScreen({super.key});

  @override
  State<SpaceHomeScreen> createState() => _SpaceHomeScreenState();
}

class _SpaceHomeScreenState extends State<SpaceHomeScreen>
    with TickerProviderStateMixin {
  // ── Controladores de Animación ─────────────────────────────────────
  late AnimationController _breathController;
  late AnimationController _flowController;  // Flujo de órbitas animadas

  // ── Gestión de Scroll y Parallax ─────────────────────────────────────
  late ScrollController _scrollController;
  double _scrollOffset = 0.0;
  Offset _mousePosition = Offset.zero;

  // ── Estado del Juego y Progresión ──────────────────────────────────
  late List<PlanetData> _planets;
  int? _hoveredIndex;  // Solo controla efectos visuales de hover
  int _completedCount = 1;

  // ── Nombre de usuario por defecto para acceso directo al Mapa Galáctico ──
  String userName = 'Astronauta';

  @override
  void initState() {
    super.initState();

    _breathController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    )..repeat(reverse: true);

    _flowController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    )..repeat();

    _scrollController = ScrollController()..addListener(_onScroll);

    _planets = spacePlanets.map((p) => p.copyWith(isUnlocked: true)).toList();
  }

  void _onScroll() {
    setState(() {
      _scrollOffset = _scrollController.offset;
    });
  }

  @override
  void dispose() {
    _breathController.dispose();
    _flowController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _navigateScroll(bool goRight) {
    final double targetOffset = goRight
        ? min(_scrollController.offset + 420.0,
            _scrollController.position.maxScrollExtent)
        : max(_scrollController.offset - 420.0, 0.0);
    _scrollController.animateTo(
      targetOffset,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOutCubic,
    );
  }

  void _onPlanetTapped(int index) {
    final planet = _planets[index];
    showDialog(
      context: context,
      barrierColor: Colors.transparent,
      builder: (context) => PlanetInfoModal(planet: planet),
    ).then((result) {
      if (result == 'ENTER_WORLD') {
        _navigateToPlanet(index);
      } else if (result != null && result.toString().startsWith('JUMP:')) {
        _handleJumpCode(result.toString());
      }
    });
  }

  void _handleJumpCode(String jumpString) {
    final code = jumpString.substring(5);
    final prefix = code.substring(0, 3);

    int targetIndex = 0;
    if (prefix == 'PRI') {
      targetIndex = 0;
    } else if (prefix == 'CIB') {
      targetIndex = 1;
    } else if (prefix == 'KIN') {
      targetIndex = 2;
    } else if (prefix == 'TIT') {
      targetIndex = 3;
    } else if (prefix == 'VIT') {
      targetIndex = 4;
    } else if (prefix == 'SIM') {
      targetIndex = 5;
    } else if (prefix == 'NOO') {
      targetIndex = 6;
    }

    setState(() {
      _planets[targetIndex] = _planets[targetIndex].copyWith(isUnlocked: true);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '¡Código "$code" aceptado! Abriendo el planeta ${_planets[targetIndex].name}.',
          style: GoogleFonts.fredoka(fontWeight: FontWeight.bold, color: Colors.black),
        ),
        backgroundColor: Colors.greenAccent,
      ),
    );

    // Animar el scroll hasta el planeta objetivo en el layout zigzag
    // (X del planeta en canvas − mitad de pantalla para centrarlo)
    const double canvasW = 3600.0;
    const double noosX  = canvasW / 2.0; // 1800.0
    const double xStep  = 460.0;
    final List<double> planetXPositions = [
      noosX - xStep * 3, // 0 Prisma    — 420
      noosX - xStep * 2, // 1 Cíberon   — 880
      noosX - xStep * 1, // 2 Kinetos   — 1340  (órbita interna izquierda)
      noosX + xStep * 3, // 3 Titan-Q   — 3180  (extremo derecho externo)
      noosX + xStep * 1, // 4 Vitalia   — 2260  (órbita interna derecha)
      noosX + xStep * 2, // 5 Simbios   — 2720
      noosX,             // 6 Noosféris — 1800  (centro)
    ];
    if (targetIndex < planetXPositions.length) {
      final double screenW = MediaQuery.of(context).size.width;
      final double targetScroll =
          (planetXPositions[targetIndex] - screenW / 2).clamp(0.0, canvasW);
      _scrollController.animateTo(
        targetScroll,
        duration: const Duration(milliseconds: 700),
        curve: Curves.easeOutBack,
      );
    }

    _navigateToPlanet(targetIndex);
  }

  void _navigateToPlanet(int index) {
    final planet = _planets[index];
    Widget targetScreen;

    switch (planet.id) {
      case 1:
        targetScreen = PrismaScreen(studentName: userName);
        break;
      case 2:
        targetScreen = CiberonScreen(studentName: userName);
        break;
      case 3:
        targetScreen = SimbiosScreen(studentName: userName);
        break;
      case 4:
        targetScreen = VitaliaScreen(studentName: userName);
        break;
      case 5:
        targetScreen = TitanQScreen(studentName: userName);
        break;
      case 6:
        targetScreen = KinetosScreen(studentName: userName);
        break;
      case 7:
        targetScreen = NoosferisScreen(studentName: userName, planets: _planets);
        break;
      default:
        return;
    }

    Navigator.of(context)
        .push(MaterialPageRoute(builder: (context) => targetScreen))
        .then((isCompleted) {
      if (isCompleted == true) {
        setState(() {
          _planets[index] = _planets[index].copyWith(progress: 1.0);
          if (index + 1 < _planets.length) {
            _planets[index + 1] = _planets[index + 1].copyWith(isUnlocked: true);
          }
          _completedCount = _planets.where((p) => p.progress >= 1.0).length + 1;
          if (_completedCount > _planets.length) {
            _completedCount = _planets.length;
          }
        });
      }
    });
  }

  void _showLockedWarning(PlanetData planet) {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '¡Alto ahí, astronauta! Completa el planeta anterior para desbloquear ${planet.name}.',
          style: GoogleFonts.fredoka(
            color: Colors.white,
            fontWeight: FontWeight.w900,
            fontSize: 14,
          ),
        ),
        backgroundColor: const Color(0xFF8B6508),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(20),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  // ── Build Principal ───────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    // Flujo directo al Mapa Galáctico / Selección de Planetas
    return _buildZigzagMap(context);
  }

  Widget _buildZigzagMap(BuildContext context) {
    final double screenWidth  = MediaQuery.of(context).size.width;
    final double screenHeight = MediaQuery.of(context).size.height;
    final double canvasHeight = max(screenHeight, 620.0);

    // ─── Dimensiones del lienzo deslizable ───────────────────────────────────
    const double canvasWidth = 3600.0;

    // ─── Eje central Y ───────────────────────────────────────────────────────
    final double cy = canvasHeight * 0.5;

    // ─── Noosféris: centro exacto del canvas ─────────────────────────────────
    const double noosX = canvasWidth / 2.0; // 1800.0
    final double noosY = cy;
    final Offset noosCenter = Offset(noosX, noosY);

    // ─── Parámetros de zigzag ────────────────────────────────────────────────
    //
    // xStep = 460 px: separación horizontal uniforme ampliada entre planetas.
    // yUp   = -155 px: desplazamiento vertical ↑ (planetas arriba).
    // yDown = +120 px: desplazamiento vertical ↓ (planetas abajo).
    //
    // Cálculo de margen seguro con canvasHeight mín = 620 px, cy = 310:
    //   Anatomía de PlanetSphere: esfera 210px + gap 14px + etiqueta ~28px = 252px total.
    //   El Positioned tiene top = planetY − orbitalOffset (105).
    //   → Borde inferior real = planetY − 105 + 252 = planetY + 147.
    //
    //   Con yDown = 120: borde inferior = (310+120)+147 = 577 px  → margen 43 px ✓
    //   Con yDown = 155: borde inferior = (310+155)+147 = 612 px  → margen 8 px ✗ (inseguro)
    //
    // Simetría espejo perfecta (hemisferio izq ↔ der):
    //   Prisma  (X=420,  Y=cy)      ←→  Titan-Q (X=3180, Y=cy)      [ambos al centro Y]
    //   Cíberon (X=880,  Y=cy−155) ←→  Vitalia (X=2260, Y=cy−155)  [ambos arriba]
    //   Kinetos (X=1340, Y=cy+120) ←→  Simbios (X=2720, Y=cy+120)  [ambos abajo, simétricos]
    //
    // Mapa de posiciones (izquierda → derecha):
    //
    //  Índice  Planeta     X       Y              Lado
    //  ──────────────────────────────────────────────────────────────────
    //    0     Prisma      420     cy           ← extremo izquierdo, centro Y
    //    1     Cíberon     880     cy - 155     ↑ izquierda, arriba
    //    2     Kinetos    1340     cy + 120     ↓ órbita interna IZQUIERDA (margen seguro)
    //    3     Titan-Q    3180     cy           → extremo DERECHO externo, centro Y (espejo de Prisma)
    //    4     Vitalia    2260     cy - 155     ↑ órbita interna DERECHA, ARRIBA (invertido ↓→↑)
    //    5     Simbios    2720     cy + 120     ↓ derecha, ABAJO (invertido ↑→↓)
    //    6     Noosféris  1800     cy           ★ centro radiante
    //
    // REGLAS CLAVE:
    //   • Ningún planeta comparte X=1800 con Noosféris → eje vertical central limpio.
    //   • Cíberon y Vitalia: misma Y (cy−155), equidistantes ±920/460 px del centro.
    //   • Kinetos y Simbios: misma Y (cy+120), equidistantes ±460/920 px del centro.
    //   • Prisma y Titan-Q:  misma Y (cy),     equidistantes ±1380 px del centro.
    const double xStep = 460.0;   // Separación horizontal uniforme ampliada
    const double yUp   = -155.0;  // Desplazamiento vertical ↑
    const double yDown =  120.0;  // Desplazamiento vertical ↓ (ajustado para margen seguro)

    // Posiciones absolutas en el canvas para los 6 planetas orbitales
    final List<Offset> planetPositions = [
      Offset(noosX - xStep * 3, cy),          // 0 Prisma   — extremo izquierdo, centro Y
      Offset(noosX - xStep * 2, cy + yUp),    // 1 Cíberon  — izquierda, arriba
      Offset(noosX - xStep * 1, cy + yDown),  // 2 Kinetos  — órbita interna izquierda, abajo
      Offset(noosX + xStep * 3, cy),          // 3 Titan-Q  — extremo derecho externo, centro Y
      Offset(noosX + xStep * 1, cy + yUp),    // 4 Vitalia  — órbita interna derecha, ARRIBA (invertido)
      Offset(noosX + xStep * 2, cy + yDown),  // 5 Simbios  — derecha, ABAJO (invertido)
    ];

    // Tamaños de hit-area (radio del cuadrado del Positioned)
    const double orbitalOffset   = 105.0; // radio hit-area planetas orbitales
    const double noosferisOffset = 136.5; // 105 × 1.30 (30% más grande)

    return Scaffold(
      backgroundColor: const Color(0xFF000000),
      body: SafeArea(
        child: MouseRegion(
          onHover: (event) {
            setState(() {
              _mousePosition = event.localPosition;
            });
          },
          child: Stack(
            children: [
              // 1. FONDO DE ESTRELLAS CON PARALLAX (700 estrellas)
              Positioned.fill(
                child: AnimatedBuilder(
                  animation: _breathController,
                  builder: (context, _) {
                    final Offset parallaxOffset = Offset(
                      -_scrollOffset * 0.45 -
                          (_mousePosition.dx - screenWidth / 2) * 0.12,
                      -(_mousePosition.dy - screenHeight / 2) * 0.12,
                    );
                    return CustomPaint(
                      painter: SpacePainter(
                        breathValue: _breathController.value,
                        mouseOffset: parallaxOffset,
                        dimFactor: _hoveredIndex != null ? 0.45 : 1.0,
                      ),
                    );
                  },
                ),
              ),

              // 2. LIENZO DESLIZABLE — Zigzag Horizontal
              SingleChildScrollView(
                controller: _scrollController,
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                child: SizedBox(
                  width: canvasWidth,
                  height: canvasHeight,
                  child: Stack(
                    children: [
                      // A. Elipses horizontales concentric sutiles (3 órbitas de fondo)
                      Positioned.fill(
                        child: AnimatedBuilder(
                          animation: _breathController,
                          builder: (context, _) {
                            return CustomPaint(
                              painter: ZigzagOrbitsPainter(
                                center: noosCenter,
                                breathValue: _breathController.value,
                                dimFactor: _hoveredIndex != null ? 0.35 : 1.0,
                              ),
                            );
                          },
                        ),
                      ),

                      // B. Planetas orbitales (indices 0-5)
                      for (int i = 0; i < _planets.length - 1; i++)
                        Positioned(
                          left: planetPositions[i].dx - orbitalOffset,
                          top:  planetPositions[i].dy - orbitalOffset,
                          child: PlanetSphere(
                            planet: _planets[i],
                            isDimmed: _hoveredIndex != null &&
                                _hoveredIndex != i,
                            onHoverChanged: (isHovered) {
                              setState(() {
                                _hoveredIndex = isHovered ? i : null;
                              });
                            },
                            onTap: () {
                              if (_planets[i].isUnlocked) {
                                _onPlanetTapped(i);
                              } else {
                                _showLockedWarning(_planets[i]);
                              }
                            },
                          ),
                        ),

                      // C. Noosféris — NÚcleo Radiante (30% más grande, al centro del canvas)
                      Positioned(
                        left: noosCenter.dx - noosferisOffset,
                        top:  noosCenter.dy - noosferisOffset,
                        child: Transform.scale(
                          scale: 1.30,
                          child: PlanetSphere(
                            planet: _planets[6],
                            isDimmed: _hoveredIndex != null &&
                                _hoveredIndex != 6,
                            onHoverChanged: (isHovered) {
                              setState(() {
                                _hoveredIndex = isHovered ? 6 : null;
                              });
                            },
                            onTap: () {
                              if (_planets[6].isUnlocked) {
                                _onPlanetTapped(6);
                              } else {
                                _showLockedWarning(_planets[6]);
                              }
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // 3. BOTONES DE NAVEGACIÓN ASISTIDA (flechas izquierda/derecha)
              if (_scrollController.hasClients) ...[
                Positioned(
                  left: 15,
                  bottom: 25,
                  child: Semantics(
                    label: 'Mover mapa a la izquierda',
                    button: true,
                    child: _buildNavArrow(
                      icon: Icons.arrow_back_ios_new_rounded,
                      onPressed: () => _navigateScroll(false),
                      visible: _scrollOffset > 10.0,
                    ),
                  ),
                ),
                Positioned(
                  right: 15,
                  bottom: 25,
                  child: Semantics(
                    label: 'Mover mapa a la derecha',
                    button: true,
                    child: _buildNavArrow(
                      icon: Icons.arrow_forward_ios_rounded,
                      onPressed: () => _navigateScroll(true),
                      visible: _scrollOffset <
                          _scrollController.position.maxScrollExtent - 10.0,
                    ),
                  ),
                ),
              ],

              // 4. BARRA SUPERIOR DE ACCESOS DIRECTOS (Material Docente & Álbum)
              Positioned(
                top: 14,
                left: 16,
                right: 16,
                child: Row(
                  children: [
                    // Logo / Título
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: AppColors.surface.withValues(alpha: 0.85),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                            color: AppColors.azulPetroleo, width: 1.5),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.azulPetroleo.withValues(alpha: 0.3),
                            blurRadius: 10,
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.rocket_launch_rounded,
                              color: Color(0xFFFFD54F), size: 18),
                          const SizedBox(width: 8),
                          Text(
                            'TERRACIENCIA',
                            style: GoogleFonts.fredoka(
                              color: Colors.white,
                              fontWeight: FontWeight.w900,
                              fontSize: 13.5,
                              letterSpacing: 1.1,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Spacer(),
                    // Botón Álbum de Insignias
                    _buildTopActionButton(
                      icon: Icons.military_tech_rounded,
                      label: 'Álbum',
                      color: AppColors.mostazaDorado,
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => GaleriaInsigniasScreen(
                              studentName: userName,
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
    bool isPrimary = false,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: isPrimary
                ? color.withValues(alpha: 0.9)
                : AppColors.surface.withValues(alpha: 0.85),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isPrimary ? const Color(0xFFFFD54F) : color,
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: 0.35),
                blurRadius: 8,
              )
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: Colors.white, size: 17),
              const SizedBox(width: 6),
              Text(
                label,
                style: GoogleFonts.fredoka(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  fontSize: 12.5,
                  letterSpacing: 0.2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavArrow({
    required IconData icon,
    required VoidCallback onPressed,
    required bool visible,
  }) {
    return AnimatedScale(
      scale: visible ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 250),
      child: Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          color: AppColors.surface.withValues(alpha: 0.85),
          shape: BoxShape.circle,
          border: Border.all(color: AppColors.azulPetroleo, width: 2.0),
          boxShadow: [
            BoxShadow(
              color: AppColors.azulPetroleo.withValues(alpha: 0.3),
              blurRadius: 15,
            )
          ],
        ),
        child: IconButton(
          onPressed: onPressed,
          icon: Icon(icon, color: Colors.white, size: 28),
        ),
      ),
    );
  }

  // ── Pantalla de bienvenida / registro de nombre (Desactivada) ─────
  // Omitida por el momento: la app inicia directamente en el Mapa Galáctico con userName = "Astronauta".
  /*
  Widget _buildNameInputScreen(BuildContext context) {
    final TextEditingController nameController = TextEditingController();
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: SingleChildScrollView(
          child: Container(
            width: 450,
            padding: const EdgeInsets.all(32),
            margin: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(28),
              border: Border.all(color: AppColors.azulPetroleo, width: 3),
              boxShadow: [
                BoxShadow(
                  color: AppColors.azulPetroleo.withOpacity(0.25),
                  blurRadius: 30,
                  spreadRadius: 2,
                )
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.azulPetroleo.withOpacity(0.15),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.rocket_launch_rounded,
                    color: AppColors.azulPetroleo,
                    size: 56,
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  '¡BIENVENIDO A TERRACIENCIA!',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.fredoka(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'Tu viaje por la Vía Láctea del Saber está a punto de comenzar.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.fredoka(
                    fontSize: 14,
                    color: Colors.white70,
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: 30),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    '¿Cómo te llamas, astronauta?',
                    style: GoogleFonts.fredoka(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.azulPetroleo,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.04),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.white24, width: 1.5),
                  ),
                  child: TextField(
                    controller: nameController,
                    autofocus: true,
                    style:
                        GoogleFonts.fredoka(color: Colors.white, fontSize: 16),
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText: 'Escribe tu nombre aquí...',
                      hintStyle:
                          GoogleFonts.fredoka(color: Colors.white24),
                    ),
                    onSubmitted: (val) {
                      if (val.trim().isNotEmpty) {
                        setState(() {
                          _studentName = val.trim();
                        });
                      }
                    },
                  ),
                ),
                const SizedBox(height: 30),
                SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: ElevatedButton(
                    onPressed: () {
                      if (nameController.text.trim().isNotEmpty) {
                        setState(() {
                          _studentName = nameController.text.trim();
                        });
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Por favor, escribe tu nombre para comenzar.',
                              style: GoogleFonts.fredoka(
                                  fontWeight: FontWeight.bold),
                            ),
                            backgroundColor: AppColors.rojoOxido,
                          ),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.azulPetroleo,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 4,
                    ),
                    child: Text(
                      '¡COMENZAR EL VIAJE!',
                      style: GoogleFonts.fredoka(
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
  */
}
