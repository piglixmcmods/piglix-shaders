// new_ui.dart  — Piglix Shader Studio v2  (beautiful redesign)
// Home screen → "OPEN EDITOR" grid cards → tabbed shader editor

import 'dart:convert';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:archive/archive.dart';
import 'package:universal_html/html.dart' as html;
import 'package:uuid/uuid.dart';
import 'package:file_saver/file_saver.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart' show kIsWeb, compute;
import 'piglix_logo_data.dart';
import 'minecraft_icons.dart';
import 'legal_screens.dart';
import 'my_shaders_screen.dart';
import 'tab_art_data.dart';
import 'hero_sunset_bytes.dart';
import 'theme_controller.dart';
import 'shader_presets.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'io_stub.dart' if (dart.library.io) 'io_real.dart';

Archive _decodeZipBytesWorker(List<int> bytes) =>
    ZipDecoder().decodeBytes(bytes);
List<int> _encodeZipArchiveWorker(Archive archive) =>
    ZipEncoder().encode(archive);

// ─── OBSIDIAN & EMERALD PALETTE (MATCHING HOME SCREEN) ────────────────────────
const _green = Color(0xFF22C55E);

extension _ColorLegacyExt on Color {
  int get redInt => (r * 255.0).round().clamp(0, 255);
  int get greenInt => (g * 255.0).round().clamp(0, 255);
  int get blueInt => (b * 255.0).round().clamp(0, 255);
}
// Vibrant emerald green accent

// ─── SPARKLE STARS LOGO (Detailed 3-Star Vector Icon matching screenshot) ───
class SparkleStarsPainter extends CustomPainter {
  final Color color;
  final bool glow;

  const SparkleStarsPainter({
    this.color = const Color(0xFFFFD54F),
    this.glow = true,
  });

  void _drawSparkle(Canvas canvas, Offset center, double radius, Paint paint) {
    final path = Path();
    final double rIn = radius * 0.22; // Inward curved concave pinch

    path.moveTo(center.dx, center.dy - radius);
    path.quadraticBezierTo(
      center.dx + rIn,
      center.dy - rIn,
      center.dx + radius,
      center.dy,
    );
    path.quadraticBezierTo(
      center.dx + rIn,
      center.dy + rIn,
      center.dx,
      center.dy + radius,
    );
    path.quadraticBezierTo(
      center.dx - rIn,
      center.dy + rIn,
      center.dx - radius,
      center.dy,
    );
    path.quadraticBezierTo(
      center.dx - rIn,
      center.dy - rIn,
      center.dx,
      center.dy - radius,
    );
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    if (glow) {
      final glowPaint = Paint()
        ..color = color.withValues(alpha: 0.38)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5.0);
      _drawSparkle(canvas, Offset(w * 0.38, h * 0.48), w * 0.36, glowPaint);
      _drawSparkle(canvas, Offset(w * 0.78, h * 0.28), w * 0.17, glowPaint);
      _drawSparkle(canvas, Offset(w * 0.70, h * 0.74), w * 0.22, glowPaint);
    }

    final fillPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill
      ..isAntiAlias = true;

    // 1. Large 4-point star (center-left)
    _drawSparkle(canvas, Offset(w * 0.38, h * 0.48), w * 0.34, fillPaint);

    // 2. Small 4-point star (top-right)
    _drawSparkle(canvas, Offset(w * 0.78, h * 0.28), w * 0.16, fillPaint);

    // 3. Medium 4-point star (bottom-right)
    _drawSparkle(canvas, Offset(w * 0.70, h * 0.74), w * 0.20, fillPaint);

    // Inner bright highlights for extra detail
    final highlightPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.85)
      ..style = PaintingStyle.fill
      ..isAntiAlias = true;
    _drawSparkle(canvas, Offset(w * 0.38, h * 0.48), w * 0.12, highlightPaint);
    _drawSparkle(canvas, Offset(w * 0.78, h * 0.28), w * 0.06, highlightPaint);
    _drawSparkle(canvas, Offset(w * 0.70, h * 0.74), w * 0.08, highlightPaint);
  }

  @override
  bool shouldRepaint(covariant SparkleStarsPainter oldDelegate) =>
      color != oldDelegate.color || glow != oldDelegate.glow;
}

class SparkleStarsIcon extends StatelessWidget {
  final double size;
  final Color color;
  final bool glow;

  const SparkleStarsIcon({
    super.key,
    this.size = 28,
    this.color = const Color(0xFFFFD54F),
    this.glow = true,
  });

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: CustomPaint(
        size: Size(size, size),
        painter: SparkleStarsPainter(color: color, glow: glow),
      ),
    );
  }
}

// ─── ENTRY POINT ────────────────────────────────────────────────────────────
class _ParsedShaderPack {
  final ShaderPresetConfig preset;
  final Uint8List? packIconBytes;
  final String? manifestPackName;
  _ParsedShaderPack({
    required this.preset,
    this.packIconBytes,
    this.manifestPackName,
  });
}

class PiglixHomeScreen extends StatefulWidget {
  const PiglixHomeScreen({super.key});
  @override
  State<PiglixHomeScreen> createState() => _PiglixHomeScreenState();
}

