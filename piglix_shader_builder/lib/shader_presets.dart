import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'piglix_logo_data.dart';
import 'theme_controller.dart';
import 'vv_global_nav_bar.dart';
import 'vv_config.dart';

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

  /// Native Vibrant Visuals engine configuration for authentic rendering.
  final VVShaderConfig? vvConfig;

  /// Optional thumbnail image path (e.g. 'assets/screenshots/prizma.png' or network URL)
  final String? thumbnailPath;

  const ShaderPresetConfig({
    required this.id,
    required this.name,
    this.creator = 'Piglix Labs',
    required this.description,
    this.rating = 4.9,
    this.downloads = '12.4k',
    this.tags = const ['Vibrant Visuals', 'Deferred PBR', '60 FPS'],
    this.thumbnailPath,
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
    this.vvConfig,
  });
}

/// Curated official presets ready for one-tap application.
final List<ShaderPresetConfig> kDefaultShaderPresets = [
  const ShaderPresetConfig(
    id: 'prizma_visuals',
    name: 'Prizma Visuals',
    creator: 'Piglix Labs',
    description:
        'The community-favorite Prizma shader featuring delicate pastel pink & lilac sky horizons, soft rose bloom, and ACES filmic grading.',
    rating: 4.95,
    downloads: '85.4k',
    tags: ['Prizma', 'Pastel Pink', 'Lilac Sky', 'Community Top'],
    thumbnailPath: 'assets/screenshots/prizma_visuals.webp',
    morningColor: Color(0xFFFCE7F3),
    noonColor: Color(0xFFF472B6),
    eveningColor: Color(0xFFE879F9),
    nightColor: Color(0xFF1E1B4B),
    sunSize: 1.1,
    nightVision: 1.1,
    fogDensity: 0.95,
    cloudType: 'Realistic 3D',
    torchColor: Color(0xFFFFB050),
    lightIntensity: 1.0,
    blockLightIntensity: 1.1,
    shadowQuality: 'High',
    enablePointLightShadows: true,
    volumetricFogProfile: 'Cinematic',
    rayMorningColor: Color(0xFFF472B6),
    rayNoonColor: Color(0xFFFDF2F8),
    rayEveningColor: Color(0xFFC084FC),
    rayNightColor: Color(0xFF818CF8),
    waterColor: Color(0xFF38BDF8),
    windSpeed: 1.1,
    waterQuality: 'Ultra',
    underwaterCaustics: true,
    rainFogColor: Color(0xFF4A3E4E),
    rainWaterColor: Color(0xFF2E3D48),
    worldReflections: true,
    enablePBR: true,
    metalness: 0.05,
    wavingFoliage: true,
    foliageWaveSpeed: 1.0,
    toneMapFilter: 'ACES (Cinematic)',
    biomeTone: 'Vibrant',
    saturation: 1.04,
    contrast: 1.10,
    autoExposure: 1.0,
    vvConfig: VVShaderConfig(
      packName: 'Prizma Visuals',
      packDescription:
          'The community-favorite Prizma shader featuring delicate pastel pink & lilac sky horizons, soft rose bloom, and ACES filmic grading.',
      lighting: LightingConfig(
        sunBrightnessMultiplier: 0.9,
        sunColorNoon: Color(0xFFFFF0F5),
        sunColorSunrise: Color(0xFFF472B6),
        sunColorSunset: Color(0xFFE879F9),
        nightMoonColor: Color(0xFF818CF8),
        moonIlluminance: 2.0,
        ambientIlluminance: 0.15,
        ambientColor: Color(0xFF1A1A22),
        skyIntensity: 0.4,
        shadowStyle: 'soft_shadows',
        shadowTexelSize: 1024,
      ),
      atmosphere: AtmosphereConfig(
        rayleighNoon: 0.9,
        rayleighSunset: 0.6,
        rayleighSunrise: 0.7,
        rayleighNight: 0.4,
        sunGlowNoon: 2.5,
        noonZenith: Color(0xFFE9D5FF),
        noonHorizon: Color(0xFFFCE7F3),
        sunsetZenith: Color(0xFFC084FC),
        sunsetHorizon: Color(0xFFF472B6),
        nightZenith: Color(0xFF1E1B4B),
        nightHorizon: Color(0xFF312E81),
        sunriseZenith: Color(0xFFFBCFE8),
        sunriseHorizon: Color(0xFFF472B6),
      ),
      fog: FogConfig(
        airFogStart: 0.9,
        airFogEnd: 1.0,
        waterFogEnd: 60.0,
        waterFogColor: Color(0xFF38BDF8),
        volumetricMaxDensity: 0.045,
      ),
      colorGrading: ColorGradingConfig(
        toneMappingOperator: 'aces',
        midtonesContrast: [1.1, 1.1, 1.1],
        midtonesSaturation: [1.04, 1.04, 1.04],
        midtonesGain: [1.2, 1.2, 1.2],
      ),
    ),
  ),
  const ShaderPresetConfig(
    id: 'definitive_vibrant',
    name: 'Definitive Vibrant Visuals',
    creator: 'Piglix Labs',
    description:
        'Ultra-popular Bedrock deferred shader featuring rich autumn golden-amber sunlight, honey-orange sky horizons, and warm 60 FPS performance.',
    rating: 4.93,
    downloads: '78.1k',
    tags: ['Definitive', 'Autumn Amber', 'Golden Sunlight', 'Top Rated'],
    thumbnailPath: 'assets/screenshots/definitive_vibrant.webp',
    morningColor: Color(0xFFFFBE53),
    noonColor: Color(0xFFF59E0B),
    eveningColor: Color(0xFFEA580C),
    nightColor: Color(0xFF1C1917),
    sunSize: 1.0,
    nightVision: 1.0,
    fogDensity: 1.0,
    cloudType: 'Realistic 3D',
    torchColor: Color(0xFFFF9933),
    lightIntensity: 1.0,
    blockLightIntensity: 1.0,
    shadowQuality: 'High',
    enablePointLightShadows: true,
    volumetricFogProfile: 'Balanced',
    rayMorningColor: Color(0xFFFF9A3C),
    rayNoonColor: Color(0xFFFDE68A),
    rayEveningColor: Color(0xFFEA580C),
    rayNightColor: Color(0xFFF59E0B),
    waterColor: Color(0xFF0284C7),
    windSpeed: 1.0,
    waterQuality: 'High',
    underwaterCaustics: true,
    rainFogColor: Color(0xFF382E2B),
    rainWaterColor: Color(0xFF1E3A4B),
    worldReflections: true,
    enablePBR: true,
    metalness: 0.0,
    wavingFoliage: true,
    foliageWaveSpeed: 1.0,
    toneMapFilter: 'ACES (Cinematic)',
    biomeTone: 'Dynamic',
    saturation: 1.02,
    contrast: 1.25,
    autoExposure: 1.0,
    vvConfig: VVShaderConfig(
      packName: 'Definitive Vibrant Visuals',
      packDescription:
          'Ultra-popular Bedrock deferred shader featuring rich autumn golden-amber sunlight, honey-orange sky horizons, and warm 60 FPS performance.',
      lighting: LightingConfig(
        sunBrightnessMultiplier: 1.0,
        sunColorNoon: Color(0xFFFDE68A),
        sunColorSunrise: Color(0xFFFF9A3C),
        sunColorSunset: Color(0xFFEA580C),
        nightMoonColor: Color(0xFFFDE68A),
        moonIlluminance: 2.0,
        ambientIlluminance: 0.3,
        ambientColor: Color(0xFF1E1714),
        skyIntensity: 0.4,
        shadowStyle: 'soft_shadows',
        shadowTexelSize: 1024,
      ),
      atmosphere: AtmosphereConfig(
        rayleighNoon: 1.1,
        rayleighSunset: 0.5,
        rayleighSunrise: 0.7,
        rayleighNight: 0.9,
        sunGlowNoon: 0.3,
        sunGlowSunset: 0.4,
        sunGlowSunrise: 0.3,
        moonGlow: 2.2,
        noonZenith: Color(0xFFD97706),
        noonHorizon: Color(0xFFFEF3C7),
        sunsetZenith: Color(0xFFB45309),
        sunsetHorizon: Color(0xFFEA580C),
        nightZenith: Color(0xFF1C1917),
        nightHorizon: Color(0xFF292524),
        sunriseZenith: Color(0xFFF59E0B),
        sunriseHorizon: Color(0xFFFFBE53),
      ),
      fog: FogConfig(
        airFogStart: 0.9,
        airFogEnd: 1.0,
        waterFogEnd: 60.0,
        waterFogColor: Color(0xFF0284C7),
        volumetricMaxDensity: 0.045,
      ),
      colorGrading: ColorGradingConfig(
        toneMappingOperator: 'aces',
        midtonesContrast: [1.25, 1.25, 1.25],
        midtonesSaturation: [1.02, 1.02, 1.02],
        midtonesGain: [1.18, 1.18, 1.18],
      ),
    ),
  ),
  const ShaderPresetConfig(
    id: 'revolution_visuals',
    name: 'Revolution Vibrant Visuals',
    creator: 'Piglix Labs',
    description:
        'Ultra-bright and clean daylight shader with crystal-clear azure skies, pure white sunlight, vivid lime foliage, and sparkling lagoon waters.',
    rating: 4.90,
    downloads: '64.3k',
    tags: ['Revolution', 'Bright Clean', 'Crystal Skies', 'Marketplace Grade'],
    thumbnailPath: 'assets/screenshots/revolution_visuals.webp',
    morningColor: Color(0xFF7DD3FC),
    noonColor: Color(0xFF0284C7),
    eveningColor: Color(0xFF38BDF8),
    nightColor: Color(0xFF0F172A),
    sunSize: 1.1,
    nightVision: 1.0,
    fogDensity: 1.0,
    cloudType: 'Realistic 3D',
    torchColor: Color(0xFFFF9933),
    lightIntensity: 1.0,
    blockLightIntensity: 1.1,
    shadowQuality: 'High',
    enablePointLightShadows: true,
    volumetricFogProfile: 'Cinematic',
    rayMorningColor: Color(0xFFBAE6FD),
    rayNoonColor: Color(0xFFFFFFFF),
    rayEveningColor: Color(0xFF7DD3FC),
    rayNightColor: Color(0xFF38BDF8),
    waterColor: Color(0xFF06B6D4),
    windSpeed: 1.05,
    waterQuality: 'Ultra',
    underwaterCaustics: true,
    rainFogColor: Color(0xFF334155),
    rainWaterColor: Color(0xFF0284C7),
    worldReflections: true,
    enablePBR: true,
    metalness: 0.05,
    wavingFoliage: true,
    foliageWaveSpeed: 1.0,
    toneMapFilter: 'ACES (Cinematic)',
    biomeTone: 'Vibrant',
    saturation: 1.10,
    contrast: 1.05,
    autoExposure: 1.0,
    vvConfig: VVShaderConfig(
      packName: 'Revolution Vibrant Visuals',
      packDescription:
          'Ultra-bright and clean daylight shader with crystal-clear azure skies, pure white sunlight, vivid lime foliage, and sparkling lagoon waters.',
      lighting: LightingConfig(
        sunBrightnessMultiplier: 1.0,
        sunColorNoon: Color(0xFFFFFFFF),
        sunColorSunset: Color(0xFF7DD3FC),
        sunColorSunrise: Color(0xFFBAE6FD),
        ambientIlluminance: 0.3,
        ambientColor: Color(0xFF1E293B),
        skyIntensity: 0.4,
        shadowStyle: 'soft_shadows',
        shadowTexelSize: 1024,
      ),
      atmosphere: AtmosphereConfig(
        rayleighNoon: 1.15,
        sunGlowNoon: 0.3,
        noonZenith: Color(0xFF0284C7),
        noonHorizon: Color(0xFFE0F2FE),
        sunsetZenith: Color(0xFF38BDF8),
        sunsetHorizon: Color(0xFF7DD3FC),
        nightZenith: Color(0xFF0F172A),
        nightHorizon: Color(0xFF1E293B),
        sunriseZenith: Color(0xFF38BDF8),
        sunriseHorizon: Color(0xFFBAE6FD),
      ),
      fog: FogConfig(
        airFogStart: 0.9,
        airFogEnd: 1.0,
        waterFogEnd: 60.0,
        waterFogColor: Color(0xFF06B6D4),
        volumetricMaxDensity: 0.045,
      ),
      colorGrading: ColorGradingConfig(
        toneMappingOperator: 'aces',
        midtonesContrast: [1.05, 1.05, 1.05],
        midtonesSaturation: [1.104, 1.104, 1.104],
        midtonesGain: [1.0, 1.0, 1.0],
      ),
    ),
  ),
  const ShaderPresetConfig(
    id: 'luminous_dreams',
    name: 'Luminous Dreams',
    creator: 'Piglix Labs',
    description:
        'The legendary high-lux vibrant shader with crystalline cyan tropical waters, 181-lux golden sunlight, deep blue night skies, and filmic Hable tonemapping.',
    rating: 4.92,
    downloads: '72.9k',
    tags: ['Luminous', 'Filmic Hable', '181 Lux', 'Legendary'],
    thumbnailPath: 'assets/screenshots/luminous_dreams.webp',
    morningColor: Color(0xFFFFA0B2),
    noonColor: Color(0xFF5B7AFF),
    eveningColor: Color(0xFFFF5A20),
    nightColor: Color(0xFF0E225C),
    sunSize: 1.35,
    nightVision: 1.15,
    fogDensity: 1.05,
    cloudType: 'Realistic 3D',
    torchColor: Color(0xFFFFA033),
    lightIntensity: 1.0,
    blockLightIntensity: 1.25,
    shadowQuality: 'Ultra',
    enablePointLightShadows: true,
    volumetricFogProfile: 'Cinematic',
    rayMorningColor: Color(0xFFFFB050),
    rayNoonColor: Color(0xFFFFD5AF),
    rayEveningColor: Color(0xFFFF2A0F),
    rayNightColor: Color(0xFF051EFF),
    waterColor: Color(0xFF1B9ED8),
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
    toneMapFilter: 'Hable (Filmic)',
    biomeTone: 'Vibrant',
    saturation: 1.03,
    contrast: 1.35,
    autoExposure: 1.1,
    vvConfig: VVShaderConfig(
      packName: 'Luminous Dreams',
      packDescription:
          'The legendary high-lux vibrant shader with crystalline cyan tropical waters, 181-lux golden sunlight, deep blue night skies, and filmic Hable tonemapping.',
      lighting: LightingConfig(
        sunBrightnessMultiplier: 1.0,
        sunColorNoon: Color(0xFFFFD5AF),
        sunColorSunset: Color(0xFFFF2A0F),
        nightMoonColor: Color(0xFF051EFF),
        moonIlluminance: 2.1,
        ambientIlluminance: 0.07,
        ambientColor: Color(0xFF1E232D),
        skyIntensity: 0.3,
        shadowStyle: 'soft_shadows',
        shadowTexelSize: 1024,
      ),
      atmosphere: AtmosphereConfig(
        rayleighNoon: 2.2,
        rayleighSunset: 2.86,
        sunGlowNoon: 4.0,
        noonZenith: Color(0xFF5B7AFF),
        noonHorizon: Color(0xFFD7EFFD),
        sunsetZenith: Color(0xFFB9BFFC),
        sunsetHorizon: Color(0xFFFFDBCF),
        nightZenith: Color(0xFF0E225C),
        nightHorizon: Color(0xFF344B87),
      ),
      fog: FogConfig(
        airFogStart: 0.9,
        airFogEnd: 1.0,
        waterFogEnd: 60.0,
        waterFogColor: Color(0xFF1B9ED8),
        volumetricMaxDensity: 0.045,
      ),
      colorGrading: ColorGradingConfig(
        toneMappingOperator: 'hable',
        midtonesContrast: [1.35, 1.35, 1.35],
        midtonesSaturation: [1.03, 1.03, 1.03],
        midtonesGain: [1.05, 1.04, 1.03],
      ),
    ),
  ),
  const ShaderPresetConfig(
    id: 'bslb_dreamy',
    name: 'BSLB Dreamy Visuals',
    creator: 'Piglix Labs',
    description:
        'Ethereal dreamy lighting with soft atmospheric bloom, boosted 1.15x saturation, smooth ambient color transitions, and gentle fog density.',
    rating: 4.89,
    downloads: '44.6k',
    tags: ['Dreamy', 'Ethereal', 'Soft Bloom', 'ACES'],
    thumbnailPath: 'assets/screenshots/bslb_dreamy.webp',
    morningColor: Color(0xFFFFB482),
    noonColor: Color(0xFF78A0FF),
    eveningColor: Color(0xFFFF643C),
    nightColor: Color(0xFF1C2238),
    sunSize: 1.2,
    nightVision: 1.05,
    fogDensity: 1.0,
    cloudType: 'Realistic 3D',
    torchColor: Color(0xFFFFA040),
    lightIntensity: 1.0,
    blockLightIntensity: 1.0,
    shadowQuality: 'High',
    enablePointLightShadows: true,
    volumetricFogProfile: 'Balanced',
    rayMorningColor: Color(0xFFFFB482),
    rayNoonColor: Color(0xFFFFF0DC),
    rayEveningColor: Color(0xFFFF643C),
    rayNightColor: Color(0xFF465078),
    waterColor: Color(0xFF22B4DC),
    windSpeed: 1.1,
    waterQuality: 'High',
    underwaterCaustics: true,
    rainFogColor: Color(0xFF404858),
    rainWaterColor: Color(0xFF22B4DC),
    worldReflections: true,
    enablePBR: true,
    metalness: 0.05,
    wavingFoliage: true,
    foliageWaveSpeed: 1.0,
    toneMapFilter: 'ACES (Cinematic)',
    biomeTone: 'Dynamic',
    saturation: 1.15,
    contrast: 1.15,
    autoExposure: 1.0,
    vvConfig: VVShaderConfig(
      packName: 'BSLB Dreamy Visuals',
      packDescription:
          'Ethereal dreamy lighting with soft atmospheric bloom, boosted 1.15x saturation, smooth ambient color transitions, and gentle fog density.',
      lighting: LightingConfig(
        sunBrightnessMultiplier: 1.0,
        sunColorNoon: Color(0xFFFFF0DC),
        sunColorSunset: Color(0xFFFF643C),
        ambientIlluminance: 0.12,
        ambientColor: Color(0xFF26282C),
        skyIntensity: 0.28,
        shadowStyle: 'soft_shadows',
        shadowTexelSize: 1024,
      ),
      atmosphere: AtmosphereConfig(
        rayleighNoon: 1.6,
        sunGlowNoon: 3.8,
        noonZenith: Color(0xFF6E94E8),
        noonHorizon: Color(0xFFE2EAF8),
        sunsetZenith: Color(0xFFB078B8),
        sunsetHorizon: Color(0xFFFF9E78),
        nightZenith: Color(0xFF14182E),
        nightHorizon: Color(0xFF2E3858),
      ),
      fog: FogConfig(
        airFogStart: 0.88,
        airFogEnd: 1.0,
        waterFogEnd: 55.0,
        waterFogColor: Color(0xFF22B4DC),
        volumetricMaxDensity: 0.05,
      ),
      colorGrading: ColorGradingConfig(
        toneMappingOperator: 'aces',
        midtonesContrast: [1.16, 1.15, 1.14],
        midtonesSaturation: [1.10, 1.15, 1.10],
        midtonesGain: [0.94, 0.98, 0.945],
      ),
    ),
  ),
  const ShaderPresetConfig(
    id: 'better_vibrant',
    name: 'Better Vibrant Visuals',
    creator: 'Piglix Labs',
    description:
        'Natural, crisp daylight illumination with warm 155-lux cream sun shafts, rich deep sky gradients, and 1.3x filmic contrast.',
    rating: 4.90,
    downloads: '48.3k',
    tags: ['Natural Light', 'Warm Sun', 'Cinematic', '60 FPS'],
    thumbnailPath: 'assets/screenshots/better_vibrant.webp',
    morningColor: Color(0xFFFFA040),
    noonColor: Color(0xFF6782AA),
    eveningColor: Color(0xFFFFBBA3),
    nightColor: Color(0xFF282828),
    sunSize: 1.0,
    nightVision: 1.0,
    fogDensity: 1.0,
    cloudType: 'Realistic 3D',
    torchColor: Color(0xFFFF9933),
    lightIntensity: 1.0,
    blockLightIntensity: 1.0,
    shadowQuality: 'High',
    enablePointLightShadows: true,
    volumetricFogProfile: 'Balanced',
    rayMorningColor: Color(0xFFFFB050),
    rayNoonColor: Color(0xFFFFE1B9),
    rayEveningColor: Color(0xFFFF7828),
    rayNightColor: Color(0xFF303030),
    waterColor: Color(0xFF0A2573),
    windSpeed: 1.0,
    waterQuality: 'High',
    underwaterCaustics: true,
    rainFogColor: Color(0xFF404040),
    rainWaterColor: Color(0xFF0A2573),
    worldReflections: true,
    enablePBR: true,
    metalness: 0.0,
    wavingFoliage: true,
    foliageWaveSpeed: 1.0,
    toneMapFilter: 'Hable (Filmic)',
    biomeTone: 'Dynamic',
    saturation: 1.05,
    contrast: 1.30,
    autoExposure: 1.0,
    vvConfig: VVShaderConfig(
      packName: 'Better Vibrant Visuals',
      packDescription:
          'Natural, crisp daylight illumination with warm 155-lux cream sun shafts, rich deep sky gradients, and 1.3x filmic contrast.',
      lighting: LightingConfig(
        sunBrightnessMultiplier: 1.0,
        sunColorNoon: Color(0xFFFFE1B9),
        sunColorSunrise: Color(0xFFFFB050),
        sunColorSunset: Color(0xFFFF7828),
        nightMoonColor: Color(0xFF051EFF),
        moonIlluminance: 1.5,
        ambientIlluminance: 0.2,
        ambientColor: Color(0xFF000000),
        skyIntensity: 0.45,
        shadowStyle: 'soft_shadows',
        shadowTexelSize: 1024,
      ),
      atmosphere: AtmosphereConfig(
        rayleighNoon: 1.8,
        sunGlowNoon: 3.5,
        noonZenith: Color(0xFF6782AA),
        noonHorizon: Color(0xFFB7BDC6),
        sunsetZenith: Color(0xFF101488),
        sunsetHorizon: Color(0xFFFFBBA3),
        nightZenith: Color(0xFF282828),
        nightHorizon: Color(0xFF2B2B2B),
        sunriseZenith: Color(0xFF88A0D0),
        sunriseHorizon: Color(0xFFFFD5AF),
      ),
      fog: FogConfig(
        airFogStart: 0.9,
        airFogEnd: 1.0,
        waterFogEnd: 60.0,
        waterFogColor: Color(0xFF1B9ED8),
        volumetricMaxDensity: 0.045,
      ),
      colorGrading: ColorGradingConfig(
        toneMappingOperator: 'hable',
        midtonesContrast: [1.30, 1.30, 1.30],
        midtonesSaturation: [1.05, 1.05, 1.05],
        midtonesGain: [1.0, 1.0, 1.0],
      ),
    ),
  ),
];

