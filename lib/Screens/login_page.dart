import 'package:aplicacion_manga/Screens/forgot_password_page.dart';
import 'package:aplicacion_manga/Screens/register_page.dart';
import 'package:aplicacion_manga/fetch_screen.dart';
import 'package:aplicacion_manga/theme/kuro_theme.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_sign_in/google_sign_in.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  bool validarCampos() {
    if (emailController.text.trim().isEmpty ||
        passwordController.text.trim().isEmpty) {
      showErrorDialog('Por favor, ingresa tu correo y contraseña.');
      return false;
    }
    return true;
  }

  void showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: KuroTheme.card,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(color: KuroTheme.border),
          ),
          title: Text(
            'AVISO DE SISTEMA',
            style: KuroTheme.mono(color: KuroTheme.crimson, fontSize: 13),
          ),
          content: Text(
            message,
            style: KuroTheme.body(color: KuroTheme.textWhite, fontSize: 14),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'ENTENDIDO',
                style: KuroTheme.mono(color: KuroTheme.crimson, fontSize: 12),
              ),
            ),
          ],
        );
      },
    );
  }

  void loguearUsuario() async {
    if (!validarCampos()) return;

    try {
      setState(() {
        _isLoading = true;
      });

      final email = emailController.text.trim();
      final password = passwordController.text.trim();

      UserCredential? credential;
      try {
        credential = await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: email,
          password: password,
        );
      } on FirebaseAuthException catch (e) {
        if (e.code == 'user-not-found' || e.code == 'invalid-credential') {
          try {
            credential =
                await FirebaseAuth.instance.createUserWithEmailAndPassword(
              email: email,
              password: password,
            );
          } catch (_) {
            rethrow;
          }
        } else {
          rethrow;
        }
      }

      final user = credential.user ?? FirebaseAuth.instance.currentUser;
      final emailLower = email.toLowerCase();
      bool isAdmin = (emailLower == 'jorge.torres.1994.1000@gmail.com') ||
          emailLower.contains('admin');

      if (user != null) {
        try {
          final doc = await FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .get();
          if (doc.exists && doc.data() != null) {
            final storedRole = doc.data()?['rol'];
            if (storedRole == 'admin' ||
                emailLower == 'jorge.torres.1994.1000@gmail.com') {
              isAdmin = true;
            } else if (storedRole == 'reader') {
              isAdmin = false;
            }

            // Limpieza automática de campos repetidos u obsoletos (email/telefono)
            final data = doc.data()!;
            final cleanup = <String, dynamic>{};
            if (data.containsKey('email')) cleanup['email'] = FieldValue.delete();
            if (data.containsKey('telefono')) {
              if (data['celular'] == null || data['celular'] == '+51 987654321') {
                cleanup['celular'] = data['telefono'];
              }
              cleanup['telefono'] = FieldValue.delete();
            }
            if (cleanup.isNotEmpty) {
              await doc.reference.update(cleanup);
            }
          } else {
            await FirebaseFirestore.instance
                .collection('users')
                .doc(user.uid)
                .set({
              'userId': user.uid,
              'usuario': isAdmin ? 'Jorge Torres' : 'Kenji Reader',
              'correo': email,
              'celular': isAdmin ? '952336505' : '+51 952336505',
              'clan': 'Carmesí',
              'rango': isAdmin ? 'ROOT ADMIN' : 'LECTOR REGULAR',
              'nivel': isAdmin ? 99 : 12,
              'rol': isAdmin ? 'admin' : 'reader',
              'avatar': '',
              'bio': isAdmin ? 'Admin principal' : 'Lector de Manga',
              'fecha_registro': FieldValue.serverTimestamp(),
            });
          }
        } catch (_) {}
      }

      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });

      Navigator.of(context).pushReplacement(MaterialPageRoute(
        builder: (ctx) => FetchScreen(isAdmin: isAdmin),
      ));
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });

      String errorMsg;
      if (e.code == 'user-not-found') {
        errorMsg = 'El correo no se encuentra registrado en Kuro.';
      } else if (e.code == 'wrong-password' || e.code == 'invalid-credential') {
        errorMsg = 'Contraseña o credenciales incorrectas.';
      } else if (e.code == 'invalid-email') {
        errorMsg = 'El formato de correo no es válido.';
      } else {
        errorMsg = e.message ?? 'Error de autenticación (${e.code})';
      }
      showErrorDialog(errorMsg);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
      showErrorDialog('Error: $e');
    }
  }

  Future<void> _autofillAndLogin({
    required String email,
    required String password,
    required bool isAdmin,
  }) async {
    emailController.text = email;
    passwordController.text = password;
    setState(() {
      _isLoading = true;
    });

    try {
      UserCredential? credential;
      try {
        credential = await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: email,
          password: password,
        );
      } on FirebaseAuthException catch (e) {
        if (e.code == 'user-not-found' || e.code == 'invalid-credential') {
          credential =
              await FirebaseAuth.instance.createUserWithEmailAndPassword(
            email: email,
            password: password,
          );
        } else {
          rethrow;
        }
      }

      final currentUser = credential.user ?? FirebaseAuth.instance.currentUser;
      if (currentUser != null) {
        final docRef = FirebaseFirestore.instance.collection('users').doc(currentUser.uid);
        final doc = await docRef.get();
        if (!doc.exists) {
          await docRef.set({
            'userId': currentUser.uid,
            'usuario': isAdmin ? 'Jorge Torres' : 'Kenji Reader',
            'correo': email,
            'celular': isAdmin ? '952336505' : '+51 952336505',
            'clan': 'Carmesí',
            'rango': isAdmin ? 'ROOT ADMIN' : 'LECTOR REGULAR',
            'nivel': isAdmin ? 99 : 12,
            'rol': isAdmin ? 'admin' : 'reader',
            'avatar': '',
            'bio': isAdmin ? 'Admin principal' : 'Lector de Manga',
            'fecha_registro': FieldValue.serverTimestamp(),
          });
        } else {
          // Si el documento ya existe, limpiar campos duplicados (email/telefono) sin sobreescribir datos personalizados
          final data = doc.data() ?? {};
          final cleanup = <String, dynamic>{};
          if (data.containsKey('email')) cleanup['email'] = FieldValue.delete();
          if (data.containsKey('telefono')) {
            if (data['celular'] == null || data['celular'] == '+51 987654321') {
              cleanup['celular'] = data['telefono'];
            }
            cleanup['telefono'] = FieldValue.delete();
          }
          if (cleanup.isNotEmpty) {
            await docRef.update(cleanup);
          }
        }
      }

      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });

      Navigator.of(context).pushReplacement(MaterialPageRoute(
        builder: (ctx) => FetchScreen(isAdmin: isAdmin),
      ));
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
      showErrorDialog('Error al conectar credenciales: $e');
    }
  }

  void autenticacionGoogle() async {
    try {
      setState(() {
        _isLoading = true;
      });

      final GoogleSignIn googleSignIn = GoogleSignIn();
      final GoogleSignInAccount? googleSignInAccount =
          await googleSignIn.signIn();

      if (googleSignInAccount != null) {
        final GoogleSignInAuthentication googleSignInAuthentication =
            await googleSignInAccount.authentication;

        final AuthCredential credential = GoogleAuthProvider.credential(
          accessToken: googleSignInAuthentication.accessToken,
          idToken: googleSignInAuthentication.idToken,
        );

        final UserCredential userCredential =
            await FirebaseAuth.instance.signInWithCredential(credential);

        if (userCredential.user != null) {
          if (!mounted) return;
          setState(() {
            _isLoading = false;
          });
          Navigator.of(context).pushReplacement(MaterialPageRoute(
            builder: (ctx) => const FetchScreen(),
          ));
        }
      } else {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
      showErrorDialog(
        e.toString().contains('ApiException: 10')
            ? 'Error de configuración (ApiException: 10): Recuerda registrar la clave SHA-1 en la consola de Firebase.'
            : 'No se pudo iniciar con Google: $e',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: KuroTheme.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: size.height - MediaQuery.of(context).padding.top - 32,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 12),

                // Top emblem + VOL.01 badge
                Center(
                  child: Stack(
                    alignment: Alignment.topCenter,
                    clipBehavior: Clip.none,
                    children: [
                      Container(
                        width: 58,
                        height: 58,
                        decoration: BoxDecoration(
                          color: KuroTheme.card,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: KuroTheme.border),
                          boxShadow: [
                            BoxShadow(
                              color: KuroTheme.crimson.withValues(alpha: 0.15),
                              blurRadius: 20,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: const Center(
                          child: Icon(
                            Icons.auto_awesome,
                            color: KuroTheme.crimson,
                            size: 26,
                          ),
                        ),
                      ),
                      Positioned(
                        top: -10,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: KuroTheme.crimson,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            'VOL.01',
                            style: GoogleFonts.jetBrainsMono(
                              fontSize: 9,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // KURO / 黒 Logo
                RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: 'KURO ',
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 28,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                          letterSpacing: 2,
                        ),
                      ),
                      TextSpan(
                        text: '/ ',
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 26,
                          fontWeight: FontWeight.w700,
                          color: KuroTheme.crimson,
                        ),
                      ),
                      TextSpan(
                        text: '黒',
                        style: GoogleFonts.notoSansJp(
                          fontSize: 24,
                          fontWeight: FontWeight.w900,
                          color: KuroTheme.crimson,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 4),

                Text(
                  'MANGA READER & ANIME',
                  style: GoogleFonts.jetBrainsMono(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: KuroTheme.textMuted,
                    letterSpacing: 3.5,
                  ),
                ),

                const SizedBox(height: 24),

                // Sincronización Activa chip
                Align(
                  alignment: Alignment.centerLeft,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: KuroTheme.card,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: KuroTheme.border),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 6,
                          height: 6,
                          decoration: const BoxDecoration(
                            color: KuroTheme.crimson,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'SINCRONIZACIÓN ACTIVA',
                          style: GoogleFonts.jetBrainsMono(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: KuroTheme.textGrey,
                            letterSpacing: 0.8,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                // Iniciar Sesión Title
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Iniciar Sesión',
                    style: KuroTheme.title(fontSize: 26),
                  ),
                ),

                const SizedBox(height: 6),

                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Accede a tu biblioteca sincronizada y lanzamientos exclusivos.',
                    style: KuroTheme.body(
                      color: KuroTheme.textGrey,
                      fontSize: 13,
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // Campo IDENTIFICADOR / EMAIL
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'CORREO ELECTRÓNICO',
                      style: KuroTheme.mono(
                        fontSize: 10,
                        color: KuroTheme.textWhite,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      'ID DE LECTOR',
                      style: KuroTheme.mono(
                        fontSize: 10,
                        color: KuroTheme.textMuted,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Container(
                  height: 52,
                  decoration: KuroTheme.cardDecoration(),
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  child: Row(
                    children: [
                      const Icon(Icons.mail_outline,
                          color: KuroTheme.textMuted, size: 20),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextField(
                          controller: emailController,
                          keyboardType: TextInputType.emailAddress,
                          style: KuroTheme.body(
                              color: KuroTheme.textWhite, fontSize: 14),
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            hintText: 'usuario@dominio.com',
                            hintStyle: KuroTheme.body(
                              color: KuroTheme.textMuted,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 18),

                // Campo CLAVE DE ACCESO
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'CONTRASEÑA',
                      style: KuroTheme.mono(
                        fontSize: 10,
                        color: KuroTheme.textWhite,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      'PROTEGIDA',
                      style: KuroTheme.mono(
                        fontSize: 10,
                        color: KuroTheme.textMuted,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Container(
                  height: 52,
                  decoration: KuroTheme.cardDecoration(),
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  child: Row(
                    children: [
                      const Icon(Icons.lock_outline,
                          color: KuroTheme.textMuted, size: 20),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextField(
                          controller: passwordController,
                          obscureText: _obscurePassword,
                          style: KuroTheme.body(
                              color: KuroTheme.textWhite, fontSize: 14),
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            hintText: '•••••••••••••',
                            hintStyle: KuroTheme.body(
                              color: KuroTheme.textMuted,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ),
                      IconButton(
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined,
                          color: KuroTheme.textMuted,
                          size: 20,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscurePassword = !_obscurePassword;
                          });
                        },
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 10),

                // ¿Olvidaste tu contraseña?
                Align(
                  alignment: Alignment.centerRight,
                  child: GestureDetector(
                    onTap: () {
                      Navigator.push(context,
                          MaterialPageRoute(builder: (context) {
                        return const ForgotPasswordPage();
                      }));
                    },
                    child: Text(
                      '¿Olvidaste tu contraseña?',
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 12,
                        color: KuroTheme.textGrey,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Accesos Rápidos Demo Firebase (Admin Jorge & Lector Kenji)
                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => _autofillAndLogin(
                          email: 'jorge.torres.1994.1000@gmail.com',
                          password: 'Sukitteiinayo1',
                          isAdmin: true,
                        ),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          decoration: BoxDecoration(
                            color: KuroTheme.purple.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                                color: KuroTheme.purple.withValues(alpha: 0.5)),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.shield,
                                  color: KuroTheme.purple, size: 14),
                              const SizedBox(width: 6),
                              Text('ADMIN (JORGE)',
                                  style: KuroTheme.mono(
                                      fontSize: 9.5,
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: GestureDetector(
                        onTap: () => _autofillAndLogin(
                          email: 'lector.kuro@gmail.com',
                          password: 'MangaReader2026!',
                          isAdmin: false,
                        ),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          decoration: BoxDecoration(
                            color: KuroTheme.cyan.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                                color: KuroTheme.cyan.withValues(alpha: 0.5)),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.menu_book,
                                  color: KuroTheme.cyan, size: 14),
                              const SizedBox(width: 6),
                              Text('LECTOR RANDOM',
                                  style: KuroTheme.mono(
                                      fontSize: 9.5,
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Botón INICIAR SESIÓN
                KuroTheme.primaryButton(
                  text: 'INICIAR SESIÓN',
                  icon: Icons.arrow_forward,
                  isLoading: _isLoading,
                  onTap: loguearUsuario,
                ),

                const SizedBox(height: 20),

                // Divider O CONTINÚA CON
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        height: 1,
                        color: KuroTheme.border,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Text(
                        'O CONTINÚA CON',
                        style: KuroTheme.mono(
                          fontSize: 9.5,
                          color: KuroTheme.textMuted,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Container(
                        height: 1,
                        color: KuroTheme.border,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Botón Continuar con Google
                Container(
                  width: double.infinity,
                  height: 48,
                  decoration: BoxDecoration(
                    color: KuroTheme.card,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: KuroTheme.border),
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: autenticacionGoogle,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset(
                            'iconos/google.png',
                            height: 20,
                          ),
                          const SizedBox(width: 10),
                          Text(
                            'Continuar con Google',
                            style: GoogleFonts.spaceGrotesk(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: KuroTheme.textWhite,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // Footer: ¿No tienes una cuenta? Regístrate
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '¿No tienes una cuenta? ',
                      style: KuroTheme.body(
                        color: KuroTheme.textGrey,
                        fontSize: 13,
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(context,
                            MaterialPageRoute(builder: (context) {
                          return const RegisterPage();
                        }));
                      },
                      child: Text(
                        'Regístrate',
                        style: GoogleFonts.spaceGrotesk(
                          color: KuroTheme.crimson,
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                // Términos • Privacidad • v2.4.0-JP
                Text(
                  'Términos   •   Privacidad   •   v2.4.0-JP',
                  style: KuroTheme.mono(
                    fontSize: 9.5,
                    color: KuroTheme.textMuted,
                    letterSpacing: 1.5,
                  ),
                ),
                const SizedBox(height: 10),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
