// vv_biomes.dart
import 'package:flutter/material.dart' show Color;

/// Biome grouping used for 3-layer overrides (Global -> Group -> Single Biome).
enum BiomeGroup {
  forest,
  desertBadlands,
  snow,
  ocean,
  swamp,
  jungle,
  cherry,
  cavesDeepDark,
  nether,
  end,
}

extension BiomeGroupExt on BiomeGroup {
  String get displayName {
    switch (this) {
      case BiomeGroup.forest:
        return 'Plains & Forests';
      case BiomeGroup.desertBadlands:
        return 'Desert & Badlands';
      case BiomeGroup.snow:
        return 'Snow & Ice';
      case BiomeGroup.ocean:
        return 'Oceans & Rivers';
      case BiomeGroup.swamp:
        return 'Swamps & Mangroves';
      case BiomeGroup.jungle:
        return 'Jungles';
      case BiomeGroup.cherry:
        return 'Cherry Grove';
      case BiomeGroup.cavesDeepDark:
        return 'Caves & Deep Dark';
      case BiomeGroup.nether:
        return 'The Nether';
      case BiomeGroup.end:
        return 'The End';
    }
  }
}

/// Dimension of a vanilla Bedrock biome.
enum BiomeDimension { overworld, nether, end }

/// Metadata and default VV visual bindings for a vanilla Minecraft Bedrock biome.
class VanillaBiomeEntry {
  /// Vanilla biome identifier (without namespace, e.g. 'plains', 'the_end').
  final String id;

  /// Human-readable label for UI display.
  final String displayName;

  /// High-level group for Layer-2 overrides.
  final BiomeGroup group;

  /// Dimension (used to preserve Nether/End defaults separately from Overworld).
  final BiomeDimension dimension;

  /// Default water preset key ('water_tropical', 'water_ocean', 'water_deep_ocean',
  /// 'water_river', 'water_swamp').
  final String defaultWaterPreset;

  /// Default fog preset key (resolved as `<packSlug>:<defaultFogPreset>`).
  final String defaultFogPreset;

  /// Default atmosphere preset key (resolved as `<packSlug>:<defaultAtmospherePreset>`).
  final String defaultAtmospherePreset;

  /// Default lighting preset key (resolved as `<packSlug>:<defaultLightingPreset>`).
  final String defaultLightingPreset;

  /// Default color grading preset key (resolved as `<packSlug>:<defaultColorGradingPreset>`).
  final String defaultColorGradingPreset;

  /// Default `minecraft:sky_color.sky_color`.
  final Color defaultSkyColor;

  /// Default `minecraft:water_appearance.surface_color`.
  final Color defaultWaterSurfaceColor;

  /// Optional default `minecraft:water_appearance.surface_opacity` (0..1).
  final double? defaultWaterSurfaceOpacity;

  /// Optional default `minecraft:grass_appearance.color` hex/colormap.
  final Color? defaultGrassColor;

  /// Optional default `minecraft:foliage_appearance.color`.
  final Color? defaultFoliageColor;

  /// Optional `minecraft:precipitation` particle key:
  /// 'none' | 'ash' | 'blue_spores' | 'red_spores' | 'white_ash'.
  final String? defaultPrecipitationType;

  /// Optional precipitation density (0.0..1.0).
  final double? defaultPrecipitationDensity;

  const VanillaBiomeEntry({
    required this.id,
    required this.displayName,
    required this.group,
    this.dimension = BiomeDimension.overworld,
    this.defaultWaterPreset = 'water_tropical',
    this.defaultFogPreset = 'fog_overworld',
    this.defaultAtmospherePreset = 'global_atmosphere',
    this.defaultLightingPreset = 'global',
    this.defaultColorGradingPreset = 'color_grading',
    this.defaultSkyColor = const Color(0xFF4461D4),
    this.defaultWaterSurfaceColor = const Color(0xFF44AFF5),
    this.defaultWaterSurfaceOpacity,
    this.defaultGrassColor,
    this.defaultFoliageColor,
    this.defaultPrecipitationType,
    this.defaultPrecipitationDensity,
  });
}

