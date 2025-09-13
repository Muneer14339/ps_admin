import 'package:flutter/material.dart';

class SectionTitle extends StatelessWidget {
  final String text;
  final double scale;
  const SectionTitle(this.text, {required this.scale});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(text, style: TextStyle(fontSize: 18 * scale, fontWeight: FontWeight.w600, color: Colors.grey[800])),
    );
  }
}