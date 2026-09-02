import 'package:e_prescription/const/quick_tech_app_colors.dart';
import 'package:e_prescription/const/quick_tech_styles.dart';
import 'package:e_prescription/controllers/assessment_controller/quick_tech_assessment_controller.dart';

import 'package:flutter/material.dart';
import 'package:e_prescription/locator.dart';
import 'package:e_prescription/widgets/quick_tech_snackbar.dart';

class QuickTechCustomDropDown<T> extends StatelessWidget {
  final String label;
  final List<T> items;
  final T? value;
  final ValueChanged<T?>? onChanged;
  final IconData icon;
  final bool isDay;
  final bool enableOthersOption;
  final String othersText;
  final String? dialogTitle;
  final String? dialogHint;
  final double? height;
  final double? borderRadius;
  final EdgeInsetsGeometry? margin;
  final TextStyle? labelStyle;
  final TextStyle? itemStyle;
  final Color? dropdownColor;
  final Color? iconColor;
  final Color? fillColor;

  const QuickTechCustomDropDown({
    Key? key,
    required this.label,
    required this.items,
    required this.value,
    this.onChanged,
    required this.icon,
    required this.isDay,
    this.enableOthersOption = false,
    this.othersText = 'Others',
    this.dialogTitle,
    this.dialogHint,
    this.height = 50,
    this.borderRadius = 18,
    this.margin = const EdgeInsets.only(top: 8),
    this.labelStyle,
    this.itemStyle,
    this.dropdownColor,
    this.iconColor,
    this.fillColor,
  }) : super(key: key);

  /// Show snackbar when an item is selected
  static void _showSelectionSnackBar(
    BuildContext context,
    String field,
    String value,
  ) {
    QuickTechSnackbar.success('$field: $value');
  }

  @override
  Widget build(BuildContext context) {
   
    final assessmentController = locator.get<QuickTechAssessmentController>();

    final effectiveLabelStyle =
        labelStyle ??
        myStyle(
          14,
          isDay
              ? QuickTechAppColors.lightmaintextcolor.withValues(alpha: 0.7)
              : QuickTechAppColors.darkmaintextcolor.withValues(alpha: 0.7),
        );

    final effectiveItemStyle =
        itemStyle ??
        myStyle(
          14,
          isDay
              ? QuickTechAppColors.lightmaintextcolor
              : QuickTechAppColors.darkmaintextcolor,
        );

    final effectiveIconColor =
        iconColor ??
        (isDay
            ? QuickTechAppColors.lightmaintextcolor.withValues(alpha: 0.7)
            : QuickTechAppColors.darkmaintextcolor.withValues(alpha: 0.7));

    final effectiveFillColor =
        fillColor ??
        (isDay ? QuickTechAppColors.bktxtfld : QuickTechAppColors.bkdarktxtfld);

    final effectiveDropdownColor =
        dropdownColor ??
        (isDay ? QuickTechAppColors.bktxtfld : QuickTechAppColors.black);

    return Container(
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius!),
      ),
      margin: margin,
      child: DropdownButtonFormField<T>(
        decoration: InputDecoration(
          labelText: label,
          labelStyle: effectiveLabelStyle,
          fillColor: effectiveFillColor,
          filled: true,
          prefixIcon: Icon(icon, color: effectiveIconColor, size: 20),

          // 👇 SAME STYLE AS TEXTFIELD
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color: isDay ? const Color(0xFFE0E4EE) : Colors.grey[800]!,
              width: 1.2,
            ),
          ),

          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color: isDay ? const Color(0xFFE0E4EE) : Colors.grey[800]!,
              width: 1.2,
            ),
          ),

          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color:
                  isDay
                      ? QuickTechAppColors.lightmaincolor
                      : QuickTechAppColors.darkmaincolor,
              width: 1.8,
            ),
          ),

          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.redAccent, width: 1.2),
          ),

          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.redAccent, width: 1.8),
          ),
        ),
        initialValue: value,
        items: DropDownItems(effectiveItemStyle),
        onChanged: (T? newValue) {
          if (enableOthersOption &&
              newValue != null &&
              newValue.toString() == othersText) {
            assessmentController.showOthersDialog(
              context,
              label: label,
              onChanged: (customValue) {
                onChanged?.call(customValue as T);
                _showSelectionSnackBar(context, label, customValue.toString());
              },
              dialogTitle: dialogTitle,
              dialogHint: dialogHint,
            );
          } else {
            onChanged?.call(newValue);
            if (newValue != null) {
              _showSelectionSnackBar(context, label, newValue.toString());
            }
          }
        },
        dropdownColor: effectiveDropdownColor,
      ),
    );
  }

  List<DropdownMenuItem<T>> DropDownItems(TextStyle style) {
    final displayItems = List<T>.from(items);
    if (enableOthersOption && !displayItems.contains(othersText as T)) {
      displayItems.add(othersText as T);
    }

    return displayItems.map((T item) {
      return DropdownMenuItem<T>(
        value: item,
        child: Text(item.toString(), style: style),
      );
    }).toList();
  }
}
