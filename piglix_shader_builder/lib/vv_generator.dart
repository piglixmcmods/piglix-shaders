// vv_generator.dart
import 'dart:convert';
import 'package:archive/archive.dart';
import 'package:flutter/material.dart' show Color;
import 'performance_tiers.dart';
import 'vv_biomes.dart';
import 'vv_config.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Private Color & Formatting Utilities
// ─────────────────────────────────────────────────────────────────────────────

int _r(Color c) => (c.toARGB32() >> 16) & 0xFF;
int _g(Color c) => (c.toARGB32() >> 8) & 0xFF;
int _b(Color c) => c.toARGB32() & 0xFF;

List<int> _rgb(Color c) => <int>[_r(c), _g(c), _b(c)];

List<double> _rgbFloat(Color c) => <double>[
      _round4(_r(c) / 255.0),
      _round4(_g(c) / 255.0),
      _round4(_b(c) / 255.0),
    ];

String _hex(Color c) =>
    '#${(c.toARGB32() & 0xFFFFFF).toRadixString(16).padLeft(6, '0').toUpperCase()}';

Color _lerpColor(Color a, Color b, double t) {
  final k = t.clamp(0.0, 1.0);
  return Color.fromARGB(
    255,
    (_r(a) + (_r(b) - _r(a)) * k).round().clamp(0, 255),
    (_g(a) + (_g(b) - _g(a)) * k).round().clamp(0, 255),
    (_b(a) + (_b(b) - _b(a)) * k).round().clamp(0, 255),
  );
}

double _clamp(double v, double lo, double hi) =>
    v < lo ? lo : (v > hi ? hi : v);

double _round4(double v) => (v * 10000.0).round() / 10000.0;

List<double> _clampVec3(List<double> v, double lo, double hi) {
  final x = v.isNotEmpty ? _clamp(v[0], lo, hi) : lo;
  final y = v.length > 1 ? _clamp(v[1], lo, hi) : x;
  final z = v.length > 2 ? _clamp(v[2], lo, hi) : y;
  return [_round4(x), _round4(y), _round4(z)];
}

/// Strips JSONC `/* ... */` block comments, `// ...` line comments, and trailing commas.
String _cleanJsonc(String raw) {
  var s = raw.replaceAll(RegExp(r'/\*.*?\*/', dotAll: true), '');
  s = s.replaceAll(RegExp(r'(?<!:)//[^\n]*'), '');
  s = s.replaceAll(RegExp(r',\s*([}\]])'), r'$1');
  return s;
}

void _putJson(Map<String, ArchiveFile> fileMap, String key, Object data) {
  final bytes = utf8.encode(const JsonEncoder.withIndent('  ').convert(data));
  fileMap[key] = ArchiveFile(key, bytes.length, bytes);
}

// ─────────────────────────────────────────────────────────────────────────────
// Keyframe Tables (Time-of-day: 0.0=noon, 0.25=sunset, 0.5=midnight, 0.75=sunrise)
// ─────────────────────────────────────────────────────────────────────────────

const List<String> _kAtmosphereKeyframes = [
  '0.000000',
  '0.160000',
  '0.215000',
  '0.225000',
  '0.235000',
  '0.250000',
  '0.295000',
  '0.300000',
  '0.350000',
  '0.400000',
  '0.500000',
  '0.640000',
  '0.680000',
  '0.694000',
  '0.740000',
  '0.750000',
  '0.770000',
  '0.790000',
  '0.800000',
  '0.827000',
  '1.000000',
];

const Map<String, double> _kStarterHorizonMin = {
  '0.000000': 0.484,
  '0.160000': 0.360,
  '0.215000': 0.0,
  '0.225000': 0.0,
  '0.235000': 0.0,
  '0.250000': 0.0,
  '0.295000': 0.0,
  '0.300000': 0.0,
  '0.350000': 0.220,
  '0.400000': 0.434,
  '0.500000': 0.350,
  '0.640000': 0.270,
  '0.680000': 0.050,
  '0.694000': 0.025,
  '0.740000': 0.0,
  '0.750000': 0.0,
  '0.770000': 0.0,
  '0.790000': 0.120,
  '0.800000': 0.250,
  '0.827000': 0.380,
  '1.000000': 0.484,
};

const Map<String, double> _kStarterHorizonMieStart = {
  '0.000000': 0.210,
  '0.160000': 0.120,
  '0.215000': 1.000,
  '0.225000': 1.000,
  '0.235000': 1.000,
  '0.250000': 1.000,
  '0.295000': 1.000,
  '0.300000': 1.000,
  '0.350000': 0.700,
  '0.400000': 0.400,
  '0.500000': 0.100,
  '0.640000': 0.500,
  '0.680000': 0.750,
  '0.694000': 0.850,
  '0.740000': 1.000,
  '0.750000': 1.000,
  '0.770000': 1.000,
  '0.790000': 1.000,
  '0.800000': 0.016,
  '0.827000': 0.140,
  '1.000000': 0.210,
};

const Map<String, double> _kStarterHorizonMax = {
  '0.000000': 0.484,
  '0.160000': 0.320,
  '0.215000': 0.050,
  '0.225000': 0.050,
  '0.235000': 0.050,
  '0.250000': 0.050,
  '0.295000': 0.042,
  '0.300000': 0.040,
  '0.350000': 0.350,
  '0.400000': 0.669,
  '0.500000': 0.693,
  '0.640000': 0.450,
  '0.680000': 0.200,
  '0.694000': 0.150,
  '0.740000': 0.050,
  '0.750000': 0.050,
  '0.770000': 0.050,
  '0.790000': 0.050,
  '0.800000': 0.410,
  '0.827000': 0.460,
  '1.000000': 0.484,
};

// ─────────────────────────────────────────────────────────────────────────────
// Core JSON Generators
// ─────────────────────────────────────────────────────────────────────────────

Color _sampleSkyColor(
  String kf, {
  required Color noon,
  required Color sunset,
  required Color night,
  required Color sunrise,
}) {
  final t = double.parse(kf);
  if (t <= 0.16) return noon;
  if (t < 0.215) return _lerpColor(noon, sunset, (t - 0.16) / 0.055);
  if (t <= 0.25) return sunset;
  if (t < 0.30) return _lerpColor(sunset, night, (t - 0.25) / 0.05);
  if (t <= 0.694) return night;
  if (t < 0.74) return _lerpColor(night, sunrise, (t - 0.694) / 0.046);
  if (t <= 0.77) return sunrise;
  if (t < 0.827) return _lerpColor(sunrise, noon, (t - 0.77) / 0.057);
  return noon;
}

double _sampleHazeStart(String kf, AtmosphereConfig a) {
  final t = double.parse(kf);
  final double raw;
  if (t <= 0.16) {
    raw = a.horizonHazeNoon;
  } else if (t < 0.215) {
    final k = (t - 0.16) / 0.055;
    raw = a.horizonHazeNoon + (a.horizonHazeSunset - a.horizonHazeNoon) * k;
  } else if (t <= 0.25) {
    raw = a.horizonHazeSunset;
  } else if (t < 0.50) {
    final k = (t - 0.25) / 0.25;
    raw = a.horizonHazeSunset + (a.horizonHazeNight - a.horizonHazeSunset) * k;
  } else if (t <= 0.60) {
    raw = a.horizonHazeNight;
  } else if (t < 0.74) {
    final k = (t - 0.60) / 0.14;
    raw = a.horizonHazeNight + (a.horizonHazeSunrise - a.horizonHazeNight) * k;
  } else if (t <= 0.78) {
    raw = a.horizonHazeSunrise;
  } else if (t < 0.827) {
    final k = (t - 0.78) / 0.047;
    raw = a.horizonHazeSunrise + (a.horizonHazeNoon - a.horizonHazeSunrise) * k;
  } else {
    raw = a.horizonHazeNoon;
  }
  return _round4(_clamp(raw * a.horizonHazeScale, 0.0, 1.0));
}

