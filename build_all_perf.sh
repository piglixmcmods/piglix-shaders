#!/bin/bash
# ═══════════════════════════════════════════════
# Piglix Shader Collection — Performance Rebuild
# Rebuilds all 4 shaders with mobile optimizations
# ═══════════════════════════════════════════════

set -e
NEWB_DIR="/Users/sopanvijaypatil/Downloads/Newb_X_Pink_Atmosphere_android/newb-source"
PACK_DIR="/Users/sopanvijaypatil/Downloads/Newb_X_Pink_Atmosphere_android/piglix-rtx-shader"
OUT_DIR="/Users/sopanvijaypatil/Downloads"
CONFIG="$NEWB_DIR/src/newb/config.h"
TOML="$NEWB_DIR/src/newb/pack_config.toml"

build_shader() {
  local name="$1"
  local filename="$2"
  local uuid="$3"
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
data['header']['uuid']='$uuid'
data['modules'][0]['uuid']=str(uuidlib.uuid4()).upper()
data['header']['name']='$name'
data['header']['description']='$desc'
json.dump(data, open(f,'w'), indent=2)
"
  rm -f "$OUT_DIR/$filename"
  zip -r "$OUT_DIR/$filename" . -x ".*" > /dev/null
  echo "<<< Done: $filename"
}

# ═══════════════════════════
# 1. ASH & EMBER (Performance)
# ═══════════════════════════
cat > "$CONFIG" << 'CFGEOF'
#ifndef NL_CONFIG_H
#define NL_CONFIG_H
// PIGLIX · ASH & EMBER — Performance Edition
// All colors preserved. Heavy GPU effects removed for 60fps mobile.

/* Color correction */
#define NL_TONEMAP_TYPE 4
#define NL_GAMMA 1.05
#define NL_EXPOSURE 0.82
#define NL_SATURATION 0.62
#define NL_TINT
#define NL_TINT_LOW  vec3(0.55,0.6,0.85)
#define NL_TINT_HIGH vec3(1.1,0.9,0.7)

/* Lighting */
#define NL_SUNLIGHT_INTENSITY   1.6
#define NL_TORCHLIGHT_INTENSITY 2.4
#define NL_SHADOW_INTENSITY     0.95
#define NL_MIN_LIGHTING_BOOST   1.0
#define NL_BLINKING_TORCH
// NL_CLOUD_SHADOW removed — perf

/* Ambient */
#define NL_NETHER_AMBIENT vec3(2.2,0.9,0.3)
#define NL_END_AMBIENT    vec3(0.6,0.3,1.0)

/* Sun/Moon */
#define NL_DAWN_SUNLIGHT_COL   vec3(1.6,0.55,0.15)
#define NL_NOON_SUNLIGHT_COL   vec3(1.1,0.95,0.70)
#define NL_NIGHT_MOONLIGHT_COL vec3(0.001,0.002,0.006)

/* Torch */
#define NL_OVERWORLD_TORCH_COL  vec3(2.0,0.70,0.08)
#define NL_UNDERWATER_TORCH_COL vec3(1.2,0.50,0.10)
#define NL_NETHER_TORCH_COL     vec3(2.5,0.80,0.05)
#define NL_END_TORCH_COL        vec3(0.9,0.50,1.40)

/* Fog — kept but optimized */
#define NL_FOG 1.0
#define NL_MIST_DENSITY 0.46
#define NL_RAIN_MIST_OPACITY 0.35
#define NL_CLOUDY_FOG 0.55

/* Sky */
#define NL_SKY_VOID_FACTOR     0.8
#define NL_SKY_VOID_DARKNESS   0.7
#define NL_SKY_RAIN_MIX_FACTOR 1.0
#define NL_DAWN_ZENITH_COL   vec3(0.22,0.12,0.08)
#define NL_DAWN_HORIZON_COL  vec3(1.10,0.35,0.05)
#define NL_DAWN_EDGE_COL     vec3(1.80,0.50,0.02)
#define NL_DAY_ZENITH_COL    vec3(0.28,0.26,0.22)
#define NL_DAY_HORIZON_COL   vec3(0.65,0.55,0.42)
#define NL_DAY_EDGE_COL      vec3(0.90,0.70,0.40)
#define NL_NIGHT_ZENITH_COL  vec3(0.001,0.001,0.003)
#define NL_NIGHT_HORIZON_COL vec3(0.003,0.003,0.008)
#define NL_NIGHT_EDGE_COL    vec3(0.005,0.004,0.010)
#define NL_RAIN_ZENITH_COL   vec3(0.10,0.09,0.08)
#define NL_RAIN_HORIZON_COL  vec3(0.22,0.20,0.18)
#define NL_END_ZENITH_COL    vec3(0.02,0.005,0.05)
#define NL_END_HORIZON_COL   vec3(0.35,0.05,0.50)

