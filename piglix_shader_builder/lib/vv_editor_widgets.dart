// vv_editor_widgets.dart
// Shared UI components, unified Obsidian & Emerald theme palette, boxy voxel
// scene cards, clean color chooser, undo/redo controller, and pack icon normalizer.

import 'dart:math' as math;
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'vv_tab_previews.dart';
import 'vv_guide_modal.dart';

// ─── UNIFIED HOME-SCREEN OBSIDIAN & EMERALD PALETTE ───────────────────────────
const Color kVVBackground = Color(0xFF080D14);
const Color kVVSurface = Color(0xFF0E1722);
const Color kVVCard = Color(0xFF141F2D);
const Color kVVBorder = Color(0xFF1E293B);
const Color kVVPrimary = Color(0xFF22C55E);

String formatVVColorHex(Color color) {
  final rgb = (color.toARGB32() & 0x00FFFFFF)
      .toRadixString(16)
      .padLeft(6, '0')
      .toUpperCase();
  return '#$rgb';
}

// ─── 1. TAB METADATA ──────────────────────────────────────────────────────────
class VVTabMeta {
  final String label;
  final String shortLabel;
  final Color accent;
  final IconData icon;

  const VVTabMeta({
    required this.label,
    required this.shortLabel,
    required this.accent,
    required this.icon,
  });
}

const List<VVTabMeta> kVVTabMetas = [
  VVTabMeta(
    label: 'Sky & Time',
    shortLabel: 'SKY',
    accent: kVVPrimary,
    icon: Icons.wb_sunny_rounded,
  ),
  VVTabMeta(
    label: 'Light & Shadows',
    shortLabel: 'LIGHT',
    accent: kVVPrimary,
    icon: Icons.lightbulb_rounded,
  ),
  VVTabMeta(
    label: 'Fog & Air',
    shortLabel: 'FOG',
    accent: kVVPrimary,
    icon: Icons.blur_on_rounded,
  ),
  VVTabMeta(
    label: 'Water',
    shortLabel: 'WATER',
    accent: kVVPrimary,
    icon: Icons.water_rounded,
  ),
  VVTabMeta(
    label: 'Color & Mood',
    shortLabel: 'COLOR',
    accent: kVVPrimary,
    icon: Icons.palette_rounded,
  ),
  VVTabMeta(
    label: 'Biomes',
    shortLabel: 'BIOMES',
    accent: kVVPrimary,
    icon: Icons.terrain_rounded,
  ),
  VVTabMeta(
    label: 'Surface',
    shortLabel: 'SURFACE',
    accent: kVVPrimary,
    icon: Icons.layers_rounded,
  ),
  VVTabMeta(
    label: 'Performance',
    shortLabel: 'PERF',
    accent: kVVPrimary,
    icon: Icons.speed_rounded,
  ),
  VVTabMeta(
    label: 'Export',
    shortLabel: 'EXPORT',
    accent: kVVPrimary,
    icon: Icons.inventory_2_rounded,
  ),
];

// ─── 2. COMPACT BADGES ────────────────────────────────────────────────────────
class _VVPillBadge extends StatelessWidget {
  final String label;
  final String tooltip;
  final IconData icon;
  final Color color;

