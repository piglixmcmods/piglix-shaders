// vv_tab_previews.dart
// Unified Obsidian & Emerald live previews, mini tab icons, and boxy scene cards
// for all 9 tabs of the Piglix Vibrant Visuals Shader Builder.

import 'dart:math' as math;
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'performance_tiers.dart';
import 'vv_config.dart';

// Unified Home-screen Obsidian & Emerald colors (duplicated locally to avoid
// circular imports; kept identical to vv_editor_widgets.dart & theme_controller.dart).
const Color _kSurface = Color(0xFF0E1722);
const Color _kCard = Color(0xFF141F2D);
const Color _kBorder = Color(0xFF1E293B);
const Color _kEmerald = Color(0xFF22C55E);

/// Stepped 90-degree Minecraft pixelated corner clipper matching Home screen (new_ui.dart).
class VVPixelatedClipper extends CustomClipper<Path> {
  final double step;
  const VVPixelatedClipper([this.step = 3.0]);

  static Path createPixelPath(double w, double h, double inset, double s) {
    final maxStep = math.max(0.5, math.min(w, h) * 0.20);
    final cs = s.clamp(0.5, maxStep);
    final l = inset;
    final t = inset;
    final r = math.max(l + cs * 4, w - inset);
    final b = math.max(t + cs * 4, h - inset);

    return Path()
      ..moveTo(l + cs * 2, t)
      ..lineTo(r - cs * 2, t)
      ..lineTo(r - cs * 2, t + cs)
      ..lineTo(r - cs, t + cs)
      ..lineTo(r - cs, t + cs * 2)
      ..lineTo(r, t + cs * 2)
      ..lineTo(r, b - cs * 2)
      ..lineTo(r - cs, b - cs * 2)
      ..lineTo(r - cs, b - cs)
      ..lineTo(r - cs * 2, b - cs)
      ..lineTo(r - cs * 2, b)
      ..lineTo(l + cs * 2, b)
      ..lineTo(l + cs * 2, b - cs)
      ..lineTo(l + cs, b - cs)
      ..lineTo(l + cs, b - cs * 2)
      ..lineTo(l, b - cs * 2)
      ..lineTo(l, t + cs * 2)
      ..lineTo(l + cs, t + cs * 2)
      ..lineTo(l + cs, t + cs)
      ..lineTo(l + cs * 2, t + cs)
      ..close();
  }

  @override
  Path getClip(Size size) => createPixelPath(size.width, size.height, 0, step);

  @override
  bool shouldReclip(covariant VVPixelatedClipper oldClipper) =>
      oldClipper.step != step;
}

/// Stepped 90-degree Minecraft card background + inner bevel + border painter.
class VVPixelatedCardPainter extends CustomPainter {
  final Color fillColor;
  final Color borderColor;
  final double borderWidth;
  final double step;
  final bool hasShadow;
  final double innerHighlightAlpha;

  const VVPixelatedCardPainter({
    required this.fillColor,
    required this.borderColor,
    this.borderWidth = 1.5,
    this.step = 3.0,
    this.hasShadow = true,
    this.innerHighlightAlpha = 0.10,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    if (hasShadow) {
      final shadowPath = VVPixelatedClipper.createPixelPath(w, h, 0, step);
      canvas.drawPath(
        shadowPath.shift(const Offset(0, 2.5)),
        Paint()..color = Colors.black.withValues(alpha: 0.42),
      );
    }

    final fillPath = VVPixelatedClipper.createPixelPath(w, h, 0, step);
    canvas.drawPath(fillPath, Paint()..color = fillColor);

    if (innerHighlightAlpha > 0) {
      final innerPath = VVPixelatedClipper.createPixelPath(
        w,
        h,
        borderWidth * 0.6,
        step,
      );
      canvas.drawPath(
        innerPath,
        Paint()
          ..color = Colors.white.withValues(alpha: innerHighlightAlpha)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.0,
      );
    }

    canvas.drawPath(
      fillPath,
      Paint()
        ..color = borderColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = borderWidth,
    );
  }

  @override
  bool shouldRepaint(covariant VVPixelatedCardPainter old) =>
      old.fillColor != fillColor ||
      old.borderColor != borderColor ||
      old.borderWidth != borderWidth ||
      old.step != step ||
      old.hasShadow != hasShadow ||
      old.innerHighlightAlpha != innerHighlightAlpha;
}

/// Foreground stepped border painter rendered crisply on top of clipped content.
class VVPixelatedBorderPainter extends CustomPainter {
  final Color borderColor;
  final double borderWidth;
  final double step;

  const VVPixelatedBorderPainter({
    required this.borderColor,
    this.borderWidth = 1.4,
    this.step = 3.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final half = borderWidth * 0.5;
    final borderPath =
        VVPixelatedClipper.createPixelPath(size.width, size.height, half, step);
    canvas.drawPath(
      borderPath,
      Paint()
        ..color = borderColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = borderWidth,
    );
  }

  @override
  bool shouldRepaint(covariant VVPixelatedBorderPainter old) =>
      old.borderColor != borderColor ||
      old.borderWidth != borderWidth ||
      old.step != step;
}

/// Stepped pixel-corner box matching the Home page cards, buttons, and pills.
class VVPixelBox extends StatelessWidget {
  final Widget child;
  final Color fillColor;
  final Color borderColor;
  final double borderWidth;
  final double step;
  final bool hasShadow;
  final double innerHighlightAlpha;
  final EdgeInsetsGeometry? padding;

  const VVPixelBox({
    super.key,
    required this.child,
    this.fillColor = _kCard,
    this.borderColor = _kBorder,
    this.borderWidth = 1.4,
    this.step = 3.0,
    this.hasShadow = true,
    this.innerHighlightAlpha = 0.10,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final content = padding != null ? Padding(padding: padding!, child: child) : child;
    return CustomPaint(
      painter: VVPixelatedCardPainter(
        fillColor: fillColor,
        borderColor: borderColor,
        borderWidth: borderWidth,
        step: step,
        hasShadow: hasShadow,
        innerHighlightAlpha: innerHighlightAlpha,
      ),
      foregroundPainter: VVPixelatedBorderPainter(
        borderColor: borderColor,
        borderWidth: borderWidth,
        step: step,
      ),
      child: ClipPath(
        clipper: VVPixelatedClipper(step),
        child: content,
      ),
    );
  }
}

/// Stepped pixel-corner preview frame matching the Home screen aesthetic.
class VVPreviewFrame extends StatelessWidget {
  final Widget child;
  final String? badgeText;
  final double height;

  const VVPreviewFrame({
    super.key,
    required this.child,
    this.badgeText,
    this.height = 164,
  });

  @override
  Widget build(BuildContext context) {
    return VVPixelBox(
      fillColor: _kSurface,
      borderColor: _kBorder,
      borderWidth: 1.5,
      step: 3.5,
      hasShadow: true,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOutCubic,
        height: height,
        width: double.infinity,
        child: child,
      ),
    );
  }
}

// ═════════════════════════════════════════════════════════════════════════════
// 1. MINI TAB ARTWORK (Rendered inside each boxy tab in the top TabBar)
// ═════════════════════════════════════════════════════════════════════════════

class VVTabMiniArt extends StatelessWidget {
  final int tabIndex;
  final bool isSelected;
  final double size;

  const VVTabMiniArt({
    super.key,
    required this.tabIndex,
    required this.isSelected,
    this.size = 22,
  });

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: CustomPaint(
        size: Size(size, size),
        painter: _VVTabMiniArtPainter(
          tabIndex: tabIndex,
          isSelected: isSelected,
        ),
      ),
    );
  }
}

class _VVTabMiniArtPainter extends CustomPainter {
  final int tabIndex;
  final bool isSelected;

  const _VVTabMiniArtPainter({
    required this.tabIndex,
    required this.isSelected,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final bgRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, w, h),
      const Radius.circular(4),
    );
    canvas.save();
    canvas.clipRRect(bgRect);

    switch (tabIndex) {
      case 0: // Sky & Time
        canvas.drawRect(
          Rect.fromLTWH(0, 0, w, h),
          Paint()
            ..shader = const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFF0F3C6E), Color(0xFF38BDF8), Color(0xFFFDE047)],
            ).createShader(Rect.fromLTWH(0, 0, w, h)),
        );
        canvas.drawRect(
          Rect.fromCenter(center: Offset(w * 0.5, h * 0.44), width: w * 0.34, height: w * 0.34),
          Paint()..color = const Color(0xFFFEF08A),
        );
        canvas.drawRect(
          Rect.fromLTWH(0, h * 0.72, w, h * 0.28),
          Paint()..color = const Color(0xFF15803D),
        );
        break;
      case 1: // Light & Shadows (Minecraft Torch/Lantern voxel)
        canvas.drawRect(Rect.fromLTWH(0, 0, w, h), Paint()..color = const Color(0xFF1B1612));
        canvas.drawCircle(
          Offset(w * 0.5, h * 0.32),
          w * 0.45,
          Paint()..color = const Color(0xFFF59E0B).withValues(alpha: 0.35),
        );
        canvas.drawRect(
          Rect.fromLTWH(w * 0.42, h * 0.40, w * 0.16, h * 0.48),
          Paint()..color = const Color(0xFF92400E),
        );
        canvas.drawRect(
          Rect.fromLTWH(w * 0.38, h * 0.22, w * 0.24, h * 0.20),
          Paint()..color = const Color(0xFFFBBF24),
        );
        canvas.drawRect(
          Rect.fromLTWH(w * 0.43, h * 0.25, w * 0.14, h * 0.12),
          Paint()..color = const Color(0xFFFFFBEB),
        );
        break;
      case 2: // Fog & Air
        canvas.drawRect(
          Rect.fromLTWH(0, 0, w, h),
          Paint()
            ..shader = const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFF334155), Color(0xFF94A3B8)],
            ).createShader(Rect.fromLTWH(0, 0, w, h)),
        );
        canvas.drawRect(
          Rect.fromLTWH(w * 0.1, h * 0.42, w * 0.45, h * 0.35),
          Paint()..color = const Color(0xFF475569),
        );
        canvas.drawRect(
          Rect.fromLTWH(w * 0.42, h * 0.32, w * 0.48, h * 0.45),
          Paint()..color = const Color(0xFF64748B),
        );
        canvas.drawRect(
          Rect.fromLTWH(0, h * 0.58, w, h * 0.42),
          Paint()..color = Colors.white.withValues(alpha: 0.45),
        );
        break;
      case 3: // Water
        canvas.drawRect(
          Rect.fromLTWH(0, 0, w, h),
          Paint()
            ..shader = const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFF06B6D4), Color(0xFF0369A1)],
            ).createShader(Rect.fromLTWH(0, 0, w, h)),
        );
        final wavePaint = Paint()..color = const Color(0xFFA5F3FC).withValues(alpha: 0.8);
        canvas.drawRect(Rect.fromLTWH(w * 0.1, h * 0.30, w * 0.45, 2), wavePaint);
        canvas.drawRect(Rect.fromLTWH(w * 0.35, h * 0.56, w * 0.52, 2), wavePaint);
        canvas.drawRect(Rect.fromLTWH(w * 0.18, h * 0.78, w * 0.38, 2), wavePaint);
        break;
      case 4: // Color & Mood
        canvas.drawRect(Rect.fromLTWH(0, 0, w * 0.5, h * 0.5), Paint()..color = const Color(0xFFF43F5E));
        canvas.drawRect(Rect.fromLTWH(w * 0.5, 0, w * 0.5, h * 0.5), Paint()..color = const Color(0xFFFBBF24));
        canvas.drawRect(Rect.fromLTWH(0, h * 0.5, w * 0.5, h * 0.5), Paint()..color = const Color(0xFF3B82F6));
        canvas.drawRect(Rect.fromLTWH(w * 0.5, h * 0.5, w * 0.5, h * 0.5), Paint()..color = const Color(0xFF22C55E));
        break;
      case 5: // Biomes (Minecraft Grass Block)
        canvas.drawRect(Rect.fromLTWH(0, 0, w, h), Paint()..color = const Color(0xFF1E293B));
        canvas.drawRect(Rect.fromLTWH(w * 0.12, h * 0.12, w * 0.76, h * 0.24), Paint()..color = const Color(0xFF22C55E));
        canvas.drawRect(Rect.fromLTWH(w * 0.24, h * 0.36, w * 0.16, h * 0.10), Paint()..color = const Color(0xFF22C55E));
        canvas.drawRect(Rect.fromLTWH(w * 0.60, h * 0.36, w * 0.16, h * 0.12), Paint()..color = const Color(0xFF22C55E));
        canvas.drawRect(Rect.fromLTWH(w * 0.12, h * 0.36, w * 0.76, h * 0.52), Paint()..color = const Color(0xFF78350F));
        break;
      case 6: // Surface (Glossy Cube)
        canvas.drawRect(Rect.fromLTWH(0, 0, w, h), Paint()..color = const Color(0xFF0F172A));
        canvas.drawRect(Rect.fromLTWH(w * 0.16, h * 0.16, w * 0.68, h * 0.68), Paint()..color = const Color(0xFF64748B));
        canvas.drawRect(Rect.fromLTWH(w * 0.22, h * 0.22, w * 0.28, h * 0.18), Paint()..color = const Color(0xFFE2E8F0));
        canvas.drawRect(Rect.fromLTWH(w * 0.50, h * 0.44, w * 0.34, h * 0.40), Paint()..color = const Color(0xFF334155));
        break;
      case 7: // Performance (FPS / Speed Bars)
        canvas.drawRect(Rect.fromLTWH(0, 0, w, h), Paint()..color = const Color(0xFF0F172A));
        canvas.drawRect(Rect.fromLTWH(w * 0.16, h * 0.56, w * 0.18, h * 0.28), Paint()..color = _kEmerald);
        canvas.drawRect(Rect.fromLTWH(w * 0.41, h * 0.38, w * 0.18, h * 0.46), Paint()..color = _kEmerald);
        canvas.drawRect(Rect.fromLTWH(w * 0.66, h * 0.20, w * 0.18, h * 0.64), Paint()..color = const Color(0xFF86EFAC));
        break;
      case 8: // Export (Chest / Pack)
      default:
        canvas.drawRect(Rect.fromLTWH(0, 0, w, h), Paint()..color = const Color(0xFF451A03));
        canvas.drawRect(Rect.fromLTWH(w * 0.12, h * 0.16, w * 0.76, h * 0.68), Paint()..color = const Color(0xFFB45309));
        canvas.drawRect(Rect.fromLTWH(w * 0.12, h * 0.42, w * 0.76, h * 0.12), Paint()..color = const Color(0xFF1F2937));
        canvas.drawRect(Rect.fromLTWH(w * 0.42, h * 0.36, w * 0.16, h * 0.22), Paint()..color = const Color(0xFFFBBF24));
        break;
    }

    if (!isSelected) {
      canvas.drawRect(
        Rect.fromLTWH(0, 0, w, h),
        Paint()..color = Colors.black.withValues(alpha: 0.28),
      );
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _VVTabMiniArtPainter oldDelegate) =>
      oldDelegate.tabIndex != tabIndex || oldDelegate.isSelected != isSelected;
}

// ═════════════════════════════════════════════════════════════════════════════
// 2. BOXY CARD SCENE ARTWORK PAINTERS (For Minecraft-style large box buttons)
// ═════════════════════════════════════════════════════════════════════════════

enum VVSceneBoxType {
  morning,
  noon,
  evening,
  night,
  sunlight,
  cave,
  blockLights,
  torch,
  lantern,
  soulFire,
  candle,
  redstone,
  endRod,
  copper,
  airFog,
  weatherFog,
  underwaterFog,
  waterTropical,
  waterOcean,
  waterDeepOcean,
  waterRiver,
  waterSwamp,
  moodDynamic,
  moodVibrant,
  moodSavanna,
  moodFrost,
  moodMoody,
}

Color _desaturateVVColor(Color c, double desat) {
  final d = desat.clamp(0.0, 1.0);
  if (d <= 0.001) return c;
  final lum = (0.299 * c.r + 0.587 * c.g + 0.114 * c.b).clamp(0.0, 1.0);
  final gray = Color.from(alpha: c.a, red: lum, green: lum, blue: lum);
  return Color.lerp(c, gray, d * 0.82)!;
}

/// Draws a textured 4x4-subpixel Minecraft block tile (stone, deepslate, grass/dirt, stoneBrick, plank, log, ore).
void _drawMcBlockTile(
  Canvas canvas,
  Rect rect, {
  required String kind, // 'stone'|'deepslate'|'grass'|'dirt'|'stoneBrick'|'plank'|'log'|'ore'|'crate'
  required Color baseColor,
  Color? accentColor,
  Color? lightEdge,
  Color? darkEdge,
  int seed = 0,
}) {
  final dark = darkEdge ?? Color.lerp(baseColor, Colors.black, 0.34)!;
  final light = lightEdge ?? Color.lerp(baseColor, Colors.white, 0.16)!;
  final px = rect.width / 4.0;
  final py = rect.height / 4.0;

  canvas.drawRect(rect, Paint()..color = baseColor);

  switch (kind) {
    case 'grass':
      final grassTop = accentColor ?? const Color(0xFF4ADE80);
      final grassEdge = Color.lerp(grassTop, const Color(0xFF15803D), 0.45)!;
      // Dirt speckles
      canvas.drawRect(Rect.fromLTWH(rect.left + px * 0.6, rect.top + py * 2.2, px, py * 0.8), Paint()..color = dark);
      canvas.drawRect(Rect.fromLTWH(rect.left + px * 2.4, rect.top + py * 2.8, px * 0.9, py * 0.8), Paint()..color = dark);
      canvas.drawRect(Rect.fromLTWH(rect.left + px * 1.4, rect.top + py * 1.8, px * 0.8, py * 0.7), Paint()..color = light);
      // Grass turf top cap + Minecraft hanging grass overhang pixels
      canvas.drawRect(Rect.fromLTWH(rect.left, rect.top, rect.width, py * 1.05), Paint()..color = grassTop);
      canvas.drawRect(Rect.fromLTWH(rect.left + px * 0.2, rect.top + py, px * 0.9, py * 0.55), Paint()..color = grassEdge);
      canvas.drawRect(Rect.fromLTWH(rect.left + px * 1.5, rect.top + py, px * 1.0, py * 0.75), Paint()..color = grassEdge);
      canvas.drawRect(Rect.fromLTWH(rect.left + px * 3.0, rect.top + py, px * 0.8, py * 0.5), Paint()..color = grassEdge);
      break;

    case 'dirt':
      canvas.drawRect(Rect.fromLTWH(rect.left + px * 0.5, rect.top + py * 0.8, px, py * 0.9), Paint()..color = dark);
      canvas.drawRect(Rect.fromLTWH(rect.left + px * 2.5, rect.top + py * 2.1, px, py * 0.9), Paint()..color = dark);
      canvas.drawRect(Rect.fromLTWH(rect.left + px * 1.4, rect.top + py * 2.6, px * 0.8, py * 0.7), Paint()..color = light);
      break;

    case 'stoneBrick':
      // Classic staggered 2-row Minecraft Stone Brick tile
      final mortar = Paint()..color = dark;
      canvas.drawRect(Rect.fromLTWH(rect.left, rect.top, rect.width, py * 0.35), Paint()..color = light);
      canvas.drawRect(Rect.fromLTWH(rect.left, rect.top + py * 1.85, rect.width, py * 0.35), mortar);
      canvas.drawRect(Rect.fromLTWH(rect.left, rect.bottom - py * 0.32, rect.width, py * 0.32), mortar);
      final jointX = seed.isEven ? px * 1.8 : px * 2.2;
      canvas.drawRect(Rect.fromLTWH(rect.left + jointX, rect.top, px * 0.32, py * 1.9), mortar);
      canvas.drawRect(Rect.fromLTWH(rect.left + px * 0.2, rect.top + py * 2.1, px * 0.32, py * 1.9), mortar);
      canvas.drawRect(Rect.fromLTWH(rect.left + px * 3.5, rect.top + py * 2.1, px * 0.32, py * 1.9), mortar);
      break;

    case 'plank':
      final plankSep = Paint()..color = dark;
      canvas.drawRect(Rect.fromLTWH(rect.left, rect.top, rect.width, py * 0.3), Paint()..color = light);
      canvas.drawRect(Rect.fromLTWH(rect.left, rect.top + py, rect.width, py * 0.25), plankSep);
      canvas.drawRect(Rect.fromLTWH(rect.left, rect.top + py * 2, rect.width, py * 0.25), plankSep);
      canvas.drawRect(Rect.fromLTWH(rect.left, rect.top + py * 3, rect.width, py * 0.25), plankSep);
      canvas.drawRect(Rect.fromLTWH(rect.left + px * ((seed % 3) + 0.8), rect.top + py, px * 0.3, py), plankSep);
      canvas.drawRect(Rect.fromLTWH(rect.left + px * (((seed + 1) % 3) + 0.6), rect.top + py * 3, px * 0.3, py), plankSep);
      break;

    case 'log':
      canvas.drawRect(Rect.fromLTWH(rect.left + px * 0.6, rect.top, px * 0.7, rect.height), Paint()..color = light);
      canvas.drawRect(Rect.fromLTWH(rect.left + px * 2.1, rect.top, px * 0.6, rect.height), Paint()..color = dark);
      canvas.drawRect(Rect.fromLTWH(rect.left + px * 3.2, rect.top, px * 0.8, rect.height), Paint()..color = dark);
      break;

    case 'crate':
      canvas.drawRect(rect.deflate(px * 0.45), Paint()..color = light);
      canvas.drawRect(rect.deflate(px * 0.85), Paint()..color = baseColor);
      canvas.drawRect(Rect.fromLTWH(rect.left, rect.top + py * 1.7, rect.width, py * 0.55), Paint()..color = dark);
      canvas.drawRect(Rect.fromLTWH(rect.left + px * 1.7, rect.top, px * 0.55, rect.height), Paint()..color = dark);
      break;

    case 'ore':
    case 'deepslate':
    case 'stone':
    default:
      final s1 = (seed % 2 == 0) ? 0.4 : 1.1;
      final s2 = (seed % 3 == 0) ? 2.2 : 1.7;
      canvas.drawRect(Rect.fromLTWH(rect.left + px * s1, rect.top + py * 0.4, px * 1.4, py * 0.85), Paint()..color = light);
      canvas.drawRect(Rect.fromLTWH(rect.left + px * 0.3, rect.top + py * 2.2, px * 1.6, py * 0.9), Paint()..color = dark);
      canvas.drawRect(Rect.fromLTWH(rect.left + px * s2, rect.top + py * 1.3, px * 1.3, py * 0.8), Paint()..color = dark);
      canvas.drawRect(Rect.fromLTWH(rect.left, rect.top, rect.width, 0.9), Paint()..color = light.withValues(alpha: 0.42));
      canvas.drawRect(Rect.fromLTWH(rect.left, rect.bottom - 0.9, rect.width, 0.9), Paint()..color = dark.withValues(alpha: 0.72));
      if (kind == 'ore' && accentColor != null) {
        final oreBright = Color.lerp(accentColor, Colors.white, 0.55)!;
        canvas.drawRect(Rect.fromLTWH(rect.left + px * 0.6, rect.top + py * 0.7, px * 1.0, py * 0.9), Paint()..color = accentColor);
        canvas.drawRect(Rect.fromLTWH(rect.left + px * 2.3, rect.top + py * 1.1, px * 0.9, py * 0.9), Paint()..color = accentColor);
        canvas.drawRect(Rect.fromLTWH(rect.left + px * 1.2, rect.top + py * 2.4, px * 1.1, py * 0.9), Paint()..color = accentColor);
        canvas.drawRect(Rect.fromLTWH(rect.left + px * 0.8, rect.top + py * 0.8, px * 0.45, py * 0.45), Paint()..color = oreBright);
        canvas.drawRect(Rect.fromLTWH(rect.left + px * 2.5, rect.top + py * 1.2, px * 0.45, py * 0.45), Paint()..color = oreBright);
      }
      break;
  }
}

/// Draws a crisp 3D isometric voxel prism (left lit face, right shaded face, optional top diamond).
void _drawIsoPrism(
  Canvas canvas, {
  required Offset bottomCenter,
  required double halfW,
  required double depthY,
  required double height,
  Color? topColor,
  required Color leftColor,
  required Color rightColor,
}) {
  final bFront = bottomCenter;
  final bLeft = Offset(bottomCenter.dx - halfW, bottomCenter.dy - depthY);
  final bRight = Offset(bottomCenter.dx + halfW, bottomCenter.dy - depthY);
  final tFront = Offset(bFront.dx, bFront.dy - height);
  final tLeft = Offset(bLeft.dx, bLeft.dy - height);
  final tRight = Offset(bRight.dx, bRight.dy - height);
  final tBack = Offset(bottomCenter.dx, bottomCenter.dy - depthY * 2.0 - height);

  // Left face
  canvas.drawPath(
    Path()
      ..moveTo(bFront.dx, bFront.dy)
      ..lineTo(bLeft.dx, bLeft.dy)
      ..lineTo(tLeft.dx, tLeft.dy)
      ..lineTo(tFront.dx, tFront.dy)
      ..close(),
    Paint()..color = leftColor,
  );
  // Right face
  canvas.drawPath(
    Path()
      ..moveTo(bFront.dx, bFront.dy)
      ..lineTo(bRight.dx, bRight.dy)
      ..lineTo(tRight.dx, tRight.dy)
      ..lineTo(tFront.dx, tFront.dy)
      ..close(),
    Paint()..color = rightColor,
  );
  // Top diamond
  if (topColor != null) {
    canvas.drawPath(
      Path()
        ..moveTo(tFront.dx, tFront.dy)
        ..lineTo(tLeft.dx, tLeft.dy)
        ..lineTo(tBack.dx, tBack.dy)
        ..lineTo(tRight.dx, tRight.dy)
        ..close(),
      Paint()..color = topColor,
    );
  }
}

/// Crisp 3D isometric perforated Minecraft Oak Tree (inspired by reference image 1).
void _drawMcUnitOakTree(
  Canvas canvas, {
  required double cx,
  required double groundY,
  required double u,
  required bool sunOnRight,
  required Color trunkLit,
  required Color trunkDark,
  required Color leafLight,
  required Color leafMid,
  required Color leafDark,
}) {
  final trunkHalfW = u * 0.92;
  final trunkDepth = u * 0.44;
  final trunkH = u * 3.1;
  final basePt = Offset(cx, groundY);
  final leftFaceCol = sunOnRight ? Color.lerp(trunkLit, trunkDark, 0.45)! : trunkLit;
  final rightFaceCol = sunOnRight ? trunkLit : trunkDark;

  _drawIsoPrism(
    canvas,
    bottomCenter: basePt,
    halfW: trunkHalfW,
    depthY: trunkDepth,
    height: trunkH,
    leftColor: leftFaceCol,
    rightColor: rightFaceCol,
  );
  // Vertical bark grain grooves on both isometric trunk faces
  final barkPaint = Paint()..color = trunkDark.withValues(alpha: 0.68);
  for (final frac in const [0.30, 0.68]) {
    canvas.drawRect(
      Rect.fromLTWH(cx - trunkHalfW * frac, groundY - trunkH * 0.92, math.max(1.2, u * 0.18), trunkH * 0.88),
      barkPaint,
    );
    canvas.drawRect(
      Rect.fromLTWH(cx + trunkHalfW * frac * 0.85, groundY - trunkH * 0.92, math.max(1.2, u * 0.18), trunkH * 0.88),
      barkPaint,
    );
  }

  // Deep underside shadow directly beneath canopy overhang on trunk
  final canopyBase = Offset(cx, groundY - trunkH + u * 0.25);
  canvas.drawPath(
    Path()
      ..moveTo(canopyBase.dx, canopyBase.dy)
      ..lineTo(canopyBase.dx - u * 2.9, canopyBase.dy - u * 1.15)
      ..lineTo(canopyBase.dx, canopyBase.dy - u * 2.2)
      ..lineTo(canopyBase.dx + u * 2.9, canopyBase.dy - u * 1.15)
      ..close(),
    Paint()..color = leafDark.withValues(alpha: 0.88),
  );

  // Lower main 3D canopy mass + upper stepped crown (with sunlit directional face)
  final cHalfW = u * 2.85;
  final cDepth = u * 1.30;
  final cHeight = u * 2.25;
  final leftCanopy = sunOnRight ? leafMid : leafLight;
  final rightCanopy = sunOnRight ? leafLight : leafDark;
  final topCanopy = Color.lerp(leafLight, Colors.white, 0.14)!;

  _drawIsoPrism(
    canvas,
    bottomCenter: canopyBase,
    halfW: cHalfW,
    depthY: cDepth,
    height: cHeight,
    topColor: topCanopy,
    leftColor: leftCanopy,
    rightColor: rightCanopy,
  );

  // Upper stepped crown tier (3x3 cube top)
  final crownBase = Offset(cx, canopyBase.dy - cHeight - u * 0.25);
  _drawIsoPrism(
    canvas,
    bottomCenter: crownBase,
    halfW: cHalfW * 0.64,
    depthY: cDepth * 0.64,
    height: u * 1.15,
    topColor: topCanopy,
    leftColor: sunOnRight ? leafMid : leafLight,
    rightColor: sunOnRight ? leafLight : Color.lerp(leafMid, leafDark, 0.55)!,
  );

  // Iconic Minecraft lacy/perforated leaf cluster texture across canopy silhouette
  final gapPaint = Paint()..color = const Color(0xFF0A1404).withValues(alpha: 0.48);
  final litLeaf = Paint()..color = leafLight;
  final darkLeaf = Paint()..color = leafDark.withValues(alpha: 0.78);
  final px = math.max(1.5, u * 0.34);

  // Scatter leaf tufts and crisp 1px dark canopy cavities across left & right faces
  for (int row = 0; row < 5; row++) {
    for (int col = -4; col <= 4; col++) {
      final hash = ((row * 7 + (col + 5) * 13) % 11);
      final lx = cx + col * px * 1.48;
      final ly = canopyBase.dy - cHeight * 0.96 + row * px * 1.12 - (col.abs() * 0.28 * px);
      if (hash == 0 || hash == 5) {
        canvas.drawRect(Rect.fromLTWH(lx, ly, px * 1.05, px * 1.05), gapPaint);
      } else if (hash == 2 || hash == 8) {
        canvas.drawRect(
          Rect.fromLTWH(lx, ly, px * 1.15, px * 1.15),
          (sunOnRight ? col >= 0 : col <= 0) ? litLeaf : darkLeaf,
        );
      }
    }
  }
  // Jagged silhouette leaf tufts protruding cleanly on outer top/side corners
  for (final tuft in [
    Offset(cx - cHalfW * 0.96, canopyBase.dy - cHeight * 0.68),
    Offset(cx + cHalfW * 0.88, canopyBase.dy - cHeight * 0.58),
    Offset(cx - u * 0.45, crownBase.dy - u * 1.85),
    Offset(cx + u * 0.65, crownBase.dy - u * 1.55),
  ]) {
    canvas.drawRect(Rect.fromLTWH(tuft.dx, tuft.dy, px * 1.35, px * 1.35), litLeaf);
  }
}

