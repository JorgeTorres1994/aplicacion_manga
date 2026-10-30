import 'package:aplicacion_manga/services/admin_service.dart';
import 'package:aplicacion_manga/theme/kuro_theme.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';

class KuroAdminUploadScreen extends StatefulWidget {
  final bool isEmbedded;
  final VoidCallback? onBack;
  final VoidCallback? onPublished;
  final String? initialMangaId;
  final String? initialMangaTitle;
  final String? initialTomo;

  const KuroAdminUploadScreen({
    Key? key,
    this.isEmbedded = false,
    this.onBack,
    this.onPublished,
    this.initialMangaId,
    this.initialMangaTitle,
    this.initialTomo,
  }) : super(key: key);

  @override
  State<KuroAdminUploadScreen> createState() => _KuroAdminUploadScreenState();
}

class _KuroAdminUploadScreenState extends State<KuroAdminUploadScreen> {
  final serieController = TextEditingController();
  final tomoController = TextEditingController();
  final capController = TextEditingController();
  final nombreCapController = TextEditingController();
  final imageUrlController = TextEditingController();
  final pdfUrlController = TextEditingController();

  bool _visibilidadInmediata = true;
  bool _notificarLectores = true;
  bool _isUploading = false;
  String _selectedCategory = 'Seinen';

  // Colecciones dinámicas de Firebase
  List<Map<String, dynamic>> _mangasDisponibles = [];
  List<Map<String, dynamic>> _tomosDisponibles = [];
  String? _selectedMangaId;
  bool _isCustomSerie = false;
  bool _isCustomTomo = false;
  bool _isLoadingSeries = true;

  final List<String> _tags = [
    'Dark Fantasy',
    'Seinen',
    'Psicológico',
    'Gore',
    'Acción',
    'Shonen',
    'Romance',
    'Comedia',
    'Sobrenatural'
  ];
  final Set<String> _selectedTags = {'Seinen'};

  @override
  void initState() {
    super.initState();
    if (widget.initialMangaTitle != null) {
      serieController.text = widget.initialMangaTitle!;
    }
    if (widget.initialMangaId != null) {
      _selectedMangaId = widget.initialMangaId;
    }
    if (widget.initialTomo != null) {
      tomoController.text = widget.initialTomo!;
    }
    _cargarSeriesDeFirebase();
  }

  Future<void> _cargarSeriesDeFirebase() async {
    setState(() => _isLoadingSeries = true);
    final mangas = await KuroAdminBackendService.instance.fetchCatalog();
    if (mounted) {
      setState(() {
        _mangasDisponibles = mangas;
        _isLoadingSeries = false;

        if (_selectedMangaId == null && mangas.isNotEmpty) {
          if (widget.initialMangaTitle != null) {
            final match = mangas.firstWhere(
              (m) => m['title'] == widget.initialMangaTitle,
              orElse: () => mangas.first,
            );
            _selectedMangaId = match['docId'] ?? match['id'];
            serieController.text = match['title'] ?? '';
            _selectedCategory = match['category'] ?? _selectedCategory;
            if (match['imageUrl'] != null && match['imageUrl'].toString().isNotEmpty) {
              imageUrlController.text = match['imageUrl'];
            }
          } else {
            _selectedMangaId = mangas.first['docId'] ?? mangas.first['id'];
            serieController.text = mangas.first['title'] ?? '';
            _selectedCategory = mangas.first['category'] ?? _selectedCategory;
            if (mangas.first['imageUrl'] != null && mangas.first['imageUrl'].toString().isNotEmpty) {
              imageUrlController.text = mangas.first['imageUrl'];
            }
          }
        }
      });

      if (_selectedMangaId != null) {
        _cargarTomosDeManga(_selectedMangaId!);
      }
    }
  }

  Future<void> _cargarTomosDeManga(String mangaId) async {
    final tomos = await KuroAdminBackendService.instance.fetchTomos(mangaId);
    if (mounted) {
      setState(() {
        _tomosDisponibles = tomos;
        if (tomoController.text.isEmpty) {
          if (tomos.isNotEmpty) {
            tomoController.text = tomos.first['nombre'] ?? 'Tomo 01';
          } else {
            tomoController.text = 'Tomo 01';
          }
        }
      });
    }
  }

