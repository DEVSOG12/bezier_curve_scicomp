import 'package:bezier_curve_scicomp/src/math/bezier_computation.dart';
import 'package:bezier_curve_scicomp/src/math/models/points.dart';


class BezierCurve {
  final Points p1; // Start point
  final Points p2; // Control point 1
  final Points p3; // Control point 2
  final Points p4; // End point

  late BezierComputation _bezierComputation;

  BezierCurve(this.p1, this.p2, this.p3, this.p4) {
    _bezierComputation = BezierComputation(p1, p2, p3, p4);
  }

  // Method to evaluate the curve at a given t (0 <= t <= 1)
  Points evaluate(double t) {
    return _bezierComputation.calculatePoint(t);
  }

  // Generate multiple points along the curve
  List<Points> generateCurvePoints({int numPoints = 100}) {
    List<Points> points = [];
    for (int i = 0; i <= numPoints; i++) {
      double t = i / numPoints;
      points.add(evaluate(t));
    }
    return points;
  }

  // Update control points and recalculate coefficients
  void updateControlPoints(Points newP2, Points newP3) {
    _bezierComputation = BezierComputation(p1, newP2, newP3, p4);
  }
}