/// Authentic tiered Minecraft Spruce / Pine Tree (inspired by Fog reference image 1).
void _drawMcSpruceTree(
  Canvas canvas, {
  required double cx,
  required double groundY,
  required double u,
  required Color trunkColor,
  required Color needleLight,
  required Color needleMid,
  required Color needleDark,
  double wind = 0.0,
}) {
  final trunkW = (u * 1.3).clamp(2.5, 7.5);
  final trunkH = u * 7.5;
  final trunkTop = groundY - trunkH;
  // 3D shaded vertical spruce trunk
  canvas.drawRect(
    Rect.fromLTWH(cx - trunkW * 0.5 + wind * 0.2, trunkTop, trunkW * 0.5, trunkH),
    Paint()..color = trunkColor,
  );
  canvas.drawRect(
    Rect.fromLTWH(cx + wind * 0.2, trunkTop, trunkW * 0.5, trunkH),
    Paint()..color = Color.lerp(trunkColor, Colors.black, 0.35)!,
  );

  // Stepped horizontal needle tiers tapering toward top
  final tiers = [
    (yFrac: 0.88, halfW: u * 3.8, h: u * 2.1), // bottom wide tier
    (yFrac: 0.66, halfW: u * 3.1, h: u * 1.9), // mid-lower tier
    (yFrac: 0.44, halfW: u * 2.4, h: u * 1.7), // mid-upper tier
    (yFrac: 0.22, halfW: u * 1.7, h: u * 1.5), // upper tier
    (yFrac: 0.00, halfW: u * 0.95, h: u * 1.3), // spire
  ];

  for (final t in tiers) {
    final ty = trunkTop + trunkH * t.yFrac;
    final wShift = wind * (1.0 - t.yFrac);
    final tCenter = cx + wShift;
    // Underside shadow
    canvas.drawRect(
      Rect.fromCenter(center: Offset(tCenter, ty + t.h * 0.38), width: t.halfW * 2.0, height: t.h * 0.32),
      Paint()..color = needleDark,
    );
    // Main needle tier
    canvas.drawRect(
      Rect.fromCenter(center: Offset(tCenter, ty), width: t.halfW * 2.0, height: t.h),
      Paint()..color = needleMid,
    );
    // Top-lit needle step
    canvas.drawRect(
      Rect.fromCenter(center: Offset(tCenter, ty - t.h * 0.28), width: t.halfW * 1.35, height: t.h * 0.42),
      Paint()..color = needleLight,
    );
  }
}

/// Towering Minecraft Kelp Stalk (inspired by Underwater reference image 2).
void _drawMcKelpStalk(
  Canvas canvas, {
  required double x,
  required double baseY,
  required double height,
  required double u,
  required Color kelpColor,
  required Color kelpDark,
  double sway = 0.0,
}) {
  final segments = (height / (u * 2.0)).round().clamp(3, 16);
  final segH = height / segments;
  for (int i = 0; i < segments; i++) {
    final frac = i / segments;
    final sy = baseY - i * segH;
    final sSway = sway * math.sin(frac * math.pi) * (u * 1.1);
    final sx = x + sSway;
    // Main vertical kelp stem
    canvas.drawRect(
      Rect.fromLTWH(sx - u * 0.32, sy - segH, u * 0.64, segH),
      Paint()..color = kelpColor,
    );
    // Alternating leaf nodes
    final isLeft = i.isEven;
    final leafW = u * 1.6;
    final lx = isLeft ? sx - leafW : sx + u * 0.32;
    canvas.drawRect(
      Rect.fromLTWH(lx, sy - segH * 0.72, leafW, u * 0.72),
      Paint()..color = isLeft ? kelpColor : kelpDark,
    );
  }
}

/// Lush Minecraft Seagrass tufts (short and tall, inspired by reference image 2).
void _drawMcSeagrass(
  Canvas canvas, {
  required double x,
  required double baseY,
  required double u,
  required Color grassColor,
  required Color grassDark,
  bool isTall = false,
  double sway = 0.0,
}) {
  final h = isTall ? u * 3.5 : u * 1.9;
  final w = u * 0.65;
  // Left blade
  canvas.drawRect(
    Rect.fromLTWH(x - w * 1.1 + sway * 0.5, baseY - h, w, h),
    Paint()..color = grassColor,
  );
  // Notched blade tip
  canvas.drawRect(
    Rect.fromLTWH(x - w * 1.1 + sway * 0.5, baseY - h - u * 0.35, w * 0.55, u * 0.35),
    Paint()..color = grassColor,
  );
  // Right blade
  final hRight = h * 0.78;
  canvas.drawRect(
    Rect.fromLTWH(x + w * 0.2 + sway * 0.3, baseY - hRight, w, hRight),
    Paint()..color = grassDark,
  );
}

void _drawVVStoneBricks(
  Canvas canvas,
  Rect bounds, {
  required double brickW,
  required double brickH,
  required Color baseColor,
  required Color mortarColor,
  Color? lightTint,
  Offset? lightPos,
  double lightRadius = 0.0,
  double lightStrength = 0.0,
}) {
  canvas.drawRect(bounds, Paint()..color = baseColor);
  final mortar = Paint()..color = mortarColor;
  final rows = (bounds.height / brickH).ceil();
  for (int row = 0; row < rows; row++) {
    final by = bounds.top + row * brickH;
    final bh = math.min(brickH, bounds.bottom - by);
    final stagger = (row.isOdd ? brickW * 0.5 : 0.0);
    final cols = ((bounds.width + brickW) / brickW).ceil();
    for (int col = -1; col < cols; col++) {
      final bx = bounds.left + col * brickW + stagger;
      final rect = Rect.fromLTWH(bx, by, brickW, bh).intersect(bounds);
      if (rect.isEmpty) continue;
      final shadeSeed = ((row * 7 + col * 13) % 5) * 0.035;
      var brickColor = Color.lerp(baseColor, mortarColor, shadeSeed)!;
      if (lightTint != null && lightPos != null && lightRadius > 0 && lightStrength > 0) {
        final dist = (rect.center - lightPos).distance;
        final falloff = (1.0 - dist / lightRadius).clamp(0.0, 1.0);
        if (falloff > 0.001) {
          brickColor = Color.lerp(
            brickColor,
            Color.lerp(brickColor, lightTint, 0.58)!,
            falloff * falloff * lightStrength,
          )!;
        }
      }
      canvas.drawRect(rect, Paint()..color = brickColor);
      if (lightTint != null && lightPos != null && lightRadius > 0 && lightStrength > 0) {
        final dist = (rect.center - lightPos).distance;
        final falloff = (1.0 - dist / lightRadius).clamp(0.0, 1.0);
        if (falloff > 0.04) {
          canvas.drawRect(
            Rect.fromLTWH(rect.left + 1, rect.top + 1, math.max(0, rect.width - 2), 1.5),
            Paint()..color = lightTint.withValues(alpha: falloff * 0.28 * lightStrength),
          );
        }
      }
      canvas.drawRect(Rect.fromLTWH(rect.left, rect.bottom - 1.1, rect.width, 1.1), mortar);
      canvas.drawRect(Rect.fromLTWH(rect.right - 1.1, rect.top, 1.1, rect.height), mortar);
    }
  }
}

/// Draws authentic 3D isometric Minecraft block-light items across selector cards and full preview banner.
Offset _drawVoxelBlockLightItem(
  Canvas canvas,
  String kind,
  Offset anchor,
  double u,
  Color rawGlowColor, {
  double flicker = 0.0,
  double desaturation = 0.0,
  double hangLength = 0.0,
  bool includeCompanionProps = false,
  bool syncMystic = false,
}) {
  final glow = _desaturateVVColor(rawGlowColor, desaturation);
  final brightCore = Color.lerp(glow, Colors.white, 0.84)!;
  final warmInner = Color.lerp(glow, const Color(0xFFFEF08A), 0.55)!;

  switch (kind) {
    case 'lantern':
      // Authentic 3D Isometric Minecraft Hanging Iron Lantern
      // 1. Ceiling Mount Flange & Stud
      final mountFlangeW = u * 3.4;
      final mountFlangeH = (u * 0.6).clamp(2.0, 4.0);
      canvas.drawRect(
        Rect.fromCenter(center: Offset(anchor.dx, anchor.dy + mountFlangeH * 0.5), width: mountFlangeW, height: mountFlangeH),
        Paint()..color = const Color(0xFF334155),
      );
      canvas.drawRect(
        Rect.fromLTWH(anchor.dx - mountFlangeW * 0.45, anchor.dy, mountFlangeW * 0.9, mountFlangeH * 0.35),
        Paint()..color = const Color(0xFF64748B),
      );

      // 2. True Minecraft Interlocking Iron Chain Links
      final chainLen = hangLength > 0 ? hangLength : u * 5.6;
      final rawLinkH = (u * 1.5).clamp(4.5, 9.0);
      final nLinks = math.max(2, (chainLen / rawLinkH).round());
      final linkH = chainLen / nLinks;
      final chainTopY = anchor.dy + mountFlangeH;

      for (int i = 0; i < nLinks; i++) {
        final ly = chainTopY + i * linkH;
        final cx = anchor.dx;
        if (i.isEven) {
          // Face-on chain link: hollow rectangular iron loop
          final wLink = u * 1.5;
          final hLink = linkH + u * 0.25;
          final thick = (u * 0.38).clamp(1.2, 2.5);
          // Left bar
          canvas.drawRect(Rect.fromLTWH(cx - wLink * 0.5, ly, thick, hLink), Paint()..color = const Color(0xFF475569));
          canvas.drawRect(Rect.fromLTWH(cx - wLink * 0.5, ly, thick * 0.5, hLink), Paint()..color = const Color(0xFF94A3B8));
          // Right bar
          canvas.drawRect(Rect.fromLTWH(cx + wLink * 0.5 - thick, ly, thick, hLink), Paint()..color = const Color(0xFF1E293B));
          // Top bar
          canvas.drawRect(Rect.fromLTWH(cx - wLink * 0.5, ly, wLink, thick), Paint()..color = const Color(0xFF64748B));
          // Bottom bar
          canvas.drawRect(Rect.fromLTWH(cx - wLink * 0.5, ly + hLink - thick, wLink, thick), Paint()..color = const Color(0xFF0F172A));
        } else {
          // Side-on link: narrow vertical metallic strip interlocking through
          final wLink = (u * 0.70).clamp(2.0, 4.0);
          final hLink = linkH + u * 0.2;
          canvas.drawRect(Rect.fromLTWH(cx - wLink * 0.5, ly, wLink, hLink), Paint()..color = const Color(0xFF1E293B));
          canvas.drawRect(Rect.fromLTWH(cx - wLink * 0.5, ly, wLink * 0.5, hLink), Paint()..color = const Color(0xFF64748B));
        }
      }

      // 3. Upright Iron Loop Handle (the Minecraft Hanging Lantern signature ring!)
      final handleTopY = chainTopY + chainLen;
      final handleW = u * 2.2;
      final handleH = u * 2.0;
      final hThick = (u * 0.42).clamp(1.2, 2.8);
      // Top bar of handle
      canvas.drawRect(Rect.fromLTWH(anchor.dx - handleW * 0.5, handleTopY, handleW, hThick), Paint()..color = const Color(0xFF475569));
      canvas.drawRect(Rect.fromLTWH(anchor.dx - handleW * 0.5, handleTopY, handleW, hThick * 0.5), Paint()..color = const Color(0xFF94A3B8));
      // Left leg
      canvas.drawRect(Rect.fromLTWH(anchor.dx - handleW * 0.5, handleTopY, hThick, handleH), Paint()..color = const Color(0xFF475569));
      // Right leg
      canvas.drawRect(Rect.fromLTWH(anchor.dx + handleW * 0.5 - hThick, handleTopY, hThick, handleH), Paint()..color = const Color(0xFF1E293B));
      // Handle connection stud into roof cap
      canvas.drawRect(
        Rect.fromCenter(center: Offset(anchor.dx, handleTopY + handleH + u * 0.2), width: u * 1.3, height: u * 0.4),
        Paint()..color = const Color(0xFF1E293B),
      );

      // 4. 3D Stepped Iron Roof / Cap
      final capTopY = handleTopY + handleH + u * 0.3;
      // Upper cap tier (small raised square)
      _drawIsoPrism(
        canvas,
        bottomCenter: Offset(anchor.dx, capTopY + u * 0.9),
        halfW: u * 1.8,
        depthY: u * 0.8,
        height: u * 0.9,
        topColor: const Color(0xFF525E75),
        leftColor: const Color(0xFF3B4455),
        rightColor: const Color(0xFF1E2530),
      );
      // Lower roof eaves tier (wide overhang)
      _drawIsoPrism(
        canvas,
        bottomCenter: Offset(anchor.dx, capTopY + u * 2.2),
        halfW: u * 3.6,
        depthY: u * 1.6,
        height: u * 1.3,
        topColor: const Color(0xFF444F63),
        leftColor: const Color(0xFF2E3747),
        rightColor: const Color(0xFF181E29),
      );
      // Underside eaves shadow rim
      canvas.drawRect(
        Rect.fromCenter(center: Offset(anchor.dx, capTopY + u * 2.2), width: u * 6.4, height: u * 0.35),
        Paint()..color = const Color(0xFF090D14),
      );

      // 5. Glowing 3D Glass Chamber with Floating Minecraft Torch Flame Core
      final glassTopY = capTopY + u * 2.2;
      final cageH = u * 5.4;
      final glassBaseY = glassTopY + cageH;
      final halfW = u * 2.7;
      final depthY = u * 1.25;

      _drawIsoPrism(
        canvas,
        bottomCenter: Offset(anchor.dx, glassBaseY),
        halfW: halfW,
        depthY: depthY,
        height: cageH,
        topColor: warmInner,
        leftColor: Color.lerp(glow, Colors.white, 0.36)!.withValues(alpha: 0.92),
        rightColor: Color.lerp(glow, const Color(0xFFEA580C), 0.20)!.withValues(alpha: 0.94),
      );

      // Inner Floating Torch Flame Core inside glass chamber
      final pShift = flicker * u * 0.18;
      final flameCenter = Offset(anchor.dx, glassBaseY - cageH * 0.52 - pShift);
      canvas.drawCircle(
        flameCenter,
        u * 2.0,
        Paint()
          ..shader = RadialGradient(
            colors: [
              brightCore.withValues(alpha: 0.95),
              glow.withValues(alpha: 0.65),
              glow.withValues(alpha: 0.0),
            ],
            stops: const [0.0, 0.45, 1.0],
          ).createShader(Rect.fromCircle(center: flameCenter, radius: u * 2.0)),
      );
      // Minecraft mini flame cube
      canvas.drawRect(
        Rect.fromLTWH(flameCenter.dx - u * 0.85, flameCenter.dy - u * 0.9, u * 0.85, u * 1.8),
        Paint()..color = Color.lerp(glow, const Color(0xFFFDE047), 0.50)!,
      );
      canvas.drawRect(
        Rect.fromLTWH(flameCenter.dx, flameCenter.dy - u * 0.9, u * 0.85, u * 1.8),
        Paint()..color = glow,
      );
      canvas.drawRect(
        Rect.fromCenter(center: flameCenter, width: u * 0.85, height: u * 1.2),
        Paint()..color = Colors.white,
      );
      // Flickering sparks
      canvas.drawRect(
        Rect.fromLTWH(flameCenter.dx - u * 0.4, flameCenter.dy - u * 1.7, u * 0.45, u * 0.45),
        Paint()..color = brightCore,
      );
      canvas.drawRect(
        Rect.fromLTWH(flameCenter.dx + u * 0.5, flameCenter.dy - u * 1.3, u * 0.4, u * 0.4),
        Paint()..color = const Color(0xFFF59E0B),
      );

      // 6. 3D Iron Cage Struts (4 corner pillars + horizontal bands)
      final strutColLeft = const Color(0xFF2D3543);
      final strutColRight = const Color(0xFF161B24);
      final strutHighlight = const Color(0xFF64748B);
      final strutW = (u * 0.62).clamp(1.8, 3.8);

      // Left corner vertical strut
      canvas.drawRect(Rect.fromLTWH(anchor.dx - halfW, glassTopY, strutW, cageH), Paint()..color = strutColLeft);
      canvas.drawRect(Rect.fromLTWH(anchor.dx - halfW, glassTopY, strutW * 0.4, cageH), Paint()..color = strutHighlight);
      // Right corner vertical strut
      canvas.drawRect(Rect.fromLTWH(anchor.dx + halfW - strutW, glassTopY, strutW, cageH), Paint()..color = strutColRight);
      // Center front vertical strut (apex spine)
      canvas.drawRect(Rect.fromLTWH(anchor.dx - strutW * 0.5, glassTopY, strutW * 0.5, cageH), Paint()..color = strutColLeft);
      canvas.drawRect(Rect.fromLTWH(anchor.dx, glassTopY, strutW * 0.5, cageH), Paint()..color = strutColRight);
      canvas.drawRect(Rect.fromLTWH(anchor.dx - strutW * 0.5, glassTopY, strutW * 0.25, cageH), Paint()..color = strutHighlight);

      // Horizontal iron collar bands (top & bottom of glass)
      final bandH = (u * 0.55).clamp(1.5, 3.2);
      // Top band
      canvas.drawRect(Rect.fromLTWH(anchor.dx - halfW, glassTopY, halfW * 2, bandH), Paint()..color = strutColLeft);
      // Bottom band
      canvas.drawRect(Rect.fromLTWH(anchor.dx - halfW, glassBaseY - bandH, halfW * 2, bandH), Paint()..color = strutColRight);
      // Mid-height crossbar
      canvas.drawRect(Rect.fromLTWH(anchor.dx - halfW, glassBaseY - cageH * 0.5 - bandH * 0.5, halfW * 2, bandH * 0.8), Paint()..color = const Color(0xFF1E293B));

      // 7. 3D Heavy Iron Baseplate
      _drawIsoPrism(
        canvas,
        bottomCenter: Offset(anchor.dx, glassBaseY + u * 1.3),
        halfW: u * 3.4,
        depthY: u * 1.55,
        height: u * 1.3,
        topColor: Color.lerp(const Color(0xFF374151), glow, 0.25)!,
        leftColor: const Color(0xFF262D38),
        rightColor: const Color(0xFF11161F),
      );
      // Underside shadow rim
      canvas.drawRect(
        Rect.fromCenter(center: Offset(anchor.dx, glassBaseY + u * 1.3), width: u * 6.0, height: u * 0.4),
        Paint()..color = const Color(0xFF070A0F),
      );

      return flameCenter;

    case 'torch':
      // True 3D Isometric Minecraft Torch matching uploaded Image 3 pixel-for-pixel!
      final stickHalfW = u * 1.48;
      final stickDepth = u * 0.72;
      final flameH = u * 2.35;
      final woodH = u * 7.4;

      // 3D Isometric Wood Handle with mottled oak grain rows on both faces
      _drawIsoPrism(
        canvas,
        bottomCenter: anchor,
        halfW: stickHalfW,
        depthY: stickDepth,
        height: woodH,
        leftColor: const Color(0xFF8C6239),
        rightColor: const Color(0xFF5D3D21),
      );
      // Alternating bark pixel bands matching Image 3
      final woodRows = 6;
      final rowH = woodH / woodRows;
      for (int r = 0; r < woodRows; r++) {
        final ry = anchor.dy - woodH + r * rowH;
        // Left lit wood grain flecks
        canvas.drawRect(
          Rect.fromLTWH(anchor.dx - stickHalfW * (r.isEven ? 0.85 : 0.45), ry - (r.isEven ? 0.2 : 0.4) * stickDepth, stickHalfW * 0.42, rowH * 0.82),
          Paint()..color = r % 3 == 0 ? const Color(0xFFA1754A) : const Color(0xFF704B2A),
        );
        // Right shaded wood grain flecks
        canvas.drawRect(
          Rect.fromLTWH(anchor.dx + stickHalfW * (r.isOdd ? 0.42 : 0.08), ry - (r.isOdd ? 0.25 : 0.45) * stickDepth, stickHalfW * 0.42, rowH * 0.82),
          Paint()..color = r % 3 == 0 ? const Color(0xFF6B4829) : const Color(0xFF422915),
        );
      }

      // 3D Isometric Flame Head Cube (white-hot center corners, gold top, glowing side cheeks)
      final flameBottom = Offset(anchor.dx, anchor.dy - woodH);
      final leftFlameCol = Color.lerp(glow, const Color(0xFFFDE047), 0.38)!;
      final rightFlameCol = glow;
      final topFlameCol = Color.lerp(glow, const Color(0xFFFEF08A), 0.55)!;

      _drawIsoPrism(
        canvas,
        bottomCenter: flameBottom,
        halfW: stickHalfW,
        depthY: stickDepth,
        height: flameH,
        topColor: topFlameCol,
        leftColor: leftFlameCol,
        rightColor: rightFlameCol,
      );
      // Iconic bright white/pale-yellow 4-pixel flame hot core on front/top facets
      final fShift = flicker * u * 0.14;
      canvas.drawRect(
        Rect.fromLTWH(anchor.dx - stickHalfW * 0.65, flameBottom.dy - flameH * 0.65 + fShift, stickHalfW * 0.65, flameH * 0.58),
        Paint()..color = const Color(0xFFFEF9C3),
      );
      canvas.drawRect(
        Rect.fromLTWH(anchor.dx - stickHalfW * 0.35, flameBottom.dy - flameH * 0.42 + fShift, stickHalfW * 0.68, flameH * 0.40),
        Paint()..color = Colors.white.withValues(alpha: 0.94),
      );
      canvas.drawRect(
        Rect.fromLTWH(anchor.dx + stickHalfW * 0.22, flameBottom.dy - flameH * 0.82, stickHalfW * 0.48, flameH * 0.42),
        Paint()..color = glow,
      );
      // Tiny rising ember spark pixels
      canvas.drawRect(
        Rect.fromLTWH(anchor.dx - u * 0.9 - flicker * u * 0.4, flameBottom.dy - flameH - u * 1.8, u * 0.55, u * 0.55),
        Paint()..color = brightCore.withValues(alpha: 0.85),
      );
      canvas.drawRect(
        Rect.fromLTWH(anchor.dx + u * 0.7 + flicker * u * 0.4, flameBottom.dy - flameH - u * 2.4, u * 0.5, u * 0.5),
        Paint()..color = glow.withValues(alpha: 0.85),
      );
      return Offset(anchor.dx, flameBottom.dy - flameH * 0.5);

    case 'soul':
      // Textured 3D Soul Soil pedestal + 3 vibrant cyan Soul Fire flame tongues (+ optional Sea Lantern if synced)
      final soilHalfW = u * (includeCompanionProps ? 4.4 : 3.6);
      final soilDepth = u * 1.75;
      final soilH = u * 3.0;
      _drawIsoPrism(
        canvas,
        bottomCenter: anchor,
        halfW: soilHalfW,
        depthY: soilDepth,
        height: soilH,
        topColor: Color.lerp(const Color(0xFF3E2E26), glow, 0.28)!,
        leftColor: const Color(0xFF2D211C),
        rightColor: const Color(0xFF1A120F),
      );
      // Dark sunken soul face pixels on Soil block
      canvas.drawRect(Rect.fromLTWH(anchor.dx - u * 2.2, anchor.dy - soilH * 0.65, u * 0.8, u * 0.8), Paint()..color = const Color(0xFF0E0907));
      canvas.drawRect(Rect.fromLTWH(anchor.dx - u * 0.8, anchor.dy - soilH * 0.55, u * 0.7, u * 0.8), Paint()..color = const Color(0xFF0E0907));

      final flameBaseY = anchor.dy - soilH - soilDepth * 0.75;
      final sway = flicker * 0.40 * u;
      canvas.drawRect(Rect.fromLTWH(anchor.dx - u * 2.8 + sway * 0.4, flameBaseY - u * 3.2, u * 1.9, u * 3.4), Paint()..color = glow);
      canvas.drawRect(Rect.fromLTWH(anchor.dx - u * 2.2 + sway * 0.7, flameBaseY - u * 4.4, u * 1.0, u * 1.3), Paint()..color = warmInner);
      canvas.drawRect(Rect.fromLTWH(anchor.dx - u * 1.1 - sway * 0.3, flameBaseY - u * 5.2, u * 2.4, u * 5.4), Paint()..color = glow);
      canvas.drawRect(Rect.fromLTWH(anchor.dx - u * 0.65 + sway * 0.5, flameBaseY - u * 6.8, u * 1.35, u * 1.8), Paint()..color = brightCore);
      canvas.drawRect(Rect.fromLTWH(anchor.dx - u * 0.65, flameBaseY - u * 2.9, u * 1.3, u * 3.1), Paint()..color = brightCore);
      canvas.drawRect(Rect.fromLTWH(anchor.dx + u * 1.2 + sway * 0.5, flameBaseY - u * 2.9, u * 1.7, u * 3.0), Paint()..color = glow);
      canvas.drawRect(Rect.fromLTWH(anchor.dx + u * 1.5 - sway * 0.4, flameBaseY - u * 4.1, u * 0.9, u * 1.3), Paint()..color = warmInner);

      if (includeCompanionProps && syncMystic) {
        _drawIsoPrism(
          canvas,
          bottomCenter: Offset(anchor.dx + u * 8.2, anchor.dy),
          halfW: u * 2.6,
          depthY: u * 1.1,
          height: u * 4.2,
          topColor: Color.lerp(glow, Colors.white, 0.55)!,
          leftColor: glow,
          rightColor: const Color(0xFF0F766E),
        );
      }
      return Offset(anchor.dx, flameBaseY - u * 2.4);

    case 'candle':
      final specs = includeCompanionProps
          ? [
              (dx: -2.8 * u, hw: 1.05 * u, h: 4.0 * u, phase: 0.8),
              (dx: -0.1 * u, hw: 1.15 * u, h: 5.8 * u, phase: -0.6),
              (dx: 2.6 * u, hw: 1.0 * u, h: 3.2 * u, phase: 0.5),
            ]
          : [
              (dx: -1.7 * u, hw: 1.1 * u, h: 5.0 * u, phase: 0.5),
              (dx: 1.5 * u, hw: 1.0 * u, h: 3.6 * u, phase: -0.5),
            ];
      final waxLight = Color.lerp(const Color(0xFFF1F5F9), glow, 0.22)!;
      final waxShade = Color.lerp(const Color(0xFF94A3B8), glow, 0.14)!;
      double lightY = anchor.dy;
      for (final c in specs) {
        final cBase = Offset(anchor.dx + c.dx, anchor.dy);
        _drawIsoPrism(
          canvas,
          bottomCenter: cBase,
          halfW: c.hw,
          depthY: c.hw * 0.48,
          height: c.h,
          topColor: Color.lerp(waxLight, glow, 0.38)!,
          leftColor: waxLight,
          rightColor: waxShade,
        );
        final topY = anchor.dy - c.h - c.hw * 0.48;
        canvas.drawRect(Rect.fromLTWH(cBase.dx - u * 0.2, topY - u * 0.8, u * 0.4, u * 0.85), Paint()..color = const Color(0xFF1E293B));
        final fShift = flicker * c.phase * u * 0.22;
        canvas.drawRect(Rect.fromLTWH(cBase.dx - u * 0.7 + fShift, topY - u * 2.4, u * 1.4, u * 1.6), Paint()..color = glow);
        canvas.drawRect(Rect.fromLTWH(cBase.dx - u * 0.38 + fShift * 0.4, topY - u * 2.0, u * 0.76, u * 1.0), Paint()..color = brightCore);
        lightY = math.min(lightY, topY - u * 1.5);
      }
      return Offset(anchor.dx, lightY);

    case 'redstone':
      final rHalfW = u * 1.35;
      final rDepth = u * 0.65;
      final rWoodH = u * 5.8;
      _drawIsoPrism(
        canvas,
        bottomCenter: anchor,
        halfW: rHalfW,
        depthY: rDepth,
        height: rWoodH,
        leftColor: const Color(0xFF78350F),
        rightColor: const Color(0xFF451A03),
      );
      _drawIsoPrism(
        canvas,
        bottomCenter: Offset(anchor.dx, anchor.dy - rWoodH),
        halfW: rHalfW * 1.15,
        depthY: rDepth * 1.15,
        height: u * 2.5,
        topColor: brightCore,
        leftColor: glow,
        rightColor: Color.lerp(glow, const Color(0xFF450A0A), 0.32)!,
      );
      if (includeCompanionProps) {
        final lpPos = Offset(anchor.dx + u * 6.8, anchor.dy);
        _drawIsoPrism(
          canvas,
          bottomCenter: lpPos,
          halfW: u * 2.8,
          depthY: u * 1.3,
          height: u * 4.6,
          topColor: Color.lerp(glow, const Color(0xFF78350F), 0.35)!,
          leftColor: glow,
          rightColor: Color.lerp(glow, const Color(0xFF451A03), 0.45)!,
        );
      }
      return Offset(anchor.dx, anchor.dy - rWoodH - u * 1.2);

    case 'end_rod':
      final bPos = anchor;
      _drawIsoPrism(
        canvas,
        bottomCenter: bPos,
        halfW: u * 1.9,
        depthY: u * 0.9,
        height: u * 1.3,
        topColor: const Color(0xFFA855F7),
        leftColor: const Color(0xFF7E22CE),
        rightColor: const Color(0xFF4C1D95),
      );
      final rodH = u * (includeCompanionProps ? 8.4 : 7.0);
      _drawIsoPrism(
        canvas,
        bottomCenter: Offset(anchor.dx, anchor.dy - u * 1.3),
        halfW: u * 0.85,
        depthY: u * 0.42,
        height: rodH,
        topColor: Colors.white,
        leftColor: Colors.white,
        rightColor: Color.lerp(glow, Colors.white, 0.35)!,
      );
      canvas.drawRect(
        Rect.fromLTWH(anchor.dx - u * 2.0, anchor.dy - rodH + u * 0.8 - flicker * u * 0.4, u * 0.65, u * 0.65),
        Paint()..color = Colors.white.withValues(alpha: 0.85),
      );
      return Offset(anchor.dx, anchor.dy - u * 1.3 - rodH * 0.5);

    case 'copper':
    default:
      final cPos = anchor;
      _drawIsoPrism(
        canvas,
        bottomCenter: cPos,
        halfW: u * (includeCompanionProps ? 3.2 : 2.8),
        depthY: u * 1.45,
        height: u * 5.0,
        topColor: const Color(0xFF2DD4BF),
        leftColor: const Color(0xFF0F766E),
        rightColor: const Color(0xFF134E4A),
      );
      // Glowing diode core window centered on left & right copper faces
      canvas.drawRect(
        Rect.fromLTWH(anchor.dx - u * 1.9, anchor.dy - u * 3.8, u * 1.2, u * 1.5),
        Paint()..color = glow,
      );
      canvas.drawRect(
        Rect.fromLTWH(anchor.dx - u * 1.6, anchor.dy - u * 3.5, u * 0.6, u * 0.9),
        Paint()..color = brightCore,
      );
      canvas.drawRect(
        Rect.fromLTWH(anchor.dx + u * 0.7, anchor.dy - u * 3.8, u * 1.2, u * 1.5),
        Paint()..color = glow,
      );
      if (includeCompanionProps) {
        _drawIsoPrism(
          canvas,
          bottomCenter: Offset(anchor.dx - u * 5.6, anchor.dy),
          halfW: u * 0.8,
          depthY: u * 0.4,
          height: u * 4.5,
          leftColor: const Color(0xFF9A3412),
          rightColor: const Color(0xFF431407),
        );
        canvas.drawRect(
          Rect.fromLTWH(anchor.dx - u * 6.5, anchor.dy - u * 6.0, u * 1.8, u * 1.5),
          Paint()..color = glow,
        );
      }
      return Offset(anchor.dx, anchor.dy - u * 3.2);
  }
}

