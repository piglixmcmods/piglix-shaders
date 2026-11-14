import 'package:flutter/material.dart';
import 'minecraft_icons.dart';
import 'vv_tab_previews.dart';

/// Official Screenshot Asset Registry.
/// Drop your official screenshots in `public/screenshots/` or `assets/screenshots/`
/// and assign them here, or pass custom paths.
/// When null or empty, an elegant Minecraft-themed empty placeholder renders.
class OfficialGuideScreenshots {
  static String? step1Generate;
  static String? step2WhatYouGet;
  static String? step3Import;
  static String? step4Activate;
  static String? step5Play;

  // Backwards compatibility aliases
  static String? get step1Import => step3Import;
  static set step1Import(String? v) => step3Import = v;
  static String? get step2GlobalResources => step4Activate;
  static set step2GlobalResources(String? v) => step4Activate = v;
  static String? get step3VideoSettings => step5Play;
  static set step3VideoSettings(String? v) => step5Play = v;
  static String? get step4InGameWorld => step5Play;
  static set step4InGameWorld(String? v) => step5Play = v;
}

/// Helper to display the unified Minecraft In-Game Guide Modal from ANY `?` button.
Future<void> showMinecraftGuideModal(
  BuildContext context, {
  int initialTab = 0,
  int initialStep = 0,
  String? parameterTitle,
  String? parameterTooltip,
}) {
  return showDialog<void>(
    context: context,
    barrierColor: Colors.black.withValues(alpha: 0.82),
    builder: (ctx) => VVMinecraftGuideModal(
      initialTab: initialTab,
      initialStep: initialStep,
      parameterTitle: parameterTitle,
      parameterTooltip: parameterTooltip,
    ),
  );
}

class _GuideStep {
  final String num;
  final String tabLabel;
  final String title;
  final String pathTag;
  final String desc;
  final List<String> bullets;
  final VoxelIconType icon;
  final String fileName;
  final String? Function() getAsset;

  const _GuideStep({
    required this.num,
    required this.tabLabel,
    required this.title,
    required this.pathTag,
    required this.desc,
    required this.bullets,
    required this.icon,
    required this.fileName,
    required this.getAsset,
  });
}

