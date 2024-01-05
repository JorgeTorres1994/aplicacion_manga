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

      mangaSnapshot.docs.forEach((element) {
        newMangasList.add(MangasModels(
          id: element.get('id'),
          title: element.get('title'),
          imageUrl: element.get('imageUrl'),
          mangaCategoryName: element.get('mangaCategoryName'),
          type: element.get('type'),
          numberPages: element.get('numberPages'),
          pdfUrl: element.get('pdfUrl'),
        ));
      });

      _mangasList.clear();
      _mangasList.addAll(newMangasList);
      print('fetchMangas completado correctamente.');
      notifyListeners();
    } catch (error) {
      print("Error al cargar mangas: $error");
      throw error;
    }
  }

  MangasModels findMangabyId(String mangaId) {
    //BUSCAR MANGA POR ID
    return _mangasList.firstWhere((element) => element.id == mangaId);
  }

  List<MangasModels> findByCategory(String categoryName) {
    //BUSCAR MANGA POR NOMBRE DE CATEGORIA
    List<MangasModels> _categoryList = _mangasList
        .where((element) => element.mangaCategoryName
            .toLowerCase()
            .contains(categoryName.toLowerCase()))
        .toList();
    return _categoryList;
  }

  List<MangasModels> searchQuery(String searchText) {
    //BUSCAR MANGA POR NOMBRE DE CATEGORIA
    List<MangasModels> _searchList = _mangasList
        .where(
          (element) =>
              element.title.toLowerCase().contains(searchText.toLowerCase()),
        )
        .toList();
    return _searchList;
  }
}
