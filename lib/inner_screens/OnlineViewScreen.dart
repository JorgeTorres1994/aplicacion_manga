import 'dart:io';
import 'package:aplicacion_manga/services/reader_service.dart';
import 'package:aplicacion_manga/theme/kuro_theme.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

class OnlineViewScreen extends StatefulWidget {
  final String pdfUrl;
  final String mangaTitle;
  final String? chapterTitle;
  final List<String>? pageImages;
  final String? mangaId;
  final String? coverUrl;
  final String? tomoTitle;

  const OnlineViewScreen({
    super.key,
    required this.pdfUrl,
    required this.mangaTitle,
    this.chapterTitle,
    this.pageImages,
    this.mangaId,
    this.coverUrl,
    this.tomoTitle,
  });

  @override
  State<OnlineViewScreen> createState() => _OnlineViewScreenState();
}

class _OnlineViewScreenState extends State<OnlineViewScreen> {
  PDFViewController? _pdfViewController;
  late final PageController _pageController;

  String? _pdfPath;
  bool _isLoading = true;
  int _currentPage = 1;
  int _totalPages = 1;
  bool _showDownloadBanner = true;
  bool _isRTL = true;
  bool _isSepia = false;
  double _brightness = 0.85;

  List<String> _effectiveImages = [];

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _loadContent();
  }

  bool _isImageSource(String url) {
    final lower = url.toLowerCase();
    if (lower.contains('.jpg') ||
        lower.contains('.jpeg') ||
        lower.contains('.png') ||
        lower.contains('.webp') ||
        lower.contains('.gif') ||
        lower.contains('capitulos_paginas') ||
        lower.contains('capitulos_imagenes') ||
        lower.contains('/images%2f') ||
        lower.contains('/images/')) {
      return true;
    }
    return false;
  }

  Future<void> _loadContent() async {
    setState(() => _isLoading = true);

    // 1. Si ya se proporcionó una lista de imágenes directas
    if (widget.pageImages != null && widget.pageImages!.isNotEmpty) {
      setState(() {
        _effectiveImages = List<String>.from(widget.pageImages!);
        _totalPages = _effectiveImages.length;
        _isLoading = false;
      });
      return;
    }

    final raw = widget.pdfUrl.trim();
    if (raw.isEmpty) {
      setState(() {
        _effectiveImages = [];
        _isLoading = false;
      });
      return;
    }

    // 2. Si la URL es reconocible como imagen por su nombre/ruta
    if (_isImageSource(raw)) {
      setState(() {
        _effectiveImages = [raw];
        _totalPages = 1;
        _isLoading = false;
      });
      return;
    }

    // 3. Si es un archivo local existente en disco
    final localFile = File(raw);
    if (localFile.existsSync()) {
      try {
        final bytes = await localFile.readAsBytes();
        final isPdf = bytes.length >= 4 &&
            bytes[0] == 0x25 &&
            bytes[1] == 0x50 &&
            bytes[2] == 0x44 &&
            bytes[3] == 0x46; // "%PDF"

        if (isPdf) {
          setState(() {
            _pdfPath = raw;
            _isLoading = false;
          });
          return;
        } else {
          setState(() {
            _effectiveImages = [raw];
            _totalPages = 1;
            _isLoading = false;
          });
          return;
        }
      } catch (e) {
        debugPrint('Error leyendo archivo local: $e');
      }
    }

    // 4. Si es una URL remota de red
    try {
      final dir = await getTemporaryDirectory();
      final hash = raw.hashCode.abs().toString();
      final safeTitle = widget.mangaTitle.replaceAll(RegExp(r'[^\w\s]+'), '_');

      final response = await http.get(Uri.parse(raw));
      if (response.statusCode == 200) {
        final bytes = response.bodyBytes;
        // Comprobar la firma mágica del archivo binario
        final isPdf = bytes.length >= 4 &&
            bytes[0] == 0x25 &&
            bytes[1] == 0x50 &&
            bytes[2] == 0x44 &&
            bytes[3] == 0x46; // "%PDF"

        if (isPdf) {
          final file = File('${dir.path}/${safeTitle}_$hash.pdf');
          await file.writeAsBytes(bytes);
          setState(() {
            _pdfPath = file.path;
            _isLoading = false;
          });
        } else {
          // No es PDF, es una foto/imagen de scanlation
          final file = File('${dir.path}/${safeTitle}_$hash.jpg');
          await file.writeAsBytes(bytes);
          setState(() {
            _effectiveImages = [file.path];
            _totalPages = 1;
            _isLoading = false;
          });
        }
      } else {
        throw Exception('Status code: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error descargando contenido: $e');
      setState(() {
        _effectiveImages = [raw];
        _totalPages = 1;
        _isLoading = false;
      });
    }
  }

  void _goToPreviousPage() {
    if (_effectiveImages.isNotEmpty) {
      if (_currentPage > 1) {
        _pageController.previousPage(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOutCubic,
        );
      } else {
        Fluttertoast.showToast(msg: 'Primera página alcanzada');
      }
    } else if (_pdfViewController != null) {
      if (_currentPage > 1) {
        final target = _currentPage - 2; // 0-based index
        _pdfViewController!.setPage(target);
        setState(() => _currentPage--);
      } else {
        Fluttertoast.showToast(msg: 'Primera página alcanzada');
      }
    }
  }

  void _goToNextPage() {
    if (_effectiveImages.isNotEmpty) {
      if (_currentPage < _totalPages) {
        _pageController.nextPage(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOutCubic,
        );
      } else {
        Fluttertoast.showToast(msg: 'Última página alcanzada');
      }
    } else if (_pdfViewController != null) {
      if (_currentPage < _totalPages) {
        final target = _currentPage; // 0-based target index
        _pdfViewController!.setPage(target);
        setState(() => _currentPage++);
      } else {
        Fluttertoast.showToast(msg: 'Última página alcanzada');
      }
    }
  }

  void _jumpToPage(int page) {
    final target = page.clamp(1, _totalPages > 0 ? _totalPages : 1);
    if (_effectiveImages.isNotEmpty) {
      _pageController.jumpToPage(target - 1);
    } else if (_pdfViewController != null) {
      _pdfViewController!.setPage(target - 1);
    }
    setState(() => _currentPage = target);
  }

  void _syncReadingProgress() {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid != null && uid.isNotEmpty) {
      KuroReaderBackendService.instance.saveReadingProgress(
        uid: uid,
        mangaId: widget.mangaId ?? widget.mangaTitle,
        mangaTitle: widget.mangaTitle,
        coverUrl: widget.coverUrl ?? '',
        chapterTitle: widget.chapterTitle ?? 'Capítulo en Lectura',
        tomoTitle: widget.tomoTitle,
        currentPage: _currentPage,
        totalPages: _totalPages > 0 ? _totalPages : 1,
        pdfUrl: widget.pdfUrl,
        pageImages: _effectiveImages.isNotEmpty ? _effectiveImages : widget.pageImages,
      );
    }
  }

  @override
  void dispose() {
    _syncReadingProgress();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final displayChapter = widget.chapterTitle ?? 'Capítulo en Lectura';

    return Scaffold(
      backgroundColor: KuroTheme.background,
      body: SafeArea(
        child: Column(
          children: [
            // Top App Bar
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: const BoxDecoration(
                color: KuroTheme.backgroundSecondary,
                border: Border(bottom: BorderSide(color: KuroTheme.border)),
              ),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back,
                        color: Colors.white, size: 20),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Flexible(
                              child: Text(
                                widget.mangaTitle.toUpperCase(),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.spaceGrotesk(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w800,
                                    color: Colors.white),
                              ),
                            ),
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 4, vertical: 1.5),
                              decoration: BoxDecoration(
                                  color: KuroTheme.crimson,
                                  borderRadius: BorderRadius.circular(3)),
                              child: Text('HD RAW',
                                  style: KuroTheme.mono(
                                      fontSize: 7.5,
                                      color: Colors.white,
                                      fontWeight: FontWeight.w800)),
                            ),
                          ],
                        ),
                        Text(displayChapter,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: KuroTheme.mono(
                                fontSize: 8.5, color: KuroTheme.textGrey)),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.bookmark_outline,
                        color: KuroTheme.crimson, size: 20),
                    onPressed: () => Fluttertoast.showToast(
                        msg: 'Página $_currentPage guardada en marcadores'),
                  ),
                  IconButton(
                    icon: const Icon(Icons.refresh, color: Colors.white, size: 20),
                    onPressed: () => _loadContent(),
                  ),
                ],
              ),
            ),

            // Download banner
            if (_showDownloadBanner)
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                padding: const EdgeInsets.all(10),
                decoration:
                    KuroTheme.cardDecoration(color: const Color(0xFF1B1B26)),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 28,
                          height: 28,
                          decoration: BoxDecoration(
                              color: KuroTheme.crimson.withValues(alpha: 0.25),
                              borderRadius: BorderRadius.circular(6)),
                          child: const Icon(Icons.cloud_download,
                              color: KuroTheme.crimson, size: 16),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(widget.mangaTitle,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: KuroTheme.mono(
                                      fontSize: 9.5,
                                      color: Colors.white,
                                      fontWeight: FontWeight.w700)),
                              Text('Modo de lectura optimizado • $displayChapter',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: KuroTheme.mono(
                                      fontSize: 8.5, color: KuroTheme.cyan)),
                            ],
                          ),
                        ),
                        GestureDetector(
                          onTap: () =>
                              setState(() => _showDownloadBanner = false),
                          child: const Icon(Icons.close,
                              color: KuroTheme.textMuted, size: 16),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

            // Viewer Area
            Expanded(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  if (_isLoading)
                    const Center(
                      child: CircularProgressIndicator(
                          color: KuroTheme.crimson, strokeWidth: 2),
                    )
                  else if (_effectiveImages.isNotEmpty)
                    PageView.builder(
                      controller: _pageController,
                      itemCount: _effectiveImages.length,
                      onPageChanged: (idx) {
                        setState(() => _currentPage = idx + 1);
                        _syncReadingProgress();
                      },
                      itemBuilder: (ctx, idx) {
                        final imgPath = _effectiveImages[idx];
                        final isLocal = File(imgPath).existsSync();
                        return Container(
                          color: _isSepia ? const Color(0xFFF4ECD8) : Colors.black,
                          child: InteractiveViewer(
                            child: isLocal
                                ? Image.file(
                                    File(imgPath),
                                    fit: BoxFit.contain,
                                  )
                                : Image.network(
                                    imgPath,
                                    fit: BoxFit.contain,
                                    errorBuilder: (_, __, ___) => const Center(
                                      child: Icon(Icons.broken_image,
                                          color: KuroTheme.textMuted, size: 48),
                                    ),
                                  ),
                          ),
                        );
                      },
                    )
                  else if (_pdfPath != null)
                    PDFView(
                      filePath: _pdfPath!,
                      enableSwipe: true,
                      swipeHorizontal: !_isRTL,
                      autoSpacing: true,
                      pageFling: true,
                      onViewCreated: (PDFViewController controller) {
                        _pdfViewController = controller;
                      },
                      onRender: (pages) {
                        if (pages != null && pages > 0) {
                          setState(() => _totalPages = pages);
                        }
                      },
                      onPageChanged: (page, total) {
                        setState(() {
                          _currentPage = (page ?? 0) + 1;
                          if (total != null && total > 0) {
                            _totalPages = total;
                          }
                        });
                        _syncReadingProgress();
                      },
                      onError: (error) {
                        debugPrint('PDF error: $error');
                      },
                    )
                  else
                    // Fallback visualizer
                    Container(
                      color: _isSepia ? const Color(0xFFF4ECD8) : Colors.black,
                      child: Center(
                        child: Image.network(
                          'https://images.unsplash.com/photo-1578632767115-351597cf2477?w=1000',
                          fit: BoxFit.contain,
                          color: _isSepia
                              ? Colors.amber.withValues(alpha: 0.25)
                              : null,
                          colorBlendMode: BlendMode.multiply,
                        ),
                      ),
                    ),

                  // Mini thumbnail overlay: PANEL X / Y
                  Positioned(
                    bottom: 16,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 5),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.8),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: KuroTheme.border),
                      ),
                      child: Text(
                        'PÁGINA $_currentPage / $_totalPages',
                        style: KuroTheme.mono(
                            fontSize: 10.5,
                            color: Colors.white,
                            fontWeight: FontWeight.w800),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Bottom Controls Bar
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: const BoxDecoration(
                color: KuroTheme.backgroundSecondary,
                border: Border(top: BorderSide(color: KuroTheme.border)),
              ),
              child: Column(
                children: [
                  // Chapter Previous / Navigation Arrows / Slider / Chapter Next
                  Row(
                    children: [
                      // Flecha Izquierda (Página Anterior)
                      Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(20),
                          onTap: _goToPreviousPage,
                          child: Container(
                            width: 38,
                            height: 38,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: _currentPage > 1
                                  ? KuroTheme.crimson.withValues(alpha: 0.25)
                                  : KuroTheme.cardLighter.withValues(alpha: 0.3),
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: _currentPage > 1
                                    ? KuroTheme.crimson
                                    : KuroTheme.border,
                                width: 1.5,
                              ),
                            ),
                            child: Icon(
                              Icons.chevron_left,
                              color: _currentPage > 1
                                  ? Colors.white
                                  : KuroTheme.textMuted,
                              size: 24,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),

                      // Barra Slider Interactiva
                      Expanded(
                        child: SliderTheme(
                          data: SliderTheme.of(context).copyWith(
                            thumbColor: KuroTheme.crimson,
                            activeTrackColor: KuroTheme.crimson,
                            inactiveTrackColor: KuroTheme.cardLighter,
                            thumbShape: const RoundSliderThumbShape(
                                enabledThumbRadius: 7),
                            trackHeight: 4,
                          ),
                          child: Slider(
                            value: _currentPage.toDouble().clamp(
                                1.0,
                                _totalPages > 1
                                    ? _totalPages.toDouble()
                                    : 1.0),
                            min: 1.0,
                            max: _totalPages > 1
                                ? _totalPages.toDouble()
                                : 1.0,
                            onChanged: (val) {
                              _jumpToPage(val.toInt());
                            },
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),

                      // Flecha Derecha (Página Siguiente)
                      Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(20),
                          onTap: _goToNextPage,
                          child: Container(
                            width: 38,
                            height: 38,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: _currentPage < _totalPages
                                  ? KuroTheme.crimson.withValues(alpha: 0.25)
                                  : KuroTheme.cardLighter.withValues(alpha: 0.3),
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: _currentPage < _totalPages
                                    ? KuroTheme.crimson
                                    : KuroTheme.border,
                                width: 1.5,
                              ),
                            ),
                            child: Icon(
                              Icons.chevron_right,
                              color: _currentPage < _totalPages
                                  ? Colors.white
                                  : KuroTheme.textMuted,
                              size: 24,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  // Info Line: PÁGINA X / Y  •  CAMBIAR CON FLECHAS O DESLIZADOR
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                              width: 6,
                              height: 6,
                              decoration: const BoxDecoration(
                                  color: KuroTheme.crimson,
                                  shape: BoxShape.circle)),
                          const SizedBox(width: 6),
                          Text('PÁGINA $_currentPage DE $_totalPages',
                              style: KuroTheme.mono(
                                  fontSize: 9.5,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700)),
                        ],
                      ),
                      Text('DESLIZA O TOCA LAS FLECHAS',
                          style: KuroTheme.mono(
                              fontSize: 8,
                              color: KuroTheme.cyan,
                              fontWeight: FontWeight.w700)),
                    ],
                  ),

                  const SizedBox(height: 10),

                  // 4 Quick Actions Row: RTL ⇄ CASCADA | AJUSTAR ANCHO | FILTRO SEPIA | BRILLO
                  Row(
                    children: [
                      _buildBottomBtn(
                        icon: Icons.swap_horiz,
                        label: _isRTL ? 'RTL ⇄ CASCADA' : 'CASCADA ⇄ RTL',
                        onTap: () {
                          setState(() => _isRTL = !_isRTL);
                          Fluttertoast.showToast(
                              msg: _isRTL
                                  ? 'Modo lectura: RTL (Derecha a Izquierda)'
                                  : 'Modo Cascada activado');
                        },
                      ),
                      const SizedBox(width: 6),
                      _buildBottomBtn(
                        icon: Icons.aspect_ratio,
                        label: 'AJUSTAR ANCHO',
                        onTap: () {
                          Fluttertoast.showToast(
                              msg: 'Ajuste de lectura al ancho de pantalla');
                        },
                      ),
                      const SizedBox(width: 6),
                      _buildBottomBtn(
                        icon: Icons.nightlight_round,
                        label: _isSepia ? 'OLED PURO' : 'FILTRO SEPIA',
                        onTap: () {
                          setState(() => _isSepia = !_isSepia);
                        },
                      ),
                      const SizedBox(width: 6),
                      _buildBottomBtn(
                        icon: Icons.brightness_6,
                        label: 'BRILLO ${(_brightness * 100).toInt()}%',
                        onTap: () {
                          setState(() {
                            _brightness = _brightness == 0.85 ? 1.0 : 0.85;
                          });
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomBtn({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: KuroTheme.card,
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: KuroTheme.border),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: KuroTheme.crimson, size: 14),
              const SizedBox(height: 2),
              Text(
                label,
                style: KuroTheme.mono(
                    fontSize: 7,
                    color: KuroTheme.textGrey,
                    fontWeight: FontWeight.w700),
                textAlign: TextAlign.center,
                maxLines: 1,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
