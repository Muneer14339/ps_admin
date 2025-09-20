// lib/user_dashboard/presentation/widgets/add_firearm_dialog.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/usecases/usecase.dart';
import '../../domain/entities/armory_firearm.dart';
import '../../domain/entities/dropdown_option.dart';
import '../bloc/armory_bloc.dart';
import '../bloc/armory_event.dart';
import '../bloc/armory_state.dart';
import '../core/theme/app_theme.dart';
import 'common/dialog_widgets.dart';
import 'common/enhanced_dialog_widgets.dart';

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
  }

  // Helper method to determine if we should use grid layout
  bool get _shouldUseGridLayout {
    final orientation = MediaQuery.of(context).orientation;
    return orientation == Orientation.landscape;
  }

  // Helper method to build responsive layout
  Widget _buildResponsiveLayout(List<Widget> children) {
    if (!_shouldUseGridLayout) {
      return Column(children: children);
    }

    final List<Widget> rows = [];
    for (int i = 0; i < children.length; i += 2) {
      if (i + 1 < children.length) {
        rows.add(
          Row(
            children: [
              Expanded(child: children[i]),
              const SizedBox(width: AppSizes.fieldSpacing),
              Expanded(child: children[i + 1]),
            ],
          ),
        );
      } else {
        rows.add(children[i]);
      }
      if (i + 2 < children.length) {
        rows.add(const SizedBox(height: AppSizes.fieldSpacing));
      }
    }
    return Column(children: rows);
  }

  void _loadBrandsForType(String type) {
    setState(() {
      _loadingBrands = true;
      _clearAllDependentDropdowns();
    });

    context.read<ArmoryBloc>().add(
      LoadDropdownOptionsEvent(type: DropdownType.firearmBrands, filterValue: type),
    );
  }

  void _loadModelsForBrand(String brand) {
    setState(() {
      _loadingModels = true;
      _firearmModels.clear();
      _clearDependentDropdowns(['model', 'generation', 'caliber', 'firingMechanism', 'make']);
    });

    context.read<ArmoryBloc>().add(
      LoadDropdownOptionsEvent(
        type: DropdownType.firearmModels,
        filterValue: brand,
      ),
    );
  }

  void _loadGenerationsForModel(String model) {
    setState(() {
      _loadingGenerations = true;
      _firearmGenerations.clear();
      _clearDependentDropdowns(['generation', 'caliber', 'firingMechanism', 'make']);
    });

    context.read<ArmoryBloc>().add(
      LoadDropdownOptionsEvent(
        type: DropdownType.firearmGenerations,
        filterValue: model,
      ),
    );
  }

  void _loadCalibersForSelection(String generation) {
    setState(() {
      _loadingCalibers = true;
      _calibers.clear();
      _clearDependentDropdowns(['caliber', 'firingMechanism', 'make']);
    });

    context.read<ArmoryBloc>().add(
      LoadDropdownOptionsEvent(
        type: DropdownType.calibers,
        filterValue: generation,
      ),
    );
  }

  void _loadFiringMechanismsForSelection(String caliber) {
    setState(() {
      _loadingMechanisms = true;
      _firearmMechanisms.clear();
      _clearDependentDropdowns(['firingMechanism', 'make']);
    });

    context.read<ArmoryBloc>().add(
      LoadDropdownOptionsEvent(
        type: DropdownType.firearmFiringMechanisms,
        filterValue: caliber,
      ),
    );
  }

  void _loadMakesForSelection(String firingMechanism) {
    setState(() {
      _loadingMakes = true;
      _firearmMakes.clear();
      _dropdownValues['make'] = null;
    });

    context.read<ArmoryBloc>().add(
      LoadDropdownOptionsEvent(
        type: DropdownType.firearmMakes,
        filterValue: firingMechanism,
      ),
    );
  }

  void _clearAllDependentDropdowns() {
    _firearmBrands.clear();
    _firearmModels.clear();
    _firearmGenerations.clear();
    _firearmMakes.clear();
    _firearmMechanisms.clear();
    _calibers.clear();

    _dropdownValues['brand'] = null;
    _dropdownValues['model'] = null;
    _dropdownValues['generation'] = null;
    _dropdownValues['make'] = null;
    _dropdownValues['firingMechanism'] = null;
    _dropdownValues['caliber'] = null;
  }

  void _clearDependentDropdowns(List<String> fields) {
    for (final field in fields) {
      _dropdownValues[field] = null;

      switch (field) {
        case 'model':
          _firearmModels.clear();
          break;
        case 'generation':
          _firearmGenerations.clear();
          break;
        case 'caliber':
          _calibers.clear();
          break;
        case 'firingMechanism':
          _firearmMechanisms.clear();
          break;
        case 'make':
          _firearmMakes.clear();
          break;
      }
    }
  }

  void _onBrandChanged(String? value) {
    setState(() => _dropdownValues['brand'] = value);
    if (value != null) {
      _loadModelsForBrand(value);
    }
  }

  void _onModelChanged(String? value) {
    setState(() => _dropdownValues['model'] = value);
    if (value != null && _dropdownValues['brand'] != null) {
      _loadGenerationsForModel(value);
    }
  }

  void _onGenerationChanged(String? value) {
    setState(() => _dropdownValues['generation'] = value);
    if (value != null) {
      _loadCalibersForSelection(value);
    }
  }

  void _onCaliberChanged(String? value) {
    setState(() => _dropdownValues['caliber'] = value);
    if (value != null) {
      _loadFiringMechanismsForSelection(value);
    }
  }

  void _onFiringMechanismChanged(String? value) {
    setState(() => _dropdownValues['firingMechanism'] = value);
    if (value != null) {
      _loadMakesForSelection(value);
    }
  }

  void _initializeControllers() {
    final fields = ['make', 'model', 'nickname', 'serial', 'notes'];

    for (final field in fields) {
      _controllers[field] = TextEditingController();
    }

    _dropdownValues['status'] = 'available';
    _dropdownValues['condition'] = 'good';
  }

  void _handleDropdownOptionsLoaded(List<DropdownOption> options) {
    setState(() {
      if (_loadingBrands) {
        _firearmBrands = options;
        _loadingBrands = false;
      }
      else if (_loadingMakes) {
        _firearmMakes = options;
        _loadingMakes = false;
      }
      else if (_loadingMechanisms) {
        _firearmMechanisms = options;
        _loadingMechanisms = false;
      }
      else if (_loadingModels) {
        _firearmModels = options;
        _loadingModels = false;
      }
      else if (_loadingGenerations) {
        _firearmGenerations = options;
        _loadingGenerations = false;
      }
      else if (_loadingCalibers) {
        _calibers = options;
        _loadingCalibers = false;
      }
    });
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

  Widget _buildForm() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSizes.dialogPadding),
      child: Form(
        key: _formKey,
        child: _buildResponsiveLayout([
          // Firearm Type
          CommonDialogWidgets.buildDropdownField(
            label: 'Firearm Type *',
            value: _dropdownValues['type'],
            options: [
              const DropdownOption(value: 'Rifle', label: 'Rifle'),
              const DropdownOption(value: 'Pistol', label: 'Pistol'),
              const DropdownOption(value: 'Revolver', label: 'Revolver'),
              const DropdownOption(value: 'Shotgun', label: 'Shotgun'),
            ],
            onChanged: (value) {
              setState(() => _dropdownValues['type'] = value);
              if (value != null) _loadBrandsForType(value);
            },
            isRequired: true,
          ),

          // Brand
          EnhancedDialogWidgets.buildDropdownFieldWithCustom(
            label: 'Brand *',
            value: _dropdownValues['brand'],
            options: _firearmBrands,
            onChanged: _onBrandChanged,
            customFieldLabel: 'Brand',
            customHintText: 'e.g., Custom Manufacturer',
            isRequired: true,
            isLoading: _loadingBrands,
            enabled: _dropdownValues['type'] != null,
          ),

          // Model
          EnhancedDialogWidgets.buildDropdownFieldWithCustom(
            label: 'Model *',
            value: _dropdownValues['model'],
            options: _firearmModels,
            onChanged: _onModelChanged,
            customFieldLabel: 'Model',
            customHintText: 'e.g., Custom Model Name',
            isRequired: true,
            isLoading: _loadingModels,
            enabled: _dropdownValues['brand'] != null,
          ),

          // Generation
          EnhancedDialogWidgets.buildDropdownFieldWithCustom(
            label: 'Generation',
            value: _dropdownValues['generation'],
            options: _firearmGenerations,
            onChanged: _onGenerationChanged,
            customFieldLabel: 'Generation',
            customHintText: 'e.g., Gen 5, Mk II',
            isLoading: _loadingGenerations,
            enabled: _dropdownValues['model'] != null,
          ),

          // Caliber
          EnhancedDialogWidgets.buildDropdownFieldWithCustom(
            label: 'Caliber *',
            value: _dropdownValues['caliber'],
            options: _calibers,
            onChanged: _onCaliberChanged,
            customFieldLabel: 'Caliber',
            customHintText: 'e.g., .300 WinMag',
            isRequired: true,
            isLoading: _loadingCalibers,
            enabled: _dropdownValues['brand'] != null,
          ),

          // Firing Mechanism
          EnhancedDialogWidgets.buildDropdownFieldWithCustom(
            label: 'Firing Mechanism',
            value: _dropdownValues['firingMechanism'],
            options: _firearmMechanisms,
            onChanged: _onFiringMechanismChanged,
            customFieldLabel: 'Firing Mechanism',
            customHintText: 'e.g., Custom Action',
            isLoading: _loadingMechanisms,
            enabled: _dropdownValues['type'] != null,
          ),

          // Make
          EnhancedDialogWidgets.buildDropdownFieldWithCustom(
            label: 'Make *',
            value: _dropdownValues['make'],
            options: _firearmMakes,
            onChanged: (value) => setState(() => _dropdownValues['make'] = value),
            customFieldLabel: 'Make',
            customHintText: 'e.g., Custom Make',
            isRequired: true,
            isLoading: _loadingMakes,
            enabled: _dropdownValues['type'] != null,
          ),

          // Nickname
          CommonDialogWidgets.buildTextField(
            label: 'Nickname/Identifier *',
            controller: _controllers['nickname']!,
            isRequired: true,
            maxLength: 20,
          ),

          // Status
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

          // Serial Number
          CommonDialogWidgets.buildTextField(
            label: 'Serial Number',
            controller: _controllers['serial']!,
            maxLength: 20,
          ),

          // Notes - Always full width
          _shouldUseGridLayout
              ? SizedBox(
            width: double.infinity,
            child: CommonDialogWidgets.buildTextField(
              label: 'Notes',
              controller: _controllers['notes']!,
              maxLines: 3,
              maxLength: 200,
              hintText: 'Purpose, setup, special considerations, etc.',
            ),
          )
              : CommonDialogWidgets.buildTextField(
            label: 'Notes',
            controller: _controllers['notes']!,
            maxLines: 3,
            maxLength: 200,
            hintText: 'Purpose, setup, special considerations, etc.',
          ),
        ]),
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
      make: EnhancedDialogWidgets.getDisplayValue(_dropdownValues['make']),
      model: EnhancedDialogWidgets.getDisplayValue(_dropdownValues['model']),
      caliber: EnhancedDialogWidgets.getDisplayValue(_dropdownValues['caliber']),
      nickname: nickname,
      status: _dropdownValues['status']!,
      serial: _controllers['serial']?.text.trim(),
      notes: _controllers['notes']?.text.trim(),
      brand: EnhancedDialogWidgets.getDisplayValue(_dropdownValues['brand']),
      generation: EnhancedDialogWidgets.getDisplayValue(_dropdownValues['generation']),
      firingMechanism: EnhancedDialogWidgets.getDisplayValue(_dropdownValues['firingMechanism']),
      dateAdded: DateTime.now(),
    );

    context.read<ArmoryBloc>().add(
      AddFirearmEvent(userId: widget.userId, firearm: firearm),
    );
  }
}