import 'package:aplicacion_manga/models/viewed_models.dart';
import 'package:flutter/cupertino.dart';

class ViewedMangaProvider with ChangeNotifier {
  Map<String, ViewedMangaModels> _viewedMangasListItems = {};

  Map<String, ViewedMangaModels> get getViewedMangasListItems {
    return _viewedMangasListItems;
  }

  void addMangasToHistory({required String mangaId}) {
    _viewedMangasListItems.putIfAbsent(
        mangaId,
        () => ViewedMangaModels(
              id: DateTime.now().toString(),
              mangaId: mangaId,
            ));

    notifyListeners();
  }

  void clearHistory() {
    _viewedMangasListItems.clear();
    notifyListeners();
  }
}
