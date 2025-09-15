// lib/user_dashboard/presentation/widgets/add_firearm_dialog.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/usecases/usecase.dart';
import '../../domain/entities/armory_firearm.dart';
import '../../domain/entities/dropdown_option.dart';
import '../../domain/usecases/get_dropdown_options_usecase.dart';
import '../bloc/armory_bloc.dart';
import '../bloc/armory_event.dart';
import '../bloc/armory_state.dart';

class AddFirearmDialog extends StatefulWidget {
  final String userId;

  const AddFirearmDialog({super.key, required this.userId});

  @override
  State<AddFirearmDialog> createState() => _AddFirearmDialogState();
}

class _AddFirearmDialogState extends State<AddFirearmDialog> {
  final _formKey = GlobalKey<FormState>();
  final _controllers = <String, TextEditingController>{};
  final _dropdownValues = <String, String?>{};
  final _errors = <String, String?>{};

  List<DropdownOption> _firearmBrands = [];
  List<DropdownOption> _firearmModels = [];
  List<DropdownOption> _firearmGenerations = [];
  List<DropdownOption> _firearmMakes = [];
  List<DropdownOption> _firearmMechanisms = [];
  List<DropdownOption> _calibers = [];

  @override
  void initState() {
    super.initState();
    _initializeControllers();
    _loadDropdownData();
  }

  void _initializeControllers() {
    final fields = [
      'make', 'model', 'nickname', 'serial', 'notes',
      'detailedType', 'purpose', 'condition', 'purchaseDate',
      'purchasePrice', 'currentValue', 'fflDealer', 'manufacturerPN',
      'finish', 'stockMaterial', 'triggerType', 'safetyType',
      'feedSystem', 'magazineCapacity', 'twistRate', 'threadPattern',
      'overallLength', 'weight', 'barrelLength', 'actionType',
      'roundCount', 'lastCleaned', 'zeroDistance', 'modifications',
      'accessoriesIncluded', 'storageLocation'
    ];

    for (final field in fields) {
      _controllers[field] = TextEditingController();
    }

    // Set default values
    _dropdownValues['status'] = 'available';
    _dropdownValues['condition'] = 'good';
    _controllers['roundCount']?.text = '0';
  }

