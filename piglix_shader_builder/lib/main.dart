import 'dart:ui';
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:archive/archive.dart';
import 'package:universal_html/html.dart' as html;
import 'package:uuid/uuid.dart';
import 'package:dio/dio.dart' as dio;

void main() {
  runApp(const PiglixProApp());
}

class PiglixProApp extends StatelessWidget {
  const PiglixProApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Piglix Shader Studio',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF121212),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFFFAFAFA),
          secondary: Color(0xFFFF4081),
          surface: Color(0xFF1E1E1E),
        ),
        fontFamily: 'Inter',
        useMaterial3: true,
      ),
      home: const StudioDashboard(),
    );
  }
}

class StudioDashboard extends StatefulWidget {
  const StudioDashboard({super.key});

  @override
  State<StudioDashboard> createState() => _StudioDashboardState();
}

class _StudioDashboardState extends State<StudioDashboard> {
  String selectedEngine = 'json'; // 'json' or 'bin'
  bool isCloudConnected = true;
  
  // Customization State
  TextEditingController shaderNameController = TextEditingController(text: "Piglix Shader");
  Color morningColor = const Color(0xFFFF9AA2);
  Color noonColor = const Color(0xFF87CEEB);
  Color eveningColor = const Color(0xFFFFA500);
  Color nightColor = const Color(0xFF00008B);
  
  // Global Tints
  Color rayColor = const Color(0xFFFAFCFF);
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

