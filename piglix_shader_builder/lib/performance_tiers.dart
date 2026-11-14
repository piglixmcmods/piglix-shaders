// performance_tiers.dart
import 'vv_config.dart';

/// How block lights are emitted in `local_lighting/local_lighting.json` for a tier.
enum BlockLightsMode {
  /// All 7 block light groups use `'static_light'` (0 real-time point lights).
  allStatic,

  /// Only Torches, Lanterns, and Soul Fire emit `'point_light'`; rest `'static_light'`.
  torchesLanternsSoulOnly,

  /// All groups except Copper emit `'point_light'`; Copper uses `'static_light'`.
  allExceptCopper,

  /// All 7 groups keep their configured `'point_light'` / `'static_light'` mode.
  allPointLights,
}

/// Hardware/quality profile for a single Bedrock subpack tier.
class TierProfile {
  final PerformanceTier tier;
  final String folderName;
  final String displayName;
  final bool wavesEnabled;
  final int wavesOctaves;
  final bool causticsEnabled;
  final BlockLightsMode blockLightsMode;
  final double fogDensityScale;
  final String shadowStyle;
  final int shadowTexelSize;
  final bool pbrTextureSets;
  final int memoryTier;

  const TierProfile({
    required this.tier,
    required this.folderName,
    required this.displayName,
    required this.wavesEnabled,
    required this.wavesOctaves,
    required this.causticsEnabled,
    required this.blockLightsMode,
    required this.fogDensityScale,
    required this.shadowStyle,
    required this.shadowTexelSize,
    required this.pbrTextureSets,
    required this.memoryTier,
  });

  static const TierProfile low = TierProfile(
    tier: PerformanceTier.low,
    folderName: 'low',
    displayName: 'Low (Battery Saver)',
    wavesEnabled: false,
    wavesOctaves: 1,
    causticsEnabled: false,
    blockLightsMode: BlockLightsMode.allStatic,
    fogDensityScale: 0.5,
    shadowStyle: 'blocky_shadows',
    shadowTexelSize: 16,
    pbrTextureSets: false,
    memoryTier: 6,
  );

  static const TierProfile medium = TierProfile(
    tier: PerformanceTier.medium,
    folderName: 'medium',
    displayName: 'Medium (Balanced)',
    wavesEnabled: true,
    wavesOctaves: 8,
    causticsEnabled: true,
    blockLightsMode: BlockLightsMode.torchesLanternsSoulOnly,
    fogDensityScale: 0.75,
    shadowStyle: 'blocky_shadows',
    shadowTexelSize: 32,
    pbrTextureSets: false,
    memoryTier: 12,
  );

  static const TierProfile high = TierProfile(
    tier: PerformanceTier.high,
    folderName: 'high',
    displayName: 'High (Recommended)',
    wavesEnabled: true,
    wavesOctaves: 16,
    causticsEnabled: true,
    blockLightsMode: BlockLightsMode.allExceptCopper,
    fogDensityScale: 1.0,
    shadowStyle: 'soft_shadows',
    shadowTexelSize: 64,
    pbrTextureSets: true,
    memoryTier: 18,
  );

  static const TierProfile ultra = TierProfile(
    tier: PerformanceTier.ultra,
    folderName: 'ultra',
    displayName: 'Ultra (Maximum)',
    wavesEnabled: true,
    wavesOctaves: 28,
    causticsEnabled: true,
    blockLightsMode: BlockLightsMode.allPointLights,
    fogDensityScale: 1.0,
    shadowStyle: 'soft_shadows',
    shadowTexelSize: 128,
    pbrTextureSets: true,
    memoryTier: 32,
  );

  static const List<TierProfile> all = [low, medium, high, ultra];