class VVSceneArtwork extends StatelessWidget {
  final VVSceneBoxType type;
  final Color color;

  const VVSceneArtwork({
    super.key,
    required this.type,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: CustomPaint(
        painter: _VVSceneArtworkPainter(type: type, color: color),
      ),
    );
  }
}

class _VVSceneArtworkPainter extends CustomPainter {
  final VVSceneBoxType type;
  final Color color;

  const _VVSceneArtworkPainter({
    required this.type,
    required this.color,
  });

  void _drawHills(Canvas canvas, double w, double h, double y, Color hillColor) {
    final p = Path()
      ..moveTo(0, y)
      ..lineTo(0, y - h * 0.08)
      ..lineTo(w * 0.22, y - h * 0.08)
      ..lineTo(w * 0.22, y - h * 0.15)
      ..lineTo(w * 0.45, y - h * 0.15)
      ..lineTo(w * 0.45, y - h * 0.06)
      ..lineTo(w * 0.72, y - h * 0.06)
      ..lineTo(w * 0.72, y - h * 0.13)
      ..lineTo(w, y - h * 0.13)
      ..lineTo(w, y)
      ..close();
    canvas.drawPath(p, Paint()..color = hillColor);
  }

  void _drawTimeScene(
    Canvas canvas,
    double w,
    double h, {
    required Color zenith,
    required Color horizon,
    required Color sunColor,
    required double sunYRatio,
    required bool isNight,
    required Color terrainTop,
    required Color waterColor,
  }) {
    final horY = h * 0.68;
    canvas.drawRect(
      Rect.fromLTWH(0, 0, w, horY),
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [zenith, horizon],
        ).createShader(Rect.fromLTWH(0, 0, w, horY)),
    );

    if (isNight) {
      final star = Paint()..color = Colors.white.withValues(alpha: 0.75);
      for (final o in const [
        Offset(0.18, 0.14),
        Offset(0.75, 0.18),
        Offset(0.32, 0.34),
        Offset(0.84, 0.40),
        Offset(0.60, 0.12),
      ]) {
        canvas.drawRect(Rect.fromLTWH(w * o.dx, horY * o.dy, 2, 2), star);
      }
    }

    final sunPos = Offset(w * 0.5, horY * sunYRatio);
    canvas.drawCircle(
      sunPos,
      w * 0.30,
      Paint()
        ..shader = RadialGradient(
          colors: [sunColor.withValues(alpha: 0.65), sunColor.withValues(alpha: 0)],
        ).createShader(Rect.fromCircle(center: sunPos, radius: w * 0.30)),
    );
    canvas.drawRect(
      Rect.fromCenter(center: sunPos, width: w * 0.22, height: w * 0.22),
      Paint()..color = isNight ? const Color(0xFFE2E8F0) : sunColor,
    );

    _drawHills(canvas, w, h, horY, terrainTop);
    canvas.drawRect(
      Rect.fromLTWH(0, horY, w, h - horY),
      Paint()..color = waterColor,
    );
    canvas.drawRect(
      Rect.fromLTWH(w * 0.34, horY + 4, w * 0.32, 2.5),
      Paint()..color = sunColor.withValues(alpha: 0.55),
    );
    canvas.drawRect(
      Rect.fromLTWH(w * 0.39, horY + 10, w * 0.22, 2),
      Paint()..color = sunColor.withValues(alpha: 0.35),
    );
  }

  void _drawDetailedSunlightCard(
    Canvas canvas,
    double w,
    double h,
    Color sunColor,
  ) {
    final horY = h * 0.60;
    // Crisp bright Minecraft sky fading softly into horizon haze
    canvas.drawRect(
      Rect.fromLTWH(0, 0, w, horY + 4),
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          stops: const [0.0, 0.65, 1.0],
          colors: [
            const Color(0xFF38BDF8),
            Color.lerp(const Color(0xFFBAE6FD), sunColor, 0.20)!,
            Color.lerp(const Color(0xFFE0F2FE), sunColor, 0.30)!,
          ],
        ).createShader(Rect.fromLTWH(0, 0, w, horY + 4)),
    );
    canvas.drawRect(
      Rect.fromLTWH(w * 0.62, horY * 0.18, w * 0.24, 3.0),
      Paint()..color = Colors.white.withValues(alpha: 0.78),
    );
    // Crisp square Minecraft Sun top-left (no ray lines)
    final sunPos = Offset(w * 0.20, horY * 0.26);
    canvas.drawCircle(
      sunPos,
      w * 0.24,
      Paint()
        ..shader = RadialGradient(
          colors: [sunColor.withValues(alpha: 0.55), sunColor.withValues(alpha: 0)],
        ).createShader(Rect.fromCircle(center: sunPos, radius: w * 0.24)),
    );
    canvas.drawRect(
      Rect.fromCenter(center: sunPos, width: w * 0.14, height: w * 0.14),
      Paint()..color = sunColor,
    );
    canvas.drawRect(
      Rect.fromCenter(center: sunPos, width: w * 0.07, height: w * 0.07),
      Paint()..color = Color.lerp(sunColor, Colors.white, 0.58)!,
    );

    // Wide grassy Minecraft meadow plain + lower grass/dirt edge
    final meadowTop = Color.lerp(const Color(0xFF84CC16), sunColor, 0.16)!;
    final meadowFore = Color.lerp(const Color(0xFF4D7C0F), sunColor, 0.10)!;
    canvas.drawPath(
      Path()
        ..moveTo(0, horY + 3)
        ..lineTo(w * 0.56, horY - 3)
        ..lineTo(w, horY + 2)
        ..lineTo(w, h)
        ..lineTo(0, h)
        ..close(),
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [meadowTop, meadowFore],
        ).createShader(Rect.fromLTWH(0, horY - 3, w, h - horY + 3)),
    );
    // Subtle cast shadow + centered detailed 3D perforated Oak Tree
    canvas.drawOval(
      Rect.fromCenter(center: Offset(w * 0.62, h * 0.78), width: w * 0.34, height: 6.0),
      Paint()..color = const Color(0xFF052E16).withValues(alpha: 0.45),
    );
    _drawMcUnitOakTree(
      canvas,
      cx: w * 0.54,
      groundY: h * 0.77,
      u: (w / 14.5).clamp(2.8, 5.0),
      sunOnRight: false,
      trunkLit: const Color(0xFF78350F),
      trunkDark: const Color(0xFF3F230D),
      leafLight: const Color(0xFF84CC16),
      leafMid: const Color(0xFF4D7C0F),
      leafDark: const Color(0xFF1A2E05),
    );
  }

  void _drawDetailedCaveCard(
    Canvas canvas,
    double w,
    double h,
    Color tintColor,
  ) {
    // Deep receding cave chamber
    canvas.drawRect(
      Rect.fromLTWH(0, 0, w, h),
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            const Color(0xFF04070D),
            Color.lerp(const Color(0xFF0E1726), tintColor, 0.32)!,
          ],
        ).createShader(Rect.fromLTWH(0, 0, w, h)),
    );
    canvas.drawCircle(
      Offset(w * 0.5, h * 0.52),
      w * 0.54,
      Paint()
        ..shader = RadialGradient(
          colors: [tintColor.withValues(alpha: 0.42), tintColor.withValues(alpha: 0)],
        ).createShader(Rect.fromCircle(center: Offset(w * 0.5, h * 0.52), radius: w * 0.54)),
    );

    final stoneTop = Color.lerp(const Color(0xFF475569), tintColor, 0.25)!;
    final stoneLit = Color.lerp(const Color(0xFF334155), tintColor, 0.22)!;
    final stoneDark = Color.lerp(const Color(0xFF111827), tintColor, 0.16)!;
    final bs = (w / 6.0).clamp(7.5, 13.0);

    // Side & ceiling stepped stone blocks + cave floor
    for (int col = 0; col < 7; col++) {
      _drawMcBlockTile(canvas, Rect.fromLTWH(col * bs, 0, bs + 0.4, bs), kind: 'stone', baseColor: stoneDark, seed: col);
      _drawMcBlockTile(canvas, Rect.fromLTWH(col * bs, h - bs, bs + 0.4, bs + 1), kind: 'deepslate', baseColor: stoneLit, seed: col + 3);
    }
    _drawMcBlockTile(canvas, Rect.fromLTWH(0, bs, bs, bs), kind: 'stone', baseColor: stoneLit, seed: 2);
    _drawMcBlockTile(canvas, Rect.fromLTWH(0, bs * 2, bs, bs), kind: 'ore', baseColor: stoneDark, accentColor: const Color(0xFF38BDF8), seed: 4);
    _drawMcBlockTile(canvas, Rect.fromLTWH(w - bs, bs, bs + 1, bs), kind: 'ore', baseColor: stoneLit, accentColor: const Color(0xFF34D399), seed: 5);
    _drawMcBlockTile(canvas, Rect.fromLTWH(w - bs, bs * 2, bs + 1, bs), kind: 'deepslate', baseColor: stoneDark, seed: 6);

    // Water puddle at base of central stepped stone pillar
    canvas.drawRect(
      Rect.fromCenter(center: Offset(w * 0.50, h - bs * 0.9), width: w * 0.46, height: 5.5),
      Paint()..color = Color.lerp(const Color(0xFF0F3D5E), tintColor, 0.45)!,
    );
    // Central stepped cave stone pillar
    _drawIsoPrism(
      canvas,
      bottomCenter: Offset(w * 0.50, h - bs * 0.72),
      halfW: w * 0.09,
      depthY: 3.5,
      height: h - bs * 1.4,
      topColor: stoneTop,
      leftColor: stoneLit,
      rightColor: stoneDark,
    );
    // Hanging lush cave foliage & vines around ceiling & pillar
    final moss = Color.lerp(const Color(0xFF4D7C0F), tintColor, 0.14)!;
    final mossDark = Color.lerp(const Color(0xFF1A2E05), tintColor, 0.12)!;
    for (final v in [
      Rect.fromLTWH(w * 0.18, bs * 0.85, bs * 0.9, bs * 0.8),
      Rect.fromLTWH(w * 0.42, bs * 0.95, bs * 1.1, bs * 0.75),
      Rect.fromLTWH(w * 0.70, bs * 0.85, bs * 0.9, bs * 0.85),
    ]) {
      canvas.drawRect(v, Paint()..color = moss);
      canvas.drawRect(Rect.fromLTWH(v.left + 2, v.bottom, 2.5, 5), Paint()..color = mossDark);
      canvas.drawRect(Rect.fromLTWH(v.right - 4, v.bottom, 2.0, 7), Paint()..color = moss);
    }
  }

  void _drawDetailedBlockLightsCard(
    Canvas canvas,
    double w,
    double h,
    Color glowColor,
  ) {
    _drawVVStoneBricks(
      canvas,
      Rect.fromLTWH(0, 0, w, h),
      brickW: w * 0.28,
      brickH: h * 0.22,
      baseColor: const Color(0xFF141B26),
      mortarColor: const Color(0xFF090D14),
      lightTint: glowColor,
      lightPos: Offset(w * 0.36, h * 0.48),
      lightRadius: w * 0.72,
      lightStrength: 0.75,
    );
    // Ceiling Oak Log beam for hanging lantern
    final beamH = (h * 0.16).clamp(7.0, 12.0);
    final plankS = (w / 5.0).clamp(8.0, 14.0);
    for (int col = 0; col < 6; col++) {
      _drawMcBlockTile(
        canvas,
        Rect.fromLTWH(col * plankS, 0, plankS + 0.5, beamH),
        kind: 'log',
        baseColor: const Color(0xFF4A2E1B),
        seed: col + 1,
      );
    }
    // Floor Oak Wood Planks
    final floorY = h * 0.80;
    for (int col = 0; col < 6; col++) {
      _drawMcBlockTile(
        canvas,
        Rect.fromLTWH(col * plankS, floorY, plankS + 0.5, h - floorY + 1),
        kind: 'plank',
        baseColor: const Color(0xFF5C3A21),
        seed: col,
      );
    }
    final c = Offset(w * 0.36, h * 0.48);
    canvas.drawCircle(
      c,
      w * 0.56,
      Paint()
        ..shader = RadialGradient(
          colors: [glowColor.withValues(alpha: 0.62), glowColor.withValues(alpha: 0)],
        ).createShader(Rect.fromCircle(center: c, radius: w * 0.56)),
    );
    final u = (math.min(w, h) / 22.0).clamp(1.6, 3.4);
    _drawVoxelBlockLightItem(
      canvas,
      'lantern',
      Offset(w * 0.34, beamH),
      u * 0.90,
      glowColor,
      hangLength: h * 0.16,
    );
    _drawVoxelBlockLightItem(
      canvas,
      'torch',
      Offset(w * 0.74, floorY),
      u * 0.92,
      const Color(0xFFFBBF24),
    );
  }

  void _drawBlockLightCard(
    Canvas canvas,
    double w,
    double h,
    Color glowColor, {
    required String kind,
  }) {
    _drawVVStoneBricks(
      canvas,
      Rect.fromLTWH(0, 0, w, h),
      brickW: math.max(8.0, w * 0.28),
      brickH: math.max(6.0, h * 0.22),
      baseColor: const Color(0xFF131924),
      mortarColor: const Color(0xFF080C12),
    );

    final glowCenter = kind == 'lantern'
        ? Offset(w * 0.5, h * 0.52)
        : Offset(w * 0.5, h * 0.44);
    canvas.drawCircle(
      glowCenter,
      w * 0.58,
      Paint()
        ..shader = RadialGradient(
          colors: [glowColor.withValues(alpha: 0.62), glowColor.withValues(alpha: 0)],
        ).createShader(Rect.fromCircle(center: glowCenter, radius: w * 0.58)),
    );

    final u = (math.min(w, h) / 15.5).clamp(1.7, 3.6);
    if (kind == 'lantern') {
      final beamH = (h * 0.18).clamp(7.0, 12.0);
      final plankS = (w / 4.0).clamp(8.0, 16.0);
      for (int col = 0; col < 5; col++) {
        _drawMcBlockTile(
          canvas,
          Rect.fromLTWH(col * plankS, 0, plankS + 0.5, beamH),
          kind: 'log',
          baseColor: const Color(0xFF4A2E1B),
          seed: col + 2,
        );
      }
      _drawVoxelBlockLightItem(
        canvas,
        'lantern',
        Offset(w * 0.5, beamH),
        u * 0.92,
        glowColor,
        hangLength: h * 0.16,
      );
    } else {
      final floorY = h * 0.84;
      canvas.drawRect(
        Rect.fromLTWH(0, floorY, w, h - floorY),
        Paint()..color = const Color(0xFF1E293B),
      );
      _drawVoxelBlockLightItem(
        canvas,
        kind,
        Offset(w * 0.5, floorY),
        u,
        glowColor,
      );
    }
  }

  void _drawWaterBiome(
    Canvas canvas,
    double w,
    double h, {
    required Color sky,
    required Color topWater,
    required Color deepWater,
    required Color accentFoam,
    bool murky = false,
  }) {
    final waterTop = h * 0.32;
    canvas.drawRect(Rect.fromLTWH(0, 0, w, waterTop), Paint()..color = sky);
    canvas.drawRect(
      Rect.fromLTWH(0, waterTop, w, h - waterTop),
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [topWater, deepWater],
        ).createShader(Rect.fromLTWH(0, waterTop, w, h - waterTop)),
    );
    // Crisp voxel ripples
    final foam = Paint()..color = accentFoam.withValues(alpha: murky ? 0.35 : 0.72);
    canvas.drawRect(Rect.fromLTWH(w * 0.12, waterTop + 6, w * 0.44, 3), foam);
    canvas.drawRect(Rect.fromLTWH(w * 0.40, waterTop + 18, w * 0.48, 3), foam);
    canvas.drawRect(Rect.fromLTWH(w * 0.18, waterTop + 32, w * 0.56, 2.5), foam);
    // Seabed caustic streaks if clear
    if (!murky) {
      final caustic = Paint()..color = Colors.white.withValues(alpha: 0.24);
      canvas.drawRect(Rect.fromLTWH(w * 0.22, h * 0.76, w * 0.24, 2), caustic);
      canvas.drawRect(Rect.fromLTWH(w * 0.56, h * 0.84, w * 0.22, 2), caustic);
    }
  }

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    canvas.save();
    canvas.clipRect(Rect.fromLTWH(0, 0, w, h));

    switch (type) {
      case VVSceneBoxType.morning:
        _drawDetailedMorningCard(canvas, w, h);
        break;
      case VVSceneBoxType.noon:
        _drawDetailedNoonCard(canvas, w, h);
        break;
      case VVSceneBoxType.evening:
        _drawDetailedEveningCard(canvas, w, h);
        break;
      case VVSceneBoxType.night:
        _drawDetailedNightCard(canvas, w, h);
        break;
      case VVSceneBoxType.sunlight:
        _drawDetailedSunlightCard(canvas, w, h, color);
        break;
      case VVSceneBoxType.cave:
        _drawDetailedCaveCard(canvas, w, h, color);
        break;
      case VVSceneBoxType.blockLights:
        _drawDetailedBlockLightsCard(canvas, w, h, color);
        break;
      case VVSceneBoxType.torch:
        _drawBlockLightCard(canvas, w, h, color, kind: 'torch');
        break;
      case VVSceneBoxType.lantern:
        _drawBlockLightCard(canvas, w, h, color, kind: 'lantern');
        break;
      case VVSceneBoxType.soulFire:
        _drawBlockLightCard(canvas, w, h, color, kind: 'soul');
        break;
      case VVSceneBoxType.candle:
        _drawBlockLightCard(canvas, w, h, color, kind: 'candle');
        break;
      case VVSceneBoxType.redstone:
        _drawBlockLightCard(canvas, w, h, color, kind: 'redstone');
        break;
      case VVSceneBoxType.endRod:
        _drawBlockLightCard(canvas, w, h, color, kind: 'end_rod');
        break;
      case VVSceneBoxType.copper:
        _drawBlockLightCard(canvas, w, h, color, kind: 'copper');
        break;
      case VVSceneBoxType.airFog:
        // Mini canyon vista with tiered spruce and valley mist (Image 1 style)
        canvas.drawRect(
          Rect.fromLTWH(0, 0, w, h),
          Paint()
            ..shader = LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color.lerp(const Color(0xFF1E3A5F), color, 0.5)!, color],
            ).createShader(Rect.fromLTWH(0, 0, w, h)),
        );
        _drawHills(canvas, w, h, h * 0.68, Color.lerp(const Color(0xFF1E293B), color, 0.55)!);
        // Canyon gorge mist pool
        canvas.drawRect(
          Rect.fromLTWH(0, h * 0.56, w, h * 0.44),
          Paint()..color = color.withValues(alpha: 0.65),
        );
        // Stepped foreground cliff & spruce tree
        final cliffP = Path()
          ..moveTo(0, h * 0.68)
          ..lineTo(w * 0.42, h * 0.68)
          ..lineTo(w * 0.54, h * 0.82)
          ..lineTo(w * 0.54, h)
          ..lineTo(0, h)
          ..close();
        canvas.drawPath(cliffP, Paint()..color = const Color(0xFF573926));
        canvas.drawRect(Rect.fromLTWH(0, h * 0.68, w * 0.42, 3.0), Paint()..color = const Color(0xFF4D7C0F));
        _drawMcSpruceTree(
          canvas,
          cx: w * 0.22,
          groundY: h * 0.68,
          u: 2.2,
          trunkColor: const Color(0xFF451A03),
          needleLight: const Color(0xFF16A34A),
          needleMid: const Color(0xFF15803D),
          needleDark: const Color(0xFF14532D),
        );
        break;
      case VVSceneBoxType.weatherFog:
        // Mini storm hillside with rain streaks
        canvas.drawRect(
          Rect.fromLTWH(0, 0, w, h),
          Paint()
            ..shader = LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [const Color(0xFF0F172A), color],
            ).createShader(Rect.fromLTWH(0, 0, w, h)),
        );
        _drawHills(canvas, w, h, h * 0.74, const Color(0xFF1E293B));
        _drawMcSpruceTree(
          canvas,
          cx: w * 0.72,
          groundY: h * 0.74,
          u: 2.1,
          trunkColor: const Color(0xFF291D14),
          needleLight: const Color(0xFF16A34A),
          needleMid: const Color(0xFF15803D),
          needleDark: const Color(0xFF14532D),
          wind: -2.0,
        );
        final rain = Paint()
          ..color = const Color(0xFFBAE6FD).withValues(alpha: 0.65)
          ..strokeWidth = 1.4;
        for (var i = 0; i < 8; i++) {
          final rx = w * (0.10 + i * 0.12);
          final ry = h * (0.12 + (i % 3) * 0.18);
          canvas.drawLine(Offset(rx, ry), Offset(rx - 4, ry + 12), rain);
        }
        break;
      case VVSceneBoxType.underwaterFog:
        // Mini seabed with kelp & seagrass in deep water (Image 2 style)
        final deepNavy = Color.lerp(color, const Color(0xFF020919), 0.65)!;
        canvas.drawRect(
          Rect.fromLTWH(0, 0, w, h),
          Paint()
            ..shader = LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color.lerp(color, const Color(0xFF38BDF8), 0.28)!, color, deepNavy],
            ).createShader(Rect.fromLTWH(0, 0, w, h)),
        );
        // Stepped seabed gravel blocks
        canvas.drawRect(Rect.fromLTWH(0, h * 0.74, w, h * 0.26), Paint()..color = const Color(0xFF334155));
        canvas.drawRect(Rect.fromLTWH(0, h * 0.74, w, 2.0), Paint()..color = const Color(0xFF64748B));
        // Mini kelp on left
        _drawMcKelpStalk(
          canvas,
          x: w * 0.18,
          baseY: h * 0.74,
          height: h * 0.50,
          u: 2.0,
          kelpColor: const Color(0xFF059669),
          kelpDark: const Color(0xFF047857),
        );
        // Mini seagrass
        _drawMcSeagrass(
          canvas,
          x: w * 0.62,
          baseY: h * 0.74,
          u: 2.2,
          grassColor: const Color(0xFF22C55E),
          grassDark: const Color(0xFF16A34A),
          isTall: true,
        );
        break;
      case VVSceneBoxType.waterTropical:
        _drawWaterBiome(
          canvas,
          w,
          h,
          sky: const Color(0xFF38BDF8),
          topWater: const Color(0xFF22D3EE),
          deepWater: const Color(0xFF0284C7),
          accentFoam: const Color(0xFFE0F2FE),
        );
        break;
      case VVSceneBoxType.waterOcean:
        _drawWaterBiome(
          canvas,
          w,
          h,
          sky: const Color(0xFF0284C7),
          topWater: const Color(0xFF0EA5E9),
          deepWater: const Color(0xFF1E3A8A),
          accentFoam: const Color(0xFFBAE6FD),
        );
        break;
      case VVSceneBoxType.waterDeepOcean:
        _drawWaterBiome(
          canvas,
          w,
          h,
          sky: const Color(0xFF0F172A),
          topWater: const Color(0xFF1E40AF),
          deepWater: const Color(0xFF090D29),
          accentFoam: const Color(0xFF60A5FA),
        );
        break;
      case VVSceneBoxType.waterRiver:
        _drawWaterBiome(
          canvas,
          w,
          h,
          sky: const Color(0xFF7DD3FC),
          topWater: const Color(0xFF38BDF8),
          deepWater: const Color(0xFF0F766E),
          accentFoam: const Color(0xFFCCFBF1),
        );
        break;
      case VVSceneBoxType.waterSwamp:
        _drawWaterBiome(
          canvas,
          w,
          h,
          sky: const Color(0xFF4D7C0F),
          topWater: const Color(0xFF3F6212),
          deepWater: const Color(0xFF1A2E05),
          accentFoam: const Color(0xFFA3E635),
          murky: true,
        );
        break;
      case VVSceneBoxType.moodDynamic:
        _drawTimeScene(
          canvas,
          w,
          h,
          zenith: const Color(0xFF0EA5E9),
          horizon: const Color(0xFFBAE6FD),
          sunColor: const Color(0xFFFDE047),
          sunYRatio: 0.34,
          isNight: false,
          terrainTop: const Color(0xFF16A34A),
          waterColor: const Color(0xFF0284C7),
        );
        break;
      case VVSceneBoxType.moodVibrant:
        _drawTimeScene(
          canvas,
          w,
          h,
          zenith: const Color(0xFF7C3AED),
          horizon: const Color(0xFFF43F5E),
          sunColor: const Color(0xFFFBBF24),
          sunYRatio: 0.65,
          isNight: false,
          terrainTop: const Color(0xFF15803D),
          waterColor: const Color(0xFF06B6D4),
        );
        break;
      case VVSceneBoxType.moodSavanna:
        _drawTimeScene(
          canvas,
          w,
          h,
          zenith: const Color(0xFFD97706),
          horizon: const Color(0xFFFDE68A),
          sunColor: const Color(0xFFFEF08A),
          sunYRatio: 0.56,
          isNight: false,
          terrainTop: const Color(0xFFA16207),
          waterColor: const Color(0xFF78350F),
        );
        break;
      case VVSceneBoxType.moodFrost:
        _drawTimeScene(
          canvas,
          w,
          h,
          zenith: const Color(0xFF1E3A8A),
          horizon: const Color(0xFFE0F2FE),
          sunColor: const Color(0xFFE0F2FE),
          sunYRatio: 0.36,
          isNight: false,
          terrainTop: const Color(0xFF64748B),
          waterColor: const Color(0xFF0369A1),
        );
        break;
      case VVSceneBoxType.moodMoody:
        _drawTimeScene(
          canvas,
          w,
          h,
          zenith: const Color(0xFF0F172A),
          horizon: const Color(0xFF475569),
          sunColor: const Color(0xFF94A3B8),
          sunYRatio: 0.62,
          isNight: true,
          terrainTop: const Color(0xFF1E293B),
          waterColor: const Color(0xFF0F172A),
        );
        break;
    }

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _VVSceneArtworkPainter oldDelegate) =>
      oldDelegate.type != type || oldDelegate.color != color;

  void _drawCardCloud(
    Canvas canvas,
    double w,
    double cx,
    double cy,
    double cw,
    double ch,
    Color topColor,
    Color midColor,
    Color rimColor,
  ) {
    final wrappedX = ((cx % (w + cw + 14)) - cw * 0.55);
    canvas.drawRect(
      Rect.fromLTWH(wrappedX, cy, cw, ch),
      Paint()..color = midColor.withValues(alpha: 0.90),
    );
    canvas.drawRect(
      Rect.fromLTWH(wrappedX + cw * 0.16, cy - ch * 0.45, cw * 0.56, ch * 0.52),
      Paint()..color = topColor.withValues(alpha: 0.92),
    );
    canvas.drawRect(
      Rect.fromLTWH(wrappedX + cw * 0.28, cy - ch * 0.72, cw * 0.30, ch * 0.32),
      Paint()..color = topColor.withValues(alpha: 0.95),
    );
    canvas.drawRect(
      Rect.fromLTWH(wrappedX, cy + ch - 2.0, cw, 2.0),
      Paint()..color = rimColor.withValues(alpha: 0.94),
    );
  }

  /// Stepped Minecraft voxel mountain range framed around the open water horizon.
  void _drawCardVoxelMountains(
    Canvas canvas,
    double w,
    double horY, {
    required Color litColor,
    required Color darkColor,
    Color? snowColor,
    required double sunXRatio,
  }) {
    final sunRight = sunXRatio >= 0.5;
    final dark = Paint()..color = darkColor;
    final lit = Paint()..color = litColor;
    // Keep outer valleys low so rising Left / setting Right sun sits cleanly half-visible above horizon
    final peaks = [
      (x: 0.36, width: 0.16, h: 13.0),
      (x: 0.50, width: 0.16, h: 16.0),
    ];
    for (final pk in peaks) {
      final px = w * pk.x;
      final pw = w * pk.width;
      canvas.drawRect(Rect.fromLTWH(px, horY - pk.h * 0.58, pw, pk.h * 0.58), dark);
      canvas.drawRect(
        Rect.fromLTWH(px + pw * 0.22, horY - pk.h, pw * 0.56, pk.h * 0.45),
        dark,
      );
      if (sunRight) {
        canvas.drawRect(
          Rect.fromLTWH(px + pw * 0.52, horY - pk.h, pw * 0.26, pk.h * 0.45),
          lit,
        );
        canvas.drawRect(
          Rect.fromLTWH(px + pw * 0.65, horY - pk.h * 0.58, pw * 0.35, pk.h * 0.58),
          lit,
        );
      } else {
        canvas.drawRect(
          Rect.fromLTWH(px + pw * 0.22, horY - pk.h, pw * 0.26, pk.h * 0.45),
          lit,
        );
        canvas.drawRect(
          Rect.fromLTWH(px, horY - pk.h * 0.58, pw * 0.35, pk.h * 0.58),
          lit,
        );
      }
      if (snowColor != null) {
        canvas.drawRect(
          Rect.fromLTWH(px + pw * 0.22, horY - pk.h, pw * 0.56, 2.5),
          Paint()..color = snowColor,
        );
      }
    }
  }

  /// Stepped Minecraft grass + dirt shoreline + unit-grid Oak & Spruce trees for cards.
  void _drawCardMinecraftShore(
    Canvas canvas,
    double w,
    double horY, {
    required Color grassTop,
    required Color grassDark,
    required Color dirtColor,
    required Color trunkColor,
    required Color leafLight,
    required Color leafMid,
    required Color leafDark,
    required bool sunOnRight,
  }) {
    // Left stepped Minecraft grass bank (leaves 0.22..0.78 open horizon clear!)
    canvas.drawRect(Rect.fromLTWH(0, horY - 7, w * 0.16, 7), Paint()..color = dirtColor);
    canvas.drawRect(Rect.fromLTWH(0, horY - 7, w * 0.16, 2.5), Paint()..color = grassTop);
    canvas.drawRect(Rect.fromLTWH(w * 0.16, horY - 3, w * 0.05, 3), Paint()..color = const Color(0xFFD6C78D).withValues(alpha: 0.72));

    // Right stepped Minecraft bank
    canvas.drawRect(Rect.fromLTWH(w * 0.84, horY - 7, w * 0.16, 7), Paint()..color = dirtColor);
    canvas.drawRect(Rect.fromLTWH(w * 0.84, horY - 7, w * 0.16, 2.5), Paint()..color = grassDark);
    canvas.drawRect(Rect.fromLTWH(w * 0.79, horY - 3, w * 0.05, 3), Paint()..color = const Color(0xFFD6C78D).withValues(alpha: 0.72));

    // Clean unit-grid Minecraft Oak tree on outer left bank
    const u = 2.6;
    final tx = w * 0.08;
    final groundY = horY - 7;
    canvas.drawRect(Rect.fromLTWH(tx - u * 0.5, groundY - u * 3.0, u, u * 3.0), Paint()..color = trunkColor);
    canvas.drawRect(Rect.fromLTWH(tx - u * 2.5, groundY - u * 5.0, u * 5.0, u * 2.0), Paint()..color = leafMid);
    canvas.drawRect(Rect.fromLTWH(tx - u * 1.5, groundY - u * 6.0, u * 3.0, u * 1.0), Paint()..color = leafMid);
    canvas.drawRect(
      Rect.fromLTWH(sunOnRight ? tx + u * 0.5 : tx - u * 2.5, groundY - u * 5.0, u * 1.8, u * 1.6),
      Paint()..color = leafLight,
    );
    canvas.drawRect(
      Rect.fromLTWH(sunOnRight ? tx - u * 2.5 : tx + u * 1.0, groundY - u * 4.2, u * 1.4, u * 1.2),
      Paint()..color = leafDark,
    );

    // Iconic stepped 3-tier Minecraft Spruce on outer right bank
    final sx = w * 0.92;
    canvas.drawRect(Rect.fromLTWH(sx - u * 0.45, groundY - u * 5.2, u * 0.9, u * 5.2), Paint()..color = trunkColor);
    canvas.drawRect(Rect.fromLTWH(sx - u * 2.5, groundY - u * 2.2, u * 5.0, u * 1.1), Paint()..color = leafDark);
    canvas.drawRect(Rect.fromLTWH(sx - u * 1.8, groundY - u * 3.8, u * 3.6, u * 1.1), Paint()..color = leafMid);
    canvas.drawRect(Rect.fromLTWH(sx - u * 1.0, groundY - u * 5.2, u * 2.0, u * 1.0), Paint()..color = leafMid);
    canvas.drawRect(Rect.fromLTWH(sx - u * 0.45, groundY - u * 6.1, u * 0.9, u * 1.0), Paint()..color = leafLight);
  }

  /// Detailed tiled Minecraft card water with sun/moon specular shimmer.
  void _drawCardMinecraftWater(
    Canvas canvas,
    double w,
    double h,
    double horY,
    double sunX, {
    required Color topWater,
    required Color deepWater,
    required Color glintColor,
    required Color rippleColor,
  }) {
    canvas.drawRect(
      Rect.fromLTWH(0, horY, w, h - horY),
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [topWater, deepWater],
        ).createShader(Rect.fromLTWH(0, horY, w, h - horY)),
    );
    final rip = Paint()..color = rippleColor.withValues(alpha: 0.24);
    for (int row = 0; row < 4; row++) {
      final wy = horY + 3 + row * 5.0;
      if (wy + 2 > h) break;
      final wx = (w * (0.16 + row * 0.20)) % (w - 14);
      canvas.drawRect(Rect.fromLTWH(wx, wy, 12, 1.5), rip);
    }
    final glint = Paint()..color = glintColor.withValues(alpha: 0.72);
    for (int i = 0; i < 5; i++) {
      final sway = math.sin(i * 1.3) * 1.8;
      canvas.drawRect(
        Rect.fromCenter(
          center: Offset(sunX + sway, horY + 3 + i * 4.4),
          width: (w * 0.22 - i * 3.0).clamp(4.0, w * 0.28),
          height: 1.8,
        ),
        glint,
      );
    }
  }

  void _drawDetailedMorningCard(Canvas canvas, double w, double h) {
    final horY = h * 0.65;
    // Orange-purple Minecraft sunrise gradient (no harsh red)
    final zenith = Color.lerp(const Color(0xFF1E1B4B), color, 0.16)!;
    final midPurple = Color.lerp(const Color(0xFF7C3AED), color, 0.38)!;
    final warmOrange = Color.lerp(const Color(0xFFFB923C), color, 0.50)!;
    canvas.drawRect(
      Rect.fromLTWH(0, 0, w, horY),
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          stops: const [0.0, 0.42, 0.78, 1.0],
          colors: [zenith, midPurple, warmOrange, color],
        ).createShader(Rect.fromLTWH(0, 0, w, horY)),
    );

    // Rising Sun on LEFT side, HALF-VISIBLE over the horizon
    final sunPos = Offset(w * 0.28, horY - 1.5);
    canvas.drawCircle(
      sunPos,
      w * 0.34,
      Paint()
        ..shader = RadialGradient(
          colors: [
            const Color(0xFFFDE68A).withValues(alpha: 0.72),
            const Color(0xFFFB923C).withValues(alpha: 0.26),
            Colors.transparent,
          ],
        ).createShader(Rect.fromCircle(center: sunPos, radius: w * 0.34)),
    );

    _drawCardCloud(
      canvas,
      w,
      w * 0.54,
      horY * 0.26,
      w * 0.34,
      5.5,
      const Color(0xFFFFEDD5),
      const Color(0xFFFED7AA),
      const Color(0xFFFB923C),
    );
    _drawCardCloud(
      canvas,
      w,
      w * 0.18,
      horY * 0.40,
      w * 0.26,
      4.5,
      const Color(0xFFFEF3C7),
      const Color(0xFFE9D5FF),
      const Color(0xFFFDBA74),
    );

    // Half-visible warm amber-gold Sun square (bottom half clipped below horY by water/shore)
    canvas.drawRect(
      Rect.fromCenter(center: sunPos, width: w * 0.17, height: w * 0.17),
      Paint()..color = const Color(0xFFFDBA74),
    );
    canvas.drawRect(
      Rect.fromCenter(center: sunPos, width: w * 0.10, height: w * 0.10),
      Paint()..color = const Color(0xFFFEF3C7),
    );

    _drawCardVoxelMountains(
      canvas,
      w,
      horY,
      litColor: const Color(0xFF64748B),
      darkColor: const Color(0xFF334155),
      snowColor: const Color(0xFFFDE68A).withValues(alpha: 0.85),
      sunXRatio: 0.28,
    );
    _drawCardMinecraftShore(
      canvas,
      w,
      horY,
      grassTop: const Color(0xFF22C55E),
      grassDark: const Color(0xFF15803D),
      dirtColor: const Color(0xFF78350F),
      trunkColor: const Color(0xFF6B4226),
      leafLight: const Color(0xFF4ADE80),
      leafMid: const Color(0xFF16A34A),
      leafDark: const Color(0xFF14532D),
      sunOnRight: false,
    );
    _drawCardMinecraftWater(
      canvas,
      w,
      h,
      horY,
      sunPos.dx,
      topWater: Color.lerp(color, const Color(0xFF0E7490), 0.44)!,
      deepWater: const Color(0xFF0F172A),
      glintColor: const Color(0xFFFDE68A),
      rippleColor: Colors.white,
    );
  }

  void _drawDetailedNoonCard(Canvas canvas, double w, double h) {
    final horY = h * 0.65;
    final zenith = Color.lerp(const Color(0xFF0284C7), color, 0.18)!;
    final midSky = Color.lerp(const Color(0xFF0EA5E9), color, 0.38)!;
    canvas.drawRect(
      Rect.fromLTWH(0, 0, w, horY),
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          stops: const [0.0, 0.52, 1.0],
          colors: [zenith, midSky, color],
        ).createShader(Rect.fromLTWH(0, 0, w, horY)),
    );

    // High TOP Center Sun (clean glowing square, no 8 cross lines)
    final sunPos = Offset(w * 0.50, horY * 0.25);
    canvas.drawCircle(
      sunPos,
      w * 0.32,
      Paint()
        ..shader = RadialGradient(
          colors: [
            Colors.white.withValues(alpha: 0.84),
            const Color(0xFFFEF08A).withValues(alpha: 0.32),
            Colors.transparent,
          ],
        ).createShader(Rect.fromCircle(center: sunPos, radius: w * 0.32)),
    );
    canvas.drawRect(
      Rect.fromCenter(center: sunPos, width: w * 0.17, height: w * 0.17),
      Paint()..color = const Color(0xFFFEF08A),
    );
    canvas.drawRect(
      Rect.fromCenter(center: sunPos, width: w * 0.10, height: w * 0.10),
      Paint()..color = Colors.white,
    );

    _drawCardCloud(
      canvas,
      w,
      w * 0.14,
      horY * 0.46,
      w * 0.34,
      6.0,
      Colors.white,
      const Color(0xFFE0F2FE),
      const Color(0xFF7DD3FC),
    );
    _drawCardCloud(
      canvas,
      w,
      w * 0.68,
      horY * 0.30,
      w * 0.26,
      5.0,
      Colors.white,
      const Color(0xFFE0F2FE),
      const Color(0xFF93C5FD),
    );

    _drawCardVoxelMountains(
      canvas,
      w,
      horY,
      litColor: const Color(0xFF64748B),
      darkColor: const Color(0xFF334155),
      snowColor: const Color(0xFFF8FAFC),
      sunXRatio: 0.50,
    );
    _drawCardMinecraftShore(
      canvas,
      w,
      horY,
      grassTop: const Color(0xFF4ADE80),
      grassDark: const Color(0xFF16A34A),
      dirtColor: const Color(0xFF78350F),
      trunkColor: const Color(0xFF6B4226),
      leafLight: const Color(0xFF4ADE80),
      leafMid: const Color(0xFF22C55E),
      leafDark: const Color(0xFF15803D),
      sunOnRight: false,
    );
    _drawCardMinecraftWater(
      canvas,
      w,
      h,
      horY,
      sunPos.dx,
      topWater: Color.lerp(color, const Color(0xFF06B6D4), 0.56)!,
      deepWater: const Color(0xFF0369A1),
      glintColor: Colors.white,
      rippleColor: const Color(0xFFA5F3FC),
    );
  }

  void _drawDetailedEveningCard(Canvas canvas, double w, double h) {
    final horY = h * 0.65;
    // Orange-purple Minecraft sunset gradient (no harsh red)
    final zenith = Color.lerp(const Color(0xFF1E1B4B), const Color(0xFF4C1D95), 0.45)!;
    final midPurple = Color.lerp(const Color(0xFF7E22CE), color, 0.35)!;
    final warmOrange = Color.lerp(const Color(0xFFF97316), color, 0.52)!;
    canvas.drawRect(
      Rect.fromLTWH(0, 0, w, horY),
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          stops: const [0.0, 0.42, 0.76, 1.0],
          colors: [zenith, midPurple, warmOrange, color],
        ).createShader(Rect.fromLTWH(0, 0, w, horY)),
    );

    final star = Paint()..color = Colors.white.withValues(alpha: 0.62);
    for (final o in const [
      Offset(0.14, 0.14),
      Offset(0.28, 0.20),
      Offset(0.42, 0.10),
    ]) {
      canvas.drawRect(Rect.fromLTWH(w * o.dx, horY * o.dy, 2, 2), star);
    }

    // Setting Sun on RIGHT side, HALF-VISIBLE over the horizon
    final sunPos = Offset(w * 0.72, horY - 1.5);
    canvas.drawCircle(
      sunPos,
      w * 0.36,
      Paint()
        ..shader = RadialGradient(
          colors: [
            const Color(0xFFFDBA74).withValues(alpha: 0.78),
            const Color(0xFFF97316).withValues(alpha: 0.26),
            Colors.transparent,
          ],
        ).createShader(Rect.fromCircle(center: sunPos, radius: w * 0.36)),
    );

    _drawCardCloud(
      canvas,
      w,
      w * 0.22,
      horY * 0.28,
      w * 0.36,
      5.5,
      const Color(0xFF581C87),
      const Color(0xFF7E22CE),
      const Color(0xFFFB923C),
    );
    _drawCardCloud(
      canvas,
      w,
      w * 0.60,
      horY * 0.42,
      w * 0.26,
      4.5,
      const Color(0xFF4C1D95),
      const Color(0xFF9333EA),
      const Color(0xFFFDBA74),
    );

    // Warm orange-gold sunset sun square (not red)
    canvas.drawRect(
      Rect.fromCenter(center: sunPos, width: w * 0.17, height: w * 0.17),
      Paint()..color = const Color(0xFFFB923C),
    );
    canvas.drawRect(
      Rect.fromCenter(center: sunPos, width: w * 0.10, height: w * 0.10),
      Paint()..color = const Color(0xFFFEF3C7),
    );

    _drawCardVoxelMountains(
      canvas,
      w,
      horY,
      litColor: const Color(0xFF4C1D95),
      darkColor: const Color(0xFF1E1B4B),
      sunXRatio: 0.72,
    );
    _drawCardMinecraftShore(
      canvas,
      w,
      horY,
      grassTop: const Color(0xFF15803D),
      grassDark: const Color(0xFF14532D),
      dirtColor: const Color(0xFF451A03),
      trunkColor: const Color(0xFF451A03),
      leafLight: const Color(0xFF22C55E),
      leafMid: const Color(0xFF14532D),
      leafDark: const Color(0xFF064E3B),
      sunOnRight: true,
    );
    _drawCardMinecraftWater(
      canvas,
      w,
      h,
      horY,
      sunPos.dx,
      topWater: Color.lerp(color, const Color(0xFF312E81), 0.56)!,
      deepWater: const Color(0xFF0F172A),
      glintColor: const Color(0xFFFDBA74),
      rippleColor: const Color(0xFFFED7AA),
    );
  }

  void _drawDetailedNightCard(Canvas canvas, double w, double h) {
    final horY = h * 0.65;
    final deepMid = Color.lerp(const Color(0xFF09132E), color, 0.22)!;
    final horizonMix = Color.lerp(const Color(0xFF0F172A), color, 0.45)!;
    canvas.drawRect(
      Rect.fromLTWH(0, 0, w, horY),
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          stops: const [0.0, 0.48, 1.0],
          colors: [const Color(0xFF020617), deepMid, horizonMix],
        ).createShader(Rect.fromLTWH(0, 0, w, horY)),
    );

    // Subtle Milky Way star-cluster glow across left-center sky
    final nebula = Paint()..color = const Color(0xFF38BDF8).withValues(alpha: 0.08);
    for (int i = 0; i < 6; i++) {
      canvas.drawOval(
        Rect.fromCenter(
          center: Offset(w * (0.12 + i * 0.09), horY * (0.64 - i * 0.085)),
          width: 16,
          height: 8,
        ),
        nebula,
      );
    }

    const stars = [
      Offset(0.12, 0.14),
      Offset(0.22, 0.29),
      Offset(0.32, 0.11),
      Offset(0.42, 0.24),
      Offset(0.86, 0.16),
      Offset(0.92, 0.36),
      Offset(0.16, 0.46),
      Offset(0.50, 0.44),
      Offset(0.36, 0.36),
      Offset(0.82, 0.46),
    ];
    for (int i = 0; i < stars.length; i++) {
      final sz = i % 3 == 0 ? 2.2 : 1.5;
      canvas.drawRect(
        Rect.fromLTWH(w * stars[i].dx, horY * stars[i].dy, sz, sz),
        Paint()
          ..color = (i % 4 == 0 ? const Color(0xFFBAE6FD) : Colors.white)
              .withValues(alpha: i.isEven ? 0.88 : 0.56),
      );
    }

    // Crisp multi-toned Pixel Moon with sapphire-silver corona & subtle moonbow halo
    final moonPos = Offset(w * 0.65, horY * 0.32);
    canvas.drawCircle(
      moonPos,
      w * 0.38,
      Paint()
        ..shader = RadialGradient(
          colors: [
            const Color(0xFFF8FAFC).withValues(alpha: 0.54),
            const Color(0xFF93C5FD).withValues(alpha: 0.22),
            const Color(0xFF3B82F6).withValues(alpha: 0.08),
            Colors.transparent,
          ],
        ).createShader(Rect.fromCircle(center: moonPos, radius: w * 0.38)),
    );
    canvas.drawCircle(
      moonPos,
      w * 0.25,
      Paint()
        ..color = const Color(0xFFBAE6FD).withValues(alpha: 0.14)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.0,
    );

    final moonSize = w * 0.22;
    final mLeft = moonPos.dx - moonSize * 0.5;
    final mTop = moonPos.dy - moonSize * 0.5;
    final u = moonSize / 6.0;
    // Outer soft silver glow frame + bright lunar body
    canvas.drawRect(
      Rect.fromLTWH(mLeft, mTop, moonSize, moonSize),
      Paint()..color = const Color(0xFFE2E8F0),
    );
    canvas.drawRect(
      Rect.fromLTWH(mLeft, mTop, moonSize, u * 0.9),
      Paint()..color = const Color(0xFFF8FAFC),
    );
    canvas.drawRect(
      Rect.fromLTWH(mLeft, mTop, u * 0.9, moonSize),
      Paint()..color = const Color(0xFFF8FAFC),
    );
    // Lunar mare patches & shaded craters + crescent bottom-right depth
    final mare = Paint()..color = const Color(0xFF94A3B8);
    final deepCrater = Paint()..color = const Color(0xFF64748B).withValues(alpha: 0.72);
    canvas.drawRect(Rect.fromLTWH(mLeft + u * 1.1, mTop + u * 1.0, u * 1.6, u * 1.4), mare);
    canvas.drawRect(Rect.fromLTWH(mLeft + u * 3.4, mTop + u * 1.6, u * 1.5, u * 1.5), mare);
    canvas.drawRect(Rect.fromLTWH(mLeft + u * 1.8, mTop + u * 3.6, u * 1.8, u * 1.2), deepCrater);
    canvas.drawRect(Rect.fromLTWH(mLeft + u * 4.2, mTop + u * 3.8, u * 1.2, u * 1.2), deepCrater);
    canvas.drawRect(
      Rect.fromLTWH(mLeft + u * 4.9, mTop + u * 1.0, u * 1.1, moonSize - u),
      Paint()..color = const Color(0xFF64748B).withValues(alpha: 0.30),
    );

    // Subtle moonlit dark cloud passing below moon
    _drawCardCloud(
      canvas,
      w,
      w * 0.22,
      horY * 0.50,
      w * 0.30,
      4.5,
      const Color(0xFF334155),
      const Color(0xFF1E293B),
      const Color(0xFF93C5FD).withValues(alpha: 0.55),
    );

    _drawCardVoxelMountains(
      canvas,
      w,
      horY,
      litColor: const Color(0xFF334155),
      darkColor: const Color(0xFF0B1320),
      snowColor: const Color(0xFFCBD5E1).withValues(alpha: 0.50),
      sunXRatio: 0.65,
    );
    _drawCardMinecraftShore(
      canvas,
      w,
      horY,
      grassTop: const Color(0xFF065F46),
      grassDark: const Color(0xFF022C22),
      dirtColor: const Color(0xFF1C1917),
      trunkColor: const Color(0xFF292524),
      leafLight: const Color(0xFF047857),
      leafMid: const Color(0xFF064E3B),
      leafDark: const Color(0xFF022C22),
      sunOnRight: true,
    );
    _drawCardMinecraftWater(
      canvas,
      w,
      h,
      horY,
      moonPos.dx,
      topWater: Color.lerp(horizonMix, const Color(0xFF0F172A), 0.52)!,
      deepWater: const Color(0xFF020617),
      glintColor: const Color(0xFFF1F5F9),
      rippleColor: const Color(0xFF93C5FD),
    );
  }
}

