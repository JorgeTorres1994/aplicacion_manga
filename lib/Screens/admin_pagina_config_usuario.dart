import 'package:aplicacion_manga/Screens/forgot_password_page.dart';
import 'package:aplicacion_manga/Screens/loading_manager.dart';
import 'package:aplicacion_manga/Screens/login_page.dart';
import 'package:aplicacion_manga/Screens/viewed_recently/admin_viewed_recently_screen.dart';
import 'package:aplicacion_manga/Screens/wishlist/admin_wishlist_screen.dart';
import 'package:aplicacion_manga/otros%20componentes/firebase_contss.dart';
import 'package:aplicacion_manga/provider/dark_theme_provider.dart';
import 'package:aplicacion_manga/services/global_methods.dart';
import 'package:aplicacion_manga/usuario/auth_google_service.dart';
import 'package:aplicacion_manga/widgets/textos_widget.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_iconly/flutter_iconly.dart';
import 'package:provider/provider.dart';

class AdminPaginaConfigUsuario extends StatefulWidget {
  const AdminPaginaConfigUsuario({Key? key}) : super(key: key);

  @override
  State<AdminPaginaConfigUsuario> createState() =>
      _AdminPaginaConfigUsuarioState();
}

class _AdminPaginaConfigUsuarioState extends State<AdminPaginaConfigUsuario> {
  final TextEditingController _usuarioTextController =
      TextEditingController(text: "");
  @override
  void dispose() {
    _usuarioTextController.dispose();
    super.dispose();
  }

  String? _email;
  String? _name;
  String? usuario;
  bool _isLoading = false;
  final User? user = authInstance.currentUser;
  /*String? _uid =
      authInstance.currentUser?.uid; // Obtener el ID de usuario actual*/

  final AuthGoogleService _authGoogleService = AuthGoogleService();

  @override
  void initState() {
    getUserData();
    super.initState();
  }

  void updateGoogleUserDetails(
      String? googleUserName, String? googleUserEmail) {
    setState(() {
      _name = googleUserName;
      _email = googleUserEmail;
    });
  }

