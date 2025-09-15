// lib/user_dashboard/presentation/widgets/report_tab_widget.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/armory_firearm.dart';
import '../../domain/entities/armory_ammunition.dart';
import '../../domain/entities/armory_gear.dart';
import '../../domain/entities/armory_tool.dart';
import '../../domain/entities/armory_loadout.dart';
import '../bloc/armory_bloc.dart';
import '../bloc/armory_event.dart';
import '../bloc/armory_state.dart';

class ReportTabWidget extends StatefulWidget {
  final String userId;

  const ReportTabWidget({super.key, required this.userId});

  @override
  State<ReportTabWidget> createState() => _ReportTabWidgetState();
}

class _ReportTabWidgetState extends State<ReportTabWidget> {
  List<ArmoryFirearm> _firearms = [];
  List<ArmoryAmmunition> _ammunition = [];
  List<ArmoryGear> _gear = [];
  List<ArmoryTool> _tools = [];
  List<ArmoryLoadout> _loadouts = [];

  final Map<String, bool> _expandedSections = {
    'firearms': false,
    'ammunition': false,
    'gear': false,
    'tools': false,
    'loadouts': false,
  };

  @override
  void initState() {
    super.initState();
    _loadAllData();
  }

  void _loadAllData() {
    final bloc = context.read<ArmoryBloc>();
    bloc.add(LoadFirearmsEvent(userId: widget.userId));
    bloc.add(LoadAmmunitionEvent(userId: widget.userId));
    bloc.add(LoadGearEvent(userId: widget.userId));
    bloc.add(LoadToolsEvent(userId: widget.userId));
    bloc.add(LoadLoadoutsEvent(userId: widget.userId));
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ArmoryBloc, ArmoryState>(
      listener: (context, state) {
        if (state is FirearmsLoaded) {
          setState(() => _firearms = state.firearms);
        } else if (state is AmmunitionLoaded) {
          setState(() => _ammunition = state.ammunition);
        } else if (state is GearLoaded) {
          setState(() => _gear = state.gear);
        } else if (state is ToolsLoaded) {
          setState(() => _tools = state.tools);
        } else if (state is LoadoutsLoaded) {
          setState(() => _loadouts = state.loadouts);
        }
      },
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF151923),
          border: Border.all(color: const Color(0xFF222838)),
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.35),
              blurRadius: 24,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          children: [
            _buildReportHeader(),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    _buildReportSection(
                      'firearms',
                      'Firearms',
                      _firearms.length,
                      _buildFirearmsTable(),
                    ),
                    _buildReportSection(
                      'ammunition',
                      'Ammunition',
                      _ammunition.length,
                      _buildAmmunitionTable(),
                    ),
                    _buildReportSection(
                      'gear',
                      'Gear & Accessories',
                      _gear.length,
                      _buildGearTable(),
                    ),
                    _buildReportSection(
                      'tools',
                      'Tools & Equipment',
                      _tools.length,
                      _buildToolsTable(),
                    ),
                    _buildReportSection(
                      'loadouts',
                      'Loadouts',
                      _loadouts.length,
                      _buildLoadoutsTable(),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReportHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0xFF222838))),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Inventory Report',
                    style: TextStyle(
                      color: Color(0xFFE8EEF7),
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 15),
                  Wrap(
                    spacing: 20,
                    runSpacing: 10,
                    children: [
                      _buildSummaryStatistic('${_firearms.length}', 'Firearms'),
                      _buildSummaryStatistic('${_ammunition.length}', 'Ammo Lots'),
                      _buildSummaryStatistic('${_gear.length}', 'Gear Items'),
                      _buildSummaryStatistic('${_tools.length}', 'Tools'),
                      _buildSummaryStatistic('${_loadouts.length}', 'Loadouts'),
                    ],
                  ),
                ],
              ),
              ElevatedButton.icon(
                onPressed: _printReport,
                icon: const Icon(Icons.print, size: 16),
                label: const Text('Print Report'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1B2130),
                  foregroundColor: const Color(0xFFE8EEF7),
                  side: const BorderSide(color: Color(0xFF222838)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryStatistic(String number, String label) {
    return Column(
      children: [
        Text(
          number,
          style: const TextStyle(
            color: Color(0xFF57B7FF),
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(
            color: Color(0xFF9AA4B2),
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildReportSection(String key, String title, int count, Widget content) {
    final isExpanded = _expandedSections[key] ?? false;

    return Container(
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0xFF222838))),
      ),
      child: Column(
        children: [
          InkWell(
            onTap: () {
              setState(() {
                _expandedSections[key] = !isExpanded;
              });
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Row(
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Color(0xFFE8EEF7),
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1B2130),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      '$count items',
                      style: const TextStyle(
                        color: Color(0xFF9AA4B2),
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const Spacer(),
                  AnimatedRotation(
                    turns: isExpanded ? 0.5 : 0,
                    duration: const Duration(milliseconds: 200),
                    child: const Icon(
                      Icons.keyboard_arrow_down,
                      color: Color(0xFF9AA4B2),
                      size: 20,
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (isExpanded)
            Container(
              padding: const EdgeInsets.only(left: 20, right: 20, bottom: 20),
              child: content,
            ),
        ],
      ),
    );
  }

  Widget _buildFirearmsTable() {
    if (_firearms.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(20),
        child: Text(
          'No firearms in inventory',
          style: TextStyle(color: Color(0xFF9AA4B2), fontSize: 13),
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFF222838)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          headingRowColor: MaterialStateProperty.all(const Color(0xFF101522)),
          dataRowMaxHeight: 50,
          columnSpacing: 20,
          headingTextStyle: const TextStyle(
            color: Color(0xFFCFE0FF),
            fontWeight: FontWeight.w800,
            fontSize: 13,
          ),
          dataTextStyle: const TextStyle(
            color: Color(0xFFE8EEF7),
            fontSize: 13,
          ),
          columns: const [
            DataColumn(label: Text('Make')),
            DataColumn(label: Text('Model')),
            DataColumn(label: Text('Caliber')),
            DataColumn(label: Text('Type')),
            DataColumn(label: Text('Status')),
            DataColumn(label: Text('Serial')),
            DataColumn(label: Text('Nickname')),
          ],
          rows: _firearms.map((firearm) {
            return DataRow(
              cells: [
                DataCell(Text(firearm.make)),
                DataCell(Text(firearm.model)),
                DataCell(Text(firearm.caliber)),
                DataCell(Text(firearm.type)),
                DataCell(_buildStatusChip(firearm.status)),
                DataCell(Text(firearm.serial ?? '')),
                DataCell(Text(firearm.nickname)),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildAmmunitionTable() {
    if (_ammunition.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(20),
        child: Text(
          'No ammunition in inventory',
          style: TextStyle(color: Color(0xFF9AA4B2), fontSize: 13),
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFF222838)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          headingRowColor: MaterialStateProperty.all(const Color(0xFF101522)),
          dataRowMaxHeight: 50,
          columnSpacing: 20,
          headingTextStyle: const TextStyle(
            color: Color(0xFFCFE0FF),
            fontWeight: FontWeight.w800,
            fontSize: 13,
          ),
          dataTextStyle: const TextStyle(
            color: Color(0xFFE8EEF7),
            fontSize: 13,
          ),
          columns: const [
            DataColumn(label: Text('Brand')),
            DataColumn(label: Text('Line')),
            DataColumn(label: Text('Caliber')),
            DataColumn(label: Text('Bullet')),
            DataColumn(label: Text('Status')),
            DataColumn(label: Text('Quantity')),
            DataColumn(label: Text('Lot')),
          ],
          rows: _ammunition.map((ammo) {
            return DataRow(
              cells: [
                DataCell(Text(ammo.brand)),
                DataCell(Text(ammo.line ?? '')),
                DataCell(Text(ammo.caliber)),
                DataCell(Text(ammo.bullet)),
                DataCell(_buildStatusChip(ammo.status)),
                DataCell(Text('${ammo.quantity}')),
                DataCell(Text(ammo.lot ?? '')),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildGearTable() {
    if (_gear.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(20),
        child: Text(
          'No gear in inventory',
          style: TextStyle(color: Color(0xFF9AA4B2), fontSize: 13),
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFF222838)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          headingRowColor: MaterialStateProperty.all(const Color(0xFF101522)),
          dataRowMaxHeight: 50,
          columnSpacing: 20,
          headingTextStyle: const TextStyle(
            color: Color(0xFFCFE0FF),
            fontWeight: FontWeight.w800,
            fontSize: 13,
          ),
          dataTextStyle: const TextStyle(
            color: Color(0xFFE8EEF7),
            fontSize: 13,
          ),
          columns: const [
            DataColumn(label: Text('Category')),
            DataColumn(label: Text('Model')),
            DataColumn(label: Text('Serial')),
            DataColumn(label: Text('Qty')),
            DataColumn(label: Text('Notes')),
          ],
          rows: _gear.map((gear) {
            return DataRow(
              cells: [
                DataCell(Text(gear.category)),
                DataCell(Text(gear.model)),
                DataCell(Text(gear.serial ?? '')),
                DataCell(Text('${gear.quantity}')),
                DataCell(Text(gear.notes ?? '')),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildToolsTable() {
    if (_tools.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(20),
        child: Text(
          'No tools in inventory',
          style: TextStyle(color: Color(0xFF9AA4B2), fontSize: 13),
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFF222838)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          headingRowColor: MaterialStateProperty.all(const Color(0xFF101522)),
          dataRowMaxHeight: 50,
          columnSpacing: 20,
          headingTextStyle: const TextStyle(
            color: Color(0xFFCFE0FF),
            fontWeight: FontWeight.w800,
            fontSize: 13,
          ),
          dataTextStyle: const TextStyle(
            color: Color(0xFFE8EEF7),
            fontSize: 13,
          ),
          columns: const [
            DataColumn(label: Text('Name')),
            DataColumn(label: Text('Category')),
            DataColumn(label: Text('Status')),
            DataColumn(label: Text('Qty')),
          ],
          rows: _tools.map((tool) {
            return DataRow(
              cells: [
                DataCell(Text(tool.name)),
                DataCell(Text(tool.category ?? '')),
                DataCell(_buildStatusChip(tool.status)),
                DataCell(Text('${tool.quantity}')),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildLoadoutsTable() {
    if (_loadouts.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(20),
        child: Text(
          'No loadouts configured',
          style: TextStyle(color: Color(0xFF9AA4B2), fontSize: 13),
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFF222838)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          headingRowColor: MaterialStateProperty.all(const Color(0xFF101522)),
          dataRowMaxHeight: 50,
          columnSpacing: 20,
          headingTextStyle: const TextStyle(
            color: Color(0xFFCFE0FF),
            fontWeight: FontWeight.w800,
            fontSize: 13,
          ),
          dataTextStyle: const TextStyle(
            color: Color(0xFFE8EEF7),
            fontSize: 13,
          ),
          columns: const [
            DataColumn(label: Text('Name')),
            DataColumn(label: Text('Firearm')),
            DataColumn(label: Text('Ammo')),
            DataColumn(label: Text('Gear')),
            DataColumn(label: Text('Notes')),
          ],
          rows: _loadouts.map((loadout) {
            return DataRow(
              cells: [
                DataCell(Text(loadout.name)),
                DataCell(Text(loadout.firearmId ?? '')),
                DataCell(Text(loadout.ammunitionId ?? '')),
                DataCell(Text('${loadout.gearIds.length} items')),
                DataCell(Text(loadout.notes ?? '')),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildStatusChip(String status) {
    Color color;
    switch (status.toLowerCase()) {
      case 'available':
        color = const Color(0xFF51CF66);
        break;
      case 'in-use':
      case 'low-stock':
        color = const Color(0xFFFFD43B);
        break;
      case 'maintenance':
      case 'out-of-stock':
        color = const Color(0xFFFF6B6B);
        break;
      default:
        color = const Color(0xFF9AA4B2);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        border: Border.all(color: color.withOpacity(0.2)),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        status,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  void _printReport() {
    // Expand all sections for printing
    setState(() {
      _expandedSections.updateAll((key, value) => true);
    });

    // Show print dialog or share functionality
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Print functionality would be implemented here'),
        backgroundColor: Color(0xFF57B7FF),
      ),
    );
  }
}