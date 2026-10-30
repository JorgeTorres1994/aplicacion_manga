import 'package:flutter/cupertino.dart';

class MangasModels with ChangeNotifier {
  String id, title, imageUrl, mangaCategoryName, type, pdfUrl, numberPages;
  String description;
  String autor;
  String estado;
  List<String> tags;
  double rating;
  int numRatings;

  MangasModels({
    this.id = '',
    this.title = '',
    this.imageUrl = '',
    this.mangaCategoryName = '',
    this.type = '',
    this.numberPages = '',
    this.pdfUrl = '',
    this.description = '',
    this.autor = '',
    this.estado = 'EN EMISIÓN',
    this.tags = const [],
    this.rating = 5.0,
    this.numRatings = 0,
  });
}
