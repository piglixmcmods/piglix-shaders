// new_ui.dart  — Piglix Shader Studio v2  (beautiful redesign)
// Home screen → "OPEN EDITOR" grid cards → tabbed shader editor

import 'dart:convert';
import 'dart:math' as math;
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:archive/archive.dart';
import 'package:universal_html/html.dart' as html;
import 'package:uuid/uuid.dart';
import 'package:file_saver/file_saver.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'piglix_logo_data.dart';
import 'minecraft_icons.dart';
import 'legal_screens.dart';
import 'my_shaders_screen.dart';
import 'sunset_banner_data.dart';
import 'water_lake_banner_data.dart';
import 'tab_art_data.dart';
import 'banner_bytes.dart';
import 'hero_sunset_bytes.dart';
import 'io_stub.dart' if (dart.library.io) 'io_real.dart';

// ─── COHESIVE DARK GREY BROWNISH PALETTE ─────────────────────────────────────
const _bg = Color(0xFF141312);          // Deep dark grey with warm brownish tone
const _surface = Color(0xFF1F1E1C);     // Dark grey top bar, header & bottom bar
const _card = Color(0xFF282624);        // Dark grey brownish card
const _border = Color(0xFF423C37);      // Muted dark grey brownish border
const _green = Color(0xFFD49B6A);      // Warm bronze-amber gold accent (replaces green)
const _greenDim = Color(0xFF262422);   // Dark grey brownish notification & surface

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
    path.quadraticBezierTo(center.dx + rIn, center.dy - rIn, center.dx + radius, center.dy);
    path.quadraticBezierTo(center.dx + rIn, center.dy + rIn, center.dx, center.dy + radius);
    path.quadraticBezierTo(center.dx - rIn, center.dy + rIn, center.dx - radius, center.dy);
    path.quadraticBezierTo(center.dx - rIn, center.dy - rIn, center.dx, center.dy - radius);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    if (glow) {
      final glowPaint = Paint()
        ..color = color.withOpacity(0.38)
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
      ..color = Colors.white.withOpacity(0.85)
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
    return CustomPaint(
      size: Size(size, size),
      painter: SparkleStarsPainter(color: color, glow: glow),
    );
  }
}

// ─── ENTRY POINT ────────────────────────────────────────────────────────────
class PiglixHomeScreen extends StatefulWidget {
  const PiglixHomeScreen({super.key});
  @override
  State<PiglixHomeScreen> createState() => _PiglixHomeScreenState();
}

