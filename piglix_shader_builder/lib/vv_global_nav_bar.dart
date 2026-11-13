// vv_global_nav_bar.dart
// Unified, shared bottom navigation bar and slider drawer with ultra-fast transitions
// for Home, Shader Presets, and My Shaders (Gallery).

import 'package:flutter/material.dart';
import 'minecraft_icons.dart';
import 'theme_controller.dart';
import 'hero_sunset_bytes.dart';
import 'legal_screens.dart';
import 'vv_guide_modal.dart';

// ─────────────────────────────────────────────────────────────────────────────
//  NAVIGATION TABS ENUM
// ─────────────────────────────────────────────────────────────────────────────

enum VvNavTab {
  home,
  builder,
  gallery,
  presets,
  settings,
}

// ─────────────────────────────────────────────────────────────────────────────
//  ULTRA-FAST & SMOOTH ROUTE TRANSITION (150ms cross-fade)
// ─────────────────────────────────────────────────────────────────────────────

class FastNavRoute<T> extends PageRouteBuilder<T> {
  final Widget child;

  FastNavRoute({required this.child, super.settings})
      : super(
          pageBuilder: (context, animation, secondaryAnimation) => child,
          transitionDuration: const Duration(milliseconds: 150),
          reverseTransitionDuration: const Duration(milliseconds: 130),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            final curved = CurvedAnimation(
              parent: animation,
              curve: Curves.easeOutCubic,
              reverseCurve: Curves.easeInCubic,
            );
            return FadeTransition(
              opacity: curved,
              child: child,
            );
          },
        );
}

Future<T?> fastPush<T>(BuildContext context, Widget page) {
  return Navigator.push<T>(context, FastNavRoute<T>(child: page));
}

Future<T?> fastPushReplacement<T, TO>(BuildContext context, Widget page) {
  return Navigator.pushReplacement<T, TO>(context, FastNavRoute<T>(child: page));
}

// ─────────────────────────────────────────────────────────────────────────────
//  PIXELATED CORNER PAINTERS (Authentic Minecraft stepped styling)
// ─────────────────────────────────────────────────────────────────────────────

class PixelatedClipper extends CustomClipper<Path> {
  final double step;
  const PixelatedClipper([this.step = 3.0]);

  static Path createPixelPath(double w, double h, double inset, double s) {
    final l = inset;
    final t = inset;
    final r = w - inset;
    final b = h - inset;
    return Path()
      ..moveTo(l + s * 2, t)
      ..lineTo(r - s * 2, t)
      ..lineTo(r - s * 2, t + s)
      ..lineTo(r - s, t + s)
      ..lineTo(r - s, t + s * 2)
      ..lineTo(r, t + s * 2)
      ..lineTo(r, b - s * 2)
      ..lineTo(r - s, b - s * 2)
      ..lineTo(r - s, b - s)
      ..lineTo(r - s * 2, b - s)
      ..lineTo(r - s * 2, b)
      ..lineTo(l + s * 2, b)
      ..lineTo(l + s * 2, b - s)
      ..lineTo(l + s, b - s)
      ..lineTo(l + s, b - s * 2)
      ..lineTo(l, b - s * 2)
      ..lineTo(l, t + s * 2)
      ..lineTo(l + s, t + s * 2)
      ..lineTo(l + s, t + s)
      ..lineTo(l + s * 2, t + s)
      ..close();
  }

  @override
  Path getClip(Size size) => createPixelPath(size.width, size.height, 0, step);

  @override
  bool shouldReclip(covariant PixelatedClipper oldClipper) =>
      oldClipper.step != step;
}

class PixelatedCardPainter extends CustomPainter {
  final Color fillColor;
  final Color borderColor;
  final double borderWidth;
  final double step;
  final bool hasShadow;

  const PixelatedCardPainter({
    required this.fillColor,
    required this.borderColor,
    this.borderWidth = 1.5,
    this.step = 3.0,
    this.hasShadow = true,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    if (hasShadow) {
      canvas.drawPath(
        PixelatedClipper.createPixelPath(w, h, 0, step).shift(const Offset(0, 3)),
        Paint()..color = Colors.black.withValues(alpha: 0.45),
      );
    }
    canvas.drawPath(
      PixelatedClipper.createPixelPath(w, h, 0, step),
      Paint()..color = fillColor,
    );
    canvas.drawPath(
      PixelatedClipper.createPixelPath(w, h, borderWidth * 0.5, step),
      Paint()
        ..color = Colors.white.withValues(alpha: 0.12)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.0,
    );
    canvas.drawPath(
      PixelatedClipper.createPixelPath(w, h, 0, step),
      Paint()
        ..color = borderColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = borderWidth,
    );
  }

  @override
  bool shouldRepaint(covariant PixelatedCardPainter old) =>
      old.fillColor != fillColor ||
      old.borderColor != borderColor ||
      old.step != step ||
      old.hasShadow != hasShadow;
}

class PixelatedBorderPainter extends CustomPainter {
  final Color borderColor;
  final double borderWidth;
  final double step;

