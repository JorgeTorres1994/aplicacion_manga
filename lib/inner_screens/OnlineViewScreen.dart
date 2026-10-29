import 'dart:io';
import 'package:aplicacion_manga/theme/kuro_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

class OnlineViewScreen extends StatefulWidget {
  final String pdfUrl;
  final String mangaTitle;

  const OnlineViewScreen({
    super.key,
    required this.pdfUrl,
    required this.mangaTitle,
  });

  @override
  _OnlineViewScreenState createState() => _OnlineViewScreenState();
}

class _OnlineViewScreenState extends State<OnlineViewScreen> {
  String? _pdfPath;
  int _currentPage = 12;
  int _totalPages = 45;
  bool _showDownloadBanner = true;
  bool _isRTL = true;
  bool _isSepia = false;
  double _brightness = 0.85;

  @override
  void initState() {
    _loadPDF();
    super.initState();
  }

  Future<void> _loadPDF() async {
    try {
      final url = widget.pdfUrl.isNotEmpty
          ? widget.pdfUrl
          : 'https://www.w3.org/WAI/ER/tests/xhtml/testfiles/resources/pdf/dummy.pdf';

      final dir = await getTemporaryDirectory();
      final sanitizedTitle = widget.mangaTitle.replaceAll(RegExp(r'[^\w\s]+'), '_');
      final file = File('${dir.path}/$sanitizedTitle.pdf');

      if (!await file.exists()) {
        final response = await http.get(Uri.parse(url));
        await file.writeAsBytes(response.bodyBytes);
      }

      setState(() {
        _pdfPath = file.path;
      });
    } catch (e) {
      print('Error al preparar PDF: $e');
      Fluttertoast.showToast(msg: 'Cargando visualizador alternativo...');
    }
  }

