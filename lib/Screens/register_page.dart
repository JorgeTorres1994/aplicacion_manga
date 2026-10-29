import 'package:aplicacion_manga/Screens/login_page.dart';
import 'package:aplicacion_manga/fetch_screen.dart';
import 'package:aplicacion_manga/theme/kuro_theme.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final usuarioController = TextEditingController();
  final correoController = TextEditingController();
  final prefijoController = TextEditingController(text: '+51');
  final celularController = TextEditingController();
  final passwordController = TextEditingController();

  bool _obscurePassword = true;
  bool _aceptaTerminos = true;
  bool _isLoading = false;

  String _selectedClan = 'Carmesí'; // Default clan

  final List<Map<String, dynamic>> _clanes = [
    {
      'id': 'Sombra',
      'sub': 'Kage / 影',
      'icon': Icons.nightlight_round,
    },
    {
      'id': 'Carmesí',
      'sub': 'Akane / 茜',
      'icon': Icons.local_fire_department,
    },
    {
      'id': 'Éter',
      'sub': 'Mugen / 夢',
      'icon': Icons.all_inclusive,
    },
    {
      'id': 'Ronin',
      'sub': 'Mu / 無',
      'icon': Icons.shield_outlined,
    },
  ];

  @override
  void dispose() {
    usuarioController.dispose();
    correoController.dispose();
    prefijoController.dispose();
    celularController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  bool validarCampos() {
    if (usuarioController.text.trim().isEmpty ||
        correoController.text.trim().isEmpty ||
        passwordController.text.trim().isEmpty) {
      showErrorDialog('Por favor completa todos los campos del registro.');
      return false;
    }
    if (!_aceptaTerminos) {
      showErrorDialog('Debes aceptar los términos de la comunidad de lectura.');
      return false;
    }
    if (passwordController.text.trim().length < 6) {
      showErrorDialog('La contraseña debe contener al menos 6 caracteres.');
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
            'AVISO DE REGISTRO',
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

  Future<void> registrarUsuario() async {
    if (!validarCampos()) return;

    try {
      setState(() {
        _isLoading = true;
      });

      final userCredential =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: correoController.text.trim(),
        password: passwordController.text.trim(),
      );

      final User? user = userCredential.user;
      if (user != null) {
        // Determinar rol (si es admin específico)
        final isKuroAdmin = correoController.text.trim().toLowerCase().contains('admin');

        await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
          'userId': user.uid,
          'usuario': usuarioController.text.trim(),
          'correo': correoController.text.trim(),
          'celular': '${prefijoController.text.trim()} ${celularController.text.trim()}',
          'clan': _selectedClan,
          'rango': isKuroAdmin ? 'ROOT ADMIN' : 'VETERANO',
          'nivel': isKuroAdmin ? 99 : 42,
          'rol': isKuroAdmin ? 'admin' : 'reader',
          'fecha_registro': FieldValue.serverTimestamp(),
        });

        if (!mounted) return;
        setState(() {
          _isLoading = false;
        });

        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (ctx) => AlertDialog(
            backgroundColor: KuroTheme.card,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: const BorderSide(color: KuroTheme.border),
            ),
            title: Text(
              '¡CUENTA DE LECTOR CREADA!',
              style: KuroTheme.mono(color: KuroTheme.cyan, fontSize: 13),
            ),
            content: Text(
              'Bienvenido a Kuro Manga, ${usuarioController.text.trim()}. Tu biblioteca de lectura está lista.',
              style: KuroTheme.body(color: KuroTheme.textWhite, fontSize: 14),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(ctx).pop();
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (c) => const FetchScreen()),
                  );
                },
                child: Text(
                  'COMENZAR A LEER',
                  style: KuroTheme.mono(color: KuroTheme.crimson, fontSize: 13),
                ),
              ),
            ],
          ),
        );
      }
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });

      String errorMsg;
      if (e.code == 'weak-password') {
        errorMsg = 'La clave proporcionada es demasiado débil.';
      } else if (e.code == 'email-already-in-use') {
        errorMsg = 'Ya existe una cuenta registrada con este correo.';
      } else if (e.code == 'invalid-email') {
        errorMsg = 'El formato de correo no es válido.';
      } else {
        errorMsg = e.message ?? 'Fallo de registro (${e.code})';
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: KuroTheme.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Banner con estilo Cyberpunk
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF1F2433), Color(0xFF12141C)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: KuroTheme.border),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: KuroTheme.cardLighter,
                        borderRadius: BorderRadius.circular(4),
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
                          const SizedBox(width: 6),
                          Text(
                            'COMIENZA TU VIAJE // PROTOCOL 01',
                            style: KuroTheme.mono(
                              fontSize: 9,
                              fontWeight: FontWeight.w700,
                              color: KuroTheme.textGrey,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          'CREAR\nCUENTA',
                          style: GoogleFonts.spaceGrotesk(
                            fontSize: 28,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                            height: 1.05,
                            letterSpacing: 1.5,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(bottom: 4),
                          child: Text(
                            'Registro de Lector',
                            style: KuroTheme.mono(
                              fontSize: 11,
                              color: KuroTheme.textMuted,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Únete a la comunidad de lectores y guarda tus mangas favoritos en tiempo real.',
                      style: KuroTheme.body(
                        fontSize: 12,
                        color: KuroTheme.textGrey,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // KOMA // ID DE LECTOR
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'KOMA // ID DE LECTOR',
                    style: KuroTheme.mono(
                      fontSize: 10,
                      color: KuroTheme.textWhite,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    'REQUERIDO',
                    style: KuroTheme.mono(
                      fontSize: 9.5,
                      color: KuroTheme.crimson,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Container(
                height: 50,
                decoration: KuroTheme.cardDecoration(),
                padding: const EdgeInsets.symmetric(horizontal: 14),
                child: Row(
                  children: [
                    const Icon(Icons.badge_outlined,
                        color: KuroTheme.textMuted, size: 20),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextField(
                        controller: usuarioController,
                        style: KuroTheme.body(
                            color: KuroTheme.textWhite, fontSize: 14),
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          hintText: 'ej. Kuro_99',
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

              const SizedBox(height: 16),

              // CANAL DE TRANSMISIÓN // CORREO
              Text(
                'CANAL DE TRANSMISIÓN // CORREO',
                style: KuroTheme.mono(
                  fontSize: 10,
                  color: KuroTheme.textWhite,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 6),
              Container(
                height: 50,
                decoration: KuroTheme.cardDecoration(),
                padding: const EdgeInsets.symmetric(horizontal: 14),
                child: Row(
                  children: [
                    const Icon(Icons.alternate_email,
                        color: KuroTheme.textMuted, size: 20),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextField(
                        controller: correoController,
                        keyboardType: TextInputType.emailAddress,
                        style: KuroTheme.body(
                            color: KuroTheme.textWhite, fontSize: 14),
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          hintText: 'archivista@kuro.org',
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

              const SizedBox(height: 16),

              // TERMINAL MÓVIL // CONTACTO
              Text(
                'TERMINAL MÓVIL // CONTACTO',
                style: KuroTheme.mono(
                  fontSize: 10,
                  color: KuroTheme.textWhite,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  Container(
                    width: 72,
                    height: 50,
                    decoration: KuroTheme.cardDecoration(),
                    child: Center(
                      child: TextField(
                        controller: prefijoController,
                        textAlign: TextAlign.center,
                        style: KuroTheme.mono(
                            color: KuroTheme.textWhite,
                            fontSize: 13,
                            fontWeight: FontWeight.w700),
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Container(
                      height: 50,
                      decoration: KuroTheme.cardDecoration(),
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      child: Row(
                        children: [
                          const Icon(Icons.phone_outlined,
                              color: KuroTheme.textMuted, size: 20),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextField(
                              controller: celularController,
                              keyboardType: TextInputType.phone,
                              style: KuroTheme.body(
                                  color: KuroTheme.textWhite, fontSize: 14),
                              decoration: InputDecoration(
                                border: InputBorder.none,
                                hintText: '090-0000-0000',
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
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // CLAVE CIFRADA // CONTRASEÑA
              Text(
                'CLAVE CIFRADA // CONTRASEÑA',
                style: KuroTheme.mono(
                  fontSize: 10,
                  color: KuroTheme.textWhite,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 6),
              Container(
                height: 50,
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

              // SEGURIDAD DE CLAVE // ESTADO: SEGURA
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'SEGURIDAD DE CLAVE',
                    style: KuroTheme.mono(
                      fontSize: 9,
                      color: KuroTheme.textMuted,
                    ),
                  ),
                  Text(
                    'ESTADO: SEGURA',
                    style: KuroTheme.mono(
                      fontSize: 9,
                      color: KuroTheme.cyan,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  Expanded(
                    flex: 6,
                    child: Container(
                      height: 4,
                      decoration: BoxDecoration(
                        color: KuroTheme.crimson,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    flex: 4,
                    child: Container(
                      height: 4,
                      decoration: BoxDecoration(
                        color: KuroTheme.cyan,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // SELECCIONA CLAN // ESTILO
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'SELECCIONA CLAN // ESTILO',
                    style: KuroTheme.mono(
                      fontSize: 10,
                      color: KuroTheme.textWhite,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    '4 DISPONIBLES',
                    style: KuroTheme.mono(
                      fontSize: 9.5,
                      color: KuroTheme.textMuted,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              // 2x2 Grid de Clanes
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  childAspectRatio: 2.3,
                ),
                itemCount: _clanes.length,
                itemBuilder: (context, index) {
                  final clan = _clanes[index];
                  final isSelected = _selectedClan == clan['id'];

                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedClan = clan['id'];
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 8),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? KuroTheme.crimson.withValues(alpha: 0.18)
                            : KuroTheme.card,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: isSelected
                              ? KuroTheme.crimson
                              : KuroTheme.border,
                          width: isSelected ? 1.5 : 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? KuroTheme.crimson
                                  : KuroTheme.cardLighter,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Icon(
                              clan['icon'] as IconData,
                              size: 18,
                              color: isSelected
                                  ? Colors.white
                                  : KuroTheme.textGrey,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  clan['id'] as String,
                                  style: GoogleFonts.spaceGrotesk(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    color: KuroTheme.textWhite,
                                  ),
                                ),
                                Text(
                                  clan['sub'] as String,
                                  style: KuroTheme.mono(
                                    fontSize: 9,
                                    color: KuroTheme.textMuted,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),

              const SizedBox(height: 16),

              // Checkbox Términos
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Theme(
                    data: ThemeData(unselectedWidgetColor: KuroTheme.border),
                    child: Checkbox(
                      value: _aceptaTerminos,
                      activeColor: KuroTheme.crimson,
                      checkColor: Colors.white,
                      onChanged: (val) {
                        setState(() {
                          _aceptaTerminos = val ?? false;
                        });
                      },
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 10),
                      child: RichText(
                        text: TextSpan(
                          style: KuroTheme.body(
                            fontSize: 11,
                            color: KuroTheme.textGrey,
                          ),
                          children: [
                            const TextSpan(
                                text: 'Acepto los términos de la '),
                            TextSpan(
                              text: 'Comunidad Manga',
                              style: TextStyle(
                                color: KuroTheme.textWhite,
                                decoration: TextDecoration.underline,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const TextSpan(
                              text:
                                  ' y las políticas de privacidad de la plataforma.',
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Botón REGISTRAR CUENTA
              KuroTheme.primaryButton(
                text: 'REGISTRAR CUENTA',
                icon: Icons.arrow_forward,
                isLoading: _isLoading,
                onTap: registrarUsuario,
              ),

              const SizedBox(height: 20),

              // ¿Ya tienes una cuenta? Inicia Sesión
              Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '¿Ya tienes una cuenta? ',
                      style: KuroTheme.body(
                        color: KuroTheme.textGrey,
                        fontSize: 13,
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.pushReplacement(context,
                            MaterialPageRoute(builder: (context) {
                          return const LoginPage();
                        }));
                      },
                      child: Text(
                        'Inicia Sesión',
                        style: GoogleFonts.spaceGrotesk(
                          color: KuroTheme.crimson,
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 12),

              Center(
                child: Text(
                  'CORE V2.4.0-JP   •   🔒 256-BIT KURO CIPHER',
                  style: KuroTheme.mono(
                    fontSize: 9.5,
                    color: KuroTheme.textMuted,
                    letterSpacing: 1.2,
                  ),
                ),
              ),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }
}
