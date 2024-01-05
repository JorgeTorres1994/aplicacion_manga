import 'package:flutter/cupertino.dart';

class MangasModels with ChangeNotifier {
  String id, title, imageUrl, mangaCategoryName, type, pdfUrl, numberPages;
  double? rating;
  int? numRatings;
  MangasModels(
      {this.id = '',
      this.title = '',
      this.imageUrl = '',
      this.mangaCategoryName = '',
      this.type = '',
      this.numberPages = '',
      this.pdfUrl = ''});
}