  Future<void> getUserData() async {
    setState(() {
      _isLoading = true;
    });

    if (user == null) {
      setState(() {
        _isLoading = false;
      });
      return;
    }

    try {
      String _uid = user!.uid;

      final DocumentSnapshot userDoc =
          await FirebaseFirestore.instance.collection('users').doc(_uid).get();

      if (!userDoc.exists) {
        setState(() {
          _isLoading = false;
        });
        print("El documento no existe en Firestore");
        return;
      } else {
        _email = userDoc.get('correo');
        _name = userDoc.get('nombres');
        usuario = userDoc.get('usuario');
        _usuarioTextController.text = usuario ?? "";

        print("Nombre del usuario: $_name");
        print("Correo electrónico: $_email");
      }
    } catch (error) {
      setState(() {
        _isLoading = false;
      });
      print("Error al obtener datos del usuario: $error");
      GlobalMethods.errorDialog(subtitle: '$error', context: context);
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    //final User? user = authInstance.currentUser;
    final themeState = Provider.of<DarkThemeProvider>(context);
    final Color color = themeState.getDarkTheme ? Colors.white : Colors.black;

    return Scaffold(
        body: LoadingManager(
            isLoading: _isLoading,
            child: Center(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      RichText(
                        text: TextSpan(
                            text: 'Hola, ',
                            style: const TextStyle(
                              color: Colors.cyan,
                              fontSize: 27,
                              fontWeight: FontWeight.bold,
                            ),
                            children: <TextSpan>[
                              TextSpan(
                                  text: _name == null ? 'nombres' : _name,
                                  style: TextStyle(
                                    color: color,
                                    fontSize: 25,
                                    fontWeight: FontWeight.w600,
                                  ),
                                  recognizer: TapGestureRecognizer()
                                    ..onTap = () {
                                      print('Mi nombre está presionado');
                                    }),
                            ]),
                      ),
                      TextosWidget(
                        text: _email == null ? 'correo' : _email!,
                        color: color,
                        textSize: 18,
                      ),

                      SizedBox(
                        height: 20,
                      ),

                      Divider(
                        thickness: 2,
                      ),

                      _listTiles(
                        title: 'Usuario',
                        subtitle: usuario,
                        icon: IconlyBold.profile,
                        onPressed: () async {
                          await _showAdressDialog();
                        },
                        color: color,
                      ),

                      SizedBox(
                        height: 5,
                      ),

                      _listTiles(
                        title: 'Lista de deseos',
                        subtitle: 'Subtitle here',
                        icon: IconlyBold.heart,
                        onPressed: () {
                          GlobalMethods.navigateto(
                              ctx: context,
                              routeName: AdminWishListScreem.routeName);
                        },
                        color: color,
                      ),

                      SizedBox(
                        height: 5,
                      ),

                      SizedBox(
                        height: 5,
                      ),

                      _listTiles(
                        title: 'Vistos',
                        subtitle: 'Subtitle here',
                        icon: IconlyBold.show,
                        onPressed: () {
                          GlobalMethods.navigateto(
                              ctx: context,
                              routeName: AdminViewedRecentlyScreen.routeName);
                        },
                        color: color,
                      ),

                      SizedBox(
                        height: 5,
                      ),

                      _listTiles(
                        title: 'Recuperar contraseña',
                        subtitle: 'Subtitle here',
                        icon: IconlyBold.password,
                        onPressed: () {
                          Navigator.of(context).push(MaterialPageRoute(
                              builder: (context) => ForgotPasswordPage()));
                        },
                        color: color,
                      ),

                      SizedBox(
                        height: 5,
                      ),

                      //TEMA OSCURO DE PANTALLA
                      SwitchListTile(
                        title: TextosWidget(
                          text: themeState.getDarkTheme
                              ? 'Modo oscuro'
                              : 'Modo claro',
                          color: color,
                          textSize: 18,
                        ),
                        secondary: Icon(themeState.getDarkTheme
                            ? Icons.dark_mode_outlined
                            : Icons.light_mode_outlined),
                        onChanged: (bool value) {
                          setState(() {
                            themeState.setDarkTheme = value;
                          });
                        },
                        value: themeState.getDarkTheme,
                      ),

                      SizedBox(
                        height: 5,
                      ),

                      _listTiles(
                        title: user == null ? 'Login' : 'Cerrar Sesión',
                        subtitle: 'Subtitle here',
                        icon: user == null
                            ? IconlyLight.login
                            : IconlyBold.logout,
                        onPressed: () {
                          if (user == null) {
                            Navigator.of(context).push(MaterialPageRoute(
                                builder: (context) => LoginPage()));
                            return;
                          }
                          GlobalMethods.warningDialog(
                              title: 'Cerrar sesión',
                              subtitle: '¿Deseas cerrar sesión?',
                              fct: () async {
                                await authInstance.signOut();
                                Navigator.of(context).push(MaterialPageRoute(
                                    builder: (context) => LoginPage()));
                              },
                              context: context);
                        },
                        color: color,
                      ),
                    ],
                  ),
                ),
                //Text('Página Configuracion de Usuario', style: semiBoltText20),
              ),
            )));
  }

  Future<void> _showAdressDialog() async {
    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Actualizar'),
          content: TextField(
            controller: _usuarioTextController,
            maxLines: 5,
            decoration: const InputDecoration(hintText: "Tu usuario"),
          ),
          actions: [
            TextButton(
              onPressed: () async {
                String _uid = user!.uid;
                try {
                  await FirebaseFirestore.instance
                      .collection('users')
                      .doc(_uid)
                      .update({'usuario': _usuarioTextController.text});
                  Navigator.of(context).pop();
                  setState(() {
                    usuario = _usuarioTextController.text;
                  });
                } catch (err) {
                  GlobalMethods.errorDialog(
                      subtitle: err.toString(), context: context);
                }
                // Aquí puedes actualizar la dirección en la base de datos
                // Utiliza _correoTextController.text para obtener el nuevo valor
              },
              child: const Text('Actualizar'),
            )
          ],
        );
      },
    );
  }

  Widget _listTiles({
    required String title,
    String? subtitle,
    required IconData icon,
    required Function onPressed,
    required Color color,
  }) {
    return ListTile(
        title: TextosWidget(
          text: title,
          color: color,
          textSize: 20,
          isTitle: true,
        ),
        subtitle: TextosWidget(
            text: subtitle == null ? "" : subtitle, color: color, textSize: 15),
        leading: Icon(icon),
        trailing: Icon(IconlyLight.arrowRight2),
        onTap: () {
          onPressed();
        });
  }
}
