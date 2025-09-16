// lib/user_dashboard/presentation/widgets/loadout_item_card.dart
import 'package:flutter/material.dart';
import '../../domain/entities/armory_loadout.dart';
import '../core/theme/app_theme.dart';

class LoadoutItemCard extends StatelessWidget {
  final ArmoryLoadout loadout;

  const LoadoutItemCard({super.key, required this.loadout});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: AppSizes.itemMargin,
      padding: AppSizes.itemPadding,
      decoration: AppDecorations.itemCardDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            loadout.name,
            style: AppTextStyles.itemTitle,
            overflow: TextOverflow.ellipsis,
          ),
          if (loadout.notes?.isNotEmpty == true) ...[
            const SizedBox(height: AppSizes.smallSpacing),
            Text(
              loadout.notes!,
              style: AppTextStyles.itemSubtitle,
              overflow: TextOverflow.ellipsis,
              maxLines: 2,
            ),
          ],
        ],
      ),
    );
  }
}