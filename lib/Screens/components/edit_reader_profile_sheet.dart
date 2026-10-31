import 'dart:io';
import 'package:aplicacion_manga/services/reader_service.dart';
import 'package:aplicacion_manga/theme/kuro_theme.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';

class EditReaderProfileSheet extends StatefulWidget {
  final String initialName;
  final String initialPhone;
  final String initialClan;
  final String initialAvatar;
  final String initialBio;
  final Function(String name, String phone, String clan, String avatar, String bio) onProfileUpdated;

  const EditReaderProfileSheet({
    Key? key,
    required this.initialName,
    required this.initialPhone,
    required this.initialClan,
    required this.initialAvatar,
    required this.initialBio,
    required this.onProfileUpdated,
  }) : super(key: key);

  @override
  State<EditReaderProfileSheet> createState() => _EditReaderProfileSheetState();
}

class _EditReaderProfileSheetState extends State<EditReaderProfileSheet> {
  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late TextEditingController _bioController;
  late TextEditingController _urlController;

  late String _selectedClan;
  late String _currentAvatar;
  File? _localImageFile;
  bool _isSaving = false;

  final List<Map<String, dynamic>> _clanes = [
    {
      'nombre': 'Carmesí',
      'full': 'CLAN CARMESÍ (黒鬼)',
      'simbolo': '👹',
      'lema': 'Fuerza & Pasión',
      'color': KuroTheme.crimson,
    },
    {
      'nombre': 'Sombra',
      'full': 'CLAN SOMBRA (影)',
      'simbolo': '🌘',
      'lema': 'Misterio & Sigilo',
      'color': KuroTheme.purple,
    },
    {
      'nombre': 'Ciber',
      'full': 'CLAN CIBER (電脳)',
      'simbolo': '⚡',
      'lema': 'Vanguardia & Neón',
      'color': KuroTheme.cyan,
    },
    {
      'nombre': 'Oro',
      'full': 'CLAN ORO (黄金)',
      'simbolo': '👑',
      'lema': 'Prestigio & Gloria',
      'color': KuroTheme.gold,
    },
    {
      'nombre': 'Vacío',
      'full': 'CLAN VACÍO (虚無)',
      'simbolo': '🌀',
      'lema': 'Filosofía & Calma',
      'color': KuroTheme.textGrey,
    },
  ];

