import 'dart:convert';
import 'package:archive/archive.dart';
import 'package:flutter/material.dart';

/// Immutable configuration passed to [ShaderPackCompiler] to compile a custom
/// Minecraft Bedrock Vibrant Visuals (Deferred PBR) `.mcpack` resource pack.
class ShaderBuildConfig {
  final String packName;

  // ── Atmosphere (Sky, Sun, Moon & Clouds) ──
  final Color morningColor;
  final Color noonColor;
  final Color eveningColor;
  final Color nightColor;
  final Color cloudTopColor;
  final Color cloudBottomColor;
  final double sunSize;
  final double sunSizeMorning;
  final double sunSizeEvening;
  final double moonSize;
  final double nightVision;
  final double fogDensity;
  final double morningFogDensity;
  final double eveningFogDensity;
  final double nightFogDensity;
  final double sunRayIntensity;
  final double morningRayIntensity;
  final double eveningRayIntensity;
  final double moonRayIntensity;
  final String cloudType;
  final String volumetricRays;

  // ── Lighting (Point Lights, Sun, Cave Ambient & Shadows) ──
  final Color torchLightColor;
  final Color sunlightColor;
  final Color soulLightColor;
  final Color caveAmbientColor;
  final Color rayMorningColor;
  final Color rayNoonColor;
  final Color rayEveningColor;
  final Color rayNightColor;
  final double lightIntensity;
  final double blockLightIntensity;
  final double soulLightIntensity;
  final double ambientBounce;
  final double caveAmbientBrightness;
  final double emissiveGlow;
  final double sunOrbitTilt;
  final String shadowQuality;
  final String volumetricFogProfile;
  final bool syncWarmBlocks;
  final bool syncMysticBlocks;

  // ── Water (Waves, Optics, Caustics & Biomes) ──
  final Color waterColor;
  final Color deepOceanColor;
  final Color swampWaterColor;
  final Color underwaterFogColor;
  final double windSpeed;
  final double waveAmplitude;
  final double waterTransparency;
  final double waterSpecularGlint;
  final double underwaterVisibility;
  final double shorelineFoam;
  final double swampTurbidity;
  final String waterQuality;
  final bool underwaterCaustics;
  final bool biomeWaterTint;

  // ── Weather (Rain, Thunder, Snow & Wetness) ──
  final Color rainFogColor;
  final Color thunderColor;
  final Color snowFogColor;
  final Color puddleColor;
  final double rainFogDensity;
  final double rainOvercast;
  final double lightningIntensity;
  final double thunderSkyDarkness;
  final double thunderFogDensity;
  final double snowFogDensity;
  final double frostShimmer;
  final double coldSkyTint;
  final double wetSurfaceGloss;
  final bool puddleReflections;

  // ── RTX PBR & Waving Foliage ──
  final bool enablePBR;
  final bool worldReflectionsEnabled;
  final double globalMetalness;
  final bool wavingFoliage;
  final double foliageWaveSpeed;

  // ── Post-FX & Color Grading ──
  final String toneMapFilter;
  final String biomeTone;
  final double globalSaturation;
  final double bloomIntensity;
  final double autoExposure;
  final double contrast;

  const ShaderBuildConfig({
    required this.packName,
    this.morningColor = const Color(0xFFFFA040),
    this.noonColor = const Color(0xFF5B7AFF),
    this.eveningColor = const Color(0xFFFF6020),
    this.nightColor = const Color(0xFF0A1C50),
    this.cloudTopColor = const Color(0xFFFFFFFF),
    this.cloudBottomColor = const Color(0xFFB0B4B8),
    this.sunSize = 1.0,
    this.sunSizeMorning = 1.1,
    this.sunSizeEvening = 1.25,
    this.moonSize = 1.0,
    this.nightVision = 1.0,
    this.fogDensity = 1.0,
    this.morningFogDensity = 1.0,
    this.eveningFogDensity = 1.1,
    this.nightFogDensity = 1.0,
    this.sunRayIntensity = 1.2,
    this.morningRayIntensity = 1.0,
    this.eveningRayIntensity = 1.2,
    this.moonRayIntensity = 1.0,
    this.cloudType = 'Realistic 3D',
    this.volumetricRays = 'Cinematic (Heavy)',
    this.torchLightColor = const Color(0xFFFF9933),
    this.sunlightColor = const Color(0xFFFFF7E6),
    this.soulLightColor = const Color(0xFF38BDF8),
    this.caveAmbientColor = const Color(0xFF1E2430),
    this.rayMorningColor = const Color(0xFFFFA040),
    this.rayNoonColor = const Color(0xFFFAFCFF),
    this.rayEveningColor = const Color(0xFFFF6020),
    this.rayNightColor = const Color(0xFF3050AA),
    this.lightIntensity = 1.0,
    this.blockLightIntensity = 1.0,
    this.soulLightIntensity = 1.0,
    this.ambientBounce = 1.0,
    this.caveAmbientBrightness = 1.0,
    this.emissiveGlow = 1.2,
    this.sunOrbitTilt = 42.0,
    this.shadowQuality = 'High',
    this.volumetricFogProfile = 'Cinematic',
    this.syncWarmBlocks = true,
    this.syncMysticBlocks = true,
    this.waterColor = const Color(0xFF00E5FF),
    this.deepOceanColor = const Color(0xFF004488),
    this.swampWaterColor = const Color(0xFF2E4832),
    this.underwaterFogColor = const Color(0xFF0A3048),
    this.windSpeed = 1.0,
    this.waveAmplitude = 1.0,
    this.waterTransparency = 0.85,
    this.waterSpecularGlint = 1.0,
    this.underwaterVisibility = 1.2,
    this.shorelineFoam = 1.0,
    this.swampTurbidity = 1.0,
    this.waterQuality = 'Ultra',
    this.underwaterCaustics = true,
    this.biomeWaterTint = true,
    this.rainFogColor = const Color(0xFF5A636A),
    this.thunderColor = const Color(0xFF263238),
    this.snowFogColor = const Color(0xFFCBD5E1),
    this.puddleColor = const Color(0xFF2E3D48),
    this.rainFogDensity = 1.2,
    this.rainOvercast = 1.0,
    this.lightningIntensity = 1.5,
    this.thunderSkyDarkness = 1.2,
    this.thunderFogDensity = 1.4,
    this.snowFogDensity = 1.1,
    this.frostShimmer = 1.0,
    this.coldSkyTint = 1.0,
    this.wetSurfaceGloss = 1.2,
    this.puddleReflections = true,
    this.enablePBR = true,
    this.worldReflectionsEnabled = true,
    this.globalMetalness = 0.0,
    this.wavingFoliage = true,
    this.foliageWaveSpeed = 1.0,
    this.toneMapFilter = 'ACES (Cinematic)',
    this.biomeTone = 'Dynamic',
    this.globalSaturation = 1.0,
    this.bloomIntensity = 1.0,
    this.autoExposure = 1.0,
    this.contrast = 1.0,
  });
}