class _PiglixHomeScreenState extends State<PiglixHomeScreen>
    with SingleTickerProviderStateMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  late final AnimationController _pulseCtrl;

  // Custom pack upload state
  List<int>? _uploadedShaderBytes;
  String? _uploadedShaderName;
  Uint8List? _uploadedLogoBytes;
  String? _uploadedLogoName;

  // Shader configuration
  final TextEditingController _shaderNameCtrl =
      TextEditingController(text: 'Piglix Shader');
  String _selectedEngine = 'Vibrant'; // 'Vibrant' or 'Classic'

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
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    _shaderNameCtrl.dispose();
    super.dispose();
  }

  void _randomizeShaderName() {
    final cur = _shaderNameCtrl.text;
    final other = _namePresets.where((p) => p != cur).toList();
    other.shuffle();
    setState(() {
      _shaderNameCtrl.text = other.first;
    });
  }

  Future<void> _pickCustomShader() async {
    try {
      final f = await FilePicker.pickFile(
        type: FileType.custom,
        allowedExtensions: ['mcpack', 'zip'],
      );
      if (f != null) {
        final bytes = await f.readAsBytes();
        if (bytes.isNotEmpty) {
          setState(() {
            _uploadedShaderBytes = bytes;
            _uploadedShaderName = f.name;
            final base = f.name.replaceAll(RegExp(r'\.(mcpack|zip)$', caseSensitive: false), '');
            if (base.isNotEmpty) _shaderNameCtrl.text = base;
          });
          _snack('Loaded "${f.name}" (${(bytes.length / 1024).toStringAsFixed(1)} KB)');
        }
      }
    } catch (e) {
      _snack('Could not load shader file: $e', isError: true);
    }
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
          _snack('Custom logo "${f.name}" set!');
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
        backgroundColor: isError ? const Color(0xFF5D1E1E) : const Color(0xFF262422),
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
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: const Color(0xFF080D14),
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
                  errorBuilder: (ctx, err, stack) => Image.asset(
                    'assets/hero_sunset.webp',
                    fit: BoxFit.cover,
                  ),
                ),
                // Gradient overlay fading into deep charcoal #080D14
                DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withOpacity(0.35),
                        Colors.transparent,
                        const Color(0xFF080D14).withOpacity(0.75),
                        const Color(0xFF080D14),
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
                _buildTopBar(),

                // Static, properly-fitted content without scrolling
                Expanded(
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final avail = constraints.maxHeight;
                      // Base natural height of the 6 sections with modest gaps: ~510px.
                      const baseContentHeight = 470.0;

                      Widget buildStaticColumn() {
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              const Spacer(),
                              _buildHeroTextSection(),
                              const SizedBox(height: 10),
                              _buildStartBuildingButton(),
                              const SizedBox(height: 10),
                              _buildQuickActionCards(),
                              const SizedBox(height: 10),
                              _buildEngineSection(),
                              const SizedBox(height: 10),
                              _buildShaderNameSection(),
                              const SizedBox(height: 10),
                              _buildUploadCards(),
                              const SizedBox(height: 10),
                            ],
                          ),
                        );
                      }

                      if (avail < baseContentHeight) {
                        return Center(
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            alignment: Alignment.center,
                            child: SizedBox(
                              width: constraints.maxWidth,
                              height: baseContentHeight,
                              child: buildStaticColumn(),
                            ),
                          ),
                        );
                      }

                      return buildStaticColumn();
                    },
                  ),
                ),
                // Fixed Bottom Navigation Bar matching reference
                _buildBottomNavBar(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 1. Top Bar: 3-Line Menu Button on Left + 3D Grass Block + PIGLIX STUDIO Title
  Widget _buildTopBar() {
    const s = 2.5;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          // 3-Line Hamburger Menu Button to open the Sidebar Drawer
          GestureDetector(
            onTap: () => _scaffoldKey.currentState?.openDrawer(),
            child: CustomPaint(
              painter: _PixelatedCardPainter(
                fillColor: const Color(0xFF182230).withOpacity(0.85),
                borderColor: const Color(0xFF2D3B4E),
                borderWidth: 1.2,
                step: s,
                hasShadow: true,
              ),
              foregroundPainter: _PixelatedBorderPainter(
                borderColor: const Color(0xFF2D3B4E),
                borderWidth: 1.2,
                step: s,
              ),
              child: ClipPath(
                clipper: _PixelatedClipper(s),
                child: const SizedBox(
                  width: 40,
                  height: 40,
                  child: Icon(
                    Icons.menu_rounded,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          // 3D Grass Block Logo Icon
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF4ADE80).withOpacity(0.35),
                  blurRadius: 10,
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.memory(
                kPiglixLogoBytes,
                fit: BoxFit.cover,
                errorBuilder: (ctx, err, stack) => const AnimatedMinecraftIcon(
                  type: VoxelIconType.grassBlock,
                  size: 38,
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          // Studio Title in Green Glowing Gradient
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'PIGLIX ',
                      style: TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 17,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        letterSpacing: 1.2,
                      ),
                    ),
                    Text(
                      'STUDIO',
                      style: TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 17,
                        fontWeight: FontWeight.w900,
                        color: const Color(0xFF4ADE80),
                        letterSpacing: 1.2,
                        shadows: [
                          Shadow(
                            color: const Color(0xFF4ADE80).withOpacity(0.5),
                            blurRadius: 10,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 1),
                const Text(
                  'SHADER GENERATOR FOR MCPE',
                  style: TextStyle(
                    fontSize: 8.5,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF94A3B8),
                    letterSpacing: 1.0,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 2. Hero Text Section
  Widget _buildHeroTextSection() {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'TURN\nYOUR WORLD\nINTO SOMETHING\nINCREDIBLE',
          style: TextStyle(
            fontFamily: 'monospace',
            fontSize: 20.0,
            fontWeight: FontWeight.w900,
            color: Colors.white,
            height: 1.15,
            letterSpacing: 1.1,
            shadows: [
              Shadow(
                color: Colors.black,
                blurRadius: 8,
                offset: Offset(0, 2),
              ),
              Shadow(
                color: Colors.black,
                blurRadius: 3,
                offset: Offset(1, 1),
              ),
            ],
          ),
        ),
        SizedBox(height: 5),
        Text(
          'Easy. Powerful. Made for MCPE.',
          style: TextStyle(
            fontSize: 12.5,
            fontWeight: FontWeight.w600,
            color: Colors.white70,
            letterSpacing: 0.3,
            shadows: [
              Shadow(
                color: Colors.black,
                blurRadius: 4,
                offset: Offset(0, 1),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // 3. CTA Button: GENERATE SHADER with Diamond Pickaxe and Pixeled Corners
  Widget _buildStartBuildingButton() {
    const s = 4.0;
    return SizedBox(
      height: 52,
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
                    colors: [
                      Color(0xFF22C55E),
                      Color(0xFF16A34A),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    const AnimatedMinecraftIcon(type: VoxelIconType.pickaxe, size: 26),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Text(
                        'GENERATE SHADER',
                        style: TextStyle(
                          fontFamily: 'monospace',
                          color: Colors.white,
                          fontSize: 15.5,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1.4,
                          shadows: [
                            Shadow(
                              color: Colors.black54,
                              blurRadius: 4,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 1.6),
                      ),
                      child: const Icon(
                        Icons.arrow_forward_rounded,
                        color: Colors.white,
                        size: 18,
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

  // 4. Three Quick Action Cards: PRESETS, MY SHADERS, COMMUNITY (Pixelated corners)
  Widget _buildQuickActionCards() {
    return Row(
      children: [
        // 1. PRESETS
        Expanded(
          child: _buildActionTile(
            voxelIcon: VoxelIconType.grassBlock,
            label: 'PRESETS',
            onTap: _pickCustomShader,
          ),
        ),
        const SizedBox(width: 10),
        // 2. MY SHADERS
        Expanded(
          child: _buildActionTile(
            voxelIcon: VoxelIconType.chest,
            label: 'MY SHADERS',
            onTap: _openMyShaders,
          ),
        ),
        const SizedBox(width: 10),
        // 3. COMMUNITY
        Expanded(
          child: _buildActionTile(
            voxelIcon: VoxelIconType.globe,
            label: 'COMMUNITY',
            onTap: () {
              _snack('Community shader sharing & cloud packs coming soon!');
            },
          ),
        ),
      ],
    );
  }

  Widget _buildActionTile({
    VoxelIconType? voxelIcon,
    IconData? iconData,
    Color? iconColor,
    required String label,
    required VoidCallback onTap,
  }) {
    const s = 3.5;
    return GestureDetector(
      onTap: onTap,
      child: CustomPaint(
        painter: _PixelatedCardPainter(
          fillColor: const Color(0xFF111822),
          borderColor: const Color(0xFF1E293B),
          borderWidth: 1.5,
          step: s,
          hasShadow: true,
        ),
        foregroundPainter: _PixelatedBorderPainter(
          borderColor: const Color(0xFF1E293B),
          borderWidth: 1.5,
          step: s,
        ),
        child: ClipPath(
          clipper: _PixelatedClipper(s),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 9, horizontal: 6),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (voxelIcon != null)
                  AnimatedMinecraftIcon(type: voxelIcon, size: 26)
                else if (iconData != null)
                  Icon(iconData, size: 26, color: iconColor ?? Colors.white),
                const SizedBox(height: 5),
                Text(
                  label,
                  style: const TextStyle(
                    fontFamily: 'monospace',
                    color: Colors.white,
                    fontSize: 10.0,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.8,
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

  // 5. ENGINE Section: Long Full-Width Vibrant Engine Card with Pixelated Corners
  Widget _buildEngineSection() {
    const s = 3.5;
    return CustomPaint(
      painter: _PixelatedCardPainter(
        fillColor: const Color(0xFF0F1722),
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
              const AnimatedMinecraftIcon(type: VoxelIconType.grassBlock, size: 28),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'VIBRANT ENGINE',
                      style: TextStyle(
                        fontFamily: 'monospace',
                        color: Colors.white,
                        fontSize: 13.0,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.8,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Minecraft Bedrock JSON Deferred Rendering API',
                      style: TextStyle(
                        color: Color(0xFF4ADE80),
                        fontSize: 10.0,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(
                  color: Color(0xFF4ADE80),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check, color: Colors.black, size: 14),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 6. SHADER NAME Section with Green Pencil + Randomize Dice (Pixelated corners)
  Widget _buildShaderNameSection() {
    const s = 3.0;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'SHADER NAME',
          style: TextStyle(
            fontFamily: 'monospace',
            color: Colors.white,
            fontSize: 12.5,
            fontWeight: FontWeight.w900,
            letterSpacing: 1.0,
          ),
        ),
        const SizedBox(height: 6),
        Row(
          children: [
            Expanded(
              child: CustomPaint(
                painter: _PixelatedCardPainter(
                  fillColor: const Color(0xFF111822),
                  borderColor: const Color(0xFF1E293B),
                  borderWidth: 1.4,
                  step: s,
                  hasShadow: false,
                ),
                foregroundPainter: _PixelatedBorderPainter(
                  borderColor: const Color(0xFF1E293B),
                  borderWidth: 1.4,
                  step: s,
                ),
                child: ClipPath(
                  clipper: _PixelatedClipper(s),
                  child: Container(
                    height: 44,
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.edit_rounded,
                          color: Color(0xFF4ADE80),
                          size: 17,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: TextField(
                            controller: _shaderNameCtrl,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 13.0,
                              fontWeight: FontWeight.w800,
                            ),
                            decoration: const InputDecoration(
                              border: InputBorder.none,
                              hintText: 'Enter shader name...',
                              hintStyle: TextStyle(color: Colors.white38, fontSize: 13.0),
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
            // Dice Randomize Button with pixelated corners
            GestureDetector(
              onTap: _randomizeShaderName,
              child: CustomPaint(
                painter: _PixelatedCardPainter(
                  fillColor: const Color(0xFF111822),
                  borderColor: const Color(0xFF1E293B),
                  borderWidth: 1.4,
                  step: s,
                  hasShadow: true,
                ),
                foregroundPainter: _PixelatedBorderPainter(
                  borderColor: const Color(0xFF1E293B),
                  borderWidth: 1.4,
                  step: s,
                ),
                child: ClipPath(
                  clipper: _PixelatedClipper(s),
                  child: const SizedBox(
                    width: 44,
                    height: 44,
                    child: Icon(
                      Icons.casino_rounded,
                      color: Color(0xFFFB923C),
                      size: 21,
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

  // 7. Custom Pack Logo Upload Card with Pixelated Corners
  Widget _buildUploadCards() {
    final hasLogo = _uploadedLogoBytes != null;
    const s = 3.5;
    return GestureDetector(
      onTap: _pickCustomLogo,
      child: CustomPaint(
        painter: _PixelatedCardPainter(
          fillColor: const Color(0xFF111822),
          borderColor: hasLogo ? const Color(0xFF22C55E) : const Color(0xFF1E293B),
          borderWidth: hasLogo ? 1.8 : 1.2,
          step: s,
          hasShadow: true,
        ),
        foregroundPainter: _PixelatedBorderPainter(
          borderColor: hasLogo ? const Color(0xFF22C55E) : const Color(0xFF1E293B),
          borderWidth: hasLogo ? 1.8 : 1.2,
          step: s,
        ),
        child: ClipPath(
          clipper: _PixelatedClipper(s),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            child: Row(
              children: [
                Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: hasLogo ? const Color(0xFF22C55E) : const Color(0xFF2D3B4E),
                    ),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: hasLogo
                      ? Image.memory(_uploadedLogoBytes!, fit: BoxFit.cover)
                      : Image.memory(
                          kPiglixLogoBytes,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              const Icon(Icons.image, color: Colors.white38),
                        ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        hasLogo ? 'Pack Logo: $_uploadedLogoName' : 'Custom Pack Logo',
                        style: const TextStyle(
                          fontFamily: 'monospace',
                          color: Colors.white,
                          fontSize: 12.5,
                          fontWeight: FontWeight.w800,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        hasLogo ? 'Tap to change pack icon' : 'Set custom 1:1 image for pack icon',
                        style: const TextStyle(color: Colors.white54, fontSize: 10),
                      ),
                    ],
                  ),
                ),
                Icon(
                  hasLogo ? Icons.check_circle_rounded : Icons.add_photo_alternate_rounded,
                  color: hasLogo ? const Color(0xFF22C55E) : Colors.white38,
                  size: 20,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // 8. Fixed Bottom Navigation Bar matching reference with pixelated corners on active pill
  Widget _buildBottomNavBar() {
    const s = 3.0;
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
      decoration: const BoxDecoration(
        color: Color(0xFF080D14),
        border: Border(
          top: BorderSide(color: Color(0xFF1E293B), width: 1.0),
        ),
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
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: const Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      AnimatedMinecraftIcon(type: VoxelIconType.grassBlock, size: 20),
                      SizedBox(height: 2),
                      Text(
                        'BUILDER',
                        style: TextStyle(
                          fontFamily: 'monospace',
                          color: Colors.black,
                          fontSize: 10,
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
            child: const Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.map_rounded, color: Color(0xFF60A5FA), size: 22),
                SizedBox(height: 3),
                Text(
                  'GALLERY',
                  style: TextStyle(
                    fontFamily: 'monospace',
                    color: Colors.white70,
                    fontSize: 9.5,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
          // 3. PRESETS
          GestureDetector(
            onTap: _pickCustomShader,
            behavior: HitTestBehavior.opaque,
            child: const Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.menu_book_rounded, color: Color(0xFFEF4444), size: 22),
                SizedBox(height: 3),
                Text(
                  'PRESETS',
                  style: TextStyle(
                    fontFamily: 'monospace',
                    color: Colors.white70,
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
            child: const Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.settings_rounded, color: Color(0xFF94A3B8), size: 22),
                SizedBox(height: 3),
                Text(
                  'SETTINGS',
                  style: TextStyle(
                    fontFamily: 'monospace',
                    color: Colors.white70,
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
    return Drawer(
      backgroundColor: const Color(0xFF141312),
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Drawer Header with App Logo & Title
            Container(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 18),
              decoration: const BoxDecoration(
                color: Color(0xFF1F1E1C),
                border: Border(bottom: BorderSide(color: Color(0xFF3E3935), width: 1.5)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: _green, width: 2.0),
                      boxShadow: [
                        BoxShadow(
                          color: _green.withOpacity(0.35),
                          blurRadius: 16,
                        ),
                      ],
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: Image.memory(kPiglixLogoBytes, fit: BoxFit.cover),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Shader Generator for MCPE',
                    style: TextStyle(
                      color: Color(0xFFFFF8E7),
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 3),
                  const Text(
                    'Minecraft Bedrock Vibrant Visuals Editor • v1.0',
                    style: TextStyle(color: Color(0xFFC7BEB5), fontSize: 11),
                  ),
                ],
              ),
            ),

            // Navigation and Legal items
            Expanded(
              child: ListView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(vertical: 8),
                children: [
                  _drawerTile(
                    Icons.tune_rounded,
                    'Shader Editor',
                    'Customize lighting & atmosphere',
                    () {
                      Navigator.pop(context);
                      _openEditor();
                    },
                  ),
                  _drawerTile(
                    Icons.folder_special_rounded,
                    'My Shaders',
                    'View & export generated shaders',
                    () {
                      Navigator.pop(context);
                      _openMyShaders();
                    },
                  ),
                  _drawerTile(
                    Icons.upload_file_rounded,
                    'Upload MC Pack',
                    'Import custom .mcpack or .zip shader',
                    () {
                      Navigator.pop(context);
                      _pickCustomShader();
                    },
                  ),
                  const Divider(color: Color(0xFF2E2A27), height: 24, indent: 16, endIndent: 16),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
                    child: Text(
                      'LEGAL & COMPLIANCE',
                      style: TextStyle(
                        color: _green,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ),
                  _drawerTile(
                    Icons.privacy_tip_outlined,
                    'Privacy Policy',
                    'Data collection & permissions',
                    () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const LegalPage(type: LegalType.privacy)),
                      );
                    },
                  ),
                  _drawerTile(
                    Icons.gavel_outlined,
                    'Terms of Service',
                    'App usage & license terms',
                    () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const LegalPage(type: LegalType.terms)),
                      );
                    },
                  ),
                  _drawerTile(
                    Icons.verified_user_outlined,
                    'Trademark & Legal Notice',
                    'Mojang & Microsoft disclaimer',
                    () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const LegalPage(type: LegalType.trademark)),
                      );
                    },
                  ),
                  _drawerTile(
                    Icons.code_rounded,
                    'Open Source Licenses',
                    'Third-party software notices',
                    () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const LegalPage(type: LegalType.licenses)),
                      );
                    },
                  ),
                ],
              ),
            ),

            // Drawer Disclaimer Footer
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              color: const Color(0xFF100F0E),
              child: const Text(
                'NOT AN OFFICIAL MINECRAFT PRODUCT. NOT APPROVED BY OR ASSOCIATED WITH MOJANG OR MICROSOFT.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Color(0xFF7A736C),
                  fontSize: 9,
                  fontWeight: FontWeight.bold,
                  height: 1.3,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _drawerTile(
    IconData icon,
    String title,
    String subtitle,
    VoidCallback onTap,
  ) {
    return ListTile(
      leading: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: const Color(0xFF282624),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: const Color(0xFF3E3935)),
        ),
        child: Icon(icon, color: _green, size: 18),
      ),
      title: Text(
        title,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 13.5,
          fontWeight: FontWeight.w700,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: const TextStyle(
          color: Colors.white38,
          fontSize: 11,
        ),
      ),
      trailing: const Icon(Icons.arrow_forward_ios_rounded, color: Colors.white24, size: 12),
      onTap: onTap,
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
    _scaleAnim = Tween<double>(begin: 1.0, end: 0.94).animate(
      CurvedAnimation(parent: _pressCtrl, curve: Curves.easeOut),
    );
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
    final selBorderColor = widget.selectedBorderColor ?? const Color(0xFFE5A04A);

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
                        color: selBorderColor.withOpacity(0.55),
                        blurRadius: 14,
                        spreadRadius: 1.5,
                        offset: const Offset(0, 1),
                      )
                    else
                      BoxShadow(
                        color: Colors.black.withOpacity(0.60),
                        blurRadius: 6,
                        offset: const Offset(0, 3),
                      ),
                  ],
                ),
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
            const SizedBox(height: 7),
            // Card Label underneath in bold, clean typography
            Text(
              widget.label,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontWeight: FontWeight.w900,
                color: widget.labelColor ?? (isSel ? selBorderColor : Colors.white),
                fontSize: 11.5,
                letterSpacing: 0.4,
              ),
            ),
            if (widget.showHexBadge) ...[
              const SizedBox(height: 3),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                decoration: BoxDecoration(
                  color: c.withOpacity(0.22),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: isSel
                        ? selBorderColor
                        : c.withOpacity(0.6),
                    width: 1.0,
                  ),
                ),
                child: Text(
                  '#${c.value.toRadixString(16).substring(2).toUpperCase()}',
                  style: TextStyle(
                    color: Color.lerp(c, Colors.white, 0.7),
                    fontSize: 8.5,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ],
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
    canvas.drawPath(
      outerPath,
      Paint()..color = const Color(0xFF141916),
    );

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
          ..color = Color.lerp(selectedBorderColor, Colors.white, 0.4)!.withOpacity(0.65)
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
          ..color = Colors.black.withOpacity(0.7)
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
                    BoxShadow(color: _green.withOpacity(0.6), blurRadius: 6),
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
            final spacing = gap ?? 8.0; // Proper spacing so cards don't touch and look clean
            final count = tiles.length;

            if (count == 0) return const SizedBox.shrink();

            // Uniform tile width across all tabs (2-card and 4-card grids match exactly)
            final baseTileW = math.min((c.maxWidth - (cols - 1) * spacing) / cols, 68.0);
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
        child: CustomPaint(
          painter: _RealisticShaderPainter(type: type, color: color),
        ),
      );
    }
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _RealisticShaderPainter(type: type, color: color),
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
  // 1. MINECRAFT MORNING: Simple, Beautiful Sunrise over Rolling Green Plains
  // Normal, clean Minecraft dawn landscape with rising sun & classic oak tree
  // ─────────────────────────────────────────────────────────────────────────
  void _drawMinecraftMorning(Canvas canvas, double w, double h, Color c) {
    // 1. Soft pastel sunrise dawn sky
    final skyTop = Color.lerp(const Color(0xFF6B9DE8), c, 0.40)!;
    final skyMid = Color.lerp(const Color(0xFFFFA07A), c, 0.48)!;
    final horizon = Color.lerp(const Color(0xFFFFD180), c, 0.55)!;

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
    _drawTieredVoxelCloud(canvas, w * 0.08, h * 0.12, w * 0.42, h * 0.08, cloudLit, cloudShadow);
    _drawTieredVoxelCloud(canvas, w * 0.54, h * 0.18, w * 0.38, h * 0.07, cloudLit, cloudShadow);

    // 3. Distant soft mountain ridge on horizon
    final distHills = Color.lerp(const Color(0xFF7CB342), horizon, 0.40)!;
    _drawDistantForestRidge(canvas, w, h * 0.46, distHills);

    // 4. Low Glowing Square Minecraft Sun on Left Horizon
    final sunX = w * 0.32;
    final sunY = h * 0.44;
    final sunSize = w * 0.21;
    _drawSquareSun(canvas, sunX, sunY, sunSize, c, defaultGlow: const Color(0xFFFFD54F));

    // 5. Rolling gentle Minecraft grass hills
    final grassTop = Color.lerp(const Color(0xFF558B2F), c, 0.22)!;
    final dirtSide = const Color(0xFF4E342E);
    // Back hill
    _drawVoxelBlock(canvas, 0, h * 0.52, w * 0.65, h * 0.10, grassTop, dirtSide);
    // Main foreground hill
    _drawVoxelBlock(canvas, 0, h * 0.60, w, h * 0.40, grassTop, dirtSide);
    _drawVoxelBlock(canvas, 0, h * 0.72, w * 0.75, h * 0.28, grassTop, dirtSide);

    // 6. Classic Minecraft Oak Tree on the RIGHT hill in morning light
    _drawMinecraftOakTree(canvas, w * 0.60, h * 0.36, w * 0.36, h * 0.38, grassTop);

    // Morning golden light haze across the grass
    canvas.drawRect(
      Rect.fromLTWH(0, h * 0.52, w, h * 0.48),
      Paint()..color = const Color(0xFFFFE082).withOpacity(0.12),
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
    _drawTieredVoxelCloud(canvas, w * 0.06, h * 0.16, w * 0.45, h * 0.09, cloudLit, cloudShadow);
    _drawTieredVoxelCloud(canvas, w * 0.52, h * 0.24, w * 0.42, h * 0.08, cloudLit, cloudShadow);

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
    _drawVoxelBlock(canvas, 0, h * 0.52, w * 0.36, h * 0.08, grassTop, dirtSide);
    _drawVoxelBlock(canvas, 0, h * 0.60, w * 0.30, h * 0.10, grassTop, dirtSide);
    _drawVoxelBlock(canvas, 0, h * 0.70, w * 0.24, h * 0.30, grassTop, dirtSide);
    // Right Bank
    _drawVoxelBlock(canvas, w * 0.62, h * 0.52, w * 0.38, h * 0.08, grassTop, dirtSide);
    _drawVoxelBlock(canvas, w * 0.68, h * 0.60, w * 0.32, h * 0.10, grassTop, dirtSide);
    _drawVoxelBlock(canvas, w * 0.74, h * 0.70, w * 0.26, h * 0.30, grassTop, dirtSide);

    // 7. Tall classic Minecraft Oak Tree on the LEFT bank
    _drawMinecraftOakTree(canvas, w * 0.04, h * 0.30, w * 0.38, h * 0.40, grassTop);
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
    _drawTieredVoxelCloud(canvas, w * 0.08, h * 0.14, w * 0.42, h * 0.07, cloudLit, cloudShadow);
    _drawTieredVoxelCloud(canvas, w * 0.54, h * 0.22, w * 0.38, h * 0.06, cloudLit, cloudShadow);

    // 3. Layered distant mountain ridges against the sunset
    final ridgeFar = Color.lerp(const Color(0xFF5D2417), horizon, 0.30)!;
    _drawDistantForestRidge(canvas, w, h * 0.46, ridgeFar);

    // 4. Large Glowing Setting Square Minecraft Sun on Center Horizon
    final sunX = w * 0.48;
    final sunY = h * 0.48;
    final sunSize = w * 0.23;
    _drawSquareSun(canvas, sunX, sunY, sunSize, c, defaultGlow: const Color(0xFFFFD600));

    // 5. Rolling hills in warm evening sunset tone
    final grassEvening = Color.lerp(const Color(0xFF33691E), horizon, 0.35)!;
    final dirtEvening = const Color(0xFF3E2723);
    _drawVoxelBlock(canvas, 0, h * 0.54, w, h * 0.46, grassEvening, dirtEvening);
    _drawVoxelBlock(canvas, 0, h * 0.66, w * 0.85, h * 0.34, grassEvening, dirtEvening);
    _drawVoxelBlock(canvas, 0, h * 0.78, w * 0.60, h * 0.22, grassEvening, dirtEvening);

    // 6. Classic Minecraft Oak Tree silhouetted on the RIGHT edge
    _drawMinecraftOakTree(canvas, w * 0.60, h * 0.36, w * 0.36, h * 0.38, grassEvening, isSilhouette: true);

    // Warm golden hour sunlight cast across the hills
    canvas.drawRect(
      Rect.fromLTWH(0, h * 0.54, w, h * 0.46),
      Paint()..color = const Color(0xFFFF6D00).withOpacity(0.14),
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
    _drawVoxelBlock(canvas, 0, h * 0.54, w * 0.36, h * 0.08, grassNight, dirtNight);
    _drawVoxelBlock(canvas, 0, h * 0.62, w * 0.30, h * 0.10, grassNight, dirtNight);
    _drawVoxelBlock(canvas, 0, h * 0.72, w * 0.24, h * 0.28, grassNight, dirtNight);

    _drawVoxelBlock(canvas, w * 0.60, h * 0.54, w * 0.40, h * 0.08, grassNight, dirtNight);
    _drawVoxelBlock(canvas, w * 0.66, h * 0.62, w * 0.34, h * 0.10, grassNight, dirtNight);
    _drawVoxelBlock(canvas, w * 0.72, h * 0.72, w * 0.28, h * 0.28, grassNight, dirtNight);

    // 7. Dark Minecraft spruce / pine tree on the left and oak on right
    _drawMinecraftSpruceTree(canvas, w * 0.06, h * 0.36, w * 0.28, h * 0.38, grassNight);
    _drawMinecraftOakTree(canvas, w * 0.68, h * 0.38, w * 0.30, h * 0.34, grassNight, isSilhouette: true);
  }

  // ─────────────────────────────────────────────────────────────────────────
  // MINECRAFT PROCEDURAL ENGINE HELPERS (Trees, Moon, Sun, Clouds, Voxel Blocks)
  // ─────────────────────────────────────────────────────────────────────────

  /// Draws an authentic Minecraft Crescent Moon out of stepped pixel blocks
  void _drawPixelCrescentMoon(Canvas canvas, double cx, double cy, double size, Color c) {
    // Outer moonlight radial aura
    canvas.drawCircle(
      Offset(cx, cy),
      size * 1.25,
      Paint()
        ..shader = RadialGradient(
          colors: [
            Color.lerp(Colors.white, c, 0.35)!.withOpacity(0.40),
            Color.lerp(const Color(0xFF90CAF9), c, 0.45)!.withOpacity(0.18),
            Colors.transparent,
          ],
        ).createShader(Rect.fromCircle(center: Offset(cx, cy), radius: size * 1.25)),
    );

    final moonColor = Color.lerp(Colors.white, c, 0.15)!;
    final p = size / 8.0;
    final startX = cx - size * 0.5;
    final startY = cy - size * 0.5;

    // 8x8 Pixel Grid definition for crescent moon facing left
    const pixelCoords = [
      [3, 0], [4, 0],
      [2, 1], [3, 1], [4, 1],
      [1, 2], [2, 2], [3, 2],
      [1, 3], [2, 3],
      [1, 4], [2, 4],
      [1, 5], [2, 5], [3, 5],
      [2, 6], [3, 6], [4, 6],
      [3, 7], [4, 7],
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
    canvas.drawRect(Rect.fromLTWH(startX + 2 * p, startY + 3 * p, p * 0.8, p * 2), innerHighlight);
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
        ..shader = RadialGradient(
          colors: [
            Colors.white.withOpacity(0.95),
            Color.lerp(defaultGlow, c, 0.45)!.withOpacity(0.65),
            c.withOpacity(0.25),
            Colors.transparent,
          ],
          stops: const [0.0, 0.35, 0.70, 1.0],
        ).createShader(Rect.fromCircle(center: Offset(cx, cy), radius: size * 1.75)),
    );

    // Square Minecraft Sun glow frame
    canvas.drawRect(
      Rect.fromCenter(center: Offset(cx, cy), width: size * 1.15, height: size * 1.15),
      Paint()..color = Color.lerp(defaultGlow, c, 0.40)!.withOpacity(0.50),
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
      Paint()..color = shadowColor.withOpacity(0.85),
    );
    // Cloud lit top
    canvas.drawRect(
      Rect.fromLTWH(x + width * 0.05, y, width * 0.90, height * 0.65),
      Paint()..color = litColor.withOpacity(0.95),
    );
    // Inner stepped cloud puff
    canvas.drawRect(
      Rect.fromLTWH(x + width * 0.20, y - height * 0.25, width * 0.50, height * 0.50),
      Paint()..color = litColor.withOpacity(0.95),
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
    final trunkColor = isSilhouette ? const Color(0xFF1E1513) : const Color(0xFF4E342E);
    final trunkGrain = isSilhouette ? const Color(0xFF140D0C) : const Color(0xFF3E2723);

    // 1. Trunk
    final trunkW = width * 0.18;
    final trunkH = height * 0.50;
    final trunkX = x + width * 0.41;
    final trunkY = y + height * 0.50;
    canvas.drawRect(Rect.fromLTWH(trunkX, trunkY, trunkW, trunkH), Paint()..color = trunkColor);
    canvas.drawRect(Rect.fromLTWH(trunkX + 2, trunkY, trunkW * 0.35, trunkH), Paint()..color = trunkGrain);

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
    canvas.drawRect(Rect.fromLTWH(x, y + h * 0.55, w, h * 0.45), Paint()..color = botShadow);
    // Center base band
    canvas.drawRect(Rect.fromLTWH(x, y + h * 0.20, w, h * 0.55), Paint()..color = base);
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
    _drawVoxelFoliageBox(canvas, x + width * 0.08, y + height * 0.44, width * 0.84, height * 0.20, leafBase, leafLit, leafDark);
    // Tier 3
    _drawVoxelFoliageBox(canvas, x + width * 0.18, y + height * 0.28, width * 0.64, height * 0.20, leafBase, leafLit, leafDark);
    // Tier 2
    _drawVoxelFoliageBox(canvas, x + width * 0.28, y + height * 0.14, width * 0.44, height * 0.18, leafBase, leafLit, leafDark);
    // Tier 1 (top tip)
    _drawVoxelFoliageBox(canvas, x + width * 0.38, y, width * 0.24, height * 0.18, leafBase, leafLit, leafDark);
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
    canvas.drawRect(Rect.fromLTWH(x, y, width, height), Paint()..color = dirtColor);

    // Grass top strip
    final grassH = height * 0.32;
    canvas.drawRect(Rect.fromLTWH(x, y, width, grassH), Paint()..color = grassColor);

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
        Rect.fromCenter(center: Offset(w * centerXRatio, yPos), width: refW, height: 2.6),
        Paint()..color = reflColor.withOpacity(alpha.clamp(0.15, 1.0)),
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
        Rect.fromCenter(center: Offset(w * centerXRatio, yPos), width: refW, height: 2.2),
        Paint()..color = reflColor.withOpacity((0.65 - i * 0.07).clamp(0.12, 1.0)),
      );
    }
  }

  /// Distant Minecraft blocky mountain ridge
  void _drawVoxelMountainRidge(Canvas canvas, double w, double y, Color color, {required int step}) {
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

  void _drawGodRaysScene(Canvas canvas, double w, double h, Color c, {required double angle}) {
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
        ..shader = RadialGradient(
          colors: [
            Color.lerp(Colors.white, sunWarm, 0.3)!.withOpacity(0.70),
            sunWarm.withOpacity(0.28),
            Colors.transparent,
          ],
        ).createShader(Rect.fromCircle(center: Offset(sunX, sunY), radius: w * 0.50)),
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
              rayGlow.withOpacity(rayAlpha * 1.4),
              rayGlow.withOpacity(rayAlpha * 0.70),
              rayGlow.withOpacity(0.02),
            ],
          ).createShader(Rect.fromLTWH(0, sunY, w, h - sunY)),
      );
    }

    // 5. Authentic Minecraft Square Sun (layered glowing voxels, beautiful & clear!)
    // Outer soft sun aura square
    canvas.drawRect(
      Rect.fromCenter(center: Offset(sunX, sunY), width: 22, height: 22),
      Paint()..color = sunWarm.withOpacity(0.35),
    );
    // Mid glowing sun corona
    canvas.drawRect(
      Rect.fromCenter(center: Offset(sunX, sunY), width: 17, height: 17),
      Paint()..color = Color.lerp(sunWarm, Colors.white, 0.45)!.withOpacity(0.85),
    );
    // Inner brilliant Minecraft sun core (pure white)
    canvas.drawRect(
      Rect.fromCenter(center: Offset(sunX, sunY), width: 12, height: 12),
      Paint()..color = Colors.white,
    );
    // Cardinal sun sparkle pixels
    final sparklePaint = Paint()..color = Colors.white.withOpacity(0.9);
    canvas.drawRect(Rect.fromCenter(center: Offset(sunX, sunY - 9), width: 2.5, height: 2.5), sparklePaint);
    canvas.drawRect(Rect.fromCenter(center: Offset(sunX, sunY + 9), width: 2.5, height: 2.5), sparklePaint);
    canvas.drawRect(Rect.fromCenter(center: Offset(sunX - 9, sunY), width: 2.5, height: 2.5), sparklePaint);
    canvas.drawRect(Rect.fromCenter(center: Offset(sunX + 9, sunY), width: 2.5, height: 2.5), sparklePaint);

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
              rayColor.withOpacity(0.32),
              rayColor.withOpacity(0.12),
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

  void _drawCloudBlock(Canvas canvas, double w, double h, Color c, {required bool isTop}) {
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
    canvas.drawPath(rightFace, Paint()..color = Color.lerp(cloudSideColor, Colors.black, 0.20)!);
  }

  void _drawTorchScene(Canvas canvas, double w, double h, Color c) {
    // 1. Dark stone dungeon / mine background
    canvas.drawRect(Rect.fromLTWH(0, 0, w, h), Paint()..color = const Color(0xFF121518));

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
        ..shader = RadialGradient(
          colors: [
            glowColor.withOpacity(0.85),
            glowColor.withOpacity(0.40),
            glowColor.withOpacity(0.12),
            Colors.transparent,
          ],
          stops: const [0.0, 0.35, 0.70, 1.0],
        ).createShader(Rect.fromCircle(center: Offset(torchX, torchY), radius: w * 0.65)),
    );

    // 3. Wooden Torch Handle (with pixel wood texture)
    final stickW = w * 0.10;
    final stickH = h * 0.32;
    final stickX = torchX - stickW * 0.5;
    final stickY = torchY + 4;

    // Wood body
    canvas.drawRect(Rect.fromLTWH(stickX, stickY, stickW, stickH), Paint()..color = const Color(0xFF5D4037));
    // Darker wood edge
    canvas.drawRect(Rect.fromLTWH(stickX + stickW * 0.6, stickY, stickW * 0.4, stickH), Paint()..color = const Color(0xFF3E2723));
    // Lighter wood grain
    canvas.drawRect(Rect.fromLTWH(stickX + 1, stickY, stickW * 0.3, stickH), Paint()..color = const Color(0xFF8D6E63));

    // Coal/charcoal head on stick
    canvas.drawRect(Rect.fromLTWH(stickX, torchY - 2, stickW, 6), Paint()..color = const Color(0xFF212121));

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
    canvas.drawRect(Rect.fromLTWH(torchX - 1, flameY - 15, 1.5, 1.5), Paint()..color = const Color(0xFFFFAB91));
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
      ..color = Colors.white.withOpacity(0.40)
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
      Rect.fromCenter(center: Offset(w * 0.5, h * 0.18), width: w * 0.6, height: 6),
      Paint()..color = Colors.white.withOpacity(0.30),
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
        ..shader = RadialGradient(
          colors: [
            Colors.white.withOpacity(0.45),
            Colors.white.withOpacity(0.15),
            Colors.transparent,
          ],
        ).createShader(Rect.fromCircle(center: Offset(w * 0.5, h * 0.24), radius: w * 0.22)),
    );
    canvas.drawRect(
      Rect.fromCenter(center: Offset(w * 0.5, h * 0.24), width: 10, height: 10),
      Paint()..color = Colors.white.withOpacity(0.55),
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
            skyBot.withOpacity(0.10),
            skyBot.withOpacity(0.55),
            skyBot.withOpacity(0.10),
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
            skyBot.withOpacity(0.15),
            skyBot.withOpacity(0.70),
            skyBot.withOpacity(0.20),
          ],
        ).createShader(Rect.fromLTWH(0, h * 0.62, w, h * 0.14)),
    );

    // 5. Layer 3: Foreground voxel grassy slope with lonely spruce tree
    final grassMist = Color.lerp(const Color(0xFF283618), skyBot, 0.25)!;
    final dirtMist = const Color(0xFF382C1E);
    _drawVoxelBlock(canvas, 0, h * 0.74, w, h * 0.26, grassMist, dirtMist);
    _drawMinecraftSpruceTree(canvas, w * 0.12, h * 0.46, w * 0.28, h * 0.34, grassMist);

    // Ground fog hugging the grass
    canvas.drawRect(
      Rect.fromLTWH(0, h * 0.72, w, h * 0.10),
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.transparent,
            skyBot.withOpacity(0.60),
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
            skyBot.withOpacity(0.10),
            skyBot.withOpacity(0.65),
            skyBot.withOpacity(0.15),
          ],
        ).createShader(Rect.fromLTWH(0, h * 0.46, w, h * 0.22)),
    );

    // 4. Foreground wet voxel grass slope and pine tree
    final grassWet = Color.lerp(const Color(0xFF1F3524), c, 0.20)!;
    final dirtWet = const Color(0xFF251A14);
    _drawVoxelBlock(canvas, 0, h * 0.68, w, h * 0.32, grassWet, dirtWet);
    _drawMinecraftSpruceTree(canvas, w * 0.08, h * 0.40, w * 0.30, h * 0.38, grassWet);

    // Low ground mist hugging the terrain
    canvas.drawRect(
      Rect.fromLTWH(0, h * 0.65, w, h * 0.12),
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.transparent,
            skyBot.withOpacity(0.50),
            Colors.transparent,
          ],
        ).createShader(Rect.fromLTWH(0, h * 0.65, w, h * 0.12)),
    );

    // 5. Natural falling rain streaks (delicate, semi-transparent, coordinated)
    final rainPaint = Paint()
      ..color = Color.lerp(Colors.white, const Color(0xFFB0BEC5), 0.3)!.withOpacity(0.42)
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
      canvas.drawLine(Offset(sx, sy), Offset(sx - w * 0.04, sy + len), rainPaint);
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
      ..color = Color.lerp(Colors.white, c, 0.3)!.withOpacity(0.18)
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
        Rect.fromCenter(center: Offset(cx, cy), width: baseRadius * 2.2, height: baseRadius * 0.65),
        Paint()
          ..color = rippleColor.withOpacity(0.25)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.0,
      );

      // Middle ring
      canvas.drawOval(
        Rect.fromCenter(center: Offset(cx, cy), width: baseRadius * 1.4, height: baseRadius * 0.42),
        Paint()
          ..color = rippleColor.withOpacity(0.55)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.2,
      );

      // Inner ripple core
      canvas.drawOval(
        Rect.fromCenter(center: Offset(cx, cy), width: baseRadius * 0.6, height: baseRadius * 0.20),
        Paint()
          ..color = rippleColor.withOpacity(0.85)
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
      ..color = Colors.white.withOpacity(0.35)
      ..strokeWidth = 1.0;

    canvas.drawLine(Offset(w * 0.38, h * 0.24), Offset(w * 0.36, h * 0.36), dropPaint);
    canvas.drawLine(Offset(w * 0.72, h * 0.54), Offset(w * 0.70, h * 0.66), dropPaint);
    canvas.drawLine(Offset(w * 0.79, h * 0.12), Offset(w * 0.78, h * 0.20), dropPaint);
    canvas.drawLine(Offset(w * 0.21, h * 0.72), Offset(w * 0.20, h * 0.80), dropPaint);
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
  bool shouldReclip(covariant _PixelatedClipper oldClipper) => oldClipper.step != step;
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
        Paint()..color = Colors.black.withOpacity(0.45),
      );
    }

    // Card fill
    final fillPath = _PixelatedClipper.createPixelPath(w, h, 0, step);
    canvas.drawPath(fillPath, Paint()..color = fillColor);

    // Subtle 3D inner bevel highlight
    final innerPath = _PixelatedClipper.createPixelPath(w, h, borderWidth * 0.5, step);
    canvas.drawPath(
      innerPath,
      Paint()
        ..color = Colors.white.withOpacity(0.12)
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
          child: Padding(
            padding: padding,
            child: child,
          ),
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
  Size getPreferredSize(bool isEnabled, bool isDiscrete) => Size(thumbSize, thumbSize + 4);

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
    final outerColor = Color.lerp(borderColor, Colors.black, 0.25) ?? borderColor;
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
        ..color = Colors.white.withOpacity(0.55)
        ..strokeWidth = 1.0,
    );
  }
}

// ─── DYNAMIC TAB THEMES FOR SHADER BUILDER ─────────────────────────────────
class _BuilderTabTheme {
  final String label;
  final VoxelIconType icon;
  final Uint8List artBytes;       // The scene image matching screenshot
  final Color primary;            // Signature accent color
  final Color bg;                 // Full app background
  final Color surface;            // Top AppBar, Tab bar header & Bottom bar
  final Color border;             // Subtle frame & divider border
  final Color cardBg;             // Darkened card background
  final List<Color> nextGradient; // Next Tab / Generate button gradient
  final Color nextBorder;         // Next Tab button border
  final Color nextShadow;         // Next Tab button glow/shadow
  final Color backBg;             // Back button background
  final Color backBorder;         // Back button border

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

  const ShaderEditorScreen({
    super.key,
    required this.uploadedShaderBytes,
    required this.uploadedShaderName,
    required this.uploadedLogoBytes,
    required this.shaderName,
  });

  @override
  State<ShaderEditorScreen> createState() => _ShaderEditorScreenState();
}

class _ShaderEditorScreenState extends State<ShaderEditorScreen>
    with TickerProviderStateMixin {
  late final TabController _tabController;

  // ── State vars ──────────────────────────────────────────────────────────
  late TextEditingController shaderNameCtrl;
  List<int>? _generatedPackBytes;
  String? _generatedPackName;
  bool _isGenerated = false;

  String _activeColorKey = 'Morning';

  // Time & Atmosphere
  Color morningColor = const Color(0xFFFF9AA2);
  Color noonColor = const Color(0xFF87CEEB);
  Color eveningColor = const Color(0xFFFFA500);
  Color nightColor = const Color(0xFF00008B);
  double sunSize = 1.0;
  double nightVision = 1.0;
  double fogDensity = 1.0;
  String volumetricRays = 'Cinematic (Heavy)';
  Color cloudTopColor = const Color(0xFFFFFFFF);
  Color cloudBottomColor = const Color(0xFFB0B4B8);
  String cloudType = 'Realistic 3D'; // 'Realistic 3D', 'Volumetric', 'Flat 2D'
  bool wavingFoliage = true;
  double foliageWaveSpeed = 1.0;
  String volumetricFogProfile = 'Cinematic'; // 'Cinematic', 'Balanced', 'Low End'
  String biomeTone = 'Dynamic'; // 'Dynamic', 'Vibrant', 'Savanna', 'Frost', 'Moody'

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
    // 0: Atmosphere (warm light brownish toasted chestnut/mocha)
    _BuilderTabTheme(
      label: 'ATMOSPHERE',
      icon: VoxelIconType.sun,
      artBytes: kTabArtAtmosphereBytes,
      primary: const Color(0xFFE5A04A),
      bg: const Color(0xFF1E150F),
      surface: const Color(0xFF2C1E15),
      border: const Color(0xFF6B4D36),
      cardBg: const Color(0xFF3A2A1E),
      nextGradient: const [Color(0xFF5A371B), Color(0xFF7E4C24)],
      nextBorder: const Color(0xFF985F33),
      nextShadow: const Color(0x22000000),
      backBg: const Color(0xFF3A2A1E),
      backBorder: const Color(0xFF7A583F),
    ),
    // 1: Lighting (less reddish, warm walnut lantern amber)
    _BuilderTabTheme(
      label: 'LIGHTING',
      icon: VoxelIconType.lantern,
      artBytes: kTabArtLightingBytes,
      primary: const Color(0xFFE5A638),
      bg: const Color(0xFF14110E),
      surface: const Color(0xFF1E1914),
      border: const Color(0xFF4C3D2B),
      cardBg: const Color(0xFF221C16),
      nextGradient: const [Color(0xFF382C18), Color(0xFF584424)],
      nextBorder: const Color(0xFF755B30),
      nextShadow: const Color(0x22000000),
      backBg: const Color(0xFF221C16),
      backBorder: const Color(0xFF5A4833),
    ),
    // 2: Water (deep oceanic cyan)
    _BuilderTabTheme(
      label: 'WATER',
      icon: VoxelIconType.waves,
      artBytes: kTabArtWaterBytes,
      primary: const Color(0xFF00BCD4),
      bg: const Color(0xFF07141E),
      surface: const Color(0xFF0D2132),
      border: const Color(0xFF1B4E73),
      cardBg: const Color(0xFF0E2234),
      nextGradient: const [Color(0xFF0E2C3A), Color(0xFF16475E)],
      nextBorder: const Color(0xFF1F5F7D),
      nextShadow: const Color(0x22000000),
      backBg: const Color(0xFF0E2234),
      backBorder: const Color(0xFF24608A),
    ),
    // 3: Weather (sleek unified dark slate gray)
    _BuilderTabTheme(
      label: 'WEATHER',
      icon: VoxelIconType.rainCloud,
      artBytes: kTabArtWeatherBytes,
      primary: const Color(0xFFA89F95),
      bg: const Color(0xFF131417),
      surface: const Color(0xFF1C1E23),
      border: const Color(0xFF424754),
      cardBg: const Color(0xFF212328),
      nextGradient: const [Color(0xFF2A2A30), Color(0xFF3C3C46)],
      nextBorder: const Color(0xFF525260),
      nextShadow: const Color(0x22000000),
      backBg: const Color(0xFF212328),
      backBorder: const Color(0xFF525A68),
    ),
  ];

  @override
  void initState() {
    super.initState();
    shaderNameCtrl = TextEditingController(text: widget.shaderName);
    _tabController = TabController(length: _tabThemes.length, vsync: this);
    _tabController.addListener(() {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    shaderNameCtrl.dispose();
    super.dispose();
  }

  // ── Helper builders ────────────────────────────────────────────────────
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
        backgroundColor: isError ? const Color(0xFF5D1E1E) : const Color(0xFF262422),
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

  /// Realistic Animated Minecraft Color Crafter Dialog
  void _pickColor(
    String title,
    Color current,
    Function(Color) onSet, {
    ShaderIconType? iconType,
  }) {
    Color tmp = current;
    final hexCtrl = TextEditingController(
      text: current.value.toRadixString(16).substring(2).toUpperCase(),
    );

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
          final curTheme = _tabThemes[_tabController.index.clamp(0, _tabThemes.length - 1)];
          final themeColor = curTheme.primary;

          return Dialog(
            backgroundColor: Colors.transparent,
            insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
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
                                  color: themeColor.withOpacity(0.40),
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
                                  color: themeColor.withOpacity(0.50),
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
                                  const AnimatedMinecraftIcon(type: VoxelIconType.sparkles, size: 16),
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
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
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
                                  border: Border.all(color: Colors.white70, width: 1),
                                ),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                '#${tmp.value.toRadixString(16).substring(2).toUpperCase()}',
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

                    // 2. 16 Minecraft Dye Palette Quick-Pick Swatches
                    const Text(
                      'MINECRAFT DYES',
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
                        final isSel = tmp.value == dyeColor.value;
                        return GestureDetector(
                          onTap: () {
                            setD(() {
                              tmp = dyeColor;
                              hexCtrl.text = dyeColor.value.toRadixString(16).substring(2).toUpperCase();
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
                                    color: dyeColor.withOpacity(0.80),
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
                                    child: Icon(Icons.check, size: 18, color: Colors.white),
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
                            hexCtrl.text = c.value.toRadixString(16).substring(2).toUpperCase();
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
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
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
                              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                              filled: true,
                              fillColor: const Color(0xFF14171A),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(6),
                                borderSide: const BorderSide(color: Color(0xFF262C33), width: 1.5),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(6),
                                borderSide: BorderSide(color: themeColor, width: 2),
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
                                side: const BorderSide(color: Color(0xFF38404A), width: 1.5),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
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
                              icon: const Icon(Icons.check, size: 18, color: Colors.black),
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
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
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
    );
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

    final titleColor = isLightBackground ? const Color(0xFF1E1006) : Colors.white;
    final badgeBg = activeColor.withOpacity(0.18);
    final badgeBorder = activeColor.withOpacity(0.45);
    final inactiveTrack = Colors.white.withOpacity(0.12);
    final sideLabelColor = isLightBackground ? const Color(0xFF381F0E) : Colors.white54;
    final centerLabelColor = activeColor;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              AnimatedMinecraftIcon(type: icon, size: 24, colorOverride: activeColor),
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
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                decoration: BoxDecoration(
                  color: badgeBg,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: badgeBorder, width: 1.2),
                  boxShadow: const [
                    BoxShadow(color: Colors.black45, blurRadius: 2, offset: Offset(0, 1)),
                  ],
                ),
                child: Text(
                  '${value.toStringAsFixed(1)}x',
                  style: TextStyle(
                    color: activeColor.computeLuminance() > 0.65 ? Colors.white : activeColor,
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
              overlayColor: activeColor.withOpacity(0.18),
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
                Text(minLabel, style: TextStyle(color: sideLabelColor, fontSize: 10, fontWeight: FontWeight.w600)),
                if (centerLabel.isNotEmpty)
                  Text(centerLabel, style: TextStyle(color: centerLabelColor, fontSize: 10, fontWeight: FontWeight.w800)),
                Text(maxLabel, style: TextStyle(color: sideLabelColor, fontSize: 10, fontWeight: FontWeight.w600)),
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
    final theme = _tabThemes[_tabController.index.clamp(0, _tabThemes.length - 1)];
    final actColor = activeColor ?? theme.primary;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          AnimatedMinecraftIcon(type: icon, size: 24, colorOverride: value ? actColor : null),
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
                    style: const TextStyle(color: Colors.white54, fontSize: 10.5),
                  ),
                ],
              ],
            ),
          ),
          Switch(
            value: value,
            activeColor: Colors.white,
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
              AnimatedMinecraftIcon(type: icon, size: 24, colorOverride: activeColor),
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
                        color: isSel ? activeColor : Colors.black.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                          color: isSel ? activeColor : activeColor.withOpacity(0.25),
                          width: 1.2,
                        ),
                        boxShadow: isSel
                            ? [
                                BoxShadow(
                                  color: activeColor.withOpacity(0.35),
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
                              ? (activeColor.computeLuminance() > 0.55 ? Colors.black87 : Colors.white)
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
              AnimatedMinecraftIcon(type: icon, size: 24, colorOverride: selectedColor),
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
                onTap: onCustomTap,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: selectedColor.withOpacity(0.20),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: selectedColor, width: 1.5),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.colorize, size: 12, color: Colors.white70),
                      const SizedBox(width: 4),
                      Text(
                        '#${selectedColor.value.toRadixString(16).substring(2).toUpperCase()}',
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
                final isSel = selectedColor.value == c.value;
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 3),
                    child: GestureDetector(
                      onTap: () => onChanged(c),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 150),
                        height: 38,
                        decoration: BoxDecoration(
                          color: c,
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                            color: isSel ? Colors.white : const Color(0xFF060D17),
                            width: isSel ? 2.5 : 1.5,
                          ),
                          boxShadow: [
                            if (isSel)
                              BoxShadow(
                                color: c.withOpacity(0.80),
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
                                child: Icon(Icons.check, size: 18, color: Colors.white),
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
                    color: Colors.black.withOpacity(0.55),
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
                    child: AnimatedMinecraftIcon(type: VoxelIconType.lightbulb, size: 20),
                  ),
                  // Rich Text: Pink "Tip: " + Cream Message
                  Expanded(
                    child: Text.rich(
                      TextSpan(
                        children: [
                          const TextSpan(
                            text: 'Tip: ',
                            style: TextStyle(
                              color: Color(0xFFF06292), // Bright pink matching screenshot
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

  /// Interactive Water Preview Banner matching Screen 4 in reference
  Widget _buildWaterPreviewBanner() {
    return Container(
      height: 120,
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFF00E5FF).withOpacity(0.4), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF00E5FF).withOpacity(0.15),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: Stack(
          children: [
            Positioned.fill(
              child: Image.memory(
                waterLakeBannerBytes,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Image.asset(
                    'assets/minecraft_shader_lake.jpg',
                    fit: BoxFit.cover,
                    errorBuilder: (ctx, err, st) {
                      return CustomPaint(
                        painter: _RealisticShaderPainter(
                          type: ShaderIconType.noon,
                          color: waterColor,
                        ),
                      );
                    },
                  );
                },
              ),
            ),
            Positioned(
              left: 12,
              bottom: 8,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    AnimatedMinecraftIcon(type: VoxelIconType.sparkles, size: 12),
                    SizedBox(width: 4),
                    Text(
                      'PIGLIX WATER SHADER (LIVE)',
                      style: TextStyle(
                        color: Color(0xFF00E5FF),
                        fontSize: 9.5,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.8,
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

  // TAB 1: ATMOSPHERE (Matching Screen 2 in reference with warm rich light brownish tone)
  Widget _tabAtmosphere() {
    // Tab 1: Solid Warm Light Brownish (toasted chestnut / mocha)
    const cardBg = Color(0xFF3A2A1E);
    const cardBorder = Color(0xFF7A583F);
    const dividerColor = Color(0xFF543E2E);
    const tabAccent = Color(0xFFE5A04A);

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 90),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 1. Top Card with Stepped Pixelated Corners in warm brownish tone
          PixelatedCard(
            backgroundColor: cardBg,
            borderColor: cardBorder,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Row(
                  children: [
                    AnimatedMinecraftIcon(type: VoxelIconType.sun, size: 30, colorOverride: tabAccent),
                    SizedBox(width: 10),
                    Expanded(
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
                // 4 Time of Day Cards: Morning, Noon, Evening, Night (with extra spacing between them)
                MinecraftColorGrid(
                  title: '',
                  gap: 14.0,
                  tiles: [
                    _colorRow('Morning', 'Sunrise sky tint', morningColor, (c) => morningColor = c, iconType: ShaderIconType.morning, labelColor: Colors.white70, aspectRatio: 1.0),
                    _colorRow('Noon', 'Midday sky tint', noonColor, (c) => noonColor = c, iconType: ShaderIconType.noon, labelColor: Colors.white70, aspectRatio: 1.0),
                    _colorRow('Evening', 'Sunset sky tint', eveningColor, (c) => eveningColor = c, iconType: ShaderIconType.evening, labelColor: Colors.white70, aspectRatio: 1.0),
                    _colorRow('Night', 'Midnight sky tint', nightColor, (c) => nightColor = c, iconType: ShaderIconType.night, labelColor: Colors.white70, aspectRatio: 1.0),
                  ],
                ),
              ],
            ),
          ),

          // 2. Bottom Card: Warm Brownish with Stepped Pixelated Corners
          PixelatedCard(
            backgroundColor: cardBg,
            borderColor: cardBorder,
            child: Column(
              children: [
                // Sun Size Slider
                _buildMinecraftSlider(
                  icon: VoxelIconType.sun,
                  title: 'Sun Size',
                  value: sunSize,
                  min: 0.0,
                  max: 2.0,
                  divisions: 20,
                  minLabel: 'Smaller',
                  centerLabel: 'Default (1.0x)',
                  maxLabel: 'Bigger',
                  activeColor: tabAccent,
                  onChanged: (v) => sunSize = v,
                ),
                Container(height: 1.5, color: dividerColor, margin: const EdgeInsets.symmetric(vertical: 8)),

                // Night Brightness Slider
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
                  onChanged: (v) => nightVision = v,
                ),
                Container(height: 1.5, color: dividerColor, margin: const EdgeInsets.symmetric(vertical: 8)),

                // Fog Density Slider
                _buildMinecraftSlider(
                  icon: VoxelIconType.cloud,
                  title: 'Fog Density',
                  value: fogDensity,
                  min: 0.0,
                  max: 2.0,
                  divisions: 20,
                  minLabel: 'Clear',
                  centerLabel: 'Default (1.0x)',
                  maxLabel: 'Thick',
                  activeColor: tabAccent,
                  onChanged: (v) => fogDensity = v,
                ),
                Container(height: 1.5, color: dividerColor, margin: const EdgeInsets.symmetric(vertical: 8)),

                // 1. CLOUDS STYLE (Realistic 3D / Volumetric / Flat 2D)
                _buildMinecraftSegmented(
                  icon: VoxelIconType.cloud,
                  title: 'Clouds Style',
                  items: const ['Realistic 3D', 'Volumetric', 'Flat 2D'],
                  selected: cloudType,
                  activeColor: tabAccent,
                  onChanged: (v) => setState(() => cloudType = v),
                ),
              ],
            ),
          ),

          // Steve Tip Banner
          _buildSteveTipBanner('Tip: Try different times to see how your world feels!'),
        ],
      ),
    );
  }

  // TAB 2: LIGHTING (Matching Screen 3 in reference)
  Widget _tabLighting() {
    const tabAccent = Color(0xFFE5A638);
    const cardBg = Color(0xFF221C16);
    const cardBorder = Color(0xFF5A4833);
    const dividerColor = Color(0xFF3E3120);

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
                const Row(
                  children: [
                    AnimatedMinecraftIcon(type: VoxelIconType.lantern, size: 28, colorOverride: tabAccent),
                    SizedBox(width: 10),
                    Expanded(
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
                            style: TextStyle(color: Colors.white54, fontSize: 11),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                // 2 Visual Scene Cards: Soft Fog, Torch Light (Square shape as requested)
                MinecraftColorGrid(
                  title: '',
                  gap: 16.0,
                  tiles: [
                    _colorRow('Soft Fog', 'Atmospheric mist', fogColor, (c) => fogColor = c, iconType: ShaderIconType.fog, aspectRatio: 1.0),
                    _colorRow('Torch Light', 'Warm point lighting', torchLightColor, (c) => torchLightColor = c, iconType: ShaderIconType.torch, aspectRatio: 1.0),
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
                Container(height: 1, color: dividerColor, margin: const EdgeInsets.symmetric(vertical: 8)),

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
                Container(height: 1, color: dividerColor, margin: const EdgeInsets.symmetric(vertical: 8)),

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
                Container(height: 1, color: dividerColor, margin: const EdgeInsets.symmetric(vertical: 8)),

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
                const Row(
                  children: [
                    AnimatedMinecraftIcon(type: VoxelIconType.sun, size: 28, colorOverride: tabAccent),
                    SizedBox(width: 10),
                    Expanded(
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
                            style: TextStyle(color: Colors.white54, fontSize: 11),
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

  // TAB 3: WATER & REFLECTIONS (Matching Screen 4 in reference)
  Widget _tabWorld() {
    const tabAccent = Color(0xFF00BCD4);
    const cardBg = Color(0xFF0E2234);
    const cardBorder = Color(0xFF24608A);
    const dividerColor = Color(0xFF183D59);

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
                const Row(
                  children: [
                    AnimatedMinecraftIcon(type: VoxelIconType.waves, size: 28, colorOverride: tabAccent),
                    SizedBox(width: 10),
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
                            style: TextStyle(color: Color(0xFF80DEEA), fontSize: 11),
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
                  onChanged: (c) => waterColor = c,
                  onCustomTap: () => _pickColor('Water Tint', waterColor, (c) => waterColor = c, iconType: ShaderIconType.water),
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
                Container(height: 1, color: dividerColor, margin: const EdgeInsets.symmetric(vertical: 8)),

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
          _buildSteveTipBanner('Tip: Adjust caustics and wave speed for realistic currents!'),
        ],
      ),
    );
  }

  // TAB 4: WEATHER & POST-FX
  Widget _tabWeather() {
    const tabAccent = Color(0xFFA89F95);
    const weatherCardBg = Color(0xFF212328);
    const weatherCardBorder = Color(0xFF525A68);
    const weatherDivider = Color(0xFF363B44);

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
                const Row(
                  children: [
                    AnimatedMinecraftIcon(type: VoxelIconType.rainCloud, size: 28, colorOverride: tabAccent),
                    SizedBox(width: 10),
                    Expanded(
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
                            style: TextStyle(color: Colors.white54, fontSize: 11),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                // 2 Visual Cards: Rain Fog & Rain Water
                MinecraftColorGrid(
                  title: '',
                  tiles: [
                    _colorRow('Rain Fog', 'Atmospheric haze during rain', rainFogColor, (c) => rainFogColor = c, iconType: ShaderIconType.rainFog),
                    _colorRow('Rain Water', 'Water color during rain', rainWaterColor, (c) => rainWaterColor = c, iconType: ShaderIconType.rainWater),
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
                const Row(
                  children: [
                    AnimatedMinecraftIcon(type: VoxelIconType.cubeMirror, size: 28, colorOverride: tabAccent),
                    SizedBox(width: 10),
                    Expanded(
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
                            style: TextStyle(color: Colors.white54, fontSize: 11),
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
                  subtitle: 'Real-time reflections of sky and surrounding blocks',
                  value: worldReflectionsEnabled,
                  activeColor: tabAccent,
                  onChanged: (v) => worldReflectionsEnabled = v,
                ),
                Container(height: 1, color: weatherDivider, margin: const EdgeInsets.symmetric(vertical: 8)),

                // PBR Bump Mapping Toggle
                _buildMinecraftToggle(
                  icon: VoxelIconType.pbrLayers,
                  title: 'PBR Bump Mapping',
                  subtitle: 'Normal and roughness relief depth on all blocks',
                  value: enablePBR,
                  activeColor: tabAccent,
                  onChanged: (v) => enablePBR = v,
                ),
                Container(height: 1, color: weatherDivider, margin: const EdgeInsets.symmetric(vertical: 8)),

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
                Container(height: 1, color: weatherDivider, margin: const EdgeInsets.symmetric(vertical: 8)),

                // Waving Foliage Toggle
                _buildMinecraftToggle(
                  icon: VoxelIconType.grassBlock,
                  title: 'Waving Foliage',
                  subtitle: 'Wind-swaying animation for leaves, grass, crops & vines',
                  value: wavingFoliage,
                  activeColor: tabAccent,
                  onChanged: (v) => wavingFoliage = v,
                ),

                if (wavingFoliage) ...[
                  Container(height: 1, color: weatherDivider, margin: const EdgeInsets.symmetric(vertical: 8)),
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
                const Row(
                  children: [
                    AnimatedMinecraftIcon(type: VoxelIconType.film, size: 28, colorOverride: tabAccent),
                    SizedBox(width: 10),
                    Expanded(
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
                            style: TextStyle(color: Colors.white54, fontSize: 11),
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
                Container(height: 1, color: weatherDivider, margin: const EdgeInsets.symmetric(vertical: 8)),

                // Biome-wise Tone (Dynamic / Vibrant / Savanna / Frost / Moody)
                _buildMinecraftSegmented(
                  icon: VoxelIconType.palette,
                  title: 'Biome-wise Tone',
                  items: const ['Dynamic', 'Vibrant', 'Savanna', 'Frost', 'Moody'],
                  selected: biomeTone,
                  activeColor: tabAccent,
                  onChanged: (v) => setState(() => biomeTone = v),
                ),
              ],
            ),
          ),

          // Steve Tip Banner
          _buildSteveTipBanner('Tip: Select ACES tone mapping with Dynamic biome tone for cinematic color depth!'),
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
    final curTheme = _tabThemes[_tabController.index.clamp(0, _tabThemes.length - 1)];
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
        _pickColor(effectiveTitle, color, onSet, iconType: iconType);
      },
    );
  }

  // ── BUILD APPBAR & SCAFFOLD (SMOOTH DYNAMIC THEME PER TAB) ───────────────
  @override
  Widget build(BuildContext context) {
    final curTheme = _tabThemes[_tabController.index.clamp(0, _tabThemes.length - 1)];

    return Scaffold(
      backgroundColor: curTheme.bg,
      appBar: AppBar(
        backgroundColor: curTheme.surface,
        elevation: 0,
        toolbarHeight: 52,
        titleSpacing: 0,
        leadingWidth: 50,
        // Themed back button
        leading: Padding(
          padding: const EdgeInsets.only(left: 10),
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
              icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 16),
              padding: EdgeInsets.zero,
              onPressed: () => Navigator.pop(context),
            ),
          ),
        ),
        // Wooden Plank Sign: "PIGLIX STUDIO" with themed border
        title: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
          decoration: BoxDecoration(
            color: curTheme.cardBg,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: curTheme.primary.withOpacity(0.5), width: 1.5),
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.5), blurRadius: 4, offset: const Offset(0, 2)),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: curTheme.primary, width: 1.2),
                ),
                clipBehavior: Clip.antiAlias,
                child: Image.memory(kPiglixLogoBytes, fit: BoxFit.cover),
              ),
              const SizedBox(width: 8),
              Text(
                'PIGLIX STUDIO',
                style: TextStyle(
                  color: curTheme.primary,
                  fontWeight: FontWeight.w900,
                  fontFamily: 'monospace',
                  fontSize: 13,
                  letterSpacing: 1.5,
                ),
              ),
            ],
          ),
        ),
        centerTitle: true,
        // Exactly 4 Tabs with AI Scene Art & Pixelated Button Frames (compact & visible border)
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(62),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            height: 62,
            padding: const EdgeInsets.only(left: 8, right: 8, top: 4, bottom: 9),
            decoration: BoxDecoration(
              color: curTheme.surface,
              border: Border(bottom: BorderSide(color: curTheme.border)),
            ),
            child: Row(
              children: List.generate(_tabThemes.length, (idx) {
                final tab = _tabThemes[idx];
                final isSel = _tabController.index == idx;
                final activeColor = tab.primary;
                const unselBorder = Color(0xFF68707E); // Clearly visible crisp border

                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4.5),
                    child: GestureDetector(
                      onTap: () => setState(() => _tabController.animateTo(idx)),
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
                                        Colors.black.withOpacity(0.70),
                                        Colors.black.withOpacity(0.92),
                                      ],
                                      begin: Alignment.topCenter,
                                      end: Alignment.bottomCenter,
                                    ),
                                  ),
                                  alignment: Alignment.center,
                                  padding: const EdgeInsets.symmetric(horizontal: 2),
                                  child: FittedBox(
                                    fit: BoxFit.scaleDown,
                                    child: Text(
                                      tab.label,
                                      style: TextStyle(
                                        color: isSel ? const Color(0xFFFFF3D0) : const Color(0xFFCAD4DF),
                                        fontFamily: 'Minecraft',
                                        fontSize: 8.0,
                                        fontWeight: isSel ? FontWeight.w900 : FontWeight.w700,
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
                                Icon(Icons.play_arrow_rounded, size: 22, color: Colors.white),
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
                    style: TextStyle(color: curTheme.primary, fontSize: 12, fontWeight: FontWeight.w600),
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
                      onPressed: () => setState(() => _tabController.animateTo(_tabController.index - 1)),
                      icon: const Icon(Icons.arrow_back_rounded, size: 18, color: Colors.white70),
                      label: const Text('Back', style: TextStyle(color: Colors.white70, fontWeight: FontWeight.w700)),
                      style: OutlinedButton.styleFrom(
                        backgroundColor: curTheme.backBg,
                        side: BorderSide(color: curTheme.backBorder),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
                          color: Colors.black.withOpacity(0.40),
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
                            : () => setState(() => _tabController.animateTo(_tabController.index + 1)),
                        borderRadius: BorderRadius.circular(12),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              isLastTab ? Icons.auto_awesome_rounded : Icons.arrow_forward_rounded,
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
      builder: (_) {
        final ValueNotifier<double> progressN = ValueNotifier<double>(0.1);
        final ValueNotifier<String> statusN = ValueNotifier<String>('Initializing Piglix Engine...');

        _doCompile(progressN, statusN);

        return Dialog(
          backgroundColor: _surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
            side: const BorderSide(color: _border),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const AnimatedMinecraftIcon(type: VoxelIconType.grassBlock, size: 48),
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
                  builder: (_, v, __) => ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: LinearProgressIndicator(
                      value: v,
                      backgroundColor: Colors.black45,
                      color: _green,
                      minHeight: 8,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                ValueListenableBuilder<String>(
                  valueListenable: statusN,
                  builder: (_, s, __) => Text(
                    s,
                    style: const TextStyle(color: Colors.white60, fontSize: 12),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _doCompile(
    ValueNotifier<double> progressN,
    ValueNotifier<String> statusN,
  ) async {
    try {
      await Future.delayed(const Duration(milliseconds: 200));
      progressN.value = 0.15;
      statusN.value = 'Loading Render Dragon materials & base configs...';

      Archive sourceArchive;
      if (widget.uploadedShaderBytes != null && widget.uploadedShaderBytes!.isNotEmpty) {
        sourceArchive = ZipDecoder().decodeBytes(widget.uploadedShaderBytes!);
      } else {
        final byteData = await rootBundle.load('assets/base_shader.zip');
        sourceArchive = ZipDecoder().decodeBytes(byteData.buffer.asUint8List());
      }

      final fileMap = <String, ArchiveFile>{};
      for (final file in sourceArchive) {
        if (file.isFile) {
          fileMap[file.name] = file;
        }
      }

      await Future.delayed(const Duration(milliseconds: 200));
      progressN.value = 0.35;
      statusN.value = 'Configuring Waving Foliage & Clouds...';

      // 1. Foliage Waving Material Injection
      if (!wavingFoliage && fileMap.containsKey('subpacks/no_wave/renderer/materials/RenderChunk.material.bin')) {
        final noWaveChunk = fileMap['subpacks/no_wave/renderer/materials/RenderChunk.material.bin']!;
        fileMap['renderer/materials/RenderChunk.material.bin'] = ArchiveFile(
          'renderer/materials/RenderChunk.material.bin',
          noWaveChunk.size,
          noWaveChunk.content,
        );
      }

      // 2. Cloud Material & Style Injection
      if (cloudType == 'Flat 2D' && fileMap.containsKey('subpacks/box_clouds/renderer/materials/Clouds.material.bin')) {
        final boxCloud = fileMap['subpacks/box_clouds/renderer/materials/Clouds.material.bin']!;
        fileMap['renderer/materials/Clouds.material.bin'] = ArchiveFile(
          'renderer/materials/Clouds.material.bin',
          boxCloud.size,
          boxCloud.content,
        );
      } else if (cloudType == 'Realistic 3D' && fileMap.containsKey('subpacks/realistic_clouds/renderer/materials/Clouds.material.bin')) {
        final realCloud = fileMap['subpacks/realistic_clouds/renderer/materials/Clouds.material.bin']!;
        fileMap['renderer/materials/Clouds.material.bin'] = ArchiveFile(
          'renderer/materials/Clouds.material.bin',
          realCloud.size,
          realCloud.content,
        );
      }

      await Future.delayed(const Duration(milliseconds: 200));
      progressN.value = 0.55;
      statusN.value = 'Injecting Torch, Water & Lighting JSONs...';

      // 3. Torch & Lantern Light Color (point_lights/global.json)
      final torchHex = '#${torchLightColor.value.toRadixString(16).padLeft(8, '0').substring(2)}';
      Map<String, dynamic> pointLights = {
        'format_version': '1.21.40',
        'minecraft:point_light_settings': {
          'colors': {
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
          }
        }
      };
      if (fileMap.containsKey('point_lights/global.json')) {
        try {
          final existing = jsonDecode(utf8.decode(fileMap['point_lights/global.json']!.content as List<int>)) as Map<String, dynamic>;
          if (existing['minecraft:point_light_settings'] != null && existing['minecraft:point_light_settings']['colors'] != null) {
            existing['minecraft:point_light_settings']['colors']['minecraft:torch'] = torchHex;
            existing['minecraft:point_light_settings']['colors']['minecraft:lantern'] = torchHex;
            pointLights = existing;
          }
        } catch (_) {}
      }
      final plBytes = utf8.encode(jsonEncode(pointLights));
      fileMap['point_lights/global.json'] = ArchiveFile('point_lights/global.json', plBytes.length, plBytes);

      // 4. Water Waves, Caustics & Transparency (water/water.json)
      final waterTransparency = waterQuality == 'Ultra'
          ? 0.85
          : (waterQuality == 'High' ? 0.70 : (waterQuality == 'Medium' ? 0.55 : 0.40));
      final waterSpeed = (windSpeed * 2.8).clamp(0.5, 6.0);
      final waterFreq = (windSpeed * 1.0).clamp(0.2, 3.0);
      Map<String, dynamic> waterSettings = {
        'format_version': '1.21.40',
        'minecraft:water_settings': {
          'description': {'identifier': 'piglix:water_settings'},
          'particle_concentrations': {
            'chlorophyll': ((1.0 - waterTransparency) * 0.04).clamp(0.001, 0.1),
            'suspended_sediment': 0.0,
            'cdom': 0.0,
          },
          'caustics': {
            'enabled': underwaterCaustics,
            'frame_length': 0.066,
            'texture': 'textures/caustic/caustics.png',
            'scale': 0.37,
            'power': 2.0,
          },
          'waves': {
            'enabled': true,
            'depth': 0.15,
            'frequency': waterFreq,
            'frequency_scaling': 1.2,
            'mix': 0.18,
            'octaves': 3,
            'pull': 0.37,
            'sampleWidth': 0.01,
            'shape': 2.989,
            'speed': waterSpeed,
            'speed_scaling': 1.02,
          }
        }
      };
      final wBytes = utf8.encode(jsonEncode(waterSettings));
      fileMap['water/water.json'] = ArchiveFile('water/water.json', wBytes.length, wBytes);

      // 5. Biome Water Surface Color & Transparency across all biomes
      for (final key in fileMap.keys.toList()) {
        if (key.startsWith('biomes/') && key.endsWith('.client_biome.json')) {
          try {
            final bData = jsonDecode(utf8.decode(fileMap[key]!.content as List<int>)) as Map<String, dynamic>;
            final bSettings = bData['minecraft:client_biome'] ?? bData;
            if (bSettings != null) {
              bSettings['water_surface_color'] = [waterColor.red, waterColor.green, waterColor.blue];
              bSettings['water_surface_transparency'] = waterTransparency;
              final bBytes = utf8.encode(jsonEncode(bData));
              fileMap[key] = ArchiveFile(key, bBytes.length, bBytes);
            }
          } catch (_) {}
        }
      }

      // 6. Color Grading (Tone mapping operator, Contrast, Saturation, Gamma)
      final op = toneMapFilter.toLowerCase() == 'reinhard'
          ? 'reinhard'
          : (toneMapFilter.toLowerCase() == 'filmic' ? 'filmic' : 'aces');
      Map<String, dynamic> colorGrading = {
        'format_version': '1.21.40',
        'minecraft:color_grading_settings': {
          'description': {'identifier': 'piglix:color_grading'},
          'color_grading': {
            'highlights': {
              'contrast': [contrast, contrast, contrast],
              'saturation': [globalSaturation, globalSaturation, globalSaturation],
              'gain': [1.2, 1.2, 1.2],
              'gamma': [2.5, 2.5, 2.5],
            },
            'midtones': {
              'contrast': [contrast, contrast, contrast],
              'saturation': [globalSaturation, globalSaturation, globalSaturation],
              'gain': [1.2, 1.2, 1.2],
              'gamma': [2.5, 2.5, 2.5],
            },
            'shadows': {
              'contrast': [contrast, contrast, contrast],
              'saturation': [globalSaturation, globalSaturation, globalSaturation],
              'gain': [1.1, 1.1, 1.1],
              'gamma': [2.5, 2.5, 2.5],
            }
          },
          'tone_mapping': {'operator': op}
        }
      };
      final cgBytes = utf8.encode(jsonEncode(colorGrading));
      fileMap['color_grading/color_grading.json'] = ArchiveFile('color_grading/color_grading.json', cgBytes.length, cgBytes);

      // 7. Directional Sun & Moon Illuminance & Sky Color (lighting/global.json)
      final sunIllum = (90.0 * lightIntensity).clamp(10.0, 200.0);
      final moonIllum = (0.5 * (nightVision + 0.2)).clamp(0.1, 15.0);
      Map<String, dynamic> lightingGlobal = {
        'format_version': '1.21.70',
        'minecraft:lighting_settings': {
          'description': {'identifier': 'piglix:global_lighting'},
          'directional_lights': {
            'sun': {
              'illuminance': {
                '0.0': sunIllum,
                '0.19': sunIllum,
                '0.22': sunIllum * 0.65,
                '0.25': 1.0,
                '0.75': sunIllum * 0.35,
                '0.795': sunIllum,
                '0.81': sunIllum,
              },
              'color': {
                '0.0': [noonColor.red, noonColor.green, noonColor.blue],
                '0.18': [noonColor.red, noonColor.green, noonColor.blue],
                '0.22': [eveningColor.red, eveningColor.green, eveningColor.blue],
                '0.25': [eveningColor.red, (eveningColor.green * 0.6).round(), (eveningColor.blue * 0.3).round()],
                '0.75': [morningColor.red, morningColor.green, morningColor.blue],
                '0.81': [noonColor.red, noonColor.green, noonColor.blue],
              }
            },
            'moon': {
              'illuminance': {
                '0.3': moonIllum,
                '0.5': moonIllum,
                '0.7': moonIllum,
              },
              'color': {
                '0.3': [nightColor.red, nightColor.green, nightColor.blue],
                '0.5': [nightColor.red, nightColor.green, nightColor.blue],
                '0.7': [nightColor.red, nightColor.green, nightColor.blue],
              }
            }
          }
        }
      };
      final lgBytes = utf8.encode(jsonEncode(lightingGlobal));
      fileMap['lighting/global.json'] = ArchiveFile('lighting/global.json', lgBytes.length, lgBytes);

      // 8. Atmospherics: Sky Zenith & Horizon Colors, God Rays (atmospherics/atmospherics.json)
      final mieGodRays = (3.5 * lightIntensity).clamp(1.0, 9.0);
      Map<String, dynamic> atmosphereJson = {
        'format_version': '1.21.40',
        'minecraft:atmosphere_settings': {
          'description': {'identifier': 'piglix:atmosphere_settings'},
          'rayleigh_strength': {
            '0.0': (0.9 * fogDensity).clamp(0.2, 3.0),
            '0.25': (0.6 * fogDensity).clamp(0.2, 2.5),
            '0.75': (0.6 * fogDensity).clamp(0.2, 2.5),
            '0.81': (0.9 * fogDensity).clamp(0.2, 3.0),
          },
          'sun_mie_strength': {
            '0.0': mieGodRays,
            '0.22': mieGodRays * 1.3,
            '0.25': mieGodRays * 1.5,
            '0.75': mieGodRays * 1.5,
            '0.81': mieGodRays,
          },
          'moon_mie_strength': {
            '0.3': 1.5,
            '0.5': 2.0,
            '0.7': 1.5,
          },
          'sun_glare_shape': {
            '0.0': (5.0 * sunSize).clamp(1.0, 15.0),
            '0.25': (5.0 * sunSize).clamp(1.0, 15.0),
            '0.75': (5.0 * sunSize).clamp(1.0, 15.0),
          },
          'sky_zenith_color': {
            '0.0': [noonColor.red, noonColor.green, noonColor.blue],
            '0.22': [eveningColor.red, eveningColor.green, eveningColor.blue],
            '0.67': [nightColor.red, nightColor.green, nightColor.blue],
            '0.75': [morningColor.red, morningColor.green, morningColor.blue],
          },
          'sky_horizon_color': {
            '0.0': [noonColor.red, noonColor.green, noonColor.blue],
            '0.22': [eveningColor.red, eveningColor.green, eveningColor.blue],
            '0.67': [nightColor.red, nightColor.green, nightColor.blue],
            '0.75': [morningColor.red, morningColor.green, morningColor.blue],
          }
        }
      };
      final atmBytes = utf8.encode(jsonEncode(atmosphereJson));
      fileMap['atmospherics/atmospherics.json'] = ArchiveFile('atmospherics/atmospherics.json', atmBytes.length, atmBytes);

      // 9. Shadows & PBR Settings
      Map<String, dynamic> shadowSettings = {
        'format_version': '1.21.40',
        'minecraft:shadow_settings': {
          'description': {'identifier': 'piglix:shadow_settings'},
          'point_light_shadows': enablePointLightShadows,
          'shadow_quality': shadowQuality.toLowerCase(),
        }
      };
      final shBytes = utf8.encode(jsonEncode(shadowSettings));
      fileMap['shadows/global.json'] = ArchiveFile('shadows/global.json', shBytes.length, shBytes);

      Map<String, dynamic> pbrSettings = {
        'format_version': '1.21.40',
        'minecraft:pbr_settings': {
          'description': {'identifier': 'piglix:pbr_settings'},
          'enabled': enablePBR,
        }
      };
      final pbrBytes = utf8.encode(jsonEncode(pbrSettings));
      fileMap['pbr/global.json'] = ArchiveFile('pbr/global.json', pbrBytes.length, pbrBytes);

      // 10. Pack Icon
      final iconBytes = widget.uploadedLogoBytes ?? kPiglixLogoBytes;
      fileMap['pack_icon.png'] = ArchiveFile('pack_icon.png', iconBytes.length, iconBytes);

      // 11. Manifest.json
      final packUuid = const Uuid().v4();
      final moduleUuid = const Uuid().v4();
      String pName = shaderNameCtrl.text.trim().isEmpty ? 'Piglix Shader' : shaderNameCtrl.text.trim();
      final manifestJson = jsonEncode({
        'format_version': 2,
        'header': {
          'name': pName,
          'description': 'Piglix Vibrant Engine · Ultra Bedrock Shader\n§aWaving Plants & Water · 3D Clouds · Custom Sky & Lighting',
          'uuid': packUuid,
          'version': [1, 0, 0],
          'min_engine_version': [1, 21, 0],
        },
        'modules': [
          {
            'type': 'resources',
            'uuid': moduleUuid,
            'version': [1, 0, 0],
          }
        ],
        'capabilities': ['raytraced'],
        'subpacks': [
          {'folder_name': 'realistic_clouds', 'name': 'Realistic 3D Clouds', 'memory_tier': 2},
          {'folder_name': 'rounded_clouds', 'name': 'Rounded Clouds', 'memory_tier': 1},
          {'folder_name': 'box_clouds', 'name': 'Classic Box Clouds', 'memory_tier': 1},
          {'folder_name': 'chunk_anim', 'name': 'Chunk Loading Animation', 'memory_tier': 1},
          {'folder_name': 'no_wave', 'name': 'No Waves (Low-End / High FPS)', 'memory_tier': 0},
          {'folder_name': 'no_fog', 'name': 'Clear Sky (No Fog)', 'memory_tier': 1},
          {'folder_name': 'default', 'name': 'Default Balanced', 'memory_tier': 1},
        ],
      });
      final mBytes = utf8.encode(manifestJson);
      fileMap['manifest.json'] = ArchiveFile('manifest.json', mBytes.length, mBytes);

      // 12. Subpacks.json
      final subpackJson = jsonEncode({
        'subpacks': [
          {'folder_name': 'realistic_clouds', 'name': 'Realistic 3D Clouds', 'memory_tier': 2},
          {'folder_name': 'rounded_clouds', 'name': 'Rounded Clouds', 'memory_tier': 1},
          {'folder_name': 'box_clouds', 'name': 'Classic Box Clouds', 'memory_tier': 1},
          {'folder_name': 'chunk_anim', 'name': 'Chunk Loading Animation', 'memory_tier': 1},
          {'folder_name': 'no_wave', 'name': 'No Waves (Low-End / High FPS)', 'memory_tier': 0},
          {'folder_name': 'no_fog', 'name': 'Clear Sky (No Fog)', 'memory_tier': 1},
          {'folder_name': 'default', 'name': 'Default Balanced', 'memory_tier': 1},
        ]
      });
      final spBytes = utf8.encode(subpackJson);
      fileMap['subpacks.json'] = ArchiveFile('subpacks.json', spBytes.length, spBytes);

      await Future.delayed(const Duration(milliseconds: 300));
      progressN.value = 0.85;
      statusN.value = 'Packaging MCPACK with Render Dragon binaries...';

      final finalArchive = Archive();
      for (final f in fileMap.values) {
        finalArchive.addFile(f);
      }
      final encoded = ZipEncoder().encode(finalArchive);

      await Future.delayed(const Duration(milliseconds: 300));
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
      _snack('📦 .mcpack downloaded! Open from Downloads to install in Minecraft.');
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