// ═════════════════════════════════════════════════════════════════════════════
// 3. TAB-SPECIFIC LIVE PREVIEWS (One dedicated custom-drawn banner per tab)
// ═════════════════════════════════════════════════════════════════════════════

/// Parameter-reactive + optional continuous shader-motion animation driver
/// (automatically settles in 520ms under Widget tests so `pumpAndSettle` succeeds).
class _VVReactiveMotion extends StatefulWidget {
  final Object signal;
  final bool continuous;
  final Widget Function(BuildContext context, double phase) builder;

  const _VVReactiveMotion({
    required this.signal,
    this.continuous = false,
    required this.builder,
  });

  @override
  State<_VVReactiveMotion> createState() => _VVReactiveMotionState();
}

class _VVReactiveMotionState extends State<_VVReactiveMotion>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  double _basePhase = 0.0;

  bool get _isRunningContinuous =>
      widget.continuous &&
      !WidgetsBinding.instance.runtimeType
          .toString()
          .contains('TestWidgetsFlutterBinding');

  @override
  void initState() {
    super.initState();
    if (_isRunningContinuous) {
      _ctrl = AnimationController(
        vsync: this,
        duration: const Duration(seconds: 48),
      )..repeat();
    } else {
      _ctrl = AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 520),
      )..forward(from: 0.0);
    }
  }

  @override
  void didUpdateWidget(covariant _VVReactiveMotion oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_isRunningContinuous) {
      if (!_ctrl.isAnimating) {
        _ctrl.duration = const Duration(seconds: 48);
        _ctrl.repeat();
      }
      return;
    }
    if (oldWidget.signal != widget.signal) {
      _basePhase = (_basePhase + _ctrl.value * 0.25) % 1.0;
      _ctrl.forward(from: 0.0);
    }
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
      builder: (context, _) {
        if (_isRunningContinuous) {
          return widget.builder(context, _ctrl.value);
        }
        final eased = Curves.easeOutCubic.transform(_ctrl.value);
        final phase = (_basePhase + eased * 0.25) % 1.0;
        return widget.builder(context, phase);
      },
    );
  }
}

class _SkyPhaseSnapshot {
  final int index;
  final Color zenithColor;
  final Color horizonColor;
  final Color sunColor;
  final double sunGlow;
  final double sunGlare;
  final double rayleigh;
  final double timeOfDay;
  final bool isNight;

  const _SkyPhaseSnapshot({
    required this.index,
    required this.zenithColor,
    required this.horizonColor,
    required this.sunColor,
    required this.sunGlow,
    required this.sunGlare,
    required this.rayleigh,
    required this.timeOfDay,
    required this.isNight,
  });
}

/// Tab 0: Sky & Time Live Preview
/// Displays a single large detailed scene for the currently selected Time of Day
/// (Morning, Noon, Evening, or Night) without split panels or text badges.
class VVSkyPreviewBanner extends StatelessWidget {
  final AtmosphereConfig atmosphere;
  final LightingConfig lighting;
  final Color fogColor;
  final Color waterColor;
  final int selectedPhase; // 0=Morning, 1=Noon, 2=Evening, 3=Night

  const VVSkyPreviewBanner({
    super.key,
    required this.atmosphere,
    required this.lighting,
    required this.fogColor,
    required this.waterColor,
    required this.selectedPhase,
  });

