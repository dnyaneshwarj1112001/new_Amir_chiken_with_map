import 'package:flutter/material.dart';

class SearchBar1 extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Material(
        elevation: 4,
        borderRadius: BorderRadius.circular(30.0),
        child: TextField(
          style: TextStyle(color: Colors.black87),
          decoration: InputDecoration(
            prefixIcon: Icon(Icons.search_rounded, color: Colors.blueAccent),
            suffixIcon: Icon(Icons.mic_rounded,
                color: Colors.blueAccent), // optional mic icon
            hintText: "Search for chicken, items, etc.",
            hintStyle: TextStyle(color: Colors.grey.shade600),
            filled: true,
            fillColor: Colors.white,
            contentPadding: EdgeInsets.symmetric(vertical: 14.0),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(30.0),
              borderSide: BorderSide.none,
            ),
          ),
        ),
      ),
    );
  }
}
