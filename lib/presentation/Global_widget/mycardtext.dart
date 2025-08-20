import 'package:meatzo/presentation/Global_widget/apptext.dart';
import 'package:flutter/material.dart';

class cardtext extends StatefulWidget {
  final String leadingtext;
  final String trailingtext;
  const cardtext(
      {super.key, required this.leadingtext, required this.trailingtext});

  @override
  State<cardtext> createState() => _cardtextState();
}

class _cardtextState extends State<cardtext> {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Apptext(
          text: widget.leadingtext,
          fontWeight: FontWeight.bold,
        ),
        Apptext(
          text: widget.trailingtext,
        ),
      ],
    );
  }
}
