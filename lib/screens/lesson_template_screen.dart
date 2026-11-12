import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../models/app_colors.dart';
import '../models/topic.dart';
import '../models/lesson_content.dart';
import '../providers/progress_provider.dart';
import '../providers/user_role_provider.dart';
import '../services/ai_evaluation_service.dart';
import '../data/sample_lesson_content.dart';
import '../widgets/lesson_phase_learn.dart';
import '../widgets/lesson_phase_practice.dart';
import '../widgets/lesson_phase_matching.dart';
import '../widgets/lesson_phase_evaluate.dart';
import '../widgets/achievement_overlay.dart';
import '../widgets/feedback_bottom_sheet.dart';

/// Pantalla plantilla reusable para las lecciones de Terraciencia.
///
/// Estructura de 3 fases DUA (Diseño Universal para el Aprendizaje):
///   1. Aprender — diapositivas + glosario + modelo 3D
///   2. Practicar — micro-quiz interactivo
///   3. Evaluar  — mapa mental + envío de reto
///
/// Se alimenta con un [Topic] (metadata) y un [LessonContent] (contenido
/// inyectable). Los 40 temas pueden reutilizar este mismo molde pasando
/// datos diferentes.
///
/// Incluye:
/// - AppBar con insignia, progreso y modo proyección (docente).
/// - TabBar/Stepper para navegación por fases.
/// - Integración con [AIEvaluationService] y [ProgressProvider].
class LessonTemplateScreen extends StatefulWidget {
  /// Metadata del tema (título, id, planeta, etc.).
  final Topic topic;

  /// Contenido inyectable de la lección. Si es null, se busca en
  /// [lessonContentDatabase] por topicId.
  final LessonContent? content;

  const LessonTemplateScreen({
    super.key,
    required this.topic,
    this.content,
  });

  @override
  State<LessonTemplateScreen> createState() => _LessonTemplateScreenState();
}

