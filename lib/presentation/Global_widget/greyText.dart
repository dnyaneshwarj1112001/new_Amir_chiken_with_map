import 'package:flutter/material.dart';

class Greytext extends StatefulWidget {
  final String text;
  const Greytext({super.key, required this.text});

  @override
  State<Greytext> createState() => _GreytextState();
}

class _GreytextState extends State<Greytext> {
  @override
  Widget build(BuildContext context) {
    return Text(
      widget.text,
      style: const TextStyle(
        fontSize: 14,
        color: Colors.grey,
      ),
    );
  }
}
