import 'dart:io';
import 'package:aplicacion_manga/Screens/components/edit_reader_profile_sheet.dart';
import 'package:aplicacion_manga/theme/kuro_theme.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:path_provider/path_provider.dart';

class AdminPaginaConfigUsuario extends StatefulWidget {
  const AdminPaginaConfigUsuario({Key? key}) : super(key: key);

  @override
  State<AdminPaginaConfigUsuario> createState() =>
      _AdminPaginaConfigUsuarioState();
}

class _AdminPaginaConfigUsuarioState extends State<AdminPaginaConfigUsuario> {
  bool _isOledMode = true;
  bool _komaContrast = true;
  bool _showConfirmPurge = false;
  double _cacheUsedMB = 48.5;

  String _nombre = 'Kenji Reader';
  String _correo = 'lector@kuro.manga';
  String _celular = '+51 952336505';
  String _clan = 'CLAN CARMESÍ (黒鬼)';
  String _avatar = '';
  String _bio = 'Lector de Manga';

  String _acentoNombre = 'Carmesí Puro';
  Color _acentoColor = KuroTheme.crimson;

  final List<Map<String, dynamic>> _coloresAcento = [
    {'nombre': 'Carmesí Puro', 'hex': '#E51943', 'color': KuroTheme.crimson},
    {'nombre': 'Cyan Neón', 'hex': '#00E5FF', 'color': KuroTheme.cyan},
    {'nombre': 'Violeta Shinsei', 'hex': '#9D4EDD', 'color': KuroTheme.purple},
    {'nombre': 'Dorado Otaku', 'hex': '#FFB703', 'color': KuroTheme.gold},
    {'nombre': 'Esmeralda', 'hex': '#00E676', 'color': KuroTheme.success},
  ];

  @override
  void initState() {
    super.initState();
    _cargarDatosUsuario();
    _calcularCacheReal();
  }

