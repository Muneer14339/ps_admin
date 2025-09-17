// lib/user_dashboard/presentation/widgets/add_maintenance_dialog.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/armory_maintenance.dart';
import '../../domain/entities/armory_firearm.dart';
import '../../domain/entities/armory_gear.dart';
import '../../domain/entities/dropdown_option.dart';
import '../bloc/armory_bloc.dart';
import '../bloc/armory_event.dart';
import '../bloc/armory_state.dart';
import '../core/theme/app_theme.dart';
import 'common/dialog_widgets.dart';

class AddMaintenanceDialog extends StatefulWidget {
  final String userId;

  const AddMaintenanceDialog({super.key, required this.userId});

  @override
  State<AddMaintenanceDialog> createState() => _AddMaintenanceDialogState();
}

class _AddMaintenanceDialogState extends State<AddMaintenanceDialog> {
  final _formKey = GlobalKey<FormState>();
  final _controllers = <String, TextEditingController>{};
  final _dropdownValues = <String, String?>{};

  List<DropdownOption> _assetOptions = [];
  List<ArmoryFirearm> _allFirearms = [];
  List<ArmoryGear> _allGear = [];
  DateTime _selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _initializeControllers();
    _loadInitialData();
  }

  void _initializeControllers() {
    final fields = ['rounds', 'notes'];
    for (final field in fields) {
      _controllers[field] = TextEditingController();
    }
    _controllers['rounds']?.text = '0';
  }

  void _loadInitialData() {
    context.read<ArmoryBloc>().add(LoadFirearmsEvent(userId: widget.userId));
    context.read<ArmoryBloc>().add(LoadGearEvent(userId: widget.userId));
  }

  void _handleAssetTypeChange(String? assetType) {
    setState(() {
      _dropdownValues['assetType'] = assetType;
      _dropdownValues['asset'] = null;
      _updateAssetOptions();
    });
  }

  void _updateAssetOptions() {
    setState(() {
      if (_dropdownValues['assetType'] == 'firearm') {
        _assetOptions = _allFirearms.map((firearm) => DropdownOption(
          value: firearm.id!,
          label: '${firearm.nickname} (${firearm.make} ${firearm.model})',
        )).toList();
      } else if (_dropdownValues['assetType'] == 'gear') {
        _assetOptions = _allGear.map((gear) => DropdownOption(
          value: gear.id!,
          label: '${gear.model} (${gear.category})',
        )).toList();
      } else {
        _assetOptions.clear();
      }
    });
  }

  void _handleFirearmsLoaded(List<ArmoryFirearm> firearms) {
    setState(() {
      _allFirearms = firearms;
      _updateAssetOptions();
    });
  }

  void _handleGearLoaded(List<ArmoryGear> gear) {
    setState(() {
      _allGear = gear;
      _updateAssetOptions();
    });
  }

  @override
  void dispose() {
    _controllers.values.forEach((controller) => controller.dispose());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ArmoryBloc, ArmoryState>(
      listener: (context, state) {
        if (state is FirearmsLoaded) {
          _handleFirearmsLoaded(state.firearms);
        } else if (state is GearLoaded) {
          _handleGearLoaded(state.gear);
        } else if (state is ArmoryActionSuccess) {
          Navigator.of(context).pop();
        }
      },
      child: CommonDialogWidgets.buildDialogWrapper(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CommonDialogWidgets.buildHeader(
              title: 'Log Maintenance',
              onClose: () => Navigator.of(context).pop(),
            ),
            Flexible(child: _buildForm()),
            BlocBuilder<ArmoryBloc, ArmoryState>(
              builder: (context, state) {
                return CommonDialogWidgets.buildActions(
                  onCancel: () => Navigator.of(context).pop(),
                  onSave: _saveMaintenance,
                  saveButtonText: 'Save Log',
                  isLoading: state is ArmoryLoadingAction,
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildForm() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSizes.dialogPadding),
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            // Asset Type and Asset
            CommonDialogWidgets.buildResponsiveRow([
              CommonDialogWidgets.buildDropdownField(
                label: 'Asset Type *',
                value: _dropdownValues['assetType'],
                options: [
                  const DropdownOption(value: 'firearm', label: 'Firearm'),
                  const DropdownOption(value: 'gear', label: 'Gear'),
                ],
                onChanged: _handleAssetTypeChange,
                isRequired: true,
              ),
              CommonDialogWidgets.buildDropdownField(
                label: 'Asset *',
                value: _dropdownValues['asset'],
                options: _assetOptions,
                onChanged: (value) => setState(() => _dropdownValues['asset'] = value),
                isRequired: true,
                enabled: _dropdownValues['assetType'] != null && _assetOptions.isNotEmpty,
              ),
            ]),
            const SizedBox(height: AppSizes.fieldSpacing),

            // Maintenance Type and Date
            CommonDialogWidgets.buildResponsiveRow([
              CommonDialogWidgets.buildDropdownField(
                label: 'Maintenance Type *',
                value: _dropdownValues['maintenanceType'],
                options: [
                  const DropdownOption(value: 'cleaning', label: 'Cleaning'),
                  const DropdownOption(value: 'lubrication', label: 'Lubrication'),
                  const DropdownOption(value: 'inspection', label: 'Inspection'),
                  const DropdownOption(value: 'repair', label: 'Repair'),
                  const DropdownOption(value: 'replacement', label: 'Part Replacement'),
                ],
                onChanged: (value) => setState(() => _dropdownValues['maintenanceType'] = value),
                isRequired: true,
              ),
              _buildDatePickerField(),
            ]),
            const SizedBox(height: AppSizes.fieldSpacing),

            // Rounds Fired
            CommonDialogWidgets.buildTextField(
              label: 'Rounds Fired (if applicable)',
              controller: _controllers['rounds']!,
              keyboardType: TextInputType.number,
              hintText: '0',
            ),
            const SizedBox(height: AppSizes.fieldSpacing),

            // Notes
            CommonDialogWidgets.buildTextField(
              label: 'Notes',
              controller: _controllers['notes']!,
              maxLines: 3,
              hintText: 'Details of maintenance performed',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDatePickerField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Date', style: AppTextStyles.fieldLabel),
        const SizedBox(height: 6),
        InkWell(
          onTap: () async {
            final date = await showDatePicker(
              context: context,
              initialDate: _selectedDate,
              firstDate: DateTime(2020),
              lastDate: DateTime.now().add(const Duration(days: 30)),
              builder: (context, child) {
                return Theme(
                  data: Theme.of(context).copyWith(
                    colorScheme: const ColorScheme.dark(
                      primary: AppColors.accentText,
                      surface: AppColors.cardBackground,
                    ),
                  ),
                  child: child!,
                );
              },
            );
            if (date != null) {
              setState(() => _selectedDate = date);
            }
          },
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.inputBackground,
              borderRadius: BorderRadius.circular(AppSizes.borderRadius),
              border: Border.all(color: AppColors.primaryBorder),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                    style: const TextStyle(color: AppColors.primaryText, fontSize: 14),
                  ),
                ),
                const Icon(Icons.calendar_today, color: AppColors.secondaryText, size: 16),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _saveMaintenance() {
    if (!_formKey.currentState!.validate()) return;

    // Validation
    if (_dropdownValues['assetType'] == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Asset type is required'), backgroundColor: AppColors.errorColor),
      );
      return;
    }

    if (_dropdownValues['asset'] == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Asset selection is required'), backgroundColor: AppColors.errorColor),
      );
      return;
    }

    if (_dropdownValues['maintenanceType'] == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Maintenance type is required'), backgroundColor: AppColors.errorColor),
      );
      return;
    }

    final maintenance = ArmoryMaintenance(
      assetType: _dropdownValues['assetType']!,
      assetId: _dropdownValues['asset']!,
      maintenanceType: _dropdownValues['maintenanceType']!,
      date: _selectedDate,
      roundsFired: int.tryParse(_controllers['rounds']?.text.trim() ?? '0'),
      notes: _controllers['notes']?.text.trim(),
      dateAdded: DateTime.now(),
    );

    context.read<ArmoryBloc>().add(
      AddMaintenanceEvent(userId: widget.userId, maintenance: maintenance),
    );
  }
}