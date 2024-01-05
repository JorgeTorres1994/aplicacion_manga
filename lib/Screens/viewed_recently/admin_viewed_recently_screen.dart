import 'package:aplicacion_manga/Screens/viewed_recently/viewed_recently_widget.dart';
import 'package:aplicacion_manga/providers/viewed_providers.dart';
import 'package:aplicacion_manga/services/global_methods.dart';
import 'package:aplicacion_manga/services/utils.dart';
import 'package:aplicacion_manga/widgets/back_widget.dart';
import 'package:aplicacion_manga/widgets/empty_screen.dart';
import 'package:aplicacion_manga/widgets/textos_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_iconly/flutter_iconly.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:provider/provider.dart';

class AdminViewedRecentlyScreen extends StatefulWidget {
  static const routeName = '/ViewedRecentlyScreen';

  const AdminViewedRecentlyScreen({Key? key}) : super(key: key);

  @override
  _AdminViewedRecentlyScreenState createState() =>
      _AdminViewedRecentlyScreenState();
}

class _AdminViewedRecentlyScreenState extends State<AdminViewedRecentlyScreen> {
  bool check = true;
  @override
  Widget build(BuildContext context) {
    Color color = Utils(context).color;

    // Size size = Utils(context).getScreenSize;
    final viewedMangaProvider = Provider.of<ViewedMangaProvider>(context);
    final viewedMangatemsList = viewedMangaProvider
        .getViewedMangasListItems.values
        .toList()
        .reversed
        .toList();
    if (viewedMangatemsList.isEmpty) {
      return EmptyScreen(
        title: 'Tu historial está vacío',
        subtitle: 'No hay mangas vistos!',
        buttonText: 'Ver ahora',
        imagePath: 'images/ver-la-television.png',
      );
    } else {
      return Scaffold(
        appBar: AppBar(
          centerTitle: true,
          leading: BackWidget(),
          automaticallyImplyLeading: false,
          elevation: 0,
          actions: [
            IconButton(
              onPressed: () {
                GlobalMethods.warningDialog(
                    title: 'Borrar tu historial?',
                    subtitle: '¿Estás seguro?',
                    fct: () {},
                    context: context);
              },
              icon: Icon(
                IconlyBroken.delete,
                color: color,
              ),
            )
          ],
          title: TextosWidget(
            text: 'Historial',
            color: color,
            textSize: 24.0,
          ),
          backgroundColor:
              Theme.of(context).scaffoldBackgroundColor.withOpacity(0.9),
        ),
        body: MasonryGridView.count(
          itemCount: viewedMangatemsList.length,
          crossAxisCount: 2,
          // mainAxisSpacing: 16,
          // crossAxisSpacing: 20,
          itemBuilder: (context, index) {
            return ChangeNotifierProvider.value(
                value: viewedMangatemsList[index],
                child: const ViewedRecentlyWidget());
          },
        ),
      );
    }
  }
}