/* Ore glow — shimmer removed for perf */
#define NL_GLOW_TEX 3.5
// #define NL_GLOW_SHIMMER removed — perf
// #define NL_GLOW_LEAK removed — perf

/* Waving — range reduced for perf */
#define NL_PLANTS_WAVE 0.09
#define NL_LANTERN_WAVE 0.22
#define NL_WAVE_SPEED 1.8
#define NL_WAVE_RANGE 8.0

/* Water — reflection removed for perf */
#define NL_WATER_TRANSPARENCY 0.65
#define NL_WATER_BUMP 0.12
#define NL_WATER_WAVE_SPEED  0.6
#define NL_WATER_TEX_OPACITY 0.2
#define NL_WATER_WAVE
// #define NL_WATER_REFL_MASK removed — perf
#define NL_WATER_TINT vec3(0.25,0.30,0.40)

/* Underwater */
#define NL_UNDERWATER_BRIGHTNESS 0.2
#define NL_CAUSTIC_INTENSITY 0.6
#define NL_UNDERWATER_WAVE 0.12
// #define NL_UNDERWATER_STREAKS removed — perf
#define NL_UNDERWATER_TINT vec3(0.3,0.38,0.55)

/* Clouds — SOFT (type 1) for performance */
#define NL_CLOUD_TYPE 1
#define NL_CLOUD1_SCALE vec2(0.018, 0.024)
#define NL_CLOUD1_DEPTH 2.0
#define NL_CLOUD1_SPEED 0.03
#define NL_CLOUD1_DENSITY 0.68
#define NL_CLOUD1_OPACITY 0.95
#define NL_CLOUD2_THICKNESS 3.0
#define NL_CLOUD2_RAIN_THICKNESS 4.5
#define NL_CLOUD2_STEPS 4
#define NL_CLOUD2_SCALE vec2(0.028, 0.028)
#define NL_CLOUD2_SHAPE vec2(0.6, 0.3)
#define NL_CLOUD2_DENSITY 30.0
#define NL_CLOUD2_VELOCITY 0.5
#define NL_CLOUD3_SCALE vec2(0.022, 0.022)
#define NL_CLOUD3_SPEED 0.009
#define NL_CLOUD3_SHADOW 1.0
#define NL_CLOUD3_SHADOW_OFFSET 0.4
#define NL_CLOUD0_THICKNESS 3.5
#define NL_CLOUD0_RAIN_THICKNESS 6.0
#define NL_CLOUD0_OPACITY 1.0
#define NL_CLOUD0_MULTILAYER

/* Aurora — disabled for perf */
// #define NL_AURORA removed — perf
#define NL_AURORA_VELOCITY 0.01
#define NL_AURORA_SCALE 0.05
#define NL_AURORA_WIDTH 0.12
#define NL_AURORA_COL1 vec3(0.8,0.10,0.0)
#define NL_AURORA_COL2 vec3(0.05,0.20,0.0)
// #define NL_CLOUD_AURORA_REFLECTION removed — perf

/* Stars */
#define NL_SHOOTING_STAR 0.4
#define NL_SHOOTING_STAR_PERIOD 8.0
#define NL_SHOOTING_STAR_DELAY 120.0
// #define NL_GALAXY_STARS removed — perf
#define NL_GALAXY_VIBRANCE 0.0
#define NL_GALAXY_SPEED 0.01
#define NL_GALAXY_DAY_VISIBILITY 0.0

/* Sun/Moon */
#define NL_SUN_SIZE  0.65
#define NL_MOON_SIZE 1.8
#define NL_SUN_PATH_YAW    12.0
#define NL_MOON_PATH_YAW   18.0
#define NL_SUN_PATH_TILT   28.0
#define NL_MOON_PATH_TILT -25.0
#define NL_SUN_TILT        40.0
#define NL_MOON_TILT       40.0
// #define NL_GODRAY removed — perf
// #define NL_GROUND_REFL removed — perf
#define NL_GROUND_RAIN_WETNESS 1.0
#define NL_GROUND_RAIN_PUDDLES 0.9

/* Entity */
#define NL_ENTITY_BRIGHTNESS     0.55
#define NL_ENTITY_EDGE_HIGHLIGHT 0.70

