import 'package:flutter/material.dart';

class BadWidget extends StatelessWidget {
  const BadWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF123456), // expect: avoid_hardcoded_colors
      child: const Icon(Icons.star, color: Colors.red), // expect: avoid_hardcoded_colors
    );
  }
}
