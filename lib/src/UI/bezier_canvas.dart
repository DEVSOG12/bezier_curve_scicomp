import 'package:bezier_curve_scicomp/src/math/bezier/bezier_curve.dart';
import 'package:bezier_curve_scicomp/src/math/models/points.dart';
import 'package:flutter/material.dart';

class BezierCanvasPainter extends CustomPainter {
  final BezierCurve? bezierCurve; // Optional single Bézier curve
  final List<Points>? shapePoints; // Optional combined points for a shape
  final int numPoints;
  final double tValue;

  // Expose the translation offsets
  double dx = 0.0;
  double dy = 0.0;

  

  BezierCanvasPainter(
    {
    this.bezierCurve,
    this.shapePoints,
    this.numPoints = 100,
    required this.tValue,
  }) ;
  // : 
  //  // both shouldn't be set at the same time
  //   assert(bezierCurve == null || shapePoints == null);


  @override
  void paint(Canvas canvas, Size size) {
    // Clip the canvas to prevent drawing outside the bounds
    canvas.clipRect(Rect.fromLTWH(0, 0, size.width, size.height));

    // Draw grid background
    _drawGrid(canvas, size);

    // Center the shape in the canvas
    canvas.save();

    // Calculate the offset to center the shape or curve
    final curveBounds = _getBounds();
    dx = (size.width - curveBounds.width) / 2 - curveBounds.left;
    dy = (size.height - curveBounds.height) / 2 - curveBounds.top;
    canvas.translate(dx, dy);

    // Draw x and y axes
    _drawAxes(canvas, size);

    // Draw the shape or Bézier curve
    if (shapePoints != null) {
      _drawShape(canvas, shapePoints!);
    } else if (bezierCurve != null) {
      _drawBezierCurve(canvas);
    }

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

  void _drawShape(Canvas canvas, List<Points> points) {
    final paint = Paint()
      ..color = Colors.blue
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final path = Path();
    if (points.isNotEmpty) {
      path.moveTo(points[0].x, points[0].y);
      for (int i = 1; i < points.length; i++) {
        path.lineTo(points[i].x, points[i].y);
      }
      canvas.drawPath(path, paint);
    }
  }

  void _drawBezierCurve(Canvas canvas) {
    final paint = Paint()
      ..color = Colors.blue
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    // Generate curve points using BezierCurve
    List<Points> points = bezierCurve!.generateCurvePoints(numPoints: numPoints);

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
    final pointAtT = bezierCurve!.evaluate(tValue);
    final pointPaint = Paint()
      ..color = Colors.green
      ..style = PaintingStyle.fill;

    canvas.drawCircle(Offset(pointAtT.x, pointAtT.y), 5, pointPaint);

    // Draw control points and lines
    _drawControlPointsAndLines(canvas);

    // Optional: Visualize De Casteljau's algorithm
    _drawDeCasteljauLines(canvas, tValue);
  }

  void _drawControlPointsAndLines(Canvas canvas) {
    // Draw control points
    final controlPaint = Paint()
      ..color = Colors.red
      ..style = PaintingStyle.fill;

    for (Points point in bezierCurve!.controlPoints) {
      _drawPoint(canvas, point, controlPaint);
    }

    // Draw lines connecting control points
    final controlLinePaint = Paint()
      ..color = Colors.grey
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    final controlPath = Path();
    if (bezierCurve!.controlPoints.isNotEmpty) {
      controlPath.moveTo(bezierCurve!.controlPoints[0].x, bezierCurve!.controlPoints[0].y);
      for (int i = 1; i < bezierCurve!.controlPoints.length; i++) {
        controlPath.lineTo(bezierCurve!.controlPoints[i].x, bezierCurve!.controlPoints[i].y);
      }
      canvas.drawPath(controlPath, controlLinePaint);
    }
  }

  // Helper method to draw points
  void _drawPoint(Canvas canvas, Points point, Paint paint) {
    canvas.drawCircle(Offset(point.x, point.y), 6, paint);
  }

  // Calculate the bounding rectangle of the shape or curve
  Rect _getBounds() {
    List<Points> points = shapePoints ?? bezierCurve!.generateCurvePoints(numPoints: numPoints);
    List<double> xs = points.map((p) => p.x).toList();
    List<double> ys = points.map((p) => p.y).toList();

    double minX = xs.reduce((a, b) => a < b ? a : b);
    double maxX = xs.reduce((a, b) => a > b ? a : b);
    double minY = ys.reduce((a, b) => a < b ? a : b);
    double maxY = ys.reduce((a, b) => a > b ? a : b);

    return Rect.fromLTRB(minX, minY, maxX, maxY);
  }

  // Optional: Visualize De Casteljau's algorithm
  void _drawDeCasteljauLines(Canvas canvas, double t) {
    List<Points> points = List.from(bezierCurve!.controlPoints);
    final deCasteljauPaint = Paint()
      ..color = Colors.orange
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    while (points.length > 1) {
      List<Points> nextLevelPoints = [];
      for (int i = 0; i < points.length - 1; i++) {
        Points p0 = points[i];
        Points p1 = points[i + 1];
        Points interpolatedPoint = Points(
          (1 - t) * p0.x + t * p1.x,
          (1 - t) * p0.y + t * p1.y,
        );
        nextLevelPoints.add(interpolatedPoint);

        // Draw line between p0 and p1
        canvas.drawLine(
          Offset(p0.x, p0.y),
          Offset(p1.x, p1.y),
          deCasteljauPaint,
        );

        // Draw the interpolated point
        _drawPoint(canvas, interpolatedPoint, deCasteljauPaint);
      }
      points = nextLevelPoints;
    }
  }

  @override
  bool shouldRepaint(covariant BezierCanvasPainter oldDelegate) {
    return shapePoints != oldDelegate.shapePoints ||
        bezierCurve != oldDelegate.bezierCurve ||
        tValue != oldDelegate.tValue;
  }
}