/// Generates `atmospherics/atmospherics.json` (`format_version: "1.21.40"`).
Map<String, dynamic> generateAtmospherics(
  VVShaderConfig cfg, {
  String identifier = 'global_atmosphere',
}) {
  final a = cfg.atmosphere;

  final noonZ = a.effectiveNoonZenith;
  final sunsetZ = a.effectiveSunsetZenith;
  final nightZ = a.effectiveNightZenith;
  final sunriseZ = a.effectiveSunriseZenith;

  final skyZenith = <String, List<int>>{};
  final skyHorizon = <String, List<int>>{};
  final rayleigh = <String, double>{};
  final sunMie = <String, double>{};
  final moonMie = <String, double>{};
  final sunGlare = <String, double>{};
  final stopMin = <String, double>{};
  final stopStart = <String, double>{};
  final stopMieStart = <String, double>{};
  final stopMax = <String, double>{};

  for (final kf in _kAtmosphereKeyframes) {
    final t = double.parse(kf);

    skyZenith[kf] = _rgb(
      _sampleSkyColor(
        kf,
        noon: noonZ,
        sunset: sunsetZ,
        night: nightZ,
        sunrise: sunriseZ,
      ),
    );
    skyHorizon[kf] = _rgb(
      _sampleSkyColor(
        kf,
        noon: a.noonHorizon,
        sunset: a.sunsetHorizon,
        night: a.nightHorizon,
        sunrise: a.sunriseHorizon,
      ),
    );

    // rayleigh_strength clamped 0.0..11.0
    final double rVal;
    if (t <= 0.16) {
      rVal = a.rayleighNoon;
    } else if (t < 0.215) {
      rVal = a.rayleighNoon +
          (a.rayleighSunset - a.rayleighNoon) * ((t - 0.16) / 0.055);
    } else if (t <= 0.25) {
      rVal = a.rayleighSunset;
    } else if (t < 0.30) {
      rVal = a.rayleighSunset +
          (a.rayleighNight - a.rayleighSunset) * ((t - 0.25) / 0.05);
    } else if (t <= 0.694) {
      rVal = a.rayleighNight;
    } else if (t < 0.74) {
      rVal = a.rayleighNight +
          (a.rayleighSunrise - a.rayleighNight) * ((t - 0.694) / 0.046);
    } else if (t <= 0.77) {
      rVal = a.rayleighSunrise;
    } else if (t < 0.80) {
      rVal = a.rayleighSunrise +
          (a.rayleighNoon * 1.15 - a.rayleighSunrise) * ((t - 0.77) / 0.03);
    } else if (t < 0.827) {
      rVal = a.rayleighNoon * 1.15 +
          (a.rayleighNoon - a.rayleighNoon * 1.15) * ((t - 0.80) / 0.027);
    } else {
      rVal = a.rayleighNoon;
    }
    rayleigh[kf] = _round4(_clamp(rVal, 0.0, 11.0));

    // sun_mie_strength clamped 0.0..60.0
    final double smVal;
    if (t <= 0.16) {
      smVal = a.sunGlowNoon;
    } else if (t < 0.215) {
      smVal = a.sunGlowNoon +
          (a.sunGlowSunset * 0.75 - a.sunGlowNoon) * ((t - 0.16) / 0.055);
    } else if (t <= 0.225) {
      smVal = a.sunGlowSunset * 0.75;
    } else if (t <= 0.25) {
      smVal = a.sunGlowSunset * 0.35;
    } else if (t <= 0.295) {
      smVal = a.sunGlowSunset * 1.15;
    } else if (t <= 0.35) {
      smVal = a.sunGlowSunset * 0.25 * (1.0 - (t - 0.295) / 0.055);
    } else if (t < 0.74) {
      smVal = 0.0;
    } else if (t <= 0.79) {
      smVal = a.sunGlowSunrise * 0.25;
    } else if (t <= 0.827) {
      smVal = a.sunGlowSunrise * 0.55;
    } else {
      smVal = a.sunGlowNoon;
    }
    sunMie[kf] = _round4(_clamp(smVal, 0.0, 60.0));

    // moon_mie_strength clamped 0.0..20.0
    final double mmVal;
    if (t < 0.25) {
      mmVal = 0.0;
    } else if (t == 0.25) {
      mmVal = a.moonGlow * 0.4;
    } else if (t <= 0.64) {
      mmVal = a.moonGlow;
    } else if (t < 0.74) {
      mmVal = a.moonGlow * (1.0 - (t - 0.64) / 0.10);
    } else {
      mmVal = 0.0;
    }
    moonMie[kf] = _round4(_clamp(mmVal, 0.0, 20.0));

    // sun_glare_shape clamped 0.01..50.0
    final double sgVal;
    if (t <= 0.16) {
      sgVal = a.sunGlareNoon;
    } else if (t < 0.215) {
      sgVal = a.sunGlareNoon +
          (a.sunGlareSunset - a.sunGlareNoon) * ((t - 0.16) / 0.055);
    } else if (t <= 0.295) {
      sgVal = a.sunGlareSunset;
    } else if (t <= 0.35) {
      sgVal = a.sunGlareSunset * 2.4;
    } else if (t <= 0.64) {
      sgVal = a.sunGlareNoon * 0.6;
    } else if (t < 0.74) {
      sgVal = a.sunGlareSunset;
    } else if (t <= 0.79) {
      sgVal = a.sunGlareSunrise;
    } else if (t <= 0.827) {
      sgVal = a.sunGlareNoon * 0.83;
    } else {
      sgVal = a.sunGlareNoon;
    }
    sunGlare[kf] = _round4(_clamp(sgVal, 0.01, 50.0));

    // horizon_blend_stops
    stopMin[kf] = _round4(
      _clamp((_kStarterHorizonMin[kf] ?? 0.0) * a.horizonHazeScale, 0.0, 1.0),
    );
    stopStart[kf] = _sampleHazeStart(kf, a);
    stopMieStart[kf] = _round4(
      _clamp(
        (_kStarterHorizonMieStart[kf] ?? 0.5) * a.horizonHazeScale,
        0.0,
        1.2,
      ),
    );
    stopMax[kf] = _round4(
      _clamp((_kStarterHorizonMax[kf] ?? 0.4) * a.horizonHazeScale, 0.0, 1.0),
    );
  }

  return {
    'format_version': '1.21.40',
    'minecraft:atmosphere_settings': {
      'description': {'identifier': cfg.namespacedId(identifier)},
      'sky_zenith_color': skyZenith,
      'sky_horizon_color': skyHorizon,
      'rayleigh_strength': rayleigh,
      'sun_mie_strength': sunMie,
      'moon_mie_strength': moonMie,
      'sun_glare_shape': sunGlare,
      'horizon_blend_stops': {
        'min': stopMin,
        'start': stopStart,
        'mie_start': stopMieStart,
        'max': stopMax,
      },
    },
  };
}

/// Generates specialized dimension/biome atmosphere configs (`hell_atmosphere`,
/// `crimson_atmosphere`, `warped_atmosphere`, `soul_atmosphere`, `deltas_atmosphere`,
/// `end_atmosphere`, `pale_atmosphere`) using `<packSlug>:<presetKey>`.
Map<String, dynamic> generateDimensionAtmosphere(
  VVShaderConfig cfg,
  String presetKey,
) {
  List<int> zenith;
  List<int> horizon;
  double rayleigh;
  double sunMie;
  double sunGlare;
  double minStop;
  double startStop;
  double mieStop;
  double maxStop;

  switch (presetKey) {
    case 'hell_atmosphere':
      zenith = [255, 100, 18];
      horizon = [255, 148, 8];
      rayleigh = 0.9;
      sunMie = 0.0;
      sunGlare = 0.5;
      minStop = 0.3;
      startStop = 0.7;
      mieStop = 0.9;
      maxStop = 0.37;
      break;
    case 'crimson_atmosphere':
      zenith = [153, 29, 29];
      horizon = [220, 70, 45];
      rayleigh = 1.2;
      sunMie = 0.0;
      sunGlare = 0.5;
      minStop = 0.25;
      startStop = 0.72;
      mieStop = 0.9;
      maxStop = 0.40;
      break;
    case 'warped_atmosphere':
      zenith = [22, 102, 110];
      horizon = [54, 178, 172];
      rayleigh = 1.1;
      sunMie = 0.0;
      sunGlare = 0.5;
      minStop = 0.25;
      startStop = 0.72;
      mieStop = 0.9;
      maxStop = 0.40;
      break;
    case 'soul_atmosphere':
      zenith = [30, 88, 96];
      horizon = [56, 185, 168];
      rayleigh = 1.4;
      sunMie = 0.0;
      sunGlare = 0.5;
      minStop = 0.25;
      startStop = 0.75;
      mieStop = 0.9;
      maxStop = 0.42;
      break;
    case 'deltas_atmosphere':
      zenith = [82, 74, 92];
      horizon = [148, 134, 160];
      rayleigh = 1.8;
      sunMie = 0.0;
      sunGlare = 0.5;
      minStop = 0.30;
      startStop = 0.75;
      mieStop = 0.95;
      maxStop = 0.45;
      break;
    case 'end_atmosphere':
      zenith = [175, 32, 255];
      horizon = [245, 105, 255];
      rayleigh = 11.0; // clamped to schema max 11.0
      sunMie = 8.05;
      sunGlare = 0.05;
      minStop = 0.31;
      startStop = 0.74;
      mieStop = 1.0;
      maxStop = 0.42;
      break;
    case 'pale_atmosphere':
    default:
      zenith = [125, 132, 145];
      horizon = [178, 182, 190];
      rayleigh = 2.6;
      sunMie = 2.0;
      sunGlare = 1.2;
      minStop = 0.28;
      startStop = 0.68;
      mieStop = 0.85;
      maxStop = 0.44;
      break;
  }

  return {
    'format_version': '1.21.40',
    'minecraft:atmosphere_settings': {
      'description': {'identifier': cfg.namespacedId(presetKey)},
      'sky_zenith_color': {'0.000000': zenith, '1.000000': zenith},
      'sky_horizon_color': {'0.000000': horizon, '1.000000': horizon},
      'rayleigh_strength': {'0.000000': rayleigh, '1.000000': rayleigh},
      'sun_mie_strength': {'0.000000': sunMie, '1.000000': sunMie},
      'moon_mie_strength': {'0.000000': 0.0, '1.000000': 0.0},
      'sun_glare_shape': {'0.000000': sunGlare, '1.000000': sunGlare},
      'horizon_blend_stops': {
        'min': {'0.000000': minStop},
        'start': {'0.000000': startStop},
        'mie_start': {'0.000000': mieStop},
        'max': {'0.000000': maxStop},
      },
    },
  };
}

/// Generates `lighting/global.json` (`format_version: "1.21.80"`).
Map<String, dynamic> generateLighting(
  VVShaderConfig cfg, {
  String identifier = 'global',
}) {
  final l = cfg.lighting;
  final mult = _clamp(l.sunBrightnessMultiplier, 0.1, 2.0);

  final sunIlluminance = <String, double>{};
  for (final entry in LightingConfig.mojangSunLuxCurve.entries) {
    sunIlluminance[entry.key] =
        _round4(_clamp(entry.value * mult, 0.01, 200000.0));
  }

  final noonRgb = _rgb(l.sunColorNoon);
  final sunsetRgb = _rgb(l.sunColorSunset);
  final sunriseRgb = _rgb(l.sunColorSunrise);
  final nightRgb = _rgb(l.nightMoonColor);

  return {
    'format_version': '1.21.80',
    'minecraft:lighting_settings': {
      'description': {'identifier': cfg.namespacedId(identifier)},
      'directional_lights': {
        'orbital': {
          'sun': {
            'illuminance': sunIlluminance,
            'color': {
              '0.000000': noonRgb,
              '0.160000': noonRgb,
              '0.215000': sunsetRgb,
              '0.250000': sunsetRgb,
              '0.350000': nightRgb,
              '0.500000': nightRgb,
              '0.650000': nightRgb,
              '0.740000': sunriseRgb,
              '0.770000': sunriseRgb,
              '0.827000': noonRgb,
              '1.000000': noonRgb,
            },
          },
          'moon': {
            'illuminance': _round4(_clamp(l.moonIlluminance, 0.0, 20.0)),
            'color': _rgb(l.moonColor),
          },
          'orbital_offset_degrees':
              _round4(_clamp(l.orbitalOffsetDegrees, 0.0, 359.98)),
        },
        'flash': {
          'illuminance': _round4(_clamp(l.flashIlluminance, 0.0, 20000.0)),
          'color': _rgb(l.flashColor),
        },
      },
      'emissive': {
        'desaturation': _round4(_clamp(l.emissiveDesaturation, 0.0, 1.0)),
      },
      'ambient': {
        'illuminance': _round4(_clamp(l.ambientIlluminance, 0.0, 5.0)),
        'color': _rgb(l.ambientColor),
      },
      'sky': {
        'intensity': _round4(_clamp(l.skyIntensity, 0.1, 1.0)),
      },
    },
  };
}

