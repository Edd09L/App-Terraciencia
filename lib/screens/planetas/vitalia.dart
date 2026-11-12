import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// SECCIÓN DE DISEÑO DEL PLANETA (Glow, zoom y esfera)
class VitaliaScreen extends StatefulWidget {
  final String studentName;

  const VitaliaScreen({super.key, required this.studentName});

  @override
  State<VitaliaScreen> createState() => _VitaliaScreenState();
}

class _VitaliaScreenState extends State<VitaliaScreen> {
  double _zoomLevel = 1.0;
  bool _isBadgeUnlocked = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF000000),
      appBar: AppBar(
        title: Text(
          'Mundo Vitalia',
          style: GoogleFonts.fredoka(fontWeight: FontWeight.bold, fontSize: 24),
        ),
        backgroundColor: const Color(0xFF1B5E20).withOpacity(0.2),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
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
                            color: const Color(0xFF1B5E20).withOpacity(0.5),
                            blurRadius: 30,
                            spreadRadius: 4,
                          )
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(75),
                        child: Image.asset(
                          'assets/images/Vitalia.png',
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return const Center(
                              child: Icon(
                                Icons.favorite_rounded,
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
          'Lecciones de Vitalia (Biología)',
          style: GoogleFonts.fredoka(
            fontSize: 22,
            fontWeight: FontWeight.w800,
            color: const Color(0xFFC8E6C9),
          ),
        ),
        const SizedBox(height: 16),

        // TEMA 1 - Seres Vivos (Contenido y lógica adaptativa)
        _buildLessonCard(
          title: 'Tema 1: ¿Qué es la Fotosíntesis?',
          icon: Icons.park_rounded,
          color: const Color(0xFF1B5E20),
          content: [
            'Las plantas son fábricas naturales de oxígeno puro para respirar.',
            'Toman luz solar, agua del suelo y aire sucio de la ciudad.',
            'Como resultado, liberan oxígeno limpio y fabrican su propia comida.',
          ],
        ),
        const SizedBox(height: 16),

        // TEMA 2 - Fotosíntesis Interactiva (Contenido y lógica adaptativa)
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
        side: BorderSide(color: color.withOpacity(0.4), width: 2),
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

  // Actividad interactiva: Regar la Planta
  int _waterClicks = 0;
  Widget _buildInteractiveLessonCard() {
    double plantHeight = 40.0 + (_waterClicks * 20.0);
    return Card(
      color: const Color(0xFF0F0F0F),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: const Color(0xFF1B5E20).withOpacity(0.4), width: 2),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.water_drop_rounded, color: Color(0xFF1B5E20), size: 30),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Tema 2: Haz crecer tu Planta',
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
              'Pulsa el botón azul para regar la semilla con agua y verla germinar:',
              style: GoogleFonts.fredoka(fontSize: 14, color: Colors.white70),
            ),
            const SizedBox(height: 16),
            Center(
              child: Column(
                children: [
                  ElevatedButton.icon(
                    onPressed: () {
                      if (_waterClicks < 4) {
                        setState(() {
                          _waterClicks++;
                        });
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueAccent,
                      foregroundColor: Colors.white,
                    ),
                    icon: const Icon(Icons.opacity),
                    label: Text(
                      _waterClicks >= 4 ? '¡Planta grande!' : 'REGAR AGUA',
                      style: GoogleFonts.fredoka(fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Container(
                    height: 140,
                    width: 100,
                    alignment: Alignment.bottomCenter,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 350),
                      curve: Curves.easeOut,
                      width: 30 + (_waterClicks * 5),
                      height: plantHeight,
                      decoration: BoxDecoration(
                        color: const Color(0xFF1B5E20),
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(30),
                          topRight: Radius.circular(30),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF1B5E20).withOpacity(0.4),
                            blurRadius: 10,
                          )
                        ],
                      ),
                      child: Center(
                        child: Icon(
                          _waterClicks == 0 ? Icons.circle : Icons.spa_rounded,
                          color: Colors.white70,
                          size: 18,
                        ),
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
        border: Border.all(color: const Color(0xFF1B5E20), width: 3),
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
                      backgroundColor: const Color(0xFF1B5E20),
                    ),
                  );
                } else {
                  Navigator.of(context).pop(true);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1B5E20),
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
