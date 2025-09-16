// lib/user_dashboard/presentation/widgets/gear_item_card.dart
import 'package:flutter/material.dart';
import '../../domain/entities/armory_gear.dart';
import '../core/theme/app_theme.dart';
import 'common/common_widgets.dart';

class GearItemCard extends StatelessWidget {
  final ArmoryGear gear;

  const GearItemCard({super.key, required this.gear});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      padding: AppSizes.itemPadding,
      decoration: AppDecorations.itemCardDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  gear.model,
                  style: AppTextStyles.itemTitle,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ),
              const SizedBox(width: AppSizes.itemSpacing),
              CommonWidgets.buildTag(gear.category),
            ],
          ),
          const SizedBox(height: AppSizes.smallSpacing),
          Wrap(
            spacing: 10,
            runSpacing: AppSizes.smallSpacing,
            children: [
              if (gear.serial?.isNotEmpty == true)
                Text(
                  'SN: ${gear.serial}',
                  style: AppTextStyles.itemSubtitle,
                ),
              Text(
                'Qty: ${gear.quantity}',
                style: AppTextStyles.itemSubtitle,
              ),
            ],
          ),
        ],
      ),
    );
  }
}