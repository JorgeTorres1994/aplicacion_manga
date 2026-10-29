import 'package:aplicacion_manga/inner_screens/manga_details.dart';
import 'package:aplicacion_manga/models/mangas_models.dart';
import 'package:aplicacion_manga/providers/mangas_providers.dart';
import 'package:aplicacion_manga/theme/kuro_theme.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class AdminPaginaCategorias extends StatefulWidget {
  const AdminPaginaCategorias({Key? key}) : super(key: key);

  @override
  State<AdminPaginaCategorias> createState() => _AdminPaginaCategoriasState();
}

class _AdminPaginaCategoriasState extends State<AdminPaginaCategorias> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedFilter = 'POPULARES';
  bool _isSearching = false;
  String _searchTab = 'TODOS';

  final List<Map<String, dynamic>> _generos = [
    {
      'title': 'SHONEN',
      'kanji': '少年',
      'tag': 'ACCIÓN',
      'tagColor': KuroTheme.crimson,
      'desc': 'Acción / Aventura',
      'count': '+1,420 Obras',
      'image': 'https://images.unsplash.com/photo-1578632767115-351597cf2477?w=800',
    },
    {
      'title': 'SEINEN',
      'kanji': '青年',
      'tag': 'MADURO',
      'tagColor': KuroTheme.cardLighter,
      'desc': 'Maduro / Psicológico',
      'count': '+890 Obras',
      'image': 'https://images.unsplash.com/photo-1607604276583-eef5d076aa5f?w=800',
    },
    {
      'title': 'CYBERPUNK',
      'kanji': '電脳',
      'tag': 'SCI-FI',
      'tagColor': KuroTheme.cyan,
      'desc': 'Sci-Fi / Distopía',
      'count': '+415 Obras',
      'image': 'https://img.europapress.es/fotoweb/fotonoticia_20180210183601_1200.jpg',
    },
    {
      'title': 'GORE & TERROR',
      'kanji': 'ホラー',
      'tag': 'HORROR',
      'tagColor': KuroTheme.crimson,
      'desc': 'Sobrenatural / Horror',
      'count': '+320 Obras',
      'image': 'https://cdn.shopify.com/s/files/1/0399/1833/8203/files/broly-dragon-ball_2048x2048.jpg?v=1616868885',
    },
    {
      'title': 'FANTASÍA',
      'kanji': '異世界',
      'tag': 'MAGIA',
      'tagColor': KuroTheme.purple,
      'desc': 'Isekai / Aventura',
      'count': '+1,150 Obras',
      'image': 'https://e.rpp-noticias.io/xlarge/2018/11/22/484448_715070.jpg',
    },
    {
      'title': 'ROMANCE',
      'kanji': '恋愛',
      'tag': 'DRAMA',
      'tagColor': KuroTheme.crimson,
      'desc': 'Sentimental / Vida',
      'count': '+640 Obras',
      'image': 'https://images.unsplash.com/photo-1578632767115-351597cf2477?w=800',
    },
    {
      'title': 'MECHA',
      'kanji': '機甲',
      'tag': 'TÁCTICO',
      'tagColor': KuroTheme.cardLighter,
      'desc': 'Post-Apo / Supervivencia',
      'count': '+210 Obras',
      'image': 'https://images.unsplash.com/photo-1607604276583-eef5d076aa5f?w=800',
    },
    {
      'title': 'SLICE OF LIFE',
      'kanji': '日常',
      'tag': 'SEIDAN',
      'tagColor': KuroTheme.cardLighter,
      'desc': 'Atmósfera / Vida Cotidiana',
      'count': '+480 Obras',
      'image': 'https://img.europapress.es/fotoweb/fotonoticia_20180210183601_1200.jpg',
    },
  ];

  final List<String> _recentSearches = [
    'Chainsaw Man ↗',
    'Solo Leveling ↗',
    'Vagabond ↗',
    'Monster ↗',
    'Ghost in Cyber ↗',
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final mangasProvider = Provider.of<MangasProvider>(context);

    List<MangasModels> searchResults = [];
    if (_searchController.text.trim().isNotEmpty) {
      searchResults = mangasProvider.searchQuery(_searchController.text.trim());
    }

    return Scaffold(
      backgroundColor: KuroTheme.background,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Bar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: 'KURO ',
                            style: GoogleFonts.spaceGrotesk(
                              fontSize: 22,
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                              letterSpacing: 2,
                            ),
                          ),
                          TextSpan(
                            text: '/ ',
                            style: GoogleFonts.spaceGrotesk(
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              color: KuroTheme.crimson,
                            ),
                          ),
                          TextSpan(
                            text: '黒',
                            style: GoogleFonts.notoSansJp(
                              fontSize: 18,
                              fontWeight: FontWeight.w900,
                              color: KuroTheme.crimson,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Row(
                      children: [
                        Container(
                          width: 38,
                          height: 38,
                          decoration: BoxDecoration(
                            color: KuroTheme.card,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: KuroTheme.border),
                          ),
                          child: const Icon(Icons.notifications_none, color: KuroTheme.textWhite, size: 18),
                        ),
                        const SizedBox(width: 10),
                        Container(
                          width: 38,
                          height: 38,
                          decoration: BoxDecoration(
                            color: const Color(0xFFF7728B),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(Icons.person, color: Colors.black, size: 22),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Title Section
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(width: 4, height: 12, color: KuroTheme.crimson),
                        const SizedBox(width: 6),
                        Text(
                          'ÍNDICE MODULAR // カテゴリ',
                          style: KuroTheme.mono(fontSize: 9.5, color: KuroTheme.crimson, fontWeight: FontWeight.w700),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text('EXPLORAR', style: KuroTheme.title(fontSize: 28)),
                    const SizedBox(height: 4),
                    Text(
                      'Descubre nuevos mangas, manhwas y cómics por demografía, género y temáticas.',
                      style: KuroTheme.body(fontSize: 12, color: KuroTheme.textGrey),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Search Bar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Container(
                  height: 48,
                  decoration: KuroTheme.cardDecoration(),
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  child: Row(
                    children: [
                      const Icon(Icons.search, color: KuroTheme.crimson, size: 20),
                      const SizedBox(width: 10),
                      Expanded(
                        child: TextField(
                          controller: _searchController,
                          onChanged: (val) {
                            setState(() {
                              _isSearching = val.trim().isNotEmpty;
                            });
                          },
                          style: KuroTheme.body(color: Colors.white, fontSize: 13),
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            hintText: 'Buscar mangas, autores, tags o scans...',
                            hintStyle: KuroTheme.body(color: KuroTheme.textMuted, fontSize: 12.5),
                          ),
                        ),
                      ),
                      if (_searchController.text.isNotEmpty)
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              _searchController.clear();
                              _isSearching = false;
                            });
                          },
                          child: const Icon(Icons.close, color: KuroTheme.textMuted, size: 18),
                        )
                      else
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: KuroTheme.cardLighter,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Icon(Icons.tune, color: KuroTheme.textGrey, size: 16),
                        ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 14),

              // IF USER IS SEARCHING -> SHOW INTERACTIVE SEARCH RESULTS (Matching Diseños 5)
              if (_isSearching) ...[
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(width: 6, height: 6, decoration: const BoxDecoration(color: KuroTheme.crimson, shape: BoxShape.circle)),
                          const SizedBox(width: 6),
                          Text(
                            '${searchResults.length} MANGAS ENCONTRADOS',
                            style: KuroTheme.mono(fontSize: 9.5, color: KuroTheme.textWhite, fontWeight: FontWeight.w700),
                          ),
                        ],
                      ),
                      Text('LATENCIA // 18ms', style: KuroTheme.mono(fontSize: 9, color: KuroTheme.textMuted)),
                    ],
                  ),
                ),

                const SizedBox(height: 12),

                // Search Filter Tabs
                SizedBox(
                  height: 32,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    children: ['TODOS', 'MANGAS', 'EN EMISIÓN', 'COMPLETADOS'].map((tab) {
                      final isSelected = _searchTab == tab;
                      return GestureDetector(
                        onTap: () => setState(() => _searchTab = tab),
                        child: Container(
                          margin: const EdgeInsets.only(right: 8),
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
                          decoration: BoxDecoration(
                            color: isSelected ? KuroTheme.crimson : KuroTheme.card,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: isSelected ? KuroTheme.crimson : KuroTheme.border),
                          ),
                          child: Center(
                            child: Text(
                              tab,
                              style: KuroTheme.mono(
                                fontSize: 9.5,
                                color: isSelected ? Colors.white : KuroTheme.textGrey,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),

                const SizedBox(height: 16),

                // Search Results List
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: searchResults.length,
                  itemBuilder: (context, index) {
                    final manga = searchResults[index];
                    return GestureDetector(
                      onTap: () {
                        Navigator.pushNamed(context, MangaDetails.routeName, arguments: manga.id);
                      },
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(12),
                        decoration: KuroTheme.cardDecoration(),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Stack(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.network(
                                    manga.imageUrl.isNotEmpty ? manga.imageUrl : 'https://images.unsplash.com/photo-1607604276583-eef5d076aa5f?w=800',
                                    width: 70,
                                    height: 90,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                Positioned(
                                  top: 4,
                                  left: 4,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: KuroTheme.crimson,
                                      borderRadius: BorderRadius.circular(3),
                                    ),
                                    child: Text('HOT', style: KuroTheme.mono(fontSize: 7.5, color: Colors.white, fontWeight: FontWeight.w800)),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: Text(
                                          manga.title,
                                          style: GoogleFonts.spaceGrotesk(fontSize: 15, fontWeight: FontWeight.w800, color: Colors.white),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      const Icon(Icons.bookmark_border, color: KuroTheme.textMuted, size: 18),
                                    ],
                                  ),
                                  const SizedBox(height: 2),
                                  Text('Tatsuki Fujimoto / SHUEISHA', style: KuroTheme.body(fontSize: 10.5, color: KuroTheme.textMuted)),
                                  const SizedBox(height: 6),
                                  Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                        decoration: BoxDecoration(color: KuroTheme.cardLighter, borderRadius: BorderRadius.circular(4)),
                                        child: Text(
                                          manga.type.isNotEmpty ? manga.type : 'ACCIÓN // GORE',
                                          style: KuroTheme.mono(fontSize: 8, color: KuroTheme.textGrey, fontWeight: FontWeight.w700),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Text('Emisión • Cap. 164', style: KuroTheme.mono(fontSize: 8.5, color: KuroTheme.textMuted)),
                                    ],
                                  ),
                                  const SizedBox(height: 6),
                                  Row(
                                    children: [
                                      const Icon(Icons.star, color: KuroTheme.gold, size: 11),
                                      const SizedBox(width: 4),
                                      Text('4.95 (38.2k)', style: KuroTheme.mono(fontSize: 8.5, color: Colors.white)),
                                      const SizedBox(width: 8),
                                      Text('• Vol. 17 RAW', style: KuroTheme.mono(fontSize: 8.5, color: KuroTheme.cyan)),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),

                const SizedBox(height: 16),

                // Registros Recientes
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.history, color: KuroTheme.textMuted, size: 14),
                          const SizedBox(width: 6),
                          Text('REGISTROS RECIENTES', style: KuroTheme.mono(fontSize: 9.5, color: KuroTheme.textMuted, fontWeight: FontWeight.w700)),
                        ],
                      ),
                      Text('LIMPIAR', style: KuroTheme.mono(fontSize: 9, color: KuroTheme.textMuted)),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _recentSearches.map((term) {
                      return GestureDetector(
                        onTap: () {
                          _searchController.text = term.replaceAll(' ↗', '');
                          setState(() {
                            _isSearching = true;
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: KuroTheme.card,
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: KuroTheme.border),
                          ),
                          child: Text(term, style: KuroTheme.mono(fontSize: 9.5, color: KuroTheme.textGrey)),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ] else ...[
                // ELSE: SHOW STANDARD EXPLORE & GENRES (Matching Diseños 4)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    children: [
                      _buildPill('🔥 MÁS POPULARES', 'POPULARES'),
                      const SizedBox(width: 8),
                      _buildPill('✨ NUEVOS', 'NUEVOS'),
                      const SizedBox(width: 8),
                      _buildPill('✅ COMPLETADOS', 'COMPLETADOS'),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // GÉNEROS CLAVE Header
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('GÉNEROS CLAVE', style: KuroTheme.title(fontSize: 18)),
                      Row(
                        children: [
                          Text('[08 CANALES]', style: KuroTheme.mono(fontSize: 9, color: KuroTheme.crimson, fontWeight: FontWeight.w700)),
                          const SizedBox(width: 6),
                          Text('ORDENAR // FRECUENCIA', style: KuroTheme.mono(fontSize: 8.5, color: KuroTheme.textMuted)),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 12),

                // 2-Column Grid of 8 Genres
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 0.82,
                    ),
                    itemCount: _generos.length,
                    itemBuilder: (context, index) {
                      final gen = _generos[index];
                      return GestureDetector(
                        onTap: () {
                          // Filtrar mangas por este género
                          _searchController.text = gen['title'] as String;
                          setState(() {
                            _isSearching = true;
                          });
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: KuroTheme.border),
                            image: DecorationImage(
                              image: NetworkImage(gen['image'] as String),
                              fit: BoxFit.cover,
                            ),
                          ),
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(14),
                              gradient: const LinearGradient(
                                colors: [
                                  Colors.transparent,
                                  Color(0x80090A0E),
                                  Color(0xF0090A0E),
                                ],
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2.5),
                                  decoration: BoxDecoration(
                                    color: (gen['tagColor'] as Color).withValues(alpha: 0.85),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    gen['tag'] as String,
                                    style: KuroTheme.mono(fontSize: 7.5, color: Colors.white, fontWeight: FontWeight.w800),
                                  ),
                                ),
                                const Spacer(),
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        gen['title'] as String,
                                        style: GoogleFonts.spaceGrotesk(fontSize: 16, fontWeight: FontWeight.w900, color: Colors.white),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    Text(gen['kanji'] as String, style: GoogleFonts.notoSansJp(fontSize: 11, color: KuroTheme.crimson)),
                                  ],
                                ),
                                const SizedBox(height: 2),
                                Text(gen['desc'] as String, style: KuroTheme.body(fontSize: 9.5, color: KuroTheme.textGrey)),
                                const SizedBox(height: 6),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(gen['count'] as String, style: KuroTheme.mono(fontSize: 9, color: KuroTheme.cyan)),
                                    const Icon(Icons.arrow_forward, color: Colors.white, size: 14),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),

                const SizedBox(height: 24),

                // Curaduría Editorial Card
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.verified, color: KuroTheme.crimson, size: 15),
                          const SizedBox(width: 6),
                          Text('CURADURÍA EDITORIAL', style: KuroTheme.mono(fontSize: 9.5, color: KuroTheme.textWhite, fontWeight: FontWeight.w700)),
                        ],
                      ),
                      Text('VER TODO', style: KuroTheme.mono(fontSize: 9, color: KuroTheme.crimson, fontWeight: FontWeight.w700)),
                    ],
                  ),
                ),

                const SizedBox(height: 10),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: KuroTheme.card,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: KuroTheme.border),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            KuroTheme.badge(text: 'SELECCIÓN EDITORIAL // 01', bgColor: KuroTheme.crimson),
                            const SizedBox(width: 8),
                            Text('SELECCIÓN ANUAL', style: KuroTheme.mono(fontSize: 8.5, color: KuroTheme.textMuted)),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'Obras Maestras del Manga Psicológico',
                          style: GoogleFonts.spaceGrotesk(fontSize: 16, fontWeight: FontWeight.w800, color: Colors.white),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '12 títulos de culto que desafían la percepción de la mente humana y la realidad.',
                          style: KuroTheme.body(fontSize: 11, color: KuroTheme.textGrey),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Container(
                              width: 22,
                              height: 22,
                              decoration: const BoxDecoration(color: Color(0xFFF7728B), shape: BoxShape.circle),
                              child: Center(child: Text('1', style: KuroTheme.mono(fontSize: 9, color: Colors.black))),
                            ),
                            Container(
                              width: 22,
                              height: 22,
                              decoration: const BoxDecoration(color: KuroTheme.purple, shape: BoxShape.circle),
                              child: Center(child: Text('2', style: KuroTheme.mono(fontSize: 9, color: Colors.white))),
                            ),
                            Container(
                              width: 22,
                              height: 22,
                              decoration: const BoxDecoration(color: KuroTheme.cyan, shape: BoxShape.circle),
                              child: Center(child: Text('3', style: KuroTheme.mono(fontSize: 9, color: Colors.black))),
                            ),
                            const SizedBox(width: 8),
                            Text('+9 MANGAS', style: KuroTheme.mono(fontSize: 9, color: KuroTheme.textMuted, fontWeight: FontWeight.w700)),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Kuro Manga Awards 2025 Banner
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: KuroTheme.cardDecoration(color: const Color(0xFF161521)),
                    child: Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(color: KuroTheme.purple, borderRadius: BorderRadius.circular(10)),
                          child: const Icon(Icons.stars, color: Colors.white, size: 22),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('KURO MANGA AWARDS 2025', style: KuroTheme.mono(fontSize: 9.5, color: Colors.white, fontWeight: FontWeight.w700)),
                              Text('Los favoritos de la comunidad y del jurado editorial.', style: KuroTheme.body(fontSize: 10, color: KuroTheme.textGrey)),
                            ],
                          ),
                        ),
                        const Icon(Icons.arrow_forward_ios, color: KuroTheme.textMuted, size: 14),
                      ],
                    ),
                  ),
                ),
              ],

              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPill(String title, String id) {
    final isSelected = _selectedFilter == id;
    return GestureDetector(
      onTap: () => setState(() => _selectedFilter = id),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? KuroTheme.crimson : KuroTheme.card,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: isSelected ? KuroTheme.crimson : KuroTheme.border),
        ),
        child: Text(
          title,
          style: KuroTheme.mono(
            fontSize: 9,
            color: isSelected ? Colors.white : KuroTheme.textGrey,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}
