import 'package:aplicacion_manga/Screens/admin/admin_moderation_screen.dart';
import 'package:aplicacion_manga/Screens/admin/admin_upload_screen.dart';
import 'package:aplicacion_manga/Screens/admin_pagina_principal.dart';
import 'package:aplicacion_manga/theme/kuro_theme.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';

class KuroAdminOverviewScreen extends StatefulWidget {
  const KuroAdminOverviewScreen({Key? key}) : super(key: key);

  @override
  State<KuroAdminOverviewScreen> createState() =>
      _KuroAdminOverviewScreenState();
}

class _KuroAdminOverviewScreenState extends State<KuroAdminOverviewScreen> {
  int _selectedNav = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: KuroTheme.background,
      body: SafeArea(
        child: Column(
          children: [
            // Top App Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back,
                        color: Colors.white, size: 20),
                    onPressed: () => Navigator.pop(context),
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
                                    color: KuroTheme.cyan,
                                    shape: BoxShape.circle)),
                            const SizedBox(width: 6),
                            Text('ADMIN PANEL',
                                style: KuroTheme.mono(
                                    fontSize: 9,
                                    color: KuroTheme.textGrey,
                                    fontWeight: FontWeight.w700)),
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
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
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
                                color: KuroTheme.crimson,
                                shape: BoxShape.circle)),
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
                  Container(
                    width: 34,
                    height: 34,
                    decoration: BoxDecoration(
                        color: const Color(0xFFF7728B),
                        borderRadius: BorderRadius.circular(8)),
                    child:
                        const Icon(Icons.person, color: Colors.black, size: 20),
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
                                Row(
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
                                          borderRadius:
                                              BorderRadius.circular(3)),
                                      child: Text('v3.4',
                                          style: KuroTheme.mono(
                                              fontSize: 8,
                                              color: Colors.white)),
                                    ),
                                  ],
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
                                    Text('Sesión Root Activa • Tokyo Node',
                                        style: KuroTheme.mono(
                                            fontSize: 8.5,
                                            color: KuroTheme.textMuted)),
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
                                border: Border.all(color: KuroTheme.cyan),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.menu_book,
                                      color: KuroTheme.cyan, size: 14),
                                  const SizedBox(width: 5),
                                  Text('MODO LECTOR',
                                      style: KuroTheme.mono(
                                          fontSize: 9,
                                          color: KuroTheme.cyan,
                                          fontWeight: FontWeight.w800)),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 18),

                    // 4 KPI Cards (2x2 Grid)
                    Row(
                      children: [
                        _buildKpiCard(
                          label: 'LECTORES',
                          chipText: '↗ +12.4%',
                          chipBg: KuroTheme.cyan.withValues(alpha: 0.2),
                          chipColor: KuroTheme.cyan,
                          mainNumber: '48.2k',
                          subText: 'Concurrencia viva hoy',
                          indicator: Container(
                            height: 18,
                            alignment: Alignment.bottomLeft,
                            child: Row(
                              children: [
                                Expanded(
                                    child: Container(
                                        height: 2, color: KuroTheme.cyan)),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        _buildKpiCard(
                          label: 'CATÁLOGO',
                          chipText: 'BIBLIOTECA',
                          chipBg: KuroTheme.purple.withValues(alpha: 0.3),
                          chipColor: Colors.white,
                          mainNumber: '1,420',
                          subText: '980 curso // 440 fin',
                          indicator: Row(
                            children: [
                              Expanded(
                                  flex: 69,
                                  child: Container(
                                      height: 3, color: KuroTheme.crimson)),
                              Expanded(
                                  flex: 31,
                                  child: Container(
                                      height: 3, color: KuroTheme.purple)),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        _buildKpiCard(
                          label: 'REVISIÓN RAW',
                          chipText: 'ALTA',
                          chipBg: KuroTheme.crimson,
                          chipColor: Colors.white,
                          mainNumber: '18',
                          subText: '4 tomos urgentes',
                          indicator: Row(
                            children: [
                              const Icon(Icons.warning,
                                  color: KuroTheme.crimson, size: 11),
                              const SizedBox(width: 4),
                              Text('Validación pendiente',
                                  style: KuroTheme.mono(
                                      fontSize: 8, color: KuroTheme.textGrey)),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        _buildKpiCard(
                          label: 'COMUNIDAD',
                          chipText: 'MOD',
                          chipBg: Colors.white.withValues(alpha: 0.2),
                          chipColor: Colors.white,
                          mainNumber: '07',
                          subText: 'Spoilers / Conducta',
                          indicator: Row(
                            children: [
                              const Icon(Icons.chat_bubble_outline,
                                  color: KuroTheme.purple, size: 11),
                              const SizedBox(width: 4),
                              Text('Atención requerida',
                                  style: KuroTheme.mono(
                                      fontSize: 8, color: KuroTheme.textGrey)),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // Section: Comandos Directos
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                                width: 4, height: 12, color: KuroTheme.crimson),
                            const SizedBox(width: 6),
                            Text('Comandos Directos',
                                style: KuroTheme.title(fontSize: 16)),
                          ],
                        ),
                        Text('OPERACIÓN EDITORIAL',
                            style: KuroTheme.mono(
                                fontSize: 8.5, color: KuroTheme.textMuted)),
                      ],
                    ),
                    const SizedBox(height: 12),

                    Row(
                      children: [
                        // Subir Nuevo Tomo (Red Button Card)
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (c) =>
                                          const KuroAdminUploadScreen()));
                            },
                            child: Container(
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                gradient: KuroTheme.crimsonGradient,
                                borderRadius: BorderRadius.circular(14),
                                boxShadow: [
                                  BoxShadow(
                                    color: KuroTheme.crimson
                                        .withValues(alpha: 0.3),
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
                                            color: Colors.white
                                                .withValues(alpha: 0.2),
                                            borderRadius:
                                                BorderRadius.circular(8)),
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
                                          fontSize: 9.5,
                                          color: Colors.white70)),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        // Moderar Foros (Dark Card)
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (c) =>
                                          const KuroAdminModerationScreen()));
                            },
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
                                            borderRadius:
                                                BorderRadius.circular(8)),
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
                                  Text('7 reportes en espera',
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

                    // Gestión de Scanlators & Clanes
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: KuroTheme.cardDecoration(),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                                color: KuroTheme.cardLighter,
                                borderRadius: BorderRadius.circular(8)),
                            child: const Icon(Icons.groups,
                                color: KuroTheme.cyan, size: 18),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Gestión de Scanlators & Clanes',
                                    style: GoogleFonts.spaceGrotesk(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w700,
                                        color: Colors.white)),
                                Text(
                                    '32 grupos activos • 4 solicitudes de ingreso',
                                    style: KuroTheme.body(
                                        fontSize: 10,
                                        color: KuroTheme.textMuted)),
                              ],
                            ),
                          ),
                          const Icon(Icons.arrow_forward_ios,
                              color: KuroTheme.textMuted, size: 14),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Section: Cola Prioritaria
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                                width: 4, height: 12, color: KuroTheme.purple),
                            const SizedBox(width: 6),
                            Text('Cola Prioritaria',
                                style: KuroTheme.title(fontSize: 16)),
                          ],
                        ),
                        Text('REVISAR TODO (18)',
                            style: KuroTheme.mono(
                                fontSize: 9,
                                color: KuroTheme.cyan,
                                fontWeight: FontWeight.w700)),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Priority Queue Item (Berserk: Remaster)
                    Container(
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
                                      color: KuroTheme.crimson,
                                      shape: BoxShape.circle)),
                              const SizedBox(width: 6),
                              Text('SCANLATION // SHINSEI',
                                  style: KuroTheme.mono(
                                      fontSize: 8.5,
                                      color: KuroTheme.textMuted)),
                              const Spacer(),
                              Text('Hace 10m',
                                  style: KuroTheme.mono(
                                      fontSize: 8.5,
                                      color: KuroTheme.textMuted)),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(6),
                                child: Image.network(
                                  'https://images.unsplash.com/photo-1578632767115-351597cf2477?w=800',
                                  width: 46,
                                  height: 60,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Berserk: Remaster',
                                        style: GoogleFonts.spaceGrotesk(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w800,
                                            color: Colors.white)),
                                    Text(
                                        'Capítulo 143 • RAW UltraHD (48 páginas)',
                                        style: KuroTheme.body(
                                            fontSize: 10,
                                            color: KuroTheme.textGrey)),
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
                                          child: Text('RAW OK',
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
                                          child: Text('TRAD OK',
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
                                child: Container(
                                  height: 38,
                                  decoration: BoxDecoration(
                                      color: KuroTheme.cardLighter,
                                      borderRadius: BorderRadius.circular(8)),
                                  child: Center(
                                    child: Text('Ver Páginas',
                                        style: KuroTheme.mono(
                                            fontSize: 9.5,
                                            color: Colors.white)),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: GestureDetector(
                                  onTap: () {
                                    Fluttertoast.showToast(
                                        msg:
                                            'Capítulo aprobado y publicado en el feed global');
                                  },
                                  child: Container(
                                    height: 38,
                                    decoration: BoxDecoration(
                                        color: KuroTheme.crimson,
                                        borderRadius: BorderRadius.circular(8)),
                                    child: Center(
                                      child: Text('Aprobar & Publicar',
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
                    ),

                    const SizedBox(height: 20),

                    // Plataforma 100% Operativa
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                            Text('Plataforma 100% Operativa',
                                style: KuroTheme.mono(
                                    fontSize: 9, color: KuroTheme.textGrey)),
                          ],
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

            // Bottom Navigation Bar Admin: SYS_VIEW, ACCESS, METRICS, CONSOLE
            Container(
              height: 56,
              decoration: const BoxDecoration(
                color: KuroTheme.backgroundSecondary,
                border: Border(top: BorderSide(color: KuroTheme.border)),
              ),
              child: Row(
                children: [
                  _buildAdminNavItem(Icons.grid_view, 'SYS_VIEW', 0),
                  _buildAdminNavItem(Icons.security, 'ACCESS', 1),
                  _buildAdminNavItem(Icons.show_chart, 'METRICS', 2),
                  _buildAdminNavItem(Icons.terminal, 'CONSOLE', 3),
                  Container(
                    margin: const EdgeInsets.only(right: 12),
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                        color: KuroTheme.cardLighter,
                        borderRadius: BorderRadius.circular(8)),
                    child: const Icon(Icons.exit_to_app,
                        color: KuroTheme.cyan, size: 18),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

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
                Text(label,
                    style: KuroTheme.mono(
                        fontSize: 8.5,
                        color: KuroTheme.textMuted,
                        fontWeight: FontWeight.w700)),
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

  Widget _buildAdminNavItem(IconData icon, String label, int index) {
    final isSelected = _selectedNav == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedNav = index),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon,
                color: isSelected ? KuroTheme.crimson : KuroTheme.textMuted,
                size: 18),
            const SizedBox(height: 2),
            Text(label,
                style: KuroTheme.mono(
                    fontSize: 7.5,
                    color: isSelected ? KuroTheme.crimson : KuroTheme.textMuted,
                    fontWeight: FontWeight.w700)),
          ],
        ),
      ),
    );
  }
}
