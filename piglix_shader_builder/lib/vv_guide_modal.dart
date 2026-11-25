import 'package:flutter/material.dart';
import 'minecraft_icons.dart';
import 'vv_tab_previews.dart';

/// Official Screenshot Asset Registry.
/// Defaults to authentic in-game Minecraft and Piglix Builder screenshots.
class OfficialGuideScreenshots {
  static String? step1Generate = 'assets/guide/step1_generate.png';
  static String? step2WhatYouGet = 'assets/guide/step2_what_you_get.png';
  static String? step3Import = 'assets/guide/step3_import.png';
  static String? step4Activate = 'assets/guide/step4_activate.png';
  static String? step5Play = 'assets/guide/step5_play.png';

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
    barrierColor: Colors.black.withValues(alpha: 0.85),
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
    title: 'Customize & Export Pack',
    pathTag: 'Piglix Builder > Export Tab',
    desc:
        'Customize your sky, water, and fog in the tabs, then tap Export to build your .mcpack.',
    bullets: [
      'Adjust Sunlight, Water clarity, and Fog to your preference.',
      'Tap "GENERATE .MCPACK" on the Export tab to compile.',
    ],
    icon: VoxelIconType.goldBlock,
    fileName: 'step1_generate.png',
    getAsset: () => OfficialGuideScreenshots.step1Generate,
  ),
  _GuideStep(
    num: '02',
    tabLabel: 'WHAT YOU GET',
    title: 'Bedrock Vibrant Visuals Shaders',
    pathTag: 'Pack Output: Official Bedrock PBR Shaders',
    desc:
        'Your .mcpack includes authentic deferred rendering features for Minecraft Bedrock:',
    bullets: [
      'Atmospheric sky scattering & glowing sun/moon bloom.',
      'Real-time water reflections & seabed wave caustics.',
      'Volumetric mist & cinematic ACES color grading.',
    ],
    icon: VoxelIconType.chest,
    fileName: 'step2_what_you_get.png',
    getAsset: () => OfficialGuideScreenshots.step2WhatYouGet,
  ),
  _GuideStep(
    num: '03',
    tabLabel: 'IMPORT',
    title: 'One-Tap Import into Minecraft',
    pathTag: 'Tap .mcpack file > Open with Minecraft',
    desc:
        'Send your generated shader package directly into Minecraft Bedrock with one tap:',
    bullets: [
      'Tap "OPEN WITH MINECRAFT" or tap your saved .mcpack file.',
      'Minecraft will open showing "Import Started..." then "Successfully imported".',
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
      'In Minecraft, go to Settings -> Global Resources -> MY PACKS.',
      'Select your shader pack and tap "ACTIVATE".',
      'Make sure your pack is at the very TOP of ACTIVE packs.',
    ],
    icon: VoxelIconType.gear,
    fileName: 'step4_activate.png',
    getAsset: () => OfficialGuideScreenshots.step4Activate,
  ),
  _GuideStep(
    num: '05',
    tabLabel: 'PLAY',
    title: 'Turn On Vibrant Visuals & Play',
    pathTag: 'Minecraft > Settings > Video > Graphics Mode: Vibrant Visuals',
    desc:
        'Turn on Minecraft\'s deferred shader pipeline and launch your world:',
    bullets: [
      'In Settings -> Video, set Graphics Mode to "Vibrant Visuals".',
      'Set Brightness to 50% for optimal contrast and bloom.',
      'Launch any world and enjoy your custom shaders!',
    ],
    icon: VoxelIconType.sparkles,
    fileName: 'step5_play.png',
    getAsset: () => OfficialGuideScreenshots.step5Play,
  ),
];

