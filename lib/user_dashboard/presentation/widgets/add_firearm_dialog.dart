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
import '../core/theme/app_theme.dart';
import 'common/dialog_widgets.dart';

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

  // Dropdown options
  List<DropdownOption> _firearmBrands = [];
  List<DropdownOption> _firearmModels = [];
  List<DropdownOption> _firearmGenerations = [];
  List<DropdownOption> _firearmMakes = [];
  List<DropdownOption> _firearmMechanisms = [];
  List<DropdownOption> _calibers = [];

  // Loading states
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
    final fields = ['make', 'model', 'nickname', 'serial', 'notes'];

    for (final field in fields) {
      _controllers[field] = TextEditingController();
    }

    _dropdownValues['status'] = 'available';
    _dropdownValues['condition'] = 'good';
  }

  void _loadInitialData() {
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
      _dropdownValues['brand'] = null;
      _dropdownValues['model'] = null;
      _dropdownValues['generation'] = null;
    });

    context.read<ArmoryBloc>().add(
      LoadDropdownOptionsEvent(type: DropdownType.firearmBrands, filterValue: type),
    );
  }

  void _loadModelsForBrand(String brand) {
    setState(() {
      _loadingModels = true;
      _firearmModels.clear();
      _firearmGenerations.clear();
      _dropdownValues['model'] = null;
      _dropdownValues['generation'] = null;
    });

    context.read<ArmoryBloc>().add(
      LoadDropdownOptionsEvent(type: DropdownType.firearmModels, filterValue: brand),
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
      child: CommonDialogWidgets.buildDialogWrapper(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CommonDialogWidgets.buildHeader(
              title: 'Add Firearm',
              badge: 'Level 1 UI',
              onClose: () => Navigator.of(context).pop(),
            ),
            Flexible(child: _buildForm()),
            BlocBuilder<ArmoryBloc, ArmoryState>(
              builder: (context, state) {
                return CommonDialogWidgets.buildActions(
                  onCancel: () => Navigator.of(context).pop(),
                  onSave: _saveFirearm,
                  saveButtonText: 'Save Firearm',
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

  Widget _buildForm() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSizes.dialogPadding),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CommonDialogWidgets.buildDropdownField(
              label: 'Firearm Type *',
              value: _dropdownValues['type'],
              options: [
                const DropdownOption(value: 'rifle', label: 'Rifle'),
                const DropdownOption(value: 'pistol', label: 'Pistol'),
                const DropdownOption(value: 'revolver', label: 'Revolver'),
                const DropdownOption(value: 'shotgun', label: 'Shotgun'),
              ],
              onChanged: (value) {
                setState(() => _dropdownValues['type'] = value);
                if (value != null) _loadBrandsForType(value);
              },
              isRequired: true,
            ),
            const SizedBox(height: AppSizes.fieldSpacing),

            CommonDialogWidgets.buildDropdownField(
              label: 'Brand *',
              value: _dropdownValues['brand'],
              options: _firearmBrands,
              onChanged: (value) {
                setState(() => _dropdownValues['brand'] = value);
                if (value != null) _loadModelsForBrand(value);
              },
              isRequired: true,
              isLoading: _loadingBrands,
              enabled: _dropdownValues['type'] != null,
            ),
            const SizedBox(height: AppSizes.fieldSpacing),

            CommonDialogWidgets.buildDropdownField(
              label: 'Model *',
              value: _dropdownValues['model'],
              options: _firearmModels,
              onChanged: (value) {
                setState(() => _dropdownValues['model'] = value);
                if (value != null && _dropdownValues['brand'] != null) {
                  _loadGenerationsForBrandModel(_dropdownValues['brand']!, value);
                }
              },
              isRequired: true,
              isLoading: _loadingModels,
              enabled: _dropdownValues['brand'] != null,
            ),
            const SizedBox(height: AppSizes.fieldSpacing),

            CommonDialogWidgets.buildDropdownField(
              label: 'Generation',
              value: _dropdownValues['generation'],
              options: _firearmGenerations,
              onChanged: (value) => setState(() => _dropdownValues['generation'] = value),
              isLoading: _loadingGenerations,
              enabled: _dropdownValues['model'] != null,
            ),
            const SizedBox(height: AppSizes.fieldSpacing),

            CommonDialogWidgets.buildResponsiveRow([
              CommonDialogWidgets.buildDropdownField(
                label: 'Make *',
                value: _dropdownValues['make'],
                options: _firearmMakes,
                onChanged: (value) => setState(() => _dropdownValues['make'] = value),
                isRequired: true,
                isLoading: _loadingMakes,
              ),
              CommonDialogWidgets.buildDropdownField(
                label: 'Caliber *',
                value: _dropdownValues['caliber'],
                options: _calibers,
                onChanged: (value) => setState(() => _dropdownValues['caliber'] = value),
                isRequired: true,
                isLoading: _loadingCalibers,
              ),
            ]),
            const SizedBox(height: AppSizes.fieldSpacing),

            CommonDialogWidgets.buildResponsiveRow([
              CommonDialogWidgets.buildTextField(
                label: 'Nickname/Identifier *',
                controller: _controllers['nickname']!,
                isRequired: true,
              ),
              CommonDialogWidgets.buildDropdownField(
                label: 'Firing Mechanism',
                value: _dropdownValues['firingMechanism'],
                options: _firearmMechanisms,
                onChanged: (value) => setState(() => _dropdownValues['firingMechanism'] = value),
                isLoading: _loadingMechanisms,
              ),
            ]),
            const SizedBox(height: AppSizes.fieldSpacing),

            CommonDialogWidgets.buildResponsiveRow([
              CommonDialogWidgets.buildDropdownField(
                label: 'Status *',
                value: _dropdownValues['status'],
                options: [
                  const DropdownOption(value: 'available', label: 'Available'),
                  const DropdownOption(value: 'in-use', label: 'In Use'),
                  const DropdownOption(value: 'maintenance', label: 'Maintenance'),
                ],
                onChanged: (value) => setState(() => _dropdownValues['status'] = value),
                isRequired: true,
              ),
              CommonDialogWidgets.buildTextField(
                label: 'Serial Number',
                controller: _controllers['serial']!,
              ),
            ]),
            const SizedBox(height: AppSizes.fieldSpacing),

            CommonDialogWidgets.buildTextField(
              label: 'Notes',
              controller: _controllers['notes']!,
              maxLines: 3,
              hintText: 'Purpose, setup, special considerations, etc.',
            ),
          ],
        ),
      ),
    );
  }

  void _saveFirearm() {
    if (!_formKey.currentState!.validate()) return;

    // Additional validation
    bool hasErrors = false;

    // Check required dropdowns
    final requiredDropdowns = {
      'type': 'Firearm type is required',
      'brand': 'Brand is required',
      'model': 'Model is required',
      'make': 'Make is required',
      'caliber': 'Caliber is required',
      'status': 'Status is required',
    };

    requiredDropdowns.forEach((field, errorMessage) {
      if (_dropdownValues[field] == null) {
        setState(() => _errors[field] = errorMessage);
        hasErrors = true;
      }
    });

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
      dateAdded: DateTime.now(),
    );

    context.read<ArmoryBloc>().add(
      AddFirearmEvent(userId: widget.userId, firearm: firearm),
    );
  }
}
