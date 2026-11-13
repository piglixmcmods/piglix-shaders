import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:piglix_shader_builder/main.dart';
import 'package:piglix_shader_builder/new_ui.dart';
import 'package:piglix_shader_builder/shader_presets.dart';
import 'package:piglix_shader_builder/vv_config.dart';
import 'package:piglix_shader_builder/vv_editor_widgets.dart';
import 'package:piglix_shader_builder/vv_tab_previews.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const PiglixProApp());
    await tester.pump();
    expect(find.byType(PiglixHomeScreen), findsOneWidget);
    expect(find.text('SHADER NAME'), findsOneWidget);
    expect(find.text('PACK ICON'), findsOneWidget);
  });

  group('ShaderEditorScreen VV rebuild tests', () {
    Future<void> pumpEditor(
      WidgetTester tester, {
      ShaderPresetConfig? presetConfig,
      VVShaderConfig? initialVVConfig,
      String? migrationNotice,
    }) async {
      tester.view.physicalSize = const Size(1280, 1400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        MaterialApp(
          home: ShaderEditorScreen(
            uploadedShaderBytes: null,
            uploadedShaderName: null,
            uploadedLogoBytes: null,
            shaderName: 'Test VV Pack',
            presetConfig: presetConfig,
            initialVVConfig: initialVVConfig,
            migrationNotice: migrationNotice,
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
    }

    Future<void> selectTab(WidgetTester tester, int index) async {
      final tab = find.byKey(Key('vv_tab_$index'));
      await tester.ensureVisible(tab);
      await tester.tap(tab);
      await tester.pumpAndSettle();
    }

    Finder switchForLabel(String label) {
      final vvSwitch = find.ancestor(
        of: find.text(label),
        matching: find.byType(VVSwitchRow),
      );
      if (vvSwitch.evaluate().isNotEmpty) {
        return find.descendant(
          of: vvSwitch.first,
          matching: find.byType(Switch),
        );
      }
      final ancestorRows = find.ancestor(
        of: find.text(label),
        matching: find.byType(Row),
      );
      for (final rowEl in ancestorRows.evaluate()) {
        final sw = find.descendant(
          of: find.byWidget(rowEl.widget),
          matching: find.byType(Switch),
        );
        if (sw.evaluate().length == 1) {
          return sw;
        }
      }
      return find.descendant(
        of: ancestorRows.first,
        matching: find.byType(Switch),
      );
    }

    testWidgets('renders all 9 tabs (vv_tab_0..vv_tab_8) and navigates between them',
        (WidgetTester tester) async {
      await pumpEditor(tester);

      const expectedSectionTitles = <String>[
        'Time of Day',
        'Light Source',
        'Fog Type',
        'Water Biomes',
        'Visual Mood',
        'Override Layer',
        'Surface Finish',
        'Quality Tiers',
        'Pack Identity',
      ];

      for (var i = 0; i < 9; i++) {
        expect(find.byKey(Key('vv_tab_$i')), findsOneWidget);
      }

      for (var i = 0; i < expectedSectionTitles.length; i++) {
        await selectTab(tester, i);
        expect(find.text(expectedSectionTitles[i]), findsOneWidget);
      }
    });

    testWidgets('Collapsible Advanced section hides and reveals Advanced controls',
        (WidgetTester tester) async {
      await pumpEditor(tester);

      // Advanced sections start collapsed.
      expect(find.text('Auto-derive Zenith from Horizon'), findsNothing);

      final skyAdvHeader = find.text('Advanced');
      await tester.ensureVisible(skyAdvHeader);
      await tester.tap(skyAdvHeader);
      await tester.pumpAndSettle();

      expect(find.text('Auto-derive Zenith from Horizon'), findsOneWidget);

      // Check another tab's Advanced collapsible section: expand then collapse.
      await selectTab(tester, 4);
      expect(find.text('Color Temperature Enabled'), findsNothing);

      final colorAdvHeader = find.text('Advanced');
      await tester.ensureVisible(colorAdvHeader);
      await tester.tap(colorAdvHeader);
      await tester.pumpAndSettle();
      expect(find.text('Color Temperature Enabled'), findsOneWidget);

      await tester.ensureVisible(colorAdvHeader);
      await tester.tap(colorAdvHeader);
      await tester.pumpAndSettle();
      expect(find.text('Color Temperature Enabled'), findsNothing);
    });

    testWidgets('Undo, Redo, and Reset tab update config state correctly',
        (WidgetTester tester) async {
      await pumpEditor(tester);
      await selectTab(tester, 3); // Water tab

      final wavesSwitchFinder = switchForLabel('Waves Enabled');
      await tester.ensureVisible(wavesSwitchFinder);
      expect(tester.widget<Switch>(wavesSwitchFinder).value, isTrue);

      // Mutate Waves Enabled -> false
      await tester.tap(wavesSwitchFinder);
      await tester.pump();
      expect(tester.widget<Switch>(wavesSwitchFinder).value, isFalse);

      // Undo -> back to true
      await tester.tap(find.byKey(const Key('vv_undo_btn')));
      await tester.pump();
      expect(tester.widget<Switch>(wavesSwitchFinder).value, isTrue);

      // Redo -> back to false
      await tester.tap(find.byKey(const Key('vv_redo_btn')));
      await tester.pump();
      expect(tester.widget<Switch>(wavesSwitchFinder).value, isFalse);

      // Reset tab -> restores default true and shows confirmation snackbar
      await tester.tap(find.byKey(const Key('vv_reset_tab_btn')));
      await tester.pump();
      expect(tester.widget<Switch>(wavesSwitchFinder).value, isTrue);
      expect(find.text('Reset Water to defaults'), findsOneWidget);
    });

    testWidgets('Lighting tab displays live point-light counter and >20 GPU warning',
        (WidgetTester tester) async {
      await pumpEditor(tester);
      await selectTab(tester, 1); // Light & Shadows tab

      // Switch to Block Lights mode card to view point-light toggles & counter.
      final blockLightsCard = find.text('Block Lights');
      await tester.ensureVisible(blockLightsCard);
      await tester.tap(blockLightsCard);
      await tester.pumpAndSettle();

      // Default config has 32 active point-light blocks (>20).
      expect(find.text('32 / 31 point-light blocks active'), findsOneWidget);
      expect(
        find.text('High point-light count (>20) may lag mobile GPUs'),
        findsOneWidget,
      );

      // Disable Torches (9 blocks -> 23) and Copper (6 blocks -> 17 <= 20).
      final torchesSwitch = switchForLabel('Torches');
      await tester.ensureVisible(torchesSwitch);
      await tester.tap(torchesSwitch);
      await tester.pump();
      expect(find.text('23 / 31 point-light blocks active'), findsOneWidget);
      expect(
        find.text('High point-light count (>20) may lag mobile GPUs'),
        findsOneWidget,
      );

      final copperSwitch = switchForLabel('Copper');
      await tester.ensureVisible(copperSwitch);
      await tester.tap(copperSwitch);
      await tester.pump();
      expect(find.text('17 / 31 point-light blocks active'), findsOneWidget);
      expect(
        find.text('High point-light count (>20) may lag mobile GPUs'),
        findsNothing,
      );
    });

    testWidgets('Pack-wide and Experimental badges appear on marked controls',
        (WidgetTester tester) async {
      await pumpEditor(tester);

      // Tab 1 (Light & Shadows): Orbital Tilt Angle has both Pack-wide and Experimental.
      await selectTab(tester, 1);
      expect(find.text('Orbital Tilt Angle'), findsOneWidget);
      expect(find.text('Pack-wide'), findsWidgets);
      expect(find.text('Experimental'), findsWidgets);

      // Tab 3 (Water): Waves Enabled has Pack-wide.
      await selectTab(tester, 3);
      expect(find.text('Waves Enabled'), findsOneWidget);
      expect(find.text('Pack-wide'), findsWidgets);

      // Tab 4 (Color & Mood): Tone Mapping Operator has Pack-wide.
      await selectTab(tester, 4);
      expect(find.text('Tone Mapping Operator'), findsOneWidget);
      expect(find.text('Pack-wide'), findsWidgets);
    });

    testWidgets('Legacy ShaderPresetConfig triggers migration notice snackbar',
        (WidgetTester tester) async {
      await pumpEditor(tester, presetConfig: kDefaultShaderPresets.first);

      expect(
        find.textContaining('settings are no longer supported'),
        findsOneWidget,
      );
    });

    testWidgets('Export tab renders Validation Report and Recommended In-Game Settings',
        (WidgetTester tester) async {
      // With <= 20 point-light blocks, Validation Report shows all checks passed.
      const cleanCfg = VVShaderConfig(
        lighting: LightingConfig(
          torches: BlockLightGroup(
            color: Color(0xFFFF8C32),
            lightType: 'static_light',
          ),
          copper: BlockLightGroup(
            color: Color(0xFFB8EF8D),
            lightType: 'static_light',
          ),
        ),
      );
      await pumpEditor(tester, initialVVConfig: cleanCfg);
      await selectTab(tester, 8); // Export tab

      expect(find.text('Validation Report'), findsOneWidget);
      expect(
        find.text('All schema, biome, and pack-wide checks passed!'),
        findsOneWidget,
      );

      final recCard = find.text('Recommended In-Game Settings');
      await tester.ensureVisible(recCard);
      expect(recCard, findsOneWidget);
    });

    testWidgets('Sky tab switches large single-scene preview cleanly without text badges',
        (WidgetTester tester) async {
      await pumpEditor(tester);

      // Default Noon single detailed preview renders without split columns or text badges.
      expect(find.text('Noon Sky Settings'), findsOneWidget);
      expect(find.text('SKY · MORNING TO NIGHT'), findsNothing);
      expect(find.byKey(const Key('vv_sky_strip_0')), findsNothing);

      // Tapping Morning, Evening, Night square cards updates active Sky Settings & preview.
      await tester.tap(find.text('Morning'));
      await tester.pumpAndSettle();
      expect(find.text('Morning Sky Settings'), findsOneWidget);

      await tester.tap(find.text('Evening'));
      await tester.pumpAndSettle();
      expect(find.text('Evening Sky Settings'), findsOneWidget);

      await tester.tap(find.text('Night'));
      await tester.pumpAndSettle();
      expect(find.text('Night Sky Settings'), findsOneWidget);
    });

    testWidgets('Light tab preview responds to Sunlight phases, Cave, and Block Light items',
        (WidgetTester tester) async {
      await pumpEditor(tester);
      await selectTab(tester, 1); // Light & Shadows tab

      VVLightingPreviewBanner banner() =>
          tester.widget<VVLightingPreviewBanner>(find.byType(VVLightingPreviewBanner));

      expect(banner().mode, 0);
      expect(banner().sunPhase, 0);

      // Sun Color Time switches phase cleanly
      await tester.tap(find.text('Evening'));
      await tester.pumpAndSettle();
      expect(banner().sunPhase, 1);

      await tester.tap(find.text('Morning'));
      await tester.pumpAndSettle();
      expect(banner().sunPhase, 2);

      await tester.tap(find.text('Night'));
      await tester.pumpAndSettle();
      expect(banner().sunPhase, 3);

      // Cave mode
      await tester.tap(find.text('Cave'));
      await tester.pumpAndSettle();
      expect(banner().mode, 1);
      expect(find.text('Cave Brightness'), findsOneWidget);

      // Block Lights mode + selecting Torch / Lanterns / Soul Fire / Candles
      await tester.tap(find.text('Block Lights'));
      await tester.pumpAndSettle();
      expect(banner().mode, 2);

      for (final entry in const [
        (label: 'Lanterns', idx: 1),
        (label: 'Soul Fire', idx: 2),
        (label: 'Candles', idx: 3),
        (label: 'Torches', idx: 0),
      ]) {
        final item = find.text(entry.label);
        await tester.ensureVisible(item);
        await tester.tap(item);
        await tester.pumpAndSettle();
        expect(banner().activeLightGroupIndex, entry.idx);
      }
    });
  });
}
