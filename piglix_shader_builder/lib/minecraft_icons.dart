import 'dart:math' as math;
import 'package:flutter/material.dart';

/// All available Minecraft voxel icon types matching the user reference
enum VoxelIconType {
  sun,
  moon,
  cloud,
  lightbulb,
  goldBlock,
  mountain,
  torch,
  waterDroplet,
  waves,
  diamond,
  caustics,
  cubeMirror,
  pearl,
  pbrLayers,
  pickaxe,
  chest,
  globe,
  gear,
  pencil,
  dice,
  sparkles,
  grassBlock,
  steve,
  lantern,
  rainCloud,
  waterSplash,
  palette,
  camera,
  contrast,
  film,
}

/// A smoothly animated 60 FPS Minecraft-style voxel icon with rich micro-animations
class AnimatedMinecraftIcon extends StatefulWidget {
  final VoxelIconType type;
  final double size;
  final Color? colorOverride;

  const AnimatedMinecraftIcon({
    super.key,
    required this.type,
    this.size = 28,
    this.colorOverride,
  });

  @override
  State<AnimatedMinecraftIcon> createState() => _AnimatedMinecraftIconState();
}

class _AnimatedMinecraftIconState extends State<AnimatedMinecraftIcon>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    // 2.4s seamless repeating loop for subtle living animations
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    )..repeat();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (context, child) {
        return CustomPaint(
          size: Size(widget.size, widget.size),
          painter: _VoxelIconPainter(
            type: widget.type,
            anim: _ctrl.value,
            colorOverride: widget.colorOverride,
          ),
        );
      },
    );
  }
}

class _VoxelIconPainter extends CustomPainter {
  final VoxelIconType type;
  final double anim; // 0.0 to 1.0
  final Color? colorOverride;

