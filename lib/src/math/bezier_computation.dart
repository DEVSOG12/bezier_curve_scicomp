// bezier_computation.dart

import 'models/points.dart';

class BezierComputation {
  final List<Points> controlPoints;

  BezierComputation(this.controlPoints);

  // Method to calculate a point on the curve at a given t using De Casteljau's algorithm
  Points calculatePoint(double t) {
    List<Points> tempPoints = List.from(controlPoints);
    int n = tempPoints.length;

    for (int k = 1; k < n; k++) {
      for (int i = 0; i < n - k; i++) {
        tempPoints[i] = Points(
          (1 - t) * tempPoints[i].x + t * tempPoints[i + 1].x,
          (1 - t) * tempPoints[i].y + t * tempPoints[i + 1].y,
        );
      }
    }
    return tempPoints[0];
  }
}
