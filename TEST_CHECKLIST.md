# Vibrant Visuals (VV) — Device Test & Experimental Checklist

Manual verification checklist and experimental protocol for exported `.mcpack` packages in **Minecraft Bedrock Edition (1.21.120+)**.

---

## 1. Experimental Controls Verification Protocol (Rule R1)

The following controls / features involve schema additions or behaviors where Bedrock documentation is emerging or ambiguous. They must be validated against real hardware running Bedrock Vibrant Visuals:

### EXP-1: Torch Point-Light vs Static-Light Toggle (`local_lighting.json`)
- **JSON Property**: `minecraft:local_light_settings["minecraft:torch"].light_type` (`"point_light"` vs `"static_light"`)
- **Risk / Ambiguity**: Microsoft Learn Creator documentation states default point-light blocks cannot change, but the 1.21.120 schema added the `light_type` field.
- **Verification Steps**:
  1. Toggle Torch to `static_light` and export pack.
  2. Place torch in dark room.
  3. Verify whether real-time dynamic shadows from torch disappear and light behaves as static emitter, or if game engine falls back to default point light.

### EXP-2: Volumetric Fog Media Coefficients (`fogs/*.json`)
- **JSON Property**: `volumetric.media_coefficients.air.scattering` & `volumetric.media_coefficients.water.scattering / absorption`
- **Risk / Ambiguity**: Writing raw RGB floats directly from a color picker blows out volumetric rendering. Media coefficients are scaled from hue and density slider to sample magnitudes (~`[0.02, 0.02, 0.02]` air; ~`[0.018, 0.021, 0.028]` water scattering; ~`[0.2, 0.079, 0.083]` water absorption).
- **Verification Steps**:
  1. Set mist density and adjust scattering tint in Fog tab.
  2. Verify ground mist renders subtle colored volumetric haze without white-out or visual blinding.
  3. Dive into deep water and confirm water volume absorption darkens red wavelengths realistically.

### EXP-3: Keyframed Ambient & Sky Intensity (Modern vs Wide Target)
- **JSON Property**: `minecraft:lighting_settings.ambient.illuminance` and `sky.intensity` as keyframe map vs static float.
- **Risk / Ambiguity**: Keyframed ambient and sky intensity require schema `1.26.0` (Modern target). Wide target (`1.21.80`) requires static float.
- **Verification Steps**:
  1. Export with "Wide Target" (`min_engine_version [1, 21, 120]`): verify static ambient float parses without syntax errors in 1.21.120.
  2. Export with "Modern Target" (`min_engine_version [1, 26, 0]`): verify dynamic ambient keyframes change lighting brightness over time of day.

### EXP-4: Biome Sky Color in Deferred Overworld vs Nether/End
- **JSON Property**: `minecraft:client_biome.components["minecraft:sky_color"]`
- **Risk / Ambiguity**: In Deferred PBR Overworld, the sky dome is rendered by `atmospherics/atmospherics.json`. Biome `minecraft:sky_color` has no visual effect for Overworld biomes. However, Nether and End vanilla biomes (`the_end` has `#000000`) rely on their template sky_color.
- **Verification Steps**:
  1. Confirm that stopping `minecraft:sky_color` overrides for Overworld biomes produces identical visuals across all Overworld biomes.
  2. Verify that The End keeps `#000000` pitch black sky and Nether keeps its vanilla atmosphere without rendering anomalies.

### EXP-5: Memory Tier Device Auto-Selection (`manifest.json`)
- **JSON Property**: `subpacks[].memory_tier` (Low: 6, Medium: 12, High: 18, Ultra: 32)
- **Risk / Ambiguity**: Engine selects highest subpack whose tier does not exceed device memory capability.
- **Verification Steps**:
  1. Test on a 2GB/4GB Android/iOS phone: verify it defaults to Low or Medium.
  2. Test on a 16GB/32GB PC: verify it defaults to Ultra.
  3. Change tier via Gear icon in Global Resources: verify setting persists and subpack assets reload.

