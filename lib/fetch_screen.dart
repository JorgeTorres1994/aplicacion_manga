import 'package:aplicacion_manga/Screens/admin/admin_overview_screen.dart';
import 'package:aplicacion_manga/Screens/admin_pagina_principal.dart';
import 'package:aplicacion_manga/otros%20componentes/contss.dart';
import 'package:aplicacion_manga/providers/mangas_providers.dart';
import 'package:aplicacion_manga/providers/viewed_providers.dart';
import 'package:aplicacion_manga/providers/wishlist_providers.dart';
import 'package:aplicacion_manga/services/admin_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:provider/provider.dart';

class FetchScreen extends StatefulWidget {
  final bool? isAdmin;
  const FetchScreen({Key? key, this.isAdmin}) : super(key: key);

  @override
  State<FetchScreen> createState() => _FetchScreenState();
}

class _FetchScreenState extends State<FetchScreen> {
  List<String> images = Constss.authImagesCarga;

  @override
  void initState() {
    super.initState();
    images.shuffle();

    // Limpieza y unificación automática en segundo plano
    KuroAdminBackendService.instance.cleanupLegacyCollections();

    Future.delayed(const Duration(milliseconds: 900), () async {
      try {
        if (!mounted) return;
        final mangasProvider =
            Provider.of<MangasProvider>(context, listen: false);
        await mangasProvider.fetchMangas();

        final currentUser = FirebaseAuth.instance.currentUser;
        if (currentUser != null) {
          final wishListProvider =
              Provider.of<WishListProvider>(context, listen: false);
          wishListProvider.initWishlistSync(currentUser.uid);

          final viewedProvider =
              Provider.of<ViewedMangaProvider>(context, listen: false);
          viewedProvider.initHistorySync(currentUser.uid);
        }

        bool isUserAdmin = widget.isAdmin ?? false;

        // Si no se pasó explícitamente, verificar usuario actual en Firebase
        if (widget.isAdmin == null) {
          final currentUser = FirebaseAuth.instance.currentUser;
          if (currentUser != null) {
            final email = currentUser.email?.toLowerCase().trim() ?? '';
            if (email == 'jorge.torres.1994.1000@gmail.com' ||
                email.contains('admin')) {
              isUserAdmin = true;
            } else {
              try {
                final doc = await FirebaseFirestore.instance
                    .collection('users')
                    .doc(currentUser.uid)
                    .get();
                if (doc.exists && doc.data() != null) {
                  final rol = doc.data()?['rol'];
                  if (rol == 'admin') {
                    isUserAdmin = true;
                  }
                }
              } catch (e) {
                print('Error consultando rol de usuario: $e');
              }
            }
          }
        }

        if (!mounted) return;

        if (isUserAdmin) {
          Navigator.of(context).pushReplacement(MaterialPageRoute(
            builder: (ctx) => const KuroAdminOverviewScreen(),
          ));
        } else {
          Navigator.of(context).pushReplacement(MaterialPageRoute(
            builder: (ctx) => const AdminPaginaPrincipal(),
          ));
        }
      } catch (error) {
        print('Error en fetchMangas: $error');
        if (!mounted) return;
        final fallbackAdmin = widget.isAdmin ?? false;
        Navigator.of(context).pushReplacement(MaterialPageRoute(
          builder: (ctx) => fallbackAdmin
              ? const KuroAdminOverviewScreen()
              : const AdminPaginaPrincipal(),
        ));
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
            color: Colors.black.withValues(alpha: 0.7),
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
