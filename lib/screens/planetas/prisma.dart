import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/topic.dart';
import '../lesson_template_screen.dart';

// SECCIÓN DE DISEÑO DEL PLANETA (Glow, zoom y esfera)
class PrismaScreen extends StatefulWidget {
  final String studentName;

  const PrismaScreen({super.key, required this.studentName});

  @override
  State<PrismaScreen> createState() => _PrismaScreenState();
}

class _PrismaScreenState extends State<PrismaScreen> {
  double _zoomLevel = 1.0;
  bool _isBadgeUnlocked = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF000000),
      appBar: AppBar(
        title: Text(
          'Mundo Prisma',
          style: GoogleFonts.fredoka(fontWeight: FontWeight.bold, fontSize: 24),
        ),
        backgroundColor: const Color(0xFF4B0082).withValues(alpha: 0.2),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            // Representación visual interactiva de Prisma
            Center(
              child: MouseRegion(
                cursor: SystemMouseCursors.click,
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      _zoomLevel = _zoomLevel == 1.0 ? 1.25 : 1.0;
                    });
                  },
                  child: AnimatedScale(
                    scale: _zoomLevel,
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeOutBack,
                    child: Container(
                      width: 150,
                      height: 150,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF4B0082).withValues(alpha: 0.5),
                            blurRadius: 30,
                            spreadRadius: 4,
                          )
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(75),
                        child: Image.asset(
                          'assets/images/Prisma.png',
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return const Center(
                              child: Icon(
                                Icons.wb_sunny_rounded,
                                size: 64,
                                color: Colors.white,
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Toca el planeta para acercarlo',
              style: GoogleFonts.fredoka(color: Colors.white54, fontSize: 13),
            ),
            const SizedBox(height: 30),

            // SECCIÓN DE LECCIONES DEL MUNDO
            _buildLessons(),

            const SizedBox(height: 40),

            // LÓGICA DE INSIGNIA Y EXPORTACIÓN PDF
            _buildBadgeSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildLessons() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Lecciones de Prisma (Física de la Luz)',
          style: GoogleFonts.fredoka(
            fontSize: 22,
            fontWeight: FontWeight.w800,
            color: const Color(0xFFD1C4E9),
          ),
        ),
        const SizedBox(height: 16),

        // TEMA 1 - La curiosidad humana y la ciencia (Abre la pantalla de plantilla DUA)
        InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const LessonTemplateScreen(
                  topic: Topic(
                    id: 'prisma_tema_1',
                    title: '1. La curiosidad humana y la ciencia',
                    description: 'Descubre cómo nace la ciencia a partir de hacernos preguntas cotidianas.',
                    planetId: 'prisma',
                    badgeAssetPath: 'assets/images/insignia_curiosidad.svg',
                  ),
                ),
              ),
            );
          },
          borderRadius: BorderRadius.circular(20),
          child: _buildLessonCard(
            title: 'Tema 1: La curiosidad humana y la ciencia',
            icon: Icons.lightbulb_rounded,
            color: const Color(0xFF4B0082),
            content: [
              'Todos nacemos siendo exploradores y la ciencia nace de las preguntas.',
              'Usa tus sentidos para observar y descubre los saberes de tu comunidad.',
              '¡Toca aquí para entrar a la lección DUA completa!',
            ],
          ),
        ),
        const SizedBox(height: 16),

        // TEMA 2 - Lentes y lupas (Contenido y lógica adaptativa con interacción táctil)
        _buildInteractiveLessonCard(),
      ],
    );
  }

  Widget _buildLessonCard({
    required String title,
    required IconData icon,
    required Color color,
    required List<String> content,
  }) {
    return Card(
      color: const Color(0xFF0F0F0F),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: color.withValues(alpha: 0.4), width: 2),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 30),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    style: GoogleFonts.fredoka(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            ...content.map(
              (text) => Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.check_circle_rounded, color: color, size: 20),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        text,
                        style: GoogleFonts.fredoka(
                          fontSize: 14,
                          color: Colors.white70,
                          height: 1.4,
                        ),
                      ),
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

  // Lección interactiva para que los estudiantes jueguen a hacer zoom (tactilidad)
  double _lensScale = 1.0;
  Widget _buildInteractiveLessonCard() {
    return Card(
      color: const Color(0xFF0F0F0F),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: const Color(0xFF4B0082).withValues(alpha: 0.4), width: 2),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.zoom_in_rounded, color: Color(0xFF4B0082), size: 30),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Tema 2: ¿Cómo funciona una lupa?',
                    style: GoogleFonts.fredoka(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Text(
              'Las lupas tienen lentes curvos que doblan la luz para que las cosas pequeñas se vean gigantes.',
              style: GoogleFonts.fredoka(fontSize: 14, color: Colors.white70, height: 1.4),
            ),
            const SizedBox(height: 16),
            Center(
              child: Column(
                children: [
                  Text(
                    '¡Desliza para usar la lupa!',
                    style: GoogleFonts.fredoka(fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  Slider(
                    value: _lensScale,
                    min: 1.0,
                    max: 2.2,
                    activeColor: const Color(0xFF4B0082),
                    inactiveColor: Colors.white12,
                    onChanged: (val) {
                      setState(() {
                        _lensScale = val;
                      });
                    },
                  ),
                  const SizedBox(height: 10),
                  AnimatedScale(
                    scale: _lensScale,
                    duration: const Duration(milliseconds: 100),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFF4B0082).withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.bug_report_rounded, color: Color(0xFF4B0082), size: 28),
                          const SizedBox(width: 8),
                          Text(
                            '¡Mariquita Gigante!',
                            style: GoogleFonts.fredoka(fontSize: 14, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBadgeSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF0F0F0F),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFF4B0082), width: 3),
      ),
      child: Column(
        children: [
          Icon(
            _isBadgeUnlocked ? Icons.emoji_events_rounded : Icons.lock_outline_rounded,
            size: 80,
            color: _isBadgeUnlocked ? const Color(0xFF8B6508) : Colors.grey,
          ),
          const SizedBox(height: 16),
          Text(
            _isBadgeUnlocked
                ? '¡Insignia Desbloqueada!'
                : 'Completa las actividades para ganar tu insignia',
            style: GoogleFonts.fredoka(fontSize: 18, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 10),
          Text(
            _isBadgeUnlocked
                ? '¡Felicidades, ${widget.studentName}! Esta medalla estará lista en tu álbum Noosféris.'
                : 'Presiona el botón de abajo para terminar de estudiar este planeta.',
            textAlign: TextAlign.center,
            style: GoogleFonts.fredoka(fontSize: 14, color: Colors.white70),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: () {
                if (!_isBadgeUnlocked) {
                  setState(() {
                    _isBadgeUnlocked = true;
                  });
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        '¡Insignia ganada para ${widget.studentName}!',
                        style: GoogleFonts.fredoka(fontWeight: FontWeight.bold, color: Colors.black),
                      ),
                      backgroundColor: const Color(0xFF4B0082),
                    ),
                  );
                } else {
                  // Regresa al Home y reporta que el planeta se completó
                  Navigator.of(context).pop(true);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4B0082),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: Text(
                _isBadgeUnlocked ? 'VOLVER AL ESPACIO' : '¡RECLAMAR MI INSIGNIA!',
                style: GoogleFonts.fredoka(fontWeight: FontWeight.w900, fontSize: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
