#!/bin/bash
# ══════════════════════════════════════════════════════════
# Piglix Famous Shader Pack — SEUS / BSL / Chocapic / NewbX
# All 4 built in one run, performance-optimized for mobile
# ══════════════════════════════════════════════════════════

set -e
NEWB_DIR="/Users/sopanvijaypatil/Downloads/Newb_X_Pink_Atmosphere_android/newb-source"
PACK_DIR="/Users/sopanvijaypatil/Downloads/Newb_X_Pink_Atmosphere_android/piglix-rtx-shader"
OUT_DIR="/Users/sopanvijaypatil/Downloads"
CONFIG="$NEWB_DIR/src/newb/config.h"
TOML="$NEWB_DIR/src/newb/pack_config.toml"

build_shader() {
  local name="$1"
  local filename="$2"
  local uuid_header="$3"
  local desc="$4"
  echo ""
  echo ">>> Building: $name"
  cd "$NEWB_DIR"
  bash build.sh pack -p android
  cp -R build/pack-android/renderer/* "$PACK_DIR/renderer/"
  cp -R build/pack-android/subpacks/* "$PACK_DIR/subpacks/"
  cd "$PACK_DIR"
  python3 -c "
import json, uuid as uuidlib
f='manifest.json'
data=json.load(open(f))
data['header']['uuid']='$uuid_header'
data['modules'][0]['uuid']=str(uuidlib.uuid4()).upper()
data['header']['name']='$name'
data['header']['description']='$desc'
json.dump(data, open(f,'w'), indent=2)
"
  rm -f "$OUT_DIR/$filename"
  zip -r "$OUT_DIR/$filename" . -x ".*" > /dev/null
  echo "<<< Done: $filename"
}

write_toml() {
  local name="$1"
  local uuid="$2"
  local desc_line1="$3"
  local desc_line2="$4"
  cat > "$TOML" << TOMLEOF
name = "$name"
version = [1, 0, 0]
min_supported_mc_version = [1, 26, 40]
description = '''
$desc_line1
$desc_line2
%v
§3https://piglix.app/
'''
authors = ["Piglix"]
url = "https://piglix.app/"
uuid = "$uuid"
materials = ["Actor", "ActorGlint", "ActorMultiTexture", "Clouds", "EndSky", "ItemInHandColor", "ItemInHandColorGlint", "ItemInHandTextured", "RenderChunk","Sky", "Stars", "SunMoon", "Weather"]
[info]
copyright = ''
credits = ''
[[subpack]]
define = "REALISTIC_CLOUDS"
materials = ["Clouds", "RenderChunk"]
description = 'Realistic clouds'
[[subpack]]
define = "ROUNDED_CLOUDS"
materials = ["Clouds"]
description = 'Rounded Clouds'
[[subpack]]
define = "BOX_CLOUDS"
materials = ["Clouds", "RenderChunk"]
description = 'Box Clouds'
[[subpack]]
define = "CHUNK_ANIM"
materials = ["RenderChunk"]
description = 'Chunk loading animation'
[[subpack]]
define = "NO_WAVE_NO_FOG"
materials = ["RenderChunk"]
description = 'No fog and wave'
[[subpack]]
define = "NO_FOG"
materials = ["RenderChunk"]
description = 'No fog'
[[subpack]]
define = "NO_WAVE"
materials = ["RenderChunk"]
description = 'No wave'
[[subpack]]
define = "DEFAULT"
materials = []
description = 'Default'
TOMLEOF
}

SUBPACK_BLOCK='
#ifdef LITE
  #define NO_WAVE
  #undef NL_WEATHER_SPECK
  #undef NL_SHOOTING_STAR
  #undef NL_RAIN_MIST_OPACITY
  #undef NL_CLOUDY_FOG
  #undef NL_ENTITY_EDGE_HIGHLIGHT
  #undef NL_LAVA_NOISE
  #undef NL_BLINKING_TORCH
#endif
#ifdef NO_WAVE_NO_FOG
  #define NO_WAVE
  #define NO_FOG
#endif
#ifdef NO_FOG
  #undef NL_FOG
#endif
#ifdef NO_WAVE
  #undef NL_PLANTS_WAVE
  #undef NL_LANTERN_WAVE
  #undef NL_UNDERWATER_WAVE
  #undef NL_WATER_WAVE
  #undef NL_RAIN_MIST_OPACITY
#endif
#ifdef CHUNK_ANIM
  #define NL_CHUNK_LOAD_ANIM 100.0
#endif
#ifdef ROUNDED_CLOUDS
  #undef NL_CLOUD_TYPE
  #define NL_CLOUD_TYPE 2
#endif
#ifdef BOX_CLOUDS
  #undef NL_CLOUD_TYPE
  #define NL_CLOUD_TYPE 0
#endif
#ifdef REALISTIC_CLOUDS
  #undef NL_CLOUD_TYPE
  #define NL_CLOUD_TYPE 3
#endif
#endif'

# ═════════════════════════════════════════
# 1. SEUS RENEWED STYLE
#    Clean, realistic, warm sunlight.
#    The gold standard of Minecraft shaders.
# ═════════════════════════════════════════
cat > "$CONFIG" << CFGEOF
#ifndef NL_CONFIG_H
#define NL_CONFIG_H
// PIGLIX · SEUS STYLE — Clean Realistic Shader

/* Color correction — Extended Reinhard for natural look */
#define NL_TONEMAP_TYPE 3
#define NL_GAMMA 1.0
// no forced exposure — natural brightness
// no saturation override — natural colors
// no tint — pure natural look

/* Lighting — the SEUS signature: warm, soft, realistic */
#define NL_SUNLIGHT_INTENSITY   3.8
#define NL_TORCHLIGHT_INTENSITY 1.4
#define NL_SHADOW_INTENSITY     0.72
#define NL_MIN_LIGHTING_BOOST   1.6
#define NL_BLINKING_TORCH
#define NL_CLOUD_SHADOW

/* Ambient */
#define NL_NETHER_AMBIENT vec3(2.0,1.0,0.5)
#define NL_END_AMBIENT    vec3(0.6,0.3,0.9)

/* Sun/Moon — SEUS hallmark: clean warm-white sun */
#define NL_DAWN_SUNLIGHT_COL   vec3(1.50,0.90,0.55)
#define NL_NOON_SUNLIGHT_COL   vec3(1.40,1.30,1.10)
#define NL_NIGHT_MOONLIGHT_COL vec3(0.05,0.07,0.14)

/* Torch — warm natural firelight */
#define NL_OVERWORLD_TORCH_COL  vec3(1.6,0.78,0.28)
#define NL_UNDERWATER_TORCH_COL vec3(1.2,0.60,0.22)
#define NL_NETHER_TORCH_COL     vec3(2.0,0.70,0.12)
#define NL_END_TORCH_COL        vec3(0.9,0.50,1.50)

/* Fog — clean, natural horizon blend */
#define NL_FOG 1.0
#define NL_MIST_DENSITY 0.18
#define NL_RAIN_MIST_OPACITY 0.22
#define NL_CLOUDY_FOG 0.15

/* Sky — SEUS hallmark: perfect clean realistic blue */
#define NL_SKY_VOID_FACTOR     0.45
#define NL_SKY_VOID_DARKNESS   0.25
#define NL_SKY_RAIN_MIX_FACTOR 0.85
/* Dawn — soft warm pink-gold sunrise */
#define NL_DAWN_ZENITH_COL   vec3(0.22,0.28,0.52)
#define NL_DAWN_HORIZON_COL  vec3(1.10,0.65,0.40)
#define NL_DAWN_EDGE_COL     vec3(1.60,0.90,0.35)
/* Day — the iconic SEUS clean blue sky */
#define NL_DAY_ZENITH_COL    vec3(0.30,0.60,1.45)
#define NL_DAY_HORIZON_COL   vec3(0.78,0.92,1.30)
#define NL_DAY_EDGE_COL      vec3(1.00,1.00,1.10)
/* Night — natural dark blue night */
#define NL_NIGHT_ZENITH_COL  vec3(0.004,0.006,0.022)
#define NL_NIGHT_HORIZON_COL vec3(0.010,0.014,0.042)
#define NL_NIGHT_EDGE_COL    vec3(0.018,0.022,0.060)
/* Rain — clean grey natural rain */
#define NL_RAIN_ZENITH_COL   vec3(0.38,0.40,0.45)
#define NL_RAIN_HORIZON_COL  vec3(0.58,0.60,0.65)
#define NL_END_ZENITH_COL    vec3(0.03,0.01,0.08)
#define NL_END_HORIZON_COL   vec3(0.40,0.05,0.60)

/* Glow */
#define NL_GLOW_TEX 2.5
#define NL_GLOW_SHIMMER_SPEED 0.9

/* Waving */
#define NL_PLANTS_WAVE 0.05
#define NL_LANTERN_WAVE 0.14
#define NL_WAVE_SPEED 2.0
#define NL_WAVE_RANGE 8.0

/* Water — SEUS hallmark: beautiful clear water */
#define NL_WATER_TRANSPARENCY 0.82
#define NL_WATER_BUMP 0.08
#define NL_WATER_WAVE_SPEED  0.7
#define NL_WATER_TEX_OPACITY 0.25
#define NL_WATER_WAVE
#define NL_WATER_TINT vec3(0.40,0.72,1.00)

/* Underwater */
#define NL_UNDERWATER_BRIGHTNESS 0.9
#define NL_CAUSTIC_INTENSITY 2.2
#define NL_UNDERWATER_WAVE 0.08
#define NL_UNDERWATER_STREAKS 1.2
#define NL_UNDERWATER_TINT vec3(0.35,0.65,0.90)

/* Clouds — soft type 1, clean white */
#define NL_CLOUD_TYPE 1
#define NL_CLOUD1_SCALE vec2(0.016, 0.022)
#define NL_CLOUD1_DEPTH 1.4
#define NL_CLOUD1_SPEED 0.03
#define NL_CLOUD1_DENSITY 0.52
#define NL_CLOUD1_OPACITY 0.88
#define NL_CLOUD2_THICKNESS 2.5
#define NL_CLOUD2_RAIN_THICKNESS 4.5
#define NL_CLOUD2_STEPS 4
#define NL_CLOUD2_SCALE vec2(0.030, 0.030)
#define NL_CLOUD2_SHAPE vec2(0.5, 0.4)
#define NL_CLOUD2_DENSITY 25.0
#define NL_CLOUD2_VELOCITY 0.8
#define NL_CLOUD3_SCALE vec2(0.030, 0.030)
#define NL_CLOUD3_SPEED 0.005
#define NL_CLOUD3_SHADOW 0.9
#define NL_CLOUD3_SHADOW_OFFSET 0.3
#define NL_CLOUD0_THICKNESS 2.1
#define NL_CLOUD0_RAIN_THICKNESS 4.0
#define NL_CLOUD0_OPACITY 0.9
#define NL_CLOUD0_MULTILAYER

/* No aurora — clean realistic */
#define NL_AURORA_VELOCITY 0.03
#define NL_AURORA_SCALE 0.04
#define NL_AURORA_WIDTH 0.18
#define NL_AURORA_COL1 vec3(0.1,1.0,0.0)
#define NL_AURORA_COL2 vec3(0.1,0.0,1.0)

/* Stars */
#define NL_SHOOTING_STAR 0.6
#define NL_SHOOTING_STAR_PERIOD 6.0
#define NL_SHOOTING_STAR_DELAY 50.0
#define NL_GALAXY_VIBRANCE 0.5
#define NL_GALAXY_SPEED 0.02
#define NL_GALAXY_DAY_VISIBILITY 0.0
#define NL_RAINBOW
#define NL_RAINBOW_CLEAR 0.0
#define NL_RAINBOW_RAIN  0.35

/* Sun/Moon */
#define NL_SUN_SIZE  1.0
#define NL_MOON_SIZE 1.0
#define NL_SUN_PATH_YAW    15.0
#define NL_MOON_PATH_YAW   17.0
#define NL_SUN_PATH_TILT   31.0
#define NL_MOON_PATH_TILT -28.0
#define NL_SUN_TILT        45.0
#define NL_MOON_TILT       45.0
#define NL_GROUND_RAIN_WETNESS 0.8
#define NL_GROUND_RAIN_PUDDLES 0.5

/* Entity */
#define NL_ENTITY_BRIGHTNESS     0.70
#define NL_ENTITY_EDGE_HIGHLIGHT 0.35

/* Weather */
#define NL_WEATHER_SPECK 0.6
#define NL_WEATHER_RAIN_SLANT 3.5
#define NL_WEATHER_PARTICLE_SIZE 1.0

/* Lava */
#define NL_LAVA_NOISE
#define NL_LAVA_NOISE_SPEED 0.2

$SUBPACK_BLOCK
CFGEOF

write_toml "Piglix SEUS Style" "e1f2a3b4-c5d6-7890-e1f2-a3b4c5d67890" \
  "§aPiglix · SEUS Style Shader" \
  "§7- Clean realistic sky, warm sunlight, clear water."
build_shader "Piglix SEUS Style" "Piglix_SEUS_Style.mcpack" \
  "E1F2A3B4-C5D6-7890-E1F2-A3B4C5D67890" \
  "§aPiglix · SEUS Style\n§7Clean realistic sky. Warm sunlight. Clear water.\nv1.0-perf"

# ══════════════════════════════════════════
# 2. BSL STYLE
#    Dreamy pastel pink-purple tones.
#    The most gorgeous sunsets ever made.
# ══════════════════════════════════════════
cat > "$CONFIG" << CFGEOF
#ifndef NL_CONFIG_H
#define NL_CONFIG_H
// PIGLIX · BSL STYLE — Dreamy Pastel Shader

/* Color correction — ACES with warm saturation */
#define NL_TONEMAP_TYPE 4
#define NL_GAMMA 1.12
#define NL_EXPOSURE 1.05
#define NL_SATURATION 1.25
#define NL_TINT
#define NL_TINT_LOW  vec3(0.75,0.60,0.95)
#define NL_TINT_HIGH vec3(1.20,1.00,0.80)

/* Lighting — BSL: soft, dreamy, everywhere-warm */
#define NL_SUNLIGHT_INTENSITY   3.5
#define NL_TORCHLIGHT_INTENSITY 1.5
#define NL_SHADOW_INTENSITY     0.65
#define NL_MIN_LIGHTING_BOOST   2.0
#define NL_BLINKING_TORCH
#define NL_CLOUD_SHADOW

/* Ambient */
#define NL_NETHER_AMBIENT vec3(2.2,1.0,0.4)
#define NL_END_AMBIENT    vec3(0.8,0.3,1.1)

/* Sun/Moon — BSL: soft warm-pink sunlight */
#define NL_DAWN_SUNLIGHT_COL   vec3(1.70,0.75,0.60)
#define NL_NOON_SUNLIGHT_COL   vec3(1.50,1.30,1.00)
#define NL_NIGHT_MOONLIGHT_COL vec3(0.06,0.06,0.14)

/* Torch — BSL: warm cozy amber */
#define NL_OVERWORLD_TORCH_COL  vec3(1.60,0.80,0.30)
#define NL_UNDERWATER_TORCH_COL vec3(1.20,0.60,0.22)
#define NL_NETHER_TORCH_COL     vec3(2.10,0.75,0.10)
#define NL_END_TORCH_COL        vec3(1.00,0.50,1.60)

/* Fog — BSL: soft dreamy haze */
#define NL_FOG 1.0
#define NL_MIST_DENSITY 0.22
#define NL_RAIN_MIST_OPACITY 0.28
#define NL_CLOUDY_FOG 0.20

/* Sky — BSL hallmark: PASTEL PINK-PURPLE sunsets */
#define NL_SKY_VOID_FACTOR     0.50
#define NL_SKY_VOID_DARKNESS   0.28
#define NL_SKY_RAIN_MIX_FACTOR 0.88
/* Dawn/Dusk — the iconic BSL pink-magenta sunset */
#define NL_DAWN_ZENITH_COL   vec3(0.35,0.22,0.55)
#define NL_DAWN_HORIZON_COL  vec3(1.50,0.55,0.80)
#define NL_DAWN_EDGE_COL     vec3(2.00,0.80,0.55)
/* Day — warm pastel blue sky */
#define NL_DAY_ZENITH_COL    vec3(0.38,0.65,1.50)
#define NL_DAY_HORIZON_COL   vec3(0.90,0.88,1.35)
#define NL_DAY_EDGE_COL      vec3(1.20,1.05,1.00)
/* Night — deep purple BSL night */
#define NL_NIGHT_ZENITH_COL  vec3(0.005,0.004,0.022)
#define NL_NIGHT_HORIZON_COL vec3(0.015,0.010,0.045)
#define NL_NIGHT_EDGE_COL    vec3(0.028,0.018,0.065)
/* Rain */
#define NL_RAIN_ZENITH_COL   vec3(0.35,0.35,0.45)
#define NL_RAIN_HORIZON_COL  vec3(0.55,0.55,0.65)
#define NL_END_ZENITH_COL    vec3(0.04,0.01,0.10)
#define NL_END_HORIZON_COL   vec3(0.45,0.05,0.65)

/* Glow */
#define NL_GLOW_TEX 2.8
#define NL_GLOW_SHIMMER_SPEED 1.0

/* Waving */
#define NL_PLANTS_WAVE 0.06
#define NL_LANTERN_WAVE 0.16
#define NL_WAVE_SPEED 2.2
#define NL_WAVE_RANGE 8.0

/* Water — BSL: beautiful soft pastel water */
#define NL_WATER_TRANSPARENCY 0.78
#define NL_WATER_BUMP 0.09
#define NL_WATER_WAVE_SPEED  0.6
#define NL_WATER_TEX_OPACITY 0.22
#define NL_WATER_WAVE
#define NL_WATER_TINT vec3(0.45,0.70,1.05)

/* Underwater */
#define NL_UNDERWATER_BRIGHTNESS 1.0
#define NL_CAUSTIC_INTENSITY 2.0
#define NL_UNDERWATER_WAVE 0.07
#define NL_UNDERWATER_STREAKS 1.1
#define NL_UNDERWATER_TINT vec3(0.40,0.65,0.95)

/* Clouds */
#define NL_CLOUD_TYPE 1
#define NL_CLOUD1_SCALE vec2(0.016, 0.022)
#define NL_CLOUD1_DEPTH 1.5
#define NL_CLOUD1_SPEED 0.035
#define NL_CLOUD1_DENSITY 0.54
#define NL_CLOUD1_OPACITY 0.90
#define NL_CLOUD2_THICKNESS 2.1
#define NL_CLOUD2_RAIN_THICKNESS 2.5
#define NL_CLOUD2_STEPS 4
#define NL_CLOUD2_SCALE vec2(0.033, 0.033)
#define NL_CLOUD2_SHAPE vec2(0.5, 0.4)
#define NL_CLOUD2_DENSITY 25.0
#define NL_CLOUD2_VELOCITY 0.8
#define NL_CLOUD3_SCALE vec2(0.03, 0.03)
#define NL_CLOUD3_SPEED 0.005
#define NL_CLOUD3_SHADOW 0.9
#define NL_CLOUD3_SHADOW_OFFSET 0.3
#define NL_CLOUD0_THICKNESS 2.1
#define NL_CLOUD0_RAIN_THICKNESS 4.0
#define NL_CLOUD0_OPACITY 0.9
#define NL_CLOUD0_MULTILAYER

/* Aurora — subtle pink BSL aurora */
#define NL_AURORA 0.5
#define NL_AURORA_VELOCITY 0.02
#define NL_AURORA_SCALE 0.04
#define NL_AURORA_WIDTH 0.15
#define NL_AURORA_COL1 vec3(0.8,0.2,0.9)
#define NL_AURORA_COL2 vec3(0.3,0.1,1.0)

/* Stars */
#define NL_SHOOTING_STAR 0.7
#define NL_SHOOTING_STAR_PERIOD 6.0
#define NL_SHOOTING_STAR_DELAY 40.0
#define NL_GALAXY_VIBRANCE 0.7
#define NL_GALAXY_SPEED 0.02
#define NL_GALAXY_DAY_VISIBILITY 0.0
#define NL_RAINBOW
#define NL_RAINBOW_CLEAR 0.0
#define NL_RAINBOW_RAIN  0.45

/* Sun/Moon */
#define NL_SUN_SIZE  1.0
#define NL_MOON_SIZE 1.2
#define NL_SUN_PATH_YAW    15.0
#define NL_MOON_PATH_YAW   17.0
#define NL_SUN_PATH_TILT   31.0
#define NL_MOON_PATH_TILT -28.0
#define NL_SUN_TILT        45.0
#define NL_MOON_TILT       45.0
#define NL_GROUND_RAIN_WETNESS 0.9
#define NL_GROUND_RAIN_PUDDLES 0.6

/* Entity */
#define NL_ENTITY_BRIGHTNESS     0.72
#define NL_ENTITY_EDGE_HIGHLIGHT 0.38

/* Weather */
#define NL_WEATHER_SPECK 0.65
#define NL_WEATHER_RAIN_SLANT 3.5
#define NL_WEATHER_PARTICLE_SIZE 1.0

/* Lava */
#define NL_LAVA_NOISE
#define NL_LAVA_NOISE_SPEED 0.2

$SUBPACK_BLOCK
CFGEOF

write_toml "Piglix BSL Style" "f2a3b4c5-d6e7-8901-f2a3-b4c5d6e78901" \
  "§dPiglix · BSL Style Shader" \
  "§7- Dreamy pastel pink-purple. Gorgeous sunsets."
build_shader "Piglix BSL Style" "Piglix_BSL_Style.mcpack" \
  "F2A3B4C5-D6E7-8901-F2A3-B4C5D6E78901" \
  "§dPiglix · BSL Style\n§7Dreamy pastel pink-purple. Gorgeous sunsets.\nv1.0-perf"

# ══════════════════════════════════════════
# 3. CHOCAPIC13 STYLE
#    Cinematic, dramatic, vivid.
#    God-rays, high contrast, movie-like.
# ══════════════════════════════════════════
cat > "$CONFIG" << CFGEOF
#ifndef NL_CONFIG_H
#define NL_CONFIG_H
// PIGLIX · CHOCAPIC STYLE — Cinematic Dramatic Shader

/* Color correction — ACES for maximum cinematic impact */
#define NL_TONEMAP_TYPE 4
#define NL_GAMMA 1.08
#define NL_EXPOSURE 0.90
#define NL_SATURATION 1.35
#define NL_TINT
#define NL_TINT_LOW  vec3(0.55,0.62,0.88)
#define NL_TINT_HIGH vec3(1.25,1.05,0.72)

/* Lighting — Chocapic: high contrast, dramatic */
#define NL_SUNLIGHT_INTENSITY   4.5
#define NL_TORCHLIGHT_INTENSITY 2.0
#define NL_SHADOW_INTENSITY     0.88
#define NL_MIN_LIGHTING_BOOST   1.4
#define NL_BLINKING_TORCH
#define NL_CLOUD_SHADOW

/* Ambient */
#define NL_NETHER_AMBIENT vec3(2.4,1.0,0.3)
#define NL_END_AMBIENT    vec3(0.7,0.3,1.0)

/* Sun/Moon — Chocapic: intense golden sun */
#define NL_DAWN_SUNLIGHT_COL   vec3(2.00,0.80,0.20)
#define NL_NOON_SUNLIGHT_COL   vec3(1.60,1.45,0.95)
#define NL_NIGHT_MOONLIGHT_COL vec3(0.04,0.06,0.16)

/* Torch — warm dramatic torch */
#define NL_OVERWORLD_TORCH_COL  vec3(1.80,0.85,0.20)
#define NL_UNDERWATER_TORCH_COL vec3(1.30,0.65,0.18)
#define NL_NETHER_TORCH_COL     vec3(2.30,0.78,0.08)
#define NL_END_TORCH_COL        vec3(1.00,0.55,1.60)

/* Fog — Chocapic: volumetric dramatic fog */
#define NL_FOG 1.0
#define NL_MIST_DENSITY 0.30
#define NL_RAIN_MIST_OPACITY 0.38
#define NL_CLOUDY_FOG 0.35

/* Sky — Chocapic: vivid, saturated, cinematic */
#define NL_SKY_VOID_FACTOR     0.55
#define NL_SKY_VOID_DARKNESS   0.38
#define NL_SKY_RAIN_MIX_FACTOR 0.90
/* Dawn — dramatic rich sunrise */
#define NL_DAWN_ZENITH_COL   vec3(0.28,0.20,0.48)
#define NL_DAWN_HORIZON_COL  vec3(1.60,0.62,0.12)
#define NL_DAWN_EDGE_COL     vec3(2.50,1.10,0.12)
/* Day — vivid deep blue Chocapic sky */
#define NL_DAY_ZENITH_COL    vec3(0.28,0.55,1.55)
#define NL_DAY_HORIZON_COL   vec3(0.72,0.88,1.40)
#define NL_DAY_EDGE_COL      vec3(1.10,1.10,1.20)
/* Night */
#define NL_NIGHT_ZENITH_COL  vec3(0.003,0.005,0.020)
#define NL_NIGHT_HORIZON_COL vec3(0.010,0.015,0.042)
#define NL_NIGHT_EDGE_COL    vec3(0.020,0.025,0.065)
/* Rain — dramatic stormy sky */
#define NL_RAIN_ZENITH_COL   vec3(0.28,0.30,0.38)
#define NL_RAIN_HORIZON_COL  vec3(0.48,0.50,0.58)
#define NL_END_ZENITH_COL    vec3(0.03,0.01,0.08)
#define NL_END_HORIZON_COL   vec3(0.40,0.05,0.60)

/* Glow */
#define NL_GLOW_TEX 3.2
#define NL_GLOW_SHIMMER_SPEED 1.0

/* Waving — Chocapic: strong vivid wind */
#define NL_PLANTS_WAVE 0.08
#define NL_LANTERN_WAVE 0.20
#define NL_WAVE_SPEED 2.6
#define NL_WAVE_RANGE 8.0

/* Water — Chocapic: vivid blue beautiful water */
#define NL_WATER_TRANSPARENCY 0.75
#define NL_WATER_BUMP 0.10
#define NL_WATER_WAVE_SPEED  0.8
#define NL_WATER_TEX_OPACITY 0.20
#define NL_WATER_WAVE
#define NL_WATER_TINT vec3(0.35,0.68,1.10)

/* Underwater */
#define NL_UNDERWATER_BRIGHTNESS 0.8
#define NL_CAUSTIC_INTENSITY 2.5
#define NL_UNDERWATER_WAVE 0.09
#define NL_UNDERWATER_STREAKS 1.4
#define NL_UNDERWATER_TINT vec3(0.30,0.60,0.95)

/* Clouds */
#define NL_CLOUD_TYPE 1
#define NL_CLOUD1_SCALE vec2(0.016, 0.022)
#define NL_CLOUD1_DEPTH 1.8
#define NL_CLOUD1_SPEED 0.04
#define NL_CLOUD1_DENSITY 0.60
#define NL_CLOUD1_OPACITY 0.95
#define NL_CLOUD2_THICKNESS 2.5
#define NL_CLOUD2_RAIN_THICKNESS 5.0
#define NL_CLOUD2_STEPS 4
#define NL_CLOUD2_SCALE vec2(0.028, 0.028)
#define NL_CLOUD2_SHAPE vec2(0.55, 0.38)
#define NL_CLOUD2_DENSITY 28.0
#define NL_CLOUD2_VELOCITY 0.9
#define NL_CLOUD3_SCALE vec2(0.025, 0.025)
#define NL_CLOUD3_SPEED 0.007
#define NL_CLOUD3_SHADOW 0.95
#define NL_CLOUD3_SHADOW_OFFSET 0.38
#define NL_CLOUD0_THICKNESS 2.5
#define NL_CLOUD0_RAIN_THICKNESS 5.0
#define NL_CLOUD0_OPACITY 1.0
#define NL_CLOUD0_MULTILAYER

/* No aurora */
#define NL_AURORA_VELOCITY 0.03
#define NL_AURORA_SCALE 0.04
#define NL_AURORA_WIDTH 0.18
#define NL_AURORA_COL1 vec3(0.1,1.0,0.0)
#define NL_AURORA_COL2 vec3(0.1,0.0,1.0)

/* Stars */
#define NL_SHOOTING_STAR 0.8
#define NL_SHOOTING_STAR_PERIOD 5.0
#define NL_SHOOTING_STAR_DELAY 35.0
#define NL_GALAXY_VIBRANCE 0.6
#define NL_GALAXY_SPEED 0.02
#define NL_GALAXY_DAY_VISIBILITY 0.0
#define NL_RAINBOW
#define NL_RAINBOW_CLEAR 0.0
#define NL_RAINBOW_RAIN  0.50

/* Sun/Moon */
#define NL_SUN_SIZE  1.1
#define NL_MOON_SIZE 1.1
#define NL_SUN_PATH_YAW    15.0
#define NL_MOON_PATH_YAW   17.0
#define NL_SUN_PATH_TILT   31.0
#define NL_MOON_PATH_TILT -28.0
#define NL_SUN_TILT        45.0
#define NL_MOON_TILT       45.0
#define NL_GROUND_RAIN_WETNESS 1.0
#define NL_GROUND_RAIN_PUDDLES 0.7

/* Entity */
#define NL_ENTITY_BRIGHTNESS     0.68
#define NL_ENTITY_EDGE_HIGHLIGHT 0.45

/* Weather */
#define NL_WEATHER_SPECK 0.7
#define NL_WEATHER_RAIN_SLANT 4.5
#define NL_WEATHER_PARTICLE_SIZE 1.1

/* Lava */
#define NL_LAVA_NOISE
#define NL_LAVA_NOISE_SPEED 0.22

$SUBPACK_BLOCK
CFGEOF

write_toml "Piglix Chocapic Style" "a3b4c5d6-e7f8-9012-a3b4-c5d6e7f89012" \
  "§6Piglix · Chocapic Style Shader" \
  "§7- Cinematic. Dramatic. Vivid sky and shadows."
build_shader "Piglix Chocapic Style" "Piglix_Chocapic_Style.mcpack" \
  "A3B4C5D6-E7F8-9012-A3B4-C5D6E7F89012" \
  "§6Piglix · Chocapic Style\n§7Cinematic. Dramatic. Vivid sky and shadows.\nv1.0-perf"

# ══════════════════════════════════════════
# 4. NEWB X CLASSIC — Reimagined
#    The original Newb X formula, perfected.
#    Best balance of beauty and performance.
# ══════════════════════════════════════════
cat > "$CONFIG" << CFGEOF
#ifndef NL_CONFIG_H
#define NL_CONFIG_H
// PIGLIX · NEWB X REIMAGINED — Perfected Classic

/* Color correction — Extended Reinhard, balanced */
#define NL_TONEMAP_TYPE 3
#define NL_GAMMA 1.33
#define NL_SATURATION 1.15
#define NL_TINT
#define NL_TINT_LOW  vec3(0.60,0.72,1.10)
#define NL_TINT_HIGH vec3(1.20,1.05,0.75)

/* Lighting — perfectly balanced classic */
#define NL_SUNLIGHT_INTENSITY   3.3
#define NL_TORCHLIGHT_INTENSITY 1.2
#define NL_SHADOW_INTENSITY     0.70
#define NL_MIN_LIGHTING_BOOST   1.5
#define NL_BLINKING_TORCH
#define NL_CLOUD_SHADOW

/* Ambient */
#define NL_NETHER_AMBIENT vec3(3.0,2.16,1.89)
#define NL_END_AMBIENT    vec3(1.98,1.25,2.3)

/* Sun/Moon — classic warm sun */
#define NL_DAWN_SUNLIGHT_COL   vec3(1.60,0.85,0.35)
#define NL_NOON_SUNLIGHT_COL   vec3(1.45,1.35,1.05)
#define NL_NIGHT_MOONLIGHT_COL vec3(0.04,0.06,0.16)

/* Torch — classic orange */
#define NL_OVERWORLD_TORCH_COL  vec3(1.0,0.52,0.18)
#define NL_UNDERWATER_TORCH_COL vec3(1.0,0.52,0.18)
#define NL_NETHER_TORCH_COL     vec3(1.0,0.52,0.18)
#define NL_END_TORCH_COL        vec3(1.0,0.52,0.18)

/* Fog */
#define NL_FOG 1.0
#define NL_MIST_DENSITY 0.20
#define NL_RAIN_MIST_OPACITY 0.18
#define NL_CLOUDY_FOG 0.12

/* Sky — improved classic Newb X sky */
#define NL_SKY_VOID_FACTOR     0.5
#define NL_SKY_VOID_DARKNESS   0.3
#define NL_SKY_RAIN_MIX_FACTOR 0.9
/* Dawn — warm classic sunrise */
#define NL_DAWN_ZENITH_COL   vec3(0.20,0.25,0.50)
#define NL_DAWN_HORIZON_COL  vec3(1.20,0.60,0.20)
#define NL_DAWN_EDGE_COL     vec3(1.80,0.85,0.20)
/* Day — classic clean blue sky improved */
#define NL_DAY_ZENITH_COL    vec3(0.32,0.62,1.48)
#define NL_DAY_HORIZON_COL   vec3(0.85,0.95,1.38)
#define NL_DAY_EDGE_COL      vec3(1.05,1.05,1.15)
/* Night — classic dark night */
#define NL_NIGHT_ZENITH_COL  vec3(0.004,0.006,0.022)
#define NL_NIGHT_HORIZON_COL vec3(0.010,0.015,0.040)
#define NL_NIGHT_EDGE_COL    vec3(0.018,0.022,0.055)
/* Rain */
#define NL_RAIN_ZENITH_COL   vec3(0.47,0.51,0.56)
#define NL_RAIN_HORIZON_COL  vec3(0.60,0.60,0.60)
#define NL_END_ZENITH_COL    vec3(0.08,0.001,0.1)
#define NL_END_HORIZON_COL   vec3(0.6,0.02,0.6)

/* Glow */
#define NL_GLOW_TEX 2.3
#define NL_GLOW_SHIMMER 0.8
#define NL_GLOW_SHIMMER_SPEED 0.9

/* Waving — classic */
#define NL_PLANTS_WAVE 0.05
#define NL_LANTERN_WAVE 0.16
#define NL_WAVE_SPEED 2.8
#define NL_WAVE_RANGE 8.0

/* Water — improved classic */
#define NL_WATER_TRANSPARENCY 0.9
#define NL_WATER_BUMP 0.09
#define NL_WATER_WAVE_SPEED  0.8
#define NL_WATER_TEX_OPACITY 0.3
#define NL_WATER_WAVE
#define NL_WATER_TINT vec3(0.52,0.90,0.45)

/* Underwater */
#define NL_UNDERWATER_BRIGHTNESS 0.8
#define NL_CAUSTIC_INTENSITY 1.9
#define NL_UNDERWATER_WAVE 0.1
#define NL_UNDERWATER_STREAKS 1.0
#define NL_UNDERWATER_TINT vec3(0.9,1.0,0.9)

/* Clouds */
#define NL_CLOUD_TYPE 1
#define NL_CLOUD1_SCALE vec2(0.016, 0.022)
#define NL_CLOUD1_DEPTH 1.3
#define NL_CLOUD1_SPEED 0.04
#define NL_CLOUD1_DENSITY 0.54
#define NL_CLOUD1_OPACITY 0.90
#define NL_CLOUD2_THICKNESS 2.1
#define NL_CLOUD2_RAIN_THICKNESS 2.5
#define NL_CLOUD2_STEPS 4
#define NL_CLOUD2_SCALE vec2(0.033, 0.033)
#define NL_CLOUD2_SHAPE vec2(0.5, 0.4)
#define NL_CLOUD2_DENSITY 25.0
#define NL_CLOUD2_VELOCITY 0.8
#define NL_CLOUD3_SCALE vec2(0.03, 0.03)
#define NL_CLOUD3_SPEED 0.005
#define NL_CLOUD3_SHADOW 0.9
#define NL_CLOUD3_SHADOW_OFFSET 0.3
#define NL_CLOUD0_THICKNESS 2.1
#define NL_CLOUD0_RAIN_THICKNESS 4.0
#define NL_CLOUD0_OPACITY 0.9
#define NL_CLOUD0_MULTILAYER

/* Aurora — classic subtle */
#define NL_AURORA 1.2
#define NL_AURORA_VELOCITY 0.03
#define NL_AURORA_SCALE 0.04
#define NL_AURORA_WIDTH 0.18
#define NL_AURORA_COL1 vec3(0.1,1.0,0.0)
#define NL_AURORA_COL2 vec3(0.1,0.0,1.0)
#define NL_CLOUD_AURORA_REFLECTION

/* Stars */
#define NL_SHOOTING_STAR 1.0
#define NL_SHOOTING_STAR_PERIOD 6.0
#define NL_SHOOTING_STAR_DELAY 64.0
#define NL_GALAXY_VIBRANCE 0.7
#define NL_GALAXY_SPEED 0.03
#define NL_GALAXY_DAY_VISIBILITY 0.0
#define NL_RAINBOW
#define NL_RAINBOW_CLEAR 0.0
#define NL_RAINBOW_RAIN  0.4

/* Sun/Moon */
#define NL_SUN_SIZE  1.0
#define NL_MOON_SIZE 1.0
#define NL_SUN_PATH_YAW    15.0
#define NL_MOON_PATH_YAW   17.0
#define NL_SUN_PATH_TILT   31.0
#define NL_MOON_PATH_TILT -28.0
#define NL_SUN_TILT        45.0
#define NL_MOON_TILT       45.0
#define NL_GROUND_RAIN_WETNESS 1.0
#define NL_GROUND_RAIN_PUDDLES 0.7

/* Entity */
#define NL_ENTITY_BRIGHTNESS     0.65
#define NL_ENTITY_EDGE_HIGHLIGHT 0.41

/* Weather */
#define NL_WEATHER_SPECK 0.6
#define NL_WEATHER_RAIN_SLANT 4.0
#define NL_WEATHER_PARTICLE_SIZE 1.0

/* Lava */
#define NL_LAVA_NOISE
#define NL_LAVA_NOISE_SPEED 0.2

$SUBPACK_BLOCK
CFGEOF

write_toml "Piglix Newb X Reimagined" "b4c5d6e7-f8a9-0123-b4c5-d6e7f8a90123" \
  "§3Piglix · Newb X Reimagined" \
  "§7- The classic perfected. Best balance of beauty & perf."
build_shader "Piglix Newb X Reimagined" "Piglix_NewbX_Reimagined.mcpack" \
  "B4C5D6E7-F8A9-0123-B4C5-D6E7F8A90123" \
  "§3Piglix · Newb X Reimagined\n§7Classic perfected. Best balance of beauty & perf.\nv1.0-perf"

echo ""
echo "✅ All 4 Famous Style shaders built successfully!"
echo "📦 Files saved to: $OUT_DIR"
