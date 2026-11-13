import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:piglix_shader_builder/shader_presets.dart';
import 'package:piglix_shader_builder/vv_config.dart';
import 'package:piglix_shader_builder/vv_shader_editor.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    final preset = kDefaultShaderPresets.firstWhere((p) => p.id == 'pink_atmosphere');
    await getOrGeneratePresetPackIcon(preset);
    await generateShaderItemPackIcon('My Custom Shader', const Color(0xFF22C55E));
    await generateShaderItemPackIcon('Gallery RTX Pack', const Color(0xFFF472B6));
  });

  group('Preset and Gallery Edit Flow Tests', () {
    test('getOrGeneratePresetPackIcon generates valid cached PNG bytes for presets', () async {
      final preset = kDefaultShaderPresets.firstWhere((p) => p.id == 'pink_atmosphere');
      final bytes = await getOrGeneratePresetPackIcon(preset);
      expect(bytes, isNotNull);
      expect(bytes.isNotEmpty, isTrue);

      // Verify PNG magic header 0x89, 'P', 'N', 'G'
      expect(bytes[0], 0x89);
      expect(bytes[1], 0x50);
      expect(bytes[2], 0x4E);
      expect(bytes[3], 0x47);

      // Verify second call is cached
      final cachedBytes = await getOrGeneratePresetPackIcon(preset);
      expect(identical(bytes, cachedBytes), isTrue);
    });

    test('generateShaderItemPackIcon generates valid cached PNG bytes for gallery items', () async {
      final bytes = await generateShaderItemPackIcon('My Custom Shader', const Color(0xFF22C55E));
      expect(bytes, isNotNull);
      expect(bytes.isNotEmpty, isTrue);
      expect(bytes[0], 0x89);
      expect(bytes[1], 0x50);
      expect(bytes[2], 0x4E);
      expect(bytes[3], 0x47);
    });

    testWidgets('ShaderEditorScreen top bar displays both pack name and package image cleanly on 360px screen',
        (WidgetTester tester) async {
      // Set to standard narrow mobile screen size (360 x 740)
      tester.view.physicalSize = const Size(360, 740);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final preset = kDefaultShaderPresets.firstWhere((p) => p.id == 'pink_atmosphere');
      final presetIcon = await getOrGeneratePresetPackIcon(preset);

      await tester.pumpWidget(
        MaterialApp(
          home: ShaderEditorScreen(
            uploadedShaderBytes: null,
            uploadedShaderName: null,
            uploadedLogoBytes: presetIcon,
            shaderName: preset.name,
            presetConfig: preset,
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // 1. Pack name must be rendered and visible in top bar
      expect(find.text(preset.name), findsOneWidget);

      // 2. Package image button must exist and contain an Image widget
      final packIconBtn = find.byKey(const Key('vv_pack_icon_btn'));
      expect(packIconBtn, findsOneWidget);
      expect(
        find.descendant(of: packIconBtn, matching: find.byType(Image)),
        findsOneWidget,
      );

      // 3. Rename button must exist
      final packNameBtn = find.byKey(const Key('vv_pack_name_btn'));
      expect(packNameBtn, findsOneWidget);

      // 4. Action buttons exist and have compact footprint
      expect(find.byKey(const Key('vv_undo_btn')), findsOneWidget);
      expect(find.byKey(const Key('vv_redo_btn')), findsOneWidget);
      expect(find.byKey(const Key('vv_reset_tab_btn')), findsOneWidget);

      // 5. Tapping rename button opens rename dialog
      await tester.tap(packNameBtn);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.text('Pack Shader Name'), findsOneWidget);
      expect(find.text('Save'), findsOneWidget);

      // Dismiss dialog
      await tester.tap(find.text('Cancel'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.text('Pack Shader Name'), findsNothing);
    });

    testWidgets('Opening from Gallery loads initialVVConfig parameters and displays pack name and icon',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      const customName = 'Gallery RTX Pack';
      final customConfig = const VVShaderConfig().copyWith(
        packName: customName,
        atmosphere: const AtmosphereConfig().copyWith(rayleighNoon: 5.5),
      );
      final customIcon = await generateShaderItemPackIcon(customName, const Color(0xFFF472B6));

      await tester.pumpWidget(
        MaterialApp(
          home: ShaderEditorScreen(
            uploadedShaderBytes: null,
            uploadedShaderName: '$customName.mcpack',
            uploadedLogoBytes: customIcon,
            shaderName: customName,
            initialVVConfig: customConfig,
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text(customName), findsOneWidget);
      expect(find.byKey(const Key('vv_pack_icon_btn')), findsOneWidget);
      expect(find.byKey(const Key('vv_pack_name_btn')), findsOneWidget);
    });

    testWidgets('Tapping Home button when preset is loaded displays Discard or Keep Editing dialog',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final preset = kDefaultShaderPresets.firstWhere((p) => p.id == 'pink_atmosphere');
      final presetIcon = await getOrGeneratePresetPackIcon(preset);

      bool popped = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Navigator(
            onGenerateRoute: (settings) => MaterialPageRoute(
              builder: (context) => Scaffold(
                body: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ShaderEditorScreen(
                          uploadedShaderBytes: null,
                          uploadedShaderName: null,
                          uploadedLogoBytes: presetIcon,
                          shaderName: preset.name,
                          presetConfig: preset,
                        ),
                      ),
                    ).then((_) => popped = true);
                  },
                  child: const Text('Open'),
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pump();
      await tester.tap(find.text('Open'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      // In the editor: tap Home button
      final homeBtn = find.byKey(const Key('vv_home_btn'));
      expect(homeBtn, findsOneWidget);
      await tester.tap(homeBtn);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      // Verify the Discard Edits dialog is shown with both options
      expect(find.text('Discard Edits?'), findsOneWidget);
      expect(find.text('Keep Editing'), findsOneWidget);
      expect(find.text('Discard'), findsOneWidget);

      // Tap 'Keep Editing' -> Dialog dismissed, user stays in editor
      await tester.tap(find.byKey(const Key('vv_discard_keep_btn')));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('Discard Edits?'), findsNothing);
      expect(find.text(preset.name), findsOneWidget);
      expect(popped, isFalse);

      // Tap Home button again -> Discard
      await tester.tap(homeBtn);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.text('Discard Edits?'), findsOneWidget);

      await tester.tap(find.byKey(const Key('vv_discard_confirm_btn')));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(popped, isTrue);
    });

    testWidgets('VVCompileProgressDialog renders authentic Minecraft block, XP bar, status & tips',
        (WidgetTester tester) async {
      final completer = Completer<void>();
      late ValueNotifier<double> testProgress;
      late ValueNotifier<String> testStatus;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: VVCompileProgressDialog(
              onCompile: (p, s) async {
                testProgress = p;
                testStatus = s;
                await completer.future;
              },
            ),
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // 1. Heading in Mojang font exists
      expect(find.text('BUILDING SHADER PACK'), findsOneWidget);

      // 2. Minecraft Tip exists
      expect(find.text('MINECRAFT TIP'), findsOneWidget);

      // 3. Custom paints for 3D block and XP bar exist
      expect(find.byType(CustomPaint), findsWidgets);

      // 4. Update status & progress
      testStatus.value = 'Compressing .mcpack archive';
      testProgress.value = 0.75;
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));

      expect(find.textContaining('Compressing .mcpack archive'), findsOneWidget);
      expect(find.text('75%'), findsOneWidget);

      // Finish compile and tear down
      completer.complete();
      await tester.pump();
    });
  });
}
