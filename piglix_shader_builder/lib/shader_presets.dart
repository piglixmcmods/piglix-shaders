import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'minecraft_icons.dart';
import 'piglix_logo_data.dart';
import 'theme_controller.dart';
import 'vv_global_nav_bar.dart';

/// Complete configuration for a production-grade Vibrant Visuals shader preset.
class ShaderPresetConfig {
  final String id;
  final String name;
  final String creator;
  final String description;
  final double rating;
  final String downloads;
  final List<String> tags;

  // Atmosphere
  final Color morningColor;
  final Color noonColor;
  final Color eveningColor;
  final Color nightColor;
  final double sunSize;
  final double nightVision;
  final double fogDensity;
  final String cloudType;

  // Lighting & Point Lights
  final Color torchColor;
  final double lightIntensity;
  final double blockLightIntensity;
  final String shadowQuality;
  final bool enablePointLightShadows;
  final String volumetricFogProfile;

  // God Rays
  final Color rayMorningColor;
  final Color rayNoonColor;
  final Color rayEveningColor;
  final Color rayNightColor;

  // Water
  final Color waterColor;
  final double windSpeed;
  final String waterQuality;
  final bool underwaterCaustics;

  // Weather
  final Color rainFogColor;
  final Color rainWaterColor;

  // PBR & Foliage
  final bool worldReflections;
  final bool enablePBR;
  final double metalness;
  final bool wavingFoliage;
  final double foliageWaveSpeed;

  // Post-FX
  final String toneMapFilter;
  final String biomeTone;
  final double saturation;
  final double contrast;
  final double autoExposure;

  const ShaderPresetConfig({
    required this.id,
    required this.name,
    this.creator = 'Piglix Labs',
    required this.description,
    this.rating = 4.9,
    this.downloads = '12.4k',
    this.tags = const ['Vibrant Visuals', 'Deferred PBR', '60 FPS'],
    required this.morningColor,
    required this.noonColor,
    required this.eveningColor,
    required this.nightColor,
    this.sunSize = 1.0,
    this.nightVision = 1.0,
    this.fogDensity = 1.0,
    this.cloudType = 'Realistic 3D',
    this.torchColor = const Color(0xFFFF9933),
    this.lightIntensity = 1.0,
    this.blockLightIntensity = 1.0,
    this.shadowQuality = 'High',
    this.enablePointLightShadows = true,
    this.volumetricFogProfile = 'Cinematic',
    required this.rayMorningColor,
    required this.rayNoonColor,
    required this.rayEveningColor,
    required this.rayNightColor,
    required this.waterColor,
    this.windSpeed = 1.0,
    this.waterQuality = 'Ultra',
    this.underwaterCaustics = true,
    this.rainFogColor = const Color(0xFF5A636A),
    this.rainWaterColor = const Color(0xFF2E3D48),
    this.worldReflections = true,
    this.enablePBR = true,
    this.metalness = 0.0,
    this.wavingFoliage = true,
    this.foliageWaveSpeed = 1.0,
    this.toneMapFilter = 'ACES (Cinematic)',
    this.biomeTone = 'Dynamic',
    this.saturation = 1.0,
    this.contrast = 1.0,
    this.autoExposure = 1.0,
  });
}

