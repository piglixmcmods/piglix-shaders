# Piglix Vibrant Visuals — Device Test Checklist

Manual verification checklist for exported `.mcpack` packs in **Minecraft Bedrock Edition (1.21.120+)**.

## 1. Installation & Graphics Setup
- [ ] Export a test `.mcpack` from the **Export** tab (with **Export all 4 quality tiers** enabled and optional **Style Intensity: Lite** tested separately).
- [ ] Import the `.mcpack` into Minecraft Bedrock (*Settings → Storage* or open directly from Downloads / "Open with Minecraft").
- [ ] Go to **Settings → Global Resources → My Packs**, activate the pack, and move it to the **very top** of **Active** packs so its per-biome files override vanilla defaults.
- [ ] Confirm **Settings → Video → Graphics Mode** is set to **Vibrant Visuals**.
- [ ] Apply recommended in-game Video settings (Bloom **ON**, Brightness/Gamma **~50%**, Upscaling **TAAU**).

## 2. Subpack Performance Tiers (Gear Icon)
- [ ] Tap the **Gear** icon on the active pack in Global Resources and confirm all configured tiers appear (`Low`, `Medium`, `High`, `Ultra`, plus `Style Intensity: Lite` if enabled).
- [ ] Switch to **Low**: confirm waves are disabled, shadows are blocky, and fewer/no real-time point lights cast shadows.
- [ ] Switch to **High**: confirm waves animate smoothly, caustics appear underwater, and soft shadows + PBR surfaces are enabled.
- [ ] Switch to **Ultra**: confirm all enabled point-light block groups cast real-time shadows and higher wave octaves run cleanly.

## 3. Time-of-Day Keyframe & Sky Verification (*Experimental*)
- [ ] `/time set noon` (`0.0`): verify **Noon** sky zenith/horizon colors, sun glow/glare, and scattering strength match expectations.
- [ ] `/time set sunset` (`0.25`): verify smooth transition into **Sunset** sky, sun color, and horizon haze.
- [ ] `/time set midnight` (`0.5`): verify **Night** sky darkness, moon illuminance slider effect, and moon glow Halo (`moon_mie_strength`).
- [ ] `/time set sunrise` (`0.75`): verify **Sunrise** warmth and haze transitions smoothly without popping.
- [ ] Test **Orbital Tilt Angle** (`orbital_offset_degrees`): verify directional sun/moon shadow angle changes as configured (Pack-wide).

## 4. Lighting, Shadows & Local Block Lights
- [ ] Place blocks from multiple configured groups (**Torch**, **Lantern**, **Soul Torch/Lantern**, **Candle**, **Redstone Torch/Lamp**, **End Rod**, **Copper Bulb**) inside a dark enclosed room and confirm configured hex colors and `point_light` vs `static_light` behavior.
- [ ] Check an unlit sealed cave at `y = 0` and verify **Cave Ambient Light** (`ambientIlluminance` + `ambientColor`) illuminates safely without crushing to black.
- [ ] Verify **Shadow Style** (`soft_shadows` vs `blocky_shadows`) and **Shadow Darkness** (`sky.intensity`).

## 5. Fog, Water & Underwater Visibility
- [ ] Check clear Overworld air distance haze and rain weather fog (`/weather rain`).
- [ ] Submerge in Ocean / River / Tropical / Swamp water: confirm water presets, surface opacity, clarity (`CDOM` / `Chlorophyll` / `Sediment`), wave motion, and caustics shimmer power (`1..6`).
- [ ] Submerge inside an underwater cave and confirm **Cave Water Visibility** keeps cave walls visible.

## 6. Biomes & Dimensions Coverage (All 87 Biomes)
- [ ] Visit **Plains** & **Forest** (global Overworld settings).
- [ ] Visit **Swamp** / **Mangrove Swamp** (Swamp water preset + biome grass/foliage).
- [ ] Visit **Ocean** & **Deep Ocean** (water preset separation).
- [ ] Visit **Cherry Grove** & **Pale Garden** (custom biome color grading / petals / fog).
- [ ] Visit **Snowy Plains** / **Ice Spikes** & **Deep Dark** (ambient & fog differences).
- [ ] Enter **The Nether** (`hell`, `crimson_forest`, `warped_forest`, `soulsand_valley`, `basalt_deltas`): verify Nether dimensions preserve Nether lighting/fog/precipitation particles instead of Overworld blue sky.
- [ ] Enter **The End** (`the_end`): verify End lighting, sky, and fog remain distinct from Overworld.

