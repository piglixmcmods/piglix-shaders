# Vibrant Visuals (VV) — Schema Validation Matrix

This document defines the definitive schema compliance, constraints, allowed value ranges, default values, target version differences, and automated test coverage for the **Piglix Shader Builder** Vibrant Visuals exporter.

---

## 1. Summary of Targets & Per-File Format Versions

| File Scope | Target: Wide (`min_engine_version [1, 21, 120]`) | Target: Modern (`min_engine_version [1, 26, 0]`) | Notes |
| :--- | :--- | :--- | :--- |
| `manifest.json` | `format_version: 2`, `min_engine_version: [1, 21, 120]` | `format_version: 2`, `min_engine_version: [1, 26, 0]` | Capabilities `["pbr"]`, fresh UUIDs per export |
| `atmospherics/atmospherics.json` | `format_version: "1.21.40"` | `format_version: "1.21.40"` | 4 time keyframes + continuity `1.000000` |
| `lighting/global.json` | `format_version: "1.21.80"` | `format_version: "1.26.0"` | Scalar ambient/sky in Wide; keyframed in Modern |
| `local_lighting/local_lighting.json`| `format_version: "1.21.80"` | `format_version: "1.21.80"` | Direct block keys without wrapper, single Bedrock ID |
| `point_lights/global.json` | `format_version: "1.21.80"` | `format_version: "1.21.80"` | Static & point-light fallback settings |
| `shadows/global.json` | `format_version: "1.21.80"` | `format_version: "1.21.80"` | Decoupled from hardware tiers |
| `pbr/global.json` | `format_version: "1.21.80"` | `format_version: "1.21.80"` | Fallback order `[m, e, r, sub]`, default roughness 255 |
| `water/*.json` | `format_version: "1.21.80"` | `format_version: "1.26.0"` | Wide disables `biome_water_color_contribution` |
| `fogs/*.json` | `format_version: "1.21.90"` | `format_version: "1.21.90"` | Render distance type "render" (air) vs "fixed" (water)|
| `color_grading/color_grading.json` | `format_version: "1.21.90"` | `format_version: "1.21.90"` | Reinhard, Reinhard Luma, Hable, ACES, Generic |
| `biomes/*.client_biome.json` | Copied from vanilla Mojang `bedrock-samples` (`1.21.120`) | Copied from vanilla Mojang `bedrock-samples` (`1.21.120`) | Preserves ambient sounds, music & non-VV tags |

---

## 2. Component-by-Component Validation Matrix

### 2.1 Manifest (`manifest.json`)
| JSON Path | Allowed Values / Types | Default / Template | Constraints & Invariants | Automated Test |
| :--- | :--- | :--- | :--- | :--- |
| `format_version` | `2` (integer) | `2` | Manifest V2 required. Manifest V3 rejected. | `test/vv_generator_test.dart: group 1 & 2` |
| `header.min_engine_version` | `[1, 21, 120]` or `[1, 26, 0]` | Per `exportTarget` | Wide vs Modern selector. | `test/vv_generator_test.dart` |
| `header.uuid` & `modules[0].uuid` | Valid RFC 4122 v4 UUID string | Freshly generated | Header & Module must have distinct, valid UUIDs. | `test/vv_generator_test.dart: Rule 19` |
| `capabilities` | `["pbr"]` | `["pbr"]` | Required for Bedrock to recognize Vibrant Visuals. | `test/vv_generator_test.dart: Rule 19` |
| `subpacks[].memory_tier` | Integers (`6`, `12`, `18`, `32`) | Low: 6, Med: 12, High: 18, Ultra: 32 | Manifest V3 `memory_performance_tier` is forbidden. | `test/vv_generator_test.dart: Rule 25` |
| `subpacks[].folder_name` | String (`"low"`, `"medium"`, `"high"`, `"ultra"`, `"lite"`) | Unique per subpack | Low mirrors base so it is physically selectable. | `test/vv_generator_test.dart: Rule 24` |

