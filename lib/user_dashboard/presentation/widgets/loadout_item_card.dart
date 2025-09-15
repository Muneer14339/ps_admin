// lib/user_dashboard/presentation/widgets/ammunition_tab_widget.dart
import 'package:flutter/material.dart';
import '../../domain/entities/armory_loadout.dart';
// lib/user_dashboard/presentation/widgets/loadout_item_card.dart
class LoadoutItemCard extends StatelessWidget {
  final ArmoryLoadout loadout;

  const LoadoutItemCard({super.key, required this.loadout});

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
            loadout.name,
            style: const TextStyle(
              color: Color(0xFFE8EEF7),
              fontSize: 14,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 4),
          if (loadout.notes?.isNotEmpty == true)
            Text(
              loadout.notes!,
              style: const TextStyle(
                color: Color(0xFF9AA4B2),
                fontSize: 12,
              ),
            ),
        ],
      ),
    );
  }
}