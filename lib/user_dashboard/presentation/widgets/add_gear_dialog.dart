// lib/user_dashboard/presentation/widgets/add_gear_dialog.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/armory_gear.dart';
import '../../domain/entities/dropdown_option.dart';
import '../bloc/armory_bloc.dart';
import '../bloc/armory_event.dart';
import '../bloc/armory_state.dart';
import '../core/theme/app_theme.dart';
import 'common/dialog_widgets.dart';

class AddGearDialog extends StatefulWidget {
  final String userId;

  const AddGearDialog({super.key, required this.userId});

  @override
  State<AddGearDialog> createState() => _AddGearDialogState();
}

class _AddGearDialogState extends State<AddGearDialog> {
  final _formKey = GlobalKey<FormState>();
  final _controllers = <String, TextEditingController>{};
  String? _category;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
  }

  void _initializeControllers() {
    final fields = ['model', 'serial', 'quantity', 'notes'];
    for (final field in fields) {
      _controllers[field] = TextEditingController();
    }
    _controllers['quantity']?.text = '1';
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
              title: 'Add Gear',
              onClose: () => Navigator.of(context).pop(),
            ),
            Flexible(child: _buildForm()),
            BlocBuilder<ArmoryBloc, ArmoryState>(
              builder: (context, state) {
                return CommonDialogWidgets.buildActions(
                  onCancel: () => Navigator.of(context).pop(),
                  onSave: _saveGear,
                  saveButtonText: 'Save Gear',
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
            CommonDialogWidgets.buildDropdownField(
              label: 'Category *',
              value: _category,
              options: [
                const DropdownOption(value: 'optics', label: 'Optics'),
                const DropdownOption(value: 'supports', label: 'Supports'),
                const DropdownOption(value: 'attachments', label: 'Attachments'),
                const DropdownOption(value: 'sensors', label: 'Sensors'),
                const DropdownOption(value: 'misc', label: 'Miscellaneous'),
              ],
              onChanged: (value) => setState(() => _category = value),
              isRequired: true,
            ),
            const SizedBox(height: AppSizes.fieldSpacing),

            CommonDialogWidgets.buildTextField(
              label: 'Model/Name *',
              controller: _controllers['model']!,
              isRequired: true,
              hintText: 'e.g., Vortex Razor HD',
            ),
            const SizedBox(height: AppSizes.fieldSpacing),

            CommonDialogWidgets.buildResponsiveRow([
              CommonDialogWidgets.buildTextField(
                label: 'Serial Number',
                controller: _controllers['serial']!,
                hintText: 'Optional',
              ),
              CommonDialogWidgets.buildTextField(
                label: 'Quantity',
                controller: _controllers['quantity']!,
                keyboardType: TextInputType.number,
              ),
            ]),
            const SizedBox(height: AppSizes.fieldSpacing),

            CommonDialogWidgets.buildTextField(
              label: 'Notes',
              controller: _controllers['notes']!,
              maxLines: 3,
              hintText: 'Details about this gear',
            ),
          ],
        ),
      ),
    );
  }

  void _saveGear() {
    if (!_formKey.currentState!.validate()) return;

    final gear = ArmoryGear(
      category: _category!,
      model: _controllers['model']?.text.trim() ?? '',
      serial: _controllers['serial']?.text.trim(),
      quantity: int.tryParse(_controllers['quantity']?.text.trim() ?? '1') ?? 1,
      notes: _controllers['notes']?.text.trim(),
      dateAdded: DateTime.now(),
    );

    context.read<ArmoryBloc>().add(
      AddGearEvent(userId: widget.userId, gear: gear),
    );
  }
}
