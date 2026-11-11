// Real dart:io implementation — used on Android, iOS, Desktop
import 'dart:io' as io;
import 'package:path_provider/path_provider.dart';

Future<String?> getNativeDownloadPath() async {
  try {
    final dir = await getExternalStorageDirectory() ?? await getApplicationDocumentsDirectory();
    return dir.path;
  } catch (_) {
    return null;
  }
}

Future<void> writeNativeFile(String path, List<int> bytes) async {
  final file = io.File(path);
  if (!await file.parent.exists()) {
    await file.parent.create(recursive: true);
  }
  await file.writeAsBytes(bytes, flush: true);
}

Future<List<int>?> readNativeFile(String path) async {
  try {
    final file = io.File(path);
    if (await file.exists()) {
      return await file.readAsBytes();
    }
  } catch (_) {}
  return null;
}

List<int>? readNativeFileSync(String path) {
  try {
    final file = io.File(path);
    if (file.existsSync()) {
      return file.readAsBytesSync();
    }
  } catch (_) {}
  return null;
}

Future<bool> deleteNativeFile(String path) async {
  try {
    final file = io.File(path);
    if (await file.exists()) {
      await file.delete();
      return true;
    }
  } catch (_) {}
  return false;
}

Future<String?> readNativeString(String path) async {
  try {
    final file = io.File(path);
    if (await file.exists()) {
      return await file.readAsString();
    }
  } catch (_) {}
  return null;
}

Future<void> writeNativeString(String path, String content) async {
  final file = io.File(path);
  if (!await file.parent.exists()) {
    await file.parent.create(recursive: true);
  }
  await file.writeAsString(content, flush: true);
}

Future<String> getShadersDirectoryPath() async {
  final dir = await getApplicationDocumentsDirectory();
  final sDir = io.Directory('${dir.path}/piglix_saved_shaders');
  if (!await sDir.exists()) {
    await sDir.create(recursive: true);
  }
  return sDir.path;
}

Future<String> getNativeTempPath() async {
  final dir = await getTemporaryDirectory();
  return dir.path;
}

class NativePackFileInfo {
  final String path;
  final String name;
  final int byteSize;
  final DateTime modified;
  NativePackFileInfo({
    required this.path,
    required this.name,
    required this.byteSize,
    required this.modified,
  });
}

Future<List<NativePackFileInfo>> listNativePacks(String dirPath) async {
  try {
    final dir = io.Directory(dirPath);
    if (!await dir.exists()) return [];
    final entities = await dir.list().toList();
    final result = <NativePackFileInfo>[];
    for (final e in entities) {
      if (e is io.File && e.path.endsWith('.mcpack')) {
        final stat = await e.stat();
        final rawName = e.uri.pathSegments.isNotEmpty ? e.uri.pathSegments.last : 'Piglix Shader';
        final cleanName = rawName.replaceAll('.mcpack', '').replaceAll('shader_', '').replaceAll('_', ' ');
        result.add(
          NativePackFileInfo(
            path: e.path,
            name: cleanName.isEmpty ? 'Piglix Shader' : cleanName,
            byteSize: stat.size,
            modified: stat.modified,
          ),
        );
      }
    }
    return result;
  } catch (e) {
    return [];
  }
}
