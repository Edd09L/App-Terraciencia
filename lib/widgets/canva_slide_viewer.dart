import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// Import condicional para registro de IFrame en Flutter Web sin romper compilación
// ignore: avoid_web_libraries_in_flutter, deprecated_member_use
import 'dart:html' as html;
import 'dart:ui_web' as ui_web;

/// Visor de Diapositivas Canva en Modo Proyector / Pantalla Completa con WebView / IFrame.
class CanvaSlideViewer extends StatefulWidget {
  final String slidesUrl;
  final String title;
  final int weekNumber;
  final Color competenceColor;

  const CanvaSlideViewer({
    super.key,
    required this.slidesUrl,
    required this.title,
    required this.weekNumber,
    this.competenceColor = const Color(0xFF4B0082),
  });

  /// Abre el visor de diapositivas en un diálogo / modal a pantalla completa
  static void open(
    BuildContext context, {
    required String slidesUrl,
    required String title,
    required int weekNumber,
    Color competenceColor = const Color(0xFF4B0082),
  }) {
    Navigator.of(context).push(
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (context) => CanvaSlideViewer(
          slidesUrl: slidesUrl,
          title: title,
          weekNumber: weekNumber,
          competenceColor: competenceColor,
        ),
      ),
    );
  }

  @override
  State<CanvaSlideViewer> createState() => _CanvaSlideViewerState();
}

class _CanvaSlideViewerState extends State<CanvaSlideViewer> {
  bool _isLoading = true;
  bool _hasError = false;
  bool _isOnline = true;
  late String _viewTypeId;
  Timer? _loadingTimeout;
  StreamSubscription? _onlineSub;
  StreamSubscription? _offlineSub;

  @override
  void initState() {
    super.initState();
    _viewTypeId = 'canva-slides-week-${widget.weekNumber}-${DateTime.now().millisecondsSinceEpoch}';

    if (kIsWeb) {
      _isOnline = html.window.navigator.onLine ?? true;
      _onlineSub = html.window.onOnline.listen((_) {
        if (mounted) {
          setState(() {
            _isOnline = true;
            _hasError = false;
          });
          _retryLoad();
        }
      });
      _offlineSub = html.window.onOffline.listen((_) {
        if (mounted) {
          setState(() {
            _isOnline = false;
            _hasError = true;
          });
        }
      });

      if (_isOnline) {
        _registerWebIFrame();
        _startTimeout();
      } else {
        _isLoading = false;
        _hasError = true;
      }
    }
  }

  void _startTimeout() {
    _loadingTimeout?.cancel();
    _loadingTimeout = Timer(const Duration(milliseconds: 2500), () {
      if (mounted && _isLoading) {
        setState(() => _isLoading = false);
      }
    });
  }

  void _retryLoad() {
    if (kIsWeb) {
      _isOnline = html.window.navigator.onLine ?? true;
    }
    if (!_isOnline) {
      setState(() {
        _hasError = true;
        _isLoading = false;
      });
      return;
    }

    setState(() {
      _hasError = false;
      _isLoading = true;
      _viewTypeId =
          'canva-slides-week-$_effectiveWeekNumber-${DateTime.now().millisecondsSinceEpoch}';
    });

    if (kIsWeb) {
      _registerWebIFrame();
      _startTimeout();
    }
  }

