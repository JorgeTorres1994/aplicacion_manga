import 'package:aplicacion_manga/inner_screens/feed_screens.dart';
import 'package:aplicacion_manga/inner_screens/on_view_screen.dart';
import 'package:aplicacion_manga/models/mangas_models.dart';
import 'package:aplicacion_manga/providers/mangas_providers.dart';
import 'package:aplicacion_manga/services/global_methods.dart';
import 'package:aplicacion_manga/services/utils.dart';
import 'package:aplicacion_manga/widgets/feed_items.dart';
import 'package:aplicacion_manga/widgets/on_view_widget.dart';
import 'package:aplicacion_manga/widgets/textos_widget.dart';
import 'package:card_swiper/card_swiper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_iconly/flutter_iconly.dart';
import 'package:provider/provider.dart';

class AdminPaginaInicio extends StatelessWidget {
  AdminPaginaInicio({Key? key}) : super(key: key);

  final List<String> _offerImages = [
    'images/fondoInicio.jpg',
    'images/fondoInicio2.jpg',
    'images/fondoInicio3.jpg',
    'images/fondoInicio4.jpg',
  ];

  @override
  Widget build(BuildContext context) {
    final Utils utils = Utils(context);
    final themeState = utils.getTheme;
    final Color color = Utils(context).color;
    Size size = Utils(context).getScreenSize;
    bool _showAllMangas =
        false; // Variable para controlar si se muestra todo o no

    final mangasProvider = Provider.of<MangasProvider>(context);
    List<MangasModels> allMangas = mangasProvider.getMangas;
    //List<MangasModels> productsOnSale = mangasProvider.getOnSaleProducts;
    //List<MangasModels> mangasOnSale = mangasProvider.getMangas;
    // Genera la lista de widgets FeedsWidget
    // Genera la lista de widgets FeedsWidget
    List<Widget> feedsWidgets = _showAllMangas
        ? allMangas.map((manga) {
            return ChangeNotifierProvider.value(
              value: manga,
              child: FeedsWidget(),
            );
          }).toList()
        : allMangas.take(4).map((manga) {
            return ChangeNotifierProvider.value(
              value: manga,
              child: FeedsWidget(),
            );
          }).toList();
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(),
            child: Column(
              children: [
                SizedBox(
                  height: size.height * 0.33,
                  child: Swiper(
                    itemBuilder: (BuildContext context, int index) {
                      return Image.asset(
                        _offerImages[index],
                        fit: BoxFit.fill,
                      );
                    },
                    autoplay: true,
                    itemCount: _offerImages.length,
                    pagination: SwiperPagination(
                      alignment: Alignment.bottomCenter,
                      builder: DotSwiperPaginationBuilder(
                          color: Colors.white, activeColor: Colors.red),
                    ),
                    control: const SwiperControl(color: Colors.blueAccent),
                  ),
                ),
                SizedBox(
                  height: 6,
                ),
                TextButton(
                  onPressed: () {
                    //Navigator.pushNamed(context, OnViewScreen.routeName);
                    GlobalMethods.navigateto(
                        ctx: context, routeName: OnViewScreen.routeName);
                  },
                  child: TextosWidget(
                      text: 'Ver todo',
                      maxLines: 1,
                      color: Colors.blue,
                      textSize: 20),
                ),
                SizedBox(
                  height: 6,
                ),
                Row(
                  children: [
                    RotatedBox(
                      quarterTurns: -1,
                      child: Row(
                        children: [
                          TextosWidget(
                            text: 'En emisión'.toUpperCase(),
                            color: Colors.red,
                            textSize: 15,
                            isTitle: true,
                          ),
                          SizedBox(width: 5),
                          Icon(
                            IconlyLight.play,
                            color: Colors.blueGrey,
                          )
                        ],
                      ),
                    ),
                    SizedBox(width: 8),
                    Expanded(
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: allMangas
                              .map(
                                (mangas) => ChangeNotifierProvider.value(
                                  value: mangas,
                                  child: OnViewWidget(),
                                ),
                              )
                              .toList(),
                        ),
                      ),
                    ),
                  ],
                ),

                SizedBox(
                  height: 10,
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      TextosWidget(
                        text: 'Nuestros mangas',
                        color: color,
                        textSize: 22,
                        isTitle: true,
                      ),
                      //Spacer(),
                      TextButton(
                        onPressed: () {
                          GlobalMethods.navigateto(
                              ctx: context, routeName: FeedScreens.routeName);
                        },
                        child: TextosWidget(
                            text: 'Buscar todo',
                            maxLines: 1,
                            color: Colors.blue,
                            textSize: 15),
                      ),
                    ],
                  ),
                ),
                //GENERACION DE UNA CANTIDAD DE MANGAS
                GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 2,
                  //crossAxisSpacing: 10,
                  childAspectRatio: size.width / (size.height * 0.68),
                  /*children: List.generate(
                        allMangas.length < 4 ? allMangas.length : 4, (index) {
                      return ChangeNotifierProvider.value(
                        value: allMangas[index],
                        child: FeedsWidget(),
                      );
                    })*/
                  children:
                      feedsWidgets, // Aquí utilizamos la lista de widgets generados
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
