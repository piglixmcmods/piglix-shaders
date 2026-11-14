# Vibrant Visuals (VV) Exporter: Control & Configuration Map

> **Generated from Codebase**: Piglix Shader Builder (Flutter / Dart)  
> **Source Files**: `lib/vv_config.dart`, `lib/vv_biomes.dart`, `lib/performance_tiers.dart`, `lib/vv_generator.dart`, `lib/vv_tabs_visual.dart`, `lib/vv_tabs_world.dart`, `lib/vv_shader_editor.dart`  
> **Specification References**: Microsoft Learn Minecraft Bedrock Creator Docs & Mojang Deferred Lighting Starter Sample

---

## 1. Overview

This document provides a 1-to-1 mapping of every configuration key in the Dart model (`VVShaderConfig` and nested sub-configs) to its UI editor control, the destination JSON file in the exported `.mcpack`, the exact JSON dot-path, the data type, default value, valid range, and compliance status.

### Status Legend
- **`WORKS`**: Fully compliant with Minecraft Bedrock Creator docs and Mojang deferred samples.
- **`FIX`**: Identified in Phase 0 audit as requiring schema/value correction in Phase 1–5.
- **`EXPERIMENTAL`**: Feature or property where Bedrock documentation is ambiguous or behavior depends on preview/unreleased schema revisions. Documented in `TEST_CHECKLIST.md`.

---

## 2. Atmosphere & Sky (`AtmosphereConfig`)
*Target File*: `atmospherics/atmospherics.json` (Format Version: `1.21.40`)  
*JSON Root*: `minecraft:atmosphere_settings`

| Config Field (Dart) | UI Control (Tab 0) | Target JSON Dot-Path | Dart Type | Default | Valid Range | Status |
|---------------------|--------------------|----------------------|-----------|---------|-------------|:------:|
| `autoDeriveZenith` | Auto-derive Zenith Toggle | UI calculation only | `bool` | `true` | `true / false` | `WORKS` |
| `noonHorizon` | Noon Horizon Color | `sky_horizon_color["0.000000"]` | `Color` | `0xFF96BDEB` | RGB [0..255] | `WORKS` |
| `noonZenith` | Noon Zenith Color | `sky_zenith_color["0.000000"]` | `Color` | `0xFF4C78B8` | RGB [0..255] | `WORKS` |
| `sunsetHorizon` | Sunset Horizon Color | `sky_horizon_color["0.250000"]` | `Color` | `0xFFE07A5F` | RGB [0..255] | `WORKS` |
| `sunsetZenith` | Sunset Zenith Color | `sky_zenith_color["0.250000"]` | `Color` | `0xFF3D405B` | RGB [0..255] | `WORKS` |
| `nightHorizon` | Night Horizon Color | `sky_horizon_color["0.500000"]` | `Color` | `0xFF0A0F1D` | RGB [0..255] | `WORKS` |
| `nightZenith` | Night Zenith Color | `sky_zenith_color["0.500000"]` | `Color` | `0xFF05070E` | RGB [0..255] | `WORKS` |
| `sunriseHorizon` | Sunrise Horizon Color | `sky_horizon_color["0.750000"]` | `Color` | `0xFFF2CC8F` | RGB [0..255] | `WORKS` |
| `sunriseZenith` | Sunrise Zenith Color | `sky_zenith_color["0.750000"]` | `Color` | `0xFF6A8EAE` | RGB [0..255] | `WORKS` |
| (Time Key "1.0") | Implicit Day Continuity | `*["1.000000"]` | `(derived)` | Copy of `0.0` | 24-hr loop | `FIX` |
| `rayleighNoon` | Rayleigh Strength (Noon) | `rayleigh_strength["0.000000"]` | `double` | `1.0` | 0.0 .. 11.0 | `WORKS` |
| `rayleighSunset` | Rayleigh Strength (Sunset) | `rayleigh_strength["0.250000"]` | `double` | `3.0` | 0.0 .. 11.0 | `WORKS` |
| `rayleighNight` | Rayleigh Strength (Night) | `rayleigh_strength["0.500000"]` | `double` | `0.4` | 0.0 .. 11.0 | `WORKS` |
| `rayleighSunrise` | Rayleigh Strength (Sunrise) | `rayleigh_strength["0.750000"]` | `double` | `2.5` | 0.0 .. 11.0 | `WORKS` |
| `sunGlowNoon` | Sun Mie Glow (Noon) | `sun_mie_strength["0.000000"]` | `double` | `1.0` | 0.0 .. 10.0 | `WORKS` |
| `sunGlowSunset` | Sun Mie Glow (Sunset) | `sun_mie_strength["0.250000"]` | `double` | `3.0` | 0.0 .. 10.0 | `WORKS` |
| `sunGlowSunrise` | Sun Mie Glow (Sunrise) | `sun_mie_strength["0.750000"]` | `double` | `2.0` | 0.0 .. 10.0 | `WORKS` |
| `sunGlareNoon` | Sun Glare Shape (Noon) | `sun_glare_shape["0.000000"]` | `double` | `1.0` | 0.1 .. 10.0 | `WORKS` |
| `sunGlareSunset` | Sun Glare Shape (Sunset) | `sun_glare_shape["0.250000"]` | `double` | `1.5` | 0.1 .. 10.0 | `WORKS` |
| `sunGlareSunrise` | Sun Glare Shape (Sunrise) | `sun_glare_shape["0.750000"]` | `double` | `1.2` | 0.1 .. 10.0 | `WORKS` |
| `moonGlow` | Moon Mie Strength | `moon_mie_strength["0.500000"]` | `double` | `0.6` | 0.0 .. 1.0 | `WORKS` |
| `horizonHazeNoon` | Horizon Blend Start (Noon) | `horizon_blend_stops.start["0.000000"]` | `double` | `0.25` | 0.0 .. 1.0 | `WORKS` |
| `horizonHazeSunset` | Horizon Blend Start (Sunset) | `horizon_blend_stops.start["0.250000"]` | `double` | `0.35` | 0.0 .. 1.0 | `WORKS` |
| `horizonHazeNight` | Horizon Blend Start (Night) | `horizon_blend_stops.start["0.500000"]` | `double` | `0.15` | 0.0 .. 1.0 | `WORKS` |
| `horizonHazeSunrise` | Horizon Blend Start (Sunrise) | `horizon_blend_stops.start["0.750000"]` | `double` | `0.30` | 0.0 .. 1.0 | `WORKS` |
| `horizonHazeScale` | Horizon Blend Scale Factor | `horizon_blend_stops.min / max` | `double` | `1.0` | 0.0 .. 2.0 | `WORKS` |

