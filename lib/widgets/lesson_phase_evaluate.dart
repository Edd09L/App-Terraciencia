import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/lesson_content.dart';

/// Widget de la Fase 3 — Evaluar.
///
/// Diagrama de Mapa Mental interactivo con:
/// - Nodo central con el concepto principal (no editable).
/// - Ramas con [TextField] en blanco donde el alumno escribe.
/// - Diseño visual tipo mind map con [CustomPaint] para las conexiones.
/// - Botón "🚀 Enviar Reto" al completar los campos.
///
/// Diseño DUA: múltiples formas de expresión (escritura libre).
class LessonPhaseEvaluate extends StatefulWidget {
  /// Plantilla del mapa mental con las ramas a completar.
  final MindMapTemplate mindMap;

  /// Color temático del planeta.
  final Color themeColor;

  /// Factor de escala de texto (modo proyección).
  final double textScaleFactor;

  /// Callback cuando se envía el reto.
  /// Devuelve un mapa {label: textoIngresado} con las respuestas del alumno.
  final ValueChanged<Map<String, String>> onSubmitChallenge;

  /// Si el quiz de la Fase 2 ya fue completado.
  final bool quizCompleted;

  const LessonPhaseEvaluate({
    super.key,
    required this.mindMap,
    required this.themeColor,
    this.textScaleFactor = 1.0,
    required this.onSubmitChallenge,
    this.quizCompleted = false,
  });

  @override
  State<LessonPhaseEvaluate> createState() => _LessonPhaseEvaluateState();
}

