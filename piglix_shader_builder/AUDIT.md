# Comprehensive Vibrant Visuals (VV) Exporter Audit

> Generated for **Piglix Shader Builder** (Flutter / Dart)  
> Scope: Complete 8-tab controls audit against Microsoft Learn Minecraft Creator Docs & Mojang Bedrock Deferred Samples.  
> Target: Minecraft Bedrock Edition Vibrant Visuals (Deferred PBR)  
> Evidence Tags: `EXPORT` (verified in exported JSON), `DOC` (official Microsoft Learn / Mojang bedrock-samples schema), `TEST` (device test required on Vibrant Visuals runtime).

---

## 1. Executive Summary of Audit

| Total Controls Audited | `WORKS` (Compliant) | `FIX` (Action Required) | `EXPERIMENTAL` (Flagged) | Evidence Breakdown |
|:---:|:---:|:---:|:---:|:---:|
| **100 Controls & Parameters** | **93** | **0** | **7** | **EXPORT**: 89 · **DOC**: 9 · **TEST**: 2 |

### Key Findings & Implementation Verification:
1. **Tone Mapping Operator Migration**: Valid operators are `reinhard`, `reinhard_luma`, `reinhard_luminance`, `hable`, `aces`, and `generic`. Old presets auto-migrate `filmic` -> `hable` and `neutral` -> `generic`.
2. **Directional Flash**: `minecraft:lighting_settings.directional_lights.flash` is specifically the **End dimension flash**, not thunderstorm lightning. UI control named "End Flash" and preview restricted to The End dimension.
3. **PBR Fallback Array & Defaults**: `[metalness, emissive, roughness, subsurface]` written for blocks, actors, particles, and items. Default roughness is `255` (giving default `[0, 0, 255, 0]`).
4. **Fog Media Coefficients**: Hex colors are never written directly as raw scattering/absorption floats. Hue from the color picker and magnitude from density slider scale to Mojang sample ranges (`~[0.02, 0.02, 0.02]` air, `~[0.018, 0.021, 0.028]` water scattering, `~[0.2, 0.079, 0.083]` water absorption). Marked `EXPERIMENTAL`.
5. **Water Settings & Surface Tint**: `water/*.json` contains ONLY `minecraft:water_settings` fields (`description`, `particle_concentrations`, `waves`, `caustics`, `biome_water_color_contribution`). `surface_color` is written to `minecraft:water_appearance` in client biome files. `deep_color` is completely removed.
6. **Shadows Decoupling from Tiers**: `shadows/global.json` `shadow_style` ("soft_shadows" | "blocky_shadows") is a user choice that is NOT overridden by performance subpacks.
7. **Biome Sky Color Preservation**: Vanilla `sky_color` is kept intact from the sample template for Nether and The End (`the_end` `#000000`). Overworld biomes stop overriding it. Marked `EXPERIMENTAL`.
8. **Block Lights Cleanup**:
   - `minecraft:torch` is the single Bedrock id (no Java `wall_torch`).
   - `soul_torch` and `soul_lantern` may be point lights; `soul_fire`, `soul_campfire`, `crying_obsidian`, `respawn_anchor`, and `sculk_catalyst` are forced to `static_light`.
   - Area emitters (`redstone_lamp`, `copper_bulb`, `glowstone`, `sea_lantern`, `froglights`, `shroomlight`, `magma`) are `static_light` only.
   - Copper group covers `copper_torch` and `copper_lantern` with all 4 oxidation and waxed variants.
   - Candles explicitly enumerate all 17 colored candle ids.
   - All IDs validated against vanilla Bedrock catalog; disjoint light groups enforced.
9. **Time Keyframes Continuity & Normalization**: All keyframes are normalized to `"0.0"`, `"0.25"`, `"0.5"`, `"0.75"`, `"1.0"` style. Day ramps for `moon_mie_strength` (0 by day, ramping to 1 at night) and twilight keys of sun illuminance (0.35, 0.65) are fully specified. Key `"1.0"` mirrors `"0.0"`.
10. **Sun Brightness Multiplier**: Scales all sun illuminance keyframes across all daylight and dusk phases.
11. **Export Targets: Wide vs Modern**: "Wide" (`[1, 21, 120]`) vs "Modern" (`[1, 26, 0]`). Wide disables `biome_water_color_contribution` and keyframed ambient/sky.intensity.
12. **Subpack Memory Tiers**: Manifest V2 `memory_tier` values: Low `6`, Medium `12`, High `18`, Ultra `32`, Lite `1`. Root pack mirrors Low tier.

