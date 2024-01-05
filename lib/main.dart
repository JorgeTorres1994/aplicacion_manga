import 'package:aplicacion_manga/Screens/login_page.dart';
import 'package:aplicacion_manga/Screens/viewed_recently/admin_viewed_recently_screen.dart';
import 'package:aplicacion_manga/Screens/wishlist/admin_wishlist_screen.dart';
import 'package:aplicacion_manga/inner_screens/category_screen.dart';
import 'package:aplicacion_manga/inner_screens/on_view_screen.dart';
import 'package:aplicacion_manga/inner_screens/manga_details.dart';
import 'package:aplicacion_manga/models/mangas_models.dart';
import 'package:aplicacion_manga/otros%20componentes/theme_data.dart';
import 'package:aplicacion_manga/provider/dark_theme_provider.dart';
import 'package:aplicacion_manga/providers/comment_provider.dart';
import 'package:aplicacion_manga/providers/mangas_providers.dart';
import 'package:aplicacion_manga/providers/viewed_providers.dart';
import 'package:aplicacion_manga/providers/wishlist_providers.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:provider/provider.dart';

import 'inner_screens/feed_screens.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await FlutterDownloader.initialize(); // Inicializar flutter_downloader
  runApp(
    ChangeNotifierProvider(
      create: (context) =>
          MangasModels(), // Aquí puedes inicializar la clase si es necesario
      child: MainApp(),
    ),
  );
}

class MainApp extends StatefulWidget {
  const MainApp({Key? key}) : super(key: key);

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  DarkThemeProvider themeChangeProvider = DarkThemeProvider();

  @override
  void initState() {
    getCurrentAppTheme();
    super.initState();
  }

  void getCurrentAppTheme() async {
    themeChangeProvider.setDarkTheme =
        await themeChangeProvider.darkThemePrefs.getTheme();
  }

  final Future<FirebaseApp> _fireBaseInitialization = Firebase.initializeApp();
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: _fireBaseInitialization,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return MaterialApp(
              debugShowCheckedModeBanner: false,
              home: Scaffold(
                body: Center(
                  child: CircularProgressIndicator(),
                ),
              ),
            );
          } else if (snapshot.hasError) {
            MaterialApp(
              debugShowCheckedModeBanner: false,
              home: Scaffold(
                body: Center(
                  child: Text('A ocurrido un error'),
                ),
              ),
            );
          }

          return MultiProvider(
            providers: [
              ChangeNotifierProvider(create: (_) {
                return themeChangeProvider;
              }),
              ChangeNotifierProvider(create: (_) => MangasProvider()),
              ChangeNotifierProvider(create: (_) => WishListProvider()),
              ChangeNotifierProvider(create: (_) => ViewedMangaProvider()),
              ChangeNotifierProvider(create: (_) => CommentProvider()),
            ],
            child: Consumer<DarkThemeProvider>(
                builder: (context, themeProvider, child) {
              return MaterialApp(
                  debugShowCheckedModeBanner: false,
                  theme: Styles.themeData(themeProvider.getDarkTheme, context),
                  home: LoginPage(),
                  routes: {
                    OnViewScreen.routeName: (ctx) => const OnViewScreen(),
                    FeedScreens.routeName: (ctx) => const FeedScreens(),
                    MangaDetails.routeName: (ctx) => const MangaDetails(),
                    AdminWishListScreem.routeName: (ctx) =>
                        const AdminWishListScreem(),
                    AdminViewedRecentlyScreen.routeName: (ctx) =>
                        const AdminViewedRecentlyScreen(),
                    CategoryScreen.routeName: (ctx) => const CategoryScreen(),
                  });
            }),
          );
        });
  }
}
