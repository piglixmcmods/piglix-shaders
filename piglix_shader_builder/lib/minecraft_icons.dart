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

/// A crisp static Minecraft-style pixel-art icon matching user reference images
class AnimatedMinecraftIcon extends StatelessWidget {
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
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(size, size),
      painter: _VoxelIconPainter(
        type: type,
        anim: 0.0, // Static, completely still, zero movement
        colorOverride: colorOverride,
      ),
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

  // 1. SUN: High-detail pixel-art sun with dark outline, amber rim, and 8 pixel rays matching user reference
  void _drawSun(Canvas canvas, double cx, double cy, double s) {
    final pulse = 1.0 + 0.05 * math.sin(anim * 2 * math.pi);
    final r = s * 0.22 * pulse;

    // Ambient solar bloom
    canvas.drawCircle(
      Offset(cx, cy),
      s * 0.44 * pulse,
      Paint()..color = (colorOverride ?? const Color(0xFFFFB300)).withOpacity(0.30),
    );

    final rayPaint = Paint()..color = (colorOverride ?? const Color(0xFFFDD835));
    final rayOutline = Paint()
      ..color = const Color(0xFF26180B)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    // 8 Cardinal and Diagonal Pixel Rays with dark outlines
    for (var i = 0; i < 8; i++) {
      final angle = i * (math.pi / 4);
      final dist = s * 0.32 * pulse;
      final rx = cx + dist * math.cos(angle);
      final ry = cy + dist * math.sin(angle);
      final rayRect = Rect.fromCenter(
        center: Offset(rx, ry),
        width: s * 0.10,
        height: s * 0.10,
      );
      canvas.drawRect(rayRect, rayPaint);
      canvas.drawRect(rayRect, rayOutline);
    }

    // Outer dark pixel outline
    canvas.drawCircle(
      Offset(cx, cy),
      r + 1.6,
      Paint()..color = const Color(0xFF26180B),
    );

    // Warm amber rim
    canvas.drawCircle(
      Offset(cx, cy),
      r,
      Paint()..color = const Color(0xFFF57F17),
    );

    // Brilliant golden yellow face
    canvas.drawCircle(
      Offset(cx, cy),
      r * 0.82,
      Paint()..color = (colorOverride ?? const Color(0xFFFFEB3B)),
    );

    // Top-left white specular glint
    canvas.drawCircle(
      Offset(cx - r * 0.32, cy - r * 0.32),
      r * 0.24,
      Paint()..color = const Color(0xFFFFFDE7),
    );
  }

  // 2. MOON: High-detail pixel crescent moon with dark outline, night aura & star matching user reference
  void _drawMoon(Canvas canvas, double cx, double cy, double s) {
    final twinkle = 0.5 + 0.5 * math.sin(anim * 4 * math.pi);

    // Deep blue night sky glow aura
    canvas.drawCircle(
      Offset(cx, cy),
      s * 0.45,
      Paint()..color = const Color(0xFF312E81).withOpacity(0.35),
    );

    // Crescent Path
    final outerRadius = s * 0.30;
    final innerRadius = s * 0.28;
    final innerCenter = Offset(cx + s * 0.14, cy - s * 0.04);

    final moonPath = Path()
      ..addOval(Rect.fromCircle(center: Offset(cx, cy), radius: outerRadius));
    final cutPath = Path()
      ..addOval(Rect.fromCircle(center: innerCenter, radius: innerRadius));
    final crescent = Path.combine(PathOperation.difference, moonPath, cutPath);

    // Dark outline
    canvas.drawPath(
      crescent,
      Paint()
        ..color = const Color(0xFF1E1B4B)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0
        ..strokeJoin = StrokeJoin.round,
    );

    // Crescent body (light periwinkle/white)
    canvas.drawPath(
      crescent,
      Paint()..color = (colorOverride ?? const Color(0xFFE0E7FF)),
    );

    // Inner shadow accent (soft lavender blue)
    final shadowPath = Path()
      ..addOval(Rect.fromCircle(center: Offset(cx - s * 0.03, cy + s * 0.03), radius: outerRadius * 0.88));
    final innerShadow = Path.combine(PathOperation.intersect, crescent, shadowPath);
    canvas.drawPath(
      innerShadow,
      Paint()..color = const Color(0xFFC7D2FE).withOpacity(0.70),
    );

    // Small pixel star in the crescent nook (matching user reference)
    final starX = cx + s * 0.18;
    final starY = cy - s * 0.10;
    final starPaint = Paint()..color = Colors.white.withOpacity(0.40 + 0.60 * twinkle);
    canvas.drawRect(Rect.fromCenter(center: Offset(starX, starY), width: 3, height: 3), starPaint);
    canvas.drawRect(Rect.fromCenter(center: Offset(starX - 2.5, starY), width: 2, height: 1.5), starPaint);
    canvas.drawRect(Rect.fromCenter(center: Offset(starX + 2.5, starY), width: 2, height: 1.5), starPaint);
    canvas.drawRect(Rect.fromCenter(center: Offset(starX, starY - 2.5), width: 1.5, height: 2), starPaint);
    canvas.drawRect(Rect.fromCenter(center: Offset(starX, starY + 2.5), width: 1.5, height: 2), starPaint);
  }

  // 3. CLOUD: High-detail pixel cumulus cloud with 3 puffy domes matching user reference
  void _drawCloud(Canvas canvas, double cx, double cy, double s) {
    final bob = math.sin(anim * 2 * math.pi) * (s * 0.03);
    final y = cy + bob;

    // Cloud silhouette path: 3 rounded domes with flat bottom
    final cloudPath = Path()
      ..addOval(Rect.fromCircle(center: Offset(cx - s * 0.18, y + s * 0.04), radius: s * 0.18)) // Left dome
      ..addOval(Rect.fromCircle(center: Offset(cx + s * 0.02, y - s * 0.06), radius: s * 0.22)) // Center tall dome
      ..addOval(Rect.fromCircle(center: Offset(cx + s * 0.20, y + s * 0.02), radius: s * 0.16)) // Right dome
      ..addRRect(RRect.fromRectAndRadius(
          Rect.fromLTWH(cx - s * 0.36, y, s * 0.72, s * 0.22),
          const Radius.circular(6))); // Flat base

    // Dark bold pixel outline
    canvas.drawPath(
      cloudPath,
      Paint()
        ..color = const Color(0xFF263238)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0
        ..strokeJoin = StrokeJoin.round,
    );

    // Bottom shadow fill
    canvas.drawPath(cloudPath, Paint()..color = const Color(0xFF90A4AE));

    // Mid billow fill
    final midBody = Path()
      ..addOval(Rect.fromCircle(center: Offset(cx - s * 0.18, y + s * 0.01), radius: s * 0.16))
      ..addOval(Rect.fromCircle(center: Offset(cx + s * 0.02, y - s * 0.08), radius: s * 0.20))
      ..addOval(Rect.fromCircle(center: Offset(cx + s * 0.20, y), radius: s * 0.14))
      ..addRRect(RRect.fromRectAndRadius(
          Rect.fromLTWH(cx - s * 0.33, y - s * 0.02, s * 0.66, s * 0.16),
          const Radius.circular(4)));
    canvas.drawPath(midBody, Paint()..color = const Color(0xFFECEFF1));

    // Top bright white highlights
    final topPuff = Path()
      ..addOval(Rect.fromCircle(center: Offset(cx - s * 0.16, y - s * 0.04), radius: s * 0.12))
      ..addOval(Rect.fromCircle(center: Offset(cx + s * 0.02, y - s * 0.12), radius: s * 0.15))
      ..addOval(Rect.fromCircle(center: Offset(cx + s * 0.18, y - s * 0.03), radius: s * 0.10));
    canvas.drawPath(topPuff, Paint()..color = Colors.white);
  }

