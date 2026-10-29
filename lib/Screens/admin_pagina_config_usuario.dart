import 'package:aplicacion_manga/theme/kuro_theme.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';

class AdminPaginaConfigUsuario extends StatefulWidget {
  const AdminPaginaConfigUsuario({Key? key}) : super(key: key);

  @override
  State<AdminPaginaConfigUsuario> createState() => _AdminPaginaConfigUsuarioState();
}

class _AdminPaginaConfigUsuarioState extends State<AdminPaginaConfigUsuario> {
  bool _isOledMode = true;
  bool _showConfirmPurge = false;
  double _cacheUsed = 1.42;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: KuroTheme.background,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: KuroTheme.background,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'CONFIGURACIÓN KURO',
          style: KuroTheme.mono(fontSize: 11, color: KuroTheme.textWhite, fontWeight: FontWeight.w700),
        ),
        actions: [
          IconButton(icon: const Icon(Icons.bookmark_border, color: Colors.white, size: 20), onPressed: () {}),
          IconButton(icon: const Icon(Icons.share_outlined, color: Colors.white, size: 20), onPressed: () {}),
          Container(
            margin: const EdgeInsets.only(right: 14),
            width: 32,
            height: 32,
            decoration: BoxDecoration(color: const Color(0xFFF7728B), borderRadius: BorderRadius.circular(8)),
            child: const Icon(Icons.person, color: Colors.black, size: 20),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Chip top
            Row(
              children: [
                Container(width: 6, height: 6, decoration: const BoxDecoration(color: KuroTheme.crimson, shape: BoxShape.circle)),
                const SizedBox(width: 6),
                Text(
                  '// AJUSTES DEL SISTEMA // 設定',
                  style: KuroTheme.mono(fontSize: 9.5, color: KuroTheme.crimson, fontWeight: FontWeight.w700),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text('CONFIGURACIÓN', style: KuroTheme.title(fontSize: 26)),
            const SizedBox(height: 4),
            Text(
              'Personaliza tu motor de lectura, almacenamiento local, apariencia y políticas.',
              style: KuroTheme.body(fontSize: 11.5, color: KuroTheme.textGrey),
            ),

            const SizedBox(height: 24),

            // 01 // VISUAL & DISPLAY
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('01 // VISUAL & DISPLAY', style: KuroTheme.mono(fontSize: 10, color: KuroTheme.textWhite, fontWeight: FontWeight.w700)),
                Text('ENGINE: KOMA-OLED', style: KuroTheme.mono(fontSize: 8.5, color: KuroTheme.textMuted)),
              ],
            ),
            const SizedBox(height: 10),

            _buildTile(
              icon: Icons.nightlight_round,
              title: 'Modo Kuro OLED',
              subtitle: 'Negro Absoluto // Modo Claro',
              trailing: GestureDetector(
                onTap: () => setState(() => _isOledMode = !_isOledMode),
                child: Container(
                  width: 24,
                  height: 24,
                  decoration: const BoxDecoration(color: KuroTheme.crimson, shape: BoxShape.circle),
                  child: const Icon(Icons.check, color: Colors.white, size: 16),
                ),
              ),
            ),
            const SizedBox(height: 8),
            _buildTile(
              icon: Icons.palette_outlined,
              title: 'Acento Cromático',
              subtitle: 'Carmesí Puro (#E11D48)',
              trailing: Row(
                children: [
                  Container(width: 10, height: 10, decoration: const BoxDecoration(color: KuroTheme.crimson, shape: BoxShape.circle)),
                  const SizedBox(width: 6),
                  Text('ACTIVO', style: KuroTheme.mono(fontSize: 8.5, color: KuroTheme.textWhite, fontWeight: FontWeight.w700)),
                ],
              ),
            ),
            const SizedBox(height: 8),
            _buildTile(
              icon: Icons.contrast,
              title: 'Contraste Koma Cine',
              subtitle: 'Realce dinámico de tramas',
              trailing: Container(
                width: 26,
                height: 26,
                decoration: const BoxDecoration(color: KuroTheme.crimson, shape: BoxShape.circle),
                child: const Icon(Icons.tune, color: Colors.white, size: 14),
              ),
            ),

            const SizedBox(height: 24),

            // 02 // CACHÉ & STORAGE
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('02 // CACHÉ & STORAGE', style: KuroTheme.mono(fontSize: 10, color: KuroTheme.textWhite, fontWeight: FontWeight.w700)),
                Text('NVME BUFFER', style: KuroTheme.mono(fontSize: 8.5, color: KuroTheme.cyan)),
              ],
            ),
            const SizedBox(height: 10),

            Container(
              padding: const EdgeInsets.all(14),
              decoration: KuroTheme.cardDecoration(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(color: KuroTheme.cardLighter, borderRadius: BorderRadius.circular(8)),
                        child: const Icon(Icons.inventory_2_outlined, color: KuroTheme.textWhite, size: 16),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Capítulos & Miniaturas', style: GoogleFonts.spaceGrotesk(fontSize: 13, fontWeight: FontWeight.w700, color: Colors.white)),
                            Text('$_cacheUsed GB usados en 12 tomos y búfer temporal.', style: KuroTheme.body(fontSize: 10, color: KuroTheme.textGrey)),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('ESPACIO EN DISCO UTILIZADO', style: KuroTheme.mono(fontSize: 8.5, color: KuroTheme.textMuted)),
                      Text('28.4%', style: KuroTheme.mono(fontSize: 9, color: KuroTheme.textWhite, fontWeight: FontWeight.w700)),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Container(
                    height: 4,
                    decoration: BoxDecoration(color: KuroTheme.cardLighter, borderRadius: BorderRadius.circular(2)),
                    child: Row(
                      children: [
                        Expanded(flex: 28, child: Container(decoration: BoxDecoration(color: KuroTheme.crimson, borderRadius: BorderRadius.circular(2)))),
                        const Expanded(flex: 72, child: SizedBox()),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _showConfirmPurge = true;
                      });
                    },
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        color: KuroTheme.cardLighter,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: KuroTheme.crimson.withValues(alpha: 0.4)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.delete_outline, color: KuroTheme.crimson, size: 16),
                          const SizedBox(width: 6),
                          Text('LIMPIAR CACHÉ LOCAL', style: KuroTheme.mono(fontSize: 9.5, color: KuroTheme.crimson, fontWeight: FontWeight.w700)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Confirm Clean Modal
            if (_showConfirmPurge) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: KuroTheme.cardDecoration(
                  color: const Color(0xFF1E1822),
                  borderColor: KuroTheme.crimson.withValues(alpha: 0.6),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.warning_amber_rounded, color: KuroTheme.crimson, size: 18),
                        const SizedBox(width: 8),
                        Text('¿Confirmar Limpieza de Caché?', style: GoogleFonts.spaceGrotesk(fontSize: 14, fontWeight: FontWeight.w800, color: Colors.white)),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Se liberarán $_cacheUsed GB de memoria caché. Los capítulos guardados para lectura sin conexión deberán descargarse nuevamente.',
                      style: KuroTheme.body(fontSize: 10.5, color: KuroTheme.textGrey),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () => setState(() => _showConfirmPurge = false),
                            child: Container(
                              height: 38,
                              decoration: BoxDecoration(color: KuroTheme.cardLighter, borderRadius: BorderRadius.circular(8)),
                              child: Center(
                                child: Text('CANCELAR', style: KuroTheme.mono(fontSize: 10, color: KuroTheme.textGrey)),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                _cacheUsed = 0.05;
                                _showConfirmPurge = false;
                              });
                              Fluttertoast.showToast(msg: 'Caché liberado con éxito');
                            },
                            child: Container(
                              height: 38,
                              decoration: BoxDecoration(color: KuroTheme.crimson, borderRadius: BorderRadius.circular(8)),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(Icons.bolt, color: Colors.white, size: 14),
                                  const SizedBox(width: 4),
                                  Text('CONFIRMAR Y PURGAR', style: KuroTheme.mono(fontSize: 9, color: Colors.white, fontWeight: FontWeight.w800)),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 24),

            // 03 // LEGAL & PROTOCOLO
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('03 // LEGAL & TÉRMINOS', style: KuroTheme.mono(fontSize: 10, color: KuroTheme.textWhite, fontWeight: FontWeight.w700)),
                Text('JURISDICCIÓN JP/GL', style: KuroTheme.mono(fontSize: 8.5, color: KuroTheme.textMuted)),
              ],
            ),
            const SizedBox(height: 10),
            _buildTile(icon: Icons.shield_outlined, title: 'Políticas de Privacidad', subtitle: 'Actualizado Feb 2025', trailing: const Icon(Icons.arrow_forward_ios, color: KuroTheme.textMuted, size: 12)),
            const SizedBox(height: 8),
            _buildTile(icon: Icons.gavel_outlined, title: 'Términos de Servicio', subtitle: 'Avisos Legales y Licencias', trailing: const Icon(Icons.arrow_forward_ios, color: KuroTheme.textMuted, size: 12)),
            const SizedBox(height: 8),
            _buildTile(icon: Icons.verified_user_outlined, title: 'Licencias & Scans', subtitle: 'Código Abierto y Editorial Kuro', trailing: const Icon(Icons.arrow_forward_ios, color: KuroTheme.textMuted, size: 12)),

            const SizedBox(height: 24),

            // 04 // KERNEL & RUNTIME
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('04 // KERNEL & RUNTIME', style: KuroTheme.mono(fontSize: 10, color: KuroTheme.textWhite, fontWeight: FontWeight.w700)),
                Text('BUILD 894', style: KuroTheme.mono(fontSize: 8.5, color: KuroTheme.textMuted)),
              ],
            ),
            const SizedBox(height: 10),
            _buildTile(
              icon: Icons.memory,
              title: 'Versión Kuro',
              subtitle: 'Kuro v2.4.1 (Canary / Stable)',
              trailing: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(color: KuroTheme.cardLighter, borderRadius: BorderRadius.circular(4)),
                child: Text('v2.4.1', style: KuroTheme.mono(fontSize: 9, color: KuroTheme.textGrey)),
              ),
            ),
            const SizedBox(height: 8),
            _buildTile(
              icon: Icons.check_circle_outline,
              title: 'Motor Koma Cinematic Core v4.2',
              subtitle: 'Renderizado vectorial activo',
              trailing: Text('AL DÍA', style: KuroTheme.mono(fontSize: 9, color: KuroTheme.cyan, fontWeight: FontWeight.w800)),
            ),
            const SizedBox(height: 12),
            GestureDetector(
              onTap: () {
                Fluttertoast.showToast(msg: 'El sistema Kuro v2.4.1 se encuentra actualizado');
              },
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: KuroTheme.cardLighter,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: KuroTheme.border),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.refresh, color: Colors.white, size: 16),
                    const SizedBox(width: 8),
                    Text('BUSCAR ACTUALIZACIONES', style: KuroTheme.mono(fontSize: 9.5, color: Colors.white, fontWeight: FontWeight.w700)),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 30),

            Center(
              child: Text(
                '黒 // KURO CYBER-EDITORIAL ARCHIVE\nTOKYO / SHINJUKU • 2025 ALL RIGHTS RESERVED',
                textAlign: TextAlign.center,
                style: KuroTheme.mono(fontSize: 8.5, color: KuroTheme.textMuted, letterSpacing: 1.0),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required Widget trailing,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
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
                Text(title, style: GoogleFonts.spaceGrotesk(fontSize: 13, fontWeight: FontWeight.w700, color: Colors.white)),
                Text(subtitle, style: KuroTheme.body(fontSize: 10, color: KuroTheme.textMuted)),
              ],
            ),
          ),
          trailing,
        ],
      ),
    );
  }
}
