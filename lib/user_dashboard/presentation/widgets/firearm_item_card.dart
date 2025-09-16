// lib/user_dashboard/presentation/widgets/firearm_item_card.dart
import 'package:flutter/material.dart';
import '../../domain/entities/armory_firearm.dart';
import '../core/theme/app_theme.dart';
import 'common/common_widgets.dart';

class FirearmItemCard extends StatelessWidget {
  final ArmoryFirearm firearm;

  const FirearmItemCard({super.key, required this.firearm});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: AppSizes.itemMargin,
      padding: AppSizes.itemPadding,
      decoration: AppDecorations.itemCardDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  '${firearm.make} ${firearm.model}',
                  style: AppTextStyles.itemTitle,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              CommonWidgets.buildTag(firearm.caliber),
            ],
          ),
          const SizedBox(height: AppSizes.smallSpacing),
          Wrap(
            spacing: 10,
            runSpacing: AppSizes.smallSpacing,
            children: [
              if (firearm.serial?.isNotEmpty == true)
                Text(
                  'SN: ${firearm.serial}',
                  style: AppTextStyles.itemSubtitle,
                ),
              if (firearm.nickname.isNotEmpty)
                Text(
                  '"${firearm.nickname}"',
                  style: AppTextStyles.itemSubtitle,
                ),
              CommonWidgets.buildStatusChip(firearm.status),
            ],
          ),
        ],
      ),
    );
  }
}