---

## 3. Directional Lighting & Shadows (`LightingConfig`)
*Target Files*: `lighting/global.json`, `shadows/global.json` (Format Version: `1.21.80` / `1.26.0`)  
*JSON Root*: `minecraft:lighting_settings`, `minecraft:shadow_settings`

| Config Field (Dart) | UI Control (Tab 1) | Target JSON Dot-Path | Dart Type | Default | Valid Range | Status |
|---------------------|--------------------|----------------------|-----------|---------|-------------|:------:|
| `sunBrightnessMultiplier` | Sunlight Brightness | `directional_lights.orbital.sun.illuminance` | `double` | `1.0` | 0.0 .. 5.0 | `FIX` (scale all keys) |
| `sunColorNoon` | Noon Sunlight Color | `directional_lights.orbital.sun.color["0.000000"]` | `Color` | `0xFFFFF8EE` | RGB [0..255] | `WORKS` |
| `sunColorSunset` | Sunset Sunlight Color | `directional_lights.orbital.sun.color["0.250000"]` | `Color` | `0xFFFFB870` | RGB [0..255] | `WORKS` |
| `sunColorSunrise` | Sunrise Sunlight Color | `directional_lights.orbital.sun.color["0.750000"]` | `Color` | `0xFFFFD090` | RGB [0..255] | `WORKS` |
| `nightMoonColor` | Night Moon Color | `directional_lights.orbital.moon.color["0.500000"]` | `Color` | `0xFF90B0E0` | RGB [0..255] | `WORKS` |
| `moonIlluminance` | Moon Light Brightness | `directional_lights.orbital.moon.illuminance` | `double` | `0.25` | 0.0 .. 2.0 | `WORKS` |
| `ambientIlluminance` | Cave Ambient Light | `ambient.illuminance` | `double` | `0.04` | 0.0 .. 5.0 | `WORKS` |
| `ambientColor` | Cave Ambient Color | `ambient.color` | `Color` | `0xFFFFFFFF` | RGB [0..255] | `WORKS` |
| `skyIntensity` | Shadow Darkness | `sky.intensity` | `double` | `0.4` | 0.1 .. 1.0 | `WORKS` |
| `emissiveDesaturation` | Emissive Desaturation | `emissive.desaturation` | `double` | `0.1` | 0.0 .. 1.0 | `WORKS` |
| `orbitalOffsetDegrees` | Sun Orbit Tilt Angle | `directional_lights.orbital.orbital_offset_degrees` | `double` | `0.0` | 0.0 .. 359.98 | `WORKS` (pack-wide) |
| `flashIlluminance` | End Flash Brightness | `directional_lights.flash` | `double` | `0.0` | 0.0 .. 10.0 | `FIX` (rename & End only) |
| `flashColor` | End Flash Color | `directional_lights.flash.color` | `Color` | `0xFFE0C0FF` | RGB [0..255] | `FIX` |
| `shadowStyle` | Shadow Style | `minecraft:shadow_settings.shadow_style` | `String` | `"soft_shadows"` | `soft_shadows / blocky_shadows` | `FIX` (decouple tiers) |
| `shadowTexelSize` | Shadow Texel Size | `minecraft:shadow_settings.texel_size` | `int` | `16` | 1 .. 1024 | `WORKS` |

