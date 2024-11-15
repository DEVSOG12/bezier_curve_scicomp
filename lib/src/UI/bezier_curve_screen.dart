import 'package:bezier_curve_scicomp/src/math/bezier/bezier_curve.dart';
import 'package:bezier_curve_scicomp/src/math/models/points.dart';
import 'package:flutter/material.dart';
import 'package:tex_text/tex_text.dart';

import 'bezier_canvas.dart';

class BezierInteractiveScreen extends StatefulWidget {
  const BezierInteractiveScreen({super.key});

  @override
  BezierInteractiveScreenState createState() =>
      BezierInteractiveScreenState();
}

class BezierInteractiveScreenState extends State<BezierInteractiveScreen> {
  late Points start, control1, control2, end;
  late BezierCurve bezierCurve;

  // Currently selected point for dragging
  Points? selectedPoint;
  double tValue = 0.0;

  // Create a GlobalKey to access the painter
  final GlobalKey _canvasKey = GlobalKey();
  BezierCanvasPainter? _bezierCanvasPainter;

  @override
  void initState() {
    super.initState();
    // Set initial points to create a centered curve
    start = Points(-180, 5);
    control1 = Points(-20, -220);
    control2 = Points(60, 240);
    end = Points(240, -5);
    bezierCurve = BezierCurve(start, control1, control2, end);
  }

