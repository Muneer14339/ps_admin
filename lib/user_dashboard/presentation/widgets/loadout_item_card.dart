// lib/user_dashboard/presentation/widgets/loadout_item_card.dart
import 'package:flutter/material.dart';
import '../../domain/entities/armory_loadout.dart';
import '../core/theme/app_theme.dart';
import 'common/common_widgets.dart';

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
          // Loadout Name
          Text(
            loadout.name,
            style: AppTextStyles.itemTitle,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: AppSizes.smallSpacing),

          // Components summary
          Wrap(
            spacing: 10,
            runSpacing: AppSizes.smallSpacing,
            children: [
              if (loadout.firearmId != null)
                _buildComponentChip('Firearm', Icons.gps_fixed),
              if (loadout.ammunitionId != null)
                _buildComponentChip('Ammo', Icons.circle),
              if (loadout.gearIds.isNotEmpty)
                _buildComponentChip('${loadout.gearIds.length} Gear', Icons.build),
            ],
          ),

          // Notes
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

  Widget _buildComponentChip(String label, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.accentBackgroundWithOpacity,
        border: Border.all(color: AppColors.accentBorderWithOpacity),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 12,
            color: AppColors.accentText,
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: AppTextStyles.badgeText.copyWith(fontSize: 10),
          ),
        ],
      ),
    );
  }
}