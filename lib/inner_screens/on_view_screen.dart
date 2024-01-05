import 'package:aplicacion_manga/models/mangas_models.dart';
import 'package:aplicacion_manga/providers/mangas_providers.dart';
import 'package:aplicacion_manga/services/utils.dart';
import 'package:aplicacion_manga/widgets/back_widget.dart';
import 'package:aplicacion_manga/widgets/empty_manga_widget.dart';
import 'package:aplicacion_manga/widgets/on_view_widget.dart';
import 'package:aplicacion_manga/widgets/textos_widget.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class OnViewScreen extends StatelessWidget {
  static const routeName = "/OnViewScreen"; //ruta de la interfaz
  const OnViewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    //bool _isEmpty = false;
    Size size = Utils(context).getScreenSize;
    final Color color = Utils(context).color;
    final mangasProvider = Provider.of<MangasProvider>(context);
    List<MangasModels> allMangas = mangasProvider.getMangas;
    bool _isEmpty = allMangas.isEmpty; // Verificar si la lista está vacía
    return Scaffold(
      appBar: AppBar(
        leading: BackWidget(),
        elevation: 0,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        title: TextosWidget(
          text: 'MANGAS POR VER',
          color: color,
          textSize: 24.0,
          isTitle: true,
        ),
      ),
      body: _isEmpty
          ? EmptyMangaWidget(
              text: 'Aún no hay mangas vistos',
            )
          : GridView.count(
              crossAxisCount: 2,
              padding: const EdgeInsets.all(35),
              childAspectRatio: size.width / (size.height * 0.89),
              children: List.generate(allMangas.length, (index) {
                return ChangeNotifierProvider.value(
                  value: allMangas[index],
                  child: const OnViewWidget(),
                );
              })),
    );
  }
}
