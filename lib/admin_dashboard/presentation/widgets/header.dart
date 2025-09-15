import 'package:flutter/material.dart';

class Header extends StatelessWidget {
  final double scale;
  const Header({required this.scale});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Database Management',
                style: TextStyle(fontSize: 24 * scale, fontWeight: FontWeight.bold, color: Colors.deepPurple),
              ),
              SizedBox(height: 6 / scale),
              Text('Manage firearms and ammunition data quickly', style: TextStyle(fontSize: 14 * scale, color: Colors.grey[700])),
            ],
          ),
        ),
        SizedBox(width: 12 / scale),
        CircleAvatar(radius: 28 * scale, backgroundColor: Colors.deepPurple.shade100, child: const Icon(Icons.storage, size: 28)),
      ],
    );
  }
}