---

## 2. Complete Control Audit Matrix

### Tab 0: Sky & Time (`VVSkyTimeTab`)
| # | Control / Parameter | Target JSON File | JSON Dot-Path | Status | Evidence | Notes / Verification |
|---|---------------------|------------------|---------------|:------:|:--------:|----------------------|
| 1 | Noon Horizon Color | `atmospherics/atmospherics.json` | `minecraft:atmosphere_settings.sky_horizon_color["0.0"]` | `WORKS` | `EXPORT` | 3-element RGB `0..255`. Normalized key `"0.0"`. |
| 2 | Noon Zenith Color | `atmospherics/atmospherics.json` | `minecraft:atmosphere_settings.sky_zenith_color["0.0"]` | `WORKS` | `EXPORT` | Explicit or auto-derived from horizon. Normalized key `"0.0"`. |
| 3 | Auto Derive Zenith | UI only | `AtmosphereConfig.autoDeriveZenith` | `WORKS` | `DOC` | Calculates natural zenith saturation. |
| 4 | Sunset Horizon Color | `atmospherics/atmospherics.json` | `sky_horizon_color["0.25"]` | `WORKS` | `EXPORT` | Golden sunset horizon tint. Normalized key `"0.25"`. |
| 5 | Sunset Zenith Color | `atmospherics/atmospherics.json` | `sky_zenith_color["0.25"]` | `WORKS` | `EXPORT` | Sunset upper sky tint. Normalized key `"0.25"`. |
| 6 | Night Horizon Color | `atmospherics/atmospherics.json` | `sky_horizon_color["0.5"]` | `WORKS` | `EXPORT` | Midnight ground haze tint. Normalized key `"0.5"`. |
| 7 | Night Zenith Color | `atmospherics/atmospherics.json` | `sky_zenith_color["0.5"]` | `WORKS` | `EXPORT` | Deep space night zenith tint. Normalized key `"0.5"`. |
| 8 | Sunrise Horizon Color | `atmospherics/atmospherics.json` | `sky_horizon_color["0.75"]` | `WORKS` | `EXPORT` | Morning dawn horizon tint. Normalized key `"0.75"`. |
| 9 | Sunrise Zenith Color | `atmospherics/atmospherics.json` | `sky_zenith_color["0.75"]` | `WORKS` | `EXPORT` | Morning dawn upper sky tint. Normalized key `"0.75"`. |
| 10 | Sun Glow (Noon Mie) | `atmospherics/atmospherics.json` | `sun_mie_strength["0.0"]` | `WORKS` | `EXPORT` | Default ~1.0. Normalized key `"0.0"`. |
| 11 | Sun Glow (Sunset Mie) | `atmospherics/atmospherics.json` | `sun_mie_strength["0.25"]` | `WORKS` | `EXPORT` | Default ~3.0. Normalized key `"0.25"`. |
| 12 | Moon Glow (Moon Mie) | `atmospherics/atmospherics.json` | `moon_mie_strength["0.5"]` | `WORKS` | `EXPORT` | Day ramp: 0.0 by day, ramping up 0.25..0.35 to moonGlow, flat night, ramping down 0.64..0.74 to 0.0. |
| 13 | Horizon Haze Start (Noon) | `atmospherics/atmospherics.json` | `horizon_blend_stops.start["0.0"]` | `WORKS` | `EXPORT` | Default ~0.25. Normalized key `"0.0"`. |
| 14 | Rayleigh Scattering (Noon) | `atmospherics/atmospherics.json` | `rayleigh_strength["0.0"]` | `WORKS` | `EXPORT` | Default ~1.0. Normalized key `"0.0"`. |
| 15 | Rayleigh Scattering (Sunset) | `atmospherics/atmospherics.json` | `rayleigh_strength["0.25"]` | `WORKS` | `EXPORT` | Dusk air scattering. Normalized key `"0.25"`. |
| 16 | Rayleigh Scattering (Night) | `atmospherics/atmospherics.json` | `rayleigh_strength["0.5"]` | `WORKS` | `EXPORT` | Starlight air scattering. Normalized key `"0.5"`. |
| 17 | Rayleigh Scattering (Sunrise) | `atmospherics/atmospherics.json` | `rayleigh_strength["0.75"]` | `WORKS` | `EXPORT` | Dawn air scattering. Normalized key `"0.75"`. |
| 18 | Sun Glare Shape (Noon) | `atmospherics/atmospherics.json` | `sun_glare_shape["0.0"]` | `WORKS` | `EXPORT` | Sun disk halo size. Normalized key `"0.0"`. |
| 19 | Sun Glare Shape (Sunset) | `atmospherics/atmospherics.json` | `sun_glare_shape["0.25"]` | `WORKS` | `EXPORT` | Sunset sun disk halo size. Normalized key `"0.25"`. |
| 20 | Time Keys Continuity (`1.0`) | `atmospherics/atmospherics.json` | `*["1.0"]` | `WORKS` | `EXPORT` | Key `"1.0"` = value of `"0.0"` across all time maps for 24h continuity. |
| 21 | Blend Stops Non-monotonic | `atmospherics/atmospherics.json` | `horizon_blend_stops.*` | `WORKS` | `DOC` | Does not enforce min < start < max in validator; matches Mojang starter sample. |

