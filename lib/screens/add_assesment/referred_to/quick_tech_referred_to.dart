import 'package:e_prescription/const/quick_tech_app_colors.dart';
import 'package:e_prescription/const/quick_tech_styles.dart';
import 'package:e_prescription/controllers/assessment_controller/referred_to/quick_tech_referred_to_controller.dart';
import 'package:e_prescription/controllers/theme_controller/quick_tech_theme_controller.dart';
import 'package:e_prescription/screens/add_assesment/referred_to/widgets/quick_tech_referred_to_widgets.dart';
import 'package:e_prescription/screens/add_assesment/widgets/quick_tech_assessment_widgets.dart'; // Responsive cards & headers
import 'package:e_prescription/responsive.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:e_prescription/locator.dart';

class ReferredTo extends StatelessWidget {
  final String? patientId;

  ReferredTo({Key? key, this.patientId}) : super(key: key) {
    // Idempotent: safe to call from constructor; it won't refetch once loaded.
    locator.get<QuickTechReferredToController>().ensureCategoryLoaded();
  }

  @override
  Widget build(BuildContext context) {
    final QuickTechThemeController themeController = locator.get<QuickTechThemeController>();
    final QuickTechReferredToController referredToController = locator.get<QuickTechReferredToController>();

    return Obx(() {
      final isDay = themeController.isDay.value;
      final mainColor = isDay ? QuickTechAppColors.lightmaincolor : QuickTechAppColors.darkmaincolor;
      final txtColor = isDay ? QuickTechAppColors.lightmaintextcolor : QuickTechAppColors.darkmaintextcolor;

      // ─────────────────────────────────────────────
      // Selection Section
      // ─────────────────────────────────────────────
      Widget selectionSection = Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const ReferredToDropdown(),
          const SizedBox(height: 16),
          // Selected Referred To Chips
          Obx(() {
            if (referredToController.selectedReferredTo.isEmpty) {
              return const SizedBox.shrink();
            }
            return Wrap(
              spacing: 8.0,
              runSpacing: 8.0,
              children: referredToController.selectedReferredTo.map((referredTo) {
                return Chip(
                  deleteIconColor: isDay ? QuickTechAppColors.bkdarktxtfld : QuickTechAppColors.whiteOpacity,
                  backgroundColor: isDay ? QuickTechAppColors.lightmaincolor.withValues(alpha:0.1) : QuickTechAppColors.darktxtfieldcolor,
                  side: BorderSide(color: mainColor.withValues(alpha:0.3)),
                  label: Text(
                    referredTo,
                    style: myStyle(14, txtColor, FontWeight.bold),
                  ),
                  onDeleted: () => referredToController.removeReferredTo(referredTo),
                );
              }).toList(),
            );
          }),
        ],
      );

      // ─────────────────────────────────────────────
      // Responsive Layouts
      // ─────────────────────────────────────────────
      Widget mobile() => SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                assessmentHeader(
                  mainColor: mainColor,
                  title: 'Referred To',
                  icon: FontAwesomeIcons.userDoctor.data,
                ),
                const SizedBox(height: 16),
                selectionSection,
              ],
            ),
          );

      Widget tablet() => SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                assessmentHeader(
                  mainColor: mainColor,
                  title: 'Referred To',
                  icon: FontAwesomeIcons.userDoctor.data,
                ),
                const SizedBox(height: 20),
                assessmentCard(
                  color: mainColor,
                  title: 'Select Referral Destination',
                  icon: Icons.search,
                  child: selectionSection,
                ),
              ],
            ),
          );

      Widget desktop() => SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                assessmentHeader(
                  mainColor: mainColor,
                  title: 'Referred To',
                  icon: FontAwesomeIcons.userDoctor.data,
                ),
                const SizedBox(height: 24),
                // Since this component is smaller, we can constrain its width on desktop
                // or let it expand within the standard card.
                assessmentCard(
                  color: mainColor,
                  title: 'Select Referral Destination',
                  icon: Icons.search,
                  child: selectionSection,
                ),
              ],
            ),
          );

      return Responsive(mobile: mobile(), tablet: tablet(), desktop: desktop());
    });
  }
}