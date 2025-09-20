// lib/user_dashboard/presentation/widgets/tools_tab_widget.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/entities/armory_maintenance.dart';
import '../../../domain/entities/armory_tool.dart';
import '../../bloc/armory_bloc.dart';
import '../../bloc/armory_event.dart';
import '../../bloc/armory_state.dart';
import '../../core/theme/app_theme.dart';
import '../add_forms/add_maintenance_form.dart';
import '../add_forms/add_tool_form.dart';
import '../armory_card.dart';
import '../common/common_widgets.dart';
import '../common/inline_form_wrapper.dart';
import '../common/responsive_grid_widget.dart';
import '../empty_state_widget.dart';
import '../maintenance_item_card.dart';
import '../tool_item_card.dart';
import 'armory_tab_view.dart';


class ToolsTabWidget extends StatefulWidget {
  final String userId;

  const ToolsTabWidget({super.key, required this.userId});

  @override
  State<ToolsTabWidget> createState() => _ToolsTabWidgetState();
}

class _ToolsTabWidgetState extends State<ToolsTabWidget> {
  List<ArmoryTool> _tools = [];
  List<ArmoryMaintenance> _maintenance = [];

  @override
  void initState() {
    super.initState();
    _loadMaintenanceData();
  }

  void _loadMaintenanceData() {
    context.read<ArmoryBloc>().add(LoadMaintenanceEvent(userId: widget.userId));
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ArmoryBloc, ArmoryState>(
      listener: (context, state) {
        if (state is ToolsLoaded) {
          setState(() => _tools = state.tools);
        } else if (state is MaintenanceLoaded) {
          setState(() => _maintenance = state.maintenance);
        } else if (state is ArmoryActionSuccess) {
          context.read<ArmoryBloc>().add(const HideFormEvent());
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
        // Show inline form for adding tool
        if (state is ShowingAddForm && state.tabType == ArmoryTabType.tools) {
          return InlineFormWrapper(
            title: 'Add Tool',
            onCancel: () => context.read<ArmoryBloc>().add(const HideFormEvent()),
            child: AddToolForm(userId: widget.userId),
          );
        }

        // Show inline form for adding maintenance
        if (state is ShowingAddForm && state.tabType == ArmoryTabType.maintenence) {
          return InlineFormWrapper(
            title: 'Log Maintenance',
            onCancel: () => context.read<ArmoryBloc>().add(const HideFormEvent()),
            child: AddMaintenanceForm(userId: widget.userId),
          );
        }

        // Show normal list view
        return ArmoryCard(
          title: 'Tools & Maintenance',
          description: 'Cleaning kits, torque tools, chronographs — plus per-asset maintenance logs.',
          onAddPressed: () => context.read<ArmoryBloc>().add(
            const ShowAddFormEvent(tabType: ArmoryTabType.tools),
          ),
          itemCount: _tools.length + _maintenance.length,
          isLoading: state is ArmoryLoadingAction,
          child: _buildToolsAndMaintenanceContent(state),
        );
      },
    );
  }

  Widget _buildToolsAndMaintenanceContent(ArmoryState state) {
    if (state is ArmoryLoading && _tools.isEmpty && _maintenance.isEmpty) {
      return CommonWidgets.buildLoading(message: 'Loading tools & maintenance...');
    }

    if (_tools.isEmpty && _maintenance.isEmpty) {
      return Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            child: Row(
              children: [
                CommonWidgets.buildActionButton(
                  label: 'Log Maintenance',
                  onPressed: () => context.read<ArmoryBloc>().add(
                    const ShowAddFormEvent(tabType: ArmoryTabType.maintenence),
                  ),
                  icon: Icons.build_circle_outlined,
                ),
              ],
            ),
          ),
          const EmptyStateWidget(
            message: 'No tools or maintenance logs yet.',
            icon: Icons.add_circle_outline,
          ),
        ],
      );
    }

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          child: Row(
            children: [
              CommonWidgets.buildActionButton(
                label: 'Log Maintenance',
                onPressed: () => context.read<ArmoryBloc>().add(
                  const ShowAddFormEvent(tabType: ArmoryTabType.maintenence),
                ),
                icon: Icons.build_circle_outlined,
              ),
            ],
          ),
        ),
        _buildToolsSection(),
        _buildMaintenanceSection(),
      ],
    );
  }

  Widget _buildToolsSection() {
    final toolCards = _tools
        .map((tool) => ToolItemCard(tool: tool, userId: widget.userId))
        .toList();

    return CommonWidgets.buildExpandableSection(
      title: 'Tools & Equipment',
      subtitle: 'cleaning kits, torque wrenches, chronographs',
      initiallyExpanded: _tools.isNotEmpty,
      children: [
        ResponsiveGridWidget(children: toolCards),
      ],
    );
  }

  Widget _buildMaintenanceSection() {
    final maintenanceCards = _maintenance
        .map((maintenance) => MaintenanceItemCard(
      maintenance: maintenance,
      userId: widget.userId,
    ))
        .toList();

    return CommonWidgets.buildExpandableSection(
      title: 'Maintenance Logs',
      subtitle: 'cleaning, lubrication, repairs, inspections',
      initiallyExpanded: _maintenance.isNotEmpty,
      children: [
        ResponsiveGridWidget(children: maintenanceCards),
      ],
    );
  }
}