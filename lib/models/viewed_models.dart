import 'package:flutter/material.dart';

class ViewedMangaModels with ChangeNotifier {
  final String id, mangaId;

  ViewedMangaModels({
    required this.id,
    required this.mangaId,
  });
}
