import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../../models/planet_data.dart';
import '../../models/app_colors.dart';
import '../../models/topic.dart';
import '../../data/topics_database.dart';
import '../../providers/progress_provider.dart';
import '../../services/pdf_sticker_service.dart';
import '../teacher_material_screen.dart';

/// Alias para soportar ambas denominaciones de la pantalla del Hub
typedef NoosferisHubScreen = NoosferisScreen;

// SECCIÓN DE DISEÑO DEL PLANETA (Glow, zoom y esfera)
class NoosferisScreen extends StatefulWidget {
  final String studentName;
  final List<PlanetData> planets;

  const NoosferisScreen({
    super.key,
    required this.studentName,
    required this.planets,
  });

  @override
  State<NoosferisScreen> createState() => _NoosferisScreenState();
}

class _NoosferisScreenState extends State<NoosferisScreen> {
  // Categoría activa del Hub: 0 = Menú Hub, 1 = Galería, 2 = Explorar, 3 = Recursos Docentes
  int _activeCategory = 0;

  // Grado académico seleccionado para filtrar la malla curricular
  String _selectedGrade = '2do Básico';
  final List<String> _gradeOptions = const [
    '1ro Básico',
    '2do Básico',
    '3ro Básico',
    '4to Bachillerato',
    '5to Bachillerato',
  ];

  // Lógica de selección múltiple de las 40 insignias
  final Map<String, bool> _selectedBadges = {};

