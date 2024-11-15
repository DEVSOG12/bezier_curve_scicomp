import 'models/points.dart';

class BezierComputation {
  final Points p1; // Start point
  final Points p2; // Control point 1
  final Points p3; // Control point 2
  final Points p4; // End point

  BezierComputation(this.p1, this.p2, this.p3, this.p4);

  // Method to calculate a point on the curve at a given t using the cubic Bézier formula
  Points calculatePoint(double t) {
    double x = _calculateCoordinate(t, p1.x, p2.x, p3.x, p4.x);
    double y = _calculateCoordinate(t, p1.y, p2.y, p3.y, p4.y);
    return Points(x, y);
  }

  // Helper method to calculate coordinate
  double _calculateCoordinate(
      double t, double p0, double p1, double p2, double p3) {
    return (1 - t) * (1 - t) * (1 - t) * p0 +
        3 * (1 - t) * (1 - t) * t * p1 +
        3 * (1 - t) * t * t * p2 +
        t * t * t * p3;
  }
}
