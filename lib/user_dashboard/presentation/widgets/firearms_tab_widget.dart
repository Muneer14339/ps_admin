// lib/user_dashboard/presentation/widgets/firearms_tab_widget.dart (Fixed)
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/armory_firearm.dart';
import '../bloc/armory_bloc.dart';
import '../bloc/armory_event.dart';
import '../bloc/armory_state.dart';
import 'add_firearm_dialog.dart';
import 'armory_card.dart';
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
          title: 'Firearms',
          description:
          'Track each gun as an asset (serial/nickname) or keep a simple quantity and split into assets later.',
          onAddPressed: () => _showAddFirearmDialog(context),
          child: _buildFirearmsList(state),
        );
      },
    );
  }

  Widget _buildFirearmsList(ArmoryState state) {
    if (state is ArmoryLoading) {
      return const Center(
        child: CircularProgressIndicator(color: Color(0xFF57B7FF)),
      );
    }

    if (state is FirearmsLoaded) {
      if (state.firearms.isEmpty) {
        return const EmptyStateWidget(message: 'No firearms added yet.');
      }

      return Column(
        children: state.firearms
            .map((firearm) => FirearmItemCard(firearm: firearm))
            .toList(),
      );
    }

    return const EmptyStateWidget(message: 'No firearms added yet.');
  }

  void _showAddFirearmDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => BlocProvider.value(
        value: context.read<ArmoryBloc>(),
        child: AddFirearmDialog(userId: userId),
      ),
    );
  }
}