import 'dart:io';
import 'package:archive/archive.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:piglix_shader_builder/vv_config.dart';
import 'package:piglix_shader_builder/vv_generator.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('Export default pack into /out/default_pack', () async {
    const cfg = VVShaderConfig(
      packName: 'Piglix Shader',
      packDescription: 'Piglix Vibrant Visuals · Bedrock Deferred PBR Shader',
      packVersion: [1, 0, 0],
    );

    final outDir = Directory('/Users/sopanvijaypatil/Downloads/Newb_X_Pink_Atmosphere_android/out/default_pack');
    if (outDir.existsSync()) {
      outDir.deleteSync(recursive: true);
    }
    outDir.createSync(recursive: true);

    final zipBytes = File('assets/base_shader.zip').readAsBytesSync();
    final baseArchive = ZipDecoder().decodeBytes(zipBytes);

    List<int> iconBytes;
    final iconFile = File('assets/pack_icon.png');
    if (iconFile.existsSync()) {
      iconBytes = iconFile.readAsBytesSync();
    } else {
      iconBytes = [
        0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A, 0x00, 0x00, 0x00, 0x0D,
        0x49, 0x48, 0x44, 0x52, 0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x01,
        0x08, 0x06, 0x00, 0x00, 0x00, 0x1F, 0x15, 0xC4, 0x89, 0x00, 0x00, 0x00,
        0x0A, 0x49, 0x44, 0x41, 0x54, 0x78, 0x9C, 0x63, 0x00, 0x01, 0x00, 0x00,
        0x05, 0x00, 0x01, 0x0D, 0x0A, 0x2D, 0xB4, 0x00, 0x00, 0x00, 0x00, 0x49,
        0x45, 0x4E, 0x44, 0xAE, 0x42, 0x60, 0x82,
      ];
    }

    final archive = buildArchive(
      baseArchive,
      cfg,
      packIconBytes: iconBytes,
      packUuid: '4054afec-8939-4586-bdab-e6dc56be1bbd',
      moduleUuid: '7c89f5bc-2234-45e8-9abc-f01234567890',
    );

    for (final file in archive) {
      if (file.isFile) {
        final filePath = '${outDir.path}/${file.name}';
        final f = File(filePath);
        f.parent.createSync(recursive: true);
        f.writeAsBytesSync(file.content as List<int>);
      }
    }

    // ignore: avoid_print
    print('Successfully exported ${archive.length} files into ${outDir.path}');
  });
}
