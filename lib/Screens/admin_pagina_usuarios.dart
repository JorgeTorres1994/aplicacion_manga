import 'dart:io';
import 'package:aplicacion_manga/Screens/admin_pagina_config_usuario.dart';
import 'package:aplicacion_manga/Screens/components/edit_reader_profile_sheet.dart';
import 'package:aplicacion_manga/Screens/login_page.dart';
import 'package:aplicacion_manga/Screens/wishlist/admin_wishlist_screen.dart';
import 'package:aplicacion_manga/inner_screens/OnlineViewScreen.dart';
import 'package:aplicacion_manga/providers/wishlist_providers.dart';
import 'package:aplicacion_manga/services/reader_service.dart';
import 'package:aplicacion_manga/theme/kuro_theme.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class AdminPaginaUsuarios extends StatefulWidget {
  const AdminPaginaUsuarios({Key? key}) : super(key: key);

  @override
  State<AdminPaginaUsuarios> createState() => _AdminPaginaUsuariosState();
}

class _AdminPaginaUsuariosState extends State<AdminPaginaUsuarios> {
  int _selectedTab = 0; // 0: Historial, 1: Mi Biblioteca
  bool _alertasPush = true;
  String _nombre = 'Kenji Reader';
  String _usuario = '@kenji_reader';
  String _correo = 'lector@kuro.manga';
  String _clan = 'CLAN CARMESÍ (黒鬼)';
  String _rango = 'VETERANO';
  String _avatar = '';
  String _celular = '+51 952336505';
  String _bio = 'Lector devoto de manga oscuro y seinen.';
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
      if (doc.exists && mounted) {
        final data = doc.data() ?? {};
        setState(() {
          _correo = user.email ?? _correo;
          _usuario = '@${data['usuario'] != null ? data['usuario'].toString().toLowerCase().replaceAll(' ', '_') : user.email?.split('@')[0]}';
          _nombre = data['usuario'] ?? 'Kenji Reader';
          _clan = data['clan'] != null ? data['clan'].toString() : 'CLAN CARMESÍ (黒鬼)';
          _rango = data['rango'] ?? 'VETERANO';
          _avatar = data['avatar']?.toString() ?? '';
          _celular = data['celular']?.toString() ?? '';
          _bio = data['bio']?.toString() ?? '';
          _nivel = data['nivel'] ?? 42;
        });
      }
    }
  }

  void _abrirModalEditarPerfil() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => EditReaderProfileSheet(
        initialName: _nombre,
        initialPhone: _celular,
        initialClan: _clan,
        initialAvatar: _avatar,
        initialBio: _bio,
        onProfileUpdated: (name, phone, clan, avatar, bio) {
          setState(() {
            _nombre = name;
            _usuario = '@${name.toLowerCase().replaceAll(' ', '_')}';
            _celular = phone;
            _clan = clan;
            _avatar = avatar;
            _bio = bio;
          });
        },
      ),
    );
  }

  Color _getClanColor(String clanStr) {
    final lower = clanStr.toLowerCase();
    if (lower.contains('sombra')) return KuroTheme.purple;
    if (lower.contains('ciber')) return KuroTheme.cyan;
    if (lower.contains('oro')) return KuroTheme.gold;
    if (lower.contains('vac')) return KuroTheme.textGrey;
    return KuroTheme.crimson;
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
                          GestureDetector(
                            onTap: _abrirModalEditarPerfil,
                            child: Stack(
                              clipBehavior: Clip.none,
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(14),
                                  child: _avatar.isNotEmpty
                                      ? (_avatar.startsWith('http')
                                          ? Image.network(
                                              _avatar,
                                              width: 64,
                                              height: 64,
                                              fit: BoxFit.cover,
                                              errorBuilder: (_, __, ___) => Container(
                                                width: 64,
                                                height: 64,
                                                color: KuroTheme.cardLighter,
                                                child: const Icon(Icons.person, color: Colors.white, size: 28),
                                              ),
                                            )
                                          : Image.file(
                                              File(_avatar),
                                              width: 64,
                                              height: 64,
                                              fit: BoxFit.cover,
                                              errorBuilder: (_, __, ___) => Container(
                                                width: 64,
                                                height: 64,
                                                color: KuroTheme.cardLighter,
                                                child: const Icon(Icons.person, color: Colors.white, size: 28),
                                              ),
                                            ))
                                      : Container(
                                          width: 64,
                                          height: 64,
                                          color: const Color(0xFFF7728B),
                                          child: const Icon(Icons.person, color: Colors.black, size: 28),
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
                                Positioned(
                                  top: -4,
                                  right: -4,
                                  child: Container(
                                    padding: const EdgeInsets.all(3),
                                    decoration: const BoxDecoration(
                                      color: KuroTheme.crimson,
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(Icons.edit, color: Colors.white, size: 10),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        _nombre,
                                        style: GoogleFonts.spaceGrotesk(fontSize: 16, fontWeight: FontWeight.w800, color: Colors.white),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    const SizedBox(width: 4),
                                    const Icon(Icons.verified, color: KuroTheme.cyan, size: 16),
                                  ],
                                ),
                                Text(_usuario, style: KuroTheme.mono(fontSize: 10.5, color: KuroTheme.crimson, fontWeight: FontWeight.w700)),
                                Text(_correo, style: KuroTheme.mono(fontSize: 9.5, color: KuroTheme.textMuted)),
                                if (_celular.isNotEmpty)
                                  Text('📱 $_celular', style: KuroTheme.mono(fontSize: 9, color: KuroTheme.cyan)),
                              ],
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.tune, color: KuroTheme.textGrey, size: 20),
                            onPressed: () {
                              Navigator.push(context, MaterialPageRoute(builder: (c) => const AdminPaginaConfigUsuario()))
                                  .then((_) => _cargarDatosUsuario());
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
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
                                Container(
                                  width: 6,
                                  height: 6,
                                  decoration: BoxDecoration(
                                    color: _getClanColor(_clan),
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Text('RANGO OTAKU // $_clan',
                                    style: KuroTheme.mono(fontSize: 8.5, color: KuroTheme.textGrey, fontWeight: FontWeight.w700)),
                              ],
                            ),
                            Text(_rango, style: KuroTheme.mono(fontSize: 8.5, color: Colors.white, fontWeight: FontWeight.w800)),
                          ],
                        ),
                      ),
                      if (_bio.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Text(
                          '"$_bio"',
                          style: KuroTheme.body(fontSize: 10.5, color: KuroTheme.textGrey),
                        ),
                      ],
                      const SizedBox(height: 12),
                      GestureDetector(
                        onTap: _abrirModalEditarPerfil,
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 9),
                          decoration: BoxDecoration(
                            color: _getClanColor(_clan).withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: _getClanColor(_clan).withValues(alpha: 0.45)),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.edit, size: 13, color: _getClanColor(_clan)),
                              const SizedBox(width: 8),
                              Text(
                                'EDITAR PERFIL, FOTO Y CLAN',
                                style: KuroTheme.mono(fontSize: 9.5, color: Colors.white, fontWeight: FontWeight.w800),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // 3-Stats Row & Tabs (Conectados en vivo al backend de Firestore)
              StreamBuilder<List<Map<String, dynamic>>>(
                stream: KuroReaderBackendService.instance.streamReadingHistory(
                    FirebaseAuth.instance.currentUser?.uid ?? ''),
                builder: (context, histSnap) {
                  final readingList = histSnap.data ?? [];
                  final wishlistProvider = Provider.of<WishListProvider>(context);
                  final wishlistCount = wishlistProvider.getWishListItems.length;
                  final historyCount = readingList.length;

                  return Column(
                    children: [
                      // 3-Stats Row
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Row(
                          children: [
                            _buildStatBox('$historyCount', 'LEÍDOS', Colors.white),
                            const SizedBox(width: 8),
                            _buildStatBox('$wishlistCount', 'BIBLIOTECA', KuroTheme.cyan),
                            const SizedBox(width: 8),
                            _buildStatBox('LV.$_nivel', 'NIVEL', KuroTheme.purple),
                          ],
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Tabs: Historial vs Mi Biblioteca
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
                                        child: Text('$historyCount', style: KuroTheme.mono(fontSize: 9, color: Colors.white)),
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
                                        child: Text('$wishlistCount', style: KuroTheme.mono(fontSize: 9, color: KuroTheme.textGrey)),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                },
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

              StreamBuilder<List<Map<String, dynamic>>>(
                stream: KuroReaderBackendService.instance.streamReadingHistory(
                    FirebaseAuth.instance.currentUser?.uid ?? ''),
                builder: (context, snapshot) {
                  final list = snapshot.data ?? [];
                  if (list.isEmpty) {
                    return Container(
                      margin: const EdgeInsets.symmetric(horizontal: 20),
                      padding: const EdgeInsets.all(24),
                      decoration: KuroTheme.cardDecoration(),
                      child: Center(
                        child: Column(
                          children: [
                            const Icon(Icons.menu_book, color: KuroTheme.textMuted, size: 36),
                            const SizedBox(height: 8),
                            Text('Aún no tienes lecturas registradas',
                                style: GoogleFonts.spaceGrotesk(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white)),
                            const SizedBox(height: 4),
                            Text('Explora mangas en el catálogo para iniciar tu progreso',
                                style: KuroTheme.body(fontSize: 10, color: KuroTheme.textMuted)),
                          ],
                        ),
                      ),
                    );
                  }

                  return Column(
                    children: list.map((item) {
                      final title = item['mangaTitle'] ?? 'Manga';
                      final chapter = item['chapterTitle'] ?? 'Capítulo 1';
                      final tomo = item['tomoTitle'] ?? 'Tomo 01';
                      final progressInt =
                          (item['progressPercent'] as num?)?.toInt() ?? 0;
                      final double progress = (progressInt / 100.0).clamp(0.0, 1.0);
                      final imgUrl = item['coverUrl'] ?? '';
                      final pages = (item['pageImages'] as List?)
                          ?.map((e) => e.toString())
                          .toList();

                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (c) => OnlineViewScreen(
                                pdfUrl: item['pdfUrl'] ?? '',
                                pageImages: pages,
                                mangaId: item['mangaId'],
                                coverUrl: imgUrl,
                                mangaTitle: title,
                                chapterTitle: chapter,
                                tomoTitle: tomo,
                              ),
                            ),
                          );
                        },
                        child: _buildReadingCard(
                          badge: '$progressInt%',
                          badgeColor:
                              progress >= 1.0 ? KuroTheme.cyan : KuroTheme.crimson,
                          title: title.toString().toUpperCase(),
                          timeAgo: 'Sincronizado',
                          chapter: chapter,
                          sub: '$tomo // Pág. ${item['currentPage'] ?? 1} de ${item['totalPages'] ?? 1}',
                          progress: progress,
                          progressText: '$progressInt% completado',
                          extraText: progress >= 1.0 ? 'Releer' : 'Continuar',
                          imgUrl: imgUrl,
                        ),
                      );
                    }).toList(),
                  );
                },
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
                child: imgUrl.isNotEmpty
                    ? Image.network(
                        imgUrl,
                        width: 48,
                        height: 62,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          width: 48,
                          height: 62,
                          color: KuroTheme.cardLighter,
                          child: const Icon(Icons.menu_book, color: KuroTheme.textMuted, size: 20),
                        ),
                      )
                    : Container(
                        width: 48,
                        height: 62,
                        color: KuroTheme.cardLighter,
                        child: const Icon(Icons.menu_book, color: KuroTheme.textMuted, size: 20),
                      ),
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
