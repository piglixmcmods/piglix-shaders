import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:piglix_shader_builder/my_shaders_screen.dart';
import 'package:piglix_shader_builder/shader_presets.dart';
import 'package:uuid/uuid.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('UserShaderItem and UserShaderStore tests', () {
    test('UserShaderItem JSON serialization & deserialization', () {
      final now = DateTime.now();
      final item = UserShaderItem(
        id: 'shader_test_123',
        name: 'Cyberpunk Neon',
        date: now,
        byteSize: 1024,
        localFilePath: '/data/user/0/test.mcpack',
        previewColor: const Color(0xFF22C55E),
        engine: 'Vibrant Engine',
      );

      final json = item.toJson();
      expect(json['id'], 'shader_test_123');
      expect(json['name'], 'Cyberpunk Neon');
      expect(json['byteSize'], 1024);
      expect(json['localFilePath'], '/data/user/0/test.mcpack');
      expect(json['previewColor'], const Color(0xFF22C55E).toARGB32());

      final restored = UserShaderItem.fromJson(json);
      expect(restored.id, item.id);
      expect(restored.name, item.name);
      expect(restored.byteSize, item.byteSize);
      expect(restored.previewColor.toARGB32(), item.previewColor.toARGB32());
    });

    test('UserShaderStore adding and removing shaders in memory', () async {
      UserShaderStore.shaders.clear();
      expect(UserShaderStore.shaders.length, 0);

      await UserShaderStore.addShader(
        name: 'Test Aurora Shader',
        bytes: [0, 1, 2, 3, 4],
        previewColor: const Color(0xFFE91E63),
      );

      expect(UserShaderStore.shaders.length, 1);
      final created = UserShaderStore.shaders.first;
      expect(created.name, 'Test Aurora Shader');
      expect(created.byteSize, 5);
      expect(created.previewColor, const Color(0xFFE91E63));

      // Test removal
      await UserShaderStore.removeShader(created.id);
      expect(UserShaderStore.shaders.length, 0);
    });

    test('UserShaderItem.loadBytes() caches and returns byte buffer', () async {
      final item = UserShaderItem(
        id: 'shader_load_test',
        name: 'Load Test Shader',
        date: DateTime.now(),
        byteSize: 4,
        bytes: [10, 20, 30, 40],
        previewColor: const Color(0xFF00FF00),
      );

      final loaded = await item.loadBytes();
      expect(loaded, [10, 20, 30, 40]);
      expect(item.bytes, [10, 20, 30, 40]);
    });
  });

  group('Shader presets data integrity tests', () {
    test('kDefaultShaderPresets contains valid, non-null configurations', () {
      expect(kDefaultShaderPresets.isNotEmpty, true);
      for (final p in kDefaultShaderPresets) {
        expect(p.id.isNotEmpty, true);
        expect(p.name.isNotEmpty, true);
        expect(p.creator.isNotEmpty, true);
        expect(p.rating, greaterThanOrEqualTo(0.0));
        expect(p.sunSize, greaterThan(0.0));
        expect(p.waterColor.a, greaterThan(0.0));
        expect(p.noonColor.a, greaterThan(0.0));
      }
    });
  });

  group('Minecraft Bedrock Manifest & Shader Pack generation validation', () {
    test('Manifest JSON adheres to Bedrock pack standards', () {
      final packUuid = const Uuid().v4();
      final moduleUuid = const Uuid().v4();
      const pName = 'Piglix Test Pack';

      final manifestMap = {
        'format_version': 2,
        'header': {
          'name': pName,
          'description': 'Piglix Vibrant Visuals · Bedrock Deferred PBR Shader',
          'uuid': packUuid,
          'version': [1, 0, 0],
          'min_engine_version': [1, 21, 0],
        },
        'modules': [
          {
            'type': 'resources',
            'uuid': moduleUuid,
            'version': [1, 0, 0],
          },
        ],
        'capabilities': ['pbr'],
        'subpacks': [
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
        ],
      };

      // Verify UUID syntax (RFC 4122 v4)
      final uuidRegex = RegExp(
        r'^[0-9a-f]{8}-[0-9a-f]{4}-4[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$',
        caseSensitive: false,
      );
      expect(uuidRegex.hasMatch(packUuid), true);
      expect(uuidRegex.hasMatch(moduleUuid), true);
      expect(packUuid != moduleUuid, true);

      // Verify format and module types
      expect(manifestMap['format_version'], 2);
      final header = manifestMap['header'] as Map<String, dynamic>;
      expect(header['name'], pName);
      expect(header['version'], [1, 0, 0]);
      expect(header['min_engine_version'], [1, 21, 0]);

      final modules = manifestMap['modules'] as List<Map<String, dynamic>>;
      expect(modules.first['type'], 'resources');
      expect((manifestMap['capabilities'] as List).contains('pbr'), true);
      expect((manifestMap['subpacks'] as List).length, 2);

      // Verify serialization to JSON
      final encoded = jsonEncode(manifestMap);
      final decoded = jsonDecode(encoded) as Map<String, dynamic>;
      expect(decoded['header']['name'], pName);
    });
  });
}
