import 'package:e_prescription/const/quick_tech_app_colors.dart';
import 'package:e_prescription/controllers/assessment_controller/home_advice/quick_tech_home_advice_controller.dart';
import 'package:e_prescription/controllers/theme_controller/quick_tech_theme_controller.dart';
import 'package:e_prescription/screens/add_assesment/widgets/quick_tech_assessment_widgets.dart'; // Responsive cards and headers
import 'package:e_prescription/responsive.dart';
import 'package:e_prescription/widgets/quick_tech_custom_text_field.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:e_prescription/locator.dart';

class HomeAdvice extends StatelessWidget {
  final String? patientId;

  const HomeAdvice({Key? key, this.patientId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final QuickTechThemeController themeController = locator.get<QuickTechThemeController>();
    final QuickTechHomeAdviceController adviceController = locator.get<QuickTechHomeAdviceController>();

    return Obx(() {
      final isDay = themeController.isDay.value;
      final mainColor = isDay ? QuickTechAppColors.lightmaincolor : QuickTechAppColors.darkmaincolor;
      final txtColor = isDay ? QuickTechAppColors.lightmaintextcolor : QuickTechAppColors.darkmaintextcolor;
      final bgColor = isDay ? QuickTechAppColors.bktxtfld : QuickTechAppColors.bkdarktxtfld;
      final iconLabelColor = txtColor.withValues(alpha: 0.8);

      // ─────────────────────────────────────────────
      // Field Definition
      // ─────────────────────────────────────────────
      final Widget adviceField = QuickTechCustomTextField(
        height: 120, // Increased slightly to accommodate 4 lines of text comfortably
        maxline: 4,
        icon: FontAwesomeIcons.houseMedical.data,
        iconcolor: iconLabelColor,
        lebelcolor: iconLabelColor,
        txtcolor: txtColor,
        label: 'Advice',
        controller: adviceController.homeAdviceController,
        backcolor: bgColor,
      );

      // ─────────────────────────────────────────────
      // Responsive Layouts
      // ─────────────────────────────────────────────

      // Mobile Layout
      Widget mobile() => SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                assessmentHeader(
                  mainColor: mainColor,
                  title: 'Home Advice',
                  icon: FontAwesomeIcons.houseUser.data,
                ),
                const SizedBox(height: 16),
                adviceField,
              ],
            ),
          );

      // Tablet Layout (Placed inside a Card)
      Widget tablet() => SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                assessmentHeader(
                  mainColor: mainColor,
                  title: 'Home Advice',
                  icon: FontAwesomeIcons.houseUser.data,
                ),
                const SizedBox(height: 20),
                assessmentCard(
                  color: mainColor,
                  title: 'Instructions for Patient',
                  icon: FontAwesomeIcons.filePrescription.data,
                  child: adviceField,
                ),
              ],
            ),
          );

      // Desktop Layout (Placed inside a Card with more padding)
      Widget desktop() => SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                assessmentHeader(
                  mainColor: mainColor,
                  title: 'Home Advice',
                  icon: FontAwesomeIcons.houseUser.data,
                ),
                const SizedBox(height: 24),
                assessmentCard(
                  color: mainColor,
                  title: 'Instructions for Patient',
                  icon: FontAwesomeIcons.filePrescription.data,
                  child: adviceField,
                ),
              ],
            ),
          );

      return Responsive(mobile: mobile(), tablet: tablet(), desktop: desktop());
    });
  }
}