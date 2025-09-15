// lib/user_dashboard/presentation/widgets/ammunition_tab_widget.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/armory_bloc.dart';
import '../bloc/armory_state.dart';
import 'add_ammunition_dialog.dart';
import 'ammunition_item_card.dart';
import 'armory_card.dart';
import 'empty_state_widget.dart';

// lib/user_dashboard/presentation/widgets/ammunition_tab_widget.dart (Fixed)
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
          title: 'Ammunition',
          description: 'Catalog brands and track lots with chrono data for better analytics.',
          onAddPressed: () => _showAddAmmunitionDialog(context),
          itemCount: state is AmmunitionLoaded ? state.ammunition.length : null,
          child: _buildAmmunitionList(state),
        );
      },
    );
  }

  Widget _buildAmmunitionList(ArmoryState state) {
    if (state is ArmoryLoading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: CircularProgressIndicator(color: Color(0xFF57B7FF)),
        ),
      );
    }

    if (state is AmmunitionLoaded) {
      if (state.ammunition.isEmpty) {
        return const EmptyStateWidget(message: 'No ammunition lots yet.');
      }

      return Column(
        children: state.ammunition
            .map((ammo) => AmmunitionItemCard(ammunition: ammo))
            .toList(),
      );
    }

    return const EmptyStateWidget(message: 'No ammunition lots yet.');
  }

  void _showAddAmmunitionDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => BlocProvider.value(
        value: context.read<ArmoryBloc>(),
        child: AddAmmunitionDialog(userId: userId),
      ),
    );
  }
}