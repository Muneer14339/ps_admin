// lib/user_dashboard/presentation/widgets/ammunition_tab_widget.dart
import 'package:flutter/material.dart';
import '../../domain/entities/armory_ammunition.dart';

// lib/user_dashboard/presentation/widgets/ammunition_item_card.dart
class AmmunitionItemCard extends StatelessWidget {
  final ArmoryAmmunition ammunition;

  const AmmunitionItemCard({super.key, required this.ammunition});

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
                  '${ammunition.brand} ${ammunition.line ?? ''}',
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
                  ammunition.caliber,
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
              if (ammunition.lot?.isNotEmpty == true)
                Text(
                  'Lot: ${ammunition.lot}',
                  style: const TextStyle(
                    color: Color(0xFF9AA4B2),
                    fontSize: 12,
                  ),
                ),
              Text(
                'Qty: ${ammunition.quantity} rds',
                style: const TextStyle(
                  color: Color(0xFF9AA4B2),
                  fontSize: 12,
                ),
              ),
              _buildStatusChip(ammunition.status),
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
      case 'low-stock':
        color = const Color(0xFFFFD43B);
        break;
      case 'out-of-stock':
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