/// Complete list of all 87 vanilla Minecraft Bedrock client biomes.
const List<VanillaBiomeEntry> kVanillaBiomes = [
  // ── Plains, Forests, Taiga, Mountains, Mushroom, Pale Garden (28) ──────────
  VanillaBiomeEntry(
    id: 'plains',
    displayName: 'Plains',
    group: BiomeGroup.forest,
  ),
  VanillaBiomeEntry(
    id: 'sunflower_plains',
    displayName: 'Sunflower Plains',
    group: BiomeGroup.forest,
  ),
  VanillaBiomeEntry(
    id: 'forest',
    displayName: 'Forest',
    group: BiomeGroup.forest,
    defaultFogPreset: 'fog_forest',
  ),
  VanillaBiomeEntry(
    id: 'forest_hills',
    displayName: 'Wooded Hills',
    group: BiomeGroup.forest,
    defaultFogPreset: 'fog_forest',
  ),
  VanillaBiomeEntry(
    id: 'birch_forest',
    displayName: 'Birch Forest',
    group: BiomeGroup.forest,
    defaultFogPreset: 'fog_forest',
  ),
  VanillaBiomeEntry(
    id: 'birch_forest_hills',
    displayName: 'Birch Forest Hills',
    group: BiomeGroup.forest,
    defaultFogPreset: 'fog_forest',
  ),
  VanillaBiomeEntry(
    id: 'birch_forest_mutated',
    displayName: 'Old Growth Birch Forest',
    group: BiomeGroup.forest,
    defaultFogPreset: 'fog_forest',
  ),
  VanillaBiomeEntry(
    id: 'birch_forest_hills_mutated',
    displayName: 'Tall Birch Hills',
    group: BiomeGroup.forest,
    defaultFogPreset: 'fog_forest',
  ),
  VanillaBiomeEntry(
    id: 'roofed_forest',
    displayName: 'Dark Forest',
    group: BiomeGroup.forest,
    defaultFogPreset: 'fog_forest',
  ),
  VanillaBiomeEntry(
    id: 'roofed_forest_mutated',
    displayName: 'Dark Forest Hills',
    group: BiomeGroup.forest,
    defaultFogPreset: 'fog_forest',
  ),
  VanillaBiomeEntry(
    id: 'flower_forest',
    displayName: 'Flower Forest',
    group: BiomeGroup.forest,
    defaultFogPreset: 'fog_forest',
  ),
  VanillaBiomeEntry(
    id: 'meadow',
    displayName: 'Meadow',
    group: BiomeGroup.forest,
  ),
  VanillaBiomeEntry(
    id: 'taiga',
    displayName: 'Taiga',
    group: BiomeGroup.forest,
    defaultFogPreset: 'fog_taiga',
    defaultSkyColor: Color(0xFF5674D8),
  ),
  VanillaBiomeEntry(
    id: 'taiga_hills',
    displayName: 'Taiga Hills',
    group: BiomeGroup.forest,
    defaultFogPreset: 'fog_taiga',
    defaultSkyColor: Color(0xFF5674D8),
  ),
  VanillaBiomeEntry(
    id: 'taiga_mutated',
    displayName: 'Taiga Mountains',
    group: BiomeGroup.forest,
    defaultFogPreset: 'fog_taiga',
    defaultSkyColor: Color(0xFF5674D8),
  ),
  VanillaBiomeEntry(
    id: 'mega_taiga',
    displayName: 'Old Growth Pine Taiga',
    group: BiomeGroup.forest,
    defaultFogPreset: 'fog_taiga',
  ),
  VanillaBiomeEntry(
    id: 'mega_taiga_hills',
    displayName: 'Giant Tree Taiga Hills',
    group: BiomeGroup.forest,
    defaultFogPreset: 'fog_taiga',
  ),
  VanillaBiomeEntry(
    id: 'redwood_taiga_mutated',
    displayName: 'Old Growth Spruce Taiga',
    group: BiomeGroup.forest,
    defaultFogPreset: 'fog_taiga',
  ),
  VanillaBiomeEntry(
    id: 'redwood_taiga_hills_mutated',
    displayName: 'Giant Spruce Taiga Hills',
    group: BiomeGroup.forest,
    defaultFogPreset: 'fog_taiga',
  ),
  VanillaBiomeEntry(
    id: 'extreme_hills',
    displayName: 'Windswept Hills',
    group: BiomeGroup.forest,
  ),
  VanillaBiomeEntry(
    id: 'extreme_hills_edge',
    displayName: 'Mountain Edge',
    group: BiomeGroup.forest,
  ),
  VanillaBiomeEntry(
    id: 'extreme_hills_mutated',
    displayName: 'Windswept Gravelly Hills',
    group: BiomeGroup.forest,
  ),
  VanillaBiomeEntry(
    id: 'extreme_hills_plus_trees',
    displayName: 'Windswept Forest',
    group: BiomeGroup.forest,
  ),
  VanillaBiomeEntry(
    id: 'extreme_hills_plus_trees_mutated',
    displayName: 'Gravelly Mountains+',
    group: BiomeGroup.forest,
  ),
  VanillaBiomeEntry(
    id: 'stony_peaks',
    displayName: 'Stony Peaks',
    group: BiomeGroup.forest,
  ),
  VanillaBiomeEntry(
    id: 'mushroom_island',
    displayName: 'Mushroom Fields',
    group: BiomeGroup.forest,
    defaultFogPreset: 'fog_mushroom',
  ),
  VanillaBiomeEntry(
    id: 'mushroom_island_shore',
    displayName: 'Mushroom Field Shore',
    group: BiomeGroup.forest,
    defaultFogPreset: 'fog_mushroom',
  ),
  VanillaBiomeEntry(
    id: 'pale_garden',
    displayName: 'Pale Garden',
    group: BiomeGroup.forest,
    defaultFogPreset: 'fog_pale_garden',
    defaultAtmospherePreset: 'pale_atmosphere',
    defaultLightingPreset: 'pale_lighting',
    defaultColorGradingPreset: 'mood_moody',
    defaultSkyColor: Color(0xFF9C9C9C),
    defaultGrassColor: Color(0xFF5C6557),
    defaultFoliageColor: Color(0xFF5C6557),
  ),

  // ── Desert, Mesa & Savanna (13) ────────────────────────────────────────────
  VanillaBiomeEntry(
    id: 'desert',
    displayName: 'Desert',
    group: BiomeGroup.desertBadlands,
    defaultFogPreset: 'fog_desert',
    defaultColorGradingPreset: 'mood_savanna',
  ),
  VanillaBiomeEntry(
    id: 'desert_hills',
    displayName: 'Desert Hills',
    group: BiomeGroup.desertBadlands,
    defaultFogPreset: 'fog_desert',
    defaultColorGradingPreset: 'mood_savanna',
  ),
  VanillaBiomeEntry(
    id: 'desert_mutated',
    displayName: 'Desert Lakes',
    group: BiomeGroup.desertBadlands,
    defaultFogPreset: 'fog_desert',
    defaultColorGradingPreset: 'mood_savanna',
  ),
  VanillaBiomeEntry(
    id: 'mesa',
    displayName: 'Badlands',
    group: BiomeGroup.desertBadlands,
    defaultFogPreset: 'fog_mesa',
    defaultColorGradingPreset: 'mood_savanna',
  ),
  VanillaBiomeEntry(
    id: 'mesa_bryce',
    displayName: 'Eroded Badlands',
    group: BiomeGroup.desertBadlands,
    defaultFogPreset: 'fog_mesa',
    defaultColorGradingPreset: 'mood_savanna',
  ),
  VanillaBiomeEntry(
    id: 'mesa_plateau',
    displayName: 'Badlands Plateau',
    group: BiomeGroup.desertBadlands,
    defaultFogPreset: 'fog_mesa',
    defaultColorGradingPreset: 'mood_savanna',
  ),
  VanillaBiomeEntry(
    id: 'mesa_plateau_mutated',
    displayName: 'Modified Badlands Plateau',
    group: BiomeGroup.desertBadlands,
    defaultFogPreset: 'fog_mesa',
    defaultColorGradingPreset: 'mood_savanna',
  ),
  VanillaBiomeEntry(
    id: 'mesa_plateau_stone',
    displayName: 'Wooded Badlands',
    group: BiomeGroup.desertBadlands,
    defaultFogPreset: 'fog_mesa',
    defaultColorGradingPreset: 'mood_savanna',
  ),
  VanillaBiomeEntry(
    id: 'mesa_plateau_stone_mutated',
    displayName: 'Modified Wooded Badlands',
    group: BiomeGroup.desertBadlands,
    defaultFogPreset: 'fog_mesa',
    defaultColorGradingPreset: 'mood_savanna',
  ),
  VanillaBiomeEntry(
    id: 'savanna',
    displayName: 'Savanna',
    group: BiomeGroup.desertBadlands,
    defaultFogPreset: 'fog_savanna',
    defaultColorGradingPreset: 'mood_savanna',
  ),
  VanillaBiomeEntry(
    id: 'savanna_mutated',
    displayName: 'Windswept Savanna',
    group: BiomeGroup.desertBadlands,
    defaultFogPreset: 'fog_savanna',
    defaultColorGradingPreset: 'mood_savanna',
  ),
  VanillaBiomeEntry(
    id: 'savanna_plateau',
    displayName: 'Savanna Plateau',
    group: BiomeGroup.desertBadlands,
    defaultFogPreset: 'fog_savanna',
    defaultColorGradingPreset: 'mood_savanna',
  ),
  VanillaBiomeEntry(
    id: 'savanna_plateau_mutated',
    displayName: 'Shattered Savanna Plateau',
    group: BiomeGroup.desertBadlands,
    defaultFogPreset: 'fog_savanna',
    defaultColorGradingPreset: 'mood_savanna',
  ),

  // ── Snow & Ice (15) ────────────────────────────────────────────────────────
  VanillaBiomeEntry(
    id: 'cold_taiga',
    displayName: 'Snowy Taiga',
    group: BiomeGroup.snow,
    defaultFogPreset: 'fog_snow',
    defaultColorGradingPreset: 'mood_frost',
    defaultSkyColor: Color(0xFF839CE8),
  ),
  VanillaBiomeEntry(
    id: 'cold_taiga_hills',
    displayName: 'Snowy Taiga Hills',
    group: BiomeGroup.snow,
    defaultFogPreset: 'fog_snow',
    defaultColorGradingPreset: 'mood_frost',
    defaultSkyColor: Color(0xFF839CE8),
  ),
  VanillaBiomeEntry(
    id: 'cold_taiga_mutated',
    displayName: 'Snowy Taiga Mountains',
    group: BiomeGroup.snow,
    defaultFogPreset: 'fog_snow',
    defaultColorGradingPreset: 'mood_frost',
    defaultSkyColor: Color(0xFF839CE8),
  ),
  VanillaBiomeEntry(
    id: 'ice_plains',
    displayName: 'Snowy Plains',
    group: BiomeGroup.snow,
    defaultFogPreset: 'fog_snow',
    defaultColorGradingPreset: 'mood_frost',
    defaultSkyColor: Color(0xFF839CE8),
  ),
  VanillaBiomeEntry(
    id: 'ice_plains_spikes',
    displayName: 'Ice Spikes',
    group: BiomeGroup.snow,
    defaultFogPreset: 'fog_ice',
    defaultColorGradingPreset: 'mood_frost',
    defaultSkyColor: Color(0xFF839CE8),
  ),
  VanillaBiomeEntry(
    id: 'ice_mountains',
    displayName: 'Snowy Mountains',
    group: BiomeGroup.snow,
    defaultFogPreset: 'fog_snow',
    defaultColorGradingPreset: 'mood_frost',
    defaultSkyColor: Color(0xFF839CE8),
  ),
  VanillaBiomeEntry(
    id: 'frozen_river',
    displayName: 'Frozen River',
    group: BiomeGroup.snow,
    defaultWaterPreset: 'water_river',
    defaultFogPreset: 'fog_ice',
    defaultColorGradingPreset: 'mood_frost',
    defaultSkyColor: Color(0xFF839CE8),
    defaultWaterSurfaceColor: Color(0xFF3938C9),
  ),
  VanillaBiomeEntry(
    id: 'frozen_ocean',
    displayName: 'Frozen Ocean',
    group: BiomeGroup.snow,
    defaultWaterPreset: 'water_ocean',
    defaultFogPreset: 'fog_ice',
    defaultColorGradingPreset: 'mood_frost',
    defaultSkyColor: Color(0xFF839CE8),
    defaultWaterSurfaceColor: Color(0xFF3938C9),
  ),
  VanillaBiomeEntry(
    id: 'legacy_frozen_ocean',
    displayName: 'Legacy Frozen Ocean',
    group: BiomeGroup.snow,
    defaultWaterPreset: 'water_ocean',
    defaultFogPreset: 'fog_ice',
    defaultColorGradingPreset: 'mood_frost',
    defaultSkyColor: Color(0xFF839CE8),
    defaultWaterSurfaceColor: Color(0xFF3938C9),
  ),
  VanillaBiomeEntry(
    id: 'deep_frozen_ocean',
    displayName: 'Deep Frozen Ocean',
    group: BiomeGroup.snow,
    defaultWaterPreset: 'water_deep_ocean',
    defaultFogPreset: 'fog_ice',
    defaultColorGradingPreset: 'mood_frost',
    defaultSkyColor: Color(0xFF839CE8),
    defaultWaterSurfaceColor: Color(0xFF282B8A),
  ),
  VanillaBiomeEntry(
    id: 'frozen_peaks',
    displayName: 'Frozen Peaks',
    group: BiomeGroup.snow,
    defaultFogPreset: 'fog_ice',
    defaultColorGradingPreset: 'mood_frost',
    defaultSkyColor: Color(0xFF839CE8),
  ),
  VanillaBiomeEntry(
    id: 'snowy_slopes',
    displayName: 'Snowy Slopes',
    group: BiomeGroup.snow,
    defaultFogPreset: 'fog_snow',
    defaultColorGradingPreset: 'mood_frost',
    defaultSkyColor: Color(0xFF839CE8),
  ),
  VanillaBiomeEntry(
    id: 'jagged_peaks',
    displayName: 'Jagged Peaks',
    group: BiomeGroup.snow,
    defaultFogPreset: 'fog_ice',
    defaultColorGradingPreset: 'mood_frost',
    defaultSkyColor: Color(0xFF839CE8),
  ),
  VanillaBiomeEntry(
    id: 'grove',
    displayName: 'Grove',
    group: BiomeGroup.snow,
    defaultFogPreset: 'fog_snow',
    defaultColorGradingPreset: 'mood_frost',
    defaultSkyColor: Color(0xFF839CE8),
  ),
  VanillaBiomeEntry(
    id: 'cold_beach',
    displayName: 'Snowy Beach',
    group: BiomeGroup.snow,
    defaultFogPreset: 'fog_snow',
    defaultColorGradingPreset: 'mood_frost',
    defaultSkyColor: Color(0xFF839CE8),
  ),

  // ── Oceans, Rivers & Beaches (11) ──────────────────────────────────────────
  VanillaBiomeEntry(
    id: 'ocean',
    displayName: 'Ocean',
    group: BiomeGroup.ocean,
    defaultWaterPreset: 'water_ocean',
    defaultWaterSurfaceColor: Color(0xFF1787D4),
  ),
  VanillaBiomeEntry(
    id: 'warm_ocean',
    displayName: 'Warm Ocean',
    group: BiomeGroup.ocean,
    defaultWaterPreset: 'water_tropical',
    defaultWaterSurfaceColor: Color(0xFF43D5EE),
  ),
  VanillaBiomeEntry(
    id: 'lukewarm_ocean',
    displayName: 'Lukewarm Ocean',
    group: BiomeGroup.ocean,
    defaultWaterPreset: 'water_tropical',
    defaultWaterSurfaceColor: Color(0xFF45ADF2),
  ),
  VanillaBiomeEntry(
    id: 'cold_ocean',
    displayName: 'Cold Ocean',
    group: BiomeGroup.ocean,
    defaultWaterPreset: 'water_ocean',
    defaultWaterSurfaceColor: Color(0xFF3D57D6),
  ),
  VanillaBiomeEntry(
    id: 'deep_ocean',
    displayName: 'Deep Ocean',
    group: BiomeGroup.ocean,
    defaultWaterPreset: 'water_deep_ocean',
    defaultWaterSurfaceColor: Color(0xFF174F9C),
  ),
  VanillaBiomeEntry(
    id: 'deep_warm_ocean',
    displayName: 'Deep Warm Ocean',
    group: BiomeGroup.ocean,
    defaultWaterPreset: 'water_deep_ocean',
    defaultWaterSurfaceColor: Color(0xFF2889C8),
  ),
  VanillaBiomeEntry(
    id: 'deep_lukewarm_ocean',
    displayName: 'Deep Lukewarm Ocean',
    group: BiomeGroup.ocean,
    defaultWaterPreset: 'water_deep_ocean',
    defaultWaterSurfaceColor: Color(0xFF2B6EC2),
  ),
  VanillaBiomeEntry(
    id: 'deep_cold_ocean',
    displayName: 'Deep Cold Ocean',
    group: BiomeGroup.ocean,
    defaultWaterPreset: 'water_deep_ocean',
    defaultWaterSurfaceColor: Color(0xFF223C9A),
  ),
  VanillaBiomeEntry(
    id: 'river',
    displayName: 'River',
    group: BiomeGroup.ocean,
    defaultWaterPreset: 'water_river',
    defaultWaterSurfaceColor: Color(0xFF0084FF),
  ),
  VanillaBiomeEntry(
    id: 'beach',
    displayName: 'Beach',
    group: BiomeGroup.ocean,
    defaultWaterPreset: 'water_tropical',
    defaultWaterSurfaceColor: Color(0xFF44AFF5),
  ),
  VanillaBiomeEntry(
    id: 'stone_beach',
    displayName: 'Stony Shore',
    group: BiomeGroup.ocean,
    defaultWaterPreset: 'water_ocean',
    defaultWaterSurfaceColor: Color(0xFF1787D4),
  ),

  // ── Swamps & Mangroves (3) ─────────────────────────────────────────────────
  VanillaBiomeEntry(
    id: 'swampland',
    displayName: 'Swamp',
    group: BiomeGroup.swamp,
    defaultWaterPreset: 'water_swamp',
    defaultFogPreset: 'fog_swamp',
    defaultWaterSurfaceColor: Color(0xFF4C6559),
    defaultGrassColor: Color(0xFF6A7039),
    defaultFoliageColor: Color(0xFF6A7039),
  ),
  VanillaBiomeEntry(
    id: 'swampland_mutated',
    displayName: 'Swamp Hills',
    group: BiomeGroup.swamp,
    defaultWaterPreset: 'water_swamp',
    defaultFogPreset: 'fog_swamp',
    defaultWaterSurfaceColor: Color(0xFF4C6559),
    defaultGrassColor: Color(0xFF6A7039),
    defaultFoliageColor: Color(0xFF6A7039),
  ),
  VanillaBiomeEntry(
    id: 'mangrove_swamp',
    displayName: 'Mangrove Swamp',
    group: BiomeGroup.swamp,
    defaultWaterPreset: 'water_swamp',
    defaultFogPreset: 'fog_swamp',
    defaultSkyColor: Color(0xFF5A6F83),
    defaultWaterSurfaceColor: Color(0xFF3A7A6A),
    defaultGrassColor: Color(0xFF4C763C),
    defaultFoliageColor: Color(0xFF8DB127),
  ),

  // ── Jungles (7) ────────────────────────────────────────────────────────────
  VanillaBiomeEntry(
    id: 'jungle',
    displayName: 'Jungle',
    group: BiomeGroup.jungle,
    defaultWaterPreset: 'water_tropical',
    defaultFogPreset: 'fog_jungle',
    defaultColorGradingPreset: 'mood_vibrant',
  ),
  VanillaBiomeEntry(
    id: 'jungle_hills',
    displayName: 'Jungle Hills',
    group: BiomeGroup.jungle,
    defaultWaterPreset: 'water_tropical',
    defaultFogPreset: 'fog_jungle',
    defaultColorGradingPreset: 'mood_vibrant',
  ),
  VanillaBiomeEntry(
    id: 'jungle_mutated',
    displayName: 'Modified Jungle',
    group: BiomeGroup.jungle,
    defaultWaterPreset: 'water_tropical',
    defaultFogPreset: 'fog_jungle',
    defaultColorGradingPreset: 'mood_vibrant',
  ),
  VanillaBiomeEntry(
    id: 'jungle_edge',
    displayName: 'Sparse Jungle',
    group: BiomeGroup.jungle,
    defaultWaterPreset: 'water_tropical',
    defaultFogPreset: 'fog_jungle',
    defaultColorGradingPreset: 'mood_vibrant',
  ),
  VanillaBiomeEntry(
    id: 'jungle_edge_mutated',
    displayName: 'Modified Jungle Edge',
    group: BiomeGroup.jungle,
    defaultWaterPreset: 'water_tropical',
    defaultFogPreset: 'fog_jungle',
    defaultColorGradingPreset: 'mood_vibrant',
  ),
  VanillaBiomeEntry(
    id: 'bamboo_jungle',
    displayName: 'Bamboo Jungle',
    group: BiomeGroup.jungle,
    defaultWaterPreset: 'water_tropical',
    defaultFogPreset: 'fog_jungle',
    defaultColorGradingPreset: 'mood_vibrant',
  ),
  VanillaBiomeEntry(
    id: 'bamboo_jungle_hills',
    displayName: 'Bamboo Jungle Hills',
    group: BiomeGroup.jungle,
    defaultWaterPreset: 'water_tropical',
    defaultFogPreset: 'fog_jungle',
    defaultColorGradingPreset: 'mood_vibrant',
  ),

  // ── Cherry Grove (1) ───────────────────────────────────────────────────────
  VanillaBiomeEntry(
    id: 'cherry_grove',
    displayName: 'Cherry Grove',
    group: BiomeGroup.cherry,
    defaultFogPreset: 'fog_cherry',
    defaultColorGradingPreset: 'mood_vibrant',
    defaultSkyColor: Color(0xFF79A6FF),
  ),

  // ── Caves & Deep Dark (3) ──────────────────────────────────────────────────
  VanillaBiomeEntry(
    id: 'dripstone_caves',
    displayName: 'Dripstone Caves',
    group: BiomeGroup.cavesDeepDark,
    defaultWaterPreset: 'water_river',
  ),
  VanillaBiomeEntry(
    id: 'lush_caves',
    displayName: 'Lush Caves',
    group: BiomeGroup.cavesDeepDark,
    defaultWaterPreset: 'water_tropical',
    defaultColorGradingPreset: 'mood_vibrant',
  ),
  VanillaBiomeEntry(
    id: 'deep_dark',
    displayName: 'Deep Dark',
    group: BiomeGroup.cavesDeepDark,
    defaultWaterPreset: 'water_deep_ocean',
    defaultFogPreset: 'fog_deep_dark',
    defaultColorGradingPreset: 'mood_moody',
    defaultSkyColor: Color(0xFF101830),
  ),

  // ── The Nether (5) ─────────────────────────────────────────────────────────
  VanillaBiomeEntry(
    id: 'hell',
    displayName: 'Nether Wastes',
    group: BiomeGroup.nether,
    dimension: BiomeDimension.nether,
    defaultWaterPreset: 'water_swamp',
    defaultFogPreset: 'fog_hell',
    defaultAtmospherePreset: 'hell_atmosphere',
    defaultLightingPreset: 'hell_lighting',
    defaultColorGradingPreset: 'color_grading',
    defaultSkyColor: Color(0xFFD76B30),
    defaultWaterSurfaceColor: Color(0xFF905957),
  ),
  VanillaBiomeEntry(
    id: 'crimson_forest',
    displayName: 'Crimson Forest',
    group: BiomeGroup.nether,
    dimension: BiomeDimension.nether,
    defaultWaterPreset: 'water_swamp',
    defaultFogPreset: 'fog_crimson_forest',
    defaultAtmospherePreset: 'crimson_atmosphere',
    defaultLightingPreset: 'crimson_lighting',
    defaultColorGradingPreset: 'color_grading',
    defaultSkyColor: Color(0xFF991D1D),
    defaultWaterSurfaceColor: Color(0xFF905957),
    defaultPrecipitationType: 'red_spores',
    defaultPrecipitationDensity: 0.35,
  ),
  VanillaBiomeEntry(
    id: 'warped_forest',
    displayName: 'Warped Forest',
    group: BiomeGroup.nether,
    dimension: BiomeDimension.nether,
    defaultWaterPreset: 'water_swamp',
    defaultFogPreset: 'fog_warped_forest',
    defaultAtmospherePreset: 'warped_atmosphere',
    defaultLightingPreset: 'warped_lighting',
    defaultColorGradingPreset: 'color_grading',
    defaultSkyColor: Color(0xFF1B7878),
    defaultWaterSurfaceColor: Color(0xFF905957),
    defaultPrecipitationType: 'blue_spores',
    defaultPrecipitationDensity: 0.35,
  ),
  VanillaBiomeEntry(
    id: 'soulsand_valley',
    displayName: 'Soul Sand Valley',
    group: BiomeGroup.nether,
    dimension: BiomeDimension.nether,
    defaultWaterPreset: 'water_swamp',
    defaultFogPreset: 'fog_soulsand_valley',
    defaultAtmospherePreset: 'soul_atmosphere',
    defaultLightingPreset: 'soul_lighting',
    defaultColorGradingPreset: 'color_grading',
    defaultSkyColor: Color(0xFF27B9A3),
    defaultWaterSurfaceColor: Color(0xFF905957),
    defaultPrecipitationType: 'ash',
    defaultPrecipitationDensity: 0.4,
  ),
  VanillaBiomeEntry(
    id: 'basalt_deltas',
    displayName: 'Basalt Deltas',
    group: BiomeGroup.nether,
    dimension: BiomeDimension.nether,
    defaultWaterPreset: 'water_swamp',
    defaultFogPreset: 'fog_basalt_deltas',
    defaultAtmospherePreset: 'deltas_atmosphere',
    defaultLightingPreset: 'deltas_lighting',
    defaultColorGradingPreset: 'color_grading',
    defaultSkyColor: Color(0xFF685F70),
    defaultWaterSurfaceColor: Color(0xFF3F76E4),
    defaultPrecipitationType: 'white_ash',
    defaultPrecipitationDensity: 0.45,
  ),

  // ── The End (1) ────────────────────────────────────────────────────────────
  VanillaBiomeEntry(
    id: 'the_end',
    displayName: 'The End',
    group: BiomeGroup.end,
    dimension: BiomeDimension.end,
    defaultWaterPreset: 'water_deep_ocean',
    defaultFogPreset: 'fog_end',
    defaultAtmospherePreset: 'end_atmosphere',
    defaultLightingPreset: 'end_lighting',
    defaultColorGradingPreset: 'color_grading',
    defaultSkyColor: Color(0xFF7218BB),
    defaultWaterSurfaceColor: Color(0xFF62529E),
  ),

  // ── 1.26+ Biomes (2) ────────────────────────────────────────────────────────
  VanillaBiomeEntry(
    id: 'sulfur_caves',
    displayName: 'Sulfur Caves',
    group: BiomeGroup.cavesDeepDark,
    dimension: BiomeDimension.overworld,
    defaultWaterPreset: 'water_tropical',
    defaultFogPreset: 'fog_overworld',
    defaultAtmospherePreset: 'global_atmosphere',
    defaultLightingPreset: 'global',
    defaultColorGradingPreset: 'color_grading',
    defaultWaterSurfaceColor: Color(0xFF34BF89),
    defaultGrassColor: Color(0xFFABA64F),
  ),
  VanillaBiomeEntry(
    id: 'dappled_forest',
    displayName: 'Dappled Forest',
    group: BiomeGroup.forest,
    dimension: BiomeDimension.overworld,
    defaultWaterPreset: 'water_tropical',
    defaultFogPreset: 'fog_overworld',
    defaultAtmospherePreset: 'global_atmosphere',
    defaultLightingPreset: 'global',
    defaultColorGradingPreset: 'color_grading',
    defaultSkyColor: Color(0xFF7CA3FF),
    defaultWaterSurfaceColor: Color(0xFF375154),
    defaultGrassColor: Color(0xFFDF6827),
    defaultFoliageColor: Color(0xFFE68E30),
  ),
];

