import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class CommentProvider extends ChangeNotifier {
  List<Map<String, dynamic>> _comments = [];

  List<Map<String, dynamic>> get comments => _comments;

  void addComment(Map<String, dynamic> commentData, String commentId) {
    // Agregar el ID del comentario a los datos
    commentData['commentId'] = commentId;
    _comments.add(commentData);
    notifyListeners();
  }

  /*Future<void> fetchCommentsFromFirebase() async {
    final commentsRef = FirebaseFirestore.instance.collection('comments');
    final commentsSnapshot = await commentsRef.get();

    _comments = commentsSnapshot.docs.map((doc) => doc.data()).toList();
    notifyListeners();
  }*/

  Future<void> fetchCommentsFromFirebase() async {
    final commentsRef = FirebaseFirestore.instance.collection('comments');

    commentsRef.snapshots().listen((commentsSnapshot) {
      _comments = commentsSnapshot.docs.map((doc) => doc.data()).toList();
      notifyListeners();
    });
  }

  Future<void> editComment(String commentId, String newContent) async {
    final commentIndex =
        _comments.indexWhere((comment) => comment['id'] == commentId);

    if (commentIndex != -1) {
      _comments[commentIndex]['contenido'] = newContent;
      notifyListeners();

      // Actualiza el comentario en Firestore si es necesario
      final commentsRef = FirebaseFirestore.instance.collection('comments');
      await commentsRef.doc(commentId).update({'contenido': newContent});
    }
  }

  String getCommentIdAtIndex(int index) {
    if (index >= 0 && index < _comments.length) {
      final comment = _comments[index];
      if (comment != null && comment.containsKey('commentId')) {
        return comment['commentId'] as String;
      }
    }
    return '';
  }
}
