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
        'The community-favorite Prizma shader featuring delicate crystal lilac sky horizons, soft periwinkle daylight, glowing sunset coral, and ACES filmic grading.',
    rating: 4.95,
    downloads: '85.4k',
    tags: ['Prizma', 'Lilac Sky', 'ACES', 'Community Top'],
    morningColor: Color(0xFFE8D0F5),
    noonColor: Color(0xFFA0ACEB),
    eveningColor: Color(0xFFF08C64),
    nightColor: Color(0xFF0F4B3C),
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
    rayMorningColor: Color(0xFFFFB050),
    rayNoonColor: Color(0xFFFAFCFF),
    rayEveningColor: Color(0xFFF08C64),
    rayNightColor: Color(0xFF32AFEB),
    waterColor: Color(0xFF1B9ED8),
    windSpeed: 1.1,
    waterQuality: 'Ultra',
    underwaterCaustics: true,
    rainFogColor: Color(0xFF3A4050),
    rainWaterColor: Color(0xFF1B9ED8),
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
          'The community-favorite Prizma shader featuring delicate crystal lilac sky horizons, soft periwinkle daylight, glowing sunset coral, and ACES filmic grading.',
      lighting: LightingConfig(
        sunBrightnessMultiplier: 0.9,
        sunColorNoon: Color(0xFFFAFAFA),
        sunColorSunrise: Color(0xFFFFB050),
        sunColorSunset: Color(0xFFF08C64),
        nightMoonColor: Color(0xFF32AFEB),
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
        noonZenith: Color(0xFFA0ACEB),
        noonHorizon: Color(0xFFF5E8FF),
        sunsetZenith: Color(0xFF826E6E),
        sunsetHorizon: Color(0xFFF08C64),
        nightZenith: Color(0xFF0F4B3C),
        nightHorizon: Color(0xFF32AFEB),
        sunriseZenith: Color(0xFF826E78),
        sunriseHorizon: Color(0xFFF08C64),
      ),
      fog: FogConfig(
        airFogStart: 0.9,
        airFogEnd: 1.0,
        waterFogEnd: 60.0,
        waterFogColor: Color(0xFF1B9ED8),
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
        'Ultra-popular Bedrock deferred shader featuring rich azure sky zenith, warm 140-lux golden daylight, ACES contrast, and optimized 60 FPS performance.',
    rating: 4.93,
    downloads: '78.1k',
    tags: ['Definitive', 'Azure Sky', '60 FPS', 'Top Rated'],
    morningColor: Color(0xFF3CA0FF),
    noonColor: Color(0xFF0A6EC8),
    eveningColor: Color(0xFFFF8264),
    nightColor: Color(0xFF002864),
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
    rayMorningColor: Color(0xFFFF460A),
    rayNoonColor: Color(0xFFFFDC82),
    rayEveningColor: Color(0xFFFF3200),
    rayNightColor: Color(0xFF002864),
    waterColor: Color(0xFF1B9ED8),
    windSpeed: 1.0,
    waterQuality: 'High',
    underwaterCaustics: true,
    rainFogColor: Color(0xFF303030),
    rainWaterColor: Color(0xFF1B9ED8),
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
          'Ultra-popular Bedrock deferred shader featuring rich azure sky zenith, warm 140-lux golden daylight, ACES contrast, and optimized 60 FPS performance.',
      lighting: LightingConfig(
        sunBrightnessMultiplier: 1.0,
        sunColorNoon: Color(0xFFFFDC82),
        sunColorSunrise: Color(0xFFFF460A),
        sunColorSunset: Color(0xFFFF3200),
        nightMoonColor: Color(0xFF002864),
        moonIlluminance: 2.0,
        ambientIlluminance: 0.3,
        ambientColor: Color(0xFF141419),
        skyIntensity: 0.4,
        shadowStyle: 'soft_shadows',
        shadowTexelSize: 1024,
      ),
      atmosphere: AtmosphereConfig(
        rayleighNoon: 1.1,
        rayleighSunset: 0.5,
        rayleighSunrise: 0.7,
        rayleighNight: 0.9,
        sunGlowNoon: 0.2,
        sunGlowSunset: 0.2,
        sunGlowSunrise: 0.2,
        moonGlow: 2.2,
        noonZenith: Color(0xFF0A6EC8),
        noonHorizon: Color(0xFFA0DCFF),
        sunsetZenith: Color(0xFF5A96FA),
        sunsetHorizon: Color(0xFFFF8264),
        nightZenith: Color(0xFF002864),
        nightHorizon: Color(0xFF2B2B2B),
        sunriseZenith: Color(0xFF3CA0FF),
        sunriseHorizon: Color(0xFFFF8E7D),
      ),
      fog: FogConfig(
        airFogStart: 0.9,
        airFogEnd: 1.0,
        waterFogEnd: 60.0,
        waterFogColor: Color(0xFF1B9ED8),
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
        'Competition-grade marketplace visual fidelity with vibrant 1.1x saturation, warm peach-cream noon, and dramatic fiery orange sunset horizons.',
    rating: 4.90,
    downloads: '64.3k',
    tags: ['Revolution', 'Vibrant', 'Fiery Sunset', 'Marketplace Grade'],
    morningColor: Color(0xFF5A96FA),
    noonColor: Color(0xFF5A96FA),
    eveningColor: Color(0xFFFF8200),
    nightColor: Color(0xFF0A1E50),
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
    rayMorningColor: Color(0xFFFF8200),
    rayNoonColor: Color(0xFFFFE1CD),
    rayEveningColor: Color(0xFFFF1E0A),
    rayNightColor: Color(0xFF1E3CA0),
    waterColor: Color(0xFF1B9ED8),
    windSpeed: 1.05,
    waterQuality: 'Ultra',
    underwaterCaustics: true,
    rainFogColor: Color(0xFF303848),
    rainWaterColor: Color(0xFF1B9ED8),
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
          'Competition-grade marketplace visual fidelity with vibrant 1.1x saturation, warm peach-cream noon, and dramatic fiery orange sunset horizons.',
      lighting: LightingConfig(
        sunBrightnessMultiplier: 1.0,
        sunColorNoon: Color(0xFFFFE1CD),
        sunColorSunset: Color(0xFFFF1E0A),
        ambientIlluminance: 0.3,
        ambientColor: Color(0xFF232323),
        skyIntensity: 0.4,
        shadowStyle: 'soft_shadows',
        shadowTexelSize: 1024,
      ),
      atmosphere: AtmosphereConfig(
        rayleighNoon: 1.15,
        sunGlowNoon: 0.3,
        noonZenith: Color(0xFF5A96FA),
        noonHorizon: Color(0xFFCDEBFF),
        sunsetZenith: Color(0xFF5A96FA),
        sunsetHorizon: Color(0xFFFF8200),
        nightZenith: Color(0xFF0A1E50),
        nightHorizon: Color(0xFF202840),
        sunriseZenith: Color(0xFF5A96FA),
        sunriseHorizon: Color(0xFFFF8200),
      ),
      fog: FogConfig(
        airFogStart: 0.9,
        airFogEnd: 1.0,
        waterFogEnd: 60.0,
        waterFogColor: Color(0xFF1B9ED8),
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
    id: 'dark_fantasy',
    name: 'Dark Fantasy (Dark Souls)',
    creator: 'Piglix Labs',
    description:
        'Grim, moody atmosphere inspired by Dark Souls with desaturated earthy tones, somber copper dusk horizons, Reinhard tonemapping, and blood-red sunset.',
    rating: 4.88,
    downloads: '51.7k',
    tags: ['Dark Souls', 'Grim Fantasy', 'Reinhard', 'Moody'],
    morningColor: Color(0xFFB48250),
    noonColor: Color(0xFF677B78),
    eveningColor: Color(0xFFE8823C),
    nightColor: Color(0xFF0F1420),
    sunSize: 0.9,
    nightVision: 1.3,
    fogDensity: 1.3,
    cloudType: 'Realistic 3D',
    torchColor: Color(0xFFFF7820),
    lightIntensity: 0.85,
    blockLightIntensity: 1.3,
    shadowQuality: 'Ultra',
    enablePointLightShadows: true,
    volumetricFogProfile: 'Cinematic',
    rayMorningColor: Color(0xFFB48250),
    rayNoonColor: Color(0xFFB4A664),
    rayEveningColor: Color(0xFFFF5014),
    rayNightColor: Color(0xFF55648C),
    waterColor: Color(0xFF28323C),
    windSpeed: 0.8,
    waterQuality: 'High',
    underwaterCaustics: false,
    rainFogColor: Color(0xFF202528),
    rainWaterColor: Color(0xFF151820),
    worldReflections: true,
    enablePBR: true,
    metalness: 0.35,
    wavingFoliage: true,
    foliageWaveSpeed: 0.7,
    toneMapFilter: 'Reinhard',
    biomeTone: 'Moody',
    saturation: 0.82,
    contrast: 1.30,
    autoExposure: 0.9,
    vvConfig: VVShaderConfig(
      packName: 'Dark Fantasy (Dark Souls)',
      packDescription:
          'Grim, moody atmosphere inspired by Dark Souls with desaturated earthy tones, somber copper dusk horizons, Reinhard tonemapping, and blood-red sunset.',
      lighting: LightingConfig(
        sunBrightnessMultiplier: 0.85,
        sunColorNoon: Color(0xFFB4A664),
        sunColorSunset: Color(0xFFFF5014),
        sunColorSunrise: Color(0xFFB48250),
        nightMoonColor: Color(0xFF55648C),
        moonIlluminance: 1.2,
        ambientIlluminance: 0.08,
        ambientColor: Color(0xFF0A0C10),
        skyIntensity: 0.3,
        shadowStyle: 'soft_shadows',
        shadowTexelSize: 1024,
      ),
      atmosphere: AtmosphereConfig(
        rayleighNoon: 4.0,
        rayleighSunset: 2.5,
        rayleighSunrise: 2.5,
        rayleighNight: 3.0,
        sunGlowNoon: 1.5,
        noonZenith: Color(0xFF677B78),
        noonHorizon: Color(0xFFB4C6C6),
        sunsetZenith: Color(0xFF9A5A41),
        sunsetHorizon: Color(0xFFE8823C),
        nightZenith: Color(0xFF55648C),
        nightHorizon: Color(0xFF91B9EA),
        sunriseZenith: Color(0xFF9A5A41),
        sunriseHorizon: Color(0xFFE8823C),
      ),
      fog: FogConfig(
        airFogStart: 0.82,
        airFogEnd: 0.98,
        airFogColor: Color(0xFF404848),
        volumetricMaxDensity: 0.065,
        weatherFogColor: Color(0xFF1E2428),
      ),
      colorGrading: ColorGradingConfig(
        toneMappingOperator: 'reinhard',
        midtonesContrast: [1.3, 1.3, 1.3],
        midtonesSaturation: [0.76, 0.85, 0.78],
        midtonesGain: [1.0, 0.98, 1.0],
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
  const ShaderPresetConfig(
    id: 'pink_atmosphere',
    name: 'Pink Atmosphere (Sakura)',
    creator: 'Piglix Labs',
    description:
        'Dreamy pastel aesthetic with cherry blossom haze, soft pearl daylight, glowing rose twilight horizons, and lavender dusk mist.',
    rating: 4.88,
    downloads: '56.0k',
    tags: ['Sakura Pink', 'Pastel Bloom', 'Aesthetic', 'Popular'],
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
    saturation: 1.15,
    contrast: 1.12,
    autoExposure: 1.0,
    vvConfig: VVShaderConfig(
      packName: 'Pink Atmosphere (Sakura)',
      packDescription:
          'Dreamy pastel aesthetic with cherry blossom haze, soft pearl daylight, glowing rose twilight horizons, and lavender dusk mist.',
      lighting: LightingConfig(
        sunBrightnessMultiplier: 1.0,
        sunColorNoon: Color(0xFFFFF0F5),
        sunColorSunrise: Color(0xFFFF9EB5),
        sunColorSunset: Color(0xFFFF6B95),
        nightMoonColor: Color(0xFF8A9AFF),
        moonIlluminance: 2.1,
        ambientIlluminance: 0.09,
        ambientColor: Color(0xFF2D1E2D),
        skyIntensity: 0.35,
        shadowStyle: 'soft_shadows',
        shadowTexelSize: 1024,
      ),
      atmosphere: AtmosphereConfig(
        rayleighNoon: 2.1,
        rayleighSunset: 3.2,
        sunGlowNoon: 4.5,
        noonZenith: Color(0xFF6B8AFF),
        noonHorizon: Color(0xFFFFE8EF),
        sunsetZenith: Color(0xFFB878D6),
        sunsetHorizon: Color(0xFFFF8EAA),
        nightZenith: Color(0xFF141233),
        nightHorizon: Color(0xFF382D4A),
        sunriseZenith: Color(0xFF9E88E8),
        sunriseHorizon: Color(0xFFFFB5C8),
      ),
      fog: FogConfig(
        airFogStart: 0.85,
        airFogEnd: 1.0,
        airFogColor: Color(0xFFF3D5E8),
        waterFogColor: Color(0xFF1EA8D6),
        volumetricMaxDensity: 0.05,
      ),
      colorGrading: ColorGradingConfig(
        toneMappingOperator: 'hable',
        midtonesContrast: [1.12, 1.12, 1.12],
        midtonesSaturation: [1.15, 1.15, 1.15],
        temperature: 6100.0,
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
      return const Color(0xFFC084FC); // Crystal Lilac
    case 'definitive_vibrant':
      return const Color(0xFF38BDF8); // Azure Blue
    case 'revolution_visuals':
      return const Color(0xFFFB923C); // Fiery Orange
    case 'dark_fantasy':
      return const Color(0xFF94A3B8); // Grim Steel / Ember
    case 'luminous_dreams':
      return const Color(0xFF22C55E); // Emerald Cyan
    case 'bslb_dreamy':
      return const Color(0xFF60A5FA); // Dreamy Sky Blue
    case 'better_vibrant':
      return const Color(0xFFFBBF24); // Warm Gold
    case 'pink_atmosphere':
    default:
      return const Color(0xFFF472B6); // Sakura Pink
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
    'BALANCED (60FPS)',
    'CINEMATIC',
    'ATMOSPHERE',
    'DARK FANTASY',
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
                  p.id == 'pink_atmosphere' ||
                  p.id == 'prizma_visuals' ||
                  p.id == 'bslb_dreamy',
            )
            .toList();
      case 'DARK FANTASY':
        return kDefaultShaderPresets
            .where((p) => p.id == 'dark_fantasy')
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

    return Container(
      decoration: BoxDecoration(
        color: palette.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: palette.border, width: 1.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.35),
            blurRadius: 14,
            offset: const Offset(0, 5),
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
              // 1. YouTube-Style 16:9 Widescreen Thumbnail Image Banner
              _PresetThumbnail(preset: p, accent: accent),

              // 2. YouTube-Style Video Details Section
              Padding(
                padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Creator Avatar + Preset Title + Channel Row
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Channel / Preset Avatar Icon
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(
                              colors: [accent, const Color(0xFF22C55E)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: accent.withValues(alpha: 0.35),
                                blurRadius: 8,
                              ),
                            ],
                          ),
                          child: Center(
                            child: Text(
                              p.name.isNotEmpty ? p.name[0] : 'P',
                              style: const TextStyle(
                                color: Colors.black,
                                fontSize: 17,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),

                        // Title, Creator, Verification & Downloads
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                p.name,
                                style: TextStyle(
                                  color: palette.textPrimary,
                                  fontSize: 16.0,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 0.2,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 3),
                              Row(
                                children: [
                                  Text(
                                    p.creator,
                                    style: TextStyle(
                                      color: palette.textSecondary,
                                      fontSize: 12.0,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  const Icon(
                                    Icons.check_circle_rounded,
                                    size: 13,
                                    color: Color(0xFF22C55E),
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    '•  ${p.downloads} downloads',
                                    style: TextStyle(
                                      color: palette.textSecondary,
                                      fontSize: 11.5,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 10),

                    // Preset Description
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

                    const SizedBox(height: 10),

                    // Feature Tags (YouTube Video Tags / Chips)
                    Wrap(
                      spacing: 6,
                      runSpacing: 4,
                      children: p.tags
                          .map((tag) => _featureBadge(tag, accent, palette))
                          .toList(),
                    ),

                    const SizedBox(height: 12),

                    // YouTube-Action Full Width "APPLY PRESET" Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () => widget.onSelectPreset(p),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF22C55E),
                          foregroundColor: Colors.black,
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
                            Icon(
                              Icons.auto_awesome_rounded,
                              size: 16,
                              color: Colors.black,
                            ),
                            SizedBox(width: 6),
                            Text(
                              'APPLY PRESET',
                              style: TextStyle(
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

  Widget _featureBadge(String text, Color accent, AppPalette palette) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
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

/// YouTube-style 16:9 widescreen preset video thumbnail widget.
/// Displays an image asset / network screenshot if provided, or renders a dynamic,
/// atmospheric procedural Minecraft shader scene fallback.
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
    final thumb = preset.thumbnailPath;
    if (thumb != null && thumb.trim().isNotEmpty) {
      final isNetwork =
          thumb.startsWith('http://') || thumb.startsWith('https://');
      content = isNetwork
          ? Image.network(
              thumb,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) =>
                  _buildFallbackPainter(),
            )
          : Image.asset(
              thumb,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) =>
                  _buildFallbackPainter(),
            );
    } else {
      content = _buildFallbackPainter();
    }

    return AspectRatio(
      aspectRatio: 16 / 9,
      child: Stack(
        fit: StackFit.expand,
        children: [
          content,

          // Subtle gradient scrim overlay for readability of badges & text
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withValues(alpha: 0.35),
                  Colors.transparent,
                  Colors.black.withValues(alpha: 0.65),
                ],
                stops: const [0.0, 0.45, 1.0],
              ),
            ),
          ),

          // Top-Left Category / Style Badge
          Positioned(
            top: 10,
            left: 10,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.70),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: accent.withValues(alpha: 0.7),
                  width: 1.0,
                ),
                boxShadow: [
                  BoxShadow(
                    color: accent.withValues(alpha: 0.3),
                    blurRadius: 6,
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: accent,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 5),
                  Text(
                    preset.tags.isNotEmpty
                        ? preset.tags.first.toUpperCase()
                        : 'VIBRANT',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.6,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Top-Right Rating Badge
          Positioned(
            top: 10,
            right: 10,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3.5),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.75),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.15),
                  width: 0.8,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.star_rounded,
                    color: Color(0xFFFBBF24),
                    size: 13,
                  ),
                  const SizedBox(width: 3),
                  Text(
                    preset.rating.toStringAsFixed(2),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10.5,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Center interactive preview icon
          Center(
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.45),
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.4),
                  width: 1.5,
                ),
              ),
              child: const Icon(
                Icons.play_arrow_rounded,
                color: Colors.white,
                size: 26,
              ),
            ),
          ),

          // Bottom-Right Duration / Spec Chip (YouTube-style time badge)
          Positioned(
            bottom: 10,
            right: 10,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.85),
                borderRadius: BorderRadius.circular(4),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.2),
                  width: 0.6,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Icon(
                    Icons.hd_rounded,
                    color: Color(0xFF22C55E),
                    size: 13,
                  ),
                  SizedBox(width: 4),
                  Text(
                    '1.21+ DEFERRED',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 9.5,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Bottom-Left Atmospheric Color Gradient Strip Preview
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              height: 3.5,
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
