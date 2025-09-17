// lib/user_dashboard/presentation/widgets/armory_tab_view.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/armory_bloc.dart';
import '../bloc/armory_event.dart';
import '../core/theme/app_theme.dart';
import 'ammunition_tab_widget.dart';
import 'firearms_tab_widget.dart';
import 'gear_tab_widget.dart';
import 'loadouts_tab_widget.dart';
import 'report_tab_widget.dart';
import 'tools_tab_widget.dart';

enum ArmoryTabType { firearms, ammunition, gear, tools, loadouts, report }

class ArmoryTabView extends StatefulWidget {
  final String userId;
  final ArmoryTabType tabType;

  const ArmoryTabView({
    super.key,
    required this.userId,
    required this.tabType,
  });

  @override
  State<ArmoryTabView> createState() => _ArmoryTabViewState();
}

class _ArmoryTabViewState extends State<ArmoryTabView> {
  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    final bloc = context.read<ArmoryBloc>();
    switch (widget.tabType) {
      case ArmoryTabType.firearms:
        bloc.add(LoadFirearmsEvent(userId: widget.userId));
        break;
      case ArmoryTabType.ammunition:
        bloc.add(LoadAmmunitionEvent(userId: widget.userId));
        break;
      case ArmoryTabType.gear:
        bloc.add(LoadGearEvent(userId: widget.userId));
        break;
      case ArmoryTabType.tools:
        bloc.add(LoadToolsEvent(userId: widget.userId));
        break;
      case ArmoryTabType.loadouts:
        bloc.add(LoadLoadoutsEvent(userId: widget.userId));
        break;
      case ArmoryTabType.report:
        bloc.add(LoadFirearmsEvent(userId: widget.userId));
        bloc.add(LoadAmmunitionEvent(userId: widget.userId));
        bloc.add(LoadGearEvent(userId: widget.userId));
        bloc.add(LoadToolsEvent(userId: widget.userId));
        bloc.add(LoadMaintenanceEvent(userId: widget.userId));
        bloc.add(LoadLoadoutsEvent(userId: widget.userId));
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: AppDecorations.pageDecoration,
      child: RefreshIndicator(
        onRefresh: () async {
          _loadData(); // Re-fetch data for the active tab
          // small delay so the refresh spinner is visible
          await Future.delayed(const Duration(milliseconds: 400));
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: AppSizes.pageMargin,
          child: _buildTabContent(),
        ),
      ),
    );
  }

  Widget _buildTabContent() {
    switch (widget.tabType) {
      case ArmoryTabType.firearms:
        return FirearmsTabWidget(userId: widget.userId);
      case ArmoryTabType.ammunition:
        return AmmunitionTabWidget(userId: widget.userId);
      case ArmoryTabType.gear:
        return GearTabWidget(userId: widget.userId);
      case ArmoryTabType.tools:
        return ToolsTabWidget(userId: widget.userId);
      case ArmoryTabType.loadouts:
        return LoadoutsTabWidget(userId: widget.userId);
      case ArmoryTabType.report:
        return ReportTabWidget(userId: widget.userId);
    }
  }
}
