// lib/user_dashboard/presentation/widgets/add_loadout_dialog.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/armory_loadout.dart';
import '../../domain/entities/dropdown_option.dart';
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
  String? _firearm;
  String? _ammunition;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
  }

  void _initializeControllers() {
    final fields = ['name', 'notes'];
    for (final field in fields) {
      _controllers[field] = TextEditingController();
    }
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
        if (state is ArmoryActionSuccess) {
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
            CommonDialogWidgets.buildTextField(
              label: 'Name *',
              controller: _controllers['name']!,
              isRequired: true,
              hintText: 'e.g., Precision .308',
            ),
            const SizedBox(height: AppSizes.fieldSpacing),

            CommonDialogWidgets.buildDropdownField(
              label: 'Firearm',
              value: _firearm,
              options: [], // TODO: Load from user's firearms
              onChanged: (value) => setState(() => _firearm = value),
            ),
            const SizedBox(height: AppSizes.fieldSpacing),

            CommonDialogWidgets.buildDropdownField(
              label: 'Ammunition',
              value: _ammunition,
              options: [], // TODO: Load from user's ammunition
              onChanged: (value) => setState(() => _ammunition = value),
            ),
            const SizedBox(height: AppSizes.fieldSpacing),

            CommonDialogWidgets.buildTextField(
              label: 'Notes',
              controller: _controllers['notes']!,
              maxLines: 3,
              hintText: 'Purpose, conditions, etc.',
            ),
          ],
        ),
      ),
    );
  }

  void _saveLoadout() {
    if (!_formKey.currentState!.validate()) return;

    final loadout = ArmoryLoadout(
      name: _controllers['name']?.text.trim() ?? '',
      firearmId: _firearm,
      ammunitionId: _ammunition,
      gearIds: const [],
      notes: _controllers['notes']?.text.trim(),
      dateAdded: DateTime.now(),
    );

    context.read<ArmoryBloc>().add(
      AddLoadoutEvent(userId: widget.userId, loadout: loadout),
    );
  }
}