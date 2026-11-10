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

  testWidgets('ShaderEditorScreen context-aware parameters and dark theme test',
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

    // Verify initial active tab is Morning / Dawn
    expect(find.text('Dawn Sun Size'), findsOneWidget);
    expect(find.text('Dawn Fog Density'), findsOneWidget);
    expect(find.text('Sunrise Ray Glow'), findsOneWidget);

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

    // Verify Night context parameters: Moon Size, Night Brightness, Moonlight God Rays
    expect(find.text('Moon Size'), findsOneWidget);
    expect(find.text('Night Brightness'), findsOneWidget);
    expect(find.text('Night Fog & Stars'), findsOneWidget);
    expect(find.text('Moonlight God Rays'), findsOneWidget);
    // Sun Size should NOT be shown during Night!
    expect(find.text('Sun Size'), findsNothing);
    expect(find.text('Dawn Sun Size'), findsNothing);
    expect(find.text('Midday Sun Size'), findsNothing);

    // Tap 'Evening' tile to switch to Evening context
    final eveningTile = find.text('Evening');
    expect(eveningTile, findsOneWidget);
    await tester.tap(eveningTile);
    await tester.pump();

    // Verify Evening context parameters: Sunset Sun Size, Twilight Fog, Twilight Rays
    expect(find.text('Sunset Sun Size'), findsOneWidget);
    expect(find.text('Sunset Fog Density'), findsOneWidget);
    expect(find.text('Twilight Rays Intensity'), findsOneWidget);

    // Tap 'Noon' tile to switch to Noon context
    final noonTile = find.text('Noon');
    expect(noonTile, findsOneWidget);
    await tester.tap(noonTile);
    await tester.pump();

    // Verify Noon context parameters: Midday Sun Size, Midday Fog Density, Sunlight Illuminance
    expect(find.text('Midday Sun Size'), findsOneWidget);
    expect(find.text('Midday Fog Density'), findsOneWidget);
    expect(find.text('Sunlight Illuminance'), findsOneWidget);
  });

  testWidgets('ShaderEditorScreen top bar spacing, warm orange morning palette and 1-tap color badge test',
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

    // 2. Verify Procedural Scene Engine Pill in Atmosphere Preview Banner
    expect(find.text('REAL-TIME CODE ENGINE'), findsOneWidget);

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
  });
}
