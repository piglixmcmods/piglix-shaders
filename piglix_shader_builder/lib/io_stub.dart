// Web stub — these functions are never called on web (guarded by kIsWeb checks)
// but must exist so the conditional import compiles on the web target.

Future<String?> getNativeDownloadPath() async => null;

Future<void> writeNativeFile(String path, List<int> bytes) async {}

Future<String> getNativeTempPath() async => '';
