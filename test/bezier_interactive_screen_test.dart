import 'package:bezier_curve_scicomp/src/UI/bezier_curve_screen.dart';
import 'package:bezier_curve_scicomp/src/math/models/points.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('BezierInteractiveScreen UI Tests', () {
    testWidgets('Displays initial control points correctly',
        (WidgetTester tester) async {
      await tester
          .pumpWidget(const MaterialApp(home: BezierInteractiveScreen()));

      expect(find.textContaining('P1 (Start)'), findsOneWidget);
      expect(find.textContaining('P2 (Control 1)'), findsOneWidget);
      expect(find.textContaining('P3 (Control 2)'), findsOneWidget);
      expect(find.textContaining('P4 (End)'), findsOneWidget);
    });

    testWidgets('Slider updates tValue and displays corresponding coordinates',
        (WidgetTester tester) async {
      await tester
          .pumpWidget(const MaterialApp(home: BezierInteractiveScreen()));

      // Initial value
      expect(find.byKey(const Key('tValueDisplay')), findsOneWidget);
      expect(find.text('t = 0.00'), findsOneWidget);

      // Drag slider to change value
      await tester.drag(find.byType(Slider), const Offset(50.0, 0.0));
      await tester.pumpAndSettle();

      // Drag slider to change value
      await tester.drag(find.byType(Slider), const Offset(50.0, 0.0));
      await tester.pumpAndSettle();

      // Extract the new t value
      final tValueWidget =
          tester.widget<Text>(find.byKey(const Key('tValueDisplay')));
      final tValueString = tValueWidget.data!.replaceAll('t = ', '');
      final tValue = double.parse(tValueString);

      // Check that the t value has changed
      expect(tValue, isNot(0.00));
      expect(tValue, greaterThan(0.00));
      expect(tValue, lessThanOrEqualTo(1.00));
    });
  testWidgets('Clicking on control point allows editing', (WidgetTester tester) async {
  await tester.pumpWidget(const MaterialApp(home: BezierInteractiveScreen()));

  // Find the CustomPaint widget
  final customPaintFinder = find.byType(CustomPaint);
  expect(customPaintFinder, findsOneWidget);

  // Get the RenderBox of the canvas
  final RenderBox canvasBox = tester.firstRenderObject(customPaintFinder);
  final Offset canvasPosition = canvasBox.localToGlobal(Offset.zero);
  final Size canvasSize = canvasBox.size;

  // Helper function to convert logical coordinates to screen coordinates
  Offset logicalToScreen(Points point) {
    final double screenX = canvasPosition.dx + (canvasSize.width / 2) + point.x;
    final double screenY = canvasPosition.dy + (canvasSize.height / 2) - point.y;
    return Offset(screenX, screenY);
  }

  // Control point to test (e.g., control2)
  final Points controlPoint = Points(60, 240);

  // Calculate screen position of the control point
  final Offset controlPointScreenPosition = logicalToScreen(controlPoint);

  // Simulate tap at the control point position
  await tester.tapAt(controlPointScreenPosition);
  await tester.pumpAndSettle();

  // Check if edit dialog appears
  expect(find.text('Edit Point'), findsOneWidget);
  expect(find.text('X'), findsOneWidget);
  expect(find.text('Y'), findsOneWidget);

  // Enter new values
  await tester.enterText(find.byType(TextField).first, '100');
  await tester.enterText(find.byType(TextField).last, '100');
  await tester.tap(find.text('OK'));
  await tester.pumpAndSettle();

  // Verify new coordinates
  expect(
    find.textContaining('P3 (Control 2): (100.00, 100.00)'),
    findsOneWidget,
  );
});

  });
}