/// Pure-Dart compiler that applies [ShaderBuildConfig] parameters to a base
/// Vibrant Visuals `.mcpack` [Archive], keeping Nether & End dimensions intact
/// and writing schema-valid Bedrock 1.21.80+ Deferred PBR JSON definitions.
class ShaderPackCompiler {
  ShaderPackCompiler._();

  static const _nonOverworldTokens = <String>[
    'hell',
    'crimson',
    'warped',
    'deltas',
    'basalt',
    'soul',
    'soulsand',
    'the_end',
    'end_lighting',
    'end_atmosphere',
  ];

  /// Returns `true` when [path] represents an Overworld or global config
  /// file, preserving Nether (`hell`, `crimson`, `warped`, `basalt_deltas`,
  /// `soulsand_valley`) and End (`end`, `the_end`) dimension configs.
  static bool isOverworldAssetPath(String path) {
    final lower = path.toLowerCase();
    for (final token in _nonOverworldTokens) {
      if (lower.contains(token)) return false;
    }
    if (lower == 'fogs/end.json' || lower.endsWith('/end.json')) return false;
    return true;
  }

  /// Returns `true` when [path] belongs to snow, ice, or cold alpine fogs.
  static bool isColdWeatherFogPath(String path) {
    final lower = path.toLowerCase();
    return lower.contains('snow') ||
        lower.contains('ice') ||
        lower.contains('cold') ||
        lower.contains('taiga');
  }

  /// Returns `true` when [path] belongs to swamp or marsh biome/water configs.
  static bool isSwampPath(String path) {
    final lower = path.toLowerCase();
    return lower.contains('swamp') ||
        lower.contains('mangrove') ||
        lower.endsWith('water_two.json');
  }

  /// Returns `true` when [path] belongs to a snow/ice/frozen biome.
  static bool isColdBiomePath(String path) {
    final lower = path.toLowerCase();
    return lower.contains('snow') ||
        lower.contains('ice') ||
        lower.contains('frozen') ||
        lower.contains('peaks') ||
        lower.contains('grove') ||
        lower.contains('cold');
  }

  /// Strips JSONC `/* ... */` comments, `// ...` comments, and trailing commas.
  static String cleanJsonComments(String raw) {
    var s = raw.replaceAll(RegExp(r'/\*.*?\*/', dotAll: true), '');
    s = s.replaceAll(RegExp(r'(?<!:)//[^\n]*'), '');
    s = s.replaceAll(RegExp(r',\s*([}\]])'), r'$1');
    return s;
  }

  static int _r(Color c) => (c.toARGB32() >> 16) & 0xFF;
  static int _g(Color c) => (c.toARGB32() >> 8) & 0xFF;
  static int _b(Color c) => c.toARGB32() & 0xFF;

  static List<int> _rgb(Color c) => <int>[_r(c), _g(c), _b(c)];

  static String _hex(Color c) =>
      '#${(c.toARGB32() & 0xFFFFFF).toRadixString(16).padLeft(6, '0')}';

  static Color _scaleColor(Color c, double factor) {
    return Color.fromARGB(
      255,
      (_r(c) * factor).round().clamp(0, 255),
      (_g(c) * factor).round().clamp(0, 255),
      (_b(c) * factor).round().clamp(0, 255),
    );
  }

