import 'package:meatzo/presentation/Global_widget/apptext.dart';
import 'package:flutter/material.dart';

class Mycardhelper extends StatefulWidget {
  const Mycardhelper(
      {super.key,
      required this.lable,
      required this.amount,
      this.amountColor = Colors.black,
      this.fontWeight = FontWeight.normal});
  final String lable;
  final String amount;
  final Color amountColor;
  final FontWeight fontWeight;
  @override
  State<Mycardhelper> createState() => _MycardhelperState();
}

class _MycardhelperState extends State<Mycardhelper> {
  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        Apptext(
          text: widget.lable,
          fontWeight: widget.fontWeight,
        ),
        Apptext(
          text: "₹ ${widget.amount}",
          color: widget.amountColor,
        )
      ],
    );
  }
}
