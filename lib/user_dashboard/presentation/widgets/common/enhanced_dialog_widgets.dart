// lib/user_dashboard/presentation/widgets/common/enhanced_dialog_widgets.dart
import 'package:flutter/material.dart';
import '../../../domain/entities/dropdown_option.dart';
import '../../core/theme/app_theme.dart';
import 'custom_value_dialog.dart';

class EnhancedDialogWidgets {
  static Widget buildDropdownFieldWithCustom({
    required String label,
    required String? value,
    required List<DropdownOption> options,
    required void Function(String?) onChanged,
    required String customFieldLabel,
    required String customHintText,
    bool isRequired = false,
    bool isLoading = false,
    bool enabled = true,
    bool allowCustom = true,
    String? Function(String?)? validator,
  }) {
    // Show search when options > 5
    final showSearch = options.length > 5 && enabled && !isLoading;

    return showSearch
        ? _SearchableDropdownField(
      label: label,
      value: value,
      options: options,
      onChanged: onChanged,
      customFieldLabel: customFieldLabel,
      customHintText: customHintText,
      isRequired: isRequired,
      isLoading: isLoading,
      enabled: enabled,
      allowCustom: allowCustom,
      validator: validator,
    )
        : _buildStaticDropdown(
      label: label,
      value: value,
      options: options,
      onChanged: onChanged,
      customFieldLabel: customFieldLabel,
      customHintText: customHintText,
      isRequired: isRequired,
      isLoading: isLoading,
      enabled: enabled,
      allowCustom: allowCustom,
      validator: validator,
    );
  }

  // Original static dropdown (unchanged)
  static Widget _buildStaticDropdown({
    required String label,
    required String? value,
    required List<DropdownOption> options,
    required void Function(String?) onChanged,
    required String customFieldLabel,
    required String customHintText,
    bool isRequired = false,
    bool isLoading = false,
    bool enabled = true,
    bool allowCustom = true,
    String? Function(String?)? validator,
  }) {
    final allOptions = List<DropdownOption>.from(options);

    if (value != null && isCustomValue(value) && !allOptions.any((opt) => opt.value == value)) {
      allOptions.add(DropdownOption(
        value: value,
        label: getDisplayValue(value),
      ));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTextStyles.fieldLabel),
        const SizedBox(height: 6),
        DropdownButtonFormField<String>(
          value: value,
          isExpanded: true,
          decoration: _getInputDecoration(enabled: enabled, isLoading: isLoading),
          dropdownColor: AppColors.cardBackground,
          style: TextStyle(
            color: enabled ? AppColors.primaryText : AppColors.primaryText.withOpacity(0.5),
            fontSize: 14,
          ),
          items: !enabled
              ? [
            DropdownMenuItem<String>(
              value: null,
              child: Text(
                'Select required field first...',
                style: TextStyle(color: AppColors.secondaryText.withOpacity(0.6)),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ]
              : [
            DropdownMenuItem<String>(
              value: null,
              child: Text(
                isLoading ? 'Loading...' : 'Select ${label.replaceAll('*', '').trim().toLowerCase()}...',
                style: TextStyle(color: AppColors.secondaryText.withOpacity(0.6)),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            ...allOptions.map((option) => DropdownMenuItem<String>(
              value: option.value,
              child: Text(
                option.label,
                overflow: TextOverflow.ellipsis,
              ),
            )),
            if (allowCustom && !isLoading)
              DropdownMenuItem<String>(
                value: '__ADD_CUSTOM__',
                child: Row(
                  children: [
                    Icon(
                      Icons.add_circle_outline,
                      color: AppColors.accentText,
                      size: AppSizes.smallIcon,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Add Custom $customFieldLabel',
                      style: TextStyle(
                        color: AppColors.accentText,
                        fontWeight: FontWeight.w600,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
          ],
          onChanged: !enabled || isLoading
              ? null
              : (selectedValue) {
            if (selectedValue == '__ADD_CUSTOM__') {
              _showCustomDialog(
                label: customFieldLabel,
                hintText: customHintText,
                onSave: onChanged,
              );
            } else {
              onChanged(selectedValue);
            }
          },
          validator: validator ??
              (isRequired
                  ? (value) {
                if (value == null || value.isEmpty) {
                  return '${label.replaceAll('*', '').trim()} is required';
                }
                return null;
              }
                  : null),
        ),
      ],
    );
  }

  // Helper methods remain the same
  static void _showCustomDialog({
    required String label,
    required String hintText,
    required Function(String?) onSave,
  }) {
    final context = _navigatorKey.currentContext;
    if (context == null) return;

    showDialog(
      context: context,
      builder: (dialogContext) => CustomValueDialog(
        title: 'Add Custom $label',
        fieldLabel: label,
        hintText: hintText,
        onSave: (customValue) {
          onSave('__CUSTOM__$customValue');
        },
      ),
    );
  }

  static final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();
  static GlobalKey<NavigatorState> get navigatorKey => _navigatorKey;

  static bool isCustomValue(String? value) {
    return value != null && value.startsWith('__CUSTOM__');
  }

  static String extractCustomValue(String? value) {
    if (isCustomValue(value)) {
      return value!.substring('__CUSTOM__'.length);
    }
    return value ?? '';
  }

  static String getDisplayValue(String? value) {
    if (isCustomValue(value)) {
      return extractCustomValue(value);
    }
    return value ?? '';
  }

  static InputDecoration _getInputDecoration({
    bool enabled = true,
    bool isLoading = false,
  }) {
    return InputDecoration(
      filled: true,
      fillColor: enabled
          ? AppColors.inputBackground
          : AppColors.inputBackground.withOpacity(0.5),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppSizes.borderRadius),
        borderSide: const BorderSide(color: AppColors.primaryBorder),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppSizes.borderRadius),
        borderSide: BorderSide(
          color: enabled
              ? AppColors.primaryBorder
              : AppColors.primaryBorder.withOpacity(0.5),
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppSizes.borderRadius),
        borderSide: const BorderSide(color: AppColors.focusBorder),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppSizes.borderRadius),
        borderSide: const BorderSide(color: AppColors.errorBorder),
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
            color: AppColors.focusBorder,
          ),
        ),
      )
          : null,
    );
  }
}

// Searchable Dropdown StatefulWidget
class _SearchableDropdownField extends StatefulWidget {
  final String label;
  final String? value;
  final List<DropdownOption> options;
  final void Function(String?) onChanged;
  final String customFieldLabel;
  final String customHintText;
  final bool isRequired;
  final bool isLoading;
  final bool enabled;
  final bool allowCustom;
  final String? Function(String?)? validator;