---

### Tab 1: Lighting & Shadows (`VVLightShadowsTab`)
| # | Control / Parameter | Target JSON File | JSON Dot-Path | Status | Evidence | Notes / Verification |
|---|---------------------|------------------|---------------|:------:|:--------:|----------------------|
| 22 | Sunlight Brightness | `lighting/*.json` | `directional_lights.orbital.sun.illuminance` | `WORKS` | `EXPORT` | Scales ALL sun keyframes (noon, sunset, sunrise). Twilight keys (0.35, 0.65) remain 0.0 lux. |
| 23 | Noon Sunlight Color | `lighting/*.json` | `directional_lights.orbital.sun.color["0.0"]` | `WORKS` | `EXPORT` | Bright warm daylight. Normalized key `"0.0"`. |
| 24 | Sunset Sunlight Color | `lighting/*.json` | `directional_lights.orbital.sun.color["0.25"]` | `WORKS` | `EXPORT` | Golden sunset light. Normalized key `"0.25"`. |
| 25 | Night Moon Color | `lighting/*.json` | `directional_lights.orbital.moon.color["0.5"]` | `WORKS` | `EXPORT` | Cool blue moonlight. Normalized key `"0.5"`. |
| 26 | Sunrise Sunlight Color | `lighting/*.json` | `directional_lights.orbital.sun.color["0.75"]` | `WORKS` | `EXPORT` | Warm morning dawn light. Normalized key `"0.75"`. |
| 27 | Moon Light Brightness | `lighting/*.json` | `directional_lights.orbital.moon.illuminance` | `WORKS` | `EXPORT` | Ambient lunar lux (default 0.27). |
| 28 | Cave Ambient Light | `lighting/*.json` | `ambient.illuminance` | `WORKS` | `EXPORT` | Range `0..5.0`, default `0.02..0.05`. |
| 29 | Cave Ambient Color | `lighting/*.json` | `ambient.color` | `WORKS` | `EXPORT` | RGB `0..255`. |
| 30 | Shadow Darkness (sky.intensity) | `lighting/*.json` | `sky.intensity` | `WORKS` | `EXPORT` | Range `0.1..1.0`, default `1.0` (0.7 darker option). Dims indirect light & reflections. |
| 31 | Emissive Desaturation | `lighting/*.json` | `emissive.desaturation` | `WORKS` | `EXPORT` | Range `0.0..1.0` (higher = less color). Renamed from Emissive Light Boost. |
| 32 | Sun Orbit Tilt Angle | `lighting/*.json` | `directional_lights.orbital.orbital_offset_degrees` | `EXPERIMENTAL` | `DOC` | Default 3.0° (sample value), range -90°..90°. Marked Experimental. |
| 33 | End Flash Illuminance & Color | `lighting/*.json` | `directional_lights.flash` | `WORKS` | `EXPORT` | End dimension flash only. Preview restricted to The End dimension. |
| 34 | Shadow Style | `shadows/global.json` | `minecraft:shadow_settings.shadow_style` | `WORKS` | `EXPORT` | User choice ("soft_shadows" vs "blocky_shadows"), NOT overridden by performance tiers. |
| 35 | Shadow Texel Size | `shadows/global.json` | `minecraft:shadow_settings.texel_size` | `WORKS` | `EXPORT` | Default 16, int 1..1024, disabled when soft. |
| 36 | Keyframed Ambient / Sky | `lighting/*.json` | `ambient`, `sky.intensity` | `EXPERIMENTAL` | `DOC` | Supported in Modern target (1.26.0) only; Wide (1.21.80) uses static float. |

