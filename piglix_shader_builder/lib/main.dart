import 'dart:ui';
import 'dart:async';
import 'dart:convert';
import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:io' as io;
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/services.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:archive/archive.dart';
import 'package:universal_html/html.dart' as html;
import 'package:uuid/uuid.dart';
import 'package:path_provider/path_provider.dart';
import 'package:file_saver/file_saver.dart';
import 'package:file_picker/file_picker.dart'
    show FilePicker, PlatformFile, FileType;
import 'package:google_fonts/google_fonts.dart';
import 'piglix_logo_data.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Color(0xFF000000),
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Color(0xFF000000),
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );
  runApp(const PiglixProApp());
}

class PiglixProApp extends StatelessWidget {
  const PiglixProApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Shader Generator for MCPE',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF020805),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF16A34A),
          secondary: Color(0xFF22C55E),
          surface: Color(0xFF071C12),
        ),
        fontFamily: 'Minecraft',
        textTheme: ThemeData.dark().textTheme.apply(
          fontFamily: 'Minecraft',
        ),
        useMaterial3: true,
      ),
      home: const PiglixSplashScreen(),
    );
  }
}

class PiglixSplashScreen extends StatefulWidget {
  const PiglixSplashScreen({super.key});

  @override
  State<PiglixSplashScreen> createState() => _PiglixSplashScreenState();
}

class _PiglixSplashScreenState extends State<PiglixSplashScreen> {
  int _titleStep = 0;
  bool _showCustomSplash = true;
  Timer? _titleTimer;

  @override
  void initState() {
    super.initState();
    _titleTimer = Timer.periodic(const Duration(milliseconds: 900), (_) {
      if (mounted) setState(() => _titleStep = (_titleStep + 1) % 4);
    });
    Future.delayed(const Duration(milliseconds: 1500), () {
      if (mounted) {
        Navigator.of(context).pushReplacement(
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) =>
                const StudioDashboard(),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) =>
                    FadeTransition(opacity: animation, child: child),
            transitionDuration: const Duration(milliseconds: 300),
          ),
        );
      }
    });
  }

  @override
  void dispose() {
    _titleTimer?.cancel();
    super.dispose();
  }

  void _openStudio() {
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            const StudioDashboard(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) =>
            FadeTransition(opacity: animation, child: child),
        transitionDuration: const Duration(milliseconds: 350),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_showCustomSplash) {
      return Scaffold(
        backgroundColor: const Color(0xFF071A14),
        body: Stack(
          fit: StackFit.expand,
          children: [
            // Background glow blobs
            Positioned(
              top: -80,
              left: -60,
              child: Container(
                width: 300,
                height: 300,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      const Color(0xFF10B981).withOpacity(0.25),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: -60,
              right: -60,
              child: Container(
                width: 260,
                height: 260,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      const Color(0xFF16834D).withOpacity(0.2),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 140,
                    height: 140,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF10B981).withOpacity(0.4),
                          blurRadius: 80,
                          spreadRadius: 20,
                        ),
                      ],
                    ),
                    child: ClipOval(
                      child: Image.memory(kPiglixLogoBytes, fit: BoxFit.cover),
                    ),
                  ),
                  const SizedBox(height: 32),
                  Text(
                    'PIGLIX STUDIO',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 4,
                      color: Color(0xFF10B981),
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Vibrant Visuals Shader Builder',
                    style: TextStyle(
                      fontSize: 13,
                      color: Color(0xFF6B7280),
                      letterSpacing: 1.5,
                    ),
                  ),
                  const SizedBox(height: 56),
                  SizedBox(
                    width: 28,
                    height: 28,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        const Color(0xFF10B981).withOpacity(0.85),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }
    const titleWords = ['shader', 'maker', 'for', 'MCPE'];
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF081A12), Color(0xFF05100B), Color(0xFF000000)],
            stops: [0.0, 0.45, 1.0],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(26, 28, 26, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Spacer(flex: 2),
                const Text(
                  'PIGLIX',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 4,
                  ),
                ),
                const SizedBox(height: 18),
                SizedBox(
                  height: 92,
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 500),
                    transitionBuilder: (child, animation) => SlideTransition(
                      position:
                          Tween<Offset>(
                            begin: const Offset(0, 1),
                            end: Offset.zero,
                          ).animate(
                            CurvedAnimation(
                              parent: animation,
                              curve: Curves.easeOutCubic,
                            ),
                          ),
                      child: FadeTransition(opacity: animation, child: child),
                    ),
                    child: Text(
                      titleWords[_titleStep],
                      key: ValueKey(_titleStep),
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 58,
                        height: 1,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -2,
                      ),
                    ),
                  ),
                ),
                const Text(
                  'for MCPE shader creators',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Color(0xFFA6C9B4),
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(flex: 3),
                _homeAction(
                  'Make your own shader',
                  Icons.auto_awesome,
                  _openStudio,
                  true,
                ),
                const SizedBox(height: 14),
                _homeAction(
                  'Open / edit your shader',
                  Icons.folder_open_rounded,
                  _openStudio,
                  false,
                ),
                const SizedBox(height: 12),
                const Text(
                  'Create beautiful Minecraft visuals in minutes',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Color(0xFF7FAF8F), fontSize: 12),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _homeAction(
    String label,
    IconData icon,
    VoidCallback onTap,
    bool primary,
  ) {
    return SizedBox(
      height: 60,
      child: ElevatedButton.icon(
        onPressed: onTap,
        icon: Icon(icon, size: 22),
        label: Text(
          label,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: primary
              ? const Color(0xFF2AAE63)
              : const Color(0xFF0D3B2A),
          foregroundColor: primary ? Colors.white : const Color(0xFF43D17A),
          elevation: primary ? 6 : 1,
          shadowColor: const Color(0x5516834D),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
            side: primary
                ? BorderSide.none
                : const BorderSide(color: Color(0xFF227A51)),
          ),
        ),
      ),
    );
  }
}

class _BannerDot extends StatelessWidget {
  final double size;
  final Color color;
  const _BannerDot({required this.size, required this.color});

  @override
  Widget build(BuildContext context) => Container(
    width: size,
    height: size,
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      color: color,
      boxShadow: [
        BoxShadow(
          color: color.withValues(alpha: 0.55),
          blurRadius: size * 2.5,
          spreadRadius: size * 0.4,
        ),
      ],
    ),
  );
}

class StudioDashboard extends StatefulWidget {
  const StudioDashboard({super.key});

  @override
  State<StudioDashboard> createState() => _StudioDashboardState();
}

class _StudioDashboardState extends State<StudioDashboard> {
  double _navHeight = 82;
  final ScrollController _settingsScrollController = ScrollController();
  final GlobalKey _packIconKey = GlobalKey();

  bool _isGenerated = false;
  List<int>? _generatedPackBytes;
  String? _generatedPackName;

  // Uploaded custom shader
  List<int>? _uploadedShaderBytes;
  String? _uploadedShaderName;
  bool _isUploadingShader = false;

  // Shader pack icon / logo
  Uint8List? _uploadedLogoBytes;
  String? _uploadedLogoName;
  bool _isUploadingLogo = false;

