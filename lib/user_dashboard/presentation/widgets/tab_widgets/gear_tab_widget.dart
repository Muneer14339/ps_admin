// lib/user_dashboard/presentation/widgets/gear_tab_widget.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/entities/armory_gear.dart';
import '../../bloc/armory_bloc.dart';
import '../../bloc/armory_event.dart';
import '../../bloc/armory_state.dart';
import '../../core/theme/app_theme.dart';
import '../add_dialogs/add_gear_dialog.dart';
import '../add_forms/add_gear_form.dart';
import '../armory_card.dart';
import '../common/common_widgets.dart';
import '../common/inline_form_wrapper.dart';
import '../common/responsive_grid_widget.dart';
import '../empty_state_widget.dart';
import '../gear_item_card.dart';
import 'armory_tab_view.dart';

class GearTabWidget extends StatelessWidget {
  final String userId;

  const GearTabWidget({super.key, required this.userId});

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
        // Show inline form if in ShowingAddForm state
        if (state is ShowingAddForm && state.tabType == ArmoryTabType.gear) {
          return InlineFormWrapper(
            title: 'Add Gear',
            onCancel: () => context.read<ArmoryBloc>().add(const HideFormEvent()),
            child: AddGearForm(userId: userId),
          );
        }

        // Show normal list view
        return Column(
          children: [
            ArmoryCard(
              title: 'Gear',
              description: 'Optics, supports, sensors, attachments, and more — organized as collapsible sections.',
              onAddPressed: () => context.read<ArmoryBloc>().add(
                const ShowAddFormEvent(tabType: ArmoryTabType.gear),
              ),
              itemCount: state is GearLoaded ? state.gear.length : null,
              isLoading: state is ArmoryLoadingAction,
              child: _buildGearAccordion(state),
            ),
          ],
        );
      },
    );
  }

  Widget _buildGearAccordion(ArmoryState state) {
    if (state is ArmoryLoading) {
      return CommonWidgets.buildLoading(message: 'Loading gear...');
    }

    if (state is GearLoaded) {
      final gearByCategory = <String, List<ArmoryGear>>{};

      for (final gear in state.gear) {
        final category = gear.category.toLowerCase();
        gearByCategory[category] = (gearByCategory[category] ?? [])..add(gear);
      }

      if (gearByCategory.isEmpty) {
        return const EmptyStateWidget(
          message: 'No gear items yet.',
          icon: Icons.add_circle_outline,
        );
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

    if (state is ArmoryError) {
      return CommonWidgets.buildError(state.message);
    }

    return const EmptyStateWidget(
      message: 'No gear items yet.',
      icon: Icons.add_circle_outline,
    );
  }

  Widget _buildGearSection(String categoryKey, String title, String subtitle, List<ArmoryGear> items) {
    final gearCards = items
        .map((gear) => GearItemCard(gear: gear, userId: userId))
        .toList();

    return CommonWidgets.buildExpandableSection(
      title: title,
      subtitle: subtitle,
      children: [
        ResponsiveGridWidget(children: gearCards),
      ],
    );
  }
}