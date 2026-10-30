import 'package:aplicacion_manga/models/mangas_models.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class MangasProvider with ChangeNotifier {
  static final List<MangasModels> _mangasList = [];

  var pdfUrl;
  List<MangasModels> get getMangas {
    return _mangasList;
  }

  Future<void> fetchMangas() async {
    try {
      final newMangasList = <MangasModels>[];

      final mangaSnapshot =
          await FirebaseFirestore.instance.collection('mangas').get();

      for (var element in mangaSnapshot.docs) {
        final data = element.data();
        newMangasList.add(MangasModels(
          id: (data['id'] != null && data['id'].toString().isNotEmpty)
              ? data['id'].toString()
              : element.id,
          title: data['title']?.toString() ?? 'Sin título',
          imageUrl: data['imageUrl']?.toString() ??
              data['coverUrl']?.toString() ??
              '',
          mangaCategoryName: data['mangaCategoryName']?.toString() ??
              data['category']?.toString() ??
              'Shonen',
          type: data['type']?.toString() ??
              data['status']?.toString() ??
              'MANGA',
          numberPages: data['numberPages']?.toString() ?? '0',
          pdfUrl: data['pdfUrl']?.toString() ?? '',
        ));
      }

      _mangasList.clear();
      _mangasList.addAll(newMangasList);
      print('fetchMangas completado correctamente.');
      notifyListeners();
    } catch (error) {
      print("Error al cargar mangas: $error");
      rethrow;
    }
  }

  MangasModels findMangabyId(String mangaId) {
    //BUSCAR MANGA POR ID
    return _mangasList.firstWhere((element) => element.id == mangaId);
  }

  List<MangasModels> findByCategory(String categoryName) {
    //BUSCAR MANGA POR NOMBRE DE CATEGORIA
    List<MangasModels> categoryList = _mangasList
        .where((element) => element.mangaCategoryName
            .toLowerCase()
            .contains(categoryName.toLowerCase()))
        .toList();
    return categoryList;
  }

  List<MangasModels> searchQuery(String searchText) {
    //BUSCAR MANGA POR NOMBRE DE CATEGORIA
    List<MangasModels> searchList = _mangasList
        .where(
          (element) =>
              element.title.toLowerCase().contains(searchText.toLowerCase()),
        )
        .toList();
    return searchList;
  }
}