  /// Returns the [TierProfile] for [tier], respecting any user octave/texel
  /// overrides stored in [perfConfig].
  static TierProfile forTier(
    PerformanceTier tier, [
    PerformanceTierConfig? perfConfig,
  ]) {
    final base = switch (tier) {
      PerformanceTier.low => low,
      PerformanceTier.medium => medium,
      PerformanceTier.high => high,
      PerformanceTier.ultra => ultra,
    };
    if (perfConfig == null) return base;
    final octaves = switch (tier) {
      PerformanceTier.low => perfConfig.octavesLow,
      PerformanceTier.medium => perfConfig.octavesMedium,
      PerformanceTier.high => perfConfig.octavesHigh,
      PerformanceTier.ultra => perfConfig.octavesUltra,
    };
    final texel = switch (tier) {
      PerformanceTier.low => perfConfig.texelLow,
      PerformanceTier.medium => perfConfig.texelMedium,
      PerformanceTier.high => perfConfig.texelHigh,
      PerformanceTier.ultra => perfConfig.texelUltra,
    };
    return TierProfile(
      tier: base.tier,
      folderName: base.folderName,
      displayName: base.displayName,
      wavesEnabled: base.wavesEnabled,
      wavesOctaves: octaves.clamp(1, 30),
      causticsEnabled: base.causticsEnabled,
      blockLightsMode: base.blockLightsMode,
      fogDensityScale: base.fogDensityScale,
      shadowStyle: base.shadowStyle,
      shadowTexelSize: texel.clamp(1, 1024),
      pbrTextureSets: base.pbrTextureSets,
      memoryTier: base.memoryTier,
    );
  }
}

/// Applies a [TierProfile] onto [cfg] to produce the tier-specific [VVShaderConfig]
/// while preserving pack-wide locked invariants within that tier.
VVShaderConfig applyTierToConfig(VVShaderConfig cfg, TierProfile profile) {
  final l = cfg.lighting;
  LightingConfig tierLighting;

  switch (profile.blockLightsMode) {
    case BlockLightsMode.allStatic:
      tierLighting = l.copyWith(
        torches: l.torches.copyWith(lightType: 'static_light'),
        lanterns: l.lanterns.copyWith(lightType: 'static_light'),
        soulFire: l.soulFire.copyWith(lightType: 'static_light'),
        candles: l.candles.copyWith(lightType: 'static_light'),
        redstone: l.redstone.copyWith(lightType: 'static_light'),
        endRod: l.endRod.copyWith(lightType: 'static_light'),
        copper: l.copper.copyWith(lightType: 'static_light'),
      );
      break;
    case BlockLightsMode.torchesLanternsSoulOnly:
      tierLighting = l.copyWith(
        candles: l.candles.copyWith(lightType: 'static_light'),
        redstone: l.redstone.copyWith(lightType: 'static_light'),
        endRod: l.endRod.copyWith(lightType: 'static_light'),
        copper: l.copper.copyWith(lightType: 'static_light'),
      );
      break;
    case BlockLightsMode.allExceptCopper:
      tierLighting = l.copyWith(
        copper: l.copper.copyWith(lightType: 'static_light'),
      );
      break;
    case BlockLightsMode.allPointLights:
      tierLighting = l;
      break;
  }

  // Shadow style is a user choice, NOT tied to performance tiers.
  final effectiveShadowStyle = l.shadowStyle;
  final effectiveTexelSize = profile.shadowTexelSize.clamp(1, 1024);

  tierLighting = tierLighting.copyWith(
    shadowStyle: effectiveShadowStyle,
    shadowTexelSize: effectiveTexelSize,
  );

  // Scale water globals & presets consistently across all 5 water presets
  final tierWaterGlobal = cfg.waterGlobal.copyWith(
    wavesEnabled: cfg.waterGlobal.wavesEnabled && profile.wavesEnabled,
    causticsEnabled: cfg.waterGlobal.causticsEnabled && profile.causticsEnabled,
  );

  WaterPresetConfig scalePreset(WaterPresetConfig p) {
    return p.copyWith(
      wavesEnabled: tierWaterGlobal.wavesEnabled,
      causticsEnabled: tierWaterGlobal.causticsEnabled,
      causticsFrameLength: tierWaterGlobal.causticsFrameLength,
      causticsPower: tierWaterGlobal.causticsPower,
      causticsScale: tierWaterGlobal.causticsScale,
      wavesOctaves: profile.wavesOctaves.clamp(1, 30),
    );
  }

  final tierFog = cfg.fog.copyWith(
    volumetricMaxDensity:
        (cfg.fog.volumetricMaxDensity * profile.fogDensityScale)
            .clamp(0.002, 0.25),
    underwaterVolumeDensity:
        (cfg.fog.underwaterVolumeDensity * profile.fogDensityScale)
            .clamp(0.002, 0.08),
  );

  return cfg.copyWith(
    lighting: tierLighting,
    fog: tierFog,
    waterGlobal: tierWaterGlobal,
    waterTropical: scalePreset(cfg.waterTropical),
    waterOcean: scalePreset(cfg.waterOcean),
    waterDeepOcean: scalePreset(cfg.waterDeepOcean),
    waterRiver: scalePreset(cfg.waterRiver),
    waterSwamp: scalePreset(cfg.waterSwamp),
  );
}

