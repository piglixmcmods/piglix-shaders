// Web stub — these functions are never called on web (guarded by kIsWeb checks)
// but must exist so the conditional import compiles on the web target.

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

Future<String?> getNativeDownloadPath() async => null;

Future<void> writeNativeFile(String path, List<int> bytes) async {}

Future<List<int>?> readNativeFile(String path) async => null;

List<int>? readNativeFileSync(String path) => null;

Future<bool> deleteNativeFile(String path) async => false;

Future<String?> readNativeString(String path) async => null;

Future<void> writeNativeString(String path, String content) async {}

Future<String> getShadersDirectoryPath() async => 'piglix_saved_shaders';

Future<String> getNativeTempPath() async => '';

Future<List<NativePackFileInfo>> listNativePacks(String dirPath) async => [];