  void _loadDropdownData() {
    context.read<ArmoryBloc>().add(
      const LoadDropdownOptionsEvent(type: DropdownType.firearmBrands),
    );
    context.read<ArmoryBloc>().add(
      const LoadDropdownOptionsEvent(type: DropdownType.firearmMakes),
    );
    context.read<ArmoryBloc>().add(
      const LoadDropdownOptionsEvent(type: DropdownType.firearmFiringMechanisms),
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
        if (state is DropdownOptionsLoaded) {
          // Handle dropdown data loading
          // This is simplified - in real implementation, you'd need to track which dropdown was loaded
        } else if (state is ArmoryActionSuccess) {
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
            'Add Firearm',
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
            _buildDropdownField(
              'Firearm Type *',
              'type',
              [
                const DropdownOption(value: 'rifle', label: 'Rifle'),
                const DropdownOption(value: 'pistol', label: 'Pistol'),
                const DropdownOption(value: 'revolver', label: 'Revolver'),
                const DropdownOption(value: 'shotgun', label: 'Shotgun'),
              ],
              isRequired: true,
            ),
            const SizedBox(height: 16),

            // Responsive row layout
            LayoutBuilder(
              builder: (context, constraints) {
                final isTablet = constraints.maxWidth > 520;
                if (isTablet) {
                  return Row(
                    children: [
                      Expanded(child: _buildTextField('Make *', 'make', isRequired: true)),
                      const SizedBox(width: 10),
                      Expanded(child: _buildTextField('Model *', 'model', isRequired: true)),
                    ],
                  );
                } else {
                  return Column(
                    children: [
                      _buildTextField('Make *', 'make', isRequired: true),
                      const SizedBox(height: 16),
                      _buildTextField('Model *', 'model', isRequired: true),
                    ],
                  );
                }
              },
            ),
            const SizedBox(height: 16),

            LayoutBuilder(
              builder: (context, constraints) {
                final isTablet = constraints.maxWidth > 520;
                if (isTablet) {
                  return Row(
                    children: [
                      Expanded(child: _buildDropdownField('Caliber *', 'caliber', _calibers, isRequired: true)),
                      const SizedBox(width: 10),
                      Expanded(child: _buildTextField('Nickname/Identifier *', 'nickname', isRequired: true)),
                    ],
                  );
                } else {
                  return Column(
                    children: [
                      _buildDropdownField('Caliber *', 'caliber', _calibers, isRequired: true),
                      const SizedBox(height: 16),
                      _buildTextField('Nickname/Identifier *', 'nickname', isRequired: true),
                    ],
                  );
                }
              },
            ),
            const SizedBox(height: 16),

            LayoutBuilder(
              builder: (context, constraints) {
                final isTablet = constraints.maxWidth > 520;
                if (isTablet) {
                  return Row(
                    children: [
                      Expanded(child: _buildDropdownField(
                        'Status *',
                        'status',
                        [
                          const DropdownOption(value: 'available', label: 'Available'),
                          const DropdownOption(value: 'in-use', label: 'In Use'),
                          const DropdownOption(value: 'maintenance', label: 'Maintenance'),
                        ],
                        isRequired: true,
                      )),
                      const SizedBox(width: 10),
                      Expanded(child: _buildTextField('Serial Number', 'serial')),
                    ],
                  );
                } else {
                  return Column(
                    children: [
                      _buildDropdownField(
                        'Status *',
                        'status',
                        [
                          const DropdownOption(value: 'available', label: 'Available'),
                          const DropdownOption(value: 'in-use', label: 'In Use'),
                          const DropdownOption(value: 'maintenance', label: 'Maintenance'),
                        ],
                        isRequired: true,
                      ),
                      const SizedBox(height: 16),
                      _buildTextField('Serial Number', 'serial'),
                    ],
                  );
                }
              },
            ),
            const SizedBox(height: 16),

            // Additional fields from existing model
            LayoutBuilder(
              builder: (context, constraints) {
                final isTablet = constraints.maxWidth > 520;
                if (isTablet) {
                  return Row(
                    children: [
                      Expanded(child: _buildDropdownField('Brand', 'brand', _firearmBrands)),
                      const SizedBox(width: 10),
                      Expanded(child: _buildTextField('Generation', 'generation')),
                    ],
                  );
                } else {
                  return Column(
                    children: [
                      _buildDropdownField('Brand', 'brand', _firearmBrands),
                      const SizedBox(height: 16),
                      _buildTextField('Generation', 'generation'),
                    ],
                  );
                }
              },
            ),
            const SizedBox(height: 16),

            _buildDropdownField('Firing Mechanism', 'firingMechanism', _firearmMechanisms),
            const SizedBox(height: 16),

            _buildTextField(
              'Notes',
              'notes',
              maxLines: 3,
              hintText: 'Purpose, setup, special considerations, etc.',
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
            return null;
          }
              : null,
          onChanged: (value) {
            if (_errors[field] != null) {
              setState(() => _errors[field] = null);
            }
          },
        ),
        if (_errors[field] != null)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              _errors[field]!,
              style: const TextStyle(
                color: Color(0xFFFF6B6B),
                fontSize: 12,
              ),
            ),
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
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Color(0xFFFF6B6B)),
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
            setState(() {
              _dropdownValues[field] = value;
              if (_errors[field] != null) {
                _errors[field] = null;
              }
            });

