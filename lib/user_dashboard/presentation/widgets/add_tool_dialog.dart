// lib/user_dashboard/presentation/widgets/add_tool_dialog.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/armory_tool.dart';
import '../../domain/entities/dropdown_option.dart';
import '../bloc/armory_bloc.dart';
import '../bloc/armory_event.dart';
import '../bloc/armory_state.dart';
import '../core/theme/app_theme.dart';
import 'common/dialog_widgets.dart';

class AddToolDialog extends StatefulWidget {
  final String userId;

  const AddToolDialog({super.key, required this.userId});

  @override
  State<AddToolDialog> createState() => _AddToolDialogState();
}

class _AddToolDialogState extends State<AddToolDialog> {
  final _formKey = GlobalKey<FormState>();
  final _controllers = <String, TextEditingController>{};
  String? _category;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
  }

  void _initializeControllers() {
    final fields = ['name', 'quantity', 'notes'];
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
              title: 'Add Tool',
              onClose: () => Navigator.of(context).pop(),
            ),
            Flexible(child: _buildForm()),
            BlocBuilder<ArmoryBloc, ArmoryState>(
              builder: (context, state) {
                return CommonDialogWidgets.buildActions(
                  onCancel: () => Navigator.of(context).pop(),
                  onSave: _saveTool,
                  saveButtonText: 'Save Tool',
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
              hintText: 'e.g., Wheeler FAT Wrench',
            ),
            const SizedBox(height: AppSizes.fieldSpacing),

            CommonDialogWidgets.buildResponsiveRow([
              CommonDialogWidgets.buildDropdownField(
                label: 'Category',
                value: _category,
                options: [
                  const DropdownOption(value: 'cleaning', label: 'Cleaning'),
                  const DropdownOption(value: 'maintenance', label: 'Maintenance'),
                  const DropdownOption(value: 'measurement', label: 'Measurement'),
                  const DropdownOption(value: 'reloading', label: 'Reloading'),
                  const DropdownOption(value: 'safety', label: 'Safety'),
                ],
                onChanged: (value) => setState(() => _category = value),
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
              hintText: 'Details about this tool',
            ),
          ],
        ),
      ),
    );
  }

  void _saveTool() {
    if (!_formKey.currentState!.validate()) return;

    final tool = ArmoryTool(
      name: _controllers['name']?.text.trim() ?? '',
      category: _category,
      quantity: int.tryParse(_controllers['quantity']?.text.trim() ?? '1') ?? 1,
      notes: _controllers['notes']?.text.trim(),
      dateAdded: DateTime.now(),
    );

    context.read<ArmoryBloc>().add(
      AddToolEvent(userId: widget.userId, tool: tool),
    );
  }
}