---

## 4. Local Block Lighting (`LightingConfig` / `BlockLightGroup`)
*Target File*: `local_lighting/local_lighting.json` (Format Version: `1.21.120`)  
*JSON Root*: `minecraft:local_light_settings`

| Config Field (Dart) | UI Control (Tab 2) | Target JSON Block IDs | Dart Type | Default Color | Default Type | Status |
|---------------------|--------------------|-----------------------|-----------|---------------|--------------|:------:|
| `torches` | Torches Group | `minecraft:torch` (single Bedrock ID) | `BlockLightGroup` | `0xFFFFB850` | `point_light` | `EXPERIMENTAL` (light_type) |
| `lanterns` | Lanterns Group | `minecraft:lantern` | `BlockLightGroup` | `0xFFFFC864` | `point_light` | `WORKS` |
| `soulFire` | Soul Fire Group | `soul_torch`, `soul_lantern`, `soul_campfire`, `soul_fire` | `BlockLightGroup` | `0xFF40C0FF` | `point_light` | `WORKS` (single group) |
| `candles` | Candles Group | All 17 `minecraft:*candle` IDs explicitly | `BlockLightGroup` | `0xFFFFE090` | `point_light` | `FIX` (explicit 17 IDs) |
| `redstone` | Redstone Group | `redstone_torch`, `lit_redstone_lamp` | `BlockLightGroup` | `0xFFFF2010` | `point_light` | `WORKS` |
| `endRod` | End Rods Group | `minecraft:end_rod` | `BlockLightGroup` | `0xFFFFF0FF` | `point_light` | `WORKS` |
| `copper` | Copper Group | `copper_torch`, `copper_lantern` (waxed/exposed/weathered/oxidized) | `BlockLightGroup` | `0xFFFFA834` | `point_light` | `FIX` (no copper_bulb) |
| (Area Emitters) | Area Emitters (Glowstone, Sea Lantern, Bulbs, Froglights, Magma) | Static emitters | `(forced static)` | (per preset) | `static_light` | `FIX` (disable point toggle) |

---

## 5. Fog & Atmosphere Volumes (`FogConfig`)
*Target Files*: `fogs/fog_overworld.json`, `fogs/fog_rain.json`, `fogs/fog_water.json` (Format Version: `1.21.90`)  
*JSON Root*: `minecraft:fog_settings`

