// vv_config.dart
// ignore_for_file: constant_identifier_names
import 'dart:ui';
import 'package:flutter/material.dart' show Color;
import 'vv_biomes.dart';

/// Performance tier options for root export and subpacks.
enum PerformanceTier { low, medium, high, ultra }

/// Target Minecraft engine / Vibrant Visuals schema level.
enum VVExportTarget {
  /// Broadest compatibility (Bedrock 1.21.120+):
  /// - min_engine_version: [1, 21, 120]
  /// - lighting format_version: 1.21.80
  /// - water format_version: 1.21.80 (disables biome_water_color_contribution)
  wide,

  /// Latest Vibrant Visuals features (Bedrock 1.26.0+):
  /// - min_engine_version: [1, 26, 0]
  /// - lighting format_version: 1.26.0
  /// - water format_version: 1.26.0 (enables biome_water_color_contribution)
  modern,
}

/// Immutable config for one Minecraft Bedrock Vibrant Visuals pack export.
/// [configVersion] lets future migrations detect old saved presets.
class VVShaderConfig {
  static const int currentVersion = 1;

  /// Version of the vanilla Bedrock client biome catalog (Rule 23).
  static const int currentBiomeListVersion = 1;

  /// Schema version — bump when field layout changes.
  final int configVersion;

  /// Version of the biome catalog when saving this preset/config.
  final int biomeListVersion;

  /// manifest.json → header.name
  final String packName;

  /// manifest.json → header.description
  final String packDescription;

  /// manifest.json → header.version [major, minor, patch]
  final List<int> packVersion;

  /// Target engine / schema level (Wide: 1.21.120+ vs Modern: 1.26.0+).
  final VVExportTarget exportTarget;

