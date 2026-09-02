import 'package:e_prescription/const/quick_tech_app_colors.dart';
import 'package:e_prescription/const/quick_tech_styles.dart';
import 'package:e_prescription/controllers/theme_controller/quick_tech_theme_controller.dart';
import 'package:e_prescription/widgets/quick_tech_custom_drop_down.dart';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:e_prescription/locator.dart';

class OnExaminationDropDown extends StatelessWidget {
  final String label;
  final List<String> items;
  final String? value;
  final Function(String?) onChanged;
  final IconData icon;
  final Widget infoContent;
  final RxBool isExpanded;
  final String? dialogTitle;
  final String? dialogHint;
  final bool enableOthersOption;

  const OnExaminationDropDown({
    Key? key,
    required this.label,
    required this.items,
    required this.value,
    required this.onChanged,
    required this.icon,
    required this.infoContent,
    required this.isExpanded,
    this.dialogTitle,
    this.dialogHint,
    this.enableOthersOption = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final themeController = locator.get<QuickTechThemeController>();

    return Obx(() {
      final isDay = themeController.isDay.value;
      final iconColor = isDay
          ? QuickTechAppColors.lightmaintextcolor.withValues(alpha: 0.7)
          : QuickTechAppColors.darkmaintextcolor.withValues(alpha: 0.7);

      return Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: QuickTechCustomDropDown<String?>(
                  label: label,
                  items: items,
                  value: value,
                  onChanged: onChanged,
                  icon: icon,
                  isDay: isDay,
                  dialogHint: dialogHint,
                  dialogTitle: dialogTitle,
                  enableOthersOption: enableOthersOption,
                ),
              ),
              IconButton(
                onPressed: () => isExpanded.toggle(),
                icon: Icon(
                  FontAwesomeIcons.circleInfo.data,
                  size: 20,
                  color: isExpanded.value ? (isDay ? QuickTechAppColors.lightmaincolor : QuickTechAppColors.darkmaincolor) : iconColor,
                ),
              ),
            ],
          ),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: isExpanded.value
                ? OnExaminationInfoCard(content: infoContent)
                : const SizedBox.shrink(),
          ),
        ],
      );
    });
  }
}

class OnExaminationInfoCard extends StatelessWidget {
  final Widget content;

  const OnExaminationInfoCard({Key? key, required this.content}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final themeController = locator.get<QuickTechThemeController>();
    return Obx(() {
      final isDay = themeController.isDay.value;
      return Card(
        elevation: isDay ? 2 : 0, // Lowered elevation for cleaner look inside grid
        shadowColor: isDay ? QuickTechAppColors.black.withValues(alpha:0.1) : Colors.transparent,
        color: isDay ? QuickTechAppColors.bktxtfld : QuickTechAppColors.bkdarktxtfld,
        margin: const EdgeInsets.only(top: 8, bottom: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: isDay ? Colors.grey.shade300 : Colors.grey.shade800),
        ),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: content,
        ),
      );
    });
  }
}

class OnExaminationInfoItem extends StatelessWidget {
  final String title;
  final String description;

  const OnExaminationInfoItem({Key? key, required this.title, required this.description}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final themeController = locator.get<QuickTechThemeController>();
    return Obx(() {
      final textColor = themeController.isDay.value
          ? QuickTechAppColors.lightmaintextcolor
          : QuickTechAppColors.darkmaintextcolor;

      return Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: RichText(
          text: TextSpan(
            style: myStyle(12, textColor),
            children: [
              TextSpan(text: title, style: const TextStyle(fontWeight: FontWeight.bold)),
              TextSpan(text: ' $description'),
            ],
          ),
        ),
      );
    });
  }
}

class CustomMultipleChip extends StatelessWidget {
  final String label;
  final List<String> items;
  final Rx<List<String>> selectedItems;
  final Function(List<String>) onSelectionChanged;

  const CustomMultipleChip({
    Key? key,
    required this.label,
    required this.items,
    required this.selectedItems,
    required this.onSelectionChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final themeController = locator.get<QuickTechThemeController>();

    return Obx(() {
      final isDay = themeController.isDay.value;
      final textColor = isDay ? QuickTechAppColors.lightmaintextcolor : QuickTechAppColors.darkmaintextcolor;
      
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Label is handled by Assessment Card in Tablet/Desktop, but keeping it for context
          Wrap(
            spacing: 10.0,
            runSpacing: 10.0,
            children: items.map((item) {
              final isSelected = selectedItems.value.contains(item);
              return FilterChip(
                backgroundColor: isDay ? QuickTechAppColors.bktxtfld : QuickTechAppColors.darktxtfieldcolor,
                selectedColor: isDay ? QuickTechAppColors.lightmaincolor.withValues(alpha:0.2) : QuickTechAppColors.darkmaincolor.withValues(alpha:0.2),
                checkmarkColor: isDay ? QuickTechAppColors.lightmaincolor : QuickTechAppColors.darkmaincolor,
                side: BorderSide(
                  color: isSelected 
                      ? (isDay ? QuickTechAppColors.lightmaincolor : QuickTechAppColors.darkmaincolor)
                      : (isDay ? Colors.grey.shade300 : Colors.grey.shade700)
                ),
                label: Text(
                  item,
                  style: myStyle(
                    13,
                    isSelected 
                        ? (isDay ? QuickTechAppColors.lightmaincolor : QuickTechAppColors.darkmaincolor)
                        : textColor,
                    isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
                selected: isSelected,
                onSelected: (bool selected) {
                  List<String> updated = List.from(selectedItems.value);
                  if (selected) {
                    updated.add(item);
                  } else {
                    updated.remove(item);
                  }
                  onSelectionChanged(updated);
                },
              );
            }).toList(),
          ),
        ],
      );
    });
  }
}