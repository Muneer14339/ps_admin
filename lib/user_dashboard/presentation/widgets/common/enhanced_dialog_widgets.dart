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
    // Create a mutable copy of options
    final allOptions = List<DropdownOption>.from(options);

    // If current value is custom and not in options, add it temporarily
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
                isLoading
                    ? 'Loading...'
                    : 'Select ${label.replaceAll('*', '').trim().toLowerCase()}...',
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