/* Weather */
#define NL_WEATHER_SPECK 0.8
#define NL_WEATHER_RAIN_SLANT 6.0
#define NL_WEATHER_PARTICLE_SIZE 1.4

/* Lava */
#define NL_LAVA_NOISE
#define NL_LAVA_NOISE_SPEED 0.15

/* Subpacks */
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
#endif
CFGEOF

cat > "$TOML" << 'TOMLEOF'
name = "Piglix Ash & Ember"
version = [1, 0, 0]
min_supported_mc_version = [1, 26, 40]
description = '''
§4Piglix · Ash & Ember Shader
§7- Dark fantasy. Fire is the only warmth.
%v
§3https://piglix.app/
'''
authors = ["Piglix"]
url = "https://piglix.app/"
uuid = "a3f7c219-5b4e-4d8a-b6c1-2e9f0d1a8b35"
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
description = 'No fog and wave effects'
[[subpack]]
define = "NO_FOG"
materials = ["RenderChunk"]
description = 'No fog effect'
[[subpack]]
define = "NO_WAVE"
materials = ["RenderChunk"]
description = 'No wave effects'
[[subpack]]
define = "DEFAULT"
materials = []
description = 'Default'
TOMLEOF

build_shader "Piglix Ash & Ember" "Piglix_Ash_and_Ember.mcpack" \
  "A3F7C219-5B4E-4D8A-B6C1-2E9F0D1A8B35" \
  "§4Piglix · Ash & Ember\n§7Dark fantasy. Fire is the only warmth.\nv1.0-perf"

# ═══════════════════════════════
# 2. ARABIAN NIGHTS (Performance)
# ═══════════════════════════════
cat > "$CONFIG" << 'CFGEOF'
#ifndef NL_CONFIG_H
#define NL_CONFIG_H
// PIGLIX · ARABIAN NIGHTS — Performance Edition

/* Color correction */
#define NL_TONEMAP_TYPE 4
#define NL_GAMMA 1.15
#define NL_EXPOSURE 1.05
#define NL_SATURATION 1.45
#define NL_TINT
#define NL_TINT_LOW  vec3(1.0,0.70,0.35)
#define NL_TINT_HIGH vec3(1.4,1.15,0.65)

/* Lighting */
#define NL_SUNLIGHT_INTENSITY   4.2
#define NL_TORCHLIGHT_INTENSITY 1.8
#define NL_SHADOW_INTENSITY     0.75
#define NL_MIN_LIGHTING_BOOST   1.8
#define NL_BLINKING_TORCH

/* Ambient */
#define NL_NETHER_AMBIENT vec3(2.5,1.2,0.3)
#define NL_END_AMBIENT    vec3(0.8,0.4,1.2)

/* Sun/Moon */
#define NL_DAWN_SUNLIGHT_COL   vec3(2.0,0.85,0.20)
#define NL_NOON_SUNLIGHT_COL   vec3(1.8,1.50,0.80)
#define NL_NIGHT_MOONLIGHT_COL vec3(0.18,0.14,0.06)

/* Torch */
#define NL_OVERWORLD_TORCH_COL  vec3(1.8,0.95,0.25)
#define NL_UNDERWATER_TORCH_COL vec3(1.4,0.75,0.20)
#define NL_NETHER_TORCH_COL     vec3(2.2,0.80,0.10)
#define NL_END_TORCH_COL        vec3(1.2,0.60,1.80)

/* Fog */
#define NL_FOG 1.0
#define NL_MIST_DENSITY 0.28
#define NL_RAIN_MIST_OPACITY 0.40
#define NL_CLOUDY_FOG 0.30

/* Sky */
#define NL_SKY_VOID_FACTOR     0.55
#define NL_SKY_VOID_DARKNESS   0.35
#define NL_SKY_RAIN_MIX_FACTOR 0.85
#define NL_DAWN_ZENITH_COL   vec3(0.35,0.18,0.05)
#define NL_DAWN_HORIZON_COL  vec3(1.80,0.70,0.08)
#define NL_DAWN_EDGE_COL     vec3(2.50,1.00,0.10)
#define NL_DAY_ZENITH_COL    vec3(0.38,0.62,1.40)
#define NL_DAY_HORIZON_COL   vec3(1.20,1.00,0.60)
#define NL_DAY_EDGE_COL      vec3(1.80,1.40,0.60)
#define NL_NIGHT_ZENITH_COL  vec3(0.006,0.004,0.025)
#define NL_NIGHT_HORIZON_COL vec3(0.020,0.012,0.055)
#define NL_NIGHT_EDGE_COL    vec3(0.045,0.025,0.080)
#define NL_RAIN_ZENITH_COL   vec3(0.38,0.30,0.18)
#define NL_RAIN_HORIZON_COL  vec3(0.65,0.52,0.28)
#define NL_END_ZENITH_COL    vec3(0.05,0.01,0.10)
#define NL_END_HORIZON_COL   vec3(0.50,0.08,0.65)

