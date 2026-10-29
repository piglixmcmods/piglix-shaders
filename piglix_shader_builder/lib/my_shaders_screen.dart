import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:universal_html/html.dart' as html;
import 'package:file_saver/file_saver.dart';
import 'package:file_picker/file_picker.dart';
import 'minecraft_icons.dart';
import 'io_stub.dart' if (dart.library.io) 'io_real.dart';

// ─── COHESIVE DARK GREY BROWNISH PALETTE ─────────────────────────────────────
const _bg = Color(0xFF141312);          // Deep dark grey with warm brownish tone
const _surface = Color(0xFF1F1E1C);     // Dark grey top bar, header & bottom bar
const _card = Color(0xFF282624);        // Dark grey brownish card
const _border = Color(0xFF423C37);      // Muted dark grey brownish border
const _green = Color(0xFFD49B6A);      // Warm bronze-amber gold accent (replaces green)
const _greenDim = Color(0xFF262422);   // Dark grey brownish notification & surface

/// Model for a saved or generated shader
class UserShaderItem {
  final String id;
  final String name;
  final DateTime date;
  final int byteSize;
  final List<int>? bytes;
  final Color previewColor;
  final String engine;

  UserShaderItem({
    required this.id,
    required this.name,
    required this.date,
    required this.byteSize,
    this.bytes,
    required this.previewColor,
    this.engine = 'Vibrant Engine',
  });
}

/// Global store holding previously generated / saved shaders
class UserShaderStore {
  static final List<UserShaderItem> shaders = [
    UserShaderItem(
      id: 'shader_vibrant_default',
      name: 'Piglix Vibrant Horizon',
      date: DateTime.now().subtract(const Duration(hours: 2)),
      byteSize: 184320,
      previewColor: const Color(0xFFD49B6A),
      engine: 'Vibrant Engine (JSON Deferred)',
    ),
    UserShaderItem(
      id: 'shader_pink_atmosphere',
      name: 'Newb X Pink Atmosphere',
      date: DateTime.now().subtract(const Duration(days: 1)),
      byteSize: 245760,
      previewColor: const Color(0xFFE91E63),
      engine: 'Vibrant Engine (JSON Deferred)',
    ),
  ];

  static void addShader({
    required String name,
    required List<int> bytes,
    required Color previewColor,
  }) {
    final cleanName = name.trim().isEmpty ? 'Piglix Shader' : name.trim();
    shaders.insert(
      0,
      UserShaderItem(
        id: 'shader_${DateTime.now().millisecondsSinceEpoch}',
        name: cleanName,
        date: DateTime.now(),
        byteSize: bytes.length,
        bytes: bytes,
        previewColor: previewColor,
        engine: 'Vibrant Engine',
      ),
    );
  }

  static void removeShader(String id) {
    shaders.removeWhere((item) => item.id == id);
  }
}

/// Screen displaying the user's previously generated shaders
class MyShadersScreen extends StatefulWidget {
  final Function(String shaderName)? onEditShader;
  final VoidCallback? onStartNew;

  const MyShadersScreen({
    super.key,
    this.onEditShader,
    this.onStartNew,
  });

  @override
  State<MyShadersScreen> createState() => _MyShadersScreenState();
}

