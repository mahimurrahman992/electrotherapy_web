import 'package:e_prescription/const/quick_tech_app_colors.dart';
import 'package:e_prescription/const/quick_tech_styles.dart';
import 'package:e_prescription/controllers/theme_controller/quick_tech_theme_controller.dart';
import 'package:e_prescription/screens/add_assesment/widgets/quick_tech_assessment_widgets.dart'; // Added to use assessmentCard
import 'package:e_prescription/widgets/quick_tech_custom_text_field.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:e_prescription/locator.dart';
import 'package:get/get.dart';

class RangeofMotionLimbSection extends StatelessWidget {
  final String title;
  final TextEditingController movementController;
  final TextEditingController muscleNameController;
  final TextEditingController leftInitialController;
  final TextEditingController rightInitialController;
  final TextEditingController leftDischargeController;
  final TextEditingController rightDischargeController;
  final TextEditingController commentController;

  const RangeofMotionLimbSection({
    Key? key,
    required this.title,
    required this.movementController,
    required this.muscleNameController,
    required this.leftInitialController,
    required this.rightInitialController,
    required this.leftDischargeController,
    required this.rightDischargeController,
    required this.commentController,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final QuickTechThemeController themeController = locator.get<QuickTechThemeController>();

    return Obx(() {
      final isDay = themeController.isDay.value;
      final mainColor = isDay ? QuickTechAppColors.lightmaincolor : QuickTechAppColors.darkmaincolor;
      final txtColor = isDay ? QuickTechAppColors.lightmaintextcolor : QuickTechAppColors.darkmaintextcolor;
      final labelColor = txtColor.withValues(alpha:0.8);
      final bgColor = isDay ? QuickTechAppColors.bktxtfld : QuickTechAppColors.darktxtfieldcolor;
      final iconColor = txtColor.withValues(alpha:0.7);

      // Wrapper to ensure uniform card-styling across all Limbs screens
      return assessmentCard(
        color: mainColor,
        title: title,
        icon: Icons.accessibility_new,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Movement & Muscle Name Textfields side-by-side
            Row(
              children: [
                Expanded(
                  child: QuickTechCustomTextField(
                    label: 'Movement',
                    controller: movementController,
                    height: 50,
                    backcolor: bgColor,
                    icon: FontAwesomeIcons.arrowsRotate.data,
                    lebelcolor: labelColor,
                    iconcolor: iconColor,
                    txtcolor: txtColor,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: QuickTechCustomTextField(
                    label: 'Muscle Name',
                    controller: muscleNameController,
                    height: 50,
                    backcolor: bgColor,
                    icon: Icons.fitness_center,
                    lebelcolor: labelColor,
                    iconcolor: iconColor,
                    txtcolor: txtColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 15),

            // Initial ROM Row
            Row(
              children: [
                Expanded(
                  flex: 3,
                  child: Text('Initial ROM', style: myStyle(15, txtColor, FontWeight.bold)),
                ),
                const SizedBox(width: 10),
                Expanded(
                  flex: 4,
                  child: QuickTechCustomTextField(
                    label: 'Left',
                    controller: leftInitialController,
                    height: 50,
                    backcolor: bgColor,
                    lebelcolor: labelColor,
                    txtcolor: txtColor,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  flex: 4,
                  child: QuickTechCustomTextField(
                    label: 'Right',
                    controller: rightInitialController,
                    height: 50,
                    backcolor: bgColor,
                    lebelcolor: labelColor,
                    txtcolor: txtColor,
                    maxline: 1,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // Discharge ROM Row
            Row(
              children: [
                Expanded(
                  flex: 3,
                  child: Text('Discharge ROM', style: myStyle(15, txtColor, FontWeight.bold)),
                ),
                const SizedBox(width: 10),
                Expanded(
                  flex: 4,
                  child: QuickTechCustomTextField(
                    label: 'Left',
                    controller: leftDischargeController,
                    height: 50,
                    backcolor: bgColor,
                    lebelcolor: labelColor,
                    txtcolor: txtColor,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  flex: 4,
                  child: QuickTechCustomTextField(
                    label: 'Right',
                    controller: rightDischargeController,
                    height: 50,
                    backcolor: bgColor,
                    lebelcolor: labelColor,
                    txtcolor: txtColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 15),

            // Comments Section
            QuickTechCustomTextField(
              maxline: 3,
              label: 'Comments',
              controller: commentController,
              height: 80,
              backcolor: bgColor,
              icon: FontAwesomeIcons.comment.data,
              lebelcolor: labelColor,
              iconcolor: iconColor,
              txtcolor: txtColor,
            ),
          ],
        ),
      );
    });
  }
}