### EXP-6: Sun Orbit Tilt Angle (`orbital_offset_degrees`)
- **JSON Property**: `minecraft:lighting_settings.directional_lights.orbital.orbital_offset_degrees`
- **Risk / Ambiguity**: Mojang starter sample sets `3.0`. Full 0..360 range is not officially documented by Microsoft Learn; range is restricted to small angles (-90°..90°, default 3.0°).
- **Verification Steps**:
  1. Test with default 3.0° on device: verify celestial sun/moon orbital path matches vanilla Bedrock expectations.
  2. Test with 45° tilt: verify shadows and sun direction slant across the terrain accordingly.

---

## 2. General In-Game Device Test Checklist

### Installation & Graphics Setup
- [ ] Export a test `.mcpack` from the **Export** tab (with **Export all 4 quality tiers** enabled).
- [ ] Import `.mcpack` into Minecraft Bedrock (*Settings → Storage* or "Open with Minecraft").
- [ ] Go to **Settings → Global Resources → My Packs**, activate the pack, and move it to the **very top** of **Active** packs.
- [ ] Confirm **Settings → Video → Graphics Mode** is set to **Vibrant Visuals** (or Deferred Technical Preview).
- [ ] Apply recommended in-game Video settings (Bloom **ON**, Brightness/Gamma **~50%**, Upscaling **TAAU**).

### Subpack Performance Tiers (Gear Icon)
- [ ] Tap the **Gear** icon on the active pack in Global Resources and confirm all 4 tiers appear (`Low`, `Medium`, `High`, `Ultra`).
- [ ] Switch to **Low**: confirm waves are disabled, shadows are blocky, and point lights are reduced.
- [ ] Switch to **High**: confirm waves animate smoothly, caustics appear underwater, and soft shadows + PBR surfaces are enabled.
- [ ] Switch to **Ultra**: confirm point lights cast real-time shadows and max wave octaves run cleanly.

### Time-of-Day Keyframes & Sky
- [ ] `/time set noon` (`0.0`): verify Noon sky zenith/horizon colors, sun glow/glare, and scattering strength.
- [ ] `/time set sunset` (`0.25`): verify smooth transition into Sunset sky, sun color, and horizon haze.
- [ ] `/time set midnight` (`0.5`): verify Night sky darkness, moon illuminance, and moon glow halo (`moon_mie_strength`).
- [ ] `/time set sunrise` (`0.75`): verify Sunrise warmth and haze transitions smoothly without popping.
- [ ] Test **24-hour Continuity**: cycle day/night with `/gamerule dodaylightcycle true` and verify no discontinuity jump at tick 0 / noon (`1.0` -> `0.0`).
- [ ] Test **Orbital Tilt Angle** (`orbital_offset_degrees`): verify sun/moon shadow angle changes as configured.

### Lighting, Shadows & Local Block Lights
- [ ] Dark enclosed room: test **Torch**, **Lantern**, **Soul Torch/Lantern**, **Candle** (all 17 colors), **Redstone Lamp**, **End Rod**, **Copper Lantern/Torch**.
- [ ] Sealed cave at `y = 0`: verify **Cave Ambient Light** illuminates safely without crushing to pure black.
- [ ] Verify **Shadow Style** (`soft_shadows` vs `blocky_shadows`) independent of selected subpack tier.
- [ ] Verify **Shadow Texel Size** (1..1024) effect when `blocky_shadows` is active.

### Fog, Water & Underwater Visibility
- [ ] Clear Overworld air distance haze vs rain weather fog (`/weather rain`).
- [ ] Submerge in Ocean / River / Tropical / Swamp water: confirm water presets, surface tint, clarity, wave motion, and caustics shimmer power (`1..6`).
- [ ] Submerge in underwater cave and confirm **Cave Water Visibility** keeps walls visible.

### Biomes & Dimensions Coverage (All 87 Biomes)
- [ ] Visit **Plains** & **Forest** (Overworld defaults).
- [ ] Visit **Swamp** / **Mangrove Swamp** (swamp water preset + foliage).
- [ ] Visit **Ocean** & **Deep Ocean** (water preset separation).
- [ ] Visit **Cherry Grove** & **Pale Garden** (custom color grading / petals / fog).
- [ ] Visit **Snowy Plains** / **Ice Spikes** & **Deep Dark** (ambient & fog).
- [ ] Enter **The Nether** (`hell`, `crimson_forest`, `warped_forest`, `soulsand_valley`, `basalt_deltas`): verify Nether preserves custom Nether lighting/fog and no Overworld blue sky leaks.
- [ ] Enter **The End** (`the_end`): verify End lighting, sky, fog, and **End Flash** trigger.