/* Ore glow */
#define NL_GLOW_TEX 3.8
// shimmer & leak removed for perf

/* Waving */
#define NL_PLANTS_WAVE 0.07
#define NL_LANTERN_WAVE 0.28
#define NL_WAVE_SPEED 2.2
#define NL_WAVE_RANGE 8.0

/* Water — no reflection for perf */
#define NL_WATER_TRANSPARENCY 0.75
#define NL_WATER_BUMP 0.10
#define NL_WATER_WAVE_SPEED  0.7
#define NL_WATER_TEX_OPACITY 0.25
#define NL_WATER_WAVE
#define NL_WATER_TINT vec3(0.85,0.68,0.20)

/* Underwater */
#define NL_UNDERWATER_BRIGHTNESS 1.4
#define NL_CAUSTIC_INTENSITY 3.2
#define NL_UNDERWATER_WAVE 0.08
#define NL_UNDERWATER_TINT vec3(0.90,0.72,0.35)

/* Clouds — SOFT for perf */
#define NL_CLOUD_TYPE 1
#define NL_CLOUD1_SCALE vec2(0.015, 0.020)
#define NL_CLOUD1_DEPTH 1.5
#define NL_CLOUD1_SPEED 0.04
#define NL_CLOUD1_DENSITY 0.50
#define NL_CLOUD1_OPACITY 0.85
#define NL_CLOUD2_THICKNESS 2.5
#define NL_CLOUD2_RAIN_THICKNESS 5.0
#define NL_CLOUD2_STEPS 4
#define NL_CLOUD2_SCALE vec2(0.025, 0.025)
#define NL_CLOUD2_SHAPE vec2(0.55, 0.35)
#define NL_CLOUD2_DENSITY 28.0
#define NL_CLOUD2_VELOCITY 0.6
#define NL_CLOUD3_SCALE vec2(0.020, 0.020)
#define NL_CLOUD3_SPEED 0.007
#define NL_CLOUD3_SHADOW 0.75
#define NL_CLOUD3_SHADOW_OFFSET 0.35
#define NL_CLOUD0_THICKNESS 2.5
#define NL_CLOUD0_RAIN_THICKNESS 5.5
#define NL_CLOUD0_OPACITY 0.9
#define NL_CLOUD0_MULTILAYER

/* Aurora — disabled */
// removed for perf
#define NL_AURORA_VELOCITY 0.015
#define NL_AURORA_SCALE 0.04
#define NL_AURORA_WIDTH 0.10
#define NL_AURORA_COL1 vec3(0.9,0.60,0.0)
#define NL_AURORA_COL2 vec3(0.6,0.10,0.5)

/* Stars */
#define NL_SHOOTING_STAR 0.9
#define NL_SHOOTING_STAR_PERIOD 5.0
#define NL_SHOOTING_STAR_DELAY 18.0
// NL_GALAXY_STARS removed for perf
#define NL_GALAXY_VIBRANCE 0.85
#define NL_GALAXY_SPEED 0.02
#define NL_GALAXY_DAY_VISIBILITY 0.0
#define NL_RAINBOW
#define NL_RAINBOW_CLEAR 0.05
#define NL_RAINBOW_RAIN  0.65

/* Sun/Moon */
#define NL_SUN_SIZE  1.6
#define NL_MOON_SIZE 2.2
#define NL_SUN_PATH_YAW    10.0
#define NL_MOON_PATH_YAW   15.0
#define NL_SUN_PATH_TILT   30.0
#define NL_MOON_PATH_TILT -25.0
#define NL_SUN_TILT        42.0
#define NL_MOON_TILT       42.0
// NL_GODRAY removed for perf
// NL_GROUND_REFL removed for perf
#define NL_GROUND_RAIN_WETNESS 0.85
#define NL_GROUND_RAIN_PUDDLES 0.65

/* Entity */
#define NL_ENTITY_BRIGHTNESS     0.75
#define NL_ENTITY_EDGE_HIGHLIGHT 0.60