### 2.2 Atmospherics (`atmospherics/atmospherics.json`)
| JSON Path | Allowed Values / Types | Default | Constraints & Invariants | Automated Test |
| :--- | :--- | :--- | :--- | :--- |
| `sky_zenith_color` | Float RGB map: `{"0.000000": [...], "0.250000": [...], ...}` | Noon `[0.18, 0.45, 0.85]` | Must include 0.0, 0.25, 0.5, 0.75 + continuity `1.000000`. | `test/vv_generator_test.dart: Rule 12 & 13` |
| `sky_horizon_color` | Float RGB map: `{"0.000000": [...], ...}` | Noon `[0.60, 0.76, 0.96]` | Keys as normalized float strings. | `test/vv_generator_test.dart: Rule 12 & 13` |
| `sun_mie_strength` | Float map: `{"0.000000": float, ...}` | Noon `1.0`, Sunset `3.0` | Sun glare multiplier. | `test/vv_generator_test.dart: Rule 13 & 16` |
| `moon_mie_strength` | Float map: `{"0.500000": float, ...}` | Midnight `0.7` | Value $\le 1.0$. | `test/vv_generator_test.dart: Rule 13 & 16` |
| `rayleigh_strength` | Float map: `{"0.000000": float, ...}` | Noon `1.0` | Atmosphere scattering. | `test/vv_generator_test.dart: Rule 13 & 16` |
| `horizon_blend_stops` | Maps with `min`, `start`, `max` keys | Noon start `0.25` | Do NOT enforce `min < start < max` (matches Mojang sample). | `test/vv_generator_test.dart: Rule 13 & 16` |

### 2.3 Lighting Global (`lighting/global.json`)
| JSON Path | Allowed Values / Types | Default | Constraints & Invariants | Automated Test |
| :--- | :--- | :--- | :--- | :--- |
| `directional_lights.orbital.sun.illuminance` | Keyframed floats | Noon $\approx 100000 \times \text{multiplier}$ | `sunBrightnessMultiplier` must scale ALL phases. | `test/vv_generator_test.dart: Rule 14` |
| `directional_lights.orbital.orbital_offset_degrees` | Float `-90.0 .. 90.0` | `0.0` | Pack-wide locked invariant across all tiers. | `test/vv_generator_test.dart: Rule 22` |
| `directional_lights.flash` | Float RGB `[0.0..1.0, ...]` | `[0.85, 0.75, 1.0]` | The End dimension flash only; previewed only for The End. | `test/vv_generator_test.dart: Rule 3` |
| `ambient.illuminance` | Float `0.0 .. 5.0` | `0.02` (caves `0.02..0.05`) | Scalar in Wide (1.21.80); Keyframed in Modern (1.26.0). | `test/vv_generator_test.dart: Rule 15 & 16` |
| `sky.intensity` | Float `0.1 .. 1.0` | `0.55` | Scalar in Wide (1.21.80); Keyframed in Modern (1.26.0). | `test/vv_generator_test.dart: Rule 15 & 17` |
| `emissive.desaturation` | Float `0.0 .. 1.0` | `0.0` | Exact path: `minecraft:lighting_settings.emissive.desaturation`. | `test/vv_generator_test.dart: Rule 2` |

### 2.4 Local Lighting (`local_lighting/local_lighting.json`)
| JSON Path | Allowed Values / Types | Default | Constraints & Invariants | Automated Test |
| :--- | :--- | :--- | :--- | :--- |
| Direct Block IDs | Vanilla Bedrock IDs only | `minecraft:torch`, etc. | Unknown ID = export error. No Java IDs (`wall_torch` removed). | `test/vv_generator_test.dart: Rule 11` |
| Torch Point/Static | `"point_light"` or `"static_light"` | `"point_light"` | Marked **EXPERIMENTAL**. Tested via EXP-1. | `test/vv_generator_test.dart: Rule 11` |
| Area Emitters | `"static_light"` only | `"static_light"` | Lamps, bulb, glowstone, sea lantern, froglight, magma. Toggle disabled. | `test/vv_generator_test.dart: Rule 11` |
| Copper Group | All copper torch & lantern variants | Waxed / unlit / weathered | Explicitly enumerated. `copper_bulb` excluded from point lights. | `test/vv_generator_test.dart: Rule 11` |
| Candle Recolor | All 17 Bedrock candle IDs | White, orange, etc. | Explicit entry for every candle ID (no variant inheritance). | `test/vv_generator_test.dart: Rule 11` |
| Duplicate ID Check | Single group per block ID | N/A | Soul lantern belongs to Soul group only (removed from Lanterns). | `test/vv_generator_test.dart: Rule 11` |

### 2.5 Shadows (`shadows/global.json`)
| JSON Path | Allowed Values / Types | Default | Constraints & Invariants | Automated Test |
| :--- | :--- | :--- | :--- | :--- |
| `shadow_style` | `"soft_shadows"` or `"blocky_shadows"` | User preference | Shadow style is user choice, NOT tied to performance tiers. | `test/vv_generator_test.dart: Rule 9` |
| `texel_size` | Integer `1 .. 1024` | `16` (Low), `32` (Med), etc. | Effective when `blocky_shadows` is active. | `test/vv_generator_test.dart: Rule 9 & 16` |

