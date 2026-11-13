import 'package:flutter/material.dart';
import 'minecraft_icons.dart';
import 'vv_tab_previews.dart';

/// Official Screenshot Asset Registry.
/// Drop your official Minecraft screenshots in `assets/screenshots/` and point
/// these paths to them. When null, authentic Minecraft UI pixelated mockups
/// render automatically.
class OfficialGuideScreenshots {
  static String? step1Import;
  static String? step2GlobalResources;
  static String? step3VideoSettings;
  static String? step4InGameWorld;
}

/// Helper to display the unified Minecraft In-Game Guide Modal from ANY `?` button in the app.
Future<void> showMinecraftGuideModal(
  BuildContext context, {
  int initialTab = 0,
  int initialStep = 0,
  String? parameterTitle,
  String? parameterTooltip,
}) {
  return showDialog<void>(
    context: context,
    barrierColor: Colors.black.withValues(alpha: 0.75),
    builder: (ctx) => VVMinecraftGuideModal(
      initialTab: initialTab,
      initialStep: initialStep,
      parameterTitle: parameterTitle,
      parameterTooltip: parameterTooltip,
    ),
  );
}

/// Unified, Modern, Pixelated Minecraft In-Game Activation & Help Guide
class VVMinecraftGuideModal extends StatefulWidget {
  final int initialTab;
  final int initialStep;
  final String? parameterTitle;
  final String? parameterTooltip;

  const VVMinecraftGuideModal({
    super.key,
    this.initialTab = 0,
    this.initialStep = 0,
    this.parameterTitle,
    this.parameterTooltip,
  });

  @override
  State<VVMinecraftGuideModal> createState() => _VVMinecraftGuideModalState();
}

class _VVMinecraftGuideModalState extends State<VVMinecraftGuideModal> {
  late int _activeTab; // 0 = Step Flow, 1 = Screenshots, 2 = In-Game Settings, 3 = Shader Controls
  late int _currentStep; // 0..3

  @override
  void initState() {
    super.initState();
    _activeTab = widget.initialTab;
    _currentStep = widget.initialStep.clamp(0, 3);
  }

