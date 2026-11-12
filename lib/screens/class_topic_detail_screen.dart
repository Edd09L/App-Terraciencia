import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

// Import condicional para registro de IFrame en Flutter Web sin romper compilación
// ignore: avoid_web_libraries_in_flutter, deprecated_member_use
import 'dart:html' as html;
import 'dart:ui_web' as ui_web;

import '../models/app_colors.dart';
import '../models/topic.dart';
import '../models/teacher_curriculum_model.dart';
import '../providers/user_role_provider.dart';
import '../widgets/canva_slide_viewer.dart';

/// Alias para soportar ambas denominaciones de la pantalla de detalle de tema
typedef TopicDetailScreen = ClassTopicDetailScreen;
typedef LessonModularDetailScreen = ClassTopicDetailScreen;

/// Pantalla Modular de Clase/Tema con Recursos Pedagógicos DUA de Terraciencia.
///
/// Dispone de una barra de navegación superior (TabBar) con 6 módulos interactivos:
/// 1. "Diapositivas": WebView / IFrame de Canva en modo proyector con controles interactivos.
/// 2. "Lectura": Texto guiado DUA, resúmenes, glosario interactivo e historias de Terraciencia.
/// 3. "Preguntas": Preguntas detonantes para el aula y quiz interactivo gamificado.
/// 4. "Actividades": Fichas didácticas imprimibles, rúbricas y retos en equipo con temporizador.
/// 5. "Laboratorio": Guía de experimentos paso a paso con lista de materiales y bitácora.
/// 6. "Realidad Virtual / RA": Visor de modelos 3D interactivos y experiencia Phygital.
class ClassTopicDetailScreen extends StatefulWidget {
  final Topic? topic;
  final CurriculumWeek? week;
  final int weekNumber;
  final String title;
  final String description;
  final String planetId;
  final String planetName;
  final Color themeColor;
  final String? slidesUrl;
  final List<String> contents;

  const ClassTopicDetailScreen({
    super.key,
    this.topic,
    this.week,
    this.weekNumber = 1,
    this.title = 'La Curiosidad Humana y el Método Científico',
    this.description = 'Descubre cómo nace la ciencia a partir de hacernos preguntas cotidianas.',
    this.planetId = 'prisma',
    this.planetName = 'Prisma',
    this.themeColor = const Color(0xFF4B0082),
    this.slidesUrl,
    this.contents = const [],
  });

  /// Abre la pantalla a partir de un [Topic]
  static void openFromTopic(BuildContext context, Topic topic, {int? weekNumber}) {
    final planetId = topic.planetId.toLowerCase();
    String pName = 'Prisma';
    Color pColor = AppColors.prisma;
    if (planetId.contains('cib')) {
      pName = 'Cíberon';
      pColor = AppColors.ciberon;
    } else if (planetId.contains('kin')) {
      pName = 'Kinetos';
      pColor = AppColors.kinetos;
    } else if (planetId.contains('sim')) {
      pName = 'Simbios';
      pColor = AppColors.simbios;
    } else if (planetId.contains('vit')) {
      pName = 'Vitalia';
      pColor = AppColors.vitalia;
    } else if (planetId.contains('tit')) {
      pName = 'Titan-Q';
      pColor = AppColors.titanQ;
    } else if (planetId.contains('noo')) {
      pName = 'Noosféris';
      pColor = AppColors.noosferis;
    }

    int effectiveWeek = weekNumber ?? 1;
    if (weekNumber == null) {
      final titleMatch = RegExp(r'[Ss]emana\s*(\d+)').firstMatch(topic.title);
      if (titleMatch != null) {
        effectiveWeek = int.tryParse(titleMatch.group(1)!) ?? 1;
      } else {
        final idMatch = RegExp(r'(\d+)').firstMatch(topic.id);
        if (idMatch != null) {
          effectiveWeek = int.tryParse(idMatch.group(1)!) ?? 1;
        }
      }
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ClassTopicDetailScreen(
          topic: topic,
          weekNumber: effectiveWeek,
          title: topic.title,
          description: topic.description,
          planetId: planetId,
          planetName: pName,
          themeColor: pColor,
          slidesUrl: topic.contentUrl,
        ),
      ),
    );
  }

  /// Abre la pantalla a partir de un [CurriculumWeek]
  static void openFromWeek(
    BuildContext context, {
    required CurriculumWeek week,
    required Color competenceColor,
  }) {
    final pName = week.planetName ?? 'Prisma';
    final pId = pName.toLowerCase().replaceAll('í', 'i').replaceAll('é', 'e');

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ClassTopicDetailScreen(
          week: week,
          weekNumber: week.weekNumber,
          title: week.title,
          description: week.description,
          planetId: pId,
          planetName: pName,
          themeColor: week.planetColor ?? competenceColor,
          slidesUrl: week.slidesUrl,
          contents: week.contents,
        ),
      ),
    );
  }

  @override
  State<ClassTopicDetailScreen> createState() => _ClassTopicDetailScreenState();
}

