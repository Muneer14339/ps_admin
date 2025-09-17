// lib/user_dashboard/presentation/widgets/tools_tab_widget.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/armory_bloc.dart';
import '../bloc/armory_state.dart';
import '../core/theme/app_theme.dart';
import 'add_maintenance_dialog.dart';
import 'add_tool_dialog.dart';
import 'armory_card.dart';
import 'common/common_widgets.dart';
import 'empty_state_widget.dart';
import 'tool_item_card.dart';

class ToolsTabWidget extends StatelessWidget {
  final String userId;

  const ToolsTabWidget({super.key, required this.userId});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ArmoryBloc, ArmoryState>(
      listener: (context, state) {
        if (state is ArmoryActionSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: AppColors.successColor,
            ),
          );
        } else if (state is ArmoryError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: AppColors.errorColor,
            ),
          );
        }
      },
      builder: (context, state) {
        return Column(
          children: [
            ArmoryCard(
              title: 'Tools & Maintenance',
              description: 'Cleaning kits, torque tools, chronographs — plus per-asset maintenance logs.',
              onAddPressed: () => _showAddToolDialog(context),
              itemCount: state is ToolsLoaded ? state.tools.length : null,
              isLoading: state is ArmoryLoadingAction,
              child: _buildToolsContent(state, context),
            ),
          ],
        );
      },
    );
  }

  Widget _buildToolsContent(ArmoryState state, BuildContext context) {
    return Column(
      children: [
        // Add Maintenance button
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          child: Row(
            children: [
              CommonWidgets.buildActionButton(
                label: 'Log Maintenance',
                onPressed: () => _showAddMaintenanceDialog(context),
                icon: Icons.build_circle_outlined,
              ),
            ],
          ),
        ),
        _buildToolsList(state),
      ],
    );
  }

  void _showAddMaintenanceDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => BlocProvider.value(
        value: context.read<ArmoryBloc>(),
        child: AddMaintenanceDialog(userId: userId),
      ),
    );
  }

  Widget _buildToolsList(ArmoryState state) {
    if (state is ArmoryLoading) {
      return CommonWidgets.buildLoading(message: 'Loading tools...');
    }

    if (state is ToolsLoaded) {
      if (state.tools.isEmpty) {
        return const EmptyStateWidget(
          message: 'No tools yet.',
          icon: Icons.add_circle_outline,
        );
      }

      return Column(
        children: state.tools
            .map((tool) => ToolItemCard(tool: tool))
            .toList(),
      );
    }

    if (state is ArmoryError) {
      return CommonWidgets.buildError(state.message);
    }

    return const EmptyStateWidget(
      message: 'No tools yet.',
      icon: Icons.add_circle_outline,
    );
  }

  void _showAddToolDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => BlocProvider.value(
        value: context.read<ArmoryBloc>(),
        child: AddToolDialog(userId: userId),
      ),
    );
  }
}