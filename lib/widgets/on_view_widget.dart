import 'package:aplicacion_manga/inner_screens/manga_details.dart';
import 'package:aplicacion_manga/models/mangas_models.dart';
import 'package:aplicacion_manga/providers/wishlist_providers.dart';
import 'package:aplicacion_manga/services/utils.dart';
import 'package:aplicacion_manga/widgets/textos_widget.dart';
import 'package:fancy_shimmer_image/fancy_shimmer_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_iconly/flutter_iconly.dart';
import 'package:provider/provider.dart';

import 'hearth_button.dart';

class OnViewWidget extends StatefulWidget {
  const OnViewWidget({Key? key}) : super(key: key);

  @override
  State<OnViewWidget> createState() => _OnViewWidgetState();
}

class _OnViewWidgetState extends State<OnViewWidget> {
  @override
  Widget build(BuildContext context) {
    final mangaModel = Provider.of<MangasModels>(context);
    final Color color = Utils(context).color;
    //final theme = Utils(context).getTheme;
    Size size = Utils(context).getScreenSize;
    final wishListProvider = Provider.of<WishListProvider>(context);
    bool? _isWishList =
        wishListProvider.getWishListItems.containsKey(mangaModel.id);

    return Center(
      // Utilizamos el widget Center para centrar todo el contenido
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Material(
          color: Theme.of(context).cardColor.withOpacity(0.9),
          borderRadius: BorderRadius.circular(12),
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () {
              Navigator.pushNamed(context, MangaDetails.routeName,
                  arguments: mangaModel.id);
              /*GlobalMethods.navigateto(
                ctx: context,
                routeName: MangaDetails.routeName,
              );*/
            },
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      // Centramos horizontalmente la imagen
                      children: [
                        FancyShimmerImage(
                          imageUrl: mangaModel.imageUrl,
                          width: size.width * 0.30,
                          height: size.height * 0.22,
                          boxFit: BoxFit.fill,
                        ),
                      ],
                    ),
                    SizedBox(
                        height:
                            8), // Agregar un espacio entre la imagen y el título
                    TextosWidget(
                      text: mangaModel.title,
                      color: color,
                      textSize: 22,
                      isTitle: true,
                    ),
                    SizedBox(
                        height:
                            8), // Agregar un espacio entre el título y el icono
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      // Centramos horizontalmente los elementos del Row
                      children: [
                        /*GestureDetector(
                          onTap: () {},
                          child: Icon(
                            IconlyLight.bag,
                            size: 22,
                            color: color,
                          ),
                        ),*/

                        /*HearthButton(
                          mangaId: mangaModel.id,
                          isWishList: _isWishList,
                        ),*/
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
