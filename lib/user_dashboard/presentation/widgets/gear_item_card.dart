// lib/user_dashboard/presentation/widgets/ammunition_tab_widget.dart
import 'package:flutter/material.dart';
import '../../domain/entities/armory_gear.dart';

// lib/user_dashboard/presentation/widgets/gear_item_card.dart
class GearItemCard extends StatelessWidget {
  final ArmoryGear gear;

  const GearItemCard({super.key, required this.gear});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xFF0E1220),
        border: Border.all(color: const Color(0xFF222838)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  gear.model,
                  style: const TextStyle(
                    color: Color(0xFFE8EEF7),
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF0B1320),
                  border: Border.all(color: const Color(0xFF222838)),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  gear.category,
                  style: const TextStyle(
                    color: Color(0xFF9AA4B2),
                    fontSize: 11,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Wrap(
            spacing: 10,
            children: [
              if (gear.serial?.isNotEmpty == true)
                Text(
                  'SN: ${gear.serial}',
                  style: const TextStyle(
                    color: Color(0xFF9AA4B2),
                    fontSize: 12,
                  ),
                ),
              Text(
                'Qty: ${gear.quantity}',
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