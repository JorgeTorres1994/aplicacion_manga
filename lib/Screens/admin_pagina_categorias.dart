import 'package:aplicacion_manga/services/utils.dart';
import 'package:aplicacion_manga/widgets/categories_widget.dart';
import 'package:aplicacion_manga/widgets/textos_widget.dart';
import 'package:flutter/material.dart';

// ignore: must_be_immutable
class AdminPaginaCategorias extends StatelessWidget {
  AdminPaginaCategorias({Key? key}) : super(key: key);

  List<Color> gridColors = [
    const Color(0xff53B175),
    const Color(0xffF8A44C),
    const Color(0xffF7A593),
    const Color(0xffD3B0E0),
    const Color(0xffFDE598),
    const Color(0xffB7DFF5),
  ];

  List<Map<String, dynamic>> catInfo = [
    {
      'imgPath': 'iconos/iconoComedia.png',
      'catText': 'Comedia',
    },
    {
      'imgPath': 'iconos/iconoEscolar.png',
      'catText': 'Escolar',
    },
    {
      'imgPath': 'iconos/iconoGore.png',
      'catText': 'Gore',
    },
    {
      'imgPath': 'iconos/iconoMisterio.png',
      'catText': 'Misterio',
    },
    {
      'imgPath': 'iconos/iconoRomance.png',
      'catText': 'Romance',
    },
    {
      'imgPath': 'iconos/iconoShonen.png',
      'catText': 'Shonen',
    },
  ];

  @override
  Widget build(BuildContext context) {
    final utils = Utils(context);
    Color color = utils.color;
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        title: TextosWidget(
          text: 'Género',
          color: color,
          textSize: 24,
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: GridView.count(
            crossAxisCount: 2,
            childAspectRatio: 240 / 250,
            crossAxisSpacing: 10, //Espacio vertical
            mainAxisSpacing: 10, //Espacio horizontal
            children: List.generate(6, (index) {
              return CategoriesWidget(
                catText: catInfo[index]['catText'],
                imgPath: catInfo[index]['imgPath'],
                passedColor: gridColors[index],
              );
            })),
      ),
    );
  }
}
