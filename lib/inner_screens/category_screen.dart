import 'package:aplicacion_manga/inner_screens/manga_details.dart';
import 'package:aplicacion_manga/models/mangas_models.dart';
import 'package:aplicacion_manga/providers/mangas_providers.dart';
import 'package:aplicacion_manga/theme/kuro_theme.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class CategoryScreen extends StatefulWidget {
  static const routeName = "/CategoryScreenState";
  const CategoryScreen({super.key});

  @override
  State<CategoryScreen> createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen> {
  final TextEditingController _searchTextController = TextEditingController();
  List<MangasModels> listMangaSearch = [];

  @override
  void dispose() {
    _searchTextController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final mangasProvider = Provider.of<MangasProvider>(context);
    final categoryText = ModalRoute.of(context)?.settings.arguments as String? ?? 'General';
    final mangaByCategory = mangasProvider.findByCategory(categoryText);

    final displayList = _searchTextController.text.isNotEmpty ? listMangaSearch : mangaByCategory;

    return Scaffold(
      backgroundColor: KuroTheme.background,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: KuroTheme.background,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'CATEGORÍA // $categoryText'.toUpperCase(),
              style: KuroTheme.mono(fontSize: 10, color: KuroTheme.crimson, fontWeight: FontWeight.w700),
            ),
            Text(
              categoryText,
              style: GoogleFonts.spaceGrotesk(fontSize: 18, fontWeight: FontWeight.w800, color: Colors.white),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Search Input
            Container(
              height: 48,
              decoration: KuroTheme.cardDecoration(),
              padding: const EdgeInsets.symmetric(horizontal: 14),
              child: Row(
                children: [
                  const Icon(Icons.search, color: KuroTheme.crimson, size: 20),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      controller: _searchTextController,
                      style: KuroTheme.body(color: Colors.white, fontSize: 13),
                      onChanged: (value) {
                        setState(() {
                          listMangaSearch = mangasProvider.searchQuery(value);
                        });
                      },
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: 'Buscar en $categoryText...',
                        hintStyle: KuroTheme.body(color: KuroTheme.textMuted, fontSize: 13),
                      ),
                    ),
                  ),
                  if (_searchTextController.text.isNotEmpty)
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          _searchTextController.clear();
                          listMangaSearch.clear();
                        });
                      },
                      child: const Icon(Icons.close, color: KuroTheme.textMuted, size: 18),
                    ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            Text(
              '${displayList.length} MANGAS DISPONIBLES',
              style: KuroTheme.mono(fontSize: 10, color: KuroTheme.textGrey, fontWeight: FontWeight.w700),
            ),

            const SizedBox(height: 12),

            if (displayList.isEmpty)
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(40),
                  child: Column(
                    children: [
                      const Icon(Icons.menu_book, color: KuroTheme.textMuted, size: 48),
                      const SizedBox(height: 12),
                      Text(
                        'No se encontraron obras en esta categoría.',
                        style: KuroTheme.body(color: KuroTheme.textMuted, fontSize: 13),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              )
            else
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 14,
                  childAspectRatio: 0.65,
                ),
                itemCount: displayList.length,
                itemBuilder: (context, index) {
                  final manga = displayList[index];
                  return GestureDetector(
                    onTap: () {
                      Navigator.pushNamed(context, MangaDetails.routeName, arguments: manga.id);
                    },
                    child: Container(
                      decoration: KuroTheme.cardDecoration(),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: ClipRRect(
                              borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
                              child: Image.network(
                                manga.imageUrl.isNotEmpty ? manga.imageUrl : 'https://images.unsplash.com/photo-1607604276583-eef5d076aa5f?w=800',
                                width: double.infinity,
                                fit: BoxFit.cover,
                                errorBuilder: (ctx, err, stack) => Container(
                                  color: KuroTheme.cardLighter,
                                  child: const Icon(Icons.broken_image, color: KuroTheme.textMuted),
                                ),
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(10),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  manga.type.isNotEmpty ? manga.type : 'MANGA',
                                  style: KuroTheme.mono(fontSize: 8, color: KuroTheme.cyan, fontWeight: FontWeight.w700),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  manga.title,
                                  style: GoogleFonts.spaceGrotesk(fontSize: 13, fontWeight: FontWeight.w700, color: Colors.white),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      manga.numberPages.isNotEmpty ? '${manga.numberPages} págs' : 'RAW',
                                      style: KuroTheme.mono(fontSize: 9, color: KuroTheme.textMuted),
                                    ),
                                    const Icon(Icons.arrow_forward_ios, color: KuroTheme.crimson, size: 12),
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
          ],
        ),
      ),
    );
  }
}