  @override
  void initState() {
    super.initState();
    // Inicializar la lista de los 40 temas/insignias
    for (var topic in allTopics) {
      _selectedBadges[topic.id] = false;
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(
          _getAppBarTitle(),
          style: GoogleFonts.fredoka(fontWeight: FontWeight.bold, fontSize: 24, color: Colors.white),
        ),
        backgroundColor: const Color(0xFF0F172A).withOpacity(0.60),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
          onPressed: () {
            if (_activeCategory != 0) {
              setState(() {
                _activeCategory = 0; // Regresa al menú Hub
              });
            } else {
              Navigator.of(context).pop(); // Regresa al mapa estelar
            }
          },
        ),
      ),
      body: Stack(
        children: [
          // 1. CONFIGURACIÓN DEL FONDO (BACKGROUND IMAGE)
          Positioned.fill(
            child: Image.asset(
              'assets/images/Noosféris paisaje.jpg',
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Image.asset(
                  'assets/images/Noosferis paisaje.jpg',
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Image.asset(
                      'Imágenes utilizadas/Noosféris paisaje.jpg',
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(color: const Color(0xFF0A0F1D));
                      },
                    );
                  },
                );
              },
            ),
          ),

          // 2. CAPA DE CONTRASTE Y LEGIBILIDAD (OVERLAY)
          Positioned.fill(
            child: Container(
              color: Colors.black.withOpacity(0.35),
            ),
          ),

          // 3. CONTENIDO DEL HUB
          SafeArea(
            child: _buildBody(),
          ),
        ],
      ),
    );
  }

  String _getAppBarTitle() {
    switch (_activeCategory) {
      case 1:
        return 'Galería de Insignias';
      case 2:
        return 'Recursos Docentes';
      default:
        return 'Noosféris - Hub de Sabiduría';
    }
  }

  Widget _buildBody() {
    switch (_activeCategory) {
      case 1:
        return _buildBadgesGallery();
      case 2:
        return _buildTeacherResources();
      default:
        return _buildHubMenu();
    }
  }

  // ─── MENÚ HUB PRINCIPAL: REDISEÑO CÓSMICO GLASSMORPHISM ─────────────────
  Widget _buildHubMenu() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth >= 760;

        return SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
          physics: const BouncingScrollPhysics(),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1040),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // 1. BANNER DE BIENVENIDA (GLASSMORPHISM TRASLÚCIDO FLOTANTE)
                  _buildWelcomeBanner(),

                  const SizedBox(height: 24),

                  // 2. CONTENEDOR RESPONSIVO DE TARJETAS (GRID EN DESKTOP / COLUMNA EN MÓVIL)
                  if (isWide)
                    IntrinsicHeight(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Expanded(child: _buildBadgesHubCard()),
                          const SizedBox(width: 22),
                          Expanded(child: _buildTeacherResourcesHubCard()),
                        ],
                      ),
                    )
                  else
                    Column(
                      children: [
                        _buildBadgesHubCard(),
                        const SizedBox(height: 20),
                        _buildTeacherResourcesHubCard(),
                      ],
                    ),

                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // ── 1. BANNER DE BIENVENIDA GLASSMORPHISM ────────────────────────────────
  Widget _buildWelcomeBanner() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 18),
      decoration: BoxDecoration(
        color: const Color(0xCC0F172A), // Glassmorphism traslúcido
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFF8B5CF6).withOpacity(0.50), // Morado resplandeciente
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF8B5CF6).withOpacity(0.20),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.40),
            blurRadius: 14,
          ),
        ],
      ),
      child: Row(
        children: [
          // Ícono de Trofeo / Estrella Brillante
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF8B5CF6).withOpacity(0.22),
              shape: BoxShape.circle,
              border: Border.all(
                color: const Color(0xFFA78BFA),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFA78BFA).withOpacity(0.40),
                  blurRadius: 12,
                ),
              ],
            ),
            child: const Icon(
              Icons.emoji_events_rounded,
              color: Color(0xFFFBBF24), // Dorado radiante
              size: 28,
            ),
          ),
          const SizedBox(width: 16),

          // Texto de Bienvenida con tipografía blanca en negrita
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '¡Hola, ${widget.studentName}!',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    letterSpacing: -0.2,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  'Bienvenido a Noosféris, el centro universal de sabiduría y recursos pedagógicos DUA de Terraciencia.',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFFCBD5E1),
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── 2. TARJETA 1: GALERÍA DE INSIGNIAS DUA ───────────────────────────────
  Widget _buildBadgesHubCard() {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF1E1B4B), // Azul Púrpura Profundo
            Color(0xFF0F172A), // Slate Espacial Oscuro
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFF8B5CF6).withOpacity(0.60),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF8B5CF6).withOpacity(0.25),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Fila Superior: Círculo Neón + Badge Violeta Neón
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: const Color(0xFF8B5CF6).withOpacity(0.20),
                      shape: BoxShape.circle,
                      border: Border.all(color: const Color(0xFFA78BFA), width: 1.5),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF8B5CF6).withOpacity(0.45),
                          blurRadius: 14,
                        ),
                      ],
                    ),
                    child: const Icon(Icons.auto_awesome_rounded, color: Color(0xFFEDE9FE), size: 28),
                  ),

                  // Badge superior derecho moderno
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: const Color(0xFF7C3AED).withOpacity(0.40),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: const Color(0xFFA78BFA), width: 1.2),
                    ),
                    child: Text(
                      '40 Insignias Coleccionables',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFFEDE9FE),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),

              // Título de la Tarjeta
              Text(
                'Galería de Insignias DUA',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 19,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                  letterSpacing: -0.2,
                ),
              ),
              const SizedBox(height: 8),

              // Descripción
              Text(
                'Explora el álbum completo de 40 estampitas, selecciona tus insignias ganadas y genera el PDF listo para imprimir.',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF94A3B8),
                  height: 1.45,
                ),
              ),
            ],
          ),
          const SizedBox(height: 22),

          // Botón Interactivo de Acción al Pie
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton.icon(
              onPressed: () => setState(() => _activeCategory = 1),
              icon: const Icon(Icons.auto_stories_rounded, size: 18, color: Colors.white),
              label: Text(
                'Abrir Álbum de Estampitas',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF7C3AED),
                foregroundColor: Colors.white,
                elevation: 4,
                shadowColor: const Color(0xFF7C3AED).withOpacity(0.50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: const BorderSide(color: Color(0xFFA78BFA), width: 1.0),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── 3. TARJETA 2: RECURSOS DOCENTES & MALLA CURRICULAR ────────────────────
  Widget _buildTeacherResourcesHubCard() {
    final bool isSecondGradeActive = _selectedGrade == '2do Básico';

    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF002B49), // Azul Petróleo Profundo
            Color(0xFF0F172A), // Slate Espacial Oscuro
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFF38BDF8).withOpacity(0.60),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF38BDF8).withOpacity(0.25),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Fila Superior: Círculo Neón + Badge de Estado de Grado
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: const Color(0xFF38BDF8).withOpacity(0.18),
                      shape: BoxShape.circle,
                      border: Border.all(color: const Color(0xFF38BDF8), width: 1.5),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF38BDF8).withOpacity(0.40),
                          blurRadius: 14,
                        ),
                      ],
                    ),
                    child: const Icon(Icons.school_rounded, color: Color(0xFFBAE6FD), size: 28),
                  ),

                  // Badge superior dinámico
                  if (isSecondGradeActive)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: const Color(0xFF059669).withOpacity(0.35),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: const Color(0xFF34D399), width: 1.2),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.check_circle_rounded, size: 14, color: Color(0xFF34D399)),
                          const SizedBox(width: 5),
                          Text(
                            '31 Semanas DUA Activas',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w800,
                              color: const Color(0xFFD1FAE5),
                            ),
                          ),
                        ],
                      ),
                    )
                  else
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: const Color(0xFFD97706).withOpacity(0.35),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: const Color(0xFFFBBF24), width: 1.2),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.hourglass_top_rounded, size: 14, color: Color(0xFFFBBF24)),
                          const SizedBox(width: 5),
                          Text(
                            'En Desarrollo Pedagógico',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w800,
                              color: const Color(0xFFFEF3C7),
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 18),

              // Título de la Tarjeta
              Text(
                'Recursos Docentes & Malla Curricular',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 19,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                  letterSpacing: -0.2,
                ),
              ),
              const SizedBox(height: 10),

              // SELECTOR DE GRADO ACADÉMICO MODERNO
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E293B),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: const Color(0xFF38BDF8).withOpacity(0.70),
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.25),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    const Icon(Icons.school_outlined, color: Color(0xFF38BDF8), size: 18),
                    const SizedBox(width: 8),
                    Text(
                      'Grado:',
                      style: GoogleFonts.plusJakartaSans(
                        color: const Color(0xFF94A3B8),
                        fontSize: 12.5,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _selectedGrade,
                          dropdownColor: const Color(0xFF0F172A),
                          icon: const Icon(Icons.arrow_drop_down_rounded, color: Color(0xFF38BDF8)),
                          style: GoogleFonts.plusJakartaSans(
                            color: Colors.white,
                            fontSize: 13.5,
                            fontWeight: FontWeight.w800,
                          ),
                          onChanged: (newGrade) {
                            if (newGrade != null) {
                              setState(() => _selectedGrade = newGrade);
                            }
                          },
                          items: _gradeOptions.map((g) {
                            return DropdownMenuItem<String>(
                              value: g,
                              child: Text(
                                g,
                                style: GoogleFonts.plusJakartaSans(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              // CONTENIDO CONDICIONAL POR GRADO
              if (isSecondGradeActive)
                Text(
                  'Malla curricular oficial de 31 semanas, presentaciones interactivas, guías didácticas y simuladores DUA.',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF94A3B8),
                    height: 1.45,
                  ),
                )
              else
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFD97706).withOpacity(0.12),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: const Color(0xFFD97706).withOpacity(0.40),
                      width: 1.0,
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.info_outline_rounded, color: Color(0xFFFBBF24), size: 18),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'La malla curricular DUA para $_selectedGrade se encuentra en fase de desarrollo pedagógico.',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFFFEF3C7),
                            height: 1.35,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: 22),

          // Botón de Acción Condicional al Pie
          if (isSecondGradeActive)
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const TeacherMaterialScreen(
                        initialGrade: '2do Básico',
                      ),
                    ),
                  );
                },
                icon: const Icon(Icons.menu_book_rounded, size: 18, color: Colors.white),
                label: Text(
                  'Ver Malla Curricular',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0284C7),
                  foregroundColor: Colors.white,
                  elevation: 4,
                  shadowColor: const Color(0xFF0284C7).withOpacity(0.50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: const BorderSide(color: Color(0xFF38BDF8), width: 1.0),
                  ),
                ),
              ),
            )
          else
            SizedBox(
              width: double.infinity,
              height: 48,
              child: OutlinedButton.icon(
                onPressed: null, // Deshabilitado
                icon: const Icon(Icons.lock_clock_rounded, size: 18, color: Color(0xFF94A3B8)),
                label: Text(
                  'Próximamente disponible',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF94A3B8),
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  backgroundColor: Colors.white.withOpacity(0.04),
                  side: const BorderSide(color: Color(0xFF334155), width: 1.2),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  // Recursos Docentes
  Widget _buildTeacherResources() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Guía para el Maestro',
            style: GoogleFonts.fredoka(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.greenAccent),
          ),
          const SizedBox(height: 10),
          Text(
            'En Terraciencia fomentamos que el aprendizaje digital se materialice en el aula física. Aquí tienes las herramientas:',
            style: GoogleFonts.fredoka(fontSize: 14, color: Colors.white70, height: 1.4),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton.icon(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const TeacherMaterialScreen(),
                  ),
                );
              },
              icon: const Icon(Icons.school_rounded, color: Colors.white),
              label: Text(
                'ABRIR MALLA CURRICULAR Y RECURSOS (31 SEMANAS)',
                style: GoogleFonts.fredoka(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.azulPetroleo,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 4,
              ),
            ),
          ),
          const SizedBox(height: 20),
          _buildResourceCard(
            title: 'Lista de Códigos de Lecciones',
            desc: 'Ingresa estos códigos en el buscador del mapa estelar para saltar directamente a la lección:\n\n'
                '• Prisma (Luz): PRI1, PRI2\n'
                '• Cíberon (Robots): CIB1, CIB2\n'
                '• Simbios (Ambiente): SIM1, SIM2\n'
                '• Vitalia (Biología): VIT1, VIT2\n'
                '• Titan-Q (Química): TIT1, TIT2\n'
                '• Kinetos (Fuerzas): KIN1, KIN2',
            icon: Icons.code_rounded,
          ),
          const SizedBox(height: 16),
          _buildResourceCard(
            title: 'Idea de Actividad en el Aula',
            desc: '1. Imprime el Álbum de Stickers Físico en papel cartulina.\n'
                '2. Cuando el estudiante complete un planeta en la tablet, pídele que seleccione la insignia ganada aquí en Noosféris.\n'
                '3. Genera e imprime el PDF de stickers en papel autoadhesivo.\n'
                '4. Entrega el sticker personalizado al alumno para que lo pegue en su mural físico.',
            icon: Icons.lightbulb_outline_rounded,
          ),
        ],
      ),
    );
  }

  Widget _buildResourceCard({required String title, required String desc, required IconData icon}) {
    return Card(
      color: const Color(0xFF0F0F0F),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: const BorderSide(color: Colors.white12)),
      child: Padding(
        padding: const EdgeInsets.all(18.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Icons.circle_notifications_rounded, color: Colors.greenAccent, size: 30),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: GoogleFonts.fredoka(fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text(desc, style: GoogleFonts.fredoka(fontSize: 13, color: Colors.white70, height: 1.35)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── GALERÍA DE INSIGNIAS — Grid completo de 40 espacios ────────────
  Widget _buildBadgesGallery() {
    final provider = context.watch<ProgressProvider>();
    final int unlockedCount = allTopics.where((t) => provider.isUnlocked(t.id)).length;
    final int selectedCount = _selectedBadges.values.where((v) => v).length;

    return Column(
      children: [
        // ── Cabecera informativa con contador de selección ─────────────────
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: const BoxDecoration(
            color: Color(0xFF0A0A0A),
            border: Border(bottom: BorderSide(color: Colors.white10, width: 1)),
          ),
          child: Row(
            children: [
              const Icon(Icons.auto_awesome_rounded,
                  color: AppColors.mostazaDorado, size: 16),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  '40 Espacios de Insignias • $unlockedCount/40 Desbloqueadas',
                  style: GoogleFonts.fredoka(fontSize: 12, color: Colors.white70),
                ),
              ),
              TextButton(
                onPressed: () {
                  final bool anySelected = selectedCount > 0;
                  setState(() {
                    for (var t in allTopics) {
                      _selectedBadges[t.id] = !anySelected;
                    }
                  });
                },
                child: Text(
                  selectedCount > 0 ? 'Deseleccionar' : 'Seleccionar Todo',
                  style: GoogleFonts.fredoka(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: AppColors.mostazaDorado,
                  ),
                ),
              ),
              if (selectedCount > 0) ...[
                const SizedBox(width: 6),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.mostazaDorado.withOpacity(0.20),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                        color: AppColors.mostazaDorado.withOpacity(0.6)),
                  ),
                  child: Text(
                    '$selectedCount ✓',
                    style: GoogleFonts.fredoka(
                      fontSize: 11,
                      fontWeight: FontWeight.w900,
                      color: AppColors.mostazaDorado,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),

        // ── Grid completo de 40 insignias (5-6 columnas en scroll) ─────────
        Expanded(
          child: GridView.builder(
            padding: const EdgeInsets.all(14),
            gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: 135,
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
              childAspectRatio: 0.92,
            ),
            itemCount: allTopics.length, // 40 insignias
            itemBuilder: (context, index) {
              final topic = allTopics[index];
              final bool isUnlocked = provider.isUnlocked(topic.id);
              final bool isSelected = _selectedBadges[topic.id] ?? false;
              return _buildTopicBadgeCell(topic, isUnlocked, isSelected);
            },
          ),
        ),

        // ── Botón PDF anclado al fondo ────────────────────────────────────
        Container(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
          decoration: BoxDecoration(
            color: AppColors.surface,
            border: const Border(top: BorderSide(color: Colors.white10, width: 1)),
          ),
          child: SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton.icon(
              onPressed: () => _generateStickersPDF(provider),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.mostazaDorado,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 4,
              ),
              icon: const Icon(Icons.print_rounded, size: 20),
              label: Text(
                selectedCount > 0
                    ? 'IMPRIMIR $selectedCount STICKERS SELECCIONADOS'
                    : 'PREPARAR STICKERS PARA MI ÁLBUM (PDF)',
                style: GoogleFonts.fredoka(
                  fontWeight: FontWeight.w900,
                  fontSize: 13,
                  letterSpacing: 0.4,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// Celda individual de tema/insignia dentro del grid de 40.
  Widget _buildTopicBadgeCell(Topic topic, bool isUnlocked, bool isSelected) {
    final planetColor = _getPlanetColor(topic.planetId);

    return InkWell(
      onTap: () {
        setState(() {
          _selectedBadges[topic.id] = !isSelected;
        });
      },
      borderRadius: BorderRadius.circular(14),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        decoration: BoxDecoration(
          color: isSelected
              ? planetColor.withOpacity(0.22)
              : const Color(0xFF0F0F0F),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected
                ? AppColors.mostazaDorado
                : (isUnlocked
                    ? planetColor.withOpacity(0.6)
                    : Colors.white10),
            width: isSelected ? 2.5 : (isUnlocked ? 1.8 : 1.2),
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.mostazaDorado.withOpacity(0.35),
                    blurRadius: 10,
                    spreadRadius: 1,
                  )
                ]
              : (isUnlocked
                  ? [
                      BoxShadow(
                        color: planetColor.withOpacity(0.20),
                        blurRadius: 8,
                        spreadRadius: 1,
                      )
                    ]
                  : []),
        ),
        child: Stack(
          children: [
            // Indicador de selección
            Positioned(
              top: 5,
              right: 5,
              child: isSelected
                  ? Container(
                      width: 18,
                      height: 18,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.mostazaDorado,
                      ),
                      child: const Icon(Icons.check, size: 12, color: Colors.white),
                    )
                  : (isUnlocked
                      ? Icon(
                          Icons.radio_button_unchecked,
                          color: planetColor.withOpacity(0.35),
                          size: 14,
                        )
                      : const SizedBox.shrink()),
            ),

            // Contenido central
            Center(
              child: Padding(
                padding: const EdgeInsets.all(6.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isUnlocked
                          ? _getPlanetIcon(topic.planetId)
                          : Icons.lock_outline_rounded,
                      size: 26,
                      color: isUnlocked ? planetColor : Colors.white24,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      topic.id,
                      style: GoogleFonts.fredoka(
                        fontSize: 9.5,
                        fontWeight: FontWeight.bold,
                        color: isUnlocked ? Colors.white : Colors.white38,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 1,
                    ),
                    const SizedBox(height: 1),
                    Text(
                      topic.title,
                      style: GoogleFonts.fredoka(
                        fontSize: 8.0,
                        color: isUnlocked ? Colors.white70 : Colors.white24,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Generación del documento PDF con las 40 insignias seleccionadas mediante Printing.layoutPdf.
  Future<void> _generateStickersPDF(ProgressProvider provider) async {
    // Obtener los temas seleccionados
    final selectedTopics = allTopics.where((t) => _selectedBadges[t.id] == true).toList();

    if (selectedTopics.isEmpty) {
      final unlockedTopics = allTopics.where((t) => provider.isUnlocked(t.id)).toList();
      if (unlockedTopics.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '¡Aún no has seleccionado ni desbloqueado insignias para exportar!',
              style: GoogleFonts.fredoka(fontWeight: FontWeight.bold, color: Colors.white),
            ),
            backgroundColor: AppColors.rojoOxido,
          ),
        );
        return;
      }
      await PdfStickerService.generateAndPrint(unlockedTopics);
      return;
    }

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

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
      name: 'insignias_terraciencia_${widget.studentName.replaceAll(' ', '_')}.pdf',
    );
  }
}
