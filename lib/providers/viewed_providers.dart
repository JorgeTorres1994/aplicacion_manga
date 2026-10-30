import 'package:aplicacion_manga/models/viewed_models.dart';
import 'package:aplicacion_manga/services/reader_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';

class ViewedMangaProvider with ChangeNotifier {
  final Map<String, ViewedMangaModels> _viewedMangasListItems = {};

  Map<String, ViewedMangaModels> get getViewedMangasListItems {
    return _viewedMangasListItems;
  }

  void initHistorySync(String uid) {
    if (uid.isEmpty) return;
    KuroReaderBackendService.instance.streamReadingHistory(uid).listen((historyList) {
      _viewedMangasListItems.clear();
      for (var item in historyList) {
        final mangaId = item['mangaId']?.toString() ?? '';
        if (mangaId.isNotEmpty) {
          _viewedMangasListItems[mangaId] = ViewedMangaModels(
            id: mangaId,
            mangaId: mangaId,
          );
        }
      }
      notifyListeners();
    });
  }

  void addMangasToHistory({
    required String mangaId,
    String? mangaTitle,
    String? coverUrl,
    String? chapterTitle,
    int? currentPage,
    int? totalPages,
  }) {
    _viewedMangasListItems.putIfAbsent(
        mangaId,
        () => ViewedMangaModels(
              id: mangaId,
              mangaId: mangaId,
            ));

    notifyListeners();

    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid != null && uid.isNotEmpty) {
      KuroReaderBackendService.instance.saveReadingProgress(
        uid: uid,
        mangaId: mangaId,
        mangaTitle: mangaTitle ?? 'Manga',
        coverUrl: coverUrl ?? '',
        chapterTitle: chapterTitle ?? 'Capítulo 1',
        currentPage: currentPage ?? 1,
        totalPages: totalPages ?? 1,
      );
    }
  }

  void clearHistory() {
    _viewedMangasListItems.clear();
    notifyListeners();
  }
}
