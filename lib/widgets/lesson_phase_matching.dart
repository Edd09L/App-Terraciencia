import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/lesson_content.dart';

/// Widget para la actividad de relacionar / emparejar tarjetas en Fase 2 (Practicar).
///
/// Permite al estudiante conectar conceptos con sus definiciones tocando una tarjeta
/// de la izquierda y luego una de la derecha.
/// Brinda retroalimentación visual inmediata con colores y animaciones.
class LessonPhaseMatching extends StatefulWidget {
  /// Lista de pares a relacionar.
  final List<MatchingPair> pairs;

  /// Puntos totales a otorgar (por defecto 30).
  final int totalPoints;

  /// Color temático del planeta.
  final Color themeColor;

  /// Factor de escala de texto para modo proyección.
  final double textScaleFactor;

  /// Callback cuando se completan todos los emparejamientos.
  final ValueChanged<double> onCompleted;

  const LessonPhaseMatching({
    super.key,
    required this.pairs,
    this.totalPoints = 30,
    required this.themeColor,
    this.textScaleFactor = 1.0,
    required this.onCompleted,
  });

  @override
  State<LessonPhaseMatching> createState() => _LessonPhaseMatchingState();
}

class _LessonPhaseMatchingState extends State<LessonPhaseMatching> {
  late List<String> _leftItems;
  late List<String> _rightItems;

  String? _selectedLeft;
  String? _selectedRight;

  /// Mapa de emparejamientos correctos ya realizados {left: right}
  final Map<String, String> _matchedPairs = {};

  /// Feedback temporal de error
  String? _errorLeft;
  String? _errorRight;

  @override
  void initState() {
    super.initState();
    _leftItems = widget.pairs.map((p) => p.left).toList()..shuffle();
    _rightItems = widget.pairs.map((p) => p.right).toList()..shuffle();
  }

  void _selectLeft(String item) {
    if (_matchedPairs.containsKey(item)) return;
    setState(() {
      _selectedLeft = item;
      _errorLeft = null;
      _errorRight = null;
      if (_selectedRight != null) {
        _checkMatch();
      }
    });
  }

  void _selectRight(String item) {
    if (_matchedPairs.containsValue(item)) return;
    setState(() {
      _selectedRight = item;
      _errorLeft = null;
      _errorRight = null;
      if (_selectedLeft != null) {
        _checkMatch();
      }
    });
  }

