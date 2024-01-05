import 'package:aplicacion_manga/Screens/login_page.dart';
import 'package:aplicacion_manga/otros%20componentes/contss.dart';
import 'package:aplicacion_manga/otros%20componentes/firebase_contss.dart';
import 'package:aplicacion_manga/widgets/primary_button.dart';
import 'package:aplicacion_manga/widgets/textos_widget.dart';
import 'package:card_swiper/card_swiper.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import '../widgets/login_form.dart';

class RegisterPage extends StatefulWidget {
  RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  //Textos a ingresar (correo y contraseña)
  final nombreController = TextEditingController();
  final apellidosController = TextEditingController();
  final celularController = TextEditingController();
  final correoController = TextEditingController();
  final usuarioController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  // Método para validar si todos los campos están completos
  bool validarCampos() {
    if (nombreController.text.trim().isEmpty ||
        apellidosController.text.trim().isEmpty ||
        celularController.text.trim().isEmpty ||
        correoController.text.trim().isEmpty ||
        usuarioController.text.trim().isEmpty ||
        passwordController.text.trim().isEmpty ||
        confirmPasswordController.text.trim().isEmpty) {
      showErrorMessage("Por favor, completa todos los campos.");
      return false;
    }
    return true;
  }

  //REGISTRAR USUARIO

  bool passwordConfirmed() {
    if (passwordController.text.trim() ==
        confirmPasswordController.text.trim()) {
      return true;
    } else {
      return false;
    }
  }

  //CREAR USUARIO
  Future registrarUsuario() async {
    try {
      if (validarCampos()) {
        if (passwordConfirmed()) {
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
            email: correoController.text.trim(),
            password: passwordController.text.trim(),
          );

          final User? user = authInstance.currentUser;
          //final _uid = user!.uid; // Obtener el ID del usuario registrado
          //Agregar detalles del usuario
          if (user != null) {
            addUserDetails(
              user.uid, // Obtener el ID del usuario registrado
              nombreController.text.trim(),
              apellidosController.text.trim(),
              celularController.text.trim(),
              correoController.text.trim(),
              usuarioController.text.trim(),
              passwordController.text.trim(),
            );
          } else {
            showErrorMessage("Hubo un problema al registrar el usuario.");
          }
        } else {
          showErrorMessage("La contraseña no es igual, intentalo otra vez");
        }
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        showErrorMessage("La contraseña proporcionada es demasiado débil");
      } else if (e.code == 'email-already-in-use') {
        showErrorMessage("La cuenta ya existe para ese correo electrónico");
      }
    } catch (e) {
      print(e);
    }
  }

  Future addUserDetails(String userId, String nombres, String apellidos,
      String celular, String correo, String usuario, String password) async {
    await FirebaseFirestore.instance.collection('users').doc(userId).set({
      'userId': userId, // Agregar el ID del usuario
      'nombres': nombres,
      'apellidos': apellidos,
      'celular': celular,
      'correo': correo,
      'usuario': usuario,
      'contraseña': password,
      'fecha_registro': FieldValue.serverTimestamp(),
    });
  }

  void errorEmailMessage() {
    showDialog(
        context: context,
        builder: (context) {
          return const AlertDialog(
            title: Text('Correo incorrecto'),
          );
        });
  }

  void errorPasswordMessage() {
    showDialog(
        context: context,
        builder: (context) {
          return const AlertDialog(
            title: Text('Contraseña incorrecta'),
          );
        });
  }

  void showErrorMessage(String message) {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            backgroundColor: Colors.deepPurpleAccent,
            title: Center(
              child: Text(
                message,
                style: const TextStyle(
                  color: Colors.white,
                ),
              ),
            ),
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(children: [
        Swiper(
          duration: 800,
          autoplayDelay: 8000,
          itemBuilder: (BuildContext context, int index) {
            return Image.asset(
              Constss.authImagesPaths[index],
              fit: BoxFit.cover,
            );
          },
          autoplay: true,
          itemCount: Constss.authImagesPaths.length,
        ),
        Container(
          color: Colors.black.withOpacity(0.7),
        ),
        SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                height: 30,
              ),
              //buildIndicator(),
              Center(
                child: Text(
                  'Registra tus Datos',
                  style: TextStyle(
                    fontSize: 25,
                    color: Colors.white,
                  ),
                ),
              ),
              SizedBox(
                height: 5,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Padding(
                    padding: EdgeInsets.all(20),
                    child: CircleAvatar(
                      backgroundImage: NetworkImage(
                          'https://i.pinimg.com/originals/ca/cb/6b/cacb6b96e4b7f803bf33d17482d325c1.jpg'),
                      radius: 70,
                    ),
                  )
                ],
              ),
              SizedBox(
                height: 15,
              ),

              LogInForm(
                controller: nombreController,
                hintText: 'Nombre',
                obscureText: false,
              ),

              SizedBox(
                height: 20,
              ),

              LogInForm(
                controller: apellidosController,
                hintText: 'Apellidos',
                obscureText: false,
              ),

              SizedBox(
                height: 20,
              ),

              /*LogInForm(
                controller: phoneController,
                hintText: 'Celular',
                obscureText: false,
              ),*/

              IntlPhoneField(
                controller: celularController,
                decoration: InputDecoration(
                  labelText: 'Celular',
                  border: OutlineInputBorder(
                    borderSide: BorderSide(),
                  ),
                ),
                initialCountryCode: 'AR',
                onChanged: (phone) {
                  //print(phone.completeNumber);
                  TextosWidget(
                    text: phone.completeNumber,
                    color: Colors.white,
                    textSize: 20,
                    isTitle: true,
                  );
                },
              ),

              /*SizedBox(
                height: 15,
              ),*/

              LogInForm(
                controller: correoController,
                hintText: 'Correo',
                obscureText: false,
              ),
              /**********************************/
              SizedBox(
                height: 15,
              ),

              LogInForm(
                controller: usuarioController,
                hintText: 'Usuario',
                obscureText: false,
              ),

              SizedBox(
                height: 20,
              ),

              LogInForm(
                controller: passwordController,
                hintText: 'Contraseña',
                obscureText: true,
              ),

              SizedBox(
                height: 20,
              ),

              LogInForm(
                controller: confirmPasswordController,
                hintText: 'Confirmar Contraseña',
                obscureText: true,
              ),

              SizedBox(
                height: 40,
              ),

              PrimaryButton(
                text: 'Registrar',
                onTap: () {
                  registrarUsuario();
                },
              ),

              SizedBox(
                height: 40,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '¿Ya tienes cuenta?',
                    style: TextStyle(color: Colors.grey[700]),
                  ),
                  const SizedBox(height: 4),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(context,
                          MaterialPageRoute(builder: (context) {
                        return LoginPage();
                      }));
                    },
                    child: const Text(
                      '¡Ingresa ahora!',
                      style: TextStyle(
                        color: Colors.blue,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: 40,
              ),
            ],
          ),
        ),
      ]),
    );
  }
}