  void _pickColor(BuildContext context, String title, Color currentColor, Function(Color) onColorChanged) {
    Color tempColor = currentColor;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E1E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        title: Text('Define $title Hex', style: const TextStyle(fontWeight: FontWeight.w600)),
        content: SingleChildScrollView(
          child: ColorPicker(
            pickerColor: tempColor,
            onColorChanged: (c) => tempColor = c,
            enableAlpha: false,
            displayThumbColor: true,
            hexInputBar: true, // Professional feature
            paletteType: PaletteType.hsvWithHue,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('CANCEL', style: TextStyle(color: Colors.white54, letterSpacing: 1)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: Colors.black,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
            ),
            onPressed: () {
              setState(() => onColorChanged(tempColor));
              Navigator.pop(context);
            },
            child: const Text('CONFIRM', style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF121212),
        elevation: 0,
        title: Row(
          children: [
            const Icon(Icons.code, color: Colors.white),
            const SizedBox(width: 12),
            const Text(
              'PIGLIX STUDIO',
              style: TextStyle(fontWeight: FontWeight.w800, letterSpacing: 2, fontSize: 18),
            ),
            const Spacer(),
            // Cloud Connection Indicator
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: isCloudConnected ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: isCloudConnected ? Colors.green : Colors.red),
              ),
              child: Row(
                children: [
                  Icon(
                    isCloudConnected ? Icons.cloud_done : Icons.cloud_off,
                    size: 14,
                    color: isCloudConnected ? Colors.green : Colors.red,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    isCloudConnected ? 'Cloud Active' : 'Offline Mode',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: isCloudConnected ? Colors.green : Colors.red,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: Colors.white10, height: 1),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'ENGINE SELECTION',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1.5, color: Colors.white54),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _EngineCard(
                    title: 'Vibrant Engine',
                    subtitle: 'JSON Deferred API',
                    icon: Icons.data_object,
                    isSelected: selectedEngine == 'json',
                    onTap: () => setState(() => selectedEngine = 'json'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _EngineCard(
                    title: 'Classic Engine',
                    subtitle: 'C++ Material Bin',
                    icon: Icons.memory,
                    isSelected: selectedEngine == 'bin',
                    onTap: () => setState(() => selectedEngine = 'bin'),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 32),
            
            if (selectedEngine == 'bin') _buildCloudWarning(),
            if (selectedEngine == 'bin') const SizedBox(height: 24),
            _buildSettings(),
            
            const SizedBox(height: 48),
            
            // Professional Generate Button
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                  elevation: 0,
                ),
                onPressed: _compileShader,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(selectedEngine == 'bin' ? Icons.cloud_upload : Icons.build, size: 20),
                    const SizedBox(width: 12),
                    Text(
                      selectedEngine == 'bin' ? 'COMPILE VIA CLOUD' : 'BUILD MCPACK LOCALLY',
                      style: const TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.5),
                    ),
                  ],
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
        const Text(
          'ATMOSPHERIC CONSTANTS',
          style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1.5, color: Colors.white54),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: const Color(0xFF1E1E1E),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.white10),
          ),
          child: Column(
            children: [
              TextField(
                controller: shaderNameController,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  labelText: 'Custom Shader Name',
                  labelStyle: TextStyle(color: Colors.white54),
                  enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.white10)),
                  focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Color(0xFFFF2A70))),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _ColorNode('Morning', morningColor, (c) => morningColor = c),
                  _ColorNode('Noon', noonColor, (c) => noonColor = c),
                  _ColorNode('Evening', eveningColor, (c) => eveningColor = c),
                  _ColorNode('Night', nightColor, (c) => nightColor = c),
                ],
              ),
              const SizedBox(height: 16),
              const Text('GLOBAL TINTS', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1.5, color: Colors.white54)),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _ColorNode('Rays', rayColor, (c) => rayColor = c),
                  _ColorNode('Fog Color', fogColor, (c) => fogColor = c),
                  _ColorNode('Water Tint', waterColor, (c) => waterColor = c),
                ],
              ),
              const Divider(height: 40, color: Colors.white10),
              
              const Text('PRO SETTINGS', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1.5, color: Colors.white54)),
              const SizedBox(height: 16),
              
              // Water Quality
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Water Reflection & Quality', style: TextStyle(fontWeight: FontWeight.w600)),
                  DropdownButton<String>(
                    value: waterQuality,
                    dropdownColor: const Color(0xFF2A2A2A),
                    underline: const SizedBox(),
                    items: ['Low', 'Medium', 'Ultra'].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                    onChanged: (v) => setState(() => waterQuality = v!),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              
              // Fog Density
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Fog Density', style: TextStyle(fontWeight: FontWeight.w600)),
                  Expanded(
                    child: Slider(
                      value: fogDensity,
                      min: 0.1,
                      max: 3.0,
                      divisions: 29,
                      activeColor: const Color(0xFFFF2A70),
                      label: '${(fogDensity * 100).toInt()}%',
                      onChanged: (v) => setState(() => fogDensity = v),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              
              // Sun/Moon Size
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Sun Size Multiplier', style: TextStyle(fontWeight: FontWeight.w600)),
                  Expanded(
                    child: Slider(
                      value: sunSize,
                      min: 0.5,
                      max: 3.0,
                      divisions: 25,
                      activeColor: const Color(0xFFFF2A70),
                      label: '${sunSize}x',
                      onChanged: (v) => setState(() => sunSize = v),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              
              // Light Intensity
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Light Intensity', style: TextStyle(fontWeight: FontWeight.w600)),
                  Expanded(
                    child: Slider(
                      value: lightIntensity,
                      min: 0.1,
                      max: 3.0,
                      divisions: 29,
                      activeColor: const Color(0xFFFF2A70),
                      label: '${(lightIntensity * 100).toInt()}%',
                      onChanged: (v) => setState(() => lightIntensity = v),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              
              // Shadow Fidelity
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Shadow Fidelity', style: TextStyle(fontWeight: FontWeight.w600)),
                  DropdownButton<String>(
                    value: shadowFidelity,
                    dropdownColor: const Color(0xFF2A2A2A),
                    underline: const SizedBox(),
                    items: ['Off', 'Ultra-Low (128px)', 'Hard Shadows (256px)', 'Soft Shadows (1024px)'].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                    onChanged: (v) => setState(() => shadowFidelity = v!),
                  ),
                ],
              ),
              if (selectedEngine == 'json') ...[
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Volumetric Fog (Sun Rays)', style: TextStyle(fontWeight: FontWeight.w600)),
                    DropdownButton<String>(
                      value: volumetricRays,
                      dropdownColor: const Color(0xFF2A2A2A),
                      underline: const SizedBox(),
                      items: ['Cinematic (Heavy)', 'Balanced', 'Low End'].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                      onChanged: (v) => setState(() => volumetricRays = v!),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('World Reflections', style: TextStyle(fontWeight: FontWeight.w600)),
                    DropdownButton<String>(
                      value: worldReflections,
                      dropdownColor: const Color(0xFF2A2A2A),
                      underline: const SizedBox(),
                      items: ['Off (Matte)', 'Low (Glossy)', 'High (Wet)', 'Ultra (Mirror)'].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                      onChanged: (v) => setState(() => worldReflections = v!),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('PBR Bump Mapping', style: TextStyle(fontWeight: FontWeight.w600)),
                    Switch(value: enablePBR, activeColor: const Color(0xFFFF2A70), onChanged: (v) => setState(() => enablePBR = v)),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Point Light Shadows', style: TextStyle(fontWeight: FontWeight.w600)),
                    Switch(value: enablePointLightShadows, activeColor: const Color(0xFFFF2A70), onChanged: (v) => setState(() => enablePointLightShadows = v)),
                  ],
                ),
              ],
              if (selectedEngine == 'bin') ...[
                const SizedBox(height: 12),
                
                // Cloud Type
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Cloud Type', style: TextStyle(fontWeight: FontWeight.w600)),
                    DropdownButton<String>(
                      value: cloudType,
                      dropdownColor: const Color(0xFF2A2A2A),
                      underline: const SizedBox(),
                      items: ['Realistic 3D', 'Box Clouds', 'Disabled'].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                      onChanged: (v) => setState(() => cloudType = v!),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                
                // Waving Foliage
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Waving Foliage (Leaves/Grass)', style: TextStyle(fontWeight: FontWeight.w600)),
                    Switch(
                      value: wavingFoliage,
                      activeColor: const Color(0xFFFF2A70),
                      onChanged: (v) => setState(() => wavingFoliage = v),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
  
  Widget _buildCloudWarning() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.blueAccent.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.cloud_sync, color: Colors.blueAccent),
              const SizedBox(width: 12),
              const Text('Cloud Compilation Required', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            ],
          ),
          const SizedBox(height: 16),
          const Text(
            'Material Bin (.material.bin) shaders require C++ toolchains that cannot run natively on Android/iOS. \n\nWhen you select this engine, your parameters will be sent to the Piglix Cloud Server, which will compile the shader from source (newb-source) and stream the final .mcpack back to this device.',
            style: TextStyle(color: Colors.white70, height: 1.5),
          ),
        ],
      ),
    );
  }
  
  Widget _ColorNode(String label, Color c, Function(Color) onChanged) {
    return GestureDetector(
      onTap: () => _pickColor(context, label, c, onChanged),
      child: Column(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: c,
              shape: BoxShape.rectangle,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.white24),
            ),
          ),
          const SizedBox(height: 8),
          Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white70)),
        ],
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
          backgroundColor: const Color(0xFF1E1E1E),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.architecture, size: 48, color: Colors.white),
                const SizedBox(height: 16),
                ValueListenableBuilder<String>(
                  valueListenable: statusNotifier,
                  builder: (context, status, child) => Text(status, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                ),
                const SizedBox(height: 24),
                ValueListenableBuilder<double>(
                  valueListenable: progressNotifier,
                  builder: (context, progress, child) => LinearProgressIndicator(
                    value: progress,
                    backgroundColor: Colors.white10,
                    valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFFF2A70)),
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
      if (selectedEngine == 'bin') {
        statusNotifier.value = "Uplinking to Piglix Cloud...";
        progressNotifier.value = 0.2;
        
        String packName = shaderNameController.text.trim();
        if (packName.isEmpty) packName = "Piglix Shader";

        String hexStr(Color c) => '#${c.value.toRadixString(16).substring(2).toUpperCase()}';
        final payload = {
          'packName': packName,
          'morning': hexStr(morningColor),
          'noon': hexStr(noonColor),
          'evening': hexStr(eveningColor),
          'night': hexStr(nightColor),
          'rayColor': hexStr(rayColor),
          'fogColor': hexStr(fogColor),
          'waterColor': hexStr(waterColor),
          'lightIntensity': lightIntensity.toString(),
          'fogDensity': fogDensity.toString(),
          'sunSize': sunSize.toString(),
          'waterQuality': waterQuality,
          'shadowFidelity': shadowFidelity,
          'cloudType': cloudType,
          'wavingFoliage': wavingFoliage,
        };
        
        statusNotifier.value = "Cloud Compiling C++ Shader...";
        progressNotifier.value = 0.5;
        
        final response = await dio.Dio().post(
          'http://127.0.0.1:5001/compile_bin',
          data: payload,
          options: dio.Options(responseType: dio.ResponseType.bytes),
        );
        
        statusNotifier.value = "Downloading from Cloud...";
        progressNotifier.value = 0.9;
        
        final blob = html.Blob([response.data]);
        final url = html.Url.createObjectUrlFromBlob(blob);
        html.AnchorElement(href: url)
          ..setAttribute("download", "$packName.mcpack")
          ..click();
        html.Url.revokeObjectUrl(url);
        
        await Future.delayed(const Duration(milliseconds: 500));
        if (mounted) Navigator.pop(context);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('✨ Bin Shader compiled and downloaded!'), backgroundColor: Colors.green, behavior: SnackBarBehavior.floating),
          );
        }
        return;
      }

      await Future.delayed(const Duration(milliseconds: 600));
      statusNotifier.value = "Reading JSON Assets...";
      progressNotifier.value = 0.3;
      ByteData data = await rootBundle.load('assets/base_shader.zip');
      List<int> bytes = data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);

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
          if (file.name == 'manifest.json') {
            String content = utf8.decode(fileData);
            Map<String, dynamic> manifest = jsonDecode(content);
            manifest['header']['uuid'] = const Uuid().v4();
            manifest['modules'][0]['uuid'] = const Uuid().v4();
            
            String pName = shaderNameController.text.trim();
            if (pName.isEmpty) pName = "Piglix Shader";
            manifest['header']['name'] = pName;
            manifest['header']['description'] = "Created with Piglix Shader Studio";
            
            fileData = utf8.encode(jsonEncode(manifest));
          }

          if (file.name.contains('water.json')) {
            String content = utf8.decode(fileData);
            Map<String, dynamic> jsonMap = jsonDecode(content);
            var waves = jsonMap['minecraft:water_settings']?['waves'];
            if (waves != null) {
              if (waterQuality == 'Low') waves['octaves'] = 3;
              else if (waterQuality == 'Medium') waves['octaves'] = 8;
              else if (waterQuality == 'Ultra') waves['octaves'] = 13;
            }
            fileData = utf8.encode(jsonEncode(jsonMap));
          }
          
          if (!enablePBR && file.name.endsWith('.json')) {
            String content = utf8.decode(fileData);
            content = content.replaceAll(RegExp(r'"bump_mapping"\s*:\s*true'), '"bump_mapping": false');
            fileData = utf8.encode(content);
          }

          if (file.name == 'shadows/global.json') {
            String content = utf8.decode(fileData);
            Map<String, dynamic> jsonMap = jsonDecode(content);
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
          
          if (file.name == 'lighting/global.json') {
            String content = utf8.decode(fileData);
            Map<String, dynamic> jsonMap = jsonDecode(content);
            List<int> toRgb(Color c) => [c.red, c.green, c.blue];
            
            var sunColor = jsonMap['minecraft:lighting_settings']['directional_lights']['sun']['color'];
            for (var key in sunColor.keys.toList()) {
                sunColor[key] = toRgb(rayColor);
            }
            
            var sunIllum = jsonMap['minecraft:lighting_settings']['directional_lights']['sun']['illuminance'];
            for (var key in sunIllum.keys.toList()) {
                double val = (sunIllum[key] as num).toDouble();
                sunIllum[key] = val * lightIntensity;
            }
            
            content = jsonEncode(jsonMap);
            
            if (volumetricRays == 'Low End') {
               content = content.replaceAll('"0.75": 20', '"0.75": 2');
               content = content.replaceAll('"0.76": 30', '"0.76": 3');
               content = content.replaceAll('"0.78": 60', '"0.78": 6');
               content = content.replaceAll('"0.795": 90', '"0.795": 9');
               content = content.replaceAll('"0.81": 90', '"0.81": 9');
            }
            fileData = utf8.encode(content);
          }
          
          if (file.name == 'pbr/global.json') {
            String content = utf8.decode(fileData);
            Map<String, dynamic> jsonMap = jsonDecode(content);
            int roughness = 255;
            if (worldReflections.contains('Low')) roughness = 180;
            if (worldReflections.contains('High')) roughness = 100;
            if (worldReflections.contains('Ultra')) roughness = 10;
            
            var blocks = jsonMap['minecraft:pbr_fallback_settings']['blocks'];
            blocks['global_metalness_emissive_roughness_subsurface'] = [0, 0, roughness, 0];
            fileData = utf8.encode(jsonEncode(jsonMap));
          }
          
          if (file.name == 'fogs/General.json') {
            String content = utf8.decode(fileData);
            Map<String, dynamic> jsonMap = jsonDecode(content);
            String hexStr(Color c) => '#${c.value.toRadixString(16).substring(2).toUpperCase()}';
            var dist = jsonMap['minecraft:fog_settings']['distance'];
            dist['air']['fog_color'] = hexStr(fogColor);
            dist['water']['fog_color'] = hexStr(waterColor);
            
            if (dist['air']['fog_start'] != null) {
                dist['air']['fog_start'] = (dist['air']['fog_start'] as num).toDouble() / fogDensity;
            }
            if (dist['air']['fog_end'] != null) {
                dist['air']['fog_end'] = (dist['air']['fog_end'] as num).toDouble() / fogDensity;
            }
            
            var vol = jsonMap['minecraft:fog_settings']['volumetric'];
            if (vol != null) {
                if (vol['density'] != null && vol['density']['air'] != null) {
                    var dens = vol['density']['air']['max_density'];
                    if (dens != null) {
                        vol['density']['air']['max_density'] = (dens as num).toDouble() * fogDensity;
                    }
                }
                if (vol['media_coefficients'] != null && vol['media_coefficients']['air'] != null) {
                    vol['media_coefficients']['air']['scattering'] = [rayColor.red / 255.0 * 0.25, rayColor.green / 255.0 * 0.25, rayColor.blue / 255.0 * 0.25];
                }
            }
            
            fileData = utf8.encode(jsonEncode(jsonMap));
          }
          
          if (file.name == 'atmospherics/atmospherics.json') {
            String content = utf8.decode(fileData);
            Map<String, dynamic> jsonMap = jsonDecode(content);
            
            var settings = jsonMap['minecraft:atmosphere_settings'];
            
            if (settings['sun_glare_shape'] != null) {
                var glare = settings['sun_glare_shape'];
                for (var key in glare.keys.toList()) {
                    glare[key] = (5.0 / sunSize);
                }
            }
            
            var zenith = settings['sky_zenith_color'];
            var horizon = settings['sky_horizon_color'];
            
            List<int> toRgb(Color c) => [c.red, c.green, c.blue];
            
            // Noon (0.0)
            zenith['0.0'] = toRgb(noonColor);
            horizon['0.0'] = toRgb(noonColor);
            
            // Evening/Sunset (0.25)
            zenith['0.25'] = toRgb(eveningColor);
            horizon['0.25'] = toRgb(eveningColor);
            
            // Night (0.50)
            zenith['0.50'] = toRgb(nightColor);
            horizon['0.50'] = toRgb(nightColor);
            
            // Morning/Sunrise (0.75)
            zenith['0.75'] = toRgb(morningColor);
            horizon['0.75'] = toRgb(morningColor);
            
            fileData = utf8.encode(jsonEncode(jsonMap));
          }
          newArchive.addFile(ArchiveFile(file.name, fileData.length, fileData));
        }
      }
      
      if (!enablePointLightShadows) {
        String pl = '{"format_version":"1.21.40","minecraft:point_lighting_settings":{"description":{"identifier":"Piglix:point"},"point_light_shadows":{"enabled":false}}}';
        newArchive.addFile(ArchiveFile('lighting/point_lights.json', pl.length, utf8.encode(pl)));
      }

      await Future.delayed(const Duration(milliseconds: 600));
      statusNotifier.value = "Encoding Final MCPACK...";
      progressNotifier.value = 0.9;
      final encodedBytes = ZipEncoder().encode(newArchive);
      if (encodedBytes == null) throw Exception("Failed to encode zip");

      await Future.delayed(const Duration(milliseconds: 600));
      statusNotifier.value = "Downloading to Device...";
      progressNotifier.value = 1.0;
      
      // Force download in browser using universal_html
      final blob = html.Blob([encodedBytes]);
      final url = html.Url.createObjectUrlFromBlob(blob);
      String pName = shaderNameController.text.trim();
      if (pName.isEmpty) pName = "Piglix Shader";
      
      html.AnchorElement(href: url)
        ..setAttribute("download", "$pName.mcpack")
        ..click();
      html.Url.revokeObjectUrl(url);

      await Future.delayed(const Duration(milliseconds: 500));
      if (mounted) Navigator.pop(context); // Close dialog

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('✨ MCPack generated and downloaded!'), backgroundColor: Colors.green, behavior: SnackBarBehavior.floating),
        );
      }
    } catch (e) {
      if (mounted) Navigator.pop(context);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red, behavior: SnackBarBehavior.floating),
        );
      }
    }
  }
}

class _EngineCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _EngineCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white.withOpacity(0.05) : const Color(0xFF1E1E1E),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? Colors.white : Colors.white10,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 28, color: isSelected ? Colors.white : Colors.white54),
            const SizedBox(height: 16),
            Text(title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: isSelected ? Colors.white : Colors.white70)),
            const SizedBox(height: 4),
            Text(subtitle, style: const TextStyle(fontSize: 11, color: Colors.white54)),
          ],
        ),
      ),
    );
  }
}