class _LessonPhaseEvaluateState extends State<LessonPhaseEvaluate>
    with SingleTickerProviderStateMixin {
  /// Controladores de texto para cada rama del mapa mental.
  late List<TextEditingController> _controllers;

  /// Focus nodes para manejar el enfoque de cada campo.
  late List<FocusNode> _focusNodes;

  /// Animación de entrada.
  late AnimationController _entryAnimController;
  late Animation<double> _entryAnim;

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(
      widget.mindMap.branches.length,
      (_) => TextEditingController(),
    );
    _focusNodes = List.generate(
      widget.mindMap.branches.length,
      (_) => FocusNode(),
    );

    _entryAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _entryAnim = CurvedAnimation(
      parent: _entryAnimController,
      curve: Curves.easeOutBack,
    );
    _entryAnimController.forward();
  }

  @override
  void dispose() {
    for (final controller in _controllers) {
      controller.dispose();
    }
    for (final node in _focusNodes) {
      node.dispose();
    }
    _entryAnimController.dispose();
    super.dispose();
  }

  /// Recopila las respuestas del alumno.
  Map<String, String> _collectAnswers() {
    final Map<String, String> answers = {};
    for (int i = 0; i < widget.mindMap.branches.length; i++) {
      answers[widget.mindMap.branches[i].label] = _controllers[i].text.trim();
    }
    return answers;
  }

  /// Verifica si todos los campos tienen texto.
  bool get _allFieldsFilled =>
      _controllers.every((c) => c.text.trim().isNotEmpty);

  void _handleSubmit() {
    if (!_allFieldsFilled) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '✏️ Completa todas las ramas del mapa mental antes de enviar.',
            style: GoogleFonts.fredoka(
                fontWeight: FontWeight.bold, color: Colors.black),
          ),
          backgroundColor: Colors.orangeAccent,
          duration: const Duration(seconds: 3),
        ),
      );
      return;
    }

    if (!widget.quizCompleted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '📝 Primero debes completar el quiz de la Fase 2 (Practicar).',
            style: GoogleFonts.fredoka(
                fontWeight: FontWeight.bold, color: Colors.black),
          ),
          backgroundColor: Colors.orangeAccent,
          duration: const Duration(seconds: 3),
        ),
      );
      return;
    }

    widget.onSubmitChallenge(_collectAnswers());
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _entryAnim,
      builder: (context, child) {
        return Opacity(
          opacity: _entryAnim.value.clamp(0.0, 1.0),
          child: Transform.scale(
            scale: 0.8 + (_entryAnim.value * 0.2),
            child: _buildContent(),
          ),
        );
      },
    );
  }

  Widget _buildContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // ── Instrucciones ────────────────────────────────────────────────
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: widget.themeColor.withOpacity(0.08),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: widget.themeColor.withOpacity(0.2),
              ),
            ),
            child: Row(
              children: [
                Icon(Icons.edit_note_rounded,
                    color: widget.themeColor, size: 28),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Completa el mapa mental escribiendo en cada rama. '
                    'Usa tus propias palabras para demostrar lo que aprendiste.',
                    style: GoogleFonts.fredoka(
                      color: Colors.white70,
                      fontSize: 14 * widget.textScaleFactor,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // ── Nodo Central ──────────────────────────────────────────────
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 18),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  widget.themeColor.withOpacity(0.3),
                  widget.themeColor.withOpacity(0.15),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: widget.themeColor.withOpacity(0.6),
                width: 3,
              ),
              boxShadow: [
                BoxShadow(
                  color: widget.themeColor.withOpacity(0.2),
                  blurRadius: 20,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Column(
              children: [
                Icon(Icons.hub_rounded, color: widget.themeColor, size: 32),
                const SizedBox(height: 8),
                Text(
                  widget.mindMap.centralNode,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.fredoka(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: 20 * widget.textScaleFactor,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),

          // ── Línea conectora central ────────────────────────────────────
          Container(
            width: 3,
            height: 24,
            decoration: BoxDecoration(
              color: widget.themeColor.withOpacity(0.4),
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // ── Ramas del Mapa Mental ─────────────────────────────────────
          ...List.generate(widget.mindMap.branches.length, (index) {
            final branch = widget.mindMap.branches[index];
            // Alternar alineación izquierda/derecha para efecto visual
            final bool isLeft = index % 2 == 0;

            return Column(
              children: [
                // Línea conectora
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (!isLeft) const Spacer(),
                    Container(
                      width: isLeft ? 80 : 3,
                      height: isLeft ? 3 : 16,
                      decoration: BoxDecoration(
                        color: widget.themeColor.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    if (isLeft) const Spacer(),
                  ],
                ),

                // Tarjeta de la rama
                Container(
                  width: double.infinity,
                  margin: EdgeInsets.only(
                    left: isLeft ? 0 : 40,
                    right: isLeft ? 40 : 0,
                    bottom: 12,
                  ),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0F0F0F),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: widget.themeColor.withOpacity(0.25),
                      width: 1.5,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Etiqueta de la rama
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: widget.themeColor.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.account_tree_rounded,
                              color: widget.themeColor,
                              size: 16,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              branch.label,
                              style: GoogleFonts.fredoka(
                                color: widget.themeColor,
                                fontWeight: FontWeight.bold,
                                fontSize: 14 * widget.textScaleFactor,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Campo de texto editable
                      TextField(
                        controller: _controllers[index],
                        focusNode: _focusNodes[index],
                        maxLines: 2,
                        style: GoogleFonts.fredoka(
                          color: Colors.white,
                          fontSize: 15 * widget.textScaleFactor,
                        ),
                        decoration: InputDecoration(
                          hintText: branch.hintText,
                          hintStyle: GoogleFonts.fredoka(
                            color: Colors.white30,
                            fontSize: 14 * widget.textScaleFactor,
                          ),
                          filled: true,
                          fillColor: Colors.white.withOpacity(0.04),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: BorderSide(
                              color: widget.themeColor.withOpacity(0.2),
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: BorderSide(
                              color: widget.themeColor.withOpacity(0.15),
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: BorderSide(
                              color: widget.themeColor,
                              width: 2,
                            ),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 14),
                        ),
                        onChanged: (_) => setState(() {}),
                      ),
                    ],
                  ),
                ),
              ],
            );
          }),

          const SizedBox(height: 24),

          // ── Botón Enviar Reto ──────────────────────────────────────────
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton.icon(
              onPressed: _handleSubmit,
              style: ElevatedButton.styleFrom(
                backgroundColor: _allFieldsFilled && widget.quizCompleted
                    ? widget.themeColor
                    : Colors.white12,
                foregroundColor: _allFieldsFilled && widget.quizCompleted
                    ? Colors.black
                    : Colors.white38,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
                elevation: _allFieldsFilled ? 4 : 0,
              ),
              icon: Icon(
                Icons.rocket_launch_rounded,
                size: 24,
                color: _allFieldsFilled && widget.quizCompleted
                    ? Colors.black
                    : Colors.white38,
              ),
              label: Text(
                '🚀 ENVIAR RETO',
                style: GoogleFonts.fredoka(
                  fontWeight: FontWeight.w900,
                  fontSize: 18 * widget.textScaleFactor,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

/// Helper: AnimatedBuilder compatible con AnimationController.
class AnimatedBuilder extends AnimatedWidget {
  final Widget Function(BuildContext, Widget?) builder;

  const AnimatedBuilder({
    super.key,
    required Animation<double> animation,
    required this.builder,
  }) : super(listenable: animation);

  @override
  Widget build(BuildContext context) {
    return builder(context, null);
  }
}