/// Generates specialized dimension/biome lighting settings while respecting
/// the pack-wide locked `orbital_offset_degrees`.
Map<String, dynamic> generateDimensionLighting(
  VVShaderConfig cfg,
  String presetKey,
) {
  final l = cfg.lighting;
  final offset = _round4(_clamp(l.orbitalOffsetDegrees, 0.0, 359.98));

  double sunLux = 100.0;
  List<int> sunColor = [255, 140, 12];
  double moonLux = 0.27;
  List<int> moonColor = [255, 255, 255];
  double ambientLux = 0.8;
  List<int> ambientColor = [255, 132, 6];
  double skyIntensity = 0.4;
  double emissiveDesat = 0.1;
  double flashLux = 0.0;
  List<int> flashColor = [182, 0, 255];

  switch (presetKey) {
    case 'hell_lighting':
      sunLux = 120.0;
      sunColor = [255, 140, 12];
      ambientColor = [255, 132, 6];
      ambientLux = 0.9;
      skyIntensity = 0.4;
      break;
    case 'crimson_lighting':
      sunLux = 110.0;
      sunColor = [255, 88, 64];
      ambientColor = [180, 42, 42];
      ambientLux = 0.75;
      skyIntensity = 0.45;
      break;
    case 'warped_lighting':
      sunLux = 110.0;
      sunColor = [64, 210, 200];
      ambientColor = [28, 120, 125];
      ambientLux = 0.75;
      skyIntensity = 0.45;
      break;
    case 'soul_lighting':
      sunLux = 95.0;
      sunColor = [95, 210, 220];
      ambientColor = [35, 92, 110];
      ambientLux = 0.65;
      skyIntensity = 0.35;
      break;
    case 'deltas_lighting':
      sunLux = 105.0;
      sunColor = [205, 185, 220];
      ambientColor = [95, 86, 110];
      ambientLux = 0.70;
      skyIntensity = 0.40;
      break;
    case 'end_lighting':
      sunLux = 500.0;
      sunColor = [255, 255, 255];
      moonLux = 20.0;
      moonColor = [255, 255, 255];
      ambientLux = 0.4;
      ambientColor = [115, 10, 255];
      skyIntensity = 1.0;
      emissiveDesat = 0.07;
      flashLux = 6.0;
      flashColor = [145, 51, 255];
      break;
    case 'pale_lighting':
    default:
      sunLux = 38000.0;
      sunColor = [215, 220, 232];
      moonLux = 0.22;
      moonColor = [160, 175, 220];
      ambientLux = 0.03;
      ambientColor = [42, 46, 56];
      skyIntensity = 0.75;
      break;
  }

  return {
    'format_version': '1.21.80',
    'minecraft:lighting_settings': {
      'description': {'identifier': cfg.namespacedId(presetKey)},
      'directional_lights': {
        'orbital': {
          'sun': {
            'illuminance': {'0.000000': sunLux, '1.000000': sunLux},
            'color': {'0.000000': sunColor, '1.000000': sunColor},
          },
          'moon': {
            'illuminance': moonLux,
            'color': moonColor,
          },
          'orbital_offset_degrees': offset,
        },
        'flash': {
          'illuminance': flashLux,
          'color': flashColor,
        },
      },
      'emissive': {'desaturation': emissiveDesat},
      'ambient': {'illuminance': ambientLux, 'color': ambientColor},
      'sky': {'intensity': skyIntensity},
    },
  };
}

/// Generates `local_lighting/local_lighting.json` (`format_version: "1.21.120"`).
/// Official schema: block IDs live directly under `minecraft:local_light_settings`
/// with `{ "light_color": "#RRGGBB", "light_type": "point_light" | "static_light" }`.
Map<String, dynamic> generateLocalLighting(VVShaderConfig cfg) {
  final l = cfg.lighting;
  final settings = <String, dynamic>{};

  void addGroup(List<String> blocks, Color color, String lightType) {
    final hex = _hex(color);
    final lt = (lightType == 'static_light') ? 'static_light' : 'point_light';
    for (final block in blocks) {
      settings[block] = {
        'light_color': hex,
        'light_type': lt,
      };
    }
  }

  addGroup(LightingConfig.torchBlocks, l.torches.color, l.torches.lightType);
  addGroup(LightingConfig.lanternBlocks, l.lanterns.color, l.lanterns.lightType);
  addGroup(LightingConfig.soulBlocks, l.soulFire.color, l.soulFire.lightType);
  if (l.syncMysticToSoul) {
    addGroup(LightingConfig.mysticBlocks, l.soulFire.color, l.soulFire.lightType);
  }
  addGroup(LightingConfig.candleBlocks, l.candles.color, l.candles.lightType);
  addGroup(
    LightingConfig.redstoneBlocks,
    l.syncWarmToTorch ? l.torches.color : l.redstone.color,
    l.redstone.lightType,
  );
  addGroup(LightingConfig.endRodBlocks, l.endRod.color, l.endRod.lightType);
  addGroup(LightingConfig.copperBlocks, l.copper.color, l.copper.lightType);

  return {
    'format_version': '1.21.120',
    'minecraft:local_light_settings': settings,
  };
}

/// Generates `shadows/global.json` (`format_version: "1.21.80"`).
Map<String, dynamic> generateShadows(VVShaderConfig cfg) {
  final style = cfg.lighting.shadowStyle == 'blocky_shadows'
      ? 'blocky_shadows'
      : 'soft_shadows';
  final texel = cfg.lighting.shadowTexelSize.clamp(1, 1024);
  return {
    'format_version': '1.21.80',
    'minecraft:shadow_settings': {
      'shadow_style': style,
      'texel_size': texel,
    },
  };
}

/// Generates a `fogs/<preset>.json` (`format_version: "1.21.90"` Experimental).
Map<String, dynamic> generateFog(
  VVShaderConfig cfg,
  String fogPresetKey,
) {
  final f = cfg.fog;
  final airStart = _round4(_clamp(f.airFogStart, 0.05, 0.98));
  final airEnd = _round4(_clamp(f.airFogEnd, airStart + 0.01, 1.0));
  final wxStart = _round4(_clamp(f.weatherFogStart, 0.05, 0.98));
  final wxEnd = _round4(_clamp(f.weatherFogEnd, wxStart + 0.01, 1.0));
  final waterEnd = _round4(_clamp(f.waterFogEnd, 12.0, 120.0));

  // caveWaterVisibility (0..1) lowers water volumetric max_density and absorption
  final vis = _clamp(f.caveWaterVisibility, 0.0, 1.0);
  final waterScale = 1.4 - 1.15 * vis; // 1.4 at vis=0 -> 0.25 at vis=1
  final uwVolDensity = _round4(
    _clamp(f.underwaterVolumeDensity * waterScale, 0.001, 0.08),
  );
  final waterAbsorption = [
    _round4(_clamp(0.18 * waterScale, 0.0, 1.0)),
    _round4(_clamp(0.06 * waterScale, 0.0, 1.0)),
    _round4(_clamp(0.03 * waterScale, 0.0, 1.0)),
  ];

  // Preset-specific tint & volumetric customizations
  Color airColor = f.airFogColor;
  double volMaxDensity = _clamp(f.volumetricMaxDensity, 0.002, 0.25);
  double volZeroH = _clamp(f.volumetricZeroDensityHeight, 50.0, 320.0);
  double volMaxH = _clamp(f.volumetricMaxDensityHeight, -64.0, 200.0);
  bool uniformAir = false;
  String airDistType = 'render';
  double distAirStart = airStart;
  double distAirEnd = airEnd;

  switch (fogPresetKey) {
    case 'fog_snow':
    case 'fog_ice':
      airColor = _lerpColor(f.airFogColor, const Color(0xFFDCEBFF), 0.45);
      break;
    case 'fog_swamp':
      airColor = _lerpColor(f.airFogColor, const Color(0xFF7D937D), 0.35);
      volMaxDensity = _clamp(volMaxDensity * 1.15, 0.002, 0.25);
      break;
    case 'fog_desert':
    case 'fog_savanna':
      airColor = _lerpColor(f.airFogColor, const Color(0xFFEBD6B5), 0.35);
      break;
    case 'fog_mesa':
      airColor = _lerpColor(f.airFogColor, const Color(0xFFE6B89C), 0.4);
      break;
    case 'fog_cherry':
      airColor = _lerpColor(f.airFogColor, const Color(0xFFF3D5E8), 0.3);
      break;
    case 'fog_pale_garden':
      airColor = const Color(0xFF9EA4AD);
      volMaxDensity = _clamp(volMaxDensity * 1.25, 0.002, 0.25);
      break;
    case 'fog_deep_dark':
      airColor = const Color(0xFF0A2573);
      airDistType = 'fixed';
      distAirStart = 81.0;
      distAirEnd = 256.0;
      volMaxDensity = 0.153;
      volMaxH = -36.0;
      volZeroH = 14.0;
      break;
    case 'fog_hell':
      airColor = const Color(0xFFD42646);
      airDistType = 'fixed';
      distAirStart = 64.0;
      distAirEnd = 256.0;
      volMaxDensity = 0.134;
      uniformAir = true;
      break;
    case 'fog_crimson_forest':
      airColor = const Color(0xFF8C1D1D);
      airDistType = 'fixed';
      distAirStart = 48.0;
      distAirEnd = 220.0;
      volMaxDensity = 0.12;
      uniformAir = true;
      break;
    case 'fog_warped_forest':
      airColor = const Color(0xFF1A5E63);
      airDistType = 'fixed';
      distAirStart = 48.0;
      distAirEnd = 220.0;
      volMaxDensity = 0.12;
      uniformAir = true;
      break;
    case 'fog_soulsand_valley':
      airColor = const Color(0xFF285F6B);
      airDistType = 'fixed';
      distAirStart = 42.0;
      distAirEnd = 200.0;
      volMaxDensity = 0.14;
      uniformAir = true;
      break;
    case 'fog_basalt_deltas':
      airColor = const Color(0xFF5C5266);
      airDistType = 'fixed';
      distAirStart = 36.0;
      distAirEnd = 190.0;
      volMaxDensity = 0.16;
      uniformAir = true;
      break;
    case 'fog_end':
      airColor = const Color(0xFF551A85);
      volMaxDensity = 0.1241;
      uniformAir = true;
      break;
    default:
      break;
  }

  final airDensityBlock = <String, dynamic>{
    'max_density': _round4(volMaxDensity),
    'uniform': uniformAir,
  };
  if (!uniformAir) {
    airDensityBlock['max_density_height'] = _round4(volMaxH);
    airDensityBlock['zero_density_height'] = _round4(volZeroH);
  }

  return {
    'format_version': '1.21.90',
    'minecraft:fog_settings': {
      'description': {'identifier': cfg.namespacedId(fogPresetKey)},
      'distance': {
        'air': {
          'fog_color': _hex(airColor),
          'fog_start': distAirStart,
          'fog_end': distAirEnd,
          'render_distance_type': airDistType,
        },
        'weather': {
          'fog_color': _hex(f.weatherFogColor),
          'fog_start': wxStart,
          'fog_end': wxEnd,
          'render_distance_type': 'render',
        },
        'water': {
          'fog_color': _hex(f.waterFogColor),
          'fog_start': 0.0,
          'fog_end': waterEnd,
          'render_distance_type': 'fixed',
          'transition_fog': {
            'init_fog': {
              'fog_color': _hex(f.waterFogColor),
              'fog_start': 0.0,
              'fog_end': 0.01,
              'render_distance_type': 'fixed',
            },
            'min_percent': 0.25,
            'mid_seconds': 5,
            'mid_percent': 0.6,
            'max_seconds': 12,
          },
        },
      },
      'volumetric': {
        'density': {
          'air': airDensityBlock,
          'water': {
            'max_density': uwVolDensity,
            'uniform': true,
          },
        },
        'media_coefficients': {
          'air': {
            'scattering': _rgbFloat(f.hazeScatteringColor),
          },
          'water': {
            'absorption': waterAbsorption,
          },
        },
      },
    },
  };
}

