// lib/user_dashboard/presentation/widgets/tool_item_card.dart
import 'package:flutter/material.dart';
import '../../domain/entities/armory_tool.dart';
import '../core/theme/app_theme.dart';
import 'common/common_widgets.dart';

class ToolItemCard extends StatelessWidget {
  final ArmoryTool tool;

  const ToolItemCard({super.key, required this.tool});

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
            tool.name,
            style: AppTextStyles.itemTitle,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: AppSizes.smallSpacing),
          Wrap(
            spacing: 10,
            runSpacing: AppSizes.smallSpacing,
            children: [
              Text(
                'Qty: ${tool.quantity}',
                style: AppTextStyles.itemSubtitle,
              ),
              if (tool.category?.isNotEmpty == true)
                Text(
                  'Category: ${tool.category}',
                  style: AppTextStyles.itemSubtitle,
                ),
              CommonWidgets.buildStatusChip(tool.status),
              if (tool.notes?.isNotEmpty == true)
                Flexible(
                  child: Text(
                    tool.notes!,
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