// lib/user_dashboard/presentation/widgets/ammunition_tab_widget.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/armory_bloc.dart';
import '../bloc/armory_state.dart';
import 'add_loadout_dialog.dart';
import 'armory_card.dart';
import 'empty_state_widget.dart';
import 'loadout_item_card.dart';
// lib/user_dashboard/presentation/widgets/loadouts_tab_widget.dart (Fixed)
class LoadoutsTabWidget extends StatelessWidget {
  final String userId;

  const LoadoutsTabWidget({super.key, required this.userId});

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
        return ArmoryCard(
          title: 'Loadouts',
          description: 'Create named bundles of your gear to speed up Training setup.',
          onAddPressed: () => _showAddLoadoutDialog(context),
          itemCount: state is LoadoutsLoaded ? state.loadouts.length : null,
          child: _buildLoadoutsList(state),
        );
      },
    );
  }

  Widget _buildLoadoutsList(ArmoryState state) {
    if (state is ArmoryLoading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: CircularProgressIndicator(color: Color(0xFF57B7FF)),
        ),
      );
    }

    if (state is LoadoutsLoaded) {
      if (state.loadouts.isEmpty) {
        return const EmptyStateWidget(message: 'No loadouts yet.');
      }

      return Column(
        children: state.loadouts
            .map((loadout) => LoadoutItemCard(loadout: loadout))
            .toList(),
      );
    }

    return const EmptyStateWidget(message: 'No loadouts yet.');
  }

  void _showAddLoadoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => BlocProvider.value(
        value: context.read<ArmoryBloc>(),
        child: AddLoadoutDialog(userId: userId),
      ),
    );
  }
}
