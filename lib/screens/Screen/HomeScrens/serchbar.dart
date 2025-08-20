import 'package:flutter/material.dart';

class SearchBar1 extends StatelessWidget {
  const SearchBar1({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Material(
        elevation: 4,
        borderRadius: BorderRadius.circular(30.0),
        child: TextField(
          style: const TextStyle(color: Colors.black87),
          decoration: InputDecoration(
            prefixIcon: const Icon(Icons.search_rounded, color: Colors.blueAccent),
            suffixIcon: const Icon(Icons.mic_rounded,
                color: Colors.blueAccent), // optional mic icon
            hintText: "Search for chicken, items, etc.",
            hintStyle: TextStyle(color: Colors.grey.shade600),
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(vertical: 14.0),
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
