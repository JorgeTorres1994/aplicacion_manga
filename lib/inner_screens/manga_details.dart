import 'package:aplicacion_manga/inner_screens/OnlineViewScreen.dart';
import 'package:aplicacion_manga/providers/mangas_providers.dart';
import 'package:aplicacion_manga/providers/viewed_providers.dart';
import 'package:aplicacion_manga/providers/wishlist_providers.dart';
import 'package:aplicacion_manga/services/reader_service.dart';
import 'package:aplicacion_manga/theme/kuro_theme.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

class MangaDetails extends StatefulWidget {
  static const routeName = '/MangaDetails';
  const MangaDetails({Key? key}) : super(key: key);

  @override
  State<MangaDetails> createState() => _MangaDetailsState();
}

class _MangaDetailsState extends State<MangaDetails> {
  final TextEditingController _commentController = TextEditingController();
  final List<Map<String, dynamic>> _comments = [];
  bool _isExpandedSynopsis = false;
  int _selectedTab = 0; // 0: Capítulos, 1: Tomos, 2: Comunidad
  double _userRating = 5.0;
  String? _selectedFilterTomo;
  bool _sortDescending = false;

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  void _downloadPDF(String pdfUrl, String title) async {
    try {
      await Permission.storage.request();
      await FlutterDownloader.enqueue(
        url: pdfUrl.isNotEmpty ? pdfUrl : 'https://www.w3.org/WAI/ER/tests/xhtml/testfiles/resources/pdf/dummy.pdf',
        savedDir: '/storage/emulated/0/Download/',
        fileName: '$title.pdf',
        showNotification: true,
        openFileFromNotification: true,
      );
      Fluttertoast.showToast(
        msg: 'Iniciando descarga de $title...',
        backgroundColor: KuroTheme.crimson,
        textColor: Colors.white,
      );
    } catch (e) {
      Fluttertoast.showToast(msg: 'Error al iniciar descarga: $e');
    }
  }