  Future<void> _publicarCapitulo() async {
    final series = serieController.text.trim();
    if (series.isEmpty) {
      Fluttertoast.showToast(msg: 'Por favor selecciona o ingresa el manga');
      return;
    }

    final capNum = capController.text.trim().isEmpty ? '01' : capController.text.trim();
    final tomoStr = tomoController.text.trim().isEmpty ? 'Tomo 01' : tomoController.text.trim();

    setState(() => _isUploading = true);

    try {
      await KuroAdminBackendService.instance.publishChapter(
        mangaId: _selectedMangaId,
        seriesTitle: series,
        volume: tomoStr,
        chapterNumber: capNum,
        chapterName: nombreCapController.text.trim().isNotEmpty
            ? nombreCapController.text.trim()
            : 'Capítulo $capNum',
        category: _selectedCategory,
        tags: _selectedTags.toList(),
        instantVisibility: _visibilidadInmediata,
        notifyReaders: _notificarLectores,
        customImageUrl: imageUrlController.text.trim().isNotEmpty
            ? imageUrlController.text.trim()
            : null,
        customPdfUrl: pdfUrlController.text.trim().isNotEmpty
            ? pdfUrlController.text.trim()
            : null,
      );

      setState(() => _isUploading = false);

      Fluttertoast.showToast(
        msg: 'Capítulo publicado y vinculado a $series ($tomoStr) exitosamente',
        backgroundColor: KuroTheme.crimson,
      );

      // Limpiar campos del capítulo
      capController.clear();
      nombreCapController.clear();
      pdfUrlController.clear();

      if (mounted) {
        if (widget.onPublished != null) {
          widget.onPublished!();
        } else if (Navigator.canPop(context)) {
          Navigator.pop(context);
        }
      }
    } catch (e) {
      setState(() => _isUploading = false);
      Fluttertoast.showToast(msg: 'Error al sincronizar: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: KuroTheme.background,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: KuroTheme.background,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white, size: 20),
          onPressed: () {
            if (widget.onBack != null) {
              widget.onBack!();
            } else if (Navigator.canPop(context)) {
              Navigator.pop(context);
            }
          },
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'KURO ADMIN SUITE // V.2.04',
              style: KuroTheme.mono(
                  fontSize: 8.5,
                  color: KuroTheme.cyan,
                  fontWeight: FontWeight.w700),
            ),
            Text(
              'SUBIR CAPÍTULO',
              style: GoogleFonts.spaceGrotesk(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: Colors.white),
            ),
          ],
        ),
        actions: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
            margin: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: KuroTheme.crimson.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(4),
              border: Border.all(
                  color: KuroTheme.crimson.withValues(alpha: 0.4)),
            ),
            child: Row(
              children: [
                Container(
                    width: 5,
                    height: 5,
                    decoration: const BoxDecoration(
                        color: KuroTheme.crimson, shape: BoxShape.circle)),
                const SizedBox(width: 4),
                Text('PIPELINE OK',
                    style: KuroTheme.mono(
                        fontSize: 8.5,
                        color: KuroTheme.crimson,
                        fontWeight: FontWeight.w800)),
              ],
            ),
          ),
          const SizedBox(width: 14),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Chips
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                    decoration: BoxDecoration(
                        color: KuroTheme.crimson.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(4)),
                    child: Row(
                      children: [
                        Container(
                            width: 5,
                            height: 5,
                            decoration: const BoxDecoration(
                                color: KuroTheme.crimson,
                                shape: BoxShape.circle)),
                        const SizedBox(width: 5),
                        Text('PIPELINE: ACTIVO',
                            style: KuroTheme.mono(
                                fontSize: 8,
                                color: KuroTheme.crimson,
                                fontWeight: FontWeight.w800)),
                      ],
                    ),
                  ),
                  const SizedBox(width: 6),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                    decoration: BoxDecoration(
                        color: KuroTheme.cardLighter,
                        borderRadius: BorderRadius.circular(4)),
                    child: Text('ROOT ADMIN',
                        style:
                            KuroTheme.mono(fontSize: 8, color: KuroTheme.textGrey)),
                  ),
                  const SizedBox(width: 6),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                    decoration: BoxDecoration(
                        color: KuroTheme.cyan.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(4)),
                    child: Row(
                      children: [
                        const Icon(Icons.bolt, color: KuroTheme.cyan, size: 10),
                        Text('KURO-INGEST v4.2',
                            style: KuroTheme.mono(
                                fontSize: 8,
                                color: KuroTheme.cyan,
                                fontWeight: FontWeight.w700)),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 8),

            Text('SUBIR CAPÍTULO // 新規投稿', style: KuroTheme.title(fontSize: 22)),
            const SizedBox(height: 4),
            Text(
              'Módulo de publicación de tomos y capítulos, compresión WebP/PDF y distribución en Firestore.',
              style: KuroTheme.body(fontSize: 11, color: KuroTheme.textGrey),
            ),

            const SizedBox(height: 20),

            // Card 01. METADATOS DE LA OBRA
            Container(
              padding: const EdgeInsets.all(16),
              decoration: KuroTheme.cardDecoration(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.menu_book,
                              color: KuroTheme.crimson, size: 15),
                          const SizedBox(width: 6),
                          Text('01. METADATOS DE LA OBRA',
                              style: KuroTheme.mono(
                                  fontSize: 9.5,
                                  color: KuroTheme.textWhite,
                                  fontWeight: FontWeight.w700)),
                        ],
                      ),
                      Text('CAMPOS EN VIVO',
                          style: KuroTheme.mono(
                              fontSize: 8, color: KuroTheme.textMuted)),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // TÍTULO DE LA SERIE
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('TÍTULO DE LA SERIE // MANGA PADRE',
                          style: KuroTheme.mono(
                              fontSize: 8.5, color: KuroTheme.textMuted)),
                      if (_isLoadingSeries)
                        const SizedBox(
                          width: 12,
                          height: 12,
                          child: CircularProgressIndicator(strokeWidth: 1.5, color: KuroTheme.purple),
                        )
                      else if (_mangasDisponibles.isNotEmpty)
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              _isCustomSerie = !_isCustomSerie;
                              if (_isCustomSerie) {
                                _selectedMangaId = null;
                                serieController.clear();
                              } else {
                                _selectedMangaId = _mangasDisponibles.first['docId'] ?? _mangasDisponibles.first['id'];
                                serieController.text = _mangasDisponibles.first['title'] ?? '';
                                _cargarTomosDeManga(_selectedMangaId!);
                              }
                            });
                          },
                          child: Text(
                            _isCustomSerie ? '← Elegir de Catálogo' : '+ Registrar Nueva',
                            style: KuroTheme.mono(
                                fontSize: 8.5,
                                color: KuroTheme.cyan,
                                fontWeight: FontWeight.w700),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 6),

                  if (!_isCustomSerie && _mangasDisponibles.isNotEmpty)
                    Container(
                      height: 48,
                      decoration: BoxDecoration(
                          color: KuroTheme.cardLighter,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: KuroTheme.cyan.withValues(alpha: 0.5))),
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _selectedMangaId,
                          isExpanded: true,
                          dropdownColor: KuroTheme.backgroundSecondary,
                          icon: const Icon(Icons.arrow_drop_down, color: KuroTheme.cyan),
                          items: _mangasDisponibles.map((m) {
                            return DropdownMenuItem<String>(
                              value: (m['docId'] ?? m['id']).toString(),
                              child: Row(
                                children: [
                                  const Icon(Icons.auto_stories, color: KuroTheme.cyan, size: 14),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      m['title'] ?? 'Sin título',
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: GoogleFonts.spaceGrotesk(
                                          fontSize: 13,
                                          color: Colors.white,
                                          fontWeight: FontWeight.w700),
                                    ),
                                  ),
                                  Text(
                                    '(${m['category'] ?? 'Manga'})',
                                    style: KuroTheme.mono(fontSize: 8, color: KuroTheme.textMuted),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                          onChanged: (val) {
                            if (val != null) {
                              setState(() {
                                _selectedMangaId = val;
                                final match = _mangasDisponibles.firstWhere(
                                    (x) => (x['docId'] ?? x['id']) == val,
                                    orElse: () => _mangasDisponibles.first);
                                serieController.text = match['title'] ?? '';
                                _selectedCategory = match['category'] ?? _selectedCategory;
                                if (match['imageUrl'] != null && match['imageUrl'].toString().isNotEmpty) {
                                  imageUrlController.text = match['imageUrl'];
                                }
                              });
                              _cargarTomosDeManga(val);
                            }
                          },
                        ),
                      ),
                    )
                  else
                    Container(
                      height: 44,
                      decoration: BoxDecoration(
                          color: KuroTheme.cardLighter,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: KuroTheme.border)),
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: TextField(
                        controller: serieController,
                        style: GoogleFonts.spaceGrotesk(
                            fontSize: 13,
                            color: Colors.white,
                            fontWeight: FontWeight.w700),
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          hintText: 'Ingresa el nombre del manga (ej. Chainsaw Man)',
                          hintStyle: KuroTheme.mono(
                              fontSize: 10, color: KuroTheme.textMuted),
                        ),
                      ),
                    ),

                  const SizedBox(height: 12),

                  // Volumen / Tomo & Nº de Capítulo
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('VOLUMEN / TOMO',
                                    style: KuroTheme.mono(
                                        fontSize: 8.5, color: KuroTheme.textMuted)),
                                if (_tomosDisponibles.isNotEmpty)
                                  GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        _isCustomTomo = !_isCustomTomo;
                                        if (_isCustomTomo) {
                                          tomoController.clear();
                                        } else {
                                          tomoController.text = _tomosDisponibles.first['nombre'];
                                        }
                                      });
                                    },
                                    child: Text(
                                      _isCustomTomo ? '← Elegir' : '+ Nuevo',
                                      style: KuroTheme.mono(
                                          fontSize: 8, color: KuroTheme.cyan, fontWeight: FontWeight.w700),
                                    ),
                                  ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            if (!_isCustomTomo && _tomosDisponibles.isNotEmpty)
                              Container(
                                height: 44,
                                decoration: BoxDecoration(
                                    color: KuroTheme.cardLighter,
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(color: KuroTheme.border)),
                                padding: const EdgeInsets.symmetric(horizontal: 12),
                                child: DropdownButtonHideUnderline(
                                  child: DropdownButton<String>(
                                    value: _tomosDisponibles.any((t) => t['nombre'] == tomoController.text)
                                        ? tomoController.text
                                        : _tomosDisponibles.first['nombre'],
                                    isExpanded: true,
                                    dropdownColor: KuroTheme.backgroundSecondary,
                                    icon: const Icon(Icons.arrow_drop_down, color: KuroTheme.cyan),
                                    items: _tomosDisponibles.map((t) {
                                      final nombre = t['nombre'].toString();
                                      return DropdownMenuItem<String>(
                                        value: nombre,
                                        child: Text(
                                          nombre,
                                          style: KuroTheme.mono(
                                              fontSize: 11,
                                              color: Colors.white,
                                              fontWeight: FontWeight.w700),
                                        ),
                                      );
                                    }).toList(),
                                    onChanged: (val) {
                                      if (val != null) {
                                        setState(() => tomoController.text = val);
                                      }
                                    },
                                  ),
                                ),
                              )
                            else
                              Container(
                                height: 44,
                                decoration: BoxDecoration(
                                    color: KuroTheme.cardLighter,
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(color: KuroTheme.border)),
                                padding: const EdgeInsets.symmetric(horizontal: 12),
                                child: TextField(
                                  controller: tomoController,
                                  style: KuroTheme.mono(
                                      fontSize: 12,
                                      color: Colors.white,
                                      fontWeight: FontWeight.w700),
                                  decoration: InputDecoration(
                                    border: InputBorder.none,
                                    hintText: 'Ej. Tomo 01',
                                    hintStyle: KuroTheme.mono(
                                        fontSize: 10, color: KuroTheme.textMuted),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Nº DE CAPÍTULO',
                                style: KuroTheme.mono(
                                    fontSize: 8.5, color: KuroTheme.textMuted)),
                            const SizedBox(height: 6),
                            Container(
                              height: 44,
                              decoration: BoxDecoration(
                                  color: KuroTheme.cardLighter,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: KuroTheme.border)),
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 12),
                              child: TextField(
                                controller: capController,
                                style: KuroTheme.mono(
                                    fontSize: 12,
                                    color: Colors.white,
                                    fontWeight: FontWeight.w700),
                                decoration: InputDecoration(
                                  border: InputBorder.none,
                                  hintText: 'Ej. Cap 01',
                                  hintStyle: KuroTheme.mono(
                                      fontSize: 10, color: KuroTheme.textMuted),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  // NOMBRE DEL CAPÍTULO
                  Text('NOMBRE DEL CAPÍTULO',
                      style: KuroTheme.mono(
                          fontSize: 8.5, color: KuroTheme.textMuted)),
                  const SizedBox(height: 6),
                  Container(
                    height: 44,
                    decoration: BoxDecoration(
                        color: KuroTheme.cardLighter,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: KuroTheme.border)),
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: TextField(
                      controller: nombreCapController,
                      style: GoogleFonts.spaceGrotesk(
                          fontSize: 13,
                          color: Colors.white,
                          fontWeight: FontWeight.w600),
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: 'Ej. El Despertar del Guerrero',
                        hintStyle: KuroTheme.mono(
                            fontSize: 10, color: KuroTheme.textMuted),
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  // URL DE LA PORTADA
                  Text('URL DE PORTADA (OPCIONAL)',
                      style: KuroTheme.mono(
                          fontSize: 8.5, color: KuroTheme.textMuted)),
                  const SizedBox(height: 6),
                  Container(
                    height: 44,
                    decoration: BoxDecoration(
                        color: KuroTheme.cardLighter,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: KuroTheme.border)),
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: TextField(
                      controller: imageUrlController,
                      style: KuroTheme.mono(fontSize: 11, color: KuroTheme.cyan),
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: 'https://ejemplo.com/portada.jpg',
                        hintStyle: KuroTheme.mono(
                            fontSize: 10, color: KuroTheme.textMuted),
                      ),
                    ),
                  ),

                  const SizedBox(height: 14),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('ETIQUETAS & GÉNEROS',
                          style: KuroTheme.mono(
                              fontSize: 8.5, color: KuroTheme.textMuted)),
                      Text('${_selectedTags.length} seleccionados',
                          style: KuroTheme.mono(
                              fontSize: 8.5, color: KuroTheme.cyan)),
                    ],
                  ),
                  const SizedBox(height: 8),

                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: _tags.map((tag) {
                      final isSelected = _selectedTags.contains(tag);
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            if (isSelected) {
                              _selectedTags.remove(tag);
                            } else {
                              _selectedTags.add(tag);
                              _selectedCategory = tag;
                            }
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? KuroTheme.crimson
                                : KuroTheme.cardLighter,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            isSelected ? '$tag ✓' : tag,
                            style: KuroTheme.mono(
                                fontSize: 8.5,
                                color: isSelected
                                    ? Colors.white
                                    : KuroTheme.textGrey,
                                fontWeight: FontWeight.w700),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Card 02. PAQUETE RAW / ENLACE DE ARCHIVO
            Container(
              padding: const EdgeInsets.all(16),
              decoration: KuroTheme.cardDecoration(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.archive,
                              color: KuroTheme.cyan, size: 16),
                          const SizedBox(width: 6),
                          Text('02. ARCHIVO / PAQUETE RAW',
                              style: KuroTheme.mono(
                                  fontSize: 9.5,
                                  color: KuroTheme.textWhite,
                                  fontWeight: FontWeight.w700)),
                        ],
                      ),
                      Text('ENLACE PDF/ZIP',
                          style: KuroTheme.mono(
                              fontSize: 8, color: KuroTheme.textMuted)),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Entrada de URL del PDF / Archivo
                  Text('ENLACE O URL DEL ARCHIVO DE LECTURA',
                      style: KuroTheme.mono(
                          fontSize: 8.5, color: KuroTheme.textMuted)),
                  const SizedBox(height: 6),
                  Container(
                    height: 44,
                    decoration: BoxDecoration(
                        color: KuroTheme.cardLighter,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: KuroTheme.border)),
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: TextField(
                      controller: pdfUrlController,
                      onChanged: (_) => setState(() {}),
                      style: KuroTheme.mono(fontSize: 11, color: Colors.white),
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: 'https://servidor-manga.com/tomo01.pdf',
                        hintStyle: KuroTheme.mono(
                            fontSize: 10, color: KuroTheme.textMuted),
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Estado del archivo
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                        color: KuroTheme.cardLighter,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: KuroTheme.border)),
                    child: Row(
                      children: [
                        Icon(
                            pdfUrlController.text.isNotEmpty
                                ? Icons.check_circle
                                : Icons.cloud_upload_outlined,
                            color: pdfUrlController.text.isNotEmpty
                                ? KuroTheme.cyan
                                : KuroTheme.textMuted,
                            size: 20),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                pdfUrlController.text.isNotEmpty
                                    ? 'Archivo enlazado listo para distribución'
                                    : 'Sin archivo asignado (Se usará enlace estándar)',
                                style: GoogleFonts.spaceGrotesk(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white),
                              ),
                              Text(
                                pdfUrlController.text.isNotEmpty
                                    ? pdfUrlController.text
                                    : 'Ingresa un enlace directo o deja en blanco para demo',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: KuroTheme.mono(
                                    fontSize: 8.5, color: KuroTheme.textMuted),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Card 03. OPCIONES DE PIPELINE
            Container(
              padding: const EdgeInsets.all(16),
              decoration: KuroTheme.cardDecoration(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.tune,
                              color: KuroTheme.purple, size: 16),
                          const SizedBox(width: 6),
                          Text('03. OPCIONES DE PUBLICACIÓN',
                              style: KuroTheme.mono(
                                  fontSize: 9.5,
                                  color: KuroTheme.textWhite,
                                  fontWeight: FontWeight.w700)),
                        ],
                      ),
                      Text('DISTRIBUCIÓN',
                          style: KuroTheme.mono(
                              fontSize: 8, color: KuroTheme.textMuted)),
                    ],
                  ),
                  const SizedBox(height: 12),

                  _buildPipelineRow(
                    icon: Icons.public,
                    title: 'Visibilidad Inmediata',
                    sub: 'Publicar en el feed en vez de borrador',
                    val: _visibilidadInmediata,
                    onChanged: (v) => setState(() => _visibilidadInmediata = v),
                  ),
                  const SizedBox(height: 8),
                  _buildPipelineRow(
                    icon: Icons.notifications_none,
                    title: 'Notificar a Lectores',
                    sub: 'Enviar push a seguidores de la serie',
                    val: _notificarLectores,
                    onChanged: (v) => setState(() => _notificarLectores = v),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Big Action Button
            KuroTheme.primaryButton(
              text: 'PUBLICAR Y SINCRONIZAR EN FIRESTORE',
              icon: Icons.sync,
              isLoading: _isUploading,
              onTap: _publicarCapitulo,
            ),

            const SizedBox(height: 8),

            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.lock_outline,
                        color: KuroTheme.cyan, size: 12),
                    const SizedBox(width: 6),
                    Flexible(
                      child: Text(
                        'Guarda metadatos en Cloud Firestore & sube assets a Kuro CDN Vault',
                        textAlign: TextAlign.center,
                        style: KuroTheme.mono(
                            fontSize: 8.5, color: KuroTheme.textMuted),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildPipelineRow({
    required IconData icon,
    required String title,
    required String sub,
    required bool val,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
          color: KuroTheme.cardLighter, borderRadius: BorderRadius.circular(8)),
      child: Row(
        children: [
          Icon(icon, color: Colors.white, size: 16),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: GoogleFonts.spaceGrotesk(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: Colors.white)),
                Text(sub,
                    style: KuroTheme.body(
                        fontSize: 9.5, color: KuroTheme.textMuted)),
              ],
            ),
          ),
          Switch(
            value: val,
            activeTrackColor: KuroTheme.crimson,
            activeThumbColor: Colors.white,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}
