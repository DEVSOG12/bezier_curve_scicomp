import 'package:bezier_curve_scicomp/src/math/bezier/bezier_curve.dart';
import 'package:bezier_curve_scicomp/src/math/models/points.dart';
import 'package:flutter/material.dart';


class BezierCanvasPainter extends CustomPainter {
  final BezierCurve bezierCurve;
  final int numPoints;
  final double tValue;

  // Expose the translation offsets
  double dx = 0.0;
  double dy = 0.0;

  BezierCanvasPainter({
    required this.bezierCurve,
    this.numPoints = 100,
    required this.tValue,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Clip the canvas to prevent drawing outside the bounds
    canvas.clipRect(Rect.fromLTWH(0, 0, size.width, size.height));

    // Draw grid background
    _drawGrid(canvas, size);

    // Center the curve in the canvas
    canvas.save();

    // Calculate the offset to center the curve
    final curveBounds = _getCurveBounds();
    dx = (size.width - curveBounds.width) / 2 - curveBounds.left;
    dy = (size.height - curveBounds.height) / 2 - curveBounds.top;
    canvas.translate(dx, dy);

    // Draw x and y axes
    _drawAxes(canvas, size);

    // Draw the Bézier curve
    _drawBezierCurve(canvas);

    // Restore the canvas
    canvas.restore();
  }

  void _drawGrid(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.grey.shade300
      ..strokeWidth = 0.5;

    const double step = 20.0; // Grid cell size

    for (double x = 0; x <= size.width; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y <= size.height; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

void _drawAxes(Canvas canvas, Size size) {
  final axisPaint = Paint()
    ..color = Colors.black
    ..strokeWidth = 1;

  // Since we've translated the canvas to center the curve,
  // we need to draw the axes accordingly.

  // Calculate the extents of the canvas in the translated coordinate system
  double left = -dx;
  double right = size.width - dx;
  double top = -dy;
  double bottom = size.height - dy;

  // Draw X-axis (horizontal line across the canvas)
  canvas.drawLine(
    Offset(left, 0),
    Offset(right, 0),
    axisPaint,
  );

  // Draw Y-axis (vertical line across the canvas)
  canvas.drawLine(
    Offset(0, top),
    Offset(0, bottom),
    axisPaint,
  );
}


  void _drawBezierCurve(Canvas canvas) {
    final paint = Paint()
      ..color = Colors.blue
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    // Generate curve points using BezierCurve
    List<Points> points =
        bezierCurve.generateCurvePoints(numPoints: numPoints);

    // Create a path to draw the curve
    if (points.isNotEmpty) {
      final path = Path();
      path.moveTo(points[0].x, points[0].y);
      for (var i = 1; i < points.length; i++) {
        path.lineTo(points[i].x, points[i].y);
      }
      canvas.drawPath(path, paint);
    }

    // Draw the point at tValue
    final pointAtT = bezierCurve.evaluate(tValue);
    final pointPaint = Paint()
      ..color = Colors.green
      ..style = PaintingStyle.fill;

    canvas.drawCircle(Offset(pointAtT.x, pointAtT.y), 5, pointPaint);

    // Draw control points and lines
    _drawControlPointsAndLines(canvas);
  }

  void _drawControlPointsAndLines(Canvas canvas) {
    // Draw control points
    final controlPaint = Paint()
      ..color = Colors.red
      ..style = PaintingStyle.fill;

    _drawPoint(canvas, bezierCurve.p1, controlPaint);
    _drawPoint(canvas, bezierCurve.p2, controlPaint);
    _drawPoint(canvas, bezierCurve.p3, controlPaint);
    _drawPoint(canvas, bezierCurve.p4, controlPaint);

    // Draw lines connecting control points
    final controlLinePaint = Paint()
      ..color = Colors.grey
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    final controlPath = Path();
    controlPath.moveTo(bezierCurve.p1.x, bezierCurve.p1.y);
    controlPath.lineTo(bezierCurve.p2.x, bezierCurve.p2.y);
    controlPath.lineTo(bezierCurve.p3.x, bezierCurve.p3.y);
    controlPath.lineTo(bezierCurve.p4.x, bezierCurve.p4.y);
    canvas.drawPath(controlPath, controlLinePaint);
  }

  // Helper method to draw points
  void _drawPoint(Canvas canvas, Points point, Paint paint) {
    canvas.drawCircle(Offset(point.x, point.y), 6, paint);
  }

  // Calculate the bounding rectangle of the curve and control points
  Rect _getCurveBounds() {
    List<double> xs = [
      bezierCurve.p1.x,
      bezierCurve.p2.x,
      bezierCurve.p3.x,
      bezierCurve.p4.x
    ];
    List<double> ys = [
      bezierCurve.p1.y,
      bezierCurve.p2.y,
      bezierCurve.p3.y,
      bezierCurve.p4.y
    ];

    double minX = xs.reduce((a, b) => a < b ? a : b);
    double maxX = xs.reduce((a, b) => a > b ? a : b);
    double minY = ys.reduce((a, b) => a < b ? a : b);
    double maxY = ys.reduce((a, b) => a > b ? a : b);

    return Rect.fromLTRB(minX, minY, maxX, maxY);
  }

  @override
  bool shouldRepaint(covariant BezierCanvasPainter oldDelegate) {
    return bezierCurve != oldDelegate.bezierCurve ||
        tValue != oldDelegate.tValue;
  }
}
