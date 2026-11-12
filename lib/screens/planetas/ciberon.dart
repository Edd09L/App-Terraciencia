import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// SECCIÓN DE DISEÑO DEL PLANETA (Glow, zoom y esfera)
class CiberonScreen extends StatefulWidget {
  final String studentName;

  const CiberonScreen({super.key, required this.studentName});

  @override
  State<CiberonScreen> createState() => _CiberonScreenState();
}

class _CiberonScreenState extends State<CiberonScreen> {
  double _zoomLevel = 1.0;
  bool _isBadgeUnlocked = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF000000),
      appBar: AppBar(
        title: Text(
          'Mundo Cíberon',
          style: GoogleFonts.fredoka(fontWeight: FontWeight.bold, fontSize: 24),
        ),
        backgroundColor: const Color(0xFF9E2A2B).withOpacity(0.2),
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
                            color: const Color(0xFF8B6508).withOpacity(0.5),
                            blurRadius: 30,
                            spreadRadius: 4,
                          )
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(75),
                        child: Image.asset(
                          'assets/images/Ciberon.png',
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return const Center(
                              child: Icon(
                                Icons.memory_rounded,
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
          'Lecciones de Cíberon (Tecnología)',
          style: GoogleFonts.fredoka(
            fontSize: 22,
            fontWeight: FontWeight.w800,
            color: const Color(0xFFFFCDD2),
          ),
        ),
        const SizedBox(height: 16),

        // TEMA 1 - Algoritmos (Contenido y lógica adaptativa)
        _buildLessonCard(
          title: 'Tema 1: ¿Cómo piensa un Robot?',
          icon: Icons.smart_toy_rounded,
          color: const Color(0xFF9E2A2B),
          content: [
            'Los robots no piensan solos, siguen una lista de pasos ordenados.',
            'Esta lista de pasos para solucionar problemas se llama algoritmo.',
            'Si cambias el orden de los pasos, el robot puede confundirse.',
          ],
        ),
        const SizedBox(height: 16),

        // TEMA 2 - Partes de una Computadora (Contenido y lógica adaptativa)
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

  // Actividad interactiva: Armar la Computadora
  int _selectedPartIndex = -1;
  final List<String> _parts = ['El Monitor (Pantalla)', 'El CPU (Cerebro)', 'El Teclado y Mouse'];
  final List<String> _partsDesc = [
    'Sirve para ver los dibujos, videos y textos en la pantalla.',
    'Guarda toda la información y hace los cálculos matemáticos.',
    'Nos sirve para escribir y movernos dentro de la pantalla.'
  ];

  Widget _buildInteractiveLessonCard() {
    return Card(
      color: const Color(0xFF0F0F0F),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: const Color(0xFF9E2A2B).withOpacity(0.4), width: 2),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.computer_rounded, color: Color(0xFF9E2A2B), size: 30),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Tema 2: Partes de la Computadora',
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
              'Haz clic en cada parte para conocer su función:',
              style: GoogleFonts.fredoka(fontSize: 14, color: Colors.white70),
            ),
            const SizedBox(height: 16),
            Column(
              children: List.generate(_parts.length, (idx) {
                final bool isSelected = _selectedPartIndex == idx;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 10.0),
                  child: InkWell(
                    onTap: () {
                      setState(() {
                        _selectedPartIndex = idx;
                      });
                    },
                    borderRadius: BorderRadius.circular(12),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.all(14),
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: isSelected ? const Color(0xFF9E2A2B).withOpacity(0.2) : Colors.white.withOpacity(0.03),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSelected ? const Color(0xFF9E2A2B) : Colors.transparent,
                          width: 2,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                isSelected ? Icons.radio_button_checked_rounded : Icons.radio_button_off_rounded,
                                color: const Color(0xFF9E2A2B),
                              ),
                              const SizedBox(width: 10),
                              Text(
                                _parts[idx],
                                style: GoogleFonts.fredoka(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                          if (isSelected) ...[
                            const SizedBox(height: 8),
                            Text(
                              _partsDesc[idx],
                              style: GoogleFonts.fredoka(fontSize: 13, color: Colors.white70),
                            ),
                          ]
                        ],
                      ),
                    ),
                  ),
                );
              }),
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
        border: Border.all(color: const Color(0xFF9E2A2B), width: 3),
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
                      backgroundColor: const Color(0xFF9E2A2B),
                    ),
                  );
                } else {
                  Navigator.of(context).pop(true);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF9E2A2B),
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



