// points.dart

class Points {
  double x;
  double y;

  Points(this.x, this.y);

  @override
  String toString() {
    return 'Points{x: ${x.toStringAsFixed(2)}, y: ${y.toStringAsFixed(2)}}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Points && other.x == x && other.y == y;
  }

  @override
  int get hashCode => x.hashCode ^ y.hashCode;
}
