import 'package:aplicacion_manga/Screens/admin_pagina_config_usuario.dart';
import 'package:aplicacion_manga/Screens/login_page.dart';
import 'package:aplicacion_manga/Screens/wishlist/admin_wishlist_screen.dart';
import 'package:aplicacion_manga/inner_screens/OnlineViewScreen.dart';
import 'package:aplicacion_manga/theme/kuro_theme.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AdminPaginaUsuarios extends StatefulWidget {
  const AdminPaginaUsuarios({Key? key}) : super(key: key);

  @override
  State<AdminPaginaUsuarios> createState() => _AdminPaginaUsuariosState();
}

class _AdminPaginaUsuariosState extends State<AdminPaginaUsuarios> {
  int _selectedTab = 0; // 0: Historial, 1: Mi Biblioteca
  bool _alertasPush = true;
  String _nombre = 'Ren Takahashi';
  String _usuario = '@takahashi_kuro';
  String _correo = 'ren.takahashi@kuro.manga';
  String _clan = 'CLAN CARMESÍ (黒鬼)';
  String _rango = 'VETERANO';
  int _nivel = 42;

  @override
  void initState() {
    super.initState();
    _cargarDatosUsuario();
  }

  Future<void> _cargarDatosUsuario() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      if (doc.exists) {
        setState(() {
          _correo = user.email ?? _correo;
          _usuario = '@${doc.data()?['usuario'] ?? user.email?.split('@')[0]}';
          _nombre = doc.data()?['usuario'] ?? 'Ren Takahashi';
          _clan = 'CLAN ${(doc.data()?['clan'] ?? 'CARMESÍ').toString().toUpperCase()}';
          _rango = doc.data()?['rango'] ?? 'VETERANO';
          _nivel = doc.data()?['nivel'] ?? 42;
        });
      }
    }
  }

  void _cerrarSesion() async {
    await FirebaseAuth.instance.signOut();
    if (!mounted) return;
    Navigator.of(context, rootNavigator: true).pushReplacement(
      MaterialPageRoute(builder: (ctx) => const LoginPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: KuroTheme.background,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Bar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: 'KURO ',
                            style: GoogleFonts.spaceGrotesk(
                              fontSize: 22,
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                              letterSpacing: 2,
                            ),
                          ),
                          TextSpan(
                            text: '/ ',
                            style: GoogleFonts.spaceGrotesk(
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              color: KuroTheme.crimson,
                            ),
                          ),
                          TextSpan(
                            text: '黒',
                            style: GoogleFonts.notoSansJp(
                              fontSize: 18,
                              fontWeight: FontWeight.w900,
                              color: KuroTheme.crimson,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Row(
                      children: [
                        Container(
                          width: 38,
                          height: 38,
                          decoration: BoxDecoration(
                            color: KuroTheme.card,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: KuroTheme.border),
                          ),
                          child: const Icon(Icons.notifications_none, color: KuroTheme.textWhite, size: 18),
                        ),
                        const SizedBox(width: 10),
                        Container(
                          width: 38,
                          height: 38,
                          decoration: BoxDecoration(
                            color: const Color(0xFFF7728B),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(Icons.person, color: Colors.black, size: 22),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Profile Card Header (Ren Takahashi)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: KuroTheme.cardDecoration(),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Stack(
                            clipBehavior: Clip.none,
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(14),
                                child: Image.network(
                                  'https://images.unsplash.com/photo-1578632767115-351597cf2477?w=800',
                                  width: 64,
                                  height: 64,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              Positioned(
                                bottom: -6,
                                left: 6,
                                right: 6,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1.5),
                                  decoration: BoxDecoration(
                                    color: KuroTheme.crimson,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Center(
                                    child: Text(
                                      '🔥 LV.$_nivel',
                                      style: KuroTheme.mono(fontSize: 8, color: Colors.white, fontWeight: FontWeight.w800),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      _nombre,
                                      style: GoogleFonts.spaceGrotesk(fontSize: 16, fontWeight: FontWeight.w800, color: Colors.white),
                                    ),
                                    const SizedBox(width: 4),
                                    const Icon(Icons.verified, color: KuroTheme.cyan, size: 16),
                                  ],
                                ),
                                Text(_usuario, style: KuroTheme.mono(fontSize: 10.5, color: KuroTheme.crimson, fontWeight: FontWeight.w700)),
                                Text(_correo, style: KuroTheme.mono(fontSize: 9.5, color: KuroTheme.textMuted)),
                              ],
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.tune, color: KuroTheme.textGrey, size: 20),
                            onPressed: () {
                              Navigator.push(context, MaterialPageRoute(builder: (c) => const AdminPaginaConfigUsuario()));
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: KuroTheme.cardLighter,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Container(width: 5, height: 5, decoration: const BoxDecoration(color: KuroTheme.crimson, shape: BoxShape.circle)),
                                const SizedBox(width: 6),
                                Text('RANGO OTAKU // $_clan', style: KuroTheme.mono(fontSize: 8.5, color: KuroTheme.textGrey, fontWeight: FontWeight.w700)),
                              ],
                            ),
                            Text(_rango, style: KuroTheme.mono(fontSize: 8.5, color: Colors.white, fontWeight: FontWeight.w800)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // 3-Stats Row: 348 Capítulos | 42 Biblioteca | 1,240h Inmersión
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    _buildStatBox('348', 'CAPÍTULOS', Colors.white),
                    const SizedBox(width: 8),
                    _buildStatBox('42', 'BIBLIOTECA', KuroTheme.cyan),
                    const SizedBox(width: 8),
                    _buildStatBox('1,240h', 'INMERSIÓN', KuroTheme.purple),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Tabs: Historial (4) vs Mi Biblioteca (42)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _selectedTab = 0),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          decoration: BoxDecoration(
                            color: _selectedTab == 0 ? KuroTheme.crimson : KuroTheme.card,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: _selectedTab == 0 ? KuroTheme.crimson : KuroTheme.border),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.history, color: Colors.white, size: 16),
                              const SizedBox(width: 6),
                              Text('Historial', style: GoogleFonts.spaceGrotesk(fontSize: 12, fontWeight: FontWeight.w700, color: Colors.white)),
                              const SizedBox(width: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                                decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.25), borderRadius: BorderRadius.circular(10)),
                                child: Text('4', style: KuroTheme.mono(fontSize: 9, color: Colors.white)),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          setState(() => _selectedTab = 1);
                          Navigator.push(context, MaterialPageRoute(builder: (c) => const AdminWishListScreem()));
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          decoration: BoxDecoration(
                            color: _selectedTab == 1 ? KuroTheme.crimson : KuroTheme.card,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: _selectedTab == 1 ? KuroTheme.crimson : KuroTheme.border),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.bookmark_outline, color: KuroTheme.textGrey, size: 16),
                              const SizedBox(width: 6),
                              Text('Mi Biblioteca', style: GoogleFonts.spaceGrotesk(fontSize: 12, fontWeight: FontWeight.w700, color: KuroTheme.textGrey)),
                              const SizedBox(width: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                                decoration: BoxDecoration(color: KuroTheme.cardLighter, borderRadius: BorderRadius.circular(10)),
                                child: Text('42', style: KuroTheme.mono(fontSize: 9, color: KuroTheme.textGrey)),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Section: // LECTURAS EN CURSO
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('// LECTURAS EN CURSO', style: KuroTheme.mono(fontSize: 10, color: KuroTheme.textWhite, fontWeight: FontWeight.w700)),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(color: KuroTheme.card, borderRadius: BorderRadius.circular(4)),
                          child: Text('Esta semana', style: KuroTheme.mono(fontSize: 8.5, color: KuroTheme.textGrey)),
                        ),
                        const SizedBox(width: 8),
                        const Icon(Icons.delete_outline, color: KuroTheme.textMuted, size: 16),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 12),

              _buildReadingCard(
                badge: 'RAW',
                badgeColor: KuroTheme.crimson,
                title: 'BERSERK: SOULS',
                timeAgo: 'Hace 2h',
                chapter: 'Cap. 142: El Festín d...',
                sub: 'Tomo 18 // Pág. 34 de 42',
                progress: 0.82,
                progressText: '82% completado',
                extraText: 'Restan 4m',
                imgUrl: 'https://images.unsplash.com/photo-1578632767115-351597cf2477?w=800',
              ),
              _buildReadingCard(
                badge: 'COLOR',
                badgeColor: KuroTheme.purple,
                title: 'CHAINSAW LEGACY',
                timeAgo: 'Ayer',
                chapter: 'Cap. 164: Fuego y M...',
                sub: 'Arco del Demonio de Sangre',
                progress: 0.45,
                progressText: '45% completado',
                extraText: 'Pág. 11/24',
                imgUrl: 'https://images.unsplash.com/photo-1607604276583-eef5d076aa5f?w=800',
              ),
              _buildReadingCard(
                badge: '✔',
                badgeColor: KuroTheme.cyan,
                title: 'TOKYO GHOUL: RE',
                timeAgo: 'Hace 3 días',
                chapter: 'Cap. 179: La Máscar...',
                sub: 'Epílogo Completo',
                progress: 1.0,
                progressText: '100% Completado',
                extraText: 'Releer',
                imgUrl: 'https://cdn.shopify.com/s/files/1/0399/1833/8203/files/broly-dragon-ball_2048x2048.jpg?v=1616868885',
              ),
              _buildReadingCard(
                badge: '',
                badgeColor: Colors.transparent,
                title: 'VAGABOND: KENSEI',
                timeAgo: 'Hace 5 días',
                chapter: 'Cap. 88: El Duelo del...',
                sub: 'Volumen 11 // Kyoto Arc',
                progress: 0.28,
                progressText: '28% completado',
                extraText: 'Pág. 7/25',
                imgUrl: 'https://e.rpp-noticias.io/xlarge/2018/11/22/484448_715070.jpg',
              ),

              const SizedBox(height: 20),

              // Section: // PREFERENCIAS & MOTOR DE LECTURA
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text('// PREFERENCIAS & MOTOR DE LECTURA', style: KuroTheme.mono(fontSize: 10, color: KuroTheme.textWhite, fontWeight: FontWeight.w700)),
              ),
              const SizedBox(height: 10),

              _buildPrefTile(
                icon: Icons.cloud_download_outlined,
                title: 'Descargas & Caché Offline',
                subtitle: '1.4 GB usados en 12 tomos',
                trailing: const Icon(Icons.arrow_forward_ios, color: KuroTheme.textMuted, size: 14),
                onTap: () {},
              ),
              _buildPrefTile(
                icon: Icons.menu_book,
                title: 'Ajustes del Lector Koma',
                subtitle: 'Modo Cascada // Filtro OLED Puro',
                trailing: const Icon(Icons.arrow_forward_ios, color: KuroTheme.textMuted, size: 14),
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (c) => const AdminPaginaConfigUsuario()));
                },
              ),
              _buildPrefTile(
                icon: Icons.notifications_none,
                title: 'Alertas de Nuevos Capítulos',
                subtitle: 'Notificaciones Push activadas',
                trailing: Switch(
                  value: _alertasPush,
                  activeTrackColor: KuroTheme.crimson,
                  activeThumbColor: Colors.white,
                  onChanged: (val) => setState(() => _alertasPush = val),
                ),
                onTap: () {},
              ),

              const SizedBox(height: 20),

              // Botón CERRAR SESIÓN
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: GestureDetector(
                  onTap: _cerrarSesion,
                  child: Container(
                    height: 48,
                    decoration: BoxDecoration(
                      color: KuroTheme.card,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: KuroTheme.crimson.withValues(alpha: 0.5)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.logout, color: KuroTheme.crimson, size: 18),
                        const SizedBox(width: 8),
                        Text(
                          'CERRAR SESIÓN',
                          style: GoogleFonts.spaceGrotesk(fontSize: 12, fontWeight: FontWeight.w800, color: KuroTheme.crimson, letterSpacing: 1),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Footer: KURO APP V2.4.1 // BUILD 894
              Center(
                child: Text(
                  'KURO APP V2.4.1 // BUILD 894\nNEO-MANGA CINEMATIC ENGINE • PRO EDITION',
                  textAlign: TextAlign.center,
                  style: KuroTheme.mono(fontSize: 8.5, color: KuroTheme.textMuted, letterSpacing: 1.0),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatBox(String val, String label, Color valColor) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: KuroTheme.cardDecoration(),
        child: Column(
          children: [
            Text(val, style: GoogleFonts.spaceGrotesk(fontSize: 18, fontWeight: FontWeight.w900, color: valColor)),
            const SizedBox(height: 2),
            Text(label, style: KuroTheme.mono(fontSize: 8, color: KuroTheme.textMuted, fontWeight: FontWeight.w700)),
          ],
        ),
      ),
    );
  }

  Widget _buildReadingCard({
    required String badge,
    required Color badgeColor,
    required String title,
    required String timeAgo,
    required String chapter,
    required String sub,
    required double progress,
    required String progressText,
    required String extraText,
    required String imgUrl,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
      child: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (ctx) => OnlineViewScreen(
                pdfUrl: '',
                mangaTitle: '$title $chapter',
              ),
            ),
          );
        },
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: KuroTheme.cardDecoration(),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(imgUrl, width: 48, height: 62, fit: BoxFit.cover),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            if (badge.isNotEmpty) ...[
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                                decoration: BoxDecoration(color: badgeColor, borderRadius: BorderRadius.circular(3)),
                                child: Text(badge, style: KuroTheme.mono(fontSize: 7.5, color: Colors.white, fontWeight: FontWeight.w800)),
                              ),
                              const SizedBox(width: 6),
                            ],
                            Text(title, style: KuroTheme.mono(fontSize: 9, color: KuroTheme.textMuted, fontWeight: FontWeight.w700)),
                          ],
                        ),
                        Text(timeAgo, style: KuroTheme.mono(fontSize: 8, color: KuroTheme.textMuted)),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(chapter, style: GoogleFonts.spaceGrotesk(fontSize: 13, fontWeight: FontWeight.w700, color: Colors.white), maxLines: 1),
                    Text(sub, style: KuroTheme.body(fontSize: 9.5, color: KuroTheme.textGrey), maxLines: 1),
                    const SizedBox(height: 6),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(progressText, style: KuroTheme.mono(fontSize: 8, color: KuroTheme.cyan)),
                        Text(extraText, style: KuroTheme.mono(fontSize: 8, color: KuroTheme.textMuted)),
                      ],
                    ),
                    const SizedBox(height: 3),
                    Container(
                      height: 2.5,
                      decoration: BoxDecoration(color: KuroTheme.cardLighter, borderRadius: BorderRadius.circular(2)),
                      child: FractionallySizedBox(
                        alignment: Alignment.centerLeft,
                        widthFactor: progress,
                        child: Container(decoration: BoxDecoration(color: KuroTheme.crimson, borderRadius: BorderRadius.circular(2))),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: progress == 1.0 ? KuroTheme.cardLighter : KuroTheme.crimson,
                  shape: BoxShape.circle,
                ),
                child: Icon(progress == 1.0 ? Icons.replay : Icons.play_arrow, color: Colors.white, size: 18),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPrefTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required Widget trailing,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: KuroTheme.cardDecoration(),
          child: Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(color: KuroTheme.cardLighter, borderRadius: BorderRadius.circular(8)),
                child: Icon(icon, color: KuroTheme.textWhite, size: 16),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: GoogleFonts.spaceGrotesk(fontSize: 12, fontWeight: FontWeight.w700, color: Colors.white)),
                    Text(subtitle, style: KuroTheme.body(fontSize: 9.5, color: KuroTheme.textMuted)),
                  ],
                ),
              ),
              trailing,
            ],
          ),
        ),
      ),
    );
  }
}
