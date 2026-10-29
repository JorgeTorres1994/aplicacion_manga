import 'package:aplicacion_manga/inner_screens/manga_details.dart';
import 'package:aplicacion_manga/providers/mangas_providers.dart';
import 'package:aplicacion_manga/providers/wishlist_providers.dart';
import 'package:aplicacion_manga/theme/kuro_theme.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class AdminWishListScreem extends StatelessWidget {
  static const routeName = "/WishListScreenState";
  const AdminWishListScreem({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final wishListProvider = Provider.of<WishListProvider>(context);
    final wishListItemList = wishListProvider.getWishListItems.values.toList().reversed.toList();
    final mangasProvider = Provider.of<MangasProvider>(context);

    return Scaffold(
      backgroundColor: KuroTheme.background,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: KuroTheme.background,
        automaticallyImplyLeading: false,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(width: 4, height: 12, color: KuroTheme.crimson),
                const SizedBox(width: 6),
                Text('COLECCIÓN // 03', style: KuroTheme.mono(fontSize: 9, color: KuroTheme.crimson, fontWeight: FontWeight.w700)),
              ],
            ),
            Text('MI BIBLIOTECA', style: GoogleFonts.spaceGrotesk(fontSize: 18, fontWeight: FontWeight.w800, color: Colors.white)),
          ],
        ),
        actions: [
          if (wishListItemList.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_outline, color: KuroTheme.crimson, size: 20),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    backgroundColor: KuroTheme.card,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    title: Text('¿VACIAR BIBLIOTECA?', style: KuroTheme.mono(fontSize: 12, color: KuroTheme.crimson)),
                    content: Text('Se eliminarán todos los mangas guardados en favoritos.', style: KuroTheme.body(fontSize: 12, color: KuroTheme.textWhite)),
                    actions: [
                      TextButton(onPressed: () => Navigator.pop(ctx), child: Text('CANCELAR', style: KuroTheme.mono(fontSize: 11, color: KuroTheme.textMuted))),
                      TextButton(
                        onPressed: () {
                          wishListProvider.clearWishList();
                          Navigator.pop(ctx);
                        },
                        child: Text('CONFIRMAR', style: KuroTheme.mono(fontSize: 11, color: KuroTheme.crimson)),
                      ),
                    ],
                  ),
                );
              },
            ),
          const SizedBox(width: 8),
        ],
      ),
      body: wishListItemList.isEmpty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 68,
                      height: 68,
                      decoration: BoxDecoration(color: KuroTheme.card, borderRadius: BorderRadius.circular(18), border: Border.all(color: KuroTheme.border)),
                      child: const Icon(Icons.bookmark_border, color: KuroTheme.crimson, size: 32),
                    ),
                    const SizedBox(height: 16),
                    Text('BIBLIOTECA VACÍA', style: GoogleFonts.spaceGrotesk(fontSize: 18, fontWeight: FontWeight.w800, color: Colors.white)),
                    const SizedBox(height: 6),
                    Text(
                      'Aún no has añadido mangas a tu colección.\nExplora el catálogo y presiona el marcador para guardar tus obras favoritas.',
                      textAlign: TextAlign.center,
                      style: KuroTheme.body(fontSize: 11.5, color: KuroTheme.textMuted),
                    ),
                  ],
                ),
              ),
            )
          : GridView.builder(
              padding: const EdgeInsets.all(18),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 14,
                childAspectRatio: 0.65,
              ),
              itemCount: wishListItemList.length,
              itemBuilder: (context, index) {
                final wishItem = wishListItemList[index];
                final manga = mangasProvider.findMangabyId(wishItem.mangaId);

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
                          child: Stack(
                            children: [
                              ClipRRect(
                                borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
                                child: Image.network(
                                  manga.imageUrl.isNotEmpty ? manga.imageUrl : 'https://images.unsplash.com/photo-1578632767115-351597cf2477?w=800',
                                  width: double.infinity,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              Positioned(
                                top: 6,
                                right: 6,
                                child: GestureDetector(
                                  onTap: () {
                                    wishListProvider.addRemoveMangasToWishList(mangaId: manga.id);
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.all(4),
                                    decoration: BoxDecoration(color: Colors.black.withValues(alpha: 0.7), shape: BoxShape.circle),
                                    child: const Icon(Icons.bookmark, color: KuroTheme.crimson, size: 16),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(10),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(manga.type.isNotEmpty ? manga.type : 'MANGA', style: KuroTheme.mono(fontSize: 8, color: KuroTheme.cyan)),
                              const SizedBox(height: 2),
                              Text(manga.title, style: GoogleFonts.spaceGrotesk(fontSize: 13, fontWeight: FontWeight.w700, color: Colors.white), maxLines: 1),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