  @override
  Widget build(BuildContext context) {
    String xEquation = getBezierEquationSymbolic(
        'x', start.x, control1.x, control2.x, end.x);
    String yEquation = getBezierEquationSymbolic(
        'y', start.y, control1.y, control2.y, end.y);
    double xAtT = bezierCurve.evaluate(tValue).x;
    double yAtT = bezierCurve.evaluate(tValue).y;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Interactive Bézier Curve'),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          bool isWideScreen = constraints.maxWidth > 600;

          return isWideScreen
              ? Row(
                  children: [
                    // Canvas area
                    Expanded(
                      child: _buildCanvas(),
                    ),
                    // Divider
                    const VerticalDivider(width: 1, color: Colors.grey),
                    // Details area
                    SizedBox(
                      width: 300,
                      child: _buildDetails(xEquation, yEquation, xAtT, yAtT),
                    ),
                  ],
                )
              : Column(
                  children: [
                    // Canvas area
                    Expanded(
                      child: _buildCanvas(),
                    ),
                    // Divider
                    const Divider(height: 1, color: Colors.grey),
                    // Details area
                    SizedBox(
                      height: 300,
                      child: _buildDetails(xEquation, yEquation, xAtT, yAtT),
                    ),
                  ],
                );
        },
      ),
    );
  }

  Widget _buildCanvas() {
    _bezierCanvasPainter = BezierCanvasPainter(
      bezierCurve: bezierCurve,
      tValue: tValue,
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        return GestureDetector(
          onTapUp: _onTapUp,
          onPanStart: _onPanStart,
          onPanUpdate: _onPanUpdate,
          onPanEnd: (_) => selectedPoint = null, // Clear selection on end
          child: SizedBox(
            width: constraints.maxWidth,
            height: constraints.maxHeight,
            child: CustomPaint(
              key: _canvasKey,
              painter: _bezierCanvasPainter,
            ),
          ),
        );
      },
    );
  }

  Widget _buildDetails(
      String xEquation, String yEquation, double xAtT, double yAtT) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          Slider(
            value: tValue,
            onChanged: (newValue) {
              setState(() {
                tValue = newValue;
              });
            },
            min: 0.0,
            max: 1.0,
            divisions: 100,
            label: 't = ${tValue.toStringAsFixed(2)}',
          ),
          Text(
            't = ${tValue.toStringAsFixed(2)}',
            style: const TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 10),
          const Text(
            'Bézier Equations:',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          TexText(
            'x(t) = $xEquation',
            // textStyle: const TextStyle(fontSize: 16),
          ),
          TexText(
            'y(t) = $yEquation',
            // textStyle: const TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 10),
          Text(
            'Evaluated at t = ${tValue.toStringAsFixed(2)}:',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          Text(
            'x(${tValue.toStringAsFixed(2)}) = ${xAtT.toStringAsFixed(2)}',
            style: const TextStyle(fontSize: 16),
          ),
          Text(
            'y(${tValue.toStringAsFixed(2)}) = ${yAtT.toStringAsFixed(2)}',
            style: const TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 10),
          const Text(
            'Control Points:',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          Text(
            'P1 (Start): (${start.x.toStringAsFixed(2)}, ${start.y.toStringAsFixed(2)})',
            style: const TextStyle(fontSize: 16),
          ),
          Text(
            'P2 (Control 1): (${control1.x.toStringAsFixed(2)}, ${control1.y.toStringAsFixed(2)})',
            style: const TextStyle(fontSize: 16),
          ),
          Text(
            'P3 (Control 2): (${control2.x.toStringAsFixed(2)}, ${control2.y.toStringAsFixed(2)})',
            style: const TextStyle(fontSize: 16),
          ),
          Text(
            'P4 (End): (${end.x.toStringAsFixed(2)}, ${end.y.toStringAsFixed(2)})',
            style: const TextStyle(fontSize: 16),
          ),
        ],
      ),
    );
  }

  void _onPanStart(DragStartDetails details) {
    // Adjust touch point coordinates
    Offset adjustedTouchPoint = _getAdjustedTouchPoint(details.localPosition);

    // Determine if the touch is near any control or end point
    selectedPoint = _getPointNearTouch(adjustedTouchPoint);
  }

  void _onPanUpdate(DragUpdateDetails details) {
    if (selectedPoint != null) {
      setState(() {
        // Update the position of the selected point
        selectedPoint!.x += details.delta.dx;
        selectedPoint!.y += details.delta.dy;

        // Update the curve with the new positions
        bezierCurve = BezierCurve(start, control1, control2, end);
      });
    }
  }

  void _onTapUp(TapUpDetails details) {
    Offset adjustedTouchPoint = _getAdjustedTouchPoint(details.localPosition);
    Points? tappedPoint = _getPointNearTouch(adjustedTouchPoint);
    if (tappedPoint != null) {
      _showEditPointDialog(tappedPoint);
    }
  }

  Offset _getAdjustedTouchPoint(Offset localPosition) {
    // Get the translation offsets from the painter
    double dx = _bezierCanvasPainter?.dx ?? 0.0;
    double dy = _bezierCanvasPainter?.dy ?? 0.0;

    // Adjust the touch point coordinates
    return Offset(localPosition.dx - dx, localPosition.dy - dy);
  }

  Points? _getPointNearTouch(Offset touchPoint) {
    const double proximityThreshold = 15.0;
    // Check if touch is near any of the points
    if (_isPointNear(touchPoint, start, proximityThreshold)) return start;
    if (_isPointNear(touchPoint, control1, proximityThreshold)) return control1;
    if (_isPointNear(touchPoint, control2, proximityThreshold)) return control2;
    if (_isPointNear(touchPoint, end, proximityThreshold)) return end;
    return null;
  }

  bool _isPointNear(Offset touchPoint, Points point, double threshold) {
    return (touchPoint.dx - point.x).abs() < threshold &&
        (touchPoint.dy - point.y).abs() < threshold;
  }

  void _showEditPointDialog(Points point) {
    TextEditingController xController =
        TextEditingController(text: point.x.toStringAsFixed(2));
    TextEditingController yController =
        TextEditingController(text: point.y.toStringAsFixed(2));

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Edit Point'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: xController,
                decoration: const InputDecoration(labelText: 'X'),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
              ),
              TextField(
                controller: yController,
                decoration: const InputDecoration(labelText: 'Y'),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Cancel
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                double? x = double.tryParse(xController.text);
                double? y = double.tryParse(yController.text);
                if (x != null && y != null) {
                  setState(() {
                    point.x = x;
                    point.y = y;
                    bezierCurve = BezierCurve(start, control1, control2, end);
                  });
                  Navigator.of(context).pop();
                } else {
                  // Show error message
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please enter valid numbers')),
                  );
                }
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  // Helper method to generate the Bézier equation string for x(t) or y(t) with symbolic t
  String getBezierEquationSymbolic(
      String axis, double p0, double p1, double p2, double p3) {
    String c0 = p0.toStringAsFixed(2);
    String c1 = p1.toStringAsFixed(2);
    String c2 = p2.toStringAsFixed(2);
    String c3 = p3.toStringAsFixed(2);

    return '($c0) * (1 - t)^3 + 3 * ($c1) * (1 - t)^2 * t + 3 * ($c2) * (1 - t) * t^2 + ($c3) * t^3';
  }
}
