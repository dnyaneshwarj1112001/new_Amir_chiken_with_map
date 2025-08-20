import 'package:flutter/material.dart';

class Apptext extends StatelessWidget {
  const Apptext(
      {super.key,
      required this.text,
      this.color = Colors.black,
      this.size = 10,
      this.fontWeight,
      this.maxline = 1});

  final String text;
  final Color? color;
  final double? size;
  final int maxline;
  final FontWeight? fontWeight; // Marked final

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      maxLines: maxline,
      style: TextStyle(
        color: color,
        fontSize: size, // Use the provided size or default to 10
        fontWeight: fontWeight,
      ),
    );
  }
}
