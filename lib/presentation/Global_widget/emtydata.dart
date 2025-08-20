import 'package:flutter/material.dart';

class EmptyStateWidget extends StatelessWidget {
  final String message;
  final IconData icon;
  final double height;

  const EmptyStateWidget({
    super.key,
    this.message = "No data found",
    this.icon = Icons.info_outline,
    this.height = 240, // default height if not specified
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 50, color: Colors.grey),
            const SizedBox(height: 10),
            Text(
              message,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.grey,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