/// Generates a `water/*.json` (`format_version: "1.21.80"`, `minecraft:water_settings`).
/// Pack-wide locked fields ([WaterGlobalSettings]) are applied from [global] when
/// provided so all 5 water files within a tier stay strictly synchronized.
Map<String, dynamic> generateWater(
  WaterPresetConfig preset, {
  required String packSlug,
  WaterGlobalSettings? global,
}) {
  final bareId = preset.identifier.contains(':')
      ? preset.identifier.split(':').last
      : preset.identifier;

  final wavesEnabled = global?.wavesEnabled ?? preset.wavesEnabled;
  final causticsEnabled = global?.causticsEnabled ?? preset.causticsEnabled;
  final causticsFrameLength =
      global?.causticsFrameLength ?? preset.causticsFrameLength;
  final causticsPower = global?.causticsPower ?? preset.causticsPower;
  final causticsScale = global?.causticsScale ?? preset.causticsScale;

  return {
    'format_version': '1.21.80',
    'minecraft:water_settings': {
      'description': {'identifier': '$packSlug:$bareId'},
      'biome_water_color_contribution': _round4(
        _clamp(preset.biomeWaterColorContribution, 0.0, 1.0),
      ),
      'particle_concentrations': {
        'cdom': _round4(_clamp(preset.cdom, 0.0, 15.0)),
        'chlorophyll': _round4(_clamp(preset.chlorophyll, 0.0, 10.0)),
        'suspended_sediment':
            _round4(_clamp(preset.suspendedSediment, 0.0, 300.0)),
      },
      'caustics': {
        'enabled': causticsEnabled,
        'frame_length': _round4(_clamp(causticsFrameLength, 0.01, 5.0)),
        'texture': 'textures/causticsLow/caustics.png',
        'scale': _round4(_clamp(causticsScale, 0.1, 5.0)),
        'power': causticsPower.clamp(1, 6),
      },
      'waves': {
        'enabled': wavesEnabled,
        'frequency': _round4(_clamp(preset.wavesFrequency, 0.01, 3.0)),
        'octaves': preset.wavesOctaves.clamp(1, 30),
        'depth': _round4(_clamp(preset.wavesDepth, 0.0, 3.0)),
        'sampleWidth': _round4(_clamp(preset.wavesSampleWidth, 0.01, 1.0)),
        'speed': _round4(_clamp(preset.wavesSpeed, 0.01, 10.0)),
        'pull': _round4(_clamp(preset.wavesPull, -1.0, 1.0)),
        'mix': _round4(_clamp(preset.wavesMix, 0.0, 1.0)),
        'frequency_scaling':
            _round4(_clamp(preset.wavesFrequencyScaling, 0.0, 2.0)),
        'speed_scaling': _round4(_clamp(preset.wavesSpeedScaling, 0.0, 2.0)),
        'direction_increment': preset.wavesDirectionIncrement.clamp(0, 360),
        'shape': _round4(_clamp(preset.wavesShape, 1.0, 10.0)),
      },
    },
  };
}

/// Generates `color_grading/*.json` (`format_version: "1.21.90"`).
/// Official schema places `temperature` INSIDE `color_grading`.
Map<String, dynamic> generateColorGrading(
  ColorGradingConfig cg,
  String namespacedIdentifier,
) {
  final op = ColorGradingConfig.validOperators.contains(cg.toneMappingOperator)
      ? cg.toneMappingOperator
      : 'hable';
  final tempType = cg.temperatureType == 'color_temperature'
      ? 'color_temperature'
      : 'white_balance';

  return {
    'format_version': '1.21.90',
    'minecraft:color_grading_settings': {
      'description': {'identifier': namespacedIdentifier},
      'color_grading': {
        'midtones': {
          'contrast': _clampVec3(cg.midtonesContrast, 0.0, 4.0),
          'gain': _clampVec3(cg.midtonesGain, 0.0, 10.0),
          'gamma': _clampVec3(cg.midtonesGamma, 0.0, 4.0),
          'offset': _clampVec3(cg.midtonesOffset, -1.0, 1.0),
          'saturation': _clampVec3(cg.midtonesSaturation, 0.0, 10.0),
        },
        'highlights': {
          'enabled': cg.highlightsEnabled,
          'highlightsMin': _round4(_clamp(cg.highlightsMin, 1.0, 4.0)),
          'contrast': _clampVec3(cg.highlightsContrast, 0.0, 4.0),
          'gain': _clampVec3(cg.highlightsGain, 0.0, 10.0),
          'gamma': _clampVec3(cg.highlightsGamma, 0.0, 4.0),
          'offset': _clampVec3(cg.highlightsOffset, -1.0, 1.0),
          'saturation': _clampVec3(cg.highlightsSaturation, 0.0, 10.0),
        },
        'shadows': {
          'enabled': cg.shadowsEnabled,
          'shadowsMax': _round4(_clamp(cg.shadowsMax, 0.1, 1.0)),
          'contrast': _clampVec3(cg.shadowsContrast, 0.0, 4.0),
          'gain': _clampVec3(cg.shadowsGain, 0.0, 10.0),
          'gamma': _clampVec3(cg.shadowsGamma, 0.0, 4.0),
          'offset': _clampVec3(cg.shadowsOffset, -1.0, 1.0),
          'saturation': _clampVec3(cg.shadowsSaturation, 0.0, 10.0),
        },
        'temperature': {
          'enabled': cg.temperatureEnabled,
          'type': tempType,
          'temperature': _round4(_clamp(cg.temperature, 1000.0, 15000.0)),
        },
      },
      'tone_mapping': {
        'operator': op,
      },
    },
  };
}

/// Generates `pbr/global.json` (`format_version: "1.21.40"`, `minecraft:pbr_fallback_settings`).
Map<String, dynamic> generatePbr(VVShaderConfig cfg) {
  final s = cfg.surface;
  final m = s.metalness.clamp(0, 255);
  final e = s.emissive.clamp(0, 255);
  final r = s.roughness.clamp(0, 255);
  final sub = s.subsurface.clamp(0, 255);

  return {
    'format_version': '1.21.40',
    'minecraft:pbr_fallback_settings': {
      'blocks': {
        'global_metalness_emissive_roughness_subsurface': [m, e, r, sub],
      },
      'actors': {
        'global_metalness_emissive_roughness_subsurface': [m, e, r, 32],
      },
      'particles': {
        'global_metalness_emissive_roughness_subsurface': [m, e, r, 0],
      },
      'items': {
        'global_metalness_emissive_roughness_subsurface': [m, e, r, 0],
      },
    },
  };
}

