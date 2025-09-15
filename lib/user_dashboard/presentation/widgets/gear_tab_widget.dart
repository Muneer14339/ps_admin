// lib/user_dashboard/presentation/widgets/ammunition_tab_widget.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/armory_gear.dart';
import '../bloc/armory_bloc.dart';
import '../bloc/armory_state.dart';
import 'add_gear_dialog.dart';
import 'armory_card.dart';
import 'empty_state_widget.dart';
import 'gear_item_card.dart';
// lib/user_dashboard/presentation/widgets/gear_tab_widget.dart
// lib/user_dashboard/presentation/widgets/gear_tab_widget.dart (Fixed)
class GearTabWidget extends StatelessWidget {
  final String userId;

  const GearTabWidget({super.key, required this.userId});

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
              title: 'Gear',
              description: 'Optics, supports, sensors, attachments, and more — organized as collapsible sections.',
              onAddPressed: () => _showAddGearDialog(context),
              itemCount: state is GearLoaded ? state.gear.length : null,
              child: _buildGearAccordion(state),
            ),
          ],
        );
      },
    );
  }

  Widget _buildGearAccordion(ArmoryState state) {
    if (state is ArmoryLoading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: CircularProgressIndicator(color: Color(0xFF57B7FF)),
        ),
      );
    }

    if (state is GearLoaded) {
      final gearByCategory = <String, List<ArmoryGear>>{};

      // Group gear by category
      for (final gear in state.gear) {
        final category = gear.category.toLowerCase();
        gearByCategory[category] = (gearByCategory[category] ?? [])..add(gear);
      }

      if (gearByCategory.isEmpty) {
        return const EmptyStateWidget(message: 'No gear items yet.');
      }

      return Column(
        children: [
          _buildGearSection('optics', 'Optics & Sights', 'scopes, RDS, irons', gearByCategory['optics'] ?? []),
          _buildGearSection('supports', 'Supports', 'bipods, tripods, rests', gearByCategory['supports'] ?? []),
          _buildGearSection('attachments', 'Attachments', 'suppressors, brakes, lights', gearByCategory['attachments'] ?? []),
          _buildGearSection('sensors', 'Sensors & Electronics', 'ShotPulse, RifleAxis, PulseSkadi', gearByCategory['sensors'] ?? []),
          _buildGearSection('misc', 'Misc. Gear', 'slings, cases, ear/eye pro', gearByCategory['misc'] ?? []),
        ],
      );
    }

    return const EmptyStateWidget(message: 'No gear items yet.');
  }

  Widget _buildGearSection(String categoryKey, String title, String subtitle, List<ArmoryGear> items) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0xFF222838))),
      ),
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        childrenPadding: const EdgeInsets.only(left: 12, right: 12, bottom: 12),
        iconColor: const Color(0xFF9AA4B2),
        collapsedIconColor: const Color(0xFF9AA4B2),
        title: Row(
          children: [
            Text(
              title,
              style: const TextStyle(
                color: Color(0xFFE8EEF7),
                fontSize: 14,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              subtitle,
              style: const TextStyle(
                color: Color(0xFF9AA4B2),
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        children: items.isEmpty
            ? [
          const Padding(
            padding: EdgeInsets.all(8),
            child: Text(
              'No items.',
              style: TextStyle(
                color: Color(0xFF9AA4B2),
                fontSize: 12,
              ),
            ),
          )
        ]
            : items.map((gear) => GearItemCard(gear: gear)).toList(),
      ),
    );
  }

  void _showAddGearDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => BlocProvider.value(
        value: context.read<ArmoryBloc>(),
        child: AddGearDialog(userId: userId),
      ),
    );
  }
}
