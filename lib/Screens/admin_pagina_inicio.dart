import 'package:aplicacion_manga/Screens/admin/admin_overview_screen.dart';
import 'package:aplicacion_manga/inner_screens/manga_details.dart';
import 'package:aplicacion_manga/inner_screens/OnlineViewScreen.dart';
import 'package:aplicacion_manga/providers/mangas_providers.dart';
import 'package:aplicacion_manga/providers/wishlist_providers.dart';
import 'package:aplicacion_manga/services/reader_service.dart';
import 'package:aplicacion_manga/theme/kuro_theme.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class AdminPaginaInicio extends StatefulWidget {
  const AdminPaginaInicio({Key? key}) : super(key: key);

  @override
  State<AdminPaginaInicio> createState() => _AdminPaginaInicioState();
}

class _AdminPaginaInicioState extends State<AdminPaginaInicio> {
  String _selectedCategory = 'TODOS';
  String _userRole = 'reader';
  String _userName = 'OPERADOR_99';

  final List<String> _categories = [
    'TODOS',
    'SHONEN OSCURO',
    'CYBERPUNK',
    'SEINEN',
    'GORE',
    'MECHA',
    'ROMANCE'
  ];

  @override
  void initState() {
    super.initState();
    _loadUserRole();
  }

  Future<void> _loadUserRole() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      if (doc.exists) {
        setState(() {
          _userRole = doc.data()?['rol'] ?? 'reader';
          _userName = doc.data()?['usuario'] ?? user.email?.split('@')[0] ?? 'OPERADOR_99';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final mangasProvider = Provider.of<MangasProvider>(context);
    final allMangas = mangasProvider.getMangas;
    final wishlistProvider = Provider.of<WishListProvider>(context);
    final featuredManga = allMangas.isNotEmpty ? allMangas.first : null;
    final isFeaturedInWishlist = featuredManga != null &&
        wishlistProvider.getWishListItems.containsKey(featuredManga.id);

    return Scaffold(
      backgroundColor: KuroTheme.background,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Top Bar: KURO / 黒 + Notifications + Avatar / Admin Switch
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
                        // Botón de acceso a Admin Suite (si es admin o acceso rápido)
                        if (_userRole == 'admin' || _userName.toLowerCase().contains('admin'))
                          GestureDetector(
                            onTap: () {
                              Navigator.push(context, MaterialPageRoute(builder: (c) => const KuroAdminOverviewScreen()));
                            },
                            child: Container(
                              margin: const EdgeInsets.only(right: 10),
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: KuroTheme.purple.withValues(alpha: 0.25),
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(color: KuroTheme.purple),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.shield, color: KuroTheme.purple, size: 12),
                                  const SizedBox(width: 4),
                                  Text('SUITE', style: KuroTheme.mono(fontSize: 9, color: Colors.white)),
                                ],
                              ),
                            ),
                          ),
                        // Notificaciones con punto rojo
                        Stack(
                          clipBehavior: Clip.none,
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
                            Positioned(
                              top: 6,
                              right: 6,
                              child: Container(
                                width: 7,
                                height: 7,
                                decoration: const BoxDecoration(
                                  color: KuroTheme.crimson,
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(width: 10),
                        // Avatar
                        Container(
                          width: 38,
                          height: 38,
                          decoration: BoxDecoration(
                            color: const Color(0xFFF7728B),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: KuroTheme.crimson, width: 1.5),
                          ),
                          child: const Icon(Icons.person, color: Colors.black, size: 22),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // 2. Subheader
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 6,
                              height: 6,
                              decoration: const BoxDecoration(
                                color: KuroTheme.crimson,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'KONNICHIWA // $_userName'.toUpperCase(),
                              style: KuroTheme.mono(
                                fontSize: 9.5,
                                fontWeight: FontWeight.w700,
                                color: KuroTheme.textWhite,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'SYNC 12M ATRÁS • FEED GLOBAL',
                          style: KuroTheme.mono(
                            fontSize: 8.5,
                            color: KuroTheme.textMuted,
                          ),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: KuroTheme.card,
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(color: KuroTheme.border),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.bolt, color: KuroTheme.cyan, size: 12),
                          const SizedBox(width: 2),
                          Text('V.4.2', style: KuroTheme.mono(fontSize: 9.5, color: KuroTheme.cyan, fontWeight: FontWeight.w700)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // 3. Category Filter Pills
              SizedBox(
                height: 34,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: _categories.length,
                  itemBuilder: (context, index) {
                    final cat = _categories[index];
                    final isSelected = _selectedCategory == cat;

                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedCategory = cat;
                        });
                      },
                      child: Container(
                        margin: const EdgeInsets.only(right: 8),
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                        decoration: BoxDecoration(
                          color: isSelected ? KuroTheme.crimson : KuroTheme.card,
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(
                            color: isSelected ? KuroTheme.crimson : KuroTheme.border,
                          ),
                        ),
                        child: Center(
                          child: Text(
                            cat,
                            style: GoogleFonts.spaceGrotesk(
                              fontSize: 10.5,
                              fontWeight: FontWeight.w700,
                              color: isSelected ? Colors.white : KuroTheme.textGrey,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 16),

              // 4. Hero Featured Card (Enlazado al catálogo dinámico)
              if (featuredManga != null)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: KuroTheme.border),
                      image: DecorationImage(
                        image: NetworkImage(
                          featuredManga.imageUrl.isNotEmpty
                              ? featuredManga.imageUrl
                              : 'https://images.unsplash.com/photo-1578632767115-351597cf2477?w=800',
                        ),
                        fit: BoxFit.cover,
                      ),
                    ),
                    child: Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(18),
                        gradient: KuroTheme.heroOverlayGradient,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Badges top
                          Row(
                            children: [
                              KuroTheme.badge(text: 'DESTACADO', bgColor: KuroTheme.crimson),
                              const SizedBox(width: 6),
                              KuroTheme.badge(
                                text: featuredManga.type.isNotEmpty ? featuredManga.type.toUpperCase() : 'MANGA',
                                bgColor: KuroTheme.cardLighter,
                                textColor: KuroTheme.cyan,
                              ),
                              const Spacer(),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                                decoration: BoxDecoration(
                                  color: Colors.black.withValues(alpha: 0.6),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(Icons.star, color: KuroTheme.gold, size: 12),
                                    const SizedBox(width: 4),
                                    Text(
                                      '${featuredManga.rating > 0 ? featuredManga.rating.toStringAsFixed(1) : "5.0"} (${featuredManga.numRatings > 0 ? featuredManga.numRatings : 1} votos)',
                                      style: KuroTheme.mono(fontSize: 9.5, color: Colors.white, fontWeight: FontWeight.w700),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 120),

                          Text(
                            featuredManga.numberPages.isNotEmpty && featuredManga.numberPages != '0'
                                ? '${featuredManga.numberPages} PÁGINAS • ${featuredManga.estado.toUpperCase()}'
                                : featuredManga.estado.toUpperCase(),
                            style: KuroTheme.mono(fontSize: 9, color: KuroTheme.textGrey, fontWeight: FontWeight.w700),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            featuredManga.title.toUpperCase(),
                            style: GoogleFonts.spaceGrotesk(
                              fontSize: 24,
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                              letterSpacing: 1.2,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            '${featuredManga.mangaCategoryName.toUpperCase()} • OFICIAL',
                            style: KuroTheme.mono(fontSize: 10, color: KuroTheme.crimson),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            featuredManga.description.isNotEmpty
                                ? featuredManga.description
                                : 'Obra disponible en la plataforma Kuro. Explora sus capítulos y tomos registrados.',
                            style: KuroTheme.body(fontSize: 11, color: KuroTheme.textGrey),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),

                          const SizedBox(height: 14),

                          // Action Buttons
                          Row(
                            children: [
                              Expanded(
                                child: GestureDetector(
                                  onTap: () {
                                    Navigator.pushNamed(
                                      context,
                                      MangaDetails.routeName,
                                      arguments: featuredManga.id,
                                    );
                                  },
                                  child: Container(
                                    height: 44,
                                    decoration: BoxDecoration(
                                      gradient: KuroTheme.crimsonGradient,
                                      borderRadius: BorderRadius.circular(10),
                                      boxShadow: [
                                        BoxShadow(
                                          color: KuroTheme.crimson.withValues(alpha: 0.35),
                                          blurRadius: 10,
                                          offset: const Offset(0, 3),
                                        ),
                                      ],
                                    ),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        const Icon(Icons.play_arrow, color: Colors.white, size: 18),
                                        const SizedBox(width: 6),
                                        Text(
                                          'LEER AHORA',
                                          style: GoogleFonts.spaceGrotesk(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w800,
                                            color: Colors.white,
                                            letterSpacing: 1,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              GestureDetector(
                                onTap: () {
                                  wishlistProvider.addRemoveMangasToWishList(mangaId: featuredManga.id);
                                },
                                child: Container(
                                  width: 44,
                                  height: 44,
                                  decoration: BoxDecoration(
                                    color: KuroTheme.card.withValues(alpha: 0.8),
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(color: KuroTheme.border),
                                  ),
                                  child: Icon(
                                    isFeaturedInWishlist ? Icons.bookmark : Icons.bookmark_outline,
                                    color: isFeaturedInWishlist ? KuroTheme.crimson : Colors.white,
                                    size: 20,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              GestureDetector(
                                onTap: () {
                                  Navigator.pushNamed(
                                    context,
                                    MangaDetails.routeName,
                                    arguments: featuredManga.id,
                                  );
                                },
                                child: Container(
                                  width: 44,
                                  height: 44,
                                  decoration: BoxDecoration(
                                    color: KuroTheme.card.withValues(alpha: 0.8),
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(color: KuroTheme.border),
                                  ),
                                  child: const Icon(Icons.info_outline, color: Colors.white, size: 20),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 12),
                          // Status indicator
                          Center(
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  width: 18,
                                  height: 4,
                                  decoration: BoxDecoration(
                                    color: KuroTheme.crimson,
                                    borderRadius: BorderRadius.circular(2),
                                  ),
                                ),
                                const SizedBox(width: 4),
                                Container(
                                  width: 4,
                                  height: 4,
                                  decoration: const BoxDecoration(color: KuroTheme.border, shape: BoxShape.circle),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

              const SizedBox(height: 20),

              // 5. Special Banner: Maestros del Manga Oscuro
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: KuroTheme.cardDecoration(
                    color: const Color(0xFF161521),
                    borderColor: const Color(0xFF28253B),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 42,
                        height: 42,
                        decoration: BoxDecoration(
                          color: const Color(0xFF281E2C),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.military_tech, color: KuroTheme.crimson, size: 22),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'ESPECIAL DEL MES',
                              style: KuroTheme.mono(fontSize: 8.5, color: KuroTheme.crimson, fontWeight: FontWeight.w700),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Maestros del Manga Oscuro',
                              style: GoogleFonts.spaceGrotesk(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                            Text(
                              '12 Obras Curadas • Retrospectiva',
                              style: KuroTheme.body(fontSize: 10, color: KuroTheme.textGrey),
                            ),
                          ],
                        ),
                      ),
                      const Icon(Icons.arrow_forward_ios, color: KuroTheme.textMuted, size: 14),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // 6. Section "En Tendencia #TOP 10"
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Text('En Tendencia', style: KuroTheme.title(fontSize: 18)),
                        const SizedBox(width: 8),
                        KuroTheme.badge(text: '#TOP 10', bgColor: KuroTheme.card, textColor: KuroTheme.textGrey),
                      ],
                    ),
                    Text(
                      'VER TODO >',
                      style: KuroTheme.mono(fontSize: 10, color: KuroTheme.crimson, fontWeight: FontWeight.w700),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 2),
                child: Text(
                  'RANKING SEMANAL // JAPÓN & GLOBAL',
                  style: KuroTheme.mono(fontSize: 8.5, color: KuroTheme.textMuted),
                ),
              ),

              const SizedBox(height: 12),

              // Horizontal Manga Cards (En Tendencia)
              SizedBox(
                height: 250,
                child: allMangas.isEmpty
                    ? Center(
                        child: Text(
                          'Cargando catálogo...',
                          style: KuroTheme.mono(fontSize: 10, color: KuroTheme.textMuted),
                        ),
                      )
                    : ListView.builder(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        itemCount: allMangas.length,
                        itemBuilder: (context, index) {
                          final manga = allMangas[index];

                          return GestureDetector(
                            onTap: () {
                              Navigator.pushNamed(
                                context,
                                MangaDetails.routeName,
                                arguments: manga.id,
                              );
                            },
                            child: Container(
                              width: 140,
                              margin: const EdgeInsets.only(right: 12),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Stack(
                                    children: [
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(12),
                                        child: manga.imageUrl.isNotEmpty
                                            ? Image.network(
                                                manga.imageUrl,
                                                height: 175,
                                                width: 140,
                                                fit: BoxFit.cover,
                                                errorBuilder: (ctx, err, stack) => Container(
                                                  height: 175,
                                                  width: 140,
                                                  color: KuroTheme.cardLighter,
                                                  child: const Icon(Icons.menu_book, color: KuroTheme.textMuted),
                                                ),
                                              )
                                            : Container(
                                                height: 175,
                                                width: 140,
                                                color: KuroTheme.cardLighter,
                                                child: const Icon(Icons.menu_book, color: KuroTheme.textMuted),
                                              ),
                                      ),
                                      Positioned(
                                        top: 6,
                                        left: 6,
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: KuroTheme.crimson,
                                            borderRadius: BorderRadius.circular(4),
                                          ),
                                          child: Text(
                                            '#0${index + 1}',
                                            style: KuroTheme.mono(fontSize: 8.5, color: Colors.white, fontWeight: FontWeight.w800),
                                          ),
                                        ),
                                      ),
                                      Positioned(
                                        top: 6,
                                        right: 6,
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: Colors.black.withValues(alpha: 0.7),
                                            borderRadius: BorderRadius.circular(4),
                                          ),
                                          child: Row(
                                            children: [
                                              const Icon(Icons.star, color: KuroTheme.gold, size: 10),
                                              const SizedBox(width: 2),
                                              Text(
                                                manga.rating > 0 ? manga.rating.toStringAsFixed(1) : '5.0',
                                                style: KuroTheme.mono(fontSize: 8.5, color: Colors.white),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      Positioned(
                                        bottom: 6,
                                        left: 6,
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: Colors.black.withValues(alpha: 0.7),
                                            borderRadius: BorderRadius.circular(4),
                                          ),
                                          child: Text(
                                            manga.numberPages.isNotEmpty && manga.numberPages != '0'
                                                ? '${manga.numberPages} págs'
                                                : manga.estado.toUpperCase(),
                                            style: KuroTheme.mono(fontSize: 8.5, color: Colors.white),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    manga.type.isNotEmpty ? manga.type.toUpperCase() : 'MANGA',
                                    style: KuroTheme.mono(fontSize: 8, color: KuroTheme.cyan, fontWeight: FontWeight.w700),
                                    maxLines: 1,
                                  ),
                                  Text(
                                    manga.title,
                                    style: GoogleFonts.spaceGrotesk(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.white,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  Text(
                                    manga.autor.isNotEmpty ? manga.autor : manga.mangaCategoryName,
                                    style: KuroTheme.body(fontSize: 10, color: KuroTheme.textMuted),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
              ),

              // 7. Section "CONTINUAR LEYENDO" (Sincronizado con Firestore)
              StreamBuilder<Map<String, dynamic>?>(
                stream: KuroReaderBackendService.instance.streamLatestReading(
                    FirebaseAuth.instance.currentUser?.uid ?? ''),
                builder: (context, snapshot) {
                  final reading = snapshot.data;
                  final hasReading = reading != null;

                  final cover = hasReading
                      ? (reading['coverUrl']?.toString() ?? '')
                      : (allMangas.isNotEmpty ? allMangas.first.imageUrl : '');
                  final title = hasReading
                      ? (reading['mangaTitle']?.toString() ?? 'Manga')
                      : (allMangas.isNotEmpty ? allMangas.first.title : 'Descubre Nuevos Mangas');
                  final subtitle = hasReading
                      ? '${reading['chapterTitle'] ?? 'Capítulo en progreso'}'
                      : 'Comienza tu primera lectura en Kuro';
                  final progress = hasReading
                      ? ((reading['progressPercent'] as num?)?.toInt() ?? 10)
                      : 0;

                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Container(
                      padding: const EdgeInsets.all(14),
                      decoration: KuroTheme.cardDecoration(
                        color: KuroTheme.card,
                        borderColor: KuroTheme.border,
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  const Icon(Icons.history, color: KuroTheme.textGrey, size: 15),
                                  const SizedBox(width: 6),
                                  Text(
                                    hasReading ? 'CONTINUAR LEYENDO' : 'LECTURA RECIENTE',
                                    style: KuroTheme.mono(fontSize: 9.5, color: KuroTheme.textGrey),
                                  ),
                                ],
                              ),
                              Text(
                                hasReading ? '$progress% LEÍDO' : 'SIN INICIAR',
                                style: KuroTheme.mono(
                                  fontSize: 9.5,
                                  color: hasReading ? KuroTheme.crimson : KuroTheme.textMuted,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: cover.isNotEmpty && cover.startsWith('http')
                                    ? Image.network(
                                        cover,
                                        width: 48,
                                        height: 60,
                                        fit: BoxFit.cover,
                                        errorBuilder: (_, __, ___) => Container(
                                          width: 48,
                                          height: 60,
                                          color: KuroTheme.cardLighter,
                                          child: const Icon(Icons.menu_book, color: KuroTheme.textMuted),
                                        ),
                                      )
                                    : Container(
                                        width: 48,
                                        height: 60,
                                        color: KuroTheme.cardLighter,
                                        child: const Icon(Icons.menu_book, color: KuroTheme.textMuted),
                                      ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      title,
                                      style: GoogleFonts.spaceGrotesk(
                                          fontSize: 14, fontWeight: FontWeight.w700, color: Colors.white),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      subtitle,
                                      style: KuroTheme.body(fontSize: 11, color: KuroTheme.textGrey),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 8),
                                    Container(
                                      height: 3,
                                      decoration: BoxDecoration(
                                        color: KuroTheme.cardLighter,
                                        borderRadius: BorderRadius.circular(2),
                                      ),
                                      child: Row(
                                        children: [
                                          Expanded(
                                            flex: progress.clamp(1, 100),
                                            child: Container(
                                              decoration: BoxDecoration(
                                                color: KuroTheme.crimson,
                                                borderRadius: BorderRadius.circular(2),
                                              ),
                                            ),
                                          ),
                                          Expanded(
                                            flex: (100 - progress).clamp(0, 99),
                                            child: const SizedBox(),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 8),
                              GestureDetector(
                                onTap: () {
                                  if (hasReading) {
                                    final pages = (reading['pageImages'] as List?)
                                        ?.map((e) => e.toString())
                                        .toList();
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (c) => OnlineViewScreen(
                                          pdfUrl: reading['pdfUrl']?.toString() ?? '',
                                          pageImages: pages,
                                          mangaId: reading['mangaId']?.toString(),
                                          coverUrl: reading['coverUrl']?.toString(),
                                          mangaTitle: reading['mangaTitle']?.toString() ?? 'Manga',
                                          chapterTitle: reading['chapterTitle']?.toString(),
                                          tomoTitle: reading['tomoTitle']?.toString(),
                                        ),
                                      ),
                                    );
                                  } else if (allMangas.isNotEmpty) {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (c) => OnlineViewScreen(
                                          pdfUrl: allMangas.first.pdfUrl,
                                          mangaId: allMangas.first.id,
                                          coverUrl: allMangas.first.imageUrl,
                                          mangaTitle: allMangas.first.title,
                                        ),
                                      ),
                                    );
                                  }
                                },
                                child: Container(
                                  width: 38,
                                  height: 38,
                                  decoration: const BoxDecoration(
                                    color: KuroTheme.crimson,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(Icons.play_arrow, color: Colors.white, size: 20),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),

              const SizedBox(height: 24),

              // 8. Section "Últimos Capítulos"
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Text('Últimos Capítulos', style: KuroTheme.title(fontSize: 18)),
                        const SizedBox(width: 6),
                        Container(width: 6, height: 6, decoration: const BoxDecoration(color: KuroTheme.crimson, shape: BoxShape.circle)),
                      ],
                    ),
                    Text(
                      'VER TODO >',
                      style: KuroTheme.mono(fontSize: 10, color: KuroTheme.crimson, fontWeight: FontWeight.w700),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 2),
                child: Text('ACTUALIZADO EN TIEMPO REAL', style: KuroTheme.mono(fontSize: 8.5, color: KuroTheme.textMuted)),
              ),
              const SizedBox(height: 12),

              if (allMangas.isNotEmpty)
                ...allMangas.take(4).map((manga) {
                  return GestureDetector(
                    onTap: () {
                      Navigator.pushNamed(
                        context,
                        MangaDetails.routeName,
                        arguments: manga.id,
                      );
                    },
                    child: _buildChapterRow(
                      badgeText: manga.estado.toUpperCase().contains('EMISI') ? 'NUEVO' : 'COMPLETO',
                      badgeColor: manga.estado.toUpperCase().contains('EMISI') ? KuroTheme.crimson : KuroTheme.cardLighter,
                      timeText: manga.type.isNotEmpty ? manga.type.toUpperCase() : 'MANGA',
                      title: manga.title,
                      chapter: manga.numberPages.isNotEmpty && manga.numberPages != '0'
                          ? '${manga.numberPages} Páginas • ${manga.mangaCategoryName}'
                          : '${manga.mangaCategoryName} • Kuro Scan',
                      tag: manga.autor.isNotEmpty ? 'Autor: ${manga.autor}' : 'Scan Oficial KuroHQ',
                      imageUrl: manga.imageUrl,
                    ),
                  );
                }).toList()
              else
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  child: Center(
                    child: Text('No hay obras registradas en el catálogo.', style: KuroTheme.body(fontSize: 11, color: KuroTheme.textMuted)),
                  ),
                ),

              const SizedBox(height: 20),

              // 9. Community Discussion Card
              if (featuredManga != null)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: GestureDetector(
                    onTap: () {
                      Navigator.pushNamed(
                        context,
                        MangaDetails.routeName,
                        arguments: featuredManga.id,
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.all(14),
                      decoration: KuroTheme.cardDecoration(),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(width: 4, height: 12, color: KuroTheme.crimson),
                              const SizedBox(width: 6),
                              Text(
                                'DISCUSIÓN DE LA COMUNIDAD // EN VIVO',
                                style: KuroTheme.mono(fontSize: 8.5, color: KuroTheme.crimson, fontWeight: FontWeight.w700),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '¿Qué opinas sobre el desarrollo de ${featuredManga.title}? Únete a las teorías y reseñas de la comunidad.',
                            style: GoogleFonts.spaceGrotesk(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.white, height: 1.3),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    width: 24,
                                    height: 24,
                                    decoration: const BoxDecoration(color: KuroTheme.crimson, shape: BoxShape.circle),
                                    child: Center(
                                      child: Text('K', style: KuroTheme.mono(fontSize: 10, color: Colors.white, fontWeight: FontWeight.w800)),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text('Lector Verificado', style: KuroTheme.mono(fontSize: 11, color: KuroTheme.textGrey)),
                                ],
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                decoration: BoxDecoration(
                                  color: KuroTheme.cardLighter,
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(color: KuroTheme.border),
                                ),
                                child: Text(
                                  'VER RESEÑAS',
                                  style: KuroTheme.mono(fontSize: 9.5, color: Colors.white, fontWeight: FontWeight.w700),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildChapterRow({
    required String badgeText,
    required Color badgeColor,
    required String timeText,
    required String title,
    required String chapter,
    required String tag,
    required String imageUrl,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: KuroTheme.cardDecoration(),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                imageUrl,
                width: 44,
                height: 52,
                fit: BoxFit.cover,
                errorBuilder: (ctx, err, stack) => Container(
                  width: 44,
                  height: 52,
                  color: KuroTheme.cardLighter,
                  child: const Icon(Icons.menu_book, color: KuroTheme.textMuted),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                        decoration: BoxDecoration(color: badgeColor, borderRadius: BorderRadius.circular(3)),
                        child: Text(badgeText, style: KuroTheme.mono(fontSize: 7.5, color: Colors.white, fontWeight: FontWeight.w800)),
                      ),
                      const SizedBox(width: 6),
                      Text(timeText, style: KuroTheme.mono(fontSize: 8, color: KuroTheme.textMuted)),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    title,
                    style: GoogleFonts.spaceGrotesk(fontSize: 13, fontWeight: FontWeight.w700, color: Colors.white),
                    maxLines: 1,
                  ),
                  Text(chapter, style: KuroTheme.body(fontSize: 10.5, color: KuroTheme.textGrey), maxLines: 1),
                  Text(tag, style: KuroTheme.mono(fontSize: 8, color: KuroTheme.cyan)),
                ],
              ),
            ),
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: KuroTheme.cardLighter,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: KuroTheme.border),
              ),
              child: const Icon(Icons.menu_book, color: KuroTheme.textWhite, size: 16),
            ),
          ],
        ),
      ),
    );
  }
}