/// Generates `biomes/<id>.client_biome.json` (`format_version: "1.21.120"`).
/// Applies the 3-layer [BiomeOverridesConfig] (Global -> Group -> Single Biome).
Map<String, dynamic> generateClientBiome(
  VanillaBiomeEntry biome,
  VVShaderConfig cfg,
) {
  final ov = cfg.biomeOverrides.resolveFor(biome);

  final defaultOverworldCg = cfg.activeMood == 'dynamic'
      ? 'color_grading'
      : 'mood_${cfg.activeMood}';
  final baseCg = (biome.dimension == BiomeDimension.overworld &&
          biome.defaultColorGradingPreset == 'color_grading')
      ? defaultOverworldCg
      : biome.defaultColorGradingPreset;

  final atmoId = cfg.namespacedId(
    ov.atmospherePreset ?? biome.defaultAtmospherePreset,
  );
  final cgId = cfg.namespacedId(ov.colorGradingPreset ?? baseCg);
  final lightId = cfg.namespacedId(
    ov.lightingPreset ?? biome.defaultLightingPreset,
  );
  final waterId = cfg.namespacedId(
    ov.waterPreset ?? biome.defaultWaterPreset,
  );
  final fogId = cfg.namespacedId(ov.fogPreset ?? biome.defaultFogPreset);

  final skyColor = ov.skyColor ?? biome.defaultSkyColor;
  final waterColor = ov.waterSurfaceColor ?? biome.defaultWaterSurfaceColor;
  final waterOpacity = ov.waterSurfaceOpacity ?? biome.defaultWaterSurfaceOpacity;
  final grassColor = ov.grassColor ?? biome.defaultGrassColor;
  final foliageColor = ov.foliageColor ?? biome.defaultFoliageColor;
  final precipType = ov.precipitationType ?? biome.defaultPrecipitationType;
  final precipDensity =
      ov.precipitationDensity ?? biome.defaultPrecipitationDensity ?? 0.35;

  final waterAppearance = <String, dynamic>{
    'surface_color': _hex(waterColor),
  };
  if (waterOpacity != null) {
    waterAppearance['surface_opacity'] =
        _round4(_clamp(waterOpacity, 0.0, 1.0));
  }

  final components = <String, dynamic>{
    'minecraft:atmosphere_identifier': {'atmosphere_identifier': atmoId},
    'minecraft:color_grading_identifier': {'color_grading_identifier': cgId},
    'minecraft:lighting_identifier': {'lighting_identifier': lightId},
    'minecraft:water_identifier': {'water_identifier': waterId},
    'minecraft:fog_appearance': {'fog_identifier': fogId},
    'minecraft:sky_color': {'sky_color': _hex(skyColor)},
    'minecraft:water_appearance': waterAppearance,
  };

  if (grassColor != null) {
    components['minecraft:grass_appearance'] = {'color': _hex(grassColor)};
  }
  if (foliageColor != null) {
    components['minecraft:foliage_appearance'] = {'color': _hex(foliageColor)};
  }
  if (precipType != null && precipType != 'none') {
    const validPrecip = {'ash', 'blue_spores', 'red_spores', 'white_ash'};
    if (validPrecip.contains(precipType)) {
      components['minecraft:precipitation'] = {
        precipType: _round4(_clamp(precipDensity, 0.0, 1.0)),
      };
    }
  }

  return {
    'format_version': '1.21.120',
    'minecraft:client_biome': {
      'description': {'identifier': biome.id},
      'components': components,
    },
  };
}

/// Generates `manifest.json` (`format_version: 2`, `min_engine_version: [1, 21, 120]`).
Map<String, dynamic> generateManifest(
  VVShaderConfig cfg,
  String packUuid,
  String moduleUuid, {
  List<Map<String, dynamic>>? subpacks,
}) {
  final cleanName =
      cfg.packName.trim().isEmpty ? 'Piglix Shader' : cfg.packName.trim();
  final cleanDesc = cfg.packDescription.trim().isEmpty
      ? 'Piglix Vibrant Visuals · Bedrock Deferred PBR Shader'
      : cfg.packDescription.trim();
  final version = cfg.packVersion.length == 3 ? cfg.packVersion : [1, 0, 0];

  final manifest = <String, dynamic>{
    'format_version': 2,
    'header': {
      'name': cleanName,
      'description': cleanDesc,
      'uuid': packUuid,
      'version': version,
      'min_engine_version': [1, 21, 120],
    },
    'modules': [
      {
        'type': 'resources',
        'uuid': moduleUuid,
        'version': version,
      },
    ],
    'capabilities': ['pbr'],
  };

  if (subpacks != null && subpacks.isNotEmpty) {
    manifest['subpacks'] = subpacks;
  }
  return manifest;
}

// ─────────────────────────────────────────────────────────────────────────────
// Tier Map Builder & Archive Exporter
// ─────────────────────────────────────────────────────────────────────────────

const List<String> _kAllFogPresetKeys = [
  'fog_overworld',
  'fog_forest',
  'fog_taiga',
  'fog_mushroom',
  'fog_pale_garden',
  'fog_desert',
  'fog_mesa',
  'fog_savanna',
  'fog_snow',
  'fog_ice',
  'fog_swamp',
  'fog_jungle',
  'fog_cherry',
  'fog_deep_dark',
  'fog_hell',
  'fog_crimson_forest',
  'fog_warped_forest',
  'fog_soulsand_valley',
  'fog_basalt_deltas',
  'fog_end',
];

const List<String> _kDimensionPresetKeys = [
  'hell',
  'crimson',
  'warped',
  'soul',
  'deltas',
  'end',
  'pale',
];

/// Generates all JSON config files for a single tier [VVShaderConfig].
Map<String, List<int>> _generateTierJsonFiles(VVShaderConfig cfg) {
  final out = <String, List<int>>{};

  void put(String path, Object jsonObj) {
    out[path] = utf8.encode(
      const JsonEncoder.withIndent('  ').convert(jsonObj),
    );
  }

  // 1. Atmospherics
  put('atmospherics/atmospherics.json', generateAtmospherics(cfg));
  for (final dim in _kDimensionPresetKeys) {
    final key = '${dim}_atmosphere';
    put('atmospherics/$key.json', generateDimensionAtmosphere(cfg, key));
  }

  // 2. Lighting, Local Lighting & Shadows
  put('lighting/global.json', generateLighting(cfg));
  for (final dim in _kDimensionPresetKeys) {
    final key = '${dim}_lighting';
    put('lighting/$key.json', generateDimensionLighting(cfg, key));
  }
  put('local_lighting/local_lighting.json', generateLocalLighting(cfg));
  put('shadows/global.json', generateShadows(cfg));

  // 3. Fogs
  for (final fogKey in _kAllFogPresetKeys) {
    put('fogs/$fogKey.json', generateFog(cfg, fogKey));
  }

  // 4. Water (5 separate files; pack-wide locked fields forced identical via cfg.waterGlobal)
  final waterPresets = [
    cfg.waterTropical,
    cfg.waterOcean,
    cfg.waterDeepOcean,
    cfg.waterRiver,
    cfg.waterSwamp,
  ];
  for (final preset in waterPresets) {
    put(
      preset.fileName,
      generateWater(
        preset,
        packSlug: cfg.packSlug,
        global: cfg.waterGlobal,
      ),
    );
  }

  // 5. Color Grading & Moods (all inherit pack-wide tone_mapping.operator)
  put(
    'color_grading/color_grading.json',
    generateColorGrading(cfg.colorGrading, cfg.namespacedId('color_grading')),
  );
  for (final mood in ColorGradingConfig.moodNames) {
    final moodCfg = ColorGradingConfig.forMood(
      mood,
      toneMappingOperator: cfg.colorGrading.toneMappingOperator,
      base: mood == 'dynamic' ? cfg.colorGrading : null,
    );
    put(
      'color_grading/mood_$mood.json',
      generateColorGrading(moodCfg, cfg.namespacedId('mood_$mood')),
    );
  }

  // 6. PBR Fallback
  put('pbr/global.json', generatePbr(cfg));

  // 7. All 87 Vanilla Client Biomes
  for (final biome in kVanillaBiomes) {
    put(
      'biomes/${biome.id}.client_biome.json',
      generateClientBiome(biome, cfg),
    );
  }

  return out;
}

bool _bytesEqual(List<int> a, List<int> b) {
  if (a.length != b.length) return false;
  for (var i = 0; i < a.length; i++) {
    if (a[i] != b[i]) return false;
  }
  return true;
}