  _SkyPhaseSnapshot _activePhaseSnapshot() {
    final atm = atmosphere;
    final l = lighting;
    switch (selectedPhase) {
      case 0:
        return _SkyPhaseSnapshot(
          index: 0,
          zenithColor: atm.effectiveSunriseZenith,
          horizonColor: atm.sunriseHorizon,
          sunColor: l.sunColorSunrise,
          sunGlow: atm.sunGlowSunrise,
          sunGlare: atm.sunGlareSunrise,
          rayleigh: atm.rayleighSunrise,
          timeOfDay: 0.75,
          isNight: false,
        );
      case 2:
        return _SkyPhaseSnapshot(
          index: 2,
          zenithColor: atm.effectiveSunsetZenith,
          horizonColor: atm.sunsetHorizon,
          sunColor: l.sunColorSunset,
          sunGlow: atm.sunGlowSunset,
          sunGlare: atm.sunGlareSunset,
          rayleigh: atm.rayleighSunset,
          timeOfDay: 0.25,
          isNight: false,
        );
      case 3:
        return _SkyPhaseSnapshot(
          index: 3,
          zenithColor: atm.effectiveNightZenith,
          horizonColor: atm.nightHorizon,
          sunColor: l.nightMoonColor,
          sunGlow: atm.moonGlow,
          sunGlare: 8.0,
          rayleigh: atm.rayleighNight,
          timeOfDay: 0.50,
          isNight: true,
        );
      case 1:
      default:
        return _SkyPhaseSnapshot(
          index: 1,
          zenithColor: atm.effectiveNoonZenith,
          horizonColor: atm.noonHorizon,
          sunColor: l.sunColorNoon,
          sunGlow: atm.sunGlowNoon,
          sunGlare: atm.sunGlareNoon,
          rayleigh: atm.rayleighNoon,
          timeOfDay: 0.0,
          isNight: false,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final active = _activePhaseSnapshot();
    final haze = atmosphere.horizonHazeScale;

    return VVPreviewFrame(
      height: 160,
      child: _VVReactiveMotion(
        continuous: true,
        signal: Object.hash(
          selectedPhase,
          active.horizonColor.toARGB32(),
          active.zenithColor.toARGB32(),
          active.sunColor.toARGB32(),
          active.sunGlow,
          active.sunGlare,
          active.rayleigh,
          haze,
          fogColor.toARGB32(),
          waterColor.toARGB32(),
        ),
        builder: (context, motion) => CustomPaint(
          painter: _VVDetailedSkyScenePainter(
            phase: active,
            fogColor: fogColor,
            waterColor: waterColor,
            hazeScale: haze,
            timeOfDay: active.timeOfDay,
            motion: motion,
          ),
        ),
      ),
    );
  }
}

class _VVDetailedSkyScenePainter extends CustomPainter {
  final _SkyPhaseSnapshot phase;
  final Color fogColor;
  final Color waterColor;
  final double hazeScale;
  final double timeOfDay;
  final double motion;

  const _VVDetailedSkyScenePainter({
    required this.phase,
    required this.fogColor,
    required this.waterColor,
    required this.hazeScale,
    required this.timeOfDay,
    required this.motion,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final horizonY = h * 0.63;
    final t = motion * math.pi * 2.0;

    // Morning (0): LEFT rising half-visible Sun | Noon (1): TOP center | Evening (2): RIGHT setting half-visible Sun | Night (3): High Moon
    late final double bodyX;
    late final double bodyY;
    switch (phase.index) {
      case 0:
        bodyX = w * 0.27;
        bodyY = horizonY - 2.0; // Bottom half sits cleanly behind the horizon
        break;
      case 2:
        bodyX = w * 0.73;
        bodyY = horizonY - 2.0; // Bottom half sits cleanly behind the horizon
        break;
      case 3:
        bodyX = w * 0.66;
        bodyY = 26.0;
        break;
      case 1:
      default:
        bodyX = w * 0.50;
        bodyY = 22.0;
        break;
    }

    final glowStrength = phase.isNight
        ? (phase.sunGlow.clamp(0.0, 20.0) / 20.0)
        : (phase.sunGlow.clamp(0.0, 60.0) / 60.0);
    final glareFactor =
        (1.0 - (phase.sunGlare.clamp(0.01, 50.0) / 55.0)).clamp(0.25, 1.0);

    _drawSkyAtmosphere(canvas, w, horizonY, bodyX, glowStrength);
    _drawNightCosmos(canvas, w, horizonY, t);
    _drawCelestialBody(
      canvas,
      bodyX,
      bodyY,
      glowStrength,
      glareFactor,
      t,
    );
    _drawVoxelClouds(canvas, w, horizonY, glowStrength);
    _drawMountainAndMistLayers(canvas, w, horizonY, bodyX, t);
    _drawMinecraftShoreline(canvas, w, horizonY, bodyX, t);
    _drawShaderWater(canvas, w, h, horizonY, bodyX, glowStrength, t);
  }

  void _drawSkyAtmosphere(
    Canvas canvas,
    double w,
    double horizonY,
    double bodyX,
    double glowStrength,
  ) {
    final scatterMix = (phase.rayleigh / 11.0).clamp(0.0, 1.0);
    late final List<double> stops;
    late final List<Color> skyColors;

    if (phase.index == 0) {
      // Soft indigo-purple to warm orange sunrise gradient (no harsh red)
      final zenith = Color.lerp(const Color(0xFF1E1B4B), phase.zenithColor, 0.55)!;
      final purpleBand = Color.lerp(const Color(0xFF7C3AED), phase.horizonColor, 0.34)!;
      final orangeBand = Color.lerp(const Color(0xFFFB923C), phase.horizonColor, 0.55)!;
      final lowGlow = Color.lerp(orangeBand, const Color(0xFFFDE68A), 0.25)!;
      stops = const [0.0, 0.38, 0.72, 0.90, 1.0];
      skyColors = [zenith, purpleBand, orangeBand, lowGlow, phase.horizonColor];
    } else if (phase.index == 2) {
      // Rich twilight purple to glowing orange sunset gradient (no harsh red)
      final zenith = Color.lerp(const Color(0xFF1E1B4B), phase.zenithColor, 0.55)!;
      final purpleBand = Color.lerp(const Color(0xFF7E22CE), phase.horizonColor, 0.30)!;
      final orangeBand = Color.lerp(const Color(0xFFF97316), phase.horizonColor, 0.54)!;
      final lowGlow = Color.lerp(orangeBand, const Color(0xFFFDBA74), 0.25)!;
      stops = const [0.0, 0.38, 0.72, 0.90, 1.0];
      skyColors = [zenith, purpleBand, orangeBand, lowGlow, phase.horizonColor];
    } else if (phase.isNight) {
      final deepSapphire = Color.lerp(const Color(0xFF09132E), phase.zenithColor, 0.45)!;
      final lunarHaze = Color.lerp(const Color(0xFF1E3A8A), phase.horizonColor, 0.52)!;
      stops = const [0.0, 0.40, 0.78, 1.0];
      skyColors = [phase.zenithColor, deepSapphire, lunarHaze, phase.horizonColor];
    } else {
      final upper = Color.lerp(phase.zenithColor, const Color(0xFF38BDF8), scatterMix * 0.28)!;
      final mid = Color.lerp(upper, phase.horizonColor, 0.55)!;
      stops = const [0.0, 0.40, 0.76, 1.0];
      skyColors = [phase.zenithColor, upper, mid, phase.horizonColor];
    }

    final skyRect = Rect.fromLTWH(0, 0, w, horizonY);
    canvas.drawRect(
      skyRect,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          stops: stops,
          colors: skyColors,
        ).createShader(skyRect),
    );

    if (phase.isNight) {
      // Soft atmospheric moonlight dome scattering around the Moon side
      canvas.drawOval(
        Rect.fromCenter(
          center: Offset(bodyX, horizonY * 0.46),
          width: w * 0.72,
          height: horizonY * 0.85,
        ),
        Paint()
          ..shader = RadialGradient(
            colors: [
              const Color(0xFF60A5FA).withValues(alpha: 0.16 * (0.4 + glowStrength)),
              const Color(0xFF1E3A8A).withValues(alpha: 0.08),
              Colors.transparent,
            ],
          ).createShader(
            Rect.fromCenter(
              center: Offset(bodyX, horizonY * 0.46),
              width: w * 0.72,
              height: horizonY * 0.85,
            ),
          ),
      );
    } else if (phase.index == 0 || phase.index == 2) {
      final sunGlowTint = Color.lerp(phase.sunColor, const Color(0xFFFB923C), 0.35)!;
      canvas.drawOval(
        Rect.fromCenter(
          center: Offset(bodyX, horizonY - 2),
          width: w * 0.85,
          height: horizonY * 0.56,
        ),
        Paint()
          ..shader = RadialGradient(
            colors: [
              sunGlowTint.withValues(alpha: 0.42 * (0.45 + glowStrength * 0.55)),
              phase.horizonColor.withValues(alpha: 0.18),
              Colors.transparent,
            ],
          ).createShader(
            Rect.fromCenter(
              center: Offset(bodyX, horizonY - 2),
              width: w * 0.85,
              height: horizonY * 0.56,
            ),
          ),
      );
    }
  }

  void _drawNightCosmos(
    Canvas canvas,
    double w,
    double horizonY,
    double t,
  ) {
    if (!phase.isNight && phase.index != 0 && phase.index != 2) return;

    if (phase.isNight) {
      // Refined diagonal Milky Way stardust band across northern sky (not boxy green bars)
      final milkyGlow = Paint()
        ..color = Color.lerp(const Color(0xFF38BDF8), phase.horizonColor, 0.35)!
            .withValues(alpha: 0.07 + 0.02 * math.sin(t));
      for (int b = 0; b < 10; b++) {
        canvas.drawOval(
          Rect.fromCenter(
            center: Offset(w * (0.06 + b * 0.075), horizonY * (0.82 - b * 0.072)),
            width: 38,
            height: 14,
          ),
          milkyGlow,
        );
      }
    }

    final baseAlpha = phase.isNight ? 0.94 : 0.34;
    const stars = [
      Offset(0.05, 0.10),
      Offset(0.11, 0.26),
      Offset(0.17, 0.13),
      Offset(0.23, 0.08),
      Offset(0.28, 0.21),
      Offset(0.35, 0.12),
      Offset(0.41, 0.29),
      Offset(0.47, 0.09),
      Offset(0.53, 0.20),
      Offset(0.59, 0.10),
      Offset(0.75, 0.11),
      Offset(0.83, 0.22),
      Offset(0.91, 0.14),
      Offset(0.08, 0.41),
      Offset(0.19, 0.36),
      Offset(0.31, 0.39),
      Offset(0.44, 0.44),
      Offset(0.56, 0.38),
      Offset(0.79, 0.39),
      Offset(0.88, 0.33),
      Offset(0.94, 0.46),
    ];
    for (int i = 0; i < stars.length; i++) {
      if (!phase.isNight && stars[i].dy > 0.25) continue;
      final twinkle = 0.45 + 0.55 * (0.5 + 0.5 * math.sin(t + i * 1.37));
      final sx = w * stars[i].dx;
      final sy = horizonY * stars[i].dy;
      final sz = (i % 4 == 0) ? 2.4 : (i % 3 == 0 ? 1.9 : 1.4);
      canvas.drawRect(
        Rect.fromLTWH(sx, sy, sz, sz),
        Paint()
          ..color = (i % 5 == 0 ? const Color(0xFFBAE6FD) : Colors.white)
              .withValues(alpha: (baseAlpha * twinkle).clamp(0.0, 1.0)),
      );
    }
  }

  /// Pure Minecraft square Sun & detailed cratered Pixel Moon — clean radial corona ONLY.
  void _drawCelestialBody(
    Canvas canvas,
    double bodyX,
    double bodyY,
    double glowStrength,
    double glareFactor,
    double t,
  ) {
    final bodyColor = phase.isNight
        ? phase.sunColor
        : Color.lerp(phase.sunColor, const Color(0xFFFDBA74), 0.32)!;
    final pulse = 1.0 + 0.03 * math.sin(t);

    if (phase.isNight) {
      final moonGlow = (34 + glowStrength * 64) * pulse;
      canvas.drawCircle(
        Offset(bodyX, bodyY),
        moonGlow,
        Paint()
          ..shader = RadialGradient(
            colors: [
              const Color(0xFFF8FAFC).withValues(alpha: 0.54 * (0.4 + glowStrength * 0.6)),
              const Color(0xFF93C5FD).withValues(alpha: 0.22 * (0.3 + glowStrength * 0.7)),
              const Color(0xFF3B82F6).withValues(alpha: 0.08),
              Colors.transparent,
            ],
          ).createShader(Rect.fromCircle(center: Offset(bodyX, bodyY), radius: moonGlow)),
      );
      // Subtle atmospheric moon halo ring
      canvas.drawCircle(
        Offset(bodyX, bodyY),
        23.5,
        Paint()
          ..color = const Color(0xFFBAE6FD).withValues(alpha: 0.14)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.1,
      );

      // Detailed 25x25 shaded Minecraft voxel Moon with lunar maria & edge highlights
      const moonSize = 25.0;
      final mLeft = bodyX - moonSize * 0.5;
      final mTop = bodyY - moonSize * 0.5;
      const u = moonSize / 7.0;
      final baseLunar = Color.lerp(bodyColor, Colors.white, 0.45)!;
      final brightRim = Color.lerp(bodyColor, Colors.white, 0.78)!;
      final mare = Color.lerp(bodyColor, const Color(0xFF64748B), 0.48)!;
      final deepCrater = const Color(0xFF475569).withValues(alpha: 0.75);

      canvas.drawRect(Rect.fromLTWH(mLeft, mTop, moonSize, moonSize), Paint()..color = baseLunar);
      // Bright silver-white top & left illuminated edge
      canvas.drawRect(Rect.fromLTWH(mLeft, mTop, moonSize, u * 0.85), Paint()..color = brightRim);
      canvas.drawRect(Rect.fromLTWH(mLeft, mTop, u * 0.85, moonSize), Paint()..color = brightRim);
      // Asymmetric Minecraft-style lunar maria & crater basins
      canvas.drawRect(Rect.fromLTWH(mLeft + u * 1.1, mTop + u * 1.1, u * 2.0, u * 1.6), Paint()..color = mare);
      canvas.drawRect(Rect.fromLTWH(mLeft + u * 4.0, mTop + u * 1.5, u * 1.8, u * 1.8), Paint()..color = mare);
      canvas.drawRect(Rect.fromLTWH(mLeft + u * 1.6, mTop + u * 3.8, u * 2.2, u * 1.4), Paint()..color = mare);
      canvas.drawRect(Rect.fromLTWH(mLeft + u * 4.5, mTop + u * 4.2, u * 1.4, u * 1.5), Paint()..color = deepCrater);
      canvas.drawRect(Rect.fromLTWH(mLeft + u * 1.4, mTop + u * 1.4, u * 0.9, u * 0.9), Paint()..color = deepCrater);
      // Subtle crescent terminator shadow along right edge
      canvas.drawRect(
        Rect.fromLTWH(mLeft + u * 5.9, mTop + u * 0.85, u * 1.1, moonSize - u * 0.85),
        Paint()..color = const Color(0xFF475569).withValues(alpha: 0.32),
      );
      return;
    }

    if (glowStrength > 0.01) {
      final glowRadius = (32 + glowStrength * 58 * glareFactor) * pulse;
      canvas.drawCircle(
        Offset(bodyX, bodyY),
        glowRadius,
        Paint()
          ..shader = RadialGradient(
            colors: [
              bodyColor.withValues(alpha: 0.70 * (0.35 + glowStrength * 0.65)),
              bodyColor.withValues(alpha: 0.20 * glowStrength),
              Colors.transparent,
            ],
          ).createShader(Rect.fromCircle(center: Offset(bodyX, bodyY), radius: glowRadius)),
      );
    }

    const discSize = 20.0;
    canvas.drawRect(
      Rect.fromCenter(center: Offset(bodyX, bodyY), width: discSize, height: discSize),
      Paint()..color = bodyColor,
    );
    canvas.drawRect(
      Rect.fromCenter(
        center: Offset(bodyX, bodyY),
        width: discSize * 0.56,
        height: discSize * 0.56,
      ),
      Paint()..color = const Color(0xFFFEF9C3),
    );
  }

  /// Slow, minimal, calm drifting Minecraft voxel clouds.
  void _drawVoxelClouds(
    Canvas canvas,
    double w,
    double horizonY,
    double glowStrength,
  ) {
    final bodyColor = phase.sunColor;
    final cloudTop = Color.lerp(
      phase.isNight ? const Color(0xFF475569) : Colors.white,
      phase.isNight ? const Color(0xFFBAE6FD) : bodyColor,
      phase.isNight ? 0.24 : 0.12,
    )!;
    final cloudMid = Color.lerp(
      phase.isNight ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
      phase.horizonColor,
      phase.isNight ? 0.35 : 0.34,
    )!;
    final cloudRim = phase.isNight
        ? Color.lerp(cloudMid, const Color(0xFF93C5FD), 0.38 + glowStrength * 0.25)!
        : Color.lerp(
            cloudMid,
            const Color(0xFFFB923C),
            (phase.index == 0 || phase.index == 2)
                ? (0.45 + glowStrength * 0.35)
                : glowStrength * 0.25,
          )!;

    // Very slow gentle drift (seamless wrap over 48s loop)
    final drift = motion * (w + 90);
    for (final c in const [
      (x: 0.08, y: 0.26, cw: 50.0, ch: 8.5),
      (x: 0.42, y: 0.18, cw: 58.0, ch: 9.0),
      (x: 0.74, y: 0.30, cw: 46.0, ch: 8.0),
    ]) {
      final cx = ((w * c.x + drift) % (w + 90)) - 70;
      final cy = horizonY * c.y;
      final alpha = phase.isNight ? 0.78 : 0.92;
      canvas.drawRect(
        Rect.fromLTWH(cx, cy, c.cw, c.ch),
        Paint()..color = cloudMid.withValues(alpha: alpha),
      );
      canvas.drawRect(
        Rect.fromLTWH(cx + 8, cy - 4, c.cw * 0.60, 4.5),
        Paint()..color = cloudTop.withValues(alpha: alpha),
      );
      canvas.drawRect(
        Rect.fromLTWH(cx, cy + c.ch - 2.2, c.cw, 2.2),
        Paint()..color = cloudRim.withValues(alpha: 0.92),
      );
    }
  }

  /// Stepped Minecraft mountains centered safely between Left sunrise & Right sunset passes.
  void _drawMountainAndMistLayers(
    Canvas canvas,
    double w,
    double horizonY,
    double bodyX,
    double t,
  ) {
    final hazeMix = (hazeScale.clamp(0.0, 2.0) * 0.38).clamp(0.08, 0.84);
    final hazeTarget = Color.lerp(phase.horizonColor, fogColor, 0.50)!;
    final darkSlope = Color.lerp(const Color(0xFF1E293B), hazeTarget, hazeMix)!;
    final litSlope = Color.lerp(
      darkSlope,
      phase.isNight ? const Color(0xFF93C5FD) : const Color(0xFFFDBA74),
      phase.isNight ? 0.16 : 0.26,
    )!;
    final snowCol = Color.lerp(
      Colors.white,
      phase.isNight ? const Color(0xFF93C5FD) : phase.horizonColor,
      phase.index == 1 ? 0.14 : 0.40,
    )!;

    final darkPaint = Paint()..color = darkSlope;
    final litPaint = Paint()..color = litSlope.withValues(alpha: 0.76);
    final snowPaint = Paint()..color = snowCol.withValues(alpha: phase.isNight ? 0.44 : 0.82);
    final sunRight = bodyX >= w * 0.50;

    // Distant extreme-hills range placed at center 0.35w..0.65w so outer sunrise/sunset sun stays clearly half-visible
    const peaks = [
      (x: 0.35, width: 0.14, h: 24.0),
      (x: 0.47, width: 0.16, h: 29.0),
      (x: 0.59, width: 0.10, h: 18.0),
    ];
    for (final pk in peaks) {
      final px = w * pk.x;
      final pw = w * pk.width;
      canvas.drawRect(Rect.fromLTWH(px, horizonY - pk.h * 0.48, pw, pk.h * 0.48), darkPaint);
      canvas.drawRect(
        Rect.fromLTWH(px + pw * 0.18, horizonY - pk.h * 0.78, pw * 0.64, pk.h * 0.32),
        darkPaint,
      );
      canvas.drawRect(
        Rect.fromLTWH(px + pw * 0.32, horizonY - pk.h, pw * 0.36, pk.h * 0.26),
        darkPaint,
      );
      if (sunRight) {
        canvas.drawRect(
          Rect.fromLTWH(px + pw * 0.50, horizonY - pk.h, pw * 0.18, pk.h * 0.26),
          litPaint,
        );
        canvas.drawRect(
          Rect.fromLTWH(px + pw * 0.58, horizonY - pk.h * 0.78, pw * 0.24, pk.h * 0.32),
          litPaint,
        );
      } else {
        canvas.drawRect(
          Rect.fromLTWH(px + pw * 0.32, horizonY - pk.h, pw * 0.18, pk.h * 0.26),
          litPaint,
        );
        canvas.drawRect(
          Rect.fromLTWH(px + pw * 0.18, horizonY - pk.h * 0.78, pw * 0.24, pk.h * 0.32),
          litPaint,
        );
      }
      canvas.drawRect(
        Rect.fromLTWH(px + pw * 0.32, horizonY - pk.h, pw * 0.36, 3.0),
        snowPaint,
      );
    }

    // Horizon mist band driven by horizonHazeScale & fogColor
    final hazeRect = Rect.fromLTWH(0, horizonY - 24, w, 26);
    canvas.drawRect(
      hazeRect,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            phase.horizonColor.withValues(alpha: 0.0),
            Color.lerp(phase.horizonColor, fogColor, 0.45)!
                .withValues(alpha: hazeMix.clamp(0.0, 0.85)),
          ],
        ).createShader(hazeRect),
    );
  }

  void _drawMcTerrainBlockColumn(
    Canvas canvas,
    double x,
    double bottomY,
    double width,
    double height, {
    required Color grassTop,
    required Color grassRim,
    required Color dirtBase,
    required Color dirtDark,
    required Color stoneColor,
    required bool withStoneBase,
  }) {
    final topY = bottomY - height;
    canvas.drawRect(Rect.fromLTWH(x, topY, width, height), Paint()..color = dirtBase);
    final speck = Paint()..color = dirtDark;
    canvas.drawRect(Rect.fromLTWH(x + 2, topY + 5, 3, 2), speck);
    if (height > 10) {
      canvas.drawRect(Rect.fromLTWH(x + width * 0.55, topY + 7, 3, 2), speck);
    }
    if (withStoneBase && height > 9) {
      canvas.drawRect(
        Rect.fromLTWH(x, bottomY - 4.0, width, 4.0),
        Paint()..color = stoneColor,
      );
    }
    canvas.drawRect(Rect.fromLTWH(x, topY, width, 3.2), Paint()..color = grassTop);
    canvas.drawRect(Rect.fromLTWH(x + 2, topY + 3.2, 4, 1.8), Paint()..color = grassRim);
    canvas.drawRect(
      Rect.fromLTWH(x + width * 0.60, topY + 3.2, 3.5, 2.0),
      Paint()..color = grassRim,
    );
  }

  /// Crisp unit-grid pixel-art Minecraft Oak or Birch tree.
  void _drawMcOakOrBirchTree(
    Canvas canvas, {
    required double cx,
    required double groundY,
    required double u,
    required bool isBirch,
    required bool sunOnRight,
    required Color leafLight,
    required Color leafMid,
    required Color leafDark,
  }) {
    final trunkX = cx - u * 0.5;
    final trunkH = u * 3.0;
    final trunkTop = groundY - trunkH;

    if (isBirch) {
      canvas.drawRect(Rect.fromLTWH(trunkX, trunkTop, u, trunkH), Paint()..color = const Color(0xFFE2E8F0));
      final barkSpot = Paint()..color = const Color(0xFF334155);
      canvas.drawRect(Rect.fromLTWH(trunkX, trunkTop + u * 0.5, u * 0.65, 1.8), barkSpot);
      canvas.drawRect(Rect.fromLTWH(trunkX + u * 0.35, trunkTop + u * 1.5, u * 0.65, 1.8), barkSpot);
    } else {
      canvas.drawRect(
        Rect.fromLTWH(trunkX, trunkTop, u, trunkH),
        Paint()..color = phase.isNight ? const Color(0xFF292524) : const Color(0xFF6B4226),
      );
      canvas.drawRect(
        Rect.fromLTWH(trunkX + 1.0, trunkTop, 1.4, trunkH),
        Paint()..color = phase.isNight ? const Color(0xFF44403C) : const Color(0xFF8B5A3C),
      );
    }

    // Exact Minecraft 3x1 top + 5x2 body crown on crisp integer unit grid
    final midP = Paint()..color = leafMid;
    final litP = Paint()..color = leafLight;
    final darkP = Paint()..color = leafDark;

    final bodyTop = groundY - u * 4.8;
    canvas.drawRect(Rect.fromLTWH(cx - u * 2.5, bodyTop, u * 5.0, u * 2.0), midP);
    final crownTop = bodyTop - u * 1.0;
    canvas.drawRect(Rect.fromLTWH(cx - u * 1.5, crownTop, u * 3.0, u * 1.05), midP);

    // Sun-lit corner & dithered leaf blocks
    if (sunOnRight) {
      canvas.drawRect(Rect.fromLTWH(cx + u * 0.2, crownTop, u * 1.3, u * 1.0), litP);
      canvas.drawRect(Rect.fromLTWH(cx + u * 0.8, bodyTop, u * 1.7, u * 1.5), litP);
      canvas.drawRect(Rect.fromLTWH(cx - u * 2.5, bodyTop + u * 0.8, u * 1.0, u * 1.2), darkP);
    } else {
      canvas.drawRect(Rect.fromLTWH(cx - u * 1.5, crownTop, u * 1.3, u * 1.0), litP);
      canvas.drawRect(Rect.fromLTWH(cx - u * 2.5, bodyTop, u * 1.7, u * 1.5), litP);
      canvas.drawRect(Rect.fromLTWH(cx + u * 1.5, bodyTop + u * 0.8, u * 1.0, u * 1.2), darkP);
    }
  }

  /// Crisp symmetrical unit-grid Minecraft Spruce pine tree.
  void _drawMcSpruceTree(
    Canvas canvas, {
    required double cx,
    required double groundY,
    required double u,
    required bool sunOnRight,
    required Color trunkColor,
    required Color leafLight,
    required Color leafMid,
    required Color leafDark,
  }) {
    canvas.drawRect(
      Rect.fromLTWH(cx - u * 0.45, groundY - u * 5.6, u * 0.9, u * 5.6),
      Paint()..color = trunkColor,
    );
    // Symmetrical stepped Minecraft pine tiers (7u -> neck -> 5u -> neck -> 3u -> 1u spike)
    final tiers = [
      (yOff: 2.0, halfW: 3.2, h: 1.15),
      (yOff: 2.9, halfW: 1.4, h: 0.7),
      (yOff: 3.8, halfW: 2.3, h: 1.1),
      (yOff: 4.6, halfW: 0.9, h: 0.65),
      (yOff: 5.5, halfW: 1.4, h: 1.05),
      (yOff: 6.4, halfW: 0.5, h: 1.0),
    ];
    for (int i = 0; i < tiers.length; i++) {
      final tr = tiers[i];
      final tw = u * tr.halfW * 2;
      final tx = cx - tw * 0.5;
      final ty = groundY - u * tr.yOff;
      final isNeck = i == 1 || i == 3;
      canvas.drawRect(
        Rect.fromLTWH(tx, ty, tw, u * tr.h),
        Paint()..color = isNeck ? leafDark : leafMid,
      );
      if (!isNeck) {
        canvas.drawRect(
          Rect.fromLTWH(sunOnRight ? cx : tx, ty, tw * 0.45, u * tr.h * 0.85),
          Paint()..color = leafLight,
        );
      }
    }
  }

  /// Balanced Minecraft voxel outer banks leaving 0.20..0.80 horizon open for half-visible Sun.
  void _drawMinecraftShoreline(
    Canvas canvas,
    double w,
    double horizonY,
    double bodyX,
    double t,
  ) {
    final sunOnRight = bodyX >= w * 0.50;
    final grassTop = phase.isNight
        ? const Color(0xFF065F46)
        : Color.lerp(const Color(0xFF4ADE80), const Color(0xFFFDE68A), 0.12)!;
    final grassRim = phase.isNight
        ? const Color(0xFF047857)
        : Color.lerp(const Color(0xFF22C55E), phase.horizonColor, 0.16)!;
    final dirtBase = phase.isNight ? const Color(0xFF292524) : const Color(0xFF78350F);
    final dirtDark = phase.isNight ? const Color(0xFF1C1917) : const Color(0xFF5C2A0C);
    final stoneCol = phase.isNight ? const Color(0xFF334155) : const Color(0xFF64748B);
    final sandCol = phase.isNight ? const Color(0xFF475569) : const Color(0xFFE5D283);

    // Left bank: 0 .. 0.16w stepped down to sand beach at 0.16..0.19w
    _drawMcTerrainBlockColumn(
      canvas,
      0,
      horizonY,
      w * 0.10,
      14,
      grassTop: grassTop,
      grassRim: grassRim,
      dirtBase: dirtBase,
      dirtDark: dirtDark,
      stoneColor: stoneCol,
      withStoneBase: true,
    );
    _drawMcTerrainBlockColumn(
      canvas,
      w * 0.10,
      horizonY,
      w * 0.06,
      8,
      grassTop: grassTop,
      grassRim: grassRim,
      dirtBase: dirtBase,
      dirtDark: dirtDark,
      stoneColor: stoneCol,
      withStoneBase: false,
    );
    canvas.drawRect(Rect.fromLTWH(w * 0.16, horizonY - 3, w * 0.04, 4), Paint()..color = sandCol);

    // Right bank: sand beach 0.80..0.84w stepping up to 0.84..1.0w
    canvas.drawRect(Rect.fromLTWH(w * 0.80, horizonY - 3, w * 0.04, 4), Paint()..color = sandCol);
    _drawMcTerrainBlockColumn(
      canvas,
      w * 0.84,
      horizonY,
      w * 0.06,
      8,
      grassTop: grassTop,
      grassRim: grassRim,
      dirtBase: dirtBase,
      dirtDark: dirtDark,
      stoneColor: stoneCol,
      withStoneBase: false,
    );
    _drawMcTerrainBlockColumn(
      canvas,
      w * 0.90,
      horizonY,
      w * 0.10,
      14,
      grassTop: grassTop,
      grassRim: grassRim,
      dirtBase: dirtBase,
      dirtDark: dirtDark,
      stoneColor: stoneCol,
      withStoneBase: true,
    );

    // Wild poppy & dandelion pixels
    canvas.drawRect(Rect.fromLTWH(w * 0.12, horizonY - 11, 2.5, 3), Paint()..color = const Color(0xFFEF4444));
    canvas.drawRect(Rect.fromLTWH(w * 0.86, horizonY - 11, 2.5, 3), Paint()..color = const Color(0xFFFACC15));

    // Proper crisp Minecraft trees on left & right banks
    final leafLight = phase.isNight ? const Color(0xFF047857) : const Color(0xFF4ADE80);
    final leafMid = phase.isNight ? const Color(0xFF065F46) : const Color(0xFF16A34A);
    final leafDark = phase.isNight ? const Color(0xFF022C22) : const Color(0xFF14532D);

    _drawMcOakOrBirchTree(
      canvas,
      cx: w * 0.055,
      groundY: horizonY - 14,
      u: 4.0,
      isBirch: false,
      sunOnRight: sunOnRight,
      leafLight: leafLight,
      leafMid: leafMid,
      leafDark: leafDark,
    );
    _drawMcOakOrBirchTree(
      canvas,
      cx: w * 0.87,
      groundY: horizonY - 8,
      u: 3.6,
      isBirch: true,
      sunOnRight: sunOnRight,
      leafLight: phase.isNight ? const Color(0xFF047857) : const Color(0xFF86EFAC),
      leafMid: phase.isNight ? const Color(0xFF065F46) : const Color(0xFF22C55E),
      leafDark: leafDark,
    );
    _drawMcSpruceTree(
      canvas,
      cx: w * 0.945,
      groundY: horizonY - 14,
      u: 4.0,
      sunOnRight: sunOnRight,
      trunkColor: phase.isNight ? const Color(0xFF292524) : const Color(0xFF451A03),
      leafLight: phase.isNight ? const Color(0xFF047857) : const Color(0xFF15803D),
      leafMid: phase.isNight ? const Color(0xFF064E3B) : const Color(0xFF14532D),
      leafDark: const Color(0xFF052E16),
    );
  }

  /// Detailed Minecraft shader water: shallow sand caustics, tiled waves, specular sun/moon reflection column.
  void _drawShaderWater(
    Canvas canvas,
    double w,
    double h,
    double horizonY,
    double bodyX,
    double glowStrength,
    double t,
  ) {
    final waterRect = Rect.fromLTWH(0, horizonY, w, h - horizonY);
    final shallowTint = Color.lerp(waterColor, const Color(0xFF38BDF8), phase.isNight ? 0.12 : 0.34)!;
    canvas.drawRect(
      waterRect,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          stops: const [0.0, 0.28, 0.70, 1.0],
          colors: [
            Color.lerp(waterColor, phase.horizonColor, 0.45)!,
            shallowTint,
            waterColor,
            Color.lerp(waterColor, const Color(0xFF020617), 0.56)!,
          ],
        ).createShader(waterRect),
    );

    final shallowSand = Paint()
      ..color = const Color(0xFFE5D283).withValues(alpha: phase.isNight ? 0.08 : 0.18);
    canvas.drawRect(Rect.fromLTWH(0, horizonY, w * 0.20, 10), shallowSand);
    canvas.drawRect(Rect.fromLTWH(w * 0.80, horizonY, w * 0.20, 10), shallowSand);

    final causticAlpha = phase.isNight ? 0.08 : (phase.index == 1 ? 0.28 : 0.18);
    final causticP = Paint()..color = const Color(0xFFA5F3FC).withValues(alpha: causticAlpha);
    for (int i = 0; i < 6; i++) {
      final cx = w * (0.04 + i * 0.17) + math.sin(t + i) * 2.5;
      final cy = horizonY + 4 + (i % 2) * 4.5;
      canvas.drawRect(Rect.fromLTWH(cx, cy, 11, 1.8), causticP);
    }

    // Slow tiled wave facets
    final troughPaint = Paint()
      ..color = const Color(0xFF020617).withValues(alpha: phase.isNight ? 0.24 : 0.13);
    final crestPaint = Paint()
      ..color = Color.lerp(phase.horizonColor, Colors.white, 0.42)!
          .withValues(alpha: phase.isNight ? 0.16 : 0.28);
    for (int row = 0; row < 5; row++) {
      final wy = horizonY + 4 + row * 9.5;
      if (wy + 3 > h) break;
      final facetW = 14.0 + row * 3.5;
      final dir = row.isEven ? 1.0 : -1.0;
      final speed = (14.0 + row * 4.0) * dir;
      for (int col = 0; col < 5; col++) {
        final fx = ((w * (col * 0.22 + (row % 2) * 0.10) + motion * speed) %
            (w + facetW)) -
            facetW * 0.5;
        canvas.drawRect(Rect.fromLTWH(fx, wy + 2.0, facetW * 0.85, 1.6), troughPaint);
        canvas.drawRect(Rect.fromLTWH(fx + 2, wy, facetW * 0.70, 1.6), crestPaint);
      }
    }