/// Curated official presets ready for one-tap application.
final List<ShaderPresetConfig> kDefaultShaderPresets = [
  const ShaderPresetConfig(
    id: 'ultra_vibrant',
    name: 'Ultra Vibrant VV',
    creator: 'Piglix Labs',
    description:
        'High-saturation cinematic visuals with dazzling sun shafts, crystalline cyan ocean, and vivid bloom.',
    rating: 4.9,
    downloads: '24.8k',
    tags: ['Vibrant Visuals', 'Raymarched', 'Ultra Caustics'],
    morningColor: Color(0xFFFFA0B2),
    noonColor: Color(0xFF5B7AFF),
    eveningColor: Color(0xFFFF5A20),
    nightColor: Color(0xFF0A1C50),
    sunSize: 1.35,
    nightVision: 1.15,
    fogDensity: 1.05,
    cloudType: 'Realistic 3D',
    torchColor: Color(0xFFFFA033),
    lightIntensity: 1.3,
    blockLightIntensity: 1.25,
    shadowQuality: 'Ultra',
    enablePointLightShadows: true,
    volumetricFogProfile: 'Cinematic',
    rayMorningColor: Color(0xFFFFA040),
    rayNoonColor: Color(0xFFFAFCFF),
    rayEveningColor: Color(0xFFFF5015),
    rayNightColor: Color(0xFF2563EB),
    waterColor: Color(0xFF00E5FF),
    windSpeed: 1.4,
    waterQuality: 'Ultra',
    underwaterCaustics: true,
    rainFogColor: Color(0xFF475569),
    rainWaterColor: Color(0xFF1E3A5F),
    worldReflections: true,
    enablePBR: true,
    metalness: 0.12,
    wavingFoliage: true,
    foliageWaveSpeed: 1.2,
    toneMapFilter: 'ACES (Cinematic)',
    biomeTone: 'Vibrant',
    saturation: 1.2,
    contrast: 1.15,
    autoExposure: 1.1,
  ),
  const ShaderPresetConfig(
    id: 'pink_atmosphere',
    name: 'Pink Atmosphere (Sakura)',
    creator: 'Piglix Labs',
    description:
        'Dreamy pastel atmosphere featuring soft pink/rose sky horizons, warm dusk fog, and glowing lanterns.',
    rating: 4.8,
    downloads: '19.4k',
    tags: ['Pastel Dusk', 'Sakura Glow', 'Warm Bloom'],
    morningColor: Color(0xFFFF8DA6),
    noonColor: Color(0xFFF472B6),
    eveningColor: Color(0xFFE11D48),
    nightColor: Color(0xFF3B0764),
    sunSize: 1.15,
    nightVision: 1.1,
    fogDensity: 1.25,
    cloudType: 'Realistic 3D',
    torchColor: Color(0xFFF97316),
    lightIntensity: 1.1,
    blockLightIntensity: 1.2,
    shadowQuality: 'High',
    enablePointLightShadows: true,
    volumetricFogProfile: 'Cinematic',
    rayMorningColor: Color(0xFFFB7185),
    rayNoonColor: Color(0xFFF472B6),
    rayEveningColor: Color(0xFFE11D48),
    rayNightColor: Color(0xFF818CF8),
    waterColor: Color(0xFFFB7185),
    windSpeed: 0.95,
    waterQuality: 'Ultra',
    underwaterCaustics: true,
    rainFogColor: Color(0xFF831843),
    rainWaterColor: Color(0xFF4C0519),
    worldReflections: true,
    enablePBR: true,
    metalness: 0.05,
    wavingFoliage: true,
    foliageWaveSpeed: 1.0,
    toneMapFilter: 'ACES (Cinematic)',
    biomeTone: 'Moody',
    saturation: 1.1,
    contrast: 1.05,
    autoExposure: 1.0,
  ),
  const ShaderPresetConfig(
    id: 'cinematic_realism',
    name: 'Cinematic Realism',
    creator: 'VoxelCraft',
    description:
        'Balanced photorealistic daylight with dense volumetric shafts, soft 1024px shadows, and natural 6500K balance.',
    rating: 4.9,
    downloads: '21.1k',
    tags: ['Photoreal', 'Soft Shadows', 'Dynamic'],
    morningColor: Color(0xFFFBBF24),
    noonColor: Color(0xFF60A5FA),
    eveningColor: Color(0xFFEA580C),
    nightColor: Color(0xFF0F172A),
    sunSize: 1.0,
    nightVision: 1.0,
    fogDensity: 0.95,
    cloudType: 'Volumetric',
    torchColor: Color(0xFFF59E0B),
    lightIntensity: 1.0,
    blockLightIntensity: 1.0,
    shadowQuality: 'High',
    enablePointLightShadows: true,
    volumetricFogProfile: 'Balanced',
    rayMorningColor: Color(0xFFFBBF24),
    rayNoonColor: Color(0xFFF8FAFC),
    rayEveningColor: Color(0xFFEA580C),
    rayNightColor: Color(0xFF38BDF8),
    waterColor: Color(0xFF0284C7),
    windSpeed: 1.0,
    waterQuality: 'High',
    underwaterCaustics: true,
    rainFogColor: Color(0xFF475569),
    rainWaterColor: Color(0xFF1E293B),
    worldReflections: true,
    enablePBR: true,
    metalness: 0.0,
    wavingFoliage: true,
    foliageWaveSpeed: 1.0,
    toneMapFilter: 'ACES (Cinematic)',
    biomeTone: 'Dynamic',
    saturation: 1.0,
    contrast: 1.0,
    autoExposure: 1.0,
  ),
  const ShaderPresetConfig(
    id: 'midnight_cyber',
    name: 'Midnight Cyber Glow',
    creator: 'NeonPixel',
    description:
        'Deep obsidian night with intense cyan soul lantern radiance, sharp point-light shadows, and moonlight rays.',
    rating: 4.8,
    downloads: '16.5k',
    tags: ['Soul Neon', 'Night RTX', 'Cyberpunk'],
    morningColor: Color(0xFF38BDF8),
    noonColor: Color(0xFF0284C7),
    eveningColor: Color(0xFF1E293B),
    nightColor: Color(0xFF060A14),
    sunSize: 0.85,
    nightVision: 1.75,
    fogDensity: 1.15,
    cloudType: 'Realistic 3D',
    torchColor: Color(0xFF06B6D4),
    lightIntensity: 0.9,
    blockLightIntensity: 1.6,
    shadowQuality: 'Ultra',
    enablePointLightShadows: true,
    volumetricFogProfile: 'Cinematic',
    rayMorningColor: Color(0xFF38BDF8),
    rayNoonColor: Color(0xFF0284C7),
    rayEveningColor: Color(0xFF1E293B),
    rayNightColor: Color(0xFF0284C7),
    waterColor: Color(0xFF083344),
    windSpeed: 1.25,
    waterQuality: 'Ultra',
    underwaterCaustics: true,
    rainFogColor: Color(0xFF0F172A),
    rainWaterColor: Color(0xFF020617),
    worldReflections: true,
    enablePBR: true,
    metalness: 0.45,
    wavingFoliage: true,
    foliageWaveSpeed: 1.1,
    toneMapFilter: 'Reinhard',
    biomeTone: 'Frost',
    saturation: 1.15,
    contrast: 1.25,
    autoExposure: 1.1,
  ),
  const ShaderPresetConfig(
    id: 'golden_hour',
    name: 'Golden Hour Sunset',
    creator: 'Piglix Labs',
    description:
        'Warm amber twilight with glowing orange haze, shimmering water caustics, and elongated soft sunset shadows.',
    rating: 4.9,
    downloads: '18.7k',
    tags: ['Golden Dusk', 'Warm 5500K', 'Caustics'],
    morningColor: Color(0xFFF59E0B),
    noonColor: Color(0xFFFDE047),
    eveningColor: Color(0xFFDC2626),
    nightColor: Color(0xFF1E1B4B),
    sunSize: 1.5,
    nightVision: 1.1,
    fogDensity: 1.15,
    cloudType: 'Realistic 3D',
    torchColor: Color(0xFFEA580C),
    lightIntensity: 1.35,
    blockLightIntensity: 1.25,
    shadowQuality: 'Ultra',
    enablePointLightShadows: true,
    volumetricFogProfile: 'Cinematic',
    rayMorningColor: Color(0xFFF59E0B),
    rayNoonColor: Color(0xFFFEF08A),
    rayEveningColor: Color(0xFFDC2626),
    rayNightColor: Color(0xFF4338CA),
    waterColor: Color(0xFFD97706),
    windSpeed: 1.25,
    waterQuality: 'Ultra',
    underwaterCaustics: true,
    rainFogColor: Color(0xFF78350F),
    rainWaterColor: Color(0xFF451A03),
    worldReflections: true,
    enablePBR: true,
    metalness: 0.15,
    wavingFoliage: true,
    foliageWaveSpeed: 1.3,
    toneMapFilter: 'Warm',
    biomeTone: 'Savanna',
    saturation: 1.2,
    contrast: 1.1,
    autoExposure: 1.15,
  ),
  const ShaderPresetConfig(
    id: 'vanilla_plus',
    name: 'Vanilla+ Enhanced',
    creator: 'SteveStudio',
    description:
        'Lightweight performance preset preserving classic Minecraft aesthetics with smooth 3D clouds and soft deferred shafts.',
    rating: 4.7,
    downloads: '14.2k',
    tags: ['Performance', 'Vanilla Feel', 'Smooth 60FPS'],
    morningColor: Color(0xFFFFA040),
    noonColor: Color(0xFF87CEEB),
    eveningColor: Color(0xFFFFA500),
    nightColor: Color(0xFF00008B),
    sunSize: 1.0,
    nightVision: 1.0,
    fogDensity: 0.8,
    cloudType: 'Realistic 3D',
    torchColor: Color(0xFFFF9933),
    lightIntensity: 1.0,
    blockLightIntensity: 1.0,
    shadowQuality: 'Low',
    enablePointLightShadows: false,
    volumetricFogProfile: 'Low End',
    rayMorningColor: Color(0xFFFFA040),
    rayNoonColor: Color(0xFFFAFCFF),
    rayEveningColor: Color(0xFFFF6020),
    rayNightColor: Color(0xFF3050AA),
    waterColor: Color(0xFF00E5FF),
    windSpeed: 1.0,
    waterQuality: 'High',
    underwaterCaustics: true,
    rainFogColor: Color(0xFF5A636A),
    rainWaterColor: Color(0xFF2E3D48),
    worldReflections: false,
    enablePBR: false,
    metalness: 0.0,
    wavingFoliage: true,
    foliageWaveSpeed: 1.0,
    toneMapFilter: 'ACES (Cinematic)',
    biomeTone: 'Dynamic',
    saturation: 1.0,
    contrast: 1.0,
    autoExposure: 1.0,
  ),
];

