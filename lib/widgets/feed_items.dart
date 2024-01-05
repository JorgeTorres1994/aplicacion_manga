import 'package:aplicacion_manga/inner_screens/manga_details.dart';
import 'package:aplicacion_manga/models/mangas_models.dart';
import 'package:aplicacion_manga/providers/wishlist_providers.dart';
import 'package:aplicacion_manga/services/utils.dart';
import 'package:aplicacion_manga/widgets/hearth_button.dart';
import 'package:fancy_shimmer_image/fancy_shimmer_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class FeedsWidget extends StatefulWidget {
  const FeedsWidget({Key? key}) : super(key: key);

  @override
  State<FeedsWidget> createState() => _FeedsWidgetState();
}

class _FeedsWidgetState extends State<FeedsWidget> {
  final _quantityTextController = TextEditingController();

  @override
  void initState() {
    _quantityTextController.text = '1';
    super.initState();
  }

  @override
  void dispose() {
    _quantityTextController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Color color = Utils(context).color;
    Size size = Utils(context).getScreenSize;
    final mangaModel = Provider.of<MangasModels>(context);
    final wishListProvider = Provider.of<WishListProvider>(context);
    bool? _isWishList =
        wishListProvider.getWishListItems.containsKey(mangaModel.id);

    return Center(
      child: Material(
        borderRadius: BorderRadius.circular(12),
        color: Theme.of(context).cardColor,
        child: InkWell(
          onTap: () {
            Navigator.pushNamed(context, MangaDetails.routeName,
                arguments: mangaModel.id);
          },
          borderRadius: BorderRadius.circular(12),
          child: SingleChildScrollView(
            // Agregamos SingleChildScrollView aquí
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                FancyShimmerImage(
                  imageUrl: mangaModel.imageUrl,
                  width: size.width * 0.30,
                  height: size.height * 0.22,
                  boxFit: BoxFit.fill,
                ),
                SizedBox(height: 8),
                Text(
                  mangaModel.title,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: color,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 8),
                /*HearthButton(
                  mangaId: mangaModel.id,
                  isWishList: _isWishList,
                ),*/
                //SizedBox(height: 8),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
