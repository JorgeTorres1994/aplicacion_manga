import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

class KuroReaderBackendService {
  final FirebaseFirestore? _firestore;
  final FirebaseAuth? _auth;

  KuroReaderBackendService({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
  })  : _firestore = firestore,
        _auth = auth;

  static final KuroReaderBackendService instance = KuroReaderBackendService();

  FirebaseFirestore? get _safeFirestore {
    if (_firestore != null) return _firestore;
    try {
      if (Firebase.apps.isNotEmpty) {
        return FirebaseFirestore.instance;
      }
    } catch (_) {}
    return null;
  }

  FirebaseAuth? get _safeAuth {
    if (_auth != null) return _auth;
    try {
      if (Firebase.apps.isNotEmpty) {
        return FirebaseAuth.instance;
      }
    } catch (_) {}
    return null;
  }

  String? get currentUid => _safeAuth?.currentUser?.uid;

  // ====================================================
  // 1. HISTORIAL DE LECTURA & "CONTINUAR LEYENDO"
  // ====================================================

  /// Registra o actualiza el progreso de lectura del usuario en Firestore
  Future<void> saveReadingProgress({
    required String uid,
    required String mangaId,
    required String mangaTitle,
    required String coverUrl,
    required String chapterTitle,
    required int currentPage,
    required int totalPages,
    String? tomoTitle,
    String? pdfUrl,
    List<String>? pageImages,
  }) async {
    try {
      final fs = _safeFirestore;
      if (fs == null || uid.isEmpty || mangaId.isEmpty) return;

      final double progress = totalPages > 0
          ? ((currentPage / totalPages) * 100).clamp(1.0, 100.0)
          : 0.0;

      final data = <String, dynamic>{
        'mangaId': mangaId,
        'mangaTitle': mangaTitle,
        'coverUrl': coverUrl,
        'chapterTitle': chapterTitle,
        'tomoTitle': tomoTitle ?? 'Tomo 01',
        'currentPage': currentPage,
        'totalPages': totalPages,
        'progressPercent': progress.round(),
        'pdfUrl': pdfUrl ?? '',
        'pageImages': pageImages ?? [],
        'ultima_lectura': FieldValue.serverTimestamp(),
      };

      // Guardar en la subcolección del usuario
      await fs
          .collection('users')
          .doc(uid)
          .collection('historial_lectura')
          .doc(mangaId)
          .set(data, SetOptions(merge: true));

      // Incrementar contador de lecturas globales en el manga
      await fs.collection('mangas').doc(mangaId).set({
        'lecturas': FieldValue.increment(1),
        'ultima_actividad': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      debugPrint('Error guardando progreso de lectura: $e');
    }
  }

  /// Obtiene la última lectura del lector para la tarjeta "CONTINUAR LEYENDO"
  Future<Map<String, dynamic>?> getLatestReading(String uid) async {
    try {
      final fs = _safeFirestore;
      if (fs == null || uid.isEmpty) return null;

      final snap = await fs
          .collection('users')
          .doc(uid)
          .collection('historial_lectura')
          .orderBy('ultima_lectura', descending: true)
          .limit(1)
          .get();

      if (snap.docs.isNotEmpty) {
        return snap.docs.first.data();
      }
    } catch (e) {
      debugPrint('Error consultando última lectura: $e');
    }
    return null;
  }

  /// Stream en tiempo real de la última lectura activa del usuario
  Stream<Map<String, dynamic>?> streamLatestReading(String uid) {
    final fs = _safeFirestore;
    if (fs == null || uid.isEmpty) {
      return Stream.value(null);
    }

    return fs
        .collection('users')
        .doc(uid)
        .collection('historial_lectura')
        .orderBy('ultima_lectura', descending: true)
        .limit(1)
        .snapshots()
        .map((snap) => snap.docs.isNotEmpty ? snap.docs.first.data() : null);
  }

  /// Stream del historial completo de lecturas del usuario
  Stream<List<Map<String, dynamic>>> streamReadingHistory(String uid) {
    final fs = _safeFirestore;
    if (fs == null || uid.isEmpty) {
      return Stream.value([]);
    }

    return fs
        .collection('users')
        .doc(uid)
        .collection('historial_lectura')
        .orderBy('ultima_lectura', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map((doc) => doc.data()).toList());
  }

  // ====================================================
  // 2. BIBLIOTECA PERSONAL & FAVORITOS (WISHLIST)
  // ====================================================

  /// Alterna el estado de un manga en la biblioteca del lector (agrega o elimina)
  Future<bool> toggleWishlist({
    required String uid,
    required String mangaId,
    String? title,
    String? imageUrl,
    String? category,
  }) async {
    try {
      final fs = _safeFirestore;
      if (fs == null || uid.isEmpty || mangaId.isEmpty) return false;

      final docRef = fs
          .collection('users')
          .doc(uid)
          .collection('favoritos')
          .doc(mangaId);

      final doc = await docRef.get();
      if (doc.exists) {
        await docRef.delete();
        return false; // Ahora ya no está en favoritos
      } else {
        await docRef.set({
          'mangaId': mangaId,
          'title': title ?? '',
          'imageUrl': imageUrl ?? '',
          'category': category ?? '',
          'fecha_agregado': FieldValue.serverTimestamp(),
        });
        return true; // Ahora sí está en favoritos
      }
    } catch (e) {
      debugPrint('Error alternando favoritos: $e');
      return false;
    }
  }

  /// Stream de los IDs de mangas favoritos del usuario
  Stream<Set<String>> streamWishlistIds(String uid) {
    final fs = _safeFirestore;
    if (fs == null || uid.isEmpty) {
      return Stream.value({});
    }

    return fs
        .collection('users')
        .doc(uid)
        .collection('favoritos')
        .snapshots()
        .map((snap) => snap.docs.map((d) => d.id).toSet());
  }

  /// Limpia todos los favoritos del lector
  Future<void> clearWishlist(String uid) async {
    try {
      final fs = _safeFirestore;
      if (fs == null || uid.isEmpty) return;

      final snap = await fs
          .collection('users')
          .doc(uid)
          .collection('favoritos')
          .get();

      final batch = fs.batch();
      for (var doc in snap.docs) {
        batch.delete(doc.reference);
      }
      await batch.commit();
    } catch (e) {
      debugPrint('Error limpiando favoritos: $e');
    }
  }

  // ====================================================
  // 3. CALIFICACIONES Y RESEÑAS
  // ====================================================

  /// Guarda la puntuación que un lector otorga a un manga
  Future<void> rateManga({
    required String mangaId,
    required String uid,
    required double rating,
  }) async {
    try {
      final fs = _safeFirestore;
      if (fs == null || mangaId.isEmpty || uid.isEmpty) return;

      await fs
          .collection('mangas')
          .doc(mangaId)
          .collection('ratings')
          .doc(uid)
          .set({
        'rating': rating,
        'fecha': FieldValue.serverTimestamp(),
      });

      // Recalcular promedio de puntuación
      final allRatings = await fs
          .collection('mangas')
          .doc(mangaId)
          .collection('ratings')
          .get();

      if (allRatings.docs.isNotEmpty) {
        double sum = 0;
        for (var doc in allRatings.docs) {
          sum += (doc.data()['rating'] as num?)?.toDouble() ?? 5.0;
        }
        final double avg = sum / allRatings.docs.length;

        await fs.collection('mangas').doc(mangaId).set({
          'rating': double.parse(avg.toStringAsFixed(1)),
          'numRatings': allRatings.docs.length,
        }, SetOptions(merge: true));
      }
    } catch (e) {
      debugPrint('Error calificando manga: $e');
    }
  }

  // ====================================================
  // 4. COMUNIDAD Y COMENTARIOS
  // ====================================================

  /// Publica un comentario en el manga
  Future<void> addComment({
    required String mangaId,
    required String uid,
    required String userName,
    required String comentario,
    double? rating,
    String? avatar,
    String? clan,
  }) async {
    try {
      final fs = _safeFirestore;
      if (fs == null || mangaId.isEmpty) return;

      await fs
          .collection('mangas')
          .doc(mangaId)
          .collection('comments')
          .add({
        'userId': uid,
        'autor': userName,
        'avatar': avatar ?? '',
        'comentario': comentario,
        'puntuacion': rating ?? 5.0,
        'clan': clan ?? 'CLAN CARMESÍ',
        'likes': 0,
        'fecha': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      debugPrint('Error publicando comentario: $e');
    }
  }

  /// Stream en vivo de comentarios de un manga
  Stream<List<Map<String, dynamic>>> streamComments(String mangaId) {
    final fs = _safeFirestore;
    if (fs == null || mangaId.isEmpty) {
      return Stream.value([]);
    }

    return fs
        .collection('mangas')
        .doc(mangaId)
        .collection('comments')
        .orderBy('fecha', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map((d) {
              final data = d.data();
              data['id'] = d.id;
              return data;
            }).toList());
  }

  // ====================================================
  // 5. ESTADÍSTICAS DEL LECTOR
  // ====================================================

  /// Calcula estadísticas reales del lector (mangas leídos, favoritos)
  Future<Map<String, dynamic>> getReaderStats(String uid) async {
    try {
      final fs = _safeFirestore;
      if (fs == null || uid.isEmpty) {
        return {'mangasLeidos': 0, 'favoritosCount': 0, 'nivel': 42};
      }

      final histSnap = await fs
          .collection('users')
          .doc(uid)
          .collection('historial_lectura')
          .get();

      final favSnap = await fs
          .collection('users')
          .doc(uid)
          .collection('favoritos')
          .get();

      final userDoc = await fs.collection('users').doc(uid).get();
      final userData = userDoc.data() ?? {};

      return {
        'mangasLeidos': histSnap.docs.length,
        'favoritosCount': favSnap.docs.length,
        'nivel': userData['nivel'] ?? (histSnap.docs.length * 2 + 10),
        'clan': userData['clan'] ?? 'Carmesí',
        'rango': userData['rango'] ?? 'LECTOR',
      };
    } catch (_) {
      return {'mangasLeidos': 0, 'favoritosCount': 0, 'nivel': 42};
    }
  }
}