### 2.6 Water Settings (`water/*.json`)
| JSON Path | Allowed Values / Types | Default | Constraints & Invariants | Automated Test |
| :--- | :--- | :--- | :--- | :--- |
| `caustics.enabled` & `power` | Boolean & Integer `1 .. 6` | Enabled; Power `3` | Pack-wide locked invariant across all water files of a tier. | `test/vv_generator_test.dart: Rule 4 & 22` |
| `waves.enabled` | Boolean | `true` | Pack-wide locked invariant across all water files of a tier. | `test/vv_generator_test.dart: Rule 4 & 22` |
| `particle_concentrations.cdom` | Float `0.0 .. 15.0` | Tropical `1.0` | Renamed "Water Tint (yellow-brown)" / Clarity. | `test/vv_generator_test.dart: Rule 7 & 17` |
| `particle_concentrations.chlorophyll`| Float `0.0 .. 10.0` | Ocean `1.0` | Microalgae green tint. | `test/vv_generator_test.dart: Rule 17` |
| `particle_concentrations.sediment` | Float `0.0 .. 300.0` | River `12.0` | Suspended particulates. | `test/vv_generator_test.dart: Rule 17` |
| `biome_water_color_contribution` | Float `0.0 .. 1.0` | `0.5` | Excluded when targeting Wide (schema 1.21.80). | `test/vv_generator_test.dart: Rule 17 & 18` |
| `waves.depth` | Float `0.0 .. 3.0` | `1.0` | Wave amplitude. | `test/vv_generator_test.dart: Rule 16 & 17` |
| `waves.octaves` | Integer `1 .. 30` | Med: 8, High: 16, Ultra: 28 | Tier override heuristic. | `test/vv_generator_test.dart: Rule 17 & 26` |

### 2.7 Fog Settings (`fogs/*.json`)
| JSON Path | Allowed Values / Types | Default | Constraints & Invariants | Automated Test |
| :--- | :--- | :--- | :--- | :--- |
| `distance.air.render_distance_type` | `"render"` | `"render"` | Fractions of render distance (`0.0 .. 1.0`). | `test/vv_generator_test.dart: Rule 8` |
| `distance.air.fog_start / fog_end` | Floats `0.0 .. 1.0` | Start `0.92`, End `1.0` | Constraint: `fog_start <= fog_end`. | `test/vv_generator_test.dart: Rule 8 & 16` |
| `distance.weather.render_distance_type` | `"render"` | `"render"` | Fractions of render distance. | `test/vv_generator_test.dart: Rule 8` |
| `distance.water.render_distance_type` | `"fixed"` | `"fixed"` | Measured in blocks (`0.0 .. 128.0`). | `test/vv_generator_test.dart: Rule 8` |
| `volumetric.media_coefficients.air` | Float RGB array | Hue-scaled magnitude $\approx [0.02, 0.02, 0.02]$ | Never write hex color directly; scale by density slider. | `test/vv_generator_test.dart: Rule 6` |
| `volumetric.media_coefficients.water` | Scattering & Absorption RGB | Scatter $\approx [0.018, 0.021, 0.028]$, Abs $\approx [0.2, 0.079, 0.083]$ | Conservative magnitude clamp. Marked **EXPERIMENTAL**. | `test/vv_generator_test.dart: Rule 6` |

### 2.8 Biomes (`biomes/*.client_biome.json`)
| Component / Field | Behavior / Constraints | Verification |
| :--- | :--- | :--- |
| Template Base | Cloned from Mojang `bedrock-samples` 1.21.120 resource pack | Retains `ambient_sounds`, `biome_music`, color maps. |
| Overridden Keys Only | ONLY 5 VV identifiers (`atmosphere`, `color_grading`, `lighting`, `water`, `fog_appearance`) and user overrides | All vanilla tags preserved across all 87 biomes. |
| Nether Separation | Uses `"hell"` and dedicated `hell_atmosphere`, `hell_lighting`, `fog_hell` | Nether environment completely isolated from Overworld. |
| The End Separation | Uses `"the_end"` and dedicated `end_atmosphere`, `end_lighting`, `fog_end` | The End environment completely isolated from Overworld. |
| 3-Layer Cascade | Global $\rightarrow$ Group $\rightarrow$ Single Biome | Lower layers override higher layers. |
| Catalog Versioning | Preserves extra/newer biomes with vanilla looks | Warns if game catalog is newer than preset. |

