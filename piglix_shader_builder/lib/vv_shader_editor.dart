// vv_shader_editor.dart — 9-Tab Vibrant Visuals Shader Editor Screen
import 'dart:async';
import 'dart:math' as math;
import 'package:archive/archive.dart';
import 'package:file_picker/file_picker.dart';
import 'package:file_saver/file_saver.dart';
import 'package:flutter/foundation.dart' show kIsWeb, compute;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:universal_html/html.dart' as html;
import 'package:uuid/uuid.dart';

import 'io_stub.dart' if (dart.library.io) 'io_real.dart';
import 'my_shaders_screen.dart';
import 'piglix_logo_data.dart';
import 'shader_presets.dart';
import 'vv_biomes.dart';
import 'vv_config.dart';
import 'vv_editor_widgets.dart';
import 'vv_generator.dart';
import 'vv_import.dart';
import 'vv_tab_previews.dart';
import 'vv_tabs_visual.dart';
import 'vv_tabs_world.dart';
import 'vv_guide_modal.dart';

Archive _decodeZipWorker(List<int> bytes) => ZipDecoder().decodeBytes(bytes);
List<int> _encodeZipWorker(Archive archive) => ZipEncoder().encode(archive);

/// 9-Tab Minecraft Bedrock Vibrant Visuals (.mcpack) Shader Builder screen.
class ShaderEditorScreen extends StatefulWidget {
  final List<int>? uploadedShaderBytes;
  final String? uploadedShaderName;
  final Uint8List? uploadedLogoBytes;
  final String shaderName;
  final ShaderPresetConfig? presetConfig;
  final VVShaderConfig? initialVVConfig;
  final String? migrationNotice;

  const ShaderEditorScreen({
    super.key,
    required this.uploadedShaderBytes,
    required this.uploadedShaderName,
    required this.uploadedLogoBytes,
    required this.shaderName,
    this.presetConfig,
    this.initialVVConfig,
    this.migrationNotice,
  });

  @override
  State<ShaderEditorScreen> createState() => _ShaderEditorScreenState();
}