| Config Field (Dart) | UI Control (Tab 3) | Target JSON Dot-Path | Dart Type | Default | Valid Range | Status |
|---------------------|--------------------|----------------------|-----------|---------|-------------|:------:|
| `airFogColor` | Clear Air Fog Color | `distance.air.fog_color` | `Color` | `0xFFBACCE0` | Hex RGB | `WORKS` |
| `airFogStart` | Clear Air Fog Start | `distance.air.fog_start` | `double` | `0.92` | 0.0 .. 1.0 (render) | `WORKS` |
| `airFogEnd` | Clear Air Fog End | `distance.air.fog_end` | `double` | `1.0` | 0.0 .. 1.0 (render) | `WORKS` |
| `weatherFogColor` | Rain Weather Fog Color | `distance.weather.fog_color` | `Color` | `0xFF7A889B` | Hex RGB | `WORKS` |
| `weatherFogStart` | Rain Weather Fog Start | `distance.weather.fog_start` | `double` | `0.4` | 0.0 .. 1.0 (render) | `WORKS` |
| `weatherFogEnd` | Rain Weather Fog End | `distance.weather.fog_end` | `double` | `0.85` | 0.0 .. 1.0 (render) | `WORKS` |
| `waterFogColor` | Water Fog Color | `distance.water.fog_color` | `Color` | `0xFF104060` | Hex RGB | `WORKS` |
| `waterFogEnd` | Water Fog Distance | `distance.water.fog_end` | `double` | `32.0` | 1.0 .. 128.0 (fixed) | `WORKS` |
| `volumetricMaxDensity` | Ground Mist Density | `volumetric.density.air.max_density` | `double` | `0.05` | 0.0 .. 1.0 | `WORKS` |
| `volumetricZeroDensityHeight`| Mist Dissipate Height | `volumetric.density.air.zero_density_height` | `double` | `120.0` | -64.0 .. 320.0 | `WORKS` |
| `volumetricMaxDensityHeight` | Mist Floor Height | `volumetric.density.air.max_density_height` | `double` | `62.0` | -64.0 .. 320.0 | `WORKS` |
| `hazeScatteringColor` | Air Media Scattering Tint | `volumetric.media_coefficients.air.scattering` | `Color` | `0xFFFFFFFF` | Scaled to ~[0.02, 0.02, 0.02] | `FIX` / `EXPERIMENTAL` |
| `underwaterVolumeDensity` | Underwater Fog Density | `volumetric.density.water.max_density` | `double` | `0.1` | 0.0 .. 1.0 | `WORKS` |
| `caveWaterVisibility` | Cave Water Visibility | `volumetric.density.water.uniform` & absorption | `double` | `0.3` | 0.0 .. 1.0 | `WORKS` |

---

## 6. Water Properties & Surface Waves (`WaterGlobalSettings` & `WaterPresetConfig`)
*Target Files*: `water/water_tropical.json`, `water/water_ocean.json`, `water/water_deep_ocean.json`, `water/water_river.json`, `water/water_swamp.json` (Format Version: `1.21.80` / `1.26.0`)  
*JSON Root*: `minecraft:water_settings`