/// Fast lookup map by biome id.
final Map<String, VanillaBiomeEntry> kVanillaBiomeById = {
  for (final b in kVanillaBiomes) b.id: b,
};

/// One layer of appearance overrides for client biomes.
/// Any non-null field overrides lower-priority layers in the 3-layer stack:
/// Global -> Group -> Single Biome.
class BiomeAppearanceOverride {
  final String? atmospherePreset;
  final String? colorGradingPreset;
  final String? lightingPreset;
  final String? waterPreset;
  final String? fogPreset;
  final Color? skyColor;
  final Color? waterSurfaceColor;

  /// `0.0..1.0` → `minecraft:water_appearance.surface_opacity`
  final double? waterSurfaceOpacity;
  final Color? grassColor;
  final Color? foliageColor;

  /// `'none' | 'ash' | 'blue_spores' | 'red_spores' | 'white_ash'`
  final String? precipitationType;

  /// `0.0..1.0`
  final double? precipitationDensity;

  const BiomeAppearanceOverride({
    this.atmospherePreset,
    this.colorGradingPreset,
    this.lightingPreset,
    this.waterPreset,
    this.fogPreset,
    this.skyColor,
    this.waterSurfaceColor,
    this.waterSurfaceOpacity,
    this.grassColor,
    this.foliageColor,
    this.precipitationType,
    this.precipitationDensity,
  });

