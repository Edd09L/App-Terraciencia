import 'package:flutter/material.dart';
import '../models/planet_data.dart';
import '../models/app_colors.dart';

/// Representación visual tridimensional e interactiva de un planeta.
///
/// Características de accesibilidad:
/// - Área de interacción grande (120x120px) para facilitar clics y gestos táctiles.
/// - Foco de teclado completo, esencial para usuarios con discapacidades motoras/cognitivas.
/// - Integración con el lector de pantalla mediante `Semantics`.
/// - Escala y resplandor (glow) al pasar el cursor o enfocar con el teclado.
class PlanetSphere extends StatefulWidget {
  final PlanetData planet;
  final ValueChanged<bool> onHoverChanged; // Notifica si está en hover/foco
  final VoidCallback onTap;                // Acción al hacer clic
  final bool isDimmed;                     // Atenuado si otro planeta tiene el foco

  const PlanetSphere({
    super.key,
    required this.planet,
    required this.onHoverChanged,
    required this.onTap,
    this.isDimmed = false,
  });

  @override
  State<PlanetSphere> createState() => _PlanetSphereState();
}

class _PlanetSphereState extends State<PlanetSphere> with SingleTickerProviderStateMixin {
  bool _isHovered = false;
  bool _isFocused = false;
  late AnimationController _pulseController;

  bool get _isActive => _isHovered || _isFocused;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  /// Devuelve el color de hover asignado a cada planeta según la paleta oficial institucional.
  Color _getHoverColor(PlanetData planet) {
    return AppColors.forPlanet(planet.name);
  }

  String _getPlanetImagePath(PlanetData planet) {
    final lower = planet.name
        .toLowerCase()
        .replaceAll('é', 'e')
        .replaceAll('í', 'i')
        .replaceAll('ó', 'o')
        .replaceAll('-', '_')
        .trim();

    if (lower.contains('prisma')) return 'assets/images/Prisma.png';
    if (lower.contains('vitalia') || lower.contains('vit')) return 'assets/images/Vitalia.png';
    if (lower.contains('simbios') || lower.contains('sim')) return 'assets/images/Simbios.png';
    if (lower.contains('titan') || lower.contains('atomis') || lower.contains('átomis')) return 'assets/images/Titan-Q.png';
    if (lower.contains('ciberon') || lower.contains('cib')) return 'assets/images/Ciberon.png';
    if (lower.contains('kineto')) return 'assets/images/Kinetos.png';
    if (lower.contains('noosferis') || lower.contains('noo')) return 'assets/images/Noosferis.png';
    return planet.assetPath;
  }

