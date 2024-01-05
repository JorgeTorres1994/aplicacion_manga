import 'package:aplicacion_manga/inner_screens/manga_details.dart';
import 'package:aplicacion_manga/models/wishlist_models.dart';
import 'package:aplicacion_manga/providers/mangas_providers.dart';
import 'package:aplicacion_manga/providers/wishlist_providers.dart';
//import 'package:aplicacion_manga/services/global_methods.dart';
import 'package:aplicacion_manga/services/utils.dart';
import 'package:aplicacion_manga/widgets/hearth_button.dart';
import 'package:aplicacion_manga/widgets/textos_widget.dart';
import 'package:fancy_shimmer_image/fancy_shimmer_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_iconly/flutter_iconly.dart';
import 'package:provider/provider.dart';

class WishListWidget extends StatelessWidget {
  const WishListWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final Color color = Utils(context).color;
    Size size = Utils(context).getScreenSize;
    final wishListProvider = Provider.of<WishListProvider>(context);
    final wishListModel = Provider.of<WishListModels>(context);
    final mangaProvider = Provider.of<MangasProvider>(context);

    final getCurrManga = mangaProvider.findMangabyId(wishListModel.mangaId);

    //final mangaModel = Provider.of<CartModel>(context);
    bool? _isWishList =
        wishListProvider.getWishListItems.containsKey(getCurrManga.id);

    return Padding(
      padding: EdgeInsets.all(4.0),
      child: GestureDetector(
        onTap: () {
          Navigator.pushNamed(
            context,
            MangaDetails.routeName,
            arguments: wishListModel.mangaId,
          );
        },
        child: Container(
          height: size.height * 0.20,
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            border: Border.all(color: color, width: 0.5),
            borderRadius: BorderRadius.circular(8.0),
          ),
          child: Row(
            children: [
              Flexible(
                flex: 3,
                child: Container(
                  margin: EdgeInsets.only(left: 8),
                  height: size.width * 0.3,
                  //width: size.width * 0.2,
                  child: FancyShimmerImage(
                    imageUrl: getCurrManga.imageUrl,
                    width: size.width * 0.30,
                    height: size.height * 0.22,
                    boxFit: BoxFit.fill,
                  ),
                ),
              ),
              Flexible(
                flex: 3,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Flexible(
                      child: Row(
                        children: [
                          IconButton(
                            onPressed: () {},
                            icon: Icon(
                              IconlyLight.video,
                              color: color,
                            ),
                          ),
                          HearthButton(
                            mangaId: getCurrManga.id,
                            isWishList: _isWishList,
                          ),
                        ],
                      ),
                    ),
                    TextosWidget(
                      text: getCurrManga.title,
                      color: color,
                      textSize: 20.0,
                      maxLines: 2,
                      isTitle: true,
                    ),
                    const SizedBox(
                      height: 5,
                    ),
                    TextosWidget(
                      text: getCurrManga.mangaCategoryName,
                      color: color,
                      textSize: 18.0,
                      maxLines: 1,
                      isTitle: true,
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