/// Builds a complete `.mcpack` [Archive] by applying [cfg] onto [baseArchive].
/// [packUuid] and [moduleUuid] must be unique RFC-4122 v4 UUIDs per export.
Archive buildArchive(
  Archive baseArchive,
  VVShaderConfig cfg, {
  required List<int> packIconBytes,
  required String packUuid,
  required String moduleUuid,
  void Function(double progress, String status)? onProgress,
}) {
  // Detect optional single top-level folder prefix in baseArchive
  String prefix = '';
  final nonDirFiles = baseArchive.where((f) => f.isFile).toList();
  if (nonDirFiles.isNotEmpty) {
    final first = nonDirFiles.first.name.replaceAll('\\', '/');
    final slashIdx = first.indexOf('/');
    if (slashIdx != -1) {
      final candidate = first.substring(0, slashIdx + 1);
      const standardDirs = [
        'atmospherics/',
        'biomes/',
        'fogs/',
        'lighting/',
        'local_lighting/',
        'point_lights/',
        'water/',
        'color_grading/',
        'textures/',
        'subpacks/',
        'pbr/',
        'shadows/',
        'particles/',
        'materials/',
        'texts/',
      ];
      if (!standardDirs.any((d) => candidate.startsWith(d)) &&
          nonDirFiles.every(
            (f) => f.name.replaceAll('\\', '/').startsWith(candidate),
          )) {
        prefix = candidate;
      }
    }
  }

  onProgress?.call(0.10, 'Preparing base pack assets...');

  // Separate base assets, stripping legacy generated JSON dirs and old subpacks
  final fileMap = <String, ArchiveFile>{};
  final pbrTextures = <String, ArchiveFile>{};

  const generatedPrefixes = [
    'atmospherics/',
    'biomes/',
    'color_grading/',
    'fogs/',
    'lighting/',
    'local_lighting/',
    'point_lights/',
    'pbr/',
    'shadows/',
    'water/',
  ];

  for (final file in baseArchive) {
    if (!file.isFile) continue;
    var name = file.name.replaceAll('\\', '/');
    if (prefix.isNotEmpty && name.startsWith(prefix)) {
      name = name.substring(prefix.length);
    }
    if (name.endsWith('.material.bin') ||
        name.startsWith('renderer/') ||
        name == 'manifest.json' ||
        name == 'pack_icon.png' ||
        name == 'textures/ui/title.png') {
      continue;
    }

    // Capture 16x PBR texture sets cleanly
    if (name.startsWith('subpacks/16x/textures/')) {
      final relTex = name.substring('subpacks/16x/'.length);
      pbrTextures[relTex] = ArchiveFile(
        relTex,
        file.size,
        file.content as List<int>,
      );
      continue;
    }
    if (name.startsWith('subpacks/')) {
      continue;
    }
    if (generatedPrefixes.any((p) => name.startsWith(p))) {
      continue;
    }

    fileMap[name] = ArchiveFile(name, file.size, file.content as List<int>);
  }

  // Ensure caustics texture exists at both standard paths if one is present
  if (fileMap.containsKey('textures/causticsLow/caustics.png') &&
      !fileMap.containsKey('textures/caustic/caustics.png')) {
    final c = fileMap['textures/causticsLow/caustics.png']!;
    fileMap['textures/caustic/caustics.png'] = ArchiveFile(
      'textures/caustic/caustics.png',
      c.size,
      c.content,
    );
  } else if (fileMap.containsKey('textures/caustic/caustics.png') &&
      !fileMap.containsKey('textures/causticsLow/caustics.png')) {
    final c = fileMap['textures/caustic/caustics.png']!;
    fileMap['textures/causticsLow/caustics.png'] = ArchiveFile(
      'textures/causticsLow/caustics.png',
      c.size,
      c.content,
    );
  }

  onProgress?.call(0.35, 'Generating Vibrant Visuals JSON configs...');

  // Root tier
  final rootProfile =
      TierProfile.forTier(cfg.performance.activeTier, cfg.performance);
  final rootCfg = applyTierToConfig(cfg, rootProfile);
  final rootJsonFiles = _generateTierJsonFiles(rootCfg);

  for (final entry in rootJsonFiles.entries) {
    fileMap[entry.key] = ArchiveFile(entry.key, entry.value.length, entry.value);
  }

  // Include PBR texture sets at root when active root tier uses them
  if (rootProfile.pbrTextureSets) {
    for (final tex in pbrTextures.entries) {
      fileMap.putIfAbsent(tex.key, () => tex.value);
    }
  }

  onProgress?.call(0.65, 'Building performance & style subpacks...');

  final manifestSubpacks = <Map<String, dynamic>>[];

  if (cfg.performance.exportAllTiers) {
    for (final tier in PerformanceTier.values) {
      final profile = TierProfile.forTier(tier, cfg.performance);
      final tierCfg = applyTierToConfig(cfg, profile);
      final tierFiles = _generateTierJsonFiles(tierCfg);

      // Write ONLY files that differ from root
      for (final entry in tierFiles.entries) {
        final rootBytes = rootJsonFiles[entry.key];
        if (rootBytes == null || !_bytesEqual(rootBytes, entry.value)) {
          final subPath = 'subpacks/${profile.folderName}/${entry.key}';
          fileMap[subPath] =
              ArchiveFile(subPath, entry.value.length, entry.value);
        }
      }

      // Include PBR texture sets inside subpack when root doesn't have them
      // but this tier enables them
      if (!rootProfile.pbrTextureSets && profile.pbrTextureSets) {
        for (final tex in pbrTextures.entries) {
          final subPath = 'subpacks/${profile.folderName}/${tex.key}';
          fileMap[subPath] = ArchiveFile(
            subPath,
            tex.value.size,
            tex.value.content as List<int>,
          );
        }
      }

      manifestSubpacks.add({
        'folder_name': profile.folderName,
        'name': profile.displayName,
        'memory_tier': profile.memoryTier,
      });
    }
  }

  if (cfg.performance.styleIntensityLite) {
    final liteCfg = applyLiteStyle(rootCfg);
    final liteFiles = _generateTierJsonFiles(liteCfg);
    for (final entry in liteFiles.entries) {
      final rootBytes = rootJsonFiles[entry.key];
      if (rootBytes == null || !_bytesEqual(rootBytes, entry.value)) {
        final subPath = 'subpacks/lite/${entry.key}';
        fileMap[subPath] =
            ArchiveFile(subPath, entry.value.length, entry.value);
      }
    }
    manifestSubpacks.add({
      'folder_name': 'lite',
      'name': 'Lite Style (Subtle Contrast & Fog)',
      'memory_tier': rootProfile.memoryTier,
    });
  }

  onProgress?.call(0.88, 'Writing manifest, language file & pack icon...');

  final cleanName =
      cfg.packName.trim().isEmpty ? 'Piglix Shader' : cfg.packName.trim();
  final cleanDesc = cfg.packDescription.trim().isEmpty
      ? 'Piglix Vibrant Visuals · Bedrock Deferred PBR Shader'
      : cfg.packDescription.trim();

  _putJson(
    fileMap,
    'manifest.json',
    generateManifest(
      cfg,
      packUuid,
      moduleUuid,
      subpacks: manifestSubpacks,
    ),
  );

  fileMap['pack_icon.png'] = ArchiveFile(
    'pack_icon.png',
    packIconBytes.length,
    packIconBytes,
  );

  final langBytes = utf8.encode(
    'pack.name=$cleanName\npack.description=$cleanDesc\n',
  );
  fileMap['texts/en_US.lang'] =
      ArchiveFile('texts/en_US.lang', langBytes.length, langBytes);

  final outArchive = Archive();
  for (final file in fileMap.values) {
    outArchive.addFile(file);
  }
  onProgress?.call(1.0, 'Pack archive compiled.');
  return outArchive;
}

// ─────────────────────────────────────────────────────────────────────────────
// Validation (Config + Archive)
// ─────────────────────────────────────────────────────────────────────────────

/// Structured validation result with blocking [errors] and advisory [warnings].
class ValidationReport {
  /// Blocking errors — export MUST be blocked when non-empty.
  final List<String> errors;

  /// Non-blocking plain-language quality/usability advisories.
  final List<String> warnings;

  const ValidationReport({
    this.errors = const [],
    this.warnings = const [],
  });

  bool get isValid => errors.isEmpty;
}