---

### Tab 2: Local Block Lights (`VVLightShadowsTab` sub-section)
| # | Control / Parameter | Target JSON File | JSON Dot-Path | Status | Evidence | Notes / Verification |
|---|---------------------|------------------|---------------|:------:|:--------:|----------------------|
| 37 | Torches Group Color & Type | `local_lighting/local_lighting.json` | `minecraft:local_light_settings["minecraft:torch"]` | `EXPERIMENTAL` | `TEST` | Single Bedrock id `minecraft:torch` (no `wall_torch`). `light_type` toggle marked Experimental. |
| 38 | Lanterns Group Color & Type | `local_lighting/local_lighting.json` | `minecraft:local_light_settings["minecraft:lantern"]` | `WORKS` | `EXPORT` | Regular lantern. `soul_lantern` strictly in Soul group. |
| 39 | Soul Group Split (Point vs Static) | `local_lighting/local_lighting.json` | `minecraft:local_light_settings` | `WORKS` | `EXPORT` | `soul_torch` & `soul_lantern` may be point_light; `soul_fire`, `soul_campfire`, `crying_obsidian`, `respawn_anchor`, `sculk_catalyst` are static_light only. |
| 40 | Candles Group Color & Type | `local_lighting/local_lighting.json` | `minecraft:local_light_settings["minecraft:*candle"]` | `WORKS` | `EXPORT` | Explicitly enumerates all 17 colored candle ids. |
| 41 | Redstone Group Color & Type | `local_lighting/local_lighting.json` | `minecraft:local_light_settings["minecraft:redstone_torch", ...]` | `WORKS` | `EXPORT` | Separate lit/unlit entries validated. `lit_redstone_lamp` static area emitter. |
| 42 | Copper Group Color & Type | `local_lighting/local_lighting.json` | `minecraft:local_light_settings["minecraft:copper_torch", ...]` | `WORKS` | `EXPORT` | Covers waxed/exposed/weathered/oxidized torches & lanterns; `copper_bulb` variants static area emitters. |
| 43 | Area Emitters Color (Static Only) | `local_lighting/local_lighting.json` | `minecraft:local_light_settings["minecraft:glowstone", ...]` | `WORKS` | `EXPORT` | Forces `static_light` only; point-light toggle disabled with informative tooltip. |
| 44 | Local Lighting Block ID Validation | `local_lighting/local_lighting.json` | Block ID keys in root map | `WORKS` | `DOC` | All block IDs validated against vanilla Bedrock catalog; Java `wall_torch` rejected; disjoint groups enforced. |

---