  @override
  Widget build(BuildContext context) {
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
                    icon: const Icon(Icons.arrow_back, color: Colors.white, size: 20),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              widget.mangaTitle.length > 15
                                  ? '${widget.mangaTitle.substring(0, 15).toUpperCase()}...'
                                  : widget.mangaTitle.toUpperCase(),
                              style: GoogleFonts.spaceGrotesk(fontSize: 13, fontWeight: FontWeight.w800, color: Colors.white),
                            ),
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1.5),
                              decoration: BoxDecoration(color: KuroTheme.crimson, borderRadius: BorderRadius.circular(3)),
                              child: Text('HD RAW', style: KuroTheme.mono(fontSize: 7.5, color: Colors.white, fontWeight: FontWeight.w800)),
                            ),
                          ],
                        ),
                        Text('Cap. 142: El Festín de...', style: KuroTheme.mono(fontSize: 8.5, color: KuroTheme.textGrey)),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.bookmark, color: KuroTheme.crimson, size: 20),
                    onPressed: () => Fluttertoast.showToast(msg: 'Página guardada en marcadores'),
                  ),
                  IconButton(
                    icon: const Icon(Icons.auto_stories_outlined, color: Colors.white, size: 20),
                    onPressed: () {},
                  ),
                  IconButton(
                    icon: const Icon(Icons.tune, color: Colors.white, size: 20),
                    onPressed: () {},
                  ),
                ],
              ),
            ),

            // Download banner: Descargando Tomo 41 // Cap. 143
            if (_showDownloadBanner)
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                padding: const EdgeInsets.all(10),
                decoration: KuroTheme.cardDecoration(color: const Color(0xFF1B1B26)),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 28,
                          height: 28,
                          decoration: BoxDecoration(color: KuroTheme.crimson.withValues(alpha: 0.25), borderRadius: BorderRadius.circular(6)),
                          child: const Icon(Icons.cloud_download, color: KuroTheme.crimson, size: 16),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Descargando Tomo 41 // Cap. 143', style: KuroTheme.mono(fontSize: 9.5, color: Colors.white, fontWeight: FontWeight.w700)),
                              Text('80% completado • 4.2 MB/s', style: KuroTheme.mono(fontSize: 8.5, color: KuroTheme.cyan)),
                            ],
                          ),
                        ),
                        GestureDetector(
                          onTap: () => setState(() => _showDownloadBanner = false),
                          child: const Icon(Icons.close, color: KuroTheme.textMuted, size: 16),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Container(
                      height: 3,
                      decoration: BoxDecoration(color: KuroTheme.cardLighter, borderRadius: BorderRadius.circular(2)),
                      child: Row(
                        children: [
                          Expanded(flex: 80, child: Container(decoration: BoxDecoration(color: KuroTheme.crimson, borderRadius: BorderRadius.circular(2)))),
                          const Expanded(flex: 20, child: SizedBox()),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

            // Viewer Area
            Expanded(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  if (_pdfPath != null)
                    PDFView(
                      filePath: _pdfPath!,
                      enableSwipe: true,
                      swipeHorizontal: !_isRTL,
                      autoSpacing: true,
                      pageFling: true,
                      onPageChanged: (page, total) {
                        setState(() {
                          _currentPage = (page ?? 0) + 1;
                          _totalPages = total ?? 45;
                        });
                      },
                    )
                  else
                    // Fallback high-res preview image for offline/demo
                    Container(
                      color: _isSepia ? const Color(0xFFF4ECD8) : Colors.black,
                      child: Center(
                        child: Image.network(
                          'https://images.unsplash.com/photo-1578632767115-351597cf2477?w=1000',
                          fit: BoxFit.contain,
                          color: _isSepia ? Colors.amber.withValues(alpha: 0.25) : null,
                          colorBlendMode: BlendMode.multiply,
                        ),
                      ),
                    ),

                  // Mini thumbnail overlay: PANEL 12/45
                  Positioned(
                    bottom: 20,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.75),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: KuroTheme.border),
                      ),
                      child: Text(
                        'PANEL $_currentPage/$_totalPages',
                        style: KuroTheme.mono(fontSize: 10, color: Colors.white, fontWeight: FontWeight.w800),
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
                  // Chapter Previous / Slider / Chapter Next
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                        decoration: BoxDecoration(color: KuroTheme.card, borderRadius: BorderRadius.circular(6)),
                        child: Text('Cap. Ant.', style: KuroTheme.mono(fontSize: 9, color: KuroTheme.textGrey)),
                      ),
                      const SizedBox(width: 6),
                      const Icon(Icons.chevron_left, color: KuroTheme.textGrey, size: 20),
                      Expanded(
                        child: SliderTheme(
                          data: SliderTheme.of(context).copyWith(
                            thumbColor: KuroTheme.crimson,
                            activeTrackColor: KuroTheme.crimson,
                            inactiveTrackColor: KuroTheme.cardLighter,
                            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
                            trackHeight: 3,
                          ),
                          child: Slider(
                            value: _currentPage.toDouble(),
                            min: 1,
                            max: _totalPages.toDouble(),
                            onChanged: (val) {
                              setState(() {
                                _currentPage = val.toInt();
                              });
                            },
                          ),
                        ),
                      ),
                      const Icon(Icons.chevron_right, color: KuroTheme.textGrey, size: 20),
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                        decoration: BoxDecoration(color: KuroTheme.card, borderRadius: BorderRadius.circular(6)),
                        child: Text('Cap. Sig.', style: KuroTheme.mono(fontSize: 9, color: KuroTheme.textGrey)),
                      ),
                    ],
                  ),

                  // Info Line: PÁGINA 12 / 45  •  JUMP TO: INDEX GRID
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(width: 6, height: 6, decoration: const BoxDecoration(color: KuroTheme.crimson, shape: BoxShape.circle)),
                          const SizedBox(width: 6),
                          Text('PÁGINA $_currentPage / $_totalPages', style: KuroTheme.mono(fontSize: 9.5, color: Colors.white, fontWeight: FontWeight.w700)),
                        ],
                      ),
                      Text('JUMP TO: INDEX GRID', style: KuroTheme.mono(fontSize: 9.5, color: KuroTheme.cyan, fontWeight: FontWeight.w700)),
                    ],
                  ),

                  const SizedBox(height: 10),

                  // 4 Quick Actions Row: RTL ⇄ CASCADA | AJUSTAR ANCHO | FILTRO SEPIA | BRILLO 85%
                  Row(
                    children: [
                      _buildBottomBtn(
                        icon: Icons.swap_horiz,
                        label: _isRTL ? 'RTL ⇄ CASCADA' : 'CASCADA ⇄ RTL',
                        onTap: () {
                          setState(() => _isRTL = !_isRTL);
                          Fluttertoast.showToast(msg: _isRTL ? 'Modo de lectura: RTL (Derecha a Izquierda)' : 'Modo Cascada activado');
                        },
                      ),
                      const SizedBox(width: 6),
                      _buildBottomBtn(
                        icon: Icons.aspect_ratio,
                        label: 'AJUSTAR ANCHO',
                        onTap: () {
                          Fluttertoast.showToast(msg: 'Ajuste de ancho automático aplicado');
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
                style: KuroTheme.mono(fontSize: 7, color: KuroTheme.textGrey, fontWeight: FontWeight.w700),
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
