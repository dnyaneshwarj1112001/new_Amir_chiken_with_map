import 'package:flutter/material.dart';

class Globalicons extends StatefulWidget {
  final IconData icon;
  final Color color;

  const Globalicons({super.key, required this.icon, required this.color});

  @override
  State<Globalicons> createState() => _GlobaliconsState();
}

class _GlobaliconsState extends State<Globalicons> {
  @override
  Widget build(BuildContext context) {
    return Icon(
      widget.icon, // ✅ Fixed: use widget.icon directly
      color: widget.color,
    );
  }
}