class _LessonTemplateScreenState extends State<LessonTemplateScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;

  /// Contenido efectivo de la lección (inyectado o del database).
  late LessonContent _lessonContent;

  /// Puntaje del quiz de la Fase 2.
  double _quizScore = 0.0;

  /// Si el quiz fue completado.
  bool _quizCompleted = false;

  /// Si se está mostrando el overlay de logro.
  bool _showAchievement = false;

  /// Si se está evaluando (loading).
  bool _isEvaluating = false;

  /// Color temático del planeta.
  late Color _planetColor;

  /// Ícono del planeta.
  late IconData _planetIcon;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _planetColor = _getPlanetColor(widget.topic.planetId);
    _planetIcon = _getPlanetIcon(widget.topic.planetId);

    // Resolver contenido de la lección
    if (widget.content != null) {
      _lessonContent = widget.content!;
    } else if (lessonContentDatabase.containsKey(widget.topic.id)) {
      _lessonContent = lessonContentDatabase[widget.topic.id]!;
    } else {
      // Placeholder vacío para temas sin contenido aún
      _lessonContent = LessonContent(
        topicId: widget.topic.id,
        slides: [
          LessonSlide(
            title: widget.topic.title,
            description: widget.topic.description,
          ),
        ],
        quizQuestions: const [],
        mindMap: const MindMapTemplate(
          centralNode: 'Próximamente',
          branches: [],
        ),
      );
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
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

  /// Maneja la completación del quiz (Fase 2).
  void _onQuizCompleted(double score) {
    setState(() {
      _quizScore = score;
      _quizCompleted = true;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '✅ Quiz completado: ${score.toInt()} pts. Ahora completa el Mapa Mental (Fase 3).',
          style: GoogleFonts.fredoka(
              fontWeight: FontWeight.bold, color: Colors.black),
        ),
        backgroundColor: _planetColor,
        duration: const Duration(seconds: 3),
      ),
    );

    // Auto-navegar a Fase 3
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        _tabController.animateTo(2);
      }
    });
  }

  /// Maneja el envío del reto (Fase 3).
  Future<void> _onSubmitChallenge(Map<String, String> answers) async {
    setState(() => _isEvaluating = true);

    // Construir mapa de respuestas esperadas
    final Map<String, String> expectedAnswers = {};
    for (final branch in _lessonContent.mindMap.branches) {
      expectedAnswers[branch.label] = branch.expectedAnswer;
    }

    // Evaluar con el servicio de IA
    final result = await AIEvaluationService.instance.evaluate(
      quizScore: _quizScore,
      mindMapAnswers: answers,
      expectedAnswers: expectedAnswers,
    );

    setState(() => _isEvaluating = false);

    if (!mounted) return;

    if (result.passed) {
      // ── Aprobado: desbloquear insignia + animación de logro ──────────
      final provider = context.read<ProgressProvider>();
      provider.setScore(widget.topic.id, result.totalScore);

      setState(() => _showAchievement = true);
    } else {
      // ── No aprobado: mostrar feedback formativo ─────────────────────
      FeedbackBottomSheet.show(
        context: context,
        result: result,
        themeColor: _planetColor,
        onRetry: _handleRetry,
      );
    }
  }

  /// Reinicia las Fases 2 y 3 para un nuevo intento.
  void _handleRetry() {
    setState(() {
      _quizScore = 0.0;
      _quizCompleted = false;
    });
    _tabController.animateTo(1); // Volver a Fase 2
  }

  @override
  Widget build(BuildContext context) {
    final roleProvider = context.watch<UserRoleProvider>();
    final progressProvider = context.watch<ProgressProvider>();
    final double currentScore = progressProvider.getScore(widget.topic.id);
    final bool isUnlocked = progressProvider.isUnlocked(widget.topic.id);
    final double textScale = roleProvider.textScaleFactor;

    return Scaffold(
      backgroundColor: const Color(0xFF000000),
      appBar: _buildAppBar(roleProvider, currentScore, isUnlocked, textScale),
      body: Stack(
        children: [
          Column(
            children: [
              // ── TabBar de Fases ──────────────────────────────────────────
              _buildPhaseTabBar(textScale),

              // ── Contenido de Fases ───────────────────────────────────────
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  physics: const NeverScrollableScrollPhysics(),
                  children: [
                    // Fase 1: Aprender
                    LessonPhaseLearn(
                      slides: _lessonContent.slides,
                      glossary: _lessonContent.glossary,
                      model3dPath: _lessonContent.model3dPath,
                      themeColor: _planetColor,
                      textScaleFactor: textScale,
                    ),

                    // Fase 2: Practicar (Soporta Micro-Quiz o Actividad de Relacionar)
                    if (_lessonContent.matchingPairs != null &&
                        _lessonContent.matchingPairs!.isNotEmpty)
                      LessonPhaseMatching(
                        pairs: _lessonContent.matchingPairs!,
                        totalPoints: _lessonContent.matchingPoints,
                        themeColor: _planetColor,
                        textScaleFactor: textScale,
                        onCompleted: _onQuizCompleted,
                      )
                    else if (_lessonContent.quizQuestions.isNotEmpty)
                      LessonPhasePractice(
                        questions: _lessonContent.quizQuestions,
                        themeColor: _planetColor,
                        textScaleFactor: textScale,
                        onQuizCompleted: _onQuizCompleted,
                      )
                    else
                      _buildEmptyPhase('Práctica', 'Próximamente', textScale),

                    // Fase 3: Evaluar
                    _lessonContent.mindMap.branches.isEmpty
                        ? _buildEmptyPhase(
                            'Mapa Mental', 'Próximamente', textScale)
                        : LessonPhaseEvaluate(
                            mindMap: _lessonContent.mindMap,
                            themeColor: _planetColor,
                            textScaleFactor: textScale,
                            quizCompleted: _quizCompleted,
                            onSubmitChallenge: _onSubmitChallenge,
                          ),
                  ],
                ),
              ),
            ],
          ),

          // ── Loading de evaluación ──────────────────────────────────────
          if (_isEvaluating)
            Container(
              color: Colors.black.withValues(alpha: 0.7),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(color: _planetColor),
                    const SizedBox(height: 20),
                    Text(
                      'Evaluando tu trabajo...',
                      style: GoogleFonts.fredoka(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'El asistente de IA está revisando tus respuestas',
                      style: GoogleFonts.fredoka(
                        color: Colors.white54,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ),

          // ── Overlay de Logro ──────────────────────────────────────────
          if (_showAchievement)
            AchievementOverlay(
              score: progressProvider.getScore(widget.topic.id),
              themeColor: _planetColor,
              topicTitle: widget.topic.title,
              onDismiss: () {
                setState(() => _showAchievement = false);
                Navigator.of(context).pop(true);
              },
            ),
        ],
      ),
    );
  }

  /// Construye el AppBar con insignia, progreso y modo proyección.
  PreferredSizeWidget _buildAppBar(
    UserRoleProvider roleProvider,
    double currentScore,
    bool isUnlocked,
    double textScale,
  ) {
    return AppBar(
      backgroundColor: _planetColor.withValues(alpha: 0.15),
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_rounded),
        onPressed: () => Navigator.of(context).pop(),
        tooltip: 'Volver',
      ),
      title: Row(
        children: [
          // Insignia/Ícono del planeta o SVG
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: isUnlocked
                  ? _planetColor.withValues(alpha: 0.2)
                  : Colors.white.withValues(alpha: 0.05),
              shape: BoxShape.circle,
              border: Border.all(
                color: isUnlocked ? _planetColor : Colors.white24,
                width: 2,
              ),
            ),
            child: widget.topic.badgeAssetPath != null &&
                    widget.topic.badgeAssetPath!.endsWith('.svg')
                ? SvgPicture.asset(
                    widget.topic.badgeAssetPath!,
                    width: 20,
                    height: 20,
                    colorFilter: ColorFilter.mode(
                      isUnlocked ? _planetColor : Colors.white38,
                      BlendMode.srcIn,
                    ),
                    placeholderBuilder: (context) => Icon(
                      isUnlocked ? _planetIcon : Icons.lock_outline_rounded,
                      color: isUnlocked ? _planetColor : Colors.white38,
                      size: 20,
                    ),
                  )
                : Icon(
                    isUnlocked ? _planetIcon : Icons.lock_outline_rounded,
                    color: isUnlocked ? _planetColor : Colors.white38,
                    size: 20,
                  ),
          ),
          const SizedBox(width: 10),
          // Título del tema
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.topic.title,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.fredoka(
                    fontWeight: FontWeight.bold,
                    fontSize: 16 * textScale,
                    color: Colors.white,
                  ),
                ),
                Text(
                  widget.topic.id,
                  style: GoogleFonts.fredoka(
                    fontSize: 11,
                    color: _planetColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(14),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(7),
            child: LinearProgressIndicator(
              value: currentScore / 100.0,
              minHeight: 8,
              backgroundColor: Colors.white10,
              valueColor: AlwaysStoppedAnimation<Color>(
                isUnlocked ? Colors.greenAccent : _planetColor,
              ),
            ),
          ),
        ),
      ),
      actions: [
        // Indicador de puntos
        Container(
          margin: const EdgeInsets.only(right: 4),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: _planetColor.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            '${currentScore.toInt()} pts',
            style: GoogleFonts.fredoka(
              color: _planetColor,
              fontWeight: FontWeight.bold,
              fontSize: 13,
            ),
          ),
        ),

        // Botón Modo Proyección (solo para docentes)
        if (roleProvider.isDocente)
          IconButton(
            icon: Icon(
              roleProvider.isProjectionMode
                  ? Icons.cast_connected_rounded
                  : Icons.cast_rounded,
              color: roleProvider.isProjectionMode
                  ? Colors.amber
                  : Colors.white60,
            ),
            tooltip: roleProvider.isProjectionMode
                ? 'Desactivar Modo Proyección'
                : 'Activar Modo Proyección',
            onPressed: () => roleProvider.toggleProjectionMode(),
          ),
      ],
    );
  }

  /// Construye la barra de navegación por fases (TabBar).
  Widget _buildPhaseTabBar(double textScale) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF0F0F0F),
        border: Border(
          bottom: BorderSide(
            color: _planetColor.withValues(alpha: 0.15),
            width: 1,
          ),
        ),
      ),
      child: TabBar(
        controller: _tabController,
        indicatorColor: _planetColor,
        indicatorWeight: 3,
        labelColor: _planetColor,
        unselectedLabelColor: Colors.white38,
        labelStyle: GoogleFonts.fredoka(
          fontWeight: FontWeight.bold,
          fontSize: 13 * textScale,
        ),
        unselectedLabelStyle: GoogleFonts.fredoka(
          fontWeight: FontWeight.w600,
          fontSize: 13 * textScale,
        ),
        tabs: [
          Tab(
            icon: Icon(Icons.auto_stories_rounded, size: 22 * textScale),
            text: 'Aprender',
          ),
          Tab(
            icon: Stack(
              clipBehavior: Clip.none,
              children: [
                Icon(Icons.quiz_rounded, size: 22 * textScale),
                if (_quizCompleted)
                  Positioned(
                    right: -4,
                    top: -4,
                    child: Container(
                      width: 12,
                      height: 12,
                      decoration: const BoxDecoration(
                        color: Colors.greenAccent,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.check, size: 8, color: Colors.black),
                    ),
                  ),
              ],
            ),
            text: 'Practicar',
          ),
          Tab(
            icon: Icon(Icons.hub_rounded, size: 22 * textScale),
            text: 'Evaluar',
          ),
        ],
      ),
    );
  }

  /// Widget placeholder para fases sin contenido.
  Widget _buildEmptyPhase(String phaseName, String message, double textScale) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.construction_rounded,
              size: 64,
              color: _planetColor.withValues(alpha: 0.3),
            ),
            const SizedBox(height: 16),
            Text(
              '$phaseName — $message',
              textAlign: TextAlign.center,
              style: GoogleFonts.fredoka(
                fontSize: 18 * textScale,
                fontWeight: FontWeight.bold,
                color: Colors.white.withValues(alpha: 0.4),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'El contenido de esta fase está en desarrollo.\n'
              'Agrega datos en sample_lesson_content.dart para activarla.',
              textAlign: TextAlign.center,
              style: GoogleFonts.fredoka(
                fontSize: 13 * textScale,
                color: Colors.white.withValues(alpha: 0.25),
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
