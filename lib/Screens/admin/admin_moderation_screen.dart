import 'package:aplicacion_manga/theme/kuro_theme.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';

class KuroAdminModerationScreen extends StatefulWidget {
  const KuroAdminModerationScreen({Key? key}) : super(key: key);

  @override
  State<KuroAdminModerationScreen> createState() => _KuroAdminModerationScreenState();
}

class _KuroAdminModerationScreenState extends State<KuroAdminModerationScreen> {
  int _selectedFilter = 0; // 0: TODOS 14, 1: REPORTADOS 9, 2: CRÍTICAS 3

  final List<Map<String, dynamic>> _reports = [
    {
      'manga': 'Berserk: Souls',
      'cap': 'CAPÍTULO 142 • PÁG. 18',
      'badge': 'SPOILER ×3',
      'badgeColor': KuroTheme.crimson,
      'user': 'griffith_stan',
      'lvl': 'LV.24',
      'avatar': 'images/admin_crops/mod_user_1.png',
      'tag': '@falcon_eye • Clan Halcón • Hace 12m',
      'extraBadge': 'Reincidente 2x',
      'warning': 'TEXTO SIN MÁSCARA REVELADO',
      'text': '"No puedo creer que en la última viñeta Guts pierda el amuleto y Casca recupere la memoria completa justo frente a él, arruinaron el arco."',
      'actions': ['Tag Spoiler', 'SANCIONAR', 'APROBAR'],
    },
    {
      'manga': 'Vagabond: Kensei',
      'cap': 'CRÍTICA GLOBAL • CAP. 88',
      'badge': 'AGRESIÓN SCAN',
      'badgeColor': KuroTheme.crimson,
      'user': 'ronin_hater',
      'lvl': 'LV.08',
      'avatar': 'images/admin_crops/mod_user_2.png',
      'tag': '@ronin_99 • Sin Clan • Hace 34m',
      'extraBadge': 'IA Flagged (0.94)',
      'warning': 'VIOLACIÓN TÉRMINOS COMUNIDAD',
      'text': '"Los editores de este capítulo son unos incompetentes totales, deberían cerrar el grupo y dejar que gente con cerebro traduzca esto, denles ban ya."',
      'actions': ['Mute 24h', 'PURGAR', 'DESCARTAR'],
    },
    {
      'manga': 'Chainsaw Legacy',
      'cap': 'CAPÍTULO 164 • SECCIÓN COM...',
      'badge': 'BOT SCAN',
      'badgeColor': KuroTheme.purple,
      'user': 'free_manga_bot',
      'lvl': 'NUEVO',
      'avatar': 'images/admin_crops/mod_user_3.png',
      'tag': '@scan_leak_hq • IP Sospechosa • Autoban Sugerido',
      'extraBadge': 'Autoban',
      'warning': 'ENLACE EXTERNO NO AUTORIZADO',
      'text': '"Leer capítulo 165 filtrado en RAW gratis sin censura aquí -> https://kuro-mirror-free.xyz/leak-165 descarga directa."',
      'actions': ['IP Blacklist', 'BAN INSTANTÁNEO', 'IGNORAR'],
    },
    {
      'manga': 'Tokyo Ghoul: Re',
      'cap': 'CAPÍTULO 179 • FIN...',
      'badge': 'CASO LÍMITE (1)',
      'badgeColor': KuroTheme.cardLighter,
      'user': 'Kenji_Otaku',
      'lvl': 'VIP III',
      'avatar': 'images/admin_crops/mod_user_4.png',
      'tag': '@kenji99 • Clan Sombra • Hace 2h',
      'extraBadge': 'Sin Infracciones',
      'warning': 'REPORTADO POR TONO CRÍTICO',
      'text': '"Las páginas 14 y 15 tienen una compresión horrible en móvil, casi no se leen los globos de diálogo de Kaneki. Por favor revisen la exportación en HD."',
      'actions': ['Enviar a Scans', 'OCULTAR', 'APROBAR FEEDBACK'],
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: KuroTheme.background,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: KuroTheme.background,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('KURO ADMIN // SEC-09', style: KuroTheme.mono(fontSize: 8.5, color: KuroTheme.cyan, fontWeight: FontWeight.w700)),
            Text('MODERACIÓN...', style: GoogleFonts.spaceGrotesk(fontSize: 16, fontWeight: FontWeight.w800, color: Colors.white)),
          ],
        ),
        actions: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
            decoration: BoxDecoration(color: KuroTheme.crimson.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(4)),
            child: Row(
              children: [
                Container(width: 5, height: 5, decoration: const BoxDecoration(color: KuroTheme.crimson, shape: BoxShape.circle)),
                const SizedBox(width: 4),
                Text('14 Q', style: KuroTheme.mono(fontSize: 9, color: KuroTheme.crimson, fontWeight: FontWeight.w800)),
              ],
            ),
          ),
          IconButton(icon: const Icon(Icons.tune, color: Colors.white, size: 18), onPressed: () {}),
          Container(
            margin: const EdgeInsets.only(right: 14),
            width: 32,
            height: 32,
            decoration: BoxDecoration(color: const Color(0xFFF7728B), borderRadius: BorderRadius.circular(8)),
            child: const Icon(Icons.person, color: Colors.black, size: 18),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Telemetry Bar
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(width: 4, height: 12, color: KuroTheme.crimson),
                            const SizedBox(width: 6),
                            Text('COLA DE MODERACIÓN DE COMENTARIOS', style: KuroTheme.mono(fontSize: 9.5, color: KuroTheme.textWhite, fontWeight: FontWeight.w700)),
                          ],
                        ),
                        Text('SYNC: LIVE 99.8%', style: KuroTheme.mono(fontSize: 8.5, color: KuroTheme.cyan)),
                      ],
                    ),

                    const SizedBox(height: 10),

                    // 3 Metric Boxes: PENDIENTES 14 | SPOILERS 08 | TOXIC/SPAM 06
                    Row(
                      children: [
                        _buildTeleBox('PENDIENTES', '14', '総数 (Cola Total)', KuroTheme.crimson),
                        const SizedBox(width: 8),
                        _buildTeleBox('SPOILERS', '08', 'ネタバレ (Graves)', KuroTheme.cyan),
                        const SizedBox(width: 8),
                        _buildTeleBox('TOXIC/SPAM', '06', '有害 (Automarcado)', KuroTheme.purple),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // Filter Pills
                    Row(
                      children: [
                        _buildFilterPill('TODOS 14', 0),
                        const SizedBox(width: 8),
                        _buildFilterPill('REPORTADOS 9', 1),
                        const SizedBox(width: 8),
                        _buildFilterPill('CRÍTICAS 3', 2),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // Report Cards List
                    ..._reports.map((rep) => _buildModerationCard(rep)).toList(),

                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),

            // Bottom Action Footer
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: const BoxDecoration(
                color: KuroTheme.backgroundSecondary,
                border: Border(top: BorderSide(color: KuroTheme.border)),
              ),
              child: Row(
                children: [
                  Row(
                    children: [
                      Container(width: 6, height: 6, decoration: const BoxDecoration(color: KuroTheme.crimson, shape: BoxShape.circle)),
                      const SizedBox(width: 6),
                      Text('NODE // 10 repo...', style: KuroTheme.mono(fontSize: 8.5, color: KuroTheme.textMuted)),
                    ],
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    decoration: BoxDecoration(color: KuroTheme.cardLighter, borderRadius: BorderRadius.circular(6)),
                    child: Row(
                      children: [
                        const Icon(Icons.low_priority, color: Colors.white, size: 14),
                        const SizedBox(width: 4),
                        Text('MÚLTIPLE', style: KuroTheme.mono(fontSize: 9, color: Colors.white, fontWeight: FontWeight.w700)),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: () {
                      Fluttertoast.showToast(msg: 'Auto-resolución de reportes IA completada');
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(color: KuroTheme.crimson, borderRadius: BorderRadius.circular(6)),
                      child: Row(
                        children: [
                          const Icon(Icons.bolt, color: Colors.white, size: 14),
                          const SizedBox(width: 4),
                          Text('AUTO-RESOLVER', style: KuroTheme.mono(fontSize: 9, color: Colors.white, fontWeight: FontWeight.w800)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTeleBox(String label, String count, String sub, Color countColor) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: KuroTheme.cardDecoration(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: KuroTheme.mono(fontSize: 7.5, color: KuroTheme.textMuted, fontWeight: FontWeight.w700)),
            const SizedBox(height: 2),
            Text(count, style: GoogleFonts.spaceGrotesk(fontSize: 20, fontWeight: FontWeight.w900, color: countColor)),
            Text(sub, style: KuroTheme.mono(fontSize: 7, color: KuroTheme.textMuted), maxLines: 1),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterPill(String title, int idx) {
    final isSelected = _selectedFilter == idx;
    return GestureDetector(
      onTap: () => setState(() => _selectedFilter = idx),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? KuroTheme.crimson : KuroTheme.card,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: isSelected ? KuroTheme.crimson : KuroTheme.border),
        ),
        child: Text(
          title,
          style: KuroTheme.mono(fontSize: 8.5, color: isSelected ? Colors.white : KuroTheme.textGrey, fontWeight: FontWeight.w700),
        ),
      ),
    );
  }

  Widget _buildModerationCard(Map<String, dynamic> rep) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(14),
      decoration: KuroTheme.cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: Image.network('https://images.unsplash.com/photo-1578632767115-351597cf2477?w=800', width: 22, height: 22, fit: BoxFit.cover),
                  ),
                  const SizedBox(width: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(rep['manga'] as String, style: GoogleFonts.spaceGrotesk(fontSize: 12, fontWeight: FontWeight.w700, color: Colors.white)),
                      Text(rep['cap'] as String, style: KuroTheme.mono(fontSize: 7.5, color: KuroTheme.textMuted)),
                    ],
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: (rep['badgeColor'] as Color).withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: rep['badgeColor'] as Color),
                ),
                child: Text(rep['badge'] as String, style: KuroTheme.mono(fontSize: 7.5, color: rep['badgeColor'] as Color, fontWeight: FontWeight.w800)),
              ),
            ],
          ),

          const SizedBox(height: 10),

          // User info row
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: KuroTheme.cardLighter, borderRadius: BorderRadius.circular(6)),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.asset(
                    rep['avatar'] as String,
                    width: 24,
                    height: 24,
                    fit: BoxFit.cover,
                    errorBuilder: (ctx, err, stack) => Container(
                      width: 24,
                      height: 24,
                      decoration: const BoxDecoration(color: KuroTheme.crimson, shape: BoxShape.circle),
                      child: const Center(child: Text('!', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13))),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(rep['user'] as String, style: KuroTheme.mono(fontSize: 9.5, color: Colors.white, fontWeight: FontWeight.w700)),
                          const SizedBox(width: 4),
                          Text(rep['lvl'] as String, style: KuroTheme.mono(fontSize: 8, color: KuroTheme.textMuted)),
                        ],
                      ),
                      Text(rep['tag'] as String, style: KuroTheme.mono(fontSize: 7.5, color: KuroTheme.cyan)),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                  decoration: BoxDecoration(color: Colors.black.withValues(alpha: 0.4), borderRadius: BorderRadius.circular(4)),
                  child: Text(rep['extraBadge'] as String, style: KuroTheme.mono(fontSize: 7.5, color: KuroTheme.textGrey)),
                ),
              ],
            ),
          ),

          const SizedBox(height: 8),

          Text(rep['warning'] as String, style: KuroTheme.mono(fontSize: 7.5, color: KuroTheme.crimson, fontWeight: FontWeight.w800)),
          const SizedBox(height: 4),
          Text(rep['text'] as String, style: KuroTheme.body(fontSize: 10.5, color: KuroTheme.textWhite, height: 1.35)),

          const SizedBox(height: 12),

          // Action Buttons
          Row(
            children: [
              Expanded(
                child: Container(
                  height: 32,
                  decoration: BoxDecoration(color: KuroTheme.cardLighter, borderRadius: BorderRadius.circular(6)),
                  child: Center(
                    child: Text(rep['actions'][0] as String, style: KuroTheme.mono(fontSize: 8.5, color: KuroTheme.textGrey)),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    Fluttertoast.showToast(msg: 'Acción ejecutada');
                  },
                  child: Container(
                    height: 32,
                    decoration: BoxDecoration(color: KuroTheme.crimson, borderRadius: BorderRadius.circular(6)),
                    child: Center(
                      child: Text(rep['actions'][1] as String, style: KuroTheme.mono(fontSize: 8.5, color: Colors.white, fontWeight: FontWeight.w800)),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    Fluttertoast.showToast(msg: 'Comentario aprobado');
                  },
                  child: Container(
                    height: 32,
                    decoration: BoxDecoration(color: KuroTheme.cyan.withValues(alpha: 0.25), borderRadius: BorderRadius.circular(6), border: Border.all(color: KuroTheme.cyan)),
                    child: Center(
                      child: Text(rep['actions'][2] as String, style: KuroTheme.mono(fontSize: 8.5, color: KuroTheme.cyan, fontWeight: FontWeight.w800)),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