| Config Field (Dart) | UI Control (Tab 4) | Target JSON Dot-Path | Dart Type | Default | Valid Range | Status |
|---------------------|--------------------|----------------------|-----------|---------|-------------|:------:|
| `wavesEnabled` | Surface Waves Toggle | `waves.enabled` | `bool` | `true` | Pack-wide locked | `WORKS` |
| `causticsEnabled` | Underwater Caustics Toggle | `caustics.enabled` | `bool` | `true` | Pack-wide locked | `WORKS` |
| `causticsPower` | Caustics Shimmer Power | `caustics.power` | `int` | `2` | 1 .. 6 (pack-wide) | `WORKS` |
| `causticsScale` | Caustics Scale | `caustics.scale` | `double` | `1.0` | 0.1 .. 5.0 | `WORKS` |
| `causticsFrameLength` | Caustics Frame Length | `caustics.frame_length` | `double` | `0.05` | 0.01 .. 5.0 | `WORKS` |
| `cdom` | Water Tint (yellow-brown) | `particle_concentrations.cdom` | `double` | `0.4` | 0.0 .. 15.0 | `FIX` (renamed label) |
| `chlorophyll` | Chlorophyll (green algae) | `particle_concentrations.chlorophyll` | `double` | `0.8` | 0.0 .. 10.0 | `WORKS` |
| `suspendedSediment` | Suspended Sediment | `particle_concentrations.suspended_sediment` | `double` | `10.0` | 0.0 .. 300.0 | `WORKS` |
| `biomeWaterColorContribution`| Biome Water Color Mix | `biome_water_color_contribution` | `double` | `0.2` | 0.0 .. 1.0 (Modern only) | `WORKS` |
| `wavesDepth` | Wave Depth | `waves.depth` | `double` | `1.0` | 0.0 .. 3.0 | `WORKS` |
| `wavesSpeed` | Wave Speed | `waves.speed` | `double` | `1.0` | 0.01 .. 10.0 | `WORKS` |
| `wavesFrequency` | Wave Frequency | `waves.frequency` | `double` | `1.0` | 0.01 .. 3.0 | `WORKS` |
| `wavesOctaves` | Wave Octaves | `waves.octaves` | `int` | `12` | 1 .. 30 | `WORKS` |
| `wavesSampleWidth` | Wave Sample Width | `waves.sample_width` | `double` | `0.1` | 0.01 .. 1.0 | `WORKS` |
| `wavesPull` | Wave Pull | `waves.pull` | `double` | `0.0` | -1.0 .. 1.0 | `WORKS` |
| `wavesMix` | Wave Mix | `waves.mix` | `double` | `0.5` | 0.0 .. 1.0 | `WORKS` |
| `wavesFrequencyScaling` | Wave Frequency Scaling | `waves.frequency_scaling` | `double` | `1.15` | 0.0 .. 2.0 | `WORKS` |
| `wavesSpeedScaling` | Wave Speed Scaling | `waves.speed_scaling` | `double` | `1.1` | 0.0 .. 2.0 | `WORKS` |
| `wavesDirectionIncrement` | Wave Direction Increment | `waves.direction_increment` | `int` | `45` | 0 .. 360 | `WORKS` |
| `wavesShape` | Wave Shape | `waves.shape` | `double` | `2.0` | 1.0 .. 10.0 | `WORKS` |

---

## 7. Color Grading & Tone Mapping (`ColorGradingConfig`)
*Target File*: `color_grading/color_grading.json` (Format Version: `1.21.90`)  
*JSON Root*: `minecraft:color_grading_settings`