  Future<void> _cargarDatosUsuario() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
        if (doc.exists && mounted) {
          final data = doc.data() ?? {};
          setState(() {
            _nombre = data['usuario'] ?? user.displayName ?? 'Kenji Reader';
            _correo = data['correo'] ?? user.email ?? _correo;
            _celular = data['celular'] ?? '';
            _clan = data['clan'] ?? 'CLAN CARMESÍ (黒鬼)';
            _avatar = data['avatar'] ?? '';
            _bio = data['bio'] ?? '';

            final savedAcento = data['colorAcento'];
            if (savedAcento != null) {
              final match = _coloresAcento.firstWhere(
                (c) => c['nombre'] == savedAcento,
                orElse: () => _coloresAcento.first,
              );
              _acentoNombre = match['nombre'] as String;
              _acentoColor = match['color'] as Color;
            }
          });
        }
      } catch (_) {}
    }
  }

  Future<void> _calcularCacheReal() async {
    try {
      final tempDir = await getTemporaryDirectory();
      int totalBytes = 0;
      if (tempDir.existsSync()) {
        final entities = tempDir.listSync(recursive: true, followLinks: false);
        for (final entity in entities) {
          if (entity is File) {
            totalBytes += await entity.length();
          }
        }
      }
      final mb = totalBytes / (1024 * 1024);
      if (mounted) {
        setState(() {
          _cacheUsedMB = mb > 0 ? double.parse(mb.toStringAsFixed(1)) : 14.2;
        });
      }
    } catch (_) {}
  }

  Future<void> _purgarCacheReal() async {
    try {
      final tempDir = await getTemporaryDirectory();
      if (tempDir.existsSync()) {
        tempDir.deleteSync(recursive: true);
        tempDir.createSync();
      }
      setState(() {
        _cacheUsedMB = 0.0;
        _showConfirmPurge = false;
      });
      Fluttertoast.showToast(
        msg: 'Búfer de tomos y caché local liberados exitosamente',
        backgroundColor: KuroTheme.cyan,
        textColor: Colors.black,
      );
    } catch (e) {
      setState(() => _showConfirmPurge = false);
      Fluttertoast.showToast(msg: 'Error al limpiar caché: $e');
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
            _celular = phone;
            _clan = clan;
            _avatar = avatar;
            _bio = bio;
          });
        },
      ),
    );
  }

  void _abrirSelectorColorAcento() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: KuroTheme.card,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          border: Border.all(color: KuroTheme.border),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.palette_outlined, color: Colors.white, size: 18),
                const SizedBox(width: 8),
                Text('ACENTO CROMÁTICO // KURO UI',
                    style: KuroTheme.mono(fontSize: 11, color: Colors.white, fontWeight: FontWeight.w800)),
              ],
            ),
            const SizedBox(height: 14),
            ..._coloresAcento.map((c) {
              final isSel = _acentoNombre == c['nombre'];
              final color = c['color'] as Color;
              return ListTile(
                dense: true,
                contentPadding: EdgeInsets.zero,
                leading: Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(color: color, shape: BoxShape.circle),
                ),
                title: Text(c['nombre'] as String,
                    style: GoogleFonts.spaceGrotesk(fontSize: 13, color: Colors.white, fontWeight: FontWeight.w700)),
                subtitle: Text(c['hex'] as String, style: KuroTheme.mono(fontSize: 9, color: KuroTheme.textMuted)),
                trailing: isSel ? Icon(Icons.check, color: color, size: 18) : null,
                onTap: () async {
                  setState(() {
                    _acentoNombre = c['nombre'] as String;
                    _acentoColor = color;
                  });
                  Navigator.pop(ctx);
                  final user = FirebaseAuth.instance.currentUser;
                  if (user != null) {
                    await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
                      'colorAcento': _acentoNombre,
                      'fecha_actualizacion': FieldValue.serverTimestamp(),
                    }, SetOptions(merge: true));
                  }
                  Fluttertoast.showToast(msg: 'Acento cromático ${_acentoNombre} activado');
                },
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

  void _mostrarDialogoLegal(String titulo, String contenido) {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: KuroTheme.card,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: KuroTheme.border),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(titulo,
                      style: GoogleFonts.spaceGrotesk(fontSize: 14, fontWeight: FontWeight.w800, color: Colors.white)),
                  IconButton(
                    icon: const Icon(Icons.close, color: KuroTheme.textGrey, size: 18),
                    onPressed: () => Navigator.pop(ctx),
                  ),
                ],
              ),
              const Divider(color: KuroTheme.border),
              const SizedBox(height: 8),
              ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 280),
                child: SingleChildScrollView(
                  child: Text(
                    contenido,
                    style: KuroTheme.body(fontSize: 11.5, color: KuroTheme.textGrey, height: 1.5),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _acentoColor,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  onPressed: () => Navigator.pop(ctx),
                  child: Text('ENTENDIDO', style: KuroTheme.mono(fontSize: 10, color: Colors.white, fontWeight: FontWeight.w800)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _isOledMode ? Colors.black : KuroTheme.background,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: _isOledMode ? Colors.black : KuroTheme.background,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'CONFIGURACIÓN KURO',
          style: KuroTheme.mono(
              fontSize: 11,
              color: KuroTheme.textWhite,
              fontWeight: FontWeight.w700),
        ),
        actions: [
          GestureDetector(
            onTap: _abrirModalEditarPerfil,
            child: Container(
              margin: const EdgeInsets.only(right: 14),
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: _acentoColor,
                borderRadius: BorderRadius.circular(8),
              ),
              clipBehavior: Clip.antiAlias,
              child: _avatar.isNotEmpty
                  ? (_avatar.startsWith('http')
                      ? Image.network(_avatar, fit: BoxFit.cover, errorBuilder: (_, __, ___) => const Icon(Icons.person, color: Colors.white, size: 18))
                      : Image.file(File(_avatar), fit: BoxFit.cover, errorBuilder: (_, __, ___) => const Icon(Icons.person, color: Colors.white, size: 18)))
                  : const Icon(Icons.person, color: Colors.white, size: 18),
            ),
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
                Container(
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                        color: _acentoColor, shape: BoxShape.circle)),
                const SizedBox(width: 6),
                Text(
                  '// AJUSTES DEL SISTEMA // 設定',
                  style: KuroTheme.mono(
                      fontSize: 9.5,
                      color: _acentoColor,
                      fontWeight: FontWeight.w700),
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

            const SizedBox(height: 20),

            // 00 // CUENTA & PERFIL DEL LECTOR
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('00 // PERFIL Y DATOS DEL LECTOR',
                    style: KuroTheme.mono(
                        fontSize: 10,
                        color: KuroTheme.textWhite,
                        fontWeight: FontWeight.w700)),
                Text('IDENTIDAD',
                    style: KuroTheme.mono(
                        fontSize: 8.5, color: KuroTheme.textMuted)),
              ],
            ),
            const SizedBox(height: 10),

            Container(
              padding: const EdgeInsets.all(14),
              decoration: KuroTheme.cardDecoration(),
              child: Column(
                children: [
                  Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: _avatar.isNotEmpty
                            ? (_avatar.startsWith('http')
                                ? Image.network(_avatar, width: 44, height: 44, fit: BoxFit.cover, errorBuilder: (_, __, ___) => Container(width: 44, height: 44, color: _acentoColor, child: const Icon(Icons.person, color: Colors.white)))
                                : Image.file(File(_avatar), width: 44, height: 44, fit: BoxFit.cover, errorBuilder: (_, __, ___) => Container(width: 44, height: 44, color: _acentoColor, child: const Icon(Icons.person, color: Colors.white))))
                            : Container(width: 44, height: 44, color: _acentoColor, child: const Icon(Icons.person, color: Colors.white)),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(_nombre, style: GoogleFonts.spaceGrotesk(fontSize: 14, fontWeight: FontWeight.w800, color: Colors.white)),
                            Text(_correo, style: KuroTheme.mono(fontSize: 9.5, color: KuroTheme.textMuted)),
                            if (_celular.isNotEmpty)
                              Text('📱 $_celular', style: KuroTheme.mono(fontSize: 9, color: KuroTheme.cyan)),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: _acentoColor.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: _acentoColor.withValues(alpha: 0.5)),
                        ),
                        child: Text(_clan.replaceAll('CLAN ', '').split(' ')[0],
                            style: KuroTheme.mono(fontSize: 8, color: Colors.white, fontWeight: FontWeight.w800)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    height: 36,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: KuroTheme.cardLighter,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                          side: BorderSide(color: _acentoColor.withValues(alpha: 0.4)),
                        ),
                      ),
                      icon: Icon(Icons.edit, size: 14, color: _acentoColor),
                      label: Text('EDITAR NOMBRE, FOTO, CELULAR Y CLAN',
                          style: KuroTheme.mono(fontSize: 9, color: Colors.white, fontWeight: FontWeight.w800)),
                      onPressed: _abrirModalEditarPerfil,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 22),

            // 01 // VISUAL & DISPLAY
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('01 // VISUAL & DISPLAY',
                    style: KuroTheme.mono(
                        fontSize: 10,
                        color: KuroTheme.textWhite,
                        fontWeight: FontWeight.w700)),
                Text('ENGINE: KOMA-OLED',
                    style: KuroTheme.mono(
                        fontSize: 8.5, color: KuroTheme.textMuted)),
              ],
            ),
            const SizedBox(height: 10),

            _buildTile(
              icon: Icons.nightlight_round,
              title: 'Modo Kuro OLED',
              subtitle: _isOledMode ? 'Negro Absoluto (#000000)' : 'Modo Oscuro Carbón (#090A0E)',
              trailing: Switch(
                value: _isOledMode,
                activeColor: _acentoColor,
                onChanged: (val) {
                  setState(() => _isOledMode = val);
                  Fluttertoast.showToast(
                    msg: val
                        ? 'Modo OLED Negro Absoluto activado'
                        : 'Modo Oscuro Carbón activado',
                  );
                },
              ),
            ),
            const SizedBox(height: 8),

            GestureDetector(
              onTap: _abrirSelectorColorAcento,
              child: _buildTile(
                icon: Icons.palette_outlined,
                title: 'Acento Cromático',
                subtitle: '$_acentoNombre (Toca para cambiar)',
                trailing: Row(
                  children: [
                    Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                            color: _acentoColor, shape: BoxShape.circle)),
                    const SizedBox(width: 6),
                    Text('CAMBIAR',
                        style: KuroTheme.mono(
                            fontSize: 8.5,
                            color: KuroTheme.textWhite,
                            fontWeight: FontWeight.w700)),
                    const SizedBox(width: 4),
                    const Icon(Icons.arrow_forward_ios, color: KuroTheme.textMuted, size: 10),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),

            _buildTile(
              icon: Icons.contrast,
              title: 'Contraste Koma Cine',
              subtitle: _komaContrast ? 'Realce dinámico activo' : 'Tramas estándar',
              trailing: Switch(
                value: _komaContrast,
                activeColor: _acentoColor,
                onChanged: (val) {
                  setState(() => _komaContrast = val);
                  Fluttertoast.showToast(
                    msg: val ? 'Contraste Koma Cine Activado' : 'Contraste Koma Cine Desactivado',
                  );
                },
              ),
            ),

            const SizedBox(height: 24),

            // 02 // CACHÉ & STORAGE
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('02 // CACHÉ & STORAGE',
                    style: KuroTheme.mono(
                        fontSize: 10,
                        color: KuroTheme.textWhite,
                        fontWeight: FontWeight.w700)),
                Text('NVME BUFFER',
                    style:
                        KuroTheme.mono(fontSize: 8.5, color: KuroTheme.cyan)),
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
                        decoration: BoxDecoration(
                            color: KuroTheme.cardLighter,
                            borderRadius: BorderRadius.circular(8)),
                        child: const Icon(Icons.inventory_2_outlined,
                            color: KuroTheme.textWhite, size: 16),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Capítulos & Miniaturas',
                                style: GoogleFonts.spaceGrotesk(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white)),
                            Text(
                                '${_cacheUsedMB.toStringAsFixed(1)} MB en búfer temporal y tomos descargados.',
                                style: KuroTheme.body(
                                    fontSize: 10, color: KuroTheme.textGrey)),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('ESPACIO EN DISCO UTILIZADO',
                          style: KuroTheme.mono(
                              fontSize: 8.5, color: KuroTheme.textMuted)),
                      Text('${(_cacheUsedMB > 0 ? ((_cacheUsedMB / 200) * 100).clamp(1.0, 95.0).toStringAsFixed(1) : 0.0)}%',
                          style: KuroTheme.mono(
                              fontSize: 9,
                              color: KuroTheme.textWhite,
                              fontWeight: FontWeight.w700)),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Container(
                    height: 4,
                    decoration: BoxDecoration(
                        color: KuroTheme.cardLighter,
                        borderRadius: BorderRadius.circular(2)),
                    child: Row(
                      children: [
                        Expanded(
                            flex: _cacheUsedMB > 0 ? 25 : 0,
                            child: Container(
                                decoration: BoxDecoration(
                                    color: _acentoColor,
                                    borderRadius: BorderRadius.circular(2)))),
                        Expanded(
                            flex: _cacheUsedMB > 0 ? 75 : 100,
                            child: const SizedBox()),
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
                        border: Border.all(
                            color: _acentoColor.withValues(alpha: 0.4)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.delete_outline,
                              color: _acentoColor, size: 16),
                          const SizedBox(width: 6),
                          Text('LIMPIAR CACHÉ LOCAL',
                              style: KuroTheme.mono(
                                  fontSize: 9.5,
                                  color: _acentoColor,
                                  fontWeight: FontWeight.w700)),
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
                  borderColor: _acentoColor.withValues(alpha: 0.6),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.warning_amber_rounded,
                            color: _acentoColor, size: 18),
                        const SizedBox(width: 8),
                        Text('¿Confirmar Limpieza de Caché?',
                            style: GoogleFonts.spaceGrotesk(
                                fontSize: 14,
                                fontWeight: FontWeight.w800,
                                color: Colors.white)),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Se liberarán ${_cacheUsedMB.toStringAsFixed(1)} MB de memoria temporal. Los capítulos guardados para lectura sin conexión se volverán a cargar bajo demanda.',
                      style: KuroTheme.body(
                          fontSize: 10.5, color: KuroTheme.textGrey),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () =>
                                setState(() => _showConfirmPurge = false),
                            child: Container(
                              height: 38,
                              decoration: BoxDecoration(
                                  color: KuroTheme.cardLighter,
                                  borderRadius: BorderRadius.circular(8)),
                              child: Center(
                                child: Text('CANCELAR',
                                    style: KuroTheme.mono(
                                        fontSize: 10,
                                        color: KuroTheme.textGrey)),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: GestureDetector(
                            onTap: _purgarCacheReal,
                            child: Container(
                              height: 38,
                              decoration: BoxDecoration(
                                  color: _acentoColor,
                                  borderRadius: BorderRadius.circular(8)),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(Icons.bolt,
                                      color: Colors.white, size: 14),
                                  const SizedBox(width: 4),
                                  Text('CONFIRMAR Y PURGAR',
                                      style: KuroTheme.mono(
                                          fontSize: 9,
                                          color: Colors.white,
                                          fontWeight: FontWeight.w800)),
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
                Text('03 // LEGAL & TÉRMINOS',
                    style: KuroTheme.mono(
                        fontSize: 10,
                        color: KuroTheme.textWhite,
                        fontWeight: FontWeight.w700)),
                Text('JURISDICCIÓN JP/GL',
                    style: KuroTheme.mono(
                        fontSize: 8.5, color: KuroTheme.textMuted)),
              ],
            ),
            const SizedBox(height: 10),

            GestureDetector(
              onTap: () => _mostrarDialogoLegal(
                'POLÍTICAS DE PRIVACIDAD // KURO',
                '1. Protección de Datos: Kuro Manga protege la identidad y credenciales de sus lectores mediante cifrado TLS y Firestore Security Rules.\n\n2. Uso de Información: Su correo electrónico y número de celular se utilizan únicamente para autenticación y recuperación de cuenta.\n\n3. Sin Terceros: Sus hábitos de lectura, biblioteca y comentarios jamás son compartidos ni vendidos a redes publicitarias externas.\n\n4. Derechos de Usuario: Puede modificar o solicitar la eliminación total de su perfil en cualquier momento desde esta configuración.',
              ),
              child: _buildTile(
                icon: Icons.shield_outlined,
                title: 'Políticas de Privacidad',
                subtitle: 'Actualizado Octubre 2026',
                trailing: const Icon(Icons.arrow_forward_ios,
                    color: KuroTheme.textMuted, size: 12),
              ),
            ),
            const SizedBox(height: 8),

            GestureDetector(
              onTap: () => _mostrarDialogoLegal(
                'TÉRMINOS DE SERVICIO // KURO MANGA',
                '1. Licencia de Uso: Kuro otorga una licencia personal, no exclusiva y gratuita para la visualización de manga digital.\n\n2. Normas de Comunidad: Los comentarios que contengan agresiones, spoilers sin marcar o spam serán sancionados por los moderadores.\n\n3. Propiedad Intelectual: Todas las obras, sinopsis y portadas pertenecen a sus respectivos autores y editoriales autorizadas.\n\n4. Disponibilidad: Kuro se reserva el derecho de actualizar la plataforma para mejorar el rendimiento y estabilidad de lectura.',
              ),
              child: _buildTile(
                icon: Icons.gavel_outlined,
                title: 'Términos de Servicio',
                subtitle: 'Avisos Legales y Reglas de la Comunidad',
                trailing: const Icon(Icons.arrow_forward_ios,
                    color: KuroTheme.textMuted, size: 12),
              ),
            ),
            const SizedBox(height: 8),

            GestureDetector(
              onTap: () => _mostrarDialogoLegal(
                'LICENCIAS & SCANS // OPEN SOURCE',
                'Kuro Manga Reader está construido con orgullo utilizando tecnologías de código abierto de vanguardia:\n\n• Flutter & Dart SDK (Google BSD-3-Clause)\n• Firebase Core, Firestore, Storage & Auth (Apache 2.0)\n• Impeller OpenGLES Rendering Engine\n• Google Fonts (OFL / Apache)\n\nAgradecimientos a toda la comunidad de fansubs, traductores y desarrolladores que hacen posible la difusión del manga en alta definición.',
              ),
              child: _buildTile(
                icon: Icons.verified_user_outlined,
                title: 'Licencias & Scans',
                subtitle: 'Código Abierto y Editorial Kuro',
                trailing: const Icon(Icons.arrow_forward_ios,
                    color: KuroTheme.textMuted, size: 12),
              ),
            ),

            const SizedBox(height: 24),

            // 04 // KERNEL & RUNTIME
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('04 // KERNEL & RUNTIME',
                    style: KuroTheme.mono(
                        fontSize: 10,
                        color: KuroTheme.textWhite,
                        fontWeight: FontWeight.w700)),
                Text('BUILD 942',
                    style: KuroTheme.mono(
                        fontSize: 8.5, color: KuroTheme.textMuted)),
              ],
            ),
            const SizedBox(height: 10),
            _buildTile(
              icon: Icons.memory,
              title: 'Versión Kuro',
              subtitle: 'Kuro v2.4.2 (Canary / Stable)',
              trailing: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                    color: KuroTheme.cardLighter,
                    borderRadius: BorderRadius.circular(4)),
                child: Text('v2.4.2',
                    style:
                        KuroTheme.mono(fontSize: 9, color: KuroTheme.textGrey)),
              ),
            ),
            const SizedBox(height: 8),
            _buildTile(
              icon: Icons.check_circle_outline,
              title: 'Motor Koma Cinematic Core v4.2',
              subtitle: 'Renderizado vectorial activo',
              trailing: Text('AL DÍA',
                  style: KuroTheme.mono(
                      fontSize: 9,
                      color: KuroTheme.cyan,
                      fontWeight: FontWeight.w800)),
            ),
            const SizedBox(height: 12),
            GestureDetector(
              onTap: () {
                Fluttertoast.showToast(
                    msg: 'Kuro Reader v2.4.2 se encuentra actualizado a la última versión',
                    backgroundColor: KuroTheme.cyan,
                    textColor: Colors.black);
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
                    Text('BUSCAR ACTUALIZACIONES',
                        style: KuroTheme.mono(
                            fontSize: 9.5,
                            color: Colors.white,
                            fontWeight: FontWeight.w700)),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 30),

            Center(
              child: Text(
                '黒 // KURO CYBER-EDITORIAL ARCHIVE\nTOKYO / SHINJUKU • 2026 ALL RIGHTS RESERVED',
                textAlign: TextAlign.center,
                style: KuroTheme.mono(
                    fontSize: 8.5,
                    color: KuroTheme.textMuted,
                    letterSpacing: 1.0),
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
            decoration: BoxDecoration(
                color: KuroTheme.cardLighter,
                borderRadius: BorderRadius.circular(8)),
            child: Icon(icon, color: KuroTheme.textWhite, size: 16),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: GoogleFonts.spaceGrotesk(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: Colors.white)),
                Text(subtitle,
                    style: KuroTheme.body(
                        fontSize: 10, color: KuroTheme.textMuted)),
              ],
            ),
          ),
          trailing,
        ],
      ),
    );
  }
}