    final sunRefColor = phase.isNight
        ? phase.sunColor
        : Color.lerp(phase.sunColor, const Color(0xFFFDBA74), 0.35)!;
    final refPaint = Paint()
      ..color = sunRefColor.withValues(alpha: (0.44 + glowStrength * 0.34).clamp(0.0, 0.90));
    final coreRefPaint = Paint()
      ..color = Colors.white.withValues(alpha: phase.isNight ? 0.30 : 0.52);
    for (int i = 0; i < 6; i++) {
      final y = horizonY + 3.5 + i * 8.5;
      if (y + 3 > h) break;
      final shift = math.sin(t + i * 1.2) * (2.0 + i * 0.4);
      final sliceW = (40.0 - i * 4.8).clamp(6.0, 44.0);
      canvas.drawRect(
        Rect.fromCenter(center: Offset(bodyX + shift, y), width: sliceW, height: 2.2),
        refPaint,
      );
      if (i < 4) {
        canvas.drawRect(
          Rect.fromCenter(center: Offset(bodyX + shift, y), width: sliceW * 0.45, height: 1.4),
          coreRefPaint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant _VVDetailedSkyScenePainter old) =>
      old.phase.index != phase.index ||
      old.phase.horizonColor != phase.horizonColor ||
      old.phase.zenithColor != phase.zenithColor ||
      old.phase.sunColor != phase.sunColor ||
      old.phase.sunGlow != phase.sunGlow ||
      old.phase.sunGlare != phase.sunGlare ||
      old.phase.rayleigh != phase.rayleigh ||
      old.fogColor != fogColor ||
      old.waterColor != waterColor ||
      old.hazeScale != hazeScale ||
      old.timeOfDay != timeOfDay ||
      old.motion != motion;
}

/// Tab 1: Light & Shadows Live Preview (adapts cleanly between Sunlight / Cave / Block Lights)
class VVLightingPreviewBanner extends StatelessWidget {
  final int mode; // 0 = Sunlight, 1 = Cave, 2 = Block Lights
  final LightingConfig lighting;
  final int sunPhase; // 0 = Noon, 1 = Evening, 2 = Morning, 3 = Night
  final int activeLightGroupIndex; // 0..6 when mode == 2

  const VVLightingPreviewBanner({
    super.key,
    required this.mode,
    required this.lighting,
    this.sunPhase = 0,
    this.activeLightGroupIndex = 0,
  });

  @override
  Widget build(BuildContext context) {
    return VVPreviewFrame(
      height: 160,
      child: _VVReactiveMotion(
        continuous: true,
        signal: Object.hash(mode, sunPhase, lighting, activeLightGroupIndex),
        builder: (context, motion) => CustomPaint(
          painter: _VVLightingPreviewPainter(
            mode: mode,
            lighting: lighting,
            sunPhase: sunPhase,
            activeLightGroupIndex: activeLightGroupIndex,
            motion: motion,
          ),
        ),
      ),
    );
  }
}

class _VVLightingPreviewPainter extends CustomPainter {
  final int mode;
  final LightingConfig lighting;
  final int sunPhase;
  final int activeLightGroupIndex;
  final double motion;

  const _VVLightingPreviewPainter({
    required this.mode,
    required this.lighting,
    required this.sunPhase,
    required this.activeLightGroupIndex,
    this.motion = 0.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    canvas.save();
    canvas.clipRect(Rect.fromLTWH(0, 0, w, h));

    if (mode == 1) {
      _drawCaveScene(canvas, w, h);
    } else if (mode == 2) {
      _drawBlockLightsScene(canvas, w, h);
    } else {
      _drawSunlightScene(canvas, w, h);
    }

    canvas.restore();
  }

  void _drawSunlightScene(Canvas canvas, double w, double h) {
    final horizonY = h * 0.56;
    final groundY = h * 0.78;
    final isNight = sunPhase == 3;
    final isEvening = sunPhase == 1;
    final isMorning = sunPhase == 2;
    final t = motion * math.pi * 2.0;

    final bright = isNight
        ? (0.28 + (lighting.moonIlluminance / 20.0) * 0.72).clamp(0.22, 1.0)
        : (0.28 + (lighting.sunBrightnessMultiplier / 2.0) * 0.72).clamp(0.22, 1.0);

    final activeLightColor = switch (sunPhase) {
      1 => Color.lerp(lighting.sunColorSunset, const Color(0xFFFB923C), 0.25)!,
      2 => Color.lerp(lighting.sunColorSunrise, const Color(0xFFFDBA74), 0.25)!,
      3 => Color.lerp(lighting.nightMoonColor, lighting.moonColor, 0.35)!,
      _ => lighting.sunColorNoon,
    };

    // 1. Minecraft Sky Gradient per Sun Color Time + Brightness (clear horizon haze like shader skies)
    late final Color skyTop;
    late final Color skyMid;
    late final Color skyHorizon;
    if (isNight) {
      skyTop = Color.lerp(const Color(0xFF030712), lighting.nightMoonColor, 0.28 * bright)!;
      skyMid = Color.lerp(const Color(0xFF0B1536), lighting.nightMoonColor, 0.42 * bright)!;
      skyHorizon = Color.lerp(const Color(0xFF1E3A8A), lighting.moonColor, 0.30 * bright)!;
    } else if (isMorning) {
      skyTop = Color.lerp(const Color(0xFF1E1B4B), const Color(0xFF3730A3), bright * 0.6)!;
      skyMid = Color.lerp(const Color(0xFF7C3AED), lighting.sunColorSunrise, 0.38 * bright)!;
      skyHorizon = Color.lerp(const Color(0xFFFB923C), lighting.sunColorSunrise, 0.46)!;
    } else if (isEvening) {
      skyTop = Color.lerp(const Color(0xFF1E1B4B), const Color(0xFF4C1D95), bright * 0.65)!;
      skyMid = Color.lerp(const Color(0xFF9333EA), lighting.sunColorSunset, 0.38 * bright)!;
      skyHorizon = Color.lerp(const Color(0xFFF97316), lighting.sunColorSunset, 0.48)!;
    } else {
      skyTop = Color.lerp(const Color(0xFF3B82F6), lighting.sunColorNoon, 0.14 * bright)!;
      skyMid = Color.lerp(const Color(0xFF7DD3FC), lighting.sunColorNoon, 0.22 * bright)!;
      skyHorizon = Color.lerp(const Color(0xFFE0F2FE), lighting.sunColorNoon, 0.36 * bright)!;
    }

    canvas.drawRect(
      Rect.fromLTWH(0, 0, w, horizonY + 18),
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          stops: const [0.0, 0.56, 1.0],
          colors: [skyTop, skyMid, skyHorizon],
        ).createShader(Rect.fromLTWH(0, 0, w, horizonY + 18)),
    );

    if (isNight) {
      final starPaint = Paint();
      const stars = [
        Offset(0.08, 0.13),
        Offset(0.19, 0.27),
        Offset(0.32, 0.11),
        Offset(0.45, 0.24),
        Offset(0.57, 0.14),
        Offset(0.78, 0.21),
        Offset(0.89, 0.13),
        Offset(0.14, 0.44),
        Offset(0.92, 0.36),
      ];
      for (int i = 0; i < stars.length; i++) {
        final tw = 0.55 + 0.45 * math.sin(t * 2 + i * 1.4);
        starPaint.color = Colors.white.withValues(alpha: 0.78 * tw);
        canvas.drawRect(Rect.fromLTWH(w * stars[i].dx, horizonY * stars[i].dy, 2, 2), starPaint);
      }
    }

    // 2. Orbital tilt offset shifts celestial arc & shadow angle/length
    final rad = lighting.orbitalOffsetDegrees * math.pi / 180.0;
    final tiltDx = math.sin(rad) * 0.08;
    final tiltDy = (1.0 - math.cos(rad)) * 0.06;

    final baseSunX = isMorning
        ? 0.22
        : isEvening
            ? 0.78
            : isNight
                ? 0.72
                : 0.24;
    final baseSunY = (isMorning || isEvening) ? 0.90 : 0.30;
    final bodyPos = Offset(
      w * (baseSunX + tiltDx).clamp(0.10, 0.90),
      (isMorning || isEvening)
          ? horizonY + 1.0 // Half-visible Sunrise/Sunset right at meadow horizon
          : horizonY * (baseSunY + tiltDy).clamp(0.18, 0.74),
    );

    final haloRadius = (isNight ? 44.0 : 58.0) * (0.72 + 0.48 * bright);
    canvas.drawCircle(
      bodyPos,
      haloRadius,
      Paint()
        ..shader = RadialGradient(
          colors: [
            activeLightColor.withValues(alpha: (isNight ? 0.38 : 0.54) * bright),
            activeLightColor.withValues(alpha: 0.0),
          ],
        ).createShader(Rect.fromCircle(center: bodyPos, radius: haloRadius)),
    );

    if (isNight) {
      // Shaded 7x7 Minecraft Moon with craters & bright rim
      const moonSize = 22.0;
      final ml = bodyPos.dx - moonSize * 0.5;
      final mt = bodyPos.dy - moonSize * 0.5;
      const u = moonSize / 7.0;
      final baseL = Color.lerp(activeLightColor, Colors.white, 0.52)!;
      final brightL = Color.lerp(activeLightColor, Colors.white, 0.82)!;
      canvas.drawRect(Rect.fromLTWH(ml, mt, moonSize, moonSize), Paint()..color = baseL);
      canvas.drawRect(Rect.fromLTWH(ml, mt, moonSize, u * 0.85), Paint()..color = brightL);
      canvas.drawRect(Rect.fromLTWH(ml, mt, u * 0.85, moonSize), Paint()..color = brightL);
      canvas.drawRect(Rect.fromLTWH(ml + u * 1.2, mt + u * 1.2, u * 1.8, u * 1.5), Paint()..color = const Color(0xFF94A3B8));
      canvas.drawRect(Rect.fromLTWH(ml + u * 4.0, mt + u * 1.8, u * 1.7, u * 1.6), Paint()..color = const Color(0xFF64748B));
      canvas.drawRect(Rect.fromLTWH(ml + u * 1.8, mt + u * 4.0, u * 2.0, u * 1.3), Paint()..color = const Color(0xFF64748B));
    } else {
      // Clean square Minecraft Sun (no ray lines!)
      const sSize = 20.0;
      canvas.drawRect(Rect.fromCenter(center: bodyPos, width: sSize, height: sSize), Paint()..color = activeLightColor);
      canvas.drawRect(
        Rect.fromCenter(center: bodyPos, width: 11.0, height: 11.0),
        Paint()..color = const Color(0xFFFEF9C3),
      );
    }

    // 3. Slow drifting stepped Minecraft clouds
    final cloudDrift = motion * (w + 90);
    final cloudTopCol = isNight ? const Color(0xFF475569) : Colors.white.withValues(alpha: 0.90);
    final cloudBotCol = isNight
        ? const Color(0xFF1E293B)
        : Color.lerp(const Color(0xFFE2E8F0), activeLightColor, 0.30)!;
    for (final c in const [
      (x: 0.12, y: 0.22, cw: 44.0, ch: 7.5),
      (x: 0.64, y: 0.17, cw: 52.0, ch: 8.0),
    ]) {
      final cx = ((w * c.x + cloudDrift) % (w + 90)) - 70;
      final cy = horizonY * c.y;
      canvas.drawRect(Rect.fromLTWH(cx, cy, c.cw, c.ch), Paint()..color = cloudBotCol);
      canvas.drawRect(Rect.fromLTWH(cx + 8, cy - 3.5, c.cw * 0.56, 4.0), Paint()..color = cloudTopCol);
    }



    // 4. Broad Perspective Minecraft Grass Meadow + Pond + Foreground Grass/Dirt Blocks
    final ambientTintStrength = (0.10 + (lighting.ambientIlluminance / 5.0) * 0.35).clamp(0.08, 0.45);
    final shadowContrast = (1.0 - lighting.skyIntensity * 0.62).clamp(0.28, 0.88);
    final grassLit = Color.lerp(
      isNight ? const Color(0xFF065F46) : const Color(0xFF7FA32C),
      activeLightColor,
      bright * 0.24,
    )!;
    final grassFore = Color.lerp(
      isNight ? const Color(0xFF064E3B) : const Color(0xFF5D7F1F),
      lighting.ambientColor,
      ambientTintStrength * 0.22,
    )!;
    final grassHorizonTint = Color.lerp(grassLit, skyHorizon, 0.30)!;
    final dirtBase = isNight ? const Color(0xFF292524) : const Color(0xFF78350F);

    // Wide contoured grassy plateau receding smoothly to the misty horizon
    final meadowPath = Path()
      ..moveTo(0, horizonY + 12)
      ..lineTo(w * 0.24, horizonY + 4)
      ..lineTo(w * 0.62, horizonY - 2)
      ..lineTo(w, horizonY + 9)
      ..lineTo(w, h)
      ..lineTo(0, h)
      ..close();
    canvas.drawPath(
      meadowPath,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          stops: const [0.0, 0.28, 1.0],
          colors: [grassHorizonTint, grassLit, grassFore],
        ).createShader(Rect.fromLTWH(0, horizonY - 2, w, h - horizonY + 2)),
    );

    // Crisp pixelated grass surface mottling across the meadow plane
    final tuftLight = Paint()..color = Color.lerp(grassLit, Colors.white, 0.16)!.withValues(alpha: 0.48);
    final tuftDark = Paint()..color = Color.lerp(grassFore, const Color(0xFF052E16), 0.28)!.withValues(alpha: 0.42);
    for (int row = 0; row < 5; row++) {
      final y = horizonY + 6.0 + row * 7.5;
      final stepX = 11.0 + row * 2.5;
      for (double x = (row * 5) % stepX; x < w * 0.78; x += stepX) {
        final isAlt = (((x / stepX).floor() + row) % 3) == 0;
        canvas.drawRect(
          Rect.fromLTWH(x, y, 4.5 + row * 0.7, 2.5),
          isAlt ? tuftLight : tuftDark,
        );
      }
    }

    // Foreground Minecraft Grass & Dirt Block Border Strip + Pond on the far right
    const bs = 16.0;
    final foreY = h - 18.0;
    final grassCols = ((w * 0.78) / bs).ceil();
    for (int col = 0; col < grassCols; col++) {
      final bx = col * bs;
      _drawMcBlockTile(
        canvas,
        Rect.fromLTWH(bx, foreY, bs + 0.4, h - foreY),
        kind: 'grass',
        baseColor: dirtBase,
        accentColor: grassLit,
        seed: col + 3,
      );
    }

    // Right Pond Shoreline & Animated Water
    final pondX = grassCols * bs;
    if (pondX < w) {
      final pondPath = Path()
        ..moveTo(pondX + 18, horizonY + 28)
        ..lineTo(w, horizonY + 22)
        ..lineTo(w, h)
        ..lineTo(pondX, h)
        ..close();
      canvas.drawPath(
        pondPath,
        Paint()
          ..shader = LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color.lerp(isNight ? const Color(0xFF1E3A8A) : const Color(0xFF0EA5E9), activeLightColor, 0.25 * bright)!,
              isNight ? const Color(0xFF020617) : const Color(0xFF0369A1),
            ],
          ).createShader(Rect.fromLTWH(pondX, horizonY + 22, w - pondX, h - horizonY)),
      );
      final waveShift = math.sin(t) * 4.0;
      canvas.drawRect(
        Rect.fromLTWH(pondX + 12 + waveShift, groundY + 12, 22, 2.2),
        Paint()..color = Color.lerp(Colors.white, activeLightColor, 0.4)!.withValues(alpha: 0.70 * bright),
      );
    }

    // 5. Directional Shadows cast by Ruins Block & 3D Oak Tree (Soft vs Blocky Texel)
    final sunLeftOfCenter = bodyPos.dx < w * 0.5;
    final dirX = sunLeftOfCenter ? 1.0 : -1.0;
    final horizFactor = ((bodyPos.dx - w * 0.5).abs() / (w * 0.42)).clamp(0.28, 1.35);
    final shadowLen = (28.0 + horizFactor * 40.0) * (0.85 + 0.25 * math.sin(rad).abs());
    final shadowBaseColor = Color.lerp(
      const Color(0xFF020617),
      lighting.ambientColor,
      ambientTintStrength * 0.55,
    )!.withValues(alpha: shadowContrast);

    final isBlocky = lighting.shadowStyle == 'blocky_shadows';
    final texelBlockPx = isBlocky
        ? (9.5 - (math.log(lighting.shadowTexelSize.clamp(1, 1024)) / math.ln10) * 2.45).clamp(1.6, 9.5)
        : 0.0;