  void _checkMatch() {
    final left = _selectedLeft!;
    final right = _selectedRight!;

    // Verificar si es un par correcto
    final isCorrect = widget.pairs.any((p) => p.left == left && p.right == right);

    if (isCorrect) {
      setState(() {
        _matchedPairs[left] = right;
        _selectedLeft = null;
        _selectedRight = null;
      });

      // Verificar si ya se completaron todos
      if (_matchedPairs.length == widget.pairs.length) {
        Future.delayed(const Duration(milliseconds: 600), () {
          if (mounted) {
            widget.onCompleted(widget.totalPoints.toDouble());
          }
        });
      }
    } else {
      setState(() {
        _errorLeft = left;
        _errorRight = right;
        _selectedLeft = null;
        _selectedRight = null;
      });

      Future.delayed(const Duration(milliseconds: 900), () {
        if (mounted) {
          setState(() {
            _errorLeft = null;
            _errorRight = null;
          });
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final int matchedCount = _matchedPairs.length;
    final int totalCount = widget.pairs.length;
    final double progress = totalCount > 0 ? matchedCount / totalCount : 0.0;
    final double currentScore = totalCount > 0
        ? (matchedCount / totalCount) * widget.totalPoints
        : 0.0;

    return Column(
      children: [
        // ── Cabecera de progreso ──────────────────────────────────────────
        Container(
          margin: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF0F0F0F),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: widget.themeColor.withOpacity(0.3),
              width: 1.5,
            ),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(Icons.extension_rounded,
                          color: widget.themeColor, size: 22),
                      const SizedBox(width: 8),
                      Text(
                        'Relaciona las Tarjetas',
                        style: GoogleFonts.fredoka(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16 * widget.textScaleFactor,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: widget.themeColor.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: widget.themeColor.withOpacity(0.4),
                      ),
                    ),
                    child: Text(
                      '${currentScore.toInt()} / ${widget.totalPoints} pts',
                      style: GoogleFonts.fredoka(
                        color: widget.themeColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 14 * widget.textScaleFactor,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: progress,
                  minHeight: 8,
                  backgroundColor: Colors.white10,
                  valueColor: AlwaysStoppedAnimation<Color>(widget.themeColor),
                ),
              ),
              const SizedBox(height: 6),
              Align(
                alignment: Alignment.centerRight,
                child: Text(
                  '$matchedCount de $totalCount pares emparejados',
                  style: GoogleFonts.fredoka(
                    color: Colors.white38,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
        ),

        // ── Instrucción breve ─────────────────────────────────────────────
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: Text(
            'Toca un concepto de la izquierda y luego su significado de la derecha:',
            textAlign: TextAlign.center,
            style: GoogleFonts.fredoka(
              color: Colors.white70,
              fontSize: 13 * widget.textScaleFactor,
            ),
          ),
        ),

        // ── Columnas de Tarjetas ──────────────────────────────────────────
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Columna izquierda (Conceptos)
                Expanded(
                  child: ListView.builder(
                    itemCount: _leftItems.length,
                    itemBuilder: (context, index) {
                      final item = _leftItems[index];
                      final isMatched = _matchedPairs.containsKey(item);
                      final isSelected = _selectedLeft == item;
                      final isError = _errorLeft == item;

                      return _buildCard(
                        text: item,
                        isLeft: true,
                        isMatched: isMatched,
                        isSelected: isSelected,
                        isError: isError,
                        onTap: () => _selectLeft(item),
                      );
                    },
                  ),
                ),
                const SizedBox(width: 12),
                // Columna derecha (Definiciones)
                Expanded(
                  child: ListView.builder(
                    itemCount: _rightItems.length,
                    itemBuilder: (context, index) {
                      final item = _rightItems[index];
                      final isMatched = _matchedPairs.containsValue(item);
                      final isSelected = _selectedRight == item;
                      final isError = _errorRight == item;

                      return _buildCard(
                        text: item,
                        isLeft: false,
                        isMatched: isMatched,
                        isSelected: isSelected,
                        isError: isError,
                        onTap: () => _selectRight(item),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCard({
    required String text,
    required bool isLeft,
    required bool isMatched,
    required bool isSelected,
    required bool isError,
    required VoidCallback onTap,
  }) {
    Color cardColor = const Color(0xFF0F0F0F);
    Color borderColor = widget.themeColor.withOpacity(0.2);
    Color textColor = Colors.white;

    if (isMatched) {
      cardColor = Colors.greenAccent.withOpacity(0.12);
      borderColor = Colors.greenAccent;
      textColor = Colors.greenAccent;
    } else if (isError) {
      cardColor = Colors.redAccent.withOpacity(0.15);
      borderColor = Colors.redAccent;
      textColor = Colors.redAccent;
    } else if (isSelected) {
      cardColor = widget.themeColor.withOpacity(0.25);
      borderColor = widget.themeColor;
      textColor = Colors.white;
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: InkWell(
        onTap: isMatched ? null : onTap,
        borderRadius: BorderRadius.circular(16),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: borderColor,
              width: isSelected || isMatched || isError ? 2.5 : 1.5,
            ),
            boxShadow: isMatched || isSelected
                ? [
                    BoxShadow(
                      color: (isMatched ? Colors.greenAccent : widget.themeColor)
                          .withOpacity(0.2),
                      blurRadius: 10,
                      spreadRadius: 1,
                    )
                  ]
                : [],
          ),
          child: Row(
            children: [
              if (isMatched) ...[
                const Icon(Icons.check_circle_rounded,
                    color: Colors.greenAccent, size: 20),
                const SizedBox(width: 8),
              ] else if (isError) ...[
                const Icon(Icons.cancel_rounded,
                    color: Colors.redAccent, size: 20),
                const SizedBox(width: 8),
              ],
              Expanded(
                child: Text(
                  text,
                  style: GoogleFonts.fredoka(
                    fontSize: (isLeft ? 15 : 13) * widget.textScaleFactor,
                    fontWeight: isLeft ? FontWeight.bold : FontWeight.w500,
                    color: textColor,
                    height: 1.3,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
