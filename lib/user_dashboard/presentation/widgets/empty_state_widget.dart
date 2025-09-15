// lib/user_dashboard/presentation/pages/user_dashboard_page.dart
import 'package:flutter/material.dart';

// lib/user_dashboard/presentation/widgets/empty_state_widget.dart
class EmptyStateWidget extends StatelessWidget {
  final String message;

  const EmptyStateWidget({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Text(
        message,
        style: const TextStyle(
          color: Color(0xFF9AA4B2),
          fontSize: 13,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}