  @override
  Widget build(BuildContext context) {
    final planet = widget.planet;
    
    // Determinar la opacidad actual del planeta
    // Si está atenuado por el foco de otro, baja a 0.5. Si está bloqueado, baja a 0.7.
    double currentOpacity = 1.0;
    if (widget.isDimmed) {
      currentOpacity = 0.5;
    } else if (!planet.isUnlocked) {
      currentOpacity = 0.7;
    }

    final double scale = _isActive ? 1.12 : 1.0;

    return Semantics(
      label: planet.isUnlocked
          ? 'Planeta ${planet.name}. ${planet.description}. Presiona dos veces para explorar.'
          : 'Planeta ${planet.name}. Bloqueado. Completa los planetas anteriores para explorar.',
      button: planet.isUnlocked,
      enabled: planet.isUnlocked,
      focused: _isFocused,
      child: FocusableActionDetector(
        onShowHoverHighlight: (value) {
          setState(() {
            _isHovered = value;
          });
          widget.onHoverChanged(value);
        },
        onShowFocusHighlight: (value) {
          setState(() {
            _isFocused = value;
          });
          widget.onHoverChanged(value);
        },
        actions: {
          ActivateIntent: CallbackAction<ActivateIntent>(
            onInvoke: (intent) => widget.onTap(),
          ),
        },
        child: GestureDetector(
          onTap: widget.onTap,
          child: MouseRegion(
            cursor: planet.isUnlocked ? SystemMouseCursors.click : SystemMouseCursors.forbidden,
            child: AnimatedBuilder(
              animation: _pulseController,
              builder: (context, child) {
                final double pulseValue = _pulseController.value;
                
                final List<BoxShadow> shadows = [];
                if (planet.isUnlocked) {
                  final Color hoverColor = _getHoverColor(planet);
                  if (planet.id == 7) {
                    // Resplandor animado de Noosféris
                    shadows.add(
                      BoxShadow(
                        color: (_isActive ? hoverColor : planet.color)
                            .withOpacity(_isActive ? 0.9 : 0.65),
                        blurRadius: _isActive
                            ? (50.0 + pulseValue * 30.0)
                            : (30.0 + pulseValue * 15.0),
                        spreadRadius: _isActive
                            ? (10.0 + pulseValue * 6.0)
                            : (4.0 + pulseValue * 4.0),
                      ),
                    );
                  } else {
                    // Planetas orbitales: blanco tenue en reposo, color neón en hover
                    shadows.add(
                      BoxShadow(
                        color: _isActive
                            ? hoverColor.withOpacity(0.75)  // Neón específico del planeta al hacer hover
                            : Colors.white10,               // Blanco tenue por defecto (sin hover)
                        blurRadius: _isActive ? 42.0 : 10.0,
                        spreadRadius: _isActive ? 8.0 : 2.0,
                      ),
                    );
                  }
                } else {
                  shadows.add(
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.15),
                      blurRadius: 10.0,
                    ),
                  );
                }

                final Decoration sphereDecoration = BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: shadows,
                );

                return AnimatedOpacity(
                  duration: const Duration(milliseconds: 300),
                  opacity: currentOpacity,
                  child: AnimatedScale(
                    scale: scale,
                    duration: const Duration(milliseconds: 250),
                    curve: Curves.easeOutBack,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // 1. Esfera del Planeta
                        Stack(
                          alignment: Alignment.center,
                          children: [
                            Center(
                              child: Container(
                                width: 210,
                                height: 210,
                                decoration: sphereDecoration,
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(105),
                                  child: Image.asset(
                                    _getPlanetImagePath(planet),
                                    fit: BoxFit.cover,
                                    color: planet.isUnlocked ? null : Colors.grey.shade600,
                                    colorBlendMode: planet.isUnlocked ? null : BlendMode.modulate,
                                    errorBuilder: (context, error, stackTrace) {
                                      return Image.asset(
                                        planet.assetPath,
                                        fit: BoxFit.cover,
                                        color: planet.isUnlocked ? null : Colors.grey.shade600,
                                        colorBlendMode: planet.isUnlocked ? null : BlendMode.modulate,
                                        errorBuilder: (c, e, s) => Center(
                                          child: Icon(
                                            Icons.broken_image,
                                            size: 70,
                                            color: planet.isUnlocked ? Colors.yellow : Colors.grey,
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ),
                            ),
                            // Icono temático central en el planeta (si está bloqueado, candado)
                            if (!planet.isUnlocked)
                              const Center(
                                child: Icon(
                                  Icons.lock_rounded,
                                  size: 70,
                                  color: Color(0x80FFFFFF),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        
                        // 2. Nombre del Planeta
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: _isActive 
                                ? planet.color.withOpacity(0.2) 
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(12),
                            border: _isFocused
                                ? Border.all(color: Colors.white.withOpacity(0.8), width: 1.5)
                                : Border.all(color: Colors.transparent, width: 1.5),
                          ),
                          child: Text(
                            planet.name,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.5,
                              color: planet.isUnlocked
                                  ? (_isActive ? Colors.white : const Color(0xFFE0E0E0))
                                  : Colors.grey.shade500,
                              shadows: planet.isUnlocked
                                  ? [
                                      BoxShadow(
                                        color: planet.color.withOpacity(0.7),
                                        blurRadius: 8,
                                      ),
                                    ]
                                  : [],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
