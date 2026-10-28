import 'package:flutter_test/flutter_test.dart';
import 'package:piglix_shader_builder/main.dart';
import 'package:piglix_shader_builder/new_ui.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const PiglixProApp());
    // Pump past the splash delay of 1200ms
    await tester.pump(const Duration(milliseconds: 1400));
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.byType(PiglixHomeScreen), findsOneWidget);
  });
}