### Tab 3: Fog & Air (`VVFogAirTab`)
| # | Control / Parameter | Target JSON File | JSON Dot-Path | Status | Evidence | Notes / Verification |
|---|---------------------|------------------|---------------|:------:|:--------:|----------------------|
| 45 | Clear Air Fog Start / End | `fogs/*.json` | `distance.air.fog_start / fog_end` | `WORKS` | `EXPORT` | Range fractions ~0.92..1.0, type "render". |
| 46 | Clear Air Fog Color | `fogs/*.json` | `distance.air.fog_color` | `WORKS` | `EXPORT` | Hex RGB color. |
| 47 | Rain Weather Fog Start / End | `fogs/*.json` | `distance.weather.fog_start / fog_end` | `WORKS` | `EXPORT` | Type "render", start <= end. |
| 48 | Rain Weather Fog Color | `fogs/*.json` | `distance.weather.fog_color` | `WORKS` | `EXPORT` | Hex RGB color. |
| 49 | Ground Mist Density | `fogs/*.json` | `volumetric.density.air.max_density` | `WORKS` | `EXPORT` | Max density for air ground mist. |
| 50 | Air Fog Zero Density Height | `fogs/*.json` | `volumetric.density.air.zero_density_height` | `WORKS` | `EXPORT` | Non-uniform air fog gradient transition floor. |
| 51 | Air Fog Max Density Height | `fogs/*.json` | `volumetric.density.air.max_density_height` | `WORKS` | `EXPORT` | Non-uniform air fog gradient transition ceiling. |
| 52 | Air Media Scattering | `fogs/*.json` | `volumetric.media_coefficients.air.scattering` | `EXPERIMENTAL` | `EXPORT` | Scaled by density magnitude to ~[0.02, 0.02, 0.02] (never raw hex). Marked Experimental. |
| 53 | Air Media Absorption | `fogs/*.json` | `volumetric.media_coefficients.air.absorption` | `EXPERIMENTAL` | `EXPORT` | Scaled by density magnitude. Marked Experimental. |
| 54 | Water Fog Distance | `fogs/*.json` | `distance.water.fog_end` | `WORKS` | `EXPORT` | Distance type "fixed" (blocks). |
| 55 | Water Fog Color | `fogs/*.json` | `distance.water.fog_color` | `WORKS` | `EXPORT` | Hex RGB color. |
| 56 | Cave Water Visibility | `fogs/*.json` | `volumetric.density.water` & absorption | `WORKS` | `EXPORT` | Prevents pitch-black underwater caves. |
| 57 | Water Media Coefficients | `fogs/*.json` | `volumetric.media_coefficients.water` | `EXPERIMENTAL` | `EXPORT` | Clamped to Mojang sample values (~[0.018, 0.021, 0.028] scattering, ~[0.2, 0.079, 0.083] absorption). |

---

### Tab 4: Water & Oceans (`VVWaterTab`)
| # | Control / Parameter | Target JSON File | JSON Dot-Path | Status | Evidence | Notes / Verification |
|---|---------------------|------------------|---------------|:------:|:--------:|----------------------|
| 58 | Water Preset Selector | `water/*.json` | 5 preset files (`tropical`, `ocean`, `deep_ocean`, `river`, `swamp`) | `WORKS` | `EXPORT` | Per-biome water assignment. |
| 59 | Water Settings Spec Compliance | `water/*.json` | `minecraft:water_settings` keys | `WORKS` | `EXPORT` | Contains ONLY `description`, `particle_concentrations`, `waves`, `caustics`, `biome_water_color_contribution`. No surface_color or deep_color. |
| 60 | Water Surface Tint in Client Biomes | `biomes/*.client_biome.json` | `minecraft:water_appearance.surface_color` & `surface_opacity` | `WORKS` | `EXPORT` | Surface tint written to client biomes; UI indicates client_biome mapping; deep_color completely removed. |
| 61 | Water Clarity | `water/*.json` | `particle_concentrations.*` | `WORKS` | `EXPORT` | Lowers CDOM, Chlorophyll, and Sediment simultaneously. |
| 62 | CDOM (Water Tint yellow-brown) | `water/*.json` | `particle_concentrations.cdom` | `WORKS` | `EXPORT` | Range `0..15.0`. Labeled "Water Tint (yellow-brown)". |
| 63 | Chlorophyll | `water/*.json` | `particle_concentrations.chlorophyll` | `WORKS` | `EXPORT` | Range `0..10.0`. |
| 64 | Suspended Sediment | `water/*.json` | `particle_concentrations.suspended_sediment` | `WORKS` | `EXPORT` | Range `0..300.0`. |
| 65 | Biome Water Color Mix | `water/*.json` | `biome_water_color_contribution` | `WORKS` | `EXPORT` | Range `0..1.0`. Disabled in Wide target, enabled in Modern target. |
| 66 | Surface Waves Toggle | `water/*.json` | `waves.enabled` | `WORKS` | `EXPORT` | Pack-wide locked across all water files. |
| 67 | Wave Depth | `water/*.json` | `waves.depth` | `WORKS` | `EXPORT` | Range `0..3.0`, default ~1.0. |
| 68 | Wave Speed | `water/*.json` | `waves.speed` | `WORKS` | `EXPORT` | Range `0.01..10.0`. |
| 69 | Underwater Caustics Toggle | `water/*.json` | `caustics.enabled` | `WORKS` | `EXPORT` | Pack-wide locked across all water files. |
| 70 | Caustics Shimmer Power | `water/*.json` | `caustics.power` | `WORKS` | `EXPORT` | Integer `1..6`, pack-wide locked. |
| 71 | Caustics Scale | `water/*.json` | `caustics.scale` | `WORKS` | `EXPORT` | Range `0.1..5.0`. |
| 72 | Caustics Frame Length | `water/*.json` | `caustics.frame_length` | `WORKS` | `EXPORT` | Range `0.01..5.0`. |
| 73 | Advanced Wave Parameters | `water/*.json` | `waves.octaves`, `frequency`, `pull`, `mix`, etc. | `WORKS` | `EXPORT` | Octaves 1..30 int, all ranges conform to Item 17. |
| 74 | Wave Octaves Tier Overrides | `subpacks/*/water/*.json` | `waves.octaves` | `WORKS` | `EXPORT` | Overridden per tier: Low 2, Med 3, High 5, Ultra 8. |
| 75 | Caustics Tier Override (Low Off) | `subpacks/low/water/*.json` | `caustics.enabled` | `WORKS` | `EXPORT` | Disabled on Low tier for mobile performance; active on Med/High/Ultra. |

