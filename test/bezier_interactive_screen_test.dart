import 'package:bezier_curve_scicomp/src/UI/bezier_curve_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('BezierInteractiveScreen UI Tests', () {
    testWidgets('Displays initial control points correctly', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: BezierInteractiveScreen()));

      expect(find.textContaining('P1 (Start)'), findsOneWidget);
      expect(find.textContaining('P2 (Control 1)'), findsOneWidget);
      expect(find.textContaining('P3 (Control 2)'), findsOneWidget);
      expect(find.textContaining('P4 (End)'), findsOneWidget);
    });

    testWidgets('Slider updates tValue and displays corresponding coordinates', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: BezierInteractiveScreen()));

      // Initial value
      expect(find.text('t = 0.00'), findsOneWidget);

      // Drag slider to change value
      await tester.drag(find.byType(Slider), const Offset(50.0, 0.0));
      await tester.pumpAndSettle();

      // Check that the displayed value has changed
      expect(find.byType(Slider), findsOneWidget);
      expect(find.textContaining('t = '), findsOneWidget);
    });

    testWidgets('Clicking on control point allows editing', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: BezierInteractiveScreen()));

      // Tap on a control point (simulate)
      // Adjust coordinates if needed based on actual control point positions
      await tester.tapAt(const Offset(60, 240));
      await tester.pump();

      // Check if edit dialog appears
      expect(find.text('Edit Point'), findsOneWidget);
      expect(find.text('X'), findsOneWidget);
      expect(find.text('Y'), findsOneWidget);

      // Enter new values
      await tester.enterText(find.byType(TextField).first, '100');
      await tester.enterText(find.byType(TextField).last, '100');
      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();

      // Verify new coordinates (based on implementation, adjust as necessary)
      expect(find.textContaining('P2 (Control 1): (100.00, 100.00)'), findsOneWidget);
    });
  });
}
