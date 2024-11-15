class Points {
  double x;
  double y;

  Points(this.x, this.y);

  @override
  String toString() {
    return 'Points{x: ${x.toStringAsFixed(2)}, y: ${y.toStringAsFixed(2)}}';
  }

  void setX(double x) {
    this.x = x;
  }

  void setY(double y) {
    this.y = y;
  }
}