### 2.9 Color Grading (`color_grading/color_grading.json`)
| JSON Path | Allowed Values / Types | Default | Constraints & Invariants | Automated Test |
| :--- | :--- | :--- | :--- | :--- |
| `tone_mapping.operator` | `"reinhard"`, `"reinhard_luma"`, `"reinhard_luminance"`, `"hable"`, `"aces"`, `"generic"` | `"generic"` | Pack-wide locked invariant across all tiers. Old filmic/neutral migrated. | `test/vv_generator_test.dart: Rule 1 & 22` |
| `color_grading.temperature` | Integer `1000 .. 15000` | `6500` | Must write `{"enabled": true, "type": "white_balance", "temperature": N}`. | `test/vv_generator_test.dart: Rule 17` |
| `color_grading.midtones.saturation` | Float `0.0 .. 10.0` (array of 3) | `[1.0, 1.0, 1.0]` | Per-channel vector. | `test/vv_generator_test.dart: Rule 17` |
| `color_grading.midtones.contrast` | Float `0.0 .. 4.0` (array of 3) | `[1.0, 1.0, 1.0]` | Per-channel vector. | `test/vv_generator_test.dart: Rule 17` |
| `color_grading.midtones.gain` | Float `0.0 .. 10.0` (array of 3) | `[1.0, 1.0, 1.0]` | Per-channel vector. | `test/vv_generator_test.dart: Rule 17` |
| `color_grading.midtones.offset` | Float `-1.0 .. 1.0` (array of 3) | `[0.0, 0.0, 0.0]` | Per-channel vector. | `test/vv_generator_test.dart: Rule 17` |
| `color_grading.highlightsMin` | Float `1.0 .. 4.0` | `1.0` | Split-toning threshold. | `test/vv_generator_test.dart: Rule 17` |
| `color_grading.shadowsMax` | Float `0.1 .. 1.0` | `0.1` | Split-toning threshold. | `test/vv_generator_test.dart: Rule 17` |

### 2.10 PBR Settings (`pbr/global.json`)
| JSON Path | Allowed Values / Types | Default | Constraints & Invariants | Automated Test |
| :--- | :--- | :--- | :--- | :--- |
| Fallback array order | `[metalness, emissive, roughness, subsurface]` | `[0, 0, 255, 0]` | Emits roughness `255` (non-glossy matte). Emits for blocks, actors, particles, items. | `test/vv_generator_test.dart: Rule 5 & 16` |

---

## 3. Performance Score & Bandwidth Throttling Matrix

| Feature | Max Score Weight | Scoring Formula | Bandwidth / Throttling Warning Condition |
| :--- | :--- | :--- | :--- |
| **Shadows** | 25 points | `25 * (1 - (texelSize - 16) / 1008)` (Blocky) or `10 pts` (Soft) | Warn if `texelSize < 16` |
| **Volumetric Fog** | 20 points | `20 * (1 - (density - 0.002) / 0.248)` | Warn if multi-layer volumetric media enabled |
| **Point Lights** | 20 points | `20 * (1 - pointLightCount / 20)` | Warn if total active point-light blocks $> 16$ |
| **Water** | 15 points | `15 * (1 - octaves / 30)` (waves enabled) | Warn if wave octaves $> 8$ |
| **PBR Textures** | 10 points | `0` (enabled) or `10` (disabled) | Texture bandwidth warning on 2GB RAM devices |
| **Color Grading** | 10 points | `6` (complex LUT/curves) or `10` (scalar tone map) | Negligible overhead |

---

## 4. Test Suite Matrix Verification

| Test Group | Test Cases | Status |
| :--- | :--- | :--- |
| `1. All Generators (Direct Unit Tests)` | Atmospherics 1.21.40 keyframes, Lighting 1.21.80/1.26.0, Local lighting 1.21.120 direct keys, Shadows 1.21.80, Fog 1.21.90, Water 1.21.80/1.26.0, Color grading 1.21.90, PBR fallback `[m,e,r,sub]`, Biomes 3-layer cascade & dimension separation, Manifest capabilities & UUIDs. | **PASSED** (16/16) |
| `2. buildArchive End-to-End Integration` | Subpack creation, root as Low tier, pack-wide water locks, PBR textures only in High/Ultra, 87 client biomes preserved. | **PASSED** (1/1) |
| `3. Validation, Migration & Round-trip` | `validateConfig` constraints & warnings, `migrateFromLegacy` & `migrateFromShaderPreset` dropping unsupported keys, `parseVVPackFromArchive` round-trip import. | **PASSED** (3/3) |
| `4. Simple-Control JSON Diff Report` | Automated diff asserting every single Simple control in the UI mutates its documented JSON path in the exported archive. | **PASSED** (1/1) |
| **Total Automated Tests** | **50 tests across entire app suite** | **100% PASSED** |

