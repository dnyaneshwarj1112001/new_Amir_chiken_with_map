import 'package:flutter/material.dart';

class Gaph extends StatelessWidget {
  final double height;

  const Gaph({super.key, required this.height});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
    );
  }
}

class Gapw extends StatelessWidget {
  final double width;

  const Gapw({super.key, required this.width});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
    );
  }
}
