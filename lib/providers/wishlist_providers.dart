import 'package:aplicacion_manga/models/wishlist_models.dart';
import 'package:aplicacion_manga/services/reader_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';

class WishListProvider with ChangeNotifier {
  final Map<String, WishListModels> _wishListItems = {};

  Map<String, WishListModels> get getWishListItems {
    return _wishListItems;
  }

  /// Inicializa la sincronización en vivo con Firestore
  void initWishlistSync(String uid) {
    if (uid.isEmpty) return;
    KuroReaderBackendService.instance.streamWishlistIds(uid).listen((ids) {
      _wishListItems.clear();
      for (var id in ids) {
        _wishListItems[id] = WishListModels(
          id: id,
          mangaId: id,
        );
      }
      notifyListeners();
    });
  }

  Future<void> addRemoveMangasToWishList({
    required String mangaId,
    String? title,
    String? imageUrl,
    String? category,
  }) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;

    if (_wishListItems.containsKey(mangaId)) {
      _wishListItems.remove(mangaId);
    } else {
      _wishListItems[mangaId] = WishListModels(
        id: mangaId,
        mangaId: mangaId,
      );
    }
    notifyListeners();

    if (uid != null && uid.isNotEmpty) {
      await KuroReaderBackendService.instance.toggleWishlist(
        uid: uid,
        mangaId: mangaId,
        title: title,
        imageUrl: imageUrl,
        category: category,
      );
    }
  }

  void removeOneItem(String mangaId) async {
    _wishListItems.remove(mangaId);
    notifyListeners();

    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid != null && uid.isNotEmpty) {
      await KuroReaderBackendService.instance.toggleWishlist(
        uid: uid,
        mangaId: mangaId,
      );
    }
  }

  void clearWishList() async {
    _wishListItems.clear();
    notifyListeners();

    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid != null && uid.isNotEmpty) {
      await KuroReaderBackendService.instance.clearWishlist(uid);
    }
  }
}