  Future<void> _enviarComentario(String mangaId) async {
    final text = _commentController.text.trim();
    if (text.isEmpty) return;

    final user = FirebaseAuth.instance.currentUser;
    final userName = user?.displayName?.isNotEmpty == true
        ? user!.displayName!
        : (user?.email?.split('@')[0] ?? 'Lector Nocturno');

    try {
      await KuroReaderBackendService.instance.addComment(
        mangaId: mangaId,
        uid: user?.uid ?? 'anonimo',
        userName: userName,
        avatar: user?.photoURL ?? '',
        comentario: text,
        rating: _userRating,
      );

      _commentController.clear();
      Fluttertoast.showToast(msg: 'Comentario publicado');
    } catch (e) {
      Fluttertoast.showToast(msg: 'Error al publicar comentario: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final mangaId = ModalRoute.of(context)!.settings.arguments as String;
    final mangasProvider = Provider.of<MangasProvider>(context);
    final currentManga = mangasProvider.findMangabyId(mangaId);

    final wishlistProvider = Provider.of<WishListProvider>(context);
    final isInWishlist = wishlistProvider.getWishListItems.containsKey(mangaId);

    final viewedProvider = Provider.of<ViewedMangaProvider>(context);

    return Scaffold(
      backgroundColor: KuroTheme.background,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: KuroTheme.background,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'MANGA DETALLES',
          style: KuroTheme.mono(fontSize: 12, color: KuroTheme.textWhite, fontWeight: FontWeight.w700),
        ),
        actions: [
          IconButton(
            icon: Icon(
              isInWishlist ? Icons.bookmark : Icons.bookmark_border,
              color: isInWishlist ? KuroTheme.crimson : Colors.white,
            ),
            onPressed: () {
              wishlistProvider.addRemoveMangasToWishList(mangaId: mangaId);
              Fluttertoast.showToast(
                msg: isInWishlist ? 'Eliminado de favoritos' : 'Guardado en Mi Biblioteca',
                backgroundColor: KuroTheme.cardLighter,
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.share_outlined, color: Colors.white),
            onPressed: () {
              Fluttertoast.showToast(msg: 'Enlace copiado al portapapeles');
            },
          ),
          Container(
            margin: const EdgeInsets.only(right: 14),
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: const Color(0xFFF7728B),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.person, color: Colors.black, size: 20),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 10),

            // Badge superior: KURO EXCLUSIVE • EDICIÓN DELUXE
            Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: KuroTheme.cardLighter,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: KuroTheme.border),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(width: 6, height: 6, decoration: const BoxDecoration(color: KuroTheme.crimson, shape: BoxShape.circle)),
                    const SizedBox(width: 6),
                    Text(
                      'KURO EXCLUSIVE • EDICIÓN DELUXE',
                      style: KuroTheme.mono(fontSize: 8.5, color: KuroTheme.textGrey, fontWeight: FontWeight.w700),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // 3D Poster Cover Card
            Center(
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    width: 200,
                    height: 290,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: KuroTheme.border, width: 2),
                      boxShadow: [
                        BoxShadow(
                          color: KuroTheme.crimson.withValues(alpha: 0.25),
                          blurRadius: 30,
                          offset: const Offset(0, 10),
                        ),
                      ],
                      image: DecorationImage(
                        image: NetworkImage(
                          currentManga.imageUrl.isNotEmpty
                              ? currentManga.imageUrl
                              : 'https://images.unsplash.com/photo-1578632767115-351597cf2477?w=800',
                        ),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 12,
                    left: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.8),
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(color: KuroTheme.cyan.withValues(alpha: 0.6)),
                      ),
                      child: Text(
                        currentManga.type.isNotEmpty ? currentManga.type.toUpperCase() : 'MANGA',
                        style: KuroTheme.mono(fontSize: 9, color: KuroTheme.cyan, fontWeight: FontWeight.w700),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 12,
                    right: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: KuroTheme.crimson,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        currentManga.estado.toUpperCase(),
                        style: KuroTheme.mono(fontSize: 9, color: Colors.white, fontWeight: FontWeight.w800),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 18),

            // Stars & Rank
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.star, color: KuroTheme.gold, size: 14),
                const SizedBox(width: 4),
                Text(
                  '${currentManga.rating > 0 ? currentManga.rating.toStringAsFixed(1) : "5.0"} (${currentManga.numRatings > 0 ? "${currentManga.numRatings} votos" : "Nuevo"})',
                  style: KuroTheme.mono(fontSize: 10, color: Colors.white, fontWeight: FontWeight.w700),
                ),
                const SizedBox(width: 8),
                Text('•', style: KuroTheme.mono(color: KuroTheme.textMuted)),
                const SizedBox(width: 8),
                Text(
                  currentManga.mangaCategoryName.toUpperCase(),
                  style: KuroTheme.mono(fontSize: 10, color: KuroTheme.cyan, fontWeight: FontWeight.w700),
                ),
              ],
            ),

            const SizedBox(height: 8),

