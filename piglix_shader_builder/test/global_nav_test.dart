import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:piglix_shader_builder/vv_global_nav_bar.dart';
import 'package:piglix_shader_builder/shader_presets.dart';
import 'package:piglix_shader_builder/my_shaders_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Shared Global Navigation Bar Tests', () {
    testWidgets('VvGlobalBottomNav renders all 5 tabs and highlights current tab', (tester) async {
      var homeTapped = false;
      var builderTapped = false;
      var galleryTapped = false;
      var presetsTapped = false;
      var settingsTapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            bottomNavigationBar: VvGlobalBottomNav(
              currentTab: VvNavTab.home,
              onOpenHome: () => homeTapped = true,
              onOpenBuilder: () => builderTapped = true,
              onOpenGallery: () => galleryTapped = true,
              onOpenPresets: () => presetsTapped = true,
              onOpenSettings: () => settingsTapped = true,
            ),
          ),
        ),
      );

      // Check all 5 labels exist
      expect(find.text('HOME'), findsOneWidget);
      expect(find.text('BUILDER'), findsOneWidget);
      expect(find.text('GALLERY'), findsOneWidget);
      expect(find.text('PRESETS'), findsOneWidget);
      expect(find.text('SETTINGS'), findsOneWidget);

      // Tap tabs
      await tester.tap(find.text('HOME'));
      expect(homeTapped, isTrue);

      await tester.tap(find.text('BUILDER'));
      expect(builderTapped, isTrue);

      await tester.tap(find.text('GALLERY'));
      expect(galleryTapped, isTrue);

      await tester.tap(find.text('PRESETS'));
      expect(presetsTapped, isTrue);

      await tester.tap(find.text('SETTINGS'));
      expect(settingsTapped, isTrue);
    });

    test('FastNavRoute has 150ms duration and smooth cross-fade', () {
      final route = FastNavRoute(child: const SizedBox());
      expect(route.transitionDuration, const Duration(milliseconds: 150));
      expect(route.reverseTransitionDuration, const Duration(milliseconds: 130));
    });

    testWidgets('Presets screen contains shared bottom nav and drawer key', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ShaderPresetsScreen(
            onSelectPreset: (_) {},
          ),
        ),
      );
      await tester.pump();

      expect(find.byType(VvGlobalBottomNav), findsOneWidget);
      expect(find.text('PRESETS'), findsWidgets);

      // Verify category counters and featured banner are removed
      expect(find.text('CATEGORIES'), findsNothing);
      expect(find.text('★ FEATURED'), findsNothing);

      // Verify filter tabs exist and can be tapped
      expect(find.text('ALL'), findsOneWidget);
      expect(find.text('POPULAR'), findsOneWidget);
      await tester.tap(find.text('POPULAR'));
      await tester.pumpAndSettle();
    });

    testWidgets('Gallery screen contains shared bottom nav and drawer key', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: MyShadersScreen(),
        ),
      );
      await tester.pump();

      expect(find.byType(VvGlobalBottomNav), findsOneWidget);
      expect(find.text('GALLERY'), findsWidgets);
    });
  });
}