  bool get isEmpty =>
      atmospherePreset == null &&
      colorGradingPreset == null &&
      lightingPreset == null &&
      waterPreset == null &&
      fogPreset == null &&
      skyColor == null &&
      waterSurfaceColor == null &&
      waterSurfaceOpacity == null &&
      grassColor == null &&
      foliageColor == null &&
      precipitationType == null &&
      precipitationDensity == null;

  /// Returns a new [BiomeAppearanceOverride] where non-null fields in [upper]
  /// replace fields in `this`.
  BiomeAppearanceOverride merge(BiomeAppearanceOverride? upper) {
    if (upper == null || upper.isEmpty) return this;
    return BiomeAppearanceOverride(
      atmospherePreset: upper.atmospherePreset ?? atmospherePreset,
      colorGradingPreset: upper.colorGradingPreset ?? colorGradingPreset,
      lightingPreset: upper.lightingPreset ?? lightingPreset,
      waterPreset: upper.waterPreset ?? waterPreset,
      fogPreset: upper.fogPreset ?? fogPreset,
      skyColor: upper.skyColor ?? skyColor,
      waterSurfaceColor: upper.waterSurfaceColor ?? waterSurfaceColor,
      waterSurfaceOpacity: upper.waterSurfaceOpacity ?? waterSurfaceOpacity,
      grassColor: upper.grassColor ?? grassColor,
      foliageColor: upper.foliageColor ?? foliageColor,
      precipitationType: upper.precipitationType ?? precipitationType,
      precipitationDensity: upper.precipitationDensity ?? precipitationDensity,
    );
  }

