// Real dart:io implementation — used on Android, iOS, Desktop
import 'dart:io' as io;
import 'package:path_provider/path_provider.dart';

Future<String?> getNativeDownloadPath() async {
  try {
    final downloadDir = io.Directory('/storage/emulated/0/Download');
    if (await downloadDir.exists()) return downloadDir.path;
    final dir = await getExternalStorageDirectory();
    return dir?.path;
  } catch (_) {
    return null;
  }
}

Future<void> writeNativeFile(String path, List<int> bytes) async {
  await io.File(path).writeAsBytes(bytes);
}

Future<String> getNativeTempPath() async {
  final dir = await getTemporaryDirectory();
  return dir.path;
}
