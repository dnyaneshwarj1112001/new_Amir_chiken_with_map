import 'package:meatzo/presentation/Global_widget/Appcolor.dart';
import 'package:flutter/material.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final bool centerTitle;
  final Color titleColor;
  final FontWeight titleFontWeight;
  final List<Widget>? actions;
  final Widget? leading;

  const CustomAppBar({
    super.key,
    required this.title,
    this.centerTitle = true,
    this.titleColor = Colors.white,
    this.titleFontWeight = FontWeight.bold,
    this.actions,
    this.leading,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      bottomOpacity: BorderSide.strokeAlignCenter,
      leading: leading,
      title: Text(
        title,
        style: TextStyle(
          color: titleColor,
          fontWeight: titleFontWeight,
          fontSize: 14, // You can adjust the font size as needed
        ),
      ),
      centerTitle: centerTitle,
      backgroundColor: Appcolor.primaryRed,
      iconTheme: const IconThemeData(
          color: Colors.white), // <-- Set icon color to white
      actions: actions,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