  const _VVPillBadge({
    required this.label,
    required this.tooltip,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: VVPixelBox(
        fillColor: kVVSurface,
        borderColor: color.withValues(alpha: 0.45),
        borderWidth: 1.0,
        step: 1.5,
        hasShadow: false,
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 10, color: color),
            const SizedBox(width: 3),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 9.5,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class PackWideBadge extends StatelessWidget {
  const PackWideBadge({super.key});

  @override
  Widget build(BuildContext context) {
    return const _VVPillBadge(
      label: 'Pack-wide',
      tooltip: 'Applies across all biomes (cannot blend per biome).',
      icon: Icons.lock_outline_rounded,
      color: Color(0xFF94A3B8),
    );
  }
}

class ExperimentalBadge extends StatelessWidget {
  const ExperimentalBadge({super.key});

  @override
  Widget build(BuildContext context) {
    return const _VVPillBadge(
      label: 'Experimental',
      tooltip: 'Behavior may vary across Bedrock versions — test in game.',
      icon: Icons.science_outlined,
      color: Color(0xFF94A3B8),
    );
  }
}

Widget _buildRowTitleBlock({
  required String label,
  required String? tooltip,
  required bool isPackWide,
  required bool isExperimental,
  Widget? trailingBadge,
  Widget? endWidget,
  bool enabled = true,
}) {
  return Row(
    crossAxisAlignment: CrossAxisAlignment.center,
    children: [
      Expanded(
        child: Wrap(
          spacing: 6,
          runSpacing: 4,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            Text(
              label,
              style: TextStyle(
                color: enabled ? Colors.white : Colors.white54,
                fontSize: 13.5,
                fontWeight: FontWeight.w600,
              ),
            ),
            if (isPackWide) const PackWideBadge(),
            if (isExperimental) const ExperimentalBadge(),
            ?trailingBadge,
            if (tooltip != null && tooltip.isNotEmpty)
              Builder(
                builder: (ctx) => GestureDetector(
                  onTap: () => showMinecraftGuideModal(
                    ctx,
                    parameterTitle: label,
                    parameterTooltip: tooltip,
                    initialTab: 3,
                  ),
                  child: Tooltip(
                    message: '$tooltip\nTap to open Minecraft guide',
                    triggerMode: TooltipTriggerMode.tap,
                    child: Container(
                      padding: const EdgeInsets.all(2.5),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.06),
                        borderRadius: BorderRadius.circular(3),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.16),
                          width: 0.8,
                        ),
                      ),
                      child: const Icon(
                        Icons.help_outline_rounded,
                        size: 13,
                        color: Colors.white60,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
      if (endWidget != null) ...[
        const SizedBox(width: 8),
        endWidget,
      ],
    ],
  );
}

// ─── 3. SECTION CARD ──────────────────────────────────────────────────────────
class VVSectionCard extends StatelessWidget {
  final String title;
  final Color accent;
  final Widget? badge;
  final List<Widget> children;
  final bool collapsible;
  final bool initiallyExpanded;

  const VVSectionCard({
    super.key,
    required this.title,
    Color? accent,
    this.badge,
    required this.children,
    this.collapsible = false,
    this.initiallyExpanded = false,
  }) : accent = accent ?? kVVPrimary;

  Widget _buildHeaderTitle() {
    return Row(
      children: [
        Container(
          width: 3.5,
          height: 15,
          decoration: BoxDecoration(
            color: accent,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 9),
        Expanded(
          child: Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.2,
            ),
          ),
        ),
        if (badge != null) ...[const SizedBox(width: 8), badge!],
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    if (collapsible) {
      return VVPixelBox(
        fillColor: kVVSurface,
        borderColor: kVVBorder,
        borderWidth: 1.4,
        step: 3.5,
        hasShadow: true,
        child: Material(
          type: MaterialType.transparency,
          child: Theme(
            data: Theme.of(context).copyWith(
              dividerColor: Colors.transparent,
              splashColor: accent.withValues(alpha: 0.08),
              highlightColor: Colors.transparent,
            ),
            child: ExpansionTile(
              initiallyExpanded: initiallyExpanded,
              tilePadding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 2,
              ),
              childrenPadding: const EdgeInsets.fromLTRB(14, 2, 14, 14),
              iconColor: accent,
              collapsedIconColor: Colors.white54,
              title: _buildHeaderTitle(),
              children: children,
            ),
          ),
        ),
      );
    }

    return VVPixelBox(
      fillColor: kVVSurface,
      borderColor: kVVBorder,
      borderWidth: 1.4,
      step: 3.5,
      hasShadow: true,
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeaderTitle(),
          if (children.isNotEmpty) const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }
}

// ─── 4. USER-FRIENDLY TACTILE SLIDER WITH -/+ NUDGE BUTTONS ───────────────────
class _VVVoxelSliderThumbShape extends SliderComponentShape {
  final Color fillColor;

  const _VVVoxelSliderThumbShape({required this.fillColor});

  @override
  Size getPreferredSize(bool isEnabled, bool isDiscrete) => const Size(14, 18);

  @override
  void paint(
    PaintingContext context,
    Offset center, {
    required Animation<double> activationAnimation,
    required Animation<double> enableAnimation,
    required bool isDiscrete,
    required TextPainter labelPainter,
    required RenderBox parentBox,
    required SliderThemeData sliderTheme,
    required TextDirection textDirection,
    required double value,
    required double textScaleFactor,
    required Size sizeWithOverflow,
  }) {
    final canvas = context.canvas;
    final outer = RRect.fromRectAndRadius(
      Rect.fromCenter(center: center, width: 14, height: 18),
      const Radius.circular(3),
    );
    canvas.drawRRect(
      outer,
      Paint()..color = Color.lerp(fillColor, Colors.black, 0.35)!,
    );
    final inner = RRect.fromRectAndRadius(
      Rect.fromCenter(center: center, width: 10, height: 14),
      const Radius.circular(2),
    );
    canvas.drawRRect(inner, Paint()..color = fillColor);
    canvas.drawLine(
      Offset(center.dx - 3.5, center.dy - 5),
      Offset(center.dx + 3.5, center.dy - 5),
      Paint()
        ..color = Colors.white.withValues(alpha: 0.55)
        ..strokeWidth = 1.2,
    );
  }
}

class VVLabeledSlider extends StatelessWidget {
  final String label;
  final String tooltip;
  final double value;
  final double min;
  final double max;
  final int? divisions;
  final String unit;
  final int decimals;
  final Color accent;
  final bool isPackWide;
  final bool isExperimental;
  final bool enabled;
  final ValueChanged<double> onChanged;
  final ValueChanged<double>? onChangeEnd;

  const VVLabeledSlider({
    super.key,
    required this.label,
    required this.tooltip,
    required this.value,
    required this.min,
    required this.max,
    this.divisions,
    this.unit = '',
    this.decimals = 2,
    this.accent = kVVPrimary,
    this.isPackWide = false,
    this.isExperimental = false,
    this.enabled = true,
    required this.onChanged,
    this.onChangeEnd,
  });

  double _stepAmount() {
    final range = (max - min).abs();
    if (divisions != null && divisions! > 0) {
      return range / divisions!;
    }
    if (decimals == 0) return math.max(1.0, (range / 40.0).roundToDouble());
    return double.parse((range / 40.0).toStringAsFixed(decimals)).clamp(0.001, range);
  }

  void _nudge(double dir, double clamped, double safeMax) {
    final next = (clamped + dir * _stepAmount()).clamp(min, safeMax).toDouble();
    HapticFeedback.selectionClick();
    onChanged(next);
    onChangeEnd?.call(next);
  }

  @override
  Widget build(BuildContext context) {
    final safeMax = max >= min ? max : min;
    final clamped = (value.isNaN ? min : value.clamp(min, safeMax)).toDouble();
    final formatted = clamped.toStringAsFixed(decimals);
    final valueText = '$formatted$unit';

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: VVPixelBox(
        fillColor: kVVCard,
        borderColor: kVVBorder,
        borderWidth: 1.2,
        step: 2.5,
        hasShadow: false,
        padding: const EdgeInsets.fromLTRB(10, 9, 10, 4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildRowTitleBlock(
              label: label,
              tooltip: tooltip,
              isPackWide: isPackWide,
              isExperimental: isExperimental,
              enabled: enabled,
              endWidget: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _nudgeBtn(
                    icon: Icons.remove_rounded,
                    enabled: enabled && clamped > min,
                    onTap: () => _nudge(-1, clamped, safeMax),
                  ),
                  const SizedBox(width: 4),
                  VVPixelBox(
                    fillColor: kVVSurface,
                    borderColor: enabled ? accent.withValues(alpha: 0.50) : kVVBorder,
                    borderWidth: 1.1,
                    step: 1.5,
                    hasShadow: false,
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    child: Text(
                      valueText,
                      style: TextStyle(
                        color: enabled ? accent : Colors.white38,
                        fontFamily: 'monospace',
                        fontSize: 11.5,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(width: 4),
                  _nudgeBtn(
                    icon: Icons.add_rounded,
                    enabled: enabled && clamped < safeMax,
                    onTap: () => _nudge(1, clamped, safeMax),
                  ),
                ],
              ),
            ),
            SliderTheme(
              data: SliderTheme.of(context).copyWith(
                activeTrackColor: enabled ? accent : Colors.white24,
                inactiveTrackColor: kVVSurface,
                disabledActiveTrackColor: Colors.white24,
                disabledInactiveTrackColor: kVVSurface,
                thumbColor: enabled ? accent : Colors.white38,
                overlayColor: accent.withValues(alpha: 0.14),
                trackHeight: 5,
                thumbShape: _VVVoxelSliderThumbShape(
                  fillColor: enabled ? accent : Colors.white38,
                ),
                overlayShape: const RoundSliderOverlayShape(overlayRadius: 14),
              ),
              child: Slider(
                value: clamped,
                min: min,
                max: safeMax,
                divisions: safeMax > min ? divisions : null,
                onChanged: enabled ? onChanged : null,
                onChangeEnd: enabled ? onChangeEnd : null,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _nudgeBtn({
    required IconData icon,
    required bool enabled,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      behavior: HitTestBehavior.opaque,
      child: VVPixelBox(
        fillColor: kVVSurface,
        borderColor: kVVBorder,
        borderWidth: 1.1,
        step: 1.5,
        hasShadow: false,
        child: SizedBox(
          width: 24,
          height: 24,
          child: Icon(
            icon,
            size: 14,
            color: enabled ? Colors.white70 : Colors.white24,
          ),
        ),
      ),
    );
  }
}

// ─── 5. CLEAN COLOR CHOOSER DIALOG & COLOR ROW ────────────────────────────────
const List<Color> _kQuickColorSwatches = [
  Color(0xFFFFFFFF),
  Color(0xFFFDE047),
  Color(0xFFFB923C),
  Color(0xFFF43F5E),
  Color(0xFFEC4899),
  Color(0xFFA855F7),
  Color(0xFF38BDF8),
  Color(0xFF22D3EE),
  Color(0xFF22C55E),
  Color(0xFF84CC16),
  Color(0xFFCE8133),
  Color(0xFF0F172A),
];

Future<Color?> showVVColorPickerDialog(
  BuildContext context, {
  required String title,
  required Color initialColor,
  Color accent = kVVPrimary,
}) async {
  Color draftColor = Color(initialColor.toARGB32() | 0xFF000000);
  final hexController = TextEditingController(
    text: formatVVColorHex(draftColor).substring(1),
  );

  final Color? picked = await showDialog<Color>(
    context: context,
    builder: (dialogCtx) {
      return StatefulBuilder(
        builder: (ctx, setDialogState) {
          void updateColor(Color next, {bool updateHexField = true}) {
            final opaque = Color(next.toARGB32() | 0xFF000000);
            setDialogState(() {
              draftColor = opaque;
              if (updateHexField) {
                final hex = formatVVColorHex(opaque).substring(1);
                hexController.value = TextEditingValue(
                  text: hex,
                  selection: TextSelection.collapsed(offset: hex.length),
                );
              }
            });
          }

          return AlertDialog(
            backgroundColor: kVVSurface,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
              side: const BorderSide(color: kVVBorder, width: 1.5),
            ),
            titlePadding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
            contentPadding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
            title: Row(
              children: [
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: draftColor,
                    borderRadius: BorderRadius.circular(5),
                    border: Border.all(color: Colors.white70, width: 1.5),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                Text(
                  formatVVColorHex(draftColor),
                  style: TextStyle(
                    color: accent,
                    fontFamily: 'monospace',
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            content: SizedBox(
              width: 300,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Clean palette swatch strip
                    Wrap(
                      spacing: 7,
                      runSpacing: 7,
                      alignment: WrapAlignment.center,
                      children: _kQuickColorSwatches.map((swatch) {
                        final selected = (swatch.toARGB32() & 0x00FFFFFF) ==
                            (draftColor.toARGB32() & 0x00FFFFFF);
                        return GestureDetector(
                          onTap: () {
                            HapticFeedback.selectionClick();
                            updateColor(swatch);
                          },
                          child: Container(
                            width: 36,
                            height: 26,
                            decoration: BoxDecoration(
                              color: swatch,
                              borderRadius: BorderRadius.circular(5),
                              border: Border.all(
                                color: selected ? accent : Colors.black87,
                                width: selected ? 2.4 : 1.2,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 12),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Container(
                        color: kVVBackground,
                        padding: const EdgeInsets.fromLTRB(8, 8, 8, 2),
                        child: ColorPicker(
                          pickerColor: draftColor,
                          enableAlpha: false,
                          displayThumbColor: true,
                          hexInputBar: false,
                          labelTypes: const [],
                          paletteType: PaletteType.hsvWithHue,
                          pickerAreaHeightPercent: 0.56,
                          pickerAreaBorderRadius: BorderRadius.circular(8),
                          onColorChanged: updateColor,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 9,
                          ),
                          decoration: BoxDecoration(
                            color: kVVCard,
                            borderRadius: BorderRadius.circular(7),
                            border: Border.all(color: kVVBorder),
                          ),
                          child: const Text(
                            '#',
                            style: TextStyle(
                              color: Colors.white54,
                              fontFamily: 'monospace',
                              fontWeight: FontWeight.w700,
                              fontSize: 13,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextField(
                            controller: hexController,
                            maxLength: 6,
                            inputFormatters: [
                              FilteringTextInputFormatter.allow(
                                RegExp(r'[0-9a-fA-F]'),
                              ),
                            ],
                            style: const TextStyle(
                              color: Colors.white,
                              fontFamily: 'monospace',
                              fontWeight: FontWeight.w700,
                              fontSize: 13,
                              letterSpacing: 1.4,
                            ),
                            decoration: InputDecoration(
                              counterText: '',
                              isDense: true,
                              filled: true,
                              fillColor: kVVCard,
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 9,
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(7),
                                borderSide: const BorderSide(color: kVVBorder),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(7),
                                borderSide: BorderSide(color: accent, width: 1.5),
                              ),
                            ),
                            onChanged: (raw) {
                              final clean = raw.trim();
                              if (clean.length == 6) {
                                final parsed = int.tryParse(clean, radix: 16);
                                if (parsed != null) {
                                  updateColor(
                                    Color(0xFF000000 | parsed),
                                    updateHexField: false,
                                  );
                                }
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(dialogCtx).pop(),
                child: const Text(
                  'Cancel',
                  style: TextStyle(color: Colors.white54),
                ),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: accent,
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: () => Navigator.of(dialogCtx).pop(draftColor),
                child: const Text(
                  'Apply',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
            ],
          );
        },
      );
    },
  );

  hexController.dispose();
  return picked;
}

class VVColorRow extends StatelessWidget {
  final String label;
  final String tooltip;
  final Color color;
  final Color accent;
  final bool isPackWide;
  final bool isExperimental;
  final Widget? trailingBadge;
  final ValueChanged<Color> onChanged;

  const VVColorRow({
    super.key,
    required this.label,
    required this.tooltip,
    required this.color,
    this.accent = kVVPrimary,
    this.isPackWide = false,
    this.isExperimental = false,
    this.trailingBadge,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final hexLabel = formatVVColorHex(color);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: GestureDetector(
        onTap: () async {
          final picked = await showVVColorPickerDialog(
            context,
            title: label,
            initialColor: color,
            accent: accent,
          );
          if (picked != null) onChanged(picked);
        },
        behavior: HitTestBehavior.opaque,
        child: VVPixelBox(
          fillColor: kVVCard,
          borderColor: kVVBorder,
          borderWidth: 1.2,
          step: 2.5,
          hasShadow: false,
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          child: Row(
            children: [
              VVPixelBox(
                fillColor: color,
                borderColor: Colors.white.withValues(alpha: 0.78),
                borderWidth: 1.4,
                step: 1.5,
                hasShadow: false,
                child: const SizedBox(width: 28, height: 28),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildRowTitleBlock(
                  label: label,
                  tooltip: tooltip,
                  isPackWide: isPackWide,
                  isExperimental: isExperimental,
                  trailingBadge: trailingBadge,
                ),
              ),
              const SizedBox(width: 8),
              VVPixelBox(
                fillColor: kVVSurface,
                borderColor: kVVBorder,
                borderWidth: 1.1,
                step: 1.5,
                hasShadow: false,
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      hexLabel,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontFamily: 'monospace',
                        fontSize: 11.5,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(Icons.edit_rounded, size: 11, color: accent),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── 6. SQUARE PIXELATED MODE CARDS WITH INTERNAL ARTWORK ───────────────────────

/// Crisp 1:1 square Minecraft-styled pixel box selector card with internal
/// custom-painted scene, bold bottom label bar, and compact corner swatch dot.
class VVSceneBoxCard extends StatelessWidget {
  final String label;
  final VVSceneBoxType sceneType;
  final Color color;
  final bool isSelected;
  final VoidCallback onTap;
  final VoidCallback? onPickColor;
  final bool showHexBadge;
  final String? statusBadge;
  final double aspectRatio;

  const VVSceneBoxCard({
    super.key,
    required this.label,
    required this.sceneType,
    required this.color,
    required this.isSelected,
    required this.onTap,
    this.onPickColor,
    this.showHexBadge = false,
    this.statusBadge,
    this.aspectRatio = 1.0,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        onTap();
      },
      behavior: HitTestBehavior.opaque,
      child: AspectRatio(
        aspectRatio: aspectRatio,
        child: Container(
          decoration: BoxDecoration(
            boxShadow: [
              if (isSelected)
                BoxShadow(
                  color: kVVPrimary.withValues(alpha: 0.28),
                  blurRadius: 10,
                ),
            ],
          ),
          child: VVPixelBox(
            fillColor: kVVCard,
            borderColor: isSelected ? kVVPrimary : const Color(0xFF334155),
            borderWidth: isSelected ? 2.0 : 1.3,
            step: 3.0,
            hasShadow: true,
            child: Stack(
              fit: StackFit.expand,
              children: [
                VVSceneArtwork(
                  type: sceneType,
                  color: color,
                ),
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 5,
                      vertical: 4.5,
                    ),
                    decoration: BoxDecoration(
                      color: kVVBackground.withValues(alpha: isSelected ? 0.88 : 0.78),
                      border: Border(
                        top: BorderSide(
                          color: isSelected
                              ? kVVPrimary.withValues(alpha: 0.75)
                              : kVVBorder,
                          width: 1.0,
                        ),
                      ),
                    ),
                    child: Center(
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          label,
                          maxLines: 1,
                          style: TextStyle(
                            color: isSelected ? kVVPrimary : Colors.white,
                            fontSize: 10.5,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
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

/// Centered responsive grid for square Minecraft scene cards.
class VVSceneBoxGrid extends StatelessWidget {
  final List<Widget> cards;
  final int maxColumns;
  final double gap;

  const VVSceneBoxGrid({
    super.key,
    required this.cards,
    this.maxColumns = 4,
    this.gap = 8.0,
  });

  @override
  Widget build(BuildContext context) {
    if (cards.isEmpty) return const SizedBox.shrink();
    return LayoutBuilder(
      builder: (context, constraints) {
        final effectiveMaxCols =
            constraints.maxWidth < 260 ? math.min(maxColumns, 2) : maxColumns;
        final cols = math.min(effectiveMaxCols, math.max(1, cards.length));
        final tileW = math.min(
          (constraints.maxWidth - (cols - 1) * gap) / cols,
          104.0,
        );
        final rows = <Widget>[];
        for (var r = 0; r * cols < cards.length; r++) {
          final start = r * cols;
          final end = math.min(start + cols, cards.length);
          final slice = cards.sublist(start, end);
          rows.add(
            Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  for (var i = 0; i < slice.length; i++) ...[
                    SizedBox(width: tileW, child: slice[i]),
                    if (i < slice.length - 1) SizedBox(width: gap),
                  ],
                ],
              ),
            ),
          );
          if (end < cards.length) rows.add(const SizedBox(height: 12));
        }
        return Column(children: rows);
      },
    );
  }
}

// ─── 7. SWITCH ROW ────────────────────────────────────────────────────────────
class VVSwitchRow extends StatelessWidget {
  final String label;
  final String tooltip;
  final bool value;
  final Color accent;
  final bool isPackWide;
  final bool isExperimental;
  final ValueChanged<bool> onChanged;

  const VVSwitchRow({
    super.key,
    required this.label,
    required this.tooltip,
    required this.value,
    this.accent = kVVPrimary,
    this.isPackWide = false,
    this.isExperimental = false,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: GestureDetector(
        onTap: () => onChanged(!value),
        behavior: HitTestBehavior.opaque,
        child: VVPixelBox(
          fillColor: kVVCard,
          borderColor: kVVBorder,
          borderWidth: 1.2,
          step: 2.5,
          hasShadow: false,
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          child: Row(
            children: [
              Expanded(
                child: _buildRowTitleBlock(
                  label: label,
                  tooltip: tooltip,
                  isPackWide: isPackWide,
                  isExperimental: isExperimental,
                ),
              ),
              const SizedBox(width: 8),
              Switch(
                value: value,
                onChanged: onChanged,
                activeThumbColor: accent,
                activeTrackColor: accent.withValues(alpha: 0.38),
                inactiveThumbColor: Colors.white54,
                inactiveTrackColor: kVVSurface,
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── 8. CHIP SELECTOR ─────────────────────────────────────────────────────────
class VVChipSelector<T> extends StatelessWidget {
  final String label;
  final String? tooltip;
  final List<({T value, String label})> options;
  final T selected;
  final Color accent;
  final bool isPackWide;
  final bool isExperimental;
  final ValueChanged<T> onSelected;

  const VVChipSelector({
    super.key,
    required this.label,
    this.tooltip,
    required this.options,
    required this.selected,
    this.accent = kVVPrimary,
    this.isPackWide = false,
    this.isExperimental = false,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildRowTitleBlock(
            label: label,
            tooltip: tooltip,
            isPackWide: isPackWide,
            isExperimental: isExperimental,
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: options.map((opt) {
              final isSelected = opt.value == selected;
              return GestureDetector(
                onTap: () => onSelected(opt.value),
                behavior: HitTestBehavior.opaque,
                child: VVPixelBox(
                  fillColor: isSelected
                      ? accent.withValues(alpha: 0.18)
                      : kVVCard,
                  borderColor: isSelected ? accent : kVVBorder,
                  borderWidth: isSelected ? 1.5 : 1.1,
                  step: 2.0,
                  hasShadow: false,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  child: Text(
                    opt.label,
                    style: TextStyle(
                      color: isSelected ? accent : Colors.white70,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

// ─── 9. UNDO / REDO HISTORY CONTROLLER ────────────────────────────────────────
class VVUndoHistory<T> {
  final int maxHistory;
  final List<T> _undoStack = <T>[];
  final List<T> _redoStack = <T>[];

  VVUndoHistory({this.maxHistory = 40});

  bool get canUndo => _undoStack.isNotEmpty;
  bool get canRedo => _redoStack.isNotEmpty;

  void _pushBounded(List<T> stack, T state) {
    if (maxHistory <= 0) return;
    if (stack.length >= maxHistory) {
      stack.removeAt(0);
    }
    stack.add(state);
  }

  void record(T previousState) {
    _pushBounded(_undoStack, previousState);
    _redoStack.clear();
  }

  T? undo(T current) {
    if (_undoStack.isEmpty) return null;
    final previous = _undoStack.removeLast();
    _pushBounded(_redoStack, current);
    return previous;
  }

  T? redo(T current) {
    if (_redoStack.isEmpty) return null;
    final next = _redoStack.removeLast();
    _pushBounded(_undoStack, current);
    return next;
  }

  void clear() {
    _undoStack.clear();
    _redoStack.clear();
  }
}

// ─── 10. PACK ICON NORMALIZER ─────────────────────────────────────────────────
Future<Uint8List> normalizePackIconPng(
  Uint8List rawBytes, {
  int targetSize = 256,
}) async {
  if (rawBytes.isEmpty || targetSize <= 0) return rawBytes;
  ui.Codec? codec;
  ui.Image? srcImage;
  ui.Image? outImage;
  try {
    codec = await ui.instantiateImageCodec(rawBytes);
    final frame = await codec.getNextFrame();
    srcImage = frame.image;

    final int srcW = srcImage.width;
    final int srcH = srcImage.height;
    if (srcW <= 0 || srcH <= 0) return rawBytes;

    final int side = math.min(srcW, srcH);
    final double srcLeft = (srcW - side) / 2.0;
    final double srcTop = (srcH - side) / 2.0;
    final Rect srcRect = Rect.fromLTWH(
      srcLeft,
      srcTop,
      side.toDouble(),
      side.toDouble(),
    );
    final Rect dstRect = Rect.fromLTWH(
      0,
      0,
      targetSize.toDouble(),
      targetSize.toDouble(),
    );

    final recorder = ui.PictureRecorder();
    final canvas = ui.Canvas(recorder, dstRect);
    final paint = ui.Paint()
      ..filterQuality = ui.FilterQuality.high
      ..isAntiAlias = true;
    canvas.drawImageRect(srcImage, srcRect, dstRect, paint);

    final picture = recorder.endRecording();
    outImage = await picture.toImage(targetSize, targetSize);
    picture.dispose();

    final ByteData? pngData = await outImage.toByteData(
      format: ui.ImageByteFormat.png,
    );
    if (pngData == null) return rawBytes;
    return pngData.buffer.asUint8List();
  } catch (_) {
    return rawBytes;
  } finally {
    outImage?.dispose();
    srcImage?.dispose();
    codec?.dispose();
  }
}
