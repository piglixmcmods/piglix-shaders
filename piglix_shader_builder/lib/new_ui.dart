// new_ui.dart  — Piglix Shader Studio v2  (beautiful redesign)
// Home screen → "OPEN EDITOR" grid cards → tabbed shader editor

import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:archive/archive.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart' show compute;
import 'minecraft_icons.dart';
import 'my_shaders_screen.dart';
import 'hero_sunset_bytes.dart';
import 'theme_controller.dart';
import 'shader_presets.dart';
import 'vv_import.dart';
import 'vv_shader_editor.dart';
import 'vv_guide_modal.dart';
import 'vv_global_nav_bar.dart';

export 'vv_shader_editor.dart' show ShaderEditorScreen;

Archive _decodeZipBytesWorker(List<int> bytes) =>
    ZipDecoder().decodeBytes(bytes);

// ─── OBSIDIAN & EMERALD PALETTE (MATCHING HOME SCREEN) ────────────────────────
const _green = Color(0xFF22C55E);
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
  }

  void _showWelcomeOnboardingSheet() {
    showMinecraftGuideModal(context);
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
    fastPush(
      context,
      ShaderEditorScreen(
        uploadedShaderBytes: _uploadedShaderBytes,
        uploadedShaderName: _uploadedShaderName,
        uploadedLogoBytes: _uploadedLogoBytes,
        shaderName: _shaderNameCtrl.text.trim().isEmpty
            ? 'Piglix Shader'
            : _shaderNameCtrl.text.trim(),
      ),
    );
  }

  Widget _buildMyShadersScreen() {
    return MyShadersScreen(
      onEditShader: (name) {
        setState(() {
          _shaderNameCtrl.text = name;
        });
        _openEditor();
      },
      onEditShaderItem: (item) async {
        final bytes = await item.loadBytes();
        if (!mounted) return;
        if (bytes != null && bytes.isNotEmpty) {
          try {
            final archive = await compute(_decodeZipBytesWorker, bytes);
            final parsed = parseVVPackFromArchive(
              archive,
              fallbackName: item.name,
            );
            if (!mounted) return;
            final finalName =
                parsed.importedPackName ?? parsed.config.packName;
            final itemIcon = parsed.packIconBytes ??
                await generateShaderItemPackIcon(finalName, item.previewColor);
            if (!mounted) return;
            setState(() {
              _uploadedShaderBytes = bytes;
              _uploadedShaderName = '$finalName.mcpack';
              _uploadedLogoBytes = itemIcon;
              _uploadedLogoName = '$finalName Icon';
              _shaderNameCtrl.text = finalName;
            });
            fastPush(
              context,
              ShaderEditorScreen(
                uploadedShaderBytes: bytes,
                uploadedShaderName: '$finalName.mcpack',
                uploadedLogoBytes: itemIcon,
                shaderName: finalName,
                initialVVConfig: parsed.config,
                migrationNotice: parsed.legacyMigration?.userNotice,
              ),
            );
            return;
          } catch (_) {}
        }
        final fallbackIcon =
            await generateShaderItemPackIcon(item.name, item.previewColor);
        if (!mounted) return;
        setState(() {
          _shaderNameCtrl.text = item.name;
          _uploadedLogoBytes = fallbackIcon;
        });
        fastPush(
          context,
          ShaderEditorScreen(
            uploadedShaderBytes: _uploadedShaderBytes,
            uploadedShaderName: _uploadedShaderName,
            uploadedLogoBytes: fallbackIcon,
            shaderName: item.name,
          ),
        );
      },
      onStartNew: _openEditor,
      onOpenPresets: () {
        fastPushReplacement(context, _buildPresetsScreen());
      },
      onOpenSettings: () {
        _scaffoldKey.currentState?.openDrawer();
      },
    );
  }

  Widget _buildPresetsScreen() {
    return ShaderPresetsScreen(
      onSelectPreset: (preset) async {
        final iconBytes = await getOrGeneratePresetPackIcon(preset);
        if (!mounted) return;
        setState(() {
          _shaderNameCtrl.text = preset.name;
          _uploadedLogoBytes = iconBytes;
          _uploadedLogoName = '${preset.name} Icon';
        });
        fastPush(
          context,
          ShaderEditorScreen(
            uploadedShaderBytes: _uploadedShaderBytes,
            uploadedShaderName: _uploadedShaderName,
            uploadedLogoBytes: iconBytes,
            shaderName: preset.name,
            presetConfig: preset,
          ),
        );
      },
      onOpenBuilder: _openEditor,
      onOpenGallery: () {
        fastPushReplacement(context, _buildMyShadersScreen());
      },
      onOpenSettings: () {
        _scaffoldKey.currentState?.openDrawer();
      },
    );
  }

  void _openMyShaders() {
    fastPush(context, _buildMyShadersScreen());
  }

  void _openPresetsPage() {
    fastPush(context, _buildPresetsScreen());
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

      // Parse the zip using native VV / legacy importer
      final archive = await compute(_decodeZipBytesWorker, bytes);
      final parsed = parseVVPackFromArchive(
        archive,
        fallbackName: baseName.isEmpty ? 'Imported Shader' : baseName,
      );
      final finalName = parsed.importedPackName ?? parsed.config.packName;

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
            initialVVConfig: parsed.config,
            migrationNotice: parsed.legacyMigration?.userNotice,
          ),
        ),
      );
    } catch (e) {
      _snack('Could not parse shader pack: $e', isError: true);
    }
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
      drawer: VvGlobalDrawer(
        currentTab: VvNavTab.home,
        onOpenEditor: _openEditor,
        onOpenMyShaders: _openMyShaders,
        onOpenPresets: _openPresetsPage,
        onOpenUpload: _uploadAndParseShader,
      ),
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
                        fontWeight: FontWeight.w700,
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
                        fontWeight: FontWeight.w700,
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
                    fontWeight: FontWeight.w600,
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
          // Help / Guide Button on right (Opens onboarding guide on click)
          GestureDetector(
            onTap: _showWelcomeOnboardingSheet,
            child: Tooltip(
              message: 'How to create & install shaders',
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
                child: const SizedBox(
                  width: 42,
                  height: 42,
                  child: Center(
                    child: Icon(
                      Icons.help_outline_rounded,
                      color: Color(0xFF22C55E),
                      size: 20,
                    ),
                  ),
                ),
              ),
            ),
          ),
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
              fontWeight: FontWeight.w700,
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
                  fontWeight: FontWeight.w700,
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

  // 3. CTA Button: START GENERATING with Centered Simple Font & Pixelated Border
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
                alignment: Alignment.center,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: const Text(
                  'START GENERATING',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16.5,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.8,
                    shadows: [
                      Shadow(
                        color: Colors.black54,
                        blurRadius: 4,
                        offset: Offset(0, 1.5),
                      ),
                    ],
                  ),
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
                    fontWeight: FontWeight.w700,
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
                fontWeight: FontWeight.w700,
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
                            fontWeight: FontWeight.w700,
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
            fontWeight: FontWeight.w700,
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
                              fontWeight: FontWeight.w600,
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
                              fontWeight: FontWeight.w700,
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
                                  fontWeight: FontWeight.w600,
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
            fontWeight: FontWeight.w700,
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
                              fontWeight: FontWeight.w600,
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

  // 8. Shared Bottom Navigation Bar
  Widget _buildBottomNavBar(AppPalette palette) {
    return VvGlobalBottomNav(
      currentTab: VvNavTab.home,
      onOpenHome: () {},
      onOpenBuilder: _openEditor,
      onOpenGallery: _openMyShaders,
      onOpenPresets: _openPresetsPage,
      onOpenSettings: () => _scaffoldKey.currentState?.openDrawer(),
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
  sunlight,
  soulLight,
  caveLight,
  deepOcean,
  swampWater,
  underwaterFog,
  thunder,
  snow,
  puddle,
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
  DateTime? _lastTapTime;

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

  void _handleCardTap() {
    final now = DateTime.now();
    final isDouble =
        _lastTapTime != null &&
        now.difference(_lastTapTime!) < const Duration(milliseconds: 350);
    _lastTapTime = now;

    if (isDouble || widget.isSelected) {
      if (widget.onColorPick != null) {
        HapticFeedback.selectionClick();
        widget.onColorPick!();
      } else {
        widget.onTap();
      }
    } else {
      widget.onTap();
    }
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
        _handleCardTap();
      },
      onTapCancel: () => _pressCtrl.reverse(),
      onLongPress: () {
        _pressCtrl.reverse();
        HapticFeedback.mediumImpact();
        if (widget.onColorPick != null) {
          widget.onColorPick!();
        } else {
          widget.onTap();
        }
      },
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
            // Card Label underneath in bold, clean typography (scales down cleanly on compact widths)
            SizedBox(
              height: 16,
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  widget.label,
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    color:
                        widget.labelColor ??
                        (isSel ? selBorderColor : Colors.white),
                    fontSize: 11.5,
                    letterSpacing: 0.4,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 4),
            // Dedicated interactive Color Badge Button (Single-tap to select & edit color!)
            GestureDetector(
              onTap: () {
                HapticFeedback.selectionClick();
                if (widget.onColorPick != null) {
                  widget.onColorPick!();
                } else {
                  widget.onTap();
                }
              },
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
                          fontWeight: FontWeight.w600,
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
                    fontWeight: FontWeight.w600,
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
      case ShaderIconType.sunlight:
        _drawSunlightSkyScene(canvas, w, h, color);
        break;
      case ShaderIconType.soulLight:
        _drawEmissiveOresScene(canvas, w, h, color);
        break;
      case ShaderIconType.caveLight:
        _drawCaveAmbientScene(canvas, w, h, color);
        break;
      case ShaderIconType.deepOcean:
        _drawDeepOceanScene(canvas, w, h, color);
        break;
      case ShaderIconType.swampWater:
        _drawSwampWaterScene(canvas, w, h, color);
        break;
      case ShaderIconType.underwaterFog:
        _drawUnderwaterFogScene(canvas, w, h, color);
        break;
      case ShaderIconType.thunder:
        _drawThunderstormScene(canvas, w, h, color);
        break;
      case ShaderIconType.snow:
        _drawSnowFrostScene(canvas, w, h, color);
        break;
      case ShaderIconType.puddle:
        _drawPuddleReflectionScene(canvas, w, h, color);
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
    // Sunlit sandy coastline meeting shallow turquoise water
    final skyBand = Color.lerp(const Color(0xFF38BDF8), c, 0.25)!;
    canvas.drawRect(Rect.fromLTWH(0, 0, w, h * 0.28), Paint()..color = skyBand);

    final waterShallow = Color.lerp(const Color(0xFF22D3EE), c, 0.55)!;
    final waterMid = Color.lerp(const Color(0xFF06B6D4), c, 0.65)!;
    canvas.drawRect(
      Rect.fromLTWH(0, h * 0.28, w, h * 0.72),
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [waterShallow, waterMid],
        ).createShader(Rect.fromLTWH(0, h * 0.28, w, h * 0.72)),
    );

    // Warm shoreline sand bank on lower-left + white foam rim
    final sandPath = Path()
      ..moveTo(0, h * 0.52)
      ..lineTo(w * 0.44, h * 0.64)
      ..lineTo(w * 0.60, h)
      ..lineTo(0, h)
      ..close();
    canvas.drawPath(sandPath, Paint()..color = const Color(0xFFE5C88B));
    canvas.drawLine(
      Offset(0, h * 0.52),
      Offset(w * 0.60, h),
      Paint()
        ..color = Colors.white.withValues(alpha: 0.75)
        ..strokeWidth = 2.0,
    );

    // Crisp surface wave lines
    final causticPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.45)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4;
    for (var i = 0; i < 3; i++) {
      final y = h * (0.42 + i * 0.16);
      final wavePath = Path()
        ..moveTo(w * 0.22, y)
        ..quadraticBezierTo(w * 0.48, y - 3, w * 0.72, y)
        ..quadraticBezierTo(w * 0.88, y + 3, w, y);
      canvas.drawPath(wavePath, causticPaint);
    }
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

  /// Sunlight & Sky tile icon: sunlit sky, square sun, volumetric sunbeams & cast shadow
  void _drawSunlightSkyScene(Canvas canvas, double w, double h, Color c) {
    final skyTop = Color.lerp(const Color(0xFF0284C7), c, 0.30)!;
    final skyBot = Color.lerp(const Color(0xFF7DD3FC), c, 0.45)!;
    canvas.drawRect(
      Rect.fromLTWH(0, 0, w, h * 0.72),
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [skyTop, skyBot],
        ).createShader(Rect.fromLTWH(0, 0, w, h * 0.72)),
    );

    final sunPos = Offset(w * 0.24, h * 0.22);
    canvas.drawCircle(
      sunPos,
      w * 0.34,
      Paint()
        ..shader = RadialGradient(
          colors: [
            c.withValues(alpha: 0.65),
            c.withValues(alpha: 0.15),
            Colors.transparent,
          ],
        ).createShader(Rect.fromCircle(center: sunPos, radius: w * 0.34)),
    );
    _drawSquareSun(
      canvas,
      sunPos.dx,
      sunPos.dy,
      w * 0.18,
      c,
      defaultGlow: const Color(0xFFFFD54F),
    );

    // Diagonal light shafts from sun onto grass terrain
    for (var i = 0; i < 3; i++) {
      final shift = i * w * 0.16;
      final ray = Path()
        ..moveTo(sunPos.dx, sunPos.dy)
        ..lineTo(sunPos.dx + 6, sunPos.dy)
        ..lineTo(w * 0.44 + shift, h * 0.74)
        ..lineTo(w * 0.30 + shift, h * 0.74)
        ..close();
      canvas.drawPath(
        ray,
        Paint()..color = Colors.white.withValues(alpha: 0.22 - i * 0.04),
      );
    }

    // Lit voxel terrain + tall block casting crisp directional shadow
    _drawVoxelBlock(
      canvas,
      0,
      h * 0.70,
      w,
      h * 0.30,
      const Color(0xFF5A9E2B),
      const Color(0xFF5D4037),
    );
    canvas.drawRect(
      Rect.fromLTWH(w * 0.34, h * 0.48, w * 0.18, h * 0.22),
      Paint()..color = const Color(0xFF6B7280),
    );
    final shadow = Path()
      ..moveTo(w * 0.52, h * 0.70)
      ..lineTo(w * 0.88, h * 0.78)
      ..lineTo(w * 0.74, h * 0.86)
      ..lineTo(w * 0.36, h * 0.70)
      ..close();
    canvas.drawPath(
      shadow,
      Paint()..color = const Color(0xFF0F172A).withValues(alpha: 0.50),
    );
  }

  /// Emissive & Ores tile icon: dark deepslate wall studded with glowing ores & lantern crystal
  void _drawEmissiveOresScene(Canvas canvas, double w, double h, Color c) {
    canvas.drawRect(
      Rect.fromLTWH(0, 0, w, h),
      Paint()..color = const Color(0xFF10131A),
    );
    // Deepslate stone joints
    final slatePaint = Paint()..color = const Color(0xFF1D2230);
    canvas.drawRect(
      Rect.fromLTWH(w * 0.04, h * 0.06, w * 0.42, h * 0.24),
      slatePaint,
    );
    canvas.drawRect(
      Rect.fromLTWH(w * 0.50, h * 0.10, w * 0.44, h * 0.26),
      slatePaint,
    );
    canvas.drawRect(
      Rect.fromLTWH(w * 0.08, h * 0.38, w * 0.36, h * 0.28),
      slatePaint,
    );
    canvas.drawRect(
      Rect.fromLTWH(w * 0.52, h * 0.46, w * 0.42, h * 0.32),
      slatePaint,
    );

    // Central emissive glow halo in chosen accent color
    final center = Offset(w * 0.50, h * 0.52);
    canvas.drawCircle(
      center,
      w * 0.48,
      Paint()
        ..shader = RadialGradient(
          colors: [
            c.withValues(alpha: 0.75),
            c.withValues(alpha: 0.20),
            Colors.transparent,
          ],
        ).createShader(Rect.fromCircle(center: center, radius: w * 0.48)),
    );

    // Glowing Sea Lantern / Emissive Crystal block at center
    canvas.drawRect(
      Rect.fromCenter(center: center, width: w * 0.30, height: w * 0.30),
      Paint()..color = Color.lerp(c, const Color(0xFF1E293B), 0.35)!,
    );
    canvas.drawRect(
      Rect.fromCenter(center: center, width: w * 0.20, height: w * 0.20),
      Paint()..color = Color.lerp(c, Colors.white, 0.45)!,
    );
    canvas.drawRect(
      Rect.fromCenter(center: center, width: w * 0.09, height: w * 0.09),
      Paint()..color = Colors.white,
    );

    // Embedded glowing ore flecks (redstone, emerald, diamond/accent)
    canvas.drawRect(
      Rect.fromLTWH(w * 0.16, h * 0.16, 4, 4),
      Paint()..color = const Color(0xFFEF4444),
    );
    canvas.drawRect(
      Rect.fromLTWH(w * 0.24, h * 0.22, 3.5, 3.5),
      Paint()..color = const Color(0xFFFCA5A5),
    );
    canvas.drawRect(
      Rect.fromLTWH(w * 0.72, h * 0.20, 4, 4),
      Paint()..color = const Color(0xFF10B981),
    );
    canvas.drawRect(
      Rect.fromLTWH(w * 0.20, h * 0.72, 4.5, 4.5),
      Paint()..color = c,
    );
    canvas.drawRect(
      Rect.fromLTWH(w * 0.76, h * 0.74, 4, 4),
      Paint()..color = c,
    );
  }

  /// Cave Ambient tile icon: pitch-dark rocky underground cavern with stalactites & subterranean mist
  void _drawCaveAmbientScene(Canvas canvas, double w, double h, Color c) {
    final voidTop = Color.lerp(const Color(0xFF06080D), c, 0.25)!;
    final mistDepth = Color.lerp(const Color(0xFF141B29), c, 0.48)!;
    canvas.drawRect(
      Rect.fromLTWH(0, 0, w, h),
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [voidTop, mistDepth],
        ).createShader(Rect.fromLTWH(0, 0, w, h)),
    );

    // Jagged ceiling stalactites
    const rockDark = Color(0xFF181D27);
    const rockEdge = Color(0xFF283042);
    final ceiling = Path()
      ..moveTo(0, 0)
      ..lineTo(w, 0)
      ..lineTo(w, h * 0.34)
      ..lineTo(w * 0.80, h * 0.24)
      ..lineTo(w * 0.68, h * 0.44)
      ..lineTo(w * 0.56, h * 0.20)
      ..lineTo(w * 0.38, h * 0.38)
      ..lineTo(w * 0.24, h * 0.18)
      ..lineTo(w * 0.10, h * 0.36)
      ..lineTo(0, h * 0.28)
      ..close();
    canvas.drawPath(ceiling, Paint()..color = rockDark);

    // Dark cavern walls left & right framing the misty cave tunnel
    canvas.drawRect(
      Rect.fromLTWH(0, h * 0.24, w * 0.20, h * 0.76),
      Paint()..color = rockDark,
    );
    canvas.drawRect(
      Rect.fromLTWH(w * 0.80, h * 0.24, w * 0.20, h * 0.76),
      Paint()..color = rockDark,
    );
    canvas.drawRect(
      Rect.fromLTWH(w * 0.17, h * 0.28, 3, h * 0.55),
      Paint()..color = rockEdge,
    );
    canvas.drawRect(
      Rect.fromLTWH(w * 0.80, h * 0.28, 3, h * 0.55),
      Paint()..color = rockEdge,
    );

    // Stepped deepslate floor & rising stalagmite
    final floor = Path()
      ..moveTo(0, h * 0.78)
      ..lineTo(w * 0.26, h * 0.76)
      ..lineTo(w * 0.34, h * 0.60)
      ..lineTo(w * 0.44, h * 0.78)
      ..lineTo(w * 0.66, h * 0.74)
      ..lineTo(w * 0.76, h * 0.64)
      ..lineTo(w, h * 0.76)
      ..lineTo(w, h)
      ..lineTo(0, h)
      ..close();
    canvas.drawPath(floor, Paint()..color = const Color(0xFF11151E));

    // Faint ambient glow lichen dots inside cave mist
    canvas.drawCircle(
      Offset(w * 0.50, h * 0.56),
      w * 0.24,
      Paint()..color = c.withValues(alpha: 0.26),
    );
    canvas.drawRect(
      Rect.fromLTWH(w * 0.11, h * 0.50, 3, 3),
      Paint()..color = const Color(0xFF4ADE80).withValues(alpha: 0.75),
    );
    canvas.drawRect(
      Rect.fromLTWH(w * 0.85, h * 0.44, 3, 3),
      Paint()..color = const Color(0xFF4ADE80).withValues(alpha: 0.70),
    );
  }

  /// Deep Ocean tile icon: dark abyssal waves, crisp ocean swells & deep caustic glow
  void _drawDeepOceanScene(Canvas canvas, double w, double h, Color c) {
    final top = Color.lerp(const Color(0xFF0A2444), c, 0.45)!;
    final bot = Color.lerp(const Color(0xFF030D1E), c, 0.55)!;
    canvas.drawRect(
      Rect.fromLTWH(0, 0, w, h * 0.24),
      Paint()..color = const Color(0xFF0F294A),
    );
    canvas.drawRect(
      Rect.fromLTWH(0, h * 0.24, w, h * 0.76),
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [top, bot],
        ).createShader(Rect.fromLTWH(0, h * 0.24, w, h * 0.76)),
    );

    // Tall rolling ocean wave crests
    final swellPaint = Paint()
      ..color = Color.lerp(
        const Color(0xFF38BDF8),
        c,
        0.35,
      )!.withValues(alpha: 0.65)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;
    for (var i = 0; i < 4; i++) {
      final y = h * (0.28 + i * 0.16);
      final p = Path()
        ..moveTo(0, y + 3)
        ..quadraticBezierTo(w * 0.25, y - 5, w * 0.50, y + 2)
        ..quadraticBezierTo(w * 0.75, y + 8, w, y);
      canvas.drawPath(p, swellPaint);
    }
    // Deep trench glint & distant caustic ribbons
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(w * 0.42, h * 0.78),
        width: w * 0.48,
        height: 8,
      ),
      Paint()..color = const Color(0xFF38BDF8).withValues(alpha: 0.22),
    );
  }

  /// Swamp Murk tile icon: olive murky water, floating lily pads & swamp cattails
  void _drawSwampWaterScene(Canvas canvas, double w, double h, Color c) {
    canvas.drawRect(
      Rect.fromLTWH(0, 0, w, h * 0.24),
      Paint()..color = const Color(0xFF3F4E37),
    );
    final murkyTop = Color.lerp(const Color(0xFF4D6234), c, 0.50)!;
    final murkyBot = Color.lerp(const Color(0xFF283618), c, 0.55)!;
    canvas.drawRect(
      Rect.fromLTWH(0, h * 0.24, w, h * 0.76),
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [murkyTop, murkyBot],
        ).createShader(Rect.fromLTWH(0, h * 0.24, w, h * 0.76)),
    );

    // Reeds rising on left bank
    final reedPaint = Paint()..color = const Color(0xFF1E2D12);
    canvas.drawRect(Rect.fromLTWH(w * 0.10, h * 0.12, 3, h * 0.34), reedPaint);
    canvas.drawRect(Rect.fromLTWH(w * 0.18, h * 0.18, 3, h * 0.28), reedPaint);
    canvas.drawRect(
      Rect.fromLTWH(w * 0.09, h * 0.10, 5, 6),
      Paint()..color = const Color(0xFF5C4033),
    );

    // Minecraft notched green lily pads floating on still water
    void drawLilyPad(double x, double y, double s, {bool blossom = false}) {
      canvas.drawRect(
        Rect.fromLTWH(x, y, s, s * 0.55),
        Paint()..color = const Color(0xFF4D7C0F),
      );
      canvas.drawRect(
        Rect.fromLTWH(x + s * 0.60, y + s * 0.18, s * 0.42, 3),
        Paint()..color = murkyTop,
      );
      if (blossom) {
        canvas.drawRect(
          Rect.fromLTWH(x + s * 0.25, y - 3, 5, 4),
          Paint()..color = const Color(0xFFF472B6),
        );
      }
    }

    drawLilyPad(w * 0.24, h * 0.52, w * 0.28, blossom: true);
    drawLilyPad(w * 0.58, h * 0.70, w * 0.26);
  }

  /// Underwater Fog tile icon: submerged beneath waves looking into volumetric depth haze & bubbles
  void _drawUnderwaterFogScene(Canvas canvas, double w, double h, Color c) {
    final top = Color.lerp(const Color(0xFF0E7490), c, 0.38)!;
    final fogDeep = Color.lerp(const Color(0xFF082F49), c, 0.72)!;
    canvas.drawRect(
      Rect.fromLTWH(0, 0, w, h),
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [top, fogDeep],
        ).createShader(Rect.fromLTWH(0, 0, w, h)),
    );

    // Bright water surface seen from below along top edge
    canvas.drawRect(
      Rect.fromLTWH(0, 0, w, h * 0.11),
      Paint()..color = const Color(0xFF67E8F9).withValues(alpha: 0.45),
    );
    // Volumetric underwater light rays fading into distance fog
    final ray = Path()
      ..moveTo(w * 0.25, 0)
      ..lineTo(w * 0.45, 0)
      ..lineTo(w * 0.65, h * 0.75)
      ..lineTo(w * 0.35, h * 0.75)
      ..close();
    canvas.drawPath(ray, Paint()..color = Colors.white.withValues(alpha: 0.16));
    // Thick horizon fog veil across lower depths
    canvas.drawRect(
      Rect.fromLTWH(0, h * 0.46, w, h * 0.54),
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.transparent, c.withValues(alpha: 0.65)],
        ).createShader(Rect.fromLTWH(0, h * 0.46, w, h * 0.54)),
    );
    // Square oxygen bubbles & kelp silhouette
    final bPaint = Paint()..color = Colors.white.withValues(alpha: 0.75);
    canvas.drawRect(Rect.fromLTWH(w * 0.70, h * 0.26, 3.5, 3.5), bPaint);
    canvas.drawRect(Rect.fromLTWH(w * 0.75, h * 0.42, 4, 4), bPaint);
    canvas.drawRect(Rect.fromLTWH(w * 0.68, h * 0.58, 3, 3), bPaint);
    final kelp = Paint()
      ..color = const Color(0xFF14532D).withValues(alpha: 0.65);
    canvas.drawRect(Rect.fromLTWH(w * 0.18, h * 0.62, 4, h * 0.38), kelp);
    canvas.drawRect(Rect.fromLTWH(w * 0.26, h * 0.70, 4, h * 0.30), kelp);
  }

  /// Thunderstorm tile icon: dark squall clouds & jagged lightning bolt strike
  void _drawThunderstormScene(Canvas canvas, double w, double h, Color c) {
    final skyTop = Color.lerp(const Color(0xFF0F172A), c, 0.35)!;
    final skyBot = Color.lerp(const Color(0xFF1E1B4B), c, 0.45)!;
    canvas.drawRect(
      Rect.fromLTWH(0, 0, w, h),
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [skyTop, skyBot],
        ).createShader(Rect.fromLTWH(0, 0, w, h)),
    );
    _drawTieredVoxelCloud(
      canvas,
      w * 0.04,
      h * 0.02,
      w * 0.92,
      h * 0.20,
      const Color(0xFF334155),
      const Color(0xFF0F172A),
    );
    // Lightning flash halo
    canvas.drawCircle(
      Offset(w * 0.52, h * 0.48),
      w * 0.36,
      Paint()..color = const Color(0xFFFEF08A).withValues(alpha: 0.24),
    );
    // Jagged electric bolt
    final bolt = Path()
      ..moveTo(w * 0.56, h * 0.20)
      ..lineTo(w * 0.42, h * 0.48)
      ..lineTo(w * 0.55, h * 0.48)
      ..lineTo(w * 0.40, h * 0.80);
    canvas.drawPath(
      bolt,
      Paint()
        ..color = const Color(0xFFFEF08A)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3.0
        ..strokeCap = StrokeCap.square,
    );
    canvas.drawPath(
      bolt,
      Paint()
        ..color = Colors.white
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.4,
    );
    // Steep squall rain streaks
    final rain = Paint()
      ..color = Colors.white.withValues(alpha: 0.35)
      ..strokeWidth = 1.0;
    for (final p in const [0.16, 0.28, 0.72, 0.86]) {
      canvas.drawLine(
        Offset(w * p, h * 0.26),
        Offset(w * p - 6, h * 0.44),
        rain,
      );
      canvas.drawLine(
        Offset(w * (p - 0.05), h * 0.62),
        Offset(w * (p - 0.05) - 6, h * 0.82),
        rain,
      );
    }
  }

  /// Snow & Frost tile icon: frosted alpine spruce, thick white snow & falling pixel flakes
  void _drawSnowFrostScene(Canvas canvas, double w, double h, Color c) {
    final skyTop = Color.lerp(const Color(0xFF64748B), c, 0.45)!;
    final skyBot = Color.lerp(const Color(0xFFCBD5E1), c, 0.55)!;
    canvas.drawRect(
      Rect.fromLTWH(0, 0, w, h),
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [skyTop, skyBot],
        ).createShader(Rect.fromLTWH(0, 0, w, h)),
    );
    _drawMinecraftSpruceTree(
      canvas,
      w * 0.56,
      h * 0.26,
      w * 0.34,
      h * 0.48,
      const Color(0xFF1E3A2F),
    );
    // White snow cap dusted on spruce tiers
    canvas.drawRect(
      Rect.fromLTWH(w * 0.68, h * 0.26, w * 0.10, 3),
      Paint()..color = Colors.white,
    );
    canvas.drawRect(
      Rect.fromLTWH(w * 0.61, h * 0.40, w * 0.24, 3),
      Paint()..color = Colors.white,
    );
    // Thick white snow block + icy edge
    _drawVoxelBlock(
      canvas,
      0,
      h * 0.70,
      w,
      h * 0.30,
      const Color(0xFFF8FAFC),
      const Color(0xFF7DD3FC),
    );
    // Square pixel snowflakes
    final flake = Paint()..color = Colors.white;
    for (final pt in const [
      Offset(0.16, 0.18),
      Offset(0.38, 0.14),
      Offset(0.24, 0.40),
      Offset(0.46, 0.32),
      Offset(0.12, 0.56),
      Offset(0.34, 0.54),
      Offset(0.84, 0.16),
    ]) {
      canvas.drawRect(
        Rect.fromCenter(
          center: Offset(w * pt.dx, h * pt.dy),
          width: 3.0,
          height: 3.0,
        ),
        flake,
      );
    }
  }

  /// Puddles & Wet tile icon: wet cobblestone ground with reflective mirror puddles & ripples
  void _drawPuddleReflectionScene(Canvas canvas, double w, double h, Color c) {
    // Damp dark stone ground base
    canvas.drawRect(
      Rect.fromLTWH(0, 0, w, h),
      Paint()..color = const Color(0xFF1E2530),
    );
    final mortar = Paint()
      ..color = const Color(0xFF0F131A)
      ..strokeWidth = 1.0;
    for (var r = 1; r < 4; r++) {
      canvas.drawLine(Offset(0, h * r * 0.25), Offset(w, h * r * 0.25), mortar);
    }
    for (var col = 1; col < 4; col++) {
      canvas.drawLine(
        Offset(w * col * 0.25, 0),
        Offset(w * col * 0.25, h),
        mortar,
      );
    }

    // Mirror-glossy sky-reflecting puddle tinted with puddle color c
    final puddleRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(w * 0.12, h * 0.24, w * 0.76, h * 0.54),
      const Radius.circular(10),
    );
    canvas.drawRRect(
      puddleRect,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color.lerp(const Color(0xFF94A3B8), c, 0.45)!,
            Color.lerp(const Color(0xFF334155), c, 0.65)!,
          ],
        ).createShader(puddleRect.outerRect),
    );
    // Concentric ripple oval inside puddle + wet specular highlight
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(w * 0.52, h * 0.52),
        width: w * 0.36,
        height: h * 0.16,
      ),
      Paint()
        ..color = Colors.white.withValues(alpha: 0.60)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2,
    );
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(w * 0.52, h * 0.52),
        width: w * 0.16,
        height: h * 0.07,
      ),
      Paint()
        ..color = Colors.white.withValues(alpha: 0.85)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2,
    );
    canvas.drawRRect(
      puddleRect,
      Paint()
        ..color = Colors.white.withValues(alpha: 0.22)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.0,
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

