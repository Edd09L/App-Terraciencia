import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// SECCIÓN DE DISEÑO DEL PLANETA (Glow, zoom y esfera)
class KinetosScreen extends StatefulWidget {
  final String studentName;

  const KinetosScreen({super.key, required this.studentName});

  @override
  State<KinetosScreen> createState() => _KinetosScreenState();
}

class _KinetosScreenState extends State<KinetosScreen> with TickerProviderStateMixin {
  double _zoomLevel = 1.0;
  bool _isBadgeUnlocked = false;

  // Lógica de caída libre interactiva (Gravedad de Galileo)
  late AnimationController _dropController;
  late Animation<double> _dropAnimation;

  @override
  void initState() {
    super.initState();
    _dropController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _dropAnimation = Tween<double>(begin: 0.0, end: 120.0).animate(
      CurvedAnimation(parent: _dropController, curve: Curves.easeInQuad),
    );
  }

  @override
  void dispose() {
    _dropController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF000000),
      appBar: AppBar(
        title: Text(
          'Mundo Kinetos',
          style: GoogleFonts.fredoka(fontWeight: FontWeight.bold, fontSize: 24),
        ),
        backgroundColor: const Color(0xFF004F77).withOpacity(0.2),
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
                            color: const Color(0xFF9E2A2B).withOpacity(0.5),
                            blurRadius: 30,
                            spreadRadius: 4,
                          )
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(75),
                        child: Image.asset(
                          'assets/images/Kinetos.png',
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return const Center(
                              child: Icon(
                                Icons.speed_rounded,
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
          'Lecciones de Kinetos (Física)',
          style: GoogleFonts.fredoka(
            fontSize: 22,
            fontWeight: FontWeight.w800,
            color: const Color(0xFFB3E5FC),
          ),
        ),
        const SizedBox(height: 16),

        // TEMA 1 - El sonido viaja (Contenido y lógica adaptativa)
        _buildLessonCard(
          title: 'Tema 1: ¿Cómo viaja el Sonido?',
          icon: Icons.volume_up_rounded,
          color: const Color(0xFF004F77),
          content: [
            'El sonido no viaja solo, lo hace en ondas invisibles por el aire.',
            'Cuando hablas, tus cuerdas vocales vibran y empujan el aire.',
            'En el espacio exterior no se puede oír nada porque no hay aire.',
          ],
        ),
        const SizedBox(height: 16),

        // TEMA 2 - Caída libre y Gravedad (Contenido y lógica adaptativa)
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

  Widget _buildInteractiveLessonCard() {
    return Card(
      color: const Color(0xFF0F0F0F),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: const Color(0xFF004F77).withOpacity(0.4), width: 2),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.vertical_align_bottom_rounded, color: Color(0xFF004F77), size: 30),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Tema 2: Experimento de Gravedad',
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
              'En el vacío (sin aire), una yunque pesada y una pluma caen EXACTAMENTE al mismo tiempo. ¡Pruébalo!',
              style: GoogleFonts.fredoka(fontSize: 14, color: Colors.white70, height: 1.45),
            ),
            const SizedBox(height: 16),
            Center(
              child: Column(
                children: [
                  ElevatedButton(
                    onPressed: () {
                      _dropController.forward(from: 0.0);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF004F77),
                      foregroundColor: Colors.white,
                    ),
                    child: Text(
                      '¡SOLTAR OBJETOS!',
                      style: GoogleFonts.fredoka(fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    height: 170,
                    width: 200,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.04),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.white12),
                    ),
                    child: AnimatedBuilder(
                      animation: _dropAnimation,
                      builder: (context, _) {
                        return Stack(
                          children: [
                            // Yunque
                            Positioned(
                              top: _dropAnimation.value,
                              left: 40,
                              child: const Icon(Icons.architecture_rounded, color: Colors.grey, size: 32),
                            ),
                            // Pluma
                            Positioned(
                              top: _dropAnimation.value,
                              right: 40,
                              child: const Icon(Icons.spa_rounded, color: Colors.lightBlueAccent, size: 32),
                            ),
                            // Suelo
                            const Positioned(
                              bottom: 0,
                              left: 0,
                              right: 0,
                              child: Divider(color: Colors.white54, thickness: 3, height: 1),
                            )
                          ],
                        );
                      },
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
        border: Border.all(color: const Color(0xFF004F77), width: 3),
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
                      backgroundColor: const Color(0xFF004F77),
                    ),
                  );
                } else {
                  Navigator.of(context).pop(true);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF004F77),
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
