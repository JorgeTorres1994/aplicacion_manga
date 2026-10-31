import 'dart:io';
import 'package:aplicacion_manga/Screens/admin/admin_moderation_screen.dart';
import 'package:aplicacion_manga/Screens/admin/admin_upload_screen.dart';
import 'package:aplicacion_manga/Screens/admin_pagina_principal.dart';
import 'package:aplicacion_manga/Screens/login_page.dart';
import 'package:aplicacion_manga/inner_screens/OnlineViewScreen.dart';
import 'package:aplicacion_manga/services/admin_service.dart';
import 'package:aplicacion_manga/theme/kuro_theme.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';

class KuroAdminOverviewScreen extends StatefulWidget {
  const KuroAdminOverviewScreen({Key? key}) : super(key: key);

  @override
  State<KuroAdminOverviewScreen> createState() =>
      _KuroAdminOverviewScreenState();
}

class _KuroAdminOverviewScreenState extends State<KuroAdminOverviewScreen> {
  int _selectedNav = 0; // 0: DASHBOARD, 1: PUBLICAR, 2: CATÁLOGO, 3: SEGURIDAD, 4: PERFIL

  // Manga y Tomo preseleccionados al saltar a PUBLICAR
  String? _targetUploadMangaId;
  String? _targetUploadMangaTitle;
  String? _targetUploadTomo;

  // Catálogo search and filter
  String _catalogFilter = 'TODAS';
  final TextEditingController _searchController = TextEditingController();

  // Admin Profile state & controllers (cargados dinámicamente de Firebase Auth/Firestore)
  final TextEditingController _adminNameCtrl = TextEditingController();
  final TextEditingController _adminEmailCtrl = TextEditingController();
  final TextEditingController _adminPhoneCtrl = TextEditingController();
  final TextEditingController _adminBioCtrl = TextEditingController();
  String _adminAvatar = '';
  bool _isSavingProfile = false;

  // Catálogo dinámico cargado de Firestore collection('mangas')
  List<Map<String, dynamic>> _catalogMangas = [];
  bool _isLoadingCatalog = true;

  // Dashboard dynamic metrics from Backend
  String _readersCount = '0';
  String _catalogCount = '0';
  String _forumReports = '00';

  @override
  void initState() {
    super.initState();
    _cargarDatosAdmin();
    _cargarMetricas();
    _cargarCatalogo();
  }

  void _cargarCatalogo() async {
    setState(() => _isLoadingCatalog = true);
    final list = await KuroAdminBackendService.instance.fetchCatalog();
    if (mounted) {
      setState(() {
        _catalogMangas = list;
        _isLoadingCatalog = false;
        _catalogCount = list.length.toString();
      });
    }
  }

  void _cargarMetricas() async {
    final metrics = await KuroAdminBackendService.instance.getDashboardMetrics();
    if (mounted) {
      setState(() {
        _readersCount = metrics['readersCount'] ?? _readersCount;
        _catalogCount = metrics['catalogCount'] ?? _catalogCount;
        _forumReports = metrics['forumReports'] ?? _forumReports;
      });
    }
  }

  void _cargarDatosAdmin() async {
    try {
      if (Firebase.apps.isNotEmpty) {
        final user = FirebaseAuth.instance.currentUser;
        if (user != null) {
          if (mounted) {
            setState(() {
              _adminEmailCtrl.text = user.email ?? '';
              _adminNameCtrl.text = user.displayName ?? (user.email?.split('@').first ?? 'Administrador');
              if (user.photoURL != null && user.photoURL!.isNotEmpty) {
                _adminAvatar = user.photoURL!;
              }
            });
          }
          final profile = await KuroAdminBackendService.instance.loadAdminProfile(user.uid);
          if (profile != null && mounted) {
            setState(() {
              if (profile['usuario'] != null && profile['usuario'].toString().isNotEmpty) {
                _adminNameCtrl.text = profile['usuario'];
              }
              final phone = profile['celular'] ?? profile['telefono'];
              if (phone != null && phone.toString().isNotEmpty) {
                _adminPhoneCtrl.text = phone.toString();
              }
              final emailVal = profile['correo'] ?? profile['email'];
              if (emailVal != null && emailVal.toString().isNotEmpty) {
                _adminEmailCtrl.text = emailVal.toString();
              }
              if (profile['bio'] != null) {
                _adminBioCtrl.text = profile['bio'];
              }
              if (profile['avatar'] != null && profile['avatar'].toString().isNotEmpty) {
                _adminAvatar = profile['avatar'];
              }
            });
          }
        }
      }
    } catch (_) {}
  }