---

### Tab 5: Color & Mood (`VVColorMoodTab`)
| # | Control / Parameter | Target JSON File | JSON Dot-Path | Status | Evidence | Notes / Verification |
|---|---------------------|------------------|---------------|:------:|:--------:|----------------------|
| 76 | Tone Mapping Operator | `color_grading/*.json` | `tone_mapping.operator` | `WORKS` | `EXPORT` | Pack-wide locked. Valid operators: `reinhard`, `reinhard_luma`, `reinhard_luminance`, `hable`, `aces`, `generic`. Auto-migrates `filmic` -> `hable`, `neutral` -> `generic`. |
| 77 | Midtones Grading | `color_grading/*.json` | `color_grading.midtones.*` | `WORKS` | `EXPORT` | Contrast (0..4), Gain (0..10), Gamma (0..4), Offset (-1..1), Saturation (0..10). |
| 78 | Highlights Grading | `color_grading/*.json` | `color_grading.highlights.*` | `WORKS` | `EXPORT` | HighlightsMin (1..4) + color grading vectors. |
| 79 | Shadows Grading | `color_grading/*.json` | `color_grading.shadows.*` | `WORKS` | `EXPORT` | ShadowsMax (0.1..1.0) + color grading vectors. |
| 80 | White Balance / Temperature | `color_grading/*.json` | `color_grading.temperature` | `WORKS` | `EXPORT` | Range 1000..15000, `enabled: true`, type `color_temperature` / `white_balance`. |

---

