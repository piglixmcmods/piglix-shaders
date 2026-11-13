import 'dart:convert';
import 'dart:io';
import 'package:archive/archive.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:piglix_shader_builder/shader_compiler.dart';

Archive _loadBaseArchive() {
  final bytes = File('assets/base_shader.zip').readAsBytesSync();
  return ZipDecoder().decodeBytes(bytes);
}

Map<String, dynamic> _readJson(Archive archive, String path) {
  final file = archive.findFile(path);
  expect(file, isNotNull, reason: 'Expected $path in compiled archive');
  final raw = ShaderPackCompiler.cleanJsonComments(
    utf8.decode(file!.content as List<int>),
  );
  return jsonDecode(raw) as Map<String, dynamic>;
}

void main() {
  group('ShaderPackCompiler production verification', () {
    test('preserves Nether and End dimension configs unchanged', () {
      final base = _loadBaseArchive();
      const nonOverworldFiles = [
        'lighting/hell_lighting.json',
        'lighting/end_lighting.json',
        'atmospherics/hell_atmosphere.json',
        'atmospherics/end_atmosphere.json',
        'fogs/hell.json',
        'fogs/end.json',
        'biomes/hell.client_biome.json',
        'biomes/the_end.client_biome.json',
      ];
      final before = {
        for (final p in nonOverworldFiles) p: base.findFile(p)!.content,
      };

      const cfg = ShaderBuildConfig(
        packName: 'Custom Overworld Pack',
        noonColor: Color(0xFF123456),
        waterColor: Color(0xFF00E5FF),
        rainFogColor: Color(0xFF556677),
        thunderColor: Color(0xFF112233),
      );
      final compiled = ShaderPackCompiler.compileArchive(
        base,
        cfg,
        packIconBytes: const [1, 2, 3],
        packUuid: '11111111-1111-1111-1111-111111111111',
        moduleUuid: '22222222-2222-2222-2222-222222222222',
      );

      for (final p in nonOverworldFiles) {
        expect(
          compiled.findFile(p)!.content,
          equals(before[p]),
          reason:
              '$p must stay dimension-native and not get Overworld overrides',
        );
      }
    });

    test(
      'wires Atmosphere, Lighting, Water, Biomes, Weather, Shadows, PBR & Post-FX',
      () {
        final base = _loadBaseArchive();
        const cfg = ShaderBuildConfig(
          packName: 'Sakura Test Shader',
          morningColor: Color(0xFFFF90B0),
          noonColor: Color(0xFF4488FF),
          eveningColor: Color(0xFFFF5511),
          nightColor: Color(0xFF081430),
          cloudTopColor: Color(0xFFFFDDE6),
          cloudBottomColor: Color(0xFF667788),
          sunRayIntensity: 1.8,
          volumetricRays: 'Heavy',
          sunlightColor: Color(0xFFFFE8A0),
          rayNoonColor: Color(0xFFFFFFFF),
          torchLightColor: Color(0xFFFF8800),
          soulLightColor: Color(0xFF00FFFF),
          caveAmbientColor: Color(0xFF142238),
          caveAmbientBrightness: 1.5,
          ambientBounce: 1.4,
          emissiveGlow: 1.6,
          sunOrbitTilt: 60.0,
          shadowQuality: 'Ultra',
          syncWarmBlocks: false,
          syncMysticBlocks: true,
          waterColor: Color(0xFF00D0FF),
          deepOceanColor: Color(0xFF002266),
          swampWaterColor: Color(0xFF335522),
          underwaterFogColor: Color(0xFF082438),
          waveAmplitude: 1.6,
          waterSpecularGlint: 1.8,
          underwaterVisibility: 1.7,
          shorelineFoam: 1.5,
          swampTurbidity: 1.4,
          biomeWaterTint: true,
          lightningIntensity: 2.0,
          thunderColor: Color(0xFF3344AA),
          snowFogColor: Color(0xFFD0E8FF),
          snowFogDensity: 1.5,
          coldSkyTint: 1.5,
          wetSurfaceGloss: 1.6,
          puddleReflections: true,
          worldReflectionsEnabled: true,
          globalMetalness: 0.25,
          frostShimmer: 1.5,
          toneMapFilter: 'Cool',
          biomeTone: 'Vibrant',
          bloomIntensity: 1.6,
          globalSaturation: 1.3,
          contrast: 1.25,
          autoExposure: 1.2,
        );

        final compiled = ShaderPackCompiler.compileArchive(
          base,
          cfg,
          packIconBytes: const [9, 8, 7],
          packUuid: 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa',
          moduleUuid: 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb',
        );

        // Local lighting
        final localLight = _readJson(
          compiled,
          'local_lighting/local_lighting.json',
        );
        final llColors =
            localLight['minecraft:local_light_settings']['colors']
                as Map<String, dynamic>;
        expect(llColors['minecraft:torch'], '#ff8800');
        expect(llColors['minecraft:soul_torch'], '#00ffff');
        expect(llColors.containsKey('minecraft:redstone_torch'), isFalse);
        expect(llColors['minecraft:sea_lantern'], '#00ffff');

        // Directional, ambient, flash, emissive, tilt
        final lighting = _readJson(compiled, 'lighting/global.json');
        final ls =
            lighting['minecraft:lighting_settings'] as Map<String, dynamic>;
        final dl = ls['directional_lights'] as Map<String, dynamic>;
        expect(dl['flash']['illuminance'], closeTo(28.0, 0.01));
        expect(dl['flash']['color'], [0x33, 0x44, 0xAA]);
        expect(dl['orbital']['orbital_offset_degrees']['0.000000'], 60.0);
        expect(ls['ambient']['color'], [0x14, 0x22, 0x38]);
        expect(ls['ambient']['illuminance'], closeTo(0.105, 0.001));
        expect(ls['sky']['intensity'], closeTo(0.42, 0.001));
        expect(
          (ls['emissive']['desaturation'] as num).toDouble(),
          lessThan(0.25),
        );

        // Water & Swamp
        final water = _readJson(compiled, 'water/water.json');
        final ws = water['minecraft:water_settings'] as Map<String, dynamic>;
        expect((ws['waves']['depth'] as num).toDouble(), greaterThan(0.1));
        expect(
          (ws['caustics']['power'] as num).toDouble(),
          closeTo(2.43, 0.02),
        );
        final swampWater = _readJson(compiled, 'water/swamp_water.json');
        expect(
          swampWater['minecraft:water_settings']['particle_concentrations']['cdom'],
          closeTo(9.52, 0.05),
        );

        // Biome adaptive water
        final deepOceanBiome = _readJson(
          compiled,
          'biomes/deep_ocean.client_biome.json',
        );
        expect(
          deepOceanBiome['minecraft:client_biome']['components']['minecraft:water_appearance']['surface_color'],
          '#002266',
        );
        final swampBiome = _readJson(
          compiled,
          'biomes/swampland.client_biome.json',
        );
        expect(
          swampBiome['minecraft:client_biome']['components']['minecraft:water_appearance']['surface_color'],
          '#335522',
        );

        // Underwater fog uses underwaterFogColor, NOT lavender or rainWaterColor
        final plainsFog = _readJson(compiled, 'fogs/plains.json');
        final pDist = plainsFog['minecraft:fog_settings']['distance'];
        expect(pDist['water']['fog_color'], '#082438');
        expect(pDist['water']['fog_end'], closeTo(76.5, 0.1));
        expect(pDist['air']['fog_color'], isNot('#c0bce6'));

        // Snow fog honors snowFogColor & snowFogDensity
        final snowFog = _readJson(compiled, 'fogs/snow.json');
        final sWeather =
            snowFog['minecraft:fog_settings']['volumetric']['density']['weather'];
        expect(
          (sWeather['max_density'] as num).toDouble(),
          closeTo(0.45, 0.01),
        );

        // Atmospherics honors sunRayIntensity
        final atm = _readJson(compiled, 'atmospherics/atmospherics.json');
        final aSet = atm['minecraft:atmosphere_settings'];
        expect(aSet['sun_mie_strength']['0.000000'], closeTo(10.8, 0.05));

        // Shadows valid schema
        final shadows = _readJson(compiled, 'shadows/global.json');
        final shSet =
            shadows['minecraft:shadow_settings'] as Map<String, dynamic>;
        expect(shSet['shadow_style'], 'soft_shadows');
        expect(shSet['texel_size'], 2048);
        expect(shSet.containsKey('point_light_shadows'), isFalse);

        // PBR fallback wet gloss & metalness
        final pbr = _readJson(compiled, 'pbr/global.json');
        final blkMer =
            pbr['minecraft:pog_fallback_settings']['blocks']['global_metalness_emissive_roughness_subsurface']
                as List<dynamic>;
        expect(blkMer[0], 64);
        expect((blkMer[2] as int), lessThan(85));

        // Color grading Cool + Vibrant temp shift & bloom gain
        final cg = _readJson(compiled, 'color_grading/color_grading.json');
        final cgs = cg['minecraft:color_grading_settings'];
        expect(cgs['temperature']['temperature'], closeTo(6950.0, 0.1));
        final hiGain =
            cgs['color_grading']['highlights']['gain'] as List<dynamic>;
        expect((hiGain[0] as num).toDouble(), greaterThan(1.5));

        // Manifest & en_US.lang
        final manifest = _readJson(compiled, 'manifest.json');
        expect(manifest['header']['name'], 'Sakura Test Shader');
        expect(manifest['header']['min_engine_version'], [1, 21, 80]);
      },
    );

    test(
      'disables volumetric god rays and selects blocky_shadows when set Off',
      () {
        final base = _loadBaseArchive();
        const cfg = ShaderBuildConfig(
          packName: 'Vanilla Crisp Test',
          shadowQuality: 'Off',
          volumetricRays: 'Off',
          biomeWaterTint: false,
          waterColor: Color(0xFF11AAFF),
          deepOceanColor: Color(0xFF001122),
        );
        final compiled = ShaderPackCompiler.compileArchive(
          base,
          cfg,
          packIconBytes: const [1],
          packUuid: 'u1',
          moduleUuid: 'u2',
        );
        final shadows = _readJson(compiled, 'shadows/global.json');
        expect(
          shadows['minecraft:shadow_settings']['shadow_style'],
          'blocky_shadows',
        );
        expect(shadows['minecraft:shadow_settings']['texel_size'], 16);

        final atm = _readJson(compiled, 'atmospherics/atmospherics.json');
        expect(
          atm['minecraft:atmosphere_settings']['sun_mie_strength']['0.000000'],
          0.0,
        );

        final deepOceanBiome = _readJson(
          compiled,
          'biomes/deep_ocean.client_biome.json',
        );
        expect(
          deepOceanBiome['minecraft:client_biome']['components']['minecraft:water_appearance']['surface_color'],
          '#11aaff',
        );
      },
    );
  });
}
