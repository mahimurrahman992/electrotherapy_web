import 'package:e_prescription/const/quick_tech_app_colors.dart';
import 'package:e_prescription/const/quick_tech_styles.dart';
import 'package:e_prescription/controllers/assessment_controller/assestive_device/quick_tech_assestive_device_controller.dart';
import 'package:e_prescription/controllers/theme_controller/quick_tech_theme_controller.dart';
import 'package:e_prescription/screens/add_assesment/assestive_device/widgets/quick_tech_assestive_device_widgets.dart';
import 'package:e_prescription/screens/add_assesment/widgets/quick_tech_assessment_widgets.dart'; // Responsive cards & headers
import 'package:e_prescription/widgets/quick_tech_custom_text_field.dart';
import 'package:e_prescription/responsive.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:e_prescription/locator.dart';

class AssestiveDevice extends StatelessWidget {
  final String? patientId;

  AssestiveDevice({Key? key, this.patientId}) : super(key: key) {
    // Idempotent: safe to call from constructor; it won't refetch once loaded.
    locator.get<QuickTechAssestiveDeviceController>().ensureCategoryLoaded();
  }

  @override
  Widget build(BuildContext context) {
    final QuickTechThemeController themeController = locator.get<QuickTechThemeController>();
    final QuickTechAssestiveDeviceController assestiveDeviceController = locator.get<QuickTechAssestiveDeviceController>();

    return Obx(() {
      final isDay = themeController.isDay.value;
      final mainColor = isDay ? QuickTechAppColors.lightmaincolor : QuickTechAppColors.darkmaincolor;
      final txtColor = isDay ? QuickTechAppColors.lightmaintextcolor : QuickTechAppColors.darkmaintextcolor;
      final bgColor = isDay ? QuickTechAppColors.bktxtfld : QuickTechAppColors.bkdarktxtfld;
      final iconLabelColor = txtColor.withValues(alpha:0.8);

      // ─────────────────────────────────────────────
      // 1. Device Selection Section
      // ─────────────────────────────────────────────
      Widget selectionSection = Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const AssestiveDeviceDropdown(),
          const SizedBox(height: 16),
          // Selected Device Chips
          Obx(() {
            if (assestiveDeviceController.selectedAssestiveDevice.isEmpty) {
              return const SizedBox.shrink();
            }
            return Wrap(
              spacing: 8.0,
              runSpacing: 8.0,
              children: assestiveDeviceController.selectedAssestiveDevice.map((device) {
                return Chip(
                  deleteIconColor: isDay ? QuickTechAppColors.bkdarktxtfld : QuickTechAppColors.whiteOpacity,
                  backgroundColor: isDay ? QuickTechAppColors.lightmaincolor.withValues(alpha:0.1) : QuickTechAppColors.darktxtfieldcolor,
                  side: BorderSide(color: mainColor.withValues(alpha:0.3)),
                  label: Text(
                    device,
                    style: myStyle(14, txtColor, FontWeight.bold),
                  ),
                  onDeleted: () => assestiveDeviceController.removeSuggestiveDevice(device),
                );
              }).toList(),
            );
          }),
        ],
      );

      // ─────────────────────────────────────────────
      // 2. Device Details & Sub-Categories Section
      // ─────────────────────────────────────────────
      Widget detailsSection = Obx(() {
        if (assestiveDeviceController.selectedAssestiveDevice.isEmpty) {
          return const SizedBox.shrink();
        }

        final category = assestiveDeviceController.assestiveDeviceCategory.value;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Details TextFields
            ...assestiveDeviceController.selectedAssestiveDevice.map((device) {
              if (assestiveDeviceController.showDetailsField(device)) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: QuickTechCustomTextField(
                    icon: Icons.input,
                    label: '$device Details',
                    controller: assestiveDeviceController.getDetailsController(device),
                    backcolor: bgColor,
                    txtcolor: txtColor,
                    lebelcolor: iconLabelColor,
                    iconcolor: iconLabelColor,
                  ),
                );
              }
              return const SizedBox.shrink();
            }).toList(),

            // Sub-Device Choice Chips
            if (category != null)
              ...assestiveDeviceController.selectedAssestiveDevice.map((device) {
                final sub = category.subCategories.firstWhereOrNull((s) => s.name == device);
                if (sub != null && sub.childCategories.isNotEmpty) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 8.0, bottom: 12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Sub-Category for $device',
                          style: myStyle(15, txtColor, FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8.0,
                          runSpacing: 8.0,
                          children: sub.childCategories.map((child) {
                            final isSelected = assestiveDeviceController.selectedsubAssestiveDevice[device]?.contains(child.name) ?? false;
                            return ChoiceChip(
                              backgroundColor: isDay ? QuickTechAppColors.bktxtfld : QuickTechAppColors.darktxtfieldcolor,
                              selectedColor: mainColor.withValues(alpha:0.2),
                              side: BorderSide(color: isSelected ? mainColor : (isDay ? Colors.grey.shade300 : Colors.grey.shade700)),
                              label: Text(
                                child.name,
                                style: myStyle(
                                  13,
                                  isSelected ? mainColor : txtColor,
                                  isSelected ? FontWeight.bold : FontWeight.normal,
                                ),
                              ),
                              selected: isSelected,
                              onSelected: (selected) {
                                if (selected) {
                                  assestiveDeviceController.addSubassestiveDevice(device, child.name);
                                } else {
                                  assestiveDeviceController.removeSubAssestiveDevice(device, child.name);
                                }
                              },
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  );
                }
                return const SizedBox.shrink();
              }).toList(),
          ],
        );
      });

      // ─────────────────────────────────────────────
      // Responsive Layouts
      // ─────────────────────────────────────────────
      Widget mobile() => SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                assessmentHeader(mainColor: mainColor, title: 'Assistive Device', icon: FontAwesomeIcons.wheelchair.data),
                const SizedBox(height: 16),
                selectionSection,
                const SizedBox(height: 16),
                detailsSection,
              ],
            ),
          );

      Widget tablet() => SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                assessmentHeader(mainColor: mainColor, title: 'Assistive Device', icon: FontAwesomeIcons.wheelchair.data),
                const SizedBox(height: 20),
                assessmentCard(color: mainColor, title: 'Select Device', icon: Icons.search, child: selectionSection),
                Obx(() => assestiveDeviceController.selectedAssestiveDevice.isNotEmpty
                    ? Padding(
                        padding: const EdgeInsets.only(top: 16),
                        child: assessmentCard(color: mainColor, title: 'Details & Sub-categories', icon: Icons.list_alt, child: detailsSection),
                      )
                    : const SizedBox.shrink()),
              ],
            ),
          );

      Widget desktop() => SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                assessmentHeader(mainColor: mainColor, title: 'Assistive Device', icon: FontAwesomeIcons.wheelchair.data),
                const SizedBox(height: 24),
                // Place selection and details side-by-side on desktop if a device is selected
                Obx(() {
                  if (assestiveDeviceController.selectedAssestiveDevice.isEmpty) {
                    return assessmentCard(color: mainColor, title: 'Select Device', icon: Icons.search, child: selectionSection);
                  }
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 1,
                        child: assessmentCard(color: mainColor, title: 'Select Device', icon: Icons.search, child: selectionSection),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        flex: 1,
                        child: assessmentCard(color: mainColor, title: 'Details & Sub-categories', icon: Icons.list_alt, child: detailsSection),
                      ),
                    ],
                  );
                }),
              ],
            ),
          );

      return Responsive(mobile: mobile(), tablet: tablet(), desktop: desktop());
    });
  }
}