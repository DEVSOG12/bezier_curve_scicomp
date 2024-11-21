import 'dart:io';
import 'package:bezier_curve_scicomp/src/math/models/points.dart';

Future<List<List<Points>>> readSegmentsFromFile(String filePath) async {
  try {
    final file = File(filePath);
    final lines = await file.readAsLines();

    List<List<Points>> segments = [];
    List<Points> currentSegment = [];

    for (var line in lines) {
      line = line.trim();

      if (line.isEmpty || line.startsWith('#')) {
        // Ignore empty lines or comments
        continue;
      }

      if (line == '---') {
        // Segment separator
        if (currentSegment.isNotEmpty) {
          segments.add(List.from(currentSegment));
          currentSegment.clear();
        }
      } else {
        final parts = line.split(',');
        if (parts.length != 2) {
          throw FormatException('Each line must contain exactly two numbers separated by a comma');
        }

        final double x = double.parse(parts[0].trim());
        final double y = double.parse(parts[1].trim());

        currentSegment.add(Points(x, y));
      }
    }

    // Add the last segment if any
    if (currentSegment.isNotEmpty) {
      segments.add(currentSegment);
    }

    return segments;
  } catch (e) {
    print('Error reading points from file: $e');
    rethrow;
  }
}
