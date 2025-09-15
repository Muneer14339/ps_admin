// lib/user_dashboard/presentation/pages/user_dashboard_page.dart
import 'package:flutter/material.dart';
// lib/user_dashboard/presentation/widgets/armory_card.dart
class ArmoryCard extends StatelessWidget {
  final String title;
  final String description;
  final VoidCallback onAddPressed;
  final Widget child;
  final int? itemCount;

  const ArmoryCard({
    super.key,
    required this.title,
    required this.description,
    required this.onAddPressed,
    required this.child,
    this.itemCount,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF151923),
        border: Border.all(color: const Color(0xFF222838)),
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.35),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: Color(0xFFE8EEF7),
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Icon(
                      Icons.inventory_2_outlined,
                      color: Color(0xFF57B7FF),
                      size: 16,
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  description,
                  style: const TextStyle(
                    color: Color(0xFF9AA4B2),
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    ElevatedButton.icon(
                      onPressed: onAddPressed,
                      icon: const Icon(Icons.add, size: 16),
                      label: Text('Add $title'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2A3BFF).withOpacity(0.15),
                        foregroundColor: const Color(0xFFDBE6FF),
                        side: BorderSide(
                          color: const Color(0xFF3050FF).withOpacity(0.35),
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 10,
                        ),
                      ),
                    ),
                    const Spacer(),
                    if (itemCount != null)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1B2130),
                          border: Border.all(color: const Color(0xFF222838)),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          '$itemCount items',
                          style: const TextStyle(
                            color: Color(0xFF9AA4B2),
                            fontSize: 11,
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
          child,
        ],
      ),
    );
  }
}