/// Validates [cfg] against all official Vibrant Visuals schema bounds and
/// produces plain-language errors and warnings.
ValidationReport validateConfig(VVShaderConfig cfg) {
  final errors = <String>[];
  final warnings = <String>[];

  // Pack identity
  if (cfg.packName.trim().isEmpty) {
    errors.add('Pack name cannot be empty.');
  }
  if (cfg.packVersion.length != 3 || cfg.packVersion.any((v) => v < 0)) {
    errors.add('Pack version must be 3 non-negative numbers [major, minor, patch].');
  }

  // Atmosphere
  final a = cfg.atmosphere;
  void checkRayleigh(String label, double v) {
    if (v < 0.0 || v > 11.0) {
      errors.add('Atmosphere $label Rayleigh strength ($v) must be in 0.0–11.0.');
    }
  }

  checkRayleigh('Noon', a.rayleighNoon);
  checkRayleigh('Sunset', a.rayleighSunset);
  checkRayleigh('Night', a.rayleighNight);
  checkRayleigh('Sunrise', a.rayleighSunrise);

  if (a.sunGlowNoon < 0 || a.sunGlowNoon > 60) {
    errors.add('Noon sun glow (${a.sunGlowNoon}) must be in 0.0–60.0.');
  }
  if (a.sunGlowSunset < 0 || a.sunGlowSunset > 60) {
    errors.add('Sunset sun glow (${a.sunGlowSunset}) must be in 0.0–60.0.');
  }
  if (a.sunGlowSunrise < 0 || a.sunGlowSunrise > 60) {
    errors.add('Sunrise sun glow (${a.sunGlowSunrise}) must be in 0.0–60.0.');
  }
  if (a.sunGlareNoon < 0.01 || a.sunGlareNoon > 50) {
    errors.add('Noon sun glare shape (${a.sunGlareNoon}) must be in 0.01–50.0.');
  }
  if (a.sunGlareSunset < 0.01 || a.sunGlareSunset > 50) {
    errors.add('Sunset sun glare shape (${a.sunGlareSunset}) must be in 0.01–50.0.');
  }
  if (a.sunGlareSunrise < 0.01 || a.sunGlareSunrise > 50) {
    errors.add('Sunrise sun glare shape (${a.sunGlareSunrise}) must be in 0.01–50.0.');
  }
  if (a.moonGlow < 0 || a.moonGlow > 20) {
    errors.add('Moon glow (${a.moonGlow}) must be in 0.0–20.0.');
  }
  if (a.horizonHazeScale < 0 || a.horizonHazeScale > 2.0) {
    errors.add('Horizon haze scale (${a.horizonHazeScale}) must be in 0.0–2.0.');
  }

  // Lighting
  final l = cfg.lighting;
  if (l.sunBrightnessMultiplier < 0.1 || l.sunBrightnessMultiplier > 2.0) {
    errors.add(
      'Sun brightness multiplier (${l.sunBrightnessMultiplier}) must be in 0.1–2.0.',
    );
  }
  if (l.moonIlluminance < 0.0 || l.moonIlluminance > 20.0) {
    errors.add('Moon illuminance (${l.moonIlluminance}) must be in 0.0–20.0 lux.');
  }
  if (l.ambientIlluminance < 0.0 || l.ambientIlluminance > 5.0) {
    errors.add(
      'Ambient illuminance (${l.ambientIlluminance}) must be in 0.0–5.0 lux.',
    );
  }
  if (l.skyIntensity < 0.1 || l.skyIntensity > 1.0) {
    errors.add('Sky intensity (${l.skyIntensity}) must be in 0.1–1.0.');
  }
  if (l.emissiveDesaturation < 0.0 || l.emissiveDesaturation > 1.0) {
    errors.add(
      'Emissive desaturation (${l.emissiveDesaturation}) must be in 0.0–1.0.',
    );
  }
  if (l.orbitalOffsetDegrees < 0.0 || l.orbitalOffsetDegrees > 359.98) {
    errors.add(
      'Orbital offset degrees (${l.orbitalOffsetDegrees}) must be in 0.0–359.98.',
    );
  }
  if (l.flashIlluminance < 0.0 || l.flashIlluminance > 20000.0) {
    errors.add(
      'Flash illuminance (${l.flashIlluminance}) must be in 0.0–20000.0.',
    );
  }
  if (l.shadowStyle != 'soft_shadows' && l.shadowStyle != 'blocky_shadows') {
    errors.add(
      'Shadow style "${l.shadowStyle}" must be soft_shadows or blocky_shadows.',
    );
  }
  if (l.shadowTexelSize < 1 || l.shadowTexelSize > 1024) {
    errors.add('Shadow texel size (${l.shadowTexelSize}) must be in 1–1024.');
  }

  // Fog
  final f = cfg.fog;
  if (f.airFogStart < 0.05 || f.airFogStart > 0.99) {
    errors.add('Air fog start (${f.airFogStart}) must be in 0.05–0.99.');
  }
  if (f.airFogEnd < 0.1 || f.airFogEnd > 1.0) {
    errors.add('Air fog end (${f.airFogEnd}) must be in 0.1–1.0.');
  }
  if (f.airFogStart >= f.airFogEnd) {
    errors.add(
      'Air fog start (${f.airFogStart}) must be less than air fog end (${f.airFogEnd}).',
    );
  }
  if (f.weatherFogStart < 0.05 || f.weatherFogStart > 0.99) {
    errors.add('Weather fog start (${f.weatherFogStart}) must be in 0.05–0.99.');
  }
  if (f.weatherFogEnd < 0.1 || f.weatherFogEnd > 1.0) {
    errors.add('Weather fog end (${f.weatherFogEnd}) must be in 0.1–1.0.');
  }
  if (f.weatherFogStart >= f.weatherFogEnd) {
    errors.add(
      'Weather fog start (${f.weatherFogStart}) must be less than weather fog end (${f.weatherFogEnd}).',
    );
  }
  if (f.waterFogEnd < 12.0 || f.waterFogEnd > 120.0) {
    errors.add('Water fog end (${f.waterFogEnd}) must be in 12–120 blocks.');
  }
  if (f.volumetricMaxDensity < 0.002 || f.volumetricMaxDensity > 0.25) {
    errors.add(
      'Volumetric fog max density (${f.volumetricMaxDensity}) must be in 0.002–0.25.',
    );
  }
  if (f.underwaterVolumeDensity < 0.002 || f.underwaterVolumeDensity > 0.08) {
    errors.add(
      'Underwater volumetric density (${f.underwaterVolumeDensity}) must be in 0.002–0.08.',
    );
  }
  if (f.caveWaterVisibility < 0.0 || f.caveWaterVisibility > 1.0) {
    errors.add(
      'Cave water visibility (${f.caveWaterVisibility}) must be in 0.0–1.0.',
    );
  }

  // Water Global + 5 Presets
  final wg = cfg.waterGlobal;
  if (wg.causticsFrameLength < 0.01 || wg.causticsFrameLength > 5.0) {
    errors.add(
      'Caustics frame length (${wg.causticsFrameLength}) must be in 0.01–5.0.',
    );
  }
  if (wg.causticsPower < 1 || wg.causticsPower > 6) {
    errors.add('Caustics power (${wg.causticsPower}) must be in 1–6.');
  }
  if (wg.causticsScale < 0.1 || wg.causticsScale > 5.0) {
    errors.add('Caustics scale (${wg.causticsScale}) must be in 0.1–5.0.');
  }

  final waterPresets = [
    cfg.waterTropical,
    cfg.waterOcean,
    cfg.waterDeepOcean,
    cfg.waterRiver,
    cfg.waterSwamp,
  ];
  for (final wp in waterPresets) {
    if (wp.cdom < 0 || wp.cdom > 15) {
      errors.add('${wp.identifier}: cdom (${wp.cdom}) must be in 0–15.');
    }
    if (wp.chlorophyll < 0 || wp.chlorophyll > 10) {
      errors.add(
        '${wp.identifier}: chlorophyll (${wp.chlorophyll}) must be in 0–10.',
      );
    }
    if (wp.suspendedSediment < 0 || wp.suspendedSediment > 300) {
      errors.add(
        '${wp.identifier}: suspendedSediment (${wp.suspendedSediment}) must be in 0–300.',
      );
    }
    if (wp.biomeWaterColorContribution < 0 ||
        wp.biomeWaterColorContribution > 1) {
      errors.add(
        '${wp.identifier}: biomeWaterColorContribution (${wp.biomeWaterColorContribution}) must be in 0–1.',
      );
    }
    if (wp.wavesOctaves < 1 || wp.wavesOctaves > 30) {
      errors.add(
        '${wp.identifier}: wavesOctaves (${wp.wavesOctaves}) must be in 1–30.',
      );
    }
    if (wp.wavesFrequency < 0.01 || wp.wavesFrequency > 3.0) {
      errors.add(
        '${wp.identifier}: wavesFrequency (${wp.wavesFrequency}) must be in 0.01–3.0.',
      );
    }
    if (wp.wavesDepth < 0.0 || wp.wavesDepth > 3.0) {
      errors.add(
        '${wp.identifier}: wavesDepth (${wp.wavesDepth}) must be in 0.0–3.0.',
      );
    }
    if (wp.wavesSampleWidth < 0.01 || wp.wavesSampleWidth > 1.0) {
      errors.add(
        '${wp.identifier}: wavesSampleWidth (${wp.wavesSampleWidth}) must be in 0.01–1.0.',
      );
    }
    if (wp.wavesSpeed < 0.01 || wp.wavesSpeed > 10.0) {
      errors.add(
        '${wp.identifier}: wavesSpeed (${wp.wavesSpeed}) must be in 0.01–10.0.',
      );
    }
    if (wp.wavesPull < -1.0 || wp.wavesPull > 1.0) {
      errors.add(
        '${wp.identifier}: wavesPull (${wp.wavesPull}) must be in -1.0–1.0.',
      );
    }
    if (wp.wavesMix < 0.0 || wp.wavesMix > 1.0) {
      errors.add('${wp.identifier}: wavesMix (${wp.wavesMix}) must be in 0–1.');
    }
    if (wp.wavesShape < 1.0 || wp.wavesShape > 10.0) {
      errors.add(
        '${wp.identifier}: wavesShape (${wp.wavesShape}) must be in 1.0–10.0.',
      );
    }
    if (wp.wavesDirectionIncrement < 0 || wp.wavesDirectionIncrement > 360) {
      errors.add(
        '${wp.identifier}: wavesDirectionIncrement (${wp.wavesDirectionIncrement}) must be in 0–360.',
      );
    }
  }

  // Color Grading
  final cg = cfg.colorGrading;
  if (!ColorGradingConfig.validOperators.contains(cg.toneMappingOperator)) {
    errors.add(
      'Invalid tone mapping operator "${cg.toneMappingOperator}". Valid: ${ColorGradingConfig.validOperators.join(", ")}.',
    );
  }
  if (cg.temperature < 1000.0 || cg.temperature > 15000.0) {
    errors.add(
      'Color temperature (${cg.temperature}K) must be in 1000–15000.',
    );
  }
  if (cg.highlightsMin < 1.0 || cg.highlightsMin > 4.0) {
    errors.add('highlightsMin (${cg.highlightsMin}) must be in 1.0–4.0.');
  }
  if (cg.shadowsMax < 0.1 || cg.shadowsMax > 1.0) {
    errors.add('shadowsMax (${cg.shadowsMax}) must be in 0.1–1.0.');
  }
  void checkVec3(String label, List<double> v, double lo, double hi) {
    if (v.length != 3) {
      errors.add('$label must have 3 RGB channels.');
      return;
    }
    for (final c in v) {
      if (c < lo || c > hi) {
        errors.add('$label channel ($c) must be in $lo–$hi.');
        break;
      }
    }
  }

  checkVec3('midtones.contrast', cg.midtonesContrast, 0.0, 4.0);
  checkVec3('midtones.gain', cg.midtonesGain, 0.0, 10.0);
  checkVec3('midtones.gamma', cg.midtonesGamma, 0.0, 4.0);
  checkVec3('midtones.offset', cg.midtonesOffset, -1.0, 1.0);
  checkVec3('midtones.saturation', cg.midtonesSaturation, 0.0, 10.0);
  checkVec3('highlights.contrast', cg.highlightsContrast, 0.0, 4.0);
  checkVec3('highlights.gain', cg.highlightsGain, 0.0, 10.0);
  checkVec3('highlights.gamma', cg.highlightsGamma, 0.0, 4.0);
  checkVec3('highlights.offset', cg.highlightsOffset, -1.0, 1.0);
  checkVec3('highlights.saturation', cg.highlightsSaturation, 0.0, 10.0);
  checkVec3('shadows.contrast', cg.shadowsContrast, 0.0, 4.0);
  checkVec3('shadows.gain', cg.shadowsGain, 0.0, 10.0);
  checkVec3('shadows.gamma', cg.shadowsGamma, 0.0, 4.0);
  checkVec3('shadows.offset', cg.shadowsOffset, -1.0, 1.0);
  checkVec3('shadows.saturation', cg.shadowsSaturation, 0.0, 10.0);

  // Surface PBR
  final s = cfg.surface;
  if (s.metalness < 0 ||
      s.metalness > 255 ||
      s.emissive < 0 ||
      s.emissive > 255 ||
      s.roughness < 0 ||
      s.roughness > 255 ||
      s.subsurface < 0 ||
      s.subsurface > 255) {
    errors.add('Surface MERS values must each be in 0–255.');
  }

  // ── Plain-Language Advisory Warnings ────────────────────────
  if (l.moonIlluminance < 0.05 && l.ambientIlluminance < 0.01) {
    warnings.add(
      'Night is too dark: low moon illuminance (${l.moonIlluminance}) and ambient (${l.ambientIlluminance}) may make unlit areas pitch black.',
    );
  }
  if (a.rayleighNoon > 7.5 || l.sunBrightnessMultiplier > 1.7) {
    warnings.add(
      'Sky may look washed out at noon due to high Rayleigh scattering or sun brightness multiplier.',
    );
  }
  if (f.caveWaterVisibility < 0.15) {
    warnings.add(
      'No visible water in caves: low caveWaterVisibility (${f.caveWaterVisibility}) makes underwater cave fog nearly opaque.',
    );
  }
  final ptCount = l.countPointLightBlocks();
  if (ptCount > 20) {
    warnings.add(
      'High point-light count ($ptCount blocks) may lag mobile GPUs on Ultra.',
    );
  }
  if (f.volumetricMaxDensity > 0.16) {
    warnings.add(
      'Very dense volumetric air fog (${f.volumetricMaxDensity}) may obscure distant terrain.',
    );
  }

  return ValidationReport(errors: errors, warnings: warnings);
}

final RegExp _uuidV4Regex = RegExp(
  r'^[0-9a-f]{8}-[0-9a-f]{4}-4[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$',
  caseSensitive: false,
);