class _ClassTopicDetailScreenState extends State<ClassTopicDetailScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _canvaEmbedViewId = '';
  bool _isCanvaLoading = true;
  bool _canvaLoadError = false;
  bool _isOnline = true;
  Timer? _canvaLoadingTimer;
  StreamSubscription? _onlineSub;
  StreamSubscription? _offlineSub;


  // Configuración de accesibilidad DUA para lectura
  double _fontScale = 1.0;
  bool _easyReadingMode = false;

  // Estado del Quiz Interactivo (Pestaña 3)
  int _currentQuestionIndex = 0;
  int? _selectedAnswerIndex;
  bool _hasAnswered = false;
  int _quizScore = 0;
  bool _isQuizCompleted = false;

  // Estado de Experimentos / Laboratorio (Pestaña 5)
  final Set<int> _completedSteps = {};
  final TextEditingController _labNotesController = TextEditingController();
  bool _labNotesSaved = false;

  // Estado del Temporizador de Aula (Pestaña 4)
  Timer? _timer;
  int _timerSeconds = 600; // 10 minutos por defecto
  bool _isTimerRunning = false;

  // Estado del Visor 3D / Realidad Virtual (Pestaña 6)
  double _rotationX = 0.0;
  double _rotationY = 0.0;
  double _zoomScale = 1.0;

  final ScrollController _tabScrollController = ScrollController();

  // Paleta de colores pastel y bordes sólidos por módulo DUA
  final List<Color> _tabPastelColors = const [
    Color(0xFFF3E8FF), // 1. Diapositivas (Morado Pastel)
    Color(0xFFE0F2FE), // 2. Lectura (Azul Cielo Pastel)
    Color(0xFFFEF3C7), // 3. Preguntas (Ámbar Pastel)
    Color(0xFFFFE4E6), // 4. Actividades (Rosa Pastel)
    Color(0xFFDCFCE7), // 5. Laboratorio (Verde Menta Pastel)
    Color(0xFFCFFAFE), // 6. Realidad Virtual / RA (Cian Pastel)
  ];

  final List<Color> _tabSolidBorders = const [
    Color(0xFF7C3AED), // 1. Morado Sólido
    Color(0xFF0284C7), // 2. Azul Sólido
    Color(0xFFD97706), // 3. Ámbar Sólido
    Color(0xFFE11D48), // 4. Rosa Sólido
    Color(0xFF059669), // 5. Verde Sólido
    Color(0xFF0891B2), // 6. Cian Sólido
  ];

  final List<String> _tabEmojis = const [
    '🎥',
    '📖',
    '❓',
    '🧩',
    '🔬',
    '🥽',
  ];

  final List<String> _tabTitles = const [
    'Diapositivas',
    'Lectura',
    'Preguntas',
    'Actividades',
    'Laboratorio',
    'Realidad Virtual / RA',
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 6, vsync: this);
    _tabController.addListener(() {
      setState(() {});
    });

    _canvaEmbedViewId =
        'canva-topic-view-${widget.weekNumber}-${DateTime.now().millisecondsSinceEpoch}';

    if (kIsWeb) {
      _isOnline = html.window.navigator.onLine ?? true;
      _onlineSub = html.window.onOnline.listen((_) {
        if (mounted) {
          setState(() {
            _isOnline = true;
            _canvaLoadError = false;
          });
          _retryCanvaLoad();
        }
      });
      _offlineSub = html.window.onOffline.listen((_) {
        if (mounted) {
          setState(() {
            _isOnline = false;
            _canvaLoadError = true;
          });
        }
      });

      if (_isOnline) {
        _registerCanvaWebIFrame();
        _startLoadingTimer();
      } else {
        _isCanvaLoading = false;
        _canvaLoadError = true;
      }
    }
  }

  void _startLoadingTimer() {
    _canvaLoadingTimer?.cancel();
    _canvaLoadingTimer = Timer(const Duration(milliseconds: 2500), () {
      if (mounted && _isCanvaLoading) {
        setState(() => _isCanvaLoading = false);
      }
    });
  }

  void _retryCanvaLoad() {
    if (kIsWeb) {
      _isOnline = html.window.navigator.onLine ?? true;
    }
    if (!_isOnline) {
      setState(() {
        _canvaLoadError = true;
        _isCanvaLoading = false;
      });
      return;
    }

    setState(() {
      _canvaLoadError = false;
      _isCanvaLoading = true;
      _canvaEmbedViewId =
          'canva-topic-view-$_effectiveWeekNumber-${DateTime.now().millisecondsSinceEpoch}';
    });

    if (kIsWeb) {
      _registerCanvaWebIFrame();
      _startLoadingTimer();
    }
  }

  void _scrollToTab(int index) {
    if (!_tabScrollController.hasClients) return;
    const itemEstimatedWidth = 145.0;
    final targetOffset = (index * itemEstimatedWidth - 60).clamp(
      0.0,
      _tabScrollController.position.maxScrollExtent,
    );
    _tabScrollController.animateTo(
      targetOffset,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOutCubic,
    );
  }

  /// Sanitiza y formatea la URL de Canva para asegurar que termine en /watch?embed o ?embed
  static String sanitizeCanvaUrl(String rawUrl) {
    if (rawUrl.isEmpty) return rawUrl;
    var url = rawUrl.trim();

    if (url.contains('canva.com')) {
      if (url.contains('/view?embed')) {
        url = url.replaceAll('/view?embed', '/watch?embed');
      } else if (url.contains('/view')) {
        url = url.replaceAll('/view', '/watch?embed');
      } else if (url.contains('/watch')) {
        if (!url.contains('?embed') && !url.contains('&embed')) {
          url = url.contains('?') ? '$url&embed' : '$url?embed';
        }
      } else if (!url.contains('?embed') && !url.contains('&embed')) {
        url = url.contains('?') ? '$url&embed' : '$url?embed';
      }
    }
    return url;
  }

  void _registerCanvaWebIFrame() {
    final formattedCanvaUrl = _getEffectiveSlidesUrl();
    ui_web.platformViewRegistry.registerViewFactory(_canvaEmbedViewId, (int viewId) {
      final iframe = html.IFrameElement()
        ..src = formattedCanvaUrl
        ..allow = "fullscreen"
        ..style.border = 'none'
        ..style.width = '100%'
        ..style.height = '100%'
        ..setAttribute('allowfullscreen', 'true')
        ..setAttribute('webkitallowfullscreen', 'true')
        ..setAttribute('mozallowfullscreen', 'true');

      iframe.onLoad.listen((_) {
        if (mounted) {
          setState(() {
            _isCanvaLoading = false;
            _canvaLoadError = false;
          });
        }
      });

      iframe.onError.listen((_) {
        if (mounted) {
          setState(() {
            _isCanvaLoading = false;
            _canvaLoadError = true;
          });
        }
      });

      return iframe;
    });
  }

  String _getEffectiveSlidesUrl() {
    String? rawUrl = widget.slidesUrl;
    if (rawUrl == null || rawUrl.isEmpty || rawUrl.startsWith('placeholder_')) {
      rawUrl = widget.topic?.contentUrl;
    }

    if (rawUrl == null || rawUrl.isEmpty || rawUrl.startsWith('placeholder_')) {
      // Presentaciones oficiales de Canva para Prisma (Semanas 1 a 4) y Simbios (Semanas 5 a 9)
      switch (_effectiveWeekNumber) {
        case 1:
          rawUrl =
              'https://www.canva.com/design/DAHWl7lM8js/mOhgvI64u01ucTvazBWM9Q/watch?embed';
          break;
        case 2:
          rawUrl =
              'https://www.canva.com/design/DAHWlz1UWoo/jpddo6_AIOd7gN6YPLSDyg/watch?embed';
          break;
        case 3:
          rawUrl =
              'https://www.canva.com/design/DAHWlwKTQ98/N3JRV46lVEtMiN4rn_8hyw/watch?embed';
          break;
        case 4:
          rawUrl =
              'https://www.canva.com/design/DAHWgUBGbPg/JKIksrv6ZQeNiQpzpCrSQQ/watch?embed';
          break;
        case 5:
          rawUrl =
              'https://www.canva.com/design/DAHYp5ZC3KE/HDS_ywTlND_bFRewc9wg6w/watch?embed';
          break;
        case 6:
          rawUrl =
              'https://www.canva.com/design/DAHYp1BI0Wc/MvfFSweJ_pZgMI7lPUQ2pQ/watch?embed';
          break;
        case 7:
          rawUrl =
              'https://www.canva.com/design/DAHYp0uAVL8/oW4eLABLwvjTZynqHOv6AQ/watch?embed';
          break;
        case 8:
          rawUrl =
              'https://www.canva.com/design/DAHYqLypi_g/b5HFiViuJ8ST2r6N99Onmg/watch?embed';
          break;
        case 9:
          rawUrl =
              'https://www.canva.com/design/DAHYqCECcJM/Q1mjepk96RFfF0XrsinKWw/watch?embed';
          break;
        case 10:
          rawUrl =
              'https://www.canva.com/design/DAHYrJVe388/vWqY8dvFSzXpV4hjjgVxeA/watch?embed';
          break;
        case 11:
          rawUrl =
              'https://www.canva.com/design/DAHYrAXbYms/mjlEh43gDE3pOrep5fTnog/watch?embed';
          break;
        case 12:
          rawUrl =
              'https://www.canva.com/design/DAHYrA9CXKw/2WEzbyEPHFYYC2WzY6cW1w/watch?embed';
          break;
        case 13:
          rawUrl =
              'https://www.canva.com/design/DAHYrH5eAQ8/Ox9V28l2w9-4kA8kituJfg/watch?embed';
          break;
        case 14:
          rawUrl =
              'https://www.canva.com/design/DAHYrChpcZc/4JnKXpTOhSGBELC6EYuBGg/watch?embed';
          break;
        case 15:
          rawUrl =
              'https://www.canva.com/design/DAHYrFe2MMw/aQQiQLMdDkOALJGItbBfrQ/watch?embed';
          break;
        case 16:
          rawUrl =
              'https://www.canva.com/design/DAHYrH24TTM/cCZx3Q_sTMANZmmIK5mEIg/watch?embed';
          break;
        case 17:
          rawUrl =
              'https://www.canva.com/design/DAHYrEkhheM/erNArIIO4UXoELex4pQQdw/watch?embed';
          break;
        case 18:
          rawUrl =
              'https://www.canva.com/design/DAHYrJDzT-U/TG-eLAN9Led0rD7HPphxJw/watch?embed';
          break;
        case 19:
          rawUrl =
              'https://www.canva.com/design/DAHYrGL1fo0/6HSl9mk19W8eX1GeLhFkPg/watch?embed';
          break;
        case 20:
          rawUrl =
              'https://www.canva.com/design/DAHYrLOTomA/4q39iY07SF2-v8ohI9j1uA/watch?embed';
          break;
        case 21:
          rawUrl =
              'https://www.canva.com/design/DAHYrPWXFcQ/4NAGgUDGTXE6Tu4329-DAA/watch?embed';
          break;
        case 22:
          rawUrl =
              'https://www.canva.com/design/DAHYrGlxZbg/HYV875spBLsyDHV-HkQBjQ/watch?embed';
          break;
        case 23:
          rawUrl =
              'https://www.canva.com/design/DAHYwDy3OJc/o-ZtiqJkTn-dFRfsYLTpDg/watch?embed';
          break;
        case 24:
          rawUrl =
              'https://www.canva.com/design/DAHYwCSrVCg/wMgZMIQ4SWalYYZLL82Jwg/watch?embed';
          break;
        case 25:
        case 26:
          rawUrl =
              'https://www.canva.com/design/DAHYwHiKWS0/1wFpH8z10JQ9epjiieRLEQ/watch?embed';
          break;
        case 27:
          rawUrl =
              'https://www.canva.com/design/DAHYwBeFfJ4/viQuUqhgw3JpOqeQYhyhvg/watch?embed';
          break;
        case 28:
          rawUrl =
              'https://www.canva.com/design/DAHYwKDFT_M/rfAT06CBVoIMKfTgXEHILA/watch?embed';
          break;
        case 29:
          rawUrl =
              'https://www.canva.com/design/DAHYwFtE7UI/jfryP_psZ25BuTw7NoLnAw/watch?embed';
          break;
        case 30:
          rawUrl =
              'https://www.canva.com/design/DAHYwCIWkCc/cuulqZ8hB91zCfKX7XgkNg/watch?embed';
          break;
        case 31:
          rawUrl =
              'https://www.canva.com/design/DAHYwOgDCcw/6Fq68-_-P2TS5XHtDlw1Fw/watch?embed';
          break;
        default:
          rawUrl =
              'https://www.canva.com/design/DAHWl7lM8js/mOhgvI64u01ucTvazBWM9Q/watch?embed';
      }
    }

    return sanitizeCanvaUrl(rawUrl);
  }

  @override
  void dispose() {
    _onlineSub?.cancel();
    _offlineSub?.cancel();
    _canvaLoadingTimer?.cancel();
    _tabScrollController.dispose();
    _timer?.cancel();
    _tabController.dispose();
    _labNotesController.dispose();
    super.dispose();
  }

  // ── TEMPORIZADOR DE AULA ──────────────────────────────────────────────────
  void _toggleTimer() {
    if (_isTimerRunning) {
      _timer?.cancel();
      setState(() => _isTimerRunning = false);
    } else {
      setState(() => _isTimerRunning = true);
      _timer = Timer.periodic(const Duration(seconds: 1), (t) {
        if (_timerSeconds > 0) {
          setState(() => _timerSeconds--);
        } else {
          t.cancel();
          setState(() => _isTimerRunning = false);
        }
      });
    }
  }

  void _resetTimer(int seconds) {
    _timer?.cancel();
    setState(() {
      _timerSeconds = seconds;
      _isTimerRunning = false;
    });
  }

  String _formatTimerTime(int totalSecs) {
    final mins = totalSecs ~/ 60;
    final secs = totalSecs % 60;
    return '${mins.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  // ── CONSTRUCCIÓN PRINCIPAL DE LA INTERFAZ ─────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final roleProvider = context.watch<UserRoleProvider>();
    final double textScale = roleProvider.textScaleFactor;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA), // Fondo Blanco Hueso
      body: SafeArea(
        child: Column(
          children: [
            // 1. BARRA SUPERIOR CON METADATA Y BOTONES DE ACCIÓN
            _buildTopAppBar(context, textScale),

            // 2. TABBAR HORIZONTAL MODULAR (6 PESTAÑAS PASTEL CON BORDE SÓLIDO)
            _buildModularTabBar(textScale),

            const SizedBox(height: 8),

            // 3. VISTA DE CONTENIDOS MODULARES (TABBARVIEW)
            Expanded(
              child: TabBarView(
                controller: _tabController,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  _KeepAliveWrapper(child: _buildSlidesTab(textScale)),
                  _KeepAliveWrapper(child: _buildReadingTab(textScale)),
                  _KeepAliveWrapper(child: _buildQuestionsTab(textScale)),
                  _KeepAliveWrapper(child: _buildActivitiesTab(textScale)),
                  _KeepAliveWrapper(child: _buildLaboratoryTab(textScale)),
                  _KeepAliveWrapper(child: _buildVRPhygitalTab(textScale)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Obtención dinámica del número de semana
  int get _effectiveWeekNumber {
    if (widget.weekNumber > 1 && !widget.title.toLowerCase().contains('semana')) {
      return widget.weekNumber;
    }
    final match = RegExp(r'[Ss]emana\s*(\d+)').firstMatch(widget.title);
    if (match != null) {
      return int.tryParse(match.group(1)!) ?? widget.weekNumber;
    }
    return widget.weekNumber;
  }

  // ─── 1. BARRA SUPERIOR LIMPIA CON [VOLVER], [CHIP SEMANA] Y [TÍTULO] ───────
  Widget _buildTopAppBar(BuildContext context, double textScale) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: Color(0xFFE2E8F0), width: 1.0),
        ),
      ),
      child: Row(
        children: [
          // Botón Regresar [Volver]
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => Navigator.of(context).pop(),
              borderRadius: BorderRadius.circular(10),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFFE2E8F0), width: 1.0),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.arrow_back_ios_new_rounded,
                      color: Color(0xFF0F172A),
                      size: 15,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Volver',
                      style: GoogleFonts.plusJakartaSans(
                        color: const Color(0xFF0F172A),
                        fontWeight: FontWeight.w700,
                        fontSize: 13 * textScale,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: 14),

          // [Chip Dinámico de Semana]
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: widget.themeColor,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              'Semana $_effectiveWeekNumber',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12.5 * textScale,
                fontWeight: FontWeight.w800,
                color: Colors.white,
                letterSpacing: 0.1,
              ),
            ),
          ),
          const SizedBox(width: 14),

          // [Título del Tema]
          Expanded(
            child: Text(
              widget.title,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 16 * textScale,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF0F172A),
                letterSpacing: -0.3,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  // ─── 2. TABBAR HORIZONTAL CON LOS 6 MÓDULOS PEDAGÓGICOS DUA ───────────────
  Widget _buildModularTabBar(double textScale) {
    return Container(
      height: 64,
      margin: const EdgeInsets.only(top: 4, bottom: 6),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: Color(0xFFE2E8F0), width: 1.0),
        ),
      ),
      child: ListView.separated(
        controller: _tabScrollController,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: 6,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final isSelected = _tabController.index == index;
          final pastelColor = _tabPastelColors[index];
          final solidBorder = _tabSolidBorders[index];
          final emoji = _tabEmojis[index];
          final title = _tabTitles[index];

          return Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                _tabController.animateTo(index);
                _scrollToTab(index);
                setState(() {});
              },
              borderRadius: BorderRadius.circular(12),
              hoverColor: solidBorder.withValues(alpha: 0.06),
              splashColor: solidBorder.withValues(alpha: 0.12),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeInOut,
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  color: isSelected ? pastelColor : Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected ? solidBorder : const Color(0xFFCBD5E1),
                    width: isSelected ? 2.0 : 1.0,
                  ),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: solidBorder.withValues(alpha: 0.24),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : const [
                          BoxShadow(
                            color: Color(0x04000000),
                            blurRadius: 3,
                            offset: Offset(0, 1),
                          ),
                        ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(5),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? solidBorder.withValues(alpha: 0.14)
                            : const Color(0xFFF1F5F9),
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        emoji,
                        style: const TextStyle(fontSize: 16),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      title,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 13.5 * textScale,
                        fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                        color: isSelected
                            ? const Color(0xFF0F172A)
                            : const Color(0xFF475569),
                        letterSpacing: -0.2,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // PESTAÑA 1: DIAPOSITIVAS (WEBVIEW / CANVA EN MODO PROYECTOR)
  // ═══════════════════════════════════════════════════════════════════════════
  Widget _buildCanvaErrorState(double textScale) {
    return Center(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 480),
        margin: const EdgeInsets.all(24),
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 32),
        decoration: BoxDecoration(
          color: const Color(0xFF1E293B),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFF334155), width: 1.5),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.35),
              blurRadius: 24,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: const Color(0xFFEF4444).withValues(alpha: 0.12),
                shape: BoxShape.circle,
                border: Border.all(
                  color: const Color(0xFFEF4444).withValues(alpha: 0.35),
                  width: 1.5,
                ),
              ),
              child: const Icon(
                Icons.wifi_off_rounded,
                color: Color(0xFFF87171),
                size: 42,
              ),
            ),
            const SizedBox(height: 18),
            Text(
              _isOnline ? 'Error al Cargar Diapositivas' : 'Sin Conexión a Internet',
              style: GoogleFonts.plusJakartaSans(
                color: Colors.white,
                fontSize: 18 * textScale,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.3,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            Text(
              _isOnline
                  ? 'No se pudo conectar con los servidores de Canva para la Semana $_effectiveWeekNumber. Revisa tu conexión o vuelve a intentar cargar la presentación.'
                  : 'Parece que tu dispositivo está desconectado. Conéctate a una red Wi-Fi o datos móviles para ver la presentación interactiva de Canva.',
              style: GoogleFonts.plusJakartaSans(
                color: const Color(0xFF94A3B8),
                fontSize: 13.5 * textScale,
                height: 1.45,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _retryCanvaLoad,
              icon: const Icon(Icons.refresh_rounded, size: 20),
              label: Text(
                'Reintentar Carga',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 14 * textScale,
                  fontWeight: FontWeight.w700,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF7C3AED),
                foregroundColor: Colors.white,
                elevation: 4,
                shadowColor: const Color(0xFF7C3AED).withValues(alpha: 0.5),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // PESTAÑA 1: DIAPOSITIVAS (WEBVIEW / CANVA EN MODO PROYECTOR)
  // ═══════════════════════════════════════════════════════════════════════════
  Widget _buildSlidesTab(double textScale) {
    final slidesUrl = _getEffectiveSlidesUrl();

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
      child: Column(
        children: [
          // Barra de Control Superior del Modo Proyector
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFE2E8F0), width: 1.0),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x04000000),
                  blurRadius: 6,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                const Icon(Icons.slideshow_rounded, color: Color(0xFF7C3AED), size: 22),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Presentación Oficial de Canva • Semana $_effectiveWeekNumber',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 13.5 * textScale,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF0F172A),
                    ),
                  ),
                ),
                // Botón de Recargar
                OutlinedButton.icon(
                  onPressed: _retryCanvaLoad,
                  icon: const Icon(Icons.refresh_rounded, size: 16),
                  label: Text(
                    'Recargar',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12.5 * textScale,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF64748B),
                    side: const BorderSide(color: Color(0xFFCBD5E1)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  ),
                ),
                const SizedBox(width: 8),
                // Botón Pantalla Completa Proyector
                ElevatedButton.icon(
                  onPressed: () {
                    CanvaSlideViewer.open(
                      context,
                      slidesUrl: slidesUrl,
                      title: widget.title,
                      weekNumber: _effectiveWeekNumber,
                      competenceColor: widget.themeColor,
                    );
                  },
                  icon: const Icon(Icons.fullscreen_rounded, size: 18),
                  label: Text(
                    'Pantalla Completa',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 13 * textScale,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF7C3AED),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    elevation: 2,
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Contenedor del IFrame de Canva / Error / Fallback
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: const Color(0xFF0F172A),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFF7C3AED), width: 1.5),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.12),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(15),
                child: (_canvaLoadError || !_isOnline)
                    ? _buildCanvaErrorState(textScale)
                    : (kIsWeb
                        ? Stack(
                            children: [
                              HtmlElementView(viewType: _canvaEmbedViewId),
                              if (_isCanvaLoading)
                                Container(
                                  color: const Color(0xFF0F172A),
                                  child: Center(
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const CircularProgressIndicator(
                                          color: Color(0xFF7C3AED),
                                          strokeWidth: 3,
                                        ),
                                        const SizedBox(height: 16),
                                        Text(
                                          'Cargando presentación de Canva...',
                                          style: GoogleFonts.plusJakartaSans(
                                            color: Colors.white,
                                            fontSize: 14 * textScale,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                        const SizedBox(height: 6),
                                        Text(
                                          'Semana $_effectiveWeekNumber • Diapositivas DUA',
                                          style: GoogleFonts.plusJakartaSans(
                                            color: const Color(0xFF94A3B8),
                                            fontSize: 12.5 * textScale,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                            ],
                          )
                        : Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.slideshow_rounded, size: 54, color: Colors.white70),
                                const SizedBox(height: 12),
                                Text(
                                  'Visualizador de Canva',
                                  style: GoogleFonts.plusJakartaSans(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                ElevatedButton(
                                  onPressed: () {
                                    CanvaSlideViewer.open(
                                      context,
                                      slidesUrl: slidesUrl,
                                      title: widget.title,
                                      weekNumber: _effectiveWeekNumber,
                                      competenceColor: widget.themeColor,
                                    );
                                  },
                                  child: const Text('Abrir Diapositivas'),
                                ),
                              ],
                            ),
                          )),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // PESTAÑA 2: LECTURA (TEXTO GUIADO DUA & RESÚMENES)
  // ═══════════════════════════════════════════════════════════════════════════
  Widget _buildReadingTab(double textScale) {
    final effectiveTextScale = textScale * _fontScale;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 30),
      physics: const BouncingScrollPhysics(),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 860),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Barra de Herramientas DUA para Lectura
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: const Color(0xFFE0F2FE),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFF0284C7), width: 1.5),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.accessibility_new_rounded, color: Color(0xFF0284C7), size: 22),
                    const SizedBox(width: 8),
                    Text(
                      'Adaptaciones DUA:',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 13 * effectiveTextScale,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF0369A1),
                      ),
                    ),
                    const Spacer(),

                    // Selector de Tamaño de Fuente
                    IconButton(
                      tooltip: 'Reducir tamaño de letra',
                      icon: const Icon(Icons.text_decrease_rounded, color: Color(0xFF0369A1), size: 20),
                      onPressed: () => setState(() => _fontScale = (_fontScale - 0.1).clamp(0.85, 1.4)),
                    ),
                    IconButton(
                      tooltip: 'Aumentar tamaño de letra',
                      icon: const Icon(Icons.text_increase_rounded, color: Color(0xFF0369A1), size: 20),
                      onPressed: () => setState(() => _fontScale = (_fontScale + 0.1).clamp(0.85, 1.4)),
                    ),

                    // Modo Lectura Fácil
                    FilterChip(
                      label: Text(
                        'Lectura Fácil',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 11.5 * effectiveTextScale,
                          fontWeight: FontWeight.w700,
                          color: _easyReadingMode ? Colors.white : const Color(0xFF0369A1),
                        ),
                      ),
                      selected: _easyReadingMode,
                      selectedColor: const Color(0xFF0284C7),
                      backgroundColor: Colors.white,
                      onSelected: (val) => setState(() => _easyReadingMode = val),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // SECCIÓN 1: La Gran Historia de Terraciencia
              _buildReadingSectionCard(
                title: 'La Aventura en el Planeta ${widget.planetName}',
                subtitle: 'Historia narrativa para introducir la curiosidad científica',
                icon: Icons.auto_stories_rounded,
                headerColor: const Color(0xFF0284C7),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _easyReadingMode
                          ? 'Nova y los exploradores llegaron al planeta ${widget.planetName}. Notaron que todo a su alrededor tenía secretos por descubrir. Se hicieron una pregunta: ¿Cómo podemos saber la verdad de las cosas? La respuesta fue usar la observación y los experimentos.'
                          : 'Al aterrizar en la atmósfera resplandeciente del Planeta ${widget.planetName}, la tripulación de exploradores de Terraciencia se enfrentó a un enigma cósmico. Nova, la guía científica, tomó su cuaderno de campo y recordó la regla de oro de la ciencia: "Todo gran descubrimiento comienza con una pregunta sencilla y la valentía de observar sin prejuicios".',
                      style: GoogleFonts.merriweather(
                        fontSize: 15 * effectiveTextScale,
                        height: 1.65,
                        color: const Color(0xFF1E293B),
                      ),
                    ),
                    const SizedBox(height: 14),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF0FDF4),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFF86EFAC), width: 1.0),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.lightbulb_outline_rounded, color: Color(0xFF16A34A), size: 22),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'Pregunta clave para reflexionar: ¿Qué es lo más curioso que has observado en la naturaleza esta semana?',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 13 * effectiveTextScale,
                                fontWeight: FontWeight.w700,
                                color: const Color(0xFF15803D),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // SECCIÓN 2: Conceptos Clave del Currículo Nacional
              _buildReadingSectionCard(
                title: 'Conceptos Clave y Resumen DUA',
                subtitle: 'Contenidos curriculares oficiales explicados con claridad',
                icon: Icons.checklist_rounded,
                headerColor: const Color(0xFF4338CA),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (widget.contents.isNotEmpty)
                      ...widget.contents.map((c) => Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Padding(
                                  padding: EdgeInsets.only(top: 4),
                                  child: Icon(Icons.check_circle_rounded, color: Color(0xFF4338CA), size: 18),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    c,
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 14 * effectiveTextScale,
                                      fontWeight: FontWeight.w600,
                                      color: const Color(0xFF1E293B),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ))
                    else ...[
                      _buildBulletPoint('1. La Observación:', 'Usar todos los sentidos para registrar hechos medibles y verificables.', effectiveTextScale),
                      _buildBulletPoint('2. La Hipótesis:', 'Una explicación tentativa que puede ser puesta a prueba mediante experimentos.', effectiveTextScale),
                      _buildBulletPoint('3. La Experimentación:', 'Diseñar pruebas controladas para comprobar si la hipótesis es correcta.', effectiveTextScale),
                      _buildBulletPoint('4. Las Conclusiones:', 'Compartir los hallazgos de forma clara y honesta con la comunidad.', effectiveTextScale),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // SECCIÓN 3: Glosario Emergente
              _buildReadingSectionCard(
                title: 'Glosario Científico DUA',
                subtitle: 'Toca cada término para ver su definición ilustrada',
                icon: Icons.bookmark_added_rounded,
                headerColor: const Color(0xFF0D9488),
                child: Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    _buildGlossaryChip('Método Científico', 'Camino ordenado para investigar y responder preguntas sobre la naturaleza.', effectiveTextScale),
                    _buildGlossaryChip('Hipótesis', 'Respuesta probable que se pone a prueba con experimentos.', effectiveTextScale),
                    _buildGlossaryChip('Variable', 'Elemento que puede cambiar en un experimento.', effectiveTextScale),
                    _buildGlossaryChip('Evidencia', 'Datos y pruebas reales que demuestran un hecho.', effectiveTextScale),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildReadingSectionCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color headerColor,
    required Widget child,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0), width: 1.0),
        boxShadow: const [
          BoxShadow(color: Color(0x06000000), blurRadius: 10, offset: Offset(0, 3)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
            decoration: BoxDecoration(
              color: headerColor.withValues(alpha: 0.06),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
              border: Border(bottom: BorderSide(color: headerColor.withValues(alpha: 0.18), width: 1.0)),
            ),
            child: Row(
              children: [
                Icon(icon, color: headerColor, size: 22),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF0F172A),
                        ),
                      ),
                      Text(
                        subtitle,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12,
                          color: const Color(0xFF64748B),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(18),
            child: child,
          ),
        ],
      ),
    );
  }

  Widget _buildBulletPoint(String label, String text, double textScale) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: RichText(
        text: TextSpan(
          style: GoogleFonts.plusJakartaSans(
            fontSize: 14 * textScale,
            color: const Color(0xFF1E293B),
            height: 1.5,
          ),
          children: [
            TextSpan(
              text: '$label ',
              style: const TextStyle(fontWeight: FontWeight.w800, color: Color(0xFF0F172A)),
            ),
            TextSpan(text: text),
          ],
        ),
      ),
    );
  }

  Widget _buildGlossaryChip(String term, String definition, double textScale) {
    return ActionChip(
      backgroundColor: const Color(0xFFF0FDFA),
      side: const BorderSide(color: Color(0xFF5EEAD4), width: 1.2),
      label: Text(
        term,
        style: GoogleFonts.plusJakartaSans(
          fontSize: 13 * textScale,
          fontWeight: FontWeight.w700,
          color: const Color(0xFF0F766E),
        ),
      ),
      onPressed: () {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
            title: Row(
              children: [
                const Icon(Icons.bookmark_added_rounded, color: Color(0xFF0D9488)),
                const SizedBox(width: 10),
                Text(term, style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w800)),
              ],
            ),
            content: Text(
              definition,
              style: GoogleFonts.plusJakartaSans(fontSize: 14.5, height: 1.5),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Entendido'),
              ),
            ],
          ),
        );
      },
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // PESTAÑA 3: PREGUNTAS (PREGUNTAS DETONANTES & QUIZ INTERACTIVO)
  // ═══════════════════════════════════════════════════════════════════════════
  Widget _buildQuestionsTab(double textScale) {
    final questions = [
      {
        'q': '¿Cuál es el primer paso indispensable para iniciar una investigación científica según el método científico?',
        'opts': [
          'Hacer una observación cuidadosa y formularse una pregunta',
          'Comprar instrumentos caros de laboratorio',
          'Escribir la conclusión final antes de empezar',
          'Aceptar las opiniones sin comprobarlas'
        ],
        'correct': 0,
        'explanation': 'La ciencia siempre nace de la curiosidad humana: observar un fenómeno y hacerse una pregunta sobre cómo funciona.',
      },
      {
        'q': '¿Qué es una hipótesis en el contexto de las ciencias naturales?',
        'opts': [
          'Una verdad absoluta que nunca cambia',
          'Una explicación tentativa o predicción que se pone a prueba',
          'Un resumen de las opiniones de los científicos',
          'Un dibujo artístico del experimento'
        ],
        'correct': 1,
        'explanation': 'Una hipótesis es una respuesta tentativa que debe ponerse a prueba mediante experimentos y recolección de evidencias.',
      },
      {
        'q': 'Si un experimento no da el resultado esperado, ¿qué debe hacer un científico?',
        'opts': [
          'Ocultar los datos para que nadie se entere',
          'Analizar los resultados, revisar la hipótesis y aprender del error',
          'Abandonar la investigación para siempre',
          'Inventar números falsos'
        ],
        'correct': 1,
        'explanation': 'En la ciencia, los resultados inesperados son valiosísimos para ajustar hipótesis y avanzar en el conocimiento.',
      },
    ];

    final currentQ = questions[_currentQuestionIndex];

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 30),
      physics: const BouncingScrollPhysics(),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 820),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 1. Tarjeta de Preguntas Detonantes (Para debate en el aula)
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: const Color(0xFFFEF3C7),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFD97706), width: 1.5),
                  boxShadow: const [
                    BoxShadow(color: Color(0x06000000), blurRadius: 10, offset: Offset(0, 3)),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.psychology_rounded, color: Color(0xFFB45309), size: 24),
                        const SizedBox(width: 10),
                        Text(
                          'Preguntas Detonantes para el Aula DUA',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 15 * textScale,
                            fontWeight: FontWeight.w800,
                            color: const Color(0xFF78350F),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      '• ¿Por qué creemos lo que creemos sobre la naturaleza?\n• ¿Cómo podemos comprobar si un remedio casero o un saber tradicional funciona científicamente?\n• ¿Qué pasaría si la humanidad nunca hubiera inventado el método científico?',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 13.5 * textScale,
                        height: 1.55,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF92400E),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // 2. Quiz Interactivo Gamificado
              Container(
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: const Color(0xFFE2E8F0), width: 1.2),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.06),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (_isQuizCompleted) ...[
                      const Center(
                        child: Icon(Icons.stars_rounded, color: Color(0xFFD97706), size: 56),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        '¡Quiz Completado con Éxito! 🎉',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 18 * textScale,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF0F172A),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Puntaje total obtenido: $_quizScore pts',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 15 * textScale,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFFD97706),
                        ),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        onPressed: () {
                          setState(() {
                            _isQuizCompleted = false;
                            _currentQuestionIndex = 0;
                            _selectedAnswerIndex = null;
                            _hasAnswered = false;
                            _quizScore = 0;
                          });
                        },
                        icon: const Icon(Icons.replay_rounded),
                        label: const Text('Reiniciar Quiz'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFD97706),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                    ] else ...[
                      // Progreso del Quiz
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Pregunta ${_currentQuestionIndex + 1} de ${questions.length}',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 13 * textScale,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF64748B),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFEF3C7),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: const Color(0xFFF59E0B), width: 1.0),
                            ),
                            child: Text(
                              'Puntaje: $_quizScore pts',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 12.5 * textScale,
                                fontWeight: FontWeight.w800,
                                color: const Color(0xFFB45309),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                    const SizedBox(height: 12),

                    // Texto de la Pregunta
                    Text(
                      currentQ['q'] as String,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 16 * textScale,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF0F172A),
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 18),

                    // Opciones de Respuesta
                    ...(currentQ['opts'] as List<String>).asMap().entries.map((entry) {
                      final i = entry.key;
                      final opt = entry.value;
                      final isSelected = _selectedAnswerIndex == i;
                      final isCorrect = i == (currentQ['correct'] as int);

                      Color btnBg = Colors.white;
                      Color btnBorder = const Color(0xFFCBD5E1);
                      Color textColor = const Color(0xFF1E293B);

                      if (_hasAnswered) {
                        if (isCorrect) {
                          btnBg = const Color(0xFFDCFCE7);
                          btnBorder = const Color(0xFF16A34A);
                          textColor = const Color(0xFF15803D);
                        } else if (isSelected) {
                          btnBg = const Color(0xFFFFE4E6);
                          btnBorder = const Color(0xFFE11D48);
                          textColor = const Color(0xFFBE123C);
                        }
                      } else if (isSelected) {
                        btnBg = const Color(0xFFFEF3C7);
                        btnBorder = const Color(0xFFD97706);
                      }

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: InkWell(
                          onTap: _hasAnswered
                              ? null
                              : () {
                                  setState(() {
                                    _selectedAnswerIndex = i;
                                    _hasAnswered = true;
                                    if (isCorrect) {
                                      _quizScore += 100 ~/ questions.length;
                                    }
                                  });
                                },
                          borderRadius: BorderRadius.circular(14),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                            decoration: BoxDecoration(
                              color: btnBg,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: btnBorder, width: isSelected ? 2.0 : 1.2),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 28,
                                  height: 28,
                                  decoration: BoxDecoration(
                                    color: isSelected ? btnBorder : const Color(0xFFF1F5F9),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Center(
                                    child: Text(
                                      String.fromCharCode(65 + i),
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w800,
                                        color: isSelected ? Colors.white : const Color(0xFF475569),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    opt,
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 14 * textScale,
                                      fontWeight: FontWeight.w600,
                                      color: textColor,
                                    ),
                                  ),
                                ),
                                if (_hasAnswered && isCorrect)
                                  const Icon(Icons.check_circle_rounded, color: Color(0xFF16A34A), size: 22)
                                else if (_hasAnswered && isSelected)
                                  const Icon(Icons.cancel_rounded, color: Color(0xFFE11D48), size: 22),
                              ],
                            ),
                          ),
                        ),
                      );
                    }),

                    // Retroalimentación Explicativa
                    if (_hasAnswered) ...[
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8FAFC),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFFCBD5E1), width: 1.0),
                        ),
                        child: Text(
                          currentQ['explanation'] as String,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 13 * textScale,
                            fontStyle: FontStyle.italic,
                            color: const Color(0xFF334155),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () {
                          if (_currentQuestionIndex < questions.length - 1) {
                            setState(() {
                              _currentQuestionIndex++;
                              _selectedAnswerIndex = null;
                              _hasAnswered = false;
                            });
                          } else {
                            setState(() {
                              _isQuizCompleted = true;
                            });
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFD97706),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          elevation: 2,
                        ),
                        child: Text(
                          _currentQuestionIndex < questions.length - 1
                              ? 'Siguiente Pregunta'
                              : 'Finalizar Quiz DUA',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 14.5 * textScale,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // PESTAÑA 4: ACTIVIDADES (FICHAS DIDÁCTICAS, JUEGOS Y RETOS EN EQUIPO)
  // ═══════════════════════════════════════════════════════════════════════════
  Widget _buildActivitiesTab(double textScale) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 30),
      physics: const BouncingScrollPhysics(),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 860),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Temporizador de Aula Integrado
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFE4E6),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: const Color(0xFFE11D48), width: 1.5),
                  boxShadow: const [
                    BoxShadow(color: Color(0x06000000), blurRadius: 10, offset: Offset(0, 3)),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        _formatTimerTime(_timerSeconds),
                        style: GoogleFonts.firaCode(
                          fontSize: 22 * textScale,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFFBE123C),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Temporizador de Reto en Equipo',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 14 * textScale,
                              fontWeight: FontWeight.w800,
                              color: const Color(0xFF881337),
                            ),
                          ),
                          Text(
                            'Asigna roles de aula: Líder, Investigador, Diseñador y Portavoz.',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 12 * textScale,
                              color: const Color(0xFF9F1239),
                            ),
                          ),
                        ],
                      ),
                    ),
                    ElevatedButton.icon(
                      onPressed: _toggleTimer,
                      icon: Icon(_isTimerRunning ? Icons.pause_rounded : Icons.play_arrow_rounded, size: 18),
                      label: Text(_isTimerRunning ? 'Pausar' : 'Iniciar'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFE11D48),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      tooltip: 'Reiniciar Temporizador',
                      onPressed: () => _resetTimer(600),
                      icon: const Icon(Icons.refresh_rounded, color: Color(0xFFE11D48)),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),

              // Fichas Didácticas Imprimibles
              Text(
                'Fichas Didácticas y Retos Cooperativos',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 16 * textScale,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF0F172A),
                ),
              ),
              const SizedBox(height: 12),

              _buildActivityCard(
                title: 'Ficha 1: Mapa Mental de la Indagación (Individual)',
                badge: 'Ficha Imprimible',
                description: 'Los estudiantes organizan las etapas del método científico con ejemplos cotidianos.',
                icon: Icons.draw_rounded,
                color: const Color(0xFFE11D48),
                textScale: textScale,
              ),
              const SizedBox(height: 12),

              _buildActivityCard(
                title: 'Ficha 2: El Gran Debate Científico (En Equipo)',
                badge: 'Trabajo Cooperativo',
                description: 'Diseño de un experimento escolar para resolver un problema de la comunidad.',
                icon: Icons.groups_rounded,
                color: const Color(0xFF0284C7),
                textScale: textScale,
              ),
              const SizedBox(height: 12),

              _buildActivityCard(
                title: 'Ficha 3: Rúbrica de Autoevaluación DUA',
                badge: 'Evaluación Formativa',
                description: 'Instrumento de evaluación formativa con criterios visuales y niveles de logro.',
                icon: Icons.fact_check_rounded,
                color: const Color(0xFF059669),
                textScale: textScale,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActivityCard({
    required String title,
    required String badge,
    required String description,
    required IconData icon,
    required Color color,
    required double textScale,
  }) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0), width: 1.0),
        boxShadow: const [
          BoxShadow(color: Color(0x06000000), blurRadius: 8, offset: Offset(0, 2)),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: color.withValues(alpha: 0.35), width: 1.0),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    badge,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 11 * textScale,
                      fontWeight: FontWeight.w700,
                      color: color,
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  title,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14.5 * textScale,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12.5 * textScale,
                    color: const Color(0xFF64748B),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          ElevatedButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Generando recurso: $title'),
                  backgroundColor: color,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: color,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            ),
            child: const Text('Descargar'),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // PESTAÑA 5: LABORATORIO (GUÍA DE EXPERIMENTOS PASO A PASO)
  // ═══════════════════════════════════════════════════════════════════════════
  Widget _buildLaboratoryTab(double textScale) {
    final steps = [
      'Paso 1: Colocar un recipiente con agua sobre una mesa cerca de una ventana o fuente de luz.',
      'Paso 2: Sumergir un espejo plano en el agua con una inclinación aproximada de 45 grados.',
      'Paso 3: Dirigir una linterna o la luz solar directamente hacia la parte sumergida del espejo.',
      'Paso 4: Sostener una hoja de papel blanco frente al espejo para captar la luz reflejada.',
      'Paso 5: Observar cómo la luz blanca se descompone en los 7 colores del arcoíris y registrar los hallazgos.',
    ];

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 30),
      physics: const BouncingScrollPhysics(),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 860),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Encabezado del Experimento
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: const Color(0xFFDCFCE7),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFF059669), width: 1.5),
                  boxShadow: const [
                    BoxShadow(color: Color(0x06000000), blurRadius: 10, offset: Offset(0, 3)),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.science_rounded, color: Color(0xFF047857), size: 24),
                        const SizedBox(width: 10),
                        Text(
                          'Experimento de Indagación: El Prisma Casero',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 15.5 * textScale,
                            fontWeight: FontWeight.w800,
                            color: const Color(0xFF064E3B),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Materiales Requeridos: 1 espejo plano pequeño, 1 recipiente hondo con agua, 1 linterna o luz solar, 1 hoja de papel blanco y tu bitácora.',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 13 * textScale,
                        height: 1.45,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF065F46),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),

              // Pasos del Experimento
              Text(
                'Procedimiento Paso a Paso (Marca al completar):',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 15 * textScale,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF0F172A),
                ),
              ),
              const SizedBox(height: 10),

              ...steps.asMap().entries.map((entry) {
                final idx = entry.key;
                final stepText = entry.value;
                final isDone = _completedSteps.contains(idx);

                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: InkWell(
                    onTap: () {
                      setState(() {
                        if (isDone) {
                          _completedSteps.remove(idx);
                        } else {
                          _completedSteps.add(idx);
                        }
                      });
                    },
                    borderRadius: BorderRadius.circular(14),
                    child: Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: isDone ? const Color(0xFFF0FDF4) : Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: isDone ? const Color(0xFF16A34A) : const Color(0xFFCBD5E1),
                          width: isDone ? 1.8 : 1.0,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            isDone ? Icons.check_box_rounded : Icons.check_box_outline_blank_rounded,
                            color: isDone ? const Color(0xFF16A34A) : const Color(0xFF94A3B8),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              stepText,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 13.5 * textScale,
                                fontWeight: isDone ? FontWeight.w700 : FontWeight.w500,
                                color: isDone ? const Color(0xFF15803D) : const Color(0xFF1E293B),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }),
              const SizedBox(height: 16),

              // Bitácora Científica del Alumno / Docente
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFE2E8F0), width: 1.2),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Bitácora Científica: Registra tus Observaciones',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 14.5 * textScale,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF0F172A),
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: _labNotesController,
                      maxLines: 4,
                      style: GoogleFonts.plusJakartaSans(fontSize: 13.5 * textScale),
                      decoration: InputDecoration(
                        hintText: 'Describe los colores observados, los ángulos y tu conclusión...',
                        hintStyle: GoogleFonts.plusJakartaSans(color: const Color(0xFF94A3B8)),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton.icon(
                      onPressed: () {
                        setState(() => _labNotesSaved = true);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('¡Observaciones guardadas en la bitácora científica!'),
                            backgroundColor: Color(0xFF059669),
                          ),
                        );
                      },
                      icon: const Icon(Icons.save_rounded, size: 18),
                      label: Text(_labNotesSaved ? '¡Guardado con Éxito!' : 'Guardar en Bitácora'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF059669),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // PESTAÑA 6: REALIDAD VIRTUAL / RA (MODELOS 3D Y EXPERIENCIA PHYGITAL)
  // ═══════════════════════════════════════════════════════════════════════════
  Widget _buildVRPhygitalTab(double textScale) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 30),
      physics: const BouncingScrollPhysics(),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 860),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Visor 3D Interactivo
              Container(
                height: 380,
                decoration: BoxDecoration(
                  color: const Color(0xFF0F172A),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFF0891B2), width: 1.8),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF0891B2).withValues(alpha: 0.25),
                      blurRadius: 18,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Stack(
                  children: [
                    // Canvas 3D Interactivo
                    GestureDetector(
                      onPanUpdate: (details) {
                        setState(() {
                          _rotationX += details.delta.dy * 0.01;
                          _rotationY += details.delta.dx * 0.01;
                        });
                      },
                      child: Center(
                        child: Transform.scale(
                          scale: _zoomScale,
                          child: Transform(
                            transform: Matrix4.identity()
                              ..setEntry(3, 2, 0.001)
                              ..rotateX(_rotationX)
                              ..rotateY(_rotationY),
                            alignment: Alignment.center,
                            child: Container(
                            width: 200,
                            height: 200,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: RadialGradient(
                                colors: [
                                  widget.themeColor.withValues(alpha: 0.9),
                                  const Color(0xFF0891B2),
                                  const Color(0xFF0284C7),
                                  Colors.transparent,
                                ],
                                stops: const [0.2, 0.5, 0.8, 1.0],
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFF0891B2).withValues(alpha: 0.5),
                                  blurRadius: 30,
                                  spreadRadius: 10,
                                ),
                              ],
                            ),
                            child: const Center(
                              child: Icon(
                                Icons.all_inclusive_rounded,
                                color: Colors.white,
                                size: 80,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    ),

                    // Controles de Vista 3D
                    Positioned(
                      top: 14,
                      left: 14,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.7),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: const Color(0xFF0891B2), width: 1.0),
                        ),
                        child: Text(
                          'Arrastra para rotar en 360°',
                          style: GoogleFonts.plusJakartaSans(
                            color: const Color(0xFFCFFAFE),
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),

                    Positioned(
                      bottom: 14,
                      right: 14,
                      child: Row(
                        children: [
                          IconButton(
                            tooltip: 'Acercar Zoom',
                            onPressed: () => setState(() => _zoomScale = (_zoomScale + 0.15).clamp(0.6, 2.2)),
                            icon: const Icon(Icons.zoom_in_rounded, color: Colors.white),
                            style: IconButton.styleFrom(backgroundColor: const Color(0xFF1E293B)),
                          ),
                          const SizedBox(width: 8),
                          IconButton(
                            tooltip: 'Alejar Zoom',
                            onPressed: () => setState(() => _zoomScale = (_zoomScale - 0.15).clamp(0.6, 2.2)),
                            icon: const Icon(Icons.zoom_out_rounded, color: Colors.white),
                            style: IconButton.styleFrom(backgroundColor: const Color(0xFF1E293B)),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),

              // Tarjeta de Experiencia Phygital y Realidad Aumentada
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: const Color(0xFFCFFAFE),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFF0891B2), width: 1.5),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.qr_code_scanner_rounded, color: Color(0xFF0E7490), size: 28),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Modo Phygital: Escaneo de Estampitas Físicas',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 14 * textScale,
                              fontWeight: FontWeight.w800,
                              color: const Color(0xFF155E75),
                            ),
                          ),
                          Text(
                            'Apunta con la cámara de tu tablet o teléfono al álbum impreso para proyectar el holograma interactivo.',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 12 * textScale,
                              color: const Color(0xFF164E63),
                            ),
                          ),
                        ],
                      ),
                    ),
                    ElevatedButton.icon(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Iniciando sensor de Realidad Aumentada (RA)...'),
                            backgroundColor: Color(0xFF0891B2),
                          ),
                        );
                      },
                      icon: const Icon(Icons.view_in_ar_rounded, size: 18),
                      label: const Text('Iniciar RA'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0891B2),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Mantiene vivo el estado de cada pestaña DUA (evita recarga de Canva WebView, bitácora y temporizador)
class _KeepAliveWrapper extends StatefulWidget {
  final Widget child;

  const _KeepAliveWrapper({required this.child});

  @override
  State<_KeepAliveWrapper> createState() => _KeepAliveWrapperState();
}

class _KeepAliveWrapperState extends State<_KeepAliveWrapper>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return widget.child;
  }
}

