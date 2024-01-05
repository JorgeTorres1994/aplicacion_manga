import 'package:aplicacion_manga/inner_screens/OnlineViewScreen.dart';
import 'package:aplicacion_manga/models/detalle_puntuacion_model.dart';
import 'package:aplicacion_manga/providers/comment_provider.dart';
import 'package:aplicacion_manga/providers/mangas_providers.dart';
import 'package:aplicacion_manga/providers/viewed_providers.dart';
import 'package:aplicacion_manga/providers/wishlist_providers.dart';
import 'package:aplicacion_manga/services/utils.dart';
import 'package:aplicacion_manga/widgets/textos_widget.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fancy_shimmer_image/fancy_shimmer_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:flutter_iconly/flutter_iconly.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

class MangaDetails extends StatefulWidget {
  //static const routeName = '/ProductDetails';
  static const routeName = '/MangaDetails';

  const MangaDetails({Key? key}) : super(key: key);

  @override
  _MangaDetailsState createState() => _MangaDetailsState();
}

class _MangaDetailsState extends State<MangaDetails> {
  TextEditingController _commentController = TextEditingController();
  List<Map<String, dynamic>> _comments = [];
  bool _isContentLoaded =
      false; // Agregamos una variable para controlar la carga de contenido
  double _userRating = 0.0;

  void _downloadPDF(String pdfUrl, String title) async {
    try {
      final taskId = await FlutterDownloader.enqueue(
        url: pdfUrl,
        savedDir: '/storage/emulated/0/Download/', // Directorio de descarga
        fileName: '$title.pdf', // Nombre del archivo
        showNotification: true,
        openFileFromNotification: true,
      );
      print('Tarea de descarga iniciada: $taskId');
      Fluttertoast.showToast(
        msg: 'El manga $title fue descargado con éxito.',
        gravity: ToastGravity.BOTTOM, // Puedes ajustar la posición del mensaje
        toastLength:
            Toast.LENGTH_SHORT, // Puedes ajustar la duración del mensaje
      );
    } catch (error) {
      print('Error al iniciar la descarga: $error');
    }
  }

  void _submitComment() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final commentContent = _commentController.text;
      final mangaId = ModalRoute.of(context)!.settings.arguments as String;
      final userDocRef =
          FirebaseFirestore.instance.collection('users').doc(user.uid);
      final commentData = {
        'contenido': commentContent,
        'usuarioId': user.uid,
        'usuarioDocRef':
            userDocRef, // Guardar la referencia al documento de usuario
        'mangaId': mangaId,
        'fecha': DateTime.now().toString(),
      };

      // Acceder al Provider de comentarios
      final commentProvider =
          Provider.of<CommentProvider>(context, listen: false);

      // Generar un ID único para el comentario
      final commentId =
          FirebaseFirestore.instance.collection('comments').doc().id;

      // Agregar el comentario al Provider
      commentProvider.addComment(commentData, commentId);

      // Guardar el comentario en Firestore en la colección "comments"
      final commentsRef = FirebaseFirestore.instance.collection('comments');
      await commentsRef.doc(commentId).set(commentData);

