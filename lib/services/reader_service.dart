import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
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

  /// Publica un comentario en la colección raíz unificada 'comentarios'
  Future<void> addComment({
    required String mangaId,
    String? mangaTitle,
    required String uid,
    required String userName,
    required String comentario,
    double? rating,
    String? avatar,
    String? rol,
    String? rango,
    String? clan,
  }) async {
    try {
      final fs = _safeFirestore;
      if (fs == null || mangaId.isEmpty) return;

      String userRole = rol ?? 'reader';
      String userRango = rango ?? 'Lector Regular';
      String userClan = clan ?? 'CLAN CARMESÍ';
      String userAvatar = avatar ?? '';

      if (uid.isNotEmpty) {
        try {
          final uDoc = await fs.collection('users').doc(uid).get();
          if (uDoc.exists && uDoc.data() != null) {
            final uData = uDoc.data()!;
            userRole = uData['rol']?.toString() ?? userRole;
            userRango = uData['rango']?.toString() ?? userRango;
            userClan = uData['clan']?.toString() ?? userClan;
            if (userAvatar.isEmpty) {
              userAvatar = uData['avatar']?.toString() ?? '';
            }
          }
        } catch (_) {}
      }

      await fs.collection('comentarios').add({
        'mangaId': mangaId,
        'mangaTitle': mangaTitle ?? '',
        'userId': uid,
        'autor': userName,
        'avatar': userAvatar,
        'rol': userRole,
        'rango': userRango,
        'clan': userClan,
        'comentario': comentario,
        'puntuacion': rating ?? 5.0,
        'likes': 0,
        'reportado': false,
        'estado': 'publicado',
        'reportsCount': 0,
        'fecha': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      debugPrint('Error publicando comentario: $e');
    }
  }

  /// Stream en vivo de comentarios de un manga desde la colección unificada 'comentarios'
  Stream<List<Map<String, dynamic>>> streamComments(String mangaId) {
    final fs = _safeFirestore;
    if (fs == null || mangaId.isEmpty) {
      return Stream.value([]);
    }

    return fs
        .collection('comentarios')
        .where('mangaId', isEqualTo: mangaId)
        .snapshots()
        .map((snap) {
      final list = snap.docs.map((d) {
        final data = d.data();
        data['id'] = d.id;
        return data;
      }).toList();

      list.sort((a, b) {
        final aDate = (a['fecha'] as Timestamp?)?.toDate() ?? DateTime(2000);
        final bDate = (b['fecha'] as Timestamp?)?.toDate() ?? DateTime(2000);
        return bDate.compareTo(aDate);
      });

      return list;
    });
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

  // ====================================================
  // 6. PERFIL DEL LECTOR (EDICIÓN Y ACTUALIZACIÓN)
  // ====================================================

  /// Carga datos del perfil de un lector desde Firestore
  Future<Map<String, dynamic>?> loadReaderProfile(String uid) async {
    try {
      final fs = _safeFirestore;
      if (fs == null || uid.isEmpty) return null;
      final doc = await fs.collection('users').doc(uid).get();
      if (doc.exists && doc.data() != null) {
        return doc.data();
      }
    } catch (e) {
      debugPrint('Error cargando perfil de lector: $e');
    }
    return null;
  }

  /// Guarda y actualiza los datos del lector en la colección 'users'
  Future<bool> saveReaderProfile({
    required String uid,
    required String nombre,
    required String celular,
    required String clan,
    String? bio,
    String? avatar,
    String? colorAcento,
  }) async {
    try {
      final fs = _safeFirestore;
      if (fs == null || uid.isEmpty) return false;

      final updateMap = <String, dynamic>{
        'usuario': nombre.trim(),
        'celular': celular.trim(),
        'clan': clan.trim(),
        'bio': (bio ?? 'Lector de Manga').trim(),
        'fecha_actualizacion': FieldValue.serverTimestamp(),
      };

      if (avatar != null && avatar.isNotEmpty) {
        updateMap['avatar'] = avatar.trim();
      }
      if (colorAcento != null && colorAcento.isNotEmpty) {
        updateMap['colorAcento'] = colorAcento.trim();
      }

      // Eliminar posibles campos duplicados obsoletos
      updateMap['email'] = FieldValue.delete();
      updateMap['telefono'] = FieldValue.delete();

      await fs.collection('users').doc(uid).set(updateMap, SetOptions(merge: true));

      final authUser = _safeAuth?.currentUser;
      if (authUser != null) {
        if (nombre.trim().isNotEmpty) {
          await authUser.updateDisplayName(nombre.trim()).catchError((_) {});
        }
        if (avatar != null && avatar.trim().isNotEmpty && avatar.startsWith('http')) {
          await authUser.updatePhotoURL(avatar.trim()).catchError((_) {});
        }
      }
      return true;
    } catch (e) {
      debugPrint('Error guardando perfil de lector: $e');
      return false;
    }
  }

  /// Sube una foto de perfil para el lector a Firebase Storage y la guarda en users
  Future<String?> uploadReaderAvatar({
    required String uid,
    required File imageFile,
  }) async {
    try {
      final storage = FirebaseStorage.instance;
      final fileName = 'reader_${uid}_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final ref = storage.ref().child('usuarios_avatares').child(fileName);
      await ref.putFile(imageFile);
      final downloadUrl = await ref.getDownloadURL();

      final fs = _safeFirestore;
      if (fs != null && uid.isNotEmpty) {
        await fs.collection('users').doc(uid).set({
          'avatar': downloadUrl,
          'fecha_actualizacion': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
      }

      final authUser = _safeAuth?.currentUser;
      if (authUser != null) {
        await authUser.updatePhotoURL(downloadUrl).catchError((_) {});
      }

      return downloadUrl;
    } catch (e) {
      debugPrint('Error subiendo avatar de lector: $e');
      return null;
    }
  }
}