| Config Field (Dart) | UI Control (Tab 5) | Target JSON Dot-Path | Dart Type | Default | Valid Range | Status |
|---------------------|--------------------|----------------------|-----------|---------|-------------|:------:|
| `toneMappingOperator` | Tone Mapping Operator | `tone_mapping.operator` | `String` | `"aces"` | `reinhard, reinhard_luma, reinhard_luminance, hable, aces, generic` | `FIX` (migrate filmic/neutral) |
| `temperatureEnabled` | White Balance Toggle | `color_grading.temperature.enabled` | `bool` | `true` | `true / false` | `WORKS` |
| `temperatureType` | White Balance Mode | `color_grading.temperature.type` | `String` | `"color_temperature"` | `color_temperature, white_balance` | `WORKS` |
| `temperature` | Color Temperature | `color_grading.temperature.value` | `double` | `6500.0` | 1000.0 .. 15000.0 | `WORKS` |
| `midtonesContrast` | Midtones Contrast | `color_grading.midtones.contrast` | `List<double>` | `[1.0, 1.0, 1.0]` | 0.0 .. 4.0 | `WORKS` |
| `midtonesGain` | Midtones Gain | `color_grading.midtones.gain` | `List<double>` | `[1.0, 1.0, 1.0]` | 0.0 .. 10.0 | `WORKS` |
| `midtonesGamma` | Midtones Gamma | `color_grading.midtones.gamma` | `List<double>` | `[1.0, 1.0, 1.0]` | 0.0 .. 4.0 | `WORKS` |
| `midtonesOffset` | Midtones Offset | `color_grading.midtones.offset` | `List<double>` | `[0.0, 0.0, 0.0]` | -1.0 .. 1.0 | `WORKS` |
| `midtonesSaturation` | Midtones Saturation | `color_grading.midtones.saturation` | `List<double>` | `[1.0, 1.0, 1.0]` | 0.0 .. 10.0 | `WORKS` |
| `highlightsEnabled` | Highlights Grading Toggle | `color_grading.highlights.enabled` | `bool` | `false` | `true / false` | `WORKS` |
| `highlightsMin` | Highlights Threshold | `color_grading.highlights.highlights_min` | `double` | `1.5` | 1.0 .. 4.0 | `WORKS` |
| `highlightsContrast` | Highlights Contrast | `color_grading.highlights.contrast` | `List<double>` | `[1.0, 1.0, 1.0]` | 0.0 .. 4.0 | `WORKS` |
| `highlightsGain` | Highlights Gain | `color_grading.highlights.gain` | `List<double>` | `[1.0, 1.0, 1.0]` | 0.0 .. 10.0 | `WORKS` |
| `highlightsGamma` | Highlights Gamma | `color_grading.highlights.gamma` | `List<double>` | `[1.0, 1.0, 1.0]` | 0.0 .. 4.0 | `WORKS` |
| `highlightsOffset` | Highlights Offset | `color_grading.highlights.offset` | `List<double>` | `[0.0, 0.0, 0.0]` | -1.0 .. 1.0 | `WORKS` |
| `highlightsSaturation` | Highlights Saturation | `color_grading.highlights.saturation` | `List<double>` | `[1.0, 1.0, 1.0]` | 0.0 .. 10.0 | `WORKS` |
| `shadowsEnabled` | Shadows Grading Toggle | `color_grading.shadows.enabled` | `bool` | `false` | `true / false` | `WORKS` |
| `shadowsMax` | Shadows Threshold | `color_grading.shadows.shadows_max` | `double` | `0.4` | 0.1 .. 1.0 | `WORKS` |
| `shadowsContrast` | Shadows Contrast | `color_grading.shadows.contrast` | `List<double>` | `[1.0, 1.0, 1.0]` | 0.0 .. 4.0 | `WORKS` |
| `shadowsGain` | Shadows Gain | `color_grading.shadows.gain` | `List<double>` | `[1.0, 1.0, 1.0]` | 0.0 .. 10.0 | `WORKS` |
| `shadowsGamma` | Shadows Gamma | `color_grading.shadows.gamma` | `List<double>` | `[1.0, 1.0, 1.0]` | 0.0 .. 4.0 | `WORKS` |
| `shadowsOffset` | Shadows Offset | `color_grading.shadows.offset` | `List<double>` | `[0.0, 0.0, 0.0]` | -1.0 .. 1.0 | `WORKS` |
| `shadowsSaturation` | Shadows Saturation | `color_grading.shadows.saturation` | `List<double>` | `[1.0, 1.0, 1.0]` | 0.0 .. 10.0 | `WORKS` |

---

## 8. Surface PBR Fallbacks (`SurfaceConfig`)
*Target File*: `pbr/global.json` (Format Version: `1.21.80`)  
*JSON Root*: `minecraft:pbr_fallback_settings`

| Config Field (Dart) | UI Control (Tab 7) | Target JSON Dot-Path | Dart Type | Default | Valid Range | Status |
|---------------------|--------------------|----------------------|-----------|---------|-------------|:------:|
| `metalness` | Global Metalness | `blocks[0], actors[0], particles[0], items[0]` | `int` | `0` | 0 .. 255 | `WORKS` |
| `emissive` | Global Emissive | `blocks[1], actors[1], particles[1], items[1]` | `int` | `0` | 0 .. 255 | `WORKS` |
| `roughness` | Global Roughness | `blocks[2], actors[2], particles[2], items[2]` | `int` | `255` | 0 .. 255 | `FIX` (default 255 matte) |
| `subsurface` | Global Subsurface | `blocks[3], actors[3], particles[3], items[3]` | `int` | `0` | 0 .. 255 | `FIX` (order [M,E,R,S]) |

---

## 9. Performance & Subpacks (`PerformanceTierConfig`)
*Target File*: `manifest.json` (Format Version: `2`)  
*JSON Root*: `subpacks[]`