class _ShaderEditorScreenState extends State<ShaderEditorScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  late VVShaderConfig _config;
  late VVShaderConfig _baselineConfig;
  final VVUndoHistory<VVShaderConfig> _undoHistory =
      VVUndoHistory<VVShaderConfig>();
  VVShaderConfig? _dragStartSnapshot;

  Uint8List? _activeLogoBytes;
  List<int>? _generatedPackBytes;
  String? _generatedPackName;
  bool _isGenerated = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: kVVTabMetas.length, vsync: this);
    _tabController.addListener(() {
      if (mounted) setState(() {});
    });

    _activeLogoBytes = widget.uploadedLogoBytes;
    String? noticeToShow = widget.migrationNotice;

    final safeName = widget.shaderName.trim().isEmpty
        ? 'Piglix Shader'
        : widget.shaderName.trim();

    if (widget.initialVVConfig != null) {
      _config = widget.initialVVConfig!.copyWith(packName: safeName);
    } else if (widget.presetConfig != null) {
      final res = migrateFromShaderPreset(widget.presetConfig!);
      _config = res.config.copyWith(packName: safeName);
      noticeToShow ??= res.userNotice;
    } else {
      _config = VVShaderConfig(packName: safeName);
    }

    _baselineConfig = _config;

    if (noticeToShow != null && noticeToShow.isNotEmpty) {
      final msg = noticeToShow;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _snack(msg);
      });
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _updateConfig(VVShaderConfig next, {bool recordUndo = true}) {
    if (!recordUndo) {
      _dragStartSnapshot ??= _config;
      setState(() {
        _config = next;
        _isGenerated = false;
      });
      return;
    }

    final snapshot = _dragStartSnapshot ?? _config;
    _dragStartSnapshot = null;
    if (snapshot != next) {
      _undoHistory.record(snapshot);
    }
    setState(() {
      _config = next;
      _isGenerated = false;
    });
  }

  void _undo() {
    _dragStartSnapshot = null;
    final prev = _undoHistory.undo(_config);
    if (prev == null) return;
    setState(() {
      _config = prev;
      _isGenerated = false;
    });
  }

  void _redo() {
    _dragStartSnapshot = null;
    final next = _undoHistory.redo(_config);
    if (next == null) return;
    setState(() {
      _config = next;
      _isGenerated = false;
    });
  }

  void _resetTab(int tabIdx) {
    _dragStartSnapshot = null;
    const defaults = VVShaderConfig();
    final VVShaderConfig next = switch (tabIdx) {
      0 => _config.copyWith(atmosphere: defaults.atmosphere),
      1 => _config.copyWith(lighting: defaults.lighting),
      2 => _config.copyWith(fog: defaults.fog),
      3 => _config.copyWith(
          waterGlobal: defaults.waterGlobal,
          waterTropical: defaults.waterTropical,
          waterOcean: defaults.waterOcean,
          waterDeepOcean: defaults.waterDeepOcean,
          waterRiver: defaults.waterRiver,
          waterSwamp: defaults.waterSwamp,
        ),
      4 => _config.copyWith(
          colorGrading: defaults.colorGrading,
          activeMood: defaults.activeMood,
        ),
      5 => _config.copyWith(biomeOverrides: const BiomeOverridesConfig()),
      6 => _config.copyWith(surface: defaults.surface),
      7 => _config.copyWith(performance: defaults.performance),
      8 => _config.copyWith(
          packName: _baselineConfig.packName,
          packDescription: defaults.packDescription,
          packVersion: defaults.packVersion,
          performance: _config.performance.copyWith(
            exportAllTiers: defaults.performance.exportAllTiers,
          ),
        ),
      _ => _config,
    };

    _undoHistory.record(_config);
    setState(() {
      _config = next;
      if (tabIdx == 8) {
        _activeLogoBytes = widget.uploadedLogoBytes;
      }
      _isGenerated = false;
    });
    _snack('Reset ${kVVTabMetas[tabIdx].label} to defaults');
  }

  void _snack(String msg, {bool isError = false}) {
    if (!mounted) return;
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
        backgroundColor:
            isError ? const Color(0xFF5D1E1E) : const Color(0xFF262422),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: BorderSide(
            color: isError ? const Color(0xFFE57373) : const Color(0xFF5A524A),
            width: 1.5,
          ),
        ),
      ),
    );
  }

  Future<void> _pickEditorLogo() async {
    try {
      final f = await FilePicker.pickFile(
        type: FileType.custom,
        allowedExtensions: ['png', 'jpg', 'jpeg'],
      );
      if (f == null) return;
      final bytes = await f.readAsBytes();
      if (bytes.isEmpty) return;
      final normalized = await normalizePackIconPng(bytes);
      if (!mounted) return;
      setState(() {
        _activeLogoBytes = normalized;
        _isGenerated = false;
      });
      _snack('Pack icon normalized to 1:1 PNG');
    } catch (e) {
      _snack('Could not load icon: $e', isError: true);
    }
  }

  void _showRenameDialog() {
    showDialog<void>(
      context: context,
      builder: (ctx) => _RenameShaderDialog(
        initialName: _config.packName,
        onSave: (next) {
          _updateConfig(_config.copyWith(packName: next));
        },
      ),
    );
  }

  Future<bool> _confirmDiscardEdits() async {
    if (_isGenerated) {
      return true;
    }

    final hasActiveSession = widget.presetConfig != null ||
        widget.initialVVConfig != null ||
        (widget.uploadedShaderBytes != null && widget.uploadedShaderBytes!.isNotEmpty) ||
        _undoHistory.canUndo ||
        _config != _baselineConfig ||
        _activeLogoBytes != widget.uploadedLogoBytes ||
        _config.packName != 'Piglix Shader';

    if (!hasActiveSession) {
      return true;
    }

    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: kVVSurface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: const BorderSide(color: kVVBorder, width: 1.2),
        ),
        title: const Row(
          children: [
            Icon(
              Icons.warning_amber_rounded,
              color: Color(0xFFE5A04A),
              size: 22,
            ),
            SizedBox(width: 8),
            Text(
              'Discard Edits?',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ],
        ),
        content: const Text(
          'You are currently editing a shader. Going home will discard your unsaved changes. Do you want to keep editing or discard?',
          style: TextStyle(color: Colors.white70, fontSize: 13, height: 1.4),
        ),
        actions: [
          TextButton(
            key: const Key('vv_discard_keep_btn'),
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            ),
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text(
              'Keep Editing',
              style: TextStyle(
                color: kVVPrimary,
                fontWeight: FontWeight.w700,
                fontSize: 13,
              ),
            ),
          ),
          ElevatedButton(
            key: const Key('vv_discard_confirm_btn'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFDC2626),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text(
              'Discard',
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  void _showActivationGuide() {
    showMinecraftGuideModal(context);
  }

  // ── COMPILATION & EXPORT ─────────────────────────────────────────────────

  void _generatePack() {
    final report = validateConfig(_config);
    if (!report.isValid) {
      _snack(
        'Cannot export: ${report.errors.first}',
        isError: true,
      );
      _tabController.animateTo(kVVTabMetas.length - 1);
      return;
    }

    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => VVCompileProgressDialog(
        onCompile: (p, s) => _doCompile(p, s),
      ),
    );
  }

  Future<void> _doCompile(
    ValueNotifier<double> progressN,
    ValueNotifier<String> statusN,
  ) async {
    try {
      progressN.value = 0.08;
      statusN.value = 'Loading Vibrant Visuals base assets...';

      Archive sourceArchive;
      if (widget.uploadedShaderBytes != null &&
          widget.uploadedShaderBytes!.isNotEmpty) {
        sourceArchive = await compute(
          _decodeZipWorker,
          widget.uploadedShaderBytes!,
        );
      } else {
        final byteData = await rootBundle.load('assets/base_shader.zip');
        sourceArchive = await compute(
          _decodeZipWorker,
          byteData.buffer.asUint8List(),
        );
      }

      final iconBytes =
          _activeLogoBytes ?? widget.uploadedLogoBytes ?? kPiglixLogoBytes;
      final normalizedIcon = await normalizePackIconPng(iconBytes);
      final packUuid = const Uuid().v4();
      final moduleUuid = const Uuid().v4();

      final compiledArchive = buildArchive(
        sourceArchive,
        _config,
        packIconBytes: normalizedIcon,
        packUuid: packUuid,
        moduleUuid: moduleUuid,
        onProgress: (p, msg) {
          progressN.value = (p * 0.85).clamp(0.05, 0.88);
          statusN.value = msg;
        },
      );

      progressN.value = 0.88;
      statusN.value = 'Validating pack schemas & 87 biomes...';
      final archiveReport = validateArchive(compiledArchive, _config);
      if (!archiveReport.isValid) {
        throw StateError(archiveReport.errors.first);
      }

      progressN.value = 0.93;
      statusN.value = 'Compressing .mcpack archive...';
      final encoded = await compute(_encodeZipWorker, compiledArchive);

      progressN.value = 1.0;
      statusN.value = 'Pack ready!';

      final pName = _config.packName.trim().isEmpty
          ? 'Piglix Shader'
          : _config.packName.trim();

      if (mounted) {
        setState(() {
          _generatedPackBytes = encoded;
          _generatedPackName = '$pName.mcpack';
          _isGenerated = true;
        });
      }

      UserShaderStore.addShader(
        name: pName,
        bytes: encoded,
        previewColor: _config.atmosphere.noonHorizon,
      );

      await Future.delayed(const Duration(milliseconds: 280));
      if (mounted) Navigator.pop(context);
      _snack('$pName.mcpack built cleanly!');
    } catch (e) {
      if (mounted) Navigator.pop(context);
      _snack('Export failed: $e', isError: true);
    }
  }

  Future<void> _downloadPack() async {
    if (_generatedPackBytes == null) return;
    final pName = _generatedPackName ?? 'piglix_shader.mcpack';
    try {
      if (kIsWeb) {
        final blob = html.Blob([
          Uint8List.fromList(_generatedPackBytes!),
        ], 'application/zip');
        final url = html.Url.createObjectUrlFromBlob(blob);
        html.AnchorElement(href: url)
          ..setAttribute('download', pName)
          ..click();
        html.Url.revokeObjectUrl(url);
        _snack('$pName downloaded!');
      } else {
        try {
          await FileSaver.instance.saveFile(
            name: pName.replaceAll('.mcpack', ''),
            bytes: Uint8List.fromList(_generatedPackBytes!),
            fileExtension: 'mcpack',
            mimeType: MimeType.other,
          );
          _snack('Saved: $pName');
        } catch (e) {
          final tp = await getNativeTempPath();
          await writeNativeFile('$tp/$pName', _generatedPackBytes!);
          _snack('Saved to: $tp/$pName');
        }
      }
    } catch (e) {
      _snack('Download error: $e', isError: true);
    }
  }

  Future<void> _openWithMinecraft() async {
    if (_generatedPackBytes == null) return;
    final pName = _generatedPackName ?? 'piglix_shader.mcpack';
    if (kIsWeb) {
      await _downloadPack();
      return;
    }
    try {
      final tp = await getNativeTempPath();
      final path = '$tp/$pName';
      await writeNativeFile(path, _generatedPackBytes!);
      const platform = MethodChannel('com.piglix.shader/launcher');
      await platform.invokeMethod('openWithMinecraft', {'filePath': path});
      _snack('Opening $pName in Minecraft...');
    } catch (e) {
      _snack('Error opening Minecraft: $e', isError: true);
    }
  }

  Future<void> _sharePack() async {
    if (_generatedPackBytes == null) return;
    final pName = _generatedPackName ?? 'piglix_shader.mcpack';
    if (kIsWeb) {
      await _downloadPack();
      return;
    }
    try {
      final tp = await getNativeTempPath();
      final path = '$tp/$pName';
      await writeNativeFile(path, _generatedPackBytes!);
      const platform = MethodChannel('com.piglix.shader/launcher');
      await platform.invokeMethod('shareFile', {
        'filePath': path,
        'title': 'Share $pName',
      });
    } catch (e) {
      _snack('Share error: $e', isError: true);
    }
  }

  // ── UI BUILD ─────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    const accent = kVVPrimary;
    final validation = validateConfig(_config);
    final effectiveIcon =
        _activeLogoBytes ?? widget.uploadedLogoBytes ?? kPiglixLogoBytes;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        final ok = await _confirmDiscardEdits();
        if (ok && context.mounted) Navigator.pop(context);
      },
      child: Scaffold(
        backgroundColor: kVVBackground,
        appBar: AppBar(
          backgroundColor: kVVSurface,
          elevation: 0,
          toolbarHeight: 52,
          titleSpacing: 6,
          leadingWidth: 46,
          leading: Padding(
            padding: const EdgeInsets.only(left: 8),
            child: Center(
              child: VVPixelBox(
                fillColor: kVVCard,
                borderColor: kVVBorder,
                borderWidth: 1.2,
                step: 2.0,
                hasShadow: false,
                child: SizedBox(
                  width: 36,
                  height: 36,
                  child: IconButton(
                    key: const Key('vv_home_btn'),
                    tooltip: 'Home',
                    icon: const Icon(
                      Icons.home_rounded,
                      color: Colors.white,
                      size: 18,
                    ),
                    padding: EdgeInsets.zero,
                    onPressed: () async {
                      final ok = await _confirmDiscardEdits();
                      if (ok && context.mounted) {
                        Navigator.of(context).popUntil((route) => route.isFirst);
                      }
                    },
                  ),
                ),
              ),
            ),
          ),
          centerTitle: false,
          title: Row(
            children: [
              // 1. Pack Image / Icon (Separate VVPixelBox, consistent 36px height)
              VVPixelBox(
                fillColor: kVVCard,
                borderColor: kVVBorder,
                borderWidth: 1.2,
                step: 2.0,
                hasShadow: false,
                child: SizedBox(
                  width: 36,
                  height: 36,
                  child: GestureDetector(
                    key: const Key('vv_pack_icon_btn'),
                    onTap: _pickEditorLogo,
                    behavior: HitTestBehavior.opaque,
                    child: Tooltip(
                      message: 'Pack Icon (Tap to change)',
                      child: Center(
                        child: Container(
                          width: 26,
                          height: 26,
                          clipBehavior: Clip.antiAlias,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(2),
                            border: Border.all(
                              color: _activeLogoBytes != null ||
                                      widget.uploadedLogoBytes != null
                                  ? accent
                                  : kVVBorder,
                              width: 1.0,
                            ),
                          ),
                          child: Image.memory(
                            effectiveIcon,
                            fit: BoxFit.cover,
                            filterQuality: FilterQuality.medium,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 6),

              // 2. Shader / Pack Name (Separate VVPixelBox, consistent 36px height & padding)
              Expanded(
                child: VVPixelBox(
                  fillColor: kVVCard,
                  borderColor: kVVBorder,
                  borderWidth: 1.2,
                  step: 2.0,
                  hasShadow: false,
                  child: SizedBox(
                    height: 36,
                    child: GestureDetector(
                      key: const Key('vv_pack_name_btn'),
                      onTap: _showRenameDialog,
                      behavior: HitTestBehavior.opaque,
                      child: Tooltip(
                        message: 'Tap to rename',
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  _config.packName,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 0.2,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(width: 4),
                              Icon(
                                Icons.edit_rounded,
                                color: accent.withValues(alpha: 0.8),
                                size: 13,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          actions: [
            SizedBox(
              width: 32,
              height: 32,
              child: IconButton(
                key: const Key('vv_undo_btn'),
                tooltip: 'Undo',
                padding: EdgeInsets.zero,
                icon: Icon(
                  Icons.undo_rounded,
                  color: _undoHistory.canUndo ? Colors.white : Colors.white24,
                  size: 18,
                ),
                onPressed: _undoHistory.canUndo ? _undo : null,
              ),
            ),
            SizedBox(
              width: 32,
              height: 32,
              child: IconButton(
                key: const Key('vv_redo_btn'),
                tooltip: 'Redo',
                padding: EdgeInsets.zero,
                icon: Icon(
                  Icons.redo_rounded,
                  color: _undoHistory.canRedo ? Colors.white : Colors.white24,
                  size: 18,
                ),
                onPressed: _undoHistory.canRedo ? _redo : null,
              ),
            ),
            SizedBox(
              width: 32,
              height: 32,
              child: IconButton(
                key: const Key('vv_reset_tab_btn'),
                tooltip: 'Reset current tab',
                padding: EdgeInsets.zero,
                icon: const Icon(
                  Icons.restart_alt_rounded,
                  color: Colors.white70,
                  size: 18,
                ),
                onPressed: () => _resetTab(_tabController.index),
              ),
            ),
            SizedBox(
              width: 32,
              height: 32,
              child: IconButton(
                tooltip: 'How to use in Minecraft',
                padding: EdgeInsets.zero,
                icon: const Icon(
                  Icons.help_outline_rounded,
                  color: Colors.white70,
                  size: 18,
                ),
                onPressed: _showActivationGuide,
              ),
            ),
            const SizedBox(width: 6),
          ],
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(72),
            child: Container(
              height: 72,
              decoration: const BoxDecoration(
                color: kVVSurface,
                border: Border(bottom: BorderSide(color: kVVBorder)),
              ),
              child: TabBar(
                controller: _tabController,
                isScrollable: true,
                tabAlignment: TabAlignment.start,
                indicator: const BoxDecoration(),
                indicatorWeight: 0.1,
                dividerColor: Colors.transparent,
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                labelPadding: const EdgeInsets.symmetric(horizontal: 4),
                onTap: (idx) => setState(() => _tabController.animateTo(idx)),
                tabs: List.generate(kVVTabMetas.length, (idx) {
                  final meta = kVVTabMetas[idx];
                  final isSel = _tabController.index == idx;
                  return Tab(
                    key: Key('vv_tab_$idx'),
                    height: 58,
                    child: VVPixelBox(
                      fillColor: isSel
                          ? kVVPrimary.withValues(alpha: 0.18)
                          : kVVCard,
                      borderColor: isSel ? kVVPrimary : kVVBorder,
                      borderWidth: isSel ? 1.6 : 1.1,
                      step: 2.5,
                      hasShadow: isSel,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(minWidth: 54),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            VVTabMiniArt(
                              tabIndex: idx,
                              isSelected: isSel,
                              size: 22,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              meta.shortLabel,
                              style: TextStyle(
                                color: isSel ? Colors.white : Colors.white60,
                                fontSize: 10.5,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.3,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ),
          ),
        ),
        body: TabBarView(
          controller: _tabController,
          children: [
            VVSkyTimeTab(
              config: _config,
              onConfigChanged: _updateConfig,
            ),
            VVLightShadowsTab(
              config: _config,
              onConfigChanged: _updateConfig,
            ),
            VVFogAirTab(
              config: _config,
              onConfigChanged: _updateConfig,
            ),
            VVWaterTab(
              config: _config,
              onConfigChanged: _updateConfig,
            ),
            VVColorMoodTab(
              config: _config,
              onConfigChanged: _updateConfig,
            ),
            VVBiomesTab(
              config: _config,
              onConfigChanged: _updateConfig,
            ),
            VVSurfaceTab(
              config: _config,
              onConfigChanged: _updateConfig,
            ),
            VVPerformanceTab(
              config: _config,
              onConfigChanged: _updateConfig,
            ),
            VVExportTab(
              config: _config,
              onConfigChanged: _updateConfig,
              packIconBytes: effectiveIcon,
              onPickIcon: _pickEditorLogo,
              validationReport: validation,
              generatedPackBytes: _generatedPackBytes,
              generatedPackName: _generatedPackName,
              onExportPack: _generatePack,
              onDownloadPack: _generatedPackBytes != null ? _downloadPack : null,
              onOpenInMinecraft:
                  _generatedPackBytes != null ? _openWithMinecraft : null,
            ),
          ],
        ),
        bottomNavigationBar: _buildBottomBar(accent, validation),
      ),
    );
  }

  Widget _buildBottomBar(Color accent, ValidationReport validation) {
    final isFirstTab = _tabController.index == 0;
    final isLastTab = _tabController.index == kVVTabMetas.length - 1;

    return Container(
      decoration: const BoxDecoration(
        color: kVVSurface,
        border: Border(top: BorderSide(color: kVVBorder)),
      ),
      padding: EdgeInsets.only(
        left: 14,
        right: 14,
        top: 10,
        bottom: 10 + MediaQuery.of(context).padding.bottom,
      ),
      child: (_isGenerated && _generatedPackBytes != null)
          ? Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: _openWithMinecraft,
                    behavior: HitTestBehavior.opaque,
                    child: VVPixelBox(
                      fillColor: const Color(0xFF22C55E),
                      borderColor: const Color(0xFF86EFAC),
                      borderWidth: 1.5,
                      step: 3.0,
                      hasShadow: true,
                      child: const SizedBox(
                        height: 48,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.play_arrow_rounded, color: Colors.black),
                            SizedBox(width: 6),
                            Text(
                              'OPEN WITH MINECRAFT',
                              style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.6,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Tooltip(
                  message: 'Download .mcpack',
                  child: GestureDetector(
                    onTap: _downloadPack,
                    behavior: HitTestBehavior.opaque,
                    child: VVPixelBox(
                      fillColor: kVVCard,
                      borderColor: accent,
                      borderWidth: 1.4,
                      step: 2.5,
                      hasShadow: false,
                      child: SizedBox(
                        height: 48,
                        width: 48,
                        child: Icon(Icons.download_rounded, color: accent),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Tooltip(
                  message: 'Share .mcpack',
                  child: GestureDetector(
                    onTap: _sharePack,
                    behavior: HitTestBehavior.opaque,
                    child: VVPixelBox(
                      fillColor: kVVCard,
                      borderColor: accent,
                      borderWidth: 1.4,
                      step: 2.5,
                      hasShadow: false,
                      child: SizedBox(
                        height: 48,
                        width: 48,
                        child: Icon(Icons.share_rounded, color: accent),
                      ),
                    ),
                  ),
                ),
              ],
            )
          : Row(
              children: [
                if (!isFirstTab) ...[
                  GestureDetector(
                    onTap: () => setState(() {
                      _tabController.animateTo(_tabController.index - 1);
                    }),
                    behavior: HitTestBehavior.opaque,
                    child: VVPixelBox(
                      fillColor: kVVCard,
                      borderColor: kVVBorder,
                      borderWidth: 1.4,
                      step: 2.5,
                      hasShadow: false,
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      child: const SizedBox(
                        height: 46,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.arrow_back_rounded,
                              size: 16,
                              color: Colors.white70,
                            ),
                            SizedBox(width: 6),
                            Text(
                              'Back',
                              style: TextStyle(
                                color: Colors.white70,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                ],
                Expanded(
                  child: GestureDetector(
                    onTap: isLastTab
                        ? (validation.isValid ? _generatePack : null)
                        : () => setState(() {
                            _tabController.animateTo(
                              _tabController.index + 1,
                            );
                          }),
                    behavior: HitTestBehavior.opaque,
                    child: VVPixelBox(
                      fillColor: (!isLastTab || validation.isValid)
                          ? accent
                          : Colors.white12,
                      borderColor: (!isLastTab || validation.isValid)
                          ? const Color(0xFF86EFAC)
                          : kVVBorder,
                      borderWidth: 1.5,
                      step: 3.0,
                      hasShadow: !isLastTab || validation.isValid,
                      child: SizedBox(
                        height: 46,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              isLastTab
                                  ? Icons.auto_awesome_rounded
                                  : Icons.arrow_forward_rounded,
                              size: 18,
                              color: (!isLastTab || validation.isValid)
                                  ? Colors.black
                                  : Colors.white38,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              isLastTab ? 'GENERATE .MCPACK' : 'NEXT TAB',
                              style: TextStyle(
                                color: (!isLastTab || validation.isValid)
                                    ? Colors.black
                                    : Colors.white38,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.8,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}

class VVCompileProgressDialog extends StatefulWidget {
  final Future<void> Function(
    ValueNotifier<double> progressN,
    ValueNotifier<String> statusN,
  ) onCompile;

  const VVCompileProgressDialog({super.key, required this.onCompile});

  @override
  State<VVCompileProgressDialog> createState() =>
      _VVCompileProgressDialogState();
}

class _VVCompileProgressDialogState extends State<VVCompileProgressDialog>
    with SingleTickerProviderStateMixin {
  final ValueNotifier<double> progressN = ValueNotifier<double>(0.05);
  final ValueNotifier<String> statusN =
      ValueNotifier<String>('Preparing Vibrant Visuals pack...');
  late final AnimationController _animCtrl;
  Timer? _tipTimer;
  int _tipIndex = 0;

  static const List<String> _kMinecraftTips = [
    'Vibrant Visuals shaders run natively on Minecraft Bedrock Render Dragon!',
    'Atmospheric Rayleigh scattering shapes authentic Minecraft blue horizons.',
    'Point-light multipliers make torches and lanterns glow warmly in caves.',
    'Exported .mcpack files import directly into Minecraft on tap.',
    'Ultra tier features high-precision caustics and multi-octave water waves.',
    'Sunlight illuminance controls realistic orbital shadow darkness.',
    'Mining blocks and compiling Vibrant Visuals archive...',
  ];

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    )..repeat();

    _tipTimer = Timer.periodic(const Duration(milliseconds: 3200), (_) {
      if (!mounted) return;
      setState(() {
        _tipIndex = (_tipIndex + 1) % _kMinecraftTips.length;
      });
    });

    widget.onCompile(progressN, statusN);
  }

  @override
  void dispose() {
    _tipTimer?.cancel();
    _animCtrl.dispose();
    progressN.dispose();
    statusN.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 356),
          child: VVPixelBox(
            fillColor: const Color(0xFF111822),
            borderColor: const Color(0xFF22C55E),
            borderWidth: 2.0,
            step: 3.0,
            hasShadow: true,
            innerHighlightAlpha: 0.15,
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // 1. Center Animated 3D Isometric Minecraft Block & Floating XP Particles
                Center(
                  child: SizedBox(
                    width: 84,
                    height: 84,
                    child: AnimatedBuilder(
                      animation: _animCtrl,
                      builder: (context, _) => CustomPaint(
                        painter: _MinecraftBobbingBlockPainter(
                          animationValue: _animCtrl.value,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),

                // 2. Minecraft Mojang Heading with Pixel Shadow
                const Text(
                  'BUILDING SHADER PACK',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontFamily: 'PixelifySans',
                    fontWeight: FontWeight.w700,
                    fontSize: 15.5,
                    letterSpacing: 0.8,
                    shadows: [
                      Shadow(
                        color: Color(0xFF06090E),
                        offset: Offset(2, 2),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 4),

                // Decorative green pixel accent bar
                Center(
                  child: Container(
                    width: 48,
                    height: 3,
                    decoration: BoxDecoration(
                      color: const Color(0xFF22C55E),
                      borderRadius: BorderRadius.circular(1.5),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF22C55E).withValues(alpha: 0.6),
                          blurRadius: 4,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                // 3. Status text with animated Minecraft trailing dots
                ValueListenableBuilder<String>(
                  valueListenable: statusN,
                  builder: (_, s, _) {
                    return AnimatedBuilder(
                      animation: _animCtrl,
                      builder: (context, _) {
                        final dotCount = ((_animCtrl.value * 3).floor() % 3) + 1;
                        final dots = '.' * dotCount;
                        final clean = s.replaceAll(RegExp(r'\.+$'), '');
                        return Text(
                          '$clean$dots',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Color(0xFFFDE047),
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                            letterSpacing: 0.2,
                            shadows: [
                              Shadow(
                                color: Color(0xFF0F172A),
                                offset: Offset(1, 1),
                              ),
                            ],
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        );
                      },
                    );
                  },
                ),
                const SizedBox(height: 14),

                // 4. Authentic Minecraft Stepped XP / Loading Bar with Level Number
                ValueListenableBuilder<double>(
                  valueListenable: progressN,
                  builder: (_, p, _) => AnimatedBuilder(
                    animation: _animCtrl,
                    builder: (context, _) => _MinecraftProgressBar(
                      progress: p,
                      animationValue: _animCtrl.value,
                    ),
                  ),
                ),
                const SizedBox(height: 14),

                // 5. Authentic Minecraft Bedrock "Tip:" Box
                VVPixelBox(
                  fillColor: const Color(0xFF0A0F17),
                  borderColor: const Color(0xFF1E293B),
                  borderWidth: 1.2,
                  step: 2.0,
                  hasShadow: false,
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(
                            Icons.lightbulb_rounded,
                            size: 13,
                            color: Color(0xFFFBBF24),
                          ),
                          SizedBox(width: 5),
                          Text(
                            'MINECRAFT TIP',
                            style: TextStyle(
                              color: Color(0xFFFBBF24),
                              fontSize: 9.5,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.8,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 300),
                        child: Text(
                          _kMinecraftTips[_tipIndex],
                          key: ValueKey<int>(_tipIndex),
                          style: const TextStyle(
                            color: Color(0xFFCBD5E1),
                            fontSize: 11,
                            height: 1.35,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Custom painter for an authentic 3D isometric Minecraft Grass Block
/// that smoothly bobs up and down with dynamic ground shadow and floating XP sparkle particles.
class _MinecraftBobbingBlockPainter extends CustomPainter {
  final double animationValue;

  _MinecraftBobbingBlockPainter({required this.animationValue});

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;

    // Bobbing offset (-5px to +5px)
    final bob = math.sin(animationValue * 2 * math.pi) * 5.0;
    final blockCy = cy + bob - 4;

    // 1. Dynamic Ground Shadow (shrinks & fades as block floats higher)
    final shadowScale = 1.0 - (bob / 12.0);
    final shadowPaint = Paint()
      ..color = Colors.black.withValues(alpha: (0.35 * shadowScale).clamp(0.15, 0.45))
      ..style = PaintingStyle.fill;
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(cx, cy + 26),
        width: 48 * shadowScale,
        height: 14 * shadowScale,
      ),
      shadowPaint,
    );

    // 2. Floating XP / Sparkle Particles (8 floating particles)
    const particleColors = [
      Color(0xFF34D399),
      Color(0xFF86EFAC),
      Color(0xFFFBBF24),
      Color(0xFF38BDF8),
    ];

    for (int i = 0; i < 8; i++) {
      final pPhase = (animationValue + (i * 0.125)) % 1.0;
      final px = cx + math.cos(i * 0.785) * (26.0 + i * 2.0) + math.sin(pPhase * 2 * math.pi) * 3.0;
      final py = (blockCy + 16.0) - (pPhase * 44.0);
      final pAlpha = (math.sin(pPhase * math.pi) * 0.9).clamp(0.0, 1.0);
      final pColor = particleColors[i % particleColors.length].withValues(alpha: pAlpha);

      final pSize = 3.0 + (i % 2) * 1.5;
      final pPaint = Paint()..color = pColor;
      canvas.drawRect(
        Rect.fromCenter(center: Offset(px, py), width: pSize, height: pSize),
        pPaint,
      );
    }

    // 3. 3D Isometric Grass Block
    const double s = 42.0;
    const double w2 = s * 0.46; // half-width
    const double h2 = s * 0.25; // isometric pitch

    final edgeOutline = Paint()
      ..color = const Color(0xFF140F0A)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.8
      ..strokeJoin = StrokeJoin.miter;

    // A. Top green grass face (Isometric Rhombus)
    final topFace = Path()
      ..moveTo(cx, blockCy - s * 0.38)
      ..lineTo(cx + w2, blockCy - s * 0.38 + h2)
      ..lineTo(cx, blockCy - s * 0.38 + 2 * h2)
      ..lineTo(cx - w2, blockCy - s * 0.38 + h2)
      ..close();
    canvas.drawPath(topFace, Paint()..color = const Color(0xFF4EA32A));
    canvas.drawPath(topFace, edgeOutline);

    // Top grass texture pixel flecks
    final fleckLight = Paint()..color = const Color(0xFF6DCB3C);
    final fleckDark = Paint()..color = const Color(0xFF347A18);
    canvas.drawRect(Rect.fromLTWH(cx - 7, blockCy - 12, 5, 3), fleckLight);
    canvas.drawRect(Rect.fromLTWH(cx + 4, blockCy - 15, 6, 3), fleckLight);
    canvas.drawRect(Rect.fromLTWH(cx - 11, blockCy - 7, 5, 3), fleckDark);
    canvas.drawRect(Rect.fromLTWH(cx + 2, blockCy - 7, 5, 3), fleckDark);

    // B. Left dirt face (shaded 85%)
    final leftFace = Path()
      ..moveTo(cx - w2, blockCy - s * 0.38 + h2)
      ..lineTo(cx, blockCy - s * 0.38 + 2 * h2)
      ..lineTo(cx, blockCy + s * 0.38)
      ..lineTo(cx - w2, blockCy + s * 0.38 - h2)
      ..close();
    canvas.drawPath(leftFace, Paint()..color = const Color(0xFF6E4D30));
    canvas.drawPath(leftFace, edgeOutline);

    // Left dirt pebbles
    final pebbleLight = Paint()..color = const Color(0xFF8F6845);
    final pebbleDark = Paint()..color = const Color(0xFF48301B);
    canvas.drawRect(Rect.fromLTWH(cx - 14, blockCy + 4, 4, 4), pebbleLight);
    canvas.drawRect(Rect.fromLTWH(cx - 7, blockCy + 9, 4, 3), pebbleDark);
    canvas.drawRect(Rect.fromLTWH(cx - 12, blockCy + 14, 3, 3), pebbleDark);

    // C. Right dirt face (shaded 65%)
    final rightFace = Path()
      ..moveTo(cx, blockCy - s * 0.38 + 2 * h2)
      ..lineTo(cx + w2, blockCy - s * 0.38 + h2)
      ..lineTo(cx + w2, blockCy + s * 0.38 - h2)
      ..lineTo(cx, blockCy + s * 0.38)
      ..close();
    canvas.drawPath(rightFace, Paint()..color = const Color(0xFF563B23));
    canvas.drawPath(rightFace, edgeOutline);

    // Right dirt pebbles
    canvas.drawRect(Rect.fromLTWH(cx + 8, blockCy + 6, 4, 4), pebbleDark);
    canvas.drawRect(Rect.fromLTWH(cx + 4, blockCy + 13, 4, 3), pebbleLight);
    canvas.drawRect(Rect.fromLTWH(cx + 12, blockCy + 11, 3, 3), pebbleDark);

    // D. Stepped voxel grass overhang fringe hanging down both sides
    final overLeft = Path()
      ..moveTo(cx - w2, blockCy - s * 0.38 + h2)
      ..lineTo(cx, blockCy - s * 0.38 + 2 * h2)
      ..lineTo(cx, blockCy - s * 0.38 + 2 * h2 + 6)
      ..lineTo(cx - 7, blockCy - s * 0.38 + 2 * h2 + 6)
      ..lineTo(cx - 7, blockCy - s * 0.38 + 2 * h2 + 3)
      ..lineTo(cx - 14, blockCy - s * 0.38 + 2 * h2 + 3)
      ..lineTo(cx - 14, blockCy - s * 0.38 + 2 * h2 + 6)
      ..lineTo(cx - w2, blockCy - s * 0.38 + h2 + 6)
      ..close();
    canvas.drawPath(overLeft, Paint()..color = const Color(0xFF3F8A1E));
    canvas.drawPath(overLeft, edgeOutline);

    final overRight = Path()
      ..moveTo(cx, blockCy - s * 0.38 + 2 * h2)
      ..lineTo(cx + w2, blockCy - s * 0.38 + h2)
      ..lineTo(cx + w2, blockCy - s * 0.38 + h2 + 6)
      ..lineTo(cx + 14, blockCy - s * 0.38 + 2 * h2 + 6)
      ..lineTo(cx + 14, blockCy - s * 0.38 + 2 * h2 + 3)
      ..lineTo(cx + 7, blockCy - s * 0.38 + 2 * h2 + 3)
      ..lineTo(cx + 7, blockCy - s * 0.38 + 2 * h2 + 6)
      ..lineTo(cx, blockCy - s * 0.38 + 2 * h2 + 6)
      ..close();
    canvas.drawPath(overRight, Paint()..color = const Color(0xFF337016));
    canvas.drawPath(overRight, edgeOutline);
  }

  @override
  bool shouldRepaint(covariant _MinecraftBobbingBlockPainter oldDelegate) =>
      oldDelegate.animationValue != animationValue;
}

/// The Authentic Minecraft Stepped XP / Loading Bar with Level Percentage
class _MinecraftProgressBar extends StatelessWidget {
  final double progress;
  final double animationValue;

  const _MinecraftProgressBar({
    required this.progress,
    required this.animationValue,
  });

  @override
  Widget build(BuildContext context) {
    final pct = (progress.clamp(0.0, 1.0) * 100).round();

    return Column(
      children: [
        Stack(
          alignment: Alignment.center,
          clipBehavior: Clip.none,
          children: [
            // Stepped Beveled Minecraft Bar
            SizedBox(
              height: 18,
              width: double.infinity,
              child: CustomPaint(
                painter: _MinecraftProgressBarPainter(
                  progress: progress,
                  animationValue: animationValue,
                ),
              ),
            ),

            // Minecraft XP Level Number right on the bar with 4-way drop shadow
            Positioned(
              top: -6,
              child: Text(
                '$pct%',
                style: const TextStyle(
                  color: Color(0xFF86EFAC),
                  fontFamily: 'PixelifySans',
                  fontWeight: FontWeight.w800,
                  fontSize: 13,
                  letterSpacing: 0.5,
                  shadows: [
                    Shadow(color: Colors.black, offset: Offset(-1.5, -1.5)),
                    Shadow(color: Colors.black, offset: Offset(1.5, -1.5)),
                    Shadow(color: Colors.black, offset: Offset(1.5, 1.5)),
                    Shadow(color: Colors.black, offset: Offset(-1.5, 1.5)),
                    Shadow(color: Colors.black, offset: Offset(0, 2)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

/// Custom painter for the stepped, beveled Minecraft Bedrock XP Loading Bar
class _MinecraftProgressBarPainter extends CustomPainter {
  final double progress;
  final double animationValue;

  _MinecraftProgressBarPainter({
    required this.progress,
    required this.animationValue,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final r = Rect.fromLTWH(0, 0, size.width, size.height);

    // 1. Outer 2px solid black border
    canvas.drawRect(r, Paint()..color = const Color(0xFF080C12));

    // 2. Beveled inner border (shadow top/left, highlight bottom/right)
    final innerR = Rect.fromLTWH(1.5, 1.5, size.width - 3.0, size.height - 3.0);
    canvas.drawRect(innerR, Paint()..color = const Color(0xFF141A24));

    // Channel base (deep empty bedrock)
    final channelR = Rect.fromLTWH(3.0, 3.0, size.width - 6.0, size.height - 6.0);
    canvas.drawRect(channelR, Paint()..color = const Color(0xFF0B0F15));

    final clampedP = progress.clamp(0.0, 1.0);
    final fillW = (size.width - 6.0) * clampedP;

    if (fillW > 0) {
      canvas.save();
      canvas.clipRect(Rect.fromLTWH(3.0, 3.0, fillW, size.height - 6.0));

      // 3. Authentic Minecraft 3-band Emerald Green Bar:
      // Top 3px highlight
      canvas.drawRect(
        Rect.fromLTWH(3.0, 3.0, fillW, 3.0),
        Paint()..color = const Color(0xFF86EFAC),
      );
      // Mid 6px body
      canvas.drawRect(
        Rect.fromLTWH(3.0, 6.0, fillW, 6.0),
        Paint()..color = const Color(0xFF22C55E),
      );
      // Bottom 3px shadow
      canvas.drawRect(
        Rect.fromLTWH(3.0, 12.0, fillW, 3.0),
        Paint()..color = const Color(0xFF15803D),
      );

      // 4. Vertical pixel tick dividers every 14px (Minecraft XP notches)
      final tickPaint = Paint()..color = const Color(0xFF0E5E2B);
      for (double x = 3.0 + 14.0; x < 3.0 + fillW; x += 14.0) {
        canvas.drawRect(Rect.fromLTWH(x, 3.0, 1.2, size.height - 6.0), tickPaint);
      }

      // 5. Sweeping gleam / enchantment sheen across the filled portion
      final gleamX = 3.0 + ((animationValue * (size.width + 40.0)) - 30.0);
      final gleamPaint = Paint()
        ..shader = LinearGradient(
          colors: [
            Colors.white.withValues(alpha: 0.0),
            Colors.white.withValues(alpha: 0.35),
            Colors.white.withValues(alpha: 0.0),
          ],
        ).createShader(Rect.fromLTWH(gleamX, 3.0, 24.0, size.height - 6.0));
      canvas.drawRect(
        Rect.fromLTWH(gleamX, 3.0, 24.0, size.height - 6.0),
        gleamPaint,
      );

      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant _MinecraftProgressBarPainter oldDelegate) =>
      oldDelegate.progress != progress ||
      oldDelegate.animationValue != animationValue;
}

class _RenameShaderDialog extends StatefulWidget {
  final String initialName;
  final ValueChanged<String> onSave;

  const _RenameShaderDialog({
    required this.initialName,
    required this.onSave,
  });

  @override
  State<_RenameShaderDialog> createState() => _RenameShaderDialogState();
}

class _RenameShaderDialogState extends State<_RenameShaderDialog> {
  late final TextEditingController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = TextEditingController(text: widget.initialName);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const accent = kVVPrimary;
    return AlertDialog(
      backgroundColor: kVVSurface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: const BorderSide(color: kVVBorder, width: 1.2),
      ),
      title: const Text(
        'Pack Shader Name',
        style: TextStyle(
          color: Colors.white,
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
      content: TextField(
        controller: _ctrl,
        autofocus: true,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 14,
          fontWeight: FontWeight.w700,
        ),
        decoration: InputDecoration(
          hintText: 'Enter shader name',
          hintStyle: const TextStyle(color: Color(0xFF64748B)),
          filled: true,
          fillColor: kVVCard,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: kVVBorder),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: accent, width: 1.5),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text(
            'Cancel',
            style: TextStyle(color: Color(0xFF94A3B8)),
          ),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: accent,
            foregroundColor: Colors.black,
          ),
          onPressed: () {
            final next = _ctrl.text.trim();
            if (next.isNotEmpty) {
              widget.onSave(next);
            }
            Navigator.pop(context);
          },
          child: const Text(
            'Save',
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
      ],
    );
  }
}
