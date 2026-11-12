import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// SECCIÓN DE DISEÑO DEL PLANETA (Glow, zoom y esfera)
class TitanQScreen extends StatefulWidget {
  final String studentName;

  const TitanQScreen({super.key, required this.studentName});

  @override
  State<TitanQScreen> createState() => _TitanQScreenState();
}

class _TitanQScreenState extends State<TitanQScreen> {
  double _zoomLevel = 1.0;
  bool _isBadgeUnlocked = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF000000),
      appBar: AppBar(
        title: Text(
          'Mundo Titan-Q',
          style: GoogleFonts.fredoka(fontWeight: FontWeight.bold, fontSize: 24),
        ),
        backgroundColor: const Color(0xFFA1005B).withOpacity(0.2),
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
                            color: const Color(0xFF004F77).withOpacity(0.5),
                            blurRadius: 30,
                            spreadRadius: 4,
                          )
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(75),
                        child: Image.asset(
                          'assets/images/Titan-Q.png',
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return const Center(
                              child: Icon(
                                Icons.science_rounded,
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
          'Lecciones de Titan-Q (Química)',
          style: GoogleFonts.fredoka(
            fontSize: 22,
            fontWeight: FontWeight.w800,
            color: const Color(0xFFF8BBD0),
          ),
        ),
        const SizedBox(height: 16),

        // TEMA 1 - Mezclas homogéneas (Contenido y lógica adaptativa)
        _buildLessonCard(
          title: 'Tema 1: ¿De qué están hechas las cosas?',
          icon: Icons.bubble_chart_rounded,
          color: const Color(0xFFA1005B),
          content: [
            'Todo lo que nos rodea en el universo está hecho de materia.',
            'La materia está compuesta de partes diminutas llamadas átomos.',
            'Los átomos se juntan para formar materiales como el agua o el metal.',
          ],
        ),
        const SizedBox(height: 16),

        // TEMA 2 - Estados de la Materia (Contenido y lógica adaptativa)
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

  // Actividad interactiva: Cambiar Estados de la Materia
  String _matterState = 'Sólido'; // Sólido, Líquido, Gaseoso
  Widget _buildInteractiveLessonCard() {
    return Card(
      color: const Color(0xFF0F0F0F),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: const Color(0xFFA1005B).withOpacity(0.4), width: 2),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.ac_unit_rounded, color: Color(0xFFA1005B), size: 30),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Tema 2: Estados del Agua',
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
              'Selecciona un estado de la materia para ver cómo se comportan sus átomos:',
              style: GoogleFonts.fredoka(fontSize: 14, color: Colors.white70),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _stateButton('Sólido'),
                _stateButton('Líquido'),
                _stateButton('Gaseoso'),
              ],
            ),
            const SizedBox(height: 20),
            Center(
              child: Container(
                width: 150,
                height: 100,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.white24),
                ),
                child: _buildStateVisual(),
              ),
            ),
            const SizedBox(height: 10),
            Center(
              child: Text(
                _getStateExplanation(),
                textAlign: TextAlign.center,
                style: GoogleFonts.fredoka(
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                  color: const Color(0xFFA1005B),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _stateButton(String state) {
    final bool isSelected = _matterState == state;
    return ElevatedButton(
      onPressed: () {
        setState(() {
          _matterState = state;
        });
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: isSelected ? const Color(0xFFA1005B) : Colors.white10,
        foregroundColor: Colors.white,
      ),
      child: Text(
        state,
        style: GoogleFonts.fredoka(fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildStateVisual() {
    if (_matterState == 'Sólido') {
      // Átomos juntos y estáticos (Hielo)
      return const Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.circle, color: Color(0xFFA1005B), size: 18),
              Icon(Icons.circle, color: Color(0xFFA1005B), size: 18),
              Icon(Icons.circle, color: Color(0xFFA1005B), size: 18),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.circle, color: Color(0xFFA1005B), size: 18),
              Icon(Icons.circle, color: Color(0xFFA1005B), size: 18),
              Icon(Icons.circle, color: Color(0xFFA1005B), size: 18),
            ],
          ),
        ],
      );
    } else if (_matterState == 'Líquido') {
      // Átomos semi-separados y fluidos
      return const Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Icon(Icons.circle, color: Color(0xFFA1005B), size: 18),
          Padding(
            padding: EdgeInsets.only(top: 20),
            child: Icon(Icons.circle, color: Color(0xFFA1005B), size: 18),
          ),
          Icon(Icons.circle, color: Color(0xFFA1005B), size: 18),
        ],
      );
    } else {
      // Gaseoso: Átomos volando libres
      return const Stack(
        children: [
          Positioned(top: 10, left: 20, child: Icon(Icons.circle, color: Color(0xFFA1005B), size: 14)),
          Positioned(bottom: 15, left: 60, child: Icon(Icons.circle, color: Color(0xFFA1005B), size: 14)),
          Positioned(top: 20, right: 30, child: Icon(Icons.circle, color: Color(0xFFA1005B), size: 14)),
        ],
      );
    }
  }

  String _getStateExplanation() {
    if (_matterState == 'Sólido') {
      return 'Hielo: Los átomos están muy juntos y no se mueven.';
    } else if (_matterState == 'Líquido') {
      return 'Agua: Los átomos están un poco sueltos y fluyen.';
    } else {
      return 'Vapor: Los átomos vuelan libres por el aire.';
    }
  }

  Widget _buildBadgeSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF0F0F0F),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFA1005B), width: 3),
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
                      backgroundColor: const Color(0xFFA1005B),
                    ),
                  );
                } else {
                  Navigator.of(context).pop(true);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFA1005B),
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