  /// Sanitized lowercase `[a-z0-9_]+` namespace slug derived from [packName].
  /// Every custom JSON identifier in the generated pack uses `<packSlug>:<name>`.
  String get packSlug {
    final sanitized = packName
        .trim()
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9]+'), '_')
        .replaceAll(RegExp(r'^_+|_+$'), '');
    return sanitized.isEmpty ? 'piglix_shader' : sanitized;
  }

  /// Formats a pack-namespaced identifier (`<packSlug>:<name>`).
  /// Strips any pre-existing namespace prefix if [name] already contains `:`.
  String namespacedId(String name) {
    final idx = name.indexOf(':');
    final bare = idx == -1 ? name : name.substring(idx + 1);
    return '$packSlug:$bare';
  }

  // ── Sky & Time ───────────────────────────────────────────
  // atmospherics/atmospherics.json

  final AtmosphereConfig atmosphere;

  // ── Light & Shadows ──────────────────────────────────────
  // lighting/global.json + local_lighting/local_lighting.json + shadows/global.json

  final LightingConfig lighting;

  // ── Fog & Air ────────────────────────────────────────────
  // fogs/*.json (overworld biomes)

  final FogConfig fog;

  // ── Water Presets ────────────────────────────────────────
  // water/*.json (5 separate files, referenced by identifier)

  /// Pack-wide locked water settings (identical across all 5 water files per tier).
  final WaterGlobalSettings waterGlobal;

  /// water/water_tropical.json → `<slug>:water_tropical`
  final WaterPresetConfig waterTropical;

  /// water/water_ocean.json → `<slug>:water_ocean`
  final WaterPresetConfig waterOcean;

  /// water/water_deep_ocean.json → `<slug>:water_deep_ocean`
  final WaterPresetConfig waterDeepOcean;

  /// water/water_river.json → `<slug>:water_river`
  final WaterPresetConfig waterRiver;

  /// water/water_swamp.json → `<slug>:water_swamp`
  final WaterPresetConfig waterSwamp;

  // ── Color & Mood ─────────────────────────────────────────
  // color_grading/color_grading.json + color_grading/mood_*.json

  final ColorGradingConfig colorGrading;

  /// Active overworld default mood preset:
  /// `'dynamic' | 'vibrant' | 'savanna' | 'frost' | 'moody'`.
  final String activeMood;

  // ── Surface PBR ──────────────────────────────────────────
  // pbr/global.json

  final SurfaceConfig surface;

  // ── Performance & Subpacks ───────────────────────────────
  // manifest.json subpacks + per-tier overrides

  final PerformanceTierConfig performance;

  // ── Biome Overrides (3-layer: Global -> Group -> Single) ─
  // biomes/*.client_biome.json

  final BiomeOverridesConfig biomeOverrides;

  const VVShaderConfig({
    this.configVersion = currentVersion,
    this.biomeListVersion = currentBiomeListVersion,
    this.packName = 'Piglix Shader',
    this.packDescription = 'Piglix Vibrant Visuals · Bedrock Deferred PBR Shader',
    this.packVersion = const [1, 0, 0],
    this.exportTarget = VVExportTarget.wide,
    this.atmosphere = const AtmosphereConfig(),
    this.lighting = const LightingConfig(),
    this.fog = const FogConfig(),
    this.waterGlobal = const WaterGlobalSettings(),
    this.waterTropical = const WaterPresetConfig.tropical(),
    this.waterOcean = const WaterPresetConfig.ocean(),
    this.waterDeepOcean = const WaterPresetConfig.deepOcean(),
    this.waterRiver = const WaterPresetConfig.river(),
    this.waterSwamp = const WaterPresetConfig.swamp(),
    this.colorGrading = const ColorGradingConfig(),
    this.activeMood = 'dynamic',
    this.surface = const SurfaceConfig(),
    this.performance = const PerformanceTierConfig(),
    this.biomeOverrides = const BiomeOverridesConfig(),
  });

  VVShaderConfig copyWith({
    int? configVersion,
    int? biomeListVersion,
    String? packName,
    String? packDescription,
    List<int>? packVersion,
    VVExportTarget? exportTarget,
    AtmosphereConfig? atmosphere,
    LightingConfig? lighting,
    FogConfig? fog,
    WaterGlobalSettings? waterGlobal,
    WaterPresetConfig? waterTropical,
    WaterPresetConfig? waterOcean,
    WaterPresetConfig? waterDeepOcean,
    WaterPresetConfig? waterRiver,
    WaterPresetConfig? waterSwamp,
    ColorGradingConfig? colorGrading,
    String? activeMood,
    SurfaceConfig? surface,
    PerformanceTierConfig? performance,
    BiomeOverridesConfig? biomeOverrides,
  }) {
    return VVShaderConfig(
      configVersion: configVersion ?? this.configVersion,
      biomeListVersion: biomeListVersion ?? this.biomeListVersion,
      packName: packName ?? this.packName,
      packDescription: packDescription ?? this.packDescription,
      packVersion: packVersion ?? this.packVersion,
      exportTarget: exportTarget ?? this.exportTarget,
      atmosphere: atmosphere ?? this.atmosphere,
      lighting: lighting ?? this.lighting,
      fog: fog ?? this.fog,
      waterGlobal: waterGlobal ?? this.waterGlobal,
      waterTropical: waterTropical ?? this.waterTropical,
      waterOcean: waterOcean ?? this.waterOcean,
      waterDeepOcean: waterDeepOcean ?? this.waterDeepOcean,
      waterRiver: waterRiver ?? this.waterRiver,
      waterSwamp: waterSwamp ?? this.waterSwamp,
      colorGrading: colorGrading ?? this.colorGrading,
      activeMood: activeMood ?? this.activeMood,
      surface: surface ?? this.surface,
      performance: performance ?? this.performance,
      biomeOverrides: biomeOverrides ?? this.biomeOverrides,
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// AtmosphereConfig
// ─────────────────────────────────────────────────────────────────────────────

/// Sky atmosphere settings.
/// Maps to `atmospherics/atmospherics.json` → `minecraft:atmosphere_settings`.
///
/// VV time convention: `0.0` = noon, `0.25` = sunset, `0.5` = midnight, `0.75` = sunrise.
class AtmosphereConfig {
  /// When true, `sky_zenith_color` is derived as a darker, slightly bluer shift
  /// of `sky_horizon_color`. When false, explicit zenith colors are used.
  final bool autoDeriveZenith;

  // ── Sky zenith colors ────────────────────────────────────
  // → sky_zenith_color keyframes

  final Color noonZenith;
  final Color sunsetZenith;
  final Color nightZenith;
  final Color sunriseZenith;

  // ── Sky horizon colors ───────────────────────────────────
  // → sky_horizon_color keyframes

  final Color noonHorizon;
  final Color sunsetHorizon;
  final Color nightHorizon;
  final Color sunriseHorizon;

  // ── Atmospheric scattering ───────────────────────────────
  // → rayleigh_strength keyframes (0.0..11.0)

  final double rayleighNoon;
  final double rayleighSunset;
  final double rayleighNight;
  final double rayleighSunrise;

  // ── Sun glow / glare ─────────────────────────────────────
  // → sun_mie_strength keyframes (0.0..60.0)

  final double sunGlowNoon;
  final double sunGlowSunset;
  final double sunGlowSunrise;

  // → sun_glare_shape keyframes (0.01..50.0)

  final double sunGlareNoon;
  final double sunGlareSunset;
  final double sunGlareSunrise;

  // ── Moon glow ────────────────────────────────────────────
  // → moon_mie_strength keyframes (0.0..20.0)

  final double moonGlow;

  // ── Horizon haze blend ───────────────────────────────────
  // → horizon_blend_stops.{min, start, mie_start, max}
  // Simple "Horizon haze" scale (0.0..2.0) scales stops around starter values.

  /// Scale `0.0..2.0`, default `1.0`.
  final double horizonHazeScale;

  /// Explicit `horizon_blend_stops.start` keyframes (`0.0..1.0`).
  final double horizonHazeNoon;
  final double horizonHazeSunset;
  final double horizonHazeNight;
  final double horizonHazeSunrise;

  const AtmosphereConfig({
    this.autoDeriveZenith = true,
    this.noonZenith = const Color(0xFF5B7AFF),
    this.sunsetZenith = const Color(0xFFB9BFFC),
    this.nightZenith = const Color(0xFF0E225C),
    this.sunriseZenith = const Color(0xFF4A5E8E),
    this.noonHorizon = const Color(0xFFD7EFFF),
    this.sunsetHorizon = const Color(0xFFFFDBCF),
    this.nightHorizon = const Color(0xFF344B87),
    this.sunriseHorizon = const Color(0xFFFFDBCF),
    this.rayleighNoon = 1.0,
    this.rayleighSunset = 1.1,
    this.rayleighNight = 0.45,
    this.rayleighSunrise = 0.8,
    this.sunGlowNoon = 1.0,
    this.sunGlowSunset = 3.0,
    this.sunGlowSunrise = 3.0,
    this.sunGlareNoon = 5.0,
    this.sunGlareSunset = 0.07,
    this.sunGlareSunrise = 0.07,
    this.moonGlow = 0.7,
    this.horizonHazeScale = 1.0,
    this.horizonHazeNoon = 0.25,
    this.horizonHazeSunset = 0.95,
    this.horizonHazeNight = 0.375,
    this.horizonHazeSunrise = 0.95,
  });

  /// Derives a darker, slightly bluer zenith color from a horizon color.
  static Color deriveZenithFromHorizon(Color horizon) {
    final rgb = horizon.toARGB32();
    final r = (rgb >> 16) & 0xFF;
    final g = (rgb >> 8) & 0xFF;
    final b = rgb & 0xFF;
    final dr = (r * 0.44).round().clamp(0, 255);
    final dg = (g * 0.56).round().clamp(0, 255);
    final db = (b * 0.88 + 14).round().clamp(0, 255);
    return Color.fromARGB(255, dr, dg, db);
  }

  /// Effective zenith colors respecting [autoDeriveZenith].
  Color get effectiveNoonZenith =>
      autoDeriveZenith ? deriveZenithFromHorizon(noonHorizon) : noonZenith;
  Color get effectiveSunsetZenith =>
      autoDeriveZenith ? deriveZenithFromHorizon(sunsetHorizon) : sunsetZenith;
  Color get effectiveNightZenith =>
      autoDeriveZenith ? deriveZenithFromHorizon(nightHorizon) : nightZenith;
  Color get effectiveSunriseZenith =>
      autoDeriveZenith ? deriveZenithFromHorizon(sunriseHorizon) : sunriseZenith;

  /// Simple UI helper: sets Horizon haze scale (`0.0..2.0`).
  AtmosphereConfig withSimpleHorizonHaze(double scale) =>
      copyWith(horizonHazeScale: scale.clamp(0.0, 2.0));

  /// Simple UI helper: sets Sun glow scale (`0.0..2.0`) for Noon.
  AtmosphereConfig withSimpleSunGlowNoon(double scale) {
    final s = scale.clamp(0.0, 2.0);
    return copyWith(
      sunGlowNoon: (1.0 * s).clamp(0.0, 60.0),
      sunGlareNoon: (5.0 * s).clamp(0.01, 50.0),
    );
  }

  /// Simple UI helper: sets Sun glow scale (`0.0..2.0`) for Sunset.
  AtmosphereConfig withSimpleSunGlowSunset(double scale) {
    final s = scale.clamp(0.0, 2.0);
    return copyWith(
      sunGlowSunset: (4.0 * s).clamp(0.0, 60.0),
      sunGlareSunset: (0.07 * s).clamp(0.01, 50.0),
    );
  }

  /// Simple UI helper: sets Sun glow scale (`0.0..2.0`) for Sunrise.
  AtmosphereConfig withSimpleSunGlowSunrise(double scale) {
    final s = scale.clamp(0.0, 2.0);
    return copyWith(
      sunGlowSunrise: (4.0 * s).clamp(0.0, 60.0),
      sunGlareSunrise: (0.07 * s).clamp(0.01, 50.0),
    );
  }

  /// Simple UI helper: sets Moon glow scale (`0.0..2.0`) for Night.
  AtmosphereConfig withSimpleMoonGlow(double scale) {
    final s = scale.clamp(0.0, 2.0);
    return copyWith(moonGlow: (0.7 * s).clamp(0.0, 20.0));
  }

  AtmosphereConfig copyWith({
    bool? autoDeriveZenith,
    Color? noonZenith,
    Color? sunsetZenith,
    Color? nightZenith,
    Color? sunriseZenith,
    Color? noonHorizon,
    Color? sunsetHorizon,
    Color? nightHorizon,
    Color? sunriseHorizon,
    double? rayleighNoon,
    double? rayleighSunset,
    double? rayleighNight,
    double? rayleighSunrise,
    double? sunGlowNoon,
    double? sunGlowSunset,
    double? sunGlowSunrise,
    double? sunGlareNoon,
    double? sunGlareSunset,
    double? sunGlareSunrise,
    double? moonGlow,
    double? horizonHazeScale,
    double? horizonHazeNoon,
    double? horizonHazeSunset,
    double? horizonHazeNight,
    double? horizonHazeSunrise,
  }) {
    return AtmosphereConfig(
      autoDeriveZenith: autoDeriveZenith ?? this.autoDeriveZenith,
      noonZenith: noonZenith ?? this.noonZenith,
      sunsetZenith: sunsetZenith ?? this.sunsetZenith,
      nightZenith: nightZenith ?? this.nightZenith,
      sunriseZenith: sunriseZenith ?? this.sunriseZenith,
      noonHorizon: noonHorizon ?? this.noonHorizon,
      sunsetHorizon: sunsetHorizon ?? this.sunsetHorizon,
      nightHorizon: nightHorizon ?? this.nightHorizon,
      sunriseHorizon: sunriseHorizon ?? this.sunriseHorizon,
      rayleighNoon: rayleighNoon ?? this.rayleighNoon,
      rayleighSunset: rayleighSunset ?? this.rayleighSunset,
      rayleighNight: rayleighNight ?? this.rayleighNight,
      rayleighSunrise: rayleighSunrise ?? this.rayleighSunrise,
      sunGlowNoon: sunGlowNoon ?? this.sunGlowNoon,
      sunGlowSunset: sunGlowSunset ?? this.sunGlowSunset,
      sunGlowSunrise: sunGlowSunrise ?? this.sunGlowSunrise,
      sunGlareNoon: sunGlareNoon ?? this.sunGlareNoon,
      sunGlareSunset: sunGlareSunset ?? this.sunGlareSunset,
      sunGlareSunrise: sunGlareSunrise ?? this.sunGlareSunrise,
      moonGlow: moonGlow ?? this.moonGlow,
      horizonHazeScale: horizonHazeScale ?? this.horizonHazeScale,
      horizonHazeNoon: horizonHazeNoon ?? this.horizonHazeNoon,
      horizonHazeSunset: horizonHazeSunset ?? this.horizonHazeSunset,
      horizonHazeNight: horizonHazeNight ?? this.horizonHazeNight,
      horizonHazeSunrise: horizonHazeSunrise ?? this.horizonHazeSunrise,
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// BlockLightGroup & LightingConfig
// ─────────────────────────────────────────────────────────────────────────────

/// Color and light type for one group of emissive blocks in
/// `local_lighting/local_lighting.json` (`minecraft:local_light_settings`).
class BlockLightGroup {
  /// Block light color → `light_color` (`#RRGGBB`).
  final Color color;

  /// `'point_light'` (casts real-time point light) or `'static_light'`.
  final String lightType;

  const BlockLightGroup({
    required this.color,
    this.lightType = 'point_light',
  });

  bool get isPointLight => lightType == 'point_light';

  BlockLightGroup copyWith({Color? color, String? lightType}) {
    return BlockLightGroup(
      color: color ?? this.color,
      lightType: lightType ?? this.lightType,
    );
  }
}

/// Sun/moon/ambient/block light and shadow settings.
/// Maps to:
/// - `lighting/global.json` → `minecraft:lighting_settings` (`1.21.80`)
/// - `local_lighting/local_lighting.json` → `minecraft:local_light_settings` (`1.21.120`)
/// - `shadows/global.json` → `minecraft:shadow_settings` (`1.21.80`)
class LightingConfig {
  /// Mojang baseline sun illuminance curve (lux) keyed by VV time-of-day.
  /// Normalized keys ("0.0", "0.25", "0.5", "0.75", "1.0") including twilight keys (0.35, 0.65).
  static const Map<String, double> mojangSunLuxCurve = {
    '0.0': 109880.0,
    '0.16': 85000.0,
    '0.215': 50000.0,
    '0.24': 30000.0,
    '0.25': 20000.0,
    '0.3': 5000.0,
    '0.35': 0.0,
    '0.5': 0.0,
    '0.65': 0.0,
    '0.68': 0.0,
    '0.74': 6000.0,
    '0.75': 20000.0,
    '0.77': 60000.0,
    '0.827': 95000.0,
    '1.0': 109880.0,
  };

  /// Multiplies Mojang's lux curve (`0.1..2.0`, default `1.0`), clamped `0.01..200000.0`.
  /// → directional_lights.orbital.sun.illuminance
  final double sunBrightnessMultiplier;

  // → directional_lights.orbital.sun.color keyframes
  final Color sunColorNoon;
  final Color sunColorSunset;
  final Color sunColorSunrise;
  final Color nightMoonColor;

  // ── Moon ─────────────────────────────────────────────────
  // → directional_lights.orbital.moon.illuminance / .color

  /// lux, range `0.0..20.0`, default `0.27`
  final double moonIlluminance;

  /// default `#051EFF`
  final Color moonColor;

  // ── Ambient ───────────────────────────────────────────────
  // → ambient.illuminance / .color

  /// lux, range `0.0..5.0`, default `0.02`
  final double ambientIlluminance;

  /// Cave/indirect ambient tint → `ambient.color`, default `#1E2330`
  final Color ambientColor;

  // ── Shadow diffusion ─────────────────────────────────────
  // → sky.intensity (`0.1..1.0`, default `1.0`; lower = darker shadows)

  final double skyIntensity;

  // ── Emissive glow ─────────────────────────────────────────
  // → emissive.desaturation (`0.0..1.0`, default `0.1`)

  final double emissiveDesaturation;

  // ── Orbital tilt (pack-wide locked) ──────────────────────
  // → directional_lights.orbital.orbital_offset_degrees (`0.0..359.98`, default `3.0`)

  final double orbitalOffsetDegrees;

  // ── Lightning flash ───────────────────────────────────────
  // → directional_lights.flash.illuminance (`0.0..20000.0`) / .color

  final double flashIlluminance;
  final Color flashColor;

  // ── 7 Block Light Groups ─────────────────────────────────
  // → local_lighting/local_lighting.json (format_version 1.21.120)

  /// Group 1 (`#EFE39D`): torch, campfire, glowstone, lit_furnace, jack_o_lantern,
  /// shroomlight, lava_cauldron, ochre_froglight, light_block.
  final BlockLightGroup torches;

  /// Group 2 (`#CE8133`): lantern.
  final BlockLightGroup lanterns;

  /// Group 3 (`#00FFFF`): soul_torch, soul_lantern, soul_campfire, soul_fire,
  /// crying_obsidian, respawn_anchor, sculk_catalyst.
  final BlockLightGroup soulFire;

  /// Group 4 (`#EFE39D`): candle.
  final BlockLightGroup candles;

  /// Group 5 (`#FF0000`): redstone_torch, lit_redstone_lamp, lit_redstone_ore.
  final BlockLightGroup redstone;

  /// Group 6 (`#FFFFFF`): end_rod, beacon.
  final BlockLightGroup endRod;

  /// Group 7 (`#B8EF8D`): copper_torch, copper_lantern, copper_bulb,
  /// exposed_copper_bulb, weathered_copper_bulb, oxidized_copper_bulb.
  final BlockLightGroup copper;

  /// When true, redstone blocks use [torches.color] instead of [redstone.color].
  final bool syncWarmToTorch;

  /// When true, `sea_lantern`, `pearlescent_froglight`, `verdant_froglight`
  /// are emitted and linked to [soulFire].
  final bool syncMysticToSoul;

  // ── Shadow style ─────────────────────────────────────────
  // → shadows/global.json

  /// `'soft_shadows'` | `'blocky_shadows'`
  final String shadowStyle;

  /// `1..1024`, default `16`
  final int shadowTexelSize;

  // Canonical block lists per group
  static const List<String> torchBlocks = [
    'minecraft:torch',
    'minecraft:campfire',
    'minecraft:glowstone',
    'minecraft:lit_furnace',
    'minecraft:jack_o_lantern',
    'minecraft:shroomlight',
    'minecraft:lava_cauldron',
    'minecraft:ochre_froglight',
    'minecraft:light_block',
  ];

  static const List<String> lanternBlocks = ['minecraft:lantern'];

  static const List<String> soulBlocks = [
    'minecraft:soul_torch',
    'minecraft:soul_lantern',
    'minecraft:soul_campfire',
    'minecraft:soul_fire',
    'minecraft:crying_obsidian',
    'minecraft:respawn_anchor',
    'minecraft:sculk_catalyst',
  ];

  static const List<String> mysticBlocks = [
    'minecraft:sea_lantern',
    'minecraft:pearlescent_froglight',
    'minecraft:verdant_froglight',
  ];

  /// All 17 explicit candle block IDs in Bedrock (undyed + 16 dyed).
  static const List<String> candleBlocks = [
    'minecraft:candle',
    'minecraft:white_candle',
    'minecraft:orange_candle',
    'minecraft:magenta_candle',
    'minecraft:light_blue_candle',
    'minecraft:yellow_candle',
    'minecraft:lime_candle',
    'minecraft:pink_candle',
    'minecraft:gray_candle',
    'minecraft:light_gray_candle',
    'minecraft:cyan_candle',
    'minecraft:purple_candle',
    'minecraft:blue_candle',
    'minecraft:brown_candle',
    'minecraft:green_candle',
    'minecraft:red_candle',
    'minecraft:black_candle',
  ];

  static const List<String> redstoneBlocks = [
    'minecraft:redstone_torch',
    'minecraft:lit_redstone_lamp',
    'minecraft:lit_redstone_ore',
  ];

  static const List<String> endRodBlocks = [
    'minecraft:end_rod',
    'minecraft:beacon',
  ];

  static const List<String> copperBlocks = [
    'minecraft:copper_torch',
    'minecraft:copper_lantern',
    'minecraft:exposed_copper_lantern',
    'minecraft:weathered_copper_lantern',
    'minecraft:oxidized_copper_lantern',
    'minecraft:waxed_copper_lantern',
    'minecraft:waxed_exposed_copper_lantern',
    'minecraft:waxed_weathered_copper_lantern',
    'minecraft:waxed_oxidized_copper_lantern',
    'minecraft:copper_bulb',
    'minecraft:exposed_copper_bulb',
    'minecraft:weathered_copper_bulb',
    'minecraft:oxidized_copper_bulb',
    'minecraft:waxed_copper_bulb',
    'minecraft:waxed_exposed_copper_bulb',
    'minecraft:waxed_weathered_copper_bulb',
    'minecraft:waxed_oxidized_copper_bulb',
  ];

  /// Blocks in Soul group that are static_light only (area/ambient emitters).
  /// soul_torch and soul_lantern may be point_light; soul_fire, soul_campfire,
  /// crying_obsidian, respawn_anchor, and sculk_catalyst are static_light only.
  static const Set<String> soulStaticOnlyBlocks = {
    'minecraft:soul_fire',
    'minecraft:soul_campfire',
    'minecraft:crying_obsidian',
    'minecraft:respawn_anchor',
    'minecraft:sculk_catalyst',
  };

  /// Area emitter block IDs that must ALWAYS use static_light and are excluded
  /// from the point-light budget.
  static const Set<String> areaEmitterBlockIds = {
    'minecraft:soul_fire',
    'minecraft:soul_campfire',
    'minecraft:crying_obsidian',
    'minecraft:respawn_anchor',
    'minecraft:sculk_catalyst',
    'minecraft:lit_redstone_lamp',
    'minecraft:redstone_lamp',
    'minecraft:copper_bulb',
    'minecraft:exposed_copper_bulb',
    'minecraft:weathered_copper_bulb',
    'minecraft:oxidized_copper_bulb',
    'minecraft:waxed_copper_bulb',
    'minecraft:waxed_exposed_copper_bulb',
    'minecraft:waxed_weathered_copper_bulb',
    'minecraft:waxed_oxidized_copper_bulb',
    'minecraft:glowstone',
    'minecraft:sea_lantern',
    'minecraft:ochre_froglight',
    'minecraft:pearlescent_froglight',
    'minecraft:verdant_froglight',
    'minecraft:shroomlight',
    'minecraft:magma',
  };

  /// Valid Bedrock block IDs for local lighting validation.
  static const Set<String> validBedrockBlockIds = {
    'minecraft:torch',
    'minecraft:soul_torch',
    'minecraft:redstone_torch',
    'minecraft:campfire',
    'minecraft:soul_campfire',
    'minecraft:soul_fire',
    'minecraft:lantern',
    'minecraft:soul_lantern',
    'minecraft:copper_torch',
    'minecraft:copper_lantern',
    'minecraft:exposed_copper_lantern',
    'minecraft:weathered_copper_lantern',
    'minecraft:oxidized_copper_lantern',
    'minecraft:waxed_copper_lantern',
    'minecraft:waxed_exposed_copper_lantern',
    'minecraft:waxed_weathered_copper_lantern',
    'minecraft:waxed_oxidized_copper_lantern',
    'minecraft:candle',
    'minecraft:white_candle',
    'minecraft:orange_candle',
    'minecraft:magenta_candle',
    'minecraft:light_blue_candle',
    'minecraft:yellow_candle',
    'minecraft:lime_candle',
    'minecraft:pink_candle',
    'minecraft:gray_candle',
    'minecraft:light_gray_candle',
    'minecraft:cyan_candle',
    'minecraft:purple_candle',
    'minecraft:blue_candle',
    'minecraft:brown_candle',
    'minecraft:green_candle',
    'minecraft:red_candle',
    'minecraft:black_candle',
    'minecraft:lit_redstone_lamp',
    'minecraft:redstone_lamp',
    'minecraft:lit_redstone_ore',
    'minecraft:end_rod',
    'minecraft:beacon',
    'minecraft:copper_bulb',
    'minecraft:exposed_copper_bulb',
    'minecraft:weathered_copper_bulb',
    'minecraft:oxidized_copper_bulb',
    'minecraft:waxed_copper_bulb',
    'minecraft:waxed_exposed_copper_bulb',
    'minecraft:waxed_weathered_copper_bulb',
    'minecraft:waxed_oxidized_copper_bulb',
    'minecraft:glowstone',
    'minecraft:shroomlight',
    'minecraft:sea_lantern',
    'minecraft:ochre_froglight',
    'minecraft:pearlescent_froglight',
    'minecraft:verdant_froglight',
    'minecraft:magma',
    'minecraft:lit_furnace',
    'minecraft:jack_o_lantern',
    'minecraft:lava_cauldron',
    'minecraft:light_block',
    'minecraft:crying_obsidian',
    'minecraft:respawn_anchor',
    'minecraft:sculk_catalyst',
  };

  const LightingConfig({
    this.sunBrightnessMultiplier = 1.0,
    this.sunColorNoon = const Color(0xFFFFD5AF),
    this.sunColorSunset = const Color(0xFFFF2A0F),
    this.sunColorSunrise = const Color(0xFFFF3C0F),
    this.nightMoonColor = const Color(0xFF3050AA),
    this.moonIlluminance = 0.27,
    this.moonColor = const Color(0xFF051EFF),
    this.ambientIlluminance = 0.02,
    this.ambientColor = const Color(0xFF1E2330),
    this.skyIntensity = 1.0,
    this.emissiveDesaturation = 0.1,
    this.orbitalOffsetDegrees = 3.0,
    this.flashIlluminance = 0.0,
    this.flashColor = const Color(0xFFB600FF),
    this.torches = const BlockLightGroup(color: Color(0xFFEFE39D)),
    this.lanterns = const BlockLightGroup(color: Color(0xFFCE8133)),
    this.soulFire = const BlockLightGroup(color: Color(0xFF00FFFF)),
    this.candles = const BlockLightGroup(color: Color(0xFFEFE39D)),
    this.redstone = const BlockLightGroup(color: Color(0xFFFF0000)),
    this.endRod = const BlockLightGroup(color: Color(0xFFFFFFFF)),
    this.copper = const BlockLightGroup(color: Color(0xFFB8EF8D)),
    this.syncWarmToTorch = false,
    this.syncMysticToSoul = true,
    this.shadowStyle = 'soft_shadows',
    this.shadowTexelSize = 16,
  });

  // Convenience color getters
  Color get torchColor => torches.color;
  Color get lanternColor => lanterns.color;
  Color get soulColor => soulFire.color;
  Color get candleColor => candles.color;
  Color get redstoneColor => redstone.color;
  Color get endRodColor => endRod.color;
  Color get copperBulbColor => copper.color;

  /// Effective noon sun illuminance in lux (`sunBrightnessMultiplier * 109880.0`).
  double get sunIlluminanceNoon =>
      (109880.0 * sunBrightnessMultiplier).clamp(0.01, 200000.0);

  /// Total number of available point-light capable blocks across all groups.
  static int get totalPointLightBlocks {
    int countNonArea(List<String> list) =>
        list.where((b) => !areaEmitterBlockIds.contains(b)).length;
    return countNonArea(torchBlocks) +
        countNonArea(lanternBlocks) +
        countNonArea(soulBlocks) +
        countNonArea(candleBlocks) +
        countNonArea(redstoneBlocks) +
        countNonArea(endRodBlocks) +
        countNonArea(copperBlocks);
  }

  /// Counts total block entries whose `light_type` is `'point_light'`.
  /// Note: Area emitters (bulbs, lamps, froglights, glowstone, etc.) are always static
  /// and excluded from the real-time shadow casting point-light GPU budget.
  int countPointLightBlocks() {
    int countNonArea(List<String> list) =>
        list.where((b) => !areaEmitterBlockIds.contains(b)).length;

    var count = 0;
    if (torches.isPointLight) count += countNonArea(torchBlocks);
    if (lanterns.isPointLight) count += countNonArea(lanternBlocks);
    if (soulFire.isPointLight) {
      count += countNonArea(soulBlocks);
      if (syncMysticToSoul) count += countNonArea(mysticBlocks);
    }
    if (candles.isPointLight) count += countNonArea(candleBlocks);
    if (redstone.isPointLight) count += countNonArea(redstoneBlocks);
    if (endRod.isPointLight) count += countNonArea(endRodBlocks);
    if (copper.isPointLight) count += countNonArea(copperBlocks);
    return count;
  }

  LightingConfig copyWith({
    double? sunBrightnessMultiplier,
    Color? sunColorNoon,
    Color? sunColorSunset,
    Color? sunColorSunrise,
    Color? nightMoonColor,
    double? moonIlluminance,
    Color? moonColor,
    double? ambientIlluminance,
    Color? ambientColor,
    double? skyIntensity,
    double? emissiveDesaturation,
    double? orbitalOffsetDegrees,
    double? flashIlluminance,
    Color? flashColor,
    BlockLightGroup? torches,
    BlockLightGroup? lanterns,
    BlockLightGroup? soulFire,
    BlockLightGroup? candles,
    BlockLightGroup? redstone,
    BlockLightGroup? endRod,
    BlockLightGroup? copper,
    bool? syncWarmToTorch,
    bool? syncMysticToSoul,
    String? shadowStyle,
    int? shadowTexelSize,
  }) {
    return LightingConfig(
      sunBrightnessMultiplier:
          sunBrightnessMultiplier ?? this.sunBrightnessMultiplier,
      sunColorNoon: sunColorNoon ?? this.sunColorNoon,
      sunColorSunset: sunColorSunset ?? this.sunColorSunset,
      sunColorSunrise: sunColorSunrise ?? this.sunColorSunrise,
      nightMoonColor: nightMoonColor ?? this.nightMoonColor,
      moonIlluminance: moonIlluminance ?? this.moonIlluminance,
      moonColor: moonColor ?? this.moonColor,
      ambientIlluminance: ambientIlluminance ?? this.ambientIlluminance,
      ambientColor: ambientColor ?? this.ambientColor,
      skyIntensity: skyIntensity ?? this.skyIntensity,
      emissiveDesaturation: emissiveDesaturation ?? this.emissiveDesaturation,
      orbitalOffsetDegrees: orbitalOffsetDegrees ?? this.orbitalOffsetDegrees,
      flashIlluminance: flashIlluminance ?? this.flashIlluminance,
      flashColor: flashColor ?? this.flashColor,
      torches: torches ?? this.torches,
      lanterns: lanterns ?? this.lanterns,
      soulFire: soulFire ?? this.soulFire,
      candles: candles ?? this.candles,
      redstone: redstone ?? this.redstone,
      endRod: endRod ?? this.endRod,
      copper: copper ?? this.copper,
      syncWarmToTorch: syncWarmToTorch ?? this.syncWarmToTorch,
      syncMysticToSoul: syncMysticToSoul ?? this.syncMysticToSoul,
      shadowStyle: shadowStyle ?? this.shadowStyle,
      shadowTexelSize: shadowTexelSize ?? this.shadowTexelSize,
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// FogConfig
// ─────────────────────────────────────────────────────────────────────────────

/// Overworld fog settings.
/// Maps to `fogs/*.json` (`format_version: "1.21.90"` Experimental, `minecraft:fog_settings`).
class FogConfig {
  // ── Air distance fog ─────────────────────────────────────
  // → distance.air.{fog_color, fog_start, fog_end, render_distance_type: "render"}

  final Color airFogColor;

  /// range `0.05..0.99`, default `0.92`
  final double airFogStart;

  /// range `0.1..1.0`, default `1.0`
  final double airFogEnd;

  // ── Weather fog ───────────────────────────────────────────
  // → distance.weather.{fog_color, fog_start, fog_end, render_distance_type: "render"}

  final Color weatherFogColor;

  /// range `0.05..0.99`, default `0.56`
  final double weatherFogStart;

  /// range `0.1..1.0`, default `0.86`
  final double weatherFogEnd;

  // ── Water distance fog ────────────────────────────────────
  // → distance.water.{fog_color, fog_end} + transition_fog

  final Color waterFogColor;

  /// fixed blocks, range `12..120`, default `45.0`
  final double waterFogEnd;

  // ── Ground / volumetric air fog ───────────────────────────
  // → volumetric.density.air.{max_density, zero_density_height, max_density_height, uniform: false}

  /// range `0.002..0.25`, default `0.065`
  final double volumetricMaxDensity;

  /// blocks, range `50..320`, default `165.0`
  final double volumetricZeroDensityHeight;

  /// blocks, range `-64..200`, default `128.0`
  final double volumetricMaxDensityHeight;

  // ── Haze tint ─────────────────────────────────────────────
  // → volumetric.media_coefficients.air.scattering [r, g, b] in 0.0..1.0

  final Color hazeScatteringColor;

  // ── Underwater volumetric ─────────────────────────────────
  // → volumetric.density.water.max_density + volumetric.media_coefficients.water.absorption

  /// range `0.002..0.08`, default `0.015`
  final double underwaterVolumeDensity;

  /// `0.0..1.0`, default `0.7` — higher values lower water volumetric
  /// `max_density` and `water.absorption` proportionally for clearer cave water.
  final double caveWaterVisibility;

  const FogConfig({
    this.airFogColor = const Color(0xFFB8D8F0),
    this.airFogStart = 0.92,
    this.airFogEnd = 1.0,
    this.weatherFogColor = const Color(0xFF5A636A),
    this.weatherFogStart = 0.56,
    this.weatherFogEnd = 0.86,
    this.waterFogColor = const Color(0xFF0A3048),
    this.waterFogEnd = 45.0,
    this.volumetricMaxDensity = 0.065,
    this.volumetricZeroDensityHeight = 165.0,
    this.volumetricMaxDensityHeight = 128.0,
    this.hazeScatteringColor = const Color(0xFF080808),
    this.underwaterVolumeDensity = 0.015,
    this.caveWaterVisibility = 0.7,
  });

  FogConfig copyWith({
    Color? airFogColor,
    double? airFogStart,
    double? airFogEnd,
    Color? weatherFogColor,
    double? weatherFogStart,
    double? weatherFogEnd,
    Color? waterFogColor,
    double? waterFogEnd,
    double? volumetricMaxDensity,
    double? volumetricZeroDensityHeight,
    double? volumetricMaxDensityHeight,
    Color? hazeScatteringColor,
    double? underwaterVolumeDensity,
    double? caveWaterVisibility,
  }) {
    return FogConfig(
      airFogColor: airFogColor ?? this.airFogColor,
      airFogStart: airFogStart ?? this.airFogStart,
      airFogEnd: airFogEnd ?? this.airFogEnd,
      weatherFogColor: weatherFogColor ?? this.weatherFogColor,
      weatherFogStart: weatherFogStart ?? this.weatherFogStart,
      weatherFogEnd: weatherFogEnd ?? this.weatherFogEnd,
      waterFogColor: waterFogColor ?? this.waterFogColor,
      waterFogEnd: waterFogEnd ?? this.waterFogEnd,
      volumetricMaxDensity: volumetricMaxDensity ?? this.volumetricMaxDensity,
      volumetricZeroDensityHeight:
          volumetricZeroDensityHeight ?? this.volumetricZeroDensityHeight,
      volumetricMaxDensityHeight:
          volumetricMaxDensityHeight ?? this.volumetricMaxDensityHeight,
      hazeScatteringColor: hazeScatteringColor ?? this.hazeScatteringColor,
      underwaterVolumeDensity:
          underwaterVolumeDensity ?? this.underwaterVolumeDensity,
      caveWaterVisibility: caveWaterVisibility ?? this.caveWaterVisibility,
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// WaterGlobalSettings & WaterPresetConfig
// ─────────────────────────────────────────────────────────────────────────────

/// Pack-wide locked water fields that MUST remain identical across all 5 water
/// preset files within a given tier.
class WaterGlobalSettings {
  final bool wavesEnabled;
  final bool causticsEnabled;

  /// range `0.01..5.0`, default `0.0315`
  final double causticsFrameLength;

  /// range `1..6`, default `1`
  final int causticsPower;

  /// range `0.1..5.0`, default `0.13`
  final double causticsScale;

  const WaterGlobalSettings({
    this.wavesEnabled = true,
    this.causticsEnabled = true,
    this.causticsFrameLength = 0.0315,
    this.causticsPower = 1,
    this.causticsScale = 0.13,
  });

  WaterGlobalSettings copyWith({
    bool? wavesEnabled,
    bool? causticsEnabled,
    double? causticsFrameLength,
    int? causticsPower,
    double? causticsScale,
  }) {
    return WaterGlobalSettings(
      wavesEnabled: wavesEnabled ?? this.wavesEnabled,
      causticsEnabled: causticsEnabled ?? this.causticsEnabled,
      causticsFrameLength: causticsFrameLength ?? this.causticsFrameLength,
      causticsPower: causticsPower ?? this.causticsPower,
      causticsScale: causticsScale ?? this.causticsScale,
    );
  }
}

/// One water biome preset.
/// Maps to `water/*.json` → `minecraft:water_settings`.
class WaterPresetConfig {
  /// Bare preset key (prefixed with `<packSlug>:` when emitted), e.g. `'water_tropical'`.
  final String identifier;

  /// Target archive file path, e.g. `'water/water_tropical.json'`.
  final String fileName;

  // ── particle_concentrations ───────────────────────────────

  /// range `0..15`; clarity decreases as this rises
  final double cdom;

  /// range `0..10`
  final double chlorophyll;

  /// range `0..300`
  final double suspendedSediment;

  /// range `0..1` → `minecraft:water_settings.biome_water_color_contribution`
  final double biomeWaterColorContribution;

  // ── caustics ─────────────────────────────────────────────

  final bool causticsEnabled;

  /// range `0.01..5.0`
  final double causticsFrameLength;

  /// range `0.1..5.0`
  final double causticsScale;

  /// int `1..6`
  final int causticsPower;

  // ── waves ────────────────────────────────────────────────

  final bool wavesEnabled;

  /// range `0.01..3.0`
  final double wavesFrequency;

  /// int `1..30`
  final int wavesOctaves;

  /// range `0.0..3.0`
  final double wavesDepth;

  /// range `0.01..1.0`
  final double wavesSampleWidth;

  /// range `0.01..10.0`
  final double wavesSpeed;

  /// range `-1.0..1.0`
  final double wavesPull;

  /// range `0.0..1.0`
  final double wavesMix;

  /// range `0.0..2.0`
  final double wavesFrequencyScaling;

  /// range `0.0..2.0`
  final double wavesSpeedScaling;

  /// int `0..360`
  final int wavesDirectionIncrement;

  /// range `1.0..10.0`
  final double wavesShape;

  const WaterPresetConfig({
    required this.identifier,
    required this.fileName,
    this.cdom = 2.94,
    this.chlorophyll = 0.0035,
    this.suspendedSediment = 0.93,
    this.biomeWaterColorContribution = 0.5,
    this.causticsEnabled = true,
    this.causticsFrameLength = 0.0315,
    this.causticsScale = 0.13,
    this.causticsPower = 1,
    this.wavesEnabled = true,
    this.wavesFrequency = 1.338,
    this.wavesOctaves = 16,
    this.wavesDepth = 1.0,
    this.wavesSampleWidth = 0.115,
    this.wavesSpeed = 2.383,
    this.wavesPull = 0.35,
    this.wavesMix = 0.31,
    this.wavesFrequencyScaling = 1.22,
    this.wavesSpeedScaling = 1.11,
    this.wavesDirectionIncrement = 80,
    this.wavesShape = 3.393,
  });

  /// Preset 1: Tropical → `water/water_tropical.json`, `<slug>:water_tropical`
  const WaterPresetConfig.tropical()
      : this(
          identifier: 'water_tropical',
          fileName: 'water/water_tropical.json',
          cdom: 2.94,
          chlorophyll: 0.0035,
          suspendedSediment: 0.93,
          biomeWaterColorContribution: 0.5,
          causticsEnabled: true,
          causticsFrameLength: 0.0315,
          causticsScale: 0.13,
          causticsPower: 1,
          wavesEnabled: true,
          wavesFrequency: 1.338,
          wavesOctaves: 16,
          wavesDepth: 0.074,
          wavesSampleWidth: 0.115,
          wavesSpeed: 2.383,
          wavesPull: 0.35,
          wavesMix: 0.31,
          wavesFrequencyScaling: 1.22,
          wavesSpeedScaling: 1.11,
          wavesDirectionIncrement: 80,
          wavesShape: 3.393,
        );

  /// Preset 2: Ocean (separate file & id!) → `water/water_ocean.json`, `<slug>:water_ocean`
  const WaterPresetConfig.ocean()
      : this(
          identifier: 'water_ocean',
          fileName: 'water/water_ocean.json',
          cdom: 3.5,
          chlorophyll: 0.005,
          suspendedSediment: 0.5,
          biomeWaterColorContribution: 0.45,
          causticsEnabled: true,
          causticsFrameLength: 0.0315,
          causticsScale: 0.13,
          causticsPower: 1,
          wavesEnabled: true,
          wavesFrequency: 1.338,
          wavesOctaves: 16,
          wavesDepth: 0.085,
          wavesSampleWidth: 0.115,
          wavesSpeed: 2.383,
          wavesPull: 0.35,
          wavesMix: 0.31,
          wavesFrequencyScaling: 1.22,
          wavesSpeedScaling: 1.11,
          wavesDirectionIncrement: 80,
          wavesShape: 3.393,
        );

  /// Preset 3: Deep Ocean → `water/water_deep_ocean.json`, `<slug>:water_deep_ocean`
  const WaterPresetConfig.deepOcean()
      : this(
          identifier: 'water_deep_ocean',
          fileName: 'water/water_deep_ocean.json',
          cdom: 9.0,
          chlorophyll: 2.0,
          suspendedSediment: 6.6,
          biomeWaterColorContribution: 0.35,
          causticsEnabled: true,
          causticsFrameLength: 0.0315,
          causticsScale: 0.13,
          causticsPower: 1,
          wavesEnabled: true,
          wavesFrequency: 0.58,
          wavesOctaves: 16,
          wavesDepth: 0.465,
          wavesSampleWidth: 0.01,
          wavesSpeed: 0.683,
          wavesPull: 0.31,
          wavesMix: 0.16,
          wavesFrequencyScaling: 1.18,
          wavesSpeedScaling: 1.1,
          wavesDirectionIncrement: 80,
          wavesShape: 2.393,
        );

  /// Preset 4: River → `water/water_river.json`, `<slug>:water_river`
  const WaterPresetConfig.river()
      : this(
          identifier: 'water_river',
          fileName: 'water/water_river.json',
          cdom: 0.0,
          chlorophyll: 0.0,
          suspendedSediment: 0.0,
          biomeWaterColorContribution: 0.55,
          causticsEnabled: true,
          causticsFrameLength: 0.0315,
          causticsScale: 0.13,
          causticsPower: 1,
          wavesEnabled: true,
          wavesFrequency: 0.58,
          wavesOctaves: 16,
          wavesDepth: 0.465,
          wavesSampleWidth: 0.01,
          wavesSpeed: 0.683,
          wavesPull: 0.31,
          wavesMix: 0.16,
          wavesFrequencyScaling: 1.18,
          wavesSpeedScaling: 1.1,
          wavesDirectionIncrement: 80,
          wavesShape: 2.393,
        );

  /// Preset 5: Swamp → `water/water_swamp.json`, `<slug>:water_swamp`
  const WaterPresetConfig.swamp()
      : this(
          identifier: 'water_swamp',
          fileName: 'water/water_swamp.json',
          cdom: 7.5,
          chlorophyll: 0.005,
          suspendedSediment: 14.0,
          biomeWaterColorContribution: 0.85,
          causticsEnabled: true,
          causticsFrameLength: 0.0315,
          causticsScale: 0.13,
          causticsPower: 1,
          wavesEnabled: true,
          wavesFrequency: 1.338,
          wavesOctaves: 16,
          wavesDepth: 0.125,
          wavesSampleWidth: 0.115,
          wavesSpeed: 2.383,
          wavesPull: 0.35,
          wavesMix: 0.31,
          wavesFrequencyScaling: 1.22,
          wavesSpeedScaling: 1.11,
          wavesDirectionIncrement: 80,
          wavesShape: 3.393,
        );

  /// Simple UI helper: converts `clarity` (`0.0` = murky .. `1.0` = crystal clear)
  /// directly into `cdom`, `chlorophyll`, and `suspendedSediment`.
  WaterPresetConfig withClarity(double clarity) {
    final c = clarity.clamp(0.0, 1.0);
    final inv = 1.0 - c;
    return copyWith(
      cdom: (inv * 12.0).clamp(0.0, 15.0),
      chlorophyll: (inv * 2.5).clamp(0.0, 10.0),
      suspendedSediment: (inv * 18.0).clamp(0.0, 300.0),
    );
  }

  /// Simple UI helper: sets `biomeWaterColorContribution` (`0.0..1.0`).
  WaterPresetConfig withTintMix(double contribution) {
    return copyWith(biomeWaterColorContribution: contribution.clamp(0.0, 1.0));
  }

  WaterPresetConfig copyWith({
    String? identifier,
    String? fileName,
    double? cdom,
    double? chlorophyll,
    double? suspendedSediment,
    double? biomeWaterColorContribution,
    bool? causticsEnabled,
    double? causticsFrameLength,
    double? causticsScale,
    int? causticsPower,
    bool? wavesEnabled,
    double? wavesFrequency,
    int? wavesOctaves,
    double? wavesDepth,
    double? wavesSampleWidth,
    double? wavesSpeed,
    double? wavesPull,
    double? wavesMix,
    double? wavesFrequencyScaling,
    double? wavesSpeedScaling,
    int? wavesDirectionIncrement,
    double? wavesShape,
  }) {
    return WaterPresetConfig(
      identifier: identifier ?? this.identifier,
      fileName: fileName ?? this.fileName,
      cdom: cdom ?? this.cdom,
      chlorophyll: chlorophyll ?? this.chlorophyll,
      suspendedSediment: suspendedSediment ?? this.suspendedSediment,
      biomeWaterColorContribution:
          biomeWaterColorContribution ?? this.biomeWaterColorContribution,
      causticsEnabled: causticsEnabled ?? this.causticsEnabled,
      causticsFrameLength: causticsFrameLength ?? this.causticsFrameLength,
      causticsScale: causticsScale ?? this.causticsScale,
      causticsPower: causticsPower ?? this.causticsPower,
      wavesEnabled: wavesEnabled ?? this.wavesEnabled,
      wavesFrequency: wavesFrequency ?? this.wavesFrequency,
      wavesOctaves: wavesOctaves ?? this.wavesOctaves,
      wavesDepth: wavesDepth ?? this.wavesDepth,
      wavesSampleWidth: wavesSampleWidth ?? this.wavesSampleWidth,
      wavesSpeed: wavesSpeed ?? this.wavesSpeed,
      wavesPull: wavesPull ?? this.wavesPull,
      wavesMix: wavesMix ?? this.wavesMix,
      wavesFrequencyScaling:
          wavesFrequencyScaling ?? this.wavesFrequencyScaling,
      wavesSpeedScaling: wavesSpeedScaling ?? this.wavesSpeedScaling,
      wavesDirectionIncrement:
          wavesDirectionIncrement ?? this.wavesDirectionIncrement,
      wavesShape: wavesShape ?? this.wavesShape,
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// ColorGradingConfig
// ─────────────────────────────────────────────────────────────────────────────

/// Post-processing color grading settings.
/// Maps to `color_grading/color_grading.json` (`format_version: "1.21.90"`).
class ColorGradingConfig {
  static const Set<String> validOperators = {
    'reinhard',
    'reinhard_luma',
    'reinhard_luminance',
    'hable',
    'aces',
    'generic',
  };

  /// Normalizes and migrates old/deprecated operator values:
  /// filmic -> hable, neutral -> generic.
  static String normalizeOperator(String? op) {
    if (op == null) return 'aces';
    final cleaned = op.trim().toLowerCase();
    if (cleaned == 'filmic') return 'hable';
    if (cleaned == 'neutral') return 'generic';
    if (validOperators.contains(cleaned)) return cleaned;
    return 'aces';
  }

  static const List<String> moodNames = [
    'dynamic',
    'vibrant',
    'savanna',
    'frost',
    'moody',
  ];

  // ── Tone mapping (pack-wide locked) ──────────────────────
  // → tone_mapping.operator

  final String toneMappingOperator;

  // ── White balance / color temperature ────────────────────
  // → color_grading.temperature

  final bool temperatureEnabled;

  /// `'white_balance'` | `'color_temperature'`
  final String temperatureType;

  /// Kelvin, range `1000..15000`, default `6500.0`
  final double temperature;

  // ── Midtones ─────────────────────────────────────────────
  // → color_grading.midtones  (3-element [R, G, B] lists)

  /// range `0.0..4.0`
  final List<double> midtonesContrast;

  /// range `0.0..10.0`
  final List<double> midtonesGain;

  /// range `0.0..4.0`
  final List<double> midtonesGamma;

  /// range `-1.0..1.0`
  final List<double> midtonesOffset;

  /// range `0.0..10.0`
  final List<double> midtonesSaturation;

  // ── Highlights ───────────────────────────────────────────
  // → color_grading.highlights

  final bool highlightsEnabled;

  /// range `1.0..4.0`, default `1.0`
  final double highlightsMin;

  final List<double> highlightsContrast;
  final List<double> highlightsGain;
  final List<double> highlightsGamma;
  final List<double> highlightsOffset;
  final List<double> highlightsSaturation;

  // ── Shadows ──────────────────────────────────────────────
  // → color_grading.shadows

  final bool shadowsEnabled;

  /// range `0.1..1.0`, default `0.4`
  final double shadowsMax;

  final List<double> shadowsContrast;
  final List<double> shadowsGain;
  final List<double> shadowsGamma;
  final List<double> shadowsOffset;
  final List<double> shadowsSaturation;

  const ColorGradingConfig({
    String toneMappingOperator = 'hable',
    this.temperatureEnabled = true,
    this.temperatureType = 'white_balance',
    this.temperature = 6500.0,
    this.midtonesContrast = const [1.35, 1.35, 1.35],
    this.midtonesGain = const [1.05, 1.05, 1.05],
    this.midtonesGamma = const [2.2, 2.2, 2.2],
    this.midtonesOffset = const [0.0, 0.0, 0.0],
    this.midtonesSaturation = const [1.03, 1.03, 1.03],
    this.highlightsEnabled = true,
    this.highlightsMin = 1.0,
    this.highlightsContrast = const [1.1, 1.1, 1.1],
    this.highlightsGain = const [1.04, 1.04, 1.04],
    this.highlightsGamma = const [2.2, 2.2, 2.2],
    this.highlightsOffset = const [0.0, 0.0, 0.0],
    this.highlightsSaturation = const [1.02, 1.02, 1.02],
    this.shadowsEnabled = false,
    this.shadowsMax = 0.4,
    this.shadowsContrast = const [1.1, 1.1, 1.1],
    this.shadowsGain = const [1.0, 1.0, 1.0],
    this.shadowsGamma = const [2.2, 2.2, 2.2],
    this.shadowsOffset = const [0.0, 0.0, 0.0],
    this.shadowsSaturation = const [1.1, 1.1, 1.1],
  }) : toneMappingOperator = (toneMappingOperator == 'filmic')
            ? 'hable'
            : (toneMappingOperator == 'neutral')
                ? 'generic'
                : toneMappingOperator;

  /// Scalar constructor for convenience when uniform RGB channels are desired.
  factory ColorGradingConfig.scalar({
    String toneMappingOperator = 'hable',
    bool temperatureEnabled = true,
    String temperatureType = 'white_balance',
    double temperature = 6500.0,
    double midtonesContrast = 1.35,
    double midtonesGain = 1.05,
    double midtonesGamma = 2.2,
    double midtonesOffset = 0.0,
    double midtonesSaturation = 1.03,
    bool highlightsEnabled = true,
    double highlightsMin = 1.0,
    double highlightsContrast = 1.1,
    double highlightsGain = 1.04,
    double highlightsGamma = 2.2,
    double highlightsOffset = 0.0,
    double highlightsSaturation = 1.02,
    bool shadowsEnabled = false,
    double shadowsMax = 0.4,
    double shadowsContrast = 1.1,
    double shadowsGain = 1.0,
    double shadowsGamma = 2.2,
    double shadowsOffset = 0.0,
    double shadowsSaturation = 1.1,
  }) {
    List<double> v3(double v) => [v, v, v];
    return ColorGradingConfig(
      toneMappingOperator: toneMappingOperator,
      temperatureEnabled: temperatureEnabled,
      temperatureType: temperatureType,
      temperature: temperature,
      midtonesContrast: v3(midtonesContrast),
      midtonesGain: v3(midtonesGain),
      midtonesGamma: v3(midtonesGamma),
      midtonesOffset: v3(midtonesOffset),
      midtonesSaturation: v3(midtonesSaturation),
      highlightsEnabled: highlightsEnabled,
      highlightsMin: highlightsMin,
      highlightsContrast: v3(highlightsContrast),
      highlightsGain: v3(highlightsGain),
      highlightsGamma: v3(highlightsGamma),
      highlightsOffset: v3(highlightsOffset),
      highlightsSaturation: v3(highlightsSaturation),
      shadowsEnabled: shadowsEnabled,
      shadowsMax: shadowsMax,
      shadowsContrast: v3(shadowsContrast),
      shadowsGain: v3(shadowsGain),
      shadowsGamma: v3(shadowsGamma),
      shadowsOffset: v3(shadowsOffset),
      shadowsSaturation: v3(shadowsSaturation),
    );
  }

  /// Generates a named mood preset inheriting [toneMappingOperator].
  factory ColorGradingConfig.forMood(
    String mood, {
    String toneMappingOperator = 'hable',
    ColorGradingConfig? base,
  }) {
    final effectiveOp = normalizeOperator(toneMappingOperator);
    final b = base ?? const ColorGradingConfig();
    switch (mood) {
      case 'vibrant':
        return b.withScalars(
          toneMappingOperator: effectiveOp,
          temperature: 6200.0,
          midtonesSaturation: 1.28,
          midtonesContrast: 1.38,
          highlightsSaturation: 1.18,
          highlightsGain: 1.08,
        );
      case 'savanna':
        return b.withScalars(
          toneMappingOperator: effectiveOp,
          temperature: 5400.0,
          midtonesSaturation: 1.12,
          midtonesContrast: 1.30,
          midtonesGain: 1.08,
        );
      case 'frost':
        return b.withScalars(
          toneMappingOperator: effectiveOp,
          temperature: 8200.0,
          midtonesSaturation: 0.94,
          midtonesContrast: 1.22,
          highlightsGain: 1.06,
        );
      case 'moody':
        return b.withScalars(
          toneMappingOperator: effectiveOp,
          temperature: 7000.0,
          midtonesSaturation: 0.78,
          midtonesContrast: 1.42,
          midtonesGain: 0.95,
          shadowsEnabled: true,
          shadowsGain: 0.88,
        );
      case 'dynamic':
      default:
        return b.copyWith(toneMappingOperator: effectiveOp);
    }
  }

  // Scalar average getters
  static double _avg(List<double> v) =>
      v.isEmpty ? 1.0 : v.reduce((a, b) => a + b) / v.length;

  double get midtonesContrastScalar => _avg(midtonesContrast);
  double get midtonesGainScalar => _avg(midtonesGain);
  double get midtonesGammaScalar => _avg(midtonesGamma);
  double get midtonesOffsetScalar => _avg(midtonesOffset);
  double get midtonesSaturationScalar => _avg(midtonesSaturation);

  double get highlightsContrastScalar => _avg(highlightsContrast);
  double get highlightsGainScalar => _avg(highlightsGain);
  double get highlightsGammaScalar => _avg(highlightsGamma);
  double get highlightsOffsetScalar => _avg(highlightsOffset);
  double get highlightsSaturationScalar => _avg(highlightsSaturation);

  double get shadowsContrastScalar => _avg(shadowsContrast);
  double get shadowsGainScalar => _avg(shadowsGain);
  double get shadowsGammaScalar => _avg(shadowsGamma);
  double get shadowsOffsetScalar => _avg(shadowsOffset);
  double get shadowsSaturationScalar => _avg(shadowsSaturation);

  ColorGradingConfig withScalars({
    String? toneMappingOperator,
    bool? temperatureEnabled,
    String? temperatureType,
    double? temperature,
    double? midtonesContrast,
    double? midtonesGain,
    double? midtonesGamma,
    double? midtonesOffset,
    double? midtonesSaturation,
    bool? highlightsEnabled,
    double? highlightsMin,
    double? highlightsContrast,
    double? highlightsGain,
    double? highlightsGamma,
    double? highlightsOffset,
    double? highlightsSaturation,
    bool? shadowsEnabled,
    double? shadowsMax,
    double? shadowsContrast,
    double? shadowsGain,
    double? shadowsGamma,
    double? shadowsOffset,
    double? shadowsSaturation,
  }) {
    List<double>? v3(double? v) => v == null ? null : [v, v, v];
    return copyWith(
      toneMappingOperator: toneMappingOperator,
      temperatureEnabled: temperatureEnabled,
      temperatureType: temperatureType,
      temperature: temperature,
      midtonesContrast: v3(midtonesContrast),
      midtonesGain: v3(midtonesGain),
      midtonesGamma: v3(midtonesGamma),
      midtonesOffset: v3(midtonesOffset),
      midtonesSaturation: v3(midtonesSaturation),
      highlightsEnabled: highlightsEnabled,
      highlightsMin: highlightsMin,
      highlightsContrast: v3(highlightsContrast),
      highlightsGain: v3(highlightsGain),
      highlightsGamma: v3(highlightsGamma),
      highlightsOffset: v3(highlightsOffset),
      highlightsSaturation: v3(highlightsSaturation),
      shadowsEnabled: shadowsEnabled,
      shadowsMax: shadowsMax,
      shadowsContrast: v3(shadowsContrast),
      shadowsGain: v3(shadowsGain),
      shadowsGamma: v3(shadowsGamma),
      shadowsOffset: v3(shadowsOffset),
      shadowsSaturation: v3(shadowsSaturation),
    );
  }

  ColorGradingConfig copyWith({
    String? toneMappingOperator,
    bool? temperatureEnabled,
    String? temperatureType,
    double? temperature,
    List<double>? midtonesContrast,
    List<double>? midtonesGain,
    List<double>? midtonesGamma,
    List<double>? midtonesOffset,
    List<double>? midtonesSaturation,
    bool? highlightsEnabled,
    double? highlightsMin,
    List<double>? highlightsContrast,
    List<double>? highlightsGain,
    List<double>? highlightsGamma,
    List<double>? highlightsOffset,
    List<double>? highlightsSaturation,
    bool? shadowsEnabled,
    double? shadowsMax,
    List<double>? shadowsContrast,
    List<double>? shadowsGain,
    List<double>? shadowsGamma,
    List<double>? shadowsOffset,
    List<double>? shadowsSaturation,
  }) {
    return ColorGradingConfig(
      toneMappingOperator: toneMappingOperator ?? this.toneMappingOperator,
      temperatureEnabled: temperatureEnabled ?? this.temperatureEnabled,
      temperatureType: temperatureType ?? this.temperatureType,
      temperature: temperature ?? this.temperature,
      midtonesContrast: midtonesContrast ?? this.midtonesContrast,
      midtonesGain: midtonesGain ?? this.midtonesGain,
      midtonesGamma: midtonesGamma ?? this.midtonesGamma,
      midtonesOffset: midtonesOffset ?? this.midtonesOffset,
      midtonesSaturation: midtonesSaturation ?? this.midtonesSaturation,
      highlightsEnabled: highlightsEnabled ?? this.highlightsEnabled,
      highlightsMin: highlightsMin ?? this.highlightsMin,
      highlightsContrast: highlightsContrast ?? this.highlightsContrast,
      highlightsGain: highlightsGain ?? this.highlightsGain,
      highlightsGamma: highlightsGamma ?? this.highlightsGamma,
      highlightsOffset: highlightsOffset ?? this.highlightsOffset,
      highlightsSaturation: highlightsSaturation ?? this.highlightsSaturation,
      shadowsEnabled: shadowsEnabled ?? this.shadowsEnabled,
      shadowsMax: shadowsMax ?? this.shadowsMax,
      shadowsContrast: shadowsContrast ?? this.shadowsContrast,
      shadowsGain: shadowsGain ?? this.shadowsGain,
      shadowsGamma: shadowsGamma ?? this.shadowsGamma,
      shadowsOffset: shadowsOffset ?? this.shadowsOffset,
      shadowsSaturation: shadowsSaturation ?? this.shadowsSaturation,
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// SurfaceConfig
// ─────────────────────────────────────────────────────────────────────────────

/// Global PBR fallback properties.
/// Maps to `pbr/global.json` (`format_version: "1.21.40"`, `minecraft:pbr_fallback_settings`).
class SurfaceConfig {
  /// Metalness fallback `0..255`, default `0`.
  final int metalness;

  /// Emissive fallback `0..255`, default `0`.
  final int emissive;

  /// Roughness fallback `0..255`, default `255` (`255` = matte; default PBR is [0, 0, 255, 0]).
  final int roughness;

  /// Subsurface scattering fallback `0..255`, default `0`.
  final int subsurface;

  const SurfaceConfig({
    this.metalness = 0,
    this.emissive = 0,
    this.roughness = 255,
    this.subsurface = 0,
  });

  /// Constructs a [SurfaceConfig] from a normalized `shininess` (`0.0..1.0`).
  /// `0.0` → roughness `255`, `0.08` → roughness `235`, `1.0` → roughness `0`.
  factory SurfaceConfig.fromShininess(
    double shininess, {
    int metalness = 0,
    int emissive = 0,
    int subsurface = 0,
  }) {
    final s = shininess.clamp(0.0, 1.0);
    return SurfaceConfig(
      metalness: metalness.clamp(0, 255),
      emissive: emissive.clamp(0, 255),
      roughness: ((1.0 - s) * 255.0).round().clamp(0, 255),
      subsurface: subsurface.clamp(0, 255),
    );
  }

  /// Normalized shininess `0.0..1.0` derived from [roughness].
  double get shininess => (1.0 - (roughness / 255.0)).clamp(0.0, 1.0);

  SurfaceConfig copyWith({
    int? metalness,
    int? emissive,
    int? roughness,
    int? subsurface,
  }) {
    return SurfaceConfig(
      metalness: metalness ?? this.metalness,
      emissive: emissive ?? this.emissive,
      roughness: roughness ?? this.roughness,
      subsurface: subsurface ?? this.subsurface,
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// PerformanceTierConfig
// ─────────────────────────────────────────────────────────────────────────────

/// Subpack & performance tier configuration.
class PerformanceTierConfig {
  /// Tier emitted at pack root. Default `PerformanceTier.high`.
  final PerformanceTier activeTier;

  /// Per-tier wave octave counts (defaults match TierProfile table: 1, 8, 16, 28).
  final int octavesLow;
  final int octavesMedium;
  final int octavesHigh;
  final int octavesUltra;

  /// Per-tier shadow texel sizes.
  final int texelLow;
  final int texelMedium;
  final int texelHigh;
  final int texelUltra;

  /// Whether to export `subpacks/<tier>/...` for all 4 tiers.
  final bool exportAllTiers;

  /// Optional "Style Intensity: Lite" subpack (`subpacks/lite/...`) blending
  /// saturation, contrast, and volumetric fog 40% toward neutral.
  final bool styleIntensityLite;

  const PerformanceTierConfig({
    this.activeTier = PerformanceTier.high,
    this.octavesLow = 1,
    this.octavesMedium = 8,
    this.octavesHigh = 16,
    this.octavesUltra = 28,
    this.texelLow = 16,
    this.texelMedium = 32,
    this.texelHigh = 64,
    this.texelUltra = 128,
    this.exportAllTiers = true,
    this.styleIntensityLite = false,
  });

  PerformanceTierConfig copyWith({
    PerformanceTier? activeTier,
    int? octavesLow,
    int? octavesMedium,
    int? octavesHigh,
    int? octavesUltra,
    int? texelLow,
    int? texelMedium,
    int? texelHigh,
    int? texelUltra,
    bool? exportAllTiers,
    bool? styleIntensityLite,
  }) {
    return PerformanceTierConfig(
      activeTier: activeTier ?? this.activeTier,
      octavesLow: octavesLow ?? this.octavesLow,
      octavesMedium: octavesMedium ?? this.octavesMedium,
      octavesHigh: octavesHigh ?? this.octavesHigh,
      octavesUltra: octavesUltra ?? this.octavesUltra,
      texelLow: texelLow ?? this.texelLow,
      texelMedium: texelMedium ?? this.texelMedium,
      texelHigh: texelHigh ?? this.texelHigh,
      texelUltra: texelUltra ?? this.texelUltra,
      exportAllTiers: exportAllTiers ?? this.exportAllTiers,
      styleIntensityLite: styleIntensityLite ?? this.styleIntensityLite,
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Legacy Migration
// ─────────────────────────────────────────────────────────────────────────────

/// Result returned by [migrateFromLegacy] so the UI can report how many old
/// non-VV fields were dropped during import.
class MigrationResult {
  final VVShaderConfig config;
  final int droppedUnsupportedCount;
  final List<String> droppedKeys;

  const MigrationResult({
    required this.config,
    required this.droppedUnsupportedCount,
    required this.droppedKeys,
  });

  String? get userNotice => droppedUnsupportedCount > 0
      ? '$droppedUnsupportedCount settings are no longer supported in Vibrant Visuals (${droppedKeys.join(", ")})'
      : null;
}

Color? _tryColorFromDynamic(dynamic v) {
  if (v is Color) return v;
  if (v is int) return Color(v);
  if (v is String) {
    final hex = v.replaceFirst('#', '').trim();
    if (hex.length == 6) {
      final parsed = int.tryParse('FF$hex', radix: 16);
      if (parsed != null) return Color(parsed);
    } else if (hex.length == 8) {
      final parsed = int.tryParse(hex, radix: 16);
      if (parsed != null) return Color(parsed);
    }
  }
  return null;
}

const Set<String> _kSupportedLegacyKeys = {
  'id',
  'name',
  'packName',
  'creator',
  'description',
  'rating',
  'downloads',
  'tags',
  'morningColor',
  'noonColor',
  'eveningColor',
  'nightColor',
  'fogDensity',
  'morningFogDensity',
  'eveningFogDensity',
  'nightFogDensity',
  'sunRayIntensity',
  'morningRayIntensity',
  'eveningRayIntensity',
  'moonRayIntensity',
  'torchLightColor',
  'torchColor',
  'sunlightColor',
  'soulLightColor',
  'caveAmbientColor',
  'rayMorningColor',
  'rayNoonColor',
  'rayEveningColor',
  'rayNightColor',
  'lightIntensity',
  'ambientBounce',
  'caveAmbientBrightness',
  'emissiveGlow',
  'sunOrbitTilt',
  'shadowQuality',
  'volumetricFogProfile',
  'syncWarmBlocks',
  'syncMysticBlocks',
  'waterColor',
  'deepOceanColor',
  'swampWaterColor',
  'underwaterFogColor',
  'windSpeed',
  'waveAmplitude',
  'waterTransparency',
  'waterSpecularGlint',
  'underwaterVisibility',
  'shorelineFoam',
  'swampTurbidity',
  'waterQuality',
  'underwaterCaustics',
  'biomeWaterTint',
  'rainFogColor',
  'thunderColor',
  'rainFogDensity',
  'lightningIntensity',
  'enablePBR',
  'worldReflectionsEnabled',
  'worldReflections',
  'globalMetalness',
  'metalness',
  'toneMapFilter',
  'biomeTone',
  'globalSaturation',
  'saturation',
  'contrast',
};

const Set<String> _kUnsupportedLegacyKeys = {
  'cloudTopColor',
  'cloudBottomColor',
  'cloudType',
  'volumetricRays',
  'sunSize',
  'sunSizeMorning',
  'sunSizeEvening',
  'moonSize',
  'nightVision',
  'blockLightIntensity',
  'soulLightIntensity',
  'enablePointLightShadows',
  'rainWaterColor',
  'snowFogColor',
  'puddleColor',
  'rainOvercast',
  'thunderSkyDarkness',
  'thunderFogDensity',
  'snowFogDensity',
  'frostShimmer',
  'coldSkyTint',
  'wetSurfaceGloss',
  'puddleReflections',
  'wavingFoliage',
  'foliageWaveSpeed',
  'bloomIntensity',
  'autoExposure',
};

/// Migrates a JSON map saved by the old [ShaderBuildConfig] or [ShaderPresetConfig]
/// into a [MigrationResult] containing the upgraded [VVShaderConfig] and a list
/// of dropped legacy fields that have no VV JSON equivalent.
MigrationResult migrateFromLegacy(Map<String, dynamic> legacy) {
  final dropped = <String>[];
  for (final key in legacy.keys) {
    if (_kUnsupportedLegacyKeys.contains(key) ||
        !_kSupportedLegacyKeys.contains(key)) {
      dropped.add(key);
    }
  }

  final packName = (legacy['packName'] as String?) ??
      (legacy['name'] as String?) ??
      'Piglix Shader';

  // ── Atmosphere ──────────────────────────────────────────
  const defaultAtmo = AtmosphereConfig();
  final noonHorizon = _tryColorFromDynamic(legacy['noonColor']) ??
      defaultAtmo.noonHorizon;
  final sunriseHorizon = _tryColorFromDynamic(legacy['morningColor']) ??
      defaultAtmo.sunriseHorizon;
  final sunsetHorizon = _tryColorFromDynamic(legacy['eveningColor']) ??
      defaultAtmo.sunsetHorizon;
  final nightHorizon = _tryColorFromDynamic(legacy['nightColor']) ??
      defaultAtmo.nightHorizon;

  final fogDensity = (legacy['fogDensity'] as num?)?.toDouble() ?? 1.0;
  final morningFog = (legacy['morningFogDensity'] as num?)?.toDouble() ?? 1.0;
  final eveningFog = (legacy['eveningFogDensity'] as num?)?.toDouble() ?? 1.0;
  final nightFog = (legacy['nightFogDensity'] as num?)?.toDouble() ?? 1.0;

  final sunRay = (legacy['sunRayIntensity'] as num?)?.toDouble() ?? 1.0;
  final morningRay = (legacy['morningRayIntensity'] as num?)?.toDouble() ?? 1.0;
  final eveningRay = (legacy['eveningRayIntensity'] as num?)?.toDouble() ?? 1.0;
  final moonRay = (legacy['moonRayIntensity'] as num?)?.toDouble() ?? 1.0;

  final atmosphere = defaultAtmo.copyWith(
    autoDeriveZenith: false,
    noonZenith: noonHorizon,
    sunriseZenith: sunriseHorizon,
    sunsetZenith: sunsetHorizon,
    nightZenith: nightHorizon,
    noonHorizon: noonHorizon,
    sunriseHorizon: sunriseHorizon,
    sunsetHorizon: sunsetHorizon,
    nightHorizon: nightHorizon,
    rayleighNoon: (defaultAtmo.rayleighNoon * fogDensity).clamp(0.0, 11.0),
    rayleighSunset: (defaultAtmo.rayleighSunset * eveningFog).clamp(0.0, 11.0),
    rayleighNight: (defaultAtmo.rayleighNight * nightFog).clamp(0.0, 11.0),
    rayleighSunrise: (defaultAtmo.rayleighSunrise * morningFog).clamp(0.0, 11.0),
    sunGlowNoon: (4.0 * sunRay).clamp(0.0, 60.0),
    sunGlowSunset: (4.0 * eveningRay).clamp(0.0, 60.0),
    sunGlowSunrise: (4.0 * morningRay).clamp(0.0, 60.0),
    moonGlow: (0.7 * moonRay).clamp(0.0, 20.0),
  );

  // ── Lighting ────────────────────────────────────────────
  const defaultLighting = LightingConfig();

  final torchColor = _tryColorFromDynamic(
        legacy['torchLightColor'] ?? legacy['torchColor'],
      ) ??
      defaultLighting.torchColor;
  final soulColor = _tryColorFromDynamic(legacy['soulLightColor']) ??
      defaultLighting.soulColor;
  final ambientColor = _tryColorFromDynamic(legacy['caveAmbientColor']) ??
      defaultLighting.ambientColor;

  final sunColorNoon = _tryColorFromDynamic(
        legacy['rayNoonColor'] ?? legacy['sunlightColor'],
      ) ??
      defaultLighting.sunColorNoon;
  final sunColorSunset = _tryColorFromDynamic(legacy['rayEveningColor']) ??
      defaultLighting.sunColorSunset;
  final sunColorSunrise = _tryColorFromDynamic(legacy['rayMorningColor']) ??
      defaultLighting.sunColorSunrise;
  final nightMoonColor = _tryColorFromDynamic(legacy['rayNightColor']) ??
      defaultLighting.nightMoonColor;

  final sunBrightnessMultiplier =
      ((legacy['lightIntensity'] as num?)?.toDouble() ?? 1.0).clamp(0.1, 2.0);
  final ambientBounce =
      (legacy['ambientBounce'] as num?)?.toDouble() ?? 1.0;
  final caveBright =
      (legacy['caveAmbientBrightness'] as num?)?.toDouble() ?? 1.0;
  final emissiveGlow = (legacy['emissiveGlow'] as num?)?.toDouble() ?? 1.0;
  final orbitTilt = (legacy['sunOrbitTilt'] as num?)?.toDouble() ??
      defaultLighting.orbitalOffsetDegrees;
  final lightning = (legacy['lightningIntensity'] as num?)?.toDouble() ?? 0.0;
  final flashColor = _tryColorFromDynamic(legacy['thunderColor']) ??
      defaultLighting.flashColor;

  String shadowStyle = defaultLighting.shadowStyle;
  int shadowTexelSize = defaultLighting.shadowTexelSize;
  if (legacy.containsKey('shadowQuality')) {
    final sq = (legacy['shadowQuality'] as String? ?? '').toLowerCase();
    if (sq == 'off' || sq == 'low' || sq == 'medium') {
      shadowStyle = 'blocky_shadows';
      shadowTexelSize = sq == 'off' ? 64 : 512;
    } else {
      shadowStyle = 'soft_shadows';
      shadowTexelSize = 1024;
    }
  }

  final lighting = defaultLighting.copyWith(
    sunBrightnessMultiplier: sunBrightnessMultiplier,
    sunColorNoon: sunColorNoon,
    sunColorSunset: sunColorSunset,
    sunColorSunrise: sunColorSunrise,
    nightMoonColor: nightMoonColor,
    ambientColor: ambientColor,
    ambientIlluminance: (0.02 * caveBright).clamp(0.0, 5.0),
    skyIntensity: (0.7 * ambientBounce).clamp(0.1, 1.0),
    emissiveDesaturation:
        (0.3 - (emissiveGlow - 1.0) * 0.2).clamp(0.0, 1.0),
    orbitalOffsetDegrees: orbitTilt.clamp(0.0, 359.98),
    flashIlluminance: (lightning * 14.0).clamp(0.0, 20000.0),
    flashColor: flashColor,
    torches: defaultLighting.torches.copyWith(color: torchColor),
    lanterns: defaultLighting.lanterns.copyWith(color: torchColor),
    soulFire: defaultLighting.soulFire.copyWith(color: soulColor),
    syncWarmToTorch:
        (legacy['syncWarmBlocks'] as bool?) ?? defaultLighting.syncWarmToTorch,
    syncMysticToSoul:
        (legacy['syncMysticBlocks'] as bool?) ??
        defaultLighting.syncMysticToSoul,
    shadowStyle: shadowStyle,
    shadowTexelSize: shadowTexelSize,
  );

  // ── Fog ─────────────────────────────────────────────────
  const defaultFog = FogConfig();
  final weatherColor = _tryColorFromDynamic(legacy['rainFogColor']) ??
      defaultFog.weatherFogColor;
  final waterFogColor = _tryColorFromDynamic(legacy['underwaterFogColor']) ??
      defaultFog.waterFogColor;
  final uwVis = (legacy['underwaterVisibility'] as num?)?.toDouble() ?? 1.0;
  final volProfile = (legacy['volumetricFogProfile'] as String?) ?? 'Cinematic';
  final baseVol = volProfile == 'Light'
      ? 0.012
      : (volProfile == 'Balanced' ? 0.035 : 0.065);

  final fog = defaultFog.copyWith(
    weatherFogColor: weatherColor,
    waterFogColor: waterFogColor,
    waterFogEnd: (45.0 * uwVis).clamp(12.0, 120.0),
    volumetricMaxDensity: (baseVol * fogDensity).clamp(0.002, 0.25),
    caveWaterVisibility: (uwVis * 0.5).clamp(0.0, 1.0),
  );

  // ── Water ───────────────────────────────────────────────
  final windSpeed = (legacy['windSpeed'] as num?)?.toDouble() ?? 1.0;
  final waveAmp = (legacy['waveAmplitude'] as num?)?.toDouble() ?? 1.0;
  final transparency =
      (legacy['waterTransparency'] as num?)?.toDouble() ?? 0.85;
  final glint = (legacy['waterSpecularGlint'] as num?)?.toDouble() ?? 1.0;
  final foam = (legacy['shorelineFoam'] as num?)?.toDouble() ?? 1.0;
  final swampTurb = (legacy['swampTurbidity'] as num?)?.toDouble() ?? 1.0;
  final causticsEnabled = (legacy['underwaterCaustics'] as bool?) ?? true;
  final waterQuality =
      (legacy['waterQuality'] as String? ?? 'High').toLowerCase();

  final octaves = waterQuality == 'ultra'
      ? 28
      : (waterQuality == 'high' ? 16 : (waterQuality == 'medium' ? 8 : 1));
  final waterGlobal = WaterGlobalSettings(
    wavesEnabled: waterQuality != 'low',
    causticsEnabled: causticsEnabled,
    causticsPower: (1.35 * glint).round().clamp(1, 6),
    causticsScale: (0.13 / glint.clamp(0.5, 2.0)).clamp(0.1, 5.0),
  );

  WaterPresetConfig scaleWater(WaterPresetConfig p, {bool isSwamp = false}) {
    return p
        .withClarity(isSwamp ? (1.0 - swampTurb * 0.6).clamp(0.0, 1.0) : transparency)
        .copyWith(
          wavesEnabled: waterGlobal.wavesEnabled,
          causticsEnabled: waterGlobal.causticsEnabled,
          causticsPower: waterGlobal.causticsPower,
          causticsScale: waterGlobal.causticsScale,
          wavesOctaves: octaves,
          wavesSpeed: (p.wavesSpeed * windSpeed).clamp(0.01, 10.0),
          wavesFrequency: (p.wavesFrequency * windSpeed).clamp(0.01, 3.0),
          wavesDepth: (p.wavesDepth * waveAmp).clamp(0.0, 3.0),
          wavesMix: (p.wavesMix * foam).clamp(0.0, 1.0),
        );
  }

  // ── Color Grading ───────────────────────────────────────
  const defaultCg = ColorGradingConfig();
  String toneOp = defaultCg.toneMappingOperator;
  if (legacy.containsKey('toneMapFilter')) {
    final raw = (legacy['toneMapFilter'] as String? ?? '').toLowerCase();
    if (raw.contains('aces')) {
      toneOp = 'aces';
    } else if (raw.contains('reinhard')) {
      toneOp = 'reinhard';
    } else {
      toneOp = 'hable';
    }
  }
  final biomeToneRaw = (legacy['biomeTone'] as String? ?? 'dynamic').toLowerCase();
  final activeMood = ColorGradingConfig.moodNames.contains(biomeToneRaw)
      ? biomeToneRaw
      : 'dynamic';

  final sat = (legacy['globalSaturation'] ?? legacy['saturation'] as num?)
          ?.toDouble() ??
      defaultCg.midtonesSaturationScalar;
  final con =
      (legacy['contrast'] as num?)?.toDouble() ?? defaultCg.midtonesContrastScalar;

  final colorGrading = ColorGradingConfig.forMood(
    activeMood,
    toneMappingOperator: toneOp,
  ).withScalars(
    midtonesSaturation: sat.clamp(0.0, 10.0),
    midtonesContrast: con.clamp(0.0, 4.0),
  );

  // ── Surface PBR ─────────────────────────────────────────
  final enablePbr = (legacy['enablePBR'] as bool?) ?? true;
  final worldRefl =
      (legacy['worldReflectionsEnabled'] ?? legacy['worldReflections'] as bool?) ??
          true;
  final metalFloat =
      ((legacy['globalMetalness'] ?? legacy['metalness']) as num?)?.toDouble() ??
          0.0;
  final surface = SurfaceConfig(
    metalness: (metalFloat * 255).round().clamp(0, 255),
    roughness: (!enablePbr || !worldRefl) ? 255 : 235,
    subsurface: 0,
  );

  // ── Biome overrides for legacy water colors ──────────────
  final legacyWaterColor = _tryColorFromDynamic(legacy['waterColor']);
  final legacyDeepColor = _tryColorFromDynamic(legacy['deepOceanColor']);
  final legacySwampColor = _tryColorFromDynamic(legacy['swampWaterColor']);
  final groupOverrides = <BiomeGroup, BiomeAppearanceOverride>{};
  if (legacyWaterColor != null) {
    groupOverrides[BiomeGroup.ocean] =
        BiomeAppearanceOverride(waterSurfaceColor: legacyWaterColor);
  }
  if (legacySwampColor != null) {
    groupOverrides[BiomeGroup.swamp] =
        BiomeAppearanceOverride(waterSurfaceColor: legacySwampColor);
  }
  final biomeMapOverrides = <String, BiomeAppearanceOverride>{};
  if (legacyDeepColor != null) {
    for (final b in ['deep_ocean', 'deep_warm_ocean', 'deep_lukewarm_ocean', 'deep_cold_ocean', 'deep_frozen_ocean']) {
      biomeMapOverrides[b] =
          BiomeAppearanceOverride(waterSurfaceColor: legacyDeepColor);
    }
  }

  final activeTier = waterQuality == 'ultra'
      ? PerformanceTier.ultra
      : (waterQuality == 'medium'
          ? PerformanceTier.medium
          : (waterQuality == 'low'
              ? PerformanceTier.low
              : PerformanceTier.high));

  final config = VVShaderConfig(
    packName: packName,
    atmosphere: atmosphere,
    lighting: lighting,
    fog: fog,
    waterGlobal: waterGlobal,
    waterTropical: scaleWater(const WaterPresetConfig.tropical()),
    waterOcean: scaleWater(const WaterPresetConfig.ocean()),
    waterDeepOcean: scaleWater(const WaterPresetConfig.deepOcean()),
    waterRiver: scaleWater(const WaterPresetConfig.river()),
    waterSwamp: scaleWater(const WaterPresetConfig.swamp(), isSwamp: true),
    colorGrading: colorGrading,
    activeMood: activeMood,
    surface: surface,
    performance: PerformanceTierConfig(activeTier: activeTier),
    biomeOverrides: BiomeOverridesConfig(
      groupOverrides: groupOverrides,
      biomeOverrides: biomeMapOverrides,
    ),
  );

  return MigrationResult(
    config: config,
    droppedUnsupportedCount: dropped.length,
    droppedKeys: dropped,
  );
}
