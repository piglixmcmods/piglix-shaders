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
        scaffoldBackgroundColor: const Color(0xFF111312),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFFFAFAFA),
          secondary: Color(0xFF6DE846),
          surface: Color(0xFF181E19),
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
  FragmentProgram? previewProgram;
  bool _isGenerated = false;
  List<int>? _generatedPackBytes;
  String? _generatedPackName;

  void _downloadPack() {
    if (_generatedPackBytes == null) return;
    String pName = _generatedPackName ?? (shaderNameController.text.trim().isEmpty ? "Piglix Shader" : shaderNameController.text.trim());
    if (!pName.endsWith('.mcpack')) pName = '$pName.mcpack';

    final blob = html.Blob([_generatedPackBytes], 'application/octet-stream');
    final url = html.Url.createObjectUrlFromBlob(blob);
    html.AnchorElement(href: url)
      ..setAttribute("download", pName)
      ..click();
    html.Url.revokeObjectUrl(url);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Color(0xFF6DE846), size: 18),
            const SizedBox(width: 8),
            Text('Downloaded $pName!'),
          ],
        ),
        backgroundColor: const Color(0xFF181E19),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _openWithMinecraft() {
    _downloadPack();
    try {
      html.window.open('minecraft://', '_self');
    } catch (_) {}
  }

  @override
  void initState() {
    super.initState();
  }

  
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
  double globalSaturation = 1.0;
  String toneMapFilter = 'ACES (Cinematic)';
  double nightVision = 1.0;
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
        backgroundColor: const Color(0xFF111312),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(color: Color(0xFF385E2E), width: 1.5)
        ),
        title: Row(
            children: [
                const Icon(Icons.help_outline, color: Color(0xFF6DE846)),
                const SizedBox(width: 12),
                Text(title, style: const TextStyle(fontWeight: FontWeight.w800, color: Color(0xFF6DE846), fontSize: 16)),
            ]
        ),
        content: Text(info, style: const TextStyle(color: Colors.white70, fontSize: 14, height: 1.5)),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF6DE846), foregroundColor: Colors.black),
            onPressed: () => Navigator.pop(context),
            child: const Text('GOT IT', style: TextStyle(fontWeight: FontWeight.bold)),
          )
        ],
      ),
    );
  }

  Widget _buildTitleWithHelp(String title, String tooltip) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(title, style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.white70, fontSize: 13)),
        const SizedBox(width: 6),
        if (tooltip.isNotEmpty)
          GestureDetector(
            onTap: () => _showTooltip(title, tooltip),
            child: const Icon(Icons.help_outline, size: 14, color: Colors.white38),
          )
      ]
    );
  }

  void _pickColor(BuildContext context, String title, Color currentColor, Function(Color) onColorChanged) {
    Color tempColor = currentColor;
    final TextEditingController hexController = TextEditingController(text: currentColor.value.toRadixString(16).substring(2).toUpperCase());

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            backgroundColor: const Color(0xFF111312),
            surfaceTintColor: Colors.transparent,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: const BorderSide(color: Color(0xFF385E2E), width: 1.5)
            ),
            titlePadding: const EdgeInsets.only(top: 24, left: 24, right: 24, bottom: 8),
            title: Text(
                'DEFINE ${title.toUpperCase()}', 
                style: const TextStyle(fontWeight: FontWeight.w800, color: Color(0xFF6DE846), fontSize: 16, letterSpacing: 1.5)
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Divider(color: Colors.white10, thickness: 1),
                  const SizedBox(height: 16),
                  ColorPicker(
                    pickerColor: tempColor,
                    onColorChanged: (c) {
                      setDialogState(() {
                        tempColor = c;
                        hexController.text = c.value.toRadixString(16).substring(2).toUpperCase();
                      });
                    },
                    enableAlpha: false,
                    displayThumbColor: true,
                    hexInputBar: false, // We use our custom one below
                    labelTypes: const [],
                    paletteType: PaletteType.hsvWithHue,
                    pickerAreaBorderRadius: BorderRadius.circular(8), // Make it properly rounded
                    pickerAreaHeightPercent: 0.75,
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      const Text('Hex', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextField(
                          controller: hexController,
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, letterSpacing: 1),
                          decoration: InputDecoration(
                            isDense: true,
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                            filled: true,
                            fillColor: const Color(0xFF181E19),
                            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFF385E2E), width: 1.5)),
                            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFF6DE846), width: 2)),
                          ),
                          onChanged: (val) {
                            if (val.length == 6) {
                              setDialogState(() {
                                tempColor = Color(int.parse('FF$val', radix: 16));
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
                child: const Text('CANCEL', style: TextStyle(color: Colors.white54, letterSpacing: 1, fontWeight: FontWeight.bold)),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6DE846),
                  foregroundColor: Colors.black,
                  elevation: 4,
                  shadowColor: const Color(0xFF6DE846).withOpacity(0.5),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                onPressed: () {
                  setState(() => onColorChanged(tempColor));
                  Navigator.pop(context);
                },
                child: const Text('CONFIRM', style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.2)),
              ),
            ],
          );
        }
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF111312),
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
            
            // Professional Action Area
            if (!_isGenerated)
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6DE846),
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    elevation: 4,
                  ),
                  onPressed: _compileShader,
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.auto_awesome, size: 20, color: Colors.black),
                      SizedBox(width: 12),
                      Text(
                        'GENERATE SHADER',
                        style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1.5, fontSize: 15),
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
                          backgroundColor: const Color(0xFF6DE846),
                          foregroundColor: Colors.black,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          elevation: 4,
                        ),
                        onPressed: _openWithMinecraft,
                        icon: const Icon(Icons.play_arrow_rounded, size: 26, color: Colors.black),
                        label: const Text(
                          'OPEN WITH MINECRAFT',
                          style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1.2, fontSize: 14),
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
                        backgroundColor: const Color(0xFF181E19),
                        foregroundColor: const Color(0xFF6DE846),
                        padding: EdgeInsets.zero,
                        side: const BorderSide(color: Color(0xFF385E2E), width: 1.5),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        elevation: 2,
                      ),
                      onPressed: _downloadPack,
                      child: const Icon(Icons.download_rounded, size: 26, color: Color(0xFF6DE846)),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Center(
                child: TextButton.icon(
                  onPressed: () => setState(() => _isGenerated = false),
                  icon: const Icon(Icons.refresh, size: 16, color: Colors.white54),
                  label: const Text('Edit settings & regenerate', style: TextStyle(color: Colors.white54, fontSize: 12)),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }


  


  Widget _buildSettings() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: shaderNameController,
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          decoration: const InputDecoration(
            labelText: 'Custom Shader Name',
            labelStyle: TextStyle(color: Colors.white54),
            filled: true,
            fillColor: Color(0xFF181E19),
            enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Color(0xFF385E2E))),
            focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Color(0xFF6DE846))),
            prefixIcon: Icon(Icons.edit, color: Color(0xFF6DE846)),
          ),
        ),
        const SizedBox(height: 24),
        
        _buildCategoryCard('TIME & ATMOSPHERE', Icons.wb_sunny, [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
                    _ColorNode('Morning', '', morningColor, (c) => morningColor = c),
                    _ColorNode('Noon', '', noonColor, (c) => noonColor = c),
                    _ColorNode('Evening', '', eveningColor, (c) => eveningColor = c),
                    _ColorNode('Night', '', nightColor, (c) => nightColor = c)
                ]),
                Positioned(
                  right: -8,
                  top: -8,
                  child: GestureDetector(
                    onTap: () => _showTooltip('Time of Day Sky Tinting', 'Defines the exact sky colors at different times of the Minecraft day cycle.\n\n• Morning: Tints sunrise.\n• Noon: Tints midday.\n• Evening: Tints sunset.\n• Night: Tints midnight.'),
                    child: const Icon(Icons.help_outline, size: 16, color: Colors.white38),
                  )
                )
              ]
            ),
            _sliderRow('Sun Size Multiplier', 'Mathematically scales the size of the Sun and Moon textures rendered in the skybox. Larger values create a massive, cinematic celestial body, while smaller values look more realistic.', sunSize, 0.0, 2.0, 20, sunSize == 1.0 ? '1.0x (Default)' : '${sunSize.toStringAsFixed(1)}x', (v) => sunSize = v),
            _sliderRow('Night Brightness', 'Overrides the vanilla Minecraft moonlight intensity. Increasing this makes midnight completely visible without torches, while lowering it creates pitch-black, hardcore darkness.', nightVision, 0.0, 2.0, 20, nightVision == 1.0 ? '1.0x (Default)' : '${nightVision.toStringAsFixed(1)}x', (v) => nightVision = v),
            if (selectedEngine == 'json') _sliderRow('Fog Density', 'Adjusts how close the atmospheric fog starts relative to the player. Higher density obscures distant chunks completely, creating a thick, moody atmosphere.', fogDensity, 0.0, 2.0, 20, fogDensity == 1.0 ? '1.0x (Default)' : '${fogDensity.toStringAsFixed(1)}x', (v) => fogDensity = v),
            if (selectedEngine == 'json') _dropdownRow('Volumetric Fog', 'Defines the quality and depth of 3D God-Rays intersecting the fog. Cinematic calculates high-density scattering but costs more FPS. Low End uses flat rendering.', ['Cinematic (Heavy)', 'Balanced', 'Low End'], volumetricRays, (v) => volumetricRays = v),
            if (selectedEngine == 'json') const SizedBox(height: 16),
            if (selectedEngine == 'json') Stack(
              clipBehavior: Clip.none,
              children: [
                Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
                    _ColorNode('Cloud Top', '', cloudTopColor, (c) => cloudTopColor = c),
                    _ColorNode('Cloud Bottom', '', cloudBottomColor, (c) => cloudBottomColor = c),
                ]),
                Positioned(
                  right: -8,
                  top: -8,
                  child: GestureDetector(
                    onTap: () => _showTooltip('Volumetric Cloud Tinting', 'Defines the colors of the 3D clouds.\n\n• Cloud Top: The color of the clouds where the sun hits them directly.\n• Cloud Bottom: The color of the shadows underneath the clouds.'),
                    child: const Icon(Icons.help_outline, size: 16, color: Colors.white38),
                  )
                )
              ]
            ),
        ]),
        const SizedBox(height: 16),
        
        if (selectedEngine == 'json') _buildCategoryCard('WEATHER OVERRIDES', Icons.thunderstorm, [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
                    _ColorNode('Rain Fog Tint', '', rainFogColor, (c) => rainFogColor = c),
                    _ColorNode('Rain Water Tint', '', rainWaterColor, (c) => rainWaterColor = c),
                ]),
                Positioned(
                  right: -8,
                  top: -8,
                  child: GestureDetector(
                    onTap: () => _showTooltip('Dynamic Weather Colors', 'Overrides the world colors during rain or storms.\n\n• Rain Fog Tint: Changes the atmospheric haze during rain (e.g., dark grey for storms).\n• Rain Water Tint: Changes the color of water during rain.'),
                    child: const Icon(Icons.help_outline, size: 16, color: Colors.white38),
                  )
                )
              ]
            ),
        ]),
        if (selectedEngine == 'json') const SizedBox(height: 16),

        _buildCategoryCard('LIGHTING & SHADOWS', Icons.lightbulb, [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
                    _ColorNode('God Rays Tint', '', rayColor, (c) => rayColor = c), 
                    _ColorNode('Fog Tint', '', fogColor, (c) => fogColor = c),
                    if (selectedEngine == 'json') _ColorNode('Torch Light', '', torchLightColor, (c) => torchLightColor = c)
                ]),
                Positioned(
                  right: -8,
                  top: -8,
                  child: GestureDetector(
                    onTap: () => _showTooltip('Global Lighting Tints', 'Controls the color of the world lighting.\\n\\n• God Rays: Changes the color of direct sunlight beams.\\n• Fog Tint: Changes the ambient color of the fog in the distance.\\n• Torch Light: Customizes the exact RGB color of Torches, Glowstone, and Lava.'),
                    child: const Icon(Icons.help_outline, size: 16, color: Colors.white38),
                  )
                )
              ]
            ),
            const SizedBox(height: 16),
            _sliderRow('Light Intensity', 'Multiplies the global directional light from the Sun and Moon. This affects how bright the surface of blocks appear when exposed directly to the sky.', lightIntensity, 0.0, 2.0, 20, lightIntensity == 1.0 ? '1.0x (Default)' : '${lightIntensity.toStringAsFixed(1)}x', (v) => lightIntensity = v),
            if (selectedEngine == 'json') _sliderRow('Block Light Intensity', 'Boosts the emissive strength and radius of all point lights. This allows a single torch to illuminate massive caves, completely changing the survival experience.', blockLightIntensity, 0.0, 2.0, 20, blockLightIntensity == 1.0 ? '1.0x (Default)' : '${blockLightIntensity.toStringAsFixed(1)}x', (v) => blockLightIntensity = v),
            _dropdownRow('Shadow Fidelity', 'Controls the resolution of the shadow maps cast by the Sun. Soft Shadows uses high-res 1024px maps with soft-edge filtering, while Hard Shadows creates sharp edges.', ['Off', 'Ultra-Low (128px)', 'Hard Shadows (256px)', 'Soft Shadows (1024px)'], shadowFidelity, (v) => shadowFidelity = v),
            if (selectedEngine == 'json') _switchRow('Point Light Shadows', 'Enables highly experimental real-time ray-traced shadows cast by Torches and Lava. This makes the game look incredible but can be heavy on mobile devices.', enablePointLightShadows, (v) => enablePointLightShadows = v),
        ]),
        const SizedBox(height: 16),
        
        _buildCategoryCard('WORLD & WATER', Icons.public, [
            Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [_ColorNode('Water Tint', 'Tints the surface color and depth scattering of all water in the world. (Does not affect rain-overridden water).', waterColor, (c) => waterColor = c)]),
            const SizedBox(height: 24),
            _sliderRow('Wind & Wave Speed', 'Modifies the internal shader time-multiplier for vertex animations. This makes oceans and lakes look like they have fast, aggressive currents or slow, calm ripples.', windSpeed, 0.0, 2.0, 20, windSpeed == 1.0 ? '1.0x (Default)' : '${windSpeed.toStringAsFixed(1)}x', (v) => windSpeed = v),
            _dropdownRow('Water Quality', 'Controls the noise complexity (octaves) of the water surface. Ultra calculates multiple layers of overlapping waves for a highly realistic, churning ocean.', ['Low', 'Medium', 'Ultra'], waterQuality, (v) => waterQuality = v),
            _switchRow('Underwater Caustics', 'Generates animated, waving light patterns on the floor of oceans and rivers when the sun shines through the water surface.', underwaterCaustics, (v) => underwaterCaustics = v),
            if (selectedEngine == 'json') _dropdownRow('World Reflections', 'Overrides the global PBR roughness of all blocks. Setting this to Ultra makes every block in the world behave like a mirror, reflecting the sky and clouds.', ['Off (Matte)', 'Low (Glossy)', 'High (Wet)', 'Ultra (Mirror)'], worldReflections, (v) => worldReflections = v),
            if (selectedEngine == 'json') _sliderRow('Global Metalness', 'Overrides the global PBR metalness of all blocks. Increasing this makes blocks absorb light like conductive metals, giving everything a shiny, synthetic look.', globalMetalness, 0.0, 10.0, 10, globalMetalness == 0.0 ? '0.0 (Default)' : '${globalMetalness.toStringAsFixed(1)}', (v) => globalMetalness = v),
            if (selectedEngine == 'json') _switchRow('PBR Bump Mapping', 'Activates the Normal/MER texture mapping pipeline. If you have a PBR texture pack installed, this will give blocks true 3D depth and bumpy surfaces.', enablePBR, (v) => enablePBR = v),
            if (selectedEngine == 'bin') _dropdownRow('Cloud Type', 'Defines the shape of the clouds generated by the binary engine. Realistic 3D uses volumetric raymarching, while Box Clouds uses the classic Minecraft style.', ['Realistic 3D', 'Box Clouds', 'Disabled'], cloudType, (v) => cloudType = v),
            if (selectedEngine == 'bin') _switchRow('Waving Foliage', 'Injects a sine-wave vertex displacement shader into plant life, causing Leaves, Grass, and Vines to sway realistically in the wind.', wavingFoliage, (v) => wavingFoliage = v),
        ]),

      ],
    );
  }
  
  Widget _buildCategoryCard(String title, IconData icon, List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF181E19),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF385E2E).withOpacity(0.5)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          initiallyExpanded: true,
          iconColor: const Color(0xFF6DE846),
          collapsedIconColor: Colors.white54,
          title: Row(
            children: [
                Icon(icon, color: const Color(0xFF6DE846), size: 20),
                const SizedBox(width: 12),
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, letterSpacing: 1.2, color: Colors.white)),
            ],
          ),
          children: [
            Padding(
                padding: const EdgeInsets.only(left: 16, right: 16, bottom: 20, top: 8),
                child: Column(children: children),
            )
          ],
        ),
      ),
    );
  }

  Widget _sliderRow(String title, String tooltip, double val, double min, double max, int div, String label, Function(double) onChanged, {double defaultVal = 1.0}) {
    return Padding(
        padding: const EdgeInsets.only(top: 10, bottom: 20),
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
                Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                        Flexible(child: _buildTitleWithHelp(title, tooltip)),
                        const SizedBox(width: 8),
                        Text(label, style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF6DE846), fontSize: 13)),
                    ]
                ),
                const SizedBox(height: 8),
                Column(
                    children: [
                        SliderTheme(
                            data: SliderTheme.of(context).copyWith(
                                trackHeight: 6.0,
                            ),
                            child: Slider(
                                value: val, min: min, max: max, divisions: div,
                                activeColor: const Color(0xFF6DE846),
                                inactiveColor: const Color(0xFF385E2E).withOpacity(0.5),
                                onChanged: (v) => setState(() => onChanged(v)),
                            )
                        ),
                        Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 14),
                            child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                    const Text('Min (0.0x)', style: TextStyle(color: Colors.white38, fontSize: 10, fontWeight: FontWeight.bold)),
                                    const Text('Default (1.0x)', style: TextStyle(color: Color(0xFF6DE846), fontSize: 10, fontWeight: FontWeight.bold)),
                                    const Text('Max (2.0x)', style: TextStyle(color: Colors.white38, fontSize: 10, fontWeight: FontWeight.bold)),
                                ]
                            )
                        )
                    ]
                )
            ]
        )
    );
  }

  Widget _dropdownRow(String title, String tooltip, List<String> items, String val, Function(String) onChanged) {
    return Padding(
        padding: const EdgeInsets.only(top: 10, bottom: 20),
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
                _buildTitleWithHelp(title, tooltip),
                const SizedBox(height: 12),
                Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: items.map((e) {
                        bool isSelected = e == val;
                        return GestureDetector(
                            onTap: () => setState(() => onChanged(e)),
                            child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                decoration: BoxDecoration(
                                    color: isSelected ? const Color(0xFF6DE846) : const Color(0xFF222B22),
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(color: isSelected ? const Color(0xFF6DE846) : const Color(0xFF385E2E)),
                                ),
                                child: Text(e, style: TextStyle(
                                    color: isSelected ? Colors.black : Colors.white70,
                                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                    fontSize: 11.5
                                )),
                            ),
                        );
                    }).toList(),
                )
            ]
        )
    );
  }

  Widget _switchRow(String title, String tooltip, bool val, Function(bool) onChanged) {
    return Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Row(
            children: [
                SizedBox(
                    width: 140,
                    child: _buildTitleWithHelp(title, tooltip)
                ),
                Expanded(
                    child: Align(
                        alignment: Alignment.centerRight,
                        child: Switch(
                            value: val,
                            activeColor: const Color(0xFF111312),
                            activeTrackColor: const Color(0xFF6DE846),
                            inactiveThumbColor: Colors.white54,
                            inactiveTrackColor: const Color(0xFF385E2E),
                            onChanged: (v) => setState(() => onChanged(v))
                        )
                    )
                )
            ]
        )
    );
  }
  Widget _buildCloudWarning() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.red.withOpacity(0.1),
        border: Border.all(color: Colors.red.withOpacity(0.3)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Row(
        children: [
          Icon(Icons.cloud_off, color: Colors.red),
          SizedBox(width: 12),
          Expanded(child: Text('Cloud compilation is required for the Classic Engine.', style: TextStyle(color: Colors.redAccent))),
        ],
      ),
    );
  }

  Widget _ColorNode(String label, String tooltip, Color color, Function(Color) onChanged) {
    return GestureDetector(
      onTap: () => _pickColor(context, label, color, onChanged),
      child: Column(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.white, width: 2), // Stronger border
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(0.4),
                  blurRadius: 8,
                  spreadRadius: 1,
                )
              ]
            ),
          ),
          const SizedBox(height: 8),
          _buildTitleWithHelp(label, tooltip),
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
          backgroundColor: const Color(0xFF181E19),
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
                    valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF6DE846)),
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
          'globalSaturation': globalSaturation.toString(),
          'toneMapFilter': toneMapFilter,
          'nightVision': nightVision.toString(),
          'underwaterCaustics': underwaterCaustics.toString(),
          'windSpeed': windSpeed.toString(),
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
        
        statusNotifier.value = "Preparing Shader Pack...";
        progressNotifier.value = 1.0;
        
        final packBytes = response.data is List<int> ? (response.data as List<int>) : List<int>.from(response.data);
        setState(() {
          _generatedPackBytes = packBytes;
          _generatedPackName = "$packName.mcpack";
          _isGenerated = true;
        });
        
        await Future.delayed(const Duration(milliseconds: 500));
        if (mounted) Navigator.pop(context);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('✨ $packName generated! Tap "Open with Minecraft" or Download.'),
              backgroundColor: const Color(0xFF385E2E),
              behavior: SnackBarBehavior.floating,
            ),
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
            manifest['header']['description'] = "Created with Piglix Shader Studio";
            
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
              if (waterQuality == 'Low') waves['octaves'] = 3;
              else if (waterQuality == 'Medium') waves['octaves'] = 8;
              else if (waterQuality == 'Ultra') waves['octaves'] = 14;
              
              if (waves['speed'] != null) waves['speed'] = (waves['speed'] as num).toDouble() * windSpeed;
            }
            
            var caustics = jsonMap['minecraft:water_settings']?['caustics'];
            if (caustics != null) caustics['enabled'] = underwaterCaustics;
            
            fileData = utf8.encode(jsonEncode(jsonMap));
          }
          
          if (!enablePBR && file.name.endsWith('.json')) {
            String content = utf8.decode(fileData);
            content = content.replaceAll(RegExp(r'"bump_mapping"\s*:\s*true'), '"bump_mapping": false');
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
          
          if (file.name.startsWith('lighting/') && file.name.endsWith('.json')) {
            String content = utf8.decode(fileData);
            Map<String, dynamic> jsonMap;
            try {
              jsonMap = jsonDecode(content);
            } catch (e) {
              print('JSON ERROR IN ${file.name}: $e');
              continue;
            }
            List<int> toRgb(Color c) => [c.red, c.green, c.blue];
            
            var lights = jsonMap['minecraft:lighting_settings']?['directional_lights'];
            if (lights != null) {
            var point = jsonMap['minecraft:lighting_settings']?['point_lights'];
            if (point != null) {
               point['colors'] = {
                 "default": [
                   (torchLightColor.red / 255.0) * blockLightIntensity,
                   (torchLightColor.green / 255.0) * blockLightIntensity,
                   (torchLightColor.blue / 255.0) * blockLightIntensity
                 ]
               };
            }

                var sun = lights['sun'] ?? lights['orbital']?['sun'];
                if (sun != null) {
                    var sunColor = sun['color'];
                    if (sunColor is Map) {
                        for (var key in sunColor.keys.toList()) sunColor[key] = toRgb(rayColor);
                    }
                    var sunIllum = sun['illuminance'];
                    if (sunIllum is Map) {
                        for (var key in sunIllum.keys.toList()) {
                            sunIllum[key] = (sunIllum[key] as num).toDouble() * lightIntensity;
                        }
                    }
                }
                var moon = lights['moon'] ?? lights['orbital']?['moon'];
                if (moon != null) {
                    var moonIllum = moon['illuminance'];
                    if (moonIllum is Map) {
                        for (var key in moonIllum.keys.toList()) {
                            moonIllum[key] = (moonIllum[key] as num).toDouble() * nightVision;
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
              blocks['global_metalness_emissive_roughness_subsurface'] = [(globalMetalness * 255).toInt(), 0, roughness, 0];
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
            String hexStr(Color c) => '#${c.value.toRadixString(16).substring(2).toUpperCase()}';
            var dist = jsonMap['minecraft:fog_settings']?['distance'];
            if (dist != null) {
                if (dist['air'] != null) dist['air']['fog_color'] = hexStr(fogColor);
                if (dist['water'] != null) dist['water']['fog_color'] = hexStr(waterColor);
                
                dist['weather_instances'] = [
                  { "weather": "rain", "fog_color": hexStr(rainFogColor), "fog_start": 0.0, "fog_end": 1.0 },
                  { "weather": "thunder", "fog_color": hexStr(rainFogColor), "fog_start": 0.0, "fog_end": 1.0 }
                ];
                
                if (dist['air'] != null && dist['air']['fog_start'] != null) {
                    dist['air']['fog_start'] = (dist['air']['fog_start'] as num).toDouble() / fogDensity;
                }
                if (dist['air'] != null && dist['air']['fog_end'] != null) {
                    dist['air']['fog_end'] = (dist['air']['fog_end'] as num).toDouble() / fogDensity;
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
                            vol['density']['air']['max_density'] = dens.toDouble() * fogDensity;
                        }
                    }
                }
                if (vol['media_coefficients'] != null && vol['media_coefficients']['air'] != null) {
                    double mult = 0.25;
                    if (volumetricRays == 'Balanced') mult = 0.15;
                    if (volumetricRays == 'Low End') mult = 0.05;
                    vol['media_coefficients']['air']['scattering'] = [rayColor.red / 255.0 * mult, rayColor.green / 255.0 * mult, rayColor.blue / 255.0 * mult];
                }
            }
            
            fileData = utf8.encode(jsonEncode(jsonMap));
          }
          
          if (file.name.startsWith('atmospherics/') && file.name.endsWith('.json')) {
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
          
          if (file.name.startsWith('color_grading/') && file.name.endsWith('.json')) {
            String content = utf8.decode(fileData);
            Map<String, dynamic> jsonMap;
            try {
              jsonMap = jsonDecode(content);
            } catch (e) {
              print('JSON ERROR IN ${file.name}: $e');
              continue;
            }
            var grading = jsonMap['minecraft:color_grading_settings']?['color_grading'];
            if (grading != null) {
                var sat = [1.04 * globalSaturation, 1.04 * globalSaturation, 1.04 * globalSaturation];
                if (grading['highlights'] != null) grading['highlights']['saturation'] = sat;
                if (grading['midtones'] != null) grading['midtones']['saturation'] = sat;
                if (grading['shadows'] != null) grading['shadows']['saturation'] = sat;
                
                List<double> highGain = [1.2, 1.2, 1.2];
                if (toneMapFilter.contains('Vintage')) highGain = [1.5, 1.3, 0.9];
                if (toneMapFilter.contains('Cool')) highGain = [0.9, 1.1, 1.5];
                if (grading['highlights'] != null) grading['highlights']['gain'] = highGain;
            }
            
            var tm = jsonMap['minecraft:color_grading_settings']?['tone_mapping'];
            if (tm != null) {
                if (toneMapFilter.contains('Reinhard')) tm['operator'] = 'reinhard';
                else tm['operator'] = 'aces';
                tm['contrast'] = contrast;
                tm['auto_exposure_max'] = autoExposure * 2.0;
            }
            
            var cg = jsonMap['minecraft:color_grading_settings'];
            if (cg != null && cg['color_grading'] != null) {
               if (cg['color_grading']['midtones'] != null) cg['color_grading']['midtones']['contrast'] = [contrast, contrast, contrast];
            }
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
            content: Text('✨ $pName generated! Tap "Open with Minecraft" or Download.'),
            backgroundColor: const Color(0xFF385E2E),
            behavior: SnackBarBehavior.floating,
          ),
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
          color: isSelected ? Colors.white.withOpacity(0.05) : const Color(0xFF181E19),
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
