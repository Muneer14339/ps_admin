import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/armory_loadout.dart';
import '../../domain/entities/dropdown_option.dart';
import '../bloc/armory_bloc.dart';
import '../bloc/armory_event.dart';
import '../bloc/armory_state.dart';
// lib/user_dashboard/presentation/widgets/add_loadout_dialog.dart
class AddLoadoutDialog extends StatefulWidget {
  final String userId;

  const AddLoadoutDialog({super.key, required this.userId});

  @override
  State<AddLoadoutDialog> createState() => _AddLoadoutDialogState();
}

class _AddLoadoutDialogState extends State<AddLoadoutDialog> {
  final _formKey = GlobalKey<FormState>();
  final _controllers = <String, TextEditingController>{};
  final _dropdownValues = <String, String?>{};

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
      child: Dialog(
        backgroundColor: const Color(0xFF151923),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          width: MediaQuery.of(context).size.width * 0.9,
          //maxWidth: 600,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildHeader(),
              _buildForm(),
              _buildActions(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0xFF222838))),
      ),
      child: Row(
        children: [
          const Text(
            'Create Loadout',
            style: TextStyle(
              color: Color(0xFFE8EEF7),
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Spacer(),
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.close, color: Color(0xFFE8EEF7)),
          ),
        ],
      ),
    );
  }

  Widget _buildForm() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            _buildTextField('Name *', 'name', isRequired: true, hintText: 'e.g., Precision .308'),
            const SizedBox(height: 16),
            _buildDropdownField('Firearm', 'firearm', []),  // TODO: Load from user's firearms
            const SizedBox(height: 16),
            _buildDropdownField('Ammunition', 'ammunition', []),  // TODO: Load from user's ammunition
            const SizedBox(height: 16),
            _buildTextField('Notes', 'notes', maxLines: 3, hintText: 'Purpose, conditions, etc.'),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(
      String label,
      String field, {
        bool isRequired = false,
        int maxLines = 1,
        String? hintText,
        TextInputType keyboardType = TextInputType.text,
      }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Color(0xFF9AA4B2),
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: _controllers[field],
          maxLines: maxLines,
          keyboardType: keyboardType,
          style: const TextStyle(color: Color(0xFFE8EEF7), fontSize: 14),
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: TextStyle(color: const Color(0xFF9AA4B2).withOpacity(0.6)),
            filled: true,
            fillColor: const Color(0xFF0B1020),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Color(0xFF222838)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Color(0xFF222838)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Color(0xFF57B7FF)),
            ),
            contentPadding: const EdgeInsets.all(12),
          ),
          validator: isRequired
              ? (value) {
            if (value == null || value.trim().isEmpty) {
              return '${label.replaceAll('*', '').trim()} is required';
            }
            return null;
          }
              : null,
        ),
      ],
    );
  }

  Widget _buildDropdownField(
      String label,
      String field,
      List<DropdownOption> options, {
        bool isRequired = false,
      }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Color(0xFF9AA4B2),
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 6),
        DropdownButtonFormField<String>(
          value: _dropdownValues[field],
          decoration: InputDecoration(
            filled: true,
            fillColor: const Color(0xFF0B1020),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Color(0xFF222838)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Color(0xFF222838)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Color(0xFF57B7FF)),
            ),
            contentPadding: const EdgeInsets.all(12),
          ),
          dropdownColor: const Color(0xFF151923),
          style: const TextStyle(color: Color(0xFFE8EEF7), fontSize: 14),
          items: [
            DropdownMenuItem<String>(
              value: null,
              child: Text(
                'Select ${label.toLowerCase()}...',
                style: TextStyle(color: const Color(0xFF9AA4B2).withOpacity(0.6)),
              ),
            ),
            ...options.map((option) => DropdownMenuItem<String>(
              value: option.value,
              child: Text(option.label),
            )),
          ],
          onChanged: (value) {
            setState(() => _dropdownValues[field] = value);
          },
          validator: isRequired
              ? (value) {
            if (value == null || value.isEmpty) {
              return '${label} is required';
            }
            return null;
          }
              : null,
        ),
      ],
    );
  }

  Widget _buildActions() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: Color(0xFF222838))),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text(
              'Cancel',
              style: TextStyle(color: Color(0xFF9AA4B2)),
            ),
          ),
          const SizedBox(width: 8),
          BlocBuilder<ArmoryBloc, ArmoryState>(
            builder: (context, state) {
              final isLoading = state is ArmoryLoadingAction;
              return ElevatedButton(
                onPressed: isLoading ? null : _saveLoadout,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2A3BFF).withOpacity(0.15),
                  foregroundColor: const Color(0xFFDBE6FF),
                  side: BorderSide(
                    color: const Color(0xFF3050FF).withOpacity(0.35),
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
                child: isLoading
                    ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Color(0xFFDBE6FF),
                  ),
                )
                    : const Text('Save Loadout'),
              );
            },
          ),
        ],
      ),
    );
  }

  void _saveLoadout() {
    if (!_formKey.currentState!.validate()) return;

    final loadout = ArmoryLoadout(
      name: _controllers['name']?.text.trim() ?? '',
      firearmId: _dropdownValues['firearm'],
      ammunitionId: _dropdownValues['ammunition'],
      gearIds: const [], // Simplified for now
      notes: _controllers['notes']?.text.trim(),
      dateAdded: DateTime.now(),
    );

    context.read<ArmoryBloc>().add(
      AddLoadoutEvent(userId: widget.userId, loadout: loadout),
    );
  }
}