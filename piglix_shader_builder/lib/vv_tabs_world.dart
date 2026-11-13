// vv_tabs_world.dart
// Tabs 6–9 of the Piglix Vibrant Visuals Shader Builder:
// 6. VVBiomesTab       (Tab 5 — 3-layer Global -> Group -> Single Biome overrides)
// 7. VVSurfaceTab      (Tab 6 — Global PBR fallback pbr/global.json)
// 8. VVPerformanceTab  (Tab 7 — Performance score meter, 4 tier profiles, subpacks)
// 9. VVExportTab       (Tab 8 — Pack identity, validation report, in-game guide, .mcpack export)

import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'performance_tiers.dart';
import 'vv_biomes.dart';
import 'vv_config.dart';
import 'vv_editor_widgets.dart';
import 'vv_generator.dart';
import 'vv_tab_previews.dart';
import 'vv_guide_modal.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Shared Preset Tables (matching vv_generator.dart & vv_biomes.dart)
// ─────────────────────────────────────────────────────────────────────────────

const List<({String id, String label})> _kWaterPresetOptions = [
  (id: 'water_tropical', label: 'Tropical'),
  (id: 'water_ocean', label: 'Ocean'),
  (id: 'water_deep_ocean', label: 'Deep Ocean'),
  (id: 'water_river', label: 'River'),
  (id: 'water_swamp', label: 'Swamp'),
];

const List<({String id, String label})> _kPrecipitationOptions = [
  (id: 'none', label: 'None'),
  (id: 'ash', label: 'Ash'),
  (id: 'blue_spores', label: 'Blue Spores'),
  (id: 'red_spores', label: 'Red Spores'),
  (id: 'white_ash', label: 'White Ash'),
];

const List<({String id, String label})> _kFogPresetOptions = [
  (id: 'fog_overworld', label: 'Overworld'),
  (id: 'fog_forest', label: 'Forest'),
  (id: 'fog_taiga', label: 'Taiga'),
  (id: 'fog_mushroom', label: 'Mushroom'),
  (id: 'fog_pale_garden', label: 'Pale Garden'),
  (id: 'fog_desert', label: 'Desert'),
  (id: 'fog_mesa', label: 'Badlands'),
  (id: 'fog_savanna', label: 'Savanna'),
  (id: 'fog_snow', label: 'Snow'),
  (id: 'fog_ice', label: 'Ice'),
  (id: 'fog_swamp', label: 'Swamp'),
  (id: 'fog_jungle', label: 'Jungle'),
  (id: 'fog_cherry', label: 'Cherry Grove'),
  (id: 'fog_deep_dark', label: 'Deep Dark'),
  (id: 'fog_hell', label: 'Nether Wastes'),
  (id: 'fog_crimson_forest', label: 'Crimson Forest'),
  (id: 'fog_warped_forest', label: 'Warped Forest'),
  (id: 'fog_soulsand_valley', label: 'Soul Sand Valley'),
  (id: 'fog_basalt_deltas', label: 'Basalt Deltas'),
  (id: 'fog_end', label: 'The End'),
];

const List<({String id, String label})> _kColorGradingOptions = [
  (id: 'color_grading', label: 'Base (color_grading)'),
  (id: 'mood_dynamic', label: 'Dynamic'),
  (id: 'mood_vibrant', label: 'Vibrant'),
  (id: 'mood_savanna', label: 'Savanna'),
  (id: 'mood_frost', label: 'Frost'),
  (id: 'mood_moody', label: 'Moody'),
];

const List<({String id, String label})> _kAtmosphereOptions = [
  (id: 'global_atmosphere', label: 'Overworld (global)'),
  (id: 'pale_atmosphere', label: 'Pale Garden'),
  (id: 'hell_atmosphere', label: 'Nether Wastes'),
  (id: 'crimson_atmosphere', label: 'Crimson Forest'),
  (id: 'warped_atmosphere', label: 'Warped Forest'),
  (id: 'soul_atmosphere', label: 'Soul Sand Valley'),
  (id: 'deltas_atmosphere', label: 'Basalt Deltas'),
  (id: 'end_atmosphere', label: 'The End'),
];

const List<({String id, String label})> _kLightingOptions = [
  (id: 'global', label: 'Overworld (global)'),
  (id: 'pale_lighting', label: 'Pale Garden'),
  (id: 'hell_lighting', label: 'Nether Wastes'),
  (id: 'crimson_lighting', label: 'Crimson Forest'),
  (id: 'warped_lighting', label: 'Warped Forest'),
  (id: 'soul_lighting', label: 'Soul Sand Valley'),
  (id: 'deltas_lighting', label: 'Basalt Deltas'),
  (id: 'end_lighting', label: 'The End'),
];

enum _BiomeField {
  waterPreset,
  skyColor,
  waterSurfaceColor,
  waterSurfaceOpacity,
  grassColor,
  foliageColor,
  precipitationType,
  precipitationDensity,
  fogPreset,
  colorGradingPreset,
  atmospherePreset,
  lightingPreset,
}

