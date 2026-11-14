import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:archive/archive.dart';
import 'package:flutter/material.dart' show Color;
import 'package:flutter_test/flutter_test.dart';
import 'package:piglix_shader_builder/performance_tiers.dart';
import 'package:piglix_shader_builder/shader_presets.dart';
import 'package:piglix_shader_builder/vv_biomes.dart';
import 'package:piglix_shader_builder/vv_config.dart';
import 'package:piglix_shader_builder/vv_generator.dart';
import 'package:piglix_shader_builder/vv_import.dart';

const String _kTestPackUuid = '11111111-1111-4111-8111-111111111111';
const String _kTestModuleUuid = '22222222-2222-4222-8222-222222222222';
final List<int> _kDummyPngIcon = <int>[
  0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A, //
  0x00, 0x00, 0x00, 0x0D, 0x49, 0x48, 0x44, 0x52,
  0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x01,
  0x08, 0x06, 0x00, 0x00, 0x00, 0x1F, 0x15, 0xC4,
  0x89, 0x00, 0x00, 0x00, 0x0A, 0x49, 0x44, 0x41,
  0x54, 0x78, 0x9C, 0x63, 0x00, 0x01, 0x00, 0x00,
  0x05, 0x00, 0x01, 0x0D, 0x0A, 0x2D, 0xB4, 0x00,
  0x00, 0x00, 0x00, 0x49, 0x45, 0x4E, 0x44, 0xAE,
  0x42, 0x60, 0x82,
];

Archive _loadBaseArchive() {
  final bytes = File('assets/base_shader.zip').readAsBytesSync();
  return ZipDecoder().decodeBytes(bytes);
}

Map<String, dynamic> _readArchiveJson(Archive archive, String path) {
  final file = archive.findFile(path);
  expect(file, isNotNull, reason: 'Expected $path in archive');
  final raw = utf8.decode(file!.content as List<int>);
  return jsonDecode(raw) as Map<String, dynamic>;
}

dynamic _jsonPath(Map<String, dynamic> root, String dottedPath) {
  dynamic cur = root;
  final segs = dottedPath.split('.');
  for (var i = 0; i < segs.length; i++) {
    if (cur is Map) {
      final seg = segs[i];
      if (cur.containsKey(seg)) {
        cur = cur[seg];
      } else {
        final rest = segs.sublist(i).join('.');
        if (cur.containsKey(rest)) {
          return cur[rest];
        }
        return null;
      }
    } else {
      return null;
    }
  }
  return cur;
}

