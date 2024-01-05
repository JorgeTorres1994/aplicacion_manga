import 'package:aplicacion_manga/otros%20componentes/firebase_contss.dart';
import 'package:aplicacion_manga/providers/wishlist_providers.dart';
import 'package:aplicacion_manga/services/global_methods.dart';
import 'package:aplicacion_manga/services/utils.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_iconly/flutter_iconly.dart';
import 'package:provider/provider.dart';

class HearthButton extends StatelessWidget {
  const HearthButton(
      {super.key, required this.mangaId, this.isWishList = false});
  final String mangaId;
  final bool? isWishList;

  @override
  Widget build(BuildContext context) {
    final Color color = Utils(context).color;
    final wishListProvider = Provider.of<WishListProvider>(context);
    return GestureDetector(
      onTap: () {
        final User? user = authInstance.currentUser;
        if (user == null) {
          GlobalMethods.warningDialog(
              title: 'El usuario no funciona',
              subtitle: 'Por favor ingresa logueate primero',
              fct: () {},
              context: context);
        }
        //print('user id is ${user.uid}');
        wishListProvider.addRemoveMangasToWishList(mangaId: mangaId);
      },
      child: Icon(
        isWishList != null && isWishList == true
            ? IconlyBold.heart
            : IconlyLight.heart,
        size: 22,
        color:
            isWishList != null && isWishList == true ? Colors.redAccent : color,
      ),
    );
  }
}
