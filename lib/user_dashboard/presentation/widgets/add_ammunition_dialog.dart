// lib/user_dashboard/presentation/widgets/add_ammunition_dialog.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/usecases/usecase.dart';
import '../../domain/entities/armory_ammunition.dart';
import '../../domain/entities/dropdown_option.dart';
import '../../domain/usecases/get_dropdown_options_usecase.dart';
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

  // Dropdown options lists
  List<DropdownOption> _ammunitionBrands = [];
  List<DropdownOption> _calibers = [];
  List<DropdownOption> _bulletTypes = [];

  // Loading states for individual dropdowns
  bool _loadingBrands = false;
  bool _loadingCalibers = false;
  bool _loadingBulletTypes = false;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
    _loadInitialData();
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

  void _loadInitialData() {
    setState(() {
      _loadingBrands = true;
    });

    context.read<ArmoryBloc>().add(
      const LoadDropdownOptionsEvent(type: DropdownType.ammunitionBrands),
    );
  }

  void _loadCalibersForBrand(String brand) {
    setState(() {
      _loadingCalibers = true;
      _calibers.clear();
      _bulletTypes.clear();
      // Clear dependent dropdown values
      _dropdownValues['caliber'] = null;
      _dropdownValues['bulletType'] = null;
    });

    context.read<ArmoryBloc>().add(
      LoadDropdownOptionsEvent(
        type: DropdownType.calibers,
        filterValue: brand, // Filter calibers by brand
      ),
    );
  }

  void _loadBulletTypesForBrandCaliber(String brand, String caliber) {
    setState(() {
      _loadingBulletTypes = true;
      _bulletTypes.clear();
      _dropdownValues['bulletType'] = null;
    });

    // This would load bullet weights/types based on brand and caliber
    // For now, we'll provide common bullet types
    Future.delayed(const Duration(milliseconds: 500), () {
      setState(() {
        _bulletTypes = _getCommonBulletTypes(caliber);
        _loadingBulletTypes = false;
      });
    });
  }

  List<DropdownOption> _getCommonBulletTypes(String caliber) {
    // Common bullet types based on caliber
    switch (caliber.toLowerCase()) {
      case '.223 rem':
      case '5.56x45':
        return [
          const DropdownOption(value: '55gr FMJ', label: '55 gr FMJ'),
          const DropdownOption(value: '62gr M855', label: '62 gr M855'),
          const DropdownOption(value: '77gr OTM', label: '77 gr OTM'),
          const DropdownOption(value: '69gr SMK', label: '69 gr SMK'),
        ];
      case '.308 win':
      case '7.62x51':
        return [
          const DropdownOption(value: '147gr FMJ', label: '147 gr FMJ'),
          const DropdownOption(value: '168gr HPBT', label: '168 gr HPBT'),
          const DropdownOption(value: '175gr SMK', label: '175 gr SMK'),
          const DropdownOption(value: '178gr ELD-X', label: '178 gr ELD-X'),
        ];
      case '9mm':
        return [
          const DropdownOption(value: '115gr FMJ', label: '115 gr FMJ'),
          const DropdownOption(value: '124gr HP', label: '124 gr HP'),
          const DropdownOption(value: '147gr HP', label: '147 gr HP'),
        ];
      case '.45 acp':
        return [
          const DropdownOption(value: '230gr FMJ', label: '230 gr FMJ'),
          const DropdownOption(value: '185gr HP', label: '185 gr HP'),
        ];
      default:
        return [
          const DropdownOption(value: 'custom', label: 'Custom - Enter manually'),
        ];
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
    if (_loadingBrands) {
      setState(() {
        _ammunitionBrands = options;
        _loadingBrands = false;
      });
    } else if (_loadingCalibers) {
      setState(() {
        _calibers = options;
        _loadingCalibers = false;
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
              'Smart Dropdowns',
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
            // Step 1: Brand selection (triggers caliber loading)
            _buildDropdownField(
              'Brand *',
              'brand',
              _ammunitionBrands,
              isRequired: true,
              isLoading: _loadingBrands,
              onChanged: (value) {
                if (value != null) {
                  _loadCalibersForBrand(value);
                }
              },
            ),
            const SizedBox(height: 16),

            // Product Line field
            _buildTextField(
              'Product Line',
              'line',
              hintText: 'e.g., Gold Medal Match, V-Max, American Eagle',
            ),
            const SizedBox(height: 16),

            // Step 2: Caliber selection (shows after brand is selected)
            _buildDropdownField(
              'Caliber *',
              'caliber',
              _calibers,
              isRequired: true,
              isLoading: _loadingCalibers,
              enabled: _dropdownValues['brand'] != null,
              onChanged: (value) {
                if (value != null && _dropdownValues['brand'] != null) {
                  _loadBulletTypesForBrandCaliber(_dropdownValues['brand']!, value);
                }
              },
            ),
            const SizedBox(height: 16),

            // Step 3: Bullet type selection or manual entry
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildDropdownField(
                  'Bullet Weight & Type *',
                  'bulletType',
                  _bulletTypes,
                  isRequired: false,
                  isLoading: _loadingBulletTypes,
                  enabled: _dropdownValues['caliber'] != null,
                  onChanged: (value) {
                    if (value == 'custom') {
                      // Clear the dropdown and let user enter manually
                      setState(() {
                        _dropdownValues['bulletType'] = null;
                      });
                    } else if (value != null) {
                      // Set the bullet text field to the selected value
                      _controllers['bullet']?.text = value;
                    }
                  },
                ),
                const SizedBox(height: 8),
                Text(
                  'Or enter manually:',
                  style: TextStyle(
                    color: const Color(0xFF9AA4B2).withOpacity(0.8),
                    fontSize: 11,
                  ),
                ),
                const SizedBox(height: 4),
                _buildTextField(
                  'Custom Bullet Description',
                  'bullet',
                  hintText: 'e.g., 168 gr HPBT, 55 gr FMJ, 77 gr SMK',
                  enabled: _dropdownValues['caliber'] != null,
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Quantity, Status, Lot in responsive layout
            LayoutBuilder(
              builder: (context, constraints) {
                final isTablet = constraints.maxWidth > 520;
                if (isTablet) {
                  return Row(
                    children: [
                      Expanded(child: _buildTextField(
                        'Quantity (rounds) *',
                        'quantity',
                        isRequired: true,
                        keyboardType: TextInputType.number,
                        hintText: '20',
                      )),
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
                      _buildTextField(
                        'Quantity (rounds) *',
                        'quantity',
                        isRequired: true,
                        keyboardType: TextInputType.number,
                        hintText: '20',
                      ),
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
              hintText: 'Performance notes, accuracy, reliability, chronograph data, etc.',
            ),

            // Add helpful info card
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF57B7FF).withOpacity(0.05),
                border: Border.all(color: const Color(0xFF57B7FF).withOpacity(0.2)),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '💡 Smart Entry Tips',
                    style: TextStyle(
                      color: const Color(0xFF57B7FF),
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '• Select brand first to see available calibers\n'
                        '• Choose caliber to see common bullet types\n'
                        '• Use "Custom" option for special loads\n'
                        '• Notes field is great for chronograph data',
                    style: TextStyle(
                      color: const Color(0xFF9AA4B2),
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
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
        bool enabled = true,
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
          enabled: enabled,
          style: TextStyle(
            color: enabled ? const Color(0xFFE8EEF7) : const Color(0xFFE8EEF7).withOpacity(0.5),
            fontSize: 14,
          ),
          decoration: InputDecoration(
            hintText: enabled ? hintText : 'Select caliber first...',
            hintStyle: TextStyle(color: const Color(0xFF9AA4B2).withOpacity(0.6)),
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
                'Select brand first...',
                style: TextStyle(color: const Color(0xFF9AA4B2).withOpacity(0.6)),
              ),
            ),
          ]
              : [
            DropdownMenuItem<String>(
              value: null,
              child: Text(
                isLoading
                    ? 'Loading options...'
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
            setState(() => _dropdownValues[field] = value);
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

    // Get bullet description from either dropdown selection or manual entry
    String bulletDescription = _controllers['bullet']?.text.trim() ?? '';
    if (bulletDescription.isEmpty && _dropdownValues['bulletType'] != null) {
      bulletDescription = _dropdownValues['bulletType']!;
    }

    if (bulletDescription.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please specify bullet weight and type'),
          backgroundColor: Color(0xFFFF6B6B),
        ),
      );
      return;
    }

    final ammunition = ArmoryAmmunition(
      brand: _dropdownValues['brand']!,
      line: _controllers['line']?.text.trim(),
      caliber: _dropdownValues['caliber']!,
      bullet: bulletDescription,
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