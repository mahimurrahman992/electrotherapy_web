import 'package:e_prescription/const/quick_tech_app_colors.dart';

import 'package:e_prescription/controllers/assessment_controller/problem_summary/quick_tech_problem_summary_controller.dart';
import 'package:e_prescription/controllers/theme_controller/quick_tech_theme_controller.dart';
import 'package:e_prescription/screens/add_assesment/widgets/quick_tech_assessment_widgets.dart'; // Responsive cards and headers
import 'package:e_prescription/responsive.dart';
import 'package:e_prescription/widgets/quick_tech_custom_text_field.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:e_prescription/locator.dart';

class ProblemSummary extends StatelessWidget {
  final String? patientId;

  const ProblemSummary({Key? key, this.patientId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final QuickTechThemeController themeController = locator.get<QuickTechThemeController>();
    final QuickTechProblemSummaryController problemSummaryController = locator.get<QuickTechProblemSummaryController>();

    return Obx(() {
      final isDay = themeController.isDay.value;
      final mainColor = isDay ? QuickTechAppColors.lightmaincolor : QuickTechAppColors.darkmaincolor;
      final txtColor = isDay ? QuickTechAppColors.lightmaintextcolor : QuickTechAppColors.darkmaintextcolor;
      final bgColor = isDay ? QuickTechAppColors.bktxtfld : QuickTechAppColors.bkdarktxtfld;
      final iconLabelColor = txtColor.withValues(alpha: 0.8);

      // ─────────────────────────────────────────────
      // Fields Definition
      // ─────────────────────────────────────────────
      final List<Widget> fields = [
        QuickTechCustomTextField(
          height: 100, // Slightly increased to comfortably fit 4 lines
          maxline: 4,
          icon: Icons.sick,
          iconcolor: iconLabelColor,
          lebelcolor: iconLabelColor,
          txtcolor: txtColor,
          label: 'Problem List',
          controller: problemSummaryController.problemListController,
          backcolor: bgColor,
        ),
        QuickTechCustomTextField(
          height: 100,
          maxline: 4,
          icon: Icons.flag,
          iconcolor: iconLabelColor,
          lebelcolor: iconLabelColor,
          txtcolor: txtColor,
          label: 'Goal',
          controller: problemSummaryController.goalListController,
          backcolor: bgColor,
        ),
        QuickTechCustomTextField(
          height: 100,
          maxline: 4,
          icon: FontAwesomeIcons.kitMedical.data,
          iconcolor: iconLabelColor,
          lebelcolor: iconLabelColor,
          txtcolor: txtColor,
          label: 'Treatment Plan',
          controller: problemSummaryController.treatmentPlanController,
          backcolor: bgColor,
        ),
      ];

      // ─────────────────────────────────────────────
      // Responsive Layouts
      // ─────────────────────────────────────────────

      // Mobile Layout (Stacked Vertically)
      Widget mobile() => SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                assessmentHeader(
                  mainColor: mainColor,
                  title: 'Problem Summary, Goal & Plan',
                  icon: Icons.summarize,
                ),
                const SizedBox(height: 16),
                assessmentGrid(fields: fields, cols: 1), // 1 column for mobile
              ],
            ),
          );

      // Tablet Layout (Stacked Vertically inside a Card)
      Widget tablet() => SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                assessmentHeader(
                  mainColor: mainColor,
                  title: 'Problem Summary, Goal & Plan',
                  icon: Icons.summarize,
                ),
                const SizedBox(height: 20),
                assessmentCard(
                  color: mainColor,
                  title: 'Action Plan Details',
                  icon: Icons.assignment,
                  child: assessmentGrid(fields: fields, cols: 1), // 1 column for tablet
                ),
              ],
            ),
          );

      // Desktop Layout (Side-by-side in 3 Columns)
      Widget desktop() => SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                assessmentHeader(
                  mainColor: mainColor,
                  title: 'Problem Summary, Goal & Plan',
                  icon: Icons.summarize,
                ),
                const SizedBox(height: 24),
                assessmentCard(
                  color: mainColor,
                  title: 'Action Plan Details',
                  icon: Icons.assignment,
                  child: assessmentGrid(fields: fields, cols: 3), // 3 columns side-by-side on desktop
                ),
              ],
            ),
          );

      return Responsive(mobile: mobile(), tablet: tablet(), desktop: desktop());
    });
  }
}