  BiomeAppearanceOverride copyWith({
    String? atmospherePreset,
    String? colorGradingPreset,
    String? lightingPreset,
    String? waterPreset,
    String? fogPreset,
    Color? skyColor,
    Color? waterSurfaceColor,
    double? waterSurfaceOpacity,
    Color? grassColor,
    Color? foliageColor,
    String? precipitationType,
    double? precipitationDensity,
  }) {
    return BiomeAppearanceOverride(
      atmospherePreset: atmospherePreset ?? this.atmospherePreset,
      colorGradingPreset: colorGradingPreset ?? this.colorGradingPreset,
      lightingPreset: lightingPreset ?? this.lightingPreset,
      waterPreset: waterPreset ?? this.waterPreset,
      fogPreset: fogPreset ?? this.fogPreset,
      skyColor: skyColor ?? this.skyColor,
      waterSurfaceColor: waterSurfaceColor ?? this.waterSurfaceColor,
      waterSurfaceOpacity: waterSurfaceOpacity ?? this.waterSurfaceOpacity,
      grassColor: grassColor ?? this.grassColor,
      foliageColor: foliageColor ?? this.foliageColor,
      precipitationType: precipitationType ?? this.precipitationType,
      precipitationDensity: precipitationDensity ?? this.precipitationDensity,
    );
  }
}

