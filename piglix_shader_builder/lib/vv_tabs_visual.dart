// vv_tabs_visual.dart
// Tabs 1–5 of the Piglix Vibrant Visuals Shader Builder:
//   1. VVSkyTimeTab      (Tab 0 - Sky & Time)
//   2. VVLightShadowsTab (Tab 1 - Light & Shadows)
//   3. VVFogAirTab       (Tab 2 - Fog & Air)
//   4. VVWaterTab        (Tab 3 - Water)
//   5. VVColorMoodTab    (Tab 4 - Color & Mood)

import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'vv_config.dart';
import 'vv_editor_widgets.dart';
import 'vv_tab_previews.dart';

typedef VVConfigChanged = void Function(
  VVShaderConfig next, {
  bool recordUndo,
});

// ─── SHARED PRIVATE HELPERS ───────────────────────────────────────────────────

Widget _vvTabListView({required List<Widget> children}) {
  final spaced = <Widget>[];
  for (var i = 0; i < children.length; i++) {
    spaced.add(children[i]);
    if (i < children.length - 1) {
      spaced.add(const SizedBox(height: 12));
    }
  }
  return ListView(
    padding: const EdgeInsets.fromLTRB(14, 12, 14, 110),
    children: spaced,
  );
}

Widget _vvBanner({
  required String message,
  required Color color,
  IconData icon = Icons.info_outline_rounded,
}) {
  return VVPixelBox(
    fillColor: color.withValues(alpha: 0.11),
    borderColor: color.withValues(alpha: 0.45),
    borderWidth: 1.2,
    step: 2.5,
    hasShadow: false,
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
    child: Row(
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            message,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    ),
  );
}

