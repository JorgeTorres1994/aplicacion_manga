import 'package:aplicacion_manga/Screens/admin_pagina_categorias.dart';
import 'package:aplicacion_manga/Screens/admin_pagina_inicio.dart';
import 'package:aplicacion_manga/Screens/admin_pagina_usuarios.dart';
import 'package:aplicacion_manga/Screens/wishlist/admin_wishlist_screen.dart';
import 'package:aplicacion_manga/theme/kuro_theme.dart';
import 'package:flutter/material.dart';

class AdminPaginaPrincipal extends StatefulWidget {
  const AdminPaginaPrincipal({Key? key}) : super(key: key);

  @override
  State<AdminPaginaPrincipal> createState() => _AdminPaginaPrincipalState();
}

class _AdminPaginaPrincipalState extends State<AdminPaginaPrincipal> {
  int _selectedIndex = 0;

  final List<Widget> _screens = const [
    AdminPaginaInicio(),
    AdminPaginaCategorias(),
    AdminWishListScreem(),
    AdminPaginaUsuarios(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: KuroTheme.background,
      body: IndexedStack(
        index: _selectedIndex,
        children: _screens,
      ),
      bottomNavigationBar: Container(
        height: 62,
        decoration: const BoxDecoration(
          color: KuroTheme.backgroundSecondary,
          border: Border(
            top: BorderSide(color: KuroTheme.border, width: 1),
          ),
        ),
        child: Row(
          children: [
            _buildNavItem(icon: Icons.home_filled, label: 'INICIO', index: 0),
            _buildNavItem(
                icon: Icons.explore_outlined, label: 'EXPLORAR', index: 1),
            _buildNavItem(
                icon: Icons.menu_book_outlined, label: 'BIBLIOTECA', index: 2),
            _buildNavItem(
                icon: Icons.person_outline, label: 'PERFIL', index: 3),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required String label,
    required int index,
  }) {
    final isSelected = _selectedIndex == index;

    return Expanded(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          setState(() {
            _selectedIndex = index;
          });
        },
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isSelected ? KuroTheme.crimson : KuroTheme.textMuted,
              size: 22,
            ),
            const SizedBox(height: 3),
            Text(
              label,
              style: KuroTheme.mono(
                fontSize: 8.5,
                fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                color: isSelected ? KuroTheme.crimson : KuroTheme.textMuted,
                letterSpacing: 0.8,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