  Future<void> _pickShaderFile() async {
    try {
      setState(() => _isUploadingShader = true);

      // file_picker v13: pickFile() returns PlatformFile?, read bytes via readAsBytes()
      final PlatformFile? file = await FilePicker.pickFile(
        type: FileType.custom,
        allowedExtensions: ['mcpack', 'zip'],
      );

      if (file == null) {
        setState(() => _isUploadingShader = false);
        return;
      }

      Uint8List? bytes;
      try {
        bytes = await file.readAsBytes();
      } catch (_) {
        bytes = null;
      }
      if (bytes == null || bytes.isEmpty) {
        setState(() => _isUploadingShader = false);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Could not read file bytes. Try again.'),
              backgroundColor: Colors.red,
            ),
          );
        }
        return;
      }

      // Validate: must be a valid ZIP with at least one lighting/ or atmospherics/ JSON
      bool isValidShader = false;
      String detectedFiles = '';
      try {
        final archive = ZipDecoder().decodeBytes(bytes);
        final relevantFiles = archive.files
            .where(
              (f) =>
                  f.name.startsWith('lighting/') ||
                  f.name.startsWith('atmospherics/') ||
                  f.name.startsWith('pbr/') ||
                  f.name.startsWith('point_lights/'),
            )
            .toList();
        if (relevantFiles.isNotEmpty) {
          isValidShader = true;
          detectedFiles = relevantFiles.map((f) => f.name).take(5).join(', ');
        }
      } catch (_) {
        isValidShader = false;
      }

      if (!isValidShader) {
        setState(() => _isUploadingShader = false);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                '❌ Invalid shader! Must be a Vibrant Visuals .mcpack with lighting/global.json.',
              ),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
        return;
      }

      setState(() {
        _uploadedShaderBytes = bytes!.toList();
        _uploadedShaderName = file.name;
        shaderNameController.text = file.name.replaceFirst(
          RegExp(r'\.(mcpack|zip)$', caseSensitive: false),
          '',
        );
        _isUploadingShader = false;
        _isGenerated = false;
        _generatedPackBytes = null;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('✅ Loaded: ${file.name}\nDetected: $detectedFiles'),
            backgroundColor: const Color(0xFF385E2E),
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    } catch (e) {
      setState(() => _isUploadingShader = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading shader: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _clearUploadedShader() {
    setState(() {
      _uploadedShaderBytes = null;
      _uploadedShaderName = null;
      _isGenerated = false;
      _generatedPackBytes = null;
    });
  }

  void _scrollToPackIcon() {
    final targetContext = _packIconKey.currentContext;
    if (targetContext == null) return;
    Scrollable.ensureVisible(
      targetContext,
      duration: const Duration(milliseconds: 850),
      curve: Curves.easeInOutCubic,
      alignment: 0.06,
    );
  }

  Future<void> _pickLogoFile() async {
    try {
      setState(() => _isUploadingLogo = true);
      final PlatformFile? file = await FilePicker.pickFile(
        type: FileType.image,
      );
      if (file == null) {
        setState(() => _isUploadingLogo = false);
        return;
      }
      Uint8List? bytes;
      try {
        bytes = await file.readAsBytes();
      } catch (_) {
        bytes = null;
      }
      if (bytes == null || bytes.isEmpty) {
        setState(() => _isUploadingLogo = false);
        if (mounted)
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Could not read image. Try another file.'),
              backgroundColor: Colors.red,
            ),
          );
        return;
      }
      setState(() {
        _uploadedLogoBytes = bytes;
        _uploadedLogoName = file.name;
        _isUploadingLogo = false;
      });
      if (mounted)
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('✅ Logo set: ${file.name}'),
            backgroundColor: const Color(0xFF385E2E),
            behavior: SnackBarBehavior.floating,
          ),
        );
    } catch (e) {
      setState(() => _isUploadingLogo = false);
      if (mounted)
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
    }
  }

  void _clearUploadedLogo() {
    setState(() {
      _uploadedLogoBytes = null;
      _uploadedLogoName = null;
    });
  }

  Future<void> _downloadPack() async {
    if (_generatedPackBytes == null) return;
    String pName =
        _generatedPackName ??
        (shaderNameController.text.trim().isEmpty
            ? "Piglix Shader"
            : shaderNameController.text.trim());
    if (!pName.endsWith('.mcpack')) pName = '$pName.mcpack';
    final baseName = pName.replaceAll(
      RegExp(r'\.mcpack$', caseSensitive: false),
      '',
    );

    String savedMessage = 'Downloaded $pName!';

    if (kIsWeb) {
      final blob = html.Blob([_generatedPackBytes], 'application/octet-stream');
      final url = html.Url.createObjectUrlFromBlob(blob);
      html.AnchorElement(href: url)
        ..setAttribute("download", pName)
        ..click();
      html.Url.revokeObjectUrl(url);
    } else {
      try {
        final bytes = Uint8List.fromList(_generatedPackBytes!);
        // Save directly to device public Download directory
        final savedPath = await FileSaver.instance.saveFile(
          name: baseName,
          bytes: bytes,
          fileExtension: 'mcpack',
          mimeType: MimeType.other,
        );
        savedMessage = 'Saved $pName to Downloads!';
        print('Saved to: $savedPath');
      } catch (e) {
        print('FileSaver error: $e. Fallback to storage directory.');
        try {
          io.Directory? targetDir = await getExternalStorageDirectory();
          if (targetDir != null) {
            // Check for standard Download directory path on Android
            final downloadDir = io.Directory('/storage/emulated/0/Download');
            if (await downloadDir.exists()) {
              targetDir = downloadDir;
            }
            final file = io.File('${targetDir.path}/$pName');
            await file.writeAsBytes(_generatedPackBytes!);
            savedMessage = 'Saved to ${targetDir.path}/$pName';
          }
        } catch (e2) {
          print('Fallback download error: $e2');
        }
      }
    }

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(
                Icons.check_circle,
                color: Color(0xFF6DE846),
                size: 18,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(savedMessage, overflow: TextOverflow.ellipsis),
              ),
            ],
          ),
          backgroundColor: const Color(0xFF181E19),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _openWithMinecraft() async {
    if (_generatedPackBytes == null) return;
    String pName =
        _generatedPackName ??
        (shaderNameController.text.trim().isEmpty
            ? "Piglix Shader"
            : shaderNameController.text.trim());
    if (!pName.endsWith('.mcpack')) pName = '$pName.mcpack';

    if (kIsWeb) {
      await _downloadPack();
      try {
        html.window.open('minecraft://', '_self');
      } catch (_) {}
    } else {
      try {
        final dir = await getTemporaryDirectory();
        final file = io.File('${dir.path}/$pName');
        await file.writeAsBytes(_generatedPackBytes!);

        final platform = const MethodChannel('com.piglix.shader/launcher');
        await platform.invokeMethod('openWithMinecraft', {
          'filePath': file.path,
        });
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Could not open Minecraft: $e')),
          );
        }
      }
    }
  }

  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Color(0xFF071A14),
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
        systemNavigationBarColor: Color(0xFF071A14),
        systemNavigationBarIconBrightness: Brightness.light,
      ),
    );
  }

  @override
  void dispose() {
    shaderNameController.dispose();
    _settingsScrollController.dispose();
    super.dispose();
  }

  // Customization State
  bool _timeAtmosphereExpanded = true;
  TextEditingController shaderNameController = TextEditingController(
    text: "Piglix Shader",
  );
  Color morningColor = const Color(0xFFFF9AA2);
  Color noonColor = const Color(0xFF87CEEB);
  Color eveningColor = const Color(0xFFFFA500);
  Color nightColor = const Color(0xFF00008B);

  // God Ray Colors (per time-of-day)
  Color rayMorningColor = const Color(0xFFFFA040); // Warm golden sunrise
  Color rayNoonColor = const Color(0xFFFAFCFF); // Pure white daylight
  Color rayEveningColor = const Color(0xFFFF6020); // Deep orange sunset
  Color rayNightColor = const Color(0xFF3050AA); // Cool blue moonlight
  Color fogColor = const Color(0xFFC0BCE6);
  Color waterColor = const Color(0xFF4287F5);

  // Pro Settings
  String waterQuality = 'Ultra';
  String shadowFidelity = 'Soft Shadows (1024px)';
  String cloudType = 'Realistic 3D';
  bool wavingFoliage = true;
  String volumetricRays = 'Cinematic (Heavy)';
  String worldReflections = 'Off (Matte)';
  bool enablePBR = true;
  bool enablePointLightShadows = true;
  double lightIntensity = 1.0;
  double fogDensity = 1.0;
  double sunSize = 1.0;
  double globalSaturation = 1.0;
  String toneMapFilter = 'ACES (Cinematic)';
  double nightVision = 1.5;
  bool underwaterCaustics = true;

  double windSpeed = 1.0;

  // New Advanced Features
  Color rainFogColor = const Color(0xFF5A636A);
  Color rainWaterColor = const Color(0xFF2E3D48);
  Color torchLightColor = const Color(0xFFFF9933);
  double blockLightIntensity = 1.0;
  double bloomIntensity = 1.0;
  double autoExposure = 1.0;
  Color cloudTopColor = const Color(0xFFFFFFFF);
  Color cloudBottomColor = const Color(0xFFB0B4B8);
  double globalMetalness = 0.0;
  double contrast = 1.0;

  void _showTooltip(String title, String info) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF0D3B2A),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: Color(0xFF43D17A), width: 2),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.w800,
            color: Color(0xFF43D17A),
            fontSize: 16,
          ),
        ),
        content: Text(
          info,
          style: const TextStyle(
            color: Color(0xFFB9D9C5),
            fontSize: 14,
            height: 1.5,
          ),
        ),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2AAE63),
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'GOT IT',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTitleWithHelp(String title, String _) {
    return Text(
      title,
      style: const TextStyle(
        fontWeight: FontWeight.w900,
        color: Colors.white,
        fontSize: 14.5,
        letterSpacing: 0.3,
        shadows: [
          Shadow(
            color: Colors.black,
            blurRadius: 6,
            offset: Offset(0, 1.5),
          ),
          Shadow(
            color: Color(0xAA000000),
            blurRadius: 10,
          ),
        ],
      ),
    );
  }

  void _pickColor(
    BuildContext context,
    String title,
    Color currentColor,
    Function(Color) onColorChanged,
  ) {
    Color tempColor = currentColor;
    final TextEditingController hexController = TextEditingController(
      text: currentColor.value.toRadixString(16).substring(2).toUpperCase(),
    );

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            backgroundColor: const Color(0xFF0D3B2A),
            surfaceTintColor: Colors.transparent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: const BorderSide(color: Color(0xFF43D17A), width: 2),
            ),
            titlePadding: const EdgeInsets.only(
              top: 24,
              left: 24,
              right: 24,
              bottom: 8,
            ),
            title: Text(
              'DEFINE ${title.toUpperCase()}',
              style: const TextStyle(
                fontWeight: FontWeight.w800,
                color: Color(0xFF43D17A),
                fontSize: 16,
                letterSpacing: 1.5,
              ),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 24,
              vertical: 12,
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Divider(color: Color(0xFF227A51), thickness: 1),
                  const SizedBox(height: 16),
                  ColorPicker(
                    pickerColor: tempColor,
                    onColorChanged: (c) {
                      setDialogState(() {
                        tempColor = c;
                        hexController.text = c.value
                            .toRadixString(16)
                            .substring(2)
                            .toUpperCase();
                      });
                    },
                    enableAlpha: false,
                    displayThumbColor: true,
                    hexInputBar: false, // We use our custom one below
                    labelTypes: const [],
                    paletteType: PaletteType.hsvWithHue,
                    pickerAreaBorderRadius: BorderRadius.circular(
                      8,
                    ), // Make it properly rounded
                    pickerAreaHeightPercent: 0.75,
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      const Text(
                        'Hex',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextField(
                          controller: hexController,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1,
                          ),
                          decoration: InputDecoration(
                            isDense: true,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 10,
                            ),
                            filled: true,
                            fillColor: const Color(0xFF08281D),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: const BorderSide(
                                color: Color(0xFF227A51),
                                width: 1.5,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: const BorderSide(
                                color: Color(0xFF43D17A),
                                width: 2,
                              ),
                            ),
                          ),
                          onChanged: (val) {
                            if (val.length == 6) {
                              setDialogState(() {
                                tempColor = Color(
                                  int.parse('FF$val', radix: 16),
                                );
                              });
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            actionsPadding: const EdgeInsets.only(bottom: 20, right: 24),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text(
                  'CANCEL',
                  style: TextStyle(
                    color: Color(0xFFA6C9B4),
                    letterSpacing: 1,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2AAE63),
                  foregroundColor: Colors.white,
                  elevation: 4,
                  shadowColor: const Color(0xFF16834D).withOpacity(0.55),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: () {
                  setState(() => onColorChanged(tempColor));
                  Navigator.pop(context);
                },
                child: const Text(
                  'CONFIRM',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isCompactWidth = MediaQuery.sizeOf(context).width < 390;
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Color(0xFF020805),
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
        systemNavigationBarColor: Color(0xFF020805),
        systemNavigationBarIconBrightness: Brightness.light,
      ),
    );
    return Scaffold(
      backgroundColor: const Color(0xFF020805),
      drawer: Drawer(
        backgroundColor: const Color(0xFF030A06),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                padding: const EdgeInsets.fromLTRB(22, 24, 22, 20),
                decoration: const BoxDecoration(
                  color: Color(0xFF071C12),
                  border: Border(bottom: BorderSide(color: Color(0xFF15803D), width: 1.5)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF43D17A).withOpacity(0.35),
                            blurRadius: 16,
                          ),
                        ],
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: Image.memory(kPiglixLogoBytes, fit: BoxFit.cover),
                    ),
                    const SizedBox(height: 14),
                    const Text(
                      'Shader Generator for MCPE',
                      style: TextStyle(
                        color: Color(0xFFE7FFF0),
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Minecraft Bedrock Vibrant Visuals Editor • v1.0',
                      style: TextStyle(color: Color(0xFFA6C9B4), fontSize: 11),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  children: [
                    _drawerTile(
                      Icons.tune_rounded,
                      'Shader Editor',
                      'Customize lighting & atmosphere',
                      () => Navigator.pop(context),
                    ),
                    const Divider(color: Color(0xFF14382B), height: 24, indent: 16, endIndent: 16),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 6),
                      child: Text(
                        'LEGAL & COMPLIANCE',
                        style: TextStyle(
                          color: Color(0xFF34D399),
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ),
                    _drawerTile(
                      Icons.privacy_tip_outlined,
                      'Privacy Policy',
                      'Data collection & permissions',
                      () {
                        Navigator.pop(context);
                        Navigator.push(context, MaterialPageRoute(builder: (_) => const LegalPage(
                          title: 'Privacy Policy',
                          icon: Icons.privacy_tip_outlined,
                          sections: [
                            LegalSection('Shader Generator for MCPE — Privacy Policy', null, isHeader: true),
                            LegalSection('Piglix Labs • Last updated: October 1, 2026', null, isMuted: true),
                            LegalSection('Overview', 'Piglix Labs ("we", "our", or "us") operates the Shader Generator for MCPE mobile application. This page informs you of our policies regarding the collection, use, and disclosure of personal data when you use our Application.'),
                            LegalSection('1. Information Collection and Use', 'Shader Generator for MCPE is designed as a standalone utility tool:\n\n• Zero Personal Data Collection: We do NOT collect, store, or sell any personally identifiable information (PII) such as your name, email, phone number, or physical location.\n\n• Local Processing: All shader configurations, lighting adjustments, and pack generations are processed directly and locally on your device.'),
                            LegalSection('2. Device Storage & File Permissions', 'The Application may request permission to access device storage solely for the purpose of exporting and saving generated shader .mcpack files directly to your device or Minecraft resource pack folder. We do not access, read, or modify any personal photos, private documents, or unrelated files.'),
                            LegalSection('3. Third-Party Advertising & Services', 'We may display advertisements to keep this application free for everyone. We use third-party advertising partners such as Google AdMob. These ad networks may collect anonymized device identifiers or ad interaction data according to their own privacy policies. For more info: https://policies.google.com/privacy'),
                            LegalSection('4. Children\'s Privacy', 'Our Application is intended for general audiences (ages 13 and above). We do not knowingly collect personal identifiable information from children under 13.'),
                            LegalSection('5. Changes to This Policy', 'We may update our Privacy Policy periodically. Any updates will be posted directly to this page with a revised "Last updated" date.'),
                            LegalSection('6. Contact Us', 'If you have questions regarding our Privacy Policy, contact us at:\n\nEmail: realpiglix@gmail.com'),
                          ],
                        )));
                      },
                    ),
                    _drawerTile(
                      Icons.gavel_outlined,
                      'Terms of Service',
                      'App usage & license terms',
                      () {
                        Navigator.pop(context);
                        Navigator.push(context, MaterialPageRoute(builder: (_) => const LegalPage(
                          title: 'Terms of Service',
                          icon: Icons.gavel_outlined,
                          sections: [
                            LegalSection('Shader Generator for MCPE — Terms of Service', null, isHeader: true),
                            LegalSection('Piglix Labs • Last updated: October 1, 2026', null, isMuted: true),
                            LegalSection('1. App Purpose & Usage', 'Shader Generator for MCPE is a free, unofficial companion tool intended solely to assist users in creating and modifying shader packs and lighting textures for personal use in Minecraft Bedrock Edition / MCPE.'),
                            LegalSection('2. User Responsibility', 'You are solely responsible for the content you generate. You agree not to use this tool to modify files in ways that violate the End User License Agreement (EULA) of Minecraft or any third-party copyrights.'),
                            LegalSection('3. Limitation of Liability', 'The app is provided "AS IS". Piglix Labs assumes no liability for game crashes, data loss, or account issues resulting from the use of custom shaders generated by this tool.'),
                            LegalSection('4. Intellectual Property', 'The app\'s code and original UI are copyright Piglix Labs. Users retain rights to their custom shader configurations.'),
                            LegalSection('5. Contact', 'Email: realpiglix@gmail.com\nWebsite: https://piglixmcmods.dev'),
                          ],
                        )));
                      },
                    ),
                    _drawerTile(
                      Icons.verified_user_outlined,
                      'Trademark & Legal Notice',
                      'Mojang & Microsoft disclaimer',
                      () {
                        Navigator.pop(context);
                        Navigator.push(context, MaterialPageRoute(builder: (_) => const LegalPage(
                          title: 'Trademark & Legal Disclaimer',
                          icon: Icons.verified_user_outlined,
                          sections: [
                            LegalSection('UNOFFICIAL MINECRAFT COMPANION APP', null, isHeader: true),
                            LegalSection('Important Notice', 'NOT AN OFFICIAL MINECRAFT PRODUCT. NOT APPROVED BY OR ASSOCIATED WITH MOJANG OR MICROSOFT.'),
                            LegalSection('Trademark Information', '• "Minecraft" is a registered trademark of Mojang Synergies AB.\n\n• All Minecraft assets, brands, and textures belong strictly to Mojang AB and Microsoft Corporation.\n\n• Shader Generator for MCPE is an independent, third-party utility created by fans for fans. It is not affiliated with, endorsed by, sponsored by, or otherwise connected to Mojang AB or Microsoft Corporation in any way.\n\n• This app complies with the Minecraft Commercial Usage Guidelines.'),
                          ],
                        )));
                      },
                    ),
                    _drawerTile(
                      Icons.code_rounded,
                      'Open Source Licenses',
                      'Third-party software notices',
                      () {
                        Navigator.pop(context);
                        Navigator.push(context, MaterialPageRoute(builder: (_) => const LegalPage(
                          title: 'Open Source Licenses',
                          icon: Icons.code_rounded,
                          sections: [
                            LegalSection('Open Source Software Notices', null, isHeader: true),
                            LegalSection('Included Libraries', 'Shader Generator for MCPE includes software licensed under open source terms:'),
                            LegalSection('Flutter SDK', 'License: BSD-3-Clause\nCopyright © Google LLC'),
                            LegalSection('Archive Library', 'License: MIT'),
                            LegalSection('File Saver & File Picker', 'License: MIT'),
                            LegalSection('Path Provider', 'License: BSD-3-Clause'),
                            LegalSection('Universal HTML', 'License: MIT'),
                            LegalSection('UUID Package', 'License: MIT'),
                            LegalSection('Acknowledgement', 'We express our sincere gratitude to the open-source community for making this app possible.'),
                          ],
                        )));
                      },
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.all(16),
                color: const Color(0xFF04100D),
                child: const Text(
                  'NOT AN OFFICIAL MINECRAFT PRODUCT. NOT APPROVED BY OR ASSOCIATED WITH MOJANG OR MICROSOFT.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Color(0xFF4B6B5B),
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                    height: 1.3,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      body: SafeArea(
        child: NotificationListener<ScrollNotification>(
          onNotification: (notification) {
            if (notification is ScrollUpdateNotification &&
                notification.scrollDelta != null) {
              final nextHeight = (_navHeight - notification.scrollDelta!).clamp(
                0.0,
                82.0,
              );
              if (nextHeight != _navHeight)
                setState(() => _navHeight = nextHeight);
            }
            return false;
          },
          child: Container(
            decoration: const BoxDecoration(color: Color(0xFF020805)),
            child: SingleChildScrollView(
              controller: _settingsScrollController,
              padding: EdgeInsets.fromLTRB(
                isCompactWidth ? 12 : 20,
                14,
                isCompactWidth ? 12 : 20,
                32,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: double.infinity,
                    child: Row(
                      children: [
                        Builder(
                          builder: (ctx) => Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: () => Scaffold.of(ctx).openDrawer(),
                              borderRadius: BorderRadius.circular(4),
                              child: Container(
                                width: 42,
                                height: 42,
                                decoration: BoxDecoration(
                                  color: const Color(0xFF071C12),
                                  borderRadius: BorderRadius.circular(4),
                                  border: Border.all(
                                    color: const Color(0xFF15803D),
                                    width: 1.5,
                                  ),
                                ),
                                child: const Icon(
                                  Icons.menu_rounded,
                                  color: Color(0xFF22C55E),
                                  size: 24,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.memory(
                            kPiglixLogoBytes,
                            width: 36,
                            height: 36,
                            fit: BoxFit.cover,
                          ),
                        ),
                        const SizedBox(width: 10),
                        const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text.rich(
                              TextSpan(
                                children: [
                                  TextSpan(
                                    text: 'PIGLIX',
                                    style: TextStyle(color: Color(0xFFE7FFF0)),
                                  ),
                                  TextSpan(
                                    text: ' LAB',
                                    style: TextStyle(color: Color(0xFF43D17A)),
                                  ),
                                ],
                              ),
                              style: TextStyle(
                                fontSize: 19,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 1.1,
                              ),
                            ),
                            SizedBox(height: 2),
                            Text(
                              'Shaders  •  Packs  •  More',
                              style: TextStyle(
                                color: Color(0xFF7FAF8F),
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                        const Spacer(),
                      ],
                    ),
                  ),
                const SizedBox(height: 18),

                // ── UPLOAD CUSTOM SHADER CARD ───────────────────────────────────
                Container(
                  width: double.infinity,
                  constraints: const BoxConstraints(minHeight: 285),
                  decoration: BoxDecoration(
                    color: const Color(0xFF062C20),
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(
                      color: const Color(0xFF0D6844),
                      width: 1.2,
                    ),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x66000000),
                        blurRadius: 18,
                        offset: Offset(0, 8),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.fromLTRB(16, 18, 16, 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            _uploadedShaderBytes != null
                                ? Icons.check_circle
                                : Icons.upload_file,
                            color: _uploadedShaderBytes != null
                                ? const Color(0xFF43D17A)
                                : const Color(0xFFA6C9B4),
                            size: 18,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              _uploadedShaderBytes != null
                                  ? 'CUSTOM SHADER LOADED'
                                  : 'SHADER SOURCE',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 19,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 0.6,
                                color: _uploadedShaderBytes != null
                                    ? const Color(0xFF43D17A)
                                    : const Color(0xFFA6C9B4),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 5),
                      Text(
                        _uploadedShaderBytes != null
                            ? 'Your pack is ready to customize'
                            : 'Start with a pack or use the Piglix default',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFFB9D9C5),
                        ),
                      ),
                      const SizedBox(height: 10),
                      if (_uploadedShaderBytes != null) ...[
                        // Current shader name (shown only after a custom pack is selected)
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFF08281D),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: const Color(0xFFFFFFFF).withOpacity(0.7),
                            ),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.folder_zip_outlined,
                                size: 14,
                                color: Color(0xFFA6C9B4),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  _uploadedShaderName ??
                                      'Piglix Default (base_shader.zip)',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: _uploadedShaderBytes != null
                                        ? const Color(0xFFE7FFF0)
                                        : const Color(0xFFA6C9B4),
                                    fontStyle: _uploadedShaderBytes != null
                                        ? FontStyle.normal
                                        : FontStyle.italic,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              if (_uploadedShaderBytes != null)
                                GestureDetector(
                                  onTap: _clearUploadedShader,
                                  child: const Icon(
                                    Icons.close,
                                    size: 16,
                                    color: Colors.red,
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ],
                      const SizedBox(height: 12),
                      // Upload button
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: ElevatedButton.icon(
                          onPressed: _isUploadingShader
                              ? null
                              : _pickShaderFile,
                          icon: _isUploadingShader
                              ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Icon(
                                  Icons.file_upload_outlined,
                                  size: 18,
                                ),
                          label: Text(
                            _isUploadingShader
                                ? 'Loading...'
                                : _uploadedShaderBytes != null
                                ? 'Replace Shader to Edit (.mcpack / .zip)'
                                : 'Upload Shader to Edit (.mcpack / .zip)',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _uploadedShaderBytes != null
                                ? const Color(0xFF16834D)
                                : const Color(0xFF2AAE63),
                            foregroundColor: Colors.white,
                            elevation: 5,
                            shadowColor: const Color(0x552AAE63),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            side: const BorderSide(
                              color: Color(0xFFFFFFFF),
                              width: 1,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: OutlinedButton.icon(
                          onPressed: () {
                            _clearUploadedShader();
                            WidgetsBinding.instance.addPostFrameCallback(
                              (_) => _scrollToPackIcon(),
                            );
                          },
                          icon: const Icon(
                            Icons.auto_awesome_rounded,
                            size: 18,
                          ),
                          label: const Text(
                            'Create Your Own Shader',
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.3,
                            ),
                          ),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: const Color(0xFFA6C9B4),
                            side: const BorderSide(
                              color: Color(0xFF43D17A),
                              width: 1,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                      if (_uploadedShaderBytes != null) ...[
                        const SizedBox(height: 8),
                        const Text(
                          '⚡ All settings below will be applied to your uploaded shader when you generate.',
                          style: TextStyle(
                            fontSize: 11,
                            color: Color(0xFF7FAF8F),
                          ),
                        ),
                      ] else ...[
                        const SizedBox(height: 8),
                        const Text(
                          'Upload any Vibrant Visuals .mcpack to edit its lighting, colors & atmosphere.',
                          style: TextStyle(
                            fontSize: 11,
                            color: Color(0xFF607A92),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),

                // ─────────────────────────────────────────────────────────────────
                const SizedBox(height: 24),

                // ── PACK ICON / LOGO CARD ─────────────────────────────────────────
                Container(
                  key: _packIconKey,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: const Color(0xFF062C20),
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(
                      color: const Color(0xFF0D6844),
                      width: 1.2,
                    ),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x66000000),
                        blurRadius: 18,
                        offset: Offset(0, 8),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Logo preview
                      Container(
                        width: 72,
                        height: 72,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: _uploadedLogoBytes != null
                                ? const Color(0xFF43D17A)
                                : const Color(0xFF43D17A).withOpacity(0.25),
                            width: 1.5,
                          ),
                          color: const Color(0xFF08281D),
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: _uploadedLogoBytes != null
                            ? Image.memory(
                                _uploadedLogoBytes!,
                                fit: BoxFit.cover,
                              )
                            : Image.memory(kPiglixLogoBytes, fit: BoxFit.cover),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  _uploadedLogoBytes != null
                                      ? Icons.check_circle
                                      : Icons.image_outlined,
                                  size: 14,
                                  color: _uploadedLogoBytes != null
                                      ? const Color(0xFF43D17A)
                                      : const Color(0xFFA6C9B4),
                                ),
                                const SizedBox(width: 6),
                                Expanded(
                                  child: Text(
                                    _uploadedLogoBytes != null
                                        ? 'CUSTOM LOGO'
                                        : 'PACK ICON',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w900,
                                      letterSpacing: 0.6,
                                      color: _uploadedLogoBytes != null
                                          ? const Color(0xFF43D17A)
                                          : const Color(0xFFA6C9B4),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _uploadedLogoName ?? 'Default Piglix Logo',
                              style: TextStyle(
                                fontSize: 12,
                                color: _uploadedLogoBytes != null
                                    ? const Color(0xFFE7FFF0)
                                    : const Color(0xFFA6C9B4),
                                fontStyle: _uploadedLogoBytes != null
                                    ? FontStyle.normal
                                    : FontStyle.italic,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 10),
                            Row(
                              children: [
                                Expanded(
                                  child: SizedBox(
                                    height: 36,
                                    child: ElevatedButton.icon(
                                      onPressed: _isUploadingLogo
                                          ? null
                                          : _pickLogoFile,
                                      icon: _isUploadingLogo
                                          ? const SizedBox(
                                              width: 14,
                                              height: 14,
                                              child: CircularProgressIndicator(
                                                strokeWidth: 2,
                                                color: Colors.white,
                                              ),
                                            )
                                          : const Icon(
                                              Icons.image_outlined,
                                              size: 16,
                                            ),
                                      label: Text(
                                        _isUploadingLogo
                                            ? 'Loading...'
                                            : 'Upload Logo',
                                        style: const TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: const Color(
                                          0xFF0B4C31,
                                        ),
                                        foregroundColor: const Color(
                                          0xFFA6C9B4,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                        ),
                                        side: const BorderSide(
                                          color: Color(0xFF43D17A),
                                          width: 1,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                if (_uploadedLogoBytes != null) ...[
                                  const SizedBox(width: 8),
                                  GestureDetector(
                                    onTap: _clearUploadedLogo,
                                    child: Container(
                                      height: 36,
                                      width: 36,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(
                                          color: Colors.red.withOpacity(0.5),
                                        ),
                                        color: Colors.red.withOpacity(0.08),
                                      ),
                                      child: const Icon(
                                        Icons.close,
                                        color: Colors.red,
                                        size: 16,
                                      ),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // ─────────────────────────────────────────────────────────────────
                const SizedBox(height: 28),

                _buildSettings(),

                const SizedBox(height: 48),

                // Professional Action Area
                if (!_isGenerated)
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF14532D),
                        foregroundColor: const Color(0xFFFFFFFF),
                        side: const BorderSide(color: Color(0xFF22C55E), width: 1.5),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4),
                        ),
                        elevation: 4,
                      ),
                      onPressed: _compileShader,
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.auto_awesome,
                            size: 20,
                            color: Color(0xFF22C55E),
                          ),
                          SizedBox(width: 12),
                          Text(
                            'GENERATE SHADER',
                            style: TextStyle(
                              fontWeight: FontWeight.w900,
                              letterSpacing: 1.5,
                              fontSize: 15,
                              color: Color(0xFFFFFFFF),
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                else ...[
                  Row(
                    children: [
                      Expanded(
                        child: SizedBox(
                          height: 56,
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF14532D),
                              foregroundColor: const Color(0xFFFFFFFF),
                              side: const BorderSide(color: Color(0xFF22C55E), width: 1.5),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(4),
                              ),
                              elevation: 4,
                            ),
                            onPressed: _openWithMinecraft,
                            icon: const Icon(
                              Icons.play_arrow_rounded,
                              size: 26,
                              color: Color(0xFF22C55E),
                            ),
                            label: const Text(
                              'OPEN WITH MINECRAFT',
                              style: TextStyle(
                                fontWeight: FontWeight.w900,
                                letterSpacing: 1.2,
                                fontSize: 14,
                                color: Color(0xFFFFFFFF),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      SizedBox(
                        width: 56,
                        height: 56,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF08140E),
                            foregroundColor: const Color(0xFF22C55E),
                            padding: EdgeInsets.zero,
                            side: const BorderSide(
                              color: Color(0xFF14532D),
                              width: 1.5,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(4),
                            ),
                            elevation: 2,
                          ),
                          onPressed: _downloadPack,
                          child: const Icon(
                            Icons.download_rounded,
                            size: 26,
                            color: Color(0xFF22C55E),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Center(
                    child: TextButton.icon(
                      onPressed: () => setState(() => _isGenerated = false),
                      icon: const Icon(
                        Icons.refresh,
                        size: 16,
                        color: Color(0xFF7FAF8F),
                      ),
                      label: const Text(
                        'Edit settings & regenerate',
                        style: TextStyle(
                          color: Color(0xFF7FAF8F),
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeroBanner() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFF071F17),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: const Color(0xFF43D17A), width: 2.5),
        boxShadow: const [
          BoxShadow(
            color: Color(0x99000000),
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(2),
        child: Stack(
            alignment: Alignment.bottomCenter,
            children: [
              Image.asset(
                'assets/banner.webp',
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  height: 120,
                  color: const Color(0xFF0F261F),
                  child: const Center(
                    child: Text(
                      'Shader Generator for MCPE',
                      style: TextStyle(
                        color: Color(0xFF34D399),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
    );
  }

  Widget _buildSettings() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 20),

        // Shader name field with green/blue theme
        TextField(
          controller: shaderNameController,
          style: const TextStyle(
            color: Color(0xFFE7FFF0),
            fontWeight: FontWeight.bold,
          ),
          decoration: const InputDecoration(
            labelText: 'Custom Shader Name',
            labelStyle: TextStyle(color: Color(0xFFA6C9B4)),
            filled: true,
            fillColor: Color(0xFF08281D),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Color(0xFF227A51), width: 1),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Color(0xFF43D17A), width: 2),
            ),
            prefixIcon: Icon(Icons.edit, color: Color(0xFF43D17A)),
          ),
        ),
        const SizedBox(height: 28),

        _buildCategoryCard(
          'TIME & ATMOSPHERE',
          Icons.wb_sunny,
          [
          _sliderRow(
            'Sun Size Multiplier',
            'Mathematically scales the size of the Sun and Moon textures rendered in the skybox. Larger values create a massive, cinematic celestial body, while smaller values look more realistic.',
            sunSize,
            0.0,
            2.0,
            20,
            sunSize == 1.0
                ? '1.0x (Default)'
                : '${sunSize.toStringAsFixed(1)}x',
            (v) => sunSize = v,
            bgAsset: 'assets/sun_multiplier_bg.jpg',
          ),
          _sliderRow(
            'Night Brightness',
            'Overrides the vanilla Minecraft moonlight intensity. Increasing this makes midnight completely visible without torches, while lowering it creates pitch-black, hardcore darkness.',
            nightVision,
            0.0,
            2.0,
            20,
            nightVision == 1.5
                ? '1.5x (Default)'
                : '${nightVision.toStringAsFixed(1)}x',
            (v) => nightVision = v,
            bgAsset: 'assets/night_brightness_bg.jpg',
          ),
          _sliderRow(
            'Fog Density',
            'Adjusts how close the atmospheric fog starts relative to the player. Higher density obscures distant chunks completely, creating a thick, moody atmosphere.',
            fogDensity,
            0.0,
            2.0,
            20,
            fogDensity == 1.0
                ? '1.0x (Default)'
                : '${fogDensity.toStringAsFixed(1)}x',
            (v) => fogDensity = v,
            bgAsset: 'assets/fog_density_bg.jpg',
          ),
          _dropdownRow(
            'Volumetric Fog',
            'Defines the quality and depth of 3D God-Rays intersecting the fog. Cinematic calculates high-density scattering but costs more FPS. Low End uses flat rendering.',
            ['Cinematic (Heavy)', 'Balanced', 'Low End'],
            volumetricRays,
            (v) => volumetricRays = v,
          ),
          _timeOfDayColorsPanel(),
        ],
        initiallyExpanded: true,
        ),
        const SizedBox(height: 18),

        _buildCategoryCard(
          'WEATHER OVERRIDES',
          Icons.thunderstorm,
          [
            _compactColorPickerRow([
              _ColorNode('Rain Fog', '', rainFogColor, (c) => rainFogColor = c),
              _ColorNode(
                'Rain Water',
                '',
                rainWaterColor,
                (c) => rainWaterColor = c,
              ),
              _ColorNode(
                'Cloud Top',
                'Defines the color of clouds where sunlight hits directly.',
                cloudTopColor,
                (c) => cloudTopColor = c,
              ),
              _ColorNode(
                'Cloud Bottom',
                'Defines the shadow color underneath the clouds.',
                cloudBottomColor,
                (c) => cloudBottomColor = c,
              ),
            ]),
          ],
          subtitle: 'Customize rain, water, and cloud colors',
          initiallyExpanded: false,
        ),
        const SizedBox(height: 18),

        _buildCategoryCard(
          'LIGHTING & SHADOWS',
          Icons.lightbulb,
          [
          _sliderRow(
            'Light Intensity',
            'Multiplies the global directional light from the Sun and Moon. This affects how bright the surface of blocks appear when exposed directly to the sky.',
            lightIntensity,
            0.0,
            2.0,
            20,
            lightIntensity == 1.0
                ? '1.0x (Default)'
                : '${lightIntensity.toStringAsFixed(1)}x',
            (v) => lightIntensity = v,
            bgAsset: 'assets/light_intensity_bg.jpg',
          ),
          _sliderRow(
            'Block Light Intensity',
            'Boosts the emissive strength and radius of all point lights. This allows a single torch to illuminate massive caves, completely changing the survival experience.',
            blockLightIntensity,
            0.0,
            2.0,
            20,
            blockLightIntensity == 1.0
                ? '1.0x (Default)'
                : '${blockLightIntensity.toStringAsFixed(1)}x',
            (v) => blockLightIntensity = v,
            bgAsset: 'assets/block_light_bg.jpg',
          ),
          _dropdownRow(
            'Shadow Fidelity',
            'Controls the resolution of the shadow maps cast by the Sun. Soft Shadows uses high-res 1024px maps with soft-edge filtering, while Hard Shadows creates sharp edges.',
            [
              'Off',
              'Ultra-Low (128px)',
              'Hard Shadows (256px)',
              'Soft Shadows (1024px)',
            ],
            shadowFidelity,
            (v) => shadowFidelity = v,
          ),
          _switchRow(
            'Point Light Shadows',
            'Enables highly experimental real-time ray-traced shadows cast by Torches and Lava. This makes the game look incredible but can be heavy on mobile devices.',
            enablePointLightShadows,
            (v) => enablePointLightShadows = v,
          ),
          const SizedBox(height: 8),
          _godRaysPanel(),
        ],
        initiallyExpanded: false,
        ),
        const SizedBox(height: 18),

        _buildCategoryCard(
          'WORLD & WATER',
          Icons.public,
          [
          _sliderRow(
            'Wind & Wave Speed',
            'Modifies the internal shader time-multiplier for vertex animations. This makes oceans and lakes look like they have fast, aggressive currents or slow, calm ripples.',
            windSpeed,
            0.0,
            2.0,
            20,
            windSpeed == 1.0
                ? '1.0x (Default)'
                : '${windSpeed.toStringAsFixed(1)}x',
            (v) => windSpeed = v,
            bgAsset: 'assets/wind_waves_bg.jpg',
          ),
          _dropdownRow(
            'Water Quality',
            'Controls the noise complexity (octaves) of the water surface. Ultra calculates multiple layers of overlapping waves for a highly realistic, churning ocean.',
            ['Low', 'Medium', 'Ultra'],
            waterQuality,
            (v) => waterQuality = v,
          ),
          _switchRow(
            'Underwater Caustics',
            'Generates animated, waving light patterns on the floor of oceans and rivers when the sun shines through the water surface.',
            underwaterCaustics,
            (v) => underwaterCaustics = v,
          ),
          _dropdownRow(
            'World Reflections',
            'Overrides the global PBR roughness of all blocks. Setting this to Ultra makes every block in the world behave like a mirror, reflecting the sky and clouds.',
            ['Off (Matte)', 'Low (Glossy)', 'High (Wet)', 'Ultra (Mirror)'],
            worldReflections,
            (v) => worldReflections = v,
          ),
          _sliderRow(
            'Global Metalness',
            'Overrides the global PBR metalness of all blocks. Increasing this makes blocks absorb light like conductive metals, giving everything a shiny, synthetic look.',
            globalMetalness,
            0.0,
            10.0,
            10,
            globalMetalness == 0.0
                ? '0.0 (Default)'
                : '${globalMetalness.toStringAsFixed(1)}',
            (v) => globalMetalness = v,
            bgAsset: 'assets/global_metalness_bg.jpg',
          ),
          _switchRow(
            'PBR Bump Mapping',
            'Activates the Normal/MER texture mapping pipeline. If you have a PBR texture pack installed, this will give blocks true 3D depth and bumpy surfaces.',
            enablePBR,
            (v) => enablePBR = v,
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(12, 14, 12, 14),
            decoration: BoxDecoration(
              color: const Color(0xFF062C20),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFF0D6844), width: 1),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(
                      Icons.palette_outlined,
                      color: Color(0xFF8BE0B0),
                      size: 24,
                    ),
                    SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'ATMOSPHERE COLORS',
                          style: TextStyle(
                            color: Color(0xFFE7FFF0),
                            fontSize: 17,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          'Customize fog, torch, and water colors',
                          style: TextStyle(
                            color: Color(0xFF7FAF8F),
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                _compactColorPickerRow([
                  _ColorNode('Fog Tint', '', fogColor, (c) => fogColor = c),
                  _ColorNode(
                    'Torch Light',
                    '',
                    torchLightColor,
                    (c) => torchLightColor = c,
                  ),
                  _ColorNode(
                    'Water Tint',
                    'Tints the surface color and depth scattering of all water in the world. (Does not affect rain-overridden water).',
                    waterColor,
                    (c) => waterColor = c,
                  ),
                ]),
              ],
            ),
          ),
        ]),
      ],
    );
  }

  Widget _godRaysPanel() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(vertical: 10),
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 18),
      decoration: BoxDecoration(
        color: const Color(0xFF071C12),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: const Color(0xFF15803D), width: 1.8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(
                Icons.wb_sunny_rounded,
                size: 24,
                color: Color(0xFF39FF14),
              ),
              SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'GOD RAYS — TIME OF DAY',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Color(0xFFE7FFF0),
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.8,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Customize direct light colors for each time of day',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Color(0xFF7FAF8F),
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Expanded(
                child: _buildTimeCard(
                  'Morning',
                  rayMorningColor,
                  (c) => rayMorningColor = c,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildTimeCard(
                  'Noon',
                  rayNoonColor,
                  (c) => rayNoonColor = c,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildTimeCard(
                  'Evening',
                  rayEveningColor,
                  (c) => rayEveningColor = c,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildTimeCard(
                  'Night',
                  rayNightColor,
                  (c) => rayNightColor = c,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _timeOfDayColorsPanel() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(vertical: 10),
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 18),
      decoration: BoxDecoration(
        color: const Color(0xFF071C12),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: const Color(0xFF15803D), width: 1.8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            onTap: () {
              setState(() {
                _timeAtmosphereExpanded = !_timeAtmosphereExpanded;
              });
            },
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 2),
              child: Row(
                children: [
                  const Icon(
                    Icons.wb_sunny_rounded,
                    color: Color(0xFF39FF14),
                    size: 24,
                  ),
                  const SizedBox(width: 10),
                  const Text(
                    'TIME & ATMOSPHERE',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.8,
                    ),
                  ),
                  const Spacer(),
                  Icon(
                    _timeAtmosphereExpanded
                        ? Icons.keyboard_arrow_up_rounded
                        : Icons.keyboard_arrow_down_rounded,
                    color: const Color(0xFF39FF14),
                    size: 26,
                  ),
                ],
              ),
            ),
          ),
          if (_timeAtmosphereExpanded) ...[
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Expanded(
                  child: _buildTimeCard(
                    'Morning',
                    morningColor,
                    (c) => morningColor = c,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildTimeCard(
                    'Noon',
                    noonColor,
                    (c) => noonColor = c,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildTimeCard(
                    'Evening',
                    eveningColor,
                    (c) => eveningColor = c,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildTimeCard(
                    'Night',
                    nightColor,
                    (c) => nightColor = c,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTimeCard(
    String label,
    Color color,
    Function(Color) onChanged,
  ) {
    final hexString =
        '#${color.value.toRadixString(16).substring(2).toUpperCase()}';

    return GestureDetector(
      onTap: () => _pickColor(context, label, color, onChanged),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            height: 74,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: color, width: 2.2),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x99000000),
                  offset: Offset(0, 3),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(2),
              child: AspectRatio(
                aspectRatio: 1.0,
                child: CustomPaint(
                  painter: TimeSceneryPainter(
                    timeOfDay: label,
                    userColor: color,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 7),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.3,
            ),
          ),
          const SizedBox(height: 3),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
            decoration: BoxDecoration(
              color: color.withOpacity(0.20),
              borderRadius: BorderRadius.circular(2),
              border: Border.all(color: color.withOpacity(0.65), width: 1.0),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(color: color.withOpacity(0.8), blurRadius: 4),
                    ],
                  ),
                ),
                const SizedBox(width: 4),
                Text(
                  hexString,
                  style: TextStyle(
                    color: Color.lerp(Colors.white, color, 0.3),
                    fontSize: 9,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _compactColorPickerRow(List<Widget> pickers) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (int i = 0; i < pickers.length; i++) ...[
          if (i > 0) const SizedBox(width: 8),
          Expanded(child: pickers[i]),
        ],
      ],
    );
  }

  Widget _buildCategoryCard(
    String title,
    IconData icon,
    List<Widget> children, {
    String? subtitle,
    bool initiallyExpanded = false,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 18),
      decoration: BoxDecoration(
        color: const Color(0xFF071C12),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: const Color(0xFF15803D), width: 1.8),
        boxShadow: const [
          BoxShadow(
            color: Color(0x99000000),
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4),
        ),
        clipBehavior: Clip.antiAlias,
        child: Theme(
          data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
          child: ExpansionTile(
            initiallyExpanded: initiallyExpanded,
            iconColor: const Color(0xFF22C55E),
            collapsedIconColor: const Color(0xFF86EFAC),
            tilePadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            childrenPadding: const EdgeInsets.fromLTRB(14, 4, 14, 18),
            title: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: const Color(0xFF040A07),
                    borderRadius: BorderRadius.circular(3),
                    border: Border.all(
                      color: const Color(0xFF166534),
                      width: 1.5,
                    ),
                  ),
                  child: Icon(icon, color: const Color(0xFF22C55E), size: 16),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: subtitle == null
                      ? Text(
                          title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 18,
                            letterSpacing: 0.4,
                            color: Color(0xFFE7FFF0),
                          ),
                        )
                      : Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontWeight: FontWeight.w800,
                                fontSize: 18,
                                letterSpacing: 0.4,
                                color: Color(0xFFE7FFF0),
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              subtitle,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Color(0xFF7FAF8F),
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                ),
              ],
            ),
            children: children,
          ),
        ),
      ),
    );
  }

  Widget _sliderRow(
    String title,
    String tooltip,
    double val,
    double min,
    double max,
    int div,
    String label,
    Function(double) onChanged, {
    String? bgAsset,
    Color? borderColor,
  }) {
    const defaultBorder = Color(0xFF15803D);
    final effectiveBorderColor = borderColor ?? defaultBorder;

    final content = Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(child: _buildTitleWithHelp(title, tooltip)),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF020704),
                  borderRadius: BorderRadius.circular(3),
                  border: Border.all(
                    color: const Color(0xFF166534),
                    width: 1.5,
                  ),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x99000000),
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Text(
                  label,
                  style: const TextStyle(
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF4ADE80),
                    fontSize: 13,
                    letterSpacing: 0.3,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Column(
            children: [
              SliderTheme(
                data: SliderTheme.of(context).copyWith(
                  trackHeight: 6.0,
                  activeTrackColor: const Color(0xFF15803D),
                  inactiveTrackColor: const Color(0xFF06180E),
                  thumbColor: const Color(0xFF22C55E),
                  overlayColor: const Color(0xFF22C55E).withOpacity(0.2),
                ),
                child: Slider(
                  value: val,
                  min: min,
                  max: max,
                  divisions: div,
                  onChanged: (v) => setState(() => onChanged(v)),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Min (${min.toStringAsFixed(1)}x)',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.2,
                        shadows: [
                          Shadow(
                            color: Colors.black,
                            blurRadius: 4,
                            offset: Offset(1, 1),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      'Max (${max.toStringAsFixed(1)}x)',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.2,
                        shadows: [
                          Shadow(
                            color: Colors.black,
                            blurRadius: 4,
                            offset: Offset(1, 1),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );

    if (bgAsset != null) {
      return Container(
        margin: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: const Color(0xFF05140C),
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: effectiveBorderColor, width: 1.8),
          boxShadow: const [
            BoxShadow(
              color: Color(0x99000000),
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(2),
          child: Stack(
            children: [
              Positioned.fill(
                child: Image.asset(
                  bgAsset,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) =>
                      Container(color: const Color(0xFF071C12)),
                ),
              ),
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        const Color(0xBA000000), // ~73% black tint
                        const Color(0x9004140C), // ~56% dark green tint
                        const Color(0xC8000000), // ~78% black tint
                      ],
                      stops: const [0.0, 0.50, 1.0],
                    ),
                  ),
                ),
              ),
              content,
            ],
          ),
        ),
      );
    }

    return Container(
      margin: const EdgeInsets.only(top: 8, bottom: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF071C12),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: effectiveBorderColor, width: 1.8),
        boxShadow: const [
          BoxShadow(
            color: Color(0x99000000),
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: content,
    );
  }

  Widget _dropdownRow(
    String title,
    String tooltip,
    List<String> items,
    String val,
    Function(String) onChanged,
  ) {
    return Padding(
      padding: const EdgeInsets.only(top: 10, bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTitleWithHelp(title, tooltip),
          const SizedBox(height: 12),
          LayoutBuilder(
            builder: (context, constraints) {
              const gap = 8.0;
              final columns = items.length == 1 ? 1 : 2;
              final buttonWidth =
                  (constraints.maxWidth - (gap * (columns - 1))) / columns;
              return Wrap(
                spacing: gap,
                runSpacing: gap,
                children: items.map((e) {
                  final isSelected = e == val;
                  return SizedBox(
                    width: buttonWidth,
                    height: 44,
                    child: GestureDetector(
                      onTap: () => setState(() => onChanged(e)),
                      child: Container(
                        alignment: Alignment.center,
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? const Color(0xFF14532D)
                              : const Color(0xFF050E09),
                          borderRadius: BorderRadius.circular(3),
                          border: Border.all(
                            color: isSelected
                                ? const Color(0xFF22C55E)
                                : const Color(0xFF113822),
                            width: 1.8,
                          ),
                          boxShadow: const [
                            BoxShadow(
                              color: Color(0x88000000),
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            e,
                            maxLines: 1,
                            style: TextStyle(
                              color: const Color(0xFFE7FFF0),
                              fontWeight: isSelected
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                              fontSize: 11.5,
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _switchRow(
    String title,
    String tooltip,
    bool val,
    Function(bool) onChanged,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(child: _buildTitleWithHelp(title, tooltip)),
          const SizedBox(width: 8),
          Switch(
            value: val,
            activeColor: const Color(0xFFFFFFFF),
            activeTrackColor: const Color(0xFF43D17A),
            inactiveThumbColor: const Color(0xFFA6C9B4),
            inactiveTrackColor: const Color(0xFF1D5A3D),
            onChanged: (v) => setState(() => onChanged(v)),
          ),
        ],
      ),
    );
  }

  Widget _sectionHeader({
    required String emoji,
    required String title,
    required String subtitle,
    required Color accentColor,
    bool small = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: EdgeInsets.all(small ? 6 : 8),
              decoration: BoxDecoration(
                color: accentColor.withOpacity(0.12),
                borderRadius: BorderRadius.circular(small ? 8 : 10),
              ),
              child: Text(emoji, style: TextStyle(fontSize: small ? 14 : 18)),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: small ? 16 : 20,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      letterSpacing: 0.3,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: small ? 11 : 12,
                      color: accentColor.withOpacity(0.75),
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Container(
          height: 1,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [accentColor.withOpacity(0.5), Colors.transparent],
            ),
          ),
        ),
      ],
    );
  }

  // Legacy method kept for compatibility (no longer used)
  void _showLegalDialog(BuildContext context, String title, String content) {
    Navigator.push(context, MaterialPageRoute(
      builder: (_) => LegalPage(
        title: title,
        icon: Icons.shield_outlined,
        sections: [LegalSection(title, content)],
      ),
    ));
  }

  Widget _drawerTile(
    IconData icon,
    String title,
    String subtitle,
    VoidCallback onTap,
  ) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF10B981).withOpacity(0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: const Color(0xFF34D399), size: 18),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        color: Color(0xFF6B7280),
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.chevron_right,
                color: Color(0xFF4B5563),
                size: 18,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _ColorNode(
    String label,
    String tooltip,
    Color color,
    Function(Color) onChanged,
  ) {
    final hexString =
        '#${color.value.toRadixString(16).substring(2).toUpperCase()}';

    return Tooltip(
      message: tooltip.isNotEmpty ? tooltip : label,
      child: GestureDetector(
        onTap: () => _pickColor(context, label, color, onChanged),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              height: 72,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: color, width: 2.2),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x99000000),
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(2),
                child: AspectRatio(
                  aspectRatio: 1.0,
                  child: CustomPaint(
                    painter: TimeSceneryPainter(
                      timeOfDay: label,
                      userColor: color,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 7),
            SizedBox(
              height: 16,
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  label,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.3,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 3),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
              decoration: BoxDecoration(
                color: color.withOpacity(0.20),
                borderRadius: BorderRadius.circular(2),
                border: Border.all(color: color.withOpacity(0.65), width: 1.0),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(color: color.withOpacity(0.8), blurRadius: 4),
                      ],
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    hexString,
                    style: TextStyle(
                      color: Color.lerp(Colors.white, color, 0.3),
                      fontSize: 9,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _compileShader() async {
    final progressNotifier = ValueNotifier<double>(0.1);
    final statusNotifier = ValueNotifier<String>("Initializing Builder...");

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return Dialog(
          backgroundColor: const Color(0xFF181E19),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.architecture, size: 48, color: Colors.white),
                const SizedBox(height: 16),
                ValueListenableBuilder<String>(
                  valueListenable: statusNotifier,
                  builder: (context, status, child) => Text(
                    status,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                ValueListenableBuilder<double>(
                  valueListenable: progressNotifier,
                  builder: (context, progress, child) =>
                      LinearProgressIndicator(
                        value: progress,
                        backgroundColor: Colors.white10,
                        valueColor: const AlwaysStoppedAnimation<Color>(
                          Color(0xFF6DE846),
                        ),
                        minHeight: 8,
                        borderRadius: BorderRadius.circular(4),
                      ),
                ),
              ],
            ),
          ),
        );
      },
    );

    try {
      await Future.delayed(const Duration(milliseconds: 600));
      statusNotifier.value = "Reading JSON Assets...";
      progressNotifier.value = 0.3;
      ByteData data = await rootBundle.load('assets/base_shader.zip');
      List<int> bytes;
      if (_uploadedShaderBytes != null) {
        // Use user-uploaded shader as the base
        bytes = _uploadedShaderBytes!;
        statusNotifier.value = "Using Uploaded Shader: $_uploadedShaderName";
      } else {
        // Use bundled Piglix default shader
        bytes = data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
      }

      await Future.delayed(const Duration(milliseconds: 600));
      statusNotifier.value = "Decoding Zip Archive...";
      progressNotifier.value = 0.5;
      final archive = ZipDecoder().decodeBytes(bytes);
      final newArchive = Archive();

      await Future.delayed(const Duration(milliseconds: 600));
      statusNotifier.value = "Applying Shader Constants...";
      progressNotifier.value = 0.7;

      for (final file in archive) {
        if (file.isFile) {
          List<int> fileData = file.content as List<int>;
          if (file.name == 'pack_icon.png') {
            // Use user uploaded logo, or fall back to default Piglix logo
            fileData = _uploadedLogoBytes != null
                ? _uploadedLogoBytes!.toList()
                : kPiglixLogoBytes.toList();
          }

          if (file.name == 'manifest.json') {
            String content = utf8.decode(fileData);
            Map<String, dynamic> manifest;
            try {
              manifest = jsonDecode(content);
            } catch (e) {
              print('JSON ERROR IN ${file.name}: $e');
              continue;
            }
            manifest['header']['uuid'] = const Uuid().v4();
            manifest['modules'][0]['uuid'] = const Uuid().v4();

            String pName = shaderNameController.text.trim();
            if (pName.isEmpty) pName = "Piglix Shader";
            manifest['header']['name'] = pName;
            manifest['header']['description'] =
                "Created with Shader Generator for MCPE";

            fileData = utf8.encode(jsonEncode(manifest));
          }

          if (file.name.startsWith('water/') && file.name.endsWith('.json')) {
            String content = utf8.decode(fileData);
            Map<String, dynamic> jsonMap;
            try {
              jsonMap = jsonDecode(content);
            } catch (e) {
              print('JSON ERROR IN ${file.name}: $e');
              continue;
            }
            var waves = jsonMap['minecraft:water_settings']?['waves'];
            if (waves != null) {
              if (waterQuality == 'Low')
                waves['octaves'] = 3;
              else if (waterQuality == 'Medium')
                waves['octaves'] = 8;
              else if (waterQuality == 'Ultra')
                waves['octaves'] = 14;

              if (waves['speed'] != null)
                waves['speed'] = (waves['speed'] as num).toDouble() * windSpeed;
            }

            var caustics = jsonMap['minecraft:water_settings']?['caustics'];
            if (caustics != null) caustics['enabled'] = underwaterCaustics;

            fileData = utf8.encode(jsonEncode(jsonMap));
          }

          if (!enablePBR && file.name.endsWith('.json')) {
            String content = utf8.decode(fileData);
            content = content.replaceAll(
              RegExp(r'"bump_mapping"\s*:\s*true'),
              '"bump_mapping": false',
            );
            fileData = utf8.encode(content);
          }

          if (file.name == 'shadows/global.json') {
            String content = utf8.decode(fileData);
            Map<String, dynamic> jsonMap;
            try {
              jsonMap = jsonDecode(content);
            } catch (e) {
              print('JSON ERROR IN ${file.name}: $e');
              continue;
            }
            var shadow = jsonMap['minecraft:shadow_settings'];
            if (shadow != null) {
              if (shadowFidelity == 'Off') {
                shadow['enabled'] = false;
              } else {
                shadow.remove('enabled');
                if (shadowFidelity.contains('128')) {
                  shadow['shadow_style'] = 'hard_shadows';
                  shadow['texel_size'] = 128;
                } else if (shadowFidelity.contains('256')) {
                  shadow['shadow_style'] = 'hard_shadows';
                  shadow['texel_size'] = 256;
                } else if (shadowFidelity.contains('Soft')) {
                  shadow['shadow_style'] = 'soft_shadows';
                  shadow['texel_size'] = 1024;
                }
              }
            }
            fileData = utf8.encode(jsonEncode(jsonMap));
          }

          if (file.name.startsWith('lighting/') &&
              file.name.endsWith('.json')) {
            String content = utf8.decode(fileData);
            Map<String, dynamic> jsonMap;
            try {
              jsonMap = jsonDecode(content);
            } catch (e) {
              print('JSON ERROR IN ${file.name}: $e');
              continue;
            }
            List<int> toRgb(Color c) => [c.red, c.green, c.blue];

            var lights =
                jsonMap['minecraft:lighting_settings']?['directional_lights'];
            if (lights != null) {
              var point =
                  jsonMap['minecraft:lighting_settings']?['point_lights'];
              if (point != null) {
                point['colors'] = {
                  "default": [
                    (torchLightColor.red / 255.0) * blockLightIntensity,
                    (torchLightColor.green / 255.0) * blockLightIntensity,
                    (torchLightColor.blue / 255.0) * blockLightIntensity,
                  ],
                };
              }

              var sun = lights['sun'] ?? lights['orbital']?['sun'];
              if (sun != null) {
                var sunColor = sun['color'];
                if (sunColor is Map) {
                  // Map each time key to the correct user-chosen ray color.
                  // Minecraft time keys: 0.0=noon, 0.22-0.26=sunset, 0.30-0.67=night, 0.74-0.82=sunrise
                  for (var key in sunColor.keys.toList()) {
                    final t = double.tryParse(key.toString()) ?? 0.0;
                    if (t >= 0.74 && t <= 0.82) {
                      // Morning / Sunrise
                      sunColor[key] = toRgb(rayMorningColor);
                    } else if ((t >= 0.0 && t < 0.19) ||
                        (t >= 0.82 && t <= 1.0)) {
                      // Noon / Daytime
                      sunColor[key] = toRgb(rayNoonColor);
                    } else if (t >= 0.19 && t < 0.30) {
                      // Evening / Sunset
                      sunColor[key] = toRgb(rayEveningColor);
                    } else {
                      // Night (0.30 - 0.74)
                      sunColor[key] = toRgb(rayNightColor);
                    }
                  }
                }
                var sunIllum = sun['illuminance'];
                if (sunIllum is Map) {
                  for (var key in sunIllum.keys.toList()) {
                    sunIllum[key] =
                        (sunIllum[key] as num).toDouble() * lightIntensity;
                  }
                }
              }
              var moon = lights['moon'] ?? lights['orbital']?['moon'];
              if (moon != null) {
                var moonIllum = moon['illuminance'];
                if (moonIllum is Map) {
                  for (var key in moonIllum.keys.toList()) {
                    moonIllum[key] =
                        (moonIllum[key] as num).toDouble() * nightVision;
                  }
                }
              }
            }
            fileData = utf8.encode(jsonEncode(jsonMap));
          }

          if (file.name == 'pbr/global.json') {
            String content = utf8.decode(fileData);
            Map<String, dynamic> jsonMap;
            try {
              jsonMap = jsonDecode(content);
            } catch (e) {
              print('JSON ERROR IN ${file.name}: $e');
              continue;
            }
            int roughness = 255;
            if (worldReflections.contains('Low')) roughness = 180;
            if (worldReflections.contains('High')) roughness = 100;
            if (worldReflections.contains('Ultra')) roughness = 10;

            var pbrSettings = jsonMap['minecraft:pbr_fallback_settings'];
            if (pbrSettings != null && pbrSettings['blocks'] != null) {
              var blocks = pbrSettings['blocks'];
              blocks['global_metalness_emissive_roughness_subsurface'] = [
                (globalMetalness * 255).toInt(),
                0,
                roughness,
                0,
              ];
              fileData = utf8.encode(jsonEncode(jsonMap));
            }
          }

          if (file.name.startsWith('fogs/') && file.name.endsWith('.json')) {
            String content = utf8.decode(fileData);
            Map<String, dynamic> jsonMap;
            try {
              jsonMap = jsonDecode(content);
            } catch (e) {
              print('JSON ERROR IN ${file.name}: $e');
              continue;
            }
            String hexStr(Color c) =>
                '#${c.value.toRadixString(16).substring(2).toUpperCase()}';
            var dist = jsonMap['minecraft:fog_settings']?['distance'];
            if (dist != null) {
              if (dist['air'] != null)
                dist['air']['fog_color'] = hexStr(fogColor);
              if (dist['water'] != null)
                dist['water']['fog_color'] = hexStr(waterColor);

              dist['weather_instances'] = [
                {
                  "weather": "rain",
                  "fog_color": hexStr(rainFogColor),
                  "fog_start": 0.0,
                  "fog_end": 1.0,
                },
                {
                  "weather": "thunder",
                  "fog_color": hexStr(rainFogColor),
                  "fog_start": 0.0,
                  "fog_end": 1.0,
                },
              ];

              if (dist['air'] != null && dist['air']['fog_start'] != null) {
                dist['air']['fog_start'] =
                    (dist['air']['fog_start'] as num).toDouble() / fogDensity;
              }
              if (dist['air'] != null && dist['air']['fog_end'] != null) {
                dist['air']['fog_end'] =
                    (dist['air']['fog_end'] as num).toDouble() / fogDensity;
              }
            }

            var vol = jsonMap['minecraft:fog_settings']?['volumetric'];
            if (vol != null) {
              if (vol['density'] != null && vol['density']['air'] != null) {
                var dens = vol['density']['air']['max_density'];
                if (dens != null) {
                  if (dens is Map) {
                    for (var key in dens.keys.toList()) {
                      dens[key] = (dens[key] as num).toDouble() * fogDensity;
                    }
                  } else if (dens is num) {
                    vol['density']['air']['max_density'] =
                        dens.toDouble() * fogDensity;
                  }
                }
              }
              if (vol['media_coefficients'] != null &&
                  vol['media_coefficients']['air'] != null) {
                double mult = 0.25;
                if (volumetricRays == 'Balanced') mult = 0.15;
                if (volumetricRays == 'Low End') mult = 0.05;
                // Volumetric air scattering tinted with daytime noon ray color (most visible during day)
                vol['media_coefficients']['air']['scattering'] = [
                  rayNoonColor.red / 255.0 * mult,
                  rayNoonColor.green / 255.0 * mult,
                  rayNoonColor.blue / 255.0 * mult,
                ];
              }
            }

            fileData = utf8.encode(jsonEncode(jsonMap));
          }

          if (file.name.startsWith('atmospherics/') &&
              file.name.endsWith('.json')) {
            String content = utf8.decode(fileData);
            Map<String, dynamic> jsonMap;
            try {
              jsonMap = jsonDecode(content);
            } catch (e) {
              print('JSON ERROR IN ${file.name}: $e');
              continue;
            }

            var settings = jsonMap['minecraft:atmosphere_settings'];
            if (settings != null) {
              var glare = settings['sun_glare_shape'];
              if (glare is Map) {
                for (var key in glare.keys.toList()) {
                  glare[key] = (5.0 / sunSize);
                }
              }

              var zenith = settings['sky_zenith_color'];
              var horizon = settings['sky_horizon_color'];

              if (zenith is Map && horizon is Map) {
                for (var key in zenith.keys.toList()) zenith.remove(key);
                for (var key in horizon.keys.toList()) horizon.remove(key);

                List<int> toRgb(Color c) => [c.red, c.green, c.blue];

                zenith['0.0'] = toRgb(noonColor);
                horizon['0.0'] = toRgb(noonColor);

                zenith['0.25'] = toRgb(eveningColor);
                horizon['0.25'] = toRgb(eveningColor);

                zenith['0.50'] = toRgb(nightColor);
                horizon['0.50'] = toRgb(nightColor);

                zenith['0.75'] = toRgb(morningColor);
                horizon['0.75'] = toRgb(morningColor);
              }
            }

            fileData = utf8.encode(jsonEncode(jsonMap));
          }

          if (file.name.startsWith('color_grading/') &&
              file.name.endsWith('.json')) {
            String content = utf8.decode(fileData);
            Map<String, dynamic> jsonMap;
            try {
              jsonMap = jsonDecode(content);
            } catch (e) {
              print('JSON ERROR IN ${file.name}: $e');
              continue;
            }
            var grading =
                jsonMap['minecraft:color_grading_settings']?['color_grading'];
            if (grading != null) {
              var sat = [
                1.04 * globalSaturation,
                1.04 * globalSaturation,
                1.04 * globalSaturation,
              ];
              if (grading['highlights'] != null)
                grading['highlights']['saturation'] = sat;
              if (grading['midtones'] != null)
                grading['midtones']['saturation'] = sat;
              if (grading['shadows'] != null)
                grading['shadows']['saturation'] = sat;

              List<double> highGain = [1.2, 1.2, 1.2];
              if (toneMapFilter.contains('Vintage')) highGain = [1.5, 1.3, 0.9];
              if (toneMapFilter.contains('Cool')) highGain = [0.9, 1.1, 1.5];
              if (grading['highlights'] != null)
                grading['highlights']['gain'] = highGain;
            }

            var tm =
                jsonMap['minecraft:color_grading_settings']?['tone_mapping'];
            if (tm != null) {
              if (toneMapFilter.contains('Reinhard'))
                tm['operator'] = 'reinhard';
              else
                tm['operator'] = 'aces';
              tm['contrast'] = contrast;
              tm['auto_exposure_max'] = autoExposure * 2.0;
            }

            var cg = jsonMap['minecraft:color_grading_settings'];
            if (cg != null && cg['color_grading'] != null) {
              if (cg['color_grading']['midtones'] != null)
                cg['color_grading']['midtones']['contrast'] = [
                  contrast,
                  contrast,
                  contrast,
                ];
            }
            fileData = utf8.encode(jsonEncode(jsonMap));
          }

          newArchive.addFile(ArchiveFile(file.name, fileData.length, fileData));
        }
      }

      if (!enablePointLightShadows) {
        String pl =
            '{"format_version":"1.21.40","minecraft:point_lighting_settings":{"description":{"identifier":"Piglix:point"},"point_light_shadows":{"enabled":false}}}';
        newArchive.addFile(
          ArchiveFile('lighting/point_lights.json', pl.length, utf8.encode(pl)),
        );
      }

      await Future.delayed(const Duration(milliseconds: 600));
      statusNotifier.value = "Encoding Final MCPACK...";
      progressNotifier.value = 0.9;
      final encodedBytes = ZipEncoder().encode(newArchive)!;

      await Future.delayed(const Duration(milliseconds: 400));
      statusNotifier.value = "Finalizing Shader Pack...";
      progressNotifier.value = 1.0;

      String pName = shaderNameController.text.trim();
      if (pName.isEmpty) pName = "Piglix Shader";

      setState(() {
        _generatedPackBytes = encodedBytes;
        _generatedPackName = "$pName.mcpack";
        _isGenerated = true;
      });

      await Future.delayed(const Duration(milliseconds: 500));
      if (mounted) Navigator.pop(context); // Close dialog

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '✨ $pName generated! Tap "Open with Minecraft" or Download.',
            ),
            backgroundColor: const Color(0xFF385E2E),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) Navigator.pop(context);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }
}

// ─────────────────────────────────────────────
// Legal Page — Full Screen
// ─────────────────────────────────────────────

class LegalSection {
  final String title;
  final String? body;
  final bool isHeader;
  final bool isMuted;

  const LegalSection(
    this.title,
    this.body, {
    this.isHeader = false,
    this.isMuted = false,
  });
}

class LegalPage extends StatelessWidget {
  final String title;
  final IconData icon;
  final List<LegalSection> sections;

  const LegalPage({
    super.key,
    required this.title,
    required this.icon,
    required this.sections,
  });

  @override
  Widget build(BuildContext context) {
    const bgColor = Color(0xFF071A14);
    const cardColor = Color(0xFF0D1F19);
    const accentGreen = Color(0xFF34D399);
    const borderColor = Color(0xFF1A3A2A);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: accentGreen),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            Icon(icon, color: accentGreen, size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 17,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: Color(0xFF071A14),
          statusBarIconBrightness: Brightness.light,
        ),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 40),
        itemCount: sections.length,
        itemBuilder: (context, index) {
          final section = sections[index];

          if (section.isHeader) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 4, top: 8),
              child: Text(
                section.title,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                  fontSize: 20,
                ),
              ),
            );
          }

          if (section.isMuted) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 20),
              child: Text(
                section.title,
                style: const TextStyle(
                  color: Color(0xFF6B7280),
                  fontSize: 13,
                ),
              ),
            );
          }

          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: borderColor, width: 1),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 3,
                        height: 16,
                        decoration: BoxDecoration(
                          color: accentGreen,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          section.title,
                          style: const TextStyle(
                            color: accentGreen,
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (section.body != null) ...[
                    const SizedBox(height: 10),
                    Text(
                      section.body!,
                      style: const TextStyle(
                        color: Color(0xFFB0BEC5),
                        fontSize: 13,
                        height: 1.6,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class TimeSceneryPainter extends CustomPainter {
  final String timeOfDay;
  final Color userColor;

  TimeSceneryPainter({
    required this.timeOfDay,
    required this.userColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final rrect = RRect.fromRectAndRadius(rect, const Radius.circular(2));
    canvas.save();
    canvas.clipRRect(rrect);

    final norm = timeOfDay.toLowerCase().replaceAll(' ', '').replaceAll('_', '');
    switch (norm) {
      case 'morning':
        _drawMorning(canvas, size);
        break;
      case 'noon':
        _drawNoon(canvas, size);
        break;
      case 'evening':
        _drawEvening(canvas, size);
        break;
      case 'night':
        _drawNight(canvas, size);
        break;
      case 'rainfog':
        _drawRainFog(canvas, size);
        break;
      case 'rainwater':
        _drawRainWater(canvas, size);
        break;
      case 'cloudtop':
        _drawCloudTop(canvas, size);
        break;
      case 'cloudbottom':
        _drawCloudBottom(canvas, size);
        break;
      case 'fogtint':
      case 'fog':
        _drawFogTint(canvas, size);
        break;
      case 'torchlight':
      case 'torch':
        _drawTorchLight(canvas, size);
        break;
      case 'watertint':
      case 'water':
        _drawWaterTint(canvas, size);
        break;
      default:
        _drawMorning(canvas, size);
        break;
    }

    // High-gloss overlay at top for premium glass effect
    final glossPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Colors.white.withOpacity(0.20),
          Colors.white.withOpacity(0.0),
        ],
        stops: const [0.0, 0.45],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height * 0.45));
    canvas.drawRRect(rrect, glossPaint);

    // Inner subtle crisp border for depth
    final borderPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0
      ..color = Colors.white.withOpacity(0.20);
    canvas.drawRRect(rrect, borderPaint);

    canvas.restore();
  }

  void _drawMorning(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final hsv = HSVColor.fromColor(userColor);

    final topColor = hsv
        .withValue((hsv.value * 0.70).clamp(0.0, 1.0))
        .withSaturation((hsv.saturation * 1.1).clamp(0.0, 1.0))
        .toColor();
    final midColor = userColor;
    final horizColor = hsv
        .withValue((hsv.value * 1.25).clamp(0.0, 1.0))
        .withSaturation((hsv.saturation * 0.55).clamp(0.0, 1.0))
        .toColor();

    final skyPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [topColor, midColor, horizColor],
        stops: const [0.0, 0.50, 1.0],
      ).createShader(Offset.zero & size);
    canvas.drawRect(Offset.zero & size, skyPaint);

    final sunCenter = Offset(w * 0.50, h * 0.42);

    final haloPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          Colors.white.withOpacity(0.95),
          userColor.withOpacity(0.70),
          userColor.withOpacity(0.25),
          Colors.transparent,
        ],
        stops: const [0.0, 0.38, 0.70, 1.0],
      ).createShader(Rect.fromCircle(center: sunCenter, radius: w * 0.48));
    canvas.drawCircle(sunCenter, w * 0.48, haloPaint);

    final rayPaint = Paint()
      ..color = Colors.white.withOpacity(0.55)
      ..strokeWidth = 2.2
      ..strokeCap = StrokeCap.round;
    for (int i = -3; i <= 3; i++) {
      if (i == 0) continue;
      final angle = -math.pi / 2 + (i * 0.28);
      final r1 = w * 0.18;
      final r2 = w * 0.40;
      canvas.drawLine(
        Offset(sunCenter.dx + math.cos(angle) * r1,
            sunCenter.dy + math.sin(angle) * r1),
        Offset(sunCenter.dx + math.cos(angle) * r2,
            sunCenter.dy + math.sin(angle) * r2),
        rayPaint,
      );
    }

    final sunDiskPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          Colors.white,
          const Color(0xFFFFF9C4),
          userColor.withOpacity(0.85)
        ],
        stops: const [0.0, 0.7, 1.0],
      ).createShader(Rect.fromCircle(center: sunCenter, radius: w * 0.17));
    canvas.drawCircle(sunCenter, w * 0.17, sunDiskPaint);

    final bgMtn = Path()
      ..moveTo(0, h * 0.64)
      ..lineTo(w * 0.26, h * 0.53)
      ..lineTo(w * 0.50, h * 0.60)
      ..lineTo(w * 0.76, h * 0.51)
      ..lineTo(w, h * 0.63)
      ..lineTo(w, h)
      ..lineTo(0, h)
      ..close();
    final mtnColor = Color.lerp(const Color(0xFF3E2014), userColor, 0.25)!;
    canvas.drawPath(bgMtn, Paint()..color = mtnColor);

    final islandRock = Path()
      ..moveTo(w * 0.22, h * 0.65)
      ..lineTo(w * 0.78, h * 0.65)
      ..lineTo(w * 0.68, h * 0.82)
      ..lineTo(w * 0.50, h * 0.92)
      ..lineTo(w * 0.32, h * 0.82)
      ..close();
    canvas.drawPath(islandRock, Paint()..color = const Color(0xFF2C160C));

    final islandGrass = RRect.fromRectAndRadius(
      Rect.fromLTWH(w * 0.18, h * 0.62, w * 0.64, h * 0.08),
      const Radius.circular(2.5),
    );
    canvas.drawRRect(islandGrass, Paint()..color = const Color(0xFF43A047));
    canvas.drawRRect(
      RRect.fromRectAndRadius(
          Rect.fromLTWH(w * 0.18, h * 0.62, w * 0.64, h * 0.035),
          const Radius.circular(1.5)),
      Paint()..color = const Color(0xFF76FF03),
    );

    final leftCliff = Path()
      ..moveTo(0, h * 0.72)
      ..lineTo(w * 0.24, h * 0.72)
      ..lineTo(w * 0.20, h)
      ..lineTo(0, h)
      ..close();
    canvas.drawPath(leftCliff, Paint()..color = const Color(0xFF1E0E08));
    canvas.drawRect(Rect.fromLTWH(0, h * 0.70, w * 0.24, h * 0.05),
        Paint()..color = const Color(0xFF2E7D32));
    canvas.drawRect(Rect.fromLTWH(0, h * 0.70, w * 0.24, h * 0.02),
        Paint()..color = const Color(0xFF64DD17));

    final rightCliff = Path()
      ..moveTo(w * 0.76, h * 0.72)
      ..lineTo(w, h * 0.72)
      ..lineTo(w, h)
      ..lineTo(w * 0.80, h)
      ..close();
    canvas.drawPath(rightCliff, Paint()..color = const Color(0xFF1E0E08));
    canvas.drawRect(Rect.fromLTWH(w * 0.76, h * 0.70, w * 0.24, h * 0.05),
        Paint()..color = const Color(0xFF2E7D32));
    canvas.drawRect(Rect.fromLTWH(w * 0.76, h * 0.70, w * 0.24, h * 0.02),
        Paint()..color = const Color(0xFF64DD17));
  }

  void _drawNoon(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final hsv = HSVColor.fromColor(userColor);

    final topColor = hsv
        .withValue((hsv.value * 0.75).clamp(0.0, 1.0))
        .withSaturation((hsv.saturation * 1.1).clamp(0.0, 1.0))
        .toColor();
    final midColor = userColor;
    final horizColor = hsv
        .withValue((hsv.value * 1.25).clamp(0.0, 1.0))
        .withSaturation((hsv.saturation * 0.50).clamp(0.0, 1.0))
        .toColor();

    final skyPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [topColor, midColor, horizColor],
        stops: const [0.0, 0.55, 1.0],
      ).createShader(Offset.zero & size);
    canvas.drawRect(Offset.zero & size, skyPaint);

    _drawVoxelCloud(canvas, Offset(w * 0.16, h * 0.18), w * 0.26, h * 0.12);
    _drawVoxelCloud(canvas, Offset(w * 0.72, h * 0.22), w * 0.28, h * 0.13);
    _drawVoxelCloud(canvas, Offset(w * 0.48, h * 0.10), w * 0.20, h * 0.09);

    final sunCenter = Offset(w * 0.50, h * 0.44);

    final haloPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          Colors.white.withOpacity(0.95),
          userColor.withOpacity(0.70),
          userColor.withOpacity(0.20),
          Colors.transparent,
        ],
        stops: const [0.0, 0.40, 0.75, 1.0],
      ).createShader(Rect.fromCircle(center: sunCenter, radius: w * 0.46));
    canvas.drawCircle(sunCenter, w * 0.46, haloPaint);

    final rayPaint = Paint()
      ..color = Colors.white.withOpacity(0.65)
      ..strokeWidth = 2.4
      ..strokeCap = StrokeCap.round;
    for (int i = 0; i < 8; i++) {
      final angle = (i * math.pi / 4);
      final r1 = w * 0.17;
      final r2 = (i % 2 == 0) ? w * 0.32 : w * 0.26;
      canvas.drawLine(
        Offset(sunCenter.dx + math.cos(angle) * r1,
            sunCenter.dy + math.sin(angle) * r1),
        Offset(sunCenter.dx + math.cos(angle) * r2,
            sunCenter.dy + math.sin(angle) * r2),
        rayPaint,
      );
    }

    final sunDiskPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          Colors.white,
          const Color(0xFFFFF176),
          userColor.withOpacity(0.85)
        ],
        stops: const [0.0, 0.75, 1.0],
      ).createShader(Rect.fromCircle(center: sunCenter, radius: w * 0.16));
    canvas.drawCircle(sunCenter, w * 0.16, sunDiskPaint);

    final backHill = Path()
      ..moveTo(0, h * 0.70)
      ..lineTo(w * 0.35, h * 0.62)
      ..lineTo(w * 0.70, h * 0.65)
      ..lineTo(w, h * 0.60)
      ..lineTo(w, h)
      ..lineTo(0, h)
      ..close();
    canvas.drawPath(backHill, Paint()..color = const Color(0xFF2E7D32));

    final midHill = Path()
      ..moveTo(0, h * 0.76)
      ..lineTo(w * 0.45, h * 0.72)
      ..lineTo(w * 0.85, h * 0.78)
      ..lineTo(w, h * 0.75)
      ..lineTo(w, h)
      ..close();
    canvas.drawPath(midHill, Paint()..color = const Color(0xFF43A047));

    canvas.drawRect(Rect.fromLTWH(0, h * 0.82, w * 0.40, h * 0.18),
        Paint()..color = const Color(0xFF4E342E));
    canvas.drawRect(Rect.fromLTWH(0, h * 0.82, w * 0.40, h * 0.05),
        Paint()..color = const Color(0xFF66BB6A));

    canvas.drawRect(Rect.fromLTWH(w * 0.36, h * 0.86, w * 0.64, h * 0.14),
        Paint()..color = const Color(0xFF3E2723));
    canvas.drawRect(Rect.fromLTWH(w * 0.36, h * 0.86, w * 0.64, h * 0.05),
        Paint()..color = const Color(0xFF81C784));
  }

  void _drawEvening(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final hsv = HSVColor.fromColor(userColor);

    final topColor = hsv
        .withValue((hsv.value * 0.65).clamp(0.0, 1.0))
        .withSaturation((hsv.saturation * 1.15).clamp(0.0, 1.0))
        .toColor();
    final midColor = userColor;
    final horizColor = hsv
        .withValue((hsv.value * 1.30).clamp(0.0, 1.0))
        .withSaturation((hsv.saturation * 0.60).clamp(0.0, 1.0))
        .toColor();

    final skyPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [topColor, midColor, horizColor],
        stops: const [0.0, 0.50, 1.0],
      ).createShader(Offset.zero & size);
    canvas.drawRect(Offset.zero & size, skyPaint);

    final sunCenter = Offset(w * 0.50, h * 0.48);

    final haloPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          Colors.white.withOpacity(0.95),
          userColor.withOpacity(0.80),
          userColor.withOpacity(0.30),
          Colors.transparent,
        ],
        stops: const [0.0, 0.38, 0.72, 1.0],
      ).createShader(Rect.fromCircle(center: sunCenter, radius: w * 0.48));
    canvas.drawCircle(sunCenter, w * 0.48, haloPaint);

    final beamPaint = Paint()
      ..color = Colors.white.withOpacity(0.50)
      ..strokeWidth = 2.4
      ..strokeCap = StrokeCap.round;
    for (int i = -3; i <= 3; i++) {
      final angle = -math.pi / 2 + (i * 0.26);
      canvas.drawLine(
        Offset(sunCenter.dx + math.cos(angle) * (w * 0.18),
            sunCenter.dy + math.sin(angle) * (w * 0.18)),
        Offset(sunCenter.dx + math.cos(angle) * (w * 0.40),
            sunCenter.dy + math.sin(angle) * (w * 0.40)),
        beamPaint,
      );
    }

    final sunDiskPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          Colors.white,
          const Color(0xFFFFD54F),
          userColor.withOpacity(0.85)
        ],
        stops: const [0.0, 0.7, 1.0],
      ).createShader(Rect.fromCircle(center: sunCenter, radius: w * 0.17));
    canvas.drawCircle(sunCenter, w * 0.17, sunDiskPaint);

    final backMountain = Path()
      ..moveTo(0, h * 0.64)
      ..lineTo(w * 0.30, h * 0.52)
      ..lineTo(w * 0.50, h * 0.60)
      ..lineTo(w * 0.72, h * 0.50)
      ..lineTo(w, h * 0.63)
      ..lineTo(w, h)
      ..lineTo(0, h)
      ..close();
    final mtnColor = Color.lerp(const Color(0xFF2C1008), userColor, 0.2)!;
    canvas.drawPath(backMountain, Paint()..color = mtnColor);

    final leftShelf = Path()
      ..moveTo(0, h * 0.72)
      ..lineTo(w * 0.38, h * 0.72)
      ..lineTo(w * 0.30, h)
      ..lineTo(0, h)
      ..close();
    canvas.drawPath(leftShelf, Paint()..color = const Color(0xFF1B0703));
    canvas.drawRect(Rect.fromLTWH(0, h * 0.70, w * 0.38, h * 0.04),
        Paint()..color = userColor.withOpacity(0.9));

    final rightShelf = Path()
      ..moveTo(w * 0.62, h * 0.72)
      ..lineTo(w, h * 0.72)
      ..lineTo(w, h)
      ..lineTo(w * 0.70, h)
      ..close();
    canvas.drawPath(rightShelf, Paint()..color = const Color(0xFF1B0703));
    canvas.drawRect(Rect.fromLTWH(w * 0.62, h * 0.70, w * 0.38, h * 0.04),
        Paint()..color = userColor.withOpacity(0.9));

    final centerRock = Path()
      ..moveTo(w * 0.30, h * 0.76)
      ..lineTo(w * 0.70, h * 0.76)
      ..lineTo(w * 0.58, h * 0.94)
      ..lineTo(w * 0.42, h * 0.94)
      ..close();
    canvas.drawPath(centerRock, Paint()..color = const Color(0xFF140502));
    canvas.drawRect(
        Rect.fromLTWH(w * 0.28, h * 0.74, w * 0.44, h * 0.04),
        Paint()..color = userColor);
  }

  void _drawNight(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final hsv = HSVColor.fromColor(userColor);

    final topColor = hsv
        .withValue((hsv.value * 0.55).clamp(0.0, 1.0))
        .withSaturation((hsv.saturation * 1.1).clamp(0.0, 1.0))
        .toColor();
    final midColor = userColor;
    final horizColor = hsv
        .withValue((hsv.value * 1.25).clamp(0.0, 1.0))
        .withSaturation((hsv.saturation * 0.60).clamp(0.0, 1.0))
        .toColor();

    final skyPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [topColor, midColor, horizColor],
        stops: const [0.0, 0.55, 1.0],
      ).createShader(Offset.zero & size);
    canvas.drawRect(Offset.zero & size, skyPaint);

    final starPaint = Paint()..color = Colors.white.withOpacity(0.95);
    final starOffsets = [
      Offset(w * 0.15, h * 0.16),
      Offset(w * 0.26, h * 0.30),
      Offset(w * 0.75, h * 0.14),
      Offset(w * 0.88, h * 0.26),
      Offset(w * 0.36, h * 0.12),
      Offset(w * 0.68, h * 0.34),
      Offset(w * 0.12, h * 0.42),
      Offset(w * 0.86, h * 0.46),
    ];
    for (final pos in starOffsets) {
      canvas.drawCircle(pos, 1.3, starPaint);
    }
    _drawSparkle(canvas, Offset(w * 0.20, h * 0.20), 3.2);
    _drawSparkle(canvas, Offset(w * 0.80, h * 0.18), 3.6);

    final moonCenter = Offset(w * 0.50, h * 0.40);
    final moonRadius = w * 0.19;

    final moonHalo = Paint()
      ..shader = RadialGradient(
        colors: [
          Colors.white.withOpacity(0.95),
          userColor.withOpacity(0.70),
          userColor.withOpacity(0.20),
          Colors.transparent,
        ],
        stops: const [0.0, 0.42, 0.75, 1.0],
      ).createShader(Rect.fromCircle(center: moonCenter, radius: w * 0.46));
    canvas.drawCircle(moonCenter, w * 0.46, moonHalo);

    final moonPath = Path()
      ..addOval(Rect.fromCircle(center: moonCenter, radius: moonRadius));
    final cutPath = Path()
      ..addOval(
        Rect.fromCircle(
          center: moonCenter.translate(moonRadius * 0.52, -moonRadius * 0.20),
          radius: moonRadius * 0.96,
        ),
      );
    final crescent = Path.combine(PathOperation.difference, moonPath, cutPath);
    canvas.drawPath(
      crescent,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.white, Color(0xFFE0F7FA)],
        ).createShader(Rect.fromCircle(center: moonCenter, radius: moonRadius)),
    );

    final nightMtn = Path()
      ..moveTo(0, h * 0.66)
      ..lineTo(w * 0.32, h * 0.56)
      ..lineTo(w * 0.50, h * 0.63)
      ..lineTo(w * 0.75, h * 0.54)
      ..lineTo(w, h * 0.64)
      ..lineTo(w, h)
      ..lineTo(0, h)
      ..close();
    final mtnColor = Color.lerp(const Color(0xFF070B18), userColor, 0.2)!;
    canvas.drawPath(nightMtn, Paint()..color = mtnColor);

    final waterPath = Path()
      ..moveTo(0, h * 0.76)
      ..lineTo(w, h * 0.76)
      ..lineTo(w, h)
      ..lineTo(0, h)
      ..close();
    canvas.drawPath(
      waterPath,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            userColor.withOpacity(0.65),
            const Color(0xFF040A14),
          ],
        ).createShader(Rect.fromLTWH(0, h * 0.76, w, h * 0.24)),
    );

    final ripplePaint = Paint()
      ..color = Colors.white.withOpacity(0.75)
      ..strokeWidth = 1.8
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(
        Offset(w * 0.42, h * 0.81), Offset(w * 0.58, h * 0.81), ripplePaint);
    canvas.drawLine(
        Offset(w * 0.38, h * 0.86), Offset(w * 0.62, h * 0.86), ripplePaint);
    canvas.drawLine(
        Offset(w * 0.44, h * 0.91), Offset(w * 0.56, h * 0.91), ripplePaint);
  }

  void _drawRainFog(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final hsv = HSVColor.fromColor(userColor);

    final topColor = hsv
        .withValue((hsv.value * 0.40).clamp(0.0, 1.0))
        .withSaturation((hsv.saturation * 0.8).clamp(0.0, 1.0))
        .toColor();
    final midColor = userColor;
    final horizColor = hsv
        .withValue((hsv.value * 0.85).clamp(0.0, 1.0))
        .withSaturation((hsv.saturation * 0.40).clamp(0.0, 1.0))
        .toColor();

    final skyPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [topColor, midColor, horizColor],
        stops: const [0.0, 0.50, 1.0],
      ).createShader(Offset.zero & size);
    canvas.drawRect(Offset.zero & size, skyPaint);

    final stormCloud = Paint()..color = const Color(0xFF1E2832).withOpacity(0.80);
    canvas.drawRect(Rect.fromLTWH(0, 0, w, h * 0.22), stormCloud);
    _drawVoxelCloud(canvas, Offset(w * 0.30, h * 0.16), w * 0.45, h * 0.15);
    _drawVoxelCloud(canvas, Offset(w * 0.75, h * 0.18), w * 0.40, h * 0.14);

    final mtnFar = Path()
      ..moveTo(0, h * 0.58)
      ..lineTo(w * 0.25, h * 0.48)
      ..lineTo(w * 0.55, h * 0.54)
      ..lineTo(w * 0.80, h * 0.45)
      ..lineTo(w, h * 0.56)
      ..lineTo(w, h)
      ..lineTo(0, h)
      ..close();
    canvas.drawPath(
      mtnFar,
      Paint()
        ..color = Color.lerp(const Color(0xFF1A262C), userColor, 0.40)!
            .withOpacity(0.70),
    );

    final mtnMid = Path()
      ..moveTo(0, h * 0.68)
      ..lineTo(w * 0.35, h * 0.60)
      ..lineTo(w * 0.68, h * 0.64)
      ..lineTo(w, h * 0.58)
      ..lineTo(w, h)
      ..lineTo(0, h)
      ..close();
    canvas.drawPath(
      mtnMid,
      Paint()..color = Color.lerp(const Color(0xFF0D1B1E), userColor, 0.25)!,
    );

    final fogPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          userColor.withOpacity(0.10),
          userColor.withOpacity(0.60),
          userColor.withOpacity(0.85),
        ],
      ).createShader(Rect.fromLTWH(0, h * 0.55, w, h * 0.45));
    canvas.drawRect(Rect.fromLTWH(0, h * 0.55, w, h * 0.45), fogPaint);

    final rainPaint = Paint()
      ..color = Colors.white.withOpacity(0.75)
      ..strokeWidth = 1.3
      ..strokeCap = StrokeCap.round;
    final rainOffsets = [
      Offset(w * 0.12, h * 0.15),
      Offset(w * 0.28, h * 0.08),
      Offset(w * 0.45, h * 0.22),
      Offset(w * 0.62, h * 0.10),
      Offset(w * 0.82, h * 0.18),
      Offset(w * 0.20, h * 0.38),
      Offset(w * 0.38, h * 0.48),
      Offset(w * 0.56, h * 0.35),
      Offset(w * 0.74, h * 0.42),
      Offset(w * 0.90, h * 0.32),
      Offset(w * 0.15, h * 0.62),
      Offset(w * 0.32, h * 0.70),
      Offset(w * 0.50, h * 0.60),
      Offset(w * 0.70, h * 0.68),
      Offset(w * 0.85, h * 0.75),
    ];
    for (final pt in rainOffsets) {
      canvas.drawLine(pt, Offset(pt.dx - 3.5, pt.dy + 12), rainPaint);
    }
  }

  void _drawRainWater(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final hsv = HSVColor.fromColor(userColor);

    final skyColor = hsv
        .withValue((hsv.value * 0.45).clamp(0.0, 1.0))
        .withSaturation((hsv.saturation * 0.7).clamp(0.0, 1.0))
        .toColor();
    canvas.drawRect(Rect.fromLTWH(0, 0, w, h * 0.34), Paint()..color = skyColor);

    final waterBottomColor = hsv
        .withValue((hsv.value * 0.35).clamp(0.0, 1.0))
        .withSaturation((hsv.saturation * 1.2).clamp(0.0, 1.0))
        .toColor();
    final waterPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [userColor, waterBottomColor],
      ).createShader(Rect.fromLTWH(0, h * 0.34, w, h * 0.66));
    canvas.drawRect(Rect.fromLTWH(0, h * 0.34, w, h * 0.66), waterPaint);

    final surfacePaint = Paint()
      ..color = Colors.white.withOpacity(0.85)
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round;
    final surfPath = Path()
      ..moveTo(0, h * 0.34)
      ..quadraticBezierTo(w * 0.25, h * 0.32, w * 0.50, h * 0.34)
      ..quadraticBezierTo(w * 0.75, h * 0.36, w, h * 0.34);
    canvas.drawPath(surfPath, surfacePaint);

    final ripplePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.3
      ..color = Colors.white.withOpacity(0.80);

    canvas.drawOval(
      Rect.fromCenter(
          center: Offset(w * 0.35, h * 0.46), width: w * 0.45, height: h * 0.12),
      ripplePaint,
    );
    canvas.drawOval(
      Rect.fromCenter(
          center: Offset(w * 0.35, h * 0.46), width: w * 0.22, height: h * 0.06),
      ripplePaint..strokeWidth = 1.6,
    );

    canvas.drawOval(
      Rect.fromCenter(
          center: Offset(w * 0.72, h * 0.62), width: w * 0.38, height: h * 0.10),
      ripplePaint..strokeWidth = 1.3,
    );
    canvas.drawOval(
      Rect.fromCenter(
          center: Offset(w * 0.72, h * 0.62), width: w * 0.18, height: h * 0.05),
      ripplePaint..strokeWidth = 1.5,
    );

    canvas.drawOval(
      Rect.fromCenter(
          center: Offset(w * 0.28, h * 0.78), width: w * 0.40, height: h * 0.10),
      ripplePaint..strokeWidth = 1.2,
    );

    final splashPaint = Paint()..color = Colors.white.withOpacity(0.95);
    canvas.drawCircle(Offset(w * 0.35, h * 0.41), 1.6, splashPaint);
    canvas.drawCircle(Offset(w * 0.33, h * 0.38), 1.1, splashPaint);
    canvas.drawCircle(Offset(w * 0.72, h * 0.57), 1.6, splashPaint);
    canvas.drawCircle(Offset(w * 0.28, h * 0.73), 1.4, splashPaint);

    final rainPaint = Paint()
      ..color = Colors.white.withOpacity(0.65)
      ..strokeWidth = 1.2
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(
        Offset(w * 0.38, h * 0.12), Offset(w * 0.35, h * 0.41), rainPaint);
    canvas.drawLine(
        Offset(w * 0.75, h * 0.25), Offset(w * 0.72, h * 0.57), rainPaint);
    canvas.drawLine(
        Offset(w * 0.18, h * 0.10), Offset(w * 0.16, h * 0.33), rainPaint);
  }

  void _drawCloudTop(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final hsv = HSVColor.fromColor(userColor);

    final skyTop = hsv
        .withValue((hsv.value * 0.65).clamp(0.0, 1.0))
        .withSaturation((hsv.saturation * 1.1).clamp(0.0, 1.0))
        .toColor();
    final skyBot = userColor;
    final skyPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [skyTop, skyBot],
      ).createShader(Offset.zero & size);
    canvas.drawRect(Offset.zero & size, skyPaint);

    final sunCenter = Offset(w * 0.82, h * 0.22);
    final sunHalo = Paint()
      ..shader = RadialGradient(
        colors: [
          Colors.white.withOpacity(0.95),
          userColor.withOpacity(0.60),
          Colors.transparent,
        ],
      ).createShader(Rect.fromCircle(center: sunCenter, radius: w * 0.38));
    canvas.drawCircle(sunCenter, w * 0.38, sunHalo);
    canvas.drawCircle(sunCenter, w * 0.12, Paint()..color = Colors.white);

    _draw3DVoxelCloud(
      canvas,
      rect: Rect.fromLTWH(w * 0.08, h * 0.38, w * 0.55, h * 0.22),
      topHighlightColor: Color.lerp(Colors.white, userColor, 0.25)!,
      sideShadeColor: Color.lerp(const Color(0xFF90A4AE), userColor, 0.40)!,
      bottomShadeColor: Color.lerp(const Color(0xFF546E7A), userColor, 0.50)!,
    );

    _draw3DVoxelCloud(
      canvas,
      rect: Rect.fromLTWH(w * 0.25, h * 0.52, w * 0.68, h * 0.28),
      topHighlightColor: Colors.white,
      sideShadeColor: Color.lerp(const Color(0xFFCFD8DC), userColor, 0.35)!,
      bottomShadeColor: Color.lerp(const Color(0xFF78909C), userColor, 0.45)!,
    );

    _draw3DVoxelCloud(
      canvas,
      rect: Rect.fromLTWH(0, h * 0.66, w * 0.40, h * 0.26),
      topHighlightColor: Color.lerp(Colors.white, userColor, 0.15)!,
      sideShadeColor: Color.lerp(const Color(0xFFB0BEC5), userColor, 0.35)!,
      bottomShadeColor: Color.lerp(const Color(0xFF607D8B), userColor, 0.45)!,
    );
  }

  void _drawCloudBottom(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final hsv = HSVColor.fromColor(userColor);

    final horizonColor = hsv
        .withValue((hsv.value * 1.25).clamp(0.0, 1.0))
        .withSaturation((hsv.saturation * 0.50).clamp(0.0, 1.0))
        .toColor();
    final skyPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [userColor, horizonColor, const Color(0xFF0B1720)],
        stops: const [0.0, 0.60, 1.0],
      ).createShader(Offset.zero & size);
    canvas.drawRect(Offset.zero & size, skyPaint);

    final horizMtn = Path()
      ..moveTo(0, h * 0.78)
      ..lineTo(w * 0.35, h * 0.70)
      ..lineTo(w * 0.70, h * 0.74)
      ..lineTo(w, h * 0.68)
      ..lineTo(w, h)
      ..lineTo(0, h)
      ..close();
    canvas.drawPath(horizMtn, Paint()..color = const Color(0xFF0D1C24));

    final cloudUnderColor =
        Color.lerp(const Color(0xFF1E293B), userColor, 0.75)!;
    final cloudDarkShadow =
        Color.lerp(const Color(0xFF0F172A), userColor, 0.90)!;

    final underPath = Path()
      ..moveTo(0, 0)
      ..lineTo(w, 0)
      ..lineTo(w, h * 0.52)
      ..lineTo(w * 0.75, h * 0.58)
      ..lineTo(w * 0.55, h * 0.50)
      ..lineTo(w * 0.30, h * 0.56)
      ..lineTo(0, h * 0.48)
      ..close();
    canvas.drawPath(underPath, Paint()..color = cloudDarkShadow);

    final stepPaint = Paint()..color = cloudUnderColor;
    canvas.drawRect(
        Rect.fromLTWH(w * 0.05, h * 0.15, w * 0.40, h * 0.28), stepPaint);
    canvas.drawRect(
        Rect.fromLTWH(w * 0.38, h * 0.10, w * 0.56, h * 0.34), stepPaint);
    canvas.drawRect(
        Rect.fromLTWH(w * 0.20, h * 0.32, w * 0.45, h * 0.18), stepPaint);

    final rimPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.4
      ..color = Color.lerp(Colors.white, userColor, 0.40)!.withOpacity(0.90)
      ..strokeCap = StrokeCap.round;
    final rimPath = Path()
      ..moveTo(0, h * 0.48)
      ..lineTo(w * 0.30, h * 0.56)
      ..lineTo(w * 0.55, h * 0.50)
      ..lineTo(w * 0.75, h * 0.58)
      ..lineTo(w, h * 0.52);
    canvas.drawPath(rimPath, rimPaint);
  }

  void _drawFogTint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final hsv = HSVColor.fromColor(userColor);

    final skyTop = hsv
        .withValue((hsv.value * 0.55).clamp(0.0, 1.0))
        .withSaturation((hsv.saturation * 1.1).clamp(0.0, 1.0))
        .toColor();
    final skyHoriz = hsv
        .withValue((hsv.value * 1.25).clamp(0.0, 1.0))
        .withSaturation((hsv.saturation * 0.45).clamp(0.0, 1.0))
        .toColor();

    final skyPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [skyTop, userColor, skyHoriz],
        stops: const [0.0, 0.45, 1.0],
      ).createShader(Offset.zero & size);
    canvas.drawRect(Offset.zero & size, skyPaint);

    final mtn1 = Path()
      ..moveTo(0, h * 0.50)
      ..lineTo(w * 0.32, h * 0.38)
      ..lineTo(w * 0.65, h * 0.46)
      ..lineTo(w, h * 0.35)
      ..lineTo(w, h)
      ..lineTo(0, h)
      ..close();
    canvas.drawPath(
      mtn1,
      Paint()
        ..color = Color.lerp(const Color(0xFF1E293B), userColor, 0.50)!
            .withOpacity(0.55),
    );

    canvas.drawRect(
      Rect.fromLTWH(0, h * 0.42, w, h * 0.15),
      Paint()..color = userColor.withOpacity(0.35),
    );

    final mtn2 = Path()
      ..moveTo(0, h * 0.62)
      ..lineTo(w * 0.28, h * 0.54)
      ..lineTo(w * 0.58, h * 0.60)
      ..lineTo(w * 0.85, h * 0.52)
      ..lineTo(w, h * 0.58)
      ..lineTo(w, h)
      ..lineTo(0, h)
      ..close();
    canvas.drawPath(
      mtn2,
      Paint()
        ..color = Color.lerp(const Color(0xFF0F172A), userColor, 0.30)!
            .withOpacity(0.75),
    );

    canvas.drawRect(
      Rect.fromLTWH(0, h * 0.56, w, h * 0.20),
      Paint()..color = userColor.withOpacity(0.55),
    );

    final mtn3 = Path()
      ..moveTo(0, h * 0.74)
      ..lineTo(w * 0.40, h * 0.68)
      ..lineTo(w * 0.75, h * 0.72)
      ..lineTo(w, h * 0.66)
      ..lineTo(w, h)
      ..lineTo(0, h)
      ..close();
    canvas.drawPath(mtn3, Paint()..color = const Color(0xFF070D12));

    _drawPineTree(canvas, Offset(w * 0.18, h * 0.70), w * 0.16, h * 0.26,
        const Color(0xFF070D12));
    _drawPineTree(canvas, Offset(w * 0.82, h * 0.68), w * 0.15, h * 0.24,
        const Color(0xFF070D12));
    _drawPineTree(canvas, Offset(w * 0.35, h * 0.74), w * 0.12, h * 0.20,
        const Color(0xFF070D12));
  }

  void _drawTorchLight(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    canvas.drawRect(
        Offset.zero & size, Paint()..color = const Color(0xFF141416));

    final stonePaint = Paint()
      ..color = const Color(0xFF232328)
      ..strokeWidth = 1.0;
    canvas.drawLine(Offset(0, h * 0.33), Offset(w, h * 0.33), stonePaint);
    canvas.drawLine(Offset(0, h * 0.66), Offset(w, h * 0.66), stonePaint);
    canvas.drawLine(
        Offset(w * 0.50, 0), Offset(w * 0.50, h * 0.33), stonePaint);
    canvas.drawLine(
        Offset(w * 0.25, h * 0.33), Offset(w * 0.25, h * 0.66), stonePaint);
    canvas.drawLine(
        Offset(w * 0.75, h * 0.33), Offset(w * 0.75, h * 0.66), stonePaint);
    canvas.drawLine(
        Offset(w * 0.50, h * 0.66), Offset(w * 0.50, h), stonePaint);

    final torchCenter = Offset(w * 0.50, h * 0.42);

    final auraPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          Colors.white.withOpacity(0.95),
          userColor.withOpacity(0.80),
          userColor.withOpacity(0.35),
          Colors.transparent,
        ],
        stops: const [0.0, 0.35, 0.70, 1.0],
      ).createShader(Rect.fromCircle(center: torchCenter, radius: w * 0.48));
    canvas.drawCircle(torchCenter, w * 0.48, auraPaint);

    final woodHandle = RRect.fromRectAndRadius(
      Rect.fromLTWH(w * 0.44, h * 0.44, w * 0.12, h * 0.38),
      const Radius.circular(1.5),
    );
    canvas.drawRRect(woodHandle, Paint()..color = const Color(0xFF8D6E63));
    canvas.drawRect(
      Rect.fromLTWH(w * 0.50, h * 0.44, w * 0.06, h * 0.38),
      Paint()..color = const Color(0xFF5D4037),
    );

    final coalHead = RRect.fromRectAndRadius(
      Rect.fromLTWH(w * 0.42, h * 0.40, w * 0.16, h * 0.08),
      const Radius.circular(1.5),
    );
    canvas.drawRRect(coalHead, Paint()..color = const Color(0xFF263238));

    final outerFlame = Path()
      ..moveTo(w * 0.50, h * 0.22)
      ..quadraticBezierTo(w * 0.64, h * 0.32, w * 0.58, h * 0.42)
      ..lineTo(w * 0.42, h * 0.42)
      ..quadraticBezierTo(w * 0.36, h * 0.32, w * 0.50, h * 0.22)
      ..close();
    canvas.drawPath(
      outerFlame,
      Paint()
        ..shader = RadialGradient(
          colors: [
            Colors.white,
            userColor,
          ],
          stops: const [0.2, 1.0],
        ).createShader(Rect.fromCircle(center: torchCenter, radius: w * 0.16)),
    );

    final innerFlame = Path()
      ..moveTo(w * 0.50, h * 0.28)
      ..quadraticBezierTo(w * 0.58, h * 0.35, w * 0.54, h * 0.41)
      ..lineTo(w * 0.46, h * 0.41)
      ..quadraticBezierTo(w * 0.42, h * 0.35, w * 0.50, h * 0.28)
      ..close();
    canvas.drawPath(innerFlame, Paint()..color = const Color(0xFFFFF9C4));

    final emberPaint = Paint()..color = Colors.white.withOpacity(0.95);
    canvas.drawCircle(Offset(w * 0.42, h * 0.20), 1.4, emberPaint);
    canvas.drawCircle(Offset(w * 0.58, h * 0.16), 1.6, emberPaint);
    canvas.drawCircle(Offset(w * 0.50, h * 0.12), 1.2, emberPaint);
    canvas.drawCircle(Offset(w * 0.36, h * 0.26), 1.0, emberPaint);
  }

  void _drawWaterTint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final hsv = HSVColor.fromColor(userColor);

    final skyColor = hsv
        .withValue((hsv.value * 0.70).clamp(0.0, 1.0))
        .withSaturation((hsv.saturation * 0.6).clamp(0.0, 1.0))
        .toColor();
    canvas.drawRect(
        Rect.fromLTWH(0, 0, w, h * 0.28), Paint()..color = skyColor);

    final waterDeepColor = hsv
        .withValue((hsv.value * 0.45).clamp(0.0, 1.0))
        .withSaturation((hsv.saturation * 1.25).clamp(0.0, 1.0))
        .toColor();
    final waterPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [userColor, waterDeepColor],
      ).createShader(Rect.fromLTWH(0, h * 0.28, w, h * 0.72));
    canvas.drawRect(Rect.fromLTWH(0, h * 0.28, w, h * 0.72), waterPaint);

    final wavePaint = Paint()
      ..color = Colors.white.withOpacity(0.90)
      ..strokeWidth = 2.2
      ..strokeCap = StrokeCap.round;
    final wavePath = Path()
      ..moveTo(0, h * 0.28)
      ..quadraticBezierTo(w * 0.25, h * 0.25, w * 0.50, h * 0.28)
      ..quadraticBezierTo(w * 0.75, h * 0.31, w, h * 0.28);
    canvas.drawPath(wavePath, wavePaint);

    final sandPath = Path()
      ..moveTo(0, h * 0.80)
      ..lineTo(w * 0.35, h * 0.76)
      ..lineTo(w * 0.70, h * 0.82)
      ..lineTo(w, h * 0.78)
      ..lineTo(w, h)
      ..lineTo(0, h)
      ..close();
    canvas.drawPath(sandPath, Paint()..color = const Color(0xFFC2B280));
    canvas.drawPath(
      sandPath,
      Paint()..color = userColor.withOpacity(0.45),
    );

    final causticPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4
      ..color = Colors.white.withOpacity(0.70);
    final causticPath = Path()
      ..moveTo(w * 0.10, h * 0.82)
      ..quadraticBezierTo(w * 0.25, h * 0.76, w * 0.40, h * 0.84)
      ..quadraticBezierTo(w * 0.60, h * 0.77, w * 0.80, h * 0.83)
      ..moveTo(w * 0.20, h * 0.88)
      ..quadraticBezierTo(w * 0.45, h * 0.83, w * 0.70, h * 0.90);
    canvas.drawPath(causticPath, causticPaint);

    final kelpPaint = Paint()
      ..color = const Color(0xFF2E7D32).withOpacity(0.85)
      ..strokeWidth = 2.4
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(
        Offset(w * 0.20, h * 0.78), Offset(w * 0.18, h * 0.52), kelpPaint);
    canvas.drawLine(
        Offset(w * 0.25, h * 0.77), Offset(w * 0.28, h * 0.48), kelpPaint);

    final bubblePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.1
      ..color = Colors.white.withOpacity(0.85);
    final bubbleFill = Paint()..color = Colors.white.withOpacity(0.30);

    final bubblePositions = [
      Offset(w * 0.60, h * 0.65),
      Offset(w * 0.68, h * 0.52),
      Offset(w * 0.54, h * 0.42),
      Offset(w * 0.78, h * 0.60),
      Offset(w * 0.42, h * 0.58),
    ];
    for (int i = 0; i < bubblePositions.length; i++) {
      final r = 1.8 + (i % 3) * 0.9;
      canvas.drawCircle(bubblePositions[i], r, bubbleFill);
      canvas.drawCircle(bubblePositions[i], r, bubblePaint);
    }
  }

  void _drawPineTree(
      Canvas canvas, Offset base, double tw, double th, Color color) {
    final p = Paint()..color = color;
    canvas.drawRect(
        Rect.fromLTWH(
            base.dx - tw * 0.1, base.dy - th * 0.2, tw * 0.2, th * 0.2),
        p);
    for (int i = 0; i < 3; i++) {
      final tierW = tw * (1.0 - i * 0.25);
      final tierH = th * 0.4;
      final tierY = base.dy - th * 0.2 - (i * th * 0.26);
      final treePath = Path()
        ..moveTo(base.dx, tierY - tierH)
        ..lineTo(base.dx + tierW / 2, tierY)
        ..lineTo(base.dx - tierW / 2, tierY)
        ..close();
      canvas.drawPath(treePath, p);
    }
  }

  void _draw3DVoxelCloud(
    Canvas canvas, {
    required Rect rect,
    required Color topHighlightColor,
    required Color sideShadeColor,
    required Color bottomShadeColor,
  }) {
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(rect.left, rect.top, rect.width, rect.height * 0.45),
        const Radius.circular(3),
      ),
      Paint()..color = topHighlightColor,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(rect.left, rect.top + rect.height * 0.40, rect.width,
            rect.height * 0.35),
        const Radius.circular(2),
      ),
      Paint()..color = sideShadeColor,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(rect.left + 2, rect.top + rect.height * 0.70,
            rect.width - 4, rect.height * 0.30),
        const Radius.circular(2),
      ),
      Paint()..color = bottomShadeColor,
    );
  }

  void _drawVoxelCloud(Canvas canvas, Offset pos, double cw, double ch) {
    final cloudPaint = Paint()..color = Colors.white.withOpacity(0.88);
    final shadowPaint =
        Paint()..color = const Color(0xFFB0BEC5).withOpacity(0.65);

    canvas.drawRRect(
      RRect.fromRectAndRadius(
          Rect.fromLTWH(pos.dx - cw / 2, pos.dy, cw, ch * 0.6),
          const Radius.circular(3)),
      cloudPaint,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
          Rect.fromLTWH(
              pos.dx - cw * 0.25, pos.dy - ch * 0.4, cw * 0.55, ch * 0.5),
          const Radius.circular(3)),
      cloudPaint,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
          Rect.fromLTWH(
              pos.dx - cw / 2 + 1, pos.dy + ch * 0.48, cw - 2, ch * 0.15),
          const Radius.circular(1)),
      shadowPaint,
    );
  }

  void _drawSparkle(Canvas canvas, Offset pos, double size) {
    final paint = Paint()
      ..color = Colors.white
      ..strokeWidth = 1.0
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(
        Offset(pos.dx - size, pos.dy), Offset(pos.dx + size, pos.dy), paint);
    canvas.drawLine(
        Offset(pos.dx, pos.dy - size), Offset(pos.dx, pos.dy + size), paint);
  }

  @override
  bool shouldRepaint(covariant TimeSceneryPainter oldDelegate) {
    return oldDelegate.timeOfDay != timeOfDay ||
        oldDelegate.userColor != userColor;
  }
}

