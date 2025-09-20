// lib/user_dashboard/presentation/widgets/firearms_tab_widget.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../bloc/armory_bloc.dart';
import '../../bloc/armory_event.dart';
import '../../bloc/armory_state.dart';
import '../../core/theme/app_theme.dart';
import '../add_forms/add_firearm_form.dart';
import '../armory_card.dart';
import '../common/common_widgets.dart';
import '../common/inline_form_wrapper.dart';
import '../common/responsive_grid_widget.dart'; // Import the new widget
import '../empty_state_widget.dart';
import '../firearm_item_card.dart';
import 'armory_tab_view.dart';

class FirearmsTabWidget extends StatelessWidget {
  final String userId;

  const FirearmsTabWidget({super.key, required this.userId});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ArmoryBloc, ArmoryState>(
      listener: (context, state) {
        if (state is ArmoryActionSuccess) {
          // Hide form and show success message
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
        // Show inline form if in ShowingAddForm state
        if (state is ShowingAddForm && state.tabType == ArmoryTabType.firearms) {
          return InlineFormWrapper(
            title: 'Add Firearm',
            badge: 'Level 1 UI',
            onCancel: () => context.read<ArmoryBloc>().add(const HideFormEvent()),
            child: AddFirearmForm(userId: userId),
          );
        }

        // Show normal list view
        return ArmoryCard(
          title: 'Firearms',
          description: 'Track each gun as an asset or keep a simple quantity.',
          onAddPressed: () => context.read<ArmoryBloc>().add(
            const ShowAddFormEvent(tabType: ArmoryTabType.firearms),
          ),
          itemCount: state is FirearmsLoaded ? state.firearms.length : null,
          isLoading: state is ArmoryLoadingAction,
          child: _buildFirearmsList(state),
        );
      },
    );
  }

  Widget _buildFirearmsList(ArmoryState state) {
    if (state is ArmoryLoading) {
      return CommonWidgets.buildLoading(message: 'Loading firearms...');
    }

    if (state is FirearmsLoaded) {
      if (state.firearms.isEmpty) {
        return const EmptyStateWidget(
          message: 'No firearms added yet.',
          icon: Icons.add_circle_outline,
        );
      }

      final firearmCards = state.firearms
          .map((firearm) => FirearmItemCard(
        firearm: firearm,
        userId: userId,
      ))
          .toList();

      return ResponsiveGridWidget(children: firearmCards);
    }

    if (state is ArmoryError) {
      return CommonWidgets.buildError(state.message);
    }

    return const EmptyStateWidget(
      message: 'No firearms added yet.',
      icon: Icons.add_circle_outline,
    );
  }
}