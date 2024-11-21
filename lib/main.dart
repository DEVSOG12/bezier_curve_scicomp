// main.dart
import 'package:bezier_curve_scicomp/src/UI/bezier_curve_screen.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: BezierInteractiveScreen(),
    );
  }
}
