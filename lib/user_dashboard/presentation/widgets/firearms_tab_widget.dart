// lib/user_dashboard/presentation/widgets/firearms_tab_widget.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/armory_bloc.dart';
import '../bloc/armory_event.dart';
import '../bloc/armory_state.dart';
import '../core/theme/app_theme.dart';
import 'add_firearm_dialog.dart';
import 'armory_card.dart';
import 'common/common_widgets.dart';
import 'common/responsive_grid_widget.dart'; // Import the new widget
import 'empty_state_widget.dart';
import 'firearm_item_card.dart';

class FirearmsTabWidget extends StatelessWidget {
  final String userId;

  const FirearmsTabWidget({super.key, required this.userId});

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
        }
        else if (state is ArmoryError) {
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
          title: 'Firearms',
          description: 'Track each gun as an asset (serial/nickname) or keep a simple quantity and split into assets later.',
          onAddPressed: () => _showAddFirearmDialog(context),
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

      // Use the new ResponsiveGridWidget instead of Column
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

  void _showAddFirearmDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => BlocProvider.value(
        value: context.read<ArmoryBloc>(),
        child: AddFirearmDialog(userId: userId),
      ),
    ).then((_) {
      // This runs after the dialog is closed
      context.read<ArmoryBloc>().add(LoadFirearmsEvent(userId: userId));
    });
  }
}
