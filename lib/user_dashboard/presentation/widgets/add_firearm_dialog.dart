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

  // Dropdown options lists
  List<DropdownOption> _firearmBrands = [];
  List<DropdownOption> _firearmModels = [];
  List<DropdownOption> _firearmGenerations = [];
  List<DropdownOption> _firearmMakes = [];
  List<DropdownOption> _firearmMechanisms = [];
  List<DropdownOption> _calibers = [];

  // Loading states for individual dropdowns
  bool _loadingBrands = false;
  bool _loadingModels = false;
  bool _loadingGenerations = false;
  bool _loadingMakes = false;
  bool _loadingMechanisms = false;
  bool _loadingCalibers = false;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
    _loadInitialData();
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

  void _loadInitialData() {
    // Load initial static data
    setState(() {
      _loadingMakes = true;
      _loadingMechanisms = true;
      _loadingCalibers = true;
    });

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

  void _loadBrandsForType(String type) {
    setState(() {
      _loadingBrands = true;
      _firearmBrands.clear();
      _firearmModels.clear();
      _firearmGenerations.clear();
      // Clear dependent dropdown values
      _dropdownValues['brand'] = null;
      _dropdownValues['model'] = null;
      _dropdownValues['generation'] = null;
    });

    context.read<ArmoryBloc>().add(
      LoadDropdownOptionsEvent(
        type: DropdownType.firearmBrands,
        filterValue: type, // Filter brands by firearm type
      ),
    );
  }

  void _loadModelsForBrand(String brand) {
    setState(() {
      _loadingModels = true;
      _firearmModels.clear();
      _firearmGenerations.clear();
      // Clear dependent dropdown values
      _dropdownValues['model'] = null;
      _dropdownValues['generation'] = null;
    });

    context.read<ArmoryBloc>().add(
      LoadDropdownOptionsEvent(
        type: DropdownType.firearmModels,
        filterValue: brand,
      ),
    );
  }

  void _loadGenerationsForBrandModel(String brand, String model) {
    setState(() {
      _loadingGenerations = true;
      _firearmGenerations.clear();
      _dropdownValues['generation'] = null;
    });

    context.read<ArmoryBloc>().add(
      LoadDropdownOptionsEvent(
        type: DropdownType.firearmGenerations,
        filterValue: brand,
        secondaryFilter: model,
      ),
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
          _handleDropdownOptionsLoaded(state.options);
        } else if (state is ArmoryActionSuccess) {
          Navigator.of(context).pop();
        }
      },
      child: Dialog(
        backgroundColor: const Color(0xFF151923),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          width: MediaQuery.of(context).size.width * 0.9,
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

  void _handleDropdownOptionsLoaded(List<DropdownOption> options) {
    // Determine which dropdown was loaded based on current loading states
    if (_loadingMakes) {
      setState(() {
        _firearmMakes = options;
        _loadingMakes = false;
      });
    } else if (_loadingMechanisms) {
      setState(() {
        _firearmMechanisms = options;
        _loadingMechanisms = false;
      });
    } else if (_loadingCalibers) {
      setState(() {
        _calibers = options;
        _loadingCalibers = false;
      });
    } else if (_loadingBrands) {
      setState(() {
        _firearmBrands = options;
        _loadingBrands = false;
      });
    } else if (_loadingModels) {
      setState(() {
        _firearmModels = options;
        _loadingModels = false;
      });
    } else if (_loadingGenerations) {
      setState(() {
        _firearmGenerations = options;
        _loadingGenerations = false;
      });
    }
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
              'Cascading Dropdowns',
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
            // Step 1: Firearm Type (triggers brand loading)
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
              onChanged: (value) {
                if (value != null) {
                  _loadBrandsForType(value);
                }
              },
            ),
            const SizedBox(height: 16),

            // Step 2: Brand (shows after type is selected)
            _buildDropdownField(
              'Brand *',
              'brand',
              _firearmBrands,
              isRequired: true,
              isLoading: _loadingBrands,
              enabled: _dropdownValues['type'] != null,
              onChanged: (value) {
                if (value != null) {
                  _loadModelsForBrand(value);
                }
              },
            ),
            const SizedBox(height: 16),

            // Step 3: Model (shows after brand is selected)
            _buildDropdownField(
              'Model *',
              'model',
              _firearmModels,
              isRequired: true,
              isLoading: _loadingModels,
              enabled: _dropdownValues['brand'] != null,
              onChanged: (value) {
                if (value != null && _dropdownValues['brand'] != null) {
                  _loadGenerationsForBrandModel(_dropdownValues['brand']!, value);
                }
              },
            ),
            const SizedBox(height: 16),

            // Step 4: Generation (shows after model is selected)
            _buildDropdownField(
              'Generation',
              'generation',
              _firearmGenerations,
              isLoading: _loadingGenerations,
              enabled: _dropdownValues['model'] != null,
            ),
            const SizedBox(height: 16),

            // Other fields in responsive layout
            LayoutBuilder(
              builder: (context, constraints) {
                final isTablet = constraints.maxWidth > 520;
                if (isTablet) {
                  return Row(
                    children: [
                      Expanded(child: _buildDropdownField('Make *', 'make', _firearmMakes, isRequired: true, isLoading: _loadingMakes)),
                      const SizedBox(width: 10),
                      Expanded(child: _buildDropdownField('Caliber *', 'caliber', _calibers, isRequired: true, isLoading: _loadingCalibers)),
                    ],
                  );
                } else {
                  return Column(
                    children: [
                      _buildDropdownField('Make *', 'make', _firearmMakes, isRequired: true, isLoading: _loadingMakes),
                      const SizedBox(height: 16),
                      _buildDropdownField('Caliber *', 'caliber', _calibers, isRequired: true, isLoading: _loadingCalibers),
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
                      Expanded(child: _buildTextField('Nickname/Identifier *', 'nickname', isRequired: true)),
                      const SizedBox(width: 10),
                      Expanded(child: _buildDropdownField('Firing Mechanism', 'firingMechanism', _firearmMechanisms, isLoading: _loadingMechanisms)),
                    ],
                  );
                } else {
                  return Column(
                    children: [
                      _buildTextField('Nickname/Identifier *', 'nickname', isRequired: true),
                      const SizedBox(height: 16),
                      _buildDropdownField('Firing Mechanism', 'firingMechanism', _firearmMechanisms, isLoading: _loadingMechanisms),
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
        bool isLoading = false,
        bool enabled = true,
        Function(String?)? onChanged,
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
            fillColor: enabled ? const Color(0xFF0B1020) : const Color(0xFF0B1020).withOpacity(0.5),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Color(0xFF222838)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(
                color: enabled ? const Color(0xFF222838) : const Color(0xFF222838).withOpacity(0.5),
              ),
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
            suffixIcon: isLoading
                ? const Padding(
              padding: EdgeInsets.all(12),
              child: SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Color(0xFF57B7FF),
                ),
              ),
            )
                : null,
          ),
          dropdownColor: const Color(0xFF151923),
          style: TextStyle(
            color: enabled ? const Color(0xFFE8EEF7) : const Color(0xFFE8EEF7).withOpacity(0.5),
            fontSize: 14,
          ),
          items: !enabled
              ? [
            DropdownMenuItem<String>(
              value: null,
              child: Text(
                'Select ${label.split('*')[0].trim().split(' ').first.toLowerCase()} first...',
                style: TextStyle(color: const Color(0xFF9AA4B2).withOpacity(0.6)),
              ),
            ),
          ]
              : [
            DropdownMenuItem<String>(
              value: null,
              child: Text(
                isLoading
                    ? 'Loading...'
                    : 'Select ${label.replaceAll('*', '').trim().toLowerCase()}...',
                style: TextStyle(color: const Color(0xFF9AA4B2).withOpacity(0.6)),
              ),
            ),
            ...options.map((option) => DropdownMenuItem<String>(
              value: option.value,
              child: Text(option.label),
            )),
          ],
          onChanged: !enabled || isLoading
              ? null
              : (value) {
            setState(() {
              _dropdownValues[field] = value;
              if (_errors[field] != null) {
                _errors[field] = null;
              }
            });
            if (onChanged != null) {
              onChanged(value);
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
      setState(() => _errors['type'] = 'Firearm type is required');
      hasErrors = true;
    }

    if (_dropdownValues['brand'] == null) {
      setState(() => _errors['brand'] = 'Brand is required');
      hasErrors = true;
    }

    if (_dropdownValues['model'] == null) {
      setState(() => _errors['model'] = 'Model is required');
      hasErrors = true;
    }

    if (_dropdownValues['make'] == null) {
      setState(() => _errors['make'] = 'Make is required');
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

    // Check nickname uniqueness
    final nickname = _controllers['nickname']?.text.trim() ?? '';
    if (nickname.isEmpty) {
      setState(() => _errors['nickname'] = 'Nickname is required and must be unique');
      hasErrors = true;
    }

    if (hasErrors) return;

    final firearm = ArmoryFirearm(
      type: _dropdownValues['type']!,
      make: _dropdownValues['make']!,
      model: _dropdownValues['model']!,
      caliber: _dropdownValues['caliber']!,
      nickname: nickname,
      status: _dropdownValues['status']!,
      serial: _controllers['serial']?.text.trim(),
      notes: _controllers['notes']?.text.trim(),
      brand: _dropdownValues['brand'],
      generation: _dropdownValues['generation'],
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