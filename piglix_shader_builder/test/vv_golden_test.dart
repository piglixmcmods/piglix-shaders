import 'package:flutter_test/flutter_test.dart';
import 'package:piglix_shader_builder/vv_config.dart';
import 'package:piglix_shader_builder/vv_biomes.dart';
import 'package:piglix_shader_builder/vv_generator.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Vibrant Visuals Golden Schema Verification', () {
    late VVShaderConfig defaultCfg;

    setUp(() {
      defaultCfg = const VVShaderConfig(
        packName: 'Piglix Shader',
        packDescription: 'Piglix Vibrant Visuals · Bedrock Deferred PBR Shader',
        packVersion: [1, 0, 0],
      );
    });

    test('1. manifest.json conforms to Bedrock V2 schema', () {
      final subpacks = [
        {'folder_name': 'low', 'name': 'Low (Performance)', 'memory_tier': 6},
        {'folder_name': 'medium', 'name': 'Medium (Balanced)', 'memory_tier': 12},
        {'folder_name': 'high', 'name': 'High (Quality)', 'memory_tier': 18},
        {'folder_name': 'ultra', 'name': 'Ultra (Cinematic)', 'memory_tier': 32},
        {'folder_name': 'lite', 'name': 'Lite Style', 'memory_tier': 1},
      ];
      final manifest = generateManifest(
        defaultCfg,
        'a0000000-0000-4000-8000-000000000001',
        'a0000000-0000-4000-8000-000000000002',
        subpacks: subpacks,
      );
      expect(manifest['format_version'], 2);
      final header = manifest['header'] as Map<String, dynamic>;
      expect(header['name'], 'Piglix Shader');
      expect(header['min_engine_version'], [1, 21, 120]);
      expect(header['uuid'], isA<String>());
      expect(manifest['capabilities'], contains('pbr'));

      // Check subpacks
      final spList = manifest['subpacks'] as List;
      expect(spList.length, 5);
      final lowSp = spList.first as Map<String, dynamic>;
      expect(lowSp['folder_name'], 'low');
      expect(lowSp['memory_tier'], 6);
      expect(lowSp.containsKey('memory_performance_tier'), isFalse);
    });

    test('2. atmospherics/atmospherics.json conforms to 1.21.40 schema', () {
      final atmo = generateAtmospherics(defaultCfg);
      expect(atmo['format_version'], '1.21.40');
      final settings = atmo['minecraft:atmosphere_settings'] as Map<String, dynamic>;
      expect(settings['description']['identifier'], 'piglix_shader:global_atmosphere');

      final zenith = settings['sky_zenith_color'] as Map<String, dynamic>;
      final horizon = settings['sky_horizon_color'] as Map<String, dynamic>;
      final rayleigh = settings['rayleigh_strength'] as Map<String, dynamic>;
      final sunMie = settings['sun_mie_strength'] as Map<String, dynamic>;
      final moonMie = settings['moon_mie_strength'] as Map<String, dynamic>;
      final stops = settings['horizon_blend_stops'] as Map<String, dynamic>;

      // Normalized keyframes
      expect(zenith.containsKey('0.0'), isTrue);
      expect(zenith.containsKey('1.0'), isTrue);
      expect(horizon.containsKey('0.0'), isTrue);
      expect(rayleigh.containsKey('0.0'), isTrue);
      expect(sunMie.containsKey('0.0'), isTrue);
      expect(zenith.containsKey('0.000000'), isFalse);
      expect(zenith.containsKey('0.0'), isTrue);
      expect(zenith.containsKey('1.0'), isTrue);
      expect(zenith.containsKey('0.000000'), isFalse);

      // Moon mie day ramp: 0.0 at day (0.0..0.25), full at night (0.5), 0.0 at 1.0
      expect(moonMie['0.0'], 0.0);
      expect(moonMie['0.5'], defaultCfg.atmosphere.moonGlow);
      expect(moonMie['1.0'], 0.0);

      expect(stops['min'], isA<Map>());
      expect(stops['start'], isA<Map>());
      expect(stops['mie_start'], isA<Map>());
      expect(stops['max'], isA<Map>());
    });

    test('3. lighting/global.json conforms to 1.21.80 schema', () {
      final lighting = generateLighting(defaultCfg);
      expect(lighting['format_version'], '1.21.80');
      final s = lighting['minecraft:lighting_settings'] as Map<String, dynamic>;
      expect(s['description']['identifier'], 'piglix_shader:global');

      final orbital = s['directional_lights']['orbital'] as Map<String, dynamic>;
      expect(orbital['orbital_offset_degrees'], 3.0);

      final sun = orbital['sun'] as Map<String, dynamic>;
      final sunIllum = sun['illuminance'] as Map<String, dynamic>;
      expect(sunIllum['0.0'], closeTo(109880.0, 1e-2));
      expect(sunIllum['0.35'], 0.0);
      expect(sunIllum['0.5'], 0.0);
      expect(sunIllum['0.65'], 0.0);
      expect(sunIllum['1.0'], closeTo(109880.0, 1e-2));

      final sunColor = sun['color'] as Map<String, dynamic>;
      expect(sunColor.containsKey('0.0'), isTrue);
      expect(sunColor.containsKey('1.0'), isTrue);

      final emissive = s['emissive'] as Map<String, dynamic>;
      expect(emissive['desaturation'], 0.1);

      final sky = s['sky'] as Map<String, dynamic>;
      expect(sky['intensity'], 1.0);
    });

    test('4. water/*.json contains ONLY minecraft:water_settings valid fields', () {
      final presets = [
        defaultCfg.waterTropical,
        defaultCfg.waterOcean,
        defaultCfg.waterDeepOcean,
        defaultCfg.waterRiver,
        defaultCfg.waterSwamp,
      ];

      for (final p in presets) {
        final w = generateWater(p, packSlug: 'piglix_shader', global: defaultCfg.waterGlobal);
        expect(w['format_version'], '1.21.80');
        final ws = w['minecraft:water_settings'] as Map<String, dynamic>;

        // Must contain only description, particle_concentrations, caustics, waves
        expect(ws.keys, unorderedEquals(['description', 'particle_concentrations', 'caustics', 'waves']));
        expect(ws.containsKey('surface_color'), isFalse);
        expect(ws.containsKey('deep_color'), isFalse);

        final caustics = ws['caustics'] as Map<String, dynamic>;
        expect(caustics['power'], inInclusiveRange(1, 6));
        expect(caustics['enabled'], isTrue);

        final waves = ws['waves'] as Map<String, dynamic>;
        expect(waves['depth'], inInclusiveRange(0.0, 3.0));
      }
    });

    test('5. fogs/fog_overworld.json conforms to 1.21.90 schema', () {
      final fog = generateFog(defaultCfg, 'fog_overworld');
      expect(fog['format_version'], '1.21.90');
      final fs = fog['minecraft:fog_settings'] as Map<String, dynamic>;
      expect(fs['description']['identifier'], 'piglix_shader:fog_overworld');

      final distance = fs['distance'] as Map<String, dynamic>;
      expect(distance['air']['render_distance_type'], 'render');
      expect(distance['water']['render_distance_type'], 'fixed');
      expect(distance['weather']['render_distance_type'], 'render');

      final vol = fs['volumetric'] as Map<String, dynamic>;
      final density = vol['density'] as Map<String, dynamic>;
      expect(density['air']['zero_density_height'], isA<num>());
      expect(density['air']['max_density_height'], isA<num>());
    });

    test('6. shadows/global.json conforms to 1.21.80 schema', () {
      final shadow = generateShadows(defaultCfg);
      expect(shadow['format_version'], '1.21.80');
      final ss = shadow['minecraft:shadow_settings'] as Map<String, dynamic>;
      expect(ss['shadow_style'], 'soft_shadows');
      expect(ss['texel_size'], 16);
    });

    test('7. pbr/global.json conforms to 1.21.80 fallback schema', () {
      final pbr = generatePbr(defaultCfg);
      expect(pbr['format_version'], '1.21.40');
      final ps = pbr['minecraft:pbr_fallback_settings'] as Map<String, dynamic>;
      final mers = ps['blocks']['global_metalness_emissive_roughness_subsurface'] as List;
      expect(mers, [0, 0, 255, 0]);
      expect(ps['actors']['global_metalness_emissive_roughness_subsurface'], [0, 0, 255, 0]);
      expect(ps['particles']['global_metalness_emissive_roughness_subsurface'], [0, 0, 255, 0]);
      expect(ps['items']['global_metalness_emissive_roughness_subsurface'], [0, 0, 255, 0]);
    });

    test('8. color_grading/color_grading.json conforms to 1.21.90 schema', () {
      final cg = generateColorGrading(defaultCfg.colorGrading, 'piglix_shader:color_grading');
      expect(cg['format_version'], '1.21.90');
      final cgs = cg['minecraft:color_grading_settings'] as Map<String, dynamic>;
      expect(cgs['color_grading']['temperature']['enabled'], isA<bool>());
      expect(cgs['tone_mapping']['operator'], 'hable');
    });

    test('9. local_lighting/local_lighting.json enforces valid Bedrock block IDs and point/static split', () {
      final ll = generateLocalLighting(defaultCfg);
      expect(ll['format_version'], '1.21.120');
      final blocks = ll['minecraft:local_light_settings'] as Map<String, dynamic>;

      // Check torches
      expect(blocks.containsKey('minecraft:torch'), isTrue);
      expect(blocks.containsKey('minecraft:wall_torch'), isFalse);

      // Check Soul group split:
      // soul_torch and soul_lantern may be point_light
      expect(blocks['minecraft:soul_torch']['light_type'], 'point_light');
      expect(blocks['minecraft:soul_lantern']['light_type'], 'point_light');

      // soul_fire, soul_campfire, crying_obsidian, respawn_anchor must be static_light
      expect(blocks['minecraft:soul_fire']['light_type'], 'static_light');
      expect(blocks['minecraft:soul_campfire']['light_type'], 'static_light');
      expect(blocks['minecraft:crying_obsidian']['light_type'], 'static_light');
      expect(blocks['minecraft:respawn_anchor']['light_type'], 'static_light');

      // Area emitters: copper_bulb must be static_light
      expect(blocks['minecraft:copper_bulb']['light_type'], 'static_light');
    });

    test('10. Client biomes plains, hell, the_end preserve vanilla sky_color and assign VV IDs', () {
      final plains = kVanillaBiomeById['plains']!;
      final hell = kVanillaBiomeById['hell']!;
      final theEnd = kVanillaBiomeById['the_end']!;

      final plainsJson = generateClientBiome(plains, defaultCfg);
      final hellJson = generateClientBiome(hell, defaultCfg);
      final endJson = generateClientBiome(theEnd, defaultCfg);

      final plainsComps = plainsJson['minecraft:client_biome']['components'] as Map<String, dynamic>;
      final hellComps = hellJson['minecraft:client_biome']['components'] as Map<String, dynamic>;
      final endComps = endJson['minecraft:client_biome']['components'] as Map<String, dynamic>;

      // #78: Plains (Overworld) must NOT inject synthetic sky_color
      expect(plainsComps.containsKey('minecraft:sky_color'), isFalse);

      // #78: The End must keep vanilla sky_color (#000000)
      expect(endComps['minecraft:sky_color']['sky_color'], '#000000');

      // All 3 have valid VV identifiers
      expect(plainsComps['minecraft:atmosphere_identifier']['atmosphere_identifier'], 'piglix_shader:global_atmosphere');
      expect(hellComps['minecraft:atmosphere_identifier']['atmosphere_identifier'], 'piglix_shader:hell_atmosphere');
      expect(endComps['minecraft:atmosphere_identifier']['atmosphere_identifier'], 'piglix_shader:end_atmosphere');

      // Water appearance surface_color in client biome
      expect(
        (plainsComps['minecraft:water_appearance']['surface_color'] as String).toLowerCase(),
        '#44aff5',
      );
      expect(
        (endComps['minecraft:water_appearance']['surface_color'] as String).toLowerCase(),
        '#62529e',
      );
    });
  });
}
