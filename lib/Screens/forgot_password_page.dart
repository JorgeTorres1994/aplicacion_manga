import 'package:aplicacion_manga/otros%20componentes/contss.dart';
import 'package:aplicacion_manga/widgets/login_form.dart';
import 'package:aplicacion_manga/widgets/textos_widget.dart';
import 'package:card_swiper/card_swiper.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final emailController = TextEditingController();

  @override
  void dispose() {
    emailController.dispose();
    super.dispose();
  }

  Future passwordReset() async {
    try {
      await FirebaseAuth.instance
          .sendPasswordResetEmail(email: emailController.text.trim());
      if (!mounted) return;
      showDialog(
          context: context,
          builder: (context) {
            return const AlertDialog(
              content: Text(
                  '¡El link para resear tu contraseña fue enviado!, revisa tu correo'),
            );
          });
    } on FirebaseAuthException catch (_) {
      if (!mounted) return;
      showDialog(
          context: context,
          builder: (context) {
            return const AlertDialog(
              /*content: Text(
                e.message.toString(),
              ),*/
              content: Text(
                '¡El correo no existe!, no se pudo restaurar la contraseña',
              ),
            );
          });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
          //padding: kDefaultPadding,
          children: [
            Swiper(
              duration: 800,
              autoplayDelay: 8000,
              itemBuilder: (BuildContext context, int index) {
                return Image.asset(
                  Constss.authImagesPaths2[index],
                  fit: BoxFit.cover,
                );
              },
              autoplay: true,
              itemCount: Constss.authImagesPaths2.length,
            ),
            Container(
              color: Colors.black.withValues(alpha: 0.7),
            ),
            SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(
                    height: 30,
                  ),
                  //buildIndicator(),
                  /*Text(
                    '¿PROBLEMAS PARA INGRESAR?',
                    //style: TextStyle(color: Colors.grey[600]),
                    style: TextStyle(
                      color: Colors.redAccent,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),*/

                  TextosWidget(
                    text: '¿PROBLEMAS PARA INGRESAR?',
                    color: Colors.redAccent,
                    textSize: 22,
                    isTitle: true,
                  ),

                  const SizedBox(
                    height: 40,
                  ),
                  /*Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Padding(
                        padding: EdgeInsets.all(20),
                        child: CircleAvatar(
                          backgroundImage: NetworkImage(
                              'https://cdn-icons-png.flaticon.com/128/10550/10550842.png'),
                          radius: 70,
                        ),
                      )
                    ],
                  ),
                  SizedBox(
                    height: 15,
                  ),*/

                  TextosWidget(
                    text:
                        'Ingresa tu correo electrónico para enviarte un enlace y resetear contraseña',
                    color: Colors.white,
                    textSize: 30,
                    isTitle: true,
                  ),

                  const SizedBox(
                    height: 160,
                  ),

                  LogInForm(
                    controller: emailController,
                    hintText: 'Correo',
                    obscureText: false,
                  ),

                  const SizedBox(
                    height: 120,
                  ),

                  /*MaterialButton(
                    onPressed: passwordReset,
                    child: Text(
                      'Enviar enlace',
                      style: TextStyle(
                        color: Colors.white,
                      ),
                    ),
                    color: Colors.green,
                  ),*/

                  Container(
                    alignment: Alignment.bottomCenter,
                    padding: const EdgeInsets.only(left: 20, bottom: 20),
                    child: MaterialButton(
                      color: Colors.green,
                      height: 50, // Ajustar el tamaño del botón
                      onPressed: () {
                        passwordReset();
                      },
                      child: const Text(
                        'Enviar enlace',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20, // Tamaño de fuente del texto del botón
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(
                    height: 30,
                  ),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        '¿Quieres retroceder?',
                        style: TextStyle(color: Colors.white),
                      ),
                      const SizedBox(height: 4),
                      GestureDetector(
                        onTap: () {
                          Navigator.pop(context);
                        },
                        child: const Text(
                          'Login',
                          style: TextStyle(
                            color: Colors.blue,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ),
          ]),
    );
  }
}