---

## 3. Step-by-Step Bedrock Testing Procedures for Experimental Features

### EXP-1 Detailed Procedure: Torch Point vs Static Light
1. In Piglix Shader Builder:
   - Navigate to **Local Lighting** tab.
   - For `minecraft:torch`, set Light Type to `static_light` on Preset A, and `point_light` on Preset B.
2. In Minecraft:
   - Execute `/fill ~-5 ~-1 ~-5 ~5 ~5 ~5 cobblestone 0 outline` to build a dark room.
   - Place a pillar in the center: `/setblock ~ ~1 ~ stone`.
   - Place a torch on one side of the pillar.
   - **Observation with point_light**: The pillar casts a dynamic, moving shadow on the opposite wall as you move or inspect the shadows.
   - **Observation with static_light**: The light emits a smooth radial illumination gradient without a hard shadow volume cast from the pillar.
   - **Result Logging**: Record if Bedrock 1.21.120+ respects `static_light` on `minecraft:torch` or ignores it and keeps point light shadows.

### EXP-2 Detailed Procedure: Volumetric Fog Media Scattering
1. In Piglix Shader Builder:
   - In **Fog & Mist** tab, set Ground Mist Density to `0.08` and Mist Color to a distinct tint (e.g. Amber `#FFB040`).
2. In Minecraft:
   - Run `/time set sunset` and `/weather clear`.
   - Find a valley or open plain.
   - Look horizontally through low-altitude terrain.
   - **Check**: Fog volume should exhibit the warm amber scattering without obscuring close-up blocks or turning solid white.
   - Fly above the fog layer: the top boundary should smoothly feather out.

### EXP-3 Detailed Procedure: Target Version Compatibility
1. **Wide Target (1.21.120)**:
   - Export pack targeting Wide (`[1, 21, 120]`).
   - Open Minecraft Bedrock `1.21.120`. Check Settings → Creator → Enable Content Log GUI.
   - Load world. Verify no JSON schema errors appear in the Content Log for `lighting/global.json` or `water/*.json`.
2. **Modern Target (1.26.0)**:
   - Export pack targeting Modern (`[1, 26, 0]`).
   - Open Bedrock Preview `1.26.0+`.
   - Observe ambient light transitions over a 24-hour cycle (`/gamerule dodaylightcycle true`).
   - Verify ambient illumination smoothly dims from day to midnight keyframes.

### EXP-4 Detailed Procedure: The End Dimension Flash
1. In Piglix Shader Builder:
   - Go to **Atmosphere** / **Lighting** tab.
   - Adjust **End Flash** color to Violet `#C850FF`.
2. In Minecraft:
   - Run `/execute in the_end run tp @p 0 70 0`.
   - Wait for the periodic ambient dimension flash in the End sky.
   - **Check**: Sky illuminates with the configured violet tint. Overworld and Nether should NEVER trigger this flash.

---

## 4. Hardware Validation Log Template

Use this table to record test runs on physical devices:

| Date | Tester | Device Model | OS & RAM | MC Version | Auto Tier Detected | Manual Gear Override OK? | EXP Features Verified | Pass / Fail |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| YYYY-MM-DD | | e.g. Galaxy S23 | Android 14, 8GB | 1.21.120 | Medium (12) | [ ] Yes [ ] No | EXP-1, EXP-2 | [ ] Pass |
| YYYY-MM-DD | | e.g. iPhone 13 | iOS 17, 4GB | 1.21.120 | Low (6) | [ ] Yes [ ] No | EXP-1, EXP-5 | [ ] Pass |
| YYYY-MM-DD | | e.g. PC RTX 4070| Win 11, 32GB | 1.21.120 | Ultra (32) | [ ] Yes [ ] No | All EXP 1-5 | [ ] Pass |
