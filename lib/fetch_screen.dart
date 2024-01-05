//import 'package:aplicacion_manga/Screens/admin_pagina_principal.dart';
import 'package:aplicacion_manga/Screens/admin_pagina_principal.dart';
import 'package:aplicacion_manga/otros%20componentes/contss.dart';
import 'package:aplicacion_manga/providers/mangas_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:provider/provider.dart';

class FetchScreen extends StatefulWidget {
  const FetchScreen({Key? key}) : super(key: key);

  @override
  State<FetchScreen> createState() => _FetchScreenState();
}

class _FetchScreenState extends State<FetchScreen> {
  List<String> images = Constss.authImagesCarga;

  @override
  void initState() {
    super.initState();
    images.shuffle();

    // Agregamos un pequeño retraso para dar tiempo al framework de Flutter
    // a realizar otras operaciones antes de cargar los mangas
    Future.delayed(const Duration(seconds: 1), () async {
      try {
        print('Iniciando fetchMangas...');
        final mangasProvider =
            Provider.of<MangasProvider>(context, listen: false);
        await mangasProvider.fetchMangas();
        print('fetchMangas completado correctamente.');

        // Utilizamos Navigator.pushReplacement después de asegurarnos de que fetchMangas se haya completado.
        Navigator.of(context).pushReplacement(MaterialPageRoute(
          builder: (ctx) => const AdminPaginaPrincipal(),
        ));
      } catch (error) {
        print('Error en fetchMangas: $error');
        // Puedes manejar el error de alguna manera, mostrar un mensaje al usuario, etc.
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Image.asset(
            images[0],
            fit: BoxFit.cover,
            height: double.infinity,
          ),
          Container(
            color: Colors.black.withOpacity(0.7),
          ),
          const Center(
            child: SpinKitFadingFour(
              color: Colors.white,
            ),
          )
        ],
      ),
    );
  }
}