  final List<String> _presetAvatares = [
    'https://images.unsplash.com/photo-1578632767115-351597cf2477?w=300',
    'https://images.unsplash.com/photo-1563089145-599997674d42?w=300',
    'https://images.unsplash.com/photo-1607604276583-eef5d076aa5f?w=300',
    'https://images.unsplash.com/photo-1534447677768-be436bb09401?w=300',
    'https://images.unsplash.com/photo-1618005182384-a83a8bd57fbe?w=300',
  ];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.initialName);
    _phoneController = TextEditingController(text: widget.initialPhone);
    _bioController = TextEditingController(text: widget.initialBio);
    _urlController = TextEditingController();

    _currentAvatar = widget.initialAvatar;
    _selectedClan = _sanitizeClan(widget.initialClan);
  }

  String _sanitizeClan(String raw) {
    final lower = raw.toLowerCase();
    if (lower.contains('sombra')) return 'Sombra';
    if (lower.contains('ciber')) return 'Ciber';
    if (lower.contains('oro')) return 'Oro';
    if (lower.contains('vac')) return 'Vacío';
    return 'Carmesí';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _bioController.dispose();
    _urlController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final picker = ImagePicker();
      final picked = await picker.pickImage(source: source, imageQuality: 85);
      if (picked != null) {
        setState(() {
          _localImageFile = File(picked.path);
          _currentAvatar = picked.path;
        });
      }
    } catch (e) {
      Fluttertoast.showToast(msg: 'Error al seleccionar imagen: $e');
    }
  }

  Future<void> _guardarCambios() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      Fluttertoast.showToast(msg: 'No hay sesión de usuario activa');
      return;
    }

    final nombre = _nameController.text.trim();
    if (nombre.isEmpty) {
      Fluttertoast.showToast(msg: 'El nombre de lector no puede estar vacío');
      return;
    }

    setState(() => _isSaving = true);

    try {
      String finalAvatar = _currentAvatar;

      // 1. Si se seleccionó una imagen local de la galería, subir a Firebase Storage
      if (_localImageFile != null && _localImageFile!.existsSync()) {
        final uploaded = await KuroReaderBackendService.instance.uploadReaderAvatar(
          uid: user.uid,
          imageFile: _localImageFile!,
        );
        if (uploaded != null && uploaded.isNotEmpty) {
          finalAvatar = uploaded;
        }
      }

      // 2. Si se ingresó una URL personalizada
      final customUrl = _urlController.text.trim();
      if (customUrl.isNotEmpty && customUrl.startsWith('http')) {
        finalAvatar = customUrl;
      }

      final clanObj = _clanes.firstWhere(
        (c) => c['nombre'] == _selectedClan,
        orElse: () => _clanes.first,
      );
      final clanFull = clanObj['full'] as String;

      final success = await KuroReaderBackendService.instance.saveReaderProfile(
        uid: user.uid,
        nombre: nombre,
        celular: _phoneController.text.trim(),
        clan: clanFull,
        bio: _bioController.text.trim(),
        avatar: finalAvatar,
      );

      if (success) {
        widget.onProfileUpdated(
          nombre,
          _phoneController.text.trim(),
          clanFull,
          finalAvatar,
          _bioController.text.trim(),
        );

        if (mounted) {
          Navigator.pop(context);
        }

        Fluttertoast.showToast(
          msg: '¡Perfil y clan de lector actualizados con éxito!',
          backgroundColor: KuroTheme.cyan,
          textColor: Colors.black,
        );
      } else {
        Fluttertoast.showToast(msg: 'Error al actualizar perfil en el servidor');
      }
    } catch (e) {
      Fluttertoast.showToast(msg: 'Error guardando datos: $e');
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final activeColor = _clanes.firstWhere(
      (c) => c['nombre'] == _selectedClan,
      orElse: () => _clanes.first,
    )['color'] as Color;

    return Container(
      decoration: BoxDecoration(
        color: KuroTheme.card,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(22)),
        border: Border.all(color: KuroTheme.border),
      ),
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Drag handle
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: KuroTheme.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 14),

            // Header Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 6,
                            height: 6,
                            decoration: BoxDecoration(color: activeColor, shape: BoxShape.circle),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            '// KURO LECTOR // IDENTIDAD',
                            style: KuroTheme.mono(fontSize: 9.5, color: activeColor, fontWeight: FontWeight.w700),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'EDITAR PERFIL DEL LECTOR',
                        style: GoogleFonts.spaceGrotesk(fontSize: 16, fontWeight: FontWeight.w800, color: Colors.white),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                IconButton(
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  icon: const Icon(Icons.close, color: KuroTheme.textGrey, size: 20),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 18),

            // Avatar Section
            Center(
              child: Column(
                children: [
                  Stack(
                    children: [
                      Container(
                        width: 86,
                        height: 86,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: activeColor, width: 2.5),
                          boxShadow: [
                            BoxShadow(
                              color: activeColor.withValues(alpha: 0.35),
                              blurRadius: 16,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: ClipOval(
                          child: _localImageFile != null
                              ? Image.file(_localImageFile!, fit: BoxFit.cover)
                              : (_currentAvatar.isNotEmpty && _currentAvatar.startsWith('http')
                                  ? Image.network(
                                      _currentAvatar,
                                      fit: BoxFit.cover,
                                      errorBuilder: (_, __, ___) => Container(
                                        color: KuroTheme.cardLighter,
                                        child: const Icon(Icons.person, color: Colors.white, size: 36),
                                      ),
                                    )
                                  : Container(
                                      color: KuroTheme.cardLighter,
                                      child: const Icon(Icons.person, color: Colors.white, size: 36),
                                    )),
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: GestureDetector(
                          onTap: () => _pickImage(ImageSource.gallery),
                          child: Container(
                            width: 28,
                            height: 28,
                            decoration: BoxDecoration(
                              color: activeColor,
                              shape: BoxShape.circle,
                              border: Border.all(color: KuroTheme.card, width: 2),
                            ),
                            child: const Icon(Icons.camera_alt, color: Colors.white, size: 14),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: KuroTheme.cardLighter,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                        ),
                        icon: const Icon(Icons.photo_library, size: 14),
                        label: Text('Galería', style: KuroTheme.mono(fontSize: 9.5, color: Colors.white)),
                        onPressed: () => _pickImage(ImageSource.gallery),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: KuroTheme.cardLighter,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                        ),
                        icon: const Icon(Icons.camera_alt, size: 14),
                        label: Text('Cámara', style: KuroTheme.mono(fontSize: 9.5, color: Colors.white)),
                        onPressed: () => _pickImage(ImageSource.camera),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  // Presets rápidos
                  Text('O ELIGE UN AVATAR DE LA ORDEN', style: KuroTheme.mono(fontSize: 8, color: KuroTheme.textMuted)),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: _presetAvatares.map((url) {
                      final isSelected = _currentAvatar == url && _localImageFile == null;
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            _localImageFile = null;
                            _currentAvatar = url;
                          });
                        },
                        child: Container(
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          width: 34,
                          height: 34,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: isSelected ? activeColor : KuroTheme.border,
                              width: isSelected ? 2 : 1,
                            ),
                          ),
                          child: ClipOval(
                            child: Image.network(url, fit: BoxFit.cover),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 18),

            // Campo Nombre
            Text('NOMBRE DE LECTOR // NICKNAME', style: KuroTheme.mono(fontSize: 9, color: KuroTheme.textMuted)),
            const SizedBox(height: 6),
            Container(
              height: 46,
              decoration: KuroTheme.cardDecoration(color: KuroTheme.cardLighter),
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Row(
                children: [
                  const Icon(Icons.person_outline, color: KuroTheme.textMuted, size: 16),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      controller: _nameController,
                      style: GoogleFonts.spaceGrotesk(fontSize: 13, color: Colors.white, fontWeight: FontWeight.w700),
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        hintText: 'Ej. Kenji Reader',
                        hintStyle: TextStyle(color: KuroTheme.textMuted, fontSize: 12),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 14),

            // Campo Celular
            Text('NÚMERO DE CELULAR // CONTACTO', style: KuroTheme.mono(fontSize: 9, color: KuroTheme.textMuted)),
            const SizedBox(height: 6),
            Container(
              height: 46,
              decoration: KuroTheme.cardDecoration(color: KuroTheme.cardLighter),
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Row(
                children: [
                  const Icon(Icons.phone_android, color: KuroTheme.textMuted, size: 16),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      controller: _phoneController,
                      keyboardType: TextInputType.phone,
                      style: KuroTheme.mono(fontSize: 12.5, color: Colors.white, fontWeight: FontWeight.w600),
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        hintText: 'Ej. +51 952336505',
                        hintStyle: TextStyle(color: KuroTheme.textMuted, fontSize: 12),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 14),

            // Selector de Clan / Estilo
            Text('ESTILO / CLAN DEL LECTOR', style: KuroTheme.mono(fontSize: 9, color: KuroTheme.textMuted)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _clanes.map((clan) {
                final isSelected = _selectedClan == clan['nombre'];
                final color = clan['color'] as Color;

                return GestureDetector(
                  onTap: () => setState(() => _selectedClan = clan['nombre']),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: isSelected ? color.withValues(alpha: 0.2) : KuroTheme.cardLighter,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isSelected ? color : KuroTheme.border,
                        width: isSelected ? 1.5 : 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(clan['simbolo'] as String, style: const TextStyle(fontSize: 14)),
                        const SizedBox(width: 6),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              clan['nombre'] as String,
                              style: KuroTheme.mono(
                                fontSize: 10.5,
                                color: isSelected ? Colors.white : KuroTheme.textGrey,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            Text(
                              clan['lema'] as String,
                              style: KuroTheme.mono(fontSize: 7.5, color: KuroTheme.textMuted),
                            ),
                          ],
                        ),
                        if (isSelected) ...[
                          const SizedBox(width: 6),
                          Icon(Icons.check_circle, color: color, size: 14),
                        ],
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),

            const SizedBox(height: 14),

            // Bio / Lema Personal
            Text('BIO / LEMA DE LECTOR', style: KuroTheme.mono(fontSize: 9, color: KuroTheme.textMuted)),
            const SizedBox(height: 6),
            Container(
              height: 46,
              decoration: KuroTheme.cardDecoration(color: KuroTheme.cardLighter),
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Row(
                children: [
                  const Icon(Icons.edit_note, color: KuroTheme.textMuted, size: 18),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      controller: _bioController,
                      style: KuroTheme.body(fontSize: 12, color: Colors.white),
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        hintText: 'Ej. Devoto del Seinen y Manga Oscuro...',
                        hintStyle: TextStyle(color: KuroTheme.textMuted, fontSize: 11),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 22),

            // Botón Guardar
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: activeColor,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  elevation: 6,
                  shadowColor: activeColor.withValues(alpha: 0.5),
                ),
                onPressed: _isSaving ? null : _guardarCambios,
                child: _isSaving
                    ? const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                          ),
                          SizedBox(width: 10),
                          Text('GUARDANDO CAMBIOS...', style: TextStyle(color: Colors.white, fontSize: 11)),
                        ],
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.save, color: Colors.white, size: 18),
                          const SizedBox(width: 8),
                          Text(
                            'GUARDAR CAMBIOS EN EL LECTOR',
                            style: KuroTheme.mono(fontSize: 11, color: Colors.white, fontWeight: FontWeight.w900),
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
}