// ─────────────────────────────────────────────────────────────────
//  PRESET & GALLERY PACKAGE ICON GENERATOR
// ─────────────────────────────────────────────────────────────────

Color presetAccentColor(ShaderPresetConfig p) {
  switch (p.id) {
    case 'ultra_vibrant':
      return const Color(0xFF22C55E);
    case 'pink_atmosphere':
      return const Color(0xFFF472B6);
    case 'cinematic_realism':
      return const Color(0xFF38BDF8);
    case 'midnight_cyber':
      return const Color(0xFFA855F7);
    case 'golden_hour':
      return const Color(0xFFF59E0B);
    case 'vanilla_plus':
    default:
      return const Color(0xFF4ADE80);
  }
}

final Map<String, Uint8List> _presetIconCache = {};

/// Generates or retrieves from cache an authentic Minecraft-style 128x128 PNG package image
/// for a curated preset using its accent, atmospheric lighting colors, and name initials.
Future<Uint8List> getOrGeneratePresetPackIcon(ShaderPresetConfig preset) async {
  final cached = _presetIconCache[preset.id];
  if (cached != null && cached.isNotEmpty) return cached;

  try {
    const double size = 128.0;
    final recorder = ui.PictureRecorder();
    final canvas = ui.Canvas(
      recorder,
      const Rect.fromLTWH(0, 0, 128, 128),
    );

    final accent = presetAccentColor(preset);
    const bgDark = Color(0xFF0F172A);
    const bgDeep = Color(0xFF020617);

    // 1. Background linear gradient
    final bgPaint = ui.Paint()
      ..shader = ui.Gradient.linear(
        const Offset(0, 0),
        const Offset(128, 128),
        [bgDark, bgDeep],
      );
    canvas.drawRect(
      const Rect.fromLTWH(0, 0, 128, 128),
      bgPaint,
    );

    // 2. Minecraft pixel grid pattern
    final gridPaint = ui.Paint()..color = Colors.white.withValues(alpha: 0.035);
    for (double i = 0; i < size; i += 16) {
      canvas.drawLine(Offset(i, 0), Offset(i, size), gridPaint);
      canvas.drawLine(Offset(0, i), Offset(size, i), gridPaint);
    }

    // 3. Ambient atmospheric radial glow
    final glowPaint = ui.Paint()
      ..shader = ui.Gradient.radial(
        const Offset(64, 64),
        size * 0.55,
        [accent.withValues(alpha: 0.35), accent.withValues(alpha: 0.0)],
      );
    canvas.drawCircle(const Offset(64, 64), size * 0.55, glowPaint);

    // 4. Outer Minecraft pixel border
    final borderPaint = ui.Paint()
      ..color = accent
      ..style = ui.PaintingStyle.stroke
      ..strokeWidth = 4.0;
    canvas.drawRect(
      const Rect.fromLTWH(2, 2, 124, 124),
      borderPaint,
    );

    // 5. Inner highlight border
    final innerBorder = ui.Paint()
      ..color = Colors.white.withValues(alpha: 0.16)
      ..style = ui.PaintingStyle.stroke
      ..strokeWidth = 2.0;
    canvas.drawRect(
      const Rect.fromLTWH(6, 6, 116, 116),
      innerBorder,
    );

    // 6. Central isometric Minecraft block
    // Top face
    final topFace = ui.Path()
      ..moveTo(64, 30)
      ..lineTo(92, 46)
      ..lineTo(64, 62)
      ..lineTo(36, 46)
      ..close();
    final topPaint = ui.Paint()
      ..color = Color.lerp(preset.noonColor, Colors.white, 0.28) ?? accent;
    canvas.drawPath(topFace, topPaint);

    // Left face
    final leftFace = ui.Path()
      ..moveTo(36, 46)
      ..lineTo(64, 62)
      ..lineTo(64, 94)
      ..lineTo(36, 78)
      ..close();
    final leftPaint = ui.Paint()
      ..color = Color.lerp(preset.morningColor, Colors.black, 0.22) ?? accent;
    canvas.drawPath(leftFace, leftPaint);

    // Right face
    final rightFace = ui.Path()
      ..moveTo(64, 62)
      ..lineTo(92, 46)
      ..lineTo(92, 78)
      ..lineTo(64, 94)
      ..close();
    final rightPaint = ui.Paint()
      ..color = Color.lerp(preset.waterColor, Colors.black, 0.42) ?? accent;
    canvas.drawPath(rightFace, rightPaint);

    // Block outline edges
    final blockEdgePaint = ui.Paint()
      ..color = Colors.black.withValues(alpha: 0.55)
      ..style = ui.PaintingStyle.stroke
      ..strokeWidth = 1.8;
    canvas.drawPath(topFace, blockEdgePaint);
    canvas.drawPath(leftFace, blockEdgePaint);
    canvas.drawPath(rightFace, blockEdgePaint);

    // 7. Initials banner
    final initials = preset.name
        .split(RegExp(r'\s+'))
        .where((s) => s.isNotEmpty)
        .take(2)
        .map((s) => s[0].toUpperCase())
        .join();

    final textPainter = TextPainter(
      text: TextSpan(
        text: initials.isNotEmpty ? initials : 'VV',
        style: const TextStyle(
          color: Colors.white,
          fontSize: 17,
          fontWeight: FontWeight.w900,
          letterSpacing: 1.0,
          shadows: [
            Shadow(
              color: Colors.black,
              offset: Offset(1.5, 1.5),
              blurRadius: 3,
            ),
          ],
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(
        (size - textPainter.width) / 2,
        size - textPainter.height - 8,
      ),
    );

    final picture = recorder.endRecording();
    final img = await picture.toImage(128, 128);
    picture.dispose();
    final byteData = await img.toByteData(format: ui.ImageByteFormat.png);
    img.dispose();

    if (byteData != null) {
      final res = byteData.buffer.asUint8List();
      _presetIconCache[preset.id] = res;
      return res;
    }
  } catch (_) {}

  return kPiglixLogoBytes;
}

/// Generates or retrieves from cache an authentic Minecraft-style 128x128 PNG package image
/// for an edited gallery pack item using its preview color and pack initials.
Future<Uint8List> generateShaderItemPackIcon(String name, Color? previewColor) async {
  final accent = previewColor ?? const Color(0xFF10B981);
  final cacheKey = 'gallery_${name}_${accent.toARGB32()}';
  final cached = _presetIconCache[cacheKey];
  if (cached != null && cached.isNotEmpty) return cached;

  try {
    const double size = 128.0;
    final recorder = ui.PictureRecorder();
    final canvas = ui.Canvas(
      recorder,
      const Rect.fromLTWH(0, 0, 128, 128),
    );

    const bgDark = Color(0xFF0F172A);
    const bgDeep = Color(0xFF020617);

    // 1. Background linear gradient
    final bgPaint = ui.Paint()
      ..shader = ui.Gradient.linear(
        const Offset(0, 0),
        const Offset(128, 128),
        [bgDark, bgDeep],
      );
    canvas.drawRect(
      const Rect.fromLTWH(0, 0, 128, 128),
      bgPaint,
    );

    // 2. Minecraft pixel grid
    final gridPaint = ui.Paint()..color = Colors.white.withValues(alpha: 0.04);
    for (double i = 0; i < size; i += 16) {
      canvas.drawLine(Offset(i, 0), Offset(i, size), gridPaint);
      canvas.drawLine(Offset(0, i), Offset(size, i), gridPaint);
    }

    // 3. Center ambient glow
    final glowPaint = ui.Paint()
      ..shader = ui.Gradient.radial(
        const Offset(64, 64),
        size * 0.55,
        [accent.withValues(alpha: 0.4), accent.withValues(alpha: 0.0)],
      );
    canvas.drawCircle(const Offset(64, 64), size * 0.55, glowPaint);

    // 4. Outer border
    final borderPaint = ui.Paint()
      ..color = accent
      ..style = ui.PaintingStyle.stroke
      ..strokeWidth = 4.0;
    canvas.drawRect(
      const Rect.fromLTWH(2, 2, 124, 124),
      borderPaint,
    );

    // 5. Inner border
    final innerBorder = ui.Paint()
      ..color = Colors.white.withValues(alpha: 0.18)
      ..style = ui.PaintingStyle.stroke
      ..strokeWidth = 2.0;
    canvas.drawRect(
      const Rect.fromLTWH(6, 6, 116, 116),
      innerBorder,
    );

    // 6. Central isometric cube
    final topFace = ui.Path()
      ..moveTo(64, 30)
      ..lineTo(92, 46)
      ..lineTo(64, 62)
      ..lineTo(36, 46)
      ..close();
    final topPaint = ui.Paint()
      ..color = Color.lerp(accent, Colors.white, 0.3) ?? accent;
    canvas.drawPath(topFace, topPaint);

    final leftFace = ui.Path()
      ..moveTo(36, 46)
      ..lineTo(64, 62)
      ..lineTo(64, 94)
      ..lineTo(36, 78)
      ..close();
    final leftPaint = ui.Paint()
      ..color = Color.lerp(accent, Colors.black, 0.25) ?? accent;
    canvas.drawPath(leftFace, leftPaint);

    final rightFace = ui.Path()
      ..moveTo(64, 62)
      ..lineTo(92, 46)
      ..lineTo(92, 78)
      ..lineTo(64, 94)
      ..close();
    final rightPaint = ui.Paint()
      ..color = Color.lerp(accent, Colors.black, 0.45) ?? accent;
    canvas.drawPath(rightFace, rightPaint);

    final blockEdgePaint = ui.Paint()
      ..color = Colors.black.withValues(alpha: 0.6)
      ..style = ui.PaintingStyle.stroke
      ..strokeWidth = 1.8;
    canvas.drawPath(topFace, blockEdgePaint);
    canvas.drawPath(leftFace, blockEdgePaint);
    canvas.drawPath(rightFace, blockEdgePaint);

    // 7. Initials banner
    final initials = name
        .split(RegExp(r'\s+'))
        .where((s) => s.isNotEmpty)
        .take(2)
        .map((s) => s[0].toUpperCase())
        .join();

    final textPainter = TextPainter(
      text: TextSpan(
        text: initials.isNotEmpty ? initials : 'VV',
        style: const TextStyle(
          color: Colors.white,
          fontSize: 17,
          fontWeight: FontWeight.w900,
          letterSpacing: 1.0,
          shadows: [
            Shadow(
              color: Colors.black,
              offset: Offset(1.5, 1.5),
              blurRadius: 3,
            ),
          ],
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(
        (size - textPainter.width) / 2,
        size - textPainter.height - 8,
      ),
    );

    final picture = recorder.endRecording();
    final img = await picture.toImage(128, 128);
    picture.dispose();
    final byteData = await img.toByteData(format: ui.ImageByteFormat.png);
    img.dispose();

    if (byteData != null) {
      final res = byteData.buffer.asUint8List();
      _presetIconCache[cacheKey] = res;
      return res;
    }
  } catch (_) {}

  return kPiglixLogoBytes;
}

/// Dedicated full-screen page for exploring, previewing and applying curated shader presets.
class ShaderPresetsScreen extends StatefulWidget {
  final Function(ShaderPresetConfig) onSelectPreset;
  final VoidCallback? onOpenBuilder;
  final VoidCallback? onOpenGallery;
  final VoidCallback? onOpenSettings;

  const ShaderPresetsScreen({
    super.key,
    required this.onSelectPreset,
    this.onOpenBuilder,
    this.onOpenGallery,
    this.onOpenSettings,
  });

  @override
  State<ShaderPresetsScreen> createState() => _ShaderPresetsScreenState();
}

class _ShaderPresetsScreenState extends State<ShaderPresetsScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  String _selectedCategory = 'ALL';

  final List<String> _categories = [
    'ALL',
    'POPULAR',
    'CINEMATIC',
    'ATMOSPHERE',
    'NIGHT & CYBER',
    'VANILLA+',
  ];

  List<ShaderPresetConfig> _filteredPresets() {
    switch (_selectedCategory) {
      case 'POPULAR':
        return kDefaultShaderPresets
            .where(
              (p) =>
                  p.rating >= 4.9 ||
                  p.id == 'ultra_vibrant' ||
                  p.id == 'vanilla_plus',
            )
            .toList();
      case 'CINEMATIC':
        return kDefaultShaderPresets
            .where(
              (p) => p.id == 'ultra_vibrant' || p.id == 'cinematic_realism',
            )
            .toList();
      case 'ATMOSPHERE':
        return kDefaultShaderPresets
            .where((p) => p.id == 'pink_atmosphere' || p.id == 'golden_hour')
            .toList();
      case 'NIGHT & CYBER':
        return kDefaultShaderPresets
            .where((p) => p.id == 'midnight_cyber')
            .toList();
      case 'VANILLA+':
        return kDefaultShaderPresets
            .where((p) => p.id == 'vanilla_plus')
            .toList();
      default:
        return kDefaultShaderPresets;
    }
  }

  VoxelIconType _getPresetIcon(String id) {
    switch (id) {
      case 'ultra_vibrant':
        return VoxelIconType.enchantedBook;
      case 'pink_atmosphere':
        return VoxelIconType.waterDroplet;
      case 'cinematic_realism':
        return VoxelIconType.sun;
      case 'midnight_cyber':
        return VoxelIconType.moon;
      case 'golden_hour':
        return VoxelIconType.torch;
      case 'vanilla_plus':
      default:
        return VoxelIconType.enchantedBook;
    }
  }

  Color _getPresetAccent(String id) => presetAccentColor(
        kDefaultShaderPresets.firstWhere(
          (p) => p.id == id,
          orElse: () => kDefaultShaderPresets.first,
        ),
      );

  @override
  Widget build(BuildContext context) {
    final palette = AppPalette(true);
    final presets = _filteredPresets();

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: palette.bg,
      drawer: VvGlobalDrawer(
        currentTab: VvNavTab.presets,
        onOpenEditor: widget.onOpenBuilder,
        onOpenMyShaders: widget.onOpenGallery,
        onOpenPresets: () {},
      ),
      appBar: AppBar(
        backgroundColor: palette.surface,
        elevation: 0,
        centerTitle: false,
        automaticallyImplyLeading: false,
        titleSpacing: 16,
        title: Row(
          children: [
            Container(
              width: 3.5,
              height: 18,
              decoration: BoxDecoration(
                color: const Color(0xFF22C55E),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 10),
            const Text(
              'SHADER PRESETS',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16.0,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.8,
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                // 1. Category Filter Bar
                SliverToBoxAdapter(
                  child: Container(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      physics: const BouncingScrollPhysics(),
                      child: Row(
                        children: _categories.map((cat) {
                          final isSel = _selectedCategory == cat;
                          return Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: GestureDetector(
                              onTap: () => setState(() => _selectedCategory = cat),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                  vertical: 7,
                                ),
                                decoration: BoxDecoration(
                                  color: isSel
                                      ? const Color(0xFF22C55E)
                                      : palette.surface,
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: isSel
                                        ? const Color(0xFF4ADE80)
                                        : palette.border,
                                    width: 1.0,
                                  ),
                                  boxShadow: isSel
                                      ? [
                                          BoxShadow(
                                            color: const Color(
                                              0xFF22C55E,
                                            ).withValues(alpha: 0.3),
                                            blurRadius: 8,
                                            offset: const Offset(0, 2),
                                          ),
                                        ]
                                      : null,
                                ),
                                child: Text(
                                  cat,
                                  style: TextStyle(
                                    color: isSel
                                        ? Colors.black
                                        : palette.textSecondary,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: 0.6,
                                  ),
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                ),

                // 2. Presets List
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 6, 16, 32),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate((context, index) {
                      final p = presets[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 14),
                        child: _buildPresetCard(context, p, palette),
                      );
                    }, childCount: presets.length),
                  ),
                ),
              ],
            ),
          ),

          // Shared Bottom Navigation Bar (Consistent with Home & Gallery)
          VvGlobalBottomNav(
            currentTab: VvNavTab.presets,
            onOpenHome: () => Navigator.popUntil(context, (r) => r.isFirst),
            onOpenBuilder: () => widget.onOpenBuilder?.call(),
            onOpenGallery: () => widget.onOpenGallery?.call(),
            onOpenPresets: () {},
            onOpenSettings: () {
              if (widget.onOpenSettings != null) {
                widget.onOpenSettings!();
              } else {
                _scaffoldKey.currentState?.openDrawer();
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildPresetCard(
    BuildContext context,
    ShaderPresetConfig p,
    AppPalette palette,
  ) {
    final accent = _getPresetAccent(p.id);
    final icon = _getPresetIcon(p.id);

    return InkWell(
      onTap: () => widget.onSelectPreset(p),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          color: palette.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: palette.border, width: 1.2),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.4),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 1. Sleek 4-Phase Sky Atmosphere Gradient Strip
            Container(
              height: 24,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    p.morningColor,
                    p.noonColor,
                    p.eveningColor,
                    p.nightColor,
                  ],
                  stops: const [0.0, 0.33, 0.66, 1.0],
                ),
              ),
              child: Row(
                children: const [
                  Icon(
                    Icons.wb_twilight_rounded,
                    size: 12,
                    color: Colors.white,
                  ),
                  SizedBox(width: 4),
                  Text(
                    'DAWN',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 8.5,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.8,
                      shadows: [Shadow(color: Colors.black87, blurRadius: 4)],
                    ),
                  ),
                  Spacer(),
                  Icon(Icons.wb_sunny_rounded, size: 12, color: Colors.white),
                  SizedBox(width: 4),
                  Text(
                    'NOON',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 8.5,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.8,
                      shadows: [Shadow(color: Colors.black87, blurRadius: 4)],
                    ),
                  ),
                  Spacer(),
                  Icon(
                    Icons.nights_stay_rounded,
                    size: 12,
                    color: Colors.white,
                  ),
                  SizedBox(width: 4),
                  Text(
                    'NIGHT',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 8.5,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.8,
                      shadows: [Shadow(color: Colors.black87, blurRadius: 4)],
                    ),
                  ),
                ],
              ),
            ),

            // 2. Main Preset Info & Action
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Icon badge
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: accent.withValues(alpha: 0.16),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: accent.withValues(alpha: 0.4),
                        width: 1.2,
                      ),
                    ),
                    child: Center(
                      child: AnimatedMinecraftIcon(type: icon, size: 26),
                    ),
                  ),
                  const SizedBox(width: 12),

                  // Preset title, description & chips
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          p.name,
                          style: TextStyle(
                            color: palette.textPrimary,
                            fontSize: 15.0,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.3,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          p.description,
                          style: TextStyle(
                            color: palette.textSecondary,
                            fontSize: 11.5,
                            height: 1.25,
                            fontWeight: FontWeight.w500,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 8),
                        // Clean Feature Badges
                        Wrap(
                          spacing: 6,
                          runSpacing: 4,
                          children: [
                            _featureBadge(p.toneMapFilter, accent, palette),
                            _featureBadge(
                              '${p.cloudType} Clouds',
                              accent,
                              palette,
                            ),
                            _featureBadge(
                              p.volumetricFogProfile == 'Cinematic'
                                  ? 'Cinematic Fog'
                                  : 'Light Mist',
                              accent,
                              palette,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(width: 10),

                  // Apply Button
                  ElevatedButton(
                    onPressed: () => widget.onSelectPreset(p),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF22C55E),
                      foregroundColor: Colors.black,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Icon(
                          Icons.check_rounded,
                          size: 15,
                          color: Colors.black,
                        ),
                        SizedBox(width: 4),
                        Text(
                          'APPLY',
                          style: TextStyle(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.6,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _featureBadge(String text, Color accent, AppPalette palette) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
      decoration: BoxDecoration(
        color: palette.border.withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(5),
        border: Border.all(
          color: palette.border.withValues(alpha: 0.6),
          width: 0.8,
        ),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: palette.textSecondary,
          fontSize: 9.5,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

/// Bottom sheet dialog for browsing and applying curated shader presets.
class PresetsModalSheet extends StatelessWidget {
  final Function(ShaderPresetConfig) onSelectPreset;
  const PresetsModalSheet({super.key, required this.onSelectPreset});

  @override
  Widget build(BuildContext context) {
    return ShaderPresetsScreen(onSelectPreset: onSelectPreset);
  }
}
