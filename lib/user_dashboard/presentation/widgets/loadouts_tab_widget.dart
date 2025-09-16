// lib/user_dashboard/presentation/widgets/loadouts_tab_widget.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/armory_bloc.dart';
import '../bloc/armory_state.dart';
import '../core/theme/app_theme.dart';
import 'add_loadout_dialog.dart';
import 'armory_card.dart';
import 'common/common_widgets.dart';
import 'empty_state_widget.dart';
import 'loadout_item_card.dart';

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
        return ArmoryCard(
          title: 'Loadouts',
          description: 'Create named bundles of your gear to speed up Training setup.',
          onAddPressed: () => _showAddLoadoutDialog(context),
          itemCount: state is LoadoutsLoaded ? state.loadouts.length : null,
          isLoading: state is ArmoryLoadingAction,
          child: _buildLoadoutsList(state),
        );
      },
    );
  }

  Widget _buildLoadoutsList(ArmoryState state) {
    if (state is ArmoryLoading) {
      return CommonWidgets.buildLoading(message: 'Loading loadouts...');
    }

    if (state is LoadoutsLoaded) {
      if (state.loadouts.isEmpty) {
        return const EmptyStateWidget(
          message: 'No loadouts yet.',
          icon: Icons.add_circle_outline,
        );
      }

      return Column(
        children: state.loadouts
            .map((loadout) => LoadoutItemCard(loadout: loadout))
            .toList(),
      );
    }

    if (state is ArmoryError) {
      return CommonWidgets.buildError(state.message);
    }

    return const EmptyStateWidget(
      message: 'No loadouts yet.',
      icon: Icons.add_circle_outline,
    );
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