  static String _sanitizeCanvaUrl(String rawUrl) {
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

  void _registerWebIFrame() {
    final formattedCanvaUrl = _sanitizeCanvaUrl(widget.slidesUrl);
    ui_web.platformViewRegistry.registerViewFactory(_viewTypeId, (int viewId) {
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
            _isLoading = false;
            _hasError = false;
          });
        }
      });

      iframe.onError.listen((_) {
        if (mounted) {
          setState(() {
            _isLoading = false;
            _hasError = true;
          });
        }
      });

      return iframe;
    });
  }

  @override
  void dispose() {
    _onlineSub?.cancel();
    _offlineSub?.cancel();
    _loadingTimeout?.cancel();
    super.dispose();
  }

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B1120), // Fondo cine / proyector oscuro
      body: SafeArea(
        child: Column(
          children: [
            // ── Barra Superior Limpia: [Volver], [Chip Semana] y [Título] ──
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: const BoxDecoration(
                color: Color(0xFF0F172A),
                border: Border(
                  bottom: BorderSide(
                    color: Color(0xFF1E293B),
                    width: 1.0,
                  ),
                ),
              ),
              child: Row(
                children: [
                  // Botón Volver
                  Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () => Navigator.of(context).pop(),
                      borderRadius: BorderRadius.circular(10),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1E293B),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: const Color(0xFF334155),
                            width: 1.0,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.arrow_back_ios_new_rounded,
                              color: Colors.white,
                              size: 16,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Volver',
                              style: GoogleFonts.plusJakartaSans(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),

                  // Botón Recargar
                  Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: _retryLoad,
                      borderRadius: BorderRadius.circular(10),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1E293B),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: const Color(0xFF334155),
                            width: 1.0,
                          ),
                        ),
                        child: const Icon(
                          Icons.refresh_rounded,
                          color: Colors.white70,
                          size: 16,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),

                  // Chip Dinámico de Semana
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: widget.competenceColor,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'Semana $_effectiveWeekNumber',
                      style: GoogleFonts.plusJakartaSans(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        fontSize: 12.5,
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),

                  // Título del Tema
                  Expanded(
                    child: Text(
                      widget.title,
                      style: GoogleFonts.plusJakartaSans(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),

            // ── Contenedor del WebView / IFrame de Canva ──────────────────
            Expanded(
              child: (_hasError || !_isOnline)
                  ? Center(
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
                                fontSize: 18,
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
                                fontSize: 13.5,
                                height: 1.45,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 24),
                            ElevatedButton.icon(
                              onPressed: _retryLoad,
                              icon: const Icon(Icons.refresh_rounded, size: 20),
                              label: Text(
                                'Reintentar Carga',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 14,
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
                    )
                  : Stack(
                      children: [
                        // IFrame / WebView
                        if (kIsWeb)
                          HtmlElementView(viewType: _viewTypeId)
                        else
                          // Placeholder si se ejecuta en plataformas de testing sin webview
                          Center(
                            child: Container(
                              padding: const EdgeInsets.all(24),
                              decoration: BoxDecoration(
                                color: const Color(0xFF1E293B),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    Icons.slideshow_rounded,
                                    size: 48,
                                    color: Color(0xFF93C5FD),
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    'Presentación de Canva: Semana $_effectiveWeekNumber',
                                    style: GoogleFonts.plusJakartaSans(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    widget.slidesUrl,
                                    style: GoogleFonts.plusJakartaSans(
                                      color: const Color(0xFF94A3B8),
                                      fontSize: 12,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            ),
                          ),

                        // ── Indicador de Carga Estilizado ─────────────────────────
                        if (_isLoading)
                          Container(
                            color: const Color(0xFF0B1120),
                            child: Center(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(20),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF1E293B),
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: widget.competenceColor.withValues(alpha: 0.5),
                                        width: 2.0,
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: widget.competenceColor.withValues(alpha: 0.35),
                                          blurRadius: 20,
                                          spreadRadius: 2,
                                        ),
                                      ],
                                    ),
                                    child: CircularProgressIndicator(
                                      strokeWidth: 3.5,
                                      color: widget.competenceColor,
                                    ),
                                  ),
                                  const SizedBox(height: 20),
                                  Text(
                                    'Cargando presentación de Canva...',
                                    style: GoogleFonts.plusJakartaSans(
                                      color: Colors.white,
                                      fontSize: 15,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    'Semana $_effectiveWeekNumber • Modo Proyección sin barras de edición',
                                    style: GoogleFonts.plusJakartaSans(
                                      color: const Color(0xFF94A3B8),
                                      fontSize: 13,
                                    ),
                                  ),
                                ],
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
}
