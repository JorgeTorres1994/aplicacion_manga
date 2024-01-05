import 'package:aplicacion_manga/models/wishlist_models.dart';
import 'package:flutter/cupertino.dart';

class WishListProvider with ChangeNotifier {
  Map<String, WishListModels> _wishListItems = {};

  Map<String, WishListModels> get getWishListItems {
    return _wishListItems;
  }

  void addRemoveMangasToWishList({required String mangaId}) {
    if (_wishListItems.containsKey(mangaId)) {
      removeOneItem(mangaId);
    } else {
      _wishListItems.putIfAbsent(
          mangaId,
          () => WishListModels(
                id: DateTime.now().toString(),
                mangaId: mangaId,
              ));
    }
    notifyListeners();
  }

  void removeOneItem(String mangaId) {
    _wishListItems.remove(mangaId);
    notifyListeners();
  }

  void clearWishList() {
    _wishListItems.clear();
    notifyListeners();
  }
}