      setState(() {
        _comments.add(commentData); // Agregar el comentario a la lista
        _commentController.clear();
      });
    }
  }

  /*void initState() {
    super.initState();
    final commentProvider =
        Provider.of<CommentProvider>(context, listen: false);
    //commentProvider.fetchCommentsFromFirebase();
    commentProvider.fetchCommentsFromFirebase().then((_) {
      setState(() {
        _isContentLoaded = true; // Marcamos que el contenido se ha cargado
      });
    });
    // Asegúrate de que el manga esté disponible antes de intentar acceder a sus propiedades
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final mangasProvider =
          Provider.of<MangasProvider>(context, listen: false);
      final mangaId = ModalRoute.of(context)!.settings.arguments as String;
      final getCurrManga = mangasProvider.findMangabyId(mangaId);
      if (getCurrManga != null) {
        // Aquí puedes inicializar _userRating si el manga está disponible
        setState(() {
          _userRating = getCurrManga.rating ?? 0.0;
        });
      }
    });
  }*/

  void initState() {
    super.initState();
    final commentProvider =
        Provider.of<CommentProvider>(context, listen: false);
    //commentProvider.fetchCommentsFromFirebase();
    commentProvider.fetchCommentsFromFirebase().then((_) {
      setState(() {
        _isContentLoaded = true; // Marcamos que el contenido se ha cargado
      });
    });
    final mangasProvider = Provider.of<MangasProvider>(context, listen: false);

    WidgetsBinding.instance?.addPostFrameCallback((_) async {
      final mangaId = ModalRoute.of(context)!.settings.arguments as String;
      final getCurrManga = mangasProvider.findMangabyId(mangaId);

      if (getCurrManga != null) {
        // Obtén el rating del manga
        final detallePuntuacionRef =
            FirebaseFirestore.instance.collection('detalle_puntuacion');
        final userUid = FirebaseAuth.instance.currentUser?.uid;

        if (userUid != null) {
          final detallePuntuacionQuery = await detallePuntuacionRef
              .where('idUsuario', isEqualTo: userUid)
              .where('idManga', isEqualTo: mangaId)
              .limit(1)
              .get();

          if (detallePuntuacionQuery.docs.isNotEmpty) {
            final detallePuntuacionDoc = detallePuntuacionQuery.docs.first;
            final userRating = detallePuntuacionDoc['rating'] ?? 0.0;

            // Actualiza el rating en el estado
            setState(() {
              _userRating = userRating;
            });
          }
        }
      }
    });
  }

  @override
  void dispose() {
    _commentController.dispose(); // Liberar recursos del controlador
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Size size = Utils(context).getScreenSize;
    final Color color = Utils(context).color;
    final mangasProvider = Provider.of<MangasProvider>(context);
    final mangaId = ModalRoute.of(context)!.settings.arguments as String;
    final getCurrManga = mangasProvider.findMangabyId(mangaId);

    final wishListProvider = Provider.of<WishListProvider>(context);
    /*bool? _isWishList =
        wishListProvider.getWishListItems.containsKey(getCurrManga.id);*/

    final viewedMangaProvider = Provider.of<ViewedMangaProvider>(context);

    final commentProvider =
        Provider.of<CommentProvider>(context, listen: false);

    return WillPopScope(
      onWillPop: () async {
        viewedMangaProvider.addMangasToHistory(mangaId: mangaId);
        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          leading: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () =>
                Navigator.canPop(context) ? Navigator.pop(context) : null,
            child: Icon(
              IconlyLight.arrowLeft2,
              color: color,
              size: 24,
            ),
          ),
          elevation: 0,
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        ),
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Imagen del manga
              FancyShimmerImage(
                imageUrl: getCurrManga.imageUrl,
                boxFit: BoxFit.scaleDown,
                width: size.width,
              ),
              // Detalles del manga
              Padding(
                padding: const EdgeInsets.all(7.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            /*RatingBar.builder(
                                initialRating: _userRating,
                                minRating: 1,
                                direction: Axis.horizontal,
                                allowHalfRating: false,
                                itemCount: 5,
                                itemBuilder: (context, _) => Icon(
                                      Icons.star,
                                      color: Colors.amber,
                                      size: 30,
                                    ),
                                onRatingUpdate: (rating) async {
                                  setState(() {
                                    _userRating = rating;
                                  });

                                  if (getCurrManga != null) {
                                    final mangasRef = FirebaseFirestore.instance
                                        .collection('mangas');
                                    final detallePuntuacionRef =
                                        FirebaseFirestore.instance
                                            .collection('detalle_puntuacion');

                                    final userUid =
                                        FirebaseAuth.instance.currentUser?.uid;

                                    if (userUid != null) {
                                      // Buscar el registro de detalle_puntuacion del usuario actual para este manga
                                      final detallePuntuacionQuery =
                                          await detallePuntuacionRef
                                              .where('idUsuario',
                                                  isEqualTo: userUid)
                                              .where('idManga',
                                                  isEqualTo: mangaId)
                                              .limit(1)
                                              .get();

                                      if (detallePuntuacionQuery
                                          .docs.isNotEmpty) {
                                        // Si el usuario ya votó antes, actualiza el rating en detalle_puntuacion
                                        final detallePuntuacionDoc =
                                            detallePuntuacionQuery.docs.first;
                                        final currentRating =
                                            detallePuntuacionDoc['rating'] ??
                                                0.0;

                                        // Resta el voto anterior y suma el nuevo voto
                                        final newRating =
                                            (getCurrManga.rating ?? 0.0) -
                                                currentRating +
                                                _userRating;

                                        await mangasRef.doc(mangaId).update({
                                          'rating': newRating /
                                              (getCurrManga.numRatings ?? 1),
                                        });

                                        await detallePuntuacionDoc.reference
                                            .update({
                                          'numeroRating':
                                              FieldValue.increment(1),
                                          'rating': _userRating,
                                        });
                                      } else {
                                        // Si es la primera vez que vota, guarda la puntuación en detalle_puntuacion
                                        final newRating =
                                            (getCurrManga.rating ?? 0.0) *
                                                    (getCurrManga.numRatings ??
                                                        0) +
                                                _userRating /
                                                    ((getCurrManga.numRatings ??
                                                            0) +
                                                        1);

                                        await mangasRef.doc(mangaId).update({
                                          'rating': newRating /
                                              (getCurrManga.numRatings ?? 1),
                                          'numRatings': FieldValue.increment(1),
                                        });

                                        final detallePuntuacion =
                                            DetallePuntuacion(
                                          idUsuario: userUid,
                                          idManga: mangaId,
                                          numeroRating: 1,
                                          rating: _userRating,
                                        );

                                        try {
                                          await detallePuntuacionRef
                                              .add(detallePuntuacion.toMap());
                                        } catch (error) {
                                          print(
                                              'Error al guardar la puntuación del usuario: $error');
                                        }
                                      }
                                    }
                                  }
                                }),
                            SizedBox(width: 8),
                            Text(
                              'Rating: ${getCurrManga.rating?.toStringAsFixed(1) ?? "N/A"}',
                            ),*/
                            Text("Rating: $_userRating"),
                            RatingBar.builder(
                              initialRating: _userRating,
                              minRating: 1,
                              direction: Axis.horizontal,
                              allowHalfRating: false,
                              itemCount: 5,
                              itemSize: 30,
                              itemBuilder: (context, _) => Icon(
                                Icons.star,
                                color: Colors.amber,
                              ),
                              onRatingUpdate: (rating) async {
                                setState(() {
                                  _userRating = rating;
                                });

                                if (getCurrManga != null) {
                                  final mangasRef = FirebaseFirestore.instance
                                      .collection('mangas');
                                  final detallePuntuacionRef = FirebaseFirestore
                                      .instance
                                      .collection('detalle_puntuacion');

                                  final userUid =
                                      FirebaseAuth.instance.currentUser?.uid;

                                  if (userUid != null) {
                                    // Buscar el registro de detalle_puntuacion del usuario actual para este manga
                                    final detallePuntuacionQuery =
                                        await detallePuntuacionRef
                                            .where('idUsuario',
                                                isEqualTo: userUid)
                                            .where('idManga',
                                                isEqualTo: mangaId)
                                            .limit(1)
                                            .get();

                                    if (detallePuntuacionQuery
                                        .docs.isNotEmpty) {
                                      // Si el usuario ya votó antes, actualiza el rating en detalle_puntuacion
                                      final detallePuntuacionDoc =
                                          detallePuntuacionQuery.docs.first;
                                      final currentRating =
                                          detallePuntuacionDoc['rating'] ?? 0.0;

                                      // Resta el voto anterior y suma el nuevo voto
                                      final newRating =
                                          (getCurrManga.rating ?? 0.0) -
                                              currentRating +
                                              _userRating;

                                      await mangasRef.doc(mangaId).update({
                                        'rating': newRating /
                                            (getCurrManga.numRatings ?? 1),
                                      });

                                      await detallePuntuacionDoc.reference
                                          .update({
                                        'numeroRating': FieldValue.increment(1),
                                        'rating': _userRating,
                                      });
                                    } else {
                                      // Si es la primera vez que vota, guarda la puntuación en detalle_puntuacion
                                      final newRating = (getCurrManga.rating ??
                                                  0.0) *
                                              (getCurrManga.numRatings ?? 0) +
                                          _userRating /
                                              ((getCurrManga.numRatings ?? 0) +
                                                  1);

                                      await mangasRef.doc(mangaId).update({
                                        'rating': newRating /
                                            (getCurrManga.numRatings ?? 1),
                                        'numRatings': FieldValue.increment(1),
                                      });

                                      final detallePuntuacion =
                                          DetallePuntuacion(
                                        idUsuario: userUid,
                                        idManga: mangaId,
                                        numeroRating: 1,
                                        rating: _userRating,
                                      );

                                      try {
                                        await detallePuntuacionRef
                                            .add(detallePuntuacion.toMap());
                                      } catch (error) {
                                        print(
                                            'Error al guardar la puntuación del usuario: $error');
                                      }
                                    }
                                  }
                                }
                              },
                            ),
                            SizedBox(height: 20),
                            // Título del manga
                            TextosWidget(
                              text: getCurrManga.title,
                              color: color,
                              textSize: 25,
                              isTitle: true,
                            ),

                            SizedBox(height: 15),
                            TextosWidget(
                              text: 'Género: ${getCurrManga.mangaCategoryName}',
                              color: Colors.green,
                              textSize: 22,
                              isTitle: true,
                            ),
                            SizedBox(height: 15),
                            TextosWidget(
                              text: 'Tipo: ${getCurrManga.type}',
                              color: Colors.white60,
                              textSize: 22,
                              isTitle: true,
                            ),
                            SizedBox(height: 15),
                            TextosWidget(
                              text: 'Páginas: ${getCurrManga.numberPages}',
                              color: Colors.red.shade300,
                              textSize: 20,
                              isTitle: true,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              // Botones de Ver Online y Descargar
              Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 20, horizontal: 30),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                      onPressed: () async {
                        final pdfUrl = getCurrManga.pdfUrl;
                        final mangaTitle = getCurrManga.title;

                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => OnlineViewScreen(
                              pdfUrl: pdfUrl,
                              mangaTitle: mangaTitle,
                            ),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        primary: Colors.redAccent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: Text('Ver online',
                          style: TextStyle(color: Colors.white, fontSize: 18)),
                    ),
                    ElevatedButton(
                      onPressed: () async {
                        PermissionStatus status =
                            await Permission.storage.request();

                        if (status.isGranted) {
                          _downloadPDF(getCurrManga.pdfUrl, getCurrManga.title);
                        } else {
                          if (status.isPermanentlyDenied) {
                            // El usuario denegó permanentemente los permisos, muestra una alerta o una pantalla de configuración
                            openAppSettings();
                          } else {
                            // El usuario denegó temporalmente los permisos
                            print('Los permisos no fueron otorgados');
                          }
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        primary: Colors.green,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: Text('Descargar',
                          style: TextStyle(color: Colors.white, fontSize: 18)),
                    )
                  ],
                ),
              ),
              // Comentarios
              Builder(builder: (context) {
                if (_isContentLoaded) {
                  return Container(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Comentarios',
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold)),
                        SizedBox(height: 10),
                        ListView.builder(
                          shrinkWrap: true,
                          //itemCount: _comments.length,
                          itemCount: commentProvider.comments
                              .where((comment) => comment['mangaId'] == mangaId)
                              .length, // Obtener la longitud de los comentarios del Provider
                          itemBuilder: (ctx, index) {
                            //final comment = _comments[index];
                            //final commentId = commentProvider.getCommentIdAtIndex(index);

                            final filteredComments = commentProvider.comments
                                .where(
                                    (comment) => comment['mangaId'] == mangaId)
                                .toList();

                            final comment = filteredComments[index];
                            final userDocRef =
                                comment['usuarioDocRef'] as DocumentReference;
                            final commentId = comment[
                                'commentId']; // Obtener el commentId directamente
                            return FutureBuilder<DocumentSnapshot>(
                              future: userDocRef.get(),
                              builder: (ctx, snapshot) {
                                if (snapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  return ListTile(
                                    title: Text(comment['contenido']),
                                    subtitle: Text('Cargando usuario...'),
                                  );
                                }
                                if (snapshot.hasError) {
                                  return ListTile(
                                    title: Text(comment['contenido']),
                                    subtitle: Text('Error al obtener usuario'),
                                  );
                                }
                                final userData = snapshot.data?.data()
                                    as Map<String, dynamic>;
                                final username = userData[
                                    'usuario']; // Cambia 'username' por el campo que almacena el nombre de usuario en tu colección de usuarios
                                return ListTile(
                                  //title: Text(comment['contenido']),
                                  subtitle: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(comment['contenido'],
                                                style: TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 18)),
                                            IconButton(
                                              icon: Icon(Icons.edit),
                                              onPressed: () {
                                                _editComment(
                                                    index, commentId, comment);
                                                (commentId, comment);
                                              },
                                            ),
                                            /*SizedBox(
                                          height: 20,
                                        ),*/
                                          ]),
                                      Text('Usuario: $username'),
                                      SizedBox(
                                          height:
                                              8), // Agrega un espacio vertical
                                      Text('Fecha: ' + comment['fecha']),
                                    ],
                                  ),
                                );
                              },
                            );
                          },
                        ),
                        SizedBox(height: 10),
                        TextField(
                          controller: _commentController,
                          decoration: InputDecoration(
                            hintText: 'Agregar comentario...',
                          ),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            if (_commentController.text.isNotEmpty) {
                              _submitComment();
                            }
                          },
                          child: Text('Agregar Comentario'),
                        ),
                      ],
                    ),
                  );
                } else {
                  return CircularProgressIndicator(); // O cualquier indicador de carga
                }
              })
            ],
          ),
        ),
      ),
    );
  }

  void _editComment(int index, String commentId, Map<String, dynamic> comment) {
    final commentProvider =
        Provider.of<CommentProvider>(context, listen: false);
    final TextEditingController _editController =
        TextEditingController(text: comment['contenido']);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Editar Comentario'),
          content: TextField(
            controller: _editController,
            onChanged: (newContent) {
              comment['contenido'] = newContent;
            },
            decoration: InputDecoration(labelText: 'Nuevo contenido'),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Cancelar'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Guardar'),
              onPressed: () async {
                final newContent = _editController.text;
                print('Nuevo contenido: $newContent');
                if (newContent.isNotEmpty) {
                  final commentsRef =
                      FirebaseFirestore.instance.collection('comments');

                  // Verificar si el documento existe antes de intentar actualizarlo
                  print('commentId: $commentId');
                  final commentDoc = await commentsRef.doc(commentId).get();
                  if (commentDoc.exists) {
                    print('Documento encontrado en Firestore');
                    await commentProvider.editComment(commentId, newContent);
                    await commentsRef
                        .doc(commentId)
                        .update({'contenido': newContent});

                    setState(() {
                      // Actualizar el comentario en la lista local
                      commentProvider.comments[index]['contenido'] = newContent;
                      print('Comentario actualizado en la lista local');
                    });
                  } else {
                    print('El documento no existe en Firestore.');
                  }
                  Navigator.of(context).pop();
                }
              },
            ),
          ],
        );
      },
    );
  }
}