/// Blends saturation, contrast, and volumetric fog 40% toward neutral for the
/// optional `"lite"` ("Style Intensity: Lite") subpack.
VVShaderConfig applyLiteStyle(VVShaderConfig cfg) {
  List<double> blendToOne(List<double> vals) =>
      vals.map((v) => v + (1.0 - v) * 0.4).toList();

  final cg = cfg.colorGrading;
  final liteCg = cg.copyWith(
    midtonesContrast: blendToOne(cg.midtonesContrast),
    midtonesSaturation: blendToOne(cg.midtonesSaturation),
    highlightsContrast: blendToOne(cg.highlightsContrast),
    highlightsSaturation: blendToOne(cg.highlightsSaturation),
    shadowsContrast: blendToOne(cg.shadowsContrast),
    shadowsSaturation: blendToOne(cg.shadowsSaturation),
  );

  // Blend volumetric fog 40% toward subtle/neutral (0.015)
  final liteFog = cfg.fog.copyWith(
    volumetricMaxDensity:
        (cfg.fog.volumetricMaxDensity * 0.6 + 0.015 * 0.4).clamp(0.002, 0.25),
  );

  return cfg.copyWith(
    colorGrading: liteCg,
    fog: liteFog,
  );
}

/// Detailed cost component breakdown for the 100-point performance score (Rule 27).
class PerformanceScoreBreakdown {
  /// Shadows: resolution + texel size (up to 25 pts).
  final double shadows;

  /// Volumetric fog: samples / steps / media density (up to 20 pts).
  final double volumetricFog;

  /// Point lights: count + radius (up to 20 pts).
  final double pointLights;

  /// Water: caustics + wave octaves (up to 15 pts).
  final double waterWavesCaustics;

  /// PBR fallback: subsurface / metalness (up to 10 pts).
  final double pbrFallback;

  /// Color grading enabled: tonemapping / curves (up to 10 pts).
  final double colorGrading;

  const PerformanceScoreBreakdown({
    required this.shadows,
    required this.volumetricFog,
    required this.pointLights,
    required this.waterWavesCaustics,
    required this.pbrFallback,
    required this.colorGrading,
  });

  /// Formatted explanation for UI tooltips (Rule 27).
  String get tooltipText =>
      'Performance Cost Breakdown (Total: 100 pts):\n'
      '• Shadows (Resolution + Texel Size): ${shadows.round()} / 25 pts (25%)\n'
      '• Volumetric Fog (Samples & Steps): ${volumetricFog.round()} / 20 pts (20%)\n'
      '• Point Lights (Count & Radius): ${pointLights.round()} / 20 pts (20%)\n'
      '• Water (Caustics + Wave Octaves): ${waterWavesCaustics.round()} / 15 pts (15%)\n'
      '• PBR Fallback & Materials: ${pbrFallback.round()} / 10 pts (10%)\n'
      '• Color Grading & Tonemapping: ${colorGrading.round()} / 10 pts (10%)';
}

/// Live performance estimation for UI feedback before export.
class PerformanceScoreResult {
  /// `'Low' | 'Medium' | 'High' | 'Heavy'`
  final String scoreLabel;

  /// Numeric cost score `0..100` (higher = heavier GPU load).
  final int numericScore;

  /// Number of blocks configured with `light_type == 'point_light'`.
  final int pointLightsCount;

  /// Plain-language warnings for heavy configurations, specifically explaining
  /// mobile GPU memory bandwidth throttling (Rule 28).
  final List<String> warnings;

  /// Detailed 100-pt breakdown of each weighted criterion (Rule 27).
  final PerformanceScoreBreakdown breakdown;

  const PerformanceScoreResult({
    required this.scoreLabel,
    required this.numericScore,
    required this.pointLightsCount,
    required this.warnings,
    required this.breakdown,
  });
}

