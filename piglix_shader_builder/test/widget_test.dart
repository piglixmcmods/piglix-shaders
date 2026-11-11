import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:piglix_shader_builder/main.dart';
import 'package:piglix_shader_builder/new_ui.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const PiglixProApp());
    await tester.pump();
    expect(find.byType(PiglixHomeScreen), findsOneWidget);
    expect(find.text('SHADER NAME'), findsOneWidget);
    expect(find.text('PACK ICON'), findsOneWidget);
  });

  testWidgets('ShaderEditorScreen context-aware parameters and dark theme test', (
    WidgetTester tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(800, 1200));

    await tester.pumpWidget(
      const MaterialApp(
        home: ShaderEditorScreen(
          uploadedShaderBytes: null,
          uploadedShaderName: null,
          uploadedLogoBytes: null,
          shaderName: 'Test Shader',
        ),
      ),
    );
    await tester.pump();

    // Verify initial active tab is Morning / Dawn
    expect(find.text('Rising Sun Scale'), findsOneWidget);
    expect(find.text('Morning Horizon Fog'), findsOneWidget);
    expect(find.text('Sunrise God Rays'), findsOneWidget);

    // Verify redundant segment bar pills are NOT present
    expect(find.text('🌅 Dawn'), findsNothing);
    expect(find.text('☀️ Noon'), findsNothing);
    expect(find.text('🌇 Sunset'), findsNothing);
    expect(find.text('🌙 Night'), findsNothing);

    // Tap 'Night' tile to switch to Night context
    final nightTile = find.text('Night');
    expect(nightTile, findsOneWidget);
    await tester.tap(nightTile);
    await tester.pump();

    // Verify Night context parameters: Moon Scale, Night Vision Boost, Moonlight Beams
    expect(find.text('Moon Scale'), findsOneWidget);
    expect(find.text('Night Vision Boost'), findsOneWidget);
    expect(find.text('Starry Sky & Night Fog'), findsOneWidget);
    expect(find.text('Moonlight Beams (Rays)'), findsOneWidget);
    // Sun Size should NOT be shown during Night!
    expect(find.text('Sun Size'), findsNothing);
    expect(find.text('Rising Sun Scale'), findsNothing);
    expect(find.text('Midday Sun Scale'), findsNothing);

    // Tap 'Evening' tile to switch to Evening context
    final eveningTile = find.text('Evening');
    expect(eveningTile, findsOneWidget);
    await tester.tap(eveningTile);
    await tester.pump();

    // Verify Evening context parameters: Sunset Sun Scale, Twilight Horizon Fog, Twilight God Rays
    expect(find.text('Sunset Sun Scale'), findsOneWidget);
    expect(find.text('Twilight Horizon Fog'), findsOneWidget);
    expect(find.text('Twilight God Rays'), findsOneWidget);

    // Tap 'Noon' tile to switch to Noon context
    final noonTile = find.text('Noon');
    expect(noonTile, findsOneWidget);
    await tester.tap(noonTile);
    await tester.pump();

    // Verify Noon context parameters: Midday Sun Scale, Overworld Fog Density, Daylight Brightness
    expect(find.text('Midday Sun Scale'), findsOneWidget);
    expect(find.text('Overworld Fog Density'), findsOneWidget);
    expect(find.text('Daylight Brightness'), findsOneWidget);
  });

  testWidgets(
    'ShaderEditorScreen top bar spacing, warm orange morning palette and 1-tap color badge test',
    (WidgetTester tester) async {
      await tester.binding.setSurfaceSize(const Size(800, 1200));

      await tester.pumpWidget(
        const MaterialApp(
          home: ShaderEditorScreen(
            uploadedShaderBytes: null,
            uploadedShaderName: null,
            uploadedLogoBytes: null,
            shaderName: 'Test Shader',
          ),
        ),
      );
      await tester.pump();

      // 1. Verify Top Bar Spacing: Shader Name and Pack Icon are both present
      expect(find.text('Test Shader'), findsOneWidget);
      expect(find.text('Pack Icon'), findsOneWidget);

      // 2. Verify Atmosphere Preview Banner badge
      expect(find.text('ATMOSPHERE PREVIEW'), findsOneWidget);

      // 3. Verify Morning Warm Sunrise Orange (#FFA040) Color Badge Button
      expect(find.text('#FFA040'), findsOneWidget);

      // 4. Tap the Morning color badge button to test 1-tap color picker opening
      final morningBadge = find.text('#FFA040');
      expect(morningBadge, findsOneWidget);
      await tester.tap(morningBadge);
      await tester.pumpAndSettle();

      // Verify Color Picker dialog opened in ONE tap (no double click needed)
      expect(find.text('COLOR CRAFTING'), findsOneWidget);
      expect(find.text('CURATED MORNING PALETTE'), findsOneWidget);
    },
  );

  testWidgets(
    'MinecraftColorTile long-press and re-tap open color crafter, and top bar ? opens guide',
    (WidgetTester tester) async {
      await tester.binding.setSurfaceSize(const Size(800, 1200));

      await tester.pumpWidget(const PiglixProApp());
      await tester.pump();

      // Verify no onboarding dialog is shown automatically at startup
      expect(find.text('WELCOME TO PIGLIX SHADER BUILDER'), findsNothing);

      // Tap help / guide ? icon button in top bar to open guide
      final helpButton = find.byIcon(Icons.help_outline_rounded);
      expect(helpButton, findsOneWidget);
      await tester.tap(helpButton);
      await tester.pump(const Duration(milliseconds: 600));

      // Guide dialog should now be visible
      expect(find.text('WELCOME TO PIGLIX SHADER BUILDER'), findsOneWidget);
      // Close guide bottom sheet
      Navigator.pop(
        tester.element(find.text('WELCOME TO PIGLIX SHADER BUILDER')),
      );
      await tester.pump(const Duration(milliseconds: 600));
      expect(find.text('WELCOME TO PIGLIX SHADER BUILDER'), findsNothing);

      // Open editor directly via widget
      await tester.pumpWidget(
        const MaterialApp(
          home: ShaderEditorScreen(
            uploadedShaderBytes: null,
            uploadedShaderName: null,
            uploadedLogoBytes: null,
            shaderName: 'Test Shader',
          ),
        ),
      );
      await tester.pump();

      // Long press on Noon tile to open color picker directly
      final noonTile = find.text('Noon');
      expect(noonTile, findsOneWidget);
      await tester.longPress(noonTile);
      await tester.pumpAndSettle();
      expect(find.text('COLOR CRAFTING'), findsOneWidget);
      expect(find.text('NOON'), findsOneWidget);
    },
  );
}
