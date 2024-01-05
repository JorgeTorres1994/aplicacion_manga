import 'package:flutter/material.dart';

class WishListModels with ChangeNotifier {
  final String id, mangaId;

  WishListModels({
    required this.id,
    required this.mangaId,
  });
}
