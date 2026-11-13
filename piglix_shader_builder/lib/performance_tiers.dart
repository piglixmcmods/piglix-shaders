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
    shadowTexelSize: 512,
    pbrTextureSets: false,
    memoryTier: 2,
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
    shadowTexelSize: 1024,
    pbrTextureSets: false,
    memoryTier: 4,
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
    shadowTexelSize: 1024,
    pbrTextureSets: true,
    memoryTier: 6,
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
    shadowTexelSize: 1024,
    pbrTextureSets: true,
    memoryTier: 8,
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

  // Hardware tiers that require blocky_shadows enforce it for performance;
  // higher tiers preserve explicit blocky_shadows selection from Light & Shadows tab.
  final effectiveShadowStyle = profile.shadowStyle == 'blocky_shadows'
      ? 'blocky_shadows'
      : l.shadowStyle;
  final effectiveTexelSize = (effectiveShadowStyle == 'blocky_shadows' &&
          l.shadowStyle == 'blocky_shadows')
      ? l.shadowTexelSize.clamp(1, 1024)
      : profile.shadowTexelSize.clamp(1, 1024);

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

/// Live performance estimation for UI feedback before export.
class PerformanceScoreResult {
  /// `'Low' | 'Medium' | 'High' | 'Heavy'`
  final String scoreLabel;

  /// Numeric cost score `0..100` (higher = heavier GPU load).
  final int numericScore;

  /// Number of blocks configured with `light_type == 'point_light'`.
  final int pointLightsCount;

  /// Plain-language warnings for heavy configurations.
  final List<String> warnings;

  const PerformanceScoreResult({
    required this.scoreLabel,
    required this.numericScore,
    required this.pointLightsCount,
    required this.warnings,
  });
}

/// Computes an estimated GPU/mobile performance score from [cfg].
PerformanceScoreResult computePerformanceScore(VVShaderConfig cfg) {
  final warnings = <String>[];
  final pointLights = cfg.lighting.countPointLightBlocks();

  // Base cost factors
  var score = 0.0;

  // 1. Point lights (up to ~31 blocks -> up to 35 pts)
  score += (pointLights / 31.0) * 35.0;
  if (pointLights > 20) {
    warnings.add(
      'High point-light count ($pointLights blocks) may lag mobile GPUs',
    );
  }

  // 2. Water wave octaves & caustics (up to 30 pts)
  final maxOctaves = [
    cfg.waterTropical.wavesOctaves,
    cfg.waterOcean.wavesOctaves,
    cfg.waterDeepOcean.wavesOctaves,
    cfg.waterRiver.wavesOctaves,
    cfg.waterSwamp.wavesOctaves,
  ].reduce((a, b) => a > b ? a : b);

  if (cfg.waterGlobal.wavesEnabled) {
    score += (maxOctaves / 30.0) * 22.0;
    if (maxOctaves > 20) {
      warnings.add(
        'High water wave octaves ($maxOctaves) increase fragment shader cost',
      );
    }
  }
  if (cfg.waterGlobal.causticsEnabled) {
    score += 8.0;
  }

  // 3. Shadows (up to 20 pts)
  if (cfg.lighting.shadowStyle == 'soft_shadows') {
    score += 18.0;
  } else {
    score += (cfg.lighting.shadowTexelSize / 1024.0) * 10.0;
  }

  // 4. Volumetric fog density (up to 15 pts)
  score += (cfg.fog.volumetricMaxDensity / 0.25).clamp(0.0, 1.0) * 15.0;
  if (cfg.fog.volumetricMaxDensity > 0.14) {
    warnings.add(
      'Dense volumetric air fog may reduce framerate on low-end devices',
    );
  }

  final intScore = score.round().clamp(0, 100);
  final String label;
  if (intScore < 30) {
    label = 'Low';
  } else if (intScore < 55) {
    label = 'Medium';
  } else if (intScore < 80) {
    label = 'High';
  } else {
    label = 'Heavy';
  }

  return PerformanceScoreResult(
    scoreLabel: label,
    numericScore: intScore,
    pointLightsCount: pointLights,
    warnings: warnings,
  );
}