/// 3-layer override container (Global -> BiomeGroup -> Single Biome).
class BiomeOverridesConfig {
  /// Layer 1: Applied to Overworld biomes (unless overridden by Group or Single).
  final BiomeAppearanceOverride global;

  /// Layer 2: Overrides per [BiomeGroup].
  final Map<BiomeGroup, BiomeAppearanceOverride> groupOverrides;

  /// Layer 3: Overrides per individual biome ID (e.g. `'cherry_grove'`).
  final Map<String, BiomeAppearanceOverride> biomeOverrides;

  const BiomeOverridesConfig({
    this.global = const BiomeAppearanceOverride(),
    this.groupOverrides = const {},
    this.biomeOverrides = const {},
  });

  /// Resolves the effective override for [biome].
  /// Nether and End biomes skip the Overworld [global] layer so their distinct
  /// dimension defaults are preserved unless explicitly overridden at group/biome level.
  BiomeAppearanceOverride resolveFor(VanillaBiomeEntry biome) {
    var effective = biome.dimension == BiomeDimension.overworld
        ? global
        : const BiomeAppearanceOverride();
    effective = effective.merge(groupOverrides[biome.group]);
    effective = effective.merge(biomeOverrides[biome.id]);
    return effective;
  }

  BiomeOverridesConfig copyWith({
    BiomeAppearanceOverride? global,
    Map<BiomeGroup, BiomeAppearanceOverride>? groupOverrides,
    Map<String, BiomeAppearanceOverride>? biomeOverrides,
  }) {
    return BiomeOverridesConfig(
      global: global ?? this.global,
      groupOverrides: groupOverrides ?? this.groupOverrides,
      biomeOverrides: biomeOverrides ?? this.biomeOverrides,
    );
  }
}