            // Handle cascading dropdowns
            if (field == 'brand' && value != null) {
              context.read<ArmoryBloc>().add(
                LoadDropdownOptionsEvent(
                  type: DropdownType.firearmModels,
                  filterValue: value,
                ),
              );
            } else if (field == 'model' && value != null && _dropdownValues['brand'] != null) {
              context.read<ArmoryBloc>().add(
                LoadDropdownOptionsEvent(
                  type: DropdownType.firearmGenerations,
                  filterValue: _dropdownValues['brand']!,
                  secondaryFilter: value,
                ),
              );
            }
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
        if (_errors[field] != null)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              _errors[field]!,
              style: const TextStyle(
                color: Color(0xFFFF6B6B),
                fontSize: 12,
              ),
            ),
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
                onPressed: isLoading ? null : _saveFirearm,
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
                    : const Text('Save Firearm'),
              );
            },
          ),
        ],
      ),
    );
  }

  void _saveFirearm() {
    if (!_formKey.currentState!.validate()) return;

    // Additional validation
    bool hasErrors = false;

    // Check required dropdowns
    if (_dropdownValues['type'] == null) {
      setState(() => _errors['type'] = 'Firearm type is required for loadout compatibility');
      hasErrors = true;
    }

    if (_dropdownValues['caliber'] == null) {
      setState(() => _errors['caliber'] = 'Caliber is required');
      hasErrors = true;
    }

    if (_dropdownValues['status'] == null) {
      setState(() => _errors['status'] = 'Status is required');
      hasErrors = true;
    }

    // Check nickname uniqueness (simplified - in real implementation, you'd check against existing data)
    final nickname = _controllers['nickname']?.text.trim() ?? '';
    if (nickname.isEmpty) {
      setState(() => _errors['nickname'] = 'Nickname is required and must be unique');
      hasErrors = true;
    }

    if (hasErrors) return;

    final firearm = ArmoryFirearm(
      type: _dropdownValues['type']!,
      make: _controllers['make']?.text.trim() ?? '',
      model: _controllers['model']?.text.trim() ?? '',
      caliber: _dropdownValues['caliber']!,
      nickname: nickname,
      status: _dropdownValues['status']!,
      serial: _controllers['serial']?.text.trim(),
      notes: _controllers['notes']?.text.trim(),
      brand: _dropdownValues['brand'],
      generation: _controllers['generation']?.text.trim(),
      firingMechanism: _dropdownValues['firingMechanism'],
      // Include all Level 3 fields with default values
      detailedType: _controllers['detailedType']?.text.trim(),
      purpose: _controllers['purpose']?.text.trim(),
      condition: _dropdownValues['condition'] ?? 'good',
      purchaseDate: _controllers['purchaseDate']?.text.trim(),
      purchasePrice: _controllers['purchasePrice']?.text.trim(),
      currentValue: _controllers['currentValue']?.text.trim(),
      fflDealer: _controllers['fflDealer']?.text.trim(),
      manufacturerPN: _controllers['manufacturerPN']?.text.trim(),
      finish: _controllers['finish']?.text.trim(),
      stockMaterial: _controllers['stockMaterial']?.text.trim(),
      triggerType: _controllers['triggerType']?.text.trim(),
      safetyType: _controllers['safetyType']?.text.trim(),
      feedSystem: _controllers['feedSystem']?.text.trim(),
      magazineCapacity: _controllers['magazineCapacity']?.text.trim(),
      twistRate: _controllers['twistRate']?.text.trim(),
      threadPattern: _controllers['threadPattern']?.text.trim(),
      overallLength: _controllers['overallLength']?.text.trim(),
      weight: _controllers['weight']?.text.trim(),
      barrelLength: _controllers['barrelLength']?.text.trim(),
      actionType: _controllers['actionType']?.text.trim(),
      roundCount: int.tryParse(_controllers['roundCount']?.text.trim() ?? '0') ?? 0,
      lastCleaned: _controllers['lastCleaned']?.text.trim(),
      zeroDistance: _controllers['zeroDistance']?.text.trim(),
      modifications: _controllers['modifications']?.text.trim(),
      accessoriesIncluded: _controllers['accessoriesIncluded']?.text.trim(),
      storageLocation: _controllers['storageLocation']?.text.trim(),
      photos: const [],
      dateAdded: DateTime.now(),
    );

    context.read<ArmoryBloc>().add(
      AddFirearmEvent(userId: widget.userId, firearm: firearm),
    );
  }
}