/// Validates an already-built `.mcpack` [Archive] before export, verifying:
/// - Config schema rules via [validateConfig]
/// - Root `manifest.json` (`pbr` capability, `min_engine_version >= [1,21,120]`, valid UUIDs)
/// - Root `pack_icon.png` present & non-empty
/// - Every vanilla biome in [kVanillaBiomes] present
/// - All referenced identifiers (`atmosphere`, `lighting`, `color_grading`, `water`, `fog`)
///   exist in the archive and use `<packSlug>:` namespace with no duplicate IDs
/// - Pack-wide invariants (`tone_mapping.operator`, `orbital_offset_degrees`,
///   `caustics.*`, `waves.enabled`) identical within each tier.
ValidationReport validateArchive(Archive archive, VVShaderConfig cfg) {
  final base = validateConfig(cfg);
  final errors = List<String>.from(base.errors);
  final warnings = List<String>.from(base.warnings);

  final files = <String, ArchiveFile>{
    for (final f in archive)
      if (f.isFile) f.name.replaceAll('\\', '/'): f,
  };

  // 1. Root icon
  final icon = files['pack_icon.png'];
  if (icon == null || icon.size == 0) {
    errors.add('Missing or empty root pack_icon.png.');
  }

  // 2. Root manifest.json
  final manifestFile = files['manifest.json'];
  if (manifestFile == null) {
    errors.add('Missing root manifest.json.');
  } else {
    try {
      final manifest = jsonDecode(
        _cleanJsonc(utf8.decode(manifestFile.content as List<int>)),
      ) as Map<String, dynamic>;

      final caps = (manifest['capabilities'] as List?)?.cast<dynamic>() ?? [];
      if (!caps.contains('pbr')) {
        errors.add('manifest.json must include "pbr" in capabilities.');
      }

      final header = manifest['header'] as Map<String, dynamic>? ?? {};
      final minVer =
          (header['min_engine_version'] as List?)?.cast<int>() ?? [];
      final verOk = minVer.length >= 3 &&
          (minVer[0] > 1 ||
              (minVer[0] == 1 && minVer[1] > 21) ||
              (minVer[0] == 1 && minVer[1] == 21 && minVer[2] >= 120));
      if (!verOk) {
        errors.add(
          'manifest.json min_engine_version ($minVer) must be >= [1, 21, 120].',
        );
      }

      final pUuid = header['uuid'] as String? ?? '';
      if (!_uuidV4Regex.hasMatch(pUuid)) {
        errors.add('manifest.json header.uuid "$pUuid" is not a valid UUID v4.');
      }

      final modules = (manifest['modules'] as List?) ?? [];
      if (modules.isEmpty) {
        errors.add('manifest.json modules must not be empty.');
      } else {
        final mUuid = (modules.first as Map)['uuid'] as String? ?? '';
        if (!_uuidV4Regex.hasMatch(mUuid)) {
          errors.add('manifest.json module uuid "$mUuid" is not a valid UUID v4.');
        }
        if (pUuid.isNotEmpty && pUuid == mUuid) {
          errors.add('manifest.json header.uuid and module uuid must differ.');
        }
      }
    } catch (e) {
      errors.add('Invalid manifest.json: $e');
    }
  }

  // Helper to resolve effective JSON map for a tier prefix ("" = root, or "subpacks/<tier>/")
  Map<String, dynamic>? readTierJson(String subPrefix, String relPath) {
    final f = files['$subPrefix$relPath'] ?? files[relPath];
    if (f == null) return null;
    try {
      return jsonDecode(
        _cleanJsonc(utf8.decode(f.content as List<int>)),
      ) as Map<String, dynamic>;
    } catch (_) {
      return null;
    }
  }

  void verifyScope(String scopeLabel, String subPrefix) {
    final atmoIds = <String>{};
    final lightIds = <String>{};
    final cgIds = <String>{};
    final waterIds = <String>{};
    final fogIds = <String>{};

    final seenIds = <String>{};
    void recordId(String kind, String? id) {
      if (id == null || !id.startsWith('${cfg.packSlug}:')) {
        errors.add(
          '[$scopeLabel] $kind identifier "$id" must use namespace "${cfg.packSlug}:".',
        );
        return;
      }
      if (!seenIds.add('$kind:$id')) {
        errors.add('[$scopeLabel] Duplicate $kind identifier "$id".');
      }
    }

    // Collect effective files in this scope
    final effectivePaths = <String>{
      for (final p in files.keys)
        if (!p.startsWith('subpacks/')) p,
      if (subPrefix.isNotEmpty)
        for (final p in files.keys)
          if (p.startsWith(subPrefix)) p.substring(subPrefix.length),
    };

    String? lockedToneOp;
    num? lockedOrbitalOffset;
    String? lockedWaterSig;

    for (final rel in effectivePaths) {
      if (rel.startsWith('atmospherics/') && rel.endsWith('.json')) {
        final d = readTierJson(subPrefix, rel);
        final id =
            d?['minecraft:atmosphere_settings']?['description']?['identifier']
                as String?;
        recordId('atmosphere', id);
        if (id != null) atmoIds.add(id);
      } else if (rel.startsWith('lighting/') && rel.endsWith('.json')) {
        final d = readTierJson(subPrefix, rel);
        final s = d?['minecraft:lighting_settings'] as Map<String, dynamic>?;
        final id = s?['description']?['identifier'] as String?;
        recordId('lighting', id);
        if (id != null) lightIds.add(id);
        final offset =
            s?['directional_lights']?['orbital']?['orbital_offset_degrees']
                as num?;
        if (offset != null) {
          lockedOrbitalOffset ??= offset;
          if ((offset - lockedOrbitalOffset).abs() > 1e-4) {
            errors.add(
              '[$scopeLabel] orbital_offset_degrees differs in $rel ($offset vs $lockedOrbitalOffset).',
            );
          }
        }
      } else if (rel.startsWith('color_grading/') && rel.endsWith('.json')) {
        final d = readTierJson(subPrefix, rel);
        final s =
            d?['minecraft:color_grading_settings'] as Map<String, dynamic>?;
        final id = s?['description']?['identifier'] as String?;
        recordId('color_grading', id);
        if (id != null) cgIds.add(id);
        final op = s?['tone_mapping']?['operator'] as String?;
        if (op != null) {
          lockedToneOp ??= op;
          if (op != lockedToneOp) {
            errors.add(
              '[$scopeLabel] tone_mapping.operator differs in $rel ($op vs $lockedToneOp).',
            );
          }
        }
      } else if (rel.startsWith('water/') && rel.endsWith('.json')) {
        final d = readTierJson(subPrefix, rel);
        final s = d?['minecraft:water_settings'] as Map<String, dynamic>?;
        final id = s?['description']?['identifier'] as String?;
        recordId('water', id);
        if (id != null) waterIds.add(id);
        final caustics = s?['caustics'];
        final wavesEnabled = s?['waves']?['enabled'];
        final sig = jsonEncode({'caustics': caustics, 'waves': wavesEnabled});
        lockedWaterSig ??= sig;
        if (sig != lockedWaterSig) {
          errors.add(
            '[$scopeLabel] Water pack-wide invariant (caustics.* / waves.enabled) mismatch in $rel.',
          );
        }
      } else if (rel.startsWith('fogs/') && rel.endsWith('.json')) {
        final d = readTierJson(subPrefix, rel);
        final id = d?['minecraft:fog_settings']?['description']?['identifier']
            as String?;
        recordId('fog', id);
        if (id != null) fogIds.add(id);
      }
    }

    // Verify local_lighting schema (no description/colors wrapper, valid light_type)
    final llData = readTierJson(subPrefix, 'local_lighting/local_lighting.json');
    if (llData == null) {
      errors.add('[$scopeLabel] Missing local_lighting/local_lighting.json.');
    } else {
      final llSettings =
          llData['minecraft:local_light_settings'] as Map<String, dynamic>?;
      if (llSettings == null ||
          llSettings.containsKey('description') ||
          llSettings.containsKey('colors')) {
        errors.add(
          '[$scopeLabel] local_lighting.json must use direct block keys under minecraft:local_light_settings.',
        );
      }
    }

    // Verify no legacy point_lights/global.json exists
    if (effectivePaths.any((p) => p.startsWith('point_lights/'))) {
      errors.add(
        '[$scopeLabel] Legacy point_lights/ files must not be emitted.',
      );
    }

    // Verify pbr/global.json uses official minecraft:pbr_fallback_settings
    final pbrData = readTierJson(subPrefix, 'pbr/global.json');
    if (pbrData == null ||
        pbrData['minecraft:pbr_fallback_settings'] == null) {
      errors.add(
        '[$scopeLabel] pbr/global.json must contain minecraft:pbr_fallback_settings.',
      );
    }

    // Verify all 87 vanilla biomes exist and their referenced IDs exist
    for (final biome in kVanillaBiomes) {
      final rel = 'biomes/${biome.id}.client_biome.json';
      final bData = readTierJson(subPrefix, rel);
      if (bData == null) {
        errors.add('[$scopeLabel] Missing biome file $rel.');
        continue;
      }
      final comps =
          bData['minecraft:client_biome']?['components']
              as Map<String, dynamic>?;
      if (comps == null) {
        errors.add('[$scopeLabel] Missing components in $rel.');
        continue;
      }

      void checkRef(String compKey, String fieldKey, Set<String> validSet) {
        final ref = (comps[compKey] as Map?)?[fieldKey] as String?;
        if (ref == null || !validSet.contains(ref)) {
          errors.add(
            '[$scopeLabel] $rel references unknown $compKey "$ref".',
          );
        }
      }

      checkRef('minecraft:atmosphere_identifier', 'atmosphere_identifier', atmoIds);
      checkRef('minecraft:lighting_identifier', 'lighting_identifier', lightIds);
      checkRef(
        'minecraft:color_grading_identifier',
        'color_grading_identifier',
        cgIds,
      );
      checkRef('minecraft:water_identifier', 'water_identifier', waterIds);
      checkRef('minecraft:fog_appearance', 'fog_identifier', fogIds);
    }
  }

  // Verify root scope
  verifyScope('root', '');

  // Verify each generated subpack scope
  final subpackNames = <String>{
    for (final p in files.keys)
      if (p.startsWith('subpacks/')) p.split('/')[1],
  };
  for (final sub in subpackNames) {
    verifyScope('subpack:$sub', 'subpacks/$sub/');
  }

  return ValidationReport(errors: errors, warnings: warnings);
}
