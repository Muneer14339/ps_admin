// lib/user_dashboard/presentation/pages/user_dashboard_page.dart
import 'package:flutter/material.dart';
import '../../domain/entities/armory_firearm.dart';
class FirearmItemCard extends StatelessWidget {
  final ArmoryFirearm firearm;

  const FirearmItemCard({super.key, required this.firearm});

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
          Row(
            children: [
              Expanded(
                child: Text(
                  '${firearm.make} ${firearm.model}',
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
                  firearm.caliber,
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
              if (firearm.serial?.isNotEmpty == true)
                Text(
                  'SN: ${firearm.serial}',
                  style: const TextStyle(
                    color: Color(0xFF9AA4B2),
                    fontSize: 12,
                  ),
                ),
              if (firearm.nickname.isNotEmpty)
                Text(
                  '"${firearm.nickname}"',
                  style: const TextStyle(
                    color: Color(0xFF9AA4B2),
                    fontSize: 12,
                  ),
                ),
              _buildStatusChip(firearm.status),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusChip(String status) {
    Color color;
    switch (status.toLowerCase()) {
      case 'available':
        color = const Color(0xFF51CF66);
        break;
      case 'in-use':
        color = const Color(0xFFFFD43B);
        break;
      case 'maintenance':
        color = const Color(0xFFFF6B6B);
        break;
      default:
        color = const Color(0xFF9AA4B2);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        border: Border.all(color: color.withOpacity(0.2)),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        status,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