  Widget _buildMangaCover(String? imageUrl, {double width = 50, double height = 70}) {
    if (imageUrl != null && imageUrl.isNotEmpty && imageUrl.startsWith('http')) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(6),
        child: Image.network(
          imageUrl,
          width: width,
          height: height,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => _buildCoverFallback(width, height),
        ),
      );
    }
    return _buildCoverFallback(width, height);
  }

  Widget _buildCoverFallback(double width, double height) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: KuroTheme.cardLighter,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: KuroTheme.border),
      ),
      child: Center(
        child: Icon(Icons.menu_book, color: KuroTheme.cyan.withValues(alpha: 0.7), size: width * 0.45),
      ),
    );
  }

  Future<void> _guardarPerfilAdmin() async {
    setState(() => _isSavingProfile = true);
    try {
      if (Firebase.apps.isNotEmpty) {
        final user = FirebaseAuth.instance.currentUser;
        if (user != null) {
          await KuroAdminBackendService.instance.saveAdminProfile(
            uid: user.uid,
            name: _adminNameCtrl.text.trim(),
            phone: _adminPhoneCtrl.text.trim(),
            bio: _adminBioCtrl.text.trim(),
            avatar: _adminAvatar,
            email: user.email ?? _adminEmailCtrl.text.trim(),
          );
        }
      }

      setState(() => _isSavingProfile = false);
      Fluttertoast.showToast(
        msg: 'Perfil guardado y sincronizado en Firestore correctamente',
        backgroundColor: KuroTheme.cyan,
      );
    } catch (e) {
      setState(() => _isSavingProfile = false);
      Fluttertoast.showToast(
        msg: 'Cambios guardados localmente ($e)',
        backgroundColor: KuroTheme.purple,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: KuroTheme.background,
      body: SafeArea(
        child: Column(
          children: [
            // Pestaña principal activa
            Expanded(
              child: IndexedStack(
                index: _selectedNav,
                children: [
                  _buildDashboardScreen(),
                  KuroAdminUploadScreen(
                    key: ValueKey('$_targetUploadMangaId-$_targetUploadTomo'),
                    isEmbedded: true,
                    initialMangaId: _targetUploadMangaId,
                    initialMangaTitle: _targetUploadMangaTitle,
                    initialTomo: _targetUploadTomo,
                    onBack: () => setState(() => _selectedNav = 0),
                    onPublished: () {
                      setState(() {
                        _selectedNav = 2;
                        _targetUploadMangaId = null;
                        _targetUploadMangaTitle = null;
                        _targetUploadTomo = null;
                      });
                      _cargarCatalogo();
                    },
                  ),
                  _buildCatalogScreen(),
                  KuroAdminModerationScreen(
                    isEmbedded: true,
                    onBack: () => setState(() => _selectedNav = 0),
                  ),
                  _buildProfileScreen(),
                ],
              ),
            ),

            // Persistent Bottom Navigation Bar con los 5 módulos:
            // DASHBOARD | PUBLICAR | CATÁLOGO | SEGURIDAD | PERFIL
            Container(
              height: 58,
              decoration: const BoxDecoration(
                color: KuroTheme.backgroundSecondary,
                border: Border(top: BorderSide(color: KuroTheme.border)),
              ),
              child: Row(
                children: [
                  _buildAdminNavItem(Icons.dashboard_outlined, 'DASHBOARD', 0),
                  _buildAdminNavItem(Icons.cloud_upload_outlined, 'PUBLICAR', 1),
                  _buildAdminNavItem(Icons.auto_stories_outlined, 'CATÁLOGO', 2),
                  _buildAdminNavItem(Icons.security, 'SEGURIDAD', 3),
                  _buildAdminNavItem(Icons.person_outline, 'PERFIL', 4),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==========================================
  // ITEM DE LA BARRA DE NAVEGACIÓN
  // ==========================================
  Widget _buildAdminNavItem(IconData icon, String label, int index) {
    final isSelected = _selectedNav == index;
    return Expanded(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          setState(() => _selectedNav = index);
        },
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isSelected ? KuroTheme.crimson : KuroTheme.textMuted,
              size: 20,
            ),
            const SizedBox(height: 3),
            Text(
              label,
              style: KuroTheme.mono(
                fontSize: 8,
                color: isSelected ? KuroTheme.crimson : KuroTheme.textMuted,
                fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==========================================
  // MODULO 0: DASHBOARD (PANEL PRINCIPAL & METRICAS)
  // ==========================================
  Widget _buildDashboardScreen() {
    return Column(
      children: [
        // Top App Bar del Dashboard
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.exit_to_app, color: Colors.white, size: 20),
                onPressed: () => _showExitOrSwitchDialog(context),
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 6,
                          height: 6,
                          decoration: const BoxDecoration(
                              color: KuroTheme.cyan, shape: BoxShape.circle),
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text('ADMIN DASHBOARD',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: KuroTheme.mono(
                                  fontSize: 9,
                                  color: KuroTheme.textGrey,
                                  fontWeight: FontWeight.w700)),
                        ),
                      ],
                    ),
                    Text('Overview...',
                        style: GoogleFonts.spaceGrotesk(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: Colors.white)),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: KuroTheme.purple.withValues(alpha: 0.25),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: KuroTheme.purple),
                ),
                child: Row(
                  children: [
                    Container(
                        width: 5,
                        height: 5,
                        decoration: const BoxDecoration(
                            color: KuroTheme.crimson, shape: BoxShape.circle)),
                    const SizedBox(width: 6),
                    Text('ROOT ADMIN // レベル9',
                        style: KuroTheme.mono(
                            fontSize: 8.5,
                            color: Colors.white,
                            fontWeight: FontWeight.w700)),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              GestureDetector(
                onTap: () => setState(() => _selectedNav = 4), // Ir al Perfil
                child: Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: KuroTheme.crimson, width: 1.5),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: _adminAvatar.isNotEmpty && _adminAvatar.startsWith('http')
                        ? Image.network(
                            _adminAvatar,
                            fit: BoxFit.cover,
                            errorBuilder: (c, e, s) => Container(
                              color: const Color(0xFFF7728B),
                              child: const Icon(Icons.person, color: Colors.black, size: 20),
                            ),
                          )
                        : (_adminAvatar.isNotEmpty
                            ? Image.asset(
                                _adminAvatar,
                                fit: BoxFit.cover,
                                errorBuilder: (c, e, s) => Container(
                                  color: const Color(0xFFF7728B),
                                  child: const Icon(Icons.person, color: Colors.black, size: 20),
                                ),
                              )
                            : Container(
                                color: const Color(0xFFF7728B),
                                child: const Icon(Icons.person, color: Colors.black, size: 20),
                              )),
                  ),
                ),
              ),
            ],
          ),
        ),

        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top banner: Kuro Suite v3.4 + MODO LECTOR button
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: KuroTheme.cardDecoration(
                    color: KuroTheme.card,
                    borderColor: KuroTheme.border,
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: KuroTheme.cardLighter,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.security,
                            color: KuroTheme.crimson, size: 20),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Row(
                                children: [
                                  Text('Kuro Suite',
                                      style: GoogleFonts.spaceGrotesk(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w800,
                                          color: Colors.white)),
                                  const SizedBox(width: 6),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 5, vertical: 1),
                                    decoration: BoxDecoration(
                                        color: KuroTheme.purple,
                                        borderRadius: BorderRadius.circular(3)),
                                    child: Text('v3.4',
                                        style: KuroTheme.mono(
                                            fontSize: 8, color: Colors.white)),
                                  ),
                                ],
                              ),
                            ),
                            Row(
                              children: [
                                Container(
                                    width: 5,
                                    height: 5,
                                    decoration: const BoxDecoration(
                                        color: KuroTheme.cyan,
                                        shape: BoxShape.circle)),
                                const SizedBox(width: 5),
                                Expanded(
                                  child: Text('Sesión Root • Tokyo Node',
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: KuroTheme.mono(
                                          fontSize: 8.5,
                                          color: KuroTheme.textMuted)),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                  builder: (c) =>
                                      const AdminPaginaPrincipal()));
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: KuroTheme.cyan.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(
                                color: KuroTheme.cyan.withValues(alpha: 0.4)),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.chrome_reader_mode,
                                  color: KuroTheme.cyan, size: 12),
                              const SizedBox(width: 4),
                              Text('MODO LECTOR',
                                  style: KuroTheme.mono(
                                      fontSize: 8.5,
                                      color: KuroTheme.cyan,
                                      fontWeight: FontWeight.w800)),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // Sección 1: Métricas Clave
                Row(
                  children: [
                    Container(width: 4, height: 12, color: KuroTheme.cyan),
                    const SizedBox(width: 6),
                    Text('Métricas Clave', style: KuroTheme.title(fontSize: 16)),
                  ],
                ),
                const SizedBox(height: 12),

                // 2 Cards superiores: Lectores Activos + Catálogo Total
                Row(
                  children: [
                    _buildKpiCard(
                      label: 'LECTORES ACTIVOS',
                      chipText: '+14%',
                      chipBg: KuroTheme.cyan.withValues(alpha: 0.2),
                      chipColor: KuroTheme.cyan,
                      mainNumber: _readersCount,
                      subText: 'Lectura activa en 24h',
                      indicator: SizedBox(
                        height: 24,
                        child: CustomPaint(
                          painter: _CyanAreaChartPainter(),
                          size: const Size(double.infinity, 24),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    _buildKpiCard(
                      label: 'CATÁLOGO TOTAL',
                      chipText: 'SYNC',
                      chipBg: KuroTheme.purple.withValues(alpha: 0.25),
                      chipColor: KuroTheme.purple,
                      mainNumber: _catalogCount,
                      subText: '69% activos • 31% archivados',
                      indicator: ClipRRect(
                        borderRadius: BorderRadius.circular(3),
                        child: Row(
                          children: [
                            Expanded(
                              flex: 69,
                              child: Container(
                                  height: 4, color: KuroTheme.crimson),
                            ),
                            Expanded(
                              flex: 31,
                              child:
                                  Container(height: 4, color: KuroTheme.purple),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // 2 Cards inferiores: Revisiones RAW + Reportes de Foros
                Row(
                  children: [
                    _buildKpiCard(
                      label: 'REVISIONES RAW',
                      chipText: '0 PEND',
                      chipBg: KuroTheme.cyan.withValues(alpha: 0.2),
                      chipColor: KuroTheme.cyan,
                      mainNumber: '0',
                      subText: 'Cola de escaneo al día',
                      indicator: Row(
                        children: [
                          Container(
                              width: 6,
                              height: 6,
                              decoration: const BoxDecoration(
                                  color: KuroTheme.cyan,
                                  shape: BoxShape.circle)),
                          const SizedBox(width: 6),
                          Text('Sin pendientes',
                              style: KuroTheme.mono(
                                  fontSize: 8.5, color: KuroTheme.cyan)),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    _buildKpiCard(
                      label: 'REPORTES FOROS',
                      chipText: 'HOY',
                      chipBg: Colors.white.withValues(alpha: 0.08),
                      chipColor: KuroTheme.textGrey,
                      mainNumber: _forumReports,
                      subText: 'Comentarios reportados',
                      indicator: Row(
                        children: [
                          Container(
                              width: 6,
                              height: 6,
                              decoration: const BoxDecoration(
                                  color: KuroTheme.cyan,
                                  shape: BoxShape.circle)),
                          const SizedBox(width: 6),
                          Text('Sincronizado',
                              style: KuroTheme.mono(
                                  fontSize: 8.5, color: KuroTheme.cyan)),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // Sección 2: Comandos Directos
                Wrap(
                  alignment: WrapAlignment.spaceBetween,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(width: 4, height: 12, color: KuroTheme.crimson),
                        const SizedBox(width: 6),
                        Text('Comandos Directos', style: KuroTheme.title(fontSize: 16)),
                      ],
                    ),
                    TextButton.icon(
                      style: TextButton.styleFrom(
                        backgroundColor: KuroTheme.purple.withValues(alpha: 0.15),
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6),
                          side: const BorderSide(color: KuroTheme.purple),
                        ),
                      ),
                      icon: const Icon(Icons.bolt, color: KuroTheme.purple, size: 14),
                      label: Text(
                        'POBLAR DRAGON BALL SUPER',
                        style: KuroTheme.mono(fontSize: 8, color: Colors.white, fontWeight: FontWeight.w800),
                      ),
                      onPressed: () => _sembrarDragonBallSuper(),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                Row(
                  children: [
                    // Subir Nuevo Tomo (Cambia a pestaña 1 PUBLICAR)
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _selectedNav = 1),
                        child: Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            gradient: KuroTheme.crimsonGradient,
                            borderRadius: BorderRadius.circular(14),
                            boxShadow: [
                              BoxShadow(
                                color: KuroTheme.crimson.withValues(alpha: 0.3),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(6),
                                    decoration: BoxDecoration(
                                        color: Colors.white.withValues(alpha: 0.2),
                                        borderRadius: BorderRadius.circular(8)),
                                    child: const Icon(Icons.cloud_upload,
                                        color: Colors.white, size: 18),
                                  ),
                                  const Icon(Icons.arrow_forward,
                                      color: Colors.white, size: 18),
                                ],
                              ),
                              const SizedBox(height: 14),
                              Text('Subir Nuevo Tomo',
                                  style: GoogleFonts.spaceGrotesk(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w800,
                                      color: Colors.white)),
                              const SizedBox(height: 2),
                              Text('RAWs, scanlation y fichas',
                                  style: KuroTheme.body(
                                      fontSize: 9.5, color: Colors.white70)),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Moderar Foros (Cambia a pestaña 3 SEGURIDAD)
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _selectedNav = 3),
                        child: Container(
                          padding: const EdgeInsets.all(14),
                          decoration: KuroTheme.cardDecoration(),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(6),
                                    decoration: BoxDecoration(
                                        color: KuroTheme.cardLighter,
                                        borderRadius: BorderRadius.circular(8)),
                                    child: const Icon(Icons.security,
                                        color: Colors.white, size: 18),
                                  ),
                                  const Icon(Icons.arrow_forward,
                                      color: KuroTheme.textGrey, size: 18),
                                ],
                              ),
                              const SizedBox(height: 14),
                              Text('Moderar Foros',
                                  style: GoogleFonts.spaceGrotesk(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w800,
                                      color: Colors.white)),
                              const SizedBox(height: 2),
                              Text('$_forumReports reportes en espera',
                                  style: KuroTheme.body(
                                      fontSize: 9.5,
                                      color: KuroTheme.textMuted)),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Botón horizontal: Gestión de Catálogo y Biblioteca
                GestureDetector(
                  onTap: () => setState(() => _selectedNav = 2),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: KuroTheme.cardDecoration(),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                              color: KuroTheme.purple.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(8)),
                          child: const Icon(Icons.auto_stories,
                              color: KuroTheme.purple, size: 18),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Gestión del Catálogo Global',
                                  style: GoogleFonts.spaceGrotesk(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.white)),
                              Text('$_catalogCount series sincronizadas con Firebase',
                                  style: KuroTheme.body(
                                      fontSize: 9.5, color: KuroTheme.textMuted)),
                            ],
                          ),
                        ),
                        const Icon(Icons.arrow_forward_ios,
                            color: KuroTheme.textMuted, size: 14),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // Sección 3: Última Serie en Firebase / Cola Prioritaria
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          Container(width: 4, height: 12, color: KuroTheme.purple),
                          const SizedBox(width: 6),
                          Flexible(
                            child: Text('Última Serie en Firebase',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: KuroTheme.title(fontSize: 16)),
                          ),
                        ],
                      ),
                    ),
                    GestureDetector(
                      onTap: () => setState(() => _selectedNav = 2),
                      child: Text('VER CATÁLOGO (${_catalogMangas.length})',
                          style: KuroTheme.mono(
                              fontSize: 9,
                              color: KuroTheme.cyan,
                              fontWeight: FontWeight.w700)),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                if (_catalogMangas.isNotEmpty) ...[
                  Builder(
                    builder: (ctx) {
                      final latestManga = _catalogMangas.first;
                      return Container(
                        padding: const EdgeInsets.all(14),
                        decoration: KuroTheme.cardDecoration(),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                    width: 6,
                                    height: 6,
                                    decoration: const BoxDecoration(
                                        color: KuroTheme.cyan,
                                        shape: BoxShape.circle)),
                                const SizedBox(width: 6),
                                Text('SERIE ACTIVA // FIRESTORE',
                                    style: KuroTheme.mono(
                                        fontSize: 8.5, color: KuroTheme.cyan)),
                                const Spacer(),
                                Text(latestManga['status'] ?? 'EN EMISIÓN',
                                    style: KuroTheme.mono(
                                        fontSize: 8.5, color: KuroTheme.textMuted)),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Row(
                              children: [
                                _buildMangaCover(latestManga['imageUrl'], width: 48, height: 64),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(latestManga['title'] ?? 'Sin título',
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: GoogleFonts.spaceGrotesk(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w800,
                                              color: Colors.white)),
                                      Text(
                                          '${latestManga['category']} • ${latestManga['chapters']}',
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: KuroTheme.body(
                                              fontSize: 10, color: KuroTheme.textGrey)),
                                      const SizedBox(height: 6),
                                      Row(
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 5, vertical: 1.5),
                                            decoration: BoxDecoration(
                                                color: KuroTheme.purple
                                                    .withValues(alpha: 0.3),
                                                borderRadius:
                                                    BorderRadius.circular(3)),
                                            child: Text('FIREBASE SYNC',
                                                style: KuroTheme.mono(
                                                    fontSize: 7.5,
                                                    color: Colors.white,
                                                    fontWeight: FontWeight.w700)),
                                          ),
                                          const SizedBox(width: 6),
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 5, vertical: 1.5),
                                            decoration: BoxDecoration(
                                                color: KuroTheme.cyan
                                                    .withValues(alpha: 0.2),
                                                borderRadius:
                                                    BorderRadius.circular(3)),
                                            child: Text(latestManga['author'] ?? 'Admin',
                                                style: KuroTheme.mono(
                                                    fontSize: 7.5,
                                                    color: KuroTheme.cyan,
                                                    fontWeight: FontWeight.w700)),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Expanded(
                                  child: GestureDetector(
                                    onTap: () => _showMangaDetailsSheet(latestManga),
                                    child: Container(
                                      height: 38,
                                      decoration: BoxDecoration(
                                          color: KuroTheme.cyan.withValues(alpha: 0.15),
                                          borderRadius: BorderRadius.circular(8),
                                          border: Border.all(color: KuroTheme.cyan.withValues(alpha: 0.4))),
                                      child: Center(
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            const Icon(Icons.visibility_outlined,
                                                color: KuroTheme.cyan, size: 14),
                                            const SizedBox(width: 6),
                                            Text('Ver Ficha Completa',
                                                style: KuroTheme.mono(
                                                    fontSize: 9.5,
                                                    color: KuroTheme.cyan,
                                                    fontWeight: FontWeight.w700)),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: GestureDetector(
                                    onTap: () => setState(() => _selectedNav = 1),
                                    child: Container(
                                      height: 38,
                                      decoration: BoxDecoration(
                                          color: KuroTheme.crimson,
                                          borderRadius: BorderRadius.circular(8)),
                                      child: Center(
                                        child: Text('+ Subir Capítulo',
                                            style: KuroTheme.mono(
                                                fontSize: 9.5,
                                                color: Colors.white,
                                                fontWeight: FontWeight.w800)),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ] else ...[
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: KuroTheme.cardDecoration(),
                    child: Column(
                      children: [
                        const Icon(Icons.check_circle_outline, color: KuroTheme.cyan, size: 36),
                        const SizedBox(height: 10),
                        Text('COLA AL DÍA // SIN PENDIENTES',
                            style: GoogleFonts.spaceGrotesk(
                                fontSize: 13,
                                fontWeight: FontWeight.w800,
                                color: Colors.white)),
                        const SizedBox(height: 4),
                        Text(
                          'No hay mangas o capítulos pendientes en Firestore.',
                          textAlign: TextAlign.center,
                          style: KuroTheme.body(fontSize: 10, color: KuroTheme.textMuted),
                        ),
                        const SizedBox(height: 14),
                        GestureDetector(
                          onTap: () => setState(() => _selectedNav = 1),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              color: KuroTheme.crimson,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text('+ PUBLICAR PRIMER MANGA',
                                style: KuroTheme.mono(
                                    fontSize: 9.5,
                                    color: Colors.white,
                                    fontWeight: FontWeight.w800)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                const SizedBox(height: 20),

                // Plataforma 100% Operativa
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          Container(
                              width: 6,
                              height: 6,
                              decoration: const BoxDecoration(
                                  color: KuroTheme.cyan, shape: BoxShape.circle)),
                          const SizedBox(width: 6),
                          Flexible(
                            child: Text('Plataforma 100% Operativa',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: KuroTheme.mono(
                                    fontSize: 9, color: KuroTheme.textGrey)),
                          ),
                        ],
                      ),
                    ),
                    Text('Sincronizado: 1m',
                        style: KuroTheme.mono(
                            fontSize: 9, color: KuroTheme.textMuted)),
                  ],
                ),

                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ==========================================
  // MODULO 2: CATÁLOGO & BIBLIOTECA ROOT
  // ==========================================
  Widget _buildCatalogScreen() {
    final filtered = _catalogMangas.where((m) {
      if (_catalogFilter == 'EN EMISIÓN' && m['status'] != 'EN EMISIÓN') return false;
      if (_catalogFilter == 'PAUSADO' && m['status'] != 'PAUSADO') return false;
      if (_catalogFilter == 'FINALIZADO' && m['status'] != 'FINALIZADO') return false;
      if (_searchController.text.isNotEmpty) {
        final query = _searchController.text.toLowerCase();
        final title = (m['title'] as String).toLowerCase();
        final author = (m['author'] as String).toLowerCase();
        if (!title.contains(query) && !author.contains(query)) return false;
      }
      return true;
    }).toList();

    return Column(
      children: [
        // AppBar Catálogo
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white, size: 20),
                onPressed: () => setState(() => _selectedNav = 0),
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('KURO ADMIN // CATALOG-01',
                        style: KuroTheme.mono(
                            fontSize: 8.5,
                            color: KuroTheme.cyan,
                            fontWeight: FontWeight.w700)),
                    Text('CATÁLOGO GLOBAL',
                        style: GoogleFonts.spaceGrotesk(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: Colors.white)),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.refresh, color: KuroTheme.cyan, size: 18),
                onPressed: _cargarCatalogo,
              ),
              const SizedBox(width: 4),
              GestureDetector(
                onTap: _showAddMangaDialog,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: KuroTheme.crimson,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.add, color: Colors.white, size: 14),
                      const SizedBox(width: 4),
                      Text('NUEVA SERIE',
                          style: KuroTheme.mono(
                              fontSize: 9,
                              color: Colors.white,
                              fontWeight: FontWeight.w800)),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),

        // Buscador y Filtros
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: [
              Container(
                height: 40,
                decoration: BoxDecoration(
                  color: KuroTheme.card,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: KuroTheme.border),
                ),
                child: TextField(
                  controller: _searchController,
                  onChanged: (_) => setState(() {}),
                  style: KuroTheme.mono(fontSize: 11, color: Colors.white),
                  decoration: InputDecoration(
                    hintText: 'Buscar por manga, autor o categoría...',
                    hintStyle: KuroTheme.mono(fontSize: 10, color: KuroTheme.textMuted),
                    prefixIcon: const Icon(Icons.search, color: KuroTheme.textMuted, size: 18),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(vertical: 10),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: ['TODAS', 'EN EMISIÓN', 'PAUSADO', 'FINALIZADO']
                      .map((filter) {
                    final isSel = _catalogFilter == filter;
                    return GestureDetector(
                      onTap: () => setState(() => _catalogFilter = filter),
                      child: Container(
                        margin: const EdgeInsets.only(right: 8),
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: isSel ? KuroTheme.purple : KuroTheme.cardLighter,
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                              color: isSel ? KuroTheme.purple : KuroTheme.border),
                        ),
                        child: Text(filter,
                            style: KuroTheme.mono(
                                fontSize: 8.5,
                                color: isSel ? Colors.white : KuroTheme.textGrey,
                                fontWeight: FontWeight.w700)),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 14),

        // Lista Dinámica de Mangas de Firebase o Estado Vacío
        if (_isLoadingCatalog)
          const Expanded(
            child: Center(
              child: CircularProgressIndicator(color: KuroTheme.cyan),
            ),
          )
        else if (filtered.isEmpty)
          Expanded(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        color: KuroTheme.cyan.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                        border: Border.all(color: KuroTheme.cyan.withValues(alpha: 0.3)),
                      ),
                      child: const Icon(Icons.auto_stories_outlined, color: KuroTheme.cyan, size: 32),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      _catalogMangas.isEmpty ? 'CATÁLOGO VACÍO EN FIREBASE' : 'SIN RESULTADOS DE BÚSQUEDA',
                      style: GoogleFonts.spaceGrotesk(fontSize: 14, fontWeight: FontWeight.w800, color: Colors.white),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      _catalogMangas.isEmpty
                          ? 'No se encontraron mangas en la colección "mangas" de Firestore.'
                          : 'No se encontraron mangas con los filtros o término de búsqueda ingresado.',
                      textAlign: TextAlign.center,
                      style: KuroTheme.body(fontSize: 10, color: KuroTheme.textMuted),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: KuroTheme.crimson,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      onPressed: _showAddMangaDialog,
                      child: Text('+ REGISTRAR MANGA EN FIREBASE',
                          style: KuroTheme.mono(fontSize: 9.5, color: Colors.white, fontWeight: FontWeight.w800)),
                    ),
                  ],
                ),
              ),
            ),
          )
        else
          Expanded(
            child: RefreshIndicator(
              color: KuroTheme.cyan,
              backgroundColor: KuroTheme.card,
              onRefresh: () async => _cargarCatalogo(),
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
                itemCount: filtered.length,
                itemBuilder: (ctx, index) {
                  final manga = filtered[index];
                  final statusColor = (manga['statusColor'] is Color)
                      ? manga['statusColor'] as Color
                      : (manga['status'] == 'FINALIZADO'
                          ? KuroTheme.purple
                          : (manga['status'] == 'PAUSADO' ? KuroTheme.crimson : KuroTheme.cyan));

                  return GestureDetector(
                    onTap: () => _showMangaDetailsSheet(manga),
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(12),
                      decoration: KuroTheme.cardDecoration(),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildMangaCover(manga['imageUrl'] ?? manga['image']),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Text(manga['title'] ?? 'Sin título',
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: GoogleFonts.spaceGrotesk(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w800,
                                              color: Colors.white)),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: statusColor.withValues(alpha: 0.2),
                                        borderRadius: BorderRadius.circular(4),
                                        border: Border.all(color: statusColor),
                                      ),
                                      child: Text(manga['status'] ?? 'EN EMISIÓN',
                                          style: KuroTheme.mono(
                                              fontSize: 7.5,
                                              color: statusColor,
                                              fontWeight: FontWeight.w800)),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 2),
                                Text('${manga['author'] ?? 'Autor'} • ${manga['category'] ?? 'General'}',
                                    style: KuroTheme.body(
                                        fontSize: 10, color: KuroTheme.textGrey)),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    Text('${manga['chapters'] ?? '1 Tomo'}',
                                        style: KuroTheme.mono(
                                            fontSize: 9, color: KuroTheme.cyan)),
                                    const SizedBox(width: 8),
                                    Text('•  ${manga['views'] ?? '0'} lecturas',
                                        style: KuroTheme.mono(
                                            fontSize: 9, color: KuroTheme.textMuted)),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    GestureDetector(
                                      onTap: () => _showMangaDetailsSheet(manga),
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 8, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: KuroTheme.cyan.withValues(alpha: 0.15),
                                          borderRadius: BorderRadius.circular(4),
                                          border: Border.all(
                                              color: KuroTheme.cyan.withValues(alpha: 0.4)),
                                        ),
                                        child: Row(
                                          children: [
                                            const Icon(Icons.visibility_outlined,
                                                color: KuroTheme.cyan, size: 10),
                                            const SizedBox(width: 3),
                                            Text('INFO',
                                                style: KuroTheme.mono(
                                                    fontSize: 8,
                                                    color: KuroTheme.cyan,
                                                    fontWeight: FontWeight.w800)),
                                          ],
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    GestureDetector(
                                      onTap: () => _editMangaSheet(manga),
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 8, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: KuroTheme.cardLighter,
                                          borderRadius: BorderRadius.circular(4),
                                        ),
                                        child: Text('ESTADO',
                                            style: KuroTheme.mono(
                                                fontSize: 8, color: Colors.white)),
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    GestureDetector(
                                      onTap: () => setState(() => _selectedNav = 1),
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 8, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: KuroTheme.crimson.withValues(alpha: 0.2),
                                          borderRadius: BorderRadius.circular(4),
                                          border: Border.all(
                                              color: KuroTheme.crimson.withValues(alpha: 0.5)),
                                        ),
                                        child: Text('+ CAP',
                                            style: KuroTheme.mono(
                                                fontSize: 8,
                                                color: KuroTheme.crimson,
                                                fontWeight: FontWeight.w800)),
                                      ),
                                    ),
                                    const Spacer(),
                                    IconButton(
                                      constraints: const BoxConstraints(),
                                      padding: EdgeInsets.zero,
                                      icon: const Icon(Icons.more_vert,
                                          color: KuroTheme.textMuted, size: 18),
                                      onPressed: () => _showMangaOptions(manga),
                                    ),
                                  ],
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
            ),
          ),
      ],
    );
  }

  // ==========================================
  // MODULO 4: PERFIL DEL ADMINISTRADOR
  // ==========================================
  Widget _buildProfileScreen() {
    return Column(
      children: [
        // Top App Bar de Perfil
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white, size: 20),
                onPressed: () => setState(() => _selectedNav = 0),
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('KURO ADMIN // SEC-ROOT',
                        style: KuroTheme.mono(
                            fontSize: 8.5,
                            color: KuroTheme.cyan,
                            fontWeight: FontWeight.w700)),
                    Text('PERFIL ADMINISTRADOR',
                        style: GoogleFonts.spaceGrotesk(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: Colors.white)),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: KuroTheme.crimson.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: KuroTheme.crimson),
                ),
                child: Text('NIVEL 9 // ROOT',
                    style: KuroTheme.mono(
                        fontSize: 8.5,
                        color: KuroTheme.crimson,
                        fontWeight: FontWeight.w800)),
              ),
            ],
          ),
        ),

        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Tarjeta Principal del Perfil (Avatar + Info + Botón Foto)
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: KuroTheme.cardDecoration(
                    color: KuroTheme.card,
                    borderColor: KuroTheme.border,
                  ),
                  child: Column(
                    children: [
                      // Avatar con botón de edición
                      Center(
                        child: GestureDetector(
                          onTap: _showAvatarPickerSheet,
                          child: Stack(
                            children: [
                              Container(
                                width: 86,
                                height: 86,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(color: KuroTheme.crimson, width: 2.5),
                                  boxShadow: [
                                    BoxShadow(
                                      color: KuroTheme.crimson.withValues(alpha: 0.35),
                                      blurRadius: 14,
                                      spreadRadius: 2,
                                    ),
                                  ],
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(43),
                                  child: _adminAvatar.isNotEmpty && _adminAvatar.startsWith('http')
                                      ? Image.network(
                                          _adminAvatar,
                                          fit: BoxFit.cover,
                                          errorBuilder: (ctx, err, stack) => _buildDefaultAdminAvatar(),
                                        )
                                      : _buildDefaultAdminAvatar(),
                                ),
                              ),
                              Positioned(
                                bottom: 0,
                                right: 0,
                                child: Container(
                                  width: 28,
                                  height: 28,
                                  decoration: BoxDecoration(
                                    color: KuroTheme.cyan,
                                    shape: BoxShape.circle,
                                    border: Border.all(color: Colors.black, width: 2),
                                  ),
                                  child: const Icon(Icons.camera_alt,
                                      color: Colors.black, size: 14),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Nombre y Correo
                      Text(_adminNameCtrl.text.isNotEmpty ? _adminNameCtrl.text : 'Administrador',
                          style: GoogleFonts.spaceGrotesk(
                              fontSize: 18,
                              fontWeight: FontWeight.w900,
                              color: Colors.white)),
                      const SizedBox(height: 2),
                      Text(_adminEmailCtrl.text.isNotEmpty ? _adminEmailCtrl.text : 'root@manga.app',
                          style: KuroTheme.mono(
                              fontSize: 10.5, color: KuroTheme.cyan)),
                      const SizedBox(height: 8),

                      // Badges de Rango
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: KuroTheme.crimson.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(4),
                                border: Border.all(
                                    color: KuroTheme.crimson.withValues(alpha: 0.5)),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                      width: 5,
                                      height: 5,
                                      decoration: const BoxDecoration(
                                          color: KuroTheme.crimson,
                                          shape: BoxShape.circle)),
                                  const SizedBox(width: 4),
                                  Text('ACCESO TOTAL // SUPERADMIN',
                                      style: KuroTheme.mono(
                                          fontSize: 8,
                                          color: KuroTheme.crimson,
                                          fontWeight: FontWeight.w800)),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: KuroTheme.purple.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(4),
                                border: Border.all(
                                    color: KuroTheme.purple.withValues(alpha: 0.5)),
                              ),
                              child: Text('TOKYO NODE #01',
                                  style: KuroTheme.mono(
                                      fontSize: 8,
                                      color: KuroTheme.purple,
                                      fontWeight: FontWeight.w700)),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // Telemetría & Estadísticas Rápidas
                Row(
                  children: [
                    _buildProfileMetricCard('PERMISOS', 'ROOT', KuroTheme.crimson),
                    const SizedBox(width: 8),
                    _buildProfileMetricCard('CATÁLOGO', _catalogCount, KuroTheme.cyan),
                    const SizedBox(width: 8),
                    _buildProfileMetricCard('SESIÓN', 'ACTIVA', Colors.greenAccent),
                  ],
                ),

                const SizedBox(height: 20),

                // Formulario de Edición de Datos
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: KuroTheme.cardDecoration(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.manage_accounts,
                                  color: KuroTheme.cyan, size: 16),
                              const SizedBox(width: 6),
                              Text('DATOS DEL ADMINISTRADOR',
                                  style: KuroTheme.mono(
                                      fontSize: 10,
                                      color: Colors.white,
                                      fontWeight: FontWeight.w800)),
                            ],
                          ),
                          Text('EDITABLE',
                              style: KuroTheme.mono(
                                  fontSize: 8, color: KuroTheme.textMuted)),
                        ],
                      ),
                      const SizedBox(height: 14),

                      // Campo: Nombre de Administrador
                      Text('NOMBRE COMPLETO / ALIAS',
                          style: KuroTheme.mono(
                              fontSize: 8.5, color: KuroTheme.textMuted)),
                      const SizedBox(height: 6),
                      Container(
                        decoration: BoxDecoration(
                          color: KuroTheme.cardLighter,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: KuroTheme.border),
                        ),
                        child: TextField(
                          controller: _adminNameCtrl,
                          style: KuroTheme.mono(fontSize: 12, color: Colors.white),
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            prefixIcon: Icon(Icons.person,
                                color: KuroTheme.textMuted, size: 18),
                            contentPadding: EdgeInsets.symmetric(
                                horizontal: 12, vertical: 12),
                          ),
                        ),
                      ),

                      const SizedBox(height: 12),

                      // Campo: Correo Electrónico
                      Text('CORREO ELECTRÓNICO (FIRESTORE & AUTH)',
                          style: KuroTheme.mono(
                              fontSize: 8.5, color: KuroTheme.textMuted)),
                      const SizedBox(height: 6),
                      Container(
                        decoration: BoxDecoration(
                          color: KuroTheme.cardLighter,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: KuroTheme.border),
                        ),
                        child: TextField(
                          controller: _adminEmailCtrl,
                          readOnly: true,
                          style: KuroTheme.mono(fontSize: 12, color: KuroTheme.cyan),
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            prefixIcon: Icon(Icons.alternate_email,
                                color: KuroTheme.cyan, size: 18),
                            contentPadding: EdgeInsets.symmetric(
                                horizontal: 12, vertical: 12),
                          ),
                        ),
                      ),

                      const SizedBox(height: 12),

                      // Campo: Teléfono de Verificación
                      Text('TELÉFONO DE CONTACTO / 2FA',
                          style: KuroTheme.mono(
                              fontSize: 8.5, color: KuroTheme.textMuted)),
                      const SizedBox(height: 6),
                      Container(
                        decoration: BoxDecoration(
                          color: KuroTheme.cardLighter,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: KuroTheme.border),
                        ),
                        child: TextField(
                          controller: _adminPhoneCtrl,
                          style: KuroTheme.mono(fontSize: 12, color: Colors.white),
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            prefixIcon: Icon(Icons.phone,
                                color: KuroTheme.textMuted, size: 18),
                            contentPadding: EdgeInsets.symmetric(
                                horizontal: 12, vertical: 12),
                          ),
                        ),
                      ),

                      const SizedBox(height: 12),

                      // Campo: Biografía / Estado
                      Text('BIOGRAFÍA / ESTADO OPERATIVO',
                          style: KuroTheme.mono(
                              fontSize: 8.5, color: KuroTheme.textMuted)),
                      const SizedBox(height: 6),
                      Container(
                        decoration: BoxDecoration(
                          color: KuroTheme.cardLighter,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: KuroTheme.border),
                        ),
                        child: TextField(
                          controller: _adminBioCtrl,
                          maxLines: 2,
                          style: KuroTheme.mono(fontSize: 11, color: Colors.white),
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.all(12),
                          ),
                        ),
                      ),

                      const SizedBox(height: 18),

                      // Botón Guardar Cambios
                      KuroTheme.primaryButton(
                        text: 'GUARDAR CAMBIOS EN PERFIL',
                        icon: Icons.save,
                        isLoading: _isSavingProfile,
                        onTap: _guardarPerfilAdmin,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // Acciones de Sesión (Ver como lector / Cerrar sesión)
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: KuroTheme.cardDecoration(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('GESTIÓN DE ENTORNO',
                          style: KuroTheme.mono(
                              fontSize: 9.5,
                              color: KuroTheme.textMuted,
                              fontWeight: FontWeight.w700)),
                      const SizedBox(height: 12),

                      // Alternar a vista lector
                      GestureDetector(
                        onTap: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                                builder: (c) => const AdminPaginaPrincipal()),
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 12),
                          decoration: BoxDecoration(
                            color: KuroTheme.cardLighter,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                                color: KuroTheme.cyan.withValues(alpha: 0.4)),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.chrome_reader_mode,
                                  color: KuroTheme.cyan, size: 18),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Cambiar a Modo Lector',
                                        style: GoogleFonts.spaceGrotesk(
                                            fontSize: 12.5,
                                            fontWeight: FontWeight.w700,
                                            color: Colors.white)),
                                    Text('Explora mangas, biblioteca y comentarios',
                                        style: KuroTheme.body(
                                            fontSize: 9.5,
                                            color: KuroTheme.textMuted)),
                                  ],
                                ),
                              ),
                              const Icon(Icons.arrow_forward_ios,
                                  color: KuroTheme.cyan, size: 12),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 10),

                      // Botón para poblar Dragon Ball Super
                      GestureDetector(
                        onTap: () => _sembrarDragonBallSuper(),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 12),
                          decoration: BoxDecoration(
                            color: KuroTheme.purple.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                                color: KuroTheme.purple.withValues(alpha: 0.6)),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.bolt,
                                  color: KuroTheme.purple, size: 20),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('POBLAR DRAGON BALL SUPER (TOMOS 1 Y 2)',
                                        style: GoogleFonts.spaceGrotesk(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w800,
                                            color: Colors.white)),
                                    Text('Crea Tomo 1 y 2 con sus 15 capítulos canónicos',
                                        style: KuroTheme.mono(
                                            fontSize: 8.5,
                                            color: KuroTheme.purple)),
                                  ],
                                ),
                              ),
                              const Icon(Icons.arrow_forward_ios,
                                  color: KuroTheme.purple, size: 12),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 10),

                      // Cerrar sesión
                      GestureDetector(
                        onTap: () async {
                          await FirebaseAuth.instance.signOut();
                          if (mounted) {
                            Navigator.of(context).pushAndRemoveUntil(
                              MaterialPageRoute(
                                  builder: (c) => const LoginPage()),
                              (route) => false,
                            );
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 12),
                          decoration: BoxDecoration(
                            color: KuroTheme.crimson.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                                color: KuroTheme.crimson.withValues(alpha: 0.4)),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.logout,
                                  color: KuroTheme.crimson, size: 18),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text('Cerrar Sesión de Administrador',
                                    style: GoogleFonts.spaceGrotesk(
                                        fontSize: 12.5,
                                        fontWeight: FontWeight.w700,
                                        color: KuroTheme.crimson)),
                              ),
                              const Icon(Icons.arrow_forward_ios,
                                  color: KuroTheme.crimson, size: 12),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildProfileMetricCard(String label, String value, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        decoration: KuroTheme.cardDecoration(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label,
                style: KuroTheme.mono(
                    fontSize: 7.5,
                    color: KuroTheme.textMuted,
                    fontWeight: FontWeight.w700)),
            const SizedBox(height: 4),
            Text(value,
                style: GoogleFonts.spaceGrotesk(
                    fontSize: 13, fontWeight: FontWeight.w800, color: color)),
          ],
        ),
      ),
    );
  }

  Widget _buildDefaultAdminAvatar() {
    return Container(
      color: KuroTheme.cardLighter,
      child: const Center(
        child: Icon(Icons.shield_outlined, color: KuroTheme.cyan, size: 36),
      ),
    );
  }

  // Selector modal de foto/avatar sincronizado directamente con la colección 'users' de Firestore
  void _showAvatarPickerSheet() {
    final urlCtrl = TextEditingController(text: _adminAvatar);
    final user = FirebaseAuth.instance.currentUser;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: KuroTheme.backgroundSecondary,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        side: BorderSide(color: KuroTheme.border),
      ),
      builder: (ctx) {
        bool isUploading = false;
        String previewAvatar = _adminAvatar;

        return StatefulBuilder(
          builder: (context, setModalState) => Padding(
            padding: EdgeInsets.only(
                bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
                left: 20,
                right: 20,
                top: 20),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(width: 4, height: 14, color: KuroTheme.cyan),
                          const SizedBox(width: 8),
                          Text('FOTO DE PERFIL // COLECCIÓN USERS',
                              style: KuroTheme.mono(
                                  fontSize: 11,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w800)),
                        ],
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, color: KuroTheme.textMuted, size: 20),
                        onPressed: () => Navigator.pop(ctx),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text('La foto se sube a Firebase Storage y se guarda directamente en tu documento de usuario en Firestore.',
                      style: KuroTheme.body(fontSize: 10, color: KuroTheme.textMuted)),
                  const SizedBox(height: 16),

                  // Vista previa del avatar
                  Center(
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Container(
                          width: 84,
                          height: 84,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: KuroTheme.cyan, width: 2.5),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(42),
                            child: previewAvatar.isNotEmpty && previewAvatar.startsWith('http')
                                ? Image.network(
                                    previewAvatar,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) => _buildDefaultAdminAvatar(),
                                  )
                                : _buildDefaultAdminAvatar(),
                          ),
                        ),
                        if (isUploading)
                          Container(
                            width: 84,
                            height: 84,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.black.withValues(alpha: 0.65),
                            ),
                            child: const Center(
                              child: CircularProgressIndicator(
                                  color: KuroTheme.cyan, strokeWidth: 2.5),
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),

                  // Botón 1: Subir desde Galería
                  SizedBox(
                    width: double.infinity,
                    height: 42,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: KuroTheme.purple,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8)),
                      ),
                      icon: const Icon(Icons.photo_library, size: 16, color: Colors.white),
                      label: Text(
                        isUploading ? 'SUBIENDO A STORAGE Y FIRESTORE...' : 'SUBIR FOTO DESDE GALERÍA',
                        style: KuroTheme.mono(
                            fontSize: 9.5, color: Colors.white, fontWeight: FontWeight.w800),
                      ),
                      onPressed: isUploading
                          ? null
                          : () async {
                              try {
                                final picker = ImagePicker();
                                final picked = await picker.pickImage(
                                  source: ImageSource.gallery,
                                  imageQuality: 85,
                                );
                                if (picked == null) return;

                                setModalState(() => isUploading = true);
                                final file = File(picked.path);

                                final uid = user?.uid ?? 'admin_default';
                                final newUrl = await KuroAdminBackendService.instance
                                    .uploadAndSaveAdminAvatar(
                                  uid: uid,
                                  imageFile: file,
                                );

                                if (newUrl != null && newUrl.isNotEmpty) {
                                  setState(() => _adminAvatar = newUrl);
                                  setModalState(() {
                                    previewAvatar = newUrl;
                                    isUploading = false;
                                  });
                                  if (ctx.mounted) Navigator.pop(ctx);
                                  Fluttertoast.showToast(
                                    msg: '¡Foto de perfil guardada en la colección users!',
                                    backgroundColor: KuroTheme.cyan,
                                  );
                                } else {
                                  setModalState(() => isUploading = false);
                                  Fluttertoast.showToast(
                                    msg: 'Error al subir imagen a Firebase',
                                    backgroundColor: KuroTheme.crimson,
                                  );
                                }
                              } catch (e) {
                                setModalState(() => isUploading = false);
                                Fluttertoast.showToast(
                                  msg: 'Error al seleccionar foto: $e',
                                  backgroundColor: KuroTheme.crimson,
                                );
                              }
                            },
                    ),
                  ),

                  const SizedBox(height: 14),

                  // Separador
                  Row(
                    children: [
                      const Expanded(child: Divider(color: KuroTheme.border)),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        child: Text('O INGRESA URL DIRECTA',
                            style: KuroTheme.mono(fontSize: 8, color: KuroTheme.textMuted)),
                      ),
                      const Expanded(child: Divider(color: KuroTheme.border)),
                    ],
                  ),
                  const SizedBox(height: 14),

                  TextField(
                    controller: urlCtrl,
                    style: KuroTheme.mono(fontSize: 11, color: Colors.white),
                    decoration: InputDecoration(
                      labelText: 'URL de la Imagen (HTTPS)',
                      hintText: 'https://ejemplo.com/avatar.jpg',
                      labelStyle: KuroTheme.mono(fontSize: 10, color: KuroTheme.textMuted),
                      hintStyle: KuroTheme.mono(fontSize: 9.5, color: KuroTheme.textMuted),
                      filled: true,
                      fillColor: KuroTheme.card,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                  const SizedBox(height: 14),

                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: KuroTheme.cyan,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8)),
                          ),
                          onPressed: () async {
                            final rawUrl = urlCtrl.text.trim();
                            if (user != null) {
                              await KuroAdminBackendService.instance.saveAdminAvatarUrl(
                                uid: user.uid,
                                avatarUrl: rawUrl,
                              );
                            }
                            setState(() => _adminAvatar = rawUrl);
                            if (ctx.mounted) Navigator.pop(ctx);
                            Fluttertoast.showToast(
                                msg: 'Foto de perfil guardada en users',
                                backgroundColor: KuroTheme.cyan);
                          },
                          child: Text('GUARDAR URL EN USERS',
                              style: KuroTheme.mono(
                                  fontSize: 9.5,
                                  color: Colors.black,
                                  fontWeight: FontWeight.w800)),
                        ),
                      ),
                      if (_adminAvatar.isNotEmpty) ...[
                        const SizedBox(width: 10),
                        Expanded(
                          child: OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: KuroTheme.crimson),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8)),
                            ),
                            onPressed: () async {
                              if (user != null) {
                                await KuroAdminBackendService.instance.saveAdminAvatarUrl(
                                  uid: user.uid,
                                  avatarUrl: '',
                                );
                              }
                              setState(() => _adminAvatar = '');
                              if (ctx.mounted) Navigator.pop(ctx);
                              Fluttertoast.showToast(
                                  msg: 'Foto de perfil removida de users',
                                  backgroundColor: KuroTheme.crimson);
                            },
                            child: Text('REMOVER FOTO',
                                style: KuroTheme.mono(
                                    fontSize: 9.5,
                                    color: KuroTheme.crimson,
                                    fontWeight: FontWeight.w700)),
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // ==========================================
  // MODALES & ACCIONES GENERALES
  // ==========================================
  Widget _buildKpiCard({
    required String label,
    required String chipText,
    required Color chipBg,
    required Color chipColor,
    required String mainNumber,
    required String subText,
    required Widget indicator,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: KuroTheme.cardDecoration(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: KuroTheme.mono(
                          fontSize: 8.5,
                          color: KuroTheme.textMuted,
                          fontWeight: FontWeight.w700)),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                  decoration: BoxDecoration(
                      color: chipBg, borderRadius: BorderRadius.circular(4)),
                  child: Text(chipText,
                      style: KuroTheme.mono(
                          fontSize: 7.5,
                          color: chipColor,
                          fontWeight: FontWeight.w800)),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(mainNumber,
                style: GoogleFonts.spaceGrotesk(
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                    color: Colors.white)),
            Text(subText,
                style:
                    KuroTheme.body(fontSize: 9.5, color: KuroTheme.textGrey)),
            const SizedBox(height: 8),
            indicator,
          ],
        ),
      ),
    );
  }

  void _showExitOrSwitchDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: KuroTheme.backgroundSecondary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: KuroTheme.border),
        ),
        title: Row(
          children: [
            const Icon(Icons.shield_outlined, color: KuroTheme.crimson, size: 22),
            const SizedBox(width: 8),
            Text('SESIÓN DE ADMINISTRADOR',
                style: KuroTheme.mono(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: Colors.white)),
          ],
        ),
        content: Text(
          '¿Deseas cambiar a la vista de lector para explorar mangas o cerrar sesión en Kuro?',
          style: KuroTheme.body(fontSize: 12, color: KuroTheme.textGrey),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                    builder: (c) => const AdminPaginaPrincipal()),
              );
            },
            child: Text('VER COMO LECTOR',
                style: KuroTheme.mono(
                    fontSize: 11,
                    color: KuroTheme.cyan,
                    fontWeight: FontWeight.w700)),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await FirebaseAuth.instance.signOut();
              if (context.mounted) {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (c) => const LoginPage()),
                  (route) => false,
                );
              }
            },
            child: Text('CERRAR SESIÓN',
                style: KuroTheme.mono(
                    fontSize: 11,
                    color: KuroTheme.crimson,
                    fontWeight: FontWeight.w700)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('CANCELAR',
                style: KuroTheme.mono(fontSize: 11, color: KuroTheme.textMuted)),
          ),
        ],
      ),
    );
  }

  void _showAddMangaDialog() {
    final titleCtrl = TextEditingController();
    final authorCtrl = TextEditingController();
    final catCtrl = TextEditingController(text: 'Seinen');
    final imageCtrl = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: KuroTheme.backgroundSecondary,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        side: BorderSide(color: KuroTheme.border),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
            left: 20,
            right: 20,
            top: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('REGISTRAR NUEVA SERIE EN CATÁLOGO',
                style: KuroTheme.mono(
                    fontSize: 11,
                    color: KuroTheme.cyan,
                    fontWeight: FontWeight.w800)),
            const SizedBox(height: 14),
            TextField(
              controller: titleCtrl,
              style: KuroTheme.mono(fontSize: 12, color: Colors.white),
              decoration: InputDecoration(
                labelText: 'Título del Manga',
                labelStyle: KuroTheme.mono(fontSize: 10, color: KuroTheme.textMuted),
                filled: true,
                fillColor: KuroTheme.card,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: authorCtrl,
              style: KuroTheme.mono(fontSize: 12, color: Colors.white),
              decoration: InputDecoration(
                labelText: 'Autor / Mangaka',
                labelStyle: KuroTheme.mono(fontSize: 10, color: KuroTheme.textMuted),
                filled: true,
                fillColor: KuroTheme.card,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: catCtrl,
              style: KuroTheme.mono(fontSize: 12, color: Colors.white),
              decoration: InputDecoration(
                labelText: 'Categoría Principal',
                labelStyle: KuroTheme.mono(fontSize: 10, color: KuroTheme.textMuted),
                filled: true,
                fillColor: KuroTheme.card,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: imageCtrl,
              style: KuroTheme.mono(fontSize: 12, color: Colors.white),
              decoration: InputDecoration(
                labelText: 'URL de Portada (Opcional)',
                hintText: 'https://ejemplo.com/portada.jpg',
                labelStyle: KuroTheme.mono(fontSize: 10, color: KuroTheme.textMuted),
                hintStyle: KuroTheme.mono(fontSize: 9.5, color: KuroTheme.textMuted),
                filled: true,
                fillColor: KuroTheme.card,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 42,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                    backgroundColor: KuroTheme.crimson,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8))),
                onPressed: () async {
                  if (titleCtrl.text.isNotEmpty) {
                    final newTitle = titleCtrl.text.trim();
                    final newAuthor = authorCtrl.text.trim().isEmpty
                        ? 'Autor Desconocido'
                        : authorCtrl.text.trim();
                    final newCat = catCtrl.text.trim();
                    final customCover = imageCtrl.text.trim();

                    await KuroAdminBackendService.instance.addMangaToCatalog(
                      title: newTitle,
                      author: newAuthor,
                      category: newCat,
                      imageUrl: customCover.isNotEmpty ? customCover : null,
                    );

                    _cargarCatalogo();

                    if (ctx.mounted) Navigator.pop(ctx);
                    Fluttertoast.showToast(
                        msg: 'Serie añadida al catálogo global con éxito',
                        backgroundColor: KuroTheme.crimson);
                  }
                },
                child: Text('CREAR FICHA EN BASE DE DATOS',
                    style: KuroTheme.mono(
                        fontSize: 10,
                        color: Colors.white,
                        fontWeight: FontWeight.w800)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==========================================
  // MODAL DETALLE COMPLETO DEL MANGA (ADMIN)
  // ==========================================
  void _showMangaDetailsSheet(Map<String, dynamic> manga) {
    final docId = (manga['docId'] ?? manga['id'] ?? 'N/A').toString();
    final title = (manga['title'] ?? 'Sin título').toString();
    final author = (manga['author'] ?? manga['autor'] ?? 'Autor no especificado').toString();
    final category = (manga['category'] ?? manga['mangaCategoryName'] ?? 'General').toString();
    final type = (manga['type'] ?? 'MANGA').toString();
    final status = (manga['status'] ?? 'EN EMISIÓN').toString().toUpperCase();
    final pages = (manga['numberPages'] ?? '0').toString();
    final chapter = (manga['capitulo'] ?? '').toString();
    final chapterName = (manga['nombreCapitulo'] ?? '').toString();
    final pdfUrl = (manga['pdfUrl'] ?? '').toString();
    final imageUrl = (manga['imageUrl'] ?? '').toString();
    final views = (manga['views'] ?? '0').toString();
    final dateStr = (manga['fecha_subida_str'] ?? 'Reciente').toString();
    final tags = manga['tags'] is List ? (manga['tags'] as List).cast<dynamic>() : [];

    final statusColor = status == 'FINALIZADO'
        ? KuroTheme.purple
        : (status == 'PAUSADO' ? KuroTheme.crimson : KuroTheme.cyan);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: KuroTheme.backgroundSecondary,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        side: BorderSide(color: KuroTheme.border),
      ),
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.85,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (_, scrollCtrl) => SingleChildScrollView(
          controller: scrollCtrl,
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Barra superior / Telemetría
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(width: 4, height: 12, color: KuroTheme.cyan),
                      const SizedBox(width: 6),
                      Text('KURO ADMIN // METADATOS Y CONTROL',
                          style: KuroTheme.mono(
                              fontSize: 9,
                              color: KuroTheme.cyan,
                              fontWeight: FontWeight.w800)),
                    ],
                  ),
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit_outlined, color: KuroTheme.cyan, size: 19),
                        tooltip: 'Editar datos y foto',
                        onPressed: () {
                          Navigator.pop(ctx);
                          _showEditMangaDialog(manga);
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, color: Colors.white70, size: 20),
                        onPressed: () => Navigator.pop(ctx),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Hero: Portada + Información Primaria
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildMangaCover(imageUrl, width: 90, height: 130),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: GoogleFonts.spaceGrotesk(
                              fontSize: 16,
                              fontWeight: FontWeight.w900,
                              color: Colors.white),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(Icons.person_outline,
                                color: KuroTheme.textGrey, size: 13),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                author,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: KuroTheme.body(
                                    fontSize: 11, color: KuroTheme.textGrey),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 6,
                          runSpacing: 6,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 7, vertical: 2.5),
                              decoration: BoxDecoration(
                                color: statusColor.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(4),
                                border: Border.all(color: statusColor),
                              ),
                              child: Text(status,
                                  style: KuroTheme.mono(
                                      fontSize: 7.5,
                                      color: statusColor,
                                      fontWeight: FontWeight.w800)),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 7, vertical: 2.5),
                              decoration: BoxDecoration(
                                color: KuroTheme.purple.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(4),
                                border: Border.all(
                                    color: KuroTheme.purple
                                        .withValues(alpha: 0.5)),
                              ),
                              child: Text(category,
                                  style: KuroTheme.mono(
                                      fontSize: 7.5,
                                      color: KuroTheme.purple,
                                      fontWeight: FontWeight.w700)),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 7, vertical: 2.5),
                              decoration: BoxDecoration(
                                color: KuroTheme.cardLighter,
                                borderRadius: BorderRadius.circular(4),
                                border: Border.all(color: KuroTheme.border),
                              ),
                              child: Text(type,
                                  style: KuroTheme.mono(
                                      fontSize: 7.5,
                                      color: Colors.white70,
                                      fontWeight: FontWeight.w700)),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 18),

              // Grid de Parámetros de Firestore
              Container(
                padding: const EdgeInsets.all(14),
                decoration: KuroTheme.cardDecoration(),
                child: Column(
                  children: [
                    _buildMetaRow(
                      icon: Icons.fingerprint,
                      label: 'ID FIRESTORE',
                      value: docId,
                      canCopy: true,
                    ),
                    const Divider(color: KuroTheme.border, height: 16),
                    _buildMetaRow(
                      icon: Icons.menu_book,
                      label: 'TOMO / CAPÍTULO',
                      value: chapter.isNotEmpty
                          ? 'Capítulo $chapter ${chapterName.isNotEmpty ? "($chapterName)" : ""}'
                          : 'Ficha General de Serie',
                    ),
                    const Divider(color: KuroTheme.border, height: 16),
                    _buildMetaRow(
                      icon: Icons.format_list_numbered,
                      label: 'PÁGINAS REGISTRADAS',
                      value: '$pages páginas',
                    ),
                    const Divider(color: KuroTheme.border, height: 16),
                    _buildMetaRow(
                      icon: Icons.calendar_today,
                      label: 'FECHA REGISTRO',
                      value: dateStr,
                    ),
                    const Divider(color: KuroTheme.border, height: 16),
                    _buildMetaRow(
                      icon: Icons.remove_red_eye_outlined,
                      label: 'MÉTRICA DE LECTURAS',
                      value: '$views visualizaciones',
                    ),
                  ],
                ),
              ),

              // ==========================================
              // SECCIÓN: TOMOS Y CAPÍTULOS DE ESTA OBRA
              // ==========================================
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(width: 4, height: 12, color: KuroTheme.purple),
                      const SizedBox(width: 6),
                      Text('TOMOS Y CAPÍTULOS // FIRESTORE',
                          style: KuroTheme.mono(
                              fontSize: 9.5,
                              color: Colors.white,
                              fontWeight: FontWeight.w800)),
                    ],
                  ),
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () => _showCrearTomoDialog(docId, title, () {
                          if (ctx.mounted) Navigator.pop(ctx);
                          _showMangaDetailsSheet(manga);
                        }),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: KuroTheme.purple.withValues(alpha: 0.25),
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(color: KuroTheme.purple),
                          ),
                          child: Text('+ Tomo',
                              style: KuroTheme.mono(
                                  fontSize: 8, color: Colors.white, fontWeight: FontWeight.w800)),
                        ),
                      ),
                      const SizedBox(width: 6),
                      GestureDetector(
                        onTap: () {
                          if (ctx.mounted) Navigator.pop(ctx);
                          setState(() {
                            _targetUploadMangaId = docId;
                            _targetUploadMangaTitle = title;
                            _selectedNav = 1;
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: KuroTheme.crimson,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text('+ Capítulo',
                              style: KuroTheme.mono(
                                  fontSize: 8, color: Colors.white, fontWeight: FontWeight.w800)),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 10),

              FutureBuilder<List<Map<String, dynamic>>>(
                future: KuroAdminBackendService.instance.fetchCapitulos(docId),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.all(16),
                        child: CircularProgressIndicator(color: KuroTheme.purple, strokeWidth: 2),
                      ),
                    );
                  }

                  final caps = snapshot.data ?? [];
                  if (caps.isEmpty) {
                    return Container(
                      padding: const EdgeInsets.all(16),
                      decoration: KuroTheme.cardDecoration(),
                      child: Center(
                        child: Column(
                          children: [
                            const Icon(Icons.menu_book, color: KuroTheme.textMuted, size: 28),
                            const SizedBox(height: 6),
                            Text('Aún no hay capítulos registrados en este manga',
                                style: KuroTheme.body(fontSize: 10, color: KuroTheme.textMuted)),
                            const SizedBox(height: 12),
                            Wrap(
                              alignment: WrapAlignment.center,
                              spacing: 8,
                              runSpacing: 8,
                              children: [
                                if (title.toLowerCase().contains('dragon ball super'))
                                  ElevatedButton.icon(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: KuroTheme.purple,
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                                    ),
                                    icon: const Icon(Icons.bolt, size: 14, color: Colors.white),
                                    onPressed: () {
                                      if (ctx.mounted) Navigator.pop(ctx);
                                      _sembrarDragonBallSuper(targetMangaId: docId);
                                    },
                                    label: Text('GENERAR TOMOS 1 Y 2',
                                        style: KuroTheme.mono(fontSize: 8.5, color: Colors.white, fontWeight: FontWeight.w800)),
                                  ),
                                ElevatedButton.icon(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: KuroTheme.crimson,
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                                  ),
                                  icon: const Icon(Icons.add_circle_outline, size: 14, color: Colors.white),
                                  onPressed: () {
                                    if (ctx.mounted) Navigator.pop(ctx);
                                    setState(() {
                                      _targetUploadMangaId = docId;
                                      _targetUploadMangaTitle = title;
                                      _selectedNav = 1;
                                    });
                                  },
                                  label: Text('+ SUBIR PRIMER CAPÍTULO',
                                      style: KuroTheme.mono(fontSize: 8.5, color: Colors.white, fontWeight: FontWeight.w800)),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  return Container(
                    decoration: KuroTheme.cardDecoration(),
                    child: ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: caps.length,
                      separatorBuilder: (_, __) => const Divider(color: KuroTheme.border, height: 1),
                      itemBuilder: (c, idx) {
                        final cap = caps[idx];
                        final capNum = cap['capituloDisplay'] ?? cap['numero'] ?? '${idx + 1}';
                        final capNombre = cap['nombre'] ?? 'Capítulo $capNum';
                        final capTomo = cap['tomo'] ?? 'Tomo 01';
                        final capPdf = cap['pdfUrl'] ?? '';

                        return ListTile(
                          dense: true,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          onTap: () {
                            final List<String> paginasList = (cap['paginas'] as List?)
                                ?.map((e) => e.toString())
                                .where((s) => s.isNotEmpty)
                                .toList() ?? [];

                            if (capPdf.isNotEmpty || paginasList.isNotEmpty) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => OnlineViewScreen(
                                    pdfUrl: capPdf,
                                    pageImages: paginasList.isNotEmpty ? paginasList : null,
                                    mangaTitle: '$title - Cap $capNum',
                                    chapterTitle: capNombre,
                                  ),
                                ),
                              );
                            } else {
                              Fluttertoast.showToast(
                                msg: 'Este capítulo aún no tiene páginas o PDF asignado. Usa "+ CAP" para subirlo.',
                              );
                            }
                          },
                          leading: Container(
                            width: 36,
                            height: 36,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: KuroTheme.purple.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: KuroTheme.purple.withValues(alpha: 0.4)),
                            ),
                            child: Text(
                              '#$capNum',
                              style: KuroTheme.mono(fontSize: 10.5, color: KuroTheme.purple, fontWeight: FontWeight.w800),
                            ),
                          ),
                          title: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                                decoration: BoxDecoration(
                                  color: KuroTheme.cardLighter,
                                  borderRadius: BorderRadius.circular(3),
                                  border: Border.all(color: KuroTheme.border),
                                ),
                                child: Text(
                                  capTomo.length > 14 ? '${capTomo.substring(0, 14)}...' : capTomo,
                                  style: KuroTheme.mono(fontSize: 7.5, color: KuroTheme.cyan, fontWeight: FontWeight.w700),
                                ),
                              ),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  capNombre,
                                  style: GoogleFonts.spaceGrotesk(fontSize: 12, fontWeight: FontWeight.w700, color: Colors.white),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                          subtitle: Padding(
                            padding: const EdgeInsets.only(top: 2),
                            child: Text(
                              '${cap['numberPages'] ?? '42'} págs • ${cap['visibilidad'] ?? 'PUBLICADO'}',
                              style: KuroTheme.mono(fontSize: 8, color: KuroTheme.textMuted),
                            ),
                          ),
                          trailing: (capPdf.isNotEmpty || (cap['paginas'] != null && (cap['paginas'] as List).isNotEmpty))
                              ? IconButton(
                                  icon: const Icon(Icons.chrome_reader_mode, color: KuroTheme.cyan, size: 18),
                                  onPressed: () {
                                    final List<String> paginasList = (cap['paginas'] as List?)
                                        ?.map((e) => e.toString())
                                        .where((s) => s.isNotEmpty)
                                        .toList() ?? [];

                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => OnlineViewScreen(
                                          pdfUrl: capPdf,
                                          pageImages: paginasList.isNotEmpty ? paginasList : null,
                                          mangaTitle: '$title - Cap $capNum',
                                          chapterTitle: capNombre,
                                        ),
                                      ),
                                    );
                                  },
                                )
                              : null,
                        );
                      },
                    ),
                  );
                },
              ),

              const SizedBox(height: 14),

              // Sección PDF / Visor RAW
              Container(
                padding: const EdgeInsets.all(14),
                decoration: KuroTheme.cardDecoration(
                  borderColor: pdfUrl.isNotEmpty
                      ? KuroTheme.cyan.withValues(alpha: 0.4)
                      : KuroTheme.border,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.picture_as_pdf,
                            color: pdfUrl.isNotEmpty
                                ? KuroTheme.cyan
                                : KuroTheme.textMuted,
                            size: 16),
                        const SizedBox(width: 8),
                        Text('ARCHIVO PDF / CONTENIDO RAW',
                            style: KuroTheme.mono(
                                fontSize: 9.5,
                                color: Colors.white,
                                fontWeight: FontWeight.w800)),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      pdfUrl.isNotEmpty
                          ? pdfUrl
                          : 'No se asignó un enlace PDF a este registro.',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: KuroTheme.mono(
                          fontSize: 9,
                          color: pdfUrl.isNotEmpty
                              ? KuroTheme.cyan
                              : KuroTheme.textMuted),
                    ),
                    const SizedBox(height: 12),
                    if (pdfUrl.isNotEmpty)
                      SizedBox(
                        width: double.infinity,
                        height: 38,
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: KuroTheme.cyan,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8)),
                          ),
                          icon: const Icon(Icons.chrome_reader_mode,
                              color: Colors.black, size: 16),
                          label: Text('ABRIR EN VISOR / VER PÁGINAS',
                              style: KuroTheme.mono(
                                  fontSize: 9.5,
                                  color: Colors.black,
                                  fontWeight: FontWeight.w800)),
                          onPressed: () {
                            final List<String> mangaPages = (manga['paginas'] as List?)
                                ?.map((e) => e.toString())
                                .where((s) => s.isNotEmpty)
                                .toList() ?? [];

                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => OnlineViewScreen(
                                  pdfUrl: pdfUrl,
                                  pageImages: mangaPages.isNotEmpty ? mangaPages : null,
                                  mangaTitle: title,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                  ],
                ),
              ),

              if (tags.isNotEmpty) ...[
                const SizedBox(height: 14),
                Text('ETIQUETAS // TAGS',
                    style: KuroTheme.mono(
                        fontSize: 8.5, color: KuroTheme.textMuted)),
                const SizedBox(height: 6),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: tags.map((t) {
                    return Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: KuroTheme.cardLighter,
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(color: KuroTheme.border),
                      ),
                      child: Text('#$t',
                          style: KuroTheme.mono(
                              fontSize: 8, color: KuroTheme.textGrey)),
                    );
                  }).toList(),
                ),
              ],

              const SizedBox(height: 18),

              // Botones de Acción de Administrador
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: KuroTheme.cyan),
                        padding: const EdgeInsets.symmetric(vertical: 11),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8)),
                      ),
                      icon: const Icon(Icons.edit, color: KuroTheme.cyan, size: 15),
                      label: Text('EDITAR',
                          style: KuroTheme.mono(
                              fontSize: 8.5, color: KuroTheme.cyan, fontWeight: FontWeight.w700)),
                      onPressed: () {
                        if (ctx.mounted) Navigator.pop(ctx);
                        _showEditMangaDialog(manga);
                      },
                    ),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: KuroTheme.border),
                        padding: const EdgeInsets.symmetric(vertical: 11),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8)),
                      ),
                      icon: const Icon(Icons.sync_alt,
                          color: Colors.white, size: 15),
                      label: Text('ESTADO',
                          style: KuroTheme.mono(
                              fontSize: 8.5, color: Colors.white)),
                      onPressed: () {
                        if (ctx.mounted) Navigator.pop(ctx);
                        _editMangaSheet(manga);
                      },
                    ),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: KuroTheme.crimson,
                        padding: const EdgeInsets.symmetric(vertical: 11),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8)),
                      ),
                      icon: const Icon(Icons.cloud_upload_outlined,
                          color: Colors.white, size: 15),
                      label: Text('+ CAP',
                          style: KuroTheme.mono(
                              fontSize: 8.5,
                              color: Colors.white,
                              fontWeight: FontWeight.w800)),
                      onPressed: () {
                        if (ctx.mounted) Navigator.pop(ctx);
                        setState(() {
                          _targetUploadMangaId = docId;
                          _targetUploadMangaTitle = title;
                          _selectedNav = 1;
                        });
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: TextButton.icon(
                  icon: const Icon(Icons.delete_outline,
                      color: KuroTheme.crimson, size: 16),
                  label: Text('ARCHIVAR / ELIMINAR DE FIRESTORE',
                      style: KuroTheme.mono(
                          fontSize: 8.5,
                          color: KuroTheme.crimson,
                          fontWeight: FontWeight.w700)),
                  onPressed: () async {
                    if (manga['docId'] != null) {
                      await KuroAdminBackendService.instance
                          .deleteManga(manga['docId']);
                    }
                    setState(() {
                      _catalogMangas.remove(manga);
                      _catalogCount = _catalogMangas.length.toString();
                    });
                    if (ctx.mounted) Navigator.pop(ctx);
                    Fluttertoast.showToast(
                        msg: 'Manga archivado del catálogo de Firestore',
                        backgroundColor: KuroTheme.crimson);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMetaRow({
    required IconData icon,
    required String label,
    required String value,
    bool canCopy = false,
  }) {
    return Row(
      children: [
        Icon(icon, color: KuroTheme.textGrey, size: 15),
        const SizedBox(width: 8),
        Text(label,
            style: KuroTheme.mono(
                fontSize: 8.5,
                color: KuroTheme.textMuted,
                fontWeight: FontWeight.w700)),
        const Spacer(),
        Flexible(
          child: Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: KuroTheme.mono(
                fontSize: 9.5,
                color: Colors.white,
                fontWeight: FontWeight.w600),
          ),
        ),
        if (canCopy) ...[
          const SizedBox(width: 6),
          GestureDetector(
            onTap: () {
              Clipboard.setData(ClipboardData(text: value));
              Fluttertoast.showToast(msg: 'Copiado al portapapeles');
            },
            child: const Icon(Icons.copy, color: KuroTheme.cyan, size: 13),
          ),
        ],
      ],
    );
  }

  void _showCrearTomoDialog(String mangaId, String mangaTitle, VoidCallback onCreated) {
    final tomoNumCtrl = TextEditingController();
    final tomoNombreCtrl = TextEditingController();
    bool isSaving = false;

    showDialog(
      context: context,
      builder: (dlgCtx) => StatefulBuilder(
        builder: (context, setDlgState) {
          return AlertDialog(
            backgroundColor: KuroTheme.backgroundSecondary,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
              side: const BorderSide(color: KuroTheme.border),
            ),
            title: Row(
              children: [
                const Icon(Icons.bookmark_add, color: KuroTheme.purple, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'CREAR TOMO / VOLUMEN',
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Manga: $mangaTitle',
                    style: KuroTheme.mono(fontSize: 10, color: KuroTheme.cyan),
                  ),
                  const SizedBox(height: 14),
                  Text('NÚMERO DE TOMO (EJ: 1, 2, 3...)',
                      style: KuroTheme.mono(fontSize: 8.5, color: KuroTheme.textMuted)),
                  const SizedBox(height: 6),
                  Container(
                    decoration: BoxDecoration(
                      color: KuroTheme.cardLighter,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: KuroTheme.border),
                    ),
                    child: TextField(
                      controller: tomoNumCtrl,
                      keyboardType: TextInputType.number,
                      style: KuroTheme.mono(fontSize: 12, color: Colors.white),
                      decoration: InputDecoration(
                        hintText: '1',
                        hintStyle: KuroTheme.mono(fontSize: 11, color: KuroTheme.textMuted),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                      ),
                      onChanged: (val) {
                        if (tomoNombreCtrl.text.isEmpty || tomoNombreCtrl.text.startsWith('Tomo ')) {
                          final padded = val.padLeft(2, '0');
                          tomoNombreCtrl.text = 'Tomo $padded';
                        }
                      },
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text('NOMBRE / ETIQUETA DEL TOMO',
                      style: KuroTheme.mono(fontSize: 8.5, color: KuroTheme.textMuted)),
                  const SizedBox(height: 6),
                  Container(
                    decoration: BoxDecoration(
                      color: KuroTheme.cardLighter,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: KuroTheme.border),
                    ),
                    child: TextField(
                      controller: tomoNombreCtrl,
                      style: KuroTheme.mono(fontSize: 12, color: Colors.white),
                      decoration: InputDecoration(
                        hintText: 'Ej. Tomo 01: El Comienzo',
                        hintStyle: KuroTheme.mono(fontSize: 11, color: KuroTheme.textMuted),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: isSaving ? null : () => Navigator.pop(dlgCtx),
                child: Text('CANCELAR', style: KuroTheme.mono(fontSize: 10, color: KuroTheme.textMuted)),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: KuroTheme.purple,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                onPressed: isSaving
                    ? null
                    : () async {
                        final nombre = tomoNombreCtrl.text.trim();
                        final numero = int.tryParse(tomoNumCtrl.text.trim());
                        if (nombre.isEmpty) {
                          Fluttertoast.showToast(msg: 'Ingresa el nombre o número del tomo');
                          return;
                        }
                        setDlgState(() => isSaving = true);
                        try {
                          await KuroAdminBackendService.instance.createTomo(
                            mangaId: mangaId,
                            tomoNombre: nombre,
                            tomoNumero: numero,
                          );
                          if (dlgCtx.mounted) Navigator.pop(dlgCtx);
                          Fluttertoast.showToast(
                            msg: '$nombre registrado con éxito',
                            backgroundColor: KuroTheme.purple,
                          );
                          onCreated();
                        } catch (e) {
                          setDlgState(() => isSaving = false);
                          Fluttertoast.showToast(
                            msg: 'Error al crear tomo: $e',
                            backgroundColor: KuroTheme.crimson,
                          );
                        }
                      },
                child: isSaving
                    ? const SizedBox(
                        width: 14,
                        height: 14,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : Text(
                        'CREAR TOMO',
                        style: KuroTheme.mono(fontSize: 10, color: Colors.white, fontWeight: FontWeight.w800),
                      ),
              ),
            ],
          );
        },
      ),
    );
  }

  void _editMangaSheet(Map<String, dynamic> manga) {
    showModalBottomSheet(
      context: context,
      backgroundColor: KuroTheme.backgroundSecondary,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        side: BorderSide(color: KuroTheme.border),
      ),
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('EDITAR SERIE: ${manga['title']}',
                style: GoogleFonts.spaceGrotesk(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: Colors.white)),
            const SizedBox(height: 14),
            ListTile(
              leading: const Icon(Icons.pause_circle_outline, color: KuroTheme.crimson),
              title: Text('Alternar a Pausado / En Emisión',
                  style: KuroTheme.mono(fontSize: 11, color: Colors.white)),
              onTap: () async {
                setState(() {
                  manga['status'] = manga['status'] == 'EN EMISIÓN' ? 'PAUSADO' : 'EN EMISIÓN';
                  manga['statusColor'] = manga['status'] == 'EN EMISIÓN' ? KuroTheme.cyan : KuroTheme.crimson;
                });
                if (manga['docId'] != null) {
                  await KuroAdminBackendService.instance.updateMangaStatus(manga['docId'], manga['status']);
                }
                if (ctx.mounted) Navigator.pop(ctx);
                Fluttertoast.showToast(msg: 'Estado actualizado a ${manga['status']}');
              },
            ),
            ListTile(
              leading: const Icon(Icons.check_circle_outline, color: KuroTheme.purple),
              title: Text('Marcar como Serie Finalizada',
                  style: KuroTheme.mono(fontSize: 11, color: Colors.white)),
              onTap: () async {
                setState(() {
                  manga['status'] = 'FINALIZADO';
                  manga['statusColor'] = KuroTheme.purple;
                });
                if (manga['docId'] != null) {
                  await KuroAdminBackendService.instance.updateMangaStatus(manga['docId'], 'FINALIZADO');
                }
                if (ctx.mounted) Navigator.pop(ctx);
                Fluttertoast.showToast(msg: 'Serie marcada como FINALIZADO');
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showMangaOptions(Map<String, dynamic> manga) {
    showModalBottomSheet(
      context: context,
      backgroundColor: KuroTheme.backgroundSecondary,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        side: BorderSide(color: KuroTheme.border),
      ),
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.info_outline, color: KuroTheme.cyan),
              title: Text('Ver información técnica completa',
                  style: KuroTheme.mono(fontSize: 11, color: KuroTheme.cyan, fontWeight: FontWeight.w700)),
              onTap: () {
                Navigator.pop(ctx);
                _showMangaDetailsSheet(manga);
              },
            ),
            ListTile(
              leading: const Icon(Icons.edit, color: KuroTheme.cyan),
              title: Text('Editar datos y foto de la obra',
                  style: KuroTheme.mono(fontSize: 11, color: Colors.white, fontWeight: FontWeight.w700)),
              onTap: () {
                Navigator.pop(ctx);
                _showEditMangaDialog(manga);
              },
            ),
            ListTile(
              leading: const Icon(Icons.cloud_upload, color: KuroTheme.crimson),
              title: Text('Subir nuevo capítulo a esta serie',
                  style: KuroTheme.mono(fontSize: 11, color: Colors.white)),
              onTap: () {
                Navigator.pop(ctx);
                setState(() => _selectedNav = 1);
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete_outline, color: KuroTheme.textGrey),
              title: Text('Archivar del catálogo público',
                  style: KuroTheme.mono(fontSize: 11, color: KuroTheme.textGrey)),
              onTap: () async {
                if (manga['docId'] != null) {
                  await KuroAdminBackendService.instance.deleteManga(manga['docId']);
                }
                setState(() {
                  _catalogMangas.remove(manga);
                });
                if (ctx.mounted) Navigator.pop(ctx);
                Fluttertoast.showToast(msg: 'Serie archivada del feed público');
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showEditMangaDialog(Map<String, dynamic> manga) {
    final docId = (manga['docId'] ?? manga['id'] ?? '').toString();
    if (docId.isEmpty) {
      Fluttertoast.showToast(msg: 'No se puede editar: falta ID de Firestore');
      return;
    }

    final titleCtrl = TextEditingController(text: (manga['title'] ?? '').toString());
    final authorCtrl = TextEditingController(text: (manga['author'] ?? manga['autor'] ?? '').toString());
    final imageCtrl = TextEditingController(text: (manga['imageUrl'] ?? '').toString());
    final descCtrl = TextEditingController(text: (manga['description'] ?? manga['sinopsis'] ?? '').toString());

    String selectedCategory = (manga['category'] ?? manga['mangaCategoryName'] ?? 'Shonen').toString();
    String selectedStatus = (manga['status'] ?? 'EN EMISIÓN').toString().toUpperCase();
    if (selectedStatus != 'EN EMISIÓN' && selectedStatus != 'PAUSADO' && selectedStatus != 'FINALIZADO') {
      selectedStatus = 'EN EMISIÓN';
    }

    File? localCoverFile;
    bool isSaving = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: KuroTheme.backgroundSecondary,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        side: BorderSide(color: KuroTheme.border),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) {
          return Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
              top: 16,
              left: 20,
              right: 20,
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(width: 4, height: 14, color: KuroTheme.crimson),
                          const SizedBox(width: 8),
                          Text(
                            'EDITAR OBRA // METADATOS Y PORTADA',
                            style: GoogleFonts.spaceGrotesk(
                              fontSize: 13,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, color: KuroTheme.textMuted, size: 20),
                        onPressed: () => Navigator.pop(ctx),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  // Portada actual + Botón para cambiar foto
                  Center(
                    child: Column(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Container(
                            width: 100,
                            height: 140,
                            color: KuroTheme.cardLighter,
                            child: localCoverFile != null
                                ? Image.file(localCoverFile!, fit: BoxFit.cover)
                                : (imageCtrl.text.isNotEmpty
                                    ? Image.network(
                                        imageCtrl.text,
                                        fit: BoxFit.cover,
                                        errorBuilder: (_, __, ___) => const Center(
                                          child: Icon(Icons.broken_image, color: KuroTheme.textMuted, size: 30),
                                        ),
                                      )
                                    : const Center(
                                        child: Icon(Icons.image, color: KuroTheme.textMuted, size: 30),
                                      )),
                          ),
                        ),
                        const SizedBox(height: 8),
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: KuroTheme.purple.withValues(alpha: 0.3),
                            side: const BorderSide(color: KuroTheme.purple),
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                          ),
                          icon: const Icon(Icons.photo_camera, size: 14, color: Colors.white),
                          label: Text(
                            'CAMBIAR FOTO DESDE GALERÍA',
                            style: KuroTheme.mono(fontSize: 8.5, color: Colors.white, fontWeight: FontWeight.w700),
                          ),
                          onPressed: () async {
                            try {
                              final picker = ImagePicker();
                              final img = await picker.pickImage(source: ImageSource.gallery);
                              if (img != null) {
                                setModalState(() {
                                  localCoverFile = File(img.path);
                                });
                              }
                            } catch (e) {
                              Fluttertoast.showToast(msg: 'Error al abrir galería: $e');
                            }
                          },
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 14),

                  // Título
                  Text('TÍTULO DE LA SERIE', style: KuroTheme.mono(fontSize: 8.5, color: KuroTheme.textMuted)),
                  const SizedBox(height: 4),
                  Container(
                    height: 44,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: KuroTheme.cardLighter,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: KuroTheme.border),
                    ),
                    child: TextField(
                      controller: titleCtrl,
                      style: GoogleFonts.spaceGrotesk(fontSize: 13, color: Colors.white, fontWeight: FontWeight.w700),
                      decoration: const InputDecoration(border: InputBorder.none),
                    ),
                  ),

                  const SizedBox(height: 10),

                  // Autor
                  Text('AUTOR / MANGAKA', style: KuroTheme.mono(fontSize: 8.5, color: KuroTheme.textMuted)),
                  const SizedBox(height: 4),
                  Container(
                    height: 44,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: KuroTheme.cardLighter,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: KuroTheme.border),
                    ),
                    child: TextField(
                      controller: authorCtrl,
                      style: KuroTheme.mono(fontSize: 11, color: Colors.white),
                      decoration: const InputDecoration(border: InputBorder.none),
                    ),
                  ),

                  const SizedBox(height: 10),

                  // Categoría y Estado en una fila
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('CATEGORÍA', style: KuroTheme.mono(fontSize: 8.5, color: KuroTheme.textMuted)),
                            const SizedBox(height: 4),
                            Container(
                              height: 44,
                              padding: const EdgeInsets.symmetric(horizontal: 12),
                              decoration: BoxDecoration(
                                color: KuroTheme.cardLighter,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: KuroTheme.border),
                              ),
                              child: DropdownButtonHideUnderline(
                                child: DropdownButton<String>(
                                  value: ['Shonen', 'Seinen', 'Romance', 'Gore', 'Dark Fantasy', 'Acción', 'Comedia', 'Sobrenatural'].contains(selectedCategory)
                                      ? selectedCategory
                                      : 'Shonen',
                                  dropdownColor: KuroTheme.backgroundSecondary,
                                  isExpanded: true,
                                  items: ['Shonen', 'Seinen', 'Romance', 'Gore', 'Dark Fantasy', 'Acción', 'Comedia', 'Sobrenatural'].map((cat) {
                                    return DropdownMenuItem<String>(
                                      value: cat,
                                      child: Text(cat, style: KuroTheme.mono(fontSize: 11, color: Colors.white)),
                                    );
                                  }).toList(),
                                  onChanged: (val) {
                                    if (val != null) setModalState(() => selectedCategory = val);
                                  },
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('ESTADO', style: KuroTheme.mono(fontSize: 8.5, color: KuroTheme.textMuted)),
                            const SizedBox(height: 4),
                            Container(
                              height: 44,
                              padding: const EdgeInsets.symmetric(horizontal: 12),
                              decoration: BoxDecoration(
                                color: KuroTheme.cardLighter,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: KuroTheme.border),
                              ),
                              child: DropdownButtonHideUnderline(
                                child: DropdownButton<String>(
                                  value: selectedStatus,
                                  dropdownColor: KuroTheme.backgroundSecondary,
                                  isExpanded: true,
                                  items: ['EN EMISIÓN', 'PAUSADO', 'FINALIZADO'].map((st) {
                                    return DropdownMenuItem<String>(
                                      value: st,
                                      child: Text(st, style: KuroTheme.mono(fontSize: 11, color: Colors.white)),
                                    );
                                  }).toList(),
                                  onChanged: (val) {
                                    if (val != null) setModalState(() => selectedStatus = val);
                                  },
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 10),

                  // URL de Portada (opcional/manual)
                  Text('O URL DIRECTA DE PORTADA', style: KuroTheme.mono(fontSize: 8.5, color: KuroTheme.textMuted)),
                  const SizedBox(height: 4),
                  Container(
                    height: 44,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: KuroTheme.cardLighter,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: KuroTheme.border),
                    ),
                    child: TextField(
                      controller: imageCtrl,
                      onChanged: (_) => setModalState(() {}),
                      style: KuroTheme.mono(fontSize: 10.5, color: KuroTheme.cyan),
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        hintText: 'https://ejemplo.com/portada.jpg',
                        hintStyle: TextStyle(fontSize: 10, color: KuroTheme.textMuted),
                      ),
                    ),
                  ),

                  const SizedBox(height: 10),

                  // Sinopsis
                  Text('SINOPSIS / DESCRIPCIÓN', style: KuroTheme.mono(fontSize: 8.5, color: KuroTheme.textMuted)),
                  const SizedBox(height: 4),
                  Container(
                    height: 80,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: KuroTheme.cardLighter,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: KuroTheme.border),
                    ),
                    child: TextField(
                      controller: descCtrl,
                      maxLines: 3,
                      style: KuroTheme.body(fontSize: 11, color: Colors.white),
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        hintText: 'Escribe una breve sinopsis de la obra...',
                        hintStyle: TextStyle(fontSize: 10, color: KuroTheme.textMuted),
                      ),
                    ),
                  ),

                  const SizedBox(height: 18),

                  // Botón Guardar Cambios
                  SizedBox(
                    width: double.infinity,
                    height: 46,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: KuroTheme.crimson,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      icon: isSaving
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                            )
                          : const Icon(Icons.save, size: 18, color: Colors.white),
                      label: Text(
                        isSaving ? 'GUARDANDO CAMBIOS...' : 'GUARDAR CAMBIOS EN FIRESTORE',
                        style: KuroTheme.mono(fontSize: 10.5, color: Colors.white, fontWeight: FontWeight.w800),
                      ),
                      onPressed: isSaving
                          ? null
                          : () async {
                              final newTitle = titleCtrl.text.trim();
                              if (newTitle.isEmpty) {
                                Fluttertoast.showToast(msg: 'El título no puede estar vacío');
                                return;
                              }

                              setModalState(() => isSaving = true);
                              try {
                                String finalCoverUrl = imageCtrl.text.trim();

                                // Si seleccionó una foto local, subir a Firebase Storage
                                if (localCoverFile != null && localCoverFile!.existsSync()) {
                                  try {
                                    final fileName = 'cover_${docId}_${DateTime.now().millisecondsSinceEpoch}.jpg';
                                    final storageRef = FirebaseStorage.instance.ref().child('images').child(fileName);
                                    final uploadTask = await storageRef.putFile(localCoverFile!);
                                    finalCoverUrl = await uploadTask.ref.getDownloadURL();
                                  } catch (e) {
                                    debugPrint('Storage error uploading cover: $e');
                                    finalCoverUrl = localCoverFile!.path;
                                  }
                                }

                                await KuroAdminBackendService.instance.updateManga(
                                  docId: docId,
                                  title: newTitle,
                                  author: authorCtrl.text.trim().isNotEmpty ? authorCtrl.text.trim() : 'Autor no especificado',
                                  category: selectedCategory,
                                  status: selectedStatus,
                                  imageUrl: finalCoverUrl.isNotEmpty ? finalCoverUrl : null,
                                  description: descCtrl.text.trim(),
                                );

                                // Actualizar el mapa local del manga
                                setState(() {
                                  manga['title'] = newTitle;
                                  manga['author'] = authorCtrl.text.trim();
                                  manga['category'] = selectedCategory;
                                  manga['mangaCategoryName'] = selectedCategory;
                                  manga['status'] = selectedStatus;
                                  if (finalCoverUrl.isNotEmpty) manga['imageUrl'] = finalCoverUrl;
                                  manga['description'] = descCtrl.text.trim();
                                });

                                _cargarCatalogo();

                                if (ctx.mounted) Navigator.pop(ctx);
                                Fluttertoast.showToast(
                                  msg: '¡Datos y portada de "$newTitle" actualizados!',
                                  backgroundColor: KuroTheme.purple,
                                );
                              } catch (e) {
                                setModalState(() => isSaving = false);
                                Fluttertoast.showToast(msg: 'Error al actualizar: $e');
                              }
                            },
                    ),
                  ),

                  const SizedBox(height: 16),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Future<void> _sembrarDragonBallSuper({String? targetMangaId}) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dlgCtx) => StatefulBuilder(
        builder: (context, setDlgState) {
          return AlertDialog(
            backgroundColor: KuroTheme.backgroundSecondary,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
              side: const BorderSide(color: KuroTheme.border),
            ),
            title: Row(
              children: [
                const Icon(Icons.bolt, color: KuroTheme.purple, size: 22),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'POBLANDO DRAGON BALL SUPER',
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 10),
                const CircularProgressIndicator(color: KuroTheme.purple),
                const SizedBox(height: 18),
                Text(
                  'Registrando Tomo 1 y Tomo 2 con sus 15 capítulos canónicos en Firestore...',
                  textAlign: TextAlign.center,
                  style: KuroTheme.body(fontSize: 11, color: KuroTheme.textGrey),
                ),
              ],
            ),
          );
        },
      ),
    );

    try {
      String mangaDocId = targetMangaId ?? '';

      // Si no nos pasaron el ID, buscar si existe Dragon Ball Super en el catálogo
      if (mangaDocId.isEmpty) {
        final match = _catalogMangas.firstWhere(
          (m) => m['title'].toString().toLowerCase().contains('dragon ball super'),
          orElse: () => {},
        );
        if (match.isNotEmpty) {
          mangaDocId = match['docId'] ?? match['id'] ?? '';
        }
      }

      // Si no existe, crear el documento del manga en la colección principal
      if (mangaDocId.isEmpty) {
        final newDoc = FirebaseFirestore.instance.collection('mangas').doc();
        mangaDocId = newDoc.id;
        await newDoc.set({
          'id': mangaDocId,
          'title': 'Dragon Ball Super',
          'author': 'Akira Toriyama & Toyotarō',
          'mangaCategoryName': 'Shonen',
          'status': 'EN EMISIÓN',
          'type': 'MANGA',
          'numberPages': '852',
          'imageUrl': 'https://firebasestorage.googleapis.com/v0/b/latin-manga.appspot.com/o/images%2Fdragon_ball_super.jpg?alt=media',
          'pdfUrl': 'https://firebasestorage.googleapis.com/v0/b/latin-manga.appspot.com/o/pdfs%2F5fac889b-1ed8-496f-b7f1-d0092c68f2ae?alt=media',
          'tags': ['Shonen', 'Acción', 'Artes Marciales', 'Aventura'],
          'fecha_creacion': FieldValue.serverTimestamp(),
          'fecha_actualizacion': FieldValue.serverTimestamp(),
          'views': '14520',
        });
      }

      // Capítulos de Tomo 01: "Los guerreros del Universo 6" (Capítulos 1 al 9)
      final capitulosTomo1 = [
        {'num': '1', 'nombre': 'El sueño profético del dios de la destrucción', 'pags': '45'},
        {'num': '2', 'nombre': 'La derrota de Goku', 'pags': '42'},
        {'num': '3', 'nombre': 'La ira de Bills', 'pags': '40'},
        {'num': '4', 'nombre': 'Dios y Dios', 'pags': '44'},
        {'num': '5', 'nombre': 'Bills y Champa', 'pags': '43'},
        {'num': '6', 'nombre': 'Preparándose para el torneo', 'pags': '41'},
        {'num': '7', 'nombre': 'Los guerreros del sexto universo', 'pags': '45'},
        {'num': '8', 'nombre': '¡El Torneo Comienza!', 'pags': '42'},
        {'num': '9', 'nombre': 'Goku VS Botamo', 'pags': '40'},
      ];

      // Capítulos de Tomo 02: "¡Finalmente se define el universo ganador!" (Capítulos 10 al 15)
      final capitulosTomo2 = [
        {'num': '10', 'nombre': 'La verdadera identidad de Frost', 'pags': '45'},
        {'num': '11', 'nombre': '¡Vegeta entra en escena!', 'pags': '43'},
        {'num': '12', 'nombre': 'El orgullo de los saiyajin', 'pags': '44'},
        {'num': '13', 'nombre': '¡Finalmente se define el universo ganador!', 'pags': '46'},
        {'num': '14', 'nombre': 'SOS del futuro', 'pags': '48'},
        {'num': '15', 'nombre': '¡¡Esperanza una vez más!!', 'pags': '45'},
      ];

      // Registrar Tomo 1
      await KuroAdminBackendService.instance.createTomo(
        mangaId: mangaDocId,
        tomoNombre: 'Tomo 01: Los guerreros del Universo 6',
        tomoNumero: 1,
      );

      for (var cap in capitulosTomo1) {
        await KuroAdminBackendService.instance.publishChapter(
          mangaId: mangaDocId,
          seriesTitle: 'Dragon Ball Super',
          volume: 'Tomo 01: Los guerreros del Universo 6',
          chapterNumber: cap['num']!,
          chapterName: cap['nombre']!,
          category: 'Shonen',
          tags: ['Shonen', 'Acción', 'Torneo'],
          instantVisibility: true,
          notifyReaders: false,
          numberPages: cap['pags'],
          customPdfUrl: 'https://firebasestorage.googleapis.com/v0/b/latin-manga.appspot.com/o/pdfs%2F5fac889b-1ed8-496f-b7f1-d0092c68f2ae?alt=media',
        );
      }

      // Registrar Tomo 2
      await KuroAdminBackendService.instance.createTomo(
        mangaId: mangaDocId,
        tomoNombre: 'Tomo 02: ¡Se define el universo ganador!',
        tomoNumero: 2,
      );

      for (var cap in capitulosTomo2) {
        await KuroAdminBackendService.instance.publishChapter(
          mangaId: mangaDocId,
          seriesTitle: 'Dragon Ball Super',
          volume: 'Tomo 02: ¡Se define el universo ganador!',
          chapterNumber: cap['num']!,
          chapterName: cap['nombre']!,
          category: 'Shonen',
          tags: ['Shonen', 'Acción', 'Trunks del Futuro'],
          instantVisibility: true,
          notifyReaders: false,
          numberPages: cap['pags'],
          customPdfUrl: 'https://firebasestorage.googleapis.com/v0/b/latin-manga.appspot.com/o/pdfs%2F5fac889b-1ed8-496f-b7f1-d0092c68f2ae?alt=media',
        );
      }

      if (mounted) {
        Navigator.pop(context); // cerrar diálogo de carga
        Fluttertoast.showToast(
          msg: '¡Dragon Ball Super poblado con éxito! (2 Tomos, 15 Capítulos)',
          backgroundColor: KuroTheme.purple,
          toastLength: Toast.LENGTH_LONG,
        );
        _cargarCatalogo();
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context);
        Fluttertoast.showToast(
          msg: 'Error al poblar: $e',
          backgroundColor: KuroTheme.crimson,
          toastLength: Toast.LENGTH_LONG,
        );
      }
    }
  }
}

// Pintor de gráfica de área Cyan para métricas
class _CyanAreaChartPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final strokePaint = Paint()
      ..color = KuroTheme.cyan
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;

    final fillPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          KuroTheme.cyan.withValues(alpha: 0.35),
          KuroTheme.cyan.withValues(alpha: 0.0),
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height))
      ..style = PaintingStyle.fill;

    final path = Path();
    path.moveTo(0, size.height * 0.85);
    path.cubicTo(
      size.width * 0.35,
      size.height * 0.75,
      size.width * 0.65,
      size.height * 0.30,
      size.width,
      size.height * 0.15,
    );

    final fillPath = Path.from(path)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();

    canvas.drawPath(fillPath, fillPaint);
    canvas.drawPath(path, strokePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
