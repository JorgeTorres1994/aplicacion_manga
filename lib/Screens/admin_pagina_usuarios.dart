import 'package:aplicacion_manga/Screens/Leer%20Datos/get_user_name.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../../otros componentes/themaFondo.dart';

class AdminPaginaUsuarios extends StatefulWidget {
  const AdminPaginaUsuarios({Key? key}) : super(key: key);

  @override
  State<AdminPaginaUsuarios> createState() => _AdminPaginaUsuariosState();
}

class _AdminPaginaUsuariosState extends State<AdminPaginaUsuarios> {
  //final user = FirebaseAuth.instance.currentUser!;
  //documents ID
  List<String> docIds = [];

  //getDocIds
  Future getDocId() async {
    await FirebaseFirestore.instance
        .collection('users')
        .orderBy('nombres')
        .get()
        .then((snapshot) => snapshot.docs.forEach((document) {
              print(document.reference);
              docIds.add(document.reference.id);
            }));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        //child: Text('Página Control de Usuarios', style: semiBoltText20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              height: 30,
            ),
            Text('Página Control de Usuarios', style: semiBoltText20),
            SizedBox(
              height: 30,
            ),
            Text('Lista de Usuarios Registrados', style: semiBoltText14),
            Expanded(
                child: FutureBuilder(
                    future: getDocId(),
                    builder: (context, snapshot) {
                      return ListView.builder(
                          itemCount: docIds.length,
                          itemBuilder: (context, index) {
                            return Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: ListTile(
                                title: GetUsarName(documentId: docIds[index]),
                                tileColor: Colors.blueAccent,
                              ),
                            );
                          });
                    }))
          ],
        ),
      ),
    );
  }
}
