import 'package:aplicacion_manga/models/mangas_models.dart';
import 'package:aplicacion_manga/providers/mangas_providers.dart';
import 'package:aplicacion_manga/services/utils.dart';
import 'package:aplicacion_manga/widgets/back_widget.dart';
import 'package:aplicacion_manga/widgets/empty_manga_widget.dart';
import 'package:aplicacion_manga/widgets/feed_items.dart';
import 'package:aplicacion_manga/widgets/textos_widget.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class FeedScreens extends StatefulWidget {
  static const routeName = "/FeedScreenState"; //ruta de la interfaz
  const FeedScreens({super.key});

  @override
  State<FeedScreens> createState() => _FeedScreensState();
}

class _FeedScreensState extends State<FeedScreens> {
  final TextEditingController? _searchTextController = TextEditingController();
  final FocusNode _searchTextFocusNode = FocusNode();
  /*@override
  void dispose() {
    _searchTextController!.dispose();
    _searchTextFocusNode.dispose();
    super.dispose();
  }*/
  List<MangasModels> listMangaSearch = [];

  @override
  void initState() {
    super.initState();
    //final mangasProvider = Provider.of<MangasProvider>(context, listen: false);
    //mangasProvider.fetchMangas();
    Future.delayed(Duration.zero, () {
      final mangasProvider =
          Provider.of<MangasProvider>(context, listen: false);
      mangasProvider.fetchMangas();
    });
  }

  @override
  Widget build(BuildContext context) {
    Size size = Utils(context).getScreenSize;
    final Color color = Utils(context).color;
    final mangasProvider = Provider.of<MangasProvider>(context);
    List<MangasModels> allMangas = mangasProvider.getMangas;
    return Scaffold(
        appBar: AppBar(
          leading: BackWidget(),
          elevation: 0,
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          centerTitle: true,
          title: TextosWidget(
            text: 'Todos los Mangas',
            color: color,
            textSize: 24.0,
            isTitle: true,
          ),
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: SizedBox(
                  height: kBottomNavigationBarHeight,
                  child: TextField(
                    focusNode: _searchTextFocusNode,
                    controller: _searchTextController,
                    onChanged: (value) {
                      setState(() {
                        listMangaSearch = mangasProvider.searchQuery(value);
                      });
                    },
                    decoration: InputDecoration(
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                              color: Colors.greenAccent, width: 1),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                              color: Colors.greenAccent, width: 1),
                        ),
                        hintText: '¿Qué manga te apetece ver?',
                        prefixIcon: Icon(Icons.search),
                        suffix: IconButton(
                          onPressed: () {
                            _searchTextController!.clear();
                            _searchTextFocusNode.unfocus();
                          },
                          icon: Icon(
                            Icons.close,
                            color: _searchTextFocusNode.hasFocus
                                ? Colors.red
                                : color,
                          ),
                        )),
                  ),
                ),
              ),
              _searchTextController!.text.isNotEmpty && listMangaSearch.isEmpty
                  ? const EmptyMangaWidget(
                      text: 'No está disponible el manga que buscas')
                  : GridView.count(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisCount: 2,
                      padding: EdgeInsets.zero,
                      // crossAxisSpacing: 10,
                      childAspectRatio: size.width / (size.height * 0.59),
                      children: List.generate(
                          _searchTextController!.text.isNotEmpty
                              ? listMangaSearch.length
                              : allMangas.length, (index) {
                        return ChangeNotifierProvider.value(
                          value: _searchTextController!.text.isNotEmpty
                              ? listMangaSearch[index]
                              : allMangas[index],
                          child: const FeedsWidget(),
                        );
                      }),
                    ),
            ],
          ),
        ));
  }
}
