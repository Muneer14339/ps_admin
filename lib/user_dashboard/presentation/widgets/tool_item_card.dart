// lib/user_dashboard/presentation/widgets/ammunition_tab_widget.dart
import 'package:flutter/material.dart';
import '../../domain/entities/armory_tool.dart';
// lib/user_dashboard/presentation/widgets/tool_item_card.dart
class ToolItemCard extends StatelessWidget {
  final ArmoryTool tool;

  const ToolItemCard({super.key, required this.tool});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 14),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xFF0E1220),
        border: Border.all(color: const Color(0xFF222838)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            tool.name,
            style: const TextStyle(
              color: Color(0xFFE8EEF7),
              fontSize: 14,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 4),
          Wrap(
            spacing: 10,
            children: [
              Text(
                'Qty: ${tool.quantity}',
                style: const TextStyle(
                  color: Color(0xFF9AA4B2),
                  fontSize: 12,
                ),
              ),
              if (tool.category?.isNotEmpty == true)
                Text(
                  'Category: ${tool.category}',
                  style: const TextStyle(
                    color: Color(0xFF9AA4B2),
                    fontSize: 12,
                  ),
                ),
              if (tool.notes?.isNotEmpty == true)
                Text(
                  tool.notes!,
                  style: const TextStyle(
                    color: Color(0xFF9AA4B2),
                    fontSize: 12,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}