/* Weather */
#define NL_WEATHER_SPECK 0.9
#define NL_WEATHER_RAIN_SLANT 5.0
#define NL_WEATHER_PARTICLE_SIZE 1.2

/* Lava */
#define NL_LAVA_NOISE
#define NL_LAVA_NOISE_SPEED 0.25

/* Subpacks */
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
#endif
CFGEOF

sed -i '' 's/^name = .*/name = "Piglix Arabian Nights"/' "$TOML"
sed -i '' 's/^uuid = .*/uuid = "b7e2f451-8c3a-4f9b-d1e5-3a7c0b2d9f16"/' "$TOML"

build_shader "Piglix Arabian Nights" "Piglix_Arabian_Nights.mcpack" \
  "B7E2F451-8C3A-4F9B-D1E5-3A7C0B2D9F16" \
  "§6Piglix · Arabian Nights\n§7Desert gold. Giant moon. Shooting stars.\nv1.0-perf"

# ══════════════════════════════
# 3. PERMAFROST (Performance)
# ══════════════════════════════
cat > "$CONFIG" << 'CFGEOF'
#ifndef NL_CONFIG_H
#define NL_CONFIG_H
// PIGLIX · PERMAFROST — Performance Edition

/* Color correction */
#define NL_TONEMAP_TYPE 3
#define NL_GAMMA 1.08
#define NL_EXPOSURE 1.12
#define NL_SATURATION 0.80
#define NL_TINT
#define NL_TINT_LOW  vec3(0.45,0.60,1.10)
#define NL_TINT_HIGH vec3(0.90,0.96,1.30)

/* Lighting */
#define NL_SUNLIGHT_INTENSITY   2.8
#define NL_TORCHLIGHT_INTENSITY 2.2
#define NL_SHADOW_INTENSITY     0.82
#define NL_MIN_LIGHTING_BOOST   2.0
#define NL_BLINKING_TORCH

/* Ambient */
#define NL_NETHER_AMBIENT vec3(2.0,0.8,0.3)
#define NL_END_AMBIENT    vec3(0.5,0.3,0.9)

/* Sun/Moon */
#define NL_DAWN_SUNLIGHT_COL   vec3(1.30,0.95,0.80)
#define NL_NOON_SUNLIGHT_COL   vec3(1.10,1.20,1.50)
#define NL_NIGHT_MOONLIGHT_COL vec3(0.08,0.12,0.25)

/* Torch */
#define NL_OVERWORLD_TORCH_COL  vec3(1.9,0.80,0.22)
#define NL_UNDERWATER_TORCH_COL vec3(1.2,0.55,0.18)
#define NL_NETHER_TORCH_COL     vec3(2.4,0.75,0.08)
#define NL_END_TORCH_COL        vec3(0.8,0.45,1.60)

/* Fog */
#define NL_FOG 1.0
#define NL_MIST_DENSITY 0.32
#define NL_RAIN_MIST_OPACITY 0.50
#define NL_CLOUDY_FOG 0.25

/* Sky */
#define NL_SKY_VOID_FACTOR     0.60
#define NL_SKY_VOID_DARKNESS   0.45
#define NL_SKY_RAIN_MIX_FACTOR 0.95
#define NL_DAWN_ZENITH_COL   vec3(0.25,0.30,0.55)
#define NL_DAWN_HORIZON_COL  vec3(1.00,0.65,0.70)
#define NL_DAWN_EDGE_COL     vec3(1.20,0.80,0.60)
#define NL_DAY_ZENITH_COL    vec3(0.35,0.65,1.40)
#define NL_DAY_HORIZON_COL   vec3(0.75,0.90,1.30)
#define NL_DAY_EDGE_COL      vec3(0.90,0.95,1.20)
#define NL_NIGHT_ZENITH_COL  vec3(0.003,0.005,0.020)
#define NL_NIGHT_HORIZON_COL vec3(0.008,0.015,0.045)
#define NL_NIGHT_EDGE_COL    vec3(0.012,0.025,0.065)
#define NL_RAIN_ZENITH_COL   vec3(0.55,0.60,0.68)
#define NL_RAIN_HORIZON_COL  vec3(0.80,0.85,0.90)
#define NL_END_ZENITH_COL    vec3(0.03,0.01,0.08)
#define NL_END_HORIZON_COL   vec3(0.40,0.05,0.60)

/* Ore glow */
#define NL_GLOW_TEX 3.2
// shimmer & leak removed for perf

