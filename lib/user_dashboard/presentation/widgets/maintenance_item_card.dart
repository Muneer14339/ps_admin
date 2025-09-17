// lib/user_dashboard/presentation/widgets/maintenance_item_card.dart
import 'package:flutter/material.dart';
import '../../domain/entities/armory_maintenance.dart';
import '../core/theme/app_theme.dart';
import 'common/common_widgets.dart';

class MaintenanceItemCard extends StatelessWidget {
  final ArmoryMaintenance maintenance;

  const MaintenanceItemCard({super.key, required this.maintenance});

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
                  maintenance.maintenanceType,
                  style: AppTextStyles.itemTitle,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              CommonWidgets.buildTag(maintenance.assetType),
            ],
          ),
          const SizedBox(height: AppSizes.smallSpacing),
          Wrap(
            spacing: 10,
            runSpacing: AppSizes.smallSpacing,
            children: [
              Text(
                '${maintenance.date.day}/${maintenance.date.month}/${maintenance.date.year}',
                style: AppTextStyles.itemSubtitle,
              ),
              if (maintenance.roundsFired != null && maintenance.roundsFired! > 0)
                Text(
                  'Rounds: ${maintenance.roundsFired}',
                  style: AppTextStyles.itemSubtitle,
                ),
              if (maintenance.notes?.isNotEmpty == true)
                Flexible(
                  child: Text(
                    maintenance.notes!,
                    style: AppTextStyles.itemSubtitle,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 2,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}