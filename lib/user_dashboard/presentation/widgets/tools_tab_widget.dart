// lib/user_dashboard/presentation/widgets/ammunition_tab_widget.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/armory_bloc.dart';
import '../bloc/armory_state.dart';
import 'add_tool_dialog.dart';
import 'armory_card.dart';
import 'empty_state_widget.dart';
import 'tool_item_card.dart';
// lib/user_dashboard/presentation/widgets/tools_tab_widget.dart
// lib/user_dashboard/presentation/widgets/tools_tab_widget.dart (Fixed)
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
              backgroundColor: const Color(0xFF51CF66),
            ),
          );
        } else if (state is ArmoryError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: const Color(0xFFFF6B6B),
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
              child: _buildToolsList(state),
            ),
          ],
        );
      },
    );
  }

  Widget _buildToolsList(ArmoryState state) {
    if (state is ArmoryLoading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: CircularProgressIndicator(color: Color(0xFF57B7FF)),
        ),
      );
    }

    if (state is ToolsLoaded) {
      if (state.tools.isEmpty) {
        return const EmptyStateWidget(message: 'No tools yet.');
      }

      return Column(
        children: state.tools
            .map((tool) => ToolItemCard(tool: tool))
            .toList(),
      );
    }

    return const EmptyStateWidget(message: 'No tools yet.');
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
