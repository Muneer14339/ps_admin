// lib/user_dashboard/presentation/widgets/add_loadout_dialog.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/armory_loadout.dart';
import '../../domain/entities/dropdown_option.dart';
import '../../domain/entities/armory_firearm.dart';
import '../../domain/entities/armory_ammunition.dart';
import '../bloc/armory_bloc.dart';
import '../bloc/armory_event.dart';
import '../bloc/armory_state.dart';
import '../core/theme/app_theme.dart';
import 'common/dialog_widgets.dart';

class AddLoadoutDialog extends StatefulWidget {
  final String userId;

  const AddLoadoutDialog({super.key, required this.userId});

  @override
  State<AddLoadoutDialog> createState() => _AddLoadoutDialogState();
}

class _AddLoadoutDialogState extends State<AddLoadoutDialog> {
  final _formKey = GlobalKey<FormState>();
  final _controllers = <String, TextEditingController>{};
  String? _selectedFirearmId;
  String? _selectedAmmunitionId;

  List<DropdownOption> _firearmOptions = [];
  List<DropdownOption> _ammunitionOptions = [];
  bool _loadingFirearms = true;
  bool _loadingAmmunition = true;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
    _loadData();
  }

  void _initializeControllers() {
    final fields = ['name', 'notes'];
    for (final field in fields) {
      _controllers[field] = TextEditingController();
    }
  }

  void _loadData() {
    // Load user's firearms and ammunition
    context.read<ArmoryBloc>().add(LoadFirearmsEvent(userId: widget.userId));
    context.read<ArmoryBloc>().add(LoadAmmunitionEvent(userId: widget.userId));
  }

  void _handleFirearmsLoaded(List<ArmoryFirearm> firearms) {
    setState(() {
      _firearmOptions = firearms.map((firearm) => DropdownOption(
        value: firearm.id!,
        label: '${firearm.nickname} (${firearm.make} ${firearm.model})',
      )).toList();
      _loadingFirearms = false;
    });
  }

  void _handleAmmunitionLoaded(List<ArmoryAmmunition> ammunition) {
    setState(() {
      _ammunitionOptions = ammunition.map((ammo) => DropdownOption(
        value: ammo.id!,
        label: '${ammo.brand} ${ammo.caliber} ${ammo.bullet} (${ammo.quantity} rds)',
      )).toList();
      _loadingAmmunition = false;
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
        } else if (state is AmmunitionLoaded) {
          _handleAmmunitionLoaded(state.ammunition);
        } else if (state is ArmoryActionSuccess) {
          Navigator.of(context).pop();
        }
      },
      child: CommonDialogWidgets.buildDialogWrapper(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CommonDialogWidgets.buildHeader(
              title: 'Create Loadout',
              onClose: () => Navigator.of(context).pop(),
            ),
            Flexible(child: _buildForm()),
            BlocBuilder<ArmoryBloc, ArmoryState>(
              builder: (context, state) {
                return CommonDialogWidgets.buildActions(
                  onCancel: () => Navigator.of(context).pop(),
                  onSave: _saveLoadout,
                  saveButtonText: 'Save Loadout',
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
            // Loadout Name
            CommonDialogWidgets.buildTextField(
              label: 'Loadout Name *',
              controller: _controllers['name']!,
              isRequired: true,
              hintText: 'e.g., Precision .308, Competition Setup',
            ),
            const SizedBox(height: AppSizes.fieldSpacing),

            // Firearm Selection
            CommonDialogWidgets.buildDropdownField(
              label: 'Firearm',
              value: _selectedFirearmId,
              options: _firearmOptions,
              onChanged: (value) => setState(() => _selectedFirearmId = value),
              isLoading: _loadingFirearms,
              enabled: !_loadingFirearms,
            ),
            const SizedBox(height: AppSizes.fieldSpacing),

            // Ammunition Selection
            CommonDialogWidgets.buildDropdownField(
              label: 'Ammunition',
              value: _selectedAmmunitionId,
              options: _ammunitionOptions,
              onChanged: (value) => setState(() => _selectedAmmunitionId = value),
              isLoading: _loadingAmmunition,
              enabled: !_loadingAmmunition,
            ),
            const SizedBox(height: AppSizes.fieldSpacing),

            // Notes
            CommonDialogWidgets.buildTextField(
              label: 'Notes',
              controller: _controllers['notes']!,
              maxLines: 3,
              hintText: 'Purpose, conditions, special setup notes, etc.',
            ),
          ],
        ),
      ),
    );
  }

  void _saveLoadout() {
    if (!_formKey.currentState!.validate()) return;

    final name = _controllers['name']?.text.trim() ?? '';
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Loadout name is required'),
          backgroundColor: AppColors.errorColor,
        ),
      );
      return;
    }

    final loadout = ArmoryLoadout(
      name: name,
      firearmId: _selectedFirearmId,
      ammunitionId: _selectedAmmunitionId,
      gearIds: const [], // TODO: Add gear selection in future
      notes: _controllers['notes']?.text.trim(),
      dateAdded: DateTime.now(),
    );

    context.read<ArmoryBloc>().add(
      AddLoadoutEvent(userId: widget.userId, loadout: loadout),
    );
  }
}