// bezier_curve.dart
import 'package:bezier_curve_scicomp/src/math/bezier_computation.dart';
import 'package:bezier_curve_scicomp/src/math/models/points.dart';

class BezierCurve {
  final List<Points> controlPoints;
  late BezierComputation _bezierComputation;

  BezierCurve(this.controlPoints) {
    _bezierComputation = BezierComputation(controlPoints);
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

  // Add a control point and update computation
  void addControlPoint(Points point) {
    controlPoints.add(point);
    _bezierComputation = BezierComputation(controlPoints);
  }

  // Remove a control point at the specified index and update computation
  void removeControlPoint(int index) {
    controlPoints.removeAt(index);
    _bezierComputation = BezierComputation(controlPoints);
  }
}


