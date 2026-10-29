import 'package:aplicacion_manga/theme/kuro_theme.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';

class KuroAdminUploadScreen extends StatefulWidget {
  const KuroAdminUploadScreen({Key? key}) : super(key: key);

  @override
  State<KuroAdminUploadScreen> createState() => _KuroAdminUploadScreenState();
}

class _KuroAdminUploadScreenState extends State<KuroAdminUploadScreen> {
  final tomoController = TextEditingController(text: 'Tomo 42');
  final capController = TextEditingController(text: 'Capitulo 143');
  final nombreCapController = TextEditingController(text: 'El Despertar del Behemoth');
  
  bool _visibilidadInmediata = true;
  bool _notificarLectores = true;
  bool _isUploading = false;

  final List<String> _tags = ['Dark Fantasy', 'Seinen', 'Psicológico', 'Gore', 'Acción'];
  final Set<String> _selectedTags = {'Dark Fantasy', 'Seinen', 'Psicológico'};

  Future<void> _publicarCapitulo() async {
    setState(() => _isUploading = true);

    try {
      // Registrar en Firestore en la colección 'mangas' o subcolección 'capitulos'
      await FirebaseFirestore.instance.collection('mangas').add({
        'title': 'Berserk: ${tomoController.text.trim()}',
        'imageUrl': 'https://images.unsplash.com/photo-1578632767115-351597cf2477?w=800',
        'mangaCategoryName': 'Dark Fantasy',
        'type': 'SEINEN • RAW',
        'numberPages': '42',
        'pdfUrl': 'https://www.w3.org/WAI/ER/tests/xhtml/testfiles/resources/pdf/dummy.pdf',
        'capitulo': capController.text.trim(),
        'nombreCapitulo': nombreCapController.text.trim(),
        'fecha_subida': FieldValue.serverTimestamp(),
      });

      setState(() => _isUploading = false);

      Fluttertoast.showToast(
        msg: 'Capítulo sincronizado y publicado en Firestore exitosamente',
        backgroundColor: KuroTheme.crimson,
      );

      if (mounted) Navigator.pop(context);
    } catch (e) {
      setState(() => _isUploading = false);
      Fluttertoast.showToast(msg: 'Error al sincronizar: $e');
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
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'MANGA DET...',
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
            // Top Chips: PIPELINE: ACTIVO | ROOT ADMIN | KURO-INGEST v4.2
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                  decoration: BoxDecoration(color: KuroTheme.crimson.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(4)),
                  child: Row(
                    children: [
                      Container(width: 5, height: 5, decoration: const BoxDecoration(color: KuroTheme.crimson, shape: BoxShape.circle)),
                      const SizedBox(width: 5),
                      Text('PIPELINE: ACTIVO', style: KuroTheme.mono(fontSize: 8, color: KuroTheme.crimson, fontWeight: FontWeight.w800)),
                    ],
                  ),
                ),
                const SizedBox(width: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                  decoration: BoxDecoration(color: KuroTheme.cardLighter, borderRadius: BorderRadius.circular(4)),
                  child: Text('ROOT ADMIN', style: KuroTheme.mono(fontSize: 8, color: KuroTheme.textGrey)),
                ),
                const SizedBox(width: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                  decoration: BoxDecoration(color: KuroTheme.cyan.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(4)),
                  child: Row(
                    children: [
                      const Icon(Icons.bolt, color: KuroTheme.cyan, size: 10),
                      Text('KURO-INGEST v4.2', style: KuroTheme.mono(fontSize: 8, color: KuroTheme.cyan, fontWeight: FontWeight.w700)),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 8),

            Text('SUBIR CAPÍTULO // 新規投稿', style: KuroTheme.title(fontSize: 22)),
            const SizedBox(height: 4),
            Text(
              'Módulo de publicación de tomos y capítulos, compresión WebP/PDF y distribución a lectores.',
              style: KuroTheme.body(fontSize: 11, color: KuroTheme.textGrey),
            ),

            const SizedBox(height: 20),

            // Card 01. METADATOS DE LA OBRA
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
                          const Icon(Icons.menu_book, color: KuroTheme.crimson, size: 15),
                          const SizedBox(width: 6),
                          Text('01. METADATOS DE LA OBRA', style: KuroTheme.mono(fontSize: 9.5, color: KuroTheme.textWhite, fontWeight: FontWeight.w700)),
                        ],
                      ),
                      Text('SERIES_REQ: #BK-7702', style: KuroTheme.mono(fontSize: 8, color: KuroTheme.textMuted)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text('TÍTULO DE LA SERIE', style: KuroTheme.mono(fontSize: 8.5, color: KuroTheme.textMuted)),
                  const SizedBox(height: 6),

                  // Serie Selector Pill
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(color: KuroTheme.cardLighter, borderRadius: BorderRadius.circular(8)),
                    child: Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: Image.network('https://images.unsplash.com/photo-1578632767115-351597cf2477?w=800', width: 36, height: 46, fit: BoxFit.cover),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Berserk: Souls of the Eclipse', style: GoogleFonts.spaceGrotesk(fontSize: 13, fontWeight: FontWeight.w700, color: Colors.white)),
                              Text('Kentarō M. Legacy / Young Animal', style: KuroTheme.body(fontSize: 9.5, color: KuroTheme.textMuted)),
                            ],
                          ),
                        ),
                        const Icon(Icons.unfold_more, color: KuroTheme.textGrey, size: 18),
                      ],
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Volumen / Tomo & Nº de Capítulo
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('VOLUMEN / TOMO', style: KuroTheme.mono(fontSize: 8.5, color: KuroTheme.textMuted)),
                            const SizedBox(height: 6),
                            Container(
                              height: 44,
                              decoration: BoxDecoration(color: KuroTheme.cardLighter, borderRadius: BorderRadius.circular(8)),
                              padding: const EdgeInsets.symmetric(horizontal: 12),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: TextField(
                                      controller: tomoController,
                                      style: KuroTheme.mono(fontSize: 12, color: Colors.white, fontWeight: FontWeight.w700),
                                      decoration: const InputDecoration(border: InputBorder.none),
                                    ),
                                  ),
                                  const Icon(Icons.bookmark_border, color: KuroTheme.textMuted, size: 16),
                                ],
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
                            Text('Nº DE CAPÍTULO', style: KuroTheme.mono(fontSize: 8.5, color: KuroTheme.textMuted)),
                            const SizedBox(height: 6),
                            Container(
                              height: 44,
                              decoration: BoxDecoration(color: KuroTheme.cardLighter, borderRadius: BorderRadius.circular(8)),
                              padding: const EdgeInsets.symmetric(horizontal: 12),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: TextField(
                                      controller: capController,
                                      style: KuroTheme.mono(fontSize: 12, color: Colors.white, fontWeight: FontWeight.w700),
                                      decoration: const InputDecoration(border: InputBorder.none),
                                    ),
                                  ),
                                  Text('#', style: KuroTheme.mono(fontSize: 14, color: KuroTheme.crimson, fontWeight: FontWeight.w900)),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  Text('NOMBRE DEL CAPÍTULO', style: KuroTheme.mono(fontSize: 8.5, color: KuroTheme.textMuted)),
                  const SizedBox(height: 6),
                  Container(
                    height: 44,
                    decoration: BoxDecoration(color: KuroTheme.cardLighter, borderRadius: BorderRadius.circular(8)),
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: TextField(
                      controller: nombreCapController,
                      style: GoogleFonts.spaceGrotesk(fontSize: 13, color: Colors.white, fontWeight: FontWeight.w600),
                      decoration: const InputDecoration(border: InputBorder.none),
                    ),
                  ),

                  const SizedBox(height: 14),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('ETIQUETAS & GÉNEROS', style: KuroTheme.mono(fontSize: 8.5, color: KuroTheme.textMuted)),
                      Text('+ Tag Custom', style: KuroTheme.mono(fontSize: 8.5, color: KuroTheme.cyan)),
                    ],
                  ),
                  const SizedBox(height: 8),

                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: _tags.map((tag) {
                      final isSelected = _selectedTags.contains(tag);
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            if (isSelected) {
                              _selectedTags.remove(tag);
                            } else {
                              _selectedTags.add(tag);
                            }
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: isSelected ? KuroTheme.crimson : KuroTheme.cardLighter,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            isSelected ? '$tag ✓' : tag,
                            style: KuroTheme.mono(fontSize: 8.5, color: isSelected ? Colors.white : KuroTheme.textGrey, fontWeight: FontWeight.w700),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Card 02. PAQUETE DE ARCHIVO
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
                          const Icon(Icons.cloud_upload_outlined, color: KuroTheme.cyan, size: 16),
                          const SizedBox(width: 6),
                          Text('02. SUBIR CAPÍTULO (ZIP / CBZ / PDF)', style: KuroTheme.mono(fontSize: 9.5, color: KuroTheme.textWhite, fontWeight: FontWeight.w700)),
                        ],
                      ),
                      Row(
                        children: [
                          Container(width: 5, height: 5, decoration: const BoxDecoration(color: KuroTheme.crimson, shape: BoxShape.circle)),
                          const SizedBox(width: 5),
                          Text('LISTO PARA PROCESAR', style: KuroTheme.mono(fontSize: 8, color: KuroTheme.textMuted)),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Upload Dropzone
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
                    decoration: BoxDecoration(
                      color: KuroTheme.cardLighter,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: KuroTheme.border, style: BorderStyle.solid),
                    ),
                    child: Column(
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(color: KuroTheme.card, borderRadius: BorderRadius.circular(10)),
                          child: const Icon(Icons.upload_file, color: KuroTheme.crimson, size: 24),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'Arrastra el tomo o capítulo en ZIP o CBZ',
                          style: GoogleFonts.spaceGrotesk(fontSize: 14, fontWeight: FontWeight.w800, color: Colors.white),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'O presiona para seleccionar las páginas o el tomo desde tu dispositivo',
                          textAlign: TextAlign.center,
                          style: KuroTheme.body(fontSize: 10, color: KuroTheme.textMuted),
                        ),
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                          decoration: BoxDecoration(
                            color: KuroTheme.card,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: KuroTheme.border),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.folder_open, color: Colors.white, size: 16),
                              const SizedBox(width: 6),
                              Text('SELECCIONAR CAPÍTULO LOCAL', style: KuroTheme.mono(fontSize: 9, color: Colors.white, fontWeight: FontWeight.w700)),
                            ],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Formatos admitidos: PDF, CBZ, ZIP (PNG/WEBP) • Máx: 250 MB',
                          style: KuroTheme.mono(fontSize: 8, color: KuroTheme.textMuted),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Pill de archivo detectado
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(color: KuroTheme.cardLighter, borderRadius: BorderRadius.circular(8)),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.folder, color: KuroTheme.crimson, size: 18),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'berserk_cap143_raw',
                                style: KuroTheme.mono(fontSize: 10.5, color: Colors.white, fontWeight: FontWeight.w700),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                              decoration: BoxDecoration(color: KuroTheme.cyan.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(3)),
                              child: Text('OK', style: KuroTheme.mono(fontSize: 8, color: KuroTheme.cyan, fontWeight: FontWeight.w800)),
                            ),
                            const SizedBox(width: 8),
                            const Icon(Icons.replay, color: KuroTheme.textMuted, size: 16),
                            const SizedBox(width: 8),
                            const Icon(Icons.delete_outline, color: KuroTheme.crimson, size: 16),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text('68.4 MB • 42 páginas detectadas', style: KuroTheme.mono(fontSize: 8.5, color: KuroTheme.textMuted)),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.check_circle_outline, color: KuroTheme.cyan, size: 12),
                                const SizedBox(width: 4),
                                Text('Verificación 4K: Correcta', style: KuroTheme.mono(fontSize: 8.5, color: KuroTheme.textWhite)),
                              ],
                            ),
                            Text('3200 × 4800 px', style: KuroTheme.mono(fontSize: 8.5, color: KuroTheme.cyan)),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Container(height: 2, color: KuroTheme.cyan),
                      ],
                    ),
                  ),

                  const SizedBox(height: 12),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('PÁGINAS DE MUESTRA (1-3)', style: KuroTheme.mono(fontSize: 8.5, color: KuroTheme.textMuted)),
                      Text('Ver todas (42)', style: KuroTheme.mono(fontSize: 8.5, color: KuroTheme.cyan)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      _buildThumbPage('https://images.unsplash.com/photo-1578632767115-351597cf2477?w=800'),
                      const SizedBox(width: 8),
                      _buildThumbPage('https://images.unsplash.com/photo-1607604276583-eef5d076aa5f?w=800'),
                      const SizedBox(width: 8),
                      _buildThumbPage('https://e.rpp-noticias.io/xlarge/2018/11/22/484448_715070.jpg'),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Card 03. OPCIONES DE PIPELINE
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
                          const Icon(Icons.tune, color: KuroTheme.purple, size: 16),
                          const SizedBox(width: 6),
                          Text('03. OPCIONES DE PIPELINE', style: KuroTheme.mono(fontSize: 9.5, color: KuroTheme.textWhite, fontWeight: FontWeight.w700)),
                        ],
                      ),
                      Text('AUTO-DISTRIB', style: KuroTheme.mono(fontSize: 8, color: KuroTheme.textMuted)),
                    ],
                  ),
                  const SizedBox(height: 12),

                  _buildPipelineRow(
                    icon: Icons.public,
                    title: 'Visibilidad Inmediata',
                    sub: 'Publicar en el feed en vez de borrador',
                    val: _visibilidadInmediata,
                    onChanged: (v) => setState(() => _visibilidadInmediata = v),
                  ),
                  const SizedBox(height: 8),
                  _buildPipelineRow(
                    icon: Icons.notifications_none,
                    title: 'Notificar a Lectores',
                    sub: 'Enviar push a seguidores de la serie',
                    val: _notificarLectores,
                    onChanged: (v) => setState(() => _notificarLectores = v),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(color: KuroTheme.cardLighter, borderRadius: BorderRadius.circular(8)),
                    child: Row(
                      children: [
                        const Icon(Icons.storage, color: KuroTheme.cyan, size: 16),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('CLUSTER DE PROCESAMIENTO', style: KuroTheme.mono(fontSize: 8, color: KuroTheme.textMuted)),
                              Text('Shinjuku Edge CDN – Cluster A (WebP 4K)', style: GoogleFonts.spaceGrotesk(fontSize: 11, fontWeight: FontWeight.w700, color: Colors.white)),
                            ],
                          ),
                        ),
                        const Icon(Icons.arrow_forward_ios, color: KuroTheme.textMuted, size: 12),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Big Action Button
            KuroTheme.primaryButton(
              text: 'PUBLICAR Y SINCRONIZAR EN FIRESTORE',
              icon: Icons.sync,
              isLoading: _isUploading,
              onTap: _publicarCapitulo,
            ),

            const SizedBox(height: 8),

            Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.lock_outline, color: KuroTheme.cyan, size: 12),
                  const SizedBox(width: 6),
                  Text(
                    'Guarda metadatos en Cloud Firestore & sube assets a Kuro CDN Vault',
                    style: KuroTheme.mono(fontSize: 8.5, color: KuroTheme.textMuted),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildThumbPage(String url) {
    return Expanded(
      child: ClipRRect(
        borderRadius: BorderRadius.circular(6),
        child: Image.network(url, height: 80, fit: BoxFit.cover),
      ),
    );
  }

  Widget _buildPipelineRow({
    required IconData icon,
    required String title,
    required String sub,
    required bool val,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(color: KuroTheme.cardLighter, borderRadius: BorderRadius.circular(8)),
      child: Row(
        children: [
          Icon(icon, color: Colors.white, size: 16),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: GoogleFonts.spaceGrotesk(fontSize: 12, fontWeight: FontWeight.w700, color: Colors.white)),
                Text(sub, style: KuroTheme.body(fontSize: 9.5, color: KuroTheme.textMuted)),
              ],
            ),
          ),
          Switch(
            value: val,
            activeTrackColor: KuroTheme.crimson,
            activeThumbColor: Colors.white,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}