/// Computes an estimated GPU/mobile performance score from [cfg] based on the
/// official 100-point formula (Rule 27) and evaluates mobile GPU throttling
/// warnings (Rule 28).
PerformanceScoreResult computePerformanceScore(VVShaderConfig cfg) {
  final warnings = <String>[];
  final pointLights = cfg.lighting.countPointLightBlocks();

  // 1. Shadows (Resolution + Texel Size): 25% (up to 25 pts)
  double shadowCost;
  if (cfg.lighting.shadowStyle == 'soft_shadows') {
    shadowCost = 25.0;
  } else {
    // blocky shadows: texel size 1..1024
    shadowCost = 5.0 + ((cfg.lighting.shadowTexelSize.clamp(1, 1024) / 1024.0) * 15.0);
  }

  // 2. Volumetric fog (Samples / Steps / Media): 20% (up to 20 pts)
  final airFogCost = (cfg.fog.volumetricMaxDensity / 0.25).clamp(0.0, 1.0) * 12.0;
  final waterFogCost =
      (cfg.fog.underwaterVolumeDensity / 0.08).clamp(0.0, 1.0) * 8.0;
  final volumetricCost = (airFogCost + waterFogCost).clamp(0.0, 20.0);

  // 3. Point lights count + radius: 20% (up to 20 pts)
  final totalBlocks = LightingConfig.totalPointLightBlocks;
  final pointLightCost =
      (pointLights / (totalBlocks > 0 ? totalBlocks : 44)).clamp(0.0, 1.0) * 20.0;

  // 4. Caustics + Wave octaves: 15% (up to 15 pts)
  final maxOctaves = [
    cfg.waterTropical.wavesOctaves,
    cfg.waterOcean.wavesOctaves,
    cfg.waterDeepOcean.wavesOctaves,
    cfg.waterRiver.wavesOctaves,
    cfg.waterSwamp.wavesOctaves,
  ].reduce((a, b) => a > b ? a : b);

  var waterCost = 0.0;
  if (cfg.waterGlobal.wavesEnabled) {
    waterCost += (maxOctaves.clamp(1, 30) / 30.0) * 10.0;
  }
  if (cfg.waterGlobal.causticsEnabled) {
    waterCost += 5.0;
  }
  waterCost = waterCost.clamp(0.0, 15.0);

  // 5. PBR Fallback: 10% (up to 10 pts)
  // Subsurface scattering on deferred renderers adds G-buffer bandwidth cost
  final pbrCost = 5.0 + ((cfg.surface.subsurface.clamp(0, 255) / 255.0) * 5.0);

  // 6. Color Grading & Tonemapping enabled: 10% (up to 10 pts)
  const colorGradingCost = 10.0;

  final breakdown = PerformanceScoreBreakdown(
    shadows: shadowCost,
    volumetricFog: volumetricCost,
    pointLights: pointLightCost,
    waterWavesCaustics: waterCost,
    pbrFallback: pbrCost,
    colorGrading: colorGradingCost,
  );

  final totalScore = (shadowCost +
          volumetricCost +
          pointLightCost +
          waterCost +
          pbrCost +
          colorGradingCost)
      .round()
      .clamp(0, 100);

  // Rule 28: Mobile GPU memory bandwidth throttling warnings
  if (pointLights > 16) {
    warnings.add(
      'Point lights count ($pointLights blocks > 16): mobile GPUs throttle quickly on deferred memory bandwidth.',
    );
  }

  if (cfg.lighting.shadowTexelSize < 16) {
    warnings.add(
      'Shadow texel size (${cfg.lighting.shadowTexelSize} < 16): mobile GPUs throttle quickly on deferred memory bandwidth.',
    );
  } else if (cfg.lighting.shadowStyle == 'soft_shadows' &&
      cfg.performance.activeTier == PerformanceTier.low) {
    warnings.add(
      'Soft shadows on Low tier: mobile GPUs throttle quickly on deferred memory bandwidth (prefer blocky shadows for Low tier).',
    );
  }

  if (cfg.waterGlobal.wavesEnabled && maxOctaves > 8) {
    warnings.add(
      'Water wave octaves ($maxOctaves > 8): high fragment noise ALU cost; mobile GPUs throttle quickly on deferred memory bandwidth.',
    );
  }

  if (cfg.fog.volumetricMaxDensity > 0.05 &&
      cfg.fog.underwaterVolumeDensity > 0.02) {
    warnings.add(
      'Volumetric media active on multiple layers (air + water): mobile GPUs throttle quickly on deferred memory bandwidth.',
    );
  }

  final String label;
  if (totalScore < 30) {
    label = 'Low';
  } else if (totalScore < 55) {
    label = 'Medium';
  } else if (totalScore < 80) {
    label = 'High';
  } else {
    label = 'Heavy';
  }

  return PerformanceScoreResult(
    scoreLabel: label,
    numericScore: totalScore,
    pointLightsCount: pointLights,
    warnings: warnings,
    breakdown: breakdown,
  );
}