  static const Color _bgModal = Color(0xFF0C131D);
  static const Color _bgCard = Color(0xFF131D2A);
  static const Color _borderColor = Color(0xFF1E293B);
  static const Color _kEmerald = Color(0xFF22C55E);
  static const Color _kCyan = Color(0xFF38BDF8);
  static const Color _kGold = Color(0xFFF59E0B);
  static const Color _kPurple = Color(0xFFA855F7);

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    final isCompact = media.size.width < 380;

    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      insetPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 18),
      child: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: 520,
            maxHeight: media.size.height * 0.88,
          ),
          child: VVPixelBox(
            fillColor: _bgModal,
            borderColor: _borderColor,
            borderWidth: 2.0,
            step: 3.5,
            hasShadow: true,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // 1. Pixelated Minecraft Header
                _buildModalHeader(context, isCompact),

                // Parameter quick-reference alert if opened from a specific slider
                if (widget.parameterTitle != null)
                  _buildParameterAlertCard(isCompact),

                // 2. Pixelated Stepped Tab Bar
                _buildPixelTabBar(isCompact),

                // 3. Tab Body
                Flexible(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
                    child: switch (_activeTab) {
                      1 => _buildScreenshotsGalleryTab(),
                      2 => _buildInGameSettingsTab(),
                      3 => _buildShaderControlsGuideTab(),
                      _ => _buildStepFlowTab(),
                    },
                  ),
                ),

                // 4. Modal Footer with Pixelated Action Buttons
                _buildModalFooter(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ─── 1. MODAL HEADER ────────────────────────────────────────────────────────
  Widget _buildModalHeader(BuildContext context, bool isCompact) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 14, 12, 12),
      decoration: const BoxDecoration(
        color: Color(0xFF111A24),
        border: Border(bottom: BorderSide(color: _borderColor, width: 1.5)),
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: _kEmerald.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: _kEmerald, width: 1.2),
            ),
            alignment: Alignment.center,
            child: const AnimatedMinecraftIcon(
              type: VoxelIconType.grassBlock,
              size: 20,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'MINECRAFT ACTIVATION GUIDE',
                  style: TextStyle(
                    color: Colors.white,
                    fontFamily: 'PixelifySans',
                    fontSize: 14.5,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.6,
                  ),
                ),
                Text(
                  'Official Bedrock Vibrant Visuals Workflow',
                  style: TextStyle(
                    color: _kCyan.withValues(alpha: 0.9),
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          // Close button
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.close_rounded, color: Colors.white60, size: 20),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
            splashRadius: 18,
          ),
        ],
      ),
    );
  }

  // ─── PARAMETER QUICK-REFERENCE CARD ─────────────────────────────────────────
  Widget _buildParameterAlertCard(bool isCompact) {
    return Container(
      margin: const EdgeInsets.fromLTRB(14, 10, 14, 2),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: _kCyan.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: _kCyan.withValues(alpha: 0.4)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.info_outline_rounded, size: 16, color: _kCyan),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.parameterTitle!,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                if (widget.parameterTooltip != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    widget.parameterTooltip!,
                    style: const TextStyle(
                      color: Color(0xFF94A3B8),
                      fontSize: 11,
                      height: 1.3,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─── 2. PIXELATED TAB BAR ───────────────────────────────────────────────────
  Widget _buildPixelTabBar(bool isCompact) {
    final tabs = [
      (label: 'FLOW', icon: Icons.linear_scale_rounded),
      (label: 'SCREENSHOTS', icon: Icons.photo_library_outlined),
      (label: 'SETTINGS', icon: Icons.tune_rounded),
      (label: 'CONTROLS', icon: Icons.help_outline_rounded),
    ];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: _borderColor)),
      ),
      child: Row(
        children: [
          for (int i = 0; i < tabs.length; i++) ...[
            if (i > 0) const SizedBox(width: 6),
            Expanded(
              child: GestureDetector(
                onTap: () => setState(() => _activeTab = i),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  decoration: BoxDecoration(
                    color: _activeTab == i
                        ? _kEmerald.withValues(alpha: 0.16)
                        : const Color(0xFF131D2A),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: _activeTab == i ? _kEmerald : _borderColor,
                      width: 1.2,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      tabs[i].label,
                      style: TextStyle(
                        fontFamily: 'PixelifySans',
                        fontSize: isCompact ? 10.5 : 11.5,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.5,
                        color: _activeTab == i ? _kEmerald : Colors.white60,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ─── TAB 1: STEP-BY-STEP FLOW ───────────────────────────────────────────────
  Widget _buildStepFlowTab() {
    final steps = [
      (
        stepNum: '01',
        title: 'Export & Import .mcpack',
        color: _kEmerald,
        icon: VoxelIconType.chest,
        pathTag: 'Piglix > Generate .mcpack > Open with Minecraft',
        desc:
            'Generate your shader package in Piglix and send it to Minecraft Bedrock with one tap.',
        bullets: [
          'Go to the Export tab (Tab 8) and tap "GENERATE .MCPACK".',
          'Select "Open with Minecraft" in your device share sheet.',
          'Minecraft will launch with an "Import Started..." notification.',
        ],
        mockupType: _MockupType.importToast,
        screenshotAsset: OfficialGuideScreenshots.step1Import,
      ),
      (
        stepNum: '02',
        title: 'Activate in Global Resources',
        color: _kCyan,
        icon: VoxelIconType.gear,
        pathTag: 'Minecraft > Settings > Global Resources > Active (Top)',
        desc:
            'Load your shader pack at the top of Active packs and choose your subpack tier.',
        bullets: [
          'In Minecraft, open Settings -> Global Resources -> MY PACKS.',
          'Tap your pack and press "ACTIVATE".',
          'In the ACTIVE section, move your shader pack to the VERY TOP.',
          'Tap the gear icon on the pack to pick your tier: Lite, Medium, High, or Ultra.',
        ],
        mockupType: _MockupType.globalResources,
        screenshotAsset: OfficialGuideScreenshots.step2GlobalResources,
      ),
      (
        stepNum: '03',
        title: 'Enable Vibrant Visuals Mode',
        color: _kGold,
        icon: VoxelIconType.diamond,
        pathTag: 'Settings > Video > Graphics Mode > Vibrant Visuals',
        desc:
            'Switch the Minecraft graphics engine to Deferred Technical Preview ("Vibrant Visuals").',
        bullets: [
          'In Minecraft Settings, go down to "Video".',
          'Under Graphics Mode, choose "Vibrant Visuals".',
          'Set Brightness / Gamma to 50% for optimal balanced lighting.',
          'Enable "Bloom: ON" and set "Upscaling: TAAU" for sharp, crisp visuals.',
        ],
        mockupType: _MockupType.videoSettings,
        screenshotAsset: OfficialGuideScreenshots.step3VideoSettings,
      ),
      (
        stepNum: '04',
        title: 'Launch World & Verify Shaders',
        color: _kPurple,
        icon: VoxelIconType.sparkles,
        pathTag: 'Play > World Settings > Experiments > Render Dragon Features',
        desc:
            'Hop into your world to see dynamic sunlight, wave reflections, and volumetric mist!',
        bullets: [
          'If creating an experimental world, ensure "Render Dragon Features for Creators" is ON.',
          'Enter the world — look at the directional sun glow, water caustics, and soft shadows!',
          'If shadows look dark, check that Brightness is set to 50% in Video settings.',
        ],
        mockupType: _MockupType.inGameWorld,
        screenshotAsset: OfficialGuideScreenshots.step4InGameWorld,
      ),
    ];

    final current = steps[_currentStep];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Stepper pills selector
        Row(
          children: [
            for (int i = 0; i < steps.length; i++) ...[
              if (i > 0)
                Expanded(
                  child: Container(
                    height: 2,
                    color: i <= _currentStep ? _kEmerald : _borderColor,
                  ),
                ),
              GestureDetector(
                onTap: () => setState(() => _currentStep = i),
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: _currentStep == i
                        ? steps[i].color
                        : (_currentStep > i
                            ? _kEmerald.withValues(alpha: 0.25)
                            : _bgCard),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: _currentStep == i ? Colors.white : _borderColor,
                      width: _currentStep == i ? 1.8 : 1.2,
                    ),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    steps[i].stepNum,
                    style: TextStyle(
                      fontFamily: 'PixelifySans',
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: _currentStep == i
                          ? Colors.black
                          : (_currentStep > i ? _kEmerald : Colors.white60),
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 16),

        // Step Card
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: _bgCard,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: current.color.withValues(alpha: 0.5), width: 1.4),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Step header
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                    decoration: BoxDecoration(
                      color: current.color,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      'STEP ${current.stepNum}',
                      style: const TextStyle(
                        fontFamily: 'PixelifySans',
                        fontSize: 10.5,
                        fontWeight: FontWeight.w800,
                        color: Colors.black,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      current.title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13.5,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  AnimatedMinecraftIcon(type: current.icon, size: 20),
                ],
              ),
              const SizedBox(height: 10),

              // Breadcrumb path tag
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.45),
                  borderRadius: BorderRadius.circular(5),
                  border: Border.all(color: _borderColor),
                ),
                child: Row(
                  children: [
                    Icon(Icons.folder_open_rounded, size: 13, color: current.color),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        current.pathTag,
                        style: TextStyle(
                          color: current.color,
                          fontSize: 10.5,
                          fontFamily: 'PixelifySans',
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),

              Text(
                current.desc,
                style: const TextStyle(
                  color: Color(0xFF94A3B8),
                  fontSize: 12,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 12),

              // Screenshot / Mockup Preview Container
              _buildOfficialScreenshotContainer(
                title: current.title,
                mockupType: current.mockupType,
                color: current.color,
                assetPath: current.screenshotAsset,
              ),
              const SizedBox(height: 12),

              // Step bullet points
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  for (final bullet in current.bullets) ...[
                    Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(Icons.check_circle_rounded, size: 14, color: current.color),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              bullet,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 11.5,
                                height: 1.35,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ─── TAB 2: OFFICIAL SCREENSHOTS GALLERY ────────────────────────────────────
  Widget _buildScreenshotsGalleryTab() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.add_photo_alternate_outlined, size: 16, color: _kEmerald),
            const SizedBox(width: 6),
            const Text(
              'OFFICIAL MINECRAFT SCREENSHOT SLOTS',
              style: TextStyle(
                fontFamily: 'PixelifySans',
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: _kEmerald,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        const Text(
          'Each step contains an official screenshot slot. You can drop in real in-game screenshots by setting OfficialGuideScreenshots paths, or view the built-in Minecraft UI previews below:',
          style: TextStyle(
            color: Color(0xFF94A3B8),
            fontSize: 11.5,
            height: 1.4,
          ),
        ),
        const SizedBox(height: 14),

        _buildGalleryItem(
          step: '01',
          title: 'Import Toast Notification',
          desc: 'Shows Minecraft importing the .mcpack file after tapping Open with Minecraft.',
          mockupType: _MockupType.importToast,
          color: _kEmerald,
          assetPath: OfficialGuideScreenshots.step1Import,
        ),
        const SizedBox(height: 12),
        _buildGalleryItem(
          step: '02',
          title: 'Global Resources Pack & Gear Tier',
          desc: 'Shows the shader pack placed at the top of Active packs with resolution subpacks.',
          mockupType: _MockupType.globalResources,
          color: _kCyan,
          assetPath: OfficialGuideScreenshots.step2GlobalResources,
        ),
        const SizedBox(height: 12),
        _buildGalleryItem(
          step: '03',
          title: 'Video Settings · Vibrant Visuals',
          desc: 'Shows Graphics Mode set to Vibrant Visuals with Bloom ON and Gamma 50%.',
          mockupType: _MockupType.videoSettings,
          color: _kGold,
          assetPath: OfficialGuideScreenshots.step3VideoSettings,
        ),
        const SizedBox(height: 12),
        _buildGalleryItem(
          step: '04',
          title: 'In-Game World Rendering',
          desc: 'Shows dynamic directional sunlight, realistic water ripples, and fog in action.',
          mockupType: _MockupType.inGameWorld,
          color: _kPurple,
          assetPath: OfficialGuideScreenshots.step4InGameWorld,
        ),
      ],
    );
  }

  Widget _buildGalleryItem({
    required String step,
    required String title,
    required String desc,
    required _MockupType mockupType,
    required Color color,
    String? assetPath,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _bgCard,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: _borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  'STEP $step',
                  style: const TextStyle(
                    fontFamily: 'PixelifySans',
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    color: Colors.black,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            desc,
            style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 11),
          ),
          const SizedBox(height: 10),
          _buildOfficialScreenshotContainer(
            title: title,
            mockupType: mockupType,
            color: color,
            assetPath: assetPath,
          ),
        ],
      ),
    );
  }

  // ─── TAB 3: RECOMMENDED IN-GAME SETTINGS ────────────────────────────────────
  Widget _buildInGameSettingsTab() {
    final settings = [
      (
        category: 'GRAPHICS MODE',
        setting: 'Video -> Graphics Mode',
        value: 'Vibrant Visuals',
        why: 'Enables official Deferred Technical Preview PBR pipeline.',
        icon: Icons.auto_awesome_rounded,
        color: _kEmerald,
      ),
      (
        category: 'BRIGHTNESS',
        setting: 'Brightness / Gamma',
        value: '50% (Default)',
        why: 'Values above 70% cause overexposed daylight and washed-out shadows.',
        icon: Icons.brightness_6_rounded,
        color: _kGold,
      ),
      (
        category: 'POST-PROCESSING',
        setting: 'Bloom & Reflections',
        value: 'ON · Matches Subpack',
        why: 'Enables realistic emissive glows and glossy water specular hits.',
        icon: Icons.lens_blur_rounded,
        color: _kCyan,
      ),
      (
        category: 'RESOLUTION SCALING',
        setting: 'Upscaling Quality',
        value: 'TAAU (Recommended)',
        why: 'Temporal Anti-Aliasing gives razor sharp geometry without jagged edges.',
        icon: Icons.hd_rounded,
        color: _kPurple,
      ),
      (
        category: 'EXPERIMENTS',
        setting: 'World Experiments',
        value: 'Render Dragon Features: ON',
        why: 'Required for custom biomes and local point-light blocks.',
        icon: Icons.science_outlined,
        color: const Color(0xFFF43F5E),
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.tune_rounded, size: 16, color: _kCyan),
            const SizedBox(width: 6),
            const Text(
              'RECOMMENDED IN-GAME CONFIGURATION',
              style: TextStyle(
                fontFamily: 'PixelifySans',
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: _kCyan,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        const Text(
          'For the best visual fidelity and stable framerates, apply these exact settings in Minecraft:',
          style: TextStyle(
            color: Color(0xFF94A3B8),
            fontSize: 11.5,
            height: 1.4,
          ),
        ),
        const SizedBox(height: 12),

        for (final s in settings) ...[
          Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.all(11),
            decoration: BoxDecoration(
              color: _bgCard,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: _borderColor),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: s.color.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: s.color.withValues(alpha: 0.6)),
                  ),
                  alignment: Alignment.center,
                  child: Icon(s.icon, size: 15, color: s.color),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              s.setting,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: s.color.withValues(alpha: 0.18),
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(color: s.color, width: 0.8),
                            ),
                            child: Text(
                              s.value,
                              style: TextStyle(
                                color: s.color,
                                fontFamily: 'PixelifySans',
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        s.why,
                        style: const TextStyle(
                          color: Color(0xFF94A3B8),
                          fontSize: 11,
                          height: 1.3,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  // ─── TAB 4: SHADER CONTROLS GUIDE ───────────────────────────────────────────
  Widget _buildShaderControlsGuideTab() {
    final sections = [
      (
        tab: 'TAB 0: SKY & ATMOSPHERE',
        color: _kCyan,
        icon: VoxelIconType.sun,
        items: [
          ('Sun / Moon Position', 'Sets orbital sunrise/sunset direction and noon elevation.'),
          ('Horizon Haze', 'Controls atmospheric light scattering gradient where sky meets ground.'),
          ('Rayleigh / Mie Scattering', 'Simulates realistic physical sun halo glow and dusk/dawn redness.'),
        ],
      ),
      (
        tab: 'TAB 1: LIGHTING & CAVES',
        color: _kGold,
        icon: VoxelIconType.torch,
        items: [
          ('Sunlight / Ambient', 'Directional illumination on blocks and shadows under trees.'),
          ('Cave Ambient', 'Ambient visibility in pitch black underground caverns.'),
          ('Block Lights', 'Point-light emission colors for Torches, Lanterns, and Glowstone.'),
        ],
      ),
      (
        tab: 'TAB 2: FOG & MIST',
        color: _kEmerald,
        icon: VoxelIconType.rainCloud,
        items: [
          ('Air Fog Start / End', 'Distance where distance mist begins and turns 100% opaque.'),
          ('Ground Mist Density', 'Pools thick volumetric mist billows in canyon basins.'),
          ('Weather Fog', 'Simulates heavy storm downpours and low-hanging rain curtains.'),
        ],
      ),
      (
        tab: 'TAB 3: WATER & CAUSTICS',
        color: _kCyan,
        icon: VoxelIconType.caustics,
        items: [
          ('Water Clarity (CDOM)', 'Balances crystal clear water vs murky marsh water.'),
          ('Caustics Shimmer', 'Animated sunlight prismatic web reflections on seabed blocks.'),
          ('Wave Height / Speed', 'Simulates gentle ocean swells or lively river rapids.'),
        ],
      ),
      (
        tab: 'TAB 4: COLOR GRADING',
        color: _kPurple,
        icon: VoxelIconType.palette,
        items: [
          ('Tone Mapping Operator', 'Reinhard, ACES, or Neutral filmic color response.'),
          ('Temperature / Gain', 'Warm sunset golden hour vs crisp cool morning sky.'),
        ],
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.help_outline_rounded, size: 16, color: _kEmerald),
            const SizedBox(width: 6),
            const Text(
              'WHAT EACH SHADER SLIDER CONTROLS',
              style: TextStyle(
                fontFamily: 'PixelifySans',
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: _kEmerald,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        const Text(
          'Quick reference for all Piglix Shader Builder controls and their official JSON outputs:',
          style: TextStyle(
            color: Color(0xFF94A3B8),
            fontSize: 11.5,
          ),
        ),
        const SizedBox(height: 12),

        for (final sec in sections) ...[
          Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: _bgCard,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: _borderColor),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    AnimatedMinecraftIcon(type: sec.icon, size: 16),
                    const SizedBox(width: 8),
                    Text(
                      sec.tab,
                      style: TextStyle(
                        fontFamily: 'PixelifySans',
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: sec.color,
                        letterSpacing: 0.4,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                for (final item in sec.items) ...[
                  Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('• ', style: TextStyle(color: sec.color, fontWeight: FontWeight.bold)),
                        Text(
                          '${item.$1}: ',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11.5,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Expanded(
                          child: Text(
                            item.$2,
                            style: const TextStyle(
                              color: Color(0xFF94A3B8),
                              fontSize: 11.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ],
    );
  }

  // ─── OFFICIAL SCREENSHOT & MOCKUP CONTAINER ─────────────────────────────────
  Widget _buildOfficialScreenshotContainer({
    required String title,
    required _MockupType mockupType,
    required Color color,
    String? assetPath,
  }) {
    return Container(
      width: double.infinity,
      height: 140,
      decoration: BoxDecoration(
        color: const Color(0xFF090D14),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.4), width: 1.2),
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          // If asset path exists, show image with error fallback to mockup
          if (assetPath != null && assetPath.isNotEmpty)
            Positioned.fill(
              child: Image.asset(
                assetPath,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) =>
                    _buildPixelatedMockup(mockupType, color),
              ),
            )
          else
            // High-fidelity authentic Minecraft UI Mockup
            Positioned.fill(
              child: _buildPixelatedMockup(mockupType, color),
            ),

          // Screenshot slot status badge on top-right
          Positioned(
            top: 6,
            right: 6,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2.5),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.75),
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: color.withValues(alpha: 0.6)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    assetPath != null ? Icons.check_circle_rounded : Icons.photo_camera_outlined,
                    size: 11,
                    color: color,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    assetPath != null ? 'OFFICIAL SCREENSHOT' : 'MINECRAFT UI PREVIEW',
                    style: TextStyle(
                      fontFamily: 'PixelifySans',
                      fontSize: 8.5,
                      fontWeight: FontWeight.w700,
                      color: color,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─── AUTHENTIC MINECRAFT UI MOCKUPS ─────────────────────────────────────────
  Widget _buildPixelatedMockup(_MockupType type, Color accent) {
    return switch (type) {
      _MockupType.importToast => _mockupImportToast(accent),
      _MockupType.globalResources => _mockupGlobalResources(accent),
      _MockupType.videoSettings => _mockupVideoSettings(accent),
      _MockupType.inGameWorld => _mockupInGameWorld(accent),
    };
  }

  Widget _mockupImportToast(Color accent) {
    return Container(
      color: const Color(0xFF18181B),
      padding: const EdgeInsets.all(12),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Minecraft Title Top Bar Mockup
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
            decoration: BoxDecoration(
              color: const Color(0xFF27272A),
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: const Color(0xFF3F3F46)),
            ),
            child: Row(
              children: [
                const AnimatedMinecraftIcon(type: VoxelIconType.grassBlock, size: 16),
                const SizedBox(width: 8),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Import Started...',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        'Successfully imported "Piglix Shader Pack.mcpack"',
                        style: TextStyle(
                          color: Color(0xFF4ADE80),
                          fontSize: 9.5,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.check_circle_rounded, size: 16, color: accent),
              ],
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            'Minecraft Notification Toast',
            style: TextStyle(color: Colors.white38, fontSize: 9.5, fontFamily: 'PixelifySans'),
          ),
        ],
      ),
    );
  }

  Widget _mockupGlobalResources(Color accent) {
    return Container(
      color: const Color(0xFF141923),
      padding: const EdgeInsets.all(10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text(
                'GLOBAL RESOURCES',
                style: TextStyle(
                  fontFamily: 'PixelifySans',
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: Colors.white70,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(3),
                ),
                child: Text(
                  'ACTIVE (1)',
                  style: TextStyle(
                    fontFamily: 'PixelifySans',
                    fontSize: 8.5,
                    color: accent,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          // Active Pack Card with Gear
          Container(
            padding: const EdgeInsets.all(7),
            decoration: BoxDecoration(
              color: const Color(0xFF1F2937),
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: accent, width: 1.2),
            ),
            child: Row(
              children: [
                const AnimatedMinecraftIcon(type: VoxelIconType.chest, size: 16),
                const SizedBox(width: 6),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Piglix Vibrant Visuals Pack',
                        style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        'Subpack: High (1024x Shadows + Caustics)',
                        style: TextStyle(color: Colors.white60, fontSize: 8.5),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.black45,
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: Colors.white30),
                  ),
                  child: const Icon(Icons.settings, size: 12, color: Colors.white),
                ),
              ],
            ),
          ),
          const SizedBox(height: 6),
          // Subpack Slider Mockup
          Row(
            children: [
              const Text('Resolution:', style: TextStyle(color: Colors.white38, fontSize: 8.5)),
              const SizedBox(width: 6),
              Expanded(
                child: Container(
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(2),
                  ),
                  child: FractionallySizedBox(
                    alignment: Alignment.centerLeft,
                    widthFactor: 0.75,
                    child: Container(
                      decoration: BoxDecoration(
                        color: accent,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 6),
              Text(
                'HIGH',
                style: TextStyle(
                  fontFamily: 'PixelifySans',
                  fontSize: 9,
                  color: accent,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _mockupVideoSettings(Color accent) {
    return Container(
      color: const Color(0xFF141A22),
      padding: const EdgeInsets.all(10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'VIDEO SETTINGS',
            style: TextStyle(
              fontFamily: 'PixelifySans',
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: Colors.white70,
            ),
          ),
          const SizedBox(height: 8),
          _mockupSettingRow('Graphics Mode:', 'Vibrant Visuals', accent, isHighlight: true),
          const SizedBox(height: 5),
          _mockupSettingRow('Brightness:', '50%', Colors.white70),
          const SizedBox(height: 5),
          _mockupSettingRow('Bloom:', 'ON', const Color(0xFF22C55E)),
          const SizedBox(height: 5),
          _mockupSettingRow('Upscaling:', 'TAAU', const Color(0xFF38BDF8)),
        ],
      ),
    );
  }

  Widget _mockupSettingRow(String label, String value, Color col, {bool isHighlight = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3.5),
      decoration: BoxDecoration(
        color: isHighlight ? col.withValues(alpha: 0.15) : const Color(0xFF1E2632),
        borderRadius: BorderRadius.circular(3),
        border: Border.all(color: isHighlight ? col : const Color(0xFF2D3748)),
      ),
      child: Row(
        children: [
          Text(label, style: const TextStyle(color: Colors.white70, fontSize: 9.5)),
          const Spacer(),
          Text(
            value,
            style: TextStyle(
              color: col,
              fontFamily: 'PixelifySans',
              fontSize: 9.5,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _mockupInGameWorld(Color accent) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF38BDF8), Color(0xFFBAE6FD), Color(0xFF15803D), Color(0xFF047857)],
          stops: [0.0, 0.45, 0.45, 1.0],
        ),
      ),
      child: Stack(
        children: [
          // Sun block in sky
          Positioned(
            top: 14,
            left: 28,
            child: Container(
              width: 18,
              height: 18,
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(color: Colors.yellow.withValues(alpha: 0.7), blurRadius: 10),
                ],
              ),
            ),
          ),
          // Water pool with waves
          Positioned(
            bottom: 0,
            right: 0,
            width: 120,
            height: 38,
            child: Container(
              color: const Color(0xFF0284C7).withValues(alpha: 0.85),
              alignment: Alignment.center,
              child: const Text(
                '~ Caustic Waves ~',
                style: TextStyle(color: Colors.white70, fontSize: 8.5, fontFamily: 'PixelifySans'),
              ),
            ),
          ),
          // Center In-Game HUD overlay
          Positioned(
            bottom: 8,
            left: 12,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.black54,
                borderRadius: BorderRadius.circular(3),
              ),
              child: const Text(
                'Piglix Vibrant Visuals Active',
                style: TextStyle(color: Colors.white, fontSize: 8.5, fontFamily: 'PixelifySans'),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─── 4. MODAL FOOTER WITH PIXELATED BUTTONS ─────────────────────────────────
  Widget _buildModalFooter(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 10, 14, 12),
      decoration: const BoxDecoration(
        color: Color(0xFF111A24),
        border: Border(top: BorderSide(color: _borderColor)),
      ),
      child: Row(
        children: [
          // Previous step button (if in step flow tab)
          if (_activeTab == 0 && _currentStep > 0) ...[
            GestureDetector(
              onTap: () => setState(() => _currentStep--),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E293B),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: Colors.white24),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.arrow_back_rounded, size: 13, color: Colors.white70),
                    SizedBox(width: 4),
                    Text(
                      'PREV',
                      style: TextStyle(
                        fontFamily: 'PixelifySans',
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 8),
          ],

          // Next / Got It Button
          Expanded(
            child: GestureDetector(
              onTap: () {
                if (_activeTab == 0 && _currentStep < 3) {
                  setState(() => _currentStep++);
                } else {
                  Navigator.pop(context);
                }
              },
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 9),
                decoration: BoxDecoration(
                  color: _kEmerald,
                  borderRadius: BorderRadius.circular(6),
                  boxShadow: [
                    BoxShadow(
                      color: _kEmerald.withValues(alpha: 0.35),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    (_activeTab == 0 && _currentStep < 3) ? 'NEXT STEP >' : 'GOT IT · READY TO PLAY',
                    style: const TextStyle(
                      fontFamily: 'PixelifySans',
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      color: Colors.black,
                      letterSpacing: 0.5,
                    ),
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

enum _MockupType {
  importToast,
  globalResources,
  videoSettings,
  inGameWorld,
}
