#!/bin/bash
# ══════════════════════════════════════════════════════════════
# Piglix New 5 Shader Pack
# Sakura / Neon Tokyo / Tropical / Fallout / Lost World
# All 5 built in one run, performance-optimized for mobile
# ══════════════════════════════════════════════════════════════

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
  local d1="$3"
  local d2="$4"
  cat > "$TOML" << TOMLEOF
name = "$name"
version = [1, 0, 0]
min_supported_mc_version = [1, 26, 40]
description = '''
$d1
$d2
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

SUBPACKS='
#ifdef LITE
  #define NO_WAVE
  #undef NL_WEATHER_SPECK
  #undef NL_SHOOTING_STAR
  #undef NL_RAIN_MIST_OPACITY
  #undef NL_CLOUDY_FOG
  #undef NL_ENTITY_EDGE_HIGHLIGHT
  #undef NL_LAVA_NOISE
  #undef NL_BLINKING_TORCH
  #undef NL_AURORA
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

# ════════════════════════════════════════════
# 1. SAKURA DREAM — Japanese Spring
#    Soft pink sky. Peaceful. Paper-lantern glow.
# ════════════════════════════════════════════
cat > "$CONFIG" << CFGEOF
#ifndef NL_CONFIG_H
#define NL_CONFIG_H
// PIGLIX · SAKURA DREAM — Japanese Spring Shader

/* Color correction — soft warm pastel */
#define NL_TONEMAP_TYPE 3
#define NL_GAMMA 1.20
#define NL_EXPOSURE 1.08
#define NL_SATURATION 1.20
#define NL_TINT
#define NL_TINT_LOW  vec3(0.90,0.65,0.85)
#define NL_TINT_HIGH vec3(1.25,1.00,1.10)

/* Lighting — soft, diffused, like through blossoms */
#define NL_SUNLIGHT_INTENSITY   2.8
#define NL_TORCHLIGHT_INTENSITY 1.5
#define NL_SHADOW_INTENSITY     0.55
#define NL_MIN_LIGHTING_BOOST   2.2
#define NL_BLINKING_TORCH

/* Ambient */
#define NL_NETHER_AMBIENT vec3(2.2,1.0,0.4)
#define NL_END_AMBIENT    vec3(0.8,0.3,1.1)

/* Sun/Moon — soft warm-pink diffused sunlight */
#define NL_DAWN_SUNLIGHT_COL   vec3(1.50,0.80,0.90)
#define NL_NOON_SUNLIGHT_COL   vec3(1.40,1.20,1.20)
#define NL_NIGHT_MOONLIGHT_COL vec3(0.10,0.07,0.12)

/* Torch — warm paper-lantern glow */
#define NL_OVERWORLD_TORCH_COL  vec3(1.60,0.90,0.50)
#define NL_UNDERWATER_TORCH_COL vec3(1.20,0.70,0.40)
#define NL_NETHER_TORCH_COL     vec3(2.00,0.70,0.10)
#define NL_END_TORCH_COL        vec3(1.00,0.50,1.50)

/* Fog — soft pink cherry blossom mist */
#define NL_FOG 1.0
#define NL_MIST_DENSITY 0.20
#define NL_RAIN_MIST_OPACITY 0.25
#define NL_CLOUDY_FOG 0.18

/* Sky — soft pastel pink-white spring sky */
#define NL_SKY_VOID_FACTOR     0.40
#define NL_SKY_VOID_DARKNESS   0.20
#define NL_SKY_RAIN_MIX_FACTOR 0.80
/* Dawn — warm rose-gold sakura sunrise */
#define NL_DAWN_ZENITH_COL   vec3(0.55,0.30,0.55)
#define NL_DAWN_HORIZON_COL  vec3(1.60,0.80,0.95)
#define NL_DAWN_EDGE_COL     vec3(1.80,1.00,0.80)
/* Day — soft pastel pink-blue sky */
#define NL_DAY_ZENITH_COL    vec3(0.55,0.72,1.40)
#define NL_DAY_HORIZON_COL   vec3(1.10,0.88,1.20)
#define NL_DAY_EDGE_COL      vec3(1.30,1.05,1.10)
/* Night — deep soft violet night */
#define NL_NIGHT_ZENITH_COL  vec3(0.006,0.004,0.020)
#define NL_NIGHT_HORIZON_COL vec3(0.020,0.010,0.045)
#define NL_NIGHT_EDGE_COL    vec3(0.038,0.018,0.072)
/* Rain — soft pink-grey spring rain */
#define NL_RAIN_ZENITH_COL   vec3(0.42,0.38,0.48)
#define NL_RAIN_HORIZON_COL  vec3(0.68,0.62,0.72)
#define NL_END_ZENITH_COL    vec3(0.04,0.01,0.10)
#define NL_END_HORIZON_COL   vec3(0.50,0.05,0.65)

/* Glow — ores shimmer like cherry blossoms */
#define NL_GLOW_TEX 2.6
#define NL_GLOW_SHIMMER 0.9
#define NL_GLOW_SHIMMER_SPEED 0.8

/* Waving — very gentle spring breeze */
#define NL_PLANTS_WAVE 0.04
#define NL_LANTERN_WAVE 0.12
#define NL_WAVE_SPEED 1.2
#define NL_WAVE_RANGE 8.0

/* Water — crystal clear calm mirror lake */
#define NL_WATER_TRANSPARENCY 0.85
#define NL_WATER_BUMP 0.05
#define NL_WATER_WAVE_SPEED  0.4
#define NL_WATER_TEX_OPACITY 0.15
#define NL_WATER_WAVE
#define NL_WATER_TINT vec3(0.65,0.78,1.10)

/* Underwater */
#define NL_UNDERWATER_BRIGHTNESS 1.2
#define NL_CAUSTIC_INTENSITY 2.0
#define NL_UNDERWATER_WAVE 0.06
#define NL_UNDERWATER_STREAKS 1.0
#define NL_UNDERWATER_TINT vec3(0.60,0.72,1.00)

/* Clouds — soft fluffy spring clouds */
#define NL_CLOUD_TYPE 1
#define NL_CLOUD1_SCALE vec2(0.014, 0.020)
#define NL_CLOUD1_DEPTH 1.2
#define NL_CLOUD1_SPEED 0.025
#define NL_CLOUD1_DENSITY 0.48
#define NL_CLOUD1_OPACITY 0.82
#define NL_CLOUD2_THICKNESS 2.0
#define NL_CLOUD2_RAIN_THICKNESS 4.0
#define NL_CLOUD2_STEPS 4
#define NL_CLOUD2_SCALE vec2(0.030, 0.030)
#define NL_CLOUD2_SHAPE vec2(0.5, 0.35)
#define NL_CLOUD2_DENSITY 22.0
#define NL_CLOUD2_VELOCITY 0.6
#define NL_CLOUD3_SCALE vec2(0.028, 0.028)
#define NL_CLOUD3_SPEED 0.005
#define NL_CLOUD3_SHADOW 0.60
#define NL_CLOUD3_SHADOW_OFFSET 0.28
#define NL_CLOUD0_THICKNESS 2.0
#define NL_CLOUD0_RAIN_THICKNESS 4.0
#define NL_CLOUD0_OPACITY 0.85
#define NL_CLOUD0_MULTILAYER

/* Aurora — soft pink aurora like cherry blossoms in sky */
#define NL_AURORA 0.55
#define NL_AURORA_VELOCITY 0.010
#define NL_AURORA_SCALE 0.042
#define NL_AURORA_WIDTH 0.14
#define NL_AURORA_COL1 vec3(1.0,0.40,0.70)
#define NL_AURORA_COL2 vec3(0.7,0.20,0.90)

/* Stars */
#define NL_SHOOTING_STAR 0.65
#define NL_SHOOTING_STAR_PERIOD 5.0
#define NL_SHOOTING_STAR_DELAY 30.0
#define NL_GALAXY_VIBRANCE 0.50
#define NL_GALAXY_SPEED 0.015
#define NL_GALAXY_DAY_VISIBILITY 0.0
#define NL_RAINBOW
#define NL_RAINBOW_CLEAR 0.05
#define NL_RAINBOW_RAIN  0.60

/* Sun/Moon */
#define NL_SUN_SIZE  1.1
#define NL_MOON_SIZE 1.3
#define NL_SUN_PATH_YAW    14.0
#define NL_MOON_PATH_YAW   16.0
#define NL_SUN_PATH_TILT   30.0
#define NL_MOON_PATH_TILT -26.0
#define NL_SUN_TILT        44.0
#define NL_MOON_TILT       44.0
#define NL_GROUND_RAIN_WETNESS 0.75
#define NL_GROUND_RAIN_PUDDLES 0.55

/* Entity */
#define NL_ENTITY_BRIGHTNESS     0.78
#define NL_ENTITY_EDGE_HIGHLIGHT 0.38

/* Weather — soft spring rain */
#define NL_WEATHER_SPECK 0.70
#define NL_WEATHER_RAIN_SLANT 2.5
#define NL_WEATHER_PARTICLE_SIZE 0.9

/* Lava */
#define NL_LAVA_NOISE
#define NL_LAVA_NOISE_SPEED 0.18
$SUBPACKS
CFGEOF

write_toml "Piglix Sakura Dream" "c1d2e3f4-a5b6-7890-c1d2-e3f4a5b67890" \
  "§dPiglix · Sakura Dream Shader" \
  "§7- Soft pink sky. Peaceful spring. Paper lanterns."
build_shader "Piglix Sakura Dream" "Piglix_Sakura_Dream.mcpack" \
  "C1D2E3F4-A5B6-7890-C1D2-E3F4A5B67890" \
  "§dPiglix · Sakura Dream\n§7Soft pink sky. Peaceful spring. Paper lanterns.\nv1.0-perf"

# ════════════════════════════════════════════
# 2. NEON TOKYO — Cyberpunk Rainy Night
#    Always night. Wet reflective ground. City glow.
# ════════════════════════════════════════════
cat > "$CONFIG" << CFGEOF
#ifndef NL_CONFIG_H
#define NL_CONFIG_H
// PIGLIX · NEON TOKYO — Cyberpunk Rainy Night Shader

/* Color correction — dark cinematic purple-blue */
#define NL_TONEMAP_TYPE 4
#define NL_GAMMA 0.95
#define NL_EXPOSURE 0.72
#define NL_SATURATION 1.40
#define NL_TINT
#define NL_TINT_LOW  vec3(0.35,0.30,0.75)
#define NL_TINT_HIGH vec3(0.80,0.65,1.20)

/* Lighting — dark moody, neon contrast */
#define NL_SUNLIGHT_INTENSITY   1.0
#define NL_TORCHLIGHT_INTENSITY 3.0
#define NL_SHADOW_INTENSITY     0.92
#define NL_MIN_LIGHTING_BOOST   0.8
#define NL_BLINKING_TORCH

/* Ambient */
#define NL_NETHER_AMBIENT vec3(2.0,0.5,0.3)
#define NL_END_AMBIENT    vec3(0.5,0.2,1.2)

/* Sun/Moon — weak sun, neon-tinted night */
#define NL_DAWN_SUNLIGHT_COL   vec3(0.80,0.50,1.00)
#define NL_NOON_SUNLIGHT_COL   vec3(0.70,0.70,1.10)
#define NL_NIGHT_MOONLIGHT_COL vec3(0.04,0.04,0.18)

/* Torch — electric neon glow! */
#define NL_OVERWORLD_TORCH_COL  vec3(0.40,0.60,2.50)
#define NL_UNDERWATER_TORCH_COL vec3(0.30,0.50,2.00)
#define NL_NETHER_TORCH_COL     vec3(2.50,0.20,0.40)
#define NL_END_TORCH_COL        vec3(1.20,0.10,2.00)

/* Fog — moody city night fog */
#define NL_FOG 1.0
#define NL_MIST_DENSITY 0.38
#define NL_RAIN_MIST_OPACITY 0.55
#define NL_CLOUDY_FOG 0.45

/* Sky — always deep night, city glow on clouds */
#define NL_SKY_VOID_FACTOR     0.70
#define NL_SKY_VOID_DARKNESS   0.60
#define NL_SKY_RAIN_MIX_FACTOR 1.0
/* Dawn — barely any dawn, purple-blue only */
#define NL_DAWN_ZENITH_COL   vec3(0.08,0.06,0.25)
#define NL_DAWN_HORIZON_COL  vec3(0.30,0.12,0.50)
#define NL_DAWN_EDGE_COL     vec3(0.60,0.20,0.80)
/* Day — overcast dark purple, feels like night */
#define NL_DAY_ZENITH_COL    vec3(0.08,0.08,0.22)
#define NL_DAY_HORIZON_COL   vec3(0.25,0.12,0.42)
#define NL_DAY_EDGE_COL      vec3(0.45,0.18,0.65)
/* Night — deep neon city night */
#define NL_NIGHT_ZENITH_COL  vec3(0.004,0.003,0.022)
#define NL_NIGHT_HORIZON_COL vec3(0.020,0.010,0.060)
#define NL_NIGHT_EDGE_COL    vec3(0.050,0.020,0.100)
/* Rain — thick neon foggy city rain */
#define NL_RAIN_ZENITH_COL   vec3(0.08,0.06,0.18)
#define NL_RAIN_HORIZON_COL  vec3(0.20,0.12,0.35)
#define NL_END_ZENITH_COL    vec3(0.02,0.01,0.08)
#define NL_END_HORIZON_COL   vec3(0.30,0.05,0.55)

/* Glow — ores pulse like neon signs */
#define NL_GLOW_TEX 4.5
#define NL_GLOW_SHIMMER 1.0
#define NL_GLOW_SHIMMER_SPEED 2.0

/* Waving — city wind, moderate */
#define NL_PLANTS_WAVE 0.07
#define NL_LANTERN_WAVE 0.25
#define NL_WAVE_SPEED 2.5
#define NL_WAVE_RANGE 8.0

/* Water — dark wet reflective city streets */
#define NL_WATER_TRANSPARENCY 0.50
#define NL_WATER_BUMP 0.08
#define NL_WATER_WAVE_SPEED  0.5
#define NL_WATER_TEX_OPACITY 0.12
#define NL_WATER_WAVE
#define NL_WATER_TINT vec3(0.15,0.12,0.45)

/* Underwater */
#define NL_UNDERWATER_BRIGHTNESS 0.4
#define NL_CAUSTIC_INTENSITY 1.2
#define NL_UNDERWATER_WAVE 0.08
#define NL_UNDERWATER_TINT vec3(0.20,0.15,0.55)

/* Clouds — heavy dark city clouds */
#define NL_CLOUD_TYPE 1
#define NL_CLOUD1_SCALE vec2(0.018, 0.024)
#define NL_CLOUD1_DEPTH 2.0
#define NL_CLOUD1_SPEED 0.05
#define NL_CLOUD1_DENSITY 0.72
#define NL_CLOUD1_OPACITY 0.98
#define NL_CLOUD2_THICKNESS 3.5
#define NL_CLOUD2_RAIN_THICKNESS 6.0
#define NL_CLOUD2_STEPS 4
#define NL_CLOUD2_SCALE vec2(0.025, 0.025)
#define NL_CLOUD2_SHAPE vec2(0.60, 0.28)
#define NL_CLOUD2_DENSITY 35.0
#define NL_CLOUD2_VELOCITY 1.2
#define NL_CLOUD3_SCALE vec2(0.020, 0.020)
#define NL_CLOUD3_SPEED 0.012
#define NL_CLOUD3_SHADOW 1.0
#define NL_CLOUD3_SHADOW_OFFSET 0.50
#define NL_CLOUD0_THICKNESS 4.0
#define NL_CLOUD0_RAIN_THICKNESS 7.0
#define NL_CLOUD0_OPACITY 1.0
#define NL_CLOUD0_MULTILAYER

/* No aurora - city lights only */
#define NL_AURORA_VELOCITY 0.02
#define NL_AURORA_SCALE 0.04
#define NL_AURORA_WIDTH 0.15
#define NL_AURORA_COL1 vec3(0.0,0.8,1.0)
#define NL_AURORA_COL2 vec3(0.8,0.0,1.0)

/* Stars — hidden by city light pollution */
#define NL_SHOOTING_STAR 0.3
#define NL_SHOOTING_STAR_PERIOD 8.0
#define NL_SHOOTING_STAR_DELAY 90.0
#define NL_GALAXY_VIBRANCE 0.3
#define NL_GALAXY_SPEED 0.01
#define NL_GALAXY_DAY_VISIBILITY 0.0
//#define NL_RAINBOW
#define NL_RAINBOW_CLEAR 0.0
#define NL_RAINBOW_RAIN  0.0

/* Sun/Moon — tiny distant moon */
#define NL_SUN_SIZE  0.5
#define NL_MOON_SIZE 0.8
#define NL_SUN_PATH_YAW    15.0
#define NL_MOON_PATH_YAW   17.0
#define NL_SUN_PATH_TILT   31.0
#define NL_MOON_PATH_TILT -28.0
#define NL_SUN_TILT        45.0
#define NL_MOON_TILT       45.0
#define NL_GROUND_RAIN_WETNESS 1.0
#define NL_GROUND_RAIN_PUDDLES 0.95

/* Entity — dark outline like neon streets */
#define NL_ENTITY_BRIGHTNESS     0.50
#define NL_ENTITY_EDGE_HIGHLIGHT 0.80

/* Weather — heavy cyberpunk rain */
#define NL_WEATHER_SPECK 1.0
#define NL_WEATHER_RAIN_SLANT 6.5
#define NL_WEATHER_PARTICLE_SIZE 1.3

/* Lava */
#define NL_LAVA_NOISE
#define NL_LAVA_NOISE_SPEED 0.25
$SUBPACKS
CFGEOF

write_toml "Piglix Neon Tokyo" "d2e3f4a5-b6c7-8901-d2e3-f4a5b6c78901" \
  "§bPiglix · Neon Tokyo Shader" \
  "§7- Always night. Wet streets. Electric neon glow."
build_shader "Piglix Neon Tokyo" "Piglix_Neon_Tokyo.mcpack" \
  "D2E3F4A5-B6C7-8901-D2E3-F4A5B6C78901" \
  "§bPiglix · Neon Tokyo\n§7Always night. Wet streets. Electric neon glow.\nv1.0-perf"

# ════════════════════════════════════════════
# 3. TROPICAL PARADISE — Crystal Caribbean
#    Blazing sun. Perfect azure. Turquoise water.
# ════════════════════════════════════════════
cat > "$CONFIG" << CFGEOF
#ifndef NL_CONFIG_H
#define NL_CONFIG_H
// PIGLIX · TROPICAL PARADISE — Crystal Caribbean Shader

/* Color correction — vibrant punchy tropical */
#define NL_TONEMAP_TYPE 2
#define NL_GAMMA 1.25
#define NL_EXPOSURE 1.15
#define NL_SATURATION 1.55
/* No tint — pure vibrant natural colors */

/* Lighting — blazing tropical sun */
#define NL_SUNLIGHT_INTENSITY   4.8
#define NL_TORCHLIGHT_INTENSITY 1.3
#define NL_SHADOW_INTENSITY     0.65
#define NL_MIN_LIGHTING_BOOST   2.5
#define NL_CLOUD_SHADOW

/* Ambient */
#define NL_NETHER_AMBIENT vec3(2.2,1.0,0.4)
#define NL_END_AMBIENT    vec3(0.6,0.3,0.9)

/* Sun/Moon — blazing white tropical sun */
#define NL_DAWN_SUNLIGHT_COL   vec3(1.80,1.00,0.50)
#define NL_NOON_SUNLIGHT_COL   vec3(1.80,1.70,1.40)
#define NL_NIGHT_MOONLIGHT_COL vec3(0.06,0.09,0.18)

/* Torch — warm tropical glow */
#define NL_OVERWORLD_TORCH_COL  vec3(1.70,0.90,0.30)
#define NL_UNDERWATER_TORCH_COL vec3(1.40,0.80,0.30)
#define NL_NETHER_TORCH_COL     vec3(2.20,0.75,0.08)
#define NL_END_TORCH_COL        vec3(1.00,0.55,1.50)

/* Fog — minimal, clear tropical air */
#define NL_FOG 1.0
#define NL_MIST_DENSITY 0.10
#define NL_RAIN_MIST_OPACITY 0.20
#define NL_CLOUDY_FOG 0.08

/* Sky — the perfect deep azure tropical sky */
#define NL_SKY_VOID_FACTOR     0.40
#define NL_SKY_VOID_DARKNESS   0.20
#define NL_SKY_RAIN_MIX_FACTOR 0.80
/* Dawn — bright warm tropical sunrise */
#define NL_DAWN_ZENITH_COL   vec3(0.28,0.38,0.88)
#define NL_DAWN_HORIZON_COL  vec3(1.40,0.80,0.40)
#define NL_DAWN_EDGE_COL     vec3(1.80,1.10,0.35)
/* Day — the iconic perfect tropical azure */
#define NL_DAY_ZENITH_COL    vec3(0.22,0.55,1.65)
#define NL_DAY_HORIZON_COL   vec3(0.60,0.88,1.55)
#define NL_DAY_EDGE_COL      vec3(0.85,1.05,1.40)
/* Night — deep tropical night */
#define NL_NIGHT_ZENITH_COL  vec3(0.003,0.005,0.022)
#define NL_NIGHT_HORIZON_COL vec3(0.008,0.015,0.048)
#define NL_NIGHT_EDGE_COL    vec3(0.015,0.025,0.070)
/* Rain */
#define NL_RAIN_ZENITH_COL   vec3(0.30,0.40,0.55)
#define NL_RAIN_HORIZON_COL  vec3(0.50,0.60,0.75)
#define NL_END_ZENITH_COL    vec3(0.03,0.01,0.08)
#define NL_END_HORIZON_COL   vec3(0.35,0.05,0.55)

/* Glow */
#define NL_GLOW_TEX 2.8
#define NL_GLOW_SHIMMER_SPEED 1.2

/* Waving — warm tropical breeze */
#define NL_PLANTS_WAVE 0.07
#define NL_LANTERN_WAVE 0.18
#define NL_WAVE_SPEED 2.0
#define NL_WAVE_RANGE 8.0

/* Water — THE signature: crystal clear turquoise! */
#define NL_WATER_TRANSPARENCY 0.35
#define NL_WATER_BUMP 0.06
#define NL_WATER_WAVE_SPEED  0.9
#define NL_WATER_TEX_OPACITY 0.10
#define NL_WATER_WAVE
#define NL_WATER_TINT vec3(0.10,0.78,0.85)

/* Underwater — crystal bright tropical reef */
#define NL_UNDERWATER_BRIGHTNESS 2.0
#define NL_CAUSTIC_INTENSITY 4.0
#define NL_UNDERWATER_WAVE 0.06
#define NL_UNDERWATER_STREAKS 1.8
#define NL_UNDERWATER_TINT vec3(0.12,0.80,0.88)

/* Clouds — bright white fluffy tropical clouds */
#define NL_CLOUD_TYPE 1
#define NL_CLOUD1_SCALE vec2(0.014, 0.018)
#define NL_CLOUD1_DEPTH 1.2
#define NL_CLOUD1_SPEED 0.03
#define NL_CLOUD1_DENSITY 0.45
#define NL_CLOUD1_OPACITY 0.92
#define NL_CLOUD2_THICKNESS 2.2
#define NL_CLOUD2_RAIN_THICKNESS 4.5
#define NL_CLOUD2_STEPS 4
#define NL_CLOUD2_SCALE vec2(0.028, 0.028)
#define NL_CLOUD2_SHAPE vec2(0.5, 0.38)
#define NL_CLOUD2_DENSITY 22.0
#define NL_CLOUD2_VELOCITY 0.7
#define NL_CLOUD3_SCALE vec2(0.024, 0.024)
#define NL_CLOUD3_SPEED 0.006
#define NL_CLOUD3_SHADOW 0.65
#define NL_CLOUD3_SHADOW_OFFSET 0.30
#define NL_CLOUD0_THICKNESS 2.2
#define NL_CLOUD0_RAIN_THICKNESS 5.0
#define NL_CLOUD0_OPACITY 0.92
#define NL_CLOUD0_MULTILAYER

/* No aurora */
#define NL_AURORA_VELOCITY 0.03
#define NL_AURORA_SCALE 0.04
#define NL_AURORA_WIDTH 0.18
#define NL_AURORA_COL1 vec3(0.1,1.0,0.0)
#define NL_AURORA_COL2 vec3(0.1,0.0,1.0)

/* Stars */
#define NL_SHOOTING_STAR 0.7
#define NL_SHOOTING_STAR_PERIOD 5.0
#define NL_SHOOTING_STAR_DELAY 40.0
#define NL_GALAXY_VIBRANCE 0.60
#define NL_GALAXY_SPEED 0.018
#define NL_GALAXY_DAY_VISIBILITY 0.0
#define NL_RAINBOW
#define NL_RAINBOW_CLEAR 0.08
#define NL_RAINBOW_RAIN  0.80

/* Sun/Moon — massive tropical sun */
#define NL_SUN_SIZE  1.5
#define NL_MOON_SIZE 1.1
#define NL_SUN_PATH_YAW    12.0
#define NL_MOON_PATH_YAW   16.0
#define NL_SUN_PATH_TILT   35.0
#define NL_MOON_PATH_TILT -28.0
#define NL_SUN_TILT        45.0
#define NL_MOON_TILT       45.0
#define NL_GROUND_RAIN_WETNESS 0.70
#define NL_GROUND_RAIN_PUDDLES 0.50

/* Entity */
#define NL_ENTITY_BRIGHTNESS     0.85
#define NL_ENTITY_EDGE_HIGHLIGHT 0.30

/* Weather */
#define NL_WEATHER_SPECK 0.60
#define NL_WEATHER_RAIN_SLANT 2.5
#define NL_WEATHER_PARTICLE_SIZE 0.9

/* Lava */
#define NL_LAVA_NOISE
#define NL_LAVA_NOISE_SPEED 0.20
$SUBPACKS
CFGEOF

write_toml "Piglix Tropical Paradise" "e3f4a5b6-c7d8-9012-e3f4-a5b6c7d89012" \
  "§aPiglix · Tropical Paradise Shader" \
  "§7- Blazing sun. Azure sky. Crystal turquoise water."
build_shader "Piglix Tropical Paradise" "Piglix_Tropical_Paradise.mcpack" \
  "E3F4A5B6-C7D8-9012-E3F4-A5B6C7D89012" \
  "§aPiglix · Tropical Paradise\n§7Blazing sun. Azure sky. Crystal turquoise water.\nv1.0-perf"

# ════════════════════════════════════════════
# 4. FALLOUT ZONE — Nuclear Wasteland
#    Toxic yellow-green haze. Desaturated world.
#    Only neon green glows — everything else is ash.
# ════════════════════════════════════════════
cat > "$CONFIG" << CFGEOF
#ifndef NL_CONFIG_H
#define NL_CONFIG_H
// PIGLIX · FALLOUT ZONE — Nuclear Wasteland Shader

/* Color correction — toxic desaturated world */
#define NL_TONEMAP_TYPE 4
#define NL_GAMMA 1.02
#define NL_EXPOSURE 0.78
#define NL_SATURATION 0.45
#define NL_TINT
#define NL_TINT_LOW  vec3(0.60,0.70,0.45)
#define NL_TINT_HIGH vec3(0.85,0.95,0.55)

/* Lighting — toxic pale weak sun */
#define NL_SUNLIGHT_INTENSITY   2.0
#define NL_TORCHLIGHT_INTENSITY 3.5
#define NL_SHADOW_INTENSITY     0.85
#define NL_MIN_LIGHTING_BOOST   1.2
#define NL_BLINKING_TORCH

/* Ambient */
#define NL_NETHER_AMBIENT vec3(1.8,0.8,0.2)
#define NL_END_AMBIENT    vec3(0.4,0.8,0.3)

/* Sun/Moon — sickly toxic pale sun */
#define NL_DAWN_SUNLIGHT_COL   vec3(1.00,1.00,0.30)
#define NL_NOON_SUNLIGHT_COL   vec3(0.90,1.00,0.55)
#define NL_NIGHT_MOONLIGHT_COL vec3(0.04,0.06,0.02)

/* Torch — TOXIC NEON GREEN — the only color! */
#define NL_OVERWORLD_TORCH_COL  vec3(0.10,2.50,0.15)
#define NL_UNDERWATER_TORCH_COL vec3(0.08,2.00,0.12)
#define NL_NETHER_TORCH_COL     vec3(1.80,0.60,0.05)
#define NL_END_TORCH_COL        vec3(0.20,2.20,0.20)

/* Fog — toxic acid green haze */
#define NL_FOG 1.0
#define NL_MIST_DENSITY 0.42
#define NL_RAIN_MIST_OPACITY 0.55
#define NL_CLOUDY_FOG 0.48

/* Sky — toxic yellow-green nuclear haze */
#define NL_SKY_VOID_FACTOR     0.65
#define NL_SKY_VOID_DARKNESS   0.50
#define NL_SKY_RAIN_MIX_FACTOR 1.0
/* Dawn — sickly green-yellow nuclear morning */
#define NL_DAWN_ZENITH_COL   vec3(0.18,0.22,0.08)
#define NL_DAWN_HORIZON_COL  vec3(0.55,0.60,0.08)
#define NL_DAWN_EDGE_COL     vec3(0.80,0.90,0.10)
/* Day — toxic yellow-green haze sky */
#define NL_DAY_ZENITH_COL    vec3(0.22,0.28,0.10)
#define NL_DAY_HORIZON_COL   vec3(0.60,0.72,0.18)
#define NL_DAY_EDGE_COL      vec3(0.82,0.95,0.20)
/* Night — dark toxic night */
#define NL_NIGHT_ZENITH_COL  vec3(0.004,0.006,0.002)
#define NL_NIGHT_HORIZON_COL vec3(0.010,0.016,0.004)
#define NL_NIGHT_EDGE_COL    vec3(0.018,0.028,0.006)
/* Rain — acid rain green fog */
#define NL_RAIN_ZENITH_COL   vec3(0.18,0.22,0.08)
#define NL_RAIN_HORIZON_COL  vec3(0.35,0.42,0.12)
#define NL_END_ZENITH_COL    vec3(0.02,0.08,0.02)
#define NL_END_HORIZON_COL   vec3(0.10,0.35,0.10)

/* Glow — ores glow toxic neon green */
#define NL_GLOW_TEX 5.0
#define NL_GLOW_SHIMMER 1.0
#define NL_GLOW_SHIMMER_SPEED 1.8

/* Waving — toxic wind */
#define NL_PLANTS_WAVE 0.10
#define NL_LANTERN_WAVE 0.20
#define NL_WAVE_SPEED 2.5
#define NL_WAVE_RANGE 8.0

/* Water — toxic murky acid water */
#define NL_WATER_TRANSPARENCY 0.60
#define NL_WATER_BUMP 0.10
#define NL_WATER_WAVE_SPEED  0.6
#define NL_WATER_TEX_OPACITY 0.20
#define NL_WATER_WAVE
#define NL_WATER_TINT vec3(0.22,0.48,0.12)

/* Underwater — toxic acid pool */
#define NL_UNDERWATER_BRIGHTNESS 0.6
#define NL_CAUSTIC_INTENSITY 1.5
#define NL_UNDERWATER_WAVE 0.09
#define NL_UNDERWATER_TINT vec3(0.20,0.45,0.12)

/* Clouds — heavy toxic overcast */
#define NL_CLOUD_TYPE 1
#define NL_CLOUD1_SCALE vec2(0.020, 0.026)
#define NL_CLOUD1_DEPTH 2.2
#define NL_CLOUD1_SPEED 0.04
#define NL_CLOUD1_DENSITY 0.75
#define NL_CLOUD1_OPACITY 0.96
#define NL_CLOUD2_THICKNESS 3.5
#define NL_CLOUD2_RAIN_THICKNESS 6.5
#define NL_CLOUD2_STEPS 4
#define NL_CLOUD2_SCALE vec2(0.025, 0.025)
#define NL_CLOUD2_SHAPE vec2(0.65, 0.28)
#define NL_CLOUD2_DENSITY 32.0
#define NL_CLOUD2_VELOCITY 1.0
#define NL_CLOUD3_SCALE vec2(0.022, 0.022)
#define NL_CLOUD3_SPEED 0.010
#define NL_CLOUD3_SHADOW 0.95
#define NL_CLOUD3_SHADOW_OFFSET 0.42
#define NL_CLOUD0_THICKNESS 4.0
#define NL_CLOUD0_RAIN_THICKNESS 7.0
#define NL_CLOUD0_OPACITY 1.0
#define NL_CLOUD0_MULTILAYER

/* No aurora */
#define NL_AURORA_VELOCITY 0.02
#define NL_AURORA_SCALE 0.04
#define NL_AURORA_WIDTH 0.15
#define NL_AURORA_COL1 vec3(0.1,1.0,0.1)
#define NL_AURORA_COL2 vec3(0.5,1.0,0.1)

/* Stars — hidden by toxic sky */
#define NL_SHOOTING_STAR 0.2
#define NL_SHOOTING_STAR_PERIOD 10.0
#define NL_SHOOTING_STAR_DELAY 150.0
#define NL_GALAXY_VIBRANCE 0.10
#define NL_GALAXY_SPEED 0.01
#define NL_GALAXY_DAY_VISIBILITY 0.0
//#define NL_RAINBOW
#define NL_RAINBOW_CLEAR 0.0
#define NL_RAINBOW_RAIN  0.0

/* Sun/Moon */
#define NL_SUN_SIZE  0.75
#define NL_MOON_SIZE 0.85
#define NL_SUN_PATH_YAW    15.0
#define NL_MOON_PATH_YAW   17.0
#define NL_SUN_PATH_TILT   31.0
#define NL_MOON_PATH_TILT -28.0
#define NL_SUN_TILT        45.0
#define NL_MOON_TILT       45.0
#define NL_GROUND_RAIN_WETNESS 1.0
#define NL_GROUND_RAIN_PUDDLES 0.85

/* Entity */
#define NL_ENTITY_BRIGHTNESS     0.58
#define NL_ENTITY_EDGE_HIGHLIGHT 0.55

/* Weather — acid rain */
#define NL_WEATHER_SPECK 0.80
#define NL_WEATHER_RAIN_SLANT 5.5
#define NL_WEATHER_PARTICLE_SIZE 1.2

/* Lava */
#define NL_LAVA_NOISE
#define NL_LAVA_NOISE_SPEED 0.22
$SUBPACKS
CFGEOF

write_toml "Piglix Fallout Zone" "f4a5b6c7-d8e9-0123-f4a5-b6c7d8e90123" \
  "§2Piglix · Fallout Zone Shader" \
  "§7- Toxic haze. Desaturated world. Neon green glow."
build_shader "Piglix Fallout Zone" "Piglix_Fallout_Zone.mcpack" \
  "F4A5B6C7-D8E9-0123-F4A5-B6C7D8E90123" \
  "§2Piglix · Fallout Zone\n§7Toxic haze. Desaturated world. Neon green glow.\nv1.0-perf"

# ════════════════════════════════════════════
# 5. LOST WORLD — Ancient Prehistoric Jungle
#    Dark green fog. Dramatic god-rays.
#    Murky jungle river. Wild and ancient.
# ════════════════════════════════════════════
cat > "$CONFIG" << CFGEOF
#ifndef NL_CONFIG_H
#define NL_CONFIG_H
// PIGLIX · LOST WORLD — Ancient Prehistoric Jungle Shader

/* Color correction — dark lush cinematic green */
#define NL_TONEMAP_TYPE 4
#define NL_GAMMA 1.05
#define NL_EXPOSURE 0.85
#define NL_SATURATION 1.25
#define NL_TINT
#define NL_TINT_LOW  vec3(0.45,0.70,0.40)
#define NL_TINT_HIGH vec3(0.85,1.00,0.55)

/* Lighting — dramatic rays through dense canopy */
#define NL_SUNLIGHT_INTENSITY   3.0
#define NL_TORCHLIGHT_INTENSITY 2.0
#define NL_SHADOW_INTENSITY     0.90
#define NL_MIN_LIGHTING_BOOST   1.3
#define NL_BLINKING_TORCH
#define NL_CLOUD_SHADOW

/* Ambient */
#define NL_NETHER_AMBIENT vec3(2.0,0.9,0.3)
#define NL_END_AMBIENT    vec3(0.5,0.8,0.3)

/* Sun/Moon — warm sun filtered through canopy */
#define NL_DAWN_SUNLIGHT_COL   vec3(1.60,0.90,0.30)
#define NL_NOON_SUNLIGHT_COL   vec3(1.20,1.30,0.65)
#define NL_NIGHT_MOONLIGHT_COL vec3(0.04,0.07,0.03)

/* Torch — warm survival fire in the dark jungle */
#define NL_OVERWORLD_TORCH_COL  vec3(1.80,0.80,0.18)
#define NL_UNDERWATER_TORCH_COL vec3(1.20,0.60,0.15)
#define NL_NETHER_TORCH_COL     vec3(2.20,0.70,0.08)
#define NL_END_TORCH_COL        vec3(0.80,0.45,1.40)

/* Fog — dense jungle green canopy mist */
#define NL_FOG 1.0
#define NL_MIST_DENSITY 0.48
#define NL_RAIN_MIST_OPACITY 0.52
#define NL_CLOUDY_FOG 0.55

/* Sky — barely visible through green jungle haze */
#define NL_SKY_VOID_FACTOR     0.70
#define NL_SKY_VOID_DARKNESS   0.55
#define NL_SKY_RAIN_MIX_FACTOR 0.95
/* Dawn — green-gold jungle sunrise */
#define NL_DAWN_ZENITH_COL   vec3(0.20,0.25,0.12)
#define NL_DAWN_HORIZON_COL  vec3(0.80,0.65,0.18)
#define NL_DAWN_EDGE_COL     vec3(1.20,0.95,0.22)
/* Day — dark deep green jungle canopy sky */
#define NL_DAY_ZENITH_COL    vec3(0.18,0.38,0.20)
#define NL_DAY_HORIZON_COL   vec3(0.45,0.62,0.28)
#define NL_DAY_EDGE_COL      vec3(0.70,0.85,0.35)
/* Night — true dark jungle night */
#define NL_NIGHT_ZENITH_COL  vec3(0.002,0.005,0.002)
#define NL_NIGHT_HORIZON_COL vec3(0.005,0.012,0.004)
#define NL_NIGHT_EDGE_COL    vec3(0.008,0.020,0.006)
/* Rain — thick dark jungle storm */
#define NL_RAIN_ZENITH_COL   vec3(0.12,0.18,0.10)
#define NL_RAIN_HORIZON_COL  vec3(0.25,0.32,0.18)
#define NL_END_ZENITH_COL    vec3(0.02,0.06,0.02)
#define NL_END_HORIZON_COL   vec3(0.15,0.40,0.10)

/* Glow — bioluminescent jungle ores */
#define NL_GLOW_TEX 3.8
#define NL_GLOW_SHIMMER 1.0
#define NL_GLOW_SHIMMER_SPEED 0.7

/* Waving — thick heavy jungle wind */
#define NL_PLANTS_WAVE 0.11
#define NL_LANTERN_WAVE 0.24
#define NL_WAVE_SPEED 1.8
#define NL_WAVE_RANGE 8.0

/* Water — dark murky jungle river */
#define NL_WATER_TRANSPARENCY 0.55
#define NL_WATER_BUMP 0.11
#define NL_WATER_WAVE_SPEED  0.55
#define NL_WATER_TEX_OPACITY 0.30
#define NL_WATER_WAVE
#define NL_WATER_TINT vec3(0.22,0.42,0.18)

/* Underwater — murky dark green river */
#define NL_UNDERWATER_BRIGHTNESS 0.6
#define NL_CAUSTIC_INTENSITY 1.8
#define NL_UNDERWATER_WAVE 0.10
#define NL_UNDERWATER_TINT vec3(0.20,0.40,0.16)

/* Clouds — heavy jungle overcast clouds */
#define NL_CLOUD_TYPE 1
#define NL_CLOUD1_SCALE vec2(0.018, 0.024)
#define NL_CLOUD1_DEPTH 1.9
#define NL_CLOUD1_SPEED 0.035
#define NL_CLOUD1_DENSITY 0.68
#define NL_CLOUD1_OPACITY 0.96
#define NL_CLOUD2_THICKNESS 3.2
#define NL_CLOUD2_RAIN_THICKNESS 6.0
#define NL_CLOUD2_STEPS 4
#define NL_CLOUD2_SCALE vec2(0.024, 0.024)
#define NL_CLOUD2_SHAPE vec2(0.62, 0.30)
#define NL_CLOUD2_DENSITY 30.0
#define NL_CLOUD2_VELOCITY 0.9
#define NL_CLOUD3_SCALE vec2(0.020, 0.020)
#define NL_CLOUD3_SPEED 0.009
#define NL_CLOUD3_SHADOW 1.0
#define NL_CLOUD3_SHADOW_OFFSET 0.45
#define NL_CLOUD0_THICKNESS 3.5
#define NL_CLOUD0_RAIN_THICKNESS 6.5
#define NL_CLOUD0_OPACITY 0.98
#define NL_CLOUD0_MULTILAYER

/* No aurora */
#define NL_AURORA_VELOCITY 0.02
#define NL_AURORA_SCALE 0.04
#define NL_AURORA_WIDTH 0.15
#define NL_AURORA_COL1 vec3(0.1,1.0,0.1)
#define NL_AURORA_COL2 vec3(0.1,0.5,0.1)

/* Stars — barely visible through jungle canopy */
#define NL_SHOOTING_STAR 0.4
#define NL_SHOOTING_STAR_PERIOD 8.0
#define NL_SHOOTING_STAR_DELAY 80.0
#define NL_GALAXY_VIBRANCE 0.30
#define NL_GALAXY_SPEED 0.012
#define NL_GALAXY_DAY_VISIBILITY 0.0
//#define NL_RAINBOW
#define NL_RAINBOW_CLEAR 0.0
#define NL_RAINBOW_RAIN  0.0

/* Sun/Moon */
#define NL_SUN_SIZE  0.90
#define NL_MOON_SIZE 0.95
#define NL_SUN_PATH_YAW    15.0
#define NL_MOON_PATH_YAW   17.0
#define NL_SUN_PATH_TILT   38.0
#define NL_MOON_PATH_TILT -30.0
#define NL_SUN_TILT        45.0
#define NL_MOON_TILT       45.0
#define NL_GROUND_RAIN_WETNESS 1.0
#define NL_GROUND_RAIN_PUDDLES 0.85

/* Entity */
#define NL_ENTITY_BRIGHTNESS     0.62
#define NL_ENTITY_EDGE_HIGHLIGHT 0.50

/* Weather — heavy tropical storm */
#define NL_WEATHER_SPECK 0.90
#define NL_WEATHER_RAIN_SLANT 5.0
#define NL_WEATHER_PARTICLE_SIZE 1.3

/* Lava */
#define NL_LAVA_NOISE
#define NL_LAVA_NOISE_SPEED 0.20
$SUBPACKS
CFGEOF

write_toml "Piglix Lost World" "a5b6c7d8-e9f0-1234-a5b6-c7d8e9f01234" \
  "§2Piglix · Lost World Shader" \
  "§7- Ancient jungle. Dense fog. Murky rivers. Danger."
build_shader "Piglix Lost World" "Piglix_Lost_World.mcpack" \
  "A5B6C7D8-E9F0-1234-A5B6-C7D8E9F01234" \
  "§2Piglix · Lost World\n§7Ancient jungle. Dense fog. Murky rivers. Danger.\nv1.0-perf"

echo ""
echo "✅ All 5 new shaders built successfully!"
echo "📦 Sakura Dream | Neon Tokyo | Tropical Paradise | Fallout Zone | Lost World"
echo "📁 Files saved to: $OUT_DIR"