  // 4. LIGHTBULB: Glowing pixel-art lightbulb with dark outline & reflection matching user reference
  void _drawLightbulb(Canvas canvas, double cx, double cy, double s) {
    final glow = 0.85 + 0.15 * math.sin(anim * 3 * math.pi);

    // Warm ambient halo
    canvas.drawCircle(
      Offset(cx, cy - s * 0.06),
      s * 0.45,
      Paint()..color = const Color(0xFFFFD54F).withOpacity(0.35 * glow),
    );

    // Bulb glass path
    final bulbPath = Path()
      ..addOval(Rect.fromCircle(center: Offset(cx, cy - s * 0.08), radius: s * 0.27))
      ..addRRect(RRect.fromRectAndRadius(
          Rect.fromCenter(center: Offset(cx, cy + s * 0.10), width: s * 0.26, height: s * 0.20),
          const Radius.circular(4)));

    // Bold dark outline
    canvas.drawPath(
      bulbPath,
      Paint()
        ..color = const Color(0xFF18181B)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.4
        ..strokeJoin = StrokeJoin.round,
    );

    // Warm yellow glass body
    canvas.drawPath(bulbPath, Paint()..color = const Color(0xFFFFEB3B));

    // Bottom warm amber gradient/shade
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset(cx, cy + s * 0.10), width: s * 0.22, height: s * 0.16),
        const Radius.circular(3),
      ),
      Paint()..color = const Color(0xFFF59E0B),
    );

    // Top-left specular curved white highlight
    final highlightPath = Path()
      ..addArc(
        Rect.fromCircle(center: Offset(cx, cy - s * 0.08), radius: s * 0.20),
        -math.pi * 0.85,
        math.pi * 0.45,
      );
    canvas.drawPath(
      highlightPath,
      Paint()
        ..color = Colors.white.withOpacity(0.90)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.4
        ..strokeCap = StrokeCap.round,
    );

    // Screw base (brass neck with horizontal ridges)
    final baseRect = Rect.fromCenter(
      center: Offset(cx, cy + s * 0.24),
      width: s * 0.20,
      height: s * 0.10,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(baseRect, const Radius.circular(2)),
      Paint()..color = const Color(0xFFF59E0B),
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(baseRect, const Radius.circular(2)),
      Paint()
        ..color = const Color(0xFF18181B)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.8,
    );

    // Thread lines
    final threadPaint = Paint()..color = const Color(0xFF78350F)..strokeWidth = 1.2;
    canvas.drawLine(Offset(cx - s * 0.08, cy + s * 0.22), Offset(cx + s * 0.08, cy + s * 0.22), threadPaint);
    canvas.drawLine(Offset(cx - s * 0.08, cy + s * 0.26), Offset(cx + s * 0.08, cy + s * 0.26), threadPaint);

    // Black contact tip
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset(cx, cy + s * 0.31), width: s * 0.10, height: s * 0.04),
        const Radius.circular(1.5),
      ),
      Paint()..color = const Color(0xFF18181B),
    );
  }

  // 5. GOLD BLOCK: 3D Isometric Minecraft Block of Gold with beveled brick panels & gleam
  void _drawGoldBlock(Canvas canvas, double cx, double cy, double s) {
    final gleamPos = (anim * 2.0) - 0.5;
    final w2 = s * 0.36;
    final h2 = s * 0.21;

    // 1. Top face
    final topFace = Path()
      ..moveTo(cx, cy - s * 0.32)
      ..lineTo(cx + w2, cy - s * 0.32 + h2)
      ..lineTo(cx, cy - s * 0.32 + 2 * h2)
      ..lineTo(cx - w2, cy - s * 0.32 + h2)
      ..close();
    canvas.drawPath(topFace, Paint()..color = const Color(0xFFFFF176));

    // Top face inner border & brick panel lines
    final topBorder = Path()
      ..moveTo(cx, cy - s * 0.28)
      ..lineTo(cx + w2 * 0.8, cy - s * 0.32 + h2)
      ..lineTo(cx, cy - s * 0.36 + 2 * h2)
      ..lineTo(cx - w2 * 0.8, cy - s * 0.32 + h2)
      ..close();
    canvas.drawPath(topBorder, Paint()..color = const Color(0xFFFFD54F)..style = PaintingStyle.stroke..strokeWidth = 1.2);

    // 2. Left face (Mid golden amber)
    final leftFace = Path()
      ..moveTo(cx - w2, cy - s * 0.32 + h2)
      ..lineTo(cx, cy - s * 0.32 + 2 * h2)
      ..lineTo(cx, cy + s * 0.30)
      ..lineTo(cx - w2, cy + s * 0.30 - h2)
      ..close();
    canvas.drawPath(leftFace, Paint()..color = const Color(0xFFFBC02D));

    // Left face inner border
    final leftBorder = Path()
      ..moveTo(cx - w2 * 0.85, cy - s * 0.28 + h2)
      ..lineTo(cx - w2 * 0.15, cy - s * 0.30 + 2 * h2)
      ..lineTo(cx - w2 * 0.15, cy + s * 0.24)
      ..lineTo(cx - w2 * 0.85, cy + s * 0.24 - h2)
      ..close();
    canvas.drawPath(leftBorder, Paint()..color = const Color(0xFFF57F17)..style = PaintingStyle.stroke..strokeWidth = 1.0);

    // 3. Right face (Deep bronze shadow)
    final rightFace = Path()
      ..moveTo(cx, cy - s * 0.32 + 2 * h2)
      ..lineTo(cx + w2, cy - s * 0.32 + h2)
      ..lineTo(cx + w2, cy + s * 0.30 - h2)
      ..lineTo(cx, cy + s * 0.30)
      ..close();
    canvas.drawPath(rightFace, Paint()..color = const Color(0xFFE65100));

    // 4. Corner rivets/studs
    final rivetPaint = Paint()..color = const Color(0xFFFF8F00);
    canvas.drawRect(Rect.fromCenter(center: Offset(cx, cy - s * 0.30), width: 2, height: 2), Paint()..color = Colors.white);
    canvas.drawRect(Rect.fromCenter(center: Offset(cx, cy + s * 0.28), width: 2.5, height: 2.5), rivetPaint);

    // Diagonal specular gleam sweep
    if (gleamPos >= 0.0 && gleamPos <= 1.0) {
      canvas.save();
      canvas.clipPath(topFace);
      final gx = (cx - w2) + (2 * w2) * gleamPos;
      canvas.drawRect(
        Rect.fromCenter(center: Offset(gx, cy - s * 0.15), width: s * 0.15, height: s * 0.45),
        Paint()..color = Colors.white.withOpacity(0.70),
      );
      canvas.restore();
    }
  }

  // 6. MOUNTAIN: Stepped 3D Minecraft jagged peak with snowcap & spruce silhouettes
  void _drawMountain(Canvas canvas, double cx, double cy, double s) {
    // Background second ridge for 3D depth
    final bgRidge = Path()
      ..moveTo(cx + s * 0.10, cy - s * 0.18)
      ..lineTo(cx + s * 0.40, cy + s * 0.30)
      ..lineTo(cx - s * 0.05, cy + s * 0.30)
      ..close();
    canvas.drawPath(bgRidge, Paint()..color = const Color(0xFF263238));

    // Foreground Mountain: Left sun-lit granite face
    final litPath = Path()
      ..moveTo(cx - s * 0.02, cy - s * 0.34)
      ..lineTo(cx + s * 0.10, cy - s * 0.08)
      ..lineTo(cx + s * 0.02, cy + s * 0.08)
      ..lineTo(cx + s * 0.04, cy + s * 0.30)
      ..lineTo(cx - s * 0.36, cy + s * 0.30)
      ..close();
    canvas.drawPath(litPath, Paint()..color = const Color(0xFF90A4AE));

    // Right basalt shadow face
    final shadowPath = Path()
      ..moveTo(cx - s * 0.02, cy - s * 0.34)
      ..lineTo(cx + s * 0.36, cy + s * 0.30)
      ..lineTo(cx + s * 0.04, cy + s * 0.30)
      ..lineTo(cx + s * 0.02, cy + s * 0.08)
      ..lineTo(cx + s * 0.10, cy - s * 0.08)
      ..close();
    canvas.drawPath(shadowPath, Paint()..color = const Color(0xFF455A64));

    // Stepped crisp snowcap
    final snowPath = Path()
      ..moveTo(cx - s * 0.02, cy - s * 0.34)
      ..lineTo(cx + s * 0.15, cy - s * 0.12)
      ..lineTo(cx + s * 0.04, cy - s * 0.06)
      ..lineTo(cx - s * 0.02, cy - s * 0.10)
      ..lineTo(cx - s * 0.08, cy - s * 0.06)
      ..lineTo(cx - s * 0.16, cy - s * 0.12)
      ..close();
    canvas.drawPath(snowPath, Paint()..color = Colors.white);

    // Icy blue snow shadow crevice
    final iceShadow = Path()
      ..moveTo(cx - s * 0.02, cy - s * 0.34)
      ..lineTo(cx + s * 0.15, cy - s * 0.12)
      ..lineTo(cx + s * 0.05, cy - s * 0.08)
      ..close();
    canvas.drawPath(iceShadow, Paint()..color = const Color(0xFFB3E5FC));

    // Spruce pine silhouettes at mountain base
    final pinePaint = Paint()..color = const Color(0xFF1B5E20);
    void drawPine(double px, double py, double pw, double ph) {
      final p = Path()
        ..moveTo(px, py - ph)
        ..lineTo(px + pw / 2, py)
        ..lineTo(px - pw / 2, py)
        ..close();
      canvas.drawPath(p, pinePaint);
      canvas.drawRect(Rect.fromCenter(center: Offset(px, py + ph * 0.15), width: pw * 0.25, height: ph * 0.3), Paint()..color = const Color(0xFF3E2723));
    }
    drawPine(cx - s * 0.22, cy + s * 0.26, s * 0.14, s * 0.18);
    drawPine(cx - s * 0.08, cy + s * 0.28, s * 0.10, s * 0.14);
  }

  // 7. TORCH: Authentic Minecraft wall torch with 4-tier voxel flame & rising sparks
  void _drawTorch(Canvas canvas, double cx, double cy, double s) {
    final flicker = math.sin(anim * 8 * math.pi) * (s * 0.025);

    // Warm radial glow halo
    canvas.drawCircle(
      Offset(cx, cy - s * 0.16 + flicker),
      s * 0.44,
      Paint()..color = const Color(0xFFFF9800).withOpacity(0.30),
    );

    // 3-Tone oak handle with shadow edge
    canvas.drawRect(
      Rect.fromCenter(center: Offset(cx, cy + s * 0.14), width: s * 0.13, height: s * 0.42),
      Paint()..color = const Color(0xFF5D4037),
    );
    // Right shadow edge
    canvas.drawRect(
      Rect.fromLTWH(cx + s * 0.025, cy - s * 0.07, s * 0.04, s * 0.42),
      Paint()..color = const Color(0xFF3E2723),
    );
    // Wood grain knot
    canvas.drawRect(
      Rect.fromLTWH(cx - s * 0.04, cy + s * 0.12, s * 0.035, s * 0.05),
      Paint()..color = const Color(0xFF8D6E63),
    );

    // Charred obsidian torch head collar
    canvas.drawRect(
      Rect.fromCenter(center: Offset(cx, cy - s * 0.08), width: s * 0.15, height: s * 0.07),
      Paint()..color = const Color(0xFF212121),
    );
    canvas.drawRect(
      Rect.fromLTWH(cx - s * 0.075, cy - s * 0.115, s * 0.06, s * 0.07),
      Paint()..color = const Color(0xFF424242),
    );

    // 4-Tier animated voxel flame
    final flameY = cy - s * 0.22 + flicker;

    // Outer crimson ember base
    canvas.drawRect(
      Rect.fromCenter(center: Offset(cx, flameY + s * 0.04), width: s * 0.24, height: s * 0.18),
      Paint()..color = const Color(0xFFD32F2F),
    );
    // Mid vivid orange flame
    canvas.drawRect(
      Rect.fromCenter(center: Offset(cx, flameY), width: s * 0.20, height: s * 0.20),
      Paint()..color = const Color(0xFFFF6D00),
    );
    // Inner blazing yellow flame
    canvas.drawRect(
      Rect.fromCenter(center: Offset(cx, flameY - s * 0.02), width: s * 0.13, height: s * 0.13),
      Paint()..color = const Color(0xFFFFD600),
    );
    // White-hot core
    canvas.drawRect(
      Rect.fromCenter(center: Offset(cx, flameY - s * 0.02), width: s * 0.06, height: s * 0.06),
      Paint()..color = const Color(0xFFFFFDE7),
    );

    // 3 Floating rising ember sparks
    final sparkPaint = Paint()..color = const Color(0xFFFFD54F);
    for (var i = 0; i < 3; i++) {
      final spAnim = (anim * 1.5 + i * 0.33) % 1.0;
      final sx = cx + math.sin(spAnim * 2 * math.pi + i) * (s * 0.12);
      final sy = flameY - s * 0.08 - spAnim * (s * 0.24);
      final sz = s * 0.035 * (1.0 - spAnim * 0.5);
      canvas.drawRect(Rect.fromCenter(center: Offset(sx, sy), width: sz, height: sz), sparkPaint..color = const Color(0xFFFFD54F).withOpacity(1.0 - spAnim));
    }
  }

  // 8. WATER DROPLET: Crystal 3D fluid droplet with specular glare & expanding ripple pool
  void _drawWaterDroplet(Canvas canvas, double cx, double cy, double s) {
    final bob = math.sin(anim * 2 * math.pi) * (s * 0.035);
    final y = cy + bob - s * 0.04;

    // Ambient aqua halo
    canvas.drawCircle(Offset(cx, y), s * 0.36, Paint()..color = const Color(0xFF00E5FF).withOpacity(0.20));

    // Teardrop body
    final dropPath = Path()
      ..moveTo(cx, y - s * 0.32)
      ..cubicTo(cx + s * 0.30, y - s * 0.04, cx + s * 0.28, y + s * 0.28, cx, y + s * 0.30)
      ..cubicTo(cx - s * 0.28, y + s * 0.28, cx - s * 0.30, y - s * 0.04, cx, y - s * 0.32)
      ..close();

    canvas.drawPath(
      dropPath,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF80D8FF), Color(0xFF00B0FF), Color(0xFF01579B)],
        ).createShader(Rect.fromCircle(center: Offset(cx, y), radius: s * 0.35)),
    );

    // Specular curved glare arc
    final glarePath = Path()
      ..moveTo(cx - s * 0.16, y)
      ..cubicTo(cx - s * 0.18, y - s * 0.14, cx - s * 0.08, y - s * 0.22, cx, y - s * 0.24);
    canvas.drawPath(
      glarePath,
      Paint()..color = Colors.white.withOpacity(0.90)..style = PaintingStyle.stroke..strokeWidth = 2.0..strokeCap = StrokeCap.round,
    );
    // Lower secondary bounce glint
    canvas.drawCircle(Offset(cx + s * 0.10, y + s * 0.14), s * 0.04, Paint()..color = const Color(0xFFB3E5FC).withOpacity(0.80));

    // Base ripple pool
    final ripR = (anim * 2.0) % 1.0;
    canvas.drawOval(
      Rect.fromCenter(center: Offset(cx, cy + s * 0.32), width: s * 0.50 * ripR, height: s * 0.14 * ripR),
      Paint()..color = const Color(0xFF80D8FF).withOpacity(1.0 - ripR)..style = PaintingStyle.stroke..strokeWidth = 1.2,
    );
  }

  // 9. WAVES: 3-tiered Minecraft ocean waves with white-crested pixel seafoam
  void _drawWaves(Canvas canvas, double cx, double cy, double s) {
    final shift = anim * 2 * math.pi;

    final waveColors = [
      const Color(0xFF0D47A1), // Deep navy
      const Color(0xFF00ACC1), // Tropical turquoise
      (colorOverride ?? const Color(0xFF00E5FF)), // Vibrant surface aqua
    ];

    for (var i = 0; i < 3; i++) {
      final wy = cy - s * 0.18 + i * (s * 0.18);
      final phaseOffset = shift + i * 1.6;

      final wavePaint = Paint()
        ..color = waveColors[i]
        ..style = PaintingStyle.stroke
        ..strokeWidth = s * 0.075
        ..strokeCap = StrokeCap.round;

      final p = Path();
      p.moveTo(cx - s * 0.38, wy);
      for (var x = -s * 0.38; x <= s * 0.38; x += 3.0) {
        final dy = math.sin((x / s * 9) + phaseOffset) * (s * 0.045);
        p.lineTo(cx + x, wy + dy);
      }
      canvas.drawPath(p, wavePaint);

      // White pixel seafoam caps on crests
      final crestX1 = cx + math.cos(phaseOffset) * (s * 0.20);
      final crestY1 = wy + math.sin((crestX1 - cx) / s * 9 + phaseOffset) * (s * 0.045) - 2;
      canvas.drawRect(Rect.fromCenter(center: Offset(crestX1, crestY1), width: s * 0.08, height: s * 0.04), Paint()..color = Colors.white);
    }
  }

  // 10. DIAMOND: Flawless cut Minecraft diamond gem with multi-faceted crown & rotating star glint
  void _drawDiamond(Canvas canvas, double cx, double cy, double s) {
    final sparkle = (math.sin(anim * 4 * math.pi) * 0.5 + 0.5).clamp(0.0, 1.0);

    // Radiant cyan aura
    canvas.drawCircle(Offset(cx, cy), s * 0.40, Paint()..color = const Color(0xFF00E5FF).withOpacity(0.30));

    // Outer dark cyan outline
    final outerPath = Path()
      ..moveTo(cx, cy - s * 0.32)
      ..lineTo(cx + s * 0.34, cy - s * 0.08)
      ..lineTo(cx, cy + s * 0.36)
      ..lineTo(cx - s * 0.34, cy - s * 0.08)
      ..close();
    canvas.drawPath(outerPath, Paint()..color = const Color(0xFF006064));

    // Pavilion body (Deep cyan)
    final pavPath = Path()
      ..moveTo(cx - s * 0.32, cy - s * 0.08)
      ..lineTo(cx + s * 0.32, cy - s * 0.08)
      ..lineTo(cx, cy + s * 0.34)
      ..close();
    canvas.drawPath(pavPath, Paint()..color = const Color(0xFF0097A7));

    // Pavilion inner facets
    final pavInner = Path()
      ..moveTo(cx - s * 0.12, cy - s * 0.08)
      ..lineTo(cx + s * 0.12, cy - s * 0.08)
      ..lineTo(cx, cy + s * 0.34)
      ..close();
    canvas.drawPath(pavInner, Paint()..color = const Color(0xFF00ACC1));

    // Crown facets (Brilliant light cyan)
    final crownPath = Path()
      ..moveTo(cx, cy - s * 0.30)
      ..lineTo(cx + s * 0.32, cy - s * 0.08)
      ..lineTo(cx - s * 0.32, cy - s * 0.08)
      ..close();
    canvas.drawPath(crownPath, Paint()..color = const Color(0xFF00E5FF));

    // Top table facet (Luminous ice cyan)
    final tablePath = Path()
      ..moveTo(cx, cy - s * 0.30)
      ..lineTo(cx + s * 0.18, cy - s * 0.08)
      ..lineTo(cx - s * 0.18, cy - s * 0.08)
      ..close();
    canvas.drawPath(tablePath, Paint()..color = const Color(0xFFE0F7FA));

    // Rotating 4-point star twinkle glint
    if (sparkle > 0.35) {
      final glintPaint = Paint()..color = Colors.white.withOpacity(sparkle);
      final gx = cx + s * 0.18;
      final gy = cy - s * 0.16;
      final gw = s * 0.18 * sparkle;

      canvas.save();
      canvas.translate(gx, gy);
      canvas.rotate(anim * math.pi);
      canvas.drawLine(Offset(-gw, 0), Offset(gw, 0), glintPaint..strokeWidth = 2.0);
      canvas.drawLine(Offset(0, -gw), Offset(0, gw), glintPaint..strokeWidth = 2.0);
      canvas.drawCircle(Offset.zero, 1.8, Paint()..color = Colors.white);
      canvas.restore();
    }
  }

  // 11. CAUSTICS: Underwater shimmering caustic photon network with nodes & light ribbons
  void _drawCaustics(Canvas canvas, double cx, double cy, double s) {
    final phase = anim * 2 * math.pi;

    // Ambient water glow
    canvas.drawCircle(Offset(cx, cy), s * 0.40, Paint()..color = const Color(0xFF00B0FF).withOpacity(0.18));

    final causticPaint = Paint()
      ..color = (colorOverride ?? const Color(0xFF80D8FF)).withOpacity(0.70)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.8;

    // Overlapping intersecting caustic rings
    for (var i = 0; i < 4; i++) {
      final r = s * (0.16 + i * 0.06) + math.sin(phase + i * 1.5) * (s * 0.035);
      final ox = cx + math.cos(phase + i) * (s * 0.08);
      final oy = cy + math.sin(phase + i * 1.2) * (s * 0.08);
      canvas.drawCircle(Offset(ox, oy), r, causticPaint);

      // Bright photon intersection nodes
      final nx = ox + math.cos(phase + i * 2) * r;
      final ny = oy + math.sin(phase + i * 2) * r;
      canvas.drawCircle(Offset(nx, ny), 2.2, Paint()..color = Colors.white.withOpacity(0.85));
    }

    // Inner bright focus point
    canvas.drawCircle(Offset(cx, cy), s * 0.06, Paint()..color = const Color(0xFFE0F7FA).withOpacity(0.80));
  }

  // 12. CUBE MIRROR: 3D Holographic refractive glass cube with chromatic dispersion sheen
  void _drawCubeMirror(Canvas canvas, double cx, double cy, double s) {
    final w2 = s * 0.34;
    final h2 = s * 0.20;

    // Top face (Reflective ice)
    final topFace = Path()
      ..moveTo(cx, cy - s * 0.32)
      ..lineTo(cx + w2, cy - s * 0.32 + h2)
      ..lineTo(cx, cy - s * 0.32 + 2 * h2)
      ..lineTo(cx - w2, cy - s * 0.32 + h2)
      ..close();
    canvas.drawPath(topFace, Paint()..color = const Color(0xFFE0F7FA).withOpacity(0.90));
    canvas.drawPath(topFace, Paint()..color = Colors.white..style = PaintingStyle.stroke..strokeWidth = 1.2);

    // Left face (Prism cyan)
    final leftFace = Path()
      ..moveTo(cx - w2, cy - s * 0.32 + h2)
      ..lineTo(cx, cy - s * 0.32 + 2 * h2)
      ..lineTo(cx, cy + s * 0.30)
      ..lineTo(cx - w2, cy + s * 0.30 - h2)
      ..close();
    canvas.drawPath(leftFace, Paint()..color = const Color(0xFF80DEEA).withOpacity(0.80));
    canvas.drawPath(leftFace, Paint()..color = const Color(0xFF4DD0E1)..style = PaintingStyle.stroke..strokeWidth = 1.0);

    // Right face (Deep refractive turquoise)
    final rightFace = Path()
      ..moveTo(cx, cy - s * 0.32 + 2 * h2)
      ..lineTo(cx + w2, cy - s * 0.32 + h2)
      ..lineTo(cx + w2, cy + s * 0.30 - h2)
      ..lineTo(cx, cy + s * 0.30)
      ..close();
    canvas.drawPath(rightFace, Paint()..color = const Color(0xFF26C6DA).withOpacity(0.75));
    canvas.drawPath(rightFace, Paint()..color = const Color(0xFF00ACC1)..style = PaintingStyle.stroke..strokeWidth = 1.0);

    // Rainbow chromatic dispersion sheen across left face
    final rainbowPaint = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFFFF80AB), Color(0xFFB388FF), Color(0xFF80D8FF)],
      ).createShader(Rect.fromLTWH(cx - w2, cy - s * 0.15, w2, s * 0.35))
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;
    canvas.drawLine(Offset(cx - w2 * 0.7, cy + s * 0.10), Offset(cx - w2 * 0.2, cy - s * 0.05), rainbowPaint);

    // Specular corner glint
    canvas.drawCircle(Offset(cx, cy - s * 0.32), 2.2, Paint()..color = Colors.white);
  }

  // 13. PEARL: Cosmic Ender Pearl with void core, cyan iris & orbiting Ender particles
  void _drawPearl(Canvas canvas, double cx, double cy, double s) {
    final pulse = 1.0 + 0.07 * math.sin(anim * 3 * math.pi);

    // Mystical Ender purple aura
    canvas.drawCircle(
      Offset(cx, cy),
      s * 0.44 * pulse,
      Paint()..color = const Color(0xFFAB47BC).withOpacity(0.35),
    );

    // Deep void body
    canvas.drawCircle(
      Offset(cx, cy),
      s * 0.30,
      Paint()
        ..shader = const RadialGradient(
          colors: [Color(0xFF80CBC4), Color(0xFF00695C), Color(0xFF00251A)],
          stops: [0.0, 0.65, 1.0],
        ).createShader(Rect.fromCircle(center: Offset(cx - s * 0.08, cy - s * 0.08), radius: s * 0.30)),
    );

    // Swirling cyan iris ring
    canvas.drawCircle(
      Offset(cx, cy),
      s * 0.18,
      Paint()
        ..color = const Color(0xFF1DE9B6).withOpacity(0.65)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.8,
    );

    // Specular highlight glint
    canvas.drawCircle(Offset(cx - s * 0.10, cy - s * 0.10), s * 0.065, Paint()..color = Colors.white.withOpacity(0.95));

    // 3 Orbiting glowing Ender particles
    for (var i = 0; i < 3; i++) {
      final angle = anim * 2 * math.pi + i * (2 * math.pi / 3);
      final pr = s * 0.38;
      final px = cx + math.cos(angle) * pr;
      final py = cy + math.sin(angle) * (pr * 0.6);
      canvas.drawRect(
        Rect.fromCenter(center: Offset(px, py), width: s * 0.05, height: s * 0.05),
        Paint()..color = (i == 0 ? const Color(0xFFE040FB) : const Color(0xFF1DE9B6)),
      );
    }
  }

  // 14. PBR LAYERS: 3D hovering PBR texture sheets (Albedo, Normal, Roughness) with alignment beams
  void _drawPbrLayers(Canvas canvas, double cx, double cy, double s) {
    final float = math.sin(anim * 2 * math.pi) * (s * 0.035);

    final colors = [
      const Color(0xFF42A5F5), // Albedo (Diffuse map)
      const Color(0xFFAB47BC), // Normal (Tangent vectors)
      const Color(0xFF607D8B), // Roughness / Metallic
    ];

    for (var i = 2; i >= 0; i--) {
      final y = cy - s * 0.18 + i * (s * 0.18) + (i == 0 ? float : 0);
      final w2 = s * 0.34;
      final h2 = s * 0.15;

      final path = Path()
        ..moveTo(cx, y - h2)
        ..lineTo(cx + w2, y)
        ..lineTo(cx, y + h2)
        ..lineTo(cx - w2, y)
        ..close();

      // Plate body
      canvas.drawPath(path, Paint()..color = colors[i]);
      // Plate beveled rim
      canvas.drawPath(path, Paint()..color = Colors.white38..style = PaintingStyle.stroke..strokeWidth = 1.2);

      // Plate surface texture hint
      if (i == 0) {
        // Albedo checker/grid hint
        canvas.drawCircle(Offset(cx, y), 3, Paint()..color = Colors.white70);
      } else if (i == 1) {
        // Normal map RGB vector splash
        canvas.drawCircle(Offset(cx - s * 0.08, y), 2.5, Paint()..color = const Color(0xFF00E5FF));
        canvas.drawCircle(Offset(cx + s * 0.08, y), 2.5, Paint()..color = const Color(0xFFFF4081));
      } else {
        // Roughness gloss streak
        canvas.drawLine(Offset(cx - s * 0.12, y), Offset(cx + s * 0.12, y), Paint()..color = Colors.white54..strokeWidth = 1.4);
      }
    }

    // Cyan vertical alignment laser beam linking top to bottom sheet
    final beamPaint = Paint()..color = const Color(0xFF00E5FF).withOpacity(0.60)..strokeWidth = 1.0;
    canvas.drawLine(Offset(cx - s * 0.34, cy + float), Offset(cx - s * 0.34, cy + s * 0.18), beamPaint);
    canvas.drawLine(Offset(cx + s * 0.34, cy + float), Offset(cx + s * 0.34, cy + s * 0.18), beamPaint);
  }

  // 15. PICKAXE: High-detail 3D Minecraft Diamond Pickaxe matching user reference image 1
  void _drawPickaxe(Canvas canvas, double cx, double cy, double s) {
    canvas.save();
    canvas.translate(cx, cy);

    final p = s * 0.082; // pixel block step

    // 1. Stepped Oak Handle (diagonal pixels from bottom-left to center-right)
    final handleFill = Paint()..color = const Color(0xFF8D5A36);
    final handleShadow = Paint()..color = const Color(0xFF5C361A);
    final handleOutline = Paint()
      ..color = const Color(0xFF2E1708)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4;

    for (var i = -4; i <= 1; i++) {
      final hx = i * p * 0.95;
      final hy = -i * p * 0.95 + s * 0.04;
      final hRect = Rect.fromCenter(center: Offset(hx, hy), width: p * 1.15, height: p * 1.15);
      canvas.drawRect(hRect, handleFill);
      canvas.drawRect(Rect.fromLTWH(hRect.left + p * 0.45, hRect.top + p * 0.45, p * 0.65, p * 0.65), handleShadow);
      canvas.drawRect(hRect, handleOutline);
    }

    // 2. Diamond Pickaxe Head (curved dual-pointed arc with diamond highlight)
    final headOutline = Paint()
      ..color = const Color(0xFF00363A)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.2
      ..strokeJoin = StrokeJoin.round;
    final headDark = Paint()..color = const Color(0xFF00838F);
    final headMid = Paint()..color = const Color(0xFF00BCD4);
    final headLit = Paint()..color = const Color(0xFF00E5FF);
    final headHighlight = Paint()..color = const Color(0xFFE0F7FA);

    // Pickaxe head polygon path
    final headPath = Path()
      ..moveTo(-s * 0.16, -s * 0.38) // Left sharp tip
      ..lineTo(s * 0.28, -s * 0.36)  // Top curve
      ..lineTo(s * 0.38, -s * 0.08)  // Right sharp tip
      ..lineTo(s * 0.24, -s * 0.16)  // Inner crook
      ..lineTo(s * 0.12, -s * 0.12)  // Socket underside
      ..lineTo(-s * 0.04, -s * 0.26) // Left crook
      ..close();

    // Dark outline
    canvas.drawPath(headPath, headOutline);

    // Base body fill
    canvas.drawPath(headPath, headDark);

    // Mid diamond cyan layer
    final innerHead = Path()
      ..moveTo(-s * 0.14, -s * 0.36)
      ..lineTo(s * 0.26, -s * 0.34)
      ..lineTo(s * 0.36, -s * 0.10)
      ..lineTo(s * 0.24, -s * 0.18)
      ..lineTo(s * 0.11, -s * 0.14)
      ..lineTo(-s * 0.03, -s * 0.27)
      ..close();
    canvas.drawPath(innerHead, headMid);

    // Bright cyan spine
    final spinePath = Path()
      ..moveTo(-s * 0.12, -s * 0.36)
      ..lineTo(s * 0.24, -s * 0.34)
      ..lineTo(s * 0.24, -s * 0.22)
      ..lineTo(s * 0.06, -s * 0.24)
      ..close();
    canvas.drawPath(spinePath, headLit);

    // Signature white glint notch on top corner
    canvas.drawRect(Rect.fromCenter(center: Offset(s * 0.22, -s * 0.33), width: p * 0.9, height: p * 0.9), headHighlight);
    canvas.drawRect(Rect.fromCenter(center: Offset(-s * 0.14, -s * 0.36), width: p * 0.6, height: p * 0.6), headHighlight);
    canvas.drawRect(Rect.fromCenter(center: Offset(s * 0.36, -s * 0.10), width: p * 0.6, height: p * 0.6), headHighlight);

    // Socket center accent (wooden socket core)
    canvas.drawRect(Rect.fromCenter(center: Offset(s * 0.12, -s * 0.18), width: p * 0.9, height: p * 0.9), handleShadow);

    canvas.restore();
  }

  // 16. CHEST: Authentic 3D Isometric Minecraft Oak Chest matching user reference image 3
  void _drawChest(Canvas canvas, double cx, double cy, double s) {
    // 3D Isometric Projection Points
    final topVertex = Offset(cx, cy - s * 0.34);
    final rightTopVertex = Offset(cx + s * 0.36, cy - s * 0.14);
    final centerVertex = Offset(cx, cy + s * 0.06);
    final leftTopVertex = Offset(cx - s * 0.36, cy - s * 0.14);

    final leftBottomVertex = Offset(cx - s * 0.36, cy + s * 0.24);
    final centerBottomVertex = Offset(cx, cy + s * 0.44);
    final rightBottomVertex = Offset(cx + s * 0.36, cy + s * 0.24);

    final edgeOutline = Paint()
      ..color = const Color(0xFF1B120C)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..strokeJoin = StrokeJoin.miter;

    // 1. Top Lid Face (Isometric Rhombus)
    final topLidPath = Path()
      ..moveTo(topVertex.dx, topVertex.dy)
      ..lineTo(rightTopVertex.dx, rightTopVertex.dy)
      ..lineTo(centerVertex.dx, centerVertex.dy)
      ..lineTo(leftTopVertex.dx, leftTopVertex.dy)
      ..close();
    canvas.drawPath(topLidPath, Paint()..color = const Color(0xFFC78038)); // Warm oak lid
    canvas.drawPath(topLidPath, edgeOutline);

    // Plank lines on top lid
    final plankPaint = Paint()..color = const Color(0xFF9E5D20)..strokeWidth = 1.4;
    canvas.drawLine(
      Offset.lerp(topVertex, leftTopVertex, 0.5)!,
      Offset.lerp(rightTopVertex, centerVertex, 0.5)!,
      plankPaint,
    );
    canvas.drawLine(
      Offset.lerp(topVertex, rightTopVertex, 0.5)!,
      Offset.lerp(leftTopVertex, centerVertex, 0.5)!,
      plankPaint,
    );

    // 2. Left Front Face (Front of chest with latch)
    final frontFacePath = Path()
      ..moveTo(leftTopVertex.dx, leftTopVertex.dy)
      ..lineTo(centerVertex.dx, centerVertex.dy)
      ..lineTo(centerBottomVertex.dx, centerBottomVertex.dy)
      ..lineTo(leftBottomVertex.dx, leftBottomVertex.dy)
      ..close();
    canvas.drawPath(frontFacePath, Paint()..color = const Color(0xFFA55E22)); // Front oak
    canvas.drawPath(frontFacePath, edgeOutline);

    // Horizontal split seam for lid
    final frontSeamLeft = Offset.lerp(leftTopVertex, leftBottomVertex, 0.36)!;
    final frontSeamCenter = Offset.lerp(centerVertex, centerBottomVertex, 0.36)!;
    canvas.drawLine(frontSeamLeft, frontSeamCenter, Paint()..color = const Color(0xFF1B120C)..strokeWidth = 2.0);

    // 3. Right Side Face (Shadowed oak)
    final sideFacePath = Path()
      ..moveTo(centerVertex.dx, centerVertex.dy)
      ..lineTo(rightTopVertex.dx, rightTopVertex.dy)
      ..lineTo(rightBottomVertex.dx, rightBottomVertex.dy)
      ..lineTo(centerBottomVertex.dx, centerBottomVertex.dy)
      ..close();
    canvas.drawPath(sideFacePath, Paint()..color = const Color(0xFF783C10)); // Darker shaded oak
    canvas.drawPath(sideFacePath, edgeOutline);

    // Horizontal split seam on side
    final sideSeamRight = Offset.lerp(rightTopVertex, rightBottomVertex, 0.36)!;
    canvas.drawLine(frontSeamCenter, sideSeamRight, Paint()..color = const Color(0xFF1B120C)..strokeWidth = 2.0);

    // 4. Black Iron Perimeter Straps
    final ironBandPaint = Paint()..color = const Color(0xFF263238)..strokeWidth = 2.4;
    canvas.drawLine(leftTopVertex, Offset.lerp(leftTopVertex, centerVertex, 0.16)!, ironBandPaint);
    canvas.drawLine(rightTopVertex, Offset.lerp(rightTopVertex, centerVertex, 0.16)!, ironBandPaint);
    canvas.drawLine(leftBottomVertex, Offset.lerp(leftBottomVertex, centerBottomVertex, 0.16)!, ironBandPaint);
    canvas.drawLine(rightBottomVertex, Offset.lerp(rightBottomVertex, centerBottomVertex, 0.16)!, ironBandPaint);

    // 5. Silver Latch in center of front seam (matching user reference image 3)
    final latchCenter = Offset(frontSeamCenter.dx - s * 0.05, frontSeamCenter.dy + s * 0.02);
    final latchRect = Rect.fromCenter(center: latchCenter, width: s * 0.14, height: s * 0.16);
    canvas.drawRect(latchRect, Paint()..color = const Color(0xFFCFD8DC)); // Silver body
    canvas.drawRect(Rect.fromLTWH(latchRect.left, latchRect.top, latchRect.width, latchRect.height * 0.30), Paint()..color = Colors.white); // Top highlight
    canvas.drawRect(Rect.fromCenter(center: Offset(latchCenter.dx, latchCenter.dy + s * 0.02), width: s * 0.04, height: s * 0.07), Paint()..color = const Color(0xFF1B120C)); // Keyhole
    canvas.drawRect(latchRect, Paint()..color = const Color(0xFF1B120C)..style = PaintingStyle.stroke..strokeWidth = 1.4); // Outline
  }

  // 17. GLOBE: 3D Voxel Planet Earth with ocean depth, multi-tone continents & polar ice
  void _drawGlobe(Canvas canvas, double cx, double cy, double s) {
    // Deep ocean sphere with radial depth
    canvas.drawCircle(
      Offset(cx, cy),
      s * 0.34,
      Paint()
        ..shader = const RadialGradient(
          colors: [Color(0xFF039BE5), Color(0xFF0277BD), Color(0xFF01579B)],
        ).createShader(Rect.fromCircle(center: Offset(cx - s * 0.06, cy - s * 0.06), radius: s * 0.34)),
    );

    // Stepped green continents with varied terrain
    final landForest = Paint()..color = const Color(0xFF43A047);
    final landSavanna = Paint()..color = const Color(0xFF8BC34A);

    // Continent 1 (North-west)
    canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(cx - s * 0.22, cy - s * 0.20, s * 0.18, s * 0.16), const Radius.circular(2)), landForest);
    canvas.drawRect(Rect.fromLTWH(cx - s * 0.16, cy - s * 0.14, s * 0.10, s * 0.10), landSavanna);

    // Continent 2 (East)
    canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(cx + s * 0.02, cy - s * 0.10, s * 0.22, s * 0.22), const Radius.circular(3)), landForest);
    canvas.drawRect(Rect.fromLTWH(cx + s * 0.08, cy - s * 0.04, s * 0.12, s * 0.10), landSavanna);

    // Continent 3 (South-west)
    canvas.drawRect(Rect.fromLTWH(cx - s * 0.16, cy + s * 0.08, s * 0.14, s * 0.14), landForest);

    // North polar ice cap
    canvas.drawArc(
      Rect.fromCircle(center: Offset(cx, cy), radius: s * 0.34),
      -math.pi * 0.75,
      math.pi * 0.50,
      true,
      Paint()..color = Colors.white,
    );

    // Orbiting semi-transparent atmosphere cloud streaks
    final cloudShift = (anim * 2 * math.pi);
    final cloudPaint = Paint()..color = Colors.white.withOpacity(0.55)..strokeWidth = 1.8..strokeCap = StrokeCap.round;
    final cy1 = cy - s * 0.04;
    canvas.drawLine(Offset(cx - s * 0.25 + math.sin(cloudShift) * 4, cy1), Offset(cx + s * 0.10 + math.sin(cloudShift) * 4, cy1), cloudPaint);
  }

  // 18. GEAR: Precision engineered steampunk cog with 3D metallic bevel & central brass hub
  void _drawGear(Canvas canvas, double cx, double cy, double s) {
    canvas.save();
    canvas.translate(cx, cy);
    canvas.rotate(anim * 2 * math.pi);

    final toothLit = Paint()..color = const Color(0xFFB0BEC5);
    final toothShadow = Paint()..color = const Color(0xFF546E7A);

    // 8 Beveled gear teeth
    for (var i = 0; i < 4; i++) {
      canvas.drawRect(Rect.fromCenter(center: Offset.zero, width: s * 0.72, height: s * 0.18), toothLit);
      canvas.drawRect(Rect.fromLTWH(s * 0.26, -s * 0.09, s * 0.10, s * 0.18), toothShadow);
      canvas.drawRect(Rect.fromLTWH(-s * 0.36, -s * 0.09, s * 0.10, s * 0.18), toothShadow);
      canvas.rotate(math.pi / 4);
    }

    // Outer metallic rim
    canvas.drawCircle(Offset.zero, s * 0.26, Paint()..color = const Color(0xFF78909C));
    canvas.drawCircle(Offset.zero, s * 0.26, Paint()..color = Colors.white70..style = PaintingStyle.stroke..strokeWidth = 1.2);

    // Recessed dark plate with 4 cutouts
    canvas.drawCircle(Offset.zero, s * 0.19, Paint()..color = const Color(0xFF263238));
    for (var i = 0; i < 4; i++) {
      canvas.drawCircle(Offset(s * 0.12, 0), 2.2, Paint()..color = const Color(0xFF151B1E));
      canvas.rotate(math.pi / 2);
    }

    // Central polished brass hub
    canvas.drawCircle(Offset.zero, s * 0.09, Paint()..color = const Color(0xFFFFB300));
    canvas.drawCircle(Offset.zero, s * 0.045, Paint()..color = const Color(0xFF37474F));

    canvas.restore();
  }

  // 19. PENCIL: High-detail draughtsman's pencil with hexagonal body, cedar collar & eraser
  void _drawPencil(Canvas canvas, double cx, double cy, double s) {
    canvas.save();
    canvas.translate(cx, cy);
    canvas.rotate(-math.pi / 4);

    // Hexagonal lacquered body: 3 shaded facets
    final w = s * 0.16;
    final h = s * 0.40;
    // Lit facet (Left)
    canvas.drawRect(Rect.fromLTWH(-w / 2, -h / 2, w * 0.35, h), Paint()..color = const Color(0xFF81C784));
    // Mid facet (Center)
    canvas.drawRect(Rect.fromLTWH(-w / 2 + w * 0.35, -h / 2, w * 0.40, h), Paint()..color = const Color(0xFF4CAF50));
    // Shadow facet (Right)
    canvas.drawRect(Rect.fromLTWH(-w / 2 + w * 0.75, -h / 2, w * 0.25, h), Paint()..color = const Color(0xFF2E7D32));

    // Gold imprint band
    canvas.drawRect(Rect.fromLTWH(-w / 2, -h * 0.20, w, s * 0.035), Paint()..color = const Color(0xFFFFD54F));

    // Sharpened conical cedar collar
    final collar = Path()
      ..moveTo(-w / 2, h / 2)
      ..lineTo(0, h / 2 + s * 0.16)
      ..lineTo(w / 2, h / 2)
      ..close();
    canvas.drawPath(collar, Paint()..color = const Color(0xFFFFE082));
    // Cedar scallop grain
    canvas.drawPath(
      Path()..moveTo(-w * 0.2, h / 2)..lineTo(0, h / 2 + s * 0.12)..lineTo(w * 0.2, h / 2)..close(),
      Paint()..color = const Color(0xFFFFB74D),
    );

    // Dark graphite lead point
    final lead = Path()
      ..moveTo(-w * 0.20, h / 2 + s * 0.09)
      ..lineTo(0, h / 2 + s * 0.16)
      ..lineTo(w * 0.20, h / 2 + s * 0.09)
      ..close();
    canvas.drawPath(lead, Paint()..color = const Color(0xFF212121));

    // Silver ferrule band
    canvas.drawRect(Rect.fromLTWH(-w / 2, -h / 2 - s * 0.06, w, s * 0.06), Paint()..color = const Color(0xFFCFD8DC));
    canvas.drawLine(Offset(-w / 2, -h / 2 - s * 0.03), Offset(w / 2, -h / 2 - s * 0.03), Paint()..color = const Color(0xFF90A4AE));

    // Pink rubber eraser
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromLTWH(-w / 2, -h / 2 - s * 0.14, w, s * 0.08), const Radius.circular(2)),
      Paint()..color = const Color(0xFFF48FB1),
    );

    canvas.restore();
  }

  // 20. DICE: 3D Isometric Voxel Dice with beveled corners & indented pip recesses
  void _drawDice(Canvas canvas, double cx, double cy, double s) {
    final w2 = s * 0.32;
    final h2 = s * 0.18;

    // Top face (showing 1 pip)
    final topFace = Path()
      ..moveTo(cx, cy - s * 0.30)
      ..lineTo(cx + w2, cy - s * 0.30 + h2)
      ..lineTo(cx, cy - s * 0.30 + 2 * h2)
      ..lineTo(cx - w2, cy - s * 0.30 + h2)
      ..close();
    canvas.drawPath(topFace, Paint()..color = const Color(0xFFFFFFFF));
    canvas.drawPath(topFace, Paint()..color = const Color(0xFFCFD8DC)..style = PaintingStyle.stroke..strokeWidth = 1.0);

    // Left face (showing 2 pips)
    final leftFace = Path()
      ..moveTo(cx - w2, cy - s * 0.30 + h2)
      ..lineTo(cx, cy - s * 0.30 + 2 * h2)
      ..lineTo(cx, cy + s * 0.28)
      ..lineTo(cx - w2, cy + s * 0.28 - h2)
      ..close();
    canvas.drawPath(leftFace, Paint()..color = const Color(0xFFECEFF1));
    canvas.drawPath(leftFace, Paint()..color = const Color(0xFFB0BEC5)..style = PaintingStyle.stroke..strokeWidth = 1.0);

    // Right face (showing 3 pips)
    final rightFace = Path()
      ..moveTo(cx, cy - s * 0.30 + 2 * h2)
      ..lineTo(cx + w2, cy - s * 0.30 + h2)
      ..lineTo(cx + w2, cy + s * 0.28 - h2)
      ..lineTo(cx, cy + s * 0.28)
      ..close();
    canvas.drawPath(rightFace, Paint()..color = const Color(0xFFCFD8DC));
    canvas.drawPath(rightFace, Paint()..color = const Color(0xFF90A4AE)..style = PaintingStyle.stroke..strokeWidth = 1.0);

    // Pips: Top face center pip (Red / Crimson pip)
    final pip1 = Paint()..color = const Color(0xFFD32F2F);
    canvas.drawCircle(Offset(cx, cy - s * 0.30 + h2), s * 0.05, pip1);

    // Left face 2 pips (Black)
    final pipDark = Paint()..color = const Color(0xFF263238);
    canvas.drawCircle(Offset(cx - s * 0.16, cy + s * 0.03), s * 0.035, pipDark);
    canvas.drawCircle(Offset(cx - s * 0.08, cy + s * 0.16), s * 0.035, pipDark);

    // Right face 3 pips (Black)
    canvas.drawCircle(Offset(cx + s * 0.08, cy + s * 0.03), s * 0.035, pipDark);
    canvas.drawCircle(Offset(cx + s * 0.16, cy + s * 0.10), s * 0.035, pipDark);
    canvas.drawCircle(Offset(cx + s * 0.24, cy + s * 0.17), s * 0.035, pipDark);
  }

  // 21. SPARKLES: Multi-star Enchantment Glint sparkles with chromatic pulse & particle dust
  void _drawSparkles(Canvas canvas, double cx, double cy, double s) {
    final scale = 0.85 + 0.15 * math.sin(anim * 4 * math.pi);
    final scale2 = 0.85 + 0.15 * math.sin((anim + 0.5) * 4 * math.pi);

    void draw8PointStar(double x, double y, double r, Color coreColor, Color auraColor) {
      // Chromatic aura
      canvas.drawCircle(Offset(x, y), r * 1.4, Paint()..color = auraColor.withOpacity(0.35));

      final p = Path()
        ..moveTo(x, y - r)
        ..lineTo(x + r * 0.22, y - r * 0.22)
        ..lineTo(x + r, y)
        ..lineTo(x + r * 0.22, y + r * 0.22)
        ..lineTo(x, y + r)
        ..lineTo(x - r * 0.22, y + r * 0.22)
        ..lineTo(x - r, y)
        ..lineTo(x - r * 0.22, y - r * 0.22)
        ..close();
      canvas.drawPath(p, Paint()..color = coreColor);
      canvas.drawCircle(Offset(x, y), r * 0.25, Paint()..color = Colors.white);
    }

    // Primary Diamond Star (Center-left)
    draw8PointStar(cx - s * 0.08, cy - s * 0.08, s * 0.26 * scale, const Color(0xFF00E5FF), const Color(0xFFE040FB));

    // Secondary Golden Star (Bottom-right)
    draw8PointStar(cx + s * 0.22, cy + s * 0.14, s * 0.16 * scale2, const Color(0xFFFFD54F), const Color(0xFFFF8F00));

    // 3 Orbiting sparkle dust motes
    final motePaint = Paint()..color = Colors.white;
    canvas.drawRect(Rect.fromCenter(center: Offset(cx + s * 0.10, cy - s * 0.24), width: 2, height: 2), motePaint);
    canvas.drawRect(Rect.fromCenter(center: Offset(cx - s * 0.26, cy + s * 0.18), width: 2.2, height: 2.2), motePaint);
    canvas.drawRect(Rect.fromCenter(center: Offset(cx + s * 0.30, cy - s * 0.02), width: 1.8, height: 1.8), motePaint);
  }

  // 22. GRASS BLOCK: Iconic 3D Minecraft Grass Block with textured grass top & loam dirt sides
  void _drawGrassBlock(Canvas canvas, double cx, double cy, double s) {
    final w2 = s * 0.36;
    final h2 = s * 0.21;

    // 1. Top green grass face
    final topFace = Path()
      ..moveTo(cx, cy - s * 0.32)
      ..lineTo(cx + w2, cy - s * 0.32 + h2)
      ..lineTo(cx, cy - s * 0.32 + 2 * h2)
      ..lineTo(cx - w2, cy - s * 0.32 + h2)
      ..close();
    canvas.drawPath(topFace, Paint()..color = const Color(0xFF4CAF50));

    // Top grass texture pixels
    canvas.drawRect(Rect.fromLTWH(cx - s * 0.14, cy - s * 0.22, s * 0.08, s * 0.06), Paint()..color = const Color(0xFF66BB6A));
    canvas.drawRect(Rect.fromLTWH(cx + s * 0.06, cy - s * 0.26, s * 0.08, s * 0.06), Paint()..color = const Color(0xFF388E3C));
    canvas.drawRect(Rect.fromLTWH(cx - s * 0.02, cy - s * 0.14, s * 0.08, s * 0.06), Paint()..color = const Color(0xFF2E7D32));

    // 2. Left dirt face
    final leftFace = Path()
      ..moveTo(cx - w2, cy - s * 0.32 + h2)
      ..lineTo(cx, cy - s * 0.32 + 2 * h2)
      ..lineTo(cx, cy + s * 0.28)
      ..lineTo(cx - w2, cy + s * 0.28 - h2)
      ..close();
    canvas.drawPath(leftFace, Paint()..color = const Color(0xFF5D4037));

    // Left dirt pebbles
    canvas.drawRect(Rect.fromLTWH(cx - s * 0.20, cy + s * 0.04, s * 0.06, s * 0.06), Paint()..color = const Color(0xFF8D6E63));
    canvas.drawRect(Rect.fromLTWH(cx - s * 0.10, cy + s * 0.14, s * 0.05, s * 0.05), Paint()..color = const Color(0xFF3E2723));

    // 3. Right dirt face (shaded)
    final rightFace = Path()
      ..moveTo(cx, cy - s * 0.32 + 2 * h2)
      ..lineTo(cx + w2, cy - s * 0.32 + h2)
      ..lineTo(cx + w2, cy + s * 0.30 - h2)
      ..lineTo(cx, cy + s * 0.30)
      ..close();
    canvas.drawPath(rightFace, Paint()..color = const Color(0xFF4E342E));

    // Right dirt pebbles
    canvas.drawRect(Rect.fromLTWH(cx + s * 0.14, cy + s * 0.08, s * 0.06, s * 0.05), Paint()..color = const Color(0xFF3E2723));
    canvas.drawRect(Rect.fromLTWH(cx + s * 0.06, cy + s * 0.18, s * 0.05, s * 0.05), Paint()..color = const Color(0xFF6D4C41));

    // 4. Jagged grass overhang fringe hanging down both sides
    final overLeft = Path()
      ..moveTo(cx - w2, cy - s * 0.32 + h2)
      ..lineTo(cx, cy - s * 0.32 + 2 * h2)
      ..lineTo(cx, cy - s * 0.32 + 2 * h2 + s * 0.12)
      ..lineTo(cx - s * 0.12, cy - s * 0.32 + 2 * h2 + s * 0.06)
      ..lineTo(cx - s * 0.22, cy - s * 0.32 + 2 * h2 + s * 0.14)
      ..lineTo(cx - w2, cy - s * 0.32 + h2 + s * 0.08)
      ..close();
    canvas.drawPath(overLeft, Paint()..color = const Color(0xFF388E3C));

    final overRight = Path()
      ..moveTo(cx, cy - s * 0.32 + 2 * h2)
      ..lineTo(cx + w2, cy - s * 0.32 + h2)
      ..lineTo(cx + w2, cy - s * 0.32 + h2 + s * 0.08)
      ..lineTo(cx + s * 0.20, cy - s * 0.32 + 2 * h2 + s * 0.13)
      ..lineTo(cx + s * 0.10, cy - s * 0.32 + 2 * h2 + s * 0.06)
      ..lineTo(cx, cy - s * 0.32 + 2 * h2 + s * 0.11)
      ..close();
    canvas.drawPath(overRight, Paint()..color = const Color(0xFF2E7D32));
  }

  // 23. STEVE: High-res pixel-perfect Steve avatar with textured hair, eyes & beard
  void _drawSteve(Canvas canvas, double cx, double cy, double s) {
    // Outer border
    canvas.drawRect(Rect.fromCenter(center: Offset(cx, cy), width: s * 0.70, height: s * 0.70), Paint()..color = const Color(0xFF2E1C14));

    // Head base (Skin tone)
    canvas.drawRect(Rect.fromCenter(center: Offset(cx, cy), width: s * 0.64, height: s * 0.64), Paint()..color = const Color(0xFFD7A17C));

    // Textured brown hair
    final hairPaint = Paint()..color = const Color(0xFF4E342E);
    final hairLight = Paint()..color = const Color(0xFF6D4C41);
    canvas.drawRect(Rect.fromLTWH(cx - s * 0.32, cy - s * 0.32, s * 0.64, s * 0.22), hairPaint);
    canvas.drawRect(Rect.fromLTWH(cx - s * 0.24, cy - s * 0.30, s * 0.20, s * 0.08), hairLight);
    // Sideburns
    canvas.drawRect(Rect.fromLTWH(cx - s * 0.32, cy - s * 0.14, s * 0.12, s * 0.20), hairPaint);
    canvas.drawRect(Rect.fromLTWH(cx + s * 0.20, cy - s * 0.14, s * 0.12, s * 0.20), hairPaint);

    // Eyes: White sclera + Cyan/Indigo pupils
    final eyeY = cy - s * 0.02;
    canvas.drawRect(Rect.fromLTWH(cx - s * 0.22, eyeY, s * 0.14, s * 0.08), Paint()..color = Colors.white);
    canvas.drawRect(Rect.fromLTWH(cx + s * 0.08, eyeY, s * 0.14, s * 0.08), Paint()..color = Colors.white);
    canvas.drawRect(Rect.fromLTWH(cx - s * 0.16, eyeY, s * 0.08, s * 0.08), Paint()..color = const Color(0xFF00838F));
    canvas.drawRect(Rect.fromLTWH(cx + s * 0.14, eyeY, s * 0.08, s * 0.08), Paint()..color = const Color(0xFF00838F));

    // Nose
    canvas.drawRect(Rect.fromCenter(center: Offset(cx, cy + s * 0.08), width: s * 0.12, height: s * 0.08), Paint()..color = const Color(0xFFBD8262));

    // Mouth / Trimmed goatee
    canvas.drawRect(Rect.fromCenter(center: Offset(cx, cy + s * 0.18), width: s * 0.26, height: s * 0.08), Paint()..color = const Color(0xFF4E342E));
    canvas.drawRect(Rect.fromCenter(center: Offset(cx, cy + s * 0.16), width: s * 0.14, height: s * 0.04), Paint()..color = const Color(0xFF8D6E63));
  }

  // 24. LANTERN: High-detail glowing Minecraft lantern with iron frame & flame bloom matching user reference image 4
  void _drawLantern(Canvas canvas, double cx, double cy, double s) {
    final glow = 0.85 + 0.15 * math.sin(anim * 4 * math.pi);

    // Warm atmospheric bloom
    canvas.drawCircle(
      Offset(cx, cy + s * 0.04),
      s * 0.44 * glow,
      Paint()..color = const Color(0xFFFF9800).withOpacity(0.38),
    );
    canvas.drawCircle(
      Offset(cx, cy + s * 0.04),
      s * 0.28 * glow,
      Paint()..color = const Color(0xFFFFD54F).withOpacity(0.45),
    );

    // 1. Top Hanger Ring / Loop
    final ringPaint = Paint()
      ..color = const Color(0xFF263238)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.4;
    canvas.drawCircle(Offset(cx, cy - s * 0.32), s * 0.08, ringPaint);
    canvas.drawCircle(Offset(cx, cy - s * 0.32), s * 0.08, Paint()..color = const Color(0xFF10171B)..style = PaintingStyle.stroke..strokeWidth = 1.0);

    // 2. Stepped Iron Roof Cap (tiered pyramid)
    final roofCap = Path()
      ..moveTo(cx - s * 0.24, cy - s * 0.14)
      ..lineTo(cx + s * 0.24, cy - s * 0.14)
      ..lineTo(cx + s * 0.16, cy - s * 0.24)
      ..lineTo(cx - s * 0.16, cy - s * 0.24)
      ..close();
    canvas.drawPath(roofCap, Paint()..color = const Color(0xFF37474F));
    canvas.drawPath(roofCap, Paint()..color = const Color(0xFF10171B)..style = PaintingStyle.stroke..strokeWidth = 2.0);

    // Roof Eaves overhang rim
    canvas.drawRect(
      Rect.fromCenter(center: Offset(cx, cy - s * 0.13), width: s * 0.52, height: s * 0.06),
      Paint()..color = const Color(0xFF263238),
    );
    canvas.drawRect(
      Rect.fromCenter(center: Offset(cx, cy - s * 0.13), width: s * 0.52, height: s * 0.06),
      Paint()..color = const Color(0xFF10171B)..style = PaintingStyle.stroke..strokeWidth = 1.5,
    );

    // 3. Glass Chamber Body (illuminated warm amber glass)
    final glassRect = Rect.fromCenter(center: Offset(cx, cy + s * 0.08), width: s * 0.40, height: s * 0.36);
    canvas.drawRect(glassRect, Paint()..color = const Color(0xFFFFA000));

    // 4. Blazing Interior Core Flame
    final flY = cy + s * 0.08 + math.sin(anim * 6 * math.pi) * 1.5;
    canvas.drawCircle(Offset(cx, flY), s * 0.14 * glow, Paint()..color = const Color(0xFFFF6D00));
    canvas.drawCircle(Offset(cx, flY - 1), s * 0.09 * glow, Paint()..color = const Color(0xFFFFD54F));
    canvas.drawCircle(Offset(cx, flY - 2), s * 0.05 * glow, Paint()..color = Colors.white);

    // 5. 4 Wrought-Iron Struts & Glass Crossbars
    final ironPost = Paint()..color = const Color(0xFF263238);
    final postW = s * 0.055;
    // Left post
    canvas.drawRect(Rect.fromLTWH(cx - s * 0.20, cy - s * 0.10, postW, s * 0.36), ironPost);
    // Right post
    canvas.drawRect(Rect.fromLTWH(cx + s * 0.20 - postW, cy - s * 0.10, postW, s * 0.36), ironPost);
    // Center divider
    canvas.drawRect(Rect.fromCenter(center: Offset(cx, cy + s * 0.08), width: postW * 0.8, height: s * 0.36), ironPost);

    // Outer dark frame outline
    canvas.drawRect(glassRect, Paint()..color = const Color(0xFF10171B)..style = PaintingStyle.stroke..strokeWidth = 2.0);

    // 6. Base Iron Plate with corner feet
    final baseRect = Rect.fromCenter(center: Offset(cx, cy + s * 0.28), width: s * 0.46, height: s * 0.07);
    canvas.drawRect(baseRect, Paint()..color = const Color(0xFF263238));
    canvas.drawRect(baseRect, Paint()..color = const Color(0xFF10171B)..style = PaintingStyle.stroke..strokeWidth = 1.6);

    // Base feet
    canvas.drawRect(Rect.fromLTWH(cx - s * 0.22, cy + s * 0.31, s * 0.07, s * 0.04), Paint()..color = const Color(0xFF10171B));
    canvas.drawRect(Rect.fromLTWH(cx + s * 0.15, cy + s * 0.31, s * 0.07, s * 0.04), Paint()..color = const Color(0xFF10171B));
  }

  // 25. RAIN CLOUD: Atmospheric 3D Minecraft storm cloud with falling diagonal crystal drops
  void _drawRainCloud(Canvas canvas, double cx, double cy, double s) {
    // Darker storm cloud
    final bob = math.sin(anim * 2 * math.pi) * (s * 0.03);
    final y = cy - s * 0.12 + bob;

    final stormBody = Paint()..color = const Color(0xFF455A64);
    final stormShadow = Paint()..color = const Color(0xFF263238);
    final stormHighlight = Paint()..color = const Color(0xFF78909C);

    // Bottom shelf
    canvas.drawRect(Rect.fromCenter(center: Offset(cx, y + s * 0.12), width: s * 0.74, height: s * 0.10), stormShadow);
    // Main body
    canvas.drawRect(Rect.fromCenter(center: Offset(cx, y), width: s * 0.72, height: s * 0.18), stormBody);
    // Upper puffs
    canvas.drawRect(Rect.fromCenter(center: Offset(cx - s * 0.12, y - s * 0.09), width: s * 0.32, height: s * 0.16), stormHighlight);
    canvas.drawRect(Rect.fromCenter(center: Offset(cx + s * 0.14, y - s * 0.06), width: s * 0.26, height: s * 0.12), stormHighlight);

    // 4 Diagonal falling crystal raindrops
    final dropPaint = Paint()..color = const Color(0xFF40C4FF)..strokeWidth = 2.0..strokeCap = StrokeCap.round;
    for (var i = 0; i < 4; i++) {
      final dropAnim = (anim * 2.2 + i * 0.25) % 1.0;
      final x = cx - s * 0.24 + i * (s * 0.16);
      final dy = cy + s * 0.06 + dropAnim * (s * 0.32);
      canvas.drawLine(Offset(x, dy), Offset(x - s * 0.04, dy + s * 0.10), dropPaint);
    }
  }

  // 26. WATER SPLASH: Dynamic fluid droplet impact with 3 concentric ripple rings & splash droplets
  void _drawWaterSplash(Canvas canvas, double cx, double cy, double s) {
    // Central impact droplet
    _drawWaterDroplet(canvas, cx, cy - s * 0.06, s * 0.80);

    // 3 Concentric expanding oval ripples
    for (var i = 0; i < 3; i++) {
      final rAnim = (anim + i * 0.33) % 1.0;
      final rw = s * (0.30 + rAnim * 0.40);
      final rh = s * (0.10 + rAnim * 0.14);
      final rAlpha = (1.0 - rAnim).clamp(0.0, 1.0);

      canvas.drawOval(
        Rect.fromCenter(center: Offset(cx, cy + s * 0.26), width: rw, height: rh),
        Paint()..color = const Color(0xFF80D8FF).withOpacity(rAlpha * 0.85)..style = PaintingStyle.stroke..strokeWidth = 1.4,
      );
    }

    // 4 Arched airborne water splash droplets
    final splashDrops = Paint()..color = const Color(0xFF00E5FF);
    canvas.drawCircle(Offset(cx - s * 0.26, cy + s * 0.12), 2.2, splashDrops);
    canvas.drawCircle(Offset(cx + s * 0.26, cy + s * 0.12), 2.2, splashDrops);
    canvas.drawCircle(Offset(cx - s * 0.34, cy + s * 0.22), 1.8, splashDrops);
    canvas.drawCircle(Offset(cx + s * 0.34, cy + s * 0.22), 1.8, splashDrops);
  }

  // 27. PALETTE: Artist's wooden palette with contoured thumb hole & 5 thick 3D paint dollops
  void _drawPalette(Canvas canvas, double cx, double cy, double s) {
    // Contoured wooden palette
    final palettePath = Path()
      ..addOval(Rect.fromCenter(center: Offset(cx, cy), width: s * 0.74, height: s * 0.60));
    canvas.drawPath(palettePath, Paint()..color = const Color(0xFF8D6E63));
    canvas.drawPath(palettePath, Paint()..color = const Color(0xFF5D4037)..style = PaintingStyle.stroke..strokeWidth = 1.6);

    // Thumb hole
    canvas.drawOval(
      Rect.fromCenter(center: Offset(cx + s * 0.18, cy + s * 0.08), width: s * 0.14, height: s * 0.18),
      Paint()..color = const Color(0xFF1E2226),
    );

    // 5 Thick 3D paint dollops with specular shine domes
    final colors = [
      const Color(0xFFFF5252), // Crimson Red
      const Color(0xFFFF9800), // Solar Orange
      const Color(0xFFFFEB3B), // Radiant Yellow
      const Color(0xFF4CAF50), // Emerald Green
      const Color(0xFF2196F3), // Sapphire Blue
    ];

    final positions = [
      Offset(cx - s * 0.22, cy - s * 0.12),
      Offset(cx - s * 0.12, cy - s * 0.20),
      Offset(cx + s * 0.04, cy - s * 0.20),
      Offset(cx + s * 0.18, cy - s * 0.10),
      Offset(cx - s * 0.18, cy + s * 0.08),
    ];

    for (var i = 0; i < 5; i++) {
      final pos = positions[i];
      // Paint drop shadow
      canvas.drawCircle(Offset(pos.dx + 1, pos.dy + 1), s * 0.07, Paint()..color = Colors.black38);
      // Paint dome
      canvas.drawCircle(pos, s * 0.065, Paint()..color = colors[i]);
      // Specular highlight dot
      canvas.drawCircle(Offset(pos.dx - 1.5, pos.dy - 1.5), 1.5, Paint()..color = Colors.white.withOpacity(0.90));
    }
  }

  // 28. CAMERA: Professional cinema / DSLR camera with dials, multi-element lens & blinking tally light
  void _drawCamera(Canvas canvas, double cx, double cy, double s) {
    // Camera body (magnesium alloy)
    final bodyR = RRect.fromRectAndRadius(
      Rect.fromCenter(center: Offset(cx, cy + s * 0.02), width: s * 0.72, height: s * 0.48),
      const Radius.circular(4),
    );
    canvas.drawRRect(bodyR, Paint()..color = const Color(0xFF37474F));
    canvas.drawRRect(bodyR, Paint()..color = const Color(0xFF263238)..style = PaintingStyle.stroke..strokeWidth = 1.4);

    // Textured leatherette grip (Left)
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromLTWH(cx - s * 0.34, cy - s * 0.18, s * 0.14, s * 0.40), const Radius.circular(2)),
      Paint()..color = const Color(0xFF212121),
    );

    // Top control dial and shutter button
    canvas.drawRect(Rect.fromLTWH(cx - s * 0.22, cy - s * 0.26, s * 0.10, s * 0.06), Paint()..color = const Color(0xFFB0BEC5));
    canvas.drawRect(Rect.fromLTWH(cx + s * 0.14, cy - s * 0.28, s * 0.08, s * 0.08), Paint()..color = const Color(0xFFECEFF1));

    // Multi-element optical lens barrel
    canvas.drawCircle(Offset(cx + s * 0.06, cy + s * 0.04), s * 0.18, Paint()..color = const Color(0xFF212121));
    canvas.drawCircle(Offset(cx + s * 0.06, cy + s * 0.04), s * 0.15, Paint()..color = const Color(0xFF37474F));

    // Anti-reflective coating reflection (Sapphire-cyan & magenta sheen)
    final lensGlint = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFF00E5FF), Color(0xFFAB47BC)],
      ).createShader(Rect.fromCircle(center: Offset(cx + s * 0.06, cy + s * 0.04), radius: s * 0.11));
    canvas.drawCircle(Offset(cx + s * 0.06, cy + s * 0.04), s * 0.11, lensGlint);

    // Specular lens flare dot
    canvas.drawCircle(Offset(cx + s * 0.02, cy), 2.2, Paint()..color = Colors.white.withOpacity(0.90));

    // Blinking red recording tally LED
    final blink = (math.sin(anim * 4 * math.pi) > 0);
    canvas.drawCircle(
      Offset(cx - s * 0.26, cy - s * 0.12),
      2.5,
      Paint()..color = blink ? const Color(0xFFFF1744) : const Color(0xFFB71C1C),
    );
  }

  // 29. CONTRAST: Circular aperture dial with calibrated notches & high-contrast Yin-Yang transition
  void _drawContrast(Canvas canvas, double cx, double cy, double s) {
    // Brushed metallic aperture ring
    canvas.drawCircle(Offset(cx, cy), s * 0.36, Paint()..color = const Color(0xFF78909C));
    canvas.drawCircle(Offset(cx, cy), s * 0.36, Paint()..color = const Color(0xFFCFD8DC)..style = PaintingStyle.stroke..strokeWidth = 1.2);

    // Calibrated aperture tick marks
    final tickPaint = Paint()..color = Colors.white70..strokeWidth = 1.2;
    for (var i = 0; i < 8; i++) {
      final a = i * (math.pi / 4);
      final x1 = cx + math.cos(a) * (s * 0.32);
      final y1 = cy + math.sin(a) * (s * 0.32);
      final x2 = cx + math.cos(a) * (s * 0.36);
      final y2 = cy + math.sin(a) * (s * 0.36);
      canvas.drawLine(Offset(x1, y1), Offset(x2, y2), tickPaint);
    }

    // Inner dial: Dark half (Obsidian)
    canvas.drawCircle(Offset(cx, cy), s * 0.30, Paint()..color = const Color(0xFF1A1A1A));

    // Light half (Pure diamond white)
    final lightHalf = Path()
      ..addArc(Rect.fromCircle(center: Offset(cx, cy), radius: s * 0.30), -math.pi / 2, math.pi)
      ..close();
    canvas.drawPath(lightHalf, Paint()..color = Colors.white);

    // Center contrast pips
    canvas.drawCircle(Offset(cx, cy - s * 0.14), s * 0.05, Paint()..color = const Color(0xFF1A1A1A));
    canvas.drawCircle(Offset(cx, cy + s * 0.14), s * 0.05, Paint()..color = Colors.white);
  }

  // 30. FILM: Authentic 35mm motion picture celluloid strip with miniature sunset gradient frame
  void _drawFilm(Canvas canvas, double cx, double cy, double s) {
    // Film strip celluloid body
    final filmR = RRect.fromRectAndRadius(
      Rect.fromCenter(center: Offset(cx, cy), width: s * 0.68, height: s * 0.52),
      const Radius.circular(3),
    );
    canvas.drawRRect(filmR, Paint()..color = const Color(0xFF1E2226));
    canvas.drawRRect(filmR, Paint()..color = const Color(0xFF37474F)..style = PaintingStyle.stroke..strokeWidth = 1.4);

    // Top and bottom sprocket perforation tracks (3 on top, 3 on bottom)
    final holePaint = Paint()..color = const Color(0xFFECEFF1);
    final holeW = s * 0.07;
    final holeH = s * 0.06;

    for (var i = 0; i < 3; i++) {
      final hx = cx - s * 0.22 + i * (s * 0.22);
      // Top sprocket hole
      canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromCenter(center: Offset(hx, cy - s * 0.19), width: holeW, height: holeH), const Radius.circular(1)), holePaint);
      // Bottom sprocket hole
      canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromCenter(center: Offset(hx, cy + s * 0.19), width: holeW, height: holeH), const Radius.circular(1)), holePaint);
    }

    // Central frame window showing miniature vibrant Minecraft sunset exposure!
    final frameRect = Rect.fromCenter(center: Offset(cx, cy), width: s * 0.46, height: s * 0.24);
    canvas.drawRect(
      frameRect,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF1A237E), Color(0xFFFF5722), Color(0xFFFFD54F)],
        ).createShader(frameRect),
    );
    // Miniature silhouette mountain in exposure window
    final mPath = Path()
      ..moveTo(cx - s * 0.23, cy + s * 0.12)
      ..lineTo(cx - s * 0.06, cy - s * 0.02)
      ..lineTo(cx + s * 0.08, cy + s * 0.06)
      ..lineTo(cx + s * 0.23, cy + s * 0.12)
      ..close();
    canvas.drawPath(mPath, Paint()..color = const Color(0xFF0F1215));

    // Celluloid gloss reflection across film
    canvas.drawLine(
      Offset(cx - s * 0.30, cy - s * 0.23),
      Offset(cx + s * 0.30, cy - s * 0.23),
      Paint()..color = Colors.white54..strokeWidth = 1.0,
    );
  }

  @override
  bool shouldRepaint(covariant _VoxelIconPainter oldDelegate) {
    return oldDelegate.type != type || oldDelegate.colorOverride != colorOverride;
  }
}
