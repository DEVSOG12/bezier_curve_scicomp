import 'package:bezier_curve_scicomp/src/math/bezier/bezier_curve.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bezier_curve_scicomp/src/math/bezier_computation.dart';
import 'package:bezier_curve_scicomp/src/math/models/points.dart';

void main() {
  group('BezierComputation', () {
    test(
        'calculatePoint() should correctly evaluate a point on the curve at t = 0',
        () {
      final Points p1 = Points(0, 0);
      final Points p2 = Points(1, 2);
      final Points p3 = Points(2, 3);
      final Points p4 = Points(4, 0);

      final BezierComputation bezier = BezierComputation(p1, p2, p3, p4);
      final Points result = bezier.calculatePoint(0.0);

      expect(result.x, equals(p1.x));
      expect(result.y, equals(p1.y));
    });

    test(
        'calculatePoint() should correctly evaluate a point on the curve at t = 1',
        () {
      final Points p1 = Points(0, 0);
      final Points p2 = Points(1, 2);
      final Points p3 = Points(2, 3);
      final Points p4 = Points(4, 0);

      final BezierComputation bezier = BezierComputation(p1, p2, p3, p4);
      final Points result = bezier.calculatePoint(1.0);

      expect(result.x, equals(p4.x));
      expect(result.y, equals(p4.y));
    });

    test(
        'calculatePoint() should correctly evaluate a point on the curve at t = 0.5',
        () {
      final Points p1 = Points(0, 0);
      final Points p2 = Points(1, 2);
      final Points p3 = Points(2, 3);
      final Points p4 = Points(4, 0);

      final BezierComputation bezier = BezierComputation(p1, p2, p3, p4);
      final Points result = bezier.calculatePoint(0.5);

      // Values t = 0.5
      expect(result.x, closeTo(1.625, 0.001));
      expect(result.y, closeTo(1.875, 0.001));
    });

    test('BezierCurve should generate a correct number of points', () {
      final Points p1 = Points(0, 0);
      final Points p2 = Points(1, 2);
      final Points p3 = Points(2, 3);
      final Points p4 = Points(4, 0);

      final BezierCurve curve = BezierCurve(p1, p2, p3, p4);
      final List<Points> points = curve.generateCurvePoints(numPoints: 50);

      expect(points.length, equals(51)); // 0 to 50 (inclusive)
    });
  });
}