### Tab 6: Biomes & Weather (`VVBiomesTab`)
| # | Control / Parameter | Target JSON File | JSON Dot-Path | Status | Evidence | Notes / Verification |
|---|---------------------|------------------|---------------|:------:|:--------:|----------------------|
| 81 | 3-Layer Override Cascade | `biomes/*.client_biome.json` | Global -> Group -> Single Biome | `WORKS` | `EXPORT` | Clean inheritance tree. |
| 82 | Vanilla Biomes Dynamic Coverage | `biomes/*.client_biome.json` | All vanilla biome files dynamically copied from sample (89 biomes) | `WORKS` | `EXPORT` | Takes count dynamically from vanilla sample (89 biomes, including sulfur_caves & dappled_forest). |
| 83 | Client Biome Preservation | `biomes/*.client_biome.json` | Sounds, music, grass/foliage maps preserved | `WORKS` | `EXPORT` | Only overwrites VV identifiers and user overrides. |
| 84 | Biome Sky Color Preservation | `biomes/*.client_biome.json` | `minecraft:sky_color.sky_color` | `EXPERIMENTAL` | `TEST` | Vanilla sky_color preserved for Nether and End (`the_end` #000000); not overridden for Overworld. Marked Experimental. |
| 85 | Per-Biome Fog Assignment | `biomes/*.client_biome.json` | `minecraft:fog_appearance.fog_identifier` | `WORKS` | `EXPORT` | Correctly references pack fog JSON identifiers with pack slug namespace. |
| 86 | Per-Biome Water Assignment | `biomes/*.client_biome.json` | `minecraft:water_identifier.water_identifier` | `WORKS` | `EXPORT` | Correctly references pack water JSON identifiers with pack slug namespace. |
| 87 | Biome List Version Tracking | Config & Manifest | `biomeListVersion` | `WORKS` | `DOC` | Warns if game adds newer biomes not in catalog. |

---

### Tab 7: Surface & PBR (`VVSurfaceTab`)
| # | Control / Parameter | Target JSON File | JSON Dot-Path | Status | Evidence | Notes / Verification |
|---|---------------------|------------------|---------------|:------:|:--------:|----------------------|
| 88 | Global Roughness | `pbr/global.json` | `minecraft:pbr_fallback_settings.*[2]` | `WORKS` | `EXPORT` | Default roughness is `255` (matte `[0, 0, 255, 0]`). |
| 89 | Global Metalness | `pbr/global.json` | `minecraft:pbr_fallback_settings.*[0]` | `WORKS` | `EXPORT` | Default `0`, range `0..255`. |
| 90 | Global Emissive | `pbr/global.json` | `minecraft:pbr_fallback_settings.*[1]` | `WORKS` | `EXPORT` | Default `0`, range `0..255`. |
| 91 | Global Subsurface | `pbr/global.json` | `minecraft:pbr_fallback_settings.*[3]` | `WORKS` | `EXPORT` | Fallback array order `[metalness, emissive, roughness, subsurface]` for blocks, actors, particles, items. |
| 92 | PBR Texture Sets per Tier | `subpacks/*/textures/` | `*_texture_set.json` | `WORKS` | `EXPORT` | High and Ultra subpacks include normal/height texture sets; Low/Med omit them. |

---

### Tab 8: Performance & Export (`VVPerformanceTab` & `VVExportTab`)
| # | Control / Parameter | Target JSON File | JSON Dot-Path | Status | Evidence | Notes / Verification |
|---|---------------------|------------------|---------------|:------:|:--------:|----------------------|
| 93 | Export Target (Wide vs Modern) | `manifest.json` & headers | `min_engine_version`, file `format_version` | `WORKS` | `EXPORT` | Wide (`[1, 21, 120]`) vs Modern (`[1, 26, 0]`) selection. |
| 94 | Subpack Memory Tiers | `manifest.json` | `subpacks[].memory_tier` | `WORKS` | `DOC` | Values: Low 6, Medium 12, High 18, Ultra 32, Lite 1; base pack is Low tier. Rejects manifest V3 memory_performance_tier. |
| 95 | All Quality Modes Export | `.mcpack` zip archive | `subpacks/low`, `medium`, `high`, `ultra` | `WORKS` | `EXPORT` | Multi-tier hardware selector with diff-only subpack overlays. |
| 96 | Lite Style Export | `.mcpack` zip archive | `subpacks/lite` | `WORKS` | `EXPORT` | Subtle contrast and softened fog subpack overlay option. |
| 97 | Live Performance Score | UI display | `PerformanceScore` & warnings | `WORKS` | `DOC` | Evaluates point-light count, octaves, fog density, etc. |
| 98 | Pack Manifest Identity | `manifest.json` | `format_version: 2`, `capabilities: ["pbr"]`, fresh UUIDs | `WORKS` | `EXPORT` | Standard Bedrock format with valid V4 UUIDs. |
| 99 | Pre-Export Validator | UI & compilation | `validateConfig` & `validateArchive` | `WORKS` | `EXPORT` | Blocks invalid ranges and broken invariants before file write. |
| 100 | Preset & Migration Engine | Config deserializer | `migrateFromLegacy`, `migrateFromShaderPreset` | `WORKS` | `DOC` | Drops legacy keys with snackbar notice. |