/* Waving */
#define NL_PLANTS_WAVE 0.12
#define NL_LANTERN_WAVE 0.32
#define NL_WAVE_SPEED 3.0
#define NL_WAVE_RANGE 8.0

/* Water */
#define NL_WATER_TRANSPARENCY 0.55
#define NL_WATER_BUMP 0.06
#define NL_WATER_WAVE_SPEED  0.3
#define NL_WATER_TEX_OPACITY 0.15
#define NL_WATER_WAVE
// NL_WATER_REFL_MASK removed for perf
#define NL_WATER_TINT vec3(0.18,0.42,0.65)

/* Underwater */
#define NL_UNDERWATER_BRIGHTNESS 0.5
#define NL_CAUSTIC_INTENSITY 1.4
#define NL_UNDERWATER_WAVE 0.06
#define NL_UNDERWATER_TINT vec3(0.25,0.50,0.85)

/* Clouds — SOFT for perf */
#define NL_CLOUD_TYPE 1
#define NL_CLOUD1_SCALE vec2(0.014, 0.018)
#define NL_CLOUD1_DEPTH 1.8
#define NL_CLOUD1_SPEED 0.06
#define NL_CLOUD1_DENSITY 0.62
#define NL_CLOUD1_OPACITY 0.95
#define NL_CLOUD2_THICKNESS 3.5
#define NL_CLOUD2_RAIN_THICKNESS 6.0
#define NL_CLOUD2_STEPS 4
#define NL_CLOUD2_SCALE vec2(0.022, 0.022)
#define NL_CLOUD2_SHAPE vec2(0.65, 0.25)
#define NL_CLOUD2_DENSITY 32.0
#define NL_CLOUD2_VELOCITY 1.0
#define NL_CLOUD3_SCALE vec2(0.018, 0.018)
#define NL_CLOUD3_SPEED 0.012
#define NL_CLOUD3_SHADOW 0.90
#define NL_CLOUD3_SHADOW_OFFSET 0.45
#define NL_CLOUD0_THICKNESS 4.0
#define NL_CLOUD0_RAIN_THICKNESS 7.0
#define NL_CLOUD0_OPACITY 1.0
#define NL_CLOUD0_MULTILAYER

/* Aurora — REDUCED for perf (kept because it's the main feature) */
#define NL_AURORA 2.0
#define NL_AURORA_VELOCITY 0.025
#define NL_AURORA_SCALE 0.035
#define NL_AURORA_WIDTH 0.22
#define NL_AURORA_COL1 vec3(0.05,1.20,0.25)
#define NL_AURORA_COL2 vec3(0.50,0.05,1.40)
// NL_CLOUD_AURORA_REFLECTION removed for perf

/* Stars */
#define NL_SHOOTING_STAR 0.7
#define NL_SHOOTING_STAR_PERIOD 6.0
#define NL_SHOOTING_STAR_DELAY 45.0
// NL_GALAXY_STARS removed for perf
#define NL_GALAXY_VIBRANCE 0.55
#define NL_GALAXY_SPEED 0.015
#define NL_GALAXY_DAY_VISIBILITY 0.0
//#define NL_RAINBOW
#define NL_RAINBOW_CLEAR 0.0
#define NL_RAINBOW_RAIN  0.0

/* Sun/Moon */
#define NL_SUN_SIZE  0.80
#define NL_MOON_SIZE 1.90
#define NL_SUN_PATH_YAW    8.0
#define NL_MOON_PATH_YAW   12.0
#define NL_SUN_PATH_TILT   22.0
#define NL_MOON_PATH_TILT -20.0
#define NL_SUN_TILT        35.0
#define NL_MOON_TILT       38.0
// NL_GODRAY removed for perf
// NL_GROUND_REFL removed for perf
#define NL_GROUND_RAIN_WETNESS 1.0
#define NL_GROUND_RAIN_PUDDLES 0.80

/* Entity */
#define NL_ENTITY_BRIGHTNESS     0.70
#define NL_ENTITY_EDGE_HIGHLIGHT 0.65

/* Weather */
#define NL_WEATHER_SPECK 1.0
#define NL_WEATHER_RAIN_SLANT 7.0
#define NL_WEATHER_PARTICLE_SIZE 1.6

/* Lava */
#define NL_LAVA_NOISE
#define NL_LAVA_NOISE_SPEED 0.30

/* Subpacks */
#ifdef LITE
  #define NO_WAVE
  #undef NL_AURORA
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
#endif
CFGEOF

