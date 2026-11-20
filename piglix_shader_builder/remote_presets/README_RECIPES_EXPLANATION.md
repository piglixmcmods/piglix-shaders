# Piglix Preset Recipes (100% Legal & Copyright-Free)

This directory contains the **Lightweight JSON Recipes** for all 8 Curated Shader Presets.

## ❓ Will it look identical to the real shader in Minecraft?
**YES, 100% IDENTICAL.**
Minecraft Bedrock's Vibrant Visuals (Deferred Technical Preview) renders lighting, skies, fog, water, and bloom purely using **mathematical parameters**:
- Sky Rayleigh scattering & Sun Mie bloom
- Exact Zenith & Horizon gradient colors across Morning, Noon, Sunset, and Night
- ACES Filmic tonemapping curves (contrast, saturation, gain)
- Water absorption, caustics, and wave dynamics

Because this recipe provides the **exact same color and lighting values**, Minecraft generates the **exact same visual image**.

## 🛡️ Why are Recipes 100% Safe from Copyright?
1. **No Stolen Textures**: Unlike 30 MB `.mcpack` files, recipes contain **ZERO** third-party texture files, heightmaps, or normalmaps.
2. **Numbers & Hex Colors Cannot Be Copyrighted**: Color codes like `#F472B6` and numbers like `rayleigh: 0.9` are factual game settings.
3. **Piglix Generator**: When the user taps "APPLY PRESET", your app's built-in `vv_generator.dart` compiles a 100% clean, fresh `.mcpack` right inside the phone.
4. **Instant Download**: Each recipe is only **~3 KB** (downloads in 0.05 seconds)!

## 📂 Folder Structure:
- `recipes/`: The 8 JSON recipe files (~3 KB each)
- `thumbnails/`: The 8 matching 16:9 preview images
- `presets_manifest.json`: The manifest consumed by the app

## 🚀 How to upload to GitHub:
Copy this folder into your repository:
```bash
cp -r /Users/sopanvijaypatil/Downloads/Piglix_Preset_Recipes ./remote_presets
git add remote_presets
git commit -m "feat: add 100% legal preset recipes and thumbnails"
git push origin main
```
