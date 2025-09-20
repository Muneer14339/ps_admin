// lib/user_dashboard/presentation/widgets/ammunition_tab_widget.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/armory_bloc.dart';
import '../bloc/armory_event.dart';
import '../bloc/armory_state.dart';
import '../core/theme/app_theme.dart';
import 'add_ammunition_dialog.dart';
import 'ammunition_item_card.dart';
import 'armory_card.dart';
import 'common/common_widgets.dart';
import 'common/responsive_grid_widget.dart';
import 'empty_state_widget.dart';

class AmmunitionTabWidget extends StatelessWidget {
  final String userId;

  const AmmunitionTabWidget({super.key, required this.userId});

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
          title: 'Ammunition',
          description: 'Catalog brands and track lots with chrono data for better analytics.',
          onAddPressed: () => _showAddAmmunitionDialog(context),
          itemCount: state is AmmunitionLoaded ? state.ammunition.length : null,
          isLoading: state is ArmoryLoadingAction,
          child: _buildAmmunitionList(state),
        );
      },
    );
  }

  Widget _buildAmmunitionList(ArmoryState state) {
    if (state is ArmoryLoading) {
      return CommonWidgets.buildLoading(message: 'Loading ammunition...');
    }

    if (state is AmmunitionLoaded) {
      if (state.ammunition.isEmpty) {
        return const EmptyStateWidget(
          message: 'No ammunition lots yet.',
          icon: Icons.add_circle_outline,
        );
      }

      // Ammunition cards list bana lo
      final ammoCards = state.ammunition
          .map((ammo) => AmmunitionItemCard(
        ammunition: ammo,
        userId: userId,
      ))
          .toList();

// Yahan Column ki jagah ResponsiveGridWidget use karo
      return ResponsiveGridWidget(children: ammoCards);

    }

    if (state is ArmoryError) {
      return CommonWidgets.buildError(state.message);
    }

    return const EmptyStateWidget(
      message: 'No ammunition lots yet.',
      icon: Icons.add_circle_outline,
    );
  }

  void _showAddAmmunitionDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => BlocProvider.value(
        value: context.read<ArmoryBloc>(),
        child: AddAmmunitionDialog(userId: userId),
      ),
    ).then((_) {
      // This runs after the dialog is closed
      context.read<ArmoryBloc>().add(LoadAmmunitionEvent(userId: userId));
    });
  }
}