class _PiglixHomeScreenState extends State<PiglixHomeScreen>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  late final AnimationController _pulseCtrl;

  // Custom pack upload state
  List<int>? _uploadedShaderBytes;
  String? _uploadedShaderName;
  Uint8List? _uploadedLogoBytes;
  String? _uploadedLogoName;

  // Shader configuration
  final TextEditingController _shaderNameCtrl = TextEditingController(
    text: 'Piglix Shader',
  );

  final List<String> _namePresets = [
    'Piglix Shader',
    'Vibrant Bedrock',
    'Cyber Bloom RTX',
    'Pink Atmosphere',
    'Neon Shimmer',
    'Misty Horizon',
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkFirstRunOnboarding();
    });
  }

  Future<void> _checkFirstRunOnboarding() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final hasSeen = prefs.getBool('piglix_has_seen_onboarding_v1') ?? false;
      if (!hasSeen && mounted) {
        await prefs.setBool('piglix_has_seen_onboarding_v1', true);
        _showWelcomeOnboardingSheet();
      }
    } catch (_) {}
  }

  void _showWelcomeOnboardingSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF0E1722),
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        side: BorderSide(color: Color(0xFF1E293B)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: const Color(0xFF22C55E).withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: const Color(0xFF22C55E),
                      width: 1.2,
                    ),
                  ),
                  alignment: Alignment.center,
                  child: const AnimatedMinecraftIcon(
                    type: VoxelIconType.grassBlock,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    'WELCOME TO PIGLIX SHADER BUILDER',
                    style: TextStyle(
                      color: Colors.white,
                      fontFamily: 'PixelifySans',
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Text(
              'Create, customize, and compile official Deferred PBR Shaders for Minecraft Bedrock on Android:',
              style: TextStyle(
                color: Color(0xFF94A3B8),
                fontSize: 13,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 14),
            _onboardingStepCard(
              icon: Icons.palette_outlined,
              title: '1. Customize Visual Parameters',
              desc:
                  'Fine-tune time-of-day sky colors, sun/moon size, water caustics, and volumetric fog.',
            ),
            const SizedBox(height: 10),
            _onboardingStepCard(
              icon: Icons.archive_outlined,
              title: '2. Compile to .MCPACK',
              desc:
                  'Piglix Engine bundles your parameters into a standard Minecraft resource pack in the background.',
            ),
            const SizedBox(height: 10),
            _onboardingStepCard(
              icon: Icons.play_arrow_outlined,
              title: '3. Enable in Minecraft Experiments',
              desc:
                  'Import with 1-tap, then turn on "Render Dragon Features for Creators" in Minecraft World Settings!',
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 46,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF22C55E),
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: () => Navigator.pop(ctx),
                child: const Text(
                  'START CREATING SHADERS',
                  style: TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 13,
                    letterSpacing: 0.8,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _onboardingStepCard({
    required IconData icon,
    required String title,
    required String desc,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF16202A),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFF243547)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: const Color(0xFF22C55E), size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  desc,
                  style: const TextStyle(
                    color: Color(0xFF94A3B8),
                    fontSize: 11.5,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _pulseCtrl.dispose();
    _shaderNameCtrl.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive) {
      if (_pulseCtrl.isAnimating) {
        _pulseCtrl.stop();
      }
    } else if (state == AppLifecycleState.resumed) {
      if (!_pulseCtrl.isAnimating) {
        _pulseCtrl.repeat(reverse: true);
      }
    }
  }

  void _randomizeShaderName() {
    final cur = _shaderNameCtrl.text;
    final other = _namePresets.where((p) => p != cur).toList();
    other.shuffle();
    setState(() {
      _shaderNameCtrl.text = other.first;
    });
  }

  Future<void> _pickCustomLogo() async {
    try {
      final f = await FilePicker.pickFile(
        type: FileType.custom,
        allowedExtensions: ['png', 'jpg', 'jpeg'],
      );
      if (f != null) {
        final bytes = await f.readAsBytes();
        if (bytes.isNotEmpty) {
          setState(() {
            _uploadedLogoBytes = bytes;
            _uploadedLogoName = f.name;
          });
          // Production: no toast for logo set
        }
      }
    } catch (e) {
      _snack('Could not load logo: $e', isError: true);
    }
  }

  void _openEditor() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ShaderEditorScreen(
          uploadedShaderBytes: _uploadedShaderBytes,
          uploadedShaderName: _uploadedShaderName,
          uploadedLogoBytes: _uploadedLogoBytes,
          shaderName: _shaderNameCtrl.text.trim().isEmpty
              ? 'Piglix Shader'
              : _shaderNameCtrl.text.trim(),
        ),
      ),
    );
  }

  void _openMyShaders() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => MyShadersScreen(
          onEditShader: (name) {
            setState(() {
              _shaderNameCtrl.text = name;
            });
            _openEditor();
          },
          onStartNew: _openEditor,
        ),
      ),
    );
  }

  void _openPresetsPage() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ShaderPresetsScreen(
          onSelectPreset: (preset) {
            Navigator.pop(context);
            setState(() {
              _shaderNameCtrl.text = preset.name;
            });
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ShaderEditorScreen(
                  uploadedShaderBytes: _uploadedShaderBytes,
                  uploadedShaderName: _uploadedShaderName,
                  uploadedLogoBytes: _uploadedLogoBytes,
                  shaderName: preset.name,
                  presetConfig: preset,
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  /// Upload an existing .mcpack/.zip shader pack, parse its JSON values,
  /// auto-populate a ShaderPresetConfig, and open the editor with those values.
  Future<void> _uploadAndParseShader() async {
    try {
      final f = await FilePicker.pickFile(
        type: FileType.custom,
        allowedExtensions: ['mcpack', 'zip'],
      );
      if (f == null) return;
      final bytes = await f.readAsBytes();
      if (bytes.isEmpty) return;

      final baseName = f.name.replaceAll(
        RegExp(r'\.(mcpack|zip)$', caseSensitive: false),
        '',
      );

      // Parse the zip and extract values from JSONs, manifest title, and pack_icon.png
      final archive = await compute(_decodeZipBytesWorker, bytes);
      final parsed = _parseShaderPackFromArchive(
        archive,
        baseName.isEmpty ? 'Imported Shader' : baseName,
      );
      final finalName = parsed.manifestPackName ?? parsed.preset.name;

      setState(() {
        _uploadedShaderBytes = bytes;
        _uploadedShaderName = f.name;
        if (parsed.packIconBytes != null) {
          _uploadedLogoBytes = parsed.packIconBytes;
          _uploadedLogoName = '$finalName Icon';
        }
        _shaderNameCtrl.text = finalName;
      });

      if (!mounted) return;

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ShaderEditorScreen(
            uploadedShaderBytes: bytes,
            uploadedShaderName: f.name,
            uploadedLogoBytes: _uploadedLogoBytes,
            shaderName: finalName,
            presetConfig: parsed.preset,
          ),
        ),
      );
    } catch (e) {
      _snack('Could not parse shader pack: $e', isError: true);
    }
  }

  /// Parse an uploaded .mcpack/.zip and extract configuration values into a ShaderPresetConfig.
  _ParsedShaderPack _parseShaderPackFromArchive(
    Archive archive,
    String packName,
  ) {
    final fileMap = <String, List<int>>{};

    // Detect if archive has a single top-level folder prefix (e.g. PackFolder/manifest.json)
    String prefix = '';
    final nonDirFiles = archive.where((f) => f.isFile).toList();
    if (nonDirFiles.isNotEmpty) {
      final first = nonDirFiles.first.name.replaceAll('\\', '/');
      final slashIdx = first.indexOf('/');
      if (slashIdx != -1) {
        final candidate = first.substring(0, slashIdx + 1);
        const standardDirs = [
          'atmospherics/',
          'biomes/',
          'fogs/',
          'lighting/',
          'local_lighting/',
          'point_lights/',
          'water/',
          'color_grading/',
          'textures/',
          'subpacks/',
          'pbr/',
          'shadows/',
          'particles/',
          'materials/',
        ];
        if (!standardDirs.any((d) => candidate.startsWith(d))) {
          if (nonDirFiles.every(
            (f) => f.name.replaceAll('\\', '/').startsWith(candidate),
          )) {
            prefix = candidate;
          }
        }
      }
    }

    Uint8List? extractedIcon;
    for (final file in archive) {
      if (file.isFile) {
        var name = file.name.replaceAll('\\', '/');
        if (prefix.isNotEmpty && name.startsWith(prefix)) {
          name = name.substring(prefix.length);
        }
        final content = file.content as List<int>;
        fileMap[name] = content;
        if (name == 'pack_icon.png' || name.endsWith('/pack_icon.png')) {
          extractedIcon = Uint8List.fromList(content);
        }
      }
    }

    // Try reading clean name from manifest.json
    String? manifestName;
    if (fileMap.containsKey('manifest.json')) {
      try {
        final raw = utf8.decode(fileMap['manifest.json']!);
        final m = jsonDecode(raw) as Map<String, dynamic>;
        final header = m['header'] as Map<String, dynamic>?;
        if (header != null &&
            header['name'] is String &&
            (header['name'] as String).trim().isNotEmpty) {
          final hName = (header['name'] as String).trim();
          final clean = hName
              .replaceAll(RegExp(r'§[0-9a-fk-or]', caseSensitive: false), '')
              .trim();
          if (clean.isNotEmpty) manifestName = clean;
        }
      } catch (_) {}
    }

    final effectiveName = manifestName ?? packName;

    // Defaults
    Color morningC = const Color(0xFFFF9AA2);
    Color noonC = const Color(0xFF87CEEB);
    Color eveningC = const Color(0xFFFFA500);
    Color nightC = const Color(0xFF00008B);
    double sunSz = 1.0;
    double fogDens = 1.0;
    Color torchC = const Color(0xFFFF9933);
    double lightInt = 1.0;
    double blockLightInt = 1.0;
    Color rayMornC = const Color(0xFFFFA040);
    Color rayNoonC = const Color(0xFFFAFCFF);
    Color rayEveC = const Color(0xFFFF6020);
    Color rayNightC = const Color(0xFF3050AA);
    Color waterC = const Color(0xFF00E5FF);
    double windSpd = 1.0;
    Color rainFogC = const Color(0xFF5A636A);
    Color rainWaterC = const Color(0xFF2E3D48);
    String cloudTp = 'Realistic 3D';
    String volFogProf = 'Cinematic';
    String shadowQ = 'High';
    String waterQ = 'Ultra';
    bool ptLightShadows = true;
    bool uwCaustics = true;
    bool worldRef = true;
    bool pbrEnabled = true;
    double metalness = 0.0;
    bool waveFoliage = true;
    double foliageSpd = 1.0;
    String toneMap = 'ACES (Cinematic)';
    String bioTone = 'Dynamic';
    double sat = 1.0;
    double con = 1.0;
    double autoExp = 1.0;
    double nightVis = 1.0;

    Color parseColorArray(List<dynamic> arr) {
      if (arr.length >= 3) {
        return Color.fromARGB(
          255,
          (arr[0] as num).toInt().clamp(0, 255),
          (arr[1] as num).toInt().clamp(0, 255),
          (arr[2] as num).toInt().clamp(0, 255),
        );
      }
      return const Color(0xFF888888);
    }

    Color parseHexColor(String hex) {
      hex = hex.replaceFirst('#', '');
      if (hex.length == 6) hex = 'FF$hex';
      return Color(int.parse(hex, radix: 16));
    }

    String cleanJsonStr(String raw) {
      raw = raw.replaceAll(RegExp(r'/\*.*?\*/', dotAll: true), '');
      raw = raw.replaceAll(RegExp(r'//[^\n]*'), '');
      raw = raw.replaceAll(RegExp(r',\s*([}\]])'), r'\1');
      return raw;
    }

    // ── Parse atmospherics/*.json for sky colors ──
    for (final key in fileMap.keys) {
      if (key.startsWith('atmospherics/') && key.endsWith('.json')) {
        try {
          final raw = cleanJsonStr(utf8.decode(fileMap[key]!));
          final data = jsonDecode(raw) as Map<String, dynamic>;
          final atm =
              data['minecraft:atmosphere_settings'] as Map<String, dynamic>?;
          if (atm != null) {
            final zenith = atm['sky_zenith_color'];
            if (zenith is Map) {
              // Extract noon (key ~0.0), evening (~0.215), night (~0.3–0.5), morning (~0.74)
              zenith.forEach((k, v) {
                final t = double.tryParse(k.toString()) ?? -1;
                if (v is List && v.length >= 3) {
                  if (t >= 0.0 && t <= 0.05) noonC = parseColorArray(v);
                  if (t >= 0.21 && t <= 0.23) eveningC = parseColorArray(v);
                  if (t >= 0.29 && t <= 0.51) nightC = parseColorArray(v);
                  if (t >= 0.73 && t <= 0.78) morningC = parseColorArray(v);
                }
              });
            }
            final glare = atm['sun_glare_shape'];
            if (glare is Map) {
              glare.forEach((k, v) {
                final t = double.tryParse(k.toString()) ?? -1;
                if (t >= 0.0 && t <= 0.01 && v is num) {
                  sunSz = (v.toDouble() / 5.0).clamp(0.2, 3.0);
                }
              });
            }
            final rayleigh = atm['rayleigh_strength'];
            if (rayleigh is Map) {
              rayleigh.forEach((k, v) {
                final t = double.tryParse(k.toString()) ?? -1;
                if (t >= 0.0 && t <= 0.01 && v is num) {
                  fogDens = (v.toDouble() / 2.2).clamp(0.2, 3.0);
                }
              });
            }
          }
        } catch (_) {}
      }
    }

    // ── Parse lighting/*.json for directional lights & god rays ──
    for (final key in fileMap.keys) {
      if (key.startsWith('lighting/') && key.endsWith('.json')) {
        try {
          final raw = cleanJsonStr(utf8.decode(fileMap[key]!));
          final data = jsonDecode(raw) as Map<String, dynamic>;
          final ls =
              data['minecraft:lighting_settings'] as Map<String, dynamic>?;
          if (ls != null && ls['directional_lights'] != null) {
            final dl = ls['directional_lights'] as Map<String, dynamic>;
            final orb = dl['orbital'] as Map<String, dynamic>?;
            if (orb != null) {
              final sun = orb['sun'] as Map<String, dynamic>?;
              if (sun != null) {
                final illum = sun['illuminance'];
                if (illum is Map) {
                  illum.forEach((k, v) {
                    final t = double.tryParse(k.toString()) ?? -1;
                    if (t >= 0.0 && t <= 0.01 && v is num) {
                      lightInt = (v.toDouble() / 181.0).clamp(0.2, 2.0);
                    }
                  });
                }
                final sunColors = sun['color'];
                if (sunColors is Map) {
                  sunColors.forEach((k, v) {
                    final t = double.tryParse(k.toString()) ?? -1;
                    if (v is List && v.length >= 3) {
                      if (t >= 0.0 && t <= 0.05) rayNoonC = parseColorArray(v);
                      if (t >= 0.21 && t <= 0.24) rayEveC = parseColorArray(v);
                      if (t >= 0.73 && t <= 0.78) rayMornC = parseColorArray(v);
                    }
                  });
                }
              }
              final moon = orb['moon'] as Map<String, dynamic>?;
              if (moon != null) {
                final moonIllum = moon['illuminance'];
                if (moonIllum is Map) {
                  moonIllum.forEach((k, v) {
                    final t = double.tryParse(k.toString()) ?? -1;
                    if (t >= 0.0 && t <= 0.01 && v is num) {
                      nightVis = (v.toDouble() / 2.1).clamp(0.2, 3.0);
                    }
                  });
                }
                final moonColors = moon['color'];
                if (moonColors is Map) {
                  moonColors.forEach((k, v) {
                    final t = double.tryParse(k.toString()) ?? -1;
                    if (v is List && v.length >= 3 && t >= 0.0 && t <= 0.05) {
                      rayNightC = parseColorArray(v);
                    }
                  });
                }
              }
            }
          }
        } catch (_) {}
      }
    }

    // ── Parse point_lights or local_lighting for torch color ──
    for (final key in [
      'point_lights/global.json',
      'local_lighting/local_lighting.json',
    ]) {
      if (fileMap.containsKey(key)) {
        try {
          final raw = cleanJsonStr(utf8.decode(fileMap[key]!));
          final data = jsonDecode(raw) as Map<String, dynamic>;
          final colors =
              (data['minecraft:point_light_settings']?['colors'] ??
                      data['minecraft:local_light_settings']?['colors'])
                  as Map<String, dynamic>?;
          if (colors != null) {
            final torchHex =
                colors['minecraft:torch'] ?? colors['minecraft:lantern'];
            if (torchHex is String) {
              torchC = parseHexColor(torchHex);
            }
          }
        } catch (_) {}
      }
    }

    // ── Parse water/*.json for water settings ──
    for (final key in fileMap.keys) {
      if (key.startsWith('water/') && key.endsWith('.json')) {
        try {
          final raw = cleanJsonStr(utf8.decode(fileMap[key]!));
          final data = jsonDecode(raw) as Map<String, dynamic>;
          final ws = data['minecraft:water_settings'] as Map<String, dynamic>?;
          if (ws != null) {
            final waves = ws['waves'] as Map<String, dynamic>?;
            if (waves != null) {
              final spd = waves['speed'];
              if (spd is num) windSpd = (spd.toDouble() / 2.38).clamp(0.2, 2.0);
            }
            final caustics = ws['caustics'] as Map<String, dynamic>?;
            if (caustics != null) {
              uwCaustics = caustics['enabled'] == true;
            }
          }
        } catch (_) {}
        break; // one water file is enough
      }
    }

    // ── Parse biomes for water surface color ──
    for (final key in fileMap.keys) {
      if (key.startsWith('biomes/') && key.endsWith('.client_biome.json')) {
        try {
          final raw = cleanJsonStr(utf8.decode(fileMap[key]!));
          final data = jsonDecode(raw) as Map<String, dynamic>;
          final bio = data['minecraft:client_biome'] ?? data;
          final wsc = bio['water_surface_color'];
          if (wsc is List && wsc.length >= 3) {
            waterC = parseColorArray(wsc);
          }
          final comps = bio['components'] as Map<String, dynamic>?;
          if (comps != null) {
            final wa =
                comps['minecraft:water_appearance'] as Map<String, dynamic>?;
            if (wa != null && wa['surface_color'] is String) {
              waterC = parseHexColor(wa['surface_color'] as String);
            }
          }
        } catch (_) {}
        break; // one biome is enough
      }
    }

    // ── Parse fogs/*.json for fog & weather colors ──
    for (final key in fileMap.keys) {
      if (key.startsWith('fogs/') && key.endsWith('.json')) {
        try {
          final raw = cleanJsonStr(utf8.decode(fileMap[key]!));
          final data = jsonDecode(raw) as Map<String, dynamic>;
          final fs = data['minecraft:fog_settings'] as Map<String, dynamic>?;
          if (fs != null) {
            final dist = fs['distance'] as Map<String, dynamic>?;
            if (dist != null) {
              if (dist['weather'] != null) {
                final wFog = dist['weather']['fog_color'];
                if (wFog is String) rainFogC = parseHexColor(wFog);
              }
              if (dist['water'] != null) {
                final wWater = dist['water']['fog_color'];
                if (wWater is String) rainWaterC = parseHexColor(wWater);
              }
            }
            final vol = fs['volumetric'] as Map<String, dynamic>?;
            if (vol != null && vol['density'] != null) {
              final airDens = vol['density']['air']?['max_density'];
              if (airDens is num) {
                if (airDens > 0.05) {
                  volFogProf = 'Cinematic';
                } else if (airDens > 0.02) {
                  volFogProf = 'Balanced';
                } else {
                  volFogProf = 'Low End';
                }
              }
              final mc = vol['media_coefficients'] as Map<String, dynamic>?;
              if (mc != null && mc['cloud'] != null) {
                final scattering = mc['cloud']['scattering'];
                if (scattering is List && scattering.length >= 3) {
                  final avg =
                      ((scattering[0] as num) +
                          (scattering[1] as num) +
                          (scattering[2] as num)) /
                      3.0;
                  if (avg > 0.03) {
                    cloudTp = 'Realistic 3D';
                  } else if (avg > 0.005) {
                    cloudTp = 'Volumetric';
                  } else {
                    cloudTp = 'Flat 2D';
                  }
                }
              }
            }
          }
        } catch (_) {}
        break; // one fog file is enough
      }
    }

    // ── Parse color_grading/*.json for tone mapping & saturation ──
    for (final key in [
      'color_grading/color_grading.json',
      'color_grading/pale_color_grading.json',
    ]) {
      if (fileMap.containsKey(key)) {
        try {
          final raw = cleanJsonStr(utf8.decode(fileMap[key]!));
          final data = jsonDecode(raw) as Map<String, dynamic>;
          final cgs =
              data['minecraft:color_grading_settings'] as Map<String, dynamic>?;
          if (cgs != null) {
            final tm = cgs['tone_mapping'] as Map<String, dynamic>?;
            if (tm != null) {
              final op = tm['operator']?.toString() ?? 'aces';
              if (op.contains('reinhard')) {
                toneMap = 'Reinhard';
              } else if (op.contains('hable')) {
                toneMap = 'Warm';
              } else {
                toneMap = 'ACES (Cinematic)';
              }
            }
            final temp = cgs['temperature'] as Map<String, dynamic>?;
            if (temp != null) {
              final t = temp['temperature'];
              if (t is num) {
                if (t > 7000) {
                  bioTone = 'Frost';
                } else if (t < 5800) {
                  bioTone = 'Savanna';
                } else {
                  bioTone = 'Dynamic';
                }
              }
            }
            final cg = cgs['color_grading'] as Map<String, dynamic>?;
            if (cg != null && cg['midtones'] != null) {
              final mid = cg['midtones'] as Map<String, dynamic>;
              final satArr = mid['saturation'];
              if (satArr is List && satArr.isNotEmpty) {
                sat = (satArr[0] as num).toDouble().clamp(0.1, 2.5);
              }
              final conArr = mid['contrast'];
              if (conArr is List && conArr.isNotEmpty) {
                con = (conArr[0] as num).toDouble().clamp(0.5, 2.0);
              }
              final gainArr = mid['gain'];
              if (gainArr is List && gainArr.isNotEmpty) {
                autoExp = ((gainArr[0] as num).toDouble() / 1.05).clamp(
                  0.4,
                  2.5,
                );
              }
            }
          }
        } catch (_) {}
        break;
      }
    }

    final preset = ShaderPresetConfig(
      id: 'uploaded_${effectiveName.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '_')}',
      name: effectiveName,
      creator: 'Imported',
      description: 'Imported from $packName',
      rating: 0.0,
      downloads: '—',
      tags: const ['Uploaded', 'Custom'],
      morningColor: morningC,
      noonColor: noonC,
      eveningColor: eveningC,
      nightColor: nightC,
      sunSize: sunSz,
      nightVision: nightVis,
      fogDensity: fogDens,
      cloudType: cloudTp,
      torchColor: torchC,
      lightIntensity: lightInt,
      blockLightIntensity: blockLightInt,
      shadowQuality: shadowQ,
      enablePointLightShadows: ptLightShadows,
      volumetricFogProfile: volFogProf,
      rayMorningColor: rayMornC,
      rayNoonColor: rayNoonC,
      rayEveningColor: rayEveC,
      rayNightColor: rayNightC,
      waterColor: waterC,
      windSpeed: windSpd,
      waterQuality: waterQ,
      underwaterCaustics: uwCaustics,
      rainFogColor: rainFogC,
      rainWaterColor: rainWaterC,
      worldReflections: worldRef,
      enablePBR: pbrEnabled,
      metalness: metalness,
      wavingFoliage: waveFoliage,
      foliageWaveSpeed: foliageSpd,
      toneMapFilter: toneMap,
      biomeTone: bioTone,
      saturation: sat,
      contrast: con,
      autoExposure: autoExp,
    );

    return _ParsedShaderPack(
      preset: preset,
      packIconBytes: extractedIcon,
      manifestPackName: manifestName,
    );
  }

  void _snack(String msg, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          msg,
          style: const TextStyle(
            color: Color(0xFFF2EFE9),
            fontWeight: FontWeight.w700,
            fontSize: 13,
          ),
        ),
        backgroundColor: isError
            ? const Color(0xFF5D1E1E)
            : const Color(0xFF262422),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: BorderSide(
            color: isError ? const Color(0xFFE57373) : const Color(0xFF5A524A),
            width: 1.5,
          ),
        ),
        elevation: 8,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final palette = AppPalette(true);
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: palette.bg,
      drawerScrimColor: Colors.black.withValues(alpha: 0.72),
      drawerEdgeDragWidth: 36,
      drawer: _buildDrawer(context),
      body: Stack(
        children: [
          // 1. Hero Sunset Landscape Background at the top
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: MediaQuery.of(context).size.height * 0.58,
            child: Stack(
              fit: StackFit.expand,
              children: [
                Image.memory(
                  kHeroSunsetBytes,
                  fit: BoxFit.cover,
                  errorBuilder: (ctx, err, stack) =>
                      Image.asset('assets/hero_sunset.webp', fit: BoxFit.cover),
                ),
                // Gradient overlay fading into active background
                DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        palette.bannerOverlayTop,
                        Colors.transparent,
                        palette.bg.withValues(alpha: 0.75),
                        palette.bg,
                      ],
                      stops: const [0.0, 0.35, 0.85, 1.0],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // 2. Main Scrollable Content
          SafeArea(
            child: Column(
              children: [
                // Top App Bar: 3-line menu button on left + Piglix Studio title
                _buildTopBar(palette),

                // Static, properly-fitted content without scrolling
                Expanded(
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final avail = constraints.maxHeight;
                      const baseContentHeight = 630.0;

                      Widget buildStaticColumn({bool withSpacer = true}) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            mainAxisSize: withSpacer
                                ? MainAxisSize.max
                                : MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              if (withSpacer) const Spacer(),
                              _buildHeroTextSection(palette),
                              const SizedBox(height: 10),
                              _buildStartBuildingButton(),
                              const SizedBox(height: 10),
                              _buildQuickActionCards(palette),
                              const SizedBox(height: 10),
                              _buildEngineSection(palette),
                              const SizedBox(height: 10),
                              _buildShaderNameSection(palette),
                              const SizedBox(height: 16),
                              _buildUploadCards(palette),
                              const SizedBox(height: 10),
                            ],
                          ),
                        );
                      }

                      if (avail < baseContentHeight) {
                        return Center(
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            alignment: Alignment.bottomCenter,
                            child: SizedBox(
                              width: constraints.maxWidth,
                              height: baseContentHeight,
                              child: buildStaticColumn(withSpacer: false),
                            ),
                          ),
                        );
                      }

                      return buildStaticColumn(withSpacer: true);
                    },
                  ),
                ),
                // Fixed Bottom Navigation Bar matching reference
                _buildBottomNavBar(palette),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 1. Top Bar: Hamburger button on Left + Centered Shader Generator Title + Theme Toggle
  Widget _buildTopBar(AppPalette palette) {
    const s = 2.5;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          // 3-Line Hamburger Menu Button
          GestureDetector(
            onTap: () => _scaffoldKey.currentState?.openDrawer(),
            child: CustomPaint(
              painter: _PixelatedCardPainter(
                fillColor: palette.card,
                borderColor: const Color(0xFF22C55E),
                borderWidth: 1.5,
                step: s,
                hasShadow: true,
              ),
              foregroundPainter: _PixelatedBorderPainter(
                borderColor: const Color(0xFF22C55E),
                borderWidth: 1.5,
                step: s,
              ),
              child: ClipPath(
                clipper: _PixelatedClipper(s),
                child: SizedBox(
                  width: 42,
                  height: 42,
                  child: Icon(
                    Icons.menu_rounded,
                    color: palette.textPrimary,
                    size: 24,
                  ),
                ),
              ),
            ),
          ),
          // Centered Title & Subtitle matching reference screenshot
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Shader ',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                        color: palette.textPrimary,
                        letterSpacing: -0.3,
                        shadows: const [
                          Shadow(
                            color: Colors.black87,
                            blurRadius: 8,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                    ),
                    const Text(
                      'Generator',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF22C55E),
                        letterSpacing: -0.3,
                        shadows: [
                          Shadow(
                            color: Colors.black87,
                            blurRadius: 8,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 3),
                const Text(
                  'FOR MCPE',
                  style: TextStyle(
                    fontSize: 11.0,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF64748B),
                    letterSpacing: 2.8,
                    shadows: [
                      Shadow(
                        color: Colors.black87,
                        blurRadius: 4,
                        offset: Offset(0, 1),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Balancer on right so title remains centered
          const SizedBox(width: 42),
        ],
      ),
    );
  }

  // 2. Hero Text Section matching exact screenshot (Bold, Thick, Big normal font)
  Widget _buildHeroTextSection(AppPalette palette) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 28,
          height: 4.0,
          decoration: BoxDecoration(
            color: const Color(0xFF22C55E),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(height: 8),
        RichText(
          text: TextSpan(
            style: TextStyle(
              fontSize: 30.0,
              fontWeight: FontWeight.w900,
              height: 1.05,
              letterSpacing: -0.5,
              shadows: [
                Shadow(
                  color: palette.isDark ? Colors.black : Colors.black26,
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            children: [
              TextSpan(
                text: 'Create\nStunning\n',
                style: TextStyle(color: palette.textPrimary),
              ),
              const TextSpan(
                text: 'Shaders\n',
                style: TextStyle(color: Color(0xFF22C55E)),
              ),
              TextSpan(
                text: 'for MCPE',
                style: TextStyle(
                  color: palette.textPrimary,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Simple. Powerful. Fully Customizable.',
          style: TextStyle(
            fontSize: 13.0,
            fontWeight: FontWeight.w600,
            color: palette.textSecondary,
            letterSpacing: 0.2,
          ),
        ),
      ],
    );
  }

  // 3. CTA Button: START GENERATING with Real Diamond Pickaxe, Pixelated Border, and Centered Text
  Widget _buildStartBuildingButton() {
    const s = 4.0;
    return SizedBox(
      height: 54,
      child: CustomPaint(
        painter: _PixelatedCardPainter(
          fillColor: const Color(0xFF16A34A),
          borderColor: const Color(0xFF4ADE80),
          borderWidth: 2.0,
          step: s,
          hasShadow: true,
        ),
        foregroundPainter: _PixelatedBorderPainter(
          borderColor: const Color(0xFF4ADE80),
          borderWidth: 2.0,
          step: s,
        ),
        child: ClipPath(
          clipper: _PixelatedClipper(s),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: _openEditor,
              child: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF22C55E), Color(0xFF16A34A)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: const [
                    AnimatedMinecraftIcon(
                      type: VoxelIconType.pickaxe,
                      size: 28,
                    ),
                    SizedBox(width: 12),
                    Text(
                      'START GENERATING',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16.0,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.0,
                        shadows: [
                          Shadow(
                            color: Colors.black54,
                            blurRadius: 4,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // 4. Three Quick Action Cards: PRESETS (Curated Hub), MY SHADERS, COMMUNITY (Explore & Import)
  Widget _buildQuickActionCards(AppPalette palette) {
    return Row(
      children: [
        // 1. PRESETS
        Expanded(
          child: _buildActionTile(
            palette: palette,
            voxelIcon: VoxelIconType.enchantedBook,
            label: 'PRESETS',
            subtitle: 'Ready styles',
            onTap: _openPresetsPage,
          ),
        ),
        const SizedBox(width: 10),
        // 2. MY SHADERS
        Expanded(
          child: _buildActionTile(
            palette: palette,
            voxelIcon: VoxelIconType.chest,
            label: 'MY SHADERS',
            subtitle: 'Saved packs',
            onTap: _openMyShaders,
          ),
        ),
        const SizedBox(width: 10),
        // 3. UPLOAD PACK
        Expanded(
          child: _buildActionTile(
            palette: palette,
            iconData: Icons.file_upload_rounded,
            iconColor: const Color(0xFFA855F7),
            label: 'UPLOAD',
            subtitle: 'Edit existing',
            onTap: _uploadAndParseShader,
          ),
        ),
      ],
    );
  }

  Widget _buildActionTile({
    required AppPalette palette,
    VoxelIconType? voxelIcon,
    IconData? iconData,
    Color? iconColor,
    required String label,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    const s = 3.5;
    return GestureDetector(
      onTap: onTap,
      child: CustomPaint(
        painter: _PixelatedCardPainter(
          fillColor: palette.card,
          borderColor: palette.border,
          borderWidth: 1.4,
          step: s,
          hasShadow: true,
        ),
        foregroundPainter: _PixelatedBorderPainter(
          borderColor: palette.border,
          borderWidth: 1.4,
          step: s,
        ),
        child: ClipPath(
          clipper: _PixelatedClipper(s),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (voxelIcon != null)
                  AnimatedMinecraftIcon(type: voxelIcon, size: 28)
                else if (iconData != null)
                  Icon(iconData, size: 28, color: iconColor ?? Colors.white),
                const SizedBox(height: 6),
                Text(
                  label,
                  style: TextStyle(
                    color: palette.textPrimary,
                    fontSize: 11.5,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.5,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: palette.textSecondary,
                    fontSize: 9.5,
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // 5. RENDER ENGINE Section: RENDER ENGINE Header + Vibrant Engine Card
  Widget _buildEngineSection(AppPalette palette) {
    const s = 3.5;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'RENDER ENGINE',
              style: TextStyle(
                color: palette.textPrimary,
                fontSize: 12.5,
                fontWeight: FontWeight.w900,
                letterSpacing: 0.8,
              ),
            ),
            const SizedBox(width: 6),
            Container(
              width: 15,
              height: 15,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: palette.border, width: 1.2),
              ),
              alignment: Alignment.center,
              child: Text(
                '?',
                style: TextStyle(
                  color: palette.textSecondary,
                  fontSize: 9.5,
                  fontWeight: FontWeight.bold,
                  height: 1.0,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        CustomPaint(
          painter: _PixelatedCardPainter(
            fillColor: palette.card,
            borderColor: const Color(0xFF22C55E),
            borderWidth: 1.8,
            step: s,
            hasShadow: true,
          ),
          foregroundPainter: _PixelatedBorderPainter(
            borderColor: const Color(0xFF22C55E),
            borderWidth: 1.8,
            step: s,
          ),
          child: ClipPath(
            clipper: _PixelatedClipper(s),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
              child: Row(
                children: [
                  const AnimatedMinecraftIcon(
                    type: VoxelIconType.grassBlock,
                    size: 28,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'VIBRANT ENGINE',
                          style: TextStyle(
                            color: palette.textPrimary,
                            fontSize: 13.5,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.8,
                          ),
                        ),
                        const SizedBox(height: 2),
                        const Text(
                          'Minecraft Bedrock JSON Deferred Rendering API',
                          style: TextStyle(
                            color: Color(0xFF22C55E),
                            fontSize: 10.5,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: Color(0xFF22C55E),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.check_rounded,
                      color: Colors.black,
                      size: 16,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  // 6. SHADER NAME Section with Green Pencil + Randomize Dice / Shuffle Button
  Widget _buildShaderNameSection(AppPalette palette) {
    const s = 3.0;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'SHADER NAME',
          style: TextStyle(
            color: palette.textPrimary,
            fontSize: 12.0,
            fontWeight: FontWeight.w900,
            letterSpacing: 0.8,
          ),
        ),
        const SizedBox(height: 6),
        Row(
          children: [
            Expanded(
              child: CustomPaint(
                painter: _PixelatedCardPainter(
                  fillColor: palette.card,
                  borderColor: palette.border,
                  borderWidth: 1.4,
                  step: s,
                  hasShadow: false,
                ),
                foregroundPainter: _PixelatedBorderPainter(
                  borderColor: palette.border,
                  borderWidth: 1.4,
                  step: s,
                ),
                child: ClipPath(
                  clipper: _PixelatedClipper(s),
                  child: Container(
                    height: 48,
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.edit_rounded,
                          color: Color(0xFF22C55E),
                          size: 18,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: TextField(
                            controller: _shaderNameCtrl,
                            style: TextStyle(
                              color: palette.textPrimary,
                              fontSize: 14.0,
                              fontWeight: FontWeight.w800,
                            ),
                            decoration: InputDecoration(
                              border: InputBorder.none,
                              hintText: 'Enter shader name...',
                              hintStyle: TextStyle(
                                color: palette.textMuted,
                                fontSize: 13.0,
                              ),
                              isDense: true,
                              contentPadding: EdgeInsets.zero,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            // Square reload button with exact matching height
            Tooltip(
              message:
                  'Change shader name (Tap to roll, long-press to pick from list)',
              child: GestureDetector(
                onTap: _randomizeShaderName,
                onLongPress: () {
                  showModalBottomSheet(
                    context: context,
                    backgroundColor: Colors.transparent,
                    builder: (ctx) => Container(
                      decoration: BoxDecoration(
                        color: palette.surface,
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(20),
                        ),
                        border: Border.all(color: palette.border),
                      ),
                      padding: const EdgeInsets.symmetric(
                        vertical: 16,
                        horizontal: 16,
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Center(
                            child: Container(
                              width: 36,
                              height: 4,
                              decoration: BoxDecoration(
                                color: palette.border,
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'CHOOSE SHADER NAME',
                            style: TextStyle(
                              color: palette.textPrimary,
                              fontWeight: FontWeight.w900,
                              fontSize: 14,
                              letterSpacing: 0.8,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: _namePresets.map((name) {
                              final isSel = _shaderNameCtrl.text == name;
                              return ChoiceChip(
                                label: Text(name),
                                selected: isSel,
                                onSelected: (_) {
                                  setState(() => _shaderNameCtrl.text = name);
                                  Navigator.pop(ctx);
                                },
                                selectedColor: const Color(0xFF22C55E),
                                labelStyle: TextStyle(
                                  color: isSel
                                      ? Colors.black
                                      : palette.textPrimary,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 12,
                                ),
                              );
                            }).toList(),
                          ),
                          const SizedBox(height: 10),
                        ],
                      ),
                    ),
                  );
                },
                child: CustomPaint(
                  painter: _PixelatedCardPainter(
                    fillColor: palette.card,
                    borderColor: const Color(0xFF22C55E),
                    borderWidth: 1.5,
                    step: s,
                    hasShadow: true,
                  ),
                  foregroundPainter: _PixelatedBorderPainter(
                    borderColor: const Color(0xFF22C55E),
                    borderWidth: 1.5,
                    step: s,
                  ),
                  child: ClipPath(
                    clipper: _PixelatedClipper(s),
                    child: const SizedBox(
                      width: 48,
                      height: 48,
                      child: Center(
                        child: AnimatedMinecraftIcon(
                          type: VoxelIconType.reload,
                          size: 22,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // 7. Custom Pack Logo Upload Card matching Shader Name size, padding & style
  Widget _buildUploadCards(AppPalette palette) {
    final hasLogo = _uploadedLogoBytes != null;
    const s = 3.0;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'PACK ICON',
          style: TextStyle(
            color: palette.textPrimary,
            fontSize: 12.0,
            fontWeight: FontWeight.w900,
            letterSpacing: 0.8,
          ),
        ),
        const SizedBox(height: 6),
        GestureDetector(
          onTap: _pickCustomLogo,
          child: CustomPaint(
            painter: _PixelatedCardPainter(
              fillColor: palette.card,
              borderColor: palette.border,
              borderWidth: 1.4,
              step: s,
              hasShadow: true,
            ),
            foregroundPainter: _PixelatedBorderPainter(
              borderColor: palette.border,
              borderWidth: 1.4,
              step: s,
            ),
            child: ClipPath(
              clipper: _PixelatedClipper(s),
              child: Container(
                height: 48,
                padding: const EdgeInsets.symmetric(horizontal: 14),
                child: Row(
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(
                          color: hasLogo
                              ? const Color(0xFF22C55E)
                              : palette.border,
                          width: 1.2,
                        ),
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: hasLogo
                          ? Image.memory(_uploadedLogoBytes!, fit: BoxFit.cover)
                          : Center(
                              child: Icon(
                                Icons.image_outlined,
                                color: palette.textSecondary,
                                size: 18,
                              ),
                            ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            hasLogo
                                ? (_uploadedLogoName ?? 'Pack Icon')
                                : 'Default Pack Icon',
                            style: TextStyle(
                              color: palette.textPrimary,
                              fontSize: 13.0,
                              fontWeight: FontWeight.w800,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 1),
                          Text(
                            hasLogo
                                ? 'Tap to change 1:1 icon'
                                : 'Tap to set custom 1:1 logo',
                            style: TextStyle(
                              color: palette.textSecondary,
                              fontSize: 10.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: hasLogo
                            ? const Color(0xFF22C55E).withValues(alpha: 0.15)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(
                          color: hasLogo
                              ? const Color(0xFF22C55E)
                              : palette.border,
                          width: 1.2,
                        ),
                      ),
                      alignment: Alignment.center,
                      child: Icon(
                        hasLogo
                            ? Icons.check_rounded
                            : Icons.file_upload_outlined,
                        color: hasLogo
                            ? const Color(0xFF22C55E)
                            : palette.textSecondary,
                        size: 16,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // 8. Fixed Bottom Navigation Bar matching reference screenshot
  Widget _buildBottomNavBar(AppPalette palette) {
    const s = 3.0;
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
      decoration: BoxDecoration(
        color: palette.surface,
        border: Border(top: BorderSide(color: palette.border, width: 1.0)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          // 1. BUILDER (Active Green Pill with pixelated corners)
          GestureDetector(
            onTap: _openEditor,
            child: CustomPaint(
              painter: _PixelatedCardPainter(
                fillColor: const Color(0xFF22C55E),
                borderColor: const Color(0xFF4ADE80),
                borderWidth: 1.5,
                step: s,
                hasShadow: true,
              ),
              foregroundPainter: _PixelatedBorderPainter(
                borderColor: const Color(0xFF4ADE80),
                borderWidth: 1.5,
                step: s,
              ),
              child: ClipPath(
                clipper: _PixelatedClipper(s),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 8,
                  ),
                  child: const Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.inventory_2_rounded,
                        color: Colors.black,
                        size: 22,
                      ),
                      SizedBox(height: 2),
                      Text(
                        'BUILDER',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 10.5,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.6,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          // 2. GALLERY
          GestureDetector(
            onTap: _openMyShaders,
            behavior: HitTestBehavior.opaque,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.map_rounded,
                  color: Color(0xFF60A5FA),
                  size: 22,
                ),
                const SizedBox(height: 3),
                Text(
                  'GALLERY',
                  style: TextStyle(
                    color: palette.textSecondary,
                    fontSize: 9.5,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
          // 3. PRESETS
          GestureDetector(
            onTap: _openPresetsPage,
            behavior: HitTestBehavior.opaque,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const AnimatedMinecraftIcon(
                  type: VoxelIconType.enchantedBook,
                  size: 22,
                ),
                const SizedBox(height: 3),
                Text(
                  'PRESETS',
                  style: TextStyle(
                    color: palette.textSecondary,
                    fontSize: 9.5,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
          // 4. SETTINGS
          GestureDetector(
            onTap: () => _scaffoldKey.currentState?.openDrawer(),
            behavior: HitTestBehavior.opaque,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.settings_rounded,
                  color: palette.textSecondary,
                  size: 22,
                ),
                const SizedBox(height: 3),
                Text(
                  'SETTINGS',
                  style: TextStyle(
                    color: palette.textSecondary,
                    fontSize: 9.5,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawer(BuildContext context) {
    final topPadding = MediaQuery.paddingOf(context).top;
    final palette = AppPalette(true);
    return Drawer(
      backgroundColor: palette.drawerBg,
      surfaceTintColor: Colors.transparent,
      width: MediaQuery.of(context).size.width > 420
          ? 320
          : MediaQuery.of(context).size.width * 0.82,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.horizontal(right: Radius.circular(20)),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 1. Drawer Header with Cool Hero Sunset Banner & Project Title + Theme Switcher on top left
          _buildDrawerHeader(context, topPadding),

          // 2. Navigation items with minimal headings & proper spacing/padding
          Expanded(
            child: ListView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 14),
              children: [
                _buildDrawerSectionLabel('EDITOR & TOOLS', palette),
                const SizedBox(height: 6),
                _drawerTile(
                  palette: palette,
                  icon: Icons.tune_rounded,
                  iconColor: const Color(0xFF22C55E),
                  title: 'Shader Editor',
                  onTap: () {
                    Navigator.pop(context);
                    _openEditor();
                  },
                ),
                _drawerTile(
                  palette: palette,
                  voxelIcon: VoxelIconType.chest,
                  iconColor: const Color(0xFF38BDF8),
                  title: 'My Shaders',
                  onTap: () {
                    Navigator.pop(context);
                    _openMyShaders();
                  },
                ),
                _drawerTile(
                  palette: palette,
                  voxelIcon: VoxelIconType.enchantedBook,
                  iconColor: const Color(0xFFF59E0B),
                  title: 'Shader Presets',
                  onTap: () {
                    Navigator.pop(context);
                    _openPresetsPage();
                  },
                ),
                _drawerTile(
                  palette: palette,
                  icon: Icons.file_upload_rounded,
                  iconColor: const Color(0xFFA855F7),
                  title: 'Upload & Edit Pack',
                  onTap: () {
                    Navigator.pop(context);
                    _uploadAndParseShader();
                  },
                ),

                const SizedBox(height: 14),
                Divider(color: palette.divider, height: 1),
                const SizedBox(height: 14),

                _buildDrawerSectionLabel('LEGAL & POLICIES', palette),
                const SizedBox(height: 6),
                _drawerTile(
                  palette: palette,
                  icon: Icons.shield_outlined,
                  iconColor: const Color(0xFF2DD4BF),
                  title: 'Privacy Policy',
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            const LegalPage(type: LegalType.privacy),
                      ),
                    );
                  },
                ),
                _drawerTile(
                  palette: palette,
                  icon: Icons.description_outlined,
                  iconColor: const Color(0xFF818CF8),
                  title: 'Terms of Service',
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const LegalPage(type: LegalType.terms),
                      ),
                    );
                  },
                ),
                _drawerTile(
                  palette: palette,
                  icon: Icons.verified_user_outlined,
                  iconColor: const Color(0xFFF59E0B),
                  title: 'Trademark & Notice',
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            const LegalPage(type: LegalType.trademark),
                      ),
                    );
                  },
                ),
                _drawerTile(
                  palette: palette,
                  icon: Icons.code_rounded,
                  iconColor: const Color(0xFF94A3B8),
                  title: 'Open Source Licenses',
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            const LegalPage(type: LegalType.licenses),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),

          // 3. Drawer Footer: strictly "Created by Piglix Labs" with standard modern typography
          Container(
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
            decoration: BoxDecoration(
              color: palette.drawerBg,
              border: Border(
                top: BorderSide(color: palette.border, width: 1.0),
              ),
            ),
            child: SafeArea(
              top: false,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 7,
                    height: 7,
                    decoration: const BoxDecoration(
                      color: Color(0xFF22C55E),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Color(0xFF22C55E),
                          blurRadius: 6,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  RichText(
                    text: TextSpan(
                      style: const TextStyle(
                        fontSize: 12.5,
                        letterSpacing: 0.3,
                      ),
                      children: [
                        TextSpan(
                          text: 'Created by ',
                          style: TextStyle(
                            color: palette.textSecondary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const TextSpan(
                          text: 'Piglix Labs',
                          style: TextStyle(
                            color: Color(0xFF22C55E),
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerHeader(BuildContext context, double topPadding) {
    final palette = AppPalette(true);
    return Container(
      height: 180 + topPadding,
      decoration: BoxDecoration(
        color: palette.surface,
        border: Border(bottom: BorderSide(color: palette.border, width: 1.2)),
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          // 1. Hero Sunset Landscape image matching home page
          Image.memory(
            kHeroSunsetBytes,
            fit: BoxFit.cover,
            errorBuilder: (ctx, err, stack) => Image.asset(
              'assets/hero_sunset.webp',
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) =>
                  Container(color: palette.surface),
            ),
          ),

          // 2. Dark Gradient overlay fading into drawer background
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withValues(alpha: 0.35),
                  palette.drawerBg.withValues(alpha: 0.55),
                  palette.drawerBg,
                ],
                stops: const [0.0, 0.45, 1.0],
              ),
            ),
          ),

          // 3. Header content
          Padding(
            padding: EdgeInsets.fromLTRB(16, topPadding + 12, 16, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Top Row: Close button on right
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    // Close Button on Right
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      behavior: HitTestBehavior.opaque,
                      child: Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: const Color(
                            0xFF0E1722,
                          ).withValues(alpha: 0.85),
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white24, width: 1),
                        ),
                        child: const Icon(
                          Icons.close_rounded,
                          color: Colors.white,
                          size: 18,
                        ),
                      ),
                    ),
                  ],
                ),

                // Bottom Identity: Clean Project Title & Subtitle Badge
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Shader ',
                          style: TextStyle(
                            color: palette.textPrimary,
                            fontSize: 22,
                            fontWeight: FontWeight.w900,
                            letterSpacing: -0.4,
                          ),
                        ),
                        const Text(
                          'Generator',
                          style: TextStyle(
                            color: Color(0xFF22C55E),
                            fontSize: 22,
                            fontWeight: FontWeight.w900,
                            letterSpacing: -0.4,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'FOR MINECRAFT PE • BEDROCK RTX',
                      style: TextStyle(
                        color: palette.textSecondary,
                        fontSize: 9.5,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerSectionLabel(String label, AppPalette palette) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 4, 4, 4),
      child: Text(
        label,
        style: TextStyle(
          color: palette.textSecondary,
          fontSize: 10.5,
          fontWeight: FontWeight.w800,
          letterSpacing: 1.5,
        ),
      ),
    );
  }

  Widget _drawerTile({
    required AppPalette palette,
    IconData? icon,
    VoxelIconType? voxelIcon,
    Color iconColor = const Color(0xFF22C55E),
    required String title,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: palette.cardElevated,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: palette.borderMuted, width: 1.0),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          splashColor: iconColor.withValues(alpha: 0.15),
          highlightColor: iconColor.withValues(alpha: 0.08),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
            child: Row(
              children: [
                if (voxelIcon != null)
                  AnimatedMinecraftIcon(type: voxelIcon, size: 21)
                else if (icon != null)
                  Icon(icon, color: iconColor, size: 21),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      color: palette.textPrimary,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.1,
                    ),
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  color: palette.textSecondary,
                  size: 13,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

enum ShaderIconType {
  morning,
  noon,
  evening,
  night,
  cloudTop,
  cloudBottom,
  rayMorning,
  rayNoon,
  rayEvening,
  rayNight,
  fog,
  torch,
  water,
  rainFog,
  rainWater,
}

/// Inventory-slot color picker: Minecraft bevel frame + scene icon + color swatch.
class MinecraftColorTile extends StatefulWidget {
  final String label;
  final ShaderIconType type;
  final Color color;
  final bool isSelected;
  final Color? selectedBorderColor;
  final VoidCallback onTap;
  final VoidCallback? onColorPick;
  final Color? labelColor;
  final bool showHexBadge;
  final double aspectRatio;

  const MinecraftColorTile({
    super.key,
    required this.label,
    required this.type,
    required this.color,
    this.isSelected = false,
    this.selectedBorderColor,
    required this.onTap,
    this.onColorPick,
    this.labelColor,
    this.showHexBadge = false,
    this.aspectRatio = 0.62,
  });

  @override
  State<MinecraftColorTile> createState() => _MinecraftColorTileState();
}

class _MinecraftColorTileState extends State<MinecraftColorTile>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pressCtrl;
  late final Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _pressCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
      reverseDuration: const Duration(milliseconds: 180),
      lowerBound: 0.0,
      upperBound: 1.0,
    );
    _scaleAnim = Tween<double>(
      begin: 1.0,
      end: 0.94,
    ).animate(CurvedAnimation(parent: _pressCtrl, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _pressCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = widget.color;
    final isSel = widget.isSelected;
    final selBorderColor =
        widget.selectedBorderColor ?? const Color(0xFFE5A04A);

    return GestureDetector(
      onTapDown: (_) => _pressCtrl.forward(),
      onTapUp: (_) {
        _pressCtrl.reverse();
        widget.onTap();
      },
      onTapCancel: () => _pressCtrl.reverse(),
      behavior: HitTestBehavior.opaque,
      child: ScaleTransition(
        scale: _scaleAnim,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Playing card (aspect ratio configurable, 0.62 for vertical card, 1.0 for square)
            AspectRatio(
              aspectRatio: widget.aspectRatio,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    if (isSel)
                      BoxShadow(
                        color: selBorderColor.withValues(alpha: 0.55),
                        blurRadius: 14,
                        spreadRadius: 1.5,
                        offset: const Offset(0, 1),
                      )
                    else
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.60),
                        blurRadius: 6,
                        offset: const Offset(0, 3),
                      ),
                  ],
                ),
                child: RepaintBoundary(
                  child: CustomPaint(
                    painter: _MinecraftCardFramePainter(
                      color: c,
                      isSelected: isSel,
                      selectedBorderColor: selBorderColor,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(3.5),
                      child: ClipPath(
                        clipper: _ChamferedCardClipper(),
                        child: RealisticShaderIcon(
                          type: widget.type,
                          color: c,
                          size: double.infinity,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 7),
            // Card Label underneath in bold, clean typography
            Text(
              widget.label,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontWeight: FontWeight.w900,
                color:
                    widget.labelColor ??
                    (isSel ? selBorderColor : Colors.white),
                fontSize: 11.5,
                letterSpacing: 0.4,
              ),
            ),
            const SizedBox(height: 4),
            // Dedicated interactive Color Badge Button (Single-tap to select & edit color!)
            GestureDetector(
              onTap: widget.onColorPick ?? widget.onTap,
              behavior: HitTestBehavior.opaque,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 4,
                  vertical: 2.0,
                ),
                decoration: BoxDecoration(
                  color: isSel
                      ? c.withValues(alpha: 0.28)
                      : const Color(0xFF131B2A),
                  borderRadius: BorderRadius.circular(5),
                  border: Border.all(
                    color: isSel ? selBorderColor : c.withValues(alpha: 0.65),
                    width: 1.0,
                  ),
                  boxShadow: [
                    if (isSel)
                      BoxShadow(
                        color: selBorderColor.withValues(alpha: 0.35),
                        blurRadius: 4,
                      ),
                  ],
                ),
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 7,
                        height: 7,
                        decoration: BoxDecoration(
                          color: c,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 0.8),
                          boxShadow: [
                            BoxShadow(
                              color: c.withValues(alpha: 0.8),
                              blurRadius: 3,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 3),
                      Text(
                        '#${c.toARGB32().toRadixString(16).substring(2).toUpperCase()}',
                        style: TextStyle(
                          color: isSel ? Colors.white : const Color(0xFFCBD5E1),
                          fontSize: 8.5,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.2,
                        ),
                      ),
                      const SizedBox(width: 2.5),
                      Icon(
                        Icons.edit_rounded,
                        size: 8.5,
                        color: isSel ? selBorderColor : const Color(0xFF94A3B8),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Chamfered 45-degree cut corners clipper for the inner card artwork
class _ChamferedCardClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final w = size.width;
    final h = size.height;
    final cut = w * 0.12;

    return Path()
      ..moveTo(cut, 0)
      ..lineTo(w - cut, 0)
      ..lineTo(w, cut)
      ..lineTo(w, h - cut)
      ..lineTo(w - cut, h)
      ..lineTo(cut, h)
      ..lineTo(0, h - cut)
      ..lineTo(0, cut)
      ..close();
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}

/// Paints the outer Minecraft card frame with chamfered corners, bevel shadow, and tab-matching glow border
class _MinecraftCardFramePainter extends CustomPainter {
  final Color color;
  final bool isSelected;
  final Color selectedBorderColor;

  const _MinecraftCardFramePainter({
    required this.color,
    this.isSelected = false,
    this.selectedBorderColor = const Color(0xFFE5A04A),
  });

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final cut = w * 0.12;

    final outerPath = Path()
      ..moveTo(cut, 0)
      ..lineTo(w - cut, 0)
      ..lineTo(w, cut)
      ..lineTo(w, h - cut)
      ..lineTo(w - cut, h)
      ..lineTo(cut, h)
      ..lineTo(0, h - cut)
      ..lineTo(0, cut)
      ..close();

    // 1. Dark stone/graphite backing
    canvas.drawPath(outerPath, Paint()..color = const Color(0xFF141916));

    if (isSelected) {
      // 2. Selected Card: Glowing outer border matching tab theme!
      canvas.drawPath(
        outerPath,
        Paint()
          ..color = selectedBorderColor
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3.0,
      );

      // Inner subtle glow stroke
      canvas.drawPath(
        outerPath,
        Paint()
          ..color = Color.lerp(
            selectedBorderColor,
            Colors.white,
            0.4,
          )!.withValues(alpha: 0.65)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.0,
      );
    } else {
      // Unselected Card: Dark metallic / bevel frame
      canvas.drawPath(
        outerPath,
        Paint()
          ..color = const Color(0xFF383F4A)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.0,
      );

      canvas.drawPath(
        outerPath,
        Paint()
          ..color = Colors.black.withValues(alpha: 0.7)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.0,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _MinecraftCardFramePainter old) =>
      old.color != color || old.isSelected != isSelected;
}

class MinecraftColorGrid extends StatelessWidget {
  final String title;
  final List<Widget> tiles;
  final double? gap;

  const MinecraftColorGrid({
    super.key,
    required this.title,
    required this.tiles,
    this.gap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // ── Section header (only shown if title is provided, prevents green bar glitch) ──
        if (title.trim().isNotEmpty) ...[
          Row(
            children: [
              Container(
                width: 3.5,
                height: 14,
                decoration: BoxDecoration(
                  color: _green,
                  borderRadius: BorderRadius.circular(2),
                  boxShadow: [
                    BoxShadow(
                      color: _green.withValues(alpha: 0.6),
                      blurRadius: 6,
                    ),
                  ],
                ),
                margin: const EdgeInsets.only(right: 8),
              ),
              Expanded(
                child: Text(
                  title.toUpperCase(),
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 11.5,
                    letterSpacing: 1.4,
                    color: Colors.white70,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
        ],
        // ── Tile grid ──
        LayoutBuilder(
          builder: (context, c) {
            const cols = 4;
            final spacing =
                gap ??
                8.0; // Proper spacing so cards don't touch and look clean
            final count = tiles.length;

            if (count == 0) return const SizedBox.shrink();

            // Uniform tile width across all tabs (2-card and 4-card grids match exactly)
            final baseTileW = math.min(
              (c.maxWidth - (cols - 1) * spacing) / cols,
              82.0,
            );
            final tileW = baseTileW;

            final rows = <Widget>[];
            for (var r = 0; r * cols < count; r++) {
              final start = r * cols;
              final end = math.min(start + cols, count);
              final rowTiles = tiles.sublist(start, end);
              final rowCount = rowTiles.length;

              final rowChildren = [
                for (var i = 0; i < rowCount; i++) ...[
                  SizedBox(width: tileW, child: rowTiles[i]),
                  if (i < rowCount - 1) SizedBox(width: spacing),
                ],
              ];

              rows.add(
                Center(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: rowChildren,
                  ),
                ),
              );
              if (r * cols + cols < count) rows.add(const SizedBox(height: 12));
            }

            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: rows,
            );
          },
        ),
      ],
    );
  }
}

class RealisticShaderIcon extends StatelessWidget {
  final ShaderIconType type;
  final Color color;
  final double size;

  const RealisticShaderIcon({
    super.key,
    required this.type,
    required this.color,
    this.size = double.infinity,
  });

  @override
  Widget build(BuildContext context) {
    if (size == double.infinity) {
      return SizedBox.expand(
        child: RepaintBoundary(
          child: CustomPaint(
            painter: _RealisticShaderPainter(type: type, color: color),
          ),
        ),
      );
    }
    return SizedBox(
      width: size,
      height: size,
      child: RepaintBoundary(
        child: CustomPaint(
          painter: _RealisticShaderPainter(type: type, color: color),
        ),
      ),
    );
  }
}

class _RealisticShaderPainter extends CustomPainter {
  final ShaderIconType type;
  final Color color;

  _RealisticShaderPainter({required this.type, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    canvas.save();
    canvas.clipRect(Rect.fromLTWH(0, 0, w, h));

    switch (type) {
      case ShaderIconType.morning:
        _drawMinecraftMorning(canvas, w, h, color);
        break;
      case ShaderIconType.noon:
        _drawMinecraftNoon(canvas, w, h, color);
        break;
      case ShaderIconType.evening:
        _drawMinecraftEvening(canvas, w, h, color);
        break;
      case ShaderIconType.night:
        _drawMinecraftNight(canvas, w, h, color);
        break;
      case ShaderIconType.cloudTop:
        _drawCloudBlock(canvas, w, h, color, isTop: true);
        break;
      case ShaderIconType.cloudBottom:
        _drawCloudBlock(canvas, w, h, color, isTop: false);
        break;
      case ShaderIconType.rayMorning:
        _drawGodRaysScene(canvas, w, h, color, angle: -0.45);
        break;
      case ShaderIconType.rayNoon:
        _drawGodRaysScene(canvas, w, h, color, angle: 0.0);
        break;
      case ShaderIconType.rayEvening:
        _drawGodRaysScene(canvas, w, h, color, angle: 0.45);
        break;
      case ShaderIconType.rayNight:
        _drawNightRaysScene(canvas, w, h, color);
        break;
      case ShaderIconType.fog:
        _drawFogScene(canvas, w, h, color);
        break;
      case ShaderIconType.torch:
        _drawTorchScene(canvas, w, h, color);
        break;
      case ShaderIconType.water:
        _drawWaterScene(canvas, w, h, color);
        break;
      case ShaderIconType.rainFog:
        _drawRainFogScene(canvas, w, h, color);
        break;
      case ShaderIconType.rainWater:
        _drawRainWaterScene(canvas, w, h, color);
        break;
    }
    canvas.restore();
  }

  // ─────────────────────────────────────────────────────────────────────────
  // 1. MINECRAFT MORNING: Golden Warm Sunrise over Rolling Green Plains
  // Warm orange dawn daybreak Minecraft landscape with rising sun & classic oak tree
  // ─────────────────────────────────────────────────────────────────────────
  void _drawMinecraftMorning(Canvas canvas, double w, double h, Color c) {
    // 1. Warm golden sunrise dawn sky (orange daybreak)
    final skyTop = Color.lerp(const Color(0xFF4B6B94), c, 0.35)!;
    final skyMid = Color.lerp(const Color(0xFFFF9E3D), c, 0.55)!;
    final horizon = Color.lerp(const Color(0xFFFFC043), c, 0.65)!;

    canvas.drawRect(
      Rect.fromLTWH(0, 0, w, h),
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [skyTop, skyMid, horizon],
          stops: const [0.0, 0.42, 0.68],
        ).createShader(Rect.fromLTWH(0, 0, w, h)),
    );

    // 2. High morning voxel clouds
    final cloudLit = Color.lerp(Colors.white, c, 0.20)!;
    final cloudShadow = Color.lerp(const Color(0xFFFFCC80), c, 0.35)!;
    _drawTieredVoxelCloud(
      canvas,
      w * 0.08,
      h * 0.12,
      w * 0.42,
      h * 0.08,
      cloudLit,
      cloudShadow,
    );
    _drawTieredVoxelCloud(
      canvas,
      w * 0.54,
      h * 0.18,
      w * 0.38,
      h * 0.07,
      cloudLit,
      cloudShadow,
    );

    // 3. Distant soft mountain ridge on horizon
    final distHills = Color.lerp(const Color(0xFF7CB342), horizon, 0.40)!;
    _drawDistantForestRidge(canvas, w, h * 0.46, distHills);

    // 4. Low Glowing Square Minecraft Sun on Left Horizon
    final sunX = w * 0.32;
    final sunY = h * 0.44;
    final sunSize = w * 0.21;
    _drawSquareSun(
      canvas,
      sunX,
      sunY,
      sunSize,
      c,
      defaultGlow: const Color(0xFFFFB300),
    );

    // 5. Rolling gentle Minecraft grass hills
    final grassTop = Color.lerp(
      const Color(0xFF558B2F),
      const Color(0xFFFF9E3D),
      0.15,
    )!;
    final dirtSide = const Color(0xFF4E342E);
    // Back hill
    _drawVoxelBlock(
      canvas,
      0,
      h * 0.52,
      w * 0.65,
      h * 0.10,
      grassTop,
      dirtSide,
    );
    // Main foreground hill
    _drawVoxelBlock(canvas, 0, h * 0.60, w, h * 0.40, grassTop, dirtSide);
    _drawVoxelBlock(
      canvas,
      0,
      h * 0.72,
      w * 0.75,
      h * 0.28,
      grassTop,
      dirtSide,
    );

    // 6. Classic Minecraft Oak Tree on the RIGHT hill in morning light
    _drawMinecraftOakTree(
      canvas,
      w * 0.60,
      h * 0.36,
      w * 0.36,
      h * 0.38,
      grassTop,
    );

    // Morning golden light haze across the grass
    canvas.drawRect(
      Rect.fromLTWH(0, h * 0.52, w, h * 0.48),
      Paint()..color = const Color(0xFFFFD54F).withValues(alpha: 0.14),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // 2. MINECRAFT NOON: Clean, Bright Sunny Midday across Plains & Blue River
  // Normal, clean Minecraft daytime landscape with high sun, clouds & river
  // ─────────────────────────────────────────────────────────────────────────
  void _drawMinecraftNoon(Canvas canvas, double w, double h, Color c) {
    // 1. Clear vivid azure daytime sky
    final skyTop = Color.lerp(const Color(0xFF1976D2), c, 0.35)!;
    final skyMid = Color.lerp(const Color(0xFF42A5F5), c, 0.38)!;
    final horizon = Color.lerp(const Color(0xFF90CAF9), c, 0.42)!;

    canvas.drawRect(
      Rect.fromLTWH(0, 0, w, h),
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [skyTop, skyMid, horizon],
          stops: const [0.0, 0.45, 0.68],
        ).createShader(Rect.fromLTWH(0, 0, w, h)),
    );

    // 2. High Bright Square Minecraft Sun (upper right)
    final sunX = w * 0.55;
    final sunY = h * 0.15;
    final sunSize = w * 0.22;
    _drawSquareSun(canvas, sunX, sunY, sunSize, c, defaultGlow: Colors.white);

    // 3. Classic Fluffy White 3D Minecraft Cumulus Clouds
    final cloudLit = Colors.white;
    final cloudShadow = const Color(0xFFCFD8DC);
    _drawTieredVoxelCloud(
      canvas,
      w * 0.06,
      h * 0.16,
      w * 0.45,
      h * 0.09,
      cloudLit,
      cloudShadow,
    );
    _drawTieredVoxelCloud(
      canvas,
      w * 0.52,
      h * 0.24,
      w * 0.42,
      h * 0.08,
      cloudLit,
      cloudShadow,
    );

    // 4. Distant soft blue-green hills on horizon
    final distRidge = Color.lerp(const Color(0xFF64B5F6), c, 0.30)!;
    _drawVoxelMountainRidge(canvas, w, h * 0.46, distRidge, step: 1);

    // 5. River flowing through the center towards viewer
    final riverColor = Color.lerp(const Color(0xFF1E88E5), c, 0.40)!;
    final riverPath = Path()
      ..moveTo(w * 0.36, h * 0.52)
      ..lineTo(w * 0.62, h * 0.52)
      ..lineTo(w * 0.74, h)
      ..lineTo(w * 0.22, h)
      ..close();
    canvas.drawPath(riverPath, Paint()..color = riverColor);

    // Clean sky reflection ripples down the river
    final reflColor = Color.lerp(const Color(0xFFE3F2FD), c, 0.45)!;
    _drawRiverSkyReflection(canvas, w, h, 0.48, 0.52, reflColor);

    // 6. Lush green Minecraft stepped banks
    final grassTop = Color.lerp(const Color(0xFF4CAF50), c, 0.22)!;
    final dirtSide = const Color(0xFF4E342E);
    // Left Bank
    _drawVoxelBlock(
      canvas,
      0,
      h * 0.52,
      w * 0.36,
      h * 0.08,
      grassTop,
      dirtSide,
    );
    _drawVoxelBlock(
      canvas,
      0,
      h * 0.60,
      w * 0.30,
      h * 0.10,
      grassTop,
      dirtSide,
    );
    _drawVoxelBlock(
      canvas,
      0,
      h * 0.70,
      w * 0.24,
      h * 0.30,
      grassTop,
      dirtSide,
    );
    // Right Bank
    _drawVoxelBlock(
      canvas,
      w * 0.62,
      h * 0.52,
      w * 0.38,
      h * 0.08,
      grassTop,
      dirtSide,
    );
    _drawVoxelBlock(
      canvas,
      w * 0.68,
      h * 0.60,
      w * 0.32,
      h * 0.10,
      grassTop,
      dirtSide,
    );
    _drawVoxelBlock(
      canvas,
      w * 0.74,
      h * 0.70,
      w * 0.26,
      h * 0.30,
      grassTop,
      dirtSide,
    );

    // 7. Tall classic Minecraft Oak Tree on the LEFT bank
    _drawMinecraftOakTree(
      canvas,
      w * 0.04,
      h * 0.30,
      w * 0.38,
      h * 0.40,
      grassTop,
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // 3. MINECRAFT EVENING: Cinematic Sunset over Distant Silhouette Ridges
  // Normal, clean Minecraft twilight landscape with large setting sun
  // ─────────────────────────────────────────────────────────────────────────
  void _drawMinecraftEvening(Canvas canvas, double w, double h, Color c) {
    // 1. Fiery twilight sunset gradient (purple to coral to golden orange)
    final skyTop = Color.lerp(const Color(0xFF4A148C), c, 0.45)!;
    final skyMid = Color.lerp(const Color(0xFFE91E63), c, 0.50)!;
    final horizon = Color.lerp(const Color(0xFFFF6D00), c, 0.58)!;

    canvas.drawRect(
      Rect.fromLTWH(0, 0, w, h),
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [skyTop, skyMid, horizon],
          stops: const [0.0, 0.40, 0.68],
        ).createShader(Rect.fromLTWH(0, 0, w, h)),
    );

    // 2. Sunset-lit flat voxel clouds
    final cloudLit = Color.lerp(const Color(0xFFFF8A80), c, 0.35)!;
    final cloudShadow = Color.lerp(const Color(0xFF880E4F), c, 0.42)!;
    _drawTieredVoxelCloud(
      canvas,
      w * 0.08,
      h * 0.14,
      w * 0.42,
      h * 0.07,
      cloudLit,
      cloudShadow,
    );
    _drawTieredVoxelCloud(
      canvas,
      w * 0.54,
      h * 0.22,
      w * 0.38,
      h * 0.06,
      cloudLit,
      cloudShadow,
    );

    // 3. Layered distant mountain ridges against the sunset
    final ridgeFar = Color.lerp(const Color(0xFF5D2417), horizon, 0.30)!;
    _drawDistantForestRidge(canvas, w, h * 0.46, ridgeFar);

    // 4. Large Glowing Setting Square Minecraft Sun on Center Horizon
    final sunX = w * 0.48;
    final sunY = h * 0.48;
    final sunSize = w * 0.23;
    _drawSquareSun(
      canvas,
      sunX,
      sunY,
      sunSize,
      c,
      defaultGlow: const Color(0xFFFFD600),
    );

    // 5. Rolling hills in warm evening sunset tone
    final grassEvening = Color.lerp(const Color(0xFF33691E), horizon, 0.35)!;
    final dirtEvening = const Color(0xFF3E2723);
    _drawVoxelBlock(
      canvas,
      0,
      h * 0.54,
      w,
      h * 0.46,
      grassEvening,
      dirtEvening,
    );
    _drawVoxelBlock(
      canvas,
      0,
      h * 0.66,
      w * 0.85,
      h * 0.34,
      grassEvening,
      dirtEvening,
    );
    _drawVoxelBlock(
      canvas,
      0,
      h * 0.78,
      w * 0.60,
      h * 0.22,
      grassEvening,
      dirtEvening,
    );

    // 6. Classic Minecraft Oak Tree silhouetted on the RIGHT edge
    _drawMinecraftOakTree(
      canvas,
      w * 0.60,
      h * 0.36,
      w * 0.36,
      h * 0.38,
      grassEvening,
      isSilhouette: true,
    );

    // Warm golden hour sunlight cast across the hills
    canvas.drawRect(
      Rect.fromLTWH(0, h * 0.54, w, h * 0.46),
      Paint()..color = const Color(0xFFFF6D00).withValues(alpha: 0.14),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // 4. MINECRAFT NIGHT: Serene Cosmic Starry Night with Crescent Moon
  // Normal, clean Minecraft night landscape with stars, crescent moon & trees
  // ─────────────────────────────────────────────────────────────────────────
  void _drawMinecraftNight(Canvas canvas, double w, double h, Color c) {
    // 1. Deep cosmic midnight dark navy sky
    final skyTop = Color.lerp(const Color(0xFF030812), c, 0.25)!;
    final skyMid = Color.lerp(const Color(0xFF0A1830), c, 0.30)!;
    final horizon = Color.lerp(const Color(0xFF102848), c, 0.35)!;

    canvas.drawRect(
      Rect.fromLTWH(0, 0, w, h),
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [skyTop, skyMid, horizon],
          stops: const [0.0, 0.50, 0.72],
        ).createShader(Rect.fromLTWH(0, 0, w, h)),
    );

    // 2. Twinkling Minecraft Square Pixel Stars
    _drawMinecraftStars(canvas, w, h);

    // 3. Luminous Glowing Pixel Crescent Moon in upper right sky
    final moonX = w * 0.66;
    final moonY = h * 0.18;
    final moonSize = w * 0.28;
    _drawPixelCrescentMoon(canvas, moonX, moonY, moonSize, c);

    // 4. Distant dark mountain ridge on horizon
    final nightHorizon = Color.lerp(const Color(0xFF040A14), c, 0.20)!;
    _drawDistantForestRidge(canvas, w, h * 0.48, nightHorizon);

    // 5. Calm dark river/lake in center reflecting moonlight
    final waterNight = Color.lerp(const Color(0xFF08182B), c, 0.30)!;
    final riverPath = Path()
      ..moveTo(w * 0.36, h * 0.54)
      ..lineTo(w * 0.60, h * 0.54)
      ..lineTo(w * 0.74, h)
      ..lineTo(w * 0.22, h)
      ..close();
    canvas.drawPath(riverPath, Paint()..color = waterNight);

    // Silvery moonlight reflection down the water
    final moonRefl = Color.lerp(const Color(0xFFE2F1FF), c, 0.38)!;
    _drawRiverReflection(canvas, w, h, 0.48, 0.54, moonRefl, isNight: true);

    // 6. Dark nighttime stepped voxel grass banks
    final grassNight = Color.lerp(const Color(0xFF0E2218), c, 0.20)!;
    final dirtNight = const Color(0xFF181311);
    _drawVoxelBlock(
      canvas,
      0,
      h * 0.54,
      w * 0.36,
      h * 0.08,
      grassNight,
      dirtNight,
    );
    _drawVoxelBlock(
      canvas,
      0,
      h * 0.62,
      w * 0.30,
      h * 0.10,
      grassNight,
      dirtNight,
    );
    _drawVoxelBlock(
      canvas,
      0,
      h * 0.72,
      w * 0.24,
      h * 0.28,
      grassNight,
      dirtNight,
    );

    _drawVoxelBlock(
      canvas,
      w * 0.60,
      h * 0.54,
      w * 0.40,
      h * 0.08,
      grassNight,
      dirtNight,
    );
    _drawVoxelBlock(
      canvas,
      w * 0.66,
      h * 0.62,
      w * 0.34,
      h * 0.10,
      grassNight,
      dirtNight,
    );
    _drawVoxelBlock(
      canvas,
      w * 0.72,
      h * 0.72,
      w * 0.28,
      h * 0.28,
      grassNight,
      dirtNight,
    );

    // 7. Dark Minecraft spruce / pine tree on the left and oak on right
    _drawMinecraftSpruceTree(
      canvas,
      w * 0.06,
      h * 0.36,
      w * 0.28,
      h * 0.38,
      grassNight,
    );
    _drawMinecraftOakTree(
      canvas,
      w * 0.68,
      h * 0.38,
      w * 0.30,
      h * 0.34,
      grassNight,
      isSilhouette: true,
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // MINECRAFT PROCEDURAL ENGINE HELPERS (Trees, Moon, Sun, Clouds, Voxel Blocks)
  // ─────────────────────────────────────────────────────────────────────────

  /// Draws an authentic Minecraft Crescent Moon out of stepped pixel blocks
  void _drawPixelCrescentMoon(
    Canvas canvas,
    double cx,
    double cy,
    double size,
    Color c,
  ) {
    // Outer moonlight radial aura
    canvas.drawCircle(
      Offset(cx, cy),
      size * 1.25,
      Paint()
        ..shader =
            RadialGradient(
              colors: [
                Color.lerp(Colors.white, c, 0.35)!.withValues(alpha: 0.40),
                Color.lerp(
                  const Color(0xFF90CAF9),
                  c,
                  0.45,
                )!.withValues(alpha: 0.18),
                Colors.transparent,
              ],
            ).createShader(
              Rect.fromCircle(center: Offset(cx, cy), radius: size * 1.25),
            ),
    );

    final moonColor = Color.lerp(Colors.white, c, 0.15)!;
    final p = size / 8.0;
    final startX = cx - size * 0.5;
    final startY = cy - size * 0.5;

    // 8x8 Pixel Grid definition for crescent moon facing left
    const pixelCoords = [
      [3, 0],
      [4, 0],
      [2, 1],
      [3, 1],
      [4, 1],
      [1, 2],
      [2, 2],
      [3, 2],
      [1, 3],
      [2, 3],
      [1, 4],
      [2, 4],
      [1, 5],
      [2, 5],
      [3, 5],
      [2, 6],
      [3, 6],
      [4, 6],
      [3, 7],
      [4, 7],
    ];

    final paint = Paint()..color = moonColor;
    for (final pt in pixelCoords) {
      canvas.drawRect(
        Rect.fromLTWH(startX + pt[0] * p, startY + pt[1] * p, p, p),
        paint,
      );
    }

    // Soft pixel highlight in center
    final innerHighlight = Paint()..color = Colors.white;
    canvas.drawRect(
      Rect.fromLTWH(startX + 2 * p, startY + 3 * p, p * 0.8, p * 2),
      innerHighlight,
    );
  }

  /// Draws the square Minecraft Sun with radial bloom
  void _drawSquareSun(
    Canvas canvas,
    double cx,
    double cy,
    double size,
    Color c, {
    required Color defaultGlow,
  }) {
    // Soft outer atmospheric bloom
    canvas.drawCircle(
      Offset(cx, cy),
      size * 1.75,
      Paint()
        ..shader =
            RadialGradient(
              colors: [
                Colors.white.withValues(alpha: 0.95),
                Color.lerp(defaultGlow, c, 0.45)!.withValues(alpha: 0.65),
                c.withValues(alpha: 0.25),
                Colors.transparent,
              ],
              stops: const [0.0, 0.35, 0.70, 1.0],
            ).createShader(
              Rect.fromCircle(center: Offset(cx, cy), radius: size * 1.75),
            ),
    );

    // Square Minecraft Sun glow frame
    canvas.drawRect(
      Rect.fromCenter(
        center: Offset(cx, cy),
        width: size * 1.15,
        height: size * 1.15,
      ),
      Paint()
        ..color = Color.lerp(defaultGlow, c, 0.40)!.withValues(alpha: 0.50),
    );

    // Bright Square Minecraft Sun
    canvas.drawRect(
      Rect.fromCenter(center: Offset(cx, cy), width: size, height: size),
      Paint()..color = Color.lerp(Colors.white, c, 0.15)!,
    );
  }

  /// Tiered 3D Minecraft voxel cloud (lit top face, shaded under-edge)
  void _drawTieredVoxelCloud(
    Canvas canvas,
    double x,
    double y,
    double width,
    double height,
    Color litColor,
    Color shadowColor,
  ) {
    // Cloud shadow base
    canvas.drawRect(
      Rect.fromLTWH(x, y + height * 0.35, width, height * 0.65),
      Paint()..color = shadowColor.withValues(alpha: 0.85),
    );
    // Cloud lit top
    canvas.drawRect(
      Rect.fromLTWH(x + width * 0.05, y, width * 0.90, height * 0.65),
      Paint()..color = litColor.withValues(alpha: 0.95),
    );
    // Inner stepped cloud puff
    canvas.drawRect(
      Rect.fromLTWH(
        x + width * 0.20,
        y - height * 0.25,
        width * 0.50,
        height * 0.50,
      ),
      Paint()..color = litColor.withValues(alpha: 0.95),
    );
  }

  /// Authentic Minecraft Oak Tree with brown wood trunk and multi-layered foliage boxes
  void _drawMinecraftOakTree(
    Canvas canvas,
    double x,
    double y,
    double width,
    double height,
    Color leafBase, {
    bool isSilhouette = false,
  }) {
    final trunkColor = isSilhouette
        ? const Color(0xFF1E1513)
        : const Color(0xFF4E342E);
    final trunkGrain = isSilhouette
        ? const Color(0xFF140D0C)
        : const Color(0xFF3E2723);

    // 1. Trunk
    final trunkW = width * 0.18;
    final trunkH = height * 0.50;
    final trunkX = x + width * 0.41;
    final trunkY = y + height * 0.50;
    canvas.drawRect(
      Rect.fromLTWH(trunkX, trunkY, trunkW, trunkH),
      Paint()..color = trunkColor,
    );
    canvas.drawRect(
      Rect.fromLTWH(trunkX + 2, trunkY, trunkW * 0.35, trunkH),
      Paint()..color = trunkGrain,
    );

    // 2. Leaf Layers
    final leafHighlight = isSilhouette
        ? Color.lerp(leafBase, const Color(0xFFFF8A65), 0.35)! // warm rim light
        : Color.lerp(leafBase, Colors.white, 0.22)!;
    final leafShadow = isSilhouette
        ? const Color(0xFF0A0F0D)
        : Color.lerp(leafBase, Colors.black, 0.35)!;

    // Layer 1: Bottom wide foliage box
    _drawVoxelFoliageBox(
      canvas,
      x + width * 0.06,
      y + height * 0.32,
      width * 0.88,
      height * 0.28,
      leafBase,
      leafHighlight,
      leafShadow,
    );

    // Layer 2: Middle foliage box
    _drawVoxelFoliageBox(
      canvas,
      x + width * 0.14,
      y + height * 0.14,
      width * 0.72,
      height * 0.26,
      leafBase,
      leafHighlight,
      leafShadow,
    );

    // Layer 3: Top cap foliage box
    _drawVoxelFoliageBox(
      canvas,
      x + width * 0.26,
      y,
      width * 0.48,
      height * 0.22,
      leafBase,
      leafHighlight,
      leafShadow,
    );
  }

  /// Individual 3D Minecraft foliage box with lit top and shaded bottom
  void _drawVoxelFoliageBox(
    Canvas canvas,
    double x,
    double y,
    double w,
    double h,
    Color base,
    Color topLit,
    Color botShadow,
  ) {
    // Bottom shadow band
    canvas.drawRect(
      Rect.fromLTWH(x, y + h * 0.55, w, h * 0.45),
      Paint()..color = botShadow,
    );
    // Center base band
    canvas.drawRect(
      Rect.fromLTWH(x, y + h * 0.20, w, h * 0.55),
      Paint()..color = base,
    );
    // Top lit band
    canvas.drawRect(Rect.fromLTWH(x, y, w, h * 0.30), Paint()..color = topLit);
  }

  /// Minecraft Spruce/Pine Tree (conical tiered foliage)
  void _drawMinecraftSpruceTree(
    Canvas canvas,
    double x,
    double y,
    double width,
    double height,
    Color leafBase,
  ) {
    // Trunk
    final trunkX = x + width * 0.43;
    final trunkY = y + height * 0.50;
    canvas.drawRect(
      Rect.fromLTWH(trunkX, trunkY, width * 0.14, height * 0.50),
      Paint()..color = const Color(0xFF2E1C14),
    );

    final leafLit = Color.lerp(leafBase, Colors.white, 0.15)!;
    final leafDark = Color.lerp(leafBase, Colors.black, 0.40)!;

    // Tier 4 (bottom)
    _drawVoxelFoliageBox(
      canvas,
      x + width * 0.08,
      y + height * 0.44,
      width * 0.84,
      height * 0.20,
      leafBase,
      leafLit,
      leafDark,
    );
    // Tier 3
    _drawVoxelFoliageBox(
      canvas,
      x + width * 0.18,
      y + height * 0.28,
      width * 0.64,
      height * 0.20,
      leafBase,
      leafLit,
      leafDark,
    );
    // Tier 2
    _drawVoxelFoliageBox(
      canvas,
      x + width * 0.28,
      y + height * 0.14,
      width * 0.44,
      height * 0.18,
      leafBase,
      leafLit,
      leafDark,
    );
    // Tier 1 (top tip)
    _drawVoxelFoliageBox(
      canvas,
      x + width * 0.38,
      y,
      width * 0.24,
      height * 0.18,
      leafBase,
      leafLit,
      leafDark,
    );
  }

  /// Stepped Minecraft Voxel Terrain Block (green grass top with jagged overhang + brown dirt)
  void _drawVoxelBlock(
    Canvas canvas,
    double x,
    double y,
    double width,
    double height,
    Color grassColor,
    Color dirtColor,
  ) {
    // Dirt body
    canvas.drawRect(
      Rect.fromLTWH(x, y, width, height),
      Paint()..color = dirtColor,
    );

    // Grass top strip
    final grassH = height * 0.32;
    canvas.drawRect(
      Rect.fromLTWH(x, y, width, grassH),
      Paint()..color = grassColor,
    );

    // Stepped jagged pixel grass overhangs (Minecraft style)
    final overhangPaint = Paint()..color = grassColor;
    final stepW = width * 0.16;
    for (var i = 0; i < 6; i++) {
      if (i % 2 == 1) {
        canvas.drawRect(
          Rect.fromLTWH(x + i * stepW, y + grassH, stepW, grassH * 0.45),
          overhangPaint,
        );
      }
    }
  }

  /// Stepped horizontal specular ripple path down the river
  void _drawRiverReflection(
    Canvas canvas,
    double w,
    double h,
    double centerXRatio,
    double startYRatio,
    Color reflColor, {
    bool isNight = false,
  }) {
    final count = isNight ? 7 : 8;
    for (var i = 0; i < count; i++) {
      final yPos = h * (startYRatio + 0.03 + i * 0.055);
      final refW = w * (0.07 + i * 0.034);
      final alpha = isNight ? (0.80 - i * 0.08) : (0.92 - i * 0.07);
      canvas.drawRect(
        Rect.fromCenter(
          center: Offset(w * centerXRatio, yPos),
          width: refW,
          height: 2.6,
        ),
        Paint()..color = reflColor.withValues(alpha: alpha.clamp(0.15, 1.0)),
      );
    }
  }

  /// Soft clear midday sky reflection for Noon river
  void _drawRiverSkyReflection(
    Canvas canvas,
    double w,
    double h,
    double centerXRatio,
    double startYRatio,
    Color reflColor,
  ) {
    for (var i = 0; i < 6; i++) {
      final yPos = h * (startYRatio + 0.04 + i * 0.065);
      final refW = w * (0.12 + i * 0.04);
      canvas.drawRect(
        Rect.fromCenter(
          center: Offset(w * centerXRatio, yPos),
          width: refW,
          height: 2.2,
        ),
        Paint()
          ..color = reflColor.withValues(
            alpha: (0.65 - i * 0.07).clamp(0.12, 1.0),
          ),
      );
    }
  }

  /// Distant Minecraft blocky mountain ridge
  void _drawVoxelMountainRidge(
    Canvas canvas,
    double w,
    double y,
    Color color, {
    required int step,
  }) {
    final path = Path();
    if (step == 1) {
      path.moveTo(0, y + 10);
      path.lineTo(w * 0.15, y - 12);
      path.lineTo(w * 0.35, y + 6);
      path.lineTo(w * 0.55, y - 16);
      path.lineTo(w * 0.78, y + 2);
      path.lineTo(w, y - 8);
      path.lineTo(w, y + 30);
      path.lineTo(0, y + 30);
    } else {
      path.moveTo(0, y);
      path.lineTo(w * 0.22, y - 8);
      path.lineTo(w * 0.44, y + 4);
      path.lineTo(w * 0.68, y - 12);
      path.lineTo(w, y);
      path.lineTo(w, y + 25);
      path.lineTo(0, y + 25);
    }
    path.close();
    canvas.drawPath(path, Paint()..color = color);
  }

  /// Distant forest tree-line silhouette
  void _drawDistantForestRidge(Canvas canvas, double w, double y, Color color) {
    final p = Paint()..color = color;
    canvas.drawRect(Rect.fromLTWH(0, y, w, 20), p);
    // Tree top bumps
    for (var i = 0; i < 14; i++) {
      final bx = w * (i / 14.0);
      final bh = (i % 3 + 1) * 2.5;
      canvas.drawRect(Rect.fromLTWH(bx, y - bh, w * 0.07, bh), p);
    }
  }

  /// Twinkling pixel stars for night sky
  void _drawMinecraftStars(Canvas canvas, double w, double h) {
    final bright = Paint()..color = Colors.white;
    final dim = Paint()..color = Colors.white60;

    for (final pt in [
      Offset(w * 0.10, h * 0.08),
      Offset(w * 0.28, h * 0.14),
      Offset(w * 0.18, h * 0.24),
      Offset(w * 0.42, h * 0.10),
      Offset(w * 0.52, h * 0.22),
      Offset(w * 0.86, h * 0.08),
      Offset(w * 0.90, h * 0.26),
      Offset(w * 0.78, h * 0.36),
      Offset(w * 0.08, h * 0.38),
      Offset(w * 0.36, h * 0.34),
    ]) {
      canvas.drawRect(Rect.fromLTWH(pt.dx, pt.dy, 2.0, 2.0), bright);
    }
    for (final pt in [
      Offset(w * 0.22, h * 0.06),
      Offset(w * 0.60, h * 0.12),
      Offset(w * 0.14, h * 0.18),
      Offset(w * 0.82, h * 0.18),
    ]) {
      canvas.drawRect(Rect.fromLTWH(pt.dx, pt.dy, 1.2, 1.2), dim);
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // OTHER SHADER SCENES (God Rays, Torch, Water, Fog, Rain)
  // ─────────────────────────────────────────────────────────────────────────

  void _drawGodRaysScene(
    Canvas canvas,
    double w,
    double h,
    Color c, {
    required double angle,
  }) {
    // Atmospheric sky gradient tailored to time of day
    Color skyTop;
    Color skyMid;
    Color skyBot;
    Color sunWarm;

    if (angle < -0.15) {
      // Morning Dawn: rich warm sunrise transitioning to amber horizon
      skyTop = Color.lerp(const Color(0xFF141F32), c, 0.35)!;
      skyMid = Color.lerp(const Color(0xFF3E2C4A), c, 0.45)!;
      skyBot = Color.lerp(const Color(0xFFE27B58), c, 0.40)!;
      sunWarm = const Color(0xFFFFD54F);
    } else if (angle > 0.15) {
      // Evening Sunset: deep twilight crimson/orange
      skyTop = Color.lerp(const Color(0xFF180E28), c, 0.35)!;
      skyMid = Color.lerp(const Color(0xFF5C1B28), c, 0.50)!;
      skyBot = Color.lerp(const Color(0xFFD35400), c, 0.45)!;
      sunWarm = const Color(0xFFFF8A65);
    } else {
      // Noon Sunlight: brilliant midday clear blue
      skyTop = Color.lerp(const Color(0xFF0F365E), c, 0.35)!;
      skyMid = Color.lerp(const Color(0xFF1D5A8A), c, 0.45)!;
      skyBot = Color.lerp(const Color(0xFF58B6D6), c, 0.35)!;
      sunWarm = const Color(0xFFFFF176);
    }

    // 1. Sky backdrop
    canvas.drawRect(
      Rect.fromLTWH(0, 0, w, h),
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [skyTop, skyMid, skyBot],
        ).createShader(Rect.fromLTWH(0, 0, w, h)),
    );

    // 2. Radiant Sun source position (no clouds!)
    final sunX = w * (0.50 + angle * 0.38);
    final sunY = h * 0.18;

    // 3. Volumetric atmospheric bloom around Sun
    canvas.drawCircle(
      Offset(sunX, sunY),
      w * 0.50,
      Paint()
        ..shader =
            RadialGradient(
              colors: [
                Color.lerp(Colors.white, sunWarm, 0.3)!.withValues(alpha: 0.70),
                sunWarm.withValues(alpha: 0.28),
                Colors.transparent,
              ],
            ).createShader(
              Rect.fromCircle(center: Offset(sunX, sunY), radius: w * 0.50),
            ),
    );

    // 4. Volumetric Crepuscular God Rays radiating down from the Sun
    final rayGlow = Color.lerp(Colors.white, sunWarm, 0.35)!;
    for (var i = -3; i <= 3; i++) {
      final spread = i * 0.22;
      final rayAlpha = (0.30 - (i.abs() * 0.045)).clamp(0.08, 0.30);
      final rayPath = Path()
        ..moveTo(sunX - 2.0 + i * 1.2, sunY)
        ..lineTo(sunX + 2.0 + i * 1.2, sunY)
        ..lineTo(w * (0.50 + angle * 0.32 + spread) + w * 0.09, h)
        ..lineTo(w * (0.50 + angle * 0.32 + spread) - w * 0.09, h)
        ..close();

      canvas.drawPath(
        rayPath,
        Paint()
          ..shader = LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              rayGlow.withValues(alpha: rayAlpha * 1.4),
              rayGlow.withValues(alpha: rayAlpha * 0.70),
              rayGlow.withValues(alpha: 0.02),
            ],
          ).createShader(Rect.fromLTWH(0, sunY, w, h - sunY)),
      );
    }

    // 5. Authentic Minecraft Square Sun (layered glowing voxels, beautiful & clear!)
    // Outer soft sun aura square
    canvas.drawRect(
      Rect.fromCenter(center: Offset(sunX, sunY), width: 22, height: 22),
      Paint()..color = sunWarm.withValues(alpha: 0.35),
    );
    // Mid glowing sun corona
    canvas.drawRect(
      Rect.fromCenter(center: Offset(sunX, sunY), width: 17, height: 17),
      Paint()
        ..color = Color.lerp(
          sunWarm,
          Colors.white,
          0.45,
        )!.withValues(alpha: 0.85),
    );
    // Inner brilliant Minecraft sun core (pure white)
    canvas.drawRect(
      Rect.fromCenter(center: Offset(sunX, sunY), width: 12, height: 12),
      Paint()..color = Colors.white,
    );
    // Cardinal sun sparkle pixels
    final sparklePaint = Paint()..color = Colors.white.withValues(alpha: 0.9);
    canvas.drawRect(
      Rect.fromCenter(center: Offset(sunX, sunY - 9), width: 2.5, height: 2.5),
      sparklePaint,
    );
    canvas.drawRect(
      Rect.fromCenter(center: Offset(sunX, sunY + 9), width: 2.5, height: 2.5),
      sparklePaint,
    );
    canvas.drawRect(
      Rect.fromCenter(center: Offset(sunX - 9, sunY), width: 2.5, height: 2.5),
      sparklePaint,
    );
    canvas.drawRect(
      Rect.fromCenter(center: Offset(sunX + 9, sunY), width: 2.5, height: 2.5),
      sparklePaint,
    );

    // 6. Distant mountain ridge catching the sunlight
    final hillColor = Color.lerp(const Color(0xFF1E2F23), skyBot, 0.30)!;
    _drawVoxelMountainRidge(canvas, w, h * 0.74, hillColor, step: 1);

    // 7. Foreground distant pine forest ridge
    final foreRidge = Color.lerp(const Color(0xFF111D15), skyBot, 0.18)!;
    _drawDistantForestRidge(canvas, w, h * 0.84, foreRidge);
  }

  void _drawNightRaysScene(Canvas canvas, double w, double h, Color c) {
    // Deep midnight sky
    final bgTop = Color.lerp(const Color(0xFF030712), c, 0.30)!;
    final bgBot = Color.lerp(const Color(0xFF0C182A), c, 0.40)!;

    canvas.drawRect(
      Rect.fromLTWH(0, 0, w, h),
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [bgTop, bgBot],
        ).createShader(Rect.fromLTWH(0, 0, w, h)),
    );

    // Moonlight source on top right
    final moonX = w * 0.70;
    final moonY = h * 0.16;

    // Moonlight volumetric beams streaming down-left
    final rayColor = Color.lerp(const Color(0xFFD6E9FF), c, 0.35)!;
    for (var i = -2; i <= 2; i++) {
      final rayPath = Path()
        ..moveTo(moonX - 2, moonY)
        ..lineTo(moonX + 2, moonY)
        ..lineTo(w * (0.05 + (i + 2) * 0.22) + w * 0.08, h)
        ..lineTo(w * (0.05 + (i + 2) * 0.22) - w * 0.08, h)
        ..close();

      canvas.drawPath(
        rayPath,
        Paint()
          ..shader = LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              rayColor.withValues(alpha: 0.32),
              rayColor.withValues(alpha: 0.12),
              Colors.transparent,
            ],
          ).createShader(Rect.fromLTWH(0, moonY, w, h - moonY)),
      );
    }

    // Moon & stars
    _drawMinecraftStars(canvas, w, h * 0.5);
    _drawPixelCrescentMoon(canvas, moonX, moonY, 14, c);

    // Distant dark mountain ridge
    final ridgeColor = Color.lerp(const Color(0xFF070E1A), c, 0.20)!;
    _drawVoxelMountainRidge(canvas, w, h * 0.78, ridgeColor, step: 2);
    _drawDistantForestRidge(canvas, w, h * 0.86, const Color(0xFF040810));
  }

  void _drawCloudBlock(
    Canvas canvas,
    double w,
    double h,
    Color c, {
    required bool isTop,
  }) {
    canvas.drawRect(
      Rect.fromLTWH(0, 0, w, h),
      Paint()..color = const Color(0xFF141E28),
    );

    final cloudTopColor = isTop ? c : Color.lerp(c, Colors.white, 0.4)!;
    final cloudSideColor = isTop ? Color.lerp(c, Colors.black, 0.25)! : c;

    final topFace = Path()
      ..moveTo(w * 0.5, h * 0.22)
      ..lineTo(w * 0.85, h * 0.38)
      ..lineTo(w * 0.5, h * 0.54)
      ..lineTo(w * 0.15, h * 0.38)
      ..close();
    canvas.drawPath(topFace, Paint()..color = cloudTopColor);

    final leftFace = Path()
      ..moveTo(w * 0.15, h * 0.38)
      ..lineTo(w * 0.5, h * 0.54)
      ..lineTo(w * 0.5, h * 0.80)
      ..lineTo(w * 0.15, h * 0.64)
      ..close();
    canvas.drawPath(leftFace, Paint()..color = cloudSideColor);

    final rightFace = Path()
      ..moveTo(w * 0.5, h * 0.54)
      ..lineTo(w * 0.85, h * 0.38)
      ..lineTo(w * 0.85, h * 0.64)
      ..lineTo(w * 0.5, h * 0.80)
      ..close();
    canvas.drawPath(
      rightFace,
      Paint()..color = Color.lerp(cloudSideColor, Colors.black, 0.20)!,
    );
  }

  void _drawTorchScene(Canvas canvas, double w, double h, Color c) {
    // 1. Dark stone dungeon / mine background
    canvas.drawRect(
      Rect.fromLTWH(0, 0, w, h),
      Paint()..color = const Color(0xFF121518),
    );

    // Subtle stone block mortar grid (Minecraft cobblestone feel)
    final mortarPaint = Paint()..color = const Color(0xFF0B0D0F);
    for (var row = 0; row < 6; row++) {
      final y = h * (row / 6.0);
      canvas.drawLine(Offset(0, y), Offset(w, y), mortarPaint);
      final offset = (row % 2 == 0) ? 0.0 : (w * 0.25);
      for (var col = 0; col < 3; col++) {
        final x = (col * w * 0.5 + offset) % w;
        canvas.drawLine(Offset(x, y), Offset(x, y + h / 6.0), mortarPaint);
      }
    }

    final torchX = w * 0.50;
    final torchY = h * 0.44;

    // 2. Warm radial torchlight illumination casting light onto the stone wall
    final glowColor = Color.lerp(const Color(0xFFFF9800), c, 0.45)!;
    canvas.drawCircle(
      Offset(torchX, torchY),
      w * 0.65,
      Paint()
        ..shader =
            RadialGradient(
              colors: [
                glowColor.withValues(alpha: 0.85),
                glowColor.withValues(alpha: 0.40),
                glowColor.withValues(alpha: 0.12),
                Colors.transparent,
              ],
              stops: const [0.0, 0.35, 0.70, 1.0],
            ).createShader(
              Rect.fromCircle(center: Offset(torchX, torchY), radius: w * 0.65),
            ),
    );

    // 3. Wooden Torch Handle (with pixel wood texture)
    final stickW = w * 0.10;
    final stickH = h * 0.32;
    final stickX = torchX - stickW * 0.5;
    final stickY = torchY + 4;

    // Wood body
    canvas.drawRect(
      Rect.fromLTWH(stickX, stickY, stickW, stickH),
      Paint()..color = const Color(0xFF5D4037),
    );
    // Darker wood edge
    canvas.drawRect(
      Rect.fromLTWH(stickX + stickW * 0.6, stickY, stickW * 0.4, stickH),
      Paint()..color = const Color(0xFF3E2723),
    );
    // Lighter wood grain
    canvas.drawRect(
      Rect.fromLTWH(stickX + 1, stickY, stickW * 0.3, stickH),
      Paint()..color = const Color(0xFF8D6E63),
    );

    // Coal/charcoal head on stick
    canvas.drawRect(
      Rect.fromLTWH(stickX, torchY - 2, stickW, 6),
      Paint()..color = const Color(0xFF212121),
    );

    // 4. Pixelated Flame Head (multi-layer fire)
    final flameW = w * 0.18;
    final flameH = h * 0.16;
    final flameX = torchX - flameW * 0.5;
    final flameY = torchY - flameH;

    // Outer flame (amber/red)
    canvas.drawRect(
      Rect.fromLTWH(flameX, flameY, flameW, flameH),
      Paint()..color = Color.lerp(const Color(0xFFFF5722), c, 0.35)!,
    );
    // Mid flame (bright orange/gold)
    canvas.drawRect(
      Rect.fromLTWH(flameX + 2, flameY + 2, flameW - 4, flameH - 3),
      Paint()..color = const Color(0xFFFFB300),
    );
    // Inner hot flame (bright yellow)
    canvas.drawRect(
      Rect.fromLTWH(flameX + 3.5, flameY + 3.5, flameW - 7, flameH - 6),
      Paint()..color = const Color(0xFFFFF176),
    );
    // Hot white core
    canvas.drawRect(
      Rect.fromLTWH(flameX + 5, flameY + 5, flameW - 10, flameH - 9),
      Paint()..color = Colors.white,
    );

    // 5. Tiny rising fire sparks / ember pixels
    final sparkPaint = Paint()..color = const Color(0xFFFFD54F);
    canvas.drawRect(Rect.fromLTWH(torchX - 5, flameY - 7, 2, 2), sparkPaint);
    canvas.drawRect(Rect.fromLTWH(torchX + 4, flameY - 11, 2, 2), sparkPaint);
    canvas.drawRect(
      Rect.fromLTWH(torchX - 1, flameY - 15, 1.5, 1.5),
      Paint()..color = const Color(0xFFFFAB91),
    );
  }

  void _drawWaterScene(Canvas canvas, double w, double h, Color c) {
    // Crystal clear Minecraft water gradient
    final waterShallow = Color.lerp(const Color(0xFF29B6F6), c, 0.50)!;
    final waterMid = Color.lerp(const Color(0xFF0288D1), c, 0.60)!;
    final waterAbyss = Color.lerp(const Color(0xFF01579B), c, 0.75)!;

    canvas.drawRect(
      Rect.fromLTWH(0, 0, w, h),
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [waterShallow, waterMid, waterAbyss],
        ).createShader(Rect.fromLTWH(0, 0, w, h)),
    );

    // Sunlit surface highlights & caustics
    final causticPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.40)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    for (var i = 0; i < 5; i++) {
      final y = h * (0.16 + i * 0.18);
      final wavePath = Path()
        ..moveTo(0, y)
        ..quadraticBezierTo(w * 0.25, y - 4, w * 0.5, y)
        ..quadraticBezierTo(w * 0.75, y + 4, w, y);
      canvas.drawPath(wavePath, causticPaint);
    }

    // Subtle sun glare gleam on surface
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(w * 0.5, h * 0.18),
        width: w * 0.6,
        height: 6,
      ),
      Paint()..color = Colors.white.withValues(alpha: 0.30),
    );
  }

  void _drawFogScene(Canvas canvas, double w, double h, Color c) {
    // 1. Soft atmospheric sky gradient
    final skyTop = Color.lerp(const Color(0xFF4A5568), c, 0.40)!;
    final skyMid = Color.lerp(const Color(0xFF718096), c, 0.50)!;
    final skyBot = Color.lerp(const Color(0xFFA0AEC0), c, 0.60)!;

    canvas.drawRect(
      Rect.fromLTWH(0, 0, w, h),
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [skyTop, skyMid, skyBot],
        ).createShader(Rect.fromLTWH(0, 0, w, h)),
    );

    // 2. Soft pale morning sun disc partially obscured by mist
    canvas.drawCircle(
      Offset(w * 0.5, h * 0.24),
      w * 0.22,
      Paint()
        ..shader =
            RadialGradient(
              colors: [
                Colors.white.withValues(alpha: 0.45),
                Colors.white.withValues(alpha: 0.15),
                Colors.transparent,
              ],
            ).createShader(
              Rect.fromCircle(
                center: Offset(w * 0.5, h * 0.24),
                radius: w * 0.22,
              ),
            ),
    );
    canvas.drawRect(
      Rect.fromCenter(center: Offset(w * 0.5, h * 0.24), width: 10, height: 10),
      Paint()..color = Colors.white.withValues(alpha: 0.55),
    );

    // 3. Layer 1: Distant mountain ridge (partially veiled in mist)
    final ridge1 = Color.lerp(const Color(0xFF4A5568), skyBot, 0.50)!;
    _drawVoxelMountainRidge(canvas, w, h * 0.42, ridge1, step: 1);

    // Mist band 1 drifting over valley
    canvas.drawRect(
      Rect.fromLTWH(0, h * 0.46, w, h * 0.12),
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            skyBot.withValues(alpha: 0.10),
            skyBot.withValues(alpha: 0.55),
            skyBot.withValues(alpha: 0.10),
          ],
        ).createShader(Rect.fromLTWH(0, h * 0.46, w, h * 0.12)),
    );

    // 4. Layer 2: Mid-distance forested ridge
    final ridge2 = Color.lerp(const Color(0xFF2D3748), skyBot, 0.35)!;
    _drawDistantForestRidge(canvas, w, h * 0.58, ridge2);

    // Mist band 2 rolling lower
    canvas.drawRect(
      Rect.fromLTWH(0, h * 0.62, w, h * 0.14),
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            skyBot.withValues(alpha: 0.15),
            skyBot.withValues(alpha: 0.70),
            skyBot.withValues(alpha: 0.20),
          ],
        ).createShader(Rect.fromLTWH(0, h * 0.62, w, h * 0.14)),
    );

    // 5. Layer 3: Foreground voxel grassy slope with lonely spruce tree
    final grassMist = Color.lerp(const Color(0xFF283618), skyBot, 0.25)!;
    final dirtMist = const Color(0xFF382C1E);
    _drawVoxelBlock(canvas, 0, h * 0.74, w, h * 0.26, grassMist, dirtMist);
    _drawMinecraftSpruceTree(
      canvas,
      w * 0.12,
      h * 0.46,
      w * 0.28,
      h * 0.34,
      grassMist,
    );

    // Ground fog hugging the grass
    canvas.drawRect(
      Rect.fromLTWH(0, h * 0.72, w, h * 0.10),
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.transparent,
            skyBot.withValues(alpha: 0.60),
            Colors.transparent,
          ],
        ).createShader(Rect.fromLTWH(0, h * 0.72, w, h * 0.10)),
    );
  }

  void _drawRainFogScene(Canvas canvas, double w, double h, Color c) {
    // 1. Stormy overcast sky gradient
    final skyTop = Color.lerp(const Color(0xFF1E2832), c, 0.40)!;
    final skyMid = Color.lerp(const Color(0xFF2E3D4C), c, 0.45)!;
    final skyBot = Color.lerp(const Color(0xFF455A64), c, 0.50)!;

    canvas.drawRect(
      Rect.fromLTWH(0, 0, w, h),
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [skyTop, skyMid, skyBot],
        ).createShader(Rect.fromLTWH(0, 0, w, h)),
    );

    // 2. Heavy dark rainclouds at top
    _drawTieredVoxelCloud(
      canvas,
      w * 0.05,
      h * 0.02,
      w * 0.90,
      h * 0.16,
      Color.lerp(const Color(0xFF546E7A), c, 0.35)!,
      Color.lerp(const Color(0xFF263238), c, 0.40)!,
    );

    // 3. Distant mountain ridge shrouded in rain haze
    final ridgeRain = Color.lerp(const Color(0xFF1C2D37), skyBot, 0.45)!;
    _drawVoxelMountainRidge(canvas, w, h * 0.45, ridgeRain, step: 2);

    // Soft dense rain fog veil drifting across midground
    canvas.drawRect(
      Rect.fromLTWH(0, h * 0.46, w, h * 0.22),
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            skyBot.withValues(alpha: 0.10),
            skyBot.withValues(alpha: 0.65),
            skyBot.withValues(alpha: 0.15),
          ],
        ).createShader(Rect.fromLTWH(0, h * 0.46, w, h * 0.22)),
    );

    // 4. Foreground wet voxel grass slope and pine tree
    final grassWet = Color.lerp(const Color(0xFF1F3524), c, 0.20)!;
    final dirtWet = const Color(0xFF251A14);
    _drawVoxelBlock(canvas, 0, h * 0.68, w, h * 0.32, grassWet, dirtWet);
    _drawMinecraftSpruceTree(
      canvas,
      w * 0.08,
      h * 0.40,
      w * 0.30,
      h * 0.38,
      grassWet,
    );

    // Low ground mist hugging the terrain
    canvas.drawRect(
      Rect.fromLTWH(0, h * 0.65, w, h * 0.12),
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.transparent,
            skyBot.withValues(alpha: 0.50),
            Colors.transparent,
          ],
        ).createShader(Rect.fromLTWH(0, h * 0.65, w, h * 0.12)),
    );

    // 5. Natural falling rain streaks (delicate, semi-transparent, coordinated)
    final rainPaint = Paint()
      ..color = Color.lerp(
        Colors.white,
        const Color(0xFFB0BEC5),
        0.3,
      )!.withValues(alpha: 0.42)
      ..strokeWidth = 1.0;

    const rainPoints = [
      [0.14, 0.18, 0.12],
      [0.26, 0.10, 0.15],
      [0.38, 0.24, 0.13],
      [0.52, 0.12, 0.16],
      [0.64, 0.22, 0.14],
      [0.78, 0.14, 0.15],
      [0.90, 0.20, 0.13],
      [0.18, 0.45, 0.14],
      [0.32, 0.52, 0.15],
      [0.46, 0.42, 0.13],
      [0.58, 0.56, 0.16],
      [0.72, 0.48, 0.14],
      [0.86, 0.54, 0.15],
      [0.24, 0.72, 0.12],
      [0.42, 0.76, 0.13],
      [0.66, 0.74, 0.12],
      [0.82, 0.78, 0.13],
    ];

    for (final r in rainPoints) {
      final sx = w * r[0];
      final sy = h * r[1];
      final len = h * r[2];
      canvas.drawLine(
        Offset(sx, sy),
        Offset(sx - w * 0.04, sy + len),
        rainPaint,
      );
    }
  }

  void _drawRainWaterScene(Canvas canvas, double w, double h, Color c) {
    // 1. Deep moody rainwater surface gradient
    final waterTop = Color.lerp(const Color(0xFF1A3348), c, 0.45)!;
    final waterMid = Color.lerp(const Color(0xFF102436), c, 0.55)!;
    final waterDeep = Color.lerp(const Color(0xFF07121E), c, 0.65)!;

    canvas.drawRect(
      Rect.fromLTWH(0, 0, w, h),
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [waterTop, waterMid, waterDeep],
        ).createShader(Rect.fromLTWH(0, 0, w, h)),
    );

    // 2. Gentle surface water caustics / wave lines
    final wavePaint = Paint()
      ..color = Color.lerp(Colors.white, c, 0.3)!.withValues(alpha: 0.18)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;

    for (var i = 0; i < 4; i++) {
      final y = h * (0.18 + i * 0.22);
      final wavePath = Path()
        ..moveTo(0, y)
        ..quadraticBezierTo(w * 0.25, y - 3, w * 0.5, y)
        ..quadraticBezierTo(w * 0.75, y + 3, w, y);
      canvas.drawPath(wavePath, wavePaint);
    }

    // 3. Concentric Expanding Ripple Rings (from raindrops hitting the water)
    void drawRipple(double cx, double cy, double baseRadius) {
      final rippleColor = Color.lerp(Colors.white, c, 0.25)!;

      // Outer fading ring
      canvas.drawOval(
        Rect.fromCenter(
          center: Offset(cx, cy),
          width: baseRadius * 2.2,
          height: baseRadius * 0.65,
        ),
        Paint()
          ..color = rippleColor.withValues(alpha: 0.25)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.0,
      );

      // Middle ring
      canvas.drawOval(
        Rect.fromCenter(
          center: Offset(cx, cy),
          width: baseRadius * 1.4,
          height: baseRadius * 0.42,
        ),
        Paint()
          ..color = rippleColor.withValues(alpha: 0.55)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.2,
      );

      // Inner ripple core
      canvas.drawOval(
        Rect.fromCenter(
          center: Offset(cx, cy),
          width: baseRadius * 0.6,
          height: baseRadius * 0.20,
        ),
        Paint()
          ..color = rippleColor.withValues(alpha: 0.85)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.4,
      );

      // Center bright water splash droplet
      canvas.drawRect(
        Rect.fromCenter(center: Offset(cx, cy), width: 2.0, height: 2.0),
        Paint()..color = Colors.white,
      );
    }

    // Ripple 1: Mid-left
    drawRipple(w * 0.36, h * 0.38, w * 0.22);
    // Ripple 2: Lower-right
    drawRipple(w * 0.70, h * 0.68, w * 0.26);
    // Ripple 3: Smaller recent splash top-right
    drawRipple(w * 0.78, h * 0.22, w * 0.14);
    // Ripple 4: Fresh splash bottom-left
    drawRipple(w * 0.20, h * 0.82, w * 0.16);

    // 4. Delicate falling raindrops impacting the surface
    final dropPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.35)
      ..strokeWidth = 1.0;

    canvas.drawLine(
      Offset(w * 0.38, h * 0.24),
      Offset(w * 0.36, h * 0.36),
      dropPaint,
    );
    canvas.drawLine(
      Offset(w * 0.72, h * 0.54),
      Offset(w * 0.70, h * 0.66),
      dropPaint,
    );
    canvas.drawLine(
      Offset(w * 0.79, h * 0.12),
      Offset(w * 0.78, h * 0.20),
      dropPaint,
    );
    canvas.drawLine(
      Offset(w * 0.21, h * 0.72),
      Offset(w * 0.20, h * 0.80),
      dropPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _RealisticShaderPainter oldDelegate) {
    return oldDelegate.type != type || oldDelegate.color != color;
  }
}

/// 3D Minecraft voxel block slider thumb matching user reference image

/// Stepped 90-degree Minecraft pixelated corner clipper
class _PixelatedClipper extends CustomClipper<Path> {
  final double step;
  const _PixelatedClipper([this.step = 4.0]);

  static Path createPixelPath(double w, double h, double inset, double s) {
    final l = inset;
    final t = inset;
    final r = w - inset;
    final b = h - inset;

    return Path()
      // Top-left corner
      ..moveTo(l + s * 2, t)
      ..lineTo(r - s * 2, t)
      // Top-right stepped corner
      ..lineTo(r - s * 2, t + s)
      ..lineTo(r - s, t + s)
      ..lineTo(r - s, t + s * 2)
      ..lineTo(r, t + s * 2)
      // Right edge
      ..lineTo(r, b - s * 2)
      // Bottom-right stepped corner
      ..lineTo(r - s, b - s * 2)
      ..lineTo(r - s, b - s)
      ..lineTo(r - s * 2, b - s)
      ..lineTo(r - s * 2, b)
      // Bottom edge
      ..lineTo(l + s * 2, b)
      // Bottom-left stepped corner
      ..lineTo(l + s * 2, b - s)
      ..lineTo(l + s, b - s)
      ..lineTo(l + s, b - s * 2)
      ..lineTo(l, b - s * 2)
      // Left edge
      ..lineTo(l, t + s * 2)
      // Finish top-left steps
      ..lineTo(l + s, t + s * 2)
      ..lineTo(l + s, t + s)
      ..lineTo(l + s * 2, t + s)
      ..close();
  }

  @override
  Path getClip(Size size) {
    return createPixelPath(size.width, size.height, 0, step);
  }

  @override
  bool shouldReclip(covariant _PixelatedClipper oldClipper) =>
      oldClipper.step != step;
}

/// Stepped 90-degree Minecraft pixelated corner card painter matching reference screenshot
class _PixelatedCardPainter extends CustomPainter {
  final Color fillColor;
  final Color borderColor;
  final double borderWidth;
  final double step;
  final bool hasShadow;

  const _PixelatedCardPainter({
    required this.fillColor,
    required this.borderColor,
    this.borderWidth = 2.0,
    this.step = 2.5,
    this.hasShadow = true,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Soft drop shadow
    if (hasShadow) {
      final shadowPath = _PixelatedClipper.createPixelPath(w, h, 0, step);
      canvas.drawPath(
        shadowPath.shift(const Offset(0, 3)),
        Paint()..color = Colors.black.withValues(alpha: 0.45),
      );
    }

    // Card fill
    final fillPath = _PixelatedClipper.createPixelPath(w, h, 0, step);
    canvas.drawPath(fillPath, Paint()..color = fillColor);

    // Subtle 3D inner bevel highlight
    final innerPath = _PixelatedClipper.createPixelPath(
      w,
      h,
      borderWidth * 0.5,
      step,
    );
    canvas.drawPath(
      innerPath,
      Paint()
        ..color = Colors.white.withValues(alpha: 0.12)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.0,
    );

    // Outer Stepped pixel border
    canvas.drawPath(
      fillPath,
      Paint()
        ..color = borderColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = borderWidth,
    );
  }

  @override
  bool shouldRepaint(covariant _PixelatedCardPainter old) =>
      old.fillColor != fillColor ||
      old.borderColor != borderColor ||
      old.borderWidth != borderWidth ||
      old.step != step ||
      old.hasShadow != hasShadow;
}

/// Foreground stepped border painter that draws cleanly ON TOP of child content
class _PixelatedBorderPainter extends CustomPainter {
  final Color borderColor;
  final double borderWidth;
  final double step;

  const _PixelatedBorderPainter({
    required this.borderColor,
    this.borderWidth = 1.2,
    this.step = 2.5,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final half = borderWidth * 0.5;
    final borderPath = _PixelatedClipper.createPixelPath(w, h, half, step);
    canvas.drawPath(
      borderPath,
      Paint()
        ..color = borderColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = borderWidth,
    );
  }

  @override
  bool shouldRepaint(covariant _PixelatedBorderPainter old) =>
      old.borderColor != borderColor ||
      old.borderWidth != borderWidth ||
      old.step != step;
}

/// Minecraft card with authentic stepped pixel corners matching screenshot
class PixelatedCard extends StatelessWidget {
  final Widget child;
  final Color backgroundColor;
  final Color borderColor;
  final double borderWidth;
  final double pixelStep;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry margin;

  const PixelatedCard({
    super.key,
    required this.child,
    required this.backgroundColor,
    required this.borderColor,
    this.borderWidth = 1.5,
    this.pixelStep = 4.0,
    this.padding = const EdgeInsets.all(16),
    this.margin = const EdgeInsets.only(bottom: 14),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      child: CustomPaint(
        painter: _PixelatedCardPainter(
          fillColor: backgroundColor,
          borderColor: borderColor,
          borderWidth: borderWidth,
          step: pixelStep,
          hasShadow: false,
        ),
        foregroundPainter: _PixelatedBorderPainter(
          borderColor: borderColor,
          borderWidth: borderWidth,
          step: pixelStep,
        ),
        child: ClipPath(
          clipper: _PixelatedClipper(pixelStep),
          child: Padding(padding: padding, child: child),
        ),
      ),
    );
  }
}

class MinecraftSliderThumbShape extends SliderComponentShape {
  final Color baseColor;
  final Color borderColor;
  final double thumbSize;

  const MinecraftSliderThumbShape({
    required this.baseColor,
    required this.borderColor,
    this.thumbSize = 14.0,
  });

  @override
  Size getPreferredSize(bool isEnabled, bool isDiscrete) =>
      Size(thumbSize, thumbSize + 4);

  @override
  void paint(
    PaintingContext context,
    Offset center, {
    required Animation<double> activationAnimation,
    required Animation<double> enableAnimation,
    required bool isDiscrete,
    required TextPainter labelPainter,
    required RenderBox parentBox,
    required SliderThemeData sliderTheme,
    required TextDirection textDirection,
    required double value,
    required double textScaleFactor,
    required Size sizeWithOverflow,
  }) {
    final canvas = context.canvas;
    final w = thumbSize;
    final h = thumbSize + 2;

    // 1. Outer bevel border in deeper shade of tab color
    final outerColor =
        Color.lerp(borderColor, Colors.black, 0.25) ?? borderColor;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: center, width: w, height: h),
        const Radius.circular(2.5),
      ),
      Paint()..color = outerColor,
    );

    // 2. Inner voxel face in tab color
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: center, width: w - 3, height: h - 3),
        const Radius.circular(1.5),
      ),
      Paint()..color = baseColor,
    );

    // 3. Top subtle highlight specular
    canvas.drawLine(
      Offset(center.dx - w * 0.30, center.dy - h * 0.35),
      Offset(center.dx + w * 0.30, center.dy - h * 0.35),
      Paint()
        ..color = Colors.white.withValues(alpha: 0.55)
        ..strokeWidth = 1.0,
    );
  }
}

// ─── PROCEDURAL DETAILED MINECRAFT SCENERY PAINTERS (100% CODE RENDERED) ─────
/// High-Detail Procedural Minecraft Atmosphere Scene Painter
/// Reacts dynamically in real-time to sun/moon size, god rays, fog density, clouds, colors, and night vision!
class _AtmosphereDetailedScenePainter extends CustomPainter {
  final String timeOfDay;
  final Color activeSkyColor;
  final double sunOrMoonScale;
  final double fogDensity;
  final double rayIntensity;
  final double nightVision;
  final String cloudType;
  final Color cloudTopColor;
  final Color cloudBottomColor;

  _AtmosphereDetailedScenePainter({
    required this.timeOfDay,
    required this.activeSkyColor,
    required this.sunOrMoonScale,
    required this.fogDensity,
    required this.rayIntensity,
    required this.nightVision,
    required this.cloudType,
    required this.cloudTopColor,
    required this.cloudBottomColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final isNight = timeOfDay.contains('Night');
    final isMorning = timeOfDay.contains('Morning');
    final isEvening = timeOfDay.contains('Evening');

    // ── 1. PROCEDURAL MINECRAFT SKY GRADIENT ────────────────────────────────
    Color skyZenith;
    Color skyMid;
    Color skyHorizon;

    if (isMorning) {
      // Warm golden sunrise orange dawn sky
      skyZenith = Color.lerp(const Color(0xFF2E4057), activeSkyColor, 0.40)!;
      skyMid = Color.lerp(const Color(0xFFFF9E3D), activeSkyColor, 0.60)!;
      skyHorizon = Color.lerp(const Color(0xFFFFD54F), activeSkyColor, 0.75)!;
    } else if (isEvening) {
      // Fiery twilight sunset sky
      skyZenith = Color.lerp(const Color(0xFF4A148C), activeSkyColor, 0.45)!;
      skyMid = Color.lerp(const Color(0xFFE91E63), activeSkyColor, 0.55)!;
      skyHorizon = Color.lerp(const Color(0xFFFF6D00), activeSkyColor, 0.70)!;
    } else if (isNight) {
      // Midnight deep cosmic starlit sky
      skyZenith = Color.lerp(const Color(0xFF020617), activeSkyColor, 0.30)!;
      skyMid = Color.lerp(const Color(0xFF0B132B), activeSkyColor, 0.35)!;
      skyHorizon = Color.lerp(const Color(0xFF1E293B), activeSkyColor, 0.40)!;
    } else {
      // Crisp azure noon daytime sky
      skyZenith = Color.lerp(const Color(0xFF0284C7), activeSkyColor, 0.45)!;
      skyMid = Color.lerp(const Color(0xFF38BDF8), activeSkyColor, 0.50)!;
      skyHorizon = Color.lerp(const Color(0xFFBAE6FD), activeSkyColor, 0.55)!;
    }

    final skyPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [skyZenith, skyMid, skyHorizon],
        stops: const [0.0, 0.45, 0.72],
      ).createShader(Rect.fromLTWH(0, 0, w, h));
    canvas.drawRect(Rect.fromLTWH(0, 0, w, h), skyPaint);

    // ── 2. PIXEL STARS (NIGHT ONLY) ─────────────────────────────────────────
    if (isNight) {
      final starPaint = Paint()
        ..color = Colors.white.withValues(
          alpha: (0.85 * nightVision).clamp(0.25, 1.0),
        );
      final starlightHalos = Paint()
        ..color = const Color(
          0xFFC7D2FE,
        ).withValues(alpha: (0.40 * nightVision).clamp(0.1, 0.8));

      // Fixed pseudo-random Minecraft square star coordinates
      const stars = [
        Offset(0.05, 0.12),
        Offset(0.12, 0.22),
        Offset(0.18, 0.08),
        Offset(0.24, 0.28),
        Offset(0.31, 0.14),
        Offset(0.38, 0.06),
        Offset(0.44, 0.25),
        Offset(0.51, 0.10),
        Offset(0.57, 0.18),
        Offset(0.62, 0.05),
        Offset(0.68, 0.30),
        Offset(0.75, 0.12),
        Offset(0.82, 0.22),
        Offset(0.88, 0.08),
        Offset(0.94, 0.26),
        Offset(0.15, 0.38),
        Offset(0.28, 0.42),
        Offset(0.48, 0.36),
        Offset(0.65, 0.38),
        Offset(0.84, 0.40),
      ];

      for (var i = 0; i < stars.length; i++) {
        final pos = Offset(stars[i].dx * w, stars[i].dy * h);
        final sz = (i % 3 == 0) ? 2.5 : 1.8;
        if (i % 2 == 0) {
          canvas.drawRect(
            Rect.fromCenter(center: pos, width: sz * 2.2, height: sz * 2.2),
            starlightHalos,
          );
        }
        canvas.drawRect(Rect.fromLTWH(pos.dx, pos.dy, sz, sz), starPaint);
      }
    }

    // ── 3. CELESTIAL POSITION & DYNAMIC VOLUMETRIC GOD RAYS ─────────────────
    double bodyX, bodyY;
    if (isMorning) {
      bodyX = w * 0.28;
      bodyY = h * 0.38;
    } else if (isEvening) {
      bodyX = w * 0.48;
      bodyY = h * 0.44;
    } else if (isNight) {
      bodyX = w * 0.72;
      bodyY = h * 0.24;
    } else {
      bodyX = w * 0.64;
      bodyY = h * 0.20;
    }

    // Dynamic God Rays streaming across the sky
    if (rayIntensity > 0.08) {
      final effRayAlpha = (0.24 * rayIntensity).clamp(0.04, 0.65);
      Color rayTint;
      if (isMorning) {
        rayTint = Color.lerp(const Color(0xFFFFE082), activeSkyColor, 0.4)!;
      } else if (isEvening) {
        rayTint = Color.lerp(const Color(0xFFFFB74D), activeSkyColor, 0.5)!;
      } else if (isNight) {
        rayTint = Color.lerp(const Color(0xFFA5B4FC), activeSkyColor, 0.3)!;
      } else {
        rayTint = Color.lerp(Colors.white, activeSkyColor, 0.3)!;
      }

      final angles = isMorning
          ? [0.25, 0.45, 0.70, 0.95, 1.20]
          : (isEvening
                ? [-0.55, -0.25, 0.0, 0.25, 0.55]
                : (isNight
                      ? [-0.60, -0.35, -0.10, 0.15]
                      : [-0.45, -0.20, 0.05, 0.30, 0.55]));

      for (final ang in angles) {
        final rayPath = Path();
        final rayLen = h * 1.2;
        final startW = 8.0 * rayIntensity.clamp(0.5, 2.0);
        final spreadW = (32.0 * rayIntensity).clamp(16.0, 90.0);

        final cosA = math.cos(ang + math.pi / 2);
        final sinA = math.sin(ang + math.pi / 2);

        final endX = bodyX + cosA * rayLen;
        final endY = bodyY + sinA * rayLen;

        rayPath.moveTo(bodyX - startW / 2, bodyY);
        rayPath.lineTo(bodyX + startW / 2, bodyY);
        rayPath.lineTo(endX + spreadW / 2, endY);
        rayPath.lineTo(endX - spreadW / 2, endY);
        rayPath.close();

        final rayPaint = Paint()
          ..shader = LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              rayTint.withValues(alpha: effRayAlpha),
              rayTint.withValues(alpha: effRayAlpha * 0.4),
              Colors.transparent,
            ],
            stops: const [0.0, 0.55, 1.0],
          ).createShader(Rect.fromLTWH(0, 0, w, h));
        canvas.drawPath(rayPath, rayPaint);
      }
    }

    // ── 4. SQUARE MINECRAFT CELESTIAL BODY (SUN / MOON) ─────────────────────
    final baseRadius = isEvening ? 15.0 : (isNight ? 13.0 : 14.0);
    final discSize = (baseRadius * 2 * sunOrMoonScale).clamp(14.0, 56.0);

    Color glowColor;
    if (isMorning) {
      glowColor = const Color(0xFFFFB300);
    } else if (isEvening) {
      glowColor = const Color(0xFFF97316);
    } else if (isNight) {
      glowColor = const Color(0xFFA5B4FC);
    } else {
      glowColor = const Color(0xFFFDE047);
    }

    final glowPaint = Paint()
      ..shader =
          RadialGradient(
            colors: [
              glowColor.withValues(
                alpha: (0.65 * (isNight ? nightVision : 1.0)).clamp(0.2, 0.9),
              ),
              glowColor.withValues(alpha: 0.22),
              Colors.transparent,
            ],
            stops: const [0.0, 0.45, 1.0],
          ).createShader(
            Rect.fromCenter(
              center: Offset(bodyX, bodyY),
              width: discSize * 3.2,
              height: discSize * 3.2,
            ),
          );
    canvas.drawCircle(Offset(bodyX, bodyY), discSize * 1.6, glowPaint);

    if (isNight) {
      // Glowing Square Minecraft Moon with pixel crater detail
      final moonRect = Rect.fromCenter(
        center: Offset(bodyX, bodyY),
        width: discSize,
        height: discSize,
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(moonRect, const Radius.circular(2)),
        Paint()..color = const Color(0xFFF8FAFC),
      );
      final craterPaint = Paint()..color = const Color(0xFFCBD5E1);
      final cs = discSize * 0.28;
      canvas.drawRect(
        Rect.fromLTWH(bodyX - discSize * 0.32, bodyY - discSize * 0.32, cs, cs),
        craterPaint,
      );
      canvas.drawRect(
        Rect.fromLTWH(
          bodyX + discSize * 0.05,
          bodyY + discSize * 0.05,
          cs * 0.8,
          cs * 0.8,
        ),
        craterPaint,
      );
    } else {
      // Glowing Square Minecraft Sun
      final sunRect = Rect.fromCenter(
        center: Offset(bodyX, bodyY),
        width: discSize,
        height: discSize,
      );
      canvas.drawRect(
        sunRect,
        Paint()
          ..color = isEvening
              ? const Color(0xFFFFCC80)
              : const Color(0xFFFFF9C4),
      );
      final coreSize = discSize * 0.72;
      canvas.drawRect(
        Rect.fromCenter(
          center: Offset(bodyX, bodyY),
          width: coreSize,
          height: coreSize,
        ),
        Paint()..color = Colors.white,
      );
    }

    // ── 5. PROCEDURAL MINECRAFT CLOUDS (ACCORDING TO cloudType) ─────────────
    final cTop = Color.lerp(cloudTopColor, activeSkyColor, 0.20)!;
    final cBottom = Color.lerp(cloudBottomColor, activeSkyColor, 0.30)!;

    if (cloudType == 'Flat 2D') {
      final cloudPaint = Paint()..color = cTop.withValues(alpha: 0.85);
      final shadowPaint = Paint()..color = cBottom.withValues(alpha: 0.90);
      _drawFlatMinecraftCloudBand(
        canvas,
        w,
        h * 0.15,
        h * 0.06,
        cloudPaint,
        shadowPaint,
      );
    } else if (cloudType == 'Volumetric') {
      _drawVolumetricCloudPuff(
        canvas,
        w * 0.06,
        h * 0.12,
        w * 0.36,
        h * 0.10,
        cTop,
        cBottom,
      );
      _drawVolumetricCloudPuff(
        canvas,
        w * 0.50,
        h * 0.18,
        w * 0.44,
        h * 0.09,
        cTop,
        cBottom,
      );
    } else {
      _draw3DVoxelCloud(
        canvas,
        w * 0.04,
        h * 0.11,
        w * 0.40,
        h * 0.11,
        cTop,
        cBottom,
      );
      _draw3DVoxelCloud(
        canvas,
        w * 0.52,
        h * 0.16,
        w * 0.42,
        h * 0.10,
        cTop,
        cBottom,
      );
    }

    // ── 6. DISTANT MINECRAFT MOUNTAIN RIDGES ─────────────────────────────────
    Color ridgeFarColor;
    Color ridgeNearColor;
    if (isMorning) {
      ridgeFarColor = Color.lerp(
        const Color(0xFF5A728A),
        activeSkyColor,
        0.35,
      )!;
      ridgeNearColor = Color.lerp(
        const Color(0xFF4A6638),
        const Color(0xFFFF9E3D),
        0.25,
      )!;
    } else if (isEvening) {
      ridgeFarColor = Color.lerp(
        const Color(0xFF4A1F3D),
        activeSkyColor,
        0.40,
      )!;
      ridgeNearColor = Color.lerp(
        const Color(0xFF38181A),
        const Color(0xFFFF6D00),
        0.30,
      )!;
    } else if (isNight) {
      ridgeFarColor = Color.lerp(
        const Color(0xFF070F1E),
        activeSkyColor,
        0.25,
      )!;
      ridgeNearColor = Color.lerp(
        const Color(0xFF040A14),
        activeSkyColor,
        0.20,
      )!;
    } else {
      ridgeFarColor = Color.lerp(
        const Color(0xFF64B5F6),
        activeSkyColor,
        0.30,
      )!;
      ridgeNearColor = Color.lerp(
        const Color(0xFF43A047),
        activeSkyColor,
        0.25,
      )!;
    }

    _drawSteppedMountainSilhouette(
      canvas,
      w,
      h * 0.44,
      ridgeFarColor,
      h * 0.16,
    );
    _drawSteppedMountainSilhouette(
      canvas,
      w,
      h * 0.50,
      ridgeNearColor,
      h * 0.12,
      shift: w * 0.25,
    );

    // ── 7. VOLUMETRIC HORIZON FOG LAYER (DYNAMIC TO fogDensity) ──────────────
    if (fogDensity > 0.05) {
      final fogH = (42.0 * fogDensity).clamp(12.0, 85.0);
      final fogAlpha = (0.42 * fogDensity).clamp(0.08, 0.85);
      final fogColor = isNight
          ? const Color(0xFF0F172A)
          : (isEvening
                ? const Color(0xFFEA580C)
                : (isMorning ? const Color(0xFFFFB74D) : activeSkyColor));

      final fogPaint = Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.transparent,
            fogColor.withValues(alpha: fogAlpha * 0.4),
            fogColor.withValues(alpha: fogAlpha),
          ],
          stops: const [0.0, 0.5, 1.0],
        ).createShader(Rect.fromLTWH(0, h - fogH - 15, w, fogH + 15));
      canvas.drawRect(Rect.fromLTWH(0, h - fogH - 15, w, fogH + 15), fogPaint);
    }

    // ── 8. FOREGROUND MINECRAFT TERRAIN, RIVER & TREES ───────────────────────
    Color grassColor;
    const dirtColor = Color(0xFF4E342E);
    if (isMorning) {
      grassColor = Color.lerp(
        const Color(0xFF558B2F),
        const Color(0xFFFF9E3D),
        0.20,
      )!;
    } else if (isEvening) {
      grassColor = Color.lerp(
        const Color(0xFF33691E),
        const Color(0xFFFF6D00),
        0.30,
      )!;
    } else if (isNight) {
      grassColor = Color.lerp(const Color(0xFF1B3820), activeSkyColor, 0.25)!;
    } else {
      grassColor = Color.lerp(const Color(0xFF4CAF50), activeSkyColor, 0.20)!;
    }

    // River flowing in center towards viewer
    final riverColor = isNight
        ? Color.lerp(const Color(0xFF08182B), activeSkyColor, 0.30)!
        : (isEvening
              ? Color.lerp(const Color(0xFFB45309), activeSkyColor, 0.40)!
              : Color.lerp(const Color(0xFF1E88E5), activeSkyColor, 0.40)!);
    final riverPath = Path()
      ..moveTo(w * 0.42, h * 0.58)
      ..lineTo(w * 0.58, h * 0.58)
      ..lineTo(w * 0.70, h)
      ..lineTo(w * 0.30, h)
      ..close();
    canvas.drawPath(riverPath, Paint()..color = riverColor);

    // River celestial reflection ripples
    final rippleColor = isNight
        ? const Color(0xFFC7D2FE).withValues(alpha: 0.35)
        : (isEvening
              ? const Color(0xFFFFD54F).withValues(alpha: 0.40)
              : Colors.white.withValues(alpha: 0.40));
    canvas.drawRect(
      Rect.fromLTWH(w * 0.46, h * 0.65, w * 0.08, 2.0),
      Paint()..color = rippleColor,
    );
    canvas.drawRect(
      Rect.fromLTWH(w * 0.43, h * 0.76, w * 0.14, 2.5),
      Paint()..color = rippleColor,
    );
    canvas.drawRect(
      Rect.fromLTWH(w * 0.38, h * 0.88, w * 0.24, 3.0),
      Paint()..color = rippleColor,
    );

    // Left Grass Stepped Bank
    _drawVoxelBlock(
      canvas,
      0,
      h * 0.58,
      w * 0.42,
      h * 0.10,
      grassColor,
      dirtColor,
    );
    _drawVoxelBlock(
      canvas,
      0,
      h * 0.68,
      w * 0.36,
      h * 0.14,
      grassColor,
      dirtColor,
    );
    _drawVoxelBlock(
      canvas,
      0,
      h * 0.80,
      w * 0.30,
      h * 0.20,
      grassColor,
      dirtColor,
    );

    // Right Grass Stepped Bank
    _drawVoxelBlock(
      canvas,
      w * 0.58,
      h * 0.58,
      w * 0.42,
      h * 0.10,
      grassColor,
      dirtColor,
    );
    _drawVoxelBlock(
      canvas,
      w * 0.64,
      h * 0.68,
      w * 0.36,
      h * 0.14,
      grassColor,
      dirtColor,
    );
    _drawVoxelBlock(
      canvas,
      w * 0.70,
      h * 0.80,
      w * 0.30,
      h * 0.20,
      grassColor,
      dirtColor,
    );

    // Minecraft Oak / Spruce Trees on banks
    _drawMinecraftOakTree(
      canvas,
      w * 0.06,
      h * 0.38,
      w * 0.24,
      h * 0.36,
      grassColor,
    );
    _drawMinecraftSpruceTree(
      canvas,
      w * 0.76,
      h * 0.42,
      w * 0.18,
      h * 0.36,
      grassColor,
    );
  }

  void _drawVoxelBlock(
    Canvas canvas,
    double x,
    double y,
    double bw,
    double bh,
    Color top,
    Color side,
  ) {
    canvas.drawRect(Rect.fromLTWH(x, y, bw, bh), Paint()..color = side);
    canvas.drawRect(Rect.fromLTWH(x, y, bw, 3.0), Paint()..color = top);
  }

  void _drawFlatMinecraftCloudBand(
    Canvas canvas,
    double w,
    double y,
    double bh,
    Paint topPaint,
    Paint shadowPaint,
  ) {
    canvas.drawRect(Rect.fromLTWH(0, y, w, bh * 0.65), topPaint);
    canvas.drawRect(Rect.fromLTWH(0, y + bh * 0.65, w, bh * 0.35), shadowPaint);
  }

  void _drawVolumetricCloudPuff(
    Canvas canvas,
    double x,
    double y,
    double cw,
    double ch,
    Color topC,
    Color botC,
  ) {
    final puffPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [topC.withValues(alpha: 0.92), botC.withValues(alpha: 0.85)],
      ).createShader(Rect.fromLTWH(x, y, cw, ch));
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(x, y, cw, ch),
        const Radius.circular(5),
      ),
      puffPaint,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(x + cw * 0.15, y - ch * 0.35, cw * 0.55, ch * 0.55),
        const Radius.circular(4),
      ),
      puffPaint,
    );
  }

  void _draw3DVoxelCloud(
    Canvas canvas,
    double x,
    double y,
    double cw,
    double ch,
    Color topC,
    Color botC,
  ) {
    final topP = Paint()..color = topC.withValues(alpha: 0.95);
    final botP = Paint()..color = botC.withValues(alpha: 0.90);
    canvas.drawRect(Rect.fromLTWH(x, y, cw, ch * 0.65), topP);
    canvas.drawRect(Rect.fromLTWH(x, y + ch * 0.65, cw, ch * 0.35), botP);
    canvas.drawRect(
      Rect.fromLTWH(x + cw * 0.20, y - ch * 0.40, cw * 0.45, ch * 0.40),
      topP,
    );
    canvas.drawRect(
      Rect.fromLTWH(x + cw * 0.65, y + ch * 0.15, cw * 0.25, ch * 0.50),
      topP,
    );
    canvas.drawRect(
      Rect.fromLTWH(x + cw * 0.65, y + ch * 0.65, cw * 0.25, ch * 0.35),
      botP,
    );
  }

  void _drawSteppedMountainSilhouette(
    Canvas canvas,
    double w,
    double baseH,
    Color col,
    double peakHeight, {
    double shift = 0.0,
  }) {
    final p = Path();
    p.moveTo(0, baseH + peakHeight);
    const segments = 8;
    final segW = w / segments;
    for (var i = 0; i <= segments; i++) {
      final segX = i * segW;
      final alt = (i % 2 == 1)
          ? -peakHeight
          : (i % 4 == 2 ? -peakHeight * 0.55 : 0.0);
      p.lineTo(segX, baseH + alt);
    }
    p.lineTo(w, baseH + peakHeight);
    p.close();
    canvas.drawPath(p, Paint()..color = col);
  }

  void _drawMinecraftOakTree(
    Canvas canvas,
    double x,
    double y,
    double tw,
    double th,
    Color leafColor,
  ) {
    final trunkW = tw * 0.22;
    final trunkH = th * 0.50;
    canvas.drawRect(
      Rect.fromLTWH(x + (tw - trunkW) / 2, y + th - trunkH, trunkW, trunkH),
      Paint()..color = const Color(0xFF5D4037),
    );
    final leafPaint = Paint()..color = leafColor;
    final leafShadow = Paint()
      ..color = Color.lerp(leafColor, Colors.black, 0.25)!;
    canvas.drawRect(Rect.fromLTWH(x, y + th * 0.20, tw, th * 0.45), leafPaint);
    canvas.drawRect(
      Rect.fromLTWH(x + tw * 0.10, y + th * 0.55, tw * 0.80, th * 0.12),
      leafShadow,
    );
    canvas.drawRect(
      Rect.fromLTWH(x + tw * 0.18, y, tw * 0.64, th * 0.28),
      leafPaint,
    );
  }

  void _drawMinecraftSpruceTree(
    Canvas canvas,
    double x,
    double y,
    double tw,
    double th,
    Color leafColor,
  ) {
    final trunkW = tw * 0.18;
    canvas.drawRect(
      Rect.fromLTWH(x + (tw - trunkW) / 2, y + th * 0.6, trunkW, th * 0.4),
      Paint()..color = const Color(0xFF3E2723),
    );
    final spruceLeaf = Color.lerp(leafColor, const Color(0xFF1B3820), 0.35)!;
    final p = Paint()..color = spruceLeaf;
    canvas.drawRect(Rect.fromLTWH(x, y + th * 0.52, tw, th * 0.22), p);
    canvas.drawRect(
      Rect.fromLTWH(x + tw * 0.15, y + th * 0.30, tw * 0.70, th * 0.24),
      p,
    );
    canvas.drawRect(
      Rect.fromLTWH(x + tw * 0.30, y + th * 0.10, tw * 0.40, th * 0.22),
      p,
    );
    canvas.drawRect(Rect.fromLTWH(x + tw * 0.40, y, tw * 0.20, th * 0.12), p);
  }

  @override
  bool shouldRepaint(covariant _AtmosphereDetailedScenePainter oldDelegate) {
    return oldDelegate.timeOfDay != timeOfDay ||
        oldDelegate.activeSkyColor != activeSkyColor ||
        oldDelegate.sunOrMoonScale != sunOrMoonScale ||
        oldDelegate.fogDensity != fogDensity ||
        oldDelegate.rayIntensity != rayIntensity ||
        oldDelegate.nightVision != nightVision ||
        oldDelegate.cloudType != cloudType ||
        oldDelegate.cloudTopColor != cloudTopColor ||
        oldDelegate.cloudBottomColor != cloudBottomColor;
  }
}

/// High-Detail Procedural Minecraft Lighting Scene Painter (Torch Cavern & God Rays)
class _LightingDetailedScenePainter extends CustomPainter {
  final double blockLightIntensity;
  final double lightIntensity;
  final Color torchColor;
  final Color rayColor;
  final Color fogColor;
  final String shadowQuality;

  _LightingDetailedScenePainter({
    required this.blockLightIntensity,
    required this.lightIntensity,
    required this.torchColor,
    required this.rayColor,
    required this.fogColor,
    required this.shadowQuality,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // 1. Dark stone cavern/room background
    canvas.drawRect(
      Rect.fromLTWH(0, 0, w, h),
      Paint()..color = const Color(0xFF0F172A),
    );

    // 2. Cobblestone / Stone brick wall patterns
    const stoneDark = Color(0xFF1E293B);
    const stoneBorder = Color(0xFF090D16);
    final brickW = w / 12;
    final brickH = h / 6;
    for (var r = 0; r < 6; r++) {
      final xOffset = (r % 2 == 1) ? brickW / 2 : 0.0;
      for (var c = -1; c < 13; c++) {
        final bx = c * brickW + xOffset;
        final by = r * brickH;
        canvas.drawRect(
          Rect.fromLTWH(bx + 1, by + 1, brickW - 2, brickH - 2),
          Paint()
            ..color = (c + r) % 3 == 0 ? const Color(0xFF253348) : stoneDark,
        );
        canvas.drawRect(
          Rect.fromLTWH(bx, by, brickW, brickH),
          Paint()
            ..color = stoneBorder
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1.0,
        );
      }
    }

    // 3. Wooden support beam across ceiling & post
    final woodPaint = Paint()..color = const Color(0xFF452211);
    final woodHighlight = Paint()..color = const Color(0xFF5D301A);
    canvas.drawRect(Rect.fromLTWH(0, 0, w, h * 0.18), woodPaint);
    canvas.drawRect(Rect.fromLTWH(0, 0, w, 2.5), woodHighlight);
    canvas.drawRect(Rect.fromLTWH(w * 0.72, 0, w * 0.10, h), woodPaint);
    canvas.drawRect(Rect.fromLTWH(w * 0.72, 0, 2.5, h), woodHighlight);

    // 4. Diagonal God Rays streaming in from skylight
    if (lightIntensity > 0.1) {
      final effAlpha = (0.35 * lightIntensity).clamp(0.05, 0.65);
      final rayP = Path()
        ..moveTo(w * 0.10, 0)
        ..lineTo(w * 0.35, 0)
        ..lineTo(w * 0.65, h)
        ..lineTo(w * 0.25, h)
        ..close();
      canvas.drawPath(
        rayP,
        Paint()
          ..shader = LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              rayColor.withValues(alpha: effAlpha),
              rayColor.withValues(alpha: effAlpha * 0.2),
              Colors.transparent,
            ],
            stops: const [0.0, 0.6, 1.0],
          ).createShader(Rect.fromLTWH(0, 0, w, h)),
      );
    }

    // 5. Point Light Torch Glow on the right post
    final torchX = w * 0.72 + (w * 0.10) / 2;
    final torchY = h * 0.45;
    final glowRad = (55.0 * blockLightIntensity).clamp(18.0, 110.0);

    final torchGlow = Paint()
      ..shader =
          RadialGradient(
            colors: [
              torchColor.withValues(
                alpha: (0.85 * blockLightIntensity).clamp(0.25, 0.95),
              ),
              torchColor.withValues(
                alpha: (0.35 * blockLightIntensity).clamp(0.1, 0.6),
              ),
              Colors.transparent,
            ],
            stops: const [0.0, 0.45, 1.0],
          ).createShader(
            Rect.fromCircle(center: Offset(torchX, torchY), radius: glowRad),
          );
    canvas.drawCircle(Offset(torchX, torchY), glowRad, torchGlow);

    // Torch stick & flame block
    canvas.drawRect(
      Rect.fromLTWH(torchX - 2.5, torchY - 2, 5, 20),
      Paint()..color = const Color(0xFF6B4226),
    );
    canvas.drawRect(
      Rect.fromLTWH(torchX - 3.5, torchY - 8, 7, 7),
      Paint()..color = const Color(0xFFFFB300),
    );
    canvas.drawRect(
      Rect.fromLTWH(torchX - 2, torchY - 11, 4, 5),
      Paint()..color = const Color(0xFFFFF9C4),
    );

    // 6. Ambient Fog Layer
    canvas.drawRect(
      Rect.fromLTWH(0, 0, w, h),
      Paint()..color = fogColor.withValues(alpha: 0.12),
    );

    // 7. Dynamic Vignette & Shadows
    final shadowAlpha = shadowQuality.contains('Ultra')
        ? 0.45
        : (shadowQuality.contains('High') ? 0.35 : 0.22);
    final vignette = Paint()
      ..shader = RadialGradient(
        center: Alignment.center,
        radius: 0.9,
        colors: [
          Colors.transparent,
          Colors.black.withValues(alpha: shadowAlpha),
        ],
        stops: const [0.55, 1.0],
      ).createShader(Rect.fromLTWH(0, 0, w, h));
    canvas.drawRect(Rect.fromLTWH(0, 0, w, h), vignette);
  }

  @override
  bool shouldRepaint(covariant _LightingDetailedScenePainter oldDelegate) {
    return oldDelegate.blockLightIntensity != blockLightIntensity ||
        oldDelegate.lightIntensity != lightIntensity ||
        oldDelegate.torchColor != torchColor ||
        oldDelegate.rayColor != rayColor ||
        oldDelegate.fogColor != fogColor ||
        oldDelegate.shadowQuality != shadowQuality;
  }
}

/// High-Detail Procedural Minecraft Water Ocean Scene Painter
class _WaterDetailedScenePainter extends CustomPainter {
  final Color waterColor;
  final double waterSpeed;
  final String waterQuality;
  final bool underwaterCaustics;

  _WaterDetailedScenePainter({
    required this.waterColor,
    required this.waterSpeed,
    required this.waterQuality,
    required this.underwaterCaustics,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // 1. Sunny sky above horizon
    final skyPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          const Color(0xFF0284C7),
          const Color(0xFF7DD3FC),
          const Color(0xFFE0F2FE),
        ],
        stops: const [0.0, 0.45, 0.70],
      ).createShader(Rect.fromLTWH(0, 0, w, h * 0.45));
    canvas.drawRect(Rect.fromLTWH(0, 0, w, h * 0.45), skyPaint);

    // Fluffy cloud
    canvas.drawRect(
      Rect.fromLTWH(w * 0.10, h * 0.08, w * 0.32, h * 0.10),
      Paint()..color = Colors.white.withValues(alpha: 0.9),
    );
    canvas.drawRect(
      Rect.fromLTWH(w * 0.16, h * 0.04, w * 0.18, h * 0.06),
      Paint()..color = Colors.white,
    );

    // Distant tropical island
    canvas.drawRect(
      Rect.fromLTWH(w * 0.55, h * 0.34, w * 0.35, h * 0.11),
      Paint()..color = const Color(0xFF2E7D32),
    );
    canvas.drawRect(
      Rect.fromLTWH(w * 0.52, h * 0.41, w * 0.41, h * 0.04),
      Paint()..color = const Color(0xFFC0CA33),
    );

    // 2. Sand seabed under the water
    final sandPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [const Color(0xFFD4B483), const Color(0xFF9E7846)],
      ).createShader(Rect.fromLTWH(0, h * 0.45, w, h * 0.55));
    canvas.drawRect(Rect.fromLTWH(0, h * 0.45, w, h * 0.55), sandPaint);

    // Sand voxel blocks & coral details
    canvas.drawRect(
      Rect.fromLTWH(w * 0.15, h * 0.72, w * 0.12, h * 0.10),
      Paint()..color = const Color(0xFFE91E63).withValues(alpha: 0.8),
    );
    canvas.drawRect(
      Rect.fromLTWH(w * 0.70, h * 0.78, w * 0.14, h * 0.09),
      Paint()..color = const Color(0xFF9C27B0).withValues(alpha: 0.8),
    );

    // 3. Water body depth gradient tinted with waterColor
    final waterAlpha = waterQuality == 'Low' ? 0.85 : 0.65;
    final waterPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          waterColor.withValues(alpha: waterAlpha * 0.6),
          waterColor.withValues(alpha: waterAlpha),
        ],
        stops: const [0.0, 1.0],
      ).createShader(Rect.fromLTWH(0, h * 0.45, w, h * 0.55));
    canvas.drawRect(Rect.fromLTWH(0, h * 0.45, w, h * 0.55), waterPaint);

    // 4. Procedural Caustic Water Wave Ripples
    final waveAlpha = (0.35 * (waterSpeed.clamp(0.5, 2.0))).clamp(0.15, 0.65);
    final wavePaint = Paint()
      ..color = Colors.white.withValues(alpha: waveAlpha);

    for (var i = 0; i < 7; i++) {
      final y = h * 0.48 + i * (h * 0.07);
      final rw = w * (0.08 + (i * 0.02));
      final spacing = rw * 1.6;
      final stepOffset = (i % 2 == 1) ? rw * 0.8 : 0.0;
      for (var x = -rw; x < w + rw; x += spacing) {
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromLTWH(x + stepOffset, y, rw, 2.5),
            const Radius.circular(1.5),
          ),
          wavePaint,
        );
      }
    }

    // 5. Shoreline Foam line at water edge
    canvas.drawRect(
      Rect.fromLTWH(0, h * 0.45, w, 2.5),
      Paint()..color = Colors.white.withValues(alpha: 0.8),
    );

    // 6. Underwater caustics network
    if (underwaterCaustics) {
      final cP = Paint()
        ..color = Colors.white.withValues(alpha: 0.18)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2;
      for (var i = 0; i < 4; i++) {
        final cx = w * (0.15 + i * 0.22);
        final cy = h * (0.60 + (i % 2) * 0.15);
        canvas.drawCircle(Offset(cx, cy), 14, cP);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _WaterDetailedScenePainter oldDelegate) {
    return oldDelegate.waterColor != waterColor ||
        oldDelegate.waterSpeed != waterSpeed ||
        oldDelegate.waterQuality != waterQuality ||
        oldDelegate.underwaterCaustics != underwaterCaustics;
  }
}

/// High-Detail Procedural Minecraft Weather Storm Scene Painter
class _WeatherDetailedScenePainter extends CustomPainter {
  final Color rainFogColor;
  final Color rainWaterColor;
  final double metalness;
  final bool pbrEnabled;

  _WeatherDetailedScenePainter({
    required this.rainFogColor,
    required this.rainWaterColor,
    required this.metalness,
    required this.pbrEnabled,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // 1. Dark stormy overcast sky
    final stormSky = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          const Color(0xFF1E293B),
          const Color(0xFF334155),
          const Color(0xFF475569),
        ],
        stops: const [0.0, 0.50, 0.75],
      ).createShader(Rect.fromLTWH(0, 0, w, h));
    canvas.drawRect(Rect.fromLTWH(0, 0, w, h), stormSky);

    // 2. Heavy dark stormy voxel thunderclouds
    const cloudDark = Color(0xFF182232);
    const cloudShadow = Color(0xFF0F172A);
    canvas.drawRect(
      Rect.fromLTWH(0, 0, w, h * 0.28),
      Paint()..color = cloudDark,
    );
    canvas.drawRect(
      Rect.fromLTWH(0, h * 0.24, w, h * 0.06),
      Paint()..color = cloudShadow,
    );
    canvas.drawRect(
      Rect.fromLTWH(w * 0.20, h * 0.28, w * 0.60, h * 0.08),
      Paint()..color = cloudDark,
    );
    canvas.drawRect(
      Rect.fromLTWH(w * 0.25, h * 0.34, w * 0.50, h * 0.04),
      Paint()..color = cloudShadow,
    );

    // 3. Shrouded distant mountain silhouettes in rain fog
    final mtnColor = Color.lerp(const Color(0xFF1E293B), rainFogColor, 0.45)!;
    final p = Path();
    p.moveTo(0, h * 0.62);
    p.lineTo(w * 0.25, h * 0.44);
    p.lineTo(w * 0.55, h * 0.55);
    p.lineTo(w * 0.80, h * 0.42);
    p.lineTo(w, h * 0.60);
    p.lineTo(w, h);
    p.lineTo(0, h);
    p.close();
    canvas.drawPath(p, Paint()..color = mtnColor);

    // 4. Wet ground terrain with puddles
    final groundPaint = Paint()..color = const Color(0xFF2A3428);
    canvas.drawRect(Rect.fromLTWH(0, h * 0.62, w, h * 0.38), groundPaint);

    // PBR Metallic puddles reflecting stormy sky
    final puddleColor = Color.lerp(
      const Color(0xFF475569),
      rainWaterColor,
      0.4,
    )!;
    final puddlePaint = Paint()..color = puddleColor;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(w * 0.12, h * 0.74, w * 0.28, h * 0.12),
        const Radius.circular(6),
      ),
      puddlePaint,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(w * 0.55, h * 0.80, w * 0.35, h * 0.12),
        const Radius.circular(6),
      ),
      puddlePaint,
    );

    // Metallic sheen overlay when PBR / Metalness is active
    if (pbrEnabled) {
      final shinePaint = Paint()
        ..shader = LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withValues(alpha: 0.12 + (metalness * 0.25)),
            Colors.transparent,
            Colors.white.withValues(alpha: 0.06 + (metalness * 0.15)),
          ],
        ).createShader(Rect.fromLTWH(0, h * 0.62, w, h * 0.38));
      canvas.drawRect(Rect.fromLTWH(0, h * 0.62, w, h * 0.38), shinePaint);
    }

    // 5. Rain Fog mist rising from ground
    final fogPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Colors.transparent, rainFogColor.withValues(alpha: 0.40)],
      ).createShader(Rect.fromLTWH(0, h * 0.40, w, h * 0.60));
    canvas.drawRect(Rect.fromLTWH(0, h * 0.40, w, h * 0.60), fogPaint);

    // 6. Angled Rain Streaks
    final rainPaint = Paint()..color = Colors.white.withValues(alpha: 0.42);
    const rainDrops = [
      Offset(0.08, 0.15),
      Offset(0.18, 0.30),
      Offset(0.28, 0.10),
      Offset(0.38, 0.45),
      Offset(0.48, 0.20),
      Offset(0.58, 0.50),
      Offset(0.68, 0.15),
      Offset(0.78, 0.35),
      Offset(0.88, 0.22),
      Offset(0.94, 0.48),
      Offset(0.14, 0.65),
      Offset(0.32, 0.75),
      Offset(0.52, 0.68),
      Offset(0.74, 0.72),
      Offset(0.85, 0.60),
    ];
    for (final drop in rainDrops) {
      final dx = drop.dx * w;
      final dy = drop.dy * h;
      canvas.drawLine(Offset(dx, dy), Offset(dx - 5, dy + 20), rainPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _WeatherDetailedScenePainter oldDelegate) {
    return oldDelegate.rainFogColor != rainFogColor ||
        oldDelegate.rainWaterColor != rainWaterColor ||
        oldDelegate.metalness != metalness ||
        oldDelegate.pbrEnabled != pbrEnabled;
  }
}

// ─── DYNAMIC TAB THEMES FOR SHADER BUILDER ─────────────────────────────────
class _BuilderTabTheme {
  final String label;
  final VoxelIconType icon;
  final Uint8List artBytes; // The scene image matching screenshot
  final Color primary; // Signature accent color
  final Color bg; // Full app background
  final Color surface; // Top AppBar, Tab bar header & Bottom bar
  final Color border; // Subtle frame & divider border
  final Color cardBg; // Darkened card background
  final List<Color> nextGradient; // Next Tab / Generate button gradient
  final Color nextBorder; // Next Tab button border
  final Color nextShadow; // Next Tab button glow/shadow
  final Color backBg; // Back button background
  final Color backBorder; // Back button border

  const _BuilderTabTheme({
    required this.label,
    required this.icon,
    required this.artBytes,
    required this.primary,
    required this.bg,
    required this.surface,
    required this.border,
    required this.cardBg,
    required this.nextGradient,
    required this.nextBorder,
    required this.nextShadow,
    required this.backBg,
    required this.backBorder,
  });
}

// ─── SHADER EDITOR SCREEN ───────────────────────────────────────────────────
class ShaderEditorScreen extends StatefulWidget {
  final List<int>? uploadedShaderBytes;
  final String? uploadedShaderName;
  final Uint8List? uploadedLogoBytes;
  final String shaderName;
  final ShaderPresetConfig? presetConfig;

  const ShaderEditorScreen({
    super.key,
    required this.uploadedShaderBytes,
    required this.uploadedShaderName,
    required this.uploadedLogoBytes,
    required this.shaderName,
    this.presetConfig,
  });

  @override
  State<ShaderEditorScreen> createState() => _ShaderEditorScreenState();
}

class _ShaderEditorScreenState extends State<ShaderEditorScreen>
    with TickerProviderStateMixin {
  late final TabController _tabController;

  // ── State vars ──────────────────────────────────────────────────────────
  late TextEditingController shaderNameCtrl;
  Uint8List? _activeLogoBytes;
  List<int>? _generatedPackBytes;
  String? _generatedPackName;
  bool _isGenerated = false;

  String _activeColorKey = 'Morning';

  // Time & Atmosphere
  Color morningColor = const Color(0xFFFFA040);
  Color noonColor = const Color(0xFF87CEEB);
  Color eveningColor = const Color(0xFFFFA500);
  Color nightColor = const Color(0xFF00008B);
  double sunSize = 1.0;
  double sunSizeMorning = 1.0;
  double sunSizeEvening = 1.2;
  double moonSize = 1.0;
  double nightVision = 1.0;
  double fogDensity = 1.0;
  double morningFogDensity = 1.0;
  double eveningFogDensity = 1.1;
  double nightFogDensity = 1.0;
  double morningRayIntensity = 1.0;
  double eveningRayIntensity = 1.2;
  double moonRayIntensity = 1.0;
  String volumetricRays = 'Cinematic (Heavy)';
  Color cloudTopColor = const Color(0xFFFFFFFF);
  Color cloudBottomColor = const Color(0xFFB0B4B8);
  String cloudType = 'Realistic 3D'; // 'Realistic 3D', 'Volumetric', 'Flat 2D'
  bool wavingFoliage = true;
  double foliageWaveSpeed = 1.0;
  String volumetricFogProfile =
      'Cinematic'; // 'Cinematic', 'Balanced', 'Low End'
  String biomeTone =
      'Dynamic'; // 'Dynamic', 'Vibrant', 'Savanna', 'Frost', 'Moody'

  // Lighting & Shadows
  Color rayMorningColor = const Color(0xFFFFA040);
  Color rayNoonColor = const Color(0xFFFAFCFF);
  Color rayEveningColor = const Color(0xFFFF6020);
  Color rayNightColor = const Color(0xFF3050AA);
  Color fogColor = const Color(0xFFC0BCE6);
  Color torchLightColor = const Color(0xFFFF9933);
  double lightIntensity = 1.0;
  double blockLightIntensity = 1.0;
  String shadowQuality = 'Low'; // 'Off', 'Low', 'High', 'Ultra'
  bool enablePointLightShadows = true;

  // World & Water
  Color waterColor = const Color(0xFF00E5FF);
  double windSpeed = 1.0;
  String waterQuality = 'Ultra'; // 'Low', 'Medium', 'High', 'Ultra'
  bool underwaterCaustics = true;
  bool worldReflectionsEnabled = true;
  double globalMetalness = 0.0;
  bool enablePBR = true;

  // Weather
  Color rainFogColor = const Color(0xFF5A636A);
  Color rainWaterColor = const Color(0xFF2E3D48);

  // Color Grading
  double globalSaturation = 1.0;
  double bloomIntensity = 1.0;
  double autoExposure = 1.0;
  double contrast = 1.0;
  String toneMapFilter = 'ACES (Cinematic)';

  static final List<_BuilderTabTheme> _tabThemes = [
    // 0: Atmosphere default (Vibrant Sky & Dawn) - Low saturation dark theme
    _BuilderTabTheme(
      label: 'ATMOSPHERE',
      icon: VoxelIconType.sun,
      artBytes: kTabArtAtmosphereBytes,
      primary: const Color(0xFF7DD3FC),
      bg: const Color(0xFF080D14),
      surface: const Color(0xFF0E1724),
      border: const Color(0xFF1C324C),
      cardBg: const Color(0xFF131B2A),
      nextGradient: const [Color(0xFF17304A), Color(0xFF1D4265)],
      nextBorder: const Color(0xFF7DD3FC),
      nextShadow: const Color(0x337DD3FC),
      backBg: const Color(0xFF131B2A),
      backBorder: const Color(0xFF1C324C),
    ),
    // 1: Lighting (Warm Minecraft Torch & Lantern Amber with Refined Dark Slate)
    _BuilderTabTheme(
      label: 'LIGHTING',
      icon: VoxelIconType.lantern,
      artBytes: kTabArtLightingBytes,
      primary: const Color(0xFFFDE68A),
      bg: const Color(0xFF080D14),
      surface: const Color(0xFF0E1724),
      border: const Color(0xFF383124),
      cardBg: const Color(0xFF131B2A),
      nextGradient: const [Color(0xFF382F1B), Color(0xFF4C3E21)],
      nextBorder: const Color(0xFFFDE68A),
      nextShadow: const Color(0x33FDE68A),
      backBg: const Color(0xFF131B2A),
      backBorder: const Color(0xFF383124),
    ),
    // 2: Water (Soft Oceanic Aqua & Caustics with Refined Dark Slate)
    _BuilderTabTheme(
      label: 'WATER',
      icon: VoxelIconType.waves,
      artBytes: kTabArtWaterBytes,
      primary: const Color(0xFF67E8F9),
      bg: const Color(0xFF080D14),
      surface: const Color(0xFF0E1724),
      border: const Color(0xFF183744),
      cardBg: const Color(0xFF131B2A),
      nextGradient: const [Color(0xFF153842), Color(0xFF1B4E5C)],
      nextBorder: const Color(0xFF67E8F9),
      nextShadow: const Color(0x3367E8F9),
      backBg: const Color(0xFF131B2A),
      backBorder: const Color(0xFF183744),
    ),
    // 3: Weather (Storm Slate & Nimbus Blue with Refined Dark Slate)
    _BuilderTabTheme(
      label: 'WEATHER',
      icon: VoxelIconType.rainCloud,
      artBytes: kTabArtWeatherBytes,
      primary: const Color(0xFFCBD5E1),
      bg: const Color(0xFF080D14),
      surface: const Color(0xFF0E1724),
      border: const Color(0xFF273446),
      cardBg: const Color(0xFF131B2A),
      nextGradient: const [Color(0xFF253344), Color(0xFF33445A)],
      nextBorder: const Color(0xFFCBD5E1),
      nextShadow: const Color(0x33CBD5E1),
      backBg: const Color(0xFF131B2A),
      backBorder: const Color(0xFF273446),
    ),
  ];

  @override
  void initState() {
    super.initState();
    shaderNameCtrl = TextEditingController(text: widget.shaderName);
    _activeLogoBytes = widget.uploadedLogoBytes;
    _tabController = TabController(length: _tabThemes.length, vsync: this);
    _tabController.addListener(() {
      if (mounted) setState(() {});
    });

    if (widget.presetConfig != null) {
      final p = widget.presetConfig!;
      morningColor = p.morningColor;
      noonColor = p.noonColor;
      eveningColor = p.eveningColor;
      nightColor = p.nightColor;
      sunSize = p.sunSize;
      sunSizeMorning = p.sunSize;
      sunSizeEvening = (p.sunSize * 1.15).clamp(0.0, 2.0);
      moonSize = 1.0;
      nightVision = p.nightVision;
      fogDensity = p.fogDensity;
      morningFogDensity = p.fogDensity;
      eveningFogDensity = (p.fogDensity * 1.1).clamp(0.0, 2.0);
      nightFogDensity = p.fogDensity;
      morningRayIntensity = 1.0;
      eveningRayIntensity = 1.2;
      moonRayIntensity = 1.0;
      cloudType = p.cloudType;
      torchLightColor = p.torchColor;
      lightIntensity = p.lightIntensity;
      blockLightIntensity = p.blockLightIntensity;
      shadowQuality = p.shadowQuality;
      enablePointLightShadows = p.enablePointLightShadows;
      volumetricFogProfile = p.volumetricFogProfile;
      rayMorningColor = p.rayMorningColor;
      rayNoonColor = p.rayNoonColor;
      rayEveningColor = p.rayEveningColor;
      rayNightColor = p.rayNightColor;
      waterColor = p.waterColor;
      windSpeed = p.windSpeed;
      waterQuality = p.waterQuality;
      underwaterCaustics = p.underwaterCaustics;
      rainFogColor = p.rainFogColor;
      rainWaterColor = p.rainWaterColor;
      worldReflectionsEnabled = p.worldReflections;
      enablePBR = p.enablePBR;
      globalMetalness = p.metalness;
      wavingFoliage = p.wavingFoliage;
      foliageWaveSpeed = p.foliageWaveSpeed;
      toneMapFilter = p.toneMapFilter;
      biomeTone = p.biomeTone;
      globalSaturation = p.saturation;
      contrast = p.contrast;
      autoExposure = p.autoExposure;
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    shaderNameCtrl.dispose();
    super.dispose();
  }

  // ── Helper builders ────────────────────────────────────────────────────
  Future<void> _pickEditorLogo() async {
    try {
      final f = await FilePicker.pickFile(
        type: FileType.custom,
        allowedExtensions: ['png', 'jpg', 'jpeg'],
      );
      if (f != null) {
        final bytes = await f.readAsBytes();
        if (bytes.isNotEmpty) {
          setState(() {
            _activeLogoBytes = bytes;
          });
          _snack('Custom pack icon updated! ✨');
        }
      }
    } catch (e) {
      _snack('Could not load icon: $e', isError: true);
    }
  }

  _BuilderTabTheme get _activeTabTheme {
    final idx = _tabController.index.clamp(0, _tabThemes.length - 1);
    if (idx == 0) {
      if (_activeColorKey.contains('Morning')) {
        return _BuilderTabTheme(
          label: 'ATMOSPHERE',
          icon: VoxelIconType.sun,
          artBytes: kTabArtAtmosphereBytes,
          primary: const Color(0xFFFDBA74), // Warm Sunrise Golden Amber Orange
          bg: const Color(0xFF080D14), // Clean Obsidian Dark
          surface: const Color(0xFF0E1724), // Midnight Slate
          border: const Color(0xFF3D2A18), // Soft Warm Dawn Slate
          cardBg: const Color(0xFF131B2A), // Dark Card Slate
          nextGradient: const [Color(0xFF3B271A), Color(0xFF523522)],
          nextBorder: const Color(0xFFFDBA74),
          nextShadow: const Color(0x33FDBA74),
          backBg: const Color(0xFF131B2A),
          backBorder: const Color(0xFF3D2A18),
        );
      } else if (_activeColorKey.contains('Evening')) {
        return _BuilderTabTheme(
          label: 'ATMOSPHERE',
          icon: VoxelIconType.sun,
          artBytes: kHeroSunsetBytes,
          primary: const Color(0xFFFDBA74), // Sunset Soft Peach/Amber
          bg: const Color(0xFF080D14), // Clean Obsidian Dark
          surface: const Color(0xFF0E1724), // Midnight Slate
          border: const Color(0xFF3C2C24), // Soft Twilight Slate
          cardBg: const Color(0xFF131B2A), // Dark Card Slate
          nextGradient: const [Color(0xFF3A241B), Color(0xFF503022)],
          nextBorder: const Color(0xFFFDBA74),
          nextShadow: const Color(0x33FDBA74),
          backBg: const Color(0xFF131B2A),
          backBorder: const Color(0xFF3C2C24),
        );
      } else if (_activeColorKey.contains('Night')) {
        return _BuilderTabTheme(
          label: 'ATMOSPHERE',
          icon: VoxelIconType.moon,
          artBytes: kTabArtAtmosphereBytes,
          primary: const Color(0xFFA5B4FC), // Starlight Soft Periwinkle
          bg: const Color(0xFF080D14), // Clean Obsidian Dark
          surface: const Color(0xFF0E1724), // Midnight Slate
          border: const Color(0xFF242C48), // Soft Midnight Astral Slate
          cardBg: const Color(0xFF131B2A), // Dark Card Slate
          nextGradient: const [Color(0xFF22294A), Color(0xFF2D3764)],
          nextBorder: const Color(0xFFA5B4FC),
          nextShadow: const Color(0x33A5B4FC),
          backBg: const Color(0xFF131B2A),
          backBorder: const Color(0xFF242C48),
        );
      } else {
        // Noon (Day)
        return _BuilderTabTheme(
          label: 'ATMOSPHERE',
          icon: VoxelIconType.sun,
          artBytes: kTabArtAtmosphereBytes,
          primary: const Color(0xFF7DD3FC), // Soft Sky Azure
          bg: const Color(0xFF080D14), // Clean Obsidian Dark
          surface: const Color(0xFF0E1724), // Midnight Slate
          border: const Color(0xFF1C324C), // Soft Azure Slate
          cardBg: const Color(0xFF131B2A), // Dark Card Slate
          nextGradient: const [Color(0xFF17304A), Color(0xFF1D4265)],
          nextBorder: const Color(0xFF7DD3FC),
          nextShadow: const Color(0x337DD3FC),
          backBg: const Color(0xFF131B2A),
          backBorder: const Color(0xFF1C324C),
        );
      }
    }
    return _tabThemes[idx];
  }

  void _showRenameDialog() {
    final curTheme = _activeTabTheme;
    final renameCtrl = TextEditingController(text: shaderNameCtrl.text);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF0E1722),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: Color(0xFF1E293B), width: 1.2),
        ),
        title: const Text(
          'Pack Shader Name',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w800,
          ),
        ),
        content: TextField(
          controller: renameCtrl,
          autofocus: true,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.w700,
          ),
          decoration: InputDecoration(
            hintText: 'Enter shader name',
            hintStyle: const TextStyle(color: Color(0xFF64748B)),
            filled: true,
            fillColor: const Color(0xFF16202A),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 12,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Color(0xFF334155)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: curTheme.primary, width: 1.5),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text(
              'Cancel',
              style: TextStyle(color: Color(0xFF94A3B8)),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: curTheme.primary,
              foregroundColor: Colors.black,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onPressed: () {
              final newName = renameCtrl.text.trim();
              if (newName.isNotEmpty) {
                setState(() {
                  shaderNameCtrl.text = newName;
                });
              }
              Navigator.pop(ctx);
            },
            child: const Text(
              'Save',
              style: TextStyle(fontWeight: FontWeight.w800),
            ),
          ),
        ],
      ),
    ).then((_) => renameCtrl.dispose());
  }

  void _snack(String msg, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          msg,
          style: const TextStyle(
            color: Color(0xFFF2EFE9),
            fontWeight: FontWeight.w700,
            fontSize: 13,
          ),
        ),
        backgroundColor: isError
            ? const Color(0xFF5D1E1E)
            : const Color(0xFF262422),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: BorderSide(
            color: isError ? const Color(0xFFE57373) : const Color(0xFF5A524A),
            width: 1.5,
          ),
        ),
        elevation: 8,
      ),
    );
  }

  List<Map<String, dynamic>> _getCuratedPalette(String title) {
    if (title.contains('Morning')) {
      return [
        {'name': 'Golden Sunrise', 'color': const Color(0xFFFFA040)},
        {'name': 'Sunrise Amber', 'color': const Color(0xFFFFB347)},
        {'name': 'Morning Sunburst', 'color': const Color(0xFFFDBA74)},
        {'name': 'Dawn Gold', 'color': const Color(0xFFFBBF24)},
        {'name': 'Tangerine Dawn', 'color': const Color(0xFFFB923C)},
        {'name': 'Warm Daybreak', 'color': const Color(0xFFFFAB40)},
        {'name': 'Radiant Amber', 'color': const Color(0xFFF59E0B)},
        {'name': 'Honey Glow', 'color': const Color(0xFFFDE047)},
      ];
    } else if (title.contains('Noon')) {
      return [
        {'name': 'Pure Azure', 'color': const Color(0xFF87CEEB)},
        {'name': 'Sky Cyan', 'color': const Color(0xFF38BDF8)},
        {'name': 'Crystal Daylight', 'color': const Color(0xFF60A5FA)},
        {'name': 'Tropical Turquoise', 'color': const Color(0xFF06B6D4)},
        {'name': 'Radiant Ether', 'color': const Color(0xFF22D3EE)},
        {'name': 'Deep Cerulean', 'color': const Color(0xFF0284C7)},
        {'name': 'Overcast Silver', 'color': const Color(0xFF94A3B8)},
        {'name': 'Diamond Day', 'color': const Color(0xFF00E5FF)},
      ];
    } else if (title.contains('Evening')) {
      return [
        {'name': 'Burning Gold', 'color': const Color(0xFFFFA500)},
        {'name': 'Sunset Amber', 'color': const Color(0xFFF97316)},
        {'name': 'Crimson Twilight', 'color': const Color(0xFFF43F5E)},
        {'name': 'Blood Orange', 'color': const Color(0xFFEA580C)},
        {'name': 'Sunset Magenta', 'color': const Color(0xFFD946EF)},
        {'name': 'Twilight Purple', 'color': const Color(0xFF7C3AED)},
        {'name': 'Golden Hour', 'color': const Color(0xFFFB923C)},
        {'name': 'Fiery Dusk', 'color': const Color(0xFFFF6020)},
      ];
    } else if (title.contains('Night')) {
      return [
        {'name': 'Midnight Indigo', 'color': const Color(0xFF0F172A)},
        {'name': 'Royal Starlight', 'color': const Color(0xFF1E1B4B)},
        {'name': 'Cyber Violet', 'color': const Color(0xFF312E81)},
        {'name': 'Abyssal Obsidian', 'color': const Color(0xFF020617)},
        {'name': 'Moonlit Cobalt', 'color': const Color(0xFF1E3A8A)},
        {'name': 'Aurora Teal', 'color': const Color(0xFF0F766E)},
        {'name': 'Deep Nebula', 'color': const Color(0xFF4C1D95)},
        {'name': 'Starlight Silver', 'color': const Color(0xFFCBD5E1)},
      ];
    } else if (title.contains('Torch') ||
        title.contains('Ray') ||
        title.contains('Light')) {
      return [
        {'name': 'Campfire Amber', 'color': const Color(0xFFFF9933)},
        {'name': 'Lantern Gold', 'color': const Color(0xFFFBBF24)},
        {'name': 'Soul Fire Cyan', 'color': const Color(0xFF00E5FF)},
        {'name': 'Redstone Ember', 'color': const Color(0xFFEF4444)},
        {'name': 'Golden Sunbeam', 'color': const Color(0xFFFEF08A)},
        {'name': 'Daylight Ray', 'color': const Color(0xFFFAFCFF)},
        {'name': 'Sunset Ray', 'color': const Color(0xFFFF6020)},
        {'name': 'Midnight Ray', 'color': const Color(0xFF3050AA)},
      ];
    } else if (title.contains('Water') || title.contains('Caustic')) {
      return [
        {'name': 'Crystal Lagoon', 'color': const Color(0xFF00E5FF)},
        {'name': 'Tropical Caribbean', 'color': const Color(0xFF06B6D4)},
        {'name': 'Ocean Sapphire', 'color': const Color(0xFF0284C7)},
        {'name': 'Emerald River', 'color': const Color(0xFF10B981)},
        {'name': 'Warm Coral Reef', 'color': const Color(0xFF38BDF8)},
        {'name': 'Glacial Freeze', 'color': const Color(0xFF7DD3FC)},
        {'name': 'Abyssal Trench', 'color': const Color(0xFF0C4A6E)},
        {'name': 'Swamp Murk', 'color': const Color(0xFF3F6212)},
      ];
    } else {
      return [
        {'name': 'Cinematic Rain Fog', 'color': const Color(0xFF5A636A)},
        {'name': 'Stormy Dark Slate', 'color': const Color(0xFF334155)},
        {'name': 'Mountain Mist', 'color': const Color(0xFF64748B)},
        {'name': 'Thunder Tempest', 'color': const Color(0xFF1E293B)},
        {'name': 'Nimbus Overcast', 'color': const Color(0xFF475569)},
        {'name': 'Rainy Lake', 'color': const Color(0xFF2E3D48)},
        {'name': 'Typhoon Cyan', 'color': const Color(0xFF374151)},
        {'name': 'Post-Rain Daylight', 'color': const Color(0xFF94A3B8)},
      ];
    }
  }

  /// Realistic Animated Minecraft Color Crafter Dialog
  void _pickColor(
    String title,
    Color current,
    Function(Color) onSet, {
    ShaderIconType? iconType,
  }) {
    Color tmp = current;
    final hexCtrl = TextEditingController(
      text: current.toARGB32().toRadixString(16).substring(2).toUpperCase(),
    );
    final curatedList = _getCuratedPalette(title);

    // 16 Authentic Minecraft Dyes with rich names & voxel colors
    final minecraftDyes = [
      {'name': 'Bone White', 'color': const Color(0xFFFFFFFF)},
      {'name': 'Ink Black', 'color': const Color(0xFF1D1D21)},
      {'name': 'Lapis Blue', 'color': const Color(0xFF3C44AA)},
      {'name': 'Redstone', 'color': const Color(0xFFB02E26)},
      {'name': 'Glow Yellow', 'color': const Color(0xFFFED83D)},
      {'name': 'Cactus Green', 'color': const Color(0xFF5E7C16)},
      {'name': 'Cyan Prism', 'color': const Color(0xFF169C9C)},
      {'name': 'Light Blue', 'color': const Color(0xFF3AB3DA)},
      {'name': 'Amethyst', 'color': const Color(0xFF8932B8)},
      {'name': 'Magenta', 'color': const Color(0xFFC74EBD)},
      {'name': 'Sunset Orange', 'color': const Color(0xFFF9801D)},
      {'name': 'Pink Tulip', 'color': const Color(0xFFF38BAA)},
      {'name': 'Lime Grass', 'color': const Color(0xFF80C71F)},
      {'name': 'Cocoa Brown', 'color': const Color(0xFF835432)},
      {'name': 'Diamond Cyan', 'color': const Color(0xFF00E5FF)},
      {'name': 'Nether Crimson', 'color': const Color(0xFF9C27B0)},
    ];

    showDialog(
      context: context,
      barrierColor: Colors.black87,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setD) {
          final curTheme =
              _tabThemes[_tabController.index.clamp(0, _tabThemes.length - 1)];
          final themeColor = curTheme.primary;

          return Dialog(
            backgroundColor: Colors.transparent,
            insetPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 24,
            ),
            child: PixelatedCard(
              backgroundColor: curTheme.cardBg,
              borderColor: curTheme.border,
              borderWidth: 2.5,
              pixelStep: 4.0,
              padding: const EdgeInsets.all(16),
              margin: EdgeInsets.zero,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // 1. Header with Live Preview & Animated Icon
                    Row(
                      children: [
                        if (iconType != null)
                          Container(
                            width: 44,
                            height: 60,
                            margin: const EdgeInsets.only(right: 12),
                            decoration: BoxDecoration(
                              color: Colors.black45,
                              border: Border.all(color: themeColor, width: 2.0),
                              boxShadow: [
                                BoxShadow(
                                  color: themeColor.withValues(alpha: 0.40),
                                  blurRadius: 10,
                                ),
                              ],
                            ),
                            child: ClipPath(
                              clipper: _ChamferedCardClipper(),
                              child: RealisticShaderIcon(
                                type: iconType,
                                color: tmp,
                                size: double.infinity,
                              ),
                            ),
                          )
                        else
                          Container(
                            width: 36,
                            height: 36,
                            margin: const EdgeInsets.only(right: 12),
                            decoration: BoxDecoration(
                              color: tmp,
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(color: themeColor, width: 2.0),
                              boxShadow: [
                                BoxShadow(
                                  color: themeColor.withValues(alpha: 0.50),
                                  blurRadius: 10,
                                ),
                              ],
                            ),
                          ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const AnimatedMinecraftIcon(
                                    type: VoxelIconType.sparkles,
                                    size: 16,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    'COLOR CRAFTING',
                                    style: TextStyle(
                                      color: themeColor,
                                      fontSize: 10.5,
                                      fontWeight: FontWeight.w900,
                                      letterSpacing: 1.2,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 2),
                              Text(
                                title.toUpperCase(),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w900,
                                  fontSize: 15,
                                  letterSpacing: 0.8,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        // Live Hex Badge
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFF111417),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: const Color(0xFF262C33)),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 12,
                                height: 12,
                                decoration: BoxDecoration(
                                  color: tmp,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Colors.white70,
                                    width: 1,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                '#${tmp.toARGB32().toRadixString(16).substring(2).toUpperCase()}',
                                style: TextStyle(
                                  color: themeColor,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w900,
                                  fontFamily: 'monospace',
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),

                    // 1b. Professional Curated Palette tailored for this element
                    Row(
                      children: [
                        const Icon(
                          Icons.auto_awesome,
                          size: 13,
                          color: Color(0xFFF59E0B),
                        ),
                        const SizedBox(width: 5),
                        Text(
                          'CURATED ${title.toUpperCase()} PALETTE',
                          style: const TextStyle(
                            color: Color(0xFFF59E0B),
                            fontSize: 10,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.8,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 7,
                      runSpacing: 7,
                      children: curatedList.map((swatch) {
                        final swColor = swatch['color'] as Color;
                        final swName = swatch['name'] as String;
                        final isSel = tmp.toARGB32() == swColor.toARGB32();
                        return Tooltip(
                          message: swName,
                          child: GestureDetector(
                            onTap: () {
                              setD(() {
                                tmp = swColor;
                                hexCtrl.text = swColor
                                    .toARGB32()
                                    .toRadixString(16)
                                    .substring(2)
                                    .toUpperCase();
                              });
                              setState(() => onSet(swColor));
                            },
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 150),
                              width: 34,
                              height: 34,
                              decoration: BoxDecoration(
                                color: swColor,
                                borderRadius: BorderRadius.circular(4),
                                border: Border.all(
                                  color: isSel ? Colors.white : Colors.black87,
                                  width: isSel ? 2.5 : 1.2,
                                ),
                                boxShadow: [
                                  if (isSel)
                                    BoxShadow(
                                      color: swColor.withValues(alpha: 0.85),
                                      blurRadius: 8,
                                      spreadRadius: 1,
                                    )
                                  else
                                    const BoxShadow(
                                      color: Colors.black45,
                                      blurRadius: 2,
                                      offset: Offset(0, 1),
                                    ),
                                ],
                              ),
                              child: isSel
                                  ? const Center(
                                      child: Icon(
                                        Icons.check,
                                        size: 18,
                                        color: Colors.white,
                                      ),
                                    )
                                  : null,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 14),

                    // 2. 16 Minecraft Dye Palette Quick-Pick Swatches
                    const Text(
                      'MINECRAFT DYES (CLASSIC)',
                      style: TextStyle(
                        color: Colors.white54,
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.0,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 7,
                      runSpacing: 7,
                      children: minecraftDyes.map((dye) {
                        final dyeColor = dye['color'] as Color;
                        final isSel = tmp.toARGB32() == dyeColor.toARGB32();
                        return GestureDetector(
                          onTap: () {
                            setD(() {
                              tmp = dyeColor;
                              hexCtrl.text = dyeColor
                                  .toARGB32()
                                  .toRadixString(16)
                                  .substring(2)
                                  .toUpperCase();
                            });
                            setState(() => onSet(dyeColor));
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 150),
                            width: 34,
                            height: 34,
                            decoration: BoxDecoration(
                              color: dyeColor,
                              border: Border.all(
                                color: isSel ? Colors.white : Colors.black87,
                                width: isSel ? 2.5 : 1.5,
                              ),
                              boxShadow: [
                                if (isSel)
                                  BoxShadow(
                                    color: dyeColor.withValues(alpha: 0.80),
                                    blurRadius: 8,
                                    spreadRadius: 1,
                                  )
                                else
                                  const BoxShadow(
                                    color: Colors.black45,
                                    blurRadius: 2,
                                    offset: Offset(0, 1),
                                  ),
                              ],
                            ),
                            child: isSel
                                ? const Center(
                                    child: Icon(
                                      Icons.check,
                                      size: 18,
                                      color: Colors.white,
                                    ),
                                  )
                                : null,
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 14),

                    // 3. Smooth HSV Spectrum Palette
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFF14171A),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: const Color(0xFF262C33)),
                      ),
                      child: ColorPicker(
                        pickerColor: tmp,
                        enableAlpha: false,
                        displayThumbColor: true,
                        hexInputBar: false,
                        labelTypes: const [],
                        paletteType: PaletteType.hsvWithHue,
                        pickerAreaHeightPercent: 0.60,
                        pickerAreaBorderRadius: BorderRadius.circular(8),
                        onColorChanged: (c) {
                          setD(() {
                            tmp = c;
                            hexCtrl.text = c
                                .toARGB32()
                                .toRadixString(16)
                                .substring(2)
                                .toUpperCase();
                          });
                          setState(() => onSet(c));
                        },
                      ),
                    ),
                    const SizedBox(height: 12),

                    // 4. Hex Input Bar
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFF14171A),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: const Color(0xFF262C33)),
                          ),
                          child: const Text(
                            'HEX #',
                            style: TextStyle(
                              color: Colors.white54,
                              fontWeight: FontWeight.w900,
                              fontFamily: 'monospace',
                              fontSize: 11,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextField(
                            controller: hexCtrl,
                            maxLength: 6,
                            style: const TextStyle(
                              color: Colors.white,
                              fontFamily: 'monospace',
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                              letterSpacing: 2.0,
                            ),
                            decoration: InputDecoration(
                              counterText: '',
                              isDense: true,
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 10,
                              ),
                              filled: true,
                              fillColor: const Color(0xFF14171A),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(6),
                                borderSide: const BorderSide(
                                  color: Color(0xFF262C33),
                                  width: 1.5,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(6),
                                borderSide: BorderSide(
                                  color: themeColor,
                                  width: 2,
                                ),
                              ),
                            ),
                            onChanged: (v) {
                              if (v.length == 6) {
                                final parsed = int.tryParse('FF$v', radix: 16);
                                if (parsed != null) {
                                  final newC = Color(parsed);
                                  setD(() => tmp = newC);
                                  setState(() => onSet(newC));
                                }
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // 5. Stepped Minecraft Action Buttons
                    Row(
                      children: [
                        Expanded(
                          child: SizedBox(
                            height: 44,
                            child: OutlinedButton(
                              onPressed: () {
                                setState(() => onSet(current));
                                Navigator.pop(context);
                              },
                              style: OutlinedButton.styleFrom(
                                side: const BorderSide(
                                  color: Color(0xFF38404A),
                                  width: 1.5,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: const Text(
                                'CANCEL',
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 12,
                                  letterSpacing: 1.0,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: SizedBox(
                            height: 44,
                            child: ElevatedButton.icon(
                              onPressed: () {
                                setState(() => onSet(tmp));
                                Navigator.pop(context);
                              },
                              icon: const Icon(
                                Icons.check,
                                size: 18,
                                color: Colors.black,
                              ),
                              label: const Text(
                                'APPLY',
                                style: TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.w900,
                                  fontSize: 12,
                                  letterSpacing: 1.2,
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: themeColor,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    ).then((_) => hexCtrl.dispose());
  }

  // ── CUSTOM MINECRAFT SETTING ROW BUILDERS (Matching User Reference Image) ──

  /// Minecraft Setting Slider with pixelated styling and adaptive background theme
  Widget _buildMinecraftSlider({
    required VoxelIconType icon,
    required String title,
    required double value,
    required double min,
    required double max,
    required int divisions,
    required String minLabel,
    required String centerLabel,
    required String maxLabel,
    required Color activeColor,
    Color? thumbBorderColor,
    Color? thumbFaceColor,
    bool isLightBackground = false,
    required ValueChanged<double> onChanged,
  }) {
    // Both thumb face and border strictly match the tab's signature active color
    final fColor = thumbFaceColor ?? activeColor;
    final bColor = thumbBorderColor ?? activeColor;

    final titleColor = isLightBackground
        ? const Color(0xFF1E1006)
        : Colors.white;
    final badgeBg = activeColor.withValues(alpha: 0.18);
    final badgeBorder = activeColor.withValues(alpha: 0.45);
    final inactiveTrack = Colors.white.withValues(alpha: 0.12);
    final sideLabelColor = isLightBackground
        ? const Color(0xFF381F0E)
        : Colors.white54;
    final centerLabelColor = activeColor;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              AnimatedMinecraftIcon(
                type: icon,
                size: 24,
                colorOverride: activeColor,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    color: titleColor,
                    fontWeight: FontWeight.w900,
                    fontSize: 13.5,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 3,
                ),
                decoration: BoxDecoration(
                  color: badgeBg,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: badgeBorder, width: 1.2),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black45,
                      blurRadius: 2,
                      offset: Offset(0, 1),
                    ),
                  ],
                ),
                child: Text(
                  '${value.toStringAsFixed(1)}x',
                  style: TextStyle(
                    color: activeColor.computeLuminance() > 0.65
                        ? Colors.white
                        : activeColor,
                    fontWeight: FontWeight.w900,
                    fontSize: 11,
                    fontFamily: 'monospace',
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              trackHeight: 6,
              activeTrackColor: activeColor,
              inactiveTrackColor: inactiveTrack,
              thumbColor: fColor,
              overlayColor: activeColor.withValues(alpha: 0.18),
              thumbShape: MinecraftSliderThumbShape(
                baseColor: fColor,
                borderColor: bColor,
                thumbSize: 14.0,
              ),
            ),
            child: Slider(
              value: value,
              min: min,
              max: max,
              divisions: divisions,
              onChanged: (v) => setState(() => onChanged(v)),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  minLabel,
                  style: TextStyle(
                    color: sideLabelColor,
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (centerLabel.isNotEmpty)
                  Text(
                    centerLabel,
                    style: TextStyle(
                      color: centerLabelColor,
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                Text(
                  maxLabel,
                  style: TextStyle(
                    color: sideLabelColor,
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Minecraft Toggle Switch with animated icon, title, subtitle matching active tab color
  Widget _buildMinecraftToggle({
    required VoxelIconType icon,
    required String title,
    String? subtitle,
    required bool value,
    Color? activeColor,
    required ValueChanged<bool> onChanged,
  }) {
    final theme =
        _tabThemes[_tabController.index.clamp(0, _tabThemes.length - 1)];
    final actColor = activeColor ?? theme.primary;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          AnimatedMinecraftIcon(
            type: icon,
            size: 24,
            colorOverride: value ? actColor : null,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: 13,
                  ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      color: Colors.white54,
                      fontSize: 10.5,
                    ),
                  ),
                ],
              ],
            ),
          ),
          Switch(
            value: value,
            activeThumbColor: Colors.white,
            activeTrackColor: actColor,
            inactiveThumbColor: Colors.white38,
            inactiveTrackColor: Colors.black45,
            onChanged: (v) => setState(() => onChanged(v)),
          ),
        ],
      ),
    );
  }

  /// Minecraft Segmented Pill Selector with animated icon
  Widget _buildMinecraftSegmented({
    required VoxelIconType icon,
    required String title,
    required List<String> items,
    required String selected,
    required Color activeColor,
    required ValueChanged<String> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              AnimatedMinecraftIcon(
                type: icon,
                size: 24,
                colorOverride: activeColor,
              ),
              const SizedBox(width: 10),
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  fontSize: 13,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: items.map((it) {
              final isSel = it == selected;
              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 3),
                  child: GestureDetector(
                    onTap: () => setState(() => onChanged(it)),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        color: isSel
                            ? activeColor
                            : Colors.black.withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                          color: isSel
                              ? activeColor
                              : activeColor.withValues(alpha: 0.25),
                          width: 1.2,
                        ),
                        boxShadow: isSel
                            ? [
                                BoxShadow(
                                  color: activeColor.withValues(alpha: 0.35),
                                  blurRadius: 6,
                                ),
                              ]
                            : null,
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        it,
                        style: TextStyle(
                          color: isSel
                              ? (activeColor.computeLuminance() > 0.55
                                    ? Colors.black87
                                    : Colors.white)
                              : Colors.white70,
                          fontWeight: FontWeight.w800,
                          fontSize: 11,
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  /// Water Tint Color Swatches matching Screen 4 in reference
  /// Water Tint Color Swatches with 3D Voxel Minecraft Bevel Styling
  Widget _buildMinecraftColorSwatches({
    required VoxelIconType icon,
    required String title,
    required Color selectedColor,
    required ValueChanged<Color> onChanged,
    required VoidCallback onCustomTap,
  }) {
    final swatches = [
      {'color': const Color(0xFF00E5FF), 'name': 'Cyan'},
      {'color': const Color(0xFF29B6F6), 'name': 'Sky'},
      {'color': const Color(0xFF0288D1), 'name': 'Ocean'},
      {'color': const Color(0xFF7E57C2), 'name': 'Amethyst'},
      {'color': const Color(0xFFFF7043), 'name': 'Coral'},
      {'color': const Color(0xFFEC407A), 'name': 'Prism'},
    ];

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF0B1726),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFF162D4A), width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              AnimatedMinecraftIcon(
                type: icon,
                size: 24,
                colorOverride: selectedColor,
              ),
              const SizedBox(width: 10),
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  fontSize: 13,
                ),
              ),
              const Spacer(),
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: onCustomTap,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: selectedColor.withValues(alpha: 0.20),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: selectedColor, width: 1.5),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.colorize,
                        size: 12,
                        color: Colors.white70,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '#${selectedColor.toARGB32().toRadixString(16).substring(2).toUpperCase()}',
                        style: TextStyle(
                          color: selectedColor,
                          fontSize: 10,
                          fontWeight: FontWeight.w900,
                          fontFamily: 'monospace',
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              ...swatches.map((item) {
                final c = item['color'] as Color;
                final isSel =
                    (selectedColor.toARGB32() & 0x00FFFFFF) ==
                    (c.toARGB32() & 0x00FFFFFF);
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 3),
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () {
                        setState(() {
                          onChanged(c);
                        });
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 150),
                        height: 38,
                        decoration: BoxDecoration(
                          color: c,
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                            color: isSel
                                ? Colors.white
                                : const Color(0xFF060D17),
                            width: isSel ? 2.5 : 1.5,
                          ),
                          boxShadow: [
                            if (isSel)
                              BoxShadow(
                                color: c.withValues(alpha: 0.80),
                                blurRadius: 10,
                                spreadRadius: 1,
                              )
                            else
                              const BoxShadow(
                                color: Colors.black45,
                                blurRadius: 3,
                                offset: Offset(0, 2),
                              ),
                          ],
                        ),
                        child: isSel
                            ? const Center(
                                child: Icon(
                                  Icons.check,
                                  size: 18,
                                  color: Colors.white,
                                ),
                              )
                            : null,
                      ),
                    ),
                  ),
                );
              }),
            ],
          ),
        ],
      ),
    );
  }

  /// Minecraft Steve Avatar Tip Banner (matching bottom of user reference screens)
  Widget _buildSteveTipBanner(String tip) {
    final cleanTip = tip.startsWith('Tip:')
        ? tip.substring(4).trim()
        : (tip.startsWith('Tip') ? tip.substring(3).trim() : tip.trim());

    return Container(
      margin: const EdgeInsets.only(top: 8, bottom: 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Steve Upper Body (46w x 60h)
          const SizedBox(
            width: 46,
            height: 60,
            child: _SteveUpperBodyWidget(width: 46, height: 60),
          ),
          const SizedBox(width: 10),
          // Wooden Plank Sign with beveled border
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: const Color(0xFF261D1A), // Dark wood tone
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: const Color(0xFF4E342E), width: 2.0),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.55),
                    blurRadius: 6,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Yellow glowing lightbulb
                  const Padding(
                    padding: EdgeInsets.only(top: 1, right: 8),
                    child: AnimatedMinecraftIcon(
                      type: VoxelIconType.lightbulb,
                      size: 20,
                    ),
                  ),
                  // Rich Text: Pink "Tip: " + Cream Message
                  Expanded(
                    child: Text.rich(
                      TextSpan(
                        children: [
                          const TextSpan(
                            text: 'Tip: ',
                            style: TextStyle(
                              color: Color(
                                0xFFF06292,
                              ), // Bright pink matching screenshot
                              fontWeight: FontWeight.w900,
                              fontSize: 12,
                              letterSpacing: 0.3,
                            ),
                          ),
                          TextSpan(
                            text: cleanTip,
                            style: const TextStyle(
                              color: Color(0xFFFFECB3), // Warm cream body
                              fontSize: 11.5,
                              fontWeight: FontWeight.w600,
                              height: 1.35,
                            ),
                          ),
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
    );
  }

  // ── PROCEDURAL DETAILED MINECRAFT SCENERY PAINTERS (100% CODE RENDERED) ──
  /// Draws a high-detail procedural Minecraft atmosphere scene reacting dynamically to sliders in real time
  Widget _buildAtmospherePreviewBanner() {
    final isNight = _activeColorKey.contains('Night');
    final isMorning = _activeColorKey.contains('Morning');
    final isEvening = _activeColorKey.contains('Evening');

    Color activeSky;
    double currentFog;
    VoxelIconType badgeIcon;
    String statusText;

    if (isNight) {
      activeSky = nightColor;
      currentFog = nightFogDensity;
      badgeIcon = VoxelIconType.moon;
      statusText =
          'NIGHT • MOON ${moonSize.toStringAsFixed(1)}x • BRIGHTNESS ${nightVision.toStringAsFixed(1)}x • FOG ${nightFogDensity.toStringAsFixed(1)}x';
    } else if (isMorning) {
      activeSky = morningColor;
      currentFog = morningFogDensity;
      badgeIcon = VoxelIconType.sun;
      statusText =
          'DAWN • SUN ${sunSizeMorning.toStringAsFixed(1)}x • FOG ${morningFogDensity.toStringAsFixed(1)}x • RAYS ${morningRayIntensity.toStringAsFixed(1)}x';
    } else if (isEvening) {
      activeSky = eveningColor;
      currentFog = eveningFogDensity;
      badgeIcon = VoxelIconType.sun;
      statusText =
          'SUNSET • SUN ${sunSizeEvening.toStringAsFixed(1)}x • FOG ${eveningFogDensity.toStringAsFixed(1)}x • RAYS ${eveningRayIntensity.toStringAsFixed(1)}x';
    } else {
      activeSky = noonColor;
      currentFog = fogDensity;
      badgeIcon = VoxelIconType.sun;
      statusText =
          'NOON • SUN ${sunSize.toStringAsFixed(1)}x • FOG ${fogDensity.toStringAsFixed(1)}x • LIGHT ${lightIntensity.toStringAsFixed(1)}x';
    }

    final curTheme = _activeTabTheme;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      height: 125,
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: curTheme.primary.withValues(alpha: 0.65),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: curTheme.primary.withValues(alpha: 0.20),
            blurRadius: 14,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: Stack(
          children: [
            // 1. Pure Procedural Minecraft Scene (Drawn 100% in code via CustomPainter)
            Positioned.fill(
              child: RepaintBoundary(
                child: CustomPaint(
                  painter: _AtmosphereDetailedScenePainter(
                    timeOfDay: _activeColorKey,
                    activeSkyColor: activeSky,
                    sunOrMoonScale: isNight
                        ? moonSize
                        : (isMorning
                              ? sunSizeMorning
                              : (isEvening ? sunSizeEvening : sunSize)),
                    fogDensity: currentFog,
                    rayIntensity: isMorning
                        ? morningRayIntensity
                        : (isEvening
                              ? eveningRayIntensity
                              : (isNight ? moonRayIntensity : 1.0)),
                    nightVision: nightVision,
                    cloudType: cloudType,
                    cloudTopColor: cloudTopColor,
                    cloudBottomColor: cloudBottomColor,
                  ),
                ),
              ),
            ),

            // 2. Real-Time Procedural Engine Pill (Top Right)
            Positioned(
              right: 12,
              top: 10,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 7,
                  vertical: 2.5,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xCC080D14),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: curTheme.primary.withValues(alpha: 0.40),
                    width: 0.9,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 5,
                      height: 5,
                      decoration: BoxDecoration(
                        color: curTheme.primary,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: curTheme.primary.withValues(alpha: 0.8),
                            blurRadius: 4,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 4.5),
                    Text(
                      'REAL-TIME CODE ENGINE',
                      style: TextStyle(
                        color: curTheme.primary,
                        fontSize: 8.0,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.6,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // 3. Live Status Badge (Bottom Left)
            Positioned(
              left: 12,
              bottom: 8,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 3.5,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xCC080D14),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: curTheme.primary.withValues(alpha: 0.5),
                    width: 1.0,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    AnimatedMinecraftIcon(
                      type: badgeIcon,
                      size: 12,
                      colorOverride: curTheme.primary,
                    ),
                    const SizedBox(width: 5),
                    Text(
                      statusText,
                      style: TextStyle(
                        color: curTheme.primary,
                        fontSize: 9.5,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.6,
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

  /// Interactive Lighting Preview Banner reflecting Torch Glow, God Rays & High-Detail Scenery
  Widget _buildLightingPreviewBanner() {
    final tR = (torchLightColor.redInt * blockLightIntensity).round().clamp(
      0,
      255,
    );
    final tG = (torchLightColor.greenInt * blockLightIntensity).round().clamp(
      0,
      255,
    );
    final tB = (torchLightColor.blueInt * blockLightIntensity).round().clamp(
      0,
      255,
    );
    final effectiveTorch = Color.fromARGB(255, tR, tG, tB);

    Color activeRay = rayNoonColor;
    if (_activeColorKey.contains('Morning')) activeRay = rayMorningColor;
    if (_activeColorKey.contains('Evening')) activeRay = rayEveningColor;
    if (_activeColorKey.contains('Night')) activeRay = rayNightColor;

    final curTheme = _activeTabTheme;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      height: 125,
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: curTheme.primary.withValues(alpha: 0.65),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: curTheme.primary.withValues(alpha: 0.20),
            blurRadius: 14,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: Stack(
          children: [
            // 1. Procedural High-Detail Minecraft Torch & Cavern Scenery (100% Code via CustomPainter)
            Positioned.fill(
              child: RepaintBoundary(
                child: CustomPaint(
                  painter: _LightingDetailedScenePainter(
                    blockLightIntensity: blockLightIntensity,
                    lightIntensity: lightIntensity,
                    torchColor: effectiveTorch,
                    rayColor: activeRay,
                    fogColor: fogColor,
                    shadowQuality: shadowQuality,
                  ),
                ),
              ),
            ),
            // 2. Torch Icon overlay
            const Positioned(
              right: 56,
              bottom: 38,
              child: AnimatedMinecraftIcon(type: VoxelIconType.torch, size: 24),
            ),
            // 7. Status badge
            Positioned(
              left: 12,
              bottom: 8,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 3.5,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xCC080D14),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: curTheme.primary.withValues(alpha: 0.5),
                    width: 1.0,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    AnimatedMinecraftIcon(
                      type: VoxelIconType.lantern,
                      size: 12,
                      colorOverride: curTheme.primary,
                    ),
                    const SizedBox(width: 5),
                    Text(
                      'LIGHT ${lightIntensity.toStringAsFixed(1)}x • TORCH ${blockLightIntensity.toStringAsFixed(1)}x • SHADOWS: $shadowQuality',
                      style: TextStyle(
                        color: curTheme.primary,
                        fontSize: 9.5,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.6,
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

  /// Interactive Weather Preview Banner reflecting High-Detail Minecraft Storm Scenery
  Widget _buildWeatherPreviewBanner() {
    final curTheme = _activeTabTheme;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      height: 125,
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: curTheme.primary.withValues(alpha: 0.65),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: curTheme.primary.withValues(alpha: 0.20),
            blurRadius: 14,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: Stack(
          children: [
            // 1. Procedural High-Detail Minecraft Storm Scenery (100% Code via CustomPainter)
            Positioned.fill(
              child: RepaintBoundary(
                child: CustomPaint(
                  painter: _WeatherDetailedScenePainter(
                    rainFogColor: rainFogColor,
                    rainWaterColor: rainWaterColor,
                    metalness: globalMetalness,
                    pbrEnabled: enablePBR,
                  ),
                ),
              ),
            ),
            // 2. Badge
            Positioned(
              left: 12,
              bottom: 8,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 3.5,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xCC080D14),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: curTheme.primary.withValues(alpha: 0.5),
                    width: 1.0,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    AnimatedMinecraftIcon(
                      type: VoxelIconType.rainCloud,
                      size: 12,
                      colorOverride: curTheme.primary,
                    ),
                    const SizedBox(width: 5),
                    Text(
                      'PBR: ${enablePBR ? 'ON' : 'OFF'} • METAL ${(globalMetalness * 100).round()}% • TONE: $toneMapFilter',
                      style: TextStyle(
                        color: curTheme.primary,
                        fontSize: 9.5,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.6,
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

  /// Interactive Water Preview Banner matching Screen 4 in reference with Authentic Scenery
  Widget _buildWaterPreviewBanner() {
    final curTheme = _activeTabTheme;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      height: 125,
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: curTheme.primary.withValues(alpha: 0.65),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: curTheme.primary.withValues(alpha: 0.20),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: Stack(
          children: [
            // 1. Procedural High-Detail Minecraft Water Ocean Scenery (100% Code via CustomPainter)
            Positioned.fill(
              child: RepaintBoundary(
                child: CustomPaint(
                  painter: _WaterDetailedScenePainter(
                    waterColor: waterColor,
                    waterSpeed: windSpeed,
                    waterQuality: waterQuality,
                    underwaterCaustics: underwaterCaustics,
                  ),
                ),
              ),
            ),
            // 2. Status badge
            Positioned(
              left: 12,
              bottom: 8,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 3.5,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xCC080D14),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: curTheme.primary.withValues(alpha: 0.5),
                    width: 1.0,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    AnimatedMinecraftIcon(
                      type: VoxelIconType.waves,
                      size: 12,
                      colorOverride: curTheme.primary,
                    ),
                    const SizedBox(width: 5),
                    Text(
                      'WATER: $waterQuality • SPEED ${windSpeed.toStringAsFixed(1)}x • CAUSTICS: ${underwaterCaustics ? 'ON' : 'OFF'}',
                      style: TextStyle(
                        color: curTheme.primary,
                        fontSize: 9.5,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.6,
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

  // ── 4 TAB IMPLEMENTATIONS (ATMOSPHERE, LIGHTING, WATER, WEATHER) ──────────

  // Context-aware atmosphere sliders tailored to selected time of day
  List<Widget> _buildAtmosphereContextSliders(
    Color tabAccent,
    Color dividerColor,
  ) {
    if (_activeColorKey.contains('Morning')) {
      return [
        _buildMinecraftSlider(
          icon: VoxelIconType.sun,
          title: 'Dawn Sun Size',
          value: sunSizeMorning,
          min: 0.0,
          max: 2.0,
          divisions: 20,
          minLabel: 'Smaller',
          centerLabel: 'Default (1.0x)',
          maxLabel: 'Bigger',
          activeColor: tabAccent,
          onChanged: (v) => setState(() => sunSizeMorning = v),
        ),
        Container(
          height: 1.5,
          color: dividerColor,
          margin: const EdgeInsets.symmetric(vertical: 8),
        ),
        _buildMinecraftSlider(
          icon: VoxelIconType.cloud,
          title: 'Dawn Fog Density',
          value: morningFogDensity,
          min: 0.0,
          max: 2.0,
          divisions: 20,
          minLabel: 'Clear',
          centerLabel: 'Default (1.0x)',
          maxLabel: 'Thick',
          activeColor: tabAccent,
          onChanged: (v) => setState(() => morningFogDensity = v),
        ),
        Container(
          height: 1.5,
          color: dividerColor,
          margin: const EdgeInsets.symmetric(vertical: 8),
        ),
        _buildMinecraftSlider(
          icon: VoxelIconType.sun,
          title: 'Sunrise Ray Glow',
          value: morningRayIntensity,
          min: 0.0,
          max: 2.0,
          divisions: 20,
          minLabel: 'Subtle',
          centerLabel: 'Default (1.0x)',
          maxLabel: 'Intense',
          activeColor: tabAccent,
          onChanged: (v) => setState(() => morningRayIntensity = v),
        ),
        Container(
          height: 1.5,
          color: dividerColor,
          margin: const EdgeInsets.symmetric(vertical: 8),
        ),
        _buildMinecraftSegmented(
          icon: VoxelIconType.cloud,
          title: 'Clouds Style',
          items: const ['Realistic 3D', 'Volumetric', 'Flat 2D'],
          selected: cloudType,
          activeColor: tabAccent,
          onChanged: (v) => setState(() => cloudType = v),
        ),
      ];
    } else if (_activeColorKey.contains('Evening')) {
      return [
        _buildMinecraftSlider(
          icon: VoxelIconType.sun,
          title: 'Sunset Sun Size',
          value: sunSizeEvening,
          min: 0.0,
          max: 2.0,
          divisions: 20,
          minLabel: 'Smaller',
          centerLabel: 'Default (1.2x)',
          maxLabel: 'Bigger',
          activeColor: tabAccent,
          onChanged: (v) => setState(() => sunSizeEvening = v),
        ),
        Container(
          height: 1.5,
          color: dividerColor,
          margin: const EdgeInsets.symmetric(vertical: 8),
        ),
        _buildMinecraftSlider(
          icon: VoxelIconType.cloud,
          title: 'Sunset Fog Density',
          value: eveningFogDensity,
          min: 0.0,
          max: 2.0,
          divisions: 20,
          minLabel: 'Clear',
          centerLabel: 'Default (1.1x)',
          maxLabel: 'Thick',
          activeColor: tabAccent,
          onChanged: (v) => setState(() => eveningFogDensity = v),
        ),
        Container(
          height: 1.5,
          color: dividerColor,
          margin: const EdgeInsets.symmetric(vertical: 8),
        ),
        _buildMinecraftSlider(
          icon: VoxelIconType.torch,
          title: 'Twilight Rays Intensity',
          value: eveningRayIntensity,
          min: 0.0,
          max: 2.0,
          divisions: 20,
          minLabel: 'Subtle',
          centerLabel: 'Default (1.2x)',
          maxLabel: 'Dramatic',
          activeColor: tabAccent,
          onChanged: (v) => setState(() => eveningRayIntensity = v),
        ),
        Container(
          height: 1.5,
          color: dividerColor,
          margin: const EdgeInsets.symmetric(vertical: 8),
        ),
        _buildMinecraftSegmented(
          icon: VoxelIconType.cloud,
          title: 'Clouds Style',
          items: const ['Realistic 3D', 'Volumetric', 'Flat 2D'],
          selected: cloudType,
          activeColor: tabAccent,
          onChanged: (v) => setState(() => cloudType = v),
        ),
      ];
    } else if (_activeColorKey.contains('Night')) {
      return [
        _buildMinecraftSlider(
          icon: VoxelIconType.moon,
          title: 'Moon Size',
          value: moonSize,
          min: 0.0,
          max: 2.0,
          divisions: 20,
          minLabel: 'Smaller',
          centerLabel: 'Default (1.0x)',
          maxLabel: 'Bigger',
          activeColor: tabAccent,
          onChanged: (v) => setState(() => moonSize = v),
        ),
        Container(
          height: 1.5,
          color: dividerColor,
          margin: const EdgeInsets.symmetric(vertical: 8),
        ),
        _buildMinecraftSlider(
          icon: VoxelIconType.moon,
          title: 'Night Brightness',
          value: nightVision,
          min: 0.0,
          max: 2.0,
          divisions: 20,
          minLabel: 'Darker',
          centerLabel: 'Default (1.0x)',
          maxLabel: 'Brighter',
          activeColor: tabAccent,
          onChanged: (v) => setState(() => nightVision = v),
        ),
        Container(
          height: 1.5,
          color: dividerColor,
          margin: const EdgeInsets.symmetric(vertical: 8),
        ),
        _buildMinecraftSlider(
          icon: VoxelIconType.cloud,
          title: 'Night Fog & Stars',
          value: nightFogDensity,
          min: 0.0,
          max: 2.0,
          divisions: 20,
          minLabel: 'Clear',
          centerLabel: 'Default (1.0x)',
          maxLabel: 'Mystic',
          activeColor: tabAccent,
          onChanged: (v) => setState(() => nightFogDensity = v),
        ),
        Container(
          height: 1.5,
          color: dividerColor,
          margin: const EdgeInsets.symmetric(vertical: 8),
        ),
        _buildMinecraftSlider(
          icon: VoxelIconType.lantern,
          title: 'Moonlight God Rays',
          value: moonRayIntensity,
          min: 0.0,
          max: 2.0,
          divisions: 20,
          minLabel: 'Subtle',
          centerLabel: 'Default (1.0x)',
          maxLabel: 'Luminous',
          activeColor: tabAccent,
          onChanged: (v) => setState(() => moonRayIntensity = v),
        ),
        Container(
          height: 1.5,
          color: dividerColor,
          margin: const EdgeInsets.symmetric(vertical: 8),
        ),
        _buildMinecraftSegmented(
          icon: VoxelIconType.cloud,
          title: 'Clouds Style',
          items: const ['Realistic 3D', 'Volumetric', 'Flat 2D'],
          selected: cloudType,
          activeColor: tabAccent,
          onChanged: (v) => setState(() => cloudType = v),
        ),
      ];
    } else {
      // Noon (Day)
      return [
        _buildMinecraftSlider(
          icon: VoxelIconType.sun,
          title: 'Midday Sun Size',
          value: sunSize,
          min: 0.0,
          max: 2.0,
          divisions: 20,
          minLabel: 'Smaller',
          centerLabel: 'Default (1.0x)',
          maxLabel: 'Bigger',
          activeColor: tabAccent,
          onChanged: (v) => setState(() => sunSize = v),
        ),
        Container(
          height: 1.5,
          color: dividerColor,
          margin: const EdgeInsets.symmetric(vertical: 8),
        ),
        _buildMinecraftSlider(
          icon: VoxelIconType.cloud,
          title: 'Midday Fog Density',
          value: fogDensity,
          min: 0.0,
          max: 2.0,
          divisions: 20,
          minLabel: 'Clear',
          centerLabel: 'Default (1.0x)',
          maxLabel: 'Thick',
          activeColor: tabAccent,
          onChanged: (v) => setState(() => fogDensity = v),
        ),
        Container(
          height: 1.5,
          color: dividerColor,
          margin: const EdgeInsets.symmetric(vertical: 8),
        ),
        _buildMinecraftSlider(
          icon: VoxelIconType.sun,
          title: 'Sunlight Illuminance',
          value: lightIntensity,
          min: 0.0,
          max: 2.0,
          divisions: 20,
          minLabel: 'Dim',
          centerLabel: 'Default (1.0x)',
          maxLabel: 'Radiant',
          activeColor: tabAccent,
          onChanged: (v) => setState(() => lightIntensity = v),
        ),
        Container(
          height: 1.5,
          color: dividerColor,
          margin: const EdgeInsets.symmetric(vertical: 8),
        ),
        _buildMinecraftSegmented(
          icon: VoxelIconType.cloud,
          title: 'Clouds Style',
          items: const ['Realistic 3D', 'Volumetric', 'Flat 2D'],
          selected: cloudType,
          activeColor: tabAccent,
          onChanged: (v) => setState(() => cloudType = v),
        ),
      ];
    }
  }

  // TAB 1: ATMOSPHERE (Dynamic & reactive to Morning, Noon, Evening, Night)
  Widget _tabAtmosphere() {
    final curTheme = _activeTabTheme;
    final cardBg = curTheme.cardBg;
    final cardBorder = curTheme.border;
    final dividerColor = curTheme.border.withValues(alpha: 0.45);
    final tabAccent = curTheme.primary;

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 90),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 1. Top Card with Stepped Pixelated Corners
          PixelatedCard(
            backgroundColor: cardBg,
            borderColor: cardBorder,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    AnimatedMinecraftIcon(
                      type: VoxelIconType.sun,
                      size: 30,
                      colorOverride: tabAccent,
                    ),
                    const SizedBox(width: 10),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'TIME & ATMOSPHERE',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w900,
                              fontFamily: 'monospace',
                              letterSpacing: 1.0,
                            ),
                          ),
                          SizedBox(height: 2),
                          Text(
                            'Set the mood and sky for your world.',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 11.5,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                // Interactive Atmosphere Preview Banner reflecting Sky Tint, Sun Size, Night Brightness & Fog
                _buildAtmospherePreviewBanner(),
                // 4 Time of Day Cards: Morning, Noon, Evening, Night (with extra spacing between them)
                MinecraftColorGrid(
                  title: '',
                  gap: 14.0,
                  tiles: [
                    _colorRow(
                      'Morning',
                      'Sunrise sky tint',
                      morningColor,
                      (c) => morningColor = c,
                      iconType: ShaderIconType.morning,
                      labelColor: Colors.white70,
                      aspectRatio: 1.0,
                    ),
                    _colorRow(
                      'Noon',
                      'Midday sky tint',
                      noonColor,
                      (c) => noonColor = c,
                      iconType: ShaderIconType.noon,
                      labelColor: Colors.white70,
                      aspectRatio: 1.0,
                    ),
                    _colorRow(
                      'Evening',
                      'Sunset sky tint',
                      eveningColor,
                      (c) => eveningColor = c,
                      iconType: ShaderIconType.evening,
                      labelColor: Colors.white70,
                      aspectRatio: 1.0,
                    ),
                    _colorRow(
                      'Night',
                      'Midnight sky tint',
                      nightColor,
                      (c) => nightColor = c,
                      iconType: ShaderIconType.night,
                      labelColor: Colors.white70,
                      aspectRatio: 1.0,
                    ),
                  ],
                ),
              ],
            ),
          ),

          // 2. Bottom Card: Context-Aware Parameters per selected Time of Day
          PixelatedCard(
            backgroundColor: cardBg,
            borderColor: cardBorder,
            child: Column(
              children: _buildAtmosphereContextSliders(tabAccent, dividerColor),
            ),
          ),

          // Steve Tip Banner
          _buildSteveTipBanner(
            _activeColorKey.contains('Morning')
                ? 'Tip: Sunrise rays look magical when paired with subtle dawn fog!'
                : (_activeColorKey.contains('Evening')
                      ? 'Tip: Larger sunset sun size creates breathtaking cinematic twilights!'
                      : (_activeColorKey.contains('Night')
                            ? 'Tip: Adjust moon size and night brightness for luminous starry skies!'
                            : 'Tip: Balanced midday sun size gives sharp, realistic shadows!')),
          ),
        ],
      ),
    );
  }

  // TAB 2: LIGHTING (Vibrant Torch Amber & Dark Slate Theme)
  Widget _tabLighting() {
    final curTheme = _activeTabTheme;
    final tabAccent = curTheme.primary;
    final cardBg = curTheme.cardBg;
    final cardBorder = curTheme.border;
    final dividerColor = curTheme.border.withValues(alpha: 0.45);

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 90),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 1. Top Card: Less Red, Deep Warm Walnut
          PixelatedCard(
            backgroundColor: cardBg,
            borderColor: cardBorder,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    AnimatedMinecraftIcon(
                      type: VoxelIconType.lantern,
                      size: 28,
                      colorOverride: tabAccent,
                    ),
                    const SizedBox(width: 10),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'LIGHTING & SHADOWS',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 0.8,
                            ),
                          ),
                          Text(
                            'Make your world look stunning.',
                            style: TextStyle(
                              color: Colors.white54,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                // Interactive Lighting Preview Banner reflecting Torch Glow, God Rays & Shadows
                _buildLightingPreviewBanner(),
                // 2 Visual Scene Cards: Soft Fog, Torch Light (Square shape as requested)
                MinecraftColorGrid(
                  title: '',
                  gap: 16.0,
                  tiles: [
                    _colorRow(
                      'Soft Fog',
                      'Atmospheric mist',
                      fogColor,
                      (c) => fogColor = c,
                      iconType: ShaderIconType.fog,
                      aspectRatio: 1.0,
                    ),
                    _colorRow(
                      'Torch Light',
                      'Warm point lighting',
                      torchLightColor,
                      (c) => torchLightColor = c,
                      iconType: ShaderIconType.torch,
                      aspectRatio: 1.0,
                    ),
                  ],
                ),
              ],
            ),
          ),

          // 2. Bottom Card: Deep Warm Walnut Controls
          PixelatedCard(
            backgroundColor: cardBg,
            borderColor: cardBorder,
            child: Column(
              children: [
                // Light Intensity Slider
                _buildMinecraftSlider(
                  icon: VoxelIconType.lightbulb,
                  title: 'Light Intensity',
                  value: lightIntensity,
                  min: 0.0,
                  max: 2.0,
                  divisions: 20,
                  minLabel: 'Low',
                  centerLabel: 'Default (1.0x)',
                  maxLabel: 'High',
                  activeColor: tabAccent,
                  onChanged: (v) => lightIntensity = v,
                ),
                Container(
                  height: 1,
                  color: dividerColor,
                  margin: const EdgeInsets.symmetric(vertical: 8),
                ),

                // Block Light Intensity Slider
                _buildMinecraftSlider(
                  icon: VoxelIconType.goldBlock,
                  title: 'Block Light Intensity',
                  value: blockLightIntensity,
                  min: 0.0,
                  max: 2.0,
                  divisions: 20,
                  minLabel: 'Low',
                  centerLabel: 'Default (1.0x)',
                  maxLabel: 'High',
                  activeColor: tabAccent,
                  onChanged: (v) => blockLightIntensity = v,
                ),
                Container(
                  height: 1,
                  color: dividerColor,
                  margin: const EdgeInsets.symmetric(vertical: 8),
                ),

                // Shadow Quality Segmented Selector
                _buildMinecraftSegmented(
                  icon: VoxelIconType.mountain,
                  title: 'Shadow Quality',
                  items: ['Off', 'Low', 'High', 'Ultra'],
                  selected: shadowQuality,
                  activeColor: tabAccent,
                  onChanged: (v) => shadowQuality = v,
                ),
                const SizedBox(height: 4),

                // Point Light Shadows Toggle
                _buildMinecraftToggle(
                  icon: VoxelIconType.torch,
                  title: 'Point Light Shadows',
                  subtitle: 'Enable shadows for light sources',
                  value: enablePointLightShadows,
                  activeColor: tabAccent,
                  onChanged: (v) => enablePointLightShadows = v,
                ),
                Container(
                  height: 1,
                  color: dividerColor,
                  margin: const EdgeInsets.symmetric(vertical: 8),
                ),

                // 2. VOLUMETRIC FOG (Cinematic / Balanced / Low End)
                _buildMinecraftSegmented(
                  icon: VoxelIconType.lantern,
                  title: 'Volumetric Fog Profile',
                  items: const ['Cinematic', 'Balanced', 'Low End'],
                  selected: volumetricFogProfile,
                  activeColor: tabAccent,
                  onChanged: (v) => setState(() => volumetricFogProfile = v),
                ),
              ],
            ),
          ),

          // 3. Bottom Card: 4 God Rays Color Pickers (Morning, Noon, Evening, Night) - Square shape
          PixelatedCard(
            backgroundColor: cardBg,
            borderColor: cardBorder,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    AnimatedMinecraftIcon(
                      type: VoxelIconType.sun,
                      size: 28,
                      colorOverride: tabAccent,
                    ),
                    const SizedBox(width: 10),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'GOD RAYS TINT (VOLUMETRIC LIGHT)',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 0.8,
                            ),
                          ),
                          Text(
                            'Sunlight & moonlight volumetric rays by time of day',
                            style: TextStyle(
                              color: Colors.white54,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                // 4 Time of Day Color Pickers for God Rays: Morning, Noon, Evening, Night (Square shape)
                MinecraftColorGrid(
                  title: '',
                  tiles: [
                    _colorRow(
                      'Morning',
                      'Morning sunlight rays',
                      rayMorningColor,
                      (c) => rayMorningColor = c,
                      iconType: ShaderIconType.rayMorning,
                      dialogTitle: 'Morning God Rays',
                      aspectRatio: 1.0,
                    ),
                    _colorRow(
                      'Noon',
                      'Noon bright rays',
                      rayNoonColor,
                      (c) => rayNoonColor = c,
                      iconType: ShaderIconType.rayNoon,
                      dialogTitle: 'Noon God Rays',
                      aspectRatio: 1.0,
                    ),
                    _colorRow(
                      'Evening',
                      'Sunset golden rays',
                      rayEveningColor,
                      (c) => rayEveningColor = c,
                      iconType: ShaderIconType.rayEvening,
                      dialogTitle: 'Evening God Rays',
                      aspectRatio: 1.0,
                    ),
                    _colorRow(
                      'Night',
                      'Midnight moon rays',
                      rayNightColor,
                      (c) => rayNightColor = c,
                      iconType: ShaderIconType.rayNight,
                      dialogTitle: 'Night God Rays',
                      aspectRatio: 1.0,
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Steve Tip Banner
          _buildSteveTipBanner('Shadows add depth and make your world alive!'),
        ],
      ),
    );
  }

  // TAB 3: WATER & REFLECTIONS (Deep Oceanic Cyan & Caustics)
  Widget _tabWorld() {
    final curTheme = _activeTabTheme;
    final tabAccent = curTheme.primary;
    final cardBg = curTheme.cardBg;
    final cardBorder = curTheme.border;
    final dividerColor = curTheme.border.withValues(alpha: 0.45);

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 90),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 1. Top Card: Deep Oceanic Slate
          PixelatedCard(
            backgroundColor: cardBg,
            borderColor: cardBorder,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    AnimatedMinecraftIcon(
                      type: VoxelIconType.waves,
                      size: 28,
                      colorOverride: tabAccent,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'WATER & REFLECTIONS',
                            style: TextStyle(
                              color: tabAccent,
                              fontSize: 15,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 0.8,
                            ),
                          ),
                          Text(
                            'Customize water appearance and behavior.',
                            style: TextStyle(
                              color: Color(0xFF80DEEA),
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                // Large Water Preview Banner matching reference Screen 4
                _buildWaterPreviewBanner(),

                // Water Tint Swatches
                _buildMinecraftColorSwatches(
                  icon: VoxelIconType.waterDroplet,
                  title: 'Water Tint',
                  selectedColor: waterColor,
                  onChanged: (c) {
                    setState(() {
                      waterColor = c;
                    });
                  },
                  onCustomTap: () => _pickColor('Water Tint', waterColor, (c) {
                    setState(() {
                      waterColor = c;
                    });
                  }, iconType: ShaderIconType.water),
                ),
              ],
            ),
          ),

          // 2. Bottom Card: Deep Oceanic Slate Controls & Sliders
          PixelatedCard(
            backgroundColor: cardBg,
            borderColor: cardBorder,
            child: Column(
              children: [
                // Wind & Wave Speed Slider
                _buildMinecraftSlider(
                  icon: VoxelIconType.waves,
                  title: 'Wind & Wave Speed',
                  value: windSpeed,
                  min: 0.0,
                  max: 2.0,
                  divisions: 20,
                  minLabel: 'Calm',
                  centerLabel: 'Default (1.0x)',
                  maxLabel: 'Stormy',
                  activeColor: tabAccent,
                  onChanged: (v) => windSpeed = v,
                ),
                Container(
                  height: 1,
                  color: dividerColor,
                  margin: const EdgeInsets.symmetric(vertical: 8),
                ),

                // Water Quality Segmented
                _buildMinecraftSegmented(
                  icon: VoxelIconType.diamond,
                  title: 'Water Quality',
                  items: ['Low', 'Medium', 'High', 'Ultra'],
                  selected: waterQuality,
                  activeColor: tabAccent,
                  onChanged: (v) => waterQuality = v,
                ),
                const SizedBox(height: 4),

                // Underwater Caustics Toggle
                _buildMinecraftToggle(
                  icon: VoxelIconType.caustics,
                  title: 'Underwater Caustics',
                  subtitle: 'Animated light patterns on river and ocean floors',
                  value: underwaterCaustics,
                  activeColor: tabAccent,
                  onChanged: (v) => underwaterCaustics = v,
                ),
              ],
            ),
          ),

          // Steve Tip Banner for Water & Ocean reflections
          _buildSteveTipBanner(
            'Tip: Adjust caustics and wave speed for realistic currents!',
          ),
        ],
      ),
    );
  }

  // TAB 4: WEATHER & POST-FX (Storm Slate & Nimbus Blue)
  Widget _tabWeather() {
    final curTheme = _activeTabTheme;
    final tabAccent = curTheme.primary;
    final weatherCardBg = curTheme.cardBg;
    final weatherCardBorder = curTheme.border;
    final weatherDivider = curTheme.border.withValues(alpha: 0.45);

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 90),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 1. Top Card: Sleek Dark Slate Gray with Proper Minimal Border
          PixelatedCard(
            backgroundColor: weatherCardBg,
            borderColor: weatherCardBorder,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    AnimatedMinecraftIcon(
                      type: VoxelIconType.rainCloud,
                      size: 28,
                      colorOverride: tabAccent,
                    ),
                    const SizedBox(width: 10),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'WEATHER & POST-FX',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 0.8,
                            ),
                          ),
                          Text(
                            'Tune storms, bloom, and cinematic color grading.',
                            style: TextStyle(
                              color: Colors.white54,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                // Interactive Weather Preview Banner reflecting Storm, Reflections & PBR Metalness
                _buildWeatherPreviewBanner(),
                // 2 Visual Cards: Rain Fog & Rain Water
                MinecraftColorGrid(
                  title: '',
                  tiles: [
                    _colorRow(
                      'Rain Fog',
                      'Atmospheric haze during rain',
                      rainFogColor,
                      (c) => rainFogColor = c,
                      iconType: ShaderIconType.rainFog,
                    ),
                    _colorRow(
                      'Rain Water',
                      'Water color during rain',
                      rainWaterColor,
                      (c) => rainWaterColor = c,
                      iconType: ShaderIconType.rainWater,
                    ),
                  ],
                ),
              ],
            ),
          ),

          // 2. World Reflections, PBR & Foliage Card (Same unified dark slate background & border)
          PixelatedCard(
            backgroundColor: weatherCardBg,
            borderColor: weatherCardBorder,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    AnimatedMinecraftIcon(
                      type: VoxelIconType.cubeMirror,
                      size: 28,
                      colorOverride: tabAccent,
                    ),
                    const SizedBox(width: 10),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'SURFACE & MATERIALS',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 0.8,
                            ),
                          ),
                          Text(
                            'Real-time reflections, bump maps, and waving flora.',
                            style: TextStyle(
                              color: Colors.white54,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                // World Reflections Toggle
                _buildMinecraftToggle(
                  icon: VoxelIconType.cubeMirror,
                  title: 'World Reflections',
                  subtitle:
                      'Real-time reflections of sky and surrounding blocks',
                  value: worldReflectionsEnabled,
                  activeColor: tabAccent,
                  onChanged: (v) => worldReflectionsEnabled = v,
                ),
                Container(
                  height: 1,
                  color: weatherDivider,
                  margin: const EdgeInsets.symmetric(vertical: 8),
                ),

                // PBR Bump Mapping Toggle
                _buildMinecraftToggle(
                  icon: VoxelIconType.pbrLayers,
                  title: 'PBR Bump Mapping',
                  subtitle: 'Normal and roughness relief depth on all blocks',
                  value: enablePBR,
                  activeColor: tabAccent,
                  onChanged: (v) => enablePBR = v,
                ),
                Container(
                  height: 1,
                  color: weatherDivider,
                  margin: const EdgeInsets.symmetric(vertical: 8),
                ),

                // Global Metalness Slider
                _buildMinecraftSlider(
                  icon: VoxelIconType.pearl,
                  title: 'Global Metalness',
                  value: globalMetalness,
                  min: 0.0,
                  max: 1.0,
                  divisions: 10,
                  minLabel: 'Matte',
                  centerLabel: '',
                  maxLabel: 'Shiny',
                  activeColor: tabAccent,
                  onChanged: (v) => globalMetalness = v,
                ),
                Container(
                  height: 1,
                  color: weatherDivider,
                  margin: const EdgeInsets.symmetric(vertical: 8),
                ),

                // Waving Foliage Toggle
                _buildMinecraftToggle(
                  icon: VoxelIconType.grassBlock,
                  title: 'Waving Foliage',
                  subtitle:
                      'Wind-swaying animation for leaves, grass, crops & vines',
                  value: wavingFoliage,
                  activeColor: tabAccent,
                  onChanged: (v) => wavingFoliage = v,
                ),

                if (wavingFoliage) ...[
                  Container(
                    height: 1,
                    color: weatherDivider,
                    margin: const EdgeInsets.symmetric(vertical: 8),
                  ),
                  _buildMinecraftSlider(
                    icon: VoxelIconType.waves,
                    title: 'Foliage Wave Intensity',
                    value: foliageWaveSpeed,
                    min: 0.2,
                    max: 2.0,
                    divisions: 18,
                    minLabel: 'Gentle',
                    centerLabel: 'Default (1.0x)',
                    maxLabel: 'Breeze',
                    activeColor: tabAccent,
                    onChanged: (v) => foliageWaveSpeed = v,
                  ),
                ],
              ],
            ),
          ),

          // 3. Post-FX & Biome Tone Card (Same unified dark slate background & border)
          PixelatedCard(
            backgroundColor: weatherCardBg,
            borderColor: weatherCardBorder,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    AnimatedMinecraftIcon(
                      type: VoxelIconType.film,
                      size: 28,
                      colorOverride: tabAccent,
                    ),
                    const SizedBox(width: 10),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'POST-FX & TONE',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 0.8,
                            ),
                          ),
                          Text(
                            'Cinematic color grading and biome temperature.',
                            style: TextStyle(
                              color: Colors.white54,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                // Tone Mapping Segmented
                _buildMinecraftSegmented(
                  icon: VoxelIconType.film,
                  title: 'Tone Mapping Filter',
                  items: const ['ACES', 'Reinhard', 'Warm', 'Cool'],
                  selected: toneMapFilter.split(' ').first,
                  activeColor: tabAccent,
                  onChanged: (v) => toneMapFilter = v,
                ),
                Container(
                  height: 1,
                  color: weatherDivider,
                  margin: const EdgeInsets.symmetric(vertical: 8),
                ),

                // Biome-wise Tone (Dynamic / Vibrant / Savanna / Frost / Moody)
                _buildMinecraftSegmented(
                  icon: VoxelIconType.palette,
                  title: 'Biome-wise Tone',
                  items: const [
                    'Dynamic',
                    'Vibrant',
                    'Savanna',
                    'Frost',
                    'Moody',
                  ],
                  selected: biomeTone,
                  activeColor: tabAccent,
                  onChanged: (v) => setState(() => biomeTone = v),
                ),
              ],
            ),
          ),

          // Steve Tip Banner
          _buildSteveTipBanner(
            'Tip: Select ACES tone mapping with Dynamic biome tone for cinematic color depth!',
          ),
        ],
      ),
    );
  }

  Widget _colorRow(
    String label,
    String tip,
    Color color,
    Function(Color) onSet, {
    required ShaderIconType iconType,
    String? dialogTitle,
    Color? labelColor,
    bool showHexBadge = false,
    double? aspectRatio,
  }) {
    final effectiveTitle = dialogTitle ?? label;
    final bool isSelected = _activeColorKey == effectiveTitle;
    final curTheme = _activeTabTheme;
    return MinecraftColorTile(
      label: label,
      type: iconType,
      color: color,
      isSelected: isSelected,
      selectedBorderColor: curTheme.primary,
      labelColor: labelColor,
      showHexBadge: showHexBadge,
      aspectRatio: aspectRatio ?? 0.62,
      onTap: () {
        setState(() => _activeColorKey = effectiveTitle);
      },
      onColorPick: () {
        setState(() => _activeColorKey = effectiveTitle);
        _pickColor(effectiveTitle, color, onSet, iconType: iconType);
      },
    );
  }

  Future<bool> _confirmDiscardEdits() async {
    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF0E1722),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: const BorderSide(color: Color(0xFF1E293B)),
        ),
        title: const Row(
          children: [
            Icon(
              Icons.warning_amber_rounded,
              color: Color(0xFFE5A04A),
              size: 22,
            ),
            SizedBox(width: 8),
            Text(
              'Discard Edits?',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ],
        ),
        content: const Text(
          'You have unsaved shader parameter adjustments. Discarding will lose your changes.',
          style: TextStyle(color: Colors.white70, fontSize: 13),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text(
              'Keep Editing',
              style: TextStyle(color: Colors.white60),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFEF4444),
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text(
              'Discard',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  void _showActivationGuide() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF0E1722),
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        side: BorderSide(color: Color(0xFF1E293B)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Row(
              children: [
                AnimatedMinecraftIcon(type: VoxelIconType.grassBlock, size: 28),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'ACTIVATE IN MINECRAFT',
                    style: TextStyle(
                      color: Colors.white,
                      fontFamily: 'PixelifySans',
                      fontWeight: FontWeight.w900,
                      fontSize: 16,
                      letterSpacing: 1.0,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            const Text(
              'Follow these 3 quick steps in Minecraft Bedrock (1.21+) to see your custom deferred PBR shaders:',
              style: TextStyle(color: Colors.white70, fontSize: 13),
            ),
            const SizedBox(height: 16),
            _guideStep(
              stepNumber: '1',
              title: 'Open or Import Pack',
              description:
                  'Tap "Open with Minecraft" or export .mcpack. Minecraft will launch and show "Import Started... Successfully imported pack".',
              icon: Icons.file_download_done_rounded,
            ),
            const SizedBox(height: 10),
            _guideStep(
              stepNumber: '2',
              title: 'Enable Creator Experiments in World',
              description:
                  'Open your World Settings -> Scroll down to Experiments -> Toggle ON "Render Dragon Features for Creators".',
              icon: Icons.science_outlined,
            ),
            const SizedBox(height: 10),
            _guideStep(
              stepNumber: '3',
              title: 'Turn On Deferred Lighting',
              description:
                  'In Minecraft Settings -> Video -> Graphics Mode -> Choose "Deferred Technical Preview" to activate your custom shaders!',
              icon: Icons.wb_sunny_outlined,
            ),
            const SizedBox(height: 18),
            SizedBox(
              width: double.infinity,
              height: 44,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF22C55E),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: () => Navigator.pop(ctx),
                child: const Text(
                  "GOT IT, LET'S GO!",
                  style: TextStyle(fontWeight: FontWeight.w900),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _guideStep({
    required String stepNumber,
    required String title,
    required String description,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF141F2D),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFF1E293B)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: const Color(0xFF22C55E).withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: const Color(0xFF22C55E), width: 1.2),
            ),
            alignment: Alignment.center,
            child: Text(
              stepNumber,
              style: const TextStyle(
                color: Color(0xFF22C55E),
                fontWeight: FontWeight.w900,
                fontSize: 14,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(icon, size: 16, color: const Color(0xFF38BDF8)),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 11.5,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── BUILD APPBAR & SCAFFOLD (SMOOTH DYNAMIC THEME PER TAB) ───────────────
  @override
  Widget build(BuildContext context) {
    final curTheme = _activeTabTheme;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        final shouldPop = await _confirmDiscardEdits();
        if (shouldPop && context.mounted) {
          Navigator.pop(context);
        }
      },
      child: Scaffold(
        backgroundColor: curTheme.bg,
        appBar: AppBar(
          backgroundColor: curTheme.surface,
          elevation: 0,
          toolbarHeight: 52,
          titleSpacing: 8,
          leadingWidth: 46,
          // Themed back button
          leading: Padding(
            padding: const EdgeInsets.only(left: 8),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              width: 36,
              height: 36,
              margin: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                color: curTheme.backBg,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: curTheme.backBorder),
              ),
              child: IconButton(
                icon: const Icon(
                  Icons.arrow_back_ios_new_rounded,
                  color: Colors.white,
                  size: 16,
                ),
                padding: EdgeInsets.zero,
                onPressed: () async {
                  final shouldPop = await _confirmDiscardEdits();
                  if (shouldPop && context.mounted) {
                    Navigator.pop(context);
                  }
                },
              ),
            ),
          ),
          centerTitle: false,
          // Pack Shader Name with edit action + Pack Icon button with generous standard spacing
          title: Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: _showRenameDialog,
                  behavior: HitTestBehavior.opaque,
                  child: Container(
                    height: 36,
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    decoration: BoxDecoration(
                      color: curTheme.cardBg,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: curTheme.border, width: 1.2),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.inventory_2_outlined,
                          color: curTheme.primary,
                          size: 15,
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            shaderNameCtrl.text.isEmpty
                                ? 'Piglix Shader'
                                : shaderNameCtrl.text,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 13,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.2,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Icon(
                          Icons.edit_rounded,
                          color: curTheme.primary.withValues(alpha: 0.7),
                          size: 12,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              // Generous standard spacing between Shader Name and Pack Icon
              const SizedBox(width: 12),
              GestureDetector(
                onTap: _pickEditorLogo,
                behavior: HitTestBehavior.opaque,
                child: Container(
                  height: 36,
                  padding: const EdgeInsets.symmetric(horizontal: 9),
                  decoration: BoxDecoration(
                    color: curTheme.cardBg,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color:
                          (_activeLogoBytes != null ||
                              widget.uploadedLogoBytes != null)
                          ? curTheme.primary
                          : curTheme.border,
                      width: 1.2,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 22,
                        height: 22,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(
                            color:
                                (_activeLogoBytes != null ||
                                    widget.uploadedLogoBytes != null)
                                ? curTheme.primary
                                : curTheme.border,
                            width: 0.8,
                          ),
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: _activeLogoBytes != null
                            ? Image.memory(_activeLogoBytes!, fit: BoxFit.cover)
                            : (widget.uploadedLogoBytes != null
                                  ? Image.memory(
                                      widget.uploadedLogoBytes!,
                                      fit: BoxFit.cover,
                                    )
                                  : const Icon(
                                      Icons.add_photo_alternate_outlined,
                                      color: Color(0xFF94A3B8),
                                      size: 13,
                                    )),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        (_activeLogoBytes != null ||
                                widget.uploadedLogoBytes != null)
                            ? 'Icon ✓'
                            : 'Pack Icon',
                        style: TextStyle(
                          color:
                              (_activeLogoBytes != null ||
                                  widget.uploadedLogoBytes != null)
                              ? curTheme.primary
                              : const Color(0xFF94A3B8),
                          fontSize: 11.0,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 4),
            ],
          ),
          actions: [
            IconButton(
              tooltip: 'How to use in Minecraft',
              icon: const Icon(
                Icons.help_outline_rounded,
                color: Colors.white70,
                size: 22,
              ),
              onPressed: _showActivationGuide,
            ),
            const SizedBox(width: 4),
          ],
          // Exactly 4 Tabs with AI Scene Art & Pixelated Button Frames (compact & visible border)
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(62),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              height: 62,
              padding: const EdgeInsets.only(
                left: 8,
                right: 8,
                top: 4,
                bottom: 9,
              ),
              decoration: BoxDecoration(
                color: curTheme.surface,
                border: Border(bottom: BorderSide(color: curTheme.border)),
              ),
              child: Row(
                children: List.generate(_tabThemes.length, (idx) {
                  final tab = _tabThemes[idx];
                  final isSel = _tabController.index == idx;
                  final activeColor = (isSel && idx == 0)
                      ? curTheme.primary
                      : tab.primary;
                  const unselBorder = Color(
                    0xFF68707E,
                  ); // Clearly visible crisp border

                  return Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4.5),
                      child: GestureDetector(
                        onTap: () =>
                            setState(() => _tabController.animateTo(idx)),
                        child: CustomPaint(
                          painter: _PixelatedCardPainter(
                            fillColor: const Color(0xFF16202A),
                            borderColor: isSel ? activeColor : unselBorder,
                            borderWidth: isSel ? 2.0 : 1.4,
                            step: 2.5,
                            hasShadow: false,
                          ),
                          foregroundPainter: _PixelatedBorderPainter(
                            borderColor: isSel ? activeColor : unselBorder,
                            borderWidth: isSel ? 2.0 : 1.4,
                            step: 2.5,
                          ),
                          child: ClipPath(
                            clipper: const _PixelatedClipper(2.5),
                            child: Stack(
                              fit: StackFit.expand,
                              children: [
                                // 1. Clean AI Minecraft Scene Art fitted properly
                                Image.memory(
                                  tab.artBytes,
                                  fit: BoxFit.cover,
                                  gaplessPlayback: true,
                                ),

                                // 2. Subtle Dark Bottom Gradient Vignette
                                Positioned(
                                  left: 0,
                                  right: 0,
                                  bottom: 0,
                                  child: Container(
                                    height: 16,
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [
                                          Colors.transparent,
                                          Colors.black.withValues(alpha: 0.70),
                                          Colors.black.withValues(alpha: 0.92),
                                        ],
                                        begin: Alignment.topCenter,
                                        end: Alignment.bottomCenter,
                                      ),
                                    ),
                                    alignment: Alignment.center,
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 2,
                                    ),
                                    child: FittedBox(
                                      fit: BoxFit.scaleDown,
                                      child: Text(
                                        tab.label,
                                        style: TextStyle(
                                          color: isSel
                                              ? const Color(0xFFFFF3D0)
                                              : const Color(0xFFCAD4DF),
                                          fontFamily: 'PixelifySans',
                                          fontSize: 8.0,
                                          fontWeight: isSel
                                              ? FontWeight.w900
                                              : FontWeight.w700,
                                          letterSpacing: 0.5,
                                          shadows: const [
                                            Shadow(
                                              color: Colors.black,
                                              blurRadius: 2,
                                              offset: Offset(0, 1),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ),
          ),
        ),
        body: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          color: curTheme.bg,
          child: TabBarView(
            controller: _tabController,
            children: [
              _tabAtmosphere(),
              _tabLighting(),
              _tabWorld(),
              _tabWeather(),
            ],
          ),
        ),
        bottomNavigationBar: _buildBottomBar(curTheme),
      ),
    );
  }

  Widget _buildBottomBar(_BuilderTabTheme curTheme) {
    final isLastTab = _tabController.index == _tabThemes.length - 1;
    final isFirstTab = _tabController.index == 0;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      decoration: BoxDecoration(
        color: curTheme.surface,
        border: Border(top: BorderSide(color: curTheme.border, width: 1.2)),
      ),
      padding: EdgeInsets.fromLTRB(
        20,
        14,
        20,
        MediaQuery.of(context).padding.bottom + 12,
      ),
      child: _isGenerated
          ? Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                        height: 52,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          gradient: LinearGradient(
                            colors: curTheme.nextGradient,
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          border: Border.all(
                            color: curTheme.nextBorder,
                            width: 1.5,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: curTheme.nextShadow,
                              blurRadius: 14,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: _openWithMinecraft,
                            borderRadius: BorderRadius.circular(12),
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.play_arrow_rounded,
                                  size: 22,
                                  color: Colors.white,
                                ),
                                SizedBox(width: 8),
                                Text(
                                  'OPEN WITH MINECRAFT',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: 1.2,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    SizedBox(
                      height: 52,
                      width: 52,
                      child: ElevatedButton(
                        onPressed: _downloadPack,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: curTheme.cardBg,
                          foregroundColor: curTheme.primary,
                          padding: EdgeInsets.zero,
                          side: BorderSide(color: curTheme.border),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Icon(
                          Icons.download_rounded,
                          size: 22,
                          color: curTheme.primary,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                GestureDetector(
                  onTap: () => setState(() {
                    _isGenerated = false;
                    _generatedPackBytes = null;
                  }),
                  child: Text(
                    '✎ Edit & Regenerate',
                    style: TextStyle(
                      color: curTheme.primary,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            )
          : Row(
              children: [
                if (!isFirstTab) ...[
                  SizedBox(
                    height: 50,
                    child: OutlinedButton.icon(
                      onPressed: () => setState(
                        () =>
                            _tabController.animateTo(_tabController.index - 1),
                      ),
                      icon: const Icon(
                        Icons.arrow_back_rounded,
                        size: 18,
                        color: Colors.white70,
                      ),
                      label: const Text(
                        'Back',
                        style: TextStyle(
                          color: Colors.white70,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        backgroundColor: curTheme.backBg,
                        side: BorderSide(color: curTheme.backBorder),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                ],
                Expanded(
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                    height: 50,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      gradient: LinearGradient(
                        colors: curTheme.nextGradient,
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      border: Border.all(
                        color: curTheme.nextBorder,
                        width: 1.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.40),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: isLastTab
                            ? _generatePack
                            : () => setState(
                                () => _tabController.animateTo(
                                  _tabController.index + 1,
                                ),
                              ),
                        borderRadius: BorderRadius.circular(12),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              isLastTab
                                  ? Icons.auto_awesome_rounded
                                  : Icons.arrow_forward_rounded,
                              color: Colors.white,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              isLastTab ? 'GENERATE SHADER' : 'NEXT TAB',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 1.2,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  // ── PACK COMPILATION & GENERATION ────────────────────────────────────────
  Future<void> _generatePack() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) =>
          _CompileProgressDialog(onCompile: (p, s) => _doCompile(p, s)),
    );
  }

  String _cleanJson(String raw) {
    var s = raw.replaceAll(RegExp(r'/\*[\s\S]*?\*/'), '');
    s = s.replaceAll(RegExp(r'//.*'), '');
    s = s.replaceAll(RegExp(r',\s*([}\]])'), r'$1');
    return s;
  }

  Future<void> _doCompile(
    ValueNotifier<double> progressN,
    ValueNotifier<String> statusN,
  ) async {
    try {
      await Future.delayed(const Duration(milliseconds: 150));
      progressN.value = 0.15;
      statusN.value = 'Loading Vibrant Visuals configuration & PBR assets...';

      Archive sourceArchive;
      if (widget.uploadedShaderBytes != null &&
          widget.uploadedShaderBytes!.isNotEmpty) {
        sourceArchive = await compute(
          _decodeZipBytesWorker,
          widget.uploadedShaderBytes!,
        );
      } else {
        final byteData = await rootBundle.load('assets/base_shader.zip');
        sourceArchive = await compute(
          _decodeZipBytesWorker,
          byteData.buffer.asUint8List(),
        );
      }

      // Detect if archive has a single top-level folder prefix (e.g. PackFolder/manifest.json)
      String prefix = '';
      final nonDirFiles = sourceArchive.where((f) => f.isFile).toList();
      if (nonDirFiles.isNotEmpty) {
        final first = nonDirFiles.first.name.replaceAll('\\', '/');
        final slashIdx = first.indexOf('/');
        if (slashIdx != -1) {
          final candidate = first.substring(0, slashIdx + 1);
          const standardDirs = [
            'atmospherics/',
            'biomes/',
            'fogs/',
            'lighting/',
            'local_lighting/',
            'point_lights/',
            'water/',
            'color_grading/',
            'textures/',
            'subpacks/',
            'pbr/',
            'shadows/',
            'particles/',
            'materials/',
          ];
          if (!standardDirs.any((d) => candidate.startsWith(d))) {
            if (nonDirFiles.every(
              (f) => f.name.replaceAll('\\', '/').startsWith(candidate),
            )) {
              prefix = candidate;
            }
          }
        }
      }

      final fileMap = <String, ArchiveFile>{};
      for (final file in sourceArchive) {
        if (file.isFile) {
          var name = file.name.replaceAll('\\', '/');
          if (prefix.isNotEmpty && name.startsWith(prefix)) {
            name = name.substring(prefix.length);
          }
          // Pure Vibrant Visuals (Deferred JSON / PBR): strip out any legacy .material.bin binaries
          if (name.endsWith('.material.bin') || name.startsWith('renderer/')) {
            continue;
          }
          fileMap[name] = ArchiveFile(name, file.size, file.content);
        }
      }

      await Future.delayed(const Duration(milliseconds: 200));
      progressN.value = 0.35;
      statusN.value = 'Configuring Atmosphere, Water & Lighting JSONs...';

      // 1. Torch & Point Lighting (Both 1.21.60+ local_lighting and 1.21.0-1.21.50 point_lights)
      final tR = (torchLightColor.redInt * blockLightIntensity).round().clamp(
        0,
        255,
      );
      final tG = (torchLightColor.greenInt * blockLightIntensity).round().clamp(
        0,
        255,
      );
      final tB = (torchLightColor.blueInt * blockLightIntensity).round().clamp(
        0,
        255,
      );
      final torchHex =
          '#${Color.fromARGB(255, tR, tG, tB).toARGB32().toRadixString(16).padLeft(8, '0').substring(2)}';

      final pointColors = {
        'minecraft:torch': torchHex,
        'minecraft:lantern': torchHex,
        'minecraft:copper_bulb': torchHex,
        'minecraft:lit_furnace': torchHex,
        'minecraft:lit_redstone_lamp': torchHex,
        'minecraft:glowstone': torchHex,
        'minecraft:light_block': torchHex,
        'minecraft:campfire': torchHex,
        'minecraft:soul_torch': '#29c2f1',
        'minecraft:soul_lantern': '#29c2f1',
        'minecraft:shroomlight': torchHex,
      };

      final localLightingJson = jsonEncode({
        'format_version': '1.21.60',
        'minecraft:local_light_settings': {
          'description': {'identifier': 'pog:local_lighting'},
          'colors': pointColors,
        },
      });
      final llBytes = utf8.encode(localLightingJson);
      fileMap['local_lighting/local_lighting.json'] = ArchiveFile(
        'local_lighting/local_lighting.json',
        llBytes.length,
        llBytes,
      );

      final pointLightsJson = jsonEncode({
        'format_version': '1.21.40',
        'minecraft:point_light_settings': {'colors': pointColors},
      });
      final plBytes = utf8.encode(pointLightsJson);
      fileMap['point_lights/global.json'] = ArchiveFile(
        'point_lights/global.json',
        plBytes.length,
        plBytes,
      );

      // 2. Water Waves, Caustics & Transparency across all water/*.json files
      final waterTransparency = waterQuality == 'Ultra'
          ? 0.85
          : (waterQuality == 'High'
                ? 0.70
                : (waterQuality == 'Medium' ? 0.55 : 0.40));
      final waterSpeed = (windSpeed * 2.38).clamp(0.2, 8.0);
      final waterFreq = (windSpeed * 1.33).clamp(0.2, 4.0);
      final waterOctaves = waterQuality == 'Ultra'
          ? 24
          : (waterQuality == 'High' ? 18 : (waterQuality == 'Medium' ? 12 : 8));

      for (final key in fileMap.keys.toList()) {
        if (key.startsWith('water/') && key.endsWith('.json')) {
          try {
            final raw = _cleanJson(
              utf8.decode(fileMap[key]!.content as List<int>),
            );
            final wData = jsonDecode(raw) as Map<String, dynamic>;
            final wSettings =
                wData['minecraft:water_settings'] as Map<String, dynamic>?;
            if (wSettings != null) {
              if (wSettings['waves'] == null) {
                wSettings['waves'] = <String, dynamic>{};
              }
              final waves = wSettings['waves'] as Map<String, dynamic>;
              waves['enabled'] = true;
              waves['speed'] = waterSpeed;
              waves['frequency'] = waterFreq;
              waves['octaves'] = waterOctaves;

              if (wSettings['caustics'] == null) {
                wSettings['caustics'] = <String, dynamic>{};
              }
              final caustics = wSettings['caustics'] as Map<String, dynamic>;
              caustics['enabled'] = underwaterCaustics;
              caustics['texture'] = 'textures/causticsLow/caustics.png';

              if (wSettings['particle_concentrations'] != null) {
                final p =
                    wSettings['particle_concentrations']
                        as Map<String, dynamic>;
                p['chlorophyll'] = ((1.0 - waterTransparency) * 0.05).clamp(
                  0.0005,
                  0.1,
                );
              }

              final wBytes = utf8.encode(jsonEncode(wData));
              fileMap[key] = ArchiveFile(key, wBytes.length, wBytes);
            }
          } catch (_) {}
        }
      }

      // 3. Biome Water Surface Color, Transparency & Sky Color across all biomes
      final waterHex =
          '#${waterColor.toARGB32().toRadixString(16).padLeft(8, '0').substring(2)}';
      final skyHex =
          '#${noonColor.toARGB32().toRadixString(16).padLeft(8, '0').substring(2)}';
      for (final key in fileMap.keys.toList()) {
        if (key.startsWith('biomes/') && key.endsWith('.client_biome.json')) {
          try {
            final raw = _cleanJson(
              utf8.decode(fileMap[key]!.content as List<int>),
            );
            final bData = jsonDecode(raw) as Map<String, dynamic>;
            final bSettings = bData['minecraft:client_biome'] ?? bData;
            if (bSettings != null) {
              bSettings['water_surface_color'] = [
                waterColor.redInt,
                waterColor.greenInt,
                waterColor.blueInt,
              ];
              bSettings['water_surface_transparency'] = waterTransparency;
              if (bSettings['components'] != null) {
                final comps = bSettings['components'] as Map<String, dynamic>;
                if (comps['minecraft:water_appearance'] != null) {
                  comps['minecraft:water_appearance']['surface_color'] =
                      waterHex;
                  comps['minecraft:water_appearance']['surface_transparency'] =
                      waterTransparency;
                }
                if (comps['minecraft:sky_color'] != null) {
                  comps['minecraft:sky_color']['sky_color'] = skyHex;
                }
              }
              final bBytes = utf8.encode(jsonEncode(bData));
              fileMap[key] = ArchiveFile(key, bBytes.length, bBytes);
            }
          } catch (_) {}
        }
      }

      // 4. Fog Density, Soft Fog Color & Weather Fog across all fog definitions
      final fogHex =
          '#${fogColor.toARGB32().toRadixString(16).padLeft(8, '0').substring(2)}';
      final rainFogHex =
          '#${rainFogColor.toARGB32().toRadixString(16).padLeft(8, '0').substring(2)}';
      final rainWaterHex =
          '#${rainWaterColor.toARGB32().toRadixString(16).padLeft(8, '0').substring(2)}';
      final baseVolumetric = volumetricFogProfile == 'Cinematic'
          ? 0.065
          : (volumetricFogProfile == 'Balanced' ? 0.035 : 0.012);

      for (final key in fileMap.keys.toList()) {
        if (key.startsWith('fogs/') && key.endsWith('.json')) {
          try {
            final raw = _cleanJson(
              utf8.decode(fileMap[key]!.content as List<int>),
            );
            final fData = jsonDecode(raw) as Map<String, dynamic>;
            final fSettings =
                fData['minecraft:fog_settings'] as Map<String, dynamic>?;
            if (fSettings != null) {
              if (fSettings['distance'] != null) {
                final dist = fSettings['distance'] as Map<String, dynamic>;
                if (dist['air'] != null) {
                  dist['air']['fog_color'] = fogHex;
                  dist['air']['fog_start'] = (0.92 - (fogDensity * 0.40)).clamp(
                    0.05,
                    0.95,
                  );
                  dist['air']['fog_end'] = (1.00 - (fogDensity * 0.20)).clamp(
                    0.30,
                    1.00,
                  );
                }
                if (dist['weather'] != null) {
                  dist['weather']['fog_color'] = rainFogHex;
                }
                if (dist['water'] != null) {
                  dist['water']['fog_color'] = rainWaterHex;
                }
              }
              if (fSettings['volumetric'] != null) {
                final vol = fSettings['volumetric'] as Map<String, dynamic>;
                if (vol['density'] != null && vol['density']['air'] != null) {
                  vol['density']['air']['max_density'] =
                      (baseVolumetric * fogDensity).clamp(0.002, 0.25);
                }
                if (vol['media_coefficients'] != null) {
                  final mc = vol['media_coefficients'] as Map<String, dynamic>;
                  if (mc['cloud'] != null) {
                    if (cloudType == 'Realistic 3D') {
                      mc['cloud']['scattering'] = [0.02, 0.08, 0.04];
                      mc['cloud']['absorption'] = [1.2, 1.2, 1.2];
                    } else if (cloudType == 'Volumetric') {
                      mc['cloud']['scattering'] = [0.01, 0.06, 0.03];
                      mc['cloud']['absorption'] = [1.0, 1.0, 1.0];
                    } else {
                      mc['cloud']['scattering'] = [0.0005, 0.0005, 0.0005];
                      mc['cloud']['absorption'] = [0.2, 0.2, 0.2];
                    }
                  }
                }
              }
              final fBytes = utf8.encode(jsonEncode(fData));
              fileMap[key] = ArchiveFile(key, fBytes.length, fBytes);
            }
          } catch (_) {}
        }
      }

      // 5. Color Grading (Operator, Contrast, Saturation, Auto-Exposure Gain, Biome Tone)
      final op = toneMapFilter.toLowerCase().contains('reinhard')
          ? 'reinhard'
          : (toneMapFilter.toLowerCase().contains('warm')
                ? 'hable'
                : (toneMapFilter.toLowerCase().contains('cool')
                      ? 'aces'
                      : 'aces'));
      final targetTemp = biomeTone == 'Savanna'
          ? 5500.0
          : (biomeTone == 'Frost'
                ? 7800.0
                : (biomeTone == 'Vibrant'
                      ? 6200.0
                      : (biomeTone == 'Moody' ? 6000.0 : 6500.0)));
      final satMult = biomeTone == 'Vibrant'
          ? 1.25
          : (biomeTone == 'Moody' ? 0.75 : 1.0);
      final effSat = (globalSaturation * satMult).clamp(0.1, 2.5);
      final effContrast = contrast.clamp(0.5, 2.0);
      final effGain = (1.05 * autoExposure).clamp(0.4, 2.5);

      for (final cgKey in [
        'color_grading/color_grading.json',
        'color_grading/pale_color_grading.json',
      ]) {
        if (fileMap.containsKey(cgKey)) {
          try {
            final raw = _cleanJson(
              utf8.decode(fileMap[cgKey]!.content as List<int>),
            );
            final cgData = jsonDecode(raw) as Map<String, dynamic>;
            final cgSettings =
                cgData['minecraft:color_grading_settings']
                    as Map<String, dynamic>?;
            if (cgSettings != null) {
              cgSettings['description'] = {'identifier': 'pog:color_grading'};
              cgSettings['tone_mapping'] = {'operator': op};
              cgSettings['temperature'] = {
                'enabled': true,
                'type': 'white_balance',
                'temperature': targetTemp,
              };
              if (cgSettings['color_grading'] != null) {
                final cg = cgSettings['color_grading'] as Map<String, dynamic>;
                for (final block in ['midtones', 'highlights', 'shadows']) {
                  if (cg[block] != null) {
                    final b = cg[block] as Map<String, dynamic>;
                    b['contrast'] = [effContrast, effContrast, effContrast];
                    b['saturation'] = [effSat, effSat, effSat];
                    b['gain'] = [effGain, effGain, effGain];
                  }
                }
              }
              final cgBytes = utf8.encode(jsonEncode(cgData));
              fileMap[cgKey] = ArchiveFile(cgKey, cgBytes.length, cgBytes);
            }
          } catch (_) {}
        }
      }

      await Future.delayed(const Duration(milliseconds: 200));
      progressN.value = 0.60;
      statusN.value = 'Configuring Directional Lighting & God Rays...';

      // 6. Directional Sun & Moon Illuminance, God Rays Colors & Orbital Offset (lighting/*.json)
      final sunIllumScale = (181.0 * lightIntensity * bloomIntensity).clamp(
        10.0,
        350.0,
      );
      final moonIllumScale = (2.1 * nightVision * moonRayIntensity).clamp(
        0.1,
        15.0,
      );

      for (final key in fileMap.keys.toList()) {
        if (key.startsWith('lighting/') && key.endsWith('.json')) {
          try {
            final raw = _cleanJson(
              utf8.decode(fileMap[key]!.content as List<int>),
            );
            final lData = jsonDecode(raw) as Map<String, dynamic>;
            final lSettings =
                lData['minecraft:lighting_settings'] as Map<String, dynamic>?;
            if (lSettings != null && lSettings['directional_lights'] != null) {
              final dl =
                  lSettings['directional_lights'] as Map<String, dynamic>;
              if (dl['orbital'] == null) dl['orbital'] = <String, dynamic>{};
              final orbital = dl['orbital'] as Map<String, dynamic>;

              orbital['sun'] = {
                'illuminance': {
                  '0.000000': sunIllumScale,
                  '0.160000': sunIllumScale * 0.78,
                  '0.215000': sunIllumScale * 0.58 * eveningRayIntensity,
                  '0.240000': sunIllumScale * 0.17 * eveningRayIntensity,
                  '0.300000': 8,
                  '0.350000': 0,
                  '0.680000': 0,
                  '0.740000': sunIllumScale * 0.1 * morningRayIntensity,
                  '0.750000': sunIllumScale * 0.17 * morningRayIntensity,
                  '0.770000': sunIllumScale * 0.67 * morningRayIntensity,
                  '0.827000': sunIllumScale * 1.18,
                },
                'color': {
                  '0.000000': [
                    rayNoonColor.redInt,
                    rayNoonColor.greenInt,
                    rayNoonColor.blueInt,
                  ],
                  '0.160000': [
                    rayNoonColor.redInt,
                    rayNoonColor.greenInt,
                    rayNoonColor.blueInt,
                  ],
                  '0.215000': [
                    rayEveningColor.redInt,
                    rayEveningColor.greenInt,
                    rayEveningColor.blueInt,
                  ],
                  '0.230000': [
                    rayEveningColor.redInt,
                    rayEveningColor.greenInt,
                    rayEveningColor.blueInt,
                  ],
                  '0.300000': [40, 15, 5],
                  '0.670000': [0, 0, 0],
                  '0.680000': [0, 0, 0],
                  '0.690000': [0, 0, 0],
                  '0.740000': [
                    rayMorningColor.redInt,
                    rayMorningColor.greenInt,
                    rayMorningColor.blueInt,
                  ],
                  '0.750000': [
                    rayMorningColor.redInt,
                    rayMorningColor.greenInt,
                    rayMorningColor.blueInt,
                  ],
                  '0.770000': [
                    rayMorningColor.redInt,
                    rayMorningColor.greenInt,
                    rayMorningColor.blueInt,
                  ],
                  '0.790000': [
                    rayMorningColor.redInt,
                    rayMorningColor.greenInt,
                    rayMorningColor.blueInt,
                  ],
                  '0.800000': [
                    rayNoonColor.redInt,
                    rayNoonColor.greenInt,
                    rayNoonColor.blueInt,
                  ],
                },
              };

              orbital['moon'] = {
                'illuminance': {
                  '0.000000': moonIllumScale,
                  '0.730000': moonIllumScale,
                  '0.740000': 0.0,
                  '1.000000': moonIllumScale * 0.5,
                },
                'color': {
                  '0.000000': [
                    rayNightColor.redInt,
                    rayNightColor.greenInt,
                    rayNightColor.blueInt,
                  ],
                  '0.300000': [
                    rayNightColor.redInt,
                    rayNightColor.greenInt,
                    rayNightColor.blueInt,
                  ],
                  '0.500000': [
                    rayNightColor.redInt,
                    rayNightColor.greenInt,
                    rayNightColor.blueInt,
                  ],
                },
              };

              if (orbital['orbital_offset_degrees'] == null) {
                orbital['orbital_offset_degrees'] = {
                  '0.000000': 55.0,
                  '0.215000': 30.0,
                  '0.500000': 55.0,
                  '0.827000': 30.0,
                };
              }

              final lBytes = utf8.encode(jsonEncode(lData));
              fileMap[key] = ArchiveFile(key, lBytes.length, lBytes);
            }
          } catch (_) {}
        }
      }

      // 7. Atmospherics: Volumetric God Rays, Glare, Rayleigh & Sky Colors
      final rayMultiplier = volumetricRays.contains('Heavy')
          ? 1.5
          : (volumetricRays.contains('Balanced')
                ? 1.0
                : (volumetricRays.contains('Subtle') ? 0.6 : 0.2));
      final mieMorning = (4.0 * morningRayIntensity * rayMultiplier).clamp(
        0.2,
        16.0,
      );
      final mieNoon = (4.0 * lightIntensity * rayMultiplier).clamp(0.2, 16.0);
      final mieEvening = (4.0 * eveningRayIntensity * rayMultiplier).clamp(
        0.2,
        16.0,
      );
      final mieMoon = (1.5 * moonRayIntensity * rayMultiplier * nightVision)
          .clamp(0.05, 10.0);

      for (final key in fileMap.keys.toList()) {
        if (key.startsWith('atmospherics/') && key.endsWith('.json')) {
          try {
            final raw = _cleanJson(
              utf8.decode(fileMap[key]!.content as List<int>),
            );
            final aData = jsonDecode(raw) as Map<String, dynamic>;
            final aSettings =
                aData['minecraft:atmosphere_settings'] as Map<String, dynamic>?;
            if (aSettings != null) {
              aSettings['sky_zenith_color'] = {
                '0.000000': [
                  noonColor.redInt,
                  noonColor.greenInt,
                  noonColor.blueInt,
                ],
                '0.160000': [
                  noonColor.redInt,
                  noonColor.greenInt,
                  noonColor.blueInt,
                ],
                '0.215000': [
                  eveningColor.redInt,
                  eveningColor.greenInt,
                  eveningColor.blueInt,
                ],
                '0.225000': [
                  eveningColor.redInt,
                  eveningColor.greenInt,
                  eveningColor.blueInt,
                ],
                '0.300000': [
                  nightColor.redInt,
                  nightColor.greenInt,
                  nightColor.blueInt,
                ],
                '0.500000': [
                  nightColor.redInt,
                  nightColor.greenInt,
                  nightColor.blueInt,
                ],
                '0.694000': [
                  nightColor.redInt,
                  nightColor.greenInt,
                  nightColor.blueInt,
                ],
                '0.740000': [
                  morningColor.redInt,
                  morningColor.greenInt,
                  morningColor.blueInt,
                ],
                '0.770000': [
                  morningColor.redInt,
                  morningColor.greenInt,
                  morningColor.blueInt,
                ],
                '0.827000': [
                  noonColor.redInt,
                  noonColor.greenInt,
                  noonColor.blueInt,
                ],
              };

              aSettings['sky_horizon_color'] = {
                '0.000000': [
                  (noonColor.redInt * 0.85 + 38).round().clamp(0, 255),
                  (noonColor.greenInt * 0.85 + 38).round().clamp(0, 255),
                  (noonColor.blueInt * 0.85 + 38).round().clamp(0, 255),
                ],
                '0.160000': [
                  (noonColor.redInt * 0.85 + 38).round().clamp(0, 255),
                  (noonColor.greenInt * 0.85 + 38).round().clamp(0, 255),
                  (noonColor.blueInt * 0.85 + 38).round().clamp(0, 255),
                ],
                '0.215000': [
                  eveningColor.redInt,
                  eveningColor.greenInt,
                  eveningColor.blueInt,
                ],
                '0.225000': [
                  eveningColor.redInt,
                  eveningColor.greenInt,
                  eveningColor.blueInt,
                ],
                '0.300000': [
                  nightColor.redInt,
                  nightColor.greenInt,
                  (nightColor.blueInt * 0.8).round().clamp(0, 255),
                ],
                '0.500000': [
                  nightColor.redInt,
                  nightColor.greenInt,
                  (nightColor.blueInt * 0.8).round().clamp(0, 255),
                ],
                '0.694000': [
                  nightColor.redInt,
                  nightColor.greenInt,
                  (nightColor.blueInt * 0.8).round().clamp(0, 255),
                ],
                '0.740000': [
                  morningColor.redInt,
                  morningColor.greenInt,
                  morningColor.blueInt,
                ],
                '0.770000': [
                  morningColor.redInt,
                  morningColor.greenInt,
                  morningColor.blueInt,
                ],
                '0.827000': [
                  (noonColor.redInt * 0.85 + 38).round().clamp(0, 255),
                  (noonColor.greenInt * 0.85 + 38).round().clamp(0, 255),
                  (noonColor.blueInt * 0.85 + 38).round().clamp(0, 255),
                ],
              };

              aSettings['sun_glare_shape'] = {
                '0.000000': (5.0 * sunSize).clamp(0.5, 20.0),
                '0.215000': (0.07 * sunSizeEvening).clamp(0.01, 2.0),
                '0.300000': (0.17 * sunSizeEvening).clamp(0.02, 3.0),
                '0.500000': (5.0 * sunSize).clamp(0.5, 20.0),
                '0.640000': (3.0 * sunSize).clamp(0.3, 12.0),
                '0.740000': (0.07 * sunSizeMorning).clamp(0.01, 2.0),
                '0.790000': (0.07 * sunSizeMorning).clamp(0.01, 2.0),
                '0.800000': (4.15 * sunSize).clamp(0.4, 18.0),
              };

              aSettings['moon_glare_shape'] = {
                '0.000000': 0.0,
                '0.250000': (0.15 * moonSize).clamp(0.01, 2.0),
                '0.300000': (1.8 * moonSize).clamp(0.1, 10.0),
                '0.500000': (2.4 * moonSize).clamp(0.2, 12.0),
                '0.690000': (1.8 * moonSize).clamp(0.1, 10.0),
                '0.730000': 0.0,
              };

              aSettings['rayleigh_strength'] = {
                '0.000000': (2.2 * fogDensity).clamp(0.4, 6.0),
                '0.215000': (1.1 * eveningFogDensity).clamp(0.2, 4.0),
                '0.300000': (0.45 * nightFogDensity).clamp(0.1, 2.0),
                '0.694200': (0.45 * nightFogDensity).clamp(0.1, 2.0),
                '0.740000': (0.8 * morningFogDensity).clamp(0.1, 3.0),
                '0.770000': (0.8 * morningFogDensity).clamp(0.1, 3.0),
                '0.800000': (2.86 * fogDensity).clamp(0.5, 8.0),
              };

              aSettings['sun_mie_strength'] = {
                '0.000000': mieNoon,
                '0.215000': mieEvening * 0.75,
                '0.235000': mieEvening * 0.25,
                '0.295000': mieEvening * 1.25,
                '0.300000': mieEvening * 0.25,
                '0.400000': 0.0,
                '0.500000': 0.0,
                '0.740000': mieMorning * 0.2,
                '0.780000': mieMorning * 0.2,
                '0.790000': mieMorning * 0.2,
                '0.800000': mieMorning * 0.5,
                '1.000000': mieMorning * 0.5,
              };

              aSettings['moon_mie_strength'] = {
                '0.000000': 0.0,
                '0.250000': mieMoon * 0.4,
                '0.300000': mieMoon,
                '0.350000': mieMoon,
                '0.500000': 0.0,
                '0.730000': 0.0,
                '0.800000': 0.0,
                '1.000000': 0.0,
              };

              final aBytes = utf8.encode(jsonEncode(aData));
              fileMap[key] = ArchiveFile(key, aBytes.length, aBytes);
            }
          } catch (_) {}
        }
      }

      // 8. Shadows Settings (format_version: 1.21.80)
      final texel = shadowQuality == 'Ultra'
          ? 2048
          : (shadowQuality == 'High'
                ? 1024
                : (shadowQuality == 'Low' ? 512 : 256));
      Map<String, dynamic> shadowSettings = {
        'format_version': '1.21.80',
        'minecraft:shadow_settings': {
          'shadow_style': shadowQuality == 'Off'
              ? 'hard_shadows'
              : 'soft_shadows',
          'texel_size': texel,
          'point_light_shadows': enablePointLightShadows,
        },
      };
      final shBytes = utf8.encode(jsonEncode(shadowSettings));
      fileMap['shadows/global.json'] = ArchiveFile(
        'shadows/global.json',
        shBytes.length,
        shBytes,
      );

      // 9. PBR Fallback Settings (minecraft:pog_fallback_settings)
      final metalInt = (globalMetalness * 255).round().clamp(0, 255);
      final roughInt = worldReflectionsEnabled ? 120 : 255;
      final bumpInt = enablePBR ? 24 : 0;
      Map<String, dynamic> pbrSettings = {
        'format_version': '1.21.40',
        'minecraft:pog_fallback_settings': {
          'description': {'identifier': 'pog:base_pog'},
          'blocks': {
            'global_metalness_emissive_roughness_subsurface': [
              metalInt,
              0,
              roughInt,
              bumpInt,
            ],
          },
          'actors': {
            'global_metalness_emissive_roughness_subsurface': [
              metalInt,
              0,
              roughInt,
              32,
            ],
          },
          'particles': {
            'global_metalness_emissive_roughness_subsurface': [
              metalInt,
              0,
              roughInt,
              0,
            ],
          },
          'items': {
            'global_metalness_emissive_roughness_subsurface': [
              metalInt,
              0,
              roughInt,
              0,
            ],
          },
        },
      };
      final pbrBytes = utf8.encode(jsonEncode(pbrSettings));
      fileMap['pbr/global.json'] = ArchiveFile(
        'pbr/global.json',
        pbrBytes.length,
        pbrBytes,
      );

      // 10. Waving Foliage in particles/leaves/*.particle.json
      for (final key in fileMap.keys.toList()) {
        if (key.startsWith('particles/leaves/') &&
            key.endsWith('.particle.json')) {
          try {
            final raw = _cleanJson(
              utf8.decode(fileMap[key]!.content as List<int>),
            );
            final pData = jsonDecode(raw) as Map<String, dynamic>;
            final pe = pData['particle_effect'] as Map<String, dynamic>?;
            if (pe != null && pe['components'] != null) {
              final comps = pe['components'] as Map<String, dynamic>;
              if (!wavingFoliage) {
                if (comps['minecraft:particle_emitter_rate_steady'] != null) {
                  comps['minecraft:particle_emitter_rate_steady']['spawn_rate'] =
                      0.0;
                }
              } else {
                if (comps['minecraft:particle_emitter_rate_steady'] != null) {
                  comps['minecraft:particle_emitter_rate_steady']['spawn_rate'] =
                      (2.0 * foliageWaveSpeed).clamp(0.5, 6.0);
                }
                if (comps['minecraft:particle_motion_dynamic'] != null) {
                  final motion =
                      comps['minecraft:particle_motion_dynamic']
                          as Map<String, dynamic>;
                  motion['linear_speed'] = (0.35 * foliageWaveSpeed).clamp(
                    0.05,
                    1.5,
                  );
                }
              }
              final pBytes = utf8.encode(jsonEncode(pData));
              fileMap[key] = ArchiveFile(key, pBytes.length, pBytes);
            }
          } catch (_) {}
        }
      }

      // 11. Pack Icon & Title Sanitization
      final iconBytes =
          _activeLogoBytes ?? widget.uploadedLogoBytes ?? kPiglixLogoBytes;
      fileMap['pack_icon.png'] = ArchiveFile(
        'pack_icon.png',
        iconBytes.length,
        iconBytes,
      );
      fileMap.remove('textures/ui/title.png');

      // Ensure caustics texture resolves regardless of naming
      if (fileMap.containsKey('textures/causticsLow/caustics.png') &&
          !fileMap.containsKey('textures/caustic/caustics.png')) {
        final c = fileMap['textures/causticsLow/caustics.png']!;
        fileMap['textures/caustic/caustics.png'] = ArchiveFile(
          'textures/caustic/caustics.png',
          c.size,
          c.content,
        );
      }
      if (fileMap.containsKey('textures/caustic/caustics.png') &&
          !fileMap.containsKey('textures/causticsLow/caustics.png')) {
        final c = fileMap['textures/caustic/caustics.png']!;
        fileMap['textures/causticsLow/caustics.png'] = ArchiveFile(
          'textures/causticsLow/caustics.png',
          c.size,
          c.content,
        );
      }
      // Ensure cloud texture exists in standard environment folder
      if (fileMap.containsKey('subpacks/16x/textures/clouds.png') &&
          !fileMap.containsKey('textures/environment/clouds.png')) {
        final c = fileMap['subpacks/16x/textures/clouds.png']!;
        fileMap['textures/environment/clouds.png'] = ArchiveFile(
          'textures/environment/clouds.png',
          c.size,
          c.content,
        );
      }

      // 12. Manifest.json & Subpacks Preservation
      final packUuid = const Uuid().v4();
      final moduleUuid = const Uuid().v4();
      String pName = shaderNameCtrl.text.trim().isEmpty
          ? 'Piglix Shader'
          : shaderNameCtrl.text.trim();

      List<Map<String, dynamic>> subpacksList = [];
      if (fileMap.containsKey('manifest.json')) {
        try {
          final existingM =
              jsonDecode(
                    utf8.decode(fileMap['manifest.json']!.content as List<int>),
                  )
                  as Map<String, dynamic>;
          if (existingM['subpacks'] is List &&
              (existingM['subpacks'] as List).isNotEmpty) {
            subpacksList = (existingM['subpacks'] as List)
                .map((e) => Map<String, dynamic>.from(e as Map))
                .toList();
          }
        } catch (_) {}
      }
      if (subpacksList.isEmpty) {
        subpacksList = [
          {
            'folder_name': '32x',
            'name': '32x HD Texture Resolution',
            'memory_tier': 2,
          },
          {
            'folder_name': '16x',
            'name': '16x Standard Texture Resolution',
            'memory_tier': 3,
          },
        ];
      }

      final manifestJson = jsonEncode({
        'format_version': 2,
        'header': {
          'name': pName,
          'description':
              'Piglix Vibrant Visuals · Bedrock Deferred PBR Shader\n§aReal-Time Lighting · Water Caustics · Atmospheric Rays & PBR',
          'uuid': packUuid,
          'version': [1, 0, 0],
          'min_engine_version': [1, 21, 0],
        },
        'modules': [
          {
            'type': 'resources',
            'uuid': moduleUuid,
            'version': [1, 0, 0],
          },
        ],
        'capabilities': enablePBR ? ['pbr'] : [],
        'subpacks': subpacksList,
      });
      final mBytes = utf8.encode(manifestJson);
      fileMap['manifest.json'] = ArchiveFile(
        'manifest.json',
        mBytes.length,
        mBytes,
      );

      // 13. Texts Localization (en_US.lang)
      final langContent =
          'pack.name=$pName\npack.description=Piglix Vibrant Visuals Engine for Minecraft Bedrock (Deferred PBR)\n';
      final lBytes = utf8.encode(langContent);
      fileMap['texts/en_US.lang'] = ArchiveFile(
        'texts/en_US.lang',
        lBytes.length,
        lBytes,
      );

      await Future.delayed(const Duration(milliseconds: 300));
      progressN.value = 0.85;
      statusN.value = 'Packaging Vibrant Visuals Deferred MCPACK...';

      final finalArchive = Archive();
      for (final f in fileMap.values) {
        finalArchive.addFile(f);
      }
      final encoded = await compute(_encodeZipArchiveWorker, finalArchive);

      await Future.delayed(const Duration(milliseconds: 150));
      progressN.value = 1.0;
      statusN.value = 'Done! ✨';

      pName = shaderNameCtrl.text.trim().isEmpty
          ? 'Piglix Shader'
          : shaderNameCtrl.text.trim();
      setState(() {
        _generatedPackBytes = encoded;
        _generatedPackName = '$pName.mcpack';
        _isGenerated = true;
      });

      UserShaderStore.addShader(
        name: pName,
        bytes: encoded,
        previewColor: morningColor,
      );

      await Future.delayed(const Duration(milliseconds: 500));
      if (mounted) Navigator.pop(context);
      _snack('✨ $pName generated! Ready to install in Minecraft.');
    } catch (e) {
      if (mounted) Navigator.pop(context);
      _snack('Compilation error: $e', isError: true);
    }
  }

  // ── Download & Open in Minecraft ────────────────────────────────────────
  Future<void> _downloadPack() async {
    if (_generatedPackBytes == null) return;
    final pName = _generatedPackName ?? 'piglix_shader.mcpack';
    try {
      if (kIsWeb) {
        final blob = html.Blob([
          Uint8List.fromList(_generatedPackBytes!),
        ], 'application/zip');
        final url = html.Url.createObjectUrlFromBlob(blob);
        html.AnchorElement(href: url)
          ..setAttribute('download', pName)
          ..click();
        html.Url.revokeObjectUrl(url);
        _snack('⬇ $pName downloaded!');
      } else {
        try {
          await FileSaver.instance.saveFile(
            name: pName.replaceAll('.mcpack', ''),
            bytes: Uint8List.fromList(_generatedPackBytes!),
            fileExtension: 'mcpack',
            mimeType: MimeType.other,
          );
          _snack('⬇ Saved: $pName');
        } catch (e) {
          try {
            final tp = await getNativeTempPath();
            await writeNativeFile('$tp/$pName', _generatedPackBytes!);
            _snack('⬇ Saved to: $tp/$pName');
          } catch (_) {
            _snack('❌ Could not save file: $e', isError: true);
          }
        }
      }
    } catch (e) {
      _snack('❌ Download error: $e', isError: true);
    }
  }

  Future<void> _openWithMinecraft() async {
    if (_generatedPackBytes == null) return;
    final pName = _generatedPackName ?? 'piglix_shader.mcpack';
    if (kIsWeb) {
      final blob = html.Blob([
        Uint8List.fromList(_generatedPackBytes!),
      ], 'application/octet-stream');
      final url = html.Url.createObjectUrlFromBlob(blob);
      html.AnchorElement(href: url)
        ..setAttribute('download', pName)
        ..click();
      html.Url.revokeObjectUrl(url);
      _snack(
        '📦 .mcpack downloaded! Open from Downloads to install in Minecraft.',
      );
      return;
    }
    try {
      final tp = await getNativeTempPath();
      final path = '$tp/$pName';
      await writeNativeFile(path, _generatedPackBytes!);
      const platform = MethodChannel('com.piglix.shader/launcher');
      await platform.invokeMethod('openWithMinecraft', {'filePath': path});
      _snack('✅ Opening $pName in Minecraft...');
    } catch (e) {
      _snack('Error opening Minecraft: $e', isError: true);
    }
  }
}

class _CompileProgressDialog extends StatefulWidget {
  final Future<void> Function(
    ValueNotifier<double> progressN,
    ValueNotifier<String> statusN,
  )
  onCompile;

  const _CompileProgressDialog({required this.onCompile});

  @override
  State<_CompileProgressDialog> createState() => _CompileProgressDialogState();
}

class _CompileProgressDialogState extends State<_CompileProgressDialog> {
  final ValueNotifier<double> progressN = ValueNotifier<double>(0.1);
  final ValueNotifier<String> statusN = ValueNotifier<String>(
    'Initializing Piglix Engine...',
  );

  @override
  void initState() {
    super.initState();
    widget.onCompile(progressN, statusN);
  }

  @override
  void dispose() {
    progressN.dispose();
    statusN.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: const Color(0xFF0E1722),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: const BorderSide(color: Color(0xFF1E293B)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const AnimatedMinecraftIcon(
              type: VoxelIconType.grassBlock,
              size: 48,
            ),
            const SizedBox(height: 16),
            const Text(
              'COMPILING SHADER',
              style: TextStyle(
                fontWeight: FontWeight.w900,
                letterSpacing: 2,
                fontSize: 16,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 14),
            ValueListenableBuilder<double>(
              valueListenable: progressN,
              builder: (context, v, child) => ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: LinearProgressIndicator(
                  value: v,
                  backgroundColor: Colors.black45,
                  color: const Color(0xFF22C55E),
                  minHeight: 8,
                ),
              ),
            ),
            const SizedBox(height: 12),
            ValueListenableBuilder<String>(
              valueListenable: statusN,
              builder: (context, s, child) => Text(
                s,
                style: const TextStyle(color: Colors.white60, fontSize: 12),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SteveUpperBodyWidget extends StatelessWidget {
  final double width;
  final double height;

  const _SteveUpperBodyWidget({this.width = 46, this.height = 60});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(width, height),
      painter: const _SteveUpperBodyPainter(),
    );
  }
}

class _SteveUpperBodyPainter extends CustomPainter {
  const _SteveUpperBodyPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Scale from reference 46 x 60
    final sx = w / 46.0;
    final sy = h / 60.0;

    void drawVoxel(double x, double y, double vw, double vh, Color c) {
      canvas.drawRect(
        Rect.fromLTWH(x * sx, y * sy, vw * sx, vh * sy),
        Paint()..color = c,
      );
    }

    // 1. HEAD (24w x 22h, centered horizontally at x=11)
    const headX = 11.0;
    const headY = 2.0;

    // Base skin tone
    drawVoxel(headX, headY, 24, 22, const Color(0xFFD7A17C));

    // Hair: Top cap
    drawVoxel(headX, headY, 24, 6, const Color(0xFF462917));
    // Hair: Left & right sideburns
    drawVoxel(headX, headY + 6, 4, 8, const Color(0xFF462917));
    drawVoxel(headX + 20, headY + 6, 4, 8, const Color(0xFF462917));
    // Hair: Center bangs dip
    drawVoxel(headX + 9, headY + 6, 6, 2, const Color(0xFF462917));

    // Eyes (y = headY + 9)
    final eyeY = headY + 9;
    // Left eye (white outer, cyan inner pupil)
    drawVoxel(headX + 3, eyeY, 3, 3, Colors.white);
    drawVoxel(headX + 6, eyeY, 3, 3, const Color(0xFF00796B));
    // Right eye (cyan inner pupil, white outer)
    drawVoxel(headX + 15, eyeY, 3, 3, const Color(0xFF00796B));
    drawVoxel(headX + 18, eyeY, 3, 3, Colors.white);

    // Nose
    drawVoxel(headX + 9, headY + 12, 6, 3, const Color(0xFFBD8262));

    // Mouth / Goatee
    drawVoxel(headX + 8, headY + 15, 8, 3, const Color(0xFF5D4037));

    // 2. TORSO & ARMS
    // Neck opening (skin tone)
    drawVoxel(18, 24, 10, 3, const Color(0xFFD7A17C));

    // Cyan T-Shirt body (vibrant teal/cyan like screenshot)
    drawVoxel(13, 27, 20, 15, const Color(0xFF00A896));
    // Cyan Shirt bottom shadow hem
    drawVoxel(13, 40, 20, 2, const Color(0xFF007E70));
    // Cyan Shirt left & right side seams
    drawVoxel(13, 27, 2, 15, const Color(0xFF007E70));
    drawVoxel(31, 27, 2, 15, const Color(0xFF007E70));

    // Left Arm: Cyan short sleeve cap
    drawVoxel(5, 27, 8, 6, const Color(0xFF00A896));
    // Left Arm: Skin tone
    drawVoxel(5, 33, 8, 12, const Color(0xFFD7A17C));
    // Left Arm: Hand shadow crease
    drawVoxel(5, 43, 8, 2, const Color(0xFFBD8262));

    // Right Arm: Cyan short sleeve cap
    drawVoxel(33, 27, 8, 6, const Color(0xFF00A896));
    // Right Arm: Skin tone
    drawVoxel(33, 33, 8, 12, const Color(0xFFD7A17C));
    // Right Arm: Hand shadow crease
    drawVoxel(33, 43, 8, 2, const Color(0xFFBD8262));

    // 3. LEATHER BELT with GOLD BUCKLE
    drawVoxel(13, 42, 20, 4, const Color(0xFF3E2723));
    // Gold buckle
    drawVoxel(20, 42, 6, 4, const Color(0xFFFFD54F));
    drawVoxel(22, 43, 2, 2, const Color(0xFFFFA000));

    // 4. BLUE JEANS
    drawVoxel(13, 46, 20, 14, const Color(0xFF1E3A8A));
    // Center fly / seam
    drawVoxel(22, 46, 2, 14, const Color(0xFF172554));
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