/// Minimal, Clean Step-by-Step Minecraft Activation Guide (Emerald Green Theme)
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
  // Emerald Green Theme Color Palette (Matching App Theme)
  static const Color _kGreenPrimary = Color(0xFF22C55E); // Piglix Emerald Green
  static const Color _kGreenAccent = Color(0xFF4ADE80); // Mint green
  static const Color _kBgModal = Color(0xFF090E15); // Dark modal surface
  static const Color _kBgCard = Color(0xFF101823); // Elevated card
  static const Color _kBorder = Color(0xFF1E2D3D); // Border color

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
            borderColor: _kGreenPrimary.withValues(alpha: 0.65),
            borderWidth: 2.0,
            step: 3.5,
            hasShadow: true,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // 1. Pixelated Header
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
      padding: const EdgeInsets.fromLTRB(16, 14, 12, 14),
      decoration: const BoxDecoration(
        color: Color(0xFF0C131D),
        border: Border(bottom: BorderSide(color: _kBorder, width: 1.4)),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: _kGreenPrimary.withValues(alpha: 0.20),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: _kGreenPrimary, width: 1.4),
              boxShadow: [
                BoxShadow(
                  color: _kGreenPrimary.withValues(alpha: 0.25),
                  blurRadius: 8,
                ),
              ],
            ),
            alignment: Alignment.center,
            child: const AnimatedMinecraftIcon(
              type: VoxelIconType.goldBlock,
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: const [
                Text(
                  'MINECRAFT SHADER GUIDE',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.4,
                  ),
                ),
                SizedBox(height: 1),
                Text(
                  'Bedrock Vibrant Visuals Setup',
                  style: TextStyle(
                    color: _kGreenAccent,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.close_rounded, color: Colors.white70, size: 22),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
            splashRadius: 20,
          ),
        ],
      ),
    );
  }

  // ─── PARAMETER QUICK-REFERENCE CARD ─────────────────────────────────────────
  Widget _buildParameterAlertCard(bool isCompact) {
    return Container(
      margin: const EdgeInsets.fromLTRB(14, 10, 14, 2),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: _kGreenPrimary.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: _kGreenPrimary.withValues(alpha: 0.50), width: 1.4),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.lightbulb_outline_rounded, size: 18, color: _kGreenAccent),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Quick Tip: ${widget.parameterTitle!}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                if (widget.parameterTooltip != null) ...[
                  const SizedBox(height: 3),
                  Text(
                    widget.parameterTooltip!,
                    style: const TextStyle(
                      color: Color(0xFFE4E4E7),
                      fontSize: 12,
                      height: 1.35,
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
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
      decoration: const BoxDecoration(
        color: Color(0xFF0C131D),
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
                  padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
                  decoration: BoxDecoration(
                    color: _currentStep == i
                        ? _kGreenPrimary
                        : const Color(0xFF131B26),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: _currentStep == i ? _kGreenPrimary : _kBorder,
                      width: 1.4,
                    ),
                    boxShadow: _currentStep == i
                        ? [
                            BoxShadow(
                              color: _kGreenPrimary.withValues(alpha: 0.35),
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
                          fontSize: isCompact ? 11.0 : 12.0,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.3,
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
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Step pill badge & Title
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _kGreenPrimary,
                  borderRadius: BorderRadius.circular(5),
                  boxShadow: [
                    BoxShadow(
                      color: _kGreenPrimary.withValues(alpha: 0.3),
                      blurRadius: 6,
                    ),
                  ],
                ),
                child: Text(
                  'STEP ${step.num}',
                  style: const TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w900,
                    color: Colors.black,
                    letterSpacing: 0.4,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  step.title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15.5,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.2,
                  ),
                ),
              ),
              AnimatedMinecraftIcon(type: step.icon, size: 24),
            ],
          ),
          const SizedBox(height: 10),

          // Breadcrumb Path Tag
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.55),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: _kBorder, width: 1.2),
            ),
            child: Row(
              children: [
                const Icon(Icons.folder_open_rounded, size: 15, color: _kGreenAccent),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    step.pathTag,
                    style: const TextStyle(
                      color: _kGreenAccent,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Description (Clean & Readable)
          Text(
            step.desc,
            style: const TextStyle(
              color: Color(0xFFE4E4E7),
              fontSize: 13.5,
              height: 1.45,
              fontWeight: FontWeight.w400,
            ),
          ),
          const SizedBox(height: 14),

          // Screenshot Slot with Highly Visible Proper Emerald Border
          _buildScreenshotPlaceholder(
            title: step.title,
            fileName: step.fileName,
            assetPath: step.getAsset(),
            accent: _kGreenPrimary,
          ),
          const SizedBox(height: 14),

          // Key Action Bullets (Larger, Punchy Text)
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: _kBgCard,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: _kBorder, width: 1.2),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (final bullet in step.bullets) ...[
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(
                          Icons.check_circle_rounded,
                          size: 17,
                          color: _kGreenAccent,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            bullet,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 13.0,
                              height: 1.4,
                              fontWeight: FontWeight.w500,
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

  // ─── OFFICIAL SCREENSHOT SLOT (HIGHLY VISIBLE PROPER BORDER) ───────────────
  Widget _buildScreenshotPlaceholder({
    required String title,
    required String fileName,
    String? assetPath,
    required Color accent,
  }) {
    final effectivePath = assetPath ?? 'assets/guide/$fileName';
    final hasAsset = effectivePath.trim().isNotEmpty;

    return Container(
      width: double.infinity,
      height: 175,
      decoration: BoxDecoration(
        color: const Color(0xFF070B10),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: const Color(0xFF22C55E), // Solid, highly visible Piglix green border
          width: 2.0,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF22C55E).withValues(alpha: 0.28),
            blurRadius: 14,
            spreadRadius: 1,
            offset: const Offset(0, 3),
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.6),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        fit: StackFit.expand,
        children: [
          if (hasAsset)
            Image.asset(
              effectivePath,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Image.network(
                'public/guide/$fileName',
                fit: BoxFit.cover,
                errorBuilder: (c, e, s) => Image.network(
                  'guide/$fileName',
                  fit: BoxFit.cover,
                  errorBuilder: (c2, e2, s2) =>
                      _buildEmptySlotContent(fileName, accent),
                ),
              ),
            )
          else
            _buildEmptySlotContent(fileName, accent),

          // Subtle gradient scrim overlay for readability
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withValues(alpha: 0.35),
                  Colors.transparent,
                  Colors.black.withValues(alpha: 0.45),
                ],
                stops: const [0.0, 0.4, 1.0],
              ),
            ),
          ),

          // Top right status pill
          Positioned(
            top: 8,
            right: 8,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.88),
                borderRadius: BorderRadius.circular(5),
                border: Border.all(
                  color: _kGreenAccent,
                  width: 1.0,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.5),
                    blurRadius: 4,
                  ),
                ],
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.check_circle_rounded,
                    size: 12,
                    color: _kGreenAccent,
                  ),
                  SizedBox(width: 5),
                  Text(
                    'OFFICIAL SCREENSHOT',
                    style: TextStyle(
                      fontSize: 9.5,
                      fontWeight: FontWeight.w900,
                      color: _kGreenAccent,
                      letterSpacing: 0.4,
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
              Icons.photo_camera_outlined,
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
            'assets/guide/$fileName',
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
        color: Color(0xFF0C131D),
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
                  color: const Color(0xFF131B26),
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
                    width: _currentStep == i ? 18 : 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: _currentStep == i ? _kGreenPrimary : Colors.white24,
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
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [_kGreenPrimary, Color(0xFF16A34A)],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
                borderRadius: BorderRadius.circular(6),
                boxShadow: [
                  BoxShadow(
                    color: _kGreenPrimary.withValues(alpha: 0.35),
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
                      fontWeight: FontWeight.w900,
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