sed -i '' 's/^name = .*/name = "Piglix Permafrost"/' "$TOML"
sed -i '' 's/^uuid = .*/uuid = "c9d3e562-7f4b-4a8c-e2f6-4b8d1c3e0a27"/' "$TOML"

build_shader "Piglix Permafrost" "Piglix_Permafrost.mcpack" \
  "C9D3E562-7F4B-4A8C-E2F6-4B8D1C3E0A27" \
  "§bPiglix · Permafrost\n§7Arctic winter. Vivid aurora. Glacial water.\nv1.0-perf"

# ════════════════════════════════
# 4. ETERNAL AUTUMN (Performance)
# ════════════════════════════════
cat > "$CONFIG" << 'CFGEOF'
#ifndef NL_CONFIG_H
#define NL_CONFIG_H
// PIGLIX · ETERNAL AUTUMN — Performance Edition

/* Color correction */
#define NL_TONEMAP_TYPE 4
#define NL_GAMMA 1.18
#define NL_EXPOSURE 0.95
#define NL_SATURATION 1.30
#define NL_TINT
#define NL_TINT_LOW  vec3(0.80,0.55,0.30)
#define NL_TINT_HIGH vec3(1.30,1.00,0.55)

/* Lighting */
#define NL_SUNLIGHT_INTENSITY   3.2
#define NL_TORCHLIGHT_INTENSITY 1.6
#define NL_SHADOW_INTENSITY     0.80
#define NL_MIN_LIGHTING_BOOST   1.9
#define NL_BLINKING_TORCH

/* Ambient */
#define NL_NETHER_AMBIENT vec3(2.2,1.0,0.3)
#define NL_END_AMBIENT    vec3(0.7,0.3,1.0)

/* Sun/Moon */
#define NL_DAWN_SUNLIGHT_COL   vec3(1.80,0.70,0.15)
#define NL_NOON_SUNLIGHT_COL   vec3(1.60,1.20,0.60)
#define NL_NIGHT_MOONLIGHT_COL vec3(0.12,0.08,0.04)

/* Torch */
#define NL_OVERWORLD_TORCH_COL  vec3(1.70,0.85,0.22)
#define NL_UNDERWATER_TORCH_COL vec3(1.20,0.65,0.18)
#define NL_NETHER_TORCH_COL     vec3(2.20,0.75,0.10)
#define NL_END_TORCH_COL        vec3(1.00,0.55,1.50)

/* Fog */
#define NL_FOG 1.0
#define NL_MIST_DENSITY 0.35
#define NL_RAIN_MIST_OPACITY 0.38
#define NL_CLOUDY_FOG 0.35

/* Sky */
#define NL_SKY_VOID_FACTOR     0.50
#define NL_SKY_VOID_DARKNESS   0.30
#define NL_SKY_RAIN_MIX_FACTOR 0.88
#define NL_DAWN_ZENITH_COL   vec3(0.30,0.18,0.08)
#define NL_DAWN_HORIZON_COL  vec3(1.60,0.60,0.10)
#define NL_DAWN_EDGE_COL     vec3(2.20,0.90,0.15)
#define NL_DAY_ZENITH_COL    vec3(0.42,0.68,1.50)
#define NL_DAY_HORIZON_COL   vec3(1.10,0.88,0.52)
#define NL_DAY_EDGE_COL      vec3(1.50,1.10,0.50)
#define NL_NIGHT_ZENITH_COL  vec3(0.005,0.004,0.018)
#define NL_NIGHT_HORIZON_COL vec3(0.018,0.012,0.040)
#define NL_NIGHT_EDGE_COL    vec3(0.035,0.022,0.055)
#define NL_RAIN_ZENITH_COL   vec3(0.28,0.24,0.18)
#define NL_RAIN_HORIZON_COL  vec3(0.52,0.44,0.30)
#define NL_END_ZENITH_COL    vec3(0.05,0.01,0.10)
#define NL_END_HORIZON_COL   vec3(0.50,0.08,0.65)

/* Ore glow */
#define NL_GLOW_TEX 3.0
// shimmer & leak removed for perf

/* Waving */
#define NL_PLANTS_WAVE 0.06
#define NL_LANTERN_WAVE 0.18
#define NL_WAVE_SPEED 1.5
#define NL_WAVE_RANGE 8.0

/* Water */
#define NL_WATER_TRANSPARENCY 0.70
#define NL_WATER_BUMP 0.07
#define NL_WATER_WAVE_SPEED  0.5
#define NL_WATER_TEX_OPACITY 0.20
#define NL_WATER_WAVE
// NL_WATER_REFL_MASK removed for perf
#define NL_WATER_TINT vec3(0.65,0.42,0.18)