final List<_GuideStep> _kGuideSteps = [
  _GuideStep(
    num: '01',
    tabLabel: 'GENERATE',
    title: 'Customize & Generate .mcpack',
    pathTag: 'Piglix Builder > Customize > Export Tab',
    desc:
        'Tweak your sky, sun glow, water, and fog in the Builder. When ready, switch to the Export tab to compile your pack.',
    bullets: [
      'Adjust Sunlight, Shadows, Water clarity, and Fog to your preference.',
      'Open the Export tab (Tab 8) and confirm the Validation Report shows all checks passed.',
      'Tap "GENERATE .MCPACK" in the bottom action bar to build your shader package.',
    ],
    icon: VoxelIconType.goldBlock,
    fileName: 'step1_generate.png',
    getAsset: () => OfficialGuideScreenshots.step1Generate,
  ),
  _GuideStep(
    num: '02',
    tabLabel: 'WHAT YOU GET',
    title: 'What You Get in Your Shader Pack',
    pathTag: 'Pack Output: Bedrock Vibrant Visuals PBR',
    desc:
        'Your generated .mcpack file contains full official Bedrock Deferred Technical Preview PBR shaders:',
    bullets: [
      '☀️ Atmospheric Sky & Sun/Moon directional light scattering.',
      '🌊 Real-time water surface reflections, waves, and prismatic seabed caustics.',
      '🌫️ Volumetric air and ground mist tailored across all 87 biomes.',
      '⚡ All 4 Quality Modes (Low, Medium, High, Ultra) built into one slider.',
    ],
    icon: VoxelIconType.chest,
    fileName: 'step2_what_you_get.png',
    getAsset: () => OfficialGuideScreenshots.step2WhatYouGet,
  ),
  _GuideStep(
    num: '03',
    tabLabel: 'IMPORT',
    title: 'One-Tap Import into Minecraft',
    pathTag: 'Piglix Bottom Bar > "OPEN WITH MINECRAFT" or "Share"',
    desc:
        'Send your generated shader package directly into Minecraft Bedrock with a single tap:',
    bullets: [
      'Tap "OPEN WITH MINECRAFT" in the bottom bar to launch Minecraft automatically.',
      'Or tap the Share button beside it to share the file to Discord, Drive, or WhatsApp.',
      'Minecraft will open with "Import Started..." followed by "Successfully imported".',
    ],
    icon: VoxelIconType.pickaxe,
    fileName: 'step3_import.png',
    getAsset: () => OfficialGuideScreenshots.step3Import,
  ),
  _GuideStep(
    num: '04',
    tabLabel: 'ACTIVATE',
    title: 'Activate in Global Resources',
    pathTag: 'Minecraft > Settings > Global Resources > MY PACKS',
    desc:
        'Activate your shader pack in Minecraft so it applies to all your worlds:',
    bullets: [
      'In Minecraft, open Settings -> Global Resources -> MY PACKS.',
      'Select your shader pack and press "ACTIVATE".',
      'Under the ACTIVE section, move your shader pack to the VERY TOP.',
      'Optional: Tap the gear icon on the pack to slide between Low, Medium, High, or Ultra.',
    ],
    icon: VoxelIconType.gear,
    fileName: 'step4_activate.png',
    getAsset: () => OfficialGuideScreenshots.step4Activate,
  ),
  _GuideStep(
    num: '05',
    tabLabel: 'PLAY',
    title: 'Turn On Vibrant Visuals & Play',
    pathTag: 'Minecraft > Settings > Video > Graphics Mode > Vibrant Visuals',
    desc:
        'Switch on Minecraft\'s official deferred shader pipeline and launch your world:',
    bullets: [
      'Go to Minecraft Settings -> Video -> Graphics Mode and choose "Vibrant Visuals".',
      'Set Brightness / Gamma to 50% (prevents overexposed daylight and washed-out shadows).',
      'Turn Bloom: ON and set Upscaling: TAAU for smooth antialiased geometry.',
      'Launch any world and enjoy your custom Vibrant Visuals shaders!',
    ],
    icon: VoxelIconType.sparkles,
    fileName: 'step5_play.png',
    getAsset: () => OfficialGuideScreenshots.step5Play,
  ),
];

