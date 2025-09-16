
// lib/user_dashboard/presentation/widgets/add_ammunition_dialog.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/usecases/usecase.dart';
import '../../domain/entities/armory_ammunition.dart';
import '../../domain/entities/dropdown_option.dart';
import '../bloc/armory_bloc.dart';
import '../bloc/armory_event.dart';
import '../bloc/armory_state.dart';
import '../core/theme/app_theme.dart';
import 'common/dialog_widgets.dart';

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

  // Dropdown options
  List<DropdownOption> _ammunitionBrands = [];
  List<DropdownOption> _calibers = [];
  List<DropdownOption> _bulletTypes = [];

  // Loading states
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
    final fields = ['line', 'bullet', 'quantity', 'lot', 'notes'];

    for (final field in fields) {
      _controllers[field] = TextEditingController();
    }

    _dropdownValues['status'] = 'available';
    _controllers['quantity']?.text = '20';
  }

  void _loadInitialData() {
    setState(() => _loadingBrands = true);
    context.read<ArmoryBloc>().add(
      const LoadDropdownOptionsEvent(type: DropdownType.ammunitionBrands),
    );
  }

  void _loadCalibersForBrand(String brand) {
    setState(() {
      _loadingCalibers = true;
      _calibers.clear();
      _bulletTypes.clear();
      _dropdownValues['caliber'] = null;
      _dropdownValues['bulletType'] = null;
    });

    context.read<ArmoryBloc>().add(
      LoadDropdownOptionsEvent(type: DropdownType.calibers, filterValue: brand),
    );
  }

  void _loadBulletTypesForBrandCaliber(String brand, String caliber) {
    setState(() {
      _loadingBulletTypes = true;
      _bulletTypes.clear();
      _dropdownValues['bulletType'] = null;
    });

    Future.delayed(const Duration(milliseconds: 500), () {
      setState(() {
        _bulletTypes = _getCommonBulletTypes(caliber);
        _loadingBulletTypes = false;
      });
    });
  }

  List<DropdownOption> _getCommonBulletTypes(String caliber) {
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
      child: CommonDialogWidgets.buildDialogWrapper(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CommonDialogWidgets.buildHeader(
              title: 'Add Ammunition',
              badge: 'Level 1 UI',
              onClose: () => Navigator.of(context).pop(),
            ),
            Flexible(child: _buildForm()),
            BlocBuilder<ArmoryBloc, ArmoryState>(
              builder: (context, state) {
                return CommonDialogWidgets.buildActions(
                  onCancel: () => Navigator.of(context).pop(),
                  onSave: _saveAmmunition,
                  saveButtonText: 'Save Ammunition',
                  isLoading: state is ArmoryLoadingAction,
                );
              },
            ),
          ],
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

  Widget _buildForm() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSizes.dialogPadding),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CommonDialogWidgets.buildDropdownField(
              label: 'Brand *',
              value: _dropdownValues['brand'],
              options: _ammunitionBrands,
              onChanged: (value) {
                setState(() => _dropdownValues['brand'] = value);
                if (value != null) _loadCalibersForBrand(value);
              },
              isRequired: true,
              isLoading: _loadingBrands,
            ),
            const SizedBox(height: AppSizes.fieldSpacing),

            CommonDialogWidgets.buildTextField(
              label: 'Product Line',
              controller: _controllers['line']!,
              hintText: 'e.g., Gold Medal Match, V-Max, American Eagle',
            ),
            const SizedBox(height: AppSizes.fieldSpacing),

            CommonDialogWidgets.buildDropdownField(
              label: 'Caliber *',
              value: _dropdownValues['caliber'],
              options: _calibers,
              onChanged: (value) {
                setState(() => _dropdownValues['caliber'] = value);
                if (value != null && _dropdownValues['brand'] != null) {
                  _loadBulletTypesForBrandCaliber(_dropdownValues['brand']!, value);
                }
              },
              isRequired: true,
              isLoading: _loadingCalibers,
              enabled: _dropdownValues['brand'] != null,
            ),
            const SizedBox(height: AppSizes.fieldSpacing),

            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CommonDialogWidgets.buildDropdownField(
                  label: 'Bullet Weight & Type *',
                  value: _dropdownValues['bulletType'],
                  options: _bulletTypes,
                  onChanged: (value) {
                    setState(() => _dropdownValues['bulletType'] = value);
                    if (value == 'custom') {
                      setState(() => _dropdownValues['bulletType'] = null);
                    } else if (value != null) {
                      _controllers['bullet']?.text = value;
                    }
                  },
                  isRequired: false,
                  isLoading: _loadingBulletTypes,
                  enabled: _dropdownValues['caliber'] != null,
                ),
              ],
            ),
            const SizedBox(height: AppSizes.fieldSpacing),

            CommonDialogWidgets.buildResponsiveRow([
              CommonDialogWidgets.buildTextField(
                label: 'Quantity (rounds) *',
                controller: _controllers['quantity']!,
                isRequired: true,
                keyboardType: TextInputType.number,
                hintText: '20',
              ),
              CommonDialogWidgets.buildDropdownField(
                label: 'Status *',
                value: _dropdownValues['status'],
                options: [
                  const DropdownOption(value: 'available', label: 'Available'),
                  const DropdownOption(value: 'low-stock', label: 'Low Stock'),
                  const DropdownOption(value: 'out-of-stock', label: 'Out of Stock'),
                ],
                onChanged: (value) => setState(() => _dropdownValues['status'] = value),
                isRequired: true,
              ),
            ]),
            const SizedBox(height: AppSizes.fieldSpacing),

            CommonDialogWidgets.buildTextField(
              label: 'Lot Number',
              controller: _controllers['lot']!,
              hintText: 'ABC1234',
            ),
            const SizedBox(height: AppSizes.fieldSpacing),

            CommonDialogWidgets.buildTextField(
              label: 'Notes',
              controller: _controllers['notes']!,
              maxLines: 3,
              hintText: 'Performance notes, accuracy, reliability, chronograph data, etc.',
            ),
            const SizedBox(height: AppSizes.fieldSpacing),

          ],
        ),
      ),
    );
  }

  void _saveAmmunition() {
    if (!_formKey.currentState!.validate()) return;

    String bulletDescription = _controllers['bullet']?.text.trim() ?? '';
    if (bulletDescription.isEmpty && _dropdownValues['bulletType'] != null) {
      bulletDescription = _dropdownValues['bulletType']!;
    }

    if (bulletDescription.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please specify bullet weight and type'),
          backgroundColor: AppColors.errorColor,
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