  _VoxelIconPainter({
    required this.type,
    required this.anim,
    this.colorOverride,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final cx = w * 0.5;
    final cy = h * 0.5;

    switch (type) {
      case VoxelIconType.sun:
        _drawSun(canvas, cx, cy, w);
        break;
      case VoxelIconType.moon:
        _drawMoon(canvas, cx, cy, w);
        break;
      case VoxelIconType.cloud:
        _drawCloud(canvas, cx, cy, w);
        break;
      case VoxelIconType.lightbulb:
        _drawLightbulb(canvas, cx, cy, w);
        break;
      case VoxelIconType.goldBlock:
        _drawGoldBlock(canvas, cx, cy, w);
        break;
      case VoxelIconType.mountain:
        _drawMountain(canvas, cx, cy, w);
        break;
      case VoxelIconType.torch:
        _drawTorch(canvas, cx, cy, w);
        break;
      case VoxelIconType.waterDroplet:
        _drawWaterDroplet(canvas, cx, cy, w);
        break;
      case VoxelIconType.waves:
        _drawWaves(canvas, cx, cy, w);
        break;
      case VoxelIconType.diamond:
        _drawDiamond(canvas, cx, cy, w);
        break;
      case VoxelIconType.caustics:
        _drawCaustics(canvas, cx, cy, w);
        break;
      case VoxelIconType.cubeMirror:
        _drawCubeMirror(canvas, cx, cy, w);
        break;
      case VoxelIconType.pearl:
        _drawPearl(canvas, cx, cy, w);
        break;
      case VoxelIconType.pbrLayers:
        _drawPbrLayers(canvas, cx, cy, w);
        break;
      case VoxelIconType.pickaxe:
        _drawPickaxe(canvas, cx, cy, w);
        break;
      case VoxelIconType.chest:
        _drawChest(canvas, cx, cy, w);
        break;
      case VoxelIconType.globe:
        _drawGlobe(canvas, cx, cy, w);
        break;
      case VoxelIconType.gear:
        _drawGear(canvas, cx, cy, w);
        break;
      case VoxelIconType.pencil:
        _drawPencil(canvas, cx, cy, w);
        break;
      case VoxelIconType.dice:
        _drawDice(canvas, cx, cy, w);
        break;
      case VoxelIconType.sparkles:
        _drawSparkles(canvas, cx, cy, w);
        break;
      case VoxelIconType.grassBlock:
        _drawGrassBlock(canvas, cx, cy, w);
        break;
      case VoxelIconType.steve:
        _drawSteve(canvas, cx, cy, w);
        break;
      case VoxelIconType.lantern:
        _drawLantern(canvas, cx, cy, w);
        break;
      case VoxelIconType.rainCloud:
        _drawRainCloud(canvas, cx, cy, w);
        break;
      case VoxelIconType.waterSplash:
        _drawWaterSplash(canvas, cx, cy, w);
        break;
      case VoxelIconType.palette:
        _drawPalette(canvas, cx, cy, w);
        break;
      case VoxelIconType.camera:
        _drawCamera(canvas, cx, cy, w);
        break;
      case VoxelIconType.contrast:
        _drawContrast(canvas, cx, cy, w);
        break;
      case VoxelIconType.film:
        _drawFilm(canvas, cx, cy, w);
        break;
    }
  }

  // 1. SUN: Glowing square sun with animated pulsating rays
  void _drawSun(Canvas canvas, double cx, double cy, double s) {
    final pulse = 1.0 + 0.08 * math.sin(anim * 2 * math.pi);
    final rot = anim * 0.15;

    // Outer warm radial aura
    canvas.drawCircle(
      Offset(cx, cy),
      s * 0.45 * pulse,
      Paint()
        ..color = (colorOverride ?? const Color(0xFFFFD54F)).withOpacity(0.35),
    );

    // Rotating 8-point square rays
    canvas.save();
    canvas.translate(cx, cy);
    canvas.rotate(rot);

    final rayPaint = Paint()..color = (colorOverride ?? const Color(0xFFFFC107));
    final rayLen = s * 0.40 * pulse;
    for (var i = 0; i < 4; i++) {
      canvas.drawRect(Rect.fromCenter(center: Offset(0, -rayLen), width: s * 0.12, height: s * 0.14), rayPaint);
      canvas.drawRect(Rect.fromCenter(center: Offset(0, rayLen), width: s * 0.12, height: s * 0.14), rayPaint);
      canvas.rotate(math.pi / 2);
    }
    canvas.restore();

    // Central Square Minecraft Sun
    canvas.drawRect(
      Rect.fromCenter(center: Offset(cx, cy), width: s * 0.38, height: s * 0.38),
      Paint()..color = const Color(0xFFFFF9C4),
    );
  }

  // 2. MOON: Glowing pixel crescent moon with twinkling star
  void _drawMoon(Canvas canvas, double cx, double cy, double s) {
    final twinkle = 0.5 + 0.5 * math.sin(anim * 4 * math.pi);

    // Moonlight aura
    canvas.drawCircle(
      Offset(cx, cy),
      s * 0.42,
      Paint()..color = const Color(0xFF90CAF9).withOpacity(0.25),
    );

    // Pixel crescent moon
    final p = s * 0.085;
    final startX = cx - s * 0.35;
    final startY = cy - s * 0.35;

    final moonPaint = Paint()..color = (colorOverride ?? const Color(0xFFE3F2FD));
    const coords = [
      [3, 0], [4, 0],
      [2, 1], [3, 1], [4, 1],
      [1, 2], [2, 2], [3, 2],
      [1, 3], [2, 3],
      [1, 4], [2, 4],
      [1, 5], [2, 5], [3, 5],
      [2, 6], [3, 6], [4, 6],
      [3, 7], [4, 7],
    ];
    for (final c in coords) {
      canvas.drawRect(Rect.fromLTWH(startX + c[0] * p, startY + c[1] * p, p, p), moonPaint);
    }

    // Twinkling star in top right
    final starPaint = Paint()..color = Colors.white.withOpacity(twinkle);
    canvas.drawRect(Rect.fromLTWH(cx + s * 0.22, cy - s * 0.28, s * 0.09, s * 0.09), starPaint);
  }

  // 3. CLOUD: 3D Minecraft voxel cloud floating up and down
  void _drawCloud(Canvas canvas, double cx, double cy, double s) {
    final bob = math.sin(anim * 2 * math.pi) * (s * 0.05);
    final y = cy + bob;

    final litPaint = Paint()..color = (colorOverride ?? Colors.white);
    final shadowPaint = Paint()..color = const Color(0xFFB0BEC5);

    // Bottom shadow band
    canvas.drawRect(Rect.fromCenter(center: Offset(cx, y + s * 0.12), width: s * 0.75, height: s * 0.20), shadowPaint);
    // Main cloud puff
    canvas.drawRect(Rect.fromCenter(center: Offset(cx, y), width: s * 0.75, height: s * 0.22), litPaint);
    // Top tiered voxel bumps
    canvas.drawRect(Rect.fromCenter(center: Offset(cx - s * 0.12, y - s * 0.12), width: s * 0.32, height: s * 0.18), litPaint);
    canvas.drawRect(Rect.fromCenter(center: Offset(cx + s * 0.14, y - s * 0.08), width: s * 0.26, height: s * 0.14), litPaint);
  }

  // 4. LIGHTBULB: Glowing bulb with pulsing filament
  void _drawLightbulb(Canvas canvas, double cx, double cy, double s) {
    final glow = 0.65 + 0.35 * math.sin(anim * 3 * math.pi);

    // Bulb glow halo
    canvas.drawCircle(
      Offset(cx, cy - s * 0.05),
      s * 0.40,
      Paint()..color = const Color(0xFFFFD54F).withOpacity(0.35 * glow),
    );

    // Glass bulb
    final bulbPath = Path()
      ..addOval(Rect.fromCircle(center: Offset(cx, cy - s * 0.06), radius: s * 0.28))
      ..addRect(Rect.fromCenter(center: Offset(cx, cy + s * 0.15), width: s * 0.26, height: s * 0.18));
    canvas.drawPath(bulbPath, Paint()..color = const Color(0xFFFFEB3B));

    // Base screw thread
    final basePaint = Paint()..color = const Color(0xFF78909C);
    canvas.drawRect(Rect.fromCenter(center: Offset(cx, cy + s * 0.28), width: s * 0.20, height: s * 0.08), basePaint);
    canvas.drawRect(Rect.fromCenter(center: Offset(cx, cy + s * 0.34), width: s * 0.12, height: s * 0.05), Paint()..color = const Color(0xFF455A64));

    // Inner bright filament
    canvas.drawRect(
      Rect.fromCenter(center: Offset(cx, cy - s * 0.06), width: s * 0.10, height: s * 0.12),
      Paint()..color = Colors.white.withOpacity(glow),
    );
  }

  // 5. GOLD BLOCK: 3D isometric glowing gold block with diagonal gleam
  void _drawGoldBlock(Canvas canvas, double cx, double cy, double s) {
    final gleamPos = (anim * 2.0) - 0.5;

    final w2 = s * 0.35;
    final h2 = s * 0.20;

    // Top face
    final topFace = Path()
      ..moveTo(cx, cy - s * 0.32)
      ..lineTo(cx + w2, cy - s * 0.32 + h2)
      ..lineTo(cx, cy - s * 0.32 + 2 * h2)
      ..lineTo(cx - w2, cy - s * 0.32 + h2)
      ..close();
    canvas.drawPath(topFace, Paint()..color = const Color(0xFFFFF176));

    // Left face
    final leftFace = Path()
      ..moveTo(cx - w2, cy - s * 0.32 + h2)
      ..lineTo(cx, cy - s * 0.32 + 2 * h2)
      ..lineTo(cx, cy + s * 0.30)
      ..lineTo(cx - w2, cy + s * 0.30 - h2)
      ..close();
    canvas.drawPath(leftFace, Paint()..color = const Color(0xFFFBC02D));

    // Right face
    final rightFace = Path()
      ..moveTo(cx, cy - s * 0.32 + 2 * h2)
      ..lineTo(cx + w2, cy - s * 0.32 + h2)
      ..lineTo(cx + w2, cy + s * 0.30 - h2)
      ..lineTo(cx, cy + s * 0.30)
      ..close();
    canvas.drawPath(rightFace, Paint()..color = const Color(0xFFF57F17));

    // Shimmer gleam band across top face
    if (gleamPos >= 0.0 && gleamPos <= 1.0) {
      canvas.save();
      canvas.clipPath(topFace);
      final gx = (cx - w2) + (2 * w2) * gleamPos;
      canvas.drawRect(
        Rect.fromCenter(center: Offset(gx, cy - s * 0.15), width: s * 0.12, height: s * 0.4),
        Paint()..color = Colors.white.withOpacity(0.65),
      );
      canvas.restore();
    }
  }

  // 6. MOUNTAIN: Stepped Minecraft peak casting a shadow
  void _drawMountain(Canvas canvas, double cx, double cy, double s) {
    // Lit peak
    final litPath = Path()
      ..moveTo(cx, cy - s * 0.32)
      ..lineTo(cx + s * 0.36, cy + s * 0.28)
      ..lineTo(cx, cy + s * 0.28)
      ..close();
    canvas.drawPath(litPath, Paint()..color = const Color(0xFF90A4AE));

    // Shadow side
    final shadowPath = Path()
      ..moveTo(cx, cy - s * 0.32)
      ..lineTo(cx - s * 0.36, cy + s * 0.28)
      ..lineTo(cx, cy + s * 0.28)
      ..close();
    canvas.drawPath(shadowPath, Paint()..color = const Color(0xFF455A64));

    // Snow cap
    final snowPath = Path()
      ..moveTo(cx, cy - s * 0.32)
      ..lineTo(cx + s * 0.12, cy - s * 0.12)
      ..lineTo(cx, cy - s * 0.08)
      ..lineTo(cx - s * 0.12, cy - s * 0.12)
      ..close();
    canvas.drawPath(snowPath, Paint()..color = Colors.white);
  }

  // 7. TORCH: Minecraft wall torch with animated flickering voxel flame!
  void _drawTorch(Canvas canvas, double cx, double cy, double s) {
    final flicker = math.sin(anim * 8 * math.pi) * (s * 0.03);

    // Warm radial glow halo
    canvas.drawCircle(
      Offset(cx, cy - s * 0.15 + flicker),
      s * 0.40,
      Paint()..color = const Color(0xFFFF9800).withOpacity(0.35),
    );

    // Angled wooden stick
    final stickPaint = Paint()..color = const Color(0xFF5D4037);
    canvas.drawRect(
      Rect.fromCenter(center: Offset(cx, cy + s * 0.12), width: s * 0.14, height: s * 0.45),
      stickPaint,
    );
    // Charcoal tip
    canvas.drawRect(
      Rect.fromCenter(center: Offset(cx, cy - s * 0.10), width: s * 0.14, height: s * 0.08),
      Paint()..color = const Color(0xFF212121),
    );

    // Outer voxel flame (Orange/Red)
    final flameY = cy - s * 0.24 + flicker;
    canvas.drawRect(
      Rect.fromCenter(center: Offset(cx, flameY), width: s * 0.22, height: s * 0.22),
      Paint()..color = const Color(0xFFFF5722),
    );
    // Inner voxel flame (Yellow/White core)
    canvas.drawRect(
      Rect.fromCenter(center: Offset(cx, flameY), width: s * 0.12, height: s * 0.12),
      Paint()..color = const Color(0xFFFFF9C4),
    );
  }

  // 8. WATER DROPLET: Glossy 3D water droplet bobbing up and down
  void _drawWaterDroplet(Canvas canvas, double cx, double cy, double s) {
    final bob = math.sin(anim * 2 * math.pi) * (s * 0.04);
    final y = cy + bob;

    final dropPath = Path()
      ..moveTo(cx, y - s * 0.34)
      ..cubicTo(cx + s * 0.32, y - s * 0.05, cx + s * 0.32, y + s * 0.28, cx, y + s * 0.32)
      ..cubicTo(cx - s * 0.32, y + s * 0.28, cx - s * 0.32, y - s * 0.05, cx, y - s * 0.34)
      ..close();

    canvas.drawPath(
      dropPath,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF40C4FF), Color(0xFF0091EA)],
        ).createShader(Rect.fromCircle(center: Offset(cx, y), radius: s * 0.35)),
    );

    // Specular highlight gleam
    canvas.drawOval(
      Rect.fromCenter(center: Offset(cx - s * 0.10, y - s * 0.08), width: s * 0.09, height: s * 0.14),
      Paint()..color = Colors.white.withOpacity(0.85),
    );
  }

  // 9. WAVES: 3 undulating ripple lines
  void _drawWaves(Canvas canvas, double cx, double cy, double s) {
    final wavePaint = Paint()
      ..color = (colorOverride ?? const Color(0xFF00E5FF))
      ..style = PaintingStyle.stroke
      ..strokeWidth = s * 0.09
      ..strokeCap = StrokeCap.round;

    final shift = anim * 2 * math.pi;

    for (var i = 0; i < 3; i++) {
      final y = cy - s * 0.20 + i * (s * 0.20);
      final p = Path();
      p.moveTo(cx - s * 0.35, y);
      for (var x = -s * 0.35; x <= s * 0.35; x += 2.0) {
        final wy = math.sin((x / s * 8) + shift + i * 1.5) * (s * 0.04);
        p.lineTo(cx + x, y + wy);
      }
      canvas.drawPath(p, wavePaint);
    }
  }

  // 10. DIAMOND: Minecraft cyan diamond with sparkling facets
  void _drawDiamond(Canvas canvas, double cx, double cy, double s) {
    final sparkle = (math.sin(anim * 4 * math.pi) * 0.5 + 0.5).clamp(0.0, 1.0);

    // Outer aura
    canvas.drawCircle(
      Offset(cx, cy),
      s * 0.38,
      Paint()..color = const Color(0xFF00E5FF).withOpacity(0.30),
    );

    // Diamond polygon
    final diaPath = Path()
      ..moveTo(cx, cy - s * 0.30)
      ..lineTo(cx + s * 0.32, cy - s * 0.08)
      ..lineTo(cx, cy + s * 0.34)
      ..lineTo(cx - s * 0.32, cy - s * 0.08)
      ..close();
    canvas.drawPath(diaPath, Paint()..color = const Color(0xFF00E5FF));

    // Inner facets
    final facetPaint = Paint()..color = const Color(0xFF84FFFF);
    final topFacet = Path()
      ..moveTo(cx, cy - s * 0.30)
      ..lineTo(cx + s * 0.16, cy - s * 0.08)
      ..lineTo(cx, cy + s * 0.06)
      ..lineTo(cx - s * 0.16, cy - s * 0.08)
      ..close();
    canvas.drawPath(topFacet, facetPaint);

    // Flashing 4-point star glint in top corner
    if (sparkle > 0.4) {
      final glintPaint = Paint()..color = Colors.white.withOpacity(sparkle);
      final gx = cx + s * 0.16;
      final gy = cy - s * 0.16;
      final gw = s * 0.18 * sparkle;
      canvas.drawLine(Offset(gx - gw, gy), Offset(gx + gw, gy), glintPaint..strokeWidth = 1.8);
      canvas.drawLine(Offset(gx, gy - gw), Offset(gx, gy + gw), glintPaint..strokeWidth = 1.8);
    }
  }

  // 11. CAUSTICS: Underwater shimmering caustic light mesh
  void _drawCaustics(Canvas canvas, double cx, double cy, double s) {
    final causticPaint = Paint()
      ..color = (colorOverride ?? const Color(0xFF80D8FF)).withOpacity(0.65)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.8;

    final phase = anim * 2 * math.pi;
    for (var i = 0; i < 4; i++) {
      final r = s * (0.16 + i * 0.06) + math.sin(phase + i) * (s * 0.03);
      canvas.drawCircle(Offset(cx + math.cos(phase + i) * 3, cy + math.sin(phase + i) * 3), r, causticPaint);
    }
  }

  // 12. CUBE MIRROR: 3D holographic glass cube with specular sweep
  void _drawCubeMirror(Canvas canvas, double cx, double cy, double s) {
    final w2 = s * 0.32;
    final h2 = s * 0.18;

    final topFace = Path()
      ..moveTo(cx, cy - s * 0.30)
      ..lineTo(cx + w2, cy - s * 0.30 + h2)
      ..lineTo(cx, cy - s * 0.30 + 2 * h2)
      ..lineTo(cx - w2, cy - s * 0.30 + h2)
      ..close();
    canvas.drawPath(topFace, Paint()..color = const Color(0xFFE0F7FA).withOpacity(0.85));

    final leftFace = Path()
      ..moveTo(cx - w2, cy - s * 0.30 + h2)
      ..lineTo(cx, cy - s * 0.30 + 2 * h2)
      ..lineTo(cx, cy + s * 0.28)
      ..lineTo(cx - w2, cy + s * 0.28 - h2)
      ..close();
    canvas.drawPath(leftFace, Paint()..color = const Color(0xFF80DEEA).withOpacity(0.75));

    final rightFace = Path()
      ..moveTo(cx, cy - s * 0.30 + 2 * h2)
      ..lineTo(cx + w2, cy - s * 0.30 + h2)
      ..lineTo(cx + w2, cy + s * 0.28 - h2)
      ..lineTo(cx, cy + s * 0.28)
      ..close();
    canvas.drawPath(rightFace, Paint()..color = const Color(0xFF26C6DA).withOpacity(0.70));
  }

  // 13. PEARL: Ender pearl with swirling mystical purple aura
  void _drawPearl(Canvas canvas, double cx, double cy, double s) {
    final pulse = 1.0 + 0.06 * math.sin(anim * 3 * math.pi);

    // Mystical purple aura
    canvas.drawCircle(
      Offset(cx, cy),
      s * 0.40 * pulse,
      Paint()..color = const Color(0xFFAB47BC).withOpacity(0.40),
    );

    // Deep teal/black pearl core
    canvas.drawCircle(
      Offset(cx, cy),
      s * 0.28,
      Paint()
        ..shader = const RadialGradient(
          colors: [Color(0xFF80CBC4), Color(0xFF004D40), Color(0xFF00251A)],
          stops: [0.0, 0.65, 1.0],
        ).createShader(Rect.fromCircle(center: Offset(cx - s * 0.06, cy - s * 0.06), radius: s * 0.28)),
    );

    // Specular gleam
    canvas.drawCircle(Offset(cx - s * 0.08, cy - s * 0.08), s * 0.06, Paint()..color = Colors.white.withOpacity(0.90));
  }

  // 14. PBR LAYERS: 3 stacked isometric texture sheets hovering
  void _drawPbrLayers(Canvas canvas, double cx, double cy, double s) {
    final float = math.sin(anim * 2 * math.pi) * (s * 0.03);

    final colors = [
      const Color(0xFF42A5F5), // Albedo
      const Color(0xFFAB47BC), // Normal
      const Color(0xFF78909C), // Roughness/Height
    ];

    for (var i = 0; i < 3; i++) {
      final y = cy - s * 0.16 + i * (s * 0.18) + (i == 0 ? float : 0);
      final w2 = s * 0.32;
      final h2 = s * 0.14;

      final path = Path()
        ..moveTo(cx, y - h2)
        ..lineTo(cx + w2, y)
        ..lineTo(cx, y + h2)
        ..lineTo(cx - w2, y)
        ..close();
      canvas.drawPath(path, Paint()..color = colors[i]);
      canvas.drawPath(path, Paint()..color = Colors.white24..style = PaintingStyle.stroke..strokeWidth = 1.0);
    }
  }

  // 15. PICKAXE: Diamond Pickaxe
  void _drawPickaxe(Canvas canvas, double cx, double cy, double s) {
    // Handle (diagonal)
    final handlePaint = Paint()
      ..color = const Color(0xFF5D4037)
      ..strokeWidth = s * 0.10
      ..strokeCap = StrokeCap.square;
    canvas.drawLine(Offset(cx - s * 0.25, cy + s * 0.25), Offset(cx + s * 0.18, cy - s * 0.18), handlePaint);

    // Diamond head (curved top)
    final headPaint = Paint()
      ..color = const Color(0xFF00E5FF)
      ..style = PaintingStyle.fill;

    final headPath = Path()
      ..moveTo(cx - s * 0.05, cy - s * 0.35)
      ..lineTo(cx + s * 0.35, cy - s * 0.30)
      ..lineTo(cx + s * 0.32, cy - s * 0.02)
      ..lineTo(cx + s * 0.22, cy - s * 0.15)
      ..lineTo(cx + s * 0.05, cy - s * 0.20)
      ..close();
    canvas.drawPath(headPath, headPaint);
  }

  // 16. CHEST: Minecraft wooden chest
  void _drawChest(Canvas canvas, double cx, double cy, double s) {
    // Dark border
    canvas.drawRect(Rect.fromCenter(center: Offset(cx, cy), width: s * 0.65, height: s * 0.55), Paint()..color = const Color(0xFF2E1C14));
    // Wood body
    canvas.drawRect(Rect.fromCenter(center: Offset(cx, cy), width: s * 0.55, height: s * 0.45), Paint()..color = const Color(0xFF8D6E63));
    // Silver/Black latch
    canvas.drawRect(Rect.fromCenter(center: Offset(cx, cy - s * 0.02), width: s * 0.12, height: s * 0.14), Paint()..color = const Color(0xFFECEFF1));
    canvas.drawRect(Rect.fromCenter(center: Offset(cx, cy + s * 0.01), width: s * 0.06, height: s * 0.08), Paint()..color = Colors.black);
  }

  // 17. GLOBE: 3D Earth block
  void _drawGlobe(Canvas canvas, double cx, double cy, double s) {
    canvas.drawCircle(Offset(cx, cy), s * 0.32, Paint()..color = const Color(0xFF1E88E5));
    // Continents
    final landPaint = Paint()..color = const Color(0xFF4CAF50);
    canvas.drawRect(Rect.fromLTWH(cx - s * 0.18, cy - s * 0.14, s * 0.20, s * 0.16), landPaint);
    canvas.drawRect(Rect.fromLTWH(cx + s * 0.02, cy - s * 0.04, s * 0.18, s * 0.18), landPaint);
    canvas.drawRect(Rect.fromLTWH(cx - s * 0.12, cy + s * 0.08, s * 0.14, s * 0.12), landPaint);
  }

  // 18. GEAR: Cog
  void _drawGear(Canvas canvas, double cx, double cy, double s) {
    canvas.save();
    canvas.translate(cx, cy);
    canvas.rotate(anim * 2 * math.pi);
    final p = Paint()..color = const Color(0xFF90A4AE);

    for (var i = 0; i < 4; i++) {
      canvas.drawRect(Rect.fromCenter(center: Offset.zero, width: s * 0.68, height: s * 0.20), p);
      canvas.rotate(math.pi / 4);
    }
    canvas.drawCircle(Offset.zero, s * 0.22, Paint()..color = const Color(0xFF37474F));
    canvas.restore();
  }

  // 19. PENCIL: Green craft pencil
  void _drawPencil(Canvas canvas, double cx, double cy, double s) {
    canvas.save();
    canvas.translate(cx, cy);
    canvas.rotate(-math.pi / 4);
    // Green body
    canvas.drawRect(Rect.fromLTWH(-s * 0.08, -s * 0.25, s * 0.16, s * 0.40), Paint()..color = const Color(0xFF4CAF50));
    // Wood tip
    final tipPath = Path()
      ..moveTo(-s * 0.08, s * 0.15)
      ..lineTo(0, s * 0.32)
      ..lineTo(s * 0.08, s * 0.15)
      ..close();
    canvas.drawPath(tipPath, Paint()..color = const Color(0xFFFFCC80));
    // Graphite point
    canvas.drawCircle(Offset(0, s * 0.28), s * 0.04, Paint()..color = const Color(0xFF212121));
    canvas.restore();
  }

  // 20. DICE: Voxel dice
  void _drawDice(Canvas canvas, double cx, double cy, double s) {
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromCenter(center: Offset(cx, cy), width: s * 0.60, height: s * 0.60), const Radius.circular(5)),
      Paint()..color = const Color(0xFFECEFF1),
    );
    // Pips
    final pipPaint = Paint()..color = const Color(0xFF263238);
    final off = s * 0.16;
    canvas.drawCircle(Offset(cx - off, cy - off), s * 0.04, pipPaint);
    canvas.drawCircle(Offset(cx + off, cy - off), s * 0.04, pipPaint);
    canvas.drawCircle(Offset(cx, cy), s * 0.04, pipPaint);
    canvas.drawCircle(Offset(cx - off, cy + off), s * 0.04, pipPaint);
    canvas.drawCircle(Offset(cx + off, cy + off), s * 0.04, pipPaint);
  }

  // 21. SPARKLES: Magical sparkles
  void _drawSparkles(Canvas canvas, double cx, double cy, double s) {
    final scale = 0.8 + 0.2 * math.sin(anim * 4 * math.pi);
    final p = Paint()..color = const Color(0xFF00E5FF);

    void drawStar(double x, double y, double r) {
      final path = Path()
        ..moveTo(x, y - r)
        ..lineTo(x + r * 0.3, y - r * 0.3)
        ..lineTo(x + r, y)
        ..lineTo(x + r * 0.3, y + r * 0.3)
        ..lineTo(x, y + r)
        ..lineTo(x - r * 0.3, y + r * 0.3)
        ..lineTo(x - r, y)
        ..lineTo(x - r * 0.3, y - r * 0.3)
        ..close();
      canvas.drawPath(path, p);
    }

    drawStar(cx - s * 0.08, cy - s * 0.08, s * 0.24 * scale);
    drawStar(cx + s * 0.20, cy + s * 0.16, s * 0.14 * (1.2 - scale));
  }

  // 22. GRASS BLOCK: 3D isometric Minecraft grass block
  void _drawGrassBlock(Canvas canvas, double cx, double cy, double s) {
    final w2 = s * 0.36;
    final h2 = s * 0.20;

    // Top green grass face
    final topFace = Path()
      ..moveTo(cx, cy - s * 0.32)
      ..lineTo(cx + w2, cy - s * 0.32 + h2)
      ..lineTo(cx, cy - s * 0.32 + 2 * h2)
      ..lineTo(cx - w2, cy - s * 0.32 + h2)
      ..close();
    canvas.drawPath(topFace, Paint()..color = const Color(0xFF4CAF50));

    // Left dirt face
    final leftFace = Path()
      ..moveTo(cx - w2, cy - s * 0.32 + h2)
      ..lineTo(cx, cy - s * 0.32 + 2 * h2)
      ..lineTo(cx, cy + s * 0.28)
      ..lineTo(cx - w2, cy + s * 0.28 - h2)
      ..close();
    canvas.drawPath(leftFace, Paint()..color = const Color(0xFF6D4C41));

    // Right dirt face
    final rightFace = Path()
      ..moveTo(cx, cy - s * 0.32 + 2 * h2)
      ..lineTo(cx + w2, cy - s * 0.32 + h2)
      ..lineTo(cx + w2, cy + s * 0.28 - h2)
      ..lineTo(cx, cy + s * 0.28)
      ..close();
    canvas.drawPath(rightFace, Paint()..color = const Color(0xFF4E342E));

    // Grass overhangs on left and right sides
    final overLeft = Path()
      ..moveTo(cx - w2, cy - s * 0.32 + h2)
      ..lineTo(cx, cy - s * 0.32 + 2 * h2)
      ..lineTo(cx, cy - s * 0.32 + 2 * h2 + s * 0.08)
      ..lineTo(cx - w2, cy - s * 0.32 + h2 + s * 0.08)
      ..close();
    canvas.drawPath(overLeft, Paint()..color = const Color(0xFF388E3C));

    final overRight = Path()
      ..moveTo(cx, cy - s * 0.32 + 2 * h2)
      ..lineTo(cx + w2, cy - s * 0.32 + h2)
      ..lineTo(cx + w2, cy - s * 0.32 + h2 + s * 0.08)
      ..lineTo(cx, cy - s * 0.32 + 2 * h2 + s * 0.08)
      ..close();
    canvas.drawPath(overRight, Paint()..color = const Color(0xFF2E7D32));
  }

  // 23. STEVE: Animated Steve avatar pixel head
  void _drawSteve(Canvas canvas, double cx, double cy, double s) {
    // Head base (Skin tone)
    canvas.drawRect(Rect.fromCenter(center: Offset(cx, cy), width: s * 0.65, height: s * 0.65), Paint()..color = const Color(0xFFD7A17C));
    // Hair (Brown)
    canvas.drawRect(Rect.fromLTWH(cx - s * 0.325, cy - s * 0.325, s * 0.65, s * 0.22), Paint()..color = const Color(0xFF4E342E));
    canvas.drawRect(Rect.fromLTWH(cx - s * 0.325, cy - s * 0.15, s * 0.12, s * 0.18), Paint()..color = const Color(0xFF4E342E));
    canvas.drawRect(Rect.fromLTWH(cx + s * 0.205, cy - s * 0.15, s * 0.12, s * 0.18), Paint()..color = const Color(0xFF4E342E));

    // Eyes: White + Cyan/Blue pupil
    final eyeY = cy - s * 0.02;
    canvas.drawRect(Rect.fromLTWH(cx - s * 0.22, eyeY, s * 0.14, s * 0.08), Paint()..color = Colors.white);
    canvas.drawRect(Rect.fromLTWH(cx + s * 0.08, eyeY, s * 0.14, s * 0.08), Paint()..color = Colors.white);
    canvas.drawRect(Rect.fromLTWH(cx - s * 0.16, eyeY, s * 0.08, s * 0.08), Paint()..color = const Color(0xFF00796B));
    canvas.drawRect(Rect.fromLTWH(cx + s * 0.14, eyeY, s * 0.08, s * 0.08), Paint()..color = const Color(0xFF00796B));

    // Nose
    canvas.drawRect(Rect.fromCenter(center: Offset(cx, cy + s * 0.08), width: s * 0.12, height: s * 0.08), Paint()..color = const Color(0xFFBD8262));
    // Mouth / Goatee
    canvas.drawRect(Rect.fromCenter(center: Offset(cx, cy + s * 0.18), width: s * 0.24, height: s * 0.08), Paint()..color = const Color(0xFF5D4037));
  }

  // 24. LANTERN: Hanging lantern with gentle sway
  void _drawLantern(Canvas canvas, double cx, double cy, double s) {
    final sway = math.sin(anim * 2 * math.pi) * 0.08;

    canvas.save();
    canvas.translate(cx, cy - s * 0.30);
    canvas.rotate(sway);

    // Hanging chain
    canvas.drawLine(Offset.zero, Offset(0, s * 0.18), Paint()..color = const Color(0xFF78909C)..strokeWidth = 2.0);

    // Lantern top cap
    canvas.drawRect(Rect.fromCenter(center: Offset(0, s * 0.22), width: s * 0.40, height: s * 0.08), Paint()..color = const Color(0xFF37474F));

    // Glass body with warm glowing flame
    canvas.drawRect(Rect.fromCenter(center: Offset(0, s * 0.40), width: s * 0.32, height: s * 0.28), Paint()..color = const Color(0xFFFF9800));
    canvas.drawRect(Rect.fromCenter(center: Offset(0, s * 0.40), width: s * 0.16, height: s * 0.16), Paint()..color = const Color(0xFFFFF9C4));

    // Metal corner struts
    final strut = Paint()..color = const Color(0xFF263238)..strokeWidth = 2.0;
    canvas.drawLine(Offset(-s * 0.16, s * 0.26), Offset(-s * 0.16, s * 0.54), strut);
    canvas.drawLine(Offset(s * 0.16, s * 0.26), Offset(s * 0.16, s * 0.54), strut);

    // Base plate
    canvas.drawRect(Rect.fromCenter(center: Offset(0, s * 0.56), width: s * 0.36, height: s * 0.06), Paint()..color = const Color(0xFF37474F));
    canvas.restore();
  }

  // 25. RAIN CLOUD: Stormy cloud with falling raindrops
  void _drawRainCloud(Canvas canvas, double cx, double cy, double s) {
    // Cloud
    _drawCloud(canvas, cx, cy - s * 0.12, s * 0.9);

    // Raindrops
    final dropPaint = Paint()..color = const Color(0xFF40C4FF)..strokeWidth = 1.8;
    for (var i = 0; i < 3; i++) {
      final dropAnim = (anim * 2.0 + i * 0.33) % 1.0;
      final x = cx - s * 0.20 + i * (s * 0.20);
      final y = cy + s * 0.10 + dropAnim * (s * 0.25);
      canvas.drawLine(Offset(x, y), Offset(x - 2, y + 5), dropPaint);
    }
  }

  // 26. WATER SPLASH: Splash ripples
  void _drawWaterSplash(Canvas canvas, double cx, double cy, double s) {
    _drawWaterDroplet(canvas, cx, cy - s * 0.05, s * 0.85);
    final splashPaint = Paint()..color = const Color(0xFF80D8FF)..style = PaintingStyle.stroke..strokeWidth = 1.6;
    canvas.drawOval(Rect.fromCenter(center: Offset(cx, cy + s * 0.22), width: s * 0.60, height: s * 0.18), splashPaint);
  }

  // 27. PALETTE: Color grading palette
  void _drawPalette(Canvas canvas, double cx, double cy, double s) {
    canvas.drawCircle(Offset(cx, cy), s * 0.32, Paint()..color = const Color(0xFF8D6E63));
    canvas.drawCircle(Offset(cx - s * 0.14, cy - s * 0.12), s * 0.06, Paint()..color = const Color(0xFFFF5252));
    canvas.drawCircle(Offset(cx + s * 0.02, cy - s * 0.18), s * 0.06, Paint()..color = const Color(0xFFFFEB3B));
    canvas.drawCircle(Offset(cx + s * 0.16, cy - s * 0.06), s * 0.06, Paint()..color = const Color(0xFF4CAF50));
    canvas.drawCircle(Offset(cx + s * 0.12, cy + s * 0.12), s * 0.06, Paint()..color = const Color(0xFF2196F3));
  }

  // 28. CAMERA: Aperture / Exposure
  void _drawCamera(Canvas canvas, double cx, double cy, double s) {
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromCenter(center: Offset(cx, cy), width: s * 0.65, height: s * 0.48), const Radius.circular(4)),
      Paint()..color = const Color(0xFF455A64),
    );
    canvas.drawCircle(Offset(cx, cy), s * 0.16, Paint()..color = const Color(0xFF263238));
    canvas.drawCircle(Offset(cx, cy), s * 0.10, Paint()..color = const Color(0xFF80D8FF));
  }

  // 29. CONTRAST: Contrast half-circle
  void _drawContrast(Canvas canvas, double cx, double cy, double s) {
    canvas.drawCircle(Offset(cx, cy), s * 0.30, Paint()..color = const Color(0xFF212121));
    final half = Path()
      ..addArc(Rect.fromCircle(center: Offset(cx, cy), radius: s * 0.30), -math.pi / 2, math.pi)
      ..close();
    canvas.drawPath(half, Paint()..color = Colors.white);
  }

  // 30. FILM: Tone mapping film strip
  void _drawFilm(Canvas canvas, double cx, double cy, double s) {
    canvas.drawRect(Rect.fromCenter(center: Offset(cx, cy), width: s * 0.55, height: s * 0.45), Paint()..color = const Color(0xFF212121));
    final holePaint = Paint()..color = Colors.white70;
    canvas.drawRect(Rect.fromLTWH(cx - s * 0.24, cy - s * 0.18, s * 0.08, s * 0.08), holePaint);
    canvas.drawRect(Rect.fromLTWH(cx + s * 0.16, cy - s * 0.18, s * 0.08, s * 0.08), holePaint);
    canvas.drawRect(Rect.fromLTWH(cx - s * 0.24, cy + s * 0.10, s * 0.08, s * 0.08), holePaint);
    canvas.drawRect(Rect.fromLTWH(cx + s * 0.16, cy + s * 0.10, s * 0.08, s * 0.08), holePaint);
  }

  @override
  bool shouldRepaint(covariant _VoxelIconPainter oldDelegate) {
    return oldDelegate.anim != anim || oldDelegate.type != type || oldDelegate.colorOverride != colorOverride;
  }
}