  /// Compiles a fresh [Archive] from [baseArchive] using all parameters in [cfg].
  static Archive compileArchive(
    Archive baseArchive,
    ShaderBuildConfig cfg, {
    required List<int> packIconBytes,
    required String packUuid,
    required String moduleUuid,
    void Function(double progress, String status)? onProgress,
  }) {
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
        ];
        if (!standardDirs.any((d) => candidate.startsWith(d)) &&
            nonDirFiles.every(
              (f) => f.name.replaceAll('\\', '/').startsWith(candidate),
            )) {
          prefix = candidate;
        }
      }
    }

    final fileMap = <String, ArchiveFile>{};
    for (final file in baseArchive) {
      if (!file.isFile) continue;
      var name = file.name.replaceAll('\\', '/');
      if (prefix.isNotEmpty && name.startsWith(prefix)) {
        name = name.substring(prefix.length);
      }
      if (name.endsWith('.material.bin') || name.startsWith('renderer/')) {
        continue;
      }
      fileMap[name] = ArchiveFile(name, file.size, file.content);
    }

    onProgress?.call(0.18, 'Baking Torch & Point Light Colors...');
    _writePointLights(fileMap, cfg);

    onProgress?.call(0.32, 'Sculpting Water Waves, Caustics & Biomes...');
    _writeWaterAndBiomes(fileMap, cfg);

    onProgress?.call(0.48, 'Compiling Overworld Fog, Clouds & Weather...');
    _writeFogsAndWeather(fileMap, cfg);

    onProgress?.call(0.60, 'Grading Tone Mapping, White Balance & Bloom...');
    _writeColorGrading(fileMap, cfg);

    onProgress?.call(0.74, 'Configuring Sun, Shadows & Sky Atmospherics...');
    _writeDirectionalLighting(fileMap, cfg);
    _writeAtmospherics(fileMap, cfg);
    _writeShadowsAndPbr(fileMap, cfg);
    _writeFoliageParticles(fileMap, cfg);

    onProgress?.call(0.88, 'Bundling Textures & Pack Manifest...');
    _writePackAssetsAndManifest(
      fileMap,
      cfg,
      packIconBytes: packIconBytes,
      packUuid: packUuid,
      moduleUuid: moduleUuid,
    );

    final outArchive = Archive();
    for (final file in fileMap.values) {
      outArchive.addFile(file);
    }
    return outArchive;
  }

  static void _putJson(
    Map<String, ArchiveFile> fileMap,
    String key,
    Object data,
  ) {
    final bytes = utf8.encode(jsonEncode(data));
    fileMap[key] = ArchiveFile(key, bytes.length, bytes);
  }

  static Map<String, dynamic>? _readJsonMap(
    Map<String, ArchiveFile> fileMap,
    String key,
  ) {
    final file = fileMap[key];
    if (file == null) return null;
    try {
      final raw = cleanJsonComments(utf8.decode(file.content as List<int>));
      final decoded = jsonDecode(raw);
      return decoded is Map<String, dynamic> ? decoded : null;
    } catch (_) {
      return null;
    }
  }

  static void _writePointLights(
    Map<String, ArchiveFile> fileMap,
    ShaderBuildConfig cfg,
  ) {
    final torchHex = _hex(
      _scaleColor(cfg.torchLightColor, cfg.blockLightIntensity),
    );
    final soulHex = _hex(
      _scaleColor(cfg.soulLightColor, cfg.soulLightIntensity),
    );

    final pointColors = <String, String>{
      'minecraft:torch': torchHex,
      'minecraft:lantern': torchHex,
      'minecraft:copper_bulb': torchHex,
      'minecraft:lit_furnace': torchHex,
      'minecraft:lit_redstone_lamp': torchHex,
      'minecraft:glowstone': torchHex,
      'minecraft:light_block': torchHex,
      'minecraft:campfire': torchHex,
      'minecraft:shroomlight': torchHex,
      'minecraft:jack_o_lantern': torchHex,
      'minecraft:lava_cauldron': torchHex,
      'minecraft:ochre_froglight': torchHex,
      'minecraft:soul_torch': soulHex,
      'minecraft:soul_lantern': soulHex,
      'minecraft:soul_campfire': soulHex,
      'minecraft:soul_fire': soulHex,
      'minecraft:crying_obsidian': soulHex,
      'minecraft:respawn_anchor': soulHex,
      'minecraft:sculk_catalyst': soulHex,
      'minecraft:beacon': soulHex,
      'minecraft:end_rod': soulHex,
    };

    if (cfg.syncWarmBlocks) {
      pointColors['minecraft:redstone_torch'] = torchHex;
      pointColors['minecraft:magma'] = torchHex;
      pointColors['minecraft:lit_redstone_ore'] = torchHex;
    }
    if (cfg.syncMysticBlocks) {
      pointColors['minecraft:sea_lantern'] = soulHex;
      pointColors['minecraft:pearlescent_froglight'] = soulHex;
      pointColors['minecraft:verdant_froglight'] = soulHex;
    }

    _putJson(fileMap, 'local_lighting/local_lighting.json', {
      'format_version': '1.21.60',
      'minecraft:local_light_settings': {
        'description': {'identifier': 'pog:local_lighting'},
        'colors': pointColors,
      },
    });

    _putJson(fileMap, 'point_lights/global.json', {
      'format_version': '1.21.40',
      'minecraft:point_light_settings': {'colors': pointColors},
    });
  }

  static void _writeWaterAndBiomes(
    Map<String, ArchiveFile> fileMap,
    ShaderBuildConfig cfg,
  ) {
    final baseClarity = cfg.waterQuality == 'Ultra'
        ? 0.85
        : (cfg.waterQuality == 'High'
              ? 0.70
              : (cfg.waterQuality == 'Medium' ? 0.55 : 0.40));
    final computedTransparency = (baseClarity * (cfg.waterTransparency / 0.85))
        .clamp(0.15, 0.98);
    final waterSpeed = (cfg.windSpeed * 2.38).clamp(0.2, 8.0);
    final waterFreq = (cfg.windSpeed * 1.33).clamp(0.2, 4.0);
    final waterOctaves = cfg.waterQuality == 'Ultra'
        ? 24
        : (cfg.waterQuality == 'High'
              ? 18
              : (cfg.waterQuality == 'Medium' ? 12 : 8));
    final causticPower = (1.35 * cfg.waterSpecularGlint).clamp(0.3, 4.5);
    final causticScale = (0.13 / cfg.waterSpecularGlint.clamp(0.5, 2.0)).clamp(
      0.05,
      0.45,
    );

    for (final key in fileMap.keys.toList()) {
      if (!key.startsWith('water/') || !key.endsWith('.json')) continue;
      final wData = _readJsonMap(fileMap, key);
      final wSettings =
          wData?['minecraft:water_settings'] as Map<String, dynamic>?;
      if (wData == null || wSettings == null) continue;

      final isSwamp = isSwampPath(key);
      final waves =
          (wSettings['waves'] as Map<String, dynamic>?) ?? <String, dynamic>{};
      wSettings['waves'] = waves;
      waves['enabled'] = true;
      waves['speed'] = isSwamp ? waterSpeed * 0.45 : waterSpeed;
      waves['frequency'] = waterFreq;
      waves['octaves'] = waterOctaves;
      final baseDepth = isSwamp ? 0.045 : 0.074;
      waves['depth'] = (baseDepth * cfg.waveAmplitude).clamp(0.01, 0.45);
      waves['pull'] = (0.35 * cfg.waveAmplitude).clamp(0.08, 0.85);
      waves['mix'] = (0.31 * cfg.shorelineFoam).clamp(0.05, 0.95);
      waves['shape'] = (3.39 * (0.7 + 0.3 * cfg.shorelineFoam)).clamp(1.0, 6.0);

      final caustics =
          (wSettings['caustics'] as Map<String, dynamic>?) ??
          <String, dynamic>{};
      wSettings['caustics'] = caustics;
      caustics['enabled'] = cfg.underwaterCaustics;
      caustics['texture'] = 'textures/causticsLow/caustics.png';
      caustics['power'] = causticPower;
      caustics['scale'] = causticScale;

      if (wSettings['particle_concentrations'] is Map<String, dynamic>) {
        final p = wSettings['particle_concentrations'] as Map<String, dynamic>;
        if (isSwamp) {
          p['chlorophyll'] = (1.25 * cfg.swampTurbidity).clamp(0.01, 6.0);
          p['suspended_sediment'] = (7.5 * cfg.swampTurbidity).clamp(0.5, 22.0);
          p['cdom'] = (6.8 * cfg.swampTurbidity).clamp(0.4, 18.0);
        } else {
          p['chlorophyll'] = ((1.0 - computedTransparency) * 0.045).clamp(
            0.0005,
            0.12,
          );
          p['suspended_sediment'] =
              (0.65 * cfg.shorelineFoam * (1.2 - computedTransparency * 0.5))
                  .clamp(0.05, 4.0);
          p['cdom'] =
              ((1.0 - computedTransparency) * 3.8 +
                      cfg.waterSpecularGlint * 0.2)
                  .clamp(0.2, 8.0);
        }
      }
      _putJson(fileMap, key, wData);
    }

    // Overworld biome water & cold sky tinting (preserve Hell & End dimensions)
    final oceanMidColor =
        Color.lerp(cfg.waterColor, cfg.deepOceanColor, 0.40) ?? cfg.waterColor;
    final frostSkyColor =
        Color.lerp(
          cfg.noonColor,
          cfg.snowFogColor,
          (cfg.coldSkyTint * 0.28).clamp(0.0, 0.55),
        ) ??
        cfg.noonColor;
    final noonSkyHex = _hex(cfg.noonColor);
    final frostSkyHex = _hex(frostSkyColor);

    for (final key in fileMap.keys.toList()) {
      if (!key.startsWith('biomes/') ||
          !key.endsWith('.client_biome.json') ||
          !isOverworldAssetPath(key)) {
        continue;
      }
      final bData = _readJsonMap(fileMap, key);
      final bSettings =
          (bData?['minecraft:client_biome'] ?? bData) as Map<String, dynamic>?;
      if (bData == null || bSettings == null) continue;

      final lower = key.toLowerCase();
      Color targetWater = cfg.waterColor;
      if (cfg.biomeWaterTint) {
        if (isSwampPath(lower)) {
          targetWater = cfg.swampWaterColor;
        } else if (lower.contains('deep_') && lower.contains('ocean')) {
          targetWater = cfg.deepOceanColor;
        } else if (lower.contains('ocean')) {
          targetWater = oceanMidColor;
        }
      }

      final targetWaterHex = _hex(targetWater);
      bSettings['water_surface_color'] = _rgb(targetWater);
      bSettings['water_surface_transparency'] = computedTransparency;

      if (bSettings['components'] is Map<String, dynamic>) {
        final comps = bSettings['components'] as Map<String, dynamic>;
        if (comps['minecraft:water_appearance'] is Map<String, dynamic>) {
          final wa =
              comps['minecraft:water_appearance'] as Map<String, dynamic>;
          wa['surface_color'] = targetWaterHex;
          wa['surface_transparency'] = computedTransparency;
        }
        if (comps['minecraft:sky_color'] is Map<String, dynamic>) {
          comps['minecraft:sky_color']['sky_color'] = isColdBiomePath(lower)
              ? frostSkyHex
              : noonSkyHex;
        }
      }
      _putJson(fileMap, key, bData);
    }
  }

  static void _writeFogsAndWeather(
    Map<String, ArchiveFile> fileMap,
    ShaderBuildConfig cfg,
  ) {
    final baseAirColor =
        Color.lerp(cfg.noonColor, const Color(0xFFDCEEFF), 0.58) ??
        cfg.noonColor;
    final uwFogHex = _hex(cfg.underwaterFogColor);
    final uwFogEnd = (45.0 * cfg.underwaterVisibility).clamp(12.0, 120.0);
    final uwVolDensity = ((2.1 - cfg.underwaterVisibility) * 0.015).clamp(
      0.002,
      0.08,
    );

    final baseVolumetric = cfg.volumetricFogProfile == 'Cinematic'
        ? 0.065
        : (cfg.volumetricFogProfile == 'Balanced' ? 0.035 : 0.012);

    // Derive cloud scattering & absorption directly from cloud colors & overcast
    final cloudScale = cfg.cloudType == 'Realistic 3D'
        ? 0.075
        : (cfg.cloudType == 'Volumetric' ? 0.052 : 0.004);
    final cloudScattering = <double>[
      ((_r(cfg.cloudTopColor) / 255.0) * cloudScale + 0.002).clamp(
        0.0005,
        0.18,
      ),
      ((_g(cfg.cloudTopColor) / 255.0) * cloudScale + 0.002).clamp(
        0.0005,
        0.18,
      ),
      ((_b(cfg.cloudTopColor) / 255.0) * cloudScale + 0.002).clamp(
        0.0005,
        0.18,
      ),
    ];
    final shadowLum =
        (0.299 * _r(cfg.cloudBottomColor) +
            0.587 * _g(cfg.cloudBottomColor) +
            0.114 * _b(cfg.cloudBottomColor)) /
        255.0;
    final baseAbs = cfg.cloudType == 'Flat 2D' ? 0.25 : 1.05;
    final absFactor =
        (baseAbs * (0.65 + 0.45 * cfg.rainOvercast) * (1.28 - shadowLum * 0.45))
            .clamp(0.10, 3.20);

    final stormMixColor =
        Color.lerp(
          cfg.rainFogColor,
          cfg.thunderColor,
          ((cfg.thunderSkyDarkness - 0.5) * 0.45).clamp(0.0, 0.70),
        ) ??
        cfg.rainFogColor;
    final stormFogColor =
        Color.lerp(stormMixColor, cfg.puddleColor, 0.15) ?? stormMixColor;
    final stormFogHex = _hex(stormFogColor);
    final effWeatherDensity =
        (cfg.rainFogDensity * 0.65 + cfg.thunderFogDensity * 0.35).clamp(
          0.2,
          2.0,
        );

    for (final key in fileMap.keys.toList()) {
      if (!key.startsWith('fogs/') ||
          !key.endsWith('.json') ||
          !isOverworldAssetPath(key)) {
        continue;
      }
      final fData = _readJsonMap(fileMap, key);
      final fSettings =
          fData?['minecraft:fog_settings'] as Map<String, dynamic>?;
      if (fData == null || fSettings == null) continue;

      final isColdFog = isColdWeatherFogPath(key);
      final isDeepDark = key.toLowerCase().contains('deep_dark');

      if (fSettings['distance'] is Map<String, dynamic>) {
        final dist = fSettings['distance'] as Map<String, dynamic>;

        if (dist['air'] is Map<String, dynamic> && !isDeepDark) {
          final air = dist['air'] as Map<String, dynamic>;
          final effectiveAir = isColdFog
              ? (Color.lerp(
                      baseAirColor,
                      cfg.snowFogColor,
                      (0.35 + 0.30 * (cfg.coldSkyTint - 0.5)).clamp(0.15, 0.85),
                    ) ??
                    cfg.snowFogColor)
              : baseAirColor;
          final airDensity = isColdFog
              ? (cfg.fogDensity * 0.7 + cfg.snowFogDensity * 0.3)
              : cfg.fogDensity;
          air['fog_color'] = _hex(effectiveAir);
          air['fog_start'] = (0.92 - (airDensity * 0.40)).clamp(0.05, 0.95);
          air['fog_end'] = (1.00 - (airDensity * 0.20)).clamp(0.30, 1.00);
        }

        if (dist['water'] is Map<String, dynamic>) {
          final water = dist['water'] as Map<String, dynamic>;
          water['fog_color'] = uwFogHex;
          water['fog_end'] = uwFogEnd;
          if (water['transition_fog'] is Map<String, dynamic>) {
            final tf = water['transition_fog'] as Map<String, dynamic>;
            if (tf['init_fog'] is Map<String, dynamic>) {
              tf['init_fog']['fog_color'] = uwFogHex;
            }
          }
        }

        if (dist['weather'] is Map<String, dynamic>) {
          final weather = dist['weather'] as Map<String, dynamic>;
          if (isColdFog) {
            final snowStormColor =
                Color.lerp(
                  cfg.snowFogColor,
                  stormFogColor,
                  (0.25 + (cfg.thunderSkyDarkness - 0.8) * 0.25).clamp(
                    0.1,
                    0.65,
                  ),
                ) ??
                cfg.snowFogColor;
            weather['fog_color'] = _hex(snowStormColor);
            weather['fog_start'] = (0.92 - (cfg.snowFogDensity * 0.40)).clamp(
              0.08,
              0.96,
            );
            weather['fog_end'] = (1.00 - (cfg.snowFogDensity * 0.16)).clamp(
              0.38,
              1.00,
            );
          } else {
            weather['fog_color'] = stormFogHex;
            weather['fog_start'] = (0.94 - (effWeatherDensity * 0.38)).clamp(
              0.08,
              0.97,
            );
            weather['fog_end'] = (1.00 - (effWeatherDensity * 0.14)).clamp(
              0.40,
              1.00,
            );
          }
        }
      }

      if (fSettings['volumetric'] is Map<String, dynamic>) {
        final vol = fSettings['volumetric'] as Map<String, dynamic>;
        if (vol['density'] is Map<String, dynamic>) {
          final dens = vol['density'] as Map<String, dynamic>;
          if (dens['air'] is Map<String, dynamic> && !isDeepDark) {
            dens['air']['max_density'] = (baseVolumetric * cfg.fogDensity)
                .clamp(0.002, 0.25);
          }
          if (dens['water'] is Map<String, dynamic>) {
            dens['water']['max_density'] = uwVolDensity;
          }
          if (dens['weather'] is Map<String, dynamic>) {
            final d = isColdFog ? cfg.snowFogDensity : effWeatherDensity;
            dens['weather']['max_density'] = (0.30 * d).clamp(0.05, 0.95);
          }
        }
        if (vol['media_coefficients'] is Map<String, dynamic>) {
          final mc = vol['media_coefficients'] as Map<String, dynamic>;
          if (mc['cloud'] is Map<String, dynamic>) {
            mc['cloud']['scattering'] = cloudScattering;
            mc['cloud']['absorption'] = [absFactor, absFactor, absFactor];
          }
        }
      }

      _putJson(fileMap, key, fData);
    }
  }

  static void _writeColorGrading(
    Map<String, ArchiveFile> fileMap,
    ShaderBuildConfig cfg,
  ) {
    final filterLower = cfg.toneMapFilter.toLowerCase();
    final op = filterLower.contains('reinhard')
        ? 'reinhard'
        : (filterLower.contains('warm') ? 'hable' : 'aces');

    final baseTemp = cfg.biomeTone == 'Savanna'
        ? 5500.0
        : (cfg.biomeTone == 'Frost'
              ? 7800.0
              : (cfg.biomeTone == 'Vibrant'
                    ? 6200.0
                    : (cfg.biomeTone == 'Moody' ? 6000.0 : 6500.0)));
    final filterTempShift = filterLower.contains('warm')
        ? -650.0
        : (filterLower.contains('cool') ? 750.0 : 0.0);
    final targetTemp = (baseTemp + filterTempShift).clamp(3500.0, 10000.0);

    final satMult = cfg.biomeTone == 'Vibrant'
        ? 1.25
        : (cfg.biomeTone == 'Moody' ? 0.75 : 1.0);
    final effSat = (cfg.globalSaturation * satMult).clamp(0.1, 2.5);
    final effContrast = cfg.contrast.clamp(0.5, 2.0);
    final effGain = (1.05 * cfg.autoExposure).clamp(0.4, 2.5);
    final hiGain = (effGain * (0.82 + 0.30 * cfg.bloomIntensity)).clamp(
      0.5,
      3.0,
    );
    final hiContrast = (effContrast * (0.90 + 0.14 * cfg.bloomIntensity)).clamp(
      0.5,
      2.2,
    );
    final shadowGain =
        (effGain *
                (cfg.nightVision > 1.0 ? 0.85 + cfg.nightVision * 0.18 : 1.0))
            .clamp(0.5, 2.5);

    for (final cgKey in [
      'color_grading/color_grading.json',
      'color_grading/pale_color_grading.json',
    ]) {
      final cgData = _readJsonMap(fileMap, cgKey);
      final cgSettings =
          cgData?['minecraft:color_grading_settings'] as Map<String, dynamic>?;
      if (cgData == null || cgSettings == null) continue;

      cgSettings['description'] = {'identifier': 'pog:color_grading'};
      cgSettings['tone_mapping'] = {'operator': op};
      cgSettings['temperature'] = {
        'enabled': true,
        'type': 'white_balance',
        'temperature': targetTemp,
      };
      if (cgSettings['color_grading'] is Map<String, dynamic>) {
        final cg = cgSettings['color_grading'] as Map<String, dynamic>;
        if (cg['midtones'] is Map<String, dynamic>) {
          final m = cg['midtones'] as Map<String, dynamic>;
          m['contrast'] = [effContrast, effContrast, effContrast];
          m['saturation'] = [effSat, effSat, effSat];
          m['gain'] = [effGain, effGain, effGain];
        }
        if (cg['highlights'] is Map<String, dynamic>) {
          final h = cg['highlights'] as Map<String, dynamic>;
          h['enabled'] = true;
          h['contrast'] = [hiContrast, hiContrast, hiContrast];
          h['saturation'] = [effSat, effSat, effSat];
          h['gain'] = [hiGain, hiGain, hiGain];
        }
        if (cg['shadows'] is Map<String, dynamic>) {
          final s = cg['shadows'] as Map<String, dynamic>;
          s['contrast'] = [effContrast, effContrast, effContrast];
          s['saturation'] = [effSat, effSat, effSat];
          s['gain'] = [shadowGain, shadowGain, shadowGain];
        }
      }
      _putJson(fileMap, cgKey, cgData);
    }
  }

  static void _writeDirectionalLighting(
    Map<String, ArchiveFile> fileMap,
    ShaderBuildConfig cfg,
  ) {
    final sunIllumScale =
        (181.0 * cfg.lightIntensity * (0.80 + 0.20 * cfg.bloomIntensity)).clamp(
          10.0,
          380.0,
        );
    final moonIllumScale = (2.1 * cfg.nightVision * cfg.moonRayIntensity).clamp(
      0.1,
      15.0,
    );
    final noonSunRgb = _rgb(
      Color.lerp(cfg.sunlightColor, cfg.rayNoonColor, 0.35) ??
          cfg.sunlightColor,
    );
    final tiltLow = (cfg.sunOrbitTilt * 0.72).clamp(10.0, 65.0);
    final emissiveDesat = (0.36 - (cfg.emissiveGlow - 0.5) * 0.16).clamp(
      0.02,
      0.72,
    );
    final ambientIllum = (0.07 * cfg.caveAmbientBrightness).clamp(0.015, 0.45);
    final skyIntensity = (0.3 * cfg.ambientBounce).clamp(0.05, 1.5);
    final flashIllum = (14.0 * cfg.lightningIntensity).clamp(0.0, 45.0);

    for (final key in fileMap.keys.toList()) {
      if (!key.startsWith('lighting/') ||
          !key.endsWith('.json') ||
          !isOverworldAssetPath(key)) {
        continue;
      }
      final lData = _readJsonMap(fileMap, key);
      final lSettings =
          lData?['minecraft:lighting_settings'] as Map<String, dynamic>?;
      if (lData == null ||
          lSettings == null ||
          lSettings['directional_lights'] == null) {
        continue;
      }

      final dl = lSettings['directional_lights'] as Map<String, dynamic>;
      final orbital =
          (dl['orbital'] as Map<String, dynamic>?) ?? <String, dynamic>{};
      dl['orbital'] = orbital;

      orbital['sun'] = {
        'illuminance': {
          '0.000000': sunIllumScale,
          '0.160000': sunIllumScale * 0.78,
          '0.215000': sunIllumScale * 0.58 * cfg.eveningRayIntensity,
          '0.240000': sunIllumScale * 0.17 * cfg.eveningRayIntensity,
          '0.300000': 8,
          '0.350000': 0,
          '0.680000': 0,
          '0.740000': sunIllumScale * 0.1 * cfg.morningRayIntensity,
          '0.750000': sunIllumScale * 0.17 * cfg.morningRayIntensity,
          '0.770000': sunIllumScale * 0.67 * cfg.morningRayIntensity,
          '0.827000': sunIllumScale * 1.18,
        },
        'color': {
          '0.000000': noonSunRgb,
          '0.160000': noonSunRgb,
          '0.215000': _rgb(cfg.rayEveningColor),
          '0.230000': _rgb(cfg.rayEveningColor),
          '0.300000': [40, 15, 5],
          '0.670000': [0, 0, 0],
          '0.680000': [0, 0, 0],
          '0.690000': [0, 0, 0],
          '0.740000': _rgb(cfg.rayMorningColor),
          '0.750000': _rgb(cfg.rayMorningColor),
          '0.770000': _rgb(cfg.rayMorningColor),
          '0.790000': _rgb(cfg.rayMorningColor),
          '0.800000': noonSunRgb,
        },
      };

      orbital['moon'] = {
        'illuminance': {
          '0.000000': moonIllumScale,
          '0.730000': moonIllumScale,
          '0.740000': 0.0,
          '1.000000': moonIllumScale * 0.5,
        },
        'color': {
          '0.000000': _rgb(cfg.rayNightColor),
          '0.300000': _rgb(cfg.rayNightColor),
          '0.500000': _rgb(cfg.rayNightColor),
        },
      };

      orbital['orbital_offset_degrees'] = {
        '0.000000': cfg.sunOrbitTilt,
        '0.215000': tiltLow,
        '0.500000': cfg.sunOrbitTilt,
        '0.827000': tiltLow,
      };

      dl['flash'] = {
        'illuminance': flashIllum,
        'color': _rgb(cfg.thunderColor),
      };

      lSettings['emissive'] = {'desaturation': emissiveDesat};
      lSettings['ambient'] = {
        'illuminance': ambientIllum,
        'color': _rgb(cfg.caveAmbientColor),
      };
      lSettings['sky'] = {'intensity': skyIntensity};

      _putJson(fileMap, key, lData);
    }
  }

  static void _writeAtmospherics(
    Map<String, ArchiveFile> fileMap,
    ShaderBuildConfig cfg,
  ) {
    final rayMultiplier = cfg.volumetricRays == 'Off'
        ? 0.0
        : ((cfg.volumetricRays.contains('Heavy') ||
                  cfg.volumetricRays.contains('Cinematic'))
              ? 1.5
              : (cfg.volumetricRays.contains('Balanced') ? 1.0 : 0.6));

    final mieMorning = (4.0 * cfg.morningRayIntensity * rayMultiplier).clamp(
      0.0,
      16.0,
    );
    final mieNoon = (4.0 * cfg.sunRayIntensity * rayMultiplier).clamp(
      0.0,
      16.0,
    );
    final mieEvening = (4.0 * cfg.eveningRayIntensity * rayMultiplier).clamp(
      0.0,
      16.0,
    );
    final mieMoon =
        (1.5 * cfg.moonRayIntensity * rayMultiplier * cfg.nightVision).clamp(
          0.0,
          10.0,
        );

    final noonHorizon =
        Color.lerp(cfg.noonColor, const Color(0xFFD8F0FF), 0.35) ??
        cfg.noonColor;
    final eveningHorizon =
        Color.lerp(cfg.eveningColor, const Color(0xFFFFB27A), 0.25) ??
        cfg.eveningColor;
    final nightHorizon =
        Color.lerp(cfg.nightColor, const Color(0xFF344B87), 0.22) ??
        cfg.nightColor;
    final morningHorizon =
        Color.lerp(cfg.morningColor, const Color(0xFFFFE0C2), 0.28) ??
        cfg.morningColor;

    for (final key in fileMap.keys.toList()) {
      if (!key.startsWith('atmospherics/') ||
          !key.endsWith('.json') ||
          !isOverworldAssetPath(key)) {
        continue;
      }
      final aData = _readJsonMap(fileMap, key);
      final aSettings =
          aData?['minecraft:atmosphere_settings'] as Map<String, dynamic>?;
      if (aData == null || aSettings == null) continue;

      aSettings['sky_zenith_color'] = {
        '0.000000': _rgb(cfg.noonColor),
        '0.160000': _rgb(cfg.noonColor),
        '0.215000': _rgb(cfg.eveningColor),
        '0.225000': _rgb(cfg.eveningColor),
        '0.300000': _rgb(cfg.nightColor),
        '0.500000': _rgb(cfg.nightColor),
        '0.694000': _rgb(cfg.nightColor),
        '0.740000': _rgb(cfg.morningColor),
        '0.770000': _rgb(cfg.morningColor),
        '0.827000': _rgb(cfg.noonColor),
      };

      aSettings['sky_horizon_color'] = {
        '0.000000': _rgb(noonHorizon),
        '0.160000': _rgb(noonHorizon),
        '0.215000': _rgb(eveningHorizon),
        '0.225000': _rgb(eveningHorizon),
        '0.300000': _rgb(nightHorizon),
        '0.500000': _rgb(nightHorizon),
        '0.694000': _rgb(nightHorizon),
        '0.740000': _rgb(morningHorizon),
        '0.770000': _rgb(morningHorizon),
        '0.827000': _rgb(noonHorizon),
      };

      aSettings['sun_glare_shape'] = {
        '0.000000': (5.0 * cfg.sunSize).clamp(0.5, 20.0),
        '0.215000': (0.07 * cfg.sunSizeEvening).clamp(0.01, 2.0),
        '0.300000': (0.17 * cfg.sunSizeEvening).clamp(0.02, 3.0),
        '0.500000': (5.0 * cfg.sunSize).clamp(0.5, 20.0),
        '0.640000': (3.0 * cfg.sunSize).clamp(0.3, 12.0),
        '0.740000': (0.07 * cfg.sunSizeMorning).clamp(0.01, 2.0),
        '0.790000': (0.07 * cfg.sunSizeMorning).clamp(0.01, 2.0),
        '0.800000': (4.15 * cfg.sunSize).clamp(0.4, 18.0),
      };

      aSettings['moon_glare_shape'] = {
        '0.000000': 0.0,
        '0.250000': (0.15 * cfg.moonSize).clamp(0.01, 2.0),
        '0.300000': (1.8 * cfg.moonSize).clamp(0.1, 10.0),
        '0.500000': (2.4 * cfg.moonSize).clamp(0.2, 12.0),
        '0.690000': (1.8 * cfg.moonSize).clamp(0.1, 10.0),
        '0.730000': 0.0,
      };

      aSettings['rayleigh_strength'] = {
        '0.000000': (2.2 * cfg.fogDensity).clamp(0.4, 6.0),
        '0.215000': (1.1 * cfg.eveningFogDensity).clamp(0.2, 4.0),
        '0.300000': (0.45 * cfg.nightFogDensity).clamp(0.1, 2.0),
        '0.694200': (0.45 * cfg.nightFogDensity).clamp(0.1, 2.0),
        '0.740000': (0.8 * cfg.morningFogDensity).clamp(0.1, 3.0),
        '0.770000': (0.8 * cfg.morningFogDensity).clamp(0.1, 3.0),
        '0.800000': (2.86 * cfg.fogDensity).clamp(0.5, 8.0),
      };

      aSettings['sun_mie_strength'] = {
        '0.000000': mieNoon,
        '0.215000': mieEvening * 0.75,
        '0.235000': mieEvening * 0.25,
        '0.295000': mieEvening * 1.25,
        '0.300000': mieEvening * 0.25,
        '0.400000': 0.0,
        '0.500000': 0.0,
        '0.740000': mieMorning * 0.2,
        '0.780000': mieMorning * 0.2,
        '0.790000': mieMorning * 0.2,
        '0.800000': mieMorning * 0.5,
        '1.000000': mieMorning * 0.5,
      };

      aSettings['moon_mie_strength'] = {
        '0.000000': 0.0,
        '0.250000': mieMoon * 0.4,
        '0.300000': mieMoon,
        '0.350000': mieMoon,
        '0.500000': 0.0,
        '0.730000': 0.0,
        '0.800000': 0.0,
        '1.000000': 0.0,
      };

      _putJson(fileMap, key, aData);
    }
  }

  static void _writeShadowsAndPbr(
    Map<String, ArchiveFile> fileMap,
    ShaderBuildConfig cfg,
  ) {
    final isOff = cfg.shadowQuality == 'Off';
    final texel = isOff
        ? 16
        : (cfg.shadowQuality == 'Ultra'
              ? 2048
              : (cfg.shadowQuality == 'High' ? 1024 : 512));

    _putJson(fileMap, 'shadows/global.json', {
      'format_version': '1.21.80',
      'minecraft:shadow_settings': {
        'shadow_style': isOff ? 'blocky_shadows' : 'soft_shadows',
        'texel_size': texel,
      },
    });

    final metalInt = (cfg.globalMetalness * 255).round().clamp(0, 255);
    final roughInt = !cfg.worldReflectionsEnabled
        ? 250
        : (cfg.puddleReflections
              ? (165 - cfg.wetSurfaceGloss * 52 - cfg.frostShimmer * 8)
                    .round()
                    .clamp(36, 175)
              : 120);
    final bumpInt = cfg.enablePBR
        ? (24 + (cfg.frostShimmer * 8).round()).clamp(12, 48)
        : 0;

    _putJson(fileMap, 'pbr/global.json', {
      'format_version': '1.21.40',
      'minecraft:pog_fallback_settings': {
        'description': {'identifier': 'pog:base_pog'},
        'blocks': {
          'global_metalness_emissive_roughness_subsurface': [
            metalInt,
            0,
            roughInt,
            bumpInt,
          ],
        },
        'actors': {
          'global_metalness_emissive_roughness_subsurface': [
            metalInt,
            0,
            roughInt,
            32,
          ],
        },
        'particles': {
          'global_metalness_emissive_roughness_subsurface': [
            metalInt,
            0,
            roughInt,
            0,
          ],
        },
        'items': {
          'global_metalness_emissive_roughness_subsurface': [
            metalInt,
            0,
            roughInt,
            0,
          ],
        },
      },
    });
  }

  static void _writeFoliageParticles(
    Map<String, ArchiveFile> fileMap,
    ShaderBuildConfig cfg,
  ) {
    for (final key in fileMap.keys.toList()) {
      if (!key.startsWith('particles/leaves/') ||
          !key.endsWith('.particle.json')) {
        continue;
      }
      final pData = _readJsonMap(fileMap, key);
      final pe = pData?['particle_effect'] as Map<String, dynamic>?;
      final comps = pe?['components'] as Map<String, dynamic>?;
      if (pData == null || comps == null) continue;

      if (!cfg.wavingFoliage) {
        if (comps['minecraft:particle_emitter_rate_steady']
            is Map<String, dynamic>) {
          comps['minecraft:particle_emitter_rate_steady']['spawn_rate'] = 0.0;
        }
      } else {
        if (comps['minecraft:particle_emitter_rate_steady']
            is Map<String, dynamic>) {
          comps['minecraft:particle_emitter_rate_steady']['spawn_rate'] =
              (2.0 * cfg.foliageWaveSpeed).clamp(0.5, 6.0);
        }
        if (comps['minecraft:particle_motion_dynamic']
            is Map<String, dynamic>) {
          comps['minecraft:particle_motion_dynamic']['linear_speed'] =
              (0.35 * cfg.foliageWaveSpeed).clamp(0.05, 1.5);
        }
      }
      _putJson(fileMap, key, pData);
    }
  }

  static void _writePackAssetsAndManifest(
    Map<String, ArchiveFile> fileMap,
    ShaderBuildConfig cfg, {
    required List<int> packIconBytes,
    required String packUuid,
    required String moduleUuid,
  }) {
    fileMap['pack_icon.png'] = ArchiveFile(
      'pack_icon.png',
      packIconBytes.length,
      packIconBytes,
    );
    fileMap.remove('textures/ui/title.png');

    if (fileMap.containsKey('textures/causticsLow/caustics.png') &&
        !fileMap.containsKey('textures/caustic/caustics.png')) {
      final c = fileMap['textures/causticsLow/caustics.png']!;
      fileMap['textures/caustic/caustics.png'] = ArchiveFile(
        'textures/caustic/caustics.png',
        c.size,
        c.content,
      );
    }
    if (fileMap.containsKey('textures/caustic/caustics.png') &&
        !fileMap.containsKey('textures/causticsLow/caustics.png')) {
      final c = fileMap['textures/caustic/caustics.png']!;
      fileMap['textures/causticsLow/caustics.png'] = ArchiveFile(
        'textures/causticsLow/caustics.png',
        c.size,
        c.content,
      );
    }
    if (fileMap.containsKey('subpacks/16x/textures/clouds.png') &&
        !fileMap.containsKey('textures/environment/clouds.png')) {
      final c = fileMap['subpacks/16x/textures/clouds.png']!;
      fileMap['textures/environment/clouds.png'] = ArchiveFile(
        'textures/environment/clouds.png',
        c.size,
        c.content,
      );
    }

    var subpacksList = <Map<String, dynamic>>[];
    final existingM = _readJsonMap(fileMap, 'manifest.json');
    if (existingM != null &&
        existingM['subpacks'] is List &&
        (existingM['subpacks'] as List).isNotEmpty) {
      subpacksList = (existingM['subpacks'] as List)
          .whereType<Map>()
          .map((e) => Map<String, dynamic>.from(e))
          .toList();
    }
    if (subpacksList.isEmpty) {
      subpacksList = [
        {
          'folder_name': '32x',
          'name': '32x HD Texture Resolution',
          'memory_tier': 2,
        },
        {
          'folder_name': '16x',
          'name': '16x Standard Texture Resolution',
          'memory_tier': 3,
        },
      ];
    }

    final cleanName = cfg.packName.trim().isEmpty
        ? 'Piglix Shader'
        : cfg.packName.trim();

    _putJson(fileMap, 'manifest.json', {
      'format_version': 2,
      'header': {
        'name': cleanName,
        'description':
            'Piglix Vibrant Visuals · Bedrock Deferred PBR Shader\n§aReal-Time Lighting · Water Caustics · Atmospheric Rays & PBR',
        'uuid': packUuid,
        'version': [1, 0, 0],
        'min_engine_version': [1, 21, 80],
      },
      'modules': [
        {
          'type': 'resources',
          'uuid': moduleUuid,
          'version': [1, 0, 0],
        },
      ],
      'subpacks': subpacksList,
      'capabilities': cfg.enablePBR ? ['pbr'] : <String>[],
    });

    final langBytes = utf8.encode(
      'pack.name=$cleanName\npack.description=Piglix Vibrant Visuals Engine for Minecraft Bedrock (Deferred PBR)\n',
    );
    fileMap['texts/en_US.lang'] = ArchiveFile(
      'texts/en_US.lang',
      langBytes.length,
      langBytes,
    );
  }
}