  const PixelatedBorderPainter({
    required this.borderColor,
    this.borderWidth = 1.5,
    this.step = 3.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final half = borderWidth * 0.5;
    canvas.drawPath(
      PixelatedClipper.createPixelPath(size.width, size.height, half, step),
      Paint()
        ..color = borderColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = borderWidth,
    );
  }

  @override
  bool shouldRepaint(covariant PixelatedBorderPainter old) =>
      old.borderColor != borderColor || old.step != step;
}

// ─────────────────────────────────────────────────────────────────────────────
//  SHARED GLOBAL BOTTOM NAVIGATION BAR
// ─────────────────────────────────────────────────────────────────────────────

class VvGlobalBottomNav extends StatelessWidget {
  final VvNavTab currentTab;
  final VoidCallback? onOpenHome;
  final VoidCallback? onOpenBuilder;
  final VoidCallback? onOpenGallery;
  final VoidCallback? onOpenPresets;
  final VoidCallback? onOpenSettings;

  const VvGlobalBottomNav({
    super.key,
    required this.currentTab,
    this.onOpenHome,
    this.onOpenBuilder,
    this.onOpenGallery,
    this.onOpenPresets,
    this.onOpenSettings,
  });

  static const Color _green = Color(0xFF22C55E);
  static const Color _greenBorder = Color(0xFF4ADE80);

