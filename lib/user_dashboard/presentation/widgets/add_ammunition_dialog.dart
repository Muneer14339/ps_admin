// lib/user_dashboard/presentation/widgets/add_ammunition_dialog.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/usecases/usecase.dart';
import '../../domain/entities/armory_ammunition.dart';
import '../../domain/entities/dropdown_option.dart';
import '../bloc/armory_bloc.dart';
import '../bloc/armory_event.dart';
import '../bloc/armory_state.dart';

class AddAmmunitionDialog extends StatefulWidget {
  final String userId;

  const AddAmmunitionDialog({super.key, required this.userId});

  @override
  State<AddAmmunitionDialog> createState() => _AddAmmunitionDialogState();
}

class _AddAmmunitionDialogState extends State<AddAmmunitionDialog> {
  final _formKey = GlobalKey<FormState>();
  final _controllers = <String, TextEditingController>{};
  final _dropdownValues = <String, String?>{};
  final _errors = <String, String?>{};

  List<DropdownOption> _ammunitionBrands = [];
  List<DropdownOption> _calibers = [];

  @override
  void initState() {
    super.initState();
    _initializeControllers();
    _loadDropdownData();
  }

  void _initializeControllers() {
    final fields = [
      'line', 'bullet', 'quantity', 'lot', 'notes',
    ];

    for (final field in fields) {
      _controllers[field] = TextEditingController();
    }

    // Set default values
    _dropdownValues['status'] = 'available';
    _controllers['quantity']?.text = '20';
  }

  void _loadDropdownData() {
    context.read<ArmoryBloc>().add(
      const LoadDropdownOptionsEvent(type: DropdownType.ammunitionBrands),
    );
    context.read<ArmoryBloc>().add(
      const LoadDropdownOptionsEvent(type: DropdownType.calibers),
    );
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
          //maxWidth: 720,
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.9,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildHeader(),
              Flexible(child: _buildForm()),
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
            'Add Ammunition',
            style: TextStyle(
              color: Color(0xFFE8EEF7),
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFF57B7FF).withOpacity(0.1),
              border: Border.all(color: const Color(0xFF57B7FF).withOpacity(0.2)),
              borderRadius: BorderRadius.circular(6),
            ),
            child: const Text(
              'Level 1 UI',
              style: TextStyle(
                color: Color(0xFF57B7FF),
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
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
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Brand and Line
            LayoutBuilder(
              builder: (context, constraints) {
                final isTablet = constraints.maxWidth > 520;
                if (isTablet) {
                  return Row(
                    children: [
                      Expanded(child: _buildDropdownField('Brand *', 'brand', _ammunitionBrands, isRequired: true)),
                      const SizedBox(width: 10),
                      Expanded(child: _buildTextField('Product Line', 'line', hintText: 'e.g., Gold Medal Match, V-Max')),
                    ],
                  );
                } else {
                  return Column(
                    children: [
                      _buildDropdownField('Brand *', 'brand', _ammunitionBrands, isRequired: true),
                      const SizedBox(height: 16),
                      _buildTextField('Product Line', 'line', hintText: 'e.g., Gold Medal Match, V-Max'),
                    ],
                  );
                }
              },
            ),
            const SizedBox(height: 16),

            // Caliber and Bullet
            LayoutBuilder(
              builder: (context, constraints) {
                final isTablet = constraints.maxWidth > 520;
                if (isTablet) {
                  return Row(
                    children: [
                      Expanded(child: _buildDropdownField('Caliber *', 'caliber', _calibers, isRequired: true)),
                      const SizedBox(width: 10),
                      Expanded(child: _buildTextField('Bullet Weight & Type *', 'bullet', isRequired: true, hintText: 'e.g., 168 gr HPBT, 55 gr FMJ')),
                    ],
                  );
                } else {
                  return Column(
                    children: [
                      _buildDropdownField('Caliber *', 'caliber', _calibers, isRequired: true),
                      const SizedBox(height: 16),
                      _buildTextField('Bullet Weight & Type *', 'bullet', isRequired: true, hintText: 'e.g., 168 gr HPBT, 55 gr FMJ'),
                    ],
                  );
                }
              },
            ),
            const SizedBox(height: 16),

            // Quantity, Status, Lot
            LayoutBuilder(
              builder: (context, constraints) {
                final isTablet = constraints.maxWidth > 520;
                if (isTablet) {
                  return Row(
                    children: [
                      Expanded(child: _buildTextField('Quantity (rounds) *', 'quantity', isRequired: true, keyboardType: TextInputType.number, hintText: '20')),
                      const SizedBox(width: 10),
                      Expanded(child: _buildDropdownField(
                        'Status *',
                        'status',
                        [
                          const DropdownOption(value: 'available', label: 'Available'),
                          const DropdownOption(value: 'low-stock', label: 'Low Stock'),
                          const DropdownOption(value: 'out-of-stock', label: 'Out of Stock'),
                        ],
                        isRequired: true,
                      )),
                      const SizedBox(width: 10),
                      Expanded(child: _buildTextField('Lot Number', 'lot', hintText: 'ABC1234')),
                    ],
                  );
                } else {
                  return Column(
                    children: [
                      _buildTextField('Quantity (rounds) *', 'quantity', isRequired: true, keyboardType: TextInputType.number, hintText: '20'),
                      const SizedBox(height: 16),
                      _buildDropdownField(
                        'Status *',
                        'status',
                        [
                          const DropdownOption(value: 'available', label: 'Available'),
                          const DropdownOption(value: 'low-stock', label: 'Low Stock'),
                          const DropdownOption(value: 'out-of-stock', label: 'Out of Stock'),
                        ],
                        isRequired: true,
                      ),
                      const SizedBox(height: 16),
                      _buildTextField('Lot Number', 'lot', hintText: 'ABC1234'),
                    ],
                  );
                }
              },
            ),
            const SizedBox(height: 16),

            _buildTextField(
              'Notes',
              'notes',
              maxLines: 3,
              hintText: 'Performance notes, accuracy, reliability, etc.',
            ),
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
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Color(0xFFFF6B6B)),
            ),
            contentPadding: const EdgeInsets.all(12),
          ),
          validator: isRequired
              ? (value) {
            if (value == null || value.trim().isEmpty) {
              return '${label.replaceAll('*', '').trim()} is required';
            }
            if (field == 'quantity') {
              final qty = int.tryParse(value);
              if (qty == null || qty < 0) {
                return 'Quantity must be a valid number';
              }
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
                'Select ${label.replaceAll('*', '').trim().toLowerCase()}...',
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
              return '${label.replaceAll('*', '').trim()} is required';
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
                onPressed: isLoading ? null : _saveAmmunition,
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
                    : const Text('Save Ammunition'),
              );
            },
          ),
        ],
      ),
    );
  }

  void _saveAmmunition() {
    if (!_formKey.currentState!.validate()) return;

    final ammunition = ArmoryAmmunition(
      brand: _dropdownValues['brand']!,
      line: _controllers['line']?.text.trim(),
      caliber: _dropdownValues['caliber']!,
      bullet: _controllers['bullet']?.text.trim() ?? '',
      quantity: int.tryParse(_controllers['quantity']?.text.trim() ?? '0') ?? 0,
      status: _dropdownValues['status']!,
      lot: _controllers['lot']?.text.trim(),
      notes: _controllers['notes']?.text.trim(),
      dateAdded: DateTime.now(),
    );

    context.read<ArmoryBloc>().add(
      AddAmmunitionEvent(userId: widget.userId, ammunition: ammunition),
    );
  }
}