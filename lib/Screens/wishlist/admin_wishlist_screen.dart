import 'package:aplicacion_manga/Screens/wishlist/wishlist_widget.dart';
import 'package:aplicacion_manga/providers/wishlist_providers.dart';
import 'package:aplicacion_manga/services/global_methods.dart';
import 'package:aplicacion_manga/services/utils.dart';
import 'package:aplicacion_manga/widgets/back_widget.dart';
import 'package:aplicacion_manga/widgets/empty_screen.dart';
import 'package:aplicacion_manga/widgets/textos_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_iconly/flutter_iconly.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:provider/provider.dart';

class AdminWishListScreem extends StatelessWidget {
  static const routeName = "/WishListScreenState"; //ruta de la interfaz
  const AdminWishListScreem({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final Color color = Utils(context).color;
    //Size size = Utils(context).getScreenSize;
    final wishListProvider = Provider.of<WishListProvider>(context);
    final wishListItemList =
        wishListProvider.getWishListItems.values.toList().reversed.toList();
    return wishListItemList.isEmpty
        ? EmptyScreen(
            title: 'Lista de deseos vacía',
            subtitle: '',
            buttonText: 'Agrega un manga a tu lista',
            //imagePath: 'iconos/carrito-de-compras.png',
            imagePath: 'images/lista-de-deseos.png',
          )
        : Scaffold(
            appBar: AppBar(
              centerTitle: true,
              leading: BackWidget(),
              automaticallyImplyLeading: false,
              elevation: 0,
              backgroundColor: Theme.of(context).scaffoldBackgroundColor,
              title: TextosWidget(
                text: 'Lista de Deseos (${wishListItemList.length})',
                color: color,
                isTitle: true,
                textSize: 18,
              ),
              actions: [
                IconButton(
                  onPressed: () {
                    GlobalMethods.warningDialog(
                        title: 'Borrar lista de deseos?',
                        subtitle: 'Estás seguro?',
                        fct: () {
                          wishListProvider.clearWishList();
                        },
                        context: context);
                  },
                  icon: Icon(
                    IconlyBroken.delete,
                    color: color,
                  ),
                ),
              ],
            ),
            //body: WishListWidget(),
            body: MasonryGridView.count(
              itemCount: wishListItemList.length,
              crossAxisCount: 2,
              // mainAxisSpacing: 16,
              // crossAxisSpacing: 20,
              itemBuilder: (context, index) {
                return ChangeNotifierProvider.value(
                    value: wishListItemList[index],
                    child: const WishListWidget());
              },
            ));
  }
}