  const _SearchableDropdownField({
    required this.label,
    required this.value,
    required this.options,
    required this.onChanged,
    required this.customFieldLabel,
    required this.customHintText,
    required this.isRequired,
    required this.isLoading,
    required this.enabled,
    required this.allowCustom,
    this.validator,
  });

  @override
  State<_SearchableDropdownField> createState() => _SearchableDropdownFieldState();
}

class _SearchableDropdownFieldState extends State<_SearchableDropdownField> {
  final TextEditingController _searchController = TextEditingController();
  List<DropdownOption> _filteredOptions = [];
  bool _showDropdown = false;

  @override
  void initState() {
    super.initState();
    _updateFilteredOptions();
  }

  @override
  void didUpdateWidget(_SearchableDropdownField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.options != widget.options) {
      _updateFilteredOptions();
    }
  }

  void _updateFilteredOptions() {
    final query = _searchController.text.toLowerCase();
    _filteredOptions = widget.options
        .where((option) => option.label.toLowerCase().contains(query))
        .toList();

    // Add current value if custom and not in options
    if (widget.value != null &&
        EnhancedDialogWidgets.isCustomValue(widget.value!) &&
        !_filteredOptions.any((opt) => opt.value == widget.value)) {
      _filteredOptions.add(DropdownOption(
        value: widget.value!,
        label: EnhancedDialogWidgets.getDisplayValue(widget.value),
      ));
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(widget.label, style: AppTextStyles.fieldLabel),
        const SizedBox(height: 6),

        // Search Field
        TextFormField(
          controller: _searchController,
          enabled: widget.enabled,
          style: TextStyle(
            color: widget.enabled ? AppColors.primaryText : AppColors.primaryText.withOpacity(0.5),
            fontSize: 14,
          ),
          decoration: EnhancedDialogWidgets._getInputDecoration(
            enabled: widget.enabled,
            isLoading: widget.isLoading,
          ).copyWith(
            hintText: widget.enabled
                ? (widget.isLoading
                ? 'Loading...'
                : 'Search ${widget.label.replaceAll('*', '').trim().toLowerCase()}...')
                : 'Select required field first...',
            suffixIcon: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (widget.isLoading)
                  const Padding(
                    padding: EdgeInsets.all(12),
                    child: SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppColors.focusBorder,
                      ),
                    ),
                  ),
                IconButton(
                  onPressed: widget.enabled && !widget.isLoading
                      ? () => setState(() => _showDropdown = !_showDropdown)
                      : null,
                  icon: Icon(
                    _showDropdown ? Icons.arrow_drop_up : Icons.arrow_drop_down,
                    color: widget.enabled ? AppColors.secondaryText : AppColors.secondaryText.withOpacity(0.5),
                  ),
                ),
              ],
            ),
          ),
          onChanged: widget.enabled && !widget.isLoading
              ? (value) {
            setState(() {
              _updateFilteredOptions();
              _showDropdown = value.isNotEmpty;
            });
          }
              : null,
          onTap: widget.enabled && !widget.isLoading
              ? () => setState(() => _showDropdown = true)
              : null,
          readOnly: false,
          validator: widget.validator ?? (widget.isRequired
              ? (value) {
            if (widget.value == null || widget.value!.isEmpty) {
              return '${widget.label.replaceAll('*', '').trim()} is required';
            }
            return null;
          }
              : null),
        ),

        // // Selected Value Display
        // if (widget.value != null && widget.value!.isNotEmpty) ...[
        //   const SizedBox(height: 4),
        //   Container(
        //     padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        //     decoration: AppDecorations.accentBadgeDecoration,
        //     child: Text(
        //       'Selected: ${EnhancedDialogWidgets.getDisplayValue(widget.value)}',
        //       style: AppTextStyles.badgeText,
        //       overflow: TextOverflow.ellipsis,
        //     ),
        //   ),
        // ],

        // Dropdown Options
        if (_showDropdown && widget.enabled && !widget.isLoading) ...[
          const SizedBox(height: 4),
          Container(
            constraints: const BoxConstraints(maxHeight: 200),
            decoration: BoxDecoration(
              color: AppColors.cardBackground,
              border: Border.all(color: AppColors.primaryBorder),
              borderRadius: BorderRadius.circular(AppSizes.borderRadius),
            ),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Options
                  ..._filteredOptions.map((option) => InkWell(
                    onTap: () {
                      widget.onChanged(option.value);
                      _searchController.text = option.label;
                      setState(() => _showDropdown = false);
                    },
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      child: Text(
                        option.label,
                        style: const TextStyle(
                          color: AppColors.primaryText,
                          fontSize: 14,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  )),

                  // Add Custom Option
                  if (widget.allowCustom) ...[
                    const Divider(color: AppColors.primaryBorder, height: 1),
                    InkWell(
                      onTap: () {
                        EnhancedDialogWidgets._showCustomDialog(
                          label: widget.customFieldLabel,
                          hintText: widget.customHintText,
                          onSave: (customValue) {
                            widget.onChanged(customValue);
                            _searchController.text = EnhancedDialogWidgets.getDisplayValue(customValue);
                          },
                        );
                        setState(() => _showDropdown = false);
                      },
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        child: Row(
                          children: [
                            Icon(
                              Icons.add_circle_outline,
                              color: AppColors.accentText,
                              size: AppSizes.smallIcon,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Add Custom ${widget.customFieldLabel}',
                              style: TextStyle(
                                color: AppColors.accentText,
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],

                  // No results
                  if (_filteredOptions.isEmpty) ...[
                    Container(
                      padding: const EdgeInsets.all(12),
                      child: Text(
                        'No results found',
                        style: TextStyle(
                          color: AppColors.secondaryText,
                          fontSize: 14,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }
}