/* Underwater */
#define NL_UNDERWATER_BRIGHTNESS 1.1
#define NL_CAUSTIC_INTENSITY 2.4
#define NL_UNDERWATER_WAVE 0.07
#define NL_UNDERWATER_TINT vec3(0.70,0.52,0.28)

/* Clouds — SOFT for perf */
#define NL_CLOUD_TYPE 1
#define NL_CLOUD1_SCALE vec2(0.016, 0.022)
#define NL_CLOUD1_DEPTH 1.6
#define NL_CLOUD1_SPEED 0.035
#define NL_CLOUD1_DENSITY 0.55
#define NL_CLOUD1_OPACITY 0.90
#define NL_CLOUD2_THICKNESS 2.8
#define NL_CLOUD2_RAIN_THICKNESS 5.5
#define NL_CLOUD2_STEPS 4
#define NL_CLOUD2_SCALE vec2(0.026, 0.026)
#define NL_CLOUD2_SHAPE vec2(0.58, 0.32)
#define NL_CLOUD2_DENSITY 28.0
#define NL_CLOUD2_VELOCITY 0.7
#define NL_CLOUD3_SCALE vec2(0.022, 0.022)
#define NL_CLOUD3_SPEED 0.008
#define NL_CLOUD3_SHADOW 0.80
#define NL_CLOUD3_SHADOW_OFFSET 0.38
#define NL_CLOUD0_THICKNESS 3.0
#define NL_CLOUD0_RAIN_THICKNESS 6.0
#define NL_CLOUD0_OPACITY 0.95
#define NL_CLOUD0_MULTILAYER

/* Aurora — disabled */
// removed for perf
#define NL_AURORA_VELOCITY 0.008
#define NL_AURORA_SCALE 0.045
#define NL_AURORA_WIDTH 0.08
#define NL_AURORA_COL1 vec3(0.9,0.45,0.05)
#define NL_AURORA_COL2 vec3(0.7,0.20,0.0)

/* Stars */
#define NL_SHOOTING_STAR 0.75
#define NL_SHOOTING_STAR_PERIOD 5.0
#define NL_SHOOTING_STAR_DELAY 25.0
// NL_GALAXY_STARS removed for perf
#define NL_GALAXY_VIBRANCE 0.45
#define NL_GALAXY_SPEED 0.012
#define NL_GALAXY_DAY_VISIBILITY 0.0
#define NL_RAINBOW
#define NL_RAINBOW_CLEAR 0.02
#define NL_RAINBOW_RAIN  0.70

/* Sun/Moon */
#define NL_SUN_SIZE  1.40
#define NL_MOON_SIZE 2.0
#define NL_SUN_PATH_YAW    14.0
#define NL_MOON_PATH_YAW   16.0
#define NL_SUN_PATH_TILT   32.0
#define NL_MOON_PATH_TILT -28.0
#define NL_SUN_TILT        40.0
#define NL_MOON_TILT       42.0
// NL_GODRAY removed for perf (biggest perf win for Autumn)
// NL_GROUND_REFL removed for perf
#define NL_GROUND_RAIN_WETNESS 0.90
#define NL_GROUND_RAIN_PUDDLES 0.75

/* Entity */
#define NL_ENTITY_BRIGHTNESS     0.80
#define NL_ENTITY_EDGE_HIGHLIGHT 0.55

/* Weather */
#define NL_WEATHER_SPECK 0.85
#define NL_WEATHER_RAIN_SLANT 3.5
#define NL_WEATHER_PARTICLE_SIZE 1.1

/* Lava */
#define NL_LAVA_NOISE
#define NL_LAVA_NOISE_SPEED 0.18

/* Subpacks */
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
#endif
CFGEOF

sed -i '' 's/^name = .*/name = "Piglix Eternal Autumn"/' "$TOML"
sed -i '' 's/^uuid = .*/uuid = "d4e8f673-9a5c-4b7d-f3e7-5c9e2d4f1b38"/' "$TOML"

build_shader "Piglix Eternal Autumn" "Piglix_Eternal_Autumn.mcpack" \
  "D4E8F673-9A5C-4B7D-F3E7-5C9E2D4F1B38" \
  "§6Piglix · Eternal Autumn\n§7Cozy fall. Harvest moon. Amber fog.\nv1.0-perf"

echo ""
echo "✅ All 4 shaders rebuilt with performance optimizations!"
echo "Files saved to: $OUT_DIR"
