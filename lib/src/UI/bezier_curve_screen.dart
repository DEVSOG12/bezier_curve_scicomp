// bezier_curve_screen.dart
import 'package:bezier_curve_scicomp/src/math/bezier/bezier_curve.dart';
import 'package:bezier_curve_scicomp/src/math/models/points.dart';
import 'package:flutter/material.dart';
import 'package:tex_text/tex_text.dart';

import 'bezier_canvas.dart';

class BezierInteractiveScreen extends StatefulWidget {
  const BezierInteractiveScreen({super.key});

  @override
  BezierInteractiveScreenState createState() => BezierInteractiveScreenState();
}

class BezierInteractiveScreenState extends State<BezierInteractiveScreen> {
  late BezierCurve bezierCurve;
  late List<Points> fiveShapePoints;

  // Currently selected point for dragging
  Points? selectedPoint;
  double tValue = 0.0;

  // Create a GlobalKey to access the painter
  final GlobalKey _canvasKey = GlobalKey();
  BezierCanvasPainter? _bezierCanvasPainter;

@override
void initState() {
  super.initState();

  // Define the control points for each segment of the "5"
  final List<Points> topCurve = [
    Points(0, 50),   // Start point
    Points(20, 70),  // Control point 1
    Points(80, 70),  // Control point 2
    Points(100, 50), // End point
  ];

  final List<Points> bottomLoop = [
    Points(100, 30),  // Start point
    Points(80, 10),   // Control point 1
    Points(20, 10),   // Control point 2
    Points(0, 30),    // End point
  ];

  final List<Points> verticalLine = [
    Points(100, 50), // Start of vertical line
    Points(100, 30), // End of vertical line
  ];

  // Create BézierCurve instances for curved sections
  final BezierCurve topBezier = BezierCurve(topCurve);
  final BezierCurve bottomBezier = BezierCurve(bottomLoop);

  // Generate all points needed to render the "5"
  fiveShapePoints = [
    ...topBezier.generateCurvePoints(numPoints: 50),
    ...verticalLine, // Vertical straight line
    ...bottomBezier.generateCurvePoints(numPoints: 50),
  ];

  bezierCurve = BezierCurve([
        Points(-100, 0),
        Points(0, 100),
        Points(100, 0),
      ]);
}

  @override
  Widget build(BuildContext context) {
    String xEquation = getBezierEquationSymbolic(
      'x',
      bezierCurve.controlPoints.map((p) => p.x).toList(),
    );
    String yEquation = getBezierEquationSymbolic(
      'y',
      bezierCurve.controlPoints.map((p) => p.y).toList(),
    );
    Points pointAtT = bezierCurve.evaluate(tValue);

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
                      child: _buildDetails(xEquation, yEquation, pointAtT),
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
                      child: _buildDetails(xEquation, yEquation, pointAtT),
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
          key: const Key('canvasGestureDetector'),
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

  Widget _buildDetails(String xEquation, String yEquation, Points pointAtT) {
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
            key: const Key('tValueDisplay'),
            style: const TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 10),
          const Text(
            'Bézier Equations:',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: TexText(
              r'$x(t) = ' + xEquation + r'$',
              style: const TextStyle(fontSize: 12),
            ),
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: TexText(
              r'$y(t) = ' + yEquation + r'$',
              style: const TextStyle(fontSize: 12),
            
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Evaluated at t = ${tValue.toStringAsFixed(2)}:',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          Text(
            'x(${tValue.toStringAsFixed(2)}) = ${pointAtT.x.toStringAsFixed(2)}',
            style: const TextStyle(fontSize: 16),
          ),
          Text(
            'y(${tValue.toStringAsFixed(2)}) = ${pointAtT.y.toStringAsFixed(2)}',
            style: const TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 10),
          const Text(
            'Control Points:',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          ListView.builder(
            shrinkWrap: true,
            itemCount: bezierCurve.controlPoints.length,
            itemBuilder: (context, index) {
              Points point = bezierCurve.controlPoints[index];
              return Text(
                'P${index + 1}: (${point.x.toStringAsFixed(2)}, ${point.y.toStringAsFixed(2)})',
                style: const TextStyle(fontSize: 16),
              );
            },
          ),
          const SizedBox(height: 10),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: _addControlPoint,
                child: const Text('Add Control Point'),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _removeControlPoint,
                child: const Text('Remove Control Point'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _addControlPoint() {
    setState(() {
      // Add a new point at a default position or at the end
      Points lastPoint = bezierCurve.controlPoints.last;
      Points newPoint = Points(lastPoint.x + 50, lastPoint.y);
      bezierCurve.addControlPoint(newPoint);
    });
  }

  void _removeControlPoint() {
    setState(() {
      if (bezierCurve.controlPoints.length > 2) {
        // Ensure at least 2 points remain
        bezierCurve.removeControlPoint(bezierCurve.controlPoints.length - 1);
      }
    });
  }

  void _onPanStart(DragStartDetails details) {
    // Adjust touch point coordinates
    Offset adjustedTouchPoint = _getAdjustedTouchPoint(details.localPosition);

    // Determine if the touch is near any control point
    selectedPoint = _getPointNearTouch(adjustedTouchPoint);
  }

  void _onPanUpdate(DragUpdateDetails details) {
    if (selectedPoint != null) {
      setState(() {
        // Update the position of the selected point
        selectedPoint!.x += details.delta.dx;
        selectedPoint!.y += details.delta.dy;

        // Update the curve with the new positions
        bezierCurve = BezierCurve(bezierCurve.controlPoints);
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
    for (Points point in bezierCurve.controlPoints) {
      if ((touchPoint.dx - point.x).abs() < proximityThreshold &&
          (touchPoint.dy - point.y).abs() < proximityThreshold) {
        return point;
      }
    }
    return null;
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
                key: const Key('xTextField'),
                controller: xController,
                decoration: const InputDecoration(labelText: 'X'),
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
              ),
              TextField(
                key: const Key('yTextField'),
                controller: yController,
                decoration: const InputDecoration(labelText: 'Y'),
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
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
                    bezierCurve = BezierCurve(bezierCurve.controlPoints);
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
  String getBezierEquationSymbolic(String axis, List<double> controlValues) {
    int n = controlValues.length - 1;
    List<String> terms = [];

    for (int i = 0; i <= n; i++) {
      double coeff = controlValues[i];
      int binCoeff = _binomialCoefficient(n, i);
      String term = '$binCoeff \\times ($coeff) \\times (1 - t)^{${n - i}} \\times t^$i';
      terms.add(term);
    }

    return terms.join(' + ');
  }

  int _binomialCoefficient(int n, int k) {
    return _factorial(n) ~/ (_factorial(k) * _factorial(n - k));
  }

  int _factorial(int n) {
    if (n <= 1) return 1;
    int result = 1;
    for (int i = 2; i <= n; i++) {
      result *= i;
    }
    return result;
  }
}
