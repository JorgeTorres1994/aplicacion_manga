import 'package:aplicacion_manga/Screens/admin_pagina_inicio.dart';
import 'package:aplicacion_manga/provider/dark_theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_iconly/flutter_iconly.dart';
import 'package:provider/provider.dart';

import 'admin_pagina_categorias.dart';
import 'admin_pagina_config_usuario.dart';
import 'admin_pagina_usuarios.dart';

class AdminPaginaPrincipal extends StatefulWidget {
  const AdminPaginaPrincipal({Key? key}) : super(key: key);
  @override
  _NavBarState createState() => _NavBarState();
}

class _NavBarState extends State<AdminPaginaPrincipal> {
  int selectedIndex = 0;

  final _screens = [
    AdminPaginaInicio(),
    //AdminPaginaFavoritos(),
    AdminPaginaCategorias(),
    //AdminPaginaDescargas(),
    //AdminCartScreen(),
    AdminPaginaUsuarios(),
    AdminPaginaConfigUsuario(),
  ];

  @override
  Widget build(BuildContext context) {
    final themeState = Provider.of<DarkThemeProvider>(context);

    Widget customBottomNav() {
      return BottomNavigationBar(
        backgroundColor: themeState.getDarkTheme
            ? Theme.of(context).cardColor
            : Colors.white,
        type: BottomNavigationBarType.fixed,
        currentIndex: selectedIndex,
        onTap: (i) {
          print(i);
          setState(() {
            selectedIndex = i;
          });
        },
        items: [
          BottomNavigationBarItem(
            icon: Icon(selectedIndex == 0 ? IconlyBold.home : IconlyLight.home),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Icon(selectedIndex == 1
                ? IconlyBold.category
                : IconlyLight.category),
            label: '',
          ),
          /*BottomNavigationBarItem(
            icon: Icon(selectedIndex == 2 ? IconlyBold.buy : IconlyLight.buy),
            label: '',
          ),*/
          BottomNavigationBarItem(
            icon:
                Icon(selectedIndex == 2 ? IconlyBold.user2 : IconlyLight.user2),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Icon(
                selectedIndex == 3 ? IconlyBold.setting : IconlyLight.setting),
            label: '',
          ),
        ],
      );
    }

    return Scaffold(
      bottomNavigationBar: customBottomNav(),
      body: Stack(
          children: _screens
              .asMap()
              .map((i, screen) => MapEntry(
                  i,
                  Offstage(
                    offstage: selectedIndex != i,
                    child: screen,
                  )))
              .values
              .toList()),
    );
  }
}