            // Title
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                currentManga.title.toUpperCase(),
                textAlign: TextAlign.center,
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                  letterSpacing: 1.1,
                ),
              ),
            ),

            const SizedBox(height: 4),

            Text(
              currentManga.autor.isNotEmpty
                  ? 'Historia & Arte: ${currentManga.autor}'
                  : 'Historia & Arte: Scan Oficial Kuro',
              style: KuroTheme.body(fontSize: 11, color: KuroTheme.textGrey),
            ),

            const SizedBox(height: 12),

            // Genre Chips
            Wrap(
              spacing: 6,
              runSpacing: 6,
              alignment: WrapAlignment.center,
              children: [
                if (currentManga.tags.isNotEmpty)
                  ...currentManga.tags.map((t) => _buildTag(t.toUpperCase()))
                else ...[
                  _buildTag(currentManga.mangaCategoryName.toUpperCase()),
                  _buildTag(currentManga.type.toUpperCase()),
                ],
                if (currentManga.numberPages.isNotEmpty && currentManga.numberPages != '0')
                  _buildTag('${currentManga.numberPages} PÁGINAS'),
              ],
            ),

            const SizedBox(height: 20),

            // Main Action Buttons (Leer & Descargar)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                children: [
                  Expanded(
                    flex: 6,
                    child: GestureDetector(
                      onTap: () {
                        viewedProvider.addMangasToHistory(mangaId: currentManga.id);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (ctx) => OnlineViewScreen(
                              pdfUrl: currentManga.pdfUrl,
                              mangaId: currentManga.id,
                              coverUrl: currentManga.imageUrl,
                              mangaTitle: currentManga.title,
                              chapterTitle: 'Capítulo 01',
                            ),
                          ),
                        );
                      },
                      child: Container(
                        height: 48,
                        decoration: BoxDecoration(
                          gradient: KuroTheme.crimsonGradient,
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: [
                            BoxShadow(
                              color: KuroTheme.crimson.withValues(alpha: 0.4),
                              blurRadius: 14,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.menu_book, color: Colors.white, size: 18),
                            const SizedBox(width: 8),
                            Text(
                              'LEER AHORA',
                              style: GoogleFonts.spaceGrotesk(
                                fontSize: 13,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                                letterSpacing: 0.8,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    flex: 4,
                    child: GestureDetector(
                      onTap: () => _downloadPDF(currentManga.pdfUrl, currentManga.title),
                      child: Container(
                        height: 48,
                        decoration: BoxDecoration(
                          color: KuroTheme.cardLighter,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: KuroTheme.border),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.file_download_outlined, color: Colors.white, size: 18),
                            const SizedBox(width: 6),
                            Text(
                              'DESCARGAR',
                              style: GoogleFonts.spaceGrotesk(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 14),

            // Secondary Action Bar (En Mi Lista / Calificar / Compartir)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildSecondaryAction(
                    icon: isInWishlist ? Icons.bookmark : Icons.bookmark_border,
                    label: 'EN MI LISTA',
                    active: isInWishlist,
                    onTap: () {
                      wishlistProvider.addRemoveMangasToWishList(mangaId: mangaId);
                    },
                  ),
                  _buildSecondaryAction(
                    icon: Icons.chat_bubble_outline,
                    label: 'CALIFICAR',
                    onTap: () {
                      _showRatingDialog(context, mangaId);
                    },
                  ),
                  _buildSecondaryAction(
                    icon: Icons.share_outlined,
                    label: 'COMPARTIR',
                    onTap: () {
                      Fluttertoast.showToast(msg: 'Enlace copiado');
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Card EXPEDIENTE // SINOPSIS
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
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
                            Container(width: 4, height: 12, color: KuroTheme.crimson),
                            const SizedBox(width: 6),
                            Text(
                              'FICHA TÉCNICA // SINOPSIS',
                              style: KuroTheme.mono(fontSize: 9.5, color: KuroTheme.crimson, fontWeight: FontWeight.w700),
                            ),
                          ],
                        ),
                        Text(
                          currentManga.estado.toUpperCase(),
                          style: KuroTheme.mono(fontSize: 8.5, color: KuroTheme.textMuted),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      currentManga.description.isNotEmpty
                          ? currentManga.description
                          : 'Esta obra está disponible en el catálogo de Kuro. Explora sus tomos y capítulos publicados.',
                      style: KuroTheme.body(fontSize: 11.5, color: KuroTheme.textGrey, height: 1.5),
                      maxLines: _isExpandedSynopsis ? null : 3,
                    ),
                    const SizedBox(height: 6),
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          _isExpandedSynopsis = !_isExpandedSynopsis;
                        });
                      },
                      child: Text(
                        _isExpandedSynopsis ? 'PLEGAR SINOPSIS ⌃' : 'DESPLEGAR SINOPSIS ⌵',
                        style: KuroTheme.mono(fontSize: 9, color: KuroTheme.crimson, fontWeight: FontWeight.w700),
                      ),
                    ),
                    const SizedBox(height: 16),
                    // 2x2 Metadata Grid
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: KuroTheme.cardLighter,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              _buildMetaCell('DIRECCIÓN DE LECTURA', 'Derecha a Izquierda (RTL)'),
                              _buildMetaCell('CATEGORÍA', currentManga.mangaCategoryName.isNotEmpty ? currentManga.mangaCategoryName : 'Manga'),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              _buildMetaCell('TIPO / FORMATO', currentManga.type.isNotEmpty ? currentManga.type : 'Digital HD'),
                              _buildMetaCell('AUTOR', currentManga.autor.isNotEmpty ? currentManga.autor : 'Scan Oficial', isCyan: true),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Tab Bar: Capítulos, Tomos, Comunidad
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('mangas')
                  .doc(currentManga.id)
                  .collection('capitulos')
                  .snapshots(),
              builder: (context, capSnap) {
                final totalCaps = capSnap.hasData ? capSnap.data!.docs.length : 0;
                return StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('mangas')
                      .doc(currentManga.id)
                      .collection('tomos')
                      .snapshots(),
                  builder: (context, tomoSnap) {
                    final totalTomos = tomoSnap.hasData ? tomoSnap.data!.docs.length : 0;

                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: KuroTheme.card,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: KuroTheme.border),
                        ),
                        child: Row(
                          children: [
                            _buildTabButton('Capítulos ($totalCaps)', 0),
                            _buildTabButton('Tomos ($totalTomos)', 1),
                            _buildTabButton('Comunidad (${_comments.length + 2})', 2),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),

            const SizedBox(height: 14),

            // Tab 0: Capítulos
            if (_selectedTab == 0) ...[
              if (_selectedFilterTomo != null)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: KuroTheme.purple.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: KuroTheme.purple),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Row(
                            children: [
                              const Icon(Icons.filter_list, size: 14, color: KuroTheme.purple),
                              const SizedBox(width: 6),
                              Text('Filtrando: ', style: KuroTheme.mono(fontSize: 9.5, color: KuroTheme.textMuted)),
                              Expanded(
                                child: Text(
                                  _selectedFilterTomo!,
                                  style: KuroTheme.mono(fontSize: 9.5, color: Colors.white, fontWeight: FontWeight.w700),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        GestureDetector(
                          onTap: () => setState(() => _selectedFilterTomo = null),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: KuroTheme.crimson.withValues(alpha: 0.25),
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(color: KuroTheme.crimson.withValues(alpha: 0.6)),
                            ),
                            child: Text('VER TODOS [X]',
                                style: KuroTheme.mono(fontSize: 8.5, color: Colors.white, fontWeight: FontWeight.w800)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

              // Controles de Orden (ASC / DESC)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('LISTADO DE CAPÍTULOS', style: KuroTheme.mono(fontSize: 8.5, color: KuroTheme.textMuted)),
                    GestureDetector(
                      onTap: () => setState(() => _sortDescending = !_sortDescending),
                      child: Row(
                        children: [
                          Icon(_sortDescending ? Icons.arrow_downward : Icons.arrow_upward, size: 12, color: KuroTheme.cyan),
                          const SizedBox(width: 4),
                          Text(_sortDescending ? 'DESCENDENTE' : 'ASCENDENTE', style: KuroTheme.mono(fontSize: 8.5, color: KuroTheme.cyan, fontWeight: FontWeight.w700)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('mangas')
                    .doc(currentManga.id)
                    .collection('capitulos')
                    .orderBy('numero', descending: _sortDescending)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.all(24),
                        child: CircularProgressIndicator(color: KuroTheme.crimson, strokeWidth: 2),
                      ),
                    );
                  }

                  final docs = snapshot.data?.docs ?? [];
                  var filteredDocs = docs;
                  if (_selectedFilterTomo != null) {
                    filteredDocs = docs.where((d) {
                      final data = d.data() as Map<String, dynamic>;
                      return (data['tomo']?.toString() ?? '') == _selectedFilterTomo;
                    }).toList();
                  }

                  if (filteredDocs.isEmpty) {
                    if (currentManga.pdfUrl.isNotEmpty && _selectedFilterTomo == null) {
                      return Column(
                        children: [
                          _buildChapterItem(
                            '#01',
                            'Capítulo Principal / Obra Completa',
                            'Lectura original integrada • 42 Páginas',
                            isDownloaded: false,
                            currentManga: currentManga,
                            pdfUrl: currentManga.pdfUrl,
                          ),
                        ],
                      );
                    }

                    return Padding(
                      padding: const EdgeInsets.all(24),
                      child: Center(
                        child: Column(
                          children: [
                            const Icon(Icons.menu_book, color: KuroTheme.textMuted, size: 36),
                            const SizedBox(height: 8),
                            Text(
                              _selectedFilterTomo != null
                                  ? 'No hay capítulos en $_selectedFilterTomo'
                                  : 'Aún no hay capítulos publicados para esta serie',
                              style: KuroTheme.body(fontSize: 11, color: KuroTheme.textMuted),
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  return ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: filteredDocs.length,
                    itemBuilder: (context, index) {
                      final data = filteredDocs[index].data() as Map<String, dynamic>;
                      final numStr = data['capituloDisplay']?.toString() ?? data['numero']?.toString() ?? '${index + 1}';
                      final titleStr = data['nombre']?.toString() ?? 'Capítulo $numStr';
                      final tomoStr = data['tomo']?.toString() ?? 'Tomo 01';
                      final pdf = data['pdfUrl']?.toString() ?? currentManga.pdfUrl;
                      final pages = data['numberPages']?.toString() ?? '32';
                      final List<String> paginasList = (data['paginas'] as List?)
                          ?.map((e) => e.toString())
                          .where((s) => s.isNotEmpty)
                          .toList() ?? [];

                      return _buildChapterItem(
                        '#$numStr',
                        titleStr,
                        '$tomoStr • $pages Páginas',
                        isDownloaded: false,
                        currentManga: currentManga,
                        pdfUrl: pdf,
                        tomo: tomoStr,
                        pageImages: paginasList.isNotEmpty ? paginasList : null,
                      );
                    },
                  );
                },
              ),
            ],

            // Tab 1: Tomos
            if (_selectedTab == 1) ...[
              StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('mangas')
                    .doc(currentManga.id)
                    .collection('tomos')
                    .orderBy('numero')
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.all(24),
                        child: CircularProgressIndicator(color: KuroTheme.purple, strokeWidth: 2),
                      ),
                    );
                  }

                  final docs = snapshot.data?.docs ?? [];
                  if (docs.isEmpty) {
                    return Padding(
                      padding: const EdgeInsets.all(24),
                      child: Center(
                        child: Column(
                          children: [
                            const Icon(Icons.collections_bookmark_outlined, color: KuroTheme.textMuted, size: 36),
                            const SizedBox(height: 8),
                            Text('No hay tomos definidos independientemente.',
                                style: GoogleFonts.spaceGrotesk(fontSize: 13, fontWeight: FontWeight.w700, color: Colors.white)),
                            const SizedBox(height: 4),
                            Text('El administrador puede registrar tomos y asociar capítulos desde Kuro Admin Suite.',
                                textAlign: TextAlign.center,
                                style: KuroTheme.body(fontSize: 10.5, color: KuroTheme.textMuted)),
                          ],
                        ),
                      ),
                    );
                  }

                  return ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: docs.length,
                    itemBuilder: (context, index) {
                      final tomo = docs[index].data() as Map<String, dynamic>;
                      final tomoNombre = tomo['nombre']?.toString() ?? 'Tomo ${index + 1}';
                      final tomoNumero = tomo['numero'] is int
                          ? tomo['numero'] as int
                          : (int.tryParse(tomo['numero']?.toString() ?? '') ?? (index + 1));

                      return _buildTomoItem(
                        tomoNombre: tomoNombre,
                        tomoNumero: tomoNumero,
                        mangaId: currentManga.id,
                        onTap: () {
                          setState(() {
                            _selectedFilterTomo = tomoNombre;
                            _selectedTab = 0;
                          });
                        },
                      );
                    },
                  );
                },
              ),
            ],

            // Tab 2: Comunidad
            if (_selectedTab == 2) ...[

            // Section: DISCUSIÓN DE LA COMUNIDAD // RESEÑAS
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
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
                            Container(width: 4, height: 12, color: KuroTheme.crimson),
                            const SizedBox(width: 6),
                            Text(
                              'DISCUSIÓN DE LA COMUNIDAD // RESEÑAS',
                              style: KuroTheme.mono(fontSize: 9.5, color: KuroTheme.crimson, fontWeight: FontWeight.w700),
                            ),
                          ],
                        ),
                        Text(
                          '★ ${currentManga.rating > 0 ? currentManga.rating.toStringAsFixed(1) : "5.0"} / 5.0',
                          style: KuroTheme.mono(fontSize: 9.5, color: KuroTheme.gold, fontWeight: FontWeight.w700),
                        ),
                      ],
                    ),
                    Text('Voz de los lectores en la comunidad Kuro', style: KuroTheme.body(fontSize: 10, color: KuroTheme.textMuted)),

                    const SizedBox(height: 16),

                    // Big Rating Breakdown
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              currentManga.rating > 0 ? currentManga.rating.toStringAsFixed(1) : '5.0',
                              style: GoogleFonts.spaceGrotesk(fontSize: 38, fontWeight: FontWeight.w900, color: Colors.white, height: 1.0),
                            ),
                            Row(
                              children: List.generate(
                                5,
                                (index) => Icon(
                                  index < (currentManga.rating.round()) ? Icons.star : Icons.star_border,
                                  color: KuroTheme.gold,
                                  size: 14,
                                ),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              currentManga.numRatings > 0 ? '${currentManga.numRatings} votos' : 'Sin votos aún',
                              style: KuroTheme.mono(fontSize: 9, color: KuroTheme.textMuted),
                            ),
                          ],
                        ),
                        const SizedBox(width: 20),
                        Expanded(
                          child: Column(
                            children: [
                              _buildRatingBarRow('5★', currentManga.numRatings > 0 ? 0.90 : 0.0, 'Excelentes'),
                              _buildRatingBarRow('3★', currentManga.numRatings > 0 ? 0.08 : 0.0, 'Regulares'),
                              _buildRatingBarRow('1★', currentManga.numRatings > 0 ? 0.02 : 0.0, 'Bajas'),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 18),

                    // Comment Input Box
                    Row(
                      children: [
                        Container(
                          width: 24,
                          height: 24,
                          decoration: const BoxDecoration(color: KuroTheme.crimson, shape: BoxShape.circle),
                          child: Center(child: Text('KU', style: KuroTheme.mono(fontSize: 9, color: Colors.white, fontWeight: FontWeight.w800))),
                        ),
                        const SizedBox(width: 8),
                        Text('Comentar como ', style: KuroTheme.body(fontSize: 11, color: KuroTheme.textGrey)),
                        Text('Lector Nocturno', style: KuroTheme.mono(fontSize: 11, color: Colors.white, fontWeight: FontWeight.w700)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Container(
                      height: 44,
                      decoration: KuroTheme.cardDecoration(color: KuroTheme.cardLighter),
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _commentController,
                              style: KuroTheme.body(color: Colors.white, fontSize: 12),
                              decoration: InputDecoration(
                                border: InputBorder.none,
                                hintText: 'Escribe tu teoría o comentario sobre el tomo...',
                                hintStyle: KuroTheme.body(color: KuroTheme.textMuted, fontSize: 11),
                              ),
                            ),
                          ),
                          GestureDetector(
                            onTap: () => _enviarComentario(mangaId),
                            child: Container(
                              width: 30,
                              height: 30,
                              decoration: BoxDecoration(color: KuroTheme.crimson, borderRadius: BorderRadius.circular(6)),
                              child: const Icon(Icons.send, color: Colors.white, size: 14),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Stream de Comentarios Reales de la Comunidad
                    StreamBuilder<List<Map<String, dynamic>>>(
                      stream: KuroReaderBackendService.instance.streamComments(currentManga.id),
                      builder: (context, snapshot) {
                        final liveComments = snapshot.data ?? [];

                        if (liveComments.isEmpty) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 20),
                            child: Center(
                              child: Column(
                                children: [
                                  const Icon(Icons.chat_bubble_outline, color: KuroTheme.textMuted, size: 32),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Aún no hay comentarios en esta obra.',
                                    style: GoogleFonts.spaceGrotesk(fontSize: 12.5, fontWeight: FontWeight.w700, color: Colors.white),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '¡Sé el primero en publicar una opinión o reseña!',
                                    style: KuroTheme.body(fontSize: 10.5, color: KuroTheme.textMuted),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }

                        return ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: liveComments.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 12),
                          itemBuilder: (context, index) {
                            final c = liveComments[index];
                            final autor = c['autor']?.toString() ?? 'Lector';
                            final comentario = c['comentario']?.toString() ?? '';
                            final clan = c['clan']?.toString() ?? 'CLAN CARMESÍ';
                            final avatar = c['avatar']?.toString() ?? '';
                            final likes = c['likes']?.toString() ?? '1';

                            return _buildReviewCard(
                              avatarUrl: avatar,
                              userName: autor,
                              clan: clan,
                              clanColor: clan.contains('SOMBRA') ? KuroTheme.cardLighter : KuroTheme.crimson,
                              timeAgo: 'Reciente • Verificado',
                              comment: comentario,
                              likes: likes,
                              replies: '0 respuestas',
                            );
                          },
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildTag(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: KuroTheme.cardLighter,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: KuroTheme.border),
      ),
      child: Text(text, style: KuroTheme.mono(fontSize: 8.5, color: KuroTheme.textGrey, fontWeight: FontWeight.w700)),
    );
  }

  Widget _buildSecondaryAction({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    bool active = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        children: [
          Icon(icon, color: active ? KuroTheme.crimson : KuroTheme.textGrey, size: 16),
          const SizedBox(width: 5),
          Text(
            label,
            style: KuroTheme.mono(
              fontSize: 9.5,
              color: active ? KuroTheme.crimson : KuroTheme.textGrey,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetaCell(String label, String value, {bool isCyan = false}) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: KuroTheme.mono(fontSize: 7.5, color: KuroTheme.textMuted)),
          const SizedBox(height: 2),
          Text(
            value,
            style: GoogleFonts.spaceGrotesk(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: isCyan ? KuroTheme.cyan : Colors.white,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildTabButton(String title, int index) {
    final isSelected = _selectedTab == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedTab = index),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? KuroTheme.crimson : Colors.transparent,
            borderRadius: BorderRadius.circular(7),
          ),
          child: Center(
            child: Text(
              title,
              style: GoogleFonts.spaceGrotesk(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: isSelected ? Colors.white : KuroTheme.textGrey,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildChapterItem(
    String num,
    String title,
    String sub, {
    required bool isDownloaded,
    required dynamic currentManga,
    String? pdfUrl,
    String? tomo,
    List<String>? pageImages,
  }) {
    final viewedProvider = Provider.of<ViewedMangaProvider>(context, listen: false);
    final targetPdf = (pdfUrl != null && pdfUrl.isNotEmpty) ? pdfUrl : currentManga.pdfUrl;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      child: GestureDetector(
        onTap: () {
          viewedProvider.addMangasToHistory(mangaId: currentManga.id);
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (ctx) => OnlineViewScreen(
                pdfUrl: targetPdf,
                pageImages: pageImages,
                mangaId: currentManga.id,
                coverUrl: currentManga.imageUrl,
                mangaTitle: '${currentManga.title} $num',
                chapterTitle: title,
                tomoTitle: tomo,
              ),
            ),
          );
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: KuroTheme.cardDecoration(),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                decoration: BoxDecoration(
                  color: KuroTheme.purple.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: KuroTheme.purple.withValues(alpha: 0.3)),
                ),
                child: Text(
                  num,
                  style: KuroTheme.mono(fontSize: 10, color: KuroTheme.purple, fontWeight: FontWeight.w700),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: GoogleFonts.spaceGrotesk(fontSize: 13, fontWeight: FontWeight.w700, color: Colors.white), maxLines: 1),
                    Text(sub, style: KuroTheme.body(fontSize: 10, color: KuroTheme.textMuted), maxLines: 1),
                  ],
                ),
              ),
              if (isDownloaded)
                const Icon(Icons.check_circle_outline, color: KuroTheme.cyan, size: 18)
              else if (targetPdf.isNotEmpty)
                IconButton(
                  icon: const Icon(Icons.file_download_outlined, color: KuroTheme.textGrey, size: 18),
                  onPressed: () => _downloadPDF(targetPdf, '${currentManga.title} $num'),
                ),
              const SizedBox(width: 4),
              const Icon(Icons.arrow_forward_ios, color: KuroTheme.textMuted, size: 12),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTomoItem({
    required String tomoNombre,
    required int tomoNumero,
    required String mangaId,
    required VoidCallback onTap,
  }) {
    return FutureBuilder<QuerySnapshot>(
      future: FirebaseFirestore.instance
          .collection('mangas')
          .doc(mangaId)
          .collection('capitulos')
          .where('tomo', isEqualTo: tomoNombre)
          .get(),
      builder: (context, snap) {
        final capCount = snap.hasData ? snap.data!.docs.length : 0;
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: KuroTheme.cardDecoration(),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: KuroTheme.purple.withValues(alpha: 0.18),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: KuroTheme.purple.withValues(alpha: 0.4)),
                  ),
                  child: const Icon(Icons.auto_stories, color: KuroTheme.purple, size: 22),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: KuroTheme.crimson.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              'VOL. $tomoNumero',
                              style: KuroTheme.mono(fontSize: 8.5, color: KuroTheme.crimson, fontWeight: FontWeight.w800),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            snap.connectionState == ConnectionState.waiting
                                ? '...'
                                : '$capCount ${capCount == 1 ? 'Capítulo' : 'Capítulos'}',
                            style: KuroTheme.mono(fontSize: 9, color: KuroTheme.textMuted),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        tomoNombre,
                        style: GoogleFonts.spaceGrotesk(fontSize: 14, fontWeight: FontWeight.w700, color: Colors.white),
                      ),
                    ],
                  ),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: KuroTheme.cardLighter,
                    side: const BorderSide(color: KuroTheme.border),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  ),
                  onPressed: onTap,
                  child: Row(
                    children: [
                      Text('CAPÍTULOS', style: KuroTheme.mono(fontSize: 8.5, color: KuroTheme.cyan, fontWeight: FontWeight.w700)),
                      const SizedBox(width: 4),
                      const Icon(Icons.arrow_forward_ios, size: 10, color: KuroTheme.cyan),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildRatingBarRow(String star, double fill, String percentage) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Text(star, style: KuroTheme.mono(fontSize: 8.5, color: KuroTheme.textMuted)),
          const SizedBox(width: 6),
          Expanded(
            child: Container(
              height: 4,
              decoration: BoxDecoration(color: KuroTheme.cardLighter, borderRadius: BorderRadius.circular(2)),
              child: FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: fill,
                child: Container(
                  decoration: BoxDecoration(color: KuroTheme.crimson, borderRadius: BorderRadius.circular(2)),
                ),
              ),
            ),
          ),
          const SizedBox(width: 6),
          Text(percentage, style: KuroTheme.mono(fontSize: 8.5, color: KuroTheme.textMuted)),
        ],
      ),
    );
  }

  Widget _buildReviewCard({
    required String avatarUrl,
    required String userName,
    required String clan,
    required Color clanColor,
    required String timeAgo,
    required String comment,
    required String likes,
    required String replies,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: KuroTheme.cardLighter,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: KuroTheme.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: avatarUrl.isNotEmpty
                    ? Image.network(
                        avatarUrl,
                        width: 28,
                        height: 28,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          width: 28,
                          height: 28,
                          color: KuroTheme.crimson,
                          child: const Icon(Icons.person, size: 16, color: Colors.white),
                        ),
                      )
                    : Container(
                        width: 28,
                        height: 28,
                        color: KuroTheme.crimson,
                        child: const Icon(Icons.person, size: 16, color: Colors.white),
                      ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(userName, style: GoogleFonts.spaceGrotesk(fontSize: 12, fontWeight: FontWeight.w700, color: Colors.white)),
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                          decoration: BoxDecoration(color: clanColor.withValues(alpha: 0.3), borderRadius: BorderRadius.circular(3)),
                          child: Text(clan, style: KuroTheme.mono(fontSize: 7.5, color: Colors.white, fontWeight: FontWeight.w700)),
                        ),
                      ],
                    ),
                    Text(timeAgo, style: KuroTheme.mono(fontSize: 8, color: KuroTheme.textMuted)),
                  ],
                ),
              ),
              Row(children: List.generate(5, (i) => const Icon(Icons.star, color: KuroTheme.gold, size: 10))),
            ],
          ),
          const SizedBox(height: 8),
          Text(comment, style: KuroTheme.body(fontSize: 11, color: KuroTheme.textGrey, height: 1.4)),
          const SizedBox(height: 10),
          Row(
            children: [
              const Icon(Icons.favorite_border, color: KuroTheme.textMuted, size: 14),
              const SizedBox(width: 4),
              Text(likes, style: KuroTheme.mono(fontSize: 9, color: KuroTheme.textMuted)),
              const SizedBox(width: 14),
              const Icon(Icons.chat_bubble_outline, color: KuroTheme.textMuted, size: 14),
              const SizedBox(width: 4),
              Text(replies, style: KuroTheme.mono(fontSize: 9, color: KuroTheme.textMuted)),
              const Spacer(),
              Text('Verificado', style: KuroTheme.mono(fontSize: 9, color: KuroTheme.cyan)),
            ],
          ),
        ],
      ),
    );
  }

  void _showRatingDialog(BuildContext context, String mangaId) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: KuroTheme.card,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('CALIFICAR OBRA', style: KuroTheme.mono(fontSize: 12, color: KuroTheme.crimson)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RatingBar.builder(
              initialRating: _userRating,
              minRating: 1,
              direction: Axis.horizontal,
              allowHalfRating: true,
              itemCount: 5,
              itemPadding: const EdgeInsets.symmetric(horizontal: 4.0),
              itemBuilder: (context, _) => const Icon(Icons.star, color: KuroTheme.gold),
              onRatingUpdate: (rating) {
                setState(() => _userRating = rating);
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () async {
              final user = FirebaseAuth.instance.currentUser;
              if (user != null) {
                await KuroReaderBackendService.instance.rateManga(
                  mangaId: mangaId,
                  uid: user.uid,
                  rating: _userRating,
                );
                Fluttertoast.showToast(msg: '¡Calificación registrada con éxito!');
              }
              Navigator.pop(ctx);
            },
            child: Text('GUARDAR', style: KuroTheme.mono(fontSize: 12, color: KuroTheme.crimson)),
          ),
        ],
      ),
    );
  }
}