    void drawCastShadow(double originX, double topY, double baseW, double castLen, double castH) {
      if (isBlocky) {
        final steps = (castH / texelBlockPx).ceil().clamp(2, 14);
        final rowH = castH / steps;
        final p = Paint()..color = shadowBaseColor;
        for (int i = 0; i < steps; i++) {
          final frac = i / steps;
          final xShift = dirX * frac * (castLen * 0.35);
          final left = dirX > 0 ? originX + xShift : originX + baseW + xShift - castLen;
          final qLeft = (left / texelBlockPx).round() * texelBlockPx;
          final qWidth = ((castLen - frac * 8) / texelBlockPx).round() * texelBlockPx;
          canvas.drawRect(
            Rect.fromLTWH(qLeft, topY + i * rowH, math.max(texelBlockPx, qWidth), rowH + 0.5),
            p,
          );
        }
      } else {
        final p = Paint()
          ..color = shadowBaseColor
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3.6);
        final path = Path()
          ..moveTo(originX, topY)
          ..lineTo(originX + baseW, topY)
          ..lineTo(originX + baseW + dirX * castLen, topY + castH)
          ..lineTo(originX + dirX * (castLen * 0.78), topY + castH)
          ..close();
        canvas.drawPath(path, p);
      }
    }

    final ruinsGroundY = groundY - 6.0;
    drawCastShadow(w * 0.12, ruinsGroundY - 2, 18, shadowLen * 0.72, 13);
    drawCastShadow(w * 0.45, groundY - 2, 34, shadowLen * 1.15, 16);

    // 6. Mossy Stone Brick Block Ruins on Left Ridge (catches directional sunlight vs ambient shadow)
    final litBrick = Color.lerp(const Color(0xFF64748B), activeLightColor, 0.25 * bright)!;
    final darkSideTint = Color.lerp(const Color(0xFF0F172A), lighting.ambientColor, ambientTintStrength * 0.4)!
        .withValues(alpha: shadowContrast * 0.72);
    final brickR = Rect.fromLTWH(w * 0.12, ruinsGroundY - 16.0, 18.0, 16.0);
    _drawMcBlockTile(canvas, brickR, kind: 'stoneBrick', baseColor: litBrick, seed: 1);
    canvas.drawRect(
      Rect.fromLTWH(sunLeftOfCenter ? brickR.right - 5 : brickR.left, brickR.top, 5, brickR.height),
      Paint()..color = darkSideTint,
    );
    _drawMcBlockTile(
      canvas,
      Rect.fromLTWH(w * 0.12 - 1.5, ruinsGroundY - 21.0, 21.0, 5.0),
      kind: 'grass',
      baseColor: const Color(0xFF475569),
      accentColor: isNight ? const Color(0xFF047857) : const Color(0xFF65A30D),
    );

    // 7. Hero 3D Isometric Perforated Minecraft Oak Tree + Wildflowers
    _drawMcUnitOakTree(
      canvas,
      cx: w * 0.49,
      groundY: groundY,
      u: 9.2,
      sunOnRight: !sunLeftOfCenter,
      trunkLit: isNight ? const Color(0xFF44403C) : const Color(0xFF78350F),
      trunkDark: const Color(0xFF291D14),
      leafLight: Color.lerp(isNight ? const Color(0xFF047857) : const Color(0xFF84CC16), activeLightColor, 0.22 * bright)!,
      leafMid: Color.lerp(isNight ? const Color(0xFF065F46) : const Color(0xFF4D7C0F), activeLightColor, 0.12 * bright)!,
      leafDark: Color.lerp(const Color(0xFF1A2E05), lighting.ambientColor, shadowContrast * 0.35)!,
    );
    // Poppy & Dandelion pixels in meadow
    canvas.drawRect(Rect.fromLTWH(w * 0.31, groundY - 4, 2, 4), Paint()..color = const Color(0xFF16A34A));
    canvas.drawRect(Rect.fromLTWH(w * 0.305, groundY - 6.5, 3.5, 2.5), Paint()..color = const Color(0xFFEF4444));
    canvas.drawRect(Rect.fromLTWH(w * 0.69, groundY - 4, 2, 4), Paint()..color = const Color(0xFF16A34A));
    canvas.drawRect(Rect.fromLTWH(w * 0.685, groundY - 6.5, 3.5, 2.5), Paint()..color = const Color(0xFFFACC15));
  }

  void _drawCaveScene(Canvas canvas, double w, double h) {
    // Perceptual response across 0.0..5.0 lux Cave Brightness curve + ambientColor tint (strictly ZERO torches!)
    final illumNorm = math.pow((lighting.ambientIlluminance / 5.0).clamp(0.0, 1.0), 0.44).clamp(0.06, 1.0).toDouble();
    final tint = lighting.ambientColor;
    final desat = lighting.emissiveDesaturation;

    // 1. Deep receding perspective cave backdrop
    canvas.drawRect(
      Rect.fromLTWH(0, 0, w, h),
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color.lerp(const Color(0xFF03050A), tint, illumNorm * 0.24)!,
            Color.lerp(const Color(0xFF0B111E), tint, illumNorm * 0.45)!,
          ],
        ).createShader(Rect.fromLTWH(0, 0, w, h)),
    );

    final backStone = Color.lerp(const Color(0xFF111827), tint, illumNorm * 0.30)!;
    final stoneTop = Color.lerp(const Color(0xFF475569), tint, 0.22 + illumNorm * 0.42)!;
    final stoneLit = Color.lerp(const Color(0xFF334155), tint, 0.16 + illumNorm * 0.40)!;
    final stoneDark = Color.lerp(const Color(0xFF1A2232), tint, illumNorm * 0.32)!;
    final deepDark = Color.lerp(const Color(0xFF0C111B), tint, illumNorm * 0.24)!;
    final rimLight = Color.lerp(const Color(0xFF64748B), tint, 0.30 + illumNorm * 0.48)!;

    // Back wall recessed arched blocks leaving deep cavern void behind central pillar
    const bs = 14.0;
    final cols = (w / bs).ceil();
    for (int col = 1; col < cols - 1; col++) {
      for (int row = 1; row < 8; row++) {
        // Keep central deep chamber passage darker behind the stone pillar & left/right wings
        final inRecess = col >= (cols * 0.26).round() && col <= (cols * 0.74).round() && row >= 2 && row <= 7;
        if (inRecess) continue;
        _drawMcBlockTile(
          canvas,
          Rect.fromLTWH(col * bs, row * bs, bs + 0.4, bs + 0.4),
          kind: row >= 5 ? 'deepslate' : 'stone',
          baseColor: backStone,
          lightEdge: Color.lerp(backStone, tint, 0.12 + illumNorm * 0.18),
          darkEdge: const Color(0xFF030508),
          seed: col * 3 + row,
        );
      }
    }

    // 2. Ambient volumetric underground haze fill driven by ambientIlluminance & ambientColor
    canvas.drawCircle(
      Offset(w * 0.50, h * 0.52),
      w * 0.50,
      Paint()
        ..shader = RadialGradient(
          colors: [
            tint.withValues(alpha: illumNorm * 0.52),
            tint.withValues(alpha: 0.0),
          ],
        ).createShader(Rect.fromCircle(center: Offset(w * 0.50, h * 0.52), radius: w * 0.50)),
    );

    // 3. Perspective Stepped Stone Floor (`h * 0.75..h`) & Central Water Pool
    final floorY = h * 0.75;
    canvas.drawRect(
      Rect.fromLTWH(0, floorY, w, h - floorY),
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [stoneDark, stoneLit],
        ).createShader(Rect.fromLTWH(0, floorY, w, h - floorY)),
    );
    // Perspective floor block grid lines
    final seamPaint = Paint()..color = deepDark.withValues(alpha: 0.75);
    for (int r = 0; r < 3; r++) {
      final fy = floorY + r * 12.0;
      canvas.drawRect(Rect.fromLTWH(0, fy, w, 1.0), seamPaint);
    }
    for (int c = 0; c < 12; c++) {
      final topX = w * (0.06 + c * 0.08);
      final botX = w * (-0.06 + c * 0.105);
      canvas.drawLine(Offset(topX, floorY), Offset(botX, h), seamPaint..strokeWidth = 1.0);
    }

    // Central shallow water pool wrapping around pillar base (stone-stepped pixels)
    final poolCenter = Offset(w * 0.49, h * 0.855);
    final poolDark = Color.lerp(const Color(0xFF082F49), tint, 0.34 + illumNorm * 0.36)!;
    final poolRim = Color.lerp(const Color(0xFF0E7490), tint, 0.42 + illumNorm * 0.38)!;
    final poolRect = Rect.fromCenter(center: poolCenter, width: w * 0.44, height: 18);
    canvas.drawRect(poolRect, Paint()..color = poolDark);
    canvas.drawRect(Rect.fromCenter(center: poolCenter, width: w * 0.34, height: 22), Paint()..color = poolDark);
    canvas.drawRect(Rect.fromLTWH(poolRect.left + 12, poolRect.top + 3, w * 0.14, 2.0), Paint()..color = poolRim);
    canvas.drawRect(Rect.fromLTWH(poolRect.right - 48, poolRect.bottom - 5, w * 0.11, 2.0), Paint()..color = poolRim);

    // 4. Receding 3D Stepped Cave Side Walls & Ceiling + Embedded Glowing Ores
    final diamondOre = _desaturateVVColor(const Color(0xFF38BDF8), desat);
    final emeraldOre = _desaturateVVColor(const Color(0xFF22C55E), desat);
    final amethystOre = _desaturateVVColor(const Color(0xFFC084FC), desat);

    for (int col = 0; col < cols; col++) {
      final edgeDist = math.min(col, cols - 1 - col);
      final ceilRows = edgeDist <= 1 ? 3 : (edgeDist <= 3 ? 2 : 1);
      for (int row = 0; row < ceilRows; row++) {
        _drawMcBlockTile(
          canvas,
          Rect.fromLTWH(col * bs, row * bs, bs + 0.4, bs + 0.4),
          kind: 'stone',
          baseColor: row == 0 ? stoneDark : stoneLit,
          lightEdge: rimLight,
          seed: col + row * 7,
        );
      }
      if (col < 2 || col >= cols - 2) {
        final maxWallRow = (floorY / bs).floor();
        for (int row = ceilRows; row < maxWallRow; row++) {
          final isDiamond = col == 1 && row == 4;
          final isAmethyst = col == cols - 2 && row == 4;
          final isEmerald = col == 1 && row == 6;
          final oreCol = isDiamond
              ? diamondOre
              : isAmethyst
                  ? amethystOre
                  : isEmerald
                      ? emeraldOre
                      : null;
          _drawMcBlockTile(
            canvas,
            Rect.fromLTWH(col * bs, row * bs, bs + 0.4, bs + 0.4),
            kind: oreCol != null ? 'ore' : (row >= 5 ? 'deepslate' : 'stone'),
            baseColor: row >= 5 ? deepDark : stoneLit,
            accentColor: oreCol,
            lightEdge: rimLight,
            seed: col * 5 + row,
          );
        }
      }
    }

    // Protruding 3D stepped rock ledges flanking left & right cave walls
    _drawIsoPrism(
      canvas,
      bottomCenter: Offset(bs * 2.2, floorY - 2),
      halfW: 15,
      depthY: 5,
      height: 44,
      topColor: stoneTop,
      leftColor: stoneLit,
      rightColor: stoneDark,
    );
    _drawIsoPrism(
      canvas,
      bottomCenter: Offset(w - bs * 2.2, floorY - 2),
      halfW: 16,
      depthY: 5,
      height: 50,
      topColor: stoneTop,
      leftColor: stoneLit,
      rightColor: stoneDark,
    );

    // 5. Iconic Central Stepped Stone Cave Pillar Column (rising from the water pool to the arched ceiling!)
    final pillarX = w * 0.49;
    final pillarBaseY = h * 0.84;
    _drawIsoPrism(
      canvas,
      bottomCenter: Offset(pillarX, pillarBaseY),
      halfW: 18,
      depthY: 6.5,
      height: pillarBaseY - bs * 0.8,
      topColor: stoneTop,
      leftColor: stoneLit,
      rightColor: stoneDark,
    );
    // Stepped protruding stone ribs mid-column (signature chunky Minecraft cave pillar shape)
    _drawIsoPrism(
      canvas,
      bottomCenter: Offset(pillarX - 13, pillarBaseY - 38),
      halfW: 10,
      depthY: 4,
      height: 28,
      topColor: stoneTop,
      leftColor: rimLight,
      rightColor: stoneDark,
    );
    _drawIsoPrism(
      canvas,
      bottomCenter: Offset(pillarX + 13, pillarBaseY - 46),
      halfW: 10,
      depthY: 4,
      height: 30,
      topColor: stoneTop,
      leftColor: stoneLit,
      rightColor: deepDark,
    );
    _drawIsoPrism(
      canvas,
      bottomCenter: Offset(pillarX, pillarBaseY - 76),
      halfW: 22,
      depthY: 7,
      height: 26,
      topColor: stoneTop,
      leftColor: rimLight,
      rightColor: stoneDark,
    );

    // 6. Lush Hanging Cave Leaf Clusters, Vines & Tall Cave Grass (dimmed naturally by cave light!)
    final mossLight = Color.lerp(const Color(0xFF4D7C0F), tint, illumNorm * 0.24)!;
    final mossMid = Color.lerp(const Color(0xFF365314), tint, illumNorm * 0.18)!;
    final mossDark = Color.lerp(const Color(0xFF1A2E05), tint, illumNorm * 0.10)!;

    void drawLeafBunch(double cx, double cy, double bw, double bh, int vineLen) {
      canvas.drawRect(Rect.fromCenter(center: Offset(cx, cy), width: bw, height: bh), Paint()..color = mossDark);
      canvas.drawRect(Rect.fromLTWH(cx - bw * 0.44, cy - bh * 0.42, bw * 0.46, bh * 0.45), Paint()..color = mossLight);
      canvas.drawRect(Rect.fromLTWH(cx, cy - bh * 0.25, bw * 0.42, bh * 0.50), Paint()..color = mossMid);
      canvas.drawRect(Rect.fromLTWH(cx - bw * 0.28, cy + bh * 0.10, bw * 0.40, bh * 0.35), Paint()..color = mossLight);
      if (vineLen > 0) {
        canvas.drawRect(Rect.fromLTWH(cx - bw * 0.3, cy + bh * 0.48, 2.5, vineLen.toDouble()), Paint()..color = mossMid);
        canvas.drawRect(Rect.fromLTWH(cx + bw * 0.2, cy + bh * 0.48, 2.5, (vineLen * 0.72)), Paint()..color = mossLight);
      }
    }

    drawLeafBunch(w * 0.19, bs * 1.9, 26, 18, 16);
    drawLeafBunch(w * 0.31, bs * 1.4, 24, 16, 20);
    drawLeafBunch(pillarX - 16, bs * 2.5, 22, 16, 14);
    drawLeafBunch(pillarX + 18, bs * 2.1, 24, 16, 18);
    drawLeafBunch(w * 0.69, bs * 1.4, 24, 16, 15);
    drawLeafBunch(w * 0.82, bs * 1.9, 26, 18, 14);

    // Tall cave grass along lower side wall ledges
    for (int i = 0; i < 6; i++) {
      final gxL = bs * 2.2 + i * 5.0;
      final gh = (i % 2 == 0) ? 9.0 : 6.0;
      canvas.drawRect(Rect.fromLTWH(gxL, floorY - gh, 2.2, gh), Paint()..color = mossMid);
      final gxR = w - bs * 2.2 - 30 + i * 5.0;
      canvas.drawRect(Rect.fromLTWH(gxR, floorY - gh, 2.2, gh), Paint()..color = mossMid);
    }

    // 7. Red & Brown Cave Mushrooms by the Water Pool + Ore Blooms & Underground Spores (NO torches!)
    final stemCol = Color.lerp(const Color(0xFFD6D3D1), tint, illumNorm * 0.30)!;
    // Brown mushroom left of pillar
    canvas.drawRect(Rect.fromLTWH(pillarX - 36, pillarBaseY - 7, 3, 7), Paint()..color = stemCol);
    canvas.drawRect(Rect.fromLTWH(pillarX - 39, pillarBaseY - 11, 9, 4.5), Paint()..color = const Color(0xFF78350F));
    // Red spotted mushroom right of pillar
    canvas.drawRect(Rect.fromLTWH(pillarX + 34, pillarBaseY - 8, 3, 8), Paint()..color = stemCol);
    canvas.drawRect(Rect.fromLTWH(pillarX + 30.5, pillarBaseY - 12.5, 10, 5), Paint()..color = const Color(0xFFDC2626));
    canvas.drawRect(Rect.fromLTWH(pillarX + 32, pillarBaseY - 11.5, 2, 2), Paint()..color = Colors.white.withValues(alpha: 0.85));
    canvas.drawRect(Rect.fromLTWH(pillarX + 36.5, pillarBaseY - 10.5, 2, 2), Paint()..color = Colors.white.withValues(alpha: 0.85));

    final lichenColor = _desaturateVVColor(const Color(0xFF6EE7B7), desat);
    for (final orePos in [
      (pos: Offset(bs * 1.5, bs * 4.5), col: diamondOre),
      (pos: Offset(bs * (cols - 1.5), bs * 4.5), col: amethystOre),
      (pos: Offset(bs * 1.5, bs * 6.5), col: emeraldOre),
    ]) {
      canvas.drawCircle(
        orePos.pos,
        16,
        Paint()
          ..shader = RadialGradient(
            colors: [orePos.col.withValues(alpha: 0.34), orePos.col.withValues(alpha: 0.0)],
          ).createShader(Rect.fromCircle(center: orePos.pos, radius: 16)),
      );
    }
    final drift = math.sin(motion * math.pi * 2) * 5.0;
    canvas.drawRect(Rect.fromLTWH(w * 0.36 + drift, h * 0.48, 2.5, 2.5), Paint()..color = lichenColor.withValues(alpha: 0.62));
    canvas.drawRect(Rect.fromLTWH(w * 0.64 - drift, h * 0.56, 2.0, 2.0), Paint()..color = tint.withValues(alpha: 0.58));
  }

  void _drawBlockLightsScene(Canvas canvas, double w, double h) {
    const kinds = ['torch', 'lantern', 'soul', 'candle', 'redstone', 'end_rod', 'copper'];
    final idx = activeLightGroupIndex.clamp(0, kinds.length - 1);
    final groups = [
      lighting.torches,
      lighting.lanterns,
      lighting.soulFire,
      lighting.candles,
      lighting.redstone,
      lighting.endRod,
      lighting.copper,
    ];
    final activeGroup = groups[idx];
    final rawColor = (idx == 4 && lighting.syncWarmToTorch)
        ? lighting.torches.color
        : activeGroup.color;
    final lightColor = _desaturateVVColor(rawColor, lighting.emissiveDesaturation);
    final isPoint = activeGroup.isPointLight;
    final flicker = math.sin(motion * math.pi * 6);

    final ambNorm = math.pow((lighting.ambientIlluminance / 5.0).clamp(0.0, 1.0), 0.45).clamp(0.05, 0.75).toDouble();
    final roomWallBase = Color.lerp(const Color(0xFF0E131C), lighting.ambientColor, ambNorm * 0.42)!;
    final roomMortar = Color.lerp(const Color(0xFF06090E), lighting.ambientColor, ambNorm * 0.25)!;

    const bs = 18.0;
    final floorY = h - 34.0;
    final kind = kinds[idx];
    const hangLength = 34.0;
    const u = 5.2;
    final emitterOffset = kind == 'lantern'
        ? Offset(w * 0.50, bs + hangLength + u * 4.6)
        : Offset(w * 0.50, floorY - 36.0);
    final pointRadius = isPoint ? w * 0.56 : w * 0.24;
    final brickStrength = isPoint ? 0.94 : 0.28;

    // 1. Stone Brick Workshop Wall reacting per-brick to radial point light
    _drawVVStoneBricks(
      canvas,
      Rect.fromLTWH(0, bs, w, floorY - bs),
      brickW: 22.0,
      brickH: 13.0,
      baseColor: roomWallBase,
      mortarColor: roomMortar,
      lightTint: lightColor,
      lightPos: emitterOffset,
      lightRadius: pointRadius,
      lightStrength: brickStrength,
    );

    // 2. Real Oak Log Ceiling Beam Row (`y = 0..18`)
    final cols = (w / bs).ceil();
    for (int col = 0; col < cols; col++) {
      final litMix = isPoint ? (1.0 - ((col * bs + 9 - emitterOffset.dx).abs() / pointRadius)).clamp(0.0, 1.0) * 0.30 : 0.04;
      _drawMcBlockTile(
        canvas,
        Rect.fromLTWH(col * bs, 0, bs + 0.4, bs),
        kind: 'log',
        baseColor: Color.lerp(const Color(0xFF3E2717), lightColor, litMix)!,
        seed: col,
      );
    }

    // 3. Left framing Stone Brick Pillar (`2 blocks` tall on far left)
    for (int row = 0; row < 2; row++) {
      _drawMcBlockTile(
        canvas,
        Rect.fromLTWH(bs * 0.5, floorY - (row + 1) * bs, bs, bs),
        kind: 'stoneBrick',
        baseColor: Color.lerp(const Color(0xFF1F2937), lightColor, isPoint ? 0.16 : 0.04)!,
        seed: row + 2,
      );
    }

    // 4. Real Oak Wood Plank Floor Row (`y = floorY..h`)
    for (int col = 0; col < cols; col++) {
      final d = (col * bs + 9 - emitterOffset.dx).abs();
      final glowBounce = isPoint ? (1.0 - d / pointRadius).clamp(0.0, 1.0) * 0.40 : 0.06;
      final plankColor = Color.lerp(
        Color.lerp(const Color(0xFF4A2E1B), lighting.ambientColor, ambNorm * 0.25)!,
        lightColor,
        glowBounce,
      )!;
      _drawMcBlockTile(
        canvas,
        Rect.fromLTWH(col * bs, floorY, bs + 0.4, h - floorY),
        kind: 'plank',
        baseColor: plankColor,
        seed: col,
      );
    }

    // 5. Radial Point-Light Bloom & Floor Bounce Pool
    final poolPulse = isPoint ? (1.0 + 0.045 * flicker) : (1.0 + 0.02 * flicker);
    final poolRadius = (isPoint ? w * 0.48 : w * 0.19) * poolPulse;
    canvas.drawCircle(
      emitterOffset,
      poolRadius,
      Paint()
        ..shader = RadialGradient(
          stops: const [0.0, 0.35, 1.0],
          colors: [
            lightColor.withValues(alpha: isPoint ? 0.60 : 0.36),
            lightColor.withValues(alpha: isPoint ? 0.22 : 0.08),
            lightColor.withValues(alpha: 0.0),
          ],
        ).createShader(Rect.fromCircle(center: emitterOffset, radius: poolRadius)),
    );

    final floorGlowW = isPoint ? w * 0.54 : w * 0.22;
    canvas.drawOval(
      Rect.fromCenter(center: Offset(w * 0.5, floorY + 7), width: floorGlowW, height: 12),
      Paint()
        ..shader = RadialGradient(
          colors: [
            lightColor.withValues(alpha: isPoint ? 0.45 : 0.18),
            lightColor.withValues(alpha: 0.0),
          ],
        ).createShader(Rect.fromCenter(center: Offset(w * 0.5, floorY + 7), width: floorGlowW, height: 12)),
    );

    // 6. Right Wooden Barrel/Crate Block receiving dynamic Point Light rim & casting floor shadow
    final crateSize = 22.0;
    final crateRect = Rect.fromLTWH(w * 0.78, floorY - crateSize, crateSize, crateSize);
    if (isPoint) {
      canvas.drawPath(
        Path()
          ..moveTo(crateRect.right, floorY)
          ..lineTo(crateRect.right + 38, floorY + 9)
          ..lineTo(crateRect.right + 28, floorY + 13)
          ..lineTo(crateRect.left + 8, floorY)
          ..close(),
        Paint()..color = const Color(0xFF020617).withValues(alpha: 0.72),
      );
    }
    _drawMcBlockTile(
      canvas,
      crateRect,
      kind: 'crate',
      baseColor: const Color(0xFF6B3E21),
      lightEdge: const Color(0xFF92552D),
      darkEdge: const Color(0xFF3B1F0E),
    );
    // Warm lit edge facing emitter
    canvas.drawRect(
      Rect.fromLTWH(crateRect.left, crateRect.top, 3.0, crateSize),
      Paint()..color = Color.lerp(const Color(0xFF92552D), lightColor, isPoint ? 0.65 : 0.20)!,
    );

    // 7. Chiseled Stone Slab Pedestal under standing items (Lantern hangs from Oak Log ceiling!)
    const pedH = 8.0;
    if (kind != 'lantern') {
      _drawMcBlockTile(
        canvas,
        Rect.fromLTWH(w * 0.50 - 28, floorY - pedH, 56, pedH),
        kind: 'stoneBrick',
        baseColor: Color.lerp(const Color(0xFF334155), lightColor, isPoint ? 0.22 : 0.06)!,
        seed: 1,
      );
    }

    // 8. Authentic Minecraft Block Light Item centered front-and-center!
    if (kind == 'lantern') {
      _drawVoxelBlockLightItem(
        canvas,
        'lantern',
        Offset(w * 0.50, bs),
        u,
        rawColor,
        flicker: flicker,
        desaturation: lighting.emissiveDesaturation,
        hangLength: hangLength,
      );
      // Companion Minecraft Torch resting on the right wooden crate shelf
      _drawVoxelBlockLightItem(
        canvas,
        'torch',
        Offset(w * 0.78 + 11.0, floorY - crateSize),
        3.2,
        lighting.torches.color,
        flicker: flicker,
        desaturation: lighting.emissiveDesaturation,
      );
    } else {
      _drawVoxelBlockLightItem(
        canvas,
        kind,
        Offset(w * 0.50, floorY - pedH),
        u,
        rawColor,
        flicker: flicker,
        desaturation: lighting.emissiveDesaturation,
        includeCompanionProps: true,
        syncMystic: lighting.syncMysticToSoul,
      );
      // Companion Minecraft hanging lantern on left oak ceiling beam
      _drawVoxelBlockLightItem(
        canvas,
        'lantern',
        Offset(w * 0.22, bs),
        3.6,
        lighting.lanterns.color,
        flicker: flicker,
        desaturation: lighting.emissiveDesaturation,
        hangLength: 22.0,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _VVLightingPreviewPainter old) =>
      old.mode != mode ||
      old.lighting != lighting ||
      old.sunPhase != sunPhase ||
      old.activeLightGroupIndex != activeLightGroupIndex ||
      old.motion != motion;
}

/// Tab 2: Fog & Air Live Preview (Air Fog / Weather Fog / Underwater Fog)
class VVFogPreviewBanner extends StatelessWidget {
  final int mode; // 0 = Air, 1 = Weather, 2 = Underwater
  final FogConfig fog;

  const VVFogPreviewBanner({
    super.key,
    required this.mode,
    required this.fog,
  });

  @override
  Widget build(BuildContext context) {
    return VVPreviewFrame(
      badgeText: null,
      child: _VVReactiveMotion(
        continuous: true,
        signal: Object.hash(mode, fog),
        builder: (context, motion) => CustomPaint(
          painter: _VVFogPreviewPainter(
            mode: mode,
            fog: fog,
            motion: motion,
          ),
        ),
      ),
    );
  }
}

class _VVFogPreviewPainter extends CustomPainter {
  final int mode;
  final FogConfig fog;
  final double motion;

  const _VVFogPreviewPainter({
    required this.mode,
    required this.fog,
    this.motion = 0.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    if (mode == 2) {
      _drawUnderwaterFogScene(canvas, w, h);
    } else if (mode == 1) {
      _drawWeatherFogScene(canvas, w, h);
    } else {
      _drawAirFogScene(canvas, w, h);
    }
  }

  void _drawAirFogScene(Canvas canvas, double w, double h) {
    final t = motion * math.pi * 2.0;
    final fogCol = fog.airFogColor;
    final endNorm = fog.airFogEnd.clamp(0.1, 1.0);
    final startNorm = fog.airFogStart.clamp(0.05, 0.99);
    final mistDensity = ((fog.volumetricMaxDensity - 0.002) / 0.248).clamp(0.0, 1.0);
    final scatterCol = fog.hazeScatteringColor;

    // 1. Pale Misty Overworld Sky fading softly into atmospheric horizon fog
    final horizonY = h * 0.44;
    canvas.drawRect(
      Rect.fromLTWH(0, 0, w, horizonY + 14),
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          stops: const [0.0, 0.52, 1.0],
          colors: [
            Color.lerp(const Color(0xFF64748B), fogCol, 0.45)!,
            Color.lerp(const Color(0xFF94A3B8), fogCol, 0.72)!,
            fogCol,
          ],
        ).createShader(Rect.fromLTWH(0, 0, w, horizonY + 14)),
    );

    // Atmospheric haze scattering glow along horizon (responsive to hazeScatteringColor & startNorm)
    final hazeGlowAlpha = (0.16 + (1.0 - startNorm) * 0.26).clamp(0.10, 0.45);
    canvas.drawRect(
      Rect.fromLTWH(0, horizonY - 22, w, 32),
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            scatterCol.withValues(alpha: 0.0),
            scatterCol.withValues(alpha: hazeGlowAlpha),
          ],
        ).createShader(Rect.fromLTWH(0, horizonY - 22, w, 32)),
    );

    // 2. Far Mountain Headwall Silhouettes across distant canyon (responsive to airFogEnd)
    final farFogMix = (0.97 - endNorm * 0.52).clamp(0.42, 0.97);
    final farSlope = Color.lerp(const Color(0xFF334155), fogCol, farFogMix)!;
    for (final pk in const [
      (x: 0.12, pw: 68.0, ph: 26.0),
      (x: 0.32, pw: 96.0, ph: 38.0),
      (x: 0.56, pw: 82.0, ph: 30.0),
      (x: 0.78, pw: 74.0, ph: 24.0),
    ]) {
      canvas.drawRect(Rect.fromLTWH(w * pk.x, horizonY - pk.ph * 0.45, pk.pw, pk.ph * 0.45 + 12), Paint()..color = farSlope);
      canvas.drawRect(Rect.fromLTWH(w * pk.x + pk.pw * 0.22, horizonY - pk.ph, pk.pw * 0.56, pk.ph * 0.55), Paint()..color = farSlope);
      canvas.drawRect(Rect.fromLTWH(w * pk.x + pk.pw * 0.40, horizonY - pk.ph - 6, pk.pw * 0.20, 6), Paint()..color = farSlope);
    }

    // 3. Midground Stepped Canyon Slopes & Faded Spruce Trees across the gorge (responsive to airFogEnd & airFogStart)
    final midFogMix = (0.88 - endNorm * 0.40 - startNorm * 0.18).clamp(0.25, 0.88);
    final midDirt = Color.lerp(const Color(0xFF573926), fogCol, midFogMix)!;
    final midGrass = Color.lerp(const Color(0xFF3F6212), fogCol, midFogMix)!;
    final midTrunk = Color.lerp(const Color(0xFF3E2717), fogCol, midFogMix)!;
    final midNeedleLight = Color.lerp(const Color(0xFF15803D), fogCol, midFogMix)!;
    final midNeedleMid = Color.lerp(const Color(0xFF166534), fogCol, midFogMix)!;
    final midNeedleDark = Color.lerp(const Color(0xFF14532D), fogCol, midFogMix)!;

    // Distant canyon rim terrace stepping across center
    final midY = h * 0.52;
    for (int i = 0; i < 8; i++) {
      final bx = w * 0.26 + i * 16.0;
      final stepDown = (i >= 3 ? (i - 3) * 3.5 : 0.0);
      _drawMcBlockTile(canvas, Rect.fromLTWH(bx, midY + stepDown, 16.4, 12), kind: 'grass', baseColor: midDirt, accentColor: midGrass, seed: i + 2);
    }
    // Midground spruce trees along far canyon slopes
    _drawMcSpruceTree(canvas, cx: w * 0.33, groundY: midY, u: 3.2, trunkColor: midTrunk, needleLight: midNeedleLight, needleMid: midNeedleMid, needleDark: midNeedleDark);
    _drawMcSpruceTree(canvas, cx: w * 0.42, groundY: midY + 4, u: 3.8, trunkColor: midTrunk, needleLight: midNeedleLight, needleMid: midNeedleMid, needleDark: midNeedleDark);
    _drawMcSpruceTree(canvas, cx: w * 0.50, groundY: midY + 11, u: 2.8, trunkColor: midTrunk, needleLight: midNeedleLight, needleMid: midNeedleMid, needleDark: midNeedleDark);
    _drawMcSpruceTree(canvas, cx: w * 0.58, groundY: midY + 14, u: 3.4, trunkColor: midTrunk, needleLight: midNeedleLight, needleMid: midNeedleMid, needleDark: midNeedleDark);

    // 4. Deep Receding Canyon Gorge Floor
    final gorgeY = h * 0.60;
    final deepStone = Color.lerp(const Color(0xFF1E293B), fogCol, 0.45)!;
    canvas.drawRect(
      Rect.fromLTWH(w * 0.20, gorgeY, w * 0.60, h - gorgeY),
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [deepStone, Color.lerp(deepStone, Colors.black, 0.45)!],
        ).createShader(Rect.fromLTWH(w * 0.20, gorgeY, w * 0.60, h - gorgeY)),
    );

    // 5. Dense Volumetric Ground Mist Pool in the canyon basin (controlled by volumetricMaxDensity & hazeScatteringColor)
    final mistTopY = h * (0.84 - mistDensity * 0.36); // rises up to h*0.48 at max density!
    final mistCol = Color.lerp(fogCol, scatterCol, 0.40)!;
    final mistAlpha = (0.25 + mistDensity * 0.70).clamp(0.18, 0.95);

    // Base mist gradient filling the canyon
    canvas.drawRect(
      Rect.fromLTWH(0, mistTopY, w, h - mistTopY),
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          stops: const [0.0, 0.32, 1.0],
          colors: [
            mistCol.withValues(alpha: 0.0),
            mistCol.withValues(alpha: mistAlpha * 0.70),
            mistCol.withValues(alpha: mistAlpha),
          ],
        ).createShader(Rect.fromLTWH(0, mistTopY, w, h - mistTopY)),
    );

    // Layered rolling volumetric mist billows (responsive to motion & volumetricMaxDensity)
    final bSpeed1 = motion * w * 0.35;
    final billowPaint1 = Paint()..color = mistCol.withValues(alpha: mistAlpha * 0.55);
    for (int i = 0; i < 8; i++) {
      final bx = ((i * 56.0 + bSpeed1) % (w + 112.0)) - 56.0;
      final bw = 48.0 + (i % 3) * 14.0;
      final bh = (10.0 + (i % 2) * 8.0) * (0.5 + mistDensity * 0.7);
      final by = mistTopY + math.sin(t + i * 1.2) * 3.5;
      canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(bx, by, bw, bh), const Radius.circular(6.0)), billowPaint1);
    }
    final bSpeed2 = motion * w * 0.60;
    final billowPaint2 = Paint()..color = Color.lerp(mistCol, scatterCol, 0.5)!.withValues(alpha: mistAlpha * 0.40);
    for (int i = 0; i < 7; i++) {
      final bx = (((i * 64.0 + 32.0 + bSpeed2) % (w + 128.0)) - 64.0);
      final bw = 54.0 + (i % 3) * 12.0;
      final bh = (12.0 + (i % 3) * 6.0) * (0.5 + mistDensity * 0.8);
      final by = mistTopY + 12.0 + math.cos(t * 1.3 + i) * 4.0;
      canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(bx, by, bw, bh), const Radius.circular(7.0)), billowPaint2);
    }

    // Floating atmospheric mist spores drifting through the gorge
    final sporePaint = Paint()..color = Color.lerp(Colors.white, scatterCol, 0.5)!.withValues(alpha: 0.40);
    for (int i = 0; i < 8; i++) {
      final sx = (w * (i * 0.13 + 0.05) + motion * 34.0 + math.sin(t + i) * 6.0) % w;
      final sy = (h * (0.35 + (i * 0.07)) + math.cos(t * 1.5 + i) * 8.0) % h;
      canvas.drawRect(Rect.fromLTWH(sx, sy, 2.0, 2.0), sporePaint);
    }

    // 6. Left Stepped Dirt Cliff & Grassy Terrace (matching Reference Image 1)
    const bs = 16.0;
    final leftCliffCols = ((w * 0.36) / bs).ceil();
    final foreDirt = const Color(0xFF78350F);
    final foreGrass = const Color(0xFF4D7C0F);
    final foreStone = const Color(0xFF475569);

    for (int col = 0; col < leftCliffCols; col++) {
      final bx = col * bs;
      final cliffStep = (col >= 3 ? (col - 2) * 9.0 : 0.0);
      final topY = h * 0.56 + cliffStep;
      _drawMcBlockTile(
        canvas,
        Rect.fromLTWH(bx, topY, bs + 0.4, bs),
        kind: 'grass',
        baseColor: foreDirt,
        accentColor: foreGrass,
        seed: col,
      );
      _drawMcBlockTile(
        canvas,
        Rect.fromLTWH(bx, topY + bs, bs + 0.4, 22),
        kind: 'dirt',
        baseColor: foreDirt,
        seed: col + 11,
      );
      _drawMcBlockTile(
        canvas,
        Rect.fromLTWH(bx, topY + bs + 22, bs + 0.4, h - (topY + bs + 22)),
        kind: 'stone',
        baseColor: foreStone,
        seed: col + 19,
      );
    }

    // Hero Spruce Tree on the Left Cliff (with wind sway)
    final breezeSway = math.sin(t) * 1.8;
    _drawMcSpruceTree(
      canvas,
      cx: w * 0.16,
      groundY: h * 0.56,
      u: 5.6,
      trunkColor: const Color(0xFF451A03),
      needleLight: const Color(0xFF16A34A),
      needleMid: const Color(0xFF15803D),
      needleDark: const Color(0xFF14532D),
      wind: breezeSway,
    );

    // 7. Right Stepped Foreground Bluff & Prominent Spruce Trees (matching Reference Image 1)
    final rightStartX = w * 0.56;
    final rightCols = (((w - rightStartX) + bs) / bs).ceil();
    for (int col = 0; col < rightCols; col++) {
      final bx = rightStartX + col * bs;
      final stepUp = (col <= 2 ? (2 - col) * 8.0 : 0.0);
      final topY = h * 0.68 + stepUp;
      _drawMcBlockTile(
        canvas,
        Rect.fromLTWH(bx, topY, bs + 0.4, bs),
        kind: 'grass',
        baseColor: foreDirt,
        accentColor: foreGrass,
        seed: col + 5,
      );
      _drawMcBlockTile(
        canvas,
        Rect.fromLTWH(bx, topY + bs, bs + 0.4, h - (topY + bs)),
        kind: 'dirt',
        baseColor: foreDirt,
        seed: col + 17,
      );
    }

    // Tall Hero Spruce Tree on right bluff
    _drawMcSpruceTree(
      canvas,
      cx: w * 0.74,
      groundY: h * 0.68,
      u: 6.8,
      trunkColor: const Color(0xFF451A03),
      needleLight: const Color(0xFF22C55E),
      needleMid: const Color(0xFF16A34A),
      needleDark: const Color(0xFF14532D),
      wind: breezeSway * 1.2,
    );
    // Secondary spruce tree on right
    _drawMcSpruceTree(
      canvas,
      cx: w * 0.89,
      groundY: h * 0.68,
      u: 5.0,
      trunkColor: const Color(0xFF451A03),
      needleLight: const Color(0xFF16A34A),
      needleMid: const Color(0xFF15803D),
      needleDark: const Color(0xFF14532D),
      wind: breezeSway * 0.9,
    );

    // Near corner pine needles in bottom-right (matching Image 1)
    final nearNeedle = Paint()..color = const Color(0xFF14532D);
    final nearNeedleLit = Paint()..color = const Color(0xFF16A34A);
    canvas.drawRect(Rect.fromLTWH(w * 0.78, h - 22, w * 0.22, 22), nearNeedle);
    canvas.drawRect(Rect.fromLTWH(w * 0.82, h - 28, w * 0.18, 8), nearNeedleLit);
    canvas.drawRect(Rect.fromLTWH(w * 0.88, h - 34, w * 0.12, 8), nearNeedle);

    // 8. Near Atmospheric Fog Veil (responsive to airFogStart)
    // When airFogStart < 0.45, fog creeps directly into foreground!
    if (startNorm < 0.45) {
      final foreVeilAlpha = ((0.45 - startNorm) / 0.45 * 0.52).clamp(0.0, 0.52);
      canvas.drawRect(
        Rect.fromLTWH(0, 0, w, h),
        Paint()
          ..shader = LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              fogCol.withValues(alpha: foreVeilAlpha * 0.35),
              fogCol.withValues(alpha: foreVeilAlpha),
            ],
          ).createShader(Rect.fromLTWH(0, 0, w, h)),
      );
    }
  }

  void _drawUnderwaterFogScene(Canvas canvas, double w, double h) {
    final t = motion * math.pi * 2.0;
    final waterFogCol = fog.waterFogColor;
    final clarity = fog.caveWaterVisibility.clamp(0.0, 1.0);
    // waterFogEnd is 12..120 blocks
    final visNorm = ((fog.waterFogEnd - 12.0) / 108.0).clamp(0.0, 1.0);

    // 1. Deep Oceanic Water Column Gradient (responsive to waterFogColor & caveWaterVisibility)
    final surfaceCyan = Color.lerp(waterFogCol, const Color(0xFF38BDF8), 0.32 + clarity * 0.32)!;
    final deepAbyss = Color.lerp(waterFogCol, const Color(0xFF020919), 0.70 - clarity * 0.20)!;
    canvas.drawRect(
      Rect.fromLTWH(0, 0, w, h),
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          stops: const [0.0, 0.40, 1.0],
          colors: [surfaceCyan, waterFogCol, deepAbyss],
        ).createShader(Rect.fromLTWH(0, 0, w, h)),
    );

    // 2. Caustic Shimmer Light Shafts (responsive to caveWaterVisibility & ocean wave motion)
    final shaftAlpha = (0.05 + clarity * 0.28).clamp(0.04, 0.35);
    final causticPaint = Paint()
      ..color = Color.lerp(Colors.white, surfaceCyan, 0.35)!.withValues(alpha: shaftAlpha)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5.0);
    for (int i = 0; i < 5; i++) {
      final shaftX = w * (0.12 + i * 0.20) + math.sin(t + i * 1.4) * 10.0;
      final path = Path()
        ..moveTo(shaftX - 8, 0)
        ..lineTo(shaftX + 8, 0)
        ..lineTo(shaftX + 26, h * 0.88)
        ..lineTo(shaftX - 12, h * 0.88)
        ..close();
      canvas.drawPath(path, causticPaint);
    }

    // 3. Floating Suspended Water Bubbles / Particles drifting upward with horizontal wobble
    final bubblePaint = Paint()..color = Color.lerp(Colors.white, surfaceCyan, 0.35)!.withValues(alpha: 0.55);
    final bubbleRimPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.80)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.8;
    for (int i = 0; i < 11; i++) {
      final wobble = math.sin(t * 2.0 + i * 1.3) * 4.0;
      final bx = (w * (i * 0.09 + 0.06) + wobble) % (w - 12.0) + 6.0;
      final by = h * ((0.94 - ((i * 0.09 + motion * 0.32) % 0.88)));
      final bSize = (i % 3 == 0) ? 2.6 : (i % 2 == 0 ? 2.0 : 1.5);
      canvas.drawCircle(Offset(bx, by), bSize, bubblePaint);
      canvas.drawCircle(Offset(bx, by), bSize, bubbleRimPaint);
    }

    // 4. Distant Underwater Seabed Terraces fading into Oceanic Fog (controlled by waterFogEnd)
    // Low waterFogEnd (12 blk) = thick oceanic murky fog hiding distant seabed.
    // High waterFogEnd (120 blk) = sharp distant seabed terraces visible across wide ocean basin.
    final distantFogBlend = (0.96 - visNorm * 0.62).clamp(0.32, 0.96);
    final farGravel = Color.lerp(const Color(0xFF334155), waterFogCol, distantFogBlend)!;
    final farStone = Color.lerp(const Color(0xFF1E293B), waterFogCol, distantFogBlend)!;

    final farBedY = h * 0.54;
    for (int i = 0; i < 14; i++) {
      final bx = i * (w / 13.0);
      final step = (i % 4 == 0 ? 6.0 : (i % 3 == 0 ? -4.0 : 0.0));
      canvas.drawRect(
        Rect.fromLTWH(bx, farBedY + step, (w / 13.0) + 1.0, 18.0),
        Paint()..color = (i.isEven ? farGravel : farStone),
      );
    }

    // Distant Kelp silhouettes if visibility is high enough (visNorm > 0.30)
    if (visNorm > 0.30) {
      final farKelpAlpha = ((visNorm - 0.30) / 0.70 * 0.45).clamp(0.0, 0.45);
      final farKelpColor = Color.lerp(const Color(0xFF047857), waterFogCol, distantFogBlend)!.withValues(alpha: farKelpAlpha);
      for (final fk in const [0.38, 0.48, 0.62, 0.72]) {
        _drawMcKelpStalk(
          canvas,
          x: w * fk,
          baseY: farBedY + 4,
          height: h * 0.28,
          u: 2.2,
          kelpColor: farKelpColor,
          kelpDark: farKelpColor,
          sway: math.sin(t + fk * 3.0) * 0.6,
        );
      }
    }

    // 5. Stepped Minecraft Gravel, Sand & Stone Seabed Terraces (matching Reference Image 2)
    const bs = 16.0;
    final bedCols = (w / bs).ceil();
    final gravelBase = Color.lerp(const Color(0xFF475569), waterFogCol, 0.28 - clarity * 0.15)!;
    final gravelDark = Color.lerp(const Color(0xFF1E293B), waterFogCol, 0.25)!;
    final sandBase = Color.lerp(const Color(0xFF64748B), waterFogCol, 0.22 - clarity * 0.12)!;

    for (int col = 0; col < bedCols; col++) {
      final bx = col * bs;
      final centerDist = (col - bedCols * 0.5).abs();
      final terraceStep = (centerDist > 4 ? (centerDist - 4) * 5.0 : 0.0);
      final topY = h * 0.70 - terraceStep;

      // Top seabed block layer
      _drawMcBlockTile(
        canvas,
        Rect.fromLTWH(bx, topY, bs + 0.4, bs),
        kind: col % 5 == 0 ? 'dirt' : 'stone',
        baseColor: col % 3 == 0 ? sandBase : gravelBase,
        seed: col + 3,
      );
      // Lower seabed strata
      for (double subY = topY + bs; subY < h; subY += bs) {
        _drawMcBlockTile(
          canvas,
          Rect.fromLTWH(bx, subY, bs + 0.4, bs),
          kind: 'deepslate',
          baseColor: gravelDark,
          seed: (col + subY.toInt()),
        );
      }

      // Animated Caustic Shimmer Light Patches on Seabed Floor
      if (clarity > 0.15) {
        final shimmerAlpha = (clarity * 0.25 * (0.5 + 0.5 * math.sin(t * 2.2 + col * 0.75))).clamp(0.0, 0.32);
        canvas.drawRect(
          Rect.fromLTWH(bx, topY, bs + 0.4, 3.0),
          Paint()..color = Colors.white.withValues(alpha: shimmerAlpha),
        );
      }
    }

    // 6. Towering Minecraft Kelp Forest on the Left (matching Reference Image 2)
    final kelpColor = Color.lerp(const Color(0xFF059669), surfaceCyan, 0.18)!;
    final kelpDark = const Color(0xFF047857);
    final kelpStalks = [
      (x: w * 0.05, baseY: h * 0.65, height: h * 0.48, phase: 0.0),
      (x: w * 0.10, baseY: h * 0.68, height: h * 0.58, phase: 0.6),
      (x: w * 0.15, baseY: h * 0.70, height: h * 0.52, phase: 1.2),
      (x: w * 0.20, baseY: h * 0.70, height: h * 0.42, phase: 1.8),
    ];
    for (final k in kelpStalks) {
      final kSway = math.sin(t * 1.5 + k.phase);
      _drawMcKelpStalk(
        canvas,
        x: k.x,
        baseY: k.baseY,
        height: k.height,
        u: 3.8,
        kelpColor: kelpColor,
        kelpDark: kelpDark,
        sway: kSway,
      );
    }

    // 7. Lush Minecraft Seagrass Tufts along the seabed terraces (matching Reference Image 2)
    final grassLight = Color.lerp(const Color(0xFF22C55E), surfaceCyan, 0.16)!;
    final grassMid = const Color(0xFF16A34A);
    final grassTufts = [
      (x: w * 0.28, y: h * 0.70, isTall: true, phase: 0.2),
      (x: w * 0.35, y: h * 0.70, isTall: false, phase: 0.5),
      (x: w * 0.42, y: h * 0.70, isTall: true, phase: 0.8),
      (x: w * 0.50, y: h * 0.70, isTall: false, phase: 1.1),
      (x: w * 0.58, y: h * 0.70, isTall: true, phase: 1.4),
      (x: w * 0.68, y: h * 0.68, isTall: false, phase: 1.7),
      (x: w * 0.76, y: h * 0.65, isTall: true, phase: 2.0),
      (x: w * 0.85, y: h * 0.62, isTall: false, phase: 2.3),
      (x: w * 0.92, y: h * 0.60, isTall: true, phase: 2.6),
    ];
    for (final g in grassTufts) {
      final gSway = math.sin(t * 1.5 + g.phase);
      _drawMcSeagrass(
        canvas,
        x: g.x,
        baseY: g.y,
        u: 3.6,
        grassColor: grassLight,
        grassDark: grassMid,
        isTall: g.isTall,
        sway: gSway,
      );
    }

    // 8. Ocean Depth Absorption Fog Overlay (responsive to waterFogEnd)
    final depthVeilAlpha = (0.35 - visNorm * 0.25).clamp(0.08, 0.40);
    canvas.drawRect(
      Rect.fromLTWH(0, 0, w, h),
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            waterFogCol.withValues(alpha: 0.0),
            waterFogCol.withValues(alpha: depthVeilAlpha),
          ],
        ).createShader(Rect.fromLTWH(0, 0, w, h)),
    );
  }

  void _drawWeatherFogScene(Canvas canvas, double w, double h) {
    final t = motion * math.pi * 2.0;
    final stormCol = fog.weatherFogColor;
    final endNorm = fog.weatherFogEnd.clamp(0.1, 1.0);
    final startNorm = fog.weatherFogStart.clamp(0.05, 0.99);

    // Dynamic storm severity: low end & low start -> violent thunderstorm! High end -> gentle drizzle
    final stormSeverity = (1.0 - (endNorm - startNorm * 0.3)).clamp(0.08, 1.0);

    // Periodic sheet lightning flash during intense storms
    final lightningThreshold = (0.97 - stormSeverity * 0.04).clamp(0.90, 0.98);
    final isLightning = stormSeverity > 0.35 && (math.sin(t * 4.0) > lightningThreshold);
    final lightningFlash = isLightning ? (0.28 + stormSeverity * 0.40) : 0.0;

    // 1. Dark Moody Overcast Storm Sky (responsive to weatherFogColor & lightning)
    canvas.drawRect(
      Rect.fromLTWH(0, 0, w, h * 0.58),
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color.lerp(const Color(0xFF0F172A), Colors.white, lightningFlash)!,
            Color.lerp(const Color(0xFF1E293B), stormCol, 0.65 + lightningFlash * 0.25)!,
            Color.lerp(stormCol, Colors.white, lightningFlash * 0.60)!,
          ],
        ).createShader(Rect.fromLTWH(0, 0, w, h * 0.58)),
    );

    // Low-hanging dark stepped Minecraft storm clouds drifting along horizon
    final cloudDrift = motion * (w + 140) * (0.8 + stormSeverity * 0.8);
    final cloudCol = Color.lerp(const Color(0xFF1E293B), stormCol, 0.55)!;
    final cloudDark = const Color(0xFF0B132B);
    final cloudList = [
      (x: 0.04, y: 0.12, cw: 58.0, ch: 11.0),
      (x: 0.36, y: 0.06, cw: 76.0, ch: 14.0),
      (x: 0.68, y: 0.15, cw: 62.0, ch: 10.0),
      if (stormSeverity > 0.4) (x: 0.18, y: 0.20, cw: 84.0, ch: 12.0),
      if (stormSeverity > 0.6) (x: 0.52, y: 0.24, cw: 70.0, ch: 13.0),
    ];
    for (final c in cloudList) {
      final cx = ((w * c.x + cloudDrift) % (w + 140)) - 90;
      final cy = h * c.y;
      canvas.drawRect(Rect.fromLTWH(cx, cy, c.cw, c.ch), Paint()..color = cloudDark);
      canvas.drawRect(Rect.fromLTWH(cx + 6, cy - 4, c.cw * 0.65, 5), Paint()..color = cloudCol);
    }

    // 2. Far Storm Shrouded Mountains (responsive to weatherFogEnd)
    final farFogMix = (0.55 + stormSeverity * 0.42).clamp(0.50, 0.98);
    final farMtn = Color.lerp(const Color(0xFF1E293B), stormCol, farFogMix)!;
    final horY = h * 0.54;
    canvas.drawRect(Rect.fromLTWH(w * 0.14, horY - 24, 68, 24), Paint()..color = farMtn);
    canvas.drawRect(Rect.fromLTWH(w * 0.42, horY - 32, 88, 32), Paint()..color = farMtn);
    canvas.drawRect(Rect.fromLTWH(w * 0.70, horY - 26, 76, 26), Paint()..color = farMtn);

    // 3. Dense Distance Rain Fog Sheet (responsive to weatherFogEnd)
    final rainFogAlpha = (0.22 + stormSeverity * 0.68).clamp(0.15, 0.92);
    canvas.drawRect(
      Rect.fromLTWH(0, h * 0.36, w, h * 0.64),
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            stormCol.withValues(alpha: 0.0),
            stormCol.withValues(alpha: rainFogAlpha * 0.70),
            stormCol.withValues(alpha: rainFogAlpha),
          ],
        ).createShader(Rect.fromLTWH(0, h * 0.36, w, h * 0.64)),
    );

    // 4. Wet Stepped Minecraft Terrain with Water Puddles
    const bs = 16.0;
    final cols = (w / bs).ceil();
    final wetDirt = const Color(0xFF451A03);
    final wetGrass = Color.lerp(const Color(0xFF3F6212), stormCol, 0.22)!;
    final groundY = h * 0.70;

    for (int col = 0; col < cols; col++) {
      final bx = col * bs;
      final step = (col >= 4 && col <= 8 ? 6.0 : (col < 3 ? -4.0 : 0.0));
      final topY = groundY + step;
      _drawMcBlockTile(
        canvas,
        Rect.fromLTWH(bx, topY, bs + 0.4, bs),
        kind: 'grass',
        baseColor: wetDirt,
        accentColor: wetGrass,
        seed: col,
      );
      _drawMcBlockTile(
        canvas,
        Rect.fromLTWH(bx, topY + bs, bs + 0.4, h - (topY + bs)),
        kind: 'dirt',
        baseColor: wetDirt,
        seed: col + 7,
      );
    }

    // Rainwater puddle pool on terrace
    final puddleRect = Rect.fromLTWH(w * 0.36, groundY + 6.0, w * 0.32, 4.0);
    canvas.drawRect(
      puddleRect,
      Paint()..color = Color.lerp(const Color(0xFF38BDF8), stormCol, 0.55)!.withValues(alpha: 0.88),
    );

    // Expanding splash impact ripples in puddle (speed & rate scaled by stormSeverity)
    final ripSpeed = motion * (6.0 + stormSeverity * 12.0);
    for (int r = 0; r < 3; r++) {
      final ripPhase = (ripSpeed + r * 2.3) % 6.0;
      final ripR = (2.0 + ripPhase * 1.8).toDouble();
      final ripAlpha = ((1.0 - ripPhase / 6.0) * (0.35 + stormSeverity * 0.50)).clamp(0.0, 0.85);
      final ripCenterX = puddleRect.left + 14.0 + r * (puddleRect.width * 0.35);
      canvas.drawCircle(
        Offset(ripCenterX, puddleRect.center.dy),
        ripR,
        Paint()
          ..color = Colors.white.withValues(alpha: ripAlpha)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.0,
      );
      // Splashing rain droplet bouncing upward
      if (stormSeverity > 0.30) {
        final splashH = math.sin((ripPhase / 6.0) * math.pi) * (3.0 + stormSeverity * 4.0);
        canvas.drawCircle(
          Offset(ripCenterX, puddleRect.top - splashH),
          1.2,
          Paint()..color = const Color(0xFFE0F2FE).withValues(alpha: ripAlpha),
        );
      }
    }

    // 5. Wind-Blown Minecraft Trees (sway amplitude scales with stormSeverity)
    final windSway = math.sin(t * 2.6) * (1.5 + stormSeverity * 7.5);
    _drawMcSpruceTree(
      canvas,
      cx: w * 0.22,
      groundY: groundY - 4.0,
      u: 5.4,
      trunkColor: const Color(0xFF291D14),
      needleLight: const Color(0xFF15803D),
      needleMid: const Color(0xFF166534),
      needleDark: const Color(0xFF14532D),
      wind: windSway,
    );
    _drawMcUnitOakTree(
      canvas,
      cx: w * 0.82,
      groundY: groundY,
      u: 8.0,
      sunOnRight: false,
      trunkLit: const Color(0xFF451A03),
      trunkDark: const Color(0xFF291D14),
      leafLight: const Color(0xFF16A34A),
      leafMid: const Color(0xFF15803D),
      leafDark: const Color(0xFF14532D),
    );

    // 6. Fast Diagonal Minecraft Rain Streaks (density, speed, and slant scale with stormSeverity)
    final rainCount = (16 + (stormSeverity * 40).round());
    final rainPaint = Paint()
      ..color = const Color(0xFFE0F2FE).withValues(alpha: (0.40 + stormSeverity * 0.40).clamp(0.35, 0.85))
      ..strokeWidth = 1.2 + stormSeverity * 0.8;
    final rainSpeed = motion * (1.8 + stormSeverity * 2.6);
    final rainSlant = 6.0 + stormSeverity * 10.0;
    final streakLen = 14.0 + stormSeverity * 12.0;

    for (int i = 0; i < rainCount; i++) {
      final rx = (w * (i / rainCount) + rainSpeed * w * 1.6) % (w + 40) - 20;
      final ry = (h * ((i * 7) % rainCount / rainCount) + rainSpeed * h * 2.8) % h;
      canvas.drawLine(Offset(rx, ry), Offset(rx - rainSlant, ry + streakLen), rainPaint);
    }

    // 7. Near Rain Fog Veil (responsive to weatherFogStart)
    if (startNorm < 0.35) {
      final nearHazeAlpha = ((0.35 - startNorm) / 0.35 * 0.40).clamp(0.0, 0.40);
      canvas.drawRect(
        Rect.fromLTWH(0, 0, w, h),
        Paint()..color = stormCol.withValues(alpha: nearHazeAlpha),
      );
    }
  }

  @override
  bool shouldRepaint(covariant _VVFogPreviewPainter old) =>
      old.mode != mode || old.fog != fog || old.motion != motion;
}

