import 'package:aplicacion_manga/services/admin_service.dart';
import 'package:aplicacion_manga/theme/kuro_theme.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';

class KuroAdminModerationScreen extends StatefulWidget {
  final bool isEmbedded;
  final VoidCallback? onBack;

  const KuroAdminModerationScreen({
    Key? key,
    this.isEmbedded = false,
    this.onBack,
  }) : super(key: key);

  @override
  State<KuroAdminModerationScreen> createState() =>
      _KuroAdminModerationScreenState();
}

class _KuroAdminModerationScreenState extends State<KuroAdminModerationScreen> {
  int _selectedFilter = 0; // 0: TODOS, 1: REPORTADOS, 2: CRÍTICAS
  List<Map<String, dynamic>> _reports = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _cargarReportes();
  }

  void _cargarReportes() async {
    try {
      final snap = await FirebaseFirestore.instance
          .collection('comentarios')
          .where('reportado', isEqualTo: true)
          .get();

      if (snap.docs.isNotEmpty && mounted) {
        setState(() {
          _reports = snap.docs.map((doc) {
            final data = doc.data();
            final userStr = data['autor'] ?? data['usuario'] ?? 'usuario_anonimo';
            return {
              'docId': doc.id,
              'manga': data['mangaTitle'] ?? 'Manga en Catálogo',
              'cap': data['capitulo'] ?? 'Capítulo',
              'badge': data['motivo'] ?? 'SPOILER / REPORTE',
              'badgeColor': KuroTheme.crimson,
              'user': userStr,
              'lvl': data['rango'] ?? 'LECTOR',
              'tag': '@$userStr • Hace unos momentos',
              'extraBadge': 'Reportado por Lectores',
              'warning': (data['motivo'] ?? 'VIOLACIÓN TÉRMINOS COMUNIDAD')
                  .toString()
                  .toUpperCase(),
              'text': data['comentario'] ?? data['contenido'] ?? '(Comentario vacío)',
              'actions': ['Tag Spoiler', 'SANCIONAR', 'APROBAR'],
            };
          }).toList();
          _isLoading = false;
        });
        return;
      }
    } catch (_) {}

    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: KuroTheme.background,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: KuroTheme.background,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white, size: 20),
          onPressed: () {
            if (widget.onBack != null) {
              widget.onBack!();
            } else if (Navigator.canPop(context)) {
              Navigator.pop(context);
            }
          },
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('KURO ADMIN // SEC-09',
                style: KuroTheme.mono(
                    fontSize: 8.5,
                    color: KuroTheme.cyan,
                    fontWeight: FontWeight.w700)),
            Text('MODERACIÓN...',
                style: GoogleFonts.spaceGrotesk(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: Colors.white)),
          ],
        ),
        actions: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
            decoration: BoxDecoration(
                color: KuroTheme.crimson.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(4)),
            child: Row(
              children: [
                Container(
                    width: 5,
                    height: 5,
                    decoration: const BoxDecoration(
                        color: KuroTheme.crimson, shape: BoxShape.circle)),
                const SizedBox(width: 4),
                Text('${_reports.length} Q',
                    style: KuroTheme.mono(
                        fontSize: 9,
                        color: KuroTheme.crimson,
                        fontWeight: FontWeight.w800)),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white, size: 18),
            onPressed: () {
              setState(() => _isLoading = true);
              _cargarReportes();
            },
          ),
          const SizedBox(width: 14),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Telemetry Bar
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Row(
                            children: [
                              Container(
                                  width: 4, height: 12, color: KuroTheme.crimson),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text('COLA DE MODERACIÓN DE COMENTARIOS',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: KuroTheme.mono(
                                        fontSize: 9.5,
                                        color: KuroTheme.textWhite,
                                        fontWeight: FontWeight.w700)),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text('SYNC: FIRESTORE',
                            style: KuroTheme.mono(
                                fontSize: 8.5, color: KuroTheme.cyan)),
                      ],
                    ),

                    const SizedBox(height: 10),

                    // Filter Pills: TODOS | REPORTADOS | CRÍTICAS
                    Row(
                      children: [
                        _buildFilterPill('TODOS (${_reports.length})', 0),
                        const SizedBox(width: 8),
                        _buildFilterPill('REPORTADOS', 1),
                        const SizedBox(width: 8),
                        _buildFilterPill('CRÍTICAS', 2),
                      ],
                    ),

                    const SizedBox(height: 14),

                    // Lista de Reportes o Estado Vacío
                    if (_isLoading)
                      const Center(
                        child: Padding(
                          padding: EdgeInsets.all(40),
                          child: CircularProgressIndicator(
                              color: KuroTheme.crimson),
                        ),
                      )
                    else if (_reports.isEmpty)
                      Center(
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 24, vertical: 36),
                          margin: const EdgeInsets.symmetric(vertical: 20),
                          decoration: KuroTheme.cardDecoration(),
                          child: Column(
                            children: [
                              Container(
                                width: 56,
                                height: 56,
                                decoration: BoxDecoration(
                                  color: KuroTheme.cyan.withValues(alpha: 0.15),
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                      color: KuroTheme.cyan
                                          .withValues(alpha: 0.4)),
                                ),
                                child: const Icon(Icons.verified_user_outlined,
                                    color: KuroTheme.cyan, size: 30),
                              ),
                              const SizedBox(height: 14),
                              Text('COLA DE MODERACIÓN LIMPIA',
                                  style: GoogleFonts.spaceGrotesk(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w800,
                                      color: Colors.white)),
                              const SizedBox(height: 6),
                              Text(
                                'No hay comentarios con reportes de spoilers o agresiones pendientes de revisión.',
                                textAlign: TextAlign.center,
                                style: KuroTheme.body(
                                    fontSize: 11, color: KuroTheme.textMuted),
                              ),
                              const SizedBox(height: 16),
                              TextButton.icon(
                                onPressed: () {
                                  setState(() => _isLoading = true);
                                  _cargarReportes();
                                },
                                icon: const Icon(Icons.refresh,
                                    size: 14, color: KuroTheme.cyan),
                                label: Text('RECARGAR DESDE FIRESTORE',
                                    style: KuroTheme.mono(
                                        fontSize: 9,
                                        color: KuroTheme.cyan,
                                        fontWeight: FontWeight.w800)),
                              ),
                            ],
                          ),
                        ),
                      )
                    else
                      Column(
                        children: _reports
                            .asMap()
                            .entries
                            .map((e) => _buildModerationCard(e.value, e.key))
                            .toList(),
                      ),

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
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
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
                        Text('NODE // ${_reports.length} reportes',
                            style: KuroTheme.mono(
                                fontSize: 8.5, color: KuroTheme.textMuted)),
                      ],
                    ),
                    const SizedBox(width: 16),
                    GestureDetector(
                      onTap: () async {
                        if (_reports.isEmpty) {
                          Fluttertoast.showToast(msg: 'No hay reportes que resolver');
                          return;
                        }
                        setState(() {
                          _reports.clear();
                        });
                        await KuroAdminBackendService.instance
                            .autoResolveAllReports();
                        Fluttertoast.showToast(
                            msg: 'Auto-resolución completada en Firestore: Cola limpia');
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                            color: KuroTheme.crimson,
                            borderRadius: BorderRadius.circular(6)),
                        child: Row(
                          children: [
                            const Icon(Icons.bolt,
                                color: Colors.white, size: 14),
                            const SizedBox(width: 4),
                            Text('AUTO-RESOLVER TODO',
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
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterPill(String text, int index) {
    final isSelected = _selectedFilter == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedFilter = index),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? KuroTheme.crimson : KuroTheme.cardLighter,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
              color: isSelected ? KuroTheme.crimson : KuroTheme.border),
        ),
        child: Text(
          text,
          style: KuroTheme.mono(
            fontSize: 9,
            color: isSelected ? Colors.white : KuroTheme.textGrey,
            fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildModerationCard(Map<String, dynamic> rep, int index) {
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
              Expanded(
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: Container(
                        width: 24,
                        height: 24,
                        color: KuroTheme.cardLighter,
                        child: const Icon(Icons.book,
                            size: 14, color: KuroTheme.crimson),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(rep['manga'] as String,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.spaceGrotesk(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white)),
                          Text(rep['cap'] as String,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: KuroTheme.mono(
                                  fontSize: 7.5, color: KuroTheme.textMuted)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: (rep['badgeColor'] as Color).withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: rep['badgeColor'] as Color),
                ),
                child: Text(rep['badge'] as String,
                    style: KuroTheme.mono(
                        fontSize: 7.5,
                        color: rep['badgeColor'] as Color,
                        fontWeight: FontWeight.w800)),
              ),
            ],
          ),

          const SizedBox(height: 10),

          // User Info Row
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
                color: KuroTheme.cardLighter,
                borderRadius: BorderRadius.circular(6)),
            child: Row(
              children: [
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                      color: KuroTheme.card,
                      shape: BoxShape.circle,
                      border: Border.all(color: KuroTheme.border)),
                  child: const Icon(Icons.person,
                      color: KuroTheme.textGrey, size: 14),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(rep['user'] as String,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: KuroTheme.mono(
                                    fontSize: 9.5,
                                    color: Colors.white,
                                    fontWeight: FontWeight.w700)),
                          ),
                          const SizedBox(width: 4),
                          Text(rep['lvl'] as String,
                              style: KuroTheme.mono(
                                  fontSize: 8, color: KuroTheme.textMuted)),
                        ],
                      ),
                      Text(rep['tag'] as String,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: KuroTheme.mono(
                              fontSize: 7.5, color: KuroTheme.cyan)),
                    ],
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                  decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.4),
                      borderRadius: BorderRadius.circular(4)),
                  child: Text(rep['extraBadge'] as String,
                      style: KuroTheme.mono(
                          fontSize: 7.5, color: KuroTheme.textGrey)),
                ),
              ],
            ),
          ),

          const SizedBox(height: 8),

          Text(rep['warning'] as String,
              style: KuroTheme.mono(
                  fontSize: 7.5,
                  color: KuroTheme.crimson,
                  fontWeight: FontWeight.w800)),
          const SizedBox(height: 4),
          Text(rep['text'] as String,
              style: KuroTheme.body(
                  fontSize: 10.5, color: KuroTheme.textWhite, height: 1.35)),

          const SizedBox(height: 12),

          // Action Buttons
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    KuroAdminBackendService.instance.applyModerationAction(
                      commentId: rep['docId'] ?? 'report_$index',
                      action: 'tag_spoiler',
                    );
                    setState(() {
                      _reports.removeAt(index);
                    });
                    Fluttertoast.showToast(msg: 'Máscara de spoiler aplicada');
                  },
                  child: Container(
                    height: 32,
                    decoration: BoxDecoration(
                        color: KuroTheme.cardLighter,
                        borderRadius: BorderRadius.circular(6)),
                    child: Center(
                      child: Text('Tag Spoiler',
                          style: KuroTheme.mono(
                              fontSize: 8.5, color: KuroTheme.textGrey)),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    final user = rep['user'];
                    KuroAdminBackendService.instance.applyModerationAction(
                      commentId: rep['docId'] ?? 'report_$index',
                      action: 'sancionar',
                      userEmail: '$user@kuro.manga',
                    );
                    setState(() {
                      _reports.removeAt(index);
                    });
                    Fluttertoast.showToast(
                        msg: 'Sanción aplicada a $user en base de datos');
                  },
                  child: Container(
                    height: 32,
                    decoration: BoxDecoration(
                        color: KuroTheme.crimson,
                        borderRadius: BorderRadius.circular(6)),
                    child: Center(
                      child: Text('SANCIONAR',
                          style: KuroTheme.mono(
                              fontSize: 8.5,
                              color: Colors.white,
                              fontWeight: FontWeight.w800)),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    final manga = rep['manga'];
                    KuroAdminBackendService.instance.applyModerationAction(
                      commentId: rep['docId'] ?? 'report_$index',
                      action: 'aprobar',
                    );
                    setState(() {
                      _reports.removeAt(index);
                    });
                    Fluttertoast.showToast(msg: 'Comentario aprobado en $manga');
                  },
                  child: Container(
                    height: 32,
                    decoration: BoxDecoration(
                        color: KuroTheme.cyan.withValues(alpha: 0.25),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: KuroTheme.cyan)),
                    child: Center(
                      child: Text('APROBAR',
                          style: KuroTheme.mono(
                              fontSize: 8.5,
                              color: KuroTheme.cyan,
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
  }
}
