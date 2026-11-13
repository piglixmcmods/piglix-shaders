// vv_import.dart
import 'dart:convert';
import 'dart:typed_data';
import 'package:archive/archive.dart';
import 'package:flutter/material.dart' show Color;
import 'shader_presets.dart';
import 'vv_config.dart';

/// Result of importing a `.mcpack` / `.zip` archive into a [VVShaderConfig].
class VVPackImportResult {
  final VVShaderConfig config;
  final Uint8List? packIconBytes;
  final String? importedPackName;
  final MigrationResult? legacyMigration;
  final bool wasNativeVVPack;

  const VVPackImportResult({
    required this.config,
    this.packIconBytes,
    this.importedPackName,
    this.legacyMigration,
    this.wasNativeVVPack = false,
  });
}

/// Converts a legacy [ShaderPresetConfig] into a [VVShaderConfig] via
/// [migrateFromLegacy], preserving [ShaderPresetConfig.name] and
/// [ShaderPresetConfig.description] and reporting any dropped non-VV fields.
MigrationResult migrateFromShaderPreset(ShaderPresetConfig preset) {
  final legacyMap = <String, dynamic>{
    'id': preset.id,
    'name': preset.name,
    'packName': preset.name,
    'creator': preset.creator,
    'description': preset.description,
    'rating': preset.rating,
    'downloads': preset.downloads,
    'tags': preset.tags,
    // Atmosphere
    'morningColor': preset.morningColor,
    'noonColor': preset.noonColor,
    'eveningColor': preset.eveningColor,
    'nightColor': preset.nightColor,
    'sunSize': preset.sunSize,
    'nightVision': preset.nightVision,
    'fogDensity': preset.fogDensity,
    'cloudType': preset.cloudType,
    // Lighting & Point Lights
    'torchColor': preset.torchColor,
    'lightIntensity': preset.lightIntensity,
    'blockLightIntensity': preset.blockLightIntensity,
    'shadowQuality': preset.shadowQuality,
    'enablePointLightShadows': preset.enablePointLightShadows,
    'volumetricFogProfile': preset.volumetricFogProfile,
    // God Rays
    'rayMorningColor': preset.rayMorningColor,
    'rayNoonColor': preset.rayNoonColor,
    'rayEveningColor': preset.rayEveningColor,
    'rayNightColor': preset.rayNightColor,
    // Water
    'waterColor': preset.waterColor,
    'windSpeed': preset.windSpeed,
    'waterQuality': preset.waterQuality,
    'underwaterCaustics': preset.underwaterCaustics,
    // Weather
    'rainFogColor': preset.rainFogColor,
    'rainWaterColor': preset.rainWaterColor,
    // PBR & Foliage
    'worldReflections': preset.worldReflections,
    'enablePBR': preset.enablePBR,
    'metalness': preset.metalness,
    'wavingFoliage': preset.wavingFoliage,
    'foliageWaveSpeed': preset.foliageWaveSpeed,
    // Post-FX
    'toneMapFilter': preset.toneMapFilter,
    'biomeTone': preset.biomeTone,
    'saturation': preset.saturation,
    'contrast': preset.contrast,
    'autoExposure': preset.autoExposure,
  };

  final result = migrateFromLegacy(legacyMap);
  final preservedDesc = preset.description.trim();
  return MigrationResult(
    config: result.config.copyWith(
      packName: preset.name,
      packDescription: preservedDesc.isNotEmpty ? preservedDesc : null,
    ),
    droppedUnsupportedCount: result.droppedUnsupportedCount,
    droppedKeys: result.droppedKeys,
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// JSONC & Archive Normalization Helpers
// ─────────────────────────────────────────────────────────────────────────────

/// Strips `//` line comments, `/* ... */` block comments (respecting quoted
/// strings), and trailing commas before `}` or `]`.
String _stripJsonc(String input) {
  final out = StringBuffer();
  var inString = false;
  var escaped = false;
  var inLineComment = false;
  var inBlockComment = false;

  for (var i = 0; i < input.length; i++) {
    final c = input[i];
    final next = i + 1 < input.length ? input[i + 1] : '';

    if (inLineComment) {
      if (c == '\n') {
        inLineComment = false;
        out.write(c);
      }
      continue;
    }

    if (inBlockComment) {
      if (c == '*' && next == '/') {
        inBlockComment = false;
        i++;
      } else if (c == '\n') {
        out.write('\n');
      }
      continue;
    }

    if (inString) {
      out.write(c);
      if (escaped) {
        escaped = false;
      } else if (c == r'\') {
        escaped = true;
      } else if (c == '"') {
        inString = false;
      }
      continue;
    }

    if (c == '"') {
      inString = true;
      out.write(c);
      continue;
    }

    if (c == '/' && next == '/') {
      inLineComment = true;
      i++;
      continue;
    }

    if (c == '/' && next == '*') {
      inBlockComment = true;
      i++;
      continue;
    }

    out.write(c);
  }

  return out.toString().replaceAll(RegExp(r',\s*([}\]])'), r'$1');
}

Map<String, dynamic>? _decodeJsonObject(List<int>? bytes) {
  if (bytes == null || bytes.isEmpty) return null;
  try {
    final raw = utf8.decode(bytes, allowMalformed: true);
    final cleaned = _stripJsonc(raw).trim();
    if (cleaned.isEmpty) return null;
    final decoded = jsonDecode(cleaned);
    if (decoded is Map<String, dynamic>) return decoded;
    if (decoded is Map) {
      return decoded.map((k, v) => MapEntry(k.toString(), v));
    }
  } catch (_) {}
  return null;
}

Map<String, dynamic>? _asMap(dynamic v) {
  if (v is Map<String, dynamic>) return v;
  if (v is Map) {
    return v.map((k, val) => MapEntry(k.toString(), val));
  }
  return null;
}

double? _asDouble(dynamic v) {
  if (v is num) return v.toDouble();
  if (v is String) return double.tryParse(v.trim());
  return null;
}

int? _asInt(dynamic v) {
  if (v is int) return v;
  if (v is num) return v.round();
  if (v is String) return int.tryParse(v.trim());
  return null;
}

bool? _asBool(dynamic v) {
  if (v is bool) return v;
  if (v is num) return v != 0;
  if (v is String) {
    final s = v.trim().toLowerCase();
    if (s == 'true' || s == '1') return true;
    if (s == 'false' || s == '0') return false;
  }
  return null;
}

Color? _parseColor(dynamic v, {bool unitFloats = false}) {
  if (v is Color) return v;
  if (v is String) {
    final hex = v.replaceFirst('#', '').trim();
    if (hex.length == 6) {
      final parsed = int.tryParse('FF$hex', radix: 16);
      if (parsed != null) return Color(parsed);
    } else if (hex.length == 8) {
      final parsed = int.tryParse(hex, radix: 16);
      if (parsed != null) return Color(parsed);
    }
    return null;
  }
  if (v is List && v.length >= 3) {
    final rNum = _asDouble(v[0]);
    final gNum = _asDouble(v[1]);
    final bNum = _asDouble(v[2]);
    if (rNum == null || gNum == null || bNum == null) return null;
    final useFloat =
        unitFloats || (rNum <= 1.0 && gNum <= 1.0 && bNum <= 1.0 &&
            (v[0] is double || v[1] is double || v[2] is double) &&
            (rNum > 0 && rNum < 1 || gNum > 0 && gNum < 1 || bNum > 0 && bNum < 1));
    int toByte(double x) =>
        (useFloat ? (x * 255.0).round() : x.round()).clamp(0, 255);
    return Color.fromARGB(255, toByte(rNum), toByte(gNum), toByte(bNum));
  }
  return null;
}

List<double>? _parseVec3(
  dynamic v, {
  required double min,
  required double max,
}) {
  if (v is List && v.isNotEmpty) {
    final x = _asDouble(v[0])?.clamp(min, max);
    if (x == null) return null;
    final y = (v.length > 1 ? _asDouble(v[1]) : null)?.clamp(min, max) ?? x;
    final z = (v.length > 2 ? _asDouble(v[2]) : null)?.clamp(min, max) ?? y;
    return [x, y, z];
  }
  final scalar = _asDouble(v);
  if (scalar != null) {
    final c = scalar.clamp(min, max);
    return [c, c, c];
  }
  return null;
}

/// Samples a VV keyframe map (`{"0.000000": val, ...}`) or scalar value at [targetTime].
dynamic _sampleKeyframe(dynamic raw, double targetTime) {
  final map = _asMap(raw);
  if (map == null) return raw;
  if (map.isEmpty) return null;

  double? bestTime;
  dynamic bestValue;
  var bestDist = double.infinity;

  for (final entry in map.entries) {
    final t = double.tryParse(entry.key.trim());
    if (t == null) continue;
    final dist = (t - targetTime).abs();
    if (dist < bestDist) {
      bestDist = dist;
      bestTime = t;
      bestValue = entry.value;
    }
  }

  if (bestTime != null) return bestValue;
  return map.values.first;
}

double? _sampleDoubleKeyframe(dynamic raw, double targetTime) =>
    _asDouble(_sampleKeyframe(raw, targetTime));

Color? _sampleColorKeyframe(dynamic raw, double targetTime) =>
    _parseColor(_sampleKeyframe(raw, targetTime));

String _detectRootPrefix(Archive archive) {
  final nonDirFiles = archive.where((f) => f.isFile).toList();
  if (nonDirFiles.isEmpty) return '';

  final first = nonDirFiles.first.name.replaceAll('\\', '/');
  final slashIdx = first.indexOf('/');
  if (slashIdx == -1) return '';

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
    'renderer/',
  ];
  if (standardDirs.any((d) => candidate.startsWith(d))) {
    return '';
  }
  if (nonDirFiles.every(
    (f) => f.name.replaceAll('\\', '/').startsWith(candidate),
  )) {
    return candidate;
  }
  return '';
}

// ─────────────────────────────────────────────────────────────────────────────
// Individual Section Parsers
// ─────────────────────────────────────────────────────────────────────────────

AtmosphereConfig _parseAtmosphere(
  Map<String, dynamic> json,
  AtmosphereConfig base,
) {
  final atmo = _asMap(json['minecraft:atmosphere_settings']) ?? json;

  final zenithRaw = atmo['sky_zenith_color'];
  final horizonRaw = atmo['sky_horizon_color'];
  final rayleighRaw = atmo['rayleigh_strength'];
  final sunMieRaw = atmo['sun_mie_strength'];
  final moonMieRaw = atmo['moon_mie_strength'];
  final sunGlareRaw = atmo['sun_glare_shape'];
  final stops = _asMap(atmo['horizon_blend_stops']);
  final hazeStartRaw = stops?['start'];

  final noonZ = _sampleColorKeyframe(zenithRaw, 0.0);
  final sunsetZ = _sampleColorKeyframe(zenithRaw, 0.25);
  final nightZ = _sampleColorKeyframe(zenithRaw, 0.5);
  final sunriseZ = _sampleColorKeyframe(zenithRaw, 0.75);

  final hasExplicitZenith =
      noonZ != null || sunsetZ != null || nightZ != null || sunriseZ != null;

  return base.copyWith(
    autoDeriveZenith: hasExplicitZenith ? false : base.autoDeriveZenith,
    noonZenith: noonZ,
    sunsetZenith: sunsetZ,
    nightZenith: nightZ,
    sunriseZenith: sunriseZ,
    noonHorizon: _sampleColorKeyframe(horizonRaw, 0.0),
    sunsetHorizon: _sampleColorKeyframe(horizonRaw, 0.25),
    nightHorizon: _sampleColorKeyframe(horizonRaw, 0.5),
    sunriseHorizon: _sampleColorKeyframe(horizonRaw, 0.75),
    rayleighNoon: _sampleDoubleKeyframe(rayleighRaw, 0.0)?.clamp(0.0, 11.0),
    rayleighSunset: _sampleDoubleKeyframe(rayleighRaw, 0.25)?.clamp(0.0, 11.0),
    rayleighNight: _sampleDoubleKeyframe(rayleighRaw, 0.5)?.clamp(0.0, 11.0),
    rayleighSunrise: _sampleDoubleKeyframe(rayleighRaw, 0.75)?.clamp(0.0, 11.0),
    sunGlowNoon: _sampleDoubleKeyframe(sunMieRaw, 0.0)?.clamp(0.0, 60.0),
    sunGlowSunset: _sampleDoubleKeyframe(sunMieRaw, 0.25)?.clamp(0.0, 60.0),
    sunGlowSunrise: _sampleDoubleKeyframe(sunMieRaw, 0.75)?.clamp(0.0, 60.0),
    moonGlow: _sampleDoubleKeyframe(moonMieRaw, 0.5)?.clamp(0.0, 20.0),
    sunGlareNoon: _sampleDoubleKeyframe(sunGlareRaw, 0.0)?.clamp(0.01, 50.0),
    sunGlareSunset: _sampleDoubleKeyframe(sunGlareRaw, 0.25)?.clamp(0.01, 50.0),
    sunGlareSunrise:
        _sampleDoubleKeyframe(sunGlareRaw, 0.75)?.clamp(0.01, 50.0),
    horizonHazeScale: hazeStartRaw != null ? 1.0 : base.horizonHazeScale,
    horizonHazeNoon:
        _sampleDoubleKeyframe(hazeStartRaw, 0.0)?.clamp(0.0, 1.0),
    horizonHazeSunset:
        _sampleDoubleKeyframe(hazeStartRaw, 0.25)?.clamp(0.0, 1.0),
    horizonHazeNight:
        _sampleDoubleKeyframe(hazeStartRaw, 0.5)?.clamp(0.0, 1.0),
    horizonHazeSunrise:
        _sampleDoubleKeyframe(hazeStartRaw, 0.75)?.clamp(0.0, 1.0),
  );
}

LightingConfig _parseLighting(
  Map<String, dynamic> json,
  LightingConfig base,
) {
  final settings = _asMap(json['minecraft:lighting_settings']) ?? json;
  final dirLights = _asMap(settings['directional_lights']);
  final orbital = _asMap(dirLights?['orbital']);
  final sun = _asMap(orbital?['sun']);
  final moon = _asMap(orbital?['moon']);
  final flash = _asMap(dirLights?['flash']);
  final emissive = _asMap(settings['emissive']);
  final ambient = _asMap(settings['ambient']);
  final sky = _asMap(settings['sky']);

  final noonLux = _sampleDoubleKeyframe(sun?['illuminance'], 0.0);
  final sunMult = noonLux != null
      ? (noonLux / 109880.0).clamp(0.1, 2.0)
      : base.sunBrightnessMultiplier;

  final sunColorRaw = sun?['color'];

  return base.copyWith(
    sunBrightnessMultiplier: sunMult,
    sunColorNoon: _sampleColorKeyframe(sunColorRaw, 0.0),
    sunColorSunset: _sampleColorKeyframe(sunColorRaw, 0.25),
    nightMoonColor: _sampleColorKeyframe(sunColorRaw, 0.5),
    sunColorSunrise: _sampleColorKeyframe(sunColorRaw, 0.75),
    moonIlluminance:
        _sampleDoubleKeyframe(moon?['illuminance'], 0.5)?.clamp(0.0, 20.0),
    moonColor: _sampleColorKeyframe(moon?['color'], 0.5),
    orbitalOffsetDegrees:
        _sampleDoubleKeyframe(orbital?['orbital_offset_degrees'], 0.0)
            ?.clamp(0.0, 359.98),
    flashIlluminance:
        _sampleDoubleKeyframe(flash?['illuminance'], 0.0)?.clamp(0.0, 20000.0),
    flashColor: _sampleColorKeyframe(flash?['color'], 0.0),
    emissiveDesaturation:
        _asDouble(emissive?['desaturation'])?.clamp(0.0, 1.0),
    ambientIlluminance:
        _asDouble(ambient?['illuminance'])?.clamp(0.0, 5.0),
    ambientColor: _parseColor(ambient?['color']),
    skyIntensity: _asDouble(sky?['intensity'])?.clamp(0.1, 1.0),
  );
}

BlockLightGroup _extractBlockGroup(
  Map<String, dynamic> settings,
  List<String> keys,
  BlockLightGroup fallback,
) {
  for (final k in keys) {
    final raw = settings[k];
    if (raw == null) continue;
    final entry = _asMap(raw);
    if (entry != null) {
      final color = _parseColor(entry['light_color'] ?? entry['color']);
      final ltRaw = entry['light_type'] as String?;
      final lt = ltRaw == 'static_light' ? 'static_light' : 'point_light';
      return BlockLightGroup(
        color: color ?? fallback.color,
        lightType: ltRaw != null ? lt : fallback.lightType,
      );
    }
    final directColor = _parseColor(raw);
    if (directColor != null) {
      return fallback.copyWith(color: directColor);
    }
  }
  return fallback;
}

LightingConfig _parseLocalLighting(
  Map<String, dynamic> json,
  LightingConfig base,
) {
  // Supports 1.21.120 `minecraft:local_light_settings` as well as legacy
  // `minecraft:point_light_settings` / `colors` wrappers.
  final root = _asMap(json['minecraft:local_light_settings']) ??
      _asMap(json['minecraft:point_light_settings']) ??
      json;
  final colors = _asMap(root['colors']) ?? root;

  final torches = _extractBlockGroup(
    colors,
    LightingConfig.torchBlocks,
    base.torches,
  );
  final lanterns = _extractBlockGroup(
    colors,
    LightingConfig.lanternBlocks,
    base.lanterns,
  );
  final soulFire = _extractBlockGroup(
    colors,
    LightingConfig.soulBlocks,
    base.soulFire,
  );
  final candles = _extractBlockGroup(
    colors,
    LightingConfig.candleBlocks,
    base.candles,
  );
  final redstone = _extractBlockGroup(
    colors,
    LightingConfig.redstoneBlocks,
    base.redstone,
  );
  final endRod = _extractBlockGroup(
    colors,
    LightingConfig.endRodBlocks,
    base.endRod,
  );
  final copper = _extractBlockGroup(
    colors,
    LightingConfig.copperBlocks,
    base.copper,
  );

  final hasMystic = LightingConfig.mysticBlocks.any(colors.containsKey);
  final mysticGroup = hasMystic
      ? _extractBlockGroup(colors, LightingConfig.mysticBlocks, soulFire)
      : null;
  final syncMystic = hasMystic
      ? mysticGroup!.color == soulFire.color
      : base.syncMysticToSoul;

  final hasRedstone = LightingConfig.redstoneBlocks.any(colors.containsKey);
  final syncWarm = hasRedstone &&
          redstone.color == torches.color &&
          torches.color != const Color(0xFFFF0000)
      ? true
      : base.syncWarmToTorch;

  return base.copyWith(
    torches: torches,
    lanterns: lanterns,
    soulFire: soulFire,
    candles: candles,
    redstone: redstone,
    endRod: endRod,
    copper: copper,
    syncMysticToSoul: syncMystic,
    syncWarmToTorch: syncWarm,
  );
}

LightingConfig _parseShadows(
  Map<String, dynamic> json,
  LightingConfig base,
) {
  final s = _asMap(json['minecraft:shadow_settings']) ?? json;
  final styleRaw = s['shadow_style'] as String?;
  final style = (styleRaw == 'blocky_shadows' || styleRaw == 'soft_shadows')
      ? styleRaw
      : base.shadowStyle;
  final texel = _asInt(s['texel_size'])?.clamp(1, 1024);

  return base.copyWith(
    shadowStyle: style,
    shadowTexelSize: texel,
  );
}

SurfaceConfig _parsePbr(
  Map<String, dynamic> json,
  SurfaceConfig base,
) {
  final root = _asMap(json['minecraft:pbr_fallback_settings']) ??
      _asMap(json['minecraft:pog_fallback_settings']) ??
      json;
  final blocks = _asMap(root['blocks']);
  final arr = blocks?['global_metalness_emissive_roughness_subsurface'];
  if (arr is List && arr.length >= 4) {
    final m = (_asInt(arr[0]) ?? base.metalness).clamp(0, 255);
    final e = (_asInt(arr[1]) ?? base.emissive).clamp(0, 255);
    final r = (_asInt(arr[2]) ?? base.roughness).clamp(0, 255);
    final sub = (_asInt(arr[3]) ?? base.subsurface).clamp(0, 255);
    return SurfaceConfig(
      metalness: m,
      emissive: e,
      roughness: r,
      subsurface: sub,
    );
  }
  return base;
}

ColorGradingConfig _parseColorGrading(
  Map<String, dynamic> json,
  ColorGradingConfig base,
) {
  final root = _asMap(json['minecraft:color_grading_settings']) ?? json;
  final cg = _asMap(root['color_grading']) ?? root;
  final toneMapping = _asMap(root['tone_mapping']);

  final rawOp = (toneMapping?['operator'] as String?)?.trim().toLowerCase();
  final op = rawOp != null && ColorGradingConfig.validOperators.contains(rawOp)
      ? rawOp
      : base.toneMappingOperator;

  // Support temperature inside `color_grading` (1.21.90+) or legacy sibling
  final temp = _asMap(cg['temperature']) ?? _asMap(root['temperature']);
  final rawTempType = (temp?['type'] as String?)?.trim();
  final tempType = (rawTempType == 'color_temperature' ||
          rawTempType == 'white_balance')
      ? rawTempType
      : base.temperatureType;

  final mid = _asMap(cg['midtones']);
  final hi = _asMap(cg['highlights']);
  final sh = _asMap(cg['shadows']);

  return base.copyWith(
    toneMappingOperator: op,
    temperatureEnabled: _asBool(temp?['enabled']),
    temperatureType: tempType,
    temperature: _asDouble(temp?['temperature'])?.clamp(1000.0, 15000.0),
    midtonesContrast: _parseVec3(mid?['contrast'], min: 0.0, max: 4.0),
    midtonesGain: _parseVec3(mid?['gain'], min: 0.0, max: 10.0),
    midtonesGamma: _parseVec3(mid?['gamma'], min: 0.0, max: 4.0),
    midtonesOffset: _parseVec3(mid?['offset'], min: -1.0, max: 1.0),
    midtonesSaturation: _parseVec3(mid?['saturation'], min: 0.0, max: 10.0),
    highlightsEnabled: _asBool(hi?['enabled']),
    highlightsMin: _asDouble(hi?['highlightsMin'])?.clamp(1.0, 4.0),
    highlightsContrast: _parseVec3(hi?['contrast'], min: 0.0, max: 4.0),
    highlightsGain: _parseVec3(hi?['gain'], min: 0.0, max: 10.0),
    highlightsGamma: _parseVec3(hi?['gamma'], min: 0.0, max: 4.0),
    highlightsOffset: _parseVec3(hi?['offset'], min: -1.0, max: 1.0),
    highlightsSaturation: _parseVec3(hi?['saturation'], min: 0.0, max: 10.0),
    shadowsEnabled: _asBool(sh?['enabled']),
    shadowsMax: _asDouble(sh?['shadowsMax'])?.clamp(0.1, 1.0),
    shadowsContrast: _parseVec3(sh?['contrast'], min: 0.0, max: 4.0),
    shadowsGain: _parseVec3(sh?['gain'], min: 0.0, max: 10.0),
    shadowsGamma: _parseVec3(sh?['gamma'], min: 0.0, max: 4.0),
    shadowsOffset: _parseVec3(sh?['offset'], min: -1.0, max: 1.0),
    shadowsSaturation: _parseVec3(sh?['saturation'], min: 0.0, max: 10.0),
  );
}

WaterPresetConfig _parseWaterPreset(
  Map<String, dynamic> json,
  WaterPresetConfig base,
) {
  final settings = _asMap(json['minecraft:water_settings']) ?? json;
  final particles = _asMap(settings['particle_concentrations']);
  final caustics = _asMap(settings['caustics']);
  final waves = _asMap(settings['waves']);

  return base.copyWith(
    biomeWaterColorContribution:
        _asDouble(settings['biome_water_color_contribution'])?.clamp(0.0, 1.0),
    cdom: _asDouble(particles?['cdom'])?.clamp(0.0, 15.0),
    chlorophyll: _asDouble(particles?['chlorophyll'])?.clamp(0.0, 10.0),
    suspendedSediment:
        _asDouble(particles?['suspended_sediment'])?.clamp(0.0, 300.0),
    causticsEnabled: _asBool(caustics?['enabled']),
    causticsFrameLength:
        _asDouble(caustics?['frame_length'])?.clamp(0.01, 5.0),
    causticsScale: _asDouble(caustics?['scale'])?.clamp(0.1, 5.0),
    causticsPower: _asInt(caustics?['power'])?.clamp(1, 6),
    wavesEnabled: _asBool(waves?['enabled']),
    wavesFrequency: _asDouble(waves?['frequency'])?.clamp(0.01, 3.0),
    wavesOctaves: _asInt(waves?['octaves'])?.clamp(1, 30),
    wavesDepth: _asDouble(waves?['depth'])?.clamp(0.0, 3.0),
    wavesSampleWidth: _asDouble(waves?['sampleWidth'])?.clamp(0.01, 1.0),
    wavesSpeed: _asDouble(waves?['speed'])?.clamp(0.01, 10.0),
    wavesPull: _asDouble(waves?['pull'])?.clamp(-1.0, 1.0),
    wavesMix: _asDouble(waves?['mix'])?.clamp(0.0, 1.0),
    wavesFrequencyScaling:
        _asDouble(waves?['frequency_scaling'])?.clamp(0.0, 2.0),
    wavesSpeedScaling: _asDouble(waves?['speed_scaling'])?.clamp(0.0, 2.0),
    wavesDirectionIncrement:
        _asInt(waves?['direction_increment'])?.clamp(0, 360),
    wavesShape: _asDouble(waves?['shape'])?.clamp(1.0, 10.0),
  );
}

FogConfig _parseFog(
  Map<String, dynamic> json,
  FogConfig base,
) {
  final settings = _asMap(json['minecraft:fog_settings']) ?? json;
  final distance = _asMap(settings['distance']);
  final air = _asMap(distance?['air']);
  final weather = _asMap(distance?['weather']);
  final water = _asMap(distance?['water']);

  final volumetric = _asMap(settings['volumetric']);
  final density = _asMap(volumetric?['density']);
  final volAir = _asMap(density?['air']);
  final volWater = _asMap(density?['water']);
  final media = _asMap(volumetric?['media_coefficients']);
  final mediaAir = _asMap(media?['air']);

  final airDistType = (air?['render_distance_type'] as String?)?.toLowerCase();
  final useRenderAir = airDistType == null || airDistType == 'render';
  final airStart = useRenderAir
      ? _asDouble(air?['fog_start'])?.clamp(0.05, 0.99)
      : null;
  final airEnd = useRenderAir
      ? _asDouble(air?['fog_end'])?.clamp(0.1, 1.0)
      : null;

  final wxDistType =
      (weather?['render_distance_type'] as String?)?.toLowerCase();
  final useRenderWx = wxDistType == null || wxDistType == 'render';
  final wxStart = useRenderWx
      ? _asDouble(weather?['fog_start'])?.clamp(0.05, 0.99)
      : null;
  final wxEnd = useRenderWx
      ? _asDouble(weather?['fog_end'])?.clamp(0.1, 1.0)
      : null;

  return base.copyWith(
    airFogColor: _parseColor(air?['fog_color']),
    airFogStart: airStart,
    airFogEnd: airEnd,
    weatherFogColor: _parseColor(weather?['fog_color']),
    weatherFogStart: wxStart,
    weatherFogEnd: wxEnd,
    waterFogColor: _parseColor(water?['fog_color']),
    waterFogEnd: _asDouble(water?['fog_end'])?.clamp(12.0, 120.0),
    volumetricMaxDensity:
        _asDouble(volAir?['max_density'])?.clamp(0.002, 0.25),
    volumetricZeroDensityHeight:
        _asDouble(volAir?['zero_density_height'])?.clamp(50.0, 320.0),
    volumetricMaxDensityHeight:
        _asDouble(volAir?['max_density_height'])?.clamp(-64.0, 200.0),
    hazeScatteringColor:
        _parseColor(mediaAir?['scattering'], unitFloats: true),
    underwaterVolumeDensity:
        _asDouble(volWater?['max_density'])?.clamp(0.002, 0.08),
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// Archive Parser
// ─────────────────────────────────────────────────────────────────────────────

/// Parses a `.mcpack` / `.zip` [Archive] into a [VVPackImportResult].
/// Safely strips JSONC comments, clamps values to VV schema bounds, and never
/// throws on malformed or partial packs.
VVPackImportResult parseVVPackFromArchive(
  Archive archive, {
  String? fallbackName,
}) {
  final prefix = _detectRootPrefix(archive);
  final files = <String, List<int>>{};

  for (final file in archive) {
    if (!file.isFile) continue;
    var name = file.name.replaceAll('\\', '/');
    if (prefix.isNotEmpty && name.startsWith(prefix)) {
      name = name.substring(prefix.length);
    }
    try {
      files[name] = file.content;
    } catch (_) {}
  }

  // Extract pack_icon.png
  Uint8List? iconBytes;
  final rawIcon = files['pack_icon.png'];
  if (rawIcon != null && rawIcon.isNotEmpty) {
    iconBytes = Uint8List.fromList(rawIcon);
  }

  // Extract optional texts/en_US.lang fallback for localized pack.name/description
  String? langName;
  String? langDesc;
  final langBytes = files['texts/en_US.lang'];
  if (langBytes != null) {
    try {
      final langText = utf8.decode(langBytes, allowMalformed: true);
      for (final line in langText.split('\n')) {
        final trimmed = line.trim();
        if (trimmed.startsWith('pack.name=')) {
          langName = trimmed.substring('pack.name='.length).trim();
        } else if (trimmed.startsWith('pack.description=')) {
          langDesc = trimmed.substring('pack.description='.length).trim();
        }
      }
    } catch (_) {}
  }

  // Extract manifest.json metadata
  var cfg = const VVShaderConfig();
  String? importedPackName;
  var hasSubpacksDir = files.keys.any((k) => k.startsWith('subpacks/'));
  var hasLiteSubpack = files.keys.any((k) => k.startsWith('subpacks/lite/'));
  var hasMultipleTiers = false;

  final manifest = _decodeJsonObject(files['manifest.json']);
  if (manifest != null) {
    final header = _asMap(manifest['header']);
    final rawName = (header?['name'] as String?)?.trim();
    if (rawName != null && rawName.isNotEmpty) {
      importedPackName =
          (rawName == 'pack.name' && langName != null && langName.isNotEmpty)
              ? langName
              : rawName;
    } else if (langName != null && langName.isNotEmpty) {
      importedPackName = langName;
    }

    final rawDesc = (header?['description'] as String?)?.trim();
    String? resolvedDesc;
    if (rawDesc != null && rawDesc.isNotEmpty) {
      resolvedDesc = (rawDesc == 'pack.description' &&
              langDesc != null &&
              langDesc.isNotEmpty)
          ? langDesc
          : rawDesc;
    } else if (langDesc != null && langDesc.isNotEmpty) {
      resolvedDesc = langDesc;
    }

    List<int>? parsedVer;
    final verRaw = header?['version'];
    if (verRaw is List && verRaw.length == 3) {
      final v0 = _asInt(verRaw[0]);
      final v1 = _asInt(verRaw[1]);
      final v2 = _asInt(verRaw[2]);
      if (v0 != null && v1 != null && v2 != null && v0 >= 0 && v1 >= 0 && v2 >= 0) {
        parsedVer = [v0, v1, v2];
      }
    }

    final subpacksRaw = manifest['subpacks'];
    if (subpacksRaw is List && subpacksRaw.isNotEmpty) {
      hasSubpacksDir = true;
      var tierCount = 0;
      for (final sp in subpacksRaw) {
        final folder = (_asMap(sp)?['folder_name'] as String?)?.toLowerCase();
        if (folder == 'lite') {
          hasLiteSubpack = true;
        } else if (folder == 'low' ||
            folder == 'medium' ||
            folder == 'high' ||
            folder == 'ultra') {
          tierCount++;
        }
      }
      if (tierCount > 1) hasMultipleTiers = true;
    }

    cfg = cfg.copyWith(
      packName: importedPackName ?? fallbackName ?? cfg.packName,
      packDescription: resolvedDesc ?? cfg.packDescription,
      packVersion: parsedVer ?? cfg.packVersion,
    );
  } else if (fallbackName != null && fallbackName.trim().isNotEmpty) {
    importedPackName = fallbackName.trim();
    cfg = cfg.copyWith(packName: importedPackName);
  }

  // Detect native VV files
  final hasNativeVV = files.containsKey('atmospherics/atmospherics.json') ||
      files.containsKey('lighting/global.json') ||
      files.containsKey('local_lighting/local_lighting.json') ||
      files.containsKey('point_lights/global.json') ||
      files.containsKey('shadows/global.json') ||
      files.containsKey('pbr/global.json') ||
      files.containsKey('color_grading/color_grading.json') ||
      files.keys.any((k) => k.startsWith('water/') && k.endsWith('.json')) ||
      files.keys.any((k) => k.startsWith('fogs/') && k.endsWith('.json')) ||
      hasSubpacksDir;

  if (!hasNativeVV) {
    return VVPackImportResult(
      config: cfg,
      packIconBytes: iconBytes,
      importedPackName: importedPackName ?? fallbackName,
      wasNativeVVPack: false,
    );
  }

  // 1. Atmospherics
  final atmoJson = _decodeJsonObject(files['atmospherics/atmospherics.json']);
  if (atmoJson != null) {
    try {
      cfg = cfg.copyWith(atmosphere: _parseAtmosphere(atmoJson, cfg.atmosphere));
    } catch (_) {}
  }

  // 2. Lighting + Local Lighting + Shadows
  var lighting = cfg.lighting;
  final lightJson = _decodeJsonObject(files['lighting/global.json']);
  if (lightJson != null) {
    try {
      lighting = _parseLighting(lightJson, lighting);
    } catch (_) {}
  }

  final localLightJson =
      _decodeJsonObject(files['local_lighting/local_lighting.json']) ??
          _decodeJsonObject(files['point_lights/global.json']);
  if (localLightJson != null) {
    try {
      lighting = _parseLocalLighting(localLightJson, lighting);
    } catch (_) {}
  }

  final shadowsJson = _decodeJsonObject(files['shadows/global.json']);
  if (shadowsJson != null) {
    try {
      lighting = _parseShadows(shadowsJson, lighting);
    } catch (_) {}
  }
  cfg = cfg.copyWith(lighting: lighting);

  // 3. PBR Surface
  final pbrJson = _decodeJsonObject(files['pbr/global.json']);
  if (pbrJson != null) {
    try {
      cfg = cfg.copyWith(surface: _parsePbr(pbrJson, cfg.surface));
    } catch (_) {}
  }

  // 4. Color Grading
  final cgJson = _decodeJsonObject(files['color_grading/color_grading.json']);
  if (cgJson != null) {
    try {
      cfg = cfg.copyWith(
        colorGrading: _parseColorGrading(cgJson, cfg.colorGrading),
      );
    } catch (_) {}
  }

  // 5. Water Presets
  var waterTropical = cfg.waterTropical;
  var waterOcean = cfg.waterOcean;
  var waterDeepOcean = cfg.waterDeepOcean;
  var waterRiver = cfg.waterRiver;
  var waterSwamp = cfg.waterSwamp;
  var parsedAnyOcean = false;
  var parsedAnyTropical = false;

  final waterFiles = files.entries
      .where((e) => e.key.startsWith('water/') && e.key.endsWith('.json'))
      .toList()
    ..sort((a, b) => a.key.compareTo(b.key));

  for (final entry in waterFiles) {
    final json = _decodeJsonObject(entry.value);
    if (json == null) continue;
    try {
      final settings = _asMap(json['minecraft:water_settings']) ?? json;
      final descId =
          (_asMap(settings['description'])?['identifier'] as String?) ?? '';
      final bareId = descId.contains(':') ? descId.split(':').last : descId;
      final fileName = entry.key.toLowerCase();
      final key = '${bareId.toLowerCase()}|$fileName';

      if (key.contains('deep_ocean') || key.contains('water_two')) {
        waterDeepOcean = _parseWaterPreset(json, waterDeepOcean);
      } else if (key.contains('river')) {
        waterRiver = _parseWaterPreset(json, waterRiver);
      } else if (key.contains('swamp')) {
        waterSwamp = _parseWaterPreset(json, waterSwamp);
      } else if (key.contains('ocean')) {
        waterOcean = _parseWaterPreset(json, waterOcean);
        parsedAnyOcean = true;
      } else if (key.contains('tropical') ||
          fileName == 'water/water.json' ||
          bareId.toLowerCase() == 'water') {
        waterTropical = _parseWaterPreset(json, waterTropical);
        parsedAnyTropical = true;
      }
    } catch (_) {}
  }

  if (parsedAnyTropical && !parsedAnyOcean) {
    // Base packs sharing water/water.json for tropical & ocean
    waterOcean = waterTropical.copyWith(
      identifier: waterOcean.identifier,
      fileName: waterOcean.fileName,
    );
  }

  final waterGlobal = WaterGlobalSettings(
    wavesEnabled: waterTropical.wavesEnabled,
    causticsEnabled: waterTropical.causticsEnabled,
    causticsFrameLength: waterTropical.causticsFrameLength,
    causticsPower: waterTropical.causticsPower,
    causticsScale: waterTropical.causticsScale,
  );

  cfg = cfg.copyWith(
    waterGlobal: waterGlobal,
    waterTropical: waterTropical,
    waterOcean: waterOcean,
    waterDeepOcean: waterDeepOcean,
    waterRiver: waterRiver,
    waterSwamp: waterSwamp,
  );

  // 6. Overworld Fog
  const preferredFogPaths = [
    'fogs/fog_overworld.json',
    'fogs/overworld_fog.json',
    'fogs/overworld.json',
    'fogs/default_fog.json',
  ];
  Map<String, dynamic>? overworldFogJson;
  for (final path in preferredFogPaths) {
    overworldFogJson = _decodeJsonObject(files[path]);
    if (overworldFogJson != null) break;
  }
  if (overworldFogJson == null) {
    final fallbackFog = files.entries.where((e) {
      final k = e.key.toLowerCase();
      return k.startsWith('fogs/') &&
          k.endsWith('.json') &&
          !k.contains('hell') &&
          !k.contains('nether') &&
          !k.contains('crimson') &&
          !k.contains('warped') &&
          !k.contains('soulsand') &&
          !k.contains('basalt') &&
          !k.contains('end') &&
          !k.contains('deep_dark');
    }).toList()
      ..sort((a, b) => a.key.compareTo(b.key));
    for (final entry in fallbackFog) {
      overworldFogJson = _decodeJsonObject(entry.value);
      if (overworldFogJson != null) break;
    }
  }
  if (overworldFogJson != null) {
    try {
      cfg = cfg.copyWith(fog: _parseFog(overworldFogJson, cfg.fog));
    } catch (_) {}
  }

  // 7. Performance hints
  if (hasLiteSubpack || hasMultipleTiers) {
    cfg = cfg.copyWith(
      performance: cfg.performance.copyWith(
        exportAllTiers: hasMultipleTiers ? true : cfg.performance.exportAllTiers,
        styleIntensityLite:
            hasLiteSubpack ? true : cfg.performance.styleIntensityLite,
      ),
    );
  }

  return VVPackImportResult(
    config: cfg,
    packIconBytes: iconBytes,
    importedPackName: importedPackName ?? fallbackName,
    wasNativeVVPack: true,
  );
}