| Config Field (Dart) | UI Control (Tab 8) | Manifest & Pack Property | Dart Type | Default | Valid Range / Value | Status |
|---------------------|--------------------|--------------------------|-----------|---------|---------------------|:------:|
| `activeTier` | Active Profile Preview | Performance profile selector | `PerformanceTier` | `ultra` | `low, medium, high, ultra` | `WORKS` |
| `octavesLow` | Wave Octaves (Low) | `subpacks[0]/water/*.json` | `int` | `2` | 1 .. 30 | `WORKS` |
| `octavesMedium` | Wave Octaves (Med) | `subpacks[1]/water/*.json` | `int` | `4` | 1 .. 30 | `WORKS` |
| `octavesHigh` | Wave Octaves (High) | `subpacks[2]/water/*.json` | `int` | `8` | 1 .. 30 | `WORKS` |
| `octavesUltra` | Wave Octaves (Ultra)| `subpacks[3]/water/*.json` | `int` | `12` | 1 .. 30 | `WORKS` |
| `texelLow` | Texel Size (Low) | `subpacks[0]/shadows/*.json` | `int` | `8` | 1 .. 1024 | `WORKS` |
| `texelMedium` | Texel Size (Med) | `subpacks[1]/shadows/*.json` | `int` | `16` | 1 .. 1024 | `WORKS` |
| `texelHigh` | Texel Size (High) | `subpacks[2]/shadows/*.json` | `int` | `16` | 1 .. 1024 | `WORKS` |
| `texelUltra` | Texel Size (Ultra)| `subpacks[3]/shadows/*.json` | `int` | `32` | 1 .. 1024 | `WORKS` |
| `exportAllTiers` | Export All 4 Quality Modes | `manifest.json` subpacks block | `bool` | `true` | `true / false` | `WORKS` |
| `styleIntensityLite`| Style Intensity: Lite | Separate exported `.mcpack` | `bool` | `false` | `true / false` | `WORKS` |
| (Memory Tiers) | Subpack Memory Tiers | `manifest.json` subpack `memory_tier` | `(int)` | Low:6, Med:12, High:18, Ultra:32 | Manifest V2 integers | `FIX` |
| (Export Target) | Target Architecture | `min_engine_version` | `String` | Wide `[1, 21, 120]` | Wide vs Modern `[1, 26, 0]` | `FIX` |

---

## 10. Biomes Overrides (`BiomeOverridesConfig`)
*Target Files*: `biomes/*.client_biome.json` (Format Version: `1.21.40`)  
*JSON Root*: `minecraft:client_biome.components`

| Config Field (Dart) | UI Control (Tab 6) | Target JSON Component | Dart Type | Default | Status |
|---------------------|--------------------|-----------------------|-----------|---------|:------:|
| `atmospherePreset` | Biome Atmosphere Identifier | `minecraft:atmosphere_identifier` | `String?` | `null` (inherits) | `WORKS` |
| `colorGradingPreset`| Biome Color Grading Identifier| `minecraft:color_grading_identifier` | `String?` | `null` (inherits) | `WORKS` |
| `lightingPreset` | Biome Lighting Identifier | `minecraft:lighting_identifier` | `String?` | `null` (inherits) | `WORKS` |
| `waterPreset` | Biome Water Identifier | `minecraft:water_identifier` | `String?` | `null` (inherits) | `WORKS` |
| `fogPreset` | Biome Fog Identifier | `minecraft:fog_appearance` | `String?` | `null` (inherits) | `WORKS` |
| `skyColor` | Biome Sky Color Override | `minecraft:sky_color` | `Color?` | `null` | `FIX` (remove: no effect in VV) |
| `waterSurfaceColor` | Water Surface Color Override | `minecraft:water_appearance.surface_color` | `Color?` | `null` | `WORKS` |
| `waterSurfaceOpacity`| Water Opacity Override | `minecraft:water_appearance.surface_opacity`| `double?` | `null` | `WORKS` |
| `grassColor` | Grass Color Map Override | `minecraft:grass_color` | `Color?` | `null` | `WORKS` |
| `foliageColor` | Foliage Color Map Override | `minecraft:foliage_color` | `Color?` | `null` | `WORKS` |
| `precipitationType`| Biome Precipitation Override | `minecraft:precipitation` | `String?` | `null` | `WORKS` |

