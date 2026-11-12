import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// SECCIÓN DE DISEÑO DEL PLANETA (Glow, zoom y esfera)
class SimbiosScreen extends StatefulWidget {
  final String studentName;

  const SimbiosScreen({super.key, required this.studentName});

  @override
  State<SimbiosScreen> createState() => _SimbiosScreenState();
}

class _SimbiosScreenState extends State<SimbiosScreen> {
  double _zoomLevel = 1.0;
  bool _isBadgeUnlocked = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF000000),
      appBar: AppBar(
        title: Text(
          'Mundo Simbios',
          style: GoogleFonts.fredoka(fontWeight: FontWeight.bold, fontSize: 24),
        ),
        backgroundColor: const Color(0xFF4A2711).withOpacity(0.2),
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
                          'assets/images/Simbios.png',
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return const Center(
                              child: Icon(
                                Icons.recycling_rounded,
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
          'Lecciones de Simbios (Medio Ambiente)',
          style: GoogleFonts.fredoka(
            fontSize: 22,
            fontWeight: FontWeight.w800,
            color: const Color(0xFFD7CCC8),
          ),
        ),
        const SizedBox(height: 16),

        // TEMA 1 - Ecosistemas (Contenido y lógica adaptativa)
        _buildLessonCard(
          title: 'Tema 1: ¿Qué es la Biodiversidad?',
          icon: Icons.eco_rounded,
          color: const Color(0xFF4A2711),
          content: [
            'La biodiversidad es la variedad de todos los seres vivos en la Tierra.',
            'Los animales, plantas y hongos dependen unos de otros para sobrevivir.',
            'Cuidar su espacio (los ríos, bosques y lagos) ayuda a mantener el equilibrio.',
          ],
        ),
        const SizedBox(height: 16),

        // TEMA 2 - Reciclaje Interactivo (Contenido y lógica adaptativa)
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

  // Actividad interactiva: Separador de Basura
  String _selectedTrash = 'Botella de Plástico';
  String _selectedBin = '';
  bool _isSortedCorrectly = false;

  Widget _buildInteractiveLessonCard() {
    return Card(
      color: const Color(0xFF0F0F0F),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: const Color(0xFF4A2711).withOpacity(0.4), width: 2),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.delete_sweep_rounded, color: Color(0xFF4A2711), size: 30),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Tema 2: Juego de Reciclaje',
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
              'Selecciona un objeto y arrástralo a su bote de basura correcto:',
              style: GoogleFonts.fredoka(fontSize: 14, color: Colors.white70),
            ),
            const SizedBox(height: 16),
            Center(
              child: Column(
                children: [
                  // Objeto a reciclar
                  DropdownButton<String>(
                    value: _selectedTrash,
                    dropdownColor: const Color(0xFF0F0F0F),
                    style: GoogleFonts.fredoka(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold),
                    items: <String>['Botella de Plástico', 'Periódico Viejo', 'Frasco de Vidrio']
                        .map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      setState(() {
                        _selectedTrash = newValue!;
                        _selectedBin = '';
                        _isSortedCorrectly = false;
                      });
                    },
                  ),
                  const SizedBox(height: 20),
                  // Botes de basura
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _binButton('Plástico (Azul)', const Color(0xFF004F77)),
                      _binButton('Papel (Amarillo)', const Color(0xFF8B6508)),
                      _binButton('Vidrio (Verde)', const Color(0xFF1B5E20)),
                    ],
                  ),
                  const SizedBox(height: 20),
                  if (_selectedBin.isNotEmpty)
                    Text(
                      _isSortedCorrectly
                          ? '¡Correcto! Has reciclado de forma fantástica.'
                          : '¡Intenta de nuevo! Ese no es su bote adecuado.',
                      style: GoogleFonts.fredoka(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        color: _isSortedCorrectly ? Colors.greenAccent : Colors.redAccent,
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

  Widget _binButton(String label, Color color) {
    return InkWell(
      onTap: () {
        setState(() {
          _selectedBin = label;
          // Validar reciclaje correcto
          if (_selectedTrash == 'Botella de Plástico' && label == 'Plástico (Azul)') {
            _isSortedCorrectly = true;
          } else if (_selectedTrash == 'Periódico Viejo' && label == 'Papel (Amarillo)') {
            _isSortedCorrectly = true;
          } else if (_selectedTrash == 'Frasco de Vidrio' && label == 'Vidrio (Verde)') {
            _isSortedCorrectly = true;
          } else {
            _isSortedCorrectly = false;
          }
        });
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: color.withOpacity(0.15),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color, width: 2),
        ),
        child: Text(
          label.split(' ')[0],
          style: GoogleFonts.fredoka(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
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
        border: Border.all(color: const Color(0xFF4A2711), width: 3),
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
                      backgroundColor: const Color(0xFF4A2711),
                    ),
                  );
                } else {
                  Navigator.of(context).pop(true);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4A2711),
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