BiomeAppearanceOverride _clearBiomeField(
  BiomeAppearanceOverride o,
  _BiomeField field,
) {
  return BiomeAppearanceOverride(
    atmospherePreset:
        field == _BiomeField.atmospherePreset ? null : o.atmospherePreset,
    colorGradingPreset:
        field == _BiomeField.colorGradingPreset ? null : o.colorGradingPreset,
    lightingPreset:
        field == _BiomeField.lightingPreset ? null : o.lightingPreset,
    waterPreset: field == _BiomeField.waterPreset ? null : o.waterPreset,
    fogPreset: field == _BiomeField.fogPreset ? null : o.fogPreset,
    skyColor: field == _BiomeField.skyColor ? null : o.skyColor,
    waterSurfaceColor:
        field == _BiomeField.waterSurfaceColor ? null : o.waterSurfaceColor,
    waterSurfaceOpacity:
        field == _BiomeField.waterSurfaceOpacity ? null : o.waterSurfaceOpacity,
    grassColor: field == _BiomeField.grassColor ? null : o.grassColor,
    foliageColor: field == _BiomeField.foliageColor ? null : o.foliageColor,
    precipitationType:
        field == _BiomeField.precipitationType ? null : o.precipitationType,
    precipitationDensity: field == _BiomeField.precipitationDensity
        ? null
        : o.precipitationDensity,
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// TAB 6: VVBiomesTab (Tab index 5)
// ─────────────────────────────────────────────────────────────────────────────

class VVBiomesTab extends StatefulWidget {
  final VVShaderConfig config;
  final ValueChanged<VVShaderConfig> onConfigChanged;

  const VVBiomesTab({
    super.key,
    required this.config,
    required this.onConfigChanged,
  });

  @override
  State<VVBiomesTab> createState() => _VVBiomesTabState();
}

class _VVBiomesTabState extends State<VVBiomesTab> {
  static Color get _accent => kVVPrimary;

  /// 0 = Global (Overworld), 1 = Biome Group, 2 = Single Biome
  int _layer = 0;
  BiomeGroup _selectedGroup = BiomeGroup.forest;
  String _selectedBiomeId = kVanillaBiomes.first.id;
  String _searchQuery = '';
  late final TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  VanillaBiomeEntry get _selectedBiome =>
      kVanillaBiomeById[_selectedBiomeId] ?? kVanillaBiomes.first;

  BiomeAppearanceOverride get _activeOverride {
    final bo = widget.config.biomeOverrides;
    switch (_layer) {
      case 0:
        return bo.global;
      case 1:
        return bo.groupOverrides[_selectedGroup] ??
            const BiomeAppearanceOverride();
      case 2:
      default:
        return bo.biomeOverrides[_selectedBiome.id] ??
            const BiomeAppearanceOverride();
    }
  }

  /// Resolves the inherited baseline behind the currently active layer so
  /// unset controls still display realistic values.
  BiomeAppearanceOverride _inheritedBaseline() {
    final bo = widget.config.biomeOverrides;
    final defaultOverworldCg = widget.config.activeMood == 'dynamic'
        ? 'color_grading'
        : 'mood_${widget.config.activeMood}';

    VanillaBiomeEntry refBiome;
    BiomeAppearanceOverride inherited = const BiomeAppearanceOverride();

    if (_layer == 0) {
      refBiome = kVanillaBiomes.first; // Plains (Overworld reference)
    } else if (_layer == 1) {
      refBiome = kVanillaBiomes.firstWhere(
        (b) => b.group == _selectedGroup,
        orElse: () => kVanillaBiomes.first,
      );
      if (refBiome.dimension == BiomeDimension.overworld) {
        inherited = bo.global;
      }
    } else {
      refBiome = _selectedBiome;
      if (refBiome.dimension == BiomeDimension.overworld) {
        inherited = bo.global.merge(bo.groupOverrides[refBiome.group]);
      } else {
        inherited = bo.groupOverrides[refBiome.group] ??
            const BiomeAppearanceOverride();
      }
    }

    final baseCg = (refBiome.dimension == BiomeDimension.overworld &&
            refBiome.defaultColorGradingPreset == 'color_grading')
        ? defaultOverworldCg
        : refBiome.defaultColorGradingPreset;

    return BiomeAppearanceOverride(
      atmospherePreset:
          inherited.atmospherePreset ?? refBiome.defaultAtmospherePreset,
      colorGradingPreset: inherited.colorGradingPreset ?? baseCg,
      lightingPreset:
          inherited.lightingPreset ?? refBiome.defaultLightingPreset,
      waterPreset: inherited.waterPreset ?? refBiome.defaultWaterPreset,
      fogPreset: inherited.fogPreset ?? refBiome.defaultFogPreset,
      skyColor: inherited.skyColor ?? refBiome.defaultSkyColor,
      waterSurfaceColor:
          inherited.waterSurfaceColor ?? refBiome.defaultWaterSurfaceColor,
      waterSurfaceOpacity:
          inherited.waterSurfaceOpacity ?? refBiome.defaultWaterSurfaceOpacity,
      grassColor: inherited.grassColor ?? refBiome.defaultGrassColor,
      foliageColor: inherited.foliageColor ?? refBiome.defaultFoliageColor,
      precipitationType:
          inherited.precipitationType ?? refBiome.defaultPrecipitationType,
      precipitationDensity: inherited.precipitationDensity ??
          refBiome.defaultPrecipitationDensity,
    );
  }

  void _applyLayerOverride(BiomeAppearanceOverride next) {
    final bo = widget.config.biomeOverrides;
    BiomeOverridesConfig updated;
    switch (_layer) {
      case 0:
        updated = bo.copyWith(global: next);
        break;
      case 1:
        final nextGroups =
            Map<BiomeGroup, BiomeAppearanceOverride>.from(bo.groupOverrides);
        if (next.isEmpty) {
          nextGroups.remove(_selectedGroup);
        } else {
          nextGroups[_selectedGroup] = next;
        }
        updated = bo.copyWith(groupOverrides: nextGroups);
        break;
      case 2:
      default:
        final nextBiomes =
            Map<String, BiomeAppearanceOverride>.from(bo.biomeOverrides);
        if (next.isEmpty) {
          nextBiomes.remove(_selectedBiome.id);
        } else {
          nextBiomes[_selectedBiome.id] = next;
        }
        updated = bo.copyWith(biomeOverrides: nextBiomes);
        break;
    }
    widget.onConfigChanged(widget.config.copyWith(biomeOverrides: updated));
  }

  void _resetActiveLayer() {
    _applyLayerOverride(const BiomeAppearanceOverride());
  }

  Future<void> _openCopyFromDialog() async {
    final picked = await showDialog<BiomeAppearanceOverride>(
      context: context,
      builder: (ctx) => _CopyFromBiomeDialog(
        config: widget.config,
        accent: _accent,
      ),
    );
    if (picked != null && mounted) {
      _applyLayerOverride(picked);
    }
  }

  Widget _dimensionBadge(BiomeDimension dim) {
    final Color color;
    final String text;
    switch (dim) {
      case BiomeDimension.overworld:
        color = const Color(0xFF4ADE80);
        text = 'Overworld';
        break;
      case BiomeDimension.nether:
        color = const Color(0xFFFB7185);
        text = 'Nether';
        break;
      case BiomeDimension.end:
        color = const Color(0xFFC084FC);
        text = 'End';
        break;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(5),
        border: Border.all(color: color.withValues(alpha: 0.45)),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildGroupSelector() {
    final groups = widget.config.biomeOverrides.groupOverrides;
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: BiomeGroup.values.map((group) {
        final bool isSelected = group == _selectedGroup;
        final bool isEdited = !(groups[group]?.isEmpty ?? true);
        return InkWell(
          borderRadius: BorderRadius.circular(9),
          onTap: () => setState(() => _selectedGroup = group),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 140),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(
              color: isSelected ? _accent.withValues(alpha: 0.18) : kVVSurface,
              borderRadius: BorderRadius.circular(9),
              border: Border.all(
                color: isSelected ? _accent : kVVBorder,
                width: isSelected ? 1.4 : 1.0,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (isEdited) ...[
                  Container(
                    width: 7,
                    height: 7,
                    decoration: BoxDecoration(
                      color: _accent,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 6),
                ],
                Text(
                  group.displayName,
                  style: TextStyle(
                    color: isSelected ? _accent : Colors.white70,
                    fontSize: 12,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildSingleBiomeSelector() {
    final q = _searchQuery.trim().toLowerCase();
    final filtered = q.isEmpty
        ? kVanillaBiomes
        : kVanillaBiomes
            .where(
              (b) =>
                  b.displayName.toLowerCase().contains(q) ||
                  b.id.toLowerCase().contains(q),
            )
            .toList();
    final overrides = widget.config.biomeOverrides.biomeOverrides;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: _searchController,
          style: const TextStyle(color: Colors.white, fontSize: 13),
          decoration: InputDecoration(
            hintText: 'Search all 87 biomes by name or id (e.g. cherry_grove)...',
            hintStyle: const TextStyle(color: Colors.white38, fontSize: 12),
            prefixIcon: const Icon(Icons.search_rounded, color: Colors.white54, size: 18),
            suffixIcon: _searchQuery.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.close_rounded, color: Colors.white54, size: 17),
                    onPressed: () {
                      _searchController.clear();
                      setState(() => _searchQuery = '');
                    },
                  )
                : null,
            isDense: true,
            filled: true,
            fillColor: kVVSurface,
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: kVVBorder),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: _accent),
            ),
          ),
          onChanged: (v) => setState(() => _searchQuery = v),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Text(
              'Showing ${filtered.length} of ${kVanillaBiomes.length} biomes',
              style: const TextStyle(color: Colors.white54, fontSize: 11),
            ),
            const Spacer(),
            const Text(
              'Active: ',
              style: TextStyle(color: Colors.white54, fontSize: 11),
            ),
            Text(
              _selectedBiome.displayName,
              style: TextStyle(
                color: _accent,
                fontSize: 11.5,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(width: 6),
            _dimensionBadge(_selectedBiome.dimension),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          constraints: const BoxConstraints(maxHeight: 220),
          decoration: BoxDecoration(
            color: kVVSurface,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: kVVBorder),
          ),
          child: filtered.isEmpty
              ? const Padding(
                  padding: EdgeInsets.all(16),
                  child: Center(
                    child: Text(
                      'No biomes match your search.',
                      style: TextStyle(color: Colors.white54, fontSize: 12),
                    ),
                  ),
                )
              : ListView.separated(
                  shrinkWrap: true,
                  itemCount: filtered.length,
                  separatorBuilder: (_, _) =>
                      const Divider(height: 1, color: kVVBorder),
                  itemBuilder: (ctx, idx) {
                    final biome = filtered[idx];
                    final bool isSelected = biome.id == _selectedBiome.id;
                    final bool isEdited =
                        !(overrides[biome.id]?.isEmpty ?? true);
                    return InkWell(
                      onTap: () => setState(() => _selectedBiomeId = biome.id),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 11,
                          vertical: 8,
                        ),
                        color: isSelected
                            ? _accent.withValues(alpha: 0.14)
                            : Colors.transparent,
                        child: Row(
                          children: [
                            Container(
                              width: 7,
                              height: 7,
                              decoration: BoxDecoration(
                                color: isEdited ? _accent : Colors.white12,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 9),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    biome.displayName,
                                    style: TextStyle(
                                      color: isSelected
                                          ? _accent
                                          : Colors.white,
                                      fontSize: 12.5,
                                      fontWeight: isSelected
                                          ? FontWeight.w600
                                          : FontWeight.w600,
                                    ),
                                  ),
                                  Text(
                                    biome.id,
                                    style: const TextStyle(
                                      color: Colors.white38,
                                      fontFamily: 'monospace',
                                      fontSize: 10.5,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            _dimensionBadge(biome.dimension),
                          ],
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildActiveLayerBanner(BiomeAppearanceOverride ov) {
    final String targetTitle;
    final String targetNote;
    if (_layer == 0) {
      targetTitle = 'Global (Overworld Default)';
      targetNote =
          'Applies to all Overworld biomes unless overridden by Group or Single Biome. Nether & End preserve their dimension defaults.';
    } else if (_layer == 1) {
      targetTitle = 'Group · ${_selectedGroup.displayName}';
      targetNote = (_selectedGroup == BiomeGroup.nether ||
              _selectedGroup == BiomeGroup.end)
          ? 'Dimension group — inherits dimension defaults unless overridden here.'
          : 'Inherits from Global (Overworld) for any unset property.';
    } else {
      final b = _selectedBiome;
      targetTitle = '${b.displayName} (${b.id})';
      targetNote = b.dimension == BiomeDimension.overworld
          ? 'Inherits Global -> ${b.group.displayName} -> biome defaults.'
          : 'Inherits ${b.group.displayName} -> ${b.dimension.name} dimension defaults.';
    }

    return Container(
      padding: const EdgeInsets.all(11),
      decoration: BoxDecoration(
        color: kVVSurface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: ov.isEmpty ? kVVBorder : _accent.withValues(alpha: 0.45),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  targetTitle,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              if (_layer == 2) ...[
                _dimensionBadge(_selectedBiome.dimension),
                const SizedBox(width: 6),
              ],
              _OverrideStatusPill(
                isOverridden: !ov.isEmpty,
                overriddenLabel: 'Customized',
                inheritedLabel: 'All Inherited',
                accent: _accent,
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            targetNote,
            style: const TextStyle(
              color: Colors.white54,
              fontSize: 11.5,
              height: 1.25,
            ),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              OutlinedButton.icon(
                onPressed: _openCopyFromDialog,
                icon: Icon(Icons.copy_all_rounded, size: 15, color: _accent),
                label: const Text('Copy from...'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: kVVCard,
                  side: BorderSide(color: _accent.withValues(alpha: 0.5)),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 11,
                    vertical: 8,
                  ),
                  minimumSize: const Size(0, 34),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  textStyle: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              OutlinedButton.icon(
                onPressed: ov.isEmpty ? null : _resetActiveLayer,
                icon: const Icon(Icons.restart_alt_rounded, size: 15),
                label: const Text('Reset layer'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.white70,
                  disabledForegroundColor: Colors.white24,
                  backgroundColor: kVVCard,
                  side: const BorderSide(color: kVVBorder),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 11,
                    vertical: 8,
                  ),
                  minimumSize: const Size(0, 34),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  textStyle: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPresetChipField({
    required String label,
    required String tooltip,
    required String? explicitValue,
    required String effectiveValue,
    required List<({String id, String label})> options,
    required ValueChanged<String> onSelected,
    required VoidCallback onClear,
  }) {
    final bool isOverridden = explicitValue != null;
    final bool knownOption = options.any((o) => o.id == effectiveValue);
    final List<({String value, String label})> chipOptions = [
      ...options.map((o) => (value: o.id, label: o.label)),
      if (!knownOption && effectiveValue.isNotEmpty)
        (value: effectiveValue, label: effectiveValue),
    ];

    return _BiomeOverrideCard(
      isOverridden: isOverridden,
      accent: _accent,
      onClear: onClear,
      child: VVChipSelector<String>(
        label: label,
        tooltip: tooltip,
        options: chipOptions,
        selected: effectiveValue,
        accent: _accent,
        onSelected: onSelected,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final ov = _activeOverride;
    final base = _inheritedBaseline();

    final effectiveWaterPreset = ov.waterPreset ?? base.waterPreset ?? 'water_tropical';
    final effectiveSky = ov.skyColor ?? base.skyColor ?? const Color(0xFF4461D4);
    final effectiveWaterColor =
        ov.waterSurfaceColor ?? base.waterSurfaceColor ?? const Color(0xFF44AFF5);
    final effectiveWaterOpacity =
        (ov.waterSurfaceOpacity ?? base.waterSurfaceOpacity ?? 1.0).clamp(0.0, 1.0);
    final effectiveGrass =
        ov.grassColor ?? base.grassColor ?? const Color(0xFF79C05A);
    final effectiveFoliage =
        ov.foliageColor ?? base.foliageColor ?? const Color(0xFF59AE30);
    final effectivePrecip =
        ov.precipitationType ?? base.precipitationType ?? 'none';
    final effectivePrecipDensity =
        (ov.precipitationDensity ?? base.precipitationDensity ?? 0.35)
            .clamp(0.0, 1.0);

    final effectiveFog = ov.fogPreset ?? base.fogPreset ?? 'fog_overworld';
    final effectiveCg =
        ov.colorGradingPreset ?? base.colorGradingPreset ?? 'color_grading';
    final effectiveAtmo =
        ov.atmospherePreset ?? base.atmospherePreset ?? 'global_atmosphere';
    final effectiveLight =
        ov.lightingPreset ?? base.lightingPreset ?? 'global';

    final int customGroupCount = widget.config.biomeOverrides.groupOverrides.values
        .where((e) => !e.isEmpty)
        .length;
    final int customBiomeCount = widget.config.biomeOverrides.biomeOverrides.values
        .where((e) => !e.isEmpty)
        .length;

    final String biomeLabel = _layer == 0
        ? 'Overworld Global'
        : (_layer == 1
            ? _selectedGroup.displayName
            : _selectedBiome.displayName);

    return ListView(
      padding: const EdgeInsets.all(14),
      children: [
        VVBiomesPreviewBanner(
          biomeLabel: biomeLabel,
          skyColor: effectiveSky,
          grassColor: effectiveGrass,
          foliageColor: effectiveFoliage,
          waterColor: effectiveWaterColor,
          waterOpacity: effectiveWaterOpacity,
          precipitationType: effectivePrecip,
          precipitationDensity: effectivePrecipDensity,
        ),
        const SizedBox(height: 12),

        // Layer & Target Selector Card
        VVSectionCard(
          title: 'Override Layer',
          accent: _accent,
          badge: Container(
            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
            decoration: BoxDecoration(
              color: kVVSurface,
              borderRadius: BorderRadius.circular(5),
              border: Border.all(color: kVVBorder),
            ),
            child: Text(
              'G $customGroupCount/10 · B $customBiomeCount/87',
              style: const TextStyle(
                color: Colors.white60,
                fontSize: 10,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          children: [
            VVChipSelector<int>(
              label: 'Layer Scope',
              tooltip:
                  'Higher layers override lower layers. Clear individual fields to inherit again.',
              options: const [
                (value: 0, label: 'Global (Overworld)'),
                (value: 1, label: 'Biome Group'),
                (value: 2, label: 'Single Biome'),
              ],
              selected: _layer,
              accent: _accent,
              onSelected: (v) => setState(() => _layer = v),
            ),
            if (_layer == 1) ...[
              const SizedBox(height: 8),
              _buildGroupSelector(),
            ],
            if (_layer == 2) ...[
              const SizedBox(height: 8),
              _buildSingleBiomeSelector(),
            ],
            const SizedBox(height: 12),
            _buildActiveLayerBanner(ov),
          ],
        ),
        const SizedBox(height: 12),

        // Simple Biome Appearance Controls
        VVSectionCard(
          title: 'Biome Look & Weather',
          accent: _accent,
          children: [
            _buildPresetChipField(
              label: 'Water Preset',
              tooltip:
                  'Assigns one of your 5 water presets (minecraft:water_identifier).',
              explicitValue: ov.waterPreset,
              effectiveValue: effectiveWaterPreset,
              options: _kWaterPresetOptions,
              onSelected: (v) => _applyLayerOverride(ov.copyWith(waterPreset: v)),
              onClear: () =>
                  _applyLayerOverride(_clearBiomeField(ov, _BiomeField.waterPreset)),
            ),
            _BiomeOverrideCard(
              isOverridden: ov.skyColor != null,
              accent: _accent,
              onClear: () =>
                  _applyLayerOverride(_clearBiomeField(ov, _BiomeField.skyColor)),
              child: VVColorRow(
                label: 'Sky Color',
                tooltip: 'minecraft:sky_color.sky_color',
                color: effectiveSky,
                accent: _accent,
                trailingBadge: _OverrideStatusPill(
                  isOverridden: ov.skyColor != null,
                  accent: _accent,
                ),
                onChanged: (c) =>
                    _applyLayerOverride(ov.copyWith(skyColor: c)),
              ),
            ),
            _BiomeOverrideCard(
              isOverridden: ov.waterSurfaceColor != null,
              accent: _accent,
              onClear: () => _applyLayerOverride(
                _clearBiomeField(ov, _BiomeField.waterSurfaceColor),
              ),
              child: VVColorRow(
                label: 'Water Surface Color',
                tooltip: 'minecraft:water_appearance.surface_color',
                color: effectiveWaterColor,
                accent: _accent,
                trailingBadge: _OverrideStatusPill(
                  isOverridden: ov.waterSurfaceColor != null,
                  accent: _accent,
                ),
                onChanged: (c) =>
                    _applyLayerOverride(ov.copyWith(waterSurfaceColor: c)),
              ),
            ),
            _BiomeOverrideCard(
              isOverridden: ov.waterSurfaceOpacity != null,
              accent: _accent,
              onClear: () => _applyLayerOverride(
                _clearBiomeField(ov, _BiomeField.waterSurfaceOpacity),
              ),
              child: VVLabeledSlider(
                label: 'Water Opacity',
                tooltip:
                    'minecraft:water_appearance.surface_opacity (0.0 transparent .. 1.0 opaque)',
                value: effectiveWaterOpacity,
                min: 0.0,
                max: 1.0,
                divisions: 100,
                decimals: 2,
                accent: _accent,
                onChanged: (v) => _applyLayerOverride(
                  ov.copyWith(waterSurfaceOpacity: v.clamp(0.0, 1.0)),
                ),
              ),
            ),
            _BiomeOverrideCard(
              isOverridden: ov.grassColor != null,
              accent: _accent,
              onClear: () =>
                  _applyLayerOverride(_clearBiomeField(ov, _BiomeField.grassColor)),
              child: VVColorRow(
                label: 'Grass Color',
                tooltip: (ov.grassColor == null && base.grassColor == null)
                    ? 'minecraft:grass_appearance.color (currently using vanilla colormap)'
                    : 'minecraft:grass_appearance.color',
                color: effectiveGrass,
                accent: _accent,
                trailingBadge: _OverrideStatusPill(
                  isOverridden: ov.grassColor != null,
                  accent: _accent,
                ),
                onChanged: (c) =>
                    _applyLayerOverride(ov.copyWith(grassColor: c)),
              ),
            ),
            _BiomeOverrideCard(
              isOverridden: ov.foliageColor != null,
              accent: _accent,
              onClear: () => _applyLayerOverride(
                _clearBiomeField(ov, _BiomeField.foliageColor),
              ),
              child: VVColorRow(
                label: 'Foliage Color',
                tooltip: (ov.foliageColor == null && base.foliageColor == null)
                    ? 'minecraft:foliage_appearance.color (currently using vanilla colormap)'
                    : 'minecraft:foliage_appearance.color',
                color: effectiveFoliage,
                accent: _accent,
                trailingBadge: _OverrideStatusPill(
                  isOverridden: ov.foliageColor != null,
                  accent: _accent,
                ),
                onChanged: (c) =>
                    _applyLayerOverride(ov.copyWith(foliageColor: c)),
              ),
            ),
            _buildPresetChipField(
              label: 'Weather Precipitation',
              tooltip:
                  'Ambient particle precipitation (max 1 per biome in Bedrock).',
              explicitValue: ov.precipitationType,
              effectiveValue: effectivePrecip,
              options: _kPrecipitationOptions,
              onSelected: (v) =>
                  _applyLayerOverride(ov.copyWith(precipitationType: v)),
              onClear: () => _applyLayerOverride(
                _clearBiomeField(ov, _BiomeField.precipitationType),
              ),
            ),
            _BiomeOverrideCard(
              isOverridden: ov.precipitationDensity != null,
              accent: _accent,
              onClear: () => _applyLayerOverride(
                _clearBiomeField(ov, _BiomeField.precipitationDensity),
              ),
              child: VVLabeledSlider(
                label: 'Precipitation Density',
                tooltip: effectivePrecip == 'none'
                    ? 'Select a precipitation particle above to activate (max 1 per biome).'
                    : 'minecraft:precipitation density (0.0..1.0, max 1 per biome).',
                value: effectivePrecipDensity,
                min: 0.0,
                max: 1.0,
                divisions: 100,
                decimals: 2,
                enabled: effectivePrecip != 'none',
                accent: _accent,
                onChanged: (v) => _applyLayerOverride(
                  ov.copyWith(precipitationDensity: v.clamp(0.0, 1.0)),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Advanced Biome Links (Collapsible)
        VVSectionCard(
          key: const ValueKey('biomes_adv_section'),
          title: 'Advanced',
          accent: _accent,
          collapsible: true,
          initiallyExpanded: false,
          children: [
            _buildPresetChipField(
              label: 'Fog Preset',
              tooltip: 'minecraft:fog_appearance.fog_identifier',
              explicitValue: ov.fogPreset,
              effectiveValue: effectiveFog,
              options: _kFogPresetOptions,
              onSelected: (v) => _applyLayerOverride(ov.copyWith(fogPreset: v)),
              onClear: () =>
                  _applyLayerOverride(_clearBiomeField(ov, _BiomeField.fogPreset)),
            ),
            _buildPresetChipField(
              label: 'Color Mood Link',
              tooltip: 'minecraft:color_grading_identifier',
              explicitValue: ov.colorGradingPreset,
              effectiveValue: effectiveCg,
              options: _kColorGradingOptions,
              onSelected: (v) =>
                  _applyLayerOverride(ov.copyWith(colorGradingPreset: v)),
              onClear: () => _applyLayerOverride(
                _clearBiomeField(ov, _BiomeField.colorGradingPreset),
              ),
            ),
            _buildPresetChipField(
              label: 'Atmosphere Identifier',
              tooltip: 'minecraft:atmosphere_identifier.atmosphere_identifier',
              explicitValue: ov.atmospherePreset,
              effectiveValue: effectiveAtmo,
              options: _kAtmosphereOptions,
              onSelected: (v) =>
                  _applyLayerOverride(ov.copyWith(atmospherePreset: v)),
              onClear: () => _applyLayerOverride(
                _clearBiomeField(ov, _BiomeField.atmospherePreset),
              ),
            ),
            _buildPresetChipField(
              label: 'Lighting Identifier',
              tooltip: 'minecraft:lighting_identifier.lighting_identifier',
              explicitValue: ov.lightingPreset,
              effectiveValue: effectiveLight,
              options: _kLightingOptions,
              onSelected: (v) =>
                  _applyLayerOverride(ov.copyWith(lightingPreset: v)),
              onClear: () => _applyLayerOverride(
                _clearBiomeField(ov, _BiomeField.lightingPreset),
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
      ],
    );
  }
}

class _OverrideStatusPill extends StatelessWidget {
  final bool isOverridden;
  final String overriddenLabel;
  final String inheritedLabel;
  final Color accent;

  const _OverrideStatusPill({
    required this.isOverridden,
    this.overriddenLabel = 'Overridden',
    this.inheritedLabel = 'Inherited',
    required this.accent,
  });

  @override
  Widget build(BuildContext context) {
    final color = isOverridden ? accent : Colors.white38;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(
        color: isOverridden
            ? accent.withValues(alpha: 0.16)
            : Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(5),
        border: Border.all(
          color: isOverridden ? accent.withValues(alpha: 0.5) : kVVBorder,
        ),
      ),
      child: Text(
        isOverridden ? overriddenLabel : inheritedLabel,
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _BiomeOverrideCard extends StatelessWidget {
  final bool isOverridden;
  final Color accent;
  final VoidCallback onClear;
  final Widget child;

  const _BiomeOverrideCard({
    required this.isOverridden,
    required this.accent,
    required this.onClear,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 5),
      padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
      decoration: BoxDecoration(
        color: kVVSurface.withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(11),
        border: Border.all(
          color: isOverridden ? accent.withValues(alpha: 0.45) : kVVBorder,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _OverrideStatusPill(isOverridden: isOverridden, accent: accent),
              const Spacer(),
              if (isOverridden)
                InkWell(
                  borderRadius: BorderRadius.circular(6),
                  onTap: onClear,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 7,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: kVVCard,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: kVVBorder),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.close_rounded,
                          size: 12,
                          color: Colors.white70,
                        ),
                        SizedBox(width: 3),
                        Text(
                          'Clear',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 10.5,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 4),
          child,
        ],
      ),
    );
  }
}

class _CopyFromBiomeDialog extends StatefulWidget {
  final VVShaderConfig config;
  final Color accent;

  const _CopyFromBiomeDialog({
    required this.config,
    required this.accent,
  });

  @override
  State<_CopyFromBiomeDialog> createState() => _CopyFromBiomeDialogState();
}

class _CopyFromBiomeDialogState extends State<_CopyFromBiomeDialog> {
  int _tab = 0; // 0 = Groups, 1 = Biomes
  String _query = '';

  BiomeAppearanceOverride _overrideFromBiome(VanillaBiomeEntry b) {
    final custom = widget.config.biomeOverrides.biomeOverrides[b.id];
    if (custom != null && !custom.isEmpty) return custom;
    return BiomeAppearanceOverride(
      atmospherePreset: b.defaultAtmospherePreset,
      colorGradingPreset: b.defaultColorGradingPreset,
      lightingPreset: b.defaultLightingPreset,
      waterPreset: b.defaultWaterPreset,
      fogPreset: b.defaultFogPreset,
      skyColor: b.defaultSkyColor,
      waterSurfaceColor: b.defaultWaterSurfaceColor,
      waterSurfaceOpacity: b.defaultWaterSurfaceOpacity,
      grassColor: b.defaultGrassColor,
      foliageColor: b.defaultFoliageColor,
      precipitationType: b.defaultPrecipitationType,
      precipitationDensity: b.defaultPrecipitationDensity,
    );
  }

  @override
  Widget build(BuildContext context) {
    final groupMap = widget.config.biomeOverrides.groupOverrides;
    final biomeMap = widget.config.biomeOverrides.biomeOverrides;
    final q = _query.trim().toLowerCase();
    final biomes = q.isEmpty
        ? kVanillaBiomes
        : kVanillaBiomes
            .where(
              (b) =>
                  b.displayName.toLowerCase().contains(q) ||
                  b.id.toLowerCase().contains(q),
            )
            .toList();

    return AlertDialog(
      backgroundColor: kVVSurface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: const BorderSide(color: kVVBorder, width: 1.4),
      ),
      title: const Text(
        'Copy Biome Overrides From...',
        style: TextStyle(
          color: Colors.white,
          fontSize: 15.5,
          fontWeight: FontWeight.w600,
        ),
      ),
      content: SizedBox(
        width: 360,
        height: 390,
        child: Column(
          children: [
            VVChipSelector<int>(
              label: 'Source Type',
              options: const [
                (value: 0, label: 'Biome Groups (10)'),
                (value: 1, label: 'Single Biomes (87)'),
              ],
              selected: _tab,
              accent: widget.accent,
              onSelected: (v) => setState(() => _tab = v),
            ),
            if (_tab == 1) ...[
              const SizedBox(height: 6),
              TextField(
                style: const TextStyle(color: Colors.white, fontSize: 12.5),
                decoration: InputDecoration(
                  hintText: 'Filter biomes...',
                  hintStyle: const TextStyle(color: Colors.white38, fontSize: 12),
                  prefixIcon: const Icon(Icons.search_rounded, size: 17, color: Colors.white54),
                  isDense: true,
                  filled: true,
                  fillColor: kVVBackground,
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: kVVBorder),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: widget.accent),
                  ),
                ),
                onChanged: (v) => setState(() => _query = v),
              ),
            ],
            const SizedBox(height: 8),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: kVVBackground,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: kVVBorder),
                ),
                child: _tab == 0
                    ? ListView.separated(
                        itemCount: BiomeGroup.values.length,
                        separatorBuilder: (_, _) =>
                            const Divider(height: 1, color: kVVBorder),
                        itemBuilder: (ctx, i) {
                          final g = BiomeGroup.values[i];
                          final ov =
                              groupMap[g] ?? const BiomeAppearanceOverride();
                          return ListTile(
                            dense: true,
                            title: Text(
                              g.displayName,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            trailing: _OverrideStatusPill(
                              isOverridden: !ov.isEmpty,
                              overriddenLabel: 'Edited',
                              inheritedLabel: 'Empty',
                              accent: widget.accent,
                            ),
                            onTap: () => Navigator.of(ctx).pop(ov),
                          );
                        },
                      )
                    : ListView.separated(
                        itemCount: biomes.length,
                        separatorBuilder: (_, _) =>
                            const Divider(height: 1, color: kVVBorder),
                        itemBuilder: (ctx, i) {
                          final b = biomes[i];
                          final hasCustom = !(biomeMap[b.id]?.isEmpty ?? true);
                          return ListTile(
                            dense: true,
                            title: Text(
                              b.displayName,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12.5,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            subtitle: Text(
                              b.id,
                              style: const TextStyle(
                                color: Colors.white38,
                                fontFamily: 'monospace',
                                fontSize: 10.5,
                              ),
                            ),
                            trailing: _OverrideStatusPill(
                              isOverridden: hasCustom,
                              overriddenLabel: 'Custom',
                              inheritedLabel: 'Preset',
                              accent: widget.accent,
                            ),
                            onTap: () =>
                                Navigator.of(ctx).pop(_overrideFromBiome(b)),
                          );
                        },
                      ),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel', style: TextStyle(color: Colors.white54)),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// TAB 7: VVSurfaceTab (Tab index 6)
// ─────────────────────────────────────────────────────────────────────────────

class VVSurfaceTab extends StatelessWidget {
  final VVShaderConfig config;
  final ValueChanged<VVShaderConfig> onConfigChanged;

  const VVSurfaceTab({
    super.key,
    required this.config,
    required this.onConfigChanged,
  });

  static Color get _accent => kVVPrimary;

  void _updateSurface(SurfaceConfig next) {
    onConfigChanged(config.copyWith(surface: next));
  }

  @override
  Widget build(BuildContext context) {
    final s = config.surface;
    final shininess = s.shininess;

    return ListView(
      padding: const EdgeInsets.all(14),
      children: [
        VVSurfacePreviewBanner(surface: s),
        const SizedBox(height: 12),

        // Simple: Global Surface Shininess
        VVSectionCard(
          title: 'Surface Finish',
          accent: _accent,
          children: [
            VVLabeledSlider(
              label: 'Global Surface Shininess',
              tooltip:
                  'Sets pbr/global.json fallback roughness (255 matte .. 0 mirror) when blocks lack custom .texture_set.json maps.',
              value: shininess,
              min: 0.0,
              max: 1.0,
              divisions: 100,
              decimals: 2,
              accent: _accent,
              onChanged: (v) {
                _updateSurface(
                  SurfaceConfig.fromShininess(
                    v.clamp(0.0, 1.0),
                    metalness: s.metalness,
                    emissive: s.emissive,
                    subsurface: s.subsurface,
                  ),
                );
              },
            ),
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 9),
              decoration: BoxDecoration(
                color: kVVSurface,
                borderRadius: BorderRadius.circular(9),
                border: Border.all(color: kVVBorder),
              ),
              child: Row(
                children: [
                  Icon(Icons.layers_rounded, size: 16, color: _accent),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Roughness: ${s.roughness} / 255  ·  MERS [${s.metalness}, ${s.emissive}, ${s.roughness}, ${s.subsurface}]',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontFamily: 'monospace',
                        fontSize: 11.5,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Advanced: Individual MERS Channels
        VVSectionCard(
          key: const ValueKey('surface_adv_section'),
          title: 'Advanced',
          accent: _accent,
          collapsible: true,
          initiallyExpanded: false,
          children: [
            VVLabeledSlider(
              label: 'Fallback Metalness',
              tooltip: 'Global metalness fallback (0..255) for blocks, actors, items.',
              value: s.metalness.toDouble(),
              min: 0,
              max: 255,
              divisions: 255,
              decimals: 0,
              accent: _accent,
              onChanged: (v) =>
                  _updateSurface(s.copyWith(metalness: v.round().clamp(0, 255))),
            ),
            VVLabeledSlider(
              label: 'Fallback Emissive',
              tooltip: 'Global emissive glow fallback (0..255). Keep 0 unless all blocks should glow.',
              value: s.emissive.toDouble(),
              min: 0,
              max: 255,
              divisions: 255,
              decimals: 0,
              accent: _accent,
              onChanged: (v) =>
                  _updateSurface(s.copyWith(emissive: v.round().clamp(0, 255))),
            ),
            VVLabeledSlider(
              label: 'Fallback Roughness',
              tooltip: 'Global roughness fallback (0 = mirror glossy, 255 = fully matte).',
              value: s.roughness.toDouble(),
              min: 0,
              max: 255,
              divisions: 255,
              decimals: 0,
              accent: _accent,
              onChanged: (v) =>
                  _updateSurface(s.copyWith(roughness: v.round().clamp(0, 255))),
            ),
            VVLabeledSlider(
              label: 'Fallback Subsurface',
              tooltip: 'Global subsurface scattering fallback for blocks (0..255).',
              value: s.subsurface.toDouble(),
              min: 0,
              max: 255,
              divisions: 255,
              decimals: 0,
              accent: _accent,
              onChanged: (v) =>
                  _updateSurface(s.copyWith(subsurface: v.round().clamp(0, 255))),
            ),
          ],
        ),
        const SizedBox(height: 24),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// TAB 8: VVPerformanceTab (Tab index 7)
// ─────────────────────────────────────────────────────────────────────────────

class VVPerformanceTab extends StatelessWidget {
  final VVShaderConfig config;
  final ValueChanged<VVShaderConfig> onConfigChanged;

  const VVPerformanceTab({
    super.key,
    required this.config,
    required this.onConfigChanged,
  });

  static Color get _accent => kVVPrimary;

  void _updatePerf(PerformanceTierConfig next) {
    onConfigChanged(config.copyWith(performance: next));
  }

  static Color _scoreColor(String label) {
    switch (label) {
      case 'Low':
        return const Color(0xFF4ADE80);
      case 'Medium':
        return const Color(0xFF22D3EE);
      case 'High':
        return const Color(0xFFFBBF24);
      case 'Heavy':
      default:
        return const Color(0xFFF87171);
    }
  }

  static String _blockLightsLabel(BlockLightsMode mode) {
    switch (mode) {
      case BlockLightsMode.allStatic:
        return 'All Static (0 pt)';
      case BlockLightsMode.torchesLanternsSoulOnly:
        return 'Torch/Lantern/Soul';
      case BlockLightsMode.allExceptCopper:
        return 'All except Copper';
      case BlockLightsMode.allPointLights:
        return 'All Point Lights';
    }
  }

  @override
  Widget build(BuildContext context) {
    final perf = config.performance;
    final score = computePerformanceScore(config);
    final scoreColor = _scoreColor(score.scoreLabel);

    final activeProfile = TierProfile.forTier(perf.activeTier, perf);

    return ListView(
      padding: const EdgeInsets.all(14),
      children: [
        VVPerfPreviewBanner(score: score, activeProfile: activeProfile),
        const SizedBox(height: 12),

        // 1. Live Performance Score Meter Card
        VVSectionCard(
          title: 'Live Performance Score',
          accent: scoreColor,
          badge: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: scoreColor.withValues(alpha: 0.16),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: scoreColor.withValues(alpha: 0.5)),
            ),
            child: Text(
              score.scoreLabel.toUpperCase(),
              style: TextStyle(
                color: scoreColor,
                fontSize: 10.5,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.4,
              ),
            ),
          ),
          children: [
            Row(
              children: [
                Text(
                  'Load: ${score.numericScore} / 100',
                  style: TextStyle(
                    color: scoreColor,
                    fontFamily: 'monospace',
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                Text(
                  'Point Lights: ${score.pointLightsCount} / 31',
                  style: const TextStyle(
                    color: Colors.white70,
                    fontFamily: 'monospace',
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: LinearProgressIndicator(
                value: (score.numericScore / 100.0).clamp(0.0, 1.0),
                minHeight: 9,
                backgroundColor: kVVSurface,
                valueColor: AlwaysStoppedAnimation<Color>(scoreColor),
              ),
            ),
            if (score.warnings.isNotEmpty) ...[
              const SizedBox(height: 10),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFFFBBF24).withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(9),
                  border: Border.all(
                    color: const Color(0xFFFBBF24).withValues(alpha: 0.4),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: score.warnings
                      .map(
                        (w) => Padding(
                          padding: const EdgeInsets.symmetric(vertical: 2),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Icon(
                                Icons.warning_amber_rounded,
                                size: 14,
                                color: Color(0xFFFBBF24),
                              ),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  w,
                                  style: const TextStyle(
                                    color: Colors.white70,
                                    fontSize: 11.5,
                                    height: 1.25,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                      .toList(),
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 12),

        // 2. 4 Tier Cards (TierProfile.all)
        VVSectionCard(
          title: 'Quality Tiers',
          accent: _accent,
          children: TierProfile.all.map((baseProfile) {
            final profile = TierProfile.forTier(baseProfile.tier, perf);
            final bool isActive = perf.activeTier == profile.tier;
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: InkWell(
                borderRadius: BorderRadius.circular(11),
                onTap: () => _updatePerf(perf.copyWith(activeTier: profile.tier)),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isActive
                        ? _accent.withValues(alpha: 0.12)
                        : kVVSurface,
                    borderRadius: BorderRadius.circular(11),
                    border: Border.all(
                      color: isActive ? _accent : kVVBorder,
                      width: isActive ? 1.5 : 1.0,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            isActive
                                ? Icons.radio_button_checked_rounded
                                : Icons.radio_button_off_rounded,
                            size: 18,
                            color: isActive ? _accent : Colors.white38,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              profile.displayName,
                              style: TextStyle(
                                color: isActive ? _accent : Colors.white,
                                fontSize: 13.5,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          if (isActive)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 7,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: _accent.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(5),
                                border: Border.all(
                                  color: _accent.withValues(alpha: 0.6),
                                ),
                              ),
                              child: Text(
                                'ROOT TIER',
                                style: TextStyle(
                                  color: _accent,
                                  fontSize: 9.5,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 9),
                      Wrap(
                        spacing: 8,
                        runSpacing: 6,
                        children: [
                          _TierSpecChip(
                            label: 'Waves',
                            value: profile.wavesEnabled
                                ? 'ON (${profile.wavesOctaves} oct)'
                                : 'OFF',
                          ),
                          _TierSpecChip(
                            label: 'Caustics',
                            value: profile.causticsEnabled ? 'ON' : 'OFF',
                          ),
                          _TierSpecChip(
                            label: 'Lights',
                            value: _blockLightsLabel(profile.blockLightsMode),
                          ),
                          _TierSpecChip(
                            label: 'Fog Scale',
                            value: '${(profile.fogDensityScale * 100).round()}%',
                          ),
                          _TierSpecChip(
                            label: 'Shadows',
                            value:
                                '${profile.shadowStyle} · ${profile.shadowTexelSize}px',
                          ),
                          _TierSpecChip(
                            label: 'PBR Sets',
                            value: profile.pbrTextureSets ? 'ON' : 'OFF',
                          ),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              _TierSpecChip(
                                label: 'Memory Tier',
                                value: '${profile.memoryTier}',
                              ),
                              const SizedBox(width: 4),
                              const ExperimentalBadge(),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 12),

        // 3. Subpack Toggles
        VVSectionCard(
          title: 'Subpack Options',
          accent: _accent,
          children: [
            VVSwitchRow(
              label: 'Export all 4 tiers as subpacks',
              tooltip:
                  'Writes subpacks/low, medium, high, and ultra in manifest.json.',
              value: perf.exportAllTiers,
              accent: _accent,
              onChanged: (v) => _updatePerf(perf.copyWith(exportAllTiers: v)),
            ),
            VVSwitchRow(
              label: 'Include Style Intensity: Lite subpack',
              tooltip:
                  'Adds subpacks/lite blending saturation, contrast, and volumetric fog 40% toward neutral.',
              value: perf.styleIntensityLite,
              accent: _accent,
              onChanged: (v) =>
                  _updatePerf(perf.copyWith(styleIntensityLite: v)),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // 4. Advanced Per-Tier Octaves & Shadow Texels
        VVSectionCard(
          key: const ValueKey('perf_adv_section'),
          title: 'Advanced',
          accent: _accent,
          collapsible: true,
          initiallyExpanded: false,
          children: [
            VVLabeledSlider(
              label: 'Low · Waves Octaves',
              tooltip: 'Wave octave count exported in the Low subpack (1..30).',
              value: perf.octavesLow.toDouble(),
              min: 1,
              max: 30,
              divisions: 29,
              decimals: 0,
              accent: _accent,
              onChanged: (v) =>
                  _updatePerf(perf.copyWith(octavesLow: v.round().clamp(1, 30))),
            ),
            VVLabeledSlider(
              label: 'Medium · Waves Octaves',
              tooltip: 'Wave octave count exported in the Medium subpack (1..30).',
              value: perf.octavesMedium.toDouble(),
              min: 1,
              max: 30,
              divisions: 29,
              decimals: 0,
              accent: _accent,
              onChanged: (v) => _updatePerf(
                perf.copyWith(octavesMedium: v.round().clamp(1, 30)),
              ),
            ),
            VVLabeledSlider(
              label: 'High · Waves Octaves',
              tooltip: 'Wave octave count exported in the High subpack (1..30).',
              value: perf.octavesHigh.toDouble(),
              min: 1,
              max: 30,
              divisions: 29,
              decimals: 0,
              accent: _accent,
              onChanged: (v) =>
                  _updatePerf(perf.copyWith(octavesHigh: v.round().clamp(1, 30))),
            ),
            VVLabeledSlider(
              label: 'Ultra · Waves Octaves',
              tooltip: 'Wave octave count exported in the Ultra subpack (1..30).',
              value: perf.octavesUltra.toDouble(),
              min: 1,
              max: 30,
              divisions: 29,
              decimals: 0,
              accent: _accent,
              onChanged: (v) => _updatePerf(
                perf.copyWith(octavesUltra: v.round().clamp(1, 30)),
              ),
            ),
            const Divider(color: kVVBorder, height: 20),
            VVLabeledSlider(
              label: 'Low · Shadow Texel Size',
              tooltip: 'Shadow map texel size for Low tier (1..1024).',
              value: perf.texelLow.toDouble(),
              min: 1,
              max: 1024,
              decimals: 0,
              accent: _accent,
              onChanged: (v) =>
                  _updatePerf(perf.copyWith(texelLow: v.round().clamp(1, 1024))),
            ),
            VVLabeledSlider(
              label: 'Medium · Shadow Texel Size',
              tooltip: 'Shadow map texel size for Medium tier (1..1024).',
              value: perf.texelMedium.toDouble(),
              min: 1,
              max: 1024,
              decimals: 0,
              accent: _accent,
              onChanged: (v) => _updatePerf(
                perf.copyWith(texelMedium: v.round().clamp(1, 1024)),
              ),
            ),
            VVLabeledSlider(
              label: 'High · Shadow Texel Size',
              tooltip: 'Shadow map texel size for High tier (1..1024).',
              value: perf.texelHigh.toDouble(),
              min: 1,
              max: 1024,
              decimals: 0,
              accent: _accent,
              onChanged: (v) =>
                  _updatePerf(perf.copyWith(texelHigh: v.round().clamp(1, 1024))),
            ),
            VVLabeledSlider(
              label: 'Ultra · Shadow Texel Size',
              tooltip: 'Shadow map texel size for Ultra tier (1..1024).',
              value: perf.texelUltra.toDouble(),
              min: 1,
              max: 1024,
              decimals: 0,
              accent: _accent,
              onChanged: (v) => _updatePerf(
                perf.copyWith(texelUltra: v.round().clamp(1, 1024)),
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
      ],
    );
  }
}

class _TierSpecChip extends StatelessWidget {
  final String label;
  final String value;

  const _TierSpecChip({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: kVVCard,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: kVVBorder),
      ),
      child: RichText(
        text: TextSpan(
          style: const TextStyle(fontSize: 10.5),
          children: [
            TextSpan(
              text: '$label: ',
              style: const TextStyle(color: Colors.white54),
            ),
            TextSpan(
              text: value,
              style: const TextStyle(
                color: Colors.white,
                fontFamily: 'monospace',
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// TAB 9: VVExportTab (Tab index 8)
// ─────────────────────────────────────────────────────────────────────────────

class VVExportTab extends StatefulWidget {
  final VVShaderConfig config;
  final ValueChanged<VVShaderConfig> onConfigChanged;
  final Uint8List packIconBytes;
  final VoidCallback onPickIcon;
  final ValidationReport validationReport;
  final List<int>? generatedPackBytes;
  final String? generatedPackName;
  final VoidCallback onExportPack;
  final VoidCallback? onDownloadPack;
  final VoidCallback? onOpenInMinecraft;

  const VVExportTab({
    super.key,
    required this.config,
    required this.onConfigChanged,
    required this.packIconBytes,
    required this.onPickIcon,
    required this.validationReport,
    required this.generatedPackBytes,
    required this.generatedPackName,
    required this.onExportPack,
    this.onDownloadPack,
    this.onOpenInMinecraft,
  });

  @override
  State<VVExportTab> createState() => _VVExportTabState();
}

class _VVExportTabState extends State<VVExportTab> {
  static Color get _accent => kVVPrimary;

  late final TextEditingController _nameController;
  late final TextEditingController _descController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.config.packName);
    _descController = TextEditingController(
      text: widget.config.packDescription,
    );
  }

  @override
  void didUpdateWidget(covariant VVExportTab oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.config.packName != _nameController.text) {
      _nameController.value = TextEditingValue(
        text: widget.config.packName,
        selection: TextSelection.collapsed(
          offset: widget.config.packName.length,
        ),
      );
    }
    if (widget.config.packDescription != _descController.text) {
      _descController.value = TextEditingValue(
        text: widget.config.packDescription,
        selection: TextSelection.collapsed(
          offset: widget.config.packDescription.length,
        ),
      );
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    super.dispose();
  }

  List<int> get _normalizedVersion {
    final v = widget.config.packVersion;
    if (v.length == 3) return [v[0], v[1], v[2]];
    return [1, 0, 0];
  }

  void _stepVersion(int index, int delta) {
    final next = List<int>.from(_normalizedVersion);
    next[index] = (next[index] + delta).clamp(0, 999);
    widget.onConfigChanged(widget.config.copyWith(packVersion: next));
  }

  Widget _buildVersionStepper(String label, int value, int index) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
      decoration: BoxDecoration(
        color: kVVSurface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: kVVBorder),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '$label ',
            style: const TextStyle(color: Colors.white54, fontSize: 11),
          ),
          InkWell(
            borderRadius: BorderRadius.circular(5),
            onTap: value > 0 ? () => _stepVersion(index, -1) : null,
            child: Padding(
              padding: const EdgeInsets.all(4),
              child: Icon(
                Icons.remove_rounded,
                size: 14,
                color: value > 0 ? Colors.white70 : Colors.white24,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6),
            child: Text(
              '$value',
              style: const TextStyle(
                color: Colors.white,
                fontFamily: 'monospace',
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          InkWell(
            borderRadius: BorderRadius.circular(5),
            onTap: () => _stepVersion(index, 1),
            child: Padding(
              padding: const EdgeInsets.all(4),
              child: Icon(Icons.add_rounded, size: 14, color: _accent),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cfg = widget.config;
    final report = widget.validationReport;
    final ver = _normalizedVersion;
    final bytes = widget.generatedPackBytes;

    final int tierCount = cfg.performance.exportAllTiers ? 4 : 1;

    return ListView(
      padding: const EdgeInsets.all(14),
      children: [
        VVExportPreviewBanner(
          packIconBytes: widget.packIconBytes,
          packName: cfg.packName,
          version: ver,
          isValid: report.isValid,
          tierCount: tierCount,
        ),
        const SizedBox(height: 12),

        // 1. Pack Identity Card
        VVSectionCard(
          title: 'Pack Identity',
          accent: _accent,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  children: [
                    Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        color: kVVSurface,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: _accent.withValues(alpha: 0.6),
                          width: 1.5,
                        ),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8.5),
                        child: widget.packIconBytes.isEmpty
                            ? Icon(
                                Icons.image_outlined,
                                color: _accent.withValues(alpha: 0.7),
                                size: 28,
                              )
                            : Image.memory(
                                widget.packIconBytes,
                                width: 64,
                                height: 64,
                                fit: BoxFit.cover,
                                filterQuality: FilterQuality.none,
                                errorBuilder: (_, _, _) => Icon(
                                  Icons.broken_image_outlined,
                                  color: Colors.white38,
                                  size: 26,
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    OutlinedButton(
                      onPressed: widget.onPickIcon,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: _accent,
                        backgroundColor: kVVSurface,
                        side: BorderSide(color: _accent.withValues(alpha: 0.5)),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 5,
                        ),
                        minimumSize: const Size(0, 28),
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        textStyle: const TextStyle(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w600,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(7),
                        ),
                      ),
                      child: const Text('Choose Icon'),
                    ),
                  ],
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextFormField(
                        controller: _nameController,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 13.5,
                          fontWeight: FontWeight.w700,
                        ),
                        decoration: InputDecoration(
                          labelText: 'Pack Name',
                          labelStyle: const TextStyle(
                            color: Colors.white54,
                            fontSize: 12,
                          ),
                          isDense: true,
                          filled: true,
                          fillColor: kVVSurface,
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(9),
                            borderSide: const BorderSide(color: kVVBorder),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(9),
                            borderSide: BorderSide(color: _accent),
                          ),
                        ),
                        onChanged: (v) =>
                            widget.onConfigChanged(cfg.copyWith(packName: v)),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: kVVSurface,
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: kVVBorder),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text(
                              'Namespace: ',
                              style: TextStyle(
                                color: Colors.white54,
                                fontSize: 11,
                              ),
                            ),
                            Flexible(
                              child: Text(
                                '${cfg.packSlug}:',
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: _accent,
                                  fontFamily: 'monospace',
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.w600,
                                ),
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
            const SizedBox(height: 12),
            TextFormField(
              controller: _descController,
              maxLines: 2,
              style: const TextStyle(color: Colors.white, fontSize: 12.5),
              decoration: InputDecoration(
                labelText: 'Pack Description',
                labelStyle: const TextStyle(color: Colors.white54, fontSize: 12),
                isDense: true,
                filled: true,
                fillColor: kVVSurface,
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(9),
                  borderSide: const BorderSide(color: kVVBorder),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(9),
                  borderSide: BorderSide(color: _accent),
                ),
              ),
              onChanged: (v) =>
                  widget.onConfigChanged(cfg.copyWith(packDescription: v)),
            ),
            const SizedBox(height: 12),
            const Text(
              'Pack Version [major, minor, patch]',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 6),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _buildVersionStepper('Maj', ver[0], 0),
                _buildVersionStepper('Min', ver[1], 1),
                _buildVersionStepper('Pat', ver[2], 2),
              ],
            ),
            const SizedBox(height: 8),
            VVSwitchRow(
              label: 'Include lower-tier subpacks',
              tooltip:
                  'Includes Low, Medium, High & Ultra hardware subpacks in the exported .mcpack.',
              value: cfg.performance.exportAllTiers,
              accent: _accent,
              onChanged: (v) => widget.onConfigChanged(
                cfg.copyWith(
                  performance: cfg.performance.copyWith(exportAllTiers: v),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // 2. Validation Report Card
        VVSectionCard(
          title: 'Validation Report',
          accent: report.isValid ? _accent : const Color(0xFFF87171),
          children: [
            if (report.errors.isNotEmpty)
              Container(
                width: double.infinity,
                margin: EdgeInsets.only(
                  bottom: report.warnings.isNotEmpty ? 10 : 0,
                ),
                padding: const EdgeInsets.all(11),
                decoration: BoxDecoration(
                  color: const Color(0xFFEF4444).withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: const Color(0xFFEF4444).withValues(alpha: 0.6),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(
                          Icons.error_outline_rounded,
                          size: 16,
                          color: Color(0xFFF87171),
                        ),
                        SizedBox(width: 6),
                        Text(
                          'Fix errors before exporting',
                          style: TextStyle(
                            color: Color(0xFFF87171),
                            fontSize: 12.5,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    ...report.errors.map(
                      (err) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 2),
                        child: Text(
                          '• $err',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11.5,
                            height: 1.25,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            if (report.warnings.isNotEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(11),
                decoration: BoxDecoration(
                  color: const Color(0xFFFBBF24).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: const Color(0xFFFBBF24).withValues(alpha: 0.5),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(
                          Icons.warning_amber_rounded,
                          size: 16,
                          color: Color(0xFFFBBF24),
                        ),
                        SizedBox(width: 6),
                        Text(
                          'Advisories (non-blocking)',
                          style: TextStyle(
                            color: Color(0xFFFBBF24),
                            fontSize: 12.5,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    ...report.warnings.map(
                      (warn) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 2),
                        child: Text(
                          '• $warn',
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 11.5,
                            height: 1.25,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            if (report.errors.isEmpty && report.warnings.isEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(11),
                decoration: BoxDecoration(
                  color: const Color(0xFF10B981).withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: const Color(0xFF34D399).withValues(alpha: 0.55),
                  ),
                ),
                child: const Row(
                  children: [
                    Icon(
                      Icons.check_circle_outline_rounded,
                      size: 18,
                      color: Color(0xFF34D399),
                    ),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'All schema, biome, and pack-wide checks passed!',
                        style: TextStyle(
                          color: Color(0xFF34D399),
                          fontSize: 12.5,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
        const SizedBox(height: 12),

        // 3. Recommended In-Game Settings Card
        VVSectionCard(
          title: 'Recommended In-Game Settings',
          accent: const Color(0xFF7DD3FC),
          children: [
            const _InGameSettingRow(
              label: 'Video -> Graphics Mode',
              value: 'Vibrant Visuals',
            ),
            const _InGameSettingRow(
              label: 'Bloom · Brightness / Gamma',
              value: 'ON · 50%',
            ),
            const _InGameSettingRow(
              label: 'Reflections & Shadow Quality',
              value: 'Match your subpack tier',
            ),
            const _InGameSettingRow(
              label: 'Upscaling',
              value: 'TAAU (Recommended) or Bilinear',
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => showMinecraftGuideModal(context),
                icon: const Icon(Icons.help_outline_rounded, size: 16),
                label: const Text(
                  'OPEN STEP-BY-STEP ACTIVATION GUIDE',
                  style: TextStyle(
                    fontFamily: 'PixelifySans',
                    fontSize: 11.5,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.5,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF7DD3FC),
                  side: const BorderSide(color: Color(0xFF7DD3FC)),
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // 4. Export & Share Actions
        VVSectionCard(
          title: 'Export & Share',
          accent: _accent,
          children: [
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: report.isValid ? widget.onExportPack : null,
                icon: const Icon(Icons.inventory_2_rounded, size: 18),
                label: const Text('GENERATE .MCPACK'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _accent,
                  foregroundColor: Colors.black,
                  disabledBackgroundColor: kVVBorder,
                  disabledForegroundColor: Colors.white38,
                  padding: const EdgeInsets.symmetric(vertical: 13),
                  textStyle: const TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.5,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),
            if (bytes != null) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(11),
                decoration: BoxDecoration(
                  color: kVVSurface,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: _accent.withValues(alpha: 0.5)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.check_circle_rounded, size: 16, color: _accent),
                        const SizedBox(width: 7),
                        Expanded(
                          child: Text(
                            widget.generatedPackName ?? '${cfg.packSlug}.mcpack',
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12.5,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '${(bytes.length / 1024.0).toStringAsFixed(1)} KB',
                          style: TextStyle(
                            color: _accent,
                            fontFamily: 'monospace',
                            fontSize: 11.5,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: widget.onDownloadPack,
                            icon: const Icon(Icons.download_rounded, size: 16),
                            label: const Text('Download .mcpack'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.white,
                              backgroundColor: kVVCard,
                              side: BorderSide(
                                color: _accent.withValues(alpha: 0.55),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              textStyle: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: widget.onOpenInMinecraft,
                            icon: const Icon(Icons.sports_esports_rounded, size: 16),
                            label: const Text('Open in Minecraft'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _accent.withValues(alpha: 0.2),
                              foregroundColor: _accent,
                              elevation: 0,
                              side: BorderSide(
                                color: _accent.withValues(alpha: 0.65),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              textStyle: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 24),
      ],
    );
  }
}

class _InGameSettingRow extends StatelessWidget {
  final String label;
  final String value;

  const _InGameSettingRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: kVVSurface,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: kVVBorder),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              value,
              style: const TextStyle(
                color: Color(0xFF7DD3FC),
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