// ─────────────────────────────────────────────────────────────────
//  PRESET & GALLERY PACKAGE ICON GENERATOR
// ─────────────────────────────────────────────────────────────────

Color presetAccentColor(ShaderPresetConfig p) {
  switch (p.id) {
    case 'prizma_visuals':
      return const Color(0xFFF472B6); // Soft Rose & Lilac Pink
    case 'definitive_vibrant':
      return const Color(0xFFF59E0B); // Autumn Golden Amber
    case 'revolution_visuals':
      return const Color(0xFF38BDF8); // Bright Clean Sky Azure
    case 'luminous_dreams':
      return const Color(0xFF22C55E); // Emerald Cyan
    case 'bslb_dreamy':
      return const Color(0xFF818CF8); // Dreamy Violet Bloom
    case 'better_vibrant':
      return const Color(0xFFFBBF24); // Warm Gold
    default:
      return const Color(0xFF22C55E);
  }
}

/// Returns the official app logo as the default package icon for curated presets.
Future<Uint8List> getOrGeneratePresetPackIcon(ShaderPresetConfig preset) async {
  return kPiglixLogoBytes;
}

/// Returns the official app logo as the default package icon for items.
Future<Uint8List> generateShaderItemPackIcon(String name, Color? previewColor) async {
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
    'BALANCED (60FPS)',
    'CINEMATIC',
    'ATMOSPHERE',
  ];

  List<ShaderPresetConfig> _filteredPresets() {
    switch (_selectedCategory) {
      case 'POPULAR':
        return kDefaultShaderPresets
            .where(
              (p) =>
                  p.id == 'prizma_visuals' ||
                  p.id == 'definitive_vibrant' ||
                  p.id == 'revolution_visuals' ||
                  p.id == 'luminous_dreams',
            )
            .toList();
      case 'BALANCED (60FPS)':
        return kDefaultShaderPresets
            .where(
              (p) =>
                  p.id == 'definitive_vibrant' ||
                  p.id == 'better_vibrant' ||
                  p.id == 'revolution_visuals',
            )
            .toList();
      case 'CINEMATIC':
        return kDefaultShaderPresets
            .where(
              (p) =>
                  p.id == 'prizma_visuals' ||
                  p.id == 'luminous_dreams' ||
                  p.id == 'bslb_dreamy',
            )
            .toList();
      case 'ATMOSPHERE':
        return kDefaultShaderPresets
            .where(
              (p) =>
                  p.id == 'prizma_visuals' ||
                  p.id == 'bslb_dreamy',
            )
            .toList();
      default:
        return kDefaultShaderPresets;
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
              _scaffoldKey.currentState?.openDrawer();
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

    return Container(
      decoration: BoxDecoration(
        color: palette.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: palette.border, width: 1.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.35),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => widget.onSelectPreset(p),
          borderRadius: BorderRadius.circular(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 1. Catchy 16:9 Thumbnail Image with ONLY the Rating Badge
              _PresetThumbnail(preset: p, accent: accent),

              // 2. Compact Details Section (Large Shader Name + Little Description)
              Padding(
                padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Large Shader Name
                    Text(
                      p.name,
                      style: TextStyle(
                        color: palette.textPrimary,
                        fontSize: 17.0,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.3,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),

                    // Little Description
                    Text(
                      p.description,
                      style: TextStyle(
                        color: palette.textSecondary,
                        fontSize: 12.0,
                        height: 1.35,
                        fontWeight: FontWeight.w400,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),

                    const SizedBox(height: 12),

                    // Better "APPLY PRESET" Button with Creeper Face Icon
                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF22C55E), Color(0xFF16A34A)],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [
                          BoxShadow(
                            color:
                                const Color(0xFF22C55E).withValues(alpha: 0.28),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: ElevatedButton(
                        onPressed: () => widget.onSelectPreset(p),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          foregroundColor: Colors.black,
                          shadowColor: Colors.transparent,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            CreeperFaceIcon(size: 18, color: Colors.black),
                            SizedBox(width: 8),
                            Text(
                              'APPLY PRESET',
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 12.5,
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
            ],
          ),
        ),
      ),
    );
  }
}

/// Minecraft Creeper Face Icon rendered pixel-perfect on an 8x8 voxel grid.
class CreeperFaceIcon extends StatelessWidget {
  final double size;
  final Color color;

  const CreeperFaceIcon({
    super.key,
    this.size = 18.0,
    this.color = Colors.black,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _CreeperFacePainter(color: color),
      ),
    );
  }
}

class _CreeperFacePainter extends CustomPainter {
  final Color color;
  const _CreeperFacePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final u = size.width / 8.0;

    // Standard Minecraft Creeper Face 8x8 Grid
    const grid = [
      [0, 0, 0, 0, 0, 0, 0, 0],
      [0, 0, 0, 0, 0, 0, 0, 0],
      [0, 1, 1, 0, 0, 1, 1, 0], // Eyes
      [0, 1, 1, 1, 1, 1, 1, 0], // Eye bottom + nose top
      [0, 0, 0, 1, 1, 0, 0, 0], // Nose middle
      [0, 1, 1, 1, 1, 1, 1, 0], // Mouth top
      [0, 1, 1, 0, 0, 1, 1, 0], // Mouth drops
      [0, 0, 0, 0, 0, 0, 0, 0],
    ];

    for (int y = 0; y < 8; y++) {
      for (int x = 0; x < 8; x++) {
        if (grid[y][x] == 1) {
          canvas.drawRect(
            Rect.fromLTWH(x * u, y * u, u + 0.25, u + 0.25),
            paint,
          );
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant _CreeperFacePainter oldDelegate) =>
      oldDelegate.color != color;
}

/// 16:9 widescreen preset video thumbnail widget.
/// Displays an image asset / public screenshot, with ONLY the rating badge on top-right.
class _PresetThumbnail extends StatelessWidget {
  final ShaderPresetConfig preset;
  final Color accent;

  const _PresetThumbnail({
    required this.preset,
    required this.accent,
  });

  @override
  Widget build(BuildContext context) {
    Widget content;
    final thumb = preset.thumbnailPath ?? 'assets/screenshots/${preset.id}.png';
    content = Image.asset(
      thumb,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) => Image.network(
        'public/presets/${preset.id}.png',
        fit: BoxFit.cover,
        errorBuilder: (c, e, s) => Image.network(
          'presets/${preset.id}.png',
          fit: BoxFit.cover,
          errorBuilder: (c2, e2, s2) => _buildFallbackPainter(),
        ),
      ),
    );

    return AspectRatio(
      aspectRatio: 16 / 9,
      child: Stack(
        fit: StackFit.expand,
        children: [
          content,

          // Subtle gradient scrim overlay for readability of the rating badge
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withValues(alpha: 0.35),
                  Colors.transparent,
                  Colors.black.withValues(alpha: 0.45),
                ],
                stops: const [0.0, 0.45, 1.0],
              ),
            ),
          ),

          // Rating Badge is ONLY! (Top-Right)
          Positioned(
            top: 10,
            right: 10,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.80),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: const Color(0xFFFBBF24).withValues(alpha: 0.4),
                  width: 0.8,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.4),
                    blurRadius: 6,
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.star_rounded,
                    color: Color(0xFFFBBF24),
                    size: 14,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    preset.rating.toStringAsFixed(2),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Bottom-Edge Atmosphere Color Gradient Strip
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              height: 3.0,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    preset.morningColor,
                    preset.noonColor,
                    preset.eveningColor,
                    preset.nightColor,
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFallbackPainter() {
    return CustomPaint(
      painter: _PresetAtmosphereScenePainter(
        preset: preset,
        accent: accent,
      ),
      size: Size.infinite,
    );
  }
}

/// Dynamic procedural Minecraft shader scene painter for presets when no image file is loaded yet.
/// Renders an authentic Minecraft deferred atmosphere with glowing bloom sun, voxel clouds,
/// distant mountain silhouettes, and water surface with specular reflection & caustics.
class _PresetAtmosphereScenePainter extends CustomPainter {
  final ShaderPresetConfig preset;
  final Color accent;

  const _PresetAtmosphereScenePainter({
    required this.preset,
    required this.accent,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final horizonY = h * 0.60;

    // 1. Sky Gradient (Zenith to Horizon)
    final skyPaint = Paint()
      ..shader = ui.Gradient.linear(
        Offset(w * 0.5, 0),
        Offset(w * 0.5, horizonY),
        [
          preset.noonColor,
          preset.morningColor.withValues(alpha: 0.85),
          preset.eveningColor,
        ],
        [0.0, 0.55, 1.0],
      );
    canvas.drawRect(Rect.fromLTWH(0, 0, w, horizonY + 2), skyPaint);

    // 2. Glowing Sun with Mie Scattering Bloom
    final sunX = w * 0.74;
    final sunY = horizonY * 0.40;

    // Outer bloom halo
    final bloomPaint = Paint()
      ..shader = ui.Gradient.radial(
        Offset(sunX, sunY),
        w * 0.32,
        [
          preset.rayNoonColor.withValues(alpha: 0.45),
          preset.rayEveningColor.withValues(alpha: 0.15),
          Colors.transparent,
        ],
        [0.0, 0.4, 1.0],
      );
    canvas.drawCircle(Offset(sunX, sunY), w * 0.32, bloomPaint);

    // Sun Disc (Minecraft square style)
    final sunDiscPaint = Paint()..color = Colors.white;
    final sunSize = 16.0 * preset.sunSize.clamp(0.8, 1.6);
    canvas.drawRect(
      Rect.fromCenter(
        center: Offset(sunX, sunY),
        width: sunSize,
        height: sunSize,
      ),
      sunDiscPaint,
    );

    // Subtle volumetric God ray polygon
    final rayPaint = Paint()
      ..shader = ui.Gradient.linear(
        Offset(sunX, sunY),
        Offset(w * 0.5, horizonY),
        [
          preset.rayMorningColor.withValues(alpha: 0.20),
          Colors.transparent,
        ],
      );
    final rayPath = Path()
      ..moveTo(sunX - sunSize * 0.5, sunY + sunSize * 0.5)
      ..lineTo(w * 0.20, horizonY)
      ..lineTo(w * 0.52, horizonY)
      ..lineTo(sunX + sunSize * 0.5, sunY + sunSize * 0.5)
      ..close();
    canvas.drawPath(rayPath, rayPaint);

    // 3. Volumetric Minecraft Clouds
    final cloudPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.38)
      ..style = PaintingStyle.fill;
    final cloudShadowPaint = Paint()
      ..color = preset.noonColor.withValues(alpha: 0.25)
      ..style = PaintingStyle.fill;

    _drawVoxelCloud(
        canvas, w * 0.08, h * 0.12, 110, 16, cloudPaint, cloudShadowPaint);
    _drawVoxelCloud(
        canvas, w * 0.46, h * 0.22, 130, 18, cloudPaint, cloudShadowPaint);

    // 4. Distant Mountain Silhouette
    final distantMtnPaint = Paint()
      ..color = Color.alphaBlend(
        preset.rainFogColor.withValues(alpha: 0.65),
        preset.noonColor,
      );
    final mtnPath = Path()
      ..moveTo(0, horizonY)
      ..lineTo(0, horizonY - 24)
      ..lineTo(w * 0.12, horizonY - 38)
      ..lineTo(w * 0.24, horizonY - 20)
      ..lineTo(w * 0.40, horizonY - 50)
      ..lineTo(w * 0.56, horizonY - 28)
      ..lineTo(w * 0.70, horizonY - 44)
      ..lineTo(w * 0.86, horizonY - 18)
      ..lineTo(w, horizonY - 32)
      ..lineTo(w, horizonY)
      ..close();
    canvas.drawPath(mtnPath, distantMtnPaint);

    // 5. Water Plane (Horizon to Bottom)
    final waterPaint = Paint()
      ..shader = ui.Gradient.linear(
        Offset(w * 0.5, horizonY),
        Offset(w * 0.5, h),
        [
          preset.waterColor.withValues(alpha: 0.85),
          preset.waterColor,
          preset.rainWaterColor,
        ],
        [0.0, 0.4, 1.0],
      );
    canvas.drawRect(Rect.fromLTWH(0, horizonY, w, h - horizonY), waterPaint);

    // Sun vertical specular reflection trail on water
    final reflectPaint = Paint()
      ..shader = ui.Gradient.linear(
        Offset(sunX, horizonY),
        Offset(sunX, h),
        [
          preset.rayNoonColor.withValues(alpha: 0.55),
          preset.eveningColor.withValues(alpha: 0.25),
          Colors.transparent,
        ],
        [0.0, 0.5, 1.0],
      );
    final reflectPath = Path()
      ..moveTo(sunX - 10, horizonY)
      ..lineTo(sunX + 10, horizonY)
      ..lineTo(sunX + 32, h)
      ..lineTo(sunX - 32, h)
      ..close();
    canvas.drawPath(reflectPath, reflectPaint);

    // Caustics shimmer lines
    final wavePaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.22)
      ..strokeWidth = 1.2
      ..style = PaintingStyle.stroke;
    for (int i = 0; i < 5; i++) {
      final waveY = horizonY + 8 + i * 12;
      canvas.drawLine(
        Offset(sunX - 25 - i * 8, waveY),
        Offset(sunX + 25 + i * 8, waveY),
        wavePaint,
      );
    }

    // 6. Foreground Grassy Shoreline (Bottom Left)
    final shorePaint = Paint()
      ..color = const Color(0xFF1E3922)
      ..style = PaintingStyle.fill;
    final shorePath = Path()
      ..moveTo(0, h)
      ..lineTo(0, horizonY - 8)
      ..lineTo(w * 0.16, horizonY + 6)
      ..lineTo(w * 0.30, horizonY + 22)
      ..lineTo(w * 0.22, h)
      ..close();
    canvas.drawPath(shorePath, shorePaint);

    // Grass edge rim highlight catching sunlight
    final grassRimPaint = Paint()
      ..color = accent.withValues(alpha: 0.8)
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;
    final grassRim = Path()
      ..moveTo(0, horizonY - 8)
      ..lineTo(w * 0.16, horizonY + 6)
      ..lineTo(w * 0.30, horizonY + 22);
    canvas.drawPath(grassRim, grassRimPaint);

    // Blocky oak tree silhouette
    final trunkPaint = Paint()..color = const Color(0xFF2C1E14);
    canvas.drawRect(
      Rect.fromLTWH(w * 0.07, horizonY - 26, 7, 22),
      trunkPaint,
    );
    final leavesPaint = Paint()..color = const Color(0xFF1B4D20);
    canvas.drawRect(
      Rect.fromLTWH(w * 0.035, horizonY - 48, 22, 22),
      leavesPaint,
    );
    canvas.drawRect(
      Rect.fromLTWH(w * 0.055, horizonY - 56, 14, 10),
      leavesPaint,
    );
  }

  void _drawVoxelCloud(
    Canvas canvas,
    double x,
    double y,
    double width,
    double height,
    Paint mainPaint,
    Paint shadowPaint,
  ) {
    canvas.drawRect(Rect.fromLTWH(x, y, width, height * 0.7), mainPaint);
    canvas.drawRect(
        Rect.fromLTWH(x + 16, y - height * 0.4, width * 0.6, height * 0.4),
        mainPaint);
    canvas.drawRect(
        Rect.fromLTWH(x, y + height * 0.7, width, height * 0.3), shadowPaint);
  }

  @override
  bool shouldRepaint(covariant _PresetAtmosphereScenePainter oldDelegate) {
    return oldDelegate.preset.id != preset.id || oldDelegate.accent != accent;
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