/// Tab 3: Water Live Preview (Preset clarity, waves, caustics)
class VVWaterPreviewBanner extends StatelessWidget {
  final WaterGlobalSettings waterGlobal;
  final WaterPresetConfig preset;
  final String presetName;

  const VVWaterPreviewBanner({
    super.key,
    required this.waterGlobal,
    required this.preset,
    required this.presetName,
  });

  @override
  Widget build(BuildContext context) {
    return VVPreviewFrame(
      badgeText: 'WATER · ${presetName.toUpperCase()}',
      child: _VVReactiveMotion(
        signal: Object.hash(waterGlobal, preset, presetName),
        builder: (context, motion) => CustomPaint(
          painter: _VVWaterPreviewPainter(
            waterGlobal: waterGlobal,
            preset: preset,
            motion: motion,
          ),
        ),
      ),
    );
  }
}

class _VVWaterPreviewPainter extends CustomPainter {
  final WaterGlobalSettings waterGlobal;
  final WaterPresetConfig preset;
  final double motion;

  const _VVWaterPreviewPainter({
    required this.waterGlobal,
    required this.preset,
    this.motion = 0.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final surfaceY = h * 0.36;

    // Sky reflection above water
    canvas.drawRect(
      Rect.fromLTWH(0, 0, w, surfaceY),
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF0EA5E9), Color(0xFFBAE6FD)],
        ).createShader(Rect.fromLTWH(0, 0, w, surfaceY)),
    );

    // Derive surface & deep color from clarity/chlorophyll/cdom
    final clarity = (1.0 - (preset.cdom / 12.0)).clamp(0.0, 1.0);
    final greenTint = (preset.chlorophyll / 8.0).clamp(0.0, 1.0);
    final siltTint = (preset.suspendedSediment / 150.0).clamp(0.0, 1.0);

    Color topCol = Color.lerp(const Color(0xFF1E3A8A), const Color(0xFF22D3EE), clarity)!;
    topCol = Color.lerp(topCol, const Color(0xFF3F6212), greenTint * 0.72)!;
    topCol = Color.lerp(topCol, const Color(0xFF78716C), siltTint * 0.45)!;
    final botCol = Color.lerp(topCol, const Color(0xFF020617), 0.58)!;

    // Seabed visible through clear water
    final bedPaint = Paint()
      ..color = Color.lerp(topCol, const Color(0xFFE7D3A8), clarity * 0.55)!;
    canvas.drawRect(Rect.fromLTWH(0, surfaceY, w, h - surfaceY), bedPaint);

    // Translucent water volume gradient
    canvas.drawRect(
      Rect.fromLTWH(0, surfaceY, w, h - surfaceY),
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            topCol.withValues(alpha: 0.78 - clarity * 0.35),
            botCol.withValues(alpha: 0.94),
          ],
        ).createShader(Rect.fromLTWH(0, surfaceY, w, h - surfaceY)),
    );

    // Animated waves scaled live by wavesDepth, wavesSpeed & wavesEnabled
    if (waterGlobal.wavesEnabled) {
      final amp = (preset.wavesDepth * 5.0).clamp(1.0, 9.0);
      final speedShift = motion * (1.2 + preset.wavesSpeed * 0.9) * math.pi * 2;
      final wavePaint = Paint()
        ..color = Colors.white.withValues(alpha: 0.45)
        ..strokeWidth = 2.0
        ..style = PaintingStyle.stroke;
      for (int row = 0; row < 3; row++) {
        final path = Path();
        final baseY = surfaceY + 8 + row * 16.0;
        for (double x = 0; x <= w; x += 6) {
          final dy = math.sin((x / w) * math.pi * 6 * preset.wavesFrequency + row + speedShift) * amp;
          if (x == 0) {
            path.moveTo(x, baseY + dy);
          } else {
            path.lineTo(x, baseY + dy);
          }
        }
        canvas.drawPath(path, wavePaint);
      }
    }

    // Seabed caustics shimmer
    if (waterGlobal.causticsEnabled) {
      final strength = (waterGlobal.causticsPower / 6.0).clamp(0.25, 1.0);
      final cPaint = Paint()
        ..color = const Color(0xFFA5F3FC).withValues(alpha: 0.16 + strength * 0.34)
        ..strokeWidth = 1.6;
      final step = (24.0 / waterGlobal.causticsScale.clamp(0.4, 3.0)).clamp(10.0, 44.0);
      for (double x = 10; x < w; x += step) {
        canvas.drawLine(Offset(x, h * 0.68), Offset(x + step * 0.4, h * 0.88), cPaint);
        canvas.drawLine(Offset(x + step * 0.4, h * 0.72), Offset(x - step * 0.2, h * 0.92), cPaint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _VVWaterPreviewPainter old) =>
      old.waterGlobal != waterGlobal ||
      old.preset != preset ||
      old.motion != motion;
}

/// Tab 4: Color & Mood Live Preview (applies Temperature + Sat + Contrast + Gain!)
class VVColorPreviewBanner extends StatelessWidget {
  final ColorGradingConfig colorGrading;
  final String activeMood;

  const VVColorPreviewBanner({
    super.key,
    required this.colorGrading,
    required this.activeMood,
  });

  ColorFilter _buildGradeFilter() {
    final sat = colorGrading.midtonesSaturationScalar.clamp(0.0, 2.5);
    final contrast = colorGrading.midtonesContrastScalar.clamp(0.2, 2.5);
    final gain = colorGrading.midtonesGainScalar.clamp(0.2, 2.5);

    // Temperature warmth shift (-1 cool .. +1 warm around 6500K)
    double rShift = 0, bShift = 0;
    if (colorGrading.temperatureEnabled) {
      final norm = ((6500.0 - colorGrading.temperature) / 5500.0).clamp(-1.0, 1.0);
      rShift = norm * 28.0;
      bShift = -norm * 28.0;
    }

    final invSat = 1.0 - sat;
    const rLum = 0.2126, gLum = 0.7152, bLum = 0.0722;
    final sr = invSat * rLum;
    final sg = invSat * gLum;
    final sb = invSat * bLum;
    final t = 128.0 * (1.0 - contrast);
    final s = contrast * gain;

    return ColorFilter.matrix([
      (sr + sat) * s, sg * s, sb * s, 0, t + rShift,
      sr * s, (sg + sat) * s, sb * s, 0, t,
      sr * s, sg * s, (sb + sat) * s, 0, t + bShift,
      0, 0, 0, 1, 0,
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return VVPreviewFrame(
      badgeText: 'COLOR · ${activeMood.toUpperCase()} · ${colorGrading.toneMappingOperator.toUpperCase()}',
      child: ColorFiltered(
        colorFilter: _buildGradeFilter(),
        child: CustomPaint(
          painter: const _VVSceneArtworkPainter(
            type: VVSceneBoxType.moodVibrant,
            color: Color(0xFFFB923C),
          ),
        ),
      ),
    );
  }
}

/// Tab 5: Biomes Live Preview (sky, grass, leaves, water, precipitation)
class VVBiomesPreviewBanner extends StatelessWidget {
  final String biomeLabel;
  final Color skyColor;
  final Color grassColor;
  final Color foliageColor;
  final Color waterColor;
  final double waterOpacity;
  final String precipitationType;
  final double precipitationDensity;
  final double flashIlluminance;
  final Color flashColor;

  const VVBiomesPreviewBanner({
    super.key,
    required this.biomeLabel,
    required this.skyColor,
    required this.grassColor,
    required this.foliageColor,
    required this.waterColor,
    required this.waterOpacity,
    required this.precipitationType,
    required this.precipitationDensity,
    this.flashIlluminance = 0.0,
    this.flashColor = const Color(0xFFB600FF),
  });

  @override
  Widget build(BuildContext context) {
    return VVPreviewFrame(
      badgeText: 'BIOME · ${biomeLabel.toUpperCase()}',
      child: CustomPaint(
        painter: _VVBiomePreviewPainter(
          biomeLabel: biomeLabel,
          skyColor: skyColor,
          grassColor: grassColor,
          foliageColor: foliageColor,
          waterColor: waterColor,
          waterOpacity: waterOpacity,
          precipitationType: precipitationType,
          precipitationDensity: precipitationDensity,
          flashIlluminance: flashIlluminance,
          flashColor: flashColor,
        ),
      ),
    );
  }
}

class _VVBiomePreviewPainter extends CustomPainter {
  final String biomeLabel;
  final Color skyColor;
  final Color grassColor;
  final Color foliageColor;
  final Color waterColor;
  final double waterOpacity;
  final String precipitationType;
  final double precipitationDensity;
  final double flashIlluminance;
  final Color flashColor;

  const _VVBiomePreviewPainter({
    required this.biomeLabel,
    required this.skyColor,
    required this.grassColor,
    required this.foliageColor,
    required this.waterColor,
    required this.waterOpacity,
    required this.precipitationType,
    required this.precipitationDensity,
    this.flashIlluminance = 0.0,
    this.flashColor = const Color(0xFFB600FF),
  });

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final horY = h * 0.60;

    canvas.drawRect(
      Rect.fromLTWH(0, 0, w, horY),
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [skyColor, Color.lerp(skyColor, Colors.white, 0.35)!],
        ).createShader(Rect.fromLTWH(0, 0, w, horY)),
    );

    // End Flash rendering strictly for The End dimension preview
    final isEnd = biomeLabel.toLowerCase().contains('end');
    if (isEnd && flashIlluminance > 1.0) {
      final flashStrength = (flashIlluminance / 20000.0).clamp(0.08, 1.0);
      canvas.drawRect(
        Rect.fromLTWH(0, 0, w, horY),
        Paint()..color = flashColor.withValues(alpha: flashStrength * 0.45),
      );
    }

    // Grass terrain & dirt base
    canvas.drawRect(Rect.fromLTWH(0, horY, w * 0.62, 12), Paint()..color = grassColor);
    canvas.drawRect(Rect.fromLTWH(0, horY + 12, w * 0.62, h - horY - 12), Paint()..color = const Color(0xFF5C3A21));

    // Biome water pool
    canvas.drawRect(
      Rect.fromLTWH(w * 0.62, horY + 4, w * 0.38, h - horY - 4),
      Paint()..color = waterColor.withValues(alpha: waterOpacity.clamp(0.25, 1.0)),
    );

    // Voxel tree with foliageColor
    canvas.drawRect(Rect.fromLTWH(w * 0.25, horY - 38, 12, 38), Paint()..color = const Color(0xFF6B4226));
    canvas.drawRect(Rect.fromLTWH(w * 0.17, horY - 66, 32, 32), Paint()..color = foliageColor);

    // Precipitation particles
    if (precipitationType != 'none' && precipitationDensity > 0.01) {
      final pColor = switch (precipitationType) {
        'blue_spores' => const Color(0xFF38BDF8),
        'red_spores' => const Color(0xFFF87171),
        'white_ash' => const Color(0xFFF8FAFC),
        _ => const Color(0xFF94A3B8),
      };
      final count = (precipitationDensity * 28).round().clamp(4, 28);
      final paint = Paint()..color = pColor.withValues(alpha: 0.85);
      for (int i = 0; i < count; i++) {
        final px = w * (((i * 37) % 100) / 100.0);
        final py = h * (((i * 53) % 85) / 100.0);
        canvas.drawRect(Rect.fromLTWH(px, py, 3, 3), paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _VVBiomePreviewPainter old) =>
      old.biomeLabel != biomeLabel ||
      old.skyColor != skyColor ||
      old.grassColor != grassColor ||
      old.foliageColor != foliageColor ||
      old.waterColor != waterColor ||
      old.waterOpacity != waterOpacity ||
      old.precipitationType != precipitationType ||
      old.precipitationDensity != precipitationDensity ||
      old.flashIlluminance != flashIlluminance ||
      old.flashColor != flashColor;
}

/// Tab 6: Surface & PBR Live Preview (Shininess / Metalness / Emissive / Subsurface cubes)
class VVSurfacePreviewBanner extends StatelessWidget {
  final SurfaceConfig surface;

  const VVSurfacePreviewBanner({super.key, required this.surface});

  @override
  Widget build(BuildContext context) {
    final finishLabel = surface.shininess >= 0.7
        ? 'GLOSSY'
        : surface.shininess >= 0.35
            ? 'SATIN'
            : 'MATTE';
    return VVPreviewFrame(
      badgeText: 'SURFACE · $finishLabel (R:${surface.roughness})',
      child: _VVReactiveMotion(
        signal: surface,
        builder: (context, motion) => CustomPaint(
          painter: _VVSurfacePreviewPainter(surface: surface, motion: motion),
        ),
      ),
    );
  }
}

class _VVSurfacePreviewPainter extends CustomPainter {
  final SurfaceConfig surface;
  final double motion;
  const _VVSurfacePreviewPainter({required this.surface, this.motion = 0.0});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    canvas.drawRect(
      Rect.fromLTWH(0, 0, w, h),
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF0A111C), Color(0xFF141F2D)],
        ).createShader(Rect.fromLTWH(0, 0, w, h)),
    );

    final gloss = surface.shininess.clamp(0.0, 1.0);
    final metal = (surface.metalness / 255.0).clamp(0.0, 1.0);
    final emissive = (surface.emissive / 255.0).clamp(0.0, 1.0);
    final sss = (surface.subsurface / 255.0).clamp(0.0, 1.0);

    final baseCol = Color.lerp(const Color(0xFF475569), const Color(0xFFE2E8F0), metal * 0.7)!;
    final blockRect = Rect.fromCenter(center: Offset(w * 0.5, h * 0.55), width: 72, height: 72);

    // Emissive outer bloom if emissive > 0
    if (emissive > 0.02) {
      canvas.drawCircle(
        blockRect.center,
        62,
        Paint()
          ..shader = RadialGradient(
            colors: [
              const Color(0xFFFDE047).withValues(alpha: emissive * 0.55),
              const Color(0xFFFDE047).withValues(alpha: 0),
            ],
          ).createShader(Rect.fromCircle(center: blockRect.center, radius: 62)),
      );
    }

    canvas.drawRRect(
      RRect.fromRectAndRadius(blockRect, const Radius.circular(6)),
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color.lerp(baseCol, Colors.white, gloss * 0.55 + emissive * 0.4)!,
            Color.lerp(baseCol, const Color(0xFF0F172A), 0.45 * (1.0 - emissive))!,
          ],
        ).createShader(blockRect),
    );

    // Specular highlight bar reacting to shininess & sweeping subtly on updates
    if (gloss > 0.05) {
      final sweep = 6.0 + math.sin(motion * math.pi * 2) * 8.0;
      canvas.drawRect(
        Rect.fromLTWH(blockRect.left + sweep, blockRect.top + 8, 28 * gloss + 8, 10),
        Paint()..color = Colors.white.withValues(alpha: 0.15 + gloss * 0.70),
      );
    }

    // Subsurface warm edge tint
    if (sss > 0.03) {
      canvas.drawRect(
        Rect.fromLTWH(blockRect.left, blockRect.bottom - 10, blockRect.width, 10),
        Paint()..color = const Color(0xFFFB7185).withValues(alpha: sss * 0.45),
      );
    }
  }

  @override
  bool shouldRepaint(covariant _VVSurfacePreviewPainter old) =>
      old.surface != surface || old.motion != motion;
}

/// Tab 7: Performance Live Preview (FPS Budget & Active Tier Features)
class VVPerfPreviewBanner extends StatelessWidget {
  final PerformanceScoreResult score;
  final TierProfile activeProfile;

  const VVPerfPreviewBanner({
    super.key,
    required this.score,
    required this.activeProfile,
  });

  @override
  Widget build(BuildContext context) {
    return VVPixelBox(
      fillColor: _kCard,
      borderColor: _kBorder,
      borderWidth: 1.5,
      step: 3.5,
      hasShadow: true,
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'GPU LOAD · ${score.scoreLabel.toUpperCase()}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12.5,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const Spacer(),
              Text(
                '${score.numericScore}/100',
                style: const TextStyle(
                  color: _kEmerald,
                  fontFamily: 'monospace',
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          LinearProgressIndicator(
            value: (score.numericScore / 100.0).clamp(0.0, 1.0),
            minHeight: 8,
            backgroundColor: _kSurface,
            valueColor: AlwaysStoppedAnimation<Color>(
              score.numericScore >= 75 ? const Color(0xFFF59E0B) : _kEmerald,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 6,
            children: [
              _miniStat('Tier', activeProfile.displayName),
              _miniStat('Waves', activeProfile.wavesEnabled ? '${activeProfile.wavesOctaves} oct' : 'OFF'),
              _miniStat('Caustics', activeProfile.causticsEnabled ? 'ON' : 'OFF'),
              _miniStat('Point Lights', '${score.pointLightsCount}'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _miniStat(String k, String v) {
    return VVPixelBox(
      fillColor: _kSurface,
      borderColor: _kBorder,
      borderWidth: 1.1,
      step: 2.0,
      hasShadow: false,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Text(
        '$k: $v',
        style: const TextStyle(
          color: Colors.white70,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

/// Tab 8: Export Pack Live Preview Card
class VVExportPreviewBanner extends StatelessWidget {
  final Uint8List packIconBytes;
  final String packName;
  final List<int>? version;
  final bool isValid;
  final int? tierCount;
  final int? fileSizeInBytes;

  const VVExportPreviewBanner({
    super.key,
    required this.packIconBytes,
    required this.packName,
    this.version,
    required this.isValid,
    this.tierCount,
    this.fileSizeInBytes,
  });

  @override
  Widget build(BuildContext context) {
    final hasFinalSize = fileSizeInBytes != null && fileSizeInBytes! > 0;
    final sizeKbStr = hasFinalSize ? (fileSizeInBytes! / 1024.0).toStringAsFixed(1) : null;

    return VVPixelBox(
      fillColor: _kCard,
      borderColor: isValid ? _kEmerald.withValues(alpha: 0.65) : _kBorder,
      borderWidth: 1.5,
      step: 3.5,
      hasShadow: true,
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          VVPixelBox(
            fillColor: _kSurface,
            borderColor: _kBorder,
            borderWidth: 1.2,
            step: 2.0,
            hasShadow: false,
            child: SizedBox(
              width: 56,
              height: 56,
              child: packIconBytes.isEmpty
                  ? const Icon(Icons.image_outlined, color: Colors.white38)
                  : Image.memory(packIconBytes, fit: BoxFit.cover, filterQuality: FilterQuality.none),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  packName.trim().isEmpty ? 'Piglix Shader' : packName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    if (hasFinalSize) ...[
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: _kEmerald.withValues(alpha: 0.18),
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(color: _kEmerald.withValues(alpha: 0.6), width: 1),
                        ),
                        child: Text(
                          '$sizeKbStr KB',
                          style: const TextStyle(
                            color: _kEmerald,
                            fontFamily: 'monospace',
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                    ],
                    Flexible(
                      child: Text(
                        hasFinalSize
                            ? 'Ready to Install · Vibrant Visuals'
                            : 'Vibrant Visuals .mcpack',
                        style: const TextStyle(
                          color: Colors.white54,
                          fontSize: 11.5,
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          VVPixelBox(
            fillColor: (isValid ? _kEmerald : const Color(0xFFEF4444)).withValues(alpha: 0.16),
            borderColor: isValid ? _kEmerald : const Color(0xFFEF4444),
            borderWidth: 1.2,
            step: 2.0,
            hasShadow: false,
            padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
            child: Text(
              !isValid
                  ? 'FIX ERRORS'
                  : (hasFinalSize ? '$sizeKbStr KB' : 'READY'),
              style: TextStyle(
                color: isValid ? _kEmerald : const Color(0xFFF87171),
                fontSize: 11,
                fontWeight: FontWeight.w700,
                fontFamily: hasFinalSize ? 'monospace' : null,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