/// Simple, Horizontal Step-by-Step Minecraft Activation Guide (Yellow Dark Theme)
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
  // Yellow Dark Theme Color Palette
  static const Color _kGoldPrimary = Color(0xFFFBBF24); // Minecraft Gold
  static const Color _kBgModal = Color(0xFF111114);
  static const Color _kBgCard = Color(0xFF18181D);
  static const Color _kBorder = Color(0xFF2E2E38);

  late final PageController _pageController;
  late int _currentStep;

  @override
  void initState() {
    super.initState();
    _currentStep = widget.initialStep.clamp(0, _kGuideSteps.length - 1);
    _pageController = PageController(initialPage: _currentStep);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _goToStep(int index) {
    if (index < 0 || index >= _kGuideSteps.length) return;
    setState(() => _currentStep = index);
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOutCubic,
    );
  }

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
            maxHeight: media.size.height * 0.90,
          ),
          child: VVPixelBox(
            fillColor: _kBgModal,
            borderColor: _kGoldPrimary.withValues(alpha: 0.65),
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

                // 2. Horizontal Step Tabs Bar
                _buildHorizontalStepTabs(isCompact),

                // 3. Smooth Horizontal PageView Carousel
                Flexible(
                  child: PageView.builder(
                    controller: _pageController,
                    physics: const BouncingScrollPhysics(),
                    onPageChanged: (i) => setState(() => _currentStep = i),
                    itemCount: _kGuideSteps.length,
                    itemBuilder: (ctx, index) {
                      return _buildStepPage(ctx, _kGuideSteps[index], isCompact);
                    },
                  ),
                ),

                // 4. Modal Footer with Prev, Dots, and Next Actions
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
      padding: const EdgeInsets.fromLTRB(14, 12, 10, 12),
      decoration: const BoxDecoration(
        color: Color(0xFF141418),
        border: Border(bottom: BorderSide(color: _kBorder, width: 1.4)),
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: _kGoldPrimary.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: _kGoldPrimary, width: 1.2),
            ),
            alignment: Alignment.center,
            child: const AnimatedMinecraftIcon(
              type: VoxelIconType.goldBlock,
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
                  'MINECRAFT SHADER GUIDE',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.3,
                  ),
                ),
                Text(
                  'Bedrock Vibrant Visuals Setup',
                  style: TextStyle(
                    color: _kGoldPrimary,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
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
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: _kGoldPrimary.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: _kGoldPrimary.withValues(alpha: 0.45), width: 1.2),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.lightbulb_outline_rounded, size: 16, color: _kGoldPrimary),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Quick Tip: ${widget.parameterTitle!}',
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
                      color: Color(0xFFD4D4D8),
                      fontSize: 11.5,
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

  // ─── 2. HORIZONTAL STEP TABS ────────────────────────────────────────────────
  Widget _buildHorizontalStepTabs(bool isCompact) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: const BoxDecoration(
        color: Color(0xFF141418),
        border: Border(bottom: BorderSide(color: _kBorder, width: 1.2)),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        child: Row(
          children: [
            for (int i = 0; i < _kGuideSteps.length; i++) ...[
              if (i > 0) const SizedBox(width: 6),
              GestureDetector(
                onTap: () => _goToStep(i),
                behavior: HitTestBehavior.opaque,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 220),
                  curve: Curves.easeInOut,
                  padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
                  decoration: BoxDecoration(
                    color: _currentStep == i
                        ? _kGoldPrimary
                        : const Color(0xFF1E1E24),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: _currentStep == i ? _kGoldPrimary : _kBorder,
                      width: 1.2,
                    ),
                    boxShadow: _currentStep == i
                        ? [
                            BoxShadow(
                              color: _kGoldPrimary.withValues(alpha: 0.35),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ]
                        : null,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '${i + 1}. ${_kGuideSteps[i].tabLabel}',
                        style: TextStyle(
                          fontSize: isCompact ? 10.5 : 11.5,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.2,
                          color: _currentStep == i ? Colors.black : Colors.white70,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // ─── 3. STEP CONTENT PAGE ───────────────────────────────────────────────────
  Widget _buildStepPage(BuildContext context, _GuideStep step, bool isCompact) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Step pill badge & Title
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                decoration: BoxDecoration(
                  color: _kGoldPrimary,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  'STEP ${step.num}',
                  style: const TextStyle(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w800,
                    color: Colors.black,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  step.title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              AnimatedMinecraftIcon(type: step.icon, size: 20),
            ],
          ),
          const SizedBox(height: 8),

          // Breadcrumb Path Tag
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(5),
              border: Border.all(color: _kBorder),
            ),
            child: Row(
              children: [
                const Icon(Icons.folder_open_rounded, size: 13, color: _kGoldPrimary),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    step.pathTag,
                    style: const TextStyle(
                      color: _kGoldPrimary,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),

          // Description
          Text(
            step.desc,
            style: const TextStyle(
              color: Color(0xFFD4D4D8),
              fontSize: 12,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 12),

          // Official Screenshot Placeholder / Slot
          _buildScreenshotPlaceholder(
            title: step.title,
            fileName: step.fileName,
            assetPath: step.getAsset(),
            accent: _kGoldPrimary,
          ),
          const SizedBox(height: 12),

          // Key Action Bullets
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: _kBgCard,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: _kBorder),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (final bullet in step.bullets) ...[
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 3),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(
                          Icons.check_circle_rounded,
                          size: 15,
                          color: _kGoldPrimary,
                        ),
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
          ),
        ],
      ),
    );
  }

  // ─── OFFICIAL SCREENSHOT SLOT (EMPTY PLACEHOLDER BY DEFAULT) ────────────────
  Widget _buildScreenshotPlaceholder({
    required String title,
    required String fileName,
    String? assetPath,
    required Color accent,
  }) {
    final hasAsset = assetPath != null && assetPath.trim().isNotEmpty;

    return Container(
      width: double.infinity,
      height: 145,
      decoration: BoxDecoration(
        color: const Color(0xFF0D0D10),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: hasAsset ? accent.withValues(alpha: 0.6) : accent.withValues(alpha: 0.35),
          width: 1.2,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          if (hasAsset)
            Positioned.fill(
              child: Image.asset(
                assetPath,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) =>
                    _buildEmptySlotContent(fileName, accent),
              ),
            )
          else
            Positioned.fill(
              child: _buildEmptySlotContent(fileName, accent),
            ),
          // Top right status pill
          Positioned(
            top: 7,
            right: 7,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2.5),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.85),
                borderRadius: BorderRadius.circular(4),
                border: Border.all(
                  color: hasAsset ? const Color(0xFF4ADE80) : accent.withValues(alpha: 0.5),
                  width: 0.8,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    hasAsset ? Icons.check_circle_rounded : Icons.photo_camera_outlined,
                    size: 11,
                    color: hasAsset ? const Color(0xFF4ADE80) : accent,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    hasAsset ? 'OFFICIAL SCREENSHOT' : 'SCREENSHOT PLACEHOLDER',
                    style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.w700,
                      color: hasAsset ? const Color(0xFF4ADE80) : accent,
                      letterSpacing: 0.3,
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

  Widget _buildEmptySlotContent(String fileName, Color accent) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      alignment: Alignment.center,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.12),
              shape: BoxShape.circle,
              border: Border.all(color: accent.withValues(alpha: 0.4), width: 1.2),
            ),
            child: Icon(
              Icons.add_photo_alternate_outlined,
              size: 18,
              color: accent,
            ),
          ),
          const SizedBox(height: 7),
          const Text(
            'Official Screenshot Placeholder',
            style: TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            'Drop image into: public/$fileName or assets/$fileName',
            style: const TextStyle(
              color: Colors.white54,
              fontSize: 10,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  // ─── 4. MODAL FOOTER ────────────────────────────────────────────────────────
  Widget _buildModalFooter(BuildContext context) {
    final isLast = _currentStep == _kGuideSteps.length - 1;

    return Container(
      padding: const EdgeInsets.fromLTRB(14, 10, 14, 12),
      decoration: const BoxDecoration(
        color: Color(0xFF141418),
        border: Border(top: BorderSide(color: _kBorder, width: 1.2)),
      ),
      child: Row(
        children: [
          // Previous button
          if (_currentStep > 0) ...[
            GestureDetector(
              onTap: () => _goToStep(_currentStep - 1),
              behavior: HitTestBehavior.opaque,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
                decoration: BoxDecoration(
                  color: const Color(0xFF22222A),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: _kBorder),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.arrow_back_rounded, size: 14, color: Colors.white70),
                    SizedBox(width: 4),
                    Text(
                      'PREV',
                      style: TextStyle(
                        fontSize: 11.5,
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

          // Step Dots Indicator
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                for (int i = 0; i < _kGuideSteps.length; i++)
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 240),
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    width: _currentStep == i ? 16 : 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: _currentStep == i ? _kGoldPrimary : Colors.white24,
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 8),

          // Next / Ready Button
          GestureDetector(
            onTap: () {
              if (!isLast) {
                _goToStep(_currentStep + 1);
              } else {
                Navigator.pop(context);
              }
            },
            behavior: HitTestBehavior.opaque,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 9),
              decoration: BoxDecoration(
                color: _kGoldPrimary,
                borderRadius: BorderRadius.circular(6),
                boxShadow: [
                  BoxShadow(
                    color: _kGoldPrimary.withValues(alpha: 0.35),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    isLast ? 'READY TO PLAY ✓' : 'NEXT STEP >',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      color: Colors.black,
                      letterSpacing: 0.3,
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
}
