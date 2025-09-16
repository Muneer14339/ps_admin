// lib/user_dashboard/presentation/widgets/ammunition_item_card.dart
import 'package:flutter/material.dart';
import '../../domain/entities/armory_ammunition.dart';
import '../core/theme/app_theme.dart';
import 'common/common_widgets.dart';

class AmmunitionItemCard extends StatelessWidget {
  final ArmoryAmmunition ammunition;

  const AmmunitionItemCard({super.key, required this.ammunition});

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
                  '${ammunition.brand} ${ammunition.line ?? ''}',
                  style: AppTextStyles.itemTitle,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              CommonWidgets.buildTag(ammunition.caliber),
            ],
          ),
          const SizedBox(height: AppSizes.smallSpacing),
          Wrap(
            spacing: 10,
            runSpacing: AppSizes.smallSpacing,
            children: [
              if (ammunition.lot?.isNotEmpty == true)
                Text(
                  'Lot: ${ammunition.lot}',
                  style: AppTextStyles.itemSubtitle,
                ),
              Text(
                'Qty: ${ammunition.quantity} rds',
                style: AppTextStyles.itemSubtitle,
              ),
              CommonWidgets.buildStatusChip(ammunition.status),
            ],
          ),
        ],
      ),
    );
  }
}