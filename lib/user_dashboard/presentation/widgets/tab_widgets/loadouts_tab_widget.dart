// lib/user_dashboard/presentation/widgets/loadouts_tab_widget.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pa_sreens/user_dashboard/presentation/bloc/armory_event.dart';
import '../../bloc/armory_bloc.dart';
import '../../bloc/armory_state.dart';
import '../../core/theme/app_theme.dart';
import '../add_dialogs/add_loadout_dialog.dart';
import '../add_forms/add_loadout_form.dart';
import '../armory_card.dart';
import '../common/common_widgets.dart';
import '../common/inline_form_wrapper.dart';
import '../common/responsive_grid_widget.dart';
import '../empty_state_widget.dart';
import '../loadout_item_card.dart';
import 'armory_tab_view.dart';

// Step 10: Updated LoadoutsTabWidget
class LoadoutsTabWidget extends StatelessWidget {
  final String userId;

  const LoadoutsTabWidget({super.key, required this.userId});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ArmoryBloc, ArmoryState>(
      listener: (context, state) {
        if (state is ArmoryActionSuccess) {
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
        // Show inline form
        if (state is ShowingAddForm && state.tabType == ArmoryTabType.loadouts) {
          return InlineFormWrapper(
            title: 'Create Loadout',
            onCancel: () => context.read<ArmoryBloc>().add(const HideFormEvent()),
            child: AddLoadoutForm(userId: userId),
          );
        }

        // Show normal list view
        return ArmoryCard(
          title: 'Loadouts',
          description: 'Create named bundles of your gear to speed up Training setup.',
          onAddPressed: () => context.read<ArmoryBloc>().add(
            const ShowAddFormEvent(tabType: ArmoryTabType.loadouts),
          ),
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

      final loadoutCards = state.loadouts
          .map((loadout) => LoadoutItemCard(loadout: loadout, userId: userId))
          .toList();

      return ResponsiveGridWidget(children: loadoutCards);
    }

    if (state is ArmoryError) {
      return CommonWidgets.buildError(state.message);
    }

    return const EmptyStateWidget(
      message: 'No loadouts yet.',
      icon: Icons.add_circle_outline,
    );
  }
}