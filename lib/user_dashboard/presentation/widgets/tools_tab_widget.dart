// lib/user_dashboard/presentation/widgets/tools_tab_widget.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/armory_tool.dart';
import '../../domain/entities/armory_maintenance.dart';
import '../bloc/armory_bloc.dart';
import '../bloc/armory_event.dart';
import '../bloc/armory_state.dart';
import '../core/theme/app_theme.dart';
import 'add_maintenance_dialog.dart';
import 'add_tool_dialog.dart';
import 'armory_card.dart';
import 'common/common_widgets.dart';
import 'empty_state_widget.dart';
import 'maintenance_item_card.dart';
import 'tool_item_card.dart';

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
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: AppColors.successColor,
            ),
          );
          // Reload data after successful action
          if (state.message.contains('Tool')) {
            context.read<ArmoryBloc>().add(LoadToolsEvent(userId: widget.userId));
          } else if (state.message.contains('Maintenance')) {
            _loadMaintenanceData();
          }
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
        return ArmoryCard(
          title: 'Tools & Maintenance',
          description: 'Cleaning kits, torque tools, chronographs — plus per-asset maintenance logs.',
          onAddPressed: () => _showAddToolDialog(context),
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
                  onPressed: () => _showAddMaintenanceDialog(context),
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
        // Tools Section
        _buildToolsSection(),
        // Maintenance Section
        _buildMaintenanceSection(),
      ],
    );
  }

  Widget _buildToolsSection() {
    return CommonWidgets.buildExpandableSection(
      title: 'Tools & Equipment',
      subtitle: 'cleaning kits, torque wrenches, chronographs',
      initiallyExpanded: _tools.isNotEmpty,
      children: _tools.map((tool) => ToolItemCard(tool: tool,userId: widget.userId,)).toList(),
    );
  }

  Widget _buildMaintenanceSection() {
    return CommonWidgets.buildExpandableSection(
      title: 'Maintenance Logs',
      subtitle: 'cleaning, lubrication, repairs, inspections',
      initiallyExpanded: _maintenance.isNotEmpty,
      children: _maintenance.map((maintenance) => MaintenanceItemCard(maintenance: maintenance, userId: widget.userId,)).toList(),
    );
  }

  void _showAddToolDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => BlocProvider.value(
        value: context.read<ArmoryBloc>(),
        child: AddToolDialog(userId: widget.userId),
      ),
    ).then((_) {
      // This runs after the dialog is closed
      context.read<ArmoryBloc>().add(LoadToolsEvent(userId: widget.userId));
      context.read<ArmoryBloc>().add(LoadMaintenanceEvent(userId: widget.userId));

    });
  }

  void _showAddMaintenanceDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => BlocProvider.value(
        value: context.read<ArmoryBloc>(),
        child: AddMaintenanceDialog(userId: widget.userId),
      ),
    ).then((_) {
      // This runs after the dialog is closed
      context.read<ArmoryBloc>().add(LoadToolsEvent(userId: widget.userId));
      context.read<ArmoryBloc>().add(LoadMaintenanceEvent(userId: widget.userId));
    });
  }
}