void main() {
  group('1. Golden Schema Tests for All Generators', () {
    test('generateAtmospherics emits 1.21.40 schema and all keyframe maps', () {
      const cfg = VVShaderConfig(packName: 'Golden Pack');
      final json = generateAtmospherics(cfg);

      expect(json['format_version'], '1.21.40');
      final atmo =
          json['minecraft:atmosphere_settings'] as Map<String, dynamic>;
      expect(atmo, isNotNull);
      expect(
        (atmo['description'] as Map)['identifier'],
        'golden_pack:global_atmosphere',
      );

      for (final key in [
        'rayleigh_strength',
        'sun_mie_strength',
        'moon_mie_strength',
        'sun_glare_shape',
        'sky_zenith_color',
        'sky_horizon_color',
      ]) {
        final section = atmo[key] as Map<String, dynamic>;
        expect(section, isNotEmpty, reason: '$key must have keyframes');
        expect(section.containsKey('0.0'), isTrue);
        expect(section.containsKey('0.25'), isTrue);
        expect(section.containsKey('0.5'), isTrue);
        expect(section.containsKey('0.75'), isTrue);
        expect(section.containsKey('1.0'), isTrue);
      }

      final stops = atmo['horizon_blend_stops'] as Map<String, dynamic>;
      expect(stops.keys, containsAll(['min', 'start', 'mie_start', 'max']));

      // Auto-derived zenith vs explicit zenith
      final derivedNoonZ = AtmosphereConfig.deriveZenithFromHorizon(
        cfg.atmosphere.noonHorizon,
      );
      expect(
        atmo['sky_zenith_color']['0.0'],
        equals([
          (derivedNoonZ.toARGB32() >> 16) & 0xFF,
          (derivedNoonZ.toARGB32() >> 8) & 0xFF,
          derivedNoonZ.toARGB32() & 0xFF,
        ]),
      );

      final explicitCfg = cfg.copyWith(
        atmosphere: cfg.atmosphere.copyWith(
          autoDeriveZenith: false,
          noonZenith: const Color(0xFF112233),
        ),
      );
      final explicitJson = generateAtmospherics(explicitCfg);
      expect(
        explicitJson['minecraft:atmosphere_settings']['sky_zenith_color']
            ['0.0'],
        equals([0x11, 0x22, 0x33]),
      );

      final endAtmo = generateDimensionAtmosphere(cfg, 'end_atmosphere');
      expect(endAtmo['format_version'], '1.21.40');
      expect(
        endAtmo['minecraft:atmosphere_settings']['description']['identifier'],
        'golden_pack:end_atmosphere',
      );
      expect(
        endAtmo['minecraft:atmosphere_settings']['rayleigh_strength']
            ['0.0'],
        lessThanOrEqualTo(11.0),
      );
    });

    test(
      'generateLighting emits 1.21.80 schema with orbital, ambient, sky, emissive',
      () {
        final cfg = VVShaderConfig(
          packName: 'Golden Pack',
          lighting: const LightingConfig(
            sunBrightnessMultiplier: 1.5,
            orbitalOffsetDegrees: 42.5,
            moonIlluminance: 1.25,
            ambientIlluminance: 0.12,
            skyIntensity: 0.75,
            emissiveDesaturation: 0.35,
          ),
        );
        final json = generateLighting(cfg);

        expect(json['format_version'], '1.21.80');
        final l = json['minecraft:lighting_settings'] as Map<String, dynamic>;
        expect(l['description']['identifier'], 'golden_pack:global');

        final orbital =
            l['directional_lights']['orbital'] as Map<String, dynamic>;
        expect(orbital['orbital_offset_degrees'], closeTo(42.5, 1e-4));

      final sun = orbital['sun'] as Map<String, dynamic>;
      expect(sun['illuminance']['0.0'], closeTo(109880.0 * 1.5, 1e-2));
      expect(sun['color'], isA<Map<String, dynamic>>());

        final moon = orbital['moon'] as Map<String, dynamic>;
        expect(moon['illuminance'], closeTo(1.25, 1e-4));
        expect(moon['color'], isA<List<int>>());

        expect(l['ambient']['illuminance'], closeTo(0.12, 1e-4));
        expect(l['ambient']['color'], isA<List<int>>());
        expect(l['sky']['intensity'], closeTo(0.75, 1e-4));
        expect(l['emissive']['desaturation'], closeTo(0.35, 1e-4));

        final dim = generateDimensionLighting(cfg, 'hell_lighting');
        expect(
          dim['minecraft:lighting_settings']['directional_lights']['orbital']['orbital_offset_degrees'],
          closeTo(42.5, 1e-4),
        );
      },
    );

    test(
      'generateLocalLighting emits 1.21.120 direct block keys without wrapper',
      () {
        const cfg = VVShaderConfig(
          lighting: LightingConfig(
            torches: BlockLightGroup(
              color: Color(0xFFFFAA33),
              lightType: 'point_light',
            ),
            copper: BlockLightGroup(
              color: Color(0xFF00FF88),
              lightType: 'static_light',
            ),
            syncWarmToTorch: true,
            syncMysticToSoul: false,
          ),
        );
        final json = generateLocalLighting(cfg);

        expect(json['format_version'], '1.21.120');
        final ll =
            json['minecraft:local_light_settings'] as Map<String, dynamic>;
        expect(ll.containsKey('description'), isFalse);
        expect(ll.containsKey('colors'), isFalse);

        for (final block in const [
          'minecraft:torch',
          'minecraft:lantern',
          'minecraft:soul_torch',
          'minecraft:candle',
          'minecraft:redstone_torch',
          'minecraft:end_rod',
          'minecraft:copper_torch',
        ]) {
          expect(ll.containsKey(block), isTrue, reason: 'Missing $block');
          final entry = ll[block] as Map<String, dynamic>;
          expect(entry['light_color'], matches(RegExp(r'^#[0-9A-F]{6}$')));
          expect(entry['light_type'], anyOf('point_light', 'static_light'));
        }

        expect(ll['minecraft:torch']['light_color'], '#FFAA33');
        expect(ll['minecraft:torch']['light_type'], 'point_light');
        expect(ll['minecraft:copper_torch']['light_color'], '#00FF88');
        expect(ll['minecraft:copper_torch']['light_type'], 'static_light');
        // syncWarmToTorch links redstone to torch color
        expect(ll['minecraft:redstone_torch']['light_color'], '#FFAA33');
        // syncMysticToSoul: false omits sea_lantern
        expect(ll.containsKey('minecraft:sea_lantern'), isFalse);
      },
    );

    test('generateShadows emits 1.21.80 shadow_settings', () {
      const softCfg = VVShaderConfig(
        lighting: LightingConfig(
          shadowStyle: 'soft_shadows',
          shadowTexelSize: 1024,
        ),
      );
      final softJson = generateShadows(softCfg);
      expect(softJson['format_version'], '1.21.80');
      expect(
        softJson['minecraft:shadow_settings'],
        equals({'shadow_style': 'soft_shadows', 'texel_size': 1024}),
      );

      const blockyCfg = VVShaderConfig(
        lighting: LightingConfig(
          shadowStyle: 'blocky_shadows',
          shadowTexelSize: 512,
        ),
      );
      final blockyJson = generateShadows(blockyCfg);
      expect(
        blockyJson['minecraft:shadow_settings'],
        equals({'shadow_style': 'blocky_shadows', 'texel_size': 512}),
      );
    });

    test(
      'generateFog emits 1.21.90 schema and caveWaterVisibility lowers water density & absorption',
      () {
        const lowVisCfg = VVShaderConfig(
          packName: 'Fog Test',
          fog: FogConfig(caveWaterVisibility: 0.0),
        );
        const highVisCfg = VVShaderConfig(
          packName: 'Fog Test',
          fog: FogConfig(caveWaterVisibility: 1.0),
        );

        final lowJson = generateFog(lowVisCfg, 'fog_overworld');
        final highJson = generateFog(highVisCfg, 'fog_overworld');

        expect(lowJson['format_version'], '1.21.90');
        final lowFog =
            lowJson['minecraft:fog_settings'] as Map<String, dynamic>;
        expect(lowFog['description']['identifier'], 'fog_test:fog_overworld');

        final distance = lowFog['distance'] as Map<String, dynamic>;
        expect(distance.keys, containsAll(['air', 'weather', 'water']));
        expect(
          distance['water']['transition_fog'],
          isA<Map<String, dynamic>>(),
        );

        final lowVol = lowFog['volumetric'] as Map<String, dynamic>;
        final highVol =
            highJson['minecraft:fog_settings']['volumetric']
                as Map<String, dynamic>;
        expect(lowVol.keys, containsAll(['density', 'media_coefficients']));

        final lowWaterMaxDensity =
            lowVol['density']['water']['max_density'] as num;
        final highWaterMaxDensity =
            highVol['density']['water']['max_density'] as num;
        expect(highWaterMaxDensity, lessThan(lowWaterMaxDensity));

        final lowAbs =
            (lowVol['media_coefficients']['water']['absorption'] as List)
                .cast<num>();
        final highAbs =
            (highVol['media_coefficients']['water']['absorption'] as List)
                .cast<num>();
        for (var i = 0; i < 3; i++) {
          expect(highAbs[i], lessThan(lowAbs[i]));
        }
      },
    );

    test('generateWater emits 1.21.80 for Wide and 1.26.0 for Modern', () {
      const presets = [
        WaterPresetConfig.tropical(),
        WaterPresetConfig.ocean(),
        WaterPresetConfig.deepOcean(),
        WaterPresetConfig.river(),
        WaterPresetConfig.swamp(),
      ];
      const expectedIds = [
        'water_tropical',
        'water_ocean',
        'water_deep_ocean',
        'water_river',
        'water_swamp',
      ];

      const global = WaterGlobalSettings(
        wavesEnabled: false,
        causticsEnabled: false,
        causticsFrameLength: 0.05,
        causticsPower: 3,
        causticsScale: 0.25,
      );

      for (var i = 0; i < presets.length; i++) {
        // Wide target: 1.21.80 and biome_water_color_contribution is disabled
        final wideJson = generateWater(
          presets[i],
          packSlug: 'water_pack',
          global: global,
          target: VVExportTarget.wide,
        );
        expect(wideJson['format_version'], '1.21.80');
        final wideWs =
            wideJson['minecraft:water_settings'] as Map<String, dynamic>;
        expect(
          wideWs['description']['identifier'],
          'water_pack:${expectedIds[i]}',
        );
        expect(wideWs.containsKey('biome_water_color_contribution'), isFalse);

        // Modern target: 1.26.0 and biome_water_color_contribution is enabled
        final modernJson = generateWater(
          presets[i],
          packSlug: 'water_pack',
          global: global,
          target: VVExportTarget.modern,
        );
        expect(modernJson['format_version'], '1.26.0');
        final modernWs =
            modernJson['minecraft:water_settings'] as Map<String, dynamic>;
        expect(
          modernWs['biome_water_color_contribution'],
          closeTo(presets[i].biomeWaterColorContribution, 1e-4),
        );
        expect(
          modernWs['particle_concentrations'],
          containsPair('cdom', closeTo(presets[i].cdom, 1e-4)),
        );
        final caustics = modernWs['caustics'] as Map<String, dynamic>;
        expect(caustics['enabled'], isFalse);
        expect(caustics['frame_length'], closeTo(0.05, 1e-4));
        expect(caustics['power'], 3);
        expect(caustics['scale'], closeTo(0.25, 1e-4));
        final waves = modernWs['waves'] as Map<String, dynamic>;
        expect(waves['enabled'], isFalse);
        expect(
          waves.keys,
          containsAll(['frequency', 'octaves', 'depth', 'speed']),
        );
      }
    });

    test('generateColorGrading emits 1.21.90 schema and all 5 moods', () {
      for (final mood in ColorGradingConfig.moodNames) {
        final cg = ColorGradingConfig.forMood(
          mood,
          toneMappingOperator: 'aces',
        );
        final json = generateColorGrading(cg, 'test_pack:mood_$mood');
        expect(json['format_version'], '1.21.90');

        final root =
            json['minecraft:color_grading_settings'] as Map<String, dynamic>;
        expect(root['description']['identifier'], 'test_pack:mood_$mood');
        expect(root['tone_mapping']['operator'], 'aces');

        final grading = root['color_grading'] as Map<String, dynamic>;
        // Official 1.21.90 schema places temperature inside color_grading
        expect(root.containsKey('temperature'), isFalse);
        final temp = grading['temperature'] as Map<String, dynamic>;
        expect(temp.keys, containsAll(['enabled', 'type', 'temperature']));
        expect(grading['midtones'], isA<Map<String, dynamic>>());
        expect(
          (grading['highlights'] as Map<String, dynamic>).containsKey(
            'highlightsMin',
          ),
          isTrue,
        );
        expect(
          (grading['shadows'] as Map<String, dynamic>).containsKey(
            'shadowsMax',
          ),
          isTrue,
        );
      }
    });

    test(
      'generatePbr emits 1.21.40 minecraft:pbr_fallback_settings (never pog_fallback_settings)',
      () {
        final cfg = VVShaderConfig(
          surface: SurfaceConfig.fromShininess(0.5, metalness: 12, emissive: 4),
        );
        final json = generatePbr(cfg);

        expect(json['format_version'], '1.21.40');
        expect(json.containsKey('minecraft:pbr_fallback_settings'), isTrue);
        expect(json.containsKey('minecraft:pog_fallback_settings'), isFalse);

        final pbr =
            json['minecraft:pbr_fallback_settings'] as Map<String, dynamic>;
        expect(
          pbr.keys,
          containsAll(['blocks', 'actors', 'particles', 'items']),
        );
        final blockMers =
            pbr['blocks']['global_metalness_emissive_roughness_subsurface']
                as List;
        expect(blockMers, equals([12, 4, cfg.surface.roughness, 0]));
      },
    );

    test('generateClientBiome & kVanillaBiomes cover all vanilla biomes, dimension separation, 3-layer cascade, max-1 precipitation', () {
      expect(kVanillaBiomes.length, 89);
      expect(kVanillaBiomes.map((b) => b.id).toSet().length, 89);
      expect(
        kVanillaBiomes.where((b) => b.dimension == BiomeDimension.nether).length,
        5,
      );
      expect(
        kVanillaBiomes.where((b) => b.dimension == BiomeDimension.end).length,
        1,
      );

        final cfg = VVShaderConfig(
          packName: 'Cascade Pack',
          biomeOverrides: BiomeOverridesConfig(
            global: const BiomeAppearanceOverride(
              skyColor: Color(0xFF111111),
              waterPreset: 'water_ocean',
              precipitationType: 'ash',
              precipitationDensity: 0.5,
            ),
            groupOverrides: {
              BiomeGroup.forest: const BiomeAppearanceOverride(
                skyColor: Color(0xFF222222),
              ),
            },
            biomeOverrides: {
              'plains': const BiomeAppearanceOverride(
                skyColor: Color(0xFF333333),
              ),
            },
          ),
        );

        // Single biome beats group & global; waterPreset still cascades from global
        final plains = generateClientBiome(kVanillaBiomeById['plains']!, cfg);
        expect(plains['format_version'], '1.21.120');
        final plainsComps =
            plains['minecraft:client_biome']['components']
                as Map<String, dynamic>;
        expect(plainsComps['minecraft:sky_color']['sky_color'], '#333333');
        expect(
          plainsComps['minecraft:water_identifier']['water_identifier'],
          'cascade_pack:water_ocean',
        );
        final precip =
            plainsComps['minecraft:precipitation'] as Map<String, dynamic>;
        expect(precip.length, lessThanOrEqualTo(1));
        expect(precip['ash'], closeTo(0.5, 1e-4));

        // Group beats global
        final forest = generateClientBiome(kVanillaBiomeById['forest']!, cfg);
        expect(
          forest['minecraft:client_biome']['components']['minecraft:sky_color']['sky_color'],
          '#222222',
        );

        // Overworld global does NOT bleed into Nether or End
        final hell = generateClientBiome(kVanillaBiomeById['hell']!, cfg);
        final hellComps =
            hell['minecraft:client_biome']['components']
                as Map<String, dynamic>;
        expect(hellComps['minecraft:sky_color']['sky_color'], '#D76B30');
        expect(
          hellComps['minecraft:water_identifier']['water_identifier'],
          'cascade_pack:water_swamp',
        );

        final theEnd = generateClientBiome(kVanillaBiomeById['the_end']!, cfg);
        final endComps =
            theEnd['minecraft:client_biome']['components']
                as Map<String, dynamic>;
        expect(
          endComps['minecraft:sky_color']['sky_color'],
          anyOf('#000000', '#7218BB'),
        );
        expect(endComps['minecraft:sky_color']['sky_color'], isNot('#111111'));

        // Every biome has at most 1 precipitation key
        for (final biome in kVanillaBiomes) {
          final bJson = generateClientBiome(biome, cfg);
          final comps =
              bJson['minecraft:client_biome']['components']
                  as Map<String, dynamic>;
          if (comps.containsKey('minecraft:precipitation')) {
            expect(
              (comps['minecraft:precipitation'] as Map).length,
              lessThanOrEqualTo(1),
            );
          }
        }
      },
    );

    test(
      'generateManifest emits valid min_engine_version, pbr capability, UUIDs & subpacks',
      () {
        const cfg = VVShaderConfig(
          packName: 'Manifest Test',
          packDescription: 'Test description',
          packVersion: [2, 1, 0],
        );
        final manifest = generateManifest(
          cfg,
          _kTestPackUuid,
          _kTestModuleUuid,
          subpacks: const [
            {'folder_name': 'low', 'name': 'Low', 'memory_tier': 2},
            {'folder_name': 'high', 'name': 'High', 'memory_tier': 6},
          ],
        );

        expect(manifest['format_version'], 2);
        final header = manifest['header'] as Map<String, dynamic>;
        expect(header['uuid'], _kTestPackUuid);
        expect(header['version'], [2, 1, 0]);
        final minVer = (header['min_engine_version'] as List).cast<int>();
        expect(
          minVer[0] > 1 ||
              (minVer[0] == 1 && minVer[1] > 21) ||
              (minVer[0] == 1 && minVer[1] == 21 && minVer[2] >= 120),
          isTrue,
        );
        final modules = manifest['modules'] as List;
        expect(modules.first['uuid'], _kTestModuleUuid);
        expect(header['uuid'], isNot(equals(modules.first['uuid'])));
        expect(manifest['capabilities'], equals(['pbr']));
        expect((manifest['subpacks'] as List).length, 2);
      },
    );

    test(
      'Rule 20: Client biomes copy from Mojang templates and preserve ambient_sounds & biome_music',
      () {
        const cfg = VVShaderConfig(packName: 'Biome Preserve Test');

        final plains = generateClientBiome(kVanillaBiomeById['plains']!, cfg);
        final plainsComps =
            plains['minecraft:client_biome']['components']
                as Map<String, dynamic>;
        expect(plainsComps.containsKey('minecraft:ambient_sounds'), isTrue);
        expect(
          plainsComps['minecraft:atmosphere_identifier']['atmosphere_identifier'],
          'biome_preserve_test:global_atmosphere',
        );

        final hell = generateClientBiome(kVanillaBiomeById['hell']!, cfg);
        final hellComps =
            hell['minecraft:client_biome']['components']
                as Map<String, dynamic>;
        expect(hellComps.containsKey('minecraft:ambient_sounds'), isTrue);
        expect(hellComps.containsKey('minecraft:biome_music'), isTrue);
        expect(hellComps['minecraft:biome_music']['music_definition'], 'hell');

        final theEnd = generateClientBiome(kVanillaBiomeById['the_end']!, cfg);
        final endComps =
            theEnd['minecraft:client_biome']['components']
                as Map<String, dynamic>;
        expect(endComps.containsKey('minecraft:ambient_sounds'), isTrue);
        expect(endComps.containsKey('minecraft:biome_music'), isTrue);

        final pale = generateClientBiome(
          kVanillaBiomeById['pale_garden']!,
          cfg,
        );
        final paleComps =
            pale['minecraft:client_biome']['components']
                as Map<String, dynamic>;
        expect(paleComps.containsKey('minecraft:dry_foliage_color'), isTrue);
        expect(paleComps.containsKey('minecraft:foliage_appearance'), isTrue);
      },
    );

    test(
      'Rule 21: Nether ("hell") and End ("the_end") write their own dedicated files',
      () {
        const cfg = VVShaderConfig(packName: 'Dimension Test');
        final hell = generateClientBiome(kVanillaBiomeById['hell']!, cfg);
        final hellComps =
            hell['minecraft:client_biome']['components']
                as Map<String, dynamic>;
        expect(
          hellComps['minecraft:atmosphere_identifier']['atmosphere_identifier'],
          'dimension_test:hell_atmosphere',
        );
        expect(
          hellComps['minecraft:lighting_identifier']['lighting_identifier'],
          'dimension_test:hell_lighting',
        );
        expect(
          hellComps['minecraft:fog_appearance']['fog_identifier'],
          'dimension_test:fog_hell',
        );

        final theEnd = generateClientBiome(kVanillaBiomeById['the_end']!, cfg);
        final endComps =
            theEnd['minecraft:client_biome']['components']
                as Map<String, dynamic>;
        expect(
          endComps['minecraft:atmosphere_identifier']['atmosphere_identifier'],
          'dimension_test:end_atmosphere',
        );
        expect(
          endComps['minecraft:lighting_identifier']['lighting_identifier'],
          'dimension_test:end_lighting',
        );
        expect(
          endComps['minecraft:fog_appearance']['fog_identifier'],
          'dimension_test:fog_end',
        );
      },
    );

    test(
      'Rule 22: 3-layer cascade: Global -> Group -> Single Biome, lower layer wins',
      () {
        final cfg = const VVShaderConfig(packName: 'Cascade Test').copyWith(
          biomeOverrides: BiomeOverridesConfig(
            global: const BiomeAppearanceOverride(
              waterSurfaceColor: Color(0xFF111111),
              grassColor: Color(0xFF112233),
            ),
            groupOverrides: {
              BiomeGroup.forest: const BiomeAppearanceOverride(
                waterSurfaceColor: Color(0xFF444444),
              ),
            },
            biomeOverrides: {
              'plains': const BiomeAppearanceOverride(
                waterSurfaceColor: Color(0xFF999999),
              ),
            },
          ),
        );

        // Single biome (plains) beats group & global for waterSurfaceColor, but inherits global grassColor
        final plains = generateClientBiome(kVanillaBiomeById['plains']!, cfg);
        final plainsComps =
            plains['minecraft:client_biome']['components']
                as Map<String, dynamic>;
        expect(
          plainsComps['minecraft:water_appearance']['surface_color'],
          '#999999',
        );
        expect(plainsComps['minecraft:grass_appearance']['color'], '#112233');

        // Group (forest) beats global for waterSurfaceColor
        final forest = generateClientBiome(kVanillaBiomeById['forest']!, cfg);
        final forestComps =
            forest['minecraft:client_biome']['components']
                as Map<String, dynamic>;
        expect(
          forestComps['minecraft:water_appearance']['surface_color'],
          '#444444',
        );
        expect(forestComps['minecraft:grass_appearance']['color'], '#112233');

        // Unrelated group (desert) takes global
        final desert = generateClientBiome(kVanillaBiomeById['desert']!, cfg);
        final desertComps =
            desert['minecraft:client_biome']['components']
                as Map<String, dynamic>;
        expect(
          desertComps['minecraft:water_appearance']['surface_color'],
          '#111111',
        );
      },
    );

    test('Rule 23: Biome list versioning & warning when game adds biomes', () {
      // Versioning warning in validateConfig
      final oldCfg = const VVShaderConfig(
        packName: 'Old Preset',
      ).copyWith(biomeListVersion: 0);
      final report = validateConfig(oldCfg);
      expect(
        report.warnings.any(
          (w) => w.contains('older than current game catalog'),
        ),
        isTrue,
      );

      // Archive retains extra/newer biomes with warning in validateArchive
      final base = _loadBaseArchive();
      final extraContent = utf8.encode(
        jsonEncode({
          'format_version': '1.21.120',
          'minecraft:client_biome': {
            'description': {'identifier': 'minecraft:custom_future_biome'},
            'components': {},
          },
        }),
      );
      base.addFile(
        ArchiveFile(
          'biomes/custom_future_biome.client_biome.json',
          extraContent.length,
          extraContent,
        ),
      );

      const cfg = VVShaderConfig(packName: 'Extra Biome Test');
      final archive = buildArchive(
        base,
        cfg,
        packIconBytes: _kDummyPngIcon,
        packUuid: _kTestPackUuid,
        moduleUuid: _kTestModuleUuid,
      );

      // Extra biome was retained in archive!
      final extraInArchive = archive.findFile(
        'biomes/custom_future_biome.client_biome.json',
      );
      expect(extraInArchive, isNotNull);

      // validateArchive warns about it
      final archReport = validateArchive(archive, cfg);
      expect(
        archReport.warnings.any((w) => w.contains('extra/newer biome')),
        isTrue,
      );
    });

    test(
      'Phase 5: Subpacks use manifest V2 memory_tier (6, 12, 18, 32) and reject V3 memory_performance_tier',
      () {
        expect(TierProfile.low.memoryTier, 6);
        expect(TierProfile.medium.memoryTier, 12);
        expect(TierProfile.high.memoryTier, 18);
        expect(TierProfile.ultra.memoryTier, 32);

        // Verify validateArchive rejects experimental V3 memory_performance_tier
        final base = _loadBaseArchive();
        const cfg = VVShaderConfig(packName: 'V3 Rejection Test');
        final archive = buildArchive(
          base,
          cfg,
          packIconBytes: _kDummyPngIcon,
          packUuid: _kTestPackUuid,
          moduleUuid: _kTestModuleUuid,
        );

        // Inject illegal memory_performance_tier into manifest.json
        final manifestJson = _readArchiveJson(archive, 'manifest.json');
        manifestJson['subpacks'] = [
          {
            'folder_name': 'test_v3',
            'name': 'V3 Tier',
            'memory_performance_tier': 10,
          },
        ];
        final manifestBytes = utf8.encode(jsonEncode(manifestJson));
        archive.addFile(
          ArchiveFile('manifest.json', manifestBytes.length, manifestBytes),
        );

        final report = validateArchive(archive, cfg);
        expect(
          report.errors.any((e) => e.contains('memory_performance_tier')),
          isTrue,
          reason:
              'Must reject experimental manifest V3 memory_performance_tier',
        );
      },
    );

    test(
      'Phase 5: Performance score 100-pt formula breakdown & mobile GPU throttling warnings',
      () {
        // Baseline heavy config
        final heavyCfg = VVShaderConfig(
          packName: 'Heavy Score Test',
          lighting: const LightingConfig(
            shadowStyle: 'soft_shadows', // 25 pts
            shadowTexelSize: 8, // < 16 triggers mobile warning
          ),
          fog: const FogConfig(
            volumetricMaxDensity: 0.20, // multi-layer volumetric
            underwaterVolumeDensity: 0.06,
          ),
          waterGlobal: const WaterGlobalSettings(
            wavesEnabled: true,
            causticsEnabled: true,
          ),
          waterTropical: const WaterPresetConfig.tropical().copyWith(
            wavesOctaves: 16, // > 8 triggers mobile warning
          ),
          performance: const PerformanceTierConfig(
            activeTier: PerformanceTier.low,
          ),
        );

        final score = computePerformanceScore(heavyCfg);
        expect(score.breakdown.shadows, 25.0);
        expect(score.breakdown.volumetricFog, closeTo(15.6, 0.5));
        expect(score.breakdown.waterWavesCaustics, closeTo(10.3, 0.5));
        expect(score.breakdown.colorGrading, 10.0);
        expect(score.numericScore, greaterThan(60));
        expect(
          score.breakdown.tooltipText,
          contains('Performance Cost Breakdown (Total: 100 pts)'),
        );

        // Check mobile GPU memory bandwidth throttling warnings (Rule 28)
        expect(
          score.warnings.any(
            (w) => w.contains(
              'mobile GPUs throttle quickly on deferred memory bandwidth',
            ),
          ),
          isTrue,
        );
        expect(
          score.warnings.any((w) => w.contains('Shadow texel size')),
          isTrue,
        );
        expect(
          score.warnings.any((w) => w.contains('Water wave octaves')),
          isTrue,
        );
        expect(
          score.warnings.any(
            (w) => w.contains('Volumetric media active on multiple layers'),
          ),
          isTrue,
        );
      },
    );
  });

  group('2. Full buildArchive + validateArchive against assets/base_shader.zip', () {
    test(
      'exports valid pack with diff-only subpacks, lite style, water lock, PBR textures, and 87 biomes',
      () {
        final base = _loadBaseArchive();
        const cfg = VVShaderConfig(
          packName: 'Full Export Test',
          performance: PerformanceTierConfig(
            activeTier: PerformanceTier.high,
            exportAllTiers: true,
            styleIntensityLite: true,
          ),
        );

        final archive = buildArchive(
          base,
          cfg,
          packIconBytes: _kDummyPngIcon,
          packUuid: _kTestPackUuid,
          moduleUuid: _kTestModuleUuid,
        );

        final report = validateArchive(archive, cfg);
        expect(report.errors, isEmpty);
        expect(report.isValid, isTrue);

        final filesByPath = {
          for (final f in archive)
            if (f.isFile) f.name.replaceAll('\\', '/'): f,
        };

        // Manifest lists 4 tiers + lite with manifest V2 memory_tier (Rules 24 & 25)
        final manifest = _readArchiveJson(archive, 'manifest.json');
        final subpacksRaw = manifest['subpacks'] as List;
        final subpackFolders = subpacksRaw
            .map((e) => (e as Map)['folder_name'] as String)
            .toList();
        expect(
          subpackFolders,
          equals(['low', 'medium', 'high', 'ultra', 'lite']),
        );

        final subpackMemoryTiers = {
          for (final sp in subpacksRaw)
            (sp as Map)['folder_name']: sp['memory_tier'],
        };
        expect(subpackMemoryTiers['low'], 6);
        expect(subpackMemoryTiers['medium'], 12);
        expect(subpackMemoryTiers['high'], 18);
        expect(subpackMemoryTiers['ultra'], 32);

        // All 87 biomes exist at root
        for (final b in kVanillaBiomes) {
          expect(
            filesByPath.containsKey('biomes/${b.id}.client_biome.json'),
            isTrue,
            reason: 'Missing biome ${b.id} in exported archive',
          );
        }

        // Base pack is LOWEST tier (low) (Rule 24)
        // subpacks/low mirrors base so it is listed in gear icon (Rule 25)
        expect(
          filesByPath.containsKey('subpacks/low/lighting/global.json'),
          isTrue,
          reason:
              'subpacks/low must mirror base so it is listed in gear icon dropdown',
        );

        // Diff-only files in subpacks/medium, high, ultra, lite over base low tier
        for (final tierFolder in ['medium', 'high', 'ultra', 'lite']) {
          final prefix = 'subpacks/$tierFolder/';
          final tierFiles = filesByPath.keys
              .where((k) => k.startsWith(prefix))
              .toList();
          for (final subPath in tierFiles) {
            final relPath = subPath.substring(prefix.length);
            if (relPath.startsWith('textures/')) continue;
            final rootFile = filesByPath[relPath];
            if (rootFile != null) {
              expect(
                filesByPath[subPath]!.content,
                isNot(equals(rootFile.content)),
                reason: '$subPath must only be emitted if it differs from root',
              );
            }
          }
        }

        // subpacks/high overrides base low tier
        expect(
          filesByPath.keys.any(
            (k) => k.startsWith('subpacks/high/') && k.endsWith('.json'),
          ),
          isTrue,
        );
        // subpacks/lite has diff-only color_grading & fogs
        expect(
          filesByPath.keys.any(
            (k) => k.startsWith('subpacks/lite/color_grading/'),
          ),
          isTrue,
        );

        // Water waves.enabled & caustics.* identical across all 5 water files per tier
        const waterPaths = [
          'water/water_tropical.json',
          'water/water_ocean.json',
          'water/water_deep_ocean.json',
          'water/water_river.json',
          'water/water_swamp.json',
        ];
        for (final scopePrefix in [
          '',
          'subpacks/low/',
          'subpacks/medium/',
          'subpacks/high/',
          'subpacks/ultra/',
          'subpacks/lite/',
        ]) {
          String? sig;
          for (final wp in waterPaths) {
            final effPath = filesByPath.containsKey('$scopePrefix$wp')
                ? '$scopePrefix$wp'
                : wp;
            final json = _readArchiveJson(archive, effPath);
            final ws = json['minecraft:water_settings'] as Map<String, dynamic>;
            final curSig = jsonEncode({
              'caustics': ws['caustics'],
              'wavesEnabled': ws['waves']['enabled'],
            });
            sig ??= curSig;
            expect(curSig, equals(sig), reason: 'Mismatch in $scopePrefix$wp');
          }
        }

        // PBR texture_set.json placement follows pbrTextureSets:
        // When exportAllTiers is true, root is Low tier (pbrTextureSets=false)
        expect(
          filesByPath.keys.any(
            (k) =>
                !k.startsWith('subpacks/') &&
                k.startsWith('textures/') &&
                k.endsWith('.texture_set.json'),
          ),
          isFalse,
        );
        expect(
          filesByPath.keys.any(
            (k) =>
                k.startsWith('subpacks/low/textures/') &&
                k.endsWith('.texture_set.json'),
          ),
          isFalse,
        );
        expect(
          filesByPath.keys.any(
            (k) =>
                k.startsWith('subpacks/high/textures/') &&
                k.endsWith('.texture_set.json'),
          ),
          isTrue,
        );

        // activeTier=low (pbrTextureSets=false) -> root omits texture_set.json; high/ultra include them
        final lowRootArchive = buildArchive(
          _loadBaseArchive(),
          cfg.copyWith(
            performance: cfg.performance.copyWith(
              activeTier: PerformanceTier.low,
            ),
          ),
          packIconBytes: _kDummyPngIcon,
          packUuid: _kTestPackUuid,
          moduleUuid: _kTestModuleUuid,
        );
        final lowFiles = {
          for (final f in lowRootArchive)
            if (f.isFile) f.name.replaceAll('\\', '/'): f,
        };
        expect(
          lowFiles.keys.any(
            (k) =>
                !k.startsWith('subpacks/') &&
                k.startsWith('textures/') &&
                k.endsWith('.texture_set.json'),
          ),
          isFalse,
        );
        expect(
          lowFiles.keys.any(
            (k) =>
                k.startsWith('subpacks/high/textures/') &&
                k.endsWith('.texture_set.json'),
          ),
          isTrue,
        );
        expect(
          lowFiles.keys.any(
            (k) =>
                k.startsWith('subpacks/ultra/textures/') &&
                k.endsWith('.texture_set.json'),
          ),
          isTrue,
        );
      },
    );
  });

  group('3. Validation, Migration & Round-trip Import', () {
    test(
      'validateConfig catches out-of-range errors and warns on dark night & invisible cave water',
      () {
        const invalidCfg = VVShaderConfig(
          packName: '',
          packVersion: [1, -2, 0],
          atmosphere: AtmosphereConfig(rayleighNoon: 15.0),
          lighting: LightingConfig(sunBrightnessMultiplier: 5.0),
          fog: FogConfig(airFogStart: 0.9, airFogEnd: 0.5),
          colorGrading: ColorGradingConfig(toneMappingOperator: 'bogus_op'),
          surface: SurfaceConfig(metalness: 999),
        );
        final invalidReport = validateConfig(invalidCfg);
        expect(invalidReport.isValid, isFalse);
        expect(invalidReport.errors.length, greaterThanOrEqualTo(7));

        const warnCfg = VVShaderConfig(
          lighting: LightingConfig(
            moonIlluminance: 0.01,
            ambientIlluminance: 0.0,
          ),
          fog: FogConfig(caveWaterVisibility: 0.05),
        );
        final warnReport = validateConfig(warnCfg);
        expect(warnReport.isValid, isTrue);
        expect(
          warnReport.warnings.any((w) => w.contains('Night is too dark')),
          isTrue,
        );
        expect(
          warnReport.warnings.any(
            (w) => w.contains('No visible water in caves'),
          ),
          isTrue,
        );
      },
    );

    test(
      'migrateFromLegacy and migrateFromShaderPreset convert fields and count dropped keys',
      () {
        final legacyRes = migrateFromLegacy({
          'packName': 'Legacy Test',
          'noonColor': '#3366FF',
          'torchLightColor': '#FF9922',
          'lightIntensity': 1.4,
          'toneMapFilter': 'ACES (Cinematic)',
          'biomeTone': 'Vibrant',
          'saturation': 1.25,
          'globalMetalness': 0.2,
          'cloudType': 'Realistic 3D',
          'wavingFoliage': true,
          'autoExposure': 1.1,
        });

        expect(legacyRes.config.packName, 'Legacy Test');
        expect(
          legacyRes.config.atmosphere.noonHorizon,
          const Color(0xFF3366FF),
        );
        expect(legacyRes.config.lighting.torchColor, const Color(0xFFFF9922));
        expect(
          legacyRes.config.lighting.sunBrightnessMultiplier,
          closeTo(1.4, 1e-4),
        );
        expect(legacyRes.config.colorGrading.toneMappingOperator, 'aces');
        expect(legacyRes.config.activeMood, 'vibrant');
        expect(legacyRes.droppedUnsupportedCount, 3);
        expect(
          legacyRes.droppedKeys,
          containsAll(['cloudType', 'wavingFoliage', 'autoExposure']),
        );
        expect(
          legacyRes.userNotice,
          contains('settings are no longer supported'),
        );

        final presetRes = migrateFromShaderPreset(kDefaultShaderPresets.first);
        expect(presetRes.config.packName, kDefaultShaderPresets.first.name);
        expect(presetRes.droppedUnsupportedCount, greaterThan(0));
        expect(
          presetRes.userNotice,
          contains('settings are no longer supported'),
        );
      },
    );

    test('parseVVPackFromArchive round-trips an exported VV .mcpack', () {
      final sourceCfg = VVShaderConfig(
        packName: 'Roundtrip Pack',
        packDescription: 'Roundtrip VV Description',
        packVersion: const [2, 3, 4],
        exportTarget: VVExportTarget.modern,
        atmosphere: const AtmosphereConfig(
          autoDeriveZenith: false,
          noonHorizon: Color(0xFF88CCFF),
          noonZenith: Color(0xFF2244AA),
          rayleighNoon: 3.1,
          sunGlowNoon: 9.5,
          moonGlow: 2.4,
        ),
        lighting: const LightingConfig(
          sunBrightnessMultiplier: 1.3,
          orbitalOffsetDegrees: 25.0,
          moonIlluminance: 1.5,
          ambientIlluminance: 0.08,
          skyIntensity: 0.85,
          emissiveDesaturation: 0.25,
          torches: BlockLightGroup(
            color: Color(0xFFFFAA00),
            lightType: 'point_light',
          ),
          copper: BlockLightGroup(
            color: Color(0xFF22DD88),
            lightType: 'static_light',
          ),
          syncMysticToSoul: false,
        ),
        fog: const FogConfig(
          airFogColor: Color(0xFFAABBCC),
          airFogStart: 0.35,
          airFogEnd: 0.92,
          waterFogColor: Color(0xFF113355),
          waterFogEnd: 64.0,
          volumetricMaxDensity: 0.09,
        ),
        waterGlobal: const WaterGlobalSettings(
          wavesEnabled: true,
          causticsEnabled: true,
          causticsPower: 4,
          causticsScale: 0.3,
        ),
        waterTropical: const WaterPresetConfig.tropical().copyWith(
          cdom: 4.5,
          biomeWaterColorContribution: 0.72,
          wavesDepth: 0.22,
          wavesSpeed: 3.5,
        ),
        colorGrading: ColorGradingConfig.scalar(
          toneMappingOperator: 'aces',
          temperature: 5800.0,
          midtonesSaturation: 1.35,
          midtonesContrast: 1.25,
          midtonesGain: 1.15,
        ),
        surface: const SurfaceConfig(
          metalness: 20,
          emissive: 5,
          roughness: 180,
          subsurface: 10,
        ),
        performance: const PerformanceTierConfig(
          activeTier: PerformanceTier.ultra,
          exportAllTiers: false,
          styleIntensityLite: true,
        ),
      );

      final exported = buildArchive(
        _loadBaseArchive(),
        sourceCfg,
        packIconBytes: _kDummyPngIcon,
        packUuid: _kTestPackUuid,
        moduleUuid: _kTestModuleUuid,
      );
      final encodedBytes = ZipEncoder().encode(exported);
      final decodedArchive = ZipDecoder().decodeBytes(
        Uint8List.fromList(encodedBytes),
      );

      final imported = parseVVPackFromArchive(decodedArchive);
      expect(imported.wasNativeVVPack, isTrue);
      expect(imported.packIconBytes, isNotNull);

      final ic = imported.config;
      expect(ic.packName, 'Roundtrip Pack');
      expect(ic.packDescription, 'Roundtrip VV Description');
      expect(ic.packVersion, [2, 3, 4]);
      expect(ic.exportTarget, VVExportTarget.modern);
      expect(ic.atmosphere.noonHorizon, const Color(0xFF88CCFF));
      expect(ic.atmosphere.noonZenith, const Color(0xFF2244AA));
      expect(ic.atmosphere.rayleighNoon, closeTo(3.1, 1e-3));
      expect(ic.atmosphere.sunGlowNoon, closeTo(9.5, 1e-3));
      expect(ic.atmosphere.moonGlow, closeTo(2.4, 1e-3));
      expect(ic.lighting.sunBrightnessMultiplier, closeTo(1.3, 1e-3));
      expect(ic.lighting.orbitalOffsetDegrees, closeTo(25.0, 1e-3));
      expect(ic.lighting.moonIlluminance, closeTo(1.5, 1e-3));
      expect(ic.lighting.ambientIlluminance, closeTo(0.08, 1e-3));
      expect(ic.lighting.skyIntensity, closeTo(0.85, 1e-3));
      expect(ic.lighting.emissiveDesaturation, closeTo(0.25, 1e-3));
      expect(ic.lighting.torches.color, const Color(0xFFFFAA00));
      expect(ic.lighting.copper.lightType, 'static_light');
      expect(ic.fog.airFogColor, const Color(0xFFAABBCC));
      expect(ic.fog.airFogStart, closeTo(0.35, 1e-3));
      expect(ic.fog.airFogEnd, closeTo(0.92, 1e-3));
      expect(ic.fog.waterFogColor, const Color(0xFF113355));
      expect(ic.fog.waterFogEnd, closeTo(64.0, 1e-3));
      expect(ic.fog.volumetricMaxDensity, closeTo(0.09, 1e-3));
      expect(ic.waterGlobal.causticsPower, 4);
      expect(ic.waterTropical.cdom, closeTo(4.5, 1e-3));
      expect(ic.waterTropical.biomeWaterColorContribution, closeTo(0.72, 1e-3));
      expect(ic.colorGrading.toneMappingOperator, 'aces');
      expect(ic.colorGrading.temperature, closeTo(5800.0, 1e-2));
      expect(ic.surface.metalness, 20);
      expect(ic.surface.roughness, 180);
      expect(ic.performance.styleIntensityLite, isTrue);
    });
  });

  group('4. Simple-Control JSON Diff Report', () {
    test('every Simple control mutates its documented file and JSON path', () {
      final baseSource = _loadBaseArchive();
      const baseCfg = VVShaderConfig(
        exportTarget: VVExportTarget.modern,
        performance: PerformanceTierConfig(
          exportAllTiers: false,
          activeTier: PerformanceTier.high,
        ),
      );
      final baselineArchive = buildArchive(
        baseSource,
        baseCfg,
        packIconBytes: _kDummyPngIcon,
        packUuid: _kTestPackUuid,
        moduleUuid: _kTestModuleUuid,
      );

      final checks = <({
        String control,
        String file,
        String path,
        VVShaderConfig Function(VVShaderConfig c) mutate,
      })>[
        // Sky & Time
        (
          control: 'Sky Horizon Color (Noon)',
          file: 'atmospherics/atmospherics.json',
          path: 'minecraft:atmosphere_settings.sky_horizon_color.0.0',
          mutate: (c) => c.copyWith(
            atmosphere: c.atmosphere.copyWith(noonHorizon: const Color(0xFFFF99CC)),
          ),
        ),
        (
          control: 'Sun Glow (Noon)',
          file: 'atmospherics/atmospherics.json',
          path: 'minecraft:atmosphere_settings.sun_mie_strength.0.0',
          mutate: (c) => c.copyWith(
            atmosphere: c.atmosphere.copyWith(sunGlowNoon: 12.0),
          ),
        ),
        (
          control: 'Moon Glow',
          file: 'atmospherics/atmospherics.json',
          path: 'minecraft:atmosphere_settings.moon_mie_strength.0.5',
          mutate: (c) => c.copyWith(
            atmosphere: c.atmosphere.copyWith(moonGlow: 3.5),
          ),
        ),
        (
          control: 'Horizon Haze',
          file: 'atmospherics/atmospherics.json',
          path: 'minecraft:atmosphere_settings.horizon_blend_stops.start.0.0',
          mutate: (c) => c.copyWith(
            atmosphere: c.atmosphere.withSimpleHorizonHaze(1.5),
          ),
        ),
        (
          control: 'Sky Scattering (Noon Rayleigh)',
          file: 'atmospherics/atmospherics.json',
          path: 'minecraft:atmosphere_settings.rayleigh_strength.0.0',
          mutate: (c) => c.copyWith(
            atmosphere: c.atmosphere.copyWith(rayleighNoon: 5.5),
          ),
        ),
        // Light & Shadows
        (
          control: 'Sunlight Brightness',
          file: 'lighting/global.json',
          path: 'minecraft:lighting_settings.directional_lights.orbital.sun.illuminance.0.0',
          mutate: (c) => c.copyWith(
            lighting: c.lighting.copyWith(sunBrightnessMultiplier: 1.6),
          ),
        ),
        (
          control: 'Sunlight Phase Color (Noon)',
          file: 'lighting/global.json',
          path: 'minecraft:lighting_settings.directional_lights.orbital.sun.color.0.0',
          mutate: (c) => c.copyWith(
            lighting: c.lighting.copyWith(sunColorNoon: const Color(0xFFFFEEAA)),
          ),
        ),
        (
          control: 'Shadow Darkness (sky.intensity)',
          file: 'lighting/global.json',
          path: 'minecraft:lighting_settings.sky.intensity',
          mutate: (c) => c.copyWith(
            lighting: c.lighting.copyWith(skyIntensity: 0.45),
          ),
        ),
        (
          control: 'Cave Ambient Light',
          file: 'lighting/global.json',
          path: 'minecraft:lighting_settings.ambient.illuminance',
          mutate: (c) => c.copyWith(
            lighting: c.lighting.copyWith(ambientIlluminance: 0.25),
          ),
        ),
        (
          control: 'Cave Ambient Tint',
          file: 'lighting/global.json',
          path: 'minecraft:lighting_settings.ambient.color',
          mutate: (c) => c.copyWith(
            lighting: c.lighting.copyWith(ambientColor: const Color(0xFF334466)),
          ),
        ),
        (
          control: 'Orbital Tilt Angle',
          file: 'lighting/global.json',
          path: 'minecraft:lighting_settings.directional_lights.orbital.orbital_offset_degrees',
          mutate: (c) => c.copyWith(
            lighting: c.lighting.copyWith(orbitalOffsetDegrees: 45.0),
          ),
        ),
        (
          control: 'Block Light Color (Torches)',
          file: 'local_lighting/local_lighting.json',
          path: 'minecraft:local_light_settings.minecraft:torch.light_color',
          mutate: (c) => c.copyWith(
            lighting: c.lighting.copyWith(
              torches: c.lighting.torches.copyWith(color: const Color(0xFF12AB34)),
            ),
          ),
        ),
        (
          control: 'Block Light Type (Torches)',
              file: 'local_lighting/local_lighting.json',
              path: 'minecraft:local_light_settings.minecraft:torch.light_type',
              mutate: (c) => c.copyWith(
                lighting: c.lighting.copyWith(
                  torches: c.lighting.torches.copyWith(
                    lightType: 'static_light',
                  ),
                ),
              ),
            ),
            // Fog & Air
            (
              control: 'Air Haze Color',
              file: 'fogs/fog_overworld.json',
              path: 'minecraft:fog_settings.distance.air.fog_color',
              mutate: (c) => c.copyWith(
                fog: c.fog.copyWith(airFogColor: const Color(0xFFCC99EE)),
              ),
            ),
            (
              control: 'Air Haze Start',
              file: 'fogs/fog_overworld.json',
              path: 'minecraft:fog_settings.distance.air.fog_start',
              mutate: (c) => c.copyWith(fog: c.fog.copyWith(airFogStart: 0.25)),
            ),
            (
              control: 'Air Haze End',
              file: 'fogs/fog_overworld.json',
              path: 'minecraft:fog_settings.distance.air.fog_end',
              mutate: (c) => c.copyWith(fog: c.fog.copyWith(airFogEnd: 0.95)),
            ),
            (
              control: 'Ground Fog Density',
              file: 'fogs/fog_overworld.json',
              path: 'minecraft:fog_settings.volumetric.density.air.max_density',
              mutate: (c) =>
                  c.copyWith(fog: c.fog.copyWith(volumetricMaxDensity: 0.14)),
            ),
            (
              control: 'Weather Fog Color',
              file: 'fogs/fog_overworld.json',
              path: 'minecraft:fog_settings.distance.weather.fog_color',
              mutate: (c) => c.copyWith(
                fog: c.fog.copyWith(weatherFogColor: const Color(0xFF334455)),
              ),
            ),
            (
              control: 'Weather Fog End',
              file: 'fogs/fog_overworld.json',
              path: 'minecraft:fog_settings.distance.weather.fog_end',
              mutate: (c) =>
                  c.copyWith(fog: c.fog.copyWith(weatherFogEnd: 0.96)),
            ),
            (
              control: 'Underwater Fog Color',
              file: 'fogs/fog_overworld.json',
              path: 'minecraft:fog_settings.distance.water.fog_color',
              mutate: (c) => c.copyWith(
                fog: c.fog.copyWith(waterFogColor: const Color(0xFF005577)),
              ),
            ),
            (
              control: 'Underwater View Distance',
              file: 'fogs/fog_overworld.json',
              path: 'minecraft:fog_settings.distance.water.fog_end',
              mutate: (c) => c.copyWith(fog: c.fog.copyWith(waterFogEnd: 85.0)),
            ),
            (
              control: 'Cave Water Visibility',
              file: 'fogs/fog_overworld.json',
              path:
                  'minecraft:fog_settings.volumetric.density.water.max_density',
              mutate: (c) =>
                  c.copyWith(fog: c.fog.copyWith(caveWaterVisibility: 0.15)),
            ),
            // Water
            (
              control: 'Waves Enabled',
              file: 'water/water_tropical.json',
              path: 'minecraft:water_settings.waves.enabled',
              mutate: (c) => c.copyWith(
                waterGlobal: c.waterGlobal.copyWith(wavesEnabled: false),
              ),
            ),
            (
              control: 'Underwater Caustics',
              file: 'water/water_tropical.json',
              path: 'minecraft:water_settings.caustics.enabled',
              mutate: (c) => c.copyWith(
                waterGlobal: c.waterGlobal.copyWith(causticsEnabled: false),
              ),
            ),
            (
              control: 'Caustics Shimmer Power',
              file: 'water/water_tropical.json',
              path: 'minecraft:water_settings.caustics.power',
              mutate: (c) => c.copyWith(
                waterGlobal: c.waterGlobal.copyWith(causticsPower: 5),
              ),
            ),
            (
              control: 'Water Clarity',
              file: 'water/water_tropical.json',
              path: 'minecraft:water_settings.particle_concentrations.cdom',
              mutate: (c) =>
                  c.copyWith(waterTropical: c.waterTropical.withClarity(0.2)),
            ),
            (
              control: 'Biome Tint Mix',
              file: 'water/water_tropical.json',
              path: 'minecraft:water_settings.biome_water_color_contribution',
              mutate: (c) =>
                  c.copyWith(waterTropical: c.waterTropical.withTintMix(0.9)),
            ),
            (
              control: 'Wave Height',
              file: 'water/water_tropical.json',
              path: 'minecraft:water_settings.waves.depth',
              mutate: (c) => c.copyWith(
                waterTropical: c.waterTropical.copyWith(wavesDepth: 0.85),
              ),
            ),
            (
              control: 'Wave Speed',
              file: 'water/water_tropical.json',
              path: 'minecraft:water_settings.waves.speed',
              mutate: (c) => c.copyWith(
                waterTropical: c.waterTropical.copyWith(wavesSpeed: 6.5),
              ),
            ),
            // Color & Mood
            (
              control: 'Mood Presets',
              file: 'biomes/plains.client_biome.json',
              path:
                  'minecraft:client_biome.components.minecraft:color_grading_identifier.color_grading_identifier',
              mutate: (c) => c.copyWith(activeMood: 'vibrant'),
            ),
            (
              control: 'Tone Mapping Operator',
              file: 'color_grading/color_grading.json',
              path: 'minecraft:color_grading_settings.tone_mapping.operator',
              mutate: (c) => c.copyWith(
                colorGrading: c.colorGrading.copyWith(
                  toneMappingOperator: 'aces',
                ),
              ),
            ),
            (
              control: 'Color Temperature',
              file: 'color_grading/color_grading.json',
              path:
                  'minecraft:color_grading_settings.color_grading.temperature.temperature',
              mutate: (c) => c.copyWith(
                colorGrading: c.colorGrading.copyWith(temperature: 8800.0),
              ),
            ),
            (
              control: 'Saturation',
              file: 'color_grading/color_grading.json',
              path:
                  'minecraft:color_grading_settings.color_grading.midtones.saturation',
              mutate: (c) => c.copyWith(
                colorGrading: c.colorGrading.withScalars(
                  midtonesSaturation: 1.85,
                ),
              ),
            ),
            (
              control: 'Contrast',
              file: 'color_grading/color_grading.json',
              path:
                  'minecraft:color_grading_settings.color_grading.midtones.contrast',
              mutate: (c) => c.copyWith(
                colorGrading: c.colorGrading.withScalars(midtonesContrast: 2.1),
              ),
            ),
            (
              control: 'Brightness / Gain',
              file: 'color_grading/color_grading.json',
              path:
                  'minecraft:color_grading_settings.color_grading.midtones.gain',
              mutate: (c) => c.copyWith(
                colorGrading: c.colorGrading.withScalars(midtonesGain: 1.75),
              ),
            ),
            // Biomes
            (
              control: 'Biome Global Sky Color',
              file: 'biomes/plains.client_biome.json',
              path:
                  'minecraft:client_biome.components.minecraft:sky_color.sky_color',
              mutate: (c) => c.copyWith(
                biomeOverrides: c.biomeOverrides.copyWith(
                  global: const BiomeAppearanceOverride(
                    skyColor: Color(0xFFFF77AA),
                  ),
                ),
              ),
            ),
            // Surface
            (
              control: 'Global Surface Shininess',
              file: 'pbr/global.json',
              path:
                  'minecraft:pbr_fallback_settings.blocks.global_metalness_emissive_roughness_subsurface',
              mutate: (c) =>
                  c.copyWith(surface: SurfaceConfig.fromShininess(0.75)),
            ),
            (
              control: 'Shadow Style',
              file: 'shadows/global.json',
              path: 'minecraft:shadow_settings.shadow_style',
              mutate: (c) => c.copyWith(
                lighting: c.lighting.copyWith(shadowStyle: 'blocky_shadows'),
              ),
            ),
            // Performance
            (
              control: 'Active Root Tier (Shadows)',
              file: 'shadows/global.json',
              path: 'minecraft:shadow_settings.texel_size',
              mutate: (c) => c.copyWith(
                performance: c.performance.copyWith(
                  activeTier: PerformanceTier.low,
                ),
              ),
            ),
            (
              control: 'Style Intensity: Lite Subpack',
              file: 'manifest.json',
              path: 'subpacks',
              mutate: (c) => c.copyWith(
                performance: c.performance.copyWith(styleIntensityLite: true),
              ),
            ),
            // Export
            (
              control: 'Pack Name',
              file: 'manifest.json',
              path: 'header.name',
              mutate: (c) => c.copyWith(packName: 'Mutated Shader Pack'),
            ),
            (
              control: 'Pack Description',
              file: 'manifest.json',
              path: 'header.description',
              mutate: (c) =>
                  c.copyWith(packDescription: 'Mutated VV Description'),
            ),
            (
              control: 'Pack Version',
              file: 'manifest.json',
              path: 'header.version',
              mutate: (c) => c.copyWith(packVersion: [3, 2, 1]),
            ),
          ];

      for (final item in checks) {
        final mutatedCfg = item.mutate(baseCfg);
        final mutatedArchive = buildArchive(
          _loadBaseArchive(),
          mutatedCfg,
          packIconBytes: _kDummyPngIcon,
          packUuid: _kTestPackUuid,
          moduleUuid: _kTestModuleUuid,
        );

        final beforeJson = _readArchiveJson(baselineArchive, item.file);
        final afterJson = _readArchiveJson(mutatedArchive, item.file);

        final beforeVal = _jsonPath(beforeJson, item.path);
        final afterVal = _jsonPath(afterJson, item.path);

        expect(
          afterVal,
          isNotNull,
          reason: '${item.control} -> ${item.file} :: ${item.path} missing',
        );
        expect(
          jsonEncode(afterVal),
          isNot(equals(jsonEncode(beforeVal))),
          reason: '${item.control} did not change ${item.file} :: ${item.path}',
        );

        // ignore: avoid_print
        print('[DIFF] ${item.control} -> ${item.file} :: ${item.path}');
      }
    });
  });
}