Widget _vvSubgroupLabel(String text) {
  return Padding(
    padding: const EdgeInsets.only(top: 10, bottom: 4),
    child: Row(
      children: [
        Container(
          width: 3,
          height: 12,
          decoration: BoxDecoration(
            color: kVVPrimary,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 7),
        Text(
          text,
          style: const TextStyle(
            color: kVVPrimary,
            fontSize: 11.5,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.3,
          ),
        ),
      ],
    ),
  );
}

// ═════════════════════════════════════════════════════════════════════════════
// TAB 1: VVSkyTimeTab (Tab 0)
// ═════════════════════════════════════════════════════════════════════════════

class VVSkyTimeTab extends StatefulWidget {
  final VVShaderConfig config;
  final VVConfigChanged onConfigChanged;

  const VVSkyTimeTab({
    super.key,
    required this.config,
    required this.onConfigChanged,
  });

  @override
  State<VVSkyTimeTab> createState() => _VVSkyTimeTabState();
}

class _VVSkyTimeTabState extends State<VVSkyTimeTab> {
  /// 0 = Morning (0.75), 1 = Noon (0.0), 2 = Evening (0.25), 3 = Night (0.5)
  int _phaseIdx = 1;

  String get _phaseLabel => switch (_phaseIdx) {
        0 => 'Morning',
        2 => 'Evening',
        3 => 'Night',
        _ => 'Noon',
      };

  void _updateAtm(AtmosphereConfig nextAtm, {required bool recordUndo}) {
    widget.onConfigChanged(
      widget.config.copyWith(atmosphere: nextAtm),
      recordUndo: recordUndo,
    );
  }

  Widget _atmSlider({
    required String label,
    required String tooltip,
    required double value,
    required double min,
    required double max,
    int decimals = 2,
    required AtmosphereConfig Function(double v) apply,
  }) {
    final clamped = value.clamp(min, max).toDouble();
    return VVLabeledSlider(
      label: label,
      tooltip: tooltip,
      value: clamped,
      min: min,
      max: max,
      decimals: decimals,
      onChanged: (v) => _updateAtm(apply(v.clamp(min, max)), recordUndo: false),
      onChangeEnd: (v) => _updateAtm(apply(v.clamp(min, max)), recordUndo: true),
    );
  }

  Future<void> _pickPhaseHorizonColor(int idx) async {
    final atm = widget.config.atmosphere;
    final current = switch (idx) {
      0 => atm.sunriseHorizon,
      2 => atm.sunsetHorizon,
      3 => atm.nightHorizon,
      _ => atm.noonHorizon,
    };
    final title = switch (idx) {
      0 => 'Morning Sky Color',
      2 => 'Evening Sky Color',
      3 => 'Night Sky Color',
      _ => 'Noon Sky Color',
    };
    final picked = await showVVColorPickerDialog(
      context,
      title: title,
      initialColor: current,
    );
    if (picked == null) return;
    final next = switch (idx) {
      0 => atm.copyWith(sunriseHorizon: picked),
      2 => atm.copyWith(sunsetHorizon: picked),
      3 => atm.copyWith(nightHorizon: picked),
      _ => atm.copyWith(noonHorizon: picked),
    };
    _updateAtm(next, recordUndo: true);
  }

  @override
  Widget build(BuildContext context) {
    final atm = widget.config.atmosphere;
    final l = widget.config.lighting;
    final isNight = _phaseIdx == 3;

    final previewHorizon = switch (_phaseIdx) {
      0 => atm.sunriseHorizon,
      2 => atm.sunsetHorizon,
      3 => atm.nightHorizon,
      _ => atm.noonHorizon,
    };
    final previewSunGlow = switch (_phaseIdx) {
      0 => atm.sunGlowSunrise,
      2 => atm.sunGlowSunset,
      3 => 0.0,
      _ => atm.sunGlowNoon,
    };

    return _vvTabListView(
      children: [
        VVSkyPreviewBanner(
          atmosphere: atm,
          lighting: l,
          fogColor: widget.config.fog.airFogColor,
          waterColor: widget.config.fog.waterFogColor,
          selectedPhase: _phaseIdx,
        ),
        VVSectionCard(
          title: 'Time of Day',
          children: [
            VVSceneBoxGrid(
              maxColumns: 4,
              cards: [
                VVSceneBoxCard(
                  label: 'Morning',
                  sceneType: VVSceneBoxType.morning,
                  color: atm.sunriseHorizon,
                  isSelected: _phaseIdx == 0,
                  showHexBadge: true,
                  onTap: () => setState(() => _phaseIdx = 0),
                  onPickColor: () {
                    setState(() => _phaseIdx = 0);
                    _pickPhaseHorizonColor(0);
                  },
                ),
                VVSceneBoxCard(
                  label: 'Noon',
                  sceneType: VVSceneBoxType.noon,
                  color: atm.noonHorizon,
                  isSelected: _phaseIdx == 1,
                  showHexBadge: true,
                  onTap: () => setState(() => _phaseIdx = 1),
                  onPickColor: () {
                    setState(() => _phaseIdx = 1);
                    _pickPhaseHorizonColor(1);
                  },
                ),
                VVSceneBoxCard(
                  label: 'Evening',
                  sceneType: VVSceneBoxType.evening,
                  color: atm.sunsetHorizon,
                  isSelected: _phaseIdx == 2,
                  showHexBadge: true,
                  onTap: () => setState(() => _phaseIdx = 2),
                  onPickColor: () {
                    setState(() => _phaseIdx = 2);
                    _pickPhaseHorizonColor(2);
                  },
                ),
                VVSceneBoxCard(
                  label: 'Night',
                  sceneType: VVSceneBoxType.night,
                  color: atm.nightHorizon,
                  isSelected: _phaseIdx == 3,
                  showHexBadge: true,
                  onTap: () => setState(() => _phaseIdx = 3),
                  onPickColor: () {
                    setState(() => _phaseIdx = 3);
                    _pickPhaseHorizonColor(3);
                  },
                ),
              ],
            ),
          ],
        ),
        VVSectionCard(
          title: '$_phaseLabel Sky Settings',
          children: [
            VVColorRow(
              label: '$_phaseLabel Horizon Color',
              tooltip: 'sky_horizon_color keyframe for $_phaseLabel',
              color: previewHorizon,
              onChanged: (c) {
                final next = switch (_phaseIdx) {
                  0 => atm.copyWith(sunriseHorizon: c),
                  2 => atm.copyWith(sunsetHorizon: c),
                  3 => atm.copyWith(nightHorizon: c),
                  _ => atm.copyWith(noonHorizon: c),
                };
                _updateAtm(next, recordUndo: true);
              },
            ),
            if (!isNight)
              _atmSlider(
                label: 'Sun Glow',
                tooltip: 'sun_mie_strength (0.0–60.0)',
                value: previewSunGlow,
                min: 0.0,
                max: 60.0,
                decimals: 1,
                apply: (v) => switch (_phaseIdx) {
                  0 => atm.copyWith(sunGlowSunrise: v),
                  2 => atm.copyWith(sunGlowSunset: v),
                  _ => atm.copyWith(sunGlowNoon: v),
                },
              ),
            if (isNight)
              _atmSlider(
                label: 'Moon Glow',
                tooltip: 'moon_mie_strength (0.0–20.0)',
                value: atm.moonGlow,
                min: 0.0,
                max: 20.0,
                decimals: 2,
                apply: (v) => atm.copyWith(moonGlow: v),
              ),
            _atmSlider(
              label: 'Horizon Haze',
              tooltip: 'horizon_blend_stops scale (0.0–2.0)',
              value: atm.horizonHazeScale,
              min: 0.0,
              max: 2.0,
              decimals: 2,
              apply: (v) => atm.withSimpleHorizonHaze(v),
            ),
            _atmSlider(
              label: 'Sky Scattering',
              tooltip: 'Noon rayleigh_strength (0.0–11.0)',
              value: atm.rayleighNoon,
              min: 0.0,
              max: 11.0,
              decimals: 2,
              apply: (v) => atm.copyWith(rayleighNoon: v),
            ),
          ],
        ),
        VVSectionCard(
          key: const Key('sky_adv_section'),
          title: 'Advanced',
          collapsible: true,
          initiallyExpanded: false,
          children: [
            VVSwitchRow(
              label: 'Auto-derive Zenith from Horizon',
              tooltip: 'Generates darker blue zenith sky colors automatically',
              value: atm.autoDeriveZenith,
              onChanged: (v) => _updateAtm(
                atm.copyWith(autoDeriveZenith: v),
                recordUndo: true,
              ),
            ),
            if (!atm.autoDeriveZenith) ...[
              _vvSubgroupLabel('Zenith Colors'),
              VVColorRow(
                label: 'Noon Zenith Color',
                tooltip: 'sky_zenith_color at 0.0',
                color: atm.noonZenith,
                onChanged: (c) =>
                    _updateAtm(atm.copyWith(noonZenith: c), recordUndo: true),
              ),
              VVColorRow(
                label: 'Evening Zenith Color',
                tooltip: 'sky_zenith_color at 0.25',
                color: atm.sunsetZenith,
                onChanged: (c) =>
                    _updateAtm(atm.copyWith(sunsetZenith: c), recordUndo: true),
              ),
              VVColorRow(
                label: 'Night Zenith Color',
                tooltip: 'sky_zenith_color at 0.5',
                color: atm.nightZenith,
                onChanged: (c) =>
                    _updateAtm(atm.copyWith(nightZenith: c), recordUndo: true),
              ),
              VVColorRow(
                label: 'Morning Zenith Color',
                tooltip: 'sky_zenith_color at 0.75',
                color: atm.sunriseZenith,
                onChanged: (c) =>
                    _updateAtm(atm.copyWith(sunriseZenith: c), recordUndo: true),
              ),
            ],
            _vvSubgroupLabel('Sky Scattering (Rayleigh)'),
            _atmSlider(
              label: 'Noon Scattering',
              tooltip: 'rayleigh_strength at 0.0 (0.0–11.0)',
              value: atm.rayleighNoon,
              min: 0.0,
              max: 11.0,
              apply: (v) => atm.copyWith(rayleighNoon: v),
            ),
            _atmSlider(
              label: 'Evening Scattering',
              tooltip: 'rayleigh_strength at 0.25 (0.0–11.0)',
              value: atm.rayleighSunset,
              min: 0.0,
              max: 11.0,
              apply: (v) => atm.copyWith(rayleighSunset: v),
            ),
            _atmSlider(
              label: 'Night Scattering',
              tooltip: 'rayleigh_strength at 0.5 (0.0–11.0)',
              value: atm.rayleighNight,
              min: 0.0,
              max: 11.0,
              apply: (v) => atm.copyWith(rayleighNight: v),
            ),
            _atmSlider(
              label: 'Morning Scattering',
              tooltip: 'rayleigh_strength at 0.75 (0.0–11.0)',
              value: atm.rayleighSunrise,
              min: 0.0,
              max: 11.0,
              apply: (v) => atm.copyWith(rayleighSunrise: v),
            ),
            _vvSubgroupLabel('Sun Glare Shape'),
            _atmSlider(
              label: 'Noon Sun Glare',
              tooltip: 'sun_glare_shape at 0.0 (0.01–50.0)',
              value: atm.sunGlareNoon,
              min: 0.01,
              max: 50.0,
              apply: (v) => atm.copyWith(sunGlareNoon: v),
            ),
            _atmSlider(
              label: 'Evening Sun Glare',
              tooltip: 'sun_glare_shape at 0.25 (0.01–50.0)',
              value: atm.sunGlareSunset,
              min: 0.01,
              max: 50.0,
              apply: (v) => atm.copyWith(sunGlareSunset: v),
            ),
            _atmSlider(
              label: 'Morning Sun Glare',
              tooltip: 'sun_glare_shape at 0.75 (0.01–50.0)',
              value: atm.sunGlareSunrise,
              min: 0.01,
              max: 50.0,
              apply: (v) => atm.copyWith(sunGlareSunrise: v),
            ),
            _vvSubgroupLabel('Horizon Blend Starts'),
            _atmSlider(
              label: 'Noon Blend Start',
              tooltip: 'horizon_blend_stops.start at 0.0',
              value: atm.horizonHazeNoon,
              min: 0.0,
              max: 1.0,
              decimals: 3,
              apply: (v) => atm.copyWith(horizonHazeNoon: v),
            ),
            _atmSlider(
              label: 'Evening Blend Start',
              tooltip: 'horizon_blend_stops.start at 0.25',
              value: atm.horizonHazeSunset,
              min: 0.0,
              max: 1.0,
              decimals: 3,
              apply: (v) => atm.copyWith(horizonHazeSunset: v),
            ),
            _atmSlider(
              label: 'Night Blend Start',
              tooltip: 'horizon_blend_stops.start at 0.5',
              value: atm.horizonHazeNight,
              min: 0.0,
              max: 1.0,
              decimals: 3,
              apply: (v) => atm.copyWith(horizonHazeNight: v),
            ),
            _atmSlider(
              label: 'Morning Blend Start',
              tooltip: 'horizon_blend_stops.start at 0.75',
              value: atm.horizonHazeSunrise,
              min: 0.0,
              max: 1.0,
              decimals: 3,
              apply: (v) => atm.copyWith(horizonHazeSunrise: v),
            ),
          ],
        ),
      ],
    );
  }
}

// ═════════════════════════════════════════════════════════════════════════════
// TAB 2: VVLightShadowsTab (Tab 1)
// ═════════════════════════════════════════════════════════════════════════════

class VVLightShadowsTab extends StatefulWidget {
  final VVShaderConfig config;
  final VVConfigChanged onConfigChanged;

  const VVLightShadowsTab({
    super.key,
    required this.config,
    required this.onConfigChanged,
  });

  @override
  State<VVLightShadowsTab> createState() => _VVLightShadowsTabState();
}

class _VVLightShadowsTabState extends State<VVLightShadowsTab> {
  int _lightMode = 0; // 0 = Sunlight, 1 = Cave, 2 = Block Lights
  int _sunPhase = 0; // 0 = Noon, 1 = Sunset, 2 = Sunrise, 3 = Night Moon
  int _selectedLightGroup = 1; // 0..6 (Defaults to Lanterns)

  void _updateLighting(LightingConfig next, {required bool recordUndo}) {
    widget.onConfigChanged(
      widget.config.copyWith(lighting: next),
      recordUndo: recordUndo,
    );
  }

  Widget _lightSlider({
    required String label,
    required String tooltip,
    required double value,
    required double min,
    required double max,
    int? divisions,
    String unit = '',
    int decimals = 2,
    bool isPackWide = false,
    bool isExperimental = false,
    required LightingConfig Function(double v) apply,
  }) {
    final clamped = value.clamp(min, max).toDouble();
    return VVLabeledSlider(
      label: label,
      tooltip: tooltip,
      value: clamped,
      min: min,
      max: max,
      divisions: divisions,
      unit: unit,
      decimals: decimals,
      isPackWide: isPackWide,
      isExperimental: isExperimental,
      onChanged: (v) =>
          _updateLighting(apply(v.clamp(min, max)), recordUndo: false),
      onChangeEnd: (v) =>
          _updateLighting(apply(v.clamp(min, max)), recordUndo: true),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l = widget.config.lighting;
    final pointCount = l.countPointLightBlocks();

    final (phaseColorLabel, phaseColor) = switch (_sunPhase) {
      1 => ('Evening Sun Tint', l.sunColorSunset),
      2 => ('Morning Sun Tint', l.sunColorSunrise),
      3 => ('Night Sky Tint', l.nightMoonColor),
      _ => ('Noon Sun Tint', l.sunColorNoon),
    };

    return _vvTabListView(
      children: [
        VVLightingPreviewBanner(
          mode: _lightMode,
          lighting: l,
          sunPhase: _sunPhase,
          activeLightGroupIndex: _selectedLightGroup,
        ),
        VVSectionCard(
          title: 'Light Source',
          children: [
            VVSceneBoxGrid(
              maxColumns: 3,
              cards: [
                VVSceneBoxCard(
                  label: 'Sunlight',
                  sceneType: VVSceneBoxType.sunlight,
                  color: l.sunColorNoon,
                  isSelected: _lightMode == 0,
                  onTap: () => setState(() => _lightMode = 0),
                ),
                VVSceneBoxCard(
                  label: 'Cave',
                  sceneType: VVSceneBoxType.cave,
                  color: l.ambientColor,
                  isSelected: _lightMode == 1,
                  onTap: () => setState(() => _lightMode = 1),
                ),
                VVSceneBoxCard(
                  label: 'Block Lights',
                  sceneType: VVSceneBoxType.blockLights,
                  color: l.lanterns.color,
                  isSelected: _lightMode == 2,
                  onTap: () => setState(() => _lightMode = 2),
                ),
              ],
            ),
          ],
        ),
        if (_lightMode == 0)
          VVSectionCard(
            title: 'Sunlight & Shadows',
            children: [
              _lightSlider(
                label: 'Sunlight Brightness',
                tooltip: 'Scales directional sun brightness (0.1x–2.0x)',
                value: l.sunBrightnessMultiplier,
                min: 0.1,
                max: 2.0,
                unit: 'x',
                decimals: 2,
                apply: (v) => l.copyWith(sunBrightnessMultiplier: v),
              ),
              VVChipSelector<int>(
                label: 'Sun Color Time',
                options: const [
                  (value: 0, label: 'Noon'),
                  (value: 1, label: 'Evening'),
                  (value: 2, label: 'Morning'),
                  (value: 3, label: 'Night'),
                ],
                selected: _sunPhase,
                onSelected: (idx) => setState(() => _sunPhase = idx),
              ),
              VVColorRow(
                label: phaseColorLabel,
                tooltip: 'Directional sun light color',
                color: phaseColor,
                onChanged: (c) {
                  final next = switch (_sunPhase) {
                    1 => l.copyWith(sunColorSunset: c),
                    2 => l.copyWith(sunColorSunrise: c),
                    3 => l.copyWith(nightMoonColor: c),
                    _ => l.copyWith(sunColorNoon: c),
                  };
                  _updateLighting(next, recordUndo: true);
                },
              ),
              _lightSlider(
                label: 'Shadow Darkness',
                tooltip: 'sky.intensity 0.1–1.0 (lower = darker shadows)',
                value: l.skyIntensity,
                min: 0.1,
                max: 1.0,
                decimals: 2,
                apply: (v) => l.copyWith(skyIntensity: v),
              ),
              VVChipSelector<String>(
                label: 'Shadow Style',
                tooltip: 'shadows/global.json shadow_style',
                options: const [
                  (value: 'soft_shadows', label: 'Soft Shadows'),
                  (value: 'blocky_shadows', label: 'Blocky Pixels'),
                ],
                selected: l.shadowStyle,
                isExperimental: true,
                onSelected: (style) => _updateLighting(
                  l.copyWith(shadowStyle: style),
                  recordUndo: true,
                ),
              ),
              _lightSlider(
                label: 'Orbital Tilt Angle',
                tooltip: 'directional_lights.orbital.orbital_offset_degrees (0–359.98°)',
                value: l.orbitalOffsetDegrees,
                min: 0.0,
                max: 359.98,
                unit: '°',
                decimals: 1,
                isPackWide: true,
                isExperimental: true,
                apply: (v) => l.copyWith(orbitalOffsetDegrees: v),
              ),
            ],
          ),
        if (_lightMode == 1)
          VVSectionCard(
            title: 'Cave Ambience',
            children: [
              _lightSlider(
                label: 'Cave Brightness',
                tooltip: 'ambient.illuminance (0.0–5.0 lux)',
                value: l.ambientIlluminance,
                min: 0.0,
                max: 5.0,
                unit: ' lux',
                decimals: 2,
                apply: (v) => l.copyWith(ambientIlluminance: v),
              ),
              VVColorRow(
                label: 'Cave Light Tint',
                tooltip: 'ambient.color',
                color: l.ambientColor,
                onChanged: (c) => _updateLighting(
                  l.copyWith(ambientColor: c),
                  recordUndo: true,
                ),
              ),
            ],
          ),
        if (_lightMode == 2)
          VVSectionCard(
            title: 'Block Lights',
            badge: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: kVVCard,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: pointCount > 20 ? const Color(0xFFF59E0B) : kVVBorder,
                ),
              ),
              child: Text(
                '$pointCount / 31 point-light blocks active',
                style: TextStyle(
                  color: pointCount > 20 ? const Color(0xFFFBBF24) : kVVPrimary,
                  fontSize: 10.5,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            children: [
              if (pointCount > 20) ...[
                _vvBanner(
                  message: 'High point-light count (>20) may lag mobile GPUs',
                  color: const Color(0xFFFBBF24),
                  icon: Icons.warning_amber_rounded,
                ),
                const SizedBox(height: 10),
              ],
              _BlockLightGroupRow(
                label: 'Torches',
                sceneType: VVSceneBoxType.torch,
                blockCount: LightingConfig.torchBlocks.length,
                group: l.torches,
                isSelected: _selectedLightGroup == 0,
                onSelect: () => setState(() => _selectedLightGroup = 0),
                onChanged: (g) {
                  setState(() => _selectedLightGroup = 0);
                  _updateLighting(l.copyWith(torches: g), recordUndo: true);
                },
              ),
              _BlockLightGroupRow(
                label: 'Lanterns',
                sceneType: VVSceneBoxType.lantern,
                blockCount: LightingConfig.lanternBlocks.length,
                group: l.lanterns,
                isSelected: _selectedLightGroup == 1,
                onSelect: () => setState(() => _selectedLightGroup = 1),
                onChanged: (g) {
                  setState(() => _selectedLightGroup = 1);
                  _updateLighting(l.copyWith(lanterns: g), recordUndo: true);
                },
              ),
              _BlockLightGroupRow(
                label: 'Soul Fire',
                sceneType: VVSceneBoxType.soulFire,
                blockCount: LightingConfig.soulBlocks.length +
                    (l.syncMysticToSoul ? LightingConfig.mysticBlocks.length : 0),
                group: l.soulFire,
                noteBadge: l.syncMysticToSoul ? '+3 Mystic' : null,
                isSelected: _selectedLightGroup == 2,
                onSelect: () => setState(() => _selectedLightGroup = 2),
                onChanged: (g) {
                  setState(() => _selectedLightGroup = 2);
                  _updateLighting(l.copyWith(soulFire: g), recordUndo: true);
                },
              ),
              _BlockLightGroupRow(
                label: 'Candles',
                sceneType: VVSceneBoxType.candle,
                blockCount: LightingConfig.candleBlocks.length,
                group: l.candles,
                isSelected: _selectedLightGroup == 3,
                onSelect: () => setState(() => _selectedLightGroup = 3),
                onChanged: (g) {
                  setState(() => _selectedLightGroup = 3);
                  _updateLighting(l.copyWith(candles: g), recordUndo: true);
                },
              ),
              _BlockLightGroupRow(
                label: 'Redstone',
                sceneType: VVSceneBoxType.redstone,
                blockCount: LightingConfig.redstoneBlocks.length,
                group: l.redstone,
                displayColorOverride: l.syncWarmToTorch ? l.torches.color : null,
                noteBadge: l.syncWarmToTorch ? 'Synced' : null,
                isSelected: _selectedLightGroup == 4,
                onSelect: () => setState(() => _selectedLightGroup = 4),
                onChanged: (g) {
                  setState(() => _selectedLightGroup = 4);
                  _updateLighting(l.copyWith(redstone: g), recordUndo: true);
                },
              ),
              _BlockLightGroupRow(
                label: 'End Rod',
                sceneType: VVSceneBoxType.endRod,
                blockCount: LightingConfig.endRodBlocks.length,
                group: l.endRod,
                isSelected: _selectedLightGroup == 5,
                onSelect: () => setState(() => _selectedLightGroup = 5),
                onChanged: (g) {
                  setState(() => _selectedLightGroup = 5);
                  _updateLighting(l.copyWith(endRod: g), recordUndo: true);
                },
              ),
              _BlockLightGroupRow(
                label: 'Copper',
                sceneType: VVSceneBoxType.copper,
                blockCount: LightingConfig.copperBlocks.length,
                group: l.copper,
                isSelected: _selectedLightGroup == 6,
                onSelect: () => setState(() => _selectedLightGroup = 6),
                onChanged: (g) {
                  setState(() => _selectedLightGroup = 6);
                  _updateLighting(l.copyWith(copper: g), recordUndo: true);
                },
              ),
            ],
          ),
        VVSectionCard(
          key: const Key('light_adv_section'),
          title: 'Advanced',
          collapsible: true,
          initiallyExpanded: false,
          children: [
            _lightSlider(
              label: 'Moon Brightness',
              tooltip: 'directional_lights.orbital.moon.illuminance (0.0–20.0 lux)',
              value: l.moonIlluminance,
              min: 0.0,
              max: 20.0,
              unit: ' lux',
              decimals: 2,
              apply: (v) => l.copyWith(moonIlluminance: v),
            ),
            VVColorRow(
              label: 'Moon Light Tint',
              tooltip: 'directional_lights.orbital.moon.color',
              color: l.moonColor,
              onChanged: (c) =>
                  _updateLighting(l.copyWith(moonColor: c), recordUndo: true),
            ),
            _lightSlider(
              label: 'Emissive Desaturation',
              tooltip: 'emissive.desaturation (0.0–1.0)',
              value: l.emissiveDesaturation,
              min: 0.0,
              max: 1.0,
              decimals: 2,
              apply: (v) => l.copyWith(emissiveDesaturation: v),
            ),
            VVSwitchRow(
              label: 'Sync Redstone to Torch',
              tooltip: 'Links Redstone light color to Torch color',
              value: l.syncWarmToTorch,
              onChanged: (v) => _updateLighting(
                l.copyWith(syncWarmToTorch: v),
                recordUndo: true,
              ),
            ),
            VVSwitchRow(
              label: 'Sync Sea Lantern to Soul',
              tooltip: 'Links Sea Lantern and Froglights to Soul Fire',
              value: l.syncMysticToSoul,
              onChanged: (v) => _updateLighting(
                l.copyWith(syncMysticToSoul: v),
                recordUndo: true,
              ),
            ),
            _lightSlider(
              label: 'Blocky Shadow Pixels',
              tooltip: 'shadows/global.json texel_size (1–1024)',
              value: l.shadowTexelSize.toDouble(),
              min: 1.0,
              max: 1024.0,
              divisions: 1023,
              decimals: 0,
              unit: ' px',
              apply: (v) => l.copyWith(
                shadowTexelSize: v.round().clamp(1, 1024),
              ),
            ),
            _lightSlider(
              label: 'Lightning Flash Brightness',
              tooltip: 'directional_lights.flash.illuminance (0–20,000 lux)',
              value: l.flashIlluminance,
              min: 0.0,
              max: 20000.0,
              decimals: 0,
              unit: ' lux',
              apply: (v) => l.copyWith(flashIlluminance: v),
            ),
            VVColorRow(
              label: 'Lightning Flash Color',
              tooltip: 'directional_lights.flash.color',
              color: l.flashColor,
              onChanged: (c) =>
                  _updateLighting(l.copyWith(flashColor: c), recordUndo: true),
            ),
          ],
        ),
      ],
    );
  }
}

class _BlockLightGroupRow extends StatelessWidget {
  final String label;
  final VVSceneBoxType sceneType;
  final int blockCount;
  final BlockLightGroup group;
  final Color? displayColorOverride;
  final String? noteBadge;
  final bool isSelected;
  final VoidCallback onSelect;
  final ValueChanged<BlockLightGroup> onChanged;

  const _BlockLightGroupRow({
    required this.label,
    required this.sceneType,
    required this.blockCount,
    required this.group,
    this.displayColorOverride,
    this.noteBadge,
    required this.isSelected,
    required this.onSelect,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveColor = displayColorOverride ?? group.color;
    final isLockedColor = displayColorOverride != null;
    final isPoint = group.isPointLight;
    final hexRgb = formatVVColorHex(effectiveColor);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: GestureDetector(
        onTap: onSelect,
        behavior: HitTestBehavior.opaque,
        child: VVPixelBox(
          fillColor: kVVCard,
          borderColor: isSelected ? kVVPrimary : kVVBorder,
          borderWidth: isSelected ? 1.5 : 1.1,
          step: 2.5,
          hasShadow: false,
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          child: Row(
            children: [
              GestureDetector(
                onTap: isLockedColor
                    ? onSelect
                    : () async {
                        onSelect();
                        final picked = await showVVColorPickerDialog(
                          context,
                          title: '$label Color',
                          initialColor: group.color,
                        );
                        if (picked != null) {
                          onChanged(group.copyWith(color: picked));
                        }
                      },
                child: Opacity(
                  opacity: isLockedColor ? 0.65 : 1.0,
                  child: VVPixelBox(
                    fillColor: effectiveColor,
                    borderColor: effectiveColor,
                    borderWidth: 1.5,
                    step: 2.0,
                    hasShadow: false,
                    child: SizedBox(
                      width: 38,
                      height: 38,
                      child: VVSceneArtwork(type: sceneType, color: effectiveColor),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          label,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 13.5,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          hexRgb,
                          style: const TextStyle(
                            color: Colors.white54,
                            fontFamily: 'monospace',
                            fontSize: 10.5,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        if (noteBadge != null) ...[
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                            decoration: BoxDecoration(
                              color: kVVSurface,
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(color: kVVBorder),
                            ),
                            child: Text(
                              noteBadge!,
                              style: const TextStyle(
                                color: kVVPrimary,
                                fontSize: 9,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '$blockCount blocks · ${isPoint ? 'Point Light' : 'Static'}',
                      style: const TextStyle(color: Colors.white54, fontSize: 11),
                    ),
                  ],
                ),
              ),
              Switch(
                value: isPoint,
                onChanged: (v) => onChanged(
                  group.copyWith(lightType: v ? 'point_light' : 'static_light'),
                ),
                activeThumbColor: kVVPrimary,
                activeTrackColor: kVVPrimary.withValues(alpha: 0.38),
                inactiveThumbColor: Colors.white54,
                inactiveTrackColor: kVVSurface,
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ═════════════════════════════════════════════════════════════════════════════
// TAB 3: VVFogAirTab (Tab 2)
// ═════════════════════════════════════════════════════════════════════════════

class VVFogAirTab extends StatefulWidget {
  final VVShaderConfig config;
  final VVConfigChanged onConfigChanged;

  const VVFogAirTab({
    super.key,
    required this.config,
    required this.onConfigChanged,
  });

  @override
  State<VVFogAirTab> createState() => _VVFogAirTabState();
}

class _VVFogAirTabState extends State<VVFogAirTab> {
  int _fogMode = 0; // 0 = Air Fog, 1 = Weather Fog, 2 = Underwater

  void _updateFog(FogConfig next, {required bool recordUndo}) {
    widget.onConfigChanged(
      widget.config.copyWith(fog: next),
      recordUndo: recordUndo,
    );
  }

  Widget _fogSlider({
    required String label,
    required String tooltip,
    required double value,
    required double min,
    required double max,
    String unit = '',
    int decimals = 2,
    required FogConfig Function(double v) apply,
  }) {
    final clamped = value.clamp(min, max).toDouble();
    return VVLabeledSlider(
      label: label,
      tooltip: tooltip,
      value: clamped,
      min: min,
      max: max,
      unit: unit,
      decimals: decimals,
      onChanged: (v) => _updateFog(apply(v.clamp(min, max)), recordUndo: false),
      onChangeEnd: (v) => _updateFog(apply(v.clamp(min, max)), recordUndo: true),
    );
  }

  FogConfig _withAirStart(FogConfig f, double raw) {
    final start = raw.clamp(0.05, 0.98).toDouble();
    final end = math.max(f.airFogEnd, start + 0.02).clamp(0.1, 1.0).toDouble();
    return f.copyWith(airFogStart: start, airFogEnd: end);
  }

  FogConfig _withAirEnd(FogConfig f, double raw) {
    final end = raw.clamp(0.1, 1.0).toDouble();
    final start = math.min(f.airFogStart, end - 0.02).clamp(0.05, 0.99).toDouble();
    return f.copyWith(airFogStart: start, airFogEnd: end);
  }

  FogConfig _withWeatherStart(FogConfig f, double raw) {
    final start = raw.clamp(0.05, 0.98).toDouble();
    final end = math.max(f.weatherFogEnd, start + 0.02).clamp(0.1, 1.0).toDouble();
    return f.copyWith(weatherFogStart: start, weatherFogEnd: end);
  }

  FogConfig _withWeatherEnd(FogConfig f, double raw) {
    final end = raw.clamp(0.1, 1.0).toDouble();
    final start =
        math.min(f.weatherFogStart, end - 0.02).clamp(0.05, 0.99).toDouble();
    return f.copyWith(weatherFogStart: start, weatherFogEnd: end);
  }

  Future<void> _pickFogModeColor(int idx) async {
    final f = widget.config.fog;
    final current = switch (idx) {
      1 => f.weatherFogColor,
      2 => f.waterFogColor,
      _ => f.airFogColor,
    };
    final title = switch (idx) {
      1 => 'Storm Fog Color',
      2 => 'Underwater Fog Color',
      _ => 'Air Fog Color',
    };
    final picked = await showVVColorPickerDialog(
      context,
      title: title,
      initialColor: current,
    );
    if (picked == null) return;
    final next = switch (idx) {
      1 => f.copyWith(weatherFogColor: picked),
      2 => f.copyWith(waterFogColor: picked),
      _ => f.copyWith(airFogColor: picked),
    };
    _updateFog(next, recordUndo: true);
  }

  @override
  Widget build(BuildContext context) {
    final f = widget.config.fog;

    return _vvTabListView(
      children: [
        VVFogPreviewBanner(mode: _fogMode, fog: f),
        VVSectionCard(
          title: 'Fog Type',
          children: [
            VVSceneBoxGrid(
              maxColumns: 3,
              cards: [
                VVSceneBoxCard(
                  label: 'Air Fog',
                  sceneType: VVSceneBoxType.airFog,
                  color: f.airFogColor,
                  isSelected: _fogMode == 0,
                  showHexBadge: true,
                  onTap: () => setState(() => _fogMode = 0),
                  onPickColor: () {
                    setState(() => _fogMode = 0);
                    _pickFogModeColor(0);
                  },
                ),
                VVSceneBoxCard(
                  label: 'Weather',
                  sceneType: VVSceneBoxType.weatherFog,
                  color: f.weatherFogColor,
                  isSelected: _fogMode == 1,
                  showHexBadge: true,
                  onTap: () => setState(() => _fogMode = 1),
                  onPickColor: () {
                    setState(() => _fogMode = 1);
                    _pickFogModeColor(1);
                  },
                ),
                VVSceneBoxCard(
                  label: 'Underwater',
                  sceneType: VVSceneBoxType.underwaterFog,
                  color: f.waterFogColor,
                  isSelected: _fogMode == 2,
                  showHexBadge: true,
                  onTap: () => setState(() => _fogMode = 2),
                  onPickColor: () {
                    setState(() => _fogMode = 2);
                    _pickFogModeColor(2);
                  },
                ),
              ],
            ),
          ],
        ),
        if (_fogMode == 0)
          VVSectionCard(
            title: 'Air Fog Settings',
            badge: const ExperimentalBadge(),
            children: [
              VVColorRow(
                label: 'Air Fog Color',
                tooltip: 'distance.air.fog_color',
                color: f.airFogColor,
                onChanged: (c) =>
                    _updateFog(f.copyWith(airFogColor: c), recordUndo: true),
              ),
              _fogSlider(
                label: 'Fog Start Distance',
                tooltip: 'distance.air.fog_start (0.05–0.99 render distance)',
                value: f.airFogStart,
                min: 0.05,
                max: 0.99,
                apply: (v) => _withAirStart(f, v),
              ),
              _fogSlider(
                label: 'Fog End Distance',
                tooltip: 'distance.air.fog_end (0.1–1.0 render distance)',
                value: f.airFogEnd,
                min: 0.1,
                max: 1.0,
                apply: (v) => _withAirEnd(f, v),
              ),
              _fogSlider(
                label: 'Ground Mist Density',
                tooltip: 'volumetric.density.air.max_density (0.002–0.25)',
                value: f.volumetricMaxDensity,
                min: 0.002,
                max: 0.25,
                decimals: 3,
                apply: (v) => f.copyWith(volumetricMaxDensity: v),
              ),
            ],
          ),
        if (_fogMode == 1)
          VVSectionCard(
            title: 'Weather & Rain Fog',
            badge: const ExperimentalBadge(),
            children: [
              VVColorRow(
                label: 'Storm Fog Color',
                tooltip: 'distance.weather.fog_color',
                color: f.weatherFogColor,
                onChanged: (c) =>
                    _updateFog(f.copyWith(weatherFogColor: c), recordUndo: true),
              ),
              _fogSlider(
                label: 'Storm Fog Start',
                tooltip: 'distance.weather.fog_start (0.05–0.99)',
                value: f.weatherFogStart,
                min: 0.05,
                max: 0.99,
                apply: (v) => _withWeatherStart(f, v),
              ),
              _fogSlider(
                label: 'Storm Fog End',
                tooltip: 'distance.weather.fog_end (0.1–1.0 render distance)',
                value: f.weatherFogEnd,
                min: 0.1,
                max: 1.0,
                apply: (v) => _withWeatherEnd(f, v),
              ),
            ],
          ),
        if (_fogMode == 2)
          VVSectionCard(
            title: 'Underwater Fog',
            children: [
              VVColorRow(
                label: 'Water Fog Color',
                tooltip: 'distance.water.fog_color',
                color: f.waterFogColor,
                onChanged: (c) =>
                    _updateFog(f.copyWith(waterFogColor: c), recordUndo: true),
              ),
              _fogSlider(
                label: 'Underwater View Distance',
                tooltip: 'distance.water.fog_end (12–120 blocks)',
                value: f.waterFogEnd,
                min: 12.0,
                max: 120.0,
                decimals: 0,
                unit: ' blocks',
                apply: (v) => f.copyWith(waterFogEnd: v),
              ),
              _fogSlider(
                label: 'Cave Water Clarity',
                tooltip: 'Clears dark underwater absorption in caves (0.0–1.0)',
                value: f.caveWaterVisibility,
                min: 0.0,
                max: 1.0,
                apply: (v) => f.copyWith(caveWaterVisibility: v),
              ),
            ],
          ),
        VVSectionCard(
          key: const Key('fog_adv_section'),
          title: 'Advanced',
          collapsible: true,
          initiallyExpanded: false,
          children: [
            VVColorRow(
              label: 'Air Scatter Tint',
              tooltip: 'volumetric.media_coefficients.air.scattering',
              color: f.hazeScatteringColor,
              onChanged: (c) => _updateFog(
                f.copyWith(hazeScatteringColor: c),
                recordUndo: true,
              ),
            ),
            _fogSlider(
              label: 'Fog Top Height',
              tooltip: 'volumetric.density.air.zero_density_height (50–320 blocks)',
              value: f.volumetricZeroDensityHeight,
              min: 50.0,
              max: 320.0,
              decimals: 0,
              unit: ' blocks',
              apply: (v) => f.copyWith(volumetricZeroDensityHeight: v),
            ),
            _fogSlider(
              label: 'Fog Base Height',
              tooltip: 'volumetric.density.air.max_density_height (-64–200 blocks)',
              value: f.volumetricMaxDensityHeight,
              min: -64.0,
              max: 200.0,
              decimals: 0,
              unit: ' blocks',
              apply: (v) => f.copyWith(volumetricMaxDensityHeight: v),
            ),
            _fogSlider(
              label: 'Water Volume Density',
              tooltip: 'volumetric.density.water.max_density (0.002–0.08)',
              value: f.underwaterVolumeDensity,
              min: 0.002,
              max: 0.08,
              decimals: 3,
              apply: (v) => f.copyWith(underwaterVolumeDensity: v),
            ),
          ],
        ),
      ],
    );
  }
}

// ═════════════════════════════════════════════════════════════════════════════
// TAB 4: VVWaterTab (Tab 3)
// ═════════════════════════════════════════════════════════════════════════════

class VVWaterTab extends StatefulWidget {
  final VVShaderConfig config;
  final VVConfigChanged onConfigChanged;

  const VVWaterTab({
    super.key,
    required this.config,
    required this.onConfigChanged,
  });

  @override
  State<VVWaterTab> createState() => _VVWaterTabState();
}

class _VVWaterTabState extends State<VVWaterTab> {
  int _selectedPresetIdx = 0;

  static const List<({int value, String label, VVSceneBoxType scene, Color color})> _presets = [
    (value: 0, label: 'Tropical', scene: VVSceneBoxType.waterTropical, color: Color(0xFF22D3EE)),
    (value: 1, label: 'Ocean', scene: VVSceneBoxType.waterOcean, color: Color(0xFF0EA5E9)),
    (value: 2, label: 'Deep Ocean', scene: VVSceneBoxType.waterDeepOcean, color: Color(0xFF1E40AF)),
    (value: 3, label: 'River', scene: VVSceneBoxType.waterRiver, color: Color(0xFF38BDF8)),
    (value: 4, label: 'Swamp', scene: VVSceneBoxType.waterSwamp, color: Color(0xFF4D7C0F)),
  ];

  WaterPresetConfig _currentPreset(VVShaderConfig cfg) {
    return switch (_selectedPresetIdx) {
      1 => cfg.waterOcean,
      2 => cfg.waterDeepOcean,
      3 => cfg.waterRiver,
      4 => cfg.waterSwamp,
      _ => cfg.waterTropical,
    };
  }

  void _updateWaterGlobal(
    WaterGlobalSettings nextGlobal, {
    required bool recordUndo,
  }) {
    final cfg = widget.config;
    WaterPresetConfig sync(WaterPresetConfig p) => p.copyWith(
          wavesEnabled: nextGlobal.wavesEnabled,
          causticsEnabled: nextGlobal.causticsEnabled,
          causticsFrameLength: nextGlobal.causticsFrameLength,
          causticsPower: nextGlobal.causticsPower,
          causticsScale: nextGlobal.causticsScale,
        );
    widget.onConfigChanged(
      cfg.copyWith(
        waterGlobal: nextGlobal,
        waterTropical: sync(cfg.waterTropical),
        waterOcean: sync(cfg.waterOcean),
        waterDeepOcean: sync(cfg.waterDeepOcean),
        waterRiver: sync(cfg.waterRiver),
        waterSwamp: sync(cfg.waterSwamp),
      ),
      recordUndo: recordUndo,
    );
  }

  void _updateSelectedPreset(
    WaterPresetConfig nextPreset, {
    required bool recordUndo,
  }) {
    final cfg = widget.config;
    final nextCfg = switch (_selectedPresetIdx) {
      1 => cfg.copyWith(waterOcean: nextPreset),
      2 => cfg.copyWith(waterDeepOcean: nextPreset),
      3 => cfg.copyWith(waterRiver: nextPreset),
      4 => cfg.copyWith(waterSwamp: nextPreset),
      _ => cfg.copyWith(waterTropical: nextPreset),
    };
    widget.onConfigChanged(nextCfg, recordUndo: recordUndo);
  }

  Widget _globalSlider({
    required String label,
    required String tooltip,
    required double value,
    required double min,
    required double max,
    int? divisions,
    int decimals = 2,
    required WaterGlobalSettings Function(double v) apply,
  }) {
    final clamped = value.clamp(min, max).toDouble();
    return VVLabeledSlider(
      label: label,
      tooltip: tooltip,
      value: clamped,
      min: min,
      max: max,
      divisions: divisions,
      decimals: decimals,
      isPackWide: true,
      onChanged: (v) =>
          _updateWaterGlobal(apply(v.clamp(min, max)), recordUndo: false),
      onChangeEnd: (v) =>
          _updateWaterGlobal(apply(v.clamp(min, max)), recordUndo: true),
    );
  }

  Widget _presetSlider({
    required String label,
    required String tooltip,
    required double value,
    required double min,
    required double max,
    int? divisions,
    String unit = '',
    int decimals = 2,
    required WaterPresetConfig Function(double v) apply,
  }) {
    final clamped = value.clamp(min, max).toDouble();
    return VVLabeledSlider(
      label: label,
      tooltip: tooltip,
      value: clamped,
      min: min,
      max: max,
      divisions: divisions,
      unit: unit,
      decimals: decimals,
      onChanged: (v) =>
          _updateSelectedPreset(apply(v.clamp(min, max)), recordUndo: false),
      onChangeEnd: (v) =>
          _updateSelectedPreset(apply(v.clamp(min, max)), recordUndo: true),
    );
  }

  @override
  Widget build(BuildContext context) {
    final wg = widget.config.waterGlobal;
    final preset = _currentPreset(widget.config);
    final presetName = _presets[_selectedPresetIdx].label;
    final clarity = (1.0 - (preset.cdom / 12.0)).clamp(0.0, 1.0);

    return _vvTabListView(
      children: [
        VVWaterPreviewBanner(
          waterGlobal: wg,
          preset: preset,
          presetName: presetName,
        ),
        VVSectionCard(
          title: 'Water Biomes',
          children: [
            VVSceneBoxGrid(
              maxColumns: 5,
              cards: _presets
                  .map(
                    (opt) => VVSceneBoxCard(
                      label: opt.label,
                      sceneType: opt.scene,
                      color: opt.color,
                      isSelected: _selectedPresetIdx == opt.value,
                      onTap: () => setState(() => _selectedPresetIdx = opt.value),
                    ),
                  )
                  .toList(),
            ),
          ],
        ),
        VVSectionCard(
          title: '$presetName Water Tuning',
          children: [
            _presetSlider(
              label: 'Water Clarity',
              tooltip: '0.0 murky to 1.0 crystal clear',
              value: clarity,
              min: 0.0,
              max: 1.0,
              apply: (v) => preset.withClarity(v),
            ),
            _presetSlider(
              label: 'Biome Tint Mix',
              tooltip: 'biome_water_color_contribution (0.0–1.0)',
              value: preset.biomeWaterColorContribution,
              min: 0.0,
              max: 1.0,
              apply: (v) => preset.withTintMix(v),
            ),
            _presetSlider(
              label: 'Wave Height',
              tooltip: 'waves.depth (0.0–3.0)',
              value: preset.wavesDepth,
              min: 0.0,
              max: 3.0,
              decimals: 3,
              apply: (v) => preset.copyWith(wavesDepth: v),
            ),
            _presetSlider(
              label: 'Wave Speed',
              tooltip: 'waves.speed (0.01–10.0)',
              value: preset.wavesSpeed,
              min: 0.01,
              max: 10.0,
              apply: (v) => preset.copyWith(wavesSpeed: v),
            ),
          ],
        ),
        VVSectionCard(
          title: 'Global Water Effects',
          badge: const PackWideBadge(),
          children: [
            VVSwitchRow(
              label: 'Waves Enabled',
              tooltip: 'Animated water ripples across all biomes',
              value: wg.wavesEnabled,
              isPackWide: true,
              onChanged: (v) => _updateWaterGlobal(
                wg.copyWith(wavesEnabled: v),
                recordUndo: true,
              ),
            ),
            VVSwitchRow(
              label: 'Underwater Caustics',
              tooltip: 'Sunlight caustic webs on underwater floors',
              value: wg.causticsEnabled,
              isPackWide: true,
              onChanged: (v) => _updateWaterGlobal(
                wg.copyWith(causticsEnabled: v),
                recordUndo: true,
              ),
            ),
            _globalSlider(
              label: 'Caustics Shimmer Power',
              tooltip: 'caustics.power (1–6)',
              value: wg.causticsPower.toDouble(),
              min: 1.0,
              max: 6.0,
              divisions: 5,
              decimals: 0,
              apply: (v) => wg.copyWith(causticsPower: v.round().clamp(1, 6)),
            ),
          ],
        ),
        VVSectionCard(
          key: const Key('water_adv_section'),
          title: 'Advanced',
          collapsible: true,
          initiallyExpanded: false,
          children: [
            _vvSubgroupLabel('Global Caustics'),
            _globalSlider(
              label: 'Caustics Frame Length',
              tooltip: 'caustics.frame_length (0.01–5.0)',
              value: wg.causticsFrameLength,
              min: 0.01,
              max: 5.0,
              decimals: 4,
              apply: (v) => wg.copyWith(causticsFrameLength: v),
            ),
            _globalSlider(
              label: 'Caustics Scale',
              tooltip: 'caustics.scale (0.1–5.0)',
              value: wg.causticsScale,
              min: 0.1,
              max: 5.0,
              apply: (v) => wg.copyWith(causticsScale: v),
            ),
            _vvSubgroupLabel('$presetName Water Absorption'),
            _presetSlider(
              label: 'CDOM (Murkiness)',
              tooltip: 'particle_concentrations.cdom (0.0–15.0)',
              value: preset.cdom,
              min: 0.0,
              max: 15.0,
              apply: (v) => preset.copyWith(cdom: v),
            ),
            _presetSlider(
              label: 'Chlorophyll (Green Tint)',
              tooltip: 'particle_concentrations.chlorophyll (0.0–10.0)',
              value: preset.chlorophyll,
              min: 0.0,
              max: 10.0,
              decimals: 3,
              apply: (v) => preset.copyWith(chlorophyll: v),
            ),
            _presetSlider(
              label: 'Suspended Sediment',
              tooltip: 'particle_concentrations.suspended_sediment (0.0–300.0)',
              value: preset.suspendedSediment,
              min: 0.0,
              max: 300.0,
              apply: (v) => preset.copyWith(suspendedSediment: v),
            ),
            _vvSubgroupLabel('$presetName Wave Detail'),
            _presetSlider(
              label: 'Wave Octaves',
              tooltip: 'waves.octaves (1–30)',
              value: preset.wavesOctaves.toDouble(),
              min: 1.0,
              max: 30.0,
              divisions: 29,
              decimals: 0,
              apply: (v) => preset.copyWith(wavesOctaves: v.round().clamp(1, 30)),
            ),
            _presetSlider(
              label: 'Wave Frequency',
              tooltip: 'waves.frequency (0.01–3.0)',
              value: preset.wavesFrequency,
              min: 0.01,
              max: 3.0,
              decimals: 3,
              apply: (v) => preset.copyWith(wavesFrequency: v),
            ),
            _presetSlider(
              label: 'Wave Sample Width',
              tooltip: 'waves.sample_width (0.01–1.0)',
              value: preset.wavesSampleWidth,
              min: 0.01,
              max: 1.0,
              decimals: 3,
              apply: (v) => preset.copyWith(wavesSampleWidth: v),
            ),
            _presetSlider(
              label: 'Wave Pull',
              tooltip: 'waves.pull (-1.0–1.0)',
              value: preset.wavesPull,
              min: -1.0,
              max: 1.0,
              apply: (v) => preset.copyWith(wavesPull: v),
            ),
            _presetSlider(
              label: 'Wave Mix',
              tooltip: 'waves.mix (0.0–1.0)',
              value: preset.wavesMix,
              min: 0.0,
              max: 1.0,
              apply: (v) => preset.copyWith(wavesMix: v),
            ),
            _presetSlider(
              label: 'Frequency Scaling',
              tooltip: 'waves.frequency_scaling (0.0–2.0)',
              value: preset.wavesFrequencyScaling,
              min: 0.0,
              max: 2.0,
              apply: (v) => preset.copyWith(wavesFrequencyScaling: v),
            ),
            _presetSlider(
              label: 'Speed Scaling',
              tooltip: 'waves.speed_scaling (0.0–2.0)',
              value: preset.wavesSpeedScaling,
              min: 0.0,
              max: 2.0,
              apply: (v) => preset.copyWith(wavesSpeedScaling: v),
            ),
            _presetSlider(
              label: 'Wave Direction Step',
              tooltip: 'waves.direction_increment (0–360°)',
              value: preset.wavesDirectionIncrement.toDouble(),
              min: 0.0,
              max: 360.0,
              divisions: 360,
              decimals: 0,
              unit: '°',
              apply: (v) => preset.copyWith(
                wavesDirectionIncrement: v.round().clamp(0, 360),
              ),
            ),
            _presetSlider(
              label: 'Wave Shape',
              tooltip: 'waves.shape (1.0–10.0)',
              value: preset.wavesShape,
              min: 1.0,
              max: 10.0,
              apply: (v) => preset.copyWith(wavesShape: v),
            ),
          ],
        ),
      ],
    );
  }
}

// ═════════════════════════════════════════════════════════════════════════════
// TAB 5: VVColorMoodTab (Tab 4)
// ═════════════════════════════════════════════════════════════════════════════

class VVColorMoodTab extends StatelessWidget {
  final VVShaderConfig config;
  final VVConfigChanged onConfigChanged;

  const VVColorMoodTab({
    super.key,
    required this.config,
    required this.onConfigChanged,
  });

  static const List<({String value, String label, VVSceneBoxType scene, Color color})>
      _moodCards = [
    (value: 'dynamic', label: 'Dynamic', scene: VVSceneBoxType.moodDynamic, color: Color(0xFF38BDF8)),
    (value: 'vibrant', label: 'Vibrant', scene: VVSceneBoxType.moodVibrant, color: Color(0xFFF43F5E)),
    (value: 'savanna', label: 'Savanna', scene: VVSceneBoxType.moodSavanna, color: Color(0xFFF59E0B)),
    (value: 'frost', label: 'Frost', scene: VVSceneBoxType.moodFrost, color: Color(0xFF93C5FD)),
    (value: 'moody', label: 'Moody', scene: VVSceneBoxType.moodMoody, color: Color(0xFF64748B)),
  ];

  static const List<({String value, String label})> _operatorOptions = [
    (value: 'reinhard', label: 'Reinhard'),
    (value: 'reinhard_luma', label: 'Reinhard Luma'),
    (value: 'reinhard_luminance', label: 'Luminance'),
    (value: 'hable', label: 'Hable'),
    (value: 'aces', label: 'ACES'),
    (value: 'generic', label: 'Generic'),
  ];

  static const List<({String channel, Color color})> _rgbChannels = [
    (channel: 'R', color: Color(0xFFF87171)),
    (channel: 'G', color: Color(0xFF4ADE80)),
    (channel: 'B', color: Color(0xFF60A5FA)),
  ];

  void _updateCg(ColorGradingConfig next, {required bool recordUndo}) {
    onConfigChanged(
      config.copyWith(colorGrading: next),
      recordUndo: recordUndo,
    );
  }

  Widget _cgSlider({
    required String label,
    required String tooltip,
    required double value,
    required double min,
    required double max,
    String unit = '',
    int decimals = 2,
    bool enabled = true,
    Color accent = kVVPrimary,
    required ColorGradingConfig Function(double v) apply,
  }) {
    final clamped = value.clamp(min, max).toDouble();
    return VVLabeledSlider(
      label: label,
      tooltip: tooltip,
      value: clamped,
      min: min,
      max: max,
      unit: unit,
      decimals: decimals,
      enabled: enabled,
      accent: accent,
      onChanged: (v) => _updateCg(apply(v.clamp(min, max)), recordUndo: false),
      onChangeEnd: (v) => _updateCg(apply(v.clamp(min, max)), recordUndo: true),
    );
  }

  List<Widget> _buildRgbBandSliders({
    required String bandPrefix,
    required String jsonPrefix,
    bool enabled = true,
    required List<double> contrast,
    required List<double> gain,
    required List<double> gamma,
    required List<double> offset,
    required List<double> saturation,
    required ColorGradingConfig Function(List<double> v) setContrast,
    required ColorGradingConfig Function(List<double> v) setGain,
    required ColorGradingConfig Function(List<double> v) setGamma,
    required ColorGradingConfig Function(List<double> v) setOffset,
    required ColorGradingConfig Function(List<double> v) setSaturation,
  }) {
    List<double> replaceAt(List<double> src, int idx, double v) {
      final padded = [
        src.isNotEmpty ? src[0] : 1.0,
        src.length > 1 ? src[1] : 1.0,
        src.length > 2 ? src[2] : 1.0,
      ];
      padded[idx] = v;
      return padded;
    }

    Widget group(
      String propName,
      String jsonKey,
      List<double> values,
      double min,
      double max,
      ColorGradingConfig Function(List<double> v) setter,
    ) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _vvSubgroupLabel('$bandPrefix $propName'),
          for (var i = 0; i < 3; i++)
            _cgSlider(
              label: '$propName · ${_rgbChannels[i].channel}',
              tooltip: '$jsonPrefix.$jsonKey[${_rgbChannels[i].channel}]',
              value: values.length > i ? values[i] : 1.0,
              min: min,
              max: max,
              enabled: enabled,
              accent: _rgbChannels[i].color,
              apply: (v) => setter(replaceAt(values, i, v)),
            ),
        ],
      );
    }

    return [
      group('Contrast', 'contrast', contrast, 0.0, 4.0, setContrast),
      group('Gain', 'gain', gain, 0.0, 4.0, setGain),
      group('Gamma', 'gamma', gamma, 0.0, 4.0, setGamma),
      group('Offset', 'offset', offset, -1.0, 1.0, setOffset),
      group('Saturation', 'saturation', saturation, 0.0, 10.0, setSaturation),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final cg = config.colorGrading;

    return _vvTabListView(
      children: [
        VVColorPreviewBanner(
          colorGrading: cg,
          activeMood: config.activeMood,
        ),
        VVSectionCard(
          title: 'Visual Mood',
          children: [
            VVSceneBoxGrid(
              maxColumns: 5,
              cards: _moodCards
                  .map(
                    (m) => VVSceneBoxCard(
                      label: m.label,
                      sceneType: m.scene,
                      color: m.color,
                      isSelected: config.activeMood == m.value,
                      onTap: () {
                        final nextCg = ColorGradingConfig.forMood(
                          m.value,
                          toneMappingOperator: cg.toneMappingOperator,
                        );
                        onConfigChanged(
                          config.copyWith(activeMood: m.value, colorGrading: nextCg),
                          recordUndo: true,
                        );
                      },
                    ),
                  )
                  .toList(),
            ),
          ],
        ),
        VVSectionCard(
          title: 'Color & Tone',
          children: [
            VVChipSelector<String>(
              label: 'Tone Mapping Operator',
              tooltip: 'tone_mapping.operator (pack-wide locked)',
              options: _operatorOptions,
              selected: cg.toneMappingOperator,
              isPackWide: true,
              onSelected: (op) => _updateCg(
                cg.copyWith(toneMappingOperator: op),
                recordUndo: true,
              ),
            ),
            _cgSlider(
              label: 'Warmth (Temperature)',
              tooltip: 'color_grading.temperature (1000–15000 K)',
              value: cg.temperature,
              min: 1000.0,
              max: 15000.0,
              decimals: 0,
              unit: ' K',
              enabled: cg.temperatureEnabled,
              apply: (v) => cg.copyWith(temperature: v),
            ),
            _cgSlider(
              label: 'Saturation',
              tooltip: 'Midtones saturation (0.0–3.0)',
              value: cg.midtonesSaturationScalar,
              min: 0.0,
              max: 3.0,
              apply: (v) => cg.withScalars(midtonesSaturation: v),
            ),
            _cgSlider(
              label: 'Contrast',
              tooltip: 'Midtones contrast (0.0–4.0)',
              value: cg.midtonesContrastScalar,
              min: 0.0,
              max: 4.0,
              apply: (v) => cg.withScalars(midtonesContrast: v),
            ),
            _cgSlider(
              label: 'Brightness',
              tooltip: 'Midtones gain (0.0–4.0)',
              value: cg.midtonesGainScalar,
              min: 0.0,
              max: 4.0,
              apply: (v) => cg.withScalars(midtonesGain: v),
            ),
          ],
        ),
        VVSectionCard(
          key: const Key('color_adv_section'),
          title: 'Advanced',
          collapsible: true,
          initiallyExpanded: false,
          children: [
            VVSwitchRow(
              label: 'Color Temperature Enabled',
              tooltip: 'Enables color_grading.temperature',
              value: cg.temperatureEnabled,
              onChanged: (v) => _updateCg(
                cg.copyWith(temperatureEnabled: v),
                recordUndo: true,
              ),
            ),
            VVChipSelector<String>(
              label: 'Temperature Mode',
              tooltip: 'color_grading.temperature.type',
              options: const [
                (value: 'white_balance', label: 'White Balance'),
                (value: 'color_temperature', label: 'Color Temperature'),
              ],
              selected: cg.temperatureType,
              onSelected: (t) => _updateCg(
                cg.copyWith(temperatureType: t),
                recordUndo: true,
              ),
            ),
            const SizedBox(height: 8),
            VVSectionCard(
              title: 'Midtones RGB',
              collapsible: true,
              initiallyExpanded: false,
              children: _buildRgbBandSliders(
                bandPrefix: 'Midtones',
                jsonPrefix: 'color_grading.midtones',
                contrast: cg.midtonesContrast,
                gain: cg.midtonesGain,
                gamma: cg.midtonesGamma,
                offset: cg.midtonesOffset,
                saturation: cg.midtonesSaturation,
                setContrast: (v) => cg.copyWith(midtonesContrast: v),
                setGain: (v) => cg.copyWith(midtonesGain: v),
                setGamma: (v) => cg.copyWith(midtonesGamma: v),
                setOffset: (v) => cg.copyWith(midtonesOffset: v),
                setSaturation: (v) => cg.copyWith(midtonesSaturation: v),
              ),
            ),
            const SizedBox(height: 10),
            VVSectionCard(
              title: 'Highlights RGB',
              collapsible: true,
              initiallyExpanded: false,
              children: [
                VVSwitchRow(
                  label: 'Highlights Enabled',
                  tooltip: 'Enables color_grading.highlights',
                  value: cg.highlightsEnabled,
                  onChanged: (v) => _updateCg(
                    cg.copyWith(highlightsEnabled: v),
                    recordUndo: true,
                  ),
                ),
                _cgSlider(
                  label: 'Highlights Min',
                  tooltip: 'color_grading.highlights.highlightsMin (1.0–4.0)',
                  value: cg.highlightsMin,
                  min: 1.0,
                  max: 4.0,
                  enabled: cg.highlightsEnabled,
                  apply: (v) => cg.copyWith(highlightsMin: v),
                ),
                ..._buildRgbBandSliders(
                  bandPrefix: 'Highlights',
                  jsonPrefix: 'color_grading.highlights',
                  enabled: cg.highlightsEnabled,
                  contrast: cg.highlightsContrast,
                  gain: cg.highlightsGain,
                  gamma: cg.highlightsGamma,
                  offset: cg.highlightsOffset,
                  saturation: cg.highlightsSaturation,
                  setContrast: (v) => cg.copyWith(highlightsContrast: v),
                  setGain: (v) => cg.copyWith(highlightsGain: v),
                  setGamma: (v) => cg.copyWith(highlightsGamma: v),
                  setOffset: (v) => cg.copyWith(highlightsOffset: v),
                  setSaturation: (v) => cg.copyWith(highlightsSaturation: v),
                ),
              ],
            ),
            const SizedBox(height: 10),
            VVSectionCard(
              title: 'Shadows RGB',
              collapsible: true,
              initiallyExpanded: false,
              children: [
                VVSwitchRow(
                  label: 'Shadows Enabled',
                  tooltip: 'Enables color_grading.shadows',
                  value: cg.shadowsEnabled,
                  onChanged: (v) => _updateCg(
                    cg.copyWith(shadowsEnabled: v),
                    recordUndo: true,
                  ),
                ),
                _cgSlider(
                  label: 'Shadows Max',
                  tooltip: 'color_grading.shadows.shadowsMax (0.1–1.0)',
                  value: cg.shadowsMax,
                  min: 0.1,
                  max: 1.0,
                  enabled: cg.shadowsEnabled,
                  apply: (v) => cg.copyWith(shadowsMax: v),
                ),
                ..._buildRgbBandSliders(
                  bandPrefix: 'Shadows',
                  jsonPrefix: 'color_grading.shadows',
                  enabled: cg.shadowsEnabled,
                  contrast: cg.shadowsContrast,
                  gain: cg.shadowsGain,
                  gamma: cg.shadowsGamma,
                  offset: cg.shadowsOffset,
                  saturation: cg.shadowsSaturation,
                  setContrast: (v) => cg.copyWith(shadowsContrast: v),
                  setGain: (v) => cg.copyWith(shadowsGain: v),
                  setGamma: (v) => cg.copyWith(shadowsGamma: v),
                  setOffset: (v) => cg.copyWith(shadowsOffset: v),
                  setSaturation: (v) => cg.copyWith(shadowsSaturation: v),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }
}