class _MyShadersScreenState extends State<MyShadersScreen> {
  void _snack(String msg, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          msg,
          style: const TextStyle(
            color: Color(0xFFF2EFE9),
            fontWeight: FontWeight.w700,
            fontSize: 13,
          ),
        ),
        backgroundColor: isError ? const Color(0xFF5D1E1E) : const Color(0xFF262422),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: BorderSide(
            color: isError ? const Color(0xFFE57373) : const Color(0xFF5A524A),
            width: 1.5,
          ),
        ),
        elevation: 8,
      ),
    );
  }

  Future<void> _downloadPack(UserShaderItem item) async {
    final pName = item.name.endsWith('.mcpack') ? item.name : '${item.name}.mcpack';
    final bytes = item.bytes;
    if (bytes == null || bytes.isEmpty) {
      _snack('⬇ Downloaded $pName (Template Pack)');
      return;
    }

    try {
      if (kIsWeb) {
        final blob = html.Blob([Uint8List.fromList(bytes)], 'application/zip');
        final url = html.Url.createObjectUrlFromBlob(blob);
        html.AnchorElement(href: url)
          ..setAttribute('download', pName)
          ..click();
        html.Url.revokeObjectUrl(url);
        _snack('⬇ $pName downloaded!');
      } else {
        try {
          await FileSaver.instance.saveFile(
            name: pName.replaceAll('.mcpack', ''),
            bytes: Uint8List.fromList(bytes),
            fileExtension: 'mcpack',
            mimeType: MimeType.other,
          );
          _snack('⬇ Saved: $pName');
        } catch (e) {
          try {
            final tp = await getNativeTempPath();
            await writeNativeFile('$tp/$pName', bytes);
            _snack('⬇ Saved to: $tp/$pName');
          } catch (_) {
            _snack('❌ Could not save file: $e', isError: true);
          }
        }
      }
    } catch (e) {
      _snack('❌ Download error: $e', isError: true);
    }
  }

  Future<void> _openWithMinecraft(UserShaderItem item) async {
    final pName = item.name.endsWith('.mcpack') ? item.name : '${item.name}.mcpack';
    final bytes = item.bytes;
    if (kIsWeb) {
      if (bytes != null && bytes.isNotEmpty) {
        final blob = html.Blob([Uint8List.fromList(bytes)], 'application/octet-stream');
        final url = html.Url.createObjectUrlFromBlob(blob);
        html.AnchorElement(href: url)
          ..setAttribute('download', pName)
          ..click();
        html.Url.revokeObjectUrl(url);
      }
      _snack('📦 .mcpack downloaded! Open from Downloads to install in Minecraft.');
    } else {
      if (bytes != null && bytes.isNotEmpty) {
        try {
          final tp = await getNativeTempPath();
          final path = '$tp/$pName';
          await writeNativeFile(path, bytes);
          const platform = MethodChannel('com.piglix.shader/launcher');
          await platform.invokeMethod('openWithMinecraft', {'filePath': path});
          _snack('✅ Opening $pName in Minecraft...');
          return;
        } catch (_) {}
      }
      _snack('Please export and open $pName with Minecraft.');
    }
  }

  Future<void> _importPack() async {
    try {
      final f = await FilePicker.pickFile(
        type: FileType.custom,
        allowedExtensions: ['mcpack', 'zip'],
      );
      if (f != null) {
        final bytes = await f.readAsBytes();
        if (bytes.isNotEmpty) {
          final name = f.name.replaceAll(RegExp(r'\.(mcpack|zip)$', caseSensitive: false), '');
          setState(() {
            UserShaderStore.addShader(
              name: name,
              bytes: bytes,
              previewColor: const Color(0xFF4CAF50),
            );
          });
          _snack('Imported "${f.name}" to My Shaders!');
        }
      }
    } catch (e) {
      _snack('Import error: $e', isError: true);
    }
  }

  void _deleteShader(UserShaderItem item) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: _surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: const BorderSide(color: _border),
        ),
        title: const Text(
          'Delete Shader?',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        content: Text(
          'Are you sure you want to delete "${item.name}"?',
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel', style: TextStyle(color: Colors.white54)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              setState(() {
                UserShaderStore.removeShader(item.id);
              });
              _snack('Deleted "${item.name}"');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade900,
              foregroundColor: Colors.white,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inMinutes < 60) {
      return '${diff.inMinutes <= 1 ? 1 : diff.inMinutes}m ago';
    } else if (diff.inHours < 24) {
      return '${diff.inHours}h ago';
    } else if (diff.inDays < 7) {
      return '${diff.inDays}d ago';
    }
    return '${dt.day}/${dt.month}/${dt.year}';
  }

  @override
  Widget build(BuildContext context) {
    final items = UserShaderStore.shaders;

    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: _surface,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Row(
          children: [
            AnimatedMinecraftIcon(type: VoxelIconType.chest, size: 22),
            SizedBox(width: 10),
            Text(
              'MY SHADERS',
              style: TextStyle(
                fontFamily: 'monospace',
                fontSize: 16,
                fontWeight: FontWeight.w900,
                color: Colors.white,
                letterSpacing: 1.2,
              ),
            ),
          ],
        ),
        actions: [
          TextButton.icon(
            onPressed: _importPack,
            icon: const Icon(Icons.file_upload_outlined, color: _green, size: 18),
            label: const Text(
              'IMPORT',
              style: TextStyle(
                color: _green,
                fontWeight: FontWeight.w900,
                fontSize: 11,
                letterSpacing: 0.8,
              ),
            ),
          ),
          const SizedBox(width: 8),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: _border, height: 1),
        ),
      ),
      body: SafeArea(
        child: items.isEmpty
            ? _buildEmptyState()
            : ListView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
                children: [
                  // Info banner
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: _card,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: _border),
                    ),
                    child: Row(
                      children: [
                        const AnimatedMinecraftIcon(type: VoxelIconType.sparkles, size: 24),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${items.length} SAVED SHADER${items.length == 1 ? '' : 'S'}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w900,
                                  fontSize: 13,
                                  letterSpacing: 0.5,
                                ),
                              ),
                              const SizedBox(height: 2),
                              const Text(
                                'Tap to open directly in Minecraft or export your .mcpack files.',
                                style: TextStyle(color: Colors.white54, fontSize: 11),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // List of Shader Cards
                  ...items.map((item) => _buildShaderCard(item)),
                ],
              ),
      ),
    );
  }

  Widget _buildShaderCard(UserShaderItem item) {
    final sizeKb = (item.byteSize / 1024).toStringAsFixed(0);

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: _card,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _border, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.4),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header of card
          Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                // Color Swatch / Icon
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: item.previewColor.withOpacity(0.20),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: item.previewColor, width: 1.5),
                    boxShadow: [
                      BoxShadow(
                        color: item.previewColor.withOpacity(0.35),
                        blurRadius: 8,
                      ),
                    ],
                  ),
                  child: const Center(
                    child: AnimatedMinecraftIcon(type: VoxelIconType.chest, size: 24),
                  ),
                ),
                const SizedBox(width: 12),

                // Name & Meta
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.name,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w900,
                          fontSize: 14,
                          letterSpacing: 0.5,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: _green.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(color: _green.withOpacity(0.5), width: 0.8),
                            ),
                            child: const Text(
                              'VIBRANT',
                              style: TextStyle(
                                color: _green,
                                fontSize: 9,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '$sizeKb KB • ${_formatDate(item.date)}',
                            style: const TextStyle(color: Colors.white38, fontSize: 11),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Delete Button
                IconButton(
                  icon: const Icon(Icons.delete_outline_rounded, color: Colors.white30, size: 20),
                  tooltip: 'Delete',
                  onPressed: () => _deleteShader(item),
                ),
              ],
            ),
          ),

          // Divider
          Container(height: 1, color: _border.withOpacity(0.5)),

          // Action Buttons Bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: const BoxDecoration(
              color: Color(0xFF141A16),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(13),
                bottomRight: Radius.circular(13),
              ),
            ),
            child: Row(
              children: [
                // Open With Minecraft
                Expanded(
                  flex: 5,
                  child: SizedBox(
                    height: 38,
                    child: ElevatedButton.icon(
                      onPressed: () => _openWithMinecraft(item),
                      icon: const Icon(Icons.play_arrow_rounded, size: 18),
                      label: const Text(
                        'OPEN IN MINECRAFT',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.8,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _green,
                        foregroundColor: Colors.black,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        padding: EdgeInsets.zero,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),

                // Download Button
                SizedBox(
                  height: 38,
                  width: 38,
                  child: ElevatedButton(
                    onPressed: () => _downloadPack(item),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _surface,
                      foregroundColor: _green,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                        side: const BorderSide(color: _border),
                      ),
                      padding: EdgeInsets.zero,
                    ),
                    child: const Icon(Icons.download_rounded, size: 18, color: _green),
                  ),
                ),
                const SizedBox(width: 8),

                // Edit Button
                SizedBox(
                  height: 38,
                  width: 38,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      if (widget.onEditShader != null) {
                        widget.onEditShader!(item.name);
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _surface,
                      foregroundColor: Colors.white70,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                        side: const BorderSide(color: _border),
                      ),
                      padding: EdgeInsets.zero,
                    ),
                    child: const Icon(Icons.tune_rounded, size: 17, color: Colors.white70),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: _card,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: _border),
              ),
              child: const Center(
                child: AnimatedMinecraftIcon(type: VoxelIconType.chest, size: 48),
              ),
            ),
            const SizedBox(height: 18),
            const Text(
              'No Saved Shaders Yet',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w900,
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Build and compile your custom MCPE shaders to see them here.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white54, fontSize: 12),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.pop(context);
                if (widget.onStartNew != null) widget.onStartNew!();
              },
              icon: const Icon(Icons.auto_awesome_rounded, size: 18),
              label: const Text('START BUILDING'),
              style: ElevatedButton.styleFrom(
                backgroundColor: _green,
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                textStyle: const TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1.0),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