  @override
  Widget build(BuildContext context) {
    final palette = AppPalette(true);
    const s = 3.0;

    return Container(
      padding: const EdgeInsets.fromLTRB(10, 8, 10, 12),
      decoration: BoxDecoration(
        color: palette.surface,
        border: Border(top: BorderSide(color: palette.border, width: 1.0)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          // 1. HOME
          _buildItem(
            context: context,
            tab: VvNavTab.home,
            icon: Icons.home_rounded,
            label: 'HOME',
            s: s,
            palette: palette,
            onTap: onOpenHome ??
                () {
                  if (currentTab != VvNavTab.home) {
                    Navigator.popUntil(context, (route) => route.isFirst);
                  }
                },
          ),

          // 2. BUILDER
          _buildItem(
            context: context,
            tab: VvNavTab.builder,
            icon: Icons.inventory_2_rounded,
            label: 'BUILDER',
            s: s,
            palette: palette,
            onTap: onOpenBuilder,
          ),

          // 3. GALLERY
          _buildItem(
            context: context,
            tab: VvNavTab.gallery,
            icon: Icons.map_rounded,
            label: 'GALLERY',
            s: s,
            palette: palette,
            onTap: onOpenGallery,
          ),

          // 4. PRESETS
          _buildItem(
            context: context,
            tab: VvNavTab.presets,
            voxelIcon: VoxelIconType.enchantedBook,
            label: 'PRESETS',
            s: s,
            palette: palette,
            onTap: onOpenPresets,
          ),

          // 5. SETTINGS
          _buildItem(
            context: context,
            tab: VvNavTab.settings,
            icon: Icons.settings_rounded,
            label: 'SETTINGS',
            s: s,
            palette: palette,
            onTap: () {
              if (onOpenSettings != null) {
                onOpenSettings!();
              } else {
                Scaffold.of(context).openDrawer();
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildItem({
    required BuildContext context,
    required VvNavTab tab,
    IconData? icon,
    VoxelIconType? voxelIcon,
    required String label,
    required double s,
    required AppPalette palette,
    required VoidCallback? onTap,
  }) {
    final isActive = currentTab == tab;

    if (isActive) {
      return GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: CustomPaint(
          painter: PixelatedCardPainter(
            fillColor: _green,
            borderColor: _greenBorder,
            borderWidth: 1.5,
            step: s,
            hasShadow: true,
          ),
          foregroundPainter: PixelatedBorderPainter(
            borderColor: _greenBorder,
            borderWidth: 1.5,
            step: s,
          ),
          child: ClipPath(
            clipper: PixelatedClipper(s),
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 6,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (voxelIcon != null)
                    AnimatedMinecraftIcon(type: voxelIcon, size: 20)
                  else if (icon != null)
                    Icon(icon, color: Colors.black, size: 20),
                  const SizedBox(height: 2),
                  Text(
                    label,
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 9.5,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (voxelIcon != null)
            AnimatedMinecraftIcon(type: voxelIcon, size: 20)
          else if (icon != null)
            Icon(
              icon,
              color: tab == VvNavTab.gallery
                  ? const Color(0xFF60A5FA)
                  : palette.textSecondary,
              size: 20,
            ),
          const SizedBox(height: 3),
          Text(
            label,
            style: TextStyle(
              color: palette.textSecondary,
              fontSize: 9.0,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  SHARED GLOBAL MINECRAFT SLIDER DRAWER
// ─────────────────────────────────────────────────────────────────────────────

class VvGlobalDrawer extends StatelessWidget {
  final VvNavTab? currentTab;
  final VoidCallback? onOpenEditor;
  final VoidCallback? onOpenMyShaders;
  final VoidCallback? onOpenPresets;
  final VoidCallback? onOpenUpload;

  const VvGlobalDrawer({
    super.key,
    this.currentTab,
    this.onOpenEditor,
    this.onOpenMyShaders,
    this.onOpenPresets,
    this.onOpenUpload,
  });

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.paddingOf(context).top;
    final palette = AppPalette(true);

    return Drawer(
      backgroundColor: palette.drawerBg,
      surfaceTintColor: Colors.transparent,
      width: MediaQuery.of(context).size.width > 420
          ? 320
          : MediaQuery.of(context).size.width * 0.82,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.horizontal(right: Radius.circular(20)),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 1. Drawer Header with Hero Sunset Banner & Project Title
          _buildDrawerHeader(context, topPadding, palette),

          // 2. Navigation items
          Expanded(
            child: ListView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 14),
              children: [
                _buildSectionLabel('EDITOR & TOOLS', palette),
                const SizedBox(height: 6),
                _drawerTile(
                  palette: palette,
                  icon: Icons.tune_rounded,
                  iconColor: const Color(0xFF22C55E),
                  title: 'Shader Editor',
                  onTap: () {
                    Navigator.pop(context);
                    onOpenEditor?.call();
                  },
                ),
                _drawerTile(
                  palette: palette,
                  voxelIcon: VoxelIconType.chest,
                  iconColor: const Color(0xFF38BDF8),
                  title: 'My Shaders',
                  onTap: () {
                    Navigator.pop(context);
                    if (currentTab != VvNavTab.gallery) {
                      onOpenMyShaders?.call();
                    }
                  },
                ),
                _drawerTile(
                  palette: palette,
                  voxelIcon: VoxelIconType.enchantedBook,
                  iconColor: const Color(0xFFF59E0B),
                  title: 'Shader Presets',
                  onTap: () {
                    Navigator.pop(context);
                    if (currentTab != VvNavTab.presets) {
                      onOpenPresets?.call();
                    }
                  },
                ),
                _drawerTile(
                  palette: palette,
                  icon: Icons.file_upload_rounded,
                  iconColor: const Color(0xFFA855F7),
                  title: 'Upload & Edit Pack',
                  onTap: () {
                    Navigator.pop(context);
                    onOpenUpload?.call();
                  },
                ),
                _drawerTile(
                  palette: palette,
                  icon: Icons.help_outline_rounded,
                  iconColor: const Color(0xFF38BDF8),
                  title: 'Activation Guide',
                  onTap: () {
                    Navigator.pop(context);
                    showMinecraftGuideModal(context);
                  },
                ),

                const SizedBox(height: 14),
                Divider(color: palette.divider, height: 1),
                const SizedBox(height: 14),

                _buildSectionLabel('LEGAL & POLICIES', palette),
                const SizedBox(height: 6),
                _drawerTile(
                  palette: palette,
                  icon: Icons.shield_outlined,
                  iconColor: const Color(0xFF2DD4BF),
                  title: 'Privacy Policy',
                  onTap: () {
                    Navigator.pop(context);
                    fastPush(context, const LegalPage(type: LegalType.privacy));
                  },
                ),
                _drawerTile(
                  palette: palette,
                  icon: Icons.description_outlined,
                  iconColor: const Color(0xFF818CF8),
                  title: 'Terms of Service',
                  onTap: () {
                    Navigator.pop(context);
                    fastPush(context, const LegalPage(type: LegalType.terms));
                  },
                ),
                _drawerTile(
                  palette: palette,
                  icon: Icons.verified_user_outlined,
                  iconColor: const Color(0xFFF59E0B),
                  title: 'Trademark & Notice',
                  onTap: () {
                    Navigator.pop(context);
                    fastPush(context, const LegalPage(type: LegalType.trademark));
                  },
                ),
                _drawerTile(
                  palette: palette,
                  icon: Icons.code_rounded,
                  iconColor: const Color(0xFF94A3B8),
                  title: 'Open Source Licenses',
                  onTap: () {
                    Navigator.pop(context);
                    fastPush(context, const LegalPage(type: LegalType.licenses));
                  },
                ),
              ],
            ),
          ),

          // 3. Drawer Footer: "Created by Piglix Labs"
          Container(
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
            decoration: BoxDecoration(
              color: palette.drawerBg,
              border: Border(
                top: BorderSide(color: palette.border, width: 1.0),
              ),
            ),
            child: SafeArea(
              top: false,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 7,
                    height: 7,
                    decoration: const BoxDecoration(
                      color: Color(0xFF22C55E),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Color(0xFF22C55E),
                          blurRadius: 6,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  RichText(
                    text: TextSpan(
                      style: const TextStyle(
                        fontSize: 12.5,
                        letterSpacing: 0.3,
                      ),
                      children: [
                        TextSpan(
                          text: 'Created by ',
                          style: TextStyle(
                            color: palette.textSecondary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const TextSpan(
                          text: 'Piglix Labs',
                          style: TextStyle(
                            color: Color(0xFF22C55E),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
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

  Widget _buildDrawerHeader(
    BuildContext context,
    double topPadding,
    AppPalette palette,
  ) {
    return Container(
      height: 180 + topPadding,
      decoration: BoxDecoration(
        color: palette.surface,
        border: Border(bottom: BorderSide(color: palette.border, width: 1.2)),
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          // 1. Hero Sunset Landscape image
          Image.memory(
            kHeroSunsetBytes,
            fit: BoxFit.cover,
            errorBuilder: (ctx, err, stack) => Image.asset(
              'assets/hero_sunset.webp',
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) =>
                  Container(color: palette.surface),
            ),
          ),

          // 2. Dark Gradient overlay fading into drawer background
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withValues(alpha: 0.35),
                  palette.drawerBg.withValues(alpha: 0.55),
                  palette.drawerBg,
                ],
                stops: const [0.0, 0.45, 1.0],
              ),
            ),
          ),

          // 3. Header content
          Padding(
            padding: EdgeInsets.fromLTRB(16, topPadding + 12, 16, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Top Row: Close button on right
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      behavior: HitTestBehavior.opaque,
                      child: Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: const Color(0xFF0E1722).withValues(alpha: 0.85),
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white24, width: 1),
                        ),
                        child: const Icon(
                          Icons.close_rounded,
                          color: Colors.white,
                          size: 18,
                        ),
                      ),
                    ),
                  ],
                ),

                // Bottom Identity: Clean Project Title & Subtitle Badge
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Shader ',
                          style: TextStyle(
                            color: palette.textPrimary,
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                            letterSpacing: -0.4,
                          ),
                        ),
                        const Text(
                          'Generator',
                          style: TextStyle(
                            color: Color(0xFF22C55E),
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                            letterSpacing: -0.4,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'FOR MINECRAFT PE • BEDROCK RTX',
                      style: TextStyle(
                        color: palette.textSecondary,
                        fontSize: 9.5,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionLabel(String label, AppPalette palette) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 4, 4, 4),
      child: Text(
        label,
        style: TextStyle(
          color: palette.textSecondary,
          fontSize: 10.5,
          fontWeight: FontWeight.w600,
          letterSpacing: 1.5,
        ),
      ),
    );
  }

  Widget _drawerTile({
    required AppPalette palette,
    IconData? icon,
    VoxelIconType? voxelIcon,
    Color iconColor = const Color(0xFF22C55E),
    required String title,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: palette.cardElevated,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: palette.borderMuted, width: 1.0),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          splashColor: iconColor.withValues(alpha: 0.15),
          highlightColor: iconColor.withValues(alpha: 0.08),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
            child: Row(
              children: [
                if (voxelIcon != null)
                  AnimatedMinecraftIcon(type: voxelIcon, size: 21)
                else if (icon != null)
                  Icon(icon, color: iconColor, size: 21),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      color: palette.textPrimary,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  color: palette.textSecondary.withValues(alpha: 